#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"

#INCLUDE "RHNP09.CH"

Function RHNP09()
Return .T.


	WSRESTFUL Health DESCRIPTION STR0001 //"Opera��es relacionadas ao segmento de seguran�a e medicina do trabalho"

		WSDATA employeeId	As String Optional
		WSDATA WsNull		As String Optional
		WSDATA type			As String Optional
		WSDATA filter		As String Optional
		WSDATA page       	As String Optional
		WSDATA pageSize   	As String Optional

		WSMETHOD GET fRetRegsMed ;
			DESCRIPTION STR0005 ; //STR0005 "Retorna todos os tipos de atestado m�dico"
		WSSYNTAX "/health/medicalcertificate/{employeeId}" ;
			PATH "/medicalcertificate/{employeeId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET fInfArqMed ;
			DESCRIPTION STR0036 ; //"Retorna informa��es do arquivo de anexo da solicita��o do atestado"
		WSSYNTAX "/health/medicalcertificate/file/info/{medicalCertificateId}" ;
			PATH "/medicalcertificate/file/info/{medicalCertificateId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET fDownArqMed ;
			DESCRIPTION STR0037 ; //"Retorna o arquivo de anexo da solicita��o do atestado"
		WSSYNTAX "/health/medicalcertificate/file/download/{medicalCertificateId}/{fileExtension}" ;
			PATH "/medicalcertificate/file/download/{medicalCertificateId}/{fileExtension}" ;
			PRODUCES 'image/jpeg;charset=utf-8'

		WSMETHOD GET fGtReasons ;
			DESCRIPTION STR0019 ; //Retorna os poss�veis motivos para o afastamento.
		WSSYNTAX "/health/medicalcertificate/reasons" ;
			PATH "/medicalcertificate/reasons" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET fGtTypes ;
			DESCRIPTION STR0004 ; //"Retorna os tipos de atestado m�dico."
		WSSYNTAX "/health/medicalcertificate/type" ;
			PATH "/medicalcertificate/type" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET fGtCodCid ;
			DESCRIPTION STR0011 ; //"Retorna todos os CIDs cadastrados"
		WSSYNTAX "/health/cid" ;
			PATH "/cid" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET fByIdMed ;
			DESCRIPTION STR0009 ; //"Retorna as informa��es registro de atestado"
		WSSYNTAX "/health/medicalcertificate/{employeeId}/{medicalCertificateId}" ;
			PATH "/medicalcertificate/{employeeId}/{medicalCertificateId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD POST fSetMedCertificate ;
			DESCRIPTION STR0008 ; //"Cria um registo de atestado"
		WSSYNTAX "/health/medicalcertificate/{employeeId}/" ;
			PATH "/medicalcertificate/{employeeId}/" ;
			PRODUCES 'application/json;charset=utf-8';
			TTALK "v2"

		WSMETHOD PUT fPutMedCertificate ;
			DESCRIPTION STR0007 ; //"Atualiza um registo de atestado"
		WSSYNTAX "/health/medicalcertificate/{employeeId}" ;
			PATH "/medicalcertificate/{employeeId}" ;
			PRODUCES 'application/json;charset=utf-8';
			TTALK "v2"

		WSMETHOD DELETE fDelMedCertificate ;
			DESCRIPTION STR0010 ; //"Exclui as informa��es registro de atestado"
		WSSYNTAX "/health/medicalcertificate/{employeeId}/{medicalCertificateId}" ;
			PATH "/medicalcertificate/{employeeId}/{medicalCertificateId}" ;
			PRODUCES 'application/json;charset=utf-8'

	END WSRESTFUL


// -------------------------------------------------------------------
//"Retorna informacoes do arquivo para download
// -------------------------------------------------------------------
	WSMETHOD GET fInfArqMed WSREST Health

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
	Local cKeyId     := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cLogin     := ""
	Local cRD0Cod	 := ""
	Local cIdCrypt	 := ""
	Local cMatRH3	 := ""
	Local cRoutine	 :="W_PWSA210.APW" //Afastamentos.
	Local lRet		 := .T.
	Local lHabil     := .T.
	Local lDemit     := .F.

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)
	If Len( aDataLogin ) > 0
		cMatSRA     := aDataLogin[1]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf

