// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI013A.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 05.11.11 | Tiago Tudisco
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#include "KPI013_TemaXObjetivo.ch"     

#define TAG_ENTITY "TEMAXOBJETIVO"
#define TAG_GROUP  "TEMASXOBJETIVOS"
#define TEXT_ENTITY STR0001		//###"Tema Estratégico"
#define TEXT_GROUP  STR0002		//###"Temas Estratégicos"

/*--------------------------------------------------------------------------------------
@class TKPI013A
@entity TemaXObjetivo
Temas Estrategicos
@table KPI013A
--------------------------------------------------------------------------------------*/
Class TKPI013A From TBITable

	Method New() constructor
	Method NewKPI013A()

	// Request
	Method oToXMLNode()
	Method oToXMLList()
	Method oToXMLRecList()
	
	// Create/Update/Delete
	Method nInsFromXML(oXML, cPath, cId)
	Method nDelFromXML()    
	
	Method aNodeSelect(cId)
	
EndClass


/*-------------------------------------------------------------------------------------------------------
*  CONSTRUTOR
*-------------------------------------------------------------------------------------------------------*/
Method New() Class TKPI013A
	::NewKPI013A()
Return
Method NewKPI013A() Class TKPI013A

	// Table
	::NewTable("SGI013A")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C", 010))
	::addField(TBIField():New("TEMAESTID"	,"C", 010))
	::addField(TBIField():New("OBJETIVOID"	,"C", 010))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI013AI01",{"ID"},.T.)) 
	::addIndex(TBIIndex():New("SGI013AI02",{"TEMAESTID"},.F.))
	::addIndex(TBIIndex():New("SGI013AI03",{"OBJETIVOID"},.F.))	   
	::addIndex(TBIIndex():New("SGI013AI04",{"TEMAESTID","OBJETIVOID"},.F.))	   	
	
Return     
                                         

/*--------------------------------------
* LISTA XML PARA ANEXAR AO PAI
* @Param cParentId
*-------------------------------------*/              
Method oToXMLList(cParentId) Class TKPI013A
	Local oNode, oAttrib, oXMLNode, nInd,oScorecard
	
	// COLUNAS
	oAttrib := TBIXMLAttrib():New()

	// TIPO
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .T.)
	// NOME
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	// GERA NO PRINCIPAL
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
    oScorecard := ::oOwner():oGetTable("SCORECARD")
	While(::lSeek(2,{cParentId}))
	
		aFields := ::xRecord(RF_ARRAY, {"ID","TEMAESTID"})
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		For nInd := 1 To Len(aFields)
			If(aFields[nInd][1] == "OBJETIVOID")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))
			Else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			EndIf
		Next

		::_Next()
	End

Return oXMLNode         


/*--------------------------------------
* INSERE A ENTIDADE NO SERVER
* @Param cTemaId - ID do Tema
* @oXML			- XML
*-------------------------------------*/
Method nInsFromXML(cTemaID,oXml) Class TKPI013A

	Local aFields
	Local nStatus := KPI_ST_OK
    Local cObjID
		
	Private oXmlInput := oXml
                
	cObjID := xBIConvTo("C", oXMLInput:_ID:TEXT)
	aFields := {}

	// GRAVA
    If(!::lSeek(4,{cTemaID, cObjID}) .and. !Empty(cObjID))

		// EXTRAI VALORES DO XML
		aAdd( aFields, {"ID", 			::cMakeId() })
		aAdd( aFields, {"TEMAESTID", 	cTemaID})
		aAdd( aFields, {"OBJETIVOID",	cObjID})

		If(!::lAppend(aFields))
			If(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			Else
				nStatus := KPI_ST_INUSE
			EndIf
		EndIf
	EndIf

Return nStatus
                                          

/*--------------------------------------
* EXCLUIR ENTIDADES DO SERVER
* @Param cId
*-------------------------------------*/
Method nDelFromXML(cID) Class TKPI013A
            
	//Se informado ID, posiciona a entidade	
	If ValType(cId) == "C" .and. !Empty(cId)
		::lSeek(1, {cId})
	Else
		cId := ::cValue("ID")
	EndIf 

	nStatus := KPI_ST_OK

	if(!::lDelete())
		nStatus := KPI_ST_INUSE
	endif

Return nStatus              


/*--------------------------------------
* MONTA ARRAR COM OS NODES SELECIONADOS
* @Param cId - ID do Node
*-------------------------------------*/
Method aNodeSelect(cId) Class TKPI013A
 
	Local aRet		:= {}   
    Local aPosicao 	:= ::SavePos()
    
    ::setOrder(2)
	::lSoftSeek(2,{cId})
	
	While (!::lEof() .And. ::cValue("TEMAESTID") == cId)
		
		aAdd(aRet,::cValue("OBJETIVOID"))
					   
		::_Next()
	End
              
	::RestPos(aPosicao)

Return aRet
                                      

/*--------------------------------------
* FUNCTION
*--------------------------------------*/
Function _KPI013A_TemaXObjetivo()
Return Nil