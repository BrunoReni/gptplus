#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "WSMIDCARD.CH"                                                                                                                                                                                                                                                  

#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )

Private oError
Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )

// STR0001: "Servi�o do Monitor de Transmiss�o do eSocial"
WSRESTFUL GPEEsocialMonitorHomeCards DESCRIPTION OemToAnsi( STR0001 ) FORMAT APPLICATION_JSON 
	WSDATA authorization As String
	WSDATA branches	     As String
	WSDATA period	     As String
	WSDATA events	     As String

/*
	STR0002: "M�todo para consulta dos cards acumuladores dos eventos no eSocial"
	STR0003: "api/rh/esocial/v1/GPEEsocialMonitorHomeCards"
	STR0004: "v1" 
*/
	WSMETHOD POST DESCRIPTION oEmToAnsi( STR0002 ); 
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialMonitorHomeCards"; 
	PATH "api/rh/esocial/v1/GPEEsocialMonitorHomeCards"; 
	TTALK "v1"; 
	PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST WSREST GPEEsocialMonitorHomeCards
	Local oEvents
	Local oStatus
	Local oItems
	Local oInput
	Local nTotal	:= 0
	Local nEvt 		:= 1
	Local nY		:= 1
	Local nZ		:= 1
	Local cRet		:= ""
	Local cStatus	:= ""
	Local cPeriod	:= ""
	Local aStatus	:= {}
	Local aDados	:= {}
	Local aItems	:= {}
	Local aAmb		:= {}
	Local aEvent	:= {}
	Local lRet		:= .T.
	Local cBody		:= ""
	Local cPerFrom	:= ""
	Local cPerTo	:= ""

	cBody     	:= ::GetContent()
	oInput 		:= JsonObject():New()
	oInput:FromJson( cBody )
	
	BEGIN SEQUENCE
		IF !fPreValid( oInput )
			lRet := .F.
		EndIf

		// Prepare Environment
		If lRet
			fSetErrorHandler( EncodeUTF8( STR0005 ) ) // STR0005: "Erro ao preparar o ambiente com a Empresa e Filial informados!"
			
			// Inicializa��o de Ambiente
			aAmb := STRTOKARR( oInput["companyId"], "|")
			
			RPCSetType(3)
			PREPARE ENVIRONMENT EMPRESA aAmb[1] FILIAL aAmb[2] TABLES "RJE" MODULO "GPE"
			fResetErrorHandler()
			
			aEvent 		:= oInput["events"]
			cPeriod		:= oInput["period"]
			aBranches	:= oInput["branches"]
			cPerFrom	:= oInput["periodFrom"]
			cPerTo		:= oInput["periodTo"]
			
			// Percorre todos os eventos filtrados
			For nEvt := 1 To LEN( aEvent )
				nTotal 	:= 0
				aStatus := {}
				oEvents := JsonObject():new()
				aDados 	:= fGetData( aEvent[nEvt], cPeriod, aBranches, cPerFrom, cPerTo) // Verifica se existem dados a serem retornados
				
				oEvents["eventCode"] 		:= aEvent[nEvt]
				oEvents["eventDescription"]	:= EncodeUTF8( fDescEvt( aEvent[nEvt] ) )
				
				// Verifica se encontrou status na RJE para o evento avaliado
				If !Empty( aDados )
					For nY := 1 TO LEN( aDados[1][2] )
						
						// Verifica Exclus�o
						If Empty(aDados[1][4][nY])
							If aDados[1][2][nY] == "1"
								cStatus := STR0006 // STR0006: "Pendentes de envio"
							ElseIf aDados[1][2][nY] == "2"
								cStatus := STR0007 // STR0007: "Aguardando governo"
							ElseIf aDados[1][2][nY] == "3"
								cStatus := STR0008 // STR0008: "Rejeitado"
							ElseIf aDados[1][2][nY] == "4"
								cStatus := STR0009  // STR0009: "Sucesso"
							EndIf
						Else
							cStatus := STR0046  // STR0046: "Excluido"
						EndIf

						oStatus 			:= JsonObject():new()
						oStatus["title"] 	:= EncodeUTF8( cStatus ) // Descri��o do Status
						
						// Verifica Exclus�o
						If Empty(aDados[1][4][nY])
							oStatus["type"] := aDados[1][2][nY] 	 // N�mero do Status
						Else
							oStatus["type"] := "-1" // Status Excluido
						EndIf
						
						oStatus["value"] 	:= aDados[1][3][nY] 	 // Quantidade com Status analisado
						oStatus["warning"] 	:= IIf( aDados[1][2][nY] $ "1|3", .T., .F. )
						nTotal				+= aDados[1][3][nY]
						
						AADD( aStatus, oStatus )
						FreeObj( oStatus )
					Next nY
				
					// Adiciona os status vazios
					For nZ := 1 To 4
						If ASCAN( aDados[1][2], ALLTRIM( STR( nZ ) ) ) == 0
							oStatus := JsonObject():new()
							
							If nZ == 1
								oStatus["title"] 	:= EncodeUTF8( STR0006 ) // STR0006: "Pendentes de envio"
							ElseIf nZ == 2
								oStatus["title"] 	:= EncodeUTF8( STR0007 ) // STR0007: "Aguardando governo"
							ElseIf nZ == 3
								oStatus["title"] 	:= EncodeUTF8( STR0008 ) // STR0008: "Rejeitado"
							ElseIf nZ == 4
							 	oStatus["title"] 	:= EncodeUTF8( STR0009 ) // STR0009: "Sucesso"
							EndIf
							
							oStatus["type"] 	:= nZ 	 // N�mero do Status
							oStatus["value"] 	:= 0 	 // Quantidade com Status analisado
							oStatus["warning"] 	:= .F.
							
							AADD( aStatus, oStatus )
							FreeObj( oStatus )
						EndIf
					Next nZ
				
				// Evento(s) n�o encontrado(s)
				Else
					For nZ := 1 To 4
						oStatus := JsonObject():new()

						If nZ == 1
							oStatus["title"] 	:= EncodeUTF8( STR0006 ) // STR0006: "Pendentes de envio"
						ElseIf nZ == 2
							oStatus["title"] 	:= EncodeUTF8( STR0007 ) // STR0007: "Aguardando governo"
						ElseIf nZ == 3
							oStatus["title"] 	:= EncodeUTF8( STR0008 ) // STR0008: "Rejeitado"
						ElseIf nZ == 4
						 	oStatus["title"] 	:= EncodeUTF8( STR0009 ) // STR0009: "Sucesso"
						EndIf
						
						oStatus["type"] 	:= nZ 	 // N�mero do Status
						oStatus["value"] 	:= 0 	 // Quantidade com Status analisado
						oStatus["warning"] 	:= .F.
						
						AADD( aStatus, oStatus )
						FreeObj( oStatus )
					Next nZ
				EndIf
				
				oEvents["status"] := aStatus
				oEvents["total"]  := nTotal
				AADD(aItems, oEvents)
				
			Next nEvt
			
			oItems := JsonObject():new()
			
			If !Empty( aItems )
				oItems["items"] := aItems
			EndIf
			
			cRet	:= fCompress( @oItems )
		EndIf
		
		::SetResponse( cRet )
		
	RECOVER
		lRet := .F.
		ErrorBlock( bErrorBlock )
		SetRestFault(ERRORSRV_DEF, EncodeUTF8( STR0010 ) + TAB + oError:Description, , , , , )  // STR0010: "Ocorreu uma falha no retorno da informa��o."
	END SEQUENCE

