#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MATA010GRR.CH'

//----------------------------------- MATA010GRR --------------------------------------
// Eventos para o cadastro de produtos voltado à integra com o GRR.
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA010GRR
Classe de eventos que relaciona o cadastro de produto à plataforma GRR

@author  Marcia Junko
@since   25/08/2022
/*/
//-------------------------------------------------------------------------------------
CLASS MATA010GRR FROM FWModelEvent

    Data cModelMaster   as Character

    Method New( cModelMaster ) Constructor
	Method VldActivate( oModel, cModelId )     
    Method ModelDefGRR( oModel )
    Method ViewDefGRR( oView )
	Method Destroy()

ENDCLASS

//---------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor

@param cModelMaster, caracter, Nome do modelo
@author  Marcia Junko
@since   25/08/2022
/*/
//---------------------------------------------------------
Method New( cModelMaster ) Class MATA010GRR

    Self:cModelMaster   := cModelMaster

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de pre 
validação do Model. Esse evento ocorre uma vez no contexto 
do modelo principal.

@param oModel, object, Objeto do model
@param cModelId, caracter, nome do model
@author  Marcia Junko
@since   25/08/2022/*/
//---------------------------------------------------------
Method VldActivate( oModel, cModelId ) Class MATA010GRR

    Self:ModelDefGRR( oModel )

Return .T.

//---------------------------------------------------------
/*/{Protheus.doc} ModelDefGRR
Adiciona o sub-modelo de Dados Adicionais do Produto GRR ao modelo de Produtos

@param oModel, object, Model do cadastro de produtos

@author  Marcia Junko
@since   25/08/2022
/*/
//---------------------------------------------------------
Method ModelDefGRR( oModel ) Class MATA010GRR

    Local oStruct := Nil

    // ----------------------------------------------
    //   Modelo HRG (produto recorrente do GRR).
    // ----------------------------------------------
    oStruct := FWFormStruct( 1, 'HRG' )
	oStruct:SetProperty( "HRG_SRCFIL", MODEL_FIELD_INIT, {|| xFilial( "SB1" ) } )
	oStruct:SetProperty( "HRG_ALIAS", MODEL_FIELD_INIT, {|| "SB1" } )
	oStruct:SetProperty( "HRG_CODE", MODEL_FIELD_INIT, {|| M->B1_COD } )

	oStruct:SetProperty( "HRG_RECURR", MODEL_FIELD_TITULO, STR0001 )   //"Produto Recorrente"

	oModel:AddFields( 'FORMHRG', Self:cModelMaster, oStruct )
    oModel:SetRelation( 'FORMHRG', {{ 'HRG_FILIAL', 'xFilial("HRG")' }, { 'HRG_SRCFIL', 'xFilial("SB1")' }, { 'HRG_ALIAS', "'SB1'" }, { 'HRG_CODE', 'B1_COD' }}, ( 'HRG' )->(IndexKey(1)) )
    oModel:GetModel( 'FORMHRG' ):SetDescription( STR0002 )     //"Gestão de Receita Recorrente"
    oModel:GetModel( 'FORMHRG' ):SetOptional( .T. )

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} ViewDefGRR
Adiciona o view do Dados Adicionais do GRR ao modelo de Produtos

@param oView, object, View do cadastro de produtos

@author  Marcia Junko
@since   25/08/2022
/*/
//---------------------------------------------------------
Method ViewDefGRR( oView ) Class MATA010GRR
    Local oStruct := Nil
	Local aRemoveFlds := { 'HRG_SRCFIL', 'HRG_ALIAS', 'HRG_CODE' }

    // ----------------------------------------------
	//   Visão HRG (produto recorrente do GRR).
    // ----------------------------------------------
    oStruct := FWFormStruct(2, 'HRG' )
	aEval( aRemoveFlds, {|x|  oStruct:RemoveField( x ) } )

	oStruct:SetProperty( "HRG_RECURR" , MVC_VIEW_TITULO, STR0001 )   //"Produto Recorrente"

    oView:AddField( 'VIEW_HRG', oStruct, 'FORMHRG' )
    oView:GetViewObj( "VIEW_HRG" )[3]:lCanChange := .T.
    oView:CreateHorizontalBox( 'FOLDER_HRG', 10 )
    oView:SetOwnerView( 'VIEW_HRG', 'FOLDER_HRG' )
    oView:EnableTitleView( 'VIEW_HRG', STR0002 )     //"Gestão de Receita Recorrente"

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo responsável por destruir os atributos da classe como 
arrays e objetos.

@author  Marcia Junko
@since   25/08/2022
/*/
//-------------------------------------------------------------------
Method Destroy() Class MATA010GRR
Return Nil

