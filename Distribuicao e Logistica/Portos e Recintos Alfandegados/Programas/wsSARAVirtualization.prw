#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:9090/saraws/SARAWS.dll/wsdl/IVirtualizacao 
Gerado em        01/08/13 08:36:10
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _SHNPRWH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSIVirtualizacaoservice
------------------------------------------------------------------------------- */

WSCLIENT WSIVirtualizacaoservice

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD getVirtualization

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ccParent                  AS string
	WSDATA   cURL							AS string
	WSDATA   creturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSIVirtualizacaoservice
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSIVirtualizacaoservice
Return

WSMETHOD RESET WSCLIENT WSIVirtualizacaoservice
	::ccParent           := NIL
	::cURL					:= NIL 
	::creturn            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSIVirtualizacaoservice
Local oClone := WSIVirtualizacaoservice():New()
	oClone:_URL          := ::_URL 
	oClone:ccParent      := ::ccParent
	oClone:cURL			:= ::cURL
	oClone:creturn       := ::creturn
Return oClone

// WSDL Method getVirtualization of Service WSIVirtualizacaoservice

WSMETHOD getVirtualization WSSEND ccParent WSRECEIVE creturn WSCLIENT WSIVirtualizacaoservice
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getVirtualization xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("cParent", ::ccParent, ccParent , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getVirtualization>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:VirtualizacaoIntf-IVirtualizacao#getVirtualization",; 
	"RPCX","http://tempuri.org/",,,; 	
	::cURL)

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



