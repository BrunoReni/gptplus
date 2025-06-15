// ######################################################################################
// Projeto: KPI 
// Modulo : Database
// Fonte  : KPI011_MapEst.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 26.09.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#define TAG_ENTITY "MAPAESTRATEGICO"
#define TAG_GROUP  "MAPAESTRATEGICOS"
//#define TEXT_ENTITY STR0001
//#define TEXT_GROUP  STR0002

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI011
Entidade Mapa Estratégico

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
class TKPI011 from TBITable

	method New() constructor
	method NewKPI011()

	// Request
	method oToXMLNode()
	method oToXMLMap()
	method oProcCmd()

	// Update
	method nUpdFromXML()
	method nUpdMapStruc()
	
	// Delete - Override
	method lDelete()

	// Específicos
	method oGetStObj()
	method aGetObjCause()
	method aGetObjEffect()
	method oGetObjRel()  
	method nExecute(cID, cExecCMD)       
	method moveFile(cNameFile, cPathDest)      
	method delFile(cNameFile)

endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI011
	::NewKPI011()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKPI011
Construtor

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method NewKPI011() class TKPI011

	// Table
	::NewTable("SGI011")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"				, "C", 10))
	::addField(TBIField():New("ESTRATID"		, "C", 10))
	::addField(TBIField():New("QTDDIVISAO"		, "N", 1, 0))
	::addField(TBIField():New("DIVISAO1"		, "C", 255))
	::addField(TBIField():New("DIVISAO2"		, "C", 255))
	::addField(TBIField():New("DIVISAO3"		, "C", 255))
	::addField(TBIField():New("TYPE"			, "C", 1))		//MAP_MODEL1 "1", MAP_MODEL2 "2"

	// Indexes
	::addIndex(TBIIndex():New("SGI011I01", {"ID"}, .T.))
	::addIndex(TBIIndex():New("SGI011I02", {"ESTRATID"}, .F.))
	::addIndex(TBIIndex():New("SGI011I03", {"TYPE", "ESTRATID"}, .T.))

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI011
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
/*/{Protheus.doc} oToXMLMap
Gera coleção de nós de acordo com o ID da estratégia informada

@author	BI TEAM
@version	P11 
@since		26/09/2011D
/*/
//-------------------------------------------------------------------------------------
method oToXMLMap(cIdEstrategia, cType) class TKPI011
	local oXmlNode := TBIXMLNode():New(TAG_ENTITY)
	local oNode := nil

	local oEstrat := ::oOwner():oGetTable("SCORECARD")
	local oMapPer := ::oOwner():oGetTable("MAPAPERSPECTIVA")
	local oMapLig := ::oOwner():oGetTable("MAPALIGACAO")
	local oTemas := ::oOwner():oGetTable("TEMAESTRATEGICO")
	
	local nStatus := KPI_ST_OK
	
	default cType := MAP_MODEL1

	nStatus := ::nUpdMapStruc(cIdEstrategia, cType)
    
	if nStatus == KPI_ST_OK
		//localiza mapa estratégico
		if ::lSeek(3, {cType, cIdEstrategia})
			//dados principais
			oNode := ::oToXMLNode(nil, oXmlNode, {"ESTRATID"})
			oNode:oAddChild(TBIXMLNode():New("ESTRATEGIA_ID", ::cValue("ESTRATID")))
			
			// Acrescenta os valores ao XML
			if oEstrat:lSeek(1, {::cValue("ESTRATID")})
				oNode:oAddChild(TBIXMLNode():New("NOME", oEstrat:cValue("NOME")))
			endif

			//perspectivas
			oNode:oAddChild(oMapPer:oToXMLMap(::cValue("ID")))

			//ligações
			oNode:oAddChild(oMapLig:oToXMLMap(::cValue("ID")))

			//temas estratégicos
			oNode:oAddChild(oTemas:oToXMLList(cIdEstrategia, .F.))

			//adiciona nó
			oXMLNode:oAddChild(oNode)
		endif
	endif

