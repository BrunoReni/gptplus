#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PCPA650
Fonte chamador da tela de Ordem de Produção em Po UI
@author marcelo.neumann
@since 18/10/2021
@version P12
/*/
Function PCPA650()

	If PCPVldApp()
		FwCallApp("ordem-producao")
	EndIf

Return
