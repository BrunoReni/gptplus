// ######################################################################################
// Projeto: KPI
// Modulo : Configuração - Restrição de acesso
// Fonte  : KPICFGRESTACESSO.PRW
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 21.09.07 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"


#define TAG_ENTITY "CFGRESTACESSO"
#define TAG_GROUP  "CFGRESTACESSOS"
#define TEXT_ENTITY "Ip"
#define TEXT_GROUP  "Ips"

class TKPICfgRestAcesso from TBITable
	method New() constructor
	method NewKPIChangeImg()

	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath,cUserID)
	method nExecute(cID, cExecCMD)
	
endclass

method New() class TKPICfgRestAcesso
	::NewKPIChangeImg()
return

method NewKPIChangeImg() class TKPICfgRestAcesso
	::NewObject()
return
                                                                              
// Carregar
method oToXMLNode() class TKPICfgRestAcesso
	local oXMLNode 		:= TBIXMLNode():New(TAG_ENTITY)
	local oRestAcesso	:= ::oOwner():oGetTable("RESTACESSO")  
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO") 


	oXMLNode:oAddChild(TBIXMLNode():New("RESTRINGI_IP",oParametro:getValue("RESTRINGI_IP")))
	oXMLNode:oAddChild(TBIXMLNode():New("RESTRINGI_HORARIO",oParametro:getValue("RESTRINGI_HORARIO")))   
	oXMLNode:oAddChild(TBIXMLNode():New("HORARIO_ACESSO",oParametro:getValue("HORARIO_ACESSO")))   
	
	oXMLNode:oAddChild(oRestAcesso:oToXMLList())				
	
return oXMLNode


//Atualizacao 
method nUpdFromXML(oXML, cPath,cUserID) class TKPICfgRestAcesso
	local oParametro	:= ::oOwner():oGetTable("PARAMETRO") 
	local oRestAcesso	:= ::oOwner():oGetTable("RESTACESSO")
	local nStatus 		:= KPI_ST_OK  
	local nQtdReg		:= 0
	local cRestIp		:= ""
	local cRestHr		:= ""
	local cAcesHr		:= "" 
	private oTmpNode                                        
	private oXMLInput	:= oXML

    
    cRestIp := alltrim(oXMLInput:_REGISTROS:_CFGRESTACESSO:_RESTRINGI_IP:TEXT)
    cRestHr := alltrim(oXMLInput:_REGISTROS:_CFGRESTACESSO:_RESTRINGI_HORARIO:TEXT)
    cAcesHr := alltrim(oXMLInput:_REGISTROS:_CFGRESTACESSO:_HORARIO_ACESSO:TEXT)
    
    
    if nStatus == KPI_ST_OK
    	nStatus := oParametro:setValue("RESTRINGI_IP", cRestIp)
    endif
                           
    if nStatus == KPI_ST_OK                                    
    	nStatus := oParametro:setValue("RESTRINGI_HORARIO", cRestHr)
    endif
                           
	if nStatus == KPI_ST_OK                                    
		nStatus := oParametro:setValue("HORARIO_ACESSO", cAcesHr)
    endif
	
    	
	//Excluindo endereços IPs marcados para exclusao
	if nStatus == KPI_ST_OK   
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_RESTACESSOS"), "_REG_EXCLUIDO"))!="U")
			aRegNode := &("oXMLInput:"+cPath+":_RESTACESSOS:_REG_EXCLUIDO")//Pegando endereço IP
			if(valtype(aRegNode:_EXCLUIDOS:_RESTACESSO)=="A")		
				aRegNode := aRegNode:_EXCLUIDOS:_RESTACESSO
				for nQtdReg := 1 to len(aRegNode)
					nStatus	:= oRestAcesso:nDelFromXML(aRegNode[nQtdReg])
					if(nStatus != KPI_ST_OK)
						exit
					endif			
				next nQtdReg
			else
				nStatus	:= oRestAcesso:nDelFromXML(aRegNode:_EXCLUIDOS:_RESTACESSO)				
			endif
		endif
	endif
	
	//Gravando configuracoes de acesso
	if nStatus == KPI_ST_OK   
		if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_RESTACESSOS"), "_RESTACESSO"))!="U")
			aRegNode := &("oXMLInput:"+cPath+":_RESTACESSOS")
			if(valtype(aRegNode:_RESTACESSO)=="A")
				for nQtdReg := 1 to len(aRegNode:_RESTACESSO)
	   				oTmpNode 	:= aRegNode:_RESTACESSO
					nStatus		:= oRestAcesso:nUpdFromXML(oTmpNode[nQtdReg],"")
					if(nStatus != KPI_ST_OK)
						exit
					endif
				next nQtdReg
			elseif(valtype(aRegNode:_RESTACESSO)=="O")
				oTmpNode	:= aRegNode:_RESTACESSO
				nStatus		:= oRestAcesso:nUpdFromXML(oTmpNode	,"")
		  	endif
		endif	
	endif
	
return nStatus

// Execute
method nExecute(cID, cExecCMD) class TKPIChangeImg    
return 1

function _KPICFGRESTACESSO()
return nil