return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nUpdFromXML
Atualiza entidade ja existente

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXML, cPath) class TKPI011

	local nStatus := KPI_ST_OK
	local nInd := 0
	local cId := ""
	local cField := ""
	local oMapPer := ::oOwner():oGetTable("MAPAPERSPECTIVA")
	local oMapLig := ::oOwner():oGetTable("MAPALIGACAO")
	local oMapElem := ::oOwner():oGetTable("MAPAELEMENTO")
	local oXmlAux := nil  
	local aXmlAux := {}
	local aIdPerspec := {}
	local aIdElement := {}
	local aIdLink := {}	
	local aDelList := {}
	local aDelAux := {}
	local lOk := .T.
	local xValue := nil

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY)

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		cField := aFields[nInd][1]

		if cField == "ESTRATID"
			cField := "ESTRATEGIA_ID"
		endif

		xValue := xBIConvTo(cType, &("oXMLInput:" + cPath + ":_" + cField + ":TEXT"))

		if cField == "ID"
			if upper(left(xValue, 4)) == "NEW_"
				//Gera ID em registros novos
				cId := ::cMakeID()
			else
				If !(xValue <> aFields[nInd][2])
					cId := aFields[nInd][2]
				Else 
					//trativa realizada para que não haja problemas na concorrencia de threads
					cId := xValue
				EndIf
			endif

			xValue := cId
		endif

		aFields[nInd][2] := xValue
	next

	//Inicia transação
	::oOwner():oOltpController():lBeginTransaction()

	//Salva Mapa Estratégico
	if !::lSeek(1, {cID})
		lOk := ::lAppend(aFields)
	else
		lOk := ::lUpdate(aFields)
//		lOk := ::lUpdateMapa(aFields)
	endif

	if !lOk
		if ::nLastError()==DBERROR_UNIQUE
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif

	//Salva perspectivas
	if nStatus == KPI_ST_OK
		oXmlAux := oXMLInput:_REGISTROS:_MAPAESTRATEGICO:_MAPAPERSPECTIVAS

		if XmlChildCount( oXmlAux ) > 0
			//Padroniza estrutura do XML para conter array mesmo que possua apenas um item
			if valtype(oXmlAux:_MAPAPERSPECTIVA) == "O"
				XmlNode2Arr(oXmlAux:_MAPAPERSPECTIVA, "_MAPAPERSPECTIVA")
			endif
			
			aXmlAux := XmlGetChild( oXmlAux, 1 )
			for nInd := 1 to len(aXmlAux)
				oXmlAux := aXmlAux[nInd]
				nStatus := oMapPer:nUpdFromXML(oXmlAux, cId, aIdElement, aIdPerspec)

				if !(nStatus == KPI_ST_OK)
					EXIT
				endif
			next
		endif
	endif

	//Salva ligações
	if nStatus == KPI_ST_OK
		oXmlAux := oXMLInput:_REGISTROS:_MAPAESTRATEGICO:_MAPALIGACOES

		if XmlChildCount( oXmlAux ) > 0
			//Padroniza estrutura do XML para conter array mesmo que possua apenas um item
			if valtype(oXmlAux:_MAPALIGACAO) == "O"
				XmlNode2Arr(oXmlAux:_MAPALIGACAO, "_MAPALIGACAO")
			endif

			aXmlAux := XmlGetChild( oXmlAux, 1 )
			for nInd := 1 to len(aXmlAux)
				oXmlAux := aXmlAux[nInd]
				nStatus := oMapLig:nUpdFromXML(oXmlAux, cId, aIdElement, aIdLink)

				if !(nStatus == KPI_ST_OK)
					EXIT
				endif
			next
		endif
	endif

	//Exluir ligações que não estão mais presentes no XML
	if nStatus == KPI_ST_OK	
		aDelList := {}

		if oMapLig:lSeek(2, {cId})
			while !oMapLig:lEof() .and. oMapLig:cValue("MAPAESTID") == cId
				//Verifica se ID do banco está presente na lista enviada pelo client
				if aScan(aIdLink, {|x| x[2] == oMapLig:cValue("ID")}) == 0
					aAdd(aDelList, oMapLig:cValue("ID"))
				endif

				oMapLig:_next()
			enddo
		endif

		//Exclui links inexistentes no client
		for nInd := 1 to len(aDelList)
			if oMapLig:lSeek(1, {aDelList[nInd]})
			
				if !oMapLig:lDelete()
					nStatus := KPI_ST_INUSE
					EXIT
				endif

			endif
		next
	endif

	//Exluir perspectivas que não estão mais presentes no XML
	if nStatus == KPI_ST_OK	
		aDelList := {}
		aDelAux := {}
				
		if oMapPer:lSeek(2, {cId})
			while !oMapPer:lEof() .and. oMapPer:cValue("MAPAESTID") == cId
				//Verifica se ID do banco está presente na lista enviada pelo client
				if aScan(aIdPerspec, {|x| x[2] == oMapPer:cValue("ID")}) == 0
					aAdd(aDelList, oMapPer:cValue("ID"))
					
					//remove todos os elementos filhos da perspectiva excluída
					if oMapElem:lSeek(2, {oMapPer:cValue("ID")})
						while oMapElem:cValue("MAPAPERID") == oMapPer:cValue("ID")
							aAdd(aDelAux, oMapElem:cValue("ID"))
							oMapElem:_next()
						enddo
					endif
				else
					//Exluir elementos que não estão mais presentes no XML
					if oMapElem:lSeek(2, {oMapPer:cValue("ID")})
						while !oMapElem:lEof() .and. oMapElem:cValue("MAPAPERID") == oMapPer:cValue("ID")
							//Verifica se ID do banco está presente na lista enviada pelo client
							if aScan(aIdElement, {|x| x[2] == oMapElem:cValue("ID")}) == 0
								aAdd(aDelAux, oMapElem:cValue("ID"))
							endif

							oMapElem:_next()
						enddo
					endif
				endif

				oMapPer:_next()
			enddo
		endif

		//Exclui perspectivas inexistentes no client
		for nInd := 1 to len(aDelList)
			if oMapPer:lSeek(1, {aDelList[nInd]})

				if !oMapPer:lDelete()
					nStatus := KPI_ST_INUSE
					EXIT
				endif

			endif
		next
           
		//Exlui elementos inexistentes no client
		if nStatus == KPI_ST_OK
			for nInd := 1 to len(aDelAux)
				if oMapElem:lSeek(1, {aDelAux[nInd]})
					if !oMapElem:lDelete()
						nStatus := KPI_ST_INUSE
						EXIT
					endif
				endif
			next 
		endif
	endif

	//Commit/Rollback
	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

	::oOwner():oOltpController():lEndTransaction()

