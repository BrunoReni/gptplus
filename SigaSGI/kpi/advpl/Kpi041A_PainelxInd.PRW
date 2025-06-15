// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI041A_PainelxInd.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.11.05 | 0739 Aline Correa do Vale
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI041A_PainelxInd.ch"

/*--------------------------------------------------------------------------------------
@class TKPI041A
@entity PAINELXIND
Objeto que representa os indicadores de um Painel
@table KPI041A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PAINELXIND"
#define TAG_GROUP  "PAINELXINDS"
#define TEXT_ENTITY STR0001/*//"Painel / Indicadores "*/
#define TEXT_GROUP  STR0002/*//"Paineis / Indicadores "*/

class TKPI041A from TBITable
	method New() constructor
	method NewKPI041A()

	//Multiplos registros
	method oToXMLNode(cId, cLoadCmd)
	method oToXMLList(cParentID)
	method oToXMLCards()
	method nInsFromXML(cPainelID,oXML)
	method nUpdFromXML(cPainelID,oXML)
	method nDelFromXML(cPainelID)

	//nDuplicate
	method nDuplicate(nParentID, nNewParentID, aObjIds)
	
endclass

method New() class TKPI041A
	::NewKPI041A()
return

method NewKPI041A() class TKPI041A

	// Table
	::NewTable("SGI041A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_PAINEL"	,"C"	,10))	//Id do Grupo.
	::addField(TBIField():New("ID_INDIC"	,"C"	,10))	//Id usado 
	::addField(TBIField():New("ORDEM"		,"N"))		//Ordem

	// Indexes
	::addIndex(TBIIndex():New("SGI041AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI041AI02",	{"ID_PAINEL","ORDEM"},.f.))
	::addIndex(TBIIndex():New("SGI041AI03",	{"ID_INDIC"},.f.))
	
return
                             

// Carregar
method oToXMLNode(cId, cLoadCmd) class TKPI041A
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)
	local oIndicador	:= nil
	local oNode			:= nil
	local dAlvo			:= nil
	local dAcumDe		:= nil
	local dAcumAte		:= nil
	local cCmd			:= ""
	local cId			:= ""                                  
	local cUserID		:= "" 
	local aParms		:= {}
   
	aParms 	:= aBiToken(cLoadCmd,"|",.F.)
	cCmd		:= aParms[1]
	cId	 	:= aParms[2] //ALLCARD ID=PAINELXIND; CARD ID=INDICADOR
	dAlvo 	:= xBIConvTo("D",aParms[3])
	dAcumDe 	:= xBIConvTo("D",aParms[4])
	dAcumAte := xBIConvTo("D",aParms[5])

	if(cCmd == "ALLCARD")
		oNode := ::oToXMLCards(cId,dAlvo,dAcumDe,dAcumAte)
		if(valType(oNode)=="O")
			oXMLNode:oAddChild(oNode)
		endif
	elseif(cCmd == "CARD")
		//oScoreCard := ::oOwner():oGetTable("SCORECARD")
		//if(oScoreCard:lSeek(1,{::cValue("ID_SCOREC")}))
		//	isScoOwner	:= oUser:lValue("ADMIN") .OR. oScoreCard:cValue("RESPID")==cUserID
		//endif              
		oIndicador := ::oOwner():oGetTable("INDICADOR")
		cUserID	:= oKpiCore:foSecurity:oLoggedUser():cValue("ID")
		if(oIndicador:lSeek(1,{cId}) .and. !alltrim(cId)=="0")
			oXMLNode := oIndicador:oAddIndItem( {dAlvo, , dAcumDe, dAcumAte}, .t., cUserID)
		endif
	endif

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLList(nParentID) class TKPI041A
	local oNode, oAttrib, oXMLNode, nInd
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()

	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	// Gera recheio
	::SetOrder(1)
	::cSQLFilter("PARENTID = '"+cBIStr(nParentID)+"'") // Filtra pelo pai
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
	
		aFields := ::xRecord(RF_ARRAY, {"ID"})
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "ID_INDIC")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))			
			else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))			
			endif			

		next

		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Lista XML para anexar ao pai