//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
		Return (.F.)
	EndIf

	If nLenParms == 4 .And. !Empty(aUrlParam[4])
		cIdCrypt := rc4crypt( aUrlParam[4], "MeuRH#AtestadoMedico", .F., .T. )
		aIdReq  := STRTOKARR( cIdCrypt, "|" )
		If Len(aIdReq) > 0
			cFilRH3	 := aIdReq[1]
			cCodRH3	 := aIdReq[2]
			cCodEmp	 := aIdReq[3]
			cMatRH3	 := PosAlias( "RH3", cCodRH3, cFilRH3, "RH3_MAT", 1 )
		EndIf

		If !getPermission(cBranchVld, cMatSRA, cFilRH3, cMatRH3, cEmpAnt, cCodEmp, cRoutine)
			lRet := .F.
			cMsg := EncodeUTF8(STR0053) //"ACESSO NEGADO! Voc� n�o tem permiss�o para acessar esse recurso."
		Else
			//Dados do anexo a partir do banco de conhecimento
			cRet := fInfBcoFile( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
			
			//Dados do anexo a partir do repositorio de imagens (quando nao localiza no BC p/ nao afetar o historico)
			If Empty(cRet)
				cMsg := ""
				cRet := fMedImg( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
			EndIf
			
			lRet := Empty(cMsg)
		EndIf
	EndIf

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
	WSMETHOD GET fDownArqMed WSREST Health

	Local aUrlParam	 := Self:aUrlParms
	Local nLenParms	 := Len(aUrlParam)
	Local cNameArq	 := ""
	Local cType		 := ""
	Local cMsg		 := ""
	Local cFilRH3	 := ""
	Local cCodRH3	 := ""
	Local cToken     := ""
	Local cKeyId     := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cLogin	 := ""
	Local cIdCrypt	 := ""
	Local cRD0Cod	 := ""
	Local cMatRH3	 := ""
	Local cRoutine	 :="W_PWSA210.APW" //Afastamentos.
	Local lRet		 := .T.
	Local lHabil     := .T.
	Local lDemit     := .F.
	Local cCodEmp	 := cEmpAnt
	Local aDataLogin := {}
	Local aIdReq	 := {}

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		cBranchVld := aDataLogin[5]
		lDemit     := aDataLogin[6]
	EndIf

//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
		Return (.F.)
	EndIf

	If nLenParms == 5 .And. !Empty(aUrlParam[4])
		cIdCrypt := rc4crypt( aUrlParam[4], "MeuRH#AtestadoMedico", .F., .T. )
		aIdReq   := STRTOKARR( cIdCrypt, "|" )
		If Len(aIdReq) > 0
			cFilRH3	 := aIdReq[1]
			cCodRH3	 := aIdReq[2]
			cCodEmp  := aIdReq[3]
			cMatRH3	 := PosAlias( "RH3", cCodRH3, cFilRH3, "RH3_MAT", 1 )
		EndIf

		If !getPermission(cBranchVld, cMatSRA, cFilRH3, cMatRH3, cEmpAnt, cCodEmp, cRoutine)
			lRet := .F.
			cMsg := EncodeUTF8(STR0053) //"ACESSO NEGADO! Voc� n�o tem permiss�o para acessar esse recurso."
		Else
			//Dados do anexo a partir do banco de conhecimento
			cRet := fInfBcoFile( 2, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
			
			//Dados do anexo a partir do repositorio de imagens (quando nao localiza no BC p/ nao afetar o historico)
			If Empty(cRet)
				cMsg := ""
				cRet := fMedImg( 2, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsg )
			EndIf
			lRet := Empty(cMsg)
		EndIf
	EndIf

	If lRet
		Self:SetHeader("Content-Disposition", "attachment; filename=" + cNameArq )
		Self:SetResponse(cRet)
	Else
		SetRestFault(400, cMsg)
	EndIf

Return( lRet )


// -------------------------------------------------------------------
//"Retorna os atestados com status diferente de pendente"
// -------------------------------------------------------------------
WSMETHOD GET fRetRegsMed WSREST Health

Local cJsonObj		:= "JsonObject():New()"
Local oItem			:= &cJsonObj
Local aData			:= {}
Local aDataLogin  	:= {}
Local cJson			:= ""
Local cPage			:= ""
Local cPageSize		:= ""
Local cStatus		:= ""
Local cToken        := ""
Local cKeyId        := ""
Local cBranchVld	:= ""
Local cMatSRA		:= ""
Local cLogin		:= ""
Local cRD0Cod		:= ""
Local cSavFil       := cFilAnt
Local cSavEmp       := cEmpAnt
Local nX			:= 0
Local nTipo			:= 3
Local lChangeEmp	:= .F.
Local lNext        	:= .F.
Local lHabil		:= .T.
Local lDemit		:= .F.
Local aIdFunc       := {}
Local aQryParam		:= Self:aQueryString
Local cRoutine		:= "W_PWSA210.APW" //Afastamentos.

Self:SetHeader('Access-Control-Allow-Credentials' , "true")

cToken		:= Self:GetHeader('Authorization')
cKeyId  	:= Self:GetHeader('keyId')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)
If Len( aDataLogin ) > 0
	cMatSRA     := aDataLogin[1]
	cLogin		:= aDataLogin[2]
	cRD0Cod		:= aDataLogin[3]
	cBranchVld	:= aDataLogin[5]
	lDemit			:= aDataLogin[6]
EndIf

If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
	aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
	If Len(aIdFunc) > 1
		If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return (.F.)
			EndIf
		Else
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementMedical", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return (.F.)
			//valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
				cBranchVld	:= aIdFunc[1]
				cMatSRA		:= aIdFunc[2]
				cEmpFunc	:= aIdFunc[3]
				lChangeEmp	:= !(cEmpFunc == cEmpAnt)
			Else
				SetRestFault(400, EncodeUTF8( STR0052 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
				Return (.F.)
			EndIf
		EndIf
	EndIf
Else
	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
		Return (.F.)
	EndIf
EndIF

If !Empty(cBranchVld) .And. !Empty(cMatSRA)

	For nX := 1 To Len( aQryParam )
		Do Case
		Case UPPER(aQryParam[nX,1]) == "PAGE"
			cPage		:= aQryParam[nX,2]
		Case UPPER(aQryParam[nX,1]) == "PAGESIZE"
			cPageSize	:= aQryParam[nX,2]
		Case UPPER(aQryParam[nX,1]) == "STATUS"
			cStatus		:= aQryParam[nX,2]
		End Case
	Next

	//1 = Pendentes de aprovacao (status pending)
	//2 = Aprovados ou Reprovados (status notpending)
	//3 = Todos (status vazio)
	nTipo := If( Empty(cStatus), 3, If( cStatus == "notpending", 2, 1 ) )

	If lChangeEmp
		fNewEmpFiles(cEmpFunc, cBranchVld, {"SRA","RCH","RCM","SRY"})
	EndIf

	aData := fGetRegsMedical( nTipo, cBranchVld, cMatSRA, Nil, cPage, cPageSize, @lNext )

	If lChangeEmp
		fNewEmpFiles(cSavEmp, cSavFil, {"SRA","RCH","RCM","SRY"})
	EndIf

EndIf

oItem["hasNext"]  := lNext
oItem["items"]    := aData

cJson := FWJsonSerialize(oItem, .F., .F., .T.)
Self:SetResponse(cJson)

Return(.T.)


// -------------------------------------------------------------------
//Retorna os poss�veis motivos para o afastamento.
// -------------------------------------------------------------------
	WSMETHOD GET fGtReasons WSREST Health

	Local oItem			:= JsonObject():New()
	Local oTipoAfas		:= JsonObject():New()
	Local cJson			:= ""
	Local cBrchRCM		:= ""
	Local cQuery		:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cCpoRCM		:= ""
	Local aTipoP		:= {}
	Local aDataLogin	:= {}
	Local lCpoPortal	:= CpoUsado("RCM_PORTAL")
	Local cWhere		:= ""

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  	:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)
	If Len( aDataLogin ) > 0
		cBranchVld	:= aDataLogin[5]
	EndIf

	If !Empty( cBranchVld )

		cBrchRCM	:= xFilial("RCM", cBranchVld)
		cQuery 		:= GetNextAlias()
		If lCpoPortal
			cCpoRCM := "%, RCM_PORTAL%"
			cWhere  := "%RCM.RCM_PORTAL <> '2' AND%" 
		Else
			cCpoRCM := "%%"
			cWhere  := "%%"
		EndIf

		//Apresenta os motivos considerando: dias corridos, tipo informado, e diferente de Ferias/Recesso
		BEGINSQL ALIAS cQuery
	
		SELECT RCM_FILIAL, RCM_TIPO, RCM_DESCRI %Exp:cCpoRCM%
		FROM
			%Table:RCM% RCM
		WHERE
			RCM.RCM_FILIAL = %Exp:cBrchRCM% AND
			RCM.RCM_TIPOAF NOT IN ('', '4') AND
			RCM.RCM_TIPODI = '2' AND
			%Exp:cWhere%
			RCM.%NotDel%
		ORDER BY 1, 2
		ENDSQL

		While !(cQuery)->(Eof())

			oTipoAfas 					:= JsonObject():New()
			oTipoAfas["id"]				:= (cQuery)->RCM_TIPO
			oTipoAfas["description"]	:= EncodeUTF8( AllTrim((cQuery)->RCM_DESCRI) )
			
			aAdd(aTipoP, oTipoAfas)

			(cQuery)->(dbSkip())
		EndDo

		(cQuery)->( DBCloseArea() )

		oItem["items"] 	  := aTipoP
		oItem["hasNext"]  := .F.

		cJson := FWJsonSerialize(oItem, .F., .F., .T.)
		Self:SetResponse(cJson)

	EndIf

Return(.T.)


// -------------------------------------------------------------------
//Retorna os tipos de atestado m�dico
// -------------------------------------------------------------------
	WSMETHOD GET fGtTypes WSREST Health

	Local cJsonObj		:= "JsonObject():New()"
	Local oItem			:= &cJsonObj
	Local oTipoAfas		:= ""
	Local cJson			:= ""
	Local nX			:= 0
	Local aTipos		:= {}
	Local aTipoAfas		:= {}


	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	aTipos := { ;
		EncodeUTF8(STR0050), ; 	// M�dico
		EncodeUTF8(STR0051) } 	// Odontol�gico.

	For nX := 1 To Len(aTipos)
		oTipoAfas 			:= &cJsonObj
		oTipoAfas["id"]		:= cValToChar(nX)
		oTipoAfas["name"]	:= aTipos[nX]

		aAdd(aTipoAfas, oTipoAfas)
	Next nX

	oItem["items"] 	  := aTipoAfas
	oItem["hasNext"]  := .F.

	cJson := FWJsonSerialize(oItem, .F., .F., .T.)
	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
//"Retorna todos os CIDs cadastrados"
// -------------------------------------------------------------------
WSMETHOD GET fGtCodCid WSREST Health

Local oItem			:= JsonObject():New()
Local oCid			:= NIL
Local oSt			:= Nil
Local cBranchVld	:= ""
Local cBrchTMR		:= ""
Local cJson			:= ""
Local cQuery		:= ""
Local cQueryTMR		:= GetNextAlias()
Local cToken		:= ""
Local cKeyId		:= ""
Local cDesCID		:= ""
Local nRegCount     := 0
Local nRegIniCount  := 0
Local nRegFimCount  := 0
Local nDesc  		:= 0
Local lMaisPaginas	:= .F.
Local aItens		:= {}
Local aDataLogin	:= {}
Local lContinua		:= AliasInDic("TMR")

DEFAULT Self:filter		:= ""
DEFAULT Self:page		:= ""
DEFAULT Self:pageSize	:= ""

Self:SetHeader('Access-Control-Allow-Credentials' , "true")

cToken  	:= Self:GetHeader('Authorization')
cKeyId  	:= Self:GetHeader('keyId')
aDataLogin	:= GetDataLogin(cToken, .T., cKeyId)
If Len( aDataLogin ) > 0
	cBranchVld	:= aDataLogin[5]
EndIf

If lContinua .And. !Empty( cBranchVld )

	dbSelectArea("TMR") //Alimentar a tabela CID - autocontida do TAF

	//Faz o controle de paginacao
	If Self:page == "1" .Or. Self:page == ""
		nRegIniCount := 1
		nRegFimCount := If( Empty( Val(Self:pageSize) ), 20, Val(Self:pageSize) )
	Else
		nRegIniCount := ( Val(Self:pageSize) * ( Val(Self:page) - 1 ) ) + 1
		nRegFimCount := ( nRegIniCount + Val(Self:pageSize) ) - 1
	EndIf

	//Aplica filtro caso seja informado
	oST := FWPreparedStatement():New()
	cQuery := "SELECT TMR_FILIAL, TMR_CID, TMR_DOENCA "
	cQuery += "FROM " + RetSqlName('TMR') + " TMR "
	cQuery += "WHERE TMR.TMR_FILIAL = ? AND "
	cQuery += "TMR.TMR_DOENCA <> ' ' AND "
	cQuery += "TMR.D_E_L_E_T_ = ' ' "
	If !Empty(Self:filter)
		cQuery += " AND "
		cQuery += "( TMR.TMR_DOENCA LIKE ? OR "
		cQuery += "TMR.TMR_CID LIKE ? ) "
	EndIf
	cQuery += "ORDER BY 1, 2"

	cBrchTMR := xFilial("TMR", cBranchVld)

	oSt:SetQuery(cQuery)

	//DEFINI��O DOS PAR�METROS.
	oSt:SetString(1,cBrchTMR)
	If !Empty(Self:filter)
		oSt:SetString(2,"%"+UPPER(fTAcento(Self:filter))+"%")
		oSt:SetString(3,"%"+UPPER(Self:filter)+"%")
	EndIf

	//RESTAURA A QUERY COM OS PAR�METROS INFORMADOS.
    cQuery := oSt:GetFixQuery()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQueryTMR,.T.,.T.)

	If !(cQueryTMR)->(Eof())
		While !(cQueryTMR)->(Eof())
			nRegCount ++

			nDesc	:= Len( AllTrim((cQueryTMR)->TMR_DOENCA))
			cDesCID := SubStr((cQueryTMR)->TMR_DOENCA, 1, 30) + If( nDesc > 30, "...", "")

			If ( nRegCount >= nRegIniCount .And. nRegCount <= nRegFimCount )
				oCid 			:= JsonObject():New()
				oCid["id"]		:= AllTrim( (cQueryTMR)->TMR_CID )
				oCid["name"]	:= EncodeUTF8( cDesCID )
				aAdd(aItens, oCid)
			Else
				If nRegCount >= nRegFimCount
					lMaisPaginas := .T.
					Exit
				EndIf
			EndIf

			(cQueryTMR)->(dbSkip())
		EndDo
	EndIf

	(cQueryTMR)->( DBCloseArea() )

	oItem["items"] 	  := aItens
	oItem["hasNext"]  := lMaisPaginas

	cJson := oItem:toJson()
	Self:SetResponse(cJson)
EndIf

Return(.T.)


// -------------------------------------------------------------------
//"Retorna os registros de atestados com status pendentes"
// -------------------------------------------------------------------
WSMETHOD GET fByIdMed WSREST Health

Local oData		 := JsonObject():New()
Local aUrlParam	 := Self:aUrlParms
Local aDataLogin := {}
Local aIdReq	 := {}
Local nLenParms	 := Len(aUrlParam)
Local cJson		 := ""
Local cFilRH3	 := ""
Local cCodRH3	 := ""
Local cToken	 := ""
Local cKeyId	 := ""
Local cBranchVld := ""
Local cMatSRA	 := ""
Local cLogin	 := ""
Local cRD0Cod	 := ""
Local cIdCrypt	 := ""
Local cSavFil	 := ""
Local cSavEmp    := cEmpAnt
Local cEmpFunc	 := cEmpAnt
Local aIdFunc    := {}
Local lHabil     := .T.
Local lDemit     := .F.
Local lChangeEmp := .F.
Local cRoutine	 := "W_PWSA210.APW" //Afastamentos

Self:SetHeader('Access-Control-Allow-Credentials' , "true")

cToken		:= Self:GetHeader('Authorization')
cKeyId  	:= Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len( aDataLogin ) > 0
	cMatSRA		:= aDataLogin[1]
	cLogin		:= aDataLogin[2]
	cRD0Cod		:= aDataLogin[3]
	cBranchVld	:= aDataLogin[5]
	lDemit		:= aDataLogin[6]

	cSavFil    := cBranchVld
EndIf

If  nLenParms > 1 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
	aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
	If Len(aIdFunc) > 1
		If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return(.F.)
			EndIf
		Else
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementMedical", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return(.F.)
			//valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
				cBranchVld	:= aIdFunc[1]
				cMatSRA		:= aIdFunc[2]
				cEmpFunc	:= aIdFunc[3]
				lChangeEmp	:= !(cEmpFunc == cEmpAnt)
			Else
				SetRestFault(400, EncodeUTF8( STR0052 )) //"Voc� est� tentando acessar dados de um funcion�rio que n�o faz parte do seu time."
				Return(.F.)
			EndIf
		EndIf
	EndIf
Else
	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
		Return(.F.)
	EndIf
EndIF

If nLenParms == 3 .And. !Empty(aUrlParam[3])
	cIdCrypt :=  rc4crypt( aUrlParam[3], "MeuRH#AtestadoMedico", .F., .T. )
	aIdReq   := STRTOKARR( cIdCrypt, "|" )
	If Len(aIdReq) > 0
		cFilRH3	 := aIdReq[1]
		cCodRH3  := aIdReq[2]
	EndIf
EndIf

If !Empty(cBranchVld) .And. !Empty(cMatSRA) .And. !Empty(cCodRH3)
	If lChangeEmp
		fNewEmpFiles(cEmpFunc, cBranchVld, {"SRA","RCH","RCM","SRY"})
	EndIf

	oData := fGetRegsMedical( 4, cBranchVld, cMatSRA, cCodRH3 )

	If lChangeEmp
		fNewEmpFiles(cSavEmp, cSavFil, {"SRA","RCH","RCM","SRY"})
	EndIf
EndIf

cJson := oData:toJson()
Self:SetResponse(cJson)

Return(.T.)


// -------------------------------------------------------------------
//"Cria um registo de atestado"
// -------------------------------------------------------------------
WSMETHOD POST fSetMedCertificate WSREST Health

Local oItem        	:= JsonObject():New()
Local cBody			:= Self:GetContent()
Local oBody         := JsonObject():New()
Local aIdFunc       := {}
Local aDataLogin	:= {}
Local cEmpFunc		:= ""
Local cFilFunc      := ""
Local cMatFunc      := ""
Local cBranchVld 	:= ""
Local cMatSRA		:= ""
Local cToken    	:= ""
Local cKeyId    	:= ""
Local cLogin		:= ""
Local cRD0Cod		:= ""
Local cErro			:= ""
Local cJson	    	:= ""
Local cSavFil       := cFilAnt
Local cSavEmp       := cEmpAnt
Local lChangeEmp	:= .F.
Local lRet			:= .T.
Local lRobot		:= .F.
Local lHabil		:= .T.
Local lDemit		:= .F.
Local cRoutine	 := "W_PWSA210.APW" //Afastamentos

Self:SetHeader('Access-Control-Allow-Credentials' , "true")

cToken  	:= Self:GetHeader('Authorization')
cKeyId  	:= Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len( aDataLogin ) > 0
	cMatSRA		:= aDataLogin[1]
	cLogin		:= aDataLogin[2]
	cRD0Cod		:= aDataLogin[3]
	cBranchVld	:= aDataLogin[5]
	lDemit		:= aDataLogin[6]

	cEmpFunc	:= cEmpAnt
	cFilFunc    := cBranchVld
	cMatFunc    := cMatSRA
EndIf

If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])
	aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
	If Len(aIdFunc) > 1
		If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return (.F.)
			EndIf
		Else
			fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementMedical", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return (.F.)
			//valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
				cFilFunc	:= aIdFunc[1]
				cMatFunc	:= aIdFunc[2]
				cEmpFunc	:= aIdFunc[3]
				lChangeEmp	:= !(cEmpFunc == cEmpAnt)
			Else
				lRet	 := .F.
				cErro := EncodeUTF8(STR0047) //"usu�rio n�o autorizado para atualiza��o de atestados!"
			EndIf
		EndIf
	EndIf
