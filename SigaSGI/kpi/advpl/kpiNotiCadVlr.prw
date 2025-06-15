// ######################################################################################
// Projeto: KPI 
// Modulo : Agendador
// Fonte  : kpiNotiCadVlr.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 29.01.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpiNotiCadVlr.ch"

#define		_KPI_PATH		01 
#define		_DIA_LIMITE		02  
 
/**
Notificação de cadastro na planilha de valores.
@param aParams Parâmetros para inicializaão do KPICore. 
@return .T. 
*/
function kpiNotiCadVlr(aParms)
	local oParam	:= nil
	local oSchedule	:= nil

	public oKPICore
	public cKPIErrorMsg := ""

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	//Inicializando o KPICORE
	oKPICore := TKPICore():New(aParms[_KPI_PATH]) 
	
	ErrorBlock( {|oE| __KPIError(oE)})

	// Arquivo de log
	oKPICore:LogInit()
	oKPICore:Log(STR0001, KPI_LOG_SCRFILE) //"Iniciando a notificação para cadastro na planilha de valores."
	if(oKPICore:nDBOpen() < 0)
		oKPICore:Log(STR0002 + " (KpiNotiCadVlr)", KPI_LOG_SCRFILE)  //"Erro na abertura do banco de dados."
		return
	endif          
            
	oSchedule  := TKPIScheduler():New()
	oKPICore:oOwner(oSchedule)
    
	oParam := oKPICore:oGetTable("PARAMETRO")

	if oParam:getValue("BLOQ_POR_DIA_LIMITE") == 'T'
		kpiNotiDiaLim(aParms)
    else
	   	kpiNotiPlnVlr(aParms)
    endif
    
    oKPICore:Log(STR0013, KPI_LOG_SCRFILE) 	//"Finalizando a notificação para cadastro na planilha de valores."
return .t.

