#INCLUDE "HSPAHA50.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA50  � Autor � L.Gustavo Caloi    � Data �  24/02/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Atividade Profissional (SUS)                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA50()
Private aRotina := MenuDef()

If HS_LocTab("GH1")
	DbSelectArea("GH1")
	mBrowse(06, 01, 22, 75, "GH1")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A50    � Autor � L.Gustavo Caloi    � Data �  24/02/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A50(cAlias, nReg, nOpc)
Local nOpcA := 0
Private nOpcE := aRotina[nOpc, 4]
Private aTela 					:= {}
Private aGets      := {}
Private aHeader 			:= {}
Private aCols      := {}
Private nUsado     := 0
Private oGH1
Private lGDVazio := .F.

RegToMemory("GH1",(nOpcE == 3)) //Gera variavies de memoria para o GH1

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de Atividade Profissional"

oGH1 := MsMGet():New("GH1", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGH1:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ValExcl(), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	FS_GrvA50(nReg)
	End Transaction
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA50 �Autor  �L.Gustavo Caloi     � Data �  24/02/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA50(nReg)
Local aArea := GetArea()

DbSelectArea("GH1")
If nOpcE <> 3
	DbGoTo(nReg)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GH1", (nOpcE == 3))
	HS_GrvCpo("GH1")
	GH1->GH1_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GH1", .F.)
	DbDelete()
	MsUnlock()
Endif

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ValExcl� Autor �L.Gustavo Caloi        � Data � 02/03/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ValExcl()
Local aArea := GetArea()
Local lRet	 := .T.

If nOpcE == 5
	If HS_CountTB("GHD", "GHD_CODCBO  = '" + M->GH1_CODCBO + "'")  > 0
		HS_MsgInf(STR0007, STR0008, STR0009) //"Atividade Profissional possui relacionamento com procedimento."###"Aten��o!"###"Valida��o de Exclus�o"
		lRet := .F.
	Endif
Endif

RestArea(aArea)
Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 11/07/07 ���
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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"	, 0, 1, 0, nil},; //"Pesquisar"
					 {OemtoAnsi(STR0002), "HS_A50"		, 0, 2, 0, nil},; //"Visualizar"
					 {OemtoAnsi(STR0003), "HS_A50"		, 0, 3, 0, nil},; //"Incluir"
					 {OemtoAnsi(STR0004), "HS_A50"		, 0, 4, 0, nil},; //"Alterar"
					 {OemtoAnsi(STR0005), "HS_A50"		, 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)