return nStatus

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} aUpdMapStruc
Atualiza entidade ja existente

@author	BI TEAM
@version	P11 
@since		26/09/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdMapStruc(cIdEstrategia, cType) class TKPI011
	local aMap			:= {}
	local aObj			:= {}
	local aObjOld		:= {}
	local aFields		:= {}
	local nInd			:= 0
	local nInd2	   		:= 0
	local cIdPersp	 	:= ""
	local cIdMapEst		:= ""
	local cIdMapPer		:= ""
	local cIdMapObj		:= ""
	local lAllObj 		:= .F.

	local oScorecard	:= ::oOwner():oGetTable("SCORECARD")
	local oMapPer		:= ::oOwner():oGetTable("MAPAPERSPECTIVA")
	local oMapLig		:= ::oOwner():oGetTable("MAPALIGACAO")
	local oMapElem		:= ::oOwner():oGetTable("MAPAELEMENTO")
	local oMapObj		:= ::oOwner():oGetTable("MAPAOBJETIVO")

	local nStatus		:= KPI_ST_OK

	default cType	:= MAP_MODEL1

	//localiza estratégia
	if oScorecard:lSeek(1, {cIdEstrategia})

		::oOwner():oOltpController():lBeginTransaction()

		//verifica se existe o mapa
		if !::lSeek(3, {cType, cIdEstrategia})
			//cria novo registro
			aFields := ::xRecord(RF_ARRAY, {"ID", "ESTRATID", "QTDDIVISAO", "DIVISAO1", "TYPE"})
	
			cIdMapEst := ::cMakeId()
	
			aAdd(aFields, {"ID", cIdMapEst}) 
			aAdd(aFields, {"ESTRATID", cIdEstrategia}) 
			aAdd(aFields, {"QTDDIVISAO", 1})
			aAdd(aFields, {"DIVISAO1", oScorecard:cValue("NOME")})
			aAdd(aFields, {"TYPE", cType})
	
			//mapa estratégico
			if !::lAppend(aFields)
				if ::nLastError()==DBERROR_UNIQUE
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			endif
		else
			cIdMapEst := ::cValue("ID")
		endif

		if nStatus == KPI_ST_OK
			aMap := {}
			
			//Mapa modelo 2 -> apenas uma lista de objetivos
			if cType == MAP_MODEL2
				aAdd(aMap, {"", .F., aObj, ""})
			endif
		
			//Perspectivas do Mapa
			oScorecard:lSeek(2, {cIdEstrategia})
			while !oScorecard:lEof() .and. oScorecard:cValue("PARENTID") == cIdEstrategia
				cIdPersp := oScorecard:cValue("ID")
		
				//Mapa modelo 1 -> lista de objetivos agrupados por perspectiva
				if cType == MAP_MODEL1
					aObj := {}
					aAdd(aMap, {oScorecard:cValue("ID"), .F., aObj, ""})
				endif
		
				oScorecard:savePos()
		
				//Objetivos da perspectiva
				oScorecard:lSeek(2, {cIdPersp})
		
				while !oScorecard:lEof() .and. oScorecard:cValue("PARENTID") == cIdPersp
					aAdd(aObj, {oScorecard:cValue("ID"), .F.})
					
					oScorecard:_next()
				enddo
		
				oScorecard:restPos()
				oScorecard:_next()
			enddo
		
			for nInd := 1 to len(aMap)
				aObj := aMap[nInd][3]
		
				lAllObj := .F.
		
				if !Empty(aMap[nInd][1])
					//Modelo 1 - n perspectivas
					//verifica presença da perspectiva no mapa
					if !oMapPer:lSeek(3, {cIdMapEst, aMap[nInd][1]})
						//indica que a perspectiva deve ser adicionada ao mapa
						aMap[nInd][2] := .T.
						lAllObj := .T.
					endif
				else
					//Modelo 2 - apenas 1 perspectiva por mapa
					if !oMapPer:lSeek(2, {cIdMapEst})
						aMap[nInd][2] := .T.
						lAllObj := .T.
					endif
				endif
		
				if lAllObj
					for nInd2 := 1 to len(aObj)
						aObj[nInd2][2] := .T.
					next
				else
					aMap[nInd][4] := oMapPer:cValue("ID")
				
					aObjOld := {}
		            
					//verifica quais são os objetivos cadastrados atualmente
					oMapElem:lSeek(2, {oMapPer:cValue("ID")})
					while !oMapElem:lEof() .and. oMapElem:cValue("MAPAPERID") == oMapPer:cValue("ID")
						if !oMapElem:lEof() .and. oMapElem:cValue("TYPE") == ELM_OBJETIVO
							if oMapObj:lSeek(1, {oMapElem:cValue("ID")})
								aAdd(aObjOld, oMapObj:cValue("OBJETIVOID"))
							endif
						endif
		
						oMapElem:_next()
					enddo
		
					for nInd2 := 1 to len(aObj)
						//Verifica se os objetivos da perspectiva atual estão no mapa
						if aScan(aObjOld, {|x| x==aObj[nInd2][1]}) == 0
							aObj[nInd2][2] := .T.
						endif
					next			
				endif
			next		
		
		
		
			//verifica inclusões necessárias (exclusões serão tratados durante carga dos registros)
			for nInd := 1 to len(aMap)

				//Cria perspectiva
				if aMap[nInd][2]
					cIdMapPer := oMapPer:cMakeId()
	
					aFields := oMapPer:xRecord(RF_ARRAY, {"ID", "MAPAESTID", "PERSPECTID", "HEIGHT", "FONTCOLOR", "BACKCOLOR"})
	
					aAdd(aFields, {"ID"			, cIdMapPer}) 
					aAdd(aFields, {"MAPAESTID"	, cIdMapEst})
					aAdd(aFields, {"FONTCOLOR"	, 0})
					aAdd(aFields, {"BACKCOLOR"	, 16777215})
					aAdd(aFields, {"PERSPECTID"	, aMap[nInd][1]})
					aAdd(aFields, {"HEIGHT"		, 160})

					//mapa perspectiva
					if !oMapPer:lAppend(aFields)
						if oMapPer:nLastError()==DBERROR_UNIQUE
							nStatus := KPI_ST_UNIQUE
						else
							nStatus := KPI_ST_INUSE
						endif

						EXIT
					endif
				else
					cIdMapPer := aMap[nInd][4]
				endif
				
				aObj := aMap[nInd][3]
				
				for nInd2 := 1 to len(aObj)
					//Cria objetivo
					if aObj[nInd2][2]
						cIdMapObj := oMapElem:cMakeId()

						aFields := oMapElem:xRecord(RF_ARRAY, {"ID", "MAPAPERID", "WIDTH", "HEIGHT", "OPAQUE", "BACKCOLOR", "FONTCOLOR", "SHAPE", "TYPE", "POSX", "POSY"})

						aAdd(aFields, {"ID"			, cIdMapObj}) 
						aAdd(aFields, {"MAPAPERID"	, cIdMapPer}) 
						aAdd(aFields, {"POSX"		, -1}) 
						aAdd(aFields, {"POSY"		, -1})
						aAdd(aFields, {"WIDTH"		, 70}) 
						aAdd(aFields, {"HEIGHT"		, 70})       
						aAdd(aFields, {"OPAQUE"		, .T.})
						aAdd(aFields, {"BACKCOLOR"	, 16777215})
						aAdd(aFields, {"FONTCOLOR"	, 0})
						aAdd(aFields, {"SHAPE"		, SHP_RECT})
						aAdd(aFields, {"TYPE"		, ELM_OBJETIVO})

						//mapa elemento
						if !oMapElem:lAppend(aFields)
							if oMapElem:nLastError()==DBERROR_UNIQUE
								nStatus := KPI_ST_UNIQUE
							else
								nStatus := KPI_ST_INUSE
							endif
						endif

						if nStatus == KPI_ST_OK
							aFields := oMapObj:xRecord(RF_ARRAY, {"ID", "OBJETIVOID"})

							aAdd(aFields, {"ID"			, cIdMapObj}) 
							aAdd(aFields, {"OBJETIVOID"	, aObj[nInd2][1]}) 

							//mapa elemento
							if !oMapObj:lAppend(aFields)
								if oMapObj:nLastError()==DBERROR_UNIQUE
									nStatus := KPI_ST_UNIQUE
								else
									nStatus := KPI_ST_INUSE
								endif
							endif
						endif
                        
						if !(nStatus == KPI_ST_OK)
							EXIT
						endif

					endif
				next

				if !(nStatus == KPI_ST_OK)
					EXIT
				endif
			next
		endif

		//Commit/Rollback
		if nStatus != KPI_ST_OK
			::oOwner():oOltpController():lRollback()
		endif

		::oOwner():oOltpController():lEndTransaction()
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
method lDelete() class TKPI011

	local lOk := .T.
	local oMapPer := ::oOwner():oGetTable("MAPAPERSPECTIVA")
	local oMapLig := ::oOwner():oGetTable("MAPALIGACAO")

	local oFile			:= nil
	local aFilesDel		:= {}
	local cPathImages	:= ::oOwner():cKpiPath() + "\imagens\"
	local cFilePath		:= ""
	local cSearchPath	:= ""
	local nInd			:= 0


	//Inicia transação	
	::oOwner():oOltpController():lBeginTransaction()

	//Elimina perspectivas
	while lOk .and. oMapPer:lSeek(2, {::cValue("ID")})
    	lOk := oMapPer:lDelete()
	enddo

	//Elimina ligações
	while lOk .and. oMapLig:lSeek(2, {::cValue("ID")})
    	lOk := oMapLig:lDelete()
	enddo

	//Elimina mapa
	if lOk
		cFilePath := cPathImages + "map." + ::cValue("ID") + "\"
		cSearchPath := cFilePath + "*.*"
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

		dirRemove(cFilePath) 
	endif

