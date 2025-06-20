
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"

#define K_Atend     3
#define K_Alt       4

Function PLSA307
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao de variaveis...                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL cAlias     := "BBD"                                                    
LOCAL oBrw
LOCAL bAjustBrw  := { || oBrw := GetObjBrow(), PLSA305Tel(BTH->BTH_DATA,oBrw,cCodInt,cLocal,cCdAmbu,cDsAmbu) }
LOCAL cPerg      := "PLA307"
LOCAL cCodLoja
LOCAL cLocal
LOCAL cCodInt
LOCAL cDsambu
LOCAL cSQL
LOCAL oSay
LOCAL _cFil307                                                                
LOCAL nRcBAU
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta opcoes da rotina...                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
PRIVATE cSala
PRIVATE cCdAmbu
PRIVATE cCodSala
PRIVATE aCdCores  := { { 'BR_AMARELO' ,'Encaixe'  },;
                        { 'BR_CINZA'   ,'Agendado'  },;
                        { 'BR_AZUL'    ,'Atendido'  },;
                        { 'BR_VERDE'   ,'Espera'    } }

PRIVATE aCores    := { { 'BBD_STATUS = "1" .And. BBD_ENCAIX = "1"',aCdCores[1,1] },;
                        { 'BBD_STATUS = "1"',aCdCores[2,1] },;
                        { 'BBD_STATUS = "4"',aCdCores[3,1] },;
                        { 'BBD_STATUS = "5"',aCdCores[4,1] } }

PRIVATE aRotina   := MenuDef()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define o cabecalho da tela de atualizacoes                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
PRIVATE cCadastro := "Atendimento"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Busca parametros da rotina...                                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("SX1")

If ! Pergunte(cPerg,.T.)
   Return
Endif   

cCodInt  := mv_par01
cLocal   := mv_par02
cdatade := mv_par03
cdataate := mv_par04
PRIVATE dData  := dDataDe
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Busca o medico logado...                                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cSQL := "SELECT BAU_CODIGO, R_E_C_N_O_ REG FROM "+RetSQLName("BAU")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BAU_CODCFG = '"+RetCodUsr()+"'"
PLSQuery(cSQL,"Trb307")

If ! Trb307->(Eof())
   cCodLoja := Trb307->BAU_CODIGO
   nRcBAU   := Trb307->REG
Else
   MsgInfo("O Vinculo Rede de Atendimento X Usuario Configurador deve ser feito antes de entrar nesta opcao")
   Trb307->(DbCloseArea())
   Return
Endif                     
Trb307->(DbCloseArea())
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Posiciona no medico...                                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BAU->(DbSetOrder(1))
BAU->(DbGoTo(nRcBAU))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Busca em qual sala ele esta...                                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cSQL := "SELECT BGF_CODIGO, BGF_NSALA, BGF_CDAMBU FROM "+BGF->(RetSQLName("BGF"))+" WHERE "
cSQL += "BGF_FILIAL = '"+xFilial("BGF")+"' AND "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BGF_CODLOJ = '"+cCodLoja+"' AND "
cSQL += "BGF_CODINT = '"+cCodInt+"' AND "
cSQL += "BGF_CODLOC = '"+cLocal+"' AND "
cSQL += "BGF_STATUS = '1'"

PLSQuery(cSQL,"Trb307")

Trb307->(DbGoTop())
If ! Trb307->(Eof())
   cSala   := Trb307->BGF_NSALA       
   cCdAmbu := Trb307->BGF_CDAMBU
   cDsambu := BSD->(Posicione("BSD",1,xFilial("BSD")+cCdAmbu,"BSD_DSAMBU"))
   cCodSala:= Trb307->BGF_CODIGO  
Endif
Trb307->(DbCloseArea())

