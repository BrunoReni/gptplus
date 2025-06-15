#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TECSERVCAROL.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} ServCarol
@author	Diego Bezerra
@since	10/04/2023
@description Classe utilizada para integrações entre o módulo Prestadores de Serviço Terceirização (GS) e
a plataforma Carol. 

    Como usar: 
    1) Instanciar a classe e passar o endereço da api da plataforma Carol:
    -- 
    -- Local cApiPath := 'pathdaapicarol'
    -- Local oServCarol := ServCarol():new(cApiPath)
    --
    2) Definir o conector:
    --
    -- oServCarol:defConector('codigodoconector')
    --
    3) Definir a organização:
    -- 
    -- oServCarol:defOrg('codigodaorganizacao')
    -- 
    4) Definir o dominio:
    -- 
    -- oServCarol:defDomin('codigododominio')
    --
    5) Definir usuário e senha de acesso:
    -- 
    -- oServCarol:defUser('username')
    -- oServCarol:defPw('password')
    -- 
    6) Definir endpoint de autenticação. cPathAuth não é obrigatório. Caso não seja informado, será considerado : /api/v3/oauth2/token
    -- 
    -- oServCarol:defEndpoint('cPathAuth')
    --
    7) Gerar apiKey: cPathAuthKey não é obrigatório. Caso não seja informado, será considerado: /api/v1/apiKey/issue
    -- 
    -- oServCarol:defAuthKey('cPathAuthKey')
    -- 
    8) Enviar dados para uma staging table (após autenticação). Apenas os parâmetros cTable e cBodyReq são obrigatórios. 
    --
    -- oServCarol:addStagingValue(cTable,cBodyReq,aParams,cConector,cEndPoint,cAuth,aCustomHeaders)
    --
**********************************************************************************/
Class ServCarol

    /* 
        Endereço de Acesso ao EndPoint.
        pode ser definido pelo parâmetro MV_APICLO1 no protheus
    */
    data cBaseUrl       AS CHARACTER

    /*
        Patch de acesso ao EndPoint 
        pode ser definido pelo parâmetro MV_APICLO2 no protheus
    */
    data cPathW         AS CHARACTER
    
    /*
        Id do conector Carol
        pode ser definido pelo parâmetro MV_APICLO3 no protheus
    */
    data cConec        AS CHARACTER

    data cEndPoint     AS CHARACTER

    /*
        Username de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO4 no protheus
    */
    data cUsern         AS CHARACTER

    /*
        Password de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO5 no protheus
    */
    data cPassW         AS CHARACTER

    /*
        Domain name de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO6 no protheus
    */
    data cDomin         AS CHARACTER

    /*
        Path do EndPoint DeviceList
        pode ser definido pelo parâmetro MV_APICLO7 no protheus
    */
    data cPathD         AS CHARACTER

    /*
        Path do EndPoint clockinrecordsList
        pode ser definido pelo parâmetro MV_APICLO8 no protheus
    */
    data cPathM         AS CHARACTER

    /*
        Nome da organização de acesso ao EndPoint
        pode ser definido pelo parâmetro MV_APICLO9 no protheus
    */
    data cOrg          AS CHARACTER

    data lApiExist     AS BOOLEAN
    
    /*
        Código do apiToken (conector token)
        pode ser obtido pelo parâmetro MV_APICLOA no protheus
    */
    data cApiToken      AS CHARACTER

    /*
        Tamanho da pagina de retorno da API
    */
    data cPageSize      AS CHARACTER

    data cToken         AS CHARACTER
    data cAuthKey       AS CHARACTER
    data lOrgExist      AS LOGICAL
    data lHasError      AS LOGICAL
    data cLasMsgErr     AS CHARACTER // "{method:}"
    data aError         AS ARRAY
    data lError         AS LOGICAL
    
    method new()
    method genClientRest()
    method auth()

    method getBaseUrl()
    method getEndpoint()
    method getAuthToken()
    method getAuthKey()
    method getUser()
    method getPw()
    method getConector()
    method getOrg()
    method getDomin()
    method getError()
    method getLError()

    method defAuthToken()
    method defBaseUrl()
    method defEndpoint()
    method defConector()
    method defUser()
    method defPw()
    method defOrg()
    method defDomin()
    method defAuthKey()
    method defError()
    method defLError()
    /* Método para gravar valores em staging tables na plataforma carol */
    method addStagingValue()
    method sendUserInvite()
endClass

