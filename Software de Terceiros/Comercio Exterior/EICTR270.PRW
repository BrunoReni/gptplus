#INCLUDE "Eictr270.ch"
#include "AVERAGE.CH"
#DEFINE   _Agentes      STR0001 //"Agentes"
#DEFINE   _Despachantes STR0002 //"Despachantes"
#DEFINE   ATUAL  2
#DEFINE   TODOS  3
#COMMAND E_RESET_AREA => SW6->(DBSETORDER(1)) ; SY9->(DBSETORDER(1)) ;
                       ; TRB->(E_EraseArq(cNomArq)) ;
                       ; DBSELECTAREA(nOldArea)
/*

�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EICTR270 � Autor � AVERAGE/MJBARROS      � Data � 26.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Avaliacao de Agentes                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � EICTR270()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// EOS - OS 571/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR270
// um parametro como .T. identificando que � schedulado

*--------------------*
Function EICTR270S     
*--------------------*
EICTR270(.T.)
RETURN NIL

Function EICTR270(lSXD)

EICTR270R3(lSXD,.T.)

RETURN .t.

*---------------------*
Function EICTR270R3(lSXD,p_R4)     
*---------------------*
Local   lEICPTR02 := EasyEntryPoint("EICPTR02")
PRIVATE cQual     := _Agentes
Private cCpoAval1 := "W6_DTRECDO"
Private cCpoAval2 := "W6_CHEG"
Private aCampos   := {}
Private lEmail    := !lSXD = NIL  // EOS - OS 571/02
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
Private aPosicao  := {} //ASR - 19/10/2006 - Corrige erro na MSSelect que n�o apresenta todos os registros
Private cNome
If lEICPTR02
   ExecBlock("EICPTR02", .F., .F., "AGENTE")
Endif

aCampos := { "Y4_COMPLEM", "Y4_COD" ,"Y4_NOME" ,"W2_PO_NUM","W6_HAWB",;
             "W6_LOTE", cCpoAval1, cCpoAval2}



TR270Avalia()
Return .T.   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EICTR275 � Autor � AVERAGE/MJBARROS      � Data � 26.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Avaliacao de Despachantes                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � EICTR275()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// EOS - OS 571/02 - Funcao chamada somente pelo SCHEDULE passando p/ a funcao EICTR270
// um parametro como .T. identificando que � schedulado 
*--------------------*
Function EICTR275S     
*--------------------*

EICTR270(.T.)

RETURN NIL 

Function EICTR275(lSXD)

EICTR275R3(lSXD,.T.)

RETURN .t.
                 
*---------------------*
Function EICTR275R3(lSXD,p_R4) 
*---------------------* 
Local   lEICPTR02 := EasyEntryPoint("EICPTR02")
PRIVATE cQual     := _Despachantes
Private cCpoAval1 := "W6_DTRECDO"
Private cCpoAval2 := "W6_CHEG"
Private aCampos   := {}
Private lEmail    := !lSXD = NIL  // EOS - OS 571/02
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
Private cNome
If lEICPTR02
   ExecBlock("EICPTR02", .F., .F., "DESPACHANTE")
Endif

aCampos  := { "Y4_COMPLEM","Y4_COD" ,"Y4_NOME","W2_PO_NUM","W6_HAWB",;
              "W6_LOTE", cCpoAval1, cCpoAval2,"W6_DT_DESE"}

//If lR4
  // AAF - 20/06/2006 - Relat�rio Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef()
//EndIf

IF !lEmail
   bMsg:={|msg|MsProcTxt(msg)} 
   bProcessa:={|lEnd| TR270Sint(bMsg) }
ENDIF
TR270Avalia()
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TR270Avali� Autor � AVERAGE/MJBARROS      � Data � 26.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Avaliacao de Agentes / Despachantes               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*-----------------------*
Function TR270Avalia()   
*-----------------------*
LOCAL cAlias := If(cQual=_Agentes,"SY4","SY5") 

PRIVATE aRotina := { { STR0003, "AxPesqui"   , 0 , 1} ,; //"Pesquisar"
                     { STR0004, "TR270Visua" , 0 , 2} ,; //"Atual"
                     { STR0005, "TR270Visua" , 0 , 2} }  //"Todos"

PRIVATE cCadastro := OemtoAnsi(STR0006+cQual) //"Avaliacao de "

//��������������������������������������������������������������Ŀ
//� Recupera o desenho padrao de atualizacoes                    �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE (Pano de Fundo)                  �
//����������������������������������������������������������������

IF !lEmail  
   mBrowse( 6, 1, 22, 75, cAlias )
ELSE  // EOS - OS 571/02 Desvia, qdo schedulado, as apresentacoes em tela
   TR270Visua(cAlias, (cAlias)->(RECNO()),1)
ENDIF
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TR270Visua� Autor � MicroSiga/Average     � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de consulta p/ Avaliacao de Agentes/Despachantes  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TR270Visua(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*-------------------------------------*
FUNCTION TR270Visua(cAlias,nReg,nOpcx) 
*-------------------------------------*
LOCAL nOldArea:=SELECT(), oDlg, oGet, oPanel, aSave:={}
LOCAL nSavRec := RecNo(), cSaveMenuh, nCnt, cCodigo, cTitulo , bDate, bCodigo
LOCAL nPos, cPergunte := "EIC010", nI
Local aBackCampos := aClone(aCampos)
LOCAL aDados :={"TRB",;
                STR0007,; //"Este relatorio ir� exibir uma estat�stica sobre"
                STR0008,; //"o desempenho de "
                "",;
                "G",;
                 80,;
                "",;
                "",;
                STR0006,; //"Avaliacao de "
                { "Zebrado", 1,"Importa��o", 1, 2, 1, "",1 },;
                "EICTR270",;
                { {|| EICTR270totFil() } , {|| TotalPrzMed(.T.),FilAtu:="*" }  }  }

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private nPrazoMed:=0
Private aCamposTRB:={}, aRCampos:={}
Private nOpcBrowse:=nOpcX, aReturn := aDados[10]
Private aHeader[0],nUsado:=0, nOpcA:=0, lInverte:=.F., cMarca:=GetMark()
Private aFilSW6:={}
Private cFilSW6, lMultiFil, aTotFil:={}, aPrzMedFil:={}

SY9->(DBSetOrder(2))

If cQual = _Agentes
   SW6->(DBSetOrder(6))
   bDate  :=FieldWBlock(cCpoAval1  ,Select("SW6"))
   bCodigo:=FieldWBlock("W6_AGENTE",Select("SW6"))
   cCodigo:=SY4->Y4_COD
   aDados[3]+=STR0009 //"Agentes."
   aDados[9]+=STR0009 //"Agentes." 
   IF lEmail
      cPergunte := "EIC270"
   ENDIF
Else
   SW6->(DBSetOrder(2))
   bDate  :=FieldWBlock("W6_DT_DESE",Select("SW6"))
   bCodigo:=FieldWBlock("W6_DESP"   ,Select("SW6"))
   cCodigo:=SY5->Y5_COD
   aDados[3]+=STR0010 //"Despachantes."
   aDados[9]+=STR0010 //"Despachantes."
   IF lEmail
      cPergunte := "EIC275"
   ENDIF   
Endif

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01      // Data inicial                                �
//� mv_par02      // Data final                                  �
//����������������������������������������������������������������
// EOS - OS 571/02 Se for schedulado, chama o pergunte como .F. somente para
// inicializar as variaveis mv_par?? e atraves do setprint carrega as variaveis
IF !Pergunte(cPergunte,IIF(lEmail,.F.,.T.))
   RETURN .F.
ENDIF 
IF lEmail  
   cCodigo := mv_par03
ENDIF

aFilSW6:=AvgSelectFil(.T.,"SW6") // RS 28/12/05    - Filiais Selecionadas 


FilAtu:="*"
lMultiFil:= IF(LEN(aFilSW6)<>1,.T.,.F.)
If !lMultiFil//ASR - 19/10/2006
   If (nPos := aScan(aCampos, "Y4_COMPLEM")) > 0
      ADEL(aCampos, nPos)
      ASIZE(aCampos, LEN(aCampos)-1)
   EndIf
End If
aCamposTRB:= CriaEstru(aCampos,@aHeader) 
If lMultiFil//ASR - 19/10/2006
   aHeader[1,1]:=AVSX3("W6_FILIAL",5)
   AADD(aCamposTRB,{"WKFILIAL","C",FWSizeFilial(),0})
End If

AADD(aCamposTRB,{"XX_FLAGWIN","C",02,0})
AADD(aCamposTRB,{"WKPRAZO","N", 5,0})
If cQual = _Despachantes
   AADD(aCamposTRB,{"WKPRAZO_P","N", 5,0})
   AADD(aCamposTRB,{"WKPRAZO_D","N", 5,0})
Endif

AADD(aCamposTRB,{"WKREC_DI","N",10,0})
AADD(aHeader,{STR0011,"WKPRAZO","@E 99,999",5,0," ","   ","N",," "}) //"Prazo Realizado"

If cQual = _Despachantes
   AADD(aHeader,{STR0012,"WKPRAZO_P","@E 99,999",5,0," ","   ","N",," "}) //"Prazo Previsto"
   AADD(aHeader,{STR0013,"WKPRAZO_D","@E 99,999",5,0," ","   ","N",," "})//"Atraso/Antecipa��o"
Endif

IF(EasyEntryPoint("EICTR270"),Execblock("EICTR270",.F.,.F.,"ESTR_TRB"),)

AADD(aCamposTRB,{"WKOBS","C",30,0})
AADD(aHeader,{STR0014,"WKOBS","@!",30,0," ","   ","C",," "}) //"OBS"


//��������������������������������������������������������������Ŀ
//� Cria arquivo de trabalho e indice                            �
//����������������������������������������������������������������
cNomArq := E_CriaTrab(,aCamposTRB,"TRB") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IF !USED()
   IF !lEmail // EOS - OS 571/02 Desvia, qdo schedulado, as apresentacoes em tela
      Help(" ",1,"E_NAOHAREA")
   ENDIF
   E_RESET_AREA
   aCampos := aClone(aBackCampos)   //TRP-22/12/06
   RETURN .F.
ENDIF

TRB->(avzap())                                                           
DBClearIndex()
If lMultiFil//ASR - 19/10/2006
   INDEX ON TRB->WKFILIAL+TRB->Y4_COD+TRB->W2_PO_NUM TO (cNomArq)    
Else
   INDEX ON TRB->Y4_COD+TRB->W2_PO_NUM TO (cNomArq)
End If

aSaveAcampos:=ACLONE(aCampos)  

aSize(aCampos,0)                                    // p/ criacao correta de   
If lMultiFil//ASR - 19/10/2006
   AEval(aCamposTRB,{|campo| IF(campo[1]<>"Y4_COMPLEM",AAdd(aCampos,campo[1]),) }) // aRCampos
Else
   AEval(aCamposTRB,{|campo| AAdd(aCampos,campo[1]) }) // aRCampos
End If
E_CriaCampos(aRCampos,.T.,1)

aRCampos[1,3]:="E*"
aRCampos[2,3]:="E*"
aRCampos[5,3]:="D"

IF cQual # _Agentes
   aRCampos[10,3] :="D" ; aRCampos[11,3]:="D" ; aRCampos[12,3]:="D"
Else
   aRCampos[09,3] :="D"
ENDIF

IF lEmail  // EOS OS 571/02
   aDados[11] := SetPrint(aDados[1],aDados[11],,@aDados[9],aDados[2],aDados[3],aDados[4],.F.,,.T.,aDados[5])
   cCodigo := mv_par03
ENDIF

cTitulo:=STR0015+DTOC(mv_par01)+STR0016+DTOC(mv_par02) //"De "###" ate "

If  nOpcx # 2
    cCodigo:=SPACE(LEN(cCodigo))
Endif

aCampos:=ACLONE(aSaveaCampos) 
TRB->(avzap())
nTotalMedFil:=0


IF lEmail // EOS - OS 571/02 Desvia, qdo schedulado, as apresentacoes em tela
   for ni:=1 to LEN(aFilSW6)
       // RS - 29/12/05 - Multi-Filial      
      
      cFilSW6:=aFilSW6[ni]            
          
      TR270Grava(NIL,cCodigo,bCodigo,bDate,@nPrazoMed)
   next 
   
   IF TRB->(Easyreccount("TRB")) > 0
      FilAtu:="*"
      E_Report(aDados,aRCampos,.T.,.F.)   
   ENDIF
ELSE
   for ni:=1 to LEN(aFilSW6)
       // RS - 29/12/05 - Multi-Filial      
           
      cFilSW6:=aFilSW6[ni]                 
      
       Processa({|lEnd| ProcRegua(SW6->(Easyreccount("SW6"))),;
                       TR270Grava(,cCodigo,bCodigo,bDate,@nPrazoMed), .T. },STR0017) //"Pesquisando informa��es..."
   next                
   IF TRB->(Easyreccount("TRB")) > 0
      E_CriaCampos(aCamposTRB)
      AADD(aCamposTRB,{"WKPRAZO","", STR0011,"@E 99,999"})//"Prazo Realizado"
      If cQual = _Despachantes
         AADD(aCamposTRB,{"WKPRAZO_P","",STR0012 ,"@E 99,999"})//"Prazo Previsto"
         AADD(aCamposTRB,{"WKPRAZO_D","",STR0013 ,"@E 99,999"})//"Atraso/Antecipa��o"
      ENDIF   

      npos:=ASCAN(aCamposTRB,{|aTab|aTab[1]=="XX_FLAGWIN"})
      IF nPos <> 0
         ADEL(aCamposTRB,nPos)
         ASIZE(aCamposTRB,LEN(aCamposTRB)-1)
      ENDIF

	  IF(EasyEntryPoint("EICTR270"),Execblock("EICTR270",.F.,.F.,"ANTES_TELA"),)

      IF cQual # _Agentes
         oMainWnd:ReadClientCoors()
         DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo) ;
            FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
            OF oMainWnd PIXEL  
         @ 00,00 MsPanel oPanel Prompt "" Size 60,28 of oDlg //LRL 27/04/04 - Painel para alinhamento MDI.
         @08,(oDlg:nClientWidth-4)/2-70 BUTTON STR0018 SIZE 35,12 FONT oDlg:oFont ; //"Lead Time"
                                            ACTION (Processa(bProcessa)) OF oPanel PIXEL

             DEFINE SBUTTON FROM 08,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (FilAtu:="*",If(lR4,(oReport := ReportDef(),oReport:PrintDialog()) ,E_Report(aDados,aRCampos))) ENABLE OF oPanel
             //ASR - 18/10/2006 - Corrige erro na MSSelect que n�o apresenta todos os registros
             aPosicao := AVG_TELA()
//             oMark:=MsSelect():New("TRB",,,aCamposTRB,@lInverte,@cMarca,{35,5,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
             oMark:=MsSelect():New("TRB",,,aCamposTRB,@lInverte,@cMarca,{aPosicao[1,1],aPosicao[1,2],aPosicao[1,3],aPosicao[1,4]})
			 
			 oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT 
             oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
			 
         ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},;
                                                         {||nOpca:=0,oDlg:End()}))  //LRL 27/04/04 //Alinhamento MDI.  //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT            
      ELSE
         nPrazoMed:=Round(nTotalMedFil/TRB->(Easyreccount("TRB")),2)//ASR - 09/11/2006
         
         DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+OemToAnsi(cTitulo) ;
            FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
            OF oMainWnd PIXEL  
         @ 00,00  MSPANEL oPanel Prompt "" SIZE 60,16 OF oDlg //LRL 25/03/04 - Painel para Alinamento Mdi 
         @ 4,06  SAY  OemToAnsi(STR0013)  SIZE 70,08 OF oPanel PIXEL//"Atraso/Antecipa��o"
         @ 2,58  MSGET nPrazoMed WHEN .F. SIZE 52,10 OF oPanel PIXEL
         
   
         DEFINE SBUTTON oButton FROM 1,(oDlg:nClientWidth-4)/2-30 TYPE 6 ACTION (If(lR4,(oReport := ReportDef(),oReport:PrintDialog()) ,E_Report(aDados,aRCampos))) ENABLE OF oPanel

         dbSelectArea("TRB")
         dbGoTop()


         //ASR - 18/10/2006 - Corrige erro na MSSelect que n�o apresenta todos os registros
         aPosicao := AVG_TELA()
//         oGet:= MsSelect():New("TRB",,,aCamposTRB,@lInverte,@cMarca,{35,1,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
         oGet:= MsSelect():New("TRB",,,aCamposTRB,@lInverte,@cMarca,{aPosicao[1,1],aPosicao[1,2],aPosicao[1,3],aPosicao[1,4]})

         oGet:oBrowse:Refresh()
		 
		 oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT     // GFP - 30/07/2012 - Ajustado objeto Panel
		 oGet:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		 
         ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})) //LRL 25/03/04 -Alinhamento MDI   //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT    
         
         //AEVAL(aPrzMedFil,{|aTab|nPrazoMed+=aTab[3]})
         //E_SayLeadT(cCadastro+" - "+OemToAnsi(cTitulo),,nPrazoMed,aDados,aRCampos,.T.,aCamposTRB)
      ENDIF
      
   ELSE
      Help("", 1, "AVG0003000")//Nenhum Registro foi Encontrado!
   ENDIF
ENDIF   
TRB->(E_EraseArq(cNomArq))
SW6->(dbSetOrder(1))
dbSelectArea(cAlias)
dbGoTo(nSavRec)
aCampos := aClone(aBackCampos) //TRP-22/12/06
Return

*----------------------*
Function EICTR270Rel(aDados,aRCampos)
*----------------------*

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TR270Grava� Autor � AVERAGE-MJBARROS      � Data � 10/07/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao do Arquivo de Trabalho                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TR270Grava()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � EICTR270                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*----------------------------------------------------------*
FUNCTION TR270Grava(bMsg,cCodigo,bCodigo,bDate,nPrazoMed)   
*----------------------------------------------------------*
LOCAL nPrazoTot:=0, cMsg:=STR0019 //"Processando Conhecimento "
LOCAL bDataVar
LOCAL cFilSY45,cFilSW7, nQtdeRegFil:=0

local aFilSY4,aFilSY5,aFilSW7:={}  // Conceito multi-filial

IF !EMPTY(MV_PAR02)
   bDataVar:={|| (EVAL(bDate) >= mv_par01)  .And. (EVAL(bDate) <= mv_par02)}      
Else
   bDataVar:={||(.T.)}      
EndIf               

nPrazoMed:=0

IF cQual==_Agentes
   aFilSY4:=AvgSelectFil(.F.,"SY4")
   cFilSY45:=iif(len(aFilSY4)==1 .and. alltrim(aFilSY4[1])=="",aFilSY4[1],cFilSW6)
ELSE
   aFilSY5:=AvgSelectFil(.F.,"SY5")
   cFilSY45:=iif(len(aFilSY5)==1 .and. alltrim(aFilSY5[1])=="",aFilSY5[1],cFilSW6)
ENDIF         

If cCpoAval1 == "W6_DTRECDO" .And. !EMPTY(mv_par01)
   SW6->(DBSEEK(cFilSW6+DTOS(mv_par01),.T.))
ElseIf cCpoAval1 != "W6_DTRECDO"
   SW6->(dbSetOrder(1))
   SW6->(DBSEEK(cFilSW6))
Else                                          
   SW6->(dbSetOrder(1))
   SW6->(DBSEEK(cFilSW6))
EndIf    
            
WHILE ! SW6->(EOF()) .AND. SW6->W6_FILIAL == cFilSW6
   
  IF cCpoAval1 == "W6_DTRECDO"  
     IF ! EVAL(bDataVar)
        EXIT
     ENDIF
  ENDIF

  IF ! EVAL(bDataVar)                             
     SW6->(DBSKIP()) ; LOOP
  ENDIF
  
  IF ! EMPTY(cCodigo) .AND. cCodigo <> Eval(bCodigo)
     SW6->(DBSKIP()) ; LOOP
  ENDIF
  
  IF (cQual == _Agentes .OR. cQual == _Despachantes)
     IF EMPTY( SW6->W6_DTRECDO ) .OR. EMPTY( SW6->W6_CHEG )
        SW6->(DBSKIP()) ; LOOP
     ENDIF
  ENDIF
  
  IF cQual == _Despachantes .AND. EMPTY(SW6->W6_DT_DESE)
     SW6->(DBSKIP()) ; LOOP
  ENDIF  
   
  IF !lEmail
     IncProc()
  ENDIF
     
  IF bMsg # NIL
     Eval(bMsg,cMsg+W6_HAWB)
  ENDIF  
 
  SW7->(DBSEEK(cFilSW6+SW6->W6_HAWB))
  nPrazoTot+=TRB->(TR270Atualiza(bCodigo,cFilSY45))          
  nQtdeRegFil++    

  SW6->(DBSKIP())
END

AADD(aTotFil,{cFilSW6,AvgFilName({cFilSW6})[1],nPrazoTot})  // Total por Filial

IF Easyreccount("SW6") > 0
   nPrazoMed:=ROUND((nPrazoTot/nQtdeRegFil * 100)/100,0)
   AADD(aPrzMedFil,{cFilSW6,AvgFilName({cFilSW6})[1],nPrazoMed})
ENDIF   
dbGoTop()

IF(EasyEntryPoint("EICTR270"),Execblock("EICTR270",.F.,.F.,"POS_GRV_TRB"),)

RETURN .T.

*----------------------------------------------------------------------------
FUNCTION TR270DataAval(cCpoAval)
*----------------------------------------------------------------------------
Local cAlias
cAlias := If(Substr(cCpoAval,3,1)=="_", "S"+Substr(cCpoAval,1,2), Substr(cCpoAval,1,3))+"->"
cCpoAval:= cAlias+cCpoAval
Return(&cCpoAval)

*----------------------------------------------------------------------------
FUNCTION TR270Atualiza(bCodigo,cFilSY45)
*----------------------------------------------------------------------------
LOCAL cFilSY9,aFilSY9

TRB->(DBAPPEND())
If lMultiFil//ASR - 19/10/2006
   TRB->Y4_COMPLEM := SW6->W6_FILIAL+'-'+AvgFilName({SW6->W6_FILIAL})[1]
   TRB->WKFILIAL := SW6->W6_FILIAL
End If
TRB->Y4_COD     := Eval(bCodigo)
TRB->W2_PO_NUM  := SW7->W7_PO_NUM
TRB->W6_HAWB    := SW6->W6_HAWB
TRB->W6_LOTE    := SW6->W6_LOTE
TRB->&cCpoAval1 := TR270DataAval(cCpoAval1)
TRB->&cCpoAval2 := TR270DataAval(cCpoAval2)
TRB->WKOBS      := MEMOLINE(MSMM(SW6->W6_OBS,30),30,1)
TRB->WKREC_DI   := SW6->(RECNO())
IF cQual=_Agentes
   SY4->(DBSEEK(cFilSY45+TRB->Y4_COD))
   TRB->Y4_NOME    := SY4->Y4_NOME
   TRB->WKPRAZO    := E_VerPrazo(TR270DataAval(cCpoAval1) - TR270DataAval(cCpoAval2))
ELSE

   aFilSY9:=AvgSelectFil(.F.,"SY9")
   cFilSY9:=iif(len(aFilSY9)==1 .and. alltrim(aFilSY9[1])=="",aFilSY9[1],cFilSW6)

   SY5->(DBSEEK(cFilSY45+TRB->Y4_COD))
   TRB->Y4_NOME    := SY5->Y5_NOME
   TRB->W6_DT_DESE := SW6->W6_DT_DESE
   If(!Empty(SW6->W6_LOCAL),SY9->(DBSEEK(cFilSY9+SW6->W6_LOCAL)),SY9->(DBSEEK(cFilSY9+SW6->W6_DEST)) )//JVR - 14/04/2009 - tratamento do seek
   TRB->WKPRAZO_P  := SY9->Y9_LT_DES
   TRB->WKPRAZO    := E_VerPrazo(SW6->W6_DT_DESE - ;
                              IF(TRB->&cCpoAval1 > TRB->&cCpoAval2,;
                                 TRB->&cCpoAval1,  TRB->&cCpoAval2))
   TRB->WKPRAZO_D  := TRB->WKPRAZO - TRB->WKPRAZO_P
ENDIF
nTotalMedFil+=TRB->WKPRAZO
 
IF(EasyEntryPoint("EICTR270"),Execblock("EICTR270",.F.,.F.,"GRAVA_TRB"),)
RETURN TRB->WKPRAZO

*----------------------------------------------------------------------------*
FUNCTION TR270SINT(bMsg)
*----------------------------------------------------------------------------*
LOCAL OldTela, OldRecno:=RECNO(), OldArea:=SELECT(), nRec:=0, cFilSY9, aFilSY9

LOCAL WorkFile,oDlg,Tit270A:=STR0020, oMark //" Lead Time por Porto "
LOCAL oPanel //LRL 27/04/04
LOCAL T_DBF:={ {"WKFILIAL"   ,"C", FWSizeFilial(), 0 } ,;               
               {"WKNOMFIL"   ,"C", 21, 0 } ,;
               {"WKPORTO"    ,"C", 24, 0 } ,;
               {"WKREALIZ"   ,"N",  6, 0 } ,;
               {"WKPREVIS"   ,"N",  6, 0 } ,;
               {"WKREGISTRO" ,"N",  6, 0 } }

LOCAL bFor:={||IF(nOpcBrowse==ATUAL,SW6->W6_DESP==TRB->Y4_COD,.T.)}

LOCAL TB_Campos:={ {"WKNOMFIL"   ,"", AVSX3("W6_FILIAL",5) } ,; //"Filial"
                   {"WKPORTO"    ,"", STR0021  } ,; //"Porto"
                   {"WKPREVIS"   ,"", STR0012  } ,; //"Prazo Previsto"
                   {"WKREALIZ"   ,"", STR0022  } ,; //"Realizado"
                   {"WKREGISTRO" ,"", STR0013} } //"Atraso/Antecipa��o"

PRIVATE cMarca := GetMark(), lInverte := .F.

WorkFile := E_CriaTrab(,T_DBF,"Work") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IndRegua("Work",WorkFile+TEOrdBagExt(),"WKFILIAL+WKPORTO")

aFilSY9:=AvgSelectFil(.F.,"SY9")
cFilSY9:=iif(len(aFilSY9)==1 .and. alltrim(aFilSY9[1])=="",aFilSY9[1],cFilSW6)

Work->(DBGOTOP())
TRB->(DBGOTOP())   

TRB->(DBEVAL({|| IncProc(), TR270Grv(cFilSY9)}))            
  
//SW6->(DBSEEK(xFilial()))
ProcRegua(TRB->(Easyreccount("TRB")))

IF Work->(Easyreccount("Work")) == 0
   Help(" ",1,"EICSEMREG")
   Work->(E_EraseArq(WorkFile))
   DbSelectArea(OldArea)
   DBGOTO(OldRecno)
   Return .F.
ENDIF

DBGOTOP()
DBEVAL({||Work->WKPREVIS  :=ROUND(Work->WKPREVIS/Work->WKREGISTRO,0),;
          Work->WKREALIZ  :=ROUND(Work->WKREALIZ/Work->WKREGISTRO,0),;
          Work->WKREGISTRO:=Work->WKREALIZ-Work->WKPREVIS })

DBGOTOP()


   oMainWnd:ReadClientCoors()
   DEFINE MSDIALOG oDlg TITLE Tit270A ;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
               OF oMainWnd PIXEL  
   @ 00,00 MsPanel oPanel Prompt "" Size 60,28
   DEFINE SBUTTON FROM 06,(oDlg:nClientWidth-4)/2-30 TYPE 1 ACTION (oDlg:End()) ENABLE OF oPanel

   //ASR - 18/10/2006 - Corrige erro na MSSelect que n�o apresenta todos os registros
   aPosicao := AVG_TELA()
//   oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{26,5,(oDlg:nHeight-30)/2,(oDlg:nClientWidth-4)/2})
   oMark:= MsSelect():New("Work",,,TB_Campos,@lInverte,@cMarca,{aPosicao[1,1],aPosicao[1,2],aPosicao[1,3],aPosicao[1,4]})
   oDlg:lMaximized:=.T. //LRL 27/04/04 Maximiliza janela
   
   oPanel:Align:=CONTROL_ALIGN_TOP //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT 
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg ON INIT (Work->(dbGotop())) //LRL 27/04/0 //Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT


Work->(E_EraseArq(WorkFile))
DbSelectArea(OldArea)
DBGOTO(OldRecno)
Return .T. 

*----------------------------------------------------------------------------
FUNCTION TR270Grv(cFilSY9)
*----------------------------------------------------------------------------
Local cLocal := ""

SW6->(DBGOTO(TRB->WKREC_DI))
SY9->(DBSETORDER(2))
If !Empty(SW6->W6_LOCAL)//JVR - 14/04/2009 - verifica se local(w6), esta vazio para busca pelo destino(w6).
   cLocal := SW6->W6_LOCAL
Else                        
   cLocal := SW6->W6_DEST
EndIf
SY9->(DBSEEK(cFilSY9+cLocal))

//IF ! Work->(DBSEEK(LEFT(TRB->Y4_COMPLEM,2)+SW6->W6_LOCAL))   //FILIAL+PORTO
IF ! Work->(DBSEEK(xFilial("SW6")+cLocal))//FILIAL+PORTO //ASR - 19/10/2006
     Work->(DBAPPEND())
     Work->WKPORTO := cLocal+" "+SY9->Y9_DESCR
     Work->WKFILIAL:=xFilial("SW6")//LEFT(TRB->Y4_COMPLEM,2) //ASR - 19/10/2006
     Work->WKNOMFIL:=Work->WKFILIAL+"-"+AvgFilName({Work->WKFILIAL})[1]
ENDIF

Work->WKREALIZ  += TRB->WKPRAZO
Work->WKPREVIS  += SY9->Y9_LT_DES
Work->WKREGISTRO+= 1
RETURN .T.

*----------------------------------------------------------------------------*

*----------------------------------------------------------------------------
FUNCTION EICTR270totFil()                                                    
*----------------------------------------------------------------------------
IF FilAtu == "*" .AND. lMultiFil
   PulaLinha()
//   @ Linha,01 PSAY AVSX3("W6_FILIAL",5)+".: "+TRB->Y4_COMPLEM  //"Filial : "
   @ Linha,01 PSAY AVSX3("W6_FILIAL",5)+".: "+xFilial("SW6")  //"Filial : " //ASR - 19/10/2006
   PulaLinha()
//   FilAtu:=LEFT(TRB->Y4_COMPLEM,2)      
   FilAtu:=xFilial("SW6") //ASR - 19/10/2006
ENDIF   

//if lMultiFil .AND. FilAtu#LEFT(TRB->Y4_COMPLEM,2)            
if lMultiFil .AND. FilAtu#xFilial("SW6") //ASR - 19/10/2006
   
   PulaLinha()  
   TotalPrzMed()
   PulaLinha()
   PulaLinha()
        
   FilAtu:=TRB->WKFILIAL
   
//   @ Linha,01 PSAY AVSX3("W6_FILIAL",5)+".: "+TRB->Y4_COMPLEM  //"Filial : "    
   @ Linha,01 PSAY AVSX3("W6_FILIAL",5)+".: "+xFilial("SW6")  //"Filial : "  //ASR - 19/10/2006
   PulaLinha()      
ENDIF
RETURN .T.

*---------------------*
STATIC Function TotalPrzMed(lUlt)
*---------------------*
Local nPos, ncol:=124

if cQual # _Agentes
   nCol:=137
endif
    
IF ! lMultiFil .AND. FilAtu=="*"
   FilAtu:=cFilSW6
   PulaLinha()
ELSE
   PulaLinha()
   IF lUlt <> NIL
      PulaLinha()
   ENDIF

   npos:=ASCAN(aTotFil,{|fil|fil[1] == FilAtu})
   @ Linha, 075  PSAY "Total "+AVSX3("W6_FILIAL",5)+" .: "+aTotFil[npos,1]+'-'+aTotFil[npos,2]
   @ Linha, ncol PSAY TRANS(aTotFil[npos,3],"9999")
ENDIF

npos:=ASCAN(aPrzMedFil,{|fil|fil[1] == FilAtu})
TR_RelMed(113,aPrzMedFil[npos,3])
PulaLinha()       
return .t.

*--------------------------*                 
Static Function PulaLinha(cTexto)           
*--------------------------*
IF(valtype(cTexto) = "U", cTexto:="",.T.)
IF Linha >= 60
   Linha := 0
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   If ! Empty(cTexto)
     Linha += 1
     @ Linha, 010 PSAY cTexto
   EndIf
Else                                                                     
   Linha++
Endif

Return .T.

//TRP - 20/06/2006 - Defini��es do relat�rio personaliz�vel
***************************
Static Function ReportDef()
***************************

//Alias que podem ser utilizadas para adicionar campos personalizados no relat�rio

If cQual= _Agentes 
   cNome:= "Agentes"
   aTabelas := {"SY4","SW2","SW6"}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
   aOrdem   := {}

   //Cria o objeto principal de controle do relat�rio.
   //Par�metros:            Relat�rio ,Titulo ,Pergunte ,C�digo de Bloco do Bot�o OK da tela de impress�o.
   oReport := TReport():New("EICTR270",STR0006+STR0001,"EIC270",{|oReport| ReportPrint(oReport)},STR0007+" "+STR0001)
   
   //ER - 20/10/2006 - Inicia o relat�rio como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F.


   //Define o objeto com a se��o do relat�rio
   oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)

   //Defini��o das colunas de impress�o da se��o 1
   TRCell():New(oSecao1,"Y4_COD"   ,"TRB",/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"Y4_NOME"  ,"TRB",/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W2_PO_NUM","TRB",/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_HAWB"  ,"TRB",/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_LOTE"  ,"TRB",STR0023      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,cCpoAval1  ,"TRB",STR0024      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,cCpoAval2  ,"TRB",/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WKPRAZO"  ,"TRB",STR0011      ,"@E 99,999"                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WKOBS"    ,"TRB",STR0014      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)

   oReport:Section(cNome):Cell("W6_LOTE"   ):SetColSpace(3)
   oReport:Section(cNome):Cell(cCpoAval1   ):SetColSpace(3)
   oReport:Section(cNome):Cell(cCpoAval2   ):SetColSpace(3)
   oReport:Section(cNome):Cell("WKPRAZO"   ):SetColSpace(3)
   oReport:Section(cNome):Cell("WKOBS"     ):SetColSpace(3)

ELSE

   cQual= _Despachantes
   cNome:= "Despachantes"
   aTabelas := {"SY4","SW2","SW6"}

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
   aOrdem   := {}

   //Cria o objeto principal de controle do relat�rio.
   //Par�metros:            Relat�rio ,Titulo ,Pergunte ,C�digo de Bloco do Bot�o OK da tela de impress�o.
   oReport := TReport():New("EICTR275",STR0006+STR0002,"EIC275",{|oReport| ReportPrint(oReport)},STR0007+" "+STR0002)

   //ER - 20/10/2006 - Inicia o relat�rio como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F.
   
   //Define o objeto com a se��o do relat�rio
   oSecao1 := TRSection():New(oReport,cNome,aTabelas,aOrdem)

   //Defini��o das colunas de impress�o da se��o 1
   TRCell():New(oSecao1,"Y4_COD"   ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"Y4_NOME"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W2_PO_NUM","TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_HAWB"  ,"TRB"  ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_LOTE"  ,"TRB"  ,STR0023      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,cCpoAval1  ,"TRB"  ,STR0024      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,cCpoAval2  ,"TRB"  ,STR0025      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_DESE","TRB" ,STR0026      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WKPRAZO"  ,"TRB"  ,STR0011      ,"@E 99,999"                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WKPRAZO_P","TRB"  ,STR0012      ,"@E 99,999"                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WKPRAZO_D","TRB"  ,STR0013      ,"@E 99,999"                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"WKOBS"    ,"TRB"  ,STR0014      ,"@!"                              ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)

   oReport:Section(cNome):Cell("Y4_COD"    ):SetColSpace(3)
   oReport:Section(cNome):Cell("Y4_NOME"   ):SetColSpace(3)
   oReport:Section(cNome):Cell("W2_PO_NUM" ):SetColSpace(3)
   oReport:Section(cNome):Cell("W6_HAWB"   ):SetColSpace(3)
   oReport:Section(cNome):Cell("W6_LOTE"   ):SetColSpace(3)
   oReport:Section(cNome):Cell(cCpoAval1   ):SetColSpace(3)
   oReport:Section(cNome):Cell(cCpoAval2   ):SetColSpace(3)
   oReport:Section(cNome):Cell("W6_DT_DESE"):SetColSpace(3)
   oReport:Section(cNome):Cell("WKPRAZO"   ):SetColSpace(3)
   oReport:Section(cNome):Cell("WKPRAZO_P" ):SetColSpace(3)
   oReport:Section(cNome):Cell("WKPRAZO_D" ):SetColSpace(3)
   oReport:Section(cNome):Cell("WKOBS"     ):SetColSpace(3)

ENDIF 

oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Prazo M�dio em Dias")

oTotal:= TRFunction():New(oSecao1:Cell("WKPRAZO"),NIL,"SUM",/*oBreak*/,"","@E 99,999",{|| TRB->WKPRAZO/TRB->(EasyRecCount("TRB")) },.T.,.F.)
oTotal:SetTotalInLine(.F.)


//Necess�rio para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport
************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Se��o 1")

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section(cNome),"SY4",1,{|| xFilial("SY4") + TRB->Y4_COD})

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section(cNome),"SW2",1,{|| xFilial("SW2") + TRB->W2_PO_NUM})

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section(cNome),"SW6",1,{|| xFilial("SW6") + TRB->W6_HAWB})

//oSection:Print()
oReport:SetMeter (TRB->(EasyRecCount("TRB")))
TRB->( dbGoTop() )

//Inicio da impress�o da se��o 1. Sempre que se inicia a impress�o de uma se��o � impresso automaticamente
//o cabe�alho dela.
oReport:Section(cNome):Init()

//La�o principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section(cNome):PrintLine() //Impress�o da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo

//Fim da impress�o da se��o 1
oReport:Section(cNome):Finish()
TRB->( dbGoTop() )
Return .T.
