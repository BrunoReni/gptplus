
#include "PLSMGER.CH"
#include "PLSA270.CH"
#include "PROTHEUS.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA270 � Autor � Tulio Cesar          � Data � 02.05.2000 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Forma de Cobranca                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 5.08                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA270
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define o cabecalho da tela de atualizacoes                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := OemtoAnsi(STR0002)
Private cFilter	  := ""
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Endereca a funcao de BROWSE                                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BJ1->(DbSetOrder(1))
BJ1->(DbGoTop())
BJ1->(mBrowse(006,001,022,075,"BJ1"))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Desliga F12 do programa...                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
SET KEY VK_F12 TO
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina Principal                                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PL270MOV � Autor � Tulio Cesar           � Data � 02.05.01 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Movimentacao do Cadastro de Forma de Cobranca              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PL270MOV(cAlias,nReg,nOpc)
Local I__f := 0
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis...                                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
LOCAL nOpca	 := 0
LOCAL oDlg
PRIVATE aChave := {}
PRIVATE oSay 
PRIVATE aCols   := {}
PRIVATE aHeader  := {}
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis Tipo 01                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE oGet01
PRIVATE aCab01
PRIVATE aCols01
PRIVATE aVet01 := {}
PRIVATE cExpAdv01 := Space(10)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis Tipo 02                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE oGet02
PRIVATE aCab02
PRIVATE aCols02
PRIVATE aVet02 := {}          
PRIVATE cExpAdv02 := Space(10)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis Tipo 03                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE oGet03
PRIVATE aCab03
PRIVATE aCols03
PRIVATE aVet03 := {}
PRIVATE cExpAdv03 := Space(10)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis Tipo 04                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE oGet04
PRIVATE aCab04 
PRIVATE aCols04
PRIVATE aVet04 := {}
PRIVATE cExpAdv04 := Space(10)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Variaveis para Enchoice...                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
PRIVATE oEnchoice
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE nAlt := Iif(Val(GetVersao(.F.)) >= 12, 030, 015)
aSize := MsAdvSize(.T.) 
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta aCols e aHeader...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Store Header "BJ2" TO aCab01 For .T.
If nOpc == K_Incluir
	Copy "BJ1" TO Memory Blank
	Store COLS Blank "BJ2" TO aCols01 FROM aCab01
Else
	Copy "BJ1" TO MEMORY

	BJ2->(DbSetOrder(1))
	If BJ2->(MsSeek(xFilial("BJ2")+BJ1->BJ1_CODIGO+"1"))
		Store COLS "BJ2" TO aCols01 FROM aCab01 VETTRAB aVet01 While BJ2->(BJ2_FILIAL+BJ2_CODIGO+BJ2_USO) == BJ1->(BJ1_FILIAL+BJ1_CODIGO+"1")
	Else
		Store COLS Blank "BJ2" TO aCols01 FROM aCab01
	EndIf
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta aCols e aHeader...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Store Header "BJ2" TO aCab02 For .T.
If nOpc == K_Incluir
	Copy "BJ1" TO Memory Blank
	Store COLS Blank "BJ2" TO aCols02 FROM aCab02
Else
	Copy "BJ1" TO MEMORY

	BJ2->(DbSetOrder(1))
	If BJ2->(MsSeek(xFilial("BJ2")+BJ1->BJ1_CODIGO+"2"))
		Store COLS "BJ2" TO aCols02 FROM aCab02 VETTRAB aVet02 While BJ2->(BJ2_FILIAL+BJ2_CODIGO+BJ2_USO) == BJ1->(BJ1_FILIAL+BJ1_CODIGO+"2")
	Else
		Store COLS Blank "BJ2" TO aCols02 FROM aCab02
	EndIf
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta aCols e aHeader...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Store Header "BJ2" TO aCab03 For .T.
If nOpc == K_Incluir
	Copy "BJ1" TO Memory Blank
	Store COLS Blank "BJ2" TO aCols03 FROM aCab03
