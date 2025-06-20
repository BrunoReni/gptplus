#INCLUDE "HSPAHABD.ch"                                                 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "HSPAHABD.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � HSPAHABD � Autor � Robson Ramiro A. Olive� Data � 09.05.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro Grupo de Equipamentos                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � HSPAHABD(void)                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � HSP                                                        ���
�������������������������������������������������������������������������Ĵ��
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHABD()
Private aRotina := MenuDef()

Private cCadastro := OemToAnsi(STR0006) //"Equipamentos"
Private lFROTA := .F. // Somente para utilizar a consulta do arquivo ST9
DbSelectArea("GF9")
DbSetOrder(1)

mBrowse(06, 01, 22, 75, "GF9")
Return Nil

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � HS_ABDRoti � Autor � Robson Ramiro A.Olivei� Data �09.05.05  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Manutencao dos Dados                             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void HS_ABDRoti(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHABD                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_ABDRoti(cAliasABD, nRegABD, nOpcABD)
 Local oDlg, nOpcDlg := 0
 Local nGDOpc := IIf(StrZero(aRotina[nOpcABD, 4], 2) $ "03/04", (GD_INSERT+GD_UPDATE+GD_DELETE), 0)
 Local oEnGf9, aHGer := {}, aCGer := {}, nUGer := 0

 Private oGdGer, nGerIteGrp := 0, nGerCodEqp := 0

 Private aGets := {}
 Private aTela := {}

 RegToMemory("GF9",(aRotina[nOpcABD,4]==3))

 HS_BDados("GER", @aHGER, @aCGER, @nUGER, 1, M->GF9_CODGRP, Iif(aRotina[nOpcABD, 4]#3, "GER->GER_CODGRP == '"+M->GF9_CODGRP+"'", Nil))

 nGerIteGrp := aScan(aHGER, {|aVet|aVet[2]=="GER_ITEGRP"})
 nGerCodEqp := aScan(aHGER, {|aVet|aVet[2]=="GER_CODEQP"})
 
 If aRotina[nOpcABD, 4] == 3 .Or. Empty(aCGER[1, nGerIteGrp])
  aCGER[1, nGerIteGrp] := Soma1(aCGER[1, nGerIteGrp], Len(aCGER[1, nGerIteGrp]))
 EndIf

 aSize := MsAdvSize(.T.)
 aObjects := {} 
 AAdd(aObjects,{100,030,.T.,.T.}) 
 AAdd(aObjects,{100,070,.T.,.T.}) 
  
 aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) FROM aSize[7],0 TO aSize[6]+25, aSize[5] OF oMainWnd PIXEL //"Grupo de Equipamentos"

  oEnGf9 := MsMGet():New("GF9", nRegABD, nOpcABD,,,,, aPObjs[1])
  oEnGf9:oBox:align := CONTROL_ALIGN_TOP

  oGDGer := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3] + 25, aPObjs[2, 4], nGDOpc,,, "+GER_ITEGRP",,,,,,,, aHGER, aCGER)
  oGDGer:oBrowse:align := CONTROL_ALIGN_ALLCLIENT                                                                                    
  oGDGer:oBrowse:bDelete := {||Iif(FS_VldBDelete("GER"), oGDGer:DELLINE(), .F.)}
  oGDGer:cFieldOk := "HS_VldABD()"

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| nOpcDlg := 1, Iif(Obrigatorio( aGets, aTela).And.oGDGER:TudoOk().And.FS_VldExc(nOpcABD), oDlg:End(), nOpcDlg := 0)},;
                                                   {|| nOpcDlg := 0, oDlg:End()})

 If nOpcDlg == 1
  FS_ABDGrav(nOpcABD, nUGer)
  While __lSx8
   ConfirmSx8()
  End
 Else
  While __lSx8
   RollBackSxe()
  End 
 Endif
Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_VldDel � Autor � Andr� Cruz            � Data � 17.04.07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida��o da exclus�o de equipamento                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �      FS_VldDel( )                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � HSPAHABD                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FS_VldBDelete( cTbl )
 If cTbl == "GER"
  If !oGDGer:aCols[oGDGer:nAt][Len(oGDGer:aCols[oGDGer:nAt])] .AND. HS_CountTB("GET", "GET_CODGRP = '" + M->GF9_CODGRP + "' AND GET_CODEQP = '" + oGDGer:aCols[oGDGer:nAt][nGerCodEqp] + "' ") > 0
   HS_MsgInf(STR0013, STR0009, STR0012) //"Este grupo de equipamentos est� sendo utilizado no cadastro de Cirurgia x Equipamento(GET). Imposs�vel Exclu�-lo!"###"Aten��o"###"Cadastro de Equipamentos"
   Return .F.
  EndIf
 EndIf
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_ABDGrav� Autor � Robson Ramiro A Olivei� Data � 09.05.05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao dos equipamentos                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FS_ABDGrav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � HSPAHABD                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FS_ABDGrav(nOpcABD, nUGer)
 Local nForItens := 0, lFoundGf9 := .F., lFoundGer := .F.

 If aRotina[nOpcABD, 4] <> 2
  Begin Transaction
   DbSelectArea("GF9")
   DbSetOrder(1)         
   
   If aRotina[nOpcABD, 4] == 3 // Incluis�o
    M->GF9_CODGRP := HS_VSxeNum("GF9", "M->GF9_CODGRP", 1)
   Else
    lFoundGf9 := DbSeek(xFilial("GF9") + M->GF9_CODGRP)
   EndIf
   
   If aRotina[nOpcABD, 4] <> 5
    RecLock("GF9", !lFoundGf9)
     HS_GRVCPO("GF9")
     GF9->GF9_FILIAL := xFilial("GF9")
     GF9->GF9_LOGARQ := HS_LogArq()
    MsUnLock()

    DbSelectArea("GER")
    DbSetOrder(1)
    For nForItens := 1 To Len(oGDGer:aCols)
     lFoundGer := DbSeek(xFilial("GER") + M->GF9_CODGRP + oGDGer:aCols[nForItens, nGerIteGrp])
     If !oGDGer:aCols[nForItens, nUGer + 1]
      RecLock("GER", !lFoundGer)
       HS_GRVCPO("GER", oGDGer:aCols, oGDGer:aHeader, nForItens)
       GER->GER_FILIAL := xFilial("GER")
       GER->GER_CODGRP := M->GF9_CODGRP
       GER->GER_LOGARQ := HS_LogArq()
      MsUnlock()
     ElseIf lFoundGer
      RecLock("GER", .F.)
       DbDelete()
      MsUnlock()
      WriteSx2("GER")
     Endif
    Next
   Else 
    If lFoundGf9
     RecLock("GF9", .F.)
      DbDelete()
     MsUnLock() 
     WriteSx2("GF9")
    EndIf 

    For nForItens := 1 To Len(oGDGer:aCols)
     DbSelectArea("GER")
     DbSetOrder(1)
     If DbSeek(xFilial("GER") + M->GF9_CODGRP + oGDGer:aCols[nForItens, nGerIteGrp])
      RecLock("GER", .F.)
       DbDelete()
      MsUnlock()
      WriteSx2("GER")
     Endif
    Next
   EndIf 
  End Transaction
 EndIf
 
 DbSelectArea("GF9")    