Return lRet


/*/{Protheus.doc} function fSetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   07/11/2019
@version 12.1.25
/*/
Static Function fSetErrorHandler(cTitle)
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)


/*/{Protheus.doc} function fResetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   07/11/2019
@version 12.1.25
/*/
Static Function fResetErrorHandler(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)


/*/{Protheus.doc} function fPreValid
Realiza a Pr� valida��o dos Inputs
@author  Hugo de Oliveira
@since   07/11/2019
@version 12.1.25
/*/
Static Function fPreValid( oInput )
	Local lRet 	   	:= .T.
	Local cMessage	:= ""

	If Empty( oInput["branches"] )
		cMessage := STR0011 // STR0011: "O par�metro 'branches' � obrigat�rio e n�o foi informado."
		lRet 	 := .F.

	ElseIf Empty( oInput["events"] )
		cMessage := STR0013  // STR0013: "O par�metro 'events' � obrigat�rio e n�o foi informado."
		lRet 	 := .F.
	EndIf

	If !lRet
		SetRestFault(ERRORCODE_DEF, EncodeUTF8( cMessage ), , , , , )
	EndIf
Return lRet


/*/{Protheus.doc} function fGetFil
Realiza a busca de filiais de acordo com a tabela origem do evento
@author  hugo.de.oliveira
@since   11/11/2019
@version 1.0
/*/
Static Function fGetFil( cEvent, aBranch )
	Local aRet		:= {}
	Local cRet  	:= ""
	Local nX 		:= 1
	Local nY		:= 1
	Local lParcial 	:= .F.

	For nX := 1 TO LEN( aBranch )
		If cEvent == "S-1005"
			AADD( aRet, aBranch[nX] )
			
			If fVldObraRJ(@lParcial, .F.) .And. !lParcial
				AADD( aRet, xFilial( "RJ4", aBranch[nX] ) )
			Else
				AADD( aRet, xFilial( "CTT", aBranch[nX] ) )
			EndIf
			
		ElseIf cEvent == "S-1010"
			AADD( aRet, xFilial( "SRV", aBranch[nX] ) )
			
		ElseIf cEvent == "S-1020"
			If fVldObraRJ(@lParcial, .F.) .And. !lParcial
				AADD( aRet, xFilial( "RJ3", aBranch[nX] ) )
			Else
				AADD( aRet, xFilial( "CTT", aBranch[nX] ) )
			EndIf

		ElseIf cEvent == "S-1030"
			If SuperGetMv("MV_CARGSQ3",,.F.)
				AADD( aRet, xFilial( "SQ3", aBranch[nX] ) )
			Else
				AADD( aRet, xFilial( "SRJ", aBranch[nX] ) )
			EndIf
			
		ElseIf cEvent == "S-1035"
			AADD( aRet, xFilial( "SGY", aBranch[nX] ) )
		
		ElseIf cEvent == "S-1040"
			AADD( aRet, xFilial( "SRJ", aBranch[nX] ) )
			
		ElseIf cEvent == "S-1050"
			AADD( aRet, xFilial( "SR6", aBranch[nX] ) )
		
		// Eventos 'S2210', 'S2220', 'S-1060' e 'S-1070' n�o ser�o considerados pois ainda est�o sendo desenvolvidos por terceiros.
		ElseIf cEvent $ ("S-1000|S-1060|S-1200|S-1210|S-1280|S-1295|S-1298|S-1299|S-1300|S-2190|S-2200|S-2205|S-2206|S-2210|S-2220|S-2230|S-2240|S-2250|S-2260|S-2298|S-2299|S-2300|S-2306|S-2399|S-3000")
			AADD( aRet, aBranch[nX] )
			
		EndIf
	Next nX
	
	// Preenchimento das filiais no retorno
	cRet := ""
	For nY := 1 To LEN( aRet )
		cRet += " '" + aRet[nY] + "' "

		If nY != LEN( aRet )
			cRet += ","
		EndIf
	Next nY

