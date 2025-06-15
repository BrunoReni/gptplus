// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI002a_Gru.prw    
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 17.03.04 | 1645 Leandro Marcelino Santos
// 22.08.05 | 1776 Alexandre Alves da Silva - Importado para uso no KPI.
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI002a_Gru.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIEvtObject->TBIDataSet->TBITable->TKPI002A
@entity Grupo
Grupos de Usuarios do sistema KPI.
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "GRUPO"
#define TAG_GROUP  "GRUPOS"
#define TEXT_ENTITY STR0001/*//"Grupo"*/
#define TEXT_GROUP  STR0002/*//"Grupos"*/

class TKPI002A from TBITable
	method New() constructor
	method NewKPI002A() 

	method oArvore()
	method oAllGroups()
	method oToXMLList()

	method oToXMLNode()
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(cID)

	method nSqlCount() 
	method oGetSco(cGrupo)
	method oGetChildSco(cGrupo,cEnabled,cSelected)

endclass
	
method New() class TKPI002A
	::NewKPI002A()
return    

method NewKPI002A() class TKPI002A
	local oField

	// Table
	::NewTable("SGI002A")
	::cEntity(TAG_ENTITY)

	// Fields
	::addField(TBIField():New("ID"				,"C"	,010))
	::addField(TBIField():New("PARENTID"		,"C"	,010))
	::addField(TBIField():New("DESCRICAO"		,"C"	,255))
	::addField(TBIField():New("ATIVO"			,"C"		))	
	::addField(oField := TBIField():New("NOME"	,"C"	,030))
	oField:lSensitive(.f.)

	// Indexes
	::addIndex(TBIIndex():New("SGI002AI01",	{"ID"}	,	.t.))
	::addIndex(TBIIndex():New("SGI002AI02",	{"NOME"}, 	.f.))
	
return

// Arvore
method oArvore() class TKPI002A
	local oXMLNode, oNode, oAttrib
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", 1)
	oAttrib:lSet("TIPO", "GRUPOS")
	oAttrib:lSet("NOME", STR0002) //"Grupos"
	oXMLNode := TBIXMLNode():New("GRUPOS","",oAttrib)

	::SetOrder(2) // Alfabetica por nomes
	::_First()
	while(!::lEof())
		if(! alltrim(::cValue("ID"))=="0")
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::cValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New("GRUPO", "", oAttrib))
		endif	
		::_Next()
	end
return oXMLNode
                      
// Arvore
method oAllGroups(cFixo) class TKPI002A
	local oXMLNode, oNode, oAttrib
	                   
	default cFixo := ""	                   
	                   
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID", "0")
	oAttrib:lSet("TIPO", TAG_GROUP)            
	oAttrib:lSet("IMAGE", KPI_IMG_DIRUSUARIO)
	oAttrib:lSet("NOME", STR0002) //"Grupos"
	oXMLNode := TBIXMLNode():New(TAG_GROUP,"",oAttrib)

	::SetOrder(2) // Alfabetica por nomes
	::_First()
	while(!::lEof())
		if(! alltrim(::cValue("ID"))=="0")
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", cFixo+::cValue("ID"))
			oAttrib:lSet("NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("TIPO", TAG_ENTITY)    
			oAttrib:lSet("IMAGE", KPI_IMG_GRUPO_USUARIO)
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY+"."+::cValue("ID"), "", oAttrib))
		endif	
		::_Next()
	end
return oXMLNode

// Lista XML para anexar ao pai
method oToXMLList() class TKPI002A
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
	::SetOrder(2) // Alfabetica por nomes
	::_First()
	while(!::lEof())
		if(::nValue("ID")!=0)
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"CONTEXTID"})
			for nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			next
		endif	
		::_Next()
	end
return oXMLNode

