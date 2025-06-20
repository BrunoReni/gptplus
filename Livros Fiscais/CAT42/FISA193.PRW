#Include "FISA193.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA193
  
Rotina de Visualiza��o da Apura��o do Ressarcimento ou Complemento do ICMS Retido por Substitui��o Tribut�ria ou Antecipado.
Para o Estado de S�o Paulo, o m�todo de apura��o � determinado pela portaria CAT 42/2018.

@author ulisses.oliveira
@since 16/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA193()
    Local oBrowse

    If AliasIndic("F2X")
		DbSelectArea ("F2X")
		DbSelectArea ("F2T")
		DbSelectArea ("F2U")
		DbSelectArea ("F2V")
		DbSelectArea ("F2W")

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("F2X")
        oBrowse:SetDescription(STR0001) //"Apura��o do Ressarcimento do ICMS Retido por ST ou Antecipado"
        oBrowse:Activate()
    Else
        MsgStop(STR0002) //"Dicion�rio de dados desatualizado. Favor aplicar as atualiza��es necess�rias."
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Fun��o para cria��o de menu [MVC].

@author Ulisses P. Oliveira
@since 06/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA193' OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION 'FISA192EXC'      OPERATION 5 ACCESS 0 //"Excluir"

Return ( aRotina )


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o para cria��o do modelo [MVC].

@author Ulisses P. Oliveira
@since 06/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStructF2X := FWFormStruct(1,"F2X")
    Local oStructF2T := FWFormStruct(1,"F2T")

    oModel := MPFormModel():New("FISA193",,)
    oModel:AddFields("F2XMASTER",,oStructF2X)
    oModel:AddGrid("F2TDETAIL","F2XMASTER",oStructF2T)
    oModel:SetRelation("F2TDETAIL",{{'F2T_FILIAL','xFilial("F2T")'},{'F2T_IDAPUR','F2X_IDAPUR'}},F2T->(IndexKey(1)))
    oModel:GetModel("F2XMASTER"):SetOnlyView ( .T. )
    oModel:GetModel("F2TDETAIL"):SetOnlyView ( .T. )
    oModel:SetDescription(STR0001)                       //"Apura��o do Ressarcimento do ICMS Retido por ST ou Antecipado"
    oModel:GetModel("F2XMASTER"):SetDescription(STR0005) //"Ressarcimento ICMS-ST - Apura��o"
    oModel:GetModel("F2XMASTER"):SetDescription(STR0006) //"Ressarcimento ICMS-ST - Apura��o por Enquadramento Legal"
Return oModel


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o para cria��o da view [MVC].

@author Ulisses P. Oliveira
@since 06/11/2018
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("FISA193")
Local oStructF2X := FWFormStruct(2,"F2X")
Local oStructF2T := FWFormStruct(2,"F2T")
Local oView

oStructF2X:RemoveField("F2X_IDAPUR")
oStructF2T:RemoveField("F2T_IDAPUR")
oStructF2T:RemoveField("F2T_ANOMES")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F2X",oStructF2X,"F2XMASTER")
oView:AddGrid("VIEW_F2T",oStructF2T,"F2TDETAIL")
oView:CreateHorizontalBox("HEADER",20)
oView:CreateHorizontalBox("DETAIL",80)
oView:EnableTitleView('VIEW_F2X',STR0007) //"Totais da Apura��o"
oView:EnableTitleView('VIEW_F2T',STR0008) //"Totais da Apura��o por Enquadramento Legal"
oView:SetOwnerView("VIEW_F2X","HEADER")
oView:SetOwnerView("VIEW_F2T","DETAIL") 

Return oView