Return cRet


/*/{Protheus.doc} function fGetData
Retorna todos os dados para processamento
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fGetData( cEvent, cPeriod, aBranches, cPerFrom, cPerTo )
	Local aEvents	:= {}
	Local aTemp		:= {}
	Local aStatus	:= {}
	Local aQtde		:= {}
	Local aExc		:= {}
	Local cQuery	:= ""
	Local cBranQry  := ""
	Local cAliasRJE	:= GetNextAlias()
	Local lCpoFil	:= RJE->(ColumnPos("RJE_DTEVE")) > 0

	Default cEvent 		:= ""
	Default cPeriod 	:= ""
	Default aBranches 	:= {}
	Default cPerFrom	:= ""
	Default cPerTo		:= ""

	// Verifica conex�es abertas
	If Select ("RJE") > 0
		RJE->( dbCloseArea() )
	EndIf

	cBranQry := fGetFil( cEvent, aBranches ) // Retorno da Filial origem da RJE

	If !Empty( cBranQry )
		// Montagem da consulta
		cQuery := "SELECT RJE_STATUS STATUS, COUNT( RJE_FILIAL ) QTDE, RJE_EXC EXCLUIDOS  "
		cQuery += "FROM "+ RetSqlName("RJE")
		cQuery += " WHERE RJE_EVENTO = '" + REPLACE(cEvent, "-", "") + "' "
		
		If !Empty( cPeriod ) .AND. !cEvent $ ("S-1299,S-2190,S-2200,S-2205,S-2206,S-2230,S-2250,S-2260,S-2298,S-2299,S-2300,S-2306,S-2399,S-3000")
			cQuery += "AND RJE_INI = '" + REPLACE( cPeriod, "/", "" ) + "' "
		EndIf

		If lCpoFil .And. (cEvent == "S-2230" .Or. cEvent == "S-2200") .And. !Empty(cPerFrom) .And. !Empty(cPerTo)
			cQuery += "AND RJE_DTEVE BETWEEN '" + cPerFrom + "' AND '" + cPerTo + "' "
		EndIf

		cQuery += "AND RJE_FIL IN ( " + cBranQry + ") "
		cQuery += "AND " + RetSqlName("RJE") + ".D_E_L_E_T_ <> '*' "
		cQuery += "GROUP BY RJE_STATUS, RJE_EXC"

		// Execute Query
		cQuery := ChangeQuery( cQuery )
		DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cAliasRJE, .T., .T. )
		
		aTemp 	:= {}
		aStatus := {}
		aQtde	:= {}
		AADD( aTemp, cEvent )
		
		// Pega todas as ocorr�ncias encontradas na consulta
		While ( cAliasRJE )->( !Eof() ) 
			AADD( aStatus, ( cAliasRJE )->STATUS )
			AADD( aQtde,   ( cAliasRJE )->QTDE )
			AADD( aExc,   ( cAliasRJE )->EXCLUIDOS )
			( cAliasRJE )->(DBSkip() )
		EndDo
		
		If !Empty( aStatus )
			AADD( aTemp, aStatus )
			AADD( aTemp, aQtde )
			AADD( aTemp, aExc )
			AADD( aEvents, aTemp )
		EndIf
		
		( cAliasRJE )->( DbCloseArea() )
	EndIf

Return aEvents


/*/{Protheus.doc} function fCompress
Compress String Object
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.
	
	// Set gzip format to Json Object
	cJson := oObj:toJSON()

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


