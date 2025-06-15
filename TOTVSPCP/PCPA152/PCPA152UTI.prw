#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"

#DEFINE IND_CAPACIDADE  1
#DEFINE IND_PROGRAMADAS 2
#DEFINE IND_FIRMES      3
#DEFINE IND_APONTADAS   4
#DEFINE IND_DISPONIVEL  5
#DEFINE QTD_LINHAS_TIPO 5

/*/{Protheus.doc} PCPA152UTI
API para exibição da Utilização dos recursos

@type WSCLASS
@author marcelo.neumann
@since 10/05/2023
@version P12
/*/
WSRESTFUL PCPA152UTI DESCRIPTION "PCPA152UTI" FORMAT APPLICATION_JSON
	WSDATA Page        AS INTEGER OPTIONAL
	WSDATA PageSize    AS INTEGER OPTIONAL
	WSDATA dataInicial AS STRING  OPTIONAL
	WSDATA dataFinal   AS STRING  OPTIONAL
	WSDATA programacao AS STRING  OPTIONAL
	WSDATA recurso     AS STRING  OPTIONAL

	WSMETHOD GET UTILIZACAO;
		DESCRIPTION STR0191; //"Retorna a utilização dos recursos"
		WSSYNTAX "/api/pcp/v1/pcpa152uti/utilizacao/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152uti/utilizacao/{programacao}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET UTILIZACAO /api/pcp/v1/pcpa152uti/utilizacao
Retorna a utilizacao dos recursos

@type WSMETHOD
@author marcelo.neumann
@since 10/05/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD GET UTILIZACAO PATHPARAM programacao QUERYPARAM Page, PageSize, dataInicial, dataFinal, recurso WSSERVICE PCPA152UTI
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152UTI"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getUtiliza(Self:programacao, Self:Page, Self:PageSize, StrTran(Self:dataInicial, "-", ""), StrTran(Self:dataFinal, "-", ""), Self:recurso)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getUtiliza
Busca os dados de utilização dos recursos

@type Static Function
@author marcelo.neumann
@since 10/05/2023
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 nPage     , Numeric , Página para consulta
@param 03 nPageSize , Numeric , Tamanho da página
@param 04 cDataIni  , Caracter, Data inicial para filtro dos dados
@param 05 cDataFim  , Caracter, Data final para filtro dos dados
@param 06 cInRecurso, Caracter, Recursos para filtro dos dados
@return   aReturn   , Array   , Array com os dados de retorno da API
/*/
Static Function getUtiliza(cProg, nPage, nPageSize, cDataIni, cDataFim, cInRecurso)
	Local aReturn      := {.T., 200, ""}
	Local oJsRet       := JsonObject():New()
	Default nPage      := 1
	Default nPageSize  := 20
	Default cInRecurso := ""

	oJsRet["items"]                := JsonObject():New()
	oJsRet["items"]["recursos"   ] := {}
	oJsRet["items"]["utilizacao" ] := JsonObject():New()
	oJsRet["items"]["datasVazias"] := JsonObject():New()

	If getRecurs(@oJsRet, @cInRecurso, cProg, nPage, nPageSize) > 0
		getDatas(@oJsRet, cProg, cInRecurso, cDataIni, cDataFim)

		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oJsRet:toJson()
	Else
		oJsRet["_messages"] := {JsonObject():New()}
		oJsRet["_messages"][1]["code"           ] := "404"
		oJsRet["_messages"][1]["message"        ] := STR0192 //"Não existem dados de utilização que atendam aos filtros informados."
		oJsRet["_messages"][1]["detailedMessage"] := ""

		aReturn[3] := oJsRet:toJson()
	EndIf

	FwFreeObj(oJsRet)

Return aReturn

/*/{Protheus.doc} getRecurs
Busca os recursos conforme o filtro e a paginação

