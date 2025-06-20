#INCLUDE "GFEA031.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GFEA031  � Autor � Luiz Fernando Soares  � Data � 25.03.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de Motivos de Ocorrencia	                      	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GFEA031()	                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� 			 �        �XXXXXX�	                                      ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/


//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA031()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GU6")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA031")				    // Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription(STR0009)	// Descri��o do browse //"Cadastro de Motivos de Ocorr�ncia"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
local lRet := .T.
//-------------------------------------------------------
// Adiciona bot�es do browse
//-------------------------------------------------------
ADD OPTION aRotina TITLE STR0001    ACTION "AxPesqui"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0002   ACTION "VIEWDEF.GFEA031" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003      ACTION "VIEWDEF.GFEA031" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004      ACTION "VIEWDEF.GFEA031" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005      ACTION "VIEWDEF.GFEA031" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0006   	ACTION "VIEWDEF.GFEA031" OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0007     ACTION "VIEWDEF.GFEA031" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF----------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()

Local oModel

// cID     Identificador do modelo 
// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost   Code-Block de valida��o do formul�rio de edi��o
// bCommit Code-Block de persist�ncia do formul�rio de edi��o
// bCancel Code-Block de cancelamento do formul�rio de edi��o
oModel := MPFormModel():New("GFEA031", /*bPre*/, {|oX| GFEA031POS(oX)}/* bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost        Code-Block de valida��o do formul�rio de edi��o
// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
oModel:AddFields("GFEA031_GU6", Nil, FWFormStruct(1,"GU6"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GU6_FILIAL", "GU6_CDMOT"})

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA031")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
oView:AddField( "GFEA031_GU6" , FWFormStruct(2,"GU6"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA031_GU6" , "MASTER" )   

Return oView

function GFEA031POS(oModel)
local lRet := .T.
local nOpc      := (oModel:GetOperation())
if nOpc == 5
	dbSelectArea("GU4")
	dbSetOrder(1)
	if dbSeek(xFilial("GU4")+GU6->GU6_CDMOT)
		PutHelp("PGFE031A",{STR0008},{STR0008},{STR0008})  //"Motivo est� relacionado a um tipo"###"Motivo est� relacionado a um tipo"###"Motivo est� relacionado a um tipo"
		HELP(" ",1,"GFE031A" )
		lRet := .F.	
	endif

endif
return lRet



