// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI015A_Grupo.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 30.08.05 | 1776 Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI015A_Grupo.ch"

/*--------------------------------------------------------------------------------------
@entity Grupo de Indicadores
Indicador no KPI. Contém os alvos.
Indicador de performance. Indicadores estao atreladas a objetivos.
@table KPI015A
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRUPO_IND"
#define TAG_GROUP  "GRUPO_INDS"
#define TEXT_ENTITY STR0001/*//"Grupo"*/
#define TEXT_GROUP  STR0002/*//"Grupos"*/

class TKPI015A from TBITable
	method New() constructor
	method NewKPI015A()

	//Árvore.
	Method oArvore(aSelNode)
	Method oBuildTree(cIDUser, aSelNode)

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList()

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)

endclass
	
method New() class TKPI015A
	::NewKpi015A()
return

method NewKpi015A() class TKPI015A
	// Table
	::NewTable("SGI015A")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI015AI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI015AI02",	{"NOME"},	.f.))
return


// Lista XML para anexar ao pai
method oToXMLList() class TKPI015A
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
	
	// Gera recheio
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
method oToXMLRecList() class TKPI015A
	local oXMLNodeLista, oAttrib, oXMLNode, nInd                   
         
	oXMLNodeLista := TBIXMLNode():New("LISTA")

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
	 	   	
	::SetOrder(1)
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
method oToXMLNode() class TKPI015A
	local aFields, nInd
	local nIndexId := 0
	local cIdGrupo := "" 
	local cFilter  := ""
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next 
	
	nIndexId := aScan(aFields, {|aVal| aVal[1]=="ID"})	
	cIdGrupo := aFields[nIndexId][2]
	if!(alltrim(cIdGrupo) == "0")
		cFilter := "ID_GRUPO = '" + cIdGrupo + "'"
		oXMLNode:oAddChild( ::oOwner():oGetTable("INDICADOR"):oToXMLList(cFilter,.t.) )
	endif
	
	oUser := ::oOwner():foSecurity:oLoggedUser()
	if(oUser:lValue("ADMIN") .or. ::oOwner():foSecurity:lHasAccess("GRUPO_IND", oUser:cValue("ID"), "MANUTENCAO"))
		oXMLNode:oAddChild( TBIXMLNode():New("PERMISSAO", .t.) )
	else
		oXMLNode:oAddChild( TBIXMLNode():New("PERMISSAO", .f.) )
	endif
	
return oXMLNode
	
// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI015A
	local aFields, nInd, nStatus := KPI_ST_OK, aIndTend
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd(aFields, {"ID", ::cMakeID()})
	
	// Grava
	if(!::lAppend(aFields))
		if(::nLastError()==DBERROR_UNIQUE)
			nStatus := KPI_ST_UNIQUE
		else
			nStatus := KPI_ST_INUSE
		endif
	endif	

return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI015A		
	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	local cID 			:= ""	
	local nInd			:= 0
	local nStatus		:= KPI_ST_OK
	local nQtdReg		:= 0
	local aFields 		:= {} 
	local aRegNode		:= {} 
	local cNewID		:= "" 
	
	private oXMLInput := oXML
	
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
        
            
	//Tratamento para a atualização os indicadores removendo-os do grupo. 
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_EX_IND"), "_INDICADOR"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_EX_IND")
		 
		//Tratamento para a atualização de mais de um indicador. 
		if(valtype(aRegNode:_INDICADOR)=="A")
		   
			for nQtdReg := 1 to len(aRegNode:_INDICADOR)
				cID := aRegNode:_INDICADOR[nQtdReg]:_ID:TEXT
				if(oIndicador:lSeek(1, {cID}))					
					if(! oIndicador:lUpdate({{"ID_GRUPO",""}}) )						
						if(oIndicador:nLastError()==DBERROR_UNIQUE)
							nStatus := KPI_ST_UNIQUE
						else
							nStatus := KPI_ST_INUSE
						endif						
						exit						
					endif
				endif				
			next nQtdReg 
		 
		//Tratamento para a atualização de somente um indicador.		
		elseif(valtype(aRegNode:_INDICADOR)=="O") 		
		   
		   	cID := aRegNode:_INDICADOR:_ID:TEXT
		   	if(oIndicador:lSeek(1, {cID}))					
				if(! oIndicador:lUpdate({{"ID_GRUPO",""}}) )						
					if(oIndicador:nLastError()==DBERROR_UNIQUE)
						nStatus := KPI_ST_UNIQUE
					else
						nStatus := KPI_ST_INUSE
					endif
				endif
			endif			 	
		endif				
	endif	
	          
		
	//Tratamento para a atualização os indicadores incluindo-os em um grupo. 
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_ADD_IND"), "_INDICADOR"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_ADD_IND")
		
		cNewID := &("oXMLInput:"+cPath+":_ID:TEXT")	 
		 
		//Tratamento para a atualização de mais de um indicador. 
		if(valtype(aRegNode:_INDICADOR)=="A")
		   
			for nQtdReg := 1 to len(aRegNode:_INDICADOR)
				cID := aRegNode:_INDICADOR[nQtdReg]:_ID:TEXT
				if(oIndicador:lSeek(1, {cID}))					
					if(! oIndicador:lUpdate({{"ID_GRUPO", cNewID}}) )						
						if(oIndicador:nLastError()==DBERROR_UNIQUE)
							nStatus := KPI_ST_UNIQUE
						else
							nStatus := KPI_ST_INUSE
						endif						
						exit						
					endif
				endif				
			next nQtdReg 
		 
		//Tratamento para a atualização de somente um indicador.		
		elseif(valtype(aRegNode:_INDICADOR)=="O") 		
		   
		   	cID := aRegNode:_INDICADOR:_ID:TEXT
		   	if(oIndicador:lSeek(1, {cID}))					
				if(! oIndicador:lUpdate({{"ID_GRUPO", cNewID}}) )						
					if(oIndicador:nLastError()==DBERROR_UNIQUE)
						nStatus := KPI_ST_UNIQUE
					else
						nStatus := KPI_ST_INUSE
					endif
				endif
			endif			 	
		endif				
	endif
		
