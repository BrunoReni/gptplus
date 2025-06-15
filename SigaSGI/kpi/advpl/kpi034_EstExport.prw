/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpi033_EstExport.prw
// ---------+---------------------+------------------------------------------------------
// Data     | Autor               | Descricao
// ---------+---------------------+------------------------------------------------------
// 09.04.08 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI034_EstExport.ch"

/*--------------------------------------------------------------------------------------
@entity Estrutura
Exportação de metadados.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY 	 "ESTEXPORT"
#define TAG_GROUP  	 "ESTEXPORTS"

//Constante para privilégio de indicador. 
#define PUBLICO 	 "F"
#define PRIVADO 	 "T"                  

//Constante para identificação do ID do nó principal. 
#define NO_PRINCIPAL "0"
             
//Constante para controle de status de execução. 
#define PARADO  		0 
#define EXECUTANDO  	1
#define FINALIZADO  	2
#define PARANDO  		3 
              
//Constante de controle global do cálculo dos indicadores. 
#define GLOBAL_LOCK   "bKpiExpLock"      

class TKPIEstExport from TBITable
	data cJobName
	data cGlbStopCal 
	data calcLog
	
	method New() constructor
	method NewEstExport()
	method oToXMLNode(cID,cRequest) 
	method nExecute(cID, cRequest)
	method lCal_CriaLog(cPathSite,cLogName) 
	method lCal_WriteLog()
	method lCal_CloseLog()
	method unlockExport(nHandle)
	method saveScoXml(cIdSco) 
	method saveIndXml(cIdSco)
	method saveDtSrcXml()
	method saveSchedXml()
	method changeSpecialChar()
endclass
	
method New() class TKPIEstExport
	::NewEstExport()
return

method NewEstExport() class TKPIEstExport
	::cJobName		:=	alltrim(getJobProfString("INSTANCENAME", "SGI")+"_SgiEstExp.lck")
	::NewObject() 
return

/*--------------------------------------------------------------------------------------
Carrega o no requisitado.
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com os dados
--------------------------------------------------------------------------------------*/
method oToXMLNode(cID,cRequest) class TKPIEstExport
	local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)    
	local oXMLArqs 		:=	TBIXMLNode():New("ARQUIVOS")    
	local oNodeLine     :=  nil
    local cFileLocal 	:=  ""
    local aFiles 		:=  {}
    local nStatus		:=	PARADO 
    local nItemFile		:=  1
    local nHandle		:=	fCreate(::cJobName,1)  

	if(!empty(getGlbValue(GLOBAL_LOCK)))
		nStatus	:= PARANDO
	elseif(nHandle == -1)
		nStatus	:=	EXECUTANDO
	else
		nStatus	:=	PARADO  
		::unlockExport(nHandle)		
	endif                                         
	
	oXMLNode:oAddChild(TBIXMLNode():New("STATUS", nStatus))	
         
	cFileLocal 	:=  oKpiCore:cKpiPath() + "METADADOS\*.XML"
    aFiles 		:=  directory(cFileLocal) 
    
	for nItemFile := 1 to len(aFiles)
		oNodeLine := oXMLArqs:oAddChild(TBIXMLNode():New("ARQUIVO"))
		oNodeLine:oAddChild(TBIXMLNode():New("ID",		lower(aFiles[nItemFile][1])))
		oNodeLine:oAddChild(TBIXMLNode():New("NOME",	lower(aFiles[nItemFile][1])))
		oNodeLine:oAddChild(TBIXMLNode():New("SIZE",	str(aFiles[nItemFile][2]/1024,10,2)+ " Kb"))
		oNodeLine:oAddChild(TBIXMLNode():New("DATE",	dToc(aFiles[nItemFile][3]) + " " + aFiles[nItemFile][4]))
	next nItemFile     
	
	oXMLNode:oAddChild(oXMLArqs) 	
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(,.T.))
return oXMLNode