Else
	Copy "BJ1" TO MEMORY

	BJ2->(DbSetOrder(1))
	If BJ2->(MsSeek(xFilial("BJ2")+BJ1->BJ1_CODIGO+"3"))
		Store COLS "BJ2" TO aCols03 FROM aCab03 VETTRAB aVet03 While BJ2->(BJ2_FILIAL+BJ2_CODIGO+BJ2_USO) == BJ1->(BJ1_FILIAL+BJ1_CODIGO+"3")
	Else
		Store COLS Blank "BJ2" TO aCols03 FROM aCab03
	EndIf
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta aCols e aHeader...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Store Header "BJ2" TO aCab04 For .T.
If nOpc == K_Incluir
	Copy "BJ1" TO Memory Blank
	Store COLS Blank "BJ2" TO aCols04 FROM aCab04
Else
	Copy "BJ1" TO MEMORY

	BJ2->(DbSetOrder(1))
	If BJ2->(MsSeek(xFilial("BJ2")+BJ1->BJ1_CODIGO+"4"))
		Store COLS "BJ2" TO aCols04 FROM aCab04 VETTRAB aVet04 While BJ2->(BJ2_FILIAL+BJ2_CODIGO+BJ2_USO) == BJ1->(BJ1_FILIAL+BJ1_CODIGO+"4")
	Else
		Store COLS Blank "BJ2" TO aCols04 FROM aCab04
	EndIf
EndIf

If nOpc <> K_Incluir
   cExpAdv01 := Posicione("BJ0",1,xFilial("BJ0")+M->BJ1_CODIGO+"1","BJ0_ROTINA")
Endif   

If nOpc <> K_Incluir
   cExpAdv02 := Posicione("BJ0",1,xFilial("BJ0")+M->BJ1_CODIGO+"2","BJ0_ROTINA")
Endif   

If nOpc <> K_Incluir
   cExpAdv03 := Posicione("BJ0",1,xFilial("BJ0")+M->BJ1_CODIGO+"3","BJ0_ROTINA")
Endif   

If nOpc <> K_Incluir
   cExpAdv04 := Posicione("BJ0",1,xFilial("BJ0")+M->BJ1_CODIGO+"4","BJ0_ROTINA")
Endif   

If nOpc = 6	// Copia
	M->BJ1_PROPRI 	:= ""
	M->BJ1_CODIGO 	:= Space(Len(M->BJ1_CODIGO))
	M->BJ1_DATA	  	:= dDataBase
	nOpc := 3		// Inclusao
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Dialogo...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Define Folders...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
@ 105,003 FOLDER oFolder SIZE 350,090 OF oDlg PIXEL	PROMPTS	OemtoAnsi(STR0003),OemtoAnsi(STR0004),OemtoAnsi(STR0005),OemtoAnsi(STR0006)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta Enchoice...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Zero();oEnchoice := MsMGet():New(cAlias,nReg,nOpc,,,,,{nAlt,001,100,355},,,,,,oDlg,,,.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta GetDados...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	aDifSize:= {,,,,35,3,,}
	oGet02 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[2],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab02,aCols02,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil,,,,,,,,,,,,aDifSize)
Else
	oGet02 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[2],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab02,aCols02,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil)
Endif
oGet02:aVetTrab := aClone(aVet02)
@ 006, 005 Say   OemtoAnsi(STR0007) PIXEL OF oFolder:aDialogs[2] //"Expressao ADVPL"
@ 004, 060 MSGet oSay VAR cExpAdv02 SIZE 055,010 PIXEL OF oFolder:aDialogs[2]
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta GetDados...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	aDifSize:= {,,,,35,3,,}
	oGet03 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[3],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab03,aCols03,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil,,,,,,,,,,,,aDifSize)
Else
	oGet03 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[3],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab03,aCols03,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil)