//Carregar
method oToXMLNode() class TKPI002A
	local cID, aFields, nInd//, oNode
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	local oTabRegra := ::oOWner():oGetTable("REGRA")

	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		if(aFields[nInd][1] == "ID")
			cID := aFields[nInd][2]
		endif	
	next

	oXMLNode:oAddChild(::oOwner():oGetTable("GRPUSUARIO"):oToXMLList(cID))
	oXMLNode:oAddChild(::oOwner():oGetTable("USUARIO"):oToXMLList())
	oXMLNode:oAddChild(oTabRegra:RegraNode(::cValue("ID"),"G"))
	oXMLNode:oAddChild(oTabRegra:oArvoreSeg())  
	oXMLNode:oAddChild(::oGetSco(cID))
return oXMLNode

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI002A
	local aFields		:= {}
	local nInd			:= 0 	
	local nStatus 		:= KPI_ST_OK  
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:"+cPath+":_"+aFields[nInd][1]+":TEXT"))
	next
	aAdd( aFields, {"ID", ::cMakeID()} )
	
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
method nUpdFromXML(oXML, cPath) class TKPI002A
	local oUserSco	:= ::oOWner():oGetTable("SCOR_X_USER")
	local aFields 		:= {}  
	local aUsuario		:= {}     
	local aRegNode		:= {}
	local nStatus 		:= KPI_ST_OK
	local cID			:= ""
	local nInd			:= 0 
	local nQtdReg		:= 0
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

	aFields := aBIPackArray(aFields)

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
		else

			nStatus := ::oOWner():oGetTable("REGRA"):nUpdFromXML(oXML, cPath + ":_REGRAS", cID, "G", 1)//0 - insercao / 1 - update
			
	    	if(nStatus == KPI_ST_OK)
				nStatus := ::oOWner():oGetTable("GRPUSUARIO"):nUpdFromXML(oXML,cPath,::cValue("ID"))		
			else
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			endif
		endif	
	endif    
	
	
	//Gravando a permissão de acesso aos departamentos 
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_SCOS"), "_SCO"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_SCOS")
		if(valtype(aRegNode:_SCO)=="A")
			for nQtdReg := 1 to len(aRegNode:_SCO)
				if alltrim(aRegNode:_SCO[nQtdReg]:_SELECTED:TEXT) == "T"
					aadd(aUsuario,aRegNode:_SCO[nQtdReg]:_ID:TEXT)
				endif
			next nQtdReg
		elseif(valtype(aRegNode:_SCO) =="O")       
			if alltrim(aRegNode:_SCO:_SELECTED:TEXT) == "T"
				aadd(aUsuario,aRegNode:_SCO:_ID:TEXT)
			endif		
		endif
	endif   
	    
	nStatus := oUserSco:nDelFromXML(cID,"G")
	if(len(aUsuario) > 0 .and. nStatus == KPI_ST_OK)
		oUserSco:nInsFromXML(cID,aUsuario,"G")
	endif	
	
	
return nStatus

// Exclui entidade
method nDelFromXML(cID) class TKPI002A
	local nStatus 	:= KPI_ST_OK
	local oKpiCore	:= ::oOwner()
	local oGrpUsuario, oUsuario

	//Verifica se existem usuario para este grupo.
	oGrpUsuario :=  oKpiCore:oGetTable("GRPUSUARIO")
	if(oGrpUsuario:lSoftSeek(3, {cID}))
		if(oGrpUsuario:cValue("PARENTID")==padr(cID,10))
			oUsuario := oKpiCore:oGetTable("USUARIO")
			oUsuario:_first()
			cUserId := alltrim(oGrpUsuario:cValue("IDUSUARIO"))
			if( oUsuario:lSeek(1, { cUserId }) )
				::fcMsg := STR0005 + STR0006 + "'" +alltrim(oUsuario:cValue("NOME")) + STR0007
				return KPI_ST_VALIDATION
			endif
    	endif
    endif	

	// Deleta o elemento
	if(::lSeek(1, {cID}))
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		else
			//Exclui as regras do grupo.
			nStatus := oKpiCore:oGetTable("REGRA"):nDelFromXML(cID,"G")	
		endif
	else
		nStatus := KPI_ST_BADID
	endif	
    
	// Quando implementar security
	// nStatus := KPI_ST_NORIGHTS
	
