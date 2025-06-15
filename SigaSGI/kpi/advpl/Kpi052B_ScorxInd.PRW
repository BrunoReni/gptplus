// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI052B_ScorxInd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 10.01.06 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpi052b_scorxind.ch"

/*--------------------------------------------------------------------------------------
@class TKPI052B
@entity SCORXIND
Objeto que representa os Indicadores de um Scorecard de uma Apresentação
@table KPI052B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SCORXIND"
#define TAG_GROUP  "SCORXINDS"
#define TEXT_ENTITY STR0001/*//"Scorecard / Indicador"*/
#define TEXT_GROUP  STR0002/*//"Scorecards / Indicadores"*/

class TKPI052B from TBITable
	method New() constructor
	method NewKPI052B()

	//Multiplos registros
	method oToXMLList(cApresID)
	method nInsFromXML(cApresID,oXML)
	method nUpdFromXML(cApresID,oXML)
	method nDelFromXML(cApresID)

endclass

method New() class TKPI052B
	::NewKPI052B()
return

method NewKPI052B() class TKPI052B

	// Table
	::NewTable("SGI052B")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_APRES"	,"C"	,10))//Id da apresentação.
	::addField(TBIField():New("ID_SCOREC"	,"C"	,10))//Id do  scorecard.
	::addField(TBIField():New("ID_INDIC"	,"C"	,10))//Id do indicador.

	// Indexes
	::addIndex(TBIIndex():New("SGI052BI1",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI052BI2",	{"ID_SCOREC","ID_INDIC"},.f.))
	::addIndex(TBIIndex():New("SGI052BI3",	{"ID_APRES","ID_INDIC"},.t.))
	
return

// Lista XML para anexar ao pai
method oToXMLList(cApresID) class TKPI052B
	local oNode, oAttrib, oXMLNode, nInd
	local oIndicador := ::oOwner():oGetTable("INDICADOR")
	Local cTextScor	:= alltrim( getJobProfString("ScoreCardName", "ScoreCard") )	
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .T.)
                 
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", cTextScor + STR0003) //" x Indicador"
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
    ::setOrder(3)
    ::lSoftSeek(3,{cApresID})
	while(!::lEof() .And. ::cValue("ID_APRES") == cApresID)
	
		aFields := ::xRecord(RF_ARRAY, {"ID"})
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "ID_INDIC")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))
				if (oIndicador:lSeek(1,{::cValue("ID_INDIC")}))
					oNode:oAddChild(TBIXMLNode():New("NOME"	, oIndicador:cValue("NOME")))
				else
					oNode:oAddChild(TBIXMLNode():New("NOME"	, ""))
				endif
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			endif

		next

		::_Next()
	end

return oXMLNode

//Faz a atualização dos temas gravados
method nUpdFromXML(cApresID,oXML) class TKPI052B
	local aFields, nStatus := KPI_ST_OK
	local nFoundItem, aItemOk := {} , nItem := 0
	private aObj := oXml

	if(valtype(aObj)!="A")
		aObj := { aObj }
	endif	

	// Gera recheio
    ::setOrder(3)
    ::lSoftSeek(3,{cApresID})
	while(!::lEof() .And. ::cValue("ID_APRES") == cApresID)
		nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == alltrim(::cValue("ID_INDIC"))})

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
			//Nao esta no array de itemOk Inclui.
			nStatus := ::nInsFromXML(cApresID,oXml, nItem)
		endif
	next nItem

return nStatus

//Insere a entidade no server
method nInsFromXML(cApresId, oXml,nItem) class TKPI052B
	local aFields,nInd,nItens ,nStatus := KPI_ST_OK, cIndicId, cId := 0
	private oXmlInput := oXml

	default nItem := 0
	
	aFields := ::xRecord(RF_ARRAY, {"ID_INDIC","ID_APRES"})
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		if(valtype(oXmlInput)=="O")
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXmlInput["+alltrim(str(nItem))+"]:_"+aFields[nInd][1]+":TEXT"))
		endif
		if(aFields[nInd][1] == "ID")			
			cIndicId := aFields[nInd][2]
			aAdd( aFields, {"ID_INDIC", aFields[nInd][2]})
			aFields[nInd][2] :=  ::cMakeID()
		endif
	next

	aAdd( aFields, {"ID_APRES", cApresID})
	// Grava
    if(!::lSeek(3,{cApresID,cIndicId}))
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
method nDelFromXML(cApresID) class TKPI052B
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

function _KPI052B_ScorxInd()
return nil