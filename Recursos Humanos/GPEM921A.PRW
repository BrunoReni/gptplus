#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "GPEM921A.CH"


/*/{Protheus.doc} function fSendComp
Realiza a consulta dos dados de acordo com a compet�ncia e os envia atrav�s da API.
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Function GPEM921A( aParam )
	Local aData		:= {}
	Local aMV		:= {}
	Local nF		:= 1
	Local nPos		:= 0
	Local lMatriz	:= .T.
	Local lJob		:= .F.
	Local aSM0		:= {}
	Local lTSS		:= .T.

	Private cErro := ""

	DEFAULT aParam 	:= {}
	conout( STR0001 ) // STR0001: "In�cio do Processamento do JOB!"

	If Len(aParam) > 5 .And. !Empty( aParam )
		If Len(aParam) == 6//pelo schedule
			aAdd(aParam, {aParam[4]})
			lJob := .T.
		EndIf
		For nF := 1 to Len(aParam[7])
			aMV := {}
			RpcSetType(3) // Licen�a
			RPCsetEnv(aParam[3], aParam[7,nF]) // Abertura do Ambiente

			// Verifica se a rotina est� sendo executada e realiza o Lock
			If LockByName( "GPEM921A" + cEmpAnt + aParam[7,nF], .T., .T., .T. )
				// Sele��o dos Par�metros
				Aadd( aMV , ALLTRIM( SuperGetMv( "MV_GPEAMBE",, "" ) ) ) // Tipo de Ambiente a ser utilizado
				Aadd( aMV , ALLTRIM( SuperGetMv( "MV_GPEMURL",, "" ) ) ) // Ambiente TSS Configurado
				Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI01",, "" ) ) ) // URL do ambiente com servi�o Rest Configurado
				Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI03",, "" ) ) ) // Tipo de Inscri��o
				Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI04",, "" ) ) ) // Inscri��o
				Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI09",, "" ) ) ) // Servi�o, m�todo e a vers�o da API de Envio e Consulta do Middleware

				//-- Valida se o tss est� no ar
				If FindFunction("TSSOnAir") .And. !(TSSOnAir(aMV[2]))
					lTSS := .F.
				EndIf

				//Verifica se a filial em processamento � a matriz
				If lJob .And. Findfunction("fVldRJ9")
					If Empty(aSM0)
						aSM0 := FWLoadSM0()
					EndIf
					If len(aSM0) > 0
						nPos := aScan(aSM0,{|X| X[1] + X[2] == aParam[3] + aParam[4]})
						If nPos > 0
							lMatriz := fVldRJ9(aSM0[nPos, 18])
						EndIf
					EndIf
				EndIf

				//Caso seja a filial matriz e o TSS esteja ativo
				If lTSS .And. lMatriz
					If aMV[5] == "53113791000122" .And. aMV[1] <> "2"
						cErro += STR0008 + aParam[7,nF] + STR0009 + CRLF
						//"Identificada inconsist�ncia na configura��o do ambiente de homologa��o para filial xx. Verifique o conte�do do par�metro MV_GPEAMBE e configure o ambiente eSocial como pr�-produ��o."
						Conout(cErro)
					else
						aData := fGetData( aParam, aMV ) // Selec�o dos dados com base nos filtros e suas regras

						If !Empty(aData)
							aData := fSortEvt( aData) 	// Ordena��o dos eventos
							fSendData( aData, aMV )		// Chamada da API de envio dos dados
							If !Empty(cErro)
								Conout(cErro) //Imprime erro no console.
							EndIf
						EndIf
					EndIf
				ElseIf !lTSS
					cErro += OemToAnsi(STR0012) + aMV[2] 
					Conout(cErro)
				Else
					cErro += STR0010 + aParam[7,nF] +  STR0011
					Conout(cErro)
				EndIf

				// Libera a rotina ap�s finalizar a execu��o das Threads
				UnLockByName("GPEM921A" + cEmpAnt + aParam[7,nF], .T., .T., .T.)
			Else
				conout(STR0002) // STR0002: "A rotina 'GPEM921A' est� sendo executada por outro processo"
			EndIf
			RpcClearEnv()
		Next nF
	Else
		conout( STR0003 ) // STR0003: "Erro no recebimento dos par�metros utilizados na execu��o do JOB"
	EndIf

	conout( STR0004 ) // STR0004: "Fim do Processamento do JOB!"
Return cErro


/*/{Protheus.doc} function fGetData
Retorna todos os dados para processamento
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fGetData( aParam, aMV )
	Local dDtCorte
	Local nX		:= 1
	Local aData 	:= {}
	Local cAlias	:= "RJE"
	Local cStatus 	:= ""
	Local cDtEnv 	:= ""
	Local cDtIni	:= ""
	Local cEvt 		:= ""
	Local cRetKey 	:= ""
	Local cXML 		:= ""
	Local lSched	:= Len(aParam) < 8

	If lSched .Or. Empty(aParam[8])
		// Dias de Corte
		If !Empty( aParam[2] ) .And. aParam[2] != "0"
			dDtCorte :=	DATE() - VAL( ALLTRIM( aParam[2] ) )
			dDtCorte := cValToChar( YEAR( dDtCorte ) ) + SUBSTR( cValToChar( dDtCorte ), 4, 2 ) + SUBSTR( cValToChar( dDtCorte ), 0, 2 )
		EndIf

		// Consulta a tabela de Eventos
		DbSelectArea( cAlias )
		( cAlias )->( DbSetOrder( 2 ) ) // RJE_TPINSC, RJE_INSCR
		DbSeek( aMV[4] + SUBSTR( aMV[5], 0, 8 ) )

		While ( cAlias )->( !EOF() ) .AND. aMV[4] + SUBSTR( aMV[5], 0, 8 ) == ALLTRIM( ( cAlias )->RJE_TPINSC ) + ALLTRIM( ( cAlias )->RJE_INSCR )
			cStatus := ALLTRIM( ( cAlias )->RJE_STATUS )
			cDtEnv	:= ALLTRIM( ( cAlias )->RJE_DTENV )
			cDtIni	:= ALLTRIM( ( cAlias )->RJE_INI )
			cEvt	:= ALLTRIM( ( cAlias )->RJE_EVENTO )
			cRetKey	:= ALLTRIM( ( cAlias )->RJE_RETKEY )
			cXML	:= ALLTRIM( ( cAlias )->RJE_XML )

			// Tratamento do tipo de ambiente
			nIni := AT("<tpAmb>", cXML ) // Procura no XML a TAG <tpAmb>
			cExp := SUBSTR( cXML, nIni, 16 )
			cXML := STRTRAN( cXML, cExp, "<tpAmb>" + aMV[1] + "</tpAmb>" )

			// Consulta Evento e Status
			If !(cStatus $ "2/4") .And. ( lSched .Or. cEvt == REPLACE(aParam[5], "-", "") )//pelo schedule vem usuario
				If Empty( aParam[1] ) // Se a Compet�ncia n�o for informada
					If ( Empty( cDtEnv ) .OR. cDtEnv >= dDtCorte )
						Aadd( aData, { cEvt, cRetKey, cXML } )
					EndIf
				Else
					If Empty( cDtEnv ) // Se o evento nunca foi enviado, ent�o considera a data que o registro foi gerado
						If cDtIni == ALLTRIM( aParam[1] ) .And. cDtIni >= dDtCorte
							Aadd( aData, { cEvt, cRetKey, cXML } )
						EndIf
					Else
						If cDtEnv == ALLTRIM( aParam[1] ) .And. cDtEnv >= dDtCorte
							Aadd( aData, { cEvt, cRetKey, cXML } )
						EndIf
					EndIf
				EndIf
			EndIf

			( cAlias )->( dbSkip() )
		EndDo
	// Envio apenas dos registros marcados na tela de detalhamento
	Else
		For nX := 1 To LEN(aParam[8])
			DbSelectArea(cAlias)
			(cAlias)->(DbSetOrder(3)) // RJE_EVENTO, RJE_RETKEY
			DbSeek(REPLACE(aParam[5], "-", "") + ALLTRIM(aParam[8][nX]))

			If (cAlias)->(!EOF()) .AND. REPLACE(aParam[5], "-", "") + aParam[8][nX] == ALLTRIM((cAlias)->RJE_EVENTO) + ALLTRIM((cAlias)->RJE_RETKEY);
				.AND. aMV[4] + SUBSTR( aMV[5], 0, 8 ) == ALLTRIM( ( cAlias )->RJE_TPINSC ) + ALLTRIM( ( cAlias )->RJE_INSCR )
				If ALLTRIM((cAlias)->RJE_STATUS) $ "1/3"
					cXML := ALLTRIM( ( cAlias )->RJE_XML )

					// Tratamento do tipo de ambiente
					nIni := AT("<tpAmb>", cXML ) // Procura no XML a TAG <tpAmb>
					cExp := SUBSTR( cXML, nIni, 16 )
					cXML := STRTRAN( cXML, cExp, "<tpAmb>" + aMV[1] + "</tpAmb>" )

					Aadd( aData, { REPLACE(aParam[5], "-", ""), ALLTRIM(aParam[8][nX]), cXML } )
				EndIf
			EndIf
		Next nX
	EndIf
