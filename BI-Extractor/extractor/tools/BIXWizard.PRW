#INCLUDE "PROTHEUS.CH"
#INCLUDE "BIXWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "APWIZARD.CH" 
#INCLUDE "BIXEXTRACTOR.CH"

#define TCPIP       "TCPIP"
#define STRTCPIP    "TCP/IP"
#define NPIPE       "NPIPE"
#define STRNPIPE    "Named PipeS"
#define MSSQL       "MSSQL"
#define STRMSSQL    "Microsoft SQL"
#define DB2         "DB2"
#define STRDB2      "IBM DB2"
#define ORACLE      "ORACLE"
#define STRORACLE   "Oracle"
#define INFORMIX    "INFORMIX"
#define STRINFORMIX "Informix"
#define POSTGRES		"POSTGRES"
#define STRPOSTGRES	"Postgres"

#define AREA_WITHOUT "0"
#define AREA_COM     "1" 
#define AREA_CONTROL "2"                      	
#define AREA_FIN     "3" 
#define AREA_MAT     "4" 
#define AREA_PROD    "5" 
#define AREA_RH      "6" 
#define AREA_DL      "8"
#define AREA_SERVICO "9" 
#define AREA_VAREJO  "10"
#define AREA_CRM     "11"
#define AREA_SAUDE   "12"

#define CONNSTAGE      1
#define SELAREA        1
#define GENERICO       4 
#define PARAMCOMERCIAL 1
#define PARAMCOMFINMAT 1			//Parâmetros da área comercial, finanças e materiais
#define PARAMCONTROL   2
#define PARAMMAT       1
#define PARAMRH        4
#define PARAMDL        1
#define PARAMVAREJO    1  
#define PARAMCRM       1
#define PARAMPROD      1

#define AREACOMFINMAT "30"

Static cTaCombo := "" 	// Necessário para a tela de criação de grupos de saldos.
Static cMRCombo := "" 	// Necessário para a tela de criação de macro região.
Static aArea    := BIXListArea() // Vetor com as áreas que podem ser selecionadas para a extração   

//-------------------------------------------------------------------
/*/{Protheus.doc} cfgBIXC8
Assistente de configuração de parâmetros para os extratores de dados do Microsiga Protheus
para serem utilizados pelo Cognos

@author  BI TEAM
@version P11
@since   12/07/2010
/*/
//-------------------------------------------------------------------  
function cfgBIXC8()
	Local oWizard 	:= NIL 
	Private aPath	:= {} 

   	DEFINE WIZARD oWizard TITLE STR0012 HEADER STR0013 TEXT STR0014 + CRLF + STR0015 + CRLF + STR0016 PANEL	//"Configurador Extratores Business Intelligence"###"Extrator de dados Microsiga Protheus"###"Bem vindo ao assistente de configuração dos parâmetros necessários à extração"###"de dados do Microsiga Protheus para posterior utlização destas informações no Cognos."###"Clique em Avançar para prosseguir para a tela de parâmetros."
		//-------------------------------------------------------------------
		// Parâmetros de conexão. 
		//------------------------------------------------------------------- 
		WzdConn( @oWizard )
		//-------------------------------------------------------------------
		// Áreas. 
		//------------------------------------------------------------------- 
		WzdSelArea( @oWizard )
		//-------------------------------------------------------------------
		// Moedas. 
		//------------------------------------------------------------------- 
		wzdGenerico( @oWizard )  
		//-------------------------------------------------------------------
		// Comercial. 
		//-------------------------------------------------------------------                      
		WzdComercial( @oWizard )
		//-------------------------------------------------------------------
		// Comercial \ Financeiro \ Materiais                         
		//-------------------------------------------------------------------
		WzdComFinMat( @oWizard )
		//-------------------------------------------------------------------
		// Controladoria. 
		//-------------------------------------------------------------------  
		WzdControl( @oWizard )		
		//-------------------------------------------------------------------
		// Materiais.
		//-------------------------------------------------------------------  
		WzdMat( @oWizard )
		//-------------------------------------------------------------------
		// Produção.
		//-------------------------------------------------------------------  
		WzdProd( @oWizard )
		//-------------------------------------------------------------------
		// RH. 
		//-------------------------------------------------------------------  
		WzdRH( @oWizard )
		//-------------------------------------------------------------------
		// DL. 
		//-------------------------------------------------------------------  
		WzdDL( @oWizard )  
		//-------------------------------------------------------------------
		// Varejo. 
		//-------------------------------------------------------------------  
		WzdVarejo( @oWizard )  
		//-------------------------------------------------------------------
		// CRM. 
		//-------------------------------------------------------------------  
		WzdCRM( @oWizard )  						
		
		//-------------------------------------------------------------------
		// Não permite o usuário sair do Wizard pelo ESC. 
		//-------------------------------------------------------------------  	
   		//oWizard:oDlg:lEscClose := .F.   //TODO - Voltar. 
	ACTIVATE WIZARD oWizard CENTERED   
	
	//-------------------------------------------------------------------
	// Exclui todas classes de interface da thread. 
	//-------------------------------------------------------------------  	
	DelClassIntf() 
Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} WzdConn
Painel para configuração dos parâmetros de conexão com a Stage.
@param oWizard		Objeto onde os componentes serão criados

@author  BI TEAM
@version P11
@since   12/07/2010
/*/
//---------------------------------------------------------------------------------
Static Function WzdConn( oWizard )	
	Local oPanel 		:= NIL 
	Local oSocket 	:= tSocketClient():New()
	Local nConn 		:= -1
	Local nResp 		:= 0
		
	Local cBIXTCON 	:= AllTrim( BIXLinkProperty(,"CONNECTION") )
	Local cBIXDB	:= AllTrim( BIXLinkProperty(,"DATABASE") )
	Local cBIXSRVR	:= Padr( BIXLinkProperty(,"SERVER"), 40 )
	Local cBIXPORT	:= Padr( BIXLinkProperty(,"PORT")	, 05 )
	Local cBIXALIA	:= Padr( BIXLinkProperty(,"ALIAS")	, 40 )
	
	Local aLastConn	:= {}
	Local lChangeConn := .F.
	
	//-----------------------------------------------------------------------------
	// Verifica se a conexão está válida, caso contrário os parâmetros são zerados.
	//-----------------------------------------------------------------------------	
	nResp := oSocket:Connect( nBIVal(cBIXPORT), AllTrim(cBIXSRVR), 1000 )

	If oSocket:isConnected()
		oSocket:closeConnection()
	EndIf

	If ( nResp == 0 )
		nConn := TCLINK( "@!!@" + AllTrim(cBIXDB) + "/" + AllTrim(cBIXALIA), AllTrim(cBIXSRVR), nBIVal(cBIXPORT) )
	
		If ( nConn < 0 )	
			cBIXTCON 	:= "TCPIP"
			cBIXDB		:= "MSSQL"
			cBIXSRVR	:= Space( 40 )
			cBIXPORT	:= Space( 05 )
			cBIXALIA	:= Space( 20 )
			
			//-------------------------------------------------------------------
			// Grava as propriedades da Fluig Smart Data. 
			//-------------------------------------------------------------------	
			SaveConn( cBIXTCON, cBIXDB, cBIXSRVR, cBIXPORT, cBIXALIA )
		Else
			//-------------------------------------------------------------------
			// Armazena a última conexão configurada para instruir o usuário 
			// que deve rever os parâmetros do Wizard. 
			//-------------------------------------------------------------------	
			Aadd( aLastConn, {cBIXTCON, cBIXDB, cBIXSRVR, cBIXPORT, cBIXALIA })
			TCUnlink( nConn ) //Fecha a conexão com a Stage		
		EndIf
	EndIf
	 
	//-------------------------------------------------------------------
	// Define a descrição do tipo de conexão. 
	//------------------------------------------------------------------- 			
	If cBIXTCON == TCPIP
		cBIXTCON := STRTCPIP
	ElseIf cBIXTCON == NPIPE
		cBIXTCON := STRNPIPE
	EndIf 
	
	//-------------------------------------------------------------------
	// Define a descrição do Banco de Dados. 
	//------------------------------------------------------------------- 
	If cBIXDB == MSSQL
		cBIXDB := STRMSSQL
	ElseIf cBIXDB == DB2
		cBIXDB := STRDB2
	ElseIf cBIXDB == ORACLE
		cBIXDB := STRORACLE
	ElseIf cBIXDB == INFORMIX
		cBIXDB := STRINFORMIX
	ElseIf cBIXDB == POSTGRES
		cBIXDB := STRPOSTGRES
	EndIf

	//-------------------------------------------------------------------
	// Panel 2 - Tela de parâmetros de conexão. 
	//------------------------------------------------------------------- 
	CREATE PANEL oWizard;
		HEADER STR0127;  	//"Configurações de acesso a Fluig Smart Data"
		MESSAGE STR0018;	//"Informe os parâmetros para conexão com a Fluig Smart Data." 
		BACK {|| .T. };
		NEXT {|| Iif( ValidServer( cBIXTCon, cBIXDB, cBIXSRVR, cBIXPORT, cBIXALIA, aLastConn, @lChangeConn ), (ShowNextParam( oWizard, "DEFAULT" ), .T.), (iIF( lChangeConn, oWizard:SetFinish(), ), .F. )) } PANEL               
		
		oPanel := oWizard:GetPanel(oWizard:nTPanel)

		@ 020, 005 SAY STR0003 OF oPanel SIZE 150, 008 PIXEL //"Tipo de Conexão ao DBAccess"
		@ 028, 005 MsCombobox cBIXTCON ITEMS { STRTCPIP, STRNPIPE } SIZE 120, 9 OF oPanel PIXEL

		@ 040, 005 SAY STR0005 OF oPanel SIZE 150, 008 PIXEL //"Tipo do Banco de Dados"
		@ 048, 005 MsCombobox cBIXDB ITEMS { STRMSSQL, STRDB2, STRORACLE, STRINFORMIX, STRPOSTGRES } SIZE 120, 9 OF oPanel PIXEL

		@ 060, 005 SAY STR0009 OF oPanel SIZE 150, 008 PIXEL //"Servidor DBAccess"
		@ 068, 005 MsGet cBIXSRVR OF oPanel SIZE 180, 9 PIXEL

		@ 080, 005 SAY STR0011 OF oPanel SIZE 150, 008 PIXEL //"Porta do Servidor DBAccess"
		@ 088, 005 MsGet cBIXPORT OF oPanel SIZE 50, 009 PIXEL VALID isNumeric(cBIXPORT)

		@ 100, 005 SAY STR0007 OF oPanel SIZE 150, 008 PIXEL //"Alias no DBAcess"
		@ 108, 005 MsGet cBIXALIA OF oPanel SIZE 120, 009 PIXEL
		
	BIXParUpdFato()		
Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} WzdSelArea
Painel para configuração das áreas para extração
@param oWizard		Objeto onde os componentes serão criados

@author  BI TEAM
@version P11
@since   12/07/2010
/*/
//---------------------------------------------------------------------------------
Static Function WzdSelArea( oWizard )
	Local oPanel 	:= Nil
	Local oList		:= Nil
	Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
	Local oOk 		:= LoadBitmap( GetResources(), "LBTIK" )

	//-------------------------------------------------------------------
	// Guarda o histórico de navegação entre os painéis.
	//-------------------------------------------------------------------        
	aPath := {} 

	//-------------------------------------------------------------------
	// Panel 3 - Seleção das áreas para execução do extrator . 
	//------------------------------------------------------------------- 
	CREATE PANEL oWizard;
		HEADER STR0135; 		//"Definição das áreas para extraçao"
		MESSAGE STR0136;	//"Selecione as áreas utilizadas na configuração dos extratores Protheus."
		BACK {|| .T. }; 
		NEXT {|| Iif( validArea(), (SaveSelArea(), .T.), ( ApMsgAlert(STR0137), .F.)) } EXEC {|| LoadArea(), oList:Refresh()}  PANEL	//"É necessário selecionar ao menos uma área para prosseguir com o processo de configuração."
		oPanel := oWizard:GetPanel(oWizard:nTPanel)
		
		@ 010, 010 LISTBOX oList;
		 	FIELDS HEADER "", STR0027, STR0138; //"Código"###"Descrição da Área" 
		 	SIZE 280, 125 OF oPanel PIXEL; 
		 	ON DBLCLICK (aArea[oList:nAt, 1] := !aArea[oList:nAt, 1], oList:Refresh(.f.)) 
			
			oList:SetArray(aArea)
			oList:bLine := {|| {If(aArea[oList:nAt, 1], oOK, oNO), aArea[oList:nAt, 2], aArea[oList:nAt, 3]}}
		    oList:bHeaderClick := { |a, b| iif(b == 1 , MarkAllList(aArea, b),), oList:Refresh()}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} wzdGenerico
Painel para configuração de moedas
@param oWizard		Objeto onde os componentes serão criados

@protected
@author  BI TEAM
@version P11
@since   11/04/2011
/*/
//-------------------------------------------------------------------
Static Function wzdGenerico( oWizard )
	local oSelMoeda	:= Nil
	Local oPanel	:= Nil
	Local oCompEmp	:= Nil
  	Local oFamCom	:= Nil
  	Local oUniMed  	:= Nil
 	Local oTcMoeda	:= Nil
	Local oCliReg	:= Nil
	local oMarcado	:= LoadBitmap( GetResources(), "LBOK" )
	local oDesmarc	:= LoadBitmap( GetResources(), "LBNO" )
	local aMoedas	:= BIXLoadMoeda()
	Local aRowsFato	:= LoadFtMoeda() 
    Local aCMoeda   := LoadACMoeda()  
    Local aVldReg	:= {}  
	local nCount  	:= 0
	Local lCMoeda   := LoadCMoeda()  
	Local lCliReg	:= BIXParInfo( 'BIX_CLIREG', "L", .F. ) // Dados do cliente na dimensão região geográfica
	Local lCompEmp	:= BIXParInfo( 'BIX_CMPEMP', "L", .F. ) //"Considerar o compartilhamento de tabelas entre empresas?"

	//-------------------------------------------------------------------
	// Panel 4 - Configuração de parâmetros Genéricos - Definição das moedas x fato. 
	//------------------------------------------------------------------- 
	CREATE PANEL oWizard ;
		HEADER STR0139;					//"Configuração de parâmetros Genéricos"
		MESSAGE STR0076 + CRLF; 		//"Selecione as Moedas utilizadas nas fatos. "
		BACK {|| .T. } ;
		NEXT {|| Iif(validFtMoeda(aRowsFato), ( SaveMoedas(aRowsFato),.T. ), .F.) };
		FINISH {|| Iif(validFtMoeda(aRowsFato), ( SaveMoedas(aRowsFato),.T. ), .F.) };
		EXEC {|| aRowsFato := loadFtMoeda(), oSelMoeda:SetArray( aRowsFato )};
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)
		oSelMoeda := TCBrowse():New( 10, 10, 285, 125,,,, oPanel,,,,,,,,,,,,,, .T.)
		oSelMoeda:AddColumn( TCColumn():New( STR0070, {|| aRowsFato[oSelMoeda:nAt, 1]},,,, "LEFT", 025, .F., .F.,,,,,) )//"Tabela"
		oSelMoeda:AddColumn( TCColumn():New( STR0071, {|| aRowsFato[oSelMoeda:nAt, 2]},,,, "LEFT", 080, .F., .F.,,,,,) )//"Descrição"

		//-------------------------------------------------------------------
		// Adiciona as moedas. 
		//------------------------------------------------------------------- 
		For nCount := 1 To Len(aMoedas)
			oSelMoeda:AddColumn(TcColumn():New(aMoedas[nCount, 2], &("{ |x, y| If(aRowsFato[oSelMoeda:nAt," + str(nCount + 2) + "], oMarcado, oDesmarc) }"), "@c", nil, nil, "CENTER", 030, .T., .T., nil, nil, nil, .T., nil))
		Next nCount

		//-------------------------------------------------------------------
		// Adiciona as fatos. 
		//------------------------------------------------------------------- 
		oSelMoeda:SetArray( aRowsFato )
		oSelMoeda:bLDblClick   := { |x, y| iif(y > 2, aRowsFato[oSelMoeda:nAt, y] := ! aRowsFato[oSelMoeda:nAt, y],)}
		oSelMoeda:bHeaderClick := { |a, b| iif(b > 2, MarkAllList(aRowsFato, b),), oSelMoeda:Refresh()}  
		
	//-------------------------------------------------------------------
	// Panel 5 - Configuração de macroregião. 
	//-------------------------------------------------------------------
	CREATE PANEL oWizard ;
		HEADER STR0139;					//"Configuração de parâmetros Genéricos"
		MESSAGE STR0168;		//"Configuração da Macro Região"
		BACK {||  .T.  } ;
		NEXT {|| vldNewGrp(@aVldReg, 2) } ;
		PANEL

	  	oPanel := oWizard:GetPanel(oWizard:nTPanel)
	  	wzdMacroReg(oPanel, @aVldReg )   
  	
	//-------------------------------------------------------------------
	// Panel 6 - Configuração de Consolidação de Moeda. 
	//-------------------------------------------------------------------  	
  	CREATE PANEL oWizard ;
		HEADER STR0139;			//"Configuração de parâmetros Genéricos"
    	MESSAGE STR0164+CRLF+;	//"Consolidação de Moedas"
             STR0165+CRLF;		//"Ao habilitar a opção de consolidação, será necessário informar pelo menos um código de moeda."
  		BACK {|| .T.  } ;
		NEXT {|| wzVldCMoeda( lCMoeda, oTcMoeda, aCMoeda ) };   
		PANEL

	  	oPanel := oWizard:GetPanel( oWizard:nTPanel )
	  	WzConsMoeda( oPanel, @aCMoeda, @lCMoeda, @oTcMoeda ) 
	
	//-------------------------------------------------------------------
	// Panel 7 - Configuração de parâmetros genéricos 
	//-------------------------------------------------------------------  
	CREATE PANEL oWizard ;
		HEADER STR0139;						//"Configuração de parâmetros Genéricos"
  		MESSAGE STR0147 + CRLF + STR0148; 	//"Caso seja necessário, configure o(s) parâmetro(s) abaixo para adequar a execução dos "###"extratores conforme a regra de negócio adotada."
  		BACK {||  .T. } ;
		NEXT {|| ( ShowNextParam( oWizard ), PersGenerico( lCliReg, lCompEmp) ), .T. };
		FINISH {|| ( PersGenerico( lCliReg, lCompEmp), BIXCloseFSD() ), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL

	  	oPanel := oWizard:GetPanel(oWizard:nTPanel)
	  	
	  	@ 025, 010 CHECKBOX oCliReg 	VAR lCliReg PROMPT STR0263 OF oPanel SIZE 400, 020 PIXEL //"Indica se os dados do cliente serão considerados na dimensão região geográfica."
	  	
	  	//---------------------------------------------------------------
	  	//"Considerar o compartilhamento de tabelas entre empresas?"
	  	//	Alerta:
	  	//	"Esta opção é responsável por mudar o padrão da chave de relacionamento entre fato e dimensão."
	  	//	"Alterá-la pode resultar em um comportamento indesejado ao agrupar informações com padrões de chaves diferentes."                                                                                                                                                                                                                                                                                                                                                                                                   
	  	//	"Neste caso, refaça as extrações de períodos anteriores."
	  	//--------------------------------------------------------------- 	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	  	@ 035, 010 CHECKBOX oCompEmp 	VAR lCompEmp PROMPT STR0268 OF oPanel SIZE 400, 020 PIXEL ON CHANGE (ApMsgAlert(STR0270 + CRLF + CRLF + STR0271, STR0269))
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} WzdComercial
Painel para configuração dos parâmetros da área comercial
@param oWizard		Objeto onde os componentes serão criados

@author  Valdiney V GOMES
@version P11
@since   25/06/2014
/*/
//-------------------------------------------------------------------
 Static Function WzdComercial( oWizard )
	Local oPanel	 	:= NIL 
	Local oBrowse 	:= NIL  
	Local aPeriod	:= LoadComercial()
	
	//-------------------------------------------------------------------
	// Panel 8 - Configuração de parâmetros da área comercial. 
	//------------------------------------------------------------------- 
	CREATE PANEL oWizard ;
		HEADER STR0222; //"Configuração de Parâmetros da Área Comercial";				
		MESSAGE CRLF + STR0223; //"Área Comercial" ;	
		BACK {|| ( ShowBackParam( oWizard, AREA_COM ) ), .T. } ;
		NEXT {|| ( SaveComercial( aPeriod ), ShowNextParam( oWizard, AREA_COM) ), .T. };
		FINISH {|| ( SaveComercial( aPeriod, BIXCloseFSD() ) ), .T. } ;
		EXEC {|| ShowFinish( @oWizard ) };
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)   
		
		Comercial( oPanel, aPeriod )  
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} WzdComFinMat
Painel para configuração dos parâmetros genéricos da área comercial, finanças e materiais.
@param oWizard		Objeto onde os componentes serão criados

