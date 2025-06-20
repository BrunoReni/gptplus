#INCLUDE "OGA135.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA135 
Rotina para cadastro de Tabelas de Servi�os 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	22/10/2014
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA135()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NKP" )
oMBrowse:SetDescription( STR0001 ) //"Tabelas de Produto"
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Rocio
@since: 	22/10/2014
@Uso: 		OGA135 - Servi�os
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002   , "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003   , "ViewDef.OGA135", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004   , "ViewDef.OGA135", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005   , "ViewDef.OGA135", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006   , "ViewDef.OGA135", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007   , "ViewDef.OGA135", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0008   , "ViewDef.OGA135", 0, 9, 0, Nil } ) //"Copiar"
aAdd( aRotina, { STR0011   , "OGA135I(NKP->NKP_CODTSE)"	, 0, 3, 0, Nil } ) //"Servi�os"

Return( aRotina )


/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Rocio
@since: 	22/10/2014
@Uso: 		OGA135 - Servi�os
*/
Static Function ModelDef()
Local oStruNKP := FWFormStruct( 1, "NKP" )
Local oModel := MPFormModel():New( "OGA135", , {| oModel | PosModelo( oModel ) } )

oModel:AddFields( "NKPUNICO", Nil, oStruNKP )
oModel:SetDescription( STR0009 ) //"Tabela de Servi�os"
oModel:GetModel( "NKPUNICO" ):SetDescription( STR0010 ) //"Dados da Tabela"

Return( oModel )

/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Rocio
@since: 	22/10/2014
@Uso: 		OGA135 - Servi�os
*/
Static Function ViewDef()
Local oStruNKP := FWFormStruct( 2, "NKP" )
Local oModel   := FWLoadModel( "OGA135" )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_NKP", oStruNKP, "NKPUNICO" )
oView:CreateHorizontalBox( "UM"  , 100 )
oView:SetOwnerView( "VIEW_NKP", "UM"   )

oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} PosModelo
Fun��o que valida o modelo de dados ap�s a confirma��o

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function PosModelo( oModel )
Local lRetorno	:= .t.
Local aAreaAtu	:= GetArea()
Local nOperation	:= oModel:GetOperation()


If nOperation == MODEL_OPERATION_DELETE

	dbSelectArea( 'NJR' )
	dbSetOrder( 4 )
	If dbSeek( xFilial( 'NJR' ) + '3' + NKP->( NKP_CODTSE ))
		Help(, , STR0012, , STR0013, 1, 0 ) //"Ajuda"###"Tabela n�o pode ser exclu�da pois tem contrato de dep�sito em 3� relacionado"
		lRetorno := .f.
	EndIf
	
	dbSelectArea( 'NJX' )
	dbSetOrder( 4 )
	If dbSeek( xFilial( 'NJX' ) + '3' + NKP->( NKP_CODTSE ))
		Help(, , STR0012, , STR0014, 1, 0 ) //"Ajuda"###"Tabela n�o pode ser exclu�da pois tem modelo de contrato de dep�sito em 3� relacionado"
		lRetorno := .f.
	EndIf

EndIf

RestArea( aAreaAtu )

Return( lRetorno )
