//#include "FiveWin.ch"
#include  "Average.ch"
#include  "EICTR260.ch"

#DEFINE   Atracacao    "1"
#DEFINE   Pagamento    "2"
#DEFINE   Desembaraco  "3"
#DEFINE   AtracaSemLI  "4"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EICTR260 � Autor � AVERAGE/MJBARROS      � Data � 18.07.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Follow-Up de Atracacao/D.I./Desembaraco           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � EICTR260()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
// Alterado Heder M Oliveira 26/11/99 12:08
*/
Function EICTR260()

EICTR260R3(.T.)

RETURN .t.


*------------------*
Function EICTR260R3(p_R4)
*------------------*
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro :=STR0001       //"Aguardando Atraca��o"
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
PRIVATE cQual :=Atracacao


//If lR4
   //AAF - 20/06/2006 - Relat�rio Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef()
//EndIf

E_SelEmbar(Atracacao)
Return .T.



Function EICTR261()

EICTR261R3(.T.)

RETURN .t.

*------------------*
Function EICTR261R3(p_R4)
*------------------*
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0002      //"Aguardando D.I."
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
PRIVATE cQual:= Pagamento



//If lR4
   //AAF - 20/06/2006 - Relat�rio Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef()
//EndIf

E_SelEmbar(Pagamento)

Return .T.

Function EICTR262()

EICTR262R3(.T.)

RETURN .t.

*------------------*
Function EICTR262R3(p_R4)
*------------------*
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0003      //"Aguardando Desembaraco"
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
PRIVATE cQual:= Desembaraco



//If lR4
   //AAF - 20/06/2006 - Relat�rio Personalizavel - Release 4
   //ReportDef cria os objetos.
   //oReport := ReportDef()
//EndIf

E_SelEmbar(Desembaraco)
Return .T.



*------------------*
Function EICTR263()
*------------------*
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0023      //"Atracado Sem LI"
Private lR4       := .f.

E_SelEmbar(AtracaSemLI)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �E_SelEmbar� Autor � MicroSiga/Average     � Data � 17.07.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Follow-Up de Atracacao/D.I./Desembaraco           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � E_SelEmbar(cQual)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cQual = "1" Atracacao, "2" Pagamento, "3" Desembaraco      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAEIC                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*-------------------------*
FUNCTION E_SelEmbar(cQual)
*-------------------------*
LOCAL cSaveMenuh, nCnt, cIndice2

LOCAL nOldArea:=SELECT(), oDlg, oGet

Private aCamposTRB:={} //DRL 08/07/10

Private aDados:={} //DRL 08/07/10

Private nPrazoMed:=0, aRCampos:={} //DRL 08/07/10

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aCampos:={}

// aRotina declarada apenas para compatibilizar com GetDadDB

PRIVATE aRotina := { { STR0004           , "AxPesqui"  , 0 , 1} ,;   //"Pesquisar"
                     { STR0005           , "C210Impor" , 0 , 2} ,;   //"Atual"
                     { STR0006           , "C210Impor" , 0 , 3} }    //"Todos"

PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

Private aHeader[0],nUsado:=0, nOpcA:=0
Private _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)

bCampo := {|nCPO| Field(nCPO) }

Private cDiasUt := "�teis"  //NCF - 11/05/09
Private lDlgFilCusto := .F., lDlgBrwCustos := .F., aSemSX3 := {}, cTitulo, cImportador //DRL 07/07/10

//������������������������������������������������������Ŀ
//� Cria WorkFile para GetDadDB()                        �
//��������������������������������������������������������
IF cQual = Atracacao .OR. cQual = AtracaSemLI
   AADD(aCampos,"W6_FLAG")
ENDIF

AADD(aCampos,"W6_HAWB")
AADD(aCampos,"W6_DT_HAWB")
AADD(aCampos,"W7_PO_NUM")

IF cQual = Atracacao .OR. cQual = Pagamento  .OR. cQual = AtracaSemLI
   AADD(aCampos,"W7_FORN")
   If EICLoja()
      AADD(aCampos,"W7_FORLOJ")
   EndIf
   AADD(aCampos,"A2_NREDUZ")
ENDIF

AADD(aCampos,"W6_DT_EMB")

