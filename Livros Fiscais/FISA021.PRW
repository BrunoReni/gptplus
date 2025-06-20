#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA021.ch" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA021()

Rotina para cadastro da Tabela F2P - C�digos de Ajuste - Cr�dito Acumulado

@author Ulisses P. Oliveira
@since 20/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA021()
Local oBrowse

IF AliasIndic("F2P")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2P")
    oBrowse:SetDescription(STR0001) // C�digos de Ajuste - Cr�dito Acumulado
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicion�rio de dados desatualizado.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Fun��o para cria��o de menu [MVC].

@author Ulisses P. Oliveira
@since 20/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA021")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o para cria��o do modelo [MVC].

@author Ulisses P. Oliveira
@since 20/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStructF2P := FWFormStruct(1,"F2P")

oModel := MPFormModel():New("FISA021",,{|oModel|ModelValid(oModel)})
oModel:AddFields("F2PMASTER",,oStructF2P)
oModel:SetDescription(STR0001) // C�digos de Ajuste - Cr�dito Acumulado
oModel:GetModel("F2PMASTER"):SetDescription(STR0001) // C�digos de Ajuste - Cr�dito Acumulado

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o para cria��o da view [MVC].

@author Ulisses P. Oliveira
@since 20/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("FISA021")
Local oStructF2P := FWFormStruct(2,"F2P")
Local oView

oStructF2P:AddGroup('GRUPO_UF_TIPO', STR0006,'',2) //UF x Tipo da Opera��o
oStructF2P:AddGroup('GRUPO_CODIGOS', STR0007,'',2) //C�digo de Ajuste Apura��o x C�digo Controle Cr�dito
oStructF2P:SetProperty('F2P_UF'    ,MVC_VIEW_GROUP_NUMBER,'GRUPO_UF_TIPO')
oStructF2P:SetProperty('F2P_CREDAC',MVC_VIEW_GROUP_NUMBER,'GRUPO_UF_TIPO')
oStructF2P:SetProperty('F2P_CODAJU',MVC_VIEW_GROUP_NUMBER,'GRUPO_CODIGOS')
oStructF2P:SetProperty('F2P_CODCRE',MVC_VIEW_GROUP_NUMBER,'GRUPO_CODIGOS')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_F2P",oStructF2P,"F2PMASTER")
oView:CreateHorizontalBox("TELA",100)
oView:SetOwnerView("VIEW_F2P","TELA") 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelValid
Fun��o para valida��o do modelo [MVC].

@author Ulisses P. Oliveira
@since 20/07/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelValid(oModel)

Local nOperation := oModel:GetOperation()
Local cCodAjApur := oModel:GetValue('F2PMASTER',"F2P_CODAJU")
Local cCodAjCred := oModel:GetValue('F2PMASTER',"F2P_CODCRE")
Local cUfF2P     := oModel:GetValue('F2PMASTER',"F2P_UF")
Local cUfCDOApur := Posicione("CDO",1,xFilial("CDO")+cCodAjApur,"CDO_UF")
Local cUfCDOCred := Posicione("CDO",1,xFilial("CDO")+cCodAjCred,"CDO_UF")
Local lRetorno   := .T.

//VAlida��es para opera��es de inclus�o e altera��o.
If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
    
    //N�o permite cadastro com c�digos de ajuste de apura��o e ajuste de cr�dito (extra-apura��o) iguais
    If cCodAjApur == cCodAjCred
        lRetorno := .F.
        Help(,,'Help',,STR0003,1,0) // C�digos de ajuste de apura��o e ajuste de cr�dito (extra-apura��o) n�o podem ser iguais.
    ElseIf cUfCDOApur != cUfF2P
        lRetorno := .F.
        Help(,,'Help',,STR0004,1,0) // C�digo de ajuste de apura��o deve pertencer � UF selecionada.
    ElseIf cUfCDOCred != cUfF2P
        lRetorno := .F.
        Help(,,'Help',,STR0005,1,0) // C�digo de ajuste de cr�dito (extra-apura��o) deve pertencer � UF selecionada.
    ElseIf SubStr(cCodAjApur,3,2)!="00" .And. SubStr(cCodAjApur,3,2)!="01"
        lRetorno := .F.
        Help(,,'Help',,STR0008,1,0) // � necess�ria a utiliza��o de um c�digo de ajuste dedutor de saldo credor.
    EndIf

EndIf

Return lRetorno