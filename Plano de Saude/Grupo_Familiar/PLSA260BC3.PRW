#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BC3
Browse do Historico Bloqueio da Familia
@author DEV TOTVS
@since  13/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BC3(lAutomato)
// Declara��o de Vari�veis
Local oBrowse
Default lAutomato :=  .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260BC3' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu de Historico Bloqueio da Familia
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
// Declara��o de Vari�veis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados do Historico Bloqueio da Familia
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
// Declara��o de Vari�veis
Local oModel	
Local oStruBA3 		:= FWFormStruct(1,'BA3')
Local oStruBC3 		:= FWFormStruct(1,'BC3')	
local aCmpRelac		:= { { 'BC3_FILIAL' , 'xFilial( "BC3" )'}, { 'BC3_MATRIC' , 'BA3_CODINT + BA3_CODEMP + BA3_MATRIC' } }

// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260BC3')

// Adiciona as estruturas no modelo
oModel:addFields('BA3MASTER' ,NIL,oStruBA3) 
oModel:AddGrid('BC3DETAIL','BA3MASTER',oStruBC3)

// Permiss�o de grid sem dados
oModel:GetModel('BC3DETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'BC3DETAIL', aCmpRelac,	BC3->( IndexKey( ) ) )
	
oModel:SetDescription( FunDesc() )	// Descri��o do Modelo de dados

// Descri��o de cada modelo usado
oModel:GetModel('BA3MASTER'):SetDescription('Familia' )
oModel:GetModel('BC3DETAIL'):SetDescription('Hist�rico Bloqueio da Fam�lia' )	

// N�o permite altera��o ou inclus�o no modelo
oModel:GetModel('BA3MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('BA3MASTER'):SetOnlyView(.T.)
oModel:GetModel('BC3DETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('BC3DETAIL'):SetOnlyView(.T.)

oModel:SetPrimaryKey({})

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View do hist�rico de Bloqueio da Familia
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
// Declara��o de Vari�veis
Local oStruBA3 := FWFormStruct(2,'BA3', { |cCampo| AllTrim(cCampo) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC' } )
Local oStruBC3 := FWFormStruct(2,'BC3')	
Local oModel   := FWLoadModel( 'PLSA260BC3') // Carrega o modelo
Local oView

oView := FWFormView():New() // Cria o Objeto View

oView:SetModel( oModel )

oStruBC3:RemoveField('BC3_MATRIC')
oStruBC3:RemoveField('BC3_NOMUSR')

oView:AddField( 'VIEW_BA3' , oStruBA3, 'BA3MASTER' )
oView:AddGrid(  'VIEW_BC3' , oStruBC3, 'BC3DETAIL' )

oStruBA3:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 20) 
oView:CreateHorizontalBox( 'MEIO'	 , 80) 

oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
oView:SetOwnerView('VIEW_BC3', 'MEIO')	
	
oView:EnableTitleView('VIEW_BA3','Familia')
oView:EnableTitleView('VIEW_BC3','Hist�rico Bloqueio da Fam�lia')

Return oView