return lOk

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oGetStObj
Retorna status dos objetivos

@author		BI TEAM
@version	P11 
@since		28/11/2011
/*/
//-------------------------------------------------------------------------------------
method oGetStObj(cId, dDataAlvo, cIdTheme) class TKPI011

	local oScoring	:= ::oOwner():oGetTable("SCORECARDING")
	local oSituacao	:= nil
	local oNode		:= nil
	local oXmlNode	:= nil
	local oNodeAux	:= nil
	local oMapPer	:= ::oOwner():oGetTable("MAPAPERSPECTIVA")
	local oMapElm	:= ::oOwner():oGetTable("MAPAELEMENTO")
	local oMapObj	:= ::oOwner():oGetTable("MAPAOBJETIVO")
	local oTemaXObj	:= ::oOwner():oGetTable("TEMAXOBJETIVO")
	local nX		:= 0  
	local nInd		:= 0
	local aObj		:= {}
	local aObjAux	:= {}
	local aFltObj	:= {}
	local lVisible	:= .F.
	local cIdObj	:= ""

	default dDataAlvo := date()
	default cIdTheme := "0"

	//Se informado ID, posiciona a entidade	
	if valtype(cId) == "C" .and. !empty(cId)
		::lSeek(1, {cId})
	endif

	//Filtra por tema estratégico
	if !cIdTheme == "0"
		aFltObj := oTemaXObj:aNodeSelect(cIdTheme)
	endif

	//percorre perspectivas
	oMapPer:lSeek(2, {::cValue("ID")})
	while !oMapPer:lEof() .and. oMapPer:cValue("MAPAESTID") == ::cValue("ID")

		//percorre objetivos da perspectiva
		oMapElm:lSeek(3, {ELM_OBJETIVO, oMapPer:cValue("ID")})
		while	!oMapElm:lEof() ;
				.and. oMapElm:cValue("MAPAPERID") == oMapPer:cValue("ID") ;
				.and. oMapElm:cValue("TYPE") == ELM_OBJETIVO

			if oMapObj:lSeek(1, {oMapElm:cValue("ID")})

				cIdObj := oMapObj:cValue("OBJETIVOID")
		
				lVisible := (cIdTheme == "0") .or. (aScan(aFltObj, {|x| x == cIdObj}) > 0)

				aAdd(aObj, cIdObj)
				aAdd(aObjAux, {oMapObj:cValue("ID"), cIdObj, lVisible})

			endif

			oMapElm:_Next()
		enddo

		oMapPer:_Next()
	enddo

	oXmlRet := TBIXMLNode():New("LISTA")

	oXmlNode := oXmlRet:oAddChild(TBIXMLNode():New("MAPAOBJETIVOS_STATUS"))

	oSituacao := oScoring:oToXMLScoStatus({}, aObj, dDataAlvo)

	for nX := 1 To oSituacao:nChildCount()
   		oNodeAux := oSituacao:oChildByPos(nX)

   		nInd := aScan(aObjAux, {|x| x[2] == oNodeAux:oChildByName("ID"):cGetValue()})

		if nInd > 0
	  		oNode := TBIXMLNode():New("MAPAOBJETIVO_STATUS")
			oNode:oAddChild(TBIXMLNode():New("MAPAOBJETIVO_ID"	, aObjAux[nInd][1]))
			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_STATUS"	, oNodeAux:oChildByName("STATUS_DATAALVO"):nGetValue()))
			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_VISIBLE"	, aObjAux[nInd][3]))

			oXmlNode:oAddChild(oNode)
		endif
	next

return oXmlRet
          

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oGetObjCause
Retorna relação causa entre objetivos

@author		BI TEAM
@version	P11 
@since		01/03/2012
/*/
//-------------------------------------------------------------------------------------
method aGetObjCause(cIdObj, dDataAlvo) class TKPI011

	local oScoring	:= ::oOwner():oGetTable("SCORECARDING")
	local oSituacao	:= nil
	local oNodeAux	:= nil
	local nX		:= 0  
	local nInd		:= 0
	local aObj		:= {}
	local aObjAux	:= {}
	local cAlias	:= getNextAlias()
	local aRet		:= {}
	local cCadObj	:= CAD_OBJETIVO
	local cElmObj	:= ELM_OBJETIVO
	local cMapModel	:= MAP_MODEL1

	default dDataAlvo := date()

	BeginSQL Alias cAlias
		SELECT SGI010_3.ID, 
               SGI010_3.NOME
		FROM   SGI011C
		       JOIN SGI010
		         ON SGI010.ID = SGI011C.OBJETIVOID
		            AND SGI010.TIPOSCORE = %exp:cCadObj%
		            AND SGI010.%notDel%
		       JOIN SGI010 SGI010_2
		         ON SGI010_2.ID = SGI010.PARENTID
		            AND SGI010_2.%notDel%
		       JOIN SGI011B
		         ON SGI011B.ID = SGI011C.ID
		            AND SGI011B.%notDel%
		            AND SGI011B.TYPE = %exp:cElmObj%
		       JOIN SGI011A
		         ON SGI011A.%notDel%
		            AND SGI011A.ID = SGI011B.MAPAPERID
		       JOIN SGI011
		         ON SGI011.%notDel%
		            AND SGI011.TYPE = %exp:cMapModel%
		            AND SGI011.ID = SGI011A.MAPAESTID
		            AND SGI011.ESTRATID = SGI010_2.PARENTID
		       JOIN SGI011D
		         ON SGI011D.%notDel%
		            AND SGI011D.MAPAESTID = SGI011.ID
		            AND SGI011D.DSTELMID IN ( SGI011C.ID, SGI011C.MAPAGRUPID )
		       JOIN SGI011C SGI011C_2
		         ON SGI011C_2.%notDel%
		            AND SGI011D.SRCELMID IN ( SGI011C_2.ID, SGI011C_2.MAPAGRUPID )
		       JOIN SGI010 SGI010_3
		         ON SGI010_3.%notDel%
		            AND SGI010_3.ID = SGI011C_2.OBJETIVOID
		WHERE  SGI011C.%notDel%
		       AND SGI011C.OBJETIVOID = %exp:cIdObj%
	EndSql

	(cAlias)->(dbGoTop())

	while (cAlias)->(!eof())
		aAdd(aObj, (cAlias)->ID)
		aAdd(aObjAux, {(cAlias)->ID, (cAlias)->NOME})
		
		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(dbCloseArea())

	oSituacao := oScoring:oToXMLScoStatus({}, aObj, dDataAlvo)

	for nX := 1 To oSituacao:nChildCount()
   		oNodeAux := oSituacao:oChildByPos(nX)

   		nInd := aScan(aObjAux, {|x| x[1]==oNodeAux:oChildByName("ID"):cGetValue()})

		if nInd > 0
			aAdd(aRet, {aObjAux[nInd][1], ;
						aObjAux[nInd][2], ;
						oNodeAux:oChildByName("STATUS_DATAALVO"):nGetValue()})
		endif

	next

return aRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oGetObjEffect
Retorna relação efeito entre objetivos

@author		BI TEAM
@version	P11 
@since		02/03/2012
/*/
//-------------------------------------------------------------------------------------
method aGetObjEffect(cIdObj, dDataAlvo) class TKPI011

	local oScoring	:= ::oOwner():oGetTable("SCORECARDING")
	local oSituacao	:= nil
	local oNodeAux	:= nil
	local nX		:= 0  
	local nInd		:= 0
	local aObj		:= {}
	local aObjAux	:= {}
	local cAlias	:= getNextAlias()
	local aRet		:= {}
	local cCadObj	:= CAD_OBJETIVO
	local cElmObj	:= ELM_OBJETIVO
	local cMapModel	:= MAP_MODEL1

	default dDataAlvo := date()

	BeginSQL Alias cAlias
		SELECT SGI010_3.ID, 
               SGI010_3.NOME
		FROM   SGI011C
		       JOIN SGI010
		         ON SGI010.ID = SGI011C.OBJETIVOID
		            AND SGI010.TIPOSCORE = %exp:cCadObj%
		            AND SGI010.%notDel%
		       JOIN SGI010 SGI010_2
		         ON SGI010_2.ID = SGI010.PARENTID
		            AND SGI010_2.%notDel%
		       JOIN SGI011B
		         ON SGI011B.ID = SGI011C.ID
		            AND SGI011B.%notDel%
		            AND SGI011B.TYPE = %exp:cElmObj%
		       JOIN SGI011A
		         ON SGI011A.%notDel%
		            AND SGI011A.ID = SGI011B.MAPAPERID
		       JOIN SGI011
		         ON SGI011.%notDel%
		            AND SGI011.TYPE = %exp:cMapModel%
		            AND SGI011.ID = SGI011A.MAPAESTID
		            AND SGI011.ESTRATID = SGI010_2.PARENTID
		       JOIN SGI011D
		         ON SGI011D.%notDel%
		            AND SGI011D.MAPAESTID = SGI011.ID
		            AND SGI011D.SRCELMID IN ( SGI011C.ID, SGI011C.MAPAGRUPID )
		       JOIN SGI011C SGI011C_2
		         ON SGI011C_2.%notDel%
		            AND SGI011D.DSTELMID IN ( SGI011C_2.ID, SGI011C_2.MAPAGRUPID )
		       JOIN SGI010 SGI010_3
		         ON SGI010_3.%notDel%
		            AND SGI010_3.ID = SGI011C_2.OBJETIVOID
		WHERE  SGI011C.%notDel%
		       AND SGI011C.OBJETIVOID = %exp:cIdObj%
		GROUP BY SGI010_3.ID, SGI010_3.NOME
	EndSql

	(cAlias)->(dbGoTop())

	while (cAlias)->(!eof())
		aAdd(aObj, (cAlias)->ID)
		aAdd(aObjAux, {(cAlias)->ID, (cAlias)->NOME})
		
		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(dbCloseArea())

	oSituacao := oScoring:oToXMLScoStatus({}, aObj, dDataAlvo)

	for nX := 1 To oSituacao:nChildCount()
   		oNodeAux := oSituacao:oChildByPos(nX)

   		nInd := aScan(aObjAux, {|x| x[1]==oNodeAux:oChildByName("ID"):cGetValue()})

		if nInd > 0
			aAdd(aRet, {aObjAux[nInd][1], ;
						aObjAux[nInd][2], ;
						oNodeAux:oChildByName("STATUS_DATAALVO"):nGetValue()})
		endif

	next

return aRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oGetObjRel
Retorna XML com relações causa e efeito de determinado indicador e seus indicadores.

@author		BI TEAM
@version	P11 
@since		02/03/2012
/*/
//-------------------------------------------------------------------------------------
method oGetObjRel(cIdObj, dDataAlvo, dAcumDe, dAcumAte) class TKPI011

	local oXmlNode		:= nil
	local oXmlAux		:= nil
	local oNode			:= nil
	local oNodeAux		:= nil
	local oScore		:= ::oOwner():oGetTable("SCORECARD")
	local oScoring		:= ::oOwner():oGetTable("SCORECARDING")
	local oSituacao 	:= nil
	local oAttrib		:= nil
	local aAux			:= {}
	local nInd			:= 0

	default dDataAlvo	:= date()
	default dAcumDe		:= dDataAlvo
	default dAcumAte	:= dDataAlvo

	oAttrib := TBIXMLAttrib():New()
	oXmlNode := TBIXMLNode():New("OBJETIVOS_RELACAO",,oAttrib)

	if oScore:lSeek(1, {cIdObj})
		//Dados do objetivo
		oAttrib:lSet("OBJETIVO_ID", cIdObj)
		oAttrib:lSet("OBJETIVO_NOME", alltrim(oScore:cValue("NOME")))

		oSituacao := oScoring:oToXMLScoStatus({}, {cIdObj}, dDataAlvo)

		if oSituacao:nChildCount() > 0
	   		oNodeAux := oSituacao:oChildByPos(1)

			oAttrib:lSet("OBJETIVO_STATUS", oNodeAux:oChildByName("STATUS_DATAALVO"):nGetValue())
		else
			oAttrib:lSet("OBJETIVO_STATUS", ESTAVEL_GRAY)
		endif

		//Perspectiva
		oScore:lSeek(1, {oScore:cValue("PARENTID")})
		oAttrib:lSet("PERSPECTIVA_ID"	, oScore:cValue("ID"))
		oAttrib:lSet("PERSPECTIVA_NOME"	, alltrim(oScore:cValue("NOME")))

		//Estratégia
		oScore:lSeek(1, {oScore:cValue("PARENTID")})
		oAttrib:lSet("ESTRATEGIA_ID"	, oScore:cValue("ID"))
		oAttrib:lSet("ESTRATEGIA_NOME"	, alltrim(oScore:cValue("NOME")))

		//Organizacao
		oScore:lSeek(1, {oScore:cValue("PARENTID")})
		oAttrib:lSet("ORGANIZACAO_ID"	, oScore:cValue("ID"))
		oAttrib:lSet("ORGANIZACAO_NOME"	, alltrim(oScore:cValue("NOME")))
			
		//Causas
		aAux := ::aGetObjCause(cIdObj, dDataAlvo)
		oXmlAux := oXmlNode:oAddChild(TBIXMLNode():New("CAUSAS"))

		for nInd := 1 to len(aAux)
			oNode := oXmlAux:oAddChild(TBIXMLNode():New("CAUSA"))

			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_ID"		, aAux[nInd][1]))
			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_NOME"	, alltrim(aAux[nInd][2])))
			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_STATUS"	, aAux[nInd][3]))
		next

		//Efeitos
		aAux := ::aGetObjEffect(cIdObj, dDataAlvo)
		oXmlAux := oXmlNode:oAddChild(TBIXMLNode():New("EFEITOS"))

		for nInd := 1 to len(aAux)
			oNode := oXmlAux:oAddChild(TBIXMLNode():New("EFEITO"))

			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_ID"		, aAux[nInd][1]))
			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_NOME"	, alltrim(aAux[nInd][2])))
			oNode:oAddChild(TBIXMLNode():New("OBJETIVO_STATUS"	, aAux[nInd][3]))
		next

		//Indicadores
		oXmlAux := oXmlNode:oAddChild(TBIXMLNode():New("INDICADORES"))
		oScoring:lAddIndicador(cIdObj, "SCORECARD", oXmlAux, {dDataAlvo, dDataAlvo, dAcumDe, dAcumAte}, cIdObj, {})
	endif

