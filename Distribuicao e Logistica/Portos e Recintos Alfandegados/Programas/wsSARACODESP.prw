#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://jvd008262:9191/SARAWS/saraws.dll/wsdl/ICODESP 
Gerado em        06/12/13 16:26:31
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JTTXYKR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSICODESPservice
------------------------------------------------------------------------------- */

WSCLIENT WSICODESPservice

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GerarArquivo

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nintStatus                AS int
	WSDATA   cstrProgID                AS string
	WSDATA   creturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSICODESPservice
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130522] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSICODESPservice
Return

WSMETHOD RESET WSCLIENT WSICODESPservice
	::nintStatus         := NIL 
	::cstrProgID         := NIL 
	::creturn            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSICODESPservice
Local oClone := WSICODESPservice():New()
	oClone:_URL          := ::_URL 
	oClone:nintStatus    := ::nintStatus
	oClone:cstrProgID    := ::cstrProgID
	oClone:creturn       := ::creturn
Return oClone

// WSDL Method GerarArquivo of Service WSICODESPservice

WSMETHOD GerarArquivo WSSEND nintStatus,cstrProgID WSRECEIVE creturn WSCLIENT WSICODESPservice
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:GerarArquivo xmlns:q1="urn:CODESPIntf-ICODESP">'
cSoap += WSSoapValue("intStatus", ::nintStatus, nintStatus , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("strProgID", ::cstrProgID, cstrProgID , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:GerarArquivo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:CODESPIntf-ICODESP#GerarArquivo",; 
	"RPCX","http://tempuri.org/",,,; 
	"")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



