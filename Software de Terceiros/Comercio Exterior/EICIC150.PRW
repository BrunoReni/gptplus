#INCLUDE "EICIC150.ch"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"


#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EICIC150 � Autor � Thomaz               � Data � 19.06.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relat�rio de Itens Comprados                               ���
�������������������������������������������������������������������������Ĵ��
���Observa��o� Uso - Sigaeic e Sigaedc                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

*------------------------*
Function EICIC150()
*------------------------*
EICIC150R3(.T.)
Return .t.

Function EICIC150R3(p_R4)

Local nOpca := 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}

Private cFilSB1 := xFilial("SB1"), cItem, dDtIni, dDtFim, lTop, cNomArq, oFont
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private cFilSW8 := xFilial("SW8"), cFilSW6 := xFilial("SW6"), cFilSW9 := xFilial("SW9")
Private cPictProd  := AVSX3("W8_COD_I", 06), cPictUni_M := AVSX3("W8_UNID", 06)
Private cPictDtReg := AVSX3("W6_DTREG_D", 06), cPictDi := AVSX3("W6_DI_NUM", 06)
Private cPictHawb := AVSX3("W9_HAWB", 06) //AAF - 25/06/04 - Campo adicionado no relat�rio
Private cPictDtEntr := AVSX3("W6_DT_ENTR",06)//SVG - 08/05/09 - Campo adicionado no relat�rio data de entrega
Private cPictInv := AVSX3("W8_INVOICE",06)//TRP - 09/08/2012 - Campo adicionado na estrutura - Invoice
Private cPictForn := AVSX3("W8_FORN",06)//TRP - 09/08/2012 - Campo adicionado na estrutura - Fornecedor
Private aHeader[0],aCampos:={}, lReturn:= .T., cPergunte:= "EICIV1", cEstr
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictPrTot := ALLTRIM(X3Picture("W2_FOB_TOT"))
Private _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
PRIVATE lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()



If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif

If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(2))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(2),) //Devido ao par�metro vir com um espa�o apenas
Endif

IC150CriaWork()
//If lR4
   //AAF - 20/06/2006 - Relat�rio Personalizavel - Release 4
   //ReportDef cria os objetos.
  // oReport := ReportDef()
//EndIf
#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

While .T.
   DbSelectArea("SW8")//LRL 17/02/04
   If ! Pergunte("EICIV1",.T.)
      Exit
   EndIf

   dDtIni := mv_par01
   dDtFim := mv_par02
   cItem  := mv_par03
   cEstr  := Str(mv_par04,1)

   If !E_PERIODO_OK(@dDtIni,@dDtFim)
      Loop
   Endif

   If nOpca == 1
      MsAguarde({|| lRet := EICIC150GERA()}, STR0001) //"Aguarde... Lendo Dados do Arquivo..."
      If lTop
         If Select("cAlias_Q") <> 0
            cAlias_Q->(DbCloseArea())
         Endif
      Endif
   Else
      Exit
   Endif

   If !lRet
      Exit
   Endif

EndDo

WORK->(E_EraseArq(cNomArq))

Return lReturn

*-----------------------------*
STATIC FUNCTION EICIC150GERA()
*-----------------------------*
Local oDlg, nOpc, oPanel
Local aPos :={}, nAltura, nLargura
Local aButtons := {{"PRINT",{|| (IC150REL(aDados,aRCampos,oMark),oMark:oBrowse:Refresh()) },"Imprimir"}}
Private cMarca := GetMark(), lInverte := .F.
Private aRCampos:={}, aDados, TB_Campos := {}
Private lLimpaView := .T.  //Usado no Rdmake de grava��o do Rel. no Arquivo de Muro 

If lTop
   Processa({|| GeraQuery()}, STR0002) //"Aguarde Pesquisando Dados"
Endif

MsAguarde({|| IC150GRVWORK() }, STR0003) //"Atualizando Arquivos..."

aRCampos:={}
aDados := {"WORK",;
           STR0004,; //"Este Relatorio trara dados sobre Itens "
           STR0005,; //"comprados dentro de um determinado per�odo"
           "",;
           "G",;
           220,;
           "",;
           "",;
           STR0006,; //"Relat�rio de Itens Comprados"
           {STR0007, 1, STR0008 , 2, 2, 1, "",1 },;   //"ZEBRADO"###"IMPORTA��O"
           "EICIC150",;
           { {|| .T. } , { || .T. }  }  }

