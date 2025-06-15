#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE HASH_BASE_RECIBO_TRANSMISSAO			01
#DEFINE HASH_BASE_ESTABELECIMENTO				02
#DEFINE HASH_BASE_CPF							03
#DEFINE HASH_BASE_NOME							04
#DEFINE HASH_BASE_MATRICULA						05
#DEFINE HASH_BASE_CATEGORIA						06
#DEFINE HASH_BASE_LOTACAO						07
#DEFINE HASH_BASE_EVENTO_ESOCIAL				08
#DEFINE HASH_BASE_FOLHA_BASE_FGTS				09
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO	10
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO	11
#DEFINE HASH_BASE_TAF_BASE_FGTS					12
#DEFINE HASH_BASE_TAF_BASE_FGTS_13_SALARIO		13
#DEFINE HASH_BASE_TAF_BASE_FGTS_RESCISORIO		14
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS				15
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO	16
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO	17
#DEFINE HASH_BASE_GOVERNO_LOCALIZADO			18

#DEFINE HASH_DEPOSITO_RECIBO_TRANSMISSAO				01
#DEFINE HASH_DEPOSITO_CPF								02
#DEFINE HASH_DEPOSITO_NOME								03
#DEFINE HASH_DEPOSITO_MATRICULA							04
#DEFINE HASH_DEPOSITO_CATEGORIA							05
#DEFINE HASH_DEPOSITO_EVENTO_ESOCIAL					06
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS				07
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO	08
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO	09
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS					10
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO		11
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO		12
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS				13
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO	14
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO	15
#DEFINE HASH_DEPOSITO_GOVERNO_LOCALIZADO				16

#DEFINE RECIBO_TRANSMISSAO								01
#DEFINE ESTABELECIMENTO									02
#DEFINE CPFFUNC											03
#DEFINE NOMEFUNC										04
#DEFINE MATRIC											05
#DEFINE CATEG											06
#DEFINE LOTAC											07
#DEFINE EVENTO_ESOCIAL									08
#DEFINE TIPO_BASE_CALCULO								09
#DEFINE FOLHA_BASE_INSS									10
#DEFINE FOLHA_VALOR_INSS								11
#DEFINE FOLHA_VALOR_SALARIO_FAMILIA						12
#DEFINE FOLHA_VALOR_SALARIO_MATERNIDADE					13
#DEFINE FOLHA_BASE_INSS_13_SALARIO						14
#DEFINE FOLHA_VALOR_INSS_13_SALARIO						15
#DEFINE FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO		16
#DEFINE TAF_BASE_INSS									17
#DEFINE TAF_VALOR_INSS									18
#DEFINE TAF_VALOR_SALARIO_FAMILIA						19
#DEFINE TAF_VALOR_SALARIO_MATERNIDADE					20
#DEFINE TAF_BASE_INSS_13_SALARIO						21
#DEFINE TAF_VALOR_INSS_13_SALARIO						22
#DEFINE TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO		23
#DEFINE GOVERNO_BASE_INSS								24
#DEFINE GOVERNO_VALOR_INSS								25
#DEFINE GOVERNO_VALOR_SALARIO_FAMILIA					26
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE				27
#DEFINE GOVERNO_BASE_INSS_13_SALARIO					28
#DEFINE GOVERNO_VALOR_INSS_13_SALARIO					29
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO	30
#DEFINE OBSERVACAO										31
#DEFINE TIPO_FUNCIONARIO								32
#DEFINE GOVERNO_LOCALIZADO								33
#DEFINE GOVERNO_GROSS_VALUE								34
#DEFINE GOVERNO_DESC_GROSS_VALUE						35
#DEFINE GOVERNO_13_GROSS_VALUE							36
#DEFINE GOVERNO_13_DESC_GROSS_VALUE						37
#DEFINE CAT_DESCRI										38
#DEFINE GOVERNO_BASE_SUSPENSAO                          39
#DEFINE GOVERNO_BASE_TOTAL_INSS                         40

//---------------------------------------------------------------------
/*/{Protheus.doc} reportEsocialBaseConfer
@type			method
@description	Serviço dos Relatórios de Conferência do eSocial.
@author			Robson Santos
@since			15/08/2019
/*/
//---------------------------------------------------------------------
WSRESTFUL reportEsocialBaseConfer DESCRIPTION "Serviço dos Relatórios de Conferência do eSocial" FORMAT APPLICATION_JSON

	WSDATA companyId			AS STRING
	WSDATA requestId			AS STRING
	WSDATA paymentPeriod		AS STRING
	WSDATA registrationNumber	AS STRING OPTIONAL
	WSDATA lotationCode			AS STRING OPTIONAL
	WSDATA eSocialCategory		AS STRING OPTIONAL
	WSDATA cpfNumber			AS STRING OPTIONAL
	WSDATA eSocialRegistration	AS STRING OPTIONAL
	WSDATA tribute				AS INTEGER
	WSDATA page					AS INTEGER OPTIONAL
	WSDATA pageSize				AS INTEGER OPTIONAL
	WSDATA synthetic			AS BOOLEAN OPTIONAL
	WSDATA differencesOnly		AS BOOLEAN OPTIONAL

	WSMETHOD POST;
		DESCRIPTION "Método para iniciar o processamento do relatório de conferência do eSocial";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/?{companyId}&{registrationNumber}&{lotationCode}&{eSocialCategory}&{cpfNumber}&{eSocialRegistration}&{paymentPeriod}&{tribute}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET Status;
		DESCRIPTION "Método para consultar o percentual de execução do relatório";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/Status/?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/Status/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET InssValues;
		DESCRIPTION "Método para consultar resultado do relatório de conferência de INSS";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/InssValues/?{companyId}&{requestId}&{synthetic}&{differencesOnly}&{cpfNumber}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/InssValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET FgtsValues;
		DESCRIPTION "Método para consultar resultado do relatório de conferência de FGTS";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/FgtsValues/?{companyId}&{requestId}&{synthetic}&{differencesOnly}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/FgtsValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET InssRetValues;
		DESCRIPTION "Método para consultar os valores sintéticos do Relatório de conferência de INSS";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/InssRetValues/?{companyId}&{requestId}&{differencesOnly}&{synthetic}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/InssRetValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET LegacyStatus;
		DESCRIPTION "Método para consultar o Status da API de valores das linhas";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/LegacyStatus/?{companyId}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/LegacyStatus/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método responsável por recepcionar os parâmetros e iniciar o processamento do relatório..
@author			Robson Santos
@since			15/08/2019
@return			Id. da resuisição: requestId (string)

- Inscrição Estabelecimento - registrationNumber (string)
- Código Lotação - lotationCode (string)
- Categoria eSocial - eSocialCategory (string)
- CPF - cpfNumber (string)
- Matrícula eSocial - eSocialRegistration (string)
- Período Folha (obrigatorio) - paymentPeriod (string)
- MMAAAA - mensal
- AAAA - anual

/*/
//---------------------------------------------------------------------
WSMETHOD POST WSRESTFUL reportEsocialBaseConfer

Local oRequest		:=	JsonObject():New()
Local oResponse		:=	Nil
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local cRequestID	:=	""
Local aCompany		:=	{}
Local lRet			:=	.T.

If Empty( self:GetContent() )
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )
Else
	oRequest:FromJson( self:GetContent() )

	If Empty( oRequest["companyId"] )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf Empty( oRequest["paymentPeriod"] )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'paymentPeriod'." ) )
	ElseIf Empty( oRequest["tribute"] )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Tributo não informado no parâmetro 'tribute'." ) )
	Else
		aCompany := StrTokArr( oRequest["companyId"], "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				cRequestID := GeraTicket( oRequest, self:GetContent() )

				If Empty( cRequestID )
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "Não foi possível gerar o ticket de processamento no Protheus." ) )
				Else
					//Inicia o processamento do relatório, antes de devolver o ticket da requisição
					StartJob( "TAFPRCCONF", GetEnvServer(), .F., cEmpRequest, cFilRequest, cRequestID )

					oResponse := JsonObject():New()
					oResponse["requestId"] := cRequestID

					//Envia o ticket da requisição para o frontend
					self:SetResponse( oResponse:ToJson() )					
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf
EndIf

FreeObj( oRequest )
FreeObj( oResponse )

DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraTicket
@type			function
@description	Cria e armazena o ticket para a requisição.
@author			Robson Santos
@since			05/09/2019
@param			oRequest	-	Objeto da requisição
@param			cBody		-	Corpo da requisição com os parâmetros desejados
/*/
//---------------------------------------------------------------------
Static Function GeraTicket(oRequest, cBody)

	Local oModelV3J	:= FWLoadModel( "TAFA531" )
	Local cTicket	:= FWuuId( "WSTAF010" )
	Local cServ		:= ""

	If oRequest["tribute"] == "1"
		cServ := "reportEsocialBaseConfer/InssRetValues"
		APILogAccess("ReportEsocialBaseConfer", "INSS")
	ElseIf oRequest["tribute"] == "2"
		cServ := "reportEsocialBaseConfer/FgtsValues"
		APILogAccess("ReportEsocialBaseConfer", "FGTS")
	EndIf

	oModelV3J:SetOperation( MODEL_OPERATION_INSERT )
	oModelV3J:Activate()

	oModelV3J:LoadValue( "MODEL_V3J", "V3J_ID"		, cTicket )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_SERVIC"	, cServ )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_METODO"	, "POST" )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTREQ"	, Date() )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRREQ"	, StrTran( Time(), ":", "" ) )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS"	, "1" )
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_PARAMS"	, cBody )

	FWFormCommit( oModelV3J )

	oModelV3J:DeActivate()
	oModelV3J:Destroy()

Return cTicket

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPRCCONF
Processa a parte assincrona da requisição.

@author Robson Santos
@since 15/08/2019
/*/
//-------------------------------------------------------------------
Function TAFPRCCONF(cEmpRequest, cFilRequest, cTicket)

	Local aHeader	:= {}
	Local cTribute	:= ""
	Local cFilRH	:= ""
	Local lIsLegacy	:= .F.
	Local lRet		:= .F.
	Local oRequest	:= Nil

	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest,,, "TAF", "WSTAF010" )

	oRequest := JsonObject():New()

	V3J->(DbSetOrder(1))

	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )
		oRequest:FromJson( V3J->V3J_PARAMS )

		lIsLegacy := TAFAlsInDic( "V5H" ) .And. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

		//Antes de fazer o processamento dos dados, refaz os valores de RH da V3N com base no retorno da API
		If lIsLegacy
			aHeader		:=	Iif( !Empty( AllTrim( GetNewPar( "MV_TAFRHLG", "" ) ) ), GetHeader(), {} )
			cFilRH		:=	GetFilRH( aHeader )
			cTribute	:=	Iif( "inssretvalues" $ Lower( V3J->V3J_SERVICE ), "1", "2" )

			TAFConOut( ProcName() + "RM SOLICITANDO INFO DE BASE" )
			TAFConOut( ProcName() + oRequest:ToJson() )

			GetRHValues( oRequest, oRequest["paymentPeriod"], cTribute, .T., V3J->V3J_ID, cFilRH, aHeader )
		EndIf

		If AllTrim( oRequest["tribute"] ) == "1"
			GetINSSVal( oRequest, cTicket, lIsLegacy )
		ElseIf AllTrim( oRequest["tribute"] ) == "2"
			GetFGTSData( oRequest, cTicket, lIsLegacy )
		EndIf

		lRet := .T.
	EndIf

	oRequest := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFGTSData
Escopo: FGTS
Prepara os dados filtrados no formato JSON para retornar ao front.

@author Robson Santos
@since 26/08/2019
/*/
//-------------------------------------------------------------------
Static Function GetFGTSData( oReq, cTicket, lIsLegacy )

	Local oResponse		:=	Nil
	Local oHashBase		:=	TAFXHMNew()
	Local oHashDepo		:=	TAFXHMNew()
	Local cStatusGov	:=	""
	Local cChave		:=	""
	Local nI			:=	0
	Local nFuncTotal	:=	0
	Local nFuncDiverg	:=	0
	Local nIni			:=	0
	Local nPosBase		:=	0
	Local nQtdRegs		:=	0
	Local nSeq			:=	0
	Local nPerc			:=	0
	Local nVlrRh		:= 0
	Local nVlrTaf		:= 0
	Local nVlrGov		:= 0
	Local aBaseSint		:=	{ "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	Local aBaseDiverg	:=	{ "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	Local aDepoSint		:=	{ "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	Local aDepoDiverg	:=	{ "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	Local aArqBase		:=	{}
	Local aArqDepo		:=	{}
	Local aResponse		:=	{}
	Local aArea			:=	GetArea()
	Local lFim			:=	.F.
	Local lDiverg		:=	.F.

	Private oModelV3J	:=	FWLoadModel( "TAFA531" )

//Filtra os dados do FGTS e gera o hash
	FilFGTSData( oReq, @oHashBase, @oHashDepo, cTicket, lIsLegacy )

//Grava o conteúdo dos hashs em arrays
	TAFXHMList( oHashBase, aArqBase )
	TAFXHMList( oHashDepo, aArqDepo )

	nQtdRegs := Len( aArqBase )

//Monta o retorno para a API de FGTS
	For nI := 1 to Len( aArqDepo )
		oResponse := JsonObject():New()

		If Empty( aArqDepo[nI,2,1,HASH_DEPOSITO_RECIBO_TRANSMISSAO] )
			cStatusGov := "Não Transmitido"
		ElseIf !aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]
			cStatusGov := "Não Localizado"
		Else
			cStatusGov := ""
		EndIf

		oResponse["cpfNumber"]				:=	aArqDepo[nI,2,1,HASH_DEPOSITO_CPF]

		oResponse["name"]					:=	aArqDepo[nI,2,1,HASH_DEPOSITO_NOME]
		oResponse["esocialRegistration"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_MATRICULA]
		oResponse["esocialCategory"]		:=	aArqDepo[nI,2,1,HASH_DEPOSITO_CATEGORIA]

		oResponse["fgtsValue"]				:=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
		oResponse["fgts13Value"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
		oResponse["fgtsRescissionValue"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

		oResponse["fgtsTafValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]
		oResponse["fgts13TafValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
		oResponse["fgtsRescissionTafValue"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]

		If Empty( cStatusGov )
			oResponse["fgtsRetValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
			oResponse["fgts13RetValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
			oResponse["fgtsRescissionRetValue"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
		Else
			oResponse["fgtsRetValue"]			:=	0
			oResponse["fgts13RetValue"]			:=	0
			oResponse["fgtsRescissionRetValue"]	:=	0
		EndIf

		aDepoSint[6]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
		aDepoSint[7]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
		aDepoSint[8]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

		aDepoSint[9]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]
		aDepoSint[10]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
		aDepoSint[11]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]

		If Empty( cStatusGov )
			aDepoSint[12]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
			aDepoSint[13]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
			aDepoSint[14]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
		EndIf

		nFuncTotal ++

		lDiverg := .F.
		nVlrRh	:= aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS] + aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
		nVlrTaf	:= aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS] + aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
		nVlrGov	:= aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS] + aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]

		If  !(nVlrRh == nVlrTaf .And. nVlrTaf == nVlrGov) .Or. ;
				!(aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO] == aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO] .And.;
				aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO] == aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO] )

			lDiverg		:=	.T.

			aDepoDiverg[6]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
			aDepoDiverg[7]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
			aDepoDiverg[8]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

			aDepoDiverg[9]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]
			aDepoDiverg[10]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
			aDepoDiverg[11]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]

			If Empty( cStatusGov )
				aDepoDiverg[12]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
				aDepoDiverg[13]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
				aDepoDiverg[14]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
			EndIf

			nFuncDiverg ++
		EndIf

		cChave := aArqDepo[nI,2,1,HASH_DEPOSITO_CPF] + aArqDepo[nI,2,1,HASH_DEPOSITO_CATEGORIA] + aArqDepo[nI,2,1,HASH_DEPOSITO_MATRICULA]

		lFim		:=	.F.
		nIni		:=	1
		aResponse	:=	{}

		While !lFim
			nPosBase := aScan( aArqBase, { |x| x[2,1,HASH_BASE_CPF] + x[2,1,HASH_BASE_CATEGORIA] + x[2,1,HASH_BASE_MATRICULA] == cChave }, nIni )

			//Se achar a base para o valor, adiciona um item novo no array
			If nPosBase > 0
				aAdd( aResponse, JsonObject():New() )

				If Empty( aArqBase[nPosBase,2,1,HASH_BASE_RECIBO_TRANSMISSAO] )
					cStatusGov := "Não Transmitido"
				ElseIf !aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_LOCALIZADO]
					cStatusGov := "Não Localizado"
				Else
					cStatusGov := ""
				EndIf

				aResponse[Len( aResponse )]["branchId"]					:=	aArqBase[nPosBase,2,1,HASH_BASE_ESTABELECIMENTO]
				aResponse[Len( aResponse )]["lotationCode"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_LOTACAO]

				aResponse[Len( aResponse )]["fgtsBasis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
				aResponse[Len( aResponse )]["fgts13Basis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
				aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

				aResponse[Len( aResponse )]["fgtsTafBasis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS]
				aResponse[Len( aResponse )]["fgts13TafBasis"]			:=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
				aResponse[Len( aResponse )]["fgtsRescissionTafBasis"]	:=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

				If Empty( cStatusGov )
					aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
					aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
					aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
				Else
					aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	0
					aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	0
					aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	0
				EndIf

				aBaseSint[3]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
				aBaseSint[4]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
				aBaseSint[5]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

				aBaseSint[6]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS]
				aBaseSint[7]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
				aBaseSint[8]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

				If Empty( cStatusGov )
					aBaseSint[9]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
					aBaseSint[10]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
					aBaseSint[11]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
				EndIf

				If lDiverg
					aBaseDiverg[3]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
					aBaseDiverg[4]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
					aBaseDiverg[5]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

					aBaseDiverg[6]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS]
					aBaseDiverg[7]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
					aBaseDiverg[8]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

					If Empty( cStatusGov )
						aBaseDiverg[9]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
						aBaseDiverg[10]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
						aBaseDiverg[11]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
					EndIf
				EndIf

				aDel( aArqBase, nPosBase )
				aSize( aArqBase, Len( aArqBase ) - 1 )

				nIni := nPosBase
				nPosBase := 0

				nPerc ++
				SetPercent( cTicket, nPerc, nQtdRegs,,, lIsLegacy )
			Else
				lFim := .T.
			EndIf
		EndDo

		oResponse["basis"] := aResponse

		//Grava o item na V45
		nSeq ++
		GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2" )
	Next nI

	lDiverg := .F.
	aSort( aArqBase,,, { |x,y| x[2,1,HASH_BASE_CPF] + x[2,1,HASH_BASE_NOME] + x[2,1,HASH_BASE_MATRICULA] + x[2,1,HASH_BASE_CATEGORIA] < y[2,1,HASH_BASE_CPF] + y[2,1,HASH_BASE_NOME] + y[2,1,HASH_BASE_MATRICULA] + y[2,1,HASH_BASE_CATEGORIA] } )

//Bases que não possuem vínculos com depósitos
	For nI := 1 to Len( aArqBase )
		oResponse := JsonObject():New()

		oResponse["cpfNumber"]				:=	aArqBase[nI,2,1,HASH_BASE_CPF]
		oResponse["name"]					:=	aArqBase[nI,2,1,HASH_BASE_NOME]
		oResponse["esocialRegistration"]	:=	aArqBase[nI,2,1,HASH_BASE_MATRICULA]
		oResponse["esocialCategory"]		:=	aArqBase[nI,2,1,HASH_BASE_CATEGORIA]

		oResponse["fgtsValue"]				:=	0
		oResponse["fgts13Value"]			:=	0
		oResponse["fgtsRescissionValue"]	:=	0

		oResponse["fgtsTafValue"]			:=	0
		oResponse["fgts13TafValue"]			:=	0
		oResponse["fgtsRescissionTafValue"]	:=	0

		oResponse["fgtsRetValue"]			:=	0
		oResponse["fgts13RetValue"]			:=	0
		oResponse["fgtsRescissionRetValue"]	:=	0

		nFuncTotal ++

		FwFreeArray(aResponse)

		aResponse := {}

		aAdd( aResponse, JsonObject():New() )

		If Empty( aArqBase[nI,2,1,HASH_BASE_RECIBO_TRANSMISSAO] )
			cStatusGov := "Não Transmitido"
		ElseIf !aArqBase[nI,2,1,HASH_BASE_GOVERNO_LOCALIZADO]
			cStatusGov := "Não Localizado"
		Else
			cStatusGov := ""
		EndIf

		aResponse[Len( aResponse )]["branchId"]					:=	aArqBase[nI,2,1,HASH_BASE_ESTABELECIMENTO]
		aResponse[Len( aResponse )]["lotationCode"]				:=	aArqBase[nI,2,1,HASH_BASE_LOTACAO]

		aResponse[Len( aResponse )]["fgtsBasis"]				:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS]
		aResponse[Len( aResponse )]["fgts13Basis"]				:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
		aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

		aResponse[Len( aResponse )]["fgtsTafBasis"]				:=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS]
		aResponse[Len( aResponse )]["fgts13TafBasis"]			:=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
		aResponse[Len( aResponse )]["fgtsRescissionTafBasis"]	:=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

		If Empty( cStatusGov )
			aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
			aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
			aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
		Else
			aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	0
			aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	0
			aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	0
		EndIf

		aBaseSint[3]	+=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS]
		aBaseSint[4]	+=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
		aBaseSint[5]	+=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

		aBaseSint[6]	+=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS]
		aBaseSint[7]	+=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
		aBaseSint[8]	+=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

		If Empty( cStatusGov )
			aBaseSint[9]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
			aBaseSint[10]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
			aBaseSint[11]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
		EndIf

		oResponse["basis"] := aResponse
		
		//Grava o item na V45
		nSeq ++
		GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2" )

		nPerc ++
		SetPercent( cTicket, nPerc, nQtdRegs,,, lIsLegacy )
	Next nI

	//Se não encontrou os dados
	If Empty(aArqDepo) .And. Empty(aArqBase) 
		SetPercent( cTicket, 100, 100,,, lIsLegacy )
	Else
		//Grava a parte sintética
		GrvFGTSSint( aDepoSint, aBaseSint, nFuncTotal, .F., 1 )
		GrvFGTSSint( aDepoDiverg, aBaseDiverg, nFuncDiverg, .T., 2 )
	EndIf

	SetFinish( cTicket )

	oModelV3J:Destroy()
	RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvItRes
@type			function
@description	Grava o item do resultado da requisição.
@author			Robson Santos
@since			21/08/2019
@param			aItem		-	Array com os itens do resultado
/*/
//---------------------------------------------------------------------
Static Function GrvItRes( cTicket, cResp, cSeq, lDiverg, cTipo )

	Default lDiverg	:=	.F.

	RecLock('V45',.T.)
		V45->V45_ID			:= cTicket
		V45->V45_RESP		:= cResp
		V45->V45_SEQ		:= cSeq
		V45->V45_DIVERG	:= Iif( lDiverg, "1", "2" ) 
		V45->V45_TIPO		:= cTipo
	V45->(MsUnlock())

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FilFGTSData
@type			function
@description	Filtra os dados de acordo com os parametros recebidos e salva em um hash.
@author			Robson Santos
@since			26/08/19
/*/
//---------------------------------------------------------------------
Static Function FilFGTSData(oReq as json, oHashBase as object, oHashDepo as object, cTicket as character, lIsLegacy as logical)

	Local aPosBase		as array
	Local aPosDepo		as array
	Local aLotacao    	as array
	Local aCategoria  	as array
	Local aEstabe     	as array
	Local aCPFs			as array
	Local aMats			as array
	Local cNatureza		as character 
	Local cTipo			as character
	Local cIncidFGTS	as character
	Local cQry        	as character
	Local cFilSel		as character
	Local cNextAlias    as character
	Local cMV_TAFFGMD	as character
	Local lAddBase		as logical
	Local lAddDepo		as logical
	Local lOnlyDiv		as logical
	Local lTafGpeFgts   as logical
	Local lHasMotDes	as logical
	Local lHasVlrDep	as logical
	Local nBasFGTS		as numeric
	Local nDepFGTS		as numeric
	Local nBasFGTSRes	as numeric
	Local nDepFGTSRes	as numeric
	Local nBasFGTS13	as numeric
	Local nDepFGTS13	as numeric
	Local nQtdRegs		as numeric
	Local nItem       	as numeric

	Default cTicket		:= ""
	Default lIsLegacy	:= .F.
	Default oReq		:= JsonObject():New()
	Default oHashBase	:= Nil
	Default oHashDepo	:= Nil

	aPosBase	:= {} 															
	aPosDepo	:= {} 															
	aLotacao    := {} 															
	aCategoria  := {} 															
	aEstabe     := {} 															
	aCPFs		:= {} 															
	aMats		:= {} 															
	cNatureza	:= "" 														
	cTipo		:= "" 														
	cIncidFGTS	:= "" 															
	cQry        := "" 														
	cFilSel		:= "" 															
	cNextAlias  := GetNextAlias() 											
	cMV_TAFFGMD	:= SuperGetMv("MV_TAFFGMD", .F., "02|03|05|06|14|17|26|27|33") 	
	lAddBase	:= .F. 														
	lAddDepo	:= .F. 														
	lOnlyDiv	:= .F. 														
	lTafGpeFgts := IIf(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F.) 
	lHasMotDes	:= TafColumnPos("V3N_MOTDES") 									
	lHasVlrDep	:= TafColumnPos("V3N_VLRDEP") 									
	nBasFGTS	:= 0 														
	nDepFGTS	:= 0 														
	nBasFGTSRes	:= 0 															
	nDepFGTSRes	:= 0 															
	nBasFGTS13	:= 0 															
	nDepFGTS13	:= 0 															
	nQtdRegs	:= 0 														
	nItem       := 0 														

	cFilSel := TAFCacheFil("V3N", FilMatriz(), .T.)

	If Select(cNextAlias) > 0
		(cNextAlias)->( dbCloseArea() )
	EndIf

	cPeriodo    := oReq["paymentPeriod"]
	aCategoria  := oReq["eSocialCategory"]
	aLotacao    := oReq["lotationCode"]
	aEstabe     := oReq["registrationNumber"]
	aCPFs		:= oReq["cpfNumber"]
	aMats 		:= oReq["eSocialRegistration"]
	lOnlyDiv	:= oReq["differencesOnly"]

	cQry := "SELECT * FROM ( "
	cQry += "SELECT "
	cQry += "   V3N.V3N_FILIAL, "
	cQry += "    V3N.V3N_INDAPU,  "
	cQry += "    V3N.V3N_PERAPU, "
	cQry += "    V3N.V3N_CPF, "
	cQry += "    V3N.V3N_NOME, "
	cQry += "    V3N.V3N_MATRIC, "
	cQry += "    V3N.V3N_CATEG, "
	cQry += "    V3N.V3N_TPINSC, "
	cQry += "    V3N.V3N_NRINSC, "
	cQry += "    V3N.V3N_CODLOT, "
	cQry += "    V3N.V3N_EVENTO, "
	cQry += "    V3N.V3N_ORIGEM, "
	cQry += "    V3N.V3N_RECIBO, "
	cQry += "    V3N.V3N_NATRUB, "
	cQry += "    V3N.V3N_TPRUBR, "
	cQry += "    V3N.V3N_ITFGTS, "
	cQry += "    V3N.V3N_TPVLR, "

	If lHasMotDes
		cQry += "    V3N.V3N_MOTDES, "
	EndIf

	If lHasVlrDep
		cQry += "    V3N.V3N_VLRDEP, "
	EndIf

	cQry += "    V3N.V3N_VALOR,  "
	cQry += "    C8O.C8O_CODIGO  " 
	cQry += " FROM  "+RetSqlName("V3N")+" V3N  " 

	cQry += " LEFT JOIN " + RetSqlName("C9V") + " C9V "
	cQry += "	ON C9V.C9V_FILIAL = V3N.V3N_FILIAL "
	cQry += "		AND C9V.C9V_CPF = V3N.V3N_CPF "
	cQry += "		AND (C9V.C9V_MATRIC = V3N.V3N_MATRIC "
	cQry += "			OR C9V.C9V_MATTSV = V3N.V3N_MATRIC) "
	cQry += "		AND C9V.C9V_ATIVO = '1' "
	cQry += "		AND	C9V.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("CMD") + " CMD "
	cQry += "	ON CMD.CMD_FILIAL =	V3N.V3N_FILIAL "
	cQry += "		AND CMD.CMD_FUNC = C9V.C9V_ID "
	cQry += "		AND	CMD.CMD_ATIVO =	'1' "
	cQry += "		AND	CMD.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("C8O") + " C8O "
	cQry += "	ON C8O.C8O_ID = CMD.CMD_MOTDES "
	cQry += "		AND	C8O.D_E_L_E_T_ = '' "

	cQry += " WHERE V3N.D_E_L_E_T_ = '' "
	cQry += "	AND V3N.V3N_EVENTO <> 'S-1200'"

	If lOnlyDiv .And. lIsLegacy
		cQry += "    AND V3N_ORIGEM IN ( '2', '5' )  "
	Else
		cQry += "    AND V3N_ORIGEM IN ( '1', '2', '5' )  "
	EndIf

	cQry += "    AND V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 
	cQry += "    AND V3N_PERAPU = '" + cPeriodo + "' "

	If !Empty(aCategoria)
		cQry += "    AND V3N_CATEG IN "+FormatIn(ArrayToStr(aCategoria),";")+"  "
	EndIf

	If !Empty(aLotacao)
		cQry += "    AND V3N_CODLOT IN "+FormatIn(ArrayToStr(aLotacao),";")+" "
	EndIf

	If !Empty(aEstabe)
		cQry += "    AND V3N_NRINSC IN "+FormatIn(ArrayToStr(aEstabe),";")+" "
	EndIf

	If !Empty(aCPFs)
		cQry += " AND V3N_CPF IN " + FormatIn(ArrayToStr(aCPFs),";") + " "
	EndIf

	If !Empty(aMats)
		cQry += " AND V3N_MATRIC IN " + FormatIn(ArrayToStr(aMats),";") + " "
	EndIf 

	cQry += "	UNION ALL "

	cQry += " SELECT "
	cQry += "   V3N.V3N_FILIAL, "
	cQry += "    V3N.V3N_INDAPU,  "
	cQry += "    V3N.V3N_PERAPU, "
	cQry += "    V3N.V3N_CPF, "
	cQry += "    V3N.V3N_NOME, "
	cQry += "    V3N.V3N_MATRIC, "
	cQry += "    V3N.V3N_CATEG, "
	cQry += "    V3N.V3N_TPINSC, "
	cQry += "    V3N.V3N_NRINSC, "
	cQry += "    V3N.V3N_CODLOT, "
	cQry += "    V3N.V3N_EVENTO, "
	cQry += "    V3N.V3N_ORIGEM, "
	cQry += "    V3N.V3N_RECIBO, "
	cQry += "    V3N.V3N_NATRUB, "
	cQry += "    V3N.V3N_TPRUBR, "
	cQry += "    V3N.V3N_ITFGTS, "
	cQry += "    V3N.V3N_TPVLR, "

	If lHasMotDes
		cQry += "    V3N.V3N_MOTDES, "
	EndIf

	If lHasVlrDep
		cQry += "    V3N.V3N_VLRDEP, "
	EndIf

	cQry += "    V3N.V3N_VALOR,  "
	cQry += "    C8O.C8O_CODIGO  " 
	cQry += " FROM  "+RetSqlName("V3N")+" V3N  "

	cQry += " LEFT JOIN " + RetSqlName("C9V") + " C9V "
	cQry += "	ON C9V.C9V_FILIAL = V3N.V3N_FILIAL "
	cQry += "		AND C9V.C9V_CPF = V3N.V3N_CPF "
	cQry += "		AND (C9V.C9V_MATRIC = V3N.V3N_MATRIC "
	cQry += "			OR C9V.C9V_MATTSV = V3N.V3N_MATRIC) "
	cQry += "		AND C9V.C9V_ATIVO = '1' "
	cQry += "		AND	C9V.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("CMD") + " CMD "
	cQry += "	ON CMD.CMD_FILIAL =	V3N.V3N_FILIAL "
	cQry += "		AND CMD.CMD_FUNC = C9V.C9V_ID "
	cQry += "		AND	CMD.CMD_ATIVO =	'1' "
	cQry += "		AND	CMD.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("C8O") + " C8O "
	cQry += "	ON C8O.C8O_ID = CMD.CMD_MOTDES "
	cQry += "		AND	C8O.D_E_L_E_T_ = '' "

	cQry += " WHERE V3N.D_E_L_E_T_ = '' "
	cQry += " AND V3N.V3N_EVENTO = 'S-1200' "
	cQry += "	AND V3N.V3N_MOTDES = '' "

	If lOnlyDiv .And. lIsLegacy
		cQry += "    AND V3N_ORIGEM IN ( '2', '5' )  "
	Else
		cQry += "    AND V3N_ORIGEM IN ( '1', '2', '5' )  "
	EndIf

	cQry += "    AND V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 
	cQry += "    AND V3N_PERAPU = '" + cPeriodo + "' "

	If !Empty(aCategoria)
		cQry += "    AND V3N_CATEG IN "+FormatIn(ArrayToStr(aCategoria),";")+"  "
	EndIf

	If !Empty(aLotacao)
		cQry += "    AND V3N_CODLOT IN "+FormatIn(ArrayToStr(aLotacao),";")+" "
	EndIf

	If !Empty(aEstabe)
		cQry += "    AND V3N_NRINSC IN "+FormatIn(ArrayToStr(aEstabe),";")+" "
	EndIf

	If !Empty(aCPFs)
		cQry += " AND V3N_CPF IN " + FormatIn(ArrayToStr(aCPFs),";") + " "
	EndIf

	If !Empty(aMats)
		cQry += " AND V3N_MATRIC IN " + FormatIn(ArrayToStr(aMats),";") + " "
	EndIf 

	cQry += " ) TMP "
	cQry += " ORDER BY V3N_ORIGEM "

	cQry := ChangeQuery(cQry)

	TCQUERY cQry NEW ALIAS (cNextAlias)

	If (cNextAlias)->( !Eof() )
		( cNextAlias )->( DBEval( { || nQtdRegs ++ } ) )
	EndIf

	(cNextAlias)->( dbGoTop() )

	While (cNextAlias)->( !Eof() )
		cEvento := AllTrim( ( cNextAlias )->V3N_EVENTO )

		Do Case

		Case ( cNextAlias )->V3N_ORIGEM $ "1|2"

			cNatureza	:=	AllTrim( ( cNextAlias )->V3N_NATRUB )
			cTipo		:=	AllTrim( ( cNextAlias )->V3N_TPRUBR )
			cIncidFGTS	:=	AllTrim( ( cNextAlias )->V3N_ITFGTS )

			If ( cNextAlias )->V3N_INDAPU == "1"
				If cNatureza == "9902" .And. cTipo == "3"
					nBasFGTS := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				ElseIf cNatureza == "9904" .And. cTipo == "3"
					nBasFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				ElseIf cNatureza == "9908" .And. cTipo == "3"
					// Ser S-2299/S-2399 não é motivo para automaticamente incluir como FGTS Rescisório.
					// Se o Desligamento tiver Motiv de Desligamento diferente de 02|03|05|06|14|17|26|27|33, ele não gera guia de FGTS Rescisório, sendo considerado FGTS Mensal
					If cEvento == "S-1200" .Or. (  lHasMotDes .And. val(( cNextAlias )->V3N_MOTDES) > 0 .And. !( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) 
						nDepFGTS := ( cNextAlias )->V3N_VALOR
						lAddDepo := .T.
					Else
						nDepFGTSRes := ( cNextAlias )->V3N_VALOR
						lAddDepo := .T.
					EndIf
				EndIf
			ElseIf ( cNextAlias )->V3N_INDAPU == "2"
				If cNatureza == "9902" .And. cTipo == "3"
					nBasFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				ElseIf cNatureza == "9908" .And. cTipo == "3"
					nDepFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				ElseIf lTafGpeFgts  .And. cNatureza == "9989" .And. cTipo == "4" .And. cIncidFGTS =="12"
					nBasFGTS13 -= ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				EndIf
			EndIf
			
		Case ( cNextAlias )->V3N_ORIGEM == "5"
			
			cTipo := AllTrim( ( cNextAlias )->V3N_TPVLR )

			If cTipo $ "11|13|15|17|41|43" 
				If lHasMotDes .And. ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nBasFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				Else
					nBasFGTS := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					If lHasVlrDep .And. ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTS := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
					EndIf
					
				EndIf
			ElseIf cTipo $ "12|14|16|18|22|25|28|31|42|44|46|49"
				If lHasMotDes .And. ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nBasFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					If lHasVlrDep .And. ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTSRes := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
					EndIf 
				
				Else
					nBasFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					If lHasVlrDep .And. ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTS13 := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
					EndIf
					
				EndIf
			ElseIf cTipo $ "21|23|24|26|27|29|30|32|45|47|48|50"
				nBasFGTSRes := ( cNextAlias )->V3N_VALOR
				lAddBase := .T.

				If lHasVlrDep .And. ( cNextAlias )->V3N_VLRDEP > 0
					nDepFGTSRes := ( cNextAlias )->V3N_VLRDEP
					lAddDepo := .T.
				EndIf

			ElseIf cTipo $ "51|53|55|57"
				If lHasMotDes .And. ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nDepFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				Else
					nDepFGTS := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				EndIf
			ElseIf cTipo $ "52|54|56|58|65|68|71"
				If lHasMotDes .And. ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nDepFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				Else
					nDepFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				EndIf
			ElseIf cTipo $ "61|62|63|64|66|67|69|70|72"
				nDepFGTSRes := ( cNextAlias )->V3N_VALOR
				lAddDepo := .T.
			EndIf

		OtherWise
			lAddBase := .F.
			lAddDepo := .F.
		EndCase

		If lAddBase
			If TAFXHMGet( oHashBase, AllTrim( ( cNextAlias )->V3N_NRINSC ) + AllTrim( ( cNextAlias )->V3N_CPF ) + AllTrim( ( cNextAlias )->V3N_MATRIC ) + AllTrim( ( cNextAlias )->V3N_CATEG ) + AllTrim( ( cNextAlias )->V3N_CODLOT ), @aPosBase )
				aPosBase[1,HASH_BASE_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosBase[1,HASH_BASE_NOME]				:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosBase[1,HASH_BASE_MATRICULA]			:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosBase[1,HASH_BASE_LOTACAO]			:=	AllTrim( ( cNextAlias )->V3N_CODLOT )
				aPosBase[1,HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( ( cNextAlias )->V3N_NRINSC )
				aPosBase[1,HASH_BASE_CATEGORIA]			:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosBase[1,HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS]				+=	nBasFGTS
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosBase[1,HASH_BASE_TAF_BASE_FGTS]				+=	nBasFGTS
					aPosBase[1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
					aPosBase[1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS]				+=	nBasFGTS
					aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
					aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes
					aPosBase[1,HASH_BASE_GOVERNO_LOCALIZADO]			:=	.T.

				EndCase

				aPosBase[1,HASH_BASE_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				TAFXHMSet( oHashBase, aPosBase[1,HASH_BASE_ESTABELECIMENTO] + aPosBase[1,HASH_BASE_CPF] + aPosBase[1,HASH_BASE_MATRICULA] + aPosBase[1,HASH_BASE_CATEGORIA] + aPosBase[1,HASH_BASE_LOTACAO], aPosBase )
			Else
				aPosBase := InitBase()

				aPosBase[HASH_BASE_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosBase[HASH_BASE_NOME]			:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosBase[HASH_BASE_MATRICULA]		:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosBase[HASH_BASE_LOTACAO]			:=	AllTrim( ( cNextAlias )->V3N_CODLOT )
				aPosBase[HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( ( cNextAlias )->V3N_NRINSC )
				aPosBase[HASH_BASE_CATEGORIA]		:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosBase[HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS]				:=	nBasFGTS
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosBase[HASH_BASE_TAF_BASE_FGTS]				:=	nBasFGTS
					aPosBase[HASH_BASE_TAF_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
					aPosBase[HASH_BASE_TAF_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosBase[HASH_BASE_GOVERNO_BASE_FGTS]				:=	nBasFGTS
					aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
					aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes
					aPosBase[HASH_BASE_GOVERNO_LOCALIZADO]				:=	.T.

				EndCase

				aPosBase[HASH_BASE_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				TAFXHMAdd( oHashBase, aPosBase, HASH_BASE_ESTABELECIMENTO, 3, HASH_BASE_CPF, 3, HASH_BASE_MATRICULA, 3, HASH_BASE_CATEGORIA, 3, HASH_BASE_LOTACAO, 3 )
			EndIf
		EndIf

		If lAddDepo
			If TAFXHMGet( oHashDepo, AllTrim( ( cNextAlias )->V3N_CPF ) + AllTrim( ( cNextAlias )->V3N_MATRIC ) + AllTrim( ( cNextAlias )->V3N_CATEG ), @aPosDepo )
				aPosDepo[1,HASH_DEPOSITO_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosDepo[1,HASH_DEPOSITO_NOME]				:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosDepo[1,HASH_DEPOSITO_MATRICULA]			:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosDepo[1,HASH_DEPOSITO_CATEGORIA]			:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosDepo[1,HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				+=	nDepFGTS
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]				+=	nDepFGTS
					aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
					aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				+=	nDepFGTS
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]				:=	.T.

				EndCase

				aPosDepo[1,HASH_DEPOSITO_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				TAFXHMSet( oHashDepo, aPosDepo[1,HASH_DEPOSITO_CPF] + aPosDepo[1,HASH_DEPOSITO_MATRICULA] + aPosDepo[1,HASH_DEPOSITO_CATEGORIA], aPosDepo )
			Else
				aPosDepo := InitDeposito()

				aPosDepo[HASH_DEPOSITO_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosDepo[HASH_DEPOSITO_NOME]			:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosDepo[HASH_DEPOSITO_MATRICULA]		:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosDepo[HASH_DEPOSITO_CATEGORIA]		:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosDepo[HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	nDepFGTS
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS]				:=	nDepFGTS
					aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
					aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:=	nDepFGTS
					aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
					aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
					aPosDepo[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:=	.T.

				EndCase

				aPosDepo[HASH_DEPOSITO_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				TAFXHMAdd( oHashDepo, aPosDepo, HASH_DEPOSITO_CPF, 3, HASH_DEPOSITO_MATRICULA, 3, HASH_DEPOSITO_CATEGORIA, 3 )
			EndIf
		EndIf

		(cNextAlias)->(dbSkip())

		nItem++

		setPercent(cTicket, nItem, nQtdRegs,,, lIsLegacy)

		cNatureza	:=	""
		cTipo		:=	""
		cIncidFGTS	:=	""
		nBasFGTS	:=	0
		nDepFGTS	:=	0
		nBasFGTS13	:=	0
		nDepFGTS13	:=	0
		nBasFGTSRes	:=	0
		nDepFGTSRes	:=	0
		aPosBase	:=	{}
		aPosDepo	:=	{}
		lAddBase	:=	.F.
		lAddDepo	:=	.F.

	EndDo

	If lIsLegacy

		cAliasV5H	:= V5HByTicket(cTicket)

		If !Empty(cAliasV5H)
			(cAliasV5H)->( dbGoTop() )
			

			While (cAliasV5H)->( !Eof() )
				
				aPosBase	:= {}
				aPosDepo	:= {}
				
				If TAFXHMGet( oHashBase, AllTrim((cAliasV5H)->V5H_ESTABE) + AllTrim((cAliasV5H)->V5H_CPF) + AllTrim((cAliasV5H)->V5H_MATRIC) + AllTrim((cAliasV5H)->V5H_CATEG) + AllTrim((cAliasV5H)->V5H_LOTACA), @aPosBase )

					aPosBase[1,HASH_BASE_CPF]							:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosBase[1,HASH_BASE_NOME]							:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosBase[1,HASH_BASE_MATRICULA]						:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosBase[1,HASH_BASE_LOTACAO]						:=	AllTrim( (cAliasV5H)->V5H_LOTACA )
					aPosBase[1,HASH_BASE_ESTABELECIMENTO]				:=	AllTrim( (cAliasV5H)->V5H_ESTABE )
					aPosBase[1,HASH_BASE_CATEGORIA]						:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS]				:=	(cAliasV5H)->V5H_BSFGTS
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_BSFG13
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_BSFGRE

					TAFXHMSet( oHashBase, aPosBase[1,HASH_BASE_ESTABELECIMENTO] + aPosBase[1,HASH_BASE_CPF] + aPosBase[1,HASH_BASE_MATRICULA] + aPosBase[1,HASH_BASE_CATEGORIA] + aPosBase[1,HASH_BASE_LOTACAO], aPosBase )
				Else
					aPosBase	:= InitBase()

					aPosBase[HASH_BASE_CPF]							:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosBase[HASH_BASE_NOME]						:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosBase[HASH_BASE_MATRICULA]					:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosBase[HASH_BASE_LOTACAO]						:=	AllTrim( (cAliasV5H)->V5H_LOTACA )
					aPosBase[HASH_BASE_ESTABELECIMENTO]				:=	AllTrim( (cAliasV5H)->V5H_ESTABE )
					aPosBase[HASH_BASE_CATEGORIA]					:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS]				:=	(cAliasV5H)->V5H_BSFGTS
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_BSFG13
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_BSFGRE

					TAFXHMAdd( oHashBase, aPosBase, HASH_BASE_ESTABELECIMENTO, 3, HASH_BASE_CPF, 3, HASH_BASE_MATRICULA, 3, HASH_BASE_CATEGORIA, 3, HASH_BASE_LOTACAO, 3 )

				EndIf

				If TAFXHMGet( oHashDepo, AllTrim((cAliasV5H)->V5H_CPF) + AllTrim((cAliasV5H)->V5H_MATRIC) + AllTrim((cAliasV5H)->V5H_CATEG), @aPosDepo )

					aPosDepo[1,HASH_DEPOSITO_CPF]								:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosDepo[1,HASH_DEPOSITO_NOME]								:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosDepo[1,HASH_DEPOSITO_MATRICULA]							:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosDepo[1,HASH_DEPOSITO_CATEGORIA]							:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	(cAliasV5H)->V5H_VLFGTS
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_VLFG13
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_VLFGRE

					TAFXHMSet( oHashDepo, aPosDepo[1,HASH_DEPOSITO_CPF] + aPosDepo[1,HASH_DEPOSITO_MATRICULA] + aPosDepo[1,HASH_DEPOSITO_CATEGORIA], aPosDepo )

				Else

					aPosDepo	:= InitDeposito()

					aPosDepo[HASH_DEPOSITO_CPF]								:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosDepo[HASH_DEPOSITO_NOME]							:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosDepo[HASH_DEPOSITO_MATRICULA]						:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosDepo[HASH_DEPOSITO_CATEGORIA]						:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	(cAliasV5H)->V5H_VLFGTS
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_VLFG13
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_VLFGRE

					TAFXHMAdd( oHashDepo, aPosDepo, HASH_DEPOSITO_CPF, 3, HASH_DEPOSITO_MATRICULA, 3, HASH_DEPOSITO_CATEGORIA, 3 )

				EndIf

				(cAliasV5H)->( dbSkip() )
			EndDo

		EndIf

	EndIf

	If nItem == 0
		SetPercent( cTicket, 100, 100,,, lIsLegacy )
	EndIf

Return

Static Function InitBase()

	Local aInit	:=	Array( 18 )

	aInit[HASH_BASE_RECIBO_TRANSMISSAO]				:=	""
	aInit[HASH_BASE_ESTABELECIMENTO]				:=	""
	aInit[HASH_BASE_CPF]							:=	""
	aInit[HASH_BASE_NOME]							:=	""
	aInit[HASH_BASE_MATRICULA]						:=	""
	aInit[HASH_BASE_CATEGORIA]						:=	""
	aInit[HASH_BASE_LOTACAO]						:=	""
	aInit[HASH_BASE_EVENTO_ESOCIAL]					:=	0
	aInit[HASH_BASE_FOLHA_BASE_FGTS]				:=	0
	aInit[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]		:=	0
	aInit[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]		:=	0
	aInit[HASH_BASE_TAF_BASE_FGTS]					:=	0
	aInit[HASH_BASE_TAF_BASE_FGTS_13_SALARIO]		:=	0
	aInit[HASH_BASE_TAF_BASE_FGTS_RESCISORIO]		:=	0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS]				:=	0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	:=	0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	:=	0
	aInit[HASH_BASE_GOVERNO_LOCALIZADO]				:=	.F.

Return( aInit )

Static Function InitDeposito()

	Local aInit	:=	Array( 16 )

	aInit[HASH_DEPOSITO_RECIBO_TRANSMISSAO]					:=	""
	aInit[HASH_DEPOSITO_CPF]								:=	""
	aInit[HASH_DEPOSITO_NOME]								:=	""
	aInit[HASH_DEPOSITO_MATRICULA]							:=	""
	aInit[HASH_DEPOSITO_CATEGORIA]							:=	""
	aInit[HASH_DEPOSITO_EVENTO_ESOCIAL]						:=	0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]		:=	0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]		:=	0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS]					:=	0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]		:=	0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]		:=	0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:=	0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	0
	aInit[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:=	.F.

Return( aInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} setPercent
@type			function
@description	Incrementa o percentual de processamento da requisição.
@author			Robson Santos
@since			26/08/19
/*/
//---------------------------------------------------------------------
Static Function setPercent( cTicket, nItem, nQtdRegs, lPercRH, nPercRH, lIsLegacy )

	Local aArea     := GetArea()
	Local lRet		:= .F.
	Local nPerc     := 0
	Local nDif      := 0
	Local nPeso     := 50

	Default lPercRH	:= .F.
	Default nPercRH	:= 0

	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )

		If !lPercRH
			nPerc := (Int( ( nItem / nQtdRegs ) * 100 ) * (nPeso/100))
			if lIsLegacy
				nDif := ((V3J->V3J_PERC + nPerc) - V3J->V3J_PERC)
			else
				nDif := (nPerc - V3J->V3J_PERC)
			endif
		Else
			nPerc := nPercRH
		EndIf

		If nPerc > 0

			If !lPercRH
				If V3J->V3J_PERC >= nPeso
					nPerc := (nPeso + nPerc)
				Else
					nPerc := (V3J->V3J_PERC + nDif)
				EndIf
			EndIf
			
			RecLock("V3J", .F.)
				V3J->V3J_PERC := Int( nPerc )
			V3J->(MsUnlock())
		EndIf

		lRet := .T.
	EndIf

	RestArea(aArea)
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFinish
@type			function
@description	Indica a finalização do processamento da requisição.
@author			Felipe C. Seolin
@since			18/09/2019
@param			cTicket	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function SetFinish( cTicket )

	Local aAreaV3J	:=	V3J->( GetArea() )

	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )
		oModelV3J:SetOperation( MODEL_OPERATION_UPDATE )
		oModelV3J:Activate()

		oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS", "2" )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTRESP", Date() )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRRESP", StrTran( Time(), ":", "" ) )

		FWFormCommit( oModelV3J )

		oModelV3J:DeActivate()
	EndIf

	RestArea( aAreaV3J )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvFGTSSint
@type			function
@description	Grava a parte sintética do relatório.
@author			Robson Santos
@since			27/08/19
/*/
//---------------------------------------------------------------------
Static Function GrvFGTSSint( aDepoSint, aBaseSint, nEmployees, lDiverg, nSeq )

	Local oResponse	:=	JsonObject():New()
	Local aResponse	:=	{}

	oResponse["cpfNumber"]				:=	aDepoSint[1]
	oResponse["name"]					:=	aDepoSint[2]
	oResponse["esocialRegistration"]	:=	aDepoSint[3]
	oResponse["esocialCategory"]		:=	aDepoSint[4]
	oResponse["numberEmployees"]		:=	nEmployees

	oResponse["fgtsValue"]				:=	aDepoSint[6]
	oResponse["fgts13Value"]			:=	aDepoSint[7]
	oResponse["fgtsRescissionValue"]	:=	aDepoSint[8]

	oResponse["fgtsTafValue"]			:=	aDepoSint[9]
	oResponse["fgts13TafValue"]			:=	aDepoSint[10]
	oResponse["fgtsRescissionTafValue"]	:=	aDepoSint[11]

	oResponse["fgtsRetValue"]			:=	aDepoSint[12]
	oResponse["fgts13RetValue"]			:=	aDepoSint[13]
	oResponse["fgtsRescissionRetValue"]	:=	aDepoSint[14]

//Base
	aAdd( aResponse, JsonObject():New() )

	aResponse[Len( aResponse )]["branchId"]					:=	aBaseSint[1]
	aResponse[Len( aResponse )]["lotationCode"]				:=	aBaseSint[2]

	aResponse[Len( aResponse )]["fgtsBasis"]				:=	aBaseSint[3]
	aResponse[Len( aResponse )]["fgts13Basis"]				:=	aBaseSint[4]
	aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aBaseSint[5]

	aResponse[Len( aResponse )]["fgtsTafBasis"]				:=	aBaseSint[6]
	aResponse[Len( aResponse )]["fgts13TafBasis"]			:=	aBaseSint[7]
	aResponse[Len( aResponse )]["fgtsRescissionTafBasis"]	:=	aBaseSint[8]

	aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	aBaseSint[9]
	aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	aBaseSint[10]
	aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	aBaseSint[11]

	oResponse["basis"] := aResponse

	GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "1" )

Return()

/*/{Protheus.doc} R123InitArray
Inicializa o array com as devidas posi??es em branco/zerada
@type  static
@author Victor A. Barbosa
@since 20/05/2019
@version 1
/*/
Static Function R123InitArray()

	Local aInit as array

	aInit 												:= Array(40)
	aInit[CPFFUNC]										:= ""
	aInit[NOMEFUNC]										:= ""
	aInit[MATRIC]										:= ""
	aInit[LOTAC]										:= ""
	aInit[ESTABELECIMENTO]								:= ""
	aInit[CATEG]										:= ""
	aInit[RECIBO_TRANSMISSAO]							:= ""
	aInit[TIPO_BASE_CALCULO]							:= ""
	aInit[OBSERVACAO]									:= ""
	aInit[TIPO_FUNCIONARIO]								:= ""
	aInit[EVENTO_ESOCIAL]								:= ""
	aInit[FOLHA_BASE_INSS]								:= 0
	aInit[FOLHA_VALOR_INSS]								:= 0
	aInit[FOLHA_VALOR_SALARIO_FAMILIA]					:= 0
	aInit[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= 0
	aInit[FOLHA_BASE_INSS_13_SALARIO]					:= 0
	aInit[FOLHA_VALOR_INSS_13_SALARIO]					:= 0
	aInit[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= 0
	aInit[TAF_BASE_INSS]								:= 0
	aInit[TAF_VALOR_INSS]								:= 0
	aInit[TAF_VALOR_SALARIO_FAMILIA]					:= 0
	aInit[TAF_VALOR_SALARIO_MATERNIDADE]				:= 0
	aInit[TAF_VALOR_INSS_13_SALARIO]					:= 0
	aInit[TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		:= 0
	aInit[TAF_BASE_INSS_13_SALARIO]						:= 0
	aInit[GOVERNO_BASE_INSS]							:= 0
	aInit[GOVERNO_VALOR_INSS]							:= 0
	aInit[GOVERNO_VALOR_SALARIO_FAMILIA]				:= 0
	aInit[GOVERNO_VALOR_SALARIO_MATERNIDADE]			:= 0
	aInit[GOVERNO_BASE_INSS_13_SALARIO]					:= 0
	aInit[GOVERNO_VALOR_INSS_13_SALARIO]				:= 0
	aInit[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= 0
	aInit[GOVERNO_LOCALIZADO]							:= .F.
	aInit[GOVERNO_GROSS_VALUE]							:= 0
	aInit[GOVERNO_DESC_GROSS_VALUE]						:= 0
	aInit[GOVERNO_13_GROSS_VALUE]						:= 0
	aInit[GOVERNO_13_DESC_GROSS_VALUE]					:= 0
	aInit[CAT_DESCRI]									:= 0
	aInit[GOVERNO_BASE_SUSPENSAO]						:= 0
	aInit[GOVERNO_BASE_TOTAL_INSS]						:= 0

Return aInit

//---------------------------------------------------------------------
/*/{Protheus.doc} Status
@type			method
@description	Método para consultar o percentual de execução do relatório.
@author			Felipe C. Seolin
@since			30/08/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
	WSMETHOD GET Status QUERYPARAM companyId, requestId WSRESTFUL reportEsocialBaseConfer

	Local oResponse		:=	Nil
	Local cEmpRequest	:=	""
	Local cFilRequest	:=	""
	Local cRequestID	:=	""
	Local aCompany		:=	{}
	Local lRet			:=	.T.
	Local lIsLegacy			:=	.F.

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf self:requestId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				lIsLegacy := TAFAlsInDic( "V5H" ) .and. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

				If ValidID( self:requestId,, lIsLegacy )
					cRequestID := self:requestId

					GetStatus( @oResponse, cRequestID )

					self:SetResponse( oResponse:toJson() )
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf

	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
@type			function
@description	Executa a consulta do percentual de execução do relatório.
@author			Felipe C. Seolin
@since			30/08/2019
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function GetStatus( oResponse, cRequestID )

	oResponse := JsonObject():New()

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	If V3J->( DBSeek( xFilial( "V3J" ) + cRequestID ) )
	oResponse["percent"]	:=	V3J->V3J_PERC

		If V3J->V3J_PERC == 100
			oResponse["finished"]	:= .T.	
		Else
			oResponse["finished"]	:= .F.
		EndIf

	EndIf

	TAFConOut(ProcName() + oResponse:ToJson() + ' ' +  V3J->V3J_STATUS + ' ' + cValToChar(V3J->V3J_PERC) )
Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FgtsValues
@type			method
@description	Método para consultar resultado do relatório de conferência de FGTS.
@author			Felipe C. Seolin
@since			29/08/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
	WSMETHOD GET FgtsValues QUERYPARAM companyId, requestId, synthetic, differencesOnly, page, pageSize WSRESTFUL reportEsocialBaseConfer

	Local oResponse		:=	Nil

	Local cEmpRequest	:=	""
	Local cFilRequest	:=	""
	Local cRequestID	:=	""
	Local cPeriod		:=	""
	
	Local nPage			:=	1
	Local nPageSize		:=	30

	Local lSynthetic	:=	.F.
	Local lDiverg		:=	.F.
	Local lRet			:=	.T.
	Local lIsLegacy			:=	.F.

	Local aCompany		:=	{}
	Local aCPFCabec		:=  {}

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf self:requestId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				lIsLegacy := TAFAlsInDic( "V5H" ) .and. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

				If ValidID( self:requestId, @cPeriod, lIsLegacy,@aCPFCabec )
					cRequestID := self:requestId

					If self:synthetic <> Nil
						lSynthetic := self:synthetic
					EndIf

					If self:differencesOnly <> Nil
						lDiverg := self:differencesOnly
					EndIf

					If self:page <> Nil
						nPage := self:page
					EndIf

					If self:pageSize <> Nil
						nPageSize := self:pageSize
					EndIf

					GetReport( @oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, "2", cPeriod, lIsLegacy, aCompany[2],aCPFCabec )

					self:SetResponse( oResponse:toJson() )
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf

	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} PrepEnv
@type			function
@description	Prepara o ambiente de acordo com os parâmetros.
@author			Felipe C. Seolin
@since			16/10/2019
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@return			lRet		-	Indica se o ambiente foi preparado
/*/
//---------------------------------------------------------------------
Function PrepEnv( cEmpRequest, cFilRequest )

	Local lRet := .T.
	Local lMPP := .F.

	if FindFunction( "NewRestMPP" )
		lMPP := NewRestMPP()
	endif

	If !lMPP .And. Type( "cEmpAnt" ) == "U" .or. Type( "cFilAnt" ) == "U"
		TafPrepRPC(cEmpRequest, cFilRequest, "TAF", "WSTAF010")
	ElseIf cEmpAnt <> cEmpRequest
		If !lMPP .And. FWFilExist( cEmpRequest, cFilRequest )
			TafPrepRPC(cEmpRequest, cFilRequest, "TAF", "WSTAF010")
		Else
			lRet := .F.
		EndIf
	ElseIf cFilAnt <> cFilRequest
		cFilAnt := cFilRequest
		SM0->(dbSetOrder(1))
		SM0->(MsSeek(cEmpRequest+cFilRequest))
	EndIf

	If lRet
		lRet := FWFilExist( cEmpRequest, cFilRequest )
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafPrepRPC
@type			static function
@description	Prepara o ambiente de acordo com os parâmetros.
@author			Denis Souza
@since			16/03/2022
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@param			cMod		-	Prefixo do Modulo
@param			cProgName	-	Nome do Programa
@return			Nulo
/*/
//---------------------------------------------------------------------
Static Function TafPrepRPC(cEmpRequest,cFilRequest,cMod,cProgName)

	Default cEmpRequest := ''
	Default cFilRequest := ''
	Default cMod		:= ''
	Default cProgName	:= ''

	RPCClearEnv()
	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest,,,cMod,cProgName)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GetReport
@type			function
@description	Executa a consulta do resultado do relatório de conferência de INSS.
@author			Felipe C. Seolin
@since			19/08/2019
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
@param			lSynthetic	-	Indica se o retorno deve ser sintético ou analítico
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			cPeriod		-	Período de emissão do relatório
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@param			cTribute	-	1 - INSS | 2 - FGTS
/*/
//---------------------------------------------------------------------
Static Function GetReport( oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, cTribute, cPeriod, lIsLegacy, cCompanyId,aCPFCabec )

	Local oJson			:=	Nil
	Local nTamV45_ID	:=	TamSX3( "V45_ID" )[1]
	Local aJson			:=	{}
	Local lHasNext		:=	.F.

	Default aCPFCabec := {}

	oResponse := JsonObject():New()

	cRequestID := PadR( cRequestID, nTamV45_ID )

	DBSelectArea( "V45" )

	If lSynthetic
		V45->( DBSetOrder( 2 ) )
		If V45->( MsSeek( xFilial( "V45" ) + cRequestID + "1" + Iif( lDiverg, "1", "2" ) ) )
			If CheckDiv(V45->V45_RESP)
				oJson := JsonObject():New()
				oJson:FromJson( V45->V45_RESP )
				aAdd( aJson, oJson )
				FreeObj( oJson )
			EndIf
		EndIf
	Else
		aJson := GetDetails( cRequestID, lDiverg, nPage, nPageSize, @lHasNext, cTribute, cPeriod, lIsLegacy, cCompanyId, aCPFCabec )
	EndIf

	oResponse["items"]		:=	aJson
	oResponse["hasNext"]	:=	lHasNext

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidID
@type			function
@description	Verifica se o Identificador da Requisição é válido.
@author			Felipe C. Seolin
@since			19/08/2019
@param			cPeriod		-	Utilizado para retornar o período por referência
@param			cRequestID	-	Identificador da Requisição
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@return			lRet		-	Indica se o Identificador da Requisição é válido
/*/
//---------------------------------------------------------------------
Static Function ValidID( cRequestID, cPeriod, lIsLegacy, aCPFCabec )

	Local lRet		:=	.F.
	Local oRequest	:=	Nil

	Default aCPFCabec := {}

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	lRet := V3J->( MsSeek( xFilial( "V3J" ) + cRequestID ) )

	If lRet .And. lIsLegacy
		oRequest := JsonObject():New()
		oRequest:FromJson( V3J->V3J_PARAMS )
		cPeriod := oRequest["paymentPeriod"]
		aCPFCabec := oRequest["cpfNumber"]

		FreeObj( oRequest )
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDetails
@type			function
@description	Retorna os registros analíticos com controle de paginação.
@author			Victor A. Barbosa
@since			17/09/2019
@param			cRequestID	-	Identificador da Requisição
@param			cTribute	-	1 - INSS | 2 - FGTS
@param			cPeriod		-	Período de emissão do relatório
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			lHasNext	-	Indica se há existência de mais registros além dos retornados ( Referência )
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@param			cCompanyId
@param			aCPFCabec	-	CPFs que serão consultados
@return			aJson		-	Json com o resultado processado para o relatório
/*/
//---------------------------------------------------------------------
Static Function GetDetails(cRequestID, lDiverg, nPage, nPageSize, lHasNext, cTribute, cPeriod, lIsLegacy, cCompanyId, aCPFCabec)

	Local aJson			:= {}
	Local cWhere		:= ""
	Local cBanco    	:= TcGetDb()
	Local cNextAlias	:= GetNextAlias()
	Local nRegIni		:= 0
	Local nRegFim		:= 0
	Local oJson			:= Nil

	Default aCPFCabec 	:=  {}

	If lDiverg
		cWhere := " V45.V45_DIVERG = '1' "
	Else
		cWhere := " V45.V45_DIVERG IN ('1', '2') "
	EndIf

	cWhere	:= "%" + cWhere + "%"

	nRegIni := IIf(cBanco != "OPENEDGE", ((nPage - 1) * nPageSize) + 1, (nPage - 1) * nPageSize)
	nRegFim := nPage * nPageSize

	If cBanco != "OPENEDGE"
		BeginSQL Alias cNextAlias
			SELECT * FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER, R_E_C_N_O_ V45_RECNO
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
					AND V45.V45_ID = %exp:cRequestID%
					AND V45.V45_TIPO = '2'
					AND %exp:cWhere%
					AND V45.%notdel%
			) TAB
			WHERE LINE_NUMBER BETWEEN %exp:nRegIni% AND %exp:nRegFim%
		EndSQL
	Else
		BeginSQL Alias cNextAlias
			SELECT R_E_C_N_O_ V45_RECNO
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = %xFilial:V45%
				AND V45.V45_ID = %exp:cRequestID%
				AND V45.V45_TIPO = '2'
				AND %exp:cWhere%
				AND V45.%notdel%
				OFFSET %exp:nRegIni% ROWS FETCH NEXT %exp:nRegFim% ROWS ONLY
		EndSQL
	EndIf

	( cNextAlias )->( DBGoTop() )

	While ( cNextAlias )->( !Eof() )
		V45->( DBGoTo( ( cNextAlias )->V45_RECNO ) )

		If ( lDiverg .and. V45->V45_DIVERG == "1" ) .or. !lDiverg
			oJson := JsonObject():New()
			oJson:FromJson( V45->V45_RESP )

			aAdd( aJson, oJson )
			FreeObj( oJson )
		EndIf

		( cNextAlias )->( DBSkip() )
	EndDo

	( cNextAlias )->( DBCloseArea() )

	lHasNext := HasNext( cRequestID, nRegFim, lDiverg )

Return aJson

//---------------------------------------------------------------------
/*/{Protheus.doc} HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			Victor A. Barbosa
@since			17/09/2019
@param			cRequestID	-	Identificador da Requisição
@param			nRegFim		-	Identificador do último registro retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
@param			lDiverg		-	Indica se é para filtrar somente os registros com diverências
/*/
//---------------------------------------------------------------------
Static Function HasNext(cRequestID, nRegFim, lDiverg)

	Local cWhere	:= ""
	Local cBanco	:= TcGetDb()
	Local cAliasMax	:= GetNextAlias()
	Local lHasNext	:= .F.

	If lDiverg
		cWhere := " V45.V45_DIVERG = '1' "
	Else
		cWhere := " V45.V45_DIVERG IN ('1', '2') "
	EndIf

	cWhere	:= "%" + cWhere + "%"

	If cBanco != "OPENEDGE"
		BeginSQL Alias cAliasMax
			SELECT MAX(LINE_NUMBER) MAX_LINE FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
					AND V45.V45_ID = %exp:cRequestID%
					AND V45.V45_TIPO = '2'
					AND %Exp:cWhere%
					AND V45.%notdel%
			) TAB
		EndSQL
	Else
		BeginSQL Alias cAliasMax
			SELECT COUNT(*) MAX_LINE FROM (
				SELECT V45.V45_ID
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
					AND V45.V45_ID = %exp:cRequestID%
					AND V45.V45_TIPO = '2'
					AND %Exp:cWhere%
					AND V45.%notdel%
			) TAB
		EndSQL		
	EndIf

	( cAliasMax )->( DBGoTop() )

	If ( cAliasMax )->( !Eof() )
		If ( cAliasMax )->MAX_LINE > nRegFim
			lHasNext := .T.
		EndIf
	EndIf

	( cAliasMax )->( DBCloseArea() )

Return( lHasNext )

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadSM0BaseCNPJ
@type			function
@description	Busca as Filias com a mesma Raiz de CNPJ.
@author			Felipe C. Seolin
@since			09/12/2019
@return			aFilial	-	Filiais com a mesma Raiz de CNPJ da Filial logada
/*/
//---------------------------------------------------------------------
Static Function LoadSM0BaseCNPJ()

	Local cBaseCNPJ	:=	Left( AllTrim( Posicione( "SM0", 1, cEmpAnt + cFilAnt, "M0_CGC" ) ), 8 )
	Local nI		:=	0
	Local nPos		:=	0
	Local aGroup	:=	{}
	Local aSM0		:=	FWLoadSM0( .T.,,.T. )
	Local aFilial	:=	{}

	For nI := 1 to Len( aSM0 )
		//---------------------------------------------------------------------------
		//Desconsidera Empresa não autorizada e Filiais que o usuário não tem acesso
		//---------------------------------------------------------------------------
		//If !aSM0[nI][SM0_EMPOK] .or. !aSM0[nI][SM0_USEROK]
		//	Loop
		//EndIf

		If cBaseCNPJ == AllTrim( Left( aSM0[nI][SM0_CGC], 8 ) )
			If aSM0[nI][SM0_GRPEMP] <> cEmpAnt
				If Len( aGroup ) == 0
					aAdd( aGroup, aSM0[nI][SM0_GRPEMP] )

					If !IsShared( cEmpAnt, aSM0[nI][SM0_GRPEMP] )
						Loop
					EndIf
				Else
					nPos := aScan( aGroup, {|x| x == aSM0[nI][SM0_GRPEMP] } )

					If nPos == 0
						aAdd( aGroup, aSM0[nI][SM0_GRPEMP] )

						If !IsShared( cEmpAnt, aSM0[nI][SM0_GRPEMP] )
							Loop
						EndIf
					EndIf
				EndIf
			EndIf

			aAdd( aFilial, aSM0[nI][SM0_CODFIL] )
		EndIf
	Next nI

Return( aFilial )

//---------------------------------------------------------------------
/*/{Protheus.doc} IsShared
@type			function
@description	Informa se alguma tabela do escopo eSocial está com o Grupo de Empresa compartilhado.
@author			Felipe C. Seolin
@since			09/12/2019
@param			cGrpLogged		-	Grupo de Empresa logada
@param			cGrpSameRoot	-	Grupo de Empresa que possui Filiais com Raiz de CNPJ iguais a Empresa logada
@return			lShared			-	Indica se o Grupo de Empresa comparado está compartilhado, ou seja, possui alguma tabela relacionada ao eSocial com o X2_ARQUIVO apontando para a tabela da Filial logada.
/*/
//---------------------------------------------------------------------
Static Function IsShared( cGrpLogged, cGrpSameRoot )

	Local lShared	:=	.F.

	lShared := StartJob( "TAFCSX2Share", GetEnvServer(), .T., cGrpLogged, cGrpSameRoot )

Return( lShared )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRHValues
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			oJson		-	Objeto contendo as informações de busca dos valores, além de ser retornado por referência
@param			cPeriod		-	Período de Geração do relatório
@param			cTribute	-	1 - INSS | 2 - FGTS
@param			lGrvRH		-	Indica se deve gravar a tabela com os valores de RH

@return			Nil
/*/
//---------------------------------------------------------------------
Static Function GetRHValues(oJson, cPeriod, cTribute, lGrvRH, cIDV3J, cCompanyID, aHeader, aCPFCabec, lAnalytic, aRHValues)

	Local aSM0			:= {}
	Local aEstab		:= {}
	Local aLotation		:= IIf(oJson <> Nil .And. oJson["lotationCode"] <> Nil, oJson["lotationCode"], {})
	Local aCPF			:= IIf(oJson <> Nil .And. oJson["cpfNumber"] <> Nil, oJson["cpfNumber"], {})
	Local aMatric		:= IIf(oJson <> Nil .And. oJson["eSocialRegistration"] <> Nil, oJson["eSocialRegistration"], {})
	Local aCateg		:= IIf(oJson <> Nil .And. oJson["eSocialCategory"] <> Nil, oJson["eSocialCategory"], {})
	Local cTicket		:= ""
	Local cError		:= ""
	Local cPath			:= "/api/rh/esocial/v1/reportEsocialBaseConfer"
	Local cURLErp		:= GetNewPar("MV_TAFRHUR")
	Local lIsFinish		:= .F.
	Local lHasNext		:= .T.
	Local nPage			:= 0
	Local nX			:= 0
	Local nZ			:= 0
	Local oResponse		:= Nil

	Default aCPFCabec 	:= {}
	Default aRHValues	:= {}
	Default lAnalytic 	:= .F.
	Default lGrvRh 		:= .F.

	If cTribute == "1"
		aSM0	:= FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_TPINSC"}) 
		aNrInsc := IIf(oJson <> Nil .And. oJson["registrationNumber"] <> Nil, oJson['registrationNumber'], {})
		
		For nZ := 1 To Len(aNrInsc)
			If AllTrim(Str(aSM0[1][2])) $ "1|3" .And. Len(AllTrim(aNrInsc[nZ])) == 14
				AAdd(aEstab, TpInscPic("3", aNrInsc[nZ]))
			ElseIf Len(AllTrim(aNrInsc[nZ])) == 14
				AAdd(aEstab, TpInscPic("1", aNrInsc[nZ]))
			ElseIf Len(AllTrim(aNrInsc[nZ])) == 11
				AAdd(aEstab, TpInscPic("2", aNrInsc[nZ]))
			ElseIf Len(AllTrim(aNrInsc[nZ])) == 12
				AAdd(aEstab, TpInscPic("4", aNrInsc[nZ]))
			EndIf
		Next 
	Else
		aEstab := IIf(oJson <> Nil .And. oJson["branchId"] <> Nil, oJson['branchId'], {})
	EndIf
	
	// Solicitação de Cálculo dos valores
	cTicket	:= CallInit(cURLErp, cPath, cCompanyID, cPeriod, aLotation, aCPF, aMatric, aEstab, aCateg, cTribute, @cError, aHeader,aCPFCabec)
	
	If !Empty(cTicket)
		
		// Fica consultando até a API retornar que o processamento foi finalizado
		lIsFinish := IsFinished(cURLErp, cPath, cTicket, cIDV3J, aHeader)
		While !lIsFinish
			lIsFinish := IsFinished(cURLErp, cPath, cTicket, cIDV3J, aHeader)
		EndDo

		If lGrvRH

			If lAnalytic
				While lHasNext
					oResponse := GetResult(cURLErp, cPath, cCompanyID, cTicket, cTribute, nPage, aHeader, "InssValues")
					
					For nX := 1 To Len(oResponse["items"])
						aAdd(aRHValues,oResponse["items"][nX] )
					Next

					lHasNext := oResponse["hasNext"]
					FreeObj(oResponse)
				EndDo
			Else

				dbSelectArea("V5H")

				While lHasNext
					nPage++
					oResponse := GetResult(cURLErp, cPath, cCompanyID, cTicket, cTribute, nPage, aHeader)

        			If Len(oResponse["items"]) > 0
						CreateV5H(oResponse, cIDV3J, cTribute)
					EndIf

					lHasNext := oResponse["hasNext"]

					FreeObj(oResponse)
				EndDo

				V5H->( dbCloseArea() )
			EndIf
		Else
			oResponse := GetResult(cURLErp, cPath, cCompanyID, cTicket, cTribute,, aHeader)
			UpdResponse(@oJson, oResponse, cTribute)
		EndIf

		FreeObj(oResponse)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CallInit
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			cURLErp		-	URL do ERP
@param			cPath		-	Path principal para o Endpoint
@param			cCompanyID	-	Código da empresa no software de RH
@param			cPeriod		-	Período
@param			cLotation	-	Lotação
@param			cCPF		-	CPF
@param			cMatric		-	Matricula
@param			cEstab		-	Estabelecimento
@param			cCateg		- 	Categoria
@param			cTribute	- 	1 - INSS | 2 - FGTS
@param			cError		-	Retorna mensagem de erro por referência
@param			aHeader		-	Cabeçalho da requisição

@return			cTicket		-	Código do Ticket que o ERP retornou
/*/
//---------------------------------------------------------------------
Static Function CallInit(cURLErp, cPath, cCompanyID, cPeriod, aLotation, aCPF, aMatric, aEstab, aCateg, cTribute, cError, aHeader, aCPFCabec)

	Local cTicket	:= ""
	Local oRest 	:= FWRest():New(cURLErp)
	Local oRequest	:= JsonObject():New()
	Local oResponse	:= JsonObject():New()

	oRest:SetPath(cPath)
	
	oRequest["companyId"]		:= cCompanyID
	oRequest["paymentPeriod"]	:= StrTran(cPeriod, "-", "")
	oRequest["tribute"]			:= cTribute

	If ValType(aEstab) <> "U" .And. ValType(aEstab) == "A"
		oRequest["registrationNumber"] := aEstab
	EndIf

	If ValType(aLotation) <> "U" .And. ValType(aLotation) == "A"
		oRequest["lotationCode"] := aLotation
	EndIf

	If ValType(aCateg) <> "U" .And. ValType(aCateg) == "A"
		oRequest["eSocialCategory"] := aCateg
	EndIf

	If ValType(aCPF) <> "U" .And. ValType(aCPF) == "A"
		oRequest["cpfNumber"] := aCPF
	ElseIf ValType(aCPF) <> "U" .And. ValType(aCPF) == "C" .And. !Empty(aCPF)
		oRequest["cpfNumber"] := {aCPF}
	ElseIf ValType(aCPFCabec) <> "U" .And. ValType(aCPFCabec) == "A" .And. !Empty(aCPFCabec)
		oRequest["cpfNumber"] := aCPFCabec
	EndIf
	
	If ValType(aMatric) <> "U" .And. ValType(aMatric) == "A"
		oRequest["eSocialRegistration"] := aMatric
	EndIf

	TafConOut(procname() + oRequest:ToJson())

	oRest:SetPostParams(oRequest:ToJson())

	TAFConOut(procname() + ' oRequest:ToJson(): ' + oRequest:ToJson())

	If oRest:Post(aHeader)
		oResponse:FromJson(oRest:GetResult())
		
		cTicket := oResponse["requestId"]
	Else
		TAFConOut("[" + ProcName() + "] " + oRest:GetLastError() + ": Falha na conexão com a API do software de RH. API indisponível: " + cURLErp + cPath)
	EndIf

	FwFreeObj(oRest)
	FwFreeObj(oRequest)
	FwFreeObj(oResponse)

Return cTicket

//---------------------------------------------------------------------
/*/{Protheus.doc} IsFinished
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			cURLErp		-	URL do ERP
@param			cPath		-	Path principal para o Endpoint
@param			cTicket		-	Ticket a ser consultado o percentual
@param			cTicketV3J
@param			aHeader		-	Cabeçalho da requisição

@return			lRet		- 	Indica que a API retornou que o cálculo foi concluído
/*/
//---------------------------------------------------------------------
Static Function IsFinished(cURLErp, cPath, cTicket, cTicketV3J, aHeader)

	Local lRet 			:= .F.
	Local oRest 		:= FWRest():New(cURLErp)
	Local oResponse		:= JsonObject():New()
	Local cEndPoint		:= cPath + "/Status/" + AllTrim(cTicket)
	Local nPercent		:= 0

// Manter compatibilidade com a função SetPercent ...
	Private oModelV3J		:=	FWLoadModel( "TAFA531")

	oRest:SetPath(cEndPoint)

	If oRest:Get(aHeader)
		oResponse:FromJson(oRest:GetResult())
		lRet 		:= oResponse["finished"]
		nPercent	:= (oResponse["percent"] / 3)
		SetPercent( cTicketV3J,,, .T., nPercent, .T. )
	EndIf

	FreeObj(oRest)
	FreeObj(oResponse)
	FreeObj(oModelV3J)

Return(lRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetResult
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			cURLErp		-	URL do ERP
@param			cPath		-	Path principal para o Endpoint
@param			cCompanyID	-	Código do Empresa no software de RH
@param			cTicket		-	Ticket a ser consultado o percentual
@param			cTribute	-	1 - INSS | 2 - FGTS
@param			nPage		-	Página que deverá ser retornada
@param			aHeader		-	Cabeçalho da requisição

@return			Nil
/*/
//---------------------------------------------------------------------
Static Function GetResult(cURLErp, cPath, cCompanyID, cTicket, cTribute, nPage, aHeader, cReport)

	Local oRest 		:= FWRest():New(cURLErp)
	Local oResponse		:= JsonObject():New()
	Local cEndPoint		:= ""
	Local cError			:= ""

	Default cReport		:= Iif(cTribute == "1", "InssRetValues", "FgtsValues")

	Default nPage := 1

	cEndPoint	:= cPath + "/" + cReport + "?companyId=" + cCompanyID + "&requestId=" +;
		AllTrim(cTicket) + "&page=" + cValToChar(nPage) + "&pageSize=50"

	oRest:SetPath(cEndPoint)

	If oRest:Get(aHeader)
		oResponse:FromJson(oRest:GetResult())
	Else
		cError := "Erro ao retornar os valores da FOLHA. " + oRest:GetLastError()
		TAFConOut(procname() + cError)
		oResponse["hasNext"] := .F.
		oResponse["items"]   := {}
	EndIf

	FreeObj(oRest)

Return(oResponse)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetHeader
@type			Static function
@description	Retorna o Header das requisições
@author			Victor A. Barbosa
@since			22/11/2019

@return			aHeader - Header das Requisições
/*/
//---------------------------------------------------------------------
Static Function GetHeader()

	Local aHeader 	:= {}
	Local cUser		:= GetNewPar("MV_TAFRHLG")
	Local cPass		:= GetNewPar("MV_TAFRHPW")

	aAdd(aHeader, "Content-Type: application/json")
	Aadd(aHeader, "Authorization: Basic " + Encode64(cUser+":"+cPass) )

Return(aHeader)

//---------------------------------------------------------------------
/*/{Protheus.doc} UpdResponse
@type			Static function
@description	Atualiza o JSON de retorno e devolve por referência
@author			Victor A. Barbosa
@since			26/11/2019
@param			oJson		-	Objeto JSON que será atualizado e retornado por referência
@param			oResponse	-	Objeto com a resposta do software de RH
@param			cTribute	-	1 - INSS | 2 - FGTS

@return
/*/
//---------------------------------------------------------------------
Static Function UpdResponse(oJson, oResponse, cTribute)

	Local nX			:= 0
	Local nPosKey		:= 0
	Local aBasis		:= {}
	Local cBranchID		:= ""

	If Len(oResponse["items"]) > 0
		If cTribute == "1"
			oJson["inssBasis"]		:= oResponse["items"][1]["inssBasis"]
			oJson["inss13Basis"]	:= oResponse["items"][1]["inss13Basis"]
		ElseIf cTribute == "2"

			aBasis := oResponse["items"][1]["basis"]
			For nX := 1 To Len(aBasis)

				cBranchID := StrTran(aBasis[nX]["branchId"], ".", "")
				cBranchID := StrTran(cBranchID, "/", "")
				cBranchID := StrTran(cBranchID, "-", "")

				nPosKey	:= aScan( oJson["basis"],;
					{ |x| AllTrim(x["lotationCode"]) + AllTrim(x["branchId"]) == aBasis[nX]["lotationCode"] + cBranchID } )

				If nPosKey > 0
					oJson["basis"][nPosKey]["fgtsBasis"]			:= aBasis[nX]["fgtsBasis"]
					oJson["basis"][nPosKey]["fgts13Basis"]			:= aBasis[nX]["fgts13Basis"]
					oJson["basis"][nPosKey]["fgtsRescissionBasis"]	:= aBasis[nX]["fgtsRescissionBasis"]
				EndIf

				nPosKey := 0
			Next nX
		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateV5H
@type			Static function
@description	Gravação da Tabela V5H com os valores do software de RH
@author			Victor A. Barbosa
@since			27/11/2019
@param			oResponse	-	Objeto JSON contendo o retorno do software de RH
@param			cTicket	 	-	ID da V3J
@param			cTribute	-	1 - INSS | 2 - FGTS

@return
/*/
//---------------------------------------------------------------------
Static Function CreateV5H(oResponse, cTicket, cTribute)

	Local nX 			:= 0
	Local nY			:= 0
	Local nTamCateg 	:= GetSX3Cache("V5H_CATEG", "X3_TAMANHO")
	Local nTamEstab 	:= GetSX3Cache("V5H_ESTABE", "X3_TAMANHO")
	Local nTamLotac 	:= GetSX3Cache("V5H_LOTACA", "X3_TAMANHO") 
	Local nTamMatric	:= GetSX3Cache("V5H_MATRIC", "X3_TAMANHO") 
	Local nTamCPF		:= GetSX3Cache("V5H_CPF", "X3_TAMANHO")
	Local cCateg		:= PadR("", nTamCateg)
	Local cEstab		:= PadR("", nTamEstab)
	Local cLotacao		:= PadR("", nTamLotac)
	Local cMatric		:= PadR("", nTamMatric)
	Local cCPF			:= PadR("", nTamCPF) 

	If cTribute == "1"
		For nX := 1 To Len(oResponse["items"])

			cEstab		:= PadR(cValToChar(oResponse["items"][nX]["branchId"]), nTamEstab)	
			cCateg		:= PadR(cValToChar(oResponse["items"][nX]["esocialCategory"]), nTamCateg)	
			cLotacao	:= PadR(oResponse["items"][nX]["lotationCode"], nTamLotac)
			cMatric		:= PadR(oResponse["items"][nX]["esocialRegistration"], nTamMatric)
			cCPF		:= PadR(oResponse["items"][nX]["cpfNumber"], nTamCPF)
		
			If !V5H->(MsSeek(xFilial("V5H") + cTicket + cCPF + cCateg + cEstab + cLotacao + cMatric + cTribute))
				If RecLock("V5H", .T.)
					V5H->V5H_FILIAL	:= xFilial("V5H")
					V5H->V5H_ID    	:= cTicket
					V5H->V5H_CPF   	:= cCPF
					V5H->V5H_NOME	:= oResponse["items"][nX]["name"]
					V5H->V5H_MATRIC	:= cMatric
					V5H->V5H_CATEG	:= cCateg
					V5H->V5H_ESTABE	:= cEstab
					V5H->V5H_LOTACA	:= cLotacao
					V5H->V5H_BSINSS	:= oResponse["items"][nX]["inssBasis"]
					V5H->V5H_VLINSS	:= oResponse["items"][nX]["inssGrossValue"]
					V5H->V5H_VLFAM 	:= oResponse["items"][nX]["familySalaryValue"]
					V5H->V5H_VLMAT 	:= oResponse["items"][nX]["maternitySalaryValue"]
					V5H->V5H_BS13  	:= oResponse["items"][nX]["inss13Basis"]
					V5H->V5H_VL13  	:= oResponse["items"][nX]["inss13GrossValue"]
					V5H->V5H_VLMT13	:= oResponse["items"][nX]["maternitySalary13Value"]
					V5H->V5H_TIPO	:= cTribute
					
					V5H->(MsUnlock())
				EndIf
			EndIf
		Next nX
	Else
		For nX := 1 To Len(oResponse["items"])

			For nY := 1 To Len(oResponse["items"][nX]["basis"])

				cCateg		:= PadR( cValToChar(oResponse["items"][nX]["esocialCategory"]), nTamCateg )
				cEstab		:= PadR( GetBranchID(oResponse["items"][nX]["basis"][nY]["branchId"]), nTamEstab )
				cLotacao	:= PadR( oResponse["items"][nX]["basis"][nY]["lotationCode"], nTamLotac )
				cMatric		:= PadR( oResponse["items"][nX]["esocialRegistration"], nTamMatric )
				cCPF		:= PadR( oResponse["items"][nX]["cpfNumber"], nTamCPF )

				If !V5H->( MsSeek( xFilial("V5H") + cTicket + cCPF + cCateg + cEstab + cLotacao + cMatric + cTribute ) )
					RecLock("V5H", .T.)
					V5H->V5H_FILIAL	:= xFilial("V5H")
					V5H->V5H_ID    	:= cTicket
					V5H->V5H_CPF   	:= cCPF
					V5H->V5H_CATEG	:= cCateg
					V5H->V5H_ESTABE	:= cEstab
					V5H->V5H_LOTACA	:= cLotacao
					V5H->V5H_MATRIC	:= cMatric
					V5H->V5H_NOME	:= oResponse["items"][nX]["name"]
					V5H->V5H_VLFGTS	:= oResponse["items"][nX]["fgtsValue"]
					V5H->V5H_VLFG13	:= oResponse["items"][nX]["fgts13Value"]
					V5H->V5H_VLFGRE	:= oResponse["items"][nX]["fgtsRescissionValue"]
					V5H->V5H_BSFGTS	:= oResponse["items"][nX]["basis"][nY]["fgtsBasis"]
					V5H->V5H_BSFG13	:= oResponse["items"][nX]["basis"][nY]["fgts13Basis"]
					V5H->V5H_BSFGRE	:= oResponse["items"][nX]["basis"][nY]["fgtsRescissionBasis"]
					V5H->V5H_TIPO	:= cTribute
					V5H->( MsUnlock() )
				EndIf

			Next nY

		Next nX
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} V5HByTicket
@type			Static function
@description	Retorno da Tabela V5H com os valores do software de RH
@author			Victor A. Barbosa
@since			27/11/2019
@param			cTicket	 	-	ID da V3J
@param			cCPF		-	Filtrar CPF específico
@param			cTribute	-	1 - INSS
								2 - FGTS
								3 - TODOS

@return			cAliasRet	-	Alias com a V5H filtrada
/*/
//---------------------------------------------------------------------
Static Function V5HByTicket(cTicket as character, cCPF as character, cTribute as character) as character

	Local cAliasV5H	as character
	Local cQryCPF	as character 
	Local cFields	as character

	Default cTribute 	:= "3"
	Default cCPF		:= ""	

	cAliasV5H	:= GetNextAlias()	
	cQryCPF		:= "%" + IIf(Empty(cCPF), "IS NOT NULL", "= '" + cCPF + "'")  + "%"
	cFields		:= "V5H_CPF, V5H_NOME, V5H_MATRIC, V5H_CATEG, V5H_ESTABE, V5H_LOTACA" // Campos Id Trabalhador	

	If cTribute $ ("1|3") // Campos INSS
		cFields += ", V5H_BSINSS, V5H_VLINSS, V5H_VLFAM,V5H_VLMAT, V5H_BS13, V5H_VL13, V5H_VLMT13"	
	EndIf	

	If cTribute $ ("2|3") // Campos FGTS
		cFields += ", V5H_VLFGTS, V5H_VLFG13, V5H_VLFGRE, V5H_BSFGTS, V5H_BSFG13, V5H_BSFGRE"		
	EndIf

	cFields		:= "%" + cFields + "%"	

	If Select(cAliasV5H) > 0
		(cAliasV5H)->( dbCloseArea() )
	EndIf

	BeginSQL Alias cAliasV5H
		SELECT %Exp:cFields%
		FROM %table:V5H% V5H
		WHERE 	V5H_FILIAL = %xFilial:V5H%
		AND		V5H_ID = %Exp:cTicket%
		AND 	V5H_CPF %Exp:cQryCPF%	
		AND		V5H.%notdel%
	EndSQL

	(cAliasV5H)->( dbGoTop() )

	If (cAliasV5H)->( Eof() )
		cAliasV5H := ""
	EndIf

Return(cAliasV5H)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetBranchID
@type			Static function
@description	Retorna o BranchID formatado
@author			Victor A. Barbosa
@since			29/11/2019
@param			cTicket	 	-	BranchID

@return			cAliasRet	-	BranchID formatado
/*/
//---------------------------------------------------------------------
Static Function GetBranchID(cBranchID)

	Local cBranchRet	:= ""

	cBranchRet := StrTran(cBranchID, ".", "")
	cBranchRet := StrTran(cBranchRet, "/", "")
	cBranchRet := StrTran(cBranchRet, "-", "")

Return(cBranchRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} CheckDiv
@type			Static function
@description	Função para verificar se existe uma divergência ou não no relatório
@author			Diego Santos
@since			15/05/2020
@param			cResponse	 -	V45->V45_RESP

@return			lRet	-	.T. = Existe Divergência no relatório, .F. = Não existe divergência no relatório
/*/
//---------------------------------------------------------------------
Static Function CheckDiv(cResponse)

	Local lRet := .F.
	Local aValores
	Local nCont
	Local aAux

	aValores := StrTokArr( StrTran( StrTran( StrTran( StrTran( StrTran( StrTran( V45->V45_RESP, '"basis":', ""), "]", ""), "[", ""),'"', "") , "{", ""), "}", ""), "," )

	For nCont := 1  To Len(aValores)
		aAux := StrTokArr(aValores[nCont], ":")
		If Len(aAux) > 1
			xValor := aAux[2]
			If !(xValor == "0" .Or. Empty(xValor))
				lRet := .T.
				Exit
			EndIf
		EndIf
	Next nCont

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFilRH
@type			Static function
@description	Realiza o de-para das filiais do TAF com as coligadas do RH
@author			Matheus Prada
@since			23/09/2020
@return			Retorna a filial do RH
/*/
//---------------------------------------------------------------------
Static Function GetFilRH(aHeader)

	Local cAPI		:= "/api/rh/esocial/v1/reportEsocialBaseConfer/company/"
	Local cURLErp	:= GetNewPar("MV_TAFRHUR")
	Local oRest		:= Nil
	Local oResponse	:= Nil
	Local xResponse	:= Nil

	oRest := FWRest():New(cURLErp)
	
	oRest:SetPath(cAPI + StrTran(cEmpAnt, " ", "%20") + StrTran(cFilAnt, " ", "%20"))
	
	If oRest:Get(aHeader)
		oResponse := JsonObject():New()

		oResponse:FromJSON(oRest:GetResult())

		xResponse := oResponse["companyId"]
	Else
		TAFConOut("[" + ProcName() + "] " + oRest:GetLastError() + ": Falha na conexão com a API do software de RH. API indisponível: " + cURLErp + cAPI)
	EndIf

Return xResponse

//---------------------------------------------------------------------
/*/{Protheus.doc} InssRetValues
@type			method
@description	Método para consultar os valores sintéticos do Relatório de conferência de INSS
@author		
@since			
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET InssRetValues QUERYPARAM companyId, requestId, differencesOnly, synthetic, page, pageSize WSRESTFUL reportEsocialBaseConfer

Local oResponse		:=	Nil
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local cRequestID	:=	""
Local cPeriod		:=	""

Local nPage			:=	1
Local nPageSize		:=	15

Local lDiverg		:=	.F.
Local lRet			:=	.T.
Local lIsLegacy		:=	.F.
Local lSynthetic	:=	.F.

Local aCompany		:=	{}
Local aCPFCabec		:=  {}

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:requestId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			lIsLegacy := TAFAlsInDic( "V5H" ) .and. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

			If ValidID( self:requestId, @cPeriod, lIsLegacy, @aCPFCabec )
				cRequestID := self:requestId

				If self:synthetic <> Nil
					lSynthetic := self:synthetic
				EndIf

				If self:differencesOnly <> Nil
					lDiverg := self:differencesOnly
				EndIf

				If self:page <> Nil
					nPage := self:page
				EndIf

				If self:pageSize <> Nil
					nPageSize := self:pageSize
				EndIf

				GetInssRet( @oResponse, cRequestID, lSynthetic,  lDiverg, nPage, nPageSize, cPeriod, lIsLegacy, self:companyId,aCPFCabec)

				self:SetResponse( oResponse:toJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetInssRet
@type			function
@description	Executa a consulta do resultado do relatório de conferência de INSS.
@author			Verônica de Almeida
@since			19/07/2021
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
@param			lSynthetic	-	Indica se o retorno deve ser sintético ou analítico
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			cPeriod		-	Período de emissão do relatório
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@param			cCompanyId - Identificados da empresa e filial
@param			aCPFCabec	- CPFs que serão consultados
/*/
//---------------------------------------------------------------------
Static Function GetInssRet( oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, cPeriod, lIsLegacy, cCompanyId,aCPFCabec )
Local nTamV45_ID	:=	TamSX3( "V45_ID" )[1]
Local aJson			:=	{}
Local lHasNext		:=	.F.

Default aCPFCabec	:= {}

oResponse	:= JsonObject():New()
cRequestID	:= PadR( cRequestID, nTamV45_ID )

DBSelectArea( "V45" )

If lSynthetic
	V45->( DBSetOrder( 2 ) )
	If V45->( MsSeek( xFilial( "V45" ) + cRequestID + "1" + Iif( lDiverg, "1", "2" ) ) )
		If CheckDiv(V45->V45_RESP)
			oJson := JsonObject():New()
			oJson:FromJson( V45->V45_RESP )
			aAdd( aJson, oJson )
			FreeObj( oJson )
		EndIf
	EndIf
Else
	aJson := GetDetails( cRequestID, lDiverg, nPage, nPageSize, @lHasNext, '1', cPeriod, lIsLegacy, cCompanyId, aCPFCabec )
EndIf

oResponse["items"]		:=	aJson
oResponse["hasNext"]	:=	lHasNext
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetINSSVal
Escopo: INSS
Prepara os dados filtrados no formato JSON para retornar ao front.
Chamado na parte assíncrona do relatório
@author Verônica de Almeida
@since 19/07/2021
/*/
//-------------------------------------------------------------------
Static Function GetINSSVal( oReq, cTicket, lIsLegacy )

Local oResponse			:=	Nil
Local oArqTrb			:=	TAFXHMNew()
Local nI				:=	1
Local nINSSOrig			:=	0
Local nINSSTAF			:=	0
Local nINSSGov			:=	0
Local aINSSSint			:=	{ "", "", "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
Local aINSSDivSint		:=	{ "", "", "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
Local aArqTrb			:=	{}
Local aArea				:=	GetArea()
Local lDiverg			:=	.F.
Local lDivergTot		:=	.F.
Local lTransmitido		:=	.F.
Local nFuncDiverg		:= 0
Local nFuncTotal		:= 0

Private oModelV3J		:=	FWLoadModel( "TAFA531" )

//Filtra os dados do INSS e gera o hash
FilINSSRet( oReq, @oArqTrb, cTicket, lIsLegacy )

//Grava o conteúdo dos hashs em arrays
TAFXHMList( oArqTrb, aArqTrb )

//Monta o retorno para a API de INSS
For nI := 1 to Len( aArqTrb )
	oResponse := JsonObject():New()

	lTransmitido := (!Empty( aArqTrb[nI,2,1,RECIBO_TRANSMISSAO] ) ).And. aArqTrb[nI,2,1,GOVERNO_LOCALIZADO]	

	TafConOut(procname() + " lTransmitido: " + Iif( lTransmitido, "true", "false" ) + " CPF: " + aArqTrb[nI,2,1,CPFFUNC] )

	lDiverg		:= .F.
	nINSSOrig	:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS] + aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
	nINSSTAF	:=	aArqTrb[nI,2,1,TAF_VALOR_INSS] + aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
	nINSSGov	:=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE] + aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]

	// Comparo os valores da FOLHA somente se estiver configurado o parâmetro de busca na API do sistema Legado
	If lIsLegacy
		lDiverg		:=	nINSSOrig <> nINSSTAF .or. ; 
									nINSSOrig <> nINSSGov .or. ;				
									nINSSTAF <> nINSSGov .or.;
									aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] .or.;
									aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or.;
									aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or.;
									aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] .or.;
									aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or.;
									aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or.;
									aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or.;
									aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or.;
									aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	Else
		lDiverg		:=	nINSSTAF <> nINSSGov .or.;
									aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or.;
									aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or.;
									aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	EndIf

	If lDiverg

		aINSSDivSint[8]		+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
		aINSSDivSint[10]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
		aINSSDivSint[11]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
		aINSSDivSint[12]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
		aINSSDivSint[13]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]

		If lTransmitido
			aINSSDivSint[21]	+=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE]
			aINSSDivSint[22]	+=	aArqTrb[nI,2,1,GOVERNO_DESC_GROSS_VALUE]
			aINSSDivSint[23]	+=	aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]
			aINSSDivSint[24]	+=	aArqTrb[nI,2,1,GOVERNO_13_DESC_GROSS_VALUE]
			aINSSDivSint[25]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
			aINSSDivSint[26]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
			aINSSDivSint[27]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		EndIf

		aINSSDivSint[15]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS]
		aINSSDivSint[17]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
		aINSSDivSint[18]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA]
		aINSSDivSint[19]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE]
		aINSSDivSint[20]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]

		
		lDivergTot	:=	.T.

		nFuncDiverg++
	EndIf

	oResponse["cpfNumber"]								:=	aArqTrb[nI,2,1,CPFFUNC]
	oResponse["name"]									:=	aArqTrb[nI,2,1,NOMEFUNC]
	oResponse["inssGrossValue"]							:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
	oResponse["inssTafGrossValue"]						:=	aArqTrb[nI,2,1,TAF_VALOR_INSS]
	oResponse["inss13GrossValue"]						:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
	oResponse["inss13TafGrossValue"]					:=	aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
	oResponse["familySalaryValue"]						:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
	oResponse["familySalaryTafValue"]					:=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA]
	oResponse["maternitySalaryValue"]					:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
	oResponse["maternitySalaryTafValue"]				:=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE]
	oResponse["maternitySalary13Value"]					:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	oResponse["maternitySalary13TafRetValue"]			:=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]

	If lTransmitido
		oResponse["familySalaryRetValue"]				:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
		oResponse["maternitySalaryRetValue"]			:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
		oResponse["maternitySalary13RetValue"]			:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]

		oResponse["inssRetGrossValue"]					:=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE]
		oResponse["inssRetDescGrossValue"]				:=	aArqTrb[nI,2,1,GOVERNO_DESC_GROSS_VALUE]
		oResponse["inss13RetGrossValue"]				:=	aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]
		oResponse["inss13DescGrossValue"]				:=	aArqTrb[nI,2,1,GOVERNO_13_DESC_GROSS_VALUE]
	Else
		oResponse["familySalaryRetValue"]				:=	0
		oResponse["maternitySalaryRetValue"]			:=	0
		oResponse["maternitySalary13RetValue"]			:=	0

		oResponse["inssRetGrossValue"]					:=	0									
		oResponse["inssRetDescGrossValue"]				:=	0									
		oResponse["inss13RetGrossValue"]				:=	0								
		oResponse["inss13DescGrossValue"]				:=	0								
	EndIf

	oResponse["divergent"]	:=	lDiverg

	aINSSSint[8]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
	aINSSSint[10]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
	aINSSSint[11]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
	aINSSSint[12]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
	aINSSSint[13]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	aINSSSint[15]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS]
	aINSSSint[17]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
	aINSSSint[18]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA]
	aINSSSint[19]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE]
	aINSSSint[20]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]

	If lTransmitido
		aINSSSint[21]	+=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE]
		aINSSSint[22]	+=	aArqTrb[nI,2,1,GOVERNO_DESC_GROSS_VALUE]
		aINSSSint[23]	+=	aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]
		aINSSSint[24]	+=	aArqTrb[nI,2,1,GOVERNO_13_DESC_GROSS_VALUE]
		aINSSSint[25]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
		aINSSSint[26]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
		aINSSSint[27]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]

		TafConOut(procname() + " Soma: " + cValToChar( aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE] ) + " CPF: " + aArqTrb[nI,2,1,CPFFUNC] )
		TafConOut(procname() + " Acumulado: " + cValToChar( aINSSSint[21] ) + " CPF: " + aArqTrb[nI,2,1,CPFFUNC] )
	Else
		TafConOut(procname() + " Não transmitido: CPF: " + aArqTrb[nI,2,1,CPFFUNC] )
	EndIf

	//Grava a parte analítica
	GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nI, 6 ), lDiverg, "2" )

	SetPercent( cTicket, nI, Len( aArqTrb ),,, .F. )

	nFuncTotal++

Next nI

//Se não encontrou os dados
If Len( aArqTrb ) == 0
	SetPercent( cTicket, 100, 100,,, .F. )
Else
	//Grava a parte sintética
	GrvINSSRetValues( aINSSSint, nFuncTotal, .F.,  nI )
	GrvINSSRetValues( aINSSDivSint, nFuncDiverg, .T., ++nI  )

EndIf

SetFinish( cTicket )

oModelV3J:Destroy()
RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvINSSRetValues
@type			function
@description	Grava a parte sintética do relatório.
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function GrvINSSRetValues( aINSSSint, nEmployees, lDivergTot, nSeq)

Local oResponse	:=	JsonObject():New()

oResponse["cpfNumber"]							:=	aINSSSint[1]
oResponse["name"]								:=	aINSSSint[2]
oResponse["inssGrossValue"]						:=	aINSSSint[8]
oResponse["inss13GrossValue"]					:=	aINSSSint[10]
oResponse["familySalaryValue"]					:=	aINSSSint[11]
oResponse["maternitySalaryValue"]				:=	aINSSSint[12]
oResponse["maternitySalary13Value"]				:=	aINSSSint[13]
oResponse["inssTafGrossValue"]					:=	aINSSSint[15]
oResponse["inss13TafGrossValue"]				:=	aINSSSint[17]
oResponse["familySalaryTafValue"]				:=	aINSSSint[18]
oResponse["maternitySalaryTafValue"]			:=	aINSSSint[19]
oResponse["maternitySalary13TafRetValue"]		:=	aINSSSint[20]
oResponse["inssRetGrossValue"]					:=	aINSSSint[21]
oResponse["inssRetDescGrossValue"]				:=	aINSSSint[22]
oResponse["inss13RetGrossValue"]				:=	aINSSSint[23]
oResponse["inss13DescGrossValue"]				:=	aINSSSint[24]
oResponse["familySalaryRetValue"]				:=	aINSSSint[25]
oResponse["maternitySalaryRetValue"]			:=	aINSSSint[26]
oResponse["maternitySalary13RetValue"]			:=	aINSSSint[27]

GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDivergTot, "1" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InssValues
@type			method
@description	Método responsável por retornar os valores analíticos do painel de INSS
@author			Verônica de Almeida
@since			19/07/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET InssValues QUERYPARAM companyId, requestId, synthetic, differencesOnly, cpfNumber, page, pageSize WSRESTFUL reportEsocialBaseConfer

Local oResponse			as object
Local oReqV3J 			as object
Local cEmpRequest		as character
Local cFilRequest		as character
Local cRequestID		as character
Local cPeriod			as character
Local lRet				as logical
Local aCompany			as array

oResponse   := Nil
oReqV3J     := JsonObject():New()
cEmpRequest := ""
cFilRequest := ""
cRequestID  := ""
cPeriod     := ""
lRet        := .T.
aCompany    := {}

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:requestId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
ElseIf self:synthetic == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Tipo de relatório Sintético ou Analítico não informado no parâmetro 'synthetic'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )

			If ValidID( self:requestId, @cPeriod, .F. )
				cRequestID := self:requestId

				If V3J->(MsSeek(xFilial("V3J") + PadR(cRequestID, GetSX3Cache("V3J_ID", "X3_TAMANHO"))))
					oReqV3J:FromJson(V3J->V3J_PARAMS)

					cPeriod 	:= oReqV3J["paymentPeriod"]
					lIsLegacy 	:= TAFAlsInDic("V5H") .And. !Empty(AllTrim(GetNewPar("MV_TAFRHUR", "")))

					If GetINSSVaData(::self, cRequestID, cPeriod, @oResponse, lIsLegacy)
						TafConOut(procname() + oResponse:toJson())
						self:SetResponse( oResponse:toJson() )
					Else
						SetRestFault( 400, EncodeUTF8( "Empresa|Filial não encontrado no complemento cadastral." ) )
					EndIf
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetINSSVaData
@type			function
@description	Retorna os registros analíticos.
@author			Verônica de Almeida
@since			19/07/2021
@param			oReq	-	
@param			cTicket	-	
@param			cPeriod		-	Período de emissão do relatório
@param			oResponse		-	
@return			lRet		-	Json com o resultado processado para o relatório
/*/
//---------------------------------------------------------------------
Static Function GetINSSVaData(oReq as json, cTicket as character, cPeriod as character, oResponse as json, lIsLegacy as logical)

	Local aArea			as array
	Local aArqTrb		as array
	Local aJson			as array
	Local oJson 		as object
	Local oArqTrb		as object
	Local nI			as numeric
	Local nINSSOri		as numeric
	Local nINSSTAF		as numeric
	Local nINSSGov		as numeric
	Local nArqTrb		as numeric
	Local lRet			as logical
	Local lDiverg		as logical
	Local lTransmitido	as logical
	Local lOnlyDiff		as logical

	Default cPeriod		:= ""
	Default cTicket 	:= ""
	Default lIsLegacy	:= .F.
	Default oResponse 	:= JsonObject():New()
	Default oReq 		:= JsonObject():New()
	
	aArqTrb			:= {}
	aJson			:= {}
	aArea			:= GetArea()
	nI				:= 0
	nINSSOri		:= 0
	nINSSTAF		:= 0
	nINSSGov		:= 0
	nArqTrb			:= 0		
	lRet			:= .T.
	lDiverg			:= .F.
	lTransmitido	:= .F.
	lOnlyDiff		:= IIf(oReq["differencesOnly"] == Nil, .F., oReq["differencesOnly"])
	oJson 			:= Nil
	oArqTrb			:= TAFXHMNew()

	FilInssValues(oReq, @oArqTrb, cPeriod, lIsLegacy)
	TAFXHMList(oArqTrb, aArqTrb)

	nArqTrb := Len(aArqTrb)

	For nI := 1 To nArqTrb
		lTransmitido	:= !Empty(aArqTrb[nI][2][1][RECIBO_TRANSMISSAO]) .And. aArqTrb[nI][2][1][GOVERNO_LOCALIZADO]		
		oJson 			:= JsonObject():New()

		nINSSGov 		:= aArqTrb[nI][2][1][GOVERNO_GROSS_VALUE] + aArqTrb[nI][2][1][GOVERNO_13_GROSS_VALUE]

		If nI < nArqTrb .And. aArqTrb[nI][2][1][CPFFUNC] == aArqTrb[nI + 1][2][1][CPFFUNC]
			nINSSTAF	:= aArqTrb[nI][2][1][TAF_VALOR_INSS] + aArqTrb[nI][2][1][TAF_VALOR_INSS_13_SALARIO] +; 
							aArqTrb[nI + 1][2][1][TAF_VALOR_INSS] + aArqTrb[nI + 1][2][1][TAF_VALOR_INSS_13_SALARIO]

			nINSSOrig	:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS] + aArqTrb[nI][2][1][FOLHA_VALOR_INSS_13_SALARIO] +;
							aArqTrb[nI + 1][2][1][FOLHA_VALOR_INSS] + aArqTrb[nI + 1][2][1][FOLHA_VALOR_INSS_13_SALARIO]
		ElseIf nI == 1 .Or. aArqTrb[nI][2][1][CPFFUNC] != aArqTrb[nI - 1][2][1][CPFFUNC]
			nINSSTAF	:= aArqTrb[nI][2][1][TAF_VALOR_INSS] + aArqTrb[nI][2][1][TAF_VALOR_INSS_13_SALARIO]
			nINSSOrig	:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS] + aArqTrb[nI][2][1][FOLHA_VALOR_INSS_13_SALARIO]			
		EndIf

		If lIsLegacy
			lDiverg := nINSSOrig <> nINSSTAF .Or.; 
						nINSSOrig <> nINSSGov .Or.; 
						nINSSTAF <> nINSSGov .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		Else
			lDiverg := nINSSTAF <> nINSSGov .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		EndIf
		
		If !lOnlyDiff .Or. (lOnlyDiff .And. lDiverg)
			oJson["cpfNumber"]						:= aArqTrb[nI][2][1][CPFFUNC]
			oJson["name"]							:= EncodeUTF8(aArqTrb[nI][2][1][NOMEFUNC])
			oJson["branchId"]						:= aArqTrb[nI][2][1][ESTABELECIMENTO]
			oJson["lotationCode"]					:= aArqTrb[nI][2][1][LOTAC]
			oJson["esocialCategory"]				:= aArqTrb[nI][2][1][CAT_DESCRI]
			oJson["esocialRegistration"]			:= aArqTrb[nI][2][1][MATRIC]

			oJson["inssValue"]						:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS]
			oJson["inssTafValue"]					:= aArqTrb[nI][2][1][TAF_VALOR_INSS]
			oJson["inss13Value"]					:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS_13_SALARIO]
			oJson["inss13TafValue"]					:= aArqTrb[nI][2][1][TAF_VALOR_INSS_13_SALARIO]
			oJson["inssBasis"]						:= aArqTrb[nI][2][1][FOLHA_BASE_INSS]
			oJson["inssTafBasis"]					:= aArqTrb[nI][2][1][TAF_BASE_INSS]
			oJson["familySalaryValue"]				:= aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_FAMILIA]
			oJson["familySalaryTafValue"]			:= aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA]
			oJson["maternitySalaryValue"]			:= aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE]
			oJson["maternitySalaryTafValue"]		:= aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE]
			oJson["inss13Basis"]					:= aArqTrb[nI][2][1][FOLHA_BASE_INSS_13_SALARIO]
			oJson["inss13TafBasis"]					:= aArqTrb[nI][2][1][TAF_BASE_INSS_13_SALARIO]
			oJson["maternitySalary13Value"]			:= aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			oJson["maternitySalary13TafRetValue"]	:= aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]

			If lTransmitido
				oJson["inssRetValue"]				:= aArqTrb[nI][2][1][GOVERNO_VALOR_INSS]
				oJson["inss13RetValue"]				:= aArqTrb[nI][2][1][GOVERNO_VALOR_INSS_13_SALARIO]
				oJson["inssRetBasis"]				:= aArqTrb[nI][2][1][GOVERNO_BASE_INSS]
				oJson["inssRetSuspJudBasis"]		:= aArqTrb[nI][2][1][GOVERNO_BASE_SUSPENSAO]
				oJson["inssRetTotalBasis"]			:= aArqTrb[nI][2][1][GOVERNO_BASE_TOTAL_INSS]
				oJson["familySalaryRetValue"]		:= aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA]
				oJson["maternitySalaryRetValue"]	:= aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE]
				oJson["inss13RetBasis"]				:= aArqTrb[nI][2][1][GOVERNO_BASE_INSS_13_SALARIO]
				oJson["maternitySalary13RetValue"]	:= aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	
				oJson["inssRetGrossValue"]			:= aArqTrb[nI][2][1][GOVERNO_GROSS_VALUE]									
				oJson["inssRetDescGrossValue"]		:= aArqTrb[nI][2][1][GOVERNO_DESC_GROSS_VALUE]									
				oJson["inss13RetGrossValue"]		:= aArqTrb[nI][2][1][GOVERNO_13_GROSS_VALUE]								
				oJson["inss13DescGrossValue"]		:= aArqTrb[nI][2][1][GOVERNO_13_DESC_GROSS_VALUE]		
			Else
				oJson["inssRetValue"]				:= 0
				oJson["inss13RetValue"]				:= 0
				oJson["inssRetBasis"]				:= 0
				oJson["inssRetSuspJudBasis"]		:= 0
				oJson["inssRetTotalBasis"]			:= 0			
				oJson["familySalaryRetValue"]		:= 0
				oJson["maternitySalaryRetValue"]	:= 0
				oJson["inss13RetBasis"]				:= 0
				oJson["maternitySalary13RetValue"]	:= 0
			
				oJson["inssRetGrossValue"]			:= 0									
				oJson["inssRetDescGrossValue"]		:= 0									
				oJson["inss13RetGrossValue"]		:= 0								
				oJson["inss13DescGrossValue"]		:= 0	
			EndIf

			oJson["inconsistent"] := lDiverg

			AAdd(aJson, oJson)
		EndIf

		FreeObj(oJson)
	Next

	oResponse["items"]		:= aJson
	oResponse["hasNext"]	:= .F.

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FilINSSRet
@type			function
@description	Filtra os dados e carrega no hash
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilINSSRet( oReq, oArqTrb, cTicket, lIsLegacy )

	Local cAlias		   	:= GetNextAlias()
	Local nQtdRegs			:= 0
	Local nBasINSS			:= 0
	Local nRessInss			:= 0
	Local nVlINSS			:= 0
	Local nSalFam			:= 0
	Local nSalMat			:= 0
	Local nBasINSS13		:= 0
	Local nVlINSS13			:= 0
	Local nSalMat13			:= 0
	Local nRetValue			:= 0
	Local nRetDescValue		:= 0
	Local nRet13Value		:= 0
	Local nRet13DescValue	:= 0
	Local nRegistro			:= 0
	Local nItem       		:= 0
	Local lAdd				:= .F.

	Default cPeriod 		:= ''

	// Retorna as filiais do TAF referente a Matriz logada
	cFilSel := TAFCacheFil("V3N", FilMatriz(), .T.)

	// Faz consulta do banco
	nQtdRegs := FilInssSynthetic(@cAlias, cFilSel, oReq)

	While (cAlias)->( !Eof() )

		nRegistro++

		lAdd := CalcValor(@cAlias,@nRessInss,@nVlINSS,@nVlINSS13,@nBasINSS,@nSalFam,@nSalMat,@nSalMat13,@nBasINSS13,@nRetValue,@nRetDescValue,@nRet13Value,@nRet13DescValue,.T.)
		TafConOut(procname() + " Apos CalcValor nRetValue: " + cValtoChar( nRetValue ) )

		If lAdd
			// Carrega o Hash
			LoadHash('SINTETICO',cAlias,oArqTrb,@nRessInss,@nVlINSS,@nVlINSS13,@nBasINSS,@nSalFam,@nSalMat,@nSalMat13,@nBasINSS13,@nRetValue,@nRetDescValue,@nRet13Value,@nRet13DescValue)
			TafConOut(procname() + " Apos LoadHash nRetValue: " + cValtoChar( nRetValue ) )
		EndIf

		nItem++

		setPercent(cTicket, nItem, nQtdRegs,,, lIsLegacy)

		(cAlias)->( dbSkip() )

	EndDo

	If lIsLegacy
		LoadHashLegacy(cTicket,oArqTrb)
	EndIf

	If nRegistro == 0
		setPercent(cTicket, 100, 100,,, lIsLegacy)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilInssValues
