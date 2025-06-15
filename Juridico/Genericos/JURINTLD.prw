#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "JURINTLD.CH"

Static _lLDSincOn := .F. // Indica se a sincroniza��o com o LD foi online

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIntLD
Realiza opera��es de forma online na integra��o Protheus x Legaldesk

@param  cVerbo   , Verbo da requisi��o (DELETE, POST, PUT)
@param  cModelo  , ID do modelo de dados
@param  cCodLD   , C�digo Legaldesk do registro
@param  nRecnoEnt, Recno do registro
@param  aHeader  , Header adicional (se necess�rio para algum modelo espec�fico)

@return lRet     , Indica se o registro no protheus pode ser exclu�do

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Function JurIntLD(cVerbo, cModelo, cCodLD, nRecnoEnt, aHeader)
Local lRet   := .F.

Default cVerbo    := ""
Default cModelo   := ""
Default cCodLD    := ""
Default nRecnoEnt := 0
Default aHeader   := {}

	_lLDSincOn := .F.

	If !JurIsRest()// Somente execu��o via Protheus e com os par�metros preenchidos
		Processa( {|| lRet := JRunIntLD(cVerbo, cModelo, cCodLD, nRecnoEnt, aHeader) }, STR0001, STR0002, .F. )  // "Aguarde" - "Sincronizando registro"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRunIntLD
Processamento da requisi��o no Legaldesk para opera��es (exclus�o) de registros

@param  cVerbo   , Verbo da requisi��o (DELETE, POST, PUT)
@param  cModelo  , ID do modelo de dados
@param  cCodLD   , C�digo Legaldesk do registro
@param  nRecnoEnt, Recno do registro
@param  aHeader  , Header adicional (se necess�rio para algum modelo espec�fico)

