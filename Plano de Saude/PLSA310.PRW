
#Include "PROTHEUS.CH"
#Include "PLSA310.CH"
#include "PLSMGER.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA310 � Autor � Tulio Cesar          � Data � 03.04.2000 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Formas de Bloqueio da Usuario                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus 5.07                                     潮�
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
Function PLSA310   

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis...                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
LOCAL   aRotAux   := {}
LOCAL 	nNr
PRIVATE aRotina   := MenuDef()
PRIVATE cCadastro := fundesc() //"Formas de Bloqueio de Usu醨io"
PRIVATE cAlias    := "BG3"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Chama funcao de Browse...                                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
BG3->(dbGoTop())

	If ExistBlock("PL310MEN")
		aRotAux := ExecBlock("PL310MEN",.F.,.F.,{})

		If ValType(aRotAux) == "A"
			for nNr := 1 to Len(aRotAux)
				AAdd(aRotina, aRotAux[nNr])
			Next
		EndIf	
	EndIf

BG3->(mBrowse(06,01,22,75,"BG3"))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da Rotina...                                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA310MOV� Autor � Michele Tatagiba   � Data � 29.01.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Monto uma enchoice especifica para a exclusao              潮�
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
Function PLSA310MOV(cAlias,nReg,nOpc)
Local I__f 		:= 0
Local nRetorno	:= 0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis da EnchoiceBar...                                  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
LOCAL bOK     := {|| nOpca := 1,If( PLSA310OK(M->BG3_CODBLO), ;
                      oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel := {||oDlg:End()}
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis genericas...                                       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE nOpcx        := nOpc
PRIVATE nOpca        := 0
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis da enchoice...                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]   
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define variaveis para controle de forma de pagamento...             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE aSTela  := {}
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define Dialogo...                                                   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
PRIVATE oDlg            

If nOpc == K_Incluir
	
	nRetorno := AxInclui(cAlias,nReg,K_Incluir)

ElseIf nOpc == K_Alterar
	
	nRetorno := AxAltera(cAlias,nReg,K_Alterar)

ElseIf nOpc == K_Excluir
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Monta ,M->??? para enchoice...                                       �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Copy cAlias TO MEMORY
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Define dialogo...                                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	SetEnch("") 
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Monta Enchoice dos Dados Gerais ...                                 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Zero();MsMGet():New(cAlias,nReg,nOpc,,,,,{012,001,195,356},,,,,,oDlg,,,.F.)
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Ativa o dialogo...                                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,.F.,{})
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Trata atualizacao dos dados...  
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If nOpca == K_OK
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Inicio da Transacao...                                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪� 
		Begin Transaction
		PLUPTENC("BG3",nOpc)            
		End Transaction
	Endif   
EndIf 

If nRetorno == 1 .And. nOpc <> K_Excluir .And. ExistBlock("PL310GRV")
	   
	ExecBlock("PL310GRV",.F.,.F.,{nOpc})

EndIf
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLS310New � Autor � Michele Tatagiba   � Data � 28.01.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Busca novo codigo para bloqueio de beneficiario            潮�
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
Function PLS310New(cPropri)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Busca o proximo codigo...                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
LOCAL cNew

BG3->(DbSetOrder(1))

If cPropri == "9"
   BG3->(DbSeek(xFilial("BG3")+cPropri+"99"))
Else
   If cPropri == "1"
      BG3->(DbSeek(xFilial("BG3")+"9"))
   Endif
Endif
BG3->(DbSkip(-1))

If BG3->BG3_PROPRI == cPropri
   cNew := cPropri+StrZero(Val(Subs(BG3->BG3_CODBLO,2,2))+1,2)
Else
   cNew := cPropri+"01"
Endif

Return(cNew)

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLS310VLD � Autor � Michele Tatagiba   � Data � 28.01.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Verifica se o campo rdmake foi utilizado                   潮�
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
Function PLS310VLD()
Return(M->BG3_PERBLO == "0" .And. M->BG3_PROPRI <> "1")

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA310OK � Autor � Michele Tatagiba   � Data � 29.01.2002 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Verifica se existe alguma Usuario com esse codigo de bloquei潮�
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
Function PLSA310OK(cCodBlo)

