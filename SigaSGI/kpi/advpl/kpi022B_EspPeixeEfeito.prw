// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpi022B_EspPeixeEfeito.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 12.02.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpi022B_EspPeixeEfeito.ch"

/*--------------------------------------------------------------------------------------
@entity Unidades
Tabela que contém os problemas apresentados pelos indicadores
@table KPI022B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "ESP_PEIXE_EFEITO"
#define TAG_GROUP  "ESP_PEIXE_EFEITOS"
#define TEXT_ENTITY STR0001 //"Efeito" 
#define TEXT_GROUP  STR0002 //"Efeitos" 

class TKPI022B from TBITable
	method New() constructor
	method NewKPI022B()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList()

	// registro atual
	method nInsFromXML(aFields)
	method nUpdFromXML(aFields,cID)
	method nDelFromXML(nID)
	
	//Quando a tabela é criada, este método popula a tabela
	method carregaTabela()

endclass
	
method New() class TKPI022B
	::NewKpi022B()
return

method NewKpi022B() class TKPI022B
	// Table
	::NewTable("SGI022B")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("ID_PAI"		,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI022BI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI022BI02",	{"NOME"},	.f.))

return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI022B
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
method oToXMLRecList() class TKPI022B
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
method oToXMLNode() class TKPI022B
	local aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next 
		
return oXMLNode
	
// Insere nova entidade
method nInsFromXML(aFields) class TKPI022B
	local nStatus := KPI_ST_OK

	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(aFields,cID) class TKPI022B
	local nStatus 	:= KPI_ST_OK

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
method nDelFromXML(cID, lDelFilhos) class TKPI022B
	local nStatus := KPI_ST_OK
	local oCausa  := nil
	default lDelFilhos := .f.
	
	if lDelFilhos       
		oCausa:= ::oOwner():oGetTable("ESP_PEIXE_CAUSA")
		oCausa:SetOrder(3)
		while(nStatus == KPI_ST_OK 	 .and. ;
			  oCausa:lSeek(3,{cID,KPI_EFEITO}) )
			  
			nStatus := oCausa:nDelFromXML(oCausa:cValue("ID"), .t.)
		enddo
	endif
	
	if(::lSeek(1,{cID}))
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := KPI_ST_BADID
	endif	
	
return nStatus


method carregaTabela() class TKPI022B
return

function _kpi022B()
return nil