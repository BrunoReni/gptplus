// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI052D_IndxPlan.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 20.01.06 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI052D_IndxPlan.ch"

/*--------------------------------------------------------------------------------------
@class TKPI052D
@entity INDXPLAN
Objeto que representa os Planos de Ações de um Indicadores de um Scorecard de uma Apresentação
@table KPI052D
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "INDXPLAN"
#define TAG_GROUP  "INDXPLANS"
#define TEXT_ENTITY STR0001/*//"Scorecard / Indicador"*/
#define TEXT_GROUP  STR0002/*//"Scorecards / Indicadores"*/

class TKPI052D from TBITable
	method New() constructor
	method NewKPI052D()

	//Multiplos registros
	method oToXMLList(cApresID)
	method nInsFromXML(cApresID,oXML)
	method nUpdFromXML(cApresID,oXML)
	method nDelFromXML(cApresID)

endclass

method New() class TKPI052D
	::NewKPI052D()
return

method NewKPI052D() class TKPI052D

	// Table
	::NewTable("SGI052D")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_APRES"	,"C"	,10))//Id da apresentação.
	::addField(TBIField():New("ID_SCOREC"	,"C"	,10))//Id do  scorecard.
	::addField(TBIField():New("ID_INDIC"	,"C"	,10))//Id do indicador.
	::addField(TBIField():New("ID_PLANO"	,"C"	,10))//Id do plano de ação

	// Indexes
	::addIndex(TBIIndex():New("SGI052DI1",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI052DI2",	{"ID_SCOREC","ID_INDIC","ID_PLANO"},.f.))
	::addIndex(TBIIndex():New("SGI052DI3",	{"ID_APRES","ID_PLANO"},.t.))
	
return

// Lista XML para anexar ao pai
method oToXMLList(cApresID) class TKPI052D
	local oNode, oAttrib, oXMLNode, nInd
	local oPlano := ::oOwner():oGetTable("PLANOACAO")
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .t.)
                 
	// Nome
	oAttrib:lSet("TAG000", "NOME") //Planos de Ação")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
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
			if(aFields[nInd][1] == "ID_PLANO")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			endif
			if (oPlano:lSeek(1,{::cValue("ID_PLANO")}))
				oNode:oAddChild(TBIXMLNode():New("NOME"	, oPlano:cValue("NOME")))
			else
				oNode:oAddChild(TBIXMLNode():New("NOME"	, ""))
			endif
		next

		::_Next()
	end

return oXMLNode

//Faz a atualização dos temas gravados
method nUpdFromXML(cApresID,oXML) class TKPI052D
	local aFields, nStatus := KPI_ST_OK
	local nFoundItem, aItemOk := {} , nItem := 0
	private aObj := oXml

	if(valtype(aObj)!="A")
		aObj := { aObj }
	endif	

    ::setOrder(3)
    ::lSoftSeek(3,{cApresID})
	while(!::lEof() .And. alltrim(::cValue("ID_APRES")) == cApresID)
		nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == alltrim(::cValue("ID_PLANO"))})

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
			::nInsFromXML(cApresID,oXml, nItem)
		endif
	next nItem

return nStatus

//Insere a entidade no server
method nInsFromXML(cApresId, oXml,nItem) class TKPI052D
	local aFields,nInd,nItens ,nStatus := KPI_ST_OK, cPlano := ""
	private oXmlInput := oXml

	default nItem := 1

	aFields := ::xRecord(RF_ARRAY, {"ID_PLANO","ID_APRES"})
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		if(valtype(oXmlInput)=="O")
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXmlInput["+alltrim(str(nItem))+"]:_"+aFields[nInd][1]+":TEXT"))
		endif
		if(aFields[nInd][1] == "ID")			
			cPlano := aFields[nInd][2]
			aAdd( aFields, {"ID_PLANO", aFields[nInd][2]})
			aFields[nInd][2] := ::cMakeID()
		endif
	next

	aAdd( aFields, {"ID_APRES", cApresID})

	// Grava
	if(!::lSeek(3,{cApresID,cPlano}))
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
method nDelFromXML(cApresID) class TKPI052D
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

function _KPI052D_IndxPlan()
return nil