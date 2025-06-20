#INCLUDE "TMKC030.CH"
#INCLUDE "PROTHEUS.CH"

/*
Modelo da Arvore de Monitoracao - TREE
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
�	  01 - Todos os Operadores de Call Center           �
�		  A  - Operadores do grupo de atendimento 01    �
�		  A  - Operadores do grupo de atendimento 02    �
�		  A  - Operadores do grupo de atendimento n...  �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟MKC030   튍utor  쿘arcelo Kotaki      � Data �  08/01/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘onta a tela inicial da consulta                            볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿎ALL CENTER                                                 볍�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿑ernando  �12/12/06�9.12  쿍ops 115445 Alterado a array aRotina  para  낢�
굇�          �        |      � cria豫o do menu funcional              	  낢�
굇�          �        �      �                                            낢�
굇�          �        �      �                                            낢�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function TMKC030()

Private aRotina := MenuDef()

Private cCadastro:= STR0003 //"Informa寤es de monitoramento"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Endereca a funcao de BROWSE                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
mBrowse(,,,,"SU0")

Return(.T.) 


/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o    |MenuDef	� Autor � Fernando Amorim       � Data �12/12/06  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Funcao de defini豫o do aRotina                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � aRotina   retorna a array com lista de aRotina             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � SIGATMK                                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function MenuDef() 

Local aRotina:= {		{STR0001,	"AxPesqui",		0,	1 , , .F.},;	//"Pesquisar"
						{STR0002,	"TK030Monitor",	0,	2 , , .T.} }	//"Consulta"



							
							
Return(ARotina)


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟K030Monitor튍utor  쿘arcelo Kotaki    � Data �  08/01/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎onsulta da tela de Monitoracao para o supervisor           볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿎ALL CENTER                                                 볍�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴쩡컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿌ndrea F. �06/04/04�811   �- Incluido validacao para verificar se o    낢�
굇�          �        �      쿚perador e um Supervisor para ter acesso a  낢�
굇�          �        �      퀁otina.                                     낢�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function TK030Monitor()

Local oExplorer					// Objeto principal EXPLORER.
Local oTimer					// Objeto TIMER para atualizacao dos status dos grupos
Local nRow			:= 0		// Controle de coordenadas de linhas da tela.
Local nCol			:= 0		// Coordenadas de colunas da tela.
Local nPanel		:= 0		// Numero do painel atual
Local aMemory		:= {}		// Variaveis de memoria utilizadas pelas enchoices
Local aChoice		:= {}		// Contem o ponteiro dos objetos de enchoices das tabelas SU5 e SU0
Local lSupervisor	:= .F. 		// Flag para indicar que o usuario esta no cadastro de Operadores e se e um Supervisor
Local lRet			:= .T.		// Retorno da Funcao



//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿛esquisa o usuario no cadastro de operadores	e valida se e um SUPERVISOR�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

lSupervisor := TmkOperador(.T.)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e nao encontrou o usuario no Cadastro de Operadores OU ele nao for um SUPERVISOR Nao executa �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

If !lSupervisor 
	Help(" ",1,"TK180NSUPE")  
	lRet:=.F.  
Endif

If lRet

	FATPDLoad(Nil,Nil,{"U7_NOME"}) 

	RegToMemory("SU7",.F.)
	RegToMemory("SU0",.F.)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿏efine o Explorer - tela principal da tela de consulta�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	oExplorer := MsExplorer():New(STR0004) //"Tela de Monitora豫o dos Grupos de Atendimento"
	
	//旼컴컴컴컴컴컴컴컴커
	//쿟oolbar padrao    �
	//읕컴컴컴컴컴컴컴컴켸
	oExplorer:DefaultBar()
	
	//旼컴컴컴컴컴컴컴컴커
	//쿍otoes especificos�
	//읕컴컴컴컴컴컴컴컴켸
	oExplorer:AddDefButton("BMPSERV1",	STR0005,	{ || Tkc030Change(oExplorer, @aMemory, aChoice) } ) //"Status"
	oExplorer:AddDefButton("FINAL",		STR0006,	{ || (SetKey(VK_F5, {|| AllWaysTrue() } ),oExplorer:DeActivate()) } ) //"Saida"
	
	SetKey(VK_F5, {|| Tkc030Change(oExplorer, @aMemory, aChoice) } )
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿎arrega os Grupos de atendimento                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	
	nPanel := oExplorer:AddTree(STR0007,"GROUP",,"00") //"Todos Operadores"
	nRow := Int((oExplorer:aPanel[nPanel]:nHeight * .97) / 2)
	nCol := Int((oExplorer:aPanel[nPanel]:nWidth * .985) / 2)
	
	Tkc030Painel(	oExplorer,		nPanel,		"00",		nRow,;
					nCol,			@aChoice,	@aMemory)
	
	DbSelectarea("SU0")
	DbSetOrder(1)
	MsSeek(xFilial("SU0"))
	While (!Eof()) .AND. (xFilial("SU0") == SU0->U0_FILIAL)
		
		oExplorer:AddItem(SU0->U0_NOME,"BMPUSER",SU0->U0_CODIGO,,.F.)	// Grupos de Atendimento
		
		DbSelectarea("SU0")
		DbSkip()
	End
	
	oExplorer:EndTree()
	
	DEFINE TIMER oTimer INTERVAL 5000 ACTION Tkc030Change(oExplorer, @aMemory, @aChoice)
	oExplorer:oDlg:bInit := { || oTimer:Activate() }
	
	oExplorer:bChange := {|| Tkc030Change(oExplorer, @aMemory, @aChoice)}
	
	FATPDLogUser('TKC030CHAN')	// Log de Acesso LGPD
	oExplorer:Activate()

	FATPDUnload()
Endif

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟MKC030   튍utor  쿌rmando M. Tessaroli� Data �  13/01/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘onta todo o conteudo do painel que mostrara a monitoracao  볍�
굇�          쿭os operadores.                                             볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8                                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� oExplorer - Objeto do MsExplorer                           볍�
굇�          � nPanel    - Numero do painel a ser trabalhado              볍�
굇�          � cGrupo    - Codigo do Grupo de Atendimento que sera atualiz볍�
굇�          � nRow      - Valor maximo das linhas em pixel               볍�
굇�          � nCol      - Valor maximo das colunas em pixel              볍�
굇�          � aChoice   - Array de ponteiro dos objetos enchoice         볍�
굇�          � aMemory   - Variaveis de memoria das enchoices             볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function Tkc030Painel(	oExplorer,	nPanel,		cGrupo,		nRow,;
								nCol,		aChoice,	aMemory)

Local aDados	:= {}		// Dados s serem mostrados do ListBox.
Local oListBox				// Objeto ListBox.
Local oFolder				// Folder de duas pastas com as enchoices das tabelas SU5 e SU0.
Local aCoord	:= {}		// Coordenadas de tela das enchoices.
Local aPDCols	:= {"","","","","U7_NOME",""} 

@ (nRow*.02),(nCol*.02) ListBox oListBox Fields Size (nCol*.98),(nRow*.4) Of oExplorer:GetPanel(nPanel) Pixel
oListBox:aHeaders	:= {"", STR0008, STR0009, STR0010, STR0011} //"Rotina"###"Ramal"###"in�cio"###"Operador"
oListBox:Cargo		:= "LISTBOX"
oListBox:bChange	:= { || TKC030LBChange(oListBox, @aMemory, aChoice) }

Aadd( aDados, {	LoadBitmap( GetResources(), "BR_VERDE" ), Space(30), "", "", "", "" } )
oListBox:SetArray(aDados)
oListBox:bLine:={||{	aDados[oListBox:nAt][1],;
						aDados[oListBox:nAt][2],;
						aDados[oListBox:nAt][3],;
						aDados[oListBox:nAt][4],;
						aDados[oListBox:nAt][5],;
						aDados[oListBox:nAt][6];
						}}
oListBox:nAt := 1
oListBox:Refresh()

If FATPDActive() .And. FTPDUse(.T.)
	oListBox:aObfuscatedCols := FATPDColObfuscate(aPDCols)
EndIf

@ (nRow*.45),(nCol*.02) TO (nRow*.60),(nCol) Label STR0012 OF oExplorer:GetPanel(nPanel) PIXEL //"Legendas"

@ (nRow*.50), (nCol*.03) BITMAP RESOURCE "BR_VERDE" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.50), (nCol*.06) SAY STR0013 OF oExplorer:GetPanel(nPanel) PIXEL //"Atendimento Aberto"

@ (nRow*.55), (nCol*.03) BITMAP RESOURCE "BR_AMARELO" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.55), (nCol*.06) SAY STR0014 OF oExplorer:GetPanel(nPanel) PIXEL //"Falando com Cliente"

@ (nRow*.50), (nCol*.23) BITMAP RESOURCE "BR_AZUL" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.50), (nCol*.26) SAY STR0015 OF oExplorer:GetPanel(nPanel) PIXEL //"Executando Agenda"

@ (nRow*.55), (nCol*.23) BITMAP RESOURCE "BR_LARANJA" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.55), (nCol*.26) SAY STR0016 OF oExplorer:GetPanel(nPanel) PIXEL //"Pr�-atendimento"

@ (nRow*.50), (nCol*.43) BITMAP RESOURCE "BR_VERMELHO" NO BORDER SIZE (nCol*.03), (nRow*.03) ADJUST OF oExplorer:GetPanel(nPanel) PIXEL
@ (nRow*.50), (nCol*.46) SAY STR0017 OF oExplorer:GetPanel(nPanel) PIXEL //"Novo Pr�-atendimento"


@ (nRow*.63),(nCol*.02) FOLDER oFolder ITEMS STR0011, STR0018 SIZE (nCol*.98),(nRow*.33) OF oExplorer:GetPanel(nPanel) PIXEL //"Operador"###"Grupo"
nRow := (oFolder:nHeight*.9)/2
nCol := oFolder:nWidth/2

Aadd(aCoord, { (nRow*.02), (nCol*.02), (nRow*.90), (nCol*.98) } )
Aadd( aChoice, MsMGet():New("SU7",RecNo(),2,,,,,aCoord[1],,3,,,,oFolder:aDialogs[1]) )
Aadd( aChoice, MsMGet():New("SU0",RecNo(),2,,,,,aCoord[1],,3,,,,oFolder:aDialogs[2]) )

Return()


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟k030Status튍utor  쿘arcelo Kotaki     � Data �  08/01/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿏evolve o status do Flag (Situacao da Tela), Rotina, Ramal  볍�
굇�          쿮 Tempo Inicial do atendimento - tudo baseado no SUV        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿎ALL CENTER                                                 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿬Grupo - Codigo do Grupo de Atendimento que sera pesquisado 볍�
굇�          쿬Tipo  - Tipo de retorno esperado da funcao                 볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function Tk030Status(cGrupo, cTipo)

Local oAberta	:= LoadBitmap( GetResources(), "BR_VERDE" )			// Objeto de cor da legenda
Local oCliente	:= LoadBitmap( GetResources(), "BR_AMARELO" )		// Objeto de cor da legenda
Local oAtivo	:= LoadBitmap( GetResources(), "BR_AZUL" )			// Objeto de cor da legenda
Local oPreAtend	:= LoadBitmap( GetResources(), "BR_LARANJA" )		// Objeto de cor da legenda
Local oNovoPre	:= LoadBitmap( GetResources(), "BR_VERMELHO" )		// Objeto de cor da legenda
Local xRet		:= ""												// Retorno devolvido pelo fun豫o

If cTipo == "3"  	// Ramal
	xRet := SUV->UV_RAMAL
Endif

If cTipo == "4"  	// Hora Inicial
	xRet := SUV->UV_HRINI
Endif

If cTipo $ "12"  // Status e Tela
	Do Case
		Case SUV->UV_ROTINA == "TMK0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0019 //"Telemarketing"
			Endif
			
		Case SUV->UV_ROTINA == "TMK1"
			If cTipo == "1"
				xRet := oCliente
			Else
				xRet := STR0019 //"Telemarketing"
			Endif
			
		Case SUV->UV_ROTINA == "TLV0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0020 //"Televendas"
			Endif
			
		Case SUV->UV_ROTINA == "TLV1"
			If cTipo == "1"
				xRet := oCliente
			Else
				xRet := STR0020 //"Televendas"
			Endif
			
		Case SUV->UV_ROTINA == "TLC0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0021 //"Telecobran�a"
			Endif
			
		Case SUV->UV_ROTINA == "TLC1"
			If cTipo == "1"
				xRet := oCliente
			Else
				xRet := STR0021 //"Telecobran�a"
			Endif
			
		Case SUV->UV_ROTINA == "AGE0"
			If cTipo == "1"
				xRet := oAberta
			Else
				xRet := STR0022 //"Agenda"
			Endif
			
		Case SUV->UV_ROTINA == "AGE1"
			If cTipo == "1"
				xRet := oAtivo
			Else
				xRet := STR0022 //"Agenda"
			Endif
			
		Case SUV->UV_ROTINA == "PRE0"
			If cTipo == "1"
				xRet := oPreAtend
			Else
				xRet := STR0016 //"Pr�-atendimento"
			Endif
			
		Case SUV->UV_ROTINA == "PRE1"
			If cTipo == "1"
				xRet := oNovoPre
			Else
				xRet := STR0017 //"Novo Pr�-atendimento"
			Endif
	Endcase
Endif

Return(xRet)


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟MKC030   튍utor  쿌rmando M. Tessaroli� Data �  13/01/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿌tualiza os dados do painel principal de agordo com a troca 볍�
굇�          쿭os itens do tree dentro do objeto Explorer.                볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8                                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� oExplorer - Objeto do MsExplorer                           볍�
굇�          � aMemory   - Variaveis de memoria das enchoices             볍�
굇�          � aChoice   - Array de ponteiro dos objetos enchoice         볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Tkc030Change(oExplorer, aMemory, aChoice)

Local cGrupo	:= oExplorer:GetPanel(oExplorer:nPanel):Cargo	// Cargo do objeto que guarda o codigo do grupo de atendimento
Local aDados	:= {}		// Dados que serao apresentados no listbox
Local oListBox				// Objeto listbox
Local oSU5					// Enchoice da tabela SU5
Local oSU0					// Enchoice da tabela SU0
Local aTemp		:= {}		// Array temporario para localizar um objeto dentro do Explorer
Local nI		:= 0		// Controle de loop

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿛ega os dados do item de telemarketing.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aTemp := aClone(oExplorer:aPanel[1]:oWnd:aControls)
For nI := 1 To Len(aTemp)
	If ValType(aTemp[nI]) == "O" .AND. ValType(aTemp[nI]:Cargo) == "C" .AND. aTemp[nI]:Cargo == "LISTBOX"
		oListBox := aTemp[nI]
	Endif
	If ValType(aTemp[nI]) == "O" .AND. ValType(aTemp[nI]:Cargo) == "C" .AND. aTemp[nI]:Cargo == "SU5"
		oSU5 := aTemp[nI]
	Endif
	If ValType(aTemp[nI]) == "O" .AND. ValType(aTemp[nI]:Cargo) == "C" .AND. aTemp[nI]:Cargo == "SUO"
		oSU0 := aTemp[nI]
	Endif
	If ValType(oListBox) == "O" .AND. ValType(oSU5) == "O" .AND. ValType(oSU0) == "O"
		Exit
	Endif
Next nI

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿘antem o primeiro painel sempre ativo.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oExplorer:SetPanel(1)

If !Empty(cGrupo)
	DbSelectarea("SUV")
	DbSetorder(1)
	MsSeek(xFilial("SUV"))
	While ! Eof() .AND. SUV->UV_FILIAL == xFilial("SUV")
		
		If Empty(SUV->UV_ROTINA)
			DbSelectArea("SUV")
			DbSkip()
			Loop
		Endif
		
		
		If cGrupo == "00"
			DbSelectarea("SU7")
			DbSetorder(4)		// U7_FILIAL+U7_CODUSU
			If MsSeek(xFilial("SU7")+SUV->UV_USUARIO)
				DbSelectarea("SUV")
				If DBRLOCK()
					SUV->UV_ROTINA  := ""
					DBRUNLOCK()
				EndIf
				Aadd( aDados, {	Tk030Status(cGrupo,"1"),;
								Tk030Status(cGrupo,"2"),;
								Tk030Status(cGrupo,"3"),;
								Tk030Status(cGrupo,"4"),;
								SU7->U7_NOME,;
								SUV->UV_USUARIO;
								} )
			Endif
		Else
			DbSelectarea("SU7")
			DbSetorder(4)		// U7_FILIAL+U7_CODUSU
			If MsSeek(xFilial("SU7")+SUV->UV_USUARIO)
				If SU7->U7_POSTO == cGrupo
					DbSelectarea("SUV")
					If DBRLOCK()
						SUV->UV_ROTINA  := ""
						DBRUNLOCK()
					EndIf
					Aadd( aDados, {	Tk030Status(cGrupo,"1"),;
									Tk030Status(cGrupo,"2"),;
									Tk030Status(cGrupo,"3"),;
									Tk030Status(cGrupo,"4"),;
									SU7->U7_NOME,;
									SUV->UV_USUARIO;
									} )
				Endif
			Endif
		Endif
		
		DbSelectArea("SUV")
		DbSkip()
	End
Endif

If Len(aDados) == 0
	Aadd( aDados, {	LoadBitmap( GetResources(), "BR_VERDE" ), Space(30), "", "", "", "" } )
Endif
oListBox:SetArray(aDados)
oListBox:bLine:={||{	aDados[oListBox:nAt][1],;
						aDados[oListBox:nAt][2],;
						aDados[oListBox:nAt][3],;
						aDados[oListBox:nAt][4],;
						aDados[oListBox:nAt][5],;
						aDados[oListBox:nAt][6];
						}}
oListBox:nAt := 1
oListBox:Refresh()
	
DbSelectArea("SU7")
DbSetOrder(4)
If MsSeek(xFilial("SU7") + aDados[oListBox:nAt][6])
	Tkc030Memory("SU7", @aMemory, .T.)
Else
	Tkc030Memory("SU7", @aMemory, .F.)
Endif
aChoice[1]:Refresh()
	
DbSelectArea("SU0")
DbSetOrder(1)
If MsSeek(xFilial("SU0") + SU7->U7_POSTO)
	Tkc030Memory("SU0", @aMemory, .T.)
Else
	Tkc030Memory("SU0", @aMemory, .F.)
Endif
aChoice[2]:Refresh()

Return(.T.)


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴敲굇
굇튡rograma  쿟kc030Memory튍utor 쿌rmando M. Tessaroli� Data � 14/01/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴묽�
굇튒esc.     쿌tualizacao das variaveis de memoria que alimentam o objeto 볍�
굇�          쿭a enchoice com os dados da posicao atual.                  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8                                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿬Alias  - Nome da tabela a ser trabalhada                   볍�
굇�          쿪Memory - Variaveis de memoria utilizadas pela enchoice     볍�
굇�          쿹Dados  - Define se as veriaveis serao iniciadas com conteud볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Tkc030Memory(cAlias, aMemory, lDados)

Local lRet		:= .T.		// Retorno da funcao
Local cCampo	:= ""		// Nome do campo
Local nPos		:= 0		// Posicao de objeto
Local nI		:= 0		// Contador de loop

Default lDados	:= .T.		// Define se cria as variaveis com dados ou em branco

nPos := Ascan(aMemory, {|x| x[1] == cAlias })
If nPos == 0
	DbSelectArea("SX3")
	DbSetOrder(1)
	MsSeek(cAlias)
	While ( !SX3->( Eof() ) .AND. SX3->X3_ARQUIVO == cAlias)
		If X3USO(SX3->X3_USADO)
			cCampo := ALLTRIM(SX3->X3_CAMPO)
			Aadd(aMemory, {cAlias, cCampo, X3_CONTEXT} )
			If lDados
				If (X3_CONTEXT # "V")
					M->&(cCampo) := (cAlias)->&(cCampo)
				Else
					M->&(cCampo) := CriaVar(cCampo, lDados)
				Endif
			Else
				M->&(cCampo) := CriaVar(cCampo, lDados)
			Endif
		Endif
		
		DbSkip()
	End
Else
	For nI := nPos To Len(aMemory)
		cCampo := AllTrim(aMemory[nI][2])
		If lDados
			If (aMemory[nI][3] # "V")
				M->&(cCampo) := (cAlias)->&(cCampo)
			Else
				M->&(cCampo) := CriaVar(cCampo, lDados)
			Endif
		Else
			M->&(cCampo) := CriaVar(cCampo, lDados)
		Endif
		
		If aMemory[nI][1] <> cAlias
			Exit
		Endif
	End
EndIf

Return(lRet)



/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟MKC030   튍utor  쿌rmando M. Tessaroli� Data �  14/01/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎ontrola a atualizacao das enchoices pelo evento change dos 볍�
굇�          쿶tens do listbox com os operadores.                         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8                                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿽ListBox - Objeto ListBox onde o evento sera tratado        볍�
굇�          쿪Memory  - Variaveis de memoria das enchoices SU5 e SU0     볍�
굇�          쿪Choice  - Referencia dos objetos das enchoices SU5 e SU0   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function TKC030LBChange(oListBox, aMemory, aChoice)
	
DbSelectArea("SU7")
DbSetOrder(4)
If MsSeek(xFilial("SU7") + oListBox:aArray[oListBox:nAt][6])
	Tkc030Memory("SU7", @aMemory, .T.)
Else
	Tkc030Memory("SU7", @aMemory, .F.)
Endif

If Len(aChoice) > 0
	aChoice[1]:Refresh()
Endif
	
DbSelectArea("SU0")
DbSetOrder(1)
If MsSeek(xFilial("SU0") + SU7->U7_POSTO)
	Tkc030Memory("SU0", @aMemory, .T.)
Else
	Tkc030Memory("SU0", @aMemory, .F.)
Endif

If Len(aChoice) > 0
	aChoice[2]:Refresh()
Endif

Return(.T.)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote豫o de dados.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta fun豫o deve utilizada somente ap�s a inicializa豫o das variaveis 
    atravez da fun豫o FATPDLoad.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa寤es enviadas, 
    quando a regra de auditoria de rotinas com campos sens�veis ou pessoais estiver habilitada
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que ser� utilizada no log das tabelas
    @param nOpc, Numerico, Op豫o atribu�da a fun豫o em execu豫o - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria n�o esteja aplicada, tamb�m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun豫o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
