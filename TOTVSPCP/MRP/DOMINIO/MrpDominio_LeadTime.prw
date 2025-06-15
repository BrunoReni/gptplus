#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE IND_HORA   '1'
#DEFINE IND_DIA    '2'
#DEFINE IND_SEMANA '3'
#DEFINE IND_MES    '4'
#DEFINE IND_ANO    '5'

/*/{Protheus.doc} MrpDominio_LeadTime
Regras de negocio MRP - Lead Time
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDominio_LeadTime FROM LongClassName

	DATA oDominio  AS OBJECT

	METHOD new() CONSTRUCTOR
	METHOD aplicar(cFilAux, cProduto, nPeriodo, dLeadTime, lAjusta, lTransfer, dLTReal)
	METHOD calcLeadTime(cFilAux, aRetPrazo, dLeadTime, lError)
	METHOD buscaUtilAnterior(cFilAux, dData)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oDominio, numero  , objeto da camada de dominio
/*/
METHOD new(oDominio) CLASS MrpDominio_LeadTime
	Self:oDominio  := oDominio
Return Self

/*/{Protheus.doc} aplicar
Aplica o lead time do produto
@author    marcelo.neumann
@since     07/06/2019
@version   1
@param 01 - cFilAux  , caracter, c�digo da filial
@param 02 - cProduto , caracter, chave do produto para aplicar o lead time (filial+produto)
@param 03 - nPeriodo , numero  , periodo atual do produto - retornado por referencia
@param 04 - dLeadTime, data    , data atual do produto    - retornado por referencia considerando calend�rio
@param 05 - lAjusta  , l�gico  , indica se deve ajustar a dLeadTime para um per�odo do MRP ou n�o
@param 06 - lTransfer, l�gico  , indica se calcula lead time de transfer�ncia.
@param 07 - dLTReal  , data    , retorna por refer�ncia a data real ap�s aplicar o leadtime, sem considerar o par�metro lAjusta.
@return lReturn, logico, indica se houve erro na aplica��o do lead time
/*/
METHOD aplicar(cFilAux, cProduto, nPeriodo, dLeadTime, lAjusta, lTransfer, dLTReal) CLASS MrpDominio_LeadTime

	Local aRetPrazo  := {}
	Local cCmpPrazo  := "PRD_PE"
	Local lError     := .F.
	Local lReturn    := .T.

	Default lAjusta   := .T.
	Default lTransfer := .F.

	If lTransfer
		cCmpPrazo := "PRD_LTTRAN"
	EndIf

	dLTReal := dLeadTime

	//Busca o Prazo de Entrega e o Tipo para calcular o lead time
	aRetPrazo := ::oDominio:oDados:retornaCampo("PRD", 1, cProduto, {cCmpPrazo, "PRD_TIPE"}, @lError, , , , , , .T. /*lVarios*/)

	If lError
		::oDominio:oDados:oLogs:log(STR0101 + AllTrim(cProduto), "EL") //"Problema ao buscar o prazo de entrega do produto: "
		Return .F.
	EndIf

	//Se n�o foi informado o Prazo do produto, n�o calcula
	If aRetPrazo[1] == NIL .Or. aRetPrazo[1] == 0
		Return .T.
	EndIf

	//Transforma o prazo em dias
	If aRetPrazo[2] == IND_MES
		aRetPrazo[1] *= 30

	ElseIf aRetPrazo[2] == IND_SEMANA
		aRetPrazo[1] *= 7

	ElseIf aRetPrazo[2] == IND_ANO
		aRetPrazo[1] *= 365
	EndIf

	::calcLeadTime(cFilAux, aRetPrazo, @dLeadTime, @lError)

	If lError
		lReturn  := .F.
		nPeriodo := 0
		::oDominio:oDados:oLogs:log(STR0098 + AllTrim(cProduto) + ". " + ;   //"Nao foi possivel calcular o lead time do produto "
									STR0099 + DToC(dLeadTime) + STR0100, "EL") //"Data " XX/XX/XX " nao encontrada no calendario do MRP."
	Else
		dLTReal  := dLeadTime
		nPeriodo := ::oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)
	EndIf

	//Caso chegue � uma data que n�o est� dentro do per�odo de processamento, usa o primeiro per�odo
	If nPeriodo <= 0
		nPeriodo := 1
	EndIf

	If lAjusta
		dLeadTime := ::oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
	EndIf

Return lReturn

