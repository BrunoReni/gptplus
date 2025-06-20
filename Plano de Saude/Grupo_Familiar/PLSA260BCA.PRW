#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BC3
Browse do Historico Bloqueio do usu�rio
@author DEV TOTVS
@since  13/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BCA(lAutomaco)
// Declara��o de Vari�veis
Local oBrowse
Default lAutomaco := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260BCA' )

If(!lAutomaco,oBrowse:Activate(),)

Return NIL            

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do menu de Historico Bloqueio do usu�rio
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
Definicao do modelo de dados do Historico Bloqueio do usuario
@author  DEV TOTVS
@since   13/12/2019
@version P12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()	
    // Declara��o de Vari�veis
	Local oModel	
	Local oStruBA1 := FWFormStruct( 1, 'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_TIPREG|BA1_NOMUSR|BA1_DIGITO|' } )
	Local oStruBCA := FWFormStruct( 1, 'BCA' )
    Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
    Local nNx
	
	// Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BCA')

    // Cria os campos na estrutura que est�o como n�o usados no dicionario
    For nNx := 1 To Len(aCamposBA1)
        oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
    Next
		
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields( 'BA1MASTER',NIL, oStruBA1 )
	oModel:SetPrimaryKey({})

	//Faz relaciomaneto entre os compomentes do model
	oModel:AddGrid( 'BCADETAIL', 'BA1MASTER', oStruBCA) 
	oModel:GetModel( 'BCADETAIL' ):SetMaxLine(999999999)

    // Relacionamento entre as tabelas
    oModel:SetRelation( 'BCADETAIL', { { 'BCA_FILIAL' , 'xFilial( "BCA" )'},;
								       { 'BCA_MATRIC' , 'BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC)' },;
                                       { 'BCA_TIPREG' , 'BA1->BA1_TIPREG' }},;									
									   BCA->( IndexKey( ) ) ) 								
	
	//Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( FunDesc() )	

	//Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'BA1MASTER' ):SetDescription( 'Beneficiario' )	
	oModel:GetModel( 'BCADETAIL' ):SetDescription( 'Hist�rico de Bloqueio' )	

	oModel:GetModel( 'BA1MASTER' ):SetOnlyQuery(.T.)
	oModel:GetModel( 'BA1MASTER' ):SetOnlyView(.T.)	

	/*Valido a altera��o do campo no Grid*/
	oStruBCA:setProperty( 'BCA_DATA', MODEL_FIELD_VALID, { || VldMovBlo(oModel)} )	// Fun��o no fonte PLSA259
	oStruBCA:setProperty( 'BCA_MOTBLO', MODEL_FIELD_VALID, { || VldMovBlo(oModel)} )		
	
Return oModel

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
    Local oStruBA1 := FWFormStruct( 2, 'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_TIPREG|BA1_DIGITO|BA1_NOMUSR' } )
    Local oStruBCA := FWFormStruct( 2, 'BCA', { |cCampo| AllTrim(cCampo) $ 'BCA_TIPREG|BCA_TIPO|BCA_DATA|BCA_MOTBLO|BCA_DESBLO|BCA_OBS|BCA_USUOPE|BCA_BLOFAT|BCA_DATPED|BCA_DATLAN|BCA_HORLAN|BCA_SOL412' } )
    Local oModel   := FWLoadModel( 'PLSA260BCA' )
    Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx	

	oView := FWFormView():New()

    // Cria os campos na estrutura que est�o como n�o usados no dicionario
    For nNx := 1 To Len(aCampos)
        oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
    Next

	oView:SetModel( oModel )

    oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

	oView:AddField( 'VIEW_BA1', oStruBA1, 'BA1MASTER' )
	oView:AddGrid(  'VIEW_BCA', oStruBCA, 'BCADETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )
	
    oView:EnableTitleView('VIEW_BA1','Benefici�rio')
	oView:EnableTitleView('VIEW_BCA','Hist�rico de Bloqueio')
	
	oView:SetOwnerView( 'VIEW_BA1', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BCA', 'INFERIOR' )
	
	/*N�o permito adicionar linhas no Grid*/
	oModel:GetModel( 'BCADETAIL' ):SetNoInsertLine( .T. )
	
	/*N�o permito altera��o nos campos*/
	oStruBCA:SetProperty( 'BCA_TIPREG',MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( 'BCA_TIPO',  MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( 'BCA_DESBLO',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_USUOPE',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_BLOFAT',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_DATPED',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_DATLAN',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_HORLAN',MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( 'BCA_SOL412',MVC_VIEW_CANCHANGE,.F.)

Return oView