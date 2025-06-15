#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA152.CH"

#DEFINE CHAR_ETAPAS_CALC_DISP "calculo_disponibilidade"

#DEFINE HORA_DISPONIVEL "1"
#DEFINE HORA_PARADA     "2"
#DEFINE HORA_EXTRA      "3"

#DEFINE HORA_BLOQUEADA     "1"
#DEFINE HORA_NAO_BLOQUEADA "2"

#DEFINE CALEND_POS_HORAS   1
#DEFINE CALEND_POS_MINUTOS 2
#DEFINE CALEND_POS_HORAINI 1
#DEFINE CALEND_POS_HORAFIM 2

#DEFINE ARRAY_MR_FILIAL   1
#DEFINE ARRAY_MR_PROG     2
#DEFINE ARRAY_MR_DISP     3
#DEFINE ARRAY_MR_RECURSO  4
#DEFINE ARRAY_MR_TIPO     5
#DEFINE ARRAY_MR_CALEND   6
#DEFINE ARRAY_MR_DATDISP  7
#DEFINE ARRAY_MR_SITUACA  8
#DEFINE ARRAY_MR_TEMPODI  9
#DEFINE ARRAY_MR_TEMPOBL 10
#DEFINE ARRAY_MR_TEMPOPA 11
#DEFINE ARRAY_MR_TEMPOEX 12
#DEFINE ARRAY_MR_TEMPOTO 13
#DEFINE ARRAY_MR_TAMANHO 13

#DEFINE ARRAY_MK_FILIAL   1
#DEFINE ARRAY_MK_PROG     2
#DEFINE ARRAY_MK_DISP     3
#DEFINE ARRAY_MK_SEQ      4
#DEFINE ARRAY_MK_DATDISP  5
#DEFINE ARRAY_MK_HRINI    6
#DEFINE ARRAY_MK_HRFIM    7
#DEFINE ARRAY_MK_TIPO     8
#DEFINE ARRAY_MK_BLOQUE   9
#DEFINE ARRAY_MK_TAMANHO  9

#DEFINE FACTORY_OPC_DISP  2

#DEFINE ARRAY_DISP_RECURSO_DATA        1
#DEFINE ARRAY_DISP_RECURSO_HORA_INICIO 2
#DEFINE ARRAY_DISP_RECURSO_HORA_FIM    3
#DEFINE ARRAY_DISP_RECURSO_TEMPO       4
#DEFINE ARRAY_DISP_RECURSO_TAMANHO     4

/*/{Protheus.doc} PCPA152Disponibilidade
Classe respons�vel por calcular a disponibilidade dos recursos.

@author lucas.franca
@since 01/02/2023
@version P12
/*/
CLASS PCPA152Disponibilidade FROM LongNameClass

	Private Data cFilSMK    as Character
	Private Data cFilSMR    as Character
	Private Data nTamMRDISP as Number
	Private Data oBlockRec  as Object
	Private Data oCalend    as Object
	Private Data oExcCalend as Object
	Private Data oParDisp   as Object
	Private Data oProcesso  as Object
	Private Data oQryBlock  as Object

	//M�todos para uso externo
	Public Method New(oProcesso) CONSTRUCTOR
	Public Method Destroy()
	Public Method calculaDispRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi)
	Public Method carregaDisponibilidade()
	Public Method gravaTabelasDisponibilidade()
	Public Method defineParametro(cParametro, xValor)
	Public Method processaRecursos()
	Public Method getDisponibilidadeRecurso(cRecurso)

	//M�todos de uso interno
	Private Method buscaCalendario(dData, cCalend)
	Private Method buscaBloqueiosEExecao(oJsData, dData, cRecurso, cCentCusto)
	Private Method estruturaTabela(cTabela)
	Private Method chaveExcecao(cData, cRecurso, cCentCusto)
	Private Method geraDetalheDisponibilidade(dData, aCalPad, aCalExc, aBloqueio, cCodDisp)
	Private Method gravaTabela(cTabela, aDados)
	Private Method processandoRecursos(nTotRecur, nQtdProc)
	Private Method totalDeMinutos(cHoraIni, cHoraFim)
	Private Method uneCalendarioExcecao(aCalExc, aCalPad)
	Private Method validaBloqueios(aHoras, aTotais, aBloqueio)
	Private Method aguardaCargaTabelas()
	Private Method gerouDisponibilidade()
	Private Method retornaQueryRecursos()
	Public Method carregaSMR()
	Public Method carregaSMK()

	//M�todos para manipula��o do calend�rio
	Private Method carregaCalendario(cCalend)
	Private Method carregaBloqueioRecurso(cRecurso, cCentCusto)
	Private Method carregaExcecaoCalendario(cRecurso, cCentCusto)
	Private Method converteHorasCalendario(cAloc)
	Private Method horaPosicionada(nPosicao)

	//Disponibiliza c�lculo das horas de calend�rio sem a necessidade da classe de programa��o.
	Static Method buscaHorasRecurso(cRecurso, dDataIni, dDataFim)
	Static Method descricaoTipoHora(cTipo)
EndClass

/*/{Protheus.doc} New
M�todo construtor da classe.

@author lucas.franca
@since 01/02/2023
@version P12
@param 01 oProcesso, Object, Objeto de controle do processo da programa��o
@return Self, Object, Inst�ncia da classe
/*/
Method New(oProcesso) CLASS PCPA152Disponibilidade

	Self:oCalend   := JsonObject():New()
	Self:oProcesso := oProcesso

	//Par�metros utilizados por esta classe. Dados s�o obtidos de oProcesso quando existir,
	//ou ser�o definidos pelo m�todo defineParametro quando utilizado sem o uso da programa��o.
	//Se adicionar novos par�metros, verificar tamb�m o novo par�metro no m�todo buscaHorasRecurso.
	Self:oParDisp := JsonObject():New()
	If Self:oProcesso != Nil
		Self:oParDisp["dataInicial"   ] := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataInicial")),3))
		Self:oParDisp["dataFinal"     ] := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataFinal")),3))
		Self:oParDisp["MV_PRECISA"    ] := Self:oProcesso:retornaParametro("MV_PRECISA")
		Self:oParDisp["cProg"         ] := Self:oProcesso:retornaProgramacao()
		Self:oParDisp["recursos"      ] := Self:oProcesso:retornaParametro("recursos")
		Self:oParDisp["centroTrabalho"] := Self:oProcesso:retornaParametro("centroTrabalho")
		Self:cFilSMR    := xFilial("SMR")
		Self:cFilSMK    := xFilial("SMK")
		Self:nTamMRDISP := GetSX3Cache("MR_DISP", "X3_TAMANHO")
	Else
		Self:cFilSMR    := ""
		Self:cFilSMK    := ""
		Self:nTamMRDISP := 10
	EndIf

Return Self

/*/{Protheus.doc} Destroy
Limpa as propriedades da classe

@author lucas.franca
@since 09/02/2023
@version P12
@return Nil
/*/
Method Destroy() CLASS PCPA152Disponibilidade

	If Self:oQryBlock <> Nil
		Self:oQryBlock:Destroy()
		Self:oQryBlock := Nil
	EndIf

	Self:oProcesso  := Nil
	Self:cFilSMR    := Nil
	Self:cFilSMK    := Nil
	Self:nTamMRDISP := Nil
	FwFreeObj(Self:oCalend)
	FwFreeObj(Self:oParDisp)
Return

