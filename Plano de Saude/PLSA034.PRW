#INCLUDE "plsa034.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA034 � Autor � Michele Tatagiba     � Data � 24.09.2002 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Tabela de Horarios Especiais                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矴eraldo Jr. �24/04/03�      � Acerto de Tela e Campos que nao gravavam.潮�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA034

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define variaveis...                                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE aRotina := MenuDef()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define o cabecalho da tela de atualizacoes                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE cCadastro := PLSRetTit("BAR")
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Endereca a funcao de BROWSE...                                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BAR->(mBrowse(06,01,22,75,"BAR"))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina Principal...                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北砅rograma  � PLSA034MOV � Autor � Michele Tatagiba     � Data � 24.09.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北矰escri噭o � Cadastro de Tabela de Horarios Especiais                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function PLSA034Mov(cAlias,nReg,nOpc)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define variaveis da rotina...                                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
LOCAL lRet
LOCAL aSaveArea 	:= GetArea()
LOCAL nOpca			:= 0
LOCAL oDlgBar
LOCAL oChk1
LOCAL oChk2
LOCAL oChk3
LOCAL oChk4
LOCAL oChk5
LOCAL oChk6
LOCAL oChk7
LOCAL oChk8
Local oChk9

Private lChk1   := .F.
Private lChk2   := .F.
Private lChk3   := .F.
Private lChk4   := .F.
Private lChk5   := .F.
Private lChk6   := .F.
Private lChk7   := .F.
Private lChk8   := .F.
Private lChk9	  := .F.

PRIVATE cCodAti
PRIVATE cDesAti
PRIVATE cCodigo
PRIVATE cDesc
PRIVATE cHorIni := Space(05)
PRIVATE cHorFin := Space(05)
PRIVATE nPerc   := 0
PRIVATE dVigIni := ctod("  /  /  ")
PRIVATE dVigFin := ctod("  /  /  ")
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE nOpcao := nOpc 

If nOpc == 3
   cCodAti	 := Space(Len(BAR->BAR_CODATI))
   cDesAti	 := Space(Len(BAR->BAR_DESATI))
   cCodigo   := PLS034VAL()
   cDesc     := Space(Len(BAR->BAR_DESCRI))
Else
   cCodAti	 := BAR->BAR_CODATI
   cDesAti	 := BAR->BAR_DESATI
   cCodigo   := BAR->BAR_CODIGO
   cDesc     := BAR->BAR_DESCRI
   cHorIni   := BAR->BAR_HORINI
   cHorFin   := BAR->BAR_HORFIN
   dVigIni	 := BAR->BAR_VIGINI
   dVigFin	 := BAR->BAR_VIGFIN
   nPerc     := BAR->BAR_PERC   
   BAS->(DBSetOrder(1))
   If BAS->(DBSeek(xFilial("BAS")+cCodigo))
      While !BAS->(EOF()) .And. BAS->(BAS_FILIAL+BAS_CODIGO) == xFilial("BAS")+cCodigo
            &("lChk"+BAS->BAS_DIASEM) := .T.
      BAS->(DBSkip())
      Enddo
   Endif
EndIf

