#INCLUDE "HSPAHA82.ch"
#include "Protheus.ch"
#include "TopConn.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  � HSPAHA82 � Autor � Rodrigo Xavier     � Data �Novembro/2003���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Salas/Equipamentos com a configuracao das da-  ���
���          � tas e horarios de utilizacao.                              ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA82()

 //�����������������������������������������������������������������������Ŀ
 //� Define variaveis privadas                                             �
 //�������������������������������������������������������������������������
 Private aRotina := {{STR0001  , "AxPesqui", 0, 1},; //"Pesquisar"
                     {STR0002 , "HS_A82CAD(2)", 0, 2},; //"Visualizar"
                     {STR0003    , "HS_A82CAD(3)", 0, 3},;  //"Incluir"
                     {STR0004    , "HS_A82CAD(4)", 0, 4},;  //"Alterar"
                     {STR0005    , "HS_A82CAD(5)", 0, 5},;  //"Excluir"
                     {STR0006   , "", 0, 5}} //"Imprimir"
                                   
 
 //�����������������������������������������������������������������������Ŀ
 //� Orcamento de atendimento                                              �
 //�������������������������������������������������������������������������
 DbSelectArea("GCD")
 DbSetOrder(1)

 //�����������������������������������������������������������������������Ŀ
 //� Endereca a funcao de BROWSE                                           �
 //�������������������������������������������������������������������������
 mBrowse( 6, 1, 22, 75, "GCD")
 
 //�����������������������������������������������������������������������Ŀ
 //� Devolve os indices padroes do SIGA.                                   �
 //�������������������������������������������������������������������������
 RetIndex("GCD")
 
