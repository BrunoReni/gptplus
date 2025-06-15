// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI010D_Per.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.08.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#include "KPI010D_Per.ch"     

#define TAG_ENTITY "PERSPECTIVA"
#define TAG_GROUP  "PERSPECTIVAS"
#define TEXT_ENTITY STR0001		//###"Perspectiva"
#define TEXT_GROUP  STR0002		//###"Perspectivas"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI010D
Entidade Perspectiva

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
class TKPI010D from TBITable

	method New() constructor
	method NewKpi010D()

	// Request
	method oToXMLNode()
	method oToXMLList()
	method oToXMLRecList()
	method oProcCmd()
	
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
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI010D
	::NewKpi010D()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKpi010D
Construtor

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method NewKpi010D() class TKPI010D

	// Table
	::NewTable("SGI010D")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID" , "C", 10))

	// Indexes
	::addIndex(TBIIndex():New("SGI010DI01", {"ID"}, .T.))

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI010D

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
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLList() class TKPI010D

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
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLRecList() class TKPI010D

	local oXMLNodeLista := TBIXMLNode():New("LISTA")

	oXMLNodeLista:oAddChild( ::oToXMLList() )
	
return oXMLNodeLista


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nInsFromXML
Insere nova entidade

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method nInsFromXML(oXML, cPath, cId) class TKPI010D

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
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXML, cPath, cId) class TKPI010D

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
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method nDelFromXML(cID) class TKPI010D

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
/*/{Protheus.doc} oProcCmd
Processa e distribui comandos

@author		BI TEAM
@version	P11 
@since		12/12/2011
/*/
//-------------------------------------------------------------------------------------
method oProcCmd(oCmd) class TKPI010D

	local oScorecard	:= nil
	local oAttrib		:= nil
	local oXmlNode		:= nil
	local oXmlAux		:= nil
	local cOrgName		:= ""
	local cEstName		:= ""

	if valtype(XmlChildEx(oCmd,"_PARENTID")) != "U"

		oScorecard	:= ::oOwner():oGetTable("SCORECARD")
		oAttrib		:= TBIXMLAttrib():New()
		oXmlNode	:= TBIXMLNode():New("PARENTS",,oAttrib)

		if oScorecard:lSeek(1, {oCmd:_PARENTID:TEXT})
			cEstName := oScorecard:cValue("NOME")
			
			if oScorecard:lSeek(1, {oScorecard:cValue("PARENTID")})
				cOrgName := oScorecard:cValue("NOME")
			endif
		endif

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ORGANIZACAO_NOME", cOrgName)
		oAttrib:lSet("ESTRATEGIA_NOME", cEstName)

		oXmlAux := oXmlNode:oAddChild(TBIXMLNode():New("PARENTS_NAMES",,oAttrib))
	else
		oXmlNode := ::oToXmlRecList()
	endif

return oXmlNode


//-------------------------------------------------------------------------------------
function _KPI010D_Per()
return nil