if Val(GetVersao(.F.)) >= 12 //Valida vers鉶 12
	DEFINE MSDIALOG oDlgBar TITLE STR0006 FROM 008.2,010.3 TO 027.4+10,079.3+10 OF GetWndDefault() //"Tabela de Horarios Especiais"
	
	DEFINE FONT oFnt	NAME "Arial" Size 10,15
	DEFINE FONT oFnt1	NAME "Arial" Size 000,-011 BOLD 
	         
	@015+20,002 To 058+20, 270+10 label STR0007  Of oDlgBar Pixel //"Identificacao"
	
	@024+20,010 SAY STR0027 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Grupo da Tabela"
	@024+20,055 MSGET cCodAti  Picture "@!" SIZE 020+20,08 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar PIXEL
	
	@024+20,095 SAY STR0028 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao Grupo"
	@024+20,130 MSGET cDesAti Picture "@!" SIZE 130+20,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@040+20,010 SAY STR0008 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Codigo Tabela"
	@040+20,055 MSGET cCodigo  Picture "@!" SIZE 020+20,08 When .F. OF oDlgBar PIXEL
	
	@040+20,095 SAY STR0009 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao "
	@040+20,130 MSGET cDesc Picture "@!" SIZE 130+20,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@062+20,002 To 097+20, 270 label STR0010 Of oDlgBar PIXEL  //"Dias da Semana"
	@072+20,010 CHECKBOX oChk1   Var lChk1 PROMPT STR0011    PIXEL SIZE 055+10, 010  When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Domingo"
	@072+20,075 CHECKBOX oChk2   Var lChk2 PROMPT STR0012    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Segunda-Feira"
	@072+20,140 CHECKBOX oChk3   Var lChk3 PROMPT STR0013    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Terca-Feira"
	@072+20,200 CHECKBOX oChk4   Var lChk4 PROMPT STR0014    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quarta-Feira"
	
	@082+20,010 CHECKBOX oChk5   Var lChk5 PROMPT STR0015    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quinta-Feira"
	@082+20,075 CHECKBOX oChk6   Var lChk6 PROMPT STR0016    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sexta-Feira"
	@082+20,140 CHECKBOX oChk7   Var lChk7 PROMPT STR0017    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sabado"
	@082+20,200 CHECKBOX oChk8   Var lChk8 PROMPT STR0018    PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Feriado"
	                                                          
	@100+20,002 To 140+20, 270 label STR0019 Of oDlgBar PIXEL  //"Horarios/Valores/Vigencia"
	@110+20,010 SAY STR0020 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Inicial "
	@110+20,055 MSGET cHorIni Picture "@R !!:!!" SIZE 020,08 Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) .AND. !lChk9 OF oDlgBar PIXEL
	
	@110+20,095 SAY STR0021 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Final "
	@110+20,135 MSGET cHorFin Picture "@R !!:!!" Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) .AND. !lChk9 SIZE 010,08 OF oDlgBar PIXEL
	
	@110+20,175 SAY STR0022 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Percentual "
	@110+20,215 MSGET nPerc  Picture "@E 999,999,999.9999" SIZE 050,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125+20,010 SAY STR0023 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Inicial "
	@125+20,055 MSGET dVigIni  Picture "@D" SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125+20,095 SAY STR0024 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Final: "
	@125+20,135 MSGET dVigFin  Picture "@D" Valid Empty(dVigFin) .Or. dVigFin >= dVigIni SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125+20,175 CHECKBOX oChk9   Var lChk9 PROMPT "Dia Todo" Valid ValDiaTodo()        PIXEL SIZE 055+10, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Feriado"

