// ######################################################################################
// Projeto: KPI
// Modulo : Apresentações / Relatório
// Fonte  : KPI052_Apres.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 29.12.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI052_Apres.ch"

/*--------------------------------------------------------------------------------------
@class TKPI052
@entity Apresentação
Relatório Apresentações de indicadores
@table KPI052
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELAPR"
#define TAG_GROUP  "RELAPRS"
#define TEXT_ENTITY STR0001/*//"Relatório de Apresentação"*/
#define TEXT_GROUP  STR0002/*//"Relatórios de Apresentações"*/

//aValores
#define VAL_REAL			1
#define VAL_META			2
#define VAL_REAL_ACU		3
#define VAL_META_ACU		4
#define VAL_REAL_STATUS		5
#define VAL_ACUM_STATUS		6
#define VAL_PREVIA			7

class TKPI052 from TBITable
	method New() constructor
	method NewKPI052()

	// diversos registros
	method oArvore(cParentID)
	method oToXMLRecList()
	method oToXMLList(cParentID)
	method KPIRelAprJob(aParms)

	// registro atual
	method oToXMLNode(cParentID)
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)
	
	// executar 
	method nExecute(cID, cExecCMD)
	
	method hasUserPermission()
	method nFormatVlr(nVlr, nCasaDec)
endclass

method New() class TKPI052
	::NewKPI052()
return
method NewKPI052() class TKPI052

	// Table
	::NewTable("SGI052")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C", 010))
	::addField(TBIField():New("NOME"		,"C", 060))
	::addField(TBIField():New("DESCRICAO"	,"C", 255))
	::addField(TBIField():New("USERID"		,"C", 010))
	::addField(TBIField():New("DATADE"		,"D"))
	::addField(TBIField():New("DATAATE"		,"D"))
	::addField(TBIField():New("DATAALVO"	,"D"))
	::addField(TBIField():New("TOPICOS"		,"M"))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI052I01",	{"ID"},		.t.))

return

// Arvore
method oArvore(cParentID) class TKPI052
	local oXMLArvore, oNode

	::SetOrder(1) // Por ordem de ID
	::_First()
	if(!::lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "1")
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLRecList() class TKPI052
	local oXMLNodeLista, oAttrib, oXMLNode, nInd

	oXMLNodeLista := TBIXMLNode():New("LISTA")
	
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o no de detalhes
	::SetOrder(1)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			if(::hasUserPermission())
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
				for nInd := 1 to len(aFields)
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				next
			endif
		endif			
		::_Next()		
	end

	oXMLNodeLista:oAddChild(oXMLNode)

return oXMLNodeLista

// Lista XML para anexar ao pai
method oToXMLList(cParentID) class TKPI052
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

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(2) // Por ordem de Nome
	::_First()
	while(!::lEof())
		if(! alltrim(::cValue("ID")=="0") )
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO","USERID","DATADE","DATAATE","DATAALVO"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode(cId) class TKPI052
	Local aFields
	Local nInd
	Local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	Local lShowVar		:= .f.
	Local nVarDecimnal	:= 2
	Local oParametro	:= ::oOwner():oGetTable("PARAMETRO")   
	Local aSelNode		:= {}                 

    //Exibir variação em percentual	
	if(oParametro:lSeek(1, {"SHOWVARCOL"}))
		lShowVar := oParametro:lValue("DADO")
	endif  
	oXMLNode:oAddChild(TBIXMLNode():New("SHOWVARCOL", lShowVar))
	
	//Casas decimais da variação em percentual                                     
	if(oParametro:lSeek(1, {"DECIMALVAR"}))
		nVarDecimnal := oParametro:nValue("DADO")
	endif
	oXMLNode:oAddChild(TBIXMLNode():New("DECIMALVAR", nVarDecimnal))

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
	next

	// Acrescenta children
	//TIPOACAO: 1-Indicador, 2-Projeto
	oXMLNode:oAddChild(::oOwner():oGetTable("PROJETO"):oToXMLList())
//	oXMLNode:oAddChild(::oOwner():oGetTable("APRXSCOR"):oToXMLList(cId))
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORXPRJ"):oToXMLList(cId))
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORXIND"):oToXMLList(cId))
	oXMLNode:oAddChild(::oOwner():oGetTable("INDXPLAN"):oToXMLList(cId))   
	
	aSelNode := ::oOwner():oGetTable("APRXSCOR"):aNodeSelect(cId)
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oArvore(.T.,"0",.T.,aSelNode))


return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI052
	local aFields, nInd, nStatus := KPI_ST_OK, aIndTend, nQtdReg, cId
	local oAprxScor := ::oOwner():oGetTable("APRXSCOR")
	local oScorxInd := ::oOwner():oGetTable("SCORXIND")
	local oScorxPrj := ::oOwner():oGetTable("SCORXPRJ")
	local oIndxPlan := ::oOwner():oGetTable("INDXPLAN")	
	local oUser 	:= oKpiCore:foSecurity:oLoggedUser()
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID","USERID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	cId := ::cMakeID()
	aAdd(aFields, {"ID", cId})
	aAdd(aFields, {"USERID",alltrim(oUser:cValue("ID"))})

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	else
		//Gravando os scorecards
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD"))!="U")
			aRegNode := &("oXMLInput:"+cPath+":_SCORECARDS")//Pegando os valores da scorecards
			if(valtype(aRegNode:_SCORECARD)=="A")
				for nQtdReg := 1 to len(aRegNode:_SCORECARD)
					nStatus	:= oAprxScor:nInsFromXML(cID, aRegNode:_SCORECARD[nQtdReg])
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next nQtdReg
			elseif(valtype(aRegNode:_SCORECARD)=="O")
				nStatus	:= oAprxScor:nInsFromXML(cId, aRegNode:_SCORECARD)
			endif
		endif

		//Gravando os indicadores
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORXINDS"), "_SCORXIND"))!="U")
			aRegNode := &("oXMLInput:"+cPath+":_SCORXINDS")
			if(valtype(aRegNode:_SCORXIND)=="A")
				for nQtdReg := 1 to len(aRegNode:_SCORXIND)
					nStatus	:= oScorxInd:nInsFromXML(cID, aRegNode:_SCORXIND[nQtdReg])
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next nQtdReg
			elseif(valtype(aRegNode:_SCORXIND)=="O")
				nStatus	:= oScorxInd:nInsFromXML(cId, aRegNode:_SCORXIND)
			endif
		endif

		//Gravando os projetos	
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORXPRJS"), "_SCORXPRJ"))!="U")
			aRegNode := &("oXMLInput:"+cPath+":_SCORXPRJS")
			if(valtype(aRegNode:_SCORXPRJ)=="A")
				for nQtdReg := 1 to len(aRegNode:_SCORXPRJ)
					nStatus	:= oScorxPrj:nInsFromXML(cID, aRegNode:_SCORXPRJ[nQtdReg])
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next nQtdReg
			elseif(valtype(aRegNode:_SCORXPRJ)=="O")
				nStatus	:= oScorxPrj:nInsFromXML(cId, aRegNode:_SCORXPRJ)
			endif
		endif

		//Gravando os plano de acoes	
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_INDXPLANS"), "_INDXPLAN"))!="U")
			aRegNode := &("oXMLInput:"+cPath+":_INDXPLANS")
			if(valtype(aRegNode:_INDXPLAN)=="A")
				for nQtdReg := 1 to len(aRegNode:_INDXPLAN)
					nStatus	:= oIndxPlan:nInsFromXML(cID, aRegNode:_INDXPLAN[nQtdReg])
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next nQtdReg
			elseif(valtype(aRegNode:_INDXPLAN)=="O")
				nStatus	:= oIndxPlan:nInsFromXML(cId, aRegNode:_INDXPLAN)
			endif
		endif
		
	endif

