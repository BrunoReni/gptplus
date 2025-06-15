// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpi020_MetaForm
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 15.09.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpi020_MetaForm.ch"

/*--------------------------------------------------------------------------------------
@entity Grupo de Indicadores
Indicador no KPI. Contém os alvos.
Indicador de performance. Indicadores estao atreladas a objetivos.
@table KPI020
--------------------------------------------------------------------------------------*/

#define TAG_ENTITY "METAFORMULA"
#define TAG_GROUP  "METASFORMULA"
#define TEXT_ENTITY STR0001/*//"Meta formula"*/
#define TEXT_GROUP  STR0002/*//"Metas formula"*/

class TKPI020 from TBITable
	method New() constructor
	method NewKPI020()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList()

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)

	method oFormulaToXML(cFormula)	
	method nValidaFormula(cFormula)
	method nExecute(nID, cExecCMD)

endclass
	
method New() class TKPI020
	::NewKpi020()
return

method NewKpi020() class TKPI020
	// Table
	::NewTable("SGI020")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	::addField(TBIField():New("FORMULA"		,"M"		))	
	
	// Indexes
	::addIndex(TBIIndex():New("SGI020I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI020I02",	{"NOME"},	.f.))

return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI020
	local oNode, oAttrib, oXMLNode, nInd
		
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
	
	//Gera o no de detalhes
	::SetOrder(2)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO","FORMULA"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif			
		::_Next()		
	end

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLRecList() class TKPI020
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
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO","FORMULA"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif			
		::_Next()		
	end

	oXMLNodeLista:oAddChild(oXMLNode)

return oXMLNodeLista

// Carregar
method oToXMLNode() class TKPI020
	local aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	
	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next

	oXMLNode:oAddChild(::oFormulaToXML(alltrim(::cValue("FORMULA"))))//Transforma a formula em XML.
		
return oXMLNode
	
// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI020
	local aFields, nInd, nStatus := KPI_ST_OK, aIndTend
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))

		if(aFields[nInd][1] =="FORMULA")
			if(::nValidaFormula(aFields[nInd][2]) == KPI_ST_VALIDATION )
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""				
			endif
		endif

	next
	aAdd(aFields, {"ID", ::cMakeID()})
	
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
method nUpdFromXML(oXML, cPath) class TKPI020
	local nFrequencia, nStatus := KPI_ST_OK, cID, nInd, lAscendente
	local oMeta, nAzul1, nVerde, nAmarelo, nVermelho, lFCumula, aIndTend
	local oIndicador 	:= ::oOwner():oGetTable("INDICADOR")
	local cNewFormula	:=	""
	local aSavePos		:=	{}
	
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	

		//Validacao da formula.
		if(aFields[nInd][1] =="FORMULA")
			cNewFormula	:=	aFields[nInd][2]
			if(::nValidaFormula(aFields[nInd][2])==KPI_ST_VALIDATION)
				return KPI_ST_VALIDATION
			else
				::fcMsg := ""
			endif
			
		endif
		
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else       
		//Valida referencia circular.
		dbSelectArea(oIndicador:cAlias())
		aSavePos	:=	{IndexOrd(), recno(), ::cSqlFilter()}

		if (! empty(cNewFormula) .and. oIndicador:checRefCircular("M." + alltrim(cID),cNewFormula))
			::fcMsg := STR0003//"Está fórmula contém referência circular."
			return KPI_ST_VALIDATION  
		endif

		oIndicador:faSavePos:= aSavePos
		oIndicador:RestPos()

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
method nDelFromXML(cID) class TKPI020
	local nStatus	:= KPI_ST_OK
	local oIndicador
	local oKpiCore	:= ::oOwner()
		
	//Verificar se o registro possui relacionamento com outras tabelas
	//KPI015: Indicador
	oIndicador := oKpiCore:oGetTable("INDICADOR") 
	oIndicador:_First()
	while(!oIndicador:lEof())
	if( at("M."+cID, alltrim(oIndicador:cValue("FORMULA"))) != 0)
		::fcMsg := STR0004 + alltrim(oIndicador:cValue("NOME")) + "'!"
		return KPI_ST_VALIDATION
	else
		::fcMsg := ""
	endif
		oIndicador:_next()
	enddo
	
	// Deleta o elemento
	if(nStatus == KPI_ST_OK)
		if(::lSeek(1,{cID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
    endif

return nStatus

//Transforma o formula em item XML.
method oFormulaToXML(cFormula) class TKPI020
	local oTableIndicador := ::oOwner():oGetTable("INDICADOR")
	oXMLNodeForm := oTableIndicador:oFormulaToXML(cFormula)
return oXMLNodeForm  

//Validacao da formula.
method nValidaFormula(cFormula) class TKPI020
	local nRetValidacao := 0
	local oTableIndicador := ::oOwner():oGetTable("INDICADOR")

	nRetValidacao := oTableIndicador:nValidaFormula(cFormula)
	::fcMsg := oTableIndicador:cMsg() //Atualizando mensagem de retorno.

	return nRetValidacao

//Validacao via nExecute da formula
method nExecute(nID, cExecCMD) class TKPI020
	return ::nValidaFormula(cExecCMD)
	
function _kpi020_MetaForm()
return nil	