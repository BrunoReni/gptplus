/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpi032_Duplicador.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 02.01.06 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpi032_Duplicador.ch"
/*--------------------------------------------------------------------------------------
@entity CalcIndicador
Calcula os valores dos indicadores e metas.
@table KPI032
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SCO_DUPLICADOR"
#define TAG_GROUP  "SCO_DUPLICADORES"
#define TEXT_ENTITY STR0001/*//"Duplicador"*/
#define TEXT_GROUP  STR0002/*//"Duplicadores"*/

//Array de comandos
#define		REQ_SCO_ORIGEM			1
#define		REQ_SCO_DESTINO			2
#define 	REQ_SCO_DIFERENCIADOR	3
#define 	REQ_POS_DIFERENCIADOR	4
#define 	REQ_IND_DIFERENCIADOR	5 
#define 	REQ_IND_CANDUP  		6 
#define 	REQ_COD_DIFERENCIADOR  	7
#define 	REQ_COD_POSICAO  		8

class TKPIDuplicador from TBITable
	data oIndDuplicado	//Indicadores que foram duplicados.
	data oScoDuplicado	//ScoreCards que foram duplicados.
	data oMetDuplicado	//Metas Formula que foram duplicadas.
	data cNomeDif      	//Caracter de diferenciação. 
	data lIndicadorDif	//Identifica se o caracter de diferenciação será aplicado aos indicadores. 
	data cNomePosDif    //Posição do caracter de diferenciação. 
	data lDupInd	 	//Identifica se os indicadores serão duplicados. 	
   	data cCodigoDif     //Caracter de diferenciação.   
   	data nCodigoPosDif  //Posição do caracter de diferenciação.    
	data dupliLog		//Referencia para o arquivo de log.
		
	method New() constructor
	method NewKPI032()
	method oToXMLNode(cID,cRequest)
	method nExecute(cID, cExecCMD)
	method oCriaTableTemp(cTableName,cIndexName)
	method upDateTemp(oTable,cOldID,cNewID) 
	method lCheckRefCircular(cOrigem,cDestino)
	method nDupScoreCard(cOldID,cNewParentID)
	method nDupIndicador(cOldID,cNewParentID) 
	method lStartDuplicador(cScoOrigem,cScoDestino)
	method lDup_CriaLog(cLogName) 
	method lDup_WriteLog()
	method lDup_CloseLog()
	method cUpDateFormula(cFormula)
	method cCheckMetaFormula(cOldID)
	method cNovoNome(cNomeOriginal) 
	method cNovoCodigo(cCodigoOriginal)
endclass
	
method New() class TKPIDuplicador
	::NewKPI032()
return

method NewKPI032() class TKPIDuplicador
    ::lIndicadorDif		:= .T.
    ::cNomePosDif 		:= 1
return

/*-------------------------------------------------------------------------------------
Carrega o no requisitado.
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com os dados
--------------------------------------------------------------------------------------*/
method oToXMLNode(cID,cRequest) class TKPIDuplicador
	local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)    

	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.T.,.T., __ScoreName))	
	
return oXMLNode  