/*/{Protheus.doc} calculaDispRecurso
Faz o c�lculo da disponibilidade para um recurso

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cRecurso  , Caracter, C�digo do recurso
@param 02 cCalend   , Caracter, C�digo do calend�rio vinculado ao recurso
@param 03 cCentCusto, Caracter, C�digo do centro de custo vinculado ao recurso
@param 04 cRecIlimi , Caracter, Indicador se o recurso � ilimitado
@return aRegs, Array, Array com os dados da disponibilidade. Somente quando utilizado sem a programa��o.
/*/
Method calculaDispRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi) CLASS PCPA152Disponibilidade
	Local aBloqueio := Nil
	Local aCalExc   := Nil
	Local aCalPad   := Nil
	Local aDisp     := Array(ARRAY_MR_TAMANHO)
	Local aRegs     := {}
	Local aTotais   := {}
	Local dData     := Self:oParDisp["dataInicial"]
	Local dDataFim  := Self:oParDisp["dataFinal"]
	Local nSequen   := 0

	//Verifica se o calend�rio do recurso j� foi carregado.
	Self:carregaCalendario(cCalend)

	//Carrega exce��es e bloqueios do recurso
	Self:carregaExcecaoCalendario(cRecurso, cCentCusto)
	Self:carregaBloqueioRecurso(cRecurso, cCentCusto)

	//Carrega valores fixos do array aDisp
	aDisp[ARRAY_MR_FILIAL ] := Self:cFilSMR
	aDisp[ARRAY_MR_PROG   ] := Self:oParDisp["cProg"]
	aDisp[ARRAY_MR_RECURSO] := cRecurso
	aDisp[ARRAY_MR_TIPO   ] := "1"
	aDisp[ARRAY_MR_CALEND ] := cCalend
	aDisp[ARRAY_MR_SITUACA] := Iif(cRecIlimi=="S","2","1")

	//Percorre dia por dia para gerar a disponibilidade
	While dData <= dDataFim
		//Busca dados calend�rio padr�o, exce��o de calend�rio e bloqueio de recursos
		aCalPad   := Self:buscaCalendario(dData, cCalend)
		aCalExc   := Self:buscaBloqueiosEExecao(Self:oExcCalend, dData, cRecurso, cCentCusto)
		aBloqueio := Self:buscaBloqueiosEExecao(Self:oBlockRec , dData, cRecurso, cCentCusto)

		//Total de horas dispon�veis no calend�rio
		aDisp[ARRAY_MR_TEMPODI] := aCalPad[CALEND_POS_MINUTOS]
		//Inicializa horas bloqueadas, paradas, extras e horas recurso para 0
		aDisp[ARRAY_MR_TEMPOBL] := 0
		aDisp[ARRAY_MR_TEMPOPA] := 0
		aDisp[ARRAY_MR_TEMPOEX] := 0
		aDisp[ARRAY_MR_TEMPOTO] := 0

		//Somente registra se existir algum hor�rio
		If aDisp[ARRAY_MR_TEMPODI] != 0 .Or. !Empty(aCalExc) .Or. !Empty(aBloqueio)

			//Atualiza sequencia e data da disponibilidade
			If Self:oProcesso != Nil
				Self:oProcesso:gravaValorGlobal("MR_DISP_SEQUENCE", @nSequen, .F., .T.)
			Else
				nSequen++
			EndIf
			aDisp[ARRAY_MR_DISP   ] := StrZero(nSequen, Self:nTamMRDISP)
			aDisp[ARRAY_MR_DATDISP] := dData

			//Gera dados da SMK
			aTotais := Self:geraDetalheDisponibilidade(dData               ,;
			                                           aCalPad             ,;
			                                           aCalExc             ,;
			                                           aBloqueio           ,;
			                                           aDisp[ARRAY_MR_DISP] )

			//Atualiza as horas extras, paradas e bloqueadas conforme o detalhamento gerado na SMK
			If aTotais[1] > 0
				aDisp[ARRAY_MR_TEMPOPA] := aTotais[1]
			EndIf
			If aTotais[2] > 0
				aDisp[ARRAY_MR_TEMPOEX] := aTotais[2]
			EndIf
			If aTotais[3] > 0
				aDisp[ARRAY_MR_TEMPOBL] := aTotais[3]
			EndIf
			aSize(aTotais, 0)

			//Calcula hora do recurso MR_TEMPOTO = MR_TEMPODI + MR_TEMPOEX - ( MR_TEMPOBL +  MR_TEMPOPA )
			//Converte os dados para minutos para somar/subtrair
			aDisp[ARRAY_MR_TEMPOTO] := aDisp[ARRAY_MR_TEMPODI]
			aDisp[ARRAY_MR_TEMPOTO] += aDisp[ARRAY_MR_TEMPOEX]
			aDisp[ARRAY_MR_TEMPOTO] -= aDisp[ARRAY_MR_TEMPOBL] + aDisp[ARRAY_MR_TEMPOPA]

			aAdd(aRegs, aClone(aDisp))
		EndIf

		aSize(aCalPad  , 0)
		aSize(aCalExc  , 0)
		aSize(aBloqueio, 0)

		//Verifica pr�xima data
		dData++
	End
	//Adiciona dados na mem�ria global
	If Self:oProcesso != Nil
		Self:oProcesso:adicionaListaGlobal("DADOS_SMR", cRecurso, aRegs, .F.)
		aSize(aDisp, 0)
		aSize(aRegs, 0)
		Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_PROCESSADOS", 1, .T., .T.)
	EndIf

	aDisp := Nil
	FreeObj(Self:oExcCalend)
	FreeObj(Self:oBlockRec)

Return aRegs

/*/{Protheus.doc} gravaTabelasDisponibilidade
Recupera da mem�ria global os dados da disponibilidade e grava nas tabelas SMR e SMK

@author lucas.franca
@since 08/02/2023
@version P12
@return lRet, L�gico, Indica se gravou com sucesso as tabelas
/*/
Method gravaTabelasDisponibilidade() CLASS PCPA152Disponibilidade
	Local aDados := {}
	Local lRet   := .T.

	BEGIN TRANSACTION
		//Recupera dados da SMR da global.
		aDados := Self:oProcesso:retornaListaGlobal("DADOS_SMR")
		lRet   := Self:gravaTabela("SMR", aDados)

		If lRet
			//Recupera dados da SMK da global.
			aDados := Self:oProcesso:retornaListaGlobal("DADOS_SMK")
			lRet   := Self:gravaTabela("SMK", aDados)
		EndIf
	END TRANSACTION

	Self:oProcesso:limpaListaGlobal("DADOS_SMR")
	Self:oProcesso:limpaListaGlobal("DADOS_SMK")

Return lRet

/*/{Protheus.doc} defineParametro
Grava um par�metro no objeto de par�metros desta classe, para utiliza��o
sem a classe de programa��o (PCPA152Process)

@author lucas.franca
@since 13/02/2023
@version P12
@param 01 cParametro, Caracter, C�digo do par�metro
@param 02 xValor    , Any     , Valor do par�metro
@return Nil
/*/
Method defineParametro(cParametro, xValor) CLASS PCPA152Disponibilidade
	Self:oParDisp[cParametro] := xValor
Return

/*/{Protheus.doc} buscaCalendario
Busca o array de calend�rio para um determinado dia no Json de calend�rios

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 dData  , Date    , Data para busca
@param 02 cCalend, Caracter, C�digo do calend�rio
@return aCalend, Array, Array com a c�pia do calend�rio padr�o
/*/
Method buscaCalendario(dData, cCalend) CLASS PCPA152Disponibilidade
	Local nDia := Dow(dData)
Return aClone(Self:oCalend[cCalend][nDia])

