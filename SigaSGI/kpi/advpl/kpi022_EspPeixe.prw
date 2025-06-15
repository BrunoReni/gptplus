// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpi022_EspPeixe.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 12.02.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "kpi022_EspPeixe.ch"

/*--------------------------------------------------------------------------------------
@entity Unidades
Tabela que contém os problemas apresentados pelos indicadores
@table KPI022
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "ESP_PEIXE"
#define TAG_GROUP  "ESP_PEIXES"
#define TEXT_ENTITY STR0001 //"Espinha de Peixe"
#define TEXT_GROUP  STR0002 //"Espinhas de Peixe" 
           
class TKPI022 from TBITable   
	method New() constructor
	method NewKPI022()

	// diversos registros
	method oToXMLRecList()
	method oToXMLNode()
	method oToXMLList()

	// registro atual
	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
	method nDelFromXML(nID)
	
	//Quando a tabela é criada, este método popula a tabela
	method carregaTabela()       
	
	//Outros
	method nUpdTree(oXML)
	method oArvore(cIdRoot) 
	method oBuildTree(cId, nType) 
	method hasPlanAcao(cIdCausa)

endclass
	
method New() class TKPI022  
	::NewKpi022()
return

method NewKpi022() class TKPI022
	// Table
	::NewTable("SGI022")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C"	,010))
	::addField(TBIField():New("ID_SCO"		,"C"	,010))
	::addField(TBIField():New("ID_IND"		,"C"	,010))
	::addField(TBIField():New("NOME"		,"C"	,060))
	::addField(TBIField():New("DESCRICAO"	,"C"	,255))
	
	// Indexes
	::addIndex(TBIIndex():New("SGI022I01",	{"ID"}		,	.T.))
	::addIndex(TBIIndex():New("SGI022I02",	{"NOME"}	,	.F.))
	::addIndex(TBIIndex():New("SGI022I03",	{"ID_IND"}	,	.F.))
return

// Lista XML para anexar ao pai
method oToXMLList() class TKPI022
	local oNode, oAttrib, oXMLNode, nInd
	
	oAttrib := TBIXMLAttrib():New() 
	
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)  
	
	oAttrib:lSet("TAG000", "NOME")
	oAttrib:lSet("CAB000", TEXT_ENTITY)
	oAttrib:lSet("CLA000", KPI_STRING)

	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	::SetOrder(2)
	::_First()
	
	While(!::lEof())
		If( !(alltrim(::cValue("ID")) == "0"))
			oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
			
			For nInd := 1 to len(aFields)
				oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
			Next
		EndIf			
		::_Next()		
	End
return oXMLNode

// Lista XML para anexar ao pai
method oToXMLRecList(cFiltro) class TKPI022
	Local oXMLNodeLista := TBIXMLNode():New("LISTA")
	Local oAttrib 		:= TBIXMLAttrib():New() 
	Local oXMLNode      := TBIXMLNode():New(TAG_GROUP,,oAttrib) 
    Local nRegistro		:= 0       
            
    If ( Empty(cFiltro) .Or. (cFiltro == "0") )
    	oXMLNodeLista:oAddChild(::oToXMLList())
    Else
		oAttrib:lSet("TIPO", TAG_ENTITY)
		oAttrib:lSet("RETORNA", .f.)  
		
		oAttrib:lSet("TAG000", "NOME")
		oAttrib:lSet("CAB000", TEXT_ENTITY)
		oAttrib:lSet("CLA000", KPI_STRING)

        If ( ::lSeek(3,{cFiltro}) )

			While(!::lEof() .And. ::cValue("ID_IND") == cFiltro ) 
				If( !(alltrim(::cValue("ID")) == "0"))
					oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
					aFields := ::xRecord(RF_ARRAY, {"DESCRICAO"})
					
					For nRegistro := 1 to len(aFields)
						oNode:oAddChild(TBIXMLNode():New(aFields[nRegistro][1], aFields[nRegistro][2]))
					Next
				EndIf			
				::_Next()		
			End	 
		EndIf 
		
		oXMLNodeLista:oAddChild(oXMLNode)  
    EndIf		
return oXMLNodeLista

// Carregar
method oToXMLNode() class TKPI022
	local aFields, nInd
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)

	// Acrescenta os valores ao XML
	aFields := ::xRecord(RF_ARRAY)
	for nInd := 1 to len(aFields)
		oXMLNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
	next 
	
	oXMLNode:oAddChild(::oArvore(::cValue("ID")))
	
return oXMLNode
	
// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPI022
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
	Else
		//Gravando os dados da árvore
		nStatus := ::nUpdTree(oXML,cPath)
	endif	
return nStatus

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPI022
	local nStatus := KPI_ST_OK, cID, nInd
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
		else
			//Gravando os dados da árvore
			nStatus := ::nUpdTree(oXML,cPath)
		endif	
	endif    
	
	
return nStatus   

method oArvore(cIdRoot) class TKPI022
	local oEfeito		:= ::oOwner():oGetTable("ESP_PEIXE_EFEITO")  
	local oCausa		:= ::oOwner():oGetTable("ESP_PEIXE_CAUSA")	
	local oXMLArvore	:= nil
	local oAttrib		:= nil
	local oXMLEfeito	:= nil
	local oAtbEfeito	:= nil
	local cId			:= "" 
	    
	if ::lSeek(1,{cIdRoot}) 
		// Root
		cId		:= ::cValue("ID")
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID"		, cIdRoot)
		oAttrib:lSet("TIPO"		, TAG_GROUP)
		oAttrib:lSet("NOME"		, ::cValue("NOME")) 
		oAttrib:lSet("DESCRICAO", "")
		oAttrib:lSet("ID_PAI"	, "")
		oAttrib:lSet("HASACAO"	, "F")
		oAttrib:lSet("TYPE_PAI"	, "")
		oAttrib:lSet("TYPE"		, KPI_ROOT)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		
		//Adiciona nó causa adicionado ao root
		oCausa:SetOrder(3)
		oCausa:lSeek(3,{cIdRoot,KPI_ROOT}) 
		while(oCausa:cValue("ID_PAI") == cIdRoot .and. ;
			  oCausa:nValue("TIPO_PAI") == KPI_ROOT)
			oXMLArvore:oAddChild( ::oBuildTree(oCausa:cValue("ID")) )
			oCausa:_Next()
		enddo
	
		
		//Adiciona Efeito 
		oEfeito:cSQLFilter("ID_PAI = '" + cId + "'")
		oEfeito:lFiltered(.t.)
		oEfeito:_First()	
		while(!oEfeito:lEof())
			cId 	  := oEfeito:cValue("ID")
			oAtbEfeito:= TBIXMLAttrib():New()
			oAtbEfeito:lSet("ID"		, cId)
			oAtbEfeito:lSet("NOME"		, alltrim(oEfeito:cValue("NOME")))
			oAtbEfeito:lSet("DESCRICAO"	, alltrim(oEfeito:cValue("DESCRICAO")))
			oAtbEfeito:lSet("ID_PAI"	, oEfeito:cValue("ID_PAI"))
			oAtbEfeito:lSet("HASACAO"	, "F")
			oAtbEfeito:lSet("TYPE_PAI"	, KPI_ROOT)
			oAtbEfeito:lSet("TYPE"		, KPI_EFEITO)
			oXMLEfeito:= TBIXMLNode():New(TAG_GROUP+"."+alltrim(cId),"",oAtbEfeito)
			
			//Adiciona Causa
			oCausa:SetOrder(3)
			oCausa:lSeek(3,{cId,KPI_EFEITO}) 
			while(oCausa:cValue("ID_PAI") == cId .and. ;
				  oCausa:nValue("TIPO_PAI") == KPI_EFEITO)
				oXMLEfeito:oAddChild( ::oBuildTree(oCausa:cValue("ID")) )
				oCausa:_Next()
			enddo
   			oXMLArvore:oAddChild(oXMLEfeito)
			oEfeito:_Next()
		enddo
		oEfeito:cSQLFilter("")
	endif
return oXMLArvore 


//Função Recursiva
method oBuildTree(cId) class TKPI022
	local oCausa		:= ::oOwner():oGetTable("ESP_PEIXE_CAUSA")
	local oXMLCausa		:= nil
	local oAtbCausa		:= nil 
	local nRec 			:= 0
	
	
	nRec := oCausa:nRecno()     
	cId 	 := oCausa:cValue("ID")
	oAtbCausa:= TBIXMLAttrib():New()
	oAtbCausa:lSet("ID"			, cId)
	oAtbCausa:lSet("NOME"		, alltrim(oCausa:cValue("NOME")))
	oAtbCausa:lSet("DESCRICAO"	, alltrim(oCausa:cValue("DESCRICAO")))
	oAtbCausa:lSet("ID_PAI"		, oCausa:cValue("ID_PAI"))
	oAtbCausa:lSet("TYPE_PAI"	, oCausa:cValue("TIPO_PAI"))
	oAtbCausa:lSet("TYPE"		, KPI_CAUSA)
	oAtbCausa:lSet("HASACAO"	, ::hasPlanAcao(cId))
	oXMLCausa:= TBIXMLNode():New(TAG_GROUP+"."+alltrim(cId),"",oAtbCausa)   	

    //Adiciona os filhos 
   	oCausa:SetOrder(3)
	oCausa:lSeek(3,{cId,KPI_CAUSA}) 
	while(oCausa:cValue("ID_PAI") == cId .and. ;
		  oCausa:nValue("TIPO_PAI") == KPI_CAUSA)
		oXMLCausa:oAddChild( ::oBuildTree(oCausa:cValue("ID")) )
		oCausa:_Next()
	enddo
	oCausa:lGoTo(nRec)
return oXMLCausa


//Verifica se possui plano de ação cadastrado
method hasPlanAcao(cIdCausa) class TKPI022
	local oGrpAcao := ::oOwner():oGetTable("GRUPO_ACAO")
	local lRet	 := .f.
    
	if(oGrpAcao:lSeek(4, {cIdCausa})) 
		lRet := .t.
	endif
	
return lRet


method nUpdTree(oXML, cPath) class TKPI022
	local oEfeito	:= ::oOwner():oGetTable("ESP_PEIXE_EFEITO")
	local oCausa	:= ::oOwner():oGetTable("ESP_PEIXE_CAUSA")
	local nStatus 	:= KPI_ST_OK    
	local lAddNew	:= .f.
	local cIdTmp	:= ""
	local cIdXML	:= "" 
	local cIdPaiTmp	:= ""
	local cIdPaiXml	:= ""
	local aIdNode	:= {}
	local aRegNode	:= {}   
	local aFields	:= {}
	local nQtdReg	:= 1 
	local nFlds		:= 1
	local nPos		:= 0  
	
	//Excluindo registros marcados para exclusão
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_ARVORE"), "_REG_EXCLUIDO"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_ARVORE:_REG_EXCLUIDO:_EXCLUIDOS")
		if(valtype(aRegNode:_ESP_PEIXE)=="A")		
			for nQtdReg := 1 to len(aRegNode:_ESP_PEIXE) 
                if val(aRegNode:_ESP_PEIXE[nQtdReg]:_TYPE:TEXT) == KPI_CAUSA
                	nStatus := oCausa:nDelFromXML(aRegNode:_ESP_PEIXE[nQtdReg]:_ID:TEXT, .t.)
                else
                	nStatus := oEfeito:nDelFromXML(aRegNode:_ESP_PEIXE[nQtdReg]:_ID:TEXT,.t.)
                endif              
			next nQtdReg
		else
			if val(aRegNode:_ESP_PEIXE:_TYPE:TEXT) == KPI_CAUSA
               	nStatus := oCausa:nDelFromXML(aRegNode:_ESP_PEIXE:_ID:TEXT, .t.)
            else
               	nStatus := oEfeito:nDelFromXML(aRegNode:_ESP_PEIXE:_ID:TEXT,.t.)
            endif              
		endif
	endif					

	
	
	//Atualizando efeito
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_ARVORE:_ESPPEIXE:_EFEITOS"), "_EFEITO"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_ARVORE:_ESPPEIXE:_EFEITOS")	//Pegando causas cadastradas
		if(valtype(aRegNode:_EFEITO)=="A")
			for nQtdReg := 1 to len(aRegNode:_EFEITO)
				aFields := {}
				cIdXML := aRegNode:_EFEITO[nQtdReg]:_ID:TEXT
				if left(cIdXML,6) == "IDNEW_" 
					cIdTmp := oEfeito:cMakeID()
					aadd(aIdNode,{cIdXML, cIdTmp})	
					aadd(aFields,{"ID",cIdTmp})
					lAddNew := .t.
				else
					aadd(aFields,{"ID",cIdXML})              
					lAddNew := .f.
				endif 
				aadd(aFields,{"ID_PAI"		, ::cValue("ID")})	
				aadd(aFields,{"NOME"		, aRegNode:_EFEITO[nQtdReg]:_NOME:TEXT})	
				aadd(aFields,{"DESCRICAO"	, xBIConvTo("C", aRegNode:_EFEITO[nQtdReg]:_DESCRICAO:TEXT)})
				if lAddNew
					nStatus := oEfeito:nInsFromXML(aFields)
				else
					nStatus := oEfeito:nUpdFromXML(aFields,cIdXML)
				endif
				
				if nStatus != KPI_ST_OK 
					return nStatus
				endif
				
			next nQtdReg
		elseif(valtype(aRegNode:_EFEITO)=="O")
			aFields := {}
			cIdXML := aRegNode:_EFEITO:_ID:TEXT
			if left(cIdXML,6) == "IDNEW_" 
				cIdTmp := oEfeito:cMakeID()
				aadd(aIdNode,{cIdXML, cIdTmp})	
				aadd(aFields,{"ID",cIdTmp})
				lAddNew := .t.
			else
				aadd(aFields,{"ID",cIdXML})              
				lAddNew := .f.
			endif 
			aadd(aFields,{"ID_PAI"		, ::cValue("ID")})	
			aadd(aFields,{"NOME"		, aRegNode:_EFEITO:_NOME:TEXT})
			aadd(aFields,{"DESCRICAO"	, xBIConvTo("C",aRegNode:_EFEITO:_DESCRICAO:TEXT)})
			if lAddNew
				nStatus := oEfeito:nInsFromXML(aFields)
			else
				nStatus := oEfeito:nUpdFromXML(aFields,cIdXML)
			endif
		endif
	endif


	//Atualizando causa
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_ARVORE:_ESPPEIXE:_CAUSAS"), "_CAUSA"))!="U")
		aRegNode := &("oXMLInput:"+cPath+":_ARVORE:_ESPPEIXE:_CAUSAS")//Pegando causas cadastradas
		if(valtype(aRegNode:_CAUSA)=="A")
			for nQtdReg := 1 to len(aRegNode:_CAUSA)
				aFields := {}
				cIdXML := aRegNode:_CAUSA[nQtdReg]:_ID:TEXT
				if left(cIdXML,6) == "IDNEW_" 
					cIdTmp := oCausa:cMakeID()
					aadd(aIdNode,{cIdXML, cIdTmp})	
					aadd(aFields,{"ID",cIdTmp})
					lAddNew := .t.
				else
					aadd(aFields,{"ID",cIdXML})              
					lAddNew := .f.
				endif    
				
				cIdPaiXml := aRegNode:_CAUSA[nQtdReg]:_ID_PAI:TEXT
				if left(cIdPaiXml,6) == "IDNEW_"
					nPos := aScan(aIdNode,{|aVal| aVal[1] == cIdPaiXml})
					if nPos > 0
						aadd(aFields,{"ID_PAI", aIdNode[nPos][2]})
					else
						nStatus := KPI_ST_BADID
					endif
				else
					aadd(aFields,{"ID_PAI", cIdPaiXml})	
				endif
				
				aadd(aFields,{"TIPO_PAI"	, aRegNode:_CAUSA[nQtdReg]:_TIPO_PAI:TEXT})	
				aadd(aFields,{"NOME"		, aRegNode:_CAUSA[nQtdReg]:_NOME:TEXT})	
				aadd(aFields,{"DESCRICAO"	, xBIConvTo("C",aRegNode:_CAUSA[nQtdReg]:_DESCRICAO:TEXT)})
				aadd(aFields,{"OWNER"		, ::cValue("ID")})
				
				if nStatus != KPI_ST_OK 
					return nStatus
				endif
				
				if lAddNew
					nStatus := oCausa:nInsFromXML(aFields)
				else
					nStatus := oCausa:nUpdFromXML(aFields,cIdXML)
				endif 
				
			next nQtdReg
		elseif(valtype(aRegNode:_CAUSA)=="O")              
			aFields := {}
			cIdXML := aRegNode:_CAUSA:_ID:TEXT
			if left(cIdXML,6) == "IDNEW_" 
				cIdTmp := oCausa:cMakeID()
				aadd(aIdNode,{cIdXML, cIdTmp})	
				aadd(aFields,{"ID",cIdTmp})
				lAddNew := .t.
			else
				aadd(aFields,{"ID",cIdXML})              
				lAddNew := .f.
			endif    
			
			cIdPaiXml := aRegNode:_CAUSA:_ID_PAI:TEXT
			if left(cIdPaiXml,6) == "IDNEW_"
				nPos := aScan(aIdNode,{|aVal| aVal[1] == cIdPaiXml})
				if nPos > 0
					aadd(aFields,{"ID_PAI", aIdNode[nPos][2]})
				else
					nStatus := KPI_ST_BADID
				endif
			else
				aadd(aFields,{"ID_PAI", cIdPaiXml})	
			endif
			
			aadd(aFields,{"TIPO_PAI"	, aRegNode:_CAUSA:_TIPO_PAI:TEXT})	
			aadd(aFields,{"NOME"		, aRegNode:_CAUSA:_NOME:TEXT})	
			aadd(aFields,{"DESCRICAO"	, xBIConvTo("C",aRegNode:_CAUSA:_DESCRICAO:TEXT)})
			aadd(aFields,{"OWNER"		, ::cValue("ID")})
			
			if nStatus != KPI_ST_OK 
				return nStatus
			endif
			
			if lAddNew
				nStatus := oCausa:nInsFromXML(aFields)
			else
				nStatus := oCausa:nUpdFromXML(aFields,cIdXML)
			endif                                        
			
		endif
	endif

return nStatus


// Excluir entidade do server
method nDelFromXML(cID) class TKPI022
	local nStatus			:= KPI_ST_OK
	
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

return nStatus

method carregaTabela() class TKPI022

return

function _kpi022_EspPeixe()
return nil