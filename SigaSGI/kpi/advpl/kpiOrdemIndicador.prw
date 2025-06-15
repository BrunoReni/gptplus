// ######################################################################################
// Projeto: KPI
// Modulo : Controle da ordem dos Indicadores
// Fonte  : kpiOrdemIndicador.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 13.07.06 | 2516 Lucio Pelinson
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"


#define TAG_ENTITY "ORDEMINDICADOR"
#define TAG_GROUP  "ORDEMINDICADORES"
#define TEXT_ENTITY "Ordem Indicador"
#define TEXT_GROUP  "Ordem Indicadores"


class TKPIOrdemIndicador from TBITable
	method New() constructor
	method NewKPIOrdemIndicador()

	method oToXMLNode(nParentID)
	method nUpdFromXML(oXML, cPath)
	method nExecute(cID, cExecCMD)
endclass

method New() class TKPIOrdemIndicador
	::NewKPIOrdemIndicador()
return

method NewKPIOrdemIndicador() class TKPIOrdemIndicador
	::NewObject()
return

// Carregar
method oToXMLNode() class TKPIOrdemIndicador  
local oXMLNode   	:= TBIXMLNode():New(TAG_ENTITY)
return oXMLNode


// Execute
method nExecute(cID, cExecCMD) class TKPIOrdemIndicador
return 

                                      
// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPIOrdemIndicador   
	local oIndicador	:= ::oOwner():oGetTable("INDICADOR")
	local nStatus		:= KPI_ST_OK
	local nQtdReg		:= 0
	local cCodInd		:= ""
	local nOrdem		:= 0
	local aFields 		:= {} 
	local aRegNode		:= {} 
	private oXMLInput 	:= oXML
	
	//Atualizando os valores da planilha
	if(valtype(XmlChildEx(&("oXMLInput:"+cPath+":_INDICADORES"), "_INDICADOR"))!="U")

		aRegNode := &("oXMLInput:"+cPath+":_INDICADORES")//Pegando os valores da planilhas
		if(valtype(aRegNode:_INDICADOR)=="A")
			for nQtdReg := 1 to len(aRegNode:_INDICADOR)
				cCodInd := aRegNode:_INDICADOR[nQtdReg]:_ID:TEXT
                nOrdem	:= val(aRegNode:_INDICADOR[nQtdReg]:_ORDEM:TEXT)

				if(oIndicador:lSeek(1, {cCodInd}))
					aadd(aFields,{"ORDEM",nOrdem})
					if(! oIndicador:lUpdate(aFields))
						if(oIndicador:nLastError()==DBERROR_UNIQUE)
							nStatus := KPI_ST_UNIQUE
						else
							nStatus := KPI_ST_INUSE
						endif
						exit
					endif
				endif
			next nQtdReg    
			
		elseif(valtype(aRegNode:_INDICADOR)=="O")
		
		endif
	endif
return nStatus

function _kpiOrdemIndicador()
return nil