/*/{Protheus.doc} buscaBloqueiosEExecao
Busca a exce��o de calend�rio ou bloqueio de recurso para o recurso em determinada data.
Ordem para considerar os dados:
1� procura a exce��o para RECURSO e CCUSTO iguais ao cRecurso e cCentCusto
2� procura a exce��o para RECURSO igual a cRecurso e H9_CCUSTO em branco
3� procura a exce��o para RECURSO em branco e CCUSTO igual a cCentCusto
4� procura a exce��o para RECURSO em branco e CCUSTO em branco
Ir� utilizar o primeiro registro que encontrar.

@author lucas.franca
@since 03/02/2023
@version P12
@param 01 oJsData   , Object  , Json com os dados da exce��o de calend�rio ou bloqueio de recurso
@param 02 dData     , Date    , Data para busca da exce��o
@param 03 cRecurso  , Caracter, C�digo do recurso para busca
@param 04 cCentCusto, Caracter, C�digo do centro de custo do recurso
@return aDados, Array, Array com as horas que devem ser utilizadas
/*/
Method buscaBloqueiosEExecao(oJsData, dData, cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local aChaves := {}
	Local aDados  := {}
	Local cData   := DtoS(dData)
	Local nIndex  := 0
	Local nTotal  := 0

	//Monta as chaves de cada busca no array aChaves
	aAdd(aChaves, Self:chaveExcecao(cData, cRecurso, cCentCusto)) // RECURSO + CENTRO CUSTO
	aAdd(aChaves, Self:chaveExcecao(cData, cRecurso, ""        )) // S� RECURSO
	aAdd(aChaves, Self:chaveExcecao(cData, ""      , cCentCusto)) // S� CENTRO CUSTO
	aAdd(aChaves, Self:chaveExcecao(cData, ""      , ""        )) // GERAL

	nTotal := Len(aChaves)
	For nIndex := 1 To nTotal
		If oJsData:HasProperty(aChaves[nIndex])
			aDados := aClone(oJsData[aChaves[nIndex]])
			Exit
		EndIf
	Next nIndex
	aSize(aChaves, 0)

Return aDados

/*/{Protheus.doc} estruturaTabela
Carrega a estrutura das tabelas que ser�o gravadas para uso durante o processo.
O array de retorno deve sempre seguir a ordem das colunas definidas nas constantes utilizadas para as tabelas.

@author lucas.franca
@since 03/02/2023
@version P12
@param 01 cTabela, Caracter, Tabela que ser� carregada
@return aEstrut, Array, Array com os campos da estrutura da tabela.
/*/
Method estruturaTabela(cTabela) CLASS PCPA152Disponibilidade
	Local aEstrut := {}

	Do Case
		Case cTabela == "SMR"
			aAdd(aEstrut, {"MR_FILIAL"})
			aAdd(aEstrut, {"MR_PROG"})
			aAdd(aEstrut, {"MR_DISP"})
			aAdd(aEstrut, {"MR_RECURSO"})
			aAdd(aEstrut, {"MR_TIPO"})
			aAdd(aEstrut, {"MR_CALEND"})
			aAdd(aEstrut, {"MR_DATDISP"})
			aAdd(aEstrut, {"MR_SITUACA"})
			aAdd(aEstrut, {"MR_TEMPODI"})
			aAdd(aEstrut, {"MR_TEMPOBL"})
			aAdd(aEstrut, {"MR_TEMPOPA"})
			aAdd(aEstrut, {"MR_TEMPOEX"})
			aAdd(aEstrut, {"MR_TEMPOTO"})

		Case cTabela == "SMK"
			aAdd(aEstrut, {"MK_FILIAL"})
			aAdd(aEstrut, {"MK_PROG"})
			aAdd(aEstrut, {"MK_DISP"})
			aAdd(aEstrut, {"MK_SEQ"})
			aAdd(aEstrut, {"MK_DATDISP"})
			aAdd(aEstrut, {"MK_HRINI"})
			aAdd(aEstrut, {"MK_HRFIM"})
			aAdd(aEstrut, {"MK_TIPO"})
			aAdd(aEstrut, {"MK_BLOQUE"})
	EndCase

Return aEstrut

/*/{Protheus.doc} chaveExcecao
Monta a chave padronizada para utiliza��o no objeto Self:oExcCalend

@author lucas.franca
@since 03/02/2023
@version P12
@param 01 cData     , Caracter, Data no formato CHAR
@param 02 cRecurso  , Caracter, C�digo do recurso
@param 03 cCentCusto, Caracter, C�digo do centro de custo
@return cChave, Caracter, Chave padronizada.
/*/
Method chaveExcecao(cData, cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local cChave := cData + CHR(10) + RTrim(cRecurso) + CHR(10) + RTrim(cCentCusto)
Return cChave

/*/{Protheus.doc} geraDetalheDisponibilidade
Processa os dados para gera��o dos detalhes da disponibilidade (SMK)

@author lucas.franca
@since 07/02/2023
@version P12
@param 01 dData    , Date    , Data da disponibilidade
@param 02 aCalPad  , Array   , Dados de horas do calend�rio padr�o
@param 03 aCalExc  , Array   , Dados de horas do calend�rio de exce��o
@param 04 aBloqueio, Array   , Dados de bloqueio de recursos
@param 05 cCodDisp , Caracter, C�digo da disponibilidade (MR_DISP)
@return aTotais, Array, Array com o total de horas extras e paradas.
        aTotais[1]=minutos em Paradas
        aTotais[2]=minutos em Extras
        aTotais[3]=minutos em Bloqueio
/*/
Method geraDetalheDisponibilidade(dData, aCalPad, aCalExc, aBloqueio, cCodDisp) CLASS PCPA152Disponibilidade

	Local aTotais   := {0,0,0}
	Local aDispDet  := Array(ARRAY_MK_TAMANHO)
	Local aRegs     := {}
	Local aHoras    := {}
	Local nIndex    := 0
	Local nTotal    := 0

	//Dados fixos do array aDispDet
	aDispDet[ARRAY_MK_FILIAL] := Self:cFilSMK
	aDispDet[ARRAY_MK_PROG  ] := Self:oParDisp["cProg"]
	aDispDet[ARRAY_MK_DISP  ] := cCodDisp

	If Empty(aCalExc)
		//Se n�o possuir exce��o de calend�rio, ir� registrar o hor�rio do calend�rio padr�o.
		nTotal := Len(aCalPad[CALEND_POS_HORAS])
		For nIndex := 1 To nTotal
			addTempo(aHoras,;
			         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI],;
			         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM],;
			         HORA_DISPONIVEL,;
			         .F.)
		Next nIndex
	Else
		//Se possui exce��o, gera as horas j� considerando a exce��o + padr�o.
		aHoras := Self:uneCalendarioExcecao(aCalExc, aCalPad)
	EndIf

	//Valida os bloqueios de recursos
	Self:validaBloqueios(@aHoras, @aTotais, aBloqueio)

	nTotal := Len(aHoras)
	For nIndex := 1 To nTotal
		aDispDet[ARRAY_MK_DATDISP] := dData
		aDispDet[ARRAY_MK_SEQ    ] := nIndex
		aDispDet[ARRAY_MK_HRINI  ] := aHoras[nIndex][1]
		aDispDet[ARRAY_MK_HRFIM  ] := aHoras[nIndex][2]
		aDispDet[ARRAY_MK_TIPO   ] := aHoras[nIndex][3]
		aDispDet[ARRAY_MK_BLOQUE ] := HORA_NAO_BLOQUEADA

		//Se existe bloqueio neste hor�rio, registra como "Bloqueada".
		If aHoras[nIndex][4]
			aDispDet[ARRAY_MK_BLOQUE] := HORA_BLOQUEADA
		EndIf

		//Sumariza horas paradas e extras
		If aHoras[nIndex][3] == HORA_PARADA
			aTotais[1] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])

		ElseIf aHoras[nIndex][3] == HORA_EXTRA
			aTotais[2] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])

		EndIf

		aAdd(aRegs, aClone(aDispDet))
	Next nIndex

	//Adiciona na mem�ria global os dados da SMK
	If Self:oProcesso != Nil
		Self:oProcesso:adicionaListaGlobal("DADOS_SMK", cCodDisp, aRegs, .F.)
	EndIf

	aSize(aDispDet, 0)
	aSize(aRegs   , 0)
	aSize(aHoras  , 0)

Return aTotais

