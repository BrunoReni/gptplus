#INCLUDE "OGA380.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA380
Rotina para cadastro de Modelos de Contrato

@param: 	Nil
@author: 	Fabiane Schulze
@since: 	10/10/2013
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA380()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NJX" )
oMBrowse:SetDescription( STR0001 ) //"Modelo de Contrato"
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA380 - Esp�cies
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "ViewDef.OGA380", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004   , "ViewDef.OGA380", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005   , "ViewDef.OGA380", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006   , "ViewDef.OGA380", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007  , "OGA385"		, 0, 4, 0, Nil } ) //"Associar"
aAdd( aRotina, { STR0008  , "ViewDef.OGA380", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0009    , "ViewDef.OGA380", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA380 - Esp�cies
*/
Static Function ModelDef()
Local oStruNJX := FWFormStruct( 1, "NJX" )
Local oModel   := MPFormModel():New( "OGA380" , ,{| oModel | PosModelo( oModel ) }  )

oModel:AddFields( "NJXUNICO", Nil, oStruNJX )

oStruNJX:SetProperty( "NJX_CODPRO" , MODEL_FIELD_VALID, {| oField | UMCODPRO( oField ) } )

oModel:SetDescription( STR0010 ) //"Modelos de Contrato"
oModel:GetModel( "NJXUNICO" ):SetDescription( STR0011 ) //"Dados do Modelo de Contrato"


Return( oModel )


/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA380 - Modelo de Contratos
*/
Static Function ViewDef()
Local oStruNJX 	:= FWFormStruct( 2, "NJX" )
Local oModel   	:= FWLoadModel( "OGA380" )
Local oView    	:= FWFormView():New()


oView:SetModel( oModel )
oView:AddField( "VIEW_NJX", oStruNJX, "NJXUNICO" )

oView:CreateHorizontalBox( "SUPERIOR" , 100 )

oView:SetOwnerView( "VIEW_NJX", "SUPERIOR"   )

oView:EnableTitleView( "VIEW_NJX" )

oView:SetCloseOnOk( {||.t.} )

Return( oView )


/** {Protheus.doc} PosModelo
Fun��o ap�s valida��o do modelo para complementar a grava��o

@param: 	oModel - Modelo de dados
@return:	Nil
@author: 	Fernando Pereira Leite
@since: 	13/11/2013
@Uso: 		OGA380 - Modelo de Contratos
*/
Static Function PosModelo( oModel )
Local aAreaAtu	:= GetArea()
Local nOperation 	:= oModel:GetOperation()
Local cCodigo   	:= oModel:GetValue( "NJXUNICO","NJX_CODMOD" )

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	MsgInfo(STR0016) //"Para utiliza��o dos modelos de contratos, favor realizar a associa��o com a entidade no Menu. << A��es Relacionadas >>  <<Associar >>"
EndIf	

If nOperation == MODEL_OPERATION_DELETE
	dbSelectArea( "NJY" )
	dbSetOrder( 1 )
	If dbSeek( FWxFilial( "NJY" ) + cCodigo )
		If RecLock( "NJY", .f. )
			NJY->( dbDelete() )
			NJY->( MsUnLock() )
		EndIf
	EndIf
EndIf

RestArea( aAreaAtu )

Return( .t. )


/** {Protheus.doc} UMCodPro
Fun��o Buscar a Unidade de Medida do Preco
@param:	Produto
Retorno:	.T. ou .F. 
@author:	Gilson Venturi
@since:	29/04/2015
@Uso:		SIGAAGR - Origina��o de Gr�os
*/
Static Function UMCodPro( oField )
	Local oModel		:= oField:GetModel()
	Local oModelNJX	:= oModel:GetModel( "NJXUNICO" )
	Local cProduto 	:= oField:GetValue( "NJX_CODPRO" )
	Local cUmPreco	:= AgrUmPrc ( cProduto )
	Local lRet		 	:= .T.

	IF Empty(cUmPreco)
		Help( , , STR0014, , STR0017, 1, 0 ) //"AJUDA"###"Produto nao possui UM.Pre�o."
		lRet := .F.
	EndIF

	oModelNJX:LoadValue( "NJX_UMPRC" , cUmPreco )

Return( lRet )
