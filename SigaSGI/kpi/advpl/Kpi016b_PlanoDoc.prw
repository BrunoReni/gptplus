// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI016B_PlanoDoc.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 14.08.06 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch" 
#include "KPI016B_PlanoDoc.ch"


/*--------------------------------------------------------------------------------------
@class TKPI016B_PlanoDoc
@entity PlanoDoc
Lista de Documentos
@table KPI016B
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY  "PLANODOC"
#define TAG_GROUP   "PLANODOCS"
#define TEXT_ENTITY STR0003   //"Documento" 
#define TEXT_GROUP  STR0004   //"Documentos"

class TKPI016B from TBITable
	Data cPstArqs
	Data cSubPstArqs
	
	method New() constructor
	method NewKPI016B()

	// diversos registros
	method oArvore(cParentID)
	method oToXMLList(cParentID)
	method nInsFromXML(oXML,cParentID) 
	method nUpdFromXML(oXML,cParentID)
	
	// registro atual
	method oToXMLNode()
	method nDelFromXML(oXML)   
	
	// Validacoes
	method lValidArq(cNomeArq,cParentID)
	

endclass

method New() class TKPI016B
	::NewKPI016B()
return   

method NewKPI016B() class TKPI016B
	// Table
	::NewTable("SGI016B")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID",		"C", 10))
	::addField(TBIField():New("ID_PLANO",	"C", 10)) //ID (pai)
	::addField(TBIField():New("DESCRICAO",	"C",255))
	::addField(TBIField():New("DOCUMENTO",	"C",255))

	// Indexes
	::addIndex(TBIIndex():New("SGI016BI01",	{"ID"},		.t.))
	::addIndex(TBIIndex():New("SGI016BI02",	{"ID_PLANO"}, .f.))
	
	::cPstArqs   := "\sgidocs\plano_acao\"
	::cSubPstArqs:= "pl"
return

// Arvore
method oArvore(cParentID) class TKPI016B

return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(cParentID) class TKPI016B
	local oNode, oAttrib, oXMLNode
	local cFileLocal := ""
	local aFiles := {}
	local nFiles := 0
	
	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)

	oAttrib:lSet("TAG000", "DOCUMENTO")
	oAttrib:lSet("CAB000", STR0003) //"Documento"
	oAttrib:lSet("CLA000", KPI_STRING)
	oAttrib:lSet("EDT000", "F")
	oAttrib:lSet("CUM000", "F")
	
	oAttrib:lSet("TAG001", "DATE")
	oAttrib:lSet("CAB001", STR0008)		//"Data"
	oAttrib:lSet("CLA001", KPI_STRING)
	oAttrib:lSet("EDT001", "F")
	oAttrib:lSet("CUM001", "F")
	
	oAttrib:lSet("TAG002", "SIZE")
	oAttrib:lSet("CAB002", STR0009)		//"Tamanho"
	oAttrib:lSet("CLA002", KPI_STRING)
	oAttrib:lSet("EDT002", "F")
	oAttrib:lSet("CUM002", "F")
	
	oAttrib:lSet("TAG003", "DESCRICAO")
	oAttrib:lSet("CAB003", STR0005) //"Descrição"
	oAttrib:lSet("CLA003", KPI_STRING)
	oAttrib:lSet("EDT003", "T")
	oAttrib:lSet("CUM003", "F")
	
	// Gera recheio
	cFileLocal 	 := oKPICore:cKpiPath() + ::cPstArqs + ::cSubPstArqs + cParentID + "\*.*"
	aFiles := directory(cFileLocal)
	//
	::cSQLFilter("ID_PLANO = '"+cBIStr(cParentID) + "'") // Filtra pelo pai
	::setOrder(2)
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
			cArquivo := lower(AllTrim(::cValue("DOCUMENTO")))
			oNode:oAddChild(TBIXMLNode():New("ID",::cValue("ID")))
			oNode:oAddChild(TBIXMLNode():New("ID_PLANO",::cValue("ID_PLANO")))
			oNode:oAddChild(TBIXMLNode():New("DOCUMENTO",cArquivo))
			oNode:oAddChild(TBIXMLNode():New("DESCRICAO",lower(::cValue("DESCRICAO"))))
			nFile := Ascan(aFiles,{|arq| lower(AllTrim(arq[1])) == cArquivo})
			If nFile > 0
				oNode:oAddChild(TBIXMLNode():New("SIZE",str(aFiles[nFile][2]/1024,10,2)))
				oNode:oAddChild(TBIXMLNode():New("DATE",dToc(aFiles[nFile][3]) + " " + aFiles[nFile][4]))
			Else
				oNode:oAddChild(TBIXMLNode():New("SIZE"," "))
				oNode:oAddChild(TBIXMLNode():New("DATE"," "))
			Endif
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro
return oXMLNode

// Carregar
method oToXMLNode() class TKPI016B
	local oXMLNode := TBIXMLNode():New(TAG_ENTITY)
	
return oXMLNode


// Insere nova entidade
method nInsFromXML(oXML,cParentID) class TKPI016B
	local aFields 	:= ::xRecord(RF_ARRAY, {"ID","ID_PLANO"})
	local nStatus 	:= KPI_ST_OK
    local nInd		:= 0
	local nQtdReg	:=0
    local aIndTend	:= {}

	private oXMLInput := oXML
	

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		if aFields[nInd][1] == "ID" .or. aFields[nInd][1] == "ID_PLANO"
			//os ids serao tratados abaixo
		else	
			cType := ::aFields(aFields[nInd][1]):cType()
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
			
			if aFields[nInd][1] == "DOCUMENTO" .and. !(::lValidArq(aFields[nInd][2],cParentID))
			    nStatus := KPI_ST_VALIDATION
	   			//::fcMsg := "O documento '" + alltrim(aFields[nInd][2]) + "' nao foi localizado no servidor ou não é um nome de arquivo válido."
	   			::fcMsg := STR0006 + " '" + alltrim(aFields[nInd][2]) + "' " + STR0007
		 	endif
		
		endif
	next
    
	if nStatus == KPI_ST_OK
		aAdd(aFields, {"ID", ::cMakeID()})
		aAdd(aFields, {"ID_PLANO", cParentID })
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	endif

return nStatus



// Atualiza entidade ja existente
method nUpdFromXML(oXML,cParentID) class TKPI016B
	local aFields	:= ::xRecord(RF_ARRAY) 
	local nStatus	:= KPI_ST_OK
	local nQtdReg	:= 0  
	local cCodID	:= 0
	local lAddNew	:= .F.
	local nInd, aIndTend
	private oXMLInput := oXML


	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))

		if aFields[nInd][1] == "DOCUMENTO" .and. !(::lValidArq(aFields[nInd][2],cParentID))
		    nStatus := KPI_ST_VALIDATION
//   			::fcMsg := "O documento ('" + alltrim(aFields[nInd][2]) + "') nao foi localizado no servidor ou não é um nome de arquivo válido."
   			::fcMsg := STR0006 + " '" + alltrim(aFields[nInd][2]) + "' " + STR0007
	 	endif
		
		if(aFields[nInd][1] == "ID")
			if(aFields[nInd][2] == "N_E_W_")
				aFields[nInd][2]:= ::cMakeID()
				lAddNew := .T.
			endif				
			cCodID := aFields[nInd][2]			                   
		endif
		
	next

	//Faz a gravacao dos dados.
	if(lAddNew .and. nStatus == KPI_ST_OK)
		//Adiciona um novo registro.		
		aAdd(aFields, {"ID_PLANO", cParentID})	
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	elseif(nStatus == KPI_ST_OK)
		//Atualiza os registros existentes.
		if(!::lSeek(1, {cCodID}))
			nStatus := KPI_ST_BADID
		else       
			//Gravacao do Indicador
			if(!::lUpdate(aFields))
				if(::nLastError()==DBERROR_UNIQUE)
					nStatus := KPI_ST_UNIQUE
				else
					nStatus := KPI_ST_INUSE
				endif
			endif	
		endif		
	endif

return nStatus

// Excluir entidade do server
method nDelFromXML(oXML,cPlanoId) class TKPI016B
	local aFields	:= ::xRecord(RF_ARRAY, {"ID_PLANO","DESCRICAO","DOCUMENTO"})
	local nStatus 	:= KPI_ST_OK
	local nInd 		:= 1
	local cFiltro	:= ""
	local cCodID	:= ""
	private oXMLInput := oXML
	
	default cPlanoId := ""

	If !Empty(oXML)
		// Extrai valores do XML
		for nInd := 1 to len(aFields)
			if(aFields[nInd][1] == "ID")
				cType := ::aFields(aFields[nInd][1]):cType()
				aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
				cCodID := aFields[nInd][2]
				exit
			endif	
		next
		//Exclui o elemento.
		if(::lSeek(1,{cCodID}))
			if(!::lDelete())
				nStatus := KPI_ST_INUSE
			endif
		else
			nStatus := KPI_ST_BADID
		endif	
	Else
		If !Empty(cPlanoId)
			::cSQLFilter(" ID_PLANO = '" + padr(cPlanoId,10) + "'")
			::lFiltered(.t.)
			::_First()
			while(!::lEof())
				if(nStatus == KPI_ST_OK)
					if(!::lDelete())
						nStatus := KPI_ST_INUSE
						exit
					endif
			    endif
				::_Next()		
			enddo
			::cSQLFilter("")
		Endif
	Endif
return nStatus


// Valida se existe o arquivo no servidor
method lValidArq(cNomeArq,cParentID) class TKPI016B
	local lRet 		:= .t.
	local cFdDoc	:= ::cPstArqs + ::cSubPstArqs + cParentID + "\"
    local oFile 
    
	oFile := TBIFileIO():New(oKPICore:cKpiPath() + cFdDoc + alltrim(cNomeArq) )
	if oFile:lExists()
		lRet := .t.
	else
		lRet := .f.
	endif	
return lRet  

function _KPI016B_PlanoDoc()
return nil