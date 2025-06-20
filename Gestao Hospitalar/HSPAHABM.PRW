#INCLUDE "HSPAHABM.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABM  � Autor � Mario Arizono      � Data �  20/07/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Motivo de Cobran�a (APAC)(SUS)                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHABM()
Private aRotina := MenuDef()

If HS_LocTab("GH7")
	DbSelectArea("GH7")
	mBrowse(06, 01, 22, 75, "GH7")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_MntABM � Autor � Mario Arizono      � Data �  20/07/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_MntABM(cAlias, nReg, nOpcABM)
Local nOpcA := 0
Private aTela 					:= {}
Private aGets      := {}
Private oGH7

RegToMemory("GH7",(nOpcABM == 3)) //Gera variavies de memoria para o GH7

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T.,.T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Cadastro de Motivo de Cobran�a (APAC)"

oGH7 := MsMGet():New("GH7", nReg, nOpcABM,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGH7:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcABM == 5, FS_ValExcl(nOpcABM), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcABM <> 2
	FS_GrvGHM(nOpcABM)
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvABM �Autor  �Mario Arizono       � Data �  20/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para gravacao dos campos.                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvGHM(nOpcABM)
Local lFoundGHM := .F.

If aRotina[nOpcABM, 4] <> 2
	Begin Transaction
	dbSelectArea("GH7")
	dbSetOrder(1) //FILIAL+MOTIVO COBRANCA
	lFoundGHM := DbSeek(xFilial("GH7") + M->GH7_CMCPAC)
	
	If aRotina[nOpcABM, 4] <> 5
		RecLock("GH7",!lFoundGHM)
		HS_GrvCpo("GH7")
		GH7->GH7_FILIAL := xFilial("GH7")
		GH7->GH7_LOGARQ := HS_LOGARQ()
		MsUnlock()
	Else
		dbSelectArea("GH7")
		dbSetOrder(1)
		RecLock("GH7", .F.)
		dbDelete()
		MsUnlock()
		WriteSx2("GH7")
	EndIf
	End Transaction
EndIf

Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_ValExcl� Autor �Mario Arizono          � Data � 20/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Funcao utilizada para validar a exclusao de um registro.    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ValExcl(nOpcABM)
Local aArea := GetArea()
Local lRet	 := .T.

If nOpcABM == 5
	If HS_CountTB("GCZ", "GCZ_CMCPAC = '" + M->GH7_CMCPAC + "'")  > 0
		HS_MsgInf(STR0007,STR0008,STR0009) //"Este registro possui relacionamento com as guias de atendimentos."###"Aten��o"###"Valida��o Exclus�o"
		lRet := .F.
	EndIf
EndIf
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
                     {OemtoAnsi(STR0002), "HS_MntABM"	, 0, 2, 0, nil},; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_MntABM"	, 0, 3, 0, nil},; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_MntABM"	, 0, 4, 0, nil},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_MntABM"	, 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)