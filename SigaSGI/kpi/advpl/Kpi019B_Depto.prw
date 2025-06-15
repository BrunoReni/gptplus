// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI019B_Depto
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI019B_Depto.ch"
/*--------------------------------------------------------------------------------------
Pacotes, Permissão por departamento
@entity: Pacote
@table KPI019B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "PACOTEXDEPTO"
#define TAG_GROUP  "PACOTEXDEPTOS"
#define TEXT_ENTITY STR0001 //"Permissão de departamento"
#define TEXT_GROUP  STR0002 //"Permissão de departamentos"


class TKPI019B from TBITable
	method New() constructor
	method NewKPI019B()
    
	method nInsFromXML()
	method nDelFromXML() 
	method nUpdFromXML()
	
	method aNodeSelect()
endclass
	     
	
method New() class TKPI019B
	::NewKPI019B()
return
            

method NewKPI019B() class TKPI019B

	// Table
	::NewTable("SGI019B")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C",	010))
	::addField(TBIField():New("PACOTE_ID"	,"C",	010))
	::addField(TBIField():New("DEPTO_ID"	,"C",	010))

	// Indexes
	::addIndex(TBIIndex():New("SGI019BI01",{"ID"},	.T.))
	::addIndex(TBIIndex():New("SGI019BI02",{"DEPTO_ID"}, .F.))
	::addIndex(TBIIndex():New("SGI019BI03",{"PACOTE_ID", "DEPTO_ID"}, .F.))

return

         
/*--------------------------------------
* INSERE RELACIONAMENTO PACOTE X DEPTO
* @Param cParentId ID do Pacote
* @Param oXML XML com os dados
*-------------------------------------*/
Method nInsFromXML(cParentId, oXml) Class TKPI019B

	Local aFields	:= {}
	Local nStatus	:= KPI_ST_OK
	Local cScoreID	:= ""

	Private oXmlInput := oXml

	aFields := ::xRecord(RF_ARRAY, {"ID", "PACOTE_ID"})

	cScoreID := xBIConvTo("C", oXMLInput:_ID:TEXT)

	aAdd( aFields, {"DEPTO_ID"	, cScoreID} )
	aAdd( aFields, {"PACOTE_ID"	, cParentId} )

	// GRAVA
    If !::lSeek(3, {cParentId, cScoreID}) .and. !Empty(cScoreId)

		aAdd( aFields, {"ID", ::cMakeID()} )

		If !::lAppend(aFields)
			If ::nLastError() == DBERROR_UNIQUE
				nStatus := KPI_ST_UNIQUE
			Else
				nStatus := KPI_ST_INUSE
			EndIf
		EndIf
	EndIf

Return nStatus
                        

/*--------------------------------------
* ATUALIZA RELACIONAMENTO PACOTE X DEPTO
* @Param cParentId ID do Pacote
* @Param oXML XML com os dados
*-------------------------------------*/
Method nUpdFromXML(cParentId, oXML) Class TKPI019B

	Local aFields		:= {}
	Local aItemOk		:= {}
	Local nStatus		:= KPI_ST_OK
	Local nFoundItem	:= 0
	Local nItem			:= 0
	Local nInd			:= 0

	Private aObj := oXml

	If Valtype(aObj) != "A"
		aObj := { aObj }
	EndIf

    ::lSoftSeek(3, {cParentId})

	While !::lEof() .And. ::cValue("PACOTE_ID") == cParentId
		nFoundItem := aScan(aObj, {|x| x:_ID:TEXT == Alltrim(::cValue("DEPTO_ID"))})

		If nFoundItem > 0
			aAdd(aItemOk, nFoundItem)
		EndIf

		If nFoundItem == 0
			//Nao encontrou no XML apaga.
			If !::lDelete()
				nStatus := KPI_ST_INUSE
				Exit							
			EndIf
		EndIf    
		
		::_Next()
	EndDo

	If nStatus == KPI_ST_OK
		For nItem := 1 To Len(aObj)
	
			nFoundItem := ascan(aItemOk , {|x| x == nItem})
	
			If nFoundItem == 0
				nStatus := ::nInsFromXML(cParentId, aObj[nItem])
			EndIf
	
		Next nItem
	EndIf

Return nStatus
              

/*--------------------------------------
* EXCLUIR ENTIDADES DO SERVER
* @Param cParentId ID do Pacote
*-------------------------------------*/
Method nDelFromXML(cParentId) Class TKPI019B

	nStatus := KPI_ST_OK

	::cSQLFilter("PACOTE_ID = '" + cBIStr(cParentId) + "'")
	::lFiltered(.T.)
	::_First()

	While !::lEof()

		If !::lDelete()
			nStatus := KPI_ST_INUSE
		EndIf

		::_Next()
	EndDo

	::cSQLFilter("")

Return nStatus              
            

/*--------------------------------------
* MONTA ARRAR COM OS NODES SELECIONADOS
* @Param cParentId ID do Pacote
*-------------------------------------*/
Method aNodeSelect(cParentId) Class TKPI019B
 
	Local aRet		:= {}   
    Local aPosicao 	:= ::SavePos()

	::lSoftSeek(3, {cParentId})

	While !::lEof() .And. ::cValue("PACOTE_ID") == cParentId

		If !(alltrim(::cValue("ID")) == "0")
			aAdd(aRet, ::cValue("DEPTO_ID"))
		EndIf

		::_Next()
	EndDo

	::RestPos(aPosicao)

Return aRet


Function _KPI019B_Depto()
Return