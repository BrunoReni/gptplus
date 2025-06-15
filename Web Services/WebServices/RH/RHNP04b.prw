#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "RHNP04.CH"

/*/{Protheus.doc} fCompany
Retorna um array com os grupos de empresa.
@author:	Henrique Ferreira
@since:		25/08/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter)
@return:	Lista os grupos de empresa.
/*/
Function fCompany(aQryParam)

Local oCompany := NIL
Local oItems   := NIL 
Local aSM0	   := FWLoadSM0()
Local aGroups  := {}
Local aItems   := {}
Local aArea    := GetArea()

Local lMorePage := .F.

Local cGroup   	 := ""
Local cFilter    := ""

Local nCount     := 0
Local nX         := 0
Local nPage		 := 1
Local nPageSize  := 10
Local nRegIni	 := 0
Local nRegFim	 := 0
Local nLenQp	 := Len( aQryParam )
Local nLenSM0    := Len( aSM0 )

For nX := 1 to nLenQp
	DO Case
		CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
			nPageSize := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "PAGE"
			nPage := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "FILTER"
			cFilter := UPPER(Alltrim(aQryParam[nX,2]))
	ENDCASE
Next nX

If nLenSM0 > 0
	// Primeiro For. Carrega os dados dos grupos de empresa.
    For nX := 1 To nLenSM0
		If !( cGroup == aSM0[nX,1] )
			cGroup := aSM0[nX,1]
			aAdd(aGroups, { aSM0[nX,1], aSM0[nX,21] } )
		EndIf
    Next nX

	//Controle de pagina��o
	//Controle de Pagina��o
	If nPage == 1
		nRegIni := 1
		nRegFim := nPageSize
	Else
		nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
		nRegFim := ( nRegIni + nPageSize ) - 1
	EndIf

	//Segundo for. busca os grupos de empresas filtradas por codigo do grupo ou descri��o.
	For nX := 1 To Len( aGroups )
		If ( Empty(cFilter) .Or. cFilter $ AllTrim( Upper( aGroups[nX,1] ) ) .Or. cFilter $ AllTrim( Upper( aGroups[nX,2] ) ) )
			nCount ++
			If ( nCount >= nRegIni .And. nCount <= nRegFim )
				oCompany			   := JsonObject():New()
				oCompany["id"] 		   := AllTrim( aGroups[nX,1] )
				oCompany["identifier"] := NIL
				oCompany["name"]       := EncodeUTF8( AllTrim( aGroups[nX,2] ) )
				aAdd( aItems, oCompany )
			Else
				If nCount >= nRegFim
					lMorePage := .T.
					Exit
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aArea)
FreeObj( oCompany )

oItems := JsonObject():New()
oItems["items"] := aItems
oItems["hasNext"] := lMorePage

Return oItems

/*/{Protheus.doc} fBranch
Retorna um array com as filiais, de acordo com a empresa passada no QP.
@author:	Henrique Ferreira
@since:		25/08/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter, CompanyId)
@return:	Lista os grupos de empresa.
/*/
Function fBranch(aQryParam)

Local oBranch  := NIL
Local oItems   := NIL
Local aArea	   := GetArea() 
Local aBranch  := {}
Local aItems   := {}
Local aSM0Data := {}
Local aFields  := { "M0_NOMECOM" , "M0_CGC" }

Local lMorePage := .F.

Local cFilter    := ""
Local cCompanyId := cEmpAnt

Local nCount     := 0
Local nX         := 0
Local nPage		 := 1
Local nPageSize  := 10
Local nRegIni	 := 0
Local nRegFim	 := 0
Local nLenQp	 := Len( aQryParam )

For nX := 1 to nLenQp
	DO Case
		CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
			nPageSize := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "PAGE"
			nPage := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "FILTER"
			cFilter := UPPER(Alltrim(aQryParam[nX,2]))
		CASE UPPER(aQryParam[nX,1]) == "COMPANYID"
			cCompanyId := UPPER(Alltrim(aQryParam[nX,2]))
	ENDCASE
Next nX

