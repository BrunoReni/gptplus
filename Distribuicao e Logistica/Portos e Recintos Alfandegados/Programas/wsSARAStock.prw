#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:9090/saraws/SARAWS.dll/wsdl/IEstoque 
Gerado em        01/08/13 08:35:32
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QTUCHJP ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSIEstoqueservice
------------------------------------------------------------------------------- */

WSCLIENT WSIEstoqueservice

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD getStock

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ccPesq                    AS string
	WSDATA   cURL							AS string
	WSDATA   creturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSIEstoqueservice
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSIEstoqueservice
Return

WSMETHOD RESET WSCLIENT WSIEstoqueservice
	::ccPesq             := NIL
	::cURL					:= NIL 
	::creturn            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSIEstoqueservice
Local oClone := WSIEstoqueservice():New()
	oClone:_URL          := ::_URL 
	oClone:ccPesq        := ::ccPesq
	oClone:cURL			:= ::cURL
	oClone:creturn       := ::creturn
Return oClone

// WSDL Method getStock of Service WSIEstoqueservice

WSMETHOD getStock WSSEND ccPesq WSRECEIVE creturn WSCLIENT WSIEstoqueservice
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getStock xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("cPesq", ::ccPesq, ccPesq , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getStock>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:EstoqueIntf-IEstoque#getStock",; 
	"RPCX","http://tempuri.org/",,,; 
	::cURL)

::Init()
::creturn  :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


