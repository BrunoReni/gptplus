#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

/*/{Protheus.doc} MrpDominio_Periodos
Regras de negocio MRP - Periodos
@author    marcelo.neumann
@since     10/06/2019
@version   1
/*/
CLASS MrpDominio_Periodos FROM LongNameClass

	DATA dPrimeiraUtil AS DATE
	DATA dUltimaData   AS DATE
	DATA nPrimeiroUtil AS NUMERIC
	DATA oDominio      AS OBJECT
	DATA oDatasUteis   AS OBJECT
	DATA oJsPeriodos   AS OBJECT
	DATA oStatus       AS OBJECT

	METHOD new(oDominio) CONSTRUCTOR
	METHOD criarArrayPeriodos(dData, nTipo, nPeriodos)
	METHOD cargaPeriodosJson(lRecupera)
	METHOD buscaPeriodoDaData(cFilAux, dData, lMenorIgua, nTipoPer)
	METHOD buscaProximoDiaUtil(cFilAux, dDataPar)
	METHOD buscaDataPeriodo(cFilAux, dData, nTipo, dInicio)
	METHOD montaPeriodos(cFilAux, dData, nTipo, nPeriodos)
	METHOD proximaData(cFilAux, dData, nTipo, dInicio)
	METHOD primeiroPeriodoUtil(cFilAux)
	METHOD primeiraDataUtil(cFilAux)
	METHOD retornaArrayPeriodos(cFilAux, nTipoPer)
	METHOD retornaDataPeriodo(cFilAux, nPeriodo)
	METHOD ultimaDataDoMRP()
	METHOD validaPeriodos(cFilAux)
	METHOD verificaDataUtil(cFilAux, dData, lError)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    marcelo.neumann
@since     10/06/2019
@version   1
@param 01 - oDominio, numero  , objeto da camada de dominio
/*/
METHOD new(oDominio) CLASS MrpDominio_Periodos
	::oDominio      := oDominio
	::oDatasUteis   := JsonObject():New()
	::nPrimeiroUtil := 0
	::dPrimeiraUtil := Nil
	::dUltimaData   := Nil
	::oStatus       := MrpDados_Status():New(oDominio:oParametros["ticket"])
	::oJsPeriodos   := Nil

	Self:cargaPeriodosJson(.T.)

Return Self

/*/{Protheus.doc} criarArrayPeriodos
Gera array de periodos
@author    marcelo.neumann
@since     25/04/2019
@version 1.0
@param 01 dData    , data  , indica a data inicial
@param 02 nTipo    , numero, indica o tipo de periodo a ser utilizado
@param 03 nPeriodos, numero, indica a quantidade de periodos a ser utilizada
/*/
METHOD criarArrayPeriodos(dData, nTipo, nPeriodos) CLASS MrpDominio_Periodos
	Local aFiliais  := {}
	Local aMontaPer := {}
	Local cErro     := ""
	Local cNewErro  := ""
	Local lUsaME    := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local oMultiEmp := ::oDominio:oMultiEmp

	Default dData     := dDataBase
	Default nTipo     := 1
	Default nPeriodos := 30

	lUsaME := oMultiEmp:utilizaMultiEmpresa()

	If lUsaME
		nTotal := oMultiEmp:totalDeFiliais()

		For nIndex := 1 To oMultiEmp:totalDeFiliais()
			aAdd(aFiliais, oMultiEmp:filialPorIndice(nIndex))
		Next nIndex
	Else
		aAdd(aFiliais, "")
	EndIf

	::oJsPeriodos := JsonObject():New()
	nTotal        := Len(aFiliais)

	For nIndex := 1 To nTotal
		If lUsaME
			Self:oDominio:oLogs:log(STR0177 + aFiliais[nIndex], "21") //"Gerando per�odos da filial "
		EndIf
		aMontaPer := Self:montaPeriodos(aFiliais[nIndex], dData, nTipo, nPeriodos)

		If Empty(aMontaPer[1])
			::oJsPeriodos[aFiliais[nIndex]] := aMontaPer[2]
		Else
			cErro := aMontaPer[1]
			Exit
		EndIf

		cNewErro := Self:validaPeriodos(aFiliais[nIndex])
		If !Empty(cNewErro)
			If !Empty(cErro)
				cErro += CHR(10)
			EndIf
			If lUsaME
				cErro += STR0176 + " " + AllTrim(aFiliais[nIndex]) + " " //"Filial"
			EndIf
			cErro += cNewErro
		EndIf
	Next nIndex

	If !Empty(cErro)
		Self:oStatus:gravaErro("memoria", cErro)
	EndIf

	//Armazena o JSON de per�odos na global, para recuperar durante o c�lculo.
	Self:cargaPeriodosJson(.F.)

	aSize(aFiliais, 0)
Return

/*/{Protheus.doc} montaPeriodos
Gera array de periodos para a filial espec�fica