@author  Marcia Junko
@version P11
@since   10/07/2014
/*/
//-------------------------------------------------------------------
Static Function WzdComFinMat( oWizard )
	Local oPanel		:= NIL 
	Local oTxMoeda 	:= NIL
	Local oEstoque	:= Nil 
	Local lTxMoeda	:= LoadTxMoeda()  
	Local lLoadZero	:= IsLoadZero()
	
	// Panel 9 - Configuração de parâmetros genéricos da área comercial, financeiro ou materiais  
	CREATE PANEL oWizard ;
		HEADER STR0139;				//"Configuração de Parâmetros Genéricos"				
		MESSAGE CRLF + STR0233 ; 	//"Área Comercial, Financeiro e Materiais."
		BACK {|| ( ShowBackParam( oWizard, AREACOMFINMAT ) ), .T. } ;
		NEXT {|| ( PersComFinMat(lTxMoeda, lLoadZero), ShowNextParam( oWizard, AREACOMFINMAT) ), .T. };
		FINISH {|| ( PersComFinMat(lTxMoeda, lLoadZero), BIXCloseFSD()), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)   
		
		@ 10, 010 CHECKBOX oTxMoeda VAR lTxMoeda 	PROMPT STR0226 OF oPanel SIZE 270, 009 PIXEL //"Comercial, Financeiro, Materiais - Utiliza a taxa negociada na conversão de moeda."			
		@ 30, 010 CHECKBOX oEstoque VAR lLoadZero PROMPT STR0234 OF oPanel SIZE 270, 009 PIXEL //"Estoque Diário e Saldo Estoque Diário - Extrair produtos sem movimentação ou saldo."					
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WzdControl
Painel para configuração dos parâmetros de Controladoria
@param oWizard		Objeto onde os componentes serão criados

@protected
@author  BI TEAM
@version P11
@since   11/04/2011
/*/
//-------------------------------------------------------------------
Static Function WzdControl( oWizard )
	Local oPanel	 	:= NIL
	Local aCntResult 	:= LoadCntResult()	//Vetor com as informações das contas de resultado*/
	Local oBrowse 		:= NIL 
 	Local aMark			:= {}
 	Local nAccount		:= 1 
 	Local lCheck		:= LoadContaBloq()

	//-------------------------------------------------------------------
	// Panel 10 - Configuração de parâmetros da Controladoria - Definição das contas de resultado. 
	//-------------------------------------------------------------------
	CREATE PANEL oWizard ;
		HEADER STR0141;					//"Configuração de Parâmetros da área Controladoria"
		MESSAGE STR0203 ;		//"Selecione os itens que serão utilizados como Contas de Resultado."
		BACK {|| ( ShowBackParam( oWizard, AREA_CONTROL	 ) ), .T. } ;
		NEXT {|| ( SaveCntRes(aCntResult) ), .T. };
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)

		//-------------------------------------------------------------------
		// Monta o identificador de seleção de contas. 
		//-------------------------------------------------------------------
	 	For nAccount := 1 To Len( aCntResult )
	 		aAdd( aMark, { aCntResult[nAccount], .T. }  )
	 	Next nAccount 
	
		//-------------------------------------------------------------------
		// Monta o browse. 
		//-------------------------------------------------------------------
		DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "CT1" NO CONFIG NO REPORT NO SEEK OF oPanel  
			ADD MARKCOLUMN oColumn DATA { || If( IsAccountMarked( aMark ) ,'LBOK','LBNO') } DOUBLECLICK { || MarkAccount( @aMark, @aCntResult ) } OF oBrowse
			ADD LEGEND DATA 'CT1_CLASSE == "1"' COLOR "RED" 	TITLE STR0188 OF oBrowse //"Sintética"
			ADD LEGEND DATA 'CT1_CLASSE == "2"' COLOR "GREEN"   TITLE STR0189 OF oBrowse //"Analítica"
			ADD COLUMN oColumn DATA { ||  CT1_CONTA     } TITLE STR0190 SIZE 15 OF oBrowse //"Conta"
			ADD COLUMN oColumn DATA { ||  CT1_DESC01    } TITLE STR0191 SIZE 40 OF oBrowse //"Descrição" 
		ACTIVATE FWBROWSE oBrowse
	
	// Panel 11 - Configuração de parâmetros da área Controladoria.
	CREATE PANEL oWizard ;
		HEADER STR0141 ;			//"Configuração de Parâmetros da área Controladoria"
		MESSAGE CRLF + STR0141 ; //"Configuração de Parâmetros da área Controladoria"
		BACK {|| .T.  } ;
		NEXT {|| ( SaveContaBloq( lCheck ), ShowNextParam( oWizard, AREA_CONTROL) ), .T. };
		FINISH {|| ( SaveCntRes(aCntResult), SaveContaBloq( lCheck ), BIXCloseFSD() ), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};		
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)

		@ 005, 010 CHECKBOX oRepres VAR lCheck PROMPT STR0260 OF oPanel SIZE 400, 020 PIXEL // "Indica se devem ser consideradas as Contas Bloqueadas no plano de contas."				
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WzdMat
Painel para configuração dos parâmetros de Materiais.
@param oWizard		Objeto onde os componentes serão criados

@protected
@author  Helio Leal
@version P12
@since   08/10/2014
/*/
//-------------------------------------------------------------------
Static Function WzdMat( oWizard )
	Local oPanel	 		:= NIL 
	Local oBrowse 		:= NIL  
	Local nPeriod			:= LoadMat()			
	Local oSayCarteira 	:= Nil 
	Local oSpinCarteira 	:= Nil 
	Local oSayCartComp	:= Nil
	Local oSpinCartComp 	:= Nil
	Local nPeriodCartComp	:= LoadMatCartComp()
	
	// Panel 12 - Configuração de parâmetros da área comercial 
	CREATE PANEL oWizard ;
			HEADER STR0237 ; // "Configuração de Parâmetros da Área Materiais				
		MESSAGE CRLF + STR0238 ; // "Área Materiais"
		BACK {|| ( ShowBackParam( oWizard, AREA_MAT ) ), .T. } ;
		NEXT {|| ( SaveMat( nPeriod, nPeriodCartComp ), ShowNextParam( oWizard, AREA_MAT) ), .T. };
		FINISH {|| ( SaveMat( nPeriod, nPeriodCartComp ), BIXCloseFSD() ), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL

	oPanel := oWizard:GetPanel(oWizard:nTPanel)

	//-------------------------------------------------------------------
	// Spin para Qualidade carteira.
	//-------------------------------------------------------------------
	oSayCarteira	:= tSay():new(5, 10, {|| STR0240 + " - " + STR0239 }, oPanel, , , , , , .T., , , 240, 15) // "Qualidade Carteira" ### "Número máximo de meses em aberto que devem ser considerados:"
	oSpinCarteira	:= tSpinBox():new(3, 255, oPanel, {|x| nPeriod := x }, 30, 13)
	oSpinCarteira:setRange(2, 120)
   	oSpinCarteira:setStep(1)
   	oSpinCarteira:setValue( nBIVal( nPeriod ) )

	//-------------------------------------------------------------------
	// Spin para Carteira de Compras.
	//-------------------------------------------------------------------
   	oSayCartComp 	:= tSay():new(30, 10, {|| STR0241 + " - " + STR0242 }, oPanel, , , , , , .T., , , 240, 15) // Carteira de Compras ### Número máximo de meses que os pedidos de compras não recebidas devem ser considerados:"
   	oSpinCartComp := tSpinBox():new(25, 255, oPanel, {|x| nPeriodCartComp := x }, 30, 13)
   	oSpinCartComp:setRange(2, 120)
   	oSpinCartComp:setStep(1)
   	oSpinCartComp:setValue( nBIVal(nPeriodCartComp) )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WzdProd
Painel para configuração dos parâmetros de Produção.
@param oWizard		Objeto onde os componentes serão criados

@protected
@author  Tamara Clemente
@version P12
@since   14/10/2014
/*/
//-------------------------------------------------------------------
Static Function WzdProd( oWizard )
	Local oPanel	 		:= NIL 
	Local nPeriod			:= LoadProd()			
	Local nCartMP			:= LoadCartMP()
	Local nCartPR			:= LoadCartPR()
	Local nCartMO			:= LoadCartMO()
	Local oSayOpercao		:= Nil  
	Local oSayCartMP 		:= Nil  
	Local oSayCartPR 		:= Nil
	Local oSayCartMO 		:= Nil
	Local oSpinOperacap 	:= Nil 
	Local oSpinCartMP   	:= Nil 
	Local oSpinCartPR   	:= Nil 
	Local oSpinCartMO   	:= Nil 
	
	// Panel 13 - Configuração de parâmetros da área de produção 
	CREATE PANEL oWizard ;
			HEADER STR0246 ; // "Configuração de Parâmetros da Área Produção
		MESSAGE CRLF + STR0243 ; // "Área Produção" Tamara, alterar
		BACK {|| ( ShowBackParam( oWizard, AREA_PROD ) ), .T. } ;
		NEXT {|| ( SaveProd( nPeriod, nCartMP, nCartPR, nCartMO ), ShowNextParam( oWizard, AREA_PROD) ), .T. };
		FINISH {|| ( SaveProd( nPeriod, nCartMP, nCartPR, nCartMO ), BIXCloseFSD() ), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)   

	oSayOpercao	:= tSay():new(5, 10, {|| STR0244 + " - " +STR0245 }, oPanel, , , , , , .T., , , 240, 15) // "Custo por Operação" ### "Número máximo de meses em aberto que devem ser considerados:"
	oSpinOperacap	:= tSpinBox():new(3, 255, oPanel, {|x| nPeriod := x }, 30, 13)
	oSpinOperacap:setRange(2, 120)
   	oSpinOperacap:setStep(1)
   	oSpinOperacap:setValue( nBIVal( nPeriod ) )

   	//-------------------------------------------------------------------
	// Spin para Matéria Prima - Carteira
	//-------------------------------------------------------------------
   	oSayCartMP := tSay():new(25, 10, {|| STR0249 + " - " + STR0250 + ": "}, oPanel, , , , , , .T., , , 240, 15) //"Matéria Prima - Carteira"###"Número máximo de meses em que os registros em aberto devem ser considerados" 
   	oSpinCartMP := tSpinBox():new(23, 255, oPanel, {|x| nCartMP := x }, 30, 13)
   	oSpinCartMP:setRange(2, 120)
   	oSpinCartMP:setStep(1)
   	oSpinCartMP:setValue( nBIVal(nCartMP) )

   	//-------------------------------------------------------------------
	// Spin para Produção - Carteira
	//-------------------------------------------------------------------
   	oSayCartPR := tSay():new(45, 10, {|| STR0251 + " - " + STR0250 + ": "}, oPanel, , , , , , .T., , , 240, 15) //"Produção - Carteira"###"Número máximo de meses em que os registros em aberto devem ser considerados" 
   	oSpinCartPR := tSpinBox():new(43, 255, oPanel, {|x| nCartPR := x }, 30, 13)
   	oSpinCartPR:setRange(2, 120)
   	oSpinCartPR:setStep(1)
   	oSpinCartPR:setValue( nBIVal(nCartPR) )
   	
   	//-------------------------------------------------------------------
	// Spin para Mão de Obra - Carteira
	//-------------------------------------------------------------------
   	oSayMOCart := tSay():new(65, 10, {|| STR0252 + " - " + STR0250 + ": "}, oPanel, , , , , , .T., , , 240, 15) //"Mão de Obra - Carteira"###"Número máximo de meses em que os registros em aberto devem ser considerados" 
   	oSpinMOCart := tSpinBox():new(63, 255, oPanel, {|x| nCartMO := x }, 30, 13)
   	oSpinMOCart:setRange(2, 120)
   	oSpinMOCart:setStep(1)
   	oSpinMOCart:setValue( nBIVal(nCartMO) ) 
   	   	     	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WzdRH
Painel para configuração dos parâmetros de RH
@param oWizard		Objeto onde os componentes serão criados

@protected
@author  BI TEAM
@version P11
@since   11/04/2011
/*/
//-------------------------------------------------------------------
Static Function WzdRH(oWizard)
	Local oPanel := Nil
	Local aTpCargo 	:= loadFaixa('TPCARG') //Tempo de Cargo
	Local aTpCasa 	:= loadFaixa('TPCASA') //Tempo de Casa
	Local aFxEtaria	:= loadFaixa('FXAETA') //Faixa Etária
	Local aFxSal	:= loadFaixa('FXSALA', "@E 999,999,999.99", 2) //Faixa Salarial

	// Panel 14 - "Configuração de parâmetros da área Recursos Humanos" - Faixas para tempo de cargo
	CREATE PANEL oWizard ;
		HEADER STR0142 ;			//"Configuração de Parâmetros da área Recursos Humanos"
		MESSAGE STR0204 ;	//"Informe os dados utilizados pelo extrator para classificar as informações da área de RH."
		BACK {|| ( ShowBackParam( oWizard, AREA_RH ) ), .T.  } ;
		NEXT {|| Iif( ValidFaixa( aTpCargo ), ( SaveFaixa(aTpCargo, 'TPCARG'), .T.) , .F.) };
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)
		ListFaixa(oPanel, aTpCargo, , , STR0023) //"Faixas para Tempo de Cargo"

	// Panel 15 - Configuração de parâmetros da área Recursos Humanos - Faixas para tempo de casa
	CREATE PANEL oWizard ;
		HEADER STR0142 ;			//"Configuração de Parâmetros da área Recursos Humanos"
		MESSAGE STR0204 ;	//"Informe os dados utilizados pelo extrator para classificar as informações da área de RH."
		BACK {|| .T.  } ;
		NEXT {|| Iif( validFaixa( aTpCasa ), ( SaveFaixa(aTpCasa, 'TPCASA'), .T.), .F.) };
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)
		ListFaixa(oPanel, aTpCasa, , , STR0025) //"Faixas para Tempo de Casa"

	// Panel 16 - Configuração de parâmetros da área Recursos Humanos - Faixas etárias
	CREATE PANEL oWizard ;
		HEADER STR0142 ;			//"Configuração de Parâmetros da área Recursos Humanos"
		MESSAGE STR0204 ;	//"Informe os dados utilizados pelo extrator para classificar as informações da área de RH."
		BACK {|| .T.  } ;
		NEXT {|| Iif( validFaixa( aFxEtaria ), ( SaveFaixa(aFxEtaria, 'FXAETA'), .T.), .F.) };
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)
		ListFaixa(oPanel, aFxEtaria, , , STR0026) //"Faixas etárias"

	// Panel 17 - Configuração de parâmetros da área Recursos Humanos - Faixa Salarial
	CREATE PANEL oWizard ;
		HEADER STR0142 ;			//"Configuração de Parâmetros da área Recursos Humanos"
		MESSAGE STR0204 ;	//"Informe os dados utilizados pelo extrator para classificar as informações da área de RH."
		BACK {||  .T.  } ;
		NEXT {||  Iif( validFaixa( aFxSal ), ( SaveFaixa(aFxSal, 'FXSALA', 2), ShowNextParam( oWizard, AREA_RH ), .T.), .F.) };
		FINISH {|| Iif( validFaixa( aFxSal ), ( SaveFaixa(aFxSal, 'FXSALA', 2), ShowNextParam( oWizard, AREA_RH ), BIXCloseFSD(), .T.), .F.) } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL

		oPanel := oWizard:GetPanel(oWizard:nTPanel)
		ListFaixa(oPanel, aFxSal, "@E 999,999,999.99", 2, STR0067) //"Faixa Salarial"
Return
             
//-------------------------------------------------------------------
/*/{Protheus.doc} WzdDL
Painel para configuração dos parâmetros de DL
@param oWizard		Objeto onde os componentes serão criados

@author  Valdiney V GOMES
@version P12
@since   03/07/2014
/*/
//-------------------------------------------------------------------
Static Function WzdDL( oWizard )   
	Local aPeriod	:= LoadPeriodDL()	//Vetor com as informações de Período de DL

	// Panel 21 - Configuração de parâmetros da área DL
	CREATE PANEL oWizard ;
		HEADER STR0220 ;	//"Configuração de parâmetros"
		MESSAGE STR0193 ;	//"Períodos de DL"
		BACK {|| ( ShowBackParam( oWizard, AREA_DL ) ), .T. } ;
		NEXT {|| ( PersPeriodDL(aPeriod), ShowNextParam( oWizard, AREA_DL) ), .T. };
		FINISH {|| ( PersPeriodDL(aPeriod), BIXCloseFSD() ), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL     

	oPanel := oWizard:GetPanel(oWizard:nTPanel)
	wzdPeriodDL(oPanel , @aPeriod)    
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} WzdVarejo
Painel para configuração dos parâmetros de Varejo
@param oWizard		Objeto onde os componentes serão criados

@author  Valdiney V GOMES
@version P12
@since   03/07/2014
/*/
//-------------------------------------------------------------------
Static Function WzdVarejo( oWizard )  
	Local nMinute	:= LoadHourRange()
 
 	// Panel 22 - Configuração de parâmetros da área Varejo
	CREATE PANEL oWizard ;
		HEADER STR0221 ;	//"Configuração de parâmetros"
		MESSAGE STR0202 ;	//"Faixa de Hora"
		BACK {|| ( ShowBackParam( oWizard, AREA_VAREJO ) ), .T.  } ;
		NEXT {|| ( PersHourRange( nMinute ), ShowNextParam( oWizard, AREA_VAREJO) ), .T. };
		FINISH {|| ( PersHourRange( nMinute ), BIXCloseFSD() ), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL

	oPanel := oWizard:GetPanel(oWizard:nTPanel)
	wzdHourRange(oPanel , @nMinute)   
Return 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} WzdCRM
Painel para configuração dos parâmetros de Varejo
@param oWizard		Objeto onde os componentes serão criados

@author  Valdiney V GOMES
@version P12
@since   03/07/2014
/*/
//-------------------------------------------------------------------
Static Function WzdCRM( oWizard )  
	Local aDiasCRM	:= LoadDiasCRM()
 
 	// Panel 23 - Configuração de parâmetros da área CRM
	CREATE PANEL oWizard ;
		HEADER STR0219 ;	//"Configuração de parâmetros"
		MESSAGE STR0209 ;	//"Períodos de CRM"
		BACK {|| ( ShowBackParam( oWizard, AREA_CRM ) ), .T.  } ;
		NEXT {|| ( PersDiasCRM( aDiasCRM ), ShowNextParam( oWizard, AREA_CRM ) ), .T. };
		FINISH {|| ( PersDiasCRM( aDiasCRM ), BIXCloseFSD() ), .T. } ;
		EXEC {|| ShowFinish( @oWizard )};
		PANEL
		
	oPanel := oWizard:GetPanel(oWizard:nTPanel)
	wzdPeriodCRM(oPanel , @aDiasCRM)   
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ListFaixa
Painel para configuração de faixas de valores
@param oPanel		Painel onde os componentes serão criados
@param aFaixas		Vetor com as informações das faixas
@param cPicture	Picture a ser utilizada
@param nDec		Qtde de decimais a ser utilizada
@param cTexto		Texto para identificação do tipo de faixa

@protected
@author  BI TEAM
@version P11
@since   16/12/2010
/*/
//-------------------------------------------------------------------
Static function ListFaixa(oPanel, aFaixas, cPicture, nDec, cTexto)
	Local oBrowse 		:= Nil
	Default cPicture 	:= "@E 99"
	Default nDec 		:= 0

	@ 005, 010 SAY cTexto OF oPanel SIZE 150, 010 PIXEL

	oBrowse := TCBrowse():New( 15, 10, 285, 120,,,, oPanel,,,,,,,,,,,,,, .T.)
	oBrowse:AddColumn( TCColumn():New( STR0030, {|| iif( Len(aFaixas) > 0, aFaixas[oBrowse:nAt, 1], "" )},,,, "LEFT", 060, .F., .F.,,,,,) ) //"Faixa"
	oBrowse:AddColumn( TCColumn():New( STR0031, {|| iif( Len(aFaixas) > 0, aFaixas[oBrowse:nAt, 2], "" )},,,, "RIGHT", 100, .F., .F.,,,,,) ) //"Valor Inicial"
	oBrowse:AddColumn( TCColumn():New( STR0032, {|| iif( Len(aFaixas) > 0, aFaixas[oBrowse:nAt, 3], "" )},,,, "RIGHT", 100, .F., .T.,,,,,) ) //"Valor Final"
	oBrowse:SetArray( aFaixas )
	oBrowse:blDblClick := {|| BIXEditCBCell( oBrowse, aFaixas, cPicture, Nil, {||updFx(aFaixas, oBrowse, cPicture)}, "N", nDec )}
Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ListaArea
Gera a relação de áreas disponíveis para extração.

@protected
@author  Marcia Junko
@version P11
@since   24/04/2014
@return aRet	Vetor com a relação de áreas de extração
/*/
//---------------------------------------------------------------------------------
Static Function BIXListArea()
	Local aArea	:= BIXRegister() 
	Local aRet 	:= {}
	Local nI	:= 0    

	For nI := 1 To Len(aArea)
		AAdd(aRet, { .F., aArea[nI][1], aArea[nI][2]})
	Next
Return aRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} adjustSpaces
Essa funcao ira ajustar o valor de um determinado campo com o máximo
de caracteres que ele poderá conter. Isso é necessário para campso
de tela MsGet. Será adicionado espaços em branco ao final do valor
até a quantidade de caracteres máxima.
@param cValue	Valor a ser "ajustado"
@param nQtde	Quantidade máxima de caracteres

@protected
@author  BI TEAM
@version P11
@since   12/07/2010
@return cValue	Valor "ajustado"
/*/
//---------------------------------------------------------------------------------
Static Function adjustSpaces(cValue, nQtde)
	If Len(cValue) < nQtde
		cValue := PadR(cValue, nQtde)
	Else
		cValue := Right(cValue, nQtde)
	EndIf
Return cValue


//---------------------------------------------------------------------------------
/*/{Protheus.doc} ValidServer
Função para validar o preenchimento dos parâmetros para conexão
com a Stage.
@param cBIXTCon	Tipo de conexão ao DBAccess
@param cBIXDB		Tipo do Banco de Dados
@param cBIXSRVR	Servidor DBAccess
@param cBIXPORT	Porta do servidor DBAccess
@param cBIXALIA	Alias no DBAccess

@protected
@author  BI TEAM
@version P11
@since   12/07/2010
@return Retorna se os dados foram preenchidos corretamente e se foi
	possivel a conexão com o servidor
/*/
//---------------------------------------------------------------------------------
static function ValidServer( cBIXTCon, cBIXDB, cBIXSRVR, cBIXPORT, cBIXALIA, aLastConn, lChangeConn )
	
	Default aLastConn := NIL
	Default lChangeConn := .F.
	
	If Empty(cBIXTCON)
		ApMsgStop(STR0001 + ": " + STR0003) //"Campo obrigatório"###"Tipo de Conexão ao DBAccess"
		Return .F.
	EndIf

	If Empty(cBIXDB)
		ApMsgStop(STR0001 + ": " + STR0005) //"Campo obrigatório"###"Tipo do Banco de Dados"
		Return .F.
	EndIf

	If Empty(cBIXSRVR)
		ApMsgStop(STR0001 + ": " + STR0009) //"Campo obrigatório"###"Servidor DBAccess"
		Return .F.
	EndIf

	If Empty(cBIXPORT)
		ApMsgStop(STR0001 + ": " + STR0011) //"Campo obrigatório"###"Porta do Servidor DBAccess"
		Return .F.
	EndIf

	If Empty(cBIXALIA)
		ApMsgStop(STR0001 + ": " + STR0007) //"Campo obrigatório"###"Alias no DBAcess"
		Return .F.
	EndIf
