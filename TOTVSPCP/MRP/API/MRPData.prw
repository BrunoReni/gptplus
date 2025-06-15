#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPDATA.CH"

#DEFINE N_POS_ESTOQUE         1
#DEFINE N_POS_ENTRADAS        2
#DEFINE N_POS_SAIDAS          3
#DEFINE N_POS_TRANSF_ENTRADA  4
#DEFINE N_POS_TRANSF_SAIDA    5
#DEFINE N_POS_SAIDA_ESTRUTURA 6
#DEFINE N_POS_SUBSTITUICAO    7
#DEFINE N_POS_SALDO_FINAL     8
#DEFINE N_POS_NECESSIDADE     9
#DEFINE N_POS_VALOR_NECESS    10
#DEFINE N_POS_VALOR_ESTOQUE   11
#DEFINE N_POS_QUANT_PMP       12
#DEFINE N_TAM_ARRAY_TIPOS     12

Static _aTamQtd  := TamSX3("HWG_QTEMPE")
Static _oDescAgl := Nil
Static _lPctRas  := Nil

/*/{Protheus.doc} mrpdata
API de integracao de Resultados do MRP

@type  WSCLASS
@author renan.roeder
@since 31/07/2019
@version P12.1.27
/*/
WSRESTFUL mrpdata DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Resultados do MRP"
	WSDATA allBranches         AS BOOLEAN OPTIONAL
	WSDATA branchId            AS STRING  OPTIONAL
	WSDATA clean               AS STRING  OPTIONAL
	WSDATA finalDate           AS STRING  OPTIONAL
	WSDATA initialDate         AS STRING  OPTIONAL
	WSDATA Order               AS STRING  OPTIONAL
	WSDATA optionalId          AS STRING  OPTIONAL
	WSDATA product             AS STRING  OPTIONAL
	WSDATA productDescription  AS STRING  OPTIONAL
	WSDATA productGroup        AS STRING  OPTIONAL
	WSDATA purchaseGroup       AS STRING  OPTIONAL
	WSDATA productType         AS STRING  OPTIONAL
	WSDATA ticket              AS STRING  OPTIONAL
	WSDATA filter              AS STRING  OPTIONAL
	WSDATA filterZero          AS INTEGER OPTIONAL
	WSDATA Page                AS INTEGER OPTIONAL
	WSDATA PageSize            AS INTEGER OPTIONAL
	WSDATA productFrom         AS STRING  OPTIONAL
	WSDATA productTo           AS STRING  OPTIONAL
	WSDATA costOption          AS INTEGER OPTIONAL
	WSDATA periodFrom          AS STRING  OPTIONAL
	WSDATA periodTo            AS STRING  OPTIONAL

	WSMETHOD GET RESULTS;
		DESCRIPTION STR0002; //"Retorna os resultados do cálculo do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/results" ;
		PATH "api/pcp/v1/mrpdata/results" ;
		TTALK "v1"

	WSMETHOD GET TICKETS;
		DESCRIPTION STR0003; //"Retorna todos tickets processados pelo MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/tickets" ;
		PATH "api/pcp/v1/mrpdata/tickets" ;
		TTALK "v1"

	WSMETHOD GET PRODRESULT;
		DESCRIPTION STR0012; //"Retorna os resultados de um produto específico"
		WSSYNTAX "api/pcp/v1/mrpdata/prodresult" ;
		PATH "api/pcp/v1/mrpdata/prodresult" ;
		TTALK "v1"

	WSMETHOD GET STGERADOC;
		DESCRIPTION STR0024; //"Retorna o status da geração dos documentos de acordo com o resultado do processamento do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/stgeradoc/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/stgeradoc/{ticket}" ;
		TTALK "v1"

	WSMETHOD POST GERADOC;
		DESCRIPTION STR0017; //"Geração dos documentos de acordo com o resultado do processamento do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/geradoc/" ;
		PATH "api/pcp/v1/mrpdata/geradoc/" ;
		TTALK "v1"

	WSMETHOD GET REPORT;
		DESCRIPTION STR0026; //"Busca resultados do MRP para exportação de relatório"
		WSSYNTAX "api/pcp/v1/mrpdata/report/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/report/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET PRODSINFO;
		DESCRIPTION STR0027; //"Busca informações de produtos"
		WSSYNTAX "api/pcp/v1/mrpdata/products/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/products/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET PERIODS;
		DESCRIPTION STR0033; //"Busca informações dos períodos";
		WSSYNTAX "api/pcp/v1/mrpdata/periods/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/periods/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET SUBSALT;
		DESCRIPTION STR0049; //"Busca os produtos alternativos a partir de um produto original"
		WSSYNTAX "api/pcp/v1/mrpdata/subst/alt";
		PATH "api/pcp/v1/mrpdata/subst/alt";
		TTALK "v1"

	WSMETHOD GET SUBSORI;
		DESCRIPTION STR0050; //"Busca os produtos originais a partir de um produto alternativo"
		WSSYNTAX "api/pcp/v1/mrpdata/subst/ori";
		PATH "api/pcp/v1/mrpdata/subst/ori";
		TTALK "v1"

	WSMETHOD GET GEN_INFO;
		DESCRIPTION STR0052; //"Retorna informações que não dependem do ticket selecionado."
		WSSYNTAX "api/pcp/v1/mrpdata/generics" ;
		PATH "api/pcp/v1/mrpdata/generics" ;
		TTALK "v1"

	WSMETHOD GET OPTIONAL;
		DESCRIPTION STR0051; //"Busca os opcionais do produto em um ticket";
		WSSYNTAX "api/pcp/v1/mrpdata/optional/{ticket}/{product}/{optionalId}" ;
		PATH "api/pcp/v1/mrpdata/optional/{ticket}/{product}/{optionalId}" ;
		TTALK "v1"

	WSMETHOD GET EXP_OPC;
		DESCRIPTION STR0055; //"Retorna as informações dos opcionais para exportação"
		WSSYNTAX "api/pcp/v1/mrpdata/expopc/{ticket}";
		PATH "api/pcp/v1/mrpdata/expopc/{ticket}";
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET PRODSINFO api/pcp/v1/mrpdata/products/{ticket}
Retorna todos os produtos do ticket

@type WSMETHOD
@author douglas.heydt
@since 25/04/2021
@version P12.1.27
@param 01 ticket      , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 product     , Caracter, Código do produto
@param 03 productFrom , Caracter, Código inicial do filtro de produto
@param 04 productTo   , Caracter, Código final do filtro de produto
@param 05 costOption  , Numeral , Tipo do custo de produto
@param 06 optionalId  , Caracter, ID Opcional do produto
@param 07 allBranches , Lógico  , Indica se deve retornar as informações dos produtos de todas as filiais
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PRODSINFO WSRECEIVE ticket, product, productFrom, productTo, costOption, optionalId, allBranches WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getProds(Self:ticket, Self:product, Self:productFrom, Self:productTo, Self:costOption, Self:optionalId, Self:allBranches)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} GET PRODRESULT api/pcp/v1/mrpdata/prodresult
Retorna os resultados de um produto específico (HWC)

@type WSMETHOD
@author douglas.heydt
@since 25/04/2021
@version P12.1.27
@param 01 branchId, Caracter, Codigo da filial para fazer a pesquisa
@param 02 ticket  , Caracter, Codigo único do processo para fazer a pesquisa
@param 03 Order   , Caracter, Ordenação do retorno da consulta
@param 04 Page    , Caracter, Página de retorno
@param 05 PageSize, Caracter, Tamanho da página
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PRODRESULT WSRECEIVE ticket, product, optionalId, filterZero QUERYPARAM Order, Page, PageSize WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getPrdRes(Self:ticket, Self:product, Self:optionalId, Self:filterZero)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} GET RESULTS api/pcp/v1/mrpdata/results/{branchId}/{ticket}
Retorna o Resultado do processamento do MRP (HWB)

@type WSMETHOD
@author marcelo.neumann
@since 26/03/2021
@version P12.1.27
@param 01 branchId, Caracter, Codigo da filial para fazer a pesquisa
@param 02 ticket  , Caracter, Codigo único do processo para fazer a pesquisa
@param 03 Order   , Caracter, Ordenação do retorno da consulta
@param 04 Page    , Caracter, Página de retorno
@param 05 PageSize, Caracter, Tamanho da página
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/

