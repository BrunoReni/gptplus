#INCLUDE "EICCC150.CH"
#include "AVERAGE.CH"

/*
Funcao    � EICCC150
Autor     � AVERAGE/LUIZ CLAUDIO BARBOSA
Manuten��o� GUSTAVO CARREIRO 12/07/2001
Data      � 07.11.2000
Descricao � Relar�rio de importa��es pagas no periodo
Sintaxe   � U_EICCC150()
Uso       � SIGAEIC
*/

Function EICCC150()
If EasyEntryPoint("EICCC150")
   ExecBlock("EICCC150",.F.,.F.)
Else
   EICCCR3(.T.)
EndIf
Return .t.

*-----------------------*
Function EICCCR3(p_R4)
*-----------------------*
LOCAL aAreaComp:={ "SA2","SA6","SYW"}, cAliasCad, nI
LOCAL aCamposInd:={"A2_COD","A6_COD","YW_COD"}, ccpo, aMarcados:={}, lBrowseFil:=.F., cSvFilAnt

// Define variaveis das fun��es SetPrint() e SetDefault()
PRIVATE cString := "SW6", cAlias := Alias()
PRIVATE NomeRel := "EICCC150"
PRIVATE titulo  := STR0001 //"Relar�rio de importa��es pagas no periodo por"
PRIVATE cDesc1  := STR0002 //"Este relat�rio apresenta as importa��es pagas por"
PRIVATE cDesc2  := STR0003 //"periodo conforme parametros informados pelo usu�ruo"
PRIVATE cDesc3  := ""
PRIVATE aOrd    := Nil
PRIVATE tamanho := "M"
PRIVATE nLin    := 999
PRIVATE aReturn := { "Zebrado", 1,"Importa��o", 2, 2, 1, "", 1 }
PRIVATE m_pag   := 1
PRIVATE cCabec1 := ""
PRIVATE cCabec2 := ""
PRIVATE cArqTrb := ""
PRIVATE lImpObs:=.F.
PRIVATE cTotBrk:=""
SX3->(DBSETORDER(2))
PRIVATE lCposAdto:=SX3->(DBSEEK("WB_PO_DI")) .AND. SX3->(DBSEEK("WB_PGTANT")) .AND. SX3->(DBSEEK("WB_NUMPO"))
SX3->(DBSETORDER(1))

// lCposAdto->Se existir os cpos referente a pagto antecipado, trata Seek
// com um campo a mais  WA_PO_DI/WB_PO_DI que, nas parcelas de cambio de DI tera como
// conteudo a letra "D".

// Define variaveis desta rotina
Private cKey
Private cQUEBRA
Private nVLTOTGER:= 0
Private nVLTOTUSGER:= 0
Private Var1,Var2,Var3,Var4,Var5,Var6, aFilSel
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
Do While .T.


   aFilSel:=AvgSelectFil(.T.,"SWB") // RS 05/01/06    - Filiais Selecionadas / as que o usuario tem acesso
   lSai:=.F.
   IF aFilSel[1] == "WND_CLOSE"   // BOTAO CANCELAR???
      EXIT
   ENDIF

   Do While .T.
      DBSELECTAREA("SWB")
      If ! Pergunte("EICCC1", .T.)
         lSai:=.T.
         Exit
      EndIf

      Var1 := MV_PAR01 // De Dt.Pagto ?
      Var2 := MV_PAR02 // Ate Dt.Pagto ?
      Var3 := MV_PAR03 // Emite Por ?
      Var4 := MV_PAR04 // Aberto/Fechado ?
      Var6 := MV_PAR05 // Olha para DI ? //LRS - 13/05/2015

      IF !E_PERIODO_OK(@Var1,@Var2)//AWR - 30/09/2004
         LOOP
      ENDIF

      DBSELECTAREA("SWB")
      cAliasCad:=ALIAS()
      IF Posicione("SX2",1,"SWB","X2_MODO") == "E"
         lBrowseFil:=.T.
      ENDIF

      IF(Var3<>4,DBSELECTAREA(aAreaComp[Var3]),(lBrowseFil:=.F.,aMarcados:=ACLONE(aFilSel)))
      cAliasCad:=ALIAS()
      If (Posicione("SX2",1,cAliasCad,"X2_MODO") == "C" .OR. ! lBrowseFil) .AND. Var3 <> 4   // verifica se SY3 - CC � exclusivo ou compartilhado??  -- RS 11/01/06

         If Var3 == 2     .And. !Pergunte("EICCC3", .T.)// Por Banco - SA6
            Loop
         ElseIf Var3 == 3 .And. !Pergunte("EICCC4", .T.)// Por Corretora - SYW
            Loop
         ElseIf Var3 == 1 .And. !Pergunte("EICCC5", .T.)// Por Fornecedor - SA2
            Loop
         EndIf
         Var5 := MV_PAR01
         lBrowseFil:=.F.

         aMarcados:=ACLONE(aFilSel)
      Endif
      DBSELECTAREA(cAliasCad)

      IF lBrowseFil
         ccpo:=aCamposInd[Var3]

         bCampo:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",STR0023,WorkFil->(FIELDGET(FIELDPOS(ccpo))))}

         aTB_Campos:={{bCampo,"",AVSX3(ccpo,5) 	} }

         aDBF:= { {ccpo,AVSX3(ccpo,2),AVSX3(ccpo,3),AVSX3(ccpo,4)} }
         bMarca:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",SPACE(AVSX3(ccpo,3)),WorkFil->(FIELDGET(FIELDPOS(ccpo)))),IF(EMPTY(WorkFil->WKMARCA),aRetGET:=CC150GET(aAreaComp[Var3],aCamposInd[Var3]),CC150GET(aAreaComp[Var3],aCamposInd[Var3]))}

         aRetMarcados:={ccpo}

         aMarcados:=AvgMBrowseFil("","",aFilSel,aTb_Campos,"",aDBF,bMarca,aRetMarcados)
      ENDIF

      IF EMPTY(aMarcados)
         LOOP
      ENDIF

      cSvFilAnt:=cFilAnt
      IF SELECT("TRB") > 0
         TRB->(AvZap())
      EndIf

      FOR nI:=1 TO LEN(aMarcados)
          aTemp:=aMarcados[nI]
          cFilSel:=IF(lBrowseFil,aTemp[1],aTemp)
          cFilAnt:=cFilSel

          IF(lBrowseFil,Var5:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1]),)

          CC150GRVTRB()
      NEXT
      cFilAnt:=cSvFilAnt

      If lR4
         //TRP - 29/08/2006 - Relat�rio Personalizavel - Release 4
         //ReportDef cria os objetos.
         oReport := ReportDef()
      EndIf
      If(lR4,oReport:PrintDialog(),CC150IMPRIME())

   EndDo
   IF lSai
      EXIT
   ENDIF