/*
*Funcao de alerta para cadastros na planilha de valores.
*/
function kpiNotiPlnVlr(aParms)
	local cServer 		:= "", cPorta := "", cConta := "", cAutUsuario := "", cAutSenha := "", cFrom := "", cMessage := "", cTo := "", cAssunto := ""
	local cInd				:= ""
	local cDepto 			:= ""
	local cPerAtual 		:= ""
	local cPerAnterior 	:= ""
	local cData			:= ""
	local oDepto			:= nil
	local oIndicador		:= nil   
	local oPlanilha		:= nil   
	local oUsuario		:= nil   
	local oConexao		:= nil 
	local aDtComp			:= {}   
	local aDtConv			:= {} 
	local aDtConvAnt		:= {}
	local cAno				:= strzero(year(date()),4)
	local cMes				:= strzero(month(date()),2)
	local cDia				:= strzero(aParms[_DIA_LIMITE],2) 
	local nFreqInd		:= 0    
	local nUltDiaMes		:= 0
	local lSendMail		:= .f.     
	local lAntSendMail	:= .f.      
	local oUsrGrp			:= nil
	Local cProtocol		:= "0"
	
	oIndicador	:= oKPICore:oGetTable("INDICADOR")    
 	oDepto	   	:= oKPICore:oGetTable("SCORECARD") 
	oPlanilha	:= oKPICore:oGetTable("PLANILHA")
	oUsuario	:= oKPICore:oGetTable("USUARIO")
	oConexao	:= oKPICore:oGetTable("SMTPCONF")

	oConexao:cSQLFilter("ID = '"+cBIStr(1)+"'") // Filtra o ID 1 onde tem a configuracao SMTP
	oConexao:lFiltered(.t.)
	oConexao:_First()
	If(!oConexao:lEof()) //posiciona cfg. da organização
		cServer		:= alltrim(oConexao:cValue("SERVIDOR"))
		cPorta			:= alltrim(oConexao:cValue("PORTA"))
		cConta			:= alltrim(oConexao:cValue("NOME"))
		cAutUsuario	:= alltrim(oConexao:cValue("USUARIO"))
		cAutSenha		:= alltrim(oConexao:cValue("SENHA"))
		cFrom			:= alltrim(oConexao:cValue("NOME"))
       cAssunto		:= STR0003 //"Atualização Pendente"
       cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))

		oIndicador:SetOrder(4)
		oIndicador:lSeek(4,{"0"})
		//conout("Dia Limite Default: " + cDia )
		//conout("Enviando e-mail para os indicadores:")

		while(	! oIndicador:lEof() )
			lAntSendMail := .f.
			lSendMail 	 := .f.
			cPerAtual	 := STR0014 //"Preenchido"
			cPerAnterior := STR0014 //"Preenchido" 
			nFreqInd 	 := oIndicador:nValue("FREQ")	

			//--------------------------------------------------------------------------------------
			// Se dia limite do indicador for zerado, não enviamos e-mail de alerta.
			//--------------------------------------------------------------------------------------
			If Val( oIndicador:cValue("DIA_LIMITE") ) > 0
				cDia := StrZero(oIndicador:nValue("DIA_LIMITE"),2)
				//Verifica se o dia cadastrado é maior que o ultimo dia do mês.
				nUltDiaMes := day(ctod("01/" + strzero(val(cMes) + 1,2) + "/" + cAno) -1)
				if val(cDia) > nUltDiaMes 
					cDia := strzero(nUltDiaMes,2)
				endif
						
			    if !(nFreqInd == KPI_FREQ_QUINZENAL .or. nFreqInd == KPI_FREQ_SEMANAL .or. nFreqInd == KPI_FREQ_DIARIA)
					cData := cDia + "/" + cMes + "/" + cAno            
					aDtConv := oPlanilha:aDateConv(xbiconvto("D",cData),  nFreqInd) //Data para efetuar busca na planilha
					aDtComp := aLastDtConv(xbiconvto("D",cData), nFreqInd) //Data verificar se esta dentro do periodo
					//Verifica se esta dentro do periodo
					if oPlanilha:nCompFreq(aDtComp,{cAno,cMes,strzero(day(date()),2)}) == -1
						if(oPlanilha:lSeek(2,{oIndicador:cValue("ID"),aDtConv[1],aDtConv[2],aDtConv[3]}))
							if oPlanilha:nValue("VALOR") == 0
								lSendMail := .t. 
								cPerAtual := STR0015 //"Não Preenchido"
							endif
						else
							lSendMail := .t.
							cPerAtual := STR0015 //"Não Preenchido"
						endif
					else                       
						cPerAtual := STR0016 + cData  //"Preencher até "
					endif  
					                           
					aDtConvAnt := aDtConvBack(aDtConv,nFreqInd)
					//Verifica se o periodo anterior foi preenchido
					if(oPlanilha:lSeek(2,{oIndicador:cValue("ID"),aDtConvAnt[1],aDtConvAnt[2],aDtConvAnt[3]}))
						if oPlanilha:nValue("VALOR") == 0
							lAntSendMail := .t.
							cPerAnterior := STR0015 //"Não Preenchido"
						endif
					else
						lAntSendMail := .t.
						cPerAnterior := STR0015 //"Não Preenchido"
					endif
					
					if lAntSendMail .or. lSendMail  
						//Localiza o departamento dono do indicador
						oDepto:lSeek(1, {oIndicador:cValue("ID_SCOREC")})
						cInd		:= alltrim(oIndicador:cValue("NOME"))
						cDepto 		:= alltrim(oDepto:cValue("NOME"))
						
						/*
						conout(" ")
						conout("Indicador........: " + cInd)
						conout("Departamento.....: " + cDepto)					
						conout("Dia limite...... : " + cDia)
						conout("Periodo atual ...: " + cPerAtual)
		        		conout("Periodo anterior.: " + cPerAnterior)
						*/          
						oUsrGrp := oKPICore:oGetTool("USERGROUP")
						cTo := oUsrGrp:getMailUser(oDepto:cValue("RESPID"),TIPO_USUARIO)    				// Dono do departamento
						cTo += ", " + oUsrGrp:getMailUser(oIndicador:cValue("ID_RESPCOL"),oIndicador:cValue("TP_RESPCOL"))	// Responsável pela coleta
						cTo += ", " + oUsrGrp:getMailUser(oIndicador:cValue("ID_RESP"),oIndicador:cValue("TP_RESP"))	// Responsável pelo indicador 
						
						if len(cTo) > 4
							cMessage := "<!--" 											+ CRLF   
							cMessage += STR0004 											+ CRLF //"SGI - Atualização na Planilha de Valores" 
							cMessage += "" 												+ CRLF
							cMessage += STR0005 											+ CRLF //"Os valores não foram preenchidos ou estão zerados para o indicador abaixo:"
							cMessage += STR0006 + cInd 	   								+ CRLF
							cMessage += STR0007 + cDepto 	   							+ CRLF
							cMessage += STR0008 + cDia 	   								+ CRLF
							cMessage += STR0009 + cPerAtual    						+ CRLF
							cMessage += STR0010 + cPerAnterior 						+ CRLF
							cMessage += "" 												+ CRLF
							cMessage += "" 												+ CRLF
							cMessage += STR0011 											+ CRLF
							cMessage += "" 												+ CRLF
							cMessage += "" 												+ CRLF
							cMessage += "-->" 											+ CRLF
							cMessage += "" 												+ CRLF
							cMessage += "<table>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td colspan='2' align='center'>" 		+ CRLF
							cMessage += "      <b>" + STR0004 + "</b>" 				+ CRLF //"SGI - Atualização na Planilha de Valores
							cMessage += "    </td>" 										+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td colspan='2'><br></td>" 				+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td colspan='2'>" + STR0005 + "</td>" 	+ CRLF //"Os valores não foram preenchidos ou estão zerados para o indicador abaixo:
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td colspan='2'><br></td>" 				+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td width='30%'><b>" 	+ STR0006 + "</b></td>"		+ CRLF //Indicador:
							cMessage += "    <td>" + cInd 		+ "</td>" 				+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td><b>" + STR0007 	+ "</b></td>" 				+ CRLF //Departamento:
							cMessage += "    <td>" + cDepto  	+ "</td>" 				+ CRLF
							cMessage += "  </tr>"		 								+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td><b>" + STR0008 	+ "</b></td>" 				+ CRLF //Dia limite: 
							cMessage += "    <td>" + cDia    	+ "</td>" 				+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td><b>" + STR0009 	+ "</b></td>" 				+ CRLF //Periodo atual:
							cMessage += "    <td>" + cPerAtual 	+ "</td>" 				+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td><b>" + STR0010 	+ "</b></td>" 				+ CRLF //Periodo anterior:
							cMessage += "    <td>" + cPerAnterior + "</td>" 			+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td colspan='2'><br></td>" 				+ CRLF
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "  <tr>" 										+ CRLF
							cMessage += "    <td colspan='2'>" + STR0011 + "</td>" 		+ CRLF //Favor tomar as providências necessárias.
							cMessage += "  </tr>" 										+ CRLF
							cMessage += "</table>" 										+ CRLF
							oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cMessage, "", cFrom, "", "", cProtocol)			
						endif    
					endif
				endif
			EndIf
			oIndicador:_Next()
		end while
	Else             
		oKPICore:Log(STR0012, KPI_LOG_SCRFILE) 	//"Não foi possível localizar as configurações do servidor de e-mail"
	EndIf
	oConexao:cSQLFilter("")    