WSMETHOD GET RESULTS WSRECEIVE branchId, ticket, product, productDescription, productGroup, purchaseGroup, productType, filterZero  QUERYPARAM Order, Page, PageSize WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetRes(Self:branchId, Self:ticket, Self:product, Self:productDescription, Self:productGroup, Self:purchaseGroup, Self:productType, Self:filterZero, Self:Order, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetRes
Retorna o Resultado do processamento do MRP (HWB)

@type Function
@author marcelo.neumann
@since 26/03/2021
@version P12.1.27
@param 01 cBranch    , Caracter, Codigo da filial
@param 02 cTicket    , Caracter, Codigo único do processo
@param 03 cProduct   , Caracter, Código do produto
@param 04 cPrdDescri , Caracter, Descrição do produto
@param 05 cProdGroup , Caracter, grupo do produto
@param 06 cPurcGroup , Caracter, grupo de compras
@param 07 cProdType  , Caracter, tipo do produto
@param 08 nFiltZero  , Numeral, 1 = não busca valores com necesssidade zerada
@param 09 cOrder     , Caracter, Ordenação do retorno da consulta
@param 10 nPage      , Caracter, Página de retorno
@param 11 cPageSize  , Caracter, Tamanho da página
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi
/*/
Function MrpGetRes(cBranch, cTicket,  cProduct, cPrdDescri, cProdGroup, cPurcGroup, cProdType, nFiltZero, cOrder, nPage, nPageSize)
	Local aFiliais   := {}
	Local aResult 	 := {.F., EncodeUTF8(STR0016), 400} //"Não existem registros para atender os filtros informados"
	Local cAliasQry  := GetNextAlias()
	Local cFiliaisIN := ""
	Local cQuery     := ""
	Local cHasAgl    := ""
	Local lMultiEmp  := .F.
	Local lTemPrdDes := .F.
	Local lAgluMrp   := .F.
	Local nIndex     := 0
	Local nPos       := 0
	Local nStart     := 0
	Local nTotFils   := 0
	Local nInSubs    := 0
	Local nOutSubs   := 0
	Local nLtVenc    := 0
	Local nPMP       := 0
	Local oJson      := JsonObject():New()

	Default nPage      := 1
	Default nPageSize  := 20
	Default cPrdDescri := ""
	Default cProdGroup := ""
	Default cPurcGroup := ""
	Default cProdType  := ""
	Default cOrder     := 'product, optionalId'

	dbSelectArea("HWA")
	lTemPrdDes := (FieldPos("HWA_DESC") > 0)

	DbSelectArea("HWB")
	lAgluMrp := (FieldPos("HWB_AGLPRD") > 0)

	If Empty(cTicket) .Or. !Empty(cBranch)
		If !Empty(cBranch)
			cBranch := PadR(cBranch, FWSizeFilial())
		EndIf

		cFiliaisIN := "'" + xFilial("HWB", cBranch) + "'"
	Else
		ticketME(cTicket, .F., , , , aFiliais)
		nTotFils := Len(aFiliais)
		If nTotFils == 0
			cFiliaisIN := "'" + xFilial("HWB") + "'"
		Else
			lMultiEmp := .T.
			For nIndex := 1 To nTotFils
				If nIndex > 1
					cFiliaisIN += ","
				EndIf
				cFiliaisIN += "'" + aFiliais[nIndex][1] + "'"
			Next nIndex
		EndIf
	EndIf

	cQuery := "SELECT HWB.HWB_TICKET ticket,"                 + ;
	                " HWB.HWB_PRODUT product,"                + ;
	                " HWB.HWB_IDOPC  optionalId,"             + ;
	                " SUM(HWB.HWB_QTENTR) inFlows,"           + ;
	                " SUM(HWB.HWB_QTSAID) outFlows,"          + ;
	                " SUM(HWB.HWB_QTSEST) structureOutFlows,"

	If nTotFils > 0
		cQuery +=   " SUM(HWB.HWB_QTRENT) transferIn,"        + ;
		            " SUM(HWB.HWB_QTRSAI) transferOut,"
	EndIf

	cQuery +=       " SUM(HWB.HWB_QTNECE) necessityQuantity,"

	cQuery +=" ( SELECT SUM(HWC_QTSUBS) "
	cQuery +="   FROM " +RetSqlName("HWC") + " "
	cQuery +="   WHERE HWC_FILIAL IN (" + cFiliaisIN + ") "
	cQuery +="   AND HWC_TICKET = '" + cTicket + "'"
	cQuery +="   AND HWC_PRODUT = HWB.HWB_PRODUT "
	cQuery +="   AND HWC_IDOPC = HWB.HWB_IDOPC "
	cQuery +="   AND HWC_QTSUBS > 0 ) insubs,"

	cQuery +=" ( SELECT SUM(HWC_QTSUBS) "
	cQuery +="   FROM " +RetSqlName("HWC") + " "
	cQuery +="   WHERE HWC_FILIAL IN (" + cFiliaisIN + ") "
	cQuery +="   AND HWC_TICKET = '" + cTicket + "'"
	cQuery +="   AND HWC_PRODUT = HWB.HWB_PRODUT "
	cQuery +="   AND HWC_IDOPC = HWB.HWB_IDOPC "
	cQuery +="   AND HWC_QTSUBS < 0) outsubs, "

	cQuery +=" ( SELECT SUM(HWC_QTNEOR) "
	cQuery +="   FROM " +RetSqlName("HWC") + " "
	cQuery +="   WHERE HWC_FILIAL IN (" + cFiliaisIN + ") "
	cQuery +="   AND HWC_TICKET = '" + cTicket + "'"
	cQuery +="   AND HWC_PRODUT = HWB.HWB_PRODUT "
	cQuery +="   AND HWC_IDOPC = HWB.HWB_IDOPC "
	cQuery +="   AND HWC_TPDCPA = 'LTVENC') expiredBatch, "

	cQuery +=" ( SELECT SUM(HWC_QTNEOR)  "
	cQuery +="    FROM " +RetSqlName("HWC") + " "
	cQuery +="    WHERE HWC_FILIAL IN (" + cFiliaisIN + ") ""
	cQuery +="    AND HWC_TICKET = '" + cTicket + "'"
	cQuery +="    AND HWC_PRODUT = HWB.HWB_PRODUT  "
	cQuery +="    AND HWC_IDOPC = HWB.HWB_IDOPC  "
	cQuery +="    AND HWC_TPDCPA = '1') masterPlan "

	If lAgluMrp
		cQuery +=",( SELECT MAX(HWBAGL.HWB_AGLPRD) "
		cQuery +=    " FROM " +RetSqlName("HWB") + " HWBAGL "
		cQuery +=   " WHERE HWBAGL.HWB_FILIAL IN (" + cFiliaisIN + ") ""
		cQuery +=     " AND HWBAGL.HWB_TICKET = '" + cTicket + "'"
		cQuery +=     " AND HWBAGL.HWB_PRODUT = HWB.HWB_PRODUT  "
		cQuery +=     " AND HWBAGL.HWB_IDOPC  = HWB.HWB_IDOPC  "
		cQuery +=     " AND HWBAGL.HWB_AGLPRD NOT IN(' ', '0')) hasAglMrp "
	EndIf

	cQuery += " FROM " + RetSqlName("HWB") + " HWB"          + ;
			  " INNER JOIN " +RetSqlName("HWA") + " HWA"      + ;
			     " ON HWA.HWA_FILIAL = '" + xFilial("HWA") + "'" + ;
				" AND HWA.HWA_PROD = HWB.HWB_PRODUT"     + ;
				" AND HWA.D_E_L_E_T_ = ' '"              + ;
			  " WHERE HWB.HWB_FILIAL IN (" + cFiliaisIN + ")" + ;
                " AND HWB.D_E_L_E_T_ = ' '"

	If !Empty(cTicket)
		cQuery += " AND HWB.HWB_TICKET = '" + cTicket + "'"
	EndIf

	If !Empty(cProduct)
		cQuery += " AND HWB.HWB_PRODUT like '%" + cProduct + "%'"
	EndIf

	If !Empty(cProdType)
		cQuery += " AND HWA.HWA_TIPO like '%" + cProdType + "%'"
	EndIf

	If !Empty(cProdGroup)
		cQuery += " AND HWA.HWA_GRUPO like '%" + cProdGroup + "%'"
	EndIf

	If !Empty(cPrdDescri) .And. lTemPrdDes
		cQuery += " AND HWA.HWA_DESC like '%" + cPrdDescri + "%'"
	EndIf

	If !Empty(cPurcGroup)
		cQuery += " AND HWA.HWA_GRPCOM like '%" + cPurcGroup + "%'"
	EndIf

	cQuery += " GROUP BY HWB.HWB_TICKET," + ;
	                   " HWB.HWB_PRODUT," + ;
 	                   " HWB.HWB_IDOPC "

	If nFiltZero == 1
		cQuery += " HAVING Sum(HWB.HWB_QTNECE) > 0 "
	EndIf

	cQuery += " ORDER BY " + cOrder

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, "inFlows"          , "N", _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, "outFlows"         , "N", _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, "structureOutFlows", "N", _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, "necessityQuantity", "N", _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'insubs'           , 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS" ,"X3_DECIMAL"))
	TcSetField(cAliasQry, 'outsubs'          , 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS" ,"X3_DECIMAL"))

	If nTotFils > 0
		TcSetField(cAliasQry, "transferIn"   , "N", _aTamQtd[1], _aTamQtd[2])
		TcSetField(cAliasQry, "transferOut"  , "N", _aTamQtd[1], _aTamQtd[2])
	EndIf

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
        nPos++

		nInSubs  := (cAliasQry)->insubs
		nOutSubs := (cAliasQry)->outsubs
		nLtVenc  := (cAliasQry)->expiredBatch
		nPMP     := (cAliasQry)->masterPlan
		If lAgluMrp 
			cHasAgl := (cAliasQry)->hasAglMrp
		EndIf
		
		If Empty(nInSubs)
			nInSubs := 0
		EndIf
		If Empty(nOutSubs)
			nOutSubs := 0
		EndIf
		If Empty(nLtVenc)
			nLtVenc := 0
		EndIf
		If Empty(nPMP)
			nPMP := 0
		EndIf
		If lAgluMrp .And. Empty(cHasAgl)
			cHasAgl := ""
		EndIf


		oJson["items"][nPos]["link"             ] := {'link'}
		oJson["items"][nPos]["ticket"           ] := (cAliasQry)->ticket
		oJson["items"][nPos]["product"          ] := RTRIM((cAliasQry)->product)
		oJson["items"][nPos]["inFlows"          ] := (cAliasQry)->inFlows - nInSubs + nPMP
		oJson["items"][nPos]["outFlows"         ] := (cAliasQry)->outFlows + nOutSubs - nPMP
		oJson["items"][nPos]["substitution"     ] := nInSubs+nOutSubs
		oJson["items"][nPos]["structureOutFlows"] := (cAliasQry)->structureOutFlows
		oJson["items"][nPos]["necessityQuantity"] := (cAliasQry)->necessityQuantity

		If nTotFils > 0
			oJson["items"][nPos]["transferIn"   ] := (cAliasQry)->transferIn
			oJson["items"][nPos]["transferOut"  ] := (cAliasQry)->transferOut
		Else
			oJson["items"][nPos]["transferIn"   ] := 0
			oJson["items"][nPos]["transferOut"  ] := 0
		EndIf

		oJson["items"][nPos]["optionalId"       ] := (cAliasQry)->optionalId

		getInfoPrd(@oJson["items"][nPos], lTemPrdDes, cFiliaisIN)

		//Atualiza as informações de opcional
		If Empty((cAliasQry)->optionalId)
			oJson["items"][nPos]["viewOptional" ] := {''}
		Else
			oJson["items"][nPos]["viewOptional" ] := {'viewOptional'}
		EndIf

		If lAgluMrp .And. !Empty(cHasAgl)
			oJson["items"][nPos]["qtyOfAgglutinateMRP"] := 1
		Else
			oJson["items"][nPos]["qtyOfAgglutinateMRP"] := 0
		EndIf

		oJson["items"][nPos]["optionalSelected" ] := (cAliasQry)->optionalId
		oJson["items"][nPos]["finalBalance"     ] := oJson["items"][nPos]["stockBalance"     ] + ;
		                                             ( (cAliasQry)->inFlows + nPMP           ) + ;
		                                             oJson["items"][nPos]["transferIn"       ] - ;
		                                             ( (cAliasQry)->outFlows - nPMP          ) - ;
		                                             oJson["items"][nPos]["structureOutFlows"] - ;
		                                             oJson["items"][nPos]["transferOut"      ] - ;
		                                             nLtVenc

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["ticketMultiEmpresa"] := lMultiEmp
	oJson["hasNext"]            := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)
	aSize(aFiliais, 0)

Return aResult

/*/{Protheus.doc} GET TICKETS api/pcp/v1/mrpdata/tickets
Retorna todos tickets processados pelo MRP

@type WSMETHOD
@author douglas.heydt
@since 31/03/2021
@version P12.1.27
@param 01 filter      , Caracter, usado para buscar ticket especifico
@param 02 initialDate , Caracter, data inicial de processamento do ticket
@param 03 finalDate   , Caracter, data final de processamento do ticket
@param 04 clean       , Caracter, indica se a busca é efetuada pela limpeza de tickets Po UI ( true ou false)
@param 05 Order       , Caracter, Ordenação do retorno da consulta
@param 06 Page        , Caracter, Página de retorno
@param 07 PageSize    , Caracter, Tamanho da página
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET TICKETS WSRECEIVE filter,initialDate, finalDate, clean QUERYPARAM Order, Page, PageSize WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	If Self:clean == "true"
	  Self:clean := .T.
	Else
		Self:clean := .F.
	EndIf

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetTick(Self:filter, Self:initialDate, Self:finalDate , Self:clean, Self:Order, Self:Page, Self:PageSize)

	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetTick
Retorna todos tickets processados pelo MRP

@type Function
@author douglas.heydt
@since 31/03/2021
@version P12.1.27
@param 01 cTicket     , Caracter, ticket que será buscado
@param 02 initialDate , Caracter, Data inicial de processamento do ticket
@param 03 finalDate   , Caracter, Data final de processamento do ticket
@param 04 lClean      , Caracter, indica se a busca é efetuada pela limpeza de tickets Po UI ( true ou false)
@param 05 cOrder      , Caracter, Ordenação do retorno da consulta
@param 06 nPage       , Caracter, Página de retorno
@param 07 cPageSize   , Caracter, Tamanho da página
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi
/*/
Function MrpGetTick(cTicket, initialDate, finalDate, lClean, cOrder, nPage, nPageSize)
	Local aResult 	   := {}
	Local cAliasQry    := GetNextAlias()
	Local cStatus      := ""
	Local cQuery       := ""
	Local nPos         := 0
	Local nStart       := 0
	Local oJson        := JsonObject():New()

	Default cTicket   :=" "
	Default cOrder    := 'ticket'
	Default nPage     := 1
	Default nPageSize := 20
	Default lClean    := .F.

	dbSelectArea("HW3")

	cQuery := " SELECT "+;
                    " HW3_FILIAL  branchId, "    +;
                    " HW3_TICKET  ticket, "      +;
                    " HW3_STATUS  status,"       +;
                    " HW3_DTINIC  initialDate, " +;
                    " HW3_HRINIC  InitialTime, " +;
                    " HW3_DTFIM   finalDate, "   +;
                    " HW3_HRFIM   finalTime, "   +;
					" HW3_USER    usuario, "     +;
					" ( select HW1_VAL from "+RetSqlName("HW1")+" where HW1_FILIAL = '"+xFilial("HW1")+"' AND HW1_TICKET = HW3_TICKET AND HW1_PARAM = 'demandEndDate' AND D_E_L_E_T_ = ' ' ) AS demandEndDate, " +;
				    " ( select HW1_VAL from "+RetSqlName("HW1")+" where HW1_FILIAL = '"+xFilial("HW1")+"' AND HW1_TICKET = HW3_TICKET AND HW1_PARAM = 'demandStartDate' AND D_E_L_E_T_ = ' ' ) AS demandStartDate " +;
             " FROM "+RetSqlName("HW3")+" "+;
             " WHERE HW3_FILIAL = '"+xFilial("HW3")+"' AND D_E_L_E_T_ = ' ' "

	If !Empty(initialDate)
		cQuery += "AND HW3_DTINIC BETWEEN '"+convDate(initialDate, 2)+"' AND '"+convDate(finalDate, 2)+"' "
	Endif
	If lClean
		cQuery += " AND HW3_STATUS <> '8' "
	Else
		cQuery += " AND HW3_STATUS IN ('3','6','7') "
	EndIf
	If !Empty(cTicket)
		cQuery += " AND HW3_TICKET like '%"+cTicket+"%' "
	EndIf
	cQuery += " ORDER BY "+cOrder+" DESC "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'initialDate', 'D', GetSx3Cache("HW3_DTINIC", "X3_TAMANHO"), 0)
	TcSetField(cAliasQry, 'finalDate', 'D', GetSx3Cache("HW3_DTFIM", "X3_TAMANHO"), 0)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
		nPos++

		cStatus := P144Status((cAliasQry)->status)

		oJson["items"][nPos]["branchId"]        := (cAliasQry)->branchId
		oJson["items"][nPos]["ticket"]          := (cAliasQry)->ticket
		oJson["items"][nPos]["idStatus"]        := (cAliasQry)->status
		oJson["items"][nPos]["status"]          := cStatus
		oJson["items"][nPos]["initialDate"]     := convDate((cAliasQry)->initialDate, 1)
		oJson["items"][nPos]["initialTime"]     := (cAliasQry)->InitialTime
		oJson["items"][nPos]["finalDate"]       := convDate((cAliasQry)->finalDate, 1)
		oJson["items"][nPos]["finalTime"]       := (cAliasQry)->finalTime
		oJson["items"][nPos]["demandStartDate"] := convDate(trim((cAliasQry)->demandStartDate), 3)
		oJson["items"][nPos]["demandEndDate"]   := convDate(trim((cAliasQry)->demandEndDate), 3)
		oJson["items"][nPos]["user"]            := (cAliasQry)->usuario

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End
	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJSON()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, EncodeUTF8(STR0016)) //"Não existem registros para atender os filtros informados"
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} ticketME
Verifica se determinado ticket foi processado considerando multi-empresas.

@type  Static Function
@author lucas.franca
@since 18/11/2020
@version P12
@param cTicket   , Character, Numeração do ticket do MRP
@param lRetObj   , Logic    , Indica se deve retornar os objetos por referência.
@param oParametro, Object   , Referência do objeto de parâmetros. Retornado por referência se lRetObj = .T.
@param oDominio  , Object   , Referência do objeto da camada de dominio. Retornado por referência se lRetObj = .T.
@param oLogs     , Object   , Referência do objeto da camada de logs. Retornado por referência se lRetObj = .T.
@param aFiliais  , Array    , Filial centralizadora e filiais centralizadas do processamento
@return lUsaME, Logic, Indica se o ticket foi processado com multi-empresas
/*/
Static Function ticketME(cTicket, lRetObj, oParametro, oDominio, oLogs, aFiliais)
	Local cFilFilhas := ""
	Local cFilPrinci := ""
	Local lUsaME     := .F.
	Local nSizePar   := GetSx3Cache("HW1_PARAM", "X3_TAMANHO")

	If HW1->(dbSeek(xFilial("HW1") + cTicket + PadR("branchCentralizing", nSizePar)))
		cFilPrinci := HW1->HW1_VAL

		If HW1->(dbSeek(xFilial("HW1") + cTicket + PadR("centralizedBranches", nSizePar)))
			cFilFilhas := HW1->HW1_LISTA
		EndIf
	EndIf

	If !Empty(cFilPrinci) .And. !Empty(cFilFilhas)
		oParametro := JsonObject():New()
		oParametro["ticket"             ] := cTicket
		oParametro["cChaveExec"         ] := cTicket + "GET_HWC"
		oParametro["branchCentralizing" ] := cFilPrinci
		oParametro["centralizedBranches"] := cFilFilhas

		MrpAplicacao():parametrosDefault(@oParametro)

		oLogs    := MrpDados_Logs():New(oParametro)
		oDominio := MrpDominio():New(oParametro, oLogs, .T.)

		lUsaME   := oDominio:oMultiEmp:utilizaMultiEmpresa()
		aFiliais := oDominio:oMultiEmp:retornaFiliais()

		If !lRetObj .Or. !lUsaME
			FreeObj(oLogs)
			oDominio:oDados:destruir()
			FreeObj(oDominio)
			FreeObj(oParametro)
		EndIf
	EndIf

Return lUsaME

/*/{Protheus.doc} convDate
Converte formatos de data conforme o tipo definid.or.

@type  Static Function
@author douglas.heydt
@since 12/04/2021
@version P12.1.27
@param cData, Date, Data que será convertida
@param nType, numeral, tipo de conversão executada
		1 - date para DD/MM/AAAA
		2 - AAAA-MM-DD para AAAAMMDD
		3 - AAAA-MM-DD para DD/MM/AAAA
		4 - AAAAMMDD para AAAA-MM-DD


@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(cData, nType)

	If !Empty(cData)
		If nType == 1
			cData := StrZero(Day(cData),2) + "/" + StrZero(Month(cData),2) + "/" +  StrZero(Year(cData),4)
		ElseIf nType == 2
			cData := StrTran(cData, "-", "")
		ElseIf nType == 3
			cData := StrTran(cData, "-", "")
			cData := SUBSTR(cData, 7, 2)  + "/" + SUBSTR(cData, 5, 2)  + "/" +  SUBSTR(cData, 0, 4)
		ElseIf nType == 4
			cData := SUBSTR(cData, 0, 4) +"-"+ SUBSTR(cData, 5, 2)+"-"+SUBSTR(cData, 7, 2)
		EndIf
	EndIf

Return cData

/*/{Protheus.doc} getInfoPrd
Busca os detalhes do produto

@type Static Function
@author marcelo.neumann
@since 16/04/2021
@version P12.1.27
@param 01 oRegHWB   , Objeto  , Objeto JSON onde serão adicionadas as informações
@param 02 lTemPrdDes, Lógico  , Indica se o dicionário está atualizado com o campo de descrição do produto
@param 03 cFiliais  , Caracter, Filial atual (ou todas as filiais compartilhadas - multiempresa)
@return Nil
/*/
Static Function getInfoPrd(oRegHWB, lTemPrdDes, cFiliais)
	Local cAliasQry  := GetNextAlias()
	Local cQryCondic := ""
	Local cQryFields := ""
	Local nIndex     := 0
	Local nStockBal  := 0

	cQryFields := "%HWB.HWB_FILIAL branchId,"                   + ;
                  " HWB.HWB_QTSLES stockBalance,"               + ;
			      " HWA.HWA_TIPO   productType,"                + ;
			      " HWA.HWA_GRUPO  productGroup"

	If lTemPrdDes
		cQryFields += ", HWA.HWA_DESC   productDescription,"     + ;
		              "  HWA.HWA_GRPCOM purchaseGroup,"          + ;
		              "  HWA.HWA_GCDESC purchaseGroupDescription"
	EndIf

	cQryFields += "%"

	cQryCondic := "%" + RetSqlName("HWB") + " HWB"                                    + ;
	              " INNER JOIN " + RetSqlName("HWA") + " HWA"                         + ;
	                 " ON HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"                  + ;
	                " AND HWA.HWA_PROD   = HWB.HWB_PRODUT"                            + ;
	                " AND HWA.D_E_L_E_T_ = ' '"                                       + ;
	              " WHERE HWB.HWB_FILIAL IN (" + cFiliais + ")"                       + ;
	                " AND HWB.HWB_TICKET = '" + oRegHWB["ticket"       ] + "'"        + ;
	                " AND HWB.HWB_PRODUT = '" + oRegHWB["product"      ] + "'"        + ;
	                " AND HWB.HWB_IDOPC  = '" + oRegHWB["optionalId"   ] + "'"        + ;
	                " AND HWB.D_E_L_E_T_ = ' '"                                       + ;
					" AND HWB.HWB_DATA   = (SELECT DISTINCT Min(HWB_B.HWB_DATA)"      + ;
	                                        " FROM " + RetSqlName("HWB") + " HWB_B"   + ;
	                                       " WHERE HWB_B.HWB_FILIAL = HWB.HWB_FILIAL" + ;
	                                         " AND HWB_B.HWB_TICKET = HWB.HWB_TICKET" + ;
	                                         " AND HWB_B.HWB_PRODUT = HWB.HWB_PRODUT" + ;
	                                         " AND HWB_B.HWB_IDOPC  = HWB.HWB_IDOPC"  + ;
	                                         " AND HWB_B.D_E_L_E_T_ = ' ')%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cQryFields%
		  FROM %Exp:cQryCondic%
	EndSql

	oRegHWB["mrpDataDetail"] := {}

	While (cAliasQry)->(!Eof())
		nStockBal := nStockBal + (cAliasQry)->stockBalance

		aAdd(oRegHWB["mrpDataDetail"], JsonObject():New())
		nIndex++

		oRegHWB["mrpDataDetail"][nIndex]["branchId"                ] := (cAliasQry)->branchId
		If lTemPrdDes
			oRegHWB["mrpDataDetail"][nIndex]["productDescription"      ] := (cAliasQry)->productDescription
			oRegHWB["mrpDataDetail"][nIndex]["productType"             ] := (cAliasQry)->productType
			oRegHWB["mrpDataDetail"][nIndex]["productGroup"            ] := (cAliasQry)->productGroup
			oRegHWB["mrpDataDetail"][nIndex]["purchaseGroup"           ] := (cAliasQry)->purchaseGroup
			oRegHWB["mrpDataDetail"][nIndex]["purchaseGroupDescription"] := (cAliasQry)->purchaseGroupDescription
		EndIf

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	oRegHWB["stockBalance"] := nStockBal

Return

/*/{Protheus.doc} getPrdRes
Retorna o Resultado de um produto específico

@type Function
@author douglas.heydt
@since 03/05/2021
@version P12.1.27
@param 01 cTicket    , Caracter, Codigo único do processo
@param 02 cProduto   , Caracter, Código do produto
@param 03 cOptional  , Caracter, Id do opcional
@param 04 nFiltZero  , Numeral, 1 = não busca valores com necesssidade zerada
@return aResult, Array, Array com as informacoes da requisicao
/*/
Function getPrdRes(cTicket, cProduto, cOptional, nFiltZero)
	Local aDates     := {}
	Local aFiliais   := {}
	Local aResult 	 := {}
	Local cFiliaisIN := ""
	Local lMultiEmp  := .F.
	Local nIndex     := 0
	Local nTamDates  := 0
	Local nTotFils   := 0
	Local oJson      := JsonObject():New()

	Default cOptional := ""
	Default nFiltZero := 0

	If Empty(cTicket)
		cFiliaisIN := "'" + xFilial("HWB") + "'"
	Else
		ticketME(cTicket, .F., , , , aFiliais)
		nTotFils := Len(aFiliais)
		If nTotFils == 0
			cFiliaisIN := "'" + xFilial("HWB") + "'"
		Else
			lMultiEmp := .T.
			For nIndex := 1 To nTotFils
				If nIndex > 1
					cFiliaisIN += ","
				EndIf
				cFiliaisIN += "'" + aFiliais[nIndex][1] + "'"
			Next nIndex
		EndIf
	EndIf

	oJson["items"] := Array(N_TAM_ARRAY_TIPOS)

	oJson["items"][N_POS_ESTOQUE         ] := JsonObject():New()
	oJson["items"][N_POS_ENTRADAS        ] := JsonObject():New()
	oJson["items"][N_POS_SAIDAS          ] := JsonObject():New()
	oJson["items"][N_POS_TRANSF_ENTRADA  ] := JsonObject():New()
	oJson["items"][N_POS_TRANSF_SAIDA    ] := JsonObject():New()
	oJson["items"][N_POS_SAIDA_ESTRUTURA ] := JsonObject():New()
	oJson["items"][N_POS_SUBSTITUICAO    ] := JsonObject():New()
	oJson["items"][N_POS_SALDO_FINAL     ] := JsonObject():New()
	oJson["items"][N_POS_NECESSIDADE     ] := JsonObject():New()
	oJson["items"][N_POS_VALOR_NECESS    ] := JsonObject():New()
	oJson["items"][N_POS_VALOR_ESTOQUE   ] := JsonObject():New()
	oJson["items"][N_POS_QUANT_PMP       ] := JsonObject():New()

	aDates := getHWB(cTicket, cProduto, cOptional, cFiliaisIN, oJson["items"], nFiltZero, nTotFils)

	//Remove do JSON as linhas que não devem ser exibidas na tela de resultados do produto.
	If lMultiEmp
		aSize(oJson["items"], N_POS_NECESSIDADE)
	Else
		aDel(oJson["items"] , N_POS_TRANSF_SAIDA)
		aDel(oJson["items"] , N_POS_TRANSF_ENTRADA)
		aSize(oJson["items"], N_POS_NECESSIDADE-2)
	EndIf

	oJson["columns"] := {}
	nTamDates := Len(aDates)

	For nIndex := 1 To nTamDates
		aAdd(oJson["columns"], JsonObject():New())
		oJson["columns"][nIndex]["property"] := DTOS(aDates[nIndex])
		oJson["columns"][nIndex]["label"   ] := convDate(aDates[nIndex],1)
		oJson["columns"][nIndex]["width"   ] := "100px"
	Next nIndex

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)
	aSize(aFiliais, 0)

Return aResult

/*/{Protheus.doc} getHWB
Retorna o Resultado de um produto específico

@type Function
@author douglas.heydt
@since 03/05/2021
@version P12.1.27
@param 01 cTicket    , Caracter, Codigo único do processo
@param 02 cProduto   , Caracter, Código do produto
@param 03 cOptional  , Caracter, Id do opcional
@param 04 cFiliaisIN , Caracter, Filiais do ticket
@param 05 aItems     , Array   , Array que será composto pelos resultados do produto
@param 06 nFiltZero  , Numeral , 1 = não busca valores com necesssidade zerada
@param 07 nTotFils   , Numeral , > 0 indica que ticket foi processado considerando multi-empresas.
@return aReturn, Array, Array com os resultados do produto
/*/
Static Function getHWB(cTicket, cProduto, cOptional, cFiliaisIN, aItems, nFiltZero, nTotFils)
	Local aReturn   := {}
	Local cAliasQry := GetNextAlias()
	Local cChave    := ""
	Local cQuery    := ""

	If Empty(cOptional)
		//Tratativa para banco oracle, utiliza ao menos um espaço em branco na query.
		cOptional := " "
	Endif

	cQuery := "SELECT HWB_DATA, SUM(HWB_QTSLES) stockBalance, SUM(HWB_QTENTR) inFlows, SUM(HWB_QTSAID) outFlows, "

	If nTotFils > 0
		cQuery += " SUM(HWB_QTRENT) inFlowTrans, SUM(HWB_QTRSAI) outFlowTrans, "
	EndIf

	cQuery += " SUM(HWB_QTSEST) structOutFlows, SUM(HWB_QTNECE) necessity, "
	cQuery += "( SELECT COALESCE(SUM(HWC_QTSUBS),0) "
	cQuery += "  FROM "+ RetSqlName("HWC")+" "
	cQuery += "  WHERE HWC_FILIAL IN (" + cFiliaisIN + ") "
	cQuery += "    AND HWC_TICKET = '" + cTicket + "' "
	cQuery += "    AND HWC_PRODUT = '"+cProduto+"' "
	If !Empty(cOptional)
		cQuery += "    AND HWC_IDOPC = '"+cOptional+"' "
	EndIf
	cQuery += "    AND HWC_DATA = HWB_DATA AND HWC_QTSUBS > 0 ) insubs, "

	cQuery += "( SELECT COALESCE(SUM(HWC_QTSUBS),0) "
	cQuery += "  FROM "+ RetSqlName("HWC")+" "
	cQuery += "  WHERE HWC_FILIAL IN (" + cFiliaisIN + ") "
	cQuery += "    AND HWC_TICKET = '" + cTicket + "' "
	cQuery += "    AND HWC_PRODUT = '"+cProduto+"' "
	If !Empty(cOptional)
		cQuery += "    AND HWC_IDOPC = '"+cOptional+"' "
	EndIf
	cQuery += "    AND HWC_DATA = HWB_DATA AND HWC_QTSUBS < 0 ) outsubs, "

	cQuery += " ( SELECT COALESCE(SUM(HWC_QTNEOR),0)  "
	cQuery += "    FROM "+ RetSqlName("HWC")+" "
	cQuery += "    WHERE HWC_FILIAL IN (" + cFiliaisIN + ") "
	cQuery += "    AND HWC_TICKET =  '" + cTicket + "' "
	cQuery += "    AND HWC_PRODUT = '"+cProduto+"' "
	If !Empty(cOptional)
		cQuery += "    AND HWC_IDOPC = '"+cOptional+"' "
	EndIf
	cQuery += "    AND HWC_DATA = HWB_DATA "
	cQuery += "    AND HWC_TPDCPA = '1') masterPlan "

	cQuery += " FROM " + RetSqlName("HWB")                + ;
			  " WHERE HWB_FILIAL IN (" + cFiliaisIN + ")" + ;
			  " AND HWB_PRODUT = '"+cProduto+"' "
	If !Empty(cOptional)
		cQuery += " AND HWB_IDOPC = '"+cOptional+"' "
	EndIf
	cQuery += " AND HWB_TICKET = '" + cTicket + "' "      + ;
			  " AND D_E_L_E_T_ = ' '"                     + ;
			  " GROUP BY HWB_DATA"

	If nFiltZero == 1
		cQuery += " HAVING SUM(HWB_QTNECE) > 0 "
	EndIf

	cQuery += " ORDER BY HWB_DATA "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'HWB_DATA', 'D', GetSx3Cache("HWB_DATA", "X3_TAMANHO"), 0)

	While (cAliasQry)->(!Eof())

       	aAdd(aReturn, (cAliasQry)->HWB_DATA)
		cChave := DTOS((cAliasQry)->HWB_DATA)

		aItems[N_POS_ESTOQUE  ][cChave] := (cAliasQry)->stockBalance
		aItems[N_POS_ENTRADAS ][cChave] := (cAliasQry)->inFlows - (cAliasQry)->insubs + (cAliasQry)->masterPlan
		aItems[N_POS_SAIDAS   ][cChave] := (cAliasQry)->outFlows + (cAliasQry)->outsubs - (cAliasQry)->masterPlan
		If nTotFils > 0
			aItems[N_POS_TRANSF_ENTRADA  ][cChave] := (cAliasQry)->inFlowTrans
			aItems[N_POS_TRANSF_SAIDA    ][cChave] := (cAliasQry)->outFlowTrans
		Else
			aItems[N_POS_TRANSF_ENTRADA  ][cChave] := 0
			aItems[N_POS_TRANSF_SAIDA    ][cChave] := 0
		EndIf
		aItems[N_POS_SAIDA_ESTRUTURA ][cChave] := (cAliasQry)->structOutFlows
		aItems[N_POS_SUBSTITUICAO    ][cChave] := (cAliasQry)->insubs+(cAliasQry)->outsubs

		aItems[N_POS_SALDO_FINAL     ][cChave] := aItems[N_POS_ESTOQUE         ][cChave] + ;
		                                          aItems[N_POS_ENTRADAS        ][cChave] - ;
												  aItems[N_POS_SAIDAS          ][cChave] + ;
												  aItems[N_POS_TRANSF_ENTRADA  ][cChave] - ;
												  aItems[N_POS_TRANSF_SAIDA    ][cChave] - ;
												  aItems[N_POS_SAIDA_ESTRUTURA ][cChave] + ;
												  aItems[N_POS_SUBSTITUICAO    ][cChave]
		aItems[N_POS_NECESSIDADE     ][cChave] := (cAliasQry)->necessity

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return aReturn

/*/{Protheus.doc} GET STGERADOC api/pcp/v1/mrpdata/stgeradoc/{ticket}

@param ticket     , Character, Codigo único do processo

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
WSMETHOD GET STGERADOC PATHPARAM ticket WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetSTGD( Self:ticket )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} MrpGetSTGD
Retorna status da geração de documentos de um ticket

