// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI011D_MapLig.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 26.09.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#define TAG_ENTITY "MAPALIGACAO"
#define TAG_GROUP  "MAPALIGACOES"
//#define TEXT_ENTITY STR0001
//#define TEXT_GROUP  STR0002

#define TP_LINE		"1"
#define TP_CURVE	"2"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI011D
Entidade Mapa Ligação

@author	BI TEAM
@version	P11 
@since		26/09/2011D
/*/
//-------------------------------------------------------------------------------------
class TKPI011D from TBITable

	method New() constructor
	method NewKPI011D()

	// Request
	method oToXMLNode()
	method oToXMLMap()
	
	// Update
	method nUpdFromXML()

endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão

@author	BI TEAM
@version	P11 
@since		26/09/2011D
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI011D
	::NewKPI011D()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKPI011D
Construtor

@author	BI TEAM
@version	P11 
@since		26/09/2011D
/*/
//-------------------------------------------------------------------------------------
method NewKPI011D() class TKPI011D

	// Table
	::NewTable("SGI011D")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"				, "C", 10))
	::addField(TBIField():New("MAPAESTID"		, "C", 10))
	::addField(TBIField():New("SRCELMID"		, "C", 10))
	::addField(TBIField():New("DSTELMID"		, "C", 10))
	::addField(TBIField():New("CONTROLX"		, "N"))
	::addField(TBIField():New("CONTROLY"		, "N"))           
	::addField(TBIField():New("COLOR"			, "N"))
	::addField(TBIField():New("TYPE"			, "C", 1))  //LINE_RECT "1", LINE_CURVE "2"

	// Indexes
	::addIndex(TBIIndex():New("SGI011DI01", {"ID"}, .T.))
	::addIndex(TBIIndex():New("SGI011DI02", {"MAPAESTID"}, .F.))
	::addIndex(TBIIndex():New("SGI011DI03", {"SRCELMID"}, .F.))
	::addIndex(TBIIndex():New("SGI011DI04", {"DSTELMID"}, .F.))

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author		BI TEAM
@version	P11 
@since		16/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI011D
	local aFields := {}
	local oMapElem := ::oOwner():oGetTable("MAPAELEMENTO")
	local oMapObj := ::oOwner():oGetTable("MAPAOBJETIVO")
	local oObjetivo := ::oOwner():oGetTable("SCORECARD")
	local lValid := .T.
	
	local oXmlRet := nil

	local nInd := 0

	default oXmlNode := TBIXMLNode():New(TAG_ENTITY)

	default aExcFields := nil

	//Se informado ID, posiciona a entidade	
	if valtype(cId) == "C" .and. !empty(cId)
		::lSeek(1, {cId})
	endif

	lValid := oMapElem:lSeek(1, {::cValue("SRCELMID")})

	if lValid
		if oMapElem:cValue("TYPE") == ELM_OBJETIVO
			lValid := oMapObj:lSeek(1, {::cValue("SRCELMID")})

			if lValid
				lValid := oObjetivo:lSeek(1, {oMapObj:cValue("OBJETIVOID")})
			endif
		endif
	endif

	lValid := lValid .and. oMapElem:lSeek(1, {::cValue("DSTELMID")})

	if lValid
		if oMapElem:cValue("TYPE") == ELM_OBJETIVO
			lValid := oMapObj:lSeek(1, {::cValue("DSTELMID")})

			if lValid
				lValid := oObjetivo:lSeek(1, {oMapObj:cValue("OBJETIVOID")})
			endif
		endif
	endif

	if lValid
		// Acrescenta os valores ao XML
		aFields := ::xRecord(RF_ARRAY, aExcFields)
	
		for nInd := 1 to len(aFields)
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next

		oXmlRet := oXMLNode
	endif

return oXmlRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLMap
Gera coleção de nós de acordo com o ID do mapa informado

@author	BI TEAM
@version	P11 
@since		26/09/2011D
/*/
//-------------------------------------------------------------------------------------
method oToXMLMap(cIdMapEst) class TKPI011D
	local oXmlNode := TBIXMLNode():New(TAG_GROUP)
	local oChildNode := nil

	::lSeek(2, {cIdMapEst})

	while !::lEof() .and. ::cValue("MAPAESTID") == cIdMapEst
		
		oChildNode := ::oToXMLNode(nil, nil, {"MAPAESTID"})

		if valtype(oChildNode) == "O"
			oXMLNode:oAddChild(oChildNode)
		endif

		::_Next()
	enddo

return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nUpdFromXML
Atualiza entidade ja existente

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXml, cIdMapa, aIdElement, aIdRet) class TKPI011D

	local nStatus := KPI_ST_OK
	local nInd := 0
	local nPos := 0
	local cId := ""
	local cType := ""
	local xValue := nil
	local lOk := .T.
	
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"MAPAESTID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		xValue := xBIConvTo(cType, &("oXMLInput:_" + aFields[nInd][1] + ":TEXT"))

		if aFields[nInd][1] == "ID"

			if upper(left(xValue, 4)) == "NEW_"
				//Gera ID em registros novos
				cId := ::cMakeID()
			else
				cId := xValue
			endif

			//lista de Ids com equivalência id interno/id real
			aAdd(aIdRet, {xValue, cId})

			xValue := cId

		elseif aFields[nInd][1] == "SRCELMID" .OR. aFields[nInd][1] == "DSTELMID"

			if upper(left(xValue, 4)) == "NEW_"
				//Converte IDs temporários
				nPos := aScan( aIdElement, {|x| x[1] == xValue} )

				if nPos > 0
					xValue := aIdElement[nPos][2]
				else 
					nStatus := KPI_ST_BADID
					
					EXIT
				endif				
			endif

		endif

		aFields[nInd][2] := xValue		
	next
	
	if nStatus == KPI_ST_OK
		aAdd(aFields, {"MAPAESTID", cIdMapa})
	
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
	endif

return nStatus

//-------------------------------------------------------------------------------------
function _KPI011D_MapLig()
return nil