Return SaveConn( cBIXTCon, cBIXDB, cBIXSRVR, cBIXPORT, cBIXALIA, aLastConn, @lChangeConn )

//---------------------------------------------------------------------------------
/*/{Protheus.doc} BIXGetFaixas
Função que retorna os parâmetros que podem ser configurados pelo Wizard.

@protected
@author  BI TEAM
@version P11
@since   15/07/2010
@return Vetor com os parâmetros disponíveis para configuração
/*/
//---------------------------------------------------------------------------------
function BIXGetFaixas()
	Local aRet := {}
	
	Aadd(aRet, {"FXSALA", 		STR0067, STR0068}) //"Faixas Salariais"###"Informe as faixas salariais separadas por ponto e virgula (vírgula como separador decimal), por exemplo: 0,00;20,00;40,10;60,00"
	Aadd(aRet, {"FXAETA", 		STR0026, STR0058}) //"Faixas etárias"###"Informe as faixas etárias separando as idades por ponto e virgula, por exemplo: 0;20;40;60"
	Aadd(aRet, {"TPCARG", 		STR0023, STR0059}) //"Faixa para Tempo de Cargo"###"Informe as faixas de tempo em anos separando os valores por ponto e vírgula. Exemplo: 0;2;4;10;20"
	Aadd(aRet, {"TPCASA", 		STR0025, STR0059}) //"Faixa para Tempo de Casa"###"Informe as faixas de tempo em anos separando os valores por ponto e vírgula. Exemplo: 0;2;4;10;20"
	Aadd(aRet, {"START", 		STR0060, STR0061}) //"Inicio da Extração"###"Data/Hora em que foi iniciada a extração. (YYYYMMDD HHNNSS)"
	Aadd(aRet, {"FINISH", 		STR0062, STR0063}) //"Fim da Extração"###"Data/Hora em que foi finalizada a extração. (YYYYMMDD HHNNSS)"
	Aadd(aRet, {"STATUS", 		STR0064, STR0065}) //"Estado da Extração"###"Indica que o processo não foi iniciado. RUNNING : Indica que o processo de extração foi iniciado. STOPPED : Indica que o processo de extração foi interrompido pelo usuário. ERROR : Indica que o processo de extração foi interrompido por erro."
	Aadd(aRet, {"BIX_MOEDA", 	STR0080, STR0080}) //"Moedas"###"Moedas"
	Aadd(aRet, {"BIX_CTB_CG", 	STR0083, STR0083}) //"Contas Gerenciais"###"Contas Gerenciais"
	Aadd(aRet, {"BIX_CTB_LC", 	STR0084, STR0084}) //"Livro Contabil"###"Livro Contabil"
	Aadd(aRet, {"LINPRO", 		STR0085, STR0086}) //"Linha de produto"###"Indica a linha de produto (D, L, P ou R). "
	Aadd(aRet, {"ISTCIA", 		STR0087, STR0088}) //"Instância"###"Indica a instância de instalação"
	Aadd(aRet, {"CNTRESULT", 	STR0089, STR0090}) //"Contas de Resultado"###"Indica as contas contábeis de resultado"
	Aadd(aRet, {"CNTRES", 		STR0089, STR0090}) //"Contas de Resultado"###"Indica as contas contábeis de resultado"
	Aadd(aRet, {"BIX_VISGER", 	STR0100, STR0101}) //"Visão Gerencial"###"Visões gerenciais que serão utilizadas"
	Aadd(aRet, {"BIX_DTACUM", 	STR0102, STR0103}) //"Data Acumulado"###"A partir desta data, os valores serão acumulados na visão gerencial."
	Aadd(aRet, {"BIX_GRPSLD", 	STR0106, STR0123}) //"Grupos de Saldos"###"Vinculos entre tipos de saldo e grupos de saldos."
	Aadd(aRet, {"BIX_FAMCOM", 	STR0146, STR0133}) //Chave de Negócio da Família Comercial###"Indica a utilização da chave de negócio consolidada para a Família Comercial."
	Aadd(aRet, {"BIX_UNITEM", 	STR0156, STR0155}) //Chave de Negócio da Família Comercial###"Indica a utilização da chave de negócio consolidada para a Unid. Medida Item."
	Aadd(aRet, {"BIX_CMOEDA", 	STR0158, STR0159}) //Chave de Negocio da Moeda###"Indica a utilização da chave de negócio consolidada para a Moeda."
	Aadd(aRet, {"BIX_INTREC", 	STR0196, STR0197}) //"Período Adicional para Recebimento de Notas Fiscais de Clientes" ###"No período determinado pelo parâmetro, fora do período normal de extração, deverão ser extraídos apenas os registros cuja a Quantidade Expedida for igual 0."
	Aadd(aRet, {"BIX_DTOCIO", 	STR0198, STR0199}) //"Período Adicional para Ociosidade de Veículo" ###"Data passada limite a ser utilizada para a busca de datas de chegada de veículos que ainda não tiveram uma nova saída da transportadora." 
	Aadd(aRet, {"BIX_FXHORA", 	STR0202, STR0201}) //"Faixas de Horas" ###"Informe o intervalo em minutos para a definição das faixas de horas para identificação de picos de venda."
	Aadd(aRet, {"BIX_DIASAT", 	STR0211, STR0210}) //"Período Adicional para Atividades" ###"Atividades - Número máximo de meses, além do período de extração, para buscar as atividades abertas:"
	Aadd(aRet, {"BIX_DIASPR", 	STR0212, STR0213}) //"Período Adicional para Desempenho de Vendas de Produto"###"Desempenho de Vendas de Produtos - Número máximo de meses, além do período de extração, para buscar os itens das propostas abertas ou suspensas:" 
	Aadd(aRet, {"BIX_DIASTM",	STR0214, STR0215}) //"Período Adicional para Desempenho do Time de Vendas"###"Desempenho do Time de Vendas - Número máximo de meses, além do período de extração, para buscar as oportunidades de vendas abertas ou suspensas:"
	Aadd(aRet, {"BIX_DIASEV", 	STR0216, STR0217}) //"Período Adicional para Evolução de Venda" ###"Evolução de Venda - Número máximo de meses, além do período de extração, para buscar os itens de evolução de venda com status do estágio em andamento e em atraso:" 
	Aadd(aRet, {"BIX_AREAS", 	STR0144, STR0145}) //"Áreas"###"Indica as áreas que serão utilizadas na extração"  
	Aadd(aRet, {"BIX_PVENDA", 	STR0224, STR0225}) //"Carteira de Vendas"###"Número máximo de meses que os pedidos de venda em aberto devem ser considerados."
	Aadd(aRet, {"BIX_TXMOED", 	STR0227, STR0227}) //Define a utilização da taxa negociada na conversão de moeda.
	Aadd(aRet, {"BIX_EVENDA", 	STR0228, STR0229}) //"Entregas de Vendas"###"Número máximo de meses que os pedidos de venda liberados devem ser considerados"
	Aadd(aRet, {"DB_TYPE", 		STR0231, STR0232}) //"Tipo de Banco de Dados"###"Indica a tecnologia de banco de dados utilizado para o banco BIDW (M, D, O, I)"
	Aadd(aRet, {"BIX_CRTQUA", 	STR0240, STR0239}) // "Qualidade Carteira"###"Número máximo de meses em aberto que devem ser considerados:"
	Aadd(aRet, {"BIX_NOZERO", 	STR0235, STR0236}) //"Estoque"###"Indica se produtos sem saldo ou movimentação de estoque devem ser considerados nas extrações diárias de estoque."
	Aadd(aRet, {"BIX_REPRES", 	STR0247, STR0248})	//"Dados do representante"###"Indica se o representante será obtido através do cadastro do cliente, ao invés dos dados da nota/pedido."
	Aadd(aRet, {"BIX_CUSTOP", 	STR0244, STR0245}) // "Custo por Operação"###Número máximo de meses que as operações não finalizadas devem ser consideradas"				
	Aadd(aRet, {"BIX_CRTCOM",   STR0241, STR0242})	//"Carteira de Compras"###"Número máximo de meses que os pedidos de compras não recebidas devem ser considerados:"},;
	Aadd(aRet, {"BIX_CARTMP", 	STR0249, STR0250})	//"Matéria Prima - Carteira"###"Número máximo de meses em que os registro em aberto devem ser considerados"
	Aadd(aRet, {"BIX_CARTPR", 	STR0251, STR0250})	//"Produção - Carteira"###"Número máximo de meses em que os registro em aberto devem ser considerados"
	Aadd(aRet, {"BIX_CARTMO", 	STR0252, STR0250})	//"Mão de Obra - Carteira"###"Número máximo de meses em que os registro em aberto devem ser considerados"	
	Aadd(aRet, {"BIX_TESDUP", 	STR0253, STR0254 + ". " + STR0259})	//"Faturamento"###"Considerar notas em que a TES gera duplicata"###"Opções: 1 - Sim, 2 - Não, 3 - Ambos"
	Aadd(aRet, {"BIX_TESEST", 	STR0253, STR0255 + ". " + STR0259}) //"Faturamento"###"Considerar notas em que a TES movimenta o estoque"###"Opções: 1 - Sim, 2 - Não, 3 - Ambos"
	Aadd(aRet, {"BIX_CONTBL", 	STR0141, STR0260})	//"Configuração de Parâmetros da área Controladoria"###"Indica se deve ser consideradas as Contas Bloqueadas no plano de contas."
	Aadd(aRet, {"BIX_CLIREG", 	STR0261, STR0263}) 	//"Genérico"###"Indica se os dados do cliente serão considerados na dimensão região geográfica."
	Aadd(aRet, {"BIX_DEVVEN", 	STR0264, STR0265})  //"Devolução de Vendas"###"Considerar documentos de entrada do tipo devolução com cliente diferente do documento de saída."
	Aadd(aRet, {"BIX_CMPEMP",   STR0261, STR0268})  //"Genérico"###"Considerar o compartilhamento de tabelas entre empresas?"
	Aadd(aRet, {"BIX_AGENT" , 	STR0266, STR0267}) // "Estado do Agent" ### "INITIALIZED: Processo iniciado, LISTENING: Processo em modo de listen, RUNNING: Processo rodando, STOPPED: Processo parado"	
	Aadd(aRet, {"BIX_IDENTI" , 	STR0272, STR0273}) ///"Genérico"###"Utiliza R_E_C_N_O_ auto-incremental"	
return aRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} BIXGetIndicadores
Função que retorna a lista de indicadores financeiros e econômicos

@protected
@author  BI TEAM
@version P11
@since   15/07/2010
@return Vetor com a lista dos indicadores
/*/
//---------------------------------------------------------------------------------
Function BIXGetIndicadores()
Return {{"00000001", STR0034}, ; //###"Ativo Total"
		{"00000002", STR0035}, ; //###"Ativo Circulante"
		{"00000003", STR0036}, ; //###"Clientes"
		{"00000004", STR0037}, ; //###"Duplicatas Descontadas"
		{"00000005", STR0038}, ; //###"Estoques"
		{"00000006", STR0039}, ; //###"Ativo Não Circulante"
		{"00000007", STR0040}, ; //###"Ativo Imobilizado"
		{"00000008", STR0041}, ; //###"Passivo Circulante"
		{"00000009", STR0042}, ; //###"Fornecedores"
		{"00000010", STR0043}, ; //###"Empréstimos e Financiamentos Curto Prazo"
		{"00000011", STR0044}, ; //###"Empréstimos e Financiamentos Longo Prazo"
		{"00000012", STR0045}, ; //###"Passivo Não Circulante"
		{"00000013", STR0046}, ; //###"Patrimônio Líquido"
		{"00000014", STR0047}, ; //###"Receita de Vendas"
		{"00000015", STR0048}, ; //###"Receita Operacional de Vendas"
		{"00000016", STR0049}, ; //###"Custo"
		{"00000017", STR0050}, ; //###"Devoluções"
		{"00000018", STR0051}, ; //###"Resultado Operacional"
		{"00000019", STR0052}, ; //###"Lucro Líquido/Lucros e Perdas"
		{"00000020", STR0053}, ; //###"Compras"
		{"00000021", STR0054}, ; //###"Impostos sobre Vendas"
		{"00000022", STR0055}, ; //###"Despesas Operacionais"
		{"00000023", STR0056}, ; //###"Receitas Financeiras"
		{"00000024", STR0057}, ; //###"Despesas Financeiras"
		{"00000025", STR0095}, ; //###"Livre"
		{"00000026", STR0095}, ; //###"Livre"
		{"00000027", STR0095}, ; //###"Livre"
		{"00000028", STR0095}, ; //###"Livre"
		{"00000029", STR0095}} //###"Livre"					
	 

//---------------------------------------------------------------------------------
/*/{Protheus.doc} SaveConn
Funcao para verificar uma conexão com um servidor dbAccess e salvar os dados de conexão.
@param cBIXTCon	Tipo de conexão ao DBAccess
@param cBIXDB		Tipo do Banco de Dados
@param cBIXSRVR	Servidor DBAccess
@param cBIXPORT	Porta do servidor DBAccess
@param cBIXALIA	Alias no DBAccess

@protected
@author  BI TEAM
@version P11
@since   15/07/2010
@return lRet	Se é um Servidor DBAccess valido (.T.) ou não (.F.)
/*/
//---------------------------------------------------------------------------------
Static Function SaveConn( cBIXTCon, cBIXDB, cBIXSRVR, cBIXPORT, cBIXALIA, aLastConn, lChangeConn )
	Local cDbType 		:= ""
	Local cDbTcCon 		:= ""
	Local nConn 		:= -1
	Local nResp 		:= 0
	Local oSocket 		:= tSocketClient():New()
	
	Default aLastConn := {}
	Default lChangeConn := .F.

	If cBIXTCON == STRTCPIP
		cDbTcCon := TCPIP
	ElseIf cBIXTCON == STRNPIPE
		cDbTcCon := NPIPE
	EndIf

	If cBIXDB == STRMSSQL
		cDbType := MSSQL
	ElseIf cBIXDB == STRDB2
		cDbType := DB2
	ElseIf cBIXDB == STRORACLE
		cDbType := ORACLE
	ElseIf cBIXDB == STRINFORMIX
		cDbType := INFORMIX
	ElseIf cBIXDB == STRPOSTGRES
		cDbType := POSTGRES		
	EndIf

	//Testa server/port utilizando socket
	nResp := oSocket:Connect( nBIVal(cBIXPORT), AllTrim(cBIXSRVR), 1000 )

	If oSocket:isConnected()
		oSocket:closeConnection()
	EndIf

	If ( nResp == 0 )
		nConn := TCLINK( AllTrim(cDbType) + "/" + AllTrim(cBIXALIA), AllTrim(cBIXSRVR), nBIVal(cBIXPORT) )

		If nConn >= 0
			TCUnlink( nConn ) //Fecha a conexão com a Stage
			ApMsgInfo(STR0024) //"Conexão com o Servidor DBAccess com sucesso"
			
			//-------------------------------------------------------------------
			// Grava as propriedades da Fluig Smart Data. 
			//-------------------------------------------------------------------	
			BIXLinkRecord(, cDbTcCon, cDbType, cBIXSRVR, cBIXPORT, cBIXALIA )

			//-------------------------------------------------------------------
			// Grava o tipo de banco de dados utilizado pelo DW. 
			//-------------------------------------------------------------------	
		   	If Empty( BIXLoadParam('DB_TYPE', , .T. ,.T.) )
		   		BIXSaveDBParam(cDbType)
		  	EndIf	

			//-------------------------------------------------------------------
			// Grava o parãmetro de linha de produto na Fluig Smart Data. 
			//-------------------------------------------------------------------			  	
		  	BIXSaveParam('LINPRO', "P ")		  		

			//-------------------------------------------------------------------
			// Verifica se as configurações de conexão foram alteradas 
			//-------------------------------------------------------------------			  	
		  	IF !Empty(aLastConn)
			  	If aLastConn[1][1] != cDbTcCon .Or. aLastConn[1][2] != cDbType .Or. ;
			  		Upper(Alltrim(aLastConn[1][3])) != Upper(Alltrim(cBIXSRVR)) .Or. Upper(Alltrim(aLastConn[1][4])) != Upper(Alltrim(cBIXPORT)) .Or. Upper(Alltrim(aLastConn[1][5])) != Upper(Alltrim(cBIXALIA))
			  		ApMsgAlert( STR0274 ) //"Detectamos que as configurações de acesso a Fluig Smart Data foram alteradas. Revise os parâmetros de extração."
					lChangeConn := .T.
					Return .F.
			  	EndIf
			Endif
			Return .T.
		Else
			ApMsgStop(STR0020, STR0021) //"Conexão com o Servidor DBAccess falhou."###"Atenção: Conexão falhou"
			Return .F.
		EndIf
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} isNumeric
Funcao para verificar que uma string contém somente números
@param xValue	Conteúdo que será validado

@protected
@author  BI TEAM
@version P11
@since   15/07/2010
@parm	cValue, string, valor a ser verificado
@return lógico, se é (.T.) ou não (.F.) numérico
/*/
//-------------------------------------------------------------------
Static Function isNumeric(xValue)
	If !( valtype(xValue) == "N" )
		If !lBIIsDigit( xValue, .T. )
			ApMsgStop(STR0019) //"Campo não é numérico"
			Return .F.
		EndIf
	EndIf
Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} loadArea
Atualiza as áreas que foram selecionadas conforme armazenado na tabela HJK

@protected
@author  Marcia Junko
@version P11
@since   24/04/2014
/*/
//---------------------------------------------------------------------------------
static function loadArea()
	local aLoadArea		:= BIXLoadParam('BIX_AREAS')
	local aAreaValue	:= {}
	local nI			:= 0
	Local nPos			:= 0 

	If valtype(aLoadArea) == "A"
		aAreaValue := StrTokArr( Alltrim(aLoadArea[3]), ";" )
		
		// marca as áreas gravadas na tabela de parâmetros
		For nI := 1 To Len(aAreaValue)
			If ( nPos := Ascan( aArea, { |x| x[2] == aAreaValue[nI] })) > 0 
				aArea[ nPos ][1] := .T.
			EndIF
		Next
	EndIf
return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} validArea
Valida valores inconsistentes nas moedas para as fatos.

@protected
@author  BI TEAM
@version P11
@since   16/12/2010
@return Se .T., pelo menos uma área foi selecionada
/*/
//---------------------------------------------------------------------------------
Static Function validArea()
	Local nInd 	:= 0

	For nInd := 1 To Len(aArea)
		If aArea[nInd][1]
			Return .T.
		EndIf
	Next
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveSelArea
Função para gravar as áreas selecionadas para extração

@protected
@author  Marcia Junko
@version P11
@since   24/04/2014
@return Retorna .T. caso a gravação ocorra com susesso
/*/
//-------------------------------------------------------------------
Static Function SaveSelArea()
	Local nI	 	:= 0
	Local cSelArea 	:= "" //Áreas selecionadas
	
	cSelArea := ""
	For nI := 1 to Len(aArea)
		If aArea[nI][1]
			If Len(cSelArea) > 0
				cSelArea += ";"
			EndIf
			cSelArea += aArea[nI][2]
		EndIf
	Next

	If ( BIXLinkFSD() > 0 )
		BIXSaveParam('BIX_AREAS', cSelArea)
		BIXUnlinkFSD()
	Else
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
		Return .F.
	EndIf
Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} MarkAllList
Marca/Desmarca todas as ocorrências da lista
@param aLista	Vetor com as informações a serem marcadas
@param nPos	Posição do array que está selecionado

@protected
@author  BI TEAM
@version P11
@since   12/04/2011
/*/
//---------------------------------------------------------------------------------
Static Function MarkAllList(aLista, nPos)
	Local lMark := .F.

    aEval(aLista, {|x| iif(!x[nPos], lMark := .T.,)  })
    aEval(aLista, {|x, i| aLista[i, nPos] := lMark })
Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} loadFtMoeda
Carrega as Fatos com as moedas armazenadas na tabela de parâmetros HJK

@protected
@author  BI TEAM
@version P11
@since   11/04/2011
@return aRowsFato	Vetor com as informações das moedas por fato
/*/
//---------------------------------------------------------------------------------
static function loadFtMoeda()
	Local oTopology	:= nil
	local nCount  	:= 0
	local nMoeda	:= 0
	local cMoeda	:= 0
	local cFatMoeda	:= ""
	local aMoedas	:= BIXLoadMoeda()
	local aRegFato	:= {}
	local aSavedMoe	:= {}
	local aRowsFato	:= {}
	local lFisrtTime:= .F.
	local nPos		:= 0

 	//-------------------------------------------------------------------
	// Recupera a lista de fatos registradas. 
	//------------------------------------------------------------------- 	
	oTopology 	:= BIXTopology():New( )
	aFatos 		:= oTopology:ListEntity( FACT )
	FreeObj( oTopology )

	If ( BIXLinkFSD() > 0 )
		aSavedMoe	:= BIXGetAParam('BIX_MOEDA')
		lFisrtTime	:= Len(aSavedMoe) == 0

		//Criando as linhas de valores
		For nCount := 1 To Len(aFatos)
		   	aRegFato := {}
			AAdd(aRegFato, aFatos[nCount, 1])
			AAdd(aRegFato, aFatos[nCount, 2])
			For nMoeda := 1 To Len(aMoedas)
				If lFisrtTime
					If nMoeda == 1
						AAdd(aRegFato, .T.)
					Else
						AAdd(aRegFato, .F.)
					Endif
				Else
					nPos := AScan(aSavedMoe, {|x| x[5] == aFatos[nCount, 1]})
					If nPos > 0
						cFatMoeda := ";" + Alltrim(aSavedMoe[nPos][3]) + ";"
					Else
						cFatMoeda := ""
					EndIf
					cMoeda := ";" + Alltrim(Str(aMoedas[nMoeda, 1])) + ";"

					If cMoeda $ cFatMoeda
						AAdd( aRegFato, .T. )
					Else
						If ( Empty( cFatMoeda ) )
							AAdd( aRegFato, .T. )
						Else
							AAdd( aRegFato, .F. )
						EndIf
					Endif
				EndIf
			Next
			AAdd(aRowsFato, aClone(aRegFato))
		Next
		BIXUnlinkFSD()
	EndIf
Return aRowsFato

//---------------------------------------------------------------------------------
/*/{Protheus.doc} validFtMoeda
Valida valores inconsistentes nas moedas para as fatos.
@param aLista	Vetor com as informações das moedas