If Empty(cSala)
   MsgInfo("Por favor, confira os parametros informados na entrada da rotina.")
   Return
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta filtro padrao...                                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
_cFil307 := "BBD_FILIAL = '"+xFilial("BBD")+"' .And. "
_cFil307 += "BBD_CODIGO = '"+Subs(cCodLoja,1,6)+"' .And. "
_cFil307 += " ( dtos(BBD_DATA) >= '"+dtos(dDataDe)+"' .And. dtos(BBD_DATA) <= '"+dtos(dDataAte)+"' ) .And. "
_cFil307 += "BBD_LOCAL = '"+Subs(cLocal,1,3)+"' "

BBD->(DbSetFilter({||&_cFil307},_cFil307))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Chama mBrowse padrao...                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BBD->(DbSetOrder(1))
BBD->(DbSeek(xFilial(cAlias)))

BBD->(mBrowse(006,001,022,075,cAlias, , , , , K_Atend, aCores, , , ,bAjustBrw))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera filtro antes de sair da rotina...                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BBD->(DbClearFilter())
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim da Rotina Principal...                                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return


Function PLSA307MOV(cAlias,nReg,nOpc)
Local I__f := 0
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define variaveis locais...                                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
LOCAL oDlg
LOCAL oFolder
LOCAL oEnc01
LOCAL oEnc02
LOCAL cAliasEnc := "BTH"
LOCAL nRegEnc   := 0          

LOCAL oSay                         
LOCAL nOpca   := 0                                           
LOCAL cHorIni := ""

LOCAL bOK     := { || nOpca := 1,If((Obrigatorio(aGets,aTela)),oDlg:End(),(nOpca:=3,.F.))}
LOCAL bCanc   := {|| If(MsgYesNo(__cMsgAban),(nOpca := 0, oDlg:End()),.F.) }
LOCAL cPrefFil:= "PLSA315"          

LOCAL nHMsg

LOCAL aCabBTI := {}
LOCAL aDadBTI := {}
LOCAL aTrbBTI := {}
LOCAL aCpo01  := {}
LOCAL aCpo02  := {}
LOCAL nOrdBTH := BTH->(IndexOrd())
LOCAL nRecBTH := BTH->(Recno())

LOCAL aCabBPJ := {}
LOCAL aDadBPJ := {}
LOCAL aTrbBPJ := {}


PRIVATE oBrwEvo
PRIVATE aCabEvo := {}
PRIVATE aDadEvo := {}
PRIVATE cCodPac := BBD->BBD_CODPAC
PRIVATE lEvol   := .F.

PRIVATE nOpcUpt := nOpc

PRIVATE oBrwBTI
PRIVATE oBrwBPJ
PRIVATE aTela   := {}
PRIVATE aGets   := {}
PRIVATE aCols   := {}
PRIVATE aHeader := {}                                                        
PRIVATE aButtons:= {}

PRIVATE oMemo01
PRIVATE cMemo01 := ""

PRIVATE oMemo02
PRIVATE cMemo02 := ""

PRIVATE oMemo03
PRIVATE cMemo03 := ""

PRIVATE oMemo04
PRIVATE cMemo04 := ""

PRIVATE oMemo05
PRIVATE cMemo05 := ""

PRIVATE oMemo06
PRIVATE cMemo06 := ""
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� testa se existem registros no Browse...                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If BBD->(Eof())
   Return
Endif   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� testa se pode alterar...                                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc <> K_Atend .And. BBD->BBD_STATUS <> "4"
   MsgInfo("Nao e possivel alterar ou visualizar sem realizar o atendimento")
   Return
