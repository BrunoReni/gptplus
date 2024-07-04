#INCLUDE "PCOA170.ch"
#INCLUDE "PROTHEUS.CH"
#include "pcoicons.ch"
/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA170  � AUTOR � Paulo Carnelossi      � DATA � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de manutecao da consulta gerencial do PCO           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA170                                                      潮�
北砡DESCRI_  � Programa de manutecao da consulta gerencial                  潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal a  潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo : PCOA170(2) - Executa a chamada da funcao de visua- 潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA170(nCallOpcx)

PRIVATE cCadastro	:= STR0001 //"Visao Gerencial Orcamentaria"
Private aRotina := MenuDef()						
Private nRecAKN
Private M->AKR_ORCAME := Padr(" ", Len(AKR->AKR_ORCAME))

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		PCO170DLG("AKN",AKN->(RecNo()),nCallOpcx,,,)
	Else
		mBrowse(6,1,22,75,"AKN")
	EndIf
EndIf

Return 
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅CO170DLG� Autor � Paulo Carnelossi       � Data � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o � Programa de montagem da DIALOG de manutencao da consulta     潮�
北�          � gerencial.                                                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAPCO                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCO170DLG(cAlias,nReg,nOpcx)

Local oDlg

Local cArquivo		:= CriaTrab(,.F.)
Local cFiltro 		:= ".T."

Local lOk
Local l170Inclui	:= .F.
Local l170Visual	:= .F.
Local l170Altera	:= .F.
Local l170Exclui	:= .F.
Local lContinua		:= .T.

Local aButtons		:= {}
Local aUsrButons	:= {}
Local aMenu			:= {}

Local nX			:= 0
Local nDirAcesso 	:= 0

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l170Visual := .T.
	Case (aRotina[nOpcx][4] == 3)
		l170Inclui	:= .T.
	Case (aRotina[nOpcx][4] == 4)
		l170Altera	:= .T.
	Case (aRotina[nOpcx][4] == 5)
		lOk			:= .F.
		l170Exclui	:= .T.
		l170Visual	:= .T.
EndCase

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Utiliza a funcao axInclui para incluir a visao gerencial  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If l170Inclui
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario na EnchoiceBar                              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA1702" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios na      �
		//P_E� enchoicebar da telade cadastro de orcamentos                           �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo os botoes a serem adicionados na enchoice  �
		//P_E�               Ex. :  User Function PCOA1702                            �
		//P_E�                      Return {{PEDIDO",{||U_TESTE()},"Teste"}}          �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsButtons := ExecBlock( "PCOA1702", .F., .F. ) ) == "A"
			AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
		EndIf
	EndIf
	
	If AxInclui(cAlias,nReg,nOpcx,,,,"A170ChkCfg()",,"PCO170Atu()",aButtons) <> 1
		lContinua := .F.
	Else
	   //se incluiu registro normalmente
	   dbSelectArea("AKN")
	   dbGoto(nRecAKN)  //variavel nRecAKN foi atribuida na function PCO170Atu()

	   //Posicionar tb em AKO - contas orcamentarias da planilha
	   dbSelectArea("AKO")
	   dbSetOrder(1)
	   //conta orcamentaria raiz recebe o mesmo codigo do orcamento
	   dbSeek(xFilial("AKO")+AKN->AKN_CODIGO+AKN->AKN_CODIGO)
	   
	   dbSelectArea("AKN")
	   
	EndIf
EndIf