//
If !Empty( cCompanyId )

	//Busca as filiais de acordo com a empresa vinda no QP.
	aBranch := FwAllFilial( NIL, NIL, cCompanyId, .F. )

	//Controle de pagina��o
	If nPage == 1
		nRegIni := 1
		nRegFim := nPageSize
	Else
		nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
		nRegFim := ( nRegIni + nPageSize ) - 1
	EndIf

	//Segundo for. busca os grupos de empresas filtradas por codigo do grupo ou descri��o.
	If Len( aBranch ) > 0
		For nX := 1 To Len( aBranch )

			//Busca os campos do cadastro de filial, filtrando e empresa e a filial espec�fica.
			aSM0Data := FWSM0Util():GetSM0Data( cCompanyId, aBranch[nX], aFields )
			If ( Empty(cFilter) .Or. ;
			     cFilter $ AllTrim( Upper( aSM0Data[1,2] ) ) .Or. ;
				 cFilter $ AllTrim( Upper( aSM0Data[2,2] ) ) .Or. ;
				 cFilter $ AllTrim( Upper( aBranch[nX] ) ) )
				nCount ++
				If ( nCount >= nRegIni .And. nCount <= nRegFim )
					oBranch			:= JsonObject():New()
					oBranch["id"] 	:= aBranch[nX]
					oBranch["name"] := AllTrim( aSM0Data[1,2] )
					oBranch["cnpj"] := AllTrim( aSM0Data[2,2] )
					aAdd( aItems, oBranch )
				Else
					If nCount >= nRegFim
						lMorePage := .T.
						Exit
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
EndIf

RestArea(aArea)
FreeObj( oBranch )

oItems := JsonObject():New()
oItems["items"] := aItems
oItems["hasNext"] := lMorePage

Return oItems

/*/{Protheus.doc} fProcess
Retorna um array com as filiais, de acordo com a empresa passada no QP.
@author:	Henrique Ferreira
@since:		25/08/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter, CompanyId)
@return:	Lista os grupos de empresa.
/*/
Function fProcess(aQryParam, lJob, cUID)

Local oProcess := NIL
Local oItems   := NIL 
Local aItems   := {}
Local aArea	   := {}

Local lMorePage := .F.
Local lBloq		:= .F.

Local cFilter    := ""
Local cWhere	 := ""
Local cQuery     := ""
Local cCompanyId := ""
Local cBranchId	 := ""

Local nCount	 := 0
Local nX         := 0
Local nPage		 := 1
Local nPageSize  := 10
Local nRegIni	 := 0
Local nRegFim	 := 0
Local nLenQp	 := Len( aQryParam )

Default lJob := .F.
Default cUID := ""

If !lJob
	cCompanyId := cEmpAnt
	cBranchId  := cFilAnt
EndIf

For nX := 1 to nLenQp
	DO Case
		CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
			nPageSize := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "PAGE"
			nPage := Val(aQryParam[nX,2])
		CASE UPPER(aQryParam[nX,1]) == "FILTER"
			cFilter := UPPER(Alltrim(aQryParam[nX,2]))
		CASE UPPER(aQryParam[nX,1]) == "COMPANYID"
			cCompanyId := UPPER(Alltrim(aQryParam[nX,2]))
		CASE UPPER(aQryParam[nX,1]) == "BRANCHID"
			cBranchId := UPPER(Alltrim(aQryParam[nX,2]))
	ENDCASE
Next nX

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv( cCompanyId, cBranchId )
EndIf

aArea := GetArea()

If !Empty( cCompanyId )

	//Controle de pagina��o
	If nPage == 1
		nRegIni := 1
		nRegFim := nPageSize
	Else
		nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
		nRegFim := ( nRegIni + nPageSize ) - 1
	EndIf

	lBloq  := RCJ->(ColumnPos("RCJ_MSBLQL")) > 0
	cQuery := GetNextAlias()

	cWhere := "%"
	cWhere += IIf( lBloq, " AND RCJ.RCJ_MSBLQL <> '1' ", "" )
	If !Empty(cFilter)
		cWhere += " AND ((RCJ.RCJ_CODIGO LIKE '%" + cFilter + "%' )"
		cWhere += " OR (RCJ.RCJ_DESCRI LIKE '%" + cFilter + "%' ))"
	EndIf
	cWhere += "%"

	BeginSql alias cQuery
		SELECT RCJ.RCJ_CODIGO, RCJ.RCJ_DESCRI
		FROM %table:RCJ% RCJ
		WHERE 
			RCJ.RCJ_FILIAL = %exp:xFilial("RCJ", cBranchId)% AND
			RCJ.%notDel%                       
			%exp:cWhere%
	EndSql
	(cQuery)->(DbGoTop())

	While (cQuery)->(!Eof())
		nCount ++
		If ( nCount >= nRegIni .And. nCount <= nRegFim )
			oProcess := JsonObject():New()
			oProcess["id"]   := (cQuery)->RCJ_CODIGO
			oProcess["name"] := AllTrim( EncodeUTF8( (cQuery)->RCJ_DESCRI ) )
			aAdd( aItems, oProcess)
		Else
			If nCount >= nRegFim
				lMorePage := .T.
				Exit
			EndIf
		EndIf
		(cQuery)->( DbSkip() )
	EndDo
	(cQuery)->(dbCloseArea())
