// ######################################################################################
// Projeto: KPI
// Modulo : Core
// Fonte  : KPIWebex - Rotinas para controle Webex
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 18.08.05 | 1776 Alexandre Alves da silva
// --------------------------------------------------------------------------------------

#include "KPIDefs.ch"
#include "KPIWebex.ch"

// WebStart
function SGIWebStart()
	local nStart 			:=	0
	local lFirstBase		:=	.f.
	local oGlobalLockFile	:=	nil
	local cInstanceName		:=	""  

	public oKPICore 			:= TKPICore():New()
	public cKPIErrorMsg		:= "" 

	ErrorBlock( {|oE| __KPIError(oE)})

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

//  Rpc nao abre tabelas
//	RpcSetEnv ("99","01", , , , , , , , .F., .F. )
//  Rpc abre todas as tabelas
//	RpcSetEnv ("99","01", , , , , , , , )
//	CriaPublica()

// 	ValidPswFile() - Funcao criada pela tecnologia para resolver problema do psw
// 	Como nuca funcionou não foi implantada, aqui seria o lugar adequado, se funcionasse

	// Instance Name - nome base para os arquivos gerados pelo KPI para trabalhar com multithreading
	cInstanceName := alltrim(getJobProfString("INSTANCENAME", "SGI"))
	oGlobalLockFile := TBIFileIO():New( cInstanceName+".upd" )
	
	while !oGlobalLockFile:lCreate(FC_NORMAL+FO_EXCLUSIVE)
		sleep(500)
	enddo

	nStart := nBIVal(GetGlbValue(cInstanceName))
	           
	if(nStart < 1)
		nStart := 1
		PutGlbValue(cInstanceName,cBIStr(nStart))
		
		conout("")
		conout(STR0001)/*"Iniciando SGI..."*/    
		
		oKPICore:LogInit()
		oKPICore:LanguageInit()
				
		lFirstBase := oKPICore:lUpdateDB() 
		
		if(oKPICore:nDBStatus() >= 0)
			oKPICore:UpdateVersion(lFirstBase)
			conout(STR0002)/*"Inicializando working threads..."*/
		endif   

		Conout(ANSIToOEM(STR0069))/*"Verificando a chave de licença..."*/
	   
		/*Recupera o LicenseKey em uma variável GLOBAL.*/
		PutGlbValue("LICENSE_KEY", cBIStr(LS_GetID()) )		
		PutGlbValue(cInstanceName, cBIStr(nStart))  
	else
		nStart++  		
		/*Recupera o LicenseKey para atualizar o conteúdo da variável GLOBAL ["LICENSE_KEY"].*/
		Conout(ANSIToOEM(STR0070))/*"Atualizando a chave de licença..."*/
		PutGlbValue("LICENSE_KEY", cBIStr(LS_GetID()) )		
		PutGlbValue(cInstanceName, cBIStr(nStart))     
	endif
             

	oKPICore:nTrade(val(getJobProfString("SGITRADE", "1")))//Configurando a marca que esta usando o SGI.

	oGlobalLockFile:lClose()

	if(nStart == 1 .and. oKPICore:nDBStatus() < 0)
		conout(" ")
		ExUserException(cBIMsgTopError(oKPICore:nDBStatus()))
	endif	  
	
	if(oKPICore:nDBOpen() < 0)
		conout(" ")
		ExUserException(cBIMsgTopError(oKPICore:nDBStatus()))
	else
		// Inicialização do scheduler do SGI
		// Para o mp8srv.ini KpiSchedInit=0 não inicializa o scheduler
		// Por default KpiSchedInit=0, ou seja, nao 1inicializa por default 
		oKPICore:SchedInit(xBIConvTo("N", alltrim(getJobProfString("SgiSchedInit", "0"))) > 0)
	endif	
	
	oKPICore:nThread(nStart)
	oKPICore:Log("Working thread "+upper(cInstanceName)+"."+strzero(oKPICore:nThread(), 4)+STR0003, KPI_LOG_SCRFILE)/*//" inicializada."*/

	//Verifica se a variavel cScoreCard foi criada.
	if(type("__ScoreName")=="U")
		public __ScoreName :=  oKPICore:getStrCustom():getStrSco() //alltrim(getJobProfString("ScoreCardName", "ScoreCard"))
	endif

