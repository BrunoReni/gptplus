// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI019_Pacotes.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 02.01.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI019_Pacotes.ch"

/*--------------------------------------------------------------------------------------
@entity Unidades
Tabela que contém os pacotes de acesso
@table KPI019
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PACOTE"
#define TAG_GROUP  "PACOTES"
#define TEXT_ENTITY STR0001 //"Pacote"  
#define TEXT_GROUP  STR0002 //"Pacotes" 

class TKPI019 from TBITable
	method New() constructor
	method NewKPI019()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList()

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	
endclass
	
method New() class TKPI019
	::NewKpi019()
return

method NewKpi019() class TKPI019
	// Table
	::NewTable("SGI019")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI019I01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI019I02",	{"NOME"},	.f.))

return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI019	
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
	
	//Gera recheio
	//Gera o no de detalhes
	::SetOrder(2)
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
method oToXMLRecList() class TKPI019
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
	::SetOrder(2)
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
		
	oXMLNodeLista:oAddChild(oXMLNode)
	
return oXMLNodeLista

// Carregar
method oToXMLNode() class TKPI019
	local aFields 	:= {}
	local aSelNode	:= {}
	local nInd 		:= 0
	local cId		:= ""
	local oCore		:= ::oOwner()	
	local oXMLNode 	:= TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2])) 
		if(aFields[nInd][1]=="ID")
			cId:=aFields[nInd][2]
		endif
	next 
	
	oXMLNode:oAddChild(oCore:oGetTable("USUARIO"):oToXMLList())					//Lista dos usuarios.
	oXMLNode:oAddChild(oCore:oGetTable("PACOTEXUSER"):oToXMLPacxUsu(cId))		//Usuarios com permissao para visualizar o pacote.
	oXMLNode:oAddChild(oCore:oGetTable("GRUPO_IND"):oToXMLList())				//Lista do grupo de indicadores
	oXMLNode:oAddChild(oCore:oGetTable("PACOTEXGRPIND"):oToXMLPacxGrpInd(cId))	//Grupo de indicadores com permissao no pacote.	
	
	//Lista de Scorecards
	aSelNode := oCore:oGetTable("PACOTEXDEPTO"):aNodeSelect(cId)
	oXMLNode:oAddChild(oCore:oGetTable("SCORECARD"):oArvore(.T.,"0",.T.,aSelNode))

return oXMLNode
	
// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI019
	local nStatus 		:= KPI_ST_OK
	local aFields 		:= {}         
	local aPermAlt		:= {}   
	local oTbPacGrpInd 	:= nil   
	local oTbPacDpto	:= nil  
	local oTbPacUser	:= nil
	local nInd 			:= 0   
	local cPacId		:= ""
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next                 
	cPacID := ::cMakeID()
	aAdd(aFields, {"ID", cPacId})
	
	// Grava pacote
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	
	
	// Grava grupo de indicadores
	if(nStatus == KPI_ST_OK)
		oTbPacGrpInd := ::oOwner():oGetTable("PACOTEXGRPIND")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS"), "_PACOTEXGRPIND"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND"))
					aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND["+cBIStr(nInd)+"]")
					aFields := {}
					aAdd( aFields, {"ID"		,	oTbPacGrpInd:cMakeID()	} )
					aAdd( aFields, {"PACOTE_ID"	, 	cPacId		} )	
					aAdd( aFields, {"GRPIND_ID"	, 	aPermAlt:_ID:TEXT} )	
					nStatus := oTbPacGrpInd:nInsFromXML(aFields)
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND"))=="O")
				aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND")
				aFields := {}
				aAdd( aFields, {"ID"		,	oTbPacGrpInd:cMakeID()	} )
				aAdd( aFields, {"PACOTE_ID"	, 	cPacId		} )	
				aAdd( aFields, {"GRPIND_ID"	, 	aPermAlt:_ID:TEXT} )	
				nStatus := oTbPacGrpInd:nInsFromXML(aFields)
			endif	
		endif	
	endif

	// Grava permissao de departamentos
	if(nStatus == KPI_ST_OK)
		oTbPacDpto := ::oOwner():oGetTable("PACOTEXDEPTO")

		if !(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD")) == "U")
			nStatus := oTbPacDpto:nUpdFromXML(cPacId, &("oXMLInput:"+cPath+":_SCORECARDS:_SCORECARD"))
		endif
	endif

	// Grava permissao de usuarios
	if(nStatus == KPI_ST_OK)
		oTbPacUser := ::oOwner():oGetTable("PACOTEXUSER")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PACOTEXUSERS"), "_PACOTEXUSER"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER"))
					aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER["+cBIStr(nInd)+"]")
					aFields := {}
					aAdd( aFields, {"ID"		,	oTbPacUser:cMakeID()	} )
					aAdd( aFields, {"PACOTE_ID"	, 	cPacId		} )	
					aAdd( aFields, {"USER_ID"	, 	aPermAlt:_ID:TEXT} )	
					nStatus := oTbPacUser:nInsFromXML(aFields)
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next	
			elseif(valtype(&("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER"))=="O")
				aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER")
				aFields := {}
				aAdd( aFields, {"ID"		,	oTbPacUser:cMakeID()	} )
				aAdd( aFields, {"PACOTE_ID"	, 	cPacId		} )	
				aAdd( aFields, {"USER_ID"	, 	aPermAlt:_ID:TEXT} )	
				nStatus := oTbPacUser:nInsFromXML(aFields)
			endif	
		endif	
	endif	

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI019
	local nStatus 		:= KPI_ST_OK   
	local oTbPacGrpInd	:= nil
	local oTbPacDepto 	:= nil  
	local oTbPacUser	:= nil
	local nInd 			:= 0
	local cID 			:= ""   
	local aUserPerm 	:= {}                                                           			
	local aPermAlt		:= {}
	private oXMLInput 	:= oXML
	
	aFields := ::xRecord(RF_ARRAY)

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
		if(!::lUpdate(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif        
	
	// Atualiza grupo de indicadores  
	aUserPerm := {}
	if nStatus == KPI_ST_OK
		oTbPacGrpInd := ::oOwner():oGetTable("PACOTEXGRPIND")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS"), "_PACOTEXGRPIND"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND"))
					aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND["+cBIStr(nInd)+"]")
					aFields := {}
					aAdd( aFields, {"ID"		,	oTbPacGrpInd:cMakeID()	} )
					aAdd( aFields, {"PACOTE_ID"	, 	cID		} )	
					aAdd( aFields, {"GRPIND_ID"	, 	aPermAlt:_ID:TEXT} )	
					aadd(aUserPerm,aFields)
				next	

			elseif(valtype(&("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND"))=="O")
				aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXGRPINDS:_PACOTEXGRPIND")
				aFields := {}
				aAdd( aFields, {"ID"		,	oTbPacGrpInd:cMakeID()	} )
				aAdd( aFields, {"PACOTE_ID"	, 	cID } )	
				aAdd( aFields, {"GRPIND_ID"	, 	aPermAlt:_ID:TEXT} )	
				aadd(aUserPerm,aFields)
			endif
			//Faz a atualizacao dos usuarios
			nStatus := oTbPacGrpInd:nUpdFromArray(aUserPerm,cID)
		else
			//Nao tem nada apaga todos;
			nStatus := oTbPacGrpInd:nDelFromXML(cID)
		endif
	endif   
 
	// Atualiza departamentos     
	aUserPerm := {}
	if nStatus == KPI_ST_OK
		oTbPacDpto := ::oOwner():oGetTable("PACOTEXDEPTO")
		if !(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD")) == "U")
			nStatus := oTbPacDpto:nUpdFromXML(cID, &("oXMLInput:"+cPath+":_SCORECARDS:_SCORECARD"))
		else
			nStatus := oTbPacDpto:nDelFromXML(cID)
		endif
	endif

	// Atualiza usuarios    
	aUserPerm := {}
	if nStatus == KPI_ST_OK
		oTbPacUser	:= ::oOwner():oGetTable("PACOTEXUSER")
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_PACOTEXUSERS"), "_PACOTEXUSER"))!="U")
			if(valtype(&("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER"))=="A")
				for nInd := 1 to len(&("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER"))
					aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER["+cBIStr(nInd)+"]")
					aFields := {}
					aAdd( aFields, {"ID"		,	oTbPacUser:cMakeID()	} )
					aAdd( aFields, {"PACOTE_ID"	, 	cID		} )	
					aAdd( aFields, {"USER_ID"	, 	aPermAlt:_ID:TEXT} )	
					aadd(aUserPerm,aFields)
				next	

			elseif(valtype(&("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER"))=="O")
				aPermAlt := &("oXMLInput:"+cPath+":_PACOTEXUSERS:_PACOTEXUSER")
				aFields := {}
				aAdd( aFields, {"ID"		,	oTbPacUser:cMakeID()	} )
				aAdd( aFields, {"PACOTE_ID"	, 	cID } )	
				aAdd( aFields, {"USER_ID"	, 	aPermAlt:_ID:TEXT} )	
				aadd(aUserPerm,aFields)
			endif
			//Faz a atualizacao dos usuarios
			nStatus := oTbPacUser:nUpdFromArray(aUserPerm,cID)
		else
			//Nao tem nada apaga todos;
			nStatus := oTbPacUser:nDelFromXML(cID)
		endif
	endif     
	
return nStatus

// Excluir entidade do server
method nDelFromXML(cID) class TKPI019
	local nStatus := KPI_ST_OK
	
	::oOwner():oOltpController():lBeginTransaction()
	
	//Apaga as permissoes de usuario
	nStatus := ::oOwner():oGetTable("PACOTEXUSER"):nDelFromXML(cID)
	
	//Apaga as permissoes de usuario
	if nStatus == KPI_ST_OK	
		nStatus := ::oOwner():oGetTable("PACOTEXDEPTO"):nDelFromXML(cID)
	endif
	
	//Apaga permissoes para do grupo de indicadores
	if nStatus == KPI_ST_OK	
		nStatus := ::oOwner():oGetTable("PACOTEXGRPIND"):nDelFromXML(cID)
	endif
		
	// Deleta o elemento
	if(nStatus == KPI_ST_OK )
		if(::lSeek(1,{cID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
    endif
   
   	if(nStatus != KPI_ST_OK)
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus


function _KPI019_Pacotes()
return nil