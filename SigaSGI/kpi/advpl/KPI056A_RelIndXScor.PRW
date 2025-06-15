// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI056A_RelIndXScor.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.10.11 | Tiago Tudisco       
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI056A_IndRelXScor.ch"

/*--------------------------------------------------------------------------------------
@class TKPI056A
@entity RELINDXSCOR
Objeto que representa os Scorecards do relatorio de indicadores
@table KPI056A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "RELINDXSCOR"
#define TAG_GROUP  "RELINDXSCOR"
#define TEXT_ENTITY STR0001/* "Indicador / Scorecard "   */
#define TEXT_GROUP  STR0002/* "Indicadores / Scorecard " */

Class TKPI056A From TBITable
  
	Method New() constructor
	Method NewKPI056A()

	//Multiplos registros
	Method oToXMLList(cParentID)
	Method nInsFromXML(cApresID,oXML)
	Method nUpdFromXML(cApresID,oXML)
	Method nDelFromXML(cApresID)      
	Method aNodeSelect(cId)

EndClass
           
/*--------------------------------------
* CONSTRUTOR
*--------------------------------------*/
Method New() Class TKPI056A
	::NewKPI056A()
Return
Method NewKPI056A() Class TKPI056A

	// Table
	::NewTable("SGI056A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_RELIND"	,"C"	,10))//Id do relatorio de indicacao.
	::addField(TBIField():New("ID_SCOREC"	,"C"	,10))//Id do scorecard.

	// Indexes
	::addIndex(TBIIndex():New("SGI056AI1",	{"ID"					}	,.T.))
	::addIndex(TBIIndex():New("SGI056AI2",	{"ID_RELIND","ID_SCOREC"}	,.T.))
	::addIndex(TBIIndex():New("SGI056AI3",	{"ID_SCOREC"			}	,.F.))
	
Return            
          
/*--------------------------------------
* LISTA XML PARA ANEXAR AO PAI
* @Param cParentId
*-------------------------------------*/              
Method oToXMLList(cParentId) Class TKPI056A
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
	
	// GERA RECHEIO
	::SetOrder(1)
	::cSQLFilter("ID_RELIND = '"+cBIStr(cParentId)+"'") // FILTRA PELO PAI
	::lFiltered(.T.)
	::_First()
    oScorecard := ::oOwner():oGetTable("SCORECARD")
	While(!::lEof())
	
		aFields := ::xRecord(RF_ARRAY, {"ID","ID_RELIND"})
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		For nInd := 1 To Len(aFields)
			If(aFields[nInd][1] == "ID_SCOREC")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))
			Else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			EndIf
		Next

		::_Next()
	End
	::cSQLFilter("") // ENCERRA FILTRO

Return oXMLNode         
         
/*--------------------------------------
* INSERE A ENTIDADE NO SERVER
* @Param cIndId - ID do Relatorio
* @oXML			- XML
*-------------------------------------*/
Method nInsFromXML(cIndID,oXml, nItem) class TKPI056A

	Local aFields,nInd,nItens ,nStatus 	:= KPI_ST_OK, cScoreID
	Private oXmlInput 					:= oXml

	aFields := ::xRecord(RF_ARRAY, {"ID_SCOREC","ID_RELIND"})

	// EXTRAI VALORES DO XML
	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		If(Valtype(oXmlInput)=="O")
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXmlInput["+alltrim(str(nItem))+"]:_"+aFields[nInd][1]+":TEXT"))
		endif
		if(aFields[nInd][1] == "ID")
			aAdd( aFields, {"ID_SCOREC", aFields[nInd][2]})
			cScoreId := aFields[nInd][2]
			aFields[nInd][2] := ::cMakeID()
		endif
	Next

	aAdd( aFields, {"ID_RELIND", cIndID})

	// GRAVA
    If(!::lSeek(2,{cIndID, cScoreId}) .and. !Empty(cScoreId))
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
* FAZ A ATUALIZACAO DOS TEMAS GRAVADOS
* @Param cIndId - ID do Relatorio
* @oXML			- XML
*-------------------------------------*/
Method nUpdFromXML(cIndID,oXML) Class TKPI056A

	Local 	aFields, nStatus 	:= KPI_ST_OK
	Local 	nFoundItem, aItemOk := {} , nItem := 0, nInd := 0
	Private aObj 				:= oXml

	If(Valtype(aObj)!="A")
		aObj := { aObj }
	Endif	
    ::setOrder(2)
    ::lSoftSeek(2,{cIndID})
	While(!::lEof() .And. Alltrim(::cValue("ID_RELIND")) == cIndID)
		nFoundItem := aScan(aObj,{|x| x:_ID:TEXT == Alltrim(::cValue("ID_SCOREC"))})

		If(nFoundItem > 0)
			aAdd(aItemOk, nFoundItem)
		EndIf			
		
		If(nFoundItem == 0)
			//Nao encontrou no XML apaga.
			If(!::lDelete())
				nStatus := KPI_ST_INUSE
				Exit							
			EndIf
		EndIf    
		
		::_Next()
	End

	For nItem := 1 To Len(aObj)
		nFoundItem := ascan(aItemOk , {|x| x == nItem})
		If nFoundItem == 0
			nStatus := ::nInsFromXML(cIndID, oXml, nItem)
		EndIf
	Next nItem

Return nStatus

/*--------------------------------------
* EXCLUIR ENTIDADES DO SERVER
* @Param cIndId - ID do Relatorio
*-------------------------------------*/
Method nDelFromXML(cIndID) Class TKPI056A

	nStatus := KPI_ST_OK

	::cSQLFilter("ID_RELIND = '" + cBIStr(cIndID)+"'")
	::lFiltered(.T.)
	::_First()
	while(!::lEof())
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
		::_Next()
	end
	::cSQLFilter("")

Return nStatus              

/*--------------------------------------
* MONTA ARRAR COM OS NODES SELECIONADOS
* @Param cId - ID do Node
*-------------------------------------*/
Method aNodeSelect(cId) Class TKPI056A
 
	Local aRet		:= {}   
    Local aPosicao 	:= ::SavePos()
    
    ::setOrder(2)
	//::_First() 
	::lSoftSeek(2,{cId})
	
	While (!::lEof() .And. ::cValue("ID_RELIND") == cId)
		
		aAdd(aRet,::cValue("ID_SCOREC"))
					   
		::_Next()
	End
              
	::RestPos(aPosicao)

Return aRet
                          
/*--------------------------------------
* FUNCTION
*--------------------------------------*/
Function _KPI056A_RelIndxScor()
Return Nil