return nStatus   


// Excluir entidade do server
method nDelFromXML(cID) class TKPI015A
	local nStatus			:= KPI_ST_OK//, oTableChild
	local oKpiCore			:= ::oOwner()    
	local oIndicador 	:= oKpiCore:oGetTable("INDICADOR")    
	
	if( ! oIndicador:lSeek(2,{cID})) 
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
	else
		cIndName := alltrim(oIndicador:cValue("NOME"))
		::fcMsg := STR0003 + cIndName + STR0004
		nStatus := KPI_ST_VALIDATION
	endif

return nStatus

function _KPI015A_Grupo()
return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} oArvore
Monta o XML da árvore de grupo de indicadores. 	
@Return (Objeto) Primeiro nível da árvore de grupo de indicadores.
@Since 22/04/2014
@Author  Helio Leal
/*/
//-------------------------------------------------------------------  
Method oArvore(aSelNode) class TKPI015A
	Local oUser 		:= ::oOwner():foSecurity:oLoggedUser()	
	Local lVisivel	:= .T. 
	Local oTreeNode 	:= Nil  
	Local oXMLArvore	:= Nil
	Local aPosicao	:= {}    
        
	Default aSelNode	:= .F.

	aPosicao := ::SavePos() //Guarda a posição original da tabela de grupo de indicadores.		   
    
	::SetOrder(1) //Ordena pela Ordem depois por ID.
	::_First() 
	
	If !(::lEof())
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID"		, "0")
		oAttrib:lSet("TIPO"	, TAG_GROUP)
		oAttrib:lSet("NOME"	, TEXT_GROUP )
		oAttrib:lSet("IMAGE"	, 0)
		oAttrib:lSet("ENABLE", .T.)

		oAttrib:lSet("SELECTED", .F.)

		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

		While(!::lEof())
			If ( !(alltrim(::cValue("ID")) == "0") )
				//Monta um nó para ser adicionado a arvore de grupo de indicadores.				
				oTreeNode :=  ::oBuildTree(oUser:cValue("ID"), aSelNode)
				
				If !(oTreeNode == Nil) 
					//Adiciona os nós a árvore de grupo de indicadores.   
					oXMLArvore:oAddChild(oTreeNode)  
				EndIf  		 
			EndIf 
			::_Next()			
		EndDo                                                               
	EndIf  
	
	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards.
Return oXMLArvore

//-------------------------------------------------------------------
/*/{Protheus.doc} oBuildTree
Monta o XML da árvore com as permissoes.
@Param 	cIDUser 	(Caracter) 	ID do usuário corrente.
@Return 			(Objeto)		Item da árvore de grupo de indicadores.
@Since 22/04/2014
@Author  Helio Leal.
/*/
//-------------------------------------------------------------------
Method oBuildTree(cIDUser, aSelNode) Class TKPI015A

	Local oAttrib 		:= TBIXMLAttrib():New()  
	Local oXMLNode		:= Nil
	Local aPosicao		:= {} 
	Local cIDSco			:= AllTrim(::cValue("ID") )           
		
	Default cIDUser		:=	""
	Default aSelNode	:= .F.
    
 	aPosicao := ::SavePos() //Guarda a posição original da tabela de scorecards.

	oAttrib:lSet("ID"			, ::cValue("ID"))
	oAttrib:lSet("NOME"		, AllTrim(::cValue("NOME")))
	oAttrib:lSet("TIPOSCORE"	, "1")
	oAttrib:lSet("ENABLE"	, .T.)	
	oAttrib:lSet("IMAGE"  	, KPI_IMG_GRUPOINDICADOR )	
	
	oAttrib:lSet("SELECTED"	, .F. )
	
    If (valType(aSelNode) == "A")
		oAttrib:lSet("SELECTED",IIf((aScan(aSelNode,::cValue("ID")) == 0) ,.F.,.T.))
	EndIf

	oXMLNode := TBIXMLNode():New(TAG_GROUP + "." + cIDSco, "", oAttrib)

	::RestPos(aPosicao) //Restaura a posição original da tabela de scorecards.  
return oXMLNode