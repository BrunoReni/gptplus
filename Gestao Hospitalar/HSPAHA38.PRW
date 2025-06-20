#INCLUDE "HSPAHA38.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA38  � Autor � Manoel/Jose Roberto� Data �  24/01/02   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE CODIGOS DE BARRAS SECUNDARIOS                  ���
���Alteracao � Daniel Peixoto - Modificado para o Padrao                  ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA38()
 Private aRotina := {}, cCadastro := STR0001 //"Cadastro de Codigo Secundario"
                        
 aRotina := MenuDef()
	             
 DbSelectArea("GAP")
 DbSetOrder(1)
                   
 mBrowse(06, 01, 22, 75, "GAP")
 
Return(Nil)
                                                        

Function HS_MntA38(cAliasA38, nRegA38, nOpcA38)
 Local nOpcA := 0 
 Local aSize := {}
 Local oDlg                

 Private aTela := {}, aGets := {}
                                                     
 RegToMemory("GAP", aRotina[nOpcA38, 4] == 3)

 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6]+25,aSize[5]	PIXEL of oMainWnd
  oEncGap := MsMGet():New("GAP", nRegA38, nOpcA38,,,,,  {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg) 
  oEncGap:oBox:Align := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1
  Begin Transaction 
   FS_GrvA38(nOpcA38)
  End Transaction
 EndIf                                                    
 
Return(Nil)

Static Function FS_GrvA38(nOpcA38)
 Local lAchou := .F.

 If aRotina[nOpcA38, 4] # 2 // nao for consulta
  DbSelectArea("GAP")  
  DbsetOrder(1)
  lAchou := DbSeek(xFilial("GAP") + M->GAP_CODBAR)
  If Inclui .Or. Altera
   RecLock("GAP", !lAchou)
    HS_GRVCPO("GAP")
    GAP->GAP_FILIAL := xFilial("GAP")
		 MsUnLock() 
  Else  // exclusao
   RecLock("GAP", .F., .T.)
    dbdelete()
   MsUnlock()
   WriteSx2("GAP")
  EndIf
 EndIf
Return(.T.)

Function HS_RelA38(cAlias, nReg, nOpc)  
Private cGcsTipLoc := "A" //farmacia

 If !Pergunte("HSPA38",.T.)
 	Return(Nil)
 EndIf
 	
 GDN->(dbSetOrder(1))
 If GDN->(DbSeek(xFilial("GDN") + MV_PAR01))
  HSPAHP44(.F., MV_PAR01)
 EndIf 
 
Return


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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},;	//"Pesquisar"
	             	 {OemToAnsi(STR0003), "HS_MntA38", 0, 2, 0, nil},;	//"Visualizar"
	             	 {OemToAnsi(STR0004), "HS_MntA38", 0, 3, 0, nil},;	//"Incluir"
	             	 {OemToAnsi(STR0005), "HS_MntA38", 0, 4, 0, nil},;	//"Alterar"
	             	 {OemToAnsi(STR0006), "HS_MntA38", 0, 5, 0, nil},;	//"Excluir"
		             {OemtoAnsi(STR0007), "HS_RelA38", 0, 2, 0, nil}}	//"Docs/Relat." 
Return(aRotina)