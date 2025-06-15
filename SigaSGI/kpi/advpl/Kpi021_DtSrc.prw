// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI021_DtSrc.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 08.04.03 | 1728 Fernando Patelli
// 17.04.06 | 1776 Importado e Adaptado para uso no KPI. Alexandre Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI021_DtSrc.ch"

/*--------------------------------------------------------------------------------------
@class TKPI021
@entity DataSource
Painel de instrumentos cuztomizado do KPI.
@table KPI021
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DATASRC"
#define TAG_GROUP  "DATASRCS"
#define TEXT_ENTITY STR0001/*//"Fonte de Dados"*/
#define TEXT_GROUP  STR0002/*//"Fontes de Dados"*/

class TKPI021 from TBITable
	method New() constructor
	method NewKPI021()

	// diversos registros
	method oToXMLList(nParentID)
	method oToXMLRecList(nParentID)

	// registro atual
	method oToXMLNode(nParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)
	method oXMLClasses()
	
	// executar 
	method nExecute(cID, cExecCMD, cArquivo)
endclass

method New() class TKPI021
	::NewKPI021()
return
method NewKPI021() class TKPI021
	// Table
	::NewTable("SGI021")
	::cEntity(TAG_ENTITY)    
	
	// Fields
	::addField(TBIField():New("ID"			,"C",010))
	::addField(TBIField():New("NOME"		,"C",060))
	::addField(TBIField():New("DESCRICAO"	,"C",255))

	// 1 - ENVIRONMENT
	::addField(TBIField():New("ENVIRON"		,"C",060))
    ::addField(TBIField():New("SERVIDOR"	,"C",060))
    ::addField(TBIField():New("PORTA"	    ,"N"))
    ::addField(TBIField():New("EMPRESA"	    ,"C",002))
    ::addField(TBIField():New("FILIAL"	    ,"C",014))
    ::addField(TBIField():New("PREPENV"		,"L"))

	// 2 - SETUP
	::addField(TBIField():New("TOPDB"		,"C",060))
	::addField(TBIField():New("TOPALIAS"	,"C",060))
	::addField(TBIField():New("TOPSERVER"	,"C",060))
	::addField(TBIField():New("TOPCONTYPE"	,"C",060))
	::addField(TBIField():New("FEEDBACK"	,"N"))
	::addField(TBIField():New("CLASSE"		,"N")) 		// KPI_SRC_TOP, KPI_SRC_ADVPL, KPI_SRC_FORMULA
	
	// Top
	::addField(TBIField():New("TIPOENV"		,"N")) 		// 1 - KPI_SRC_ENVIRONMENT / 2 - KPI_SRC_CUSTOM
	::addField(TBIField():New("REFER"		,"C",001)) //Nao usado no KPI
	::addField(TBIField():New("RECRIA"		,"L"))
	::addField(TBIField():New("EXECALC"		,"L"))		//Executa o calculo ao final da importacao.
	::addField(TBIField():New("TEXTO"		,"M"))		//Declaração para importação.                     
	::addField(TBIField():New("LIMPEZA"		,"L"))		//Indica se será realizada limpeza   
	::addField(TBIField():New("ESPECIFI"	,"L"))		//Indica se a limpeza será realizada com data específica. 
	::addField(TBIField():New("AGREGA"		,"L"))
	::addField(TBIField():New("ID_SCOREC"	,"C",010)) 	//ID do scorecard da fonte de dados. 	  
	::addField(TBIField():New("PERIODO"		,"D"))		//Data específica para limpeza de dados. 	
		
	//Integracao com o DW.
	::addField(TBIField():New("DW_IDCON"	,"N"))		//Id consulta do dw
	::addField(TBIField():New("DW_URL"		,"C",255))	//Url de conexão com DW
	::addField(TBIField():New("DW_NOME"		,"C",020))	//DW Selecionada.
	::addField(TBIField():New("DW_CON"		,"C",020))	//Consulta Selecionada.
	::addField(TBIField():New("DW_DATA"		,"C",010))	//Coluna com a Data.
	::addField(TBIField():New("DW_INDREAL"	,"C",010))	//Coluna com o Indicador Real.
	::addField(TBIField():New("DW_INDMETA"	,"C",010))	//Coluna com o Indicador Meta.
	::addField(TBIField():New("DW_INDPREV" ,"C",010))	//Coluna com o Indicador Previa.
	::addField(TBIField():New("DW_INDID" 	,"C",010))	//Campo na consulta do dw que retorna o codigo de para importação. (ID indicador)
	::addField(TBIField():New("DW_INDIDIP" ,"C",255))	//Campo na consulta do dw que retorna o codigo de para importação (Cad. Ind. Cod Importacao)
	                                               
	::addField(TBIField():New("SGI_IND"		,"C",010))	//Coluna com o Indicador do SGI para relacionamento com a consulta do DW.	
	
	// Indexes
	::addIndex(TBIIndex():New("SGI021I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("KPI021I02",	{"NOME"},	.t.))	
return

// Classes DTSRC
// KPI_SRC_TOP, KPI_SRC_ADVPL, KPI_SRC_FORMULA	
method oXMLClasses() class TKPI021
	local oAttrib, oNode, oXMLOutput
	local nInd, aUnidades := { "TOTVS DBAccess" } //"TOTVS DBAccess"

	//Caso o SGI estiver sendo usado por marcas diferentes de Microsiga, não adicionar ADVPL.
	if(::oOwner():nTrade() == MICROSIGA)
		aadd(aUnidades, "AdvPL")	//"AdvPL" 
		aadd(aUnidades, "SIGADW")	//DW			
	endif
		
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("CLASSES",,oAttrib)

	for nInd := 1 to len(aUnidades)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("CLASSE"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aUnidades[nInd]))
	next
	
return oXMLOutput


// Lista XML para anexar ao pai
method oToXMLRecList() class TKPI021
	Local oXMLLista 	:= TBIXMLNode():New("LISTA") 
	Local oAttrib		:= TBIXMLAttrib():New()
	Local oXMLNode		:= TBIXMLNode():New(TAG_GROUP,,oAttrib)
	Local nInd
	     
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)
	
	::SetOrder(1)
	::_First()  
	
	While(!::lEof())  
	
		If( !(Alltrim(::cValue("ID")) == "0"))			        
		  
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := {{"ID",""},{"NOME",""}}
	
				For nInd := 1 To Len(aFields)
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], ::cValue(aFields[nInd][1])))
				Next
		EndIf			
		::_Next()		
	End

	oXMLLista:oAddChild(oXMLNode)