return .t.
    
function kpiNotiDiaLim(aParms)
	local oIndicador	:= nil
	local oPlanilha	:= nil          
	local cTpUsu		:= TIPO_USUARIO
	local cTpGrp		:= TIPO_GRUPO  
	local nDiario		:= KPI_FREQ_DIARIA
	local nSemanal	:= KPI_FREQ_SEMANAL
	local nQuinzenal	:= KPI_FREQ_QUINZENAL
	local cTmp			:= GetNextAlias()
	local oConexao	:= nil  
	local dDtAtual	:= Date()      
	local aEmail		:= {}   
	local aUser		:= {}
	local aFreq		:= {}
	local aDataRef	:= {}
	local dDataRef    
	local nFreq
	local nMesPeriodo
	local dData  
	local cPeriodo    
	local dPrazo
    
	oConexao	:= oKPICore:oGetTable("SMTPCONF")

	If (oConexao:lSeek(1,{cBIStr(1)})) //Filtra o ID 1 onde tem a configuracao SMTP
		oIndicador	:= oKPICore:oGetTable("INDICADOR")
		oPlanilha	:= oKPICore:oGetTable("PLANILHA")
		
		//--------------------------------------------------------------------------------------------
		// Query abaixo irá retornar os indicadores e os usuários/grupos responsáveis por ele.
		//--------------------------------------------------------------------------------------------
		BeginSQL Alias cTmp

			SELECT	SGI015.FREQ,
					SGI015.DIA_LIMITE,
					SGI015.ID_RESPCOL,
					SGI002.EMAIL
			FROM	SGI015 JOIN SGI002 ON SGI015.ID_RESPCOL = SGI002.ID
			WHERE	SGI015.ID <> '0'					AND
					SGI015.ID_RESPCOL <> ' ' 			AND
					SGI015.TP_RESPCOL = %Exp:cTpUsu%	AND
					SGI015.FREQ NOT IN (%Exp:nQuinzenal%,
										%Exp:nSemanal%,
										%Exp:nDiario%)	AND
					SGI002.EMAIL <> ' '					AND
					SGI015.%notDel%						AND
					SGI002.%notDel%

			UNION

			SELECT	SGI015.FREQ,
					SGI015.DIA_LIMITE,
					SGI002B.IDUSUARIO AS ID_RESPCOL,
					SGI002.EMAIL
			FROM	SGI015	JOIN SGI002B 	ON SGI002B.PARENTID	 = SGI015.ID_RESPCOL
							JOIN SGI002		ON SGI002B.IDUSUARIO = SGI002.ID
			WHERE	SGI015.ID <> '0' 					AND
					SGI015.ID_RESPCOL <> ' ' 			AND
					SGI015.TP_RESPCOL = %Exp:cTpGrp%	AND
					SGI015.FREQ NOT IN (%Exp:nQuinzenal%,
										%Exp:nSemanal%,
										%Exp:nDiario%)	AND
					SGI002.EMAIL <> ' '					AND
					SGI015.%notDel%						AND
					SGI002.%notDel%						AND
					SGI002B.%notDel%

			ORDER BY ID_RESPCOL, FREQ, DIA_LIMITE

		EndSQL
                     
		While (cTmp)->(!EOF())
			nFreq 	 	:= oPlanilha:nConvFreq((cTmp)->(FREQ)) //retorna a frequencia em multiplo (mes=1; bimestre=2; trimestre=3; quadrimestre=4; semestre=6; etc)
			dDataRef	:= dDtAtual - (cTmp)->(DIA_LIMITE)
			aDataRef	:= oPlanilha:aDateConv(dDataRef ,(cTmp)->(FREQ)) //converte a data em (ano, mes, dia)
			
			nMesPeriodo	:= nFreq * Val(aDataRef[2])// ultimo mês do periodo

			if nMesPeriodo == 0 //para periodicidade anual o nMesPeriodo retorna 0
				nMesPeriodo := 12
			endif

			dData 	 	:= lastDay(cToD('01/'+cValToChar(nMesPeriodo)+'/'+aDataRef[1]))
			cPeriodo 	:= oIndicador:cGetPeriodo((cTmp)->(FREQ), dData) //nome do periodo

			dPrazo	 	:= dData + (cTmp)->(DIA_LIMITE) //data somada o dia limite

			aUser 	 	:= aBuscaArray(aEmail	, (cTmp)->(ID_RESPCOL), (cTmp)->(EMAIL)) //verifica se o usuario ja existe, senao adiciona
			aFreq 	 	:= aBuscaArray(aUser	, nFreq, oIndicador:cNomePeriodo((cTmp)->(FREQ))) //verifica se ja existe a frequencia para o usuario
			aPeriodo 	:= aBuscaArray(aFreq	, cPeriodo) //verifica se existe o periodo para o usuario

			aAdd(aPeriodo, dPrazo) //adiciona o prazo de atualizacao
			
			(cTmp)->(dbSkip())
		EndDo

		(cTmp)->(dbCloseArea()) //fecha a tabela temporaria

		ordenaArray(aEmail) //Ordena o array

		enviaEmail(aEmail,oConexao)
	else
		oKPICore:Log(STR0012, KPI_LOG_SCRFILE) 	//"Não foi possível localizar as configurações do servidor de e-mail"
	endif
