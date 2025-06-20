#INCLUDE "GFEA041.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA041

Cadastro de tipos de documentos de carga

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA041()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GV5")										// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA041")				  			    // Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription("Cadastro de Tipos de Documentos de Carga")	    // Descri��o do browse //"Tipos de Documentos de Cargas"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------------------
// Adiciona bot�es do browse
//-------------------------------------------------------------------
ADD OPTION aRotina TITLE STR0002    ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.GFEA041" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004      ACTION "VIEWDEF.GFEA041" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005      ACTION "VIEWDEF.GFEA041" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006      ACTION "VIEWDEF.GFEA041" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007     ACTION "VIEWDEF.GFEA041" OPERATION 8 ACCESS 0   //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructGV5 := FWFormStruct(1,"GV5")
Local nX

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost   Code-Block de valida��o do formul�rio de edi��o
// bCommit Code-Block de persist�ncia do formul�rio de edi��o
// bCancel Code-Block de cancelamento do formul�rio de edi��o
oModel := MPFormModel():New("GFEA041", /*bPre*/,{ |oX| GFE41VSEN( oX ) }, /*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost        Code-Block de valida��o do formul�rio de edi��o
// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
oModel:AddFields("GFEA041_GV5", Nil, oStructGV5,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GV5_FILIAL", "GV5_CDTPDC"})

Return oModel

Static Function ViewDef()

Local oModel := FWLoadModel("GFEA041")
Local oView  := Nil
Local oStructGV5 := FWFormStruct(2,"GV5")

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
oView:AddField( "GFEA041_GV5" , oStructGV5, /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA041_GV5" , "MASTER" )   

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFE41VSEN

Faz a valida��o para que n�o possa ser informado o tipo do transporte como "Retorno"
e o sentido diferente de "Entrada"

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
                   
Function GFE41VSEN(oModel)
Local lRet    := .T.
Local nOpc    := (oModel:GetOperation())

If nOpc == 3 .Or. nOpc == 4
	dbSelectArea("GV5")
	dbSetOrder(1)
	If M->GV5_TPTRP == "2" .AND. M->GV5_SENTID <> "1"
		Help( ,, 'HELP',, STR0010, 1, 0) //"O valor selecionado do campo 'Tipo de Transporte' foi de 'Retorno', logo, o campo 'Sentido' s� poder� ser de 'Entrada'"
		lRet := .F.
	EndIf
EndIf

Return (lRet)     
 