IF cQual = Atracacao .OR. cQual = AtracaSemLI
   AADD(aCampos,"W6_DT_ETA")
   AADD(aCampos,"W2_TIPO_EM")
   AADD(aCampos,"W1_PRAZO")
   AADD(aCampos,"YR_TRANS_T")
   AADD(aCampos,"W6_IDENTVE")
   IF cQual = AtracaSemLI
     AADD(aCampos,"W6_ORIGEM" )
     AADD(aCampos,"W6_DEST" )
   ENDIF
Endif               

IF cQual = Desembaraco .OR. cQual = Pagamento
   IF cQual = Desembaraco 
      AADD(aCampos,"W6_DI_NUM")
      AADD(aCampos,"W6_DTREG_D")
      AADD(aCampos,"W6_CHEG")
      AADD(aCampos,"W1_PRAZO")
      AADD(aCampos,"W6_LOCAL")
      AADD(aCampos,"YR_TRANS_T")
   Else
      AADD(aCampos,"W6_CHEG")
      AADD(aCampos,"W1_PRAZO")
      AADD(aCampos,"W6_LOCAL")
      AADD(aCampos,"YR_TRANS_T")  
   ENDIF
ENDIF

aAdd(aSemSX3,{"W6_FLAG","L",1,0}) //DRL 07/07/10

If(EasyEntryPoint("EICTR260"),Execblock("EICTR260",.F.,.F.,"TR260CAMPOS"),)  // EOB - 19/01/10

cNomArq:= E_CriaTrab(,aSemSX3) //DRL 07/07/10
IndRegua("TRB",cNomArq+TEOrdBagExt(),"W6_HAWB+W7_PO_NUM")

aHeader[ASCAN(aHeader,{|x|x[2]=="W1_PRAZO"})][1] := STR0007    //"Prazo Decorrido"


aHeader[ASCAN(aHeader,{|x|x[2]=="YR_TRANS_T"})][1] := ;
        IF(cQual = Atracacao,STR0008,STR0009)  //"Transit Time Previsto"###"Prazo Previsto Desemb."

IF cQual = Desembaraco
   aHeader[ASCAN(aHeader,{|x|x[2]=="W6_CHEG"})][1] := AVSX3("W6_DT")[5]
ENDIF
//��������������������������������������������������������������Ŀ
//� Cria arquivo de trabalho                                     �
//����������������������������������������������������������������

