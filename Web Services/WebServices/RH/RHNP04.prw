#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP04.CH"

Function RHNP04()
Return .T.

Private cMRrhKeyTree := ""


WSRESTFUL Request DESCRIPTION STR0001 //"Request Notifica��es"

	WSDATA WsNull		   As String  Optional
	WSDATA employeeId	   As String  Optional
	WSDATA page			   As String  Optional
	WSDATA pageSize		   As String  Optional
	WSDATA tab  		   As String  Optional
	WSDATA type  		   As String  Optional
	WSDATA types  		   As String  Optional
	WSDATA date			   As String  Optional
	WSDATA name			   As String  Optional
	WSDATA employeeName	   As String  Optional
	WSDATA pending 		   As boolean Optional
	WSDATA requestId       As String  Optional
	WSDATA status		   As String  Optional
	WSDATA startDate	   As String  Optional
	WSDATA siteCode	       As String  Optional
	WSDATA roleDescription As String  Optional

	//****************************** GETs ***********************************
	WSMETHOD GET getCount ;
	DESCRIPTION STR0003 ; //"Retorna a quantidade de pend�ncias."
	WSSYNTAX "/notifications/count/{employeeId}" ;
	PATH "/notifications/count/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET getRequestCount ;
	DESCRIPTION STR0010 ; //"Retorna as quantidades de solicita��es do usu�rio."
	WSSYNTAX "/count/{employeeId}" ;
	PATH "/count/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET getNotifications ;
	DESCRIPTION STR0004 ; //"Retorna as pend�ncias do usu�rio."
	WSSYNTAX "/notifications/{employeeId}" ;
	PATH "/notifications/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET Requisitions ;
	DESCRIPTION STR0011 ; //"Retorna as requisi��es do usu�rio respons�vel."
	WSSYNTAX "/requisitions/{employeeId}" ;
	PATH "/requisitions/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET detailDataChange ;
	DESCRIPTION STR0026 ; //"Retorna os detalhes da requisi��o de a��o salarial."
	WSSYNTAX "/requisition/employeeDataChange/{employeeId}/{id}" ;
	PATH "/requisition/employeeDataChange/{employeeId}/{id}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET stafDetail ;
	DESCRIPTION STR0040 ; //"Retorna os detalhes da requisi��o de aumento de quadro."
	WSSYNTAX "/requisition/staffIncrease/{employeeId}/{id}" ;
	PATH "/requisition/staffIncrease/{employeeId}/{id}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET employeesRequisitions ;
	DESCRIPTION STR0024 ; //"Retorna os funcion�rios da equipe conforme o filtro para inclus�o de a��o salarial."
	WSSYNTAX "/requisitions/employees/{employeeId}" ;
	PATH "/requisitions/employees/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'	

	WSMETHOD GET jobFunctions ;
	DESCRIPTION STR0029 ; //"Retorna as fun��es que poder�o ser utilizadas na solicita��o de a��o salarial"
	WSSYNTAX "/requisitions/jobFunctions/{employeeId}" ;
	PATH "/requisitions/jobFunctions/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'	

	WSMETHOD GET jobRoles ;
	DESCRIPTION STR0030 ; //"Retorna os cargos que poder�o ser utilizadas na solicita��o de a��o salarial"
	WSSYNTAX "/requisitions/jobRoles/{employeeId}" ;
	PATH "/requisitions/jobRoles/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET department ;
	DESCRIPTION STR0047 ; //"Retorna os departamentos que poder�o ser utilizadas no aumento de quadro ou transfer�ncia."
	WSSYNTAX "/requisitions/department/{employeeId}" ;
	PATH "/requisitions/department/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET costCenter ;
	DESCRIPTION STR0048 ; //"Retorna os centros de custo que poder�o ser utilizadas no aumento de quadro ou transfer�ncia."
	WSSYNTAX "/requisitions/costCenter/{employeeId}" ;
	PATH "/requisitions/costCenter/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET salaryTypes ;
	DESCRIPTION STR0031 ; //"Retorna os tipos de a��o salarial conforme a SX5"
	WSSYNTAX "/requisitions/salaryChangeTypes/{employeeId}" ;
	PATH "/requisitions/salaryChangeTypes/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'		

	WSMETHOD GET categoryTypes ;
	DESCRIPTION STR0033 ; //"Retorna as categorias de trabalhadores da empresa"
	WSSYNTAX "/requisitions/categoryChangeType/{employeeId}" ;
	PATH "/requisitions/categoryChangeType/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET transferDetail ;
	DESCRIPTION STR0064 ; //"Retorna os detalhes de uma requisi��o de transfer�ncia"
	WSSYNTAX "/requisition/detailsTransfRequisition/{employeeId}/{id}" ;
	PATH "/requisition/detailsTransfRequisition/{employeeId}/{id}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET detTransfer ;
	DESCRIPTION STR0065 ; //"Retorna os detalhes de uma requisi��o de transfer�ncia - novo formato" 
	WSSYNTAX "/requisition/transfRequisition/{employeeId}/{id}" ;
	PATH "/requisition/transfRequisition/{employeeId}/{id}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET company ;
	DESCRIPTION STR0057 ; //"Retorna os grupos de empresa."
	WSSYNTAX "/requisitions/company/{employeeId}" ;
	PATH "/requisitions/company/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'	

	WSMETHOD GET branch ;
	DESCRIPTION STR0058 ; //"Retorna as filiais."
	WSSYNTAX "/requisitions/branch/{employeeId}" ;
	PATH "/requisitions/branch/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET process ;
	DESCRIPTION STR0059 ; //"Retorna os processos."
	WSSYNTAX "/requisitions/process/{employeeId}" ;
	PATH "/requisitions/process/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET getPendingReqCount;
 	DESCRIPTION STR0063 ; //"Retorna a quantidade de requisi��es pendentes de aprova��o agrupadas por tipo."
 	WSSYNTAX "/requisitions/count/{employeeId}";
 	PATH "/requisitions/count/{employeeId}";
	PRODUCES "application/json;charset=utf-8"

	WSMETHOD GET InfArqReq ;
	DESCRIPTION STR0068 ; //"Retorna informa��es do arquivo de anexo da requisi��o"
	WSSYNTAX "/requisitions/file/info/{id}" ;
	PATH "/requisitions/file/info/{id}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET DownArqReq ;
	DESCRIPTION STR0069 ; //"Retorna o arquivo de anexo da requisi��o"
	WSSYNTAX "/requisitions/file/download/{id}/{fileExtension}" ;
	PATH "/requisitions/file/download/{id}/{fileExtension}" ;
	PRODUCES 'image/jpeg;charset=utf-8'

	//****************************** PUTs ***********************************
	WSMETHOD PUT Requisitions ;
	DESCRIPTION STR0019 ; //"Aprova ou Reprova requisi��es do usu�rio respons�vel."
	WSSYNTAX "/requisitions/{employeeId}" ;
	PATH "/requisitions/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD PUT editNotifications ;
	DESCRIPTION STR0005 ; //"Aprova ou Reprova notifica��es."
	WSSYNTAX "/notifications/{employeeId}" ;
	PATH "/notifications/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	//****************************** POSTs ***********************************
	WSMETHOD POST ValidSalRequest ;
	DESCRIPTION STR0034 ; //"Verifica o sal�rio e o percentual de aumento de uma solicita��o de a��o salarial"
	WSSYNTAX "/requisitions/validateSalary/{employeeId}" ;
	PATH "/requisitions/validateSalary/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD POST ActionSalRequest ;
	DESCRIPTION STR0035 ; //"Inclus�o de uma solicita��o de a��o salarial"
	WSSYNTAX "/requisition/createSalaryAndFunctionRequisition/{employeeId}" ;
	PATH "/requisition/createSalaryAndFunctionRequisition/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'	

	WSMETHOD POST staffRequest ;
	DESCRIPTION STR0050 ; //"Inclus�o de uma solicita��o de aumento de quadro"
	WSSYNTAX "/requisitions/createStaffIncreaseRequisitions/{employeeId}" ;
	PATH "/requisitions/createStaffIncreaseRequisitions/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD POST transferRequest ;
	DESCRIPTION STR0060 ; //"Inclus�o da solicita��o de transfer�ncia."
	WSSYNTAX "/requisition/createTransfRequisition/{employeeId}" ;
	PATH "/requisition/createTransfRequisition/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL

//******************** M�todos GETs ********************
//******************************************************

WSMETHOD GET getCount PATHPARAM employeeId WSREST Request

	Local oItemData	 	:= JsonObject():New()
	Local oItem		 	:= JsonObject():New()
	Local oMessages	  	:= JsonObject():New()
	Local nLenParms	 	:= Len(::aURLParms)
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cToken	  	:= ""
	Local cKeyId	  	:= ""
	Local cSubMat		:= ""
	Local cSubBranch	:= ""
	Local cSubDepts		:= ""
	Local cLogin		:= ""
	Local cCodRD0		:= ""
	Local nX			:= 0
	Local aSubstitute	:= {}
	Local aMessages		:= {}
	Local aDataLogin	:= {}
	Local lAuth    		:= .T.
	Local lSubstitute	:= .F.

	DEFAULT Self:types 	:= ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin	  := aDataLogin[2]
		cCodRD0     := aDataLogin[3]
		cBranchVld := aDataLogin[5]
	EndIf

	If Empty(cMatSRA) .Or. Empty(cBranchVld)
	::SetHeader('Status', "401")

		oMessages["type"]   := "error"
		oMessages["code"]   := "401"
		oMessages["detail"] := EncodeUTF8(STR0006) //"Dados inv�lidos."

		Aadd(aMessages,oMessages)
		lAuth := .F.
	EndIf

	If lAuth .And. nLenParms == 3 .And. !Empty(::aURLParms[3])
		
		//Verifica se o funcionario esta substituindo o seu superior
		aSubstitute := fGetSupNotify( cBranchVld, cMatSRA)

		If Len(aSubstitute) > 0
			For nX := 1 To Len(aSubstitute)
				cSubBranch += "'" + aSubstitute[nX, 1] + "',"
				cSubMat	+= "'" + aSubstitute[nX, 2] + "',"
				cSubDepts += aSubstitute[nX, 3]
			Next nX
			cSubMat		:= SubStr( cSubMat, 1, Len(cSubMat)-1 )
			cSubBranch	:= SubStr( cSubBranch, 1, Len(cSubBranch)-1 )
			cSubDepts	:= SubStr( cSubDepts, 1, Len(cSubDepts)-1 )
			lSubstitute	:= .T.
		Else
			cSubMat	:= "'" + cMatSRA + "'"
			cSubBranch := "'" + cBranchVld + "'"
		EndIf

		countNotifications(cSubMat,@oItemData,cSubBranch,cSubDepts,Self:types,"notify",NIL,NIL,cBranchVld,cMatSRA,cLogin,cCodRD0)
	EndIf

	// - Por por padr�o todo objeto tem
	// - data: contendo a estrutura do JSON
	// - messages: para determinados avisos
	// - length: informativo sobre o tamanho.
	oItem["data"] 		  := oItemData
	oItem["messages"] 	  := aMessages
	oItem["length"]   	  := 1

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

	FREEOBJ( oItem )
	FREEOBJ( oItemData )
	FREEOBJ( oMessages )

Return(.T.)


WSMETHOD GET getRequestCount PATHPARAM employeeId WSREST Request

	Local oItemData	 	:= JsonObject():New()
	Local oItem		 	:= JsonObject():New()
	Local oMessages	  	:= JsonObject():New()
	Local nLenParms	 	:= Len(::aURLParms)
	Local nTotReq		:= 0
	Local nTotPend		:= 0
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cToken	  	:= ""
	Local cKeyId	  	:= ""
	Local cRD0Login		:= ""
	Local cCodRD0		:= ""
	Local aMessages		:= {}
	Local aDataLogin	:= {}
	Local lAuth    		:= .T.

	DEFAULT Self:type 	:= ""
	DEFAULT Self:types 	:= ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cRD0Login  := aDataLogin[2]
		cCodRD0    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
	EndIf

	If Empty(cMatSRA) .Or. Empty(cBranchVld)
	::SetHeader('Status', "401")

		oMessages["type"]   := "error"
		oMessages["code"]   := "401"
		oMessages["detail"] := EncodeUTF8(STR0006) //"Dados inv�lidos."
		Aadd(aMessages,oMessages)
		lAuth := .F.
	EndIf

	If nLenParms > 0
		//varinfo("::aUrlParms -> ",::aUrlParms) 
		If (::aUrlParms[2] != "%7Bcurrent%7D") .and. (::aUrlParms[2] != "{current}")
			If !Empty(::aUrlParms[2])
		
				aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
				If Len(aIdFunc) > 1 
				
					//valida se o solicitante da requisi��o pode ter acesso as informa��es
						If getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2])
							cBranchVld	:= aIdFunc[1]
							cMatSRA		:= aIdFunc[2]
						Else
							cBranchVld	:= ""
							cMatSRA		:= ""
					EndIf	
				EndIf

			EndIf
		EndIf
		
		If !Empty(cBranchVld) .And. !Empty(cMatSRA)
			countNotifications( cMatSRA, @oItemData, cBranchVld, "", Self:types, "count", @nTotReq, @nTotPend, NIL, NIL, cRD0Login, cCodRD0 )
		ENDIF
	EndIF

	oItem["totalPending"] := nTotPend
	oItem["totalRequest"] := nTotReq
	oItem["subTotals"] 	  := oItemData

	cJson := oItem:toJson()
	Self:SetResponse(cJson)

	FREEOBJ( oItem )
	FREEOBJ( oItemData )
	FREEOBJ( oMessages )

Return(.T.)


