#INCLUDE "hspaha76.ch"
#include "protheus.CH"
#include "TopConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA76  � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tipo de Guia TISS                              ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ�� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA76()
 Private cCadastro := STR0001 //"Tipo de Guia TISS"
 Private aRotina   := {{OemToAnsi(STR0002), "axPesqui", 0, 1} ,;    //"Pesquisar"
                       {OemToAnsi(STR0003), "HS_A76"  , 0, 2} ,;    //"Visualizar"
                       {OemToAnsi(STR0004), "HS_A76"  , 0, 3} ,;    //"Incluir"
                       {OemToAnsi(STR0005), "HS_A76"  , 0, 4} ,;    //"Alterar"
                       {OemToAnsi(STR0006), "HS_A76"  , 0, 5} }    //"Excluir"

 DbSelectArea("G17")
 mBrowse(06, 01, 22, 75, "G17")

Return()            	

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A76    � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_A76(cAlias, nReg, nOpc)
 Local nGDOpc := IIf(aRotina[nOpc, 4] == 3 .or. aRotina[nOpc, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcG  := aRotina[nOpc, 4]
 Local nOpcA  := 0 
	Local cCpoEnc := ""
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {} 
 Local cCondAtrib := ""
                
 Private aTela := {}, aGets := {}  
	Private aHGN2 := {}, aCGN2 := {}, nUGN2 := 0 
 Private oG17
 
 RegToMemory("G17", nOpcG == 3)

 cCpoEnc := "GN2_CODTGT" //Define os campos que nao deverao ser editados na Getdados 

	nLenGD := HS_BDados("GN2", @aHGN2    ,   @aCGN2,    @nUGN2, 1," ", IIf((nOpc == 3), Nil, "'" + M->G17_CODIGO + "' == GN2->GN2_CODTGT"),.T.,,,,cCpoEnc,.T.)

 nGN2StaReg  := aScan(aHGN2, {| aVet | aVet[2]          == "HSP_STAREG"})
 nGN2_ITETGT := aScan(aHGN2, {| aVet | AllTrim(aVet[2]) == "GN2_ITETGT"})
 nGN2_MODIMP := aScan(aHGN2, {| aVet | AllTrim(aVet[2]) == "GN2_MODIMP"})


 aSize := MsAdvSize(.T.)                                                                                                     
 aObjects := {}	
 AAdd( aObjects, { 100, 040, .T., .T. } )
 AAdd( aObjects, { 100, 060, .T., .T. } )
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0 
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel

 oG17 := MsMGet():New("G17",nReg,nOpc, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oDlg)
 oG17 :oBox:align:= CONTROL_ALIGN_TOP
 
//cCondAtrib := "oGN2:aCols[oGN2:nAt, nGN2_MODIMP] <> oGN2:aCols[__nAtGD, nGN2_MODIMP]"

 If Empty(aCGN2[1, nGN2_ITETGT])
  aCGN2[1, nGN2_ITETGT] := StrZero(1, Len(GN2->GN2_ITETGT))
 EndIf

 oGN2 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,"HS_DuplAc(oGN2:oBrowse:nAt, oGN2:aCols, {nGN2_MODIMP},,.T.)",,"+GN2_ITETGT",,, 99999,,,, oDlg, aHGN2, aCGN2)  

 oGN2:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
 oGN2:oBrowse:bAdd    := {|| oGN2:AddLine(), HS_GDAtrib(oGN2, {{nGN2StaReg, "BR_VERMELHO"}}, 3)}  
 oGN2:cFieldOk        :=    "HS_GDAtrib(oGN2, {{nGN2StaReg, 'BR_AMARELO', 'BR_VERDE'}}, 4)"
 oGN2:oBrowse:bDelete := {|| HS_GDAtrib(oGN2, {{nGN2StaReg, "BR_CINZA", "BR_VERDE"}}, 5), oGN2:DelLine()}  

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. HS_VIA76() .And. oGN2:TudoOK(), oDlg:End(), nOpcA == 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()} )                                                     
                                              
 If nOpcA == 1
  Begin Transaction
  FS_GrvA76(nOpcG)
  End Transaction                      
  
  While __lSx8
   ConfirmSx8()
  EndDo  

 Else
  While __lSx8
   RollBackSx8()
  EndDo            
 Endif

Return()
   