return .T.                                         

// WebConnect
function SGIWebConnect()
	local lDebug, lWeb, cResponse := "", nCard := 0, nContextID := 0, i, aTemp := {}
	local oIndicador          
	
	private lPainel := .f., cUserProt:="", cSessao:=""
	
    httpSession->Title := KPIEncode(STR0019)
    httpSession->AccessBtn := STR0079
	// Se modo debug, exibe todas as informações de conexão
	lDebug := (nBIVal(GetJobProfString("debug", "0")) == 1)

	if(lDebug)                                        
		KPIDebug1()
	endif
	
	begin sequence
		do case
			case(oKpiCore:nDBStatus() < 0)
				// Avisar erro top, html browser volta ao login
				cResponse := KPITopError(oKpiCore:nDBStatus())    
				
			case(lower(HttpHeadIn->Main)=="kpicore") // Responde ao client, verificando expiração ou necessidade de autenticação
				nCard := nBIVal(HttpSession->usercard)
				nContextID := nBIVal(HttpSession->ContextID)
	   
				if(oKPICore:lSetupCard(nCard)) // Autentica o usuario
					if(valtype(HttpPost->kpicontent)=="C")
						oKPICore:fnContextID := nContextID // Atribui ContextID do contexto atual para session
						cResponse := oKPICore:cRequest(HttpPost->kpicontent) // Responde ao usuario
						HttpSession->ContextID := oKPICore:nContextID() // Se houve mudanca no contexto, atualiza session
					endif
				else
					if(valtype(HttpPost->kpicontent)=="U")
						httpSession->BadLogin := .T.
						cResponse := h_biportalby() // html browser volta ao login
					else
						cResponse := KPIXMLLogin() // XML indica ao client novo login
					endif	
				endif	 
				
			case(lower(HttpHeadIn->Main)=="sgidownload")
				BIExecDownload(oKPICore:cKpiPath()+httpGet->FILE)
				cResponse := "" 

			case(lower(HttpHeadIn->Main)=="sgitotvs")
				if valtype(HttpGet->username) == "C"
			   		nCard := oKPICore:nLogin(HttpGet->username, httpGet->password) 
					nContextID := 1 // Estrategia default para teste
					// grava na sessao do usuario
					HttpSession->usercard := nCard
					HttpSession->ContextID := nContextID 
					cResponse := redirPage("sgitotvs.apw")	
				else   
					if(HttpSession->usercard==0 .or. HttpSession->usercard == nil)
						sleep(500)
						cResponse := KPIBadLogin() //volta ao login anunciando erro na autenticação
					else 
						cResponse := KPINavApplet()//autenticação ok, Carrega o applet principal no navegador
					endif
				endif

			case(lower(HttpHeadIn->Main)=="sgisobre")
				// Mostra a pagina de sobre do sgi
				cResponse := KPISobre()
				
			case(lower(HttpHeadIn->Main)=="sgiindex")
				// Mostra a pagina de login do sgi
				cResponse := KPIIndex()
				
			case(lower(HttpHeadIn->Main)=="kpipainel")
				// Mostra a pagina de login do sgi porem exibida com restrições
				lPainel := .t.
				for i:=1 to len(HttpGet->aGets)
					if(upper(HttpGet->aGets[i])=="USUARIO")
						cUserProt := &('HttpGet->'+HttpGet->aGets[i])
					elseif(upper(HttpGet->aGets[i])="CSESSAO")
						cSessao := &('HttpGet->'+HttpGet->aGets[i])
					else
					    aadd(aTemp,{HttpGet->aGets[i], upper(&('HttpGet->'+HttpGet->aGets[i])) })
					endif
				next

				cResponse := KPIIndex(.t., aTemp)
				if(!empty(cUserProt+cSessao))
					nCard := oKPICore:nLogin(cUserProt, , cSessao )
					nContextID := 1 // Estrategia default para teste
					// grava na sessao do usuario
					HttpSession->usercard := nCard
					HttpSession->ContextID := nContextID
					if(nCard==0)
						sleep(500)
						cResponse := KPIBadLogin()  // volta ao login anunciando erro na autenticação
					else
						cResponse := KPINavApplet() // autenticação ok, carrega o applet principal no navegador
					endif
				endif

			case(lower(HttpHeadIn->Main)=="sgilogin")
				if(len(HttpGet->aGets)>0 .and. !empty(HttpGet->entidade))
					lPainel := .t.
				endif       

				// Verifica se esta tentando login
				if(valtype(HttpPost->login)=="C" .and. HttpPost->login=="true")
					nCard := oKPICore:nLogin(HttpPost->Username, HttpPost->Password) 
					nContextID := 1 // Estrategia default para teste
					// grava na sessao do usuario
					HttpSession->usercard := nCard
					HttpSession->ContextID := nContextID
					
					if(nCard==0)
						sleep(500) 
						 //Volta ao login anunciando erro na autenticação.
						//cResponse := KPIBadLogin()     
						
						httpSession->BadLogin := .T.
					
						cResponse := h_biportalby() // html browser volta ao login
					else  
					    //Força a atualização do cache de scorecards.								        
						HTTPSESSION->ScoCache = Nil
									
						//Verifica restricao por IP.
			         	if oKPICore:foSecurity:lVerifIP(nCard) == .f.   
							cResponse := KPIBadIp( lWeb ) 
						//Verifica restricao de horario.
						elseif oKPICore:foSecurity:lVerifAcessTime(nCard) == .f. 
							cResponse := KPIBadTime( lWeb )
						else
							if(HttpPost->radiobutton=="navegador") .OR. .T.
								//Carrega o applet principal no navegador.
								cResponse := KPINavApplet()   
							elseif(HttpPost->radiobutton=="janela")
								//Carrega o applet principal em frame.
								cResponse := KpiWindowApplet() 
							endif 
						endif
					endif            
				else
					sleep(500)
					//Volta ao login anunciando erro na autenticação.
					cResponse := KPIBadLogin( lWeb ) 
				endif  
					    
			case(lower(HttpHeadIn->Main)=="recpassword")//O usuario perdeu a senha.
				if(oKpiCore:lRecPassword(httpPost->USERNAME,alltrim(httpPost->EMAIL)) .AND. !Empty(httpPost->USERNAME))
					cResponse :=  KPIPassSended(alltrim(httpPost->EMAIL))
				else
					cResponse := KPIBadLogin(STR0040) // Usuário ou e-mail inválidos.
				endif
				
   			case(lower(HttpHeadIn->Main)=="h_bibyforgotpwd")//Enviando a pagina para recuperacao da senha.
				cResponse :=  h_bibyForgotPwd()
			
			case(lower(HttpHeadIn->Main)=="session") // Responde ao client, verificando expiração ou necessidade de autenticação
				cResponse := KPIXMLSession()
		   
			//Cria o arquivo JNLP e em seguida abre a tela para download.
			case(lower(HttpHeadIn->Main)=="javawebstart")
				BIExecDownload(oKPICore:CreateJNPL())
				cResponse := KPIBadLogin()        
				   
			//Exibe o relatório analítico de um indicador. 
			case(lower(HttpHeadIn->Main)=="analitico")
				cResponse := nRelatorio()			  
			endcase
	recover     

		cResponse := KPIGeneralError(cKPIErrorMsg) // XML general error

	end sequence   

