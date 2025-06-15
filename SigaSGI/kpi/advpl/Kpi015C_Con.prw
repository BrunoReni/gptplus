// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPI015C_Con.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 18.06.07 | 1776 -  Alexandre Alves da Silva
// --------------------------------------------------------------------------------------
#include "BIDefs.ch"
#include "KPIDefs.ch"
#include "KPI015C_Con.ch"

/*--------------------------------------------------------------------------------------
@class TKPI015C
@entity DataSource
Cadastro de consultas do DW para acesso no KPI.
@table KPI015C
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "DWCONSULTA"
#define TAG_GROUP  "DWCONSULTAS"
#define TEXT_ENTITY STR0001/*//"Consulta do DW"*/
#define TEXT_GROUP  STR0002/*//"Consultas do DW"*/

class TKPI015C from TBITable
	method New() constructor
	method NewKPI015C()

	// diversos registros
	method oArvore(nParentID)
	method oToXMLList(nParentID)

	// registro atual
	method oToXMLNode(cParentID,cRequest)
	method nInsFromXML(oXML,nParentID)
	method nUpdFromXML(oXML,nParentID)
	method nDelFromXML(oXML)

	
	// executar 
	method nExecute(nID, cExecCMD, cArquivo)
	method lInsDetCons(oObjDW,oXMLCons,cSessao,nConsID)	
	method oReqDWCon()
	
endclass

method New() class TKPI015C
	::NewKPI015C()
return
method NewKPI015C() class TKPI015C
	// Table
	::NewTable("SGI015C")
	::cEntity(TAG_ENTITY)
	// Fields
	::addField(TBIField():New("ID"			,"C",10))
	::addField(TBIField():New("PARENTID"	,"C",10))
	::addField(TBIField():New("DW_IDCON"	,"N"))//Id consulta do dw
	::addField(TBIField():New("DW_URL"		,"C",255))	
	::addField(TBIField():New("DW_NAME"		,"C",020))
	::addField(TBIField():New("DW_CON"		,"C",020))
	
	// Indexes
	::addIndex(TBIIndex():New("KPI015CI01",{"ID"},		.t.))
	::addIndex(TBIIndex():New("KPI015CI02",{"PARENTID"},.f.))
	
return

// Arvore
method oArvore(nParentID) class TKPI015C
	local oXMLArvore, oNode
	
	::SetOrder(2) // Por ordem de nome
	::cSQLFilter("PARENTID = "+cBIStr(nParentID)) // Filtra pelo pai
	::lFiltered(.t.)
	::_First()
	if(!::lEof())
		// Tag conjunto
		oAttrib := TBIXMLAttrib():New()
		oAttrib:lSet("ID", 1)
		oAttrib:lSet("TIPO", TAG_GROUP)
		oAttrib:lSet("DW_NOME", TEXT_GROUP)
		oXMLArvore := TBIXMLNode():New(TAG_GROUP,"",oAttrib)
		// Nodes
		while(!::lEof())
			oAttrib := TBIXMLAttrib():New()
			oAttrib:lSet("ID", ::nValue("ID"))
			oAttrib:lSet("DW_NOME", alltrim(::cValue("NOME")))
			oAttrib:lSet("FEEDBACK", ::nValue("FEEDBACK"))
			oNode := oXMLArvore:oAddChild(TBIXMLNode():New(TAG_ENTITY, "", oAttrib))
			::_Next()
		enddo
	endif
	::cSQLFilter("") // Encerra filtro
return oXMLArvore