/*--------------------------------------------------------------------------------------
Excucata o comando do client
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com o status da execução
--------------------------------------------------------------------------------------*/
method nExecute(cID, cRequest)  class TKPIEstExport
	local cPathSite		:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	local aRet			:= {}
	local nHandle		:= 0	
	local oProgress		:= nil          
	default cRequest 	:= ""	
	
	if(cRequest == "JOBSTOP")
		putGlbValue(GLOBAL_LOCK, "STOP")
	else
		//Verifica se o job esta em execucao
		nHandle	:=	fCreate(::cJobName,1)
		if(nHandle != -1)
			::unlockExport(nHandle)
			
			//Limpa Flag global de execução 				  
			putGlbValue(GLOBAL_LOCK,"")
			
			oProgress := KPIProgressbar():New("kpiestexp_1")
			oProgress:setMessage(STR0001) 
			//STR0001 -> "Iniciando Exportação..."
			oProgress:setPercent(05)

			oKPICore:Log(STR0001, KPI_LOG_SCRFILE)
			aRet := aBIToken(cRequest,"|",.f.)	//Parametros   
			aadd(aRet,cPathSite)				//Site do KPI
			aadd(aRet,::oOwner():cKpiPath())	//Kpi Path
			
			StartJob("kpiExp_Metadados", GetEnvServer(), .f., aRet)
		else
			oKPICore:Log(STR0002, KPI_LOG_SCRFILE) 
			//STR0002 -> "Atenção. Existe uma importação de estrutura em andamento."
		endif
	endif

return KPI_ST_OK


