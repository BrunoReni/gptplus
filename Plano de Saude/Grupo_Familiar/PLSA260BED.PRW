#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BED
Browse do Historico Cobran�a Carteirinha - Familia
@author DEV TOTVS
@since 09/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BED(lAutomato)
// Declara��o de Vari�veis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260BED' )
iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu de Historico Cobran�a Carteirinha - Familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
// Declara��o de Vari�veis
Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados do Historico Cobran�a Carteirinha - Familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
// Declara��o de Vari�veis
Local oModel	
Local oStruBA3 		:= FWFormStruct(1,'BA3')
Local oStruBED 		:= FWFormStruct(1,'BED')	

// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260BED')

// Adiciona as estruturas no modelo
oModel:addFields('BA3MASTER' ,NIL,oStruBA3) 
oModel:AddGrid('BEDDETAIL','BA3MASTER',oStruBED)

// Permiss�o de grid sem dados
oModel:GetModel('BEDDETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'BEDDETAIL', { { 'BED_FILIAL' , 'xFilial( "BED" )'},;
								{ 'BED_CODINT'	, 'BA3_CODINT'       },;
								{ 'BED_CODEMP'	, 'BA3_CODEMP'       },;
								{ 'BED_MATRIC'	, 'BA3_MATRIC'       } },;									
								BED->( IndexKey( ) ) ) 						
	
oModel:SetDescription( FunDesc() )	// Descri��o do Modelo de dados

// Descri��o de cada modelo usado
oModel:GetModel('BA3MASTER'):SetDescription('Familia' )
oModel:GetModel('BEDDETAIL'):SetDescription('Hist�rico Cobran�a Carteirinha' )	

// N�o permite altera��o ou inclus�o no modelo
oModel:GetModel('BA3MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('BA3MASTER'):SetOnlyView(.T.)
oModel:GetModel('BEDDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('BEDDETAIL'):SetOnlyView(.T.)

oModel:SetPrimaryKey({})

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View do hist�rico da familia
@author  DEV TOTVS
@since   09/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
// Declara��o de Vari�veis
Local oStruBA3 := FWFormStruct(2,'BA3', { |cCampo| AllTrim(cCampo) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC|' } )
Local oStruBED:= FWFormStruct(2,'BED')	
Local oModel   := FWLoadModel( 'PLSA260BED') // Carrega o modelo
Local oView

oView := FWFormView():New() // Cria o Objeto View

oView:SetModel( oModel )

oStruBED:RemoveField('BED_CODINT')
oStruBED:RemoveField('BED_CODEMP')
oStruBED:RemoveField('BED_MATRIC')

oView:AddField( 'VIEW_BA3' , oStruBA3, 'BA3MASTER' )
oView:AddGrid(  'VIEW_BED' , oStruBED, 'BEDDETAIL' )

oStruBA3:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 20) 
oView:CreateHorizontalBox( 'MEIO'	 , 80) 

oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')
oView:SetOwnerView('VIEW_BED', 'MEIO')	
	
oView:EnableTitleView('VIEW_BA3','Familia')
oView:EnableTitleView('VIEW_BED','Hist�rico Cobran�a Carteirinha')

Return oView