// Lista XML para anexar ao pai
method oToXMLList(cParentID) class TKPI015C
	local aFields, oNode, oAttrib, oXMLNode, nInd

	// Colunas
	oAttrib := TBIXMLAttrib():New()
	// Tipo
	oAttrib:lSet("TIPO", TAG_ENTITY)
	oAttrib:lSet("RETORNA", .f.)
	
	//URL
	oAttrib:lSet("TAG000", "DW_URL")
	oAttrib:lSet("CAB000", "URL")
	oAttrib:lSet("EDT000", "F")
	oAttrib:lSet("CUM000", "F")
	oAttrib:lSet("CLA000", KPI_STRING)

	//DW
	oAttrib:lSet("TAG001", "DW_NAME")
	oAttrib:lSet("CAB001", STR0003) //"DataWareHouse"
	oAttrib:lSet("EDT001", "F")
	oAttrib:lSet("CUM001", "F")		
	oAttrib:lSet("CLA001", KPI_STRING)

	//CONSULTA
	oAttrib:lSet("TAG002", "DW_CON")
	oAttrib:lSet("CAB002", STR0004) //"Consulta"
	oAttrib:lSet("CUM002", "F")	
	oAttrib:lSet("EDT002", "F")	
	oAttrib:lSet("CLA002", KPI_STRING)

	// Gera no principal
	oXMLNode := TBIXMLNode():New(TAG_GROUP,,oAttrib)
	
	//Gera o conteudo
	::SetOrder(2) // Por ordem de nome
	if(!empty(cParentID))
		::cSQLFilter("PARENTID = '"+ cParentID+ "'") // Filtra pelo pai
	else
		::cSQLFilter("PARENTID > '0' ")
	endif
	
	::lFiltered(.t.)
	::_First()
	while(!::lEof())
		oNode := oXMLNode:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		aFields := ::xRecord(RF_ARRAY, {"PARENTID"})
		for nInd := 1 to len(aFields)
			oNode:oAddChild(TBIXMLNode():New(aFields[nInd][1], aFields[nInd][2]))
		next
		::_Next()
	end
	::cSQLFilter("") // Encerra filtro

return oXMLNode

// Carregar
method oToXMLNode(cParentID,cRequest) class TKPI015C
	local aRequest 	:=	aBIToken(cRequest,"|",.f.)	
	local oParametro:= ::oOwner():oGetTable("PARAMETRO")
	local oXMLNode 	:=	TBIXMLNode():New(TAG_ENTITY)
	local oObjDW	:=	WSSIGADW():New()
	local oNodeDW	:=	nil
	local cParentID	:=	"0"
	local cUrl		:=	""
	local cDw		:=	""	
	local cSessao	:=	""
	local cDwRequest:=	"" 
	local cUrlWsDw	:=  ""
	::fcMsg :=	""


	cUrlWsDw := oParametro:getValue("WS_DW_INTEGRATION")
	if !("http" $ cUrlWsDw)
		cUrlWsDw :=	"http://" + cUrlWsDw
	endif
           
	oObjDW:_URL := cUrlWsDw
	
	do case
		case aRequest[1] == "REQ_DWLISTA"
			cParentID	:=	aRequest[2]
			oXMLNode:oAddChild(::oToXmlList(cParentID))
		case aRequest[1] == "REQUEST_DWACCESS"
			cUrl:= lower(aRequest[2])
			cDw	:=	alltrim(aRequest[3])       
			if !("http" $ cUrl)
		   		cUrl :=	"http://" + cUrl
			endif   

			cDwRequest	:= dwEncodeParm("dwacesss",DWConcatWSep("!", {lower(alltrim(cUrl)), cDw, alltrim(oParametro:getValue("DW_USER")), "SGI"}))
			oXMLNode:oAddChild(TBIXMLNode():New("REQUEST", cDwRequest))
		case aRequest[1] == "REQ_DATAWAREHOUSE"
			//Logando no DW				
			oObjDW:LOGIN(alltrim(aRequest[2]),"",alltrim(oParametro:getValue("DW_USER")),oParametro:getValue("DW_PWD"))
			cSessao	:=	oObjDW:CLOGINRESULT
			if(valtype(cSessao) == "U")
				::fcMsg :=  STR0005// "Conexão com o DW recusada.Verique o endereço web, usuário e senha."
			else
				oObjDW:LOGOUT(cSessao)
				oNodeDW :=	::oReqDWCon(oObjDW,cSessao,(aRequest[3] == "true"))
				if ! (valtype(oNodeDW) == "U")
					oXMLNode:oAddChild(oNodeDW)
				endif					
			endif
		otherwise		
		
	endcase		
	
return oXMLNode     