return oXMLLista

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TKPI021
	local aFields, oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)
	// Tipo
	oAttrib:lSet("TAG001", "CLASSE")
	oAttrib:lSet("CAB001", STR0004)/*//"Classe"*/
	oAttrib:lSet("CLA001", KPI_STRING)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de nome
	::_First()
	
	while(!::lEof())
		if !(alltrim(::cValue("ID")) == "0")
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
	
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO","TEXTO","TIPOENV", "TOPDB","TOPALIAS",;
											"TOPSERVER","TOPCONTYPE","ENVIRON","EMPRESA","FILIAL"})
			for nInd := 1 to len(aFields)
				if(aFields[nInd][1]=="CLASSE")
					if(aFields[nInd][2]==0)
						aFields[nInd][2] := 1
					endif	
					aFields[nInd][2] := ::oXMLClasses():oChildByPos(aFields[nInd][2]):oChildByName("NOME"):cGetValue()
				endif	
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
			
		endif			
		::_Next()
	end
	
return oXMLNode

// Carregar
method oToXMLNode(nParentID) class TKPI021
	local cID		:= ""	
	local aFields	:= {}
	local nInd		:= 0
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)
	local oIndicador:= ::oOwner():oGetTable("INDICADOR")
	local oParametro:= ::oOwner():oGetTable("PARAMETRO")
	local lValorPrevio := .f.

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
	                                      
		if(aFields[nInd][1] == "DW_URL" )
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], oParametro:getValue("DW_URL")))
		else                          
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		endif
		
		
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
		
		//Adiciona o campo com o nome do indicador selecionado no DW.
		if(aFields[nInd][1] == "SGI_IND" )
			if( oIndicador:lSeek(1,{aFields[nInd][2]}))
				oXMLNode:oAddChild(TBIXMLNode():New("SGI_IND_NOME", oIndicador:cValue("NOME")))		
			else
				oXMLNode:oAddChild(TBIXMLNode():New("SGI_IND_NOME", STR0042)) //"Indicador não selecionado"
			endif
		endif
	next
	
	// Tipos de data-source
	oXMLNode:oAddChild(::oXMLClasses())
	//Adiciona os scorecards
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.T.))//Scorecard

	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif               
	oXMLNode:oAddChild(TBIXMLNode():New("VALOR_PREVIO", lValorPrevio))	

