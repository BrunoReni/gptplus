#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "topconn.ch"
#INCLUDE "WSMIDESTAB.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE PAGE_DEF		1
#DEFINE PAGESIZE_DEF	15
#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )


/*/{Protheus.doc} Class GPEEsocialEstablishment
Classe para consulta de Informa��es de Estabelecimentos
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
	STR0001: "Servi�o gen�rico para retorno das informa��es de Estabelecimentos do Microsiga Protheus."
	STR0002: "application/json"
/*/
WSRESTFUL GPEEsocialEstablishment DESCRIPTION oEmToAnsi( STR0001 ) FORMAT STR0002
	WSDATA companyId 	As String
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL

	/*
		STR0003: "M�todo para consultar o detalhamento dos Estabelecimentos"
		STR0004: "api/rh/esocial/v1/GPEEsocialEstablishment/"
		STR0005: "v1"
	*/
	WSMETHOD GET DESCRIPTION oEmToAnsi( STR0003 ); 
	PRODUCES APPLICATION_JSON ;
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialEstablishment/"; 
	PATH "api/rh/esocial/v1/GPEEsocialEstablishment/"; 
	TTALK "v1"
END WSRESTFUL


/*/{Protheus.doc} Method GET
M�todo de retorno de Estabelecimentos
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
WSMETHOD GET QUERYPARAM companyId, page, pageSize WSSERVICE GPEEsocialEstablishment
	Local nPage			:=	1
	Local nPageSize		:=	1
	Local cRet 			:= ""
	Local cCompId 	 	:= ""
	Local lRet 			:= .T.
	Local aAmb			:= {}
	Local aData			:= {}

	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )
	Private oError

	DEFAULT Self:companyId 	:= ""
	DEFAULT Self:page		:= PAGE_DEF
	DEFAULT Self:pageSize 	:= PAGESIZE_DEF

	cCompId		:= Self:companyId
	nPage 	   	:= Self:page
	nPageSize  	:= Self:pageSize

	BEGIN SEQUENCE
		aAmb 	:= StrTokArr( cCompId, "|")
		
		// Pr� Valida��es
		IF lRet := fPreValid( aAmb )
			
			// Seta nPageSize e nPage
			IF (nPageSize < 1) .OR. (nPageSize > PAGESIZE_DEF)
				nPageSize := PAGESIZE_DEF
			EndIf

			If nPage < 1
				nPage := 1
			EndIf

			// Inicializa��o de Ambiente
			fSetErrorHandler( EncodeUTF8( STR0006 ) ) // STR0006: "Falha ao Inicializar o Ambiente com os dados informados!"
				RPCSetType( 3 )
				PREPARE ENVIRONMENT EMPRESA aAmb[1] FILIAL aAmb[2] TABLES "RJE" MODULO "GPE"
			fResetErrorHandler()

			// Realiza o preenchimento das Propriedades que ser�o retornadas na API
			aData := fGetData( aAmb )

			// Monta estrutura de Retorno
			cRet := fReturn( aData, nPage, nPageSize )
			::SetResponse( cRet )
		EndIf

	RECOVER
		lRet := .F.
		ErrorBlock( bErrorBlock )
		SetRestFault( ERRORSRV_DEF, EncodeUTF8( STR0007 ) + TAB + oError:Description ) // STR0007: "Ocorreu uma falha no retorno da informa��o."
	END SEQUENCE

Return lRet	


/*/{Protheus.doc} function fPreValid
Fun��o que realiza valida��o dos par�metros obrigat�rios
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fPreValid( aAmb )
	Local cMessage	:= ""
	Local lRet 	   	:= .T.
	
	DEFAULT aAmb := {}

	If Empty( aAmb )
		cMessage := STR0008 // STR0008: "O par�metro companyId � obrigat�rio."
		lRet 	 := .F.
	EndIf

	If !lRet
		SetRestFault( ERRORCODE_DEF, EncodeUTF8( cMessage ) )
	EndIf
Return lRet