AADD(TB_Campos,{{ ||Transf(Work->COD_I, cPictProd   )}  , "", STR0009 } ) //"C�digo Prod. "
AADD(TB_Campos,{{ ||Work->DESCR                     }   , "", STR0010 } ) //"Descri��o                     "
AADD(TB_Campos,{{ ||Transf(Work->UNID_M, cPictUni_M )}  , "", STR0011 } ) //"Unidade de Medida"
AADD(TB_Campos,{{ ||Transf(Work->QTDE, _PictQtde    )}  , "", STR0012 } ) //"Quantidade"
AADD(TB_Campos,{{ ||Transf(Work->PRECO_U, _PictPrUn )}  , "", STR0013 } ) //"Pre�o Unitario"
AADD(TB_Campos,{{ ||Transf(Work->VL_MOEDA, _PictPrTot )}, "", STR0014 } ) //"Valor Moeda"
AADD(TB_Campos,{{ ||Transf(Work->VL_REAL, _PictPrTot )} , "", STR0015 } ) //"Valor R$"
AADD(TB_Campos,{{ ||Transf(Work->DT_REG, cPictDtReg)}   , "", STR0016 } ) //"Data Registro D.I."
AADD(TB_Campos,{{ ||Transf(Work->DI_NUM, cPictDi)}      , "", STR0017 } ) //"Nro D.I."
//AAF - 25/06/04 - Campo adicionado no relat�rio
AADD(TB_Campos,{{ ||Transf(Work->HAWB, cPictHawb)}      , "", STR0024 } ) //"Processo"
//SVG - 08/05/09 - Campo adicionado no relat�rio data de entrega
AADD(TB_Campos,{{ ||Transf(Work->DT_ENTR, cPictDtEnt)}  , "", STR0025 })  //"Dt Entrega"
//TRP - 09/08/2012 - Campos adicionados na estrutura - Invoice/Fornecedor
AADD(TB_Campos,{{ ||Transf(Work->INVOICE,  cPictInv)}  , "", "Invoice" })  //"Invoice"
AADD(TB_Campos,{{ ||Transf(Work->FORN   , cPictForn)}  , "", "Fornecedor" })  //"Fornecedor"


If EasyEntryPoint("EICIC150") 
   ExecBlock("EICIC150", .F., .F., "EICIC150GERA_ADD_COL")
EndIf


aRCampos:= E_CriaRCampos(TB_Campos,"C")

If Work->(Easyreccount("Work")) > 0

   Work->(DbGoTop())

   Do While .T.
      oMainWnd:ReadClientCoors()
      DEFINE MSDIALOG oDlg TITLE STR0018; //"Relat�rio de Itens Comprados "
           From oMainWnd:nTop+125,oMainWnd:nLeft+5 To oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
           
      //@ 200,00 MsPanel oPanel Prompt "" Size 05,40 of oDlg     
      
      nAltura  := int((oDLG:nBottom-oDLG:nTop)) //MCF - 24/07/2015
      nLargura := int((oDLG:nRight-oDLG:nLeft))
      aPos := PosDlgDown(oDlg)
      oPanel := TPanel():New(aPos[1]+2,aPos[2],"",oDLG,,.F.,.F.,,,(nLargura),(nAltura/2),,)
      
	  If DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
         @ 18, 10 SAY STR0019+DTOC(dDtIni)+STR0020+DTOC(dDtFim) SIZE 100,8 PIXEL FONT oDlg:oFont COLOR CLR_HBLUE of oPanel //"Per�odo de "###" at� "
      ElseIf DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) = "31/12/99"
         @ 18, 10 SAY STR0021+DTOC(dDtIni) SIZE 100,8 PIXEL FONT oDlg:oFont COLOR CLR_HBLUE of oPanel //"Per�odo - desde "
      ElseIf DTOC(dDtIni) = "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
         @ 18, 10 SAY STR0022+DTOC(dDtFim) SIZE 100,8 PIXEL FONT oDlg:oFont COLOR CLR_HBLUE of oPanel //"Per�odo - at� "
      Else
         @ 18, 10 SAY STR0023 SIZE 100,8 PIXEL FONT oDlg:oFont COLOR CLR_HBLUE of oPanel //"Per�odo de __/__/__ at� __/__/__"
      Endif

      //DEFINE SBUTTON FROM 18, (oDlg:nClientWidth-4)/2-150 TYPE 6 ACTION (IC150REL(aDados,aRCampos,oMark),oMark:oBrowse:Refresh()) ENABLE OF oPanel   //Impress�o
      //DEFINE SBUTTON FROM 18, (oDlg:nClientWidth-4)/2-50 TYPE 13 ACTION (TR350ARQUIVO("Work"), oMark:oBrowse:Refresh()) ENABLE OF oPanel  //Salvar Arq.

      oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{34,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2},,,oPanel)
      
	  oDlg:lMaximized := .T.
	  oPanel:Align := CONTROL_ALIGN_TOP//BCO 16/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
 	  oMark:oBrowse:Align := CONTROL_ALIGN_BOTTOM //BCO 16/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpc:=1,oDlg:End()},; //BCO 16/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
 	                                                  {||nOpc:=0,oDlg:End()},,aButtons))

      If nOpc == 1 .Or. nOpc == 0 .Or. nOpc == Nil
         Return .F.
      Endif
   Enddo
