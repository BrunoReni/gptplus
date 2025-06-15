#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APTA100API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

/*
{Protheus.doc} laborProcess
API de Processos trabalhistas                             
@author  martins.marcio
@since   20/10/2022
@version 12.1.33
*/

WSRESTFUL laborProcess DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para Processos trabalhistas"
	WSDATA companyId	 	As String
	WSDATA branchId	     	As String
	WSDATA fields	     	As String
	WSDATA page			 	As Integer Optional
	WSDATA pageSize		 	As Integer Optional
	WSDATA order	     	As String
	WSDATA laborProcessId 	As String Optional

	WSMETHOD POST; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0002)); // "Inclui um Processo trabalhista"
	WSSYNTAX "/api/rh/v1/laborProcess" ;
	PATH "/api/rh/v1/laborProcess" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v2"

	WSMETHOD GET BYID;
	DESCRIPTION oEmToAnsi(STR0025); // "Retorna as informações de um Processo trabalhista" 
	WSSYNTAX "/api/rh/v1/laborProcess/{laborProcessId}" ;
	PATH "/api/rh/v1/laborProcess/{laborProcessId}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET ALL;
	DESCRIPTION oEmToAnsi(STR0026); // "Retorna uma lista de Processos trabalhistas" 
	WSSYNTAX "/api/rh/v1/laborProcess" ;
	PATH "/api/rh/v1/laborProcess" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD PUT; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0033)); // "Altera um Processo trabalhista" 
	WSSYNTAX "/api/rh/v1/laborProcess/{id}" ;
	PATH "/api/rh/v1/laborProcess/{id}" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v2"

	WSMETHOD DELETE; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0039)); // "Exclusão do Processo trabalhista"
	WSSYNTAX "/api/rh/v1/laborProcess/{id}" ;
	PATH "/api/rh/v1/laborProcess/{id}" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v2"

END WSRESTFUL

// Retorna Processos trabalhistas
/*/{Protheus.doc} GET BY ID
Método responsável pelo retorno de um Processo Trabalhista específico
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
@return return, return_description
/*/
WSMETHOD GET BYID WSRECEIVE companyId, branchId, laborProcessId HEADERPARAM authorization WSSERVICE laborProcess

	Local cResponse := ""
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()
	Private aUrlParam	:= ::aUrlParms

	DEFAULT Self:aUrlParms := {}
	
	Private cCompanyId	:= ""
	Private cBranchId	:= ""
	Private cProcessId	:= ""
	Private cCpfTrab	:= ""


	BEGIN SEQUENCE

		fResetErrorHandler()
		fSetErrorHandler(OemToAnsi(STR0030)) // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab;cpfTrab."
		If !Empty(Self:aUrlParms) .And. !Empty(Self:aUrlParms[1]) .And. Len(StrTokArr2(Self:aUrlParms[1],";",.T.)) >= 4
			cProcessId	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[3]
			cCpfTrab	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[4]
		Else
			fSendMess(400,OemToAnsi(STR0012),.T.,400,OemToAnsi(STR0030),,) // "Não foi possível concluir esta operação. Verifique!" // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab;cpfTrab."
		EndIf
		
		fSetErrorHandler(oEmToAnsi(STR0027)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RE1, E0A, E0B, E0C, E0D, E0G " MODULO "GPE"

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := fGetById(@oJsonData)

		// Compress String And Set Response
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	// RECOVER
	// 	lRet := .F.
	// 	ErrorBlock(bErrorBlock)
	// 	fSendError(500,oError:Description,.T.,500,STR0009,,) // STR0009: "Ocorreu uma falha no retorno da Informação."
	END SEQUENCE


Return lRet

// Retorna Processos trabalhistas
/*/{Protheus.doc} GET ALL
Método responsável pelo retorno de todos os processos cadastrados
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
@return return, return_description
/*/
WSMETHOD GET ALL QUERYPARAM companyId, branchId, page, pageSize, order, nrProcTrab HEADERPARAM authorization WSSERVICE laborProcess

	Local cResponse As Character
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()

	Private cCompanyId	As Character
	Private cBranchId	As Character
	Private cProcessId	As Character
	Private cCpfTrab	As Character 
	Private cOrder		As Character
	//Private cFields		As Character
	Private nNumePage	:= PAGE_DEFAULT
	Private nPageSize	:= PAGESIZE_DEFAULT

	BEGIN SEQUENCE

		fResetErrorHandler()
		
		fSetErrorHandler(oEmToAnsi(STR0027)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor() 
			lRet := .F.
			Return lRet
		EndIf

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RE1, E0A, E0B, E0C, E0D, E0G " MODULO "GPE"
		aEval({'RE0', 'RE1', 'E0A', 'E0B', 'E0C', 'E0D', 'E0G'},{|x|CHKFILE(x)})

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := fGetAll(@oJsonData)

		// Compress String And Set Responser
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	// RECOVER
	// 	lRet := .F.
	// 	ErrorBlock(bErrorBlock)
	// 	fSendError(500,oError:Description,.T.,500,STR0009,,) // STR0009: "Ocorreu uma falha no retorno da Informação."
	END SEQUENCE

Return lRet

// Insere um Processo trabalhista
/*/{Protheus.doc} POST
 TODO Método responsável pela inclusão de um Processo trabalhista
@author  martins.marcio
@since   20/10/2022
@version 12.1.33
@return return, return_description
/*/

WSMETHOD POST QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcess 

	Local oJson As OBJECT
	Local oBody As OBJECT
	Local cBody As Character
	Local cErroMsg As Character
	Local lRetorno As Logical
	Local cRetorno := ""
	Local aLog := {}

	Private cId As Character 
	Private cCompanyId As Character
	Private cBranchId As Character
	Private cProcessId As Character
	Private cCpfTrab As Character
	Private oError
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )

	BEGIN SEQUENCE

		oBody		:= JsonObject():New()
		cBody		:= Self:GetContent()
		lRetorno	:= .F.
		cErroMsg	:= oBody:FromJSON(DecodeUtf8(cBody))

		//Valida dados da mensagem/contrato da API
		If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0  .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items'])) 
			fSendMess(400,STR0005,.T.,400,STR0015,,) //"Corpo da mensagem inválido ou inexistente. Verifique a informação e envie novamente." ## "Erro na validação do recebimento da mensagem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
			return (lRetorno)
		Else
			oJson := oBody['items'][1]
		EndIf

		fSetErrorHandler(oEmToAnsi(STR0027)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"
		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If !fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		cProcessId	:= oJson['infoProcesso']['nrProcTrab']
		cCpfTrab	:= AllTrim(oJson['ideTrab']['cpfTrab'])
		cId 		:= cCompanyId + ";" + cBranchId + ";" + cProcessId + ";" + cCpfTrab //"companyId;branchId;processId;cpfTrab"

		//Não está permitida a inclusão de um registro pela tela:
		aAdd(aLog, oEmToAnsi(STR0041)) //"Para a inclusão de Processo utilize a rotina Manutenção de Processos Trabalhistas do módulo SGAGPE (APTA100)."
		fSendMess(403, oEmToAnsi(STR0040),.T.,403,ArrTokStr(aLog),,) //"A inclusão não é permitida por esta rotina."
		lRet := .F.
		Return lRet

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RE1, E0A, E0B, E0C, E0D, E0G " MODULO "GPE"

			// GRAVA DADOS NAS TABELAS
			lRetorno := fGrvTab(3, oJson, @cErroMsg)

			If lRetorno 
				cRetorno :=  fSendJson(oBody,cId)
				::SetResponse(cRetorno)
			Else
				aLog := {cErroMsg}
				fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,) // "não foi possível concluir esta operação. Verifique!"
			EndIf          

		// RECOVER
			//ErrorBlock(bErrorBlock)
			//fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da Informação."
		// 	fSendMess(500,"Falha crítica",.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da Informação."		
		// 	lRetorno := .F.
	END SEQUENCE

Return (lRetorno)

// Altera um Processo trabalhista
/*/{Protheus.doc} PUT
Método responsável pela alteração de um Processo trabalhista
@author  raquel.andrade
@since   07/11/2022
@version 12.1.33
@return return, return_description
/*/

WSMETHOD PUT QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcess 

	Local oJson As OBJECT
	Local oBody As OBJECT
	Local cBody As Character
	Local cErroMsg As Character
	Local lRetorno As Logical
	Local cRetorno := ""

	Private cId As Character 
	Private cCompanyId As Character
	Private cBranchId As Character
	Private cProcessId As Character
	Private cCpfTrab As Character
	Private oError
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )

	BEGIN SEQUENCE

		oBody		:= JsonObject():New()
		cBody		:= Self:GetContent()
		lRetorno	:= .F.
		cErroMsg	:= oBody:FromJSON(DecodeUtf8(cBody))
			
		//Valida dados da mensagem/contrato da API
		If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0 .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items'])) 
			fSendMess(400,STR0005,.T.,400,STR0015,,) //"Corpo da mensagem inválido ou inexistente. Verifique a informação e envie novamente." ## "Erro na validação do recebimento da mensagem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
			return (lRetorno)
		Else
			oJson := oBody['items'][1]
		EndIf

		fSetErrorHandler(oEmToAnsi(STR0027)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"
		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		cProcessId	:= oJson['infoProcesso']['nrProcTrab']
		cCpfTrab	:= AllTrim(oJson['ideTrab']['cpfTrab'])
		cId 		:= cCompanyId + ";" + cBranchId + ";" + cProcessId + ";" + cCpfTrab //"companyId;branchId;processId;cpfTrab"

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RE1, E0A, E0B, E0C, E0D, E0G " MODULO "GPE"

			// GRAVA DADOS NAS TABELAS
			lRetorno := fGrvTab(4, oJson, @cErroMsg)

			If lRetorno 
				cRetorno :=  fSendJson(oBody,cId)
				::SetResponse(cRetorno)
			Else
				aLog := {cErroMsg}
				fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,) // "Não foi possível concluir esta operação. Verifique!" 
			EndIf          

		//RECOVER
			//ErrorBlock(bErrorBlock)
			//fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."
			//fSendMess(500,"Falha crítica",.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."		
			//lRetorno := .F.
	END SEQUENCE