/*/{Protheus.doc} function fGetData
Fun��o que realiza a consulta dos dados no banco
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fGetData( aAmb )
	Local aAux		:= {}
	Local aData		:= {}
	Local aRep		:= {}
	Local cAliasRJE := "RJE"
	Local cEvent	:= "S1005"

	DEFAULT aAmb := {}

	fSetErrorHandler( EncodeUTF8( STR0009 ) ) // STR0009: "Falha ao buscar dados do Estabelecimento!"
		DbSelectArea( cAliasRJE )
		DbSetOrder( 3 )
		( cAliasRJE )->( DbGoTop() )
		DbSeek( cEvent )

		aData := {}
		While ( cAliasRJE )->( !EOF() ) .AND. cEvent == ALLTRIM( ( cAliasRJE )->RJE_EVENTO )
			If ALLTRIM( ( cAliasRJE )->RJE_STATUS ) == "4" .AND. ASCAN(aRep, ALLTRIM( ( cAliasRJE )->RJE_KEY ) ) == 0
				AADD( aRep, ALLTRIM( ( cAliasRJE )->RJE_KEY ) )
				aAux  := {}
				AADD( aAux, aAmb[1] + "|" +  ALLTRIM( ( cAliasRJE )->RJE_FIL ) ) 	// companyId - Filial Origem
				AADD( aAux, ""  ) 			// registrationType
				AADD( aAux, SUBSTR(ALLTRIM( ( cAliasRJE )->RJE_KEY ), FwGetTamFilial + 1, LEN(ALLTRIM( ( cAliasRJE )->RJE_KEY ))) ) // registrationNumber
				AADD( aAux, "" ) // description
				AADD( aData, aAux )
			EndIf
			( cAliasRJE )->( dbSkip() )
		EndDo
	fResetErrorHandler()
Return aData


/*/{Protheus.doc} function fReturn
Fun��o que monta a estrutura de retorno
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fReturn( aData, nPage, nPageSize )
	Local oRet
	Local oItems
	Local nX		:= 1
	Local nRegIni	:= 1
	Local nRegFim	:= 1
	Local cRet		:= ""
	Local aItems	:= {}
	
	DEFAULT aData := {}

	oRet := JsonObject():new()

	If !Empty( aData )
		fSetErrorHandler( EncodeUTF8( STR0010 ) ) // STR0010: "Falha na montagem da estrutura de retorno da API de Estabelecimentos!"
			
			If !Empty( aData )
				aItems := {}

				// Pagina��o
				nRegIni := ( ( nPage - 1 ) * nPageSize ) + 1
				nRegFim := nPage * nPageSize

				For nX := nRegIni To nRegFim
					If nX <= Len( aData )
						oItems := JsonObject():new()
						oItems["companyId"] 			:= aData[nX][1]
						oItems["registrationType"] 		:= aData[nX][2]
						oItems["registrationNumber"] 	:= aData[nX][3]
						oItems["description"] 			:= aData[nX][4]

						AAdd( aItems, oItems )
						FreeObj( oItems )
					EndIf
				Next nX
			EndIf

		fResetErrorHandler()
	EndIf

	oRet["hasNext"] := Iif( Len( aData ) > nRegFim, .T., .F.)
	oRet["items"] 	:= aItems

	// Compacta��o e convers�o do Objeto em String
	cRet := fCompress( oRet )
	FreeObj( oRet )
Return cRet


/*/{Protheus.doc} function fCompress
Fun��o que comprime e converte a estrutura JSON em Texto
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := oObj:toJSON()
	
	cJson := EncodeUTF8(cJson)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf
	
	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif
Return cComp


/*/{Protheus.doc} function fSetErrorHandler
Fun��o para setar erros tratados
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fSetErrorHandler( cTitle )
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock	:= ErrorBlock( bError )
Return .T.


/*/{Protheus.doc} function fResetErrorHandler
Fun��o para limpar o retorno de erros
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fResetErrorHandler( cTitle )
	bError  	:= { |e| oError := e , Break( e ) }
	bErrorBlock := ErrorBlock( bError )
Return .T.