@return lRet     , Indica se o registro no protheus pode ser exclu�do

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JRunIntLD(cVerbo, cModelo, cCodLD, nRecnoEnt, aHeader)
Local lRet         := .T.
Local lResult2xx   := .F.
Local lResult5xx   := .F.
Local oRest        := Nil
Local oResult      := Nil
Local nValid       := 0
Local cErrorResult := ""
Local cProblema    := ""
Local cSolucao     := ""
Local cServico     := ""
Local cCodeResult  := ""
Local cHost        := SuperGetMV("MV_JLDURL", .F., "") // URL de integra��o com LD
Local cUser        := SuperGetMV("MV_JLDUSR", .F., "") // Usu�rio de integra��o com LD
Local cPwd         := SuperGetMV("MV_JLDPWD", .F., "") // Senha do usu�rio de integra��o com LD

	If !Empty(cHost) .And. !Empty(cUser) .And. !Empty(cPwd)

		oRest := FWRest():New(cHost)

		aAdd(aHeader, "Content-Type: application/json")
		aAdd(aHeader, "Authorization: Basic " + Encode64(cUser + ":" + cPwd))

		cServico := JIntLDServ(cModelo, cCodLD) // Servico do LD (Complemento da URL)

		oRest:SetPath(cServico)

		If cVerbo == "DELETE"

			ProcRegua(0)
			IncProc()
			
			oRest:Delete(aHeader, cHost + cServico)

			cCodeResult := oRest:GetHTTPCode()

			lResult2xx := Substr(cCodeResult, 1, 1) == "2"
			lResult5xx := Substr(cCodeResult, 1, 1) == "5"
			
			Do Case
				Case lResult2xx // Resultados v�lidos -- Resultados 2xx
					// Vai excluir o registro e N�O vai adicionar na NYS
					_lLDSincOn := .T. // Indica que houve sincroniza��o online
				
				Case cCodeResult == "404" .Or. lResult5xx // 404 ou Erros 5xx
					// 404 - Not Found - Se n�o encontrar o registro na exclus�o online
					// 5xx - Problemas na conex�o

					// Vai excluir o registro e vai adicionar na NYS
					_lLDSincOn := .F. // Indica que n�o houve sincroniza��o online

					// Inclui arquivo de Log
					JIntLDLog(cModelo, cVerbo, oRest:GetResult(), oRest:GetLastError(), cCodLD)

				Case cCodeResult == "401" // Unauthorized - Usu�rio ou senha incorretos
					cProblema := STR0003 // "N�o foi poss�vel excluir o registro devido a falha na autentica��o (usu�rio ou senha inv�lidos) durante a sincroniza��o dos dados com o LEGALDESK"
					cSolucao  := STR0004 // "Contate a equipe t�cnica para verificar o preenchimento dos par�metros MV_JLDUSR e MV_JLDPWD. Ap�s o ajuste, refa�a a opera��o."

				Case cCodeResult == "403" // Forbidden - Usu�rio sem direito de acesso
					cProblema := STR0005 // "N�o foi poss�vel excluir o registro devido a permiss�o de acesso durante a sincroniza��o dos dados com o LEGALDESK"
					cSolucao  := STR0006 // "Contate a equipe t�cnica para verificar no LEGALDESK a permiss�o do usu�rio (indicado no par�metro MV_JLDUSR). Ap�s o ajuste, refa�a a opera��o."

				Case Empty(cCodeResult) .And. Empty(oRest:GetResult()) // URL inv�lida
					If "HOST NOT FOUND" $ Upper(oRest:GetLastError())
						cProblema := STR0007 // "N�o foi poss�vel excluir o registro devido a falha na conex�o durante a sincroniza��o dos dados com o LEGALDESK"
						cSolucao  := STR0008 // "Contate a equipe t�cnica para verificar o preenchimento do par�metro MV_JLDURL. Ap�s o ajuste, refa�a a opera��o."
					Else
						cProblema := STR0009 // "N�o foi poss�vel excluir o registro devido a falha de comunica��o na sincroniza��o dos dados com o LEGALDESK"
						cSolucao  := STR0010 // "Contate a equipe t�cnica."
					EndIf

				Case cCodeResult == "400" .And. !Empty(oRest:GetResult()) // Alguma valida��o no LD impede a exclus�o

					oResult := JsonObject():New()
					oResult:FromJSON(oRest:GetResult())

					If oResult <> Nil .And. ValType(oResult) == "J" // JsonObject
						If oResult["result"] <> Nil .And. ;
						   oResult["result"]["detail"] <> Nil .And. ; 
						   oResult["result"]["detail"]["validations"] <> Nil .And. ValType(oResult["result"]["detail"]["validations"]) == "A"
							For nValid := 1 To Len(oResult["result"]["detail"]["validations"])
								cErrorResult += CRLF + DecodeUTF8(oResult["result"]["detail"]["validations"][nValid]["errorMessage"])
							Next
						EndIf
					EndIf

					cProblema := STR0011 + CRLF + CRLF + STR0012 + cErrorResult // "N�o foi poss�vel excluir o registro devido a regra n�o atendida durante a sincroniza��o dos dados com o LEGALDESK. " - "Regra: "
					cSolucao  := STR0013 // "Contate a equipe t�cnica para verificar as regras no LEGALDESK."

			End Case

			If !Empty(cProblema)
				cProblema += " - " + STR0014 + oRest:GetLastError() // "Erro: "
				lRet := JurMsgErro(cProblema,, cSolucao)
				// Inclui arquivo de Log
				JIntLDLog(cModelo, cVerbo, oRest:GetResult(), oRest:GetLastError(), cCodLD)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntLDServ
Indica o servi�o que ser� executado conforme o modelo

@param  cModelo  , ID do modelo de dados
@param  cCodLD   , C�digo Legaldesk do registro