Else
	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
		Return (.F.)
	EndIf
EndIF

If !Empty(cBody)

	oBody:fromJson(cBody)

	//Valida��o da data de in�cio do atestado.
	If cToD(Format8601(.T., oBody["begin"])) > Date()
		SetRestFault(400, EncodeUTF8(STR0054)) //"A data de in�cio do atestado n�o pode ser uma data futura."
		Return (.F.)
	EndIf

	If lChangeEmp
		fNewEmpFiles(cEmpFunc, cFilFunc, {"SRA","RCH","RCM","SRY"})
	EndIf

	If lRet
		lRet := fGrvMedCertificate( .T., cBranchVld, cMatSRA, cSavEmp, cFilFunc, cMatFunc, cEmpFunc, cBody, @cErro, @lRobot )
	EndIf

	If lChangeEmp
		fNewEmpFiles(cSavEmp, cSavFil, {"SRA","RCH","RCM","SRY"})
	EndIf

	If lRet
		Self:SetResponse(cBody)
	Else
		If lRobot
			lRet := .T.
			oItem        			:= JsonObject():New()
			oItem["errorCode"] 		:= "400"
			oItem["errorMessage"] 	:= cErro
			cJson := oItem:toJson()
			Self:SetResponse(cJson)
		Else
			SetRestFault(400, cErro, .T.)
		EndIf
	EndIf
EndIf

Return( lRet )


// -------------------------------------------------------------------
//"Atualiza um registo de atestado"
// -------------------------------------------------------------------
WSMETHOD PUT fPutMedCertificate WSREST Health

Local oBody        	:= JsonObject():New()
Local cBody			:= Self:GetContent()
Local aIdFunc       := {}
Local aDataLogin  	:= {}
Local cEmpFunc		:= ""
Local cFilFunc      := ""
Local cMatFunc      := ""
Local cBranchVld 	:= ""
Local cMatSRA		:= ""
Local cLogin		:= ""
Local cToken    	:= ""
Local cKeyId    	:= ""
Local cRD0Cod		:= ""
Local cErro			:= ""
Local cSavFil       := cFilAnt
Local cSavEmp       := cEmpAnt
Local lRet			:= .T.
Local lHabil		:= .T.
Local lDemit		:= .F.
Local lChangeEmp	:= .F.
Local cRoutine	    := "W_PWSA210.APW" //Afastamentos

Self:SetHeader('Access-Control-Allow-Credentials' , "true")

cToken  	:= Self:GetHeader('Authorization')
cKeyId  	:= Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len( aDataLogin ) > 0
	cMatSRA		:= aDataLogin[1]
	cLogin		:= aDataLogin[2]
	cRD0Cod		:= aDataLogin[3]
	cBranchVld	:= aDataLogin[5]
	lDemit		:= aDataLogin[6]

	cFilFunc    := cBranchVld
	cMatFunc    := cMatSRA
	cEmpFunc    := cEmpAnt
EndIf

If Len(::aUrlParms) > 0 .And. !Empty(::aUrlParms[2]) .And. !("current" $ ::aUrlParms[2])

	aIdFunc := STRTOKARR( ::aUrlParms[2], "|" )
	If Len(aIdFunc) > 1
		If ( cBranchVld == aIdFunc[1] .And. cMatSRA == aIdFunc[2] )
			//Valida Permissionamento
			fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return (.F.)
			EndIf
		Else
			fPermission(cBranchVld, cLogin, cRD0Cod, "teamManagementMedical", @lHabil)
			If !lHabil .Or. lDemit
				SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
				Return (.F.)
			//valida se o solicitante da requisi��o pode ter acesso as informa��es
			ElseIf getPermission(cBranchVld, cMatSRA, aIdFunc[1], aIdFunc[2], , aIdFunc[3], cRoutine)
				cFilFunc	:= aIdFunc[1]
				cMatFunc  	:= aIdFunc[2]
				cEmpFunc	:= aIdFunc[3]
				lChangeEmp	:= !(cEmpFunc == cEmpAnt)
			Else
				lRet	 := .F.
				cErro := EncodeUTF8(STR0047) //"usu�rio n�o autorizado para atualiza��o de atestados!"
			EndIf
		EndIf
	EndIf
Else
	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
		Return (.F.)
	EndIf
EndIF

If !Empty(cBody)

	oBody:fromJson(cBody)

	//Valida��o da data de in�cio do atestado.
	If cToD(Format8601(.T., oBody["begin"])) > Date()
		SetRestFault(400, EncodeUTF8(STR0054)) //"A data de in�cio do atestado n�o pode ser uma data futura."
		Return (.F.)
	EndIf

	If lChangeEmp
		fNewEmpFiles(cEmpFunc, cFilFunc, {"SRA","RCH","RCM","SRY"})
	EndIf

	If lRet
		lRet := fGrvMedCertificate( .F., cBranchVld, cMatSRA, cSavEmp, cFilFunc, cMatFunc, cEmpFunc, cBody, @cErro )
	EndIf

	If lChangeEmp
		fNewEmpFiles(cSavEmp, cSavFil, {"SRA","RCH","RCM","SRY"})
	EndIf

	If lRet
		Self:SetResponse(cBody)
	Else
		SetRestFault(400, cErro, .T.)
	EndIf
