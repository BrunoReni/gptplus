#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://jvd008262:9191/SARAWS/saraws.dll/wsdl/IOCR  
Gerado em        05/21/13 09:13:41
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SWPKSYF ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSIOCRservice
------------------------------------------------------------------------------- */

WSCLIENT WSIOCRservice

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BuscaPlaca

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ncodPort                  AS int
	WSDATA   cdtHra                    AS string
	WSDATA   creturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSIOCRservice
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSIOCRservice
Return

WSMETHOD RESET WSCLIENT WSIOCRservice
	::ncodPort           := NIL 
	::cdtHra             := NIL 
	::creturn            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSIOCRservice
Local oClone := WSIOCRservice():New()
	oClone:_URL          := ::_URL 
	oClone:ncodPort      := ::ncodPort
	oClone:cdtHra        := ::cdtHra
	oClone:creturn       := ::creturn
Return oClone

// WSDL Method BuscaPlaca of Service WSIOCRservice

WSMETHOD BuscaPlaca WSSEND ncodPort,cdtHra WSRECEIVE creturn WSCLIENT WSIOCRservice
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:BuscaPlaca xmlns:q1="urn:OCRIntf-IOCR">'
cSoap += WSSoapValue("codPort", ::ncodPort, ncodPort , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("dtHra", ::cdtHra, cdtHra , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:BuscaPlaca>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:OCRIntf-IOCR#BuscaPlaca",; 
	"RPCX","http://tempuri.org/",,,; 
	"")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