Return aData


/*/{Protheus.doc} function fSendData
Atrav�s da API(WSESOCIAL) do TSS, realiza o envio de dados do trabalhador.
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fSendData( aData, aMV )
	Local oMID
	Local oRet
	Local oItem
	Local oBody
	Local nX 		:= 1
	Local nY 		:= 1
	Local aHeader   := {}
	Local aLote 	:= {}
	Local lRet	 	:= .F.
	Local lHeader	:= .T.
	Local cRetCode 	:= ""
	Local cBody		:= ""
	Local cRet 		:= ""
	Local cEvtRJE 	:= ""
	Local cRetKey 	:= ""
	Local cTCK 		:= ""
	Local cXML 		:= ""
	Local cSrcBra 	:= ""
	Local cAliasRJ9 := "RJ9"
	Local cAlias	:= "RJE"
	Local dDtEnv 	:= DATE()
	Local cHEnv 	:= TIME()
	Local nQtdeReg 	:= Len( aData )
	Local cEvtExc	:= ""
	Local cToken	:= ""
	Local cVersTss	:= ""
	Local cClient	:= ""
	Local cSecret	:= ""
	Local nFimTxt	:= 0

	If nQtdeReg < 1
		Return
	EndIf

	// Divide os dados em lotes de 50 itens
	aData 	 := fGetLote( aData )
	nQtdeReg := Len( aData )

	// Pega a entidade do cadastro do trabalhador
	DbSelectArea( cAliasRJ9 )
	( cAliasRJ9 )->( DbSetOrder( 5 ) ) // RJ9_NRINSC, RJ9_INI
	( cAliasRJ9 )->( DbGoTop() )

	If ( cAliasRJ9 )->( DbSeek( aMV[5] ) ) .Or. ( cAliasRJ9 )->( DbSeek( SubStr( aMV[5], 1, 8 ) ) )
		If ( cAliasRJ9 )->( ColumnPos( "RJ9_IDENT" ) ) > 0
			cSrcBra := ( cAliasRJ9 )->RJ9_IDENT
			If ( cAliasRJ9 )->( ColumnPos( "RJ9_CLIENT" ) ) > 0
				cClient := ( cAliasRJ9 )->RJ9_CLIENT
				cSecret := ( cAliasRJ9 )->RJ9_SECRET
			EndIf
		EndIf
	EndIf

	//Verifica vers�o do TSS
	If FindFunction("GpeVerTSS")
		cVersTss	:= GpeVerTSS(cSrcBra)
		nFimTxt		:= AT( "|", cVersTss )
		cVersTss	:= alltrim(Substr(cVersTss, 1, nFimTxt -1))
	EndIf

	//Procura o token v�lido se TSS 33 ou superior e existem credenciais informadas
	If  FindFunction("fGPETokenMid") .And. cVersTss >= "12.1.033" .And. !Empty(cClient) .And. !Empty(cSecret)
		cToken := fGPETokenMid(cClient,cSecret,,,,,@cErro)
		//Caso haja algum erro no gera��o do TOKEN aborta o envio do evento
		If !Empty(cErro)
			lRet := .F.
			Return
		EndIf
	EndIf

	// Montagem do Header
	If Empty(cToken)
		aadd(aHeader, "Content-Type: application/json; charset=UTF-8")
	Else
		aadd(aHeader, "TokenAuthTSS: " + cToken)
	EndIf

	// Processamento dos registros
	For nY := 1 To nQtdeReg
		For nX := 1 to LEN( aData[nY] )
			cEvtRJE	:= aData[nY][nX][1]
			cRetKey	:= aData[nY][nX][2]
			cXML 	:= aData[nY][nX][3]
			cEvtExc	:= ""

			//Para o evento S3000 pesquisa no XML qual o evento ser� exclu�do
			If cEvtRJE = "S3000"
				cEvtExc	:= SUBSTR( cXML, AT("tpEvento", cXML) + 9, 6 )
			EndIf

			// Montagem do Tickect
			If Empty( cTCK )
				cTCK := Substr( FWUUId( cRetKey ), 1, 36 ) // Formato Retornado: "b9ce64c5-094b-4c95-9b29-c22b5cbf94f3"
			EndIf

			// Montagem dos dados do array de propriedades 'Lote'
			oItem 						:= JsonObject():new()
			oItem["registryType"]		:= SUBSTR( cEvtRJE, 1, 1) + "-" + SUBSTR( cEvtRJE, 2)
			oItem["registryKey"]		:= ALLTRIM(cRetKey)
			oItem["integrationMessage"]	:= Encode64( cXML )
			oItem["schemaVersion"]		:= fGetVers( cEvtRJE, cXML) // Retorna a vers�o de Layout do evento enviado

			// Adiciona os items no array de lotes
			AAdd( aLote, oItem )
			FreeObj( oItem )
		Next nX

		// Montagem dos demais campos do Body
		oBody := JsonObject():new()
		oBody['ticketCode']		:= cTCK 	// Atributo raiz usado para ajudar na identifica��o do Bloco de dados
		oBody['sourceBranch']	:= cSrcBra	// C�digo Identificador da entidade TSS ( retornado na configura��o do certificado)
		oBody['tpAmb'] 			:= aMV[1]	// Par�metro contendo o Tipo do Ambiente
		oBody['urlTSS']			:= aMV[2]	// Par�metro contendo a URL do Ambiente

		// Adiciona o Array de Lotes no Body
		oBody["lote"] := aLote

		// Converve o objeto para texto e o compacta
		cBody := fCompress( @oBody )

		// Chamada da API
		oMID := FwRest():New( aMV[3] )
		oMID:setPath( "/" + aMV[6] + "/send/" )
		oMID:SetPostParams( cBody )

		lHeader := oMID:Post( aHeader )

		// Verifica��o de Retorno
		oRet := JsonObject():new()
		lRet := FWJsonDeserialize( oMID:GetResult(), @oRet )

		If lRet .And. lHeader .And. !Empty( oRet )
			cRet	 := oMID:GetResult()
			cRetCode := oMID:GetHTTPCode()

			For nX := 1 To Len(aData[nY])
				DbSelectArea( cAlias )
				( cAlias )->( DbSetOrder( 3 ) ) // RJE_EVENTO, RJE_RETKEY
				( cAlias )->( DbGoTop() )

				If ( cAlias )->( DbSeek( aData[nY][nX][1] + aData[nY][nX][2] ) )
					Begin Transaction
						Reclock( cAlias, .F.)

						If !Empty(oRet:REGISTRYKEY[nX]) .And. !oRet:REGISTRYKEY[nX]:SUCCESS // Trata erros de configura��o ou Schema
							( cAlias )->RJE_STATUS	:= "3" // Erro
							( cAlias )->RJE_RTN 	:= oRet:REGISTRYKEY[nX]:ERROR[1]:DESCRIPTION

						Else //cRetCode $ ("|200|201")
							( cAlias )->RJE_STATUS	:= "2" // Pendente de Processamento
							( cAlias )->RJE_TCK 	:= oRet:TICKETCODE
						EndIf

						( cAlias )->RJE_DTENV 	:= dDtEnv
						( cAlias )->RJE_HENV  	:= cHEnv

						MsUnlock()
					End Transaction
				EndIf
			Next nX
		Else
			If !lHeader .And. lRet .And. !Empty( oRet )
				cErro := DecodeUtf8(oRET:MESSAGE)
			ElseIf !lHeader .And. !Empty( oMid )
				cErro := DecodeUtf8(oMID:CINTERNALERROR) + CRLF + CRLF
				cErro += OemToAnsi(STR0013) + CRLF 
				cErro += OemToAnsi(STR0014) + aMV[3]
			EndIf
			lRet := .F.
		EndIf

		// Limpeza dos Objetos utilizados
		aLote := {}
		FreeObj( oBody )
		FreeObj( oItem )
		FreeObj( oRet )
		FreeObj( oMID )
	Next nY
Return


/*/{Protheus.doc} function fGetVers
Retorna a vers�o de Layout do evento enviado.
Formato de retorno: "02_05_00"
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
Static Function fGetVers( cEvento, cXML )

	Local cVersXML		:= ""
	Local nIni			:= 0
	Local nFim			:= 0

	Default cXML	:= ""

	If !Empty(cXML)
		nIni		:= AT("evt/", cXML) + 4
		nFim		:= AT(">", cXML) - 1
		cVersXML	:= SUBSTR( cXML, nIni, nFim-nIni )

		nIni		:= AT("/", cVersXML ) + 1
		cVersXML	:= SUBSTR( cVersXML, nIni)

		If "v_" $ cVersXML
			cVersXML	:= REPLACE( cVersXML, "v_", "")
		ElseIf "v" $ cVersXML
			cVersXML	:= REPLACE( cVersXML, "v", "")
		EndIf
	EndIf