/*/{Protheus.doc} function fDescEvt
Retorna a descri��o do evento informado
@author  Hugo de Oliveira
@since   14/09/2019
@version 1.0
/*/
Static Function fDescEvt( cEvtCd )
	Local cDesc := ""
	
	If cEvtCd == "S-1000"
		cDesc := STR0014 // "Informa��es do Empregador/Contribuinte/�rg�o P�blico"
	ElseIf cEvtCd == "S-1005" 
		cDesc := STR0015 // "Tabela de Estabelecimentos, Obras ou Unidades de �rg�os P�blicos"
	ElseIf cEvtCd == "S-1010"
		cDesc := STR0016 // "Tabela de Rubricas"
	ElseIf cEvtCd == "S-1020"
		cDesc := STR0017 // "Tabela de Lota��es Tribut�rias"
	ElseIf cEvtCd == "S-1030"
		cDesc := STR0018 // "Tabela de Cargos/Empregos P�blicos"
	ElseIf cEvtCd == "S-1035"
		cDesc := STR0019 // "Tabela de Carreiras P�blicas"
	ElseIf cEvtCd == "S-1040"
		cDesc := STR0020 // "Tabela de Fun��es/Cargos em Comiss�o"
	ElseIf cEvtCd == "S-1050"
		cDesc := STR0021 // "Tabela de Hor�rios/Turnos de Trabalho"
	ElseIf cEvtCd == "S-1060"
		cDesc := STR0022 // "Tabela de Ambientes de Trabalho"
	ElseIf cEvtCd == "S-1070"
		cDesc := STR0023 // "Tabela de Processos Administrativos/Judiciais"
	ElseIf cEvtCd == "S-1200"
		cDesc := STR0024 // "Remunera��o de trabalhador vinculado ao Regime Geral de Previd. Social"
	ElseIf cEvtCd == "S-1210"
		cDesc := STR0025 // "Pagamentos de Rendimentos do Trabalho"
	ElseIf cEvtCd == "S-1280"
		cDesc := STR0026 // "Informa��es Complementares aos Eventos Peri�dicos"
	ElseIf cEvtCd == "S-1295"
		cDesc := STR0027 // "Solicita��o de Totaliza��o para Pagamento em Conting�ncia"
	ElseIf cEvtCd == "S-1298"
		cDesc := STR0028 // "Reabertura dos Eventos Peri�dicos"
	ElseIf cEvtCd == "S-1299"
		cDesc := STR0029 // "Fechamento dos Eventos Peri�dicos"
	ElseIf cEvtCd == "S-1300"
		cDesc := STR0030 // "Contribui��o Sindical Patronal"
	ElseIf cEvtCd == "S-2190"
		cDesc := STR0031 // "Admiss�o de Trabalhador - Registro Preliminar"
	ElseIf cEvtCd == "S-2200"
		cDesc := STR0032 // "Cadastramento Inicial do V�nculo e Admiss�o/Ingresso de Trabalhador"
	ElseIf cEvtCd == "S-2205"
		cDesc := STR0033 // "Altera��o de Dados Cadastrais do Trabalhador"
	ElseIf cEvtCd == "S-2206"
		cDesc := STR0034 // "Altera��o de Contrato de Trabalho"
	ElseIf cEvtCd == "S-2210"
		cDesc := STR0035 // "Comunica��o de Acidente de Trabalho"
	ElseIf cEvtCd == "S-2220"
		cDesc := STR0036 // "Monitoramento da Sa�de do Trabalhador"
	ElseIf cEvtCd == "S-2230"
		cDesc := STR0037 // "Afastamento Tempor�rio"
	ElseIf cEvtCd == "S-2240"
		cDesc := STR0047 // "Condi��es Ambientais do Trabalho - Fatores de Risco"
	ElseIf cEvtCd == "S-2250"
		cDesc := STR0038 // "Aviso Pr�vio"
	ElseIf cEvtCd == "S-2260"
		cDesc := STR0039 // "Convoca��o para Trabalho Intermitente"
	ElseIf cEvtCd == "S-2298"
		cDesc := STR0045 // "Reintegra��o"
	ElseIf cEvtCd == "S-2299"
		cDesc := STR0040 // "Desligamento"
	ElseIf cEvtCd == "S-2300"
		cDesc := STR0041 // "Trabalhador Sem V�nculo de Emprego/Estatut�rio - In�cio"
	ElseIf cEvtCd == "S-2306"
		cDesc := STR0042 // "Trabalhador Sem V�nculo de Emprego/Estatut�rio - Altera��o Contratual"
	ElseIf cEvtCd == "S-2399"
		cDesc := STR0043 // "Trabalhador Sem V�nculo de Emprego/Estatut�rio - T�rmino"
	ElseIf cEvtCd == "S-3000"
		cDesc := STR0044 // "Exclus�o de eventos"
	EndIf
Return cDesc