@param cticket  , Character, Codigo único do processo

@return aResult	, Array, resultados obtidos pela query
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
Function MrpGetSTGD( cTicket )
	Local aParMrp    := {}
	Local aResult 	 := {}
	Local aValida    := {}
	Local cDetError  := ""
	Local cError     := ""
	Local lError     := .F.
	Local nProgress  := 0
	Local nProgRast  := 0
	Local oGeraDoc   := Nil
	Local oJson      := JsonObject():New()
	Local oPCPError  := Nil

	If _lPctRas == Nil
		_lPctRas := FindFunction("P145DelRas")
	EndIf

	aValida := validaGera(cTicket,"GET")
	If aValida[1] = .F.
		lError := .T.
		cError := aValida[2]
	Else
		If aValida[2] == "3"
			loadParam(cTicket, @aParMrp)
			oGeraDoc := ProcessaDocumentos():New(cticket, .T., aParMrp, RetCodUsr() )
			nProgress := oGeraDoc:getProgress()
			If _lPctRas
				nProgRast := oGeraDoc:getRastProgress()
			EndIf
		Else
			If aValida[2] $ "6|7"
				nProgress := 100
				nProgRast := 100
				oPCPError := PCPMultiThreadError():New("PCPA145_"+ cTicket, .F.)
				If oPCPError:possuiErro()
					cDetError := oPCPError:getcError(3)
					lError := .T.

					Iif(Empty(cDetError), cError := STR0022, cError := STR0023) //"Erro indeterminado. Entre em contato com o departamento de TI e solicite consulta ao console.log" "Ocorreu erro na geração dos documentos"
					GravaCV8("4", GetGlbValue("PCPA145PROCCV8"), /*cMsg*/, cDetError, "", "", NIL, GetGlbValue("PCPA145PROCIDCV8"), cFilAnt)
				EndIf
				oPCPError:destroy()
			EndIf
		EndIf

		oJson["progress"    ] := nProgress
		oJson["progressRast"] := nProgRast
		oJson["status"      ] := P144Status(aValida[2])
		oJson["idStatus"    ] := aValida[2]
		oJson["msg"         ] := cDetError
	EndIf

	If aValida[1] = .T.
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, EncodeUTF8(cError))
		aAdd(aResult, 400)
	EndIf