@author    lucas.franca
@since     28/06/2021
@version 1.0
@param 01 - cFilAux  , caracter, c�digo da filial
@param 02 - dData    , data    , indica a data inicial
@param 03 - nTipo    , numero  , indica o tipo de periodo a ser utilizado
@param 04 - nPeriodos, numero  , indica a quantidade de periodos a ser utilizada
@return aRet, array, aRet[1] - Erro ocorrido, aRet[2] - Array coms os periodos.
/*/
METHOD montaPeriodos(cFilAux, dData, nTipo, nPeriodos) CLASS MrpDominio_Periodos
	Local aPeriodos := {}
	Local aRet      := {}
	Local cMsgErro  := ""
	Local dInicio   := dData
	Local lOk       := .T.
	Local nIndex    := 0
	Local nLenPeri  := 0

	//Calcula a primeira data a ser verificada
	If nTipo <> 1
		dData := Self:buscaDataPeriodo(cFilAux, dData, nTipo, dInicio)
	EndIf

	//Carrega os demais per�odos
	For nIndex := 1 To nPeriodos
		aAdd(aPeriodos, dData)

		Self:oDominio:oLogs:log(STR0018 + cValToChar(nIndex) + " - " + DtoS(dData), "21") //"Periodo '"

		dData := Self:proximaData(cFilAux, dData, nTipo, dInicio)
	Next nIndex

	If ExistBlock("P712PERI")
		nLenPeri := Len(aPeriodos)

		aPeriodos := ExecBlock("P712PERI", .F., .F., aPeriodos)
		aSort(aPeriodos)

		// Verifica se o array retornado tem todos os itens do tipo date
		For nIndex := 1 to Len(aPeriodos)
			If ValType(aPeriodos[nIndex]) != "D"
				cMsgErro := STR0180 	// "O array aPeriodos retornado contem itens diferente do tipo date."
				lOk := .F.
				Exit
			EndIf
		Next

		// Verifica se o array tem mesmo tamanho do original
		If lOk .and. Len(aPeriodos) != nLenPeri
			cMsgErro := STR0181 	// "Tamanho do array aPeriodos retornado difere do tamanho original."
			lOk := .F.
		EndIf
	EndIf

	aAdd(aRet, cMsgErro)
	aAdd(aRet, aPeriodos)

Return aRet

/*/{Protheus.doc} validaPeriodos
Executa valida��es nos per�odos

@author    lucas.franca
@since     28/06/2021
@version 1.0
@param 01 - cFilAux  , caracter, c�digo da filial
@return cErro, Character, Mensagem de erro caso ocorra.
/*/
METHOD validaPeriodos(cFilAux) CLASS MrpDominio_Periodos
	Local cErro       := ""
	Local cUteis      := ""
	Local dData       := Nil
	Local dDtLimite   := Nil
	Local lError      := .F.
	Local lExistUtil  := .F.

	//Se utiliza o calend�rio, valida se todas as datas existem no calend�rio
	If Self:oDominio:oParametros["nLeadTime"] <> 1
		dData     := Self:retornaDataPeriodo(cFilAux, 1)
		dDtLimite := Self:ultimaDataDoMRP()

		While dData <= dDtLimite .AND. dDtLimite != Nil
			cUteis := Self:oDominio:oDados:retornaCampo("CAL", 1, cFilAux + DToS(dData), "CAL_UTEIS", @lError)

			//Retorna erro se a data n�o existir no calend�rio
			If lError
				cErro := STR0099 + DToC(dData) + STR0100 //"Data " XX/XX/XX " nao encontrada no calendario do MRP."
				Self:oDominio:oDados:oLogs:log(cErro, "21")
				Exit
			ElseIf cUteis <> "00:00"
				lExistUtil := .T.
			EndIf
			dData++
		Enddo

		If !lExistUtil .And. !lError
			cErro := STR0141 + DToC(Self:retornaDataPeriodo(cFilAux, 1)) + STR0142 + DToC(dDtLimite) + "." //"N�o existe dia �til no per�odo de processamento informado: " + XX/XX/XX + " at� " + XX/XX/XX
			Self:oDominio:oDados:oLogs:log(cErro, "21")
		EndIf
	EndIf

Return cErro

/*/{Protheus.doc} cargaPeriodosJson
Verifica se os per�odos j� foram gerados, e carrega da mem�ria para a thread atual.

