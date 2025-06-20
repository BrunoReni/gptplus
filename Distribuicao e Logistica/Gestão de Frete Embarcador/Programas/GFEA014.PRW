#INCLUDE "GFEA014.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
   
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA014

Cadastro de Tipo de Itens  

@author Jorge Matos Valcanaia
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA014()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GUQ")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA014")				    // Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription("Cadastro de Tipos de Itens")	    // Descri��o do browse //"Tipos de itens"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------
// Adiciona bot�es do browse
//-------------------------------------------------------
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA014" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA014" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA014" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA014" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost   Code-Block de valida��o do formul�rio de edi��o
// bCommit Code-Block de persist�ncia do formul�rio de edi��o
// bCancel Code-Block de cancelamento do formul�rio de edi��o
oModel := MPFormModel():New("GFEA014", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost        Code-Block de valida��o do formul�rio de edi��o
// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
oModel:AddFields("GFEA014_GUQ", Nil, FWFormStruct(1,"GUQ"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GUQ_FILIAL", "GUQ_TPITEM"})


Return oModel



Static Function ViewDef()

Local oModel := FWLoadModel("GFEA014")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
oView:AddField( "GFEA014_GUQ" , FWFormStruct(2,"GUQ"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA014_GUQ" , "MASTER" )   

Return oView