Return                         
 
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �HS_A82CAD � Autor � Rodrigo Xavier     � Data �Novembro/2003���
�������������������������������������������������������������������������͹��
���Descricao � Funcao que monta o formulario de cadastro.                 ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A82CAD(nOperacao)
                     
 //�����������������������������������������������������������������������Ŀ
 //� Define variaveis privadas                                             �
 //�������������������������������������������������������������������������
 Local nCodObs := 0
 Local nCodObsF := 0    
 Local nReg := RecNo()
 Local nInt := 0
 Local lGravou := .F.
 Local nOpca := 0
 
 //����������������������������	�������������������������������������������Ŀ
 //� Define variaveis privadas                                             �
 //�������������������������������������������������������������������������
 Private cCadastro := STR0007 //"Cadastro de Salas Ambulatoriais"
 Private oGetDados                    
 Private aHeader := {} 
 Private aCols := {}                
 Private aColsTemp := {}
 Private nUsado := 0                 
 Private aVisual := {}                   

 Private nGCF_SALA    := 0
 Private nGCF_ITEM    := 0
 Private nGCF_SEMANA  := 0
 Private nGCF_HORINI  := 0
 
 Private cFieldOk := "HS_A82COK()"
 Private cTudoOk  := "HS_A82TOK()"
 
 //�����������������������������������������������������������������������Ŀ
 //� Cria Variaveis de Memoria da Enchoice                                 �
 //�������������������������������������������������������������������������
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GCD")
 While ( !Eof() .And. (SX3->X3_ARQUIVO == "GCD") )
  cCampo:= SX3->X3_CAMPO
  If SX3->(X3USO(X3_USADO)) .And. cNivel >= X3_NIVEL //.And. !(AllTrim(X3_CAMPO) $ "GCD_")
   AADD(aVisual,SX3->X3_CAMPO)
   If ( SX3->X3_CONTEXT == "V"  .Or. Inclui )
    M->&(cCampo):= CriaVar(SX3->X3_CAMPO)
   Else
    M->&(cCampo):= GCD->(FieldGet(FieldPos(SX3->X3_CAMPO)))
   EndIf
  EndIf
  DbSelectArea("SX3")
  DbSkip()
 EndDo
                                                                              
 //��������������������������������������������������������������Ŀ
 //� Monta o Array aHeader.                                       �
 //����������������������������������������������������������������
 DbSelectArea("SX3")             
 DbSetOrder(1)
 DbSeek("GCF")           
 While !Eof() .and. SX3->X3_ARQUIVO == "GCF"  
  If SX3->X3_CAMPO == "GCF_FILIAL" .Or. SX3->X3_CAMPO == "GCF_SALA" .Or. ;
     SX3->X3_CAMPO == "GCF_ITEM" .Or. SX3->X3_CAMPO == "GCF_PONTAT"
   DBSkip()
   Loop
  EndIf
  If SX3->X3_CONTEXT == "V" .And. SX3->X3_TIPO == "M"
   If (nCodObs := AT("GCF_", SX3->X3_RELACAO)) > 0
    nCodObsF := At(",", SX3->X3_RELACAO)
    If nCodObsF == 0
     nCodObsF := At(")", SX3->X3_RELACAO)
    EndIf 
    nCodObsF := nCodObsF - (nCodObs - 1) - 1
    aAdd(aMemos, {Upper(AllTrim(SubStr(SX3->X3_RELACAO, nCodObs, nCodObsF))), AllTrim(SX3->X3_CAMPO)})
   EndIf 
  EndIf 
  If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. SX3->X3_BROWSE == "S"
   nUsado++     
   Aadd(aHeader,{Trim(X3Titulo()),;
    SX3->X3_CAMPO,;
    SX3->X3_PICTURE,;
    SX3->X3_TAMANHO,;
    SX3->X3_DECIMAL,;           
    SX3->X3_VALID,;
    SX3->X3_USADO,;
    SX3->X3_TIPO,;
    SX3->X3_ARQUIVO,;
    SX3->X3_CONTEXT,;
    SX3->X3_RELACAO,;
    SX3->X3_RESERV })
  EndIf
  DbSkip()
 End                       
  
 //�����������������������������������������������������������������������Ŀ
 //� Monta o Array aCols                                                   �
 //�������������������������������������������������������������������������
 dbSelectArea("GCF")
 dbSetOrder(1)
 If DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM)
  While !Eof() .And. GCF->GCF_FILIAL + GCF->GCF_SALA + GCF->GCF_PONTAT + GCF->GCF_ITEM == xFilial("GCF") + ;
                      GCD->GCD_SALA + GCD->GCD_PONTAT + GCD->GCD_ITEM
   AADD(aCols, Array(nUsado + 1))
   For nInt := 1 to nUsado
    aCols[Len(aCols),nInt] := IIf(aHeader[nInt,10] # "V", FieldGet(FieldPos(aHeader[nInt,2])),;
                               CriaVar(aHeader[nInt,2]))
   Next
   If nOperacao != 3
    aCols[Len(aCols),Len(aCols[1])] := .F.
   EndIf
   dbSkip()
  Enddo
 EndIf  
 
 If aCols == {}
  aAdd(aCols, Array(Len(aHeader)+1))
  For nInt := 2 to Len(aHeader)+1
   aCols[Len(aCols)][nInt] := CriaVar(aHeader[nInt-1][2])     
  Next           
  aCols[Len(aCols),Len(aCols[1])] := .T.
 EndIf

 nGCF_SEMANA  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GCF_SEMANA"})
 nGCF_HORINI  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GCF_HORINI"})
                  
 aColsTemp := aClone(aCols)
 
 If nOperacao != 3
  M->GCD_DESCAT := POSICIONE("GCE", 1, xFilial("GCE") + GCD->GCD_PONTAT, "GCE_DESC")
 EndIf                   
                                                 
 //�����������������������������������������������������������������������Ŀ
 //� Monta o formulario                                                    �
 //�������������������������������������������������������������������������     
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )      
 
  
  DEFINE MSDIALOG oDlgCadastro TITLE cCadastro From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd  
  
  oEnchoi := MsMGet():New("GCD",nReg,nOperacao,,,,aVisual,aPObjs[1],,3,,,,oDlgCadastro,,.T.) 
  oEnchoi :oBox:align:= CONTROL_ALIGN_TOP   
  
  oGetDados:= MSGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nOperacao,,,"",.T.,,,,,,,,, oDlgCadastro)        
  oGetDados:oBrowse:align := CONTROL_ALIGN_ALLCLIENT   
  
 ACTIVATE MSDIALOG oDlgCadastro ON INIT EnchoiceBar(oDlgCadastro, {|| nOpca := 0, IIf(&cTudoOk, oDlgCadastro:End(), nOpca := 1)},{|| nOpca := 1,oDlgCadastro:End()})

 If (nOpca == 0)
  Begin Transaction
   lGravou := HS_A82GRV(nOperacao)   
   If lGravou
    commit
   Else
    If __lSx8
     RollBackSx8()
    EndIf		   
   EndIf
  End Transaction
 EndIf
                     
Return
             
                                   
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �HS_A82COK � Autor � Rodrigo Xavier     � Data �Novembro/2003���
�������������������������������������������������������������������������͹��
���Descricao � Valida os campos.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A82COK()   

 //�����������������������������������������������������������������������Ŀ
 //� Definicao das variaveis locais                                        �
 //�������������������������������������������������������������������������
 Local aArea := GetArea()

 //�����������������������������������������������������������������������Ŀ
 //� Se for o campo M->GCD_ITEM                                            �
 //�������������������������������������������������������������������������
 If ReadVar() == "M->GCD_ITEM"    
  DBSelectArea("GCD")
  DBSetOrder(1)
  If DBSeek(xFilial("GCD") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM)
   HS_MsgInf(STR0008, STR0009, STR0011) //"Este item ja esta cadastrado!"###"Atencao!"###"Valida��o dos Campos"
   RestArea(aArea)
   Return .F.                  
  EndIf

 //�����������������������������������������������������������������������Ŀ
 //� Se for o campo M->GCD_SALA                                            �
 //�������������������������������������������������������������������������
 ElseIf ReadVar() == "M->GCD_SALA"
  DBSelectArea("GCD")
  DBSetOrder(1)
  If DBSeek(xFilial("GCD") + M->GCD_SALA)
   M->GCD_DESC := GCD->GCD_DESC
   RestArea(aArea)
   Return .T.                                      
  Else
   M->GCD_DESC := Space(Len(GCD->GCD_DESC)) 
  EndIf

 //�����������������������������������������������������������������������Ŀ
 //� Se for o campo M->GCD_PONTAT                                          �
 //�������������������������������������������������������������������������
 ElseIf ReadVar() == "M->GCD_PONTAT"
  If !ExistCpo("GCE")
   Return .F.                  
  Else
   M->GCD_DESCAT := POSICIONE("GCE", 1, xFilial("GCE") + M->GCD_PONTAT, "GCE_DESC")
  EndIf

 EndIf
             
