#INCLUDE "hspaha78.ch"
#include "protheus.CH"
#include "TopConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA78  � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Posicao Profissional                           ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ�� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA78()
 Private cCadastro := STR0001 //"Posicao Profissional"
 Private aRotina   := {{OemToAnsi(STR0002), "axPesqui", 0, 1} ,;    //"Pesquisar"
                       {OemToAnsi(STR0003), "HS_A78"  , 0, 2} ,;    //"Visualizar"
                       {OemToAnsi(STR0004), "HS_A78"  , 0, 3} ,;    //"Incluir"
                       {OemToAnsi(STR0005), "HS_A78"  , 0, 4} ,;    //"Alterar"
                       {OemToAnsi(STR0006), "HS_A78"  , 0, 5} }    //"Excluir"

 DbSelectArea("G18")
 mBrowse(06, 01, 22, 75, "G18")

Return()            	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A78    � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A78(cAlias, nReg, nOpc)
 Local nGDOpc := IIf(aRotina[nOpc, 4] == 3 .or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcG  := aRotina[nOpc, 4]
 Local nOpcA  := 0 
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
                
 Private aTela := {}, aGets := {}
 Private oG18
 
 RegToMemory("G18", nOpcG == 3)
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oG18 := MsMGet():New("G18", nReg, nOpc	,,,,, aPObjs[1],, 2)
  oG18:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )

 If nOpcA == 1
  FS_GrvA78(nOpcG)
 Endif

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA78 � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Atualizacao do cadastro                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvA78(nOpcG)
 Local lAchou      := .T.

 If nOpcG == 2     // Se for uma consulta
  Return(.T.)
 Endif 

 Begin Transaction
  DbselectArea("G18")  
  DbsetOrder(1)
  lAchou := DbSeek(xFilial("G18") + M->G18_CODIGO) 
 
  If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
   RecLock("G18", !lAchou)
    HS_GRVCPO("G18")
    G18->G18_FILIAL  := xFilial("G18")
   MsUnlock()
  Else                             // EXCLUSAO
   RecLock("G18", .F., .T.)
    DbDelete()
   MsUnlock()
   WriteSx2("G18") 
  Endif
 
 End Transaction                      
 
Return(Nil)