/**
*Requisitando a lista dos DataWareHouse
*
*/
method oReqDWCon(oObjDW,cSessao,lDetConsul) class TKPI015C
	local oNode		:=	nil
	local oDWs		:=	nil
	local oXMLQuery	:=	nil	
	local oNodeQuery:=	nil	
	local oListQuery:=	nil	
	local oXMLNodeDW:=	TBIXMLNode():New(TAG_GROUP)	
	local nDw		:= 	0	
	local nQuery	:=	0	
		
	oObjDW:RETDW(cSessao)
	oDWs := oObjDW:OWSRETDWRESULT:OWSDWLIST
	
	if len(oDWs) <= 0
		::fcMsg := STR0006 //"Lista dos DW não disponivel.Verique as permissões para o usuário SGIADMIN no DW."
	endif
	

	
	for nDw = 1 to len(oDWs)
		//Criando o no DataWareHouse
		oNode  	:= oXMLNodeDW:oAddChild(TBIXMLNode():New(TAG_ENTITY))
		oNode:oAddChild(TBIXMLNode():New("ID" 	,nDw))
		oNode:oAddChild(TBIXMLNode():New("NOME",oDWs[nDw]:CNAME))
		
		//Acessando o DW				
	   oObjDW:LOGINDW(alltrim(cSessao),alltrim(oDWs[nDw]:CNAME))
	    if(oObjDW:LLOGINDWRESULT)                   	
			//Requisitando as consultas do DW logado.     
			oObjDW:LISTCONSULTAS(cSessao,oDWs[nDw]:nID)
			if len(oObjDW:OWSLISTCONSULTASRESULT:OWSQUERYLIST) >0
				oListQuery	:=	oObjDW:OWSLISTCONSULTASRESULT:OWSQUERYLIST
				oXMLQuery 	:=	oNode:oAddChild(TBIXMLNode():New("QUERY_LISTS"))
					
				for nQuery := 1 to len(oListQuery)
					oNodeQuery 	:=	oXMLQuery:oAddChild(TBIXMLNode():New("QUERY_LIST"))
					oNodeQuery:oAddChild(TBIXMLNode():New("ID" 	,oListQuery[nQuery]:CID))
					oNodeQuery:oAddChild(TBIXMLNode():New("NOME",oListQuery[nQuery]:CNAME))
					//Estrutura da consulta.
					if(lDetConsul)
						::lInsDetCons(oObjDW,oNodeQuery,cSessao,val(oListQuery[nQuery]:CID))
					endif
				next nQuery
				
		   endif
	   	endif
	next nDw 

return oXMLNodeDW

/*
*Insere os campos de Data e Indicador do DW na consulta.
*/
method lInsDetCons(oObjDW,oXMLCons,cSessao,nConsID) class TKPI015C
	local lgetStruCon	:=	oObjDW:RETCONSULTA(cSessao,nConsID,.f.)
	local oXMLDatas 	:=	oXMLCons:oAddChild(TBIXMLNode():New("DATAS"))
	local oXMLInds		:=	oXMLCons:oAddChild(TBIXMLNode():New("INDICADORES"))
	local oXMLIdsInd	:=	oXMLCons:oAddChild(TBIXMLNode():New("INDICADORES_IDS"))
	local oXMLData		:=	nil
	local oXMLInd		:=	nil
	local nItens		:=	0		
	local aFieldsX	:=	{}   
	local aFieldsY	:=	{}   
	local aIndicador:=	{}

	if(lgetStruCon)
		aFieldsX	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSX:OWSFIELDSDET
		aFieldsY	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSFIELDSY:OWSFIELDSDET
		aIndicador	:=	oObjDW:OWSRETCONSULTARESULT:OWSCONSULTASTRU[1]:OWSMEASURES:OWSFIELDSDET		
		//Adicionando os campos do tipo data						
		for nItens := 1 to len(aFieldsX)
			if(aFieldsX[nItens]:CTYPE == "D")
				oXMLData 	:=	oXMLDatas:oAddChild(TBIXMLNode():New("CPO_DATA"))
				oXMLData:oAddChild(TBIXMLNode():New("ID" 	,aFieldsX[nItens]:CID))
				oXMLData:oAddChild(TBIXMLNode():New("NOME" 	,aFieldsX[nItens]:CNAME))
			endif			
		next nItens

		for nItens := 1 to len(aFieldsY)
			if(aFieldsY[nItens]:CTYPE == "D" .and. aFieldsY[nItens]:CTEMPORAL == "0")
				oXMLData 	:=	oXMLDatas:oAddChild(TBIXMLNode():New("CPO_DATA"))
				oXMLData:oAddChild(TBIXMLNode():New("ID" 	,aFieldsY[nItens]:CID))
				oXMLData:oAddChild(TBIXMLNode():New("NOME" 	,aFieldsY[nItens]:CNAME))
			elseif(aFieldsY[nItens]:CTYPE == "C")				
				oXMLData 	:=	oXMLIdsInd:oAddChild(TBIXMLNode():New("CPO_DATA"))						
				oXMLData:oAddChild(TBIXMLNode():New("ID" 	,aFieldsY[nItens]:CID))
				oXMLData:oAddChild(TBIXMLNode():New("NOME" 	,aFieldsY[nItens]:CNAME))			
			endif			
		next nItens		
		
		for nItens := 1 to len(aIndicador)
			if(aIndicador[nItens]:CTYPE == "N")
				oXMLInd 	:=	oXMLInds:oAddChild(TBIXMLNode():New("CPO_DATA"))
				oXMLInd:oAddChild(TBIXMLNode():New("ID" 	,aIndicador[nItens]:CID))
				oXMLInd:oAddChild(TBIXMLNode():New("NOME" 	,aIndicador[nItens]:CNAME))		
			endif
		next nItens				
		
	endif		
	