Return cVersXML

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


/*/{Protheus.doc} function fSortEvt
Realiza a ordena��o dos eventos
@author  Hugo de Oliveira
@since   30/10/2019
@version 1.0
/*/
Static Function fSortEvt( aData)
	Local nX 		:= 1
	Local cEvtRJE 	:= ""
	Local nInd		:= 0

	// Cria uma nova posi��o no Array de dados para servir de "�ndice" e assim poder ser ordenado
	For nX := 1 To Len( aData )
		cEvtRJE		:= aData[nX][1]

		// Eventos de Cadastro
		If cEvtRJE == "S1000" // Empregador
			nInd := 1
		ElseIf cEvtRJE == "S1070" // Processos
			nInd := 2
		ElseIf cEvtRJE == "S1005" // Estabelecimentos
			nInd := 3
		ElseIf cEvtRJE == "S1010" // Verbas
			nInd := 4
		ElseIf cEvtRJE == "S1020" // Lota��es
			nInd := 5
		ElseIf cEvtRJE == "S1030" // Cargos
			nInd := 6
		ElseIf cEvtRJE == "S1040" // Fun��es
			nInd := 7
		ElseIf cEvtRJE == "S1050" // Hor�rios
			nInd := 8

		// Eventos N�o Peri�dicos
		ElseIf cEvtRJE == "S2190" // Adm Preliminar
			nInd := 9
		ElseIf cEvtRJE == "S2200" // Admiss�o
			nInd := 10
		ElseIf cEvtRJE == "S2300" // In�cio TSV
			nInd := 11
		ElseIf cEvtRJE == "S2205" // Altera��o Cadastral
			nInd := 12
		ElseIf cEvtRJE == "S2206" // Altera��o Contratual
			nInd := 13
		ElseIf cEvtRJE == "S2306" // Altera��o Contratual TSV
			nInd := 14
		ElseIf cEvtRJE == "S2210" // CAT
			nInd := 15
		ElseIf cEvtRJE == "S2220" // Monitoramento Sa�de Trabalhador
			nInd := 16
		ElseIf cEvtRJE == "S2221" // Exame Toxicol�gico
			nInd := 17
		ElseIf cEvtRJE == "S2230" // Afastamentos
			nInd := 18
		ElseIf cEvtRJE == "S2240" // Condi��es de trabalho
			nInd := 19
		ElseIf cEvtRJE == "S2245" // Treinamentos
			nInd := 20
		ElseIf cEvtRJE == "S2250" // Aviso Pr�vio
			nInd := 21
		ElseIf cEvtRJE == "S2298" // Reintegra��o
			nInd := 22
		ElseIf cEvtRJE == "S2299" // Rescis�o
			nInd := 23
		ElseIf cEvtRJE == "S2299" // Rescis�o
			nInd := 24
		ElseIf cEvtRJE == "S2399" // T�rmino TSV
			nInd := 25
		ElseIf cEvtRJE == "S3000" // Exclus�o
			nInd := 26

		// Peri�dicos
		ElseIf cEvtRJE == "S1200" // Folha
			nInd := 27
		ElseIf cEvtRJE == "S1210" // Pagamentos
			nInd := 28
		ElseIf cEvtRJE == "S1280" // Desonera��o
			nInd := 29
		ElseIf cEvtRJE == "S1300" // Contribui��es Sindicais
			nInd := 30
		EndIf

		AADD( aData[nX], nInd )
	Next nX

	// Ordena os dados
	ASORT(aData, , , { | x,y | x[4] < y[4] } )

Return aData


/*/{Protheus.doc} function fGetLote
Divide os dados em Lote
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
Static Function fGetLote( aArray )
	Local aLote
	Local aClone	:= {}
	Local nSizeDef	:= 50
	Local nX		:= 1
	Local nPos		:= 1
	Local nEndPos	:= nSizeDef
	Local nSize 	:= Len(aArray)
	Local nSzClone	:= ( nSize / nSizeDef )

	// Caso os lotes n�o possuam tamanho completo de 50 itens
	If (nSize % nSizeDef) > 0
		nSzClone := INT(nSzClone) + 1
	EndIf

	aLote := ARRAY( nSzClone, {} )
	For nX := 1 To nSzClone
		aClone	:= {}
		For nPos := nPos  To nEndPos
			If  nPos <= nSize
				aadd( aClone, aArray[nPos] )
			EndIf
		Next nPos

		aLote[nX] := aClone
		nEndPos += nSizeDef
	Next nX

Return aLote
