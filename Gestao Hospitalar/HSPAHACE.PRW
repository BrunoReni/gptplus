#INCLUDE "HSPAHACE.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHACE  � Autor � Mario Arizono      � Data �  17/04/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de cuidados da prescricao.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHACE()

Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui" , 0, 1}, ;   //"Pesquisar"
                    {OemtoAnsi(STR0002), "HS_MntACE"			, 0, 2}, ;   //"Visualizar"
                    {OemtoAnsi(STR0003), "HS_MntACE"		 , 0, 3}, ;   //"Incluir"
                    {OemtoAnsi(STR0004), "HS_MntACE"		 , 0, 4}, ;  //"Alterar"
                    {OemtoAnsi(STR0005), "HS_MntACE"		 , 0, 5} }   //"Excluir"

If HS_LocTab("GNP") .And. HS_ExisDic({{"C", "GNP_CONTRO"}})
	DbSelectArea("GNP")
	mBrowse(06, 01, 22, 75, "GNP")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_MntACE � Autor � Mario Arizono      � Data �  17/04/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_MntACE(cAlias, nReg, nOpc)
Local nOpcA := 0
Private nOpcE := aRotina[nOpc, 4]
Private aTela 					:= {}
Private aGets      := {}
Private oGNP

RegToMemory("GNP",(nOpcE == 3)) //Gera variavies de memoria para GNP  

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd   //"Cadastro Cuidados da Prescri��o"

oGNP := MsMGet():New("GNP", nReg, nOpcE,,,,, aPObjs[1],,,,,, oDlg)
oGNP:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ValExcl(), .T.), oDlg:End(), nOpcA == 0)}, ;
{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	Begin Transaction
	FS_GrvACE(nReg)
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
���Programa  �FS_GrvACE �Autor  �Mario Arizono       � Data �  17/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para gravacao.                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvACE(nReg)
Local aArea := GetArea()

DbSelectArea("GNP")
If nOpcE <> 3
	DbGoTo(nReg)
Else
 M->GNP_CODCUI := HS_VSxeNum("GNP", "M->GNP_CODCUI", 1)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GNP", (nOpcE == 3))
	HS_GrvCpo("GNP")
	GNP->GNP_FILIAL := xFilial("GNP")
	GNP->GNP_USUARI :=  cUserName
	GNP->GNP_DATUSU := dDataBase      
	GNP->GNP_HORUSU := Time()
	
	MsUnlock()
	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GNP", .F.)
	DbDelete()
	MsUnlock()
Endif

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_VLDACE � Autor �Mario Arizono          � Data � 01/07/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao dos campos.                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VldAce()
Local aArea   := GetArea()
Local lRet	   := .T.
                            
 If ReadVar() == "M->GNP_CODDES"
  If !Empty(M->GNP_CODDES) .AND. !(lRet := HS_SeekRet("GAA", "M->GNP_CODDES", 1, .F., "GNP_DDESPE", "GAA_DESC"))
   HS_MsgInf(STR0010, STR0008, STR0011) //"C�digo da taxa/Diar. Inv�lido."###"Valida��o campos"
  Endif 
 Endif

RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ValExcl� Autor �Mario Arizono          � Data � 17/04/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ValExcl()
Local aArea   := GetArea()
Local lRet	   := .T.
Local lExiDic := HS_EXISDIC({{"C", "GHX_CODCUI"}}, .F.)

If nOpcE == 5 .And. lExiDic
	If HS_CountTB("GHX", "GHX_CODCUI  = '" + M->GNP_CODCUI + "'")  > 0
		HS_MsgInf(STR0007, STR0008, STR0009)   //"Cuidado possui relacionamento com a prescri��o m�dica."###"Aten��o"###"Valida��o exclus�o"
		lRet := .F.
	Endif
Endif

RestArea(aArea)
Return(lRet)