Return aResult

/*/{Protheus.doc} POST GERADOC api/pcp/v1/mrpdata/geradoc/

@param ticket     , Character, Codigo único do processo

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
WSMETHOD POST GERADOC WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpPostGD( Self:GetContent() )
	MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} MrpPostGD
Inicia geração de documentos de um ticket

@param cBody, Character, Parâmetros para a geração de documentos (String JSON)

@return aResult	, Array, resultados obtidos pela query
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
Function MrpPostGD( cBody )
	Local aParMrp    := {}
	Local aResult    := {}
	Local aValida    := {}
	Local cRecover   := ""
	Local cDetError  := ""
	Local cError     := ""
	Local cErrorUID  := ""
	Local cTicket    := ""
	Local lError     := .F.
	Local oPCPError  := Nil
	Local oPCPLock   := PCPLockControl():New()
	Local oBody      := JsonObject():New()
	Local oJsError   := Nil

	/*nEspera, nNumerico, indica o comportamento relacionado a espera e falha na tentativa de reserva: PCPLockControl
	0 - Não aguarda lock e não exibe help
	1 - Não aguarda lock e exibe Help de Falha
	2 - Aguarda para fazer lock e não exibe tela de aguarde;
	3 - Aguarda para fazer lock e exibe tela de aguarde;*/
	Local nEspera  := 2

	cError := oBody:FromJson(cBody)
	If !Empty(cError)
		lError    := .T.
		cDetError := STR0034 //"Erro ao identificar os parâmetros recebidos na requisição."
	EndIf

	If !lError
		cTicket   := oBody["ticket"]
		cRecover  := '{|| oPCPLock:unlock("MRP_MEMORIA", "PCPA145", cTicket) }'
		cErrorUID := "PCPA145_"+ cTicket
		oPCPError := PCPMultiThreadError():New(cErrorUID, .F.)

		aValida := validaGera(cTicket, "POST")
		If aValida[1] == .F.
			lError := .T.
			cError := aValida[2]
		Else
			If !PCPLock("PCPA145")
				lError := .T.
				cError := STR0018 //"Existe outro processo bloqueando a geração de documentos. Aguarde e tente novamente mais tarde"
			EndIf

			If !lError
				If oPCPLock:lock("MRP_MEMORIA", "PCPA145", cTicket, .F., {"PCPA712", "PCPA145", "PCPA151"}, nEspera)
					loadParam(cTicket, @aParMrp)

					oPCPError:startJob("PCPA145", GetEnvServer(), .F., cEmpAnt, cFilAnt, cTicket, aClone(aParMrp), .F., cErrorUID, RetCodUsr(), oBody["periodsSC"], oBody["periodsOP"], oBody["opInitialNumber"], , , , cRecover)

					//Verifica oorrencia de erros no PCPA145
					If oPCPError:possuiErro()
						cDetError := oPCPError:getcError(3)
						lError := .T.

						Iif(Empty(cDetError), cError := STR0022, cError := STR0023) //"Erro indeterminado. Entre em contato com o departamento de TI e solicite consulta ao console.log" "Ocorreu erro na geração dos documentos"
						GravaCV8("4", GetGlbValue("PCPA145PROCCV8"), /*cMsg*/, cDetError, "", "", NIL, GetGlbValue("PCPA145PROCIDCV8"), cFilAnt)
					EndIf
					oPCPError:destroy()

					oPCPLock:unlock("MRP_MEMORIA", "PCPA145", cTicket)
				EndIf

				PCPUnlock("PCPA145")
			EndIf
		EndIf
	EndIf

	If lError
		oJsError := JsonObject():New()
		oJsError["code"           ] := 400
		oJsError["message"        ] := cError
		oJsError["detailedMessage"] := cDetError

		aAdd(aResult, 400)
		aAdd(aResult, oJsError:ToJson())
		FreeObj(oJsError)
	Else
		aAdd(aResult, 200)
		aAdd(aResult, '{"code":"200", "ticket":"'+cTicket+'"}')
	EndIf

	FreeObj(oBody)
Return aResult

/*/{Protheus.doc} validaGera
Valida se um ticket pode iniciar o processamento da geração de documentos.

@type  Static Function
@author parffit.silva
@since 04/08/2021
@version P12.1.33
@param cTicket, Character, Ticket do MRP para validação
       cMethod, Character, Identifica método chamador "POST" ou "GET"
@return aReturn, Array   , Identifica se o ticket pode gerar os documentos e possível erro.
/*/
Static Function validaGera(cTicket, cMethod)
	Local aReturn := {.T.,""}

	If Empty(cTicket)
		aReturn[1] := .F.
		aReturn[2] := STR0019 //"Não foi informado o ticket de processamento do MRP"
	EndIf

	If aReturn[1] = .T.
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3")+cTicket))
			If cMethod = 'POST'
				If HW3->HW3_STATUS != "3"
					aReturn[1] := .F.
					aReturn[2] := STR0020 //"Somente processamentos do MRP com o status 'Finalizado' podem iniciar a geração de documentos"
				EndIf
			Else
				aReturn[2] := HW3->HW3_STATUS
			EndIf
		Else
			aReturn[1] := .F.
			aReturn[2] := STR0021 //"Ticket não encontrado nos processamentos do MRP"
		EndIf
	EndIf

Return aReturn

/*/{Protheus.doc} loadParam
Carga de parâmetros do MRP.

@type  Static Function
@author parffit.silva
@since 04/08/2021
@version P12.1.33
@param cTicket   , Caracter, Codigo único do processo
@param aParametro, Array   , Retorna por referência o array com os parâmetros do MRP.
                              Estrutura do array:
                              aParametro[nIndex][1] - ID do Registro (utilizado para exibir em tela). Sempre 0
                              aParametro[nIndex][2] -> Array
                              aParametro[nIndex][2][nIndice][1] - Descrição do parâmetro
                              aParametro[nIndex][2][nIndice][2] - Descrição do conteúdo do parâmetro
                              aParametro[nIndex][2][nIndice][3] - Código do parâmetro
                              aParametro[nIndex][2][nIndice][4] - Valor do parâmetro
@return lRet     , Lógico  , Validação do campo ticket
/*/
Static Function loadParam(cTicket, aParametro)
	Local aItems   := {}
	Local aParam   := {}
	Local cError   := ""
	Local lRet     := .T.
	Local nLenIte  := 0
	Local nX       := 0
	Local oJsonPar := JsonObject():New()

	aParam := MrpGetPar(cFilAnt, cTicket, "ticket,parameter,value,list",,,9999,"Parametros")
	cError := oJsonPar:FromJson(aParam[2])

	aSize(aParametro, 0)

	If Empty(cError)
		aItems := oJsonPar["items"]
		nLenIte := Len(aItems)

		For nX := 1 to nLenIte
			If (aItems[nX]["parameter"] == "structurePrecision";
					.Or. aItems[nX]["parameter"] == "cAutomacao";
					.Or. aItems[nX]["parameter"] == "setupCode";
					.Or. aItems[nX]["parameter"] == "cAutomacao";
					.Or. aItems[nX]["parameter"] == "ticket";
					.Or. aItems[nX]["parameter"] == "processLogs";
					.Or. aItems[nX]["parameter"] == "periodType";
					.Or. aItems[nX]["parameter"] == "demandStartDate";
					.Or. aItems[nX]["parameter"] == "demandEndDate")
				Loop
			EndIf

			aAdd(aParametro, {0, {aItems[nX]["parameter"], aItems[nX]["value"], aItems[nX]["parameter"], aItems[nX]["value"]} })
		Next nX

		aParametro := aSort(aParametro,,, { |x, y| x[2][1] < y[2][1] } )
	EndIf

	aSize(aItems, 0)
	FreeObj(oJsonPar)

Return lRet