LOCAL nRecBA3 := BA3->(Recno())
LOCAL nOrdBA3 := BA3->(IndexOrd())
LOCAL cInd    := CriaTrab(Nil,.F.)
LOCAL cFor    := ""
LOCAL lRet    := .T.
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta Expressao de filtro...                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cFor := "BA3_FILIAL = '"+xFilial("BA3")+"' .And. "
cFor += "BA3_MOTBLO == '"+cCodBlo+"'"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta filtro de acordo com os grupos informados no parametro...          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BA3->(IndRegua("BA3",cInd,"BA3_MOTBLO",nil,cFor,nil,.T.))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Posicione no primeiro registro no arquivo de Usuario                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If !BA3->(EOF())
   Alert(OemtoAnsi(STR0007)) //"Existe alguma Usuario bloqueada com esse motivo !"
   lRet := .F.
Endif

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Restaura dados salvados...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
BA3->(DbSetOrder(nOrdBA3))
BA3->(DbGoTo(nRecBA3))

Return(lRet)


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅L310HDE  篈utor  矨lexander           � Data �  16/05/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矱xibe Selecao para montar historico de desbloqueio		  罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PL310HDE(cOEMatric)

    Local cSql        
    Local dDataDes
    Local cHoraDes
    Local cTitulo

    Local cHistorico := OemtoAnsi(STR0008) //'Historico de Usuario Reativado'
    
    Local aSelecao   := {}
    Local aRet		 := {}           

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砆uery para mostrar o historio por data														�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSql := " SELECT DISTINCT BQY_DATA,BQY_HORA "
	cSql += " FROM "+RetSqlName("BQY")+" "
	cSql += " WHERE BQY_FILIAL+BQY_MATRIC = '"+cOEMatric+"'"
	cSql += "   AND BQY_ALIAS  = 'BA1' "

	PLSQuery(cSql,"QHTs")
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砎erifica se retornou alguma coisa															�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If QHTs->(Eof())                                            
	   QHTs->(DbCloseArea())                                       
	   MsgInfo(OemtoAnsi(STR0009)) //'N鉶 existe historico para esta matricula'
	   Return
	EndIf                  
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矼onta matriz para selecao de desbloqueio														�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	While !QHTs->(Eof())    
	   AaDd(aSelecao,{ QHTs->(BQY_DATA),QHTs->(BQY_HORA) } )                        
	   QHTs->(DbSkip()) 
	EndDo               
	QHTs->(DbCloseArea())	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砈e existir mais de um monstra o plscrigen para selecao de qual data e hora de desbloqueio	�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If Len(aSelecao) > 1
		aRet := PlsCriGen(aSelecao,{ {OemtoAnsi(STR0010),'@C',060},{OemtoAnsi(STR0012),'@C',050} },cHistorico) //'Data Reativacao' 'Hora'
		If aRet[1]
		   dDataDes := aSelecao[aRet[2],1]
		   cHoraDes := aSelecao[aRet[2],2]
		   MsAguarde({ || PL310HDEU(dDataDes,cHoraDes,cOEMatric,cHistorico), OemtoAnsi(STR0011), "", .T. }) //"Aguarde."
	    Else 
	       Return
	    EndIf   
    Else
	    MsAguarde({ || PL310HDEU(aSelecao[1,1],aSelecao[1,2],cOEMatric,cHistorico) ,  OemtoAnsi(STR0011), "", .T. }) //"Aguarde"
    EndIf
Return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅L310HDEU 篈utor  矨lexander           � Data �  16/05/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矱xibe historico de usuario reativado     					  罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
		 
