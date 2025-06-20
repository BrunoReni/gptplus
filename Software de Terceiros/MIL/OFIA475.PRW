#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA470.CH"

/*/{Protheus.doc} OFIA475
	Saida de Servi�os Especializados - MVC somente para atualizar o cabe�alho VRR

	@author Andre Luis Almeida
	@since 01/11/2022
/*/
Function OFIA475()
Return

Static Function ModelDef()
Local oStrVRR := FWFormStruct(1,"VRR")
oModel := MPFormModel():New("OFIA475", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VRRMASTER",/*cOwner*/ , oStrVRR)
oModel:GetModel("VRRMASTER"):SetDescription(STR0001) // Saida de Servi�os Especializados
oModel:SetDescription(STR0001) // Saida de Servi�os Especializados
Return oModel

/*/{Protheus.doc} ViewDef
Defini��o do interface

@author Andre Luis Almeida
@since 01/11/2022
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVRR:= FWFormStruct(2,"VRR", { |cCampo| !ALLTRIM(cCampo) $ "VRR_CODIGO/" } )
oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:AddField( 'VIEW_VRR', oStrVRR, 'VRRMASTER' )
oView:CreateHorizontalBox('CABEC' , 100)
oView:SetOwnerView('VIEW_VRR', 'CABEC' )
Return oView