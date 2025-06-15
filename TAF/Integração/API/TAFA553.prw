#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA553
@type			function
@description	Programa de inicializa��o do Portal THF/Portinari do TAF (ESOCIAL).
@author			Robson Santos
@since			29/11/2019
@version		1.0
/*/

WSRESTFUL TafValidRestOnline DESCRIPTION "Valida��o de API REST online." FORMAT APPLICATION_JSON
    
WSMETHOD GET v1 DESCRIPTION "Retorna um valor indicando se o servi�o REST est� online." PATH "api/taf/general/v1/TafValidRestOnline" TTALK "v1" WSSYNTAX "api/taf/general/v1/TafValidRestOnline" PRODUCES APPLICATION_JSON
    
END WSRESTFUL
    
//-------------------------------------------------------------------
/*/{Protheus.doc} POST
M�todo para varificar se a API REST est� online.

@author Robson Santos
@since 27/11/2019
/*/
//-------------------------------------------------------------------
WSMETHOD GET v1 WSSERVICE TafValidRestOnline

Local lRet := .T.

cResp := '{ "online":true }'

self:setResponse( encodeUtf8(cResp) )

Return lRet