#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"


#DEFINE PAGE_DEF		1
#DEFINE PAGESIZE_DEF	15
#DEFINE ERRORCODE_DEF	400

Static __aSM0	:=	Nil


/*/{Protheus.doc} WSRESTFUL monitorEsocial
Serviço de retorno de filiais de acordo com os parâmetros informados
@author  Totvs
@since   05/11/2019
@version 12.1.25
/*/
WSRESTFUL TAFEsocialBranches DESCRIPTION oEmToAnsi( "Serviço do Monitor de Transmissão do eSocial (TAFFULL) " ) FORMAT APPLICATION_JSON
	
	WSDATA companyId	AS STRING	
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL
	
	WSMETHOD GET DESCRIPTION oEmToAnsi( "Método para consultar as filiais para a transmissão dos eventos do E-Social" ) WSSYNTAX "api/rh/esocial/v1/TAFEsocialBranches/?{companyId}&{page}&{pageSize}" PATH "api/rh/esocial/v1/TAFEsocialBranches/" TTALK "v1" PRODUCES APPLICATION_JSON

END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET TAFEsocialBranches
Retorna as filiais de acordo com os parâmetros informados
@author  Totvs
@since   05/11/2019
@version 12.1.25
/*/
WSMETHOD GET QUERYPARAM companyId, page, pageSize WSRESTFUL TAFEsocialBranches

	Local oResponse   := Nil
	Local cEmpRequest := ""
	Local cFilRequest := ""
	Local nPage       := 1
	Local nPageSize   := 1
	Local aCompany    := {}
	Local lAmbiente   := .T.
	Local lRet        := .T.
	Local cCompId     := ""
		
	DEFAULT Self:companyId 		:= {}	
	DEFAULT Self:page 			:= PAGE_DEF
	DEFAULT Self:pageSize 		:= PAGESIZE_DEF
		
	cCompId    := Self:companyId	
	nPage 	   := Self:page
	nPageSize  := Self:pageSize
	cAuth 	   := self:GetHeader("Authorization")
	If Empty( cCompId )

		lRet := .F.
		SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Grupo, Empresa e Filial logada não foram informados no parâmetro 'companyId'." ) )

	Else

		aCompany := StrTokArr( cCompId, "|" )
	
		If Len( aCompany ) < 2

			lRet := .F.
			SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Grupo, Empresa e Filial logada não foram informados no parâmetro 'companyId'." ) ) 

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
	            fGetBranch( @oResponse, cEmpRequest, cFilRequest, nPage, nPageSize,cAuth )
	            self:SetResponse( oResponse:ToJson() )
			Else
				lRet := .F.
				SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" ) + cEmpRequest + EncodeUTF8( "' e Filial '" ) + cFilRequest + "'." )
			EndIf

		EndIf

	EndIf
	
	oResponse := Nil
	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

/*/{Protheus.doc} function fGetBranch
Retorna as filiais de acordo com os parâmetros informados
@author  Totvs
@since   05/11/2019
@version 12.1.25
/*/
Static Function fGetBranch( oResponse as object, cCompanyId as character, cBranchId as character, nPage as numeric, nPageSize as numeric, cAuth as character )
	
	Local aESocBranches as array
	Local aProdRur      as array
	Local aRetPsw		as array
	Local aGrupo		as array
	Local cEmp          as character
	Local cRaizCNPJ     as character
	Local cUserId 		as character
	Local cFil			as character
	Local lPrioriza     as logical	
	Local nPosBranch    as numeric
	Local nRegFim       as numeric
	Local nRegIni       as numeric
	Local nX            as numeric
	Local nY            as numeric

	Default cAuth 		:= ""

	aESocBranches 		:= {}
	aRetPsw				:= {}
	cEmp          		:= ""
	cRaizCNPJ     		:= ""
	cUserId    			:= getIdUser(cAuth)
	cFil				:= ""
	lPrioriza			:= .F.
	nRegFim       		:= 1
	nRegIni       		:= 1
	nX            		:= 1
	nY					:= 0
	nRegIni 			:= ( ( nPage - 1 ) * nPageSize ) + 1
	nRegFim 			:= nPage * nPageSize
	
	oResponse           := JsonObject():New()
	oResponse["items"]  := {}

	//Utilizado para obter o CNPJ da filial recebida por parâmetro
	nPosBranch := aScan( __aSM0, { |x| AllTrim( x[1] ) == AllTrim( cCompanyId ) .and. AllTrim( x[2] ) == AllTrim( cBranchId ) } )
	aProdRur   := VProdRural()

	If PswSeek( cUserId , .T. )  
		aRetPsw := PswRet() // Retorna vetor com informações do usuário
		aGrupo := aRetPsw[1][10] // Array com o grupo de usuário
		lPrioriza := aRetPsw[2][11] // Priorizar configuração do grupo
	EndIf
	
	If lPrioriza .AND. Len(aGrupo) > 0
		For nY := 1 To Len(aGrupo)
			cFil += ArrTokStr(FWGrpEmp( aGrupo[nY] ),"|") // Retorna Empresa e filial do Grupo de Usuário			 
		Next
	Else
		cFil := ArrTokStr(aRetPsw[2][6],"|") 
	EndIf	
		
	If nPosBranch > 0
		If Len( aProdRur ) > 0
			aESocBranches := aProdRur
			cEmp := aProdRur[1][7]
		Else
			cRaizCNPJ := SubStr( __aSM0[nPosBranch][18], 1, 8 )
			
			//Monta a cláusula IN com as filiais do grupo de empresas logado--
			aEval( __aSM0, { |x| Iif( !Empty(x[18]) .And. x[1] == cCompanyId .And. (Alltrim(x[2]) $ cFil .Or. '@' $ cFil) .And. ( SubStr( x[18], 1, 8 ) == cRaizCNPJ .Or. Len( Alltrim( x[18] ) ) == 11) , aAdd( aESocBranches, { x[1], x[2], x[7] } ) , Nil ) } )
		EndIf

		For nX := nRegIni To nRegFim
			If nX <= Len( aESocBranches )
				If cCompanyId == ALLTRIM( aESocBranches[nX][1] ) .Or. ( cEmp == cCompanyId )
					aAdd( oResponse["items"], JsonObject():New() )
					oResponse["items"][Len( oResponse["items"] )]["branchCode"]	        := aESocBranches[nX][2]
					oResponse["items"][Len( oResponse["items"] )]["branchDescription"]	:= EncodeUTF8( Rtrim( StrTran( Upper( aESocBranches[nX][3] ), "FILIAL", "" ) ) )
				EndIf
			EndIf
		Next nX

		oResponse["hasNext"] := Iif( Len( aESocBranches ) > nRegFim, .T., .F. )

	EndIf

Return

/*/{Protheus.doc} function fLoadSM0
Realiza o carregamento da tabela SM0
@author  Totvs
@since   05/11/2019
@version 12.1.25
/*/
Static Function fLoadSM0()

	If __aSM0 == Nil
		__aSM0 := FWLoadSM0()
	EndIf
	
Return()


/*/{Protheus.doc} function getIdUser
Realiza a busca do id do usuário logado
@author  José Riquelmo/ Melkz Siqueira
@since   10/11/2022
@version 12.1.33
/*/
Static Function getIdUser(cAuth as character)

	Local cUserId 	as character
	local oAuth 	as object
	
	cUserId := '000000'
	oAuth 	:= Nil
	
	cAuth := AllTrim(StrTran(cAuth, "Bearer"))
	
	If FwJWTValid(cAuth, @oAuth)
		
		cUserId := oAuth:PAYLOAD:USERID

	EndIf 

Return cUserId
