#INCLUDE "GFEA045.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GFEA045  � Autor � Luiz Fernando Soares  � Data � 29.10.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de Tipos de Veiculos 		                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GFEA045()	                                              ���
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
/*/{Protheus.doc} GFEA045()
Cadastro de Tipos de Veiculos


@author Luiz Fernando Soares
@since 29/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA045()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GV3")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA045")				    // Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription("Cadastro de Tipos de Ve�culo")	// Descri��o do browse //"Cadastro de Tipos de Ve�culos"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------
// Adiciona bot�es do browse
//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0001    ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0002   ACTION "VIEWDEF.GFEA045" OPERATION 2 ACCESS 0 //"Visualizar"
	/*
	Habilitar bot�es (Incluir, excluir, Copiar) SOMENTE SE:
	SE o ERP Integrado (MV_ERPGFE) for Protheus E Origem dos Cadastros OMS (MV_CADOMS) = SIGAGFE
	OU
	ERP Integrado (MV_ERPGFE) diferente de Protheus e Origem dos Cadastros (MV_CADERP) = SIGAGFE.
	*/

	If ((SuperGetMv("MV_ERPGFE",.F.,"2") == "2").and.(SuperGetMv("MV_CADOMS",.F.,"2") == "2")); //Protheus e origem dos cadastros sigagfe
		.Or. ((SuperGetMv("MV_ERPGFE",.F.,"1") == "1") .And.(SuperGetMv("MV_DSINTTV",.F.,"2") != "1")); //datasul e n�o integra tipo de ve�culo
		.Or. (!(SuperGetMv("MV_ERPGFE",.F.,"2")$ "1;2"))//outros
		ADD OPTION aRotina TITLE STR0003      ACTION "VIEWDEF.GFEA045" OPERATION 3 ACCESS 0 //"Incluir"
	Endif
	ADD OPTION aRotina TITLE STR0004      ACTION "VIEWDEF.GFEA045" OPERATION 4 ACCESS 0 //"Alterar"
	If ((SuperGetMv("MV_ERPGFE",.F.,"2") == "2").and.(SuperGetMv("MV_CADOMS",.F.,"2") == "2"));
		.Or. ((SuperGetMv("MV_ERPGFE",.F.,"1") == "1") .And.(SuperGetMv("MV_DSINTTV",.F.,"2") != "1"));
		.or. (!(SuperGetMv("MV_ERPGFE",.F.,"2")$ "1;2"))
		ADD OPTION aRotina TITLE STR0005      ACTION "VIEWDEF.GFEA045" OPERATION 5 ACCESS 0 //"Excluir"
		ADD OPTION aRotina TITLE STR0006   	ACTION "VIEWDEF.GFEA045" OPERATION 9 ACCESS 0 //"Copiar"   
	Endif
	ADD OPTION aRotina TITLE STR0007     ACTION "VIEWDEF.GFEA045" OPERATION 8 ACCESS 0 //"Imprimir"

	
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
oModel := MPFormModel():New("GFEA045", /*bPre*/, /* bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost        Code-Block de valida��o do formul�rio de edi��o
// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
oModel:AddFields("GFEA045_GV3", Nil, FWFormStruct(1,"GV3"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GV3_FILIAL", "GV3_CDTPVC"})

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA045")
Local oView  := Nil      
Local oStruct := FWFormStruct(2,"GV3")

// Integra��o - Desabilita campos
If SuperGetMV("MV_CADOMS",,"1") $ "1S"
	oStruct:SetProperty( "GV3_CDTPVC" , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_DSTPVC" , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_EIXOS"  , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_POSCOM" , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_SIT"    , MVC_VIEW_CANCHANGE ,.F.)                           
Endif

If SuperGetMv("MV_DSINTTV",.F.,"2") $ "1S" .And. SuperGetMv("MV_ERPGFE",.F.,"2") $ "1S"
	oStruct:SetProperty( "GV3_CDTPVC" , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_DSTPVC" , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_CARGUT" , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_VOLUT"  , MVC_VIEW_CANCHANGE ,.F.)
	oStruct:SetProperty( "GV3_SIT"    , MVC_VIEW_CANCHANGE ,.F.) 
EndIf                      
//Fim integra��o

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
oView:AddField( "GFEA045_GV3" , oStruct , /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA045_GV3" , "MASTER" )   

Return oView