/*
*Metodo do nExecute
*/
method nExecute(cID, cRequest)  class TKPIDuplicador
	local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	local aRequest		:=	aBIToken(cRequest, "|",.f.)
	local cTableName	:=	""
	local cIndexName	:=	""
	local lStatusDup	:=	.t.
	local cInsName		:=	""
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )
	local cLogName 		:= alltrim(getJobProfString("INSTANCENAME", "SGI"))+"_"
		  cLogName 		+= strtran(dToc(date()),"/","") +"_"
		  cLogName 		+= strtran(time(),":","")
		

	default cRequest 	:= ""	

	if(! ::lCheckRefCircular(padr(aRequest[REQ_SCO_ORIGEM],10),padr(aRequest[REQ_SCO_DESTINO],10))) 
		cInsName		:=	left(alltrim(getJobProfString("INSTANCENAME", "SGI")),6)	
		//"Iniciando a duplicação do(s) Scorecard(s)."
		oKPICore:Log(STR0023 + cTextScor + STR0024, KPI_LOG_SCRFILE)	//"Iniciado a duplicação do(s) "###"s)."   
		//Criando o arquivo de log.
		::lDup_CriaLog(cLogName)						    
		//"Iniciando a duplicação do(s) Scorecard(s)"
		::lDup_WriteLog(STR0023 + cTextScor + STR0024)	//"Iniciado a duplicação do(s) "###"s)."
		//Cria a tabela temporaria de indicadore
		cTableName		:=	"di" + cInsName
		cIndexName		:=	cTableName+".cdx" 
		::oIndDuplicado	:= ::oCriaTableTemp(cTableName,cIndexName)
		//Cria a tabela temporaria do scorecard
		cTableName		:=	"ds"+cInsName
		cIndexName		:=	cTableName+".cdx" 
		::oScoDuplicado	:= ::oCriaTableTemp(cTableName,cIndexName)
		//Cria a tabela temporaria de meta formula	
		cTableName		:=	"dm"+cInsName
		cIndexName		:=	cTableName+".cdx" 
		::oMetDuplicado	:= ::oCriaTableTemp(cTableName,cIndexName)
		//Recupera os parâmetros para execução da duplicação.   
		::cNomeDif			:=	alltrim(aRequest[REQ_SCO_DIFERENCIADOR]) 
		::lIndicadorDif		:=	xBIConvTo("L",aRequest[REQ_IND_DIFERENCIADOR])
		::cNomePosDif 		:= 	Val(aRequest[REQ_POS_DIFERENCIADOR])
		::lDupInd  			:=  xBIConvTo("L",aRequest[REQ_IND_CANDUP]) 
	   	::cCodigoDif     	:=	AllTrim(aRequest[REQ_COD_DIFERENCIADOR]) 
   		::nCodigoPosDif  	:= 	Val(aRequest[REQ_COD_POSICAO] )                 
		//Iniciando o metodo de duplicacao
		::oOwner():oOltpController():lBeginTransaction()
		
		lStatusDup := ::lStartDuplicador(padr(aRequest[REQ_SCO_ORIGEM],10),padr(aRequest[REQ_SCO_DESTINO],10))
        
		if !lStatusDup
			::oOwner():oOltpController():lRollback()
			::lDup_WriteLog(STR0010) //"Atualização dos dados canceladas. (RollBack)"
		endif
		
		::oOwner():oOltpController():lEndTransaction()
		
		::oIndDuplicado:Free()
		::oScoDuplicado:Free()
		::oMetDuplicado:Free()
	
		::oIndDuplicado:DropTable()
		::oScoDuplicado:DropTable()
		::oMetDuplicado:DropTable()

		::lDup_WriteLog(STR0025 + cTextScor + STR0024)  //"Finalizado a duplicação do(s) "###(s)"
		::lDup_CloseLog() 
		
		oKPICore:Log(STR0025 + cTextScor + STR0024 , KPI_LOG_SCRFILE)  //"Finalizado a duplicação###"(s)."
	else
		::fcMsg := STR0013 //"Está operação não pode ser executada porque resulta em referência circular."
		return KPI_ST_VALIDATION  
	endif
return oXMLNode