return iif(valType(cResponse)=='U', '', cResponse)

// WebExit
function SGIWebFinish()
	// Fechar arquivos
	oKPICore:Log("Working thread SGI"+strzero(oKPICore:nThread(), 4)+STR0004, KPI_LOG_SCRFILE)/*//" finalizada."*/
	BICloseDB()
return

// KpiIndex.apw
function KPIIndex( lPaineis, aParametros )
	httpGet->lPaineis	:= lPaineis
	httpGet->aParametros:= aParametros 
	httpSession->cAction := "sgilogin.apw?"    
	httpSession->ForgotPwd:= "h_bibyForgotPwd.apw"
return h_biportalby()
//return h_kpiIndex()


// SGI no navegador
function KPINavApplet()
	local cHtml, lDebug
	
	// Se modo debug, exibe todas as informações de conexão
	lDebug := (nBIVal(GetJobProfString("debug", "0")) == 1)
	
	cHtml := ""
	cHtml += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'+CRLF
	cHtml += '<html>'+CRLF
	cHtml += '<head>'+CRLF
	cHtml += '<title>'+STR0019+ '</title>'+CRLF //"SGI - Sistema de Gestão de Indicadores"
	cHtml += '<script type="text/javascript" src="sgilib.js"></script>'+CRLF
	cHtml += '</head>'+CRLF
	cHtml += '<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onResize="changeAppSize()">'+CRLF
	cHtml += '<script language="JavaScript">'+CRLF
	cHtml += 'loadApplet("' + KPIApplet("kpi.applet.KpiNavApplet", lPainel) + '");'+CRLF
	cHtml += 'changeAppSize();'+CRLF
	cHtml += '</script>'
	cHtml += '</body>'+CRLF
	cHtml += '</html>'+CRLF    