@type			function
@description	Filtra os dados e carrega no hash
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilInssValues(oReq as json, oArqTrb as object, cPeriod as character, lIsLegacy as logical)

	Local aHeader			as array
	Local aRHValues			as array
	Local cAlias    		as character
	Local cFilRH			as character
	Local cCPF				as character
	Local cTicket			as character
	Local nQtdRegs			as numeric
	Local nBasINSS			as numeric
	Local nVlINSS			as numeric
	Local nRessInss			as numeric
	Local nSalFam			as numeric
	Local nSalMat			as numeric
	Local nBasINSS13		as numeric
	Local nVlINSS13			as numeric
	Local nSalMat13			as numeric
	Local nRetValue			as numeric
	Local nRetDescValue		as numeric
	Local nRet13Value		as numeric
	Local nRet13DescValue	as numeric
	lOCAL nBasSusJud 		as numeric
	Local nX				as numeric

	Default cPeriod 		:= ""
	Default lIsLegacy		:= .F.
	Default oArqTrb			:= Nil
	Default oReq			:= JsonObject():New()

	aHeader			:= {}
	aRHValues		:= {}
	cAlias    		:= ""
	cFilRH			:= ""
	cCPF			:= IIf(oReq["cpfNumber"] == Nil, "", oReq["cpfNumber"])
	cTicket			:= IIf(oReq["requestId"] == Nil, "", oReq["requestId"])
	nBasINSS		:= 0
	nVlINSS			:= 0
	nRessInss		:= 0
	nSalFam			:= 0
	nSalMat			:= 0
	nBasINSS13		:= 0
	nVlINSS13		:= 0
	nSalMat13		:= 0
	nRetValue		:= 0
	nRetDescValue	:= 0
	nRet13Value		:= 0
	nRet13DescValue	:= 0
	nBasSusJud		:= 0
	nX				:= 0
	nQtdRegs 		:= FilInssAnalytic(@cAlias, cCPF, cPeriod, cTicket)

	While !(cAlias)->(EOF())
		If CalcValor(cAlias, @nRessInss, @nVlINSS, @nVlINSS13, @nBasINSS, @nSalFam, @nSalMat, @nSalMat13, @nBasINSS13, @nRetValue, @nRetDescValue, @nRet13Value, @nRet13DescValue, .T., .T., @nBasSusJud)
			LoadHash("ANALITICO", cAlias, oArqTrb, @nRessInss, @nVlINSS, @nVlINSS13, @nBasINSS, @nSalFam, @nSalMat, @nSalMat13, @nBasINSS13, @nRetValue, @nRetDescValue, @nRet13Value, @nRet13DescValue,, @nBasSusJud)
		EndIf

		(cAlias)->(DBSkip())
	EndDo

	If lIsLegacy		
		aRhValues := V5HGetRhValues(cTicket, cCPF)

		For nX := 1 To Len(aRHValues)
			LoadHash("RH", cAlias, oArqTrb, @nRessInss, @nVlINSS, @nVlINSS13, @nBasINSS, @nSalFam, @nSalMat, @nSalMat13, @nBasINSS13, @nRetValue, @nRetDescValue, @nRet13Value, @nRet13DescValue, aRHValues[nX])
		Next
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilInssSynthetic
@type			function
@description	Realiza select no banco para a visão sintética - InssRetValues
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilInssSynthetic(cAlias as character, cFilSel as character, oReq as json)
	
	Local aFiliais		as array
	Local aModoAcess	as array
	Local aLotacao   	as array 
	Local aCategoria	as array 
	Local aEstabe     	as array
	Local aMats			as array
	Local cPeriodo		as character
	Local cJoinT2Q		as character
	Local cWhere		as character
	Local cWhereT2M		as character
	Local cColumnTemp   as character
	Local cBanco		as character
	Local lRetInss 		as logical
	Local nRet			as numeric
	Local xCPFs			as variant
	
	Default cFilSel		:= ""
	Default	cAlias		:= GetNextAlias()
	Default oReq		:= JsonObject():New()

	aFiliais	:= {}
	aModoAcess	:= {}
	aLotacao    := IIf(oReq["lotationCode"] == Nil, {}, oReq["lotationCode"])
	aCategoria	:= IIf(oReq["eSocialCategory"] == Nil, {}, oReq["eSocialCategory"])
	aEstabe     := IIf(oReq["registrationNumber"] == Nil, {}, oReq["registrationNumber"])
	xCPFs		:= IIf(oReq["cpfNumber"] == Nil, {}, oReq["cpfNumber"])
	aMats		:= IIf(oReq["eSocialRegistration"] == Nil, {}, oReq["eSocialRegistration"])
	cPeriodo	:= oReq["paymentPeriod"]
	cJoinT2Q	:= ""
	cWhere		:= ""
	cWhereT2M	:= ""
	cColumnTemp := ""
	cBanco		:= Upper(TcGetDb())
	lRetInss 	:= IIf(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F.)
	nRet		:= 0

	// Deixamos de buscar na V3N os valores de folha (origem 1), pois serão retornados do ERP de Origem
	// cWhere += " (	V3N_ORIGEM = '3' OR ( V3N_ORIGEM IN ('1','2') AND ( (V3N_NATRUB = '9201' AND V3N_ITCP = '31') "
	cWhere += " (	V3N_ORIGEM = '3' OR ( V3N_ORIGEM = '2' AND ( (V3N_NATRUB = '9201' AND V3N_ITCP = '31') "
	cWhere += "						  OR  (V3N_NATRUB = '9201' AND V3N_ITCP = '32') "
	cWhere += "						  OR  (V3N_NATRUB = '9901' AND V3N_TPRUBR = '3') "
	cWhere += "						  OR  (V3N_NATRUB = '1409' AND V3N_ITCP = '51') "
	cWhere += "						  OR  (V3N_NATRUB = '4050' AND V3N_ITCP = '21') "
	cWhere += "						  OR  (V3N_NATRUB = '1623' AND V3N_TPRUBR = '1') "

	If lRetInss 

		cWhere += "						  OR  (V3N_NATRUB = '9989' AND V3N_ITCP = '11' AND V3N_TPRUBR = '4' ) "
		cWhere += "						  OR  (V3N_NATRUB = '9989' AND V3N_ITCP = '31' AND V3N_TPRUBR = '3' ) "

	EndIf 

	cWhere += "						  OR  (V3N_NATRUB = '4051' AND V3N_ITCP = '22') ) )  )"

	cWhere += " AND V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 
	cWhereT2M += " T2M_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 

	If !Empty(xCPFs)
		If ValType(xCPFs) == 'C'
			cWhere += " AND V3N_CPF = '" + xCPFs + "' "
			cWhereT2M += " AND T2M_CPFTRB = '" + xCPFs + "' "
		Else
			cWhere += " AND V3N_CPF IN " + FormatIn(ArrayToStr(xCPFs),";") + " "
			cWhereT2M += " AND T2M_CPFTRB IN " + FormatIn(ArrayToStr(xCPFs),";") + " "
		EndIf
	EndIf

	If !Empty(aEstabe) .Or. !Empty(aLotacao) .Or. !Empty(aMats) .Or. !Empty(aCategoria)
		cJoinT2Q := " INNER JOIN " + RetSQLName("T2Q") + " T2Q "
		cJoinT2Q += " 	ON T2Q.D_E_L_E_T_ = ' ' "
		cJoinT2Q += "		AND T2Q_FILIAL = T2M_FILIAL "  
		cJoinT2Q += "		AND T2Q_ID = T2M_ID "
		cJoinT2Q += "		AND T2Q_VERSAO = T2M_VERSAO "

		If !Empty(aEstabe)
			cWhere		+= " AND V3N_NRINSC IN " + FormatIn(ArrayToStr(aEstabe), ";") + " "
			
			cJoinT2Q 	+= " AND T2Q_ESTABE IN ( "
			cJoinT2Q 	+= " 	SELECT C92_ID "
			cJoinT2Q 	+= "  		FROM " + RetSQLName("C92") + " C92 "
			cJoinT2Q 	+= " 		WHERE C92.D_E_L_E_T_ = ' ' "		
			cJoinT2Q 	+= "  			AND C92_FILIAL IN (?) "
			cJoinT2Q 	+= "  			AND C92_NRINSC IN " + FormatIn(ArrayToStr(aEstabe), ";")
			cJoinT2Q 	+= " ) "

			FilTabela("C92", @aFiliais, @aModoAcess)
		EndIf

		If !Empty(aLotacao)
			cWhere 		+= " AND V3N_CODLOT IN " + FormatIn(ArrayToStr(aLotacao), ";") + " "

			cJoinT2Q 	+= " AND T2Q_LOTACA IN ( "
			cJoinT2Q 	+= " 	SELECT C99_ID "
			cJoinT2Q 	+= "  		FROM " + RetSQLName("C99") + " C99 "
			cJoinT2Q 	+= " 		WHERE C99.D_E_L_E_T_ = ' ' "
			cJoinT2Q 	+= "  			AND C99_FILIAL IN (?) "
			cJoinT2Q 	+= "  			AND C99_CODIGO IN " + FormatIn(ArrayToStr(aLotacao), ";")
			cJoinT2Q 	+= " ) "

			FilTabela("C99", @aFiliais, @aModoAcess)
		EndIf

		If !Empty(aMats) 
			cWhere 		+= " AND V3N_MATRIC IN " + FormatIn(ArrayToStr(aMats), ";") + " "

			cJoinT2Q	+= " AND T2Q_MATRIC IN " + FormatIn(ArrayToStr(aMats), ";")
		EndIf

		If !Empty(aCategoria)
			cWhere 		+= " AND V3N_CATEG IN " + FormatIn(ArrayToStr(aCategoria), ";") + " "

			cJoinT2Q 	+= " AND T2Q_CODCAT IN ( "
			cJoinT2Q 	+= " 	SELECT C87_ID "
			cJoinT2Q 	+= "  		FROM " + RetSQLName("C87") + " C87 "
			cJoinT2Q 	+= " 		WHERE C87.D_E_L_E_T_ = ' ' "
			cJoinT2Q 	+= "  			AND C87_FILIAL IN (?) "
			cJoinT2Q 	+= "  			AND C87_CODIGO IN " + FormatIn(ArrayToStr(aCategoria), ";")
			cJoinT2Q 	+= " ) "

			FilTabela("C87", @aFiliais, @aModoAcess)
		EndIf

		cJoinT2Q := StrTran(cJoinT2Q, "?", "SELECT FILIAIS.FILIAL FROM " + TAFCacheFil(, aFiliais, .T.) + " FILIAIS")
	EndIf

	cWhere  	:= "%" + cWhere + "%"
	cWhereT2M	:= "%" + cWhereT2M + "%"

	If Select(cAlias) > 0
		(cAlias)->( dbCloseArea() )
	EndIf

	If cBanco != "ORACLE"
		cColumnTemp := "AS TRB_TAB"
	Else 
		cColumnTemp := ""
	EndIf 

	cColumnTemp := "%" + cColumnTemp + "%"
	cJoinT2Q	:= "%" + cJoinT2Q + "%"

	BeginSql Alias cAlias
		SELECT DISTINCT * FROM (
			SELECT 
				V3N_FILIAL,
				V3N_INDAPU,
				V3N_PERAPU,
				V3N_INDDEC,
				V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				V3N_EVENTO,
				V3N_ORIGEM,
				V3N_RECIBO,
				V3N_NATRUB,
				V3N_TPRUBR,
				V3N_ITCP,
				V3N_TPVLR,
				V3N_ID,
				0 AS T2O_VRCPSE,
				0 AS T2O_VRDESC,
				'' AS T2O_IDCODR,
				CASE 
					WHEN V3N.V3N_NATRUB = '1623' AND V3N.V3N_TPRUBR = '1' 
					THEN V3N.V3N_VALOR * -1
					ELSE V3N.V3N_VALOR
					END V3N_VALOR
			FROM %Table:V3N% V3N
			WHERE %Exp:cWhere%
				AND V3N.%NotDel%  
				AND V3N_PERAPU = %Exp:cPeriodo%
				
			UNION

			SELECT 
				T2M_FILIAL AS V3N_FILIAL,
				T2M_INDAPU AS V3N_INDAPU,
				T2M_PERAPU AS V3N_PERAPU,
				'' AS V3N_INDDEC,
				T2M_CPFTRB AS V3N_CPF,
				'' AS V3N_NOME,
				'' AS V3N_MATRIC,
				'' AS V3N_CATEG,
				'' AS V3N_TPINSC,
				'' AS V3N_NRINSC,
				'' AS V3N_CODLOT,
				'' AS V3N_EVENTO,
				'3' AS V3N_ORIGEM,
				T2M_NRRECI AS V3N_RECIBO,
				'' AS V3N_NATRUB,
				'' AS V3N_TPRUBR,
				'' AS V3N_ITCP,
				'' AS V3N_TPVLR,
				'' AS V3N_ID,
				T2O_VRCPSE,
				T2O_VRDESC,
				T2O_IDCODR,
				0 AS V3N_VALOR
			FROM %Table:T2M% T2M 
			INNER JOIN %Table:V3N% V3N 
				ON T2M_FILIAL = V3N_FILIAL
					AND V3N_PERAPU = T2M_PERAPU
					AND V3N_CPF = T2M_CPFTRB
					AND V3N_RECIBO = T2M_NRRECI
					AND V3N.%NotDel% 
					AND V3N_ORIGEM = '3'
					AND V3N_TPVLR = '21'
			%Exp:cJoinT2Q%
			LEFT JOIN %Table:T2O% T2O 
				ON T2O_ID = T2M_ID
					AND T2O_VERSAO = T2M_VERSAO
					AND T2O_FILIAL = T2M_FILIAL
					AND T2O.%NotDel%
			WHERE %Exp:cWhereT2M%
				AND T2M.%NotDel% 
				AND T2M_PERAPU = %Exp:cPeriodo%
				AND T2M_NRRECI IN (
					SELECT MAX(T2M.T2M_NRRECI) AS T2M_NRRECI 
						FROM %Table:T2M% T2M
						WHERE %Exp:cWhereT2M% 
							AND T2M.%NotDel% 
							AND T2M.T2M_PERAPU = %Exp:cPeriodo%
							AND T2M.T2M_ATIVO = '1'
						GROUP BY T2M.T2M_FILIAL, T2M.T2M_CPFTRB, T2M.T2M_INDAPU, T2M.T2M_PERAPU
				)
		)%Exp:cColumnTemp%
		ORDER BY V3N_ORIGEM
	EndSql

	TafConOut(procname() + GetLastQuery()[2])

	(cAlias)->( dbGoTop() )
	
	Count To nRet

	(cAlias)->( dbGoTop() )

Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FilInssAnalytic
@type			function
@description	Realiza select no banco para a visão analítica - InssValues
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilInssAnalytic(cAlias as character, cCPF as character, cPeriod as character, cTicket as character) as numeric

	Local lRetTaf		as logical
	Local nRet	   		as numeric
	Local cColumnTmp 	as character
	Local cWhere		as character
	Local cWCPF			as character
	Local cFilSel		as character
	Local cWhereT2M		as character	
	Local cJoinT2P		as character
	Local cJoinT2R		as character

	Default cAlias	:= ""
	Default cCPF	:= ""
	Default cPeriod	:= ""
	Default cTicket	:= ""

	cColumnTmp	:= ""
	cWhereT2M	:= ""
	cWhere		:= ""
	cWCPF		:= ""
	cJoinT2P	:= "%%"
	cJoinT2R	:= "%%"
	cAlias		:= GetNextAlias()
	cFilSel		:= TAFCacheFil("V3N", FilMatriz(), .T.)
	lRetTaf 	:= IIf(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F.)
	nRet		:= 0

	If TafColumnPos("T2P_CODLOT")
		cJoinT2P := "% AND T2P_CODLOT = V3N_CODLOT AND T2P_TPINSC = V3N_TPINSC AND T2P_NRINSC = V3N_NRINSC %"
		cJoinT2R := "% AND T2R_CODLOT = T2P_CODLOT AND T2R_TPINSC = T2P_TPINSC AND T2R_NRINSC = T2P_NRINSC %"
	EndIf

	cWhere := " ( (V3N_ORIGEM = '2' AND V3N_INDAPU IN ('1','2') AND  (	(V3N_NATRUB = '9201' AND V3N_ITCP IN ( '31','32') ) "
	cWhere += " 																			OR (V3N_NATRUB = '9901' AND V3N_TPRUBR = '3') "
	cWhere += " 																			OR (V3N_NATRUB = '1409' AND V3N_ITCP = '51') "
	cWhere += " 																			OR (V3N_NATRUB = '4050' AND V3N_ITCP = '21') "
	cWhere += " 																			OR (V3N_NATRUB = '4051' AND V3N_ITCP = '22') "
	cWhere += " 																			OR (V3N_NATRUB = '1623' AND V3N_TPRUBR = '1') "
	cWhere += " 																			OR (V3N_NATRUB = '9901' AND V3N_TPRUBR = '4') "
		
	If lRetTaf
		cWhere += "						  OR  (V3N_NATRUB = '9989' AND V3N_ITCP = '11' AND V3N_TPRUBR = '4' ) "
		cWhere += "						  OR  (V3N_NATRUB = '9989' AND V3N_ITCP = '31' AND V3N_TPRUBR = '3' ) "
	EndIf

	cWhere += " 																		) ) ) "
	
	cWhereT2M := " T2M_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 

	If !Empty(cCPF)
		cWCPF 		:= " AND V3N_CPF = '" + cCPF + "' "
		cWhereT2M 	+= " AND T2M_CPFTRB = '" + cCPF + "' "
	EndIf

	cWhereT2M	:= "%" + cWhereT2M + "%"
	cWhere  	:= "%" + cWhere + "%"
	cWCPF		:= "%" + cWCPF + "%"

	If Select(cAlias) > 0
		(cAlias)->(DBCloseArea())
	EndIf

	BeginSql Alias cAlias

		SELECT DISTINCT 
				V3N_FILIAL,
				V3N_INDAPU,
				V3N_PERAPU,
				V3N_INDDEC,
				V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				V3N_EVENTO,
				V3N_ORIGEM,
				V3N_RECIBO,
				V3N_NATRUB,
				V3N_TPRUBR,
				C87_DESCRI,
				V3N_ITCP,
				V3N_TPVLR,
				V3N_ID,
				T2O_VRCPSE,
				T2O_VRDESC,
				T2O_IDCODR,
				V3N_VALOR
		FROM (
			SELECT 
				V3N_FILIAL,
				V3N_INDAPU,
				V3N_PERAPU,
				V3N_INDDEC,
				V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				V3N_EVENTO,
				V3N_ORIGEM,
				V3N_RECIBO,
				V3N_NATRUB,
				V3N_TPRUBR,
				C87_DESCRI,
				V3N_ITCP,
				V3N_TPVLR,
				V3N_ID,
				0 AS T2O_VRCPSE,
				0 AS T2O_VRDESC,
				'' AS T2O_IDCODR,
				CASE WHEN V3N.V3N_NATRUB = '1623' AND V3N.V3N_TPRUBR = '1' THEN V3N.V3N_VALOR * -1 ELSE V3N.V3N_VALOR END V3N_VALOR
			FROM %Table:V3N% V3N
			LEFT JOIN %Table:C87% C87 ON C87.C87_CODIGO = V3N.V3N_CATEG AND C87.C87_FILIAL = %xFilial:C87% AND C87.%NotDel%
			WHERE %Exp:cWhere%
				AND V3N_FILIAL IN ( 
					SELECT FILIAIS.FILIAL 
						FROM %temp-table:cFilSel% FILIAIS
				)
				AND V3N_PERAPU = %Exp:cPeriod%
				AND V3N.%NotDel%  
				%Exp:cWCPF%

			UNION

			SELECT 
				T2M_FILIAL AS V3N_FILIAL,
				T2M_INDAPU AS V3N_INDAPU,
				T2M_PERAPU AS V3N_PERAPU,
				T2R_INDDEC AS V3N_INDDEC,
				T2M_CPFTRB AS V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				'' AS V3N_EVENTO,
				'3' AS V3N_ORIGEM,
				T2M_NRRECI AS V3N_RECIBO,
				'' AS V3N_NATRUB,
				'' AS V3N_TPRUBR,
				C87_DESCRI,
				'' AS V3N_ITCP,
				T2T_CODIGO AS V3N_TPVLR,
				'' AS V3N_ID,
				0 AS T2O_VRCPSE,
				0 AS T2O_VRDESC,
				'' AS T2O_IDCODR,
				T2R_VALOR AS V3N_VALOR
			FROM %Table:T2M% T2M 
			INNER JOIN %Table:V3N% V3N 
				ON V3N_FILIAL = T2M_FILIAL
					AND V3N_PERAPU = T2M_PERAPU
					AND V3N_CPF = T2M_CPFTRB
					AND V3N_RECIBO = T2M_NRRECI
					AND V3N.%NotDel% 
					AND V3N_ORIGEM = '3'
					AND V3N_TPVLR = '21'
			LEFT JOIN %Table:C87% C87 
				ON C87.C87_CODIGO = V3N.V3N_CATEG 
					AND C87.C87_FILIAL = %xFilial:C87%
					AND C87.%NotDel%
			LEFT JOIN %Table:T2P% T2P
				ON T2P_ID = T2M_ID
					AND	T2P_VERSAO = T2M_VERSAO
					AND	T2P_FILIAL = T2M_FILIAL
					%Exp:cJoinT2P%
					AND	T2P.%NotDel%
			INNER JOIN %Table:T2R% T2R
				ON T2R_ID = T2P_ID
					AND T2R_VERSAO = T2P_VERSAO
					AND T2R_FILIAL = T2P_FILIAL
					%Exp:cJoinT2R%
					AND T2R.%NotDel%
			INNER JOIN %Table:T2T% T2T
				ON T2T_FILIAL = %xFilial:T2T%
					AND T2T_ID = T2R_TPVLR
					AND T2T.%NotDel%
			WHERE %Exp:cWhereT2M%
				AND T2M.%NotDel% 
				AND T2M_PERAPU = %Exp:cPeriod%
				AND T2M_NRRECI IN (
					SELECT MAX(T2MB.T2M_NRRECI) AS T2M_NRRECI 
						FROM %Table:T2M% T2MB
						WHERE %Exp:cWhereT2M% 
							AND T2MB.%NotDel% 
							AND T2MB.T2M_PERAPU = %Exp:cPeriod%
							AND T2MB.T2M_ATIVO = '1'
						GROUP BY T2MB.T2M_FILIAL, T2MB.T2M_CPFTRB, T2MB.T2M_INDAPU, T2MB.T2M_PERAPU
				)

			UNION

			SELECT 
				T2M_FILIAL AS V3N_FILIAL,
				T2M_INDAPU AS V3N_INDAPU,
				T2M_PERAPU AS V3N_PERAPU,
				'' AS V3N_INDDEC,
				T2M_CPFTRB AS V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				'' AS V3N_EVENTO,
				'3' AS V3N_ORIGEM,
				T2M_NRRECI AS V3N_RECIBO,
				'' AS V3N_NATRUB,
				'' AS V3N_TPRUBR,
				C87_DESCRI,
				'' AS V3N_ITCP,
				'' AS V3N_TPVLR,
				'' AS V3N_ID,
				T2O_VRCPSE,
				T2O_VRDESC,
				T2O_IDCODR,
				0 AS V3N_VALOR
			FROM %Table:T2M% T2M 
			INNER JOIN %Table:V3N% V3N 
				ON V3N_FILIAL = T2M_FILIAL
					AND V3N_PERAPU = T2M_PERAPU
					AND V3N_CPF = T2M_CPFTRB
					AND V3N_RECIBO = T2M_NRRECI
					AND V3N.%NotDel% 
					AND V3N_ORIGEM = '3'
					AND V3N_TPVLR = '21'
			LEFT JOIN %Table:C87% C87 
				ON C87.C87_CODIGO = V3N.V3N_CATEG 
					AND C87.C87_FILIAL = %xFilial:C87%
					AND C87.%NotDel%
			LEFT JOIN %Table:T2O% T2O 
				ON T2O_ID = T2M_ID
					AND T2O_VERSAO = T2M_VERSAO
					AND T2O_FILIAL = T2M_FILIAL
					AND T2O.%NotDel%
			WHERE %Exp:cWhereT2M%
				AND T2M.%NotDel% 
				AND T2M_PERAPU = %Exp:cPeriod%
				AND T2M_NRRECI IN (
					SELECT MAX(T2MB.T2M_NRRECI) AS T2M_NRRECI 
						FROM %Table:T2M% T2MB
						WHERE %Exp:cWhereT2M% 
							AND T2MB.%NotDel% 
							AND T2MB.T2M_PERAPU = %Exp:cPeriod%
							AND T2MB.T2M_ATIVO = '1'
						GROUP BY T2MB.T2M_FILIAL, T2MB.T2M_CPFTRB, T2MB.T2M_INDAPU, T2MB.T2M_PERAPU
				)
		) TRB_TAB
		
		ORDER BY TRB_TAB.V3N_NRINSC, TRB_TAB.V3N_CODLOT, TRB_TAB.V3N_CPF, TRB_TAB.V3N_MATRIC, TRB_TAB.V3N_CATEG, TRB_TAB.V3N_ORIGEM, TRB_TAB.T2O_IDCODR	
		
	EndSql

	TafConOut(Procname() + GetLastQuery()[2])

	(cAlias)->(DBGoTop())

	Count To nRet

	(cAlias)->(DBGoTop())

Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CalcValor
@type			function
@description	Atribui valor devido para as variáveis de controle
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function CalcValor(cAlias as character, nRessInss as numeric, nVlINSS as numeric, nVlINSS13 as numeric,; 
							nBasINSS as numeric, nSalFam as numeric, nSalMat as numeric, nSalMat13 as numeric,;
							nBasINSS13 as numeric, nRetValue as numeric, nRetDescValue as numeric, nRet13Value as numeric,;
							nRet13DescValue as numeric, lCalcGrossValue as logical, lAnalytic as logical, nBasSusJud as numeric)

	Local cNatureza				as character
	Local cTipo					as character
	Local cIncidPS				as character
	Local lRet					as logical
	Local lTafGpeInss           as logical

	Default cAlias				:= ""
	Default nVlINSS				:= 0
	Default nRessInss			:= 0
	Default nVlINSS13			:= 0
	Default nBasINSS			:= 0
	Default nSalFam				:= 0
	Default nSalMat				:= 0
	Default nSalMat13			:= 0
	Default nBasINSS13			:= 0
	Default nRetValue			:= 0
	Default nRetDescValue		:= 0
	Default nRet13Value			:= 0
	Default nRet13DescValue		:= 0
	Default nBasSusJud			:= 0
	Default lCalcGrossValue		:= .F.
	Default lAnalytic			:= .F.

	cNatureza	:= ""
	cTipo		:= ""
	cIncidPS	:= ""
	lRet		:= .F.
	lTafGpeInss	:= IIf(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F.)

	Do Case
	Case (cAlias)->V3N_ORIGEM $ "1|2"

		cNatureza	:= AllTrim((cAlias)->V3N_NATRUB)
		cTipo		:= AllTrim((cAlias)->V3N_TPRUBR)
		cIncidPS	:= AllTrim((cAlias)->V3N_ITCP)

		If (cAlias)->V3N_INDAPU == "1"
			If cNatureza == "9201" .and. cIncidPS == "31"
				nVlINSS := (cAlias)->V3N_VALOR	
				lRet := .T.
			ElseIf cNatureza == "9201" .and. cIncidPS == "32"
				nVlINSS13 += (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "9901" .And. cTipo == "3"
				nBasINSS := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "1409" .And. cIncidPS == "51"
				nSalFam := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "4050" .And. cIncidPS == "21"
				nSalMat := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "4051" .and. cIncidPS == "22"
				nSalMat13 += (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "1623" .and. cTipo == "1"
				nRessInss  := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
				nBasINSS -= (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
				nVlINSS -= (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf lTafGpeInss .And. cNatureza == "9901" .And. cTipo == "4"
				nBasINSS -= (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf
		ElseIf (cAlias)->V3N_INDAPU == "2"
			If cNatureza == "9201" .And. cIncidPS == "32"
				nVlINSS13 := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "9901" .And. cTipo == "3"
				nBasINSS13 := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "4051" .And. cIncidPS == "22"
				nSalMat13 := (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf
		EndIf
	Case (cAlias)->V3N_ORIGEM $ "3"
		cTipo := AllTrim((cAlias)->V3N_TPVLR)

		If lCalcGrossValue
			If (cAlias)->V3N_INDAPU == '1'
				nRetValue 			:= (cAlias)->T2O_VRCPSE
				nRetDescValue 		:= (cAlias)->T2O_VRDESC
				lRet := .T.
			ElseIf (cAlias)->V3N_INDAPU == '2'
				nRet13Value 		:= (cAlias)->T2O_VRCPSE
				nRet13DescValue 	:= (cAlias)->T2O_VRDESC
				lRet := .T.
			EndIf

			TafConOut(procname() + " Dentro CalcValor nRetValue: " + cValtoChar( nRetValue ) )
		EndIf

		If (cAlias)->V3N_INDDEC == "0"
			If cTipo $ "11|12|13|14|15|16|17|18|19|41|42|43|44|45|46|47|48|49|81|82|83|84|85|86|87|88"
				nBasINSS 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo $ "91|92|93|94|95|96|97|98"
				nBasSusJud 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "21"
				nVlINSS 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "31"
				nSalFam += (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cTipo == "32"
				nSalMat += (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf
		ElseIf (cAlias)->V3N_INDDEC == "1"
			If cTipo $ "11|12|13|14|15|16|17|18|19|41|42|43|44|45|46|47|48|49|81|82|83|84|85|86|87|88"
				nBasINSS13 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo $ "91|92|93|94|95|96|97|98"
				nBasSusJud 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "21"
				nVlINSS13 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "32"
				nSalMat13 += (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf
		EndIf
	
	OtherWise
		lRet := .F.
	EndCase

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadHash
@type			function
@description	Carrega o hash de acodo com o arquivo de trabalho oArqTrb
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function LoadHash(cTipo as character, cAlias as character, oArqTrb as object, nRessInss as numeric, nVlINSS as numeric,;
							nVlINSS13 as numeric, nBasINSS as numeric, nSalFam as numeric, nSalMat as numeric, nSalMat13 as numeric,;
							nBasINSS13 as numeric, nRetValue as numeric, nRetDescValue as numeric, nRet13Value as numeric,; 
							nRet13DescValue as numeric, jDados as json, nBasSusJud as numeric)

	Local aPos				as array
	Local cCateg			as character
	Local cEstab			as character
	Local cLotacao			as character
	Local cMatric			as character
	Local cCPF				as character

	Default cTipo			:= ""
	Default cAlias			:= ""
	Default jDados			:= JsonObject():New()
	Default nVlINSS			:= 0
	Default nRessInss		:= 0
	Default nVlINSS13		:= 0
	Default nBasINSS		:= 0
	Default nSalFam			:= 0
	Default nSalMat			:= 0
	Default nSalMat13		:= 0
	Default nBasINSS13		:= 0
	Default nRetValue		:= 0
	Default nRetDescValue	:= 0
	Default nRet13Value		:= 0
	Default nRet13DescValue	:= 0
	Default nBasSusJud		:= 0
	Default oArqTrb			:= Nil

	aPos		:= {}
	cCateg		:= ""
	cEstab		:= ""
	cLotacao	:= ""
	cMatric		:= ""
	cCPF		:= ""

	If cTipo == 'SINTETICO'
		If TAFXHMGet( oArqTrb, AllTrim((cAlias)->V3N_CPF), @aPos )
			aPos[1, CPFFUNC]			:=	AllTrim((cAlias)->V3N_CPF)
			If !Empty((cAlias)->V3N_NOME)
				aPos[1, NOMEFUNC]			:=	EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			EndIf
			aPos[1, MATRIC]				:=	AllTrim((cAlias)->V3N_MATRIC)
			aPos[1, LOTAC]				:=	AllTrim((cAlias)->V3N_CODLOT)
			aPos[1, ESTABELECIMENTO]	:=	AllTrim((cAlias)->V3N_NRINSC)
			aPos[1, CATEG]				:=	AllTrim((cAlias)->V3N_CATEG)

			Do Case
			Case (cAlias)->V3N_ORIGEM == "1"
				aPos[1, FOLHA_BASE_INSS]								+=	nBasINSS
				aPos[1, FOLHA_VALOR_INSS]								+=	nVlINSS + nRessInss
				aPos[1, FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
				aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
				aPos[1, FOLHA_BASE_INSS_13_SALARIO]						+=	nBasINSS13
				aPos[1, FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13 + nRessInss
				aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+=	nSalMat13
			Case (cAlias)->V3N_ORIGEM == "2"
				aPos[1, TAF_BASE_INSS]									+=	nBasINSS
				aPos[1, TAF_VALOR_INSS]									+=	nVlINSS + nRessInss
				aPos[1, TAF_VALOR_SALARIO_FAMILIA]						+=	nSalFam
				aPos[1, TAF_VALOR_SALARIO_MATERNIDADE]					+=	nSalMat
				aPos[1, TAF_BASE_INSS_13_SALARIO]						+=	nBasINSS13
				aPos[1, TAF_VALOR_INSS_13_SALARIO]						+=	nVlINSS13 + nRessInss
				aPos[1, TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+=	nSalMat13
			Case (cAlias)->V3N_ORIGEM == "3"
				aPos[1, GOVERNO_BASE_INSS]								+=	nBasINSS
				aPos[1, GOVERNO_VALOR_INSS]								+=	nVlINSS + nRessInss
				aPos[1, GOVERNO_VALOR_SALARIO_FAMILIA]					+=	nSalFam
				aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
				aPos[1, GOVERNO_BASE_INSS_13_SALARIO]					+=	nBasINSS13
				aPos[1, GOVERNO_VALOR_INSS_13_SALARIO]					+=	nVlINSS13 + nRessInss
				aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
				aPos[1, GOVERNO_LOCALIZADO]															:=	.T.

				aPos[1, GOVERNO_GROSS_VALUE]							+=	nRetValue
				aPos[1, GOVERNO_DESC_GROSS_VALUE]						+=	nRetDescValue
				aPos[1, GOVERNO_13_GROSS_VALUE]							+=	nRet13Value
				aPos[1, GOVERNO_13_DESC_GROSS_VALUE]					+=	nRet13DescValue
			EndCase

			aPos[1, RECIBO_TRANSMISSAO]		:= (cAlias)->V3N_RECIBO

			TafConOut(procname() + " Dentro LoadHash ALTERA nRetValue: " + cValtoChar( nRetValue ) + " CPF: " + aPos[1, CPFFUNC] )
			TafConOut(procname() + " Dentro LoadHash ALTERA GOVERNO_GROSS_VALUE: " + cValtoChar( aPos[1, GOVERNO_GROSS_VALUE] ) + " CPF: " + aPos[1, CPFFUNC] )

			TAFXHMSet( oArqTrb, aPos[1, CPFFUNC], aPos )

		Else

			aPos := R123InitArray()

			aPos[CPFFUNC]			:=	AllTrim((cAlias)->V3N_CPF)
			aPos[NOMEFUNC]			:=	EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			aPos[MATRIC]			:=	AllTrim((cAlias)->V3N_MATRIC)
			aPos[LOTAC]				:=	AllTrim((cAlias)->V3N_CODLOT)
			aPos[ESTABELECIMENTO]	:=	AllTrim((cAlias)->V3N_NRINSC)
			aPos[CATEG]				:=	AllTrim((cAlias)->V3N_CATEG)

			Do Case
			Case (cAlias)->V3N_ORIGEM == "1"
				aPos[FOLHA_BASE_INSS]								:= nBasINSS
				aPos[FOLHA_VALOR_INSS]								:= nVlINSS + nRessInss
				aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= nSalFam
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
				aPos[FOLHA_BASE_INSS_13_SALARIO]					:= nBasINSS13
				aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
			Case (cAlias)->V3N_ORIGEM == "2"
				aPos[TAF_BASE_INSS]									:=	nBasINSS
				aPos[TAF_VALOR_INSS]								:=	nVlINSS + nRessInss
				aPos[TAF_VALOR_SALARIO_FAMILIA]						:=	nSalFam
				aPos[TAF_VALOR_SALARIO_MATERNIDADE]					:=	nSalMat
				aPos[TAF_BASE_INSS_13_SALARIO]						:=	nBasINSS13
				aPos[TAF_VALOR_INSS_13_SALARIO]						:=	nVlINSS13 + nRessInss
				aPos[TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		:=	nSalMat13
			Case (cAlias)->V3N_ORIGEM == "3"
				aPos[GOVERNO_BASE_INSS]								:= nBasINSS
				aPos[GOVERNO_VALOR_INSS]							:= nVlINSS + nRessInss
				aPos[GOVERNO_VALOR_SALARIO_FAMILIA]					:= nSalFam
				aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
				aPos[GOVERNO_BASE_INSS_13_SALARIO]					:= nBasINSS13
				aPos[GOVERNO_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
				aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
				aPos[GOVERNO_LOCALIZADO]															:= .T.

				aPos[GOVERNO_GROSS_VALUE]							:= nRetValue
				aPos[GOVERNO_DESC_GROSS_VALUE]						:= nRetDescValue
				aPos[GOVERNO_13_GROSS_VALUE]						:= nRet13Value
				aPos[GOVERNO_13_DESC_GROSS_VALUE]					:= nRet13DescValue
			EndCase

			aPos[RECIBO_TRANSMISSAO]	:= (cAlias)->V3N_RECIBO

			TafConOut(procname() + " Dentro LoadHash INCLUI nRetValue: " + cValtoChar( nRetValue ) + " CPF: " + aPos[CPFFUNC] )
			TafConOut(procname() + " Dentro LoadHash INCLUI GOVERNO_GROSS_VALUE: " + cValtoChar( aPos[GOVERNO_GROSS_VALUE] ) + " CPF: " + aPos[CPFFUNC] )

			TAFXHMAdd(oArqTrb, aPos, CPFFUNC, 3)
		EndIf

		nBasINSS			:= 0
		nVlINSS				:= 0
		nRessInss			:= 0
		nSalFam				:= 0
		nSalMat				:= 0
		nBasINSS13			:= 0
		nVlINSS13			:= 0
		nSalMat13			:= 0
		nRetValue 			:= 0
		nRetDescValue 		:= 0
		nRet13Value 		:= 0
		nRet13DescValue 	:= 0

		aPos := {}
		FreeObj(aPos)

	ElseIf cTipo == 'ANALITICO'
		If TAFXHMGet( oArqTrb, AllTrim((cAlias)->V3N_NRINSC) + AllTrim((cAlias)->V3N_CPF) + AllTrim((cAlias)->V3N_MATRIC) + AllTrim((cAlias)->V3N_CATEG) + AllTrim((cAlias)->V3N_CODLOT), @aPos )
			aPos[1, CPFFUNC]			:= AllTrim((cAlias)->V3N_CPF)
			aPos[1, NOMEFUNC]			:= EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			aPos[1, MATRIC]				:= AllTrim((cAlias)->V3N_MATRIC)
			aPos[1, LOTAC]				:= AllTrim((cAlias)->V3N_CODLOT)
			aPos[1, ESTABELECIMENTO]	:= AllTrim((cAlias)->V3N_NRINSC)
			aPos[1, CATEG]				:= AllTrim((cAlias)->V3N_CATEG)
			aPos[1, CAT_DESCRI]			:= EncodeUTF8(AllTrim((cAlias)->V3N_CATEG)  + ' - ' +  AllTrim((cAlias)->C87_DESCRI))

			Do Case
				Case (cAlias)->V3N_ORIGEM == "1"
					aPos[1, FOLHA_BASE_INSS]								+= nBasINSS					// inssBasis
					aPos[1, FOLHA_VALOR_INSS]								+= nVlINSS + nRessInss		// inssValue
					aPos[1, FOLHA_VALOR_SALARIO_FAMILIA]					+= nSalFam					// familySalaryValue
					aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE]				+= nSalMat					// maternitySalaryValue
					aPos[1, FOLHA_BASE_INSS_13_SALARIO]						+= nBasINSS13				// inss13Basis
					aPos[1, FOLHA_VALOR_INSS_13_SALARIO]					+= nVlINSS13 + nRessInss	// inss13Value
					aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+= nSalMat13				// maternitySalary13Value
				
				Case (cAlias)->V3N_ORIGEM == "2"
					aPos[1, TAF_BASE_INSS]									+= nBasINSS					// inssTafBasis
					aPos[1, TAF_VALOR_INSS]									+= nVlINSS + nRessInss		// inssTafValue
					aPos[1, TAF_VALOR_SALARIO_FAMILIA]						+= nSalFam					// familySalaryTafValue
					aPos[1, TAF_VALOR_SALARIO_MATERNIDADE]					+= nSalMat					// maternitySalaryTafValue
					aPos[1, TAF_BASE_INSS_13_SALARIO]						+= nBasINSS13				// inss13TafBasis
					aPos[1, TAF_VALOR_INSS_13_SALARIO]						+= nVlINSS13 + nRessInss	// inss13TafValue
					aPos[1, TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+= nSalMat13				// maternitySalary13TafRetValue

				Case (cAlias)->V3N_ORIGEM == "3"
					aPos[1, GOVERNO_BASE_INSS]								+= nBasINSS	- nBasSusJud	// inssRetBasis
					aPos[1, GOVERNO_BASE_SUSPENSAO]							+= nBasSusJud
					aPos[1, GOVERNO_BASE_TOTAL_INSS]						+= nBasINSS
					aPos[1, GOVERNO_VALOR_INSS]								+= nVlINSS + nRessInss		// inssRetValue
					aPos[1, GOVERNO_VALOR_SALARIO_FAMILIA]					+= nSalFam					// familySalaryRetValue
					aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE]				+= nSalMat					// maternitySalaryRetValue
					aPos[1, GOVERNO_BASE_INSS_13_SALARIO]					+= nBasINSS13				// inss13RetBasis
					aPos[1, GOVERNO_VALOR_INSS_13_SALARIO]					+= nVlINSS13 + nRessInss	// inss13RetValue
					aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+= nSalMat13				// maternitySalary13RetValue
					aPos[1, GOVERNO_LOCALIZADO]								:= .T.

					aPos[1, GOVERNO_GROSS_VALUE]							+= nRetValue
					aPos[1, GOVERNO_DESC_GROSS_VALUE]						+= nRetDescValue
					aPos[1, GOVERNO_13_GROSS_VALUE]							+= nRet13Value
					aPos[1, GOVERNO_13_DESC_GROSS_VALUE]					+= nRet13DescValue

			EndCase

			aPos[1, RECIBO_TRANSMISSAO]	:= (cAlias)->V3N_RECIBO

			TAFXHMSet(oArqTrb, aPos[1, ESTABELECIMENTO] + aPos[1, CPFFUNC] + aPos[1, MATRIC] + aPos[1, CATEG] + aPos[1, LOTAC], aPos)
		Else
			aPos 					:= R123InitArray()
			aPos[CPFFUNC]			:= AllTrim((cAlias)->V3N_CPF)
			aPos[NOMEFUNC]			:= EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			aPos[MATRIC]			:= AllTrim((cAlias)->V3N_MATRIC)
			aPos[LOTAC]				:= AllTrim((cAlias)->V3N_CODLOT)
			aPos[ESTABELECIMENTO]	:= AllTrim((cAlias)->V3N_NRINSC)
			aPos[CATEG]				:= AllTrim((cAlias)->V3N_CATEG)
			aPos[CAT_DESCRI]		:= EncodeUTF8(AllTrim((cAlias)->V3N_CATEG) + " - " + AllTrim((cAlias)->C87_DESCRI))

			Do Case
				Case (cAlias)->V3N_ORIGEM == "1"
					aPos[FOLHA_BASE_INSS]								:= nBasINSS
					aPos[FOLHA_VALOR_INSS]								:= nVlINSS + nRessInss
					aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= nSalFam
					aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
					aPos[FOLHA_BASE_INSS_13_SALARIO]					:= nBasINSS13
					aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
					aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
				
				Case (cAlias)->V3N_ORIGEM == "2"
					aPos[TAF_BASE_INSS]									:= nBasINSS
					aPos[TAF_VALOR_INSS]								:= nVlINSS + nRessInss
					aPos[TAF_VALOR_SALARIO_FAMILIA]						:= nSalFam
					aPos[TAF_VALOR_SALARIO_MATERNIDADE]					:= nSalMat
					aPos[TAF_BASE_INSS_13_SALARIO]						:= nBasINSS13
					aPos[TAF_VALOR_INSS_13_SALARIO]						:= nVlINSS13 + nRessInss
					aPos[TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		:= nSalMat13

				Case (cAlias)->V3N_ORIGEM == "3"
					aPos[GOVERNO_BASE_INSS]								:= nBasINSS - nBasSusJud
					aPos[GOVERNO_BASE_SUSPENSAO]						:= nBasSusJud
					aPos[GOVERNO_BASE_TOTAL_INSS]						:= nBasINSS
					aPos[GOVERNO_VALOR_INSS]							:= nVlINSS + nRessInss
					aPos[GOVERNO_VALOR_SALARIO_FAMILIA]					:= nSalFam
					aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
					aPos[GOVERNO_BASE_INSS_13_SALARIO]					:= nBasINSS13
					aPos[GOVERNO_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
					aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
					aPos[GOVERNO_LOCALIZADO]							:= .T.

					aPos[GOVERNO_GROSS_VALUE]							:= nRetValue
					aPos[GOVERNO_DESC_GROSS_VALUE]						:= nRetDescValue
					aPos[GOVERNO_13_GROSS_VALUE]						:= nRet13Value
					aPos[GOVERNO_13_DESC_GROSS_VALUE]					:= nRet13DescValue

			EndCase

			aPos[RECIBO_TRANSMISSAO] := (cAlias)->V3N_RECIBO

			TAFXHMAdd(oArqTrb, aPos, ESTABELECIMENTO, 3, CPFFUNC, 3, MATRIC, 3, CATEG, 3, LOTAC, 3)
		EndIf

		nBasINSS		:= 0
		nVlINSS			:= 0
		nRessInss		:= 0
		nSalFam			:= 0
		nSalMat			:= 0
		nBasINSS13		:= 0
		nVlINSS13		:= 0
		nSalMat13		:= 0
		nRetValue 		:= 0
		nRetDescValue 	:= 0
		nRet13Value 	:= 0
		nRet13DescValue := 0
		nBasSusJud		:= 0
		aPos 			:= {}
		
		FreeObj(aPos)
	ElseIf cTipo == 'RH'		
		cCateg		:= AllTrim(IIf(ValType(jDados["esocialCategory"]) == "N", cValToChar(jDados["esocialCategory"]), jDados["esocialCategory"]))
		cEstab		:= AllTrim(GetBranchID(jDados["branchId"]))
		cLotacao	:= AllTrim(jDados["lotationCode"])
		cMatric		:= AllTrim(jDados["esocialRegistration"])
		cCPF		:= AllTrim(jDados["cpfNumber"])

		If TAFXHMGet(oArqTrb, cEstab + cCPF + cMatric + cCateg + cLotacao, @aPos)
			aPos[1][CPFFUNC]									:=	cCPF
			aPos[1][NOMEFUNC]									:=	EncodeUTF8(AllTrim(jDados["name"]))
			aPos[1][MATRIC]										:=	cMatric
			aPos[1][LOTAC]										:=	cLotacao
			aPos[1][ESTABELECIMENTO]							:=	cEstab
			aPos[1][CATEG]										:=	cCateg
			aPos[1][CAT_DESCRI]									:=	EncodeUTF8(cCateg  + ' - ' + AllTrim(Posicione('C87',2,xFilial('C87') + cCateg,'C87_DESCRI')) )

			aPos[1][FOLHA_BASE_INSS]							+= jDados["inssBasis"]
			aPos[1][FOLHA_VALOR_INSS]							+= jDados["inssValue"]
			aPos[1][FOLHA_VALOR_SALARIO_FAMILIA]				+= jDados["familySalaryValue"]
			aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE]			+= jDados["maternitySalaryValue"]
			aPos[1][FOLHA_BASE_INSS_13_SALARIO]					+= jDados["inss13Basis"]
			aPos[1][FOLHA_VALOR_INSS_13_SALARIO]				+= jDados["inss13Value"]
			aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+= jDados["maternitySalary13Value"]

			TAFXHMSet(oArqTrb, aPos[1][ESTABELECIMENTO] + aPos[1][CPFFUNC] + aPos[1][MATRIC] + aPos[1][CATEG] + aPos[1][LOTAC], aPos)
		Else
			aPos 												:= R123InitArray()

			aPos[CPFFUNC]										:=	cCPF
			aPos[NOMEFUNC]										:=	EncodeUTF8(AllTrim(jDados["name"]))
			aPos[MATRIC]										:=	cMatric
			aPos[LOTAC]											:=	cLotacao
			aPos[ESTABELECIMENTO]								:=	cEstab
			aPos[CATEG]											:=	cCateg
			aPos[CAT_DESCRI]									:=	EncodeUTF8(cCateg + ' - ' + AllTrim(Posicione('C87',2,xFilial('C87') + cCateg,'C87_DESCRI')) )

			aPos[FOLHA_BASE_INSS]								:= jDados["inssBasis"]
			aPos[FOLHA_VALOR_INSS]								:= jDados["inssValue"]
			aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= jDados["familySalaryValue"]
			aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= jDados["maternitySalaryValue"]
			aPos[FOLHA_BASE_INSS_13_SALARIO]					:= jDados["inss13Basis"]
			aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= jDados["inss13Value"]
			aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= jDados["maternitySalary13Value"]

			TAFXHMAdd(oArqTrb, aPos, ESTABELECIMENTO, 3, CPFFUNC, 3, MATRIC, 3, CATEG, 3, LOTAC, 3)
		EndIf

		aPos		:= {}
		nBasINSS	:= 0
		nVlINSS		:= 0
		nRessInss	:= 0
		nSalFam		:= 0
		nSalMat		:= 0
		nBasINSS13	:= 0
		nVlINSS13	:= 0
		nSalMat13	:= 0

		FWFreeArray(aPos)
	EndIf

Return oArqTrb

//---------------------------------------------------------------------
/*/{Protheus.doc} LegacyStatus
@type			method
@description	Método para consultar status do serviço do ERP Legado.
@author			Verônica de Almeida
@since			19/07/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET LegacyStatus QUERYPARAM companyId WSRESTFUL reportEsocialBaseConfer

	Local aCompany			:= {}
	Local aHeader			:= {}
	Local cEmpRequest		:= ""
	Local cFilRequest 		:= ""
	Local cRmUrl			:= ""
	Local cFilRH			:= ""
	Local cError			:= ""
	Local cPath				:= "/api/rh/esocial/v1/reportEsocialBaseConfer"
	Local lRet        		:= .T.
	Local lIsConfigured		:= .T.
	Local lIsAvailable		:= .T.
	Local lInssIsUpToDate	:= .T.
	Local lFgtsIsUpToDate	:= .T.
	Local oRest				:= Nil
	Local oResponse   		:= JsonObject():New()

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				cRmUrl 			:= AllTrim( GetNewPar( "MV_TAFRHUR", "" ))
				lIsConfigured 	:= (TAFAlsInDic( "V5H" ) .And. !Empty( cRmUrl ) )

				If lIsConfigured
					aHeader := Iif( !Empty( AllTrim( GetNewPar( "MV_TAFRHLG", "" ) ) ), GetHeader(), {} )

					// Busca coligada RM
					cFilRH 			:= GetFilRH(aHeader)
					lIsAvailable 	:= (cFilRH <> Nil)

					If lIsAvailable
						oRest := FWRest():New(cRmUrl)

						oRest:SetPath(cPath + "/InssRetValues")
						oRest:Get(aHeader)
						
						cError 			:= oRest:GetLastError()
						lInssIsUpToDate := !("404" $ cError)
						oRest 			:= Nil
						
						FreeObj(oRest)
					Else
						lInssIsUpToDate := .F.
					EndIf
				EndIf

				oResponse["isConfigured"]	:= lIsConfigured
				oResponse["isAvailable"]	:= lIsAvailable
				oResponse["inssIsUpToDate"]	:= lInssIsUpToDate
				oResponse["fgtsIsUpToDate"]	:= lFgtsIsUpToDate
						
				::SetResponse(oResponse:ToJson())
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf

	FwFreeObj(oResponse)

Return lRet 

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadHashLegacy
@type			method
@description	Método carregar o hash com valores do RH
@author			Verônica de Almeida
@since			19/07/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
Static Function LoadHashLegacy(cTicket, oArqTrb)
Local aPos	:= {}
Local cAliasV5H := V5HByTicket(cTicket)

If !Empty(cAliasV5H)
	(cAliasV5H)->( dbGoTop() )

	While (cAliasV5H)->( !Eof() )

		If TAFXHMGet( oArqTrb, AllTrim((cAliasV5H)->V5H_CPF), @aPos )

			aPos[1][CPFFUNC]									:=	AllTrim((cAliasV5H)->V5H_CPF)
			aPos[1][NOMEFUNC]									:=	AllTrim((cAliasV5H)->V5H_NOME)
			aPos[1][MATRIC]										:=	AllTrim((cAliasV5H)->V5H_MATRIC)
			aPos[1][LOTAC]										:=	AllTrim((cAliasV5H)->V5H_LOTACA)
			aPos[1][ESTABELECIMENTO]							:=	AllTrim((cAliasV5H)->V5H_ESTABE)
			aPos[1][CATEG]										:=	AllTrim((cAliasV5H)->V5H_CATEG)
			aPos[1][FOLHA_BASE_INSS]							:= (cAliasV5H)->V5H_BSINSS
			aPos[1][FOLHA_VALOR_INSS]							:= (cAliasV5H)->V5H_VLINSS
			aPos[1][FOLHA_VALOR_SALARIO_FAMILIA]				:= (cAliasV5H)->V5H_VLFAM
			aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE]			:= (cAliasV5H)->V5H_VLMAT
			aPos[1][FOLHA_BASE_INSS_13_SALARIO]					:= (cAliasV5H)->V5H_BS13
			aPos[1][FOLHA_VALOR_INSS_13_SALARIO]				:= (cAliasV5H)->V5H_VL13
			aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= (cAliasV5H)->V5H_VLMT13

			TAFXHMSet( oArqTrb, aPos[1][CPFFUNC], aPos )
		Else
			aPos := R123InitArray()

			aPos[CPFFUNC]										:=	AllTrim((cAliasV5H)->V5H_CPF)
			aPos[NOMEFUNC]										:=	AllTrim((cAliasV5H)->V5H_NOME)
			aPos[MATRIC]										:=	AllTrim((cAliasV5H)->V5H_MATRIC)
			aPos[LOTAC]											:=	AllTrim((cAliasV5H)->V5H_LOTACA)
			aPos[ESTABELECIMENTO]								:=	AllTrim((cAliasV5H)->V5H_ESTABE)
			aPos[CATEG]											:=	AllTrim((cAliasV5H)->V5H_CATEG)
			aPos[FOLHA_BASE_INSS]								:= (cAliasV5H)->V5H_BSINSS
			aPos[FOLHA_VALOR_INSS]								:= (cAliasV5H)->V5H_VLINSS
			aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= (cAliasV5H)->V5H_VLFAM
			aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= (cAliasV5H)->V5H_VLMAT
			aPos[FOLHA_BASE_INSS_13_SALARIO]					:= (cAliasV5H)->V5H_BS13
			aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= (cAliasV5H)->V5H_VL13
			aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= (cAliasV5H)->V5H_VLMT13

			TAFXHMAdd(oArqTrb, aPos, CPFFUNC, 3)

		EndIf

		(cAliasV5H)->( dbSkip() )
	EndDo

EndIf

aPos := {}
FreeObj(aPos)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FilMatriz
@type function
@description Retorna todas as filiais da matriz logada
@author Melkz Siqueira
@since 06/04/2022
@version 1.0		
@return aFiliais - Retornar um array com as filiais
/*/
//-------------------------------------------------------------------
Static Function FilMatriz()

	Local aFiliais := {}

	C1E->(DBSetOrder(3))
	
	If C1E->(MsSeek(xFilial("C1E") + PadR(cFilAnt, GetSX3Cache("C1E_FILTAF", "X3_TAMANHO")) + "1"))
		If C1E->C1E_MATRIZ
			aFiliais := LoadSM0BaseCNPJ()
		EndIf
	EndIf

	If Empty(aFiliais)
		aAdd(aFiliais, cFilAnt)
	EndIf

Return aFiliais

//-------------------------------------------------------------------
/*/{Protheus.doc} FilTabela
@type function
@description Retorna todas as filiais de acordo com o compartilhamento da tabela
@author Melkz Siqueira
@since 06/04/2022
@version 1.0
@param cTabela - Alias da tabela
@param aFiliais - Array de filiais retornado por referência		
/*/
//-------------------------------------------------------------------
Static Function FilTabela(cTabela, aFiliais, aModoAcess)

	Local aFilMatriz	:= {}
	Local nX			:= 0

	Default aFiliais	:= {}
	Default aModoAcess	:= {}
	Default cTabela 	:= ""
	
	If CheckMdAcc(cTabela, @aModoAcess)
		If !Empty(cTabela)
			aFilMatriz := FilMatriz()

			For nX := 1 To Len(aFilMatriz)
				AAdd(aFiliais, xFilial(cTabela, aFilMatriz[nX]))
			Next
		EndIf
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckMdAcc
@type function
@description Compara os modos de acesso entre as tabelas 
@author Melkz Siqueira
@since 06/04/2022
@version 1.0
@param cTabela - Alias da tabela
@param aModoAcess - Array com os modos de acesso	
/*/
//-------------------------------------------------------------------
Static Function CheckMdAcc(cTabela, aModoAcess)

	Local aSX2Data		:= {}
	Local lRet			:= .F.
	Local nX			:= 0

	Default aModoAcess	:= {} 
	Default cTabela 	:= ""

	If !Empty(cTabela)
		If FwLibVersion() >= "20180912"
			aSX2Data := FwSX2Util():GetSX2data(cTabela, {"X2_MODO", "X2_MODOUN", "X2_MODOEMP"})
			
			If !(aSX2Data[1][2] == "C" .And. aSX2Data[2][2] == "C" .And. aSX2Data[3][2] == "C")
				If Empty(aModoAcess)
					AAdd(aModoAcess, aSX2Data)

					lRet := .T.
				Else
					For nX := 1 To Len(aModoAcess)
						If !(aModoAcess[nX][1][2] == aSX2Data[1][2] .And. aModoAcess[nX][2][2] == aSX2Data[2][2] .And. aModoAcess[nX][3][2] == aSX2Data[3][2])
							AAdd(aModoAcess, aSX2Data)

							lRet := .T.
						EndIf
					Next
				EndIf
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TpInscPic
@Description Faz o tratamento do número de inscrição com a picture 
de acordo com o tipo de inscrição informado.

Tipo de inscrição:	1 - CNPJ
					2 - CPF
					3 - CAEPF
					4 - CNO

@param cTpInsc - Tipo de inscrição
@param cNrInsc - Número de inscrição

@return cNrInsc - Número de inscrição com o tratamento de picture

@author Melkz Siqueira
@since 12/04/2022
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function TpInscPic(cTpInsc, cNrInsc)

	Default cTpInsc := ""
	Default cNrInsc	:= ""
	
	If !("/" $ cNrInsc .Or. "." $ cNrInsc .Or. "-" $ cNrInsc) .And. !Empty(cTpInsc) .And. !Empty(cNrInsc)
		Do Case
			Case cTpInsc == '1'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R 99.999.999/9999-99")

			Case cTpInsc == '2'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R 999.999.999-99")

			Case cTpInsc == '3'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R 999.999.999/999-99")

			Case cTpInsc == '4'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R 99.999.99999/99")
		EndCase
	EndIf

Return cNrInsc

/*/{Protheus.doc} V5HGetRhValues
	Recupera informações de valores de INSS já calculados e anteriormente gravados na V5H 
	
	@type  Static Function
	@author Fabio Mendonça
	@since 17/02/2023
	@version 1.0
	@param 	cTicket	-	Ticket da Requisição
	@param 	cCPF	-	CPF do Trabalhador

	@return aRetRhValues	-	Array com Valores de INSS filtrados da V5H
/*/
Static Function V5HGetRhValues(cTicket as character, cCPF as character) as array

	Local aRetRhValues 	as array
	Local jRhValues		as json

	aRetRhValues	:= {}
	cAliasV5H		:= V5HByTicket(cTicket, cCPF, "1")

	If !Empty(cAliasV5H)
		(cAliasV5H)->(dbGoTop())

		While (cAliasV5H)->(!Eof()) 
			jRhValues 							:= JsonObject():New()
			jRhValues["esocialCategory"]        := AllTrim((cAliasV5H)->V5H_CATEG)
			jRhValues["branchId"]               := AllTrim((cAliasV5H)->V5H_ESTABE)
			jRhValues["lotationCode"]           := AllTrim((cAliasV5H)->V5H_LOTACA)
			jRhValues["esocialRegistration"]    := AllTrim((cAliasV5H)->V5H_MATRIC)
			jRhValues["cpfNumber"]              := AllTrim((cAliasV5H)->V5H_CPF)
			jRhValues["name"]                   := AllTrim((cAliasV5H)->V5H_NOME)
			jRhValues["inssBasis"]              := (cAliasV5H)->V5H_BSINSS
			jRhValues["inssValue"]              := (cAliasV5H)->V5H_VLINSS
			jRhValues["familySalaryValue"]      := (cAliasV5H)->V5H_VLFAM
			jRhValues["maternitySalaryValue"]   := (cAliasV5H)->V5H_VLMAT
			jRhValues["inss13Basis"]            := (cAliasV5H)->V5H_BS13
			jRhValues["inss13Value"]            := (cAliasV5H)->V5H_VL13
			jRhValues["maternitySalary13Value"] := (cAliasV5H)->V5H_VLMT13

			AADD(aRetRhValues, jRhValues)
			(cAliasV5H)->(dbSkip())
		EndDo
	EndIf
	
Return aRetRhValues
