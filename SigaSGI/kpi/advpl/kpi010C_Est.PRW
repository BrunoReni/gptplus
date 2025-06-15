// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI010C_Est.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.08.11 | Gilmar P. Santos
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"

#include "KPI010C_Est.ch"     

#define TAG_ENTITY "ESTRATEGIA"
#define TAG_GROUP  "ESTRATEGIAS"
#define TEXT_ENTITY STR0001		//###"Estratégia"
#define TEXT_GROUP  STR0002		//###"Estratégias"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TKPI010C
Entidade Estratégia

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
class TKPI010C from TBITable

	method New() constructor
	method NewKpi010C()

	// Request
	method oToXMLNode()
	method oToXMLList()
	method oToXMLRecList()
	method oProcCmd()
	
	// Create/Update/Delete
	method nInsFromXML()
	method nUpdFromXML()
	method nDelFromXML()

endclass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method New() class TKPI010C
	::NewKpi010C()
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} NewKpi010C
Construtor

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method NewKpi010C() class TKPI010C

	// Table
	::NewTable("SGI010C")  
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID" , "C", 10))

	::addField(TBIField():New("DATAINI", "D"))
	::addField(TBIField():New("DATAFIN", "D"))

	// Indexes
	::addIndex(TBIIndex():New("SGI010CI01", {"ID"}, .T.))

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLNode
Gera nó XML com os dados da entidade

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLNode(cId, oXmlNode, aExcFields) class TKPI010C

	local aFields := {}
	local nInd

	default oXmlNode := TBIXMLNode():New(TAG_ENTITY)
	default aExcFields := nil

	//Se informado ID, posiciona a entidade	
	if valtype(cId) == "C" .and. !empty(cId)
		::lSeek(1, {cId})
	else
		cId := ::cValue("ID")
	endif 
	

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY, aExcFields)

	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next 
		                                
	oXMLNode:oAddChild(::oOwner():oGetTable("TEMAESTRATEGICO"):oToXMLList(cId))	 
			
return oXMLNode


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLList
Gera XML com os dados de todas as entidades

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLList() class TKPI010C

	local oNode
	local oAttrib
	local oXMLNode

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
	::SetOrder(1)
	::_First()

	while(!::lEof())

		if( !(alltrim(::cValue("ID")) == "0"))    
			//Adiciona nó com a entidade posicionada
			oNode := oXMLNode:oAddChild( ::oToXMLNode() )
		endif

		::_Next()
	enddo

return oXMLNode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oToXMLRecList
Gera XML com os dados de todas as entidades (em um nó "LISTA")

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method oToXMLRecList() class TKPI010C

	local oXMLNodeLista := TBIXMLNode():New("LISTA")

	oXMLNodeLista:oAddChild( ::oToXMLList() )
	