return cHtml                         


// Retorna a tag para o applet do sgi
function KPIApplet(cAppletClassName)    
	local cHtml, lDebug, cPanel := ""
	
	// Se modo debug, exibe todas as informações de conexão
	lDebug := (nBIVal(GetJobProfString("debug", "0")) == 1)
	
	if(!empty(HttpGet->ENTIDADE))
		cPanel := '<PARAM NAME = ENTIDADE VALUE = '+HttpGet->ENTIDADE+'>'
	endif

	if(!empty(HttpGet->ID))
		cPanel += '<PARAM NAME = ID VALUE = '+HttpGet->ID+'>'
	endif

	cHtml := ""+;
	'<OBJECT name=\"AppKpi\" id=\"AppKpi\" classid=\"clsid:8AD9C840-044E-11D1-B3E9-00805F499D93\"'+;
	'codebase = \"http://java.sun.com/update/1.5.0/jinstall-1_5_0_03-windows-i586.cab#Version=1,5,0,3\"'+;
	'WIDTH = 1250 HEIGHT = 900>'+;
	'<PARAM NAME = CODE VALUE = '+cAppletClassName+'>'+;
	'<PARAM NAME = \"type\" VALUE = \"application/x-java-applet;version=1.5\">'+;
	'<PARAM NAME = ARCHIVE VALUE = \"sgi.jar\" >'+;
	'<PARAM NAME = \"scriptable\" VALUE = \"false\">'+;
	'<PARAM NAME = SESSIONID VALUE = \"'+alltrim(cBIStr(HttpSession->SESSIONID))+'\">'+;
	'<PARAM NAME = DEBUG VALUE = \"'+iif(lDebug, "TRUE", "FALSE")+'\">'+;
	'<PARAM NAME = LANGUAGE VALUE = \"'+cKPILanguage()+'\">'+;
	'<PARAM NAME = KPIVERSION VALUE = \"'+cKPIVersion()+'\">'+;
	'<PARAM NAME = MODO_ANALISE VALUE = \"'+getJobProfString("AnalysisMode", ANALISE_PDCA)+'\">'+;
	'<PARAM NAME = PAINEL VALUE = '+if(lPainel,"true","false")+'>'+;
	cPanel+;
		'<COMMENT>'+;
			'<EMBED  name=\"AppKpi\" id=\"AppKpi\" type = \"application/x-java-applet;version=1.5\"'+;
				'CODE = '+cAppletClassName+' ARCHIVE = \"sgi.jar\"'+;
				'WIDTH = 74 HEIGHT = 55'+;   
				' scriptable = false'+;
				' SESSIONID = '+alltrim(cBIStr(HttpSession->SESSIONID))+;
				' DEBUG = '+iif(lDebug, 'TRUE', 'FALSE')+;
				' LANGUAGE = \"'+cKPILanguage()+'\"'+;
				' KPIVERSION = \"'+cKPIVersion()+'\"'+;
				' MODO_ANALISE = \"'+getJobProfString("AnalysisMode", "1")+'\"'+; 
				' PAINEL =  \"'+ if(lPainel,"true","false")+'\"'+;
				'pluginspage = \"http://java.sun.com/products/plugin/index.html#download\" >'+;
				'<NOEMBED></NOEMBED>'+;
			'</EMBED>'+;
		'</COMMENT>'+;
	'</OBJECT>'

return cHtml

/*
Carrega o applet principal em frame
*/
function KpiWindowApplet()
	Local acTitle 	:= "SGI"
	Local acMessage	:= ""
	
	acMessage += "<br>" + STR0010 + " " + '<a href="http://www.java.com" class="linksLogin">Download Java Plugin</a>'
	acMessage += "<br><br><b>" + STR0005 + "</b> " + STR0006 + " " + STR0008 + "<br><br>"
	acMessage += "<script language='JavaScript'>"
	acMessage += "loadApplet('"
	acMessage += KPIApplet("kpi.applet.KpiWindowApplet")  
	acMessage += "'); "
	acMessage += "</script> "

