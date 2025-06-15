/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI033_EstImport.prw
// ---------+---------------------+------------------------------------------------------
// Data     | Autor               | Descricao                 
// ---------+---------------------+------------------------------------------------------
// 09.04.08 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI033_EstImport.ch"

/*--------------------------------------------------------------------------------------
@entity Estrutura
Importação de metadados.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "ESTIMPORT"
#define TAG_GROUP  "ESTIMPORTS"
     
//Constante para controle de status de execução. 
#define PARADO  		0 
#define EXECUTANDO  	1
#define FINALIZADO  	2
#define PARANDO  		3     
         
//Constante de controle global do cálculo dos indicadores. 
#define GLOBAL_LOCK   "bKpiImpLock"  

class TKPIEstImport from TBITable
	data cJobName
	data calcLog
	
	method New() constructor
	method NewEstImport()
	method oToXMLNode(cID,cRequest) 
	method nExecute(cID, cRequest)
	method lCal_CriaLog(cPathSite,cLogName) 
	method lCal_WriteLog()
	method lCal_CloseLog() 
	method unlockImport(nHandle)	
	method getScoParent(cId)  
	method getIndParent(cId)
	method cUpDateFormula(cFormula, lPrivado)
	method lCheckCodClie(cCodClie)	
endclass
	
method New() class TKPIEstImport
	::NewEstImport()
return

method NewEstImport() class TKPIEstImport
	::cJobName		:=	alltrim(getJobProfString("INSTANCENAME", "SGI")+"_SgiEstImp.lck")
	::NewObject() 
return

/*-------------------------------------------------------------------------------------
Carrega o no requisitado.
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com os dados
--------------------------------------------------------------------------------------*/
method oToXMLNode(cID,cRequest) class TKPIEstImport
	local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)    
	local oXMLArqs 		:=	TBIXMLNode():New("ARQUIVOS")
	local cPathImport	:=	"metadados\*.xml" 
	local oNodeLine     :=  nil
	local cFileLocal 	:=  ""
	local aFiles 		:=  {}
	local nStatus		:=	PARADO
	local nItemFile		:=  1
	local nHandle		:=	fCreate(::cJobName,1) 

	if(!empty(getGlbValue(GLOBAL_LOCK)))
		nStatus	:=	PARANDO
	elseif(nHandle == -1)
		nStatus	:=	EXECUTANDO
	else
		nStatus	:=PARADO
		::unlockImport(nHandle)		
	endif 
	
	oXMLNode:oAddChild(TBIXMLNode():New("STATUS", nStatus))	
 	
	cFileLocal 	:=  oKpiCore:cKpiPath() + cPathImport
	aFiles 		:=  directory(cFileLocal)   
    
	for nItemFile := 1 to len(aFiles)
		oNodeLine := oXMLArqs:oAddChild(TBIXMLNode():New("ARQUIVO"))
		oNodeLine:oAddChild(TBIXMLNode():New("ID",		lower(aFiles[nItemFile][1])))
		oNodeLine:oAddChild(TBIXMLNode():New("NOME",	lower(aFiles[nItemFile][1])))
		oNodeLine:oAddChild(TBIXMLNode():New("SIZE",	str(aFiles[nItemFile][2]/1024,10,2)+ " Kb"))
		oNodeLine:oAddChild(TBIXMLNode():New("DATE",	dToc(aFiles[nItemFile][3]) + " " + aFiles[nItemFile][4]))
	next nItemFile
	oXMLNode:oAddChild(oXMLArqs)
	            
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(,.T., ::oOwner():getStrCustom():getStrSco()))
return oXMLNode


/*-------------------------------------------------------------------------------------
Excucata o comando do client
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com o status da execução
--------------------------------------------------------------------------------------*/
method nExecute(cID, cRequest)  class TKPIEstImport
	local cPathSite	:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	local aRet			:=  {}
	local nHandle		:=	0	
	local oProgress		:=  nil
	local oPar			:= oKPICore:oGetTable("PARAMETRO")
    
	default cRequest 	:=  ""	
	
	if(cRequest == "JOBSTOP")
		putGlbValue(GLOBAL_LOCK,"STOP")
	else
		//Verifica se o job esta em execucao
		nHandle	:=	fCreate(::cJobName,1)
		if(nHandle != -1)
			::unlockImport(nHandle)
			
			//Limpa Flag global de execução 				  
			putGlbValue(GLOBAL_LOCK,"")
			
			//Inicia ProgressBar
			oProgress := KPIProgressbar():New("kpiestimp_1")
			oProgress:setMessage(STR0001) //"Iniciando Importação..."
			oProgress:setPercent(05) 
			
			oKPICore:Log(STR0001, KPI_LOG_SCRFILE)	//"Iniciando Importação..."
			aRet := aBIToken(cRequest,"|",.f.)	  	//Parametros   
			aadd(aRet,cPathSite)					//Site do KPI
			aadd(aRet,::oOwner():cKpiPath())		//Kpi Path
			
			aadd(aRet,oPar:getValue("MODO_ANALISE"))	//Modo de Análise
				
			StartJob("KpiImp_Metadados", GetEnvServer(), .f., aRet)
		else
			oKPICore:Log(STR0002, KPI_LOG_SCRFILE) //"Atenção. Existe uma importação de estrutura em andamento."
		endif
	endif