Function PL310HDEU(dDataDes,cHoraDes,cOEMatric,cHistorico)

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矰eclaracao de variavel																			�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Local cAlias 	
	Local cTitulo
	Local cConteudo                
	Local cCampo
	Local nLin
	Local nCol
	Local nLinM
	Local nColM
	Local nI
	Local nJ
	
	Local oDlg                             
	Local oFont
	Local oLista	
	
	Local aTmp                        
	Local aMatCab
	Local aMatDad    
	
	Local nQtdLin
	Local nQtdCol
	Local cPicture
	
	Local nTrocaLin := 0
	Local bOK       := {|| ( oDlg:End(), .T.) }
	Local bCancel   := {|| ( oDlg:End(), .T.) }
	Local aBotoes   := {}
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矴uarda o filtro do sx2																		�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Local cFilX2    := SX2->(DbFilter())    
	// variaveis lgpd
	local oGetChave    := NIL      
	local objCENFUNLGP := CENFUNLGP():New()         
	local lObfs 	   := .f.                                                  
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砆uery para selecionar historico do usuario													�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cSql := " SELECT BQY_DATA,BQY_ALIAS,BQY_SEQUEN,BQY_CAMPO,BQY_CONTEU "
	cSql += " FROM "+RetSqlName("BQY")+" "
	cSql += " WHERE BQY_FILIAL+BQY_MATRIC = '"+cOEMatric+"'"
    cSql += "   AND BQY_DATA = '"+DtoS(dDataDes)+"'"
    cSql += "   AND BQY_HORA = '"+cHoraDes+"'"
	cSql += " Order By R_E_C_N_O_ "
	PLSQuery(cSql,"QHis")
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砎erifica se retornou alguma coisa															�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If QHis->(Eof())
	   MsgInfo(OemtoAnsi(STR0009)) //'N鉶 existe historico para esta matricula'
	   QHis->(DbCloseArea())
	   Return
	EndIf  
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砊itulo da tela																				�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	cHistorico += OemtoAnsi(STR0013)+TransForm(QHis->(BQY_DATA),'@D') //' - Data de Reativacao: '
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矻impa o filtro do sx2																		�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	DbSelectArea("SX2")               
	SX2->(DbClearFilter())
	DbSetOrder(1) 
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矼onta Matriz dinamicamente de acordo com o historico do bqy									�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	While !QHis->(Eof())
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//矯heca se mudou o alias																		�
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    	If cAlias <> QHis->(BQY_ALIAS) 
    	   cAlias   := QHis->(BQY_ALIAS)
		   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		   //矼onta a matriz de cabecalho somente se nao for BA1										   �
		   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    	   If cAlias <> 'BA1'
	    	   aMatCab  := 'a'+cAlias+'Cab'
	    	   &aMatCab := {}
	       EndIf	   
    	   aMatDad  := 'a'+cAlias+'Dad'
    	   &aMatDad := {}                          
		   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		   //矼atriz de botoes.. Descricao																   �
		   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    	   AaDd(aBotoes , {cAlias, Posicione('SX2' , 1 , cAlias , 'X2_NOME')} )
    	EndIf                   
	    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	    //砅ega o campo e monta o conteudo conforme o tipo no sx3										�
	    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
   	    cCampo := QHis->(BQY_CAMPO)	                 
   	    cTipo  := Posicione('SX3' , 2 , cCampo , 'X3_TIPO')
	    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	    //矯heca os tipos																				�
	    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
   	    Do Case
   	       Case cTipo == 'C'
	   	        cConteudo := AllTrim(QHis->(BQY_CONTEU))
   	       Case cTipo == 'D'
	   	        cConteudo := StoD(AllTrim(QHis->(BQY_CONTEU)))
   	       Case cTipo == 'N'
 	   	        cConteudo := Val(AllTrim(QHis->(BQY_CONTEU)))
 	   	   oTherWise
 	   	        cConteudo := AllTrim(QHis->(BQY_CONTEU))
   	    EndCase                  
	    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	    //砊roca o valor do conteudo conforme x3_cbox na tabela sx3										�
	    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
   	    cBoxC := Posicione('SX3' , 2 , cCampo , 'X3_CBOX')                         
   	    If !Empty(cBoxC)
            cConteudo := alltrim(X3COMBO(cCampo,cConteudo))
	   	EndIf
	    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	    //砅ega o titulo de cada campo no caso de ba1 e cabecalho se nao 								�
	    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	    cTitulo  := Posicione('SX3' , 2 , cCampo , 'X3_TITULO')
	    If cAlias == 'BA1'   
	    	AaDd( &aMatDad, { cTitulo, cCampo, TransForm( cConteudo , PesqPict(cAlias , cCampo) )} )
	    Else   
	   	    If AsCan(&aMatCab,{|x| x[1] == cTitulo }) == 0
		   	   cPicture := Posicione('SX3' , 2 , cCampo , 'X3_PICTURE')
	   	       cPicture := Iif(Empty(cPicture),'@!',cPicture)
	       	   AaDd( &aMatCab, { cTitulo , cPicture , PL310HDETC(cCampo) } )
	        EndIf	   
	    	AaDd( &aMatDad, { QHis->(BQY_SEQUEN), cTitulo , cConteudo } )
	    EndIf	
		QHis->(DbSkip())
	EndDo               
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矲echa a area de trabalho																		�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	QHis->(DbCloseArea())                                       
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矯onforme os botoes. monta o (acols) do plscrigen												�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    For nI := 1 To Len(aBotoes)
    
        If aBotoes[nI,1] <> 'BA1' 
	
			aMatDad  := 'a'+aBotoes[nI,1]+'Dad'
			aMatCab  := 'a'+aBotoes[nI,1]+'Cab'
			
	        aSort(&aMatDad,,, { |x, y| SubString(x[1],1,4) > SubString(Y[1],1,4) })
		    nQtdLin := Val( SubString(&(aMatDad+'[1,1]'),1,4) )
		    
		    nQtdCol := Len(&aMatCab)
		    
	        aTmp    := Array( nQtdLin,nQtdCol )
	        
	        aSort(&aMatDad,,, { |x, y| x[1] < Y[1] })
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//矼onta uma matriz temporaria para implementacao do cabecalho									�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	        For nJ := 1 To Len(&aMatDad)
			   nLinM   := Val(SubString(&( aMatDad+'['+Str(nJ)+',1]' ),1,4))
	           cTitulo := &( aMatDad+'['+Str(nJ)+',2]' )
			   nColM   := AsCan(&aMatCab,{|x| x[1] == cTitulo }) 
	       	   aTmp[nLinM,nColM] := &( aMatDad+'['+Str(nJ)+',3]' )
	        Next                           
			//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			//矯arrega a matriz que vai ser exibida															�
			//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	        &aMatDad  := aClone(aTmp)
	    EndIf    
    Next
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砇etorna com o filtro do sx2																	�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	DbSelectArea("SX2")             
	Set Filter To &cFilX2
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矰efinicao de fonte e monta a tela															�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Define FONT oFont NAME "Courier New" Size 0,-11
	Define MsDialog oDlg Title cHistorico From 160,70 TO 600,950 PIXEL 
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砈croll para dados do ba1																		�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	@ 15,01 ScrollBox oScroll Vertical Horizontal  Size 100,435 of oDlg BORDER
	
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//矯onforme a matriz de abotoes exibe os botoes	e monta o nome da matriz de cab e dad			�
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	    For nI := 1 To Len(aBotoes)
		    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		    //矼onta o nome da matriz a ser exibida															�
		    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			aMatDad  := 'a'+aBotoes[nI,1]+'Dad'
	        If aBotoes[nI,1] == 'BA1'   
	           nLin     := 010
               nCol     := 005                       
	           nMudaCol := 154                          
			   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			   //矯arrega os dados para um campo em memoria													   �
			   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	           For nJ := 1 To Len(&aMatDad) 
	           	   cTitulo   := &(aMatDad+'['+AllTrim(Str(nJ))+',1]')
	           	   cCampo    := 'M->'+AllTrim(&(aMatDad+'['+AllTrim(Str(nJ))+',2]'))
	           	   cConteudo := AllTrim(&(aMatDad+'['+AllTrim(Str(nJ))+',3]'))

	           	   if !Empty(cTitulo)
					   ++nTrocaLin                       
					   cTitulo 	 += Replicate(' ' , (15-Len(cTitulo)) )
			           cMTitulo  := "{||'"+cTitulo+"'}"		                                                      
			           cMCampo   := cCampo
					   &cMCampo  := cConteudo
			           cBlock    := "{ |u| If( PCount() == 0, "+cMCampo+", "+cMCampo+" := u ) }"
					   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					   //矯heca se pode mostrar a coluna na mesma linha	(Maior campo preenchido (Mae) Tamanho 120)	   �
					   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	   			       If ( (Len(cTitulo+cConteudo)*3.3)+nCol ) > 462 
	            	      nTrocaLin := 0
			              nLin 		+= 010
			              nCol  	:= 005
			           EndIf
					   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					   //矱xibe o nome referente ao ba1															   	   �
					   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
				   	   TSay():New( nLin, nCol, &cMTitulo , oScroll,, oFont ,,,,.t.)
				   	   nCol += (Len(cTitulo)*3.3)       
					   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					   //矱xibe o conteudo referente ao ba1															   �
					   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
            		   oGetChave := TGet():New( nLin-3, nCol, &cBlock , oScroll, ( (Len(cConteudo)*3.3)+10 ) , 08, "@!",,nil,nil,nil,nil,nil,.T.,nil,nil,nil,.F.,nil,nil,.T.,Nil,nil,nil)
				   	   nCol += ( (Len(cConteudo)*3.3)+10 ) 

						if objCENFUNLGP:isLGPDAt()
							lObfs := objCENFUNLGP:getTGet(&(aMatDad+'['+AllTrim(Str(nJ))+',2]'))
							oGetChave:lObfuscate := lObfs
						endif
					   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					   //矯heca se pode exibir numa determinada coluna												   �
					   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			           If nCol > 154 .and. nCol <= 308
   	  			          nCol	:= 309
   	  			       ElseIf nCol < 154
   	  			          nCol	:= 155
   	  			       Else
	  			       	  nTrocaLin := 0
			              nLin 		+= 010
			              nCol  	:= 005
			           EndIf
					   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					   //砊roca a linha																				   �
					   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		               If nTrocaLin == 4  
	            	      nTrocaLin := 0
			              nLin 		+= 010
			              nCol  	:= 005
					   EndIf	   
				   EndIf	   
			   Next
			   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			   //砅ara controle dos botoes																	   �
			   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
 	           nCol := 002
 	           nLin := 117
	        Else                 
			   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			   //矼ontando o nome da matriz de cabecalho 													   �
			   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			   aMatCab   := 'a'+aBotoes[nI,1]+'Cab'
	           cTextoBtn := AllTrim( aBotoes[nI,2] )
			   cChamada  := '{|| PlsCriGen('+aMatDad+','+aMatCab+',"'+cTextoBtn+'") }'                
     		   If nCol > 400
			      nCol := 002
			      nLin += 015
			   EndIf    
			   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			   //矱xibe o botoa																				   �
			   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
			   TButton():New( nLin, nCol, cTextoBtn, oDlg,  &cChamada , 100, 15,,,,.T.)
			   nCol +=100
			EndIf	
		Next	
    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    //矱xibe a Tela																				   �
    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	Activate MsDialog oDlg On Init EVal({||EnChoiceBar(oDlg,{||EVal(bOk)},{||EVal(bCancel)},.F.)} )
	