@protected
@author  BI TEAM
@version P11
@since   16/12/2010
@return Se .T. não houve inconsistências na validação
/*/
//---------------------------------------------------------------------------------
Static Function validFtMoeda(aLista)
	Local nInd 	:= 0

	For nInd := 1 To Len(aLista)
		//Todos os itens devem estar selecionados
		If AScan(aLista[nInd], .T., 3) == 0
			ApMsgStop(STR0072) //"Todas as fatos devem possuir pelo menos 1 moeda selecioanda."
			Return .F.
		EndIf
	Next
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveMoedas
Grava as moedas para as fatos.
@param aLista	Vetor com as informações das fatos por moeda

@protected
@author  BI TEAM
@version P11
@since   12/04/2011
@return Retorna .T. caso a gravação ocorra com susesso
/*/
//-------------------------------------------------------------------
Static Function SaveMoedas(aLista)
	Local nInd		:= 0
	Local nMoeda	:= 0
	Local cMoeda	:= ""
	Local aMoedas	:= BIXLoadMoeda()

	If ( BIXLinkFSD() > 0 )
		For nInd := 1 To Len(aLista)
			cMoeda := ""
			For nMoeda := 3 To Len(aLista[nInd])
				If aLista[nInd, nMoeda]
					If !Empty(cMoeda)
						cMoeda += ";"
					Endif
					cMoeda += AllTrim(Str(aMoedas[nMoeda - 2, 1]))
				EndIf
			Next
			BIXSaveParam('BIX_MOEDA', cMoeda, aLista[nInd, 1], .F.)  
		Next
		BIXUnlinkFSD()
	Else
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
		Return .F.
	EndIf
Return .T.

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ShowNextParam
Função para controle da próxima guia do wizard a ser apresentada, dependendo
das áreas que foram selecionadas anteriormente.
@param oWizard		Objeto do Wizard
@param cIDArea		Identificador da área a qual o painel pertence