EndIf

Return( lRet )


// -------------------------------------------------------------------
//"Exclui um registo de atestado"
// -------------------------------------------------------------------
WSMETHOD DELETE fDelMedCertificate WSREST Health

Local oRet      	:= JsonObject():New()
Local aUrlParam		:= Self:aUrlParms
Local aDataLogin	:= {}
Local aIdReq		:= {}
Local nLenParms		:= Len(aUrlParam)
Local cFilRH3    	:= ""
Local cCodRH3    	:= ""
Local cJson	    	:= ""
Local cToken        := ""
Local cBranchVld	:= ""
Local cMatSRA		:= ""
Local cMatRH3		:= ""
Local cLogin		:= ""
Local cIdCrypt		:= ""
Local cRD0Cod		:= ""
Local cCodEmp		:= cEmpAnt
Local cRoutine	 	:= "W_PWSA210.APW" //Afastamentos.
Local lRet			:= .F.
Local lHabil		:= .T.
Local lDemit		:= .F.

Self:SetHeader('Access-Control-Allow-Credentials' , "true")

cToken		:= Self:GetHeader('Authorization')
cKeyId  	:= Self:GetHeader('keyId')
aDataLogin := GetDataLogin(cToken, .T., cKeyId)
If Len( aDataLogin ) > 0
	cMatSRA		:= aDataLogin[1]
	cLogin		:= aDataLogin[2]
	cRD0Cod		:= aDataLogin[3]
	cBranchVld	:= aDataLogin[5]
	lDemit		:= aDataLogin[6]
EndIf

//Valida Permissionamento
fPermission(cBranchVld, cLogin, cRD0Cod, "medicalCertificate", @lHabil)
If !lHabil .Or. lDemit
	SetRestFault(400, EncodeUTF8( STR0049 )) //"Permiss�o negada aos servi�os de atestado"
	Return (.F.)
EndIf

If nLenParms == 3 .And. !Empty(aUrlParam[3])
	cIdCrypt	:= rc4crypt( aUrlParam[3], "MeuRH#AtestadoMedico", .F., .T. )
	aIdReq      := STRTOKARR( cIdCrypt, "|" )
	If Len(aIdReq) > 0
		cFilRH3		:= aIdReq[1]
		cCodRH3		:= aIdReq[2]
		cCodEmp		:= aIdReq[3]
		cMatRH3	 	:= PosAlias( "RH3", cCodRH3, cFilRH3, "RH3_MAT", 1 )
	EndIf

	If !getPermission(cBranchVld, cMatSRA, cFilRH3, cMatRH3, cEmpAnt , cCodEmp , cRoutine)
		lRet := .F.
		cMsg := EncodeUTF8(STR0053) //"Voc� n�o tem permiss�o para acessar esse recurso."
	Else
		lRet := fDelReqById(cFilRH3, ,cCodRH3, "4")
	EndIf
EndIf

If lRet
	//Exclusao efetuada com sucesso
	HttpSetStatus(204)
Else
	HttpSetStatus(400)
	oRet["code"]	:= "400"
	oRet["message"]	:= EncodeUTF8(STR0039) //"A exclus�o n�o pode ser efetuada."

	cJson :=  FWJsonSerialize( oRet, .F., .F., .T.)
	Self:SetResponse(cJson)
EndIf

Return( lRet )


/*/{Protheus.doc} fSetFileImg()
- Respons�vel por gravar a imagem do atestado no Repositorio de Imagens
@author:	Marcelo Silveira
@since:		17/05/2019
@param:		cFileContent - Conteudo codificado da imagem
			cNameArq - Nome do arquivo para o repositorio de imagens
			cFileType - Extensao do arquivo
			cError - Erros durante a criacao do arquivo (referencia)			
@return:	lRet - Imagem criada no servidor ou atualizada no repositorio de imagens
/*/
Function fSetFileImg( cFileContent, cNameArq, cFileType, cError )

	Local nHandle
	Local oFile
	Local oObjImg
	Local lRet		:= .F.
	Local cTextAux	:= ""
	Local nRet		:= 0
	Local nTamArq	:= 5242880 //5MB
	Local cArqTemp 	:= GetSrvProfString ("STARTPATH","")

	DEFAULT cFileContent	:= ""
	DEFAULT cNameArq		:= ""
	DEFAULT cFileType		:= ""
	DEFAULT cError			:= ""

	cArqTemp 	+= (cNameArq +"."+ cFileType)
	cTextAux	:= Decode64( cFileContent )

	If !File( cArqTemp )

		//Cria o arquivo temporario da imagem recebida pela requisicao
		nHandle := FCREATE( cArqTemp )

		If nHandle == -1
			cError := EncodeUTF8(STR0025) + AllTrim(Str(Ferror())) //"Erro ao criar o arquivo tempor�rio da imagem: "
		Else
			FWrite(nHandle, cTextAux )
			FClose(nHandle)

			//Verifica o tamanho do arquivo
			oFile := FwFileReader():New(cArqTemp)
			If (oFile:Open())
				nRet := oFile:getFileSize()
				oFile:Close()
			EndIf

			//Cosidera somente imagens dentro do tamanho limite de 2MB
			If nRet <= nTamArq
				//Instancia o objeto da imagem
				oObjImg := FwBmpRep():New()

				//Exclui caso a imagem ja exista no repositorio
				If oObjImg:ExistBmp(cNameArq)
					oObjImg:DeleteBmp(cNameArq)
				EndIf

				//Adiciona a imagem no repositorio (sem a extensao)
				oObjImg:InsertBmp( cArqTemp, cNameArq, @lRet )

				If lRet
					Ferase(cArqTemp) //Elimina o arquivo temporario
				Else
					cError := EncodeUTF8(STR0029) //"Ocorreu um erro durante a grava��o no reposit�rio de imagens. Tente novamente e se o problema persistir contate o administrador do sistema"
				EndIf
			Else
				cError := EncodeUTF8(STR0043) +" ("+ cValToChar(nRet) +") "+ EncodeUTF8(STR0044) + cValToChar(nTamArq) + " Bytes (5MB)." //"A imagem possui"#"Bytes, e excede o tamanho m�ximo permitido: "
				Ferase(cArqTemp)
			EndIf
		EndIf

	EndIf

Return( lRet )


/*/{Protheus.doc} fGetImgMedical()
- Respons�vel por extrair a imagem do atestado no Repositorio de Imagens e salvar em disco local
@author:	Marcelo Silveira
@since:		17/05/2019
@param:		lTCFA040 - Indica a origem da chamada (Atender requisicao ou Afastamento) 
			cInfoFile - Se a origem for afastamento traz a view da GPEA240, caso contrario traz o nome do arquivo 
/*/
Function fGetImgMedical( lTCFA040, cInfoFile )

	Local nSizeY		:= 500
	Local nSizeX		:= 800
	Local cImg			:= ""
	Local cBmpPict		:= ""
	Local cCpoNumId		:= ""
	Local cNomeFile		:= ""
	Local cCodMat		:= ""
	Local cBkpMod		:= cModulo //Vari�vel publica com o modulo que est� startado. Por padr�o em ambientes REST vem como FAT.
	Local lContinua		:= .T.
	Local lDelete		:= .F.
	Local lPDF			:= .F.
	Local oBmp
	Local oScroll
	Local oButton1
	Local oButton2

	DEFAULT lTCFA040	:= .T.
	DEFAULT cInfoFile	:= ""	//Nome do arquivo no repositorio de imagens

	cModulo := "GPE" // Atribui o m�dulo GPE para consultar corretamente as fotos no banco de dados.
	If !lTCFA040
		//Quando a chamada ocorre na rotina Afastamentos no segundo parametro tera a View da SR8
		//Entao o nome do arquivo sera composto pela filial e os 5 ultimos numeros do campo R8_NUMID
		cCpoNumId := AllTrim( cInfoFile:GetValue("GPEA240_SR8","R8_NUMID") )
		cCodMat	  := cInfoFile:GetValue("GPEA240_SR8","R8_MAT")

		If ( "_" $ cCpoNumId )
			cNomeFile := cInfoFile:GetValue("GPEA240_SR8","R8_FILIAL") +"_"+ SubStr( cCpoNumId, Len(cCpoNumId)-4, 5 )
		Else
			lContinua := .F.
			MsgInfo( STR0064 ) //"Este registro n�o possui anexo."
		EndIf
	Else
		If RH3->(ColumnPos("RH3_BITMAP")) .And. !Empty( RH3->RH3_BITMAP )
			cNomeFile := RH3->RH3_FILIAL +"_"+ RH3->RH3_CODIGO
			cCodMat	  := RH3->RH3_MAT
		Else
			lContinua := .F.
			MsgInfo( STR0064 ) //"Este registro n�o possui anexo."
		EndIf
	EndIf

	If lContinua .And. !Empty( cBmpPict := Upper( AllTrim( cNomeFile ) ) )

		cImg := fGetByBco(cNomeFile, , , @lPDF)
		
		If Empty(cImg)
			cImg 	:= fGetByReposit(cNomeFile)
			lDelete := .T.
		EndIf

		If !Empty(cImg)

			If lPDF
				nSizeY := 200
			EndIf		

			DEFINE DIALOG oDlg TITLE STR0055 FROM 0,0 TO nSizeY,nSizeX PIXEL //"Anexo da solicita�ao"

			@ 0,0 MSPANEL oPanelMenu RAISED SIZE 90,1 OF oDlg
			oPanelMenu:align := CONTROL_ALIGN_RIGHT

			@ 0,0 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE 10, 10 OF oDlg
			oScroll:align := CONTROL_ALIGN_ALLCLIENT

			@ 10,320 BUTTON oButton1 PROMPT STR0033 ;	//"Salvar em disco"
			ACTION ( fImgDownload(cImg,cCodMat)) SIZE 70,15 OF oDlg  PIXEL

			@ 30,320 BUTTON oButton2 PROMPT STR0034 ;	//"Fechar"
			ACTION (oDlg:End()) SIZE 70,15 OF oDlg  PIXEL

			// Carrega a imagem do anexo ou o icone do arquivo PDF
			If lPDF
				@ 040,140 SAY oSay9 PROMPT STR0056 SIZE 061, 009 OF oScroll PIXEL //"(Arquivo PDF)"
				@ 040,120 BITMAP oBmp RESOURCE 'TOTVSPRINTER_PDF.PNG' SCROLL OF oScroll PIXEL
			Else
				@ 000,000 BITMAP oBmp  File(cImg) SCROLL OF oScroll PIXEL
			EndIf

			oBmp:lAutoSize := .T.

			ACTIVATE DIALOG oDlg CENTER

			//Exclui a imagem temporaria do servidor (apenas quando obtida do repositorio de imagens)
			If lDelete .And. File(cImg)
				Ferase(cImg)
			EndIf
		Else
			MsgStop( STR0058, STR0057 ) //"O anexo da solicita��o n�o foi localizado. Contate o administrador do sistema."#"Anexo n�o localizado"
		EndIf
	EndIf
	cModulo := cBkpMod //Volta ao modulo original

