#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'TOTVS.ch'

Function PLSMVCCONOBRI()
    Alert("Fun��o descontinuada")
Return NIL
// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} ModelDef

// Definicao do modelo MVC para a tabela B3U

// @return oModel	objeto model criado

// @author everton.mateus
// @since 26/01/2016
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function ModelDef()
// // Cria as estruturas a serem usadas no Modelo de Dados
// Local oStruB3U 		:= FWFormStruct( 1, 'B3U' )
// Local oModel // Modelo de dados constru�do

// // Cria o objeto do Modelo de Dados
// oModel := MPFormModel():New( 'PLSMVCOBRIGAC' )

// // Adiciona ao modelo um componente de formul�rio
// oModel:AddGrid( 'B3UDETAIL', /*cOwner*/, oStruB3U )

// // Adiciona a descri��o do Modelo de Dados
// oModel:SetDescription( 'Contatos x Obriga��es' )

// // Adiciona a descri��o dos Componentes do Modelo de Dados
// oModel:GetModel( 'B3UDETAIL' ):SetDescription( "Contatos" )

// //Seta Chaves primarias
// oModel:SetPrimaryKey({})

// // Retorna o Modelo de dados
// Return oModel
// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} ViewDef

// Definicao da visao MVC para a tabela B3U

// @return oView	objeto view criado

// @author everton.mateus
// @since 26/01/2016
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function ViewDef()
// // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
// Local oModel := FWLoadModel( 'PLSMVCCONOBRI' )

// // Cria as estruturas a serem usadas na View
// Local oStruB3U 			:= FWFormStruct( 2, 'B3U' )

// // Interface de visualiza��o constru�da
// Local oView

// oView := FWFormView():New()

// // Define qual Modelo de dados ser� utilizado
// oView:SetModel( oModel )

// // Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
// oView:AddGrid( 'VIEW_B3U', oStruB3U, 'B3UDETAIL' )

// // Cria um "box" horizontal para receber cada elemento da view
// oView:CreateHorizontalBox( 'BOX_CONTATOS', 100 )

// // Relaciona o identificador (ID) da View com o "box" para exibi��o
// oView:SetOwnerView( 'VIEW_B3U', 'BOX_CONTATOS' )

// // Retorna o objeto de View criado
// Return oView