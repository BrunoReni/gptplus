#INCLUDE "HSPAHA20.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA20  � Autor � L.Gustavo Caloi    � Data �  12/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro do CID                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA20()
Private aRotina := MenuDef()

If HS_LocTab("GAS")      
	DbSelectArea("GAS") 
	mBrowse(06, 01, 22, 75, "GAS")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A20    � Autor � L.Gustavo Caloi    � Data �  12/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A20(cAlias, nReg, nOpc)
Local nOpcA      := 0
Private nOpcE    := aRotina[nOpc, 4]
Private aTela    := {}
Private aGets    := {}
Private aHeader  := {}
Private aCols    := {}
Private nUsado   := 0
Private oGAS
Private lGDVazio := .F.

RegToMemory("GAS",(nOpcE == 3)) //Gera variavies de memoria para o GAS

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de CID"

oGAS := MsMGet():New("GAS", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGAS:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ExclGAS(), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	 FS_GrvA20(nReg)
	End Transaction
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA20 �Autor  �L.Gustavo Caloi     � Data �  12/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA20(nReg)
Local aArea := GetArea()
Local lEspelhar := GetNewPar("MV_INTCID ",.F.)
Local LNovBA9 	:= .T.

DbSelectArea("GAS")
If nOpcE <> 3
	DbGoTo(nReg)
Endif




//������������������������������������������������������Ŀ
//� Espelhamento GAS X BA9...                            �
//��������������������������������������������������������
If nOpcE == 3   //Inclusao
	//������������������������������������������������������Ŀ
	//� Verifica se o Cid ja existe Tabela PLS                  �
	//��������������������������������������������������������
	
		If lEspelhar

			If  ! Empty(M->GAS_CODIGO)
				DbSelectArea("BA9")		
				BA9->(DbSetOrder(1))
				lNovBA9 := (BA9->(MsSeek(xFilial("BA9")+M->GAS_CODIGO)))
			Endif
		Else
			lNovBA9 := .T.
		Endif
		
		//������������������������������������������������������Ŀ
		//� Verifica se deve criar cid AnO pLANO DE sAUDE                    �
		//��������������������������������������������������������
		If  ! LNovBA9 
			DbSelectArea("BBL")
			BBL->(DbSetOrder(2))
			If 	BBL->(MsSeek(xFilial("BBL")+"HSPAHA20  "+"GAS"+"BA9"))
					BA9->(RecLock("BA9",(nOpcE == 3)))
					BA9->BA9_FILIAL := xFilial("BA9")
					PlsSinc("HSPAHA20","GAS","BA9")
					BA9->BA9_ABREVI:=M->GAS_CODIGO + M->GAS_PATOLO
					BA9->(MsUnLock())
			Else
				If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0010)) //"Arquivo de sincronismo entre BA9 x GAS nao esta integro. Verifique!"
				Endif
			Endif

		Endif
	
	RecLock("GAS", (nOpcE == 3))
	HS_GrvCpo("GAS")
	GAS->GAS_FILIAL:=xFilial("GAS")
	GAS->GAS_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
	
ElseIf nOpcE == 4
		If lEspelhar 
			DbSelectArea("BA9")
			BA9->(DbSetOrder(1))
			If BA9->(MsSeek(xFilial("BA9")+M->GAS_CODIGO))
				DbSelectArea("BBL")
				BBL->(DbSetOrder(2))
				If BBL->(MsSeek(xFilial("BBL")+"HSPAHA20  "+"GAS"+"BA9"))
					BA9->(RecLock("BA9",.F.))
					BA9->BA9_FILIAL := xFilial("BA9")
					PlsSinc("HSPAHA20","GAS","BA9")
					BA9->(MsUnLock())
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0010)) //"Arquivo de sincronismo entre BA9 x GAS nao esta integro. Verifique!"
					Endif
				Endif
			Endif
		Endif
	
	RecLock("GAS", .F.)
	HS_GrvCpo("GAS")
	GAS->GAS_FILIAL:=xFilial("GAS")	
	GAS->GAS_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
ElseIf nOpcE == 5
	
		If lEspelhar
			DbSelectArea("BA9")
			BA9->(DbSetOrder(1))
			If BA9->(MsSeek(xFilial("BA9")+M->GAS_CODIGO))
				DbSelectArea("BBL")
				BBL->(DbSetOrder(2))
				If BBL->(MsSeek(xFilial("BBL")+"HSPAHA20  "+"GAS"+"BA9"))
					RecLock("BA9", .F.)
					DbDelete()
					MsUnlock() 
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
					MsgAlert(OemtoAnsi(STR0010)) //"Arquivo de sincronismo entre BA9 x GAS nao esta integro. Verifique!"
					Endif
				Endif
			Endif
		Endif
	
	
	RecLock("GAS", .F.)
	DbDelete()
	MsUnlock()
	
Endif

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ExclGAS� Autor �L.Gustavo Caloi        � Data � 12/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ExclGAS()
Local aArea := GetArea()
Local lRet	 := .T.
                                           
If nOpcE == 5  .and. GHH->(FieldPos("GHH_CODCID")) > 0 //Exclus�o e existe tabela no banco
	If HS_CountTB("GHH", "GHH_CODCID = '" + M->GAS_CODIGO + "'")  > 0 
		HS_MsgInf(STR0007, STR0008, STR0009) //"Grupo de Atendimento possui relacionamento com procedimento."###"Aten��o"###"Valida��o da Exclus�o"
		lRet := .F.
	Endif
Endif
                                                                                 
RestArea(aArea)
Return(lRet)


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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui", 0, 1, 0, nil}, ;  //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A20"	 , 0, 2, 0, nil}, ; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_A20"	 , 0, 3, 0, nil}, ; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_A20"	 , 0, 4, 0, nil}, ; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_A20"	 , 0, 5, 0, nil} }  //"Excluir"
Return(aRotina)