return oXmlNode


/*-------------------------------------------------------------------------------------
@method nExecute(cID, cExecCMD)
Define operação a ser executada
@cID 	- ID do registro
@cExecCMD - comando que será executado
--------------------------------------------------------------------------------------*/   
method nExecute(cID, cExecCMD) class TKPI011       
local nStatus := KPI_ST_OK
local aParam := aBIToken(cExecCMD, "|")    
	do case
		case aParam[1] == "MOVEFILE"
			::moveFile(aParam[2],aParam[3])
		case aParam[1] == "DELFILE"
			::delFile(aParam[2])
	endcase	
return nStatus         


/*-------------------------------------------------------------------------------------
@method moveFile(cNameFile, cPathDest)
Deletar arquivo no servidor
@cNameFile 	- Caminho e nome do arquivo    
@cPathDest  - Caminho destino do arquivo
--------------------------------------------------------------------------------------*/   
method moveFile(cNameFile, cPathDest) class TKPI011    
local cPath := ::oOwner():cKpiPath()
local oFile := TBIFileIO():New(cPath + cNameFile )  
local nStatus := KPI_ST_OK
	if oFile:lCopyFile( right(cNameFile, len(cNameFile) - rat("\", cNameFile)), cPath + cPathDest)
		::delFile(cNameFile)
	endif
return nStatus            

/*-------------------------------------------------------------------------------------
@method delFile(cNameFile)
Deletar arquivo no servidor
@cNameFile 	- Caminho e nome do arquivo 
--------------------------------------------------------------------------------------*/                                
method delFile(cNameFile) class TKPI011    
local oFile := TBIFileIO():New(::oOwner():cKpiPath() + "\" + cNameFile )     
local nStatus := KPI_ST_OK
	if oFile:lExists() 
		oFile:lErase()
	endif
return nStatus                       

//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oProcCmd
Processa e distribui comandos

@author		BI TEAM
@version	P11 
@since		12/12/2011
/*/
//-------------------------------------------------------------------------------------
method oProcCmd(oCmd) class TKPI011

	local oXmlRet := nil

	do case
		//Status dos Objetivos
		case oCmd:_MAPACMD:TEXT == "STOBJETIVOS"
			oXmlRet := ::oGetStObj(xBIConvTo("C", oCmd:_MAPAESTID:TEXT), xBIConvTo("D", oCmd:_DATAALVO:TEXT), xBIConvTo("C", oCmd:_TEMA:TEXT))

		//Relação de Causa / Efeito entre Objetivos
		case oCmd:_MAPACMD:TEXT == "CEOBJETIVOS"
			oXmlRet := ::oGetObjRel(xBIConvTo("C", oCmd:_OBJETIVOID:TEXT), xBIConvTo("D", oCmd:_DATAALVO:TEXT), xBIConvTo("D", oCmd:_DATAACUMDE:TEXT), xBIConvTo("D", oCmd:_DATAACUMATE:TEXT))

	endcase

return oXmlRet

//-------------------------------------------------------------------------------------
function _KPI011_MAPEST()
return nil