method oToXMLCards(cParentID, dDataAlvo, dDataDe, dDataAte) class TKPI041A
	local oAttrib			:= nil
	local oXMLNode			:= nil
	local oIndicador		:= nil    
	local cUserID			:= ""
	local aDataAnalise	:= {dDataAlvo,dDataAlvo, dDataDe, dDataAte}
	                  
	
	cUserId := oKpiCore:foSecurity:oLoggedUser():cValue("ID")
	
	::SetOrder(2)
	::lSoftSeek(2, {cParentId})

	if(!::lEof() .and. cParentId == ::cValue("ID_PAINEL"))
		// Colunas
		oAttrib := TBIXMLAttrib():New()
	
		// Tipo
		oAttrib:lSet("TIPO", "CARD")
		oAttrib:lSet("RETORNA", .f.)
	
		// Gera no principal
		oXMLNode := TBIXMLNode():New("CARDS",,oAttrib)
		oIndicador := ::oOwner():oGetTable("INDICADOR")
		while(!::lEof() .and. cParentId == ::cValue("ID_PAINEL"))
	        if(oIndicador:lSeek(1,{::cValue("ID_INDIC")}) .and. ! alltrim(::cValue("ID_INDIC"))=="0" )

				oXmlNode:oAddChild(oIndicador:oAddIndItem(aDataAnalise,.t.,cUserId))
				
			endif
			::_Next()
		end
	endif

return oXMLNode


//Faz a atualização dos temas gravados
method nUpdFromXML(cPainelID,oXML) class TKPI041A
	local aFields, nStatus := KPI_ST_OK
	local nFoundItem, aItemOk := {} , nItem := 0
	private aTemaObj := oXml

	if(valtype(aTemaObj)!="A")
		aTemaObj := { aTemaObj }
	endif	

	::cSQLFilter("ID_PAINEL = '" + cBIStr(cPainelID)+"'")
	::lFiltered(.t.)
	::_First()

	while(!::lEof())
		nFoundItem := ascan(aTemaObj,{|x| x:_ID:TEXT == alltrim(::cValue("ID_INDIC"))})

		if(nFoundItem > 0)
			aadd(aItemOk, nFoundItem)
		endif			
		
		if(nFoundItem == 0)
			//Nao encontrou no XML apaga.
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
				exit							
			endif
		else
			//Encontrou atualiza.
		endif    
		
		::_Next()
	end
	::cSQLFilter("")

	for nItem := 1 to len(aTemaObj)
		nFoundItem := ascan(aItemOk , {|x| x == nItem})
		if nFoundItem == 0
			//Nao esta no array de itemOk Inclui.
			::nInsFromXML(cPainelID,oXml, nItem)
		endif
	next nItem

return nStatus

//Insere a entidade no server
method nInsFromXML(cPainelID,oXml,nItemInc) class TKPI041A
	local aFields,nInd,nTemas ,nStatus := KPI_ST_OK
	private aTemaObj := oXml

	default nItemInc := 0
	
	if(valtype(aTemaObj)!="A")
		aTemaObj := { aTemaObj }
	endif	

	for nTemas := 1 to len(aTemaObj)
		//Verifica se devo incluir um item especifico.
		if(nItemInc == 0 .or. nTemas == nItemInc)
			aFields := ::xRecord(RF_ARRAY, {"ID_INDIC","ID_PAINEL"})
		
			// Extrai valores do XML
			for nInd := 1 to len(aFields)
				cType := ::aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("aTemaObj["+alltrim(str(nTemas))+"]:_"+aFields[nInd][1]+":TEXT"))
				if(aFields[nInd][1] == "ID")			
					aAdd( aFields, {"ID_INDIC", aFields[nInd][2]})
					aFields[nInd][2] := ::cMakeID()
				endif
			next
	
			aAdd( aFields, {"ID_PAINEL", cPainelID})
			
			// Grava
			if(!::lAppend(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			endif
		endif
	next nTemas

return nStatus

// Excluir entidade do server
method nDelFromXML(cPainelID) class TKPI041A
	nStatus := KPI_ST_OK

	::cSQLFilter("ID_PAINEL = '" + cBIStr(cPainelID)+"'")
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


// Duplica os Cards baseado na matriz
// aIndIDs - Contem todo o mapa de ids dos indicadores correspondendo a fonte da alteracao
method nDuplicate(nOldID_PAINEL, cNewID_Painel, aObjIDs) class TKPI041A
	local nStatus := KPI_ST_OK, nInd, cID, aFields := {}
	local nObjID, cNewIndID
	
	::oOwner():oOltpController():lBeginTransaction()

	::savePos() 
	for nInd := 1 to len(aObjIDs)
	
		nObjID := aObjIDs[nInd][1]
		cNewIndID := aObjIDs[nInd][2]
	
		if(::lSeek(2, {nOldID_PAINEL,nObjID}))
			// Copia temporario
			aFields := {}
			cID := ::cMakeID()

			aAdd( aFields, {"ID", cID } )
			aAdd( aFields, {"ID_PAINEL"	, cNewID_Painel} )
			aAdd( aFields, {"ID_INDIC", cNewIndID} )
		
 			// Grava
			if(! ::lAppend(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
				exit
			endif
		endif
	next nInd
	::restPos()	 
	
	if(nStatus != KPI_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()
	
return nStatus

function _KPI041A_PainelxInd()
return nil