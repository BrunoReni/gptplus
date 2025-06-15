// ######################################################################################
// Projeto: KPI
// Modulo : 
// Fonte  : KPI051_Plan.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.11.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI051_Plan.ch"

/*--------------------------------------------------------------------------------------
@class TKPI051
@entity RelPlano
Relatório Plano de Ação
@table KPI051
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELPLAN"
#define TAG_GROUP  "RELPLANS"
#define TEXT_ENTITY STR0001/*//"Relatório de Plano de Ação"*/
#define TEXT_GROUP  STR0002/*//"Relatórios de Planos de Açoes"*/

class TKPI051 from TBITable  
	method New() constructor
	method NewKPI051()
	method oArvore(nParentID)
	method oToXMLList(nParentID)
	method oXMLStatus()
	method oXMLSituacao()
	method oXMLTipoImprimir()
	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	method nExecute(cID, cExecCMD)
endclass

method New() class TKPI051
	::NewKPI051()
return  

method NewKPI051() class TKPI051
	// Table
	::NewTable("SGI051")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",			"C", 10))
	::addField(TBIField():New("PARENTID",	"C", 10))
	::addField(TBIField():New("NOME",		"C", 60))
	::addField(TBIField():New("DESCRICAO",	"C", 255))
	::addField(TBIField():New("IMPDESC",	"L")) // Imprime descrição
	::addField(TBIField():New("INICIODE",	"D"))
	::addField(TBIField():New("INICIOATE",	"D"))
	::addField(TBIField():New("TERMINODE",	"D"))
	::addField(TBIField():New("TERMINOATE",	"D"))
	::addField(TBIField():New("ID_RESP",	"C", 10))
	::addField(TBIField():New("TP_RESP",	"C", 10))
	::addField(TBIField():New("PROJ_DE",	"C", 10))
	::addField(TBIField():New("PROJ_ATE",	"C", 10)) 
	::addField(TBIField():New("SCORECARD",	"C", 10)) 	
	::addField(TBIField():New("INDIC_DE",	"C", 10))
	::addField(TBIField():New("INDIC_ATE",	"C", 10))
	::addField(TBIField():New("TIPOIMP",	"N")) //0=Projetos e Indicadores, 1=Indicadores, 2=Projetos
	::addField(TBIField():New("STATUS",		"C", 1))
	::addField(TBIField():New("SITUACAO",	"C", 1))  
	::addField(TBIField():New("CATEGORIA",	"N")) //[0 - Ambos 1-Corretiva 2-Preventiva]
	
	// Indexes
	::addIndex(TBIIndex():New("SGI051I01",	{"ID"},		.t.))	
return

method oArvore(nParentID) class TKPI051
	Local oXMLArvore
	Local oNode
	
	::SetOrder(1)
	::_First()  
	
	if(!::lEof())

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "1")
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("")
return oXMLArvore

method oToXMLList(nParentID) class TKPI051
	Local aFields
	Local oNode
	Local oAttrib
	Local oXMLNode
	Local nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	::SetOrder(2) // Por ordem de Nome
	::_First() 
	
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID","DESCRICAO","IMPDESC","INICIODE","INICIOATE",;
										"TERMINODE","TERMINOATE","PESID","PERSID","OBJID","INICID", "TIPOIMP","SITID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next  
		
		::_Next()
	end    
	
	::cSQLFilter("") 
return oXMLNode

method oToXMLNode() class TKPI051
	Local aFields	:= {}
	Local nInd		:= 0
	Local nStatus	:= KPI_ST_OK
	Local oXMLNode	:= TBIXMLNode():New(TAG_ENTITY) 
	Local cTpResp	:= ""
	Local xValue	:= nil
	local oUsrGrp	:= ::oOwner():oGetTool("USERGROUP")

	::SetOrder(1) // Por ordem de ID
	::_First()

	if(::lEof())

		if(!::lAppend({ {"ID", ::cMakeID()}}))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif

	if nStatus == KPI_ST_OK
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)

			xValue := aFields[nInd][2]

			if aFields[nInd][1] == "TP_RESP" 

				if empty(xValue)
					xValue := TIPO_USUARIO
				endIf

				cTpResp := xValue		

			endif	
			
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], xValue))
		next
	endif

	oXMLNode:oAddChild(TBIXMLNode():New("ISADMIN", ::oOwner():foSecurity:oLoggedUser():lValue("ADMIN")))

	oXMLNode:oAddChild(oUsrGrp:oTreeUsrGrp())		
	oXMLNode:oAddChild(oUsrGrp:oUsuGroup())
	oXMLNode:oAddChild(TBIXMLNode():New("TP_RESP_ID_RESP",	cTpResp + ::cValue("ID_RESP")))
	
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.t.))
	oXMLNode:oAddChild(::oOwner():oGetTable("PROJETO"):oToXMLList())

	oXMLNode:oAddChild(::oXMLStatus())
	oXMLNode:oAddChild(::oXMLSituacao())
	oXMLNode:oAddChild(::oXMLTipoImprimir())

return oXMLNode

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI051
	local nStatus := KPI_ST_OK
	Local nID
	Local nInd
	Local oTable
	Local cNome 
	
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			nID := aFields[nInd][2]
		endif
	next

	// Verifica condições de gravação (append ou update)
	::SetOrder(1) // Por ordem de ID
	::cSQLFilter("ID = '"+cBIStr(nID)+"'") // Filtra pelo pai
	::lFiltered(.t.)
	::_First() 
	
	if(::lEof())
		// Inseri registro
		if(!::lAppend({ {"ID", ::cMakeID()} }))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	else   
	
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif     
	
	::cSQLFilter("")