/*/{Protheus.doc} GET RESULTS api/pcp/v1/mrpdata/results/{branchId}/{ticket}
Retorna o Resultado do processamento do MRP (HWB)

@type WSMETHOD
@author douglas.heydt
@since 09/09/2021
@version P12.1.27
@param 01 ticket  , Caracter, Codigo único do processo
@param 02 productFrom , Caracter, código inicial do filtro de produto
@param 03 productTo   , Caracter, código final do filtro de produto
@param 04 costOption  , Numeral, tipo do custo de produto
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET REPORT WSRECEIVE productFrom, productTo, costOption PATHPARAM ticket WSSERVICE mrpdata
	Local aProducts := {}
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	aReturn := getResults( Self:ticket, Self:productFrom, Self:productTo, Self:costOption)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
	aSize(aProducts, 0)

Return lRet

/*/{Protheus.doc} getResults
Busca os resultados de todos os produtos de um ticket MRP
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 cTicket  , Caracter, ticket MRP
@param 02 cProdDe  , Caracter, código inicial do filtro de produto
@param 03 cProdAte , Caracter, código final do filtro de produto
@param 04 nTpCusto , Numeral, tipo do custo de produto
/*/
Function getResults( cTicket, cProdDe, cProdAte, nTpCusto)

	Local aFiliais   := {}
	Local aResult    := {}
	Local cAliasQry  := GetNextAlias()
	Local cFiliaisIN := ""
	Local cChave     := ""
	Local cProduto   := ""
	Local cIdOpc     := ""
	Local cQuery     := ""
	Local nCusto     := 0
	Local nIndex     := 0
	Local nTotFils   := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	If Empty(cTicket)
		cFiliaisIN := "'" + xFilial("HWB") + "'"
	Else
		ticketME(cTicket, .F., , , , aFiliais)
		nTotFils := Len(aFiliais)
		If nTotFils == 0
			cFiliaisIN := "'" + xFilial("HWB") + "'"
		Else
			For nIndex := 1 To nTotFils
				If nIndex > 1
					cFiliaisIN += ","
				EndIf
				cFiliaisIN += "'" + aFiliais[nIndex][1] + "'"
			Next nIndex
		EndIf
	EndIf

	cQuery := " SELECT HWB_TICKET, "
	cQuery += "     HWB_PRODUT, "
	cQuery += "     HWB_IDOPC, "
	cQuery += "     HWB_DATA, "
	cQuery += "     SUM(HWB_QTSLES) stockBalance, "
	cQuery += "     SUM(HWB_QTENTR) inFlows, "
	cQuery += "     SUM(HWB_QTSAID) outFlows, "
	If nTotFils > 0
		cQuery += " SUM(HWB_QTRENT) inFlowTrans, SUM(HWB_QTRSAI) outFlowTrans, "
	EndIf
	cQuery += "     SUM(HWB_QTSEST) structOutFlows, SUM(HWB_QTNECE) necessity, "

	cQuery += " 	( SELECT COALESCE(SUM(HWC_QTSUBS),0) "
	cQuery += " 	   FROM "+RetSqlName("HWC")+" "
	cQuery += " 	   WHERE HWC_FILIAL  IN (" + cFiliaisIN + ") "
	cQuery += " 	     AND HWC_TICKET = '" + cTicket + "' "
	cQuery += " 	     AND HWC_PRODUT = HWB_PRODUT "
	cQuery += " 	     AND HWC_IDOPC = HWB_IDOPC "
	cQuery += " 	     AND HWC_DATA = HWB_DATA "
	cQuery += " 	     AND HWC_QTSUBS > 0 ) insubs, "
	cQuery += " 	( SELECT COALESCE(SUM(HWC_QTSUBS),0) "
	cQuery += " 	   FROM "+RetSqlName("HWC")+" "
	cQuery += " 	   WHERE HWC_FILIAL  IN (" + cFiliaisIN + ") "
	cQuery += " 	     AND HWC_TICKET = '" + cTicket + "' "
	cQuery += " 	     AND HWC_PRODUT = HWB_PRODUT "
	cQuery += " 	     AND HWC_IDOPC = HWB_IDOPC "
	cQuery += " 	     AND HWC_DATA = HWB_DATA "
	cQuery += " 	     AND HWC_QTSUBS < 0 ) outsubs, "
	cQuery += " 	( SELECT COALESCE(SUM(HWC_QTNECE),0) "
	cQuery += " 	   FROM "+RetSqlName("HWC")+" "
	cQuery += " 	   WHERE HWC_FILIAL  IN (" + cFiliaisIN + ") "
	cQuery += " 	     AND HWC_TICKET = '" + cTicket + "' "
	cQuery += " 	     AND HWC_PRODUT = HWB_PRODUT "
	cQuery += " 	     AND HWC_IDOPC = HWB_IDOPC "
	cQuery += " 	     AND HWC_DATA = HWB_DATA "
	cQuery += " 	     AND HWC_TPDCPA = '1') masterPlan "

	cQuery += " FROM " + RetSqlName("HWB")                + ;
			  " WHERE HWB_FILIAL IN (" + cFiliaisIN + ")" + ;
			  " AND HWB_TICKET = '" + cTicket + "' "

	If !Empty(cProdDe)
		cQuery += " AND HWB_PRODUT >= '"+cProdDe+"'"
	EndIf

	If !Empty(cProdAte)
		cQuery += " AND HWB_PRODUT <= '"+cProdAte+"'"
	EndIf

	cQuery += " AND D_E_L_E_T_ = ' '"                     + ;
			  " GROUP BY HWB_TICKET, HWB_PRODUT, HWB_IDOPC, HWB_DATA"

	cQuery += " ORDER BY HWB_PRODUT,HWB_IDOPC, HWB_DATA "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'HWB_DATA', 'D', GetSx3Cache("HWB_DATA", "X3_TAMANHO"), 0)

	oJson["items"] := {}
	While (cAliasQry)->(!Eof())
		IF cProduto+cIdOpc != (cAliasQry)->HWB_PRODUT+(cAliasQry)->HWB_IDOPC
			aAdd(oJson["items"], JsonObject():New())
			nPos++
			cProduto := (cAliasQry)->HWB_PRODUT
			nCusto   := GetCost((cAliasQry)->HWB_PRODUT, nTpCusto)
			cIdOpc   := (cAliasQry)->HWB_IDOPC
			oJson["items"][nPos]["results"] := Array(N_TAM_ARRAY_TIPOS)
			oJson["items"][nPos]["results"][N_POS_ESTOQUE         ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_ENTRADAS        ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SAIDAS          ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SAIDA_ESTRUTURA ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SUBSTITUICAO    ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SALDO_FINAL     ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_NECESSIDADE     ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_VALOR_NECESS    ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_VALOR_ESTOQUE   ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_QUANT_PMP       ] := JsonObject():New()
		EndIf

		cChave := DTOS((cAliasQry)->HWB_DATA)
		oJson["items"][nPos]["results"][N_POS_ESTOQUE         ][cChave] := (cAliasQry)->stockBalance
		oJson["items"][nPos]["results"][N_POS_ENTRADAS        ][cChave] := (cAliasQry)->inFlows + (cAliasQry)->masterPlan
		oJson["items"][nPos]["results"][N_POS_SAIDAS          ][cChave] := (cAliasQry)->outFlows - (cAliasQry)->masterPlan
		If nTotFils > 0
			oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ][cChave] := (cAliasQry)->inFlowTrans
			oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ][cChave] := (cAliasQry)->outFlowTrans
		Else
			oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ][cChave] := 0
			oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ][cChave] := 0
		EndIf
		oJson["items"][nPos]["results"][N_POS_SAIDA_ESTRUTURA ][cChave] := (cAliasQry)->structOutFlows
		oJson["items"][nPos]["results"][N_POS_SUBSTITUICAO    ][cChave] := (cAliasQry)->insubs

		oJson["items"][nPos]["results"][N_POS_SALDO_FINAL     ][cChave] := oJson["items"][nPos]["results"][N_POS_ESTOQUE         ][cChave] + ;
		                                                                   oJson["items"][nPos]["results"][N_POS_ENTRADAS        ][cChave] - ;
												                           oJson["items"][nPos]["results"][N_POS_SAIDAS          ][cChave] + ;
												                           oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ][cChave] - ;
												                           oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ][cChave] - ;
												                           oJson["items"][nPos]["results"][N_POS_SAIDA_ESTRUTURA ][cChave]
		oJson["items"][nPos]["results"][N_POS_NECESSIDADE     ][cChave]  := (cAliasQry)->necessity
		oJson["items"][nPos]["results"][N_POS_VALOR_NECESS    ][cChave]  := (cAliasQry)->necessity*nCusto
		oJson["items"][nPos]["results"][N_POS_VALOR_ESTOQUE   ][cChave]  := custoEstoq( oJson["items"][nPos]["results"][N_POS_SALDO_FINAL     ][cChave], ;
		                                                                                 ((cAliasQry)->outFlows - (cAliasQry)->masterPlan)             , ;
																						 (cAliasQry)->structOutFlows                                   , ;
																						 (cAliasQry)->stockBalance                                     , ;
																						 ((cAliasQry)->inFlows + (cAliasQry)->masterPlan)              , ;
																						nCusto)
		oJson["items"][nPos]["results"][N_POS_QUANT_PMP       ][cChave]  := (cAliasQry)->masterPlan
		oJson["items"][nPos]["product"] := cProduto
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	oJson["periods"] := {}
    oJson["periods"] := getPeriods(cTicket)

	dbSelectArea("HWB")
	oJson["transfers"] := JsonObject():New()
	If FieldPos("HWB_QTRENT") > 0 .And. FieldPos("HWB_QTRSAI") > 0
    	getTransf(cTicket, oJson["transfers"], cProdDe, cProdAte)
	EndIf
	dbclosearea()
	fillDates(oJson)

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf
	aSize(aFiliais, 0)

	aSize(oJson["periods"], 0)
	aSize(oJson["items"], 0)

	FreeObj(oJson)
	oJson := Nil

Return aResult


/*/{Protheus.doc} fillDates
Função responsável por preencher as datas que não tem resultado do MRP para cada produto.
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 oJson, JSON, Json contendo os resultados do MRP
/*/
Static Function fillDates(oJson)

	Local cPeriod    := ""
	Local cPrevDate  := ""
	Local nFirstDate := 0
	Local nIndPer    := 2// indice inicia no 2 pois a primeira posição é o identificar 'Períodos'
	Local nIndRes    := 1
	Local nTotRes    := Len(oJson["items"])
	Local nTotPer    := Len(oJson["periods"])

	For nIndRes := 1 To nTotRes
		For nIndPer := 2 To nTotPer
			cPeriod := oJson["periods"][nIndPer]
			IF !oJson["items"][nIndRes]["results"][N_POS_ESTOQUE]:HasProperty(cPeriod)
				If nIndPer == 2
					nFirstDate := getFrstDat(oJson, nIndRes)
					oJson["items"][nIndRes]["results"][N_POS_ESTOQUE    ][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_ESTOQUE][nFirstDate]
					oJson["items"][nIndRes]["results"][N_POS_SALDO_FINAL][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_ESTOQUE][nFirstDate]
				Else
					cPrevDate := oJson["periods"][nIndPer -1]
					oJson["items"][nIndRes]["results"][N_POS_ESTOQUE    ][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_SALDO_FINAL][cPrevDate] + (oJson["items"][nIndRes]["results"][N_POS_NECESSIDADE][cPrevDate] - oJson["items"][nIndRes]["results"][N_POS_QUANT_PMP][cPrevDate])
					oJson["items"][nIndRes]["results"][N_POS_SALDO_FINAL][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_ESTOQUE    ][cPeriod]
				EndIf

				oJson["items"][nIndRes]["results"][N_POS_ENTRADAS       ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_SAIDAS         ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_TRANSF_ENTRADA ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_TRANSF_SAIDA   ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_SAIDA_ESTRUTURA][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_SUBSTITUICAO   ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_NECESSIDADE    ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_VALOR_NECESS   ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_VALOR_ESTOQUE  ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_QUANT_PMP      ][cPeriod] := 0
			EndIf
		Next nIndPer
	Next nIndRes
Return


/*/{Protheus.doc} getFrstDat
Retorna a primeira data com resultados no array de resultados do MRP para um produto
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 oJson   , JSON    , Json contendo os resultados do MRP
@param 02 nProdPos, numérico, Posição do produto no array de resultados
@return cFirstDate, caracter, primeira data do produto que tem resultado
/*/
Static Function getFrstDat(oJson, nProdPos)

	Local cFirstDate := ""
	Local nIndex     := 2 // indice inicia no 2 pois a primeira posição é o identificar 'Períodos'

	For nIndex := 2 To Len(oJson["periods"])
		IF oJson["items"][nProdPos]["results"][N_POS_ESTOQUE         ]:HasProperty(oJson["periods"][nIndex])
			cFirstDate := oJson["periods"][nIndex]
			Exit
		EndIf
	Next nIndex

Return cFirstDate

/*/{Protheus.doc} getPeriods
Busca os períodos resultantes no cálculo do MRP
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 cTicket, Caracter, ticket MRP dos quais serão buscados os período
@return aPeriods, Array, Array com os periodos do ticket informado
/*/
Function getPeriods(cTicket)
	Local aPeriods := {}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""

	cQuery := " select DISTINCT HWB_DATA from "+RetSqlName("HWB")+" where HWB_TICKET = '"+cTicket+"' ORDER BY HWB_DATA"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	aAdd(aPeriods, STR0025)//"Período"

	WHILE (cAliasQry)->(!Eof())
		aAdd(aPeriods, (cAliasQry)->HWB_DATA)
		(cAliasQry)->(dbSkip())
	END
	(cAliasQry)->(dbCloseArea())

return aPeriods

/*/{Protheus.doc} getTransf
Busca todas as transferencias realizadas no mesmo ticket
@type  Function
@author douglas.heydt
@since 20/09/2021
@version P12.1.30
@param 01 cTicket, Caracter, ticket MRP dos quais serão buscadas as transferencias
@param 02 oJson, Obejct, objeto json que irá conter as transferencias
@param 03 cProdDe  , Caracter, código inicial do filtro de produto
@param 04 cProdAte , Caracter, código final do filtro de produto
@param 05 nTpCusto , Numeral, tipo do custo de produto
/*/
Function getTransf(cTicket, oJson, cProdDe, cProdAte)

	Local aTransfers := {}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0

	cQuery := " SELECT HWB_FILIAL, HWB_TICKET, HWB_DATA, HWB_PRODUT, HWB_QTRENT, 0 AS HWB_QTRSAI "
	cQuery += " FROM "+RetSqlName("HWB")+" "
	cQuery += " WHERE HWB_TICKET = '"+cTicket+"'  AND  HWB_QTRENT > 0 "
	If !Empty(cProdDe)
		cQuery += " AND HWB_PRODUT >= '"+cProdDe+"'"
	EndIf
	If !Empty(cProdAte)
		cQuery += " AND HWB_PRODUT <= '"+cProdAte+"'"
	EndIf
	cQuery += " UNION "
	cQuery += " SELECT HWB_FILIAL, HWB_TICKET, HWB_DATA, HWB_PRODUT, 0 AS HWB_QTRENT, HWB_QTRSAI "
	cQuery += " FROM "+RetSqlName("HWB")+"  "
	cQuery += " WHERE HWB_TICKET = '"+cTicket+"'  AND HWB_QTRSAI > 0 "
	If !Empty(cProdDe)
		cQuery += " AND HWB_PRODUT >= '"+cProdDe+"'"
	EndIf
	If !Empty(cProdAte)
		cQuery += " AND HWB_PRODUT <= '"+cProdAte+"'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	WHILE (cAliasQry)->(!Eof())
		If 	oJson[(cAliasQry)->HWB_PRODUT] == Nil
			oJson[(cAliasQry)->HWB_PRODUT] := {}
		EndIf

		aAdd(oJson[(cAliasQry)->HWB_PRODUT], JsonObject():New())
		nPos := Len(oJson[(cAliasQry)->HWB_PRODUT])
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_FILIAL"] := (cAliasQry)->HWB_FILIAL+'-'+FwFilialName(cEmpAnt,(cAliasQry)->HWB_FILIAL)
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_DATA"]   := (cAliasQry)->HWB_DATA
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_PRODUT"] := (cAliasQry)->HWB_PRODUT
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_QTRSAI"] := (cAliasQry)->HWB_QTRSAI
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_QTRENT"] := (cAliasQry)->HWB_QTRENT

		(cAliasQry)->(dbSkip())
	END
	(cAliasQry)->(dbCloseArea())

return aTransfers

/*/{Protheus.doc} getProds
Retorna o Resultado de todos os produtos para um ticket MRP