/*
*Faz a duplicacao dos scorecards.
*/
method lStartDuplicador(cScoOrigem,cScoDestino) class TKPIDuplicador
	local nStatus 		:= 	KPI_ST_OK
	local oIndicador	:=	::oOwner():oGetTable("INDICADOR")
	local lRet			:=	.t.
	local cFormula		:=	""
	local aSavePos		:=	{}
	local aFields 		:=	{}
	local oProgress 	:= KPIProgressbar():New("dup_sco_1") 
  
 	//Duplicação dos Scorecards.                                                    
	oProgress:setMessage(STR0020) //"Duplicando Scorecards..." 
	oProgress:setPercent(10)  
 
	::nDupScoreCard(cScoOrigem,cScoDestino)
          
    //Verifica se os indicadores também devem ser duplicados.  
    If( ::lDupInd )
	    //Duplicação dos Indicadores.
		oProgress:setMessage(STR0021) //"Duplicando Indicadores..." 
		oProgress:setPercent(50)  	                         
			
		::oScoDuplicado:_First()  
		  
		do while(!::oScoDuplicado:lEof())
			oIndicador:cSQLFilter("ID_SCOREC = '" + ::oScoDuplicado:cValue("OLD_ID") + "'" )
			oIndicador:lFiltered(.t.)
			oIndicador:_First()
	
			do while( ! oIndicador:lEof())  
				if(alltrim(oIndicador:cValue("ID_INDICA")) == "0")	
					dbSelectArea(oIndicador:cAlias())
					aSavePos	:=	{IndexOrd(), recno(), oIndicador:cSqlFilter()}
					nStatus := ::nDupIndicador(oIndicador:cValue("ID"),oIndicador:cValue("ID_INDICA"))
	
					if(nStatus != KPI_ST_OK)//Se houver um erro paro o processamento.
						exit
					endif
		
					//RestPos
					oIndicador:faSavePos:= aSavePos
					oIndicador:RestPos()
				endif 
								
				oIndicador:_Next()
			enddo
	
			if(nStatus != KPI_ST_OK)
				exit
			endif
			::oScoDuplicado:_Next()
	
			oIndicador:cSQLFilter("")
		end while
	
		//Corrigindo a referencia das formulas
		if(nStatus == KPI_ST_OK)  
			::oIndDuplicado:_First()  
			
			do while(!::oIndDuplicado:lEof())  
				if(oIndicador:lSeek(1,{::oIndDuplicado:cValue("NEW_ID")}))   
					cFormula	:=	::cUpDateFormula(oIndicador:cValue("FORMULA"))  
					
					if !(cFormula == "")   
						aFields 	:= {}
						aAdd( aFields, {"FORMULA", cFormula})      
						
						if( ! oIndicador:lUpdate(aFields))   
							if(oIndicador:nLastError()==DBERROR_UNIQUE) 
								nStatus := KPI_ST_UNIQUE
								::lDup_WriteLog(STR0014 + alltrim(oIndicador:cValue("NOME") ))  //"Erro atualizando fórmula.<br> Chave duplicada para o indicador: "
								exit
							else     
								::lDup_WriteLog(STR0015 + alltrim(oIndicador:cValue("NOME") ))  //"Erro atualizando fórmula.<br> Registro em uso indicador: "
								nStatus := KPI_ST_INUSE
								exit
							endif
						endif
					endif
		        endif   
		        
				::oIndDuplicado:_Next() 
			End While			
		Endif			
	EndIf
		 
	oProgress:setMessage(STR0022) //"Processamento Finalizado..." 
	oProgress:setPercent(100)  	
	oProgress:endProgress()  	
		
	if(nStatus != 	KPI_ST_OK)
		lRet := .f.
	endif
	
return lRet	

/*
*Cria a tabela que armazena os indicadores que ja foram duplicados
*/
method oCriaTableTemp(cTableName,cIndexName) class TKPIDuplicador
	local oTableTemp	 := TBITable():New(cTableName+getDbExtension() ,cTableName)

	oTableTemp:lLocal(.t.)		

	//Fields
	oTableTemp:addField(TBIField():New("OLD_ID","C"	,15))
	oTableTemp:addField(TBIField():New("NEW_ID","C"	,10))
	
	//Indexes
	oTableTemp:addIndex(TBIIndex():New(cIndexName,{"OLD_ID"},.f.))
	oTableTemp:ChkStruct(.t.)
	oTableTemp:lOpen(.f., .t.)
	
return oTableTemp