@return cServico , Servi�o que ser� executado junto com o c�digo Legaldesk

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JIntLDServ(cModelo, cCodLD)
Local cServico   := ""
Local lNewSyncOn := FindFunction("J300ChkVer") .And. J300ChkVer("2023.1.0.0") // Nessa vers�o do LD funciona a nova vers�o do servi�o de sincroniza��o online

	Do Case
		Case cModelo == "JURA070" // Casos
			cServico := IIf(lNewSyncOn, "CasoSyncViews", "CasoViews") + "('" + AllTrim(cCodLD) + "')"
		Case cModelo == "JURA148" // Casos
			cServico := IIf(lNewSyncOn, "ClienteSyncViews", "ClienteViews") + "('" + AllTrim(cCodLD) + "')"
	End Case

Return cServico

//-------------------------------------------------------------------
/*/{Protheus.doc} JLDSincOn
Indica se a sincroniza��o ser� online

@return  _lLDSincOn  , Se .T. sincroniza��o online
                       Se .F. sincroniza��o offline (via fila de sincroniza��o)

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Function JLDSincOn()
Return _lLDSincOn

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntLDLog
Gera o log com dados do modelo e da pilha de chamadas para o registro
que ficou com a chave em branco

@param  cModelo      , ID do modelo de dados
@param  cOper        , Opera��o (verbo) da requisi��o
@param  cResult      , Resultado da requisi��o
@param  cErrorResult , Mensagem de erro da requisi��o (Ex. 404 Not Found)
@param  cCodLD       , C�digo Legaldesk do registro

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JIntLDLog(cModelo, cOper, cResult, cErrorResult, cCodLD)
Local cLog      := ""
Local aPart     := JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__cUserId), {"RD0_CODIGO", "RD0_SIGLA", "RD0_NOME"})
Local cData     := Date()
Local cHora     := Time()
Local cDataHora := cValToChar(cData) + " - " + cHora
	
	If Len(aPart) == 3
		cPart := AllTrim(aPart[1]) + " - " + AllTrim(aPart[2]) + " - " + AllTrim(aPart[3])
	EndIf

	cLog += STR0015 + cOper        + CRLF // "Opera��o: "
	cLog += STR0016 + cPart        + CRLF // "Participante: "
	cLog += STR0017 + cDataHora    + CRLF // "Data e hora de envio: "
	cLog += STR0014 + cErrorResult + CRLF // "Erro: "
	If !Empty(cResult)
		cLog += STR0018 + cResult         // "Complemento do erro: "
	EndIf

	// Faz a grava��o do arquivo no protheus_data
	JIntSavelog(cLog, cModelo, cCodLD, cData, cHora)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntSavelog
Cria o arquivo de log na pasta JURLOGSYNCONLINE dentro da protheus_data

@param  cLog   , Texto de log
@param  cModelo, ID do modelo de dados
@param  cCodLD , C�digo Legaldesk do registro
@param  cData  , Data atual
@param  cHora  , Hor�rio atual

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JIntSavelog(cLog, cModelo, cCodLD, cData, cHora)
Local cPath       := "\JURLOGSYNCONLINE\"
Local cFileName   := ""
Local nHandle     := -1
Local lChangeCase := .F.
Local lCreated    := .T.

	cData := DtoS(cData)
	cHora := StrTran(cHora, ":", "")

	If !ExistDir(cPath, Nil, lChangeCase)
		// Cria pasta JURLOGSYNCONLINE caso n�o exista
		lCreated := MakeDir(cPath, Nil, lChangeCase) == 0
	EndIf

	If lCreated
		// Formato do nome do arquivo: JURA070_20230201_172123_098767546365679892
		cFileName := cModelo + "_" + cData + "_" + cHora + "_" + AllTrim(cCodLD) + ".txt"
		nHandle   := FCreate(cPath + cFileName, Nil, Nil, lChangeCase)
		
		If nHandle == -1 // Erro ao criar arquivo
			JurLogMsg(i18N(STR0019, {cData, cHora})) // "#1 - #2 - Falha ao criar o arquivo de log!"
		Else
			FWrite(nHandle, cLog)
			FClose(nHandle)
		EndIf
	Else
		JurLogMsg(i18N(STR0020, {cData, cTime})) // "#1 - #2 - Falha ao criar o dir�torio de log!"
	EndIf

Return Nil