Return()


/*/{Protheus.doc} fImgDownload()
- Respons�vel por transferir a imagem temporaria do server para o disco local
@author:	Marcelo Silveira
@since:		17/05/2019
@param:		cArqImg - arquivo da imagem
/*/
Static Function fImgDownload( cArqImg, cCodMat )

	Local lContinua	:= .T.
	Local cOldFile	:= ""
	Local cNewStr	:= ""
	Local cNewFile	:= ""
	Local cPathPict := ""

//Deve ser selecionada uma pasta da unidade local
	While lContinua
		cPathPict := cGetFile( 'JPG|*.jpg|BMP|*.bmp' , STR0027, 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.F., .F. ) //"Selecione o destino do arquivo"
		If (lContinua := Len(cPathPict) > 0 .And. Len(cPathPict) <= 3)
			MsgStop( STR0035 ) //"Selecione uma pasta de sua unidade de disco local."
		EndIf
	End

	If !Empty( cPathPict )

		cNome := FDesc("SRA", cCodMat, "RA_NOME", ,xFilial("SRA"), 1)

		If CpyS2T( cArqImg, cPathPict )

			//Altera o nome do arquivo adicionando o nome do funcionario para facilitar a identificacao
			cOldFile := cPathPict + RetFileName(cArqImg) + SubStr(cArqImg, Len(cArqImg)-3, 4)
			cNewStr  := RetFileName(cArqImg) + " - " + AllTrim(cNome)
			cNewFile := STRTRAN( cOldFile, RetFileName(cArqImg), cNewStr )

			//Exclui caso exista arquivo com o mesmo nome no destino
			If File(cNewFile)
				Ferase(cNewFile)
			EndIf

			Frename( cOldFile, cNewFile )

			MsgInfo( STR0059 ) //"O arquivo foi transferido com sucesso!"

		EndIf

	EndIf

Return()


/*/{Protheus.doc} GetMedCertification
Verifica se ja existe atestado cadastrado para o funcionario no dia informado
@author:	Marcelo Silveira
@since:		21/05/2019
@param:		cFilSra - Filial;
			cMatSra - Matr�cula;
			cDtSolic - Data da solicitacao (considera a partir da data inicial da competencia da folha);
			cAfas - Codigo do afastamento
			cInitDate - Data inicial do atestado;
			cEndDate - Data final do atestado;
			lReject - Indica se o atestado foi rejeitado em caso de cadastro em duplicidade;
@return:	lRet - Se n�o localizar nenhum registro retorna verdadeiro			
/*/
Static Function GetMedCertification( cFilSra, cMatSra, cDtSolic, cInitDate, cEndDate, lReject )

	Local cQryRH3  	:= GetNextAlias()
	Local cQryRH4 	:= GetNextAlias()
	Local lRet 	   	:= .T.
	Local lAtend	:= .F.
	Local cCpoRH4	:= ""
	Local cValRH4	:= ""
	Local dDataIni	:= cTod("//")
	Local dDataFim	:= cTod("//")

	cDtSolic := "% '" + cDtSolic + "' %"

	BeginSql alias cQryRH3
	SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH3.RH3_STATUS
	FROM  %table:RH3% RH3 
	WHERE
		RH3.RH3_FILIAL = %exp:cFilSra% AND
		RH3.RH3_MAT = %exp:cMatSra% AND
		RH3.RH3_DTSOLI >= %Exp:cDtSolic% AND
    	RH3.RH3_TIPO = 'R' AND
		RH3.%notDel% 
	EndSql

	While !(cQryRH3)->(Eof())

		lReject := (cQryRH3)->RH3_STATUS == "3"
		lAtend  := (cQryRH3)->RH3_STATUS == "2"

		BeginSql alias cQryRH4
		SELECT *
		FROM  %table:RH4% RH4
		WHERE 	
			RH4.RH4_CODIGO = %exp:(cQryRH3)->RH3_CODIGO% AND
			(RH4.RH4_CAMPO = "R8_TIPOAFA" OR
			 RH4.RH4_CAMPO = "R8_DATAINI" OR
			 RH4.RH4_CAMPO = "R8_DATAFIM" ) AND
			 RH4.%notDel%
		EndSql

		dDataIni := cTod("//")
		dDataFim := cTod("//")

		While !(cQryRH4)->(Eof())
			cCpoRH4 := AllTrim( (cQryRH4)->RH4_CAMPO )
			cValRH4 := AllTrim( (cQryRH4)->RH4_VALNOV )

			If cCpoRH4 == "R8_DATAINI"
				dDataIni := CTOD( cValRH4 )
			EndIf
			If cCpoRH4 == "R8_DATAFIM"
				dDataFim := CTOD( cValRH4 )
			EndIf

			(cQryRH4)->(DBSkip())
		Enddo

		//Primeira verifica��o. Se o atestado j� cadastrado n�o possui data fim.
		If Empty(dDataFim)
			If 	( cInitDate >= dDataIni ) .Or. ( cEndDate >= dDataIni)
				If !lAtend .Or. !AfasDtValid(SRA->RA_FILIAL,SRA->RA_MAT,dDataIni)
					lRet := .F.
					(cQryRH4)->(DBCloseArea())
					Exit
				EndIf
			EndIf
		//Segunda verifica��o. Se o atestado que est� sendo lan�ado n�o possui data fim.
		ElseIf Empty(cEndDate)
			If 	( cInitDate >= dDataIni ) .Or. ;
				( cInitDate <= dDataIni .And. cEndDate <= dDataFim )

				If !lAtend .Or. !AfasDtValid(SRA->RA_FILIAL,SRA->RA_MAT,dDataIni)
					lRet := .F.
					(cQryRH4)->(DBCloseArea())
					Exit
				EndIf
			EndIf
		Else
			If 	( cInitDate == dDataIni .Or. cInitDate == dDataFim ) .Or. ;
				( cEndDate == dDataIni .Or. cEndDate == dDataFim ) .Or. ;
				( cInitDate >= dDataIni .And. cInitDate <= dDataFim ) .Or. ;
				( cEndDate >= dDataIni .And. cEndDate <= dDataFim ) .Or. ;
				( cInitDate <= dDataIni .And. cEndDate >= dDataFim )

				If !lAtend .Or. !AfasDtValid(SRA->RA_FILIAL,SRA->RA_MAT,dDataIni)
					lRet := .F.
					(cQryRH4)->(DBCloseArea())
					Exit
				EndIf
			EndIf
		EndIf
		(cQryRH4)->(DBCloseArea())

		(cQryRH3)->(DBSkip())
	Enddo

	(cQryRH3)->(DBCloseArea())

Return(lRet)


