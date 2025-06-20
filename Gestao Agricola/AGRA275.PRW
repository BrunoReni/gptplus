#INCLUDE "AGRA275.CH"
#include 'protheus.ch'


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA275  � Autor � Ricardo Tomasi     � Data �  25/05/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Implanta��o de Saldos Iniciais de Estoque.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA275()

Private cCadastro := STR0001 //"Saldos de Iniciais de Clientes"
Private aRotina   := MenuDef()

//�������������������������Ŀ
//� Realiza ajuste no Help  �
//���������������������������
AjustaHelp()

dbSelectArea('NPK')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NPK')

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA275A � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para montagem da tela de cadastro.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA275A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nY       := 0

Private aGets  := Array(0)
Private aTela  := Array(0,0)
Private oDlg
Private oEnch

RegToMemory('NPK',(nOpcX==3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NPK',nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(AGRA275B(nOpcX), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() })

If nOpcA==1 .And. (nOpcX==3 .Or. nOpcX==5)
	Begin Transaction
	dbSelectArea('NPK')
	dbSetOrder(1)
	dbSeek(xFilial('NPK')+M->NPK_CODCLI+M->NPK_LOJCLI+M->NPK_SAFRA+M->NPK_ARM)
	If nOpcX==3
		If RecLock('NPK',.t.)
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			NPK->NPK_FILIAL := xFilial('NPK')
			msUnLock()
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
		//��������������������������������������������������������������Ŀ
		//�Grava tabela de saldos caso nao exista saldo para este cliente�
		//����������������������������������������������������������������
		dbSelectArea('NPL')
		dbSetOrder(1)
		If dbSeek(xFilial('NPL')+M->NPK_CODCLI+M->NPK_LOJCLI+M->NPK_SAFRA+M->NPK_ARM)
			RecLock('NPL',.F.)
			NPL->NPL_SALDO += M->NPK_SLDINI
			MsUnLock()
		Else
			RecLock('NPL',.T.)
			NPL->NPL_FILIAL := xFilial('NPL')
			NPL->NPL_CODCLI := M->NPK_CODCLI
			NPL->NPL_LOJCLI := M->NPK_LOJCLI
			NPL->NPL_NOMCLI := M->NPK_NOMCLI
			NPL->NPL_SAFRA  := M->NPK_SAFRA
			NPL->NPL_ARM    := M->NPK_ARM
			NPL->NPL_SALDO  := M->NPK_SLDINI
			MsUnLock()
		EndIf
	EndIf
	If nOpcX==5
		//��������������������������������������������������������������Ŀ
		//�Grava tabela de saldos caso nao exista saldo para este cliente�
		//����������������������������������������������������������������
		dbSelectArea('NPL')
		dbSetOrder(1)
		If dbSeek(xFilial('NPL')+M->NPK_CODCLI+M->NPK_LOJCLI+M->NPK_SAFRA+M->NPK_ARM)
			RecLock('NPL',.F.)
			NPL->NPL_SALDO -= M->NPK_SLDINI
			MsUnLock()
			If NPL->NPL_SALDO+NPL->NPL_ENBRUT+NPL->NPL_ENDESC+NPL->NPL_ENEXTR+NPL->NPL_ENLIQU+NPL->NPL_ENTRFS+;
			                  NPL->NPL_SDBRUT+NPL->NPL_SDDESC+NPL->NPL_SDEXTR+NPL->NPL_SDLIQU+NPL->NPL_SDTRFS == 0
				RecLock('NPL',.F.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf
		If RecLock('NPK',.f.)
			dbDelete()
			msUnLock()
		EndIf
	EndIf
	End Transaction
Else
	If nOpcX==3
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf
EndIf

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA275B � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para validar a tela de cadastro.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA275B(nOpcX)
Local lRetorno := .t.

If nOpcX==3
	If Obrigatorio(aGets,aTela)
		dbSelectArea('NPK')
		dbSetOrder(1)
		If dbSeek(xFilial('NPK')+M->NPK_CODCLI+M->NPK_LOJCLI+M->NPK_SAFRA+M->NPK_ARM)
			lRetorno := .f.
			Help('',1,'AGRA275BV1')
		EndIf
	EndIf
EndIf

Return(lRetorno)

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � AjustaHelp   � Autor � Ricardo Berti 	   	� Data � 05/12/08 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Ajusta helps							                          ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � AjustaHelp( )                                                  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum	  										      	      ���
�����������������������������������������������������������������������������Ĵ��
��� Uso		 � AGRA275                                                   	  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Static Function AjustaHelp()

Local aHelpPor :={}
Local aHelpEng :={}
Local aHelpSpa :={}  

aHelpPor	:=	{"Cadastro j� existente."}
aHelpEng	:=	{"  "}
aHelpSpa	:=	{"Archivo existente."}
PutHelp("PAGRA275BV1",aHelpPor,aHelpEng,aHelpSpa,.F.)

aHelpPor	:=	{"Atualize cadastro existente ou utilize  ",;
				 "um novo c�digo de cliente."}
aHelpEng	:=	{"  "}
aHelpSpa	:=	{"Actualice archivo existente o utilice   ",;
				 "un nuevo codigo de cliente."}
PutHelp("SAGRA275BV1",aHelpPor,aHelpEng,aHelpSpa,.F.)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  � Ricardo Tomasi     � Data �  04/10/2006 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o do menu.                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina:= {;
				 { STR0002 ,'AxPesqui',0,1} ,; //"Pesquisar"
				 { STR0003 ,'AxVisual',0,2} ,; //"Visualizar"
				 { STR0004 ,'AGRA275A',0,3} ,; //"Incluir"
				 { STR0005 ,'AGRA275A',0,5}  ; //"Excluir"
				 }

Return(aRotina)