Return
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砅L310HDETC篈utor  矨lexander			 � Data �  05/17/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Acha o tamanho da colunao de um Browse somente necessario  罕�
北�          � passar o nome do campo                                     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PL310HDETC(cCampo)                                                  

    Local nTamTitu
    Local ntamanho
     
    nTamTitu := Len( Posicione('SX3' , 2 , cCampo , 'X3_TITULO') )
    nTamanho := Posicione('SX3' , 2 , cCampo , 'X3_TAMANHO')
    If nTamTitu > nTamanho
       nTamanho := nTamTitu
    EndIf   
    nTamanho += Iif(Posicione('SX3' , 2 , cCampo , 'X3_TIPO') <> 'C',(nTamanho*1.5),( nTamanho*3.8 ) )
    
Return nTamanho

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLDPERBL

Valida os per韔dos de bloqueio e desbloqueio de usu醨ios

@author  Karine Riquena Limp
@version P12
@since   05/07/2017

/*/
//-------------------------------------------------------------------
Function PLVLDPERBL(cAlias, cMatric, cTipReg, dData, cTp)

LOCAL lRet  := .T.
LOCAL cMsg  := ""
LOCAL nOpca := 0
LOCAL cSql  := ""
LOCAL oDlg
LOCAL aAreaAlias := (cAlias)->(getArea())
LOCAL cTitular  := SuperGetMv("MV_PLCDTIT")
LOCAL cMatDlg   := ""
LOCAL dNewData  := Date()
Local oData := NIL
Local dDtLastBlq 
DEFAULT cTipReg := ""

	
	if(cAlias == "BCA")
		lRet := (Empty(BA1->BA1_DATBLO) .OR. (!EMPTY(BA1->BA1_DATBLO) .AND. M->BCA_DATA >= BA1->BA1_DATBLO)) 
		cMsg := "O benefici醨io j� encontra-se bloqueado nesta data"
	else 
		lRet := (Empty(BA3->BA3_DATBLO) .OR. (!EMPTY(BA3->BA3_DATBLO) .AND. M->BC3_DATA >= BA3->BA3_DATBLO))           
		cMsg := "A fam韑ia j� encontra-se bloqueada nesta data"
	endIf
	
	//Para existir um desbloqueio, sempre deve haver um bloqueio
	//Estou validando para n鉶 incluir bloqueio em um periodo bloqueado
	//Exemplo:
	//bloqueio: 01/01/2017 desbloqueio: 31/12/2017
	//o sistema n鉶 permitir� incluir um bloqueio no meio desse periodo, em 01/06/2017 por exemplo
	//somente a partir de 01/01/2018
	//ent鉶 eu chamo uma dialog para que o usu醨io possa alterar a data do ultimo desbloqueio, nesse caso 31/12/2017, para poder incluir um novo bloqueio vigente
	
	if lRet .AND. cTp == "0"
				
 		lRet := !PlChHiBlo(cAlias,dData,cMatric,cTipReg)
		
		//POSICIONO NO REGISTRO DO DESBLOQUEIO QUE � O ULTIMO
		cSql := " SELECT MAX(R_E_C_N_O_) AS RECNO FROM " + RetSqlName(cAlias)
		cSql += " WHERE "
		cSql += cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += " AND " + cAlias + "_MATRIC = '" + cMatric + "' "
		cSql += iif(cAlias == "BCA","AND BCA_TIPREG = '" + cTipReg + "' "," ")
		cSql += " AND " + cAlias + "_TIPO = '1'"
		
		cSql := ChangeQuery(cSql)
		
		If Select("TRBLOQ") > 0
			TRBLOQ->(DbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBLOQ",.F.,.T.)
		
		//POSICIONO NO REGISTRO DO ULTIMO BLOQUEIO PARA INFORMAR PRO USUARIO QUE A NOVA DATA TEM QUE SER MAIOR
		cSql := " SELECT MAX(R_E_C_N_O_) AS RECNO, " + cAlias + "_DATA AS DATAUBLQ FROM " + RetSqlName(cAlias)
		cSql += " WHERE "
		cSql += cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += " AND " + cAlias + "_MATRIC = '" + cMatric + "' "
		cSql += iif(cAlias == "BCA","AND BCA_TIPREG = '" + cTipReg + "' "," ")
		cSql += " AND " + cAlias + "_TIPO = '1'"
		cSql += " GROUP BY " + cAlias + "_DATA "
		
		cSql := ChangeQuery(cSql)
		
		If Select("TRUBLOQ") > 0
			TRUBLOQ->(DbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRUBLOQ",.F.,.T.)

		
		if !lRet .AND. TRBLOQ->(!EOF())
			
			if MsgYesNo(cMsg + ". Deseja alterar a data do desbloqueio para uma data anterior � " + dtoc(dData) + " para que esse novo bloqueio seja o corrente?","Aten玢o")
			
				aArea := (cAlias)->(getArea())
				
				(cAlias)->(dbGoto(TRBLOQ->RECNO))
				
				if empty(dDtLastDesbloq) .and. nRecLastDesbloq == 0
					dDtLastDesbloq := &(cAlias+"->"+cAlias+"_DATA")
					nRecLastDesbloq := TRBLOQ->RECNO
				endIf
							
				DEFINE MsDialog oDlg Title "Desbloqueio" FROM 0,0 TO 17,60 OF GetWndDefault()

					if cAlias == "BCA"
						BA1->(dbSetOrder(2))
						BA1->(msSeek(xFilial("BA1")+BCA->(BCA_MATRIC+BCA_TIPREG)))
						cMatDlg := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
						@ 5,10  SAY "Benefici醨io: "          SIZE 60,10  OF oDlg PIXEL
						@ 5,72  SAY alltrim(BA1->BA1_NOMUSR)  SIZE 300,10 OF oDlg PIXEL
						@ 10,10 SAY "Matr韈ula: "             SIZE 30,10  OF oDlg PIXEL
						@ 10,72 SAY cMatDlg                   SIZE 60,10  OF oDlg PIXEL
						@ 15,10 SAY "Data do desbloqueio: "   SIZE 60,10  OF oDlg PIXEL
						@ 15,72 SAY dtoc(BCA->BCA_DATA)       SIZE 30,10  OF oDlg PIXEL
						@ 20,10 SAY "Motivo do desbloqueio: " SIZE 60,10  OF oDlg PIXEL
						@ 20,72 SAY BCA->BCA_MOTBLO + " - " + PLRETMOBLQ("BCA") SIZE 60,10 OF oDlg PIXEL
					else
						BA3->(dbSetOrder(1))
						BA3->(msSeek(xFilial("BC3")+BC3->BC3_MATRIC))
						BA1->(dbSetOrder(1))
						BA1->(msSeek(xFilial("BA1")+BC3->BC3_MATRIC+cTitular))
						cMatDlg := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
						@ 5,10  SAY "Titular: "          	   SIZE 60,10 OF oDlg PIXEL
						@ 5,72  SAY alltrim(BA1->BA1_NOMUSR)  SIZE 300,10 OF oDlg PIXEL
						@ 10,10 SAY "Matr韈ula: "             SIZE 30,10 OF oDlg PIXEL
						@ 10,72 SAY cMatDlg                   SIZE 60,10 OF oDlg PIXEL
						@ 15,10 SAY "Data do desbloqueio: "   SIZE 60,10 OF oDlg PIXEL
						@ 15,72 SAY dtoc(BC3->BC3_DATA)       SIZE 30,10 OF oDlg PIXEL
						@ 20,10 SAY "Motivo do desbloqueio: " SIZE 60,10 OF oDlg PIXEL
						@ 20,72 SAY BC3->BC3_MOTBLO + " - " + PLRETMOBLQ("BC3") SIZE 60,10 OF oDlg PIXEL
					endIf
					
					
					@ 35,10 SAY "Nova Data: " SIZE 30,15 OF oDlg PIXEL
					@ 35,72 MSGET oData VAR dNewData PICTURE "@D" SIZE 50,10 VALID !EMPTY(dNewData) .and. PLVLNEWDT(cAlias,dData,dNewData) OF oDlg PIXEL 
										
					DEFINE SBUTTON FROM 50,30  TYPE 1 ACTION PLGRVDBLQ(cAlias, dNewData, oDlg) ENABLE OF oDlg
							
					DEFINE SBUTTON FROM 50,60  TYPE 2 ACTION (lRet := .F., oDlg:End()) ENABLE OF oDlg
					
					if(GetNewPar("MV_PLSEXCO",.F.))
						@ 65,10  SAY "Lembre-se de alterar esse registro de desbloqueio na central de obriga珲es " COLOR CLR_HRED SIZE 250,10  OF oDlg PIXEL
					endif
				
				ACTIVATE MSDIALOG oDlg CENTERED
								
			endIf
			
			TRBLOQ->(DbCloseArea())
			TRUBLOQ->(DbCloseArea())
		
		endIf
		
	endIf
	
	
	(cAlias)->(restArea(aAreaAlias))
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRETMOBLQ
Retorna o motivo de bloqueio para a dialog

@author  Karine Riquena Limp
@version P12
@since   06/07/2017

/*/
//-------------------------------------------------------------------
Function PLRETMOBLQ(cAlias)