EndIf

RestArea( aArea )
FreeObj( oProcess )

oItems := JsonObject():New()
oItems["items"] := aItems
oItems["hasNext"] := lMorePage

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

Return oItems

Function saveTransfer( cBody, cBranchVld, cMatSRA, cCodRD0, cMsg, oItem )

// Vari�veis do Body
Local aIdFunc		:= {}
Local cName			:= ""
Local cIdDepto		:= ""
Local cIdCompany	:= ""
Local cIdBranch		:= ""
Local cIdProcess	:= ""

//Dados do funcion�rio que sofrer� a a��o.
Local cFilFunc		:= ""
Local cMatFunc		:= ""
Local cEmpFunc		:= ""

Local nSupLevel		:= 0
Local aVision		:= {}
Local cJustify		:= ""
Local cVision	 	:= ""
Local cEmpApr		:= ""
Local cFilApr		:= ""
Local cApprover		:= ""
Local cDeptoDesc    := ""
Local cCostDesc     := ""
Local cProcDesc     := ""
Local cTypeReq		:= "4" 				//Tranfer�ncia
Local cRoutine		:= "W_PWSA140.APW" 	//Transfer�ncia
Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")
Local cMsgDefault	:= AllTrim( STR0037 + Space(1) + dToC(date()) +" - "+ Time() ) //"Cadastrado via Meu RH em:"
Local lRet			:= .T.

Local oRequest			:= WSClassNew("TRequest")
Local oTransferRequest	:= WSClassNew("TTransfer")

Private cMRrhKeyTree := ""

DEFAULT oItem := JsonObject():New()

oItem:FromJson(cBody)

//Dados da requisi��o de transfer�ncia.
cJustify	:= If( oItem:hasProperty("justify") .And. !(oItem["justify"] == Nil) .And. !Empty(oItem["justify"]), AllTrim(oItem["justify"]), cMsgDefault ) //Justificativa
cIdDepto	:= If( oItem:hasProperty("department") .And. !(oItem["department"] == Nil) .And. !(oItem["department"]["id"] == Nil) .And. !Empty(oItem["department"]["id"]), AllTrim( oItem["department"]["id"] ), "") //C�digo Departamento
cIdCost	    := If( oItem:hasProperty("costCenter") .And. !(oItem["costCenter"] == Nil) .And. !(oItem["costCenter"]["id"] == Nil) .And. !Empty(oItem["costCenter"]["id"]), AllTrim( oItem["costCenter"]["id"] ), "") //C�digo Centro de custo
cIdCompany	:= If( oItem:hasProperty("company") .And. !(oItem["company"] == Nil) .And. !(oItem["company"]["id"] == Nil ) .And. !Empty(oItem["company"]["id"]), oItem["company"]["id"], "" ) // Empresa
cIdBranch   := If( oItem:hasProperty("branch") .And. !(oItem["branch"] == Nil) .And. !(oItem["branch"]["id"] == Nil) .And. !Empty(oItem["branch"]["id"]), oItem["branch"]["id"], "") // Filial
cIdProcess	:= If( oItem:hasProperty("process") .And. !(oItem["process"] == Nil) .And. !(oItem["process"]["id"] == Nil) .And. !Empty(oItem["process"]["id"]), oItem["process"]["id"], "" ) // Processo
cName  	    := If( oItem:hasProperty("employeesRequisitions") .And. !(oItem["employeesRequisitions"] == Nil) .And. !(oItem["employeesRequisitions"]["name"] == Nil) .And. !Empty(oItem["employeesRequisitions"]["name"]), AllTrim( oItem["employeesRequisitions"]["name"] ), "" ) // Dados do Funcion�rio
aIdFunc		:= If( oItem:hasProperty("employeesRequisitions") .And. !(oItem["employeesRequisitions"] == Nil) .And. !(oItem["employeesRequisitions"]["id"] == Nil) .And. !Empty(oItem["employeesRequisitions"]["id"]), StrTokArr( oItem["employeesRequisitions"]["id"], "|" ) , {} ) // Dados do Funcion�rio
cDeptoDesc  := If( oItem:hasProperty("department") .And. !(oItem["department"] == Nil) .And. !(oItem["department"]["name"] == Nil), oItem["department"]["name"], "")
cCostDesc   := If( oItem:hasProperty("costCenter") .And. !(oItem["costCenter"] == Nil) .And. !(oItem["costCenter"]["name"] == Nil), oItem["costCenter"]["name"], "")
cProcDesc   := If( oItem:hasProperty("process") .And. !(oItem["process"] == Nil) .And. !(oItem["process"]["name"] == Nil), oItem["process"]["name"], "")

