#INCLUDE "HSPAHA52.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA52  � Autor � Bruno S. P. Santos � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Justificativa de Glosa                         ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA52()                                                         

 Local aTabela := {{"T", "GG9"}}

 Private aRotina := {{OemtoAnsi(STR0001), "axPesqui" , 0, 1}, ; //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_A52"	 , 0, 2}, ; //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_A52"	 , 0, 3}, ; //"Incluir"
                      {OemtoAnsi(STR0004), "HS_A52"	 , 0, 4}, ; //"Alterar"
                      {OemtoAnsi(STR0005), "HS_A52"	 , 0, 5} }  //"Excluir"

 If HS_ExisDic(aTabela) 
 	DbSelectArea("GG9") 
 	mBrowse(06, 01, 22, 75, "GG9")
 EndIf
Return(nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A52    � Autor � Bruno S. P. Santos � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A52(cAlias, nReg, nOpc)
 Local nOpcA      := 0
 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela    := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGG9

 RegToMemory("GG9",(nOpcE == 3)) //Gera variavies de memoria para o GG9

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Justificativa de Glosa"

 oGG9 := MsMGet():New("GG9", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGG9:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ExclGG9(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 0
  While __lSX8 
   RollBackSXE()
  End
 ElseIf (nOpcA == 1 .And. nOpcE # 2)
  Begin Transaction
 	 FS_GrvA52(nReg)
  End Transaction  
  While __lSX8
   ConfirmSX8()
  End
 EndIf
Return(nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA52 �Autor  � Bruno S. P. Santos � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA52(nReg)
Local aArea := GetArea()

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GG9", (nOpcE == 3))
	HS_GrvCpo("GG9")
	MsUnlock()	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GG9", .F.)
	DbDelete()
	MsUnlock()  
 WriteSx2("GG9")	
Endif                   

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ExclGG9� Autor �Bruno S. P. Santos     � Data � 18/04/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ExclGG9()
Local aArea := GetArea()
Local lRet	 := .T.

If (HS_CountTB("GF5", "GF5_CDJGLO = '" + M->GG9_CDJGLO + "'")  > 0) 
 HS_MsgInf(STR0007, STR0010, STR0011) //"Justificativa da Glosa possui relacionamento com o extrato<Mat/Med>."###"Aten��o"###"Valida��o da Exclus�o"
	lRet := .F.
elseif (HS_CountTB("GF6", "GF6_CDJGLO = '" + M->GG9_CDJGLO + "'")  > 0) 
 HS_MsgInf(STR0008, STR0010, STR0011) //"Justificativa da Glosa possui relacionamento com o extrato<Tax/Dia>."###"Aten��o"###"Valida��o da Exclus�o"
	lRet := .F.
elseif (HS_CountTB("GF7", "GF7_CDJGLO = '" + M->GG9_CDJGLO + "'")  > 0)                                                                  
 HS_MsgInf(STR0009, STR0010, STR0011) //"Justificativa da Glosa possui relacionamento com o extrato<Pro/Hon>."###"Aten��o"###"Valida��o da Exclus�o"
	lRet := .F.
Endif                                                                   
                                                                                                                      
RestArea(aArea)
Return(lRet)                    