return .t.

static function enviaEmail(aDados, oConexao)
	local cPathSite	:= oKPICore:cKpiPath()+"imagens\"
	local cServer 	:= ""
	local cPorta 		:= ""
	local cConta 		:= ""
	local cAutUsuario	:= ""
	local cAutSenha 	:= ""
	local cFrom 		:= ""   
	local cAnexos		:= ""
	local cAssunto 	:= ""
	local cMessage 	:= ""
	local cTo 			:= ""
	local aUser		:= {}
	local nI
	Local cProtocol	:= "0"

	cServer		:= AllTrim(oConexao:cValue("SERVIDOR"))
	cPorta			:= AllTrim(oConexao:cValue("PORTA"))
	cConta			:= AllTrim(oConexao:cValue("NOME"))
	cAutUsuario	:= AllTrim(oConexao:cValue("USUARIO"))
	cAutSenha		:= AllTrim(oConexao:cValue("SENHA"))
	cFrom			:= AllTrim(oConexao:cValue("NOME"))
	cProtocol		:= AllTrim(cBIStr(oConexao:nValue("PROTOCOLO")))
	cAnexos 		:= cPathSite+"art_logo_clie.sgi"
	cAssunto		:= STR0022 //"Prazo final para preenchimento da planilha de valores"

	for nI := 1 to Len(aDados)
		aUser	:= aDados[nI]  
		cTo 	:= Alltrim(aUser[3]) //pega o e-mail

		cMessage := cTextCabec() //adiciona o cabecalho do e-mail
   		cMessage += cTextParam() //adiciona o texto definido no parametro MSG_BLOQ_DIA_LIMITE
		cMessage += cTextFreq(aUser[2]) //monta as tabelas de frequencia

		oConexao:SendMail(cServer, cPorta, cConta, cAutUsuario, cAutSenha, cTo, cAssunto, cMessage, cAnexos, cFrom, "", "", cProtocol)
	Next
