#INCLUDE "HSPAHA60.ch"
#include "protheus.CH"
#include "TopConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA60  � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tipo de Atendimento                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ�� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA60()
 Private cCadastro := STR0001 //"Tipo de Atendimento"
 Private aRotina   := {{OemToAnsi(STR0002), "axPesqui", 0, 1} ,;    //"Pesquisar"
                       {OemToAnsi(STR0003), "HS_A60"  , 0, 2} ,;    //"Visualizar"
                       {OemToAnsi(STR0004), "HS_A60"  , 0, 3} ,;    //"Incluir"
                       {OemToAnsi(STR0005), "HS_A60"  , 0, 4} ,;    //"Alterar"
                       {OemToAnsi(STR0006), "HS_A60"  , 0, 5} }    //"Excluir"

 DbSelectArea("G08")
 mBrowse(06, 01, 22, 75, "G08")

Return()            	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A60    � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A60(cAlias, nReg, nOpc)
 Local nGDOpc := IIf(aRotina[nOpc, 4] == 3 .or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcG  := aRotina[nOpc, 4]
 Local nOpcA  := 0 
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
                
 Private aTela := {}, aGets := {}
 Private oG08
 
 RegToMemory("G08", nOpcG == 3)
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oG08 := MsMGet():New("G08", nReg, nOpc	,,,,, aPObjs[1],, 2)
  oG08:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )

 If nOpcA == 1
  FS_GrvA60(nOpcG)
 Endif

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA60 � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Atualizacao do cadastro                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvA60(nOpcG)
 Local lAchou      := .T.

 If nOpcG == 2     // Se for uma consulta
  Return(.T.)
 Endif 

 Begin Transaction
  DbselectArea("G08")  
  DbsetOrder(1)
  lAchou := DbSeek(xFilial("G08") + M->G08_CODIGO) 
 
  If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
   RecLock("G08", !lAchou)
    HS_GRVCPO("G08")
    G08->G08_FILIAL  := xFilial("G08")
   MsUnlock()
  Else                             // EXCLUSAO
   RecLock("G08", .F., .T.)
    DbDelete()
   MsUnlock()
   WriteSx2("G08") 
  Endif
 
 End Transaction                      
 
Return(Nil)
