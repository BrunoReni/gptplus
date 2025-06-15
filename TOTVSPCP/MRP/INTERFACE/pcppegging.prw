#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPPEGGING.CH"
#INCLUDE "restful.ch"
#INCLUDE "fwcommand.ch"

/*/{Protheus.doc} PCPPegging
Chamada da tela de Rastreabilidade de Demandas (dash-rastreabilidade PO-UI).

@type  Function
@author parffit.silva
@since 03/05/2021
@version P12.1.33
@param  Nil
@return Nil
/*/
Function PCPPegging()

	If !AliasInDic("SMH")
		Help( ,, 'PCPPegging',, STR0001, 1, 0 ) //"Tabela SMH não foi encontrada no dicionário de dados! "
		Return
	EndIf

	If PCPVldApp()
		FwCallApp('pcppegging')
	EndIf 
Return

Static Function JsToAdvpl(oWebChannel,cType,cContent)
	Do Case
		Case cType == 'receberProtheus'
			// Envio um comando ADVPL para minha aplicação Web
			oWebChannel:AdvPLToJS('mensagemProtheus', DTOC(ddatabase))
	End
Return .T.


/*/{Protheus.doc} pcppegging
API para montagem das colunas da table list da rastrebalidade.

@type  WSCLASS
@author mauricio.joao
@since 02/02/2023
@version 12.1.2210
/*/

WSRESTFUL pcppegging DESCRIPTION STR0002 FORMAT APPLICATION_JSON

	WSDATA parentCode      AS string   

	WSMETHOD GET ColumnsOrder;
		DESCRIPTION STR0002;
		WSSYNTAX "api/pcp/v1/pcppegging/columns/orders" ;
		PATH "api/pcp/v1/pcppegging/columns/orders" ;
		TTALK "v1"

END WSRESTFUL

