#include 'AGRA420.CH'
#include 'protheus.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA420  � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de abastecimentos e manutencoes dos equipamentos. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA420()
Private cCadastro := STR0001 //"Abastecimento"
Private aRotina   := MenuDef()


dbSelectArea('NQD')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NQD')

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA420A � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para montagem da tela de cadastro.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA420A(cAlias, nReg, nOpc)
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

RegToMemory('NQD',(nOpcX==3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NQD',nReg,nOpcX,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(AGRA420B(nOpcX), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() })

If nOpcA==1 .And. (nOpcX==3 .Or. nOpcX==4 .Or. nOpcX==5)

	Begin Transaction
	dbSelectArea('NQD')
	dbSetOrder(1)
	If nOpcX==3 //Inclus�o
		If RecLock('NQD',.t.)
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			NQD->NQD_FILIAL := xFilial('NQD')
			msUnLock()
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf
	If nOpcX==4 //Aletra��o
		If RecLock('NQD',.f.)
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			msUnLock()
		EndIf
	EndIf
	If nOpcX==5 //Exclus�o
		If RecLock('NQD',.f.)
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
���Programa  � AGRA420B � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para validar a tela de cadastro.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA420B(nOpcX)
Local lRetorno := .t.

If nOpcX==3 .Or. nOpcX==4
	lRetorno := Obrigatorio(aGets,aTela)
EndIf

Return(lRetorno)

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
				{ STR0003 ,'AGRA420A',0,2} ,; //"Visualizar"
				{ STR0004 ,'AGRA420A',0,3} ,; //"Incluir"
				{ STR0005 ,'AGRA420A',0,4} ,; //"Alterar"
				{ STR0006 ,'AGRA420A',0,5}  ; //"Excluir"
				}

Return(aRotina)


