#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldAcio from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldAcio
    _Super:New()
Return self

Method validate(oEntity) Class CenVldAcio
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "C�digo da operadora n�o informado"
	ElseIf lOk 
        lOk := self:podeImpDiops(oEntity) 
    EndIf
Return lOk
