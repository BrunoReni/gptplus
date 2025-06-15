// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI011E_MapTem.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 26.09.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#define TAG_ENTITY "MAPAGRUPO"
#define TAG_GROUP  "MAPAGRUPOS"
//#define TEXT_ENTITY STR0001
//#define TEXT_GROUP  STR0002

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI011E1
Entidade Mapa Tema

@author	BI TEAM            
@version	P11 
@since		26/09/2011E
/*/
//-------------------------------------------------------------------------------------
class TKPI011E1 from TBITable

	method New() constructor
	method NewKPI011E()

	method oToXMLNode()

	method nUpdFromXML()

endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão

@author	BI TEAM
@version	P11 
@since		26/09/2011E
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI011E1
	::NewKPI011E()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKPI011E
Construtor

@author	BI TEAM
@version	P11 
@since		26/09/2011E
/*/
//-------------------------------------------------------------------------------------
method NewKPI011E() class TKPI011E1

	// Table
	::NewTable("SGI011E")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"				, "C", 10))
	::addField(TBIField():New("NOME"			, "C", 120))

	// Indexes
	::addIndex(TBIIndex():New("SGI011EI01", {"ID"}, .T.))

return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author	BI TEAM
@version	P11 
@since		26/09/2011B
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI011E1

	default oXmlNode := TBIXMLNode():New(TAG_ENTITY)

	//Se informado ID, posiciona a entidade	
	if valtype(cId) == "C" .and. !empty(cId)
		::lSeek(1, {cId})
	endif

	// Acrescenta os valores ao XML
	oXMLNode:oAddChild(TBIXMLNode():New("NOME", ::cValue("NOME")))

return oXMLNode



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nUpdFromXML
Atualiza entidade ja existente

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXml, cId, aIdElement) class TKPI011E1

	local nStatus := KPI_ST_OK
	local nInd := 0
	local nPos := 0
	local cType := ""  
	local lOk := .T.

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	//Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_" + aFields[nInd][1] + ":TEXT"))
	next

	aAdd(aFields, {"ID", cId})

	if !::lSeek(1, {cID})
		lOk := ::lAppend(aFields)
	else
		lOk := ::lUpdate(aFields)
	endif

	if !lOk	
		if ::nLastError() == DBERROR_UNIQUE
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif

return nStatus

//-------------------------------------------------------------------------------------
function __KPI011E_MapGrp()
return nil