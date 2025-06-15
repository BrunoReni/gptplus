// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI052A_AprxScor.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.01.06 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI052A_AprxScor.ch"

/*--------------------------------------------------------------------------------------
@class TKPI052A
@entity APRESXIND
Objeto que representa os Scorecards de uma Apresentação
@table KPI052A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "APRXSCOR"
#define TAG_GROUP  "APRXSCORS"
#define TEXT_ENTITY STR0001/*//"Apresesentação / Scorecard "*/
#define TEXT_GROUP  STR0002/*//"Apresentações / Scorecard "*/

class TKPI052A from TBITable
	method New() constructor
	method NewKPI052A()

	//Multiplos registros
	method oToXMLList(cParentID)
	method nInsFromXML(cApresID,oXML)
	method nUpdFromXML(cApresID,oXML)
	method nDelFromXML(cApresID)      
	method aNodeSelect(cId)

endclass

method New() class TKPI052A
	::NewKPI052A()
return

method NewKPI052A() class TKPI052A

	// Table
	::NewTable("SGI052A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_APRES"	,"C"	,10))//Id da apresentação.
	::addField(TBIField():New("ID_SCOREC"	,"C"	,10))//Id do scorecard.

	// Indexes
	::addIndex(TBIIndex():New("SGI052AI1",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI052AI2",	{"ID_APRES","ID_SCOREC"},.t.))
	::addIndex(TBIIndex():New("SGI052AI3",	{"ID_SCOREC"},.f.))
	
return

// Lista XML para anexar ao pai
method oToXMLList(cParentId) class TKPI052A
	local oNode, oAttrib, oXMLNode, nInd,oScorecard
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .T.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", STR0003 + cTextScor) //"Apresentação x "
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(1)
	::cSQLFilter("ID_APRES = '"+cBIStr(cParentId)+"'") // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
    oScorecard := ::oOwner():oGetTable("SCORECARD")
	while(!::lEof())
	
		aFields := ::xRecord(RF_ARRAY, {"ID","ID_APRES"})
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "ID_SCOREC")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			endif
		next
		//oXMLNode:oAddChild(::oOwner():oGetTable("SCORXPRJ"):oToXMLList( ::cValue("ID") ))
		//oXMLNode:oAddChild(::oOwner():oGetTable("SCORXIND"):oToXMLList( ::cValue("ID") ))

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

//Faz a atualização dos temas gravados
method nUpdFromXML(cApresID,oXML) class TKPI052A
	local aFields, nStatus := KPI_ST_OK
	local nFoundItem, aItemOk := {} , nItem := 0, nInd := 0
	private aObj := oXml

	if(valtype(aObj)!="A")
		aObj := { aObj }
	endif	
    ::setOrder(2)
    ::lSoftSeek(2,{cApresID})
	while(!::lEof() .And. alltrim(::cValue("ID_APRES")) == cApresID)
		nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == alltrim(::cValue("ID_SCOREC"))})

		if(nFoundItem > 0)
			aadd(aItemOk, nFoundItem)
		endif			
		
		if(nFoundItem == 0)
			//Nao encontrou no XML apaga.
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
				exit							
			endif
		endif    
		
		::_Next()
	end

	for nItem := 1 to len(aObj)
		nFoundItem := ascan(aItemOk , {|x| x == nItem})
		if nFoundItem == 0
			nStatus := ::nInsFromXML(cApresID, oXml, nItem)
		endif
	next nItem

return nStatus

//Insere a entidade no server
method nInsFromXML(cApresID,oXml, nItem) class TKPI052A
	local aFields,nInd,nItens ,nStatus := KPI_ST_OK, cScoreID
	private oXmlInput := oXml

	aFields := ::xRecord(RF_ARRAY, {"ID_SCOREC","ID_APRES"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		if(valtype(oXmlInput)=="O")
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXmlInput["+alltrim(str(nItem))+"]:_"+aFields[nInd][1]+":TEXT"))
		endif
		if(aFields[nInd][1] == "ID")
			aAdd( aFields, {"ID_SCOREC", aFields[nInd][2]})
			cScoreId := aFields[nInd][2]
			aFields[nInd][2] := ::cMakeID()
		endif
	next

	aAdd( aFields, {"ID_APRES", cApresID})

	// Grava
    if(!::lSeek(2,{cApresID, cScoreId}) .and. !empty(cScoreId))
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif
	endif

return nStatus

// Excluir entidade do server
method nDelFromXML(cApresID) class TKPI052A
	nStatus := KPI_ST_OK

	::cSQLFilter("ID_APRES = '" + cBIStr(cApresID)+"'")
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
		::_Next()
	end
	::cSQLFilter("")

return nStatus              

/*
* Monta array com os nodes selecionados
* @Param cId - ID do Node
*/
Method aNodeSelect(cId) Class TKPI052A
 
	Local aRet		:= {}   
    Local aPosicao 	:= ::SavePos()
    
	::lSoftSeek(2,{cId})
	
	While (!::lEof() .And. ::cValue("ID_APRES") == cId)
		
		aAdd(aRet,::cValue("ID_SCOREC"))
					   
		::_Next()
	End
              
	::RestPos(aPosicao)

Return aRet


function _KPI052A_AprxScor()
return nil