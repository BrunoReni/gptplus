#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldMuni from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldMuni
    _Super:New()
Return self

Method validate(oEntity) Class CenVldMuni
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "C�digo da operadora n�o informado"
    EndIf
Return lOk