/*/{Protheus.doc} gravaTabela
Grava dados na tabela

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cTabela, Caracter, Tabela para gravar
@param 02 aDados , Array   , Array contendo os dados para grava��o
@return lRet, Logic, Retorna se gravou com sucesso os dados
/*/
Method gravaTabela(cTabela, aDados) CLASS PCPA152Disponibilidade
	Local lRet      := .T.
	Local nIndChave := 1
	Local nTotChave := Len(aDados)
	Local nIndReg   := 1
	Local nTotReg   := 0
	Local oBulk     := FwBulk():New(RetSqlName(cTabela))

	oBulk:SetFields(Self:estruturaTabela(cTabela))

	//Percorre as chaves para grava��o
	While nIndChave <= nTotChave .And. lRet
		nIndReg := 1
		nTotReg := Len(aDados[nIndChave][2])

		//Em cada chave, percorre os registros
		While nIndReg <= nTotReg .And. lRet
			lRet := oBulk:addData(aDados[nIndChave][2][nIndReg])
			aSize(aDados[nIndChave][2][nIndReg], 0)
			//Pr�ximo registro
			nIndReg++
		End

		//Limpa os arrays
		aSize(aDados[nIndChave][2], 0)
		aSize(aDados[nIndChave]   , 0)

		//Pr�xima chave
		nIndChave++

		If nIndChave > nTotChave .And. lRet
			//Final dos dados, finaliza o bulk
			lRet := oBulk:Close()
			Exit
		EndIf
	End

	//Se deu erro, grava a mensagem de erro.
	If !lRet
		DisarmTransaction()
		Self:oProcesso:gravaErro(CHAR_ETAPAS_CALC_DISP, I18N(STR0007, {cTabela}), oBulk:getError()) //"Erro ao gravar a tabela #1[TABELA]#"
	EndIf
    oBulk:Destroy()

	aSize(aDados, 0)
Return lRet

/*/{Protheus.doc} totalDeMinutos
Retorna o total de minutos decorrentes entre hora inicial e hora final

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cHoraIni, Caracter, Hora inicial
@param 02 cHoraFim, Caracter, Hora final
@return nTotal, Number, Total de minutos
/*/
Method totalDeMinutos(cHoraIni, cHoraFim) CLASS PCPA152Disponibilidade
	Local nTotal  := 0
	Local nMinIni := __Hrs2Min(cHoraIni)
	Local nMinFim := __Hrs2Min(cHoraFim)

	nTotal := nMinFim - nMinIni
Return nTotal

/*/{Protheus.doc} uneCalendarioExcecao
Une os dados de calend�rio padr�o e calend�rio de exce��o
registrando quais hor�rios s�o hora extra, parada ou dispon�vel

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 aCalExc, Array, Array com os dados do calend�rio exce��o
@param 02 aCalPad, Array, Array com os dados do calend�rio padr�o
@return aHoras, Array, Array com as horas para registrar
/*/
Method uneCalendarioExcecao(aCalExc, aCalPad) CLASS PCPA152Disponibilidade
	Local aHoras   := {}
	Local cHoraIni := ""
	Local cHoraFim := ""
	Local nIndPad  := 1
	Local nTotPad  := Len(aCalPad[CALEND_POS_HORAS])
	Local nIndex   := 1
	Local nTotal   := Len(aCalExc[CALEND_POS_HORAS])

	//Verifica quais hor�rios deve registrar como tipo extra, parada ou normal
	For nIndex := 1 To nTotal
		//Hora inicial do calend�rio da exe��o
		cHoraIni := aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI]
		cHoraFim := aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM]

		If nIndPad > nTotPad
			//J� avaliou todos os registros do calend�rio padr�o, adiciona todos os hor�rios
			//da exce��o como hora extra
			addTempo(aHoras, cHoraIni, cHoraFim, HORA_EXTRA, .F.)
			Loop
		EndIf

		//Hora inicial da exce��o menor que hora inicial do calend�rio padr�o = hora extra
		If cHoraIni < aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
			//Exce��o inicia e termina antes do in�cio do calend�rio padr�o, registra toda a exce��o como hora extra
			If cHoraFim <= aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
				addTempo(aHoras, cHoraIni, cHoraFim, HORA_EXTRA, .F.)

				//Vai para o pr�ximo registro da exce��o
				Loop
			Else
				//Hora final da exce��o est� dentro o calend�rio padr�o.
				//Registra como extra do in�cio da exce��o at� in�cio do calend�rio padr�o
				addTempo(aHoras, cHoraIni, aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI], HORA_EXTRA, .F.)

				//Ir� reprocessar esta exce��o, mas considerando que o in�cio dela � o inicio do calend�rio padr�o
				aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI] := aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]

				nIndex-- //Decrementa �ndice do calend�rio de exce��o para avaliar novamente com o pr�ximo hor�rio do calend�rio padr�o.
				Loop
			EndIf

		//Verifica se a hora inicial da exce��o � maior que a hora inicial do calend�rio padr�o para gerar o hor�rio de parada
		ElseIf cHoraIni > aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
			//Identifica a hora final para registrar a parada
			If cHoraIni >= aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Exce��o inicia ap�s o t�rmino do calend�rio padr�o, registra este hor�rio completo do padr�o como parada.
				addTempo(aHoras                                                ,;
				         aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI],;
				         aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM],;
				         HORA_PARADA                                           ,;
				         .F.                                                    )
				nIndPad++ //Incrementa �ndice do calend�rio padr�o para verificar o pr�ximo hor�rio
				nIndex-- //Decrementa �ndice do calend�rio de exce��o para avaliar novamente com o pr�ximo hor�rio do calend�rio padr�o.
				Loop
			ElseIf cHoraIni < aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Hora inicial da exce��o � menor que o fim do calend�rio.
				//Registra parada do hor�rio in�cio do calend�rio padr�o at� in�cio da exce��o
				addTempo(aHoras, aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI], cHoraIni, HORA_PARADA, .F.)
				//Reavalia considerando como inicio do calend�rio padr�o o hor�rio ap�s a parada registrada
				aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI] := cHoraIni
				nIndex-- //Decrementa �ndice do calend�rio de exce��o para avaliar novamente com o pr�ximo hor�rio do calend�rio padr�o.
				Loop
			EndIf

		//Hora de in�cio da exce��o � igual ao in�cio do calend�rio padr�o, registra como hora normal
		ElseIf cHoraIni == aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
			//Verifica hora fim.
			If cHoraFim <= aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Final da exce��o � anterior ao final do calend�rio padr�o, registra como hora normal at� o fim do calend�rio exce��o
				addTempo(aHoras, cHoraIni, cHoraFim, HORA_DISPONIVEL, .F.)

				//Define como hora inicial do calend�rio padr�o o final da exce��o
				aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI] := cHoraFim

				//Se a hora final da exce��o for igual ao final do calend�rio padr�o,
				//invrementa o �ndice de calend�rio padr�o para validar o pr�ximo hor�rio
				If cHoraFim == aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
					nIndPad++
				EndIf

				//Processa pr�ximo registro da exce��o
				Loop
			ElseIf cHoraFim > aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Final da exce��o � maior que o final do calend�rio padr�o, registra como hora normal at� o t�rmino do calend�rio padr�o
				addTempo(aHoras, cHoraIni, aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM], HORA_DISPONIVEL, .F.)

				//Ir� reprocessar esta exce��o, mas considerando que o in�cio dela � o fim do calend�rio padr�o
				aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI] := aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]

				nIndPad++ //Incrementa �ndice do calend�rio padr�o para verificar o pr�ximo hor�rio
				nIndex-- //Decrementa �ndice do calend�rio de exce��o para avaliar novamente com o pr�ximo hor�rio do calend�rio padr�o.
				Loop
			EndIf
		EndIf

	Next nIndex

	//Percorre o restante do calend�rio padr�o caso n�o tenha processado todos os hor�rios
	For nIndex := nIndPad To nTotPad
		//Registra o tempo do calend�rio como parada
		addTempo(aHoras                                               ,;
		         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI],;
		         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM],;
		         HORA_PARADA                                          ,;
		         .F.                                                   )
	Next nIndex

Return aHoras

