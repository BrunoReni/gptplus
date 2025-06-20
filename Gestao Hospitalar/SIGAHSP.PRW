#define cVerAdv  "99"
#define cResAdv  "ADVB"

#include "SIGAHSP.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SIGAHSP  � Autor � Ary Medeiros          � Data � 10/11/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � SigaHSP Advanced for Windows                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Copyright (c) 1995 MICROSIGA Ltda.  All rights reserved    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

//teste

#include "FiveWin.ch"
#include "Siga.ch"

#define TAB   Chr( 9 )
#define SRCPAINT   15597702   // 0xEE0086
#define SRCAND      8913094

Function SIGAHSP(cInternet)
*����������������������������������������������������������������������Ŀ
*�Definir variaves de memoria                                           �
*������������������������������������������������������������������������
Local oIco, oBar, oFont, oUserBar
Local oAni, oLogo
Local cTitle := ""
Local nTitle := 0
Local aRetMod := RetModName()

PUBLIC oMainWnd
PUBLIC lLeft := .F.

PRIVATE  _NomeExec := "SIGAHSP.EXE"
PRIVATE oShortList

PRIVATE aAmbientes:={}                                                  // Ambientes do Usuario
PRIVATE uSigaADV:=.F.                  // Provisoria !!!!

PRIVATE nCampos      := 200          // Numero de campos no help
        calc         := .F.          // Calculadora ja/nao ativa
        agen         := .F.          // Agenda ja/ano ativa
        help         := .F.          // Help ja/nao ativo
        lInUtil      := .F.
        f_ASK        := "askfor"     // Nome da rotina de perguntas p/MENUH
        dDataBase    := MsDate()     // Data padrao do sistema
        Have_a_Mouse := .F.          // Se existe um mouse instalado
        cArqTel := "SIGAHSP.SCR"     // Nome do arquivo de telas
        cArqHlp := "SIGAADV" + RetExtHlp() // Nome do arquivo de HELP
        cArqMnu := "SIGAHSP" + RetExtMnu() // Nome do arquivo de Menu
        cArqPsw := "SIGAMAT.PSW"     // Nome do arquivo de senhas
        cArqEmp := "SIGAMAT.EMP"     // Nome do arquivo de Empresas/Filiais
        cArqRel := "SIGAHSP.REL"      // Nome do arquivo de Relatorios
        cArqAlca:= "SIGAMAT.ALC"      // Nome do arquivo de Alcadas
        cAcesso := Replicate("S",128) // Nivel de Acesso (SENHA)
        cEmpAut := ""                 // Empresas Autorizadas
        cEmpAnt := ""
        cNumEmp := ""
        cFilAnt := ""
        cArqTab := ""
        cMestra := ""
        cSenha  := ""
        cFOPENed:= ""                 // Arquivos Abertos
        cFuncao := "GetEmpr"
        MouseRet:= ""                 //mudado Retorno do Mouse
        aMenus  := aEmpresas:={}
        tInicio := TIME()             // Hora de Inicio
        D_String:= "ACRM"             // Letras para selecao do menu
        nOpc0   := 1
        cVersao := GetVersao()
        cNomEmp := SPACE(15)
        cNomFil := SPACE(15)
        nCodEmp := 1
        nModulo := 51                 // Codigo do Modulo HSP
        nPosMnu := 0
        cModulo := "HSP"              // Prefixo do modulo
        cUsuario:= ""
        cNivel  := 9
        lTes    := .T.                // para cadastro do Tes

PRIVATE MV_RELT,MV_CENT,MV_MILHAR,MV_SIMB1,MV_SIMB2,MV_SIMB3,MV_SIMB4,MV_SIMB5

PRIVATE AdvFont
PRIVATE AcBrowse
PRIVATE a_FILES[0]
PRIVATE nOpt01:=nOpt02:=nOpt03:=nOpt04:=1
PRIVATE aTrigger := {}                          // para controle de gatilhos
PRIVATE __cInterNet := Nil
PRIVATE VALOR := 0
PRIVATE __cBinder := Nil,__cTerminal := nil

*����������������������������������������������������������������������Ŀ
*�Chamada para Binder                                                   �
*������������������������������������������������������������������������
IF Valtype(cInternet) == "C"
        If Subs(cInternet,1,2)=='*-'
                __cBinder := cInternet
                __cInternet := nil
        Endif
Endif

SetsDefault()

IF __cInternet == Nil .and. Empty(__cBinder)
       Splash( oemtoansi("MANUTEN��O"),OemToAnsi(cVersao) )
Endif

#IFDEF DEBUG
    Public nDebug := MSMSFCREATE("DEBUG.TXT",0)
#ENDIF

DEFINE FONT AdvFont NAME "MS Sans Serif" SIZE 0, -9
*����������������������������������������������������������������������Ŀ
*�Endereca a rotina que faz diagnosticos                                �
*������������������������������������������������������������������������
PRIVATE aOpt1[0],aOpt2[0],aOpt3[0],aOpt4[0]
PRIVATE aOpt1m[0],aOpt2m[0],aOpt3m[0],aOpt4m[0]