return oXMLNode

// Insere nova entidade   
method nInsFromXML(oXML, cPath) class TKPI021
	local aFields, nInd, cID, nStatus := KPI_ST_OK
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd( aFields, {"ID", cID := ::cMakeID()} )
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI021
	local nInd, nStatus := KPI_ST_OK,	cID
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif
return nStatus

// Excluir entidade do server
method nDelFromXML(cID) class TKPI021
	local nStatus := KPI_ST_OK
	
	// Deleta o elemento
	if(nStatus == KPI_ST_OK)
		if(::lSeek(1, {cID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
	    endif

	// Quando implementar security
	// nStatus := KPI_ST_NORIGHTS
return nStatus


// Execute
method nExecute(cID, cExecCMD) class TKPI021
	local nStatus 	:= KPI_ST_OK
	local oProgress
			
	// Executando JOB
	if(cExecCMD ==  "TESTCON")
		oProgress := KPIProgressbar():New("datasrc_test")
		oProgress:setPercent(50) 
		
		nStatus := StartJob("KPIDataSrcJob", GetEnvServer(), .t., {cID, ::oOwner():cKpiPath(), cExecCMD})
		if !(valtype(nStatus) == "U")
			if nStatus < 0
				::fcMsg := STR0023//"Erro na tentativa de conexão."
				oProgress:setStatus(PROGRESS_BAR_ERROR) 
				oProgress:setMessage(STR0023)
				nStatus :=	KPI_ST_VALIDATION  							
			else
				::fcMsg := STR0024//"A conexão é valida."
				oProgress:setStatus(PROGRESS_BAR_END) 
				oProgress:setMessage(STR0024)
				nStatus :=	KPI_ST_OK
			endif
		else 
			
			::fcMsg :=  STR0023//"Erro na tentativa de conexão."
			oProgress:setStatus(PROGRESS_BAR_ERROR)
			oProgress:setMessage(STR0023)
			nStatus :=	KPI_ST_VALIDATION  			
		endif

		oProgress:setPercent(100) 		
		oProgress:endProgress()
							
	else
		oProgress := KPIProgressbar():New("datasrc_"+alltrim(cID))	   
		nStatus := StartJob("KPIDataSrcJob", GetEnvServer(), .t., {cID, ::oOwner():cKpiPath(), cExecCMD})
		if ( (valtype(nStatus) == "U")) 
			::fcMsg := STR0023//"Erro na tentativa de conexão."
			oProgress:setStatus(PROGRESS_BAR_ERROR) 
			oProgress:setMessage(STR0023)
			nStatus :=	KPI_ST_VALIDATION  							
		endif
	endif		

return nStatus
                                                  
//Funcao executa o job
function KPIDataSrcJob(aParms)
	local nTipoEnv		:= 0
	local nImpByID		:= 0  
	local nImpByUserID	:= 0  
	local nImpValor		:= 0  
	local nImpMeta		:= 0  
	local nImpPrevia	:= 0  
	local nReturn		:= 0	
	local nClasse		:= 0
	local nTopError		:= 0
	local nInd			:= 0	
	local nRegDw		:= 0
	local nTotReg		:= 0
	local nPorta		:= 0
	local nPosICod		:= 0
	local nPosUcod		:= 0
	local cServidor		:= ""
	local cEmpresa		:= ""
	local cEnvFil		:= ""
	local cRequestCalc	:= ""
	local cDataSrcID	:= ""
	local cDW_Url		:= ""
	local cDW_Sessao	:= ""	
	local cTopDb		:= ""
	local cTopAlias		:= ""
	local cTopServer	:= ""
	local cTexto		:= ""
	local cEnvironment  := ""	
	local cNome			:= ""
	local cUrlWsDw		:= "http://localhost/ws/SIGADW.apw"//Endereco do web service do dw		
	local cExecCMD 		:= "IMPORTCON"
	local cLogName		:= "DTSRC_"	
	local aParCampo		:= {}    
	local aValues		:= {}
	local aOrigem 		:= {}		
	local oExecEnv		:= nil
	local oProgress		:= nil
	local oObjDW		:= nil
	local oDataSrc		:= nil	
	local lExecCalc		:= .f.
	local lPrepEnv		:= .f.
	local lErro			:= .f.
	local lAgregado		:= .f. 

	private dCalcDe		:= date()
	private dCalcAte	:= date()
	private oParametro	:= nil	
	private oIndicador	:= nil//Usando na gravao da importacao	
	private oPlanilha	:= nil//Usando na gravao da importacao
	private aValDatas	:= {}
	private aValIds		:= {}

	public cKPIPath		:= "\"
	public cKPIErrorMsg := ""
	public oKPICore		:= nil	
    
    
    ErrorBlock( {|oE| __KPIError(oE)})
    
	//Parâmetros    
	if(len(aParms) >= 1 .and. valtype(aParms[1])=="N")
		cDataSrcID := strzero(aParms[1],10)		
	else
		cDataSrcID := cBIStr(aParms[1])
	endif
	
	if(len(aParms) >= 2 .and. valtype(aParms[2])=="C")
		cKPIPath := aParms[2]
	endif
	
	if(len(aParms) >= 3 .and. valtype(aParms[3])=="C")
		cExecCMD := aParms[3]
	endif	
	
	oKPICore := TKPICore():New(cKPIPath)

	set exclusive off
	set talk off
	set scoreboard off
	set date brit
	set epoch to 1960
	set century on
	set cursor on
	set deleted on
	
	//Atualizando o WorkStatus
	putGlbValue("bKpiImpRun","T")
		
	sleep(2000)//Espera 2 segundos para iniciar e dar tempo para o retorno ao KPI
	
	oKPICore:LogInit()//Iniciando fonte de dados, tabelas e log
	if(oKPICore:nDBOpen() < 0)
		oKPICore:Log(cBIMsgTopError(nTopError), KPI_LOG_SCRFILE)
		oKPICore:Log(STR0005, KPI_LOG_SCRFILE)/*//"Não foi póssível conectar-se ao banco de dados do KPI."*/
		putGlbValue("bKpiImpRun","F")
		return
	endif	

	// Seleciona fonte de dados informada
	oIndicador	:= oKPICore:oGetTable("INDICADOR")//Usando na gravao da importacao	
	oPlanilha	:= oKPICore:oGetTable("PLANILHA")//Usando na gravao da importacao
	oDataSrc 	:= oKPICore:oGetTable("DATASRC")

	if(!oDataSrc:lSeek(1, {cDataSrcID}))
		oKPICore:Log(STR0006, KPI_LOG_SCRFILE)/*//"Código da Fonte-de-Dados inexistente."*/
		putGlbValue("bKpiImpRun","F")
		return
	endif

	cNome := alltrim(oDataSrc:cValue("NOME"))
	oKPICore:Log(STR0007+cNome+"]", KPI_LOG_SCRFILE)/*//"Iniciando fonte de dados ["*/

	nClasse 	:= oDataSrc:nValue("CLASSE")
	nTipoEnv 	:= oDataSrc:nValue("TIPOENV") 
	cTopDB 		:= alltrim(oDataSrc:cValue("TOPDB"))
	cTopAlias 	:= alltrim(oDataSrc:cValue("TOPALIAS"))			
	cTopServer 	:= alltrim(oDataSrc:cValue("TOPSERVER"))				
	cEnvironment:= alltrim(oDataSrc:cValue("ENVIRON"))
	cTopConType := alltrim(oDataSrc:cValue("TOPCONTYPE"))
	cTexto 		:= alltrim(oDataSrc:cValue("TEXTO"))      
	nPorta		:= oDataSrc:nValue("PORTA")
	cServidor	:= alltrim(oDataSrc:cValue("SERVIDOR"))
	cEmpresa	:= alltrim(oDataSrc:cValue("EMPRESA"))
	cEnvFil		:= alltrim(oDataSrc:cValue("FILIAL"))
	lExecCalc 	:= oDataSrc:lValue("EXECALC") 
	lPrepEnv    := oDataSrc:lValue("PREPENV")  
	lAgregado	:= oDataSrc:lValue( "AGREGA" )  

	oScheduler  := TKPIScheduler():New()
	oKPICore:oOwner(oScheduler)	
	
	cLogName += alltrim(getJobProfString("INSTANCENAME", "SGI")) + "_"
	cLogName += alltrim(cDataSrcID) + "_"
	cLogName += strtran(dToc(date()),"/","") + "_"
	cLogName += strtran(time(),":","")
	
	oScheduler:lSche_CriaLog(cKPIPath,cLogName)//Criando o arquivo de log.
	oScheduler:lSche_WriteLog(STR0025)//"Iniciando a importação das fontes de dados."
              
	//Cria a estrutura do arquivo de Thread Collector
	oProgress := KPIProgressbar():New("datasrc_"+alltrim(cDataSrcID))
	oProgress:setMessage(STR0032) //"Iniciando a importação dos dados. Aguarde."
	oProgress:setPercent(10)	

	//Realiza a limpeza da planilha de valores e relatorio analítico para recarga de dados. 
   	If ( oDataSrc:lValue("LIMPEZA") )
    	oProgress:setMessage(STR0046)//"Realizando a limpeza para recarga de dados do período." 
		oProgress:setPercent(20)    
		
		If ( oDataSrc:lValue("ESPECIFI") )
			zeraPlanilha( oDataSrc:cValue("ID_SCOREC"), oDataSrc:dValue("PERIODO"))
		Else
			zeraPlanilha( oDataSrc:cValue("ID_SCOREC") )  
		EndIf                 
	EndIf
     
	//Inicia a importação da fonte de dados. 
	if(cExecCMD == "IMPORTCON" .or. cExecCMD == "TESTCON" ) .and. nClasse != KPI_SRC_DW 
		BICloseDB()
		
		// Pega configuração do environment
		if( nTipoEnv == KPI_SRC_CUSTOM )
			oKPICore:Log(STR0012, KPI_LOG_SCRFILE)/*//"Iniciando conexão TOP Connnect - Customizado"*/
			
			if( nTopError := nBIOpenDB(cTopDB, cTopAlias, cTopServer, cTopConType, {|cStr| oKPICore:Log(cStr, KPI_LOG_SCRFILE)}) ) < 0
				oKPICore:Log(cBIMsgTopError(nTopError), KPI_LOG_SCRFILE)
				oProgress:setStatus(PROGRESS_BAR_ERROR)
				oProgress:setMessage(STR0023)
				putGlbValue("bKpiImpRun","F")
				return -1
			endif
			oProgress:setMessage(STR0033) //"Conectado ao banco de dados."
			oProgress:setPercent(30)	
		elseif( nTipoEnv == KPI_SRC_ENVIRONMENT  .and. nClasse == KPI_SRC_TOP)
			oKPICore:Log(STR0013+cEnvironment+"]", KPI_LOG_SCRFILE)/*//"Iniciando conexão TOP Connnect - Ambiente ["*/
			if( nTopError := nBIOpenDBINI(nil, cEnvironment, {|cStr| oKPICore:Log(cStr, KPI_LOG_SCRFILE)}) ) < 0
				oKPICore:Log(cBIMsgTopError(nTopError), KPI_LOG_SCRFILE)
				putGlbValue("bKpiImpRun","F")
				return -1
			endif
		endif
	endif

	if(cExecCMD == "IMPORTCON")
		oKPICore:Log( STR0016 , KPI_LOG_SCRFILE) //"Identificando Tipo de Impotação e Realizando Conexão"

		if(nClasse == KPI_SRC_TOP)
			begin sequence
				oQuery	:= TBIQuery():New("SGI_TMP")
				oQuery:lOpen(cTexto)
			recover
				lErro := .t.
			end sequence

			if(! lErro)
				nImpByID		:=	aScan( oQuery:FAFIELDS, {|x| x:FCFIELDNAME == "ID"} )
				nImpByUserID	:=	aScan( oQuery:FAFIELDS, {|x| x:FCFIELDNAME == "USERID"} )
				nImpValor		:=	aScan( oQuery:FAFIELDS, {|x| x:FCFIELDNAME == "VALOR"} )
				nImpMeta		:=	aScan( oQuery:FAFIELDS, {|x| x:FCFIELDNAME == "META"} )
				nImpPrevia		:=	aScan( oQuery:FAFIELDS, {|x| x:FCFIELDNAME == "PREVIA"} )  
				
				aParCampo		:= {nImpByID, nImpByUserID, nImpValor, nImpMeta, nImpPrevia, lAgregado }

				oQuery:SetField("DATA", "D", 8)
				oProgress:setMessage(STR0034) //"Lendo o banco de dados."
				oProgress:setPercent(50)
				//Verifica se existem dados para serem importados.
				if( (nImpByID > 0 .or. nImpByUserID > 0) .and. (nImpValor > 0 .or. nImpMeta > 0 .or. nImpPrevia > 0 )  )
					while(!oQuery:lEof())
						aAdd(aOrigem, aPrepValores(oQuery,aParCampo))
						oQuery:_Next()
					end
				endif
			else
				oProgress:setStatus(PROGRESS_BAR_ERROR)
				oProgress:setMessage(STR0040) //"Erro na execução da consulta (query)."
				oKPICore:Log(STR0040, KPI_LOG_SCRFILE)
				putGlbValue("bKpiImpRun","F")
				return -1
			endif				
			
	    elseif nClasse == KPI_SRC_ADVPL
		
			oKPICore:Log( STR0014 , KPI_LOG_SCRFILE) //"Parseando e Excutando Função ADVPL de Importação"
			oExecEnv:= KPIExecInEnv():New()
             
            oExecEnv:setEnvironment(cEnvironment) 
			oExecEnv:setPortNumber(nPorta)
			oExecEnv:setServer(cServidor)
			oExecEnv:setEmpresa(cEmpresa) 
			oExecEnv:setFilial(cEnvFil)
			oExecEnv:setPrepEnv(lPrepEnv)
			
			if( oExecEnv:lConnect())
				if ! oExecEnv:lFindFunction(substr(cTexto,at(cTexto,"(")))
					oKPICore:Log(STR0029, KPI_LOG_SCRFILE) //"*ERRO Função não existente no RPO."
					oProgress:setStatus(PROGRESS_BAR_ERROR)
					oProgress:setMessage(STR0029)
					oExecEnv:lEndConnection()
					putGlbValue("bKpiImpRun","F")
					return -1
				else
					
					oProgress:setMessage(STR0038) //"Requisitando os dados."
					oProgress:setPercent(50) 		
		
					begin sequence
						aOrigem := oExecEnv:xExecFunction(cTexto)
					recover
						aOrigem := {}
					end sequence
										
				endif
			else
				oProgress:setStatus(PROGRESS_BAR_ERROR)
				oProgress:setMessage(STR0041) //"Erro de conexão."
				oKPICore:Log(STR0041, KPI_LOG_SCRFILE)
				putGlbValue("bKpiImpRun","F")
				return -1
			endif				
		elseif nClasse == KPI_SRC_DW
			oParametro := oKpiCore:oGetTable("PARAMETRO")
			
			
			cUrlWsDw := oParametro:getValue("WS_DW_INTEGRATION")
			if !("http" $ cUrlWsDw)
				cUrlWsDw :=	"http://" + cUrlWsDw
			endif
			
			oObjDW 		:= WSSIGADW():New()			
			oObjDW:_URL := cUrlWsDw
	
			//Logando no DW				
			cDW_Url		:= oDataSrc:cValue("DW_URL")
			if !("http" $ cDW_Url)
				cDW_Url :=	"http://" + cDW_Url
			endif			
			oObjDW:LOGIN(alltrim(cDW_Url),alltrim(oDataSrc:cValue("DW_NOME")),alltrim(oParametro:getValue("DW_USER")),oParametro:getValue("DW_PWD"))

			cDW_Sessao	:=	oObjDW:CLOGINRESULT
			if valType(cDW_Sessao) != "U"
				//Origem
				oKPICore:Log(STR0016, KPI_LOG_SCRFILE)/*//"Extraindo origem da importação"*/
				lStruCon:=	oObjDW:RETCONSULTA(cDW_Sessao,oDataSrc:nValue("DW_IDCON"),.t.)
			
				if(lStruCon)
					oPlanilha	:=	oKPICore:oGetTable("PLANILHA")

					//Valores recebidos do DW
					aFieldsX	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSX:OWSFIELDSDET
					aFieldsY	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSY:OWSFIELDSDET
					aIndicador	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSMEASURES:OWSFIELDSDET		
	
					//Localizando onde estao os campos.                
					nPosICod	:= ascan(aFieldsY	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("DW_INDID"))})
					nPosUcod	:= ascan(aFieldsY	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("DW_INDIDIP"))})
					nPosY 		:= ascan(aFieldsY	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("DW_DATA"))})
					nPosX 		:= ascan(aFieldsX	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("DW_DATA"))})
					nPodR 		:= ascan(aIndicador	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("DW_INDREAL"))})
					nPodM 		:= ascan(aIndicador	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("DW_INDMETA"))})
					nPodP 		:= ascan(aIndicador	,{|campo| campo:CNAME == alltrim(oDataSrc:cValue("DW_INDPREV"))})
					
					//Recuperando o ID do Indicador. Ordem USERID,ID e ID cadastrado na fonte de dados.
					if(nPosUcod != 0)
						aValIds	:=	aFieldsY[nPosUcod]:OWSVALUES:OWSFIELDSVALUE  					
					elseif(nPosICod != 0)
						aValIds	:=	aFieldsY[nPosICod]:OWSVALUES:OWSFIELDSVALUE
					endif 					
					
					//Pegando as datas.
					if(nPosY != 0)
						aValDatas	:=	aFieldsY[nPosY]:OWSVALUES:OWSFIELDSVALUE
					elseif(nPosX != 0)
						aValDatas	:=	aFieldsX[nPosX]:OWSVALUES:OWSFIELDSVALUE
					endif 
					
					//Real				
					if(nPodR != 0)
						aValReal :=	aIndicador[nPodR]:OWSVALUES:OWSFIELDSVALUE
					endif 
					
					//Meta
					if(nPodM != 0)
						aValMeta :=	aIndicador[nPodM]:OWSVALUES:OWSFIELDSVALUE
					endif 
					
					//Previa
					if(nPodP != 0)
						aValPrevia := aIndicador[nPodP]:OWSVALUES:OWSFIELDSVALUE
					endif 

					//Grava os dados em uma tabela temporaria
					if(len(aValDatas) > 0)
						nTotReg	:=	len(aValDatas)						
						for nRegDw	:= 1 to nTotReg
							aValues := {}

                            //Recuperando os IDs dos indicadores
                            if nPosUcod != 0
								aadd(aValues,"")//id do indicador                            
								aadd(aValues,aValIds[nRegDw]:CVALOR)//Client ID	                            
							elseif nPosICod != 0
								aadd(aValues,aValIds[nRegDw]:CVALOR)//id do indicador                            
								aadd(aValues,"")//Client ID	
							else
								aadd(aValues,oDataSrc:cValue("SGI_IND"))//id do indicador                            
								aadd(aValues,"")//Client ID								
							endif							

							aadd(aValues,sTOd(aValDatas[nRegDw]:CVALOR))//Data   
							if( len(alltrim(oDataSrc:cValue("DW_INDREAL"))) > 0 )//Importar Real
								aadd(aValues,aValReal[nRegDw]:CVALOR)//Valor
							else
								aadd(aValues,"")							
							endif
							
							if( len(alltrim(oDataSrc:cValue("DW_INDMETA"))) > 0 )//Importar Meta
								aadd(aValues,aValMeta[nRegDw]:CVALOR)//Meta							
							else
								aadd(aValues,"")															
							endif
							aadd(aValues,"")//Descricao
							aadd(aValues,"F")//Agregação
							
							if( len(alltrim(oDataSrc:cValue("DW_INDPREV"))) > 0 )//Importar Previa
								aadd(aValues,aValPrevia[nRegDw]:CVALOR)//Previa							
							else
								aadd(aValues,"")															
							endif						
							aAdd(aOrigem,aValues)							
						next nRegDw
					else
						oKPICore:Log(STR0043, KPI_LOG_SCRFILE)//"A coluna de data e valor tem tamanhos diferentes."
					endif					
				endif			
				//Destino
				oKPICore:Log(STR0044, KPI_LOG_SCRFILE)// "Gravando planilha"
			else
				oKPICore:Log(STR0045, KPI_LOG_SCRFILE)//STR0045 "Não foi possivel fazer a conexão com o DW."  
				oProgress:setStatus(PROGRESS_BAR_ERROR)
				oProgress:setMessage(STR0045)    
				putGlbValue("bKpiImpRun","F")
				return KPI_ST_OK
			endif
	    endif                        
	    
	    if(nClasse != KPI_SRC_DW )
			BICloseDB()
			oKPICore:Log( STR0017 , KPI_LOG_SCRFILE) //"Gravando Dados Importados"  
			
			if(oKPICore:nDBOpen() < 0)
				oKPICore:Log(cBIMsgTopError(nTopError), KPI_LOG_SCRFILE)
				oKPICore:Log(" ")
				oProgress:setStatus(PROGRESS_BAR_ERROR)
				oProgress:setMessage(cBIMsgTopError(nTopError))
				putGlbValue("bKpiImpRun","F")
				return KPI_ST_OK
			endif
		endif			

		oProgress:setMessage(STR0035) //"Gravando os dados importados."
		oProgress:setPercent(70)	

	    if(len(aOrigem) > 0 )  
			for nInd := 1 to len(aOrigem)
				saveIndImp(aOrigem[nInd], oScheduler)
			next
			oProgress:setMessage(STR0037)//"Importação finalizada."
		else
			oProgress:setMessage(STR0039)//"Não existiam valores para importação."
		endif				
        
        //Força a limpeza de memória
		aOrigem := {}               
		
		oKPICore:Log(STR0018, KPI_LOG_SCRFILE)/*//"Importação concluída"*/
		oProgress:setMessage(STR0036)//"Reiniciando o banco de dados."
		oProgress:setPercent(90)	

		BICloseDB()
	endif
	
	//Atualizando o WorkStatus
	putGlbValue("bKpiImpRun","F")
	putGlbValue("bKpiIndUpdate","T")
		
	oProgress:setMessage(STR0037)//"Importação finalizada."
	oProgress:setPercent(100)
	oProgress:endProgress()

	oScheduler:lSche_WriteLog(STR0026) //"Finalizado a importação das fontes de dados."
	oScheduler:lSche_CloseLog()
	oKPICore:Log(STR0021+cNome+"]", KPI_LOG_SCRFILE)/*//"Finalizando fonte de dados ["*/	