Else
   Help(" ",1,"EICSEMREG")
Endif

Return .T.

*--------------------------------*
Static Function GeraQuery()
*--------------------------------*
Local cQuery

cQuery := " SELECT " + ENTER
cQuery += " SW6.W6_FILIAL, SW6.W6_HAWB, SW6.W6_DI_NUM, SW6.W6_DTREG_D, SW6.W6_VLMLEMN, " + ENTER
cQuery += " SW8.W8_FILIAL, SW8.W8_INVOICE, SW8.W8_FORN, SW8.W8_COD_I, SW8.W8_UNID, SW8.W8_QTDE, SW8.W8_PRECO, (SW8.W8_QTDE * SW8.W8_PRECO) W8_VLMOE, " + ENTER
cQuery += " SW9.W9_FILIAL, SW9.W9_HAWB, SW6.W6_DT_ENTR, SW9.W9_MOE_FOB " + ENTER
cQuery += " FROM "+ RetSqlName('SW6') +" SW6, "
cQuery += RetSqlName('SW8') +" SW8, "
cQuery += RetSqlName('SW9') +" SW9  " + ENTER

cQuery += " WHERE SW6.D_E_L_E_T_ =' ' "
cQuery += " AND SW8.D_E_L_E_T_ =' ' "
cQuery += " AND SW9.D_E_L_E_T_ =' ' " + ENTER

cQuery += " AND SW6.W6_FILIAL='"+cFilSW6+"' "
cQuery += " AND SW8.W8_FILIAL='"+cFilSW8+"' "
cQuery += " AND SW9.W9_FILIAL='"+cFilSW9+"'" + ENTER

cQuery += " AND SW6.W6_HAWB = SW9.W9_HAWB "
cQuery += " AND SW8.W8_INVOICE = SW9.W9_INVOICE " + ENTER

cQuery += "AND ((SW6.W6_CURRIER ='1' AND SW6.W6_DIRE<> ' ' ) OR (SW6.W6_CURRIER<>'1' AND SW6.W6_DI_NUM<>' '))" + ENTER

cQuery += " AND SW6.W6_DTREG_D >= '"+DTOS(dDtIni)+"' "
cQuery += " AND SW6.W6_DTREG_D <= '"+DTOS(dDtFim)+"' " + ENTER

If !Empty(cItem)
   cQuery +=" AND SW8.W8_COD_I = '"+cItem+"' " + ENTER
Endif

cQuery+=" ORDER BY SW8.W8_COD_I, SW6.W6_DTREG_D"

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS "cAlias_Q" NEW

If Select("cAlias_Q") <> 0
   TCSETFIELD("cAlias_Q","W6_DTREG_D","D")
   TCSETFIELD("cAlias_Q","W6_DT_ENTR","D")//SVG - 08/05/09 - Campo incluido - Data de entrega
Endif

Return .T.

