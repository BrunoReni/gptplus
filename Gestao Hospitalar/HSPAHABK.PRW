#INCLUDE "HSPAHABK.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABK  � Autor � L.Gustavo Caloi    � Data �  02/03/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de N�vel Hier�rquico (SUS)                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHABK()
Private aRotina := MenuDef()

If HS_LocTab("GH5")
	DbSelectArea("GH5")
	mBrowse(06, 01, 22, 75, "GH5")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_ABK    � Autor � L.Gustavo Caloi    � Data �  02/03/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_ABK(cAlias, nReg, nOpc)
Local nOpcA := 0

Private nOpcE := aRotina[nOpc, 4]
Private aTela 					:= {}
Private aGets      := {}
Private aHeader 			:= {}
Private aCols      := {}
Private nUsado     := 0
Private oGH5
Private lGDVazio := .F.

RegToMemory("GH5",(nOpcE == 3)) //Gera variavies de memoria para o GH5

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de N�vel Hier�rquico"

oGH5 := MsMGet():New("GH5", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGH5:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, .T., .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	FS_GrvABK(nReg)
	End Transaction
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvABK �Autor  �L.Gustavo Caloi     � Data �  02/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvABK(nReg)
Local aArea := GetArea()

DbSelectArea("GH4")
If nOpcE <> 3
	DbGoTo(nReg)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GH5", (nOpcE == 3))
	HS_GrvCpo("GH5")
	GH5->GH5_LOGARQ := HS_LOGARQ()
	MsUnlock()
	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GH5", .F.)
	DbDelete()
	MsUnlock()
Endif

RestArea(aArea)
Return()


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
					 {OemtoAnsi(STR0002), "HS_ABK"		, 0, 2, 0, nil},; //"Visualizar"
					 {OemtoAnsi(STR0003), "HS_ABK"		, 0, 3, 0, nil},; //"Incluir"
					 {OemtoAnsi(STR0004), "HS_ABK"		, 0, 4, 0, nil},; //"Alterar"
					 {OemtoAnsi(STR0005), "HS_ABK"		, 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)