/*/{Protheus.doc} fGetRegsMedical
Carrega as solicitacoes de atestado do funcionario conforme os parametros
@author:	Marcelo Silveira
@since:		22/05/2019
@param:		nType - 1=Solicitacoes com status pendentes, 2=demais status diferente de pendente, 3=Todos;
			cFilSra - Filial;
			cMatSra - Matr�cula;
			cCodReq - Codigo da requisicao;
			cPage - Numero da pagina;
			cPageSize - Numero de registros;
			lNextPage - Indica se existe ou nao mais registros;
@return:	aFields - array com o json das solicitacoes			
/*/
Static Function fGetRegsMedical( nType, cBranchVld, cMatSRA, cCodReq, cPage, cPageSize, lNextPage  )

	Local oFields      	:= JsonObject():New()
	Local oType      	:= JsonObject():New()
	Local oFile      	:= JsonObject():New()
	Local dDtAfaIni		:= CTOD("//")
	Local aArea        	:= {}
	Local aPerAtual		:= {}
	Local aFields      	:= {}
	Local aType      	:= {}
	Local nRegCount     := 0
	Local nRegIniCount  := 0
	Local nRegFimCount  := 0
	Local cDataIni		:= ""
	Local cBegin		:= ""
	Local cEnd			:= ""
	Local cCid			:= ""
	Local cDescMot		:= ""
	Local cQryRH3		:= ""
	Local cQryRH4		:= ""
	Local cFilRH3		:= ""
	Local cCodRH3		:= ""
	Local cStatus		:= ""
	Local cRejec		:= ""
	Local cNameArq		:= ""
	Local cFileType		:= ""
	Local cMsg			:= ""
	Local cRet			:= ""
	Local cRotFOL		:= ""
	Local cJustify		:= ""
	Local cMotivo		:= ""
	Local cNomMed		:= ""
	Local cCRMMed		:= ""
	Local cIdeOC		:= ""
	Local cCodEmp		:= ""
	Local cWhere 		:= "%"
	Local cCpoRH3		:= If( RH3->(ColumnPos("RH3_BITMAP")) > 0, "%, RH3_BITMAP %", "%%" )
	Local lContinua		:= .T.
	Local lCount		:= .F.

	DEFAULT	cCodReq		:= ""
	DEFAULT cPage		:= ""
	DEFAULT cPageSize	:= ""
	DEFAULT lNextPage	:= .F.

	//----------------------------------------------------------
	//Deve existir calendario para a folha de pagamento e apresentar 
	//somente os atestados solicitados a partir dessa competencia
	//----------------------------------------------------------
	aArea := GetArea()
	DbSelectArea("SRA")
	If SRA->( dbSeek( cBranchVld + cMatSRA ) )

		//Para Aut�nomo busca o roteiro AUT, para todos os outros o FOL.
		cRotFOL := If(AllTrim(SRA->RA_CATFUNC) == "A", "AUT", fGetRotOrdinar()) 

		fGetPerAtual( @aPerAtual, xFilial("RCH", cBranchVld), SRA->RA_PROCES, cRotFOL )

		If Len( aPerAtual ) > 0
			cDataIni := "% '" + dToS(aPerAtual[1,6]) + "' %"
		Else
			lContinua := .F.
		EndIf

	EndIf
	RestArea( aArea )

	If lContinua .Or. (nType == 4)

		//Faz o controle de paginacao
		If !Empty(cPage) .And. !Empty(cPageSize)
			If cPage == "1" .Or. cPage == ""
				nRegIniCount := 1
				nRegFimCount := If( Empty( Val(cPageSize) ), 20, Val(cPageSize) )
			Else
				nRegIniCount := ( Val(cPageSize) * ( Val(cPage) - 1 ) ) + 1
				nRegFimCount := ( nRegIniCount + Val(cPageSize) ) - 1
			EndIf
			lCount := .T.
		EndIf

		cQryRH3 := GetNextAlias()

		//--------------------------------------------
		//1 = Atestados Pendentes de aprovacao (GET)
		//2 = Atestados Aprovados ou Reprovados (GET)
		//3 = Todos os Atestados (GET)
		//4 = O registro de um codigo especifico (PUT - Atualizacao)
		//--------------------------------------------
		If nType == 1
			cWhere += " RH3.RH3_STATUS = '4' AND "
		ElseIf nType == 2
			cWhere += " RH3.RH3_STATUS NOT IN ('4') AND "
		ElseIf nType == 4
			cWhere += " RH3.RH3_CODIGO = '" + cCodReq + "' AND "
		EndIf
		cWhere += "%"

		BEGINSQL ALIAS cQryRH3
	
		SELECT RH3_FILIAL, RH3_CODIGO, RH3_MAT, RH3_STATUS, RH3_DTSOLI, RH3_DTATEN, RA_PROCES, RH3_EMP %Exp:cCpoRH3% 
		FROM %Table:RH3% RH3
		INNER JOIN %Table:SRA% SRA ON
			RH3_FILIAL = RA_FILIAL AND
			RH3_MAT = RA_MAT		
		WHERE
			RH3.RH3_TIPO='R' AND
			RH3.RH3_FILIAL=%Exp:cBranchVld% AND RH3.RH3_MAT=%Exp:cMatSRA% AND
			RH3.RH3_DTSOLI >= %Exp:cDataIni% AND
			%Exp:cWhere% 
			RH3.%NotDel%
		ENDSQL

		While !(cQryRH3)->(Eof())

			cFilRH3		:= (cQryRH3)->RH3_FILIAL
			cCodRH3 	:= (cQryRH3)->RH3_CODIGO
			cCodEmp     := (cQryRH3)->RH3_EMP
			cStatus		:= If( (cQryRH3)->RH3_STATUS=='2', "approved", If((cQryRH3)->RH3_STATUS=='3', 'rejected', 'pending') )
			aType		:= {}

			cQryRH4 := GetNextAlias()

			BEGINSQL ALIAS cQryRH4
		
			SELECT RH4_FILIAL, RH4_CODIGO, RH4_CAMPO, RH4_VALNOV
			FROM %Table:RH4% RH4
			WHERE
				RH4.RH4_FILIAL = %Exp:cFilRH3% AND RH4.RH4_CODIGO=%Exp:cCodRH3% AND 
				RH4.%NotDel%
	
			ENDSQL

			While (cQryRH4)->(!Eof())

				cCpoRH4 := AllTrim((cQryRH4)->RH4_CAMPO)

				DO CASE
				CASE cCpoRH4 == "R8_DATAINI"
					cBegin		:= formatGMT(Alltrim((cQryRH4)->RH4_VALNOV))
				CASE cCpoRH4 == "R8_DATAFIM"
					If Alltrim((cQryRH4)->RH4_VALNOV) == "/  /"
						cEnd := Nil
					Else
						cEnd := formatGMT(Alltrim((cQryRH4)->RH4_VALNOV))
					EndIf
				CASE cCpoRH4 == "R8_CID"
					cCid		:= Alltrim((cQryRH4)->RH4_VALNOV)
				CASE cCpoRH4 == "R8_TIPOAFA"
					cMotivo		:= Alltrim((cQryRH4)->RH4_VALNOV)
				CASE cCpoRH4 == "TMP_MOTIVO"
					cDescMot	:= Alltrim((cQryRH4)->RH4_VALNOV)
				CASE cCpoRH4 == "TMP_OBS"
					cJustify	:= If((cQryRH3)->RH3_STATUS == '3', '', Alltrim((cQryRH4)->RH4_VALNOV))
				CASE cCpoRH4 == "R8_NMMED"
					cNomMed		:= Alltrim((cQryRH4)->RH4_VALNOV)
				CASE cCpoRH4 == "R8_CRMMED"
					cCRMMed		:= Alltrim((cQryRH4)->RH4_VALNOV)
				CASE cCpoRH4 == "R8_IDEOC"
					cIdeOC		:= Alltrim((cQryRH4)->RH4_VALNOV)
				ENDCASE

				(cQryRH4)->(DbSkip())
			EndDo

			(cQryRH4)->( DBCloseArea() )

			If nType == 4
				//-------------------------
				//Dados do anexo a partir do banco de conhecimento
				cRet := fInfBcoFile( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cFileType, @cMsg )

				//Dados do anexo a partir do repositorio de imagens (quando nao localiza no BC p/ nao afetar o historico)
				If Empty(cRet)
					cRet := fMedImg( 1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cFileType, @cMsg )
				EndIf

				oFile      			:= JsonObject():New()
				oFile["content"] 	:= cRet
				oFile["type"]    	:= cFileType
				oFile["name"]    	:= cNameArq
				//-------------------------

				oFields 			:= JsonObject():New()
				oFields["id"]		:= RC4CRYPT( cFilRH3 +"|"+ cCodRH3 +"|"+ cCodEmp, "MeuRH#AtestadoMedico")
				oFields["type"]		:= Iif( Empty(cIdeOC), "1", cIdeOC ) // Se n�o existir, carrega M�dico no padr�o.
				oFields["begin"]	:= cBegin
				oFields["end"]		:= cEnd
				oFields["cid"]		:= cCid
				oFields["justify"]	:= EncodeUTF8(cJustify)
				oFields["reason"]	:= EncodeUTF8(cMotivo)
				oFields["doctorName"]				:= EncodeUTF8(cNomMed)
				oFields["medicalRegionalCouncil"]	:= EncodeUTF8(cCRMMed)
				oFields["file"]		:= oFile

				aFields := oFields

			Else
				//Se a solicitacao j� tiver sido atendida ela precisa ter afastamento, caso contrario ser� desconsiderada
				If nType == 2 .And. (cQryRH3)->RH3_STATUS == "2" 
					dDtAfaIni := STOD( StrTran(SubStr(cBegin, 1, 10), "-", "") )
					If AfasDtValid(SRA->RA_FILIAL,SRA->RA_MAT,dDtAfaIni)
						(cQryRH3)->(dbSkip())
						Loop
					EndIf					
				EndIf

				nRegCount ++

				If !lCount .Or. ( nRegCount >= nRegIniCount .And. nRegCount <= nRegFimCount )
					oType				:= JsonObject():New()
					oType["id"] 		:= Iif( Empty(cIdeOC), "1", cIdeOC ) // Se n�o existir, carrega M�dico no padr�o.
					oType["name"] 		:= IIf( oType["id"] == "1", EncodeUTF8( STR0050 ), EncodeUTF8( STR0051 ) ) // M�dico ou Odontol�gico.

					oFields 			:= JsonObject():New()
					oFields["id"]		:= RC4CRYPT( cFilRH3 +"|"+ cCodRH3 +"|"+ cCodEmp, "MeuRH#AtestadoMedico")
					oFields["status"]	:= cStatus
					oFields["type"]		:= oType
					oFields["reason"]	:= EncodeUTF8( cDescMot )
					oFields["begin"]	:= cBegin
					oFields["end"]		:= cEnd
					oFields["sent"]		:= formatGMT( cValToChar( StoD((cQryRH3)->RH3_DTSOLI) ) )
					oFields["cid"]		:= cCid
					If (cQryRH3)->RH3_STATUS == '3'
						cRejec	:= getRGKJustify(cFilRH3, cCodRH3, Nil, .T.)
						oFields["rejectionJustify"]	:= AllTrim(cRejec)
					EndIf
					oFields["canEdit"]	:= (cQryRH3)->RH3_STATUS $ '3/4'
					oFields["canDelete"]:= (cQryRH3)->RH3_STATUS == '4'

					Aadd(aFields,oFields)
				Else
					If nRegCount >= nRegFimCount
						lNextPage := .T.
						Exit
					EndIf
				EndIf

			EndIf

			aType := {}

			(cQryRH3)->(dbSkip())
		EndDo

		(cQryRH3)->( DBCloseArea() )

	EndIf

