#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FDEBA1
Tela com campos para o preenchimento do Folder Outros BA1
@authorTotver
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FDEBA1(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FDEBA1' )
	iif(!lAutomato, oBrowse:Activate(), '')

Return (NIL)



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FDEBA1 Demais
@author Totver
@version P12
@since   05/08/2019
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260FDEBA1 
@author Totver
@version P12
@since   05/08/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1 := FWFormStruct( 1, 'BA1'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Demais') })
	
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FDEBA1')	
    
	oModel:addFields('MasterBA1' , ,oStruBA1) 								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'MasterBA1' ):SetDescription( 'Demais Dados' )
	oModel:SetPrimaryKey({})
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplica��o 
@author Totver
@version P2
@since   05/08/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  
Local oStruBA1 := FWFormStruct( 2, 'BA1'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Demais') })
Local oModel   := FWLoadModel( 'PLSA260FDEBA1' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA1' ,  oStruBA1,  'MasterBA1' )

    oStruBA1:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA1','Demais Dados')
	
Return oView

