// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI011B_MapElm.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 26.09.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#define TAG_ENTITY "MAPAELEMENTO"
#define TAG_GROUP  "MAPAELEMENTOS"
//#define TEXT_ENTITY STR0001
//#define TEXT_GROUP  STR0002

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI011B
Entidade Mapa Elemento

@author	BI TEAM
@version	P11 
@since		26/09/2011B
/*/
//-------------------------------------------------------------------------------------
class TKPI011B from TBITable

	method New() constructor
	method NewKPI011B()

	// Request
	method oToXMLNode()
	method oToXMLMap()
	
	// Update
	method nUpdFromXML() 
	
	// Delete - Override
	method lDelete()

endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão

@author	BI TEAM
@version	P11 
@since		26/09/2011B
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI011B
	::NewKPI011B()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKPI011B
Construtor

@author	BI TEAM
@version	P11 
@since		26/09/2011B
/*/
//-------------------------------------------------------------------------------------
method NewKPI011B() class TKPI011B

	// Table
	::NewTable("SGI011B")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"				, "C", 10))
	::addField(TBIField():New("MAPAPERID"		, "C", 10))
	::addField(TBIField():New("POSX"			, "N"))
	::addField(TBIField():New("POSY"			, "N"))
	::addField(TBIField():New("WIDTH"			, "N"))
	::addField(TBIField():New("HEIGHT"			, "N"))
	::addField(TBIField():New("OPAQUE"			, "L"))
	::addField(TBIField():New("HIDENAME"		, "L"))
	::addField(TBIField():New("BACKCOLOR"		, "N"))
	::addField(TBIField():New("FONTCOLOR"		, "N"))
	::addField(TBIField():New("SHAPE"			, "C", 1)) //SHP_RECT "1", SHP_CIRCLE "2"
	::addField(TBIField():New("TYPE"			, "C", 1)) //ELM_GRUPO "1", ELM_OBJETIVO "2"

	// Indexes
	::addIndex(TBIIndex():New("SGI011BI01", {"ID"}, .T.))
	::addIndex(TBIIndex():New("SGI011BI02", {"MAPAPERID"}, .F.))
	::addIndex(TBIIndex():New("SGI011BI03", {"TYPE", "MAPAPERID"}, .F.))
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author	BI TEAM
@version	P11 
@since		26/09/2011B
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI011B
	local oAux := nil

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

	if ::cValue("TYPE") == ELM_OBJETIVO
		oAux := ::oOwner():oGetTable("MAPAOBJETIVO")
	else
		oAux := ::oOwner():oGetTable("MAPAGRUPO")
	endif

	oXMLNode := oAux:oToXMLNode(::cValue("ID"), oXMLNode, {"ID"})

return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLMap
Gera coleção de nós de acordo com o ID informado

@author	BI TEAM
@version	P11 
@since		26/09/2011D
/*/
//-------------------------------------------------------------------------------------
method oToXMLMap(cIdPersp, cType, oXmlNode) class TKPI011B
	local oNode := nil
	default oXmlNode := TBIXMLNode():New(TAG_GROUP)
	default cType := ""

	//Parent = Perspectiva
	if empty(cType)
		::lSeek(2, {cIdPersp})
	else
		::lSeek(3, {cType, cIdPersp})
	endif

	while	!::lEof() ;
			.and. ::cValue("MAPAPERID") == cIdPersp ;
			.and. (empty(cType) .OR. ::cValue("TYPE") == cType)

		//dados principais
		oNode := ::oToXMLNode(nil, nil, {"MAPAPERID"})

		if valtype(oNode) == "O"
			//adiciona nó
			oXMLNode:oAddChild(oNode)
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
method nUpdFromXML(oXml, cIdPersp, aIdRet) class TKPI011B

	local nStatus := KPI_ST_OK
	local nInd := 0
	local nPos := 0
	local cId := ""
	local cType := ""
	local xValue := nil
	local lOk := .T.
	local oMapObj := ::oOwner():oGetTable("MAPAOBJETIVO")
	local oMapTem := ::oOwner():oGetTable("MAPAGRUPO")
	local oAux := nil

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"MAPAPERID"})

	//Extrai valores do XML
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

		elseif aFields[nInd][1] == "TYPE"

			if xValue == ELM_OBJETIVO
				oAux := oMapObj
			else
				oAux := oMapTem
			endif

		endif

		aFields[nInd][2] := xValue		
	next

	aAdd(aFields, {"MAPAPERID", cIdPersp})

	if !::lSeek(1, {cID})
		lOk := ::lAppend(aFields)
	else
		lOk := ::lUpdate(aFields)
	endif
	
	if lOk
		nStatus := oAux:nUpdFromXML(oXml, cId, aIdRet)
	endif


	if nStatus == KPI_ST_OK
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
/*/{Protheus.doc} lDelete
Exclui entidade

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
//override lDelete
method lDelete() class TKPI011B

	local lOk := .T.
	local oAux := nil
	local oMapLig := ::oOwner():oGetTable("MAPALIGACAO")

	//Inicia transação	
	::oOwner():oOltpController():lBeginTransaction()

	if ::cValue("TYPE") == ELM_OBJETIVO
		oAux := ::oOwner():oGetTable("MAPAOBJETIVO")
	else
		oAux := ::oOwner():oGetTable("MAPAGRUPO")
	endif

	//Elimina elemento complementar
	if oAux:lSeek(1, {::cValue("ID")})
		lOk := oAux:lDelete()
	endif
	
	//Elimina ligações com elemento como origem
	while lOk .and. oMapLig:lSeek(3, {::cValue("ID")})
    	lOk := oMapLig:lDelete()
	enddo

	//Elimina ligações com elemento como destino
	while lOk .and. oMapLig:lSeek(4, {::cValue("ID")})
    	lOk := oMapLig:lDelete()
	enddo

	//Elimina elemento
	if lOk
		lOk := _Super:lDelete()
	endif
	
	//Commit/Rollback
	if !lOk
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return lOk


//-------------------------------------------------------------------------------------
function _KPI011B_MapElm()
return nil