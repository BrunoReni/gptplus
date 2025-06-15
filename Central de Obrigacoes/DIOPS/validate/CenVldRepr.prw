#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldRepr from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldRepr
    _Super:New()
Return self

Method validate(oEntity) Class CenVldRepr
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "C�digo da operadora n�o informado (providerRegister)"
    EndIf
    If Empty( oEntity:getValue( "registrationOfIndividua" ) ) 
        lOk := .F.
        self:cMsg := "CPF n�o informado (registrationOfIndividua)"
    EndIf
Return lOk