method new(cBaseUrl) class ServCarol
    ::cBaseUrl   := cBaseUrl
    ::cEndPoint  := ""
    ::cPathW     := ""
    ::cConec     := ""
    ::cUsern     := ""
    ::cPassW     := ""
    ::cDomin     := ""
    ::cPathD     := ""
    ::cPathM     := ""
    ::cApiToken  := ""
    ::cPageSize  := 100
    ::cToken     := ""
    ::cAuthKey   := ""
    ::cOrg       := ""
    ::lApiExist  := .F.
    ::lOrgExist  := .F.
    ::aError     := {}
    ::lError     := .F.
return

/**************************************************
                    DEF VALUES
***************************************************/
method defBaseUrl(cSetValue) class ServCarol
    If VALTYPE(cSetValue) == 'C'
        ::cBaseUrl := cSetValue 
    EndIf
return ::cBaseUrl

method defEndpoint(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cEndpoint := cSetValue
    EndIf
return ::cEndpoint

method defConector(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cConec := cSetValue
    EndIf
return ::cConec

method defUser(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cUsern := cSetValue
    EndIf
return ::cUsern

method defPw(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cPassW := cSetValue
    EndIf
return ::cPassW

method defOrg(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cOrg := cSetValue
    EndIf
return ::cOrg

method defDomin(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cDomin := cSetValue
    EndIf
return ::cDomin

method defAuthToken(cSetValue) class ServCarol
    IF VALTYPE(cSetValue) == 'C'
        ::cToken := cSetValue
    EndIf
return ::cToken

/* Tentativa de gerar apikey para autenticação.*/
method defAuthKey(cEndPoint) class ServCarol
    Local aHeader	:= {}
    Local cParams	:= ""
    Local cRet		:= ""
    Local oClient	:= ::genClientRest()
    Local oObj		:= Nil
    Local oRet		:= JsonObject():New()

    Default cEndPoint   := "/api/v1/apiKey/issue"
    
    If !Empty(::getAuthToken())
        cParams := "connectorId=" + ::getConector() + "&
        cParams += "description=%7B%22en-US%22%3A%22API%20Token%20Protheus%22%7D"
        
        aAdd( aHeader, "Accept: application/json" )
        aAdd( aHeader, "Authorization:" + ::getAuthToken() )
        aAdd( aHeader, "Content-type: application/x-www-form-urlencoded" )
        aAdd( aHeader, "Origin:" + ::getBaseUrl() )
        aAdd( aHeader, "Referer:" + ::getBaseUrl() + "/" + ::getOrg() + "/carol-ui/environment/connector-tokens" )

        oClient:SetPath(cEndPoint)
        oClient:SetPostParams(cParams)
        oClient:Post(aHeader)
        cRet := oClient:GetResult()
        If FWJsonDeserialize(cRet, @oObj)
            If oObj <> Nil
                If oRet:fromJson(cRet) == Nil .And. oRet["errorCode"] == Nil
                    ::cAuthKey := oRet["X-Auth-Key"]
				EndIf 
            EndIf
        EndIf
    EndIf
return ::cAuthKey

method defError(cMethod,cMsg) class ServCarol
    IF VALTYPE(cMethod) == 'C' .AND. VALTYPE(cMsg) == 'C'
        AADD(::aError,{cMethod, cMsg})
    EndIf
return ::cToken

method defLError(lError) class ServCarol
    If VALTYPE(lError) == 'L'
        ::lError := lError
    EndIf
Return ::lError

/**************************************************
                    GET VALUES
***************************************************/

method getEndpoint() class ServCarol
return ::cEndpoint

method getConector() class ServCarol
return ::cConec

method getBaseUrl() class ServCarol
return ::cBaseUrl

method getUser() class ServCarol
return ::cUsern

method getPw() class ServCarol
return ::cPassW

method getOrg() class ServCarol
return ::cOrg

method getDomin() class ServCarol
return ::cDomin

method getAuthToken() class ServCarol
return ::cToken

method getAuthKey() class ServCarol
return ::cAuthKey

method genClientRest() class ServCarol
    Local oClient := FwRest():New(::getBaseUrl())
    oClient:SetPath(::getEndpoint())
Return oClient

method getLError() class ServCarol
Return ::lError

method getError() class ServCarol
return ::aError

/* Autenticação */
method auth(cPath,cAuthType,cParamKey,lGeraToken,cTknApiEnd) class ServCarol
    Local aHeader   := {}
    Local cParams   := ""
    Local cResponse := ""
    Local cMsgErr   := ""
    Local oRest     := Nil
    Local oResp     := Nil
    Local oRet      := JsonObject():New()

    Default cPath := "/api/v3/oauth2/token"
    Default cAuthType := 'user' //user - chaveAuth
    Default cParamKey := "MV_APICLOA"
    Default cTknApiEnd := "/api/v1/apiKey/issue"
    Default lGeraToken := .F.

    ::defEndPoint(cPath)

    oRest := ::genClientRest()
    
    If cAuthType == 'user'
        AAdd( aHeader, "Accept: application/json" )
	    AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
        
        cParams := "grant_type=password&"
        cParams += "connectorId=" + ::getConector() + "&"
        cParams += "username=" + ::getUser() + "&"
        cParams += "password=" + ::getPw() + "&"
        cParams += "subdomain=" + AllTrim(::getOrg()) + "&"
        cParams += "orgSubdomain=" + ::getDomin()
        oRest:SetPostParams(cParams)

        If oRest:Post(aHeader)
            If FWJsonDeserialize(oRest:GetResult(),@oResp)
                If oResp <> NIL
                    cResponse := oRest:GetResult()
                    If oRet:fromJson(cResponse) == Nil .AND. oRet["access_token"] <> Nil
                        ::defAuthToken(oRet:GetJsonText( "access_token" ))
                        If lGeraToken
                            ::defAuthKey(cTknApiEnd,cParamKey)
                        EndIf
                    EndIf
                EndIf
            EndIf
        Else
            If VAL(oRest:oResponseh:cStatusCode) >= 299
                ::defLError(.T.)
                cMsgErr += STR0001 + CRLF //'Problema na autenticação. '
                cMsgErr += 'Reponse code: ' + oRest:oResponseh:cStatusCode + CRLF
                ::defError('Auth',cMsgErr)  
            EndIf
        EndIf
    EndIf
return

/* Inclusão de valores em staging table, na plataforma Carol*/
method addStagingValue(cTable,cBodyReq,aParams,cConector,cEndPoint,cAuth,aCustomHeader) class ServCarol
    Local aHeader	:= {}
    Local oClient	:= ::genClientRest()
    Local nI        := 1
    Local cUrlPar   := ""
    Local cResult   := ""

    Default aParams         := {}
    Default cEndPoint       := "/api/v3/staging/intake/"
    Default cBodyReq        := ""
    Default cConector       := ::getConector()
    Default aCustomHeader   := {}

    // cTable é a stagin table dentro da plataforma carol 
    // cEndpoint + cTable forma o endpoint de cada stagin table
    cEndPoint += cTable
    For nI := 1 to Len(aParams)
        If nI == 1
            cUrlPar += '?'
        EndIf
        cUrlPar += aParams[nI][1] + "=" + aParams[nI][2] 
        If nI < Len(aParams)
            cUrlPar += '&'
        EndIf
    Next nI
    
    aAdd( aHeader, "Accept: application/json" )
    aAdd( aHeader, "Content-type: application/json" )
    aAdd( aHeader, "Authorization: Bearer " + ::getAuthToken() )

    // Headers adicionais
    For nI := 1 to Len(aCustomHeader)
        aAdd(aHeader,aCustomHeader[nI])
    Next nI

    oClient:SetPath(cEndPoint+cUrlPar)
    oClient:setPostParams(EncodeUTF8(cBodyReq))
    oClient:Post(aHeader)
    cResult := oClient:GetResult()
return cResult


/* Inclusão de valores em staging table, na plataforma Carol*/
method sendUserInvite(cInviteType,cEmail,cUrl,cRoleName,cEndPoint) class ServCarol
    Local aHeader	:= {}
    Local oClient	:= ::genClientRest()
    Local cResult   := ""
    Local cParams   := ""

    Default cEndPoint       := "/api/v3/users/invites"
    
    cParams += "inviteType=" + cInviteType + "&"
    cParams += "email=" + cEmail + "&"
    cParams += "url=" + cUrl + "&"
    cParams += "roleNames=" + cRoleName

    oClient:SetPostParamns(cParams)

    aAdd( aHeader, "Accept: application/json" )
    AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
    aAdd( aHeader, "Authorization: Bearer " + ::getAuthToken() )

    oClient:SetPath(cEndPoint)
    oClient:Post(aHeader)
    cResult := oClient:GetResult()
return cResult
