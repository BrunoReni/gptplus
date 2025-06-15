// ######################################################################################
// Projeto: KPI
// Modulo : Database
// Fonte  : KPISystemVar.prw
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 03.08.04 | 1645 Leandro Marcelino Santos
// 18.08.05 | 1776 Alexandre Alves da Silva - Importado para o KPI 
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "KPIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TKPISystemVar
@entity SystemVar
Variáveis de Sistema
--------------------------------------------------------------------------------------*/
#define TAG_ENTITY "SYSTEMVAR"
#define TAG_GROUP  "SYSTEMVARS"

class TKPISystemVar from TBIObject
	method New() constructor
	method NewKPISystemVar() 

//	method oToXMLNode()
//	method nInsFromXML(oXML, cPath)
	method nUpdFromXML(oXML, cPath)
//	method nDelFromXML(nID)

	method xSessionValue(cVar, xValue)
	
endclass
	
method New() class TKPISystemVar
	::NewKPISystemVar()
return
method NewKPISystemVar() class TKPISystemVar

return

// Atualiza entidade ja existente
method nUpdFromXML(oXML, cPath) class TKPISystemVar
	local cNome, cTipo, xValue, nStatus := KPI_ST_OK
	private oXMLInput := oXML
	
	// Extrai valores do XML
	cNome  := xBIConvTo("C", &("oXMLInput:"+cPath+":_NOME:TEXT"))
	cTipo  := xBIConvTo("C", &("oXMLInput:"+cPath+":_TIPO:TEXT"))
	xValue := xBIConvTo(cTipo, &("oXMLInput:"+cPath+":_VALOR:TEXT"))
                      
	::xSessionValue(cNome, xValue)

return nStatus

/*-------------------------------------------------------------------------------------
@property xSessionValue(cVar, xValue)
Grava ou Recupera uma Variavel de uma Sessão.
@param cVar - Nome da Variavel.
@param xValue - Valor da Variavel
@return - Valor da Variavel gravada na Sessão do Usuario.
--------------------------------------------------------------------------------------*/
method xSessionValue(cVar, xValue) class TKPISystemVar
	if(valtype(xValue) != "U")
		&("HttpSession->" + alltrim(cVar)) := xValue
	endif
return &("HttpSession->" + alltrim(cVar))

function _KPISystemVar()
return nil