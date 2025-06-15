// ######################################################################################
// Projeto: KPI
// Modulo : Restricao de Acesso
// Fonte  : KPI081_Acesso.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 11.12.06 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI081_Acesso.ch"

/*--------------------------------------------------------------------------------------
@class TKPI081
@entity Acesso
Restricoes de acesso por IP
@table KPI081
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RESTACESSO"
#define TAG_GROUP  "RESTACESSOS"
#define TEXT_ENTITY STR0003/*//"Configuracao"*/
#define TEXT_GROUP  STR0004/*//"Configuracoes"*/

class TKPI081 from TBITable
	method New() constructor
	method NewKPI081()

	// diversos registros
	method oToXMLList()

	// registro atual
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)
endclass

method New() class TKPI081
	::NewKPI081()
return

method NewKPI081() class TKPI081
	// Table
	::NewTable("SGI081")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C",010))
	::addField(TBIField():New("IP"			,"C",015))	//Endereço IP
	::addField(TBIField():New("DESCRICAO"	,"C",120))	//Descrição
	
	// Indexes
	::addIndex(TBIIndex():New("SGI081I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI081I02",	{"IP"}))
	
	
return


// Lista XML para anexar ao pai
method oToXMLList() class TKPI081
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Endereço IP
	oAttrib:lSet("TAG000", "IP")
	oAttrib:lSet("CAB000", STR0001) //"Endereço IP"
	oAttrib:lSet("CLA000", KPI_STRING)  
	oAttrib:lSet("EDT000","T")
	oAttrib:lSet("CUM000","F")
	// Descrição
	oAttrib:lSet("TAG001", "DESCRICAO")
	oAttrib:lSet("CAB001", STR0002) //"Descrição"
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("EDT001","T")
	oAttrib:lSet("CUM001","F")
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::_First()
	while(!::lEof())  
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif
		::_Next()
	end

return oXMLNode

//Atualizacao 
method nUpdFromXML(oXML) class TKPI081
	local nStatus 		:= KPI_ST_OK,nInd,nProp
	local aFields		:= {}     
	local lAddNew		:= .f.
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)
    

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
		
		if(aFields[nInd][1] == "ID")
			if(aFields[nInd][2] == "N_E_W_")
				aFields[nInd][2]:= ::cMakeID()
				lAddNew := .T.
			endif				
			cCodID := aFields[nInd][2]			
		endif
	
	next  
	
	//Faz a gravacao dos dados.
	if(lAddNew .and. nStatus == KPI_ST_OK)
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	elseif(nStatus == KPI_ST_OK)
		//Atualiza os registros existentes.
		if(!::lSeek(1, {cCodID}))
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
	endif

return nStatus


// Excluir entidade do server
method nDelFromXML(oXML) class TKPI081
	local nStatus 		:= KPI_ST_OK,cCodID
	local aFields		:= {}
	local nInd			:= 1 
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)
	
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			cType := ::aFields(aFields[nInd][1]):cType()
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
			cCodID := aFields[nInd][2]
			exit
		endif	
	next

	//Exclui o elemento.
	if(::lSeek(1,{cCodID}))
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := KPI_ST_BADID
	endif	

return nStatus


function _KPI081_Acesso()
return nil