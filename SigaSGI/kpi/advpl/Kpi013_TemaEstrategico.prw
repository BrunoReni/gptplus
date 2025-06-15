// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI013.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 29.11.11 | Tiago Tudisco
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#include "KPI013_TemaEstrategico.ch"     

#define TAG_ENTITY "TEMAESTRATEGICO"
#define TAG_GROUP  "TEMASESTRATEGICOS"
#define TEXT_ENTITY STR0001		//###"Tema Estratégico"
#define TEXT_GROUP  STR0002		//###"Temas Estratégicos"

/*--------------------------------------------------------------------------------------
@class TKPI013
@entity TemaEstrategico
Temas Estrategicos
@table KPI013
--------------------------------------------------------------------------------------*/
Class TKPI013 From TBITable

	Method New() constructor
	Method NewKPI013()

	// Request
	Method oToXMLNode()
	Method oToXMLList()
	Method oToXMLRecList()
	
	// Create/Update/Delete
	Method nInsFromXML(oXML, cPath, cId)
	Method nUpdFromXML(oXML, cPath)
	Method nDelFromXML(cID)

EndClass


/*-------------------------------------------------------------------------------------------------------
*  CONSTRUTOR
*-------------------------------------------------------------------------------------------------------*/
Method New() Class TKPI013
	::NewKPI013()
Return
Method NewKPI013() Class TKPI013

	// Table
	::NewTable("SGI013")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C", 010))
	::addField(TBIField():New("ESTRAT_ID"	,"C", 010))
	::addField(TBIField():New("NOME"		,"C", 060))
	::addField(TBIField():New("DESCRICAO"	,"C", 255))

	// Indexes
	::addIndex(TBIIndex():New("SGI013I01",{"ID"},.T.))
	::addIndex(TBIIndex():New("SGI013I02",{"ESTRAT_ID"},.F.))
	
Return     
           

/*-------------------------------------------------------------------------------------------------------
*  CARREGAR
*-------------------------------------------------------------------------------------------------------*/
Method oToXMLNode(cId, cEstId, lLoadChild) Class TKPI013
                           
	Local aFields 	:= {}
	Local nInd           
	Local aSelNode	:= {}	
	Local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	Local aEstId := {}
	
	Default lLoadChild := .T.

	//Se informado ID, posiciona a entidade	
	If ValType(cId) == "C" .and. !Empty(cId)
		::lSeek(1, {cId})
	Else
		cId := ::cValue("ID")
	EndIf         
	
	If ValType(cEstId) == "C" .and. !Empty(cEstId)
		aEstId := StrTokArr( cEstId, "|" )
		cEstId := aEstId[1]
	Else		
		cEstId := ::cValue("ESTRAT_ID")
	EndIf    
	
	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)

	For nInd := 1 To Len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	Next     

	If lLoadChild
		aSelNode := ::oOwner():oGetTable("TEMAXOBJETIVO"):aNodeSelect(cId)
		oXMLNode:oAddChild(::oOwner():oGetTable("SCORECARD"):oArvoreTema(cEstId, aSelNode))
	EndIf

Return oXMLNode

     
/*-------------------------------------------------------------------------------------------------------
*  LISTA XML PARA ANEXAR SO PAI
*-------------------------------------------------------------------------------------------------------*/
Method oToXMLList(cEstId, lLoadChild) Class TKPI013

	Local oNode
	Local oAttrib
	Local oXMLNode

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
	::lSeek(2,{cEstId})
	
	While(!::lEof() .And. ::cValue("ESTRAT_ID") == cEstId)

		If( !(alltrim(::cValue("ID")) == "0"))    
			//Adiciona nó com a entidade posicionada
			oNode := oXMLNode:oAddChild( ::oToXMLNode(,,lLoadChild) )
		EndIf

		::_Next()
	End           
	
Return oXMLNode


/*-------------------------------------------------------------------------------------------------------
*  LISTA XML PARA ANEXAR SO PAI
*-------------------------------------------------------------------------------------------------------*/
Method oToXMLRecList(cEstId, lLoadChild) Class TKPI013
	
	Local oXMLNodeLista := TBIXMLNode():New("LISTA")

	oXMLNodeLista:oAddChild( ::oToXMLList(cEstId, lLoadChild) )

Return oXMLNodeLista


