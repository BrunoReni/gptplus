// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI011A_MapPer.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 26.09.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"


#define TAG_ENTITY "MAPAPERSPECTIVA"
#define TAG_GROUP  "MAPAPERSPECTIVAS"
//#define TEXT_ENTITY STR0001
//#define TEXT_GROUP  STR0002

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI011A
Entidade Mapa Perspectiva

@author	BI TEAM
@version	P11 
@since		26/09/2011A
/*/
//-------------------------------------------------------------------------------------
class TKPI011A from TBITable

	method New() constructor
	method NewKPI011A()

	// Request
	method oToXMLNode()
	method oToXmlMap()
	
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
@since		26/09/2011A
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI011A
	::NewKPI011A()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKPI011A
Construtor

@author	BI TEAM
@version	P11 
@since		26/09/2011A
/*/
//-------------------------------------------------------------------------------------
method NewKPI011A() class TKPI011A

	// Table
	::NewTable("SGI011A")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"				, "C", 10))
	::addField(TBIField():New("MAPAESTID"		, "C", 10))
	::addField(TBIField():New("PERSPECTID"		, "C", 10))
	::addField(TBIField():New("HEIGHT"			, "N"))
	::addField(TBIField():New("FONTCOLOR"		, "N"))
	::addField(TBIField():New("BACKCOLOR"		, "N"))
	::addField(TBIField():New("IMAGE"			, "C", 255))

	// Indexes
	::addIndex(TBIIndex():New("SGI011AI01", {"ID"}, .T.))
	::addIndex(TBIIndex():New("SGI011AI02", {"MAPAESTID"}, .F.))
	::addIndex(TBIIndex():New("SGI011AI03", {"MAPAESTID", "PERSPECTID"}, .T.))
	::addIndex(TBIIndex():New("SGI011AI04", {"PERSPECTID"}, .F.))

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author	BI TEAM
@version	P11 
@since		26/09/2011A
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI011A
	local aFields := {}
	local nInd

	default oXmlNode := TBIXMLNode():New(TAG_ENTITY)

	default aExcFields := {}

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
/*/{Protheus.doc} oToXMLMap
Gera coleção de nós de acordo com o ID do mapa informado

@author	BI TEAM
@version	P11 
@since		26/09/2011D
/*/
//-------------------------------------------------------------------------------------
method oToXMLMap(cIdMapEst) class TKPI011A
	local oPersp := ::oOwner():oGetTable("SCORECARD")
	local oElem := ::oOwner():oGetTable("MAPAELEMENTO")
	local oXmlNode := TBIXMLNode():New(TAG_GROUP)
	local oNode := nil
	local oNodeAux := nil
	local cNome := ""
	local nOrdem := 0
	local cPerId := ""
	local lAddNode := .T.

	::lSeek(2, {cIdMapEst})

	while !::lEof() .and. ::cValue("MAPAESTID") == cIdMapEst
		//dados da perspectiva
		cPerId := ::cValue("PERSPECTID")

		lAddNode := .T.		

		if !Empty(cPerId)
			lAddNode := oPersp:lSeek(1, {cPerId})
			
			if lAddNode
				cNome := oPersp:cValue("NOME")
				nOrdem := oPersp:nValue("ORDEM")
			endif
		else
			cNome := ""
			nOrdem := 0
		endif

		if lAddNode
			//dados principais
			oNode := ::oToXMLNode(nil, nil, {"MAPAESTID", "PERSPECTID"})
	
			oNode:oAddChild(TBIXMLNode():New("PERSPECTIVA_NOME", cNome))
			oNode:oAddChild(TBIXMLNode():New("PERSPECTIVA_ORDEM", nOrdem))
			oNode:oAddChild(TBIXMLNode():New("PERSPECTIVA_ID", cPerId))
	
			//temas
			oNodeAux := TBIXMLNode():New("MAPAGRUPOS")
			oNode:oAddChild(oElem:oToXMLMap(::cValue("ID"), ELM_GRUPO, oNodeAux))
	
			//objetivos
			oNodeAux := TBIXMLNode():New("MAPAOBJETIVOS")
			oNode:oAddChild(oElem:oToXMLMap(::cValue("ID"), ELM_OBJETIVO, oNodeAux))
	
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
@since		26/09/2011A
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXml, cIdMapa, aIdElement, aIdRet) class TKPI011A

	local nStatus		:= KPI_ST_OK
	local nInd			:= 0
	local cId			:= ""
	local cType			:= ""
	local xValue		:= nil
	local aXmlAux		:= {}
	local oXmlAux		:= nil
	local oMapElem		:= ::oOwner():oGetTable("MAPAELEMENTO")
	local cImageFile	:= ""
	local cPathImage	:= ""

	local nPos			:= 0
	local cPathImages	:= ::oOwner():cKpiPath() + "imagens\"
	local cFileName		:= ""
	local cFilePath		:= ""
	local cSearchPath	:= ""
	local aFilesDel		:= {}
	local oFile			:= nil

	private oXMLInput	:= oXML

	aFields := ::xRecord(RF_ARRAY, {"MAPAESTID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()

		if aFields[nInd][1] == "PERSPECTID"
			xValue := xBIConvTo(cType, oXMLInput:_PERSPECTIVA_ID:TEXT)
		elseif aFields[nInd][1] == "IMAGE"
			xValue := xBIConvTo(cType, oXMLInput:_IMAGE:TEXT)
			
			nPos := rat("/", xValue)

			cFileName := allTrim( substr(xValue, nPos + 1) )

			cFilePath := cPathImages + "map." + cIdMapa + "\"
		else
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
	
			endif
		endif

		aFields[nInd][2] := xValue
	next

	aAdd(aFields, {"MAPAESTID", cIdMapa})

	if !::lSeek(1, {cID})
		lOk := ::lAppend(aFields)
	else
		lOk := ::lUpdate(aFields)
	endif

	if lOk
		//Salva temas
		oXmlAux := oXMLInput:_MAPAGRUPOS

		if XmlChildCount( oXmlAux ) > 0
			//Padroniza estrutura do XML para conter array mesmo que possua apenas um item
			if valtype(oXmlAux:_MAPAGRUPO) == "O"
				XmlNode2Arr(oXmlAux:_MAPAGRUPO, "_MAPAGRUPO")
			endif

			aXmlAux := XmlGetChild( oXmlAux, 1 )
			for nInd := 1 to len(aXmlAux)
				oXmlAux := aXmlAux[nInd]
				nStatus := oMapElem:nUpdFromXML(oXmlAux, cId, aIdElement)

				if !(nStatus == KPI_ST_OK)
					EXIT
				endif
			next
		endif

		//Salva objetivos
		if nStatus == KPI_ST_OK
			oXmlAux := oXMLInput:_MAPAOBJETIVOS

			if XmlChildCount( oXmlAux ) > 0
				//Padroniza estrutura do XML para conter array mesmo que possua apenas um item
				if valtype(oXmlAux:_MAPAOBJETIVO) == "O"
					XmlNode2Arr(oXmlAux:_MAPAOBJETIVO, "_MAPAOBJETIVO")
				endif
	
				aXmlAux := XmlGetChild( oXmlAux, 1 )
				for nInd := 1 to len(aXmlAux)
					oXmlAux := aXmlAux[nInd]
					nStatus := oMapElem:nUpdFromXML(oXmlAux, cId, aIdElement)
	
					if !(nStatus == KPI_ST_OK)
						EXIT
					endif
				next
			endif
		endif
	endif

	if nStatus == KPI_ST_OK
		if lOk
			cSearchPath := cFilePath + "persp." + cId + ".*"
			aFilesDel := directory(cSearchPath)

			cFileName := upper(cFileName)
			while (nPos := aScan(aFilesDel, {|a| upper(a[1]) == cFileName })) > 0
				aDel(aFilesDel, nPos)
				aSize(aFilesDel, len(aFilesDel) - 1)
			enddo
		
			for nInd := 1 to len(aFilesDel)
				oFile := TBIFileIO():New(cFilePath + aFilesDel[nInd][1])
				if oFile:lExists() 
					oFile:lErase()
				endif
			next
		else
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

@author		BI TEAM
@version	P11 
@since		25/11/2011
/*/
//-------------------------------------------------------------------------------------
//override lDelete
method lDelete() class TKPI011A

	local lOk			:= .T.
	local oMapElem		:= ::oOwner():oGetTable("MAPAELEMENTO")
	local oFile			:= nil
	local aFilesDel		:= {}
	local cPathImages	:= ::oOwner():cKpiPath() + "\imagens\"
	local cFilePath		:= ""
	local cSearchPath	:= ""
	local cFileName		:= ""
	local nPos			:= 0
	local nInd			:= 0

	//Inicia transação	
	::oOwner():oOltpController():lBeginTransaction()

	//Elimina elementos
	while lOk .and. oMapElem:lSeek(2, {::cValue("ID")})
    	lOk := oMapElem:lDelete()
	enddo

	//Elimina perspectiva
	if lOk
		cFileName := ::cValue("IMAGE")
		nPos := rat("/", cFileName)

		cFileName := allTrim( substr(cFileName, nPos + 1) )
	
		cFilePath := cPathImages + "map." + ::cValue("MAPAESTID") + "\"

		cSearchPath := cFilePath + "persp." + ::cValue("ID") + ".*"

		aFilesDel := directory(cSearchPath)
		lOk := _Super:lDelete()
	endif
	   
	//Commit/Rollback
	if !lOk
		::oOwner():oOltpController():lRollback()	
	endif

	::oOwner():oOltpController():lEndTransaction()
	
	if lOk
		for nInd := 1 to len(aFilesDel)
			oFile := TBIFileIO():New(cFilePath + aFilesDel[nInd][1])
			if oFile:lExists() 
				oFile:lErase()
			endif
		next
	endif

return lOk

//-------------------------------------------------------------------------------------
function _KPI011A_MapPer()
return nil