*------------------------------*
Static Function IC150CriaWork()
*------------------------------*
Private aEstru := {}
AADD(aEstru,{ "COD_I"   , AVSX3("W8_COD_I", 02)  , AVSX3("W8_COD_I", 03)  , AVSX3("W8_COD_I", 04)})
AADD(aEstru,{ "DESCR"   , "C", 30, 0})
AADD(aEstru,{ "UNID_M"  , AVSX3("W8_UNID", 02)   , AVSX3("W8_UNID", 03)   , AVSX3("W8_UNID", 04)})
AADD(aEstru,{ "QTDE"    , AVSX3("W8_QTDE", 02)   , AVSX3("W8_QTDE", 03)   , AVSX3("W8_QTDE", 04)})
AADD(aEstru,{ "PRECO_U" , AVSX3("W8_PRECO", 02)  , AVSX3("W8_PRECO", 03)  , AVSX3("W8_PRECO", 04)})
AADD(aEstru,{ "VL_MOEDA", AVSX3("W8_VLMLE", 02)  , AVSX3("W8_VLMLE", 03)  , AVSX3("W8_VLMLE", 04)})
AADD(aEstru,{ "VL_REAL" , AVSX3("W8_FOBTOTR", 02), AVSX3("W8_FOBTOTR", 03), AVSX3("W8_FOBTOTR", 04)})
AADD(aEstru,{ "DT_REG"  , AVSX3("W6_DTREG_D", 02), AVSX3("W6_DTREG_D", 03), AVSX3("W6_DTREG_D", 04)})
AADD(aEstru,{ "DI_NUM"  , AVSX3("W6_DI_NUM", 02) , AVSX3("W6_DI_NUM", 03) , AVSX3("W6_DI_NUM", 04)})
//AAF - 25/06/04 - Campo adicionado no relat�rio
AADD(aEstru,{ "HAWB"    , AVSX3("W9_HAWB"   , 02), AVSX3("W9_HAWB", 03)   , AVSX3("W9_HAWB"   , 04)})
//SVG - 08/05/09 - Campo adicionado no relat�rio data do entrega
AADD(aEstru,{ "DT_ENTR"    , AVSX3("W6_DT_ENTR"   , 02), AVSX3("W6_DT_ENTR", 03)   , AVSX3("W6_DT_ENTR"   , 04)})
//TRP - 09/08/2012 - Campos adicionados na estrutura - Invoice/Fornecedor
AADD(aEstru,{ "INVOICE"    , AVSX3("W8_INVOICE"   , 02), AVSX3("W8_INVOICE", 03)   , AVSX3("W8_INVOICE"   , 04)})
AADD(aEstru,{ "FORN"       , AVSX3("W8_FORN"      , 02), AVSX3("W8_FORN", 03)      , AVSX3("W8_FORN"      , 04)})

If EasyEntryPoint("EICIC150") 
   ExecBlock("EICIC150", .F., .F., "IC150CRIAWORK_ADD_COL")
EndIf

cNomArq:=E_CriaTrab(,aEstru,"Work")
IndRegua("Work",cNomArq+TEOrdBagExt(),"COD_I")

Return .T.

*------------------------------*
Static Function IC150GRVWORK()
*------------------------------*
Local cFilSG1:= xFilial("SG1")

SB1->(dbSetOrder(1))
SG1->(dbSetOrder(2))

WORK->(avzap())

If lTop

   Do While cAlias_Q->(!EOF())

      If !SB1->(DbSeek(cFilSB1+cAlias_Q->W8_COD_I))
         cAlias_Q->(dbSkip())
         Loop
      Else
         If (cEstr == "1" .And. SG1->(DbSeek(cFilSG1+cAlias_Q->W8_COD_I))) .Or. cEstr == "2"
            Work->(DbAppend())
            Work->COD_I    := cAlias_Q->W8_COD_I
            Work->DESCR    := SB1->B1_DESC
            Work->UNID_M   := cAlias_Q->W8_UNID
            Work->QTDE     := cAlias_Q->W8_QTDE
            Work->PRECO_U  := cAlias_Q->W8_PRECO
            Work->VL_MOEDA := cAlias_Q->W8_VLMOE                                                                  
            //DFS - 26/11/10 - Refeito tratamento para que calcule apenas o pre�o total do item e n�o o do processo.
            Work->VL_REAL  := BUSCATAXA(cAlias_Q->W9_MOE_FOB, cAlias_Q->W6_DTREG_D,,.F.,.T.) * cAlias_Q->W8_VLMOE //cAlias_Q->W6_VLMLEMN 
            Work->DT_REG   := cAlias_Q->W6_DTREG_D 
            Work->DI_NUM   := cAlias_Q->W6_DI_NUM            
            //AAF - 25/06/04 - Campo adicionado no relat�rio
            Work->HAWB     := cAlias_Q->W9_HAWB
            // SVG - 08/05/09 - Campo adicionado no relat�rio data de entrega
            Work->DT_ENTR  := cAlias_Q->W6_DT_ENTR
            //TRP - 09/08/2012 - Campos adicionados na estrutura para serem utilizados no TRPOSITION.
            Work->INVOICE  := cAlias_Q->W8_INVOICE
            Work->FORN     := cAlias_Q->W8_FORN
             
            If(EasyEntryPoint("EICIC150"), ExecBlock("EICIC150",.F.,.F.,"Grv_Muro"), )

         Endif
         cAlias_Q->(dbSkip())
      Endif
   Enddo