/*/{Protheus.doc} validaBloqueios
Valida os dados das horas geradas, se est�o dentro de um bloqueio do recurso.

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 aHoras   , Array, Array com as horas que ser�o gravadas na SMK. Retorna por refer�ncia dados atualizados.
@param 02 aTotais  , Array, Array com totais de horas extras, paradas e bloqueadas. Retorna por refer�ncia dados atualizados.
@param 03 aBloqueio, Array, Array com os hor�rios de bloqueio
@return Nil
/*/
Method validaBloqueios(aHoras, aTotais, aBloqueio) CLASS PCPA152Disponibilidade

	Local cHoraFim := ""
	Local cHoraIni := ""
	Local lOrdena  := .F.
	Local nIndex   := 1
	Local nIndBloq := 0
	Local nTotal   := 0
	Local nTotBloq := 0

	If Empty(aBloqueio)
		Return
	EndIf

	nTotBloq := Len(aBloqueio[CALEND_POS_HORAS])
	For nIndBloq := 1 To nTotBloq

		nTotal   := Len(aHoras)
		cHoraIni := aBloqueio[CALEND_POS_HORAS][nIndBloq][CALEND_POS_HORAINI]
		cHoraFim := aBloqueio[CALEND_POS_HORAS][nIndBloq][CALEND_POS_HORAFIM]

		For nIndex := 1 To nTotal
			//Se ja � uma hora bloqueada, desconsidera
			If aHoras[nIndex][4] == .T.
				Loop
			EndIf

			//Se o in�cio da hora � maior que o final do bloqueio, n�o precisa analisar o restante das horas
			//pois estar�o todas fora do bloqueio.
			If aHoras[nIndex][1] > cHoraFim
				Exit
			EndIf

			//Hora do calend�rio est� dentro do bloqueio, registra como hora bloqueada
			If aHoras[nIndex][1] >= cHoraIni .And. aHoras[nIndex][2] <= cHoraFim
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])
				EndIf
				aHoras[nIndex][4] := .T.
				Loop
			EndIf

			//Hora do calend�rio inicia antes do bloqueio, e termina durante o bloqueio. Faz a quebra do hor�rio para registrar o bloqueio.
			If aHoras[nIndex][1] < cHoraIni .And. aHoras[nIndex][2] > cHoraIni .And. aHoras[nIndex][2] <= cHoraFim
				//Adiciona novo hor�rio para registrar o bloqueio, da hora inicial do bloqueio at� a hora final do hor�rio
				addTempo(aHoras, cHoraIni, aHoras[nIndex][2], aHoras[nIndex][3], .T.)

				//Soma totais de horas bloqueadas
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(cHoraIni, aHoras[nIndex][2])
				EndIf

				//Este hor�rio do calend�rio ser� alterado para ter como hora final a hora de in�cio do bloqueio
				aHoras[nIndex][2] := cHoraIni

				lOrdena := .T.
				Loop
			EndIf

			//Hora do calend�rio inicia durante o bloqueio e encerra ap�s do t�rmino do bloqueio.
			If aHoras[nIndex][1] >= cHoraIni .And.;
				aHoras[nIndex][1] < cHoraFim .And.;
				aHoras[nIndex][2] > cHoraIni .And.;
				aHoras[nIndex][2] > cHoraFim

				//Gera novo hor�rio somente com o per�odo ap�s o t�rmino do bloqueio
				addTempo(aHoras, cHoraFim, aHoras[nIndex][2], aHoras[nIndex][3], .F.)
				//Atualiza este hor�rio para hora bloqueada
				aHoras[nIndex][2] := cHoraFim
				aHoras[nIndex][4] := .T.

				//Soma totais de horas bloqueadas
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])
				EndIf

				lOrdena := .T.
				Loop
			EndIf

			//Hora do calend�rio inicia antes do bloqueio, e termina ap�s o t�rmino do bloqueio.
			If aHoras[nIndex][1] <= cHoraIni .And. aHoras[nIndex][2] >= cHoraFim
				//Verifica se deve quebrar hora inicio para registrar o bloqueio
				If aHoras[nIndex][1] < cHoraIni
					//Hor�rio do in�cio do calend�rio at� in�cio do bloqueio ser� quebrado para registrar o bloqueio.
					addTempo(aHoras, aHoras[nIndex][1], cHoraIni, aHoras[nIndex][3], aHoras[nIndex][4])
				EndIf
				If aHoras[nIndex][2] > cHoraFim
					//Hor�rio do final do bloqueio at� final do calend�rio par�o ser� quebrado para registrar o bloqueio
					addTempo(aHoras, cHoraFim, aHoras[nIndex][2], aHoras[nIndex][3], aHoras[nIndex][4])
				EndIf

				//Soma totais de horas bloqueadas
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(cHoraIni, cHoraFim)
				EndIf

				//Marca o hor�rio atual como bloqueado e atualiza hor�rio
				aHoras[nIndex][1] := cHoraIni
				aHoras[nIndex][2] := cHoraFim
				aHoras[nIndex][4] := .T.

				lOrdena := .T.
				Loop
			EndIf

		Next nIndex
		If lOrdena
			//Se adicionou novos hor�rios, ordena o array para criar os registros com a sequencia ordenada
			aSort(aHoras,,,{|x,y| x[1] < y[1]})
		EndIf
	Next nIndBloq

Return

/*/{Protheus.doc} carregaCalendario
Busca os dados de um calend�rio

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cCalend, Caracter, C�digo do calend�rio
@return Nil
/*/
Method carregaCalendario(cCalend) CLASS PCPA152Disponibilidade
	Local cAlocDia := ""
	Local nIndDia  := 0
	Local nIndCal  := 0
	Local nPosIni  := 0
	Local nTamanho := 0

	If Self:oCalend:HasProperty(cCalend)
		Return
	EndIf

	Self:oCalend[cCalend] := Array(7) //Cada posi��o do array ser� um dia da semana, iniciando no domingo.

	SH7->(dbSetOrder(1))
	If SH7->(dbSeek(xFilial("SH7") + cCalend))
		//Posi��o inicial do H7_ALOC para buscar as horas.
		nPosIni  := 1
		//Tamanho do H7_ALOC que representa 1 dia.
		nTamanho := Self:oParDisp["MV_PRECISA"] * 24
		//Divide o conte�do de H7_ALOC no conte�do de cada dia da semana.
		For nIndDia := 1 To 7
			//Valor de H7_ALOC inicia na segunda.
			//Utiliza o nIndCal para que nos dados do calend�rio o primeiro dia seja o Domingo.
			nIndCal := nIndDia + 1
			If nIndCal > 7
				nIndCal := 1
			EndIf
			//Extrai somente a aloca��o de 1 dia do campo H7_ALOC
			cAlocDia := SubStr(SH7->H7_ALOC, nPosIni, nTamanho)
			Self:oCalend[cCalend][nIndCal] := Self:converteHorasCalendario(cAlocDia)

			//Soma o tamanho na posi��o inicial para pegar o pr�ximo dia de H7_ALOC
			nPosIni += nTamanho
		Next nIndDia
	EndIf

Return