return nStatus

method nSqlCount() class TKPI002A
	local nCount := 0
	
	nCount := _Super:nSqlCount()
	
	if(::lSeek(1,{padr("0",10)}))
		nCount--
	endif

return nCount    

method oGetSco(cGrupo) class TKPI002A
	local oXMLArvore	:= nil	
	local oTreeNode 	:= nil 
	local cEnabled		:= "True"
	local cSelected		:= "False"
	private aScoPerm	:= ::oOWner():oGetTable("SCOR_X_USER"):aScorxGrp(cGrupo)
	private oSco		:= ::oOwner():oGetTable("SCORECARD") 
	    
	//Ordena pela Ordem depois por ID. 
	oSco:SetOrder(6)	
	oSco:_First()
	
	if(! oSco:lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", "0")
		oAttrib:lSet("TIPO", "DPTOS")
		oAttrib:lSet("NOME", ::oOwner():getStrCustom():getStrSco())
		oAttrib:lSet("ENABLED", cEnabled)
		oAttrib:lSet("SELECTED", cSelected)          
		oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )				
		oXMLArvore := TBIXMLNode():New("DPTOS","",oAttrib)
                        
		// Nodes
		while(!oSco:lEof())
			
			if ( !(alltrim(oSco:cValue("ID")) == "0") .and. Empty(oSco:cValue("PARENTID")))
				oSco:SavePos() 
				oTreeNode :=  ::oGetChildSco(cGrupo,cEnabled,cSelected)
				if !oTreeNode==nil    
					oXMLArvore:oAddChild(oTreeNode)  
				endif
				oSco:SetOrder(1)//ID
				oSco:RestPos()
			endif				
			oSco:_Next()
		enddo                                                               '
	endif
return oXMLArvore                            

method oGetChildSco(cGrupo,cEnabled,cSelected) class TKPI002A
	local cId 			:= ""
	local cParentID 	:= ""     
	local nRec 			:= 0
	local oNode			:= nil
	local oXMLNode		:= nil
	local oAttrib   	:= nil
	default cGrupo		:= ""		
	
	oSco:SetOrder(5) //PARENTID
	nRec := oSco:nRecno()  
	
	cParentID 	:= oSco:cValue("PARENTID")
	cId			:= oSco:cValue("ID")
	cOrdem 		:= Padl(AllTrim(oSco:cValue("ORDEM")),3,"0")      

	cSelected := "False"    
	
	if ascan(aScoPerm, { |x| alltrim(x)  == alltrim(cId)}) > 0
		cSelected := "True"
	endif
	
	
	oAttrib := TBIXMLAttrib():New()
	oAttrib:lSet("ID"		, cID)
	oAttrib:lSet("NOME"		, alltrim(oSco:cValue("NOME")))
	oAttrib:lSet("ENABLED"	, cEnabled)
	oAttrib:lSet("SELECTED"	, cSelected)
	oAttrib:lSet("DESCRICAO", alltrim(oSco:cValue("DESCRICAO")))
	oAttrib:lSet("PARENTID"	, oSco:cValue("PARENTID") )    
	oAttrib:lSet("IMAGE"	, oSco:nTreeImgByType( oSco:nValue("TIPOSCORE") ) )		
	
	oXMLNode := TBIXMLNode():New("DPTOS" + "." + cOrdem + "." + alltrim(cID),"",oAttrib)	
	
	if oSco:lSeek(2,{cID}) //Tem nos filhos
		while(oSco:cValue("PARENTID") == cID .and. ! oSco:lEof())                 
			if oSco:lSeek(1, {oSco:cValue("ID")}) 
				oNode := ::oGetChildSco(oSco:cValue("ID"),cEnabled,cSelected)
				if !oNode==nil 
					if oXMLNode==nil   
						oXMLNode:= oNode
					else                         
						oXMLNode:oAddChild(oNode)
					endif
				endif
			endif    
			oSco:_Next()
		enddo		
	endif

	oSco:lGoTo(nRec)

return oXMLNode    


function _KPI002a_Gru()
return nil