@type Function
@author douglas.heydt
@since 03/05/2021
@version P12.1.27
@param 01 cTicket , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 cProduct, Caracter, Código do produto
@param 03 cProdDe , Caracter, Código inicial do filtro de produto
@param 04 cProdAte, Caracter, Código final do filtro de produto
@param 05 nTpCusto, Numeral , Tipo do custo de produto
@param 06 cIdOpc  , Caracter, ID Opcional do produto
@param 07 lAllFils, Lógico  , Indica se deve retornar as informações dos produtos de todas as filiais
@return    aResult, Array   , Array com as informacoes da requisicao
/*/
Function getProds(cTicket, cProduct, cProdDe, cProdAte, nTpCusto, cIdOpc, lAllFils)
	Local aFiliais   := {}
	Local aResult 	 := {.F., EncodeUTF8(STR0016), 400} //"Não existem registros para atender os filtros informados"
	Local cAliasQry  := GetNextAlias()
	Local cAglutina  := ""
	Local cArqProd   := arqProdTkt(cTicket)
	Local cBanco     := Upper(TCGETDB())
	Local cQuery     := ""
	Local cFilPrinci := ""
	Local lAddAglut  := .F.
	Local lAgluMrp   := .F.
	Local lDefInHWD  := .F.
	Local lMultiEmp  := .F.
	Local nPos       := 0
	Local oDominio   := Nil
	Local oJson      := JsonObject():New()
	Local oParametro := Nil

	Default cIdOpc   := ""
	Default lAllFils := .F.

	lDefInHWD := !Empty(GetSx3Cache("HWD_DEFAUL", "X3_TAMANHO"))

	DbSelectArea("HWB")
	lAgluMrp := (FieldPos("HWB_AGLPRD") > 0)

	If lAgluMrp .And. _oDescAgl == Nil
		_oDescAgl := JsonObject():New()
		_oDescAgl["0"] := ""
		_oDescAgl["1"] := STR0058 //"Diário"
		_oDescAgl["2"] := STR0059 //"Semanal"
		_oDescAgl["3"] := STR0060 //"Quinzenal"
		_oDescAgl["4"] := STR0061 //"Mensal"
	EndIf

	lMultiEmp := ticketME(cTicket, .T., @oParametro, @oDominio, , aFiliais) .And. Len(aFiliais) > 0
	If lMultiEmp
		cFilPrinci := RTrim(oParametro["branchCentralizing"])
	Else
		cFilPrinci := xFilial("HWB")
	EndIf

	cQuery := "SELECT DISTINCT HWB.HWB_FILIAL branchId,"
	cQuery +=                " HWA.HWA_PROD   product,"
	cQuery +=                " HWA.HWA_DESC   productDescription,"
	cQuery +=                " HWA.HWA_TIPO   productType,"
	cQuery +=                " HWB.HWB_IDOPC  optionalId,"

	If cArqProd == "SBZ"
		cQuery += " COALESCE(HWE.HWE_LOCPAD, HWA.HWA_LOCPAD) warehouse,"
		cQuery += " COALESCE(HWE.HWE_QE, HWA.HWA_QE) packing,"
		cQuery += " COALESCE(HWE.HWE_PE, HWA.HWA_PE) deliveryLeadTime,"
		cQuery += " CASE COALESCE(HWE.HWE_TIPE, HWA.HWA_TIPE)"
		cQuery +=    " WHEN '1' THEN '" + STR0028 + "'"
		cQuery +=    " WHEN '2' THEN '" + STR0029 + "'"
		cQuery +=    " WHEN '3' THEN '" + STR0030 + "'"
		cQuery +=    " WHEN '4' THEN '" + STR0031 + "'"
		cQuery +=    " WHEN '5' THEN '" + STR0032 + "'"
		cQuery +=    " ELSE '-'"
		cQuery += " END deadlineType,"
		cQuery += " COALESCE(HWE.HWE_LM, HWA.HWA_LM) minimumLotSize,"
		cQuery += " COALESCE(HWE.HWE_LE, HWA.HWA_LE) economicLotSize,"
		cQuery += " COALESCE(HWE.HWE_ESTSEG, HWA.HWA_ESTSEG) safetyStock,"
		cQuery += " COALESCE(HWE.HWE_EMIN, HWA.HWA_EMIN) orderPoint,"
	Else
		cQuery += " HWA.HWA_LOCPAD warehouse,"
		cQuery += " HWA.HWA_QE packing,"
		cQuery += " HWA.HWA_PE deliveryLeadTime,"
		cQuery += " CASE HWA.HWA_TIPE"
		cQuery +=    " WHEN '1' THEN '" + STR0028 + "'"
		cQuery +=    " WHEN '2' THEN '" + STR0029 + "'"
		cQuery +=    " WHEN '3' THEN '" + STR0030 + "'"
		cQuery +=    " WHEN '4' THEN '" + STR0031 + "'"
		cQuery +=    " WHEN '5' THEN '" + STR0032 + "'"
		cQuery +=    " ELSE '-'"
		cQuery += " END deadlineType,"
		cQuery += " HWA.HWA_LM minimumLotSize,"
		cQuery += " HWA.HWA_LE economicLotSize,"
		cQuery += " HWA.HWA_ESTSEG safetyStock,"
		cQuery += " HWA.HWA_EMIN orderPoint,"
	EndIf

	cQuery += " HWA.HWA_UM unity"

	If lDefInHWD
		cQuery += ", HWD.HWD_DEFAUL opcIsDefault"
	EndIf

	If lAgluMrp
		If lAllFils
			cQuery +=", SMI.MI_AGLUMRP aglMRP"
		Else
			cQuery +=",( SELECT"
			If "MSSQL" $ cBanco //Tratativa para retornar 1° registro encontrado na query.
				cQuery += " TOP 1"
			EndIf
			cQuery += " HWB_AGLPRD"
			cQuery += " FROM " +RetSqlName("HWB") + " HWBAGL"

			If lMultiEmp
				cQuery += " WHERE HWBAGL.HWB_FILIAL " + oDominio:oMultiEmp:queryFilial("HWB", "", .F.)
			Else
				cQuery += " WHERE HWBAGL.HWB_FILIAL = '" + cFilPrinci + "'"
			EndIf

			cQuery += " AND HWBAGL.HWB_TICKET = '" + cTicket + "'"
			cQuery += " AND HWBAGL.HWB_PRODUT = HWB.HWB_PRODUT"
			cQuery += " AND HWBAGL.HWB_IDOPC  = HWB.HWB_IDOPC"
			cQuery += " AND HWBAGL.HWB_AGLPRD NOT IN(' ', '0')"

			If cBanco == "ORACLE" //Tratativa para retornar 1° registro encontrado na query.
				cQuery += " AND ROWNUM = 1"
			EndIf
			If cBanco == "POSTGRES" //Tratativa para retornar 1° registro encontrado na query.
				cQuery += " LIMIT 1"
			EndIf
			cQuery += ") aglMRP"
		EndIf
	EndIf

	cQuery += " FROM " + RetSqlName("HWA") + " HWA"
	cQuery += " LEFT JOIN " + RetSqlName("HWB") + " HWB"
	cQuery +=   " ON HWA.HWA_PROD = HWB.HWB_PRODUT"
	cQuery +=  " AND HWB.D_E_L_E_T_ = ' '"
	cQuery +=  " AND HWB.HWB_TICKET = '" + cTicket + "'"
	If !Empty(cIdOpc)
		cQuery += " AND HWB_IDOPC = '" + RTrim(cIdOpc) + "' "
	EndIf
	If lMultiEmp .And. lAllFils
		cQuery += " AND HWB.HWB_FILIAL " + oDominio:oMultiEmp:queryFilial("HWB", "", .F.)
		If lAgluMrp
			cQuery += " LEFT JOIN " +RetSqlName("SMI") + " SMI" + ;
			             " ON SMI.MI_FILIAL  = HWB.HWB_FILIAL"   + ;
			            " AND SMI.MI_PRODUTO = HWB.HWB_PRODUT"   + ;
			            " AND SMI.MI_AGLUMRP <> ' '"             + ;
			            " AND SMI.D_E_L_E_T_ = ' '"
		EndIf
	Else
		cQuery += " AND HWB.HWB_FILIAL = '" + xFilial("HWB", cFilPrinci) + "'"
	EndIf

	If cArqProd == "SBZ"
		cQuery += " LEFT JOIN " + RetSqlName("HWE") + " HWE"
		cQuery +=   " ON ( ( HWB.HWB_FILIAL IS NOT NULL AND HWE.HWE_FILIAL = HWB.HWB_FILIAL) "
		cQuery +=    " OR (HWB.HWB_FILIAL IS NULL AND HWE.HWE_FILIAL = '"+ xFilial("HWE", cFilPrinci) +"'))"
		cQuery +=  " AND HWE.HWE_PROD = HWB.HWB_PRODUT"
		cQuery +=  " AND HWE.D_E_L_E_T_ = ' '"
	EndIf

	If lDefInHWD
		cQuery += " LEFT OUTER JOIN " + RetSqlName("HWD") + " HWD"
		cQuery +=   " ON HWD.HWD_TICKET = HWB.HWB_TICKET"
		cQuery +=  " AND HWD.HWD_FILIAL = HWB.HWB_FILIAL"
		cQuery +=  " AND HWD.HWD_KEYMAT = HWB.HWB_IDOPC"
	EndIf

	If lMultiEmp .And. lAllFils
		cQuery += " WHERE HWA.HWA_FILIAL " + oDominio:oMultiEmp:queryFilial("HWA", "", .F.)
	Else
		cQuery += " WHERE HWA.HWA_FILIAL = '" + xFilial("HWA", cFilPrinci) + "'"
	EndIf
	cQuery +=       " AND HWA.D_E_L_E_T_ = ' '"


	If !Empty(cProduct)
		cQuery +=   " AND HWA.HWA_PROD = '" + cProduct + "'"
    Else
		If !Empty(cProdDe)
		    cQuery += " AND HWA.HWA_PROD >= '" + cProdDe + "'"
		EndIf
		If !Empty(cProdAte)
			cQuery += " AND HWA.HWA_PROD <= '" + cProdAte + "'"
		EndIf
	EndIf

	cQuery += " ORDER BY branchId, product"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oJson["items"] := {}
	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
        nPos++

		oJson["items"][nPos]["branchId"          ] := RTRIM((cAliasQry)->branchId)
		oJson["items"][nPos]["product"           ] := RTRIM((cAliasQry)->product)
		oJson["items"][nPos]["productDescription"] := AllTrim((cAliasQry)->productDescription)
		oJson["items"][nPos]["productType"       ] := (cAliasQry)->productType
		oJson["items"][nPos]["packing"           ] := (cAliasQry)->packing
		oJson["items"][nPos]["deliveryLeadTime"  ] := (cAliasQry)->deliveryLeadTime
		oJson["items"][nPos]["deadlineType"      ] := (cAliasQry)->deadlineType
		oJson["items"][nPos]["warehouse"         ]  := (cAliasQry)->warehouse

		If Empty(oJson["items"][nPos]["branchId"])
			oJson["items"][nPos]["branchId"] := cFilPrinci
		EndIf

		If Empty((cAliasQry)->optionalId)
			oJson["items"][nPos]["optionalSelected"] := STR0054 //"Não"
			oJson["items"][nPos]["hasOptional"] := .F.
		Else
			oJson["items"][nPos]["optionalSelected"] := STR0053 //"Sim"
			oJson["items"][nPos]["hasOptional"] := .T.
		EndIf
		oJson["items"][nPos]["optional"] := (cAliasQry)->optionalId

		oJson["items"][nPos]["minimumLotSize" ] := (cAliasQry)->minimumLotSize
		oJson["items"][nPos]["economicLotSize"] := (cAliasQry)->economicLotSize

		If !lDefInHWD .Or. (lDefInHWD .And. (cAliasQry)->opcIsDefault == "S") .Or. Empty((cAliasQry)->opcIsDefault)
			oJson["items"][nPos]["safetyStock"] := (cAliasQry)->safetyStock
			oJson["items"][nPos]["orderPoint" ] := (cAliasQry)->orderPoint
		Else
			oJson["items"][nPos]["safetyStock"] := 0
			oJson["items"][nPos]["orderPoint" ] := 0
		EndIf

		oJson["items"][nPos]["unity"] := (cAliasQry)->unity
		oJson["items"][nPos]["value"] := GetCost((cAliasQry)->product, nTpCusto)

		If lAgluMrp .And. !Empty((cAliasQry)->aglMrp)
			cAglutina := (cAliasQry)->aglMrp
			If lAllFils
				cAglutina := cValToChar( Val(cAglutina)-1 )
			Endif

			oJson["items"][nPos]["agglutinateMRP"] := _oDescAgl[cAglutina]
			lAddAglut := .T.
		Else
			oJson["items"][nPos]["agglutinateMRP"] := ""
		EndIf

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	oJson["headers"] := {}
	addHeader(oJson["headers"], lAddAglut)

	oJson["usesProductIndicator"] := cArqProd == "SBZ"

	If !Empty(nTpCusto) .And.ExistBlock("MRPEDITEXP")
		ExecBlock("MRPEDITEXP", .F., .F., {cTicket, oJson})
	EndIf

	If Len(oJson["items"]) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

	If lMultiEmp
		oDominio:oDados:destruir()
		FreeObj(oDominio)
		FreeObj(oParametro)
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)
	aSize(aFiliais, 0)

Return aResult

/*/{Protheus.doc} addHeader
Preenche o array com o cabeçalho

@type Static Function
@author marcelo.neumann
@since 08/08/2022
@version P12
@param 01 aHeaders , Array, Header a ser preenchido
@param 02 lAddAglut, Logic, Indica se deve adicionar opção de "Aglutina MRP"
/*/
Static Function addHeader(aHeaders, lAddAglut)
	Local nIndex := 0

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "product"
	aHeaders[nIndex]["label"] := STR0035 //"Produto"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "productDescription"
	aHeaders[nIndex]["label"] := STR0036 //"Descrição"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "productType"
	aHeaders[nIndex]["label"] := STR0037 //"Tipo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "packing"
	aHeaders[nIndex]["label"] := STR0038 //"Embalagem"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "deliveryLeadTime"
	aHeaders[nIndex]["label"] := STR0039 //"Lead Time"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "deadlineType"
	aHeaders[nIndex]["label"] := STR0040 //"Tipo Prazo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "warehouse"
	aHeaders[nIndex]["label"] := STR0041 //"Armazém"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "optionalSelected"
	aHeaders[nIndex]["label"] := STR0042 //"Opcional"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "minimumLotSize"
	aHeaders[nIndex]["label"] := STR0043 //"Lote Mínimo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "economicLotSize"
	aHeaders[nIndex]["label"] := STR0044 //"Lote Econômico"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "safetyStock"
	aHeaders[nIndex]["label"] := STR0045 //"Estoque Segurança"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "orderPoint"
	aHeaders[nIndex]["label"] := STR0046 //"Ponto Pedido"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "unity"
	aHeaders[nIndex]["label"] := STR0047 //"Unidade de Medida"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "value"
	aHeaders[nIndex]["label"] := STR0048 //"Valor"

	If lAddAglut
		aAdd(aHeaders, JsonObject():New())
		nIndex++
		aHeaders[nIndex]["id"]    := "agglutinateMRP"
		aHeaders[nIndex]["label"] := STR0062 //"Aglutina MRP"
	EndIf

Return Nil

/*/{Protheus.doc} GetPrdCost
Busca o custo de um produto considerando o parametro MV_CUSTPRD
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 cProduct, Caracter, produto que terá o custo buscado
@param 02 nTpCusto , Numeral, tipo do custo de produto
/*/
Function GetCost(cProduct, nTpCusto)
	Local aAreaSB1 	 := SB1->(GetArea())
	Local nCusto     := 0
	Local nTipoCusto := Iif(!Empty(nTpCusto), nTpCusto, SuperGetMv("MV_CUSTPRD",.F.,1))

	cProduct := Padr(cProduct, GetSx3Cache("B1_COD", "X3_TAMANHO"))
	SB1->(MsSeek(xFilial("SB1") + cProduct))
	If nTipoCusto == 1
		nCusto := RetFldProd(cProduct,"B1_CUSTD")
	ElseIf nTipoCusto == 2
		nCusto := PegaCmAtu(cProduct, RetFldProd(cProduct,"B1_LOCPAD"))[1]
	ElseIf nTipoCusto == 3
		nCusto := RetFldProd(cProduct,"B1_UPRC")
	EndIf

	RestArea( aAreaSB1 )

Return nCusto

/*/{Protheus.doc} GET PERIODS api/pcp/v1/mrpdata/periods/{ticket}
Retorna os períodos considerados em uma rodada do MRP

@type WSMETHOD
@author renan.roeder
@since 14/01/2022
@version P12.1.37
@param 01 ticket  , Caracter, Codigo único do processo
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PERIODS PATHPARAM ticket WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	aReturn := getPerRes( Self:ticket)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet


/*/{Protheus.doc} getPerRes
Monta o json que retornará os períodos de uma rodada do MRP
@type  Function
@author renan.roeder
@since 14/01/2022
@version P12.1.37
@param 01 cTicket, Caracter, ticket MRP
@return aResult, Array, Array com as informacoes da requisicao
/*/
Function getPerRes(cTicket)
	Local aResult    := {}
	Local aParMrp    := {}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPosType   := 0
	Local nPosRast   := 0
	Local nContPer   := 0
	Local oJson      := JsonObject():New()

	loadParam(cTicket, @aParMrp)
	nPosType := aScan(aParMrp, {|x| AllTrim(x[2][3]) == "productionOrderType"})
	nPosRast := aScan(aParMrp, {|x| AllTrim(x[2][3]) == "lRastreiaEntradas"})

	oJson["usaRast"] := .F.
	If nPosRast > 0 .And. aParMrp[nPosRast][2][4] == "1"
		oJson["usaRast"] := .T.
	EndIf

	cQuery := " select DISTINCT HWB_DATA from "+RetSqlName("HWB")+" where HWB_TICKET = '"+cTicket+"' ORDER BY HWB_DATA"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oJson["items"] := {}
	While (cAliasQry)->(!Eof())
		nContPer++
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nContPer]["period"] := convDate((cAliasQry)->HWB_DATA, 4)
		oJson["items"][nContPer]["type"]   := aParMrp[nPosType][2][4]
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJson())
		aAdd(aResult, 400)
	EndIf

	aSize(aParMrp,0)
    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET SUBSALT api/pcp/v1/mrpdata/subst/alt