@author lucas.franca
@since 29/06/2021
@version 1.0
@param lRecupera, Logic, Identifica se deve recuperar da mem�ria, ou salvar na mem�ria.
@return Nil
/*/
METHOD cargaPeriodosJson(lRecupera) CLASS MrpDominio_Periodos
	Local aNames     := {}
	Local cJsPeriodo := ""
	Local lError     := .F.
	Local nIndName   := 0
	Local nTotName   := 0
	Local nIndPer    := 0
	Local nTotPer    := 0

	If lRecupera
		//Recupera da mem�ria, e salva na thread atual.
		cJsPeriodo := Self:oDominio:oDados:oMatriz:getFlag("PERIODOS_PROCESSAMENTO", @lError)
		If !lError .And. !Empty(cJsPeriodo)
			Self:oJsPeriodos := JsonObject():New()
			Self:oJsPeriodos:FromJson(cJsPeriodo)

			aNames   := Self:oJsPeriodos:GetNames()
			nTotName := Len(aNames)
		EndIf
	Else
		//Salva da thread atual na mem�ria.
		//Percorre os per�odos e converte para o formato de data em JSON.
		aNames   := Self:oJsPeriodos:GetNames()
		nTotName := Len(aNames)
		For nIndName := 1 To nTotName
			nTotPer := Len(Self:oJsPeriodos[aNames[nIndName]])
			For nIndPer := 1 To nTotPer
				dData := Self:oJsPeriodos[aNames[nIndName]][nIndPer]
				Self:oJsPeriodos[aNames[nIndName]][nIndPer] := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
			Next nIndPer
		Next nIndName

		Self:oDominio:oDados:oMatriz:setFlag("PERIODOS_PROCESSAMENTO", Self:oJsPeriodos:ToJson())
	EndIf

	If !lError
		//Retorna os formatos de data para DATE
		For nIndName := 1 To nTotName
			nTotPer := Len(Self:oJsPeriodos[aNames[nIndName]])
			For nIndPer := 1 To nTotPer
				Self:oJsPeriodos[aNames[nIndName]][nIndPer] := StoD( StrTran(Self:oJsPeriodos[aNames[nIndName]][nIndPer], "-", "") )
			Next nIndPer
		Next nIndName
		aSize(aNames, 0)
	EndIf

Return

/*/{Protheus.doc} retornaDataPeriodo
Retorna a data do aPeriodos contino no JSON oJsPeriodos

@author ricardo.prandi
@since 05/07/2021
@version 1.0
@param 01 - cFilAux , character, c�digo da filial
@param 02 - nPeriodo, numerico , n�mero do per�odo que ser� retornado
@param 03 - nTipoPer, numerico , tipo de per�odo que deve ser considerado (default = periodo do mrp)
@return dData  , date     , data do per�odo
/*/
METHOD retornaDataPeriodo(cFilAux, nPeriodo, nTipoPer) CLASS MrpDominio_Periodos
	Local aPeriodos := Nil

	Default nTipoPer := Self:oDominio:oParametros["nTipoPeriodos"]

	If nPeriodo == 0
		nPeriodo := 1
	EndIf

	aPeriodos := Self:retornaArrayPeriodos(cFilAux, nTipoPer)

Return aPeriodos[nPeriodo]

/*/{Protheus.doc} retornaArrayPeriodos
Retorna o aPeriodos da filial