return KPI_ST_OK


/*-------------------------------------------------------------------------------------
Cria o arquivo de log
@param cPathSite	- caminho do site
@param cLogName 	- Log
@return 	   		- .t.
--------------------------------------------------------------------------------------*/
method lCal_CriaLog(cPathSite,cLogName) class TKPIEstImport
	cPathSite	:=	strtran(cPathSite,"\","/")
	::calcLog	:= 	TBIFileIO():New(oKpiCore:cKpiPath()+"logs\metadados\import\"+ cLogName + ".html")

	// Cria o arquivo htm
	If ! ::calcLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0003) //"Erro na criacao do arquivo de log."
	else
		::calcLog:nWriteLN('<html>')
		::calcLog:nWriteLN('<head>')
		::calcLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
  		::calcLog:nWriteLN('<title>'+STR0019+'</title>') //"SGI - Log de importação"
		::calcLog:nWriteLN('<link href= "'+ cPathSite + 'imagens/report.css" rel="stylesheet" type="text/css">')
		::calcLog:nWriteLN('</head>')
		::calcLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::calcLog:nWriteLN('<table width="90%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td class="titulo"><div align="center">'+STR0019+ '</div></td>') //"SGI - Log de importação"
		::calcLog:nWriteLN('</tr>')
		::calcLog:nWriteLN('</table>')
		::calcLog:nWriteLN('<table width="90%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::calcLog:nWriteLN('<tr>')
		::calcLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0020+'</td>') //"Data"
		::calcLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0021+'</td>') //"Eventos"
		::calcLog:nWriteLN('</tr>')
	endif

return .t.
      

/*-------------------------------------------------------------------------------------
Grava um evento no log.
@param cMensagem	- Texto a ser gravado no log
@param cLogName 	- Log
@return 	   		- .t.
--------------------------------------------------------------------------------------*/
method lCal_WriteLog(cMensagem) class TKPIEstImport

	::calcLog:nWriteLN('<tr>')
	::calcLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	::calcLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	::calcLog:nWriteLN('</tr>')

	oKPICore:Log(cMensagem)	
return .t.
  

/*-------------------------------------------------------------------------------------
Fecha o arquivo de log.
@return	- .t.
--------------------------------------------------------------------------------------*/
method lCal_CloseLog() class TKPIEstImport
	::calcLog:nWriteLN('</table>')
	::calcLog:nWriteLN('<br>')
	::calcLog:nWriteLN('</body>')
	::calcLog:nWriteLN('</html>')
	::calcLog:lClose()	
return .t.

