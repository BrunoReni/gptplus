#include 'AGRA025.CH'
#include 'protheus.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA025  � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Equipamentos.                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA025()
	Private cCadastro := STR0001 //"Cadastro de Equipamento"
	Private aRotina   := MenuDef()

	dbSelectArea('NNB')
	dbSetOrder(1)

	mBrowse( 6, 1, 22, 75, 'NNB')

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA025A � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para montagem da tela de cadastro.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA025A(cAlias, nReg, nOpc)

	Local aSize    := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local nOpcX    := aRotina[nOpc,4]
	Local nOpcA    := 0
	Local nY       := 0

	Local cArqNPA  := ''
	Local cOrdNPA  := ''
	Local cIndNPA  := ''

	Private aGets  := Array(0)
	Private aTela  := Array(0,0)
	Private oDlg
	Private oEnch

	RegToMemory('NNB',(nOpcX==3))

	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NNB',nReg,nOpcX,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(AGRA025B(nOpcX), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() })

	If nOpcA==1 .And. (nOpcX==3 .Or. nOpcX==4 .Or. nOpcX==5)
		Begin Transaction
			dbSelectArea('NNB')
			dbSetOrder(1)
			dbSeek(xFilial('NNB')+M->NNB_CODIGO)
			If nOpcX==3
				If RecLock('NNB',.t.)
					For nY := 1 To FCount()
						&(FieldName(nY)) := &('M->'+FieldName(nY))
					Next nY
					NNB->NNB_FILIAL := xFilial('NNB')
					msUnLock()
				EndIf
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
			If nOpcX==4
				If RecLock('NNB',.f.)
					For nY := 1 To FCount()
						&(FieldName(nY)) := &('M->'+FieldName(nY))
					Next nY
					msUnLock()
				EndIf
			EndIf
			If nOpcX==5
				//Valida a utiliza��o do codigo no Cadastro de Apontamentos
				If Empty(AllTrim(xFilial('NNB')))
					cOrdNPA := 'NPA_CODEQU'
				Else
					cOrdNPA := 'NPA_FILIAL+NPA_CODEQU'
				EndIf
				dbSelectArea('NPA')
				cArqNPA := CriaTrab(Nil,.f.)
				IndRegua('NPA', cArqNPA, cOrdNPA,,, 'Selecionando Registros...')
				nIndNPA := RetIndex('NPA')+1
				#IFNDEF TOP
				dbSetIndex(cIndNPA+OrdBagExT())
				#ENDIF
				dbSetOrder(nIndNPA)
				dbGotop()
				If .Not. dbSeek(&cOrdNPA)
					If RecLock('NNB',.f.)
						dbDelete()
						msUnLock()
					EndIf
				Else
					Alert('N�o � possivel excluir o Equipamento, pois existem lan�amentos vinculados.')
				EndIf
				dbSelectArea('NNB')
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
���Programa  � AGRA025B � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para validar a tela de cadastro.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA025B(nOpcX)
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
	{ STR0003 ,'AGRA025A',0,2} ,; //"Visualizar"
	{ STR0004 ,'AGRA025A',0,3} ,; //"Incluir"
	{ STR0005 ,'AGRA025A',0,4} ,; //"Alterar"
	{ STR0006 ,'AGRA025A',0,5}  ; //"Excluir"
	}

Return(aRotina)