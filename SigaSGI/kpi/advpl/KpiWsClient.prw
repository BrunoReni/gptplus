#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost/ws/SIGASGI.apw?WSDL 
Gerado em        05/08/12 08:57:27
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LVWMJGI ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSSIGASGI
------------------------------------------------------------------------------- */

WSCLIENT WSSIGASGI

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD INSERTINDIC
	WSMETHOD LOGIN

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cTOKEN                    AS string
	WSDATA   oWSINDIC                  AS SIGASGI_KPIINDIC
	WSDATA   cINSERTINDICRESULT        AS string
	WSDATA   cUSERLOGIN                AS string
	WSDATA   cPASSWORD                 AS string
	WSDATA   cLOGINRESULT              AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSKPIINDIC               AS SIGASGI_KPIINDIC

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSIGASGI
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110330] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSIGASGI
	::oWSINDIC           := SIGASGI_KPIINDIC():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSKPIINDIC        := ::oWSINDIC
Return

WSMETHOD RESET WSCLIENT WSSIGASGI
	::cTOKEN             := NIL 
	::oWSINDIC           := NIL 
	::cINSERTINDICRESULT := NIL 
	::cUSERLOGIN         := NIL 
	::cPASSWORD          := NIL 
	::cLOGINRESULT       := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSKPIINDIC        := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSIGASGI
Local oClone := WSSIGASGI():New()
	oClone:_URL          := ::_URL 
	oClone:cTOKEN        := ::cTOKEN
	oClone:oWSINDIC      :=  IIF(::oWSINDIC = NIL , NIL ,::oWSINDIC:Clone() )
	oClone:cINSERTINDICRESULT := ::cINSERTINDICRESULT
	oClone:cUSERLOGIN    := ::cUSERLOGIN
	oClone:cPASSWORD     := ::cPASSWORD
	oClone:cLOGINRESULT  := ::cLOGINRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSKPIINDIC   := oClone:oWSINDIC
Return oClone

// WSDL Method INSERTINDIC of Service WSSIGASGI

WSMETHOD INSERTINDIC WSSEND cTOKEN,oWSINDIC WSRECEIVE cINSERTINDICRESULT WSCLIENT WSSIGASGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INSERTINDIC xmlns="http://webservices.totvs.com.br/sigasgi.apw">'
cSoap += WSSoapValue("TOKEN", ::cTOKEN, cTOKEN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("INDIC", ::oWSINDIC, oWSINDIC , "KPIINDIC", .T. , .F., 0 , NIL, .F.) 
cSoap += "</INSERTINDIC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.totvs.com.br/sigasgi.apw/INSERTINDIC",; 
	"DOCUMENT","http://webservices.totvs.com.br/sigasgi.apw",,"1.031217",; 
	"http://localhost/ws/SIGASGI.apw")