Else
	DEFINE MSDIALOG oDlgBar TITLE STR0006 FROM 008.2,010.3 TO 027.4,079.3 OF GetWndDefault() //"Tabela de Horarios Especiais"
	
	DEFINE FONT oFnt	NAME "Arial" Size 10,15
	DEFINE FONT oFnt1	NAME "Arial" Size 000,-011 BOLD 
	         
	@015,002 To 058, 270 label STR0007  Of oDlgBar Pixel                                     //"Identificacao"
	
	@024,010 SAY STR0027 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Grupo da Tabela"
	@024,055 MSGET cCodAti  Picture "@!" SIZE 020,08 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar PIXEL
	
	@024,095 SAY STR0028 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao Grupo"
	@024,130 MSGET cDesAti Picture "@!" SIZE 130,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@040,010 SAY STR0008 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Codigo Tabela"
	@040,055 MSGET cCodigo  Picture "@!" SIZE 020,08 When .F. OF oDlgBar PIXEL
	
	@040,095 SAY STR0009 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Descricao "
	@040,130 MSGET cDesc Picture "@!" SIZE 130,08 When (nOpcao == 3 .Or. nOpcao == 4) Of oDlgBar PIXEL
	
	@062,002 To 097, 270 label STR0010 Of oDlgBar PIXEL  //"Dias da Semana"
	@072,010 CHECKBOX oChk1   Var lChk1 PROMPT STR0011   PIXEL SIZE 055, 010  When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Domingo"
	@072,075 CHECKBOX oChk2   Var lChk2 PROMPT STR0012   PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Segunda-Feira"
	@072,140 CHECKBOX oChk3   Var lChk3 PROMPT STR0013     PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Terca-Feira"
	@072,200 CHECKBOX oChk4   Var lChk4 PROMPT STR0014    PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quarta-Feira"
	
	@082,010 CHECKBOX oChk5   Var lChk5 PROMPT STR0015    PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Quinta-Feira"
	@082,075 CHECKBOX oChk6   Var lChk6 PROMPT STR0016     PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sexta-Feira"
	@082,140 CHECKBOX oChk7   Var lChk7 PROMPT STR0017          PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Sabado"
	@082,200 CHECKBOX oChk8   Var lChk8 PROMPT STR0018         PIXEL SIZE 055, 010 When (nOpcao == 3 .Or. nOpcao == 4) OF oDlgBar //"Feriado"
	                                                          
	@100,002 To 140, 270 label STR0019 Of oDlgBar PIXEL  //"Horarios/Valores/Vigencia"
	@110,010 SAY STR0020 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Inicial "
	@110,055 MSGET cHorIni Picture "@R !!:!!" SIZE 020,08 Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@110,095 SAY STR0021 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Horario Final "
	@110,135 MSGET cHorFin Picture "@R !!:!!" Valid PLS034HOR() When (nOpc == 3 .Or. nOpc == 4) SIZE 010,08 OF oDlgBar PIXEL
	
	@110,175 SAY STR0022 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Percentual "
	@110,215 MSGET nPerc  Picture "@E 999,999,999.9999" SIZE 050,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125,010 SAY STR0023 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Inicial "
	@125,055 MSGET dVigIni  Picture "@D" SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
	
	@125,095 SAY STR0024 PIXEL COLOR CLR_HBLUE FONT oFnt1 //"Vigencia Final: "
	@125,135 MSGET dVigFin  Picture "@D" Valid Empty(dVigFin) .Or. dVigFin >= dVigIni SIZE 040,08 When (nOpc == 3 .Or. nOpc == 4) OF oDlgBar PIXEL
Endif

ACTIVATE MSDIALOG oDlgBar ON INIT EnchoiceBar(oDlgBar,{|| If(PLS034OK(),(nOpca:=1,oDlgBar:End()),nil)},{||oDlgBar:End()})

If nOpca == 1						
	PLS034GRV(nOpc)
EndIf	

RestArea(aSaveArea)

Return
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � PLS034GRV � Autor � Michele Tatagiba     � Data � 24/09/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Gravacao dos dados                                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � PLS034GRV                                                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Static Function PLS034GRV(nOpc)

LOCAL aSaveArea := GetArea() 
LOCAL nInd      := 1    
LOCAL cNomVar

BAR->(dbSelectArea("BAR"))
BAR->(dbSetOrder(1))

If nOpc == 3               
   BAR->(RecLock("BAR",.T.))   
   BAR->BAR_FILIAL := xFilial("BAR")
   BAR->BAR_CODATI := cCodAti
   BAR->BAR_DESATI := cDesAti
   BAR->BAR_CODIGO := cCodigo
   BAR->BAR_DESCRI := cDesc
   BAR->BAR_HORINI := cHorIni
   BAR->BAR_HORFIN := cHorFin  
   BAR->BAR_VIGINI := dVigIni
   BAR->BAR_VIGFIN := dVigFin
   BAR->BAR_PERC   := nPerc
   BAR->(MSUnlock())     
                    
   For nInd := 1 To 8
       cNomVar := "lChk"+AllTrim(Str(nInd))
       If &(cNomVar)
       	BAS->(RecLock("BAS",.T.))  
       	BAS->BAS_FILIAL := xFilial("BAS")
       	BAS->BAS_CODATI := cCodAti
       	BAS->BAS_DESATI := cDesAti
       	BAS->BAS_CODIGO := cCodigo
       	BAS->BAS_DIASEM := AllTrim(Str(nInd))
       	BAS->(MSUnlock())
       Endif
   Next    