Endif              
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta aButtons se for atendimento...                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aadd(aButtons,{"POSCLI",{ || PLSA307Grv(nOpc,M->BTH_CODATE)},"Gravar Dados"})
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Posiciona no usuario...                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BBD->BBD_CODPAC))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta dados da enchoice...                                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc == K_Atend
   Copy cAliasEnc To Memory Blank          
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� Monta dados...                                                           �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   If nOpc == K_Atend
      M->BTH_CODATE := PLSA305Num(dDataBase)
   Endif   
   M->BTH_DATA   := dDataBase
   M->BTH_HORINI := Time()
   M->BTH_CODPAC := BBD->BBD_CODPAC
   M->BTH_NOMPAC := BBD->BBD_NOME
   M->BTH_IDADE  := IF(!Empty(BA1->BA1_DATNAS),Calc_Idade(dDataBase,BA1->BA1_DATNAS),0)
Else
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� Posiciona no atendimento da consulta posicionada...                      �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   BTH->(DbSetOrder(1))
   BTH->(DbSeek(xFilial("BTH")+BBD->(BBD_NUMATE)))

   Copy cAliasEnc To Memory
   nRegEnc := BTH->(Recno())
Endif   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta dados das Solicitacoes...                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Store Header "BTI" TO aCabBTI For .T.
If nOpc == K_Incluir
   Store COLS Blank "BTI" TO aDadBTI FROM aCabBTI
Else
   BTI->(DbSetOrder(1))
   If ! BTI->(DbSeek(xFilial("BTI")+BTH->BTH_CODATE))
      Store COLS Blank "BTI" TO aDadBTI FROM aCabBTI
   Else
      Store COLS "BTI" TO aDadBTI FROM aCabBTI VETTRAB aTrbBTI While BTI->(BTI_FILIAL+BTI_CODATE) == xFilial("BTI")+BTH->BTH_CODATE
   Endif
Endif    
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta dados da Obstetricia.....                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Store Header "BPJ" TO aCabBPJ For .T.
If nOpc == K_Incluir
   Store COLS Blank "BPJ" TO aDadBPJ FROM aCabBPJ
Else
   BPJ->(DbSetOrder(1))
   If ! BPJ->(DbSeek(xFilial("BPJ")+BTH->BTH_CODATE+BTH->BTH_CODPAC))
      Store COLS Blank "BPJ" TO aDadBPJ FROM aCabBPJ
   Else
      Store COLS "BPJ" TO aDadBPJ FROM aCabBPJ VETTRAB aTrbBPJ While BPJ->(BPJ_FILIAL+BPJ_CODATE+BPJ_CODPAC) == xFilial("BPJ")+BTH->BTH_CODATE+BTH->BTH_CODPAC
   Endif
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta evolucao do paciente...                                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Store Header "BTH" TO aCabEvo For .T.

BTH->(DbSetOrder(2))
If BTH->(DbSeek(xFilial("BTH")+cCodPac))
   Store COLS "BTH" TO aDadEvo FROM aCabEvo While BTH->(BTH_FILIAL+BTH_CODPAC) == xFilial("BTH")+cCodPac For BTH->(Recno()) <> nRecBTH
   lEvol := Len(aDadEvo)>0
Endif
BTH->(DbSetOrder(nOrdBTH))
BTH->(DbGoTo(nRecBTH))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Posiciona no proximo horario...                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc == K_Atend .And. BBD->BBD_STATUS == "4" .And. nOpcUpt <> K_Alterar
   Return
Endif   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Posiciona no usuario...                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BA1->(DbSetOrder(2))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta dados dos MEMO...                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cMemo01 := M->BTH_QUEPRI
cMemo02 := M->BTH_QUEDOE
cMemo03 := M->BTH_QUECLI
cMemo04 := M->BTH_QUIFAM
cMemo05 := M->BTH_DESREC
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define dialogo...                                                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 TO ndLinFin,ndColFin
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define folder...                                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If lEvol
   @ 018,004 FOLDER oFolder SIZE 390,240 OF oDlg       PIXEL PROMPTS  "Atendimento",; 
                                                                       "Solicitacoes de Exames",;
                                                                       "Evolucao do Paciente",;
                                                                       "Ficha Obstetrica"