Return( aFields )


/*/{Protheus.doc} fMedImg
Carrega as informacoes e/ou faz o download do imagem do atestado medico
@author:	Marcelo Silveira
@since:		23/05/2019
@param:		nType - 1=Dados do arquivo, 2=arquivo para download;
			cFilRH3 - Filial da requisicao;
			cCodRH3 - Codigo da requisicao;
			cNameArq - Nome do arquivo gerado;
			cType - Extensao do arquivo;
			cMsg - Erros ocorridos na extracao da imagem;
@return:	cReturn - Conteudo do arquivo			
/*/
Function fMedImg( nType, cFilRH3, cCodRH3, cBranchVld, cMatSRA, cNameArq, cType, cMsg )

	Local oFile
	Local aArea			:= {}
	Local cArqTemp		:= ""
	Local cImg			:= ""
	Local cPathPict		:= ""
	Local cRet			:= ""
	Local cBkpMod		:= cModulo //Vari�vel publica com o modulo que est� startado. Por padr�o em ambientes REST vem como FAT.
	Local lExist		:= .F.
	Local lContinua		:= .T.

	DEFAULT cFilRH3		:= ""
	DEFAULT cCodRH3		:= ""
	DEFAULT cNameArq	:= ""
	DEFAULT cType		:= ""
	DEFAULT cMsg		:= ""

	//valida��o de seguran�a para acesso � informa��es do atestado
	If Empty(cBranchVld) .or. Empty(cMatSRA)
		cMsg      := EncodeUTF8( STR0045 ) //"usu�rio n�o informado para avalia��o de atestados!"
		lContinua := .F.
		cFilRH3   := ""
		cCodRH3   := ""
	EndIf

	If !Empty(cFilRH3) .And. !Empty(cCodRH3)

		cModulo 	:= "GPE" // Atribui o m�dulo GPE para consultar corretamente as fotos no banco de dados.
		cArqTemp	:= cFilRH3 +"_"+ cCodRH3
		cPathPict	:= GetSrvProfString ("STARTPATH","")

		aArea := GetArea()
		DbSelectArea("RH3")
		DbSetOrder(1)
		If RH3->(ColumnPos("RH3_BITMAP")) > 0 .And. RH3->( dbSeek( cFilRH3 + cCodRH3 ) )
			lContinua := !Empty( RH3->RH3_BITMAP )
		Else
			lContinua := .F.
		EndIf

		//valida permiss�o de acesso aos atestados quando esta sendo consultado por outra matricula
		If (RH3->RH3_FILIAL+RH3_MAT) != (cBranchVld+cMatSRA)
			If !getPermission(cBranchVld, cMatSRA, RH3->RH3_FILIAL, RH3->RH3_MAT, , RH3->RH3_EMP)
				cMsg      := EncodeUTF8( STR0046 ) //"usu�rio n�o autorizado para avalia��o de atestados!"
				lContinua := .F.
			EndIf
		EndIf

		RestArea( aArea )

		If lContinua

			//Cria o objeto da imagem
			oObjImg := FwBmpRep():New()

			//Extrai a imagem para a pasta system
			oObjImg:Extract( cArqTemp, cPathPict+cArqTemp )

			Do Case
				Case File( (cImg := cPathPict+cArqTemp) + ".jpg" )
					cType 	:= "jpg"
					cImg 	+= ".jpg"
					lExist 	:= .T.
				Case File( (cImg := cPathPict+cArqTemp) + ".bmp" )
					cType 	:= "bmp"
					cImg 	+= ".bmp"
					lExist 	:= .T.

					//Se a imagem for BMP converte para JPG
					cNewImg := cArqTemp + "_new"
					If ( BmpToJpg (cImg, cPathPict+cNewImg+".jpg") ) == 0
						fErase(cImg)
						cImg  := cPathPict+cNewImg + ".jpg"
					EndIf
			End Case

			If lExist

				oFile := FwFileReader():New(cImg)

				If (oFile:Open())
					cRet := oFile:FullRead()
					oFile:Close()

					If nType == 1
						//Retorna informacoes do arquivo
						cNameArq := cArqTemp
						cRet     := Encode64(cRet)
					Else
						//Retorna o arquivo para download
						cNameArq := cImg
					EndIf
				EndIf

				Ferase(cImg)
			Else
				cMsg := EncodeUTF8( STR0031 ) //"A imagem n�o foi localizada no reposit�rio de imagens. Contate o administrador do sistema."
			EndIf
		Else
			cMsg := EncodeUTF8( STR0026 ) //"Este registro n�o possui a imagem do atestado m�dico."
		EndIf
		cModulo := cBkpMod //Volta ao modulo original
	EndIf

Return( cRet )


/*/{Protheus.doc} fGrvMedCertificate
Efetua a inclusao ou a alteracao de uma solicitacao de atestado medico
@author:	Marcelo Silveira
@since:		27/05/2019
@param:		lNewReg - Indica se e inclusao (.T.) ou alteracao (.F.)
			cBranchVld - Filial;
			cMatSRA - Matr�cula;
			cBody - Json com o corpo da requisicao;
			oItemDetail - Objeto Json com o corpo da requisicao;
			cError - Erros durante a criacao do arquivo (referencia)
@return:	lRet - Verdadeiro se o registro foi incluido ou alterado com sucesso			
/*/
Static Function fGrvMedCertificate( lNewReg, cBranchVld, cMatSRA, cEmpSRA, cFilFunc, cMatFunc, cEmpFunc, cBody, cErro, lRobot )

Local oItemDetail	:= JsonObject():New()
Local cFilRH3		:= ""
Local cCid			:= ""
Local cCodAfas		:= ""
Local cDtIniSolic	:= ""
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cDescAfas		:= ""
Local cAnoMes		:= ""
Local cMotEsoc		:= ""
Local cJustify		:= ""
Local cNomeFun		:= ""
Local cVerba		:= ""
Local cId    		:= ""
Local cChaveSRA     := ""
Local cNameArq		:= ""
Local cRotFOL		:= ""
Local cNomMed		:= ""
Local cCRMMed		:= ""
Local cIdeOC		:= ""
Local cType			:= ""
Local cCodEmp		:= cEmpAnt
Local cCodRH3		:= 0
Local cBkpMod		:= cModulo //Vari�vel publica com o modulo que est� startado. Por padr�o em ambientes REST vem como FAT.
Local nCount		:= 0
Local nDays			:= 0
Local nItem			:= 0
Local nSaveSX8		:= GetSX8Len()
Local aCpos 	    := {}
Local aPerAtual	    := {}
Local aIdReq		:= {}
Local lContinua		:= .T.
Local lExistImg		:= .T.
Local lRet			:= .T.
Local lRec			:= .F.
Local lReject		:= .F.

Default cBody		:= ""
Default lNewReg		:= .T.
Default lRobot		:= .F.