Return mountDefaultHtml(acTitle, acMessage)

/*
Funcao que avisa o usuario da geracao de uma nova senha.
*/                                             
function KPIPassSended(cEmail)	
	httpSession->cMsg = STR0090  + cEmail //"Nova senha foi enviada para : "  
	httpSession->cClassName = "message"                   
return  h_biportalby() 

function KPIBadLogin(cMessage)
   httpSession->cMsg = cMessage 
   httpSession->cClassName = "badmessage"   
return  h_biportalby() 


static function KPIBadIP(lWeb)
	local cMessage := STR0036 + HttpHeadIn->remote_addr + STR0037 //'Endereço IP '  ' bloqueado, entre em contato com o administrador.'

	httpSession->cMsg = cMessage 
	httpSession->cClassName = "badmessage"   
return h_biportalby() 

static function KPIBadTime(lWeb)
	local cMessage := STR0038 //'Você não tem permissão para acessar o sistema nesse horário.' 
   
	httpSession->cMsg = cMessage 
	httpSession->cClassName = "badmessage" 
return h_biportalby() 

function KPITopError(nTopError)
	local cMessage := cBIMsgTopError(nTopError)
   
	httpSession->cMsg = cMessage 
	httpSession->cClassName = "badmessage"   

return h_biportalby() 


function KPISobre()
	local cHtml := ""
	
	cHtml += '<table border="0" valign="top" align="center" cellpadding="0" cellspacing="0">'+CRLF 
	cHtml += '	<tr>'+CRLF
	cHtml += '		<td align="center"><p><font face="Arial, Helvetica, sans-serif"><b><font face="Arial" size="2">'+KPIEncode(STR0035)+'</font><font face="Arial" size="4"></font></b></font></p></td>'+CRLF
	cHtml += '	</tr>'+CRLF
	cHtml += '	<tr>'+CRLF
	cHtml += '		<td align="center"><p><font face="Arial, Helvetica, sans-serif"></font><font face="Arial" size="2"><b>Business Intelligence</b></font><font face="Arial" size="4"><b></b></font></p></td>'+CRLF
	cHtml += '	</tr>'+CRLF
	cHtml += '	<tr>'+CRLF
	cHtml += '		<td align="center"><p><font size="2" face="Arial, Helvetica, sans-serif"><br><strong>Build '+ alltrim(cKPIVersion()) +'</strong></font></p></td>'+CRLF
	cHtml += '	</tr>'+CRLF 
	cHtml += '	<tr>'+CRLF
	cHtml += '		<td align="center"><p><font size="2" face="Arial, Helvetica, sans-serif"><br><strong> License Key  ' + DwStr(LS_GetID()) +'</strong></font></p></td>'+CRLF
	cHtml += '	</tr>'+CRLF 	
	cHtml += '</table>'+CRLF

return mountDefaultHtml("", cHtml)	

