#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APTA100APIB.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

/*
{Protheus.doc} laborProcessTaxes
API de Pagamentos do Processo trabalhista                             
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
*/

WSRESTFUL laborProcessTaxes DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para Pagamentos do Processo trabalhista" 
	WSDATA companyId	 	As String
	WSDATA branchId	     	As String
	WSDATA fields	     	As String Optional
	WSDATA page			 	As Integer Optional
	WSDATA pageSize		 	As Integer Optional
	WSDATA order	     	As Integer Optional
	WSDATA id				As String Optional
	WSDATA perApurPagto		As String Optional
	WSDATA cpfTrab			As String Optional

	WSMETHOD POST; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0002)); // "Inclui Pagamentos do Processo trabalhista" 
	WSSYNTAX "/api/rh/v1/laborProcessTaxes" ;
	PATH "/api/rh/v1/laborProcessTaxes" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v2"

	WSMETHOD GET ALL;
	DESCRIPTION oEmToAnsi(STR0015); // "Retorna uma lista resumida de pagamentos/tributos de um Processo trabalhista"
	WSSYNTAX "/api/rh/v1/laborProcessTaxes" ;
	PATH "/api/rh/v1/laborProcessTaxes" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET BYID;
	DESCRIPTION oEmToAnsi(STR0016); // "Retorna as informações detalhadas de pagamentos/tributos de um Processo trabalhista"
	WSSYNTAX "/api/rh/v1/laborProcessTaxes/{id}" ;
	PATH "/api/rh/v1/laborProcessTaxes/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD PUT; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0022)); // "Altera pagamentos/tributos do Processo Trabalhista"
	WSSYNTAX "/api/rh/v1/laborProcessTaxes/{id}" ;
	PATH "/api/rh/v1/laborProcessTaxes/{id}" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v2"

	WSMETHOD DELETE; 	
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0025)); // "Exclusão do Processo trabalhista"
	WSSYNTAX "/api/rh/v1/laborProcessTaxes/{id}" ;
	PATH "/api/rh/v1/laborProcessTaxes/{id}" ;
	PRODUCES 'application/json;charset=utf-8'; 
	TTALK "v2"

END WSRESTFUL

// Insere um Processo trabalhista
/*/{Protheus.doc} POST
 TODO Método responsável pela inclusão do Pagamento do Processo trabalhista
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
@return return, return_description
/*/

