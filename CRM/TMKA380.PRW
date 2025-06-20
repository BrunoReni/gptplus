#INCLUDE "TMKA380.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
  쿐strutura do array de aAtividades  �
  �                                   �
  쿑uncao Tmka380c/Tk380CarregaSU4    �
  �                                   �
  �1- Codigo da Lista de contato.     �
  �2- Status da Lista de Contatos     �
  �3- Data da Lista                   �
  �4- Hora  para execucao da Lista.   �
  �5- Nome da Lista.                  �
  �6- Operador que trabalhara a lista.�
  �7- Rotina.                         �
  �8- Codigo da ligacao pendente.     �
  |9- Forma 						  |
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿟MKA380   튍utor  쿝afael M. Quadrotti � Data �  01/12/03   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿌genda do operador. Marketing Ativo.                        볍�
굇�          쿑uncao principal onde eh criada a tela da agenda do operador볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � Call Center                                                볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴錮袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튝arcelo K �06/06/02�710   �-Notacao e Logica                           볍�
굇튗enry Fila�22/07/05�811   �-Declaracao da variavel oLbx para nao causar볍�
굇�          �        �      � erro quando utilizado a consulta cliente   볍�
굇튗anna C.  |30/03/07|10    쿍ops 118469 - Alterado o nome dos Bitmaps   낢�
굇�        	 �        |      쿭efinidos pela Engenharia para o Protheus 10낢�
굇튏onrado Q.�03/08/07�10    �-BOPS 130949: Ajuste de mensagem de ajuda.  볍�
굇훤袴袴袴袴賈袴袴袴袴鳩袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Tmka380()     	

Local oDlgAgenda									// Principal Dialogo.
Local cCadastro 		:= STR0001 					// Titulo da Dialog //"Agenda do Operador"
Local cU6Status 		:= "0%"						// Status dos itens executados da atividade.
Local cSaudacao		 	:= DiaExtenso(dDatabase) + ", " 	+ StrZero(Day(dDatabase),2) + ;
													" " 	+ AllTrim(MesExtenso(Month(dDatabase))) + ; 
													" " 	+ StrZero(Year(dDatabase),4)
Local oFont 			:= "" 						// Fonte para saudacao.
Local oFont2 			:= "" 						// Fonte para saudacao.
Local oU6Status										// Status dos itens executados da atividade.
Local oCalend1										// Objeto do calendario 1
Local oCalend2										// Objeto do calendario 2
Local oCalend3										// Objeto do calendario 3
Local oPDetalhes									// Objeto para painel de detalhes
Local oScrDet										// Scroll do painel de detalhes.
Local oPPendencia									// Objeto para painel de pendencia
Local oLbx											// Objeto do listbox
Local oObj1											// Primeiro Objeto do painel de detalhes.
Local oObj2
Local oObj3
Local oObj4
Local oObj5
Local oObj6
Local oObj7
Local oObj8
Local oObj9
Local oObj10
Local oObj11
Local oObj12
Local oObj13
Local oObj14
Local oObj15
Local oObj16 										// Decimo Sexto Objeto do painel de detalhes.
Local oBmpA											// Bitmaps da legenda.
Local oBmpV											// Bitmaps da legenda.
Local oBmpVM 										// Bitmaps da legenda.
Local oUOMeta							   			// Meta de campanha para contatos
Local cUOMEta			:= "0"						// Meta de campanha para contatos
Local aAtividades		:= {}						// Array com as atividades do dia (SU4) ListBox.
Local nCol				:= 0						// Controle de coordenadas para a criacao da tela.
Local nRow				:= 0						// Controle de coordenadas para a criacao da tela.
Local nAjust			:= 34						// vari�vel de controle de ajuste do tamanho da Dialog
Local aDet_Panel		:= {}						// Array com as informacoes do Painel de detalhes  
Local aPend_Panel		:= {}						// Array com as informacoes do Painel de pendencia
Local lRet				:= .F.						// Retorno da funcao
Local aPDFields 		:= {"U5_CONTAT","A1_NOME","US_NOME","ACH_RAZAO","U5_END","U5_EST","U5_FONE","U5_FCOM1","U5_CELULAR","U5_EMAIL","U5_MUN"}

// Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
FATPDLoad(/*cUserPDA*/, /*aAlias*/, aPDFields)

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿙ao permite a abertura simultanea para o modelo MDI�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !ExcProcess("TMK" + __cUserId)
	Help("  ",1,"TMKPROMDI")
	Return(lRet)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣erifica se o usuario da senha esta  no cadastro de operadores�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !TMKOPERADOR()
	Help("  ",1,STR0002) //"OPERADOR"
	Return(lRet)
Endif	

//旼컴컴컴컴컴컴커
//쿌justa o Help.�
//읕컴컴컴컴컴컴켸
AjustaHelp()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e o Operador tiver acesso a TODAS as rotinas ou SOMENTE TELECOBRANCA	�
//쿣erifica se o Operador possui regra de selecao e de negociacao			�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If (TkGetTipoAte() $ "34") // se utilizar telecobranca.
	If Empty(TkPosto(TkOperador(),"U0_REGSEL")) .OR. Empty(TkPosto(TkOperador(),"U0_REGNEG"))
		Help("  ",1,"TK280REGRA")
		Return(lRet)
	Endif
Endif	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣erifica se o Operador realiza atendimento somente RECEPTIVO�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If VAL(TkPosto(TkOperador(),"U0_BOUND")) == RECEPTIVO
	Help("  ",1,"TK280ATEND")
	Return(lRet)
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿛osiciona na agenda e apresenta as listas POR OPERADOR      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("SU4")
DbSetOrder(5)
DbSeek(xFilial("SU4"))

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿔nicializa informacoes do painel de detalhes                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Aadd(aDet_Panel,{STR0003,oObj1})  	//"Lista de "
AAdd(aDet_Panel,{STR0004,oObj2}) 	//"Entidade: "
AAdd(aDet_Panel,{STR0005,oObj3}) 	//"Rotina: "
AAdd(aDet_Panel,{STR0006,oObj4}) 	//"Campanha: "
AAdd(aDet_Panel,{STR0007,oObj5}) 	//"Script: "
AAdd(aDet_Panel,{STR0008,oObj6})  	//"Evento: "
AAdd(aDet_Panel,{STR0009,oObj7}) 	//"Tipo de Contato: "
AAdd(aDet_Panel,{STR0010,oObj8})   	//"Tipo de Telefone: "
AAdd(aDet_Panel,{STR0011,oObj9})  	//"Tipo de Endere�o: "
AAdd(aDet_Panel,{STR0012,oObj10})  	//"Assunto do E-mail: "

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿔nicializa informacoes do painel de pendencias              � 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Aadd(aPend_Panel,{STR0013,oObj11})  //"Contato: "
Aadd(aPend_Panel,{STR0014,oObj12})  //"Cidade: "
Aadd(aPend_Panel,{STR0015,oObj13})  //"Estado: "
Aadd(aPend_Panel,{STR0016,oObj14})  //"Retorno: "
Aadd(aPend_Panel,{STR0017,oObj15})  //"Empresa: "
Aadd(aPend_Panel,{STR0018,oObj16})  //"Data da Pend�ncia: "


// Defines das Fontes utilizadas no codigo.
DEFINE FONT oFont   NAME "Arial" SIZE 0,20 BOLD    
DEFINE FONT oFont2  NAME "Arial" SIZE 0,14 BOLD    

oMainWnd:ReadClientCoors()
nCol := oMainWnd:nClientWidth
nRow := oMainWnd:nClientHeight

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿔nforma ao gerenciador de m�ltiplos grupos de atendimento�
//쿿ue a rotina agenda do operador est� em execu豫o.        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
TK091Start( AGENDAOPERADOR )

//Ajuste do tamanho da Dialog quando o tema for TEMAP10	
If AllTrim(GetTheme()) # "TEMAP10"
	nAjust := 70
Endif  