DO WHILE .T.
  IF !lDlgFilCusto .And. ! E_GetImp(@cImportador,@cTitulo,@cDiasUt,.T.) //DRL 07/07/2010
     EXIT
  ENDIF
  
  lLoop := .F. //DRL 07/07/10 - Caso o Dlg Customizado Retorna Falso
  If(EasyEntryPoint("EICTR260"),Execblock("EICTR260",.F.,.F.,"TR260DIALOG_CUSTO"),) //DRL 07/07/10 - Caso Seja um Dialog Customizado
  If lLoop //DRL 07/07/10
     EXIT
  EndIf
  
  aDados :={"TRB",;
            STR0010,;          //"Este relatorio ir� emitir a rela��o de processos"
            STR0011,;          //"aguardando "
            "",;
            "G",;
            80,;
            "",;
            "",;
            STR0012,;          //"Aguardando "
            { STR0013, 1,STR0014, 1, 2, 1, "",1 },; //"Zebrado"###"Importa��o"
            "EICTR260",;
            { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }

  SY9->(DBSETORDER(2))
  SW6->(DBSETORDER(2))
      Processa({|lEnd| ProcRegua(SW6->(LastRec())),;
                       SW6->(nPrazoMed:=TR260Grava(cQual,cImportador)), .T. })
  SY9->(DBSETORDER(1))
  SW6->(DBSETORDER(1))

  E_CriaCampos(aRCampos,.T.,IF(cQual = Atracacao .OR. cQual = AtracaSemLI,2,1))

  aRCampos[1,3]:="E"
  IF cQual = Atracacao .OR. cQual = AtracaSemLI
     aDados[3]+=STR0015       //"atraca��o."
     aDados[9]+=STR0016       //"Atracacao."
     aRCampos[1,3]:="E" ; aRCampos[3,3]:="E" ; aRCampos[9,3]:="D" ; aRCampos[10,3]:="D"
  ELSEIF cQual = Pagamento
     aDados[3]+=STR0017      //"a Declaracao de Importacao."
//   aDados[5]:="M"
     aDados[9]+=STR0018      //"D.I."
     aRCampos[1,3]:="E" ; aRCampos[5,3]:="E" ; aRCampos[8,3]:="D" ; aRCampos[9,3]:="D"
  ELSE
     aDados[3]+=STR0019      //"desembara�o"
//   aDados[5]:="M"
     aDados[9]+=STR0020      //"Desembaraco."
     aRCampos[1,3]:="E" ; aRCampos[6,3]:="D" ; aRCampos[7,3]:="D"
  ENDIF
  If(EasyEntryPoint("EICTR260"),Execblock("EICTR260",.F.,.F.,"TR260ANTES_BROWSE"),) //DRL 08/07/10 - Add no Browse visual
  IF !EMPTY(TRB->W6_HAWB)
     TRB->(DBGOTOP())
     If !lDlgBrwCustos //DRL 08/07/10
        E_SayLeadT(cCadastro+" - "+cTitulo,,nPrazoMed,aDados,aRCampos,nil,nil,nil, If(lR4, {|| (oReport := ReportDef(),oReport:PrintDialog())},NIL))
     EndIf
     TRB->(avzap())
  ELSE
     Help("", 1, "AVG0000657")//Nao ha Registros a serem Listados
  ENDIF
  IF nOpca == 0
     EXIT
  ENDIF
ENDDO

TRB->(E_EraseArq(cNomArq))
DBSELECTAREA(nOldArea)
Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TR260Grava� Autor � AVERAGE-MJBARROS      � Data � 18.07.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravacao do Arquivo de Trabalho                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TR260Grava()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � EICTR260                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*---------------------------------------------*
STATIC FUNCTION TR260Grava(cQual,cImportador)
*---------------------------------------------*
LOCAL nConta:=0, nPrazoTot:=0,d_Emb:=DTOS(AVCTOD("01/01/"+_FirstYear)),PHawb,TB_House:={}
LOCAL b_date:={|qual|IF( qual="1",SW6->W6_DT_EMB,IF(qual="2",SW6->W6_CHEG,SW6->W6_DT) ) }
LOCAL cNomeProc:=Avsx3("W6_HAWB",5)+": "

SW6->(DBSETORDER(3))       
cKeyDt :=d_Emb

SW6->(DBSEEK(xFilial("SW6")+cKeyDt,.T.))

DO WHILE !SW6->(EOF()) .AND. SW6->W6_FILIAL==xFilial("SW6") .AND.  !EMPTY(SW6->W6_DT_EMB)

   IncProc(cNomeProc+SW6->W6_HAWB)
   
   //JVR - 03/12/09 - Atualizado tratamento de Loop do while
   Do CASE
      CASE cQual = Atracacao
         IF SW6->W6_DT_EMB >  dDataBase
            EXIT
         ENDIF
         IF (SW6->W6_TIPOFEC == "DIN" .AND. VAL(SW6->(W6_TIPODES)) >= 14 .AND. VAL(SW6->(W6_TIPODES)) <= 16) .OR.;
            !EMPTY(SW6->W6_CHEG) .OR.;
            !EMPTY(SW6->W6_DT_ENCE)//JVR - 03/12/09 - verifica data de encerramento
            SW6->(DBSKIP())
            LOOP
          ENDIF

      CASE cQual = Pagamento
         IF !EMPTY(SW6->W6_DI_NUM) .OR.;
            !EMPTY(SW6->W6_DT_ENCE) .OR. (SW6->W6_CURRIER == "1" .And. !Empty(SW6->W6_DIRE)) //FDR - 21/07/2012 - Adicionado tratamento para processos currier
            SW6->(DBSKIP())
            LOOP
         ENDIF                    
      
      CASE cQual = Desembaraco
         IF ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04") .OR.; //Processos com entreposto aduaneiro.
            (EMPTY(SW6->W6_DT) .or. !EMPTY(SW6->W6_DT_DESE)  .or. !EMPTY(SW6->W6_DT_ENCE)) .OR.;
            !EMPTY(SW6->W6_DT_ENCE)//JVR - 03/12/09 - verifica data de encerramento
            SW6->(DBSKIP())
            LOOP
         ENDIF   

      CASE cQual = AtracaSemLI
         If SW6->W6_DT_EMB >= dDataBase
            SW6->(DBSKIP())
            LOOP
         EndIf
   EndCASE

//   SE cQual = Atracacao .AND. W6_DT_EMB >= dDataBase
//   Segund LAB deve-se desprezar apenas qdo Dt Embarque maior que atual
/*   
   IF cQual = Atracacao .AND. SW6->W6_TIPOFEC == "DIN" .AND. VAL(SW6->(W6_TIPODES))>=14 .AND. VAL(SW6->(W6_TIPODES))<=16
      SW6->(DBSKIP())
      LOOP
   ENDIF
   
   IF (cQual = Atracacao .AND. SW6->W6_DT_EMB >  dDataBase) .OR. (cQual = AtracaSemLI .AND. SW6->W6_DT_EMB>=dDataBase)
      EXIT
   ENDIF
   
   IF (cQual = Atracacao .AND. (!EMPTY(SW6->W6_CHEG) .OR. !EMPTY(SW6->W6_DT_ENCE)))
      SW6->(DBSKIP())
      LOOP
   ENDIF

   //TRP- 12/03/09
   IF (cQual = Pagamento .AND. !EMPTY(SW6->W6_DI_NUM))    //!EMPTY(SW6->W6_DT))ASR 28/12/2005 - CORRE��O DO FILTRO - AGUARDANDO DI - EMPTY(SW6->W6_CHEG)
      SW6->(DBSKIP())
      LOOP
   ENDIF   

   IF (cQual = Desembaraco .AND. ALLTRIM(SW6->W6_TIPODES) $("2/3/4/02/03/04"))   //TRP- 12/03/09 - Processos com entreposto aduaneiro.
      SW6->(DBSKIP())
      LOOP
   ENDIF   
   
   IF (cQual = Desembaraco .AND. (EMPTY(SW6->W6_DT) .OR. !EMPTY(SW6->W6_DT_DESE)  .OR. !EMPTY(SW6->W6_DT_ENCE)))  //ASR 03/11/2005 - CORRE��O DO FILTRO - AGUARDANDO DESEMBARA��O "DATA EM BRANCO"
      SW6->(DBSKIP())
      LOOP
   ENDIF
*/   
   
   SW7->( DBSEEK(xFilial()+SW6->W6_HAWB) )

   DO WHILE ! SW7->(EOF()) .AND. SW7->W7_FILIAL == xFilial("SW7") .AND. SW7->W7_HAWB = SW6->W6_HAWB

      SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))
      SA2->(DBSEEK(xFilial()+SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")))

      IF cQual = Atracacao .OR. cQual = AtracaSemLI
         SYR->(DBSEEK(xFilial()+SW2->W2_TIPO_EMB+SW2->W2_ORIGEM+SW2->W2_DEST))
         IF ! EMPTY(SW6->W6_VIA_TRAN)
            SYR ->(DBSEEK(xFilial()+SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST))
         ENDIF

      ENDIF

      IF ! EMPTY(cImportador) .AND. SW2->W2_IMPORT # cImportador
         SW7->( DBSKIP() ) ; LOOP
      ENDIF                                   
      
      IF cQual = Atracacao .OR. cQual = AtracaSemLI  // CCM - 19/05/09 - So coloca o prazo caso o campo W6_CHEG esteka preenchido.                        
         If EMPTY(SW6->W6_DT_EMB)      
            SW6->(DBSKIP())
            LOOP
         Endif
       ELSE                       
         IF EMPTY(SW6->W6_CHEG)
            SW6->(DBSKIP())
            LOOP
         ENDIF
       ENDIF     
         
      IF cQual = AtracaSemLI
        IF SW7->W7_FLUXO = "7"
          SW7->(DBSKIP())
          LOOP
        ELSE
          SWP->(DBSEEK(xFilial() + SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
          IF !EMPTY(SWP->WP_REGIST)
            SW7->(DBSKIP())
            LOOP
          ENDIF
        ENDIF
      ENDIF

      lLoop:=.F.
      If(EasyEntryPoint("EICTR260"),Execblock("EICTR260",.F.,.F.,"TR260VALID_GRAVA"),)
      If lLoop
         SW7->(DBSKIP())
         LOOP
      EndIf

      IF ! TRB->(DBSEEK(SW7->W7_HAWB+SW7->W7_PO_NUM))
         TRB->( DBAPPEND() )
         TRB->W6_HAWB    := SW6->W6_HAWB
         TRB->W6_DT_HAWB := SW6->W6_DT_HAWB
         TRB->W6_DT_EMB  := SW6->W6_DT_EMB
         TRB->W7_PO_NUM  := SW7->W7_PO_NUM
         IF cQual = Atracacao .OR. cQual = AtracaSemLI
            //TRB->W1_PRAZO   := E_VerPrazo(dDataBase - TRB->W6_DT_EMB)
            IF cDiasUt = "�teis"                                                         //NCF - 11/05/09 - Adicionada esta condi��o para contagem do prazo,com ou sem dias �teis, � escolha do usu�rio. 
               TRB->W1_PRAZO := E_VerPrazo(Dias_Uteis(TRB->W6_DT_EMB,dDataBase)) 
            ELSE
               TRB->W1_PRAZO := E_VerPrazo(Dias_Corridos(TRB->W6_DT_EMB,dDataBase))
            ENDIF
         Else
            TRB->W6_CHEG    := EVAL(b_date,cQual)
            //TRB->W1_PRAZO   := E_VerPrazo(dDataBase - TRB->W6_CHEG)
            IF cDiasUt = "�teis"
               TRB->W1_PRAZO   := E_VerPrazo(Dias_Uteis(TRB->W6_CHEG,dDataBase))
            ELSE
               TRB->W1_PRAZO   := E_VerPrazo(Dias_Corridos(TRB->W6_CHEG,dDataBase))
            ENDIF
         Endif
         IF TRB->W1_PRAZO < 0
            TRB->W1_PRAZO :=0
         ENDIF
         IF cQual = Pagamento
            IF (PHawb := ASCAN(TB_House,TRB->W6_HAWB)) = 0
               IF ! SY9->(DBSEEK(xFilial()+SW6->W6_LOCAL)) .OR. SY9->Y9_DAP $ cNao
                  nConta++ ; nPrazoTot+= TRB->W1_PRAZO
                  AADD(TB_House,TRB->W6_HAWB)
               ENDIF
            ENDIF
         ELSE
            nConta++ ; nPrazoTot+= TRB->W1_PRAZO
         ENDIF

         IF cQual = Atracacao .OR. cQual = AtracaSemLI
            TRB->YR_TRANS_T := SYR->YR_TRANS_T
            TRB->W6_DT_ETA  := IF(!EMPTY(SW6->W6_DT_ETA),SW6->W6_DT_ETA,SW6->W6_DT_EMB+SYR->YR_TRANS_T)
            TRB->W6_IDENTVE := SW6->W6_IDENTVE
            TRB->W7_FORN    := SW7->W7_FORN
            If EICLoja()
               TRB->W7_FORLOJ:= SW7->W7_FORLOJ
            EndIf
            TRB->A2_NREDUZ  := SA2->A2_NREDUZ
            TRB->W6_FLAG    := .T.
//            TRB->W2_TIPO_EM:= IF(SYQ->(DBSEEK(xFilial()+SW2->W2_TIPO_EM)),SUBSTR(SYQ->YQ_DESCR,1,10),SPACE(10)) // ACB - 13/04/2010
			TRB->W2_TIPO_EM := POSICIONE("SYQ",1,XFILIAL("SYQ")+SW2->W2_TIPO_EM,"YQ_VIA") // ACB - 13/04/2010
            IF cQual = AtracaSemLI
              TRB->W6_ORIGEM  := SYR->YR_ORIGEM
              TRB->W6_DEST := SYR->YR_DESTINO
            ENDIF
         ELSEIF cQual = Pagamento
            TRB->YR_TRANS_T:= IF(SY9->(DBSEEK(xFilial()+SW6->W6_LOCAL)),SY9->Y9_LT_DES,0)
            TRB->W6_LOCAL  := SW6->W6_LOCAL
            TRB->W7_FORN   := SW7->W7_FORN
            If EICLoja()
               TRB->W7_FORLOJ:= SW7->W7_FORLOJ
            EndIf
            TRB->A2_NREDUZ := SA2->A2_NREDUZ
         ELSE

            TRB->YR_TRANS_T := IF(SY9->(DBSEEK(xFilial()+SW6->W6_LOCAL)),SY9->Y9_LT_DES,0)
            TRB->W6_DI_NUM  := SW6->W6_DI_NUM
            TRB->W6_DTREG_D := SW6->W6_DTREG_D
            TRB->W6_LOCAL   := SW6->W6_LOCAL
         ENDIF
         
         If(EasyEntryPoint("EICTR260"),Execblock("EICTR260",.F.,.F.,"TR260GRAVA"),)  // EOB - 19/01/10
                  
      ENDIF
      SW7->( DBSKIP() )
   ENDDO
   DBSKIP()
ENDDO

IF EMPTY(nConta)
   nConta:=1 ; nPrazoTot:=0
ENDIF

SW6->(DBSETORDER(1))

IF cQual <> Pagamento
   RETURN ( INT((nPrazoTot/nConta * 100)/100) )
ELSE
   RETURN ( INT((nPrazoTot / IF(LEN(TB_House) # 0,LEN(TB_House),1)*100)/100) )
ENDIF

RETURN



//TRP - 20/06/2006 - Defini��es do relat�rio personaliz�vel
***************************
Static Function ReportDef()
***************************

IF cQual= Atracacao 

   //Alias que podem ser utilizadas para adicionar campos personalizados no relat�rio

   aTabelas := {"SW6","SW7","SW1","SA2","SYR","SW2"} 
   
   //Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
   aOrdem   := {}

   //Cria o objeto principal de controle do relat�rio.
   //Par�metros:            Relat�rio ,Titulo ,Pergunte ,C�digo de Bloco do Bot�o OK da tela de impress�o.
   oReport := TReport():New("EICTR260",STR0001,"",{|oReport| ReportPrint(oReport)},STR0010+" "+STR0001)

   //ER - 20/10/2006 - Inicia o relat�rio como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F.

   //Define o objeto com a se��o do relat�rio
   oSecao1 := TRSection():New(oReport,"Embarques",aTabelas,aOrdem)

   //Defini��o das colunas de impress�o da se��o 1
   TRCell():New(oSecao1,"W6_HAWB"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_HAWB"  ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W7_PO_NUM"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W7_FORN"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   If EICLoja()
      TRCell():New(oSecao1,"W7_FORLOJ"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   EndIf
   TRCell():New(oSecao1,"A2_NREDUZ"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_EMB"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_ETA"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W2_TIPO_EM"  ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W1_PRAZO"    ,"TRB"   ,STR0007      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"YR_TRANS_T"  ,"TRB"   ,STR0008      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_IDENTVE"  ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)

   //ASR - 14/11/2006 - Espa�amento
   oReport:Section("Embarques"):Cell("W6_DT_HAWB"):SetColSpace(4)//ASR - 14/11/2006
   oReport:Section("Embarques"):Cell("W7_FORN"   ):SetColSpace(2)//ASR - 14/11/2006
   If EICLoja()
      oReport:Section("Embarques"):Cell("W7_FORLOJ"   ):SetColSpace(2)
   EndIf
   oReport:Section("Embarques"):Cell("W6_DT_EMB" ):SetColSpace(4)//ASR - 14/11/2006
   oReport:Section("Embarques"):Cell("W6_DT_ETA" ):SetColSpace(4)//ASR - 14/11/2006
   oReport:Section("Embarques"):Cell("W2_TIPO_EM"):SetColSpace(4)//ASR - 14/11/2006
   oReport:Section("Embarques"):Cell("W1_PRAZO"  ):SetColSpace(4)//ASR - 14/11/2006
   oReport:Section("Embarques"):Cell("YR_TRANS_T"):SetColSpace(4)//ASR - 14/11/2006
   oReport:Section("Embarques"):Cell("W6_IDENTVE"):SetColSpace(2)//ASR - 14/11/2006
   
ELSEIF cQual=Pagamento

   aTabelas := {"SW6","SW7","SW1","SA2"} 

   //Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
   aOrdem   := {}

   //Cria o objeto principal de controle do relat�rio.
   //Par�metros:            Relat�rio ,Titulo ,Pergunte ,C�digo de Bloco do Bot�o OK da tela de impress�o.
   oReport := TReport():New("EICTR261",STR0002,"",{|oReport| ReportPrint(oReport)},STR0010+" "+STR0002)

   //ER - 20/10/2006 - Inicia o relat�rio como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F.

   //Define o objeto com a se��o do relat�rio
   oSecao1 := TRSection():New(oReport,"Embarques",aTabelas,aOrdem)
   
    //Defini��o das colunas de impress�o da se��o 1
   TRCell():New(oSecao1,"W6_HAWB"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_HAWB"  ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W7_PO_NUM"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W7_FORN"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   If EICLoja()
      TRCell():New(oSecao1,"W7_FORLOJ"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)   
   EndIf
   TRCell():New(oSecao1,"A2_NREDUZ"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_EMB"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_CHEG"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W1_PRAZO"    ,"TRB"   ,STR0007      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_LOCAL"    ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"YR_TRANS_T"  ,"TRB"   ,STR0009      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
  
ELSEIF cQual=Desembaraco
   
   //Alias que podem ser utilizadas para adicionar campos personalizados no relat�rio

   aTabelas := {"SW6","SW7","SW1"} 
   
   //Array com o titulo e com a chave das ordens disponiveis para escolha do usu�rio
   aOrdem   := {}

   //Cria o objeto principal de controle do relat�rio.
   //Par�metros:            Relat�rio ,Titulo ,Pergunte ,C�digo de Bloco do Bot�o OK da tela de impress�o.
   oReport := TReport():New("EICTR262",STR0003,"",{|oReport| ReportPrint(oReport)},STR0010+" "+STR0003)
   
   //ER - 20/10/2006 - Inicia o relat�rio como paisagem. 
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F.
   
   //Define o objeto com a se��o do relat�rio
   oSecao1 := TRSection():New(oReport,"Embarques",aTabelas,aOrdem)
  
   //Defini��o das colunas de impress�o da se��o 1
   TRCell():New(oSecao1,"W6_HAWB"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_HAWB"  ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W7_PO_NUM"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DT_EMB"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DI_NUM"   ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_DTREG_D"  ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_CHEG"     ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W1_PRAZO"    ,"TRB"   ,STR0007      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"W6_LOCAL"    ,"TRB"   ,/*Titulo*/   ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"YR_TRANS_T"  ,"TRB"   ,STR0009      ,/*Picture*/                       ,/*Tamanho*/            ,/*lPixel*/,/*{|| code-block de impressao }*/)

ENDIF   

If(EasyEntryPoint("EICTR260"),Execblock("EICTR260",.F.,.F.,"TR260REPORTDEF"),)  //DRL 07/07/10
oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Prazo M�dio em Dias")

oTotal:= TRFunction():New(oSecao1:Cell("W1_PRAZO"),NIL,"SUM",/*oBreak*/,"","@E 99,999",{|| TRB->W1_PRAZO/TRB->(EasyRecCount()) },.T.,.F.)
oTotal:SetTotalInLine(.F.)


//Necess�rio para carregar os perguntes mv_par**
//Pergunte(oReport:uParam,.F.)

Return oReport 

************************************
Static Function ReportPrint(oReport)
************************************
//Local oSection := oReport:Section("Se��o 1")

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Embarques"),"SW6",1,{|| xFilial("SW6") + TRB->W6_HAWB})

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Embarques"),"SYR",1,{|| xFilial("SYR") + SW6->W6_VIA_TRA+SW6->W6_ORIGEM+SW6->W6_DEST})

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Embarques"),"SW7",1,{|| xFilial("SW7") + SW6->W6_HAWB})

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Embarques"),"SA2",1,{|| xFilial("SA2") + SW7->W7_FORN+EICRetLoja("SW7","W7_FORLOJ")})

//Faz o posicionamento de outros alias para utiliza��o pelo usu�rio na adi��o de novas colunas.
TRPosition():New(oReport:Section("Embarques"),"SW2",1,{|| xFilial("SW2") + SW7->W7_PO_NUM})

//oSection:Print()
oReport:SetMeter (TRB->(EasyRecCount()))
TRB->( dbGoTop() )

//Inicio da impress�o da se��o 1. Sempre que se inicia a impress�o de uma se��o � impresso automaticamente
//o cabe�alho dela.
oReport:Section("Embarques"):Init()

//La�o principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Embarques"):PrintLine() //Impress�o da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo
TRB->(DBGOTOP())

//Fim da impress�o da se��o 1
oReport:Section("Embarques"):Finish()

If(EasyEntryPoint("EICTR260"),Execblock("EICTR260",.F.,.F.,"TR260FIM_TREPORT"),)  //DRL 08/07/10

Return .T.
