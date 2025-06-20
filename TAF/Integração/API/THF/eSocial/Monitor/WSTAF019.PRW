#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEsocialEvents
@type			method
@description	Servi�o para obter os eventos do eSocial.
@author			Matheus Prada
@since			06/04/2020
/*/
//---------------------------------------------------------------------
WSRESTFUL TAFEsocialEvents DESCRIPTION "Consulta da lista de eventos do eSocial" FORMAT APPLICATION_JSON

	WSDATA companyId				AS STRING
	WSDATA eventsCheckPermissions 	AS STRING OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "M�todo para obter a lista de eventos do eSocial";
		WSSYNTAX "api/rh/esocial/v1/TAFEsocialEvents/?{companyId}&{eventsCheckPermissions}";
		PATH "api/rh/esocial/v1/TAFEsocialEvents/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	M�todo para obter a lista de eventos do eSocial.
@author			Matheus Prada
@since			06/04/2020
@return			lRet	-	Indica se o m�todo aceitou a execu��o do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, eventsCheckPermissions WSRESTFUL TAFEsocialEvents

	Local oResponse		:= JsonObject():New()
	Local cEvtsNT		:= Iif(ExistFunc("TAFEvtsNT"), TAFEvtsNT(), "")
	Local cEmpRequest	:= ""
	Local cFilRequest	:= ""
	Local aCompany		:= {}
	Local lAmbiente		:= .T.
	Local lRet			:= .T.
	Local cUserTAF		:= __cUserId

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial n�o informado no par�metro 'companyId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial n�o informado no par�metro 'companyId'." ) )
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
				oResponse["items"] := {}
				GetEvents( self:eventsCheckPermissions, cEvtsNT, @oResponse, cUserTAF )
				self:SetResponse( oResponse:ToJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na prepara��o do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf

	FreeObj( oResponse )
	oResponse := Nil
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} getEvents
	Obtem lista de eventos da TAFRotinas e adiciona mais informa��es
	@type  Static Function
	@author Alexandre Lima | Fabio Mendon�a
	@since 05/12/2021
	@version 1.0
	@param eventsCheckPermissions, string, Eventos a checar permiss�o
	@param cEvtsNT, string, Eventos de NT a n�o retornar
	@param oResponse, JsonObject, Objeto JSON de retorno
	@return void
/*/
//---------------------------------------------------------------------
Static Function GetEvents( eventsCheckPermissions, cEvtsNT, oResponse, cUserTAF )

	Local nScan     := Iif( eventsCheckPermissions == Nil, Nil, 4 )
	Local lAll      := Iif( eventsCheckPermissions == Nil, Nil, .F. )
	Local aEvents   := Iif( eventsCheckPermissions == Nil, [], StrTokArr( eventsCheckPermissions, "|" ) )
	Local nPosReg   := 0
	Local aRoutines := {}
	Local nI
	Local lLayAtivo := TafLayESoc(,.T.)


	For nI := 1 to Len( aEvents )
		AADD( aRoutines, TAFRotinas( aEvents[nI], nScan, lAll, 2, lLayAtivo ))	
	Next nI

	If Len( aEvents ) < 1
		aRoutines := TAFRotinas(,,, 2, lLayAtivo)
	ElseIf Len( aEvents ) > 1
		aSort( aRoutines,,, { |x,y| x[4] < y[4] } )
	EndIf

	DBSelectArea( "C8E" )
	C8E->( DBSetOrder( 2 ) )
	
	For nI := 1 to Len( aRoutines )

		If !Empty( aRoutines[nI,4] ) .AND. C8E->( MsSeek( xFilial( "C8E" ) + aRoutines[nI,4] ) ) .AND. !aRoutines[nI,4] $ cEvtsNT

			nPosReg ++

			aAdd( oResponse["items"], JsonObject():New() )
			oResponse["items"][nPosReg]["eventCode"]		:=	EncodeUTF8( C8E->C8E_CODIGO )
			oResponse["items"][nPosReg]["eventDescription"]	:=	EncodeUTF8( Upper(Alltrim(C8E->C8E_DESPRT)))
			oResponse["items"][nPosReg]["permissionEvent"]	:=	MPUserHasAccess( aRoutines[nI, 20],,cUserTAF )

		EndIf

	Next nI

Return
