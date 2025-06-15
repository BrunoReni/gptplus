#include "protheus.ch"

/*/{Protheus.doc} PLPOPosBen
Tela da posi��o do benefici�rio (PO UI)

@type function
@author Robson Nayland
@since 16/12/2022
@version Protheus 12
/*/
Function PLPOPosBen()
    
    If ReqMinimos()
        FWCallApp("PLPOPosBen")
    Else 
        FWAlertWarning(DecodeUtf8("Ambiente desatualizado, verifique os requisitos m�nimos na documenta��o da Posi��o do Benefici�rio (PO UI)"), DecodeUtf8("Posi��o do Benefici�rio"))
    EndIf
    
Return

/*/{Protheus.doc} ReqMinimos
Requisitos minimos para acessar Tela da posi��o do benefici�rio (PO UI)

@type function
@author Robson Nayland
@since 16/12/2022
@version Protheus 12
/*/
Static Function ReqMinimos()

    Local lValid := .F.

    lValid := FindFunction("AmIOnRestEnv") .And. AmIOnRestEnv()

Return lValid

/*/{Protheus.doc} JsToAdvpl
Configura��o do preLoad do sistema para enviar para o frontEnd (PO Ui)

@type function
@author Robson Nayland
@since 16/12/2022
@version Protheus 12
/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)

Return