return

static function cTextCabec()
	local cCabec
	
	cCabec := "<table width='100%' border='0' cellpadding='0' cellspacing='0'>"

	cCabec += "<tr>"
	cCabec += "<td width='10%'><img src='art_logo_clie.sgi'></td>"
	cCabec += "<td width='40%' style='color: #406496; font-weight: bold; font-size: 18px; font-family: Verdana, Arial, Helvetica, sans-serif;'><div align='center'>"+KPIEncode(STR0017)+"<br></br>" //E-Mail de Notificacao
	cCabec += "<td width='10%'>&nbsp;</td>"
	cCabec += "</tr>" 
	cCabec += "</table>"
return cCabec

static function cTextParam()
	local oParam	:= oKpiCore:oGetTable("PARAMETRO")
	local cParam	:= oParam:GetValue("MSG_BLOQ_DIA_LIMITE")
	local cMsgParam := ""
		                                                   
	cParam := KPIEncode(cParam)
	cParam := StrTran(cParam, CRLF		,'<br/>')
	cParam := StrTran(cParam, Chr(13)	,'<br/>')
	cParam := StrTran(cParam, Chr(10)	,'<br/>')
		
	cMsgParam := "<table width='100%' cellpadding='0' cellspacing='0'>"
	cMsgParam += "<hr colspan='4' Width='100%' Size='3' noshade style='color: #000000;'/>"
		
	cMsgParam += "<tr>"
	cMsgParam += "<td height='10' colspan='3'>&nbsp;</td>"
	cMsgParam += "</tr>"
		
	cMsgParam += "<tr>"
	cMsgParam += "<td width='10%' height='30'>&nbsp;</td>"
	cMsgParam += "<td width='60%' valign='top'><em>"+cParam+"</em></td>"
	cMsgParam += "<td width='30'>&nbsp;</td>"
	cMsgParam += "</tr>"
		
	cMsgParam += "<tr>"
	cMsgParam += "<td height='30' colspan='3'>&nbsp;</td>"
	cMsgParam += "</tr>"                
	
	cMsgParam += "</table>"