LOCAL cMotBlo := &(cAlias+"->"+cAlias+"_MOTBLO")
LOCAL cNivBlq := &(cAlias+"->"+cAlias+"_NIVBLQ")
LOCAL cAliasPesq := ""
LOCAL cRet    := ""

	If !Empty(cMotBlo)
	
		Do case
			case cNivBlq == "S"
			 	cAliasPesq := "BQU"
			case cNivBlq == "F"
			 	cAliasPesq := "BG1"
			case cNivBlq == "U"
				cAliasPesq := "BG3"
		EndCase
		
		cRet := alltrim(Posicione(cAliasPesq,1,xFilial(cAliasPesq)+cMotBlo,cAliasPesq+"_DESBLO"))
	
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVLNEWDT
Valida se a nova data informada para o desbloqueio � menor do que a data do 
bloqueio que o usu醨io est� tentando fazer e maior do que a data do bloqueio
atual

@author  Karine Riquena Limp
@version P12
@since   06/07/2017

/*/
//-------------------------------------------------------------------
Static Function PLVLNEWDT(cAlias, dData, dNewDt)

LOCAL cAliBlo := iif(cAlias == "BCA", "BA1", "BA3")
LOCAL lRet := dNewDt <= dData .and. dNewDt >= &(cAliBlo+"->"+cAliBlo+"_DATBLO")
LOCAL dDtLastBlq 

if(!lRet)
	
	if Select("TRUBLOQ") > 0 .and. TRUBLOQ->(!EOF())
		dDtLastBlq := ctod(TRUBLOQ->DATA)
	endIf
	
	msgAlert("A data inserida para alterar o desbloqueio deve ser maior que a do bloqueio atual (" + dtoc(dDtLastBlq) + ") e menor que a data inserida para o novo bloqueio (" + dtoc(dData) + ")")
endIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLGRVDBLQ
Grava a nova data no ultimo bloqueio

@author  Karine Riquena Limp
@version P12
@since   06/07/2017

/*/
//-------------------------------------------------------------------
Static Function PLGRVDBLQ(cAlias, dNewData, oDlg)
LOCAL cAliBlo := iif(cAlias == "BCA", "BA1", "BA3")
LOCAL cSql := ""
LOCAL dDtAnt := &(cAlias+"->"+cAlias+"_DATA")
LOCAL nI := 0

	Begin Transaction
		
		(cAlias)->(recLock(cAlias, .F.))
			&(cAlias+"->"+cAlias+"_DATA") := dNewData
		(cAlias)->(msUnlock())
	
		if(cAlias == "BC3")
			
			BA1->(dbSetOrder(1))
			BA1->(msSeek(xFilial("BA1")+BC3->BC3_MATRIC))
			aBCARecbloq := {}
			
			while BA1->(!EOF()) .and. (xFilial("BA1")+BC3->BC3_MATRIC) == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
					
					//POSICIONO NO REGISTRO DO DESBLOQUEIO DA BCA DO USUARIO PARA ALTERAR TAMB蒑
					cSql := " SELECT MAX(R_E_C_N_O_) AS RECNO FROM " + RetSqlName("BCA")
					cSql += " WHERE "
					cSql += "BCA_FILIAL = '" + xFilial("BCA") + "' "
					cSql += " AND BCA_MATRIC = '" + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) + "' "
					cSql += " AND BCA_TIPREG = '" + BA1->BA1_TIPREG + "' "
					cSql += " AND BCA_TIPO = '1' "
					cSql += " AND BCA_DATA = '" + DTOS(dDtAnt) + "' "
			
					cSql := ChangeQuery(cSql)
			
					If Select("TRBLOQBCA") > 0
						TRBLOQBCA->(DbCloseArea())
					EndIf
					
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBLOQBCA",.F.,.T.)
					
					if TRBLOQBCA->(!EOF()) 
						aAdd(aBCARecbloq, TRBLOQBCA->RECNO)
					endIf
					
				
				BA1->(dbSkip())
				
			endDo
			
			for nI := 1 to len(aBCARecbloq)
				BCA->(dbGoto(aBCARecbloq[nI]))
				BCA->(RecLock("BCA", .F.))
					BCA->BCA_DATA := dNewData
				BCA->(msUnlock())
			next nI
			
			If Select("TRBLOQBCA") > 0
				TRBLOQBCA->(DbCloseArea())
			EndIf
					
		endIf
				
	End Transaction
	
	msgInfo("Data alterada com sucesso, agora � poss韛el incluir um novo bloqueio a partir de " + dtoc(dNewData))
	oDlg:End()

Return .T.

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �04/01/2007潮�
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
北�          �	  1 - Pesquisa e Posiciona em um Banco de Dados           潮�
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
Private aRotina := {	{ STR0001	, 'AxPesqui' 	, 0 , K_Pesquisar  , 0, .F.},;
						{ STR0002	, 'AxVisual' 	, 0 , K_Visualizar , 0, Nil},;
						{ STR0003	, 'PLSA310MOV' 	, 0 , K_Incluir    , 0, Nil},;
						{ STR0004	, 'PLSA310MOV' 	, 0 , K_Alterar    , 0, Nil},;
						{ STR0005	, 'PLSA310MOV'	, 0 , K_Excluir    , 0, Nil}}
Return(aRotina)