return nStatus


// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI052
	local nStatus := KPI_ST_OK,	cID, nInd, oTable, cNome, nQtdReg, aObj := {}
	local oAprxScor := ::oOwner():oGetTable("APRXSCOR")
	local oScorxInd := ::oOwner():oGetTable("SCORXIND")
	local oScorxPrj := ::oOwner():oGetTable("SCORXPRJ")
	local oIndxPlan := ::oOwner():oGetTable("INDXPLAN")
	local cScorAlt	:= xBIConvTo("C", oXML:_REGISTROS:_RELAPR:_LST_SCOR_ALT:TEXT)
	local cProjAlt	:= xBIConvTo("C", oXML:_REGISTROS:_RELAPR:_LST_PROJ_ALT:TEXT)
	local cIndAlt	:= xBIConvTo("C", oXML:_REGISTROS:_RELAPR:_LST_IND_ALT:TEXT)
	local nFoundScor:= 0
	local nFoundProj:= 0  
	local nFoundAcao:= 0
	local aScorAlt	:= {}
	local aProjAlt	:= {}
	local aIndAlt	:= {}	
						
	private oXMLInput := oXML
	
	//Controla os registros que o usuario solicitou alteracao.
	cScorAlt	:= strTran(cScorAlt, "[", "")
  	cScorAlt	:= strTran(cScorAlt, "]", "")
	aScorAlt	:= aBIToken(alltrim(cScorAlt),",",.f.)

	//Controla os registros que o usuario solicitou alteracao.	
	cProjAlt	:= strTran(cProjAlt, "[", "")
  	cProjAlt	:= strTran(cProjAlt, "]", "")
	aProjAlt	:= aBIToken(alltrim(cProjAlt),",",.f.)
	
	//Controla os registros que o usuario solicitou alteracao.	
	cIndAlt	:= strTran(cIndAlt, "[", "")
  	cIndAlt	:= strTran(cIndAlt, "]", "")
	aIndAlt	:= aBIToken(alltrim(cIndAlt),",",.f.)

	aFields := ::xRecord(RF_ARRAY) //,{"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif
	next

	// Verifica condições de gravação (append ou update)
	::oOwner():oOltpController():lBeginTransaction()
	
	::SetOrder(1) // Por ordem de ID
	if(cId == '0' .or. !::lSeek(1, {cID}))
		// Insere registro
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
		else
			//Atualizando os valores da SCORECARD
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD"))!="U")

				aRegNode := &("oXMLInput:"+cPath+":_SCORECARDS")//Pegando os valores da scorecards

				if(valtype(aRegNode:_SCORECARD)!="A")
					aObj := { aRegNode:_SCORECARD }
				else
					aObj := aRegNode:_SCORECARD
				endif	
			    oAprxScor:setOrder(2)
			    oAprxScor:lSoftSeek(2,{cID})
				while(!oAprxScor:lEof() .And. alltrim(oAprxScor:cValue("ID_APRES")) == alltrim(cID))
					nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == alltrim(oAprxScor:cValue("ID_SCOREC"))})
					if(nFoundItem == 0)
							//Nao encontrou no XML apaga.
						if(!oAprxScor:lDelete())
							nStatus := KPI_ST_INUSE
							exit							
						endif
					endif    

					oAprxScor:_Next()
				enddo

				if(valtype(aRegNode:_SCORECARD)=="A")
					for nQtdReg := 1 to len(aRegNode:_SCORECARD)
						nStatus	:= oAprxScor:nInsFromXML(cId, aRegNode:_SCORECARD[nQtdReg])
						if(nStatus != KPI_ST_OK)
							exit
						endif
					next nQtdReg
				elseif(valtype(aRegNode:_SCORECARD)=="O")
					nStatus	:= oAprxScor:nInsFromXML(cId, aRegNode:_SCORECARD)
				endif
			else
				//Caso na encontrou exclui tudo.
			    oAprxScor:setOrder(2)
			    oAprxScor:lSoftSeek(2,{cID})
				while(!oAprxScor:lEof() .And. alltrim(oAprxScor:cValue("ID_APRES")) == alltrim(cID))
					//Nao encontrou no XML apaga.
					if(!oAprxScor:lDelete())
						nStatus := KPI_ST_INUSE
						exit							
					endif
					oAprxScor:_Next()
				enddo
			endif
			
			//Tratamento da lista de indicadores
		    oScorxInd:setOrder(3)
		    oScorxInd:lSoftSeek(3,{cID})
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORXINDS"), "_SCORXIND"))!="U")

				aRegNode := &("oXMLInput:"+cPath+":_SCORXINDS")
				if(valtype(aRegNode:_SCORXIND)!="A")
					aObj := { aRegNode:_SCORXIND }
				else
					aObj := aRegNode:_SCORXIND
				endif	

				while(!oScorxInd:lEof() .And. alltrim(oScorxInd:cValue("ID_APRES")) == cID)
					nFoundItem 	:= ascan(aObj		,{|x| x:_ID:TEXT == alltrim(oScorxInd:cValue("ID_INDIC"))})
					//Indentifica os scorecards que foram alterados pelo usuario.
					nFoundScor	:= ascan(aScorAlt	,{|x| alltrim(x) == alltrim(oScorxInd:cValue("ID_SCOREC"))})
					
					if(nFoundItem == 0  .and. nFoundScor != 0)
						//Nao encontrou no XML apaga.
						if(! oScorxInd:lDelete())
							nStatus := KPI_ST_INUSE
							exit							
						endif
					endif    
					
					oScorxInd:_Next()
				enddo

				if(valtype(aRegNode:_SCORXIND)=="A")
					for nQtdReg := 1 to len(aRegNode:_SCORXIND)
						nStatus	:= oScorxInd:nInsFromXML(cId, aRegNode:_SCORXIND[nQtdReg])
						if(nStatus != KPI_ST_OK)
							exit
						endif			
					next nQtdReg
				elseif(valtype(aRegNode:_SCORXIND)=="O")
					nStatus	:= oScorxInd:nInsFromXML(cID, aRegNode:_SCORXIND)
				endif
				
			else
				//Nao encontrou. Exclui tudo.
				while(!oScorxInd:lEof() .and. alltrim(oScorxInd:cValue("ID_APRES")) == cID .and. ! empty(cScorAlt))
					nFoundScor	:= ascan(aScorAlt	,{|x| alltrim(x) == alltrim(oScorxInd:cValue("ID_SCOREC"))})
					if nFoundScor != 0
						//Nao encontrou no XML apaga.
						if(!oScorxInd:lDelete())
							nStatus := KPI_ST_INUSE
							exit							
						endif
					endif						
					oScorxInd:_Next()
				enddo
			endif
			
			//Tratamento da lista de projetos
		    oScorxPrj:setOrder(3)
		    oScorxPrj:lSoftSeek(3,{cID})
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORXPRJS"), "_SCORXPRJ"))!="U")

				aRegNode := &("oXMLInput:"+cPath+":_SCORXPRJS")
				if(valtype(aRegNode:_SCORXPRJ)!="A")
					aObj := { aRegNode:_SCORXPRJ }
				else
					aObj := aRegNode:_SCORXPRJ
				endif
			    
				while(!::lEof() .And. alltrim(oScorxPrj:cValue("ID_APRES")) == cID)
					nFoundItem	:= ascan(aObj,{|x| x:_ID:TEXT == alltrim(oScorxPrj:cValue("ID_PROJ"))})
					//Indentifica os prjetos que foram alterados pelo usuario.
					nFoundProj	:= ascan(aProjAlt	,{|x| alltrim(x) == alltrim(oScorxPrj:cValue("ID_SCOREC"))})
					
					if(nFoundItem == 0 .and. nFoundProj != 0)
						//Nao encontrou no XML apaga.
						if(!oScorxPrj:lDelete())
							nStatus := KPI_ST_INUSE
							exit							
						endif
					endif    
					
					oScorxPrj:_Next()
				enddo
				
				if(valtype(aRegNode:_SCORXPRJ)=="A")
					for nQtdReg := 1 to len(aRegNode:_SCORXPRJ)
						nStatus	:= oScorxPrj:nInsFromXML(cID, aRegNode:_SCORXPRJ[nQtdReg])
						if(nStatus != KPI_ST_OK)
							exit
						endif			
					next nQtdReg
				elseif(valtype(aRegNode:_SCORXPRJ)=="O")
					nStatus	:= oScorxPrj:nInsFromXML(cID, aRegNode:_SCORXPRJ)
				endif
			else
			    //Nao encontrou. Exclui tudo.
				while(!::lEof() .And. alltrim(oScorxPrj:cValue("ID_APRES")) == cID .and. ! empty(cProjAlt))
					nFoundProj	:= ascan(aProjAlt	,{|x| alltrim(x) == alltrim(oScorxPrj:cValue("ID_SCOREC"))})
					if(nFoundProj != 0)
						//Nao encontrou no XML apaga.
						if(!oScorxPrj:lDelete())
							nStatus := KPI_ST_INUSE
							exit							
						endif
					endif						
					oScorxPrj:_Next()
				enddo
			endif

			// tratamento da lista de plano de ações de indicadores
			if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_INDXPLANS"), "_INDXPLAN"))!="U")

				aRegNode := &("oXMLInput:"+cPath+":_INDXPLANS")
				if(valtype(aRegNode:_INDXPLAN)!="A")
					aObj := { aRegNode:_INDXPLAN }
				else
					aObj := aRegNode:_INDXPLAN
				endif	
			    oIndxPlan:setOrder(3)
			    oIndxPlan:lSoftSeek(3,{cID})
				while(!oIndxPlan:lEof() .And. alltrim(oIndxPlan:cValue("ID_APRES")) == cID)
					nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == alltrim(oIndxPlan:cValue("ID_PLANO"))})
					nFoundAcao	:= ascan(aIndAlt	,{|x| alltrim(x) == alltrim(oIndxPlan:cValue("ID_INDIC"))})
		
					if(nFoundItem == 0 .And. nFoundAcao != 0)
						//Nao encontrou no XML apaga.
						if(!oIndxPlan:lDelete())
							nStatus := KPI_ST_INUSE
							exit							
						endif
					endif    
					
					oIndxPlan:_Next()
				enddo
				if(valtype(aRegNode:_INDXPLAN)=="A")
					for nQtdReg := 1 to len(aRegNode:_INDXPLAN)
						nStatus	:= oIndxPlan:nInsFromXML(cID, aRegNode:_INDXPLAN[nQtdReg])
						if(nStatus != KPI_ST_OK)
							exit
						endif			
					next nQtdReg
				elseif(valtype(aRegNode:_INDXPLAN)=="O")
					nStatus	:= oIndxPlan:nInsFromXML(cID, aRegNode:_INDXPLAN)
				endif
			else
				//Nao encontrou. Exclui tudo.
			    oIndxPlan:setOrder(3)
			    oIndxPlan:lSoftSeek(3,{cID})
				while(!oIndxPlan:lEof() .And. alltrim(oIndxPlan:cValue("ID_APRES")) == cID)
					//Nao encontrou no XML apaga.  
					nFoundAcao	:= ascan(aIndAlt	,{|x| alltrim(x) == alltrim(oIndxPlan:cValue("ID_INDIC"))})
					if (nFoundAcao != 0)
						if(!oIndxPlan:lDelete())
							nStatus := KPI_ST_INUSE
							exit							
						endif   
					EndIf
					
					oIndxPlan:_Next()
				enddo
			endif
		endif
	endif

	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

