#Include "FISA198.ch"
#include "protheus.ch"
#include "FWMBROWSE.CH"
#include "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA198()

Cadastro de Regra, gera uma carga inicial com as regras x descri��o dos codigos de ajuste 
do RS. O cliente precisa apenas relacinar o codigo da regra com o codigo de ajuste 
correspondente.

@author Bruce.Mello 
@since 24/01/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA198()

Local   oBrowse := Nil

Private lAutomato := Iif(IsBlind(),.T.,.F.)

//Verifico se as tabelas existem antes de prosseguir
If AliasIndic("F3T")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F3T")
    oBrowse:SetDescription("") // Cadastro de Regras - Ressarcimento ICMS-ST
    oBrowse:SetFilterDefault("F3T_FILIAL == " + ValToSql(xFilial("F3T")))
	If !lAutomato
    	oBrowse:Activate()
	EndIF
Else
	If !lAutomato
    	Help("",1,"Help","Help",STR0001,1,0)  //"Dicion�rio desatualizado, verifique as atualiza��es Decreto 54.308"
	EndIF
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar menu

@author Bruce.Mello 
@since 24/01/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
//Return FWMVCMenu("FISA198")

Local aRotina	:= {}

ADD OPTION aRotina Title "Visualizar"    Action 'VIEWDEF.FISA198' OPERATION 2 ACCESS 0 // 'Visualizar'
ADD OPTION aRotina Title "Alterar"       Action 'VIEWDEF.FISA198' OPERATION 4 ACCESS 0 // 'Alterar'


Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo o cadastro de regra na tabela F3T

@author bruce.Mello
@since 2
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local cIdTab := FWUUID("F3T")

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura correspondete a tabela de Regra F3T
Local oCabecalho := FWFormStruct(1, "F3T" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA198') 

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA198",,oCabecalho)


//Inicializa o campo F3T_CODIGO com o Cod. Ajuste
oCabecalho:SetProperty('F3T_REGRA' , MODEL_FIELD_INIT ,{||cIdTab} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0002) //"Cadastro de Regras"

//Bloqueia o campo F3T_REGRA para altera��o.
oCabecalho:SetProperty('F3T_REGRA' , MODEL_FIELD_WHEN ,{||.F.} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author 
@since 27/11/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA198" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho    := FWFormStruct(2, "F3T")
Local oView         := Nil
Local cVersao       := GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO', oCabecalho    , 'FISA198')


//Ajuste do T�tulo do campo F3T_DESCRI.
oCabecalho:SetProperty("F3T_DESCRI", MVC_VIEW_TITULO, STR0003)  //"Descri��o da Regra"

//Ajuste do T�tulo do campo F3T_REGRA.
oCabecalho:SetProperty("F3T_REGRA", MVC_VIEW_TITULO, STR0004)  //"Regra de C�lculo"

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO', 'SUPERIOR' )

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_CABECALHO', STR0005 ) //"CADASTRO DE REGRA"

If cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F196Carga
Funcao respons�vel por realizar a carga inicial dos registros.

@author Bruce.Mello
@since 24/01/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function F198Carga()

Local aRegra     	:= {{'01',STR0009},{'02',STR0008},{'03',STR0007},{'04','Varejista - Debito'},{'05',STR0006},{'06',STR0010},{'07',STR0011}} //'N�o Varejista - Estorno do cr�dito anteriormente a partir de invent�rio.' //'Varejista - Estorno do cr�dito pelo invent�rio' //'Varejista - Apropria��o de cr�dito relativo �s entradas de mercadoria recebidas' //'Varejista - Apropria��o do cr�dito relativo �s mercadorias em estoque' //'N�o Varejista - Debito.' //'N�o Varejista - Apropria��o do cr�dito de mercadoria recebidas com ST.'
Local nX            := 0

	DbSelectArea("F3T")
	DbGoTop()
	For Nx:= 1 to len(aRegra)
		iF !F3T->(DBSEEK(XFILIAL("F3T")+aRegra[NX][1],.F.))
			RECLOCK("F3T",.T.)
			F3T->F3T_FILIAL   := xFilial("F3T")
			F3T->F3T_REGRA    := aRegra[NX][1]
			F3T->F3T_DESCRI	  := aRegra[NX][2]
			MsUnLock()
		Endif
	Next Nx

return()