static function mountDefaultHtml(acTitle, acMessage, alDenied)
	Local cHtml  		:= ''   
     
   	Default acTitle 	:= ''
   	Default acMessage	:= ''
   	Default alDenied	:= .F.
   
	If ( alDenied )  	       
		cHtml := '<!DENIED -->'   
	EndIf
	
	cHtml += "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//PT'>"
	cHtml += '<html>'
	cHtml += '    <head>'
	cHtml += '        <link href="favico.ico/" rel="icon">'
	cHtml += '        <link href="favico.ico/" rel="shortcut icon">'
	cHtml += '        <title>' + STR0019+ '</title>' //"SGI - Sistema de Gestão de Indicadores"
	cHtml += '        <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">'
	cHtml += '        <meta content="TOTVS S.A. - IP - Business Intelligence" name="author">'
	cHtml += '        <meta content="TOTVS Web Interface" name="Generator">'
	cHtml += '        <meta content="application/x-javascript" name="Content-Script-Type">'
	cHtml += '        <meta content="no-cache" http-equiv="Cache-control">'
	cHtml += '        <meta content="-1" http-equiv="Expires">'
	cHtml += '        <meta content="none,noarchive" name="Robots">'
	
	cHtml += '        <link href="./css/reset.css" type="text/css	" rel="stylesheet">'
	cHtml += '        <link href="./css/main.css" type="text/css" rel="stylesheet">'
	cHtml += '        <link href="./css/layout.css" type="text/css" rel="stylesheet">'
	cHtml += '        <link href="./css/decor.css" type="text/css" rel="stylesheet">'
	cHtml += '        <link href="./css/ids.css" type="text/css" rel="stylesheet">'
	cHtml += '		  <link href="estilo.css" rel="stylesheet" type="text/css">'
	
	cHtml += '		  <script type="text/javascript" src="sgilib.js"></script>'
	cHtml += '	</head>'
	
	cHtml += '    <body class="p11">'
	cHtml += '        <div id="form1" style="padding-left: 0px; padding-right: 0px; width: 100%; height: 100%;" class="pos-abs">'
	
	cHtml += '			<form name="form1" action="" method="post" style="position: absolute; width: 100%; height: 100%; margin: 0px; padding: 0px;" onSubmit="saveCookies();">'
	cHtml += '                <input type="hidden" value="true" name="login">'
	cHtml += '                <div style="position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;" class="bi-dialog-nopopup bi-dialog-content" id="0000000039">'
	cHtml += '                    <div id="0000000074" class="wi-jqmsgbar pos-abs" style="height: 33px; display: none;">&nbsp;</div>'
	cHtml += '                    <div id="0000000075" class="wi-jqpanel pos-abs containerLogin" style="width: 632px; height: 420px;">'
	cHtml += '                        <div id="0000000077" class="wi-jqpanel pos-abs container_l" style="left: 0px; width: 45px; height: 420px;"></div>'
	cHtml += '                        <div id="0000000079" class="wi-jqpanel pos-abs container_m" style="left: 45px; right: 45px; height: 420px;"></div>'
	cHtml += '                        <div id="0000000081" class="wi-jqpanel pos-abs divisor" style="left: 276px; top: 50px; bottom: 50px; width: 2px;"></div>'
	cHtml += '                        <div id="0000000083" class="wi-jqpanel pos-abs logo_totvs" style="right: 114px; top: 128px; width: 176px; height: 166px;"></div>'
	cHtml += '                        <div id="0000000085" class="wi-jqpanel pos-abs divisor" style="right: 48px; top: 50px; bottom: 50px; width: 2px;"></div>'
	cHtml += '                        <div id="0000000087" class="wi-jqpanel pos-abs container_r" style="right: 0px; width: 45px; height: 420px;"></div>'
	cHtml += '                        <label unselectable="on" id="0000000089" class="wi-jqsay pos-abs title" style="left: 20px; top: 150px; width: 270px; height: 7px;">' + acTitle + '</label>'
	cHtml += '                        <label unselectable="on" id="0000000090" class="wi-jqsay pos-abs" style="left: 46px; top: 180px; width: 230px; height: 46px;">' + acMessage + '</label>'
	cHtml += '                    </div>'
	cHtml += '                    <label unselectable="on" id="0000000092" class="wi-jqsay pos-abs login_rodape" style="bottom: 15px; width: 100%; height: 13px;">Copyright &copy; 2010 <b>TOTVS</b> - ' + STR0073 + '</label>' //Todos os direitos reservados.
	cHtml += '                </div>'
	cHtml += '            </form>'
	cHtml += '        </div>'
	cHtml += '    </body>'
	cHtml += '</html>'

return cHtml

//Retorna o numero da sessao
function KPIXMLSession()
	local oXMLOutput, oNode
	local oXMLNode 
	local oNodeSession
	
	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))

	oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_OK))
	oNode := oNode:oAddChild(TBIXMLNode():New("RETORNOS"))

	// Gera no principal
	oXMLNode := TBIXMLNode():New("SESSIONS")
	oNodeSession := oXMLNode:oAddChild(TBIXMLNode():New("SESSIONID",alltrim(cBIStr(HttpSession->SESSIONID))))   

	oNode:oAddChild(oXMLNode)

return oXMLOutput:cXMLString(.t., "ISO-8859-1")

// Session expirada
function KPIXMLLogin()
	local oXMLOutput, oNode
	
	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))
	oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_EXPIREDSESSION))