/*
*Verifica se o usuario tem permissao para visualizar o painel
*/
method hasUserPermission() class TKPI052
	local lPermission := .f.
	local oUser		:= ::oOwner():foSecurity:oLoggedUser()
	local cUsuAtual := alltrim(oUser:cValue("ID"))
		
	if	oUser:lValue("ADMIN") .or.;
		(cUsuAtual == alltrim(::cValue("USERID")))
			
			lPermission := .t.
	endif
	
return lPermission

// Excluir entidade do server
method nDelFromXML(cID) class TKPI052
	local nStatus	:= KPI_ST_OK 
	local oAprxScor := ::oOwner():oGetTable("APRXSCOR")
	local oScorxInd := ::oOwner():oGetTable("SCORXIND")
	local oScorxPrj := ::oOwner():oGetTable("SCORXPRJ")
	local oIndxPlan := ::oOwner():oGetTable("INDXPLAN")
	
	::oOwner():oOltpController():lBeginTransaction()

	nStatus := oAprxScor:nDelFromXML(cID)	
	
	if(nStatus	== KPI_ST_OK)
		nStatus := oScorxInd:nDelFromXML(cID)	
	endif

	if(nStatus	== KPI_ST_OK)			
		nStatus := oScorxPrj:nDelFromXML(cID)	
	endif		

	if(nStatus	== KPI_ST_OK)			
		nStatus := oIndxPlan:nDelFromXML(cID)	
	endif		

	// Deleta o elemento
	if(nStatus	== KPI_ST_OK  .and. ::lSeek(1, {cID}))
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := KPI_ST_BADID
	endif	

	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