Else

   SW6->(DBSETORDER(11))
   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))

   SW6->(dbseek(cFilSW6))

   Do While SW6->(!EOF()) .And. cFilSW6 == SW6->W6_FILIAL

      IF Empty(SW6->W6_DI_NUM)
         SW6->(DBSKIP())
         Loop
      ENDIF

      If !Empty(dDtIni) .AND. !Empty(SW6->W6_DTREG_D) .AND. SW6->W6_DTREG_D < dDtIni
         SW6->(DbSkip())
		 Loop
      Endif

      If !Empty(dDtFim) .AND. !Empty(SW6->W6_DTREG_D) .AND. SW6->W6_DTREG_D > dDtFim
	     SW6->(DbSkip())
		Loop
      Endif

      SW8->(DbSeek(cFilSW8+SW6->W6_HAWB))

      Do While SW8->(!EOF()) .AND. SW8->W8_FILIAL==cFilSW8 .And. SW8->W8_HAWB == SW6->W6_HAWB

         If !Empty(cItem) .AND. SW8->W8_COD_I <> cItem
            SW8->(DbSkip())
            Loop
         Endif

         If cEstr == "1" .And. !SG1->(DbSeek(cFilSG1+SW8->W8_COD_I))
            SW8->(DbSkip())
            Loop
         Endif

         SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))
         SB1->(DbSeek(cFilSB1+SW8->W8_COD_I))

         Work->(DbAppend())
         Work->COD_I    := SW8->W8_COD_I
         Work->DESCR    := SB1->B1_DESC
         Work->UNID_M   := SW8->W8_UNID
         Work->QTDE     := SW8->W8_QTDE
         Work->PRECO_U  := SW8->W8_PRECO
         Work->VL_MOEDA := SW8->W8_QTDE * SW8->W8_PRECO
         //Work->VL_REAL  := SW6->W6_VLMLEMN //* BUSCATAXA(SW9->W9_MOE_FOB, SW6->W6_DTREG_D,,.F.,.T.) - Nopado por Caio C�sar Henrique em 29/10/08 pois o campo W6_VLMLEMN j� possui tratamento de moeda
         // AST - 26/11/08
         If EasyGParam("MV_VLDIMOE",,.T.)
            Work->VL_REAL  := SW6->W6_VLMLEMN * BUSCATAXA(SW9->W9_MOE_FOB, SW6->W6_DTREG_D,,.F.,.T.)
         Else
            Work->VL_REAL  := SW6->W6_VLMLEMN
         EndIf
         Work->DT_REG   := SW6->W6_DTREG_D
         Work->DI_NUM   := SW6->W6_DI_NUM
         //AAF - 25/06/04 - Campo adicionado no relat�rio
         Work->HAWB     := SW9->W9_HAWB
         // SVG - 08/05/09 - Campo adicionado no relat�rio data de entrega
         Work->DT_ENTR  := SW6->W6_DT_ENTR 
         //TRP - 09/08/2012 - Campos adicionados na estrutura para serem utilizados no TRPOSITION.
         Work->INVOICE  := SW8->W8_INVOICE
         Work->FORN     := SW8->W8_FORN
         SW8->(DBSKIP())

      ENDDO

      SW6->(DbSkip())

   EndDo

Endif

If(EasyEntryPoint("EICIC150"), ExecBlock("EICIC150",.F.,.F.,"Fecha_View"), )

SW6->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SG1->(DBSETORDER(1))

Return .T.

*----------------------------------------------*
Static Function IC150REL(aDados,aRCampos,oMark)
*----------------------------------------------*
Local nRecno:=RECNO()

If DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
   aDados[7]:= STR0019+DTOC(dDtIni)+STR0020+DTOC(dDtFim) //"Per�odo de "###" at� "
ElseIf DTOC(dDtIni) <> "01/01/50" .And. DTOC(dDtFim) = "31/12/99"
   aDados[7]:= STR0021+DTOC(dDtIni) //"Per�odo - desde "
ElseIf DTOC(dDtIni) = "01/01/50" .And. DTOC(dDtFim) <> "31/12/99"
   aDados[7]:= STR0022+DTOC(dDtFim) //"Per�odo - at� "