EndIf
oGet03:aVetTrab := aClone(aVet03)
@ 006, 005 Say   OemtoAnsi(STR0007) PIXEL OF oFolder:aDialogs[3] //"Expressao ADVPL"
@ 004, 060 MSGet oSay VAR cExpAdv03 SIZE 055,010 PIXEL OF oFolder:aDialogs[3]
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta GetDados...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	aDifSize:= {,,,,35,3,,}
	oGet04 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[4],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab04,aCols04,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil,,,,,,,,,,,,aDifSize)
Else
	oGet04 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[4],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab04,aCols04,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil)
EndIf
oGet04:aVetTrab := aClone(aVet04)
@ 006, 005 Say   OemtoAnsi(STR0007) PIXEL OF oFolder:aDialogs[4] //"Expressao ADVPL"
@ 004, 060 MSGet oSay VAR cExpAdv04 SIZE 055,010 PIXEL OF oFolder:aDialogs[4]
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta GetDados...                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If Val(GetVersao(.F.)) >= 12 // Caso a versao seja maior ou igual a 12
	aDifSize:= {,,,,35,3,,}
	oGet01 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[1],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab01,aCols01,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil,,,,,,,,,,,,aDifSize)
Else
	oGet01 := TPLSBrw():New(020,005,341,070,nil  ,oFolder:aDialogs[1],nil, nil, nil ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCab01,aCols01,.F.,"BJ2",nOpc,"Alias da Forma de Cobranca",nil,nil,nil,nil,nil)
EndIf
oGet01:aVetTrab := aClone(aVet01)
@ 006, 005 Say   OemtoAnsi(STR0007) PIXEL OF oFolder:aDialogs[1]//"Expressao ADVPL"
@ 004, 060 MSGet oSay VAR cExpAdv01 SIZE 055,010 PIXEL OF oFolder:aDialogs[1]
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ativa o Dialogo...                                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,{})  })
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Rotina de gravacao dos dados...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If nOpca == K_OK
   If nOpc <> K_Visualizar
   
      M->BJ1_USO := If(!Empty(cExpAdv01),"1","")+If(!Empty(cExpAdv02),"2","")+;
                     If(!Empty(cExpAdv03),"3","")+If(!Empty(cExpAdv04),"4","")
      PLUPTENC("BJ1",nOpc)   	
   
      aChave := {}
      aadd(aChave,{"BJ2_CODIGO",M->BJ1_CODIGO})
      aadd(aChave,{"BJ2_USO","1"})
      oGet01:Grava(aChave, .T.)      

      aChave := {}
      aadd(aChave,{"BJ2_CODIGO",M->BJ1_CODIGO})
      aadd(aChave,{"BJ2_USO","2"})
      oGet02:Grava(aChave, .T.)

      aChave := {}
      aadd(aChave,{"BJ2_CODIGO",M->BJ1_CODIGO})
      aadd(aChave,{"BJ2_USO","3"})
      oGet03:Grava(aChave, .T.)

      aChave := {}
      aadd(aChave,{"BJ2_CODIGO",M->BJ1_CODIGO})
      aadd(aChave,{"BJ2_USO","4"})
      oGet04:Grava(aChave, .T.)
      
      If ! Empty(cExpAdv01)
         DbSelectArea("BJ0")
         BJ0->(DbSetOrder(1))
         BJ0->(MsSeek(xFilial("BJ0")+M->BJ1_CODIGO+"1"))
         BJ0->(RecLock("BJ0",!BJ0->(Found())))
         If nOpc <> K_Excluir
            BJ0->BJ0_FILIAL  := xFilial("BJ0")
            BJ0->BJ0_CODIGO  := M->BJ1_CODIGO
            BJ0->BJ0_TIPO    := "1"
            BJ0->BJ0_ROTINA  := cExpAdv01
         Else
            BJ0->(DbDelete())
         Endif   
         BJ0->(MsUnLock())
      Endif   

      If ! Empty(cExpAdv02)
         DbSelectArea("BJ0")
         BJ0->(DbSetOrder(1))
         BJ0->(MsSeek(xFilial("BJ0")+M->BJ1_CODIGO+"2"))
         BJ0->(RecLock("BJ0",!BJ0->(Found())))
         If nOpc <> K_Excluir
            BJ0->BJ0_FILIAL  := xFilial("BJ0")
            BJ0->BJ0_CODIGO  := M->BJ1_CODIGO
            BJ0->BJ0_TIPO    := "2"
            BJ0->BJ0_ROTINA  := cExpAdv02
         Else
            BJ0->(DbDelete())
         Endif   
         BJ0->(MsUnLock())
      Endif   

      If ! Empty(cExpAdv03)
         DbSelectArea("BJ0")
         BJ0->(DbSetOrder(1))
         BJ0->(MsSeek(xFilial("BJ0")+M->BJ1_CODIGO+"3"))
         BJ0->(RecLock("BJ0",!BJ0->(Found())))
         If nOpc <> K_Excluir
            BJ0->BJ0_FILIAL  := xFilial("BJ0")
            BJ0->BJ0_CODIGO  := M->BJ1_CODIGO
            BJ0->BJ0_TIPO    := "3"
            BJ0->BJ0_ROTINA  := cExpAdv03
         Else
            BJ0->(DbDelete())
         Endif   
         BJ0->(MsUnLock())
      Endif   

      If ! Empty(cExpAdv04)
         DbSelectArea("BJ0")
         BJ0->(DbSetOrder(1))
         BJ0->(MsSeek(xFilial("BJ0")+M->BJ1_CODIGO+"4"))
         BJ0->(RecLock("BJ0",!BJ0->(Found())))
         If nOpc <> K_Excluir
            BJ0->BJ0_FILIAL  := xFilial("BJ0")
            BJ0->BJ0_CODIGO  := M->BJ1_CODIGO
            BJ0->BJ0_TIPO    := "4"
            BJ0->BJ0_ROTINA  := cExpAdv04
         Else
            BJ0->(DbDelete())
         Endif   
         BJ0->(MsUnLock())
      Endif            
   Endif   
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina...                                                         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLS270New � Autor � Tulio Cesar        � Data � 03.05.2000 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Busca novo codigo para Forma de Cobranca                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 5.08                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/                     
Function PLS270New(cPropri)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Busca o proximo codigo...                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
LOCAL cNew