/*
*Duplica os ScoreCards.
*/
method nDupScoreCard(cOldID,cNewParentID) class TKPIDuplicador
	local nStatus 		:= KPI_ST_OK
	local cNewID		:= ""
	local oScoreCard	:= ::oOwner():oGetTable("SCORECARD")
	local oPar			:= ::oOwner():oGetTable("PARAMETRO")
	local oEntity		:= nil
	local cEntity		:= ""
	local cTipoScore	:= ""
	local aSavePos		:= {}
	local aFields		:= {}

	if alltrim(cNewParentID) == "0"
		cNewParentID:= space(10)
	endif

	if oScoreCard:lSeek(1,{cOldID})
		aFields := oScoreCard:xRecord(RF_ARRAY, {"ID", "PARENTID","NOME"})

		aAdd( aFields, {"ID",  cNewID := oScoreCard:cMakeID()} )
		aAdd( aFields, {"PARENTID", cNewParentID} )
		aAdd( aFields, {"NOME", ::cNovoNome(oScoreCard:cValue("NOME"))} )
		
		// Grava
		if oScoreCard:lAppend(aFields)
			//Modo de análise BSC
			If oPar:getValue("MODO_ANALISE") == ANALISE_BSC
				cTipoScore := oScoreCard:cValue("TIPOSCORE")
				cEntity := ::oOwner():entityByCode(cTipoScore)
				oEntity := ::oOwner():oGetTable(cEntity)
				
				//localiza entidade origem
				if oEntity:lSeek( 1, {cOldID} )
					aFields := oEntity:xRecord(RF_ARRAY, {"ID"})
					aAdd( aFields, {"ID",  cNewID} )

					//duplica entidade
					if !oEntity:lAppend(aFields)
						if oEntity:nLastError()==DBERROR_UNIQUE
							::lDup_WriteLog(STR0026 + cTextScor + "." + STR0027 + cTextScor + ": " + alltrim(oScoreCard:cValue("NOME") ))	 //"Erro duplicando "###"Chave duplicada para o "
							nStatus := KPI_ST_UNIQUE
						else
							::lDup_WriteLog(STR0026 + cTextScor + "." + STR0028 + cTextScor + ": " + alltrim(oScoreCard:cValue("NOME") ))	 //"Erro duplicando "###"Registro em uso para o "
							nStatus := KPI_ST_INUSE
						endif
					endif
				endif
			endif
		else
			if oScoreCard:nLastError()==DBERROR_UNIQUE
				::lDup_WriteLog(STR0026 + cTextScor + "." + STR0027 + cTextScor + ": " + alltrim(oScoreCard:cValue("NOME") ))	 //"Erro duplicando "###"Chave duplicada para o "
				nStatus := KPI_ST_UNIQUE
			else
				::lDup_WriteLog(STR0026 + cTextScor + "." + STR0028 + cTextScor + ": " + alltrim(oScoreCard:cValue("NOME") ))	 //"Erro duplicando "###"Registro em uso para o "
				nStatus := KPI_ST_INUSE
			endif
		endif

		if nStatus == KPI_ST_OK
			::upDateTemp(::oScoDuplicado,cOldID,cNewID)
		endif

		if nStatus == KPI_ST_OK .and. oScoreCard:lSeek(2,{cOldID})
			while !oScoreCard:lEof() .and. oScoreCard:cValue("PARENTID") == cOldID .and. nStatus == KPI_ST_OK
				dbSelectArea(oScoreCard:cAlias())//SavePos
				aSavePos	:=	{IndexOrd(), recno(), oScoreCard:cSqlFilter()}
	
				nStatus := ::nDupScoreCard(oScoreCard:cValue("ID"),cNewID)//Gera o registro para os filhos

				if(nStatus != KPI_ST_OK)//Se houver um erro paro o processamento.
					exit
				endif
				
				oScoreCard:faSavePos:= aSavePos	//RestPos
				oScoreCard:RestPos()
				
				oScoreCard:_Next()
			enddo
		endif			
	endif
	
return nStatus