::Init()
::cINSERTINDICRESULT :=  WSAdvValue( oXmlRet,"_INSERTINDICRESPONSE:_INSERTINDICRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LOGIN of Service WSSIGASGI

WSMETHOD LOGIN WSSEND cUSERLOGIN,cPASSWORD WSRECEIVE cLOGINRESULT WSCLIENT WSSIGASGI
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LOGIN xmlns="http://webservices.totvs.com.br/sigasgi.apw">'
cSoap += WSSoapValue("USERLOGIN", ::cUSERLOGIN, cUSERLOGIN , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PASSWORD", ::cPASSWORD, cPASSWORD , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</LOGIN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.totvs.com.br/sigasgi.apw/LOGIN",; 
	"DOCUMENT","http://webservices.totvs.com.br/sigasgi.apw",,"1.031217",; 
	"http://localhost/ws/SIGASGI.apw")

::Init()
::cLOGINRESULT       :=  WSAdvValue( oXmlRet,"_LOGINRESPONSE:_LOGINRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure KPIINDIC

WSSTRUCT SIGASGI_KPIINDIC
	WSDATA   nACTUTYPE                 AS integer
	WSDATA   nACUMTYPE                 AS integer
	WSDATA   cCOLRESPID                AS string
	WSDATA   cCOLRESPTYPE              AS string
	WSDATA   nDECIMAL                  AS integer
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cDOCUMENT                 AS string
	WSDATA   cENTITYID                 AS string
	WSDATA   nFREQUENCY                AS integer
	WSDATA   cGROUPID                  AS string
	WSDATA   cIMPORTCODE               AS string
	WSDATA   cINDRESPID                AS string
	WSDATA   cINDRESPTYPE              AS string
	WSDATA   lISASCENDANT              AS boolean
	WSDATA   lISCONSOLID               AS boolean
	WSDATA   lISPARENT                 AS boolean
	WSDATA   lISSTRATEGIC              AS boolean
	WSDATA   lISVISIBLE                AS boolean
	WSDATA   nLIMITDAY                 AS integer
	WSDATA   cNAME                     AS string
	WSDATA   cPARENTID                 AS string
	WSDATA   nSURPASS                  AS integer
	WSDATA   nTOLERANCE                AS integer
	WSDATA   cUNITID                   AS string
	WSDATA   cVERIFIC                  AS string
	WSDATA   nWEIGHT                   AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGASGI_KPIINDIC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGASGI_KPIINDIC
Return

WSMETHOD CLONE WSCLIENT SIGASGI_KPIINDIC
	Local oClone := SIGASGI_KPIINDIC():NEW()
	oClone:nACTUTYPE            := ::nACTUTYPE
	oClone:nACUMTYPE            := ::nACUMTYPE
	oClone:cCOLRESPID           := ::cCOLRESPID
	oClone:cCOLRESPTYPE         := ::cCOLRESPTYPE
	oClone:nDECIMAL             := ::nDECIMAL
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cDOCUMENT            := ::cDOCUMENT
	oClone:cENTITYID            := ::cENTITYID
	oClone:nFREQUENCY           := ::nFREQUENCY
	oClone:cGROUPID             := ::cGROUPID
	oClone:cIMPORTCODE          := ::cIMPORTCODE
	oClone:cINDRESPID           := ::cINDRESPID
	oClone:cINDRESPTYPE         := ::cINDRESPTYPE
	oClone:lISASCENDANT         := ::lISASCENDANT
	oClone:lISCONSOLID          := ::lISCONSOLID
	oClone:lISPARENT            := ::lISPARENT
	oClone:lISSTRATEGIC         := ::lISSTRATEGIC
	oClone:lISVISIBLE           := ::lISVISIBLE
	oClone:nLIMITDAY            := ::nLIMITDAY
	oClone:cNAME                := ::cNAME
	oClone:cPARENTID            := ::cPARENTID
	oClone:nSURPASS             := ::nSURPASS
	oClone:nTOLERANCE           := ::nTOLERANCE
	oClone:cUNITID              := ::cUNITID
	oClone:cVERIFIC             := ::cVERIFIC
	oClone:nWEIGHT              := ::nWEIGHT
Return oClone

WSMETHOD SOAPSEND WSCLIENT SIGASGI_KPIINDIC
	Local cSoap := ""
	cSoap += WSSoapValue("ACTUTYPE", ::nACTUTYPE, ::nACTUTYPE , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ACUMTYPE", ::nACUMTYPE, ::nACUMTYPE , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("COLRESPID", ::cCOLRESPID, ::cCOLRESPID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("COLRESPTYPE", ::cCOLRESPTYPE, ::cCOLRESPTYPE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DECIMAL", ::nDECIMAL, ::nDECIMAL , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DOCUMENT", ::cDOCUMENT, ::cDOCUMENT , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ENTITYID", ::cENTITYID, ::cENTITYID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FREQUENCY", ::nFREQUENCY, ::nFREQUENCY , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("GROUPID", ::cGROUPID, ::cGROUPID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("IMPORTCODE", ::cIMPORTCODE, ::cIMPORTCODE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("INDRESPID", ::cINDRESPID, ::cINDRESPID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("INDRESPTYPE", ::cINDRESPTYPE, ::cINDRESPTYPE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ISASCENDANT", ::lISASCENDANT, ::lISASCENDANT , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ISCONSOLID", ::lISCONSOLID, ::lISCONSOLID , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ISPARENT", ::lISPARENT, ::lISPARENT , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ISSTRATEGIC", ::lISSTRATEGIC, ::lISSTRATEGIC , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ISVISIBLE", ::lISVISIBLE, ::lISVISIBLE , "boolean", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("LIMITDAY", ::nLIMITDAY, ::nLIMITDAY , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NAME", ::cNAME, ::cNAME , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PARENTID", ::cPARENTID, ::cPARENTID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SURPASS", ::nSURPASS, ::nSURPASS , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TOLERANCE", ::nTOLERANCE, ::nTOLERANCE , "integer", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("UNITID", ::cUNITID, ::cUNITID , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VERIFIC", ::cVERIFIC, ::cVERIFIC , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("WEIGHT", ::nWEIGHT, ::nWEIGHT , "integer", .T. , .F., 0 , NIL, .F.) 
Return cSoap