If SuperGetMV("MV_PCO_AKN",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lContinua := .T.                        // 2-Nao verifica o acesso por entidade
Else
	nDirAcesso := PcoDirEnt_User("AKN", AKN->AKN_CODIGO, __cUserID, .F.)
    If nDirAcesso == 0 //0=bloqueado
		Aviso(STR0011,STR0013,{STR0014},2)//"Atencao"###"Usuario sem acesso a esta configura玢o de visao gerencial. "###"Fechar"
		lContinua := .F.
	ElseIf nDirAcesso  == 1 //somente visualizacao
		If nOpcx == 4 .OR. nOpcx == 5  //se for opcao exclusao da planilha bloqueia o acesso
			Aviso(STR0011,STR0013,{STR0014},2)//"Atencao"###"Usuario sem acesso a esta configura玢o de visao gerencial. "###"Fechar"
			lContinua := .F.
		EndIf
	Else
	    lContinua := .T.
	EndIf
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� ExecBlock para inclusao de botoes customizados       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock("PCOA1703")
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios na     �
	//P_E� tela da planilha orcamentaria                                          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na planilha �
	//P_E�              [1] : Titulo                                              �
	//P_E�              [2] : Codeblock contendo a funcao do usuario              �
	//P_E�              [3] : Resource utilizado no bitmap                        �
	//P_E�              [4] : Tooltip do bitmap                                   �
	//P_E�              Exemplo :                                                 �
	//P_E�              User Function PCOXFUN1                                    �
	//P_E�              Return {{"Titulo", {|| U_Botao() }, "BPMSDOC","Titulo" }} �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	aUsrButons := ExecBlock("PCOA1703",.F.,.F.)
	For nx := 1 to Len(aUsrButons)
		aAdd(aMenu,{aUsrButons[nx,1],aUsrButons[nx,2],aUsrButons[nx,3],aUsrButons[nx,4]})
	Next
EndIf

If lContinua
	If !l170Visual
		MENU oMenu POPUP
			MENUITEM STR0007 ACTION (Pco170to171(2,cArquivo),Eval(bRefresh)) //"Visualizar C.O.G."
			MENUITEM STR0008 ACTION (Pco170to171(3,cArquivo),Eval(bRefresh)) //"Incluir C.O.G."
			MENUITEM STR0009 ACTION (Pco170to171(4,cArquivo),Eval(bRefresh)) //"Alterar C.O.G."
			MENUITEM STR0010 ACTION (Pco170to171(5,cArquivo),Eval(bRefresh)) //"Excluir C.O.G."
		ENDMENU
	Else
		MENU oMenu POPUP
			MENUITEM STR0007 ACTION (Pco170to171(2,cArquivo),Eval(bRefresh)) //"Visualizar C.O.G."
		ENDMENU
	EndIf
	aMenu := {	{TIP_PESQUISAR,		{|| PcoAKNPesq(cArquivo) }, BMP_PESQUISAR, TOOL_PESQUISAR},;
				{TIP_ORC_ESTRUTURA,	{|| PCO170Menu(@oMenu,l170Visual,cArquivo),oMenu:Activate(140,45,oDlg) },BMP_ORC_ESTRUTURA,TOOL_ORC_ESTRUTURA}}

	PCOAKNPLAN(STR0001,,cArquivo,@lOk,aMenu,@oDlg,,,l170Visual,cFiltro) //"Visao Gerencial Orcamentaria"
	
	If lOk <> Nil .And. lOk .And. l170Exclui
		A170Exclui()
	EndIf

EndIf

Return



/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅CO170ATU� Autor 砅aulo Carnelossi        � Data � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o � Funcao de chamada da rotina de atualiacao das tabelas relacio潮�
北�          � nadas a consulta gerencial orcamentaria.                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAPCO                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCO170ATU()

nRecAKN := Recno()
PcoAvalAKN("AKN",1)

Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅CO170Menu� Autor � Paulo Carnelossi      � Data � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o � Funcao de controle do menu de atualizacoes.                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAPCO                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCO170Menu(oMenu,lVisual,cArquivo)
Local aArea		:= GetArea()
Local cAlias	
Local nRecView	

cAlias	:= (cArquivo)->ALIAS
nRecView	:= (cArquivo)->RECNO
dbSelectArea(cAlias)
dbGoto(nRecView)

If !lVisual
	Do Case 
		Case cAlias == "AKO" .And. AKO->AKO_NIVEL == "001"
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Disable()
		Case cAlias == "AKO" 
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
		Otherwise
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
	EndCase
   
EndIf

RestArea(aArea)
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅CO170to171� Autor � Paulo Carnelossi     � Data � 16/11/2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 矲uncao de chamada do PCOA171 para atualizacao do Conta Orc Ger潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      砅COA170                                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCO170to171(nOpc,cArquivo)

Local aArea		:= GetArea()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� ExecBlock para inclusao de botoes customizados       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock("PCOA1704")
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para validacao da rotina chamada no menu    �
	//P_E� Estrutura no programa de atualizacao da planilha orcamentaria.         �
	//P_E� Parametros : [1] - Numerico - Opcao selecionada                        �
	//P_E� Retorno    : Logico - Permite ou na a utilizacao da opcao selecionada. �
	//P_E�              Exemplo :                                                 �
	//P_E�              User Function PCOA1704                                    �
	//P_E�              Local lRet := .F.                                         �
	//P_E�              If ParamIXB[1] == 1                                       �	
	//P_E�                 lRet := .T.                                            �	
	//P_E�              EndIf                                                     �	
	//P_E�              Return lRet                                               �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If !ExecBlock("PCOA1704", .F., .F., {nOpc})
		RestArea(aArea)
		Return
	EndIf
EndIf

cAlias := (cArquivo)->ALIAS
nRecAlias := (cArquivo)->RECNO

dbSelectArea(cAlias)
dbGoto(nRecAlias)
Do Case
	Case nOpc == 2
		PCOA171(2,,"000")
	Case nOpc == 3
		aGetCpos := {	{"AKO_CODIGO",AKO->AKO_CODIGO,.F.},;
						{"AKO_COPAI",AKO->AKO_CO,.F.}}

		nRecAKO	:= PCOA171(3,aGetCpos,AKO->AKO_NIVEL)
	Case nOpc == 4 
		PCOA171(4,,"000")
	Case nOpc == 5
	    If PadR(AKO_CODIGO, Len(AKO_CO))!=PadR(AKO_CO, Len(AKO_CO))
			PCOA171(5,,"000")
		EndIf	
EndCase

RestArea(aArea)
Return	

Static Function A170Exclui()
Local cVisGer := AKN->AKN_CODIGO
Local aArea   := GetArea()

//exclui a ITENS da conta orcamentaria
dbSelectArea("AKP")
dbSetOrder(1)

Begin Transaction

While dbSeek(xFilial("AKP")+cVisGer)
	RecLock("AKP",.F.,.T.)
	dbDelete()
	MsUnlock()
End

//exclui contas orcamentaria da planilha
dbSelectArea("AKO")
dbSetOrder(1)

While dbSeek(xFilial("AKO")+cVisGer)
	RecLock("AKO",.F.,.T.)
	dbDelete()
	MsUnlock()
End

//exclui contas orcamentaria da planilha
dbSelectArea("AKN")
dbSetOrder(1)

While dbSeek(xFilial("AKN")+cVisGer)
	RecLock("AKN",.F.,.T.)
	dbDelete()
	MsUnlock()
End

End Transaction

RestArea( aArea )

Return

Function A170ChkCfg()
Local lRet := .T.
If Alltrim(M->AKN_CONFIG) == "002"
	Aviso(STR0011, STR0012, {"Ok"}) //"Atencao"###"Configuracao de parametros reservado para simulacoes por inclusao/movimento !"
	lRet := .F.
EndIf
Return(lRet)		


Static Function MenuDef()
PRIVATE aRotina 	:= {	{ STR0002,		"AxPesqui"  , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"PCO170DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"PCO170DLG" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"PCO170DLG" , 0 , 4},; //"Alterar"
							{ STR0006, 		"PCO170DLG" , 0 , 5}} //"Excluir"
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no Browse                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA1701" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de orcamentos                                           �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOPE001                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA1701", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)