return nStatus

// Status / Situacao do Plano de Ação
method oXMLStatus() class TKPI051
	local oAttrib
	Local oNode
	Local oXMLOutput
	local nInd
	Local aStatus := { STR0007, STR0008, STR0009, STR0010, STR0011, STR0012 }
	//"Näo Iniciada" # "Em Execucäo" # "Realizada" # "Esperando" # "Adiada" # "Cancelada"
	
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("LSTSTATUS",,oAttrib)

	for nInd := 1 to len(aStatus)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("LSTSTATUS"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aStatus[nInd]))
	next
return oXMLOutput

// Situacao / Situacao do Plano de Ação (Vencidos e A vencer)
method oXMLSituacao() class TKPI051
	local oAttrib
	Local oNode
	Local oXMLOutput
	local nInd
	Local aSituacao
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO")
	local nPrazoVenc	:= 7 
	
	if(oParametro:lSeek(1, {"PRAZO_PARA_VENC"}))
		nPrazoVenc := oParametro:nValue("DADO")
	endif
	//"Vencidos" # "A Vencer"
	
	if(nPrazoVenc > 1)
		aSituacao := { STR0031, STR0032 + alltrim(str(nPrazoVenc)) + STR0034 }
	else
		aSituacao := { STR0031, STR0032 + alltrim(str(nPrazoVenc)) + STR0033 }
	endif
	
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("LSTSITUACAO",,oAttrib)

	for nInd := 1 to len(aSituacao)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("SITUACAO"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aSituacao[nInd]))
	next    
	
return oXMLOutput 

// Status / Situacao do Plano de Ação
method oXMLTipoImprimir() class TKPI051
	local oAttrib
	Local oNode
	Local oXMLOutput
	local nInd
	Local aTipo := { STR0040, STR0039, STR0018 }
	
	// Atributos
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("RETORNA", .f.)

	// Tag pai
	oXMLOutput := TBIXMLNode():New("TIPOIMPS",,oAttrib)

	for nInd := 1 to len(aTipo)
		oNode := oXMLOutput:oAddChild(TBIXMLNode():New("TIPOIMPS"))
		oNode:oAddChild(TBIXMLNode():New("ID", nInd))
		oNode:oAddChild(TBIXMLNode():New("NOME", aTipo[nInd]))
	next
return oXMLOutput

