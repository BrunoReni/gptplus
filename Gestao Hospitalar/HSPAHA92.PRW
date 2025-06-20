#INCLUDE "HSPAHA92.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � HSPAHA92 � Autor � Robson Ramiro A. Olive� Data � 12.08.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de Mnemonicos                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � HSPAHA92(void)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � HSP                                                        ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHA92()

Private aRotina := MenuDef()

Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Mnemonicos"

DbSelectArea("GCQ")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"GCQ",,,,,,)

Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � HS_A92Roti � Autor � Robson Ramiro A.Olivei� Data �12.08.04  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Manutencao dos Dados                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � HS_A92Roti(ExpC1,ExpN1,ExpN2)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHA92                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_A92Roti(cAlias,nReg,nOpc)

Local oDlg	:= NIL
Local nOpA 	:= 0

Private aTela := {}, aGets := {}

DbSelectArea(cAlias)

RegToMemory("GCQ",(nOpc == 3))

aSize := MsAdvSize(.T.)
  
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007)From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Mnemonicos"

oEnchoi := MsMGet():New("GCQ",nReg,nOpc,,,,,,,,,,,oDlg,,.T.) 
oEnchoi :oBox:align:= CONTROL_ALIGN_ALLCLIENT      

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,	{||nOpA := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpA := 0)},;
																																																	{||nOpA := 0, oDlg:End()})

If (nOpA == 1) .and. (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5)
	FS_A92Grav(nOpc)
Endif

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_A92Grav� Autor � Robson Ramiro A Olivei� Data � 12.08.04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Grava/Exclui                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FS_A92Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � HSPAHA92                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FS_A92Grav(nOpc)

Local lGraOk	:= .T.
Local nCont		:= 0
Local nCpo
Local bCampo	:= { |nCPO| Field(nCPO) }

DbSelectArea("GCQ")
DbSetOrder(1)

Begin Transaction

If (nOpc == 3 .or. nOpc == 4)
	
	If nOpc == 4
		RecLock("GCQ",.F.)
	Else
		RecLock("GCQ",.T.)
	Endif
	
	For nCont := 1 To FCount()
		
		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("GCQ"))
		Elseif "LOGARQ"$Field(nCont)
			FieldPut(nCont,HS_LOGARQ())
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif
		
	Next nCont

	MsUnlock()	

Elseif nOpc == 5
	RecLock("GCQ",.F.)
	DbDelete()
	MsUnlock()
Endif

End Transaction

DbSelectArea("GCQ")
DbSetOrder(1)

Return lGraOk


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 06/06/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Gera arquivo TXT para exportacao                      �
//�    4 - Recebe arquivo TXT                                    �
//����������������������������������������������������������������
Local aRotina :=	{{ OemToAnsi(STR0001),	"AxPesqui"  ,	0, 1, 0, nil},;	  //"Pesquisar"
					 { OemToAnsi(STR0002),	"HS_A92Roti",	0, 2, 0, nil},;  //"Visualizar"
					 { OemToAnsi(STR0003),	"HS_A92Roti",	0, 3, 0, nil},;  //"Incluir"
					 { OemToAnsi(STR0004),	"HS_A92Roti",	0, 4, 0, nil},;  //"Alterar"
					 { OemToAnsi(STR0005),	"HS_A92Roti",	0, 5, 0, nil} }  //"Excluir"
Return(aRotina)