/*************************************  validacao de inclusao  ****************************************************/
Static Function HS_VIA76()
 Local lRet := .T.    
 Local nCtaFor := 0

 For nCtaFor = 1 To Len(oGN2:aCols)
  If oGN2:aCols[oGN2:nAt, nGN2StaReg] <> 'BR_CINZA' .And. !(oGN2:aCols[nCtaFor, nUGN2 + 1])
   If M->G17_MODIMP == oGN2:aCols[nCtaFor, nGN2_MODIMP]
    HS_MsgInf(STR0010, STR0008, STR0009) //"Codigo ja est� definido como padr�o."###"Atencao"###"Valida��o de Inclus�o"
    lRet := .F.
   EndIf
  EndIf               
 Next nCtaFor
 
Return( lRet )  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA76 � Autor � Daniel Peixoto     � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Atualizacao do cadastro                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvA76(nOpcG)
 Local lAchou      := .T.
// Local lFoundGN2 := .F.
// Local nForGrv := 0     
 Local cAliasOld := Alias()
 If nOpcG == 2     // Se for uma consulta
  Return(.T.)
 Endif 

  DbselectArea("G17")  
  DbsetOrder(1)
  lAchou := DbSeek(xFilial("G17") + M->G17_CODIGO) 
 
  If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
   RecLock("G17", !lAchou)
    HS_GRVCPO("G17")
    G17->G17_FILIAL  := xFilial("G17")
   MsUnlock()
  
   FS_GrvGM("GN2", 1, "M->G17_CODIGO + oGN2:aCols[pForACols, nGN2_ITETGT]", oGN2:aHeader, oGN2:aCols, nGN2_MODIMP, nGN2STAREG)
  
  ElseIf nOpcG == 5 //Excluir
        
   FS_DelGM("GN2", 1, "M->G17_CODIGO + oGN2:aCols[pForACols, nGN2_ITETGT]", oGN2:aCols, nGN2_ITETGT) // Excluir relacionamento GHW
   
   RecLock("G17", .F., .T.)
    DbDelete()
   MsUnlock()
   WriteSx2("G17") 
  Endif

 DbSelectArea(cAliasOld)
Return(Nil)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_TipGuia� Autor � Patricia Queiroz   � Data �  09/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao utilizada para tratar a descricao do campo combo.   ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar 																					             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_TipGuia()

Local cDescri := ""

cDescri := "0=Guia Consulta;1=Guia Serv. Profiss./Serv. Aux. de Diag. e Terapia - SP/SADT;2=Guia Solicita��o Interna��o;3=Guia Resumo Interna��o;"
cDescri += "4=Guia Honor�rio Individual;5=Guia Outras Despesas;6=Dem. An�lise Conta M�dica;7=Dem. Pagamento;8=Guia Trat. Odontol.-Cobran�a;"
cDescri += "9=Guia Trat. Odontol.-Solicit.;A=Guia Odontol.-Demonst. Pagamento"
 
Return(cDescri) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvGM  � Autor � Cibele Peria       � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Grava arquivos de relacionamento - GM0, GM1 e GM2          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvGM(cAlias, nOrd, cChave, aHGrv, aCGrv, nPos, nStaReg)

 Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
 Local cPref := cAlias + "->" + PrefixoCpo(cAlias)

 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos]))
  While (nForACols := aScan(aCGrv, {| aVet | aVet[nStaReg] <> "BR_VERDE"}, nForACols + 1)) > 0
   pForACols := nForACols
  
   DbSelectArea(cAlias)
   DbSetOrder(nOrd)
   lAchou := DbSeek(xFilial(cAlias) + &(cChave))
   If aCGrv[nForACols, Len(aCGrv[nForACols])] .And. lAchou // exclusao
    RecLock(cAlias, .F., .T.)
     DbDelete()
    MsUnlock()
   Else
    If !aCGrv[nForACols, Len(aCGrv[nForACols])]
     RecLock(cAlias, !lAchou)
      HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
      &(cPref + "_FILIAL") := xFilial(cAlias)
      &(cPref + "_CODTGT") := M->G17_CODIGO
     MsUnlock()                  
    EndIf 
   EndIf
  End
 EndIf 
 
 DbSelectArea(cAliasOld)
 
Return(Nil)                                                

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_DelGM  � Autor � Cibele Peria       � Data �  12/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de DELETE dos relacionamentos do Local              ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_DelGM(cAlias, nOrd, cChave, aCGrv, nPos)

 Local nForDel := 0, cAliasOld := Alias()
 
 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos])) 
  For nForDel := 1 To Len(aCGrv)
   pForACols := nForDel
  
   DbSelectArea(cAlias)
   DbSetOrder(nOrd)
   If DbSeek(xFilial(cAlias) + &(cChave))
    RecLock(cAlias, .F., .T.)
     DbDelete()
    MsUnlock()
   EndIf
  Next
 EndIf
 
 DbSelectArea(cAliasOld)
 
Return(Nil)