DEFINE MSDIALOG oDlgAgenda TITLE cCadastro + " - " + TK091Titulo(TkOperador()) FROM 00,00 TO nRow-nAjust,nCol-8 PIXEL

	oDlgAgenda:lMaximized := .T.
	
	@00,00 MSPANEL oPanel1 SIZE 50,50
	
	// Atualiza as coordenadas com as definicoes da dialog para facilitar a criacao dos objetos
	nCol := oDlgAgenda:nClientWidth/2
	nRow := oDlgAgenda:nClientHeight/2
	
	@00,00 MSPANEL oSPanel SIZE 12,12 OF oPanel1
	oSPanel:Align := CONTROL_ALIGN_TOP
	
	// Saudacao da tela de atendimento
	@ 01,03 SAY oSaudacao PROMPT cSaudacao OF oSPanel FONT oFont  PIXEL COLOR CLR_BLUE SIZE 300,10
	
	//旼컴컴컴컴컴컴컴컴컴컴컴커
	//쿞e a tela estiver em MDI�
	//읕컴컴컴컴컴컴컴컴컴컴컴켸
	If !SetMDIChild()	
		@00,00 BITMAP oLogo RESOURCE "MDILOGO1" PIXEL OF oSPanel NO BORDER
		oLogo:lAutoSize := .T.
		oLogo:Align := CONTROL_ALIGN_RIGHT
	Endif

	// Status dos itens trabalhados no SU6
	@ 15,03 SAY STR0019    OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	 //"Percentual executado desta Lista:"
	@ 15,CalcFieldSize("C",Len(STR0019),0) SAY oU6Status PROMPT cU6Status OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	

	// Informacoes da campanha.
	@ 15,300 SAY STR0020 OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	 //"Objetivo da Campanha:"
	@ 15,300+CalcFieldSize("C",Len(STR0020),0) SAY oUOMeta PROMPT cUOMeta  OF oPanel1 FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	
	
	@00,00 SCROLLBOX oScr1 SIZE 50,50
	
	oCalend1:=MsCalend():New(02,02,oScr1)
	oCalend1:Disable()
	oCalend1:Refresh()
	
	oCalend2:=MsCalend():New(02,150,oScr1)
	oCalend2:dDiaAtu := dDataBase
	oCalend2:bChangeMes := {|| Tk380ChgMes(oCalend2:dDiaAtu,oCalend1,oCalend2,oCalend3),;
								oCalend3:dDiaAtu := oCalend2:dDiaAtu+30,;
								oCalend1:dDiaAtu := oCalend2:dDiaAtu-30,;
								oCalend1:Refresh(),;
								oCalend3:Refresh() }

	oCalend2:bChange    := {|| 	aAtividades:=Tk380CarregaSU4(oCalend2:dDiaAtu),;
								ASort(aAtividades,,,{|x,y| DToS(x[3])+x[4] < DToS(y[3])+y[4]}),;
								oLbx:SetArray(aAtividades),;
								oLbx:bLine:={||{Tk380Leg(	aAtividades[oLbx:nAt,2]),;
															aAtividades[oLbx:nAt,3],;
															aAtividades[oLbx:nAt,4],;
															aAtividades[oLbx:nAt,5],;
															aAtividades[oLbx:nAt,6],;
															Tk380RetRot(aAtividades[oLbx:nAt,7])}},;
								Tk380PDetalhes(@aDet_Panel,aAtividades[oLbx:nAt],@oPDetalhes)	,;	  // Atualiza o painel de detalhes
								Tk380PPendencia(@aPend_Panel,aAtividades[oLbx:nAt],@oPPendencia),;  // Atualiza o painel de pendencias
								Tk380AtuSaudacao(oU6Status,oUOMeta,aAtividades[oLbx:nAt]),; // Atualiza os dados do cabecalho.
								oLbx:Refresh(),;
								oCalend3:dDiaAtu := oCalend2:dDiaAtu+30,;
								oCalend1:dDiaAtu := oCalend2:dDiaAtu-30}
	
	oCalend3:=MsCalend():New(02,298,oScr1)
	oCalend3:Disable()
	oCalend3:Refresh()
	
	oCalend3:dDiaAtu := oCalend2:dDiaAtu+30
	oCalend1:dDiaAtu := oCalend2:dDiaAtu-30
	
	//"Selecionando as atividades do dia "	
	Processa({|lEnd|aAtividades := Tk380CarregaSU4(dDataBase)},STR0021 + STRZERO(Day(dDataBase),2)+"/"+STRZERO(Month(dDatabase),2),,.T.)

	/*
	  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	  쿐strutura do array de aAtividades  �
	  �                                   �
	  쿑uncao Tmka380c/Tk380CarregaSU4    �
	  �                                   �
	  �1- Codigo da Lista de contato.     �
	  �2- Status da Lista de Contatos     �
	  �3- Data da Lista                   �
	  �4- Hora  para execucao da Lista.   �
	  �5- Nome da Lista.                  �
	  �6- Operador que trabalhara a lista.�
	  �7- Rotina.                         �
	  �8- Codigo da ligacao pendente.     �
	  |9- Forma 						  |
	  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	*/

	ASORT(aAtividades,,,{|x,y| DTOS(x[3])+ x[4] < DTOS(y[3])+y[4]})
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿟arefas relacionadas a data.�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	@00,00 LISTBOX oLbx FIELDS ;
			HEADER ;
			" ",;		// 01 - Legenda   
			STR0022,;	// 02 -  //"Data"
			STR0023,;	// 03 -  //"Hora"
			STR0024,;	// 04 -  //"Nome"
			STR0002,;	// 05 -  //"Operador"
			STR0025;	// 06 -  //"Rotina"
			SIZE 100,100 OF oDlgAgenda PIXEL 

			oLbx:SetArray(aAtividades)
			oLbx:bLine:={||{Tk380Leg(	aAtividades[oLbx:nAt,2]),;
										aAtividades[oLbx:nAt,3],;
										aAtividades[oLbx:nAt,4],;
										aAtividades[oLbx:nAt,5],;
										aAtividades[oLbx:nAt,6],;
										Tk380RetRot(aAtividades[oLbx:nAt,7])}}
        	oLbx:bChange := {||	Tk380PDetalhes(@aDet_Panel,aAtividades[oLbx:nAt],@oPDetalhes)	,;	// Atualiza o painel de detalhes
								Tk380PPendencia(@aPend_Panel,aAtividades[oLbx:nAt],@oPPendencia),;	// Atualiza o painel de pendencias
								Tk380AtuSaudacao(oU6Status,oUOMeta,aAtividades[oLbx:nAt])} 			// Atualiza os dados do cabecalho.
			
			oLbx:Refresh()
			oLbx:SetFocus(.T.)
	 		
	@00,00 MSPANEL oPanel2

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿛aineis de detalhes.                           �
	//쿛ainel 1 - Detalhes da Lista - SU4             �
	//쿛ainel 2 - Detalhes de lista de Pendencia - SU4�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	
	//Painel 1
	@ 01,01 TO 70,(nCol/2)-6 LABEL STR0026 OF oPanel2 PIXEL  //'Detalhes da Lista'
	@ 08,03 MSPANEL oPDetalhes  VAR "" OF oPanel2 SIZE (nCol/2)-12,49
	
	@ 0,0 SCROLLBOX oScrDet OF oPDetalhes PIXEL 
	oScrDet:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 00, 00 SAY aDet_Panel[01,02] PROMPT aDet_Panel[01,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 
	@ 10, 00 SAY aDet_Panel[02,02] PROMPT aDet_Panel[02,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 20, 00 SAY aDet_Panel[03,02] PROMPT aDet_Panel[03,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 30, 00 SAY aDet_Panel[04,02] PROMPT aDet_Panel[04,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 40, 00 SAY aDet_Panel[05,02] PROMPT aDet_Panel[05,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 50, 00 SAY aDet_Panel[06,02] PROMPT aDet_Panel[06,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 60, 00 SAY aDet_Panel[07,02] PROMPT aDet_Panel[07,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 70, 00 SAY aDet_Panel[08,02] PROMPT aDet_Panel[08,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 80, 00 SAY aDet_Panel[09,02] PROMPT aDet_Panel[09,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 90, 00 SAY aDet_Panel[10,02] PROMPT aDet_Panel[10,01] OF oScrDet FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
 
	
	//Painel 2
	@ 01,(nCol/2)-3 TO 70,nCol-3 LABEL STR0027 OF oPanel2 PIXEL  //'Detalhes da lista de contato Pendente'
	@ 08,(nCol/2) MSPANEL oPPendencia VAR "" OF oPanel2 SIZE (nCol/2)-6,49

	@ 0,0 SCROLLBOX oScrPend OF oPPendencia PIXEL 
	oScrPend:Align := CONTROL_ALIGN_ALLCLIENT

	@ 00, 00 SAY aPend_Panel[01,02] PROMPT aPend_Panel[01,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10 
	@ 10, 00 SAY aPend_Panel[02,02] PROMPT aPend_Panel[02,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 20, 00 SAY aPend_Panel[03,02] PROMPT aPend_Panel[03,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 30, 00 SAY aPend_Panel[04,02] PROMPT aPend_Panel[04,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10
	@ 40, 00 SAY aPend_Panel[05,02] PROMPT aPend_Panel[05,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	
	@ 50, 00 SAY aPend_Panel[06,02] PROMPT aPend_Panel[06,01] OF oScrPend FONT oFont2 PIXEL COLOR CLR_BLUE SIZE 300,10	

	@00,00 MSPANEL oPanel3

    //Legendas
	@ 01,01 TO 17,nCol-70 LABEL STR0028 OF oPanel3 PIXEL  //'Legendas'
	
	@ 08,03 BITMAP oBmpV ResName "BR_VERMELHO" OF oPanel3 Size 10,10 NoBorder When .F. Pixel 
	@ 08,15 SAY STR0029 OF oPanel3 Color CLR_RED,CLR_WHITE PIXEL   //"Listas n�o executadas."

	@ 08,80 BITMAP oBmpA ResName "BR_AZUL" OF oPanel3 Size 10,10 NoBorder When .F. Pixel
	@ 08,90 SAY STR0030 OF oPanel3 Color CLR_BLUE,CLR_WHITE PIXEL  	 //"Listas em andamento."

	@ 08,147 BITMAP oBmpVM ResName "BR_VERDE" OF oPanel3 Size 10,10 NoBorder When .F. Pixel
	@ 08,159 SAY STR0104 OF oPanel3 Color CLR_GREEN,CLR_WHITE PIXEL  	 //"Atividade encerrada"


	// Botoes da para execucao das tarefas.
	DEFINE SBUTTON FROM 05,nCol-65 TYPE 1  ;
							ACTION 	(IIF(	!Empty(aAtividades[oLbx:nAt,2]) .AND. Tk380Valido(aAtividades,oLbx:nAt,oCalend2:dDiaAtu),;
											(Tk380ExecLista(aAtividades[oLbx:nAt]),;
											aAtividades := Tk380CarregaSU4(oCalend2:dDiaAtu),;
											ASORT(aAtividades,,,{|x,y| DToS(x[3])+x[4] < DToS(y[3])+y[4]}),;
											oLbx:SetArray(aAtividades),;
											oLbx:bLine:={||{Tk380Leg(	aAtividades[oLbx:nAt,2]),;
																		aAtividades[oLbx:nAt,3],;
																		aAtividades[oLbx:nAt,4],;
																		aAtividades[oLbx:nAt,5],;
																		aAtividades[oLbx:nAt,6],;
																		Tk380RetRot(aAtividades[oLbx:nAt,7])}},;
											Tk380PDetalhes(@aDet_Panel,aAtividades[oLbx:nAt],@oPDetalhes)	,;	  // Atualiza o painel de detalhes
											Tk380PPendencia(@aPend_Panel,aAtividades[oLbx:nAt],@oPPendencia),;  // Atualiza o painel de pendencias
											Tk380AtuSaudacao(oU6Status,oUOMeta,aAtividades[oLbx:nAt]),; 		// Atualiza os dados do cabecalho.
											oLbx:Refresh(),;
											oDlgAgenda:Refresh()),; 
											)) ;
							ENABLE OF oPanel3 PIXEL
											//MsgInfo(STR0105))) ;//"Nao existem listas ou esta lista n�o pode ser executada. Selecione uma lista valida."
											
	DEFINE SBUTTON FROM 05,nCol-35 TYPE 2 ACTION (TkGrvSUV(__cUserId, ""),oDlgAgenda:End()) ENABLE OF oPanel3 PIXEL

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿌tualiza o status da tabela de atendentes IN/OUT para o Monitor�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	TkGrvSUV(__cUserId, "AGE0")

	FATPDLogUser('TMKA380')	// Log de Acesso LGPD
ACTIVATE MSDIALOG oDlgAgenda ON INIT (	AlignObject(oDlgAgenda,{oPanel1,oScr1,oLbx,oPanel2,oPanel3},1,3,{48,155,,115,36}),;
										Processa({|lEnd|Tk380ChgMes(dDataBase,oCalend1,oCalend2,oCalend3)},STR0032,,.T.) ) //"Selecionando Itens da Lista..."
										
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿔nforma ao gerenciador de m�ltiplos grupos de atendimento �
//쿿ue a rotina agenda do operador n�o est� mais em execu豫o.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
TK091End( AGENDAOPERADOR )

//Finaliza o gerenciamento dos campos com prote豫o de dados.
FATPDUnLoad() 

Return .T.

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴敲굇
굇튔uncao    쿟k380AtuCalend튍utor  쿝afael M. Quadrotti � Data �23/12/03 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴묽�
굇튒esc.     � Criacao das marcacoes das tarefas no calendario.           볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpD1: Data de referencia.                                  볍�
굇�          쿐xpO1: Objeto do calendario.                                볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8                                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴錮袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튝arcelo K.�06/06/02�710   �-Revisao do fonte                           볍�
굇�          �        �      �                                            볍�
굇�          �        �      �                                            볍�
굇훤袴袴袴袴賈袴袴袴袴鳩袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function Tk380AtuCalend(dData,oCalend)

Local dAux1 		:= FirstDay(dData)				// Variavel auxiliar para controle de data.
Local dAux2 		:= LastDay(dData)				// Variavel auxiliar para controle de data.
Local nCont 		:= 0 							// Variavel contador.
Local lMV_TMKPHJ	:= GetNewPar("MV_TMKPHJ",.T.)	// Indica se as pendencias encerradas na database serao exibidas no painel de pendencias agendadas - Default EXIBE

ProcRegua(dAux2-dAux1)
	
DbSelectArea("SU4")
DbSetOrder(3) 			// FILIAL + DATA + STATUS    
MsSeek(xFilial("SU4")+DTOS(dAux1) ,.T.) 

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e existirem listas encerradas e o parametro que indica a exibicao das listas encerradas      �
//쿮stiver .T. elas serao exibidas. Caso contrario (.F.) exibe somente as pendencias em aberto   �
//쿪 serem executadas ate hoje. ESSA VALIDACAO ESTA SENDO FEITO PORQUE O WHILE E PARA CODEBASE   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

While 	!EOF() 								.AND. ;
		(xFilial("SU4") == SU4->U4_FILIAL) 	.AND.;
		(SU4->U4_DATA <= dAux2)  .AND. IIF(!lMV_TMKPHJ, SU4->U4_STATUS <> '2',.T.)

    nCont ++
	IncProc( STR0033 + StrZero(nCont,5) ) // "Tarefas do dia "

	oCalend:AddRestri(Day(SU4->U4_DATA),CLR_HRED,CLR_WHITE)
	
	SU4->(DbSkip())
End                           

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎aso a  data recebida for a data base do sistema, ou seja,       �
//쿮h o objeto do calend�rio atual  efetua a marcacao no calendario.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If dData == dDataBase
	oCalend:addRestri(Day(dDataBase),CLR_BLUE,CLR_BLUE)	
Endif 	
	
oCalend:Refresh()
		
Return(.T.)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿟k380ChgMe� Autor 쿝afael M. Quadrotti    � Data � 24/12/03 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Atualiza o calendario. Sabados e Domingos.                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpD1: Data de referencia.                                 낢�
굇�          � ExpO1: Objeto do Calendario1                               낢�
굇�          � ExpO2: Objeto do Calendario2                               낢�
굇�          � ExpO3: Objeto do Calendario3                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so       � Call Center V.811 Agenda do operador.                      낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function Tk380ChgMes(dDtFoco,oCalend1,oCalend2,oCalend3)

Local aArea    := GetArea()						// Salva a area de trabalho.
Local dDataIni := FirstDay(oCalend2:dDiaAtu)	// Retorna o primeiro dia do mes.
Local dDataFim := LastDay(oCalend2:dDiaAtu)		// Retorna o ultimo dia do mes.

CursorWait()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿟ratamento para apresenta豫o dos fins de semana em cinza.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
While ( dDataIni <= dDataFim )
	While ( Dow(dDataIni) == 1 .OR. Dow(dDataIni) == 7 )
		oCalend2:addRestri(Day(dDataIni),CLR_GRAY,CLR_WHITE)
		dDataIni++
	End
	dDataIni++
End
oCalend2:Refresh()                    

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿌tualizada as tarefas da agenda.�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
// Calendario Principal
Tk380AtuCalend(dDtFoco,@oCalend2)

// Atualiza Calendario de tarefas do mes posterior
Tk380AtuCalend(LastDay(dDtFoco)+1,@oCalend3)

// Atualiza Calendario de tarefas do mes anterior
Tk380AtuCalend(FirstDay(dDtFoco)-1,@oCalend1)

RestArea(aArea)

CursorArrow()

Return(.T.)


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴藁袴袴袴袴袴袴袴袴袴袴箇袴袴藁袴袴袴袴袴袴敲굇
굇튔uncao    쿟k380Valido튍utor 튣afael M. Quadrotti � Data �  01/20/04   볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴姦袴袴袴袴袴袴袴袴袴菰袴袴袴姦袴袴袴袴袴袴묽�
굇튒esc.     쿣erifica se a lista ja foi encerrada e nao permite sua      볍�
굇�          퀆isualizacao.                                               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpA: Vetor com todas as atividades da Agenda.              볍�
굇�          쿐xpN: Posicao do foco na tarefa.                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8 Agenda do Operador                                     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴錮袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튝arcelo K �27/07/04�811   �-Notacao e Logica                           볍�
굇�          �        �      �                                            볍�
굇�          �        �      �                                            볍�
굇훤袴袴袴袴賈袴袴袴袴鳩袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function Tk380Valido(aAtividades,nP,dData)

Local lRet 		:= .F.										// Retorno da funcao.
Local cAgPrior  := TkPosto(TkOperador(),"U0_AGPRIOR")		// Prioridade de execucao da agenda.
Local aItemSel	:= aAtividades[nP]  						// Array com as listas de Contato
Local nCont		:= 0										// Contatodor
Local nLenAtiv  := Len(aAtividades)							// Contador com o total de listas
Local dDataLim  := dDataBase
Local lTK380BOK := ExistBlock("TK380BOK")

If aItemSel[2] <> "2" // Encerrada

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿣erifica se a data desta lista e posterior e emite um aviso.                                     �
	//쿗istas com datas posteriores nao poderao ser executadas. Somente visualizadas.                   �
	//쿙a execucao da segunda janela havera uma validacao que bloqueara o acesso aos dados desta lista  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴��
	//쿛E para determinar data limite de execucao de listas�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�컴컴컴�
	If ExistBlock("TK380DAT") 
		dDataLim := Execblock("TK380DAT",.F.,.F.,{dData})	
		If dData > dDataLim
			MsgStop(STR0106, STR0107)      //"Listas com datas futuras nao podem ser executadas antes","Data inv�lida"
			Return(lRet)
		Endif
	Else
		If dData > dDataBase
			MsgStop(STR0106, STR0107)      //"Listas com datas futuras nao podem ser executadas antes","Data inv�lida"
			Return(lRet)
		Endif
	Endif
	
	If aItemSel[7] == "3"	//TeleCobranca
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿣erifica qual o tipo de regra de selecao foi aplicada: Por Lista ou por Grupo�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		DbSelectarea("SK0")
		DbSetOrder(1)
		MsSeek(xFilial("SK0"))
		If SK0->K0_ORDEM == "000001" .AND. SK0->K0_PRAZO == "999999"
			DbSelectArea("SU4")
			lRet := .T.
		Else
			MsgStop(STR0034,STR0082) //"A regra de sele豫o n�o permite a execu豫o de Listas de Cobran�a pela Agenda do Operador","Atencao"
		Endif
	Else
		lRet:= .T.
	Endif
Else
	Help(" ",1,"TMK380NACE")	//"Esta Lista ja foi encerrada e nao podera ser visualizada por esta rotina"
Endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿞e a lista pode ser executada avalia qual a prioridade do grupo de atendimento do Operador�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If lRet
	If !Empty(cAgPrior)
		Do Case
			Case cAgPrior == "1" //Lista de contatos pendente

				If Val(aItemSel[9]) <> PENDENCIA
					For nCont := 1 To nLenAtiv
						If Val(aAtividades[	nCont][9]) = PENDENCIA .AND. aAtividades[nCont][2] <> "2" //Encerrada
							If TkHoraComp(Time(), aAtividades[	nCont][4], ">=","")
								lRet := .F.
								Help("  ",1,"TK380PRIO1")//"De acordo com a defini豫o do grupo de atendimento as listas de pend�ncia devem ser executadas antes das outras atividades."
								Exit
							Endif
						Endif
					Next nCont
				Endif

			Case cAgPrior == "2" //Lista de contatos padrao

				If Val(aItemSel[9]) == PENDENCIA
					If TkHoraComp(Time(), aItemSel[4], "<","")
						For nCont := 1 To nLenAtiv
							If Val(aAtividades[	nCont][9]) <> PENDENCIA .AND. aAtividades[nCont][2] <> "2" //Encerrada
								lRet := .F.
								Help("  ",1,"TK380PRIO2")//"De acordo com a defini豫o do grupo de atendimento as listas de contato padr�o devem ser executadas antes das outras atividades."
								Exit
							Endif
						Next nCont
					Endif
				Endif

			Case cAgPrior == "3" //Lista de contatos por data.

				For nCont := 1 To nLenAtiv
					If aAtividades[	nCont][3] < aItemSel[3] .AND. aAtividades[nCont][2] <> "2" //Encerrada
						lRet := .F.
						Help("  ",1,"TK380PRIO3")//"De acordo com a defini豫o do grupo de atendimento a ordem de execu豫o das listas de contatos devem seguir a data."
						Exit
					Endif
				Next nCont
		EndCase
	
	Endif
Endif

If lRet .And. lTK380BOK
	lRet := ExecBlock("TK380BOK",.F.,.F.,{aAtividades,nP,dData})
EndIf

Return(lRet)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴藁袴袴袴袴袴袴袴袴袴袴箇袴袴藁袴袴袴袴袴袴敲굇
굇튔uncao    쿌justaHelp 튍utor 튏onrado Q. Gomes    � Data �  03/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴姦袴袴袴袴袴袴袴袴袴菰袴袴袴姦袴袴袴袴袴袴묽�
굇튒esc.     쿌juste de mensagem de ajuda.                                볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿙enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP8 Agenda do Operador                                     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴錮袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                         볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇�          �        �      �                                            볍�
굇�          �        �      �                                            볍�
굇훤袴袴袴袴賈袴袴袴袴鳩袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function AjustaHelp()
Local aHlpP	:= {}		// Texto em portugu�s
Local aHlpE	:= {}		// Texto em ingl�s
Local aHlpS   := {}		// Texto em castelhano

aAdd (aHlpP, STR0108)	// "N�o existe Midia para esta campanha."
aAdd (aHlpE, STR0108)	// "N�o existe Midia para esta campanha."
aAdd (aHlpS, STR0108)	// "N�o existe Midia para esta campanha."	
PutHelp("PSEMMIDIA ", aHlpP, aHlpE, aHlpS, .T.)
	
aHelpP	:= {}
aHelpE	:= {}
aHelpS	:= {}

Aadd(aHelpP,"Verifique se todos os campos necess�rios " )
Aadd(aHelpP,"est�o preenchidos corretamente." )
PutHelp("SSEMDADOS",aHelpP,aHelpE,aHelpS,.T.)

Return Nil




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
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun豫o deve utilizada somente ap�s 
    a inicializa豫o das variaveis atravez da fun豫o FATPDLoad.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

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
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUserAcc
    @description
    Verifica se o usuario logado possui acesso a dados sensiveis e pessoais
    Exibindo mensagem de Help caso usuario n�o possua acesso.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDUserAcc()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Retorna se Usuario possui acesso a dados protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDUserAcc()

    Local lRet := .T.  

    If FATPDActive()
        lRet := FTPDUserAcc()
    Endif

Return lRet

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