Elseif nOpc == 4
       BAR->(RecLock("BAR",.F.))  
       BAR->BAR_FILIAL := xFilial("BAR")
       BAR->BAR_CODATI := cCodAti
       BAR->BAR_DESATI := cDesAti
       BAR->BAR_DESCRI := cDesc
       BAR->BAR_HORINI := cHorIni
       BAR->BAR_HORFIN := cHorFin
       BAR->BAR_VIGINI := dVigIni
       BAR->BAR_VIGFIN := dVigFin
       BAR->BAR_PERC   := nPerc
       BAR->(MSUnlock())
       
       DbSelectArea("BAS")
       DbSetOrder(1)
		If BAS->(MsSeek(xFilial("BAS")+BAR->BAR_CODIGO))
			While ! BAS->(EOF()) .AND. BAS->(BAS_FILIAL+BAS_CODIGO) == BAR->(BAR_FILIAL+BAR_CODIGO)
       		BAS->(RecLock("BAS",.F.))
       		BAS->BAS_FILIAL := xFilial("BAS")       			
       		BAS->BAS_CODATI := cCodAti
	        	BAS->BAS_DESATI := cDesAti
	        	BAS->(MSUnlock())
	        	BAS->(DbSkip())
			EndDo
		EndIf
       
       For nInd := 1 To 8  
           cNomVar := "lChk"+AllTrim(Str(nInd))       
           BAS->(DBSetOrder(1))           
           If BAS->(DBSeek(xFilial("BAS")+cCodigo+AllTrim(Str(nInd))))
              If ! &(cNomVar)           
                 BAS->(RecLock("BAS",.F.))
                 BAS->(DBDelete())
                 BAS->(MSUnlock())
              Endif
           Else
              If &(cNomVar)
                 	BAS->(RecLock("BAS",.T.))
              	BAS->BAS_FILIAL := xFilial("BAS")
                 	BAS->BAS_CODIGO := cCodigo
                 	BAS->BAS_CODATI := cCodAti
                 	BAS->BAS_DIASEM := AllTrim(Str(nInd))
                 	BAS->(MSUnlock())                 
              Endif
           Endif
       Next

    Elseif nOpc == 5
           BAR->(RecLock("BAR",.F.))
           BAR->(DBDelete())
           BAR->(MSUnlock())
       
           For nInd := 1 To 8
               BAS->(DBSetOrder(1))           
               If BAS->(DBSeek(xFilial("BAS")+cCodigo+AllTrim(Str(nInd))))
                  BAS->(RecLock("BAS",.F.))
                  BAS->(DBDelete())
                  BAS->(MSUnlock())
               Endif
           Next
EndIf

RestArea(aSaveArea)

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    砅LS034Val  � Autor � Michele Tatagiba     � Data � 24/09/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Valida inclusao de codigo                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � PLS034VAL                                                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function PLS034Val()

LOCAL aSaveArea:= GetArea()
LOCAL cCodMasc := "001"			

DBSelectArea("BAR")
BAR->(DBSetOrder(1))
BAR->(DBSeek(xFilial("BAR")+"999"))
BAR->(DBSkip(-1))  

If !Empty(BAR->BAR_CODIGO)
   cCodMasc := StrZero(Val(BAR->BAR_CODIGO)+1,3)
Endif

RestArea(aSaveArea)
Return (cCodMasc)             


Static Function PLS034HOR()

LOCAL lRet := .t.

If cHorIni >= "00:00" .And. cHorIni <= "24:00"
   lRet := .T.
Endif               

Return(lRet)


Static Function PLS034OK()

LOCAL lRet  := .T.
LOCAL nInd  := 1
LOCAL nCont := 0
LOCAL cNomVar
LOCAL cQryBar

If  (nOpcao == 3 .Or. nOpcao == 4) .And. Empty(cCodAti) .Or. Empty(cDesAti) .Or. Empty(cDesc) .Or. Empty(cHorIni) .Or. Empty(cHorFin) .Or. nPerc == 0
   MSgInfo(STR0025) //"Preencha os campos obrigatorios."
   lRet := .F.