return oXMLNodeLista


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nInsFromXML
Insere nova entidade

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method nInsFromXML(oXML, cPath, cId) class TKPI010C

	local aFields := {}
	local aIndTend := {}
	local nStatus := KPI_ST_OK
	local nInd
	local oSco := nil
	local oPer := nil
	local aPosSco := {}
	local aPosPer := {}
	local cIdEst := ""
	local aPers := {}

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd(aFields, {"ID", cId})

	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	

	// Adiciona perspectivas padrões
	if nStatus == KPI_ST_OK
		aPers := {	{ STR0003, STR0004 }, ;		// ### "Financeira" / "Para sermos bem sucedidos financeiramente, como deveríamos ser vistos pelos nossos acionistas?"
					{ STR0005, STR0006 }, ;		// ### "Cliente" / "Para alcançarmos nossa visão, como deveríamos ser vistos pelos nossos clientes?"
					{ STR0007, STR0008 }, ;		// ### "Processo Interno" / "Para satisfazermos nossos acionistas e clientes, em que processos de negócios devemos alcançar a excelência?"
					{ STR0009, STR0010 } }		// ### "Aprendizado e Crescimento" / "Para alcançarmos nossa visão, como sustentaremos nossa capacidade de mudar e melhorar?"

		oSco := ::oOwner():oGetTable("SCORECARD")
		oPer := ::oOwner():oGetTable("PERSPECTIVA")

		//Salva posicionamento atual
	   	aPosSco := oSco:SavePos()
	   	aPosPer := oPer:SavePos()

		for nInd := 1 to len( aPers )

			// Gera novo ID
			cIdEst := oSco:cMakeID()

			// Adiciona Scorecard do tipo perspectiva
			if !oSco:lAppend( {	{ "ID"			, cIdEst 			}, ;
								{ "PARENTID"	, cID 				}, ;
								{ "NOME"		, aPers[nInd][1]	}, ;
								{ "DESCRICAO"	, aPers[nInd][2]	}, ;
								{ "VISIVEL"		, "T"				}, ;
								{ "ORDEM"		, nInd				}, ;
								{ "TIPOSCORE"	, CAD_PERSPECTIVA	} } )	

				if oSco:nLastError() == DBERROR_UNIQUE
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif

				EXIT
			endif

			// Adiciona perspectiva
			if !oPer:lAppend( {	{"ID", cIdEst} } )
				if oPer:nLastError() == DBERROR_UNIQUE
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif

				EXIT
			endif

		next

		// Restaura posicionamento original
		oPer:RestPos(aPosPer)
		oSco:RestPos(aPosSco)

	endif

return nStatus

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nUpdFromXML
Atualiza entidade ja existente

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method nUpdFromXML(oXML, cPath, cId) class TKPI010C

	local nStatus := KPI_ST_OK
	local nInd

	private oXMLInput := oXML

	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next

	aAdd(aFields, {"ID", cId})

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

return nStatus

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} nDelFromXML
Exclui entidade

@author		BI TEAM
@version	P11 
@since		17/08/2011
/*/
//-------------------------------------------------------------------------------------
method nDelFromXML(cID) class TKPI010C

	local nStatus 	:= KPI_ST_OK
    Local oTema		:= ::oOwner():oGetTable("TEMAESTRATEGICO")

	if(::lSeek(1,{cID})) 

		::oOwner():oOltpController():lBeginTransaction()

		// Deleta o relacionamento
		While oTema:lSeek(2,{::cValue("ID")})
			
			nStatus := oTema:nDelFromXML()	
			If nStatus != KPI_ST_OK
				exit			
			EndIf
	    
	    End
		
		If nStatus	== KPI_ST_OK
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
	    EndIf    
		
		If(nStatus != KPI_ST_OK)
			::oOwner():oOltpController():lRollback()
		EndIf

		::oOwner():oOltpController():lEndTransaction()

	else
		nStatus := KPI_ST_BADID
	endif	

return nStatus



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} oProcCmd
Processa e distribui comandos

@author		BI TEAM
@version	P11 
@since		12/12/2011
/*/
//-------------------------------------------------------------------------------------
method oProcCmd(oCmd) class TKPI010C

	local oScorecard	:= nil
	local oAttrib		:= nil
	local oXmlNode		:= nil
	local oXmlAux		:= nil
	local cOrgName		:= ""

	if valtype(XmlChildEx(oCmd,"_PARENTID")) != "U"

		oScorecard	:= ::oOwner():oGetTable("SCORECARD")
		oAttrib		:= TBIXMLAttrib():New()
		oXmlNode	:= TBIXMLNode():New("PARENTS",,oAttrib)

		if oScorecard:lSeek(1, {oCmd:_PARENTID:TEXT})
			cOrgName := oScorecard:cValue("NOME")
		endif

		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ORGANIZACAO_NOME", cOrgName)

		oXmlAux := oXmlNode:oAddChild(TBIXMLNode():New("PARENTS_NAMES",,oAttrib))
	else
		oXmlNode := ::oToXmlRecList()
	endif

return oXmlNode


//-------------------------------------------------------------------------------------
function _KPI010C_EST()
return nil