/*-------------------------------------------------------------------------------------
Importação de metados
@param aParms	- array com o nome do arquivo, o scorecard pai e o modo de análise
@return 	   	- boolean
--------------------------------------------------------------------------------------*/
function kpiImp_Metadados(aParms)
	local oImport		:= nil
	local nStatus 		:= KPI_ST_OK
	local cError   		:= ""
	local cWarning 		:= ""
	local cXml 	   		:= "" 
	local cNewID		:= "" 
	local cLogName		:= "" 
	local cCodClie		:= ""
	local nQtdReg		:= 0   
	local nInd			:= 0
	local nTotInd		:= 0
	local nHandle		:= 0
	local oScoreCard	:= nil 
	local oIndicador	:= nil 
	local oScheduler	:= nil
	local oDataSrc		:= nil
	local oProgress		:= nil
	local lImportAcess	:= .T. 
	local cFileLocal 	
	local cScorecard	:= iif(aParms[2] == "0", Space(10), aParms[2])
    
	local cModoAnalise	:= aParms[5]
    
	local aRegNode		:= {}

	local oEntity		:= nil
 	local cEntity		:= ""
	local cTipoScore	:= ""
	local cTpScoreAux	:= ""
	
	local nQtd			:= 0
	local xValue		:= nil
	
	local aFields		:= {}
	local aFldAux		:= {}    
	
	local cMsgAux		:= ""
	
	local lOk			:= .T.

	private cLicense	:= ""
	private oXmlInput	:= nil
	private aIdDepto	:= {}
	private aIdInd		:= {} 

	//Configuracoes do ambiente
	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on

	/*Instanciando KPICore*/
	oKPICore := TKPICore():New(aParms[4])
	ErrorBlock( {|oE| __KPIError(oE)})  

	/*Abre conexão*/
	if(oKPICore:nDBOpen() < 0)
		oKPICore:Log(STR0004, KPI_LOG_SCRFILE) //"Erro na abertura do banco de dados"
		oProgress:setStatus(PROGRESS_BAR_ERROR) 
   		oProgress:setMessage(STR0004) //"Erro na abertura do banco de dados"
		oProgress:endProgress() 
			
		//Espera 1 segundo para finalizar e dar tempo para o retorno ao KPI		
		sleep(1000)	 
		return
	endif

	//Instancia oExport
	oImport	:= oKPICore:oGetTable("ESTIMPORT")

   	//Verifica se o job esta em execucao
	nHandle	:=	fCreate(oImport:cJobName,1)
	if(nHandle == -1)
		oKPICore:Log(STR0002, KPI_LOG_SCRFILE) //"Atenção. Existe uma importação de estrutura em andamento."
		return
	endif             	
	
	/*Criando do arquivo de log.*/
	cLogName += alltrim(getJobProfString("INSTANCENAME", "SGI"))+"_"
	cLogName += strtran(dToc(date()),"/","") +"_"
	cLogName += strtran(time(),":","")
	oImport:lCal_CriaLog(aParms[3],cLogName)  /*Criando o arquivo de log.*/
	oImport:lCal_WriteLog(STR0001 + "<br>" + STR0005 + aParms[1]) /*"Iniciando importação ..."  "Arquivo: "*/

	/*Recebe o caminho do arquivo a ser importado.*/
	cFileLocal := oKpiCore:cKpiPath()+"\metadados\"+ aParms[1]

    /*Cria a progressbar*/
	oProgress := KPIProgressbar():New("kpiestimp_1")

 	/*Verifica se o conteúdo do arquivo importado excede 1024 KB.*/       
	If  ((directory(cFileLocal)[1][2]) / 1024) > 1024  
		oImport:lCal_WriteLog(STR0026) /*"Atenção! O tamanho do arquivo para importação excede 1024 KB"*/
	EndIf  

 	oProgress:setMessage(STR0037)/*"Lendo o arquivo para a importação"*/
	oProgress:setPercent(5)  
	oImport:lCal_WriteLog(STR0037)   
	
	/*Parseia o arquivo a ser importado.*/
	oXmlInput := XmlParserFile(	cFileLocal, "_", @cError, @cWarning ) 

	/*Verifica a ocorrência de erros no processo de importação.*/		
   	If !(len(cError)==0)
   	  	oImport:lCal_WriteLog(STR0038) /*"Ocorreu erro no processo de leitura do arquivo."*/
   		oImport:lCal_WriteLog(cError)  
   		 
   		lImportAcess := .F.	
   	EndIf					
										
	If (lImportAcess)						
		/*Verifica se a tag LICENSE existe no Metadado.*/
		If !(valtype(XmlChildEx(oXMLInput:_METADADOS, "_LICENSE")) == "U")     
			/*Recupera o LicenseKey do cliente.*/  
			cLicense := AllTrim( oXMLInput:_METADADOS:_LICENSE:TEXT )
			/*Verifica se a LicenseKey em uso é igual a que foi usada para gerar o XML.*/
			If !( DwStr(LS_GetID()) == DwUncripto(AllTrim(DwStr( cLicense ))))
			   	/*Nega o acesso a importação do Metadado.*/
			   	lImportAcess := .F.	
			EndIf			  
		EndIf	
    EndIf
		 
	oProgress:setMessage(STR0006) /*"Importando dados..."*/
	oProgress:setPercent(10) 	 	
		
	/*Atribui a variável cLicense o LicenseKey.*/
	cLicense := DwStr(LS_GetID())
	
	/*Lendo os valores do XML*/
	If(empty(cError) .and. empty(cWarning) .And. (lImportAcess)) 			
		/*Departamentos*/
		oProgress:setPercent(15)
		if(valtype(XmlChildEx(oXMLInput:_METADADOS:_DEPARTAMENTOS, "_DEPARTAMENTO"))!="U")
			oScoreCard 	:= oKpiCore:oGetTable("SCORECARD") 
			aRegNode 	:= oXMLInput:_METADADOS:_DEPARTAMENTOS //Capturando os departamentos

			//Padroniza estrutura do XML para conter array mesmo que possua apenas um item
			if valtype(aRegNode:_DEPARTAMENTO) == "O"
				XmlNode2Arr(aRegNode:_DEPARTAMENTO, "_DEPARTAMENTO")
			endif

			if valtype(aRegNode:_DEPARTAMENTO) == "A"
				for nQtdReg := 1 to len(aRegNode:_DEPARTAMENTO)
					cTipoScore := aRegNode:_DEPARTAMENTO[nQtdReg]:_TIPOSCORE:TEXT

					//Modo análise BSC, Primeiro elemento - Verificar integridade da estrutura
					if cModoAnalise == ANALISE_BSC .and. nQtdReg == 1
						lOk := .T.
						cTpScoreAux := CAD_SCORECARD

						if !Empty(cScorecard)
							if oScoreCard:lSeek(1, {cScorecard})
								cTpScoreAux := oScoreCard:cValue("TIPOSCORE")
							endif
						endif

						do case
							case cTipoScore == CAD_ORGANIZACAO
								lOk := ( cTpScoreAux == CAD_SCORECARD )

								cMsgAux := STR0043 //###"Não é permitido fazer a importação de uma Organização dentro da Entidade informada."

							case cTipoScore == CAD_ESTRATEGIA
								lOk := ( cTpScoreAux == CAD_ORGANIZACAO )

								cMsgAux := STR0044 //###"Não é permitido fazer a importação de uma Estratégia dentro da Entidade informada."

							case cTipoScore == CAD_PERSPECTIVA
								lOk := ( cTpScoreAux == CAD_ESTRATEGIA )

								cMsgAux := STR0045 //###"Não é permitido fazer a importação de uma Perspectiva dentro da Entidade informada."

							case cTipoScore == CAD_OBJETIVO
								lOk := ( cTpScoreAux == CAD_PERSPECTIVA )

								cMsgAux := STR0046 //###"Não é permitido fazer a importação de um Objetivo dentro da Entidade informada."
								
							otherwise
								lOk := .F.

								cMsgAux := STR0047 //###"TENTATIVA DE IMPORTAÇÃO DE ESTRUTURA INCOMPATÍVEL COM O MODO DE OPERAÇÃO ATUAL - ENTRE EM CONTATO COM O SUPORTE TÉCNICO"

						endcase

						if !lOk
							oImport:lCal_WriteLog(cMsgAux + "<br>" + STR0049)
							oProgress:setStatus(PROGRESS_BAR_ERROR) 
					   		oProgress:setMessage(cMsgAux) 
							oProgress:endProgress()

							oImport:lCal_WriteLog(STR0015) //"Importação finalizada"
							oImport:lCal_CloseLog() 
	
							//Libera o job em execução	
							oImport:unlockImport(nHandle)
	
							// Espera 2 segundos para finalizar
							// e dar tempo para o retorno ao KPI
							sleep(2000)
							
							// Aborta execução
							return
						endif
					endif

					do case
						case cTipoScore == CAD_ORGANIZACAO
							cMsgAux := STR0039		//###"Importando Organização: "

						case cTipoScore == CAD_ESTRATEGIA
							cMsgAux := STR0040		//###"Importando Estratégia: "

						case cTipoScore == CAD_PERSPECTIVA
							cMsgAux := STR0041		//###"Importando Perspectiva: "

						case cTipoScore == CAD_OBJETIVO
							cMsgAux := STR0042		//###"Importando Objetivo: "

						otherwise
							cMsgAux := STR0007		//###"Importando scorecard: "
					endcase

					oImport:lCal_WriteLog(cMsgAux + aRegNode:_DEPARTAMENTO[nQtdReg]:_NOME:TEXT) //"Importando scorecard: "

					aFields := {}

					aAdd( aFields, {"ID"		, cNewID := oScoreCard:cMakeID()})
					aAdd( aFields, {"NOME"		, aRegNode:_DEPARTAMENTO[nQtdReg]:_NOME:TEXT})
					aAdd( aFields, {"DESCRICAO"	, aRegNode:_DEPARTAMENTO[nQtdReg]:_DESCRICAO:TEXT})
					aAdd( aFields, {"PARENTID"	, oImport:getScoParent(aRegNode:_DEPARTAMENTO[nQtdReg]:_PARENTID:TEXT, cScorecard)}) 
					aAdd( aFields, {"VISIVEL"	, aRegNode:_DEPARTAMENTO[nQtdReg]:_VISIVEL:TEXT})
					aAdd( aFields, {"TIPOSCORE"	, aRegNode:_DEPARTAMENTO[nQtdReg]:_TIPOSCORE:TEXT})
					aAdd( aFields, {"ORDEM"		, val(aRegNode:_DEPARTAMENTO[nQtdReg]:_ORDEM:TEXT)})
					aAdd( aFields, {"RESPID"	, "1"}) //Administrador
					aAdd( aFields, {"TIPOPESSOA", "P"}) //G = Grupo, P = Individual

					// Grava
					if( ! oScoreCard:lAppend(aFields))
						if(oScoreCard:nLastError()==DBERROR_UNIQUE)
							nStatus := KPI_ST_UNIQUE
							oImport:lCal_WriteLog(STR0008 + "<br>" + STR0009 + alltrim(aRegNode:_DEPARTAMENTO[nQtdReg]:_NOME:TEXT)) //"Chave duplicada para o scorecard: "
						else
							oImport:lCal_WriteLog(STR0008 + "<br>" + STR0010 + alltrim(aRegNode:_DEPARTAMENTO[nQtdReg]:_NOME:TEXT)) //"Registro em uso para o scorecard: "
							nStatus := KPI_ST_INUSE
						endif
					else
						aadd(aIdDepto,{cNewID, aRegNode:_DEPARTAMENTO[nQtdReg]:_ID:TEXT })

						//Modo de análise BSC
						cTipoScore := oScoreCard:cValue("TIPOSCORE")
						if !Empty(cTipoScore)
							cEntity := oKpiCore:entityByCode(cTipoScore)

							oEntity := oKpiCore:oGetTable(cEntity)

							// Trata campos da entidade correspondente 
							aFldAux := oEntity:xRecord(RF_ARRAYFLD, {"ID"})

							aFields := {}

							aAdd(aFields, {"ID", cNewID})

							for nQtd := 1 to len (aFldAux)
								xValue := &("oXMLInput:_METADADOS:_DEPARTAMENTOS:_DEPARTAMENTO[" + alltrim( str(nQtdReg) ) + "]:_" + alltrim(aFldAux[nQtd]) + ":TEXT")
								aAdd( aFields, {alltrim(aFldAux[nQtd]), xBIConvTo( oEntity:aFields(alltrim(aFldAux[nQtd])):cType(), xValue ) } )
							next

							if(!oEntity:lAppend(aFields))
								if(oEntity:nLastError()==DBERROR_UNIQUE)
									nStatus := KPI_ST_UNIQUE
									oImport:lCal_WriteLog(STR0008 + " " + cTipoScore + "<br>" + STR0009 + alltrim(aRegNode:_DEPARTAMENTO[nQtdReg]:_NOME:TEXT)) //"Chave duplicada para o scorecard: "
								else
									nStatus := KPI_ST_INUSE
									oImport:lCal_WriteLog(STR0008 + " " + cTipoScore + "<br>" + STR0010 + alltrim(aRegNode:_DEPARTAMENTO[nQtdReg]:_NOME:TEXT)) //"Registro em uso para o scorecard: "
								endif
							endif
						endif
					endif
				next nQtdReg
			endif
		endif

		//Indicadores
		oProgress:setPercent(25)
		if(valtype(XmlChildEx(oXMLInput:_METADADOS:_INDICADORES, "_INDICADOR"))!="U") 
			oIndicador 	:= oKpiCore:oGetTable("INDICADOR") 
			aFields 	:= oIndicador:xRecord(RF_ARRAY,{"ID_RESPCOL","ID_RESP","TP_RESP","TP_RESPCOL"})
			aRegNode 	:= oXMLInput:_METADADOS:_INDICADORES //Capturando os indicadores

			//Antes de iniciar a gravação do indicador verificamos se existe o registro de numeo 0
			if !oIndicador:lSeek(1,{"0"})
				while(! oIndicador:lAppend({{"ID", "0"}}))
					sleep(500)
					conout(STR0050) //"Tentando adicionar indicador de numero 0."
				end
			endif

			//Padroniza estrutura do XML para conter array mesmo que possua apenas um item
			if valtype(aRegNode:_INDICADOR) == "O"
				XmlNode2Arr(aRegNode:_INDICADOR, "_INDICADOR")
			endif

			if valtype(aRegNode:_INDICADOR) == "A" 
				nTotInd := len(aRegNode:_INDICADOR) 
				
				for nQtdReg := 1 to nTotInd
					oProgress:setPercent( 25 + round(((nQtdReg * 25)/nTotInd),0) )
					cCodClie := ""
					
					//Extrai valores do XML.
					For nInd := 1 To Len(aFields)						
				   		//Recupera o tipo do campo para realizar a conversão para gravação.							   
						cType := oIndicador:aFields(aFields[nInd][1]):cType()
						
						If aFields[nInd][1] == "ID"
							aFields[nInd][2] :=	cNewID := oIndicador:cMakeID()
						Elseif aFields[nInd][1] == "ID_CODCLI"
							aFields[nInd][2] := cCodClie := xBIConvTo(cType, &("oXMLInput:_METADADOS:_INDICADORES:_INDICADOR["+alltrim(str(nQtdReg))+"]:_"+aFields[nInd][1]+":TEXT"))
						Else 
							If(valtype(XmlChildEx(&("oXMLInput:_METADADOS:_INDICADORES:_INDICADOR[" + AllTrim(cBIStr(nQtdReg)) + "]"), "_" + aFields[nInd][1] ))!="U") 
								aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_METADADOS:_INDICADORES:_INDICADOR["+alltrim(str(nQtdReg))+"]:_"+aFields[nInd][1]+":TEXT"))
						    EndIf							    
						Endif
					Next     
					
					//Valida cod. cliente
					if oImport:lCheckCodClie(cCodClie)
						// Grava
						if( ! oIndicador:lAppend(aFields))
							if(oIndicador:nLastError()==DBERROR_UNIQUE)
								nStatus := KPI_ST_UNIQUE
								oImport:lCal_WriteLog(STR0012 + "<br>" + STR0013 + alltrim(aRegNode:_INDICADOR[nQtdReg]:_NOME:TEXT)) //"Chave duplicada para o indicador: "
							else 
								oImport:lCal_WriteLog(STR0012 + "<br>" + STR0014 + alltrim(aRegNode:_INDICADOR[nQtdReg]:_NOME:TEXT)) //"Registro em uso para o indicador: "
								nStatus := KPI_ST_INUSE
							endif
						else
							oImport:lCal_WriteLog(STR0011 + aRegNode:_INDICADOR[nQtdReg]:_NOME:TEXT) //"Importando indicador: "
							aadd(aIdInd,{cNewID, aRegNode:_INDICADOR[nQtdReg]:_ID:TEXT })
						endif
					else 
						oImport:lCal_WriteLog(STR0022 + cCodClie + STR0023 + alltrim(aRegNode:_INDICADOR[nQtdReg]:_NOME:TEXT)) //"Código do Cliente '" "' já cadastrado. Indicador: "
					endif	
				next nQtdReg
			endif
		endif

		//Fórmulas
		oProgress:setPercent(50)
		
		nTotInd := len(aIdInd) 
		
		for nInd:= 1 to nTotInd
			oProgress:setPercent( 50 + round(((nInd * 45)/nTotInd),0) )
			aFields := {}
			oIndicador:lSeek(1,{aIdInd[nInd][1]})
			aAdd( aFields, {"ID_INDICA"	,  oImport:getIndParent(oIndicador:cValue("ID_INDICA")) })
			aAdd( aFields, {"ID_SCOREC"	,  oImport:getScoParent(oIndicador:cValue("ID_SCOREC"))	})
			/*Realiza o tratamento do atributo fórmula de acordo com o tipo [PRIVADO|PUBLICO].*/
			aAdd( aFields, {"FORMULA"	,  oImport:cUpDateFormula(oIndicador:cValue("FORMULA"),oIndicador:lValue("ISPRIVATE"))})
			
			/*Atualiza os campos com o devido tratamento.*/
			if( ! oIndicador:lUpdate(aFields))
				if(oIndicador:nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
					oImport:lCal_WriteLog(STR0012 + "<br>" + STR0013 + alltrim(aRegNode:_INDICADOR:_NOME:TEXT)) 
				else
					oImport:lCal_WriteLog(STR0012 + "<br>" + STR0014 + alltrim(aRegNode:_INDICADOR:_NOME:TEXT)) 
					nStatus := KPI_ST_INUSE
				endif
			endif
		next
		
		oProgress:setPercent(70) 
		
		/*Verifica a existência da informação sobre fontes de dados no XML.*/			
		if(valtype(XmlChildEx(oXMLInput:_METADADOS, "_DATASRCS"))!="U" .And. valtype(XmlChildEx(oXMLInput:_METADADOS:_DATASRCS, "_DATASRC"))!="U") 
			oDataSrc 	:= oKpiCore:oGetTable("DATASRC")
			aFields 	:= oDataSrc:xRecord(RF_ARRAY)
			aRegNode 	:= oXMLInput:_METADADOS:_DATASRCS //Capturando as fontes de dados

			//Antes de iniciar a gravação das fontes de dados verificamos se existe o registro de numeo 0
			if(!oDataSrc:lSeek(1,{"0"}) )
				while(! oDataSrc:lAppend({{"ID", "0"}}))
					sleep(500)
					conout(STR0050) //"Tentando adicionar registro de numero 0."
				end
			endif

			if(valtype(aRegNode:_DATASRC)=="A")
				nTotInd := len(aRegNode:_DATASRC)
				 
				for nQtdReg := 1 to nTotInd
					oProgress:setPercent( 25 + round(((nQtdReg * 25)/nTotInd),0) )
					// Extrai valores do XML
					for nInd := 1 to len(aFields)
						if aFields[nInd][1] == "ID"
							aFields[nInd][2] :=	cNewID := oDataSrc:cMakeID()
						else
							cType := oDataSrc:aFields(aFields[nInd][1]):cType()
							aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_METADADOS:_DATASRCS:_DATASRC["+alltrim(str(nQtdReg))+"]:_"+aFields[nInd][1]+":TEXT"))
						endif
					next     
					
					// Grava
					if( ! oDataSrc:lAppend(aFields))
						if(oDataSrc:nLastError()==DBERROR_UNIQUE)
							nStatus := KPI_ST_UNIQUE
							oImport:lCal_WriteLog(STR0035 + "<br>" + STR0029 + alltrim(aRegNode:_DATASRC[nQtdReg]:_NOME:TEXT)) //"Erro importando Fonte de Dados." "Chave duplicada para a fonte de dados: "
						else 
							oImport:lCal_WriteLog(STR0035 + "<br>" + STR0030 + alltrim(aRegNode:_DATASRC[nQtdReg]:_NOME:TEXT)) //"Erro importando Fonte de Dados." "Registro em uso para a fonte de dados: "
							nStatus := KPI_ST_INUSE
						endif
					else
						oImport:lCal_WriteLog(STR0031 + aRegNode:_DATASRC[nQtdReg]:_NOME:TEXT) //"Importando a fonte de dados: "
					endif
				next nQtdReg
			elseif(valtype(aRegNode:_DATASRC)=="O")
				// Extrai valores do XML
				for nInd := 1 to len(aFields)
					if aFields[nInd][1] == "ID"
						aFields[nInd][2] :=	cNewID := oDataSrc:cMakeID()  
					else							
						cType := oDataSrc:aFields(aFields[nInd][1]):cType()
						aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_METADADOS:_DATASRCS:_DATASRC:_"+aFields[nInd][1]+":TEXT"))
					endif
				next
				
				// Grava
				if( ! oDataSrc:lAppend(aFields))
					if(oDataSrc:nLastError()==DBERROR_UNIQUE)
						nStatus := KPI_ST_UNIQUE 
						oImport:lCal_WriteLog(STR0035 + "<br>" + STR0029 + alltrim(aRegNode:_DATASRC:_NOME:TEXT)) //"Erro importando Fonte de Dados." "Chave duplicada para a fonte de dados: "
					else
						oImport:lCal_WriteLog(STR0035 + "<br>" + STR0030 + alltrim(aRegNode:_DATASRC:_NOME:TEXT)) //"Erro importando Fonte de Dados." "Registro em uso para a fonte de dados: "
						nStatus := KPI_ST_INUSE
					endif
				else
					oImport:lCal_WriteLog(STR0031 + aRegNode:_DATASRC:_NOME:TEXT) //"Importando a fonte de dados: "
				endif
			endif
		endif
		
		oProgress:setPercent(90) 
		
		/*Verifica a existência da informação sobre agendamentos no XML.*/				
		if( valtype(XmlChildEx(oXMLInput:_METADADOS,"_AGENDAMENTOS"))!="U" .And. valtype(XmlChildEx(oXMLInput:_METADADOS:_AGENDAMENTOS,"_AGENDAMENTO"))!="U") 
			oScheduler 	:= oKpiCore:oGetTable("AGENDAMENTO")
			aFields 	:= oScheduler:xRecord(RF_ARRAY)
			aRegNode 	:= oXMLInput:_METADADOS:_AGENDAMENTOS //Capturando os agendamentos

			//Antes de iniciar a gravação do agendamento verificamos se existe o registro de numeo 0
			if(!oScheduler:lSeek(1,{"0"}) )
				while(! oScheduler:lAppend({{"ID", "0"}}))
					sleep(500)
					conout(STR0050) //"Tentando adicionar registro de numero 0."
				end
			endif

			if(valtype(aRegNode:_AGENDAMENTO)=="A") 
				nTotInd := len(aRegNode:_AGENDAMENTO) 
				for nQtdReg := 1 to nTotInd
					oProgress:setPercent( 25 + round(((nQtdReg * 25)/nTotInd),0) )
					// Extrai valores do XML
					for nInd := 1 to len(aFields)
						if aFields[nInd][1] == "ID"
							aFields[nInd][2] :=	cNewID := oScheduler:cMakeID()
						else
							cType := oScheduler:aFields(aFields[nInd][1]):cType()
							aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_METADADOS:_AGENDAMENTOS:_AGENDAMENTO["+alltrim(str(nQtdReg))+"]:_"+aFields[nInd][1]+":TEXT"))
						endif
					next     
					
					// Grava
					if( ! oScheduler:lAppend(aFields))
						if(oScheduler:nLastError()==DBERROR_UNIQUE)
							nStatus := KPI_ST_UNIQUE
							oImport:lCal_WriteLog(STR0036 + "<br>" + STR0032 + alltrim(aRegNode:_AGENDAMENTO[nQtdReg]:_NOME:TEXT)) //"Erro importando Agendamento." "Chave duplicada para o agendamento: "
						else 
							oImport:lCal_WriteLog(STR0036 + "<br>" + STR0033 + alltrim(aRegNode:_AGENDAMENTO[nQtdReg]:_NOME:TEXT)) //"Erro importando Agendamento." "Registro em uso para o agendamento: "
							nStatus := KPI_ST_INUSE
						endif
					else
						oImport:lCal_WriteLog(STR0034 + aRegNode:_AGENDAMENTO[nQtdReg]:_NOME:TEXT) //"Importando agendamento: "
					endif
				next nQtdReg
			elseif(valtype(aRegNode:_AGENDAMENTO)=="O")
				// Extrai valores do XML
				for nInd := 1 to len(aFields)
					if aFields[nInd][1] == "ID"
						aFields[nInd][2] :=	cNewID := oScheduler:cMakeID()  
					else							
						cType := oScheduler:aFields(aFields[nInd][1]):cType()
						aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_METADADOS:_AGENDAMENTOS:_AGENDAMENTO:_"+aFields[nInd][1]+":TEXT"))
					endif
				next
				
				// Grava
				if( ! oScheduler:lAppend(aFields))
					if(oScheduler:nLastError()==DBERROR_UNIQUE)
						nStatus := KPI_ST_UNIQUE 
						oImport:lCal_WriteLog(STR0036 + "<br>" + STR0032 + alltrim(aRegNode:_AGENDAMENTO:_NOME:TEXT)) //"Erro importando Agendamento." "Chave duplicada para o agendamento: "
					else
						oImport:lCal_WriteLog(STR0036 + "<br>" + STR0033 + alltrim(aRegNode:_AGENDAMENTO:_NOME:TEXT)) //"Erro importando Agendamento." "Registro em uso para o agendamento: "
						nStatus := KPI_ST_INUSE
					endif
				else
					oImport:lCal_WriteLog(STR0034 + aRegNode:_AGENDAMENTO:_NOME:TEXT) //"Importando agendamento: "
				endif
			endif
		endif
		
		/*Força a atualização dos ID disponíveis.*/
		oKPICore:ResetMakeID()			
		
		oProgress:setMessage(STR0015) //"Importação finalizada"
		oProgress:setPercent(100)
		oProgress:endProgress() 
	else 
		if(!empty(cError))
			oImport:lCal_WriteLog(STR0016 + " - "+ cError) //"Erro no Parse"
			oProgress:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgress:setMessage(STR0016) 
			oProgress:endProgress()
		endif

		if(!empty(cWarning))
			oImport:lCal_WriteLog(STR0017 + " - " + cWarning) //"Aviso no Parse"
			oProgress:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgress:setMessage(STR0017) 
			oProgress:endProgress()
  		endif  		

  		if(!lImportAcess)
			oImport:lCal_WriteLog(STR0024)/*"Chave de acesso inválida"*/
			oImport:lCal_WriteLog(STR0025)/*"Você não está autorizado a importar este XML."*/
			oProgress:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgress:setMessage(STR0025) /*"Você não está autorizado a importar este XML."*/
			oProgress:endProgress()
  		endif    		

  		if(lSizeOverflow)
			oImport:lCal_WriteLog(STR0026)/*"O tamanho do metadado a ser importado não pode exceder 1024 KB."*/
			oProgress:setStatus(PROGRESS_BAR_ERROR) 
	   		oProgress:setMessage(STR0026) /*"O tamanho do metadado a ser importado não pode exceder 1024 KB."*/
			oProgress:endProgress()
  		endif   		
	endif
	
	oImport:lCal_WriteLog(STR0015) //"Importação finalizada"
	oImport:lCal_CloseLog() 

	//Libera o job em execução	
	oImport:unlockImport(nHandle)
	
	// Espera 2 segundos para finalizar
	// e dar tempo para o retorno ao KPI		
	sleep(2000)	 
	 	
return .t.

/*-------------------------------------------------------------------------------------
Retorna o novo ID do scorecard cadastrado
@param cId	- ID anterior
@return 	- ID novo
--------------------------------------------------------------------------------------*/
method getScoParent(cID, cParent) class TKPIEstImport                                
	local nPos 		:= aScan(aIdDepto, {|x| x[2] == cId})
	local cRet		:= ""

	Default cParent := Space(10)		     
		
	If nPos > 0
		cRet := aIdDepto[nPos][1]
	Else 
		cRet :=	cParent
	EndIf		
Return cRet

/*-------------------------------------------------------------------------------------
Retorna o novo ID do indicador cadastrado
@param cId	- ID anterior
@return 	- ID novo
--------------------------------------------------------------------------------------*/
method getIndParent(cId) class TKPIEstImport                                 
	local nPos 	:= aScan(aIdInd, {|x| x[2] == cId})
	local cRet	:= "0"
	
	if nPos > 0
		cRet := aIdInd[nPos][1]
	endif
	
Return cRet

/*-------------------------------------------------------------------------------------
Atualiza as formulas com o novo ID
@param cId	- ID anterior
@return 	- ID novo
--------------------------------------------------------------------------------------*/
method cUpDateFormula(cFormula, lPrivado) class TKPIEstImport   
	local cNewFormula	:=	""    
	local cNewItem		:=	""	
	local aItemFormula	:=	{}
	local nItem			:=	0

    /*Define lPrivado como false pois pode ser fórmula de MetaFormula.*/                                     
	Default lPrivado := .F.
     
 	/*Idenfica se o indicador é proprietário.*/          
   	If (lPrivado)
   		/*Atribui a expressão descriptografada a variável cFormula para ser utilizada no processamento.*/	    
   	    cFormula := KPIUnCripto( KPILimpaFormula(Formula), AllTrim(cLicense)) 
   	EndIf
   	
	aItemFormula	:=	aBIToken(cFormula, "|",.f.)

	for nItem := 1 to len(aItemFormula)
		cItemFormula := aItemFormula[nItem]

		//Verifica se e uma formula.
		if(at("I.", cItemFormula) != 0)
			cID	 :=	strTran(cItemFormula, "I.", "") 
			cNewItem := "I." + ::getIndParent(cID)
		elseif(at("M", cItemFormula) != 0)
			return " "
		else
			cNewItem := cItemFormula
		endif

		if(! empty(cItemFormula))		
			cNewFormula := cNewFormula + "|" + cNewItem
		endif			
	next nItem
              
	/*Idenfica se o indicador é proprietário.*/
	If (lPrivado)
		/*Atribui a expressão criptografada a variável cNewFormula para ser persistida.*/    		
   		cNewFormula := KPICripto(AllTrim(cNewFormula), AllTrim(cLicense))   		
  	EndIf
return cNewFormula

/*-------------------------------------------------------------------------------------
Retorna .F. caso já exista o código do cliente cadastrado
@param cCodClie	- Cod. Cliente
@return 		- boolean
--------------------------------------------------------------------------------------*/
method lCheckCodClie(cCodigo) class TKPIEstImport   
	Local oIndicador := nil
	Local lRet 		 := .T.
	
	If ( len( alltrim(cCodigo) ) > 0 )
		oIndicador := oKpiCore:oGetTable("INDICADOR") 
		If oIndicador:lSeek(6,{cCodigo})            
			If ( AllTrim( oIndicador:cValue("ID_CODCLI") ) == AllTrim( cCodigo ) )
				lRet := .F.  
			EndIf
		Endif
	Endif	
Return lRet   

/*-------------------------------------------------------------------------------------
Para a importação.
@param nHandle		- Handle do arquivo
@return 	   		- boolean
--------------------------------------------------------------------------------------*/
method unlockImport(nHandle) class TKPIEstImport
	local lUnLock := .t.

    if ! fClose(nHandle) 
		lUnLock := .f.
	endif

return lUnLock 