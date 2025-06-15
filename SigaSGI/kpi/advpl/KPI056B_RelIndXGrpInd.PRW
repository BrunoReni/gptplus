// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI056B_RelIndXGrpInd.PRW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 23.04.14 | Helio Leal        |
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Objeto que representa o Grupo de indicadores do relatório de indicadores.
@Class TKPI056B
@Entity RELINDXGRPIND
@table KPI056B
@Since 23/04/2014
@Author  Helio Leal.
/*/
//-------------------------------------------------------------------
#define TAG_ENTITY "RELINDXGRPIND"
#define TAG_GROUP  "RELINDXGRPIND"
#define TEXT_ENTITY "Grupo de indicador"
#define TEXT_GROUP  "Grupo de indicadores"

Class TKPI056B From TBITable
  
	Method New() constructor
	Method NewKPI056B()

	//Míltiplos registros
	Method oToXMLList(cParentID)
	Method nInsFromXML(cApresID,oXML)
	Method nUpdFromXML(cApresID,oXML)
	Method nDelFromXML(cApresID)      
	Method aNodeSelect(cId)

EndClass
           
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor
@Since 23/04/2014
@Author  Helio Leal.
/*/
//-------------------------------------------------------------------
Method New() Class TKPI056B
	::NewKPI056B()
Return

Method NewKPI056B() Class TKPI056B

	// Table
	::NewTable("SGI056B")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"			,"C"	,10))
	::addField(TBIField():New("ID_RELIND"	,"C"	,10))//Id do relatorio de indicacao.
	::addField(TBIField():New("ID_GRPIND"	,"C"	,10))//Id do Grupo de indicadores.

	// Indexes
	::addIndex(TBIIndex():New("SGI056BI1",	{"ID"					}	,.T.))
	::addIndex(TBIIndex():New("SGI056BI2",	{"ID_RELIND","ID_GRPIND"}	,.T.))
	::addIndex(TBIIndex():New("SGI056BI3",	{"ID_GRPIND"			}	,.F.))
	
Return            
          
//-------------------------------------------------------------------
/*/{Protheus.doc} oToXMLList
Lista XML para anexar ao pai.
@Param cParentId ID do pai.
@Since 23/04/2014
@Author  Helio Leal.
/*/
//-------------------------------------------------------------------        
Method oToXMLList(cParentId) Class TKPI056B
	Local oNode, oAttrib, oXMLNode, nInd,oGrpInd
	
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
    oGrpInd := ::oOwner():oGetTable("GRUPO_IND")
	While(!::lEof())
	
		aFields := ::xRecord(RF_ARRAY, {"ID","ID_RELIND"})
		
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		For nInd := 1 To Len(aFields)
			If(aFields[nInd][1] == "ID_GRPIND")
				oNode:oAddChild(TBIXMLNode():New("ID", aFields[nInd][2]))
			Else
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			EndIf
		Next

		::_Next()
	End
	::cSQLFilter("") // ENCERRA FILTRO

Return oXMLNode         
         
//-------------------------------------------------------------------
/*/{Protheus.doc} nInsFromXML
Insere a Entidade no Server.
@Param cIndId - ID do Relatorio
@Param oXML	- XML
@Since 23/04/2014
@Author  Helio Leal.
/*/
//------------------------------------------------------------------- 
Method nInsFromXML(cIndID,oXml, nItem) class TKPI056B

	Local aFields,nInd,nItens ,nStatus 	:= KPI_ST_OK, cScoreID
	Private oXmlInput 					:= oXml

	aFields := ::xRecord(RF_ARRAY, {"ID_GRPIND","ID_RELIND"})

	// EXTRAI VALORES DO XML
	For nInd := 1 To Len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		If(Valtype(oXmlInput)=="O")
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
		else
			aFields[nInd][2] := xBIConvTo(cType, &("oXmlInput["+alltrim(str(nItem))+"]:_"+aFields[nInd][1]+":TEXT"))
		endif
		if(aFields[nInd][1] == "ID")
			aAdd( aFields, {"ID_GRPIND", aFields[nInd][2]})
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

//-------------------------------------------------------------------
/*/{Protheus.doc} nUpdFromXML
Faz a atualização dos temas gravados.
@Param cIndId - ID do Relatorio
@Param oXML	- XML
@Since 23/04/2014
@Author  Helio Leal.
/*/
//------------------------------------------------------------------- 
Method nUpdFromXML(cIndID,oXML) Class TKPI056B

	Local 	aFields, nStatus 	:= KPI_ST_OK
	Local 	nFoundItem, aItemOk := {} , nItem := 0, nInd := 0
	Private aObj 				:= oXml

	If(Valtype(aObj)!="A")
		aObj := { aObj }
	Endif	
    ::setOrder(2)
    ::lSoftSeek(2,{cIndID})
	While(!::lEof() .And. Alltrim(::cValue("ID_RELIND")) == cIndID)
		nFoundItem := aScan(aObj,{|x| x:_ID:TEXT == Alltrim(::cValue("ID_GRPIND"))})

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

//-------------------------------------------------------------------
/*/{Protheus.doc} nDelFromXML
Deletar entidades do server.
@Param cIndId - ID do Relatorio
@Since 23/04/2014
@Author  Helio Leal.
/*/
//------------------------------------------------------------------- 
Method nDelFromXML(cIndID) Class TKPI056B

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

//-------------------------------------------------------------------
/*/{Protheus.doc} nDelFromXML
Monta array com os nodes selecionados.
@Param cId - ID do Node
@Since 23/04/2014
@Author  Helio Leal.
/*/
//------------------------------------------------------------------- 
Method aNodeSelect(cId) Class TKPI056B
 
	Local aRet		:= {}   
    Local aPosicao 	:= ::SavePos()
    
    ::setOrder(2)
	//::_First() 
	::lSoftSeek(2,{cId})
	
	While (!::lEof() .And. ::cValue("ID_RELIND") == cId)
		
		aAdd(aRet,::cValue("ID_GRPIND"))
					   
		::_Next()
	End
              
	::RestPos(aPosicao)

Return aRet
                          
//-------------------------------------------------------------------
/*/{Protheus.doc} _TKPI056B_RelIndxGrpInd
Function.
@Since 23/04/2014
@Author  Helio Leal.
/*/
//------------------------------------------------------------------- 
Function _TKPI056B_RelIndxGrpInd()
Return Nil