Return (lRetorno)

// Exclusão do Processo trabalhista
/*/{Protheus.doc} DELETE
Método responsável pela exclusão de um Processo trabalhista
@author  martins.marcio
@since   30/11/2022
@version 12.1.33
@return return, return_description
/*/
WSMETHOD DELETE QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcess 
	Local aLog := {}
	Local lRetorno := .F.

	aAdd(aLog, OemToAnsi(STR0037)) //Não é possível realizar a exclusão através desta tela, utilize a rotina de Cadastro de Processos do módulo SIGAGPE (APTA100).
	fSendMess(403,OemToAnsi(STR0038),.T.,403,ArrTokStr(aLog),,) //"A exclusão não é permitida por esta rotina."

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvTab
Atualiza tabelas com base no json recebido no body da mensagem
@author  martins.marcio
@since   24/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvTab(nOpc, oJson, cErroMsg)
	Local lRet		:= .T.
	Local aInfoRE0	:= {}
	Local aInfoRE1	:= {}
	Local aInfoE0B	:= {}
	Local aInfoE0C	:= {}
	Local aInfoE0D	:= {}
	Local aInfoSRB	:= {}
	Local nI		:= 0
	Local nX		:= 0
	Local nDep		:= 0
	Local nUnic		:= 0
	Local nExterno	:= 0
	Local nSRB		:= 0
	Local aInfoE0A	:= {}
	Local aInfoE0G	:= {}
	Local aUnicE0B	:= {}
	Local cChvUnic	:= ""
	Local cChaveE0B := ""
	Local lAchouCPF	:= .F.
	Local cChvRE0	:= ""
	Local aIdePeriod := {}
	Local cE0DCompet := ""
	Local aJUniCtr	:= {}
	Local aMudCateg	:= {}
	Local lExterno	:= .F.
	Local cChvVara	:= ""
	Local cChvSRA	:= ""
	Local cMemoDep	:= ""

	DEFAULT nOpc	:= 3
	DEFAULT oJson	:= ""
	DEFAULT cErroMsg := ""

	Private cMsgErrGrv := ""
	Private nTpInsc := 0
	Private cNrInsc	:= ""
	Private cIdPrVinc := ""

	Begin Transaction

	If ValType(oJson) == "J" 
			//RE0 - Processos
			If oJson['infoProcesso']:hasProperty("ideResp")
				aAdd(aInfoRE0,{ "RE0", "RE0_TPINSC",	cValtoChar(oJson['infoProcesso']['ideResp']['tpInsc']) })
				aAdd(aInfoRE0,{ "RE0", "RE0_NINSC",		oJson['infoProcesso']['ideResp']['nrInsc'] })
			EndIf

			aAdd(aInfoRE0,{ "RE0", "RE0_TPPROC", If(cValtoChar(oJson['infoProcesso']['origem']) == "1", "J", "A") })
			aAdd(aInfoRE0,{ "RE0", "RE0_PROJUD",	oJson['infoProcesso']['nrProcTrab'] })
			aAdd(aInfoRE0,{ "RE0", "RE0_OBS", 		oJson['infoProcesso']['obsProcTrab'] })

			aAdd(aInfoRE0,{ "RE0", "RE0_DTDECI", 	fJToD(oJson['infoProcesso']['dadosCompl']['infoProcJud']['dtSent']) }) //D
			aAdd(aInfoRE1,{ "RE1", "RE1_UF"	, 		oJson['infoProcesso']['dadosCompl']['infoProcJud']['ufVara'] })
			aAdd(aInfoRE1,{ "RE1", "RE1_CODMUN", 	cValtoChar(oJson['infoProcesso']['dadosCompl']['infoProcJud']['codMunic']) })
			aAdd(aInfoRE1,{ "RE1", "RE1_IDVARA", 	cValtoChar(oJson['infoProcesso']['dadosCompl']['infoProcJud']['idVara']) })

			aAdd(aInfoRE0,{ "RE0", "RE0_DTCCP",		fJToD(oJson['infoProcesso']['dadosCompl']['infoCCP']['dtCCP']) }) //D
			aAdd(aInfoRE0,{ "RE0", "RE0_TPCCP", 	cValtoChar(oJson['infoProcesso']['dadosCompl']['infoCCP']['tpCCP'] )})
			aAdd(aInfoRE0,{ "RE0", "RE0_CNPJCC", 	oJson['infoProcesso']['dadosCompl']['infoCCP']['cnpjCCP'] })

			// Verifica a existência do processo
			cChvRE0	:= xFilial("RE0") + PadR(oJson['infoProcesso']['nrProcTrab'], GetSx3Cache( "RE0_PROJUD", "X3_TAMANHO" ))
			DbSelectArea("RE0")
			RE0->(DbSetOrder(8)) //RE0_FILIAL+RE0_PROJUD
			If !RE0->( DbSeek(cChvRE0) )
				cErroMsg := OemToAnsi(STR0022) + oJson['infoProcesso']['nrProcTrab'] + OemToAnsi(STR0023) // "O processo (" ## ") não existe na tabela RE0, verifique!"
				Return .F.
			Else
				//Verifica se o cpfTrab corresponde com o CPF do reclamante na tabela RD0
				While RE0->( !Eof() .And. RE0_FILIAL+RE0_PROJUD == cChvRE0) .And. !lAchouCPF
					If AllTrim(Posicione("RD0", 1, xFilial("RD0") + RE0_RECLAM, "RD0_CIC")) == cCpfTrab
						lAchouCPF := .T.
						EXIT
					EndIf
					RE0->(DBSkip())
				EndDo
				If !lAchouCPF
					cErroMsg := OemToAnsi(STR0028) + cCpfTrab + OemToAnsi(STR0029) // "O CPF do trabalhador(cpfTrab) ### não corresponde com o CPF do reclamante do processo."
					Return .F.
				EndIf 
				
				// RE0 - Cadastro de Processos
				If !Empty(aInfoRE0)
					lRet := fGrvRE0(aInfoRE0, RE0->RE0_PROJUD) // >> Altera tabela RE0
				EndIf

				// RE1 - Cadastro de Vara
				If lRet .And. !Empty(aInfoRE1)
					cChvVara	:= Padl(cValToChar(oJson['infoProcesso']['dadosCompl']['infoProcJud']['idVara']), GetSx3Cache( "RE1_IDVARA", "X3_TAMANHO" ), "0") +;
								oJson['infoProcesso']['dadosCompl']['infoProcJud']['ufVara'] + ;
								Padl(cValToChar(oJson['infoProcesso']['dadosCompl']['infoProcJud']['codMunic']), GetSx3Cache( "RE1_CODMUN", "X3_TAMANHO" ), "0")
					lRet := fGrvRE1( RE0->RE0_PROJUD, cChvVara ) // >> Valida tabela RE1
					If !lRet
						cErroMsg := cMsgErrGrv
						Return .F.
					EndIf
				EndIf

				// ideTrab/dependente
				If oJson['ideTrab']:hasProperty("dependente") .And. ValType(oJson['ideTrab']['dependente']) == "A" .And. !Empty(oJson['ideTrab']['dependente'])
					For nDep := 1 to Len(oJson['ideTrab']['dependente']) 
						If oJson['ideTrab']['dependente'][nDep]:hasProperty("cpfDep")
							aAdd(aInfoSRB,{ oJson['ideTrab']['dependente'][nDep]['cpfDep']  , oJson['ideTrab']['dependente'][nDep]['tpDep'] , oJson['ideTrab']['dependente'][nDep]['descDep'] } )
							cMemoDep += oJson['ideTrab']['dependente'][nDep]['cpfDep'] + "|" + ;
										oJson['ideTrab']['dependente'][nDep]['tpDep'] + "|" + ;
										oJson['ideTrab']['dependente'][nDep]['descDep'] + "###"
						EndIf
					Next nDep
				EndIf

				If IsInCallStack("PUT")
					//Limpa registros, resíduos de execuções anteriores
					fApagaReg("E0A", 1, xFilial("E0A") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0B", 2, xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0C", 1, xFilial("E0C") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0D", 1, xFilial("E0D") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0G", 1, xFilial("E0G") + RE0->RE0_NUM + RE0->RE0_RECLAM)
				EndIf

				// infoContr
				If oJson['ideTrab']:hasProperty("infoContr") .And. ValType(oJson['ideTrab']['infoContr']) == "A" .And. !Empty(oJson['ideTrab']['infoContr'])
					For nI:= 1 to Len(oJson['ideTrab']['infoContr']) 
						If 	lRet
							//E0B - Processo por Vinculo inFoContr
							aInfoE0B := {}
							aAdd(aInfoE0B,{ "09", "E0B_TPCONT", cValtoChar(oJson['ideTrab']['infoContr'][nI]['tpContr']) })
							aAdd(aInfoE0B,{ "10", "E0B_INDCON", oJson['ideTrab']['infoContr'][nI]['indContr'] }) // N se ideResp for informado
							aAdd(aInfoE0B,{ "11", "E0B_DTADMO", fJToD(oJson['ideTrab']['infoContr'][nI]['dtAdmOrig'],"C") }) // Data como caracter no dicionario
							aAdd(aInfoE0B,{ "12", "E0B_INDREI", oJson['ideTrab']['infoContr'][nI]['indReint'] })
							aAdd(aInfoE0B,{ "13", "E0B_INDCAT", oJson['ideTrab']['infoContr'][nI]['indCateg'] })
							aAdd(aInfoE0B,{ "14", "E0B_INDNAT", oJson['ideTrab']['infoContr'][nI]['indNatAtiv'] })
							aAdd(aInfoE0B,{ "15", "E0B_INDMDE", oJson['ideTrab']['infoContr'][nI]['indMotDeslig'] })
							aAdd(aInfoE0B,{ "16", "E0B_INDUNI", oJson['ideTrab']['infoContr'][nI]['indUnic'] })
							aAdd(aInfoE0B,{ "06", "E0B_CODUNI", oJson['ideTrab']['infoContr'][nI]['matricula'] })
							aAdd(aInfoE0B,{ "07", "E0B_CATEFD", cValtoChar(oJson['ideTrab']['infoContr'][nI]['codCateg']) })
							aAdd(aInfoE0B,{ "08", "E0B_DTITSV", fJToD(oJson['ideTrab']['infoContr'][nI]['dtInicio']) }) //D
							
							If !Empty(aInfoE0B)			
								cChaveE0B := xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM
								cChaveE0B += PADR(oJson['ideTrab']['infoContr'][nI]['matricula'], GetSx3Cache( "E0B_CODUNI", "X3_TAMANHO" ))  //E0B_CODUNI
								cChaveE0B += PADR(oJson['ideTrab']['infoContr'][nI]['codCateg'], GetSx3Cache( "E0B_CATEFD", "X3_TAMANHO" )) //E0B_CATEFD
								cChaveE0B += fJToD(oJson['ideTrab']['infoContr'][nI]['dtInicio'],"C") //E0B_DTITSV
								
								If oJson['ideTrab']['infoContr'][nI]:hasProperty("infoCompl")
									aAdd(aInfoE0G,{ "2", "E0G_MEM", oJson['ideTrab']['infoContr'][nI]['infoCompl']:toJSON() })
									lExterno	:= .T.
								EndIf				
								
								lRet := fGrvE0B(aInfoE0B, cChaveE0B, lExterno) // >> Grava na tabela E0B

								nTpInsc := cValToChar(oJson['ideTrab']['infoContr'][nI]['ideEstab']['tpInsc'])
								cNrInsc	:= oJson['ideTrab']['infoContr'][nI]['ideEstab']['nrInsc']

								// E0A - Mudança de Categoria						
								aMudCateg := oJson['ideTrab']['infoContr'][nI]['mudCategAtiv']
								If ValType(aMudCateg) == "A"  .And. !Empty(aMudCateg)
									For nX := 1 to Len(aMudCateg) 
										If !Empty(aMudCateg[nX]['dtMudCategAtiv'])
											aInfoE0A := {}
											aAdd(aInfoE0A,{ "10", "E0A_NCAT",	cValtoChar(aMudCateg[nX]['codCateg']) })
											aAdd(aInfoE0A,{ "11", "E0A_NATUR",	cValtoChar(aMudCateg[nX]['natAtividade']) })
											aAdd(aInfoE0A,{ "09", "E0A_DTALT",	fJToD(aMudCateg[nX]['dtMudCategAtiv']) })							
											lRet := fGrvE0A(aInfoE0A) // >> Grava na tabela E0A
										EndIf
									Next nX
								EndIf	
											

								//E0B - Unicidade de Contrato
								// Guarda tudo no aUnicE0B para gravação na função fGrvUnic
								aJUniCtr := oJson['ideTrab']['infoContr'][nI]['unicContr']
								If ValType(aJUniCtr) == "A" .And. !Empty(aJUniCtr)
									For nUnic := 1 to Len(aJUniCtr) 
										If !Empty(aJUniCtr[nUnic]['matUnic'])
											cChvUnic := xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM
											cChvUnic += PADR(aJUniCtr[nUnic]['matUnic'], GetSx3Cache( "E0B_CODUNI", "X3_TAMANHO" ))	//E0B_CODUNI
											cChvUnic += PADR(cValtoChar(aJUniCtr[nUnic]['codCateg']), GetSx3Cache( "E0B_CATEFD", "X3_TAMANHO" ))	//E0B_CATEFD
											cChvUnic += fJToD(aJUniCtr[nUnic]['dtInicio'],"C") 										//E0B_DTITSV
											aAdd( aUnicE0B, { E0B->(Recno()), cChvUnic } )
										EndIf
									Next nUnic
								EndIf
								
								//E0C - Valores Evento S-2500 infoVlr					
								aInfoE0C := {}
								aAdd(aInfoE0C,{ "07", "E0C_COMPIN", fJToD(oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['compIni'],"C")})
								aAdd(aInfoE0C,{ "08", "E0C_COMFIM", fJToD(oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['compFim'],"C")})
								aAdd(aInfoE0C,{ "09", "E0C_REPPRO", cValtoChar(oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['repercProc'])})
								aAdd(aInfoE0C,{ "10", "E0C_VREMUN", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['vrRemun']})
								aAdd(aInfoE0C,{ "11", "E0C_VRAPI ", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['vrAPI']})
								aAdd(aInfoE0C,{ "12", "E0C_V13API", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['vr13API']})
								aAdd(aInfoE0C,{ "13", "E0C_VINDEN", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['vrInden']})
								aAdd(aInfoE0C,{ "14", "E0C_BCFGTS", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['vrBaseIndenFGTS']})
								aAdd(aInfoE0C,{ "15", "E0C_PGRESC", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['pagDiretoResc']})
								If !Empty(aInfoE0C)
									lRet := fGrvE0C(aInfoE0C) // >> Grava na tabela E0C
								EndIf
								
								//E0D - Valores mensais S-2500 idePeriodo						
								aIdePeriod := oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['idePeriodo']
								If ValType(aIdePeriod) == "A" .And. !Empty(aIdePeriod)
									For nX := 1 To Len(aIdePeriod)
										aInfoE0D := {}
										cE0DCompet := fJToD(aIdePeriod[nX]['perRef'],"C")
										aAdd(aInfoE0D,{ "07", "E0D_COMPET", cE0DCompet})						
										aAdd(aInfoE0D,{ "08", "E0D_GRAUEX", cValtoChar(aIdePeriod[nX]['baseCalculo']['infoAgNocivo']['grauExp'])})
										aAdd(aInfoE0D,{ "09", "E0D_BCINSS", aIdePeriod[nX]['baseCalculo']['vrBcCpMensal']})
										aAdd(aInfoE0D,{ "10", "E0D_BCCP13", aIdePeriod[nX]['baseCalculo']['vrBcCp13']})
										aAdd(aInfoE0D,{ "11", "E0D_BCFGTS", aIdePeriod[nX]['baseCalculo']['vrBcFgts']})
										aAdd(aInfoE0D,{ "12", "E0D_FGTS13", aIdePeriod[nX]['baseCalculo']['vrBcFgts13']})
										aAdd(aInfoE0D,{ "13", "E0D_FGTSDE", aIdePeriod[nX]['infoFGTS']['vrBcFgtsGuia']})
										aAdd(aInfoE0D,{ "14", "E0D_FG13AN", aIdePeriod[nX]['infoFGTS']['vrBcFgts13Guia']})
										aAdd(aInfoE0D,{ "15", "E0D_FGTSPG", aIdePeriod[nX]['infoFGTS']['pagDireto']}) //C?
										aAdd(aInfoE0D,{ "16", "E0D_CODCAT", cValtoChar(aIdePeriod[nX]['baseMudCateg']['codCateg'])})
										aAdd(aInfoE0D,{ "17", "E0D_BCCPRE", aIdePeriod[nX]['baseMudCateg']['vrBcCPrev']})		
										lRet := fGrvE0D(aInfoE0D, cE0DCompet) // >> Grava na tabela E0D
									Next nX
								EndIf						

								If lExterno
									If !Empty(aInfoSRB)
										aAdd(aInfoE0G,{ "1", "E0G_MEM",  cMemoDep})
									EndIf
									For nExterno := 1 to Len(aInfoE0G)
										lRet := fGrvE0G(aInfoE0G[nExterno], cIdPrVinc) // >> Grava na tabela E0G
									Next nExterno	
									If lRet
										aInfoSRB := {}
									EndIf					
								EndIf

							EndIf
						EndIf
					Next nI
				EndIf

				If !lExterno .And. !Empty(aInfoSRB)							
					cChvSRA	:= fBscChSRA(cCpfTrab )							
					For nSRB := 1 to Len(aInfoSRB)
						If lRet 
							lRet := fGrvSRB(aInfoSRB[nSRB] , cChvSRA) // >> Confere Dependentes							
						EndIf
					Next nSRB 
					If !lRet
						cErroMsg := cMsgErrGrv
					EndIf	
				EndIf

				If !Empty(aUnicE0B)
					lRet := fGrvUnic(aUnicE0B) // >> Grava TODAS as unicidades identificadas (E0B)
				EndIf	
			EndIf
		EndIf

	End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvRE0