Recupera os produtos alternativos a partir de um produto original

@type WSMETHOD
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 ticket      , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 product     , Caracter, Produto substituído
@param 03 optionalId  , Caracter, ID do Opcional
@param 04 periodFrom  , Caracter, data inicial de busca de substituições
@param 05 periodTo    , Caracter, data final de busca de substituições
@parma 06 page        , number  , Número da página para consulta
@parma 07 pageSize    , number  , Quantidade de registros por página
@return lRet, Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET SUBSALT QUERYPARAM ticket, product, optionalId, periodFrom, periodTo, Page, PageSize  WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")
	//Chama a funcao para retornar os dados.
	aReturn := getSubsAlt(Self:ticket, Self:product, Self:optionalId, Self:periodFrom, Self:periodTo, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getSubsAlt
Recupera os produtos alternativos a partir de um produto original

@type  Static Function
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 cTicket     , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 cProduto    , Caracter, Produto substituído
@param 03 cIdOpc      , Caracter, ID do Opcional
@param 04 cPerDe      , Caracter, data inicial de busca de substituições
@param 05 cPerAte     , Caracter, data final de busca de substituições
@parma 06 nPage       , number  , Número da página para consulta
@parma 07 npageSize   , number  , Quantidade de registros por página
@return aResult, Array, Array com os dados da consulta
/*/
Static Function getSubsAlt(cTicket, cProduto, cIdOpc, cPerDe, cPerAte, nPage, nPageSize)
	Local aResult   := {.F., "", 204}
	Local aValFil   := getFilMRP(cTicket, "HWC")
	Local cAlias    := ""
	Local cBanco    := AllTrim(TcGetDB())
	Local cQuery    := ""
	Local lUsaME    := Len(aValFil) > 1
	Local nIndex    := 0
	Local nStart    := 0
	Local oExec     := Nil
	Local oJson     := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	cQuery := " SELECT HWC.HWC_FILIAL,"
	cQuery +=        " HWC.HWC_PRODUT,"
	cQuery +=        " HWC.HWC_DATA,"
	cQuery +=        " HWC.HWC_DOCPAI,"
	cQuery +=        " HWC.HWC_QTSBVL,"
	cQuery +=        " HWC.HWC_QTSUBS,"
	cQuery +=        " HWC.HWC_QTEMPE,"
	cQuery +=        " HWC.HWC_QTNECE"
	cQuery +=   " FROM " + RetSqlName("HWC") + " HWC"
	cQuery +=  " WHERE HWC.HWC_FILIAL IN (?)"
	cQuery +=    " AND HWC.HWC_TICKET = ?"
	cQuery +=    " AND HWC.HWC_DATA  >= ?"
	cQuery +=    " AND HWC.HWC_DATA  <= ?"
	cQuery +=    " AND HWC.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND HWC.HWC_CHVSUB IN(SELECT "

	If cBanco == "ORACLE"
		cQuery += " RPAD("//RPAD para padronizar o tamanho da string para banco ORACLE
	EndIf

	//Caso seja Multi-empresa, concatena o código da filial a chave do registro do produto original
	If lUsaME .And. cBanco == "POSTGRES"
		//Para banco POSTGRES utiliza o comando CONCAT
		cQuery +=                                  " TRIM(CONCAT(HWC_ORI.HWC_FILIAL, "
	ElseIf lUsaME
		//Para demais bancos concatena com || ou +
		cQuery +=                                  " HWC_ORI.HWC_FILIAL || "
	EndIf

	If Empty(cIdOpc)
		cQuery +=                                  " HWC_ORI.HWC_CHAVE"
	Else
		//Quando existe ID Opcional, adiciona o IDOPC antes do número do período no valor da coluna HWC_CHAVE.
		//SUBSTR de HWC_CHAVE, contendo até o caractere onde está posicionado o número do período
		cQuery +=                                  " SUBSTR(HWC_CHAVE, 1, LENGTH(RTRIM(HWC_CHAVE)) - "
		cQuery +=                                                       " LENGTH(RTRIM(LTRIM( REPLACE( HWC_CHAVE, RTRIM(HWC_PRODUT),'')))))"
		//Concatena o separador | com o HWC_IDOPC
		cQuery +=                                  " || '|' || RTRIM(HWC_IDOPC) "
		//Concatena o número do período após o HWC_IDOPC
		cQuery +=                                  " || LTRIM(REPLACE(HWC_CHAVE, RTRIM(HWC_PRODUT),''))"
	EndIf

	//Se multi-empresa e banco POSTGRES, fecha o ) do comando CONCAT e do TRIM.
	If lUsaME .And. cBanco == "POSTGRES"
		cQuery += "))"
	EndIf

	If cBanco == "ORACLE"
		cQuery += ", LENGTH(HWC_CHAVE))" //Parâmetro do RPAD com o tamanho da string.
	EndIf

	cQuery +=                            " FROM " + RetSqlName("HWC") + " HWC_ORI"
	cQuery +=                           " WHERE HWC_ORI.HWC_FILIAL = HWC.HWC_FILIAL"
	cQuery +=                             " AND HWC_ORI.HWC_TICKET = HWC.HWC_TICKET"
	cQuery +=                             " AND HWC_ORI.HWC_DATA   = HWC.HWC_DATA"
	cQuery +=                             " AND HWC_ORI.HWC_PRODUT = ?"
	cQuery +=                             " AND HWC_ORI.HWC_IDOPC  = ?"
	cQuery +=                             " AND HWC_ORI.D_E_L_E_T_ = ' ')"
	cQuery +=  " ORDER BY HWC.HWC_DATA, HWC.HWC_FILIAL, HWC.HWC_PRODUT"

	If "MSSQL" $ cBanco
		//Faz adequações na query para o banco SQL SERVER.
		cQuery := StrTran(cQuery, "||", "+") //Troca concatenação
		cQuery := StrTran(cQuery, "LENGTH", "LEN") //Troca função LENGTH por LEN
		cQuery := StrTran(cQuery, "SUBSTR", "SUBSTRING") //Troca função SUBSTR por SUBSTRING
	EndIf

	oExec  := FwExecStatement():New(cQuery)

	If Empty(cPerDe)
		cPerDe := " "
	EndIf
	If Empty(cPerAte)
		cPerAte := "ZZZZZZZZ"
	EndIf
	If Empty(cIdOpc)
		cIdOpc := " "
	EndIf

	cPerDe  := convDate(cPerDe, 2)
	cPerAte := convDate(cPerAte, 2)

	oExec:SetIn(1    , aValFil ) //HWC_FILIAL IN(xxx)
	oExec:SetString(2, cTicket ) //HWC_TICKET = cTicket
	oExec:SetString(3, cPerDe  ) //HWC_DATA >= cPerDe
	oExec:SetString(4, cPerAte ) //HWC_DATA <= cPerAte
	oExec:SetString(5, cProduto) //HWC_PRODUT = cProduto
	oExec:SetString(6, cIdOpc  ) //HWC_IDOPC = cIdOpc

	cAlias := oExec:OpenAlias()

	TcSetField(cAlias, 'HWC_DATA'  , 'D', GetSx3Cache("HWC_DATA"  , "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'HWC_QTSBVL', 'N', GetSx3Cache("HWC_QTSBVL", "X3_TAMANHO"), GetSx3Cache("HWC_QTSBVL", "X3_DECIMAL"))
	TcSetField(cAlias, 'HWC_QTSUBS', 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS", "X3_DECIMAL"))
	TcSetField(cAlias, 'HWC_QTEMPE', 'N', GetSx3Cache("HWC_QTEMPE", "X3_TAMANHO"), GetSx3Cache("HWC_QTEMPE", "X3_DECIMAL"))
	TcSetField(cAlias, 'HWC_QTNECE', 'N', GetSx3Cache("HWC_QTNECE", "X3_TAMANHO"), GetSx3Cache("HWC_QTNECE", "X3_DECIMAL"))

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}
	nIndex         := 0
	While (cAlias)->(!Eof())

		nIndex++
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nIndex]["branchId"    ] := (cAlias)->HWC_FILIAL
		oJson["items"][nIndex]["product"     ] := (cAlias)->HWC_PRODUT
		oJson["items"][nIndex]["period"      ] := convDate((cAlias)->HWC_DATA, 1)
		oJson["items"][nIndex]["document"    ] := (cAlias)->HWC_DOCPAI
		oJson["items"][nIndex]["originalQty" ] := -(cAlias)->HWC_QTSBVL
		oJson["items"][nIndex]["substitution"] := -(cAlias)->HWC_QTSUBS
		oJson["items"][nIndex]["allocation"  ] := (cAlias)->HWC_QTEMPE
		oJson["items"][nIndex]["necessity"   ] := (cAlias)->HWC_QTNECE

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If nIndex >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAlias)->(!Eof())

	(cAlias)->(dbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)

	aResult[2] := EncodeUTF8(oJson:toJson())
	If nIndex > 0
		aResult[1] := .T.
		aResult[3] := 200
	EndIf
	FwFreeObj(oJson)

	aSize(aValFil, 0)

Return aResult

/*/{Protheus.doc} GET SUBSORI api/pcp/v1/mrpdata/subst/ori
Recupera os produtos originais a partir de um produto alternativo

@type WSMETHOD
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 ticket      , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 product     , Caracter, Produto substituto
@param 03 periodFrom  , Caracter, data inicial de busca de substituições
@param 04 periodTo    , Caracter, data final de busca de substituições
@parma 05 page        , number  , Número da página para consulta
@parma 06 pageSize    , number  , Quantidade de registros por página
@return lRet, Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET SUBSORI QUERYPARAM ticket, product, periodFrom, periodTo, Page, PageSize  WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")
	//Chama a funcao para retornar os dados.
	aReturn := getSubsOri(Self:ticket, Self:product, Self:periodFrom, Self:periodTo, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getSubsOri
Recupera os produtos originais a partir de um produto alternativo

@type  Static Function
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 cTicket     , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 cProduto    , Caracter, Produto substituído
@param 03 cPerDe      , Caracter, data inicial de busca de substituições
@param 04 cPerAte     , Caracter, data final de busca de substituições
@parma 05 nPage       , number  , Número da página para consulta
@parma 06 npageSize   , number  , Quantidade de registros por página
@return aResult, Array, Array com os dados da consulta
/*/
Static Function getSubsOri(cTicket, cProduto, cPerDe, cPerAte, nPage, nPageSize)
	Local aResult := {.F., "", 204}
	Local aValFil := getFilMRP(cTicket, "HWC")
	Local cAlias  := ""
	Local cBanco  := AllTrim(TcGetDb())
	Local cQuery  := ""
	Local lUsaME  := Len(aValFil) > 1
	Local nIndex  := 0
	Local nStart  := 0
	Local oExec   := Nil
	Local oJson   := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	cQuery := " SELECT HWC_ORI.HWC_FILIAL,"
	cQuery +=        " HWC_ORI.HWC_PRODUT,"
	cQuery +=        " HWC_ORI.HWC_DATA,"
	cQuery +=        " HWC_ORI.HWC_DOCPAI,"
	cQuery +=        " HWC_ORI.HWC_QTSUBS QTORIG,"
	cQuery +=        " HWC_ALT.HWC_QTSUBS QTALT"
	cQuery +=   " FROM " + RetSqlName("HWC") + " HWC_ORI"
	cQuery +=  " INNER JOIN " + RetSqlName("HWC") + " HWC_ALT"
	cQuery +=     " ON HWC_ALT.HWC_FILIAL = HWC_ORI.HWC_FILIAL"
	cQuery +=    " AND HWC_ALT.HWC_TICKET = HWC_ORI.HWC_TICKET"
	cQuery +=    " AND HWC_ALT.HWC_DATA   = HWC_ORI.HWC_DATA"
	cQuery +=    " AND HWC_ALT.HWC_PRODUT = ?"
	cQuery +=    " AND HWC_ALT.HWC_DATA  >= ?"
	cQuery +=    " AND HWC_ALT.HWC_DATA  <= ?"
	//Comparação de HWC_CHVSUB com HWC_CHAVE com as tratativas para considerar o IDOPC correto para o HWC_CHAVE.
	cQuery +=    " AND HWC_ALT.HWC_CHVSUB = "

	If cBanco == "ORACLE"
		cQuery += "RPAD(" //RPAD para padronizar o tamanho final da string para banco ORACLE
	EndIf

	//Concatena o código da filial na chave do produto original caso utilize multi-empresa.
	If lUsaME .And. cBanco == "POSTGRES"
		//Para banco POSTGRES, utiliza comando CONCAT
		cQuery += " TRIM(CONCAT(HWC_ORI.HWC_FILIAL,"
	ElseIf lUsaME
		//Para demais bancos, utiliza comando || ou +
		cQuery += " HWC_ORI.HWC_FILIAL || "
	EndIf

	cQuery +=                                  " CASE "
	//Se não tiver IDOPC no produto origem, compara diretamente HWC_ALT.HWC_CHVSUB = HWC_ORI.HWC_CHAVE
	cQuery +=                                  " WHEN HWC_ORI.HWC_IDOPC = ' ' THEN"
	cQuery +=                                       " HWC_ORI.HWC_CHAVE"
	cQuery +=                                  " ELSE"
	//Se tiver IDOPC no produto origem, precisa fazer a comparação com o HWC_ORI.HWC_IDOPC concatenado na coluna HWC_ORI.HWC_CHAVE
	//Pega o HWC_CHAVE sem a informação do período
	cQuery +=                                       " SUBSTR(HWC_ORI.HWC_CHAVE, 1, LENGTH( RTRIM(HWC_ORI.HWC_CHAVE) ) - "
	cQuery +=                                                                    " LENGTH( RTRIM(LTRIM( REPLACE(HWC_ORI.HWC_CHAVE, "
	cQuery +=                                                                                          " RTRIM(HWC_ORI.HWC_PRODUT),'')))))"
	//Concatena o separador | + HWC_IDOPC
	cQuery +=                                       " || '|' || RTRIM(HWC_ORI.HWC_IDOPC)"
	//Concatena o número do período após o IDOPC.
	cQuery +=                                       " || LTRIM(REPLACE(HWC_ORI.HWC_CHAVE, RTRIM(HWC_ORI.HWC_PRODUT),''))"
	cQuery +=                                  " END"

	If lUsaME .And. cBanco == "POSTGRES"
		cQuery += "))" //Se multi-empresa e banco POSTGRES, fecha o ) do comando CONCAT e do TRIM.
	EndIf

	If cBanco == "ORACLE"
		//Parâmetro do RPAD com o tamanho da string.
		cQuery += " ,LENGTH(HWC_ORI.HWC_CHAVE))"
	EndIf
	cQuery +=    " AND HWC_ALT.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE HWC_ORI.HWC_FILIAL IN (?)"
	cQuery +=    " AND HWC_ORI.HWC_TICKET = ?"
	cQuery +=    " AND HWC_ORI.HWC_QTSUBS > 0"
	cQuery +=    " AND HWC_ORI.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY HWC_ORI.HWC_DATA, HWC_ORI.HWC_FILIAL, HWC_ORI.HWC_PRODUT"

	If "MSSQL" $ cBanco
		//Faz adequações na query para o banco SQL SERVER.
		cQuery := StrTran(cQuery, "||", "+") //Troca concatenação
		cQuery := StrTran(cQuery, "LENGTH", "LEN") //Troca função LENGTH por LEN
		cQuery := StrTran(cQuery, "SUBSTR", "SUBSTRING") //Troca função SUBSTR por SUBSTRING
	EndIf

	oExec  := FwExecStatement():New(cQuery)

	If Empty(cPerDe)
		cPerDe := " "
	EndIf
	If Empty(cPerAte)
		cPerAte := "ZZZZZZZZ"
	EndIf

	cPerDe  := convDate(cPerDe, 2)
	cPerAte := convDate(cPerAte, 2)

	oExec:SetString(1, cProduto) //HWC_PRODUT = cProduto
	oExec:SetString(2, cPerDe  ) //HWC_DATA >= cPerDe
	oExec:SetString(3, cPerAte ) //HWC_DATA <= cPerAte
	oExec:SetIn(    4, aValFil ) //HWC_FILIAL IN(xxx)
	oExec:SetString(5, cTicket ) //HWC_TICKET = cTicket

	cAlias := oExec:OpenAlias()

	TcSetField(cAlias, 'HWC_DATA', 'D', GetSx3Cache("HWC_DATA"  , "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'QTORIG'  , 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS", "X3_DECIMAL"))
	TcSetField(cAlias, 'QTALT'   , 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS", "X3_DECIMAL"))

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}
	nIndex         := 0
	While (cAlias)->(!Eof())

		nIndex++
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nIndex]["branchId"    ] := (cAlias)->HWC_FILIAL
		oJson["items"][nIndex]["product"     ] := (cAlias)->HWC_PRODUT
		oJson["items"][nIndex]["period"      ] := convDate((cAlias)->HWC_DATA, 1)
		oJson["items"][nIndex]["document"    ] := (cAlias)->HWC_DOCPAI
		oJson["items"][nIndex]["originalQty" ] := (cAlias)->QTORIG
		oJson["items"][nIndex]["substitution"] := -(cAlias)->QTALT

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If nIndex >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAlias)->(!Eof())

	(cAlias)->(dbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)

	aResult[2] := EncodeUTF8(oJson:toJson())
	If nIndex > 0
		aResult[1] := .T.
		aResult[3] := 200
	EndIf
	FwFreeObj(oJson)

	aSize(aValFil, 0)

Return aResult

/*/{Protheus.doc} getFilMRP
Retorna um array com as filiais do MRP para adicionar em query.

@type  Static Function
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 cTicket, Caracter, Número do ticket do MRP
@param 02 cTabela, Caracter, Tabela para retorno da filial
@return aFilMRP, Array, Array com as filiais para considerar
/*/
Static Function getFilMRP(cTicket, cTabela)
	Local aFilMRP  := {}
	Local aFiliais := {}
	Local nIndex   := 0
	Local nTotFils := 0

	ticketME(cTicket, .F., , , , @aFiliais)

	nTotFils := Len(aFiliais)
	If nTotFils == 0
		aAdd(aFilMRP, xFilial(cTabela))
	Else
		For nIndex := 1 To nTotFils
			aAdd(aFilMRP, xFilial(cTabela, aFiliais[nIndex][1]))
		Next nIndex
	EndIf
	FwFreeArray(aFiliais)

Return aFilMRP

/*/{Protheus.doc} custoEstoq
Calcula o custo de estoque para um período ( relatório excel )
@type  Function
@author douglas.heydt
@since 30/06/2022
@version P12.1.2210
@param 01 nSaldo     , Numeral, Saldo resultante do período
@param 02 nSaida     , Numeral, Saídas do período
@param 03 nSaidaEst  , Numeral, Saídas de estrutura no período
@param 04 nEstoque   , Numeral, Estoque do produto no período
@param 05 nEntrada   , Numeral, Entradas
@param 06 nCustoUnit , Numeral, Custo unitário, conforme função getCost()

@Return nCusto, Numeral, Custo calculado
/*/
Static Function custoEstoq(nSaldo, nSaida, nSaidaEst, nEstoque, nEntrada, nCustoUnit)

	Local nCusto := 0
	Local nEstoqUsad := 0
	Local nSaidasUsa := 0

	If nEstoque > 0
		nEstoqUsad :=  nEstoque + nEntrada
		nSaidasUsa :=  nSaida + nSaidaEst
	Else
		nEstoqUsad :=  nEntrada
		nSaidasUsa :=  nSaida + nSaidaEst - nEstoque
	EndIf

	If nSaidasUsa < nEstoqUsad
		nCusto := nSaidasUsa * nCustoUnit
	Else
		nCusto := nEstoqUsad * nCustoUnit
	EndIf

	If nCusto < 0
		nCusto := 0
	EndIf

Return nCusto

/*/{Protheus.doc} GET OPTIONAL api/pcp/v1/mrpdata/optional/{ticket}/{product}/{optionalId}
Retorna os opcionais do produto de acordo com o ticket e idOpc

@type WSMETHOD
@author marcelo.neumann
@since 09/11/2022
@version P12.1.27
@param 01 ticket    , Caracter, Ticket do MRP
@param 02 product   , Caracter, Código do produto
@param 03 optionalId, Caracter, ID do opcional do produto (MRP)
@return   lRet      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPTIONAL PATHPARAM ticket, product, optionalId WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getOpcProd(Self:ticket, Self:product, Self:optionalId)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getOpcProd
Retorna os opcionais do produto de acordo com o ticket e idOpc

@type Static Function
@author marcelo.neumann
@since 09/11/2022
@version P12
@param 01 cTicket , Caracter, Ticket do MRP
@param 02 cProduto, Caracter, Código do produto
@param 03 cIdOpc  , Caracter, ID do opcional do produto (MRP)
@return   aResult , Array   , Array com as informacoes da requisicao
/*/
Static Function getOpcProd(cTicket, cProduto, cIdOpc)
	Local aFiliais   := {}
	Local aOpcional  := {}
	Local aResult    := {}
	Local cAliasQry  := GetNextAlias()
	Local cFiliaisIN := ""
	Local nIndex     := 0
	Local oJson      := JsonObject():New()
	Local nTotal     := 0

	ticketME(cTicket, .F., , , , aFiliais)
	nTotal := Len(aFiliais)

	cFiliaisIN := "%("
	If nTotal == 0
		cFiliaisIN += "'" + xFilial("HWD") + "'"
	Else
		For nIndex := 1 To nTotal
			If nIndex > 1
				cFiliaisIN += ","
			EndIf
			cFiliaisIN += "'" + xFilial("HWD", aFiliais[nIndex][1]) + "'"
		Next nIndex

		aSize(aFiliais, 0)
	EndIf
	cFiliaisIN += ")%"

	oJson["items"] := {}

	BeginSql Alias cAliasQry
	  SELECT HWD_ERPOPC, HWD_ERPMOP
	    FROM %table:HWD%
	   WHERE HWD_FILIAL IN %Exp:cFiliaisIN%
	     AND HWD_TICKET = %Exp:cTicket%
	     AND HWD_KEYMAT = %Exp:cIdOpc%
		 AND %NotDel%
       ORDER BY HWD_KEYMAT
	EndSql

	If (cAliasQry)->(!Eof())
		aOpcional := aClone(ListOpc(cProduto, (cAliasQry)->HWD_ERPMOP, (cAliasQry)->HWD_ERPOPC, 2))
	EndIf

	(cAliasQry)->(dbCloseArea())

	nTotal := Len(aOpcional)
	If nTotal > 0
		For nIndex := 1 To nTotal
			aAdd(oJson["items"], JsonObject():New())
			oJson["items"][nIndex]["product"          ] := aOpcional[nIndex][1]
			oJson["items"][nIndex]["description"      ] := aOpcional[nIndex][2]
			oJson["items"][nIndex]["groupOptional"    ] := aOpcional[nIndex][3]
			oJson["items"][nIndex]["descGroupOptional"] := aOpcional[nIndex][4]
			oJson["items"][nIndex]["itemOptional"     ] := aOpcional[nIndex][5]
			oJson["items"][nIndex]["descItemOptional" ] := aOpcional[nIndex][6]
		Next nIndex

		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)

		aSize(aOpcional, 0)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJson())
		aAdd(aResult, 204)
	Endif

	FwFreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET GEN_INFO api/pcp/v1/mrpdata/generics
Retorna informações que não dependem do ticket selecionado

@type WSMETHOD
@author marcelo.neumann
@since 11/11/2022
@version P12
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET GEN_INFO WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetGen()
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} MrpGetGen
Retorna informações que não dependem do ticket selecionado

@type Function
@author marcelo.neumann
@since 11/11/2022
@version P12
@return aResult, Array, Array com as informacoes da requisicao
/*/
Function MrpGetGen()
	Local aResult   := {}
	Local cAliasQry := GetNextAlias()
	Local cHasOpc   := "N"
	Local oJson     := JsonObject():New()

	oJson["items"] := {}

	BeginSql Alias cAliasQry
	  SELECT 1
	    FROM %table:HWD%
	   WHERE %NotDel%
	EndSql

	If (cAliasQry)->(!Eof())
		cHasOpc := "S"
	EndIf

	aAdd(oJson["items"], JsonObject():New())

	oJson["items"][1]["hasOptional"] := cHasOpc

	aAdd(aResult, .T.)
	aAdd(aResult, EncodeUTF8(oJson:toJson()))
	aAdd(aResult, 200)

	FwFreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET EXP_OPC api/pcp/v1/mrpdata/expopc/{ticket}
Retorna os opcionais para exportação via excel.

@type WSMETHOD
@author Lucas Fagundes
@since 05/12/2022
@version P12
@param ticket, Caracter, Ticket do MRP
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET EXP_OPC PATHPARAM ticket WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getOpcExp(Self:ticket)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getOpcExp
Retorna as informações de opcionais para exportação do excel.
@type  Function
@author Lucas Fagundes
@since 05/12/2022
@version P12
@param cTicket, Caracter, Ticket do MRP.
@return aResult, Array, Array com os dados da requisição.
/*/
Function getOpcExp(cTicket)
	Local aResult   := {}
	Local oJson     := JsonObject():New()
	Local oJsonData := Nil

	oJsonData := getDataOpc(cTicket)

	oJson["items"] := JsonObject():New()

	oJson["items"]["header"] := getHeadOpc()
	oJson["items"]["data"  ] := oJsonData

	oJson["hasNext"] := .F.

	aAdd(aResult, .T.)
	aAdd(aResult, EncodeUTF8(oJson:toJson()))
	aAdd(aResult, 200)

	FwFreeObj(oJson)
	FwFreeObj(oJsonData)

Return aResult

/*/{Protheus.doc} getDataOpc
Retorna os dados dos opcionais de uma execução do MRP.
@type  Static Function
@author Lucas Fagundes
@since 06/12/2022
@version P12
@param cTicket, Caracter, Ticket do MRP.
@return oJson, Object, Objeto json com os dados dos opcionais.
/*/
Static Function getDataOpc(cTicket)
	Local aDadosOpc := {}
	Local cAlias    := GetNextAlias()
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsAux    := Nil
	Local oJson     := JsonObject():New()

	BeginSql alias cAlias
		SELECT HWD.HWD_KEYMAT,
		       HWD.HWD_ERPOPC,
		       HWB.HWB_PRODUT,
		       HWD.HWD_ERPMOP
		  FROM %table:HWD% HWD
		 INNER JOIN (SELECT DISTINCT HWB_IDOPC, HWB_PRODUT
		               FROM %table:HWB%
		              WHERE HWB_TICKET = %Exp:cTicket%) HWB
		    ON HWB.HWB_IDOPC  = HWD.HWD_KEYMAT
		 WHERE HWD.HWD_TICKET = %Exp:cTicket%
	EndSql

	While (cAlias)->(!Eof())

		If !oJson:hasProperty((cAlias)->HWB_PRODUT)
			oJson[(cAlias)->HWB_PRODUT] := JsonObject():New()
		EndIf

		aDadosOpc := ListOpc((cAlias)->HWB_PRODUT, (cAlias)->HWD_ERPMOP, (cAlias)->HWD_ERPOPC, 2)
		nTotal    := Len(aDadosOpc)

		oJson[(cAlias)->HWB_PRODUT][(cAlias)->HWD_KEYMAT] := {}
		For nIndex := 1 To nTotal
			oJsAux := JsonObject():New()
			oJsAux["product"           ] := RTrim(aDadosOpc[nIndex][1])
			oJsAux["productDescription"] := RTrim(aDadosOpc[nIndex][2])
			oJsAux["group"             ] := RTrim(aDadosOpc[nIndex][3])
			oJsAux["groupDescription"  ] := RTrim(aDadosOpc[nIndex][4])
			oJsAux["item"              ] := RTrim(aDadosOpc[nIndex][5])
			oJsAux["itemDescription"   ] := RTrim(aDadosOpc[nIndex][6])

			aAdd(oJson[(cAlias)->HWB_PRODUT][(cAlias)->HWD_KEYMAT], oJsAux)
		Next

		FwFreeArray(aDadosOpc)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return oJson

/*/{Protheus.doc} getHeadOpc
Retorna as informações para montar o header dos opcionais.
@type  Static Function
@author Lucas Fagundes
@since 06/12/2022
@version P12
@return aHeaders, Array, Array com as informações do cabeçalho.
/*/
Static Function getHeadOpc()
	Local aHeaders := {}
	Local nIndex   := 0

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "product"
	aHeaders[nIndex]["label"] := STR0035 // "Produto"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "productDescription"
	aHeaders[nIndex]["label"] := STR0036 // "Descrição"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "group"
	aHeaders[nIndex]["label"] := STR0056 // "Grupo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "groupDescription"
	aHeaders[nIndex]["label"] := STR0036 // "Descrição"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "item"
	aHeaders[nIndex]["label"] := STR0057 // "Item"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "itemDescription"
	aHeaders[nIndex]["label"] := STR0036 // "Descrição"

Return aHeaders

/*/{Protheus.doc} arqProdTkt
Recupera o conteudo do parâmetro MV_ARQPROD utilizado em uma execução do mrp.
@type  Static Function
@author Lucas Fagundes
@since 13/02/2023
@version P12
@param cTicket, Caracter, Ticket de execução do mrp
@return cValor, Caracter, Conteudo do parâmetro MV_ARQPROD no ticket verificado
/*/
Static Function arqProdTkt(cTicket)
	Local cValor := ""

	HW1->(DbSetOrder(1)) // HW1_FILIAL+HW1_TICKET+HW1_PARAM
	If HW1->(DbSeek(xFilial("HW1")+cTicket+"usesProductIndicator"))
		If AllTrim(HW1->HW1_VAL) == "1"
			cValor := "SBZ"
		Else
			cValor := "SB1"
		EndIf
	EndIf

Return cValor