EndDo
dbSelectArea(cAlias)
Return Nil


*-----------------------------*
Static Function CC150GET(cArqF3,cCampoF3)
*-----------------------------*
LOCAL oDlg1, cPict, aTextoSAY:={STR0004,STR0005,STR0006}     //Fornecedor,Banco,Corretora
LOCAL cTexto, lOk:=.F., xPos, cSvFilAnt


IF !EMPTY(WorkFil->WKMARCA)
   xPos:=WorkFil->(FIELDPOS(cCampoF3))
   WorkFil->WKMARCA:=SPACE(02)
   WorkFil->(FIELDPUT(xPos,SPACE(LEN(WORKFIL->(FIELDGET(FIELDPOS(cCampoF3)))))))
   RETURN .T.
ENDIF

cSvFilAnt:=cFilAnt
cFilAnt:=WorkFil->WKFILIAL

SX3->(DBSETORDER(2))
Var5:=E_TRAN(cCampoF3,cArqF3)
cPict:=ALLTRIM(SX3->X3_PICTURE)

cTexto:=aTextoSAY[Var3]

IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(cCampoF3))),1)<>"*",Var5:=WorkFil->(FIELDGET(FIELDPOS(cCampoF3))),)

DEFINE MSDIALOG oDlg1 TITLE "" From 15,35 To 23,70  OF oMainWnd

@ 13,15 SAY oSayCod VAR cTexto SIZE 45,10 OF oDlg1 PIXEL
@ 13,45 MSGET Var5 F3 cArqF3 Picture cPict SIZE 40,9 OF oDlg1 PIXEL

DEFINE SBUTTON FROM 13,100 TYPE 1 ACTION (IF(CC150VERGET(cArqF3),(lOk:=.T.,oDlg1:End()),))  ENABLE OF oDlg1
DEFINE SBUTTON FROM 27,100 TYPE 2 ACTION (/*lCancel:=.T.*/oDlg1:End()) ENABLE OF oDlg1

ACTIVATE MSDIALOG oDlg1 CENTERED

IF lOk
   WorkFil->WKMARCA:=IF(EMPTY(WorkFil->WKMARCA),cMarca,SPACE(02))
   xPos:=WorkFil->(FIELDPOS(cCampoF3))
   IF EMPTY(WorkFil->WKMARCA)
      WorkFil->(FIELDPUT(xPos,SPACE(LEN(WORKFIL->(FIELDGET(FIELDPOS(cCampoF3)))))))
      RETURN .T.
   ENDIF
   WorkFil->(FIELDPUT(xPos,IF(EMPTY(Var5),"*Todos",Var5)))
ENDIF

RETURN .T.



*----------------------------------*
Static Function CC150VERGET(xAlias)
*----------------------------------*
IF EMPTY(Var5)
   RETURN .T.
ENDIF

IF ! (xAlias)->(DBSEEK(xFilial(xAlias)+Var5))
   Help("",1,"REGNOIS")
   RETURN .F.
ENDIF

RETURN .T.

*-----------------------------*
Static Function CC150GRVTRB()
*-----------------------------*
LOCAL nTX_PTAX:=0,nValSWB:=0
LOCAL cMoeDolar:=EasyGParam("MV_SIMB2",,"US$")

