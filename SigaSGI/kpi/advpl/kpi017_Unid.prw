// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI017_Unid.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 06.01.06 | 2487 Eduardo Konigami Miyoshi
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI017_Unid.ch"

/*--------------------------------------------------------------------------------------
@entity Unidades
Tabela que contém a unidade utilizada no sistema
@table KPI017
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "UNIDADE"
#define TAG_GROUP  "UNIDADES"
#define TEXT_ENTITY STR0001/*//"Unidade"*/
#define TEXT_GROUP  STR0002/*//"Unidades"*/

class TKPI017 from TBITable
	method New() constructor
	method NewKPI017()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList()

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	
	//Quando a tabela é criada, este método popula a tabela
	method carregaTabela()

endclass
	
method New() class TKPI017
	::NewKpi017()
return

method NewKpi017() class TKPI017
	// Table
	::NewTable("SGI017")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI017I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI017I02",	{"NOME"},	.f.))

return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI017
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
	
	//Gera recheio
	//Gera o no de detalhes
	::SetOrder(2)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif			
		::_Next()		
	end

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLRecList() class TKPI017
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
	::SetOrder(2)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif			
		::_Next()		
	end
		
	oXMLNodeLista:oAddChild(oXMLNode)
	
return oXMLNodeLista

// Carregar
method oToXMLNode() class TKPI017
	local aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next 
		
return oXMLNode
	
// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI017
	local aFields, nInd, nStatus := KPI_ST_OK, aIndTend
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
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
method nUpdFromXML(oXML, cPath) class TKPI017
	local nStatus := KPI_ST_OK, cID, nInd
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
method nDelFromXML(cID) class TKPI017
	local nStatus			:= KPI_ST_OK//, oTableChild
	local oKpiCore			:= ::oOwner()    
	local oIndicador		:= oKpiCore:oGetTable("INDICADOR")    
	
	if( ! oIndicador:lSeek(9,{cID})) 
		// Deleta o elemento
		if(nStatus == KPI_ST_OK )
			if(::lSeek(1,{cID}))
				if(!::lDelete())
					nStatus := KPI_ST_INUSE
				endif
			else
				nStatus := KPI_ST_BADID
			endif	
	    endif
	else
		cIndName	:= alltrim(oIndicador:cValue("NOME"))
		::fcMsg		:= STR0003 + cIndName + STR0004
		nStatus		:= KPI_ST_VALIDATION
	endif

return nStatus

method carregaTabela() class TKPI017
	if(::nRecCount() == 0)
		::lAppend({ {"ID", "0"}, {"NOME", ""} })
		::lAppend({ {"ID", "0000000001"}, {"NOME", STR0005} }) // %
		::lAppend({ {"ID", "0000000002"}, {"NOME", STR0006} }) // Dólares
		::lAppend({ {"ID", "0000000003"}, {"NOME", STR0007} }) // Kgs
		::lAppend({ {"ID", "0000000004"}, {"NOME", STR0008} }) // Pontos
		::lAppend({ {"ID", "0000000005"}, {"NOME", STR0009} }) // Reais
		::lAppend({ {"ID", "0000000006"}, {"NOME", STR0010} }) // Tons  
		
	endif  
return

function _KPI017_Unid()
return nil