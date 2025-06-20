#INCLUDE "HSPAHA21.ch"
#include "protheus.CH"
#include "TopConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA21  � Autor � Daniel Peixoto     � Data �  19/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Taxa/Diarias                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA21()
Private cCadastro := STR0001 //"Cadastro de Taxas/Diarias"
Private aRotina   := MenuDef()


DbSelectArea("GAA")
mBrowse(06, 01, 22, 75, "GAA")

Return()  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A21    � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A21(cAlias, nReg, nOpc)
 Local nGDOpc := IIf(aRotina[nOpc, 4] == 3 .or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcG  := aRotina[nOpc, 4]
 Local nOpcA  := 0 
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
                
 Private aTela := {}, aGets := {}
 Private oGaa
 
 RegToMemory("GAA", nOpcG == 3)
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oGAA := MsMGet():New("GAA", nReg, nOpc	,,,,, aPObjs[1],, 2)
  oGAA:oBox:Align := CONTROL_ALIGN_ALLCLIENT
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .And. IIF(nOpc == 5, FS_VldExcl(), .T.), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )

 If nOpcA == 1
  FS_GrvA21(nOpcG)
 Endif

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA21 � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Atualizacao do cadastro                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvA21(nOpcG)
 Local lAchou      := .T.

 If nOpcG == 2     // Se for uma consulta
  Return(.T.)
 Endif 

 Begin Transaction
  DbselectArea("GAA")  
  DbsetOrder(1) //GAA_FILIAL + GAA_CODTXD
  lAchou := DbSeek(xFilial("GAA") + M->GAA_CODTXD) 
 
  If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
   RecLock("GAA", !lAchou)
    HS_GRVCPO("GAA")
    GAA->GAA_FILIAL  := xFilial("GAA")
   MsUnlock()
  Else                             // EXCLUSAO
   RecLock("GAA", .F., .T.)
    DbDelete()
   MsUnlock()
   WriteSx2("GAA") 
  Endif
 
 End Transaction                      
 
Return(Nil)

Function HS_VldA21()
 Local lRet := .T., cAreaOld := GetArea()
 
 If ReadVar() == "M->GAA_CITISS" .AND. !EMPTY(M->GAA_CITISS)
  If !(lRet := HS_SeekRet("G20", "M->GAA_CITISS", 1, .F., "GAA_DCITIS", "G20_DESCRI"))
   HS_MsgInf(STR0007, STR0008, STR0009) //"Classifica��o de Itens n�o cadastrada."###"Aten��o"###"Valida��o dos Campos"
  EndIf
 EndIf 
     
 RestArea(cAreaOld)
Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 06/06/07 ���
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui", 0, 1, 0, nil} ,;   //"Pesquisar"
                     {OemToAnsi(STR0003), "HS_A21"  , 0, 2, 0, nil} ,;   //"Visualizar"
                     {OemToAnsi(STR0004), "HS_A21"  , 0, 3, 0, nil} ,;   //"Incluir"
                     {OemToAnsi(STR0005), "HS_A21"  , 0, 4, 0, nil} ,;   //"Alterar"
                     {OemToAnsi(STR0006), "HS_A21"  , 0, 5, 0, nil} }    //"Excluir"
Return(aRotina)




/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldExcl � Autor � Patricia Queiroz  � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Validacao de exclusao das taxas e diarias                  ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_VldExcl()

 Local lRet     := .T.
 Local aArea    := GetArea()   //falta a tabela nova de diferenciados
 Local cMsgErro := ""
 
 If !(lRet := !(HS_CountTB("GA2", "GA2_CODCPC = '" + M->GAA_CODTXD + "'") > 0))
  cMsgErro := STR0010 //"Taxa/Di�ria possui relacionamento com Procedimento Padr�o."
 ElseIf !(lRet := !(HS_CountTB("GD3", "GD3_CODTXD = '" + M->GAA_CODTXD + "'") > 0))
  cMsgErro := STR0011 //"Taxa/Di�ria possui relacionamento com Tabela de Pre�o."
 ElseIf !(lRet := !(HS_CountTB("GD6", "GD6_CODDES = '" + M->GAA_CODTXD + "'") > 0))  
  cMsgErro := STR0012 //"Taxa/Di�ria possui relacionamento com despesas nos Atendimentos." 
 ElseIf !(lRet := !(HS_CountTB("GE6", "GE6_CODDES = '" + M->GAA_CODTXD + "'") > 0))
  cMsgErro := STR0012 //"Taxa/Di�ria possui relacionamento com despesas nos Atendimentos."   
 ElseIf !(lRet := !(HS_CountTB("GA4", "GA4_CODDES = '" + M->GAA_CODTXD + "' AND GA4_ORIDES IN ('A','B','C','D')") > 0))    
  cMsgErro := STR0013 //"Taxa/Di�ria possui relacionamento com Exce��es." 
 EndIf
 
 If !lRet
  HS_MsgInf(cMsgErro, STR0008, STR0014)  //"Aten��o"###"Valida��o de Exclus�o"
 EndIf
 
 RestArea(aArea)

Return(lRet)