/*/{Protheus.doc} carregaBloqueioRecurso
Busca os dados de bloqueios de recurso no per�odo

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cRecurso  , Caracter, C�digo do recurso
@param 02 cCentCusto, Caracter, C�digo do centro de custo vinculado ao recurso
@return Nil
/*/
Method carregaBloqueioRecurso(cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local cAlias   := ""
	Local cDataIni := ""
	Local cDataFim := ""
	Local cData    := ""
	Local cChave   := ""
	Local cHrIni   := ""
	Local cHrFim   := ""
	Local cQuery   := ""
	Local dData    := Nil
	Local dDataFim := Nil
	Local nTotal   := 0

	Self:oBlockRec := JsonObject():New()

	If Self:oQryBlock == Nil
		cDataIni := DtoS(Self:oParDisp["dataInicial"])
		cDataFim := DtoS(Self:oParDisp["dataFinal"])

		cQuery := "SELECT SH9.H9_RECURSO, SH9.H9_CCUSTO, SH9.H9_DTINI, SH9.H9_DTFIM, SH9.H9_HRINI, SH9.H9_HRFIM"
		cQuery +=  " FROM " + RetSqlName("SH9") + " SH9"
		cQuery += " WHERE SH9.H9_FILIAL  = ?"
		cQuery +=   " AND SH9.H9_TIPO    = ?"
		cQuery +=   " AND SH9.D_E_L_E_T_ = ?"
		cQuery +=   " AND (SH9.H9_DTINI BETWEEN ? AND ?"
		cQuery +=    " OR  SH9.H9_DTFIM BETWEEN ? AND ?)"
		cQuery +=   " AND ((SH9.H9_RECURSO = ? OR SH9.H9_RECURSO = ?)"
		cQuery +=   " AND  (SH9.H9_CCUSTO  = ? OR SH9.H9_CCUSTO  = ?))"
		cQuery += " ORDER BY SH9.H9_DTINI, SH9.H9_HRINI"
		Self:oQryBlock := FwExecStatement():New(cQuery)

		Self:oQryBlock:SetFields({"H9_RECURSO"           ,;
		                          "H9_CCUSTO"            ,;
		                          {"H9_DTINI", "D", 8, 0},;
		                          {"H9_DTFIM", "D", 8, 0},;
		                          "H9_HRINI"             ,;
		                          "H9_HRFIM"             })

		Self:oQryBlock:SetString(1, xFilial("SH9")) //H9_FILIAL
		Self:oQryBlock:SetString(2, 'B') //H9_TIPO
		Self:oQryBlock:SetString(3, ' ') //D_E_L_E_T_
		Self:oQryBlock:SetString(4, cDataIni) //H9_DTINI
		Self:oQryBlock:SetString(5, cDataFim) //H9_DTINI
		Self:oQryBlock:SetString(6, cDataIni) //H9_DTFIM
		Self:oQryBlock:SetString(7, cDataFim) //H9_DTFIM
		Self:oQryBlock:SetString(8, ' ') //H9_RECURSO = ' '
		Self:oQryBlock:SetString(10, ' ') //H9_CCUSTO = ' '
	EndIf

	Self:oQryBlock:SetString(9, cRecurso) //H9_RECURSO = 'recurso'
	Self:oQryBlock:SetString(11, cCentCusto) //H9_CCUSTO = 'ccusto'

	cAlias := Self:oQryBlock:OpenAlias()
	Self:oQryBlock:doTcSetField(cAlias)

	While (cAlias)->(!Eof())

		dData    := Max(Self:oParDisp["dataInicial"], (cAlias)->(H9_DTINI))
		dDataFim := Min(Self:oParDisp["dataFinal"  ], (cAlias)->(H9_DTFIM))

		While dData <= dDataFim
			cData  := DtoS(dData)
			cChave := Self:chaveExcecao(cData, (cAlias)->(H9_RECURSO), (cAlias)->(H9_CCUSTO))

			If !Self:oBlockRec:HasProperty(cChave)
				Self:oBlockRec[cChave] := {{}, 0}
			EndIf

			cHrIni := "00:00"
			cHrFim := "24:00"

			If dData == (cAlias)->(H9_DTINI)
				cHrIni := (cAlias)->(H9_HRINI)
			EndIf
			If dData == (cAlias)->(H9_DTFIM)
				cHrFim := (cAlias)->(H9_HRFIM)
			EndIf
			nTotal := Self:totalDeMinutos(cHrIni, cHrFim)

			Self:oBlockRec[cChave][2] += nTotal
			aAdd(Self:oBlockRec[cChave][1], {cHrIni, cHrFim, nTotal} )

			dData++
		End

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} carregaExcecaoCalendario
Busca os dados de exce��es de calend�rio no per�odo

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cRecurso  , Caracter, C�digo do recurso
@param 02 cCentCusto, Caracter, C�digo do centro de custo vinculado ao recurso
@return Nil
/*/
Method carregaExcecaoCalendario(cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local cAlias   := GetNextAlias()
	Local cChave   := ""
	Local cDataIni := Self:oParDisp["dataInicial"]
	Local cDataFim := Self:oParDisp["dataFinal"]

	Self:oExcCalend := JsonObject():New()

	BeginSql Alias cAlias
		%noParser%
		SELECT SH9.H9_RECURSO, SH9.H9_CCUSTO, SH9.H9_DTINI, SH9.H9_ALOC
		  FROM %Table:SH9% SH9
		 WHERE SH9.H9_FILIAL = %xFilial:SH9%
		   AND SH9.H9_TIPO   = 'E'
		   AND SH9.H9_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
		   AND ((SH9.H9_RECURSO = %Exp:cRecurso%   OR SH9.H9_RECURSO = ' ')
		    AND (SH9.H9_CCUSTO  = %Exp:cCentCusto% OR SH9.H9_CCUSTO  = ' ') )
		   AND SH9.%NotDel%
	EndSql

	While (cAlias)->(!Eof())

		cChave := Self:chaveExcecao((cAlias)->(H9_DTINI), (cAlias)->(H9_RECURSO), (cAlias)->(H9_CCUSTO))

		Self:oExcCalend[cChave] := Self:converteHorasCalendario((cAlias)->(H9_ALOC))

		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} converteHorasCalendario
Converte as horas de um dia do calend�rio (SH7) em um array com as horas dispon�veis

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cAloc, Caracter, Aloca��o do dia cadastrado na SH7
@return aHoras, Array, Array com as horas dispon�veis
/*/
Method converteHorasCalendario(cAloc) CLASS PCPA152Disponibilidade
	Local aHoras    := {}
	Local cHoraIni  := ""
	Local cHoraFim  := ""
	Local nMinutos  := 0
	Local nInicio	:= 0
	Local nFim		:= 0
	Local nInd		:= 0
	Local nHoraIni  := 0
	Local nTotal    := 0

	//Primeiro hor�rio dispon�vel
	nInicio	:=  AT("X", cAloc)
	//�ltimo hor�rio dispon�vel
	nFim	:= RAT("X", cAloc)

	If nInicio > 0 .And. nFim > 0 //Se existe algum hor�rio selecionado
		nHoraIni := nInicio -1
		//Percorre a string buscando hor�rios que n�o est�o marcados para gerar as quebras entre in�cio/fim
		For nInd := nInicio To nFim
			If nHoraIni == -1 .And. SubStr(cAloc, nInd, 1) <> " "
				//Reinicia o nHoraIni com a sele��o encontrada
				nHoraIni := nInd -1
			EndIf
			If nHoraIni <> -1 .And. (SubStr(cAloc, nInd, 1) == " " .Or. nInd == nFim)
				//Chegou no final da string ou encontrou uma pausa na sele��o de horas
				//Converte as horas iniciais/finais de acordo com as posi��es encontradas na aloca��o
				cHoraIni := Self:horaPosicionada(nHoraIni)
				If nInd == nFim
					cHoraFim := Self:horaPosicionada(nFim)
				Else
					cHoraFim := Self:horaPosicionada(nInd-1)
				EndIf
				nTotal   := Self:totalDeMinutos(cHoraIni, cHoraFim)
				nMinutos += nTotal
				aAdd(aHoras, {cHoraIni, cHoraFim, nTotal})
				//Define nHoraIni = -1 para reiniciar a contagem da hora inicial ap�s uma pausa na sele��o
				nHoraIni := -1
			EndIf
		Next nInd
	EndIf

Return {aHoras, nMinutos}

/*/{Protheus.doc} horaPosicionada
Converte uma posi��o da aloca��o (SH7) em um hor�rio

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 nPosicao, Number, Posi��o da aloca��o para converter em hora
@return cHora, Caracter, Hora convertida
/*/
Method horaPosicionada(nPosicao) CLASS PCPA152Disponibilidade
	Local cHora     := ""
	Local nHora		:= 0
	Local nMinuto	:= 0
	Local nPrecisa  := Self:oParDisp["MV_PRECISA"]

	nHora	:= Int(nPosicao / nPrecisa)
	nMinuto	:= Mod(nPosicao, nPrecisa ) * (60 / nPrecisa)

	cHora := PadL( cValToChar(nHora), 2, "0" ) + ":" + PadL( cValToChar(nMinuto), 2, "0" )
Return cHora

/*/{Protheus.doc} addTempo
Adiciona no array de horas um novo hor�rio

@type  Static Function
@author lucas.franca
@since 07/02/2023
@version P12
@param 01 aHoras    , Array   , Array para adicionar as horas
@param 02 cHoraIni  , Caracter, Hora Inicial
@param 03 cHoraFim  , Caracter, Hora final
@param 04 cTipo     , Caracter, Tipo da hora
@param 05 lBloqueado, Logico  , Identifica se a hora est� dentro de um bloqueio
@return Nil
/*/
Static Function addTempo(aHoras, cHoraIni, cHoraFim, cTipo, lBloqueado)
	Local aHora := Array(4)

	aHora[1] := cHoraIni
	aHora[2] := cHoraFim
	aHora[3] := cTipo
	aHora[4] := lBloqueado

	aAdd(aHoras, aHora)
