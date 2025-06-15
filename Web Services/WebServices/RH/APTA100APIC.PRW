#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APTA100APIC.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

/*
{Protheus.doc} laborProcessEmployees
API de Trabalhadores do Processo trabalhista                             
@author  martins.marcio
@since   21/11/2022
@version 12.1.33
*/

WSRESTFUL laborProcessEmployees DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para Pagamentos do Processo trabalhista" 
	WSDATA companyId	 	As String
	WSDATA branchId	     	As String
	WSDATA id				As String

	WSMETHOD GET;
	DESCRIPTION oEmToAnsi(STR0002); // "Retorna a lista de trabalhadores de um Processo trabalhista" 
	WSSYNTAX "/api/rh/v1/laborProcessEmployees/{id}" ;
	PATH "/api/rh/v1/laborProcessEmployees/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

END WSRESTFUL

// Retorna pagamentos/tributos do processo trabalhista S-2501
/*/{Protheus.doc} GET BY ID
Método responsável pelo retorno de tributos/pagamentos de um Processo Trabalhista específico
@author  martins.marcio
@since   21/11/2022
@version 12.1.33
@return return, return_description
/*/
WSMETHOD GET QUERYPARAM companyId, branchId, id HEADERPARAM authorization WSSERVICE laborProcessEmployees

	Local cResponse := ""
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()
	Local aParms	:= {}
	Local aInfoPar	:= {}

	DEFAULT Self:aUrlParms := {}
	
	Private aUrlParam	:= ::aUrlParms
	Private cCompanyId	:= ""
	Private cBranchId	:= ""
	Private cProcessId	:= ""

	BEGIN SEQUENCE

		aParms := StrTokArr2(Self:aUrlParms[1],";",.T.)
		
		fResetErrorHandler()
		fSetErrorHandler(OemToAnsi(STR0003)) // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab" 
		
		If !Empty(Self:aUrlParms) .And. !Empty(aParms) .And. Len(aParms) >= 3
			cProcessId	:= aParms[3]
			aAdd(aInfoPar, {"COMPANYID", aParms[1]})
			aAdd(aInfoPar, {"BRANCHID", aParms[2]})
			aAdd(aInfoPar, {"NRPROCTRAB", aParms[3]})
		Else
			fSendMess(400,OemToAnsi(STR0004),.T.,400,OemToAnsi(STR0003),,) // "Não foi possível concluir esta operação. Verifique!" 
		EndIf
		
		fSetErrorHandler(oEmToAnsi(STR0005)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!" 

		fSetQryPar(aInfoPar)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RE1, E0A, E0B, E0C, E0D, E0E, E0F, E0G " MODULO "GPE"
		aEval({'RE0', 'RE1', 'E0A', 'E0B', 'E0C', 'E0D', 'E0E', 'E0F', 'E0G'},{|x|CHKFILE(x)})

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := fGetTrab(@oJsonData)

		// Compress String And Set Response
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	// RECOVER
	// 	lRet := .F.
	// 	ErrorBlock(bErrorBlock)
	// 	fSendError(500,oError:Description,.T.,500,STR0009,,) // STR0009: "Ocorreu uma falha no retorno da Informação."
	END SEQUENCE


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetTrab
Retorna json com a lista de Pagamentos do Processo trabalhista
@author  martins.marcio
@since   21/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetTrab(oJsonData)

	Local lRet 		 	:= .T.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local aCPFList		:= fgetRE0Cpf(cProcessId)
	Local nX
	Local cCpfTrab		:= ""
	Local cNomeTrab		:= ""
	Local dDtNasc		:= ""

	If !Empty(aCPFList)
		For nX := 1 To Len(aCPFList)
			cCpfTrab := aCPFList[nX][1]
			DbSelectArea("SRA")
			SRA->(DbSetOrder(20))
			If SRA->(DbSeek(cCpfTrab)) //RA_CIC+RA_FILIAL+RA_MAT                                                                                                                                         
				cNomeTrab	:= IIf(!Empty(SRA->RA_NOMECMP), SRA->RA_NOMECMP, SRA->RA_NOME)	
				dDtNasc		:= SRA->RA_NASC
			Else
				DbSelectArea("RD0")
				RD0->(DbGoTo(aCPFList[nX][2]))
				cNomeTrab	:= RD0->RD0_NOME	
				dDtNasc		:= RD0->RD0_DTNASC
			EndIf
			oItemData := JsonObject():new()
			oItemData["cpfTrab"]	:= cCpfTrab
			oItemData["nmTrab"]		:= AllTrim(cNomeTrab)
			oItemData["dtNascto"]	:= fDtToJson(dDtNasc)
			AAdd(aItemQry, oItemData )
		Next nX
	EndIf
	oCabecData["hasNext"]	:= .F.
	oCabecData["items"]		:= aItemQry
	oJsonData := oCabecData

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fgetRE0Cpf
Retorna CPFs de trabalhadores vinculados ao Processo Trabalhista
@author  martins.marcio
@since   21/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fgetRE0Cpf(cNrProcTrab)

	Local aCPFList	:= {}
	Local cQryAlias := GetNextAlias()
	Local cFilRE0	:= xFilial("RE0")
	Local cFilRD0	:= xFilial("RD0", cFilRE0)

	DEFAULT cNrProcTrab	:= ""

	If !Empty(cNrProcTrab)
		BeginSql alias cQryAlias
			SELECT DISTINCT RD0.RD0_CIC, RD0.R_E_C_N_O_ 
			FROM %table:RE0% RE0
			LEFT OUTER JOIN %table:RD0% RD0 ON RD0.RD0_CODIGO = RE0.RE0_RECLAM 
			WHERE	RE0.RE0_PROJUD = %exp:cNrProcTrab%  AND
					RE0.RE0_FILIAL = %exp:cFilRE0% AND
					RD0.RD0_FILIAL = %exp:cFilRD0% AND 
					RE0.%notDel% AND 
					RD0.%notDel%
			ORDER BY RD0.RD0_CIC
		EndSql

		While (cQryAlias)->(!Eof())
			aAdd(aCPFList, {(cQryAlias)->RD0_CIC, (cQryAlias)->R_E_C_N_O_})
			(cQryAlias)->(DbSkip())
		EndDo
		(cQryAlias)->(DbCloseArea())
	EndIf
	
Return aCPFList

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   21/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0006 // "Erro desconhecido no processo!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0006 // "Erro desconhecido no processo!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,EncodeUTF8(NoAcento(OemToAnsi(cMessage))),lJson,nStatus,EncodeUTF8(NoAcento(OemToAnsi(cDetailMsg))),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  martins.marcio
@since   21/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0006) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: " 
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0006) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: " 
	EndIf

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0006) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: " 
		EndIf	
	EndIf

	If ! Empty(cMessage)		
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetQryPar
Carrega os valores dos parâmetros de query
@author  martins.marcio
@since  21/11/2022
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
		EndCase
	Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  21/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0007
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0007
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDtToJson
Converte data para o formato utilizado no json
@author  martins.marcio
@since  21/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fDtToJson(cStrDate)
	Local cJsonDt	:= ""
	DEFAULT cStrDate := ""
	If ValType(cStrDate) == "D"
		cStrDate := DTOS(cStrDate)
	EndIf
	Do Case
		Case Len(cStrDate) == 8
			cJsonDt := SubStr(cStrDate,1,4) + "-" + SubStr(cStrDate,5,2) + "-" + SubStr(cStrDate,7,2)
	EndCase
Return cJsonDt
