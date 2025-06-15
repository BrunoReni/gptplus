#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "JURINTLD.CH"

Static _lLDSincOn := .F. // Indica se a sincronização com o LD foi online

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIntLD
Realiza operações de forma online na integração Protheus x Legaldesk

@param  cVerbo   , Verbo da requisição (DELETE, POST, PUT)
@param  cModelo  , ID do modelo de dados
@param  cCodLD   , Código Legaldesk do registro
@param  nRecnoEnt, Recno do registro
@param  aHeader  , Header adicional (se necessário para algum modelo específico)

@return lRet     , Indica se o registro no protheus pode ser excluído

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

	If !JurIsRest()// Somente execução via Protheus e com os parâmetros preenchidos
		Processa( {|| lRet := JRunIntLD(cVerbo, cModelo, cCodLD, nRecnoEnt, aHeader) }, STR0001, STR0002, .F. )  // "Aguarde" - "Sincronizando registro"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRunIntLD
Processamento da requisição no Legaldesk para operações (exclusão) de registros

@param  cVerbo   , Verbo da requisição (DELETE, POST, PUT)
@param  cModelo  , ID do modelo de dados
@param  cCodLD   , Código Legaldesk do registro
@param  nRecnoEnt, Recno do registro
@param  aHeader  , Header adicional (se necessário para algum modelo específico)

@return lRet     , Indica se o registro no protheus pode ser excluído

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
Local cHost        := SuperGetMV("MV_JLDURL", .F., "") // URL de integração com LD
Local cUser        := SuperGetMV("MV_JLDUSR", .F., "") // Usuário de integração com LD
Local cPwd         := SuperGetMV("MV_JLDPWD", .F., "") // Senha do usuário de integração com LD

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
				Case lResult2xx // Resultados válidos -- Resultados 2xx
					// Vai excluir o registro e NÃO vai adicionar na NYS
					_lLDSincOn := .T. // Indica que houve sincronização online
				
				Case cCodeResult == "404" .Or. lResult5xx // 404 ou Erros 5xx
					// 404 - Not Found - Se não encontrar o registro na exclusão online
					// 5xx - Problemas na conexão

					// Vai excluir o registro e vai adicionar na NYS
					_lLDSincOn := .F. // Indica que não houve sincronização online

					// Inclui arquivo de Log
					JIntLDLog(cModelo, cVerbo, oRest:GetResult(), oRest:GetLastError(), cCodLD)

				Case cCodeResult == "401" // Unauthorized - Usuário ou senha incorretos
					cProblema := STR0003 // "Não foi possível excluir o registro devido a falha na autenticação (usuário ou senha inválidos) durante a sincronização dos dados com o LEGALDESK"
					cSolucao  := STR0004 // "Contate a equipe técnica para verificar o preenchimento dos parâmetros MV_JLDUSR e MV_JLDPWD. Após o ajuste, refaça a operação."

				Case cCodeResult == "403" // Forbidden - Usuário sem direito de acesso
					cProblema := STR0005 // "Não foi possível excluir o registro devido a permissão de acesso durante a sincronização dos dados com o LEGALDESK"
					cSolucao  := STR0006 // "Contate a equipe técnica para verificar no LEGALDESK a permissão do usuário (indicado no parâmetro MV_JLDUSR). Após o ajuste, refaça a operação."

				Case Empty(cCodeResult) .And. Empty(oRest:GetResult()) // URL inválida
					If "HOST NOT FOUND" $ Upper(oRest:GetLastError())
						cProblema := STR0007 // "Não foi possível excluir o registro devido a falha na conexão durante a sincronização dos dados com o LEGALDESK"
						cSolucao  := STR0008 // "Contate a equipe técnica para verificar o preenchimento do parâmetro MV_JLDURL. Após o ajuste, refaça a operação."
					Else
						cProblema := STR0009 // "Não foi possível excluir o registro devido a falha de comunicação na sincronização dos dados com o LEGALDESK"
						cSolucao  := STR0010 // "Contate a equipe técnica."
					EndIf

				Case cCodeResult == "400" .And. !Empty(oRest:GetResult()) // Alguma validação no LD impede a exclusão

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

					cProblema := STR0011 + CRLF + CRLF + STR0012 + cErrorResult // "Não foi possível excluir o registro devido a regra não atendida durante a sincronização dos dados com o LEGALDESK. " - "Regra: "
					cSolucao  := STR0013 // "Contate a equipe técnica para verificar as regras no LEGALDESK."

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
Indica o serviço que será executado conforme o modelo

@param  cModelo  , ID do modelo de dados
@param  cCodLD   , Código Legaldesk do registro

@return cServico , Serviço que será executado junto com o código Legaldesk

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JIntLDServ(cModelo, cCodLD)
Local cServico   := ""
Local lNewSyncOn := FindFunction("J300ChkVer") .And. J300ChkVer("2023.1.0.0") // Nessa versão do LD funciona a nova versão do serviço de sincronização online

	Do Case
		Case cModelo == "JURA070" // Casos
			cServico := IIf(lNewSyncOn, "CasoSyncViews", "CasoViews") + "('" + AllTrim(cCodLD) + "')"
		Case cModelo == "JURA148" // Casos
			cServico := IIf(lNewSyncOn, "ClienteSyncViews", "ClienteViews") + "('" + AllTrim(cCodLD) + "')"
	End Case

Return cServico

//-------------------------------------------------------------------
/*/{Protheus.doc} JLDSincOn
Indica se a sincronização será online

@return  _lLDSincOn  , Se .T. sincronização online
                       Se .F. sincronização offline (via fila de sincronização)

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
@param  cOper        , Operação (verbo) da requisição
@param  cResult      , Resultado da requisição
@param  cErrorResult , Mensagem de erro da requisição (Ex. 404 Not Found)
@param  cCodLD       , Código Legaldesk do registro

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

	cLog += STR0015 + cOper        + CRLF // "Operação: "
	cLog += STR0016 + cPart        + CRLF // "Participante: "
	cLog += STR0017 + cDataHora    + CRLF // "Data e hora de envio: "
	cLog += STR0014 + cErrorResult + CRLF // "Erro: "
	If !Empty(cResult)
		cLog += STR0018 + cResult         // "Complemento do erro: "
	EndIf

	// Faz a gravação do arquivo no protheus_data
	JIntSavelog(cLog, cModelo, cCodLD, cData, cHora)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntSavelog
Cria o arquivo de log na pasta JURLOGSYNCONLINE dentro da protheus_data

@param  cLog   , Texto de log
@param  cModelo, ID do modelo de dados
@param  cCodLD , Código Legaldesk do registro
@param  cData  , Data atual
@param  cHora  , Horário atual

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
		// Cria pasta JURLOGSYNCONLINE caso não exista
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
		JurLogMsg(i18N(STR0020, {cData, cTime})) // "#1 - #2 - Falha ao criar o dirétorio de log!"
	EndIf

Return Nil