WSMETHOD GET getNotifications PATHPARAM employeeId WSREST Request
	Local oItemData	 	:= JsonObject():New()
	Local oItem		 	:= JsonObject():New()
	Local oMessages		:= JsonObject():New()
	Local nX			:= 0
	Local nCount		:= 0
	Local nIniCount		:= 0
	Local nFimCount 	:= 0
	Local aQPs          := {}
	Local aMessages		:= {}
	Local aItems		:= {}
	Local aDataLogin	:= {}
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cMatSRA		:= ""
	Local cMatLogin		:= ""
	Local cBranchVld	:= ""
	Local cSubMat		:= ""
	Local cSubBranch	:= ""
	Local cSubDepts		:= ""
	Local cTypeFilter	:= ""
	Local lAuth			:= .T.

	// - Par�metros enviados pela URL - QueryString
	DEFAULT self:tab			:= ""
	DEFAULT Self:type 			:= ""
	DEFAULT self:date 			:= ""
	DEFAULT self:page			:= "*"
	DEFAULT self:pageSize  		:= "6"
	DEFAULT self:employeeName	:= ""

	Aadd(aQPs,self:tab)
	Aadd(aQPs,self:type)
	Aadd(aQPs,self:date)
	Aadd(aQPs,self:page)
	Aadd(aQPs,self:pageSize)
	Aadd(aQPs,self:employeeName)

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken      := Self:GetHeader('Authorization')
	cKeyId      := Self:GetHeader('keyId')
	cTypeFilter := Self:type
	aDataLogin 	:= GetDataLogin(cToken,,cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA     := aDataLogin[1]
		cMatLogin   := aDataLogin[2]
		cBranchVld  := aDataLogin[5]
	EndIf

	If Empty(cMatSRA) .Or. Empty(cBranchVld)
		oMessages["type"]   := "info"
		oMessages["code"]   := "401"
		oMessages["detail"] := EncodeUTF8(STR0007) //"As notifica��es n�o foram encontradas."

		Aadd(aMessages,oMessages)
		lAuth := .F.
	EndIf

	If lAuth
		//Verifica se o funcionario esta substituindo o seu superior
		aSubstitute := fGetSupNotify( cBranchVld, cMatSRA)

		If Len(aSubstitute) > 0
			For nX := 1 To Len(aSubstitute)
				cSubMat	+= "'" + aSubstitute[nX, 2] + "',"
				cSubBranch += "'" + aSubstitute[nX, 1] + "',"
				cSubDepts += aSubstitute[nX, 3]
			Next nX
			cSubMat		:= SubStr( cSubMat, 1, Len(cSubMat)-1 )
			cSubBranch	:= SubStr( cSubBranch, 1, Len(cSubBranch)-1 )
			cSubDepts	:= SubStr( cSubDepts, 1, Len(cSubDepts)-1 )
			cMatLogin	:= "" //Quando substitui seu gestor o funcionario pode ver suas proprias solicitacoes
		Else
			cSubMat	:= "'" + cMatSRA + "'"
			cSubBranch := "'" + cBranchVld + "'"
		EndIf

		//Faz o controle de paginacao
		If Self:page == "*" .Or. Empty(Self:page)
			// o objetivo do caracter '*' � de manter a compatibilidade com vers�es anteriores
			// que n�o realizam pagina��o, nesse caso o QP Page n�o foi informado na URL, onde 
			// a quantidade de registro devolvido n�o deve ser limitado pela pagina��o 
			nIniCount := 1 
			nFimCount := 999999
		Else
			nIniCount := ( Val(Self:pageSize) * ( Val(Self:page) - 1 ) ) + 1
			nFimCount := ( nIniCount + Val(Self:pageSize) ) - 1
		EndIf

		getNotifications(cSubMat,@oItemData,cSubBranch,@aItems,aQPs,cMatSRA,cSubDepts,@nCount,nIniCount,nFimCount,cBranchVld)
	EndIf

	oItem["hasNext"]	:= (nCount > nFimCount)
	oItem["items"]		:= aItems

	cJson := FWJsonSerialize(oItem, .F., .F., .T.)
	::SetResponse(cJson)

Return(.T.)


WSMETHOD GET Requisitions PATHPARAM employeeId WSREST Request
	Local oItems		:= JsonObject():New()
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cType         := ""
	Local cWhere		:= "%"
	Local cFiltro		:= ""
	Local cFiltFunc     := ""
	Local cFiltResp     := ""
	Local cTypeParam    := ""
	Local cPermissao    := ""
	Local lOrgCfg1      := SuperGetMv("MV_ORGCFG", NIL ,"0") == "1"

	LocaL aData 		:= {}
	Local aIdFunc       := {}
	Local aDataLogin	:= {}
	Local lHabil        := .T.
	Local lNomeSoc     := SuperGetMv("MV_NOMESOC", NIL, .F.)
	Local nCount		:= 0
	Local nIniCount		:= 0
	Local nFimCount 	:= 0

	DEFAULT self:startDate := ""
	DEFAULT self:status    := ""
	DEFAULT self:name      := ""
	DEFAULT self:requestId := ""
	DEFAULT self:types     := ""
	DEFAULT self:pending   := .F.
	DEFAULT self:page      := "1"
	DEFAULT self:pageSize  := "6"

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId      := Self:GetHeader('keyId')
	aDataLogin  := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
	cMatSRA    := aDataLogin[1]
	cLogin	  := aDataLogin[2]
	cRD0Cod	  := aDataLogin[3]
	cBranchVld := aDataLogin[5]
	EndIf

	If Len(::aUrlParms) > 0
		If (::aUrlParms[2] != "%7Bcurrent%7D") .and. (::aUrlParms[2] != "{current}")
			If !Empty(::aUrlParms[2])

				aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
				If Len(aIdFunc) > 1 
				
					//valida se o solicitante da requisi��o pode ter acesso as informa��es
					If getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2])
					cBranchVld	:= aIdFunc[1]
					cMatSRA		:= aIdFunc[2]
					Else
					cBranchVld	:= ""
					cMatSRA		:= ""
					EndIf	
				EndIf

			EndIf
		EndIf
	EndIF

	If !Empty(cBranchVld) .And. !Empty(cMatSRA)

		//Valida permiss�es e preenche tipo de requisi��o (cType).
		If !empty(Self:types)
			cTypeParam := Self:types
			If UPPER(cTypeParam) == "DEMISSION"
				cType += "'6'"
			ElseIf UPPER(cTypeParam) == "EMPLOYEEDATACHANGE"
				cType += "'7'"
				cPermissao := EncodeUTF8(STR0025) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o."
			ElseIf UPPER(cTypeParam) == "STAFFINCREASE"
				fPermission(cBranchVld, cLogin, cRD0Cod, "staffIncrease", @lHabil)
				lHabil := lHabil .And. lOrgCfg1
				cType  += "'3'"
				cPermissao := EncodeUTF8(STR0039) //"Permiss�o negada para aumento de quadro"
			ElseIf UPPER(cTypeParam) == "TRANSFER"
				fPermission(cBranchVld, cLogin, cRD0Cod, "transfer", @lHabil)
				cType += "'4'"
				cPermissao := EncodeUTF8(STR0049) //"Permiss�o negada para transfer�ncias"
			EndIf
		EndIf

		If lHabil
			If Self:pending
				cWhere += " RH3.RH3_FILAPR = '" + cBranchVld + "' AND "
				cWhere += " RH3.RH3_MATAPR = '" + cMatSRA    + "' "
			Else
				cWhere += " ("
				cWhere += " (RH3.RH3_FILINI = '" + cBranchVld + "' AND "
				cWhere += " RH3.RH3_MATINI = '" + cMatSRA    + "') OR "
				cWhere += " (RH3.RH3_FILAPR = '" + cBranchVld + "' AND "
				cWhere += " RH3.RH3_MATAPR = '" + cMatSRA    + "') "
				cWhere += ") "
			ENDIF

			If !Empty(Self:siteCode)
				cWhere += " AND ( RH3.RH3_FILIAL LIKE '%" + UPPER(Self:siteCode) + "%' ) "
			EndIf

			//Para requisi��o salarial filtra pela SRA
			//Para requisi��o de aumento de quadro filtra pelo nome do respons�vel.
			If !empty(Self:name)
				If (cType == "'3'")
					cFiltResp := UPPER(Self:name)
				Else
					cFiltro := " AND ( SRA.RA_NOME LIKE '%" + UPPER(Self:name) + "%' "
					cFiltro += " OR SRA.RA_NOMECMP LIKE '%" + UPPER(Self:name) + "%' "
					cFiltro += If(lNomeSoc, " OR SRA.RA_NSOCIAL LIKE '%" + UPPER(Self:name) + "%' ", "")
					cFiltro += ") "
				EndIf
			ENDIF

			If !Empty(Self:roleDescription)
				cFiltFunc := UPPER(Self:roleDescription)
			EndIf

			If !empty(Self:requestId)
				cWhere += "AND RH3.RH3_CODIGO = '" +Self:requestId + "' "
			ENDIF

			If !empty(Self:startDate)
				cWhere += "AND RH3.RH3_DTSOLI = '" +  dTos( cTod( Format8601( .T., Self:startDate ) ) ) + "' "
			ENDIF

			If !empty(Self:status)
				cWhere += "AND "

				If UPPER(Self:status) == "APPROVED"
					cWhere += "RH3.RH3_STATUS = '2' "
				ElseIf  UPPER(Self:status) == "APPROVING"
					cWhere += "RH3.RH3_STATUS IN ('1','4') "
				ElseIf UPPER(Self:status) == "REJECTED"
					cWhere += "RH3.RH3_STATUS = '3' "
				ElseIf UPPER(Self:status) == "CLOSED"
					cWhere += "RH3.RH3_STATUS IN ('2','3') "
				Else
					cWhere += "RH3.RH3_STATUS IN ('1','2','3','4') "
				EndIf
			EndIf

			If !empty(cType)
				cWhere += "AND RH3.RH3_TIPO IN (" +cType +") "
			Endif

			cWhere += "%"

			//Faz o controle de paginacao
			If Self:page == "1" .Or. Empty(Self:page)
				nIniCount := 1 
				nFimCount := If( Empty(Self:pageSize), 6, Val(Self:pageSize) )
			Else
				nIniCount := ( Val(Self:pageSize) * ( Val(Self:page) - 1 ) ) + 1
				nFimCount := ( nIniCount + Val(Self:pageSize) ) - 1
			EndIf

			//Requisi��es de demiss�o.
			aData := fRequests(cBranchVld, cMatSRA, cWhere, @nCount, nIniCount, nFimCount, cFiltro, cFiltFunc, cFiltResp)
			
			oItems["hasNext"] := (nCount > nFimCount)
			oItems["items"]   := aData
		Else
			SetRestFault(400, cPermissao) //"STROO25 - Permiss�o negada para altera��o de sal�rio cargo ou fun��o."
			Return (.F.)
		EndIf
	Else
		oItems["type"]   := "error"
		oItems["code"]   := "401"
		oItems["detail"] := EncodeUTF8(STR0006) //"Dados inv�lidos."
	EndIf

	cJson := oItems:ToJson()
	Self:SetResponse(cJson)

