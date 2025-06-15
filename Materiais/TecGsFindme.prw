#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} GsFindMe

@description Classe utilizada para integração Totvs Prestadores de Serviço Tercerização X FindMe

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
class GsFindMe

    data cBaseUrl AS CHARACTER
    data cToken AS CHARACTER
    data cUser AS CHARACTER
    data cPsw AS CHARACTER
    data lAuth AS LOGICAL
    data aTokenData AS ARRAY
    data cIntegrations AS CHARACTER
    data aClients AS ARRAY
    
    method new()
    method setBaseUrl()
    method getAuthToken()
    method setUser()
    method setPsw()
    method setlAuth()
    method setToken()
    method getBaseUrl()
    method getToken()
    method getIntegrations()
    method addClient()
    method canAddClient()
    method setIntegrations()

endclass

method new() class GsFindMe

    Local cBaseUrl      := GetMV("MV_GSXFM01",.F.,"") // Url da api de integração
    Local cUser         := GetMV("MV_GSXFM02", .F., "" ) // Usuário utilizado na plataforma findme
    Local cPsw          := GetMV("MV_GSXFM03", .F., "" )  // Senha utilizada na plataforma findme
    Local cIntegration := GetMV("MV_GSXFM04",.F.,"")

    ::cIntegrations := ""

    If Empty(cBaseUrl)
        ::setBaseUrl("https://sandbox.api.findme.id/v3")
    Else
        ::setBaseUrl(cBaseUrl)
    EndIf

    ::setUser(cUser)
    ::setPsw(cPsw)

    If !Empty(cUser) .AND. !Empty(cPsw) 
        If ::getAuthToken()
            ::setlAuth(.T.)

            If Empty(cIntegration)
                if ::getIntegrations()
                    PutMv("MV_GSXFM04",::cIntegrations)
                EndIf
            Else
                ::setIntegrations(cIntegration)
            EndIf

        Else
            ::setlAuth(.F.)
        EndIf
    Else
        //Setar mensagem de erro
    EndIf 

return

//------------------------------------------------------------------------------
/*/{Protheus.doc} getAuthToken

@description Realiza a autenticação para comunicação com a API da FindMe

@return lRet, bool, se conseguiu realizar a autenticação

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getAuthToken() class GsFindMe
    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local oObj := Nil
    Local lRet := .T.

    If EMPTY(::aTokenData)
        ::aTokenData := {}
        lRet := .F.
        AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
        AAdd(aHeader, "charset: UTF-8")

        oRest:SetPath("/settings/login")
        oRest:SetPostParams('email=' + ::cUser + '&password=' + ::cPsw)

        If oRest:Post(aHeader)
            If (lRet := FWJsonDeserialize(oRest:GetResult(),@oObj))
                ::setToken(oObj:token)
                    If lRet .AND.  FindFunction("TECTelMets")
	                    TECTelMets("autenticar_findme", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
                    EndIf
                AADD(::aTokenData, oObj:token)
                AADD(::aTokenData, TIME())
            EndIf
        EndIf

    EndIf
return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} setBaseUrl

@description Define a url base da api de integração

@param cSetValue, String, url da integração

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setBaseUrl(cSetValue) class GsFindMe

return (::cBaseUrl := cSetValue)

//------------------------------------------------------------------------------
/*/{Protheus.doc} getBaseUrl

@description Retorna a Url base da api de integração

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getBaseUrl() class GsFindMe

return (::cBaseUrl)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setUser

@description Define o nome do usuário

@param cSetValue, String, nome do usuário

@author	Diego Bezerra
@since  29/11/2022
/*/
//------------------------------------------------------------------------------
method setUser(cSetUser) class GsFindMe

return (::cUser := cSetUser)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setPsw

@description Define a senha do usuário findme

@param cSetPsw, String, senha do usuário findme

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setPsw(cSetPsw) class GsFindMe

return (::cPsw := cSetPsw)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setlAuth

@description Define variável de controle para saber se o usuário está autenticado

@param lAuth, lógico, .T. == Autenticado, .F. == Não Autenticado

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setlAuth(lAuth) class GsFindMe

return (::lAuth := lAuth)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setlAuth

@description Define token de autenticação

@param cSetToken, string, token de autenticação

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setToken(cSetToken) class GsFindMe

return (::cToken := cSetToken)

//------------------------------------------------------------------------------
/*/{Protheus.doc} getToken