@type Static Function
@author marcelo.neumann
@since 10/05/2023
@version P12
@param 01 oJsRet    , Object  , Dados a serem retornados da API (retorno por refereência)
@param 02 cInRecurso, Caracter, Recursos a serem buscados (retorno por refereência)
@param 03 cProg     , Caracter, Código da programação para filtro
@param 04 nPage     , Numeric , Página para consulta
@param 05 nPageSize , Numeric , Tamanho da página
@return   nQtdRec   , Numeric , Quantidade de recursos encontrados
/*/
Static Function getRecurs(oJsRet, cInRecurso, cProg, nPage, nPageSize)
	Local cAlias  := getNextAlias()
	Local cFields := ""
	Local cFrom   := ""
	Local cOrder  := ""
	Local cWhere  := ""
	Local nStart  := 0
	Local nQtdRec := 0

	cFields := /*SELECT*/" DISTINCT SMR.MR_RECURSO,"
	cFields +=           " SH1.H1_DESCRI"
	cFrom   :=    /*FROM*/ RetSqlName("SMR") + " SMR"
	cFrom   +=     " INNER JOIN " + RetSqlName("SH1") + " SH1"
	cFrom   +=        " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "'"
	cFrom   +=       " AND SH1.H1_CODIGO  = SMR.MR_RECURSO"
	cFrom   +=       " AND SH1.D_E_L_E_T_ = ' '"
	cWhere  :=  /*WHERE*/" SMR.MR_FILIAL  = '" + xFilial("SMR") + "'"
	cWhere  +=       " AND SMR.MR_PROG    = '" + cProg + "'"
	cWhere  +=       " AND SMR.D_E_L_E_T_ = ' '"
	If !Empty(cInRecurso)
		cWhere +=    " AND SMR.MR_RECURSO IN ('" + StrTran(cInRecurso, ", ", "','") + "')"
	EndIf
	cOrder  :=  /*ORDER BY*/" SMR.MR_RECURSO, SH1.H1_DESCRI"

	cFields := "%" + cFields + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	cOrder  := "%" + cOrder  + "%"

	BeginSql Alias cAlias
		SELECT %Exp:cFields%
		  FROM %Exp:cFrom%
		 WHERE %Exp:cWhere%
		 ORDER BY %Exp:cOrder%
	EndSql

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	cInRecurso := ""
	While (cAlias)->(!Eof()) .And. nQtdRec < nPageSize
		nQtdRec++
		aAdd(oJsRet["items"]["recursos"], JsonObject():New())
		oJsRet["items"]["recursos"][nQtdRec]["recurso"  ] := RTrim((cAlias)->MR_RECURSO)
		oJsRet["items"]["recursos"][nQtdRec]["descricao"] := RTrim((cAlias)->H1_DESCRI)

		cInRecurso += ",'" + (cAlias)->MR_RECURSO + "'"

		(cAlias)->(dbSkip())
	End

	//Verifica se existem mais dados para retornar
	oJsRet["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	//Remove a primeira vírgula da lista de recursos
	cInRecurso := Stuff(cInRecurso, 1, 1, '')

Return nQtdRec

/*/{Protheus.doc} getDatas
Busca a utilização de cada recurso em cada data

@type Static Function
@author marcelo.neumann
@since 10/05/2023
@version P12
@param 01 oJsRet    , Object  , Dados a serem retornados da API (retorno por refereência)
@param 02 cProg     , Caracter, Código da programação para filtro
@param 03 cInRecurso, Caracter, Recursos encontrados na getRecurs() para filtro
@param 04 cDataIni  , Caracter, Data inicial para filtro dos dados
@param 05 cDataFim  , Caracter, Data final para filtro dos dados
@return Nil
/*/
Static Function getDatas(oJsRet, cProg, cInRecurso, cDataIni, cDataFim)
	Local cAlias   := getNextAlias()
	Local cData    := ""
	Local cFields  := ""
	Local cFrom    := ""
	Local cOrder   := ""
	Local cRecurso := ""
	Local cWhere   := ""
	Local nDispon  := 0

	cFields := /*SELECT*/"SMR.MR_RECURSO recurso,"
	cFields +=          " SMR.MR_DATDISP dataDisponibilidade,"
	cFields +=          " SMR.MR_TEMPOTO capacidade,"
	cFields +=          " ( SELECT COALESCE(sum(SVM.VM_TEMPO), 0)"
	cFields +=              " FROM " + RetSqlName("SVM") + " SVM"
	cFields +=             " INNER JOIN " + RetSqlName("SMF") + " SMF"
	cFields +=                " ON SMF.MF_FILIAL  = '" + xFilial("SMF") + "'"
	cFields +=               " AND SMF.MF_PROG    = SVM.VM_PROG"
	cFields +=               " AND SMF.MF_ID      = SVM.VM_ID"
	cFields +=               " AND SMF.MF_RECURSO = SMR.MR_RECURSO"
	cFields +=               " AND SMF.D_E_L_E_T_ = ' '"
	cFields +=             " WHERE SVM.VM_FILIAL  = '" + xFilial("SVM") + "'"
	cFields +=               " AND SVM.VM_PROG    = SMR.MR_PROG"
	cFields +=               " AND SVM.VM_DATA    = SMR.MR_DATDISP"
	cFields +=               " AND SVM.D_E_L_E_T_ = ' ' ) programadas,"
	cFields +=          " 0 firmes,"
	cFields +=          " 0 apontadas"
	cFrom   :=   /*FROM*/ RetSqlName("SMR") + " SMR"
	cWhere  := /*WHERE*/" SMR.MR_FILIAL  = '" + xFilial("SMR") + "'"
	cWhere  +=      " AND SMR.MR_PROG    = '" + cProg + "'"
	cWhere  +=      " AND SMR.D_E_L_E_T_ = ' '"
	cWhere  +=      " AND SMR.MR_RECURSO IN (" + cInRecurso + ")"
	If !Empty(cDataIni)
		cWhere +=   " AND SMR.MR_DATDISP >= '" + StrTran(cDataIni, "-", "") + "'"
	EndIf
	If !Empty(cDataFim)
		cWhere +=   " AND SMR.MR_DATDISP <= '" + StrTran(cDataFim, "-", "") + "'"
	EndIf
	cOrder  := /*ORDER BY*/" recurso, dataDisponibilidade"

	cFields := "%" + cFields + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	cOrder  := "%" + cOrder  + "%"

	BeginSql Alias cAlias
	  SELECT %Exp:cFields%
	    FROM %Exp:cFrom%
	   WHERE %Exp:cWhere%
	   ORDER BY %Exp:cOrder%
	EndSql

	While (cAlias)->(!Eof())
		If cRecurso <> RTrim((cAlias)->recurso)
			cRecurso := RTrim((cAlias)->recurso)

			oJsRet["items"]["utilizacao"][cRecurso]                  := Array(QTD_LINHAS_TIPO)
			oJsRet["items"]["utilizacao"][cRecurso][IND_CAPACIDADE ] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_PROGRAMADAS] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_FIRMES     ] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_APONTADAS  ] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_DISPONIVEL ] := JsonObject():New()
		EndIf

		cData := PCPConvDat((cAlias)->dataDisponibilidade, 4)

		oJsRet["items"]["utilizacao"][cRecurso][IND_CAPACIDADE ][cData] := __Min2Hrs((cAlias)->capacidade  , .T.)
		oJsRet["items"]["utilizacao"][cRecurso][IND_PROGRAMADAS][cData] := __Min2Hrs((cAlias)->programadas , .T.)
		oJsRet["items"]["utilizacao"][cRecurso][IND_FIRMES     ][cData] := __Min2Hrs((cAlias)->firmes      , .T.)
		oJsRet["items"]["utilizacao"][cRecurso][IND_APONTADAS  ][cData] := __Min2Hrs((cAlias)->apontadas   , .T.)

		nDispon := (cAlias)->capacidade - (cAlias)->programadas - (cAlias)->firmes - (cAlias)->apontadas
		If nDispon >= 0
			oJsRet["items"]["utilizacao"][cRecurso][IND_DISPONIVEL][cData] := __Min2Hrs(nDispon, .T.)
		Else
			oJsRet["items"]["utilizacao"][cRecurso][IND_DISPONIVEL][cData] := "-" +  __Min2Hrs(-nDispon, .T.)
		EndIf
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	completaDt(@oJsRet, cProg, cDataIni, cDataFim)

