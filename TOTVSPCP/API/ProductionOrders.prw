#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PRODUCTIONORDERS.CH"

Static _aMapOrd := MapFields()
Static _aTamQtd := TamSX3("C2_QUANT")

Function PrdOrds()
Return

/*/{Protheus.doc} ProductionOrders
API de integra��o de Ordens de Produ��o
@type  WSCLASS
@author parffit.silva
@since 26/10/2020
@version P12.1.27
/*/
WSRESTFUL productionorders DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ordem de Produ��o"
	WSDATA Fields             AS STRING  OPTIONAL
	WSDATA Order              AS STRING  OPTIONAL
	WSDATA Page               AS INTEGER OPTIONAL
	WSDATA PageSize           AS INTEGER OPTIONAL
	WSDATA branchId           AS STRING  OPTIONAL
	WSDATA productionOrder    AS STRING  OPTIONAL
	WSDATA documentOrigin     AS STRING  OPTIONAL
	WSDATA documentId         AS STRING  OPTIONAL
	WSDATA product            AS STRING  OPTIONAL
	WSDATA productDescription AS STRING  OPTIONAL
	WSDATA SystemDate         AS STRING  OPTIONAL

	WSMETHOD GET ALLPORDERS;
		DESCRIPTION STR0002;//"Retorna todas as Ordens de Produ��o"
		WSSYNTAX "api/pcp/v1/productionorders" ;
		PATH "/api/pcp/v1/productionorders" ;
		TTALK "v1"

	WSMETHOD GET PORDER;
		DESCRIPTION STR0003;//"Retorna uma Ordem de Produ��o"
		WSSYNTAX "api/pcp/v1/productionorders/{branchId}/{productionOrder}" ;
		PATH "/api/pcp/v1/productionorders/{branchId}/{productionOrder}" ;
		TTALK "v1"

	WSMETHOD GET PEGGING;
		DESCRIPTION STR0006;//"Retorna uma ou mais Ordens de Produ��o para rastreabilidade"
		WSSYNTAX "api/pcp/v1/productionorders/pegging" ;
		PATH "/api/pcp/v1/productionorders/pegging" ;
		TTALK "v1"
	
	WSMETHOD GET ALLOCATION;
		DESCRIPTION STR0017; // "Retorna o empenhos para a tela de rastreabilidade"
		WSSYNTAX "api/pcp/v1/productionorders/allocation" ;
		PATH "/api/pcp/v1/productionorders/allocation" ;
		TTALK "v1"

	WSMETHOD GET OPCOP;
		DESCRIPTION STR0018; // "Retorna os opcionais de uma ordem de produ��o"
		WSSYNTAX "api/pcp/v1/productionorders/pegging/optional/{productionOrder}" ;
		PATH "/api/pcp/v1/productionorders/pegging/optional/{productionOrder}" ;
		TTALK "v1"

	//WSMETHOD POST PORDER;
	//	DESCRIPTION STR0004;//"Inclui ou atualiza uma ou mais ordens de produ��o"
	//	WSSYNTAX "api/pcp/v1/productionorders" ;
	//	PATH "/api/pcp/v1/productionorders" ;
	//	TTALK "v1"

	//WSMETHOD DELETE PORDER;
	//	DESCRIPTION STR0005;//"Exclui uma ou mais ordens de produ��o"
	//	WSSYNTAX "api/pcp/v1/productionorders" ;
	//	PATH "/api/pcp/v1/productionorders" ;
	//	TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALLPORDERS /api/pcp/v1/productionorders