/*/{Protheus.doc} calcLeadTime
Calcula o lead time do produto
@author    douglas.heydt
@since     19/08/2019
@version   1
@param 01 - cFilAux     , caracter, c�digo da filial
@param 02 - aRetPrazo 	, Array	  , Array contendo o lead time do produto, e em que medida est� expresso
@param 03 - dLeadTime  	, data	  , data atual do produto, retornado por referencia considerando calend�rio
@param 04 - lError 		, logico  , informa a ocorr�ncia de erros no processo
/*/
METHOD calcLeadTime(cFilAux, aRetPrazo, dLeadTime, lError) CLASS MrpDominio_LeadTime

	Local cHoraDia
	Local dPrimData := Nil
	Local nPosPeri
	Local nSub
	Local nSaldoMinu
	Local nIndex
	Local nMinutDia
	Local nCont    := 1
	Local oDominio := Self:oDominio

	If oDominio:oParametros["nLeadTime"] == 1 //N�o considera o calend�rio
		If aRetPrazo[2] == IND_HORA
			If MOD(aRetPrazo[1],24) > 0
				nSub := Int(aRetPrazo[1]/24) +1
			Else
				nSub := Int(aRetPrazo[1]/24)
			EndIf
			dLeadTime   := DaySub(dLeadTime, (nSub-1)) //O dia da demanda deve ser utilizado
		Else
			dLeadTime   := DaySub(dLeadTime,aRetPrazo[1])
		EndIf

	ElseIf oDominio:oParametros["nLeadTime"] == 2 //Dias Corridos (considera calend�rio)

		If aRetPrazo[2] == IND_HORA
			nSaldoMinu := Hrs2Min(cValToChar(aRetPrazo[1])+":00")
			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			For nIndex := nPosPeri To 1 Step -1
				cHoraDia := oDominio:oDados:retornaCampo("CAL", 1, cFilAux + DToS(oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)), "CAL_UTEIS", @lError)
				nMinutDia := Hrs2Min(cValToChar(cHoraDia))
				nSaldoMinu -= nMinutDia

				If nSaldoMinu <= 0
					dLeadTime := oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)
					Exit
				EndIf
			Next nIndex
		Else
			dPrimData := oDominio:oPeriodos:primeiraDataUtil(cFilAux)
			dLeadTime   := DaySub(dLeadTime, (aRetPrazo[1]))

			//Caso a data calculada seja um dia sem expediente, procura uma data poss�vel
			dLeadTime := Self:buscaUtilAnterior(cFilAux, dLeadTime)
		EndIf

	ElseIf oDominio:oParametros["nLeadTime"] == 3 //Dias �teis (considera calend�rio)

		If aRetPrazo[2] == IND_HORA
			nSaldoMinu := Hrs2Min(cValToChar(aRetPrazo[1])+":00")
			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			For nIndex := nPosPeri To 1 Step -1
				cHoraDia := oDominio:oDados:retornaCampo("CAL", 1, cFilAux + DToS(oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)), "CAL_UTEIS", @lError)
				nMinutDia := Hrs2Min(cValToChar(cHoraDia))

				nSaldoMinu -= nMinutDia

				If nSaldoMinu <= 0
					dLeadTime := oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nIndex)
					Exit
				EndIf
			Next nIndex
		Else
			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			While nCont <= aRetPrazo[1]
				dLeadTime := ::buscaUtilAnterior(cFilAux, dLeadTime)
				dLeadTime--
				nCont++
			EndDo

			//Caso a data calculada seja um dia sem expediente, procura uma data poss�vel
			dLeadTime := Self:buscaUtilAnterior(cFilAux, dLeadTime)

			nPosPeri := oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dLeadTime)

			//Se o per�odo dessa demanda com o lead time for menor que o primeiro per�odo �til
			//do MRP, ir� utilizar sempre o primeiro per�odo �til.
			If nPosPeri < oDominio:oPeriodos:primeiroPeriodoUtil(cFilAux)
				nPosPeri := oDominio:oPeriodos:primeiroPeriodoUtil(cFilAux)
			EndIf

			dLeadTime := oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPosPeri)
		EndIf
	EndIf

Return

/*/{Protheus.doc} buscaUtilAnterior
Busca o primeiro dia �til exatamente anterior � data par�metro no calend�rio MRP
@author douglas.heydt
@since 27/08/2019
@version 1.0
@param 01 - cFilAux, caracter, c�digo da filial
@param 02 - dData  , data    , data de partida para buscar o pr�ximo dia �til
@return     dData  , data    , data do pr�ximo dia �til de acordo com o calend�rio MRP
/*/
METHOD buscaUtilAnterior(cFilAux, dData) CLASS MrpDominio_LeadTime

	Local dPrimData := Self:oDominio:oPeriodos:primeiraDataUtil(cFilAux)

	If dData < dPrimData
		//A data recebida � menor que a primeira data �til do MRP.
		//Retorna a primeira data �til.
		dData := dPrimData
	Else
		//Verifica se a data possui hora de trabalho
		While !::oDominio:oPeriodos:verificaDataUtil(cFilAux, dData)
			//Se n�o possuir hora de trabalho, pega a data anterior.
			dData--
			If dData <= dPrimData
				//Se a data for menor que a primeira data �til do MRP, retorna a primeira data �til.
				dData := dPrimData
				Exit
			EndIf
		EndDo
	EndIf

Return dData
