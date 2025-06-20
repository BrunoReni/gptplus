#INCLUDE "GFEA047.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GFEA047  � Autor � Luiz Fernando Soares  � Data � 29.10.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de Tipos de Operacao 		                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GFEA047()	                                              ���
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
/*/{Protheus.doc} GFEA047()
Cadastro de Tipos de Operacao


@author Luiz Fernando Soares
@since 29/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function GFEA047()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GV4")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA047")				    // Nome do fonte onde esta a fun��o MenuDef
oBrowse:SetDescription(STR0001)	// Descri��o do browse //"Cadastro de Tipos de Opera��o"
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
ADD OPTION aRotina TITLE STR0002    ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.GFEA047" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004      ACTION "VIEWDEF.GFEA047" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005      ACTION "VIEWDEF.GFEA047" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006      ACTION "VIEWDEF.GFEA047" OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007   	ACTION "VIEWDEF.GFEA047" OPERATION 9 ACCESS 0 //"Copiar"
ADD OPTION aRotina TITLE STR0008     ACTION "VIEWDEF.GFEA047" OPERATION 8 ACCESS 0 //"Imprimir"

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
oModel := MPFormModel():New("GFEA047", /*bPre*/, { |oX| GFEA047POS( oX ) }/*bPost*/, /*bCommit*/, /*bCancel*/)
// cId          Identificador do modelo
// cOwner       Identificador superior do modelo
// oModelStruct Objeto com  a estrutura de dados
// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
// bPost        Code-Block de valida��o do formul�rio de edi��o
// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
oModel:AddFields("GFEA047_GV4", Nil, FWFormStruct(1,"GV4"),/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetPrimaryKey({"GV4_FILIAL", "GV4_CDTPOP"})
//oModel:SetVldActivate ( { |oX| GFEA047DEL( oX ) } )

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA047")
Local oView  := Nil

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
oView:AddField( "GFEA047_GV4" , FWFormStruct(2,"GV4"), /*cLinkID*/ )	//
// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
// Associa um View a um box
oView:SetOwnerView( "GFEA047_GV4" , "MASTER" )   

Return oView

Function GFEA047POS(oModel)
Local lRet    := .T.
Local nOpc    := (oModel:GetOperation())
	
	If nopc == 4
		If GV4->GV4_SENTID <> FwFldGet( 'GV4_SENTID' ) .and. FwFldGet( 'GV4_SENTID' ) <> "0"
			dbSelectArea("GWN")
			dbSetOrder(5)
			If dbSeek(xFilial("GWN") + GV4->GV4_CDTPOP)	
				Help( ,, 'HELP',, STR0009, 1, 0,) //'N�o � poss�vel alterar sentido. Tipo de opera��o j� est� relacionado a um romaneio '
				lRet := .F.
			EndIf	    
		EndIf
	EndIf
	
	If nOpc == MODEL_OPERATION_DELETE
		//Posiciona na GU8 para verificar se h� algum ve�culo com o CDTPOP que est� sendo excluido.
		If GFXCP12117('GU8_CDTPOP')
			GU8->(dbSetOrder(02))
			While !GU8->( Eof() )
				If Alltrim(GU8->GU8_CDTPOP) == Alltrim(FwFldGet('GV4_CDTPOP')) 
					Help( ,, 'HELP',, 'N�o � poss�vel excluir um Tipo de Opera��o relacionado a um ve�culo.', 1, 0,) 
					lRet := .F.
				EndIf
				GU8->( dbSkip() )
			EndDo
		EndIf
	EndIf
	
Return lRet