Return(Nil)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �HS_ABDLiOk� Autor � Robson Ramiro A. Olive� Data � 09.05.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � HS_ABDLiOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � HSPAHABD                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function HS_VldABD()
 Local lRetorno := .T., nPosACols := 0

 //����������������������������������Ŀ
 //� verifica se ha itens duplicados  �
 //������������������������������������
 
 If ReadVar() == "M->GER_CODEQP"

  If ((nPosACols := aScan(oGDGer:aCols, {| aVet | aVet[nGERCODEQP] == M->GER_CODEQP})) > 0) .And. (nPosACols <> oGDGer:nAt)
   HS_MsgInf(STR0008, STR0009, STR0010) //"Informacao ja cadastrada!"###"Aten��o"###"Consistencia para mudan�a/inclus�o"
   lRetorno := .F.
  Endif
 ElseIf ReadVar() == "M->GER_CODDES"
  If !Empty(M->GER_CODDES) .AND. !(lRetorno := HS_SeekRet("GAA", "M->GER_CODDES", 1, .F., "GER_DDESPE", "GAA_DESC"))
   HS_MsgInf(STR0014, STR0009, STR0010)//"C�digo da taxa/Diar. Inv�lido." "Aten��o" "Valida��o campos"   
 Endif
 Endif
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldExcL� Autor � Daniel Peixoto     � Data �  24/08/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Validacao do DELETE de um Grupo Equip.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_VldExc(nOpc)
 Local aAreaOld   := GetArea()

 If nOpc == 5 // Exclus�o       
  If HS_CountTB("GET", "GET_CODGRP = '" + M->GF9_CODGRP + "'") > 0
   HS_MsgInf(STR0013, STR0009, STR0012) //"Este grupo de equipamentos est� sendo utilizado no cadastro de Cirurgia x Equipamento(GET). Imposs�vel Exclu�-lo!"###"Aten��o"###"Cadastro de Equipamentos"
   Return .F.
  Endif
  If HS_CountTB("GFA", "GFA_CODGRP  = '" + M->GF9_CODGRP + "'") > 0
   HS_MsgInf(STR0011, STR0009, STR0012) //"Este grupo de equipamentos est� sendo utilizado no Cadastro de Procedimentos(GA7).Imposs�vel Exclu�-lo!"###"Aten��o"###"Cadastro de Equipamentos"
   Return .F.
  Endif
 EndIf
 
 RestArea(aAreaOld)
Return .T.


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
Local aRotina :=	{{OemToAnsi(STR0001), "AxPesqui"  , 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0002), "HS_ABDRoti", 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0003), "HS_ABDRoti", 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0004), "HS_ABDRoti", 0, 4, 0, nil},; //"Alterar"
                     {OemToAnsi(STR0005), "HS_ABDRoti", 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)