Altera dados na tabela RE0 - Cadastro de Processos
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvRE0(aInfoRE0, cNrProcTra)
	Local lRet	:= .T.
	Local nI	:= 0

	DEFAULT aInfoRE0	:= {}

	DbSelectArea("RE0")
	RE0->(DbSetOrder(8)) //RE0_FILIAL+RE0_PROJUD
	If RE0->( DbSeek(xFilial("RE0") + cNrProcTra) )
		RecLock("RE0", .F.)
		For nI := 1 To Len(aInfoRE0)
			If aInfoRE0[nI][2] == "RE0_OBS" // Campo memo
				MsMm(fgetCdMemo(aInfoRE0[nI][2])[2], /*nTam*/, /*nLin*/, aInfoRE0[nI][3], 1, /*nTabSize*/, /*lWrap*/, "RE0", fgetCdMemo(aInfoRE0[nI][2])[1], "RDY")
				RecLock("RE0", .F.) // Garante o lock após o MSMM	
			Else	
				&(aInfoRE0[nI][2]) := aInfoRE0[nI][3]
			EndIf
		Next nI
		RE0->(MsUnlock())	
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvRE1
Grava dados na tabela RE1 - Cadastro de Varas
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvRE1(cNrProcTra ,cChvVara)
	Local lRet	:= .T.

	DEFAULT cNrProcTra	:= ""
	DEFAULT cIdVara		:= ""

	DbSelectArea("RE1")
	RE1->(DbSetOrder(3)) //RE1_FILIAL+RE1_IDVARA+RE1_UF+RE1_CODMUN
	If !RE1->( DbSeek(xFilial("RE1") + cChvVara) )
		//"Não existe Vara relacionada à Unidade Federal e Cód. de Município informados cadastrada em que o processo tramitou. "
		//"Cadastrar Vara com os dados correspondentes vincular ao processo."
		cMsgErrGrv := OemToAnsi(STR0034)
		lRet := .F.
	Else
		cNewVara	:= RE1->RE1_VARA
		DbSelectArea("RE0")
		RE0->(DbSetOrder(8)) //RE0_FILIAL+RE0_PROJUD
		If RE0->( DbSeek(xFilial("RE0") + cNrProcTra) )
			If RE0->RE0_VARA <> cNewVara
				RecLock("RE0", .F.)
				RE0->RE0_VARA := cNewVara
				RE0->RE0_COMAR := RE1->RE1_COMAR
				RE0->(MsUnlock())	
			EndIf
		EndIf		
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvSRB
Grava dados na tabela SRB - Dependentes
@author  raquel.andrade
@since   08/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvSRB(aInfoSRB , cChvSra)
	Local lRet		:= .T.
	Local lExDep	:= .F.

	DEFAULT aInfoSRB	:= {}
	DEFAULT cChvSra		:= ""

	DbSelectArea("SRB")
	SRB->(DbSetOrder(1)) //RB_FILIAL, RB_MAT, RB_COD
	If SRB->( DbSeek(cChvSra) )
		While !SRB->(Eof()) .And. SRB->RB_FILIAL + SRB->RB_MAT == cChvSra
			If aInfoSRB[1] == SRB->RB_CIC .And. aInfoSRB[2] == SRB->RB_TPDEP
				lExDep := .T.
				RecLock("SRB", .F.)
				SRB->RB_DESCDEP	:= AllTrim(aInfoSRB[3])
				SRB->(MsUnlock())
				Exit
			EndIf
			SRB->(dbskip())
		EndDo

		If !lExDep
			//"Dados Incompatíveis no Cadastro de Dependente para o CPF informado - "
			cMsgErrGrv := OemToAnsi(STR0035) + aInfoSRB[1]
			lRet := .F.
		EndIf	
	Else
		//"Não existe Dependente cadastrado com os dados informados. Para trabalhadores que possuem informação no evento S-2190, S-2200 ou S-2300, novos dependentes devem ser incluídos acessando o cadastro de Dependentes(GPEA020)."
		cMsgErrGrv := OemToAnsi(STR0036)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fBscChSRA