Return .T.            


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �HS_A82GRV � Autor � Rodrigo Xavier     � Data �Novembro/2003���
�������������������������������������������������������������������������͹��
���Descricao � Grava as informacoes.                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/       

Function HS_A82GRV(nOper)   

 //�����������������������������������������������������������������������Ŀ
 //� Definicao das variaveis locais.                                       �
 //�������������������������������������������������������������������������
 Local nRegistro := 0
 Local nInt := 0
 
 //�����������������������������������������������������������������������Ŀ
 //� Grava as informacoes da Enchoice.                                     �
 //�������������������������������������������������������������������������
 If nOper == 3
  RecLock("GCD",.T.)        
 ElseIf nOper == 4
  RecLock("GCD",.F.)
 EndIf   

 //�����������������������������������������������������������������������Ŀ
 //� Inclusao ou Alteracao.                                                �
 //�������������������������������������������������������������������������
 If nOper == 3 .Or. nOper == 4
  HS_GRVCPO("GCD")
  GCD->GCD_FILIAL := xFilial("GCD")
  GCD->GCD_STATUS := "0"
  MsUnlock()
  If __lSx8
   ConfirmSX8()
  EndIf
  //�����������������������������������������������������������������������Ŀ
  //� Exclusao.                                                             �
  //�������������������������������������������������������������������������
 ElseIf nOper == 5
  nRegistro := RecNo()
  DBSelectArea("GCF")
  DBSetOrder(1)
  DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM)
  While !Eof() .And. GCF->GCF_SALA == M->GCD_SALA .And. GCF->GCF_ITEM == M->GCD_ITEM .And. ;
        M->GCD_PONTAT == GCF->GCF_PONTAT
   RecLock("GCF")
    DBDelete()
   MsUnlock()
   DBSkip()
  EndDo  
  DBSelectArea("GCD")
  DBSetOrder(1)
  DBGoto(nRegistro)
  RecLock("GCD")
   DBDelete()
  MsUnlock()
 EndIf

 //�����������������������������������������������������������������������Ŀ
 //� Grava as informacoes da GetDados.                                     �
 //�������������������������������������������������������������������������
 DbSelectArea("GCF")
 DBSetOrder(1)
 If nOper == 3 .Or. nOper == 4
  For nInt := 1 to Len(aCols)
   If nInt > Len(aColsTemp)  
    wProcura := DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM + ;
                       aCols[nInt,nGCF_SEMANA] + aCols[nInt,nGCF_HORINI])
   Else
    wProcura := DBSeek(xFilial("GCF") + M->GCD_SALA + M->GCD_PONTAT + M->GCD_ITEM + ;
                       aColsTemp[nInt,nGCF_SEMANA] + aColsTemp[nInt,nGCF_HORINI])
   EndIf
   If aCols[nInt, Len(aCols[nInt])] .And. wProcura 
    RecLock("GCF")
     dbdelete()
    MsUnlock()
    WriteSx2("GCF")
   Else
    If !wProcura 
     RecLock("GCF",.T.)        
    ElseIf wProcura 
     RecLock("GCF",.F.)
    EndIf   
    If !aCols[nInt,Len(aCols[nInt])]  
     HS_GRVCPO("GCF", aCols, aHeader, nInt)
      GCF->GCF_FILIAL := xFilial("GCF")
      GCF->GCF_SALA   := M->GCD_SALA
      GCF->GCF_PONTAT := M->GCD_PONTAT
      GCF->GCF_ITEM   := M->GCD_ITEM
     MsUnlock()
     If __lSx8
      ConfirmSX8()
     EndIf
    Endif
   Endif                             
  Next
 EndIf
 
Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �HS_A82TOK � Autor � Rodrigo Xavier     � Data �Novembro/2003���
�������������������������������������������������������������������������͹��
���Descricao � Valida tudo antes de fechar o programa.                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_A82TOK()                                 
 If Empty(M->GCD_SALA) .Or. Empty(M->GCD_PONTAT) .Or. Empty(M->GCD_ITEM)
  HS_MsgInf(STR0010, STR0009, STR0011)  //"Todos os campos obrigatorios devem ser preenchidos."###"Atencao!"###"Valida��o dos Campos"
  Return .F.
 EndIf
Return .T.