return nReturn

/*
Preparacao do array com os valores
*/
static function aPrepValores(oQuery, aParam)
	local aValues := {}
	local nImpByID		:=	aParam[1]
	local nImpByUserID	:=	aParam[2]
	local nImpValor		:=	aParam[3]
	local nImpMeta		:=	aParam[4]
	local nImpPrevia	:=	aParam[5]
	Local lAgregado		:= 	aParam[6]

     //Id
	if(nImpByID > 0 )
		aadd(aValues,oQuery:cValue("ID"))
	else
		aadd(aValues,"")			
	endif

	//UserID			
	if(nImpByUserID > 0)
		aadd(aValues,oQuery:cValue("USERID"))
	else
		aadd(aValues,"")
	endif				

	//Data
	aadd(aValues,oQuery:dValue("DATA"))

	//Valor
	if(nImpValor > 0)
		aadd(aValues,oQuery:cValue("VALOR"))			
	else
		aadd(aValues,"")
	endif

    //Meta
	if(nImpMeta > 0)
		aadd(aValues,oQuery:cValue("META"))
	else
		aadd(aValues,"")
	endif

	//Descricao em branco.
	aadd(aValues,"")    
	
	//Define se é agregação. 
	aadd(aValues, cBIStr( lAgregado ) )
		
    //Previa
	if(nImpPrevia > 0)
		aadd(aValues,oQuery:cValue("PREVIA"))
	else
		aadd(aValues,"")			
	endif
