#INCLUDE "HSPAHA36.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA36  � Autor � Patricia Queiroz   � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tipo de Amostras                               ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA36()

 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui", 0, 1}, ; //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_A36"		, 0, 2}, ; //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_A36"		, 0, 3}, ; //"Incluir"
                      {OemtoAnsi(STR0004), "HS_A36"		, 0, 4}, ; //"Alterar"
                      {OemtoAnsi(STR0005), "HS_A36"		, 0, 5}}   //"Excluir"
                      
 mBrowse(06, 01, 22, 75, "GGG") 
 
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A36    � Autor � Patricia Queiroz   � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_A36(cAlias, nReg, nOpc)   

 Local nOpcA := 0

 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGGG
 Private lGDVazio := .F.
 
 RegToMemory("GGG", (nOpcE == 3)) 

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Tipo de Amostras"

 oGGG := MsMGet():New("GGG", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGGG:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(nOpcE == 5, FS_ValEx(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                      {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
  Begin Transaction
   FS_GrvA36(nOpcE)
  End Transaction 
 EndIf
 
Return(Nil)
 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA36 �Autor  �Patricia Queiroz    � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA36(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
 RecLock("GGG", (nOpcE == 3))
 HS_GrvCpo("GGG")
 MsUnlock()	
ElseIf nOpcE == 5 //Excluir
 RecLock("GGG", .F.)
 DbDelete()
 MsUnlock()
EndIf

Return(nOpcE)  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValEx  �Autor  �Patricia Queiroz    � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validar a exclusao.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                           
Static Function FS_ValEx()

Local aArea := GetArea()
Local lRet	 := .T.

If HS_CountTB("GGL", "GGL_CDTIPA = '" + GGG->GGG_CDTIPA + "'") > 0
	HS_MsgInf(STR0007, STR0008, STR0009)  //"O registro possui relacionamento com Procedimento"###"Aten��o"###"Valida��o de Exclus�o"
 lRet := .F.	
EndIf
 
RestArea(aArea)

Return(lRet) 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldA36 �Autor  �Patricia Queiroz    � Data �  04/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Validacao dos campos                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/          
Function HS_VldA36()

Local aArea := GetArea()
Local lRet  := .T.

If ReadVar() == "M->GGG_CDTIPA"
 If HS_CountTB("GGG", "GGG_CDTIPA = '" + M->GGG_CDTIPA + "'") > 0
 	HS_MsgInf(STR0010, STR0008, STR0011)  //"Este c�digo j� existe"###"Aten��o"###"Valida��o de Inclus�o"
  lRet := .F.	
 EndIf
EndIf  

If ReadVar() == "M->GGG_HORVAL"
 If M->GGG_HORVAL > 24
  HS_MsgInf(STR0012, STR0008, STR0011) //"O hor�rio n�o pode ultrapassar 24 horas."###"Aten��o"###"Valida��o de Inclus�o"  
  lRet := .F.	
 EndIf
EndIf

RestArea(aArea)

Return(lRet)