Return

/*/{Protheus.doc} buscaHorasRecurso
Busca as horas de um recurso com base no seu calend�rio, para o per�odo de datas informado

@author lucas.franca
@since 13/02/2023
@version P12
@param 01 cRecurso, Caracter, C�digo do recurso
@param 02 dDataIni, Date    , Data inicial
@param 03 dDataFim, Date    , Data final
@return oHoras, JsonObject, Json com os dados de horas do recurso
/*/
Method buscaHorasRecurso(cRecurso, dDataIni, dDataFim) CLASS PCPA152Disponibilidade
	Local aRegs     := {}
	Local nIndex    := 0
	Local nTotal    := 0
	Local nTotHoras := 0
	Local oHoras    := JsonObject():New()
	Local oDisp     := PCPA152Disponibilidade():New()

	oHoras["datas"     ] := JsonObject():New()
	oHoras["totalHoras"] := "00:00"

	//Grava os par�metros que ser�o utilizados no processamento
	oDisp:defineParametro("cProg"      , "")
	oDisp:defineParametro("dataInicial", dDataIni)
	oDisp:defineParametro("dataFinal"  , dDataFim)
	oDisp:defineParametro("MV_PRECISA" , GetMv("MV_PRECISA"))

	SH1->(dbSetOrder(1))
	If SH1->(dbSeek(xFilial("SH1") + PadR(cRecurso, Len(SH1->H1_CODIGO))))
		aRegs  := oDisp:calculaDispRecurso(SH1->H1_CODIGO, SH1->H1_CALEND, SH1->H1_CCUSTO, SH1->H1_ILIMITA)
		nTotal := Len(aRegs)

		For nIndex := 1 To nTotal
			oHoras["datas"][DtoS(aRegs[nIndex][ARRAY_MR_DATDISP])] := __Min2Hrs(aRegs[nIndex][ARRAY_MR_TEMPOTO], .T.)
			nTotHoras += aRegs[nIndex][ARRAY_MR_TEMPOTO]
		Next nIndex
		oHoras["totalHoras"] := __Min2Hrs(nTotHoras, .T.)

		aSize(aRegs, 0)
	EndIf

	oDisp:Destroy()
Return oHoras

/*/{Protheus.doc} descricaoTipoHora
Retorna a descri��o do tipo de hora registrando na SMK (MK_TIPO)

@author lucas.franca
@since 01/03/2023
@version P12
@param 01 cTipo, Caracter, Valor de MK_TIPO para retornar a descri��o
@return cDesc, Caracter, Descri��o do conte�do da coluna MK_TIPO
/*/
Method descricaoTipoHora(cTipo) CLASS PCPA152Disponibilidade
	Local cDesc := cTipo

	Do Case
		Case cTipo == HORA_DISPONIVEL
			cDesc := STR0089 //"Dispon�vel"
		Case cTipo == HORA_PARADA
			cDesc := STR0090 //"Parada"
		Case cTipo == HORA_EXTRA
			cDesc := STR0091 //"Extra"

	EndCase
Return cDesc

/*/{Protheus.doc} P152CalDis
Faz o c�lculo da disponibilidade para um recurso

@author marcelo.neumann
@since 02/03/2023
@version P12
@param 01 cProg     , Caracter, N�mero da programa��o
@param 02 cRecurso  , Caracter, C�digo do recurso
@param 03 cCalend   , Caracter, C�digo do calend�rio vinculado ao recurso
@param 04 cCentCusto, Caracter, C�digo do centro de custo vinculado ao recurso
@param 05 cRecIlimi , Caracter, Indicador se o recurso � ilimitado
@return Nil
/*/
Function P152CalDis(cProg, cRecurso, cCalend, cCentCusto, cRecIlimi)
	Local oDisp     := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_DISP, @oDisp)
		oDisp:calculaDispRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi)
	EndIf

Return

/*/{Protheus.doc} processaRecursos
Processa a disponibilidade dos recursos

@author Marcelo Neumann
@since 14/03/2023
@version P12
@return lOk, L�gico, Inidica se processou com sucesso a etapa
/*/
Method processaRecursos() Class PCPA152Disponibilidade
	Local aQuery     := Self:retornaQueryRecursos()
	Local cAlias     := GetNextAlias()
	Local lOk        := .T.
	Local nIndex     := 1
	Local nPercentua := 0
	Local nQtdProc   := 0
	Local nTotRecur  := 0

	BeginSql Alias cAlias
		SELECT Count(cont.H1_CODIGO) TOTAL
		FROM (SELECT %Exp:aQuery[1]%
		        FROM %Exp:aQuery[2]%
		       WHERE %Exp:aQuery[3]%
		       GROUP BY %Exp:aQuery[4]%) cont
	EndSql

	If (cAlias)->(!Eof())
		nTotRecur := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

	BeginSql Alias cAlias
		SELECT %Exp:aQuery[1]%
		  FROM %Exp:aQuery[2]%
		 WHERE %Exp:aQuery[3]%
		 GROUP BY %Exp:aQuery[4]%
	EndSql

	Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_TOTAL"      , nTotRecur*1.1) //Acrescenta 10% no total para n�o fechar 100% antes de gravar
	Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_PROCESSADOS", 0)

	nIndex := 0
	While (cAlias)->(!Eof())
		Self:oProcesso:delegar("P152CalDis", Self:oParDisp["cProg"], (cAlias)->H1_CODIGO, (cAlias)->H1_CALEND, (cAlias)->H1_CCUSTO, (cAlias)->H1_ILIMITA)

		If nIndex == 5
			If !Self:oProcesso:permiteProsseguir()
				lOk := .F.
				Exit
			EndIf

			If !Self:processandoRecursos(nTotRecur, @nQtdProc)
				Exit
			EndIf

			nPercentua := (nQtdProc * 100) / nTotRecur
			Self:oProcesso:gravaPercentual(CHAR_ETAPAS_CALC_DISP, nPercentua)
			nIndex := 0
		Else
			nIndex++
		EndIf
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	//Aguarda t�rmino do processamento
	nIndex := 0
	While lOk .And. Self:processandoRecursos(nTotRecur, @nQtdProc)
		Sleep(500)
		If nIndex == 5
			nPercentua := (nQtdProc * 100) / nTotRecur
			Self:oProcesso:gravaPercentual(CHAR_ETAPAS_CALC_DISP, nPercentua)
			nIndex := 0
		Else
			nIndex++
		EndIF

		lOk := Self:oProcesso:permiteProsseguir()
	End

	If lOk .And. !Self:gerouDisponibilidade()
		Self:oProcesso:gravaErro(CHAR_ETAPAS_CALC_DISP, STR0190, "") // "Nenhuma disponibilidade foi gerada!"
		lOk := .F.
	EndIf

	If lOk
		If nQtdProc <> Nil
			nPercentua := (nQtdProc * 100) / nTotRecur
			Self:oProcesso:gravaPercentual(CHAR_ETAPAS_CALC_DISP, nPercentua)
		EndIf

		lOk := Self:gravaTabelasDisponibilidade()
	EndIf

	aSize(aQuery, 0)
Return lOk

/*/{Protheus.doc} processandoRecursos
Indica se ainda est� processando os recursos ou se j� processou todos

@author Marcelo Neumann
@since 07/03/2023
@version P12
@param 01 nTotRecur, Num�rico, Total de Recursos que est�o sendo processados
@param 02 nQtdProc , Num�rico, Quantidade de recursos j� processados
@return lInProcess, L�gico  , Indica que ainda est� em processamento
/*/
Method processandoRecursos(nTotRecur, nQtdProc) Class PCPA152Disponibilidade
	Local lError     := .F.
	Local lInProcess := .T.

	nQtdProc := Self:oProcesso:retornaValorGlobal("DISPONIBILIDADE_PROCESSADOS", @lError)
	If lError .Or. nQtdProc == Nil .Or. nTotRecur == nQtdProc
		lInProcess := .F.
	EndIf

Return lInProcess

