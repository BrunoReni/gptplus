#INCLUDE "OGA040.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA040
Rotina para cadastro de esp�cies de variedades de gr�os

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA040()
Local oMBrowse := Nil

If !AGRIFDICIONA("SX3","NJ2_WRRANT",2,.F.) // Verifica se o registro existe no dicion�rio de dados
	AGRINCOMDIC("UPDOG",,.T.)						// Mensagem de incompatibilidade do dicion�rio de dados
	Return
EndIf

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NJ2" )
oMBrowse:SetDescription( STR0001 ) //"Tipos de Reserva"
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( )

/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA040 - Tipos de Reserva
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "ViewDef.OGA040", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004, "ViewDef.OGA040", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005, "ViewDef.OGA040", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006, "ViewDef.OGA040", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007, "ViewDef.OGA040", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0008, "ViewDef.OGA040", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )

/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA040 - Tipos de Reserva
*/
Static Function ModelDef()
Local oStruNJ2 := FWFormStruct( 1, "NJ2" )
Local oModel := MPFormModel():New( "OGA040" )

oModel:AddFields( "NJ2UNICO", Nil, oStruNJ2 )
oModel:SetDescription( STR0009 ) //"Tipo de Reserva"
oModel:GetModel( "NJ2UNICO" ):SetDescription( STR0010 ) //"Dados do Tipo de Reserva"

Return( oModel )

/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA040 - Tipos de Reserva
*/
Static Function ViewDef()
Local oStruNJ2 := FWFormStruct( 2, "NJ2" )
Local oModel   := FWLoadModel( "OGA040" )
Local oView    := FWFormView():New()
Local lPlanoVnd:= SuperGetMV( "MV_AGRO027", .f., .f. )  

If .NOT. lPlanoVnd .AND. NJ2->(ColumnPos("NJ2_TIPOOP")) > 0 
	//Remove campo da tela se parametros MV_AGRO027 for .F.
	oStruNJ2:RemoveField( "NJ2_TIPOOP" )
EndIf

oView:SetModel( oModel )
oView:AddField( "VIEW_NJ2", oStruNJ2, "NJ2UNICO" )
oView:CreateHorizontalBox( "UM"  , 100 )
oView:SetOwnerView( "VIEW_NJ2", "UM"   )

oView:SetCloseOnOk( {||.t.} )

Return( oView )