//procura caption na RetModName
nTitle := Ascan(aRetMod,{|x| x[1] == nModulo})
If nTitle == 0
	cTitle := OemToAnsi(STR0001)
Else
	cTitle := aRetMod[nTitle][3]
EndIf

//**** Mudado para funcionar no Protheus (bof) ****//
DEFINE WINDOW oMainWnd FROM 1, 1 TO 22,75 TITLE cTitle

oMainWnd:SetMenu( MontaMenu(cArqMnu,.T.) )
//**** Mudado para funcionar no Protheus (bof) ****//

oMainWnd:oFont := AdvFont
oMainWnd:nClrText := 0

MainToolBar(@oBar)

SET MESSAGE OF oMainWnd TO oEmToAnsi(cVersao)  NOINSET FONT oFont
DEFINE MSGITEM oMsgItem0 OF oMainWnd:oMsgBar PROMPT "     " SIZE 50

 #IFDEF PROTHEUS
        DEFINE MSGITEM oMsgItem1 OF oMainWnd:oMsgBar PROMPT dDataBase SIZE 100 ACTION ChangeDate()
        DEFINE MSGITEM oMsgItem2 OF oMainWnd:oMsgBar PROMPT Substr(cUsuario,1,6) SIZE 100  //ACTION GetNewPass(Substr(cUsuario,1,6),.T.)
        DEFINE MSGITEM oMsgItem3 OF oMainWnd:oMsgBar PROMPT STR0008+STR0009 SIZE 180  ACTION GetEmpr() //"Microsiga / "###"Matriz"
        DEFINE MSGITEM oMsgItem4 OF oMainWnd:oMsgBar PROMPT STR0010 SIZE 180  ACTION GetAmb() //"Ambiente"
#ELSE
        DEFINE MSGITEM oMsgItem1 OF oMainWnd:oMsgBar PROMPT dDataBase SIZE 60 ACTION ChangeDate()
        DEFINE MSGITEM oMsgItem2 OF oMainWnd:oMsgBar PROMPT Substr(cUsuario,1,6) SIZE 100  //ACTION GetNewPass(Substr(cUsuario,1,6),.T.)
        DEFINE MSGITEM oMsgItem3 OF oMainWnd:oMsgBar PROMPT STR0008+STR0009 SIZE 150  ACTION GetEmpr() //"Microsiga / "###"Matriz"
#ENDIF

// **** Mudado para funcionar no Protheus (bof) ****//
if !lLeft
  oAni := MSAniCreate( 0, 580, 60, 60, cResAdv,, .T., oMainWnd:oBar,{ |nRow,nCol,nKeyFlags| InterNetBrowser() },{ |nRow,nCol,nKeyFlags| oAni:AniPopUp() },,, .F.,, .T.,, .F., 21, 250,9,.F.)
else
  oAni := MSAniCreate( 0, 0, 180, 60,, "ADVC", .T., oMainWnd:oBar,,{ |nRow,nCol,nKeyFlags| (if(!oAni:Active,oAni:Activate(),oAni:DeActivate())) },,, .F.,, .T.,, .F., 11, 350,7,.F.)
  MSAniSetColor( oAni,CLR_WHITE,CLR_WHITE )
endif
MSAniGotop( oAni )
oMainWnd:SetColor(CLR_BLACK,CLR_WHITE)
// **** Mudado para funcionar no Protheus (eof) ****//

oMainWnd:bResized := {|x,nWidth,nHeight| ResizeWnd(oAni,nWidth,nHeight,oShortList),If(oLogo # nil,WndCenter(oLogo:hWnd),)}
oMainWnd:Cargo := oShortList

ACTIVATE WINDOW oMainWnd MAXIMIZED;
             VALID  IIF(Abandona(),Final(OemToAnsi(STR0002)),.F.);      //"T�rmino Normal" //"Termino Normal"
         ON INIT (ShowMsLogo(@oLogo),;
                  MSAniActivate(oAni),; //**** <= Mudado para funcionar no Protheus ****//
                                                Abertura(oMainWnd),;
                                                UserToolBar(@oUserBar),;
                  MSAniUserDef( oAni,.t. ) ) ; //**** <= Mudado para funcionar no Protheus ****//
              ON RIGHT CLICK ShortCut(oShortList,oMainWnd,nRow,nCol)


RELEASE OBJECTS oFont, oShortList

SET RESOURCES TO

Return nil

/////////////////////////////////////////////////////////////////////////////
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � WriteDbg � Autor � Ary Medeiros          � Data � 05/07/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao auxiliar para Depuracao 24 Horas                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGA24 - Compilar com /dDEBUG                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
#IFDEF DEBUG
    Function WriteDbg(cFunction,cValor)
    FWrite(nDebug,cFunction+": "+cValor+CHR(13)+CHR(10))
    Return nil
#ENDIF


//FUNCTION ATUMNT()
//DBSELECTAREA("SX2")
//IF DBSEEK("STT")
//   RECLOCK("SX2", .F.)
//   SX2->X2_ROTINA := "ABREMNT()"
//   MSUNLOCK("SX2")
//ENDIF

//RETURN NIL

