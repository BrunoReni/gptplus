#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/ws127/RHATTENDCONTROL.apw?WSDL
Gerado em        01/19/17 13:58:13
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _KOOXFKS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHATTENDCONTROL
------------------------------------------------------------------------------- */

WSCLIENT WSRHATTENDCONTROL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETATTENDCONTROL
	WSMETHOD GETPERBLOQ
	WSMETHOD GETPERIODS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cBRANCH                   AS string
	WSDATA   cREGISTRATION             AS string
	WSDATA   nCURRENTPAGE              AS integer
	WSDATA   cFILTERFIELD              AS string
	WSDATA   cFILTERVALUE              AS string
	WSDATA   oWSGETATTENDCONTROLRESULT AS RHATTENDCONTROL_TATTENDCONTROLBROWSE
	WSDATA   cWSNULL                   AS string
	WSDATA   cGETPERBLOQRESULT         AS string
	WSDATA   oWSGETPERIODSRESULT       AS RHATTENDCONTROL_TATTENDCONTROLBROWSE

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHATTENDCONTROL
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.131227A-20160707 NG] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHATTENDCONTROL
	::oWSGETATTENDCONTROLRESULT := RHATTENDCONTROL_TATTENDCONTROLBROWSE():New()
	::oWSGETPERIODSRESULT := RHATTENDCONTROL_TATTENDCONTROLBROWSE():New()
Return

WSMETHOD RESET WSCLIENT WSRHATTENDCONTROL
	::cBRANCH            := NIL 
	::cREGISTRATION      := NIL 
	::nCURRENTPAGE       := NIL 
	::cFILTERFIELD       := NIL 
	::cFILTERVALUE       := NIL 
	::oWSGETATTENDCONTROLRESULT := NIL 
	::cWSNULL            := NIL 
	::cGETPERBLOQRESULT  := NIL 
	::oWSGETPERIODSRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHATTENDCONTROL
Local oClone := WSRHATTENDCONTROL():New()
	oClone:_URL          := ::_URL 
	oClone:cBRANCH       := ::cBRANCH
	oClone:cREGISTRATION := ::cREGISTRATION
	oClone:nCURRENTPAGE  := ::nCURRENTPAGE
	oClone:cFILTERFIELD  := ::cFILTERFIELD
	oClone:cFILTERVALUE  := ::cFILTERVALUE
	oClone:oWSGETATTENDCONTROLRESULT :=  IIF(::oWSGETATTENDCONTROLRESULT = NIL , NIL ,::oWSGETATTENDCONTROLRESULT:Clone() )
	oClone:cWSNULL       := ::cWSNULL
	oClone:cGETPERBLOQRESULT := ::cGETPERBLOQRESULT
	oClone:oWSGETPERIODSRESULT :=  IIF(::oWSGETPERIODSRESULT = NIL , NIL ,::oWSGETPERIODSRESULT:Clone() )
Return oClone

// WSDL Method GETATTENDCONTROL of Service WSRHATTENDCONTROL

WSMETHOD GETATTENDCONTROL WSSEND cBRANCH,cREGISTRATION,nCURRENTPAGE,cFILTERFIELD,cFILTERVALUE WSRECEIVE oWSGETATTENDCONTROLRESULT WSCLIENT WSRHATTENDCONTROL
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETATTENDCONTROL xmlns="http://localhost:8080/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CURRENTPAGE", ::nCURRENTPAGE, nCURRENTPAGE , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERFIELD", ::cFILTERFIELD, cFILTERFIELD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FILTERVALUE", ::cFILTERVALUE, cFILTERVALUE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETATTENDCONTROL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8080/GETATTENDCONTROL",; 
	"DOCUMENT","http://localhost:8080/",,"1.031217",; 
	"http://localhost:8080/ws127/RHATTENDCONTROL.apw")

::Init()
::oWSGETATTENDCONTROLRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETATTENDCONTROLRESPONSE:_GETATTENDCONTROLRESULT","TATTENDCONTROLBROWSE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPERBLOQ of Service WSRHATTENDCONTROL

WSMETHOD GETPERBLOQ WSSEND cWSNULL WSRECEIVE cGETPERBLOQRESULT WSCLIENT WSRHATTENDCONTROL
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPERBLOQ xmlns="http://localhost:8080/">'
cSoap += WSSoapValue("WSNULL", ::cWSNULL, cWSNULL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETPERBLOQ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8080/GETPERBLOQ",; 
	"DOCUMENT","http://localhost:8080/",,"1.031217",; 
	"http://localhost:8080/ws127/RHATTENDCONTROL.apw")