@protected
@author  Marcia Junko
@version P11
@since   24/04/2014
/*/
//---------------------------------------------------------------------------------
Static Function ShowNextParam( oWizard, cIDArea )
	Default cIDArea := ""
    
	//-------------------------------------------------------------------
	// Guarda o histórico de navagação entre os painéis do wizard.  
	//-------------------------------------------------------------------  	
	If ( aScan( aPath, oWizard:nPanel + 1 ) == 0 )
		aAdd( aPath, oWizard:nPanel + 1 )   
	EndIf  

	//-------------------------------------------------------------------
	// Partindo do painel de Moedas.  
	//-------------------------------------------------------------------  	
	If Empty(cIDArea)
		Do Case
			// Se as áreas posteriores não estiverem selecionadas, habilita o botão finalizar
			Case (!aArea[Val(AREA_COM)][1] .And. !aArea[Val(AREA_FIN)][1] .And. !aArea[Val(AREA_MAT)][1] .And. ;
				!aArea[Val(AREA_PROD)][1] .And. !aArea[Val(AREA_CONTROL)][1] .And. !aArea[Val(AREA_RH)][1] .And. ;
				!aArea[Val(AREA_DL) - 1][1] .And. !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
					oWizard:SetFinish()

			// Se Comercial estiver habilitado, manda para a primeira guia da Comercial
			Case aArea[Val(AREA_COM)][1]
				oWizard:nPanel := oWizard:nPanel           

			// Se Finanças ou Materiais estiver habilitado, manda para a primeira guia da ComMatFin
			Case (aArea[Val(AREA_FIN)][1] .Or. aArea[Val(AREA_MAT)][1])
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL  
				
			// Se Controladoria estiver habilitado, manda para a primeira guia da Controladoria
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL + PARAMCOMFINMAT
				
			// Se Materiais estiver habilitado, manda para a primeira guia de Materiais.
			Case aArea[Val(AREA_MAT)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL

			// Se Produção estiver habilitado, manda para a primeira guia da Produção
			Case aArea[Val(AREA_PROD)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT
				
			// Se RH estiver habilitado, manda para a primeira guia da RH
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD

			// Se DL estiver habilitado, manda para a primeira guia de DL
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH
				
			// Se VAREJO estiver habilitado, manda para a primeira guia da VAREJO
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL
			
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL + PARAMVAREJO
		EndCase

	// Se estiver no último painel de Comercial
	ElseIf cIDArea == AREA_COM
		oWizard:nPanel := oWizard:nPanel
	
	// Se estiver no último painel da Area Comercial, Finanças ou Materiais
	Elseif cIDArea == AREACOMFINMAT
		Do Case
			// Se Controladoria estiver habilitado, manda para a primeira guia da Controladoria
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel 

			// Se somente Materiais estiver habilitado, manda para a primeira guia de Materiais.
			Case aArea[Val(AREA_MAT)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCONTROL

			// Se Produção estiver habilitado, manda para a primeira guia da Produção
			Case aArea[Val(AREA_PROD)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCONTROL + PARAMMAT 

			// Se RH estiver habilitado, manda para a primeira guia da RH
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCONTROL + PARAMMAT + PARAMPROD  

			// Se DL estiver habilitado, manda para a primeira guia de DL
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH
				
			// Se VAREJO estiver habilitado, manda para a primeira guia da VAREJO
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL
			
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL + PARAMVAREJO
		EndCase

	// Se estiver no último painel de Controladoria
	ElseIf cIDArea == AREA_CONTROL
		Do Case
			// Se somente Materiais estiver habilitado, manda para a primeira guia da Materiais
			Case aArea[Val(AREA_MAT)][1]
				oWizard:nPanel := oWizard:nPanel
				
			// Se somente Produção estiver habilitado, manda para a primeira guia da Produção
			Case aArea[Val(AREA_PROD)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMMAT 
				
			// Se somente RH estiver habilitado, manda para a primeira guia da RH
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMMAT + PARAMPROD 

			// Se DL estiver habilitado, manda para a primeira guia de DL
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMMAT + PARAMPROD + PARAMRH
				
			// Se VAREJO estiver habilitado, manda para a primeira guia da VAREJO
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL
			
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL + PARAMVAREJO
				
		EndCase
	
	// Se estiver no último painel de Materiais.
	ElseIf cIDArea == AREA_MAT
		Do Case
			// Se somente Produção estiver habilitado, manda para a primeira guia da Produção
			Case aArea[Val(AREA_PROD)][1]
				oWizard:nPanel := oWizard:nPanel 
						
			// Se somente RH estiver habilitado, manda para a primeira guia da RH
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel + PARAMPROD 

			// Se DL estiver habilitado, manda para a primeira guia de DL
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMPROD + PARAMRH 
				
			// Se VAREJO estiver habilitado, manda para a primeira guia da VAREJO
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMPROD + PARAMRH + PARAMDL
			
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMPROD + PARAMRH + PARAMDL + PARAMVAREJO
	EndCase  

	// Se estiver no último painel de Produção
	ElseIf cIDArea == AREA_PROD
		Do Case
			// Se somente RH estiver habilitado, manda para a primeira guia da RH
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel 
						
			// Se DL estiver habilitado, manda para a primeira guia de DL
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMRH 		  
				
			// Se VAREJO estiver habilitado, manda para a primeira guia da VAREJO
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMRH + PARAMDL
			
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMRH + PARAMDL + PARAMVAREJO
		EndCase
		
	// Se estiver no último painel de RH
	ElseIf cIDArea == AREA_RH
		Do Case
			// Se DL estiver habilitado, manda para a primeira guia de DL
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel
				
			// Se VAREJO estiver habilitado, manda para a primeira guia da VAREJO
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMDL
			
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel + PARAMDL + PARAMVAREJO
		EndCase

	// Se estiver no último painel de DL
	ElseIf cIDArea == AREA_DL
		Do Case						  
			// Se VAREJO estiver habilitado, manda para a primeira guia da VAREJO
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel 
			
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel  + PARAMVAREJO
		EndCase	
			
	// Se estiver no último painel de VAREJO
	ElseIf cIDArea == AREA_VAREJO
		Do Case						  
			// Se CRM estiver habilitado, manda para a primeira guia da CRM
			Case aArea[Val(AREA_CRM) - 1][1]
				oWizard:nPanel := oWizard:nPanel
		EndCase	
	EndIf 
Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ShowFinish
Função que controla se o botão Finalizar será apresentado na guia atual, caso não
existam outras áreas a serem apresetadas.
@param oWizard		Objeto do Wizard

@protected
@author  Marcia Junko
@version P11
@since   24/04/2014
/*/
//---------------------------------------------------------------------------------
Static Function ShowFinish( oWizard )
	Local nGeral 	:= CONNSTAGE + SELAREA + GENERICO //Obtem a qtde de painéis padrões para todas as areas
	Local nPanelWiz	:= oWizard:nPanel

	Do Case
		// Se estiver carregando o painel de Moedas, os parâmetros genéricos não forem solicitados e
		// as áreas posteriores não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1
			If (!aArea[Val(AREA_COM)][1] .And. !aArea[Val(AREA_FIN)][1] .And. !aArea[Val(AREA_MAT)][1] .And. ;
				!aArea[Val(AREA_PROD)][1] .And. !aArea[Val(AREA_CONTROL)][1] .And. !aArea[Val(AREA_RH)][1] .And. ;
				!aArea[Val(AREA_DL)-1][1] .And. !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
					oWizard:SetFinish()
			EndIf
	
		// Se estiver carregando o ultimo painel de ComFinMat e as áreas posteriores
		// não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1 + PARAMCOMERCIAL + PARAMCOMFINMAT					
			If (!aArea[Val(AREA_MAT)][1] .And. !aArea[Val(AREA_PROD)][1] .And. !aArea[Val(AREA_CONTROL)][1] .And. ;
				!aArea[Val(AREA_RH)][1] .And. !aArea[Val(AREA_DL) - 1][1] .And. !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
				oWizard:SetFinish()
			EndIf

		// Se estiver carregando o ultimo painel de Controladoria e as áreas posteriores
		// não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1 + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL
			If (!aArea[Val(AREA_MAT)][1] .And. !aArea[Val(AREA_PROD)][1] .And. !aArea[Val(AREA_RH)][1] .And. ;
				!aArea[Val(AREA_DL) - 1][1] .And. !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
				oWizard:SetFinish()
			EndIf
		
		// Se estiver carregando o ultimo painel de Materiais e as áreas posteriores
		// não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1 + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT
			If (!aArea[Val(AREA_PROD)][1] .And. !aArea[Val(AREA_RH)][1] .And. !aArea[Val(AREA_DL) - 1][1] .And. !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
				oWizard:SetFinish()
			EndIf

		// Se estiver carregando o ultimo painel de Produção e as áreas posteriores
		// não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1 + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD
			If (!aArea[Val(AREA_RH)][1] .And. !aArea[Val(AREA_DL) - 1][1] .And. !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
				oWizard:SetFinish()
			EndIf
			
		// Se estiver carregando o ultimo painel de RH e as áreas posteriores
		// não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1 + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH
			If (!aArea[Val(AREA_DL) - 1][1] .And. !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
				oWizard:SetFinish()
			EndIf

		// Se estiver carregando o ultimo painel de DL e as áreas posteriores
		// não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1 + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL
			If ( !aArea[Val(AREA_VAREJO) - 1][1] .And. !aArea[Val(AREA_CRM) - 1][1])
				oWizard:SetFinish()
			EndIf  
			
		// Se estiver carregando o ultimo painel de VAREJO e as áreas posteriores
		// não estiverem selecionadas, habilita o botão finalizar
		Case nPanelWiz == nGeral + 1 + PARAMCOMERCIAL + PARAMCOMFINMAT + PARAMCONTROL + PARAMMAT + PARAMPROD + PARAMRH + PARAMDL	+ PARAMVAREJO
			If ( !aArea[Val(AREA_CRM) - 1][1])
				oWizard:SetFinish()
			EndIf
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCntResult
Função que carrega os dados das Contas Resultado

@protected
@author  BI TEAM
@version P11
@since   14/06/2012
@return  vetor	Vetor com as informações da conta de resultado
/*/
//-------------------------------------------------------------------
Static Function LoadCntResult()
	Local aRet			:= {}
	Local aRetAll		:= {}
	Local aRetF		:= {}
	Local nInd			:= 0
	Local nCount		:= 0
	Local nNum			:= 0
	Local nTam			:= 0
	Local nPos			:= 0
	Local nContagem	:= 0
	Local cNome		:= ''
	
	// Retorna na variável aRet os contas de resultado do parâmetro CNTRES1
	aRet := BIXLoadParam('CNTRESULT'+ "1", "HL9")
	
	// Verificar se a variável aRet trouxe conteúdo
	If ! Empty(aRet)

		// Irá retornar todos os parâmetro CNTRES's que foram salvos
		aRetAll := BIXLoadParam('CNTRESULT', "HL9", , .T.)
		
		// Será executado até o tamanho do aRetAll retornado pela BIXLoadParam
		For nInd := 1 to Len(aRetAll)
				// Verifica se o tipo da variável é diferente de indefinido
				If ValType(aRetAll) != "U"
				
					// Verifica se a variável aRetAll é um array
					If ValType(aRetAll[nInd]) == "A"
						
						// Será salvo na variável aRet as contas de resultado separados por ";"				
						aRet := StrToKArr(aRetAll[nInd][3], ";")
						
						// A variável aRetF será carregado todos os arrays 
						// que foram carregados com a conta de resultado
						If aRetAll[nInd][1] != "CNTRESULT "
							aEval(aRet, {|x| Aadd(aRetF, x)})
						EndIf
					Else
						// Caso não for um arrey será carregado na variável aRetF a informação do aRetAll na posição nInd
						Aadd( aRetF, aRetAll[nInd])
					endIf
				Else
					aRetF := {''}
				EndIf
		Next nInd
	Else
		// Caso não retorne nada no parâmetro CNTRES1, será retornado o valor do parâmetro CNTRESULT
		aRet := BIXLoadParam('CNTRESULT', "HL9")
		If ValType(aRet) != "U"
			aRetF := StrToKArr(aRet[3], ";")
			
			// Retorna a última posição
			nTam := Len(aRetF)
			cNome := aRetF[nTam]
			
			// Verifica se a ulitma posição conta dentro do array de contas de resultado
			// Caso encontre mais de uma vez a conta de resultado com o mesmo código o 
			// código da última posição do array será excluído.
			For nPos := 1 to Len(aRetF)
				
				If aRetF[nPos] == cNome
					nContagem = nContagem + 1
				EndIf
			
			Next nPos
			
			// Caso encontrado mais de um código da conta de resultado igual ao último, 
			// será excluído.
			If nContagem > 1
				aDel (aRetf, nTam)
			EndIf 
			
		Else
			aRetF := {''}
		EndIf
	EndIf	
	
Return aRetF

//---------------------------------------------------------------------------------
/*/{Protheus.doc} ShowBackParam
Função para controle da guia anterior do wizard a ser apresentada, dependendo
das áreas que foram selecionadas anteriormente.
@param oWizard		Objeto do Wizard

@author  Valdiney V GOMES
@version P12
@since   04/07/2014
/*/
//---------------------------------------------------------------------------------
Static Function ShowBackParam( oWizard, cIDArea )
	Default cIDArea := ""     

	// Se estiver voltando da guia Comercial
	If cIDArea == AREA_COM
		oWizard:nPanel := oWizard:nPanel 

	ElseIf cIDArea == AREACOMFINMAT
		If !(aArea[Val(AREA_COM)][1])
			oWizard:nPanel := oWizard:nPanel - PARAMCOMERCIAL
		Else
			oWizard:nPanel := oWizard:nPanel
		EndIf		
	
	// Se estiver voltando da guia de Controladoria
	ElseIf cIDArea == AREA_CONTROL
		Do Case
			// Se não selecionou as áreas genéricas, volta para a guia de moedas
			Case !(aArea[Val(AREA_COM)][1] .Or. aArea[Val(AREA_FIN)][1] .Or. aArea[Val(AREA_MAT)][1] )
				oWizard:nPanel := oWizard:nPanel - PARAMCOMERCIAL - PARAMCOMFINMAT
			
			// Se não selecionou as áreas financeira ou materiais, volta para a guia comercial
			Case ( aArea[Val(AREA_COM)][1] )
				oWizard:nPanel := oWizard:nPanel
		EndCase
		
	// Se estiver voltando da guia de Materiais.
	ElseIf cIDArea == AREA_MAT
		Do Case				
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel
				
			Case aArea[Val(AREA_FIN)][1] .Or. aArea[Val(AREA_MAT)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMCONTROL
				
			Case aArea[Val(AREA_COM)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMCONTROL - PARAMCOMFINMAT
			
			Otherwise
				oWizard:nPanel := oWizard:nPanel - PARAMCONTROL - PARAMCOMERCIAL - PARAMCOMFINMAT
		End Case   

	// Se estiver voltando da guia de Produção.
	ElseIf cIDArea == AREA_PROD
		Do Case
			Case aArea[Val(AREA_MAT)][1]  
				oWizard:nPanel := oWizard:nPanel
										
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMMAT
				
			Case aArea[Val(AREA_FIN)][1] .Or. aArea[Val(AREA_MAT)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMMAT - PARAMCONTROL
				
			Case aArea[Val(AREA_COM)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMMAT - PARAMCONTROL
			
			Otherwise
				oWizard:nPanel := oWizard:nPanel - PARAMMAT - PARAMCONTROL - PARAMCOMERCIAL - PARAMCOMFINMAT
		End Case   


	// Se estiver voltando da guia de RH
	ElseIf cIDArea == AREA_RH
		Do Case
			Case aArea[Val(AREA_PROD)][1]  
				oWizard:nPanel := oWizard:nPanel
						
			Case aArea[Val(AREA_MAT)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMPROD
				
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMPROD - PARAMMAT
				
			Case aArea[Val(AREA_FIN)][1] .Or. aArea[Val(AREA_MAT)][1] 
				oWizard:nPanel := oWizard:nPanel - PARAMPROD - PARAMMAT - PARAMCONTROL
				
			Case aArea[Val(AREA_COM)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMPROD - PARAMMAT - PARAMCONTROL
			
			Otherwise
				oWizard:nPanel := oWizard:nPanel - PARAMPROD - PARAMMAT - PARAMCONTROL - PARAMCOMERCIAL - PARAMCOMFINMAT
		End Case

	// Se estiver voltando da guia de DL
	ElseIf cIDArea == AREA_DL
		Do case
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel 
				
			Case aArea[Val(AREA_PROD)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMRH
				
			Case aArea[Val(AREA_MAT)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMRH - PARAMPROD
	
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMRH - PARAMPROD - PARAMMAT
			
			Case aArea[Val(AREA_FIN)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL

			Case aArea[Val(AREA_COM)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL

			Otherwise
				oWizard:nPanel := oWizard:nPanel - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL - PARAMCOMERCIAL - PARAMCOMFINMAT
		End Case
		
	// Se estiver voltando da guia de Varejo
	ElseIf cIDArea == AREA_VAREJO
		Do case
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel 
		
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMDL 

			Case aArea[Val(AREA_PROD)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMDL - PARAMRH
							
			Case aArea[Val(AREA_MAT)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMDL - PARAMRH - PARAMPROD
				
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT
				
			Case aArea[Val(AREA_FIN)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL
			
			Case aArea[Val(AREA_COM)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL

			Otherwise
				oWizard:nPanel := oWizard:nPanel - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL - PARAMCOMERCIAL - PARAMCOMFINMAT
		End Case
		
	// Se estiver voltando da guia de CRM
	ElseIf cIDArea == AREA_CRM
		Do case
			Case aArea[Val(AREA_VAREJO) - 1][1]
				oWizard:nPanel := oWizard:nPanel  
		
			Case aArea[Val(AREA_DL) - 1][1]
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO
		
			Case aArea[Val(AREA_RH)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO - PARAMDL 

			Case aArea[Val(AREA_PROD)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO - PARAMDL - PARAMRH
							
			Case aArea[Val(AREA_MAT)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO - PARAMDL - PARAMRH - PARAMPROD
					
			Case aArea[Val(AREA_CONTROL)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT
			
			Case aArea[Val(AREA_FIN)][1]  
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL
			
			Case aArea[Val(AREA_COM)][1]
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL

			Otherwise
				oWizard:nPanel := oWizard:nPanel - PARAMVAREJO - PARAMDL - PARAMRH - PARAMPROD - PARAMMAT - PARAMCONTROL - PARAMCOMERCIAL - PARAMCOMFINMAT
		End Case
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveCntRes
Função que grava o conteúdo das contas de resultado
@param aCntResult	Vetor com as informações das contas de resultado

@protected
@author  BI TEAM
@version P11
@since   14/06/2012
@return lógico	Retorna .T. caso a gravação ocorra com susesso
/*/
//-------------------------------------------------------------------
Static Function SaveCntRes(aCntResult)
	Local nInd		:= 0
	Local cContas	:= ""
	Local nCount	:= 1
	
	If ( BIXLinkFSD() > 0 )
	
		For nInd := 1 To Len(aCntResult)
			If len(cContas + AllTrim(aCntResult[nInd])) < 240  
				cContas += AllTrim(aCntResult[nInd]) + ";"
			Else
				BIXSaveParam('CNTRESULT'+alltrim(Str(nCount)) , cContas, "HL9", .F.)
				nCount++
				cContas := ""
				nInd := nInd - 1
			EndIf
		Next nInd
		
		BIXSaveParam('CNTRESULT'+alltrim(Str(nCount)) , cContas, "HL9", .F.)

		BIXUnlinkFSD()
			
	Else
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} loadFaixa
Carrega os valores salvos na tabela de parãmetros
@param cIDParam		ID do Parâmetro
@param cPicture		Picture a ser utilizada
@param nDec			Qtde de decimais a ser utilizada

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return Vetor	Vetor com as informações das faixas
/*/
//-------------------------------------------------------------------
static function loadFaixa(cIDParam, cPicture, nDec)
	local aRetFaixa		:= {{ STR0030 + " 1", "0", "" }, { STR0030 + " 2", "", "" }, { STR0030 + " 3", "", "" }, { STR0030 + " 4", "", "" }, { STR0030 + " 5", "", "" }}
	local aLoadFaixa	:= BIXLoadParam(cIDParam)
	local aFaixaValue	:= {}
	local nCount		:= 0
	local cAux			:= ""

	default cPicture := "@E 99"
	default nDec := 0

	If valtype(aLoadFaixa) == "A"
		If !Empty(aLoadFaixa)
			aFaixaValue := StrTokArr( aLoadFaixa[3], ";" )
	
			// compara o array de faixas do banco com o array de faixas a ser exibido
			For nCount := 1 To Len(aRetFaixa)
				// preenche o valor inicial da faixa
				If nCount > 1
					cAux := iif(len(aFaixaValue) >= nCount, aFaixaValue[nCount], "" )
					aRetFaixa[nCount, 2] := iif(empty(cAux), space(len(transform(0, cPicture))), bixPrepLoad(cAux, cPicture, nDec))
				Endif
	
				// preenche o valor final da faixa
				cAux := iif(len(aFaixaValue) >= (nCount + 1), aFaixaValue[nCount + 1], "")
				aRetFaixa[nCount, 3] := iif(empty(cAux), space(len(transform(0, cPicture))), bixPrepLoad(cAux, cPicture, nDec))
			Next
		Endif
	EndIf
return aRetFaixa

//-------------------------------------------------------------------
/*/{Protheus.doc} bixPrepLoad
Função que prepara os dados para carga
@param cValue  	Valor a ser transformado.
@param cPict	Picture a ser utilizada
@param nDec		Qtde de decimais a ser utilizada

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return cTransf	Informação formatada
/*/
//-------------------------------------------------------------------
static function bixPrepLoad( cValue, cPict, nDec )
	local nInd 		:= 0
	local cTransf 	:= ""

	nValue := bixValNoDec(cValue)

	for nInd := 1 to nDec
		nValue := nValue / 10
	next

	if nValue != 0
		cTransf := transform( nValue, cPict )
	else
		cTransf := "0"
	endif
return cTransf

//-------------------------------------------------------------------
/*/{Protheus.doc} bixValNoDec
Função que transforma um caracter em número inteiro
@param cValue  	Valor a ser transformado.

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return Numérico Valor inteiro
/*/
//-------------------------------------------------------------------
Static Function bixValNoDec(cValue)
	Local cAux := ""

	cAux := StrTran(cValue, ".", "")
	cAux := StrTran(cAux, ",", "")
Return Val(cAux)

//-------------------------------------------------------------------
/*/{Protheus.doc} validFaixa
Valida valores inconsistentes na faixa de valores
@param aFaixas 	Vetor com as informações das faixas
@param nDec		Qtde de decimais a ser utilizada

@protected
@author  BI TEAM
@version P11
@since   16/12/2010
@return lógico	Se .T. a faixa de valores está íntegra
/*/
//-------------------------------------------------------------------
static function validFaixa( aFaixa, nDec )
	Local lRet := .T.
	Local nCount := 0

	Default nDec := 0

	For nCount := 1 To Len( aFaixa )
		If !Empty( aFaixa[nCount][3] )
			lRet := !Empty( aFaixa[nCount][2] )

			lRet := lRet .And. ( bixVal(aFaixa[nCount][3], nDec) > bixVal(aFaixa[nCount][2], nDec) )

			If !lRet
				ApMsgStop(STR0033) //"Faixa de valores inválida."
				Exit
			EndIf
		EndIf
	Next
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} bixVal
Função que transforma ums string em número, considerando a quantidade
de decimais informada.
@param cValue  	Valor a ser transformado.
@param nDec		Qtde de decimais a ser utilizada

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return nValue	Valor calculado
/*/
//-------------------------------------------------------------------
Static Function bixVal( cValue, nDec )
	Local nValue := 0
	Local nInd	 := 0

	Default nDec := 0

	nValue := bixValNoDec(cValue)

	For nInd := 1 To nDec
		nValue := nValue / 10
	Next
Return nValue

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveFaixa
Função para gravar as faixa de valores
@param aFaixas 		Vetor com as informações das faixas
@param cIDParam  	ID do parâmetro
@param nDec			Qtde de decimais que será utilizada

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return lógico	Retorna .T. caso a gravação ocorra com susesso
/*/
//-------------------------------------------------------------------
static function SaveFaixa(aFaixas, cIDParm, nDec)
	Local cTemp := ""
	Local nInd

	For nInd := 1 To Len(aFaixas)
		If !Empty(aFaixas[nInd][3])
			cTemp += ";" + bixPrepSave( aFaixas[nInd][3], nDec )
		Else
			Exit
		Endif
	Next

	cTemp := "0" + cTemp

	BIXSaveParam(cIDParm, cTemp)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} bixPrepSave
Função que prepara os dados para gravação na base de dados
@param cValue  	Valor a ser transformado.
@param nDec		Qtde de decimais a ser utilizada

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return string 	Informação a ser gravada
/*/
//-------------------------------------------------------------------
static function bixPrepSave( cValue, nDec )
	Local nValue 	:= 0
	Local cTransf 	:= ""

	Default nDec := 0

	nValue := bixValNoDec(cValue)
	cTransf := AllTrim( Str( nValue ) )

	If nDec > 0
		cTransf := Substr( cTransf, 1, Len(cTransf) - nDec ) + "." + Right(cTransf, nDec)
	EndIf
Return cTransf

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEditCbCell
Edita uma célula de um objeto TCBrowse (ComboBox)

@protected
@param oBrowse 	Objeto TCBrowse
@param aBrowse 	Array bidimensional com os valores das células
@param cPict 	Máscara do campo
@param cAlias 	Consulta para uso em F3
@param bValid 	Valid do campo editável
@param cType 	Tipo do dado
@param nDec		Qtde de decimais
@author  BI TEAM
@version P11
@since   17/09/2010
/*/
//-------------------------------------------------------------------
Function BIXEditCbCell(oBrowse, aBrowse, cPict, cAlias, bValid, cType, nDec)
	local oDlg 		:= NIL
	local oBtn 		:= NIL
	local oRect 	:= NIL
	local oGet 		:= NIL
	local nColumn 	:= oBrowse:ColPos()
	local nLine 	:= oBrowse:nAt
	local aColumn 	:= oBrowse:aColumns[ oBrowse:ColPos() ]
	local lF3 		:= .F.
	local lValid 	:= .F.

	private xValGet := ""

	default bValid := {|| .T.}
	default cType := "C"
	default cPict := ""
	default nDec := 0

	if valtype(cAlias) == "C"
		lF3 := .T.
	endif

	//Verifica se a célula é editável
	if !aColumn:lEdit
		return .F.
	endif

	oRect := tRect():New( 0, 0, 0, 0 )
	oBrowse:GetCellRect( nColumn, nLine, oRect )

	if cType == "N"
		xValGet := bixVal(aBrowse[nLine][nColumn], nDec)
	else
		xValGet := aBrowse[nLine][nColumn]
	endif


	DEFINE MSDIALOG oDlg FROM 0,0 TO 0,0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL WINDOW oBrowse:oParent

		oGet := TGet():Create(oDlg,,,,,, cPict,,,,,,,,,,,,,,,, cAlias,,,,, lF3 )

		oGet:Move(-2, -2, ( oRect:nRight - oRect:nLeft ) + iif(lF3, -20, 4), oRect:nBottom - oRect:nTop + 4 )
		oGet:bsetGet :={|x| if(PCount() > 0, xValGet := x, xValGet)}

		oGet:bValid := {|| lValid := Eval(bValid, xValGet), lValid}

		@10, 0 BUTTON oBtn PROMPT "ZE" OF oDlg
		oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

		oDlg:Move( oRect:nTop, oRect:nLeft, oRect:nRight - oRect:nLeft, oRect:nBottom - oRect:nTop )

	ACTIVATE MSDIALOG oDlg

	if lValid
		if cType == "N"
			if !Empty(xValGet)
				aBrowse[nLine][nColumn] := transform(xValGet, cPict)
			else
				aBrowse[nLine][nColumn] := space( len( transform(0, cPict) ) )
			endif
		else
			aBrowse[nLine][nColumn] := xValGet
		endif
	endif

	oBrowse:DrawSelect()   
return

//-------------------------------------------------------------------
/*/{Protheus.doc} updFx
Ajusta valor inicial da faixa seguinte, baseado no valor final da faixa atual
@param aFaixas 	Vetor com as informações das faixas
@param oBrowse 	Objeto TCBrowse
@param cPict 	Picture a ser utilizada

@protected
@author  BI TEAM
@version P11
@since   16/12/2010
@return lRet	Se .T. é um conteúdo numérico
/*/
//-------------------------------------------------------------------
Static Function UpdFx(aFaixas, oBrowse, cPict)
	Local lRet	:= .T.
	Local nLen	:= Len(aFaixas)
	Local nAt	:= oBrowse:nAt

	If !Empty(xValGet)
		lRet := isNumeric(xValGet) //verifica se conteúdo é numérico
	EndIf

	If lRet .AND. nAt < nLen
		If valtype(xValGet) == "N"
			If Empty(xValGet)
				aFaixas[nAt + 1][2] := Space( Len( Transform( 0, cPict ) ) )
			Else
				aFaixas[nAt + 1][2] := Transform( xValGet, cPict )
			EndIf
		Else
			aFaixas[nAt + 1][2] := xValGet
		EndIf
		oBrowse:refresh()
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetGrupos
Retorna um array com os grupos de saldos existentes para atualização
do ComboBox de inclusão de grupos de saldo.

@param aInfos, Array,	Vetor com os grupos de saldos armazenados na tabela HJK
@param nType, Integer, Grupo de Saldo ou Macroregião.

@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
@return Vetor	Vetor com os grupos de saldo existentes
/*/
//-------------------------------------------------------------------
Static Function RetGrupos( aInfos, nType )
	Local aRet := {}
	Local nX   := 0

	Default nType := 1

	If ValType(aInfos) == "A"
		If Len( aInfos ) > 0
			If nType == 1
				For nX := 1 To Len(aInfos)
					aAdd( aRet , SubStr(aInfos[nX][3] , 1 , At(";" , aInfos[nX][3]) - 1 ) )
				Next nX
			Else
				For nX := 1 To Len(aInfos)
					aAdd( aRet , Alltrim(aInfos[nX] ) )
				Next nX
			EndIf	
		EndIf
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} updLists
Atualiza as informações nas duas ListBox da tela de inclusão de grupos de saldos.
@param oCombo	Combobox do grupo de saldo
@param aTipos	Vetor com os tipos de saldo
@param oListDir	Listbox com os itens selecinados
@param cComboT	Texto apresentado no combobox
@param oListEsq	Listbox com os itens não selecinados

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
/*/
//-------------------------------------------------------------------
Static Function updLists( oCombo, aTipos, oListDir, cComboT, oListEsq, nType )
	Local cCombo := Iif(oCombo:nAt <> 0 , oCombo:aItems[oCombo:nAt] , IIf(Len(oCombo:aItems) <> 0, oCombo:aItems[1], "") )
	Local aInfos := {}

	Default nType := 1

	If nType == 1
		aInfos := BIXLoadParam( 'BIX_GRPSLD' , , .T. )
		If cTaCombo <> ""
			cCombo := cTaCombo
		EndIf
	Else
		aInfos := BIXLoadMRInfo()
		If cMRCombo <> ""
			cCombo := cMRCombo
		EndIf
	EndIf

	oListDir:SetArray( updListRight( @oListDir , @cCombo , @aInfos , @aTipos, nType ) )
	oListDir:Refresh()

	oListEsq:SetArray( updListLeft(  @oListDir , @cCombo , @aInfos , @aTipos, nType ) )
	oListEsq:Refresh()


	If nType == 1
		cTaCombo := ""
	Else
		cMRCombo := ""
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} updListRight
Retorna um array para a função updLists() com o conteudo que será
atualizado na ListBox Direita
@param oListDir	Listbox com os itens selecinados
@param cCombo	Texto apresentado no combo
@param aInfos	Vetor com os grupos de saldo armazenados na tabela HJK
@param aTipos	Vetor com os tipos de saldo

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
@return Vetor	Vetor com os itens que foram selecionados
/*/
//-------------------------------------------------------------------
Static Function updListRight( oListDir , cCombo , aInfos , aTipos, nType )
	Local aItensDir := {}
	Local xAux      := {}
	Local nX		:= 0
	Local nY		:= 0

	default nType := 1

	If nType == 1
		For nX := 1 to Len(aInfos)
			If AllTrim( SubStr( aInfos[nX][3], 1 , At(";" , aInfos[nX][3]) - 1 ) ) == AllTrim(cCombo)
				xAux := StrTokArr(SubStr(aInfos[nX][3], At(";",aInfos[nX][3]) + 1) , ";")
				For nY := 1 To Len(xAux)
					If aScan( aTipos , AllTrim(xAux[nY]) + " -") <> 0
						aAdd( aItensDir , aTipos[aScan( aTipos , AllTrim(xAux[nY]) + " -")])
					EndIf
				Next nY
			EndIf
		Next nX
	Else
		For nX := 1 to Len(aInfos)
			If AllTrim( aInfos[nX][1] ) == AllTrim(cCombo)
				xAux := StrTokArr(aInfos[nX][3], ";")
				For nY := 1 To Len(xAux)
					If aScan( aTipos , AllTrim(xAux[nY]) + " -") <> 0
						aAdd( aItensDir , aTipos[aScan( aTipos , AllTrim(xAux[nY]) + " -")])
					EndIf
				Next nY
			EndIf
		Next nX
	EndIf
Return aItensDir

//-------------------------------------------------------------------
/*/{Protheus.doc} updListLeft
Retorna um array para a função updLists() com o conteudo que será
atualizado na ListBox Esquerda
@param oListEsq	Listbox com os itens não selecinados
@param cCombo	Texto apresentado no combo
@param aInfos	Vetor com os grupos de saldo armazenados na tabela HJK
@param aTipos	Vetor com os tipos de saldo

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
@return Vetor	Vetor com os itens que não foram selecionados
/*/
//-------------------------------------------------------------------
Static Function updListLeft( oListEsq , cCombo , aInfos , aTipos, nType )
	Local aRet 		:= {}
	Local aUsados 	:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local nPos		:= 2

	Default nType := 1

	Iif( nType == 2, nPos := 1, )

	For nX := 1 To Len( aInfos )
		aRet := StrTokArr(aInfos[nX][3] , ";")
		For nY := nPos To Len(aRet)
			aAdd( aUsados , aRet[nY] )
		Next nY
	Next nX

	aRet := {}

	For nX := 1 To Len(aTipos)
		If aScan( aUsados , SubStr(aTipos[nX], 0, 2) ) == 0
			aAdd( aRet , AllTrim(aTipos[nX]) )
		EndIf
	Next nX
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdCombo
Função que atualiza o ComboBox de grupos após a inclusão de um novo grupo de saldo.
@param oCombo	Combobox de grupo de saldo
@param aItens	Vetor com as informações apresentadas no combo
@param cGet		Texto que será inserido no combo
@param cCombo	Texto apresentado no combo
@param aValids	Vetor de validação dos grupos de saldo

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
/*/
//-------------------------------------------------------------------
Static Function UpdCombo(oCombo , aItens, cGet, cCombo, aValids, nType, cAux, lInsert )
	Default nType 	:= 1
	Default cAux  	:= ""
	Default lInsert := .T.

	If nType == 1
		cTaCombo := AllTrim(cGet)
		aAdd(aValids, AllTrim(cGet))
	Else
		cMRCombo := AllTrim(cGet)
		If lInsert
			aAdd(aValids, {AllTrim(cGet), cAux})
		Else
			aValids[oCombo:nAt][2] := cAux
		EndIf
	EndIf

	If lInsert
		aAdd(aItens, AllTrim(cGet))
		oCombo:SetItems(lessRepeated(aItens))
		cCombo := AllTrim(cGet)
		oCombo:Refresh()
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} lessRepeated
Retira as repetições do array de grupos de saldo.
@param aItens	Vetor com as informações apresentadas no combo

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   20/05/2013
@return Vetor	Vetor que será apresentado no combo de grupo de saldo
/*/
//-------------------------------------------------------------------
Static Function lessRepeated(aItens)
	Local aAux 	:= aClone(aItens)
	Local nX	:= 0
	Local nY	:= 0

	For nX := 1 To Len(aItens)
		cTeste := AllTrim(aItens[nX])
		For nY := 1 To Len(aItens)
			If nX <> nY
				If cTeste == aItens[nY]
					ADel(aAux , nY)
					ASize(aAux, Len(aAux) - 1)
				EndIf
			EndIf
		Next nY
		If Len(aItens) <> Len(aAux)
			Exit
		EndIf
	Next nX
Return aAux

//-------------------------------------------------------------------
/*/{Protheus.doc} delInfo
Deleta o Grupo de Saldo
@param oCombo	Combobox do grupo de saldo
@param aItens	Vetor com as informações apresentadas no combo
@param cCombo	Texto apresentado no combo
@param aValids	Vetor de validação dos grupos de saldo

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
/*/
//-------------------------------------------------------------------
Static Function delInfo( oCombo , aItens , cCombo, aValids, nType )
	Local aInfo  := {}

	Local aCombo := {}
	Local lDel   := .F.
	Local nX  	 := 0
	Local nPos	 := 0
	Local cItem	 := cCombo

	Default nType := 1

	If nType == 1
		aInfo := BIXLoadParam( 'BIX_GRPSLD' , , .T. )
	Else
		aInfo := BIXLoadMacroReg()
	EndIf

	If !Empty(cCombo)
		For nX := 1 To Len(aInfo)
			If nType == 1
				If AllTrim(oCombo:aItems[ iif(oCombo:nAt == 0, oCombo:nAt + 1, oCombo:nAt) ]) == SubStr(aInfo[nX][3] , 0 , At(";" , aInfo[nX][3]) - 1 )
					lDel := .T.
				EndIf
			Else
				If AllTrim(oCombo:aItems[ iif(oCombo:nAt == 0, oCombo:nAt + 1, oCombo:nAt) ]) == Alltrim(aInfo[nX])
					lDel := .T.
				EndIf
			EndIf
		Next nX

		If Len(aInfo) == 0 .AND. Len(aItens) <> 0
			If MsgYesNo(STR0134 , STR0107) //"Confirmar a exclusão?"###"Confirmar"
				aCombo := aItens
				aDel(aCombo , oCombo:nAt )
				aSize(aCombo, Len(aCombo) - 1)

				aDel(aValids , oCombo:nAt )
				aSize(aValids, Len(aValids) - 1)

				If Len(aCombo) == 0
					aCombo := {""}
					aValids := {}
					oCombo:SetItems(aCombo)
				Else
					oCombo:SetItems(aCombo)
					cCombo := aCombo[Len(aCombo)]
				EndIf

				oCombo:Refresh()
			EndIf
		ElseIf MsgYesNo(STR0134, STR0107) //"Confirmar a exclusão?"###"Confirmar"
		   	retPosCombo(@oCombo, cCombo, aInfo, nType)

			If lDel
				If nType == 1
					BIXDelGrpParam( .T. , aInfo[ iif(oCombo:nAt == 0, oCombo:nAt + 1, oCombo:nAt)][6] )

					aInfo    := BIXLoadParam( 'BIX_GRPSLD' , , .T. )
				Else
					BIXDelMacroReg( cItem )

					aInfo := BIXLoadMacroReg()
				EndIf
				aCombo := RetGrupos( aInfo, nType )

				If Len(aCombo) == 0
					aCombo := {""}
					aValids := {}
				Else
					aValids := aClone(aCombo)
				EndIf
			Else
				aCombo := oCombo:aItems
				If oCombo:nAt > 0
					aDel(aCombo , oCombo:nAt)
					aSize(aCombo, Len(aCombo) - 1)
				EndIf

				If nType == 1
					aValids := aClone(aCombo)
				Else
					nPos := Ascan( aValids, {|x| x[1] == cItem})
					If  nPos > 0
						aDel(aValids, nPos)
						aSize(aValids, Len(aValids) - 1)
					EndIf
				EndIf
			EndIf
			oCombo:SetItems(aCombo)
			oCombo:Refresh()
		EndIf
	Else
		ApMsgAlert(STR0125) //"Não existem grupos de saldo."
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} retPosCombo
Retorna a posição correta do item do combo, caso não seja possível atualizar por refresh.
@param oCombo	Combobox do grupo de saldo
@param cCombo	Texto apresentado no combo
@param aGrps	vetor com as informações dos grupos de saldo

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
/*/
//-------------------------------------------------------------------
Static Function retPosCombo(oCombo , cCombo , aGrps, nType)
	Local aItems := aClone(aGrps)
	Local nInd   := 0
	Local aAux   := {}

	default nType := 1

	If Len(aItems) != Len(oCombo:aItems)
		oCombo:aItems := {}

		For nInd := 1 To Len(aItems)
			If nType == 1
				aAdd(aAux, SubStr(aGrps[nInd][3], 1, At(";", AllTrim(aGrps[nInd][3])) - 1))
			Else
				aAdd(aAux, aGrps[nInd])
			EndIf
		Next nInd

		oCombo:SetItems(aAux)

		For nInd := 1 To Len(aItems)
			If nType == 1
				If AllTrim(cCombo) == SubStr(aGrps[nInd][3], 1, At(";", AllTrim(aGrps[nInd][3])) - 1)
					oCombo:nAt := nInd
				EndIf
			Else
				If AllTrim(cCombo) == aGrps[nInd]
					oCombo:nAt := nInd
				EndIf
			EndIf
		Next nInd
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} moveTpSld
Função para movimentação de um tipo de saldo de um listbox para o outro.
@param cTipo	Tipo de movimentação a ser feita
@param lTodos	Define se a ação afetará todos os registros ou somente o registro selecionado
@param oListTps	Listbox com os tipos de saldo não selecionados
@param oListEsc	Listbox com os tipos de saldo selecionados
@param aTpsEsq	Vetor com os tipos de saldo não selecinados
@param aTpsDir	Vetor com os tipos de saldo selecinados

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   13/03/2013
/*/
//-------------------------------------------------------------------
Static Function moveTpSld( cTipo , lTodos , oListTps , oListEsc , aTpsEsq , aTpsDir  )
	Local nPos  := 0
	Local nCont := 0

	If cTipo == "1"
		If lTodos
			aTpsDir := oListEsc:aItems
			aTpsEsq := oListTps:aItems
			For nCont := 1 To oListTps:Len()
				aAdd( aTpsDir , aTpsEsq[nCont] )
			Next nCont
			aTpsEsq := {}

			oListTps:SetArray(aTpsEsq)
			oListTps:Refresh()
			oListEsc:SetArray(aTpsDir)
			oListEsc:Refresh()
		Else
			If Len(oListTps:aItems) <> 0
				nPos := oListTps:GetPos()
				aTpsDir := oListEsc:aItems
				If nPos <> 0
					aAdd( aTpsDir , oListTps:GetSelText() )
					oListEsc:SetArray( aTpsDir )
					oListEsc:Refresh()

					aTpsEsq := oListTps:aItems
					aDel(aTpsEsq , nPos)
					aSize(aTpsEsq , Len(aTpsEsq) - 1 )
					oListTps:SetArray( aTpsEsq )
					oListTps:Refresh()
				Else
					ApMsgAlert(STR0113) //"Selecione um item para mover!"
				EndIf
			EndIf
		EndIf
	ElseIf cTipo == "2"
		If lTodos
			aTpsDir := oListEsc:aItems
			aTpsEsq := oListTps:aItems
			For nCont := 1 To oListEsc:Len()
				aAdd( aTpsEsq , aTpsDir[nCont] )
			Next nCont
			aTpsDir := {}

			oListTps:SetArray(aTpsEsq)
			oListTps:Refresh()
			oListEsc:SetArray(aTpsDir)
			oListEsc:Refresh()
		Else
			If Len(oListEsc:aItems) <> 0
				nPos := oListEsc:GetPos()
				If nPos <> 0
					aAdd( aTpsEsq , oListEsc:GetSelText() )
					oListTps:SetArray( aTpsEsq )
					oListTps:Refresh()

					aTpsDir := oListEsc:aItems
					aDel(aTpsDir , nPos)
					aSize(aTpsDir , Len(aTpsDir) - 1 )
					oListEsc:SetArray( aTpsDir )
					oListEsc:Refresh()
				Else
					ApMsgAlert(STR0113) //"Selecione um item para mover!"
				EndIf
			EndIf
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IsAccountMarked 
Identifica se uma conta de apuração de resultado está selecionada. 
     
@param aMark
@return lMarked

@author  Valdiney V GOMES 

@version P11
@since   04/02/2014

/*/
//-------------------------------------------------------------------   
Static Function IsAccountMarked( aMark )
	Local nWhere 	:= aScan( aMark, {|x| AllTrim( x[1] ) == AllTrim(  CT1->CT1_CONTA ) } )
    Local lMarked 	:= .F.   
         
	If ! ( nWhere == 0 )
		lMarked := aMark[nWhere][2]
	EndIf  
Return lMarked  

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAccount  
Seleciona uma conta de apuração de resultado. 

@param aMark

@author  Valdiney V GOMES 

@version P11
@since   04/02/2014

/*/
//------------------------------------------------------------------- 
Static Function MarkAccount( aMark, aCntResult )
	Local nWhere 	:= aScan( aMark, {|x| AllTrim( x[1] ) == AllTrim(  CT1->CT1_CONTA ) } )
    Local lMarked 	:= .F. 
    Local nAccount	:= 1 
    
	//-------------------------------------------------------------------
	// Permite seleção apenas de contas analíticas. 
	//-------------------------------------------------------------------                               
 	If ( CT1->CT1_CLASSE == '2' )  
 		//-------------------------------------------------------------------
		// Identifica a operação realizada. 
		//-------------------------------------------------------------------  
		If ! ( nWhere == 0 )   
			aMark[nWhere][2] := ! aMark[nWhere][2]
		Else
			aAdd( aMark, { CT1->CT1_CONTA, .T. } )
		EndIf  

	 	//-------------------------------------------------------------------
		// Guarda as contas selecionadas. 
		//------------------------------------------------------------------- 
		aCntResult := {}
				
   		For nAccount := 1 To Len( aMark ) 
   			If ( aMark[nAccount][2] )
   		 		aAdd( aCntResult, AllTrim( aMark[nAccount][1] ) )
 			EndIf 
   		Next 
   	Else
   		MsgInfo( STR0192, STR0089 ) //"Contas de apuração de resultado"###"Apenas contas analíticas devem ser selecionadas!" 		
	EndIf  
Return Nil 

       
//-------------------------------------------------------------------
/*/{Protheus.doc} Comercial
Exive os parâmetros da área comercial  

@param oPanel		Painel onde os objetos serão criados
@param aPeriod		Parametros que serão atualizados. 

@author  Valdiney V GOMES
@version P11
@since   25/06/2014
/*/
//-------------------------------------------------------------------
Static Function Comercial( oPanel, aPeriod )  
	Local oSayCarteira 		:= Nil 
	Local oSpinCarteira		:= Nil 
	Local oSayEntrega 		:= Nil
	Local oSayDupl 			:= Nil 
	Local oSayEstoque 		:= Nil  
	Local oSpinEntrega 		:= Nil
	Local oCheckDevolucao	:= Nil 
	Local oDupl				:= Nil
	Local oEst					:= Nil

	oSayCarteira 	:= tSay():new(5, 10, {|| STR0218 }, oPanel, , , , , , .T., , , 240, 15) //"Carteira de Vendas - Número máximo de meses que os pedidos de venda em aberto devem ser considerados:"
	oSpinCarteira := tSpinBox():new(3, 255, oPanel, {|x| aPeriod[1][2] := x }, 35, 13)
	oSpinCarteira:setRange(24, 120)
   	oSpinCarteira:setStep(1)
   	oSpinCarteira:setValue( aPeriod[1][2] )
    
   	oSayEntrega 	:= tSay():new(30, 10, {|| STR0230 }, oPanel, , , , , , .T., , , 240, 15) //"Entregas de Vendas - Número máximo de meses que os pedidos de venda liberados devem ser considerados:"
   	oSpinEntrega 	:= tSpinBox():new(25, 255, oPanel, {|x| aPeriod[2][2] := x }, 35, 13)
   	oSpinEntrega:setRange(2, 120)
   	oSpinEntrega:setStep(1)
   	oSpinEntrega:setValue( aPeriod[2][2] )
   	
   	@ 053, 010 CHECKBOX oRepres VAR aPeriod[3][2] PROMPT STR0248 OF oPanel SIZE 400, 020 PIXEL //"Indica se o representante será obtido através do cadastro do cliente, ao invés dos dados da nota/pedido."   
   	
   	oSayDupl	:= tSay():new(70, 10, {|| STR0253 + " - " + STR0254 }, oPanel, , , , , , .T., , , 240, 15) //"Faturamento"###"Considerar notas em que a TES gera duplicata"
	@ 70, 255 COMBOBOX oDupl VAR aPeriod[4][2] ITEMS { STR0256, STR0257, STR0258 }  SIZE 35, 9 OF oPanel PIXEL //"Sim"###"Não"###"Ambos"
	   	
   	oSayEstoque	:= tSay():new(90, 10, {|| STR0253 + " - " + STR0255 }, oPanel, , , , , , .T., , , 240, 15) //"Faturamento"###"Considerar notas em que a TES movimenta o estoque"
	@ 90, 255 COMBOBOX oEst VAR aPeriod[5][2] ITEMS { STR0256, STR0257, STR0258}  SIZE 35, 9 OF oPanel PIXEL //"Sim"###"Não"###"Ambos"

  	@ 110, 010 CHECKBOX oCheckDevolucao VAR aPeriod[6][2] PROMPT STR0264 + " - " + STR0265 OF oPanel SIZE 400, 020 PIXEL //"Devolução de Vendas"###"Considerar documentos de entrada do tipo devolução com cliente diferente do documento de saída." 
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadComercial
Carrega os parâmetros da área comercial.  

@Return aParameters Parâmetros que serão atualizados.  

@author  Valdiney V GOMES
@version P11
@since   25/06/2014
/*/
//-------------------------------------------------------------------
Static Function LoadComercial()
	Local aParameters		:= {}  
	Local aCarteira		:= BIXLoadParam( 'BIX_PVENDA' )
	Local aEntrega		:= BIXLoadParam( 'BIX_EVENDA' )
	Local lRepres			:= LoadRepres()
	Local cDupl			:= LoadComboOption( 'BIX_TESDUP' )
	Local cEstoque		:= LoadComboOption( 'BIX_TESEST' )
	Local lIgnoreClient	:= BIXParInfo( 'BIX_DEVVEN', "L", .F. )
	
	aAdd( aParameters, { 'BIX_PVENDA'	, If( aCarteira == Nil, 0, nBIVal( aCarteira[3] ) ) } ) 
	aAdd( aParameters, { 'BIX_EVENDA'	, If( aEntrega == Nil, 0, nBIVal( aEntrega[3] ) ) } )
	aAdd( aParameters, { 'BIX_REPRES'	, lRepres } )   	
	aAdd( aParameters, { 'BIX_TESDUP'	, cDupl } )
	aAdd( aParameters, { 'BIX_TESEST'	, cEstoque } )
	aAdd( aParameters, { 'BIX_DEVVEN'	, lIgnoreClient } )
Return aParameters  

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveComercial
Grava os parâmetros da área comercial.   

@Param aPeriod	 Parâmetros e valores que serão atualizados. 

@author  Valdiney V GOMES
@version P11
@since   25/06/2014
/*/
//-------------------------------------------------------------------
Static Function SaveComercial( aPeriod )
	Local nParameter := 0
	Local nOpcao	 := 0	
	
	If ! ( BIXLinkFSD() == 0 )
		For nParameter := 1 To Len( aPeriod )
			IF "BIX_TES" $ aPeriod[nParameter][1]
				IF aPeriod[nParameter][2] == STR0256 //"Sim"
					nOpcao := 1
				ElseIF aPeriod[nParameter][2] == STR0257 //"Não"
					nOpcao := 2
				Else
					nOpcao := 3
				EndIf
				
				BIXSaveParam( aPeriod[nParameter][1], cBIStr( nOpcao ), , .F.)
				
			ElseIf aPeriod[nParameter][1] <> 'BIX_REPRES'  
				BIXSaveParam( aPeriod[nParameter][1], cBIStr( aPeriod[nParameter][2] ), , .F.)
			Else
				BIXSaveParam('BIX_REPRES', Iif(aPeriod[nParameter][2], "S", ""), , .F. )	
			EndIf  
		Next nParameter
		
		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return   
         

//-------------------------------------------------------------------
/*/{Protheus.doc} vldNewGrp
Valida se existe grupo de saldo no combo que não foi gravado.
@param aValids	Vetor de validação dos grupos de saldo
@param nType	Define qual o tipo de conteúdo está sendo manipulado
				[1] - grupo de saldo
				[2] - países

@protected
@author  BI TEAM ~ Felipe Lopes
@version P11
@since   22/03/2013
@return Se .T. não houve inconsistências na validação
/*/
//-------------------------------------------------------------------
Static Function VldNewGrp( aValids, nType )
	Local aInfos    := {}
	Local aAux 		:= {}
	Local nInd      := 0
	Local cMsg		:= ""

	Default nType := 1

	If Empty(aValids)
		Return .T.
	EndIf

	If nType == 1
		aInfos  := BIXLoadParam( 'BIX_GRPSLD' , , .T. )
		cMsg 	:= STR0120 //"Foi incluído um novo grupo de saldo. Confirme a inclusão através do botão."

		For nInd := 1 To Len(aInfos)
			AAdd( aAux , SubStr(aInfos[nInd][3], 1, At(";" , aInfos[nInd][3]) - 1 ) )
		Next nInd
	Else
		aInfos	:= BIXLoadMRInfo()
		cMsg	:= STR0169 //"Foi incluído uma nova macro região. Confirme a inclusão através do botão."

		aAux := aClone(aInfos)
	EndIf

	If Len(aValids) > Len(aAux)
		ApMsgAlert(cMsg)
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PersGenerico
Função que grava o conteúdo dos parâmetros genéricos.  
@Param lCliReg		Indica se os dados do cliente serão considerados na dimensão região geográfica.

@author  Marcia Junko 
@version P12
@since   27/11/2014

/*/
//-------------------------------------------------------------------
Static Function PersGenerico( lCliReg, lCompEmp )
	If ! ( BIXLinkFSD() == 0 )
    	BIXSaveParam('BIX_CLIREG', Iif(lCliReg, "S", ""), , .F. )
    	BIXSaveParam('BIX_CMPEMP', Iif(lCompEmp, "S", ""), , .F. )

    	BIXUnlinkFSD()
  	Else
    	ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
  	EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCMoeda
Função que carrega o conteúdo do parâmetro BIX_CMOEDA
@return lCMoeda Define se a chave de negócio considerará somente o identificador principal da Dimensao Moeda

@protected
@author  Paulo V. Beraldo
@version P11
@since   05/11/2013
/*/
//-------------------------------------------------------------------
Function LoadCMoeda()
  	Local lRet 	:= .F.
  	Local aRet 	:= {} 
          
	aRet := BIXLoadParam( 'BIX_CMOEDA' )

  	If ( aRet <> Nil )
    	If !Empty( aRet[3] )
      		lRet := .T.
    	EndIf
  	EndIf 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WzConsMoeda
Painel para configuração da consolidação de moedas
@param oPanel	Painel onde os componentes serão criados
@param aCMoeda	Vetor com as informações de código de moeda da consolidação
@param lCMoeda	Define a utilização da chave de negócio consolidada para a moeda
@param oTcMoeda	Browse da configuração de códigos da moeda

@protected
@author  Paulo V. Beraldo
@version P11
@since   05/11/2013
/*/
//-------------------------------------------------------------------
Function WzConsMoeda( oPanel, aCMoeda, lCMoeda, oTcMoeda )
  	local lRet        := .T.
  	local oCMoeda     := Nil
  	local bDupClick   := {|| IIf( lCMoeda, BixEditCBCell( oTcMoeda, aCMoeda, '@!', nil, {|| .T. }, 'C' ), .F. ) }

  	@005, 010 CHECKBOX oCMoeda VAR lCMoeda PROMPT STR0157  On Click( WzSetEdt( lCMoeda, @oTcMoeda, @oPanel, @aCMoeda, @bDupClick ) ) OF oPanel SIZE 250, 009 PIXEL //"Consolidar a chave da dimensÒo MOeda?"

  	oTcMoeda := LoadGetCMoeda( oPanel, aCMoeda, lCMoeda, bDupClick )
  	oTcMoeda:CallRefresh()
  	oPanel:Refresh()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WzSetEdt
Função responsavel por validar se a Opcao de Moeda Consolidada Esta Ativa e Habilita a Get de De/Para.
@param lCMoeda	 Define a utilização da chave de negócio consolidada para a moeda
@param oTcMoeda	 Browse da configuração de códigos da moeda
@param oPanel	 Painel onde os componentes serão criados
@param aCMoeda	 Vetor com as informações de código de moeda da consolidação
@param bDupClick Bloco de código acionado no duplo click da célula

@protected
@author  Paulo V. Beraldo
@version P11
@since   05/11/2013
/*/
//-------------------------------------------------------------------
Function WzSetEdt( lCMoeda, oTcMoeda, oPanel, aCMoeda, bDupClick )
  	Local nInd := 0
  	Local nCount := 0

  	If !lCMoeda
    	For nInd := 1 To Len( oTcMoeda:AArray )
      		For nCount := 1 To Len( oTcMoeda:AColumns )
        		aCMoeda[ nInd ][ nCount ] := Eval( oTcMoeda:AColumns[ nCount ]:bData )
        		oTcMoeda:AArray[ nInd ][ nCount ] := aCMoeda[ nInd ][ nCount ]
      		Next nCount
    	Next nInd
  	EndIf

  	oTcMoeda:Refresh()
  	oPanel:Refresh()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGetCMoeda
Função responsável por montar o grid de consolidação de moedas
@param oPanel	 Painel onde os componentes serão criados
@param aCMoeda	 Vetor com as informações de código de moeda da consolidação
@param lCMoeda	 Define a utilização da chave de negócio consolidada para a moeda
@param bDupClick Bloco de código acionado no duplo click da célula

@protected
@author  Paulo V. Beraldo
@version P11
@since   06/11/2013
@return oTcMoeda	Objeto do grid de consolidação de moedas
/*/
//-------------------------------------------------------------------
Function LoadGetCMoeda( oPanel, aCMoeda, lCMoeda, bDupClick )
	local oTcMoeda    := Nil
  	local nCount      := 0
  	local aMoedas     := BIXLoadMoeda()
  	local bFalseBlock	:= { || .F. }
  
  	oTcMoeda := MsBrGetDBase():New( 23, 10, 285, 80,,,, oPanel,,,,,,,,,,,, .F., "", .T.,, .F.,,, )

	// Cria colunas do browse    
  	For nCount := 1 To Len( aMoedas )
    	oTcMoeda:AddColumn(  TcColumn():New( cValToChar( nCount ) +'-'+ aMoedas[nCount, 2] ,&('{ || VldCodMoeda( oTcMoeda, aCMoeda, ' + cValToChar( nCount ) + ', lCMoeda ) }' ),,,,"LEFT",,.F.,.T.,,,,.F., ) )//aCMoeda[ oTcMoeda:nAt ][ '+ cValToChar( nCount ) +' ]
  	Next nCount
 
  	oTcMoeda:SetArray( aCMoeda ) //Adicionando as linhas

  	oTcMoeda:blDblClick := bDupClick // Evento de duplo click na celula

  	//Tratamento para Nao permitir que o Usuario Marque a linha da Get como Deletada.  
  	oTcMoeda:bDelOk	:= bFalseBlock
  	oTcMoeda:bSuperDel:= bFalseBlock
Return oTcMoeda


//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodMoeda    
Função Responsavel por validar o conteudo informado na TcBrowse
@param oTcMoeda	  Browse da configuração de códigos da moeda
@param aCMoeda	  Vetor com as informações de código de moeda da consolidação
@param nPosColumn Coluna que foi acionada no browse

@protected
@author  Paulo V. Beraldo
@version P11
@since   06/11/2013
@return cRet Retorna o conteudo existente para a celula
/*/
//-------------------------------------------------------------------
Function VldCodMoeda( oTcMoeda, aCMoeda, nPosColumn, lCMoeda )
	local cRet    := ""
	local aMoedas := {}
	local nTamHH1 := 10

	aMoedas := BIXLoadMoeda()
	
	If nPosColumn == oTcMoeda:nColPos
		cRet := IIf( Empty( aCMoeda[ oTcMoeda:nAt, oTcMoeda:nColPos ] ), cValToChar( aMoedas[ Ascan( aMoedas, { | x | x[ 01 ]  == nPosColumn } ) ][ 01 ] ), aCMoeda[ oTcMoeda:nAt, oTcMoeda:nColPos ] )
		If Len( oTcMoeda:aArray ) > 0
			oTcMoeda:aArray[ oTcMoeda:nAt ][ oTcMoeda:nColPos ] := Padr( cRet, nTamHH1 )
		EndIf
	Else
		cRet := IIf( Empty( aCMoeda[ oTcMoeda:nAt, nPosColumn ] ), cValToChar( aMoedas[ Ascan( aMoedas, { | x | x[ 01 ]  == nPosColumn } ) ][ 01 ] ) , aCMoeda[ oTcMoeda:nAt, nPosColumn ] )
		If Len( oTcMoeda:aArray ) > 0
			oTcMoeda:aArray[ oTcMoeda:nAt ][ nPosColumn ] := Padr( cRet, nTamHH1 )
		EndIf
	EndIf
	
Return( Padr( cRet, nTamHH1 ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadACMoeda
Função Responsavel por Identificar se Existe De/Para cadastrado na 
base e retornar as informacoes.
@return aRetMoeda Vetor com as informações das chaves utilizadas na consolidação de moedas.

@protected
@author  Paulo V. Beraldo
@version P11
@since   07/11/2013
/*/
//-------------------------------------------------------------------
Function LoadACMoeda()
  	Local nInd       := 0
  	Local aAux       := {}
  	Local aRetMoeda  := {}
  	Local aMoeda     := BIXLoadMoeda()
  	Local lCMoeda    := LoadCMoeda()
  	Local cHH1Alias  := GetNextAlias()
  	
  	//---------------------------------------------------
  	// Efetua criação da tabela de consolidação de moedas.
  	//---------------------------------------------------
  	If ! ( BIXLinkFSD() < 0 )
  		BIXSetupTable( "HH1" )
  		BIXUnlinkFSD()  		
  	EndIf

  	If !lCMoeda
    	For nInd := 1 To Len( aMoeda )
      		Aadd( aAux, "          " ) //Moeda com 10 posições
    	Next nInd
    	Aadd( aRetMoeda, AClone( aAux ) )
  	Else
    	If BIXLinkFSD() < 0
      		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
      		lRet := .F.
    	Else
      		dbUseArea(.T., __cRdd, "HH1" , cHH1Alias , .T., .F.)
      		( cHH1Alias )->( dbSetIndex( "HH11" ) )

      		dbSelectArea( cHH1Alias )
      		( cHH1Alias )->( dbSetOrder( 1 ) )

      		( cHH1Alias )->( dbGoTop() )
      		( cHH1Alias )->( dbEval( { || Aadd( aAux, ( cHH1Alias )->HH1_CODCON ) },,{ || ( cHH1Alias )->( !Eof() ) .And. ( cHH1Alias )->HH1_FILIAL == xFilial( 'HH1')  } ) )
      		Aadd( aRetMoeda, AClone( aAux ) )

      		IIf( Select( cHH1Alias ) > 0, ( cHH1Alias )->( dbCloseArea() ), Nil )
      		BIXUnlinkFSD()
    	EndIf
  	EndIf
  	
Return aRetMoeda

//-------------------------------------------------------------------
/*/{Protheus.doc} PersCMoeda
Função que grava a configuração da consolidação de moedas
@param aCMoeda	Vetor com as informações de código de moeda da consolidação
@param lCMoeda	Define a utilização da chave de negócio consolidada para a moeda

@protected
@author  Marcia Junko / Paulo V. Beraldo
@version P11
@since   23/09/2013
@return lógico  Retorna .T. caso a gravação ocorra com susesso
/*/
//------------------------------------------------------------------- 
Static Function PersCMoeda( aCMoeda, lCMoeda )
  	Local lRet    := .F.

  	If !( BIXLinkFSD() == 0 )
    	BIXGrvCMoeda( aCMoeda, lCMoeda )   
    	BIXSaveParam( 'BIX_CMOEDA', Iif(lCMoeda, "S", ""), , .F. )
    	BIXUnlinkFSD()
    	lRet := .T.
  	Else
    	ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
    	lRet := .F.
  	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} wzVldCMoeda
Função que realiza a validacao dos campos da GetDados de De/Para nao estao vazios com
a opcao de chave consolidada habilitada.

@param lCMoeda,  boolean, Define se a chave de consolidacao de Moedas esta habilitada.
@param oTcMoeda, object,  MsBrGetDBase com as informacoes de De/Para de Moeda.
@param aCMoeda	,  array,   Vetor com as informações de código de moeda da consolidação

@author  Paulo V. Beraldo
@since   08/11/2013
@return lógico  Retorna .T. caso o preenchimento dos parametros esteja correto
/*/
//-------------------------------------------------------------------
Static Function wzVldCMoeda( lCMoeda, oTcMoeda, aCMoeda )
  	Local lRet    := .T.
  	Local lEmpty  := .F.
  	Local lEqual  := .F.
  	Local nInd    := 0
  	Local nPosMda := 0
  	Local nCount  := 0
  	Local aAuxMda := {}
  	Local aPosMda := {}

	If !lCMoeda
		lRet := .T.
	Else
		For nInd := 1 To Len( oTcMoeda:AArray )
			For nCount := 1 To Len( oTcMoeda:AColumns )
				If !Empty( oTcMoeda:AArray[ nInd ][ nCount ] )
					lEmpty := .F.
					Exit
				Else
					lEmpty := .T.
					lRet   := .F.
				EndIf
			Next nCount
		Next nInd
	
		If !lEmpty
			aAuxMda := AClone( oTcMoeda:AArray )
			For nInd := 1 To Len( oTcMoeda:AArray )
				For nCount := 1 To Len( oTcMoeda:AColumns )
					If Empty( AllTrim( oTcMoeda:AArray[ nInd ][ nCount ] ) )
						Loop
					Else
						nPosMda := Ascan( aPosMda, { | x | AllTrim( x[ 1 ] ) == AllTrim( oTcMoeda:AArray[ nInd ][ nCount ] ) } )
						If nPosMda == 0
							Aadd( aPosMda, { AllTrim( oTcMoeda:AArray[ nInd ][ nCount ] ) , 1 } )
						Else
							aPosMda[ nPosMda ][ 02 ] += 1
							lEqual := .T.
							lRet   := .F.
						EndIf
					EndIf
				Next nCount
			Next nInd
		EndIf
	EndIf

	//--------------------------------------------------------------------------------
	// Caso haja alguma inconsistência no preenchimentos das moedas, 
	// não é possível salvar os dados, nem ao menos passar para a próxima tela.
	//--------------------------------------------------------------------------------
  	If lRet
  		PersCMoeda( aCMoeda, lCMoeda )
  	Else
  		If lEmpty
			ApMsgStop( STR0160 + CRLF + CRLF + STR0161 ) //"A opção de Chave Consolidada de Moedas foi habilitada e por este motivo é obrigatório o preenchimento da tabela de De / Para de Moedas."###"Se não deseja preencher o De/Para, desabilite a opção de Consolidação de Moedas."
		Else
			ApMsgStop( STR0162 + CRLF + CRLF + STR0163 ) //"Existem códigos duplicados na Tabela de De/Para."###"Realize a alteração antes de prosseguir com a configuração."
		EndIf  			
  	EndIf
Return lRet         
              
//-------------------------------------------------------------------
/*/{Protheus.doc} wzdMacroReg
Painel que permite a configuração dos Grupos de Saldos
@param oPanel	Painel onde os dados serão apresentados
@param aValids	Vetor de validação dos grupos de saldo

@protected
@author  Marcia Junko
@version P11
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Function wzdMacroReg( oPanel, aVldReg )
	Local oPaises 	:= Nil
	Local oPaisesSel:= Nil
	Local oBut1 	:= Nil
	Local oBut2 	:= Nil
	Local oBut3 	:= Nil
	Local oBut4		:= Nil
	Local oCombo    := Nil
	Local oPaisEsq	:= Nil
	Local oPaisDir	:= Nil
	Local aPaises   := ListPaises(.T.)				// Vetor com a lista de países disponíveis
	Local aInfos    := BIXLoadMacroReg( @aVldReg ) 	//Vetor com as macro regiões armazenados na tabela HQF
	Local aPaisesSel   := {} 						//Vetor com os paises selecionados para a macro região
	Local aItens    := aClone(aInfos)
	Local cCombo  	:= "" 							//Texto apresentado no combobos
	Local cPaisEsq	:= Space(25)
	Local cPaisDir	:= Space(25)
	Local nTpsEsq	:= 1
	Local nTpsDir 	:= 1
	Local nX		:= 1

	If Len(aItens) <> 0
		cCombo := aItens[1]
	EndIf

	@ 005, 015 SAY STR0170 OF oPanel SIZE 80, 10 PIXEL //"Macro Região"
	@ 016, 015 COMBOBOX oCombo VAR cCombo ITEMS aItens SIZE 100, 020 OF oPanel ;
		ON CHANGE ( UpdLists(@oCombo , ListPaises() , @oPaisesSel , @cCombo, @oPaises, 2) ) PIXEL

	DEFINE SBUTTON FROM 005, 150 TYPE 4 ENABLE ACTION  RetMacroReg(oCombo:aItems, @oCombo, @cCombo, @aVldReg ) OF oPanel ONSTOP STR0092 // "Adicionar"
	@ 006, 185 SAY STR0171 OF oPanel SIZE 100, 10 PIXEL //"Adicionar Macro Região"

	DEFINE SBUTTON FROM 015, 150 TYPE 11 ENABLE ACTION  RetMacroReg(oCombo:aItems, @oCombo, @cCombo, @aVldReg, .F. ) OF oPanel ONSTOP STR0185 // "Alterar"
	@ 016, 185 SAY STR0186 OF oPanel SIZE 100, 10 PIXEL //"Alterar Macro Região"

	DEFINE SBUTTON FROM 025, 150 TYPE 3 ENABLE ACTION  delInfo(@oCombo , oCombo:aItems, @cCombo, @aVldReg, 2 ) OF oPanel ONSTOP STR0093 // "Remover"
	@ 026, 185 SAY STR0172 OF oPanel SIZE 100, 10 PIXEL //"Excluir Macro Região"

	DEFINE SBUTTON FROM 035, 150 TYPE 1 ENABLE ACTION  BIXVldMR( @oCombo, oPaisesSel, aInfos, @aPaisesSel, aVldReg ) OF oPanel ONSTOP STR0107 // "Confirmar"
	@ 036, 185 SAY STR0110 OF oPanel SIZE 100, 10 PIXEL //"Confirmar a gravação?"

	@ 050, 015 SAY STR0173 OF oPanel SIZE 100, 10 PIXEL //"Países disponíveis: "
	@ 050, 175 SAY STR0174 OF oPanel SIZE 100, 10 PIXEL //"Países utilizados na macro região:"

	@ 060, 015 GET oPaisEsq VAR cPaisEsq PICTURE "@!" OF oPanel SIZE 110,009 PIXEL
	oPaisEsq:bLostFocus := {|| FindInList( oPaises:aItems, @cPaisEsq, @oPaises, @oPaisEsq )}

	@ 075, 015 LISTBOX oPaises VAR nTpsEsq ITEMS aPaises SIZE 110, 60  OF oPanel PIXEL

	@ 060, 175 GET oPaisDir VAR cPaisDir PICTURE "@!" OF oPanel SIZE 110,009 PIXEL
	oPaisDir:bLostFocus := {|| FindInList( oPaisesSel:aItems, @cPaisDir, @oPaisesSel, @oPaisDir )}

	@ 075, 175 LISTBOX oPaisesSel VAR nTpsDir ITEMS aPaisesSel SIZE 110, 60  OF oPanel PIXEL

    @ 065, 130 BUTTON oBut3 PROMPT ">" SIZE 40, 10 PIXEL OF oPanel ACTION ( moveTpSld("1", .F., @oPaises, @oPaisesSel, @aPaises, @aPaisesSel, .F.) )
    @ 075, 130 BUTTON oBut4 PROMPT ">>" SIZE 40, 10 PIXEL OF oPanel ACTION ( moveTpSld("1", .T., @oPaises, @oPaisesSel, @aPaises, @aPaisesSel, .F. ) )
    @ 085, 130 BUTTON oBut2 PROMPT "<" SIZE 40, 10 PIXEL OF oPanel ACTION ( moveTpSld("2", .F., @oPaises, @oPaisesSel, @aPaises, @aPaisesSel, .F.) )
    @ 095, 130 BUTTON oBut1 PROMPT "<<" SIZE 40, 10 PIXEL OF oPanel ACTION ( moveTpSld("2", .T., @oPaises, @oPaisesSel, @aPaises, @aPaisesSel, .F.) )

	If Len(oCombo:aItems) <> 0
		updLists(@oCombo , ListPaises() , @oPaisesSel , @cCombo, @oPaises, 2)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCountry
Função que carrega a relação de países cadastrados na SYA
@param lDisp	Define se retorna somente os países disponíveis

@protected
@author  Marcia Junko
@version P11
@since   14/11/2013
@return Vetor com a relação de países cadastrados na SYA
/*/
//-------------------------------------------------------------------
Static Function ListPaises( lDisp )
	Local aPaises	:= LoadCountry()
	Local aMacroReg	:= BIXLoadMRInfo()
	Local aRet		:= {}
	Local nI 		:= 0

	Default lDisp := .F.

	For nI := 1 to len(aPaises)
		If !lDisp .Or. (lDisp .And. Ascan(aMacroReg, {|x| Alltrim(aPaises[nI][1]) $ Alltrim(x[3]) }) == 0)
			AAdd(aRet, aPaises[nI][1] + ' - ' + aPaises[nI][2] )
		Endif
	Next
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadSYAReg
Função que carrega a relação de países cadastrados na SYA

@protected
@author  Marcia Junko
@version P12
@since   14/11/2013
@return Vetor com a relação de países cadastrados na SYA
/*/
//-------------------------------------------------------------------
Static Function LoadCountry()
	Local cQuery	:= ""
	Local cRetAlias := GetNextAlias()
	Local aPaises	:= {}

	cQuery := "SELECT YA_CODGI, YA_DESCR FROM " + RetSqlName("SYA") + " WHERE YA_FILIAL = '" + ;
		xFilial("SYA") + "' and D_E_L_E_T_ = ' ' ORDER BY YA_DESCR"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRetAlias, .T., .F.)

	While (cRetAlias)->(!Eof())
		AAdd(aPaises, {(cRetAlias)->YA_CODGI, (cRetAlias)->YA_DESCR })

		(cRetAlias)->(DbSkip())
	End

	(cRetAlias)->(DBCloseArea())
Return aPaises

//-------------------------------------------------------------------
/*/{Protheus.doc} FindInList
Função para pesquisar um conteúdo dentro de uma listbox.
@param aInfo	Vetor contendo as informações.
@param cItem	Valor a ser pesquisado.
@param oList	Objeto da Listbox.
@param oGet		Objeto do campo de pesquisa.

@protected
@author  Marcia Junko
@version P11
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Static Function FindInList( aInfo, cItem, oList, oGet)
	Local nPos := 0
	Local nLen := Len(Alltrim(cItem))

	nPos := Ascan( aInfo, {|x| Substr(x, 7, nLen) == Alltrim(cItem)})

	If nPos > 0
		oList:nAt := nPos
		oList:Refresh()

		cItem := Space(25)
		oGet:Refresh()
	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetMacroReg
Monta a tela para inclusão de uma nova macro região
@param aItens	Vetor com as informações apresentadas no combo
@param oCombo	Combobox de grupo de saldo
@param cCombo	Texto apresentado no combo
@param aValids	Vetor de validação da macro região
@param lInsert	Define se a função foi chamada pelo botão de inclusão

@protected
@author  Marcia Junko
@version P11
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Static Function RetMacroReg( aItens , oCombo , cCombo, aValids, lInsert )
	Local oDlg 	:= Nil
	Local oSigla:= Nil
	Local oDesc	:= Nil
	Local cSigla:= Space(10)
	Local cDesc	:= Space(40)

	Default lInsert := .T.

	If !lInsert
		If Empty(aValids)
			ApMsgAlert(STR0187) //"Não existem macro regiões cadastradas."
			Return
		EndIf
		cSigla	:= aValids[oCombo:nAt][1]
		cDesc	:= aValids[oCombo:nAt][2]
	Endif

	DEFINE MSDIALOG oDlg TITLE STR0175 FROM 050, 050 TO 160, 530 PIXEL //"Informações da Macro Região"

		@ 005, 005 SAY STR0176 OF oDlg SIZE 40, 10 PIXEL //"Sigla: "
		@ 005, 040 MSGET oSigla VAR cSigla SIZE 040, 010 PICTURE "@!" WHEN lInsert PIXEL OF oDlg

		@ 020, 005 SAY STR0177 OF oDlg SIZE 60, 10 PIXEL //"Descrição: "
		@ 020, 040 MSGET oDesc VAR cDesc SIZE 200, 010 PICTURE "@!" PIXEL OF oDlg

		DEFINE SBUTTON FROM 040, 180 TYPE 1 ENABLE ACTION  iif( VldMacroReg(cSigla, cDesc , @oCombo, lInsert), (UpdCombo(@oCombo, @aItens, @cSigla, @cCombo, @aValids, 2, cDesc, lInsert ) , oDlg:End()),) OF oDlg ONSTOP STR0107 // "Adicionar"
		DEFINE SBUTTON FROM 040, 210 TYPE 2 ENABLE ACTION  oDlg:End() OF oDlg ONSTOP STR0116 // "Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMacroReg
Valida a inclusão de uma nova macro região
@param cSigla 	Sigla da Macro Região
@param cDesc	Descrição da Macro Região
@param oCombo	Combobox
@param lInsert	Define se a função foi chamada pelo botão de inclusão

@protected
@author  Marcia Junko
@version P11
@since   14/11/2013
@return lógico	Se .T. não houve inconsistências na validação.
/*/
//-------------------------------------------------------------------
Static Function VldMacroReg( cSigla, cDesc, oCombo, lInsert )
	If Empty(cSigla)
		ApMsgAlert(STR0178) //"Insira uma sigla para a macro região."
		Return .F.
	EndIf

	If Empty(cDesc)
		ApMsgAlert(STR0179) //"Insira uma descrição para a macro região."
		Return .F.
	EndIf

	If lInsert
		If aScan( oCombo:aItems , AllTrim(cSigla) ) <> 0
			ApMsgAlert(STR0180) //"Esta sigla já está sendo utilizada."
			Return .F.
		EndIf
	Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVldMR
Salva a Macrorregião
@param oCombo	    Combobox
@param oListSel	Listbox com os itens selecinados
@param aInfosT	    Vetor com as macro regiões armazenados na tabela HQF
@param aSave	    Vetor com os países a serem gravados
@param aValids	    Vetor com as informações da macro região

@author  Marcia Junko
@version P11
@since   14/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXVldMR( oCombo , oListSel , aInfosT , aSave, aValids  )
	Local nX     := 0
	Local nPos   := 0
	Local cSigla := ""
	Local cDesc  := ""
	Local cSave  := ""
	Local aInfos := {}
	Local lNew   := .F.
	Local lOk    := .T.

	If Len(oCombo:aItems) <> 0 .And. !Empty(aValids)
		cCombo := oCombo:aItems[oCombo:nAt]
		nPos   := Ascan(aValids, {|x| x[1] == cCombo})
		cDesc  := aValids[nPos][2]

		aInfos := iif( oCombo:nAt > Len(aInfosT) , aInfosT , aInfosT[oCombo:nAt])
		lNew   := iif( oCombo:nAt > Len(aInfos) , .T. , .F. )

		If Len(oListSel:aItems) == 0
			lOk := .F.
		EndIf

		If lOk
			If MsgYesNo(STR0110 , STR0107) //"Confirmar a gravação?"###"Confirmar"
				BIXSaveMacroReg( cCombo, cDesc, aSave)
			EndIf
		Else
			ApMsgAlert(STR0181 + STR0182) //"Não há países selecionados para esta macro região."###" Caso queira inutilizar esta macro região, utilize o botão de exclusão."
		EndIf
	Else
		ApMsgAlert(STR0183 + STR0184) //"Não existem macro regiões configuradas."###" Insira uma macro região através do botão 'Adicionar Macro Região'"
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadMacroReg
Carrega as configurações da macro região definida pelo usuário e gera
o vetor de controle, caso necessário.
@param aValids	Armazena as informações que estão gravadas na
				tabela HQF para controle

@author		Marcia Junko
@version 	P11
@since   	14/11/2013
@return 	Vetor com as siglas da macro regiões para mostrar no combo
/*/
//-------------------------------------------------------------------
function BIXLoadMacroReg( aValids )
	Local cQuery	:= ""
	Local cRetAlias := GetNextAlias()
	Local aMacroReg	:= {}
	Local aArea		:= GetArea()
	Local lValid	:= .F.

	Default aValids := Nil

	If BIXLinkFSD() < 0
		return {}
	EndIf

	BIXSetupTable("HQF")

	If Valtype(aValids) != "U"
		lValid	:= .T.
	EndIf

	cQuery := "SELECT HQF_MACREG, HQF_MACDES FROM HQF WHERE D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cRetAlias, .T., .F. )

	While (cRetAlias)->(! EoF() )
		aAdd( aMacroReg , (cRetAlias)->HQF_MACREG )

		If lValid
			aAdd( aValids, {(cRetAlias)->HQF_MACREG, (cRetAlias)->HQF_MACDES} )
		EndIf
		(cRetAlias)->( DbSkip() )
	End

	(cRetAlias)->( DBCloseArea() )
	BIXUnlinkFSD()
	RestArea(aArea)
return aMacroReg

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadMRInfo
Retorna as informações da macro regiões cadastradas na HQF

@author		Marcia Junko
@version 	P11
@since   	14/11/2013
@return 	Vetor com as macro regiões cadastradas
/*/
//-------------------------------------------------------------------
function BIXLoadMRInfo()
	Local cQuery	:= ""
	Local cRetAlias := GetNextAlias()
	Local aRet	:= {}
	Local aArea		:= GetArea()

	If BIXLinkFSD() < 0
		return
	EndIf

	BIXSetupTable("HQF")

	cQuery := "SELECT HQF_MACREG, HQF_MACDES, HQF_PAISES, R_E_C_N_O_ FROM HQF WHERE D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cRetAlias, .T., .F. )

	While (cRetAlias)->(! EoF() )
		aAdd( aRet , {(cRetAlias)->HQF_MACREG, (cRetAlias)->HQF_MACDES, (cRetAlias)->HQF_PAISES, (cRetAlias)->R_E_C_N_O_} )

		(cRetAlias)->( DbSkip() )
	End

	(cRetAlias)->( DBCloseArea() )
	BIXUnlinkFSD()
	RestArea(aArea)
return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSaveMacroReg
Grava as configurações da macro região definida pelo usuário.

@author  Marcia Junko
@version P11
@since   14/11/2013
@param cSigla		Sigla da macro região
@param cDescMacro	Descrição da macro região
@param aPaisesSel	Vetor com os paises selecionados para compor a macro região
@return nil
/*/
//-------------------------------------------------------------------
function BIXSaveMacroReg( cSigla, cDescMacro, aPaisesSel)
	Local nX		:= 0
	Local nAt		:= 0
	Local cPaises	:= ""
	Local cFilial	:= Space(FWSizeFilial())

	If ( ! BIXLinkFSD() == 0 )
		If ( ! Empty( cSigla ) .And. ! Empty( cDescMacro ) .And. ! Empty( aPaisesSel ) )
			nAt := At(" - ", aPaisesSel[1]) - 1
		
			For nX := 1 To Len(aPaisesSel)
				cPaises += SubStr(AllTrim(aPaisesSel[nX]) , 1 , nAt) + ";"
			Next nX
		
			cPaises := SubStr(cPaises , 1 , Len(cPaises) - 1 )
			
			//--------------------------------------------------------
			// Abre tabela HQF.
			//--------------------------------------------------------
			BIXSetupTable("HQF")
		
			dbUseArea(.T., "TOPCONN", "HQF", "HQF", .T., .F.)
		
			HQF->( dbSetIndex("HQF1") )
			HQF->( dbSetOrder(1) )
		
			If !(HQF->( dbSeek( cFilial + cSigla) ))
				RecLock( "HQF", .T. )
				HQF->HQF_FILIAL := cFilial
				HQF->HQF_MACREG := cSigla
			Else
				RecLock( "HQF", .F. )
			EndIf
		
			HQF->HQF_MACDES	:= cDescMacro
			HQF->HQF_PAISES	:= cPaises
			
			//--------------------------------------------------------
			// Libera o registro locado.
			//--------------------------------------------------------
			HQF->( MSUnlock() )
			
			//--------------------------------------------------------
			// Fecha área HQF.
			//--------------------------------------------------------
			HQF->( dbCloseArea() )
		EndIf
		
		BIXUnlinkFSD()
	EndIf
return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDelMacroReg
Exclui as configurações da macro região informada

@author  Marcia Junko
@version P11
@since   14/11/2013
@param   cSigla		Sigla da macro região
@return  nil
/*/
//-------------------------------------------------------------------
function BIXDelMacroReg( cSigla )
	Local aArea 	:= getArea()
	Local cFilial	:= Space(FWSizeFilial())

	If BIXLinkFSD() < 0
		Return
	EndIf

	BIXSetupTable("HQF")

	dbUseArea(.T., "TOPCONN", "HQF", "HQF", .T., .F.)

	HQF->( dbSetIndex("HQF1") )
	HQF->( dbSetOrder(1) )

	If HQF->(DBSeek(cFilial + cSigla))
		RecLock("HQF")
			HQF->( DBDelete() )
		MSUnlock()
	EndIf

	HQF->( dbCloseArea() )
	BIXUnlinkFSD()

	restArea( aArea )
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} wzdPeriodDL
Carrega os períodos específicos de fatos do DL.   

@param oPanel		Painel onde os objetos serão criados
@param aPeriod		Parametros que serão atualizados. 

@author  Valdiney V GOMES
@version P12
@since   17/03/2014
/*/
//-------------------------------------------------------------------
Static Function wzdPeriodDL( oPanel, aPeriod )  
	Local oSayIntRec 	:= Nil 
	Local oSayDtOcio 	:= Nil 
	Local oSpinIntRec 	:= Nil 
	Local oSpinDtOcio 	:= Nil 

	oSayIntRec 	:= tSay():new(5, 10, {|| STR0194 }, oPanel, , , , , , .T., , , 240, 15) //"Recebimento de Notas Fiscais de Clientes - Número máximo de meses, além do período de extração, para buscar notas recebidas mas ainda pendentes de expedição:"
    oSpinIntRec := tSpinBox():new(3, 255, oPanel, {|x| aPeriod[1][2] := x }, 30, 13)
    oSpinIntRec:setRange(0, 1000)
    oSpinIntRec:setStep(1)
    oSpinIntRec:setValue( aPeriod[1][2] )

	oSayDtOcio 	:= tSay():new(30, 10, {|| STR0195 }, oPanel, , , , , , .T., , , 240, 15) //"Ociosidade de Veículos - Número máximo de meses, além do período de extração, para buscar veículos que ainda não tiveram saída:"
    oSpinDtOcio := tSpinBox():new(27, 255, oPanel, {|x| aPeriod[2][2] := x }, 30, 13)
    oSpinDtOcio:setRange(0, 1000)
    oSpinDtOcio:setStep(1)
    oSpinDtOcio:setValue( aPeriod[2][2] )
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadPeriodDL
Carrega os períodos específicos de fatos do DL.

@Return aParameters Parâmetros que serão atualizados.  

@author  Valdiney V GOMES
@version P12
@since   22/03/2013
/*/
//-------------------------------------------------------------------
Static Function LoadPeriodDL()
	Local aParameters	:= {}  
	Local aIntrec 		:= BIXLoadParam( 'BIX_INTREC' )
	Local aDtocio 		:= BIXLoadParam( 'BIX_DTOCIO' )
	
	aAdd( aParameters, { 'BIX_INTREC', If( aIntrec == Nil, 0, nBIVal( aIntrec[3] ) ) } ) 
	aAdd( aParameters, { 'BIX_DTOCIO', If( aDtocio == Nil, 0, nBIVal( aDtocio[3] ) ) } ) 	
Return aParameters  

//-------------------------------------------------------------------
/*/{Protheus.doc} persPeriodDL
Grava os períodos específicos de fatos do DL.   

@Param aPeriod	Parâmetros e valores que serão atualizados. 

@author  Valdiney V GOMES
@version P12
@since   22/03/2013
/*/
//-------------------------------------------------------------------
Static Function PersPeriodDL( aPeriod )
	Local nParameter := 0
	
	If ! ( BIXLinkFSD() == 0 )
		For nParameter := 1 To Len( aPeriod ) 
			BIXSaveParam( aPeriod[nParameter][1], cBIStr( aPeriod[nParameter][2] ), , .F.)  
		Next nParameter
		
		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} wzdHourRange
Carrega o intervalo da Faixa de Hora

@param oPanel		Painel onde os objetos serão criados
@param aPeriod		Parametros que serão atualizados. 

@author  Valdiney V GOMES
@version P12
@since   15/04/2014
/*/
//-------------------------------------------------------------------
Static Function wzdHourRange( oPanel, nMinute )  
	Local oSayIntRec 	:= Nil 
	Local oSayDtOcio 	:= Nil 
	Local oSpinIntRec 	:= Nil 
	Local oSpinDtOcio 	:= Nil 

	oSayIntRec 	:= tSay():new(5, 10, {|| STR0200 }, oPanel, , , , , , .T., , , 240, 15) //"Faturamento - Intervalo em minuto para composição das faixas de horas para identificação de picos de venda:"
    oSpinIntRec := tSpinBox():new(3, 255, oPanel, {|x| nMinute := x }, 30, 13)
    oSpinIntRec:setRange(5, 1440)
    oSpinIntRec:setStep(1)
    oSpinIntRec:setValue( nMinute )
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadHourRange
Carrega o intervalo para definição da Faixa de Hora.

@Return aParameters Parâmetros que serão atualizados.  

@author  Valdiney V GOMES
@version P12
@since   15/04/2014
/*/
//-------------------------------------------------------------------
Static Function LoadHourRange() 
	Local aFxHora 		:= BIXLoadParam( 'BIX_FXHORA' )
Return If( aFxHora == Nil, 5, nBIVal( aFxHora[3] ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} PersHourRange
Grava o intervalo para definição da Faixa de Hora.

@Param aPeriod	Parâmetros e valores que serão atualizados. 

@author  Valdiney V GOMES
@version P12
@since   15/04/2014
/*/
//-------------------------------------------------------------------
Static Function PersHourRange( nMinute )
	If ! ( BIXLinkFSD() == 0 )
		BIXSaveParam( 'BIX_FXHORA', cBIStr( nMinute ), , .F.)  
		
		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} wzdPeriodCRM
Carrega os períodos específicos de fatos de CRM.   

@param oPanel		Painel onde os objetos serão criados
@param aPeriod		Parametros que serão atualizados. 

@author  Marcia Junko
@version P12
@since   12/05/2014
/*/
//-------------------------------------------------------------------
Static Function wzdPeriodCRM( oPanel, aPeriod )  
	Local oSayDiasAT 	:= Nil 
	Local oSayDiasPR 	:= Nil 
	Local oSayDiasTM 	:= Nil 
	Local oSayDiasEV 	:= Nil 
	Local oSpinDiasAT 	:= Nil 
	Local oSpinDiasPR 	:= Nil 
	Local oSpinDiasTM 	:= Nil 
	Local oSpinDiasEV 	:= Nil 

	oSayDiasAT 	:= tSay():new(5, 10, {|| STR0210 }, oPanel, , , , , , .T., , , 240, 15) //"Atividades - Número máximo de  meses, além do período de extração, para buscar as atividades abertas:"
    oSpinDiasAT := tSpinBox():new(3, 255, oPanel, {|x| aPeriod[1][2] := x }, 30, 13)
    oSpinDiasAT:setRange(0, 1000)
    oSpinDiasAT:setStep(1)
    oSpinDiasAT:setValue( aPeriod[1][2] )

	oSayDiasPR 	:= tSay():new(30, 10, {|| STR0213 }, oPanel, , , , , , .T., , , 240, 15) //"Desempenho de Vendas de Produtos - Número máximo de meses, além do período de extração, para buscar os itens das propostas abertas ou suspensas:"
    oSpinDiasPR := tSpinBox():new(27, 255, oPanel, {|x| aPeriod[2][2] := x }, 30, 13)
    oSpinDiasPR:setRange(0, 1000)
    oSpinDiasPR:setStep(1)
    oSpinDiasPR:setValue( aPeriod[2][2] )

	oSayDiasTM 	:= tSay():new(55, 10, {|| STR0215 }, oPanel, , , , , , .T., , , 240, 15) //"Desempenho do Time de Vendas - Número máximo de meses, além do período de extração, para buscar as oportunidades de vendas abertas ou suspensas:"
    oSpinDiasTM := tSpinBox():new(53, 255, oPanel, {|x| aPeriod[1][2] := x }, 30, 13)
    oSpinDiasTM:setRange(0, 1000)
    oSpinDiasTM:setStep(1)
    oSpinDiasTM:setValue( aPeriod[1][2] )

	oSayDiasEV 	:= tSay():new(80, 10, {|| STR0217 }, oPanel, , , , , , .T., , , 240, 15) //"Evolução de Venda - Número máximo de meses, além do período de extração, para buscar os itens de evolução de venda com status do estágio em andamento e em atraso:"
    oSpinDiasEV := tSpinBox():new(77, 255, oPanel, {|x| aPeriod[2][2] := x }, 30, 13)
    oSpinDiasEV:setRange(0, 1000)
    oSpinDiasEV:setStep(1)
    oSpinDiasEV:setValue( aPeriod[2][2] )
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDiasCRM
Carrega os períodos específicos de fatos de CRM.

@Return aParameters Parâmetros que serão atualizados.  

@author  Marcia Junko
@version P12
@since   12/05/2014
/*/
//-------------------------------------------------------------------
Static Function LoadDiasCRM()
	Local aParameters	:= {}  
	Local aIntAT 		:= BIXLoadParam( 'BIX_DIASAT' )
	Local aIntPR 		:= BIXLoadParam( 'BIX_DIASPR' )
	Local aIntTM 		:= BIXLoadParam( 'BIX_DIASTM' )
	Local aIntEV 		:= BIXLoadParam( 'BIX_DIASEV' )
	
	aAdd( aParameters, { 'BIX_DIASAT', If( aIntAT == Nil, 0, nBIVal( aIntAT[3] ) ) } ) 
	aAdd( aParameters, { 'BIX_DIASPR', If( aIntPR == Nil, 0, nBIVal( aIntPR[3] ) ) } ) 	
	aAdd( aParameters, { 'BIX_DIASTM', If( aIntTM == Nil, 0, nBIVal( aIntTM[3] ) ) } ) 
	aAdd( aParameters, { 'BIX_DIASEV', If( aIntEV == Nil, 0, nBIVal( aIntEV[3] ) ) } ) 	
Return aParameters  

//-------------------------------------------------------------------
/*/{Protheus.doc} PersDiasCRM
Grava os períodos específicos de fatos de CRM.   

@Param aPeriod	Parâmetros e valores que serão atualizados. 

@author  Marcia Junko
@version P12
@since   12/05/2014
/*/
//-------------------------------------------------------------------
Static Function PersDiasCRM( aPeriod )
	Local nParameter := 0
	
	If ! ( BIXLinkFSD() == 0 )
		For nParameter := 1 To Len( aPeriod ) 
			BIXSaveParam( aPeriod[nParameter][1], cBIStr( aPeriod[nParameter][2] ), , .F.)  
		Next nParameter
		
		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTxMoeada
Carrega o parâmetro que define se a taxa negociada será utilizada na
conversão de moedas.  

@Return aParameters Parâmetros que serão atualizados.  

@author  Marcia Junko
@version P11
@since   01/08/2014
/*/
//-------------------------------------------------------------------
Function LoadTxMoeda()
  	Local aRet := BIXLoadParam('BIX_TXMOED')

  	If aRet <> Nil
    	If !Empty( aRet[3] )
    		Return .T.
    	EndIf
  	EndIf
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} IsLoadZero
Parâmetro que define se produtos sem saldo ou movimento devem ser levados
para a stage. 

@author  Valdiney V GOMES
@version P11
@since   23/09/2014
/*/
//-------------------------------------------------------------------
Function IsLoadZero()
  	Local aRet := BIXLoadParam('BIX_NOZERO')

  	If aRet <> Nil
    	If !Empty( aRet[3] )
    		Return .T.
    	EndIf
  	EndIf
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PersComFinMat
Grava os parâmetros genéricos da área comercial\finanças\materiais   

@Param lTxMoeda	Parâmetros que define se será utilizada a taxa negociada ou a cotaçao do dia. 
@Param lLoadZero 	Parâmetro que define se produtos sem saldo ou movimento devem ser considerados. 

@author  Marcia Junko
@version P11
@since   10/07/2014
/*/
//-------------------------------------------------------------------
Static Function PersComFinMat( lTxMoeda, lLoadZero )
	If ! ( BIXLinkFSD() == 0 )
		BIXSaveParam('BIX_TXMOED'	, Iif(lTxMoeda, "S", ""), , .F. )
		BIXSaveParam('BIX_NOZERO'		, Iif(lLoadZero, "S", ""), , .F. )
		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveDBParam
Grava o parâmetro correspondente a tecnologia de banco de dados
utilizada para Stage e subentendida para DW

@Param cValue	 Parâmetro contendo o banco de dados da Stage. 

@author  Tamara Clemente
@version P11
@since   04/08/2014
/*/
//-------------------------------------------------------------------
Function BIXSaveDBParam( cValue )
	Local aDB := {}
	Local nPos := 0

	//Mapeamento do Banco para armazenamento do parâmetro	
	aAdd(aDB,{MSSQL, 'M'})
	aAdd(aDB,{DB2, 'D'})	
	aAdd(aDB,{ORACLE, 'O'})	
	aAdd(aDB,{INFORMIX, 'I'})	
	aAdd(aDB,{POSTGRES, 'P'})
	  
	nPos := aScan(ADB, {|x| x[1] == cValue})
    
	//Salva o parâmetro na tabela HJK
	BIXSaveParam('DB_TYPE', aDB[nPos][2])					  
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadMat
Carrega o parâmetro que define a quantidade de meses a serem considerados na fato de
carteira de qualidade.

@Return aParameters Parâmetros que serão atualizados.  

@author  Helio Leal
@version P12
@since   08/10/2014
/*/
//-------------------------------------------------------------------
Static Function LoadMat()
	Local aParameter		:= BIXLoadParam( 'BIX_CRTQUA' )
	Local nParameter		:= 0
	
	If aParameter == Nil
		nParameter := 0
	Else
		nParameter := nBIVal( aParameter[3] )
	EndIf

Return nParameter

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadMatCartComp
Carrega o parâmetro que define a quantidade de meses a serem considerados na fato de
carteira de compras.

@Return aParameters Parâmetros que serão atualizados.  

@author  Helio Leal
@version P11
@since   15/10/2014
/*/
//-------------------------------------------------------------------
Static Function LoadMatCartComp()
	Local aParameter		:= BIXLoadParam( 'BIX_CRTCOM' )
	Local nParameter		:= 0
	
	If aParameter == Nil
		nParameter := 0
	Else
		nParameter := nBIVal( aParameter[3] )
	EndIf

Return nParameter

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveMat
Grava o parâmetro para área de materiais.   

@Param nPeriodo	Parâmetros que define a quantidade de meses a serem considerados para qualidade carteira.
@Param nPeriodCartComp	Parâmetros que define a quantidade de meses a serem considerados para carteira de compras.

@author  Helio Leal
@version P12
@since   08/10/2014
/*/
//-------------------------------------------------------------------
Static Function SaveMat( nPeriod, nPeriodCartComp )	
	If ! ( BIXLinkFSD() == 0 )
		BIXSaveParam( 'BIX_CRTQUA', cBIStr( nPeriod ), , .F.)
		BIXSaveParam( 'BIX_CRTCOM', cBIStr( nPeriodCartComp ), , .F.)  

		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadRepres
Função que carrega o conteúdo do parâmetro BIX_REPRES
@return lRepres	Indica se o representante será obtido através do cadastro do cliente, ao invés dos dados da nota/pedido.

@protected
@author  Marcia Junko
@version P11
@since   13/10/2014
/*/
//-------------------------------------------------------------------
Function LoadRepres()
  	Local aRet := BIXLoadParam('BIX_REPRES')

  	If aRet <> Nil
    	If !Empty( aRet[3] )
    		Return .T.
    	EndIf
  	EndIf
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadProd
Carrega o parâmetro que define a quantidade de meses a serem considerados 
na fato de custo por operação da área de produção.

@Return aParameters Parâmetros que serão atualizados.  

@author  Tamara Clemente
@version P12
@since   15/10/2014
/*/
//-------------------------------------------------------------------
Static Function LoadProd()
	Local aParameter		:= BIXLoadParam( 'BIX_CUSTOP' )
	Local nParameter		:= 0
	
	If aParameter == Nil
		nParameter := 0
	Else
		nParameter := nBIVal( aParameter[3] )
	EndIf

Return nParameter

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCartMP
Carrega o parâmetro que define a quantidade de meses a serem considerados 
na fato de matéria prima carteira da área de produção.

@Return aParameters Parâmetros que serão atualizados.  

@author  Márcia Junko
@version P12
@since   29/10/2014
/*/
//-------------------------------------------------------------------
Static Function LoadCartMP()
	Local aParameter		:= BIXLoadParam( 'BIX_CARTMP' )
	Local nParameter		:= 0
	
	If aParameter == Nil
		nParameter := 0
	Else
		nParameter := nBIVal( aParameter[3] )
	EndIf

Return nParameter


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCartPR
Carrega o parâmetro que define a quantidade de meses a serem considerados 
na fato de produção carteira da área de produção.

@Return aParameters Parâmetros que serão atualizados.  

@author  Márcia Junko
@version P12
@since   28/10/2014
/*/
//-------------------------------------------------------------------
Static Function LoadCartPR()
	Local aParameter		:= BIXLoadParam( 'BIX_CARTPR' )
	Local nParameter		:= 0
	
	If aParameter == Nil
		nParameter := 0
	Else
		nParameter := nBIVal( aParameter[3] )
	EndIf

Return nParameter


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCartMO
Carrega o parâmetro que define a quantidade de meses a serem considerados 
na fato de mão de obra carteira da área de produção.

@Return aParameters Parâmetros que serão atualizados.  

@author  Márcia Junko
@version P12
@since   28/10/2014
/*/
//-------------------------------------------------------------------
Static Function LoadCartMO()
	Local aParameter		:= BIXLoadParam( 'BIX_CARTMO' )
	Local nParameter		:= 0
	
	If aParameter == Nil
		nParameter := 0
	Else
		nParameter := nBIVal( aParameter[3] )
	EndIf

Return nParameter


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveProd
Grava o parâmetro para área de produção.   

@Param nPeriodo	Parâmetros que define a quantidade de meses a serem 
					considerados na fato Custo por Operação.
@Param nCartMP		Parâmetro que define a quantidade de meses a serem 
					considerados na fato Matéria Prima Carteira.
@Param nCartPR		Parâmetro que define a quantidade de meses a serem 
					considerados na fato Produção Carteira.
@Param nCartMO		Parâmetro que define a quantidade de meses a serem 
					considerados na fato Mão de Obra Carteira.

@author  Tamara Clemente
@version P12
@since   15/10/2014
/*/
//-------------------------------------------------------------------
Static Function SaveProd( nPeriod, nCartMP, nCartPR, nCartMO )	
	If ! ( BIXLinkFSD() == 0 )
		BIXSaveParam( 'BIX_CUSTOP', cBIStr( nPeriod ), , .F.)
		BIXSaveParam( 'BIX_CARTMP', cBIStr( nCartMP ), , .F.)  
		BIXSaveParam( 'BIX_CARTPR', cBIStr( nCartPR ), , .F.)
		BIXSaveParam( 'BIX_CARTMO', cBIStr( nCartMO ), , .F.)

		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadComboOption
Função que converte o conteúdo de parâmetros do tipo combo
@return cTexto	Indica se o representante será obtido através do cadastro do cliente, ao invés dos dados da nota/pedido.

@protected
@author  Marcia Junko
@version P11
@since   29/10/2014
/*/
//-------------------------------------------------------------------
Function LoadComboOption( cOption )
  	Local aRet := BIXLoadParam(cOption)
  	Local cTexto	:= STR0258 //"Ambos"
  	Local cOpcao	:= ""	

  	If aRet <> Nil
    	If !Empty( aRet[3] )
    		cOpcao := Alltrim(aRet[3])
    		Do Case 
    			Case cOpcao == "1"
    				cTexto := STR0256 //"Sim"
    			Case cOpcao == "2"
    				cTexto := STR0257 //"Não"
    			Case cOpcao == "3"
    				cTexto := STR0258 //"Ambos"
    		End Case
    	EndIf
  	EndIf
Return cTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveContaBloq
Grava o parâmetro para área de controladoria.   

@Param lCheck	Parâmetro que define se as contas bloqueadas serão ou não consideradas.

@author  Helio Leal
@version P12
@since   18/11/2014
/*/
//-------------------------------------------------------------------
Static Function SaveContaBloq( lCheck )	
	If ! ( BIXLinkFSD() == 0 )
		BIXSaveParam( 'BIX_CONTBL', iif( lCheck, "S", ""), , .F.)

		BIXUnlinkFSD()
	Else 
		ApMsgStop(STR0073) //"Não foi possivel fazer a conexão com o banco de dados."
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadContaBloq
Carrega o parâmetro que define se as contas bloqueadas devem ser consideradas.

@author  Helio Leal
@version P12
@since   18/112014
/*/
//-------------------------------------------------------------------
Static Function LoadContaBloq()
	Local aParameter := BIXLoadParam( 'BIX_CONTBL' )
		
	If aParameter <> Nil
    	If !Empty( aParameter[3] )
    		Return .T.
    	EndIf
  	EndIf

Return .F.