Else
   aDados[7]:= STR0023 //"Per�odo de __/__/__ at� __/__/__"
Endif

If(lR4,(oReport := ReportDef(),oReport:PrintDialog()),E_Report(aDados,aRCampos))

DBGOTO(nRecno)

oMark:oBrowse:Refresh()

RETURN .T.


//TRP - 01/08/2006 - Defini��es do relat�rio personaliz�vel
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relat�rio
//aTabelas := {"SW6","SW8","SW9","SB1"}
Private oSecao1
aTabelas := {"SW2","SW6","SW8","SW9","SB1"}//Acb - 20/09/2010 - Inclus�o da tabela SW2

//Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
aOrdem   := { }

//Cria o objeto principal de controle do relat�rio.
//Par�metros:            Relat�rio ,Titulo ,Pergunte ,C�digo de Bloco do Bot�o OK da tela de impress�o.
oReport := TReport():New("EICIC150",STR0018,"EICIV1",{|oReport| ReportPrint(oReport)},STR0004+" "+STR0005)

//ER - 20/10/2006 - Inicia o relat�rio como paisagem. 
oReport:oPage:lLandScape := .T. 
oReport:oPage:lPortRait := .F. 

//Define o objeto com a se��o do relat�rio
oSecao1 := TRSection():New(oReport,"Itens Comprados",aTabelas,aOrdem) 

//Defini��o das colunas de impress�o da se��o 1
TRCell():New(oSecao1,"COD_I"       ,"Work"   ,STR0009      , cPictProd                        ,AVSX3("W8_COD_I", 03)            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DESCR"       ,"Work"   ,STR0010      ,/*Picture*/                       ,30                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"UNID_M"      ,"Work"   ,STR0011      ,cPictUni_M                        ,AVSX3("W8_UNID", 03)             ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"QTDE"        ,"Work"   ,STR0012      ,_PictQtde                         ,AVSX3("W8_QTDE", 03)             ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"PRECO_U"     ,"Work"   ,STR0013      ,_PictPrUn                         ,AVSX3("W8_PRECO", 03)            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VL_MOEDA"    ,"Work"   ,STR0014      ,_PictPrTot                        ,AVSX3("W8_VLMLE", 03)            ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"VL_REAL"     ,"Work"   ,STR0015      ,_PictPrTot                        ,AVSX3("W8_FOBTOTR", 03)          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DT_REG"      ,"Work"   ,STR0016      ,cPictDtReg                        ,AVSX3("W6_DTREG_D", 03)          ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DI_NUM"      ,"Work"   ,STR0017      ,cPictDi                           ,15                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"HAWB"        ,"Work"   ,STR0024      ,cPictHawb                         ,AVSX3("W9_HAWB", 03)             ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecao1,"DT_ENTR"     ,"Work"   ,STR0025      ,cPictDtEnt                        ,AVSX3("W6_DT_DESE",03)           ,/*lPixel*/,/*{|| code-block de impressao }*/)

If EasyEntryPoint("EICIC150") 
   ExecBlock("EICIC150", .F., .F., "REPORTDEF_ADD_COL")
EndIf

//Necess�rio para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Se��o 1")

//TRP - 09/08/2012 - Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Itens Comprados"),"SW6",1,{|| xFilial("SW6") + Work->HAWB })

TRPosition():New(oReport:Section("Itens Comprados"),"SW8",1,{|| xFilial("SW8") + Work->HAWB + Work->INVOICE + Work->FORN })

TRPosition():New(oReport:Section("Itens Comprados"),"SW9",1,{|| xFilial("SW9") + SW8->W8_INVOICE + SW8->W8_FORN})

TRPosition():New(oReport:Section("Itens Comprados"),"SW2",1,{|| xFilial("SW2") + SW8->W8_PO_NUM })  

TRPosition():New(oReport:Section("Itens Comprados"),"SB1",1,{|| xFilial("SB1") + SW8->W8_COD_I})

//oSection:Print()
oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->( dbGoTop() )

//Inicio da impress�o da se��o 1. Sempre que se inicia a impress�o de uma se��o � impresso automaticamente
//o cabe�alho dela.
oReport:Section("Itens Comprados"):Init()

//La�o principal
Do While Work->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Itens Comprados"):PrintLine() //Impress�o da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   Work->( dbSkip() )
EndDo

//Fim da impress�o da se��o 1
oReport:Section("Itens Comprados"):Finish() 

Return .T.