::Init()
::cGETPERBLOQRESULT  :=  WSAdvValue( oXmlRet,"_GETPERBLOQRESPONSE:_GETPERBLOQRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPERIODS of Service WSRHATTENDCONTROL

WSMETHOD GETPERIODS WSSEND cBRANCH,cREGISTRATION WSRECEIVE oWSGETPERIODSRESULT WSCLIENT WSRHATTENDCONTROL
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPERIODS xmlns="http://localhost:8080/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETPERIODS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8080/GETPERIODS",; 
	"DOCUMENT","http://localhost:8080/",,"1.031217",; 
	"http://localhost:8080/ws127/RHATTENDCONTROL.apw")

::Init()
::oWSGETPERIODSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPERIODSRESPONSE:_GETPERIODSRESULT","TATTENDCONTROLBROWSE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TATTENDCONTROLBROWSE

WSSTRUCT RHATTENDCONTROL_TATTENDCONTROLBROWSE
	WSDATA   oWSFIELDS                 AS RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS OPTIONAL
	WSDATA   oWSITENS                  AS RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST OPTIONAL
	WSDATA   cPERIODFIELTER            AS string
	WSDATA   oWSPERIODS                AS RHATTENDCONTROL_ARRAYOFTPERIODLIST OPTIONAL
	WSDATA   cPERIODVIEW               AS string OPTIONAL
	WSDATA   nTOTMARC                  AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_TATTENDCONTROLBROWSE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_TATTENDCONTROLBROWSE
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_TATTENDCONTROLBROWSE
	Local oClone := RHATTENDCONTROL_TATTENDCONTROLBROWSE():NEW()
	oClone:oWSFIELDS            := IIF(::oWSFIELDS = NIL , NIL , ::oWSFIELDS:Clone() )
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
	oClone:cPERIODFIELTER       := ::cPERIODFIELTER
	oClone:oWSPERIODS           := IIF(::oWSPERIODS = NIL , NIL , ::oWSPERIODS:Clone() )
	oClone:cPERIODVIEW          := ::cPERIODVIEW
	oClone:nTOTMARC             := ::nTOTMARC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_TATTENDCONTROLBROWSE
	Local oNode1
	Local oNode2
	Local oNode4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_FIELDS","ARRAYOFTATTENDCONTROLFIELDS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSFIELDS := RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS():New()
		::oWSFIELDS:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFTATTENDCONTROLLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSITENS := RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST():New()
		::oWSITENS:SoapRecv(oNode2)
	EndIf
	::cPERIODFIELTER     :=  WSAdvValue( oResponse,"_PERIODFIELTER","string",NIL,"Property cPERIODFIELTER as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_PERIODS","ARRAYOFTPERIODLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSPERIODS := RHATTENDCONTROL_ARRAYOFTPERIODLIST():New()
		::oWSPERIODS:SoapRecv(oNode4)
	EndIf
	::cPERIODVIEW        :=  WSAdvValue( oResponse,"_PERIODVIEW","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTOTMARC           :=  WSAdvValue( oResponse,"_TOTMARC","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFTATTENDCONTROLFIELDS

WSSTRUCT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS
	WSDATA   oWSTATTENDCONTROLFIELDS   AS RHATTENDCONTROL_TATTENDCONTROLFIELDS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS
	::oWSTATTENDCONTROLFIELDS := {} // Array Of  RHATTENDCONTROL_TATTENDCONTROLFIELDS():New()
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS
	Local oClone := RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS():NEW()
	oClone:oWSTATTENDCONTROLFIELDS := NIL
	If ::oWSTATTENDCONTROLFIELDS <> NIL 
		oClone:oWSTATTENDCONTROLFIELDS := {}
		aEval( ::oWSTATTENDCONTROLFIELDS , { |x| aadd( oClone:oWSTATTENDCONTROLFIELDS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLFIELDS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TATTENDCONTROLFIELDS","TATTENDCONTROLFIELDS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTATTENDCONTROLFIELDS , RHATTENDCONTROL_TATTENDCONTROLFIELDS():New() )
			::oWSTATTENDCONTROLFIELDS[len(::oWSTATTENDCONTROLFIELDS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTATTENDCONTROLLIST

WSSTRUCT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST
	WSDATA   oWSTATTENDCONTROLLIST     AS RHATTENDCONTROL_TATTENDCONTROLLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST
	::oWSTATTENDCONTROLLIST := {} // Array Of  RHATTENDCONTROL_TATTENDCONTROLLIST():New()
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST
	Local oClone := RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST():NEW()
	oClone:oWSTATTENDCONTROLLIST := NIL
	If ::oWSTATTENDCONTROLLIST <> NIL 
		oClone:oWSTATTENDCONTROLLIST := {}
		aEval( ::oWSTATTENDCONTROLLIST , { |x| aadd( oClone:oWSTATTENDCONTROLLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_ARRAYOFTATTENDCONTROLLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TATTENDCONTROLLIST","TATTENDCONTROLLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTATTENDCONTROLLIST , RHATTENDCONTROL_TATTENDCONTROLLIST():New() )
			::oWSTATTENDCONTROLLIST[len(::oWSTATTENDCONTROLLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTPERIODLIST

WSSTRUCT RHATTENDCONTROL_ARRAYOFTPERIODLIST
	WSDATA   oWSTPERIODLIST            AS RHATTENDCONTROL_TPERIODLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_ARRAYOFTPERIODLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_ARRAYOFTPERIODLIST
	::oWSTPERIODLIST       := {} // Array Of  RHATTENDCONTROL_TPERIODLIST():New()
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_ARRAYOFTPERIODLIST
	Local oClone := RHATTENDCONTROL_ARRAYOFTPERIODLIST():NEW()
	oClone:oWSTPERIODLIST := NIL
	If ::oWSTPERIODLIST <> NIL 
		oClone:oWSTPERIODLIST := {}
		aEval( ::oWSTPERIODLIST , { |x| aadd( oClone:oWSTPERIODLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_ARRAYOFTPERIODLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TPERIODLIST","TPERIODLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTPERIODLIST , RHATTENDCONTROL_TPERIODLIST():New() )
			::oWSTPERIODLIST[len(::oWSTPERIODLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TATTENDCONTROLFIELDS

WSSTRUCT RHATTENDCONTROL_TATTENDCONTROLFIELDS
	WSDATA   cBRANCH                   AS string
	WSDATA   cCOSTCENTER               AS string
	WSDATA   cDEPARTMENT               AS string
	WSDATA   cNAME                     AS string
	WSDATA   cREGISTRATION             AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_TATTENDCONTROLFIELDS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_TATTENDCONTROLFIELDS
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_TATTENDCONTROLFIELDS
	Local oClone := RHATTENDCONTROL_TATTENDCONTROLFIELDS():NEW()
	oClone:cBRANCH              := ::cBRANCH
	oClone:cCOSTCENTER          := ::cCOSTCENTER
	oClone:cDEPARTMENT          := ::cDEPARTMENT
	oClone:cNAME                := ::cNAME
	oClone:cREGISTRATION        := ::cREGISTRATION
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_TATTENDCONTROLFIELDS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBRANCH            :=  WSAdvValue( oResponse,"_BRANCH","string",NIL,"Property cBRANCH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOSTCENTER        :=  WSAdvValue( oResponse,"_COSTCENTER","string",NIL,"Property cCOSTCENTER as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDEPARTMENT        :=  WSAdvValue( oResponse,"_DEPARTMENT","string",NIL,"Property cDEPARTMENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cREGISTRATION      :=  WSAdvValue( oResponse,"_REGISTRATION","string",NIL,"Property cREGISTRATION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TATTENDCONTROLLIST

WSSTRUCT RHATTENDCONTROL_TATTENDCONTROLLIST
	WSDATA   cBONUSREASON              AS string
	WSDATA   cBRANCH                   AS string
	WSDATA   cDATEEVENT                AS string
	WSDATA   cDAYWEEK                  AS string
	WSDATA   oWSMARKS                  AS RHATTENDCONTROL_ARRAYOFTMARKLIST OPTIONAL
	WSDATA   cOBSERVATIONS             AS string
	WSDATA   cREGISTRATION             AS string
	WSDATA   cUPDATE                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_TATTENDCONTROLLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_TATTENDCONTROLLIST
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_TATTENDCONTROLLIST
	Local oClone := RHATTENDCONTROL_TATTENDCONTROLLIST():NEW()
	oClone:cBONUSREASON         := ::cBONUSREASON
	oClone:cBRANCH              := ::cBRANCH
	oClone:cDATEEVENT           := ::cDATEEVENT
	oClone:cDAYWEEK             := ::cDAYWEEK
	oClone:oWSMARKS             := IIF(::oWSMARKS = NIL , NIL , ::oWSMARKS:Clone() )
	oClone:cOBSERVATIONS        := ::cOBSERVATIONS
	oClone:cREGISTRATION        := ::cREGISTRATION
	oClone:cUPDATE              := ::cUPDATE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_TATTENDCONTROLLIST
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBONUSREASON       :=  WSAdvValue( oResponse,"_BONUSREASON","string",NIL,"Property cBONUSREASON as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cBRANCH            :=  WSAdvValue( oResponse,"_BRANCH","string",NIL,"Property cBRANCH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATEEVENT         :=  WSAdvValue( oResponse,"_DATEEVENT","string",NIL,"Property cDATEEVENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDAYWEEK           :=  WSAdvValue( oResponse,"_DAYWEEK","string",NIL,"Property cDAYWEEK as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_MARKS","ARRAYOFTMARKLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSMARKS := RHATTENDCONTROL_ARRAYOFTMARKLIST():New()
		::oWSMARKS:SoapRecv(oNode5)
	EndIf
	::cOBSERVATIONS      :=  WSAdvValue( oResponse,"_OBSERVATIONS","string",NIL,"Property cOBSERVATIONS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cREGISTRATION      :=  WSAdvValue( oResponse,"_REGISTRATION","string",NIL,"Property cREGISTRATION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cUPDATE            :=  WSAdvValue( oResponse,"_UPDATE","string",NIL,"Property cUPDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TPERIODLIST

WSSTRUCT RHATTENDCONTROL_TPERIODLIST
	WSDATA   cFIELTER                  AS string
	WSDATA   cVALUEFIELTER             AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_TPERIODLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_TPERIODLIST
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_TPERIODLIST
	Local oClone := RHATTENDCONTROL_TPERIODLIST():NEW()
	oClone:cFIELTER             := ::cFIELTER
	oClone:cVALUEFIELTER        := ::cVALUEFIELTER
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_TPERIODLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFIELTER           :=  WSAdvValue( oResponse,"_FIELTER","string",NIL,"Property cFIELTER as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVALUEFIELTER      :=  WSAdvValue( oResponse,"_VALUEFIELTER","string",NIL,"Property cVALUEFIELTER as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFTMARKLIST

WSSTRUCT RHATTENDCONTROL_ARRAYOFTMARKLIST
	WSDATA   oWSTMARKLIST              AS RHATTENDCONTROL_TMARKLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_ARRAYOFTMARKLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_ARRAYOFTMARKLIST
	::oWSTMARKLIST         := {} // Array Of  RHATTENDCONTROL_TMARKLIST():New()
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_ARRAYOFTMARKLIST
	Local oClone := RHATTENDCONTROL_ARRAYOFTMARKLIST():NEW()
	oClone:oWSTMARKLIST := NIL
	If ::oWSTMARKLIST <> NIL 
		oClone:oWSTMARKLIST := {}
		aEval( ::oWSTMARKLIST , { |x| aadd( oClone:oWSTMARKLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_ARRAYOFTMARKLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TMARKLIST","TMARKLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTMARKLIST , RHATTENDCONTROL_TMARKLIST():New() )
			::oWSTMARKLIST[len(::oWSTMARKLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TMARKLIST

WSSTRUCT RHATTENDCONTROL_TMARKLIST
	WSDATA   cMARKSITENS               AS string
	WSDATA   cMARKSTYPE                AS string
	WSDATA   cOBSERVATION              AS string
	WSDATA   cREQUESTREC               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHATTENDCONTROL_TMARKLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHATTENDCONTROL_TMARKLIST
Return

WSMETHOD CLONE WSCLIENT RHATTENDCONTROL_TMARKLIST
	Local oClone := RHATTENDCONTROL_TMARKLIST():NEW()
	oClone:cMARKSITENS          := ::cMARKSITENS
	oClone:cMARKSTYPE           := ::cMARKSTYPE
	oClone:cOBSERVATION         := ::cOBSERVATION
	oClone:cREQUESTREC          := ::cREQUESTREC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHATTENDCONTROL_TMARKLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cMARKSITENS        :=  WSAdvValue( oResponse,"_MARKSITENS","string",NIL,"Property cMARKSITENS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMARKSTYPE         :=  WSAdvValue( oResponse,"_MARKSTYPE","string",NIL,"Property cMARKSTYPE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOBSERVATION       :=  WSAdvValue( oResponse,"_OBSERVATION","string",NIL,"Property cOBSERVATION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cREQUESTREC        :=  WSAdvValue( oResponse,"_REQUESTREC","string",NIL,"Property cREQUESTREC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