Return

/*/{Protheus.doc} completaDt
Percorre os recursos e datas completando as datas sem registro de utilização

@type Static Function
@author marcelo.neumann
@since 10/05/2023
@version P12
@param 01 oJsRet  , Object  , Dados a serem retornados da API (retorno por refereência)
@param 02 cProg   , Caracter, Código da programação para filtro
@param 03 cDataIni, Caracter, Data inicial da pesquisa
@param 04 cDataFim, Caracter, Data final da pesquisa
@return Nil
/*/
Static Function completaDt(oJsRet, cProg, cDataIni, cDataFim)
	Local cData     := ""
	Local cRecurso  := ""
	Local dDataAux  := Nil
	Local dDataFim  := Nil
	Local dDataIni  := Nil
	Local nIndData  := 0
	Local nIndRec   := 0
	Local nTotDatas := 0
	Local nTotRecur := Len(oJsRet["items"]["recursos"])

	If Empty(cDataIni)
		buscaDatas(cProg, @cDataIni, @cDataFim)
	EndIf

	dDataIni  := PCPConvDat(cDataIni, 1)
	dDataFim  := PCPConvDat(cDataFim, 1)
	nTotDatas := dDataFim - dDataIni + 1

	//Percorre todos os recursos em busca de furos nas datas
	For nIndRec := 1 To nTotRecur
		cRecurso := oJsRet["items"]["recursos"][nIndRec]["recurso"]
		dDataAux := dDataIni

		//Se o recurso não foi encontrado com o filtro de data, cria a chave para adicionar as horas zeradas
		If !oJsRet["items"]["utilizacao"]:HasProperty(cRecurso)
			oJsRet["items"]["utilizacao"][cRecurso]                  := Array(QTD_LINHAS_TIPO)
			oJsRet["items"]["utilizacao"][cRecurso][IND_CAPACIDADE ] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_PROGRAMADAS] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_FIRMES     ] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_APONTADAS  ] := JsonObject():New()
			oJsRet["items"]["utilizacao"][cRecurso][IND_DISPONIVEL ] := JsonObject():New()
		EndIf

		//Percorre as datas do filtro, preenchendo com zero a data inexistente
		For nIndData := 1 To nTotDatas
			cData := PCPConvDat(PCPConvDat(dDataAux, 2), 3)

			If !oJsRet["items"]["utilizacao"][cRecurso][IND_CAPACIDADE ]:HasProperty(cData)
				oJsRet["items"]["utilizacao"][cRecurso][IND_CAPACIDADE ][cData] := "00:00"
				oJsRet["items"]["utilizacao"][cRecurso][IND_PROGRAMADAS][cData] := "00:00"
				oJsRet["items"]["utilizacao"][cRecurso][IND_FIRMES     ][cData] := "00:00"
				oJsRet["items"]["utilizacao"][cRecurso][IND_APONTADAS  ][cData] := "00:00"
				oJsRet["items"]["utilizacao"][cRecurso][IND_DISPONIVEL ][cData] := "00:00"

				If oJsRet["items"]["datasVazias"][cRecurso] == Nil
					oJsRet["items"]["datasVazias"][cRecurso] := {}
				EndIf
				aAdd(oJsRet["items"]["datasVazias"][cRecurso], (nIndData - 1))
			EndIf

			dDataAux++
		Next nIndData
	Next nIndRec

