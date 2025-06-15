// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI041_Painel.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 19.10.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI041_Painel.ch"

/*--------------------------------------------------------------------------------------
@entity Painel de Indicadores
Paineis grupam Indicadores dos Scorecards que o usuario tem direito de visualização.
@table KPI041
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PAINEL"
#define TAG_GROUP  "PAINEIS"
#define TEXT_ENTITY STR0001/*//"Painel de Indicadores"*/
#define TEXT_GROUP  STR0002/*//"Paineis de Indicadores"*/

class TKPI041 from TBITable
	method New() constructor
	method NewKPI041()

	// diversos registros
	method oToXMLRecList()
	method oToXMLList()

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	method oToXMLNode( cId, cLoadCmd )
	
	method hasUserPermission()

endclass
	
method New() class TKPI041
	::NewKPI041()
return

method NewKPI041() class TKPI041
	// Table
	::NewTable("SGI041")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	::addField(TBIField():New("ID_USER"		,"C"	,010))   
	::addField(TBIField():New("PUBLICO"		,"L"))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI041I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI041I02",	{"NOME"},	.f.))
	::addIndex(TBIIndex():New("SGI041I01",	{"ID_USER", "ID"},	.t.))

return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI041
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	//Gera o no de detalhes
	::SetOrder(1)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif			
		::_Next()		
	end

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLRecList() class TKPI041
	local oXMLNodeLista, oAttrib, oXMLNode, nInd

	oXMLNodeLista := TBIXMLNode():New("LISTA")
	
	//Colunas
	oAttrib := TBIXMLAttrib():New()
	//Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	//Nome
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	//Gera o principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o no de detalhes
	::SetOrder(1)
	::_First()
	while(!::lEof())
		if( !(alltrim(::cValue("ID")) == "0"))
			if(::hasUserPermission())
				oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
				aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
				for nInd := 1 to len(aFields)
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
				next
			endif
		endif			
		::_Next()		
	end

	oXMLNodeLista:oAddChild(oXMLNode)

return oXMLNodeLista

// Carregar
method oToXMLNode( cId, cLoadCmd ) class TKPI041
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	local aFields
	local nInd

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		if ValType(aFields[nInd][2]) == "L"
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], xBIConvTo("L",aFields[nInd][2])))
		else                                                                          
			oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		endif
	next

	//Acrescenta combos
	oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oToXMLList(.T.))  
	
	//Verifica se o usuário pode editar o painel.      
	oXMLNode:oAddChild(TBIXMLNode():New("EDITA", ::hasUserPermission(.T.))) 
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI041
	local oUser := oKpiCore:foSecurity:oLoggedUser()
	local nStatus 	:= KPI_ST_OK
	local nInd 		:= 0
	local nCard		:= 0
	local aFields	:= {}
	local aCardsId := {}
	local cId		:= ""
	local oTable	:= nil
	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID","ID_USER"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next  
	cId := ::cMakeID()
	aAdd(aFields, {"ID", cId})
	aAdd(aFields, {"ID_USER", oUser:cValue("ID")})

	// Grava
	if(::lAppend(aFields))
		//Exclui Cards relacionados
		oTable := ::oOwner():oGetTable("PAINELXIND")
		oTable:nDelFromXML(cId) 
		
		// Extrai e grava lista de indicadores (cards) deste painel
		aCardsId = aBiToken(&("oXMLInput:"+cPath+":_CARDSID:TEXT"),"|",.F.)
		for nCard := 1 to len(aCardsId)
			oTable:lAppend({ 	{"ID", oTable:cMakeID()},;
									{"ID_PAINEL", cId},;
									{"ID_INDIC", aCardsId[nCard]},;
									{"ORDEM", nCard} })
		next
	else
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI041
	local nStatus 	:= KPI_ST_OK
	local nInd 		:= 0
	local nCard		:= 0
	local aFields	:= {}
	local aCardsId := {}
	local cId		:= ""
	local oTable	:= nil	
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY,{"ID_USER"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
	next

	// Verifica condições de gravação (append ou update)
	if(!::lSeek(1, {cID}))
		nStatus := KPI_ST_BADID
	else       
		if(::lUpdate(aFields))
			
			//Exclui Cards relacionados
			oTable := ::oOwner():oGetTable("PAINELXIND")
			oTable:nDelFromXML(::cValue("ID")) 
			
			// Extrai e grava lista de indicadores (cards) deste painel
			aCardsId = aBiToken(&("oXMLInput:"+cPath+":_CARDSID:TEXT"),"|",.F.)
			for nCard := 1 to len(aCardsId)
				oTable:lAppend({ 	{"ID", oTable:cMakeID()},;
										{"ID_PAINEL", cID},;
										{"ID_INDIC", aCardsId[nCard]},;
										{"ORDEM", nCard} })
			next

		else
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif



return nStatus

// Excluir entidade do server
method nDelFromXML(cID) class TKPI041
	local nStatus 	:= KPI_ST_OK
	local oKpi041A
	
	//deleta os itens do painel
	oKpi041A := ::oOwner():oGetTable("PAINELXIND")
	nStatus  := oKpi041A:nDelFromXML(cID)
	// Deleta o elemento
	if(nStatus == KPI_ST_OK)
		if(::lSeek(1,{cID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
    endif
return nStatus


/**
* Verifica se o usuario tem permissao para visualizar o painel  
* @return Lógico Indica se o usuário tem permissão. 
*/
method hasUserPermission(lJustEdit) class TKPI041
	local lPermission 	:= .F.
	local oUser			:= ::oOwner():foSecurity:oLoggedUser()
	local cUsuAtual 	:= alltrim(oUser:cValue("ID"))
	Local lPublico 		:= .F.
	    
	Default lJustEdit 	:= .F.
	
	If ( ! lJustEdit )	        
		lPublico := ::lValue("PUBLICO")            	
	EndIf                 
		   
		   
	If ( oUser:lValue("ADMIN") .or. (cUsuAtual == alltrim(::cValue("ID_USER"))) .or. lPublico )
		lPermission := .t.
	EndIf	
return lPermission
                     

function _KPI041_Painel()
return nil