BJ1->(DbSetOrder(1))

BJ1->(MsSeek(xFilial("BJ1")+cPropri+"99", .T.))
BJ1->(DbSkip(-1))

If BJ1->BJ1_PROPRI == cPropri
   cNew := cPropri+StrZero(Val(Subs(BJ1->BJ1_CODIGO,2,2))+1,2)
Else
   cNew := cPropri+"01"
Endif

Return(cNew)

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLS270New � Autor � Tulio Cesar        � Data � 03.05.2000 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Busca novo codigo para Forma de Cobranca                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 5.08                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/                     
Function PLS270Sx2

Local lRet := .F., cArea := Alias()

DbSelectArea("SX2")
cFilter := DbFilter()
Set Filter To
lRet := MsSeek(M->BJ2_ALIAS)
If ! lRet
	Help("",1,"REGNOIS")
Endif
If ! Empty(cFilter)
	Set Filter To &(cFilter)
Endif

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif


Return lRet

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �02/01/2007潮�
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
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados           潮�
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
Private aRotina := {	{ STRPL01 , 'AxPesqui' , 0 , K_Pesquisar	, 0, .F.},; //'Pesquisar'
											{ STRPL02 , 'PL270MOV' , 0 , K_Visualizar	, 0, Nil},; //'Visualizar'
											{ STRPL03 , 'PL270MOV' , 0 , K_Incluir		, 0, Nil},; //'Incluir'
											{ STRPL04 , 'PL270MOV' , 0 , K_Alterar		, 0, Nil},; //'Alterar'
											{ STRPL05 , 'PL270MOV' , 0 , K_Excluir		, 0, Nil},; //"Excluir"
											{ STR0001	, 'PL270MOV' , 0 , 6						, 0, Nil} } //"Copiar"
Return(aRotina)