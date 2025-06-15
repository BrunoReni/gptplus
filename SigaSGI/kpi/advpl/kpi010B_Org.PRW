// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI010B_Org.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 16.08.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#include "KPI010B_Org.ch"     

#define TAG_ENTITY "ORGANIZACAO"
#define TAG_GROUP  "ORGANIZACOES"
#define TEXT_ENTITY STR0001		//###"Organização"
#define TEXT_GROUP  STR0002		//###"Organizações"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI010B
Entidade Organização

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
class TKPI010B from TBITable

	method New() constructor
	method NewKPI010B()

	// Request
	method oToXMLNode()
	method oToXMLList()
	method oToXMLRecList()
	
	// Create/Update/Delete
	method nInsFromXML()
	method nUpdFromXML()
	method nDelFromXML()

endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI010B
	::NewKpi010B()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKpi010B
Construtor

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method NewKpi010B() class TKPI010B

	// Table
	::NewTable("SGI010B")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			, "C", 10))

	::addField(TBIField():New("MISSAO"		, "C", 255))
	::addField(TBIField():New("VISAO"		, "C", 255))
	::addField(TBIField():New("NOTAS"		, "C", 255))
	::addField(TBIField():New("QUALIDADE"	, "C", 255))
	::addField(TBIField():New("PRINCIPIOS"	, "C", 255))
	::addField(TBIField():New("VALORES"		, "C", 255))

	::addField(TBIField():New("ENDERECO"	, "C", 120))
	::addField(TBIField():New("CIDADE"		, "C", 20))
	::addField(TBIField():New("ESTADO"		, "C", 20))
	::addField(TBIField():New("PAIS"		, "C", 20))
	::addField(TBIField():New("FONE"		, "C", 20))
	::addField(TBIField():New("EMAIL"		, "C", 80))
	::addField(TBIField():New("PAGINA"		, "C", 80))

	// Indexes
	::addIndex(TBIIndex():New("SGI010BI01", {"ID"}, .T.))

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI010B
	local aFields := {}
	local nInd

	default oXmlNode := TBIXMLNode():New(TAG_ENTITY)

	default aExcFields := nil

	//Se informado ID, posiciona a entidade	
	if valtype(cId) == "C" .and. !empty(cId)
		::lSeek(1, {cId})
	endif

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY, aExcFields)

	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next                                                                          

		
return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLList
Gera XML com os dados de todas as entidades

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLList() class TKPI010B

	local oNode
	local oAttrib
	local oXMLNode

	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera nó principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o nó de detalhes
	::SetOrder(1)
	::_First()

	while(!::lEof())

		if( !(alltrim(::cValue("ID")) == "0"))    
			//Adiciona nó com a entidade posicionada
			oNode := oXMLNode:oAddChild( ::oToXMLNode() )
		endif

		::_Next()
	enddo

return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLRecList
Gera XML com os dados de todas as entidades (em um nó "LISTA")

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLRecList() class TKPI010B

	local oXMLNodeLista := TBIXMLNode():New("LISTA")

	oXMLNodeLista:oAddChild( ::oToXMLList() )
	
return oXMLNodeLista


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nInsFromXML
Insere nova entidade

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method nInsFromXML(oXML, cPath, cId) class TKPI010B

	local aFields := {}
	local aIndTend := {}
	local nStatus := KPI_ST_OK
	local nInd

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd(aFields, {"ID", cId})

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	

return nStatus

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nUpdFromXML
Atualiza entidade ja existente

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXML, cPath, cId) class TKPI010B

	local nStatus := KPI_ST_OK
	local nInd

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next

	aAdd(aFields, {"ID", cId})

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

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nDelFromXML
Exclui entidade

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method nDelFromXML(cID) class TKPI010B

	local nStatus := KPI_ST_OK

	if(::lSeek(1,{cID})) 

		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif

	else
		nStatus := KPI_ST_BADID
	endif	

return nStatus

//-------------------------------------------------------------------------------------
function _KPI010B_ORG()
return nil