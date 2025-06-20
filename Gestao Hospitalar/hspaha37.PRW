#INCLUDE "HSPAHA37.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA37  � Autor � Patricia Queiroz   � Data �  13/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Inaptidao                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA37()

 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui", 0, 1}, ;  //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_A37"		, 0, 2}, ;  //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_A37"		, 0, 3}, ;  //"Incluir"
                      {OemtoAnsi(STR0004), "HS_A37"		, 0, 4}, ;  //"Alterar"
                      {OemtoAnsi(STR0005), "HS_A37"		, 0, 5}}    //"Excluir"
                      
 mBrowse(06, 01, 22, 75, "GGN") 
 
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A37    � Autor � Patricia Queiroz   � Data �  13/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_A37(cAlias, nReg, nOpc)   

 Local nOpcA := 0

 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGGN
 
 RegToMemory("GGN", (nOpcE == 3)) 

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Inaptid�o"

 oGGN := MsMGet():New("GGN", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGGN:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA == 0)}, ;
                                                      {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
  Begin Transaction
   FS_GrvA37(nOpcE)
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
���Programa  �FS_GrvA37 �Autor  �Patricia Queiroz    � Data �  13/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA37(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
 If nOpcE == 3
  M->GGN_CDINAP := HS_VSxeNum("GGN", "M->GGN_CDINAP", 1)                     	
 EndIf 
 RecLock("GGN", (nOpcE == 3))
 HS_GrvCpo("GGN")
 MsUnlock()	
ElseIf nOpcE == 5 //Excluir
 RecLock("GGN", .F.)
 DbDelete()
 MsUnlock()
EndIf

Return(nOpcE)  