#Include "FISA204.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA204
  
Rotina de Visualiza��o da Apura��o do Ressarcimento ou Complemento do ICMS Retido por Substitui��o Tribut�ria.
Para o Estado de Minas Gerais, o m�todo de apura��o � determinado pelo decreto 47.547/2018.

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA204()
    Local oBrowse

    If AliasIndic("F3X")
		DbSelectArea ("F3X")
		DbSelectArea ("F3Y")

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F3X")
        oBrowse:SetDescription(STR0001) //STR0001 //"Apura��o do Ressarcimento do ICMS Retido por ST"
        oBrowse:Activate()
    Else
        MsgStop(STR0002) //STR0002 //"Dicion�rio de dados desatualizado. Favor aplicar as atualiza��es necess�rias."
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Fun��o para cria��o de menu [MVC].

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA204' OPERATION 2 ACCESS 0 //STR0003 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004    ACTION 'FISA203EXC'      OPERATION 5 ACCESS 0 //STR0004 //"Excluir"
    ADD OPTION aRotina TITLE STR0005   ACTION 'FISA203'         OPERATION 3 ACCESS 0 //STR0005 //STR0005 //"Apura��o"

Return ( aRotina )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o para cria��o do modelo [MVC].

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStructF3X := FWFormStruct(1,"F3X")

    oModel := MPFormModel():New("FISA204",,)
    oModel:AddFields("F3XMASTER",,oStructF3X)
    oModel:GetModel("F3XMASTER"):SetOnlyView ( .T. )
    oModel:SetDescription(STR0001) //STR0001 //"Apura��o do Ressarcimento do ICMS Retido por ST"
    oModel:GetModel("F3XMASTER"):SetDescription(STR0006) //STR0006 //"Ressarcimento ICMS-ST - Apura��o"
Return oModel


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o para cria��o da view [MVC].

@author Eduardo Vicente da Silva
@since 22/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("FISA204")
Local oStructF3X := FWFormStruct(2,"F3X")
Local oView

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F3X",oStructF3X,"F3XMASTER")

//Ajuste do T�tulo do campo F2W_FATGER.
oStructF3X:SetProperty("F3X_VLRCOM", MVC_VIEW_TITULO, STR0008) //"Valor de Complemento"
oStructF3X:SetProperty("F3X_VLRRES", MVC_VIEW_TITULO, STR0009) //"Valor de Restitui��o"

oView:CreateHorizontalBox("HEADER",20)
oView:CreateHorizontalBox("DETAIL",80)
oView:EnableTitleView('VIEW_F3X',STR0007) //STR0007 //"Totais da Apura��o"
oView:SetOwnerView("VIEW_F3X","HEADER")

Return oView
