// ######################################################################################
// Projeto: KPI
// Modulo : Ordenação de Scorecards
// Fonte  : kpiOrdemScorecard.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.08.10 | 2516 Valdiney V GOMES
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPIOrdemScorecard.CH"

#define TAG_ENTITY "ORDEMSCORECARD"
#define TAG_GROUP  "ORDEMSCORECARDS"
#define TEXT_ENTITY STR0001 //"Ordem Scorecard"
#define TEXT_GROUP  STR0002 //"Ordem Scorecards"
 
/**
Definição da classe. 
*/
class TKPIOrdemScorecard from TBITable
	method New() constructor
	method NewKPIOrdemScorecard()

	method oToXMLNode(nParentID)
	method oToXMLRecList(cCmdSQL)   
	method nUpdFromXML(oXML, cPath)
endclass
   
/**
Construtor.
*/
method New() class TKPIOrdemScorecard
	::NewObject()
return

/**
Carrega a estrutura de dados. 
*/
method oToXMLNode() class TKPIOrdemScorecard 
	local oXMLNode   := TBIXMLNode():New(TAG_ENTITY)
return oXMLNode

/**
Lista os scorecards filhos de um scorecard.
@param cID ID do Scorecard.
@return oXMLLista
*/
method oToXMLRecList(cID) class TKPIOrdemScorecard 
	local oSco			:= ::oOwner():oGetTable("SCORECARD")
	local oAttrib 		:= TBIXMLAttrib():New()
	local oXMLNode 		:= Nil
	local oNode			:= Nil  
	local nInd			:= 0   
	local aFields		:= {}   
	local oXMLLista 	:= Nil      
	local nOrdem 		:= 1      
     
	If (cID == "0" )
		cID := Replicate(" ",10)
	EndIf        
          
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
       
	oAttrib:lSet("TAG000", "ORDEM")
	oAttrib:lSet("CAB000", STR0003) //"Ordem" 
	oAttrib:lSet("CLA000", KPI_INT)
	
	oAttrib:lSet("TAG001", "NOME")
	oAttrib:lSet("CAB001", STR0004) //"Nome"
	oAttrib:lSet("CLA001", KPI_STRING)
	
	oAttrib:lSet("TAG002", "ID")
	oAttrib:lSet("CAB002", "ID") 
	oAttrib:lSet("CLA002", KPI_STRING)   

	oXMLNode 	:= TBIXMLNode():New(TAG_GROUP,,oAttrib)
  
  	oSco:lSoftSeek(5, { AllTrim(cID) } )
  
	While(!oSco:lEof() .And. ( AllTrim(oSco:cValue("PARENTID") ) == AllTrim(cID) ) )   
		if ( !(AllTrim( oSco:cValue("ID") ) == "0") )
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := {{"ID",""},{"NOME",""},{"ORDEM",""}}
	        	
			For nInd := 1 To Len(aFields) 
			    If (aFields[nInd][1] == "ORDEM")
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], 	nOrdem))
				Else
					oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], oSco:cValue(aFields[nInd][1])))
				EndIf					
			Next
	 
			nOrdem ++
		EndIf	
		
		oSco:_Next()		
	End

	oXMLLista := TBIXMLNode():New("LISTA")
	oXMLLista:oAddChild(oXMLNode)      

return oXMLLista             

                                      
/**
Atualiza a ordem dos scorecards.
@param oXML
@param cPath
@return nStatus
*/
method nUpdFromXML(oXML, cPath) class TKPIOrdemScorecard 
	Local nStatus 	:= KPI_ST_OK 
	local oSco		:= ::oOwner():oGetTable("SCORECARD")   
	Local aConjunto	:= {}   
	Local aOrdem  	:= {} 
   	Local nCount	:= 1      
      
	Local ORDEM     := 1 
	Local ID    	:= 2
       
	Private oXMLInput 	:= oXML  
   
	aConjunto	:= aBIToken( xBIConvTo("C", &("oXMLInput:"+cPath+":_ORDEM:TEXT") ) , "|", .F.)         
                         
    For nCount := 1 To Len(aConjunto)
    	aOrdem :=  aBIToken( aConjunto[nCount] , ",", .F.)   
               
    	If( oSco:lSeek(1, {aOrdem[ID]} ) )
    		If ( ! oSco:lUpdate( {{"ORDEM", nBIVal(aOrdem[ORDEM]) }} ))  
    			If(oSco:nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				Else
					nStatus := KPI_ST_INUSE
				EndIf
										
				Exit						
			EndIf		
		EndIf   
	Next nCount		

return nStatus

/**
Torna a classe visível no inspetor de objetos.
*/
function _kpiOrdemScorecard()
return nil