// Execute
method nExecute(cID, cExecCMD) class TKPI052
	local nStatus := KPI_ST_OK//, oEstrategia
	local aParms := {} 
	local cPathSite	:= left(httpHeadIn->REFERER, rat("/", httpHeadIn->REFERER))
	if(::lSeek(1, {cID})) // Posiciona no ID informado

		// 1 - Nome
		aAdd(aParms, alltrim(::cValue("NOME")))
		// 2 - Descrição
		aAdd(aParms, ::cValue("DESCRICAO"))
		// 3 - ID do Relatório
		aAdd(aParms, ::cValue("ID"))
		// 4 - KPIPATH da Working THREAD
		aAdd(aParms, ::oOwner():cKpiPath())
		// 5 - Nome do arquivo que sera salvo, nome do userDe e nome do userAte
		aAdd(aParms,cExecCMD )
		// 6 - Diretorio do site.
		aAdd(aParms, strtran(cPathSite,"\","/"))

		// Executando JOB
		::KPIRelAprJob(aParms)

	else

		nStatus := 	KPI_ST_BADID

	endif
                                                                         
return nStatus

// Funcao executa o job
method KPIRelAprJob(aParms) class TKPI052
	local cNome, cDescricao, cKpiPath, cIndTab := "tabela01", cPrjTab := "tabela0"
	local cScorecard := "", cReportName := "", cIdUnidade := ""
	local lValorPrevio		:= .f.    
	local lVarPercent		:= .f.
	local oParametro		:= oKpiCore:oGetTable("PARAMETRO")
	local nFirstColWidth	:= 23
	local nOthersColWidth	:= 10      
	local nVarDecimal		:= 2
	local aTopic			:= {}  
	local nQtdTopic			:= 0
	local cCorAcao			:= ""
	
	local oScorecard 	:= ::oOwner():oGetTable("SCORECARD")
	local oIndicador 	:= ::oOwner():oGetTable("INDICADOR")
	local oUnidade		:= ::oOwner():oGetTable("UNIDADE")
	local oProjeto 		:= ::oOwner():oGetTable("PROJETO")
	local oPlano 		:= ::oOwner():oGetTable("PLANOACAO")
	local oApresentacao := ::oOwner():oGetTable("RELAPR")
	local oScorxPrj 	:= ::oOwner():oGetTable("SCORXPRJ")
	local oScorxInd 	:= ::oOwner():oGetTable("SCORXIND")
	local oIndxPlan 	:= ::oOwner():oGetTable("INDXPLAN")
	local oPlanilha		:= ::oOwner():oGetTable("PLANILHA")
	local oUser			:= ::oOwner():oGetTable("USUARIO")  
	local oGrupo		:= ::oOwner():oGetTable("GRUPO")
	local oScorxApr		:= ::oOwner():oGetTable("APRXSCOR")
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )		
    
    local cHierarq		:= ''
    
	if(oParametro:lSeek(1, {"VALOR_PREVIO"}))
		lValorPrevio := oParametro:lValue("DADO")
	endif    
	
	//Exibir variação em percentual	
	if(oParametro:lSeek(1, {"SHOWVARCOL"}))
		lVarPercent := oParametro:lValue("DADO")
	endif   
	
	//Casas decimais da variação em percentual
	if(oParametro:lSeek(1, {"DECIMALVAR"}))
		nVarDecimal := int(oParametro:nValue("DADO"))
	endif

    // Coleta os parametros
	// 1 - Nome
	cNome		:= aParms[1]
	// 2 - Descrição
	cDescricao 	:= aParms[2]
	// 3 - ID do Relatório
	cId			:= alltrim(aParms[3])
	// 4 - KPIPATH da Working THREAD
	cKpiPath	:= aParms[4]
	// 5 - Nome do arquivo html a ser criado
	cReportName	:= aParms[5]
    // 6 - Diretório do site
    cSitePath	:= aParms[6]
    
	// Arquivo de log
	::oOwner():Log(STR0003 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Iniciando geração do relatório [REL052_"*/

	oHtmFile := TBIFileIO():New(oKPICore:cKpiPath()+"report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\REL052_" + alltrim(cID) + ".html")

	// Cria o arquivo htm
	If ! oHtmFile:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
		::oOwner():Log(STR0004 + cBIStr(cID) + ".html]", KPI_LOG_SCRFILE)/*//"Erro na criação do arquivo [REL052_"*/
		::oOwner():Log(STR0005, KPI_LOG_SCRFILE)/*//"Operação abortada"*/
		return
	endif
			
	oApresentacao:lSeek(1,{cID})
	dDatade 	:= oApresentacao:dValue("DATADE")
	dDataAte	:= oApresentacao:dValue("DATAATE")
	dDataAlvo	:= oApresentacao:dValue("DATAALVO")

	oScorxApr:cSQLFilter("ID_APRES = '"+cID+"'")
	oScorxApr:lFiltered(.t.)
	oScorxApr:SetOrder(2)
	oScorxApr:_First()

	oScorxPrj:cSQLFilter("ID_APRES = '"+cID+"'")
	oScorxPrj:lFiltered(.t.)
	oScorxPrj:SetOrder(2)
	oScorxPrj:_First()

	oScorxInd:cSQLFilter("ID_APRES = '"+cID+"'")
	oScorxInd:lFiltered(.t.)
	oScorxInd:SetOrder(2)
	oScorxInd:_First()
	
	oIndxPlan:cSQLFilter("ID_APRES = '"+cID+"'")
	oIndxPlan:lFiltered(.t.)
	oIndxPlan:SetOrder(2)
	oIndxPlan:_First()

	if(lValorPrevio)
		nFirstColWidth	:= 23
		nOthersColWidth := 09
	endif

	// Montagem do cabeçalho do relatório
	oHtmFile:nWriteLN('<html>')
	oHtmFile:nWriteLN('<head>') 
	oHtmFile:nWriteLN('	<title>'+KPIEncode(STR0019)+'</title>')
	oHtmFile:nWriteLN('	<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">')
	oHtmFile:nWriteLN(' <link href="'+cSitePath+'imagens/report.css" rel="stylesheet" type="text/css">')
	oHtmFile:nWriteLN(' <script language="javascript">')    
	
	oHtmFile:nWriteLN('iHeight = screen.height - 30        	') 
	oHtmFile:nWriteLN('moveTo(0,0);							')                                                                     
	oHtmFile:nWriteLN('resizeTo(screen.width , iHeight);   	')                                                                    
	                         
	oHtmFile:nWriteLN(' 	function dinMenu( x )')
	oHtmFile:nWriteLN(' 	{')
	oHtmFile:nWriteLN(' 		if ( x.style.display == "none" )')
	oHtmFile:nWriteLN(' 			x.style.display = "";')
	oHtmFile:nWriteLN(' 		else')
	oHtmFile:nWriteLN(' 			x.style.display = "none";')
	oHtmFile:nWriteLN(' 	}')
	oHtmFile:nWriteLN('	</script>')
	oHtmFile:nWriteLN('</head>')
	oHtmFile:nWriteLN('<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">')
	
	

	if(!oApresentacao:lEof()) 
		oHtmFile:nWriteLN('	<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		oHtmFile:nWriteLN('		<tr>')
		oHtmFile:nWriteLN('			<td class="tdlogo"><img class="imglogo" src='+cSitePath+'/imagens/art_logo_clie.sgi></td>')
		oHtmFile:nWriteLN('			<td width="74%" align="center" class="titulo">' + KPIEncode(STR0017) + ' - ' + cNome + '</td>')
		oHtmFile:nWriteLN('			<td width="13%" align="right" class="texto">'+KPIEncode(STR0020)+ dtoc(date()) + '</td>')
		oHtmFile:nWriteLN('		</tr>')
		oHtmFile:nWriteLN('	</table>')
		oHtmFile:nWriteLN('	<br>')
		
		aTopic := abitoken(oApresentacao:cValue("TOPICOS"),chr(10))
	    if len(aTopic) > 0
			oHtmFile:nWriteLN(' <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
			oHtmFile:nWriteLN(' 	<tr>')
			oHtmFile:nWriteLN(' 	  <td class="titulo" >')
			oHtmFile:nWriteLN(' 	    ' + KPIEncode(STR0047)) //Tópicos:
			oHtmFile:nWriteLN(' 	  </td>')
			oHtmFile:nWriteLN(' 	</tr>')
			oHtmFile:nWriteLN(' 	<tr>')
			oHtmFile:nWriteLN(' 	  <td>')
			oHtmFile:nWriteLN(' 	    <br><h3><ul>')  
			for nQtdTopic := 1 to len(aTopic)
				if len(alltrim(aTopic[nQtdTopic])) > 0
					oHtmFile:nWriteLN('           <li>' )
					oHtmFile:nWriteLN('           ' + aTopic[nQtdTopic] )			
					oHtmFile:nWriteLN('           </li>' )
				endif
			next nQtdTopic
			oHtmFile:nWriteLN(' 	    </ul></h3>')
			oHtmFile:nWriteLN(' 	  </td>')
			oHtmFile:nWriteLN(' 	</tr>')
			oHtmFile:nWriteLN(' </table>')	
			oHtmFile:nWriteLN(' <br>')
		endif	
		
		oHtmFile:nWriteLN('	<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
		while !oScorxApr:lEof()
			if ! (cScorecard == oScorxApr:cValue("ID_SCOREC"))
				cScorecard := oScorxApr:cValue("ID_SCOREC")
				oScorecard:lSeek(1,{cScorecard})
				oHtmFile:nWriteLN('		<tr>')

				//PEGA A HIERARQUIA A SER EXIBIDA - CASO SEJA VAZIA, FICA A PADRAO
				cHierarq := oScorecard:cGetScoreName(oScoreCard:cValue("ID"))
            
				If oParametro:getValue("MODO_ANALISE") == ANALISE_BSC           
					oHtmFile:nWriteLN('			<td colspan="'+iif(lValorPrevio,"9","8")+'" class="titulo">'+cHierarq+'</td>')		    		
			 	Else
					oHtmFile:nWriteLN('			<td colspan="'+iif(lValorPrevio,"9","8")+'" class="titulo">'+cBITagEmpty(KPIEncode(cTextScor)) +": "+cHierarq+'</td>') 
                EndIf

				oHtmFile:nWriteLN('		</tr>')
				oHtmFile:nWriteLN('		<tr align="center">')
				oHtmFile:nWriteLN('			<td width="'+str(nFirstColWidth) + '%" rowspan="2" class="cabecalho_1">&nbsp;</td>')
				oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+ '%" rowspan="2" class="cabecalho_1">' + KPIEncode(STR0048) + '</td>') //Unidade de Medida
				if(lValorPrevio)
					oHtmFile:nWriteLN('		<td colspan="4" class="cabecalho_1_branco">'+ mesExtenso(month(oApresentacao:dValue("DATAALVO")))+'</td>') //Mês
				else
				 	oHtmFile:nWriteLN('		<td colspan="3" class="cabecalho_1_branco">'+ mesExtenso(month(oApresentacao:dValue("DATAALVO")))+'</td>') //Mês
				endif
				oHtmFile:nWriteLN('			<td colspan="3" class="cabecalho_1_branco">'+KPIEncode(STR0018)+'</td>') //Acumulado
				oHtmFile:nWriteLN('		</tr>')
				oHtmFile:nWriteLN('		<tr align="center">')
				if(lValorPrevio)
					oHtmFile:nWriteLN('		<td width="'+str(nOthersColWidth)+'%" class="cabecalho_1">'+KPIEncode(STR0046)+'</td>') //Prévia
				endif
				oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_1">'+KPIEncode(STR0042)+'</td>') //Real
				oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth-1)+'%" class="cabecalho_1">'+KPIEncode(STR0043)+'</td>') //Meta
				oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_1">'+KPIEncode(STR0044)+'</td>') //Variação
				oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_1">'+KPIEncode(STR0042)+'</td>') //Real
				oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_1">'+KPIEncode(STR0045)+'</td>') //Meta Acumulada
				oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_1">'+KPIEncode(STR0044)+'</td>') //Variação
			    oHtmFile:nWriteLN('		</tr>')
			endif
			oHtmFile:nWriteLN('	</table>')

			oScorxInd:lSoftSeek(2,{cScorecard})
			
			while(!oScorxInd:lEof() .and. cScorecard == oScorxInd:cValue("ID_SCOREC"))
				cIndTab := "indTab"+alltrim(oScorxInd:cValue("ID"))
				oIndicador:lSeek(1,{oScorxInd:cValue("ID_INDIC")})

				oHtmFile:nWriteLN('	<table width="95%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')

				if(oPlanilha:lDateSeek(oIndicador:cValue("ID"),oApresentacao:dValue("DATAALVO"),oIndicador:nValue("FREQ")))
					aValores 	:= oIndicador:aGetIndValores(oApresentacao:dValue("DATAALVO"),oApresentacao:dValue("DATADE"),oApresentacao:dValue("DATAATE"))
				else
					aValores	:= {0,0,0,0,ESTAVEL_GRAY,ESTAVEL_GRAY,0}								
				endif				

				oHtmFile:nWriteLN('		<tr valign="top">')
				if( oIndxPlan:lSoftSeek(2,{cScorecard, oScorxInd:cValue("ID_INDIC")}) )
					oHtmFile:nWriteLN('			<td width="'+str(nFirstColWidth)+'%" class="cabecalho_2"><strong><a href="javascript:dinMenu('+cIndTab+');">'+alltrim(cBITagEmpty(KPIEncode(STR0014)+" "+oIndicador:cValue("NOME")))+'</a></strong></td>')
				else
					oHtmFile:nWriteLN('			<td width="'+str(nFirstColWidth)+'%" class="cabecalho_2"><strong>'+alltrim(cBITagEmpty(KPIEncode(STR0014)+" "+oIndicador:cValue("NOME")))+'</strong></td>')
				endif 
				
				cIdUnidade := oIndicador:cValue("UNIDADE")
				if(oUnidade:lSeek(1, {cIdUnidade}))
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_2">'+alltrim(oUnidade:cValue("NOME"))+'</td>')
				else                                                   
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_2">&nbsp;</td>')
				endif

				
				if(lValorPrevio)
                	oHtmFile:nWriteLN('		<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_2">'+::nFormatVlr(aValores[VAL_PREVIA], oIndicador:nValue("DECIMAIS"))+'</td>')
                endif
				oHtmFile:nWriteLN('			<td align=right width="'+str(nOthersColWidth)  +'%" class="cabecalho_2">'+::nFormatVlr(aValores[VAL_REAL],oIndicador:nValue("DECIMAIS"))+'</td>')
				oHtmFile:nWriteLN('			<td align=right width="'+str(nOthersColWidth-1)+'%" class="cabecalho_2">'+::nFormatVlr(aValores[VAL_META],oIndicador:nValue("DECIMAIS"))+'</td>')
				
                //Cor da coluna do real
				do case
					case aValores[VAL_REAL_STATUS] == STATUS_GREEN
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_verde" >')
					case aValores[VAL_REAL_STATUS] ==  STATUS_RED
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_verm" >')
					case aValores[VAL_REAL_STATUS] ==  STATUS_YELLOW
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_amarelo" >')
					case aValores[VAL_REAL_STATUS] == STATUS_BLUE
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_azul" >')						
					otherwise
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_cinza" >')
				endcase     
				
				if lVarPercent        
					oHtmFile:nWriteLN(::nFormatVlr( oIndicador:nGetVar(.t.,aValores[VAL_REAL],aValores[VAL_META]), nVarDecimal)+' %</td>')
				else
					oHtmFile:nWriteLN(::nFormatVlr( oIndicador:nGetVar(.f.,aValores[VAL_REAL],aValores[VAL_META]), oIndicador:nValue("DECIMAIS"))+'</td>')
				endif
				
				oHtmFile:nWriteLN('<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_2">'+::nFormatVlr(aValores[VAL_REAL_ACU], oIndicador:nValue("DECIMAIS"))+'</td>')
				oHtmFile:nWriteLN('<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_2">'+::nFormatVlr(aValores[VAL_META_ACU], oIndicador:nValue("DECIMAIS"))+'</td>')
				
				//Cor da coluna do acumulado
				do case
					case aValores[VAL_ACUM_STATUS] == STATUS_RED
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_verm">')
					case aValores[VAL_ACUM_STATUS] == STATUS_GREEN
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_verde" >')
					case aValores[VAL_ACUM_STATUS] == STATUS_YELLOW
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_amarelo" >')
					case aValores[VAL_ACUM_STATUS] == STATUS_BLUE
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_azul" >')					
					otherwise
						oHtmFile:nWriteLN('	<td align=right width="'+str(nOthersColWidth)+'%" class="cabecalho_cinza" >')
				endcase

				if lVarPercent        
					oHtmFile:nWriteLN(::nFormatVlr( oIndicador:nGetVar(.t.,aValores[VAL_REAL_ACU],aValores[VAL_META_ACU]), nVarDecimal)+' %</td>')
				else
					oHtmFile:nWriteLN(::nFormatVlr( oIndicador:nGetVar(.f.,aValores[VAL_REAL_ACU],aValores[VAL_META_ACU]), oIndicador:nValue("DECIMAIS"))+'</td>')
				endif

				oHtmFile:nWriteLN('		</tr></table>')
				
				if(!oIndxPlan:lEof() .and. oIndxPlan:cValue("ID_INDIC") == oScorxInd:cValue("ID_INDIC") .and. ;
					oIndxPlan:cValue("ID_SCOREC") == cScorecard)
					oHtmFile:nWriteLN('	<table width="95%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela" id="'+cIndTab+'" style="display:none;">')
					oHtmFile:nWriteLN('		<tr valign="top" class="tabela">')
					oHtmFile:nWriteLN('			<td width="'+str(nFirstColWidth+iif(lValorPrevio,11,0))+'%" class="cabecalho_3">'+KPIEncode(STR0021)+'</td>') //Causa
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0023)+'</td>') //Descrição
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth-1)+'%" class="cabecalho_3">'+KPIEncode(STR0029)+'</td>') //Objetivo
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0022)+'</td>') //Como
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0024)+'</td>') //Responsável/Data Término
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0025)+'</td>') //Status
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0026)+'</td>') //Observação
					oHtmFile:nWriteLN('		</tr>')
				endif

				while(!oIndxPlan:lEof() .and. oIndxPlan:cValue("ID_INDIC") == oScorxInd:cValue("ID_INDIC") .and. ;
					oIndxPlan:cValue("ID_SCOREC") == cScorecard)
					
					oPlano:lSeek(1,{oIndxPlan:cValue("ID_PLANO")})
					oHtmFile:nWriteLN('		<tr valign="top" class="tabela">')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("CAUSA")))+'</td>')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("DESCRICAO")))+'</td>')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("OBJETIVO")))+'</td>')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("COMO")))+'</td>')

					if (oPlano:cValue("TP_RESP") == TIPO_GRUPO)
						oGrupo:lSeek(1,{oPlano:cValue("ID_RESP")})
						oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oGrupo:cValue("NOME")+' - '+oPlano:cValue("DATAFIM")))+'</td>')
					else//TIPO_USUARIO
						oUser:lSeek(1,{oPlano:cValue("ID_RESP")})
						oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oUser:cValue("NOME")+' - '+oPlano:cValue("DATAFIM")))+'</td>')
					endif
					
					cCorAcao := oPlano:cGetClassStatus(oPlano:cValue("STATUS"),oPlano:dValue("DATAFIM"))
					oHtmFile:nWriteLN('			<td class="' + cCorAcao + '">'+alltrim(cBITagEmpty(oPlano:cGetStatusDescricao(oPlano:cValue("STATUS"))))+'</td>')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("OBSERVACAO")))+'</td>' )
					oHtmFile:nWriteLN('		</tr>')    
					oIndxPlan:_Next()

				enddo
				
				oScorxInd:_Next()
				if(oScorxInd:lEof() .or. !(cScorecard == oScorxInd:cValue("ID_SCOREC")))
					oHtmFile:nWriteLN('</table>')
				endif
			enddo

			oScorxPrj:lSoftSeek(2,{cScorecard})

			while(!oScorxPrj:lEof() .and. cScorecard == oScorxPrj:cValue("ID_SCOREC"))
				cPrjTab := "prjTab"+alltrim(oScorxPrj:cValue("ID"))
				oProjeto:lSeek(1,{oScorxPrj:cValue("ID_PROJ")})
				oHtmFile:nWriteLN('	<table width="95%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
				
				oHtmFile:nWriteLN('		<tr valign="top">')
				if( oPlano:lSoftSeek(3,{oScorxPrj:cValue("ID_PROJ")}) )
					oHtmFile:nWriteLN('			<td class="cabecalho_4"><a href="javascript:dinMenu('+cPrjTab+');">'+alltrim(cBITagEmpty(KPIEncode(STR0015)+" "+oProjeto:cValue("NOME")))+'</a></td>')
				else
					oHtmFile:nWriteLN('			<td class="cabecalho_4">'+alltrim(cBITagEmpty(KPIEncode(STR0015)+" "+oProjeto:cValue("NOME")))+'</td>')
				endif
				oHtmFile:nWriteLN('		</tr>')
				oHtmFile:nWriteLN('	</table>')
				
				if(!oPlano:lEof() .and. oPlano:cValue("ID_PROJ") == oScorxPrj:cValue("ID_PROJ") .and. ;
					oPlano:cValue("ID_SCOREC") == cScorecard)

					oHtmFile:nWriteLN('	<table width="95%"  border="0" align="center" cellpadding="0" cellspacing="0" class="tabela" id="'+cPrjTab+'" style="display:none;">')
					oHtmFile:nWriteLN('		<tr valign="top" class="tabela">')
					oHtmFile:nWriteLN('			<td width="'+str(nFirstColWidth+iif(lValorPrevio,11,0))+'%" class="cabecalho_3">'+KPIEncode(STR0021)+'</td>') //Causa
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0023)+'</td>') //Descrição
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth-1)+'%" class="cabecalho_3">'+KPIEncode(STR0029)+'</td>') //Objetivo
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0022)+'</td>') //Como
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0024)+'</td>') //Responsável/Data Término
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0025)+'</td>') //Status
					oHtmFile:nWriteLN('			<td width="'+str(nOthersColWidth)+'%" class="cabecalho_3">'+KPIEncode(STR0026)+'</td>') //Observação
					oHtmFile:nWriteLN('		</tr>')
				endif
				while(!oPlano:lEof() .and. oPlano:cValue("ID_PROJ") == oScorxPrj:cValue("ID_PROJ") .and. ;
					oPlano:cValue("ID_SCOREC") == cScorecard)
					
					oHtmFile:nWriteLN('		<tr valign="top" class="tabela">')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("CAUSA")))+'</td>')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("DESCRICAO")))+'</td>')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("OBJETIVO")))+'</td>')
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("COMO")))+'</td>')

					if (oPlano:cValue("TP_RESP") == TIPO_GRUPO)
						oGrupo:lSeek(1,{oPlano:cValue("ID_RESP")})
						oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oGrupo:cValue("NOME")+' - '+oPlano:cValue("DATAFIM")))+'</td>')
					else//TIPO_USUARIO
						oUser:lSeek(1,{oPlano:cValue("ID_RESP")})
						oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oUser:cValue("NOME")+' - '+oPlano:cValue("DATAFIM")))+'</td>')
					endif

					if(alltrim(oPlano:cValue("STATUS")) == "1") //não iniciado
						oHtmFile:nWriteLN('			<td class="cabecalho_verm">'+alltrim(cBITagEmpty(oPlano:cGetStatusDescricao(oPlano:cValue("STATUS"))))+'</td>')
					elseif(alltrim(oPlano:cValue("STATUS")) == "2") //em execucao
						oHtmFile:nWriteLN('			<td class="cabecalho_amarelo">'+alltrim(cBITagEmpty(oPlano:cGetStatusDescricao(oPlano:cValue("STATUS"))))+'</td>')
					elseif(alltrim(oPlano:cValue("STATUS")) == "3") //completo
						oHtmFile:nWriteLN('			<td class="cabecalho_verde">'+alltrim(cBITagEmpty(oPlano:cGetStatusDescricao(oPlano:cValue("STATUS"))))+'</td>')
					elseif(alltrim(oPlano:cValue("STATUS")) == "4") //esperando
						oHtmFile:nWriteLN('			<td class="texto">'+alltrim(cBITagEmpty(oPlano:cGetStatusDescricao(oPlano:cValue("STATUS"))))+'</td>')
					elseif(alltrim(oPlano:cValue("STATUS")) == "5") //adiado
						oHtmFile:nWriteLN('			<td class="texto">'+alltrim(cBITagEmpty(oPlano:cGetStatusDescricao(oPlano:cValue("STATUS"))))+'</td>')
					elseif(alltrim(oPlano:cValue("STATUS")) == "6") //cancelado
						oHtmFile:nWriteLN('			<td class="texto">'+alltrim(cBITagEmpty(oPlano:cGetStatusDescricao(oPlano:cValue("STATUS"))))+'</td>')
					endif
					oHtmFile:nWriteLN('			<td class="texto">' + alltrim(cBITagEmpty(oPlano:cValue("OBSERVACAO")))+'</td>' )
					oHtmFile:nWriteLN('		</tr>')    
					oPlano:_Next()
				enddo
				oScorxPrj:_Next()
				if(oScorxPrj:lEof() .or. ! (cScorecard == oScorxPrj:cValue("ID_SCOREC")))
					oHtmFile:nWriteLN('	</table>')
				endif
			enddo
		
			oScorxApr:_Next()
			if(!oScorxApr:lEof())
			 	oHtmFile:nWriteLN('</table>')
			 	oHtmFile:nWriteLN('<tr>')
			 	oHtmFile:nWriteLN('<td>&nbsp;</td>')
			 	oHtmFile:nWriteLN('</tr>')
			 	oHtmFile:nWriteLN('<tr>&nbsp;</tr>')
			 	oHtmFile:nWriteLN('<tr><td>&nbsp;</td></tr>')
				oHtmFile:nWriteLN('<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">')
			endif
		enddo
	 	oHtmFile:nWriteLN('</table>')
		// Fim table 1
	else
		// Montagem do rodap&eacute; do relat&oacute;rio 
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		KPIEncode(STR0027))
		oHtmFile:nWriteLN('	</font>')
		oHtmFile:nWriteLN('	<font face="Verdana, Arial, Helvetica, sans-serif" size="2">')
		oHtmFile:nWriteLN(		KPIEncode(STR0028))
		oHtmFile:nWriteLN('	</font>')
	endif
	oHtmFile:nWriteLN('</body>')
	oHtmFile:nWriteLN('</html>')
               
	//Faz a copia do relatorio para o diretorio de Spool
	oHtmFile:lCopyFile("report\" + AllTrim( oKPICore:foSecurity:oLoggedUser():cValue("ID") ) + "\Spool\" + cReportName, ::oOwner():cKpiPath())
	oHtmFile:lClose()
	::oOwner():Log(STR0006+cNome+"]", KPI_LOG_SCRFILE)/*//"Finalizando geração do relatório ["*/
    ::fcMsg := STR0006+cNome+"]"
return  


method nFormatVlr(nVlr, nCasaDec) class TKPI052
	local nVlrFrmt
	
	if (nCasaDec > 0 )
		nVlrFrmt := transform(nVlr, "@E 999,999,999,999." + replicate("9",nCasaDec))
	else
		nVlrFrmt := transform(nVlr, "@E 999,999,999,999")	
	endif
	
	nVlrFrmt := alltrim(nVlrFrmt)
	nVlrFrmt :=	cBITagEmpty(nVlrFrmt)

return nVlrFrmt

function _KPI052_Apres()
return nil