/*/{Protheus.doc} carregaDisponibilidade
Realiza a carga da disponibilidade para a mem�ria quando processar uma programa��o com a disponibilidade gerada.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@return Nil
/*/
Method carregaDisponibilidade() Class PCPA152Disponibilidade
	Local aRegs     := {}
	Local aPeriodo  := {}
	Local cAlias    := ""
	Local cRecurso  := ""
	Local cQuery    := ""
	Local oQryBlock := Nil

	cQuery := " SELECT SMR.MR_RECURSO, "
	cQuery +=        " SMK.MK_DATDISP, "
	cQuery +=        " SMK.MK_HRINI  , "
	cQuery +=        " SMK.MK_HRFIM    "
	cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
	cQuery +=  " INNER JOIN " + RetSqlName("SMK") + " SMK "
	cQuery +=     " ON SMK.MK_PROG    = SMR.MR_PROG "
	cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP "
	cQuery +=    " AND SMK.MK_FILIAL  =  ?  "
	cQuery +=    " AND SMK.MK_BLOQUE  =  ?  "
	cQuery +=    " AND SMK.MK_TIPO   IN (?) "
	cQuery +=    " AND SMK.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMR.MR_FILIAL  =  ?  "
	cQuery +=    " AND SMR.MR_PROG    =  ?  "
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY SMR.MR_RECURSO, SMK.MK_DATDISP, SMK.MK_HRINI "

	oQryBlock := FwExecStatement():New()
	oQryBlock:setQuery(cQuery)

	oQryBlock:SetFields({"MR_RECURSO"             ,;
	                    {"MK_DATDISP", "D", 8, 0} ,;
	                     "MK_HRINI"               ,;
	                     "MK_HRFIM"               })

	oQryBlock:setString(1, Self:cFilSMK      ) // MK_FILIAL
	oQryBlock:setString(2, HORA_NAO_BLOQUEADA) // MK_BLOQUE
	oQryBlock:setIn(3, {HORA_DISPONIVEL, HORA_EXTRA}) // MK_TIPO
	oQryBlock:setString(4, Self:cFilSMR          ) // MR_FILIAL
	oQryBlock:setString(5, Self:oParDisp["cProg"]) // MR_PROG

	cAlias := oQryBlock:OpenAlias()
	oQryBlock:doTcSetField(cAlias)

	While (cAlias)->(!EoF())
		cRecurso := (cAlias)->MR_RECURSO
		aPeriodo := Array(ARRAY_DISP_RECURSO_TAMANHO)

		aPeriodo[ARRAY_DISP_RECURSO_DATA       ] := (cAlias)->MK_DATDISP
		aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO] := __Hrs2Min((cAlias)->MK_HRINI)
		aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM   ] := __Hrs2Min((cAlias)->MK_HRFIM)
		aPeriodo[ARRAY_DISP_RECURSO_TEMPO      ] := aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM] - aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO]

		aAdd(aRegs, aPeriodo)

		(cAlias)->(dbSkip())
		If (cAlias)->MR_RECURSO != cRecurso
			Self:oProcesso:adicionaListaGlobal("DISPONIBILIDADE_RECURSOS", cRecurso, aRegs, .F.)

			FwFreeArray(aRegs)
			aRegs := {}
		EndIf
	End
	(cAlias)->(dbCloseArea())

	oQryBlock:Destroy()
Return Nil

/*/{Protheus.doc} getDisponibilidadeRecurso
Retorna a disponibilidade de um recurso.
(retorna os hor�rios em minutos, usar a fun��o __Min2Hrs(nMinutos, lString) para converter)

@author Lucas Fagundes
@since 04/04/2023
@version P12
@param cRecurso, Caracter, Codigo do recurso que ir� buscar a disponibilidade.
@return aDispRec, Array, Array com os periodos de disponibilidade do recurso, no formato: aDispRec[x][1] = Data
                                                                                          aDispRec[x][2] = Hora inicio
                                                                                          aDispRec[x][3] = Hora fim
                                                                                          aDispRec[x][4] = Tempo total do periodo
/*/
Method getDisponibilidadeRecurso(cRecurso) Class PCPA152Disponibilidade
	Local aDispRec := {}

	aDispRec := Self:oProcesso:retornaListaGlobal("DISPONIBILIDADE_RECURSOS", cRecurso)

Return aDispRec

/*/{Protheus.doc} gerouDisponibilidade
Verifica se gerou algum registro de disponibilidade.
@author Lucas Fagundes
@since 16/05/2023
@version P12
@return lGerou, Logico, Indica se gerou disponibilidade.
/*/
Method gerouDisponibilidade() Class PCPA152Disponibilidade

Return Len(Self:oProcesso:retornaListaGlobal("DADOS_SMR")) > 0

/*/{Protheus.doc} retornaQueryRecursos
Retorna as instru��es SQL para a query de processamento de recursos.
@author Lucas Fagundes
@since 06/06/2023
@version P12
@return aQuery, Array, Array com os instru��es SQL para query de recursos.
/*/
Method retornaQueryRecursos() Class PCPA152Disponibilidade
	Local aQuery     := Array(4)
	Local cCampos    := ""
	Local cFrom      := ""
	Local cGroup     := ""
	Local cWhere     := ""
	Local lFiltraCT  := !Empty(Self:oParDisp["centroTrabalho"])
	Local lFiltraRec := !Empty(Self:oParDisp["recursos"])

	cCampos := /*SELECT*/" SH1.H1_CODIGO, "
	cCampos +=           " SH1.H1_CALEND, "
	cCampos +=           " SH1.H1_CCUSTO, "
	cCampos +=           " SH1.H1_ILIMITA "

	cFrom += /*FROM*/RetSqlName("SH1") + " SH1 "

	If lFiltraCT
		cFrom += " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
		cFrom +=    " ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
		cFrom +=   " AND SG2.G2_RECURSO = SH1.H1_CODIGO "
		cFrom +=   " AND SG2.D_E_L_E_T_ = ' ' "
		cFrom +=   " AND SG2.G2_CTRAB  != ' ' "
	EndIf

	cWhere := /*WHERE*/" SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cWhere +=      " AND SH1.D_E_L_E_T_ = ' ' "

	If lFiltraCT
		cWhere +=   " AND ( "
		cWhere +=       " (SG2.G2_CTRAB IN " + filInPar(Self:oParDisp["centroTrabalho"], .F.) + " ) OR "
		cWhere +=       " (SG2.G2_CTRAB IS NULL AND SH1.H1_CTRAB IN " + filInPar(Self:oParDisp["centroTrabalho"], .T.) + " ) "
		cWhere +=   " ) "
	EndIf

	If lFiltraRec
		cWhere += " AND SH1.H1_CODIGO IN " + filInPar(Self:oParDisp["recursos"], .F.)
	EndIf

	cGroup := /*GROUP BY*/ " H1_CODIGO, H1_CALEND, H1_CCUSTO, H1_ILIMITA "

	aQuery[1] := "%" + cCampos + "%"
	aQuery[2] := "%" + cFrom   + "%"
	aQuery[3] := "%" + cWhere  + "%"
	aQuery[4] := "%" + cGroup  + "%"

Return aQuery

/*/{Protheus.doc} filInPar
Monta a condi��o IN para os filtros da query.
@type  Static Function
@author Lucas Fagundes
@since 06/06/2023
@version P12
@param 01 aFiltro, Array , Array com os itens que ser�o adicionados na condi��o.
@parma 02 lBranco, Logico, Indica que deve adicionar valores em branco.
@return cFiltro, Caracter, Condi��o IN para a query.
/*/
Static Function filInPar(aFiltro, lBranco)
	Local cFiltro := ""
	Local nIndex  := 0
	Local nTotal  := Len(aFiltro)

	cFiltro := " ("
	For nIndex := 1 To nTotal
		If Empty(aFiltro[nIndex])
			If lBranco
				cFiltro += "' '"
			Else
				Loop
			EndIf
		Else
			cFiltro += "'" + aFiltro[nIndex] + "'"
		EndIf

		If nIndex < nTotal
			cFiltro += ", "
		EndIf
	Next
	cFiltro += ") "

Return cFiltro