If !Empty(cBody)

	cModulo := "GPE" // Atribui o m�dulo GPE para consultar corretamente as fotos no banco de dados.
	oItemDetail:FromJson(cBody)

	cType		:= Iif(oItemDetail:hasProperty("type"),oItemDetail["type"],"1")
	cId			:= Iif(oItemDetail:hasProperty("id"),oItemDetail["id"]," ")
	cCodAfas	:= Iif(oItemDetail:hasProperty("reason"),oItemDetail["reason"]," ")
	cDataIni	:= Iif(oItemDetail:hasProperty("begin"),CTOD(Format8601(.T.,oItemDetail["begin"])), CTOD("//"))
	cDataFim	:= Iif(oItemDetail:hasProperty("end"),CTOD(Format8601(.T.,oItemDetail["end"])), CTOD("//"))
	cCid   		:= Iif(oItemDetail:hasProperty("cid"),oItemDetail["cid"]," ")
	cJustify	:= Iif(oItemDetail:hasProperty("justify"),Alltrim(FwCutOff(oItemDetail["justify"]))," ")
	cFileTipe	:= Iif(oItemDetail:hasProperty("file"),oItemDetail["file"]["type"]," ")
	cFileContent:= Iif(oItemDetail:hasProperty("file"),oItemDetail["file"]["content"]," ")
	nDays		:= Iif( !Empty(cDataFim), (cDataFim - cDataIni + 1), 999)
	cNomMed		:= Iif(oItemDetail:hasProperty("doctorName"),oItemDetail["doctorName"]," ")
	cCRMMed		:= Iif(oItemDetail:hasProperty("medicalRegionalCouncil"),oItemDetail["medicalRegionalCouncil"]," ")
	cIdeOC		:= Iif( !Empty(cNomMed) .And. !Empty(cCRMMed), cType, "") // 1 - CRM, 2 - CRO
	lRobot		:= Iif(oItemDetail:hasProperty("execRobo"), oItemDetail["execRobo"], "0") == "1"

	// Valida��o da justificativa
	lContinua := !Empty(cJustify)
	cErro     := If(Empty(cJustify), EncodeUTF8(STR0063), "") //"Informe uma justificativa!"
	
	If lContinua .And. (Len(cJustify) > 50 .Or. Len(cJustify) < 3)
		lContinua := .F.
		cErro := EncodeUTF8(STR0062) //"A Justificativa deve ter no m�nimo 3 e no m�ximo 50 caracteres!"
	EndIf

	//----------------------------------------------------------
	//Aceita somente arquivos de imagem validos
	//----------------------------------------------------------
	If lContinua .And. (Empty(cFileContent) .Or. (Empty(cFileTipe) .Or. !cFileTipe $ ("jpg||jpeg||pdf||png||JPG||JPEG||PDF||PNG")))
		cErro := EncodeUTF8( STR0060 ) //"Anexo inv�lido. Selecione um arquivo de imagem do tipo JPG, PNG ou PDF"
		lExistImg := .F.
		lContinua := .F.
	EndIf

	//----------------------------------------------------------
	//Obtem os dados do Funcionario e do periodo da folha
	//----------------------------------------------------------
	If lContinua

		cChaveSRA := cFilFunc + cMatFunc

		DbSelectArea("SRA")
		If SRA->( dbSeek( cChaveSRA ) )
			cProc 		:= SRA->RA_PROCES
			cNomeFun	:= AllTrim(SRA->RA_NOME)
			//Para Aut�nomo busca o roteiro AUT, para todos os outros o FOL
			cRotFOL := If(AllTrim(SRA->RA_CATFUNC) == "A", "AUT", fGetRotOrdinar()) 

			fGetPerAtual( @aPerAtual, xFilial("RCH", cFilFunc), SRA->RA_PROCES, cRotFOL )

			//----------------------------------------------------------
			//Deve existir calendario para a folha de pagamento e o
			//atestado n�o pode ser cadastrado antes dessa compet�ncia
			//----------------------------------------------------------
			If Len( aPerAtual ) > 0
				lContinua := (cDataIni >= aPerAtual[1,6])
				cDtIniSolic := dToS(aPerAtual[1,6])
				cAnoMes	:= aPerAtual[1,5] +"/"+ aPerAtual[1,4]
				cErro := If( lContinua, "", EncodeUTF8(STR0015 + cAnoMes) ) //"O atestado n�o pode ser inclu�do antes da compet�ncia da Folha de Pagamento: "
			Else
				cErro := EncodeUTF8(STR0016) //"Ocorreu um erro durante a valida��o dos dados. Verifique se existe per�odo selecionado para a Folha de Pagamento."
				lContinua := .F.
			EndIf

		Else
			cErro := EncodeUTF8( STR0048 ) +": " +cChaveSRA  //"Funcion�rio n�o localizado na atualiza��o do atestado"
			lContinua := .F.
		EndIf
	EndIf

	If lContinua

		//Obtem os dados do Tipo de Afastamento
		DbSelectArea("RCM")
		If RCM->( dbSeek( xFilial("RCM", cFilFunc) + cCodAfas ) )
			cVerba    := RCM->RCM_PD		        //Verba
			cDescAfas := AllTrim(RCM->RCM_DESCRI) 	//Descricao do afastamento
			cMotEsoc  := RCM->RCM_TPEFD	            //Motivo afastamento eSocial
		Else
			cErro     := EncodeUTF8(STR0017 +"("+ cCodAfas +") " + STR0018) //"Ocorreu um erro durante a valida��o dos dados. Verifique o c�digo: "#"no cadastro Tipos de Afastamento (tabela RCM)."
			lContinua := .F.
		EndIf

	EndIf

	//Verifica se o atestado esta sendo cadastrado em duplicidade
	If lContinua .and. lNewReg
		If !GetMedCertification( SRA->RA_FILIAL, SRA->RA_MAT, cDtIniSolic, cDataIni, cDataFim, @lReject )
			cErro := EncodeUTF8( STR0023 ) //"J� existe uma solicita��o cadastrada para esta data."
			If lReject
				cErro += " " + EncodeUTF8( STR0040 ) //"Verifique o motivo pelo qual o atestado foi rejeitado e utilize a op��o de reenvio."
			EndIf

			lContinua := .F.
		EndIf
	EndIf

	If lContinua

		DbSelectArea("RH3")
		If lNewReg
			cFilRH3		:= xFilial("RH3", cFilFunc)
			cCodRH3		:= GetSX8Num("RH3", "RH3_CODIGO",RetSqlName("RH3")) //Reserva o codigo na RH3.
		Else
			If empty(cId)
				cErro := EncodeUTF8( STR0041 ) +". " + EncodeUTF8( STR0042 )  //"N�o foi localizada a solicitacao original:#"Contate o administrador do sistema."
				lContinua := .F.
			Else
				cId      := rc4crypt( cId, "MeuRH#AtestadoMedico", .F., .T. )
				aIdReq   := STRTOKARR( cId, "|" )
				IF Len(aIdReq) > 0
					cFilRH3  := aIdReq[1]
					cCodRH3  := aIdReq[2]
					cCodEmp	 := aIdReq[3]
				EndIf
				If !RH3->(dbSeek( cFilRH3 + cCodRH3 ))
					cErro := EncodeUTF8( STR0041 ) +" ("+ cCodRH3 + "). " + EncodeUTF8( STR0042 )  //"N�o foi localizada a solicitacao original:#"Contate o administrador do sistema."
					lContinua := .F.
				EndIf
			EndIf
		EndIf

		//----------------------------------------------------------
		//Adiciona a imagem no Repositorio de Imagens
		//----------------------------------------------------------
		If lExistImg .And. lContinua
			cNameArq  := cFilFunc +"_"+ cCodRH3
			// Se for altera��o, deleta a imagem do reposit�rio de imagens.
			If !lNewReg
				fDelImgRep( cNameArq )
			EndIf
			lContinua := fSetBcoFile( cFileContent, cNameArq, cFileTipe, @cErro, cCodEmp )
		EndIf

		//----------------------------------------------------------
		//Grava a requisicao do Atestado - (RH3)
		//----------------------------------------------------------
		If lContinua
			If !Empty(cCodRH3)

				//Adiciona os campos necessarios para a inclusao do Afastamento
				aAdd( aCpos, { "R8_FILIAL"	, SRA->RA_FILIAL } )
				aAdd( aCpos, { "R8_MAT"		, SRA->RA_MAT } )
				aAdd( aCpos, { "TMP_NOME"	, cNomeFun } )
				aAdd( aCpos, { "R8_TIPOAFA"	, cCodAfas } )
				aAdd( aCpos, { "TMP_MOTIVO"	, cDescAfas } )
				aAdd( aCpos, { "R8_PD" 		, cVerba } )
				aAdd( aCpos, { "R8_DATAINI"	, cValToChar(cDataIni) } )
				aAdd( aCpos, { "R8_DATAFIM"	, cValToChar(cDataFim) } )
				aAdd( aCpos, { "R8_DURACAO"	, cValToChar(nDays) } )
				aAdd( aCpos, { "R8_TPEFD"	, cMotEsoc } )
				aAdd( aCpos, { "R8_CID"		, cCid } )
				aAdd( aCpos, { "R8_NUMID"	, "SR8" + SRA->RA_MAT + cVerba + DtoS(cDataIni) +"_"+ cCodRH3 } )
				aAdd( aCpos, { "TMP_OBS"	, DecodeUTF8(cJustify) } )
				aAdd( aCpos, { "R8_NMMED"	, DecodeUTF8(cNomMed) } )
				aAdd( aCpos, { "R8_CRMMED"	, DecodeUTF8(cCRMMed) } )
				aAdd( aCpos, { "R8_IDEOC"	, cIdeOC } )

				Begin Transaction

					Reclock("RH3", lNewReg)
					If lNewReg
						RH3->RH3_CODIGO	:= cCodRH3
						RH3->RH3_FILIAL	:= cFilRH3
						RH3->RH3_MAT	:= SRA->RA_MAT
						RH3->RH3_TIPO	:= "R"	//Licencas e Afastamentos
						RH3->RH3_ORIGEM	:= STR0013 	//"MEURH"
						RH3->RH3_DTSOLI	:= dDataBase
						RH3->RH3_NVLAPR	:= 99
						RH3->RH3_NVLINI := 1
						RH3->RH3_FILINI	:= cBranchVld
						RH3->RH3_MATINI	:= cMatSRA
					EndIf
					RH3->RH3_STATUS	:= "4"	//Aguardando aprovacao do RH

					If lExistImg .And. RH3->(ColumnPos("RH3_BITMAP")) > 0
						RH3->RH3_BITMAP := cNameArq
					EndIf

					If RH3->(ColumnPos("RH3_EMP")) > 0 .AND. RH3->(ColumnPos("RH3_EMPINI")) > 0 .AND. RH3->(ColumnPos("RH3_EMPAPR")) > 0
						RH3->RH3_EMP	:= cEmpFunc
						RH3->RH3_EMPINI	:= cEmpSRA
						RH3->RH3_EMPAPR	:= cEmpFunc
					EndIf
					RH3->(MsUnlock())

					//----------------------------------------------------------
					//Grava na inclusao/alteracao o detalhe da requisicao do Atestado - (RH4)
					//----------------------------------------------------------
					DbSelectArea("RH4")
					For nCount:= 1 To Len(aCpos)
						If lNewReg
							lRec := .T.
						Else
							lRec := !RH4->( DbSeek(cFilRH3+cCodRH3+AllTrim(STR(nItem+1))) )
						EndIf
						RecLock( "RH4", lRec )
						RH4->RH4_FILIAL	:= cFilRH3
						RH4->RH4_CODIGO	:= cCodRH3
						RH4->RH4_ITEM	:= ++nItem
						RH4->RH4_CAMPO	:= aCpos[nCount, 1]
						RH4->RH4_VALNOV	:= aCpos[nCount, 2]
						RH4->(MsUnlock())
					Next

				End Transaction

			EndIf

			//Efetiva a grava��o do registro reservado.
			If lNewReg
				If ( GetSx8Len() > nSaveSx8 )
					ConfirmSX8()
				Else
					RollBackSx8()
					cErro := EncodeUTF8(STR0014) //"Ocorreu um erro durante a grava��o dos dados. Fa�a o cadastro novamente e se o problema persistir contate o administrador do sistema"
					lRet := .F.
				EndIf
			EndIf
		Else
			If lNewReg
				RollBackSx8()
			EndIf
			lRet := .F.
		EndIf

	Else
		lRet := .F.
	EndIf

	FreeObj(oItemDetail)
	cModulo := cBkpMod //Volta ao modulo original

EndIf

Return( lRet )
