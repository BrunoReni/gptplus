#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "GPEA012API.CH"

#DEFINE PAGE_DEF		1
#DEFINE PAGESIZE_DEF	15
#DEFINE ERRORCODE_DEF	400

Static __aSM0	:=	Nil


/*/{Protheus.doc} WSRESTFUL monitorEsocial
Servi�o de retorno de filiais de acordo com os par�metros informados
STR0001: "Servi�o do Monitor de Transmiss�o do eSocial"
STR0002: "M�todo para consultar as filiais para a transmiss�o dos eventos do E-Social"
STR0003: "api/rh/esocial/v1/GPEEsocialBranches/?{companyId}&{page}&{pageSize}"
STR0004: "api/rh/esocial/v1/GPEEsocialBranches/"
STR0005: "v1"
@author  Hugo de Oliveira
@since   05/11/2019
@version 12.1.25
/*/
WSRESTFUL GPEEsocialBranches DESCRIPTION oEmToAnsi( STR0001 )  FORMAT APPLICATION_JSON
	WSDATA companyId	AS STRING
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL
	
	WSMETHOD GET DESCRIPTION oEmToAnsi( STR0002 ) ; 
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialBranches/?{companyId}&{page}&{pageSize}"; 
	PATH "api/rh/esocial/v1/GPEEsocialBranches/"; 
	TTALK "v1"; 
	PRODUCES APPLICATION_JSON   
END WSRESTFUL


/*/{Protheus.doc} WSMETHOD GET GPEEsocialBranches
Retorna as filiais de acordo com os par�metros informados
@author  Hugo de Oliveira
@since   05/11/2019
@version 12.1.25
/*/
WSMETHOD GET QUERYPARAM companyId, page, pageSize WSRESTFUL GPEEsocialBranches
	Local oResponse		:=	Nil
	Local cEmpRequest	:=	""
	Local cFilRequest	:=	""
	Local nPage			:=	1
	Local nPageSize		:=	1
	Local aCompany		:=	{}
	Local lAmbiente		:=	.T.
	Local lRet			:=	.T.
	Local cCompId		:= ""
	
	DEFAULT Self:companyId 		:= {}
	DEFAULT Self:page 			:= PAGE_DEF
	DEFAULT Self:pageSize 		:= PAGESIZE_DEF
		
	cCompId    := Self:companyId
	nPage 	   := Self:page
	nPageSize  := Self:pageSize
	
	If Empty( cCompId )
		lRet := .F.
		SetRestFault( ERRORCODE_DEF, EncodeUTF8( STR0006 ) ) // STR0006: "Grupo, Empresa e Filial logada n�o foram informados no par�metro 'companyId'."
	Else
		aCompany := StrTokArr( cCompId, "|" )
	
		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( ERRORCODE_DEF, EncodeUTF8( STR0006 ) ) // STR0006: "Grupo, Empresa e Filial logada n�o foram informados no par�metro 'companyId'."
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]
	
			If Type( "cEmpAnt" ) == "U" .or. Type( "cFilAnt" ) == "U"
				RPCClearEnv()
				RPCSetType( 3 )
				RPCSetEnv( cEmpRequest, cFilRequest,,, "TAF" )
			
			ElseIf cEmpAnt <> cEmpRequest
				If FWFilExist( cEmpRequest, cFilRequest )
					RPCClearEnv()
					RPCSetType( 3 )
					RPCSetEnv( cEmpRequest, cFilRequest,,, "TAF" )
				Else
					lAmbiente := .F.
				EndIf
			
			ElseIf cFilAnt <> cFilRequest
				cFilAnt := cFilRequest
			EndIf
	
			If lAmbiente .and. FWFilExist( cEmpRequest, cFilRequest )
				fLoadSM0()
	            fGetBranch( @oResponse, cEmpRequest, nPage, nPageSize )
	            self:SetResponse( oResponse:ToJson() )
			Else
				lRet := .F.
				// STR0007: "Falha na prepara��o do ambiente para a Empresa '". STR0008: "' e Filial '".
				SetRestFault( ERRORCODE_DEF, EncodeUTF8( STR0007 ) + cEmpRequest + EncodeUTF8( STR0008 ) + cFilRequest + "'." )
			EndIf
		EndIf
	EndIf
	
	oResponse := Nil
	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )


/*/{Protheus.doc} function fGetBranch
Retorna as filiais de acordo com os par�metros informados
@author  Hugo de Oliveira
@since   05/11/2019
@version 12.1.25
/*/
Static Function fGetBranch( oResponse, cCompanyId, nPage, nPageSize )
	Local nX        :=  1
	Local nRegIni	:=	1
	Local nRegFim	:=	1
	
	nRegIni := ( ( nPage - 1 ) * nPageSize ) + 1
	nRegFim := nPage * nPageSize
	
	oResponse          := JsonObject():New()
	oResponse["items"] := {}
	
	For nX := nRegIni To nRegFim
	    If nX <= Len(__aSM0)
			If cCompanyId == ALLTRIM(__aSM0[nX][1])
	       	 	aAdd( oResponse["items"], JsonObject():New() )
		    	oResponse["items"][Len(oResponse["items"])]["branchCode"]	        := Rtrim(__aSM0[nX][2])
	        	oResponse["items"][Len(oResponse["items"])]["branchDescription"]	:= EncodeUTF8( Rtrim( StrTran( Upper( __aSM0[nX][7] ), "FILIAL", "" ) ) )
	   		EndIf
	    EndIf
	Next nX
	
	oResponse["hasNext"] := Iif( Len(__aSM0) > nRegFim, .T., .F.)
Return


/*/{Protheus.doc} function fLoadSM0
Realiza o carregamento da tabela SM0
@author  Hugo de Oliveira
@since   05/11/2019
@version 12.1.25
/*/
Static Function fLoadSM0()
	If __aSM0 == Nil
		__aSM0 := FWLoadSM0()
	EndIf
Return()