/*--------------------------------------------------------------------------------------
Cria o arquivo de log
@param cPathSite	- caminho do site
@param cLogName 	- Log
@return 	   		- .t.
--------------------------------------------------------------------------------------*/
method lCal_CriaLog(cPathSite,cLogName) class TKPIEstExport
	cPathSite	:=	strtran(cPathSite,"\","/")
	::calcLog	:= 	TBIFileIO():New(oKpiCore:cKpiPath()+"logs\metadados\export\"+ cLogName + ".html")

	// Cria o arquivo htm
	If ! ::calcLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0003) //"Erro na criacao do arquivo de log."
	else
		::calcLog:nWriteLN('<html>')
		::calcLog:nWriteLN('<head>')
		::calcLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
  		::calcLog:nWriteLN('<title>'+STR0004+'</title>') //"SGI - Log de exportação"
		::calcLog:nWriteLN('<link href= "'+ cPathSite + 'imagens/report.css" rel="stylesheet" type="text/css">')
		::calcLog:nWriteLN('</head>')
		::calcLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::calcLog:nWriteLN('<table width="90%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td class="titulo"><div align="center">'+STR0004+ '</div></td>') //"SGI - Log de exportação"
		::calcLog:nWriteLN('</tr>')
		::calcLog:nWriteLN('</table>')
		::calcLog:nWriteLN('<table width="90%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0005+'</td>') //"Data"
		::calcLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0006+'</td>') //"Eventos"
		::calcLog:nWriteLN('</tr>')
	endif

return .t.

  
/*--------------------------------------------------------------------------------------
Grava um evento no log.
@param cMensagem	- Texto a ser gravado no log
@param cLogName 	- Log
@return 	   		- .t.
--------------------------------------------------------------------------------------*/
method lCal_WriteLog(cMensagem) class TKPIEstExport

	  ::calcLog:nWriteLN('<tr>')
	  ::calcLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	  ::calcLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	  ::calcLog:nWriteLN('</tr>')
      
      oKPICore:Log(cMensagem)
return .t.


/*--------------------------------------------------------------------------------------
Fecha o arquivo de log.
@return	- .t.
--------------------------------------------------------------------------------------*/
method lCal_CloseLog() class TKPIEstExport
	::calcLog:nWriteLN('</table>')
	::calcLog:nWriteLN('<br>')
	::calcLog:nWriteLN('</body>')
	::calcLog:nWriteLN('</html>')
	::calcLog:lClose()
	
return .t.

/*-------------------------------------------------------------------------------------
Exportação de metados
@param aParms		- array com parametros
@return 	   		- boolean
--------------------------------------------------------------------------------------*/
function kpiExp_Metadados(aParms)
	Local oExport		:= nil
	Local cLogName		:= ""
	Local nQtd			:= 0 
	Local nTotSco		:= 0
	Local nHandle		:= 0
	Local oProgress		:= nil
	Local lPrivado 		:= xBIConvTo("L", DwStr(aParms[3]))
	Local lFonte 		:= xBIConvTo("L", DwStr(aParms[5]))  
	Local lAgendamento	:= xBIConvTo("L", DwStr(aParms[6]))   
	 
	Private cLicense	:= Alltrim(DwStr(aParms[4]))	
	private aIdSco		:= {} 
	private oFileXml	:= nil

	//Configuracoes do ambiente.
	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on           

	//Instanciando KPICore
	oKPICore := TKPICore():New(aParms[8])
	ErrorBlock( {|oE| __KPIError(oE)})          

	//Abre conexão
	if(oKPICore:nDBOpen() < 0)
		oKPICore:Log(STR0007, KPI_LOG_SCRFILE) 
		//"Erro na abertura do banco de dados"
		oProgress:setStatus(PROGRESS_BAR_ERROR) 
   		oProgress:setMessage(STR0007) 
   		//"Erro na abertura do banco de dados"
		return
	endif
	
	//Instancia oExport
	oExport	:= oKPICore:oGetTable("ESTEXPORT")
	
	//Verifica se o job esta em execucao
	nHandle	:=	fCreate(oExport:cJobName,1)
	if(nHandle == -1)
		oKPICore:Log(STR0002, KPI_LOG_SCRFILE) 	
		//"Atenção. Existe uma exportação de estrutura em andamento." 
		return
	endif     
	
	//Criando do arquivo de log.
	cLogName += alltrim(getJobProfString("INSTANCENAME", "SGI"))+"_"
	cLogName += strtran(dToc(date()),"/","") +"_"
	cLogName += strtran(time(),":","")
	oExport:lCal_CriaLog(aParms[7],cLogName) 
	oExport:lCal_WriteLog(STR0001) 
	//"Iniciando exportação..."
	
	//Criando arquivo xml.
	oFileXml := TBIFileIO():New(oKPICore:cKpiPath()+"metadados\"+aParms[1]+".xml")
	if oFileXml:lCreate(FO_READWRITE,.t.) 
		oFileXml:nWriteln('<?xml version="1.0" encoding="ISO-8859-1" ?>')
		oFileXml:nWriteln('<METADADOS>')
  		
  		//Verifica se está sendo criado Metadado Proprietário.
    	If (lPrivado)
	 		//Cria a tag com o LicenseKey do Cliente.
        	oFileXml:nWrite('<LICENSE>')
			//Escreve o LicenseKey criptografado no Metadado.
			oFileXml:nWrite( DWCripto( AllTrim(cLicense),Len(cLicense) ))
			//Fecha a tag LICENSE.
			oFileXml:nWriteln('</LICENSE>')
	    EndIf
	    
		//"Exportando departamentos..."
		oProgress := KPIProgressbar():New("kpiestexp_1")
		oProgress:setMessage(STR0009) 
		oProgress:setPercent(15)
		oFileXml:nWriteln('<DEPARTAMENTOS>') 
		oExport:saveScoXml(aParms[2])
		oFileXml:nWriteln('</DEPARTAMENTOS>') 
		
		//"Exportando indicadores..."
		oProgress:setMessage(STR0010)
		oProgress:setPercent(40)
		oFileXml:nWriteln('<INDICADORES>')
		nTotSco := len(aIdSco)
		for nQtd := 1 to nTotSco
			oExport:saveIndXml(aIdSco[nQtd], lPrivado)
			oProgress:setPercent( 40 + round(((nQtd * 55)/nTotSco),0) )
		next
		oFileXml:nWriteln('</INDICADORES>')
                
		oProgress:setPercent(60)

		If (lFonte)   
			oProgress:setMessage(STR0018 + "...") 
			//STR0018 -> "Exportando Fonte de Dados"
			oExport:saveDtSrcXml()
		EndIf
       
		oProgress:setPercent(80)  
	  		
		If (lAgendamento) 
			oProgress:setMessage(STR0019 + "...") 
			//STR0019 -> "Exportando Agendamento"
			oExport:saveSchedXml()
		EndIf   

		oFileXml:nWriteln('</METADADOS>')
		oFileXml:lClose()
	else
		oExport:lCal_WriteLog(STR0011 + "<br>" + STR0012)
	endif
	
	oKPICore:Log(STR0013, KPI_LOG_SCRFILE) 	
	//"Finalizando Exportação..."
	oExport:lCal_WriteLog(STR0014)		   
	//"Exportação finalizada"
	oExport:lCal_CloseLog() 
	oProgress:setMessage(STR0014) 
	oProgress:setPercent(100)
	oProgress:endProgress()  
	
	//Limpa Flag global de execução 				  
	putGlbValue(GLOBAL_LOCK,"")
	
	//Libera o job em execução	
	oExport:unlockExport(nHandle)
			
	// Espera 1 segundo para finalizar e dar tempo para o retorno ao KPI		
	sleep(1000)	
return .T.


/*-------------------------------------------------------------------------------------
Função recursiva para gravar os scorecards no formato xml
@param cIdSco		- ID do scorecard
@return 	   		- nil
--------------------------------------------------------------------------------------*/
method saveScoXml(cIdSco) class TKPIEstExport
	local oScoreCard	:= oKpiCore:oGetTable("SCORECARD")  
	local aSavePos		:= {} 
	local aFields		:= {}
	local nQtd			:= 0 

	local oEntity		:= nil
 	local cEntity		:= ""
	local cTipoScore	:= ""
	
	local cMsgAux		:= ""

	if oScoreCard:lSeek(1,{cIdSco})
		//Impede a exportação do nó principal do Scorecard [NO_PRINCIPAL = '0'].
		if !(AllTrim(oScoreCard:cValue("ID")) == NO_PRINCIPAL)			
		
			cTipoScore := oScoreCard:cValue("TIPOSCORE")
			do case
				case cTipoScore == CAD_ORGANIZACAO
					cMsgAux := STR0020		//###"Exportando Organização: "
				
				case cTipoScore == CAD_ESTRATEGIA
					cMsgAux := STR0021		//###"Exportando Estratégia: "
				
				case cTipoScore == CAD_PERSPECTIVA
					cMsgAux := STR0022		//###"Exportando Perspectiva: "
				
				case cTipoScore == CAD_OBJETIVO
					cMsgAux := STR0023		//###"Exportando Objetivo: "

				otherwise
					cMsgAux := STR0015		//###"Exportando departamento: "
			endcase

			::lCal_WriteLog(cMsgAux + alltrim(oScoreCard:cValue("NOME")))
			
			//Alimenta o array que será iterado para a exportação dos indicadores.
			aadd(aIdSco,oScoreCard:cValue("ID"))
			aFields := oScoreCard:xRecord(RF_ARRAY)

			oFileXml:nWriteln('<DEPARTAMENTO>')  

			for nQtd := 1 to len(aFields)           
				oFileXml:nWrite('<'+aFields[nQtd][1]+'>')
				oFileXml:nWrite(::changeSpecialChar(aFields[nQtd][2]))
				oFileXml:nWriteln('</'+aFields[nQtd][1]+'>')
			next

			//Entidades BSC
			if !Empty(cTipoScore)
				cEntity := oKpiCore:entityByCode(cTipoScore)

				oEntity := oKpiCore:oGetTable(cEntity)

				// Adiciona campos das entidades no XML 
				aFields := oEntity:xRecord(RF_ARRAY, {"ID"})
				for nQtd := 1 to len(aFields)           
					oFileXml:nWrite('<'+aFields[nQtd][1]+'>')
					oFileXml:nWrite(::changeSpecialChar(aFields[nQtd][2]))
					oFileXml:nWriteln('</'+aFields[nQtd][1]+'>')
				next
			endif

			oFileXml:nWriteln('</DEPARTAMENTO>')    
		endif
	endif
   
	//Verifica se o Scorecard tem nós filhos. [Chave = PARENTID].  	        
	if oScoreCard:lSeek(2,{ iif(AllTrim(oScoreCard:cValue("ID")) == NO_PRINCIPAL, '',oScoreCard:cValue("ID")) })
		//Itera pelos Scorecards, buscando os filhos, recursivamente.
		while(Alltrim(oScoreCard:cValue("PARENTID")) == Iif((cIdSco) == NO_PRINCIPAL, '',cIdSco) .and. ! oScoreCard:lEof())                 
			aSavePos := {IndexOrd(), recno(), oScoreCard:cSqlFilter()}
			::saveScoXml(oScoreCard:cValue("ID"))
			oScoreCard:faSavePos:= aSavePos
			oScoreCard:RestPos()
			oScoreCard:_Next()
		enddo		
	endif
return

/*-------------------------------------------------------------------------------------
Função recursiva para gravar os indicadores no formato xml
@param cIdSco		- ID do scorecard
@return 	   		- nil
--------------------------------------------------------------------------------------*/
method saveIndXml(cIdSco, lPrivado) class TKPIEstExport
	Local oIndicador := oKpiCore:oGetTable("INDICADOR")
	Local aFields	 := {}
	Local nQtd		 := 0
	Local cFormula	 := '' 
   	Local lCriptografado := .F.
          
	Default lPrivado := .F.

	If oIndicador:lSeek(3,{cIdSco}) //Tem nos filhos
			
		While(oIndicador:cValue("ID_SCOREC") == cIdSco .and. ! oIndicador:lEof()) 
		    //Verifica se o indicador já está criptografado ou se foi exportado como proprietário.
		    lCriptografado := oIndicador:lValue("ISPRIVATE")
			//Exporta apenas os indicadores PUBLICO [F].			 	 
		   	If !(lCriptografado)	  			
				//Loga a informação do indicador que está sendo exportado.
				::lCal_WriteLog(STR0016 + alltrim(oIndicador:cValue("NOME"))) 
				//Recupera a estrutura do indicador.
				aFields := oIndicador:xRecord(RF_ARRAY)            
	            //Inicia a exportação de um novo indicador.
				oFileXml:nWriteln('<INDICADOR>')		
				for nQtd := 1 to len(aFields)           
				    //Abre a tag do atributo que está sendo exportado.
					oFileXml:nWrite('<'+aFields[nQtd][1]+'>')		
					//Trata a formula na exportação do metadados.
					If (Upper(aFields[nQtd][1]) == "FORMULA")						
						//Recupera o conteúdo da fórmula em uma variável para ser reutilizada.
						cFormula := Alltrim(DwStr(aFields[nQtd][2]))
	                    //Verifica se o indicador possui fórmula e se a exportação está marcada como privada.						
						if !(Vazio(cFormula)) .And. (lPrivado)
							//Criptografa o conteúdo da formula.			         
							oFileXml:nWrite(KPICripto(cFormula, cLicense))
						Else  
							oFileXml:nWrite(cFormula)
						EndIf

					//Trata a exportação de campos PRIVADO [T].
					ElseIf (Upper(aFields[nQtd][1]) == 'ISPRIVATE')
						//Rasteira a posição do atributo fórmula que será usada para recuperar o valor.						
						nPos := aScan(aFields, {|x| DwStr(x[1]) == "FORMULA"})
	   					//Verifica se o indicador possui fórmula e se a exportação está marcada como privada.
						If !(Vazio(aFields[nPos][2])) .AND. (lPrivado)
							//Marca o indicador como PRIVADO ('T').
							oFileXml:nWrite(PRIVADO) 
						Else
							oFileXml:nWrite(PUBLICO)
						EndIf

					else       

						if valtype(aFields[nQtd][2]) == "C"
							oFileXml:nWrite(::changeSpecialChar(aFields[nQtd][2]))
						else 
							oFileXml:nWrite(alltrim(DwStr(aFields[nQtd][2])))
						endif 						  
					EndIf

					//Fecha a tag do atributo que está sendo exportado.
					oFileXml:nWriteln('</'+aFields[nQtd][1]+'>')
				next 
			 
				//Finaliza a exportação de um novo indicador.
				oFileXml:nWriteln('</INDICADOR>')
			Else
				//Loga a informação do indicador que não poderá ser exportado.
				::lCal_WriteLog( STR0017 + alltrim(oIndicador:cValue("NOME"))) 
				//STR0017 -> "Ignorando indicador protegido: "
			EndIf
			
			oIndicador:_Next()
		enddo		
	endif
return

/*-------------------------------------------------------------------------------------
Método para gravar as fontes de dados no formato xml
@return 	   		- nil
--------------------------------------------------------------------------------------*/
method saveDtSrcXml() class TKPIEstExport
	
	Local oDataSrcs := oKpiCore:oGetTable("DATASRC")    
	Local aFields, nQtd

	oFileXml:nWriteln('<DATASRCS>')
	
	aFields := oDataSrcs:xRecord(RF_ARRAY)
	
	oDataSrcs:_First()
	While ! oDataSrcs:lEoF()
		//Verifica pelo registro vazio/principal
        If ! allTrim(oDataSrcs:cValue("ID")) == NO_PRINCIPAL
			//Loga a informação do indicador que está sendo exportado..
			::lCal_WriteLog(STR0018 + ": " + alltrim(oDataSrcs:cValue("NOME"))) 
			//STR0018 -> "Exportando Fonte de Dados"
			
	        //Inicia a exportação de uma novo fonte de dados.
	        oFileXml:nWriteln('<DATASRC>')
			for nQtd := 1 to len(aFields)           
			    //Abre a tag do atributo que está sendo exportado.
				oFileXml:nWrite('<'+aFields[nQtd][1]+'>')		
	
				oFileXml:nWrite(::changeSpecialChar( oDataSrcs:cValue(aFields[nQtd, 1]) ))
	
				//Fecha a tag do atributo que está sendo exportado.
				oFileXml:nWriteln('</'+aFields[nQtd][1]+'>')
			next  
			//Finaliza a exportação de um novo indicador.
			oFileXml:nWriteln('</DATASRC>')
		EndIf
				
		oDataSrcs:_Next()
	enddo		
	
	oFileXml:nWriteln('</DATASRCS>')
	
return

/*-------------------------------------------------------------------------------------
Método para gravar os agendamentos no formato xml
@return 	   		- nil
--------------------------------------------------------------------------------------*/
method saveSchedXml() class TKPIEstExport
	Local oScheduler := oKpiCore:oGetTable("AGENDAMENTO")
	Local aFields, nQtd

	oFileXml:nWriteln('<AGENDAMENTOS>')	
	aFields := oScheduler:xRecord(RF_ARRAY)
	
	oScheduler:_First()
	While ! oScheduler:lEoF()
        //Verifica pelo registro vazio/principal
        If ! allTrim(oScheduler:cValue("ID")) == NO_PRINCIPAL
        	//Loga a informação do indicador que está sendo exportado.
			::lCal_WriteLog(STR0019 + ": " + alltrim(oScheduler:cValue("NOME"))) 
			//STR0019 -> "Exportando Agendamento"
			
	        //Inicia a exportação de uma novo fonte de dados.
	        oFileXml:nWriteln('<AGENDAMENTO>')
			for nQtd := 1 to len(aFields)           
			    //Abre a tag do atributo que está sendo exportado.
				oFileXml:nWrite('<'+aFields[nQtd][1]+'>')		
	
				oFileXml:nWrite(::changeSpecialChar( oScheduler:cValue(aFields[nQtd, 1]) ))
	
				//Fecha a tag do atributo que está sendo exportado.
				oFileXml:nWriteln('</'+aFields[nQtd][1]+'>')
			next  
			//Finaliza a exportação de um novo indicador.
			oFileXml:nWriteln('</AGENDAMENTO>')
		EndIf
				
		oScheduler:_Next()
	enddo		
	
	oFileXml:nWriteln('</AGENDAMENTOS>')
return
  
/*-------------------------------------------------------------------------------------
Para a importação.
@param nHandle		- Handle do arquivo
@return 	   		- boolean
--------------------------------------------------------------------------------------*/
method unlockExport(nHandle) class TKPIEstExport
	local lUnLock := .t.

    if ! fClose(nHandle) 
		lUnLock := .f.
	endif
return lUnLock    

/*-------------------------------------------------------------------------------------
Altera caracteres especiais para gravar o xml
@param cText		- valor a ser inserido no xml
@return 	   		- texto
--------------------------------------------------------------------------------------*/
method changeSpecialChar(xOrigem) class TKPIEstExport
	local cText

	if valtype( xOrigem ) == "D"
		cText := dTos( xOrigem )
	else
		cText := cBIStr( xOrigem )
	endif

	cText = alltrim(cText)

	cText = replace(cText,"&","&amp;")
	cText = replace(cText,"\","&quot;")
	cText = replace(cText,">","&gt;")
	cText = replace(cText,"<","&lt;")
return cText