Return

/*/{Protheus.doc} buscaDatas
Busca a data inicial e final da programação

@type Static Function
@author marcelo.neumann
@since 24/05/2023
@version P12
@param 01 cProg   , Caracter, Código da programação para filtro
@param 02 cDataIni, Caracter, Data inicial a ser retornada por referência
@param 03 cDataFim, Caracter, Data final a ser retornada por referência
@return Nil
/*/
Static Function buscaDatas(cProg, cDataIni, cDataFim)
	Local cAlias  := getNextAlias()
	Local cFields := ""
	Local cQuery  := ""

	cFields := /*SELECT*/" dataInicial.T4Y_VALOR dataInicial,"
	cFields +=           " dataFinal.T4Y_VALOR   dataFinal"
	cQuery  :=    /*FROM*/ RetSqlName("T4Y") + " dataInicial"
	cQuery  +=     " INNER JOIN " + RetSqlName("T4Y") + " dataFinal"
	cQuery  +=        " ON dataFinal.T4Y_FILIAL   = dataInicial.T4Y_FILIAL"
	cQuery  +=       " AND dataFinal.T4Y_PROG     = dataInicial.T4Y_PROG"
	cQuery  +=       " AND dataFinal.T4Y_PARAM    = 'dataFinal'"
	cQuery  +=       " AND dataFinal.D_E_L_E_T_   = ' '
	cQuery  +=     " WHERE dataInicial.T4Y_FILIAL = '" + xFilial("T4Y") + "'"
	cQuery  +=       " AND dataInicial.T4Y_PROG   = '" + cProg + "'"
	cQuery  +=       " AND dataInicial.T4Y_PARAM  = 'dataInicial'"
	cQuery  +=       " AND dataInicial.D_E_L_E_T_ = ' '

	cFields := "%" + cFields + "%"
	cQuery  := "%" + cQuery  + "%"

	BeginSql Alias cAlias
	  SELECT %Exp:cFields%
	    FROM %Exp:cQuery%
	EndSql

	If (cAlias)->(!Eof())
		cDataIni := (cAlias)->dataInicial
		cDataFim := (cAlias)->dataFinal
	EndIf
	(cAlias)->(dbCloseArea())

Return Nil
