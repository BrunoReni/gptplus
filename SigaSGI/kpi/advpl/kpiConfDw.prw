/* ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : kpiConfDw.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 11.11.08 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------*/
#include "BIDefs.ch"
#include "KPIDefs.ch" 
#include "KPICONFDW.CH"

/*--------------------------------------------------------------------------------------
@entity Integração com o DW
--------------------------------------------------------------------------------------*/

#define TAG_ENTITY "DW_CONF"
#define TAG_GROUP  "DW_CONFS"


class TKPIConfDw from TBITable
	method New() constructor
	method NewKPIConfDw()

	method oToXMLNode(cID,cRequest)   
	method nInsFromXML(oXML, cPath)   
	method nUpdFromXML(oXML, cPath) 
	method nExecute(cID, cExecCMD)  
	method update(oXML)  
	
	
endclass
	
method New() class TKPIConfDw
	::NewKPIConfDw()
return

method NewKPIConfDw() class TKPIConfDw

return

/*-------------------------------------------------------------------------------------
Carrega o no requisitado.
@param cID 		- ID da entidade.
@param cRequest - Sequencia de caracteres com as instrucoes de execuxao
@return 		- No XML com os dados
--------------------------------------------------------------------------------------*/
method oToXMLNode(cID,cRequest) class TKPIConfDw
	local oXMLNode 		:=	TBIXMLNode():New(TAG_ENTITY)    
	local oPar			:= ::oOwner():oGetTable("PARAMETRO")
	               
	oXMLNode:oAddChild(TBIXMLNode():New("WS_DW_INTEGRATION", oPar:getValue("WS_DW_INTEGRATION")))	
	oXMLNode:oAddChild(TBIXMLNode():New("DW_URL", oPar:getValue("DW_URL")))
	oXMLNode:oAddChild(TBIXMLNode():New("DW_USER", oPar:getValue("DW_USER")))
	oXMLNode:oAddChild(TBIXMLNode():New("DW_PWD", oPar:getValue("DW_PWD")))
	
return oXMLNode
 

// Insere nova entidade
method nInsFromXML(oXML, cPath) class TKPIConfDw   
return ::update(oXML)

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPIConfDw
return ::update(oXML)

// Atualiza os parametros em SGI01
method update(oXML) class TKPIConfDw   
	local oPar		:= ::oOwner():oGetTable("PARAMETRO")
	local nStatus 	:= KPI_ST_OK
	local cWsdl		:= ""
	local cUrl		:= ""
	local cUser		:= ""
	local cPwd		:= ""
	local nPos		:= 0
	private oXMLInput := oXML

    if nStatus == KPI_ST_OK 
		cWsdl := alltrim(oXMLInput:_REGISTROS:_DW_CONF:_WS_DW_INTEGRATION:TEXT)
		nPos := at("?",cWsdl)
		if nPos > 0 
			cWsdl := left(cWsdl,nPos-1)		
		endif
    	nStatus := oPar:setValue("WS_DW_INTEGRATION", cWsdl)
    endif
    if nStatus == KPI_ST_OK 
		cUrl := alltrim(oXMLInput:_REGISTROS:_DW_CONF:_DW_URL:TEXT)
    	nStatus := oPar:setValue("DW_URL", cUrl)
    endif
    if nStatus == KPI_ST_OK 
		cUser := alltrim(oXMLInput:_REGISTROS:_DW_CONF:_DW_USER:TEXT)
    	nStatus := oPar:setValue("DW_USER", cUser)
    endif
      if nStatus == KPI_ST_OK 
		cPwd := alltrim(oXMLInput:_REGISTROS:_DW_CONF:_DW_PWD:TEXT)
    	nStatus := oPar:setValue("DW_PWD", cPwd)
    endif
	
return nStatus


/*
*Metodo do nExecute
*/
method nExecute(cID, cRequest)  class TKPIConfDw
	local oPar		:= ::oOwner():oGetTable("PARAMETRO")
	local nStatus 	:= KPI_ST_OK
	local cWsdl		:= alltrim(oPar:getValue("WS_DW_INTEGRATION"))
	local cUrl		:= alltrim(oPar:getValue("DW_URL"))
	local cUser		:= alltrim(oPar:getValue("DW_USER"))
	local cPwd		:= alltrim(oPar:getValue("DW_PWD"))   
	local cSessao	:= ""     
	local cMsgErr	:= ""
	local oObjDW 	:= WSSIGADW():New()
	
	//Logando no DW				                                   
	oObjDW:_URL := cWsdl
	oObjDW:LOGIN(alltrim(cUrl),"",alltrim(cUser),cPwd)     
	cSessao := oObjDW:CLOGINRESULT
	
	if valType(cSessao) != "U"	
		nStatus := KPI_ST_OK
		::fcMsg := STR0001 //"Conexão Ok"
	else
		nStatus :=	KPI_ST_VALIDATION 
		cMsgErr := "<html><b>"
		cMsgErr += STR0002 //"Conexão Inválida! Verifique:"
		cMsgErr += "</b><br><br>"
		cMsgErr += STR0003 //"1) Web Service (WSDL) do DW está respondendo corretamente."
		cMsgErr += "  <br>"
		cMsgErr += STR0004 //"2) Endereço (URL) do site do DW está correto."
		cMsgErr += "<br>"
		cMsgErr += STR0005 //"3) Se o usuário esta cadastrado no DW como usuário SIGA."
		cMsgErr += "</html>"
		::fcMsg := cMsgErr                  
	endif
	
	
return nStatus     


function _kpi035_ConfDw()
return nil