WSMETHOD POST QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxes 

	Local oJson    as OBJECT
	Local oBody    as OBJECT
	Local cBody    as Character
	Local cErroMsg as Character
	Local lRetorno as Logical
	Local cRetorno as Character

	Private cId        as Character
	Private cCompanyId as Character
	Private cBranchId  as Character
	Private cNrProcTra as Character
	Private cCpfTrab   as Character
	Private cPerApurPg as Character
	Private cCompetenc as Character
	Private oError
	Private bError      := {|e| oError := e, Break(e)}
	Private bErrorBlock := ErrorBlock( bError )
	Private aUrlParam   := ::aUrlParms

	BEGIN SEQUENCE

	oBody		:= JsonObject():New()
	cBody		:= Self:GetContent()
	lRetorno	:= .F.
	cErroMsg	:= oBody:FromJSON(DecodeUtf8(cBody))

	If len(Self:aQueryString) >= 2
		Self:aQueryString[2, 2] := alltrim(Self:aQueryString[2, 2])
	EndIf

	fSetQryPar(Self:aQueryString)
	// Valida os parâmetros recebidos na mensagem
	If ! fcheckInfor()
		lRet := .F.
		Return lRet
	EndIf

	//Valida dados da mensagem/contrato da API
	If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0  .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items']))
		fSendMess(400,STR0003,.T.,400,STR0004,,) //"Corpo da mensagem inválido ou inexistente. Verifique a Informação e envie novamente." ## "Erro na validação do recebimento da mensagem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
		return (lRetorno)
	Else
		oJson := oBody['items'][1]	
	EndIf

	RESET ENVIRONMENT
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RD0, E0E, E0F " MODULO "GPE"

		aEval({'RE0', 'RD0', 'E0E', 'E0F'},{|x|CHKFILE(x)})

		// GRAVA DADOS NAS TABELAS
		lRetorno := fGrvTab(3, oJson, @cErroMsg)

		If lRetorno 
			cId			:= cEmpAnt + ";" + cFilant + ";" + cNrProcTra + ";" + fDtToJson(cPerApurPg) //"companyId;branchId;nrProcTrab;perApurPgto"
			cRetorno	:=  fSendJson(oJson,cId)
			::SetResponse(cRetorno)
		Else
			aLog := {cErroMsg}
			fSendMess(400,STR0005,.T.,400,ArrTokStr(aLog),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf          

	RECOVER
		//ErrorBlock(bErrorBlock)
		//fSendMess(500,oError:Description,.T.,500,STR0007,,) //"Ocorreu uma falha no retorno da Informação."
		//fSendMess(500,"Falha crítica",.T.,500,STR0007,,) //"Ocorreu uma falha no retorno da Informação."		
		//lRetorno := .F.
	END SEQUENCE

Return (lRetorno)

// Retorna lista de pagamentos/tributos do processo trabalhista S-2501
/*/{Protheus.doc} GET ALL
Método responsável pelo retorno de todos os pagamentos do processo
@author  martins.marcio
@since   16/11/2022
@version 12.1.33
@return return, return_description
/*/
WSMETHOD GET ALL QUERYPARAM companyId, branchId, page, pageSize, order, nrProcTrab, perApurPagto, cpfTrab HEADERPARAM authorization WSSERVICE laborProcessTaxes

	Local cResponse As Character
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()

	Private cBranchId  as Character
	Private cCompanyId as Character
	Private cCpfTrab   as Character
	Private cNrProcTra as Character
	Private cOrder     as Character
	Private cPerApurPg as Character
	Private nNumePage := PAGE_DEFAULT
	Private nPageSize := PAGESIZE_DEFAULT

	BEGIN SEQUENCE

		fResetErrorHandler()
		
		fSetErrorHandler(oEmToAnsi(STR0017)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor() 
			lRet := .F.
			Return lRet
		EndIf

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RD0, E0E, E0F " MODULO "GPE"
		aEval({'RE0', 'RD0', 'E0E', 'E0F'},{|x|CHKFILE(x)})

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

// Retorna pagamentos/tributos do processo trabalhista S-2501
/*/{Protheus.doc} GET BY ID
Método responsável pelo retorno de tributos/pagamentos de um Processo Trabalhista específico
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
@return return, return_description
/*/
WSMETHOD GET BYID QUERYPARAM companyId, branchId, id HEADERPARAM authorization WSSERVICE laborProcessTaxes

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
	Private cPerApurPg	:= ""
	Private cCpfTrab	:= ""


	BEGIN SEQUENCE

		aParms := StrTokArr2(Self:aUrlParms[1],";",.T.)

		fResetErrorHandler()
		fSetErrorHandler(OemToAnsi(STR0018)) // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab;perApurPagto."
		If !Empty(Self:aUrlParms) .And. !Empty(aParms) .And. Len(aParms) >= 4
			cProcessId	:= aParms[3]
			cPerApurPg	:= aParms[4]
			cPerApurPg	:= fJToD(cPerApurPg,"C")
			aAdd(aInfoPar, {"COMPANYID", aParms[1]})
			aAdd(aInfoPar, {"BRANCHID", aParms[2]})
			aAdd(aInfoPar, {"NRPROCTRAB", aParms[3]})
			aAdd(aInfoPar, {"PERAPURPAGTO", aParms[4]})
		Else
			fSendMess(400,OemToAnsi(STR0005),.T.,400,OemToAnsi(STR0018),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf
		
		fSetErrorHandler(oEmToAnsi(STR0019)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"

		fSetQryPar(aInfoPar)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RD0, E0E, E0F " MODULO "GPE"
		aEval({'RE0', 'RD0', 'E0E', 'E0F'},{|x|CHKFILE(x)})

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

// Altera um pagamentos/tributos do Processo Trabalhista
/*/{Protheus.doc} PUT
Método responsável pela alteração de pagamentos/tributos do Processo Trabalhista
@author  martins.marcio
@since   23/11/2022
@version 12.1.33
@return return, return_description
/*/

WSMETHOD PUT QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxes 

	Local oJson    as OBJECT
	Local oBody    as OBJECT
	Local cBody    as Character
	Local cErroMsg as Character
	Local lRetorno as Logical
	Local cRetorno := ""

	Private aUrlParam := ::aUrlParms
	Private cId        as Character
	Private cCompanyId as Character
	Private cBranchId  as Character
	Private cNrProcTra as Character
	Private cPerApurPg as Character
	Private cCpfTrab   as Character
	Private oError
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )

	BEGIN SEQUENCE

		oBody		:= JsonObject():New()
		cBody		:= Self:GetContent()
		lRetorno	:= .F.
		cErroMsg	:= oBody:FromJSON(DecodeUTF8(cBody))
			
		//Valida dados da mensagem/contrato da API
		If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0 .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items'])) 
			fSendMess(400,STR0003,.T.,400,STR0004,,) //"Corpo da mensagem inválido ou inexistente. Verifique a informação e envie novamente." ## "Erro na validação do recebimento da mensagem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
			return (lRetorno)
		Else
			oJson := oBody['items'][1]
		EndIf

		If !Empty(Self:aUrlParms) .And. !Empty(Self:aUrlParms[1]) .And. Len(StrTokArr2(Self:aUrlParms[1],";",.T.)) >= 4
			cNrProcTra	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[3]
			cPerApurPg	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[4]
			cPerApurPg	:= fJToD(cPerApurPg,"C")
		Else
			fSendMess(400,OemToAnsi(STR0005),.T.,400,OemToAnsi(STR0018),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

		fSetErrorHandler(oEmToAnsi(STR0019)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"
		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		cId := cCompanyId + ";" + cBranchId + ";" + cNrProcTra + ";" + fDtToJson(cPerApurPg) //"companyId;branchId;nrProcTrab;perApurPagto"

		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA cCompanyId FILIAL cBranchId TABLES "RE0, RD0, E0E, E0F " MODULO "GPE"

			aEval({'RE0', 'RD0', 'E0E', 'E0F'},{|x|CHKFILE(x)})

			// GRAVA DADOS NAS TABELAS
			lRetorno := fGrvTab(4, oJson, @cErroMsg)

			If lRetorno 
				cRetorno :=  fSendJson(oBody,cId)
				::SetResponse(cRetorno)
			Else
				aLog := {cErroMsg}
				fSendMess(400,STR0005,.T.,400,ArrTokStr(aLog),,) // "Não foi possível concluir esta operação. Verifique!" 
			EndIf          

		//RECOVER
			//ErrorBlock(bErrorBlock)
			//fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."
			//fSendMess(500,"Falha crítica",.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."		
			//lRetorno := .F.
	END SEQUENCE

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvTab
Atualiza tabelas com base no json recebido no body da mensagem
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvTab(nOpc, oJson, cErroMsg)
	Local aCalcTrib  := {}
	Local aIdeTrab   := {}
	Local aInfCRCntr := {}
	Local aInfCRIRRF := {}
	Local aInfoE0E   := {}
	Local aInfoE0F   := {}
	Local cChvRE0    := ""
	Local lAchouCPF  := .F.
	Local lRet       := .T.
	Local nI         := 0
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0

	DEFAULT nOpc     := 3
	DEFAULT oJson    := ""
	DEFAULT cErroMsg := ""

	Private cMsgErrGrv := ""
	Private cNrInsc    := ""
	Private nTpInsc    := 0

	Begin Transaction

		If ValType(oJson) == "J" 		
			
			cNrProcTra	:= oJson['ideProc']['nrProcTrab']
			cPerApurPg	:= fJToD(oJson['ideProc']['perApurPgto'],"C")
			If Empty(cPerApurPg)
				cErroMsg := OemToAnsi(STR0008) //"Período de apuração(perApurPgto) inválido, verifique."
				Return .F.
			EndIf		

			// Verifica a existência do processo
			cChvRE0	:= xFilial("RE0") + PADR(cNrProcTra, GetSx3Cache( "RE0_PROJUD", "X3_TAMANHO" ))
			DbSelectArea("RE0")
			RE0->(DbSetOrder(8)) //RE0_FILIAL+RE0_PROJUD
			If !RE0->( DbSeek(cChvRE0) )
				cErroMsg := OemToAnsi(STR0010) + cNrProcTra + OemToAnsi(STR0011) // "O processo (" ## ") não existe na tabela RE0, verifique!"
				Return .F.
			Else
				
				aIdeTrab := oJson['ideTrab']
				If !Empty(aIdeTrab)
					For nI := 1 To Len(aIdeTrab)
						
						cCpfTrab := aIdeTrab[nI]['cpfTrab']
						
						//Verifica se o cpfTrab corresponde com o CPF do reclamante na tabela RD0
						While RE0->( !Eof() .And. RE0_FILIAL+RE0_PROJUD == cChvRE0) .And. !lAchouCPF
							If AllTrim(Posicione("RD0", 1, xFilial("RD0") + RE0->RE0_RECLAM, "RD0_CIC")) == cCpfTrab
								lAchouCPF := .T.
								EXIT
							EndIf
							RE0->(DBSkip())
						EndDo
						If !lAchouCPF
							cErroMsg := OemToAnsi(STR0012) + cCpfTrab + OemToAnsi(STR0013) // "O CPF do trabalhador(cpfTrab) ### não corresponde com o CPF do reclamante do processo."
							Return .F.
						EndIf 

						//Grava um registro específico na E0E para guardar a observação da tag ideProc/obs
						cProcObs := oJson['ideProc']['obs']
						If !Empty(cProcObs)
							fGrvObsPer(cProcObs)
						EndIf

						aCalcTrib := aIdeTrab[nI]['calcTrib']
						If !Empty(aCalcTrib)
							For nX := 1 To Len(aCalcTrib)
								cCompetenc := fJToD(aCalcTrib[nX]['perRef'],"C")
								If Empty(cCompetenc)
									cErroMsg := OemToAnsi(STR0009) //"Período de competência(perRef) inválido, verifique."
									Return .F.
								EndIf
								
								//E0E - Trib. Processo por Período	
								aInfoE0E := {}
								aAdd(aInfoE0E,{ "05", "E0E_PERAP",	 	cPerApurPg	})
								aAdd(aInfoE0E,{ "04", "E0E_COMPET",		cCompetenc })
								aAdd(aInfoE0E,{ "06", "E0E_BSINSS",		aCalcTrib[nX]['vrBcCpMensal'] })
								aAdd(aInfoE0E,{ "07", "E0E_BS13",		aCalcTrib[nX]['vrBcCp13'] })
								aAdd(aInfoE0E,{ "08", "E0E_RDIRRF",		aCalcTrib[nX]['vrRendIRRF'] })
								aAdd(aInfoE0E,{ "09", "E0E_RDIR13",		aCalcTrib[nX]['vrRendIRRF13'] })
								If !Empty(aInfoE0E) 
									lRet := fGrvE0E(aInfoE0E, cCompetenc, cPerApurPg)
								EndIf

								//E0F - Contribuição Patronal
								aInfCRCntr := aCalcTrib[nX]['infoCRContrib']
								If !Empty(aInfCRCntr)
									For nY := 1 To Len(aInfCRCntr)
										aInfoE0F := {}
										aAdd(aInfoE0F,{ "05", "E0F_PERAP",		cPerApurPg })
										aAdd(aInfoE0F,{ "04", "E0F_COMPET",		cCompetenc })
										aAdd(aInfoE0F,{ "08", "E0F_TIPO",		"2" }) //1=IRRF;2=Contribuição Patronal
										aAdd(aInfoE0F,{ "06", "E0F_TPCR",		cValToChar(aInfCRCntr[nY]['tpCR']) })
										aAdd(aInfoE0F,{ "09", "E0F_VRCR",		aInfCRCntr[nY]['vrCR'] })									
										lRet := fGrvE0F(aInfoE0F, cCompetenc, cPerApurPg)
									Next nY
								EndIf
							Next nX
						EndIf

						//E0F - IRRF
						aInfCRIRRF := aIdeTrab[nI]['infoCRIRRF']
						If !Empty(aInfCRIRRF)
							cCompetenc	:= "999999"
							For nZ := 1 To Len(aInfCRIRRF)
								aInfoE0F := {}
								aAdd(aInfoE0F,{ "05", "E0F_PERAP",		cPerApurPg })
								aAdd(aInfoE0F,{ "04", "E0F_COMPET",		cCompetenc}) 
								aAdd(aInfoE0F,{ "08", "E0F_TIPO",		"1" }) //1=IRRF;2=Contribuição Patronal
								aAdd(aInfoE0F,{ "06", "E0F_TPCR",		cValToChar(aInfCRIRRF[nZ]['tpCR']) })
								aAdd(aInfoE0F,{ "09", "E0F_VRCR",		aInfCRIRRF[nZ]['vrCR'] })	
								lRet := fGrvE0F(aInfoE0F, cCompetenc, cPerApurPg)
							Next nZ
						EndIf

					Next nI
				EndIf

			EndIf

		EndIf

	End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetAll
Retorna json com a lista de Pagamentos do Processo trabalhista
@author  martins.marcio
@since   16/11/2022
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
	cQuery += "			SELECT  DISTINCT E0E.E0E_PERAP PERAPURPAGTO,"
	cQuery += "					RE0.RE0_PROJUD NRPROCTRAB"	

	cQuery += "			FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "			LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "			LEFT JOIN "+ RetSqlName("E0E") + " E0E ON E0E.E0E_PRONUM = RE0.RE0_NUM AND E0E.E0E_RECLAM = RE0.RE0_RECLAM"
	cQuery += "			WHERE RE0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RE0.RE0_FILIAL = '" + xFilial("RE0") + "'"
	cQuery += "			AND   RD0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RD0.RD0_FILIAL = '" + xFilial("RD0", xFilial("RE0")) + "'"
	cQuery += "			AND   E0E.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   E0E.E0E_FILIAL = '" + xFilial("E0E", xFilial("RE0")) + "'"
	If !Empty(cNrProcTra)
		cQuery += "			AND   RE0.RE0_PROJUD = '" + cNrProcTra + "'"
	EndIf
	If !Empty(cCpfTrab)
		cQuery += "			AND   RD0.RD0_CIC = '" + cCpfTrab + "'"
	EndIf
	If !Empty(cPerApurPg)
		cQuery += "			AND   E0E.E0E_PERAP = '" + cPerApurPg + "'"
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
			cIdTab		+= fDtToJson((cQrAlias)->PERAPURPAGTO)

			oItemData["nrProcTrab"]			:= (cQrAlias)->NRPROCTRAB
			oItemData["perApurPgto"]		:= fDtToJson((cQrAlias)->PERAPURPAGTO)
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
/*/{Protheus.doc} function fGetById
Retorna informações detalhadas de pagamento/tributos de um processo trabalhista
@author  martins.marcio
@since   16/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetById(oJsonData)

	Local aCalcTrib  := {}
	Local aIdeTrab   := {}
	Local aInfCRIRRF := {}
	Local aItemQry   := {}
	Local aTrabList  := {}
	Local cChaveE0F  := ""
	Local cIdTab     := ""
	Local cQrAlias   := GetNextAlias()
	Local cQuery     := ""
	Local lRet       := .T.
	Local nX         := 0
	Local oCabecData := JsonObject():New()
	Local oIdeProc
	Local oIdeTrab
	Local oItemData

	fSetErrorHandler(oEmToAnsi(STR0020)) // "Não foi possível realizar a query SQL."

	cQuery += "SELECT DISTINCT RD0.RD0_CIC CPFTRAB,"	
	cQuery += "	RE0.R_E_C_N_O_ RECNO"		

	cQuery += "		FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "		LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "		LEFT JOIN "+ RetSqlName("E0E") + " E0E ON E0E.E0E_PRONUM = RE0.RE0_NUM AND E0E.E0E_RECLAM = RE0.RE0_RECLAM"
	
	cQuery += "		WHERE RE0.D_E_L_E_T_ = ' '	"
	cQuery += "		AND   RE0.RE0_FILIAL = '" + xFilial("RE0") + "'"
	cQuery += "		AND   RE0.RE0_PROJUD = '" + cProcessId + "'"
	cQuery += "		AND   E0E.E0E_PERAP	 = '" + cPerApurPg + "'"
	cQuery += "		AND   RD0.RD0_FILIAL = '" + xFilial("RD0", xFilial("RE0")) + "'"
	cQuery += "		AND   E0E.E0E_FILIAL = '" + xFilial("E0E", xFilial("RE0")) + "'"
	cQuery += "		AND   RD0.D_E_L_E_T_ = ' '	"
	cQuery += "		AND   E0E.D_E_L_E_T_ = ' '	"

	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cQrAlias, .T., .T. )

	(cQrAlias)->(DBGoTop())
	
	While (cQrAlias)->(!Eof())
		aAdd(aTrabList, {(cQrAlias)->CPFTRAB, (cQrAlias)->RECNO} )
		(cQrAlias)->(DBSkip())
	EndDo
	(cQrAlias)->(DbCloseArea())

	fResetErrorHandler()
	fSetErrorHandler(oEmToAnsi(STR0021)) // "Erro ao montar o objeto json para retorno." 

	oItemData := JsonObject():new()
	oItemData['excluidoERP'] := "N"
	oItemData['companyId'] := cEmpAnt
	oItemData['branchId'] := cFilAnt
		oIdeProc := JsonObject():new()
		oIdeProc['nrProcTrab']	:= cProcessId
		oIdeProc['perApurPgto']	:= fDtToJson(cPerApurPg)
	oItemData['ideProc'] := oIdeProc

	If !Empty(aTrabList)
		DbSelectArea("RE0")
		For nX :=1 To Len(aTrabList)
			oIdeTrab := JsonObject():new()
			oIdeTrab['cpfTrab'] := aTrabList[nX][1]
			
			RE0->(DbGoTo(aTrabList[nX][2]))

			aCalcTrib := fGetCTrib()
			oIdeTrab['calcTrib'] := aCalcTrib
			cChaveE0F 	:= xFilial("E0F",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + "999999"
			cChaveE0F += "1" //1=IRRF;2=Contribuição Patronal
			aInfCRIRRF	:= fGetE0F(cChaveE0F)
			oIdeTrab['infoCRIRRF'] := aInfCRIRRF 

			aAdd(aIdeTrab, oIdeTrab)
		Next nX
		oIdeProc['obs']	:= fGetObsE0E()
	EndIf
	oItemData['ideTrab'] := aIdeTrab

	cIdTab		:= cEmpAnt		+ ";"
	cIdTab		+= cFilAnt		+ ";"
	cIdTab		+= cProcessId	+ ";"
	cIdTab		+= fDtToJson(cPerApurPg)
	oItemData["id"] := cIdTab 
	AAdd(aItemQry, oItemData )

	oCabecData["hasNext"] 		  := .F.

	oCabecData["items"] := aItemQry
	oJsonData := oCabecData

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetCTrib
Retorna array calcTrib
@author  martins.marcio
@since  16/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetCTrib()
	Local aCalcTrib  := {}
	Local aInfCRCntr := {}
	Local cChaveE0E  := ""
	Local cChaveE0F  := ""
	Local oCalcTrib

	DbSelectArea("E0E")
	E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET			
	cChaveE0E := xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM  + RE0->RE0_RECLAM + cPerApurPg
	If E0E->(DbSeek(cChaveE0E))
		While E0E->(!Eof() .And. E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E->E0E_PERAP == cChaveE0E)  
			oCalcTrib := JsonObject():new()
			oCalcTrib['perRef']			:= fDtToJson(E0E->E0E_COMPET)
			oCalcTrib['vrBcCpMensal']	:= E0E->E0E_BSINSS
			oCalcTrib['vrBcCp13']		:= E0E->E0E_BS13
			oCalcTrib['vrRendIRRF']		:= E0E->E0E_RDIRRF
			oCalcTrib['vrRendIRRF13']	:= E0E->E0E_RDIR13

			cChaveE0F	:= cChaveE0E + E0E->E0E_COMPET
			cChaveE0F	+= "2" //1=IRRF;2=Contribuição Patronal
			aInfCRCntr	:= fGetE0F(cChaveE0F) 		
			oCalcTrib['infoCRContrib']	:= aInfCRCntr
			aAdd(aCalcTrib, oCalcTrib)
			E0E->(DBSkip())
		EndDO
	EndIf

Return aCalcTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0F
Retorna array de objetos da tabela E0F
@author  martins.marcio
@since  17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetE0F(cChaveE0F)
	Local aRet	:= {}
	Local oItem
	
	DEFAULT cChaveE0F	:= "" 

	DbSelectArea("E0F")	                                                                                                
	E0F->(DbSetOrder(1)) // E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_IDTRIB
	If E0F->( DbSeek(cChaveE0F) )
		While E0F->(!Eof() .And. E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO == cChaveE0F)
			oItem := JsonObject():new()
			oItem['tpCR'] := E0F->E0F_TPCR
			oItem['vrCR'] := E0F->E0F_VRCR
			aAdd(aRet, oItem)
			E0F->(DBSkip())
		EndDo
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetObsE0E
Retorna observação da tabela E0E
@author  martins.marcio
@since  17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetObsE0E(cChaveE0E)
	Local cRet	:= ""
	Local cReclam	:= "OBSERV"
	Local cCompet	:= "OBSERV"
	
	DEFAULT cChaveE0E	:= xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM  + cReclam + cPerApurPg + cCompet

	DbSelectArea("E0E")	                                                                                                
	E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
	If E0E->( DbSeek(cChaveE0E) )
		cRet := EncodeUtf8(MSMM(E0E->E0E_CMEM,,,,3,,,"E0E",,"RDY"))
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fOrdQry
Retorna a ordenação a ser utilizada na query
@author  martins.marcio
@since  16/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fOrdQry(cApiOrder)
	Local cQryRet	:= " "
	Local aQryOrd	:= {}
	Local nI		:= 0
	Local cCpoOrd	:= ""

	DEFAULT cApiOrder := ""

	If !Empty(cApiOrder)
		aQryOrd := StrTokArr( cApiOrder , ',' )
		For nI := 1 To Len(aQryOrd)
			cCpoOrd := AllTrim(Upper(strTran(aQryOrd[nI], "-", "")))
			
			If cCpoOrd $ "NRPROCTRAB|PERAPURPAGTO"
				cQryRet += cCpoOrd
				cQryRet += IIf(LEFT(AllTrim(aQryOrd[nI]),1) == "-", " DESC,", ",")
			EndIf
		Next nI
	EndIf

	If Empty(cQryRet)
		cQryRet := " ORDER BY NRPROCTRAB, PERAPURPAGTO "
	Else
		cQryRet := Left(cQryRet,(Len(cQryRet)-1))  // Retira a virgula do final da string
		cQryRet := " ORDER BY " + cQryRet
	EndIf

Return cQryRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvObsPer
Grava observação na tabela E0E
@author  martins.marcio
@since   17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvObsPer(cProcObs)
	Local lRet      := .T.
	Local cChaveE0E := ""
	Local cReclam	:= "OBSERV"
	Local cCompet	:= "OBSERV"
	Local aArea := GetArea()

	DEFAULT cProcObs := ""

	DbSelectArea("E0E")
	E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
	cChaveE0E := xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM + cReclam + cPerApurPg + cCompet 
	If !E0E->( DbSeek(cChaveE0E ) )
		RecLock("E0E", .T.)	
		E0E_FILIAL	:= xFilial("E0E",RE0->RE0_FILIAL)	
		E0E_PRONUM	:= RE0->RE0_NUM						
		E0E_RECLAM	:= cReclam							
		E0E_PERAP	:= cPerApurPg							
		E0E_COMPET	:= cCompet
	else
		RecLock("E0E", .F.)	
	EndIf
	MsMm(E0E->E0E_CMEM, /*nTam*/, /*nLin*/, cProcObs, 1		, /*nTabSize*/, /*lWrap*/, "E0E" , "E0E_CMEM", "RDY")
	E0E->(MsUnlock())
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0E
Grava dados na tabela E0E
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0E(aInfoE0E, cCompetenc, cPerApurPg)
	Local lRet      := .T.
	Local nI        := 0
	Local cChaveE0E := ""
	Local aArea := GetArea()

	DEFAULT aInfoE0E	:= {}
	DEFAULT cCompetenc	:= Space(6)
	DEFAULT cPerApurPg	:= Space(6)

	DbSelectArea("E0E")
	E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
	cChaveE0E := xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + cCompetenc 
	If !E0E->( DbSeek(cChaveE0E ) )
		RecLock("E0E", .T.)	
		E0E_FILIAL	:= xFilial("E0E",RE0->RE0_FILIAL)	//01
		E0E_PRONUM	:= RE0->RE0_NUM						//02
		E0E_RECLAM	:= RE0->RE0_RECLAM					//03
	else
		RecLock("E0E", .F.)	
	EndIf

	For nI := 1 To Len(aInfoE0E)
		If aInfoE0E[nI][2] == "E0E_MEM" // Campo memo
			MsMm(fgetCdMemo(aInfoE0E[nI][2])[2], /*nTam*/, /*nLin*/, aInfoE0E[nI][3], 1, /*nTabSize*/, /*lWrap*/, "E0E", fgetCdMemo(aInfoE0E[nI][2])[1], "RDY")
			RecLock("E0E", .F.) // Garante o lock após o MSMM	
		Else
			&(aInfoE0E[nI][2]) := aInfoE0E[nI][3]
		EndIf
	Next nI
	E0E->(MsUnlock())
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0F
Grava dados na tabela E0F
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0F(aInfoE0F, cCompetenc, cPerApurPg)
	Local lRet      := .T.
	Local nI        := 0
	Local cChaveE0F := ""

	DEFAULT aInfoE0F	:= {}
	DEFAULT cCompetenc	:= Space(6)
	DEFAULT cPerApurPg	:= Space(6)

	DbSelectArea("E0F")
	E0F->(DbSetOrder(1)) // E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_IDTRIB
	cChaveE0F := xFilial("E0F",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + cCompetenc
	If !E0F->( DbSeek(cChaveE0F ) )
		RecLock("E0F", .T.)	
		E0F_FILIAL	:= xFilial("E0F",RE0->RE0_FILIAL)	//01
		E0F_PRONUM	:= RE0->RE0_NUM						//02
		E0F_RECLAM	:= RE0->RE0_RECLAM					//03
		E0F_IDTRIB	:= GetSX8Num("E0F","E0F_IDTRIB")	//07
	else
		RecLock("E0F", .F.)	
	EndIf

	For nI := 1 To Len(aInfoE0F)
		&(aInfoE0F[nI][2]) := aInfoE0F[nI][3]
	Next nI
	E0F->(MsUnlock())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet        := sToD("")
	
	DEFAULT cDateJson := ""
	DEFAULT cDtType   := "D"

	dRet := IIf(cDtType =="D", sToD( StrTran( cDateJson, "-", "" ) ), StrTran( cDateJson, "-", "" ))

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   10/11/2022
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

	SetRestFault(nCode,EncodeUTF8(OemToAnsi(cMessage)),lJson,nStatus,EncodeUTF8(OemToAnsi(cDetailMsg)),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since  10/11/2022
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
@since   10/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0014) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0014) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	EndIf

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0014) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: "
		EndIf	
	EndIf

	If ! Empty(cMessage)		
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf

	/* Persiste parâmetros específicos do GET ALL */
	If IsInCallStack("GET_ALL")
		//  Se nPageSize vazio, maior que PAGESIZE_DEFAULT ou negativo assume o DEFAULT
		If ( Empty(nPageSize)) .OR. ( nPageSize > PAGESIZE_DEFAULT ) .OR. ( nPageSize < 1 )
			nPageSize := PAGESIZE_DEFAULT
		EndIf
		// Se nPage vazio ou negativo assume o DEFAULT
		If ( Empty(nNumePage)) .OR. ( nNumePage < 1 )
			nNumePage := PAGE_DEFAULT
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetQryPar
Carrega os valores dos parâmetros de query
@author  martins.marcio
@since  10/11/2022
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
				cNrProcTra := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "CPFTRAB"
				cCpfTrab := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PERAPURPAGTO"
				cPerApurPg := fJToD(aQueryString[nX][2], "C")
			Case UPPER(AllTrim(aQueryString[nX][1])) == "ORDER"
				cOrder := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGE"
				nNumePage := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGESIZE"
				nPageSize := aQueryString[nX][2]
			// Case UPPER(AllTrim(aQueryString[nX][1])) == "FIELDS"
			// 	cFields := aQueryString[nX][2]
		EndCase
	Next nX

Return .T.

/*/{Protheus.doc} getCodMemo
Retorna o campo codigo do campo Memo
@since	10/11/2022
@autor	martins.marcio
@version P12
/*/
Static Function fgetCdMemo(cNomeMemo)
	Local aCodMemo    := {"", ""}
	Default cNomeMemo := ""
	
	If AllTrim(cNomeMemo) == "E0E_MEM"
		aCodMemo := {"E0E_CMEM", E0E->E0E_CMEM }
	EndIf

Return aCodMemo

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  10/11/2022
@version 12.1.23
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
@since  17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fDtToJson(cStrDate)
	Local cJsonDt	:= ""
	DEFAULT cStrDate := ""
	// If ValType(cStrDate) == "D"
	// 	cStrDate := DTOS(cStrDate)
	// EndIf
	Do Case
		Case Len(cStrDate) == 6
			cJsonDt := SubStr(cStrDate,1,4) + "-" + SubStr(cStrDate,5,2)
		// Case Len(cStrDate) == 8
		// 	cJsonDt := SubStr(cStrDate,1,4) + "-" + SubStr(cStrDate,5,2) + "-" + SubStr(cStrDate,7,2)
	EndCase
Return cJsonDt

//-------------------------------------------------------------------
// Exclusão do Processo trabalhista
/*/{Protheus.doc} DELETE
Método responsável pela exclusão de um Processo trabalhista
@author  lidio.oliveira
@since   28/12/2022
@version 12.1.33
@return return, return_description
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxes 
	Local aLog := {}
	Local lRetorno := .F.

	aAdd(aLog, OemToAnsi(STR0023)) //"Para excluir utilize a rotina Geração de Eventos Trabalhistas do módulo SIGAGPE (GPEM038)"
	fSendMess(403, OemToAnsi(STR0024), .T., 403, ArrTokStr(aLog),,) //"A exclusão não é permitida por esta rotina."

Return (lRetorno)
