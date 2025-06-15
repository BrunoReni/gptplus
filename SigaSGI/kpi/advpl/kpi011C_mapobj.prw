// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI011C_MapObj.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 26.09.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#define TAG_ENTITY "MAPAOBJETIVO"
#define TAG_GROUP  "MAPAOBJETIVOS"
//#define TEXT_ENTITY STR0001
//#define TEXT_GROUP  STR0002

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI011C
Entidade Mapa Objetivo

@author	BI TEAM
@version	P11 
@since		26/09/2011C
/*/
//-------------------------------------------------------------------------------------
class TKPI011C from TBITable

	method New() constructor
	method NewKPI011C()

	method oToXMLNode()

	method nUpdFromXML()
endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão

@author	BI TEAM
@version	P11 
@since		26/09/2011C
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI011C
	::NewKPI011C()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKPI011C
Construtor

@author	BI TEAM
@version	P11 
@since		26/09/2011C
/*/
//-------------------------------------------------------------------------------------
method NewKPI011C() class TKPI011C

	// Table
	::NewTable("SGI011C")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"				, "C", 10))
	::addField(TBIField():New("OBJETIVOID"		, "C", 10))
	::addField(TBIField():New("MAPAGRUPID"		, "C", 10))

	// Indexes
	::addIndex(TBIIndex():New("SGI011CI01", {"ID"}, .T.))
	::addIndex(TBIIndex():New("SGI011CI02", {"OBJETIVOID"}, .F.))
	::addIndex(TBIIndex():New("SGI011CI03", {"MAPAGRUPID"}, .F.))

return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author	BI TEAM
@version	P11 
@since		26/09/2011B
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI011C

	local oObjetivo := ::oOwner():oGetTable("SCORECARD")
	local oXmlRet := nil

	default oXmlNode := TBIXMLNode():New(TAG_ENTITY)

	//Se informado ID, posiciona a entidade	
	if valtype(cId) == "C" .and. !empty(cId)
		::lSeek(1, {cId})
	endif

	// Acrescenta os valores ao XML
	if oObjetivo:lSeek(1, {::cValue("OBJETIVOID")})
		oXMLNode:oAddChild(TBIXMLNode():New("MAPAGRUPO_ID", ::cValue("MAPAGRUPID")))  
		oXMLNode:oAddChild(TBIXMLNode():New("OBJETIVO_ID", ::cValue("OBJETIVOID")))  
		oXMLNode:oAddChild(TBIXMLNode():New("OBJETIVO_NOME", oObjetivo:cValue("NOME")))  

		oXmlRet := oXMLNode
	endif

return oXmlRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nUpdFromXML
Atualiza entidade ja existente

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXml, cId, aIdElement) class TKPI011C

	local nStatus := KPI_ST_OK
	local nInd := 0
	local nPos := 0
	local cType := ""  
	local xValue := nil
	local lOk := .T.

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	//Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()

		if aFields[nInd][1] == "OBJETIVOID"

			xValue := xBIConvTo(cType, oXMLInput:_OBJETIVO_ID:TEXT)

		elseif aFields[nInd][1] == "MAPAGRUPID"

			xValue := xBIConvTo(cType, oXMLInput:_MAPAGRUPO_ID:TEXT)

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

		else
			xValue := xBIConvTo(cType, &("oXMLInput:_" + aFields[nInd][1] + ":TEXT"))
		endif

		aFields[nInd][2] := xValue
	next

	if nStatus == KPI_ST_OK
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
	endif	

return nStatus

//-------------------------------------------------------------------------------------
function _KPI011C_MapObj()
return nil