Return(.T.)


WSMETHOD GET employeesRequisitions PATHPARAM employeeId WSREST Request

	Local aDataLogin    := {}
	Local aQryParam     := {}
	Local aItemData     := {}
	Local cToken        := ""
	Local cKeyId        := ""
	Local oItem         := JsonObject():New()
	Local lMorePages	:= .F.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	aQryParam  := Self:aQueryString

	aItemData  := fGetEmpReq(aDataLogin, aQryParam, @lMorePages)

	oItem["hasNext"] := lMorePages
	oItem["items"]   := aItemData

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)

WSMETHOD GET detailDataChange PATHPARAM employeeId, id WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aIdReq		:= {}

	Local cJson			:= ""
	Local cMatSRA		:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cIdCrypt      := ""
	Local cLogin		:= ""
	Local cRoutine		:= "W_PWSA120.APW"

	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA    	:= aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
	EndIf

	If  Len(::aUrlParms) > 1 .And. !Empty(::aUrlParms[4])
		cIdCrypt := rc4crypt(::aUrlParms[4], "MeuRH#Requisicao", .F., .T.)
		aIdReq   := STRTOKARR(cIdCrypt, "|")
		If Len(aIdReq) > 1
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "employeeDataChange", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
				Return(.F.)
			//valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf !getPermission(cBranchVld, cMatSRA, aIdReq[1], aIdReq[2], cEmpAnt, aIdReq[3], cRoutine)
				SetRestFault(400, EncodeUTF8( STR0027 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
				Return(.F.)
			EndIf
			oRet := fDetailReq(cBranchVld, cMatSRA, aIdReq)
		EndIf
	EndIf


	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET jobFunctions PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aId			:= {}
	Local aQryParam 	:= Self:aQueryString

	Local nX			:= 0
	Local nPage			:= 1
	Local nPageSize		:= 10

	Local cFilter		:= ""
	Local cJson			:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cLogin		:= ""
	Local cCodEmp		:= cEmpAnt
	Local cCodFil		:= ""

	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
		cCodFil     := cBranchVld
	EndIf

	fPermission(cBranchVld, cLogin, cRD0Cod, "employeeDataChangeRequest", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
		Return(.F.)
	EndIf

	If Len(aQryParam) > 0
		For nX := 1 to Len(aQryParam)
			DO Case
				CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
					nPageSize := Val(aQryParam[nX,2])
				CASE UPPER(aQryParam[nX,1]) == "PAGE"
					nPage := Val(aQryParam[nX,2])
				CASE UPPER(aQryParam[nX,1]) == "IDDEPARTMENT"
					aId := StrTokArr(aQryParam[nX,2], "|" )
				CASE UPPER(aQryParam[nX,1]) == "FILTER"
					cFilter := Upper( AllTrim(aQryParam[nX,2]) )
			ENDCASE
		Next nX
		If Len(aId) >= 2
			cCodEmp := aId[1]
			cCodFil := aId[2]
		EndIF
		oRet := GetDataForJob("17", { cCodEmp, cCodFil, nPage, nPageSize, cFilter }, cCodEmp )
	EndIf
	cJson := oRet:ToJson()
	::SetResponse(cJson)

	FreeObj( oRet )
Return(.T.)

WSMETHOD GET jobRoles PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aId			:= {}
	Local aQryParam 	:= Self:aQueryString

	Local nX			:= 0
	Local nPage			:= 1
	Local nPageSize	    := 10

	Local cFilter		:= ""
	Local cJson			:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cLogin		:= ""
	Local cCodEmp		:= cEmpAnt
	Local cCodFil		:= ""

	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
		cCodFil		:= cBranchVld
	EndIf

	fPermission(cBranchVld, cLogin, cRD0Cod, "employeeDataChangeRequest", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
		Return(.F.)
	EndIf
	If Len(aQryParam) > 0
		For nX := 1 to Len(aQryParam)
			DO Case
				CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
					nPageSize := Val(aQryParam[nX,2])
				CASE UPPER(aQryParam[nX,1]) == "PAGE"
					nPage := Val(aQryParam[nX,2])
				CASE UPPER(aQryParam[nX,1]) == "IDDEPARTMENT"
					aId := StrTokArr(aQryParam[nX,2], "|" )
				CASE UPPER(aQryParam[nX,1]) == "FILTER"
					cFilter := Upper( AllTrim(aQryParam[nX,2]) )
			ENDCASE
		Next nX
		If Len(aId) >= 2
			cCodEmp := aId[1]
			cCodFil := aId[2]
		EndIF
		oRet := GetDataForJob("18", { cCodEmp, cCodFil, nPage, nPageSize, cFilter }, cCodEmp )
	EndIf

	cJson := oRet:ToJson()
	::SetResponse(cJson)
	FreeObj( oRet )
Return(.T.)

WSMETHOD GET salaryTypes PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aQryParam 	:= Self:aQueryString

	Local cJson			:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cLogin		:= ""

	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
	EndIf

	fPermission(cBranchVld, cLogin, cRD0Cod, "employeeDataChangeRequest", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
		Return(.F.)
	EndIf
	oRet := fSalaryTypes(aQryParam)

	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

//Retorna as categorias de trabalhadores da empresa
WSMETHOD GET categoryTypes PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()
	Local aDataLogin    := {}
	Local aQryParam 	:= Self:aQueryString
	Local cJson			:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cLogin		:= ""
	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
	EndIf

	fPermission(cBranchVld, cLogin, cRD0Cod, "employeeDataChangeRequest", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
		Return(.F.)
	EndIf
	
	oRet := fCategoryTypes(aQryParam)

	cJson := oRet:ToJson()
	Self:SetResponse(cJson)

Return(.T.)

WSMETHOD GET stafDetail PATHPARAM employeeId, id WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aIdReq		:= {}

	Local cJson			:= ""
	Local cMatSRA		:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cLogin		:= ""
	Local cIdCrypt      := ""
	Local cRoutine		:= "W_PWSA110.APW" // Aumento de Quadro.
	Local lOrgCfg       := SuperGetMv("MV_ORGCFG", NIL ,"0") == "1"

	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA    	:= aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
	EndIf

	If  Len(::aUrlParms) > 1 .And. !Empty(::aUrlParms[4])
		cIdCrypt := rc4crypt(::aUrlParms[4], "MeuRH#Requisicao", .F., .T.)
		aIdReq   := STRTOKARR(cIdCrypt, "|" )
		If Len(aIdReq) > 1
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "staffIncrease", @lHabil)
			If !lHabil .Or. lDemit .Or. !lOrgCfg
				SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
				Return(.F.)
			//valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf !getPermission(cBranchVld, cMatSRA, aIdReq[1], aIdReq[2], cEmpAnt, aIdReq[3], cRoutine)
				SetRestFault(400, EncodeUTF8( STR0027 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
				Return(.F.)
			EndIf
			oRet := fGetStaffInc(cBranchVld, cMatSRA, aIdReq)
		EndIf
	EndIf


	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET department PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aQryParam 	:= Self:aQueryString

	Local cJson			:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cLogin		:= ""
	Local cMatSRA		:= ""
	Local cRoutine		:= "W_PWSA110.APW" // Aumento de Quadro.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA		:= aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
		oRet := fDepartment(cEmpAnt, cBranchVld, cMatSRA, cRoutine, aQryParam)
	EndIf


	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET costCenter PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local nPos			:= 0

	Local aId			:= {}
	Local aDataLogin    := {}
	Local aQryParam 	:= Self:aQueryString

	Local cJson			:= ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cCompanyId    := cEmpAnt

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		If( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "IDDEPARTMENT" } ) ) > 0
			aId := StrTokArr(aQryParam[nPos,2], "|" )
		EndIf

		If Len(aId) >= 2
			cCompanyId := aId[1]
		EndIf

		If cCompanyId == cEmpAnt
			oRet := fCostCenter( aQryParam, .F., NIL )
		else
			oRet := GetDataForJob( "11", aQryParam, cCompanyId )
		EndIf
	EndIf


	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET transferDetail PATHPARAM employeeId, id WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aIdReq		:= {}

	Local cJson			:= ""
	Local cMatSRA		:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cIdCrypt      := ""
	Local cLogin		:= ""
	Local cRoutine		:= "W_PWSA140.APW" // Transfer�ncia.

	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA    	:= aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
	EndIf

	If  Len(::aUrlParms) > 1 .And. !Empty(::aUrlParms[4])
		cIdCrypt := rc4crypt(::aUrlParms[4], "MeuRH#Requisicao", .F., .T.)
		aIdReq   := STRTOKARR(cIdCrypt, "|" )
		If Len(aIdReq) > 1
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "transfer", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada para transfer�ncia"
				Return(.F.)
			//Valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf !getPermission(cBranchVld, cMatSRA, aIdReq[1], aIdReq[2], cEmpAnt, aIdReq[3], cRoutine)
				SetRestFault(400, EncodeUTF8( STR0027 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
				Return(.F.)
			EndIf
			oRet := fDetailTrnsf(cBranchVld, cMatSRA, aIdReq)
		EndIf
	EndIf

	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET detTransfer PATHPARAM employeeId, id WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aIdReq		:= {}

	Local cJson			:= ""
	Local cMatSRA		:= ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cRD0Cod		:= ""
	Local cLogin		:= ""
	Local cRoutine		:= "W_PWSA140.APW" // Transfer�ncia.

	Local lDemit       	:= .F.
	Local lHabil		:= .T.

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA    	:= aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
	EndIf

	If  Len(::aUrlParms) > 1 .And. !Empty(::aUrlParms[4])
		aIdReq := STRTOKARR( ::aUrlParms[4], "|" )
		If Len(aIdReq) > 1
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "transfer", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada para transfer�ncias"
				Return(.F.)
			//Valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf !getPermission(cBranchVld, cMatSRA, aIdReq[1], aIdReq[2], cEmpAnt, aIdReq[3], cRoutine)
				SetRestFault(400, EncodeUTF8( STR0027 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
				Return(.F.)
			EndIf
			If(RH3->(dbSeek(aIdReq[1]+aIdReq[4])))
				oRet := fTrnsfDetail(cBranchVld, cMatSRA, aIdReq)
			Else
				SetRestFault(400, EncodeUTF8( STR0066 )) //"Requisi��o de transfer�ncia n�o localizada."
				Return(.F.)
			EndIf
		EndIf
	EndIf

	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET company PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aQryParam 	:= Self:aQueryString

	Local cJson			:= ""
	Local cToken        := ""
	Local cKeyId        := ""

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		oRet := fCompany( aQryParam )
	EndIf

	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET branch PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aQryParam 	:= Self:aQueryString

	Local cJson			:= ""
	Local cToken        := ""
	Local cKeyId        := ""

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		oRet := fBranch( aQryParam )
	EndIf

	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

WSMETHOD GET process PATHPARAM employeeId WSREST Request

	Local oRet 			:= JsonObject():New()

	Local aDataLogin    := {}
	Local aQryParam 	:= Self:aQueryString

	Local nPos			:= 0

	Local cCompanyId	:= cEmpAnt
	Local cJson			:= ""
	Local cToken        := ""
	Local cKeyId        := ""

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		If ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "COMPANYID" } ) ) > 0
			cCompanyId := aQryParam[nPos,2]
		EndIf

		If cCompanyId == cEmpAnt
			oRet := fProcess( aQryParam, .F., NIL )
		Else
			oRet := GetDataForJob( "10", aQryParam, cCompanyId )
		EndIf
	EndIf

	cJson := oRet:ToJson()
	::SetResponse(cJson)
Return(.T.)

// -------------------------------------------------------------------
// - GET CONTADOR DE REQUISI��ES PENDENTES DE APROVA��O.
// -------------------------------------------------------------------

WSMETHOD GET getPendingReqCount PATHPARAM employeeId WSREST Request

	Local aDataLogin  := {}
	local aData       := {}

	Local cBranchVld  := ""
	Local cMatSRA     := ""
	Local cJson       := ""
	Local cRD0Cod     := ""
	Local cToken      := ""
	Local cKeyId      := ""

	Local lTransfer   := .F.
	Local lDataChange := .F.
	Local lStffInc    := .F.
	Local lDemission  := .F.

	Local oItems	:= JsonObject():New()

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cRD0Cod	   := aDataLogin[3]
		cBranchVld := aDataLogin[5]
	EndIf

	If !Empty(cBranchVld) .And. !Empty(cRD0Cod) .And. !Empty(cMatSRA)

		//Verifica quais permiss�es o usu�rio tem acesso.
		fPermission(cBranchVld, cMatSRA, cRD0Cod, "transfer"          , @lTransfer)
		fPermission(cBranchVld, cMatSRA, cRD0Cod, "employeeDataChange", @lDataChange)
		fPermission(cBranchVld, cMatSRA, cRD0Cod, "staffIncrease"     , @lStffInc)
		fPermission(cBranchVld, cMatSRA, cRD0Cod, "demission"         , @lDemission)

		//Caso tenha acesso a pelo menos uma das requisi��es, verifica se existe alguma requisi��o pendente de aprova��o.
		If lTransfer .Or. lDataChange .Or. lStffInc .Or. lDemission
			aData := getPendReqCount(cBranchVld, cMatSRA, lTransfer, lDataChange, lStffInc, lDemission)
		EndIf

	EndIf

	oItems["items"] := aData

	cJson := oItems:ToJson()

	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
//"Retorna informacoes do arquivo para download
// -------------------------------------------------------------------
WSMETHOD GET InfArqReq WSREST Request

	Local oItem      := JsonObject():New()
	Local aUrlParam  := Self:aUrlParms
	Local aDataLogin := {}
	Local aIdReq	 := {}
	Local nLenParms  := Len(aUrlParam)
	Local cNameArq   := ""
	Local cType      := ""
	Local cMsg       := ""
	Local cFilRH3    := ""
	Local cCodRH3    := ""
	Local cCodEmp	 := cEmpAnt
	Local cToken     := ""
	Local cTipoPerm  := ""
	Local cMsgPerm   := ""      
	Local cKeyId     := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cLogin     := ""
	Local cRD0Cod	 := ""
	Local cIdCrypt	 := ""
	Local cMatRH3	 := ""
	Local lRet		 := .T.
	Local lHabil     := .T.
	Local lDemit     := .F.

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA     := aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
		lDemit      := aDataLogin[6]
	EndIf

	If nLenParms == 4 .And. !Empty(aUrlParam[4])
		cIdCrypt := rc4crypt(aUrlParam[4], "MeuRH#Requisicao", .F., .T.)
		aIdReq   := STRTOKARR(cIdCrypt, "|")
		If Len(aIdReq) > 3
			cFilRH3	 := aIdReq[1]
			cMatRH3	 := aIdReq[2]
			cCodEmp	 := aIdReq[3]
			cCodRH3	 := aIdReq[4]
		EndIf

		fGetDadosRh3(cFilRH3, cMatRH3, cCodRH3, @cTipoPerm, @cMsgPerm, @lRet)

		If !lRet
			SetRestFault(400, EncodeUTF8(STR0070)) //"Requisi��o n�o localizada."
			Return(.F.)	
		EndIf
	EndIf

	//Valida permiss�o do gestor ao servi�o da requisi��o.
	fPermission(cBranchVld, cLogin, cRD0Cod, cTipoPerm, @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8(STR0071) + cMsgPerm) //"Permiss�o negada ao servi�o de"
		Return (.F.)
	EndIf

	//Dados do anexo a partir do banco de conhecimento
	cRet := fInfBcoFile(1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg)			
	lRet := Empty(cMsg)

	If lRet
		oItem["content"] := cRet
		oItem["type"]    := cType
		oItem["name"]    := cNameArq

		cJson := oItem:toJson()
		Self:SetResponse(cJson)
	Else
		SetRestFault(400, cMsg)
	EndIf

Return( lRet )

// -------------------------------------------------------------------
//"Retorna a imagem para download
// -------------------------------------------------------------------
WSMETHOD GET DownArqReq WSREST Request

	Local aUrlParam	 := Self:aUrlParms
	Local nLenParms	 := Len(aUrlParam)
	Local cNameArq	 := ""
	Local cType		 := ""
	Local cMsg		 := ""
	Local cFilRH3	 := ""
	Local cCodRH3	 := ""
	Local cToken     := ""
	Local cTipoPerm  := ""
	Local cMsgPerm   := ""  
	Local cKeyId     := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cLogin	 := ""
	Local cIdCrypt	 := ""
	Local cRD0Cod	 := ""
	Local cMatRH3	 := ""
	Local lRet		 := .T.
	Local lHabil     := .T.
	Local lDemit     := .F.
	Local cCodEmp	 := cEmpAnt
	Local aDataLogin := {}
	Local aIdReq	 := {}

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cMatSRA     := aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
		lDemit      := aDataLogin[6]
	EndIf

	If nLenParms == 5 .And. !Empty(aUrlParam[4])
		cIdCrypt := rc4crypt(aUrlParam[4], "MeuRH#Requisicao", .F., .T.)
		aIdReq   := STRTOKARR(cIdCrypt, "|")
		If Len(aIdReq) > 3
			cFilRH3	 := aIdReq[1]
			cMatRH3	 := aIdReq[2]
			cCodEmp	 := aIdReq[3]
			cCodRH3	 := aIdReq[4]
		EndIf

		fGetDadosRh3(cFilRH3, cMatRH3, cCodRH3, @cTipoPerm, @cMsgPerm, @lRet)

		If !lRet
			SetRestFault(400, EncodeUTF8(STR0070)) //"Requisi��o n�o localizada."
			Return(.F.)	
		EndIf
	EndIf

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, cTipoPerm, @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0071 ) + cMsgPerm) //"Permiss�o negada ao servi�o de"
		Return (.F.)
	EndIf

	//Dados do anexo a partir do banco de conhecimento
	cRet := fInfBcoFile(2, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg)
	lRet := Empty(cMsg)

	If lRet
		Self:SetHeader("Content-Disposition", "attachment; filename=" + cNameArq )
		Self:SetResponse(cRet)
	Else
		SetRestFault(400, cMsg)
	EndIf

Return( lRet )



//******************** M�todos PUTs ********************
//******************************************************

// - PUT RESPONS�VEL POR APROVAR OU REPROVAR REQUISICOES PENDENTES.
WSMETHOD PUT Requisitions PATHPARAM employeeId WSREST Request
	Local cBody         := Self:GetContent()
	Local cMsg          := ""
	Local cJson         := ""
	Local cToken        := ""
	Local lOk           := .T.
	Local lCrypt        := .T. //Indica se o ID vem criptografado do front

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken := Self:GetHeader('Authorization')
	cKeyId := Self:GetHeader('keyId')

	cMsg := fAvalAprRepr(cToken, cBody, cKeyId, lCrypt)

	If Empty(cMsg)
		cJson := FWJsonSerialize(cBody, .F., .F., .T.)
		Self:SetResponse(cJson)
	Else
		lOk  := .F.
		SetRestFault(400, cMsg, .T.)
	EndIf

Return (lOk)


// PUT RESPONS�VEL POR APROVAR OU REPROVAR AS NOTIFICA��ES PENDENTES.
WSMETHOD PUT editNotifications PATHPARAM employeeId WSREST Request

	Local oBody			:= JsonObject():New()
	Local cBody			:= ::GetContent()
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local lOK			:= .T.
	Local lCrypt        := .F. //Indica se o ID vem criptografado do front

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken  := Self:GetHeader('Authorization')
	cKeyId  := Self:GetHeader('keyId')

	oBody:FromJson(cBody)

	cMsg := fAvalAprRepr(cToken, cBody, cKeyId, lCrypt)

	If empty(cMsg)
		cJson := FWJsonSerialize(oBody, .F., .F., .T.)
		Self:SetResponse(cJson)
	Else
		lOk  := .F.
		SetRestFault(400, cMsg, .T.)
	EndIf

Return (lOk)

// -------------------------------------------------------------------
// VALIDA O PERCENTUAL OU SALARIO PROPOSTO DE UMA REQ. DE ACAO SALARIAL
// -------------------------------------------------------------------
WSMETHOD POST ValidSalRequest PATHPARAM employeeId WSSERVICE Request

	Local oItem			:= JsonObject():New()
	Local cBody 		:= Self:GetContent()
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cJson			:= ""
	Local cLogin		:= ""
	Local cRD0Cod	 	:= ""
	Local cBranchVld 	:= ""
	Local nPerc			:= 0
	Local nSalAtu	 	:= 0
	Local nSalProp		:= 0
	Local nSalNew		:= 0
	Local lDemit		:= .F.
	Local lHabil		:= .F.
	Local aDataLogin	:= {}

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld 	:= aDataLogin[5]
		lDemit		:= aDataLogin[6]
	EndIf

	fPermission(cBranchVld, cLogin, cRD0Cod, "employeeDataChangeRequest", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
		Return(.F.)
	EndIf

	If !Empty( cBody )
		oItem:FromJson(cBody)

		nPerc		:= If( oItem:hasProperty("percent") .And. !oItem["percent"] == Nil, oItem["percent"], 0 )
		nSalAtu  	:= If( oItem:hasProperty("salaryCurrent") .And. !oItem["salaryCurrent"] == Nil, oItem["salaryCurrent"], 0 )
		nSalProp	:= If( oItem:hasProperty("salary") .And. !oItem["salary"] == Nil, oItem["salary"], 0 )

		If nPerc > 0 .And. nSalProp == 0
			nSalNew := NoRound((nSalAtu + ((nSalAtu * nPerc) / 100)),2)
		ElseIf nSalProp > 0 .And. nPerc == 0
			nPerc := Round((((nSalProp / nSalAtu) - 1) * 100),2)
		ElseIf nSalProp == 0 .And. nPerc == 0
			nSalNew := nSalAtu
		EndIf
	EndIf

	oItem["salary"]	 := nSalNew
	oItem["percent"] := nPerc

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

Return( .T. )

// -------------------------------------------------------------------
// INCLUI A REQUISICAO DE ACAO SALARIAL
// -------------------------------------------------------------------
WSMETHOD POST ActionSalRequest PATHPARAM employeeId WSSERVICE Request

	Local oItem			:= JsonObject():New()
	Local cBody 		:= Self:GetContent()
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cCodMat	 	:= ""
	Local cBranchVld 	:= ""
	Local cRD0Cod		:= ""
	Local cVision	 	:= ""
	Local cTpAlt	 	:= ""
	Local cCateg	 	:= ""
	Local cMsg			:= ""
	Local cJustify		:= ""
	Local cFilSolic 	:= ""
	Local cMatSolic 	:= ""
	Local cEmpSolic		:= cEmpAnt
	Local cTypeReq		:= "7" 				//A��o Salarial
	Local cRoutine		:= "W_PWSA120.APW" 	//A��o Salarial
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")
	Local cMsgDefault	:= AllTrim( STR0037 + Space(1) + dToC(date()) +" - "+ Time() ) //"Cadastrado via Meu RH em:"

	Local cEmpApr		:= ""
	Local cFilApr		:= ""
	Local cApprover		:= ""
	Local nSupLevel		:= 0
	Local aIdFunc		:= {}
	Local lRet			:= .F.
	Local lHabil		:= .F.
	Local lDemit		:= .F.

	oRequest				:= WSClassNew("TRequest")
	oRequest:RequestType	:= WSClassNew("TRequestType")
	oRequest:Status			:= WSClassNew("TRequestStatus")
	oSalaryChangeRequest	:= WSClassNew("TSalaryChange")

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cCodMat	    := aDataLogin[1]			
	EndIf

	fPermission(cBranchVld, cRD0Login, cCodRD0, "employeeDataChangeRequest", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0025 )) //"Permiss�o negada para altera��o de sal�rio cargo ou fun��o"
		Return(.F.)
	EndIf

	If !Empty( cBody )

		oItem:FromJson(cBody)

		//Dados do funcionario
		If( oItem:hasProperty("employeesRequisitions") .And. !(oItem["employeesRequisitions"] == Nil) )
			cId		:= If( !Empty(oItem["employeesRequisitions"]["id"]), oItem["employeesRequisitions"]["id"],"" )										//Id do funcionario
			cName	:= If( !Empty(oItem["employeesRequisitions"]["name"]), AllTrim(oItem["employeesRequisitions"]["name"]), "" )									//Nome do funcionadio
			nSalAtu	:= If( !Empty(oItem["employeesRequisitions"]["salary"]), oItem["employeesRequisitions"]["salary"], 0 )								//Salario atual
		EndIf

		cTpAlt		:= If( oItem:hasProperty("changeSalaryReason") .And. !(oItem["changeSalaryReason"] == Nil), oItem["changeSalaryReason"]["id"], "" )	//Tipo de altera��o salarial
		cJustify	:= If( oItem:hasProperty("justify") .And. !(oItem["justify"] == Nil) .And. !Empty(Alltrim(oItem["justify"])), DecodeUtf8(AllTrim(FwCutOff(oItem["justify"]))), cMsgDefault ) //Justificativa
		cIdFun		:= If( oItem:hasProperty("jobFunction") .And. !(oItem["jobFunction"] == Nil), oItem["jobFunction"]["id"], "" ) 						//Alteracao de fun��o
		cIdCargo  	:= If( oItem:hasProperty("jobRoles") .And. !(oItem["jobRoles"] == Nil), oItem["jobRoles"]["id"], "" ) 								//Alteracao de cargo
		cCateg		:= If( oItem:hasProperty("categoryChangeType") .And. !(oItem["categoryChangeType"] == Nil), oItem["categoryChangeType"]["id"], "" )	//Alteracao de categoria
		nSalNew		:= If( oItem:hasProperty("salaryInfo") .And. !(oItem["salaryInfo"] == Nil) .And. !(oItem["salaryInfo"]["proposedSalary"] == Nil), oItem["salaryInfo"]["proposedSalary"], 0 ) //Altera��o de salario
		nPerc 		:= Round((((nSalNew / nSalAtu) - 1) * 100), 2) 																						//Percentual de aumento

		//Restringe o tamanho do campo justificativa.
		If Len(cJustify) > 50 .Or. Len(cJustify) < 3
			SetRestFault(400, EncodeUTF8( STR0067 )) //"A Justificativa deve ter no minimo 3 e no m�ximo 50 caracteres!"
			Return(.F.)
		EndIf

		//Verifica se o sal�rio novo � maior que o atual.
		If (nSalNew < nSalAtu)
			SetRestFault(400, EncodeUTF8( STR0051 )) //O novo sal�rio deve ser maior que o Atual!
			Return(.F.)	
		EndIf

		If !Empty( cId )
			aIdFunc := STRTOKARR( cId, "|" )
			If Len(aIdFunc) > 0
				cFilSolic	:= aIdFunc[1]
				cMatSolic	:= aIdFunc[2]
				cEmpSolic	:= aIdFunc[3]
			EndIf
		EndIf

		If Empty( cFilSolic ) .Or. Empty( cMatSolic )
			SetRestFault(400, EncodeUTF8( STR0036 )) //Os dados do colaborador est�o incorretos. Clique no �cone de busca para localizar as informa��es corretas.
			Return(.F.)	
		EndIf

		//valida se o solicitante da requisi��o pode ter acesso as informa��es
		If !getPermission(cBranchVld, cCodMat, cFilSolic, cMatSolic, cEmpAnt, cEmpSolic, cRoutine)
			SetRestFault(400, EncodeUTF8( STR0027 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
			Return(.F.)				
		EndIf		

		If !Empty( cFilSolic ) .And. !Empty( cMatSolic )

			aVision 	:= GetVisionAI8(cRoutine, cBranchVld)
			cVision 	:= aVision[1][1]

			// -------------------------------------------------------------------------------------------
			// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicita��o.
			//- -------------------------------------------------------------------------------------------
			cMRrhKeyTree:= fMHRKeyTree(cBranchVld, cCodMat)
			aGetStruct := APIGetStructure( cRD0Cod, cOrgCFG, cVision, cBranchVld, cCodMat, , , ,cTypeReq , cBranchVld, cCodMat, , , , , .T., {cEmpAnt})

			If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
				cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
				cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
				nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
				cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
			EndIf

			//Dados do cabecalho da requisicao
			oRequest:Branch 				:= cFilSolic
			oRequest:Registration			:= cMatSolic
			oRequest:ApproverBranch			:= cFilApr
			oRequest:ApproverRegistration 	:= cApprover
			oRequest:EmpresaAPR				:= cEmpApr
			oRequest:Empresa				:= cEmpSolic
			oRequest:StarterBranch			:= cBranchVld
			oRequest:StarterRegistration	:= cCodMat
			oRequest:ApproverLevel		    := nSupLevel
			oRequest:Vision					:= cVision
			oRequest:Observation			:= cJustify

			//Dados dos itens da requisicao
			oSalaryChangeRequest:Branch			:= cFilSolic
			oSalaryChangeRequest:Registration	:= cMatSolic
			oSalaryChangeRequest:Name			:= cName
			oSalaryChangeRequest:ChangeType		:= cTpAlt
			oSalaryChangeRequest:NewRoleCode	:= cIdFun
			oSalaryChangeRequest:NewPositionCode:= cIdCargo
			oSalaryChangeRequest:Percentage		:= nPerc
			oSalaryChangeRequest:NewSalary		:= nSalNew
			oSalaryChangeRequest:Category		:= cCateg				

			//Verifica se j� existe uma altera��o salarial pendente de aprova��o.
			If (fVerPendRH3(cEmpSolic, cFilSolic, cMatSolic, '7', {"1","4"}))
				SetRestFault(400, EncodeUTF8( STR0052 )) //"J� existe solicita��o pendente de aprova��o para este funcion�rio!"
				Return(.F.)	
			EndIf

			AddSalaryChangeRequest( oRequest, oSalaryChangeRequest, "MEURH", .T., @cMsg ) 
		EndIf

		If ( lRet := Empty(cMsg) )
			cJson := FWJsonSerialize(oItem, .F., .F., .T.)
			Self:SetResponse(cJson)
		Else
			SetRestFault(400, cMsg)
		EndIf

	EndIf

Return( lRet )

// -------------------------------------------------------------------
// INCLUI A REQUISICAO DE AUMENTO DE QUADRO
// -------------------------------------------------------------------
WSMETHOD POST staffRequest PATHPARAM employeeId WSSERVICE Request

	Local oItem			:= JsonObject():New()
	Local cBody 		:= Self:GetContent()
	Local nVagas		:= 0
	Local lNewHire  	:= .F.
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cCodMat	 	:= ""
	Local cBranchVld 	:= ""
	Local cRD0Cod		:= ""
	Local cVision	 	:= ""
	Local cJustify		:= ""
	Local cMsg			:= ""
	Local cType			:= ""
	Local cIdDepto		:= ""
	Local cIdCCusto		:= ""
	Local cIdPosto		:= ""
	Local cIdFuncao		:= ""
	Local cIdCargo		:= ""
	Local nSalPropose	:= ""
	Local cIdContrato	:= ""
	Local cNewHire		:= ""
	Local cEmpSolic		:= cEmpAnt
	Local cTypeReq		:= "3" 				//Aumento de quadro
	Local cRoutine		:= "W_PWSA110.APW" 	//Aumento de quadro
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")
	Local cMsgDefault	:= AllTrim( STR0037 + Space(1) + dToC(date()) +" - "+ Time() ) //"Cadastrado via Meu RH em:"

	Local cEmpApr		:= ""
	Local cFilApr		:= ""
	Local cApprover		:= ""
	Local nSupLevel		:= 0
	Local lRet			:= .F.
	Local lHabil		:= .F.
	Local lDemit		:= .F.

	oRequest				:= WSClassNew("TRequest")
	oRequest:RequestType	:= WSClassNew("TRequestType")
	oRequest:Status			:= WSClassNew("TRequestStatus")
	oPostRequest			:= WSClassNew("TPostRequest")

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cCodMat	    := aDataLogin[1]			
	EndIf

	fPermission(cBranchVld, cRD0Login, cCodRD0, "staffIncreaseRequest", @lHabil)
	cMsg := If( !lHabil .Or. lDemit, EncodeUTF8(STR0053), "" ) //"Permiss�o negada para inclus�o de aumento de quadro"	

	If !Empty( cBody ) .And. Empty(cMsg)

		oItem:FromJson(cBody)

		//Dados da requisicao de aumento de posto
		cJustify	:= If( oItem:hasProperty("justify") .And. !(oItem["justify"] == Nil) .And. !Empty(oItem["justify"]), AllTrim(oItem["justify"]), cMsgDefault ) //Justificativa
		nVagas		:= If( oItem:hasProperty("numberVacancies") .And. !(oItem["numberVacancies"] == Nil) .And. !Empty(oItem["numberVacancies"]), oItem["numberVacancies"], 0 ) //Numero de vagas		
		cIdDepto	:= If( oItem:hasProperty("department") .And. !(oItem["department"] == Nil) .And. !(oItem["department"]["id"] == Nil) .And. !Empty(oItem["department"]["id"]), AllTrim(oItem["department"]["id"]), "") //Departamento
		cIdCCusto	:= If( oItem:hasProperty("costCenter") .And. !(oItem["costCenter"] == Nil) .And. !(oItem["costCenter"]["id"] == Nil) .And. !Empty(oItem["costCenter"]["id"]), AllTrim(oItem["costCenter"]["id"]), "") //Centro de custo
		cIdPosto	:= If( oItem:hasProperty("postType") .And. !(oItem["postType"] == Nil) .And. !(oItem["postType"]["id"] == Nil) .And. !Empty(oItem["postType"]["id"]), oItem["postType"]["id"], "") //Tipo de posto
		cIdFuncao	:= If( oItem:hasProperty("function") .And. !(oItem["function"] == Nil) .And. !(oItem["function"]["id"] == Nil) .And. !Empty(oItem["function"]["id"]), AllTrim(oItem["function"]["id"]), "") //Fun��o
		cIdCargo	:= If( oItem:hasProperty("role") .And. !(oItem["role"] == Nil) .And. !(oItem["role"]["id"] == Nil) .And. !Empty(oItem["role"]["id"]), AllTrim(oItem["role"]["id"]), "") //Cargo
		nSalPropose	:= If( oItem:hasProperty("salaryInfo") .And. !(oItem["salaryInfo"] == Nil) .And. !(oItem["salaryInfo"]["proposedSalary"] == Nil) .And. !Empty(oItem["salaryInfo"]["proposedSalary"]), oItem["salaryInfo"]["proposedSalary"], 0) //Salario
		cIdContrato	:= If( oItem:hasProperty("contractType") .And. !(oItem["contractType"] == Nil) .And. !Empty(oItem["contractType"]), AllTrim(oItem["contractType"]), "") //Cargo
		lNewHire  	:= If( oItem:hasProperty("newHire") .And. !(oItem["newHire"] == Nil), oItem["newHire"], .F. )
		cNewHire	:= If(lNewHire, "1", "2")
		cType 		:= oRequest:RequestType

		//Valida os campos obrigatorios
		cMsg := If( (Empty(cIdFuncao) .And. Empty(cIdCargo)) .Or. nVagas == 0, EncodeUTF8(STR0054), "") //"Os campos: Fun��o ou Cargo e a Quantidade de Vagas devem ser informados!"
		cMsg := If( Empty(cMsg) .And. (Empty(cIdContrato) .Or. Empty(cIdPosto)), EncodeUTF8(STR0055), cMsg) //"Os campos: Tipo do contrato e Tipo do posto devem ser informados!"
		cMsg := If( Empty(cMsg) .And. ( Len(cJustify) > 50 .Or. Len(cJustify) < 3 ), EncodeUTF8(STR0067), cMsg) // "A justificativa deve ter no m�nimo 3 e no m�ximo 50 caracteres!"

		If ( lRet := Empty(cMsg) )

			aVision := GetVisionAI8(cRoutine, cBranchVld)
			cVision := aVision[1][1]

			// -------------------------------------------------------------------------------------------
			// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicita��o.
			//- -------------------------------------------------------------------------------------------
			cMRrhKeyTree:= fMHRKeyTree(cBranchVld, cCodMat)
			aGetStruct := APIGetStructure( cRD0Cod, cOrgCFG, cVision, cBranchVld, cCodMat, , , ,cTypeReq, cBranchVld, cCodMat, , , , , .T., {cEmpAnt}, , , .T.)

			If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
				cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
				cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
				nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
				cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
			EndIf

			//Dados do cabecalho da requisicao
			oRequest:Branch 				:= cBranchVld
			oRequest:Registration			:= cCodMat
			oRequest:ApproverBranch			:= cFilApr
			oRequest:ApproverRegistration 	:= cApprover
			oRequest:EmpresaAPR				:= cEmpApr
			oRequest:Empresa				:= cEmpSolic
			oRequest:StarterBranch			:= cBranchVld
			oRequest:StarterRegistration	:= cCodMat
			oRequest:ApproverLevel		    := nSupLevel
			oRequest:Vision					:= cVision
			oRequest:Observation			:= DecodeUTF8(cJustify)

			//Dados dos itens da requisicao
			oPostRequest:Branch				:= cBranchVld	//Filial
			oPostRequest:DepartmentCode		:= cIdDepto		//Departamento
			oPostRequest:CostCenterCode		:= cIdCCusto	//Centro de custo
			oPostRequest:PostType			:= cIdPosto		//Tipo de posto
			oPostRequest:RoleCode			:= cIdFuncao	//Funcao
			oPostRequest:PositionCode		:= cIdCargo		//Cargo
			oPostRequest:Salary				:= nSalPropose	//Salario
			oPostRequest:ContractType		:= cIdContrato	//Tipo de contrato
			oPostRequest:Quantity			:= nVagas		//Quantidade
			oPostRequest:JustificationCode	:= cJustify		//Justificativa
			oPostRequest:NewContract		:= cNewHire		//Gera Nova Contrata��o: 1=Sim;2=Nao			
			oPostRequest:RequestType		:= "1"			//Tipo da requisicao do posto 1=Novo
			oPostRequest:PostCode			:= "Novo"		//Novo posto			

			AddPostRequest( oRequest, oPostRequest, "MEURH", .T., @cMsg ) 
			lRet := Empty(cMsg)
		EndIf

	EndIf

	If lRet
		cJson := FWJsonSerialize(oItem, .F., .F., .T.)
		Self:SetResponse(cJson)
	EndIf

	If( !lRet, SetRestFault(400, cMsg), Nil )

Return( lRet )

// -------------------------------------------------------------------
// INCLUI A REQUISICAO DE AUMENTO DE QUADRO
// -------------------------------------------------------------------
WSMETHOD POST transferRequest PATHPARAM employeeId WSSERVICE Request

	Local oItem 		:= NIL
	Local cBody 		:= Self:GetContent()
	Local cCodRD0		:= ""
	Local cRD0Login		:= ""
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cCodMat	 	:= ""
	Local cBranchVld 	:= ""
	Local cMsg			:= ""
	Local lRet			:= .T.
	Local lHabil		:= .F.
	Local lDemit		:= .F.

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken, .T., cKeyId)

	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cCodMat	    := aDataLogin[1]			
	EndIf

	fPermission(cBranchVld, cRD0Login, cCodRD0, "transferRequest", @lHabil)
	If !lHabil .Or. lDemit 
		SetRestFault( 400, EncodeUTF8(STR0061) ) //"Permiss�o negada para a inclus�o da solicita��o de transfer�ncia."	
		Return .F.
	EndIf

	If !Empty( cBody )
		lRet := saveTransfer( cBody, cBranchVld, cCodMat, cCodRD0, @cMsg, @oItem )
	EndIf

	If lRet
		cJson := oItem:ToJson()
		Self:SetResponse(cJson)
	else
		SetRestFault(400, cMsg)
	EndIf

Return( lRet )
