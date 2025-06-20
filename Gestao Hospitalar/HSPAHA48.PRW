#INCLUDE "hspaha48.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
                      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA48  � Autor � Patricia Queiroz   � Data �  07/11/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro Formas de Recrutamento                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA48()

 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui", 0, 1}, ;   //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_A48"		, 0, 2}, ;   //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_A48"		, 0, 3}, ;   //"Incluir"
                      {OemtoAnsi(STR0004), "HS_A48"		, 0, 4}, ;   //"Alterar"
                      {OemtoAnsi(STR0005), "HS_A48"		, 0, 5}}     //"Excluir"
                      
 DbselectArea("GGT")                     
                    
 mBrowse(06, 01, 22, 75, "GGT") 
 
Return(Nil)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A48    � Autor � Patricia Queiroz   � Data �  07/11/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_A48(cAlias, nReg, nOpc)   

 Local nOpcA := 0

 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private oGGT
 
 RegToMemory("GGT", (aRotina[nOpc, 4] == 3)) 

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd   //"Formas de Recrutamento"

 oGGT := MsMGet():New("GGT", nReg, nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGGT:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(aRotina[nOpc, 4] == 5, FS_ValEx(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. aRotina[nOpc, 4] <> 2
  Begin Transaction
   FS_GrvA48(nOpc)
  End Transaction 
  While __lSx8
   ConfirmSx8()
  EndDo  
 Else
  While __lSx8
   RollBackSx8()
  EndDo     
 EndIf
 
Return(Nil)
 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA48 �Autor  �Patricia Queiroz    � Data �  07/11/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA48(nOpc)

If aRotina[nOpc, 4] == 3 .Or. aRotina[nOpc, 4] == 4 //Incluir e Alterar
 If aRotina[nOpc, 4] == 3
  M->GGT_CDFORE := HS_VSxeNum("GGT", "M->GGT_CDFORE", 1)                     	
 EndIf 
 RecLock("GGT", (aRotina[nOpc, 4] == 3))
 HS_GrvCpo("GGT")
 MsUnlock()	
ElseIf aRotina[nOpc, 4] == 5 //Excluir
 RecLock("GGT", .F.)
 DbDelete()
 MsUnlock()
EndIf

Return(.T.)  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValEx  �Autor  �Patricia Queiroz    � Data �  07/11/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validar a exclusao.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                           
Static Function FS_ValEx()

Local aArea := GetArea()
Local lRet	 := .T.

If HS_CountTB("GBH", "GBH_CDFORE = '" + GGT->GGT_CDFORE + "'") > 0
	HS_MsgInf(STR0007, STR0008, STR0009)  //"O registro possui relacionamento com o cadastro de Paciente."###"Aten��o"###"Valida��o de Exclus�o"
 lRet := .F.	
EndIf
 
RestArea(aArea)

Return(lRet)