return cMsgParam  

static function cTextFreq(aDados)
	local cRet               
	local aFreq	:= {}
	local nI

	cRet := "<table width='100%' cellpadding='0' cellspacing='0'>"	

	for nI := 1 to Len(aDados)
		aFreq	:= aDados[nI]  

		cRet += "<tr>"
		cRet += "<td height='10' colspan='3'>&nbsp;</td>"
		cRet += "</tr>"
	
		cRet += "<tr>"
		cRet += "<td width='10%' height='30'>&nbsp;</td>"
		cRet += "<td width='60%' valign='top'>"+KPIEncode(STR0018)+" <em>"+KPIEncode(aFreq[3])+"</em> "+KPIEncode(STR0019)+"</td>"//"Indicadores com periodicidade (frequência)"/"com os seguitnes prazos:"
		cRet += "<td width='30'>&nbsp;</td>"
		cRet += "</tr>"
		
		cRet += "<tr>"
		cRet += "<td height='10' colspan='3'>&nbsp;</td>"
		cRet += "</tr>"
	
		cRet += cTextPeri(aFreq[2])
	Next
	
	cRet += "</table>"    
return cRet            

static function cTextPeri(aDados)
	local cRet      
	local aPeriodo	:= {}
	local nI
	    
	cRet := "<tr>"
	cRet += "<td width='5%'>&nbsp;</td>"
	cRet += "<td width='65%'>"
	cRet += "<table width='50%' align='center' border='1' cellpadding='0' cellspacing='0' bordercolor='#537AA2'>"
	
	cRet += "<tr>"
	cRet += "<td width='50%' align='center' bgcolor='#4F81BD'><b>"+KPIEncode(STR0020)+"</b></td>" //Periodo
	cRet += "<td width='50%' align='center' bgcolor='#4F81BD'><b>"+KPIEncode(STR0021)+"</b></td>" //Prazo para atualizacao
	cRet += "</tr>"
	
	for nI := 1 to Len(aDados)
		aPeriodo := aDados[nI]
		
		cRet += "<tr>"
		cRet += "<td width='50%' align='center' rowspan='"+Alltrim(str(Len(aPeriodo[2])))+"'>"+KPIEncode(aPeriodo[1])+"</td>"
		cRet += "<td width='50%' align='center'>"+KPIEncode(dToC(aPeriodo[2][1]))+"</td>"
		cRet += "</tr>"
		
		cRet += cTextPrazo(aPeriodo[2],2)
	Next
        
	cRet += "</table>"
	cRet += "</td>"
	cRet += "<td width='30%'>&nbsp;</td>"
	cRet += "</tr>"
return cRet

static function cTextPrazo(aPrazo, nIndice)
	local cRet := ""                          
	local nI    
	
	for nI := nIndice to Len(aPrazo)
		cRet := "<tr>"
		cRet += "<td width='50%' align='center'>"+KPIEncode(dToC(aPrazo[nI]))+"</td>"
		cRet += "</tr>"
	Next
return cRet

static function aBuscaArray(aSrc, cCampo, xExtra)
	local aRet := {}
	local nPos

	default xExtra := nil

	nPos := aScan(aSrc,{|x| x[1] == cCampo})
	
	if nPos > 0 //achou
	    aRet := aSrc[nPos] 
	else 
		aRet := array(3)
		
		aRet[1] := cCampo
		aRet[2] := {}
		aRet[3] := xExtra

		aAdd(aSrc, aRet)
	endif
