#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP11.CH"

WSRESTFUL Tae DESCRIPTION STR0001 //MEURH - SERVI�O DE INTEGRA��O COM O TAE

	WSMETHOD POST TokenTae ;
    DESCRIPTION STR0002 ; 	//"Gera token de integra��o com o TAE"
    WSSYNTAX "/tae/token" ;
    PATH     "/tae/token" ;
    PRODUCES "application/json;charset=utf-8"    

	WSMETHOD POST DashTae ;
    DESCRIPTION STR0002; 	//Dashboard com o resumo de informa��es do usuario
    WSSYNTAX "/tae/dashboard" ;
    PATH     "/tae/dashboard" ;
    PRODUCES "application/json;charset=utf-8" 

	WSMETHOD POST DocsTae ;
    DESCRIPTION STR0004; 	//Retorna Lista de documentos TAE por Status
    WSSYNTAX "/tae/documents" ;
    PATH     "/tae/documents" ;
    PRODUCES "application/json;charset=utf-8"

	WSMETHOD POST SendCode ;
    DESCRIPTION STR0006; 	//"Solicitar o c�digo de acesso por e-mail ao TAE"
    WSSYNTAX "/tae/sendcode" ;
    PATH     "/tae/sendcode" ;
    PRODUCES "application/json;charset=utf-8"

	WSMETHOD POST CodeValidate ;
    DESCRIPTION STR0008; 	//"Valida o c�digo de acesso e retorna o token"
    WSSYNTAX "/tae/verificationcode" ;
    PATH     "/tae/verificationcode" ;
    PRODUCES "application/json;charset=utf-8"

	WSMETHOD POST DocInfoTae ;
    DESCRIPTION STR0012 ; 	//"Retorna detalhes de um documento do TAE"
    WSSYNTAX "/tae/documentinfo" ;
    PATH     "/tae/documentinfo" ;
    PRODUCES "application/json;charset=utf-8"

	WSMETHOD POST DocSignTae ;
    DESCRIPTION STR0013 ; 	//"Realiza a assinatura de um documento do TAE"
    WSSYNTAX "/tae/sign" ;
    PATH     "/tae/sign" ;
    PRODUCES "application/json;charset=utf-8"  

END WSRESTFUL

//Gera o token de acesso ao Tae
WSMETHOD POST TokenTae WSREST Tae

    Local oTokenTae		:= Nil
	Local aQryParam     := Self:aQueryString
	Local cRestFault	:= ""
	Local cJson         := ""
	Local aRet			:= {}
	Local lHomeTae      := .F.
	Local nPos          := 0

	//Verifica via queryParam se a chamada veio da home ou do dashboard.
	nPos := aScan( aQryParam, { |x| Upper(x[1]) == "ISHOME" } )
	If(nPos > 0)
		lHomeTae := If(aQryParam[nPos,2] == "true", .T., .F.)
	EndIf

    aRet := GetTaeToken(@cRestFault)

	If Empty(cRestFault)
		oTokenTae			:= JsonObject():New()
		oTokenTae["token"]	:= aRet[1]
		oTokenTae["email"]	:= aRet[2]

		cJson := oTokenTae:ToJson()

		FreeObj(oTokenTae)
	EndIf

	//Caso a chamada venha da home o erro sai via conout e retorna vazio
	//Se vem do dashboard, devolve erro 400.
	If !Empty(cRestFault)
		If (lHomeTae, Conout(EncodeUTF8("TAE >>>> " + cRestFault)), cJson := SetError(cRestFault))
	EndIf 

	Self:SetResponse(cJson)

Return(.T.)

//Obtem o dashboard de documentos do Tae
WSMETHOD POST DashTae WSREST Tae

    Local oData			:= JsonObject():New()
	Local aQryParam     := Self:aQueryString
	Local cToken  		:= ""
	Local cTaeToken		:= ""
	Local cKeyId  		:= ""
	Local cRestFault	:= ""
	Local lHomeTae      := .F.
	Local nPos          := 0

	//Verifica via queryParam se a chamada veio da home ou do dashboard.
	nPos := aScan( aQryParam, { |x| Upper(x[1]) == "ISHOME" } )
	If(nPos > 0)
		lHomeTae := If(aQryParam[nPos,2] == "true", .T., .F.)
	EndIf

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  	:= Self:GetHeader('Authorization')
	cTaeToken	:= Self:GetHeader('TokenTae')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	
	If !Empty(cTaeToken)
		If Len(aDataLogin) > 0
			DbSelectArea("SRA")
			SRA->(DbSetOrder(1))
			If SRA->( DbSeek( aDataLogin[5] + aDataLogin[1] ) ) 
				cEmail := AllTrim(SRA->RA_EMAIL)
			EndIf
			//Caso a chamada venha da home o erro sai via conout e retorna vazio
			//Se vem do dashboard, devolve erro 400.
			If Empty(cEmail)
				If (lHomeTae, Conout(EncodeUTF8("TAE >>>> " + STR0011)), cRestFault := EncodeUTF8(STR0011)) //"Usu�rio sem e-mail cadastrado!"
			EndIf
		EndIf

		If !Empty(cEmail)
			GetDashTae(@oData, cEmail, cTaeToken)
		EndIf

		cJson := If(Empty(cRestFault), "", SetError(cRestFault) )
	EndIf

	If Empty(cRestFault) 
		cJson := oData:ToJson()
		FreeObj(oData)
	EndIf
	
	Self:SetResponse(cJson)