Else
   @ 018,004 FOLDER oFolder SIZE 390,240 OF oDlg       PIXEL PROMPTS  "Atendimento",; 
                                                                       "Solicitacoes de Exames",;
                                                                       "Ficha Obstetrica"
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define enchoice...                                                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
STORE FIELD "BTH" TO aCpo01 FOR AllTrim(X3_CAMPO) $ "BTH_CODATE,BTH_CODPAC,BTH_NOMPAC"
                                
STORE FIELD "BTH" TO aCpo02 FOR AllTrim(X3_CAMPO) $ "BTH_DATRET,BTH_PESO,BTH_ALTURA,BTH_PREART,BTH_PRECAR,BTH_TEMPER,BTH_CID,BTH_DESCID,BTH_IDADE"

aSvaTela := {}
aTela    := {}
aGets    := {}
cVar     := "aSvaTela["+AllTrim(Str(Len(aSvaTela)+1))+"]"
aadd(aSvaTela,{})
oEnc01 := MsMGet():New(cAliasEnc ,nRegEnc ,K_Alterar,,,,aCpo01,{005,005,045,190},aCpo01,,,,,oFolder:aDialogs[1],,,.T.,cVar)       

aSvaTela[len(aSvaTela)] = aClone(aTela)
aTela    := {}
aGets    := {}
cVar     := "aSvaTela["+AllTrim(Str(Len(aSvaTela)+1))+"]"
aadd(aSvaTela,{})
oEnc02 := MsMGet():New(cAliasEnc ,nRegEnc ,K_Alterar,,,,aCpo02,{160,005,225,381},aCpo02,,,,,oFolder:aDialogs[1],,,.F.,cVar)       
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta memo...                                                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
@ 005,195 Say oSay PROMPT "QP - Queixa Principal" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 015,195 GET oMemo01 VAR cMemo01 MEMO SIZE 185, 030 OF oFolder:aDialogs[1] PIXEL

@ 045,005 Say oSay PROMPT "HDA - Historico de Doenca Atual" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 055,005 GET oMemo02 VAR cMemo02 SIZE 186, 030 OF oFolder:aDialogs[1] PIXEL MEMO

@ 045,195 Say oSay PROMPT "HCC - Historico Clinica Cirurgica" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 055,195 GET oMemo03 VAR cMemo03 SIZE 186, 030 OF oFolder:aDialogs[1] PIXEL MEMO

@ 085,005 Say oSay PROMPT "HF - Historico Familiar" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 095,005 GET oMemo04 VAR cMemo04 SIZE 186, 030 OF oFolder:aDialogs[1] PIXEL MEMO

@ 085,195 Say oSay PROMPT "RC - Receita" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 095,195 GET oMemo05 VAR cMemo05 MEMO SIZE 185, 030 OF oFolder:aDialogs[1] PIXEL

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta browse com as solicitacoes de exames...                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oBrwBTI := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[2],nil    , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBTI,aDadBTI,.F.,"BTI",K_Alterar,"Solicitacoes")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta browse evolucao do paciente...                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
IF lEvol
   oBrwBTH := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[3],nil    , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabEvo,aDadEvo,.F.,"BTH",K_Visualizar,"Evolucao do Paciente")
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� Monta browse com a Ficha Obstetrica...                                   �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   oBrwBPJ := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[4],nil , nil ,nil,nil ,nil, .T. , nil ,.T. ,nil ,aCabBPJ,aDadBPJ,.F.,"BPJ",K_Alterar,"Obstetricia")
ELSE
   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   //� Monta browse com a Ficha Obstetrica...                                   �
   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
   oBrwBPJ := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[3],nil , nil ,nil ,nil ,nil, .T. , nil ,.T. ,nil ,aCabBPJ,aDadBPJ,.F.,"BPJ",K_Alterar,"Obstetricia")