Busca chave Filial + Matrícula na SRA - Cadastro de Funcionários
@author  raquel.andrade
@since   08/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fBscChSRA(cCpfTrab)
	Local cChave	:= ""
	Local cFilFunc	:= ""
	Local cMatFunc	:= ""
	Local cQryAlias := GetNextAlias()

	DEFAULT cCpfTrab	:= ""

	BeginSql alias cQryAlias
		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CIC, SRA.RA_DEMISSA, SRA.RA_SITFOLH, SRA.RA_ADMISSA
		FROM %table:SRA% SRA
		WHERE SRA.RA_CIC = %exp:cCpfTrab%  AND
		SRA.RA_DEMISSA = '' AND 
		SRA.RA_SITFOLH = ''AND 
		SRA.%notDel%
		ORDER BY SRA.RA_ADMISSA DESC
	EndSql

	If (cQryAlias)->(!Eof())
		cFilFunc	:= (cQryAlias)->RA_FILIAL
		cMatFunc	:= (cQryAlias)->RA_MAT		
	EndIf

	(cQryAlias)->(DbCloseArea())
	
	cChave	:= cFilFunc + cMatFunc

Return cChave

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0B
Grava dados na tabela E0B
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0B(aInfoE0B, cChaveE0B, lExterno)
	Local lRet	:= .T.
	Local nZ	:= 0
	Local cIdVinc	:= ""

	DEFAULT aInfoE0B	:= {}
	DEFAULT cChaveE0B	:= ""
	DEFAULT lExterno	:= .F.

	DbSelectArea("E0B")
	E0B->(DbSetOrder(2)) // E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_CODUNI+E0B_CATEFD+E0B_DTITSV+E0B_IDVINC
	If !E0B->( DbSeek(cChaveE0B ) )
		RecLock("E0B", .T.)			
		cIdVinc			:= GetSx8Num("E0B","E0B_IDVINC")
		E0B->E0B_FILIAL	:= xFilial("E0B",RE0->RE0_FILIAL)	//01
		E0B->E0B_PRONUM	:= RE0->RE0_NUM						//02
		E0B->E0B_RECLAM	:= RE0->RE0_RECLAM					//03
		E0B->E0B_IDVINC	:= cIdVinc							//04
		E0B->E0B_EXT	:= If(lExterno, "1","2")
	Else
		RecLock("E0B", .F.)
		cIdVinc	:= E0B->E0B_IDVINC
	EndIf

	cIdPrVinc	:= If(Empty(cIdPrVinc), cIdVinc,cIdPrVinc)

	For nZ := 1 To Len(aInfoE0B)
		&(aInfoE0B[nZ][2]) := aInfoE0B[nZ][3]
	Next nZ
	E0B->(MsUnlock())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvUnic
Grava unicidade de contrato na tabela E0B
@author  martins.marcio
@since   27/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvUnic(aUnicE0B)
	Local lRet	:= .T.
	Local nZ	:= 0
	Local aArea := GetArea()
	Local cChave	:= ""
	Local cIdVinc	:= ""
	Local nRecFilh	:= 0
	
	DEFAULT aUnicE0B	:= {}

	If !Empty(aUnicE0B)
		DbSelectArea("E0B")
		For nZ := 1 To Len(aUnicE0B)
			cChave	:= aUnicE0B[nZ][2]
			cIdVinc	:= Posicione("E0B", 2, cChave, "E0B_IDVINC") //E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_CODUNI+E0B_CATEFD+E0B_DTITSV+E0B_IDVINC
			If !Empty(cIdVinc)
				nRecFilh := aUnicE0B[nZ][1]
				DbGoTo(nRecFilh)
				RecLock("E0B", .F.)
				E0B_VININC	:= cIdVinc // E0B_IDVINC do vinculo E0B principal
				E0B->(MsUnlock())
			else
				lRet := .F.
				cMsgErrGrv := OemToAnsi(STR0021) //"não foi possível encontrar o registro pai da unicidade de contrato."	
			EndIf
		Next nZ
	EndIf
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0C
Grava dados na tabela E0C
@author  martins.marcio
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0C(aInfoE0C)
	Local lRet	:= .T.
	Local nY	:= 0
	
	DEFAULT aInfoE0C	:= {}

	If !Empty(aInfoE0C)
		DbSelectArea("E0C")
		E0C->(DbSetOrder(1)) // E0C_FILIAL+E0C_PRONUM+E0C_RECLAM+E0C_IDVINC+E0C_TPINSC+E0C_NINSC
		If !E0C->( DbSeek(xFilial("E0C",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + nTpInsc + cNrInsc ) ) 
			RecLock("E0C", .T.)	
			E0C_FILIAL	:= xFilial("E0C",RE0->RE0_FILIAL)	//01
			E0C_PRONUM	:= RE0->RE0_NUM						//02
			E0C_RECLAM	:= RE0->RE0_RECLAM					//03
			E0C_IDVINC	:= E0B->E0B_IDVINC					//04
			E0C_TPINSC	:= nTpInsc							//05
			E0C_NINSC	:= cNrInsc							//06
		Else
			RecLock("E0C", .F.)
		EndIf

		For nY := 1 To Len(aInfoE0C)
			&(aInfoE0C[nY][2]) := aInfoE0C[nY][3]
		Next nY
		E0C->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0D
Grava dados na tabela E0D
@author  martins.marcio
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0D(aInfoE0D, cE0DCompet)
	Local lRet	:= .T.
	Local nY	:= 0
	
	DEFAULT aInfoE0D	:= {}
	DEFAULT cE0DCompet	:= ""

	If !Empty(aInfoE0D)
		DbSelectArea("E0D")
		E0D->(DbSetOrder(1)) // E0D_FILIAL+E0D_PRONUM+E0D_RECLAM+E0D_IDVINC+E0D_TPINSC+E0D_NINSC+E0D_COMPET
		If !E0D->( DbSeek(xFilial("E0D",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + cValToChar(nTpInsc) + cNrInsc + cE0DCompet ) ) 
			RecLock("E0D", .T.)	
			E0D_FILIAL	:= xFilial("E0D",RE0->RE0_FILIAL)	//01
			E0D_PRONUM	:= RE0->RE0_NUM						//02
			E0D_RECLAM	:= RE0->RE0_RECLAM					//03
			E0D_IDVINC	:= E0B->E0B_IDVINC					//04
			E0D_TPINSC	:= nTpInsc							//05
			E0D_NINSC 	:= cNrInsc							//06
		Else
			RecLock("E0D", .F.)
		EndIf

		For nY := 1 To Len(aInfoE0D)
			&(aInfoE0D[nY][2]) := aInfoE0D[nY][3]
		Next nY
		E0D->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0G
Grava dados na tabela E0G
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0G(aInfoE0G, cIdPrVinc)
	Local lRet		:= .T.
	Local cIdBusca	:= ""
	
	DEFAULT aInfoE0G	:= {}
	DEFAULT cIdPrVinc	:= ""	

	If !Empty(aInfoE0G)
		// Quando for dados de dependentes, sempre deve usar o IDVINC do PRIMEIRO VÍNCULO
		// É dessa forma que os valores são buscados no GET
		cIdBusca	:= If(aInfoE0G[1] == "1",cIdPrVinc,E0B->E0B_IDVINC) 
		DbSelectArea("E0G")
		E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC+E0G_TPINF+E0G_IDEXT
		If !E0G->( DbSeek(xFilial("E0G",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cIdBusca + aInfoE0G[1]) ) 
			RecLock("E0G", .T.)	
			E0G_FILIAL	:= xFilial("E0G",RE0->RE0_FILIAL)	//01
			E0G_PRONUM	:= RE0->RE0_NUM						//02
			E0G_RECLAM	:= RE0->RE0_RECLAM					//03
			E0G_IDVINC	:= cIdBusca					//04
			E0G_IDEXT	:= GetSX8Num("E0G","E0G_IDEXT")		//05	
			E0G_TPINF	:= aInfoE0G[1] // 1 - Dados de Dependente, 2 - Dados de Inf. Complementar
		
		Else
			RecLock("E0G", .F.)
		EndIf
		
		MsMm(fgetCdMemo(aInfoE0G[2])[2], /*nTam*/, /*nLin*/, aInfoE0G[3], 1, /*nTabSize*/, /*lWrap*/, "E0G", fgetCdMemo(aInfoE0G[2])[1], "RDY")
			
		E0G->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0A
Grava dados na tabela E0A
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0A(aInfoE0A)
	Local lRet		:= .T.
	Local nY		:= 0
	Local cChaveE0A	:= ""
	Local cDtAlt	:= ""
	
	DEFAULT aInfoE0A	:= {}

	If !Empty(aInfoE0A)
		cDtAlt	:= dtoS(aInfoE0A[3][3])
		cChaveE0A	:= xFilial("E0A",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + cDtAlt  
		DbSelectArea("E0A")
		E0A->(DbSetOrder(1)) // E0A_FILIAL+E0A_PRONUM+E0A_RECLAM+E0A_IDVINC+E0A_DTALT+E0A_IDMUD
		If !E0A->( DbSeek(cChaveE0A ) ) 
			RecLock("E0A", .T.)	
			E0A_FILIAL	:= xFilial("E0A",RE0->RE0_FILIAL)	//01
			E0A_PRONUM	:= RE0->RE0_NUM						//02
			E0A_RECLAM	:= RE0->RE0_RECLAM					//03
			E0A_IDVINC	:= E0B->E0B_IDVINC					//04
			E0A_IDMUD	:= GetSX8Num("E0A","E0A_IDMUD")		//05	
			E0A_CODUNI	:= E0B->E0B_CODUNI					//06
			E0A_CATEFD	:= E0B->E0B_CATEFD					//07
			E0A_DTTSVE	:= E0B->E0B_DTITSV					//08
		Else
			RecLock("E0A", .F.)
		EndIf

		For nY := 1 To Len(aInfoE0A)
			&(aInfoE0A[nY][2]) := aInfoE0A[nY][3]
		Next nY
		E0A->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   25/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet := sToD("")
	DEFAULT cDateJson := ""
	DEFAULT cDtType	  := "D"

	dRet := IIf(cDtType =="D", sToD( StrTran( cDateJson, "-", "" ) ), StrTran( cDateJson, "-", "" ))

Return dRet

/*/{Protheus.doc} getCodMemo
Retorna o campo codigo do campo Memo
@since	25/10/2022
@autor	martins.marcio
@version P12
/*/
Function fgetCdMemo(cNomeMemo)
	Local aCodMemo := {"", ""}
	Default cNomeMemo := ""
	
	If AllTrim(cNomeMemo) == "RE0_OBS"
		aCodMemo := {"RE0_COBS", RE0->RE0_COBS }
	ElseIf AllTrim(cNomeMemo) == "E0G_MEM"
		aCodMemo := {"E0G_CMEM", E0G->E0G_CMEM }
	EndIf

Return aCodMemo

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   27/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode := 500
	DEFAULT cMessage := STR0006 // "Erro desconhecido no processo!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	DEFAULT lJson := .T.
	DEFAULT nStatus := 500
	Default cDetailMsg := STR0006 // "Erro desconhecido no processo!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	Default cHelpUrl := ""
	DEFAULT aDetails := {}

	SetRestFault(nCode,EncodeUTF8(OemToAnsi(cMessage)),lJson,nStatus,EncodeUTF8(OemToAnsi(cDetailMsg)),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since  27/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendJson(ojson,cId)
	Local cJson			:= ""
	//Local lcompact := .F.

	// If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )        
	// 	lCompact := .T.
	// EndIf

	ojson["id"] := cId

	// If(lCompact)    	
	// 	cJson := fCompress(ojson)				
	// Else
		cJson :=  FWJsonSerialize(ojson, .F., .F., .T.)   	
	// Endif

Return (cJson)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  martins.marcio
@since   01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0024) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0024) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	EndIf

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0024) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: "
		EndIf	
	EndIf

	If ! Empty(cMessage)		
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf
	
	/* Persiste parâmetros específicos do GET ALL */
	If IsInCallStack("GET_ALL")
		//  se nPageSize vazio, maior que PAGESIZE_DEFAULT ou negativo assume o DEFAULT
		If ( Empty(nPageSize)) .OR. ( nPageSize > PAGESIZE_DEFAULT ) .OR. ( nPageSize < 1 )
			nPageSize := PAGESIZE_DEFAULT
		EndIf
		// se nPage vazio ou negativo assume o DEFAULT
		If ( Empty(nNumePage)) .OR. ( nNumePage < 1 )
			nNumePage := PAGE_DEFAULT
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetById
Retorna o processo trabalhista desejado
@author  martins.marcio
@since   01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetById(oJsonData)

	Local cQuery  	 	:= ""
	Local lRet 		 	:= .T.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local cIdTab		:= ""
	Local cQrAlias 		:= GetNextAlias()
	Local oInfoProc
	Local oIdeResp
	Local oInfoPrJud
	Local oInfoCCP
	Local oDadCompl
	Local oIdeTrab
	Local aInfoContr := {}

	fSetErrorHandler(oEmToAnsi(STR0031)) // "não foi possível realizar a query SQL."

	cQuery += "SELECT 	RE0.RE0_FILIAL BRANCHID,"	
	cQuery += "		RE0.RE0_TPPROC ORIGEM,"		
	cQuery += "		RE0.RE0_PROJUD NRPROCTRAB,"	
	cQuery += "		RE0.RE0_DTDECI DTSENT,"	
	cQuery += "		RD0.RD0_CIC CPFTRAB,"
	cQuery += "		RE1.RE1_UF UFVARA,"		
	cQuery += "		RE1.RE1_CODMUN CODMUNIC,"		
	cQuery += "		RE1.RE1_IDVARA IDVARA,"
	cQuery += "		RE0.RE0_DTCCP DTCCP,"
	cQuery += "		RE0.RE0_TPCCP TPCCP,"
	cQuery += "		RE0.RE0_CNPJCC CNPJCCP,"				
				

	cQuery += "		RE0.R_E_C_N_O_ RECNO"		

	cQuery += "		FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "		LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "		LEFT JOIN "+ RetSqlName("RE1") + " RE1 ON RE1.RE1_COMAR = RE0.RE0_COMAR AND RE1.RE1_VARA = RE0.RE0_VARA"
	cQuery += "		WHERE RE0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RE0.RE0_FILIAL = '" + xFilial("RE0") + "'"
	cQuery += "			AND   RE0.RE0_PROJUD = '" + cProcessId + "'"
	cQuery += "			AND   RD0.RD0_CIC = '" + cCpfTrab + "'"
	cQuery += "			AND   RD0.RD0_FILIAL = '" + xFilial("RD0", xFilial("RE0")) + "'"
	cQuery += "			AND   RE1.RE1_FILIAL = '" + xFilial("RE1", xFilial("RE0")) + "'"
	cQuery += "			AND   RD0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RE1.D_E_L_E_T_ = ' '	"

	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cQrAlias, .T., .T. )

	(cQrAlias)->(DBGoTop())

	// Get items Properties
	If (cQrAlias)->(!Eof())
		fSetErrorHandler(oEmToAnsi(STR0031)) // "Erro ao montar o objeto json para retorno."  

		cIdTab		:= cEmpAnt					+ ";"
		cIdTab		+= cFilAnt					+ ";"
		cIdTab		+= (cQrAlias)->NRPROCTRAB	+ ";"
		cIdTab		+= (cQrAlias)->CPFTRAB

		DbSelectArea("RE0")
		RE0->(DbGoTo((cQrAlias)->RECNO))
		
			oInfoProc	:= JsonObject():new()
				oIdeResp := JsonObject():new()
				oIdeResp['tpInsc'] := Val(RE0->RE0_TPINSC)
				oIdeResp['nrInsc'] := RE0->RE0_NINSC
			oInfoProc['ideResp'] := oIdeResp
			oInfoProc['origem'] := If((cQrAlias)->ORIGEM == "J", "1", "2")
			oInfoProc['nrProcTrab'] := AllTrim((cQrAlias)->NRPROCTRAB)
			oInfoProc['obsProcTrab'] := EncodeUtf8(MSMM(RE0->RE0_COBS,,,,3,,,"RE0",,"RDY"))
				oDadCompl := JsonObject():new()
					oInfoPrJud := JsonObject():new()
					oInfoPrJud['dtSent']	:= fDtToJson((cQrAlias)->DTSENT) 
					oInfoPrJud['ufVara']	:= IIf(!Empty((cQrAlias)->UFVARA),(cQrAlias)->UFVARA,"") 
					oInfoPrJud['codMunic']	:= Val(IIf(!Empty((cQrAlias)->CODMUNIC),(cQrAlias)->CODMUNIC, "0"))
					oInfoPrJud['idVara']	:= Val(IIf(!Empty((cQrAlias)->IDVARA),(cQrAlias)->IDVARA,"0"))
				oDadCompl['infoProcJud'] := oInfoPrJud
					oInfoCCP := JsonObject():new()
					oInfoCCP['dtCCP']	:= fDtToJson((cQrAlias)->DTCCP)
					oInfoCCP['tpCCP']	:= Val((cQrAlias)->TPCCP)
					oInfoCCP['cnpjCCP']	:= (cQrAlias)->CNPJCCP
				oDadCompl['infoCCP'] := oInfoCCP
			oInfoProc['dadosCompl'] := oDadCompl

			oIdeTrab	:= JsonObject():new()
			oIdeTrab['cpfTrab'] := cCpfTrab
			DbSelectArea("RD0")
			RD0->(DbSetOrder(6)) 
			cChvRD0	:= xFilial("RD0") + cCpfTrab + RE0->RE0_RECLAM 	
			If RD0->(DbSeek(cChvRD0)) 
				oIdeTrab['nmTrab'] := IIF(!Empty(RD0->RD0_NOME), Left(Alltrim(RD0->RD0_NOME), 70), Alltrim(RD0->RD0_NOME) )
				oIdeTrab['dtNascto'] := fDtToJson(RD0->RD0_DTNASC)
			Else
				oIdeTrab['nmTrab']	 := ""
				oIdeTrab['dtNascto'] := ""
			EndIf	

			//E0B - infoContr
			aInfoContr := fGetInfCtr(xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM, @oIdeTrab, cCpfTrab)
			oIdeTrab['infoContr'] := aInfoContr	

		oItemData := JsonObject():new()
		oItemData['companyId']	:= cEmpAnt
		oItemData['branchId']	:= cFilAnt
		oItemData['excluidoERP'] := "N"
		oItemData['infoProcesso'] := oInfoProc
		oItemData['ideTrab'] := oIdeTrab
		oItemData["id"] := cIdTab

		AAdd(aItemQry, oItemData )

		oCabecData["hasNext"] 		  := .F.

	EndIf

	oCabecData["items"] := aItemQry
	oJsonData := oCabecData


	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetAll
Retorna json com a lista de Processos trabalhistas
@author  martins.marcio
@since   01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetAll(oJsonData)

	Local cQuery  	 	:= ""
	Local lRet 		 	:= .T.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local cIdTab		:= ""
	Local cDataBase		:= TcGetDB() 
	Local cQrAlias 		:= GetNextAlias()
	Local cOrdQry		:= fOrdQry(cOrder)

	dbSelectArea("RE0")

	// Create Paging Control
	cQuery := "		SELECT JSO.* FROM ( "

	cQuery += IIf(cDataBase == "ORACLE"		,"	SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  ",;
				IIf(cDataBase == "POSTGRES"	,"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER, DADOS.* ",;
											"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT(1) OVER() TOTALNUMBER, DADOS.* ")) //MSSQL
	
	cQuery += "			FROM (	"
	cQuery += "			SELECT 	RE0.RE0_FILIAL BRANCHID,"	
	cQuery += "					RE0.RE0_TPPROC ORIGEM,"		
	cQuery += "					RE0.RE0_PROJUD NRPROCTRAB,"	
	cQuery += "					RD0.RD0_CIC CPFTRAB,"		
	cQuery += "					RD0.RD0_NOME NMTRAB,"		
	cQuery += "					RD0.R_E_C_N_O_ RECNO"		

	cQuery += "			FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "			LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "			WHERE RE0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RE0.RE0_FILIAL = '" + xFilial("RE0") + "'"
	cQuery += "			AND   RD0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RD0.RD0_FILIAL = '" + xFilial("RD0", xFilial("RE0")) + "'"
	If !Empty(cProcessId)
		cQuery += "			AND   RE0.RE0_PROJUD = '" + cProcessId + "'"
	EndIf
	If !Empty(cCpfTrab)
		cQuery += "			AND   RD0.RD0_CIC = '" + cCpfTrab + "'"
	EndIf

	cQuery += "			) DADOS "

	cQuery += "			) JSO"
	cQuery += "	        WHERE JSO.ITEMNUMBER BETWEEN " + Alltrim(Str((nNumePage - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((nNumePage * nPageSize))) + " "
	
	cQuery += cOrdQry //ORDER BY
		
	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cQrAlias, .T., .T. )

	(cQrAlias)->(DBGoTop())

	If lRet
		// Get items Properties
		While (cQrAlias)->(!Eof())

			oItemData := JsonObject():new()
			cIdTab		:= cEmpAnt					+ ";"
			cIdTab		+= cFilAnt					+ ";"
			cIdTab		+= (cQrAlias)->NRPROCTRAB	+ ";"
			cIdTab		+= (cQrAlias)->CPFTRAB

			oItemData["companyId"]			:= cEmpAnt
			oItemData["branchId"]			:= (cQrAlias)->BRANCHID
			oItemData["origem"]				:= Val((cQrAlias)->ORIGEM)
			oItemData["nrProcTrab"]			:= (cQrAlias)->NRPROCTRAB
			oItemData["cpfTrab"]			:= (cQrAlias)->CPFTRAB
			oItemData["nmTrab"]				:= AllTrim((cQrAlias)->NMTRAB)
			oItemData["id"]					:= cIdTab

			AAdd(aItemQry, oItemData )

			oCabecData["hasNext"] 		  := Iif((cQrAlias)->ITEMNUMBER >= (cQrAlias)->TOTALNUMBER, .F., .T.)

			(cQrAlias)->(DBSkip())
		EndDo

		oCabecData["items"] := aItemQry
		oJsonData := oCabecData
	EndIf

	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fOrdQry
Retorna o filtro para ser utilizado na query
@author  martins.marcio
@since  01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fOrdQry(cApiOrder)
	Local cQryRet	:= " "
	Local aQryFilt	:= {}
	Local nI		:= 0
	Local cCpoOrd	:= ""

	DEFAULT cApiOrder := ""

	If !Empty(cApiOrder)
		aQryFilt := StrTokArr( cApiOrder , ',' )
		For nI := 1 To Len(aQryFilt)
			cCpoOrd := AllTrim(Upper(strTran(aQryFilt[nI], "-", "")))
			
			If cCpoOrd $ "ORIGEM;NRPROCTRAB;CPFTRAB"
				cQryRet += cCpoOrd
				cQryRet += IIf(LEFT(AllTrim(aQryFilt[nI]),1) == "-", " DESC,", ",")
			EndIf
		Next nI
	EndIf

	If Empty(cQryRet)
		cQryRet := " ORDER BY ORIGEM, NRPROCTRAB, CPFTRAB "
	Else
		cQryRet := Left(cQryRet,(Len(cQryRet)-1))  // Retira a virgula do final da string
		cQryRet := " ORDER BY " + cQryRet
	EndIf

Return cQryRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetInfCtr
Retorna um array de infoContr
@author  martins.marcio
@since  07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetInfCtr(cChaveE0B, oIdeTrab, cCpfTrab)
	Local aInfoContr := {}
	Local oInfoContr
	Local oInfoCompl
	Local oMudCateg
	Local aMudCateg := {}
	Local cErroMsg	
	Local cJMemoE0G := ""
	Local cChaveE0A	:= ""
	Local aUniContr	:= {}
	Local oIdeEstab
	Local oInfoVlr
	Local aIdePer := {}
	Local oIdePer
	Local cChaveE0D	:= ""
	Local oBsCalc
	Local oAgNociv
	Local oInfoFGTS
	Local oBsMudCat
	Local nRecE0B
	Local oDepend
	Local cIdPrVinc	:= ""
	Local cMemoDep	:= ""
	Local aDadosDep	:= {}
	Local aDepMemo	:= {}
	Local aDep		:= {}
	Local nI		:= 0
	
	DEFAULT cChaveE0B := xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM

	DbSelectArea("E0B")
	E0B->(DbSetOrder(2)) // E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_CODUNI+E0B_CATEFD+E0B_DTITSV+E0B_IDVINC
	If E0B->( DbSeek(cChaveE0B ) )//#empty infoContr[] := aInfoContr
		cIdPrVinc	:= E0B->E0B_IDVINC
		// Dependente
		DbSelectArea("E0G")
		E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC+E0G_TPINF+E0G_IDEXT
		If E0G->( DbSeek(xFilial("E0G",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cIdPrVinc + "1" ) ) 
			cMemoDep := EncodeUtf8(MSMM(E0G->E0G_CMEM,,,,3,,,"E0G",,"RDY"))
			If !Empty(cMemoDep)
				aDepMemo := StrTokArr( cMemoDep , '###' )
				For nI := 1 to Len(aDepMemo)
					oDepend	:= JsonObject():new()
					aDep	:= StrTokArr( aDepMemo[nI] , '|' )
					oDepend['cpfDep']	:= IIf(Len(aDep) >= 1,aDep[1],"")
					oDepend['tpDep']	:= IIf(Len(aDep) >= 2,aDep[2],"")
					oDepend['descDep']	:= IIf(Len(aDep) >= 3,aDep[3],"")
					aAdd(aDadosDep, oDepend)	
				Next nI
				oIdeTrab['dependente'] := aDadosDep
			EndIf
		Else
			cChvSRA	:= fBscChSRA(cCpfTrab)
			
			DbSelectArea("SRB")
			SRB->(DbSetOrder(1))
			If !Empty(cChvSRA) .And. SRB->(DbSeek(cChvSRA))
				While SRB->( !Eof() ) .And. SRB->RB_FILIAL + SRB->RB_MAT  == cChvSRA
					oDepend	:= JsonObject():new()
					oDepend['cpfDep']	:= SRB->RB_CIC
					oDepend['tpDep']	:= SRB->RB_TPDEP
					oDepend['descDep']	:= SRB->RB_DESCDEP 
					aAdd(aDadosDep, oDepend)
				SRB->(DBSkip())
				EndDo
				oIdeTrab['dependente'] := aDadosDep
			EndIf
		EndIf

		While E0B->( !Eof() .And. E0B_FILIAL+E0B_PRONUM+E0B_RECLAM == cChaveE0B)
			oInfoContr := JsonObject():new()
			oInfoContr['tpContr']		:= Val(E0B->E0B_TPCONT)
			oInfoContr['indContr']		:= E0B->E0B_INDCON
			oInfoContr['dtAdmOrig']		:= fDtToJson(E0B->E0B_DTADMO)
			oInfoContr['indReint']		:= E0B->E0B_INDREI
			oInfoContr['indCateg']		:= E0B->E0B_INDCAT
			oInfoContr['indNatAtiv']	:= E0B->E0B_INDNAT
			oInfoContr['indMotDeslig']	:= E0B->E0B_INDMDE
			oInfoContr['indUnic']		:= E0B->E0B_INDUNI
			oInfoContr['matricula']		:= AllTrim(E0B->E0B_CODUNI)
			oInfoContr['codCateg']		:= Val(E0B->E0B_CATEFD)
			oInfoContr['dtInicio']		:= fDtToJson(E0B->E0B_DTITSV)
			
			nRecE0B		:= E0B->( Recno() )	
			aUniContr := fGetUnic(E0B->E0B_VININC)
			E0B->( dbGoTo(nRecE0B) )

			// Informações Complementares
			DbSelectArea("E0G")
			E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC+E0G_TPINF+E0G_IDEXT
			If E0G->( DbSeek(xFilial("E0G",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + "2" ) ) 
				oInfoCompl := JsonObject():new()
				cJMemoE0G := EncodeUtf8(MSMM(E0G->E0G_CMEM,,,,3,,,"E0G",,"RDY"))
				cErroMsg := oInfoCompl:FromJSON(cJMemoE0G)
			Else
				oInfoCompl := getEmptyObj("infoCompl")
			EndIf
			oInfoContr['infoCompl'] := oInfoCompl

			aMudCateg := {}
			DbSelectArea("E0A")
			E0A->(DbSetOrder(1)) // E0A_FILIAL+E0A_PRONUM+E0A_RECLAM+E0A_IDVINC+E0A_IDMUD
			cChaveE0A := xFilial("E0A",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC
			If E0A->( DbSeek( cChaveE0A ) ) //#empty mudCategAtiv[] := aMudCateg
				While E0A->( !Eof() .And. E0A_FILIAL+E0A_PRONUM+E0A_RECLAM+E0A_IDVINC == cChaveE0A)
					oMudCateg := JsonObject():new()
					oMudCateg['codCateg']		:= Val(E0A->E0A_NCAT)
					oMudCateg['natAtividade']	:= Val(E0A->E0A_NATUR)
					oMudCateg['dtMudCategAtiv']	:= fDtToJson(E0A->E0A_DTALT)
					aAdd(aMudCateg, oMudCateg)
					E0A->(DBSkip())
				EndDo
			Else
				aMudCateg := getEmptyObj("mudCategAtiv")
			EndIf
			oInfoContr['mudCategAtiv'] := aMudCateg

			oInfoContr['unicContr'] := aUniContr

			oIdeEstab := JsonObject():new()
			oInfoVlr := JsonObject():new()
			DbSelectArea("E0C")
			E0C->(DbSetOrder(1)) // E0C_FILIAL+E0C_PRONUM+E0C_RECLAM+E0C_IDVINC+E0C_TPINSC+E0C_NINSC
			If E0C->( DbSeek(xFilial("E0C",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC ) ) //#empty infoVlr{} := oInfoVlr
				oIdeEstab['tpInsc']			:= Val(E0C->E0C_TPINSC)
				oIdeEstab['nrInsc']			:= E0C->E0C_NINSC								
				oInfoVlr['compIni']			:= fDtToJson(E0C->E0C_COMPIN)
				oInfoVlr['compFim']			:= fDtToJson(E0C->E0C_COMFIM)
				oInfoVlr['repercProc']		:= Val(E0C->E0C_REPPRO)
				oInfoVlr['vrRemun']			:= E0C->E0C_VREMUN
				oInfoVlr['vrAPI']			:= E0C->E0C_VRAPI
				oInfoVlr['vr13API']			:= E0C->E0C_V13API
				oInfoVlr['vrInden']			:= E0C->E0C_VINDEN
				oInfoVlr['vrBaseIndenFGTS'] := E0C->E0C_BCFGTS
				oInfoVlr['pagDiretoResc'] 	:= AllTrim(E0C->E0C_PGRESC)

			DbSelectArea("E0D")
			E0D->(DbSetOrder(1)) // E0D_FILIAL+E0D_PRONUM+E0D_RECLAM+E0D_IDVINC+E0D_TPINSC+E0D_NINSC+E0D_COMPET
			cChaveE0D := xFilial("E0D",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + E0C->E0C_TPINSC + E0C->E0C_NINSC
			aIdePer := {}
			If E0D->( DbSeek( cChaveE0D ) )  //#empty idePeriodo[] := aIdePer
				While E0D->( !Eof() .And. E0D_FILIAL+E0D_PRONUM+E0D_RECLAM+E0D_IDVINC+E0D_TPINSC+E0D_NINSC == cChaveE0D)
					oIdePer := JsonObject():new() 	
					oIdePer['perRef'] := fDtToJson(E0D->E0D_COMPET)					
						oBsCalc  := JsonObject():new()
						oBsCalc['vrBcCpMensal'] := E0D->E0D_BCINSS
						oBsCalc['vrBcCp13'] 	:= E0D->E0D_BCCP13
						oBsCalc['vrBcFgts']		:= E0D->E0D_BCFGTS
						oBsCalc['vrBcFgts13']	:= E0D->E0D_FGTS13
							oAgNociv := JsonObject():new()
							oAgNociv['grauExp']	:= Val(E0D->E0D_GRAUEX)
						oBsCalc['infoAgNocivo']	:= oAgNociv
					oIdePer['baseCalculo'] := oBsCalc
						oInfoFGTS := JsonObject():new()
						oInfoFGTS['vrBcFgtsGuia']	:= E0D->E0D_FGTSDE
						oInfoFGTS['vrBcFgts13Guia']	:= E0D->E0D_FG13AN
						oInfoFGTS['pagDireto']		:= E0D->E0D_FGTSPG
					oIdePer['infoFGTS'] := oInfoFGTS
						oBsMudCat := JsonObject():new()
							oBsMudCat['codCateg']		:= Val(E0D->E0D_CODCAT)
							oBsMudCat['vrBcCPrev']		:= E0D->E0D_BCCPRE
						oIdePer['baseMudCateg'] := oBsMudCat

						aAdd(aIdePer, oIdePer)
						E0D->(DBSkip())
					EndDo
				Else
					aIdePer := getEmptyObj("idePeriodo")
				EndIf
				oInfoVlr['idePeriodo'] := aIdePer
			Else
				oInfoVlr := getEmptyObj('infoVlr')	
			EndIf
			oIdeEstab['infoVlr'] := oInfoVlr

			oInfoContr['ideEstab'] := oIdeEstab

			aAdd(aInfoContr, oInfoContr)
			E0B->(DBSkip())
		EndDo
	Else
		aInfoContr := getEmptyObj("infoContr")
	EndIf

Return aInfoContr

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetUnic
Carrega a unicidade de contrato e retorna no array
@author  martins.marcio
@since   07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetUnic(cIdVincPai)
	
	Local aArea		:= GetArea()
	Local cChvE0B	:= ""
	Local oUnicCtr	:= JsonObject():new()
	Local aUniContr	:= {}
	Local lTemUnic	:= .F.
	
	DEFAULT cIdVincPai	:= ""

	If !Empty(cIdVincPai)
		DbSelectArea("E0B")
		cChvE0B := E0B_FILIAL + E0B_PRONUM + E0B_RECLAM + cIdVincPai
		E0B->(DbSetOrder(1)) // E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_IDVINC
		If E0B->( DbSeek(cChvE0B ) )
			lTemUnic := .T.
			oUnicCtr['matUnic']		:= E0B->E0B_CODUNI
			oUnicCtr['codCateg']	:= Val(E0B->E0B_CATEFD)
			oUnicCtr['dtInicio']	:= fDtToJson(E0B->E0B_DTITSV)
		 	aAdd(aUniContr, oUnicCtr)
		EndIf
	EndIf

	RestArea( aArea )

Return aUniContr


//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetQryPar
Carrega os valores dos parâmetros de query
@author  martins.marcio
@since  01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSetQryPar(aQueryString)

	Local nX as Numeric
	DEFAULT aQueryString := {}

	For nX := 1 To Len(aQueryString)	
		Do Case
			Case UPPER(AllTrim(aQueryString[nX][1])) == "COMPANYID" 	
				cCompanyId := aQueryString[nX][2]	
			Case UPPER(AllTrim(aQueryString[nX][1])) == "BRANCHID"
				cBranchId := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "NRPROCTRAB"
				cProcessId := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "CPFTRAB"
				cCpfTrab := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "ORDER"
				cOrder := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGE"
				nNumePage := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGESIZE"
				nPageSize := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "FIELDS"
				cFields := aQueryString[nX][2]
		EndCase
	Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDtToJson
Converte data para o formato utilizado no json
@author  martins.marcio
@since  07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fDtToJson(cStrDate)
	Local cJsonDt	:= ""
	DEFAULT cStrDate := ""
	If ValType(cStrDate) == "D"
		cStrDate := DTOS(cStrDate)
	EndIf
	cStrDate := AllTrim(cStrDate)
	Do Case
		Case Len(cStrDate) == 8
			cJsonDt := SubStr(cStrDate,1,4) + "-" + SubStr(cStrDate,5,2) + "-" + SubStr(cStrDate,7,2)
		Case Len(cStrDate) == 6
			cJsonDt := SubStr(cStrDate,1,4) + "-" + SubStr(cStrDate,5,2)
	EndCase
Return cJsonDt

//-------------------------------------------------------------------
/*/{Protheus.doc} function getEmptyObj
Retorna um objeto vazio quando não forem encontrados dados nas tabelas
@author  martins.marcio
@since  07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function getEmptyObj(cTipoObj)
	Local xObjRet
	Local oJson
	Local cTxt := ""

	DEFAULT cTipoObj := ""
	If !Empty(cTipoObj)
		Do Case
			Case cTipoObj == "idePeriodo" 	 //E0D 
				xObjRet := {}

			Case cTipoObj == "infoVlr" // E0C
				oJson := JsonObject():new()
				cTxt := '{ "compIni": "", "compFim": "", "repercProc": 0, "vrRemun": 0, "vrAPI": 0, "vr13API": 0, "vrInden": 0, "vrBaseIndenFGTS": 0, "pagDiretoResc": "", "idePeriodo": [] }'
				oJson:FromJSON(cTxt)
				oJson['idePeriodo'] := getEmptyObj("idePeriodo")
				xObjRet := oJson
			
			Case cTipoObj == "mudCategAtiv" //E0A
				xObjRet := {}

			Case cTipoObj == "infoCompl" // E0G
				oJson := JsonObject():new()
				cTxt := '{ "codCBO": "", "natAtividade": 0, "remuneracao": [], "infoVinc": { "tpRegTrab": 0, "tpRegPrev": 0, "dtAdm": "", "tmpParc": -1, "duracao": { "tpContr": 0, "dtTerm": "", "clauAssec": "", "objDet": "" }, "observacoes": [ ], "sucessaoVinc": { "tpInsc": 0, "nrInsc": "", "matricAnt": "", "dtTransf": "" }, "infoDeslig": { "dtDeslig": "", "mtvDeslig": "", "dtProjFimAPI": "" } }, "infoTerm": { "dtTerm": "", "mtvDesligTSV": "" } }'
				oJson:FromJSON(cTxt)
				xObjRet := oJson

			Case cTipoObj == "infoContr" //E0B
				xObjRet := {}

		EndCase
	EndIf

Return xObjRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  07/11/2022
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode := 500
	DEFAULT cMessage := STR0009
	DEFAULT lJson := .T.
	DEFAULT nStatus := 500
	Default cDetailMsg := STR0009
	Default cHelpUrl := ""
	DEFAULT aDetails := {}

	SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fApagaReg
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  02/12/2022
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fApagaReg(cAlias, nIndice, cChave)

	Local aArea		:= GetArea()
	Local cCPOsChv	:= "###->###_FILIAL+###->###_PRONUM+###->###_RECLAM"

	DEFAULT cAlias	:= ""
	DEFAULT nIndice := 1
	DEFAULT cChave	:= ""

	If !Empty(cAlias) .And. !Empty(cChave)		
		
		cCPOsChv := StrTran( cCPOsChv, "###", cAlias )

		DbSelectArea(cAlias)
		DbSetOrder(1)
		If DbSeek(cChave)
			While (cAlias)->( !Eof() .And. &(cCPOsChv) == cChave)
				If (cAlias)->( RecLock(cAlias,.F.) )
					(cAlias)->(DbDelete())
					(cAlias)->(MsUnlock())
				EndIf
				(cAlias)->(DBSkip())
			EndDo
		EndIf
	EndIf

	RestArea( aArea )

Return .T.