aStru := { { "WKFILIAL"   , "C", FWSizeFilial()      , 0 } ,;
           { "PROCESSO"   , "C", AVSX3("WB_HAWB",3)  , 0 } ,;
           { "HAWB"       , "C", AVSX3("WB_HAWB",3)  , 0 } ,;
           { "VAL_FOB"    , "N", AVSX3("WB_FOBMOE",3), AVSX3("WB_FOBMOE",4)},; //TDF - 18/05/11 - Altera��o no tamanho e decimal do campo
           { "VAL_FOB_US" , "N", AVSX3("WB_FOBMOE",3), AVSX3("WB_FOBMOE",4)},; //TDF - 18/05/11 - Altera��o no tamanho e decimal do campo
           { "DT_FECH"    , "D", 08                  , 0 } ,;
           { "TX_FECH"    , "N", AVSX3("WB_CA_TX",3) , AVSX3("WB_CA_TX",4)} ,; //TDF - 18/05/11 - Altera��o no tamanho e decimal do campo
           { "TX_PTAX"    , "N", AVSX3("WB_CA_TX",3) , AVSX3("WB_CA_TX",4)} ,; //TDF - 18/05/11 - Altera��o no tamanho e decimal do campo
           { "FEC_X_PTAX" , "N", 08                  , 2 } ,;
           { "DT_DEBITO"  , "D", 08                  , 0 } ,;
           { "BANCO"      , "C", AVSX3("WB_BANCO",3) , 0 } ,;
           { "DESCBANCO"  , "C", AVSX3("A6_NREDUZ",3), 0 } ,;
           { "CORRETORA"  , "C", AVSX3("YW_NOME",3)  , 0 } ,;
           { "PRODUTO"    , "C", 15                  , 0 } ,;
           { "FORNECEDOR" , "C", AVSX3("A2_COD",3)   , 0 } ,;
           { "NOMEFORN"   , "C", AVSX3("A2_NREDUZ",3), 0 } ,; //JAP
           { "PAIS"       , "C", AVSX3("A2_PAIS",3)  , 0 } ,;
           { "PO_DI"      , "C", 01                  , 0 } ,; //DFS - 29/04/11 - Inclus�o de campo na estrutura da work
           { "INVOICE"    , "C", AVSX3("WB_INVOICE",3), 0 } ,; //DFS - 29/04/11 - Inclus�o de campo na estrutura da work
           { "Vencimento" , "D", 08                  , 0 } ,; //DFS - 29/04/11 - Inclus�o de campo na estrutura da work
           { "VAL_FOB_R"  , "N", 20                  , 8 } ,;
           { "TIPO_REG"   , "C", 15                   , 0 }}  //TDF - 18/05/11 - Altera��o no tamanho do campo


cKey := ""
If Var3 == 1 // Por Fornecedor
   cKey    += STR0004 //"Fornecedor"
ElseIf Var3 == 2 // Por Banco
   cKey    += STR0005 //"Banco"
ElseIf Var3 == 3 // Por Corretora
   cKey    += STR0006 //"Corretora"
ElseIf Var3 == 4 // Por Produto
   cKey    += STR0007 //"Produto"
EndIf

IF SELECT("TRB") == 0
   cArqTrb := E_CriaTrab(,aStru,"TRB") //THTS - 06/10/2017 - TE-7085 - Temporario no Banco de Dados
   IndRegua("TRB", cArqTrb, "WKFILIAL+"+cKey+"+Dtos(DT_FECH)", , , STR0008) //"Indexando arquivo de trabalho"
ENDIF

cKey1  := cKey

If !Empty(Var1) .AND. !Empty(Var2)
   cKey1 += STR0024 + DtoC(Var1) + " a " + DtoC(Var2)
EndIf

lImpObs:=.F.
SYE->(DBSETORDER(2))
SW6->(dbSetOrder(1))
SWB->(dbSetOrder(3))//WB_FILIAL+DTOS(WB_CA_DT)+DTOS(WB_DT_VEN)
If Var4 = 1 // Aberto
   SWB->(dbSeek(xFilial("SWB"))) //AWR - 30/09/2004
   titulo  := STR0001+STR0025+cKey1 // JAP - 14/08/06
ELSE// Fechado
   SWB->(dbSeek(xFilial("SWB")+DTOS(Var1), .T.))//AWR - 30/09/2004 - A variavel Var1 sempre vai estar preenchiada por causa da funcao E_PERIODO_OK(@Var1,@Var2)
   titulo  := STR0001+STR0026+cKey1 // JAP - 14/08/06
ENDIF

Do While !SWB->(Eof()) .And. SWB->WB_FILIAL==xFilial("SWB")

// If Var4 = 1 .And. !Empty(SWB->WB_DT_CONT) // Aberto
   If Var4 = 1  // Aberto
      IF !Empty(SWB->WB_CA_DT)//AWR - 30/09/2004
         EXIT
      ENDIF