Return(.T.)

//Obtem a rela��o de documentos do Tae
WSMETHOD POST DocsTae WSREST Tae

    Local oData			:= JsonObject():New()
	Local cToken  		:= ""
	Local cTaeToken		:= ""
	Local cKeyId  		:= ""
	Local cRestFault	:= ""
	Local cBody 		:= Self:GetContent()
	Local aQryParam		:= Self:aQueryString

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  	:= Self:GetHeader('Authorization')
	cTaeToken	:= Self:GetHeader('TokenTae')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)

	If Len(aDataLogin) > 0
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		If SRA->( DbSeek( aDataLogin[5] + aDataLogin[1] ) ) 
			cEmail := AllTrim(SRA->RA_EMAIL)
		EndIf
	EndIf

	If !Empty(cEmail) .And. !Empty(cTaeToken)
    	GetDocsTae(@oData, cEmail, cTaeToken, cBody, aQryParam, @cRestFault)
	EndIf

	If Empty(cRestFault)
		cJson := oData:ToJson()
		Self:SetResponse(cJson)

		FreeObj(oData)
	EndIf

Return(.T.)

//Envia por e-mail o codigo de assinatura do documento do Tae
WSMETHOD POST SendCode WSREST Tae

	Local oData			:= JsonObject():New()
	Local cJson			:= ""
	Local aQryParam		:= Self:aQueryString
	Local cBody 		:= Self:GetContent()	
	Local cTaeToken		:= Self:GetHeader('TokenTae')

	If !Empty(cTaeToken)
		SendTaeCode(@oData, cBody, aQryParam)
	EndIf

	cJson := oData:ToJson()
	Self:SetResponse(cJson)	

	FreeObj(oData)

Return(.T.)

//Valida o codigo recebido por e-mail para permitir a assinatura do documento do Tae
WSMETHOD POST CodeValidate WSREST Tae

	Local oData			:= JsonObject():New()
	Local cJson			:= ""
	Local cRestFault	:= ""
	Local aQryParam		:= Self:aQueryString
	Local cBody 		:= Self:GetContent()	
	Local cTaeToken		:= Self:GetHeader('TokenTae')

	If !Empty(cTaeToken)
		CheckCodeTae(@oData, cBody, aQryParam, @cRestFault)
	EndIf

	If Empty(cRestFault)
		cJson := oData:ToJson()
	EndIf
	
	cJson := If( !Empty(cRestFault), SetError(cRestFault), cJson )

	Self:SetResponse(cJson)	

	FreeObj(oData)

Return(.T.)

//"Retorna detalhes de um documento do TAE"
WSMETHOD POST DocInfoTae WSREST Tae

    Local oData			:= JsonObject():New()
	Local oBody         := JsonObject():New()
	Local cTaeToken		:= ""
	Local cBody 		:= Self:GetContent()
	Local nDocumentId   := 0
	Local cRestFault    := ""

	//Busca os dados do body para fazer a requisi��o para o TAE
	If !Empty(cBody)
		oBody:FromJson(cBody)
		cTaeToken    := oBody["token"]
		nDocumentId  := oBody["documentId"]
		cEmail       := oBody["email"]
		If !Empty(cEmail)
			GetDocInfoTae(@oData, cEmail, cTaeToken, nDocumentId, @cRestFault)
		EndIf
		FreeObj(oBody)
	EndIf

	cRestFault := If(Empty(cEmail), EncodeUTF8(STR0011), cRestFault )	//Email n�o cadastrado.

	cJson      := oData:ToJson()
	cJson      := If(Empty(cRestFault), cJson, SetError(cRestFault))

	FreeObj(oData)
	
	Self:SetResponse(cJson)

Return(.T.)

//"Realiza a assinatura de um documento do TAE"
WSMETHOD POST DocSignTae WSREST Tae

    Local oData			:= JsonObject():New()
	Local oBody         := JsonObject():New()
	Local cToken  		:= ""
	Local cTaeToken		:= ""
	Local cKeyId  		:= ""
	Local cDocument     := ""
	Local cDocumentType := ""
	Local cEmail        := ""
	Local cSignType     := ""
	Local cRestFault    := ""
	Local cBody 		:= Self:GetContent()
	Local nDocumentId   := 0
	
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  	:= Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken, , cKeyId)

	//Busca o email do usu�rio.
	If Len(aDataLogin) > 0
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		If SRA->( DbSeek( aDataLogin[5] + aDataLogin[1] ) ) 
			cEmail := AllTrim(SRA->RA_EMAIL)
		EndIf
	EndIf

	//S� faz a requisi��o ao TAE se o email est� cadastrado.
	If !Empty(cEmail)
		oBody:FromJson(cBody)
		cTaeToken     := oBody["token"]
		nDocumentId   := oBody["documentId"]
		cDocument     := oBody["document"]
		cDocumentType := oBody["documentType"]
		cSignType     := oBody["signType"]

		SignDocTae(@oData, @cRestFault, cTaeToken, nDocumentId, cEmail, cDocument, cSignType, cDocumentType)
		FreeObj(oBody)
	EndIf

	cRestFault := If(Empty(cEmail), EncodeUTF8(STR0011), cRestFault )	//Email n�o cadastrado.

	cJson      := oData:ToJson()
	cJson      := If(Empty(cRestFault),  cJson, SetError(cRestFault))

	FreeObj(oData)
	
	Self:SetResponse(cJson)

Return(.T.)
