#INCLUDE "HSPAHABU.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABU  � Autor � Mario Arizono      � Data �  16/05/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de motivo de suspensao da prescricao              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHABU()

Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui" , 0, 1}, ;  //"Pesquisar"
                    {OemtoAnsi(STR0002), "HS_MntABU"			, 0, 2}, ;  //"Visualizar"
                    {OemtoAnsi(STR0003), "HS_MntABU"		 , 0, 3}, ;  //"Incluir"
                    {OemtoAnsi(STR0004), "HS_MntABU"		 , 0, 4}, ;  //"Alterar"
                    {OemtoAnsi(STR0005), "HS_MntABU"		 , 0, 5} }  //"Excluir"

If HS_LocTab("GHS")
	DbSelectArea("GHS")
	mBrowse(06, 01, 22, 75, "GHS")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_MntABU � Autor � Mario Arizono      � Data �  16/05/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_MntABU(cAlias, nReg, nOpc)
Local nOpcA := 0
Private nOpcE := aRotina[nOpc, 4]
Private aTela 					:= {}
Private aGets      := {}
Private oGHS

RegToMemory("GHS",(nOpcE == 3)) //Gera variavies de memoria para o GH1

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  //"Cadastro de Motivo de Suspens�o"

oGHS := MsMGet():New("GHS", nReg, nOpcE,,,,, aPObjs[1],,,,,, oDlg)
oGHS:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ValExcl(), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	FS_GrvABU(nReg)
	End Transaction
 
 While __lSx8
   ConfirmSx8()
 End  
ElseIf nOpcA == 0
 While __lSx8
  RollBackSxe()
 End      
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvABU �Autor  �Mario Arizono       � Data �  16/05/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gravacao.                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvABU(nReg)
Local aArea := GetArea()

DbSelectArea("GH1")
If nOpcE <> 3
	DbGoTo(nReg)
Else
 M->GHS_MOTIVO := HS_VSxeNum("GHS", "M->GHS_MOTIVO", 1)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GHS", (nOpcE == 3))
	HS_GrvCpo("GHS")
	GHS->GHS_FILIAL := xFilial("GHS")
	MsUnlock()
	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GHS", .F.)
	DbDelete()
	MsUnlock()
Endif

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ValExcl� Autor �Mario Arizono          � Data � 16/05/07 ���
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
	If HS_CountTB("GHV", "GHV_MOTIVO  = '" + M->GHS_MOTIVO + "'")  > 0  .Or. HS_CountTB("GHX", "GHX_MOTIVO  = '" + M->GHS_MOTIVO + "'")  > 0
		HS_MsgInf(STR0007, STR0008, STR0009)  //"Motivo de suspens�o possui relacionamento com prescri��o m�dica."###"Aten��o"###"Valida��o exclus�o"
		lRet := .F.
	Endif
Endif

RestArea(aArea)
Return(lRet)