// ElseIf SWB->WB_DT_CONT < Var1 .Or. SWB->WB_DT_CONT > Var2
// Fechado
   ElseIf SWB->WB_CA_DT > Var2//AWR - 30/09/2004 - A variavel Var2 sempre vai estar preenchiada por causa da funcao E_PERIODO_OK(@Var1,@Var2)
      EXIT
   EndIf

   If !Empty(Var5)
      If Var3 == 1 .And. SWB->WB_FORN # Var5  // Por Fornecedor
         SWB->(dbSkip())
         Loop
      ElseIf Var3 == 2 .And. SWB->WB_BANCO # Var5 // Por Banco
         SWB->(dbSkip())
         Loop
      ElseIf Var3 == 3 .And. SWB->WB_CORRETO # Var5 // Por Corretora
         SWB->(dbSkip())
         Loop
      EndIf
   EndIf

   SW6->(dbSeek(xFilial("SW6")+SWB->WB_HAWB))
   SW7->(dbSeek(xFilial("SW7")+SWB->WB_HAWB))
   If lCposAdto .And. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C")
      SW2->(dbSeek(xFilial("SW2")+Alltrim(SWB->WB_HAWB)))
      nValSWB:=SWB->WB_PGTANT
      lImpObs:=.T.
   Else
      SW2->(dbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
      nValSWB:=SWB->WB_FOBMOE
   EndIf
   IF nValSWB == 0
      SWB->(dbSkip())
      LOOP
   ENDIF
    //LRS - 08/05/2015 - Criado uma nova valida��o para o relatorio, Verifica D.I?
   IF VAR6 =1
	   IF SWB->WB_PO_DI == 'D' .AND. EMPTY(SW6->W6_DI_NUM)  // GFP - 06/06/2014
	      SWB->(DbSkip())
	      Loop
	   ENDIF
   EndIF

   If Var4 = 2
//    nTX_PTAX := If(SYE->(DBSEEK(xFilial("SYE")+SWB->WB_MOEDA+DTOS(SWB->WB_DT_CONT))),SYE->YE_VLCON_C,0)
      nTX_PTAX := If(SYE->(DBSEEK(xFilial("SYE")+SWB->WB_MOEDA+DTOS(SWB->WB_CA_DT))),SYE->YE_VLCON_C,0)//AWR - 30/09/2004
   Else
      nTX_PTAX := If(SYE->(DBSEEK(xFilial("SYE")+SWB->WB_MOEDA+DTOS(dDataBase))),SYE->YE_VLCON_C,0)
   EndIf
   IF SA6->(dbSeek(xFilial("SA6")+SWB->WB_BANCO+SWB->WB_AGENCIA+SWB->WB_CONTA)) //MCF - 22/08/2014
     cNomeBco:=SA6->A6_NREDUZ
   ELSE
     cNomeBco:=""
   ENDIF

   SA2->(dbSeek(xFilial("SA2")+SWB->WB_FORN))

   TRB->(DbAppend())
   TRB->PROCESSO   := SWB->WB_HAWB
   TRB->HAWB       := SWB->WB_HAWB
   TRB->VAL_FOB    := nValSWB
   IF SWB->WB_MOEDA == cMoeDolar//AWR - 30/09/2004
      TRB->VAL_FOB_US := nValSWB
   ELSE
//    TRB->VAL_FOB_US := (nValSWB * BuscaTaxa(SWB->WB_MOEDA, SWB->WB_DT_CONT,,.F.)) / BuscaTaxa(cMoeDolar, SWB->WB_DT_CONT,,.F.)//AWR - 30/09/2004
      TRB->VAL_FOB_US := (nValSWB * BuscaTaxa(SWB->WB_MOEDA, SWB->WB_CA_DT  ,,.F.)) / BuscaTaxa(cMoeDolar, SWB->WB_CA_DT,,.F.)
   ENDIF

   TRB->WKFILIAL   := SWB->WB_FILIAL
   TRB->DT_FECH    := SWB->WB_CA_DT//SWB->WB_DT_CONT //AWR - 30/09/2004
   TRB->TX_FECH    := SWB->WB_CA_TX
   TRB->TX_PTAX    := nTX_PTAX
   TRB->FEC_X_PTAX := IF(!EMPTY(nTX_PTAX),((nTX_PTAX/SWB->WB_CA_TX)-1)*100,0)
   TRB->DT_DEBITO  := SWB->WB_DT_DESE
   TRB->BANCO      := SWB->WB_BANCO
   TRB->DESCBANCO  := cNomeBco
   TRB->CORRETORA  := If(SYW->(DbSeek(xFilial("SYW")+SWB->WB_CORRETO)),SYW->YW_NOME,)//JVR - 24/04/09 - Troca de codigo por nome.
   TRB->PRODUTO    := ""
   TRB->FORNECEDOR := SWB->WB_FORN
   TRB->PO_DI      := SWB->WB_PO_DI //DFS - 29/04/11 - Inclus�o de campo na work para adicionar no TRPosition do indice da SWB
   TRB->TIPO_REG   := AllTrim(AvTabela("Y6",SWB->WB_TIPOREG))
   TRB->INVOICE    := SWB->WB_INVOICE //DFS - 29/04/11 - Inclus�o de campo na work para adicionar no TRPosition do indice da SWB
   TRB->Vencimento := SWB->WB_DT_VEN //DFS - 29/04/11 - Inclus�o de campo na work para adicionar no TRPosition do indice da SWB
   //JAP
   TRB->NOMEFORN   := SA2->A2_NREDUZ
   TRB->PAIS       := SA2->A2_PAIS
   //TDF - 24/01/2012
   IF SWB->WB_MOEDA == cMoeDolar
      TRB->VAL_FOB_R  := Round(TRB->VAL_FOB_US * TRB->TX_FECH ,2)
   ELSE
      TRB->VAL_FOB_R  := Round(TRB->VAL_FOB * TRB->TX_FECH ,2)
   ENDIF
   //TRB->VAL_FOB_R  := TRB->VAL_FOB_US * TRB->TX_FECH
   SWB->(dbSkip())
EndDo

SYE->(DbSetOrder(1))
SWB->(dbSetOrder(1))
Return .T.

*----------------------------*
Static Function CC150IMPRIME()
*----------------------------*
LOCAL aDados :={"TRB",;
                Titulo,;
                cDesc1,;
                cDesc2,;
                "G",;
                132,;
                "",;
                "",;
                Titulo,;
                aReturn,;
                "EICCC150",;
                {{|| CC150QUEBRA() },{|| CC150TOTAL()}},;
                }

Private cChave, aTotalFil:={}
Private aRCampos:={ ;
                  {"PROCESSO"                                    , STR0009     , "E"}  ,; //"Processo"
                  {"TIPO_REG"                                    , STR0032     , "E"}  ,; //"Tipo Reg"
                  {"FORNECEDOR"                                  , STR0004     , "E"}  ,; //"Fornecedor"
                  {"NOMEFORN"                                    , STR0027     , "E"}  ,; //"Descri��o"
                  {"CORRETORA"                                   , STR0006     , "E"}  ,; //"Corretora"
                  {"TRANS(VAL_FOB,'@E 99,999,999,999,999.99')"   , STR0010     , "D"}  ,; //"Valor ME"
                  {"TRANS(VAL_FOB_US,'@E 99,999,999,999,999.99')", STR0011     , "D"}  ,; //"Valor US$"
                  {"DTOC(DT_FECH)"                               , STR0012     , "E"}  ,; //"DT.Fech."
                  {"TRANS(TX_FECH,'@E 999,999.99999999')"        , STR0013     , "E"}  ,; //"Tx.Fech."
                  {"TRANS(TX_PTAX,'@E 999,999.99999999')"        , If(Var4=1,STR0014,STR0015)  , "E"}  ,; //"Tx.PTax" OU "Tx.PTaxFech"
                  {"TRANS(FEC_X_PTAX,'@E 99,999.9999')"          , If(Var4=1,STR0016,STR0017)  , "E"}  ,; //"Tx.Fec/Tx.PTax%" OU "Tx.Fec/Tx.PTaxFec%"
                  {"BANCO"                                       , STR0005     , "E"}  ,; //"Banco"
                  {"DESCBANCO"                                   , STR0018     , "E"}  ,; //"Descri��o"
                  {"DTOC(DT_DEBITO)"                             , STR0019     , "E"}  ,; //"DT.D�bito"
                  {"Vencimento"                                  , STR0031     , "E"}  ,; //"Vencimento" //DFS - 29/04/11 - Inclus�o de campo na estrutura da work
                  {"TRANS(VAL_FOB_R,'@E 99,999,999,999,999.99')" , STR0028     , "D"} }   //"Valor R$"

If Var3     == 1 // Por Fornecedor
   cChave := "FORNECEDOR+PAIS"
   bQUEBRA := {||TRB->FORNECEDOR}
ElseIf Var3 == 2 // Por Banco
   cChave := ""
   bQUEBRA := {||TRB->BANCO}
ElseIf Var3 == 3 // Por Corretora
   cChave := "CORRETORA"
   bQUEBRA := {||TRB->CORRETORA}
ElseIf Var3 == 4 // Por Produto
   cChave := "PRODUTO"
   bQUEBRA := {||TRB->PRODUTO}
Endif

DbSelectArea("TRB")
If TRB->(Bof()) .And. TRB->(Eof())
   Help("", 1, "AVG0000553")//MsgInfo("N�o existe informa��es no periodo informado")
Else
   TRB->(DBGOTOP())
   cQUEBRA:= EVAL(bQUEBRA)
   nVLTOT:=nVLTOTUS:=nVLTOTR:=nVLTOTGER:=nVLTOTUSGER:=nVLTOTRGER:=0
   If lImpObs
      aDados[7]:=STR0022 //"Os Processos iniciados com * referem-se a Adiantamentos - N�mero do Pedido"
   EndIf
   FilAtu:="*"
   E_Report(aDados,aRCampos)
   ASIZE(aTotalFil,0)
EndIf
TRB->(E_EraseArq(cArqTrb))
dbSelectArea(cAlias)

Return Nil

*-----------------------------*
Static FUNCTION CC150QUEBRA()
*-----------------------------*
Local nEspaco := 21
LOCAL nI
IF FilAtu == "*"
   Linha++
   @ Linha,01 PSAY AVSX3("W2_FILIAL",5)+".: "+TRB->WKFILIAL+' - '+AvgFilName({TRB->WKFILIAL})[1]
   Linha++
   FilAtu:=TRB->WKFILIAL
ENDIF

IF Alltrim(EVAL(bQUEBRA)) # Alltrim(cQuebra)
   cQuebra:=EVAL(bQUEBRA)
   Linha+= 2
   @ Linha, 41 + nEspaco PSAY REPLICATE("-",21)
   @ Linha, 63 + nEspaco PSAY REPLICATE("-",21)
   Linha+= 1
   @ Linha, 20 + nEspaco PSAY STR0020 + cKey //"Total por "
   @ Linha, 41 + nEspaco PSAY TRANS(nVLTOT,"@E 99,999,999,999,999.99")
   @ Linha, 63 + nEspaco PSAY TRANS(nVLTOTUS,"@E 99,999,999,999,999.99")
   @ Linha, 180 + nEspaco PSAY TRANS(nVLTOTR,"@E 99,999,999,999,999.99")
   Linha+= 1
   nVLTOTGER+=nVLTOT
   nVLTOTUSGER+=nVLTOTUS
   nVLTOTRGER+=nVLTOTR

   nVLTOT:=nVLTOTUS:=nVLTOTR:=0
   nVLTOT   += TRB->VAL_FOB
   nVLTOTUS += TRB->VAL_FOB_US
   nVLTOTR += TRB->VAL_FOB_R

Else
   nVLTOT   += TRB->VAL_FOB
   nVLTOTUS += TRB->VAL_FOB_US
   nVLTOTR  += TRB->VAL_FOB_R
ENDIF

if FilAtu#TRB->WKFILIAL

   Linha++
   @ Linha, 41 + nEspaco PSAY REPLICATE("-",21)
   @ Linha, 63 + nEspaco PSAY REPLICATE("-",21)
   Linha+= 1

   nI:=ASCAN(aTotalFil,{|X|X[1]==FilAtu})
   @ Linha, 01 + nEspaco PSAY LEFT(STR0020,6)+AVSX3("W2_FILIAL",5)+".: " +FilAtu+' - '+AvgFilName({FilAtu})[1] //"Total por "
   @ Linha, 41 + nEspaco PSAY TRANS(aTotalFil[nI][2],"@E 99,999,999,999,999.99")
   @ Linha, 63 + nEspaco PSAY TRANS(aTotalFil[nI][3],"@E 99,999,999,999,999.99")
   @ Linha, 180 + nEspaco PSAY TRANS(aTotalFil[nI][4],"@E 99,999,999,999,999.99")
   Linha++
   @ Linha, 01 + nEspaco PSAY REPLICATE("=",218)
   Linha++
   @ Linha,01 + nEspaco PSAY AVSX3("W2_FILIAL",5)+".: "+TRB->WKFILIAL+' - '+AvgFilName({TRB->WKFILIAL})[1]
   Linha++

   FilAtu:=TRB->WKFILIAL
endif

nI:=ASCAN(aTotalFil,{|X|X[1]==TRB->WKFILIAL})

IF nI==0
   AADD(aTotalFil,{TRB->WKFILIAL,TRB->VAL_FOB,TRB->VAL_FOB_US,TRB->VAL_FOB_R})
ELSE
   aTotalFil[nI][2]+=TRB->VAL_FOB
   aTotalFil[nI][3]+=TRB->VAL_FOB_US
   aTotalFil[nI][4]+=TRB->VAL_FOB_R
ENDIF

Return .T.


*-----------------------------*
STATIC FUNCTION CC150TOTAL()
*-----------------------------*
Local nEspaco := 21
nVLTOT   += TRB->VAL_FOB
nVLTOTUS += TRB->VAL_FOB_US
nVLTOTR  += TRB->VAL_FOB_R
Linha+= 2
@ Linha, 41 + nEspaco PSAY REPLICATE("-",21)
@ Linha, 63 + nEspaco PSAY REPLICATE("-",21)
@ Linha, 201 + nEspaco PSAY REPLICATE("-",21)
Linha+= 1
@ Linha, 20 + nEspaco PSAY STR0020 + cKey //"Total por "
@ Linha, 41 + nEspaco PSAY TRANS(nVLTOT,"@E 99,999,999,999,999.99")
@ Linha, 63 + nEspaco PSAY TRANS(nVLTOTUS,"@E 99,999,999,999,999.99")
@ Linha, 201 + nEspaco PSAY TRANS(nVLTOTR,"@E 99,999,999,999,999.99")
nVLTOTGER+=nVLTOT
nVLTOTUSGER+=nVLTOTUS
nVLTOT:=nVLTOTUS:=0
nVLTOTRGER+=nVLTOTR

Linha++
@ Linha, 41 + nEspaco PSAY REPLICATE("-",21)
@ Linha, 63 + nEspaco PSAY REPLICATE("-",21)
@ Linha, 201 + nEspaco PSAY REPLICATE("-",21)
Linha+= 1

nI:=ASCAN(aTotalFil,{|X|X[1]==FilAtu})
@ Linha, 01 + nEspaco PSAY LEFT(STR0020,6)+AVSX3("W2_FILIAL",5)+".: " +FilAtu+' - '+AvgFilName({FilAtu})[1] //"Total por "
@ Linha, 41 + nEspaco PSAY TRANS(aTotalFil[nI][2],"@E 99,999,999,999,999.99")
@ Linha, 63 + nEspaco PSAY TRANS(aTotalFil[nI][3],"@E 99,999,999,999,999.99")
@ Linha, 201 + nEspaco PSAY TRANS(aTotalFil[nI][4],"@E 99,999,999,999,999.99")

Linha+= 2


@ Linha, 41 + nEspaco PSAY REPLICATE("=",21)
@ Linha, 63 + nEspaco PSAY REPLICATE("=",21)
@ Linha, 201 + nEspaco PSAY REPLICATE("=",21)
Linha+= 1
@ Linha, 20 + nEspaco PSAY STR0021 //"Total Geral =>"
@ Linha, 41 + nEspaco PSAY TRANS(nVLTOTGER,  "@E 99,999,999,999,999.99")
@ Linha, 63 + nEspaco PSAY TRANS(nVLTOTUSGER,"@E 99,999,999,999,999.99")
@ Linha, 201 + nEspaco PSAY TRANS(nVLTOTRGER,"@E 99,999,999,999,999.99")

Return .T.


//TRP - 29/08/2006 - Defini��es do relat�rio personaliz�vel
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relat�rio
aTabelas := {"SWB","SYE"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
//aOrdem   := { AvSx3("EE9_COD_I" ,5)+STR0021+AvSx3("EE9_DTAVRB",5),; //" e " Primeira Ordem
//              AvSx3("EE9_DTAVRB",5)+STR0021+AvSx3("EE9_COD_I" ,5) } //" e " Segunda  Ordem

aOrdem   := { }


IF Var3 == 1
   //Cria o objeto principal de controle do relat�rio.
   //Par�metros:            Relat�rio ,Titulo ,Pergunte ,C�digo de Bloco do Bot�o OK da tela de impress�o.
   oReport := TReport():New("EICCC150",STR0001+STR0004,"EICCC1",{|oReport| ReportPrint(oReport)},STR0001+STR0004+CHR(13)+CHR(10)+STR0002+" "+STR0003)

ELSEIF Var3 == 2
   oReport := TReport():New("EICCC150",STR0001+STR0005,"EICCC1",{|oReport| ReportPrint(oReport)},STR0001+STR0005+CHR(13)+CHR(10)+STR0002+" "+STR0003)

ELSEIF Var3 == 3
   oReport := TReport():New("EICCC150",STR0001+STR0006,"EICCC1",{|oReport| ReportPrint(oReport)},STR0001+STR0006+CHR(13)+CHR(10)+STR0002+" "+STR0003)

ELSEIF Var3 == 4
   oReport := TReport():New("EICCC150",STR0001+STR0007,"EICCC1",{|oReport| ReportPrint(oReport)},STR0001+STR0007+CHR(13)+CHR(10)+STR0002+" "+STR0003)

ENDIF

//Define o Relat�rio com paisagem
oReport:oPage:lLandscape := .T.
oReport:oPage:lPortrait := .F.

//Define o objeto com a se��o do relat�rio
oSecao1 := TRSection():New(oReport,"Importa��es pagas",aTabelas,aOrdem)

//Define o objeto com a se��o do relat�rio
oSecao2 := TRSection():New(oReport,"Mensagem referente � adiantamentos",aTabelas,aOrdem)

//Defini��o das colunas de impress�o da se��o 1
TRCell():New(oSecao1,"PROCESSO"            ,"TRB",STR0009                             ,/*Picture*/                       ,AVSX3("WB_HAWB",3)  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TIPO_REG"            ,"TRB",STR0032                             ,/*Picture*/                       ,15                   ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"FORNECEDOR"          ,"TRB",STR0004                             ,/*Picture*/                       ,AVSX3("A2_COD",3)   ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"NOMEFORN"            ,"TRB",STR0027                             ,/*Picture*/                       ,AVSX3("A2_NREDUZ",3),.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"CORRETORA"           ,"TRB",STR0006                             ,/*Picture*/                       ,20                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VAL_FOB"             ,"TRB",STR0010                             ,'@E 99,999,999,999,999.99'        ,17                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VAL_FOB_US"          ,"TRB",STR0011                             ,'@E 99,999,999,999,999.99'        ,17                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DT_FECH"             ,"TRB",STR0012                             ,/*Picture*/                       ,08                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/) //GFP - 29/03/2012 - Ajuste no tamanho de datas
TRCell():New(oSecao1,"TX_FECH"             ,"TRB",STR0013                             ,'@E 999,999.99999999'             ,15                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"TX_PTAX"             ,"TRB",If(Var4=1,STR0014,STR0015)          ,'@E 999,999.99999999'             ,15                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"FEC_X_PTAX"          ,"TRB",If(Var4=1,STR0016,STR0017)          ,'@E 99,999.9999'                  ,08                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"BANCO"               ,"TRB",STR0005                             ,/*Picture*/                       ,AVSX3("WB_BANCO",3) ,.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DESCBANCO"           ,"TRB",STR0018                             ,/*Picture*/                       ,AVSX3("A6_NREDUZ",3),.F./*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DT_DEBITO"           ,"TRB",STR0019                             ,/*Picture*/                       ,08                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/) //GFP - 29/03/2012 - Ajuste no tamanho de datas
TRCell():New(oSecao1,"Vencimento"          ,"TRB",STR0031                             ,'@D'                              ,08                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/) //DFS - 29/04/11 - Inclus�o de campo na estrutura da work   //GFP - 29/03/2012 - Ajuste no tamanho de datas
TRCell():New(oSecao1,"VAL_FOB_R"           ,"TRB",STR0028                             ,'@E 99,999,999,999,999.99'        ,17                  ,.F./*lPixel*/,/*{|| code-block de impressao }*/)

//oReport:Section("Importa��es pagas"):Cell("PROCESSO"       ):SetColSpace(2)
//oReport:Section("Importa��es pagas"):Cell("VAL_FOB_US"     ):SetColSpace(2)
//oReport:Section("Importa��es pagas"):Cell("TX_PTAX"        ):SetColSpace(2)
//oReport:Section("Importa��es pagas"):Cell("FEC_X_PTAX"     ):SetColSpace(2)
oReport:Section("Importa��es pagas"):Cell("FORNECEDOR"     ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("CORRETORA"      ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("VAL_FOB"        ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("VAL_FOB_US"     ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("DT_FECH"        ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("TX_FECH"        ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("TX_PTAX"        ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("FEC_X_PTAX"     ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("BANCO"          ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("Vencimento"     ):SetHeaderAlign("RIGHT")//DFS - 29/04/11 - Inclus�o de campo na estrutura da work
oReport:Section("Importa��es pagas"):Cell("DT_DEBITO"      ):SetHeaderAlign("RIGHT")
//oReport:Section("Importa��es pagas"):Cell("DESCBANCO"      ):SetHeaderAlign("RIGHT")
oReport:Section("Importa��es pagas"):Cell("DT_DEBITO"):SetHeaderAlign("RIGHT")

If Var3 == 1
   oBreak2 := TRBreak():New(oReport:Section("Importa��es pagas"),{|| TRB->FORNECEDOR },,.F.) // "Quebra por fornecedor"
   oBreak2:SetTotalText("Total por Fornecedor:")
Elseif Var3 == 2
   oBreak2 := TRBreak():New(oReport:Section("Importa��es pagas"),{|| TRB->BANCO },,.F.) // "Quebra por Banco"
   oBreak2:SetTotalText("Total por Banco:")
Elseif Var3 == 3
   oBreak2 := TRBreak():New(oReport:Section("Importa��es pagas"),{|| TRB->CORRETORA },,.F.) // "Quebra por Corretora"
   oBreak2:SetTotalText("Total por Corretora:")
/*Elseif Var3 ==4
   oBreak2 := TRBreak():New(oReport:Section("Importa��es pagas"),{|| TRB->PRODUTO },,.F.) // "Quebra por Produto"
   oBreak2:SetTotalText("Total por Produto:")
*/
Endif

oBreak := TRBreak():New(oReport:Section("Importa��es pagas"),{||TRB->WKFILIAL},,.F.) // "Quebra por filial"
oBreak:SetTotalText("Total Filial: ")
oBreak:OnPrintTotal({||oReport:SkipLine(2),oReport:PrintText(if(!TRB->(EOF()),AVSX3("W2_FILIAL",5)+".: "+TRB->WKFILIAL+' - '+AvgFilName({TRB->WKFILIAL})[1],"" ),,)})

TRFunction():New(oReport:Section("Importa��es pagas"):Cell("VAL_FOB"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.)
TRFunction():New(oReport:Section("Importa��es pagas"):Cell("VAL_FOB_US"),NIL,"SUM",oBreak,,/*cPicture*/,/*uFormula*/,.F.,.F.)

If Var3 <> 4 // Por Produto
   TRFunction():New(oReport:Section("Importa��es pagas"):Cell("VAL_FOB"),NIL,"SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.F.)
   TRFunction():New(oReport:Section("Importa��es pagas"):Cell("VAL_FOB_US"),NIL,"SUM",oBreak2,,/*cPicture*/,/*uFormula*/,.F.,.F.)
EndIF

oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Total Geral=> ")


oTotal:= TRFunction():New(oSecao1:Cell("VAL_FOB"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->VAL_FOB  },.T.,.F.)
oTotal:SetTotalInLine(.F.)

oTotal:= TRFunction():New(oSecao1:Cell("VAL_FOB_US"),NIL,"SUM",/*oBreak*/,"","@E 9,999,999,999.99",{|| TRB->VAL_FOB_US },.T.,.F.)
oTotal:SetTotalInLine(.F.)

//Defini��o das colunas de impress�o da se��o 2
TRCell():New(oSecao2,"Cabe�alho"        ,""  , ""                  ,/*Picture*/                          ,100      ,/*lPixel*/,{|| If(lImpObs,STR0022, "") })

//Necess�rio para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

***********************************
Static Function ReportPrint(oReport)
************************************
Local cOldFilial:= cFilAnt
Local nSect1, nSect2

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
//TRPosition():New(oReport:Section("Importa��es pagas"),"SA6",1,{|| xFilial("SA6") + SWB->WB_BANCO+SWB->WB_AGENCIA})
nSect1 := aScan(oReport:aSection, {|x| x:cRealTitle == "Importa��es pagas"})
nSect2 := aScan(oReport:aSection, {|x| x:cRealTitle == "Mensagem referente � adiantamentos"})

TRPosition():New(oReport:aSection[nSect1],"SA6",1,{|| xFilial("SA6") + SWB->WB_BANCO+SWB->WB_AGENCIA})

TRPosition():New(oReport:aSection[nSect1],"SW2",1,{|| xFilial("SW2") + (If (lCposAdto .And. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C"),TRB->HAWB,SW7->W7_PO_NUM)) })

TRPosition():New(oReport:aSection[nSect1],"SW6",1,{|| xFilial("SW6") + TRB->HAWB})

TRPosition():New(oReport:aSection[nSect1],"SW7",1,{|| xFilial("SW7") + TRB->HAWB})

//TDF - 08/04/11 - Altera��o na chave de busca da SWB
TRPosition():New(oReport:aSection[nSect1],"SWB",1,{|| xFilial("SWB")+ AVKEY(TRB->HAWB, "WB_HAWB")+ AVKEY(TRB->PO_DI, "WB_PO_DI") + AVKEY(TRB->INVOICE, "WB_INVOICE")})

/*If Var4 = 1
   TRPosition():New(oReport:Section("Importa��es pagas"),"SWB",1,{|| xFilial("SWB") })
Else
   TRPosition():New(oReport:Section("Importa��es pagas"),"SWB",3,{|| xFilial("SWB") +DTOS(Var1)})
Endif */

//oSection:Print()
oReport:SetMeter(TRB->(EasyRecCount()))
TRB->(DbSetOrder(1))
TRB->( dbGoTop() )

//oReport:Section("Mensagem referente � adiantamentos"):Init()
oReport:aSection[nSect2]:Init()
oReport:aSection[nSect2]:PrintLine()
oReport:aSection[nSect2]:Finish()
//Para desabilitar a impress�o da p�gina de par�metros do pergunte
//oReport:oParamPage:Disable()

oReport:aSection[nSect1]:Init()

oReport:PrintText(IIf(!TRB->(EOF()), AVSX3("W2_FILIAL", 5) + ".: " + TRB->WKFILIAL + ' - ' + AvgFilName({TRB->WKFILIAL})[1], ""),,)

cFilAnt:= TRB->WKFILIAL
Do While TRB->(!EoF()) .And. !oReport:Cancel()

   If cFilAnt <> TRB->WKFILIAL
      cFilAnt:= TRB->WKFILIAL
   EndIf

   oReport:aSection[nSect1]:PrintLine() //Impress�o da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   TRB->( dbSkip() )
EndDo
oReport:aSection[nSect1]:Finish()

TRB->(E_EraseArq(cArqTrb))

cFilAnt:= cOldFilial
Return .T.