// Execute
method nExecute(cID, cExecCMD) class TKPI051
	local aParms := {} 
	local cPathSite	:= left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	private nStatus := KPI_ST_OK
	
	if(::lSeek(1, {cID})) // Posiciona no ID informado

		// 1 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))
		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))
		// 3 - Imprime Descrição?
		aAdd(aParms, ::lValue("IMPDESC"))
		// 4 - Inicio de
		aAdd(aParms, ::dValue("INICIODE"))
		// 5 - Inicio ate
		aAdd(aParms, ::dValue("INICIOATE"))
		// 6 - Termino de
		aAdd(aParms, ::dValue("TERMINODE"))
		// 7 - Termino ate
		aAdd(aParms, ::dValue("TERMINOATE"))
		// 8 - Id do Responsavel de
		aAdd(aParms, ::cValue("ID_RESP"))
		// 9 - Id do Responsavel ate
		aAdd(aParms, ::cValue("TP_RESP"))
		// 10 - Id do Responsavel de
		aAdd(aParms, ::cValue("PROJ_DE"))
		// 11 - Id do Responsavel ate
		aAdd(aParms, ::cValue("PROJ_ATE"))
		// 12 - Id do Scorecard
		aAdd(aParms, ::cValue("SCORECARD"))
		// 13 - Id do indicador de
		aAdd(aParms, ::cValue("INDIC_DE"))
		// 14 - Id do Indicador ate
		aAdd(aParms, ::cValue("INDIC_ATE"))
		// 15 - Tipo de impressao //0=Projetos e Indicadores, 1=Indicadores, 2=Projetos
		aAdd(aParms, ::cValue("TIPOIMP"))
		// 16 - ID do Status
		aAdd(aParms, ::cValue("STATUS"))
		// 17 - ID do Relatório
		aAdd(aParms, ::cValue("ID"))
		// 18 - KPIPATH da Working THREAD
		aAdd(aParms, ::oOwner():cKpiPath())
		// 19 - Nome do arquivo que sera salvo
		aAdd(aParms,cExecCMD )
		// 20 - Diretorio do site.
		aAdd(aParms, strtran(cPathSite,"\","/"))
		// 21 - ID da Situacao
		aAdd(aParms, ::cValue("SITUACAO"))    
		// 22 - Categoria [0 - Ambos 1-Corretiva 2-Preventiva]
		aAdd(aParms, ::cValue("CATEGORIA"))

		nStatus := KPIRelPlanJob(aParms)
		if(nStatus == KPI_ST_OK)
			::fcMsg := STR0029
		elseif(nStatus == KPI_ST_GENERALERROR)
			::fcMsg := STR0030
		endif
	
	else

		nStatus := 	KPI_ST_BADID

	endif

return nStatus

// Funcao executa o job
function KPIRelPlanJob(aParms)
	local cNome
	Local cDescricao
	Local lImpDesc
	Local cKpiPath
	Local cFiltro
	Local cStatus
	Local aObjPlans := {}
	Local dHoje := date()
	local i
	Local j
	Local oHtmFile
	local cCorAcao	 := ""
	local oParametro
	local nPrazoVenc := 7  
	local dInicioDe  
	local dInicioAte  
	local dTerminoDe
	local dTerminoAte  
	local cUserId
	local cUserTipo 
	local cProjDe 
	local cProjAte
	local cScorecard 
	local cIndDe 
	local cIndAte  
	local cTipoImp
	local cId     
	local cPathSite 
	local cIdSituacao
	local cCategoriaID
	local cReportname := ""
	local cProjetoDe	:= ""
	local cProjetoAte	:= ""
	local cIndicaDe	:= ""
	local cIndicaAte	:= ""
	local aExecCmd
	local lProject	:= .F.

	public oKPICore, cKPIErrorMsg := ""
	
	oParametro 	:= oKPICore:oGetTable("PARAMETRO") 
		
	if(oParametro:lSeek(1, {"PRAZO_PARA_VENC"}))
		nPrazoVenc := oParametro:nValue("DADO")
	endif
		
    // Coleta os parametros
	// 1 - Nome
	cNome		:= aParms[1]
	// 2 - Descrição
	cDescricao 	:= aParms[2]
	// 3 - Imprime Descrição?
	lImpDesc	:= aParms[3]
	// 4 - Inicio de
	dInicioDe	:= aParms[4]
	// 5 - Inicio ate
	dInicioAte	:= aParms[5]
	// 6 - Termino de
	dTerminoDe	:= aParms[6]
	// 7 - Termino ate
	dTerminoAte	:= aParms[7]
	// 8 - Usuario / Grupo
	cUserId		:= alltrim(aParms[8]) 
	// 9 - Tipo (Usuário ou Grupo)
	cUserTipo	:= alltrim(aParms[9])
	// 10 - Id do projeto de
	cProjDe		:= alltrim(aParms[10])
	// 11 - Id do Projeto ate
	cProjAte	:= alltrim(aParms[11])
	// 12 - Id do scorecard para filtro dos indicadores
	cScorecard	:= alltrim(aParms[12])
	// 13 - Id do indicador de
	cIndDe		:= alltrim(aParms[13])
	// 14 - Id do Indicador ate
	cIndAte		:= alltrim(aParms[14])
	// 15 - Tipo de impressao //0=Projetos e Indicadores, 1=Indicadores, 2=Projetos
	cTipoImp	:= alltrim(aParms[15])
	// 16 - ID da situacao
	cStatus		:= alltrim(aParms[16])
	// 17 - ID do Relatório
	cId			:= alltrim(aParms[17])
	// 18 - KPIPATH da Working THREAD
	cKpiPath	:= aParms[18]
	// 19 - Nome do arquivo que sera salvo
	cPathSite 	:= aParms[20]
	// 20 - ID da Situacao
	cIdSituacao := alltrim(aParms[21])  
	// 21 - ID da Categoria
	cCategoriaID := alltrim(aParms[22])  
	
	cReportname := ""
	cProjetoDe	:= ""
	cProjetoAte	:= ""
	cIndicaDe	:= ""
	cIndicaAte	:= ""
	
	aExecCmd := aBIToken(aParms[19], ",") 
	
	if(!empty(alltrim(aExecCmd[1])))
		cReportName := alltrim(aExecCmd[1])
    endif    

   
    if(!empty(allTrim(aExecCmd[2])))
		cProjetoDe := alltrim(aExecCmd[2])
    endif       
    
    if(!empty(allTrim(aExecCmd[3])))
		cProjetoAte:= alltrim(aExecCmd[3])
    endif     

    if(!empty(allTrim(aExecCmd[4])))
		cIndicaDe := alltrim(aExecCmd[4])
    endif     
    
    if(!empty(allTrim(aExecCmd[5])))
		cIndicaAte:= alltrim(aExecCmd[5])
    endif     

    
    // 20 - Diretório do site
    cSitePath	:= aParms[20]
	
	oHtmFile := TBIFileIO():New(oKPICore:cKpiPath()+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL051_" + alltrim(cID) + ".html")
	
	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		oKPICore:Log(STR0004 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL051_"*/
		oKPICore:Log(STR0005, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		return KPI_ST_GENERALERROR
	endif
	
	oProjeto := oKPICore:oGetTable("PROJETO") 
	oIndicador := oKPICore:oGetTable("INDICADOR")
	
	cFiltro := ""
	cStatusDesc := ""

	//Filtro por Período de Início. 
	if(!empty(dInicioDe) .and. !empty(dInicioAte))
		cFiltro := " and DATAINICIO >='"+dtos(dInicioDe)+"' and DATAINICIO <='"+dtos(dInicioAte)+"'"
	endif     
	     
	//Filtro por Período de Conclusão. 
	if(!empty(dTerminoDe) .and. !empty(dTerminoAte))
		cFiltro += " and DATAFIM >='"+dtos(dTerminoDe)+"' and DATAFIM <='"+dtos(dTerminoAte)+"'"
	endif     
	 
	//Filtro por Status.
	if(!empty(cStatus) .and. !cStatus=="0")
		cFiltro += " and STATUS='"+ cStatus+"'"
	endif
	  
	//Filtro por situação. 
	if(cIdSituacao == "1")
		cFiltro += " and DATAFIM <'"+ dtos(dHoje)+"' and DATATERM = '        '"
	elseif(cIdSituacao == "2")
		cFiltro += " and DATAFIM >='"+ dtos(dHoje)+"' and DATAFIM <='"+ dtos(dHoje+nPrazoVenc)+"'"
	endif
	  
	//Filtro por Categoria [Todos]. 	 	      
	If(cCategoriaID == "0")
		cFiltro += " AND (CATEGORIA = '0' Or CATEGORIA = '1')"	
	//Filtro por Categoria [Corretivo].
	ElseIf(cCategoriaID == "1")
		cFiltro += " AND CATEGORIA ='0'" 
	Else  
		//Filtro por Categoria [Preventivo].
		cFiltro += " AND CATEGORIA ='1'" 
	endif	
		
	if(cTipoImp=="1")//so indicador
		
		if(!empty(cScorecard) .and. !(alltrim(cScorecard)=="0")) //filtrando o Scorecard, pai do Indicador, se vier do Java
			oIndicador:setOrder(5)

			if(!empty(cIndicaDe) .and. !empty(cIndicaAte))
				oIndicador:cSQLFilter("NOME >= '"+cIndicaDe+"' and NOME <='"+cIndicaAte+"' and ID_SCOREC ='"+cScorecard+"'")
			elseif(!empty(cIndicaDe) .and. empty(cIndicaAte))
				oIndicador:cSQLFilter("NOME >='"+cIndicaDe+"' and ID_SCOREC ='"+cScorecard+"'")
			elseif(empty(cIndicaDe) .and. !empty(cIndicaAte))
				oIndicador:cSQLFilter("NOME <='"+cIndicaAte+"' and ID_SCOREC ='"+cScorecard+"'")
			else
				oIndicador:cSQLFilter("ID_SCOREC ='"+cScorecard+"'")
			endif
			
			oIndicador:lFiltered(.t.)
			oIndicador:_first()
		endif
		
		aTempPlan := aPopuPlano(cTipoImp, oIndicador, oProjeto, oKPICore, cFiltro, cUserId, cUserTipo)
		
		if(len(aTempPlan)!=0)
			aadd(aObjPlans, aTempPlan)
		endif
		oIndicador:cSQLFilter("")  
				
	elseif(cTipoImp=="2")//so projetos
		
		oProjeto:setOrder(2)
		oProjeto:_First()  
		
		if(!empty(cProjetoDe) .and. !empty(cProjetoAte))
			oProjeto:cSQLFilter("NOME>='"+cProjetoDe+"' and NOME<='"+cProjetoAte+"'")
		elseif(!empty(cProjetoDe) .and. empty(cProjetoAte))
			oProjeto:cSQLFilter("NOME>='"+cProjetoDe+"'")
		elseif(empty(cProjetoDe) .and. !empty(cProjetoAte))
			oProjeto:cSQLFilter("NOME<='"+cProjetoAte+"'")
		endif 
		
		oProjeto:lFiltered(.t.)
		oProjeto:_First()
		aTempPlan := aPopuPlano(cTipoImp, oIndicador, oProjeto, oKPICore, cFiltro, cUserId, cUserTipo)
		
		if(len(aTempPlan)!=0)
			aadd(aObjPlans, aTempPlan)
		endif    
		
		oProjeto:cSQLFilter("")
	
	elseif(cTipoImp=="3")
		
		if(!empty(cScorecard) .and. !cScorecard == "0") //filtrando o Scorecard, pai do Indicador, se vier do Java
			oIndicador:setOrder(2)
			oIndicador:_First() 
			
			if(!empty(cIndicaDe) .and. !empty(cIndicaAte))
				oIndicador:cSQLFilter("NOME >='"+cIndicaDe+"' and NOME <='"+cIndicaAte+"' and ID_SCOREC ='"+cScorecard+"'")
			elseif(!empty(cIndicaDe) .and. empty(cIndicaAte))
				oIndicador:cSQLFilter("NOME >='"+cIndicaDe+"' and ID_SCOREC ='"+cScorecard+"'")
			elseif(empty(cIndicaDe) .and. !empty(cIndicaAte))
				oIndicador:cSQLFilter("NOME <='"+cIndicaAte+"' and ID_SCOREC ='"+cScorecard+"'")
			else
				oIndicador:cSQLFilter("ID_SCOREC ='"+cScorecard+"'")
			endif
			
			oIndicador:lFiltered(.t.)
			oIndicador:_First()
		endif    
		                                                                                       
		aTempInd := aPopuPlano("1", oIndicador, oProjeto, oKPICore, cFiltro, cUserId, cUserTipo)
		
		if(len(aTempInd)!=0)
			aadd(aObjPlans, aTempInd)
		endif
		
	    oProjeto:setOrder(2)
		oProjeto:_First()    
		
		if(!empty(cProjetoDe) .and. !empty(cProjetoAte))
			oProjeto:cSQLFilter("NOME>='"+cProjetoDe+"' and NOME<='"+cProjetoAte+"'")
		elseif(!empty(cProjetoDe) .and. empty(cProjetoAte))
			oProjeto:cSQLFilter("NOME>='"+cProjetoDe+"'")
		elseif(empty(cProjetoDe) .and. !empty(cProjetoAte))
			oProjeto:cSQLFilter("NOME<='"+cProjetoAte+"'")
		endif      
		
		oProjeto:lFiltered(.t.)
		oProjeto:_First()
		aTempPrj := aPopuPlano("2", oIndicador, oProjeto, oKPICore, cFiltro, cUserId, cUserTipo)
		
		if(len(aTempPrj)!=0)
			aadd(aObjPlans, aTempPrj)
		endif 
		
		oIndicador:cSQLFilter("")
		oProjeto:cSQLFilter("")
	endif

	// Montagem do cabeçalho do relatório
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>')
	oHtmFile:nWriteLN('<title>'+KPIEncode(STR0019)+'</title>')
	oHtmFile:nWriteLN('<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
   	oHtmFile:nWriteLN('<link href="'+cPathSite+'imagens/report_estilo2.css" rel="stylesheet" type="text/css">')
	oHtmFile:nWriteLN('</head>')

	oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	if(len(aObjPlans)!=0) 
		oHtmFile:nWriteLN('	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela"')
  		oHtmFile:nWriteLN('<tr>')
   		oHtmFile:nWriteLN('<td class="tdlogo"><img class="imglogo" src="'+cSitePath+'/imagens/art_logo_clie.sgi"></td>')
   		oHtmFile:nWriteLN('<td class="titulo"><div align="center">' + KPIEncode(STR0017) + '</div></td>')
   		oHtmFile:nWriteLN('<td width="150" class="texto"><div align="right">'+KPIEncode(STR0020)+ dtoc(date()) + '</div></td>')
  		oHtmFile:nWriteLN('</tr>')
		oHtmFile:nWriteLN('</table>')
		oHtmFile:nWriteLN('<br>')

		cTipoAnte := ""
		cScorAnte := ""
		cPlanAnte := ""
		cStoreUlt := ""   
		
		for	i=1 to len(aObjPlans)
			for j=1 to len(aObjPlans[i])
				cTipoAtual := alltrim(aObjPlans[i][j][10])
				oHtmFile:nWriteLN('<table width="100%" bgcolor="#C6E2FF" border="0" cellpadding="0" cellspacing="0" >')
				oHtmFile:nWriteLN('<tr>')

				if(cTipoAtual == "1")				
					oHtmFile:nWriteLN('<td class="cabecalho_1_branco">')     
				else
					oHtmFile:nWriteLN('<td class="cabecalho_4">')     
				endif
				
				//Cabecalho
				oHtmFile:nWriteLN('<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">')
				if !( alltrim(aObjPlans[i][j][1]) == cTipoAnte )
					if(cTipoAnte != "") .and. (cTipoAtual == cStoreUlt)
						oHtmFile:nWriteLN('<br>')
					endif
					lProject := len(alltrim(aObjPlans[i][j][15])) > 0
					if  lProject 
					    oHtmFile:nWriteLN('<tr>')
				    	oHtmFile:nWriteLN('<td colspan="9">')
						oHtmFile:nWriteLN('<table width="80%" cellpadding="0" cellspacing="0" border="0">')
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td class="texto1" width="50%" colspan="4">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][1]))  //Projeto
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('<td class="texto1" colspan="4">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][12])) //% De ações finalizadas:    
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')					
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td class="texto1" width="50%" colspan="4">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][2])) //ScoreName
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('<td class="texto1" colspan="4">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][13])) //% De ações atrasadas:
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')					
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td class="texto1" width="50%" colspan="4">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][14])) //Responsável
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('<td class="texto1" colspan="4">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][15])) //Tipo
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')  
									
						if (len(alltrim(aObjPlans[i][j][16])) > 25)			
							oHtmFile:nWriteLN('<tr>')
							oHtmFile:nWriteLN('<td class="texto1" width="50%" colspan="8" >')
							oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][16])) //Código
							oHtmFile:nWriteLN('</td>')
							oHtmFile:nWriteLN('</tr>')
						endif
								
						oHtmFile:nWriteLN('</table>')	
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')
					else
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td width="50" class="texto1">')
   						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][22]))
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('<td class="texto1" colspan="8">')
   						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][23]))
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')
						oHtmFile:nWriteLN('<tr>')
						oHtmFile:nWriteLN('<td width="50" class="texto1">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][24]))
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('<td class="texto1" colspan="8">')
						oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][25]))
						oHtmFile:nWriteLN('</td>')
						oHtmFile:nWriteLN('</tr>')
					endif
                    
					cTipoAnte := alltrim(aObjPlans[i][j][1])
					cScorAnte := alltrim(aObjPlans[i][j][2])

				endif                  					
				
				If lProject
					oHtmFile:nWriteLN('<tr>')
					oHtmFile:nWriteLN('	<td width="50" align="left" class="texto" colspan="8">')
					oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][26]))
					oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][27]))
					oHtmFile:nWriteLN('</td>')
					oHtmFile:nWriteLN('	</tr>')
					oHtmFile:nWriteLN('	</table>')
					
					oHtmFile:nWriteLN('</tr>')
					oHtmFile:nWriteLN('	</td>')
					oHtmFile:nWriteLN('<tr>')
					oHtmFile:nWriteLN('<td class="cabecalho_4">')					
				Else
					oHtmFile:nWriteLN('<tr>')
					oHtmFile:nWriteLN('	<td width="50" align="left" class="texto">')
					oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][26]))
					oHtmFile:nWriteLN('</td>')
					oHtmFile:nWriteLN('	<td align="left" class="texto" colspan="8">')
					oHtmFile:nWriteLN(alltrim(aObjPlans[i][j][27]))
					oHtmFile:nWriteLN('</td>')
					oHtmFile:nWriteLN('	</tr>')
					oHtmFile:nWriteLN('	</table>')
				EndIf

				oHtmFile:nWriteLN('<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
			   
				oHtmFile:nWriteLN('<tr class="cabecalho_2">')						
				//Tipo.
				oHtmFile:nWriteLN('<td width="50" align="center">'+KPIEncode(STR0042)+'</td>')
				//Descrição.
				oHtmFile:nWriteLN('<td width="210" align="center">'+KPIEncode(STR0045)+'</td>')
				//Objetivo.
				oHtmFile:nWriteLN('<td width="210" align="center">'+KPIEncode(STR0046)+'</td>')
				//Período. DE 
				oHtmFile:nWriteLN('<td width="80" align="center">'+KPIEncode(STR0023)+' De</td>')
				//Período. ATE
				oHtmFile:nWriteLN('<td width="80" align="center">'+KPIEncode(STR0023)+' Até</td>')
				//Responsável
				oHtmFile:nWriteLN('	<td width="100" align="center">'+KPIEncode("Responsável")+'</td>')
				//Data Término.
				oHtmFile:nWriteLN('	<td width="100" align="center">'+KPIEncode("Data Término")+'</td>')
				//Status.
				oHtmFile:nWriteLN('	<td width="70" align="center">'+KPIEncode(STR0025)+'</td>')
				//Observação do Status.
				oHtmFile:nWriteLN('<td width="210" align="center">'+KPIEncode(STR0026)+'</td>')     
				oHtmFile:nWriteLN('	</tr> ')

				cCorAcao := aObjPlans[i][j][11]

				oHtmFile:nWriteLN('	<tr>')
		 		//Tipo.
		   		oHtmFile:nWriteLN('<td width="50" valign="top" class="texto2">'+alltrim(aObjPlans[i][j][17])+'</td>')
			   	//Descrição.
				oHtmFile:nWriteLN('<td width="210" valign="top" class="texto2">'+alltrim(aObjPlans[i][j][4]) + '</td>')
				//Objetivo.
				oHtmFile:nWriteLN('<td width="210" valign="top" class="texto2">'+ alltrim(aObjPlans[i][j][5])+ '</td>')
				//Período DE
				oHtmFile:nWriteLN('<td width="80" valign="top" class="texto2">'+ alltrim(aObjPlans[i][j][18])+ '</td>')
				//Período ATE
				oHtmFile:nWriteLN('<td width="80" valign="top" class="texto2">'+ alltrim(aObjPlans[i][j][19])+ '</td>')
				//Responsável.
				oHtmFile:nWriteLN('<td width="100" valign="top" class="texto2">'+alltrim(aObjPlans[i][j][20]) + '</td>')
				//Data Término.
				oHtmFile:nWriteLN('<td width="100" valign="top" class="texto2">'+alltrim(aObjPlans[i][j][21]) + '</td>')
				//Status.
				oHtmFile:nWriteLN('<td width="70" valign="top" class="'+cCorAcao+'">'+alltrim(aObjPlans[i][j][8])+'</td>')
				//Observação do Status.
				oHtmFile:nWriteLN('<td width="210" valign="top" class="texto2">' + alltrim(aObjPlans[i][j][9])+'</td>')
				oHtmFile:nWriteLN('</tr>')    
				
				oHtmFile:nWriteLN('</table>')
				oHtmFile:nWriteLN('</td>')
				oHtmFile:nWriteLN('</tr>')
				oHtmFile:nWriteLN('</table>')
				cStoreUlt := cTipoAtual
			next j
			oHtmFile:nWriteLN('<br>')
			oHtmFile:nWriteLN('<br>')
		
		next i
	else
		// Montagem do rodap&eacute; do relat&oacute;rio 
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(	KPIEncode(STR0027))
		oHtmFile:nWriteLN('	</font>')
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		KPIEncode(STR0028))
		oHtmFile:nWriteLN('	</font>')
	endif
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')
                                                             
	//Faz a copia do relatorio para o diretorio de Spool
	oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + cReportName, oKPICore:cKpiPath())
	oHtmFile:lClose()
	oKPICore:Log(STR0006+cNome+"]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
return nStatus

function aPopuPlano(cTipoImp, oIndicador, oProjeto, oKPICore, cFiltro, cUserId, cUserTipo) 
	
	local aField := {}
	local aFields :={}
	local cNomeResp := ""
	local cStatusDesc
	local cTipoPlan := ""
	local oTipo
	local cCampo
	local cStatusPla := ""     
	local cIdProj
	local cRespPrj
	local nFinVenc
	local nAtraVenc
	local nTotalAcoes
	local nFinTot
	local cPercFin
	local cPercAtra
	local cDescCod
	local cHierarq
	local oScorecard	:= oKPICore:oGetTable("SCORECARD")                
	local oPlano		:= oKPICore:oGetTable("PLANOACAO")
	local oUsuario		:= oKPICore:oGetTable("USUARIO")    
	local oParametro	:= oKPICore:oGetTable("PARAMETRO") 	                
	local oGrupo		:= oKPICore:oGetTable("GRUPO")    
	local oUserGrp		:= oKPICore:oGetTool("USERGROUP")
	local cTpresp  
	local lAddPlano		:= .F.
	local cNomeTemp	:= ""
	local cDataFim	:= ""
	local cTitulo		:= ""
	local cValTit		:= ""
	local cBreadCrumb	:= ""
	local cAcao		:= ""
	local cValAcao	:= ""

	//faz o filtro do tipo de ação / 1- Indicador / 2- Projeto
	if(cTipoImp == "1")	
		if(len(allTrim(cFiltro)) == 0)
			oPlano:cSQLFilter("TIPOACAO = '1'")
		else                                                               
			oPlano:cSQLFilter("TIPOACAO = '1'" + cFiltro )
		endif
		oPlano:setOrder(2)
	elseif(cTipoImp == "2")
		if(len(allTrim(cFiltro)) == 0)
			oPlano:cSQLFilter("TIPOACAO = '2'")
		else
			oPlano:cSQLFilter("TIPOACAO = '2'" + cFiltro)
		endif
		oPlano:setOrder(3) 
	endif
	
	oPlano:lFiltered(.t.)
	oPlano:_First()
	
	// filtrando os usuarios responsaveis
	if(cTipoImp == "1")
		oTipo	:= oIndicador
		cCampo	:= "ID_IND"
	else
		oTipo	:= oProjeto
		cCampo	:= "ID_PROJ"
	endif

	while !oPlano:lEof()
		lAddPlano := .T.

		aField := {}

		if( oTipo:lSeek( 1 , { oPlano:cValue(cCampo)}) )

			cNomeResp := ""

			if !empty(oPlano:cValue("ID_RESP"))

				//Filtro por usuário ou grupo
				if !Empty(cUserId) .and. !Empty(cUserTipo)
					lAddPlano := .F.

					//normalização do campo TP_RESP
					cTpResp := oPlano:cValue("TP_RESP")
					if empty(cTpResp)
						cTpResp := TIPO_USUARIO
					endif

					if cTpResp == cUserTipo
						//Filtro e plano no mesmo nível de comparação (grupo com grupo, usuário com usuário)
						lAddPlano := ( alltrim(oPlano:cValue("ID_RESP")) == cUserId )
					else
						//Filtro e plano em níveis diferentes de comparação (grupo com usuário, usuário com grupo)
						if cUserTipo == TIPO_USUARIO
							lAddPlano := oUserGrp:lUserInGrp(cUserId, oPlano:cValue("ID_RESP"))
						endif
					endif
				endif

				if lAddPlano
					if oPlano:cValue("TP_RESP") == TIPO_GRUPO
						if oGrupo:lSeek(1,{oPlano:cValue("ID_RESP")})
							cNomeResp := allTrim(oGrupo:cValue("NOME"))
						endif
					else
						if oUsuario:lSeek(1, {oPlano:cValue("ID_RESP")})
							cNomeResp := allTrim(oUsuario:cValue("COMPNOME"))
						endif
					endif
				endif
			endif
            
			lAddPlano := lAddPlano .and. !empty(cNomeResp)
			cNomeTemp := cNomeResp

			cStatusPla 	:= ""
			cStatusDesc	:= ""  

			if lAddPlano
				cNomeResp += ", <br>" + dtoc(oPlano:dValue("DATATERM"))
				cDataFim := dtoc(oPlano:dValue("DATATERM"))
				cStatusPla := oPlano:cValue("STATUS")       
				if(cStatusPla == "1")
					cStatusDesc := STR0007
				elseif(cStatusPla == "2")
					cStatusDesc := STR0008
				elseif(cStatusPla == "3")
					cStatusDesc := STR0009
				elseif(cStatusPla == "4")
					cStatusDesc := STR0010
				elseif(cStatusPla == "5")
					cStatusDesc := STR0011
				elseif(cStatusPla == "6")
					cStatusDesc := STR0012
				endif   

				//Indicador.
				If(oPlano:cValue("TIPOACAO") == '1' ) 
					
					//PEGA A HIERARQUIA A SER EXIBIDA - CASO SEJA VAZIA, FICA A PADRAO
					cHierarq := oScorecard:cGetScoreName(oTipo:cValue("ID_SCOREC"))
	
					aadd(aField, ( "<strong>" + STR0014 + "</strong> " + oTipo:cValue("NOME") ))	//[1]Projeto:
					
					cTitulo := "<strong>" + STR0014 + "</strong> "
					cValTit := oTipo:cValue("NOME")
					
					If oParametro:getValue("MODO_ANALISE") == ANALISE_BSC           
						aadd(aField, ( "<strong>" + cHierarq + "</strong> " ))						//[2]ScoreName
						cBreadCrumb := "<strong>" + cHierarq + "</strong> "
                	Else
						aadd(aField, ( "<strong>" + STR0013 + "</strong> " + cHierarq ))			//[2]ScoreName
						cBreadCrumb := "<strong>" + STR0013 + "</strong> " + cHierarq                 
                	EndIf
					
					aadd(aField, ( "<strong>" + STR0016 + "</strong> " + oPlano:cValue("NOME") ))	//[3]Plano de Ação:
					cTipoPlan := "1"
					cAcao	:= "<strong>" + STR0016 + "</strong> "
					cValAcao :=  oPlano:cValue("NOME")
			   	
			   	//Projeto. 
				Else 				
					cIdProj := oPlano:cValue("ID_PROJ")
					oTipo:lSeek(1,{cIdProj} )
				   
					//PEGA A HIERARQUIA A SER EXIBIDA - CASO SEJA VAZIA, FICA A PADRAO
					cHierarq := oScorecard:cGetScoreName(oTipo:cValue("ID_SCORE"))
					
					aadd(aField, ( "<b>" + STR0015 + "</b> " + oTipo:cValue("NOME") ))      //[1]Projeto:
					
					cTitulo := "<b>" + STR0015 + "</b> "
					cValTit := oTipo:cValue("NOME")

					If oParametro:getValue("MODO_ANALISE") == ANALISE_BSC           
						aadd(aField, ( "<b>" + cHierarq + "</b> " ))			  			//[2]ScoreName
						cBreadCrumb := "<b>" + cHierarq + "</b> " 
					Else
						aadd(aField, ( "<b>" + STR0013 + "</b> " + cHierarq ))  			//[2]ScoreName
						cBreadCrumb := "<b>" + STR0013 + "</b> " + cHierarq			
					EndIf                           
					
					aadd(aField, ( "<b>" + STR0016 + "</b> " + oPlano:cValue("NOME") ))     //[3]Plano de Ação:
					
					cAcao	:= "<b>" + STR0016 + "</b> "
					cValAcao :=  oPlano:cValue("NOME")
					
				 	cDescPrj := oTipo:cValue("DESCTIPO")
				 	cRespPrj := ""  
				 	
					if(oUsuario:lSeek(1, {oTipo:cValue("ID_RESP")}))
						cRespPrj := allTrim(oUsuario:cValue("COMPNOME"))
					endif   
					
					nVencidas 	:= oTipo:nCalculaVencido( alltrim(cIdProj) )
					nFinVenc	:= oTipo:nPercFinVenc( alltrim(cIdProj) )
					nAtraVenc	:= nVencidas - nFinVenc
					nTotalAcoes	:= oTipo:nTotalAcoes( alltrim(cIdProj) )
					nFinTot		:= oTipo:nTotalFin( alltrim(cIdProj) )  
			        cPercFin  	:= transform(oTipo:nCalcPorcentagem(nTotalAcoes, nFinTot),"@E 999.9") + " %"
					cPercAtra 	:= transform(oTipo:nCalcPorcentagem(nVencidas, nAtraVenc),"@E 999.9") + " %"
					cDescCod    := oTipo:cValue("DESCCOD")
				endif
				
				aadd(aField, oPlano:cValue("DESCRICAO"))
				aadd(aField, oPlano:cValue("OBJETIVO"))
				aadd(aField, oPlano:cValue("DATAINICIO")+"-"+oPlano:cValue("DATAFIM"))
				aadd(aField, cNomeResp)
				aadd(aField, cStatusDesc)
				aadd(aField, oPlano:cValue("OBSERVACAO") )
				aadd(aField, cTipoPlan)
				aadd(aField, oPlano:cGetClassStatus(cStatusPla,oPlano:dValue("DATAFIM")) )
				
				//Indicador.
				if(oPlano:cValue("TIPOACAO")=='1') 
					aadd(aField, "")
					aadd(aField, "")
					aadd(aField, "")
					aadd(aField, "")
					aadd(aField, "")  
				//Scorecard.
                else
					aadd(aField, "<strong>" + STR0035 + "</strong>" + cPercFin)      	//[12] %Ações finalizadas:    
					aadd(aField, "<strong>" + STR0036 + "</strong>" + cPercAtra) 		//[13] %Ações atrasadas:
					aadd(aField, "<strong>" + STR0037 + "</strong>" + alltrim(cRespPrj))//[14]  Responsável:
		  			aadd(aField, "<strong>" + STR0038 + "</strong>" + alltrim(cDescPrj))//[15]  Tipo:
		  			aadd(aField, "<strong>" + STR0041 + "</strong>" + alltrim(cDescCod))//[16]  Código: (Descricao)
                endif 
                
                //Tipo da Ação [0 - Corretiva 1 - Preventiva] 
                If (oPlano:nValue("CATEGORIA") == 1)     
                	aadd(aField, STR0043 /*"Preventiva"*/)
                Else
                	aadd(aField, STR0044 /*"Corretiva"*/)
                EndIf

                Aadd(aField, oPlano:cValue("DATAINICIO")) // [18] - Período início.
                Aadd(aField, oPlano:cValue("DATAFIM")) // [19] - Período Final.
                Aadd(aField, cNomeTemp) // [20] - Nome Responsável.
                Aadd(aField, cDataFim) // [21] - Data final do plano de ação.
                Aadd(aField, cTitulo) // [22] - Indicador: ou projeto.
                Aadd(aField, cValTit) // [23] - valor indicador
                Aadd(aField, "<b>Caminho</b>") // [24] - caminho
                Aadd(aField, cBreadCrumb) // [25] - valor caminho
                Aadd(aField, cAcao) // [26] - Ação.
                Aadd(aField, cValAcao) // [27] - Valor ação.
			endif
		endif
		
		oPlano:_next()
		if(len(aField) != 0)
			aadd(aFields, aField)
		endif
	end
	
	oPlano:cSQLFilter("")
return aFields
                                      


