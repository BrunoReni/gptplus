#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldOper from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldOper
    _Super:New()
Return self

Method validate(oEntity) Class CenVldOper
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "C�digo da operadora n�o informado"
	ElseIf Empty( oEntity:getValue( "operatorCnpj" ) ) 
        lOk := .F.
        self:cMsg := "CNPJ n�o informado (operatorCnpj)"
    EndIf
Return lOk