Retorna todas as Ordens de produ��o
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Order   , caracter, Ordena��o da tabela principal
@param	Page    , num�rico, N�mero da p�gina inicial da consulta
@param	PageSize, num�rico, N�mero de registro por p�ginas
@param	Fields  , caracter, Campos que ser�o retornados no GET.
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLPORDERS QUERYPARAM Order, Page, PageSize, Fields WSSERVICE productionorders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := GetAllPOrd(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
    MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET PORDER /api/pcp/v1/productionorders
Retorna um registro de Ordem de Produ��o
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Fields  , caracter, Campos que ser�o retornados no GET.
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PORDER PATHPARAM branchId, productionOrder QUERYPARAM Fields WSSERVICE productionorders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a fun��o para retornar os dados.
	aReturn := GetPOrd(Self:branchId, Self:productionOrder, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET PEGGING /api/pcp/v1/productionorders/pegging
Retorna as Ordens de Produ��o para rastreabilidade
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Page      , num�rico, N�mero da p�gina inicial da consulta
@param	PageSize  , num�rico, N�mero de registro por p�ginas
@param  SystemDate , character , database do protheus enviada pelo front
@return lRet      , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PEGGING WSRECEIVE branchId, productionOrder, documentOrigin, documentId, product, productDescription QUERYPARAM Page, PageSize, SystemDate WSSERVICE productionorders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a fun��o para retornar os dados.
	aReturn := GetPOrdPeg(Self:branchId, Self:productionOrder, Self:documentOrigin, Self:documentId, Self:product, Self:productDescription, Self:Page, Self:PageSize, Self:SystemDate)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET ALLOCATION api/pcp/v1/productionorders/allocation
Retorna os empenhos para exibi��o na tela de rastreabilidade

@type WSMETHOD
@author Lucas Fagundes
@since 15/03/2023
@version P12
@param 01 productionOrder, Caracter, Filtro das ordens de produ��es para consulta.
@param 02 pageSize       , Numerico, Tamanho da p�gina a ser buscada.
@param 03 page           , Numerico, Numero da p�gina a ser buscada.
@param 04 documentId     , Caracter, Filtro dos documentos para a consulta.
@return lRet, L�gico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLOCATION PATHPARAM productionOrder, pageSize, page, documentId WSSERVICE productionorders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")
	
	aReturn := PCPEmpPegg(Self:productionOrder, Self:pageSize, Self:page, Self:documentId)

	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	
	aSize(aReturn, 0)
Return lRet

/*/{Protheus.doc} GET OPCOP api/pcp/v1/productionorders/pegging/optional/{productionOrder}
Retorna os dados de opcionais de uma ordem de produ��o

@type WSMETHOD
@author lucas.franca
@since 21/03/2023
@version P12
@param 01 productionOrder, Caracter, N�mero da ordem de produ��o
@return lRet, L�gico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPCOP PATHPARAM productionOrder WSSERVICE productionorders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")
	
	aReturn := getOpcOP(Self:productionOrder)

	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	
	aSize(aReturn, 0)
Return lRet

/*/{Protheus.doc} getOpcOP
Faz a busca dos opcionais de uma ordem de produ��o

@type  Static Function
@author lucas.franca
@since 21/03/2023
@version P12
@param cNumOP, Caracter, N�mero da ordem de produ��o
@return aReturn, Array, Array com os dados para retorno
/*/
Static Function getOpcOP(cNumOP)
	Local aReturn   := {.F., STR0010, 400} //"Nenhum registro foi encontrado."
	Local aOpcional := {}
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsRet    := Nil 

	cNumOp := PadR(cNumOp, GetSx3Cache("C2_OP", "X3_TAMANHO"))
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial("SC2") + cNumOP))
		aOpcional := ListOpc(SC2->C2_PRODUTO, SC2->C2_MOPC, SC2->C2_OPC, 2)
		If !Empty(aOpcional)
			
			nTotal          := Len(aOpcional)
			oJsRet          := JsonObject():New()
			oJsRet["items"] := {}

			For nIndex := 1 To nTotal 
				aAdd(oJsRet["items"], JsonObject():New())
				oJsRet["items"][nIndex]["product"          ] := RTrim(aOpcional[nIndex][1])
				oJsRet["items"][nIndex]["description"      ] := RTrim(aOpcional[nIndex][2])
				oJsRet["items"][nIndex]["groupOptional"    ] := RTrim(aOpcional[nIndex][3])
				oJsRet["items"][nIndex]["descGroupOptional"] := RTrim(aOpcional[nIndex][4])
				oJsRet["items"][nIndex]["itemOptional"     ] := RTrim(aOpcional[nIndex][5])
				oJsRet["items"][nIndex]["descItemOptional" ] := RTrim(aOpcional[nIndex][6])
				
				aSize(aOpcional[nIndex], 0)
			Next nIndex

			aReturn[1] := .T.
			aReturn[2] := EncodeUTF8(oJsRet:toJson())
			aReturn[3] := 200
			
			FreeObj(oJsRet)
			aSize(aOpcional, 0)
		EndIf

	EndIf

Return aReturn

/*/{Protheus.doc} POST PORDER /api/pcp/v1/productionorders
Inclui ou atualiza uma ou mais ordens de produ��o
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
//WSMETHOD POST PORDER WSSERVICE productionorders
//	Local aReturn  := {}
//	Local cBody    := ""
//	Local cError   := ""
//	Local lRet     := .T.
//	Local oBody    := JsonObject():New()
//
//	Self:SetContentType("application/json")
//	cBody := Self:GetContent()
//
//	cError := oBody:FromJson(cBody)
//
//	If cError == Nil
//		aReturn := POrdPost(oBody)
//		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
//	Else
//		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
//		lRet    := .F.
//		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
//	EndIf
//
//	FreeObj(oBody)
//Return lRet

/*/{Protheus.doc} DELETE PORDER /api/pcp/v1/productionorders
Exclui uma ou mais ordens de produ��o
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
//WSMETHOD DELETE PORDER WSSERVICE productionorders
//	Local aReturn  := {}
//	Local cBody    := ""
//	Local cError   := ""
//	Local lRet     := .T.
//	Local oBody    := JsonObject():New()
//
//	Self:SetContentType("application/json")
//	cBody := Self:GetContent()
//
//	cError := oBody:FromJson(cBody)
//
//	If cError == Nil
//		aReturn := POrdDel(oBody)
//		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
//	Else
//		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
//		lRet    := .F.
//		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
//	EndIf
//
//	FreeObj(oBody)
//Return lRet

/*/{Protheus.doc} GetPOrdPeg
Busca as ordens de produ��o para rastreabilidade
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param   cBranch , Caracter, C�digo da filial
@param   cPOrder , Caracter, N�mero da ordem de produ��o
@param   cOrigin , Caracter, Tipo do documento
@param    cDocto , Caracter, N�mero do documento
@param  cProduto , Caracter, C�digo do produto
@param cProdDesc , Caracter, Descri��o do produto
@param     nPage , Numeric , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize , Numeric , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cSystDate , character , database do protheus enviada pelo front
/*/
Function GetPOrdPeg(cBranch, cPOrder, cOrigin, cDocto, cProduto, cProdDesc, nPage, nPageSize, cSystDate)
	Local aResult 	 := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cBanco     := Upper(TcGetDb())
	Local cFieldOP   := ""
	Local cQuery     := ""
	Local cTxtES     := MrpDGetSTR("ES")
	Local cTxtPP     := MrpDGetSTR("PP")
	Local lFieldsLt  := .F.
	Local lPerdInf   := SuperGetMV("MV_PERDINF",.F.,.F.)
	Local lUsaSBZ    := SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"
	Local nDelay     := 0
	Local nPos       := 0
	Local nStart     := 1
	Local nStatus    := 0
	Local nStatusPO  := 0
	Local mOpcOP     := Nil
	Local oDados     := JsonObject():New()

	DEFAULT nPage     := 1
	DEFAULT nPageSize := 20
	DEFAULT cSystDate := DtoS(dDataBase)

	dbSelectArea("SMH")
	lFieldsLt := FieldPos("MH_LOTE") > 0 .And. FieldPos("MH_SLOTE") > 0

	If Empty(cBranch)
		cBranch := cFilAnt
	Else
		cBranch := PadR(cBranch, FWSizeFilial())
	EndIf

	If "MSSQL" $ cBanco
		cFieldOP += " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD "

	ElseIf cBanco == "POSTGRES"
		cFieldOP += " TRIM(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD)) "

	Else
		cFieldOP += " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	EndIf

	cQuery := "SELECT SC2.C2_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SVR.VR_QUANT AS demandQuantity,"
	cQuery +=       " (CASE WHEN SMH.MH_DEMDOC = '" + cTxtPP + "' AND SMH.MH_TPDCSAI LIKE '%OP%' THEN ' ' ELSE SMH.MH_DEMDOC END) AS documentId,"
	cQuery +=         cFieldOP + " AS productionOrder,"
	cQuery +=       " SC2.C2_PRODUTO AS product,"
	cQuery +=       " SC2.C2_QUANT AS quantity,"

	If lPerdInf
		cQuery +=   " (SC2.C2_QUANT - SC2.C2_QUJE - SC2.C2_PERDA) AS balance,"
	Else
		cQuery +=   " (SC2.C2_QUANT - SC2.C2_QUJE) AS balance,"
	EndIf

	cQuery +=       " SC2.C2_DATPRI AS startDate,"
	cQuery +=       " SC2.C2_DATPRF AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " (CASE WHEN SMH.MH_TPDCSAI LIKE '%OP%' THEN SMH.MH_NMDCSAI ELSE SMH2.MH_NMDCSAI END) AS sourceDocument,"
	cQuery +=       " SUM(SMH.MH_QUANT) AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"
	cQuery +=       " SC2.C2_OPC AS optional,"
	cQuery +=       " SC2.R_E_C_N_O_ AS recno,"
	cQuery +=       " '1' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand,"
	cQuery +=       " SMH3.MH_NMDCENT AS sourceEstSeg"

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE  AS lote "
		cQuery += " , SMH.MH_SLOTE AS subLote "
	EndIf

	cQuery +=  " FROM " + RetSqlName("SC2") + " SC2"             // Ordem de Produ��o
	cQuery +=  " JOIN " + RetSqlName("SMH") + " SMH"  // Rastreabilidade das Demandas
	cQuery +=    " ON SMH.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=   " AND SMH.MH_TPDCENT = '1'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"

	If cBanco == "POSTGRES"
		cQuery += " AND Trim(SMH.MH_NMDCENT) = Trim(" + cFieldOP + ")"

	Else
		cQuery += " AND SMH.MH_NMDCENT = " + cFieldOP
	EndIf

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=              " AND SMH2.MH_TPDCENT = 'P'"
	cQuery +=              " AND SMH2.MH_NMDCENT = SMH.MH_NMDCSAI"
	cQuery +=              " AND SMH2.MH_TPDCSAI LIKE '%OP%'"
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH3"
	cQuery +=               " ON SMH3.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=              " AND SMH3.MH_IDREG = SMH.MH_IDPAI"
	cQuery +=              " AND SMH3.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	cQuery +=               " ON SVR.VR_FILIAL = '" + xFilial("SVR", cBranch) + "'"
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE SC2.C2_FILIAL = '" + xFilial("SC2", cBranch) + "' AND"
	cQuery +=       " SB1.B1_FILIAL = '" + xFilial("SB1", cBranch) + "' AND"

	If !Empty(cPOrder)
		cQuery += pcpPegFilt(cPOrder, cFieldOP) + " AND"
	EndIf

	If !Empty(cProduto)
		cQuery += pcpPegFilt(cProduto, "SC2.C2_PRODUTO") + " AND"
	EndIf

	If !Empty(cOrigin)
		cQuery += pcpPegFilt(cOrigin, "SVR.VR_TIPO") + " AND"
	EndIf

	If !Empty(cDocto)
		cQuery += pcpPegFilt(cDocto, "SMH.MH_DEMDOC") + " AND"
	EndIf

	If !Empty(cProdDesc)
		cQuery += pcpPegFilt(cProdDesc, "SB1.B1_DESC") + " AND"
	EndIf

	cQuery +=       " SB1.B1_COD = SC2.C2_PRODUTO"
	cQuery +=   " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
	//clausula group by com todos os campos menos o SUM do usedQuantity
	cQuery += " GROUP BY SC2.C2_FILIAL , "
    cQuery +=          " SVR.VR_TIPO, "
	cQuery +=          " SVR.VR_QUANT, "
    cQuery +=          " (CASE "
    cQuery +=          "      WHEN SMH.MH_DEMDOC = '" + cTxtPP + "' "
    cQuery +=          "           AND SMH.MH_TPDCSAI LIKE '%OP%' THEN ' ' "
    cQuery +=          "      ELSE SMH.MH_DEMDOC "
    cQuery +=          "  END), "
    cQuery +=            cFieldOP + ", "
    cQuery +=          " SC2.C2_PRODUTO, "
    cQuery +=          " SC2.C2_QUANT, "
    cQuery +=          " (SC2.C2_QUANT - SC2.C2_QUJE), "
    cQuery +=          " SC2.C2_DATPRI, "
    cQuery +=          " SC2.C2_DATPRF, "
	cQuery +=          " SC2.C2_PERDA, "
    cQuery +=          " SB1.B1_DESC, "
    cQuery +=          " (CASE "
    cQuery +=          "      WHEN SMH.MH_TPDCSAI LIKE '%OP%' THEN SMH.MH_NMDCSAI "
    cQuery +=          "      ELSE SMH2.MH_NMDCSAI "
    cQuery +=          "  END), "
    cQuery +=          " SMH.MH_DATA, "
    cQuery +=          " SC2.C2_OPC, "
    cQuery +=          " SC2.R_E_C_N_O_, "
    cQuery +=          " SMH.MH_DEMANDA, "
    cQuery +=          " SMH.MH_DEMSEQ, "
    cQuery +=          " SMH3.MH_NMDCENT "

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE "
		cQuery += " , SMH.MH_SLOTE "
	EndIf

	// Registros de Saldo Inicial
	cQuery += " UNION ALL"
	cQuery +=" SELECT SMH.MH_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SVR.VR_QUANT AS demandQuantity,"
	cQuery +=       " SMH.MH_DEMDOC AS documentId,"
	cQuery +=       " 'SaldoInicial' AS productionOrder,"
	cQuery +=       " SMH.MH_PRODUTO AS product,"
	cQuery +=       " 0 AS quantity,"
	cQuery +=       " 0 AS balance,"
	cQuery +=       " ' ' AS startDate,"
	cQuery +=       " ' ' AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " ' ' AS sourceDocument,"
	cQuery +=       " SMH.MH_QUANT AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"

	If lUsaSBZ
		cQuery +=   " COALESCE(SBZ.BZ_OPC, SB1.B1_OPC, ' ') AS optional,"
	Else
		cQuery +=   " COALESCE(SB1.B1_OPC, ' ') AS optional,"
	EndIf

	cQuery +=       " 0 AS recno,"
	cQuery +=       " '0' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand,"
	cQuery +=       " SMH2.MH_NMDCENT AS sourceEstSeg"

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE  AS lote "
		cQuery += " , SMH.MH_SLOTE AS subLote "
	EndIf

	cQuery +=  " FROM " + RetSqlName("SMH") + " SMH"             // Rastreabilidade das Demandas

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	cQuery +=    " ON SVR.VR_FILIAL = '" + xFilial("SVR", cBranch) + "'"
	cQuery +=   " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=   " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=   " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"
	cQuery +=               " ON SMH2.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=              " AND SMH2.MH_IDREG = SMH.MH_IDPAI"
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto

	If lUsaSBZ
		cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ"
		cQuery +=   " ON SBZ.BZ_FILIAL = '" + xFilial("SBZ", cBranch) + "'"
		cQuery +=  " AND SBZ.BZ_COD = SB1.B1_COD"
		cQuery +=  " AND SBZ.D_E_L_E_T_ = ' '"
	EndIf

	cQuery += " WHERE"
	cQuery +=       " SMH.MH_FILIAL = '" + xFilial("SMH", cBranch) + "' AND"
	cQuery +=       " SB1.B1_FILIAL = '" + xFilial("SB1", cBranch) + "' AND"

	If !Empty(cPOrder)
		cQuery += pcpPegFilt(cPOrder, "SMH.MH_NMDCSAI") + " AND"
	EndIf

	If !Empty(cProduto)
		cQuery += pcpPegFilt(cProduto, "SMH.MH_PRODUTO") + " AND"
	EndIf

	If !Empty(cOrigin)
		cQuery += pcpPegFilt(cOrigin, "SVR.VR_TIPO") + " AND"
	EndIf

	If !Empty(cDocto)
		cQuery += pcpPegFilt(cDocto, "SMH.MH_DEMDOC") + " AND"
	EndIf

	If !Empty(cProdDesc)
		cQuery += pcpPegFilt(cProdDesc, "SB1.B1_DESC") + " AND"
	EndIf

	cQuery +=       " SB1.B1_COD = SMH.MH_PRODUTO"
	cQuery +=   " AND SMH.MH_TPDCENT = '0'"
	cQuery +=   " AND SMH.MH_IDREG LIKE 'PA%'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"

	// Registros de Demandas atendidas pelo Ponto de Pedido
	cQuery += " UNION ALL"
	cQuery +=" SELECT SMH.MH_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SVR.VR_QUANT AS demandQuantity,"
	cQuery +=       " SMH.MH_DEMDOC AS documentId,"
	cQuery +=       " SMH2.MH_NMDCENT AS productionOrder,"
	cQuery +=       " SMH.MH_PRODUTO AS product,"
	cQuery +=       " SMH.MH_QUANT AS quantity,"
	cQuery +=       " SMH.MH_QUANT AS balance,"
	cQuery +=       " SC2.C2_DATPRI AS startDate,"
	cQuery +=       " SC2.C2_DATPRF AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " ' ' AS sourceDocument,"
	cQuery +=       " SMH.MH_QUANT AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"
	cQuery +=       " SC2.C2_OPC AS optional,"
	cQuery +=       " SC2.R_E_C_N_O_ AS recno,"
	cQuery +=       " '0.5' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand,"
	cQuery +=       " SMH3.MH_NMDCENT AS sourceEstSeg"

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE  AS lote "
		cQuery += " , SMH.MH_SLOTE AS subLote "
	EndIf

	cQuery +=  " FROM " + RetSqlName("SMH") + " SMH"             // Rastreabilidade das Demandas

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	cQuery +=               " ON SVR.VR_FILIAL = '" + xFilial("SVR", cBranch) + "'"
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=              " AND SMH2.MH_TPDCENT = '1'"
	cQuery +=              " AND SMH2.MH_NMDCSAI = SMH.MH_NMDCENT"
	cQuery +=              " AND SMH2.MH_TPDCSAI = '" + cTxtPP + "'
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH3"
	cQuery +=               " ON SMH3.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=              " AND SMH3.MH_IDREG = SMH.MH_IDPAI"
	cQuery +=              " AND SMH3.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SC2") + " SC2"  // Ordens de Produ��o
	cQuery +=               " ON SC2.C2_FILIAL = '" + xFilial("SC2", cBranch) + "'"
	If "MSSQL" $ cBanco
		cQuery +=           " AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD = SMH2.MH_NMDCENT"
	ElseIf cBanco == "POSTGRES"
		cQuery +=           " AND Trim(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD)) = Trim(SMH2.MH_NMDCENT)"
	Else
		cQuery +=           " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SMH2.MH_NMDCENT"
	EndIf
	cQuery +=              " AND SC2.C2_PRODUTO = SMH.MH_PRODUTO"
	cQuery +=              " AND SC2.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE"
	cQuery +=       " SMH.MH_FILIAL = '" + xFilial("SMH", cBranch) + "' AND"
	cQuery +=       " SB1.B1_FILIAL = '" + xFilial("SB1", cBranch) + "' AND"

	If !Empty(cPOrder)
		cQuery += pcpPegFilt(cPOrder, "SMH2.MH_NMDCENT") + " AND"
	EndIf

	If !Empty(cProduto)
		cQuery += pcpPegFilt(cProduto, "SMH.MH_PRODUTO") + " AND"
	EndIf

	If !Empty(cOrigin)
		cQuery += pcpPegFilt(cOrigin, "SVR.VR_TIPO") + " AND"
	EndIf

	If !Empty(cDocto)
		cQuery += pcpPegFilt(cDocto, "SMH.MH_DEMDOC") + " AND"
	EndIf

	If !Empty(cProdDesc)
		cQuery += pcpPegFilt(cProdDesc, "SB1.B1_DESC") + " AND"
	EndIf

	cQuery +=   " SB1.B1_COD = SMH.MH_PRODUTO"
	cQuery +=   " AND SMH.MH_TPDCENT = 'P'"
	cQuery +=   " AND SMH.MH_IDREG LIKE 'PA%'"
	cQuery +=   " AND SMH.MH_TPDCSAI = '9'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"

	cQuery += " ORDER BY 1, 14, 6, 17, 5"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	// nStart -> primeiro registro da pagina
	If nPage > 1
		nStart := ((nPage - 1) * nPageSize)
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	//Ajusta o tipo dos campos na query.
	TcSetField(cAliasQry,       'quantity', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry,        'balance', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry,   'usedQuantity', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'demandQuantity', 'N', _aTamQtd[1], _aTamQtd[2])

	oDados["items"] := {}

	nPos := 0
	While (cAliasQry)->(!Eof())
		mOpcOP := Nil
		If AllTrim((cAliasQry)->productionOrder) == 'SaldoInicial'
			nStatus   := 3
			nDelay    := 0
			nStatusPO := "0"
		Else
			nStatusPO := getStatusPO((cAliasQry)->recno, @mOpcOP)

			If nStatusPO == '5' .Or. nStatusPO == '6'
				nStatus := 0
				nDelay  := 0
			Else
				nDelay := DateDiffDay(CTOD(cSystDate), STOD((cAliasQry)->ENDDATE))
				If CTOD(cSystDate) < STOD((cAliasQry)->ENDDATE)
					nDelay := nDelay*-1
				EndIf

				nStatus := IIF(nDelay > 0, 2, 1)
			EndIf
		EndIf

		aAdd(oDados["items"], JsonObject():New())
		nPos++

		oDados["items"][nPos]['branchId'          ] := (cAliasQry)->branchId
		oDados["items"][nPos]['documentOrigin'    ] := (cAliasQry)->documentOrigin
		oDados["items"][nPos]['documentId'        ] := (cAliasQry)->documentId
		oDados["items"][nPos]['productionOrder'   ] := IIF(AllTrim((cAliasQry)->productionOrder) == 'SaldoInicial','',(cAliasQry)->productionOrder)
		oDados["items"][nPos]['product'           ] := (cAliasQry)->product
		oDados["items"][nPos]['productDescription'] := (cAliasQry)->productDescription
		oDados["items"][nPos]['quantity'          ] := (cAliasQry)->quantity
		oDados["items"][nPos]['balance'           ] := (cAliasQry)->balance		
		oDados["items"][nPos]['endDate'           ] := getDate((cAliasQry)->ENDDATE)
		oDados["items"][nPos]['status'            ] := nStatus
		oDados["items"][nPos]['delay'             ] := nDelay
		oDados["items"][nPos]['usedQuantity'      ] := (cAliasQry)->usedQuantity
		oDados["items"][nPos]['usedDate'          ] := getDate((cAliasQry)->usedDate)
		oDados["items"][nPos]['optional'          ] := (cAliasQry)->optional
		oDados["items"][nPos]['demand'            ] := (cAliasQry)->demand + Iif(!Empty((cAliasQry)->seqDemand), " / " + cValToChar((cAliasQry)->seqDemand), "")
		
		If !Empty(mOpcOP)
			oDados["items"][nPos]["viewOptional"] := {'viewOptional'}
		Else
			oDados["items"][nPos]["viewOptional"] := {''}
		EndIf

		oDados["items"][nPos]['productDetail'] := Array(1)
		oDados["items"][nPos]['productDetail'][1] :=JsonObject():New()		
		oDados["items"][nPos]['productDetail'][1]['productDescription'] := (cAliasQry)->productDescription
		oDados["items"][nPos]['productDetail'][1]['startDate'         ] := getDate((cAliasQry)->startDate)
		oDados["items"][nPos]['productDetail'][1]['lot'               ] := Iif(lFieldsLt, (cAliasQry)->lote   , '')
		oDados["items"][nPos]['productDetail'][1]['sublot'            ] := Iif(lFieldsLt, (cAliasQry)->subLote, '')
		oDados["items"][nPos]['productDetail'][1]['sourceDocument'    ] := Iif(SubStr((cAliasQry)->documentId, 1, Len(cTxtES)) == cTxtES, (cAliasQry)->sourceEstSeg, (cAliasQry)->sourceDocument) 
		oDados["items"][nPos]['productDetail'][1]['statusPO'          ] := lblStatusPO(nStatusPO)
		oDados["items"][nPos]['productDetail'][1]['demandQuantity'    ] := (cAliasQry)->demandQuantity

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da p�gina
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oDados["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	aResult[2] := EncodeUTF8(oDados:toJson())

	If nPos > 0
		aResult[1] := .T.
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0010
		aResult[3] := 204
	EndIf

    aSize(oDados["items"],0)
	FreeObj(oDados)

Return aResult

/*/{Protheus.doc} getStatusPO
Fun��o para retornar o status da OP.
@type    Function
@author parffit.silva
@since 25/05/2021
@version P12.1.27
@param 01 nPORecno, number, Recno da ordem de produ��o na SC2
@param 02 mOpcOP  , Memo  , Retorna por refer�ncia o MOPC da OP
@return  cStatus -> Status da ordem
/*/
Static Function getStatusPO(nPORecno, mOpcOP)
	Local cAliasTemp := ""
	Local aAreaSC2    := SC2->(GetArea())
	Local cQuery     := ""
	Local cStatus    := ""
	Local dEmissao   := dDataBase
	Local nRegSD3    := 0
	Local nRegSH6    := 0

	SC2->(dbGoTo(nPORecno))
	mOpcOP := SC2->C2_MOPC
	If SC2->C2_TPOP == "P"
		cStatus := "1" //Prevista
	Else
		If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE < C2_QUANT)  /*Enc.Parcialmente*/
			cStatus := "5" //Encerrada Parcialmente
		Else
			If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE >= C2_QUANT)  /*Enc.Totalmente*/
				cStatus := "6" //Encerrada Totalmente
			Else
				cAliasTemp:= "SD3TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
				cQuery     += "   FROM " + RetSqlName('SD3')
				cQuery     += "   WHERE D3_FILIAL   = '" + xFilial('SD3')+ "'"
				cQuery     += "     AND D3_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D3_ESTORNO <> 'S' "
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    += "       GROUP BY D3_EMISSAO "
				cQuery    := ChangeQuery(cQuery)
				dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SD3TMP->(Eof())
					dEmissao := STOD(SD3TMP->EMISSAO)
					nRegSD3 := SD3TMP->RegSD3
				EndIf
				(cAliasTemp)->(dbCloseArea())
				cAliasTemp:= "SH6TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSH6 "
				cQuery     += "   FROM " + RetSqlName('SH6')
				cQuery     += "   WHERE H6_FILIAL   = '" + xFilial('SH6')+ "'"
				cQuery     += "     AND H6_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    := ChangeQuery(cQuery)
				dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SH6TMP->(Eof())
					nRegSH6 := SH6TMP->RegSH6
				EndIf
				(cAliasTemp)->(dbCloseArea())

				If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - SC2->C2_DATPRI,0) < If(SC2->C2_DIASOCI == 0,1,SC2->C2_DIASOCI)) //Em aberto
					cStatus := "2" //Em aberto
				Else
					If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((dDatabase - dEmissao),0) > If(SC2->C2_DIASOCI >= 0,-1,SC2->C2_DIASOCI)) //Iniciada
						cStatus := "3" //Iniciada
					Else
						If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (Max((dDatabase - dEmissao),0) > SC2->C2_DIASOCI .Or. Max((dDatabase - SC2->C2_DATPRI),0) >= SC2->C2_DIASOCI)   //Ociosa
							cStatus := "4" //Ociosa
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSC2)
Return cStatus