@author marcelo.neumann
@since 05/07/2021
@version 1.0
@param 01 - cFilAux , character, c�digo da filial
@param 02 - nTipoPer, numerico , tipo de per�odo que deve ser considerado (default = periodo do mrp)
@return dData , date     , data do per�odo
/*/
METHOD retornaArrayPeriodos(cFilAux, nTipoPer) CLASS MrpDominio_Periodos

	Local aPeriodos := {}
	Local aDados    := {}
	Local cChavePer := ""

	Default nTipoPer := Self:oDominio:oParametros["nTipoPeriodos"]

	If Empty(cFilAux)
		cFilAux := IIf(Self:oDominio:oMultiEmp:utilizaMultiEmpresa(), Self:oDominio:oMultiEmp:filialPorIndice(1), "")
	EndIf

	If Self:oJsPeriodos == Nil
		Self:cargaPeriodosJson(.T.)
	EndIf

	If Self:oJsPeriodos != Nil
		If nTipoPer == Self:oDominio:oParametros["nTipoPeriodos"]
			aPeriodos := Self:oJsPeriodos[cFilAux]
		Else
			/*
				Tipo de per�odo do aPeriodos somente ser� diferente do 
				parametrizado para o MRP (Self:oDominio:oParametros["nTipoPeriodos"])
				quando estiver sendo executada a valida��o para realizar a aglutina��o de per�odos
				para o produto, atrav�s das regras do campo MI_AGLUMRP.
			*/
			cChavePer := cValToChar(nTipoPer) + "_" + cFilAux
			If !Self:oJsPeriodos:HasProperty(cChavePer)
				//Ainda n�o foi criado o aPeriodos para o tipo de per�odo necess�rio.
				//Ir� criar e salvar no "oJsPeriodos".
				aDados := Self:montaPeriodos(cFilAux                              ,;
				                             Self:oDominio:oParametros["dDataIni"],;
				                             nTipoPer                             ,;
				                             Self:oDominio:oParametros["nPeriodos"])
				Self:oJsPeriodos[cChavePer] := aDados[2]
				aSize(aDados, 0)
			EndIf
			aPeriodos := Self:oJsPeriodos[cChavePer]
		EndIf
	EndIf

Return aPeriodos

/*/{Protheus.doc} buscaDataPeriodo
Identifica qual � a data que deve ser utilizada no per�odo, considerando o calend�rio.
Utilizada para quando os per�odos do MRP n�o s�o do tipo Di�rio.
M�todo utilizado durante a cria��o do aPeriodos.

@author lucas.franca
@since 10/10/2019
@version 1.0
@param 01 - cFilAux, character, c�digo da filial
@param 02 - dData  , date     , Data atual que est� sendo considerada.
@param 03 - nTipo  , numeric  , Tipo do processamento do MRP.
@param 04 - dInicio, date     , Data inicial do MRP
@return     dData  , date     , Data que dever� ser considerada para o per�odo.
/*/
METHOD buscaDataPeriodo(cFilAux, dData, nTipo, dInicio) CLASS MrpDominio_Periodos

	//Somente processa caso utilize calend�rio e a data atual n�o � �til.
	If Self:oDominio:oParametros["nLeadTime"] != 1 .And. !Self:verificaDataUtil(cFilAux, dData)
		dData := Self:buscaProximoDiaUtil(cFilAux, dData)

		//A data do per�odo � menor que a data de in�cio do MRP.
		//Utiliza como data do per�odo a data de in�cio do MRP.
		If dData < dInicio
			dData := dInicio
		EndIf
	EndIf

Return dData

/*/{Protheus.doc} buscaPeriodoDaData
Identifica a posi��o da data no per�odo, caso n�o exista, pode retornar o per�odo anterior (requer ::aPeriodos ordenado)
@author brunno.costa
@since 04/06/2019
@version 1.0
@param 01 - cFilAux   , caracter, filial do per�odo
@param 02 - dData     , array   , data para conversao
@param 03 - lMenorIgua, l�gico  , indica se deve retornar o per�odo anterior caso n�o exista um correspondente � data:
                                  true  -> retorna o per�odo anterior (default)
								  false -> retorna 0 caso n�o encontre per�odo para a data
@param 04 - nTipoPer  , numerico, tipo de per�odo que deve ser considerado (default = periodo do mrp)
@return     nPosicao  , numerico, indica a posicao do array de per�odos correpondente � data (dData)
/*/
METHOD buscaPeriodoDaData(cFilAux, dData, lMenorIgua, nTipoPer) CLASS MrpDominio_Periodos
	Local aPeriodos := Nil
	Local nInf      := 1 // limite inferior
    Local nMeio     := 0
	Local nPosicao  := 0
    Local nSup      := 0 // limite superior

	Default lMenorIgua := .T.
	Default nTipoPer   := Self:oDominio:oParametros["nTipoPeriodos"]

	aPeriodos := Self:retornaArrayPeriodos(cFilAux, nTipoPer)
	nSup      := Len(aPeriodos) //Limite superior

    While (nInf < nSup)
        nMeio := (nInf + nSup - 1 - Mod((nInf + nSup-1), 2)) / 2
		If (dData == aPeriodos[nMeio])
			nPosicao := nMeio
			Exit
        ElseIf (dData < aPeriodos[nMeio])
			nSup := nMeio - 1
        Else
			nInf := nMeio + 1
		EndIf
    Enddo

    If nInf == nSup
		nPosicao := nInf
	EndIf

	//Se estiver buscando o menor ou igual, verifica se a data realmente � menor ou igual que a do per�odo
	If lMenorIgua .And. nPosicao == 0
		nPosicao := nSup
	EndIf

	//Se estiver buscando o menor ou igual, verifica se a data realmente � menor ou igual que a do per�odo
	If lMenorIgua .And. nPosicao > 0
		If dData < aPeriodos[nPosicao]
			nPosicao--
		EndIf
	EndIf