return oXMLOutput:cXMLString(.t., "ISO-8859-1")

// Erro durante a execução do ADVPL
function KPIGeneralError(cStatusMsg)
	local oXMLOutput, oNode, oAttrib

	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("MSG", cStatusMsg)

	oXMLOutput := TBIXMLNode():New("RESPOSTAS")
	oNode := oXMLOutput:oAddChild(TBIXMLNode():New("RESPOSTA"))
	oNode:oAddChild(TBIXMLNode():New("STATUS", KPI_ST_GENERALERROR, oAttrib))
return oXMLOutput:cXMLString(.t., "ISO-8859-1")

// Tratamento de erro
function __KPIError(oE)
	local cMsg := "", nPilha := 0
	
//	if oE:gencode > 0      
		cMsg := str(oE:gencode,4,0) + " - " + oE:Description 
		conout(cMsg, "Called from ")
		while ProcName( nPilha ) <> ""
			if(nPilha >= 2)
				conout("    " + ProcName(nPilha) + " line " + strZero(procLine(nPilha), 5))
			endif
			nPilha++
		end
		cKPIErrorMsg := cMsg
		break
//	endif
return .t.

// Funcoes para debug
function KPIDebug1()
	local nInd, cText := "<html><body>"

	cText += KPISaida(" ")
	cText += KPISaida("Posts:")
	cText += KPISaida("-------------------------------")
	aTmp := HTTPPOST->aPost
	for nInd := 1 to len(aTmp)
		cText += KPISaida(aTmp[nInd]+": "+&("HTTPPOST->"+aTmp[nInd]))
	next
		
	cText += KPISaida(" ")
	cText += KPISaida("Gets:")
	cText += KPISaida("-------------------------------")
	aTmp := HTTPGET->aGets
	for nInd := 1 to len(aTmp)
		cText += KPISaida(aTmp[nInd]+": "+&("HTTPGET->"+aTmp[nInd]))
	next

	cText += KPISaida(" ")
	cText += KPISaida("Cookies:")
	cText += KPISaida("-------------------------------")
	aTmp := HTTPCOOKIES->aCookies
	for nInd := 1 to len(aTmp)
		cText += KPISaida(aTmp[nInd]+": "+&("HTTPCOOKIES->"+aTmp[nInd]))
	next

	cText += KPISaida(" ")
	cText += KPISaida("Header:")
	cText += KPISaida("-------------------------------")
	aTmp := HTTPHEADIN->aHeaders
	for nInd := 1 to len(aTmp)
		if (" "$aTmp[nInd])
			cText += KPISaida(aTmp[nInd])
		else	
			cText += KPISaida(aTmp[nInd]+": "+&("HTTPHEADIN->"+aTmp[nInd]))
		endif	
	next

	cText +="</body></html>"

return cText   

/*-------------------------------------------------------------
Identica se o SGI está sendo executado em modo de DEBUG.
@Param:
@Return:
	Boolean - Verdadeiro quando está em modo de DEBUG. 	
-------------------------------------------------------------*/
function KPIIsDebug()
return (nBIVal(GetJobProfString("DEBUG", "0")) == 1)

function KPISaida(cText)
	conout(cText)
return cText+CRLF+"<br>"

function KPIRemote(cHost, cPainel, cID, time)
	local o, oDlg, cTitle := "[SGI]"
	local cSessao 	:= PswGetSession(pswRet(1)[1][1])
	local cURL 		:= cHost + "?entidade="+cPainel+"&ID="+cID+"&usuario="+cUserName+"&cSessao="+cSessao
	local nValidaTime := (val(subs(time(),1,2))*60*60) + (val(subs(time(),4,2))*60) + val(subs(time(),7,2))
	local lRetorno 	:= .t.
	
	if( (nValidaTime - (val(subs(time,1,2))*60*60) + (val(subs(time,4,2))*60) + val(subs(time,7,2))) / 60) > 120
		lRetorno := .f.
	endif
	
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 570, 950 TITLE cTitle PIXEL
	
	    oDlg:lMaximized := .T.
	    o:=TiBrowser():New(10,0,oDlg:nWidth / 2,oDlg:nHeight / 2, cURL ,oDlg)
	    o:Navigate(cURL)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) )                 
return lRetorno     