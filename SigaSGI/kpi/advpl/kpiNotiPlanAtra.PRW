// ######################################################################################
// Projeto: KPI
// Modulo : Agendador
// Fonte  : kpiNotiPlanAtra.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 24.01.06 | 2487 Eduardo Konigami Miyoshi
// --------------------------------------------------------------------------------------
#INCLUDE "BIDefs.ch"
#INCLUDE "KPIDefs.ch"
#INCLUDE "kpiNotiPlanAtra.ch"

#DEFINE		KPI_PATH			01
#DEFINE   	ACAO_FECHADA		"3|5|6"    
#DEFINE   	ACAO_PROJETO		"2"
#DEFINE   	EMAIL_DESTINATARIO	1  
#DEFINE   	EMAIL_MENSAGEM		2

/**
Notifica��o de a��es vencidas.
@param aParams Par�metros para inicializa�o do KPICore. 
@return .T. 
*/
function kpiNotiPlanAtra(aParms)
	Local cLogName		:= "log_"
	Local cKPIErrorMsg 	:= "" 
	Local lLog 			:= .f.

	Public oKPICore

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	oKPICore := TKPICore():New(aParms[KPI_PATH])
	ErrorBlock( {|oE| __KPIError(oE)})
	oKPICore:LogInit()  

	oKPICore:Log(STR0001, KPI_LOG_SCRFILE) 	//"Iniciando a notifica��o de planos atrasados."
	if(oKPICore:nDBOpen() < 0) 
		oKPICore:Log(STR0002, KPI_LOG_SCRFILE)  //"Erro na abertura do banco de dados.(KpiNotiPlanAtra)"
		return
	endif

	oScheduler  := TKPIScheduler():New() 
	oKPICore:oOwner(oScheduler)  
	
	cLogName += alltrim(getJobProfString("INSTANCENAME", "SGI"))+"_"
	cLogName += strtran(dToc(date()),"/","") +"_"
	cLogName += strtran(time(),":","")
	
	if(!lLog) 
		oScheduler:lSche_CriaLog(aParms[KPI_PATH],cLogName) 		
		oScheduler:lSche_WriteLog(STR0005) //"Iniciado a notifica��o de planos vencidos."
		lLog	:= .T.
	endif
      
 	notificaAtraso() 

	If (lLog)          
		oScheduler:lSche_WriteLog(STR0003) //"Finalizado a notifica��o de planos vencidos." 
		oScheduler:lSche_CloseLog() 
	Endif 

	oKPICore:Log(STR0004, KPI_LOG_SCRFILE)	//"Notifica��o de planos finalizada."
Return .T.
 
/**
Realiza o envio da notifica��o aos respons�veis pelas a��es vencidas. 
*/
static Function notificaAtraso()
	Local oConexao   	:= oKPICore:oGetTable("SMTPCONF")
	Local oPlano		:= oKPICore:oGetTable("PLANOACAO")
	Local oGrupo		:= oKPICore:oGetTable("GRUPO_ACAO")	
	Local oProjeto	:= oKPICore:oGetTable("PROJETO")   
	Local oUsuGrp		:= oKPICore:oGetTool("USERGROUP")
	Local cServer 	:= ""
	Local cPorta 		:= ""
	Local cConta 		:= ""
	Local cAutUsuario	:= ""
	Local cAutSenha 	:= ""
	Local cFrom 		:= ""
	Local cAssunto 	:= ""
	Local aEmail	 	:= {} 
	Local nCount 		:= 0   
	Local aUser		:= {}   
	Local nI
	Local cProtocol	:= "0"
	
	If( oConexao:lSeek(1,{cBIStr(1)}) )
		cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
		cPorta			:= alltrim(oConexao:cValue("PORTA"))
		cConta			:= alltrim(oConexao:cValue("NOME"))
		cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
		cAutSenha		:= alltrim(oConexao:cValue("SENHA"))
		cFrom			:= alltrim(oConexao:cValue("NOME"))
		cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))
		cAssunto		:= STR0006
		
		oPlano:cSQLFilter("DATAFIM < '" + DToS(date()) + "'" )
		oPlano:lFiltered(.T.)
		oPlano:_First()
		
		While(!oPlano:lEof())
			If !( oPlano:cValue("STATUS") $ ACAO_FECHADA ) 	 
				aUser := {}
				If oPlano:cValue("TP_RESP") == TIPO_GRUPO
					aUser := oUsuGrp:aUsersByGroup(oPlano:cValue("ID_RESP"))
				Else
					aAdd(aUser,oPlano:cValue("ID_RESP"))
				Endif
				
				For nI := 1 To Len(aUser)
					//Notifica o respons�vel pela execu��o da a��o. .
					aAdd(aEmail, aMontaMail(aUser[nI], oPlano))
				Next

				//Notifica o respons�vel pela projeto do qual a �a� faz parte. 
				If( AllTrim( oPlano:cValue("TIPOACAO") ) == ACAO_PROJETO ) 
					If( oProjeto:lSeek(1, { oPlano:cValue("ID_PROJ") }) )
						aAdd(aEmail, aMontaMail(oProjeto:cValue("ID_RESP"), oPlano, .T.))
					Endif
				Endif  

				//Notifica o respons�vel pela plano de a��o do qual a �a� faz parte. 
				If !( AllTrim(oPlano:cValue("ID_ASSUNTO")) == "0" )
					If( oGrupo:lSeek(1, { oPlano:cValue("ID_ASSUNTO") }) )
						aUser := {}
						If oGrupo:cValue("TP_RESP") == TIPO_GRUPO
							aUser := oUsuGrp:aUsersByGroup(oGrupo:cValue("ID_RESP"))
						Else
							aAdd(aUser,oGrupo:cValue("ID_RESP"))
						Endif

						For nI := 1 To Len(aUser)
							aAdd(aEmail, aMontaMail(aUser[nI], oPlano, .T.))
    					Next
					Endif
				Endif 		
			EndIf
			oPlano:_Next()
		EndDo
		
		For nCount := 1 To Len(aEmail)  
	    	If ( Len(aEmail[nCount]) > 0 )
	    		oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, aEmail[nCount][EMAIL_DESTINATARIO], cAssunto, aEmail[nCount][EMAIL_MENSAGEM], "", cFrom, "", "", cProtocol)
	    	EndIf
	    Next nCount  
		
		oPlano:cSQLFilter("")
	EndIf    