Endif   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Ativa o dialogo...                                                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCanc,.F.,aButtons)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Trata confirmacao...                                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpca == K_OK
   If nOpc == K_Atend .Or. nOpc == K_Alterar
      PLSA307Grv(nOpc,M->BTH_CODATE)
   Endif 
Else
Endif   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim da Rotina...                                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    � PLSA307GRV � Autor � Tulio Cesar         � Data � 08.07.02 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Grava os dados sem a necessidade de se fechar a tela...    낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function PLSA307Grv(nOpc,cCodAte)
Local I__f := 0
LOCAL aChave                                                                  
LOCAL lNovo
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Testa se existe na base de dados...                                      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BTH->(DbSetOrder(1))
lNovo := !BTH->(DbSeek(xFilial("BTH")+cCodAte))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicio da transacao...                                                   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Begin Transaction
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Atualiza agenda como efetuada...                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Copy "BBD" To Memory

If nOpc == K_Atend .And. lNovo
   M->BBD_NUMATE := PLSA305Num(dDataBase)
Endif   

M->BBD_STATUS := "4"
M->BBD_CODPAC := M->BTH_CODPAC
M->BBD_NOME   := M->BTH_NOMPAC
M->BBD_NSALA  := cSala
M->BBD_CDAMBU := cCdAmbu
M->BBD_CODSAL := cCodSala

BBD->(PLUPTENC("BBD",K_Alterar))
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Atualiza arquivo de consultas a partir de agendas medicas...             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc == K_Atend
   M->BTH_CODATE := M->BBD_NUMATE
Endif

M->BTH_QUEPRI := cMemo01
M->BTH_QUEDOE := cMemo02
M->BTH_QUECLI := cMemo03
M->BTH_QUIFAM := cMemo04
M->BTH_DESREC := cMemo05
M->BTH_HORFIN := Time()
If lNovo
   BTH->(PLUPTENC("BTH",K_Incluir))
Else
   BTH->(PLUPTENC("BTH",K_Alterar))
Endif   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Grava solicitacoes...                                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aChave := {} 
aadd(aChave,{"BTI_CODATE",M->BTH_CODATE})
oBrwBTI:Grava(aChave)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Grava Obstetricia....                                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aChave := {} 
aadd(aChave,{"BPJ_CODATE",M->BTH_CODATE})
aadd(aChave,{"BPJ_CODPAC",M->BTH_CODPAC})
oBrwBPJ:Grava(aChave)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Finaliza transacao...                                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
End Transaction
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim da Rotina...                                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  쿘enuDef   � Autor � Darcio R. Sporl       � Data �03/04/2007낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Utilizacao de menu Funcional                               낢�
굇�          �                                                            낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   쿌rray com opcoes da rotina.                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿛arametros do array a Rotina:                               낢�
굇�          �1. Nome a aparecer no cabecalho                             낢�
굇�          �2. Nome da Rotina associada                                 낢�
굇�          �3. Reservado                                                낢�
굇�          �4. Tipo de Transa뇙o a ser efetuada:                        낢�
굇�          �	  1 - Pesquisa e Posiciona em um Banco de Dados           낢�
굇�          �    2 - Simplesmente Mostra os Campos                       낢�
굇�          �    3 - Inclui registros no Bancos de Dados                 낢�
굇�          �    4 - Altera o registro corrente                          낢�
굇�          �    5 - Remove o registro corrente do Banco de Dados        낢�
굇�          �5. Nivel de acesso                                          낢�
굇�          �6. Habilita Menu Funcional                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01   , "AxPesqui"   , 0 , K_Pesquisar  , 0 , .F.},;
                        { STRPL02  , "PLSA307MOV" , 0 , K_Visualizar , 0 , Nil},;
                        { "Atendimento" , "PLSA307MOV" , 0 , K_Atend      , 0 , Nil},;
                        { STRPL04     , "PLSA307MOV" , 0 , K_Alt        , 0 , Nil} }
Return(aRotina)