Return nPosicao

/*/{Protheus.doc} buscaProximoDiaUtil
Busca o pr�ximo dia �til no calend�rio MRP partindo da data enviada
@author marcelo.neumann
@since 24/06/2019
@version 1.0
@param 01 - cFilAux , Caracter, C�digo da filial
@param 02 - dDataPar, data    , data de partida para buscar o pr�ximo dia �til
@return     dData   , data    , data do pr�ximo dia �til de acordo com o calend�rio MRP
/*/
METHOD buscaProximoDiaUtil(cFilAux, dDataPar) CLASS MrpDominio_Periodos

	Local dData  := dDataPar
	Local lError := .F.

	//Verifica se a data possui hora de trabalho
	While !Self:verificaDataUtil(cFilAux, dData, @lError)
		If lError
			dData := dDataPar
			Exit
		EndIf
		dData++
	EndDo

Return dData

/*/{Protheus.doc} proximaData
Calcula e retorna qual ser� a pr�xima data de acordo com o tipo de processamento
@author marcelo.neumann
@since 11/07/2019
@version 1.0
@param 01 - cFilAux, caracter, c�digo da filial
@param 02 - dData  , data    , data de partida para buscar a pr�xima
@param 03 - nTipo  , numero  , indica o tipo de periodo a ser utilizado: 1- Di�rio
                                                                         2- Semanal
                                                                         3- Quinzenal
                                                                         4- Mensal
@param 04 - dInicio, data    , Data inicial do processo do MRP
@return     dData  , data    , pr�xima data de acordo com o tipo
/*/
METHOD proximaData(cFilAux, dData, nTipo, dInicio) CLASS MrpDominio_Periodos

	Do Case
		Case nTipo == 1 //Di�rio
			dData++

		Case nTipo == 2 //Semanal
			dData += 7
			While Dow(dData) > 1
				dData--
			End

		Case nTipo == 3 //Quinzenal
			If Day(dData) < 15
				dData := FirstDate(dData) + 14
			Else
				dData := FirstDate(MonthSum(dData,1))
			EndIf

		Case nTipo == 4 //Mensal
			dData := FirstDate(MonthSum(dData,1))
	EndCase

	dData := Self:buscaDataPeriodo(cFilAux, dData, nTipo, dInicio)

Return dData

/*/{Protheus.doc} primeiroPeriodoUtil
Retorna qual � o primeiro per�odo �til de acordo com o calend�rio, respeitando a parametriza��o de
utiliza��o do calend�rio. Mant�m o primeiro per�odo salvo na vari�vel nPrimeiroUtil para n�o fazer a busca
todas as vezes que este m�todo for executado.

@author lucas.franca
@since 02/10/2019
@version 1.0
@param 01 - cFilAux, Character, C�digo da filial
@return Self:nPrimeiroUtil, Numeric, primeiro per�odo �til de acordo com o calend�rio.
/*/
Method primeiroPeriodoUtil(cFilAux) CLASS MrpDominio_Periodos
	If Self:nPrimeiroUtil == 0
		If Self:oDominio:oParametros["nLeadTime"] <> 1
			Self:dPrimeiraUtil := Self:buscaProximoDiaUtil(cFilAux, Self:retornaDataPeriodo(cFilAux, 1))
			Self:nPrimeiroUtil := Self:buscaPeriodoDaData(cFilAux, Self:dPrimeiraUtil)
		Else
			Self:nPrimeiroUtil := 1
		EndIf
	EndIf
Return Self:nPrimeiroUtil