// Obriga o preenchimento de pelo menos um campo na requisi��o
If Empty( cIdDepto ) .And. Empty( cIdCost ) .And. Empty( cIdBranch ) .And. Empty( cIdCompany ) .And. Empty( cIdProcess )
	cMsg :=  EncodeUTF8( STR0062 ) //"� necess�rio preencher algum dado na requisi��o."
	Return .F.
EndIf

If !Empty( cJustify ) .And. ( Len(cJustify) > 50 .Or. Len(cJustify) < 3 )
	cMsg := EncodeUTF8( STR0067 ) //"A justificativa deve ter no m�nimo 3 e no m�ximo 50 caracteres!"
	Return .F.
EndIf

If Len( aIdFunc ) >= 3  

	cFilFunc := aIdFunc[1]
	cMatFunc := aIdFunc[2]
	cEmpFunc := aIdFunc[3]

	//Verifica se j� existe uma altera��o salarial pendente de aprova��o.
	If fVerPendRH3( cEmpFunc, cFilFunc, cMatFunc, '4', {"1","4"} )
		cMsg :=  EncodeUTF8( STR0052 ) //"J� existe solicita��o pendente de aprova��o para este funcion�rio!"
		Return .F.
	EndIf	

	aVision := GetVisionAI8(cRoutine, cBranchVld)
	cVision := aVision[1][1]

	// -------------------------------------------------------------------------------------------
	// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicita��o.
	//- -------------------------------------------------------------------------------------------
	cMRrhKeyTree:= fMHRKeyTree(cBranchVld, cMatSRA)
	aGetStruct := APIGetStructure( cCodRD0, cOrgCFG, cVision, cBranchVld, cMatSRA, , , ,cTypeReq, cBranchVld, cMatSRA, , , , , .T., {cEmpAnt}, , , .T.)

	If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
		cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
		cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
		nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
		cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
	EndIf

	//Dados do cabecalho da requisicao
	oRequest:Branch 				:= cFilFunc
	oRequest:Registration			:= cMatFunc
	oRequest:ApproverBranch			:= cFilApr
	oRequest:ApproverRegistration 	:= cApprover
	oRequest:EmpresaAPR				:= cEmpApr
	oRequest:Empresa				:= cEmpFunc
	oRequest:StarterBranch			:= cBranchVld
	oRequest:StarterRegistration	:= cMatSRA
	oRequest:ApproverLevel		    := nSupLevel
	oRequest:Vision					:= cVision
	oRequest:Observation			:= DecodeUTF8(cJustify)

	//Dados dos itens da requisicao
	oTransferRequest:Company			    := cIdCompany	// Empresa Para
	oTransferRequest:Branch				    := cIdBranch	// Filial Para
	oTransferRequest:Name				    := cName        // Nome
	oTransferRequest:CostCenter			    := cIdCost		// Centro de Custo Para
	oTransferRequest:Department			    := cIdDepto		// Departamento Para
	oTransferRequest:Process			    := cIdProcess	// Processo Para
	oTransferRequest:DepartmentDescription  := cDeptoDesc   // Descri��o Departamento Para
	oTransferRequest:CostCenterDescription  := cCostDesc    // Descri��o Centro de Custo Para
	oTransferRequest:ProcessDescription     := cProcDesc    // Descri��o Processo Para

	AddTransferRequest( oRequest, oTransferRequest, "MEURH", .T., @cMsg ) 
	lRet := Empty(cMsg)
EndIf

Return lRet
