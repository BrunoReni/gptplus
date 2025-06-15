#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldResp from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldResp
    _Super:New()
Return self

Method validate(oEntity) Class CenVldResp
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "C�digo da operadora n�o informado (providerRegister)"
    EndIf
    If Empty( oEntity:getValue( "cpfCnpj" ) ) 
        lOk := .F.
        self:cMsg := "CPF/CNPJ n�o informado (cpfCnpj)"
    EndIf
Return lOk