/*/{Protheus.doc} primeiraDataUtil
Retorna qual � a primeira data �til de acordo com o calend�rio, respeitando a parametriza��o de
utiliza��o do calend�rio. Mant�m o primeiro per�odo salvo na vari�vel dPrimeiraUtil para n�o fazer a busca
todas as vezes que este m�todo for executado.

@author lucas.franca
@since 02/10/2019
@version 1.0
@param 01 - cFilAux, Character, C�digo da filial
@return Self:nPrimeiroUtil, Numeric, primeiro per�odo �til de acordo com o calend�rio.
/*/
Method primeiraDataUtil(cFilAux) CLASS MrpDominio_Periodos
	If Self:dPrimeiraUtil == Nil
		Self:primeiroPeriodoUtil(cFilAux)
	EndIf
Return Self:dPrimeiraUtil

/*/{Protheus.doc} verificaDataUtil
Verifica no Calend�rio se determinada data � �til ou n�o, de acordo com
a parametriza��o nLeadTime.

@author lucas.franca
@since 02/10/2019
@version 1.0
@param 01 - cFilAux, Character, C�digo da filial
@param 02 - dData  , Date     , Data para verifica��o
@param 03 - lError , Logic    , Retorna por refer�ncia se houve erro na busca do calend�rio
@return lDataUtil, logic, .T. se a data dData for �til de acordo com o calend�rio.
/*/
Method verificaDataUtil(cFilAux, dData, lError) CLASS MrpDominio_Periodos
	Local cChaveData := ""
	Local cUteis     := ""
	Local lDataUtil  := .T.
	Default lError   := .F.

	If Self:oDominio:oParametros["nLeadTime"] <> 1
		cChaveData := cFilAux + DtoS(dData)
		If Self:oDatasUteis[cChaveData] == Nil
			cUteis := Self:oDominio:oDados:retornaCampo("CAL", 1, cChaveData, "CAL_UTEIS", @lError)
			If lError .Or. cUteis == "00:00"
				Self:oDatasUteis[cChaveData] := .F.
				If lError
					::oDominio:oDados:oLogs:log(STR0099 + "'" + cFilAux + "' " + DToC(dData) + STR0100, "21") //"Data " XX/XX/XX " nao encontrada no calendario do MRP."
				EndIf
			Else
				Self:oDatasUteis[cChaveData] := .T.
			EndIf
		EndIf
		lDataUtil := Self:oDatasUteis[cChaveData]
	EndIf
Return lDataUtil

/*/{Protheus.doc} ultimaDataDoMRP
Retorna a �ltima data que deve ser considerada no MRP.

@author lucas.franca
@since 11/10/2019
@version 1.0
@return dData, date, �ltima data do MRP.
/*/
METHOD ultimaDataDoMRP() CLASS MrpDominio_Periodos
	Local aPeriodos := Self:retornaArrayPeriodos()
	Local dData     := Nil
	Local nLastPer  := Len(aPeriodos)

	If Self:dUltimaData == Nil .AND. nLastPer > 0
		If Self:oDominio:oParametros["nTipoPeriodos"] == 1 //Per�odo di�rio
			//Ir� utilizar como �ltima data do MRP a mesma data do �ltimo per�odo.
			Self:dUltimaData := aPeriodos[nLastPer]
		ElseIf Self:oDominio:oParametros["nTipoPeriodos"] == 2 //Per�odo semanal
			//Ir� utilizar como �ltima data do MRP o �ltimo dia da �ltima semana de processamento.
			Self:dUltimaData := aPeriodos[nLastPer]
			While Dow(Self:dUltimaData) < 7
				Self:dUltimaData++
			End
		ElseIf Self:oDominio:oParametros["nTipoPeriodos"] == 3 //Per�odo quinzenal
			//Ir� utilizar como �ltima data do MRP o �ltimo dia da �ltima quinzena de processamento.
			Self:dUltimaData := aPeriodos[nLastPer]
			If Day(Self:dUltimaData) < 15
				//Primeira quinzena do m�s.
				While Day(Self:dUltimaData) < 14
					Self:dUltimaData++
				End
			Else
				//Segunda quinzena do m�s. Utiliza �ltimo dia do m�s
				Self:dUltimaData := FirstDate(MonthSum(Self:dUltimaData,1)) - 1
			EndIf
		Else //Per�odo mensal
			//Ir� utilizar como �ltima data do MRP o �ltimo dia do m�s.
			Self:dUltimaData := aPeriodos[nLastPer]
			Self:dUltimaData := FirstDate(MonthSum(Self:dUltimaData,1)) - 1
		EndIf
	EndIf

	dData := Self:dUltimaData
Return dData