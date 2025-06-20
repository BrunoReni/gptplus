#Include "FISA174AJU.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA174AJU()

Rotina respons�vel por criar mo modelo dos ajustes manuais da apura��o

@author Erick G Dias
@since 21/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA174AJU()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2M")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2M")
    oBrowse:SetDescription(STR0001)  //"Ajustes Manuais da Apura��o"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}	

IF x174OPER() == "1" //Visualizar
    //Habilitar� somente o bot�o de visualiza��o
    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA174AJU' OPERATION 2 ACCESS 0 //STR0003 //'Visualizar'
ElseIF x174OPER() == '2' //Edi��o
    //NA edi��o habilitar� os demais bot�es
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA174AJU' OPERATION 2 ACCESS 0 //STR0003 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA174AJU' OPERATION 3 ACCESS 0 //STR0004 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA174AJU' OPERATION 4 ACCESS 0 //STR0005 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA174AJU' OPERATION 5 ACCESS 0 //STR0006 //'Excluir'
EndIF
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro das regras de apura��o

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "F2M" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA174AJU')

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA174AJU",,oCabecalho)

oModel:SetPrimaryKey( {"F2M_FILIAL","F2M_ID"} )

//Inicializador Padr�o dos campos de Tipo de ajustes e do ID da apura��o
oCabecalho:SetProperty('F2M_TPAJUS' , MODEL_FIELD_INIT,{|| x174TPAJU() })
oCabecalho:SetProperty('F2M_IDRAPU' , MODEL_FIELD_INIT,{|| x174IDRAPU() })

//N�o permite altera��o do tipo de ajuste
oCabecalho:SetProperty('F2M_TPAJUS' , MODEL_FIELD_WHEN, {|| .F. })

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) //"Ajustes Manuais da Apura��o"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias    
@since 21/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA174AJU" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2M")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA174AJU' )

// Retirando campo de ID da view.
oCabecalho:RemoveField( 'F2M_ID'  )
oCabecalho:RemoveField( 'F2M_IDRAPU'  )

Return oView