/*/{Protheus.doc} POrdPost
Fun��o para disparar as a��es da API para o m�todo POST (Inclus�o/Altera��o).
@type    Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
//Function POrdPost(oBody)
//	Local aReturn := {201, ""}
//	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST
//
//	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
//	oMRPApi:setBody(oBody)
//
//	//Executa o processamento do POST
//	oMRPApi:processar("fields")
//	//Recupera o status do processamento
//	aReturn[1] := oMRPApi:getStatus()
//	//Recupera o JSON com os dados do retorno do processo.
//	aReturn[2] := oMRPApi:getRetorno(1)
//
//	//Libera o objeto MRPApi da mem�ria.
//	oMRPApi:Destroy()
//	FreeObj(oMRPApi)
//	oMRPApi := Nil
//Return aReturn


/*/{Protheus.doc} PORDVLD
Fun��o respons�vel por validar as informa��es recebidas.
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param oMRPApi   , Object   , Refer�ncia da classe MRPApi que est� processando os dados.
@param cMapCode  , Character, C�digo do mapeamento que ser� validado
@param oItem     , Object   , Refer�ncia do objeto JSON com os dados que devem ser validados.
@return lRet     , L�gico   , Identifica se os dados est�o v�lidos.
/*/
//Function PORDVLD(oMRPApi, cMapCode, oItem)
//	Local lRet := .T.
//	Default cMapCode := "fields"
//
//	lRet := vldPOrdem(oMRPApi, oItem)
//
//Return lRet

/*/{Protheus.doc} vldPOrdem
Faz a valida��o do item.
@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param oMRPApi, Object    , Refer�ncia da classe MRPAPI que est� executando o processo.
@param oItem  , JsonObject, Objeto JSON do item que ser� validado
@return lRet  , Logical   , Indica se o item poder� ser processado.
/*/
//Static Function vldPOrdem(oMRPApi, oItem)
//	Local lRet      := .T.
//
//	If lRet .And. Empty(oItem["productionOrder"])
//		lRet     := .F.
//		oMRPApi:SetError(400, STR0008 + " 'productionOrder' " + STR0009) //"Atributo 'XXX' n�o foi informado."
//	EndIf
//
//	If oMRPApi:cMethod != "DELETE"
//		If lRet .And. Empty(oItem["itemCode"])
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'itemCode' " + STR0009) //"Atributo 'XXX' n�o foi informado."
//		EndIf
//
//		If lRet .And. (Empty(oItem["quantity"]) .Or. oItem["quantity"] <= 0)
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'quantity' " + STR0009) //"Atributo 'XXX' n�o foi informado."
//		EndIf
//
//		If lRet .And. Empty(oItem["startOrderDate"])
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'startOrderDate' " + STR0009) //"Atributo 'XXX' n�o foi informado."
//		EndIf
//
//		If lRet .And. Empty(oItem["endOrderDate"])
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'endOrderDate' " + STR0009) //"Atributo 'XXX' n�o foi informado."
//		EndIf
//	EndIf
//
//Return lRet

/*/{Protheus.doc} POrdDel
Fun��o para disparar as a��es da API para o m�todo DELETE (Exclus�o)
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
//Function POrdDel(oBody)
//	Local aReturn  := {201, ""}
//	Local oMRPApi  := defMRPApi("DELETE","") //Inst�ncia da classe MRPApi para o m�todo DELETE
//
//	//Seta as fun��es de valida��o de cada mapeamento.
//	oMRPApi:setValidData("fields", "PORDVLD")
//
//	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
//	oMRPApi:setBody(oBody)
//	oMRPApi:setMapDelete("fields")
//
//	//Executa o processamento do POST
//	oMRPApi:processar("fields")
//	//Recupera o status do processamento
//	aReturn[1] := oMRPApi:getStatus()
//	//Recupera o JSON com os dados do retorno do processo.
//	aReturn[2] := oMRPApi:getRetorno(1)
//
//	//Libera o objeto MRPApi da mem�ria.
//	oMRPApi:Destroy()
//	FreeObj(oMRPApi)
//	oMRPApi := Nil
//Return aReturn