Return Nil 

/** 
Monta o conte�do da mensagem de e-mail para aviso de a��es vencidas. 
@Param cIdUsuario ID do Usu�rio para o qual o e-mail ser� enviado. 
@return aMail Array contendo o destinat�rio e a mensagem a ser enviada. 
*/
static function aMontaMail(cIDUser, oPlano,  lOwner)
	Local oUsuario		:= oKPICore:oGetTable("USUARIO")
	Local oProjeto		:= oKPICore:oGetTable("PROJETO") 
	Local oGrupo		:= oKPICore:oGetTable("GRUPO_ACAO")	
	Local cTo	 		:= ""
	Local cBody 		:= ""
	Local cDataFim 		:= AllTrim( oPlano:cValue("DATAFIM") ) 	
	Local aEmail 		:= {}
	Local nAtraso		:= (Date() - CToD(cDataFim))  
        
    Default lOwner 		:= .F. 
     
	//Localiza o usu�rio para o qual o e-mail ser� encaminhado. 
	If(oUsuario:lSeek(1, {cIDUser}))	
		cTo := alltrim(oUsuario:cValue("EMAIL"))

		cBody := alltrim(oUsuario:cValue("COMPNOME")) + ", "
		cBody += "<br>"   
		cBody += "<br>"
		cBody += STR0007 //"O A��o"  
		cBody += "<b>"                                                                                                                                                                                                                                                                                                                                                                      
		cBody += alltrim(oPlano:cValue("NOME")) 
		cBody += "</b>"   
		     
		//Verifica se a a��o faz parte de um projeto. 
		If( AllTrim( oPlano:cValue("TIPOACAO") ) == ACAO_PROJETO )
			If( oProjeto:lSeek(1, { oPlano:cValue("ID_PROJ") }) )
				cBody += STR0008 //" do projeto "
				cBody += "<b>" 
				cBody += AllTrim( oProjeto:cValue("NOME") ) 
				cBody += "</b>" 				
			Endif
		Endif  
		   
		//Verifica se a a��o faz parte de um plano de a��o.   
		If !( AllTrim(oPlano:cValue("ID_ASSUNTO")) == "0" )
			If( oGrupo:lSeek(1, { oPlano:cValue("ID_ASSUNTO") }) )
				cBody += STR0016 //" do plano de a��o "
				cBody += "<b>" 
				cBody += AllTrim( oGrupo:cValue("NOME") ) 
				cBody += "</b>" 				
			Endif
		Endif  		  
			 
		cBody += STR0009 //" venceu em "
		cBody += cDataFim 
		cBody += STR0010 //", estando hoje com "
		cBody += "<b>" 
		cBody += cBIStr(nAtraso)  
		cBody += "</b>" 
		cBody += STR0011 //" dia(s) de atraso. "  
		cBody += "<br>"     
						   
		//Informa ao criador quem � o executor.         
		If (lOwner) 
			If ( oUsuario:lSeek(1, {oPlano:cValue("ID_RESP")}) )    
				cBody += STR0015 //"O responsabilidade pela execu��o da a��o � de " 
				cBody += "<b>"  
	 	  		cBody += oUsuario:cValue("COMPNOME") + "."	
	 	  		cBody += "</b>" 
	 	  		cBody += "<br>"
			EndIf
		EndIf   

		cBody += STR0013 //"Favor tomar as provid�ncias necess�rias."    
		cBody += "<br>"
		cBody += "<br>"  
		cBody +=STR0014 //"TOTVS SGI - Sistema de Gest�o de Indicadores"
	EndIf    

	If(! Empty(cTo) ) 
		aAdd(aEmail, cTo) 
		aAdd(aEmail, cBody)
	EndIf	
Return aEmail