return aValues
  
/**
Realiza a limpeza da planilha de valores para evitar "lixo" decorrente de reimportação. 
@param cIDScorecard ID do scorecard da fonte de dados. 
@param dDataAlvo Data para a realização limpeza. 
*/ 
Static Function zeraPlanilha( cIDScorecard, dDataAlvo )
 	Local oScoreCard    := oKPICore:oGetTable("SCORECARD") 
   	Local oIndicador	:= oKPICore:oGetTable("INDICADOR")
   	Local oPlanilha		:= oKPICore:oGetTable("PLANILHA")
   	Local oAnalitico	:= oKPICore:oGetTable("ANALITICO")
   	Local nScorecard   	:= 0
   	Local aScorecard    := {}
    Local aFields		:= {}     
                                                            
 	Default dDataAlvo   := Date()

    If ( oScoreCard:lSeek(1, { cIDScorecard } ) )
		aScorecard 	:= oScoreCard:aGetAllChilds( cIDScorecard )  
		aAdd( aScorecard, cIDScorecard )
	     
		aAdd(aFields, {"VALOR"	, nBIVal(0) })
		aAdd(aFields, {"META"	, nBIVal(0) })
		aAdd(aFields, {"PREVIA"	, nBIVal(0) })
	
		For nScorecard  := 1 to Len ( aScorecard )     
			If ( oIndicador:lSeek(3, { aScorecard[ nScorecard ] } ) )  
				while( ! oIndicador:lEof() .And. oIndicador:cValue("ID_SCOREC") == aScorecard[ nScorecard ] ) 
					If ( oPlanilha:lDateSeek( oIndicador:cValue("ID") , dDataAlvo , oIndicador:nValue("FREQ") ) ) 
						cIDPlanilha := oPlanilha:cValue("ID")  

						If ( oPlanilha:lUpdate(aFields) )
							oAnalitico:lRemove( cIDPlanilha )
						EndIf
					EndIf
	
					oIndicador:_Next()
				EndDo		
			Endif
		Next nScorecard
	EndIf
Return 