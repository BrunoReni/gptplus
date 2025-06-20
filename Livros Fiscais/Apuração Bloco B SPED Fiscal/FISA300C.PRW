#Include "FISA300C.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300C()

Esta rotina tem objetivo de realizar os cadastros das dedu��es de ISS
constantes no blocoo B da EFD ICMS/IPI.

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300C()

Local oBrowse := Nil

//Verifico se a tabela de dedu��o existe antes de prosseguir
IF AliasIndic('F1Q')
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F1Q")
    oBrowse:SetDescription(STR0001) //"Cadastro de dedu��es de ISS"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, favor verificar atualiza��es da apura��o de ISS referente ao Bloco B da EFD ICMS/IPI."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}	

IF x300BMODO() == 'EDT' //Edi��o
    //NA edi��o habilitar� os demais bot�es
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA300C' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.FISA300C' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.FISA300C' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.FISA300C' OPERATION 5 ACCESS 0 //"Excluir"

Else
    //Habilitar� somente o bot�o de visualiza��o
    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA300C' OPERATION 2 ACCESS 0 //"Visualizar"
EndIF
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Cria��o do modelo para as dedu��es de ISS

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura da tabela F1Q
Local oDeducao := FWFormStruct(1, "F1Q" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA300C')

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA300C",,oDeducao)

//Inicializador Padr�o dos campos de Tipo de ajustes e do ID da apura��o
oDeducao:SetProperty('F1Q_INDOBR' , MODEL_FIELD_INIT,{|| x300BTPDED() })
oDeducao:SetProperty('F1Q_IDAPUR' , MODEL_FIELD_INIT,{|| x300BIDAPU() })

//N�o permite altera��o do indicador de obriga��o
oDeducao:SetProperty('F1Q_INDOBR' , MODEL_FIELD_WHEN, {|| .F. })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA300C" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oDeducao := FWFormStruct(2, "F1Q")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Retiro os IDs da view
oDeducao:RemoveField('F1Q_ID')
oDeducao:RemoveField('F1Q_IDAPUR')

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_ABA' , oDeducao , 'FISA300C' )

Return oView
 