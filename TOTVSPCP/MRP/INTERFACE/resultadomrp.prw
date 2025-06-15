#INCLUDE "TOTVS.CH"
#INCLUDE "RESULTADOMRP.CH"

/*/{Protheus.doc} resultadomrp
Chamada da tela de resultados do MRP (PO-UI)

@type  Function
@author lucas.franca
@since 26/11/2021
@version P12
@return Nil
/*/
Function resultadomrp()
	If PCPVldApp()
		FwCallApp("resultado-mrp")
	EndIf
Return Nil