@description Retorna token de autenticação

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getToken() class GsFindMe

return (::cToken)


//------------------------------------------------------------------------------
/*/{Protheus.doc} getIntegrations

@description verifica se um cliente já foi cadastrado na base de dados da FindMe
Retorna variável lógica

lCanAdd == .T. == Liberado para inclusão (cliente ainda não cadastrado na base FindMe)
lCanAdd == .F. == Não liberado para inclusão (cliente já cadastrado na base FindMe)

@param codigo, string, codigo do cliente

@author	Diego Bezerra
@since	02/12/2022
/*/
//------------------------------------------------------------------------------
method getIntegrations() class GsFindMe
    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local oObj := Nil
    Local lRet := .T.
    Local cPath := "/integrations"
    If !EMPTY(::aTokenData)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::aTokenData[1])

        oRest:SetPath(cPath)

        If oRest:Get(aHeader)
            If FWJsonDeserialize(oRest:GetResult(),@oObj)
                ::setIntegrations(oObj[1]:uuid)
            EndIf
        EndIf
    EndIf
return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} canAddClient

@description verifica se um cliente já foi cadastrado na base de dados da FindMe
Retorna variável lógica

lCanAdd == .T. == Liberado para inclusão (cliente ainda não cadastrado na base FindMe)
lCanAdd == .F. == Não liberado para inclusão (cliente já cadastrado na base FindMe)

@param codigo, string, codigo do cliente

@author	Diego Bezerra
@since	02/12/2022
/*/
//------------------------------------------------------------------------------
method canAddClient(codigo,filial,loja) class GsFindMe // chamar via postman
    Local aHeader := {}
    Local oRest := FWRest():New(::cBaseUrl)
    Local lRet := .T.
    Local cBodyReq := ""
    Local cPath := "/integrations"
    // Local nX := 0
    Local lCanAdd := .F.

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/clients/find?codigo="+codigo+"&filial="+filial+"&loja="+loja
    EndIf

    If lRet .AND. !EMPTY(::getToken())
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::getToken())

        oRest:SetPath(cPath)
        oRest:SetPostParams(EncodeUTF8(cBodyReq))

        If !oRest:Get(aHeader)
            // Alerta retornando 404 !!!
            lCanADd := .T.
        EndIf

    EndIf

return lCanAdd


method addClient(aFlds) class GsFindMe

    Local aHeader := {}
    Local oRest := FWRest():New(::getBaseUrl())
    Local lRet := .T.
    Local cBodyReq := ""
    Local cPath := "/integrations"

    if !Empty(::cIntegrations)
        cPath += "/" + ::cIntegrations + "/clients"
    EndIf

    if lRet .AND. LEN(aFlds) > 0
        cBodyReq += '{"integration":{'
            cBodyReq += '"codigo":"'+aFlds[1][2]+'",'
            cBodyReq += '"filial":"'+aFlds[2][2]+'",'
            cBodyReq += '"loja":"'+aFlds[3][2]+'"'
        cBodyReq += "},"
        cBodyReq += '"customData":{'
            cBodyReq += '"descricao":"'+Alltrim(aFlds[4][2])+'"'
        cBodyReq += "},"
        cBodyReq += '"name":"'+Alltrim(aFlds[5][2])+'"}'
    EndIF

    If lRet .AND. !EMPTY(::cToken)
        Aadd(aHeader, "Content-Type: application/json")
        AAdd(aHeader, "charset: UTF-8")
        AAdd(aHeader, "Authorization: Bearer " + ::cToken)

        oRest:SetPath(cPath)
        oRest:SetPostParams(EncodeUTF8(cBodyReq))
        lRet := oRest:Post(aHeader)
        If lRet .AND.  FindFunction("TECTelMets")
	        TECTelMets("incluir_cliente_findme", "gestao-de-servicos-protheus_integracao-find-me-gs_total")
        EndIf
    EndIf

return lRet

METHOD setIntegrations(cSetValue) class GsFindMe

Return (::cIntegrations:=cSetValue)