/*-------------------------------------------------------------------------------------------------------
*  INSERE UM NOVO TEMA ESTRATEGICO
*-------------------------------------------------------------------------------------------------------*/
Method nInsFromXML(oXML, cPath, cId) Class TKPI013

	Local aFields	:= {}
	Local aIndTend	:= {}
	Local nStatus	:= KPI_ST_OK
	Local nInd,nQtdReg
	Local oTemaXObj := ::oOwner():oGetTable("TEMAXOBJETIVO")
	
	Private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	Next         
	
	cId := ::cMakeID()
	aAdd(aFields, {"ID", cId })


 	::oOwner():oOltpController():lBeginTransaction()

	// Grava
	If !::lAppend(aFields)
		
		If ::nLastError()==DBERROR_UNIQUE
			nStatus := KPI_ST_UNIQUE
		Else
			nStatus := KPI_ST_INUSE
		EndIf
		
	EndIf	
	
	If (nStatus == KPI_ST_OK)
	
		If(Valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD")) != "U")
	
			aRegNode := &("oXMLInput:"+cPath+":_SCORECARDS")//PEGANDO OS VALORES DA SCORECARDS

			If(Valtype(aRegNode:_SCORECARD) != "A")
				aObj := { aRegNode:_SCORECARD }
			Else
				aObj := aRegNode:_SCORECARD
			EndIf	

		
			For nQtdReg := 1 To Len(aObj)
				
				nStatus	:= oTemaXObj:nInsFromXML(cId, aObj[nQtdReg])
				
				If nStatus != KPI_ST_OK
					exit
				EndIf
			Next 
			
		EndIf
	
	EndIf

	if nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	endif

   	::oOwner():oOltpController():lEndTransaction()

Return nStatus


/*-------------------------------------------------------------------------------------------------------
*  ATUALIZA O TEMA ESTRATEGICO
*-------------------------------------------------------------------------------------------------------*/
Method nUpdFromXML(oXML, cPath) Class TKPI013

	Local nStatus 	:= KPI_ST_OK,	cID, nInd, oTable, cNome, nQtdReg, aObj := {}
	Local oTemaXObj := ::oOwner():oGetTable("TEMAXOBJETIVO")
						
	Private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY) 

	// EXTRAI VALORES DO XML
	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
		If(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		EndIf
	Next
            
	// VERIFICA CONDICOES DE GRAVACAO (APPEND OU UPDATE)
	::oOwner():oOltpController():lBeginTransaction()
	
	If(	::lSeek(1,{cId}) )
		If(!::lUpdate(aFields))
			If(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			Else
				nStatus := KPI_ST_INUSE
			EndIf
		EndIf	
	Else
		nStatus := KPI_ST_BADID
	EndIf          
	

    If nStatus == KPI_ST_OK

		//ATUALIZANDO OS VALORES DA SCORECARD
		If(Valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCORECARDS"), "_SCORECARD")) != "U")
	
			aRegNode := &("oXMLInput:"+cPath+":_SCORECARDS")//PEGANDO OS VALORES DA SCORECARDS
	
			If(Valtype(aRegNode:_SCORECARD) != "A")
				aObj := { aRegNode:_SCORECARD }
			Else
				aObj := aRegNode:_SCORECARD
			EndIf	

		    oTemaXObj:lSoftSeek(2,{cID})
			While(!oTemaXObj:lEof() .And. Alltrim(oTemaXObj:cValue("TEMAESTID")) == Alltrim(cID))
				nFoundItem := ascan(aObj,{|x| x:_ID:TEXT == Alltrim(oTemaXObj:cValue("OBJETIVOID"))})
				If(nFoundItem == 0)
						//NAO ENCONTROU NO XML APAGA.
					If(!oTemaXObj:lDelete())
						nStatus := KPI_ST_INUSE
						Exit							
					EndIf
				EndIf    
	
				oTemaXObj:_Next()
			End
			
			If nStatus == KPI_ST_OK
				
				If(Valtype(aRegNode:_SCORECARD) == "A")
					For nQtdReg := 1 To Len(aRegNode:_SCORECARD)
						nStatus	:= oTemaXObj:nInsFromXML(cId, aRegNode:_SCORECARD[nQtdReg])
						If(nStatus != KPI_ST_OK)
							Exit
						EndIf
					Next nQtdReg
				ElseIf(Valtype(aRegNode:_SCORECARD) == "O")
					nStatus	:= oTemaXObj:nInsFromXML(cId, aRegNode:_SCORECARD)
				EndIf   
			EndIf
							
		Else
			//CASO NAO ENCONTROU EXCLUI TUDO.
		    oTemaXObj:setOrder(2)
		    oTemaXObj:lSoftSeek(2,{cID})
			While(!oTemaXObj:lEof() .And. Alltrim(oTemaXObj:cValue("TEMAESTID")) == Alltrim(cID))
				//NAO ENCONTROU NO XML APAGA.
				If(!oTemaXObj:lDelete())
					nStatus := KPI_ST_INUSE
					Exit							
				EndIf
				oTemaXObj:_Next()
			End
		EndIf         

	EndIf   
	
	If nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	EndIf

	::oOwner():oOltpController():lEndTransaction()
					
Return nStatus 
                        
                            
/*-------------------------------------------------------------------------------------------------------
*  EXCLUI TEMA ESTRATEGICO
*-------------------------------------------------------------------------------------------------------*/
Method nDelFromXML(cID) Class TKPI013
	local nStatus	:= KPI_ST_OK 
	local oTemaXObj := ::oOwner():oGetTable("TEMAXOBJETIVO")


	//Se informado ID, posiciona a entidade	
	If ValType(cId) == "C" .and. !Empty(cId)
		::lSeek(1, {cId})
	Else
		cId := ::cValue("ID")
	EndIf 

	::oOwner():oOltpController():lBeginTransaction()	

	// Deleta o relacionamento
	While oTemaXObj:lSeek(2,{::cValue("ID")})
		
		nStatus := oTemaXObj:nDelFromXML()	
		If nStatus != KPI_ST_OK
			exit			
		EndIf
    
    End

	If nStatus == KPI_ST_OK
		if !::lDelete()
			nStatus := KPI_ST_INUSE
		endif
	EndIf

	If nStatus != KPI_ST_OK
		::oOwner():oOltpController():lRollback()
	EndIf

	::oOwner():oOltpController():lEndTransaction()
	
return nStatus


/*-------------------------------------------------------------------------------------------------------
*  FUNCTION
*-------------------------------------------------------------------------------------------------------*/
Function _KPI013_TemaEstrategico()
Return Nil