/*/{Protheus.doc} GetAllPOrd
Fun��o para disparar as a��es da API para o m�todo GET (Consulta) de uma lista de ordens de produ��o
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
*/
Function GetAllPOrd(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := PORDERGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} GetPOrd
Fun��o para disparar as a��es da API para o m�todo GET (Consulta) de uma ordem de produ��o espec�fica
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param cBranch , Caracter, C�digo da filial
@param cPOrder, Caracter, N�mero da ordem de produ��o
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informa��es da requisi��o.
                        aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Function GetPOrd(cBranch, cPOrder, cFields)
	Local aReturn   := {}
	Local aQryParam := {}
    Local nTamNumOp := GetSx3Cache("C2_NUM","X3_TAMANHO")
    Local nTamItmOp := GetSx3Cache("C2_ITEM","X3_TAMANHO")
    Local nTamSeqOp := GetSx3Cache("C2_SEQUEN","X3_TAMANHO")
    Local nTamGrdOp := GetSx3Cache("C2_ITEMGRD","X3_TAMANHO")

    cPOrder := PadR(cPOrder,GetSx3Cache("D4_OP", "X3_TAMANHO"))

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"NUMBER"  , Left(cPOrder,nTamNumOp)})
	aAdd(aQryParam, {"ITEM"    , SubStr(cPOrder,nTamNumOP + 1,nTamItmOP)})
	aAdd(aQryParam, {"SEQUENCE", SubStr(cPOrder,nTamNumOP + nTamItmOP + 1,nTamSeqOP)})
	aAdd(aQryParam, {"GRID"    , SubStr(cPOrder,nTamNumOP + nTamItmOP + nTamSeqOP + 1,nTamGrdOP)})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a fun��o para retornar os dados.
	aReturn := PORDERGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} PORDERGet