Endif        

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. (Len(StrTran(Transform(cHorIni,"9999")," ")) != 4 .Or. Len(StrTran(Transform(cHorFin,"9999")," ")) != 4 .Or. ;
						    ! SubStr(cHorIni,1,1) $ "0123456789" .Or. ! SubStr(cHorIni,2,1) $ "0123456789" .Or. ;			
						    ! SubStr(cHorIni,3,1) $ "0123456789" .Or. ! SubStr(cHorIni,4,1) $ "0123456789" .Or. ;			
						    ! SubStr(cHorFin,1,1) $ "0123456789" .Or. ! SubStr(cHorFin,2,1) $ "0123456789" .Or. ;			
						    ! SubStr(cHorFin,3,1) $ "0123456789" .Or. ! SubStr(cHorFin,4,1) $ "0123456789" .Or. ;			
							Val(SubStr(cHorIni,1,2)) > 23 .Or. Val(SubStr(cHorIni,3,2)) > 59 .Or. ;
							Val(SubStr(cHorFin,1,2)) > 23 .Or. Val(SubStr(cHorFin,3,2)) > 59 )
   MSgInfo(STR0031) //"Hor醨io digitado inv醠ido."
   lRet := .F.
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. Val(cHorFin) < Val(cHorIni)
   MSgInfo(STR0034 + Chr(13) + Chr(10) + STR0035) 
   //"Para realizar o cadastro de um hor醨io que extrapola o dia, deve-se realizar o cadastro dos dois dias separadamente."
   //"Exemplo: Ter鏰 das 22:00 鄐 23:59 e Quarta das 00:00 鄐 07:00.
   lRet := .F.
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. Val(cHorIni) == Val(cHorFin)
   lRet := MSgYesNo(STR0036,IIf(nOpcao == 3,STR0037,STR0038))
   //"Confirma a inclus鉶?"
   //"Aten玢o: Essa configura玢o representa apenas 1 minuto de dura玢o."
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4) .And. !Empty(DToS(dVigFin)) .And. !Empty(DToS(dVigIni)) .And. dVigFin < dVigIni
   MSgInfo(STR0033) //"A Data de vig阯cia final n鉶 pode ser menor que a inicial."
   lRet := .F.
EndIf

While nInd <= 8 .And. lRet
    cNomVar := "lChk"+AllTrim(Str(nInd))
    If ! &(cNomVar)
       nCont ++
    Endif
        
    nInd ++
Enddo            

If nCont == 8 .And. lRet .And. (nOpcao == 3 .Or. nOpcao == 4)
   MSgInfo(STR0026) //"Informe algum Tipo de Dia da Semana."
   lRet := .F.
Endif

If nOpcao == 5
	cQryBar  := " SELECT COUNT(*) BY5_HRE FROM " + RetSqlName("BY5") + " BY5 "
	cQryBar  += " WHERE BY5.BY5_CODATI = '" + cCodAti +"'"
	cQryBar  += "   AND BY5.BY5_FILIAL = '" + xFilial("BY5") + "' "	
	cQryBar  += "   AND BY5.D_E_L_E_T_ <> '*' "
	PLSQuery(cQryBar,"BY5QRY")
	
	cQryBar  := " SELECT COUNT(*) BF8_HRE FROM " + RetSqlName("BF8") + " BF8 "
	cQryBar  += " WHERE  BF8.BF8_CODATI = '" + cCodAti +"'"
	cQryBar  += "   AND  BF8.BF8_FILIAL = '" + xFilial("BF8") + "' "	
	cQryBar  += "   AND  BF8.D_E_L_E_T_ <> '*' "
	PLSQuery(cQryBar,"BF8QRY")
	
	If  BY5QRY->BY5_HRE >= 1
		lRet := .F.
		MsgStop(STR0029)//Registro n鉶 pode ser apagado, pois o mesmo encontra-se em R.d.a - Cadastro.
	Else
		If  BF8QRY->BF8_HRE >= 1
			lRet := .F.
			MsgStop(STR0030)//Registro n鉶 pode ser apagado, pois o mesmo encontra-se em Tabela Honor醨ios.
		EndIf
	EndIf
	BY5QRY->(DbCloseArea())
	BF8QRY->(DbCloseArea())
EndIf