return aRet[2]  

static function ordenaArray(aDados)
	local nTpOrd	:= 1
	local nInd 		:= 0	
	local xAux 		:= nil

	for nInd := 1 to len(aDados)
		xAux := aDados[nInd]
		if valType(xAux) == "A"
			ordenaArray(xAux[2])
		else
			nTpOrd := 2
			exit
		endif  
	next nInd
	
	if nTpOrd == 1
		aSort(aDados,,,{|x,y| x[1] < y[1]})
	else
		aSort(aDados)
	endif
return


// Devolve a data convertida do ultimo periodo.
static function aLastDtConv(dData, nFrequencia)
	local nTempMes 	:= 0
	local cAno 		:= "0000"
	local cMes 		:= "00"
	local cDia 		:= strzero(day(dData),2)
	
	if(nFrequencia == KPI_FREQ_ANUAL)
		cAno := strzero(year(dData), 4)
		cMes := 12
	elseif(nFrequencia == KPI_FREQ_SEMESTRAL)
		nTempMes := iif(month(dData)>6, 12, 6)
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
	elseif(nFrequencia == KPI_FREQ_QUADRIMESTRAL)
		nTempMes := iif(month(dData)<=4, 4, iif(month(dData)<=8, 8, 12))
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
	elseif(nFrequencia == KPI_FREQ_TRIMESTRAL)
		nTempMes := iif(month(dData)<=3, 3, iif(month(dData)<=6, 6, iif(month(dData)<=9, 9, 12)))
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
	elseif(nFrequencia == KPI_FREQ_BIMESTRAL)
		nTempMes := iif(month(dData)<=2, 2, iif(month(dData)<=4, 4, iif(month(dData)<=6, 6, ;
					iif(month(dData)<=8, 8, iif(month(dData)<=10, 10, 12)))))
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
	elseif(nFrequencia == KPI_FREQ_MENSAL)
		nTempMes := month(dData)
		cAno := strzero(year(dData),4)
		cMes := strzero(nTempMes,2)
	endif
return {cAno, cMes, cDia}                      


// Retorna o periodo anterior 
static function aDtConvBack(aDtConv, nFrequencia)
	local nAno 		:= val(aDtConv[1])
	local nMes 		:= val(aDtConv[2])
	
	// Atenção - Manter cAno, cMes e cDia com zeros na frente para evitar erros de indice
	if(nFrequencia == KPI_FREQ_ANUAL)      
		aDtConv[1] := strzero(nAno -1,4)
	elseif(nFrequencia == KPI_FREQ_SEMESTRAL)
		if aDtConv[2] == "01" 
			aDtConv[1] := strzero(nAno -1,4)
			aDtConv[2] := "02"		
		else  
			aDtConv[2] := "01"
		endif
	elseif(nFrequencia == KPI_FREQ_QUADRIMESTRAL)
		if aDtConv[2] == "01" 
			aDtConv[1] := strzero(nAno -1,4)
			aDtConv[2] := "03"		
		else  
			aDtConv[2] := strzero(nMes -1,2)
		endif
	elseif(nFrequencia == KPI_FREQ_TRIMESTRAL)   
		if aDtConv[2] == "01" 
			aDtConv[1] := strzero(nAno -1,4)
			aDtConv[2] := "04"		
		else  
			aDtConv[2] := strzero(nMes -1,2)
		endif
	elseif(nFrequencia == KPI_FREQ_BIMESTRAL)
		if aDtConv[2] == "01" 
			aDtConv[1] := strzero(nAno -1,4)
			aDtConv[2] := "06"		
		else  
			aDtConv[2] := strzero(nMes -1,2)
		endif
	elseif(nFrequencia == KPI_FREQ_MENSAL)
		if aDtConv[2] == "01" 
			aDtConv[1] := strzero(nAno -1,4)
			aDtConv[2] := "12"		
		else  
			aDtConv[2] := strzero(nMes -1,2)
		endif
	endif
return aDtConv