return .t.

// Insere nova entidade
method nInsFromXML(oXML,cParentID) class TKPI015C
	local aFields	:=	{}
	local aIndTend	:=	{}
	local nInd		:=	0
	local nStatus 	:=	KPI_ST_OK	
	private oXMLInput	:= oXML
	
	aFields := ::xRecord(RF_ARRAY, {"ID","PARENTID"})

	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
	next

	if nStatus == KPI_ST_OK
		aAdd(aFields, {"ID"			, ::cMakeID()})
		aAdd(aFields, {"PARENTID"	, cParentID})	
		
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
method nUpdFromXML(oXML,cParentID) class TKPI015C
	local nInd		:=	0
	local nQtdReg	:=	0	
	local nStatus	:= 	KPI_ST_OK
	local aIndTend	:=	{}
	local lAddNew 		:= .f.
	local lValorPrevio	:= .f.
	private oXMLInput := oXML
	
	aFields := ::xRecord(RF_ARRAY, {"PARENTID"})
	
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		cType := ::aFields(aFields[nInd][1]):cType()
		aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))

		if(aFields[nInd][1] == "ID" .and. aFields[nInd][2] == "-99")
			aFields[nInd][2]:= ::cMakeID()
			lAddNew := .T.
		endif
	next

	//Faz a gravacao dos dados.
	if(lAddNew .and. nStatus == KPI_ST_OK)
		//Adiciona um novo registro.		
		aAdd(aFields, {"PARENTID"	, cParentID})	
		// Grava
		if(!::lAppend(aFields))
			if(::nLastError()==DBERROR_UNIQUE)
				nStatus := KPI_ST_UNIQUE
			else
				nStatus := KPI_ST_INUSE
			endif
		endif	
	elseif(nStatus == KPI_ST_OK)
		/*Atualiza os registros existentes.  Para esta entidade nao e necessaria a atualizacao do registro ja existente.*/
	endif

return nStatus

// Excluir entidade do server
method nDelFromXML(oXML) class TKPI015C
	local nInd		:=	0
	local nStatus 	:= 	KPI_ST_OK
	local cID		:=	""
	private oXMLInput:= oXML

	aFields := ::xRecord(RF_ARRAY, {"PARENTID","DW_IDCON","DW_URL","DW_NAME","DW_CON"})
	
	// Extrai valores do XML
	for nInd := 1 to len(aFields)
		if(aFields[nInd][1] == "ID")
			cType := ::aFields(aFields[nInd][1]):cType()
			aFields[nInd][2] := xBIConvTo(cType, &("oXMLInput:_"+aFields[nInd][1]+":TEXT"))
			cID := aFields[nInd][2]
			exit
		endif	
	next

	//Exclui o elemento.
	if(::lSeek(1,{cID}))
		if(!::lDelete())
			nStatus := KPI_ST_INUSE
		endif
	else
		nStatus := KPI_ST_BADID
	endif

return nStatus

// Execute
method nExecute(nID, cExecCMD) class TKPI015C
	local nStatus := KPI_ST_OK

return nStatus

function _KPI015C_Con()
return nil