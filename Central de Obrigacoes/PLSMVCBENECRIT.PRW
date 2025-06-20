#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'TOTVS.ch'

Function PLSMVCBENCRIT()
    Alert("Fun��o descontinuada")
Return NIL
// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} MenuDef

// Defininao das opcoes do menu

// @author everton.mateus
// @since 26/01/2016
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function MenuDef()
// 	Local aRotina := {}

// Return aRotina
// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} ModelDef

// Definicao do modelo MVC para o conjunto B3K e B3F

// @return oModel	objeto model criado

// @author everton.mateus
// @since 26/01/2016
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function ModelDef()
// 	// Cria as estruturas a serem usadas no Modelo de Dados
// 	Local oStruB3K 		:= FWFormStruct( 1, 'B3K' )
// 	Local oStruB3F 		:= FWFormStruct( 1, 'B3F' )
// 	Local oModel // Modelo de dados constru�do

// 	// Cria o objeto do Modelo de Dados
// 	//oModel := MPFormModel():New( 'PLSMVCCOMPROM',,,{ |oModel| PLGrvComp( oModel ) } )
// 	oModel := MPFormModel():New( 'PLSMVCBENECRIT' )

// 	// Adiciona ao modelo um componente de formul�rio
// 	oModel:AddFields( 'B3KMASTER', /*cOwner*/ , oStruB3K )
// 	// Adiciona ao modelo componente de grid
// 	oModel:AddGrid( 'B3FDETAIL', 'B3KMASTER', oStruB3F )

// 	// Faz relacionamento entre os componentes do model
// 	oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
// 		{ 'B3F_ORICRI' , '"B3K"' },;
// 		{ 'B3F_CODOPE' , 'B3K_CODOPE' },;
// 		{ 'B3F_IDEORI' , 'B3K_MATRIC' },;
// 		{ 'B3F_IDEORI' , 'B3K_CODCCO' };
// 		}, B3F->( IndexKey( 1 ) ) )
// 	// oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
// 	// 											{ 'B3F_ORICRI' , '"B3K"' },;
// 	// 											{ 'B3F_CHVORI' , 'B3K->(Recno())' };
// 	// 					}, B3F->( IndexKey( 1 ) ) )

// 	// Adiciona a descri��o do Modelo de Dados
// 	oModel:SetDescription( 'Cr�ticas' )

// 	// Adiciona a descri��o dos Componentes do Modelo de Dados
// 	oModel:GetModel( 'B3KMASTER' ):SetDescription( "Compromissos" )
// 	oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Cr�ticas" )

// 	// Retorna o Modelo de dados
// Return oModel
// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} ViewDef

// Definicao da visao MVC para o conjunto B3K e B3F

// @return oView	objeto view criado

// @author everton.mateus
// @since 26/01/2016
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function ViewDef()
// 	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
// 	Local oModel := FWLoadModel( 'PLSMVCBENECRIT' )
// 	// Cria as estruturas a serem usadas na View
// 	Local oStruB3K 			:= FWFormStruct( 2, 'B3K' )
// 	Local oStruB3F 			:= FWFormStruct( 2, 'B3F' )
// 	// Interface de visualiza��o constru�da
// 	Local oView

// 	oView := FWFormView():New()

// 	// Define qual Modelo de dados ser� utilizado
// 	oView:SetModel( oModel )

// 	// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
// 	oView:AddField( 'VIEW_B3K', oStruB3K, 'B3KMASTER' )

// 	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
// 	oView:AddGrid( 'VIEW_B3F', oStruB3F, 'B3FDETAIL' )

// 	oStruB3F:RemoveField('B3F_CODOPE')
// 	oStruB3F:RemoveField('B3F_CDOBRI')
// 	oStruB3F:RemoveField('B3F_ANO')
// 	oStruB3F:RemoveField('B3F_CDCOMP')

// 	// Cria um "box" horizontal para receber cada elemento da view
// 	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
// 	oView:CreateHorizontalBox( 'INFERIOR', 60 )

// 	// Relaciona o identificador (ID) da View com o "box" para exibi��o
// 	oView:SetOwnerView( 'VIEW_B3K', 'SUPERIOR' )
// 	oView:SetOwnerView( 'VIEW_B3F', 'INFERIOR' )

// 	//Insiro descri��es nas views
// 	oView:EnableTitleView( 'VIEW_B3K', "Benefici�rio" )
// 	oView:EnableTitleView( 'VIEW_B3F', "Cr�ticas no Processamento" )

// 	oView:AddUserButton( 'Visualiza Cadastro', '', {|oView| PLCOExiCad(.F.)} )
// 	oView:AddUserButton( 'Comparar ANS x Central', '', {|oView| PLCOComCad()} )
// 	oView:AddUserButton( 'Enviar Alt. ANS', '', {|oView| PLSALTANS(oModel)} )

// 	// Retorna o objeto de View criado
// Return oView