If lRet .And. (nOpcao == 3 .Or. nOpcao == 4)

	aAreaBAS := BAS->(GetArea())
	aAreaBAR := BAR->(GetArea())

	BAS->(DbSetOrder(2))
	If BAS->(MsSeek(xFilial("BAS")+cCodAti))
		While ! BAS->(Eof()) .And. BAS->(BAS_FILIAL+BAS_CODATI) == xFilial("BAS")+cCodAti
			If ( !Empty(BAS->BAS_DIASEM) .And. ValType("lChk"+AllTrim(BAS->BAS_DIASEM)) == "L" .And. &("lChk"+AllTrim(BAS->BAS_DIASEM)))
				BAR->(DbSetOrder(1))
				If BAR->(MsSeek(xFilial("BAR")+BAS->BAS_CODIGO))
					If nOpcao == 4 .And. cCodigo == BAS->BAS_CODIGO
						BAS->(DbSkip())
						Loop
					EndIf
					If ( Empty(BAR->BAR_VIGINI) .And. Empty(BAR->BAR_VIGFIN)) ;
										.Or. (Empty(BAR->BAR_VIGINI) .And. (Empty(dVigIni) .Or. dVigIni <= BAR->BAR_VIGFIN) );
										.Or. (Empty(BAR->BAR_VIGFIN) .And. (Empty(dVigFin) .Or. dVigFin >= BAR->BAR_VIGINI) );
										.Or. (!Empty(BAR->BAR_VIGINI) .And. !Empty(BAR->BAR_VIGFIN) .And. ;
														( 	 (Empty(dVigIni) .And. Empty(dVigFin) );
															.Or. (Empty(dVigFin) .And. dVigIni <= BAR->BAR_VIGFIN) ;
															.Or. (Empty(dVigIni) .And. dVigFin >= BAR->BAR_VIGINI) ;
															.Or. (!Empty(dVigIni) .And. !Empty(dVigFin) .And. ;
																	(	!(dVigIni < BAR->BAR_VIGINI .And. dVigIni < BAR->BAR_VIGFIN .And. dVigFin < BAR->BAR_VIGINI .And. dVigFin < BAR->BAR_VIGFIN) ;
																 		.And. !(dVigIni > BAR->BAR_VIGINI .And. dVigIni > BAR->BAR_VIGFIN .And. dVigFin > BAR->BAR_VIGINI .And. dVigFin > BAR->BAR_VIGFIN) ;
																 	) ;
																) ;
														) ;
											 )

						If (! (cHorIni < BAR->BAR_HORINI .And. cHorIni < BAR->BAR_HORFIN .And. cHorFin < BAR->BAR_HORINI .And. cHorFin < BAR->BAR_HORFIN) ;
											.And. ! (cHorIni > BAR->BAR_HORINI .And. cHorIni > BAR->BAR_HORFIN .And. cHorFin > BAR->BAR_HORINI .And. cHorFin > BAR->BAR_HORFIN) )
							lRet := .F.
							MsgStop(STR0032 + Chr(13) + Chr(10) + STR0039 + " " + xFilial("BAR")+BAS->BAS_CODIGO)//Grupo X Dia da Semana X Hor醨io X Vig阯cia informados conflitam com dados j� cadastrados.
							Exit
						EndIf
					Endif
				Endif
			Endif      
			BAS->(DbSkip())
		Enddo
	EndIf
	
	BAS->(RestArea(aAreaBAS))
	BAR->(RestArea(aAreaBAR))

EndIf

Return(lRet)



/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �22/12/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados         潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()
Private aRotina := { { STR0001,'AxPesqui'    , 0 , K_Pesquisar		,0 ,.F. },; //'Pesquisar' //"Pesquisar"
                      { STR0002,'PLSA034Mov'  , 0 , K_Visualizar	,0 ,Nil },; //'Visualizar' //"Visualizar"
                      { STR0003	,'PLSA034Mov'  , 0 , K_Incluir		,0 ,Nil },; //'Incluir' //"Incluir"
                      { STR0004	,'PLSA034Mov'  , 0 , K_Alterar		,0 ,Nil },; //'Alterar' //"Alterar"
                      { STR0005	,'PLSA034Mov'  , 0 , K_Excluir		,0 ,Nil }}  //'Excluir' //"Excluir"
Return(aRotina)

Static function ValDiaTodo()
Local lRet := .T.

If lChk9
	cHorIni := "0000"
	cHorFin := "2359"
EndIf

Return lRet