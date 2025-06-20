#INCLUDE "HSPAHAB6.ch"
#include "protheus.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAB6  � Autor � Marcelo Jose       � Data �  03/01/06   ���
�������������������������������������������������������������������������͹��
���Descricao � TIPO DE LIVRO                                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAB6()
 Private aRotina := {}, cCadastro := STR0001 //"Cadastro de TIPO DE LIVRO"
                       
 aRotina := MenuDef()

 DbSelectArea("GEC")
 DbSetOrder(1)
                   
 mBrowse(06, 01, 22, 75, "GEC")
 
Return(Nil)
/*****************************************************************************************************************/                                      
Function HS_MntAB6(nOpc)
 Local nOpcA   := 0, nGDOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 Local bCampo  := { |nCPO| Field(nCPO) }
 Local nCntFor := 1, aCpoEnc := {}
 Local cCampo  := Space(100), oCbx, aCbx := {}, aSix := {}, cOrd := "", oBigGet       
                 
 Private aTela := {}, aGets := {}, nOpcE := 0
 Private aCGFO	:= {}, aHGFO := {}, nUGFO := 0, nLGFO := 0
 Private oEscolhe,oGFO, oFolder, pForACols := 0
 
 RegToMemory("GEC", Inclui)

 HS_BDados("GFO", @aHGFO, @aCGFO, @nUGFO, 1, M->GEC_TIPO, IIf(nOpc # 3, "GFO->GFO_CODTIP == '" + M->GEC_TIPO +"'", Nil))
 nGFO_CodLis := aScan(aHGFO, {| aVet | aVet[2] == "GFO_CODLIS"})
 nGFO_Descri := aScan(aHGFO, {| aVet | aVet[2] == "GFO_DESCRI"})
  
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 030, .T., .T. } )	
 AAdd( aObjects, { 100, 070, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 DbSelectArea("GEC")
 nOpcA := 0  
     
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
 
  oEncGEC := MsMGet():New("GEC", aCpoEnc, nOpc,,,,, aPObjs[1],, 2,,,, oDlg) 
  oEncGEC:oBox:Align := CONTROL_ALIGN_TOP 
 
  oGFO := MsNewGetDados():New(aPObjs[2, 1],aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,,,,,,oDlg, aHGFO, aCGFO)  
  oGFO:oBrowse:align := CONTROL_ALIGN_ALLCLIENT    
   
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGFO:TudoOk() .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)}, ;
                                                            {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1
  Begin Transaction 
   FS_GrvAB6(nOpc)
  End Transaction
 EndIf
 
Return(Nil)
/*****************************************************************************************************************/
Static Function FS_GrvAB6(nOpc)
 Local lAchou := .F.
 Private pForaCols := 0

 If nOpc # 2 /* nao for consulta */
  DbSelectArea("GEC")  
  DbsetOrder(1)
  lAchou := DbSeek(xFilial("GEC") + M->GEC_TIPO )
  If Inclui .Or. Altera
   RecLock("GEC", If(lAchou, .F., .T.))
    HS_GRVCPO("GEC")
    GEC->GEC_FILIAL := xFilial("GEC")
		 MsUnLock() 
  Else  /* exclusao */
   RecLock("GEC", .F., .T.)
    dbdelete()
   MsUnlock()
   WriteSx2("GEC")
  EndIf
                  
  FS_GrvRel("GFO", 1, "M->GEC_TIPO + oGFO:aCols[pForaCols, nGFO_CodLis]", oGFO ,nGFO_CodLis)                 
 EndIf
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvRel � Autor � Marcelo Jose       � Data �  06/01/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Grava arquivos de relacionamento                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvRel(cAlias, nOrd, cChave, oGrv,nPos)
 Local nItem 				:= 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
 Local cAliasOld := Alias()

 For nItem := 1 To Len(oGrv:aCols)
  pForaCols := nItem
  DbSelectArea(cAlias)
  DbSetOrder(nOrd)
  lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
  If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou /* exclusao */
   RecLock(cAlias, .F., .T.)
   DbDelete()
   MsUnlock()
   WriteSx2(cAlias)
  Else                             
   If Inclui .Or. Altera
    If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]
     RecLock(cAlias, !lAchou)
     HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
     &(cPref + "_FILIAL") := xFilial(cAlias)
     &(cPref + "_CODTIP") := M->GEC_TIPO     
     &(cPref + "_LOGARQ") := HS_LogArq()
     MsUnlock()                  
    Endif 
   Endif
  EndIf 
 Next
 
 DbSelectArea(cAliasOld)
Return() 
/************************************************************************************************************/
Function HS_ValAB6()
 Local lAchou := .F., lRet := .F.
  
  If ReadVar() == "M->GEC_TIPO"
   If DbSeek(xFilial("GEC") + M->GEC_TIPO )   
    HS_MSGINF(STR0007,STR0008,STR0009) //"CODIGO JA CADASTRADO..."###"TIPO DE LIVROS"###"ATENCAO"
   Else
    lRet := .T.
   ENDIF    
  EndIf 
  
  If ReadVar() == "M->GFO_CODLIS"
   If (lAchou := (aScan(aCols, {| aVet | aVet[nGFO_CodLis] == M->GFO_CODLIS .And. !aVet[nUGFO + 1]}) > 0))
    HS_MSGINF(STR0010,STR0011,STR0009) //"CODIGO JA RELACIONADO NO GRID"###"LISTAS"###"ATENCAO"
   Else   
    lRet := HS_SeekRet("GFN","M->GFO_CODLIS",1,.f.,"GFO_DESCRI","GFN_DESCRI",,,.T.) 
   ENDIF   
  EndIf
Return(lRet)  
               

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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"    , 0, 1, 0, nil},; //"Pesquisar"
		             {OemToAnsi(STR0003), "HS_MntAB6(2)", 0, 2, 0, nil},; //"Visualizar"
		             {OemToAnsi(STR0004), 'HS_MntAB6(3)', 0, 3, 0, nil},; //"Incluir"
		             {OemToAnsi(STR0005), 'HS_MntAB6(4)', 0, 4, 2, nil},; //"Alterar"
		             {OemToAnsi(STR0006), 'HS_MntAB6(5)', 0, 5, 1, nil}}  //"Excluir" 
Return(aRotina)