Executa o processamento do m�todo GET de acordo com os par�metros recebidos.

@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param lLista   , Logic    , Indica se dever� retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Static Function PORDERGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Inst�ncia da classe MRPApi para o m�todo GET

	//Seta os par�metros de pagina��o, filtros e campos para retorno
	oMRPApi:setFields(cFields)
	oMRPApi:setPage(nPage)
	oMRPApi:setPageSize(nPageSize)
	oMRPApi:setQueryParams(aQuery)
	oMRPApi:setUmRegistro(!lLista)

	//Executa o processamento
	aReturn[1] := oMRPApi:processar("fields")
	//Retorna o status do processamento
	aReturn[3] := oMRPApi:getStatus()
	If aReturn[1]
		//Se processou com sucesso, recupera o JSON com os dados.
		aReturn[2] := oMRPApi:getRetorno(1)
	Else
		//Ocorreu algum erro no processo. Recupera mensagem de erro.
		aReturn[2] := oMRPApi:getMessage()
	EndIf

	//Libera o objeto MRPApi da mem�ria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} defMRPApi
Faz a inst�ncia da classe MRPAPI e seta as propriedades b�sicas.

@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param cMethod  , Character, M�todo que ser� executado (GET/POST/DELETE)
@param cOrder   , Character, Ordena��o para o GET
@return oMRPApi , Object   , Refer�ncia da classe MRPApi com as defini��es j� executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabe�alho)
	oMRPApi:setAPIMap("fields", _aMapOrd , "SC2", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields", {"C2_FILIAL","C2_NUM","C2_ITEM","C2_SEQUEN","C2_ITEMGRD"})

	//If cMethod == "POST"
	//	//Seta as fun��es de valida��o de cada mapeamento.
	//	oMRPApi:setValidData("fields", "PORDVLD")
	//EndIf

Return oMRPApi

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da tabela SC2
@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()

	Local aFields := {}
    aFields := {;
                {"branchId"         , "C2_FILIAL" , "C", FWSizeFilial()                        , 0 },;
                {"number"           , "C2_NUM"    , "C", GetSx3Cache("C2_NUM","X3_TAMANHO")    , 0 },;
                {"item"             , "C2_ITEM"   , "C", GetSx3Cache("C2_ITEM","X3_TAMANHO")   , 0 },;
                {"sequence"         , "C2_SEQUEN" , "C", GetSx3Cache("C2_SEQUEN","X3_TAMANHO") , 0 },;
                {"grid"             , "C2_ITEMGRD", "C", GetSx3Cache("C2_ITEMGRD","X3_TAMANHO"), 0 },;
                {"productionOrder"  , "C2_OP"     , "C", GetSx3Cache("C2_OP","X3_TAMANHO")     , 0 },;
				{"itemCode"         , "C2_PRODUTO", "C", GetSx3Cache("C2_PRODUTO","X3_TAMANHO"), 0 },;
                {"quantity"         , "C2_QUANT"  , "N", GetSx3Cache("C2_QUANT","X3_TAMANHO")  , GetSx3Cache("C2_QUANT","X3_DECIMAL") },;
                {"reportQuantity"   , "C2_QUJE"   , "N", GetSx3Cache("C2_QUJE","X3_TAMANHO")   , GetSx3Cache("C2_QUJE","X3_DECIMAL") } ,;
				{"unitOfMeasureCode", "C2_UM"     , "C", GetSx3Cache("C2_UM","X3_TAMANHO")     , 0 },;
				{"requestOrderCode" , "C2_PEDIDO" , "C", GetSx3Cache("C2_PEDIDO","X3_TAMANHO") , 0 },;
				{"warehouseCode"    , "C2_LOCAL"  , "C", GetSx3Cache("C2_LOCAL","X3_TAMANHO")  , 0 },;
                {"startOrderDate"   , "C2_DATPRI" , "D", 8                                     , 0 },;
                {"endOrderDate"     , "C2_DATPRF" , "D", 8                                     , 0 },;
                {"scriptCode"       , "C2_ROTEIRO", "C", GetSx3Cache("C2_ROTEIRO","X3_TAMANHO"), 0 };
			   }
Return aFields

/*/{Protheus.doc} getDate
Formata uma string de data no formato AAAAMMDD para o formato AAAA-MM-DD

@type  Static Function
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param cData, Character, Data no formato AAAAMMDD
@return cData, Character, Data no formato AAAA-MM-DD
/*/
Static Function getDate(dData)
	Local cData := ""
	If !Empty(dData)
		cData := Left(dData, 4) + "-" + SubStr(dData, 5, 2) + "-" + Right(dData, 2)
	EndIf
Return cData

/*/{Protheus.doc} POrdMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  parffit.silva
@since   26/10/2020
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function POrdMap()
Return {_aMapOrd}

/*/{Protheus.doc} lblStatusPO
Retorna uma string com o nome do status da OP de acordo com o n�mero do status.
@type  Static Function
@author Lucas Fagundes
@since 28/02/2023
@version P12
@param cNumStatus, Caracter, N�mero do status para conver��o.
@return cStatus, Caracter, Status da OP convertido.
/*/
Static Function lblStatusPO(cNumStatus)
	Local cStatus := ""

	Do Case
		Case cNumStatus == "1"
			cStatus := STR0011 // "Prevista"
		Case cNumStatus == "2"
			cStatus := STR0012 //"Em aberto"
		Case cNumStatus == "3"
			cStatus := STR0013 // "Iniciada"
		Case cNumStatus == "4"
			cStatus := STR0014 //"Ociosa"
		Case cNumStatus == "5"
			cStatus := STR0015 //"Encerrada parcialmente"
		Case cNumStatus == "6"
			cStatus := STR0016 //"Encerrada totalmente"
	EndCase

Return cStatus

/*/{Protheus.doc} pcpPegFilt
Monta o filtro LIKE para os filtros da tela de rastreabilidade.
@type  Function
@author Lucas Fagundes
@since 14/03/2023
@version P12
@param 01 cFiltro, Caracter, Conteudo do filtro que ser� filtrado.
@param 02 cCampo , Caracter, Campo que ser� filtrado na query.
@return cFilQry, Caracter, Query para filtrar o campo com o conteudo do filtro.
/*/
Function pcpPegFilt(cFiltro, cCampo)
	Local aFiltros := {}
	Local cFilQry  := ""
	Local nIndex   := 0
	Local nTotal   := 0

	aFiltros := StrToKArr2(cFiltro, ",", .T.)
	nTotal := Len(aFiltros)

	If nTotal > 1
		cFilQry += " ( "
		
		For nIndex := 1 To nTotal
			cFilQry += cCampo + " LIKE '%" + AllTrim(aFiltros[nIndex]) + "%' "

			If nIndex < nTotal
				cFilQry += " OR "
			EndIf
		Next
		
		cFilQry += " ) "
	Else
		cFilQry += " " + cCampo + " LIKE '%" + AllTrim(aFiltros[nTotal]) + "%' "
	EndIf

	aSize(aFiltros, 0)
Return cFilQry

/*/{Protheus.doc} PCPEmpPegg
Busca os empenhos para exibir na tela de rastreabilidade da demandas do MRP.
@type  Function
@author Lucas Fagundes
@since 15/03/2023
@version P12
@param 01 cProdOrd , Caracter, Filtro das ordens de produ��es para consulta.
@param 02 nPageSize, Numerico, Tamanho da p�gina a ser buscada.
@param 03 nPage    , Numerico, Numero da p�gina a ser buscada.
@param 04 cDocument, Caracter, Filtro dos documentos para a consulta.
@return aReturn, Array, Array com os dados para retorno da API.
/*/
Function PCPEmpPegg(cProdOrd, nPageSize, nPage, cDocument)
	Local aReturn := {.T., "", 200}
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local nCount  := 0
	Local nStart  := 0
	Local oDados  := JsonObject():New()
	Local oJsAux  := Nil

	Default nPage     := 1
	Default nPageSize := 20

	cQuery +=  " SELECT SD4.D4_FILIAL  branchId, "
	cQuery +=         " SD4.D4_OP      productionOrder, "
	cQuery +=         " SD4.D4_COD     product, "
	cQuery +=         " SD4.D4_LOCAL   warehouse, "
	cQuery +=         " SD4.D4_DATA    allocationDate, "
	cQuery +=         " SD4.D4_QUANT   quantity, "
	cQuery +=         " SD4.D4_TRT     sequence, "
	cQuery +=         " SD4.D4_LOTECTL lot, "
	cQuery +=         " SD4.D4_NUMLOTE sublot, "
	cQuery +=         " SD4.D4_DTVALID expirationDate, "
	cQuery +=         " SD4.D4_OPERAC  operation, "
	cQuery +=         " SD4.D4_OPORIG  originalProductionOrder "
	cQuery +=    " FROM " + RetSqlName("SD4") + " SD4 "
	cQuery +=   " WHERE SD4.D4_FILIAL = '" + xFilial("SD4") + "' "
	If !Empty(cProdOrd)
		cQuery += " AND " + pcpPegFilt(cProdOrd, "SD4.D4_OP")
	EndIf
	cQuery +=     " AND EXISTS(SELECT 1 " 
	cQuery +=                  " FROM " + RetSqlName("SMH") + " SMH "
	cQuery +=                 " WHERE SMH.MH_FILIAL  = '" + xFilial("SMH") + "' "
	cQuery +=                   " AND SMH.MH_TPDCENT = '1' "
	cQuery +=                   " AND SMH.MH_NMDCENT = SD4.D4_OP "
	If !Empty(cDocument)
		cQuery +=               " AND " + pcpPegFilt(cDocument, "SMH.MH_DEMDOC")
	EndIf
	cQuery +=                   " AND SMH.D_E_L_E_T_ = ' ') "
	cQuery +=     " AND SD4.D_E_L_E_T_ = ' ' "
	cQuery +=   " ORDER BY SD4.D4_FILIAL, "
	cQuery +=            " SD4.D4_OP, "
	cQuery +=            " SD4.D4_DATA "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If nPage > 1
		nStart := ((nPage - 1) * nPageSize)
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oDados["items"] := {}

	while (cAlias)->(!EoF())
		oJsAux := JsonObject():New()

		oJsAux["branchId"               ] := (cAlias)->branchId
		oJsAux["productionOrder"        ] := (cAlias)->productionOrder
		oJsAux["product"                ] := (cAlias)->product
		oJsAux["warehouse"              ] := (cAlias)->warehouse
		oJsAux["allocationDate"         ] := getDate((cAlias)->allocationDate)
		oJsAux["quantity"               ] := (cAlias)->quantity
		oJsAux["sequence"               ] := (cAlias)->sequence
		oJsAux["lot"                    ] := (cAlias)->lot
		oJsAux["sublot"                 ] := (cAlias)->sublot
		oJsAux["expirationDate"         ] := getDate((cAlias)->expirationDate)
		oJsAux["operation"              ] := (cAlias)->operation
		oJsAux["originalProductionOrder"] := (cAlias)->originalProductionOrder

		aAdd(oDados["items"], oJsAux)
		
		(cAlias)->(dbSkip())
		nCount++

		If nCount == nPageSize
			Exit
		EndIf
	End
	oDados["hasNext"] := (cAlias)->(!EoF())
	
	(cAlias)->(dbCloseArea())

	If Len(oDados["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := EncodeUTF8(oDados:toJson())
		aReturn[3] := 200
	Else
		aReturn[1] := .F.
		aReturn[2] := STR0010 // "Nenhum registro foi encontrado."
		aReturn[3] := 400
	EndIf

	FwFreeObj(oDados)
Return aReturn
