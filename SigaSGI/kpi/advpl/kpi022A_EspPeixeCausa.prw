// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpi022A_EspPeixeCausa.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 12.02.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpi022A_EspPeixeCausa.ch"

/*--------------------------------------------------------------------------------------
@entity Unidades
Tabela que contém os problemas apresentados pelos indicadores
@table KPI022
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "ESP_PEIXE_CAUSA"
#define TAG_GROUP  "ESP_PEIXE_CAUSAS"
#define TEXT_ENTITY STR0001 //"Causa" 
#define TEXT_GROUP  STR0002 //"Causas" 

class TKPI022A from TBITable
	method New() constructor
	method NewKPI022A()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList()

	// registro atual
	method nInsFromXML(aFields)
	method nUpdFromXML(aFields, cID)
	method nDelFromXML(nID)
	
	//Quando a tabela é criada, este método popula a tabela
	method carregaTabela()

endclass
	
method New() class TKPI022A
	::NewKpi022A()
return

method NewKpi022A() class TKPI022A
	// Table
	::NewTable("SGI022A")
	::cEntity(TAG_ENTITY)        
	
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("ID_PAI"		,"C"	,010))
	::addField(TBIField():New("TIPO_PAI"	,"C"	,001))
	::addField(TBIField():New("OWNER"		,"C"	,010)) //id da espinha de peixe
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI022AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI022AI02",	{"NOME"},	.f.))
	::addIndex(TBIIndex():New("SGI022AI03",	{"ID_PAI", "TIPO_PAI"},	.f.))

return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI022A
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
method oToXMLRecList(cFilter) class TKPI022A
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
	::cSQLFilter(cFilter)
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY)
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()		
	end
	::cSQLFilter("")	
	oXMLNodeLista:oAddChild(oXMLNode)
return oXMLNodeLista    




// Carregar
method oToXMLNode() class TKPI022A
	local aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next 
		
return oXMLNode
	
// Insere nova entidade
method nInsFromXML(aFields) class TKPI022A
	local nStatus := KPI_ST_OK

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
method nUpdFromXML(aFields, cID) class TKPI022A
	local nStatus := KPI_ST_OK
	
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
method nDelFromXML(cID, lDelFilhos) class TKPI022A
	local nStatus		:= KPI_ST_OK
	default lDelFilhos 	:= .f.
	

	if lDelFilhos
		::SetOrder(3)
		::lSeek(3,{cID,KPI_CAUSA})		
		while(nStatus == KPI_ST_OK 	 .and. ;
		      ::cValue("ID_PAI") == cId .and. ;
			  ::nValue("TIPO_PAI") == KPI_CAUSA )
            
			nStatus := ::nDelFromXML(::cValue("ID"), .t.)
			::_Next()
		enddo
	endif

	if(::lSeek(1,{cID}) .and. nStatus == KPI_ST_OK)
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := KPI_ST_BADID
	endif		

return nStatus

method carregaTabela() class TKPI022A
	if(::nRecCount() == 0)
		::lAppend({ {"ID", "0"}, {"NOME", ""} })
		::lAppend({ {"ID", "000000001"}, {"NOME", STR0003} })//"%"
		::lAppend({ {"ID", "000000002"}, {"NOME", STR0004} })//"Dólares"
		::lAppend({ {"ID", "000000003"}, {"NOME", STR0005} })//"Kgs"
		::lAppend({ {"ID", "000000004"}, {"NOME", STR0006} })//"Pontos"
		::lAppend({ {"ID", "000000005"}, {"NOME", STR0007} })//"Reais"
		::lAppend({ {"ID", "000000006"}, {"NOME", STR0008} })//"Tons" 
		
	
	endif  
return

function _kpi022A_EspPeixeCausa()
return nil