#INCLUDE "HSPAHACF.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHACF  � Autor � Mario Arizono      � Data �  27/05/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro tabela unidade cobranca prescricao                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHACF()

Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui" , 0, 1}, ;   //"Pesquisar"
                    {OemtoAnsi(STR0002), "HS_MntACF"			, 0, 2}, ;   //"Visualizar"
                    {OemtoAnsi(STR0003), "HS_MntACF"		 , 0, 3}, ;   //"Incluir"
                    {OemtoAnsi(STR0004), "HS_MntACF"		 , 0, 4}, ;  //"Alterar"
                    {OemtoAnsi(STR0005), "HS_MntACF"		 , 0, 5} }   //"Excluir"

If HS_LocTab("GNS")
	DbSelectArea("GNS")
	mBrowse(06, 01, 22, 75, "GNS")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_MntACF � Autor � Mario Arizono      � Data �  27/05/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_MntACF(cAlias, nReg, nOpc)
Local nOpcA := 0
Private nOpcE := aRotina[nOpc, 4]
Private aTela 					:= {}
Private aGets      := {}
Private oGNS

RegToMemory("GNS",(nOpcE == 3)) //Gera variavies de memoria para GNS  

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd   //"Cadastro tabela unidade de cobran�a da prescri��o"

oGNS := MsMGet():New("GNS", nReg, nOpcE,,,,, aPObjs[1],,,,,, oDlg)
oGNS:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. Fs_VldOk(), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	FS_GrvACF(nReg)
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
���Programa  �FS_GrvACF �Autor  �Mario Arizono       � Data �  27/05/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gravacao.                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvACF(nReg)
Local aArea := GetArea()

DbSelectArea("GNS")
If nOpcE <> 3
	DbGoTo(nReg)
Else
 M->GNS_CODSEQ := HS_VSxeNum("GNS", "M->GNS_CODSEQ", 1)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GNS", (nOpcE == 3))
	HS_GrvCpo("GNS")
	
	GNS->GNS_FILIAL := xFilial("GNS")
	
	MsUnlock()
	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GNS", .F.)
	DbDelete()
	MsUnlock()
Endif

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_VLDACF � Autor �Mario Arizono          � Data � 27/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao dos campos.                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VldAcf()
Local aArea   := GetArea()
Local lRet	   := .T.

If Readvar() == "M->GNS_CODPRO"
 If !(lRet := HS_SeekRet("SB1", "M->GNS_CODPRO", 1, .F., "GNS_DESCRI", "B1_DESC",, .F.))
  HS_MsgInf(STR0007, STR0008, STR0009)  //"C�digo do produto inv�lido."###"Aten��o"###"Valida��o produto."
 EndIf

ElseIf Readvar() == "M->GNS_UNPRES"
	If !(lRet := HS_SeekRet("SAH", "M->GNS_UNPRES", 1, .F., "GNS_DESUNP", "AH_UMRES",, .F.))
  HS_MsgInf(STR0010, STR0008, STR0011)  //"C�digo da unidade de consumo da prescri��o inv�lida."###"Aten��o"###"Valida��o unidade."
 Else 
  If !Empty(M->GNS_UNFATU) .And. M->GNS_UNPRES == M->GNS_UNFATU
   HS_MsgInf(STR0012, STR0008, STR0011)  //"Unidade escolhida j� esta cadastrada na unidade de consumo do faturamento."###"Aten��o"###"Valida��o unidade."
   lRet := .F.
  Endif
 Endif
ElseIf Readvar() == "M->GNS_UNFATU"
 If !(lRet := HS_SeekRet("SAH", "M->GNS_UNFATU", 1, .F., "GNS_DESUFA", "AH_UMRES",, .F.))
  HS_MsgInf(STR0013, STR0008, STR0011)  //"C�digo da unidade de consumo do faturamento inv�lido."###"Aten��o"###"Valida��o unidade."
 Else
  If !Empty( M->GNS_UNPRES) .And. M->GNS_UNFATU == M->GNS_UNPRES 
   HS_MsgInf(STR0014, STR0008, STR0011)  //"Unidade escolhida j� esta cadastrada na unidade de consumo da prescri��o."###"Aten��o"###"Valida��o unidade."
   lRet := .F.
  Endif
 Endif
Endif

RestArea(aArea)
Return(lRet)           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_VldOk  � Autor �Mario Arizono          � Data � 27/05/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao de cadastros iguais.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_VldOk()
Local aArea   := GetArea()
Local lRet	   := .T.

If StrZero(nOpcE, 2) $ "03/04" 
 If HS_CountTB("GNS", "GNS_CODPRO  = '" + M->GNS_CODPRO + "' AND GNS_UNPRES  = '" + M->GNS_UNPRES + "' AND GNS_UNFATU  = '" + M->GNS_UNFATU + "'")  > 0
		HS_MsgInf(STR0015, STR0008, STR0016)   //"j� existe cadastro com as informa��es cadastradas."###"Aten��o"###"Valida��o inclus�o/altera��o"
		lRet := .F.
	Endif
Endif

RestArea(aArea)
Return(lRet)