/*
* Duplica os Indicadores.
*/
method nDupIndicador(cOldID,cNewParentID) class TKPIDuplicador
	local nStatus 		:= 	KPI_ST_OK
	local cNewID		:=	""
	local cCodClie		:= 	""
	local oIndicador	:=	::oOwner():oGetTable("INDICADOR")
	local aSavePos		:=	{}	

	aFields     		:=	{}

	if(oIndicador:lSeek(1,{cOldID}))
		aFields 	:= oIndicador:xRecord(RF_ARRAY, {"ID", "ID_INDICA","ID_SCOREC","ID_CODCLI","NOME"})

		aAdd( aFields, {"ID"		, cNewID := oIndicador:cMakeID()} )
		aAdd( aFields, {"ID_INDICA"	, cNewParentID} )
		aAdd( aFields, {"ID_SCOREC"	, ::oScoDuplicado:cValue("NEW_ID")} )
		
		cCodClie := alltrim(oIndicador:cValue("ID_CODCLI"))
		
		If Len( cCodClie ) > 0
			If ( ! Empty( ::cCodigoDif ) )
				aAdd( aFields, {"ID_CODCLI"	, ::cNovoCodigo( cCodClie ) } )
			Else
				aAdd( aFields, {"ID_CODCLI"	, "DUP_" + cCodClie} )
			EndIf
		else                                      
			aAdd( aFields, {"ID_CODCLI"	, "" } )
		endif
		
		if( ! ::lIndicadorDif )
			aAdd( aFields, {"NOME", oIndicador:cValue("NOME")})
		else
			aAdd( aFields, {"NOME",	::cNovoNome(oIndicador:cValue("NOME"))})
		endif			
		
		// Grava
		if( ! oIndicador:lAppend(aFields))
			if(oIndicador:nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
				::lDup_WriteLog(STR0018 + alltrim(oIndicador:cValue("NOME") )) 	//"Erro duplicando indicador. <br> Chave duplicada para o indicador: "
			else
				::lDup_WriteLog(STR0019 + alltrim(oIndicador:cValue("NOME") ))  //"Erro duplicando indicador. <br> Registro em uso indicador: "
				nStatus := KPI_ST_INUSE
			endif
		else
			::upDateTemp(::oIndDuplicado,cOldID,cNewID)
		endif	
		
		if(nStatus == KPI_ST_OK  .and. oIndicador:lSeek(4,{cOldID}))
			while( ! oIndicador:lEof() .and. oIndicador:cValue("ID_INDICA") == cOldID .and. nStatus == KPI_ST_OK)
				dbSelectArea(oIndicador:cAlias())//SavePos
				aSavePos	:=	{IndexOrd(), recno(), oIndicador:cSqlFilter()}
	
				nStatus := ::nDupIndicador(oIndicador:cValue("ID"),cNewID)//Gera o registro para os filhos

				if(nStatus != KPI_ST_OK)//Se houver um erro paro o processamento.
					exit
				endif
				
				oIndicador:faSavePos:= aSavePos	//RestPos
				oIndicador:RestPos()
				
				oIndicador:_Next()
			enddo
		endif			
	endif

return nStatus

/*
*Cria o arquivo de log
*/
method lDup_CriaLog(cLogName) class TKPIDuplicador
	local cPathSite		:=	left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))

	::dupliLog	:= 	TBIFileIO():New(oKpiCore:cKpiPath()+"logs\ScoCopy\"+ cLogName + ".html")
	
	// Cria o arquivo htm
	If ! ::DupliLog:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0003) //"Erro na criacao do arquivo de log."
	else
		::dupliLog:nWriteLN('<html>')
		::dupliLog:nWriteLN('<head>')
		::dupliLog:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
  		::dupliLog:nWriteLN('<title>'+STR0004+'</title>')
		::dupliLog:nWriteLN('<link href= "'+ cPathSite + 'imagens/report.css" rel="stylesheet" type="text/css">')
		::dupliLog:nWriteLN('</head>')
		::dupliLog:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
		::dupliLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::dupliLog:nWriteLN('<tr>')
		::dupliLog:nWriteLN('<td class="titulo"><div align="center">'+STR0004+ '</div></td>')
		::dupliLog:nWriteLN('</tr>')
		::dupliLog:nWriteLN('</table>')
		::dupliLog:nWriteLN('<table width="80%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		::dupliLog:nWriteLN('<tr>')
		::dupliLog:nWriteLN('<td width="21%" class="cabecalho_1">'+STR0006+'</td>')
		::dupliLog:nWriteLN('<td width="79%" class="cabecalho_1">'+STR0005+'</td>')
		::dupliLog:nWriteLN('</tr>')
	endif

return .t.

/*
*Grava um evento no log.
*/
method lDup_WriteLog(cMensagem) class TKPIDuplicador

	::dupliLog:nWriteLN('<tr>')
	::dupliLog:nWriteLN('<td class="texto">'+dToC(date())+ " " + time()+ '</td>')
	::dupliLog:nWriteLN('<td class="texto">'+cMensagem+'</td>')
	::dupliLog:nWriteLN('</tr>')

return .t.

/*
*Fecha o arquivo de log.
*/
method lDup_CloseLog() class TKPIDuplicador
	::dupliLog:nWriteLN('</table>')
	::dupliLog:nWriteLN('<br>')
	::dupliLog:nWriteLN('</body>')
	::dupliLog:nWriteLN('</html>')
	::DupliLog:lClose()

return .t.

/*
*Faz a atualizacao do arquivo temporario.
*/
method upDateTemp(oTable,cOldID,cNewID) class TKPIDuplicador
	local aFields	:=	{}
	local nStatus	:=	KPI_ST_OK
	
	aAdd(aFields, {"OLD_ID", cOldID})
	aAdd(aFields, {"NEW_ID", cNewID})	
	
	// Grava
	if(!oTable:lAppend(aFields))
		if(oTable:nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	

return nStatus

/*
*Faz a atualizacao do arquivo temporario.
*/
method cUpDateFormula(cFormula) class TKPIDuplicador
	local cNewFormula	:=	""    
	local cNewItem		:=	""	
	local aItemFormula	:=	aBIToken(cFormula, "|",.f.)
	local nItem			:=	0

	::oIndDuplicado:SavePos()
	
	for nItem := 1 to len(aItemFormula)
		cItemFormula := aItemFormula[nItem]

		//Verifica se e uma formula.
		if(at("I.", cItemFormula) != 0)
			cID	 :=	strTran(cItemFormula, "I.", "")
			if(::oIndDuplicado:lSeek(1,{cID}))
				cNewItem := "I." + alltrim(::oIndDuplicado:cValue("NEW_ID"))
			else
				cNewItem := cItemFormula
			endif
		elseif(at("M", cItemFormula) != 0)
			cID	:=	strTran(cItemFormula, "M.", "")
			if(::oMetDuplicado:lSeek(1,{cID}))
				cNewItem 	:= "M." + alltrim(::oIndDuplicado:cValue("NEW_ID"))
			else
				cNewItem	:=  ::cCheckMetaFormula(cID) //Verifica a necessidade de duplicacao da meta formula.
			 	cNewItem	:=  "M." + alltrim(cNewItem	)
			endif
		else
			cNewItem	:= cItemFormula
		endif

		if(! empty(cItemFormula))		
			cNewFormula := cNewFormula + "|" + cNewItem
		endif			
	next nItem
	
	::oIndDuplicado:RestPos()
	
return cNewFormula

/*
*Faz a duplicacao da meta formula.
*/
method cCheckMetaFormula(cOldID) class TKPIDuplicador
	local cMetaNewID	:=	""
	local oMetaFormula	:=	::oOwner():oGetTable("METAFORMULA")	
	
	aFields     		:=	{}

	if(oMetaFormula:lSeek(1,{cOldID}))
		aFields 	:= oMetaFormula:xRecord(RF_ARRAY, {"ID", "FORMULA","NOME"})

		aAdd( aFields, {"ID"		, cMetaNewID := oMetaFormula:cMakeID()})
		aAdd( aFields, {"FORMULA"	, ::cUpDateFormula(oMetaFormula:cValue("FORMULA"))} )
		aAdd( aFields, {"NOME"		, ::cNovoNome(oMetaFormula:cValue("NOME"))})
			
		// Grava
		if(! oMetaFormula:lAppend(aFields))
			if(oMetaFormula:nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		else
			::upDateTemp(::oMetDuplicado,cOldID,cMetaNewID)
		endif	
	endif
	
return cMetaNewID

/*
* Verifica se o scorecard de origem esta referenciando o scorecard de destino.
*/
method lCheckRefCircular(cOrigem,cDestino) class TKPIDuplicador
	local oScoreCard	:=	::oOwner():oGetTable("SCORECARD")
	local aSavePos		:=	{}	
	local lRefCirc		:=	.f.

	//Se a origem for igual ao destino esta em referencia circular.	
	if!(alltrim(cOrigem) == alltrim(cDestino))
		if(oScoreCard:lSeek(1,{cOrigem}))
			if(oScoreCard:lSeek(2,{cOrigem}))
				while( ! oScoreCard:lEof() .and. oScoreCard:cValue("PARENTID") == cOrigem )
					dbSelectArea(oScoreCard:cAlias())//SavePos
					aSavePos	:=	{IndexOrd(), recno(), oScoreCard:cSqlFilter()}
		
					lRefCirc :=	::lCheckRefCircular(oScoreCard:cValue("ID"),cDestino)//Gera o registro para os filhos
					
					oScoreCard:faSavePos:= aSavePos	//RestPos
					oScoreCard:RestPos()
					
					if(lRefCirc)
						exit
					endif
					
					oScoreCard:_Next()
				enddo
			endif			
		endif
	else
		lRefCirc := .t.
	endif		
	
return lRefCirc

/*
*Monta o novo nome de indicadores utilizando o caracter diferenciador. 
*/
method cNovoNome(cNomeOriginal) class TKPIDuplicador
	local cNovoNome := ""

	if !Empty(::cNomeDif)
		if(::cNomePosDif == 1)
			cNovoNome := AllTrim(cNomeOriginal) + " " + ::cNomeDif
		else
			cNovoNome := ::cNomeDif + " " + AllTrim(cNomeOriginal)
		endif
	else 
		cNovoNome := cNomeOriginal
	endif

return cNovoNome       

/**
* Monta o novo código de importação utilizando o caracter diferenciador. 
*/
method cNovoCodigo(cCodigoOriginal) class TKPIDuplicador
	Local cCodigo := ""

	if !Empty(::cCodigoDif)
		if(::nCodigoPosDif == 1)
			cCodigo := AllTrim(cCodigoOriginal) + cBIStr( ::cCodigoDif )
		else
			cCodigo := cBIStr( ::cCodigoDif ) + AllTrim(cCodigoOriginal)
		endif
	else
		cCodigo := cCodigoOriginal
	endif

return cCodigo

function _kpi032_Duplicador()
return nil