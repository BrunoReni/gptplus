// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI010E_Obj.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.08.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#include "KPI010E_Obj.ch"     

#define TAG_ENTITY "OBJETIVO"
#define TAG_GROUP  "OBJETIVOS"
#define TEXT_ENTITY STR0001		//###"Objetivo"
#define TEXT_GROUP  STR0002		//###"Objetivos"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI010E
Entidade Objetivo

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
class TKPI010E from TBITable

	method New() constructor
	method NewKpi010E()

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
Construtor padr�o

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI010E
	::NewKpi010E()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKpi010E
Construtor

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method NewKpi010E() class TKPI010E

	// Table
	::NewTable("SGI010E")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID" , "C", 10))

	::addField(TBIField():New("ORIGEM" , "C", 30))

	// Indexes
	::addIndex(TBIIndex():New("SGI010EI01", {"ID"}, .T.))

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera n� XML com os dados da entidade

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI010E

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
method oToXMLList() class TKPI010E

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

	// Gera n� principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o n� de detalhes
	::SetOrder(1)
	::_First()

	while(!::lEof())

		if( !(alltrim(::cValue("ID")) == "0"))    
			//Adiciona n� com a entidade posicionada
			oNode := oXMLNode:oAddChild( ::oToXMLNode() )
		endif

		::_Next()
	enddo

return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLRecList
Gera XML com os dados de todas as entidades (em um n� "LISTA")

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLRecList() class TKPI010E

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
method nInsFromXML(oXML, cPath, cId) class TKPI010E

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
method nUpdFromXML(oXML, cPath, cId) class TKPI010E

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
method nDelFromXML(cID) class TKPI010E

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
method oProcCmd(oCmd) class TKPI010E

	local oScorecard	:= nil
	local oAttrib		:= nil
	local oXmlNode		:= nil
	local oXmlAux		:= nil
	local cOrgName		:= ""
	local cEstName		:= ""
	local cPerName		:= ""

	if valtype(XmlChildEx(oCmd,"_PARENTID")) != "U"

		oScorecard	:= ::oOwner():oGetTable("SCORECARD")
		oAttrib		:= TBIXMLAttrib():New()
		oXmlNode	:= TBIXMLNode():New("PARENTS",,oAttrib)

		if oScorecard:lSeek(1, {oCmd:_PARENTID:TEXT})
			cPerName := oScorecard:cValue("NOME")

			if oScorecard:lSeek(1, {oScorecard:cValue("PARENTID")})
				cEstName := oScorecard:cValue("NOME")

				if oScorecard:lSeek(1, {oScorecard:cValue("PARENTID")})
					cOrgName := oScorecard:cValue("NOME")
				endif
			endif
		endif

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ORGANIZACAO_NOME", cOrgName)
		oAttrib:lSet("ESTRATEGIA_NOME", cEstName)
		oAttrib:lSet("PERSPECTIVA_NOME", cPerName)

		oXmlAux := oXmlNode:oAddChild(TBIXMLNode():New("PARENTS_NAMES",,oAttrib))
	else
		oXmlNode := ::oToXmlRecList()
	endif

return oXmlNode


//-------------------------------------------------------------------------------------
function _KPI010E_Obj()
return nil