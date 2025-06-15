#INCLUDE "PROTHEUS.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} GsFindMe

@description Classe utilizada para integra��o Totvs Prestadores de Servi�o Terceriza��o X FindMe

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

    Local cBaseUrl      := GetMV("MV_GSXFM01",.F.,"") // Url da api de integra��o
    Local cUser         := GetMV("MV_GSXFM02", .F., "" ) // Usu�rio utilizado na plataforma findme
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

@description Realiza a autentica��o para comunica��o com a API da FindMe

@return lRet, bool, se conseguiu realizar a autentica��o

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

@description Define a url base da api de integra��o

@param cSetValue, String, url da integra��o

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setBaseUrl(cSetValue) class GsFindMe

return (::cBaseUrl := cSetValue)

//------------------------------------------------------------------------------
/*/{Protheus.doc} getBaseUrl

@description Retorna a Url base da api de integra��o

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getBaseUrl() class GsFindMe

return (::cBaseUrl)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setUser

@description Define o nome do usu�rio

@param cSetValue, String, nome do usu�rio

@author	Diego Bezerra
@since  29/11/2022
/*/
//------------------------------------------------------------------------------
method setUser(cSetUser) class GsFindMe

return (::cUser := cSetUser)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setPsw

@description Define a senha do usu�rio findme

@param cSetPsw, String, senha do usu�rio findme

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setPsw(cSetPsw) class GsFindMe

return (::cPsw := cSetPsw)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setlAuth

@description Define vari�vel de controle para saber se o usu�rio est� autenticado

@param lAuth, l�gico, .T. == Autenticado, .F. == N�o Autenticado

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setlAuth(lAuth) class GsFindMe

return (::lAuth := lAuth)

//------------------------------------------------------------------------------
/*/{Protheus.doc} setlAuth

@description Define token de autentica��o

@param cSetToken, string, token de autentica��o

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method setToken(cSetToken) class GsFindMe

return (::cToken := cSetToken)

//------------------------------------------------------------------------------
/*/{Protheus.doc} getToken

@description Retorna token de autentica��o

@author	Diego Bezerra
@since	29/11/2022
/*/
//------------------------------------------------------------------------------
method getToken() class GsFindMe

return (::cToken)


//------------------------------------------------------------------------------
/*/{Protheus.doc} getIntegrations

@description verifica se um cliente j� foi cadastrado na base de dados da FindMe
Retorna vari�vel l�gica

lCanAdd == .T. == Liberado para inclus�o (cliente ainda n�o cadastrado na base FindMe)
lCanAdd == .F. == N�o liberado para inclus�o (cliente j� cadastrado na base FindMe)

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

@description verifica se um cliente j� foi cadastrado na base de dados da FindMe
Retorna vari�vel l�gica

lCanAdd == .T. == Liberado para inclus�o (cliente ainda n�o cadastrado na base FindMe)
lCanAdd == .F. == N�o liberado para inclus�o (cliente j� cadastrado na base FindMe)

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
