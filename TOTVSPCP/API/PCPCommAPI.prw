#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} PCPCommAPI
API REST com m�todos para realiza��o de testes de configura��o e comunica��o
@type  WSCLASS
@author renan.roeder
@since 24/03/2023
@version P12.1.2310
/*/
WSRESTFUL PCPCommAPI DESCRIPTION "API REST com m�todos para realiza��o de testes de configura��o e comunica��o"

WSMETHOD GET WHOIS;
	DESCRIPTION "M�todo para teste de comunica��o";
	WSSYNTAX "api/pcp/v1/pcpcommapi/whois";
	PATH "api/pcp/v1/pcpcommapi/whois";
    TTALK "v1"

END WSRESTFUL

WSMETHOD GET WHOIS WSSERVICE PCPCommAPI
    Local lRet := .T.

    ::SetContentType("application/json")
    ::SetResponse(JsonObject():New())
Return lRet