WSMETHOD GET ColumnsOrder WSRECEIVE parentCode WSSERVICE pcppegging
	Local aIcons    := Nil
	Local cJson     := ""
	Local lMrpMulti := isMRPMulti(self:parentCode)
	Local nIndex    := 0
	Local oJsonRet  := JsonObject():New()
 
	// define o tipo de retorno do método
	::SetContentType("application/json")

	oJsonRet["columns"] := JsonObject():new()	
	oJsonRet["columns"]['prodOrderColumns'] := Array(0)
	oJsonRet["columns"]['detailColumns'] := JsonObject():new()

	If lMrpMulti 
		addJson(@oJsonRet, "branchId", STR0041, "string", "80px") //"Filial"
	EndIf

	addJson(@oJsonRet, "demand"         , STR0110, "string", "120px") //"Demanda"
	addJson(@oJsonRet, "documentId"     , STR0029, "string", "120px") //"Documento"
	addJson(@oJsonRet, "productionOrder", STR0067, "link"  , "150px") //"Ordem de Produção"
	addJson(@oJsonRet, "product"        , STR0069, "string", "150px") //"Produto"
	
	If OPComOpc()
		aIcons := {JsonObject():New()}
		aIcons[1]["action" ] := "this.visualizaOpcional.bind(this)"
		aIcons[1]["icon"   ] := "po-icon-export"
		aIcons[1]["tooltip"] := STR0117 //"Visualizar opcionais"
		aIcons[1]["value"  ] := "viewOptional"
		addJson(@oJsonRet, "viewOptional", STR0068, "icon", "75px" ,,, aIcons) //"Opcional"
		aIcons := Nil
	EndIf

	addJson(@oJsonRet, "balance"       , STR0112, "number", "100px") //"Quant. OP"
	addJson(@oJsonRet, "usedQuantity"  , STR0071, "number", "100px") //"Quant. usada"
	addJson(@oJsonRet, "endDate"       , STR0032, "date"  , "90px") //"Entrega"
	addJson(@oJsonRet, "usedDate"      , STR0021, "date"  , "90px") //"Data Uso"
	addJson(@oJsonRet, "delay"         , STR0010, "number", "75px") //"Atraso"
	addJson(@oJsonRet, "status"        , STR0073, "label" , "110px",,"this.statusLabelList") //"Situação"
	addJson(@oJsonRet, "documentOrigin", STR0084, "label" , "220px",,"this.statusDocOrigem") //"Origem"
	addJson(@oJsonRet, "productDetail" , STR0026, "detail", "120px","this.detailColumns") //"Detalhes do produto"

	oJsonRet["columns"]['detailColumns']["columns"] := Array(0)

	aAdd(oJsonRet["columns"]['detailColumns']["columns"], JsonObject():new())
	nIndex := Len(oJsonRet["columns"]['detailColumns']["columns"])

	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["property"] := "productDescription"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["label"   ] := STR0022 //"Descrição do produto"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["type"    ] := "string"	

	aAdd(oJsonRet["columns"]['detailColumns']["columns"], JsonObject():new())
	nIndex := Len(oJsonRet["columns"]['detailColumns']["columns"])

	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["property"] := "startDate"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["label"   ] := STR0046 //"Início"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["type"    ] := "date"

	aAdd(oJsonRet["columns"]['detailColumns']["columns"], JsonObject():new())
	nIndex := Len(oJsonRet["columns"]['detailColumns']["columns"])

	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["property"] := "demandQuantity"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["label"   ] := STR0120 //"Quantidade da demanda"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["type"    ] := "number"

	aAdd(oJsonRet["columns"]['detailColumns']["columns"], JsonObject():new())
	nIndex := Len(oJsonRet["columns"]['detailColumns']["columns"])

	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["property"] := "lot"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["label"   ] := STR0092 //"Lote"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["type"    ] := "string"

	aAdd(oJsonRet["columns"]['detailColumns']["columns"], JsonObject():new())
	nIndex := Len(oJsonRet["columns"]['detailColumns']["columns"])

	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["property"] := "sublot"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["label"   ] := STR0093 //"Sub-lote"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["type"    ] := "string"

	aAdd(oJsonRet["columns"]['detailColumns']["columns"], JsonObject():new())
	nIndex := Len(oJsonRet["columns"]['detailColumns']["columns"])

	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["property"] := "sourceDocument"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["label"   ] := STR0089 //"OP Origem"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["type"    ] := "string"

	aAdd(oJsonRet["columns"]['detailColumns']["columns"], JsonObject():new())
	nIndex := Len(oJsonRet["columns"]['detailColumns']["columns"])

	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["property"] := "statusPO"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["label"   ] := STR0074 //"Status OP"
	oJsonRet["columns"]['detailColumns']["columns"][nIndex]["type"    ] := "string"

	oJsonRet["columns"]['detailColumns']['typeHeader'] := 'top'
	oJsonRet["columns"]['detailColumns']['hideSelect'] := 'true'

	cJson := EncodeUTF8(oJsonRet:toJson())
	::SetResponse(cJson)

Return .T.

/*/{Protheus.doc} addJson	
Adiciona uma coluna no JSON

@type  Static Function
@author mauricio.joao
@since 22/01/2023
@version 1.0
@param 01 oJson    , object   , json de construção das colunas
@param 02 cProperty, character, nome da propriedade
@param 03 cLabel   , character, label para exibição na grid
@param 04 cType    , character, tipo da propriedade
@param 05 cWidth   , character, tamanho que irá ocupar
@param 06 cDetail  , character, propriedade com as colunas que serão exibidas nos detalhes da grid
@param 07 cLabels  , character, legendas das informações
@param 08 aIcons   , Array    , array com as configurações de ícones para exibição de uma coluna do tipo icon
@return Nil
/*/
Static Function addJson(oJsonRet, cProperty, cLabel, cType, cWidth, cDetail, cLabels, aIcons)
	Local nIndex := 0

	Default cDetail  := ""
	Default cLabels  := ""

	aAdd(oJsonRet["columns"]['prodOrderColumns'], JsonObject():New())
	nIndex := Len(oJsonRet["columns"]['prodOrderColumns'])

	oJsonRet["columns"]['prodOrderColumns'][nIndex]["property"] := cProperty
	oJsonRet["columns"]['prodOrderColumns'][nIndex]["label"   ] := cLabel
	oJsonRet["columns"]['prodOrderColumns'][nIndex]["type"    ] := cType
	oJsonRet["columns"]['prodOrderColumns'][nIndex]["width"   ] := cWidth

	If !Empty(cLabels)
		oJsonRet["columns"]['prodOrderColumns'][nIndex]["labels"] := cLabels
	EndIf

	If !Empty(cDetail)
		oJsonRet["columns"]['prodOrderColumns'][nIndex]["detail"] := cDetail
	EndIf

	If !Empty(aIcons)
		oJsonRet["columns"]['prodOrderColumns'][nIndex]["icons"] := aIcons
	EndIf

Return nil

/*/{Protheus.doc} isMRPMulti
Verifica se a empresa é processada por mrp multi empresa.

@type  Static Function
@author mauricio.joao
@since 16/01/2023
@version 1.0
@param parentCode, string, código da empresa
@return lMrpMulti, logical, Retorna se a empresa é processada por mrp multi empresa.
/*/
Static Function isMRPMulti(parentCode)
	Local aArrFil   := FWArrFilAtu(cEmpAnt,parentCode)
	Local cAliasQry := GetNextAlias()
	Local cBranch   := ''
	Local cCompany  := ''
	Local cGroup    := ''
	Local cQuery    := ''
	Local cUnit     := ''
	Local lMrpMulti := .F.

	If Len(aArrFil) > 0
		cBranch  := aArrFil[SM0_FILIAL]
		cCompany := aArrFil[SM0_EMPRESA]
		cGroup   := aArrFil[SM0_GRPEMP]
		cUnit    := aArrFil[SM0_UNIDNEG]

		cQuery := "SELECT COUNT(1) ISMRPMULTI"
		cQuery += " FROM "+RetSqlName("SOP")+" SOP "
		cQuery += " WHERE SOP.D_E_L_E_T_ = ' ' "
		cQuery += " AND ((SOP.OP_CDEPCZ = '"+cGroup+"' AND SOP.OP_EMPRCZ = '"+cCompany+"' AND SOP.OP_UNIDCZ  = '"+cUnit+"' AND SOP.OP_CDESCZ  = '"+cBranch+"')"
		cQuery += " OR (SOP.OP_CDEPGR = '"+cGroup+"' AND SOP.OP_EMPRGR = '"+cCompany+"' AND SOP.OP_UNIDGR  = '"+cUnit+"' AND SOP.OP_CDESGR  = '"+cBranch+"'))"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

		If (cAliasQry)->(ISMRPMULTI) > 0
			lMrpMulti := .T.
		EndIf

		(cAliasQry)->(DbCloseArea())
		aSize(aArrFil,0)	
	EndIf

Return lMrpMulti

/*/{Protheus.doc} OPComOpc
Verifica se existem ordens de produção com opcionais na tabela de rastreabilidade (SMH)

@type  Static Function
@author lucas.franca
@since 21/03/2023
@version P12
@return lRet, Logic, Retorna se existem OPs com opcionais na rastreabilidade
/*/
Static Function OPComOpc()
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cBanco := TcGetDb()
	Local lRet   := .F.

	cQuery := " SELECT COUNT(*) TEMOPC"
	cQuery +=   " FROM " + RetSqlName("SMH") + " SMH"
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cQuery +=     " ON SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	If cBanco == "POSTGRES"
		cQuery += " AND TRIM(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD)) = SMH.MH_NMDCENT"
	Else
		cQuery += " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SMH.MH_NMDCENT"
	EndIf
	cQuery +=    " AND SC2.C2_OPC <> ' '"
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SMH.MH_FILIAL = '" + xFilial("SMH") + "' "
	cQuery +=    " AND SMH.MH_TPDCENT = '1'"
	cQuery +=    " AND SMH.MH_NMDCENT <> ' '"
	cQuery +=    " AND SMH.D_E_L_E_T_ = ' '"

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
	If (cAlias)->(TEMOPC) > 0
		lRet := .T.
	EndIf
	(cAlias)->(dbCloseArea())

Return lRet
