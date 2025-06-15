#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpresults.CH"

Static _aMapMat  := MapFields(1)
Static _aMapRas  := MapFields(2)
Static _aMapPar  := MapFields(3)
Static _aMapMtP  := MapFields(4)
Static _aMapPcd  := MapFields(5)
Static _aMapLog  := MapFields(6)
Static _lTrtHwg  := Nil
Static _aTamQtd  := TamSX3("HWG_QTEMPE")
Static _nTamDoc  := TamSX3("HWC_DOCERP")[1]
Static _nTamTipo := TamSX3("HWC_TDCERP")[1]

#DEFINE LISTA_ALTERACAO_MATRIZ               "AlteraHWB"
#DEFINE LISTA_ALTERACAO_RASTREIO             "AlteraHWC"
#DEFINE LISTA_PARAMETROS_MRP                 "Parametros"
#DEFINE LISTA_PROCESSAMENTOS_MRP             "Processed_Mrp"
#DEFINE LISTA_RESULTADOS_RASTREADOS          "Rastreio"
#DEFINE LISTA_RESULTADOS_SUMARIZADOS         "Matriz"
#DEFINE LISTA_RESULTADOS_SUMARIZADOS_PRODUTO "Matriz_Produto"
#DEFINE LISTA_LOG_ALTERACAO                  "RegistraSMG"

#DEFINE PARAMETRO_TELA "|setupDescription|demandStartDate|demandEndDate|demandsProcessed|eventLog|lGeraDoc|periodType|numberOfPeriods|leadTime|firmHorizon|consignedOut|consignedIn|rejectedQuality|blockedLot|safetyStock|orderPoint|purchaseRequestNumber|productionOrderNumber|consolidatePurchaseRequest|consolidateProductionOrder|productionOrderType|allocationSuggestion|demandType|documentType|"

/*/{Protheus.doc} mrpresults
API de integracao de Resultados do MRP

@type  WSCLASS
@author renan.roeder
@since 31/07/2019
@version P12.1.27
/*/
WSRESTFUL mrpresults DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Resultados do MRP"
	WSDATA branchId            AS STRING  OPTIONAL
	WSDATA concatDoc           AS INTEGER OPTIONAL
	WSDATA compCode            AS STRING  OPTIONAL
	WSDATA docMrp              AS STRING  OPTIONAL
	WSDATA docPai              AS STRING  OPTIONAL
	WSDATA erpDoc              AS STRING  OPTIONAL
	WSDATA erpDocType          AS STRING  OPTIONAL
	WSDATA filterEvent         AS STRING  OPTIONAL
	WSDATA Fields              AS STRING  OPTIONAL
	WSDATA format              AS BOOLEAN OPTIONAL
	WSDATA message             AS STRING  OPTIONAL
	WSDATA necessityDate       AS STRING  OPTIONAL
	WSDATA optionalId          AS STRING  OPTIONAL
	WSDATA Order               AS STRING  OPTIONAL
	WSDATA parentDoc           AS STRING  OPTIONAL
	WSDATA parentDocT          AS STRING  OPTIONAL
	WSDATA parentDocument      AS STRING  OPTIONAL
	WSDATA parentDocumentType  AS STRING  OPTIONAL
	WSDATA product             AS STRING  OPTIONAL
	WSDATA recordKey           AS STRING  OPTIONAL
	WSDATA recStatus           AS STRING  OPTIONAL
	WSDATA seqInStru           AS STRING  OPTIONAL
	WSDATA sequenceInStructure AS STRING  OPTIONAL
	WSDATA substitutionKey     AS STRING  OPTIONAL
	WSDATA substKey            AS STRING  OPTIONAL
	WSDATA ticket              AS STRING  OPTIONAL
	WSDATA transferStatus      AS STRING  OPTIONAL
	WSDATA breakupSeq          AS INTEGER OPTIONAL
	WSDATA Page                AS INTEGER OPTIONAL
	WSDATA PageSize            AS INTEGER OPTIONAL
	WSDATA recordNumber        AS INTEGER OPTIONAL
	WSDATA dataTransf          AS DATE    OPTIONAL

	WSMETHOD GET SUM;
		DESCRIPTION STR0002; //"Retorna os resultados sumarizados de uma execu��o do MRP"
		WSSYNTAX "api/pcp/v1/mrpresults/summarized/{branchId}/{ticket}" ;
		PATH "/api/pcp/v1/mrpresults/summarized/{branchId}/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET OPC;
		DESCRIPTION STR0012; //"Retorna os dados do opcional"
		WSSYNTAX "api/pcp/v1/mrpresults/optional/{branchId}/{ticket}" ;
		PATH "/api/pcp/v1/mrpresults/optional/{branchId}/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET PARAM;
		DESCRIPTION STR0003; //"Retorna os parametros utilizados em uma execu��o do MRP"
		WSSYNTAX "api/pcp/v1/mrpresults/parameters/{branchId}/{ticket}" ;
		PATH "api/pcp/v1/mrpresults/parameters/{branchId}/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET SUMPROD;
		DESCRIPTION STR0004; //"Retorna os resultados sumarizados de um produto em uma execu��o do MRP"
		WSSYNTAX "api/pcp/v1/mrpresults/summarized/{branchId}/{ticket}/{product}" ;
		PATH "/api/pcp/v1/mrpresults/summarized/{branchId}/{ticket}/{product}" ;
		TTALK "v1"

	WSMETHOD GET TRAPDDT;
		DESCRIPTION STR0005; //"Retorna os resultados rastreados de uma execu��o do MRP para um produto e data espec�ficos"
		WSSYNTAX "api/pcp/v1/mrpresults/traced/{branchId}/{ticket}/{product}/{necessityDate}" ;
		PATH "api/pcp/v1/mrpresults/traced/{branchId}/{ticket}/{product}/{necessityDate}" ;
		TTALK "v1"

	WSMETHOD GET SUBSTITUTES;
		DESCRIPTION STR0019; //"Retorna os resultados rastreados de uma execu��o do MRP para um produto e data espec�ficos"
		WSSYNTAX "api/pcp/v1/mrpresults/substitutes/{branchId}/{ticket}/{parentDocumentType}/{parentDocument}/{sequenceInStructure}/{substitutionKey}" ;
		PATH "api/pcp/v1/mrpresults/substitutes/{branchId}/{ticket}/{parentDocumentType}/{parentDocument}/{sequenceInStructure}/{substitutionKey}" ;
		TTALK "v1"

	WSMETHOD GET PROCESS;
		DESCRIPTION STR0006; //"Retorna todos os processamentos do MRP"
		WSSYNTAX "api/pcp/v1/mrpresults/processed/{branchId}" ;
		PATH "api/pcp/v1/mrpresults/processed/{branchId}" ;
		TTALK "v1"

	WSMETHOD GET TICKET;
		DESCRIPTION STR0020; //"Retorna informa��es de um processamento do MRP."
		WSSYNTAX "api/pcp/v1/mrpresults/processed/{branchId}/{ticket}" ;
		PATH "api/pcp/v1/mrpresults/processed/{branchId}/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET PROCREGS;
		DESCRIPTION STR0007; //"Retorna registros que devem ser processados"
		WSSYNTAX "api/pcp/v1/mrpresults/process/{ticket}" ;
		PATH "api/pcp/v1/mrpresults/process/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET TRANSFER;
		DESCRIPTION STR0018; //"Retorna os registros de transfer�ncia que devem ser processados"
		WSSYNTAX "api/pcp/v1/mrpresults/transferences/{ticket}" ;
		PATH "api/pcp/v1/mrpresults/transferences/{ticket}" ;
		TTALK "v1"

	WSMETHOD POST RASTREIO;
		DESCRIPTION STR0008; //"Faz a atualiza��o do status de um registro de rastreio."
		WSSYNTAX "api/pcp/v1/mrpresults/tracking/{recordNumber}/{recStatus}/{erpDoc}/{erpDocType}" ;
		PATH "api/pcp/v1/mrpresults/tracking/{recordNumber}/{recStatus}/{erpDoc}/{erpDocType}" ;
		TTALK "v1"

	WSMETHOD POST TRANSFER;
		DESCRIPTION STR0017; //"Faz a atualiza��o do status de um registro de rastreio."
		WSSYNTAX "api/pcp/v1/mrpresults/transfer/{recordNumber}/{transferStatus}/{message}" ;
		PATH "api/pcp/v1/mrpresults/transfer/{recordNumber}/{transferStatus}/{message}" ;
		TTALK "v1"

	WSMETHOD GET AGLUTINADO;
		DESCRIPTION STR0009; //"Consulta um documento do MRP na tabela de documentos aglutinados."
		WSSYNTAX "api/pcp/v1/mrpresults/aglutinado/{ticket}/{erpDoc}/{compCode}" ;
		PATH "api/pcp/v1/mrpresults/aglutinado/{ticket}/{erpDoc}/{compCode}" ;
		TTALK "v1"

	WSMETHOD GET ORDSUBS;
		DESCRIPTION STR0010;//"Busca dados do componente original de ordem de substitui��o"
		WSSYNTAX "api/pcp/v1/mrpresults/ordsubs/{ticket}/{recordKey}/{parentDoc}" ;
		PATH "api/pcp/v1/mrpresults/ordsubs/{ticket}/{recordKey}/{parentDoc}" ;
		TTALK "v1"

	WSMETHOD GET PRODORIG;
		DESCRIPTION STR0011; //"Retorna o produto origem de um empenho de alternativo"
		WSSYNTAX "api/pcp/v1/mrpresults/prodorig/{ticket}/{recordKey}/{parentDoc}" ;
		PATH "api/pcp/v1/mrpresults/prodorig/{ticket}/{recordKey}/{parentDoc}" ;
		TTALK "v1"

	WSMETHOD POST CLEAR;
		DESCRIPTION STR0013; //"Efetua limpeza de base de processamento do MRP"
		WSSYNTAX "api/pcp/v1/mrpresults/clear" ;
		PATH "/api/pcp/v1/mrpresults/clear" ;
		TTALK "v1"

	WSMETHOD GET EVENTS;
		DESCRIPTION STR0015; //"Consulta eventos do ticket"
		WSSYNTAX "api/pcp/v1/mrpresults/events/{ticket}" ;
		PATH "api/pcp/v1/mrpresults/events/{ticket}" ;
		TTALK "v1"

	WSMETHOD POST MAT_ALTERA;
		DESCRIPTION STR0019; //"Altera as informa��es de um registro da matriz de resultados."
		WSSYNTAX "api/pcp/v1/mrpresults/updMat" ;
		PATH "api/pcp/v1/mrpresults/updMat" ;
		TTALK "v1"

	WSMETHOD POST RAS_ALTERA;
		DESCRIPTION STR0021; //"Altera as informa��es de um registro de rastreio."
		WSSYNTAX "api/pcp/v1/mrpresults/updRas" ;
		PATH "api/pcp/v1/mrpresults/updRas" ;
		TTALK "v1"

	WSMETHOD GET DOC_ORIG;
		DESCRIPTION STR0016; //"Consulta o documento origem do MRP na tabela de documentos aglutinados."
		WSSYNTAX "api/pcp/v1/mrpresults/docorig/{ticket}/{erpDoc}" ;
		PATH "api/pcp/v1/mrpresults/docorig/{ticket}/{erpDoc}" ;
		TTALK "v1"

	WSMETHOD POST LOG_ALTERA;
		DESCRIPTION STR0022; //"Registra o log de altera��es das informa��es da matriz de resultados/rastreio."
		WSSYNTAX "api/pcp/v1/mrpresults/logAlt" ;
		PATH "api/pcp/v1/mrpresults/logAlt" ;
		TTALK "v1"

	WSMETHOD GET RAS_DEM;
		DESCRIPTION STR0023; //"Consulta o rastreio das demandas processadas no ticket."
		WSSYNTAX "api/pcp/v1/mrpresults/rasDem/{ticket}" ;
		PATH "api/pcp/v1/mrpresults/rasDem/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET CHKME;
		DESCRIPTION STR0024; //"Verifica se um ticket foi executado com Multi-Empresas."
		WSSYNTAX "api/pcp/v1/mrpresults/checkmultibranch/{ticket}" ;
		PATH "api/pcp/v1/mrpresults/checkmultibranch/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET PROD_PAI;
		DESCRIPTION STR0025; //"Retorna o produto pai de um documento gerado pelo MRP"
		WSSYNTAX "api/pcp/v1/mrpresults/prodPai/{branchId}/{ticket}/{docPai}" ;
		PATH "api/pcp/v1/mrpresults/prodPai/{branchId}/{ticket}/{docPai}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET SUM api/pcp/v1/mrpresults/summarized/{branchId}/{ticket}
Retorna o resultado sumarizado de uma execu��o do MRP

@type  WSMETHOD
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET SUM PATHPARAM branchId, ticket QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetSum(Self:branchId, Self:ticket, Self:Fields, Self:Order, Self:Page, Self:PageSize, LISTA_RESULTADOS_SUMARIZADOS)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetSum
Funcao para disparar as acoes da API de Resultados do MRP, para o metodo GET dos resultados sumarizados.

@type  Function
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param cBranch   , Caracter, Codigo da filial
@param cTicket   , Caracter, Codigo �nico do processo
@param cFields   , Caracter, Campos que devem ser retornados.
@param cOrder    , Caracter, Ordena��o do retorno da consulta.
@param cPage     , Caracter, P�gina de retorno.
@param cPageSize , Caracter, Tamanho da p�gina.
@param cMap      , Mapa dos campos utilizados na consulta.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGetSum(cBranch, cTicket, cFields, cOrder, cPage, cPageSize, cMap)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"TICKET"  , cTicket})

	//Chama a funcao para retornar os dados.
	aReturn := GetResults(.T., aQryParam, cOrder, cPage, cPageSize, cFields, cMap)

Return aReturn

/*/{Protheus.doc} GET OPC api/pcp/v1/mrpresults/optional/{branchId}/{ticket}
Retorna os dados do opcional

@type  WSMETHOD
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param	branchId   , Character, Codigo da filial para fazer a pesquisa
@param	ticket     , Character, Codigo �nico do processo para fazer a pesquisa.
@param	cOptionalID, Character, C�digo do ID do Opcional
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPC PATHPARAM branchId, ticket, cOptionalID QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetOPC(Self:branchId, Self:ticket, Self:cOptionalID)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetOPC
Funcao para disparar as acoes da API de Resultados do MRP, para o metodo GET do memo e string de opcional.

@type  Function
@author brunno.costa
@since 20/11/2019
@version P12.1.27
@param cBranch    , Caracter, Codigo da filial
@param cTicket    , Caracter, Codigo �nico do processo
@param cProduto   , Caracter, Codigo �nico do processo
@param cOptionalID, Caracter, Codigo �nico do processo
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGetOPC(cBranch, cTicket, cOptionalID)

	Local aReturn   := {}
	Local cAliasQry := GetNextAlias()
	Local oJson     := JsonObject():New()

	BeginSql Alias cAliasQry
		SELECT HWD_ERPOPC,
			   HWD_OPCION,
			   HWD_ERPMOP
		  FROM %Table:HWD%
		 WHERE HWD_TICKET = %Exp:cTicket%
		   AND HWD_KEYMAT = %Exp:cOptionalID%
		   AND HWD_FILIAL = %Exp:cBranch%
		   AND %NotDel%
	EndSql

	If (cAliasQry)->(!Eof())
		oJson["optionalMemo"]     := STR2Array((cAliasQry)->HWD_ERPMOP, .F.)
		oJson["optionalString"]   := (cAliasQry)->HWD_ERPOPC
		oJson["optionalSelected"] := Iif(Empty((cAliasQry)->HWD_OPCION), (cAliasQry)->HWD_ERPOPC, (cAliasQry)->HWD_OPCION)

		aAdd(aReturn, .T.)
		aAdd(aReturn, oJson:toJSON())
		aAdd(aReturn, 200)
	Else
		oJson["optionalMemo"]     := ""
		oJson["optionalString"]   := ""
		oJson["optionalSelected"] := ""

		aAdd(aReturn, .F.)
		aAdd(aReturn, oJson:toJSON())
		aAdd(aReturn, 400)
	End
	(cAliasQry)->(dbCloseArea())

Return aReturn

/*/{Protheus.doc} GET PARAM api/pcp/v1/mrpresults/parameters/{branchId}/{ticket}
Retorna os parametros de uma execu��o do MRP

@type  WSMETHOD
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param	branchId , Character, Codigo da filial para fazer a pesquisa
@param	ticket   , Character, Codigo �nico do processo para fazer a pesquisa.
@param	Fields   , Character, Campos que ser�o retornados no GET.
@param  cOrder   , Caracter, Ordena��o do retorno da consulta.
@param  cPage    , Caracter, P�gina de retorno.
@param  cPageSize, Caracter, Tamanho da p�gina.
@param  format   , Logico   , Indica que deve formatar os par�metros retornados
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PARAM PATHPARAM branchId, ticket QUERYPARAM Fields, Order, Page, PageSize, format WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetPar(Self:branchId, Self:ticket, Self:Fields, Self:Order, Self:Page, Self:PageSize, LISTA_PARAMETROS_MRP, Self:format)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetPar
Funcao para disparar as acoes da API de Resultados do MRP, para o metodo GET dos parametros do MRP.

@type  Function
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param cBranch , Caracter, Codigo da filial
@param cTicket , Caracter, Codigo �nico do processo
@param cFields , Caracter, Campos que devem ser retornados.
@param cOrder    , Caracter, Ordena��o do retorno da consulta.
@param cPage     , Caracter, P�gina de retorno.
@param cPageSize , Caracter, Tamanho da p�gina.
@param cMap      , Mapa dos campos utilizados na consulta.
@param lFormat   , Indica se deve formatar os par�metros retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGetPar(cBranch, cTicket, cFields, cOrder, cPage, cPageSize, cMap, lFormat)
	Local aReturn   := {}
	Local aQryParam := {}

	Default lFormat := .F.

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"TICKET"  , cTicket})

	//Chama a funcao para retornar os dados.
	aReturn := GetResults(.T., aQryParam, cOrder, cPage, cPageSize, cFields, cMap)

	If lFormat
		aReturn := formatPar(aReturn)
	EndIf

Return aReturn

/*/{Protheus.doc} GET SUMPROD api/pcp/v1/mrpresults/summarized/{branchId}/{ticket}/{product}
Retorna o resultado sumarizado de um produto em uma execu��o do MRP

@type  WSMETHOD
@author renan.roeder
@since 22/11/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param	Fields  , Character, Campos que ser�o retornados no GET.
@param cOrder   , Caracter, Ordena��o do retorno da consulta.
@param cPage    , Caracter, P�gina de retorno.
@param cPageSize, Caracter, Tamanho da p�gina.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET SUMPROD PATHPARAM branchId, ticket, product, optionalId QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetSPd(Self:branchId, Self:ticket, Self:product, Self:optionalId, Self:Fields, Self:Order, Self:Page, Self:PageSize, LISTA_RESULTADOS_SUMARIZADOS)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetSPd
Funcao para disparar as acoes da API de Resultados do MRP, para o metodo GET dos resultados sumarizados.

@type  Function
@author renan.roeder
@since 22/11/2019
@version P12.1.27
@param cBranch    , Caracter, Codigo da filial
@param cTicket    , Caracter, Codigo �nico do processo
@param cProduct   , Caracter, C�digo do produto
@param cOptionalId, Caracter, ID do Opcional
@param cFields    , Caracter, Campos que devem ser retornados.
@param cOrder     , Caracter, Ordena��o do retorno da consulta.
@param cPage      , Caracter, P�gina de retorno.
@param cPageSize  , Caracter, Tamanho da p�gina.
@param cMap       , Mapa dos campos utilizados na consulta.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGetSPd(cBranch, cTicket, cProduct, cOptionalId, cFields, cOrder, cPage, cPageSize, cMap)
	Local aReturn   := {}
	Local aQryParam := {}
	Local lUsaMe    := ticketME(cTicket, .F.)

	//Adiciona os filtros como QueryParam.
	If !lUsaMe
		aAdd(aQryParam, {"BRANCHID" , cBranch})
	EndIf
	aAdd(aQryParam, {"TICKET"    , cTicket})
	aAdd(aQryParam, {"PRODUCT"   , cProduct})
	aAdd(aQryParam, {"OPTIONALID", cOptionalId})

	//Chama a funcao para retornar os dados.
	aReturn := GetResults(.T., aQryParam, cOrder, cPage, cPageSize, cFields, cMap)

Return aReturn

/*/{Protheus.doc} GET TRACED api/pcp/v1/mrpresults/traced/{branchId}/{ticket}
Retorna o resultado rastreado de uma execu��o do MRP

@type  WSMETHOD
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET TRAPDDT PATHPARAM branchId, ticket, product, necessityDate QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetTPD(Self:branchId, Self:ticket, Self:product, Self:necessityDate, Self:Fields, Self:Order, Self:Page, Self:PageSize, LISTA_RESULTADOS_RASTREADOS)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetTPD
Funcao para disparar as acoes da API de Resultados do MRP, para o metodo GET dos resultados rastreados.

@type  Function
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param cBranch    , Caracter, Codigo da filial
@param cTicket    , Caracter, Codigo �nico do processo
@param cProduct   , Caracter, C�digo doproduto
@param cOptionalID, Caracter, C�digo do opcional do produto
@param cFields    , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGetTPD(cBranch, cTicket, cProduct, cOptionalID, dNecessityDate, cFields, cOrder, cPage, cPageSize, cMap)
	Local aReturn   := {}
	Local aQryParam := {}
	Local lUsaMe    := ticketME(cTicket, .F.)

	//Adiciona os filtros como QueryParam.
	If !lUsaMe
		aAdd(aQryParam, {"BRANCHID"      , cBranch})
	EndIf
	aAdd(aQryParam, {"TICKET"        , cTicket})
	aAdd(aQryParam, {"COMPONENTCODE" , cProduct})
	aAdd(aQryParam, {"OPTIONALID"    , cOptionalID})
	aAdd(aQryParam, {"NECESSITYDATE" , dToS(dNecessityDate)})

	//Chama a funcao para retornar os dados.
	aReturn := GetResults(.T., aQryParam, cOrder, cPage, cPageSize, cFields, cMap)

Return aReturn

/*/{Protheus.doc} GET SUBSTITUTES api/pcp/v1/mrpresults/substitutes/{branchId}/{ticket}/{parentDocumentType}/{parentDocument}/{sequenceInStructure}/{substitutionKey}
Retorna os resultados rastreados referente uma substitui��o espec�fica

@type  WSMETHOD
@author brunno.costa
@since 05/12/2019
@version P12.1.27
@param	branchId           , Character, Codigo da filial para fazer a pesquisa
@param	ticket             , Character, Codigo �nico do processo para fazer a pesquisa.
@param	parentDocumentType , Character, Tipo do documento pai
@param	parentDocument     , Character, Documento pai
@param	sequenceInStructure, Character, Sequ�ncia TRT do produto
@param	substitutionKey    , Character, Chave de substitui��o
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET SUBSTITUTES PATHPARAM branchId, ticket, parentDocumentType, parentDocument, sequenceInStructure, substitutionKey QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetSUB(Self:branchId, Self:ticket, Self:parentDocumentType, Self:parentDocument, Self:sequenceInStructure, Self:substitutionKey, Self:Fields, Self:Order, Self:Page, Self:PageSize, LISTA_RESULTADOS_RASTREADOS)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetSUB
Funcao para disparar as acoes da API de Resultados do MRP, para o metodo GET dos resultados rastreados.

@type  Function
@author brunno.costa
@since 05/12/2019
@version P12.1.27
@param cBranch    , Caracter, Codigo da filial
@param cTicket    , Caracter, Codigo �nico do processo
@param cTpDocPai  , Caracter, Tipo do documento pai
@param cDocumento , Caracter, Documento pai
@param cTRT       , Caracter, Sequ�ncia TRT do produto
@param cChave     , Caracter, Chave de substitui��o
@param cFields    , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico   - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Caracter - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric  - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGetSUB(cBranch, cTicket, cTpDocPai, cDocumento, cTRT, cChave, cFields, cOrder, cPage, cPageSize, cMap)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros como QueryParam.
	aAdd(aQryParam, {"BRANCHID"           , cBranch   })
	aAdd(aQryParam, {"TICKET"             , cTicket   })
	aAdd(aQryParam, {"parentDocumentType" , cTpDocPai })
	aAdd(aQryParam, {"parentDocument"     , cDocumento})
	aAdd(aQryParam, {"sequenceInStructure", cTRT      })
	aAdd(aQryParam, {"substitutionKey"    , cChave    })

	//Chama a funcao para retornar os dados.
	aReturn := GetResults(.T., aQryParam, cOrder, cPage, cPageSize, cFields, cMap)

Return aReturn

/*/{Protheus.doc} GET PROCESS api/pcp/v1/processed
Retorna todos os processamentos do MRP.

@type  WSMETHOD
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PROCESS PATHPARAM branchId QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetAPcd(Self:branchId, Self:Fields, Self:Order, Self:Page, Self:PageSize, LISTA_PROCESSAMENTOS_MRP)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetAPcd
Funcao para disparar as acoes da API de Resultados do MRP, para o metodo GET dos processamentos do MRP.

@type  Function
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param cBranch  , Caracter, Codigo da filial
@param cFields  , Caracter, Campos que devem ser retornados.
@param cOrder   , Character, Ordenacao desejada do retorno.
@param cPage    , Caracter, P�gina de retorno.
@param cPageSize, Caracter, Tamanho da p�gina.
@param cMap     , Caracter, Mapa dos campos utilizados na consulta.
@param cStatus  , Caracter, indicador do status de campo para filtro dos resultados conforme  HW3_STATUS
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpGetAPcd(cBranch, cFields, cOrder, cPage, cPageSize, cMap, cStatus)
	Local aReturn   := {}
	Local aQryParam := {}

	Default cStatus := ""

	aAdd(aQryParam, {"BRANCHID", cBranch})

	//Repassa filtros de status
	If !Empty(cStatus)
		aAdd(aQryParam, {"status", ".IN." + AllTrim(cStatus) })
	EndIf

	//Chama a funcao para retornar os dados.
	aReturn := GetResults(.T., aQryParam, cOrder, cPage, cPageSize, cFields, cMap)

Return aReturn

/*/{Protheus.doc} GET TICKET api/pcp/v1/processed/{branchId}/{ticket}
Retorna informa��es de um processamento do MRP

@type  WSMETHOD
@author lucas.franca
@since 31/01/2020
@version P12.1.27
@param	branchId, Character, Codigo da filial para fazer a pesquisa
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET TICKET PATHPARAM branchId, ticket QUERYPARAM Fields WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetPrc(Self:branchId, Self:ticket, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetPrc
Fun��o para retornar informa��es de um processamento do MRP

@type  Function
@author lucas.franca
@since 24/04/2019
@version P12.1.27
@param cBranch, Character, C�digo da filial
@param cTicket, Character, Ticket de processamento
@param cFields, Character, Fields que devem ser retornados pela api
@return aReturn, Array, Array com as informa��es da requisi��o.
                        aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Function MrpGetPrc(cBranch, cTicket, cFields)
	Local aReturn := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"TICKET"  , cTicket})

	//Processa o GET
	aReturn := GetResults(.F., aQryParam, Nil, Nil, Nil, cFields, LISTA_PROCESSAMENTOS_MRP)
Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API

@type  Static Function
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields(nType)
	Local aFields := {}
/*
	O array de mapeamento do JSON e composto por:
	aArray[1]
	aArray[1][1] = Nome do elemento do JSON que contem a informacao.
	aArray[1][2] = Nome da coluna da tabela correspondente a informacao.
	aArray[1][3] = Tipo de dado no banco de dados.
	aArray[1][4] = Tamanho do campo.
	aArray[1][5] = Decimais do campo, quando e do tipo numerico.
*/

	If nType == 1
		//Estrutura dos resultados sumarizados
		aFields := { ;
					{"branchId"                 , "HWB_FILIAL", "C", FWSizeFilial()                        , 0},;
					{"ticket"                   , "HWB_TICKET", "C", GetSx3Cache("HWB_TICKET","X3_TAMANHO"), 0},;
					{"necessityDate"            , "HWB_DATA"  , "D", GetSx3Cache("HWB_DATA"  ,"X3_TAMANHO"), 0},;
					{"product"                  , "HWB_PRODUT", "C", GetSx3Cache("HWB_PRODUT","X3_TAMANHO"), 0},;
					{"optionalId"               , "HWB_IDOPC" , "C", GetSx3Cache("HWB_IDOPC" ,"X3_TAMANHO"), 0},;
					{"stockBalance"             , "HWB_QTSLES", "N", GetSx3Cache("HWB_QTSLES","X3_TAMANHO"), GetSx3Cache("HWB_QTSLES","X3_DECIMAL")},;
					{"inFlows"                  , "HWB_QTENTR", "N", GetSx3Cache("HWB_QTENTR","X3_TAMANHO"), GetSx3Cache("HWB_QTENTR","X3_DECIMAL")},;
					{"outFlows"                 , "HWB_QTSAID", "N", GetSx3Cache("HWB_QTSAID","X3_TAMANHO"), GetSx3Cache("HWB_QTSAID","X3_DECIMAL")},;
					{"structureOutFlows"        , "HWB_QTSEST", "N", GetSx3Cache("HWB_QTSEST","X3_TAMANHO"), GetSx3Cache("HWB_QTSEST","X3_DECIMAL")},;
					{"finalBalance"             , "HWB_QTSALD", "N", GetSx3Cache("HWB_QTSALD","X3_TAMANHO"), GetSx3Cache("HWB_QTSALD","X3_DECIMAL")},;
					{"necessityQuantity"        , "HWB_QTNECE", "N", GetSx3Cache("HWB_QTNECE","X3_TAMANHO"), GetSx3Cache("HWB_QTNECE","X3_DECIMAL")},;
					{"startDate"                , "HWB_DTINIC", "D", GetSx3Cache("HWB_DTINIC","X3_TAMANHO"), 0};
				   }

		dbSelectArea("HWB")
		If FieldPos("HWB_QTRENT") > 0
			aAdd(aFields, {"transferIn"         , "HWB_QTRENT", "N", GetSx3Cache("HWB_QTRENT","X3_TAMANHO"), GetSx3Cache("HWB_QTRENT","X3_DECIMAL")})
			aAdd(aFields, {"transferOut"        , "HWB_QTRSAI", "N", GetSx3Cache("HWB_QTRSAI","X3_TAMANHO"), GetSx3Cache("HWB_QTRSAI","X3_DECIMAL")})
		EndIf

	ElseIf nType == 2
		//Estrutura dos resultados rastreados
		aFields := { ;
					{"branchId"                 , "HWC_FILIAL", "C", FWSizeFilial()                        , 0},;
					{"ticket"                   , "HWC_TICKET", "C", GetSx3Cache("HWC_TICKET","X3_TAMANHO"), 0},;
					{"necessityDate"            , "HWC_DATA"  , "D", GetSx3Cache("HWC_DATA"  ,"X3_TAMANHO"), 0},;
					{"parentDocumentType"       , "HWC_TPDCPA", "C", GetSx3Cache("HWC_TPDCPA","X3_TAMANHO"), 0},;
					{"parentDocument"           , "HWC_DOCPAI", "C", GetSx3Cache("HWC_DOCPAI","X3_TAMANHO"), 0},;
					{"childDocument"            , "HWC_DOCFIL", "C", GetSx3Cache("HWC_DOCFIL","X3_TAMANHO"), 0},;
					{"componentCode"            , "HWC_PRODUT", "C", GetSx3Cache("HWC_PRODUT","X3_TAMANHO"), 0},;
					{"optionalId"               , "HWC_IDOPC" , "C", GetSx3Cache("HWC_IDOPC" ,"X3_TAMANHO"), 0},;
					{"sequenceInStructure"      , "HWC_TRT"   , "C", GetSx3Cache("HWC_TRT"   ,"X3_TAMANHO"), 0},;
					{"originalNecessity"        , "HWC_QTNEOR", "N", GetSx3Cache("HWC_QTNEOR","X3_TAMANHO"), GetSx3Cache("HWC_QTNEOR","X3_DECIMAL")},;
					{"stockBalanceQuantity"     , "HWC_QTSLES", "N", GetSx3Cache("HWC_QTSLES","X3_TAMANHO"), GetSx3Cache("HWC_QTSLES","X3_DECIMAL")},;
					{"quantityStockWriteOff"    , "HWC_QTBXES", "N", GetSx3Cache("HWC_QTBXES","X3_TAMANHO"), GetSx3Cache("HWC_QTBXES","X3_DECIMAL")},;
					{"quantitySubstitution"     , "HWC_QTSUBS", "N", GetSx3Cache("HWC_QTSUBS","X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS","X3_DECIMAL")},;
					{"alocationQuantity"        , "HWC_QTEMPE", "N", GetSx3Cache("HWC_QTEMPE","X3_TAMANHO"), GetSx3Cache("HWC_QTEMPE","X3_DECIMAL")},;
					{"quantityNecessity"        , "HWC_QTNECE", "N", GetSx3Cache("HWC_QTNECE","X3_TAMANHO"), GetSx3Cache("HWC_QTNECE","X3_DECIMAL")},;
					{"structureReview"          , "HWC_REV"   , "C", GetSx3Cache("HWC_REV"   ,"X3_TAMANHO"), 0},;
					{"routing"                  , "HWC_ROTEIR", "C", GetSx3Cache("HWC_ROTEIR","X3_TAMANHO"), 0},;
					{"operation"                , "HWC_OPERAC", "C", GetSx3Cache("HWC_OPERAC","X3_TAMANHO"), 0},;
					{"consumptionLocation"      , "HWC_LOCAL" , "C", GetSx3Cache("HWC_LOCAL" ,"X3_TAMANHO"), 0},;
					{"recordKey"                , "HWC_CHAVE" , "C", GetSx3Cache("HWC_CHAVE" ,"X3_TAMANHO"), 0},;
					{"substitutionKey"          , "HWC_CHVSUB", "C", GetSx3Cache("HWC_CHVSUB","X3_TAMANHO"), 0},;
					{"breakupSequence"          , "HWC_SEQUEN", "N", GetSx3Cache("HWC_SEQUEN","X3_TAMANHO"), 0},;
					{"erpDocument"              , "HWC_DOCERP", "C", GetSx3Cache("HWC_DOCERP","X3_TAMANHO"), 0},;
					{"erpDocumentType"          , "HWC_TDCERP", "C", GetSx3Cache("HWC_TDCERP","X3_TAMANHO"), 0},;
					{"recordStatus"             , "HWC_STATUS", "C", GetSx3Cache("HWC_STATUS","X3_TAMANHO"), 0},;
					{"productionVersion"        , "HWC_VERSAO", "C", GetSx3Cache("HWC_VERSAO","X3_TAMANHO"), 0},;
					{"recno"                    , "R_E_C_N_O_", "N", 10                                    , 0};
					}

		dbSelectArea("HWC")
		If FieldPos("HWC_ROTFIL") > 0
			aAdd(aFields, {"routingChildDocument", "HWC_ROTFIL", "C", GetSx3Cache("HWC_ROTFIL","X3_TAMANHO"), 0})
		EndIf
		If FieldPos("HWC_QTRENT") > 0
			aAdd(aFields, {"transferIn"          , "HWC_QTRENT", "N", GetSx3Cache("HWC_QTRENT","X3_TAMANHO"), GetSx3Cache("HWC_QTRENT","X3_DECIMAL")})
			aAdd(aFields, {"transferOut"         , "HWC_QTRSAI", "N", GetSx3Cache("HWC_QTRSAI","X3_TAMANHO"), GetSx3Cache("HWC_QTRSAI","X3_DECIMAL")})
		EndIf

	ElseIf nType == 3
		//Estrutura dos parametros
		aFields := { ;
					{"branchId"                 , "HW1_FILIAL", "C", FWSizeFilial()                        , 0},;
					{"parameter"                , "HW1_PARAM" , "C", GetSx3Cache("HW1_PARAM" ,"X3_TAMANHO"), 0},;
					{"value"                    , "HW1_VAL"   , "C", GetSx3Cache("HW1_VAL"   ,"X3_TAMANHO"), 0},;
					{"list"                     , "HW1_LISTA" , "M", GetSx3Cache("HW1_LISTA" ,"X3_TAMANHO"), 0},;
					{"ticket"                   , "HW1_TICKET", "C", GetSx3Cache("HW1_TICKET","X3_TAMANHO"), 0};
				   }

	ElseIf nType == 4
		//Estrutura dos resultados sumarizados
		aFields := { ;
					{"branchId"                 , "HWB_FILIAL", "C", FWSizeFilial()                        , 0},;
					{"ticket"                   , "HWB_TICKET", "C", GetSx3Cache("HWB_TICKET","X3_TAMANHO"), 0},;
					{"optionalId"               , "HWB_IDOPC" , "C", GetSx3Cache("HWB_IDOPC" ,"X3_TAMANHO"), 0},;
					{"product"                  , "HWB_PRODUT", "C", GetSx3Cache("HWB_PRODUT","X3_TAMANHO"), 0};
				   }

	ElseIf nType == 5
		aFields := { ;
					{"branchId"                 , "HW3_FILIAL", "C", FWSizeFilial()                        , 0},;
					{"ticket"                   , "HW3_TICKET", "C", GetSx3Cache("HW3_TICKET","X3_TAMANHO"), 0},;
					{"startDate"                , "HW3_DTINIC", "D", GetSx3Cache("HW3_DTINIC","X3_TAMANHO"), 0},;
					{"startTime"                , "HW3_HRINIC", "C", GetSx3Cache("HW3_HRINIC","X3_TAMANHO"), 0},;
					{"endDate"                  , "HW3_DTFIM" , "D", GetSx3Cache("HW3_DTFIM" ,"X3_TAMANHO"), 0},;
					{"endTime"                  , "HW3_HRFIM" , "C", GetSx3Cache("HW3_HRFIM" ,"X3_TAMANHO"), 0},;
					{"user"                     , "HW3_USER"  , "C", GetSx3Cache("HW3_USER"  ,"X3_TAMANHO"), 0},;
					{"status"                   , "HW3_STATUS", "C", GetSx3Cache("HW3_STATUS","X3_TAMANHO"), 0};
				   }

	ElseIf nType == 6
		aFields := { ;
					{"branchId"                 , "MG_FILIAL", "C", FWSizeFilial()                       , 0},;
					{"ticket"                   , "MG_TICKET", "C", GetSx3Cache("MG_TICKET","X3_TAMANHO"), 0},;
					{"necessityDate"            , "MG_DATNEC", "D", GetSx3Cache("MG_DATNEC","X3_TAMANHO"), 0},;
					{"documentType"             , "MG_TPDCAL", "C", GetSx3Cache("MG_TPDCAL","X3_TAMANHO"), 0},;
					{"document"                 , "MG_DOCALT", "C", GetSx3Cache("MG_DOCALT","X3_TAMANHO"), 0},;
					{"componentCode"            , "MG_PRODUT", "C", GetSx3Cache("MG_PRODUT","X3_TAMANHO"), 0},;
					{"sequenceInStructure"      , "MG_TRT"   , "C", GetSx3Cache("MG_TRT"   ,"X3_TAMANHO"), 0},;
					{"quantityNecessityFrom"    , "MG_QTNEDE", "N", GetSx3Cache("MG_QTNEDE","X3_TAMANHO"), GetSx3Cache("MG_QTNEDE","X3_DECIMAL")},;
					{"quantityNecessityTo"      , "MG_QTNEPA", "N", GetSx3Cache("MG_QTNEPA","X3_TAMANHO"), GetSx3Cache("MG_QTNEPA","X3_DECIMAL")},;
					{"alocationQuantityFrom"    , "MG_QTEMDE", "N", GetSx3Cache("MG_QTEMDE","X3_TAMANHO"), GetSx3Cache("MG_QTEMDE","X3_DECIMAL")},;
					{"alocationQuantityTo"      , "MG_QTEMPA", "N", GetSx3Cache("MG_QTEMPA","X3_TAMANHO"), GetSx3Cache("MG_QTEMPA","X3_DECIMAL")},;
					{"recordKey"                , "MG_CHAVE" , "C", GetSx3Cache("MG_CHAVE" ,"X3_TAMANHO"), 0},;
					{"substitutionKey"          , "MG_CHVSUB", "C", GetSx3Cache("MG_CHVSUB","X3_TAMANHO"), 0},;
					{"breakupSequence"          , "MG_SEQUEN", "N", GetSx3Cache("MG_SEQUEN","X3_TAMANHO"), 0},;
					{"optionalId"               , "MG_IDOPC" , "C", GetSx3Cache("MG_IDOPC" ,"X3_TAMANHO"), 0},;
					{"user"                     , "MG_USER"  , "C", GetSx3Cache("MG_USER"  ,"X3_TAMANHO"), 0},;
					{"logDate"                  , "MG_DATA"  , "D", GetSx3Cache("MG_DATA"  ,"X3_TAMANHO"), 0},;
					{"logTime"                  , "MG_HORA"  , "C", GetSx3Cache("MG_HORA"  ,"X3_TAMANHO"), 0};
			 	   }
	EndIf

Return aFields

/*/{Protheus.doc} GetResults
Executa o processamento do metodo GET dos resultados do MRP.

@type  Static Function
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param lLista   , Logic    , Indica se devera retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Static Function GetResults(lLista, aQuery, cOrder, nPage, nPageSize, cFields, cMap)
	Local aReturn  := {.T.,"",200}
	Local oMRPApi  := defMRPApi("GET",cOrder) //Instancia da classe MRPApi para o metodo GET

	//Seta os Processos de paginacao, filtros e campos para retorno
	oMRPApi:setFields(cFields)
	oMRPApi:setPage(nPage)
	oMRPApi:setPageSize(nPageSize)
	oMRPApi:setQueryParams(aQuery)
	oMRPApi:setUmRegistro(!lLista)

	//Executa o processamento
	aReturn[1] := oMRPApi:processar(cMap)

	//Retorna o status do processamento
	aReturn[3] := oMRPApi:getStatus()

	If aReturn[1]
		//Se processou com sucesso, recupera o JSON com os dados.
		aReturn[2] := oMRPApi:getRetorno(1)
	Else
		//Ocorreu algum erro no processo. Recupera mensagem de erro.
		aReturn[2] := oMRPApi:getMessage()
	EndIf

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type  Static Function
@author renan.roeder
@since 20/11/2019
@version P12.1.27
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@return oMRPApi , Object   , Refer�ncia da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP dos resultados sumarizados (distinct produto)
	oMRPApi:setAPIMap(LISTA_RESULTADOS_SUMARIZADOS, _aMapMat , "HWB", .T., cOrder)
	//Seta o APIMAP dos resultados rastreados
	oMRPApi:setAPIMap(LISTA_RESULTADOS_RASTREADOS, _aMapRas , "HWC", .F., cOrder)
	//Seta o APIMAP dos parametros
	oMRPApi:setAPIMap(LISTA_PARAMETROS_MRP, _aMapPar , "HW1", .F., cOrder)
    //Seta o APIMAP dos resultados sumarizados
	oMRPApi:setAPIMap(LISTA_RESULTADOS_SUMARIZADOS_PRODUTO, _aMapMtP , "HWB", .T., cOrder)
	//Seta o APIMAP dos processamentos do MRP
	oMRPApi:setAPIMap(LISTA_PROCESSAMENTOS_MRP, _aMapPcd , "HW3", .T., cOrder)
	//Seta o APIMAP das altera��es das tabelas de resultados do MRP
	oMRPApi:setAPIMap(LISTA_ALTERACAO_RASTREIO, _aMapRas , "HWC", .F., cOrder)
	//Seta o APIMAP das altera��es das tabelas de resultados do MRP
	oMRPApi:setAPIMap(LISTA_ALTERACAO_MATRIZ, _aMapMat , "HWB", .F., cOrder)

	If FWAliasInDic("SMG", .F.)
		//Seta o APIMAP das altera��es das tabelas de resultados do MRP
		oMRPApi:setAPIMap(LISTA_LOG_ALTERACAO, _aMapLog , "SMG", .F., cOrder)
		oMRPApi:setKeySearch(LISTA_LOG_ALTERACAO,{"MG_FILIAL","MG_TICKET","MG_TPDCAL","MG_DOCALT","MG_TRT","MG_PRODUT","MG_SEQUEN","MG_USER","MG_DATA","MG_HORA"})
	EndIf

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch(LISTA_RESULTADOS_SUMARIZADOS        ,{"HWB_FILIAL","HWB_TICKET"})
	oMRPApi:setKeySearch(LISTA_RESULTADOS_RASTREADOS         ,{"HWC_FILIAL","HWC_TICKET","R_E_C_N_O_"})
	oMRPApi:setKeySearch(LISTA_PARAMETROS_MRP                ,{"HW1_FILIAL","HW1_TICKET"})
	oMRPApi:setKeySearch(LISTA_RESULTADOS_SUMARIZADOS_PRODUTO,{"HWB_FILIAL","HWB_TICKET"})
	oMRPApi:setKeySearch(LISTA_PROCESSAMENTOS_MRP            ,{"HW3_FILIAL"})
	oMRPApi:setKeySearch(LISTA_ALTERACAO_MATRIZ              ,{"HWB_FILIAL","HWB_TICKET","HWB_DATA","HWB_PRODUT","HWB_IDOPC"})
	oMRPApi:setKeySearch(LISTA_ALTERACAO_RASTREIO            ,{"HWC_FILIAL","HWC_TICKET","HWC_TPDCPA","HWC_DOCPAI","HWC_TRT","HWC_PRODUT","HWC_CHAVE","HWC_CHVSUB","HWC_SEQUEN","R_E_C_N_O_"})

Return oMRPApi

//dummy function
Function MrpResults()
Return

/*/{Protheus.doc} GET PROCREGS api/pcp/v1/mrpresults/process/{ticket}
Busca os registros que devem ser processados

@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
/*/
WSMETHOD GET PROCREGS PATHPARAM ticket QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetHWC( Self:ticket, .F. )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetHWC
Busca os registros que devem ser processados

@type  Function
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param lRetJSON , Logical  , Identifica se o retorno deve ser em JSON ou em STRING
/*/
Function MrpGetHWC(cTicket, lRetJSON)

	Local aResult 	 := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local lNivelHWB  := .F.
	Local lUsaME     := .F.
	Local nPos       := 0
	Local oDados     := JsonObject():New()
	Local oDominio   := Nil
	Local oParametro := Nil
	Local oLogs      := Nil

	dbSelectArea("HWB")
	If FieldPos("HWB_NIVEL") > 0
		lNivelHWB := .T.
	EndIf

	lUsaME := ticketME(cTicket, .T., @oParametro, @oDominio, @oLogs)

	cQuery := "SELECT HWC.HWC_FILIAL, "
	cQuery +=       " HWC.HWC_DATA, "
	cQuery +=       " HWC.HWC_TPDCPA, "
	cQuery +=       " HWC.HWC_DOCPAI, "
	cQuery +=       " HWC.HWC_DOCFIL, "
	cQuery +=       " HWC.HWC_PRODUT, "
	cQuery +=       " HWC.HWC_IDOPC, "
	cQuery +=       " HWC.HWC_TRT, "
	cQuery +=       " HWC.HWC_QTNEOR, "
	cQuery +=       " HWC.HWC_QTSLES, "
	cQuery +=       " HWC.HWC_QTBXES, "
	cQuery +=       " HWC.HWC_QTSUBS, "
	cQuery +=       " HWC.HWC_QTEMPE, "
	cQuery +=       " HWC.HWC_QTNECE, "
	cQuery +=       " HWC.HWC_REV, "
	cQuery +=       " HWC.HWC_ROTEIR, "
	cQuery +=       " HWC.HWC_OPERAC, "
	dbSelectArea("HWC")
	If FieldPos("HWC_ROTFIL") > 0
		cQuery +=       " HWC.HWC_ROTFIL, "
	Else
		cQuery +=       " '' as HWC_ROTFIL, "
	EndIf
	cQuery +=       " HWC.HWC_CHAVE, "
	cQuery +=       " HWC.HWC_CHVSUB, "
	cQuery +=       " HWC.HWC_SEQUEN, "
	cQuery +=       " COALESCE(HWB.HWB_DTINIC, HWC.HWC_DATA) AS HWB_DTINIC, "
	If lNivelHWB
		cQuery +=   " HWB.HWB_NIVEL AS NIVEL, "
	Else
		cQuery +=   " HWA.HWA_NIVEL AS NIVEL, "
	EndIf

	//Se n�o possui o campo na HWA, marca para gerar sempre solicita��o de compra
	If HWA->(FieldPos("HWA_CONTRA")) > 0
		cQuery +=   " HWA.HWA_CONTRA, "
	Else
		cQuery +=   " '2' AS HWA_CONTRA, "
	EndIf

	cQuery +=       " CASE WHEN HWC.HWC_LOCAL = ' ' "
	cQuery +=            " THEN HWA.HWA_LOCPAD "
	cQuery +=            " ELSE HWC.HWC_LOCAL "
	cQuery +=       " END AS HWC_LOCAL, "
	cQuery +=       " HWC.R_E_C_N_O_ AS RECHWC "
	cQuery +=  " FROM " + RetSqlName("HWA") + " HWA, "  //Tabela de Produto
	cQuery +=             RetSqlName("HWC") + " HWC " //Tabela de rastreio
	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("HWB") + " HWB " //Tabela da matriz
	cQuery +=    " ON HWB.HWB_TICKET = HWC.HWC_TICKET "
	cQuery +=   " AND HWB.HWB_PRODUT = HWC.HWC_PRODUT "
	cQuery +=   " AND HWB.HWB_IDOPC  = HWC.HWC_IDOPC "
	cQuery +=   " AND HWB.HWB_DATA   = HWC.HWC_DATA "
	If lUsaME
		cQuery += " AND " + oDominio:oMultiEmp:queryFilial("HWB", "HWB_FILIAL", .T.)
		cQuery += " AND HWB.HWB_FILIAL = HWC.HWC_FILIAL"
	Else
		cQuery += " AND HWB.HWB_FILIAL = '" + xFilial("HWB") + "' "
	EndIf
	cQuery +=   " AND HWB.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE HWC.HWC_TICKET = '" + cTicket + "' "
	cQuery +=   " AND HWA.HWA_PROD   = HWC.HWC_PRODUT "
	cQuery +=   " AND HWC.HWC_STATUS NOT IN('1','3') " //Somente o que ainda n�o foi processado.
	cQuery +=   " AND HWA.HWA_FILIAL = '" + xFilial("HWA") + "' "
	If lUsaME
		cQuery += " AND " + oDominio:oMultiEmp:queryFilial("HWC", "HWC_FILIAL", .T.)
	Else
		cQuery += " AND HWC.HWC_FILIAL = '" + xFilial("HWC") + "' "
	EndIf
	cQuery +=   " AND HWA.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND HWC.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY HWC.HWC_FILIAL, NIVEL, HWC.HWC_DATA, HWC.HWC_SEQUEN, HWC.HWC_DOCPAI, HWC.HWC_PRODUT, HWC.HWC_IDOPC "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	//Ajusta o tipo dos campos na query.
	TcSetField(cAliasQry, 'HWC_QTNEOR', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'HWC_QTSLES', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'HWC_QTBXES', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'HWC_QTSUBS', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'HWC_QTEMPE', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'HWC_QTNECE', 'N', _aTamQtd[1], _aTamQtd[2])

	oDados["items"           ] := {}
	oDados["useMultiBranches"] := lUsaME

	nPos := 0
	While (cAliasQry)->(!Eof())

		aAdd(oDados["items"], JsonObject():New())
		nPos++

		oDados["items"][nPos]['branchId'             ] := (cAliasQry)->HWC_FILIAL
		oDados["items"][nPos]['necessityDate'        ] := getDate((cAliasQry)->HWC_DATA)
		oDados["items"][nPos]['parentDocumentType'   ] := (cAliasQry)->HWC_TPDCPA
		oDados["items"][nPos]['parentDocument'       ] := (cAliasQry)->HWC_DOCPAI
		oDados["items"][nPos]['childDocument'        ] := (cAliasQry)->HWC_DOCFIL
		oDados["items"][nPos]['componentCode'        ] := (cAliasQry)->HWC_PRODUT
		oDados["items"][nPos]['optionalId'           ] := (cAliasQry)->HWC_IDOPC
		oDados["items"][nPos]['sequenceInStructure'  ] := (cAliasQry)->HWC_TRT
		oDados["items"][nPos]['originalNecessity'    ] := (cAliasQry)->HWC_QTNEOR
		oDados["items"][nPos]['stockBalanceQuantity' ] := (cAliasQry)->HWC_QTSLES
		oDados["items"][nPos]['quantityStockWriteOff'] := (cAliasQry)->HWC_QTBXES
		oDados["items"][nPos]['quantitySubstitution' ] := (cAliasQry)->HWC_QTSUBS
		oDados["items"][nPos]['alocationQuantity'    ] := (cAliasQry)->HWC_QTEMPE
		oDados["items"][nPos]['quantityNecessity'    ] := (cAliasQry)->HWC_QTNECE
		oDados["items"][nPos]['structureReview'      ] := (cAliasQry)->HWC_REV
		oDados["items"][nPos]['routing'              ] := (cAliasQry)->HWC_ROTEIR
		oDados["items"][nPos]['operation'            ] := (cAliasQry)->HWC_OPERAC
		oDados["items"][nPos]['routingChildDocument' ] := (cAliasQry)->HWC_ROTFIL
		oDados["items"][nPos]['recordKey'            ] := (cAliasQry)->HWC_CHAVE
		oDados["items"][nPos]['substitutionKey'      ] := (cAliasQry)->HWC_CHVSUB
		oDados["items"][nPos]['breakupSequence'      ] := (cAliasQry)->HWC_SEQUEN
		oDados["items"][nPos]['startDate'            ] := getDate((cAliasQry)->HWB_DTINIC )
		oDados["items"][nPos]['level'                ] := (cAliasQry)->NIVEL
		oDados["items"][nPos]['consumptionLocation'  ] := (cAliasQry)->HWC_LOCAL
		oDados["items"][nPos]['purchaseContract'     ] := (cAliasQry)->HWA_CONTRA
		oDados["items"][nPos]['recordNumber'         ] := (cAliasQry)->RECHWC

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	aResult[2] := Iif(lRetJSON, oDados, oDados:toJson())

	If nPos > 0
		aResult[1] := .T.
		aResult[3] := 200
	Else
		aResult[1] := .F.
		aResult[3] := 400
	EndIf

	If !lRetJSON
		aSize(oDados["items"],0)
		FreeObj(oDados)
	EndIf

	If lUsaME
		FreeObj(oLogs)
		oDominio:oDados:destruir()
		FreeObj(oDominio)
		FreeObj(oParametro)
	EndIf

Return aResult

/*/{Protheus.doc} GET TRANSFER api/pcp/v1/mrpresults/transferences/{ticket}
Busca os registros de transfer�ncias que devem ser processados

@type  WSMETHOD
@author lucas.franca
@since 20/11/2020
@version P12
@param ticket        , Character, Codigo �nico do processo para fazer a pesquisa.
@param transferStatus, Character, Status para filtrar a consulta. Se vazio, n�o ser� realizado filtro.
@param produto       , Character, C�digo do produto para filtrar a consulta. Se vazio, n�o ser� realizado filtro.
@param dataTransf    , Date     , Data da transfer�ncia para filtrar a consulta. Se vazio, n�o ser� realizado filtro.
/*/
WSMETHOD GET TRANSFER PATHPARAM ticket QUERYPARAM Fields,Order,Page,PageSize,transferStatus, product, dataTransf WSSERVICE mrpresults
    Local aReturn   := {}
    Local lRet      := .T.

    Self:SetContentType("application/json")

    //Chama a funcao para retornar os dados.
    aReturn := MrpGetSMA(Self:ticket, Self:transferStatus, .F., Self:product, Self:dataTransf )
    MRPApi():restReturn(Self, aReturn, "GET", @lRet)
    aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetSMA
Busca os registros da tabela SMA (transfer�ncias) que devem ser processados

@type  Function
@author lucas.franca
@since 18/11/2020
@version P12
@param 01 cTicket , Character, Codigo �nico do processo para fazer a pesquisa.
@param 02 cStatus , Character, Status para filtrar a consulta. Se vazio, n�o ser� realizado filtro.
@param 03 lRetJSON, Logical  , Identifica se o retorno deve ser em JSON ou em STRING
@param 04 cProduto, Character, C�digo do produto para filtrar a consulta. Se vazio, n�o ser� realizado filtro.
@param 05 dData   , Date     , Data da transfer�ncia para filtrar a consulta. Se vazio, n�o ser� realizado filtro.
@return   aResult , Arrau    , Resultado da consulta.
                               [1] - L�gico. Indica se encontrou ou n�o registros
                               [2] - Dados retornados. Se lRetJSON = .T., os dados ser�o JsonObject.
                                                       Se lRetJson = .F., os dados ser�o uma string JSON.
                               [3] - Numeric. C�digo HTTP de resposta.
/*/
Function MrpGetSMA(cTicket, cStatus, lRetJSON, cProduto, dData)
	Local aResult 	:= {.T.,"",200}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local oDados    := JsonObject():New()

	If FWAliasInDic("SMA", .F.)
		cQuery := " SELECT SMA.MA_FILIAL, "
		cQuery +=        " SMA.MA_FILORIG, "
		cQuery +=        " SMA.MA_FILDEST, "
		cQuery +=        " SMA.MA_PROD, "
		cQuery +=        " SMA.MA_TICKET, "
		cQuery +=        " SMA.MA_DTTRANS, "
		cQuery +=        " SMA.MA_DTRECEB, "
		cQuery +=        " SMA.MA_QTDTRAN, "
		cQuery +=        " SMA.MA_ARMORIG, "
		cQuery +=        " SMA.MA_ARMDEST, "
		cQuery +=        " SMA.MA_DOCUM, "
		cQuery +=        " SMA.MA_STATUS, "
		cQuery +=        " SMA.MA_MSG, "
		cQuery +=        " SMA.R_E_C_N_O_, "
		cQuery +=        " HWB.HWB_NIVEL "
		cQuery +=   " FROM " + RetSqlName("SMA") + " SMA "

		cQuery +=   " JOIN " + RetSqlName("HWB") + " HWB ON "
		cQuery +=    " HWB.HWB_FILIAL     = SMA.MA_FILDEST "
		cQuery +=    " AND HWB.HWB_TICKET = SMA.MA_TICKET "
		cQuery +=    " AND HWB.HWB_DATA   = SMA.MA_DTRECEB "
		cQuery +=    " AND HWB.HWB_PRODUT = SMA.MA_PROD "

		cQuery +=  " WHERE SMA.MA_TICKET  = '" + cTicket + "' "
		cQuery +=    " AND SMA.MA_FILIAL  = '" + xFilial("SMA") + "' "
		cQuery +=    " AND SMA.D_E_L_E_T_ = ' ' "

		If !Empty(cStatus)
			cQuery += " AND SMA.MA_STATUS  = '" + cStatus + "' "
		EndIf
		If !Empty(cProduto)
			cQuery += " AND SMA.MA_PROD = '" + cProduto + "' "
		EndIf
		If !Empty(dData)
			cQuery += " AND (SMA.MA_DTTRANS = '" + DToS(dData) + "' "
			cQuery +=   " OR SMA.MA_DTRECEB = '" + DToS(dData) + "' )"
		EndIf

		cQuery +=  " ORDER BY SMA.MA_FILORIG, SMA.MA_DTTRANS, SMA.MA_PROD"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

		//Ajusta o tipo dos campos na query.
		TcSetField(cAliasQry, 'MA_QTDTRAN', 'N', GetSx3Cache("MA_QTDTRAN", "X3_TAMANHO"), GetSx3Cache("MA_QTDTRAN", "X3_DECIMAL"))
		TcSetField(cAliasQry, 'MA_DTTRANS', 'D', GetSx3Cache("MA_DTTRANS", "X3_TAMANHO"), 0)
		TcSetField(cAliasQry, 'MA_DTRECEB', 'D', GetSx3Cache("MA_DTTRANS", "X3_TAMANHO"), 0)

		oDados["items"] := {}

		nPos := 0
		While (cAliasQry)->(!Eof())

			aAdd(oDados["items"], JsonObject():New())
			nPos++

			oDados["items"][nPos]['branchId'            ] := (cAliasQry)->MA_FILIAL
			oDados["items"][nPos]['originBranchId'      ] := (cAliasQry)->MA_FILORIG
			oDados["items"][nPos]['destinyBranchId'     ] := (cAliasQry)->MA_FILDEST
			oDados["items"][nPos]['product'             ] := (cAliasQry)->MA_PROD
			oDados["items"][nPos]['transferenceDate'    ] := (cAliasQry)->MA_DTTRANS
			oDados["items"][nPos]['receiptDate'         ] := (cAliasQry)->MA_DTRECEB
			oDados["items"][nPos]['transferenceQuantity'] := (cAliasQry)->MA_QTDTRAN
			oDados["items"][nPos]['originWarehouse'     ] := (cAliasQry)->MA_ARMORIG
			oDados["items"][nPos]['destinyWarehouse'    ] := (cAliasQry)->MA_ARMDEST
			oDados["items"][nPos]['document'            ] := (cAliasQry)->MA_DOCUM
			oDados["items"][nPos]['status'              ] := (cAliasQry)->MA_STATUS
			oDados["items"][nPos]['message'             ] := (cAliasQry)->MA_MSG
			oDados["items"][nPos]['ticket'              ] := (cAliasQry)->MA_TICKET
			oDados["items"][nPos]['recordNumber'        ] := (cAliasQry)->R_E_C_N_O_
			oDados["items"][nPos]['level'               ] := (cAliasQry)->HWB_NIVEL

			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())

		aResult[2] := Iif(lRetJSON, oDados, oDados:toJson())

		If nPos > 0
			aResult[1] := .T.
			aResult[3] := 200
		Else
			aResult[1] := .F.
			aResult[3] := 400
		EndIf

		If !lRetJSON
			aSize(oDados["items"],0)
		EndIf
	Else
		aResult[1] := .F.
		aResult[3] := 400
	EndIf

	If !lRetJSON
		FreeObj(oDados)
	EndIf

Return aResult

/*/{Protheus.doc} POST RASTREIO api/pcp/v1/mrpresults/tracking/{recordNumber}/{recStatus}/{erpDoc}/{erpDocType}

@param recordNumber, Numeric  , RECNO do registro para atualiza��o
@param recStatus   , Character, Status do registro
@param erpDoc      , Character, Documento gerado pelo ERP
@param erpDocType  , Character, Tipo de Documento gerado pelo ERP

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.
@author	Douglas.heydt
@since 17/12/2019
@version 12.1.28
/*/
WSMETHOD POST RASTREIO PATHPARAM recordNumber, recStatus, erpDoc, erpDocType WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpPostRas(Self:recordNumber, Self:recStatus, Self:erpDoc, Self:erpDocType)
	MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} POST MrpPostRas
Atualiza status de registro na HWC, com o documento gerado no ERP.

@param nRecno     , Numeric  , RECNO do registro para atualiza��o
@param cStatus    , Character, Status do registro
@param cDocERP    , Character, Documento gerado pelo ERP
@param cDocType   , Character, Tipo de Documento gerado pelo ERP
@return aResult	, Array, resultados obtidos pela query
@author	Douglas.heydt
@since 17/12/2019
@version 12.1.28
/*/
Function MrpPostRas(nRecno, cStatus, cDocERP, cDocType)
	Local aResult := {}
	Local nResult := 200
	Local cMsg    := "Ok"

	If Empty(_nTamTipo)
		_nTamTipo := TamSX3("HWC_TDCERP")[1]
	EndIf

	If Empty(_nTamDoc)
		_nTamDoc  := TamSX3("HWC_DOCERP")[1]
	EndIf

	If nRecno <> 0
		cDocERP  := Padr(cDocERP , _nTamDoc)
		cDocType := Padr(cDocType, _nTamTipo)

		HWC->(dbGoTo(nRecno))
		//Verifica se posicionou (recno v�lido)
		If HWC->(Recno()) == nRecno
			RecLock("HWC", .F.)
				HWC->HWC_STATUS := cStatus
				HWC->HWC_DOCERP := cDocERP
				HWC->HWC_TDCERP := cDocType
			HWC->(MsUnLock())
		Else
			nResult := 400
			cMsg    := STR0028 //"N�mero de registro inv�lido."
		EndIf
	Else
		nResult := 400
		cMsg    := STR0028 //"N�mero de registro inv�lido."
	EndIf

	aAdd(aResult, nResult)
	aAdd(aResult, cMsg)

Return aResult

/*/{Protheus.doc} POST TRANSFER api/pcp/v1/mrpresults/transfer/{recordNumber}/{transferStatus}/{message}

@param recordNumber  , Numeric  , N�mero do registro
@param transferStatus, Character, Status que ser� salvo
@param message       , Character, Mensagem que ser� salva

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.
@author	lucas.franca
@since 20/11/2020
@version P12
/*/
WSMETHOD POST TRANSFER PATHPARAM recordNumber, transferStatus, message WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpUpStSMA(Self:recordNumber, Self:transferStatus, Self:message)
	MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpUpStSMA
Atualiza o status de processamento da tabela SMA

@type  Function
@author lucas.franca
@since 19/11/2020
@version P12
@param nRecno , Numeric  , Recno do registro que deve ser atualizado.
@param cStatus, Character, C�digo do status que ser� gravado (MA_STATUS).
@param cMsg   , Character, Mensagem que ser� gravada (MA_MSG).
@return Nil
/*/
Function MrpUpStSMA(nRecno, cStatus, cMsg)
	//Posiciona no registro
	SMA->(dbGoTo(nRecno))

	//Verifica se posicionou no registro correto.
	If SMA->(Recno()) == nRecno
		RecLock("SMA", .F.)
			SMA->MA_STATUS := cStatus
			SMA->MA_MSG    := cMsg
		SMA->(MsUnLock())
	EndIf
Return Nil

/*/{Protheus.doc} GET AGLUTINADO api/pcp/v1/mrpresults/aglutinado/{ticket}/{docMrp}/{product}
Consulta um documento do MRP na tabela de documentos aglutinados.
@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param	docMrp  , Character, Documento gerado pelo ERP
@param  product , Character, C�digo do componente
/*/
WSMETHOD GET AGLUTINADO PATHPARAM ticket, docMrp, product  WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetHWG( Self:ticket, Self:docMrp, Self:product )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetHWG
Consulta um documento do MRP na tabela de documentos aglutinados.
@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	cTicket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param	cDocMRP  , Character, Documento gerado pelo ERP
@param  cProduto , Character, C�digo do componente
/*/
Function MrpGetHWG(cTicket, cDocMRP, cProduto)

	Local aResult 	:= {}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nPos      := 0
	Local oJson     := JsonObject():New()

	If _lTrtHwg == Nil
		dbSelectArea("HWG")
		_lTrtHwg := FieldPos("HWG_TRT") > 0
	EndIf

	cQuery := "SELECT HWC.HWC_DOCFIL, "
	cQuery +=       " HWG.HWG_QTEMPE "

	If _lTrtHwg
		cQuery += " ,HWG.HWG_TRT "
	EndIf

	cQuery +=  " FROM "+RetSqlName("HWG")+" HWG, "+RetSqlName("HWC")+" HWC "
	cQuery += " WHERE HWG.HWG_FILIAL = '" + xFilial("HWG") + "'"
	cQuery +=   " AND HWG.HWG_TICKET = '" + cTicket + "'"
	cQuery +=   " AND HWG.HWG_DOCAGL = '" + cDocMRP + "'"
	cQuery +=   " AND HWG.HWG_PROD   = '" + cProduto + "'"
	cQuery +=   " AND HWG.D_E_L_E_T_ = ' '"
	cQuery +=   " AND HWC.HWC_FILIAL = '" + xFilial("HWC") + "'"
	cQuery +=   " AND HWC.HWC_TICKET = HWG.HWG_TICKET"
	cQuery +=   " AND HWC.HWC_DOCPAI = HWG.HWG_DOCORI"
	cQuery +=   " AND HWC.HWC_DOCFIL <> ' '"
	cQuery +=   " AND HWC.HWC_SEQUEN = HWG.HWG_SEQORI"
	cQuery +=   " AND HWC.HWC_PRODUT = HWG.HWG_PRODOR"
	cQuery +=   " AND HWC.D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'HWG_QTEMPE', 'N', _aTamQtd[1], _aTamQtd[2])

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():new())
        nPos := Len(oJson["items"])
       	oJson["items"][nPos]['allocation'   ] := (cAliasQry)->HWG_QTEMPE
		oJson["items"][nPos]['childDocument'] := (cAliasQry)->HWC_DOCFIL
		oJson["items"][nPos]['trt'          ] := Iif(_lTrtHwg, (cAliasQry)->HWG_TRT, Nil)
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET ORDSUBS api/pcp/v1/mrpresults/ordsubs/{ticket}/{recordKey}/{parentDocument}
Busca documentos na tabela de substitui��o
@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	cTicket , Character, Codigo �nico do processo para fazer a pesquisa.
@param	cChave  , Character, Chave Registro
@param  cDocPai , Character, Documento pai
/*/
WSMETHOD GET ORDSUBS PATHPARAM  ticket, recordKey, parentDoc WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.
	Local lUsaME    := .F.

	Self:SetContentType("application/json")

	lUsaME := ticketME(Self:ticket, .F.)

	//Chama a funcao para retornar os dados.
	aReturn := MrpOrdSubs(Self:ticket, Self:recordKey, Self:parentDoc, lUsaME)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpOrdSubs
Busca documentos na tabela de substitui��o
@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	cTicket , Character, Codigo �nico do processo para fazer a pesquisa.
@param	cChave  , Character, Chave Registro
@param  cDocPai , Character, Documento pai
@param  lUsaME  , Logic    , Identifica se o processo utiliza multi-empresas
/*/
Function MrpOrdSubs(cTicket, cChave, cDocPai, lUsaME)

	Local aResult   := {}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nPos      := 0
	Local nSizeFil  := 0
	Local oJson     := JsonObject():New()

	If lUsaME
		//Se utiliza multi-empresa, remove do valor da chave o c�digo da filial.
		nSizeFil := FWSizeFilial()
		cChave   := SubStr(cChave, nSizeFil+1)
	EndIf

	//Busca os dados do componente original que foi trocado
	cQuery := "SELECT HWC.HWC_DOCFIL,"
	cQuery +=       " HWC.HWC_PRODUT,"
	cQuery +=       " HWC.HWC_IDOPC,"
	cQuery +=       " CASE WHEN HWC.HWC_LOCAL = ' ' THEN"
	cQuery +=          " HWA.HWA_LOCPAD"
	cQuery +=       " ELSE"
	cQuery +=           " HWC.HWC_LOCAL"
	cQuery +=       " END AS HWC_LOCAL,"
	cQuery +=       " HWC.HWC_TRT,"
	cQuery +=       " HWC.HWC_QTEMPE"
	cQuery +=  " FROM " + RetSqlName("HWC") + " HWC, "
	cQuery +=             RetSqlName("HWA") + " HWA"
	cQuery += "	WHERE HWC.HWC_FILIAL = '" + xFilial("HWC") + "'"
	cQuery +=   " AND HWC.HWC_TICKET = '" + cTicket + "'"
	cQuery +=   " AND HWC.HWC_CHAVE  = '" + cChave  + "'"
	cQuery +=   " AND HWC.HWC_DOCPAI = '" + cDocPai + "'"
	cQuery +=   " AND HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"
	cQuery +=   " AND HWA.HWA_PROD   = HWC.HWC_PRODUT"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'HWC_QTEMPE', 'N', _aTamQtd[1], _aTamQtd[2])

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():new())
        nPos := Len(oJson["items"])
       	oJson["items"][nPos]['childDocument'] 		:= (cAliasQry)->HWC_DOCFIL
		oJson["items"][nPos]['componentCode'] 		:= (cAliasQry)->HWC_PRODUT
		oJson["items"][nPos]['optionalId'] 		    := (cAliasQry)->HWC_IDOPC
		oJson["items"][nPos]['consumptionLocation'] := (cAliasQry)->HWC_LOCAL
		oJson["items"][nPos]['sequenceInStructure'] := (cAliasQry)->HWC_TRT
		oJson["items"][nPos]['alocationQuantity'] 	:= (cAliasQry)->HWC_QTEMPE
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET PRODORIG api/pcp/v1/mrpresults/prodorig/{ticket}/{recordKey}/{parentDocument}
Busca documentos na tabela de substitui��o
@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	cTicket , Character, Codigo �nico do processo para fazer a pesquisa.
@param	cChave  , Character, Chave Registro
@param  cDocPai , Character, Documento pai
/*/
WSMETHOD GET PRODORIG PATHPARAM  ticket, recordKey, parentDoc WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpPrdOrig(Self:ticket, Self:recordKey, Self:parentDoc  )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} POST CLEAR /api/pcp/v1/mrpresults/clear
Efetua limpeza da base de processamento do MRP

@type  WSMETHOD
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST CLEAR WSSERVICE mrpresults
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpRClear(oBody)
		HTTPSetStatus(aReturn[1])
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"Nao foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody   := Nil
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpRClear
Dispara limpeza da base de processamento do MRP

@type  Function
@author brunno.costa
@since 18/03/2020
@version P12.1.30
@param 01 oBody , JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpRClear(oBody)

	Local aTickets := {}
	Local aTabelas := {{"HWB", "HWB_TICKET", "HWB_FILIAL"}, ;
	                   {"HWC", "HWC_TICKET", "HWC_FILIAL"}, ;
	                   {"HWD", "HWD_TICKET", "HWD_FILIAL"}, ;
	                   {"HWG", "HWG_TICKET", "HWG_FILIAL"}, ;
	                   {"HW1", "HW1_TICKET", "HW1_FILIAL"}, ;
	                   {"HW3", "HW3_TICKET", "HW3_FILIAL"}}
	Local aReturn  := {200, ""}
	Local cDataIni := ""
	Local cDataFim := ""
	Local cSQL     := ""
	Local cTickets := oBody["cTickets"]
	Local cNotIN   := UltProcPen()
	Local nInd     := 0
	Local nIndReg  := 0
	Local nTotal   := Len(aTabelas)
	Local nTotReg  := 0
	Local lResult  := .T.
	Local oJsonAux := JsonObject():New()

	If AliasInDic("HWM")
		aAdd(aTabelas, {"HWM", "HWM_TICKET", "HWM_FILIAL"})
		nTotal++
	EndIf

	If AliasInDic("SME")
		aAdd(aTabelas, {"SME", "ME_TICKET", "ME_FILIAL"})
		nTotal++
	EndIf

	If AliasInDic("SMM")
		aAdd(aTabelas, {"SMM", "MM_TICKET", "MM_FILIAL"})
		nTotal++
	EndIf

	If AliasInDic("SMV")
		aAdd(aTabelas, {"SMV", "MV_TICKET", "MV_FILIAL"})
		nTotal++
	EndIf

	If AliasInDic("SMA")
		aAdd(aTabelas, {"SMA", "MA_TICKET", "MA_FILIAL"})
		nTotal++
	EndIf

	If Empty(cTickets)
		cDataIni := DtoS(PCPConvDat(oBody["dataInicial"], 1))
		cDataFim := DtoS(PCPConvDat(oBody["dataFinal"  ], 1))
	EndIf

	aTickets := StrTokArr( cTickets, "," )
	nTotReg  := Len(aTickets)

	oJsonAux["items"  ] := {}
	oJsonAux["lResult"] := .T.

	For nInd := 1 to nTotal

		If AllTrim(cTickets) == "*"
			If aTabelas[nInd][1] == "HW3"
				cSQL := " UPDATE " + RetSQLName(aTabelas[nInd][1]) +;
							" SET HW3_STATUS = '8' "               +;
						" WHERE HW3_STATUS <> '8' "                +;
							" AND HW3_FILIAL = '" + xFilial("HW3") + "' "

				If !Empty(cNotIn)
					cSql += " AND HW3_TICKET NOT IN (" + cNotIn + ") "
				EndIf
			Else
				cSQL := " DELETE FROM " + RetSQLName(aTabelas[nInd][1])
				cSQL +=  " WHERE " + aTabelas[nInd][2] + " IN ("
				cSQL +=       " SELECT HW3_TICKET "
				cSQL +=         " FROM " + RetSQLName("HW3")
				cSQL +=        " WHERE HW3_FILIAL = '" + xFilial("HW3") + "' "
				If !Empty(cNotIN)
					cSQL +=      " AND HW3_TICKET NOT IN (" + cNotIn + ") "
				EndIf
				cSQL += ") "
			EndIf
			lResult := PCPSqlExec(cSQL, @oJsonAux, aTabelas[nInd][1])
		ElseIf Empty(aTickets)

			If aTabelas[nInd][1] == "HW3"
				cSQL :=  " UPDATE " + RetSQLName("HW3")
				cSQL +=     " SET HW3_STATUS = '8' "
				cSQL +=   " WHERE HW3_STATUS <> '8' "
				cSQL +=     " AND HW3_FILIAL = '" + xFilial("HW3") + "' "
				cSQL +=     " AND HW3_DTINIC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
				If !Empty(cNotIn)
					cSQL += " AND HW3_TICKET NOT IN (" + cNotIn + ") "
				EndIf
			Else
				cSQL := " DELETE FROM " + RetSqlName(aTabelas[nInd][1])
				cSQL +=  " WHERE " + aTabelas[nInd][2] + " IN ("
				cSQL +=       " SELECT HW3_TICKET "
				cSQL +=         " FROM " + RetSqlName("HW3")
				cSQL +=        " WHERE HW3_FILIAL = '" + xFilial("HW3") + "' "
				cSQL +=          " AND HW3_DTINIC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
				If !Empty(cNotIN)
					cSQL +=      " AND HW3_TICKET NOT IN (" + cNotIn + ") "
				EndIf
				cSQL += ") "
			EndIf

			lResult := PCPSqlExec(cSQL, @oJsonAux, aTabelas[nInd][1])
		Else
			cTickets := ""
			For nIndReg := 1 to nTotReg
				If Empty(cTickets)
					cTickets := aTickets[nIndReg]
				Else
					cTickets += "," + aTickets[nIndReg]
				EndIf
				If Mod(nIndReg, 500) == 0 .Or. nIndReg == nTotReg
					If aTabelas[nInd][1] == "HW3"
						cSQL := " UPDATE " + RetSQLName(aTabelas[nInd][1])                +;
									" SET HW3_STATUS = '8' "                              +;
								" WHERE HW3_TICKET IN (" + cTickets + ") " +;
									" AND HW3_STATUS <> '8' "

						If !Empty(cNotIN)
							cSQL += " AND HW3_TICKET NOT IN (" + cNotIN + ") "
						EndIf
					Else
						cSQL := "DELETE FROM " + RetSQLName(aTabelas[nInd][1]) + " WHERE " + aTabelas[nInd][2] + " IN (" + cTickets + ") "

						If !Empty(cNotIN)
							cSQL += " AND " + aTabelas[nInd][2] + " NOT IN (" + cNotIN + ")
						EndIf
					EndIf

					lResult  := PCPSqlExec(cSQL, @oJsonAux, aTabelas[nInd][1])
					If !lResult
						oJsonAux["lResult"] := lResult
					EndIf
					cTickets := ""
				EndIf
			Next
		EndIf

		If !lResult
			oJsonAux["lResult"] := lResult
		EndIf
		aSize(aTabelas[nInd], 0)
	Next

	//Recupera o status do processamento
	If oJsonAux["lResult"]
		aReturn[1] := 200 //Ok
	Else
		aReturn[1] := 400 //Falha
	EndIf

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oJsonAux:toJson()

	//Limpeza de mem�ria
	FwFreeObj(oJsonAux)
	oJsonAux := Nil
	aSize(aTabelas, 0)

Return aReturn

/*/{Protheus.doc} UltProcPen
Retorna o ID do �timo processamento, caso esteja ainda em execu��o
@type  WSMETHOD
@author brunno.costa
@since 22/07/2020
@version P12.1.27
@return cNotIN, caracter, ultimo ticket em execucao, caso esteja ainda em processamento
/*/
Static Function UltProcPen()

	Local aUltProc := MrpGStatus()
	Local cNotIN := ""
	Local oJsonAux

	If !Empty(aUltProc)
		oJsonAux := JsonObject():New()
		oJsonAux:fromJson(aUltProc[2])
		If oJsonAux["status"] != Nil .AND. oJsonAux["status"] $ "1,2" //Reservado, Iniciado
			cNotIN := "'" + oJsonAux["ticket"] + "'"
		EndIf
		FreeObj(oJsonAux)
		oJsonAux := Nil
		aSize(aUltProc, 0)
	EndIf

Return cNotIN

/*/{Protheus.doc} PCPSqlExec
Executa TcSQLExe
@author brunno.costa
@since 23/03/2020
@version P12.1.30
@param	cSQL    , caracter , script SQL
@param	oJsonAux, objeto   , Ojeto de controle de erros Json
@param	cTabela , caracter , nome da tabela relacionada
@return lResult, l�gico, indica sucesso na execu��o
/*/

Static Function PCPSqlExec(cSQL, oJsonAux, cTabela)
	Local cErro    := ""
	Local lResult  := .T.
	Local oJsError := Nil

	If TcSqlExec(cSQL) < 0
		cErro   := AllTrim(TcSqlError())
		LogMsg('PCPA144', 0, 0, 1, '', '', "PCPA144 - " + STR0014 + " '" + cTabela + "': " + cErro) //Erro na limpeza da tabela

		oJsError := JsonObject():New()
		oJsError["tabela"] := cTabela
		oJsError["erro"  ] := cErro


		aAdd(oJsonAux["items"], oJsError)
		lResult := .F.
	EndIf

Return lResult

/*/{Protheus.doc} MrpPrdOrig
Busca documentos na tabela de substitui��o
@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	cTicket , Character, Codigo �nico do processo para fazer a pesquisa.
@param	cChave  , Character, Chave Registro
@param  cDocPai , Character, Documento pai
/*/
Function MrpPrdOrig(cTicket, cChave, cDocPai)
	Local aResult 	:= {}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nPos      := 0
	Local oJson     := JsonObject():New()

	cQuery := "SELECT HWC.HWC_PRODUT"
	cQuery +=  " FROM " + RetSqlName("HWC") + " HWC"
	cQuery += " WHERE HWC.HWC_FILIAL = '" + xFilial("HWC") + "'"
	cQuery +=   " AND HWC.HWC_TICKET = '" + cTicket        + "'"
	cQuery +=   " AND HWC.HWC_CHAVE  = '" + cChave         + "'"
	cQuery +=   " AND HWC.HWC_DOCPAI = '" + cDocPai        + "'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		Aadd(oJson["items"],JsonObject():new())
        nPos := Len(oJson["items"])
       	oJson["items"][nPos]['componentCode'] := (cAliasQry)->HWC_PRODUT
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} getDate
Formata uma string de data no formato AAAAMMDD para o formato AAAA-MM-DD

@type  Static Function
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param cData, Character, Data no formato AAAAMMDD
@return cData, Character, Data no formato AAAA-MM-DD
/*/
Static Function getDate(dData)
	Local cData := ""
	cData := Left(dData, 4) + "-" + SubStr(dData, 5, 2) + "-" + Right(dData, 2)
Return cData

/*/{Protheus.doc} MrpGetProd
Consulta os produtos conforme a tabela HWB.
@type  Function
@author renan.roeder
@since 24/03/2020
@version P12.1.30
@param	cTicket  , Character, Codigo �nico do processo para fazer a pesquisa.
/*/
Function MrpGetProd(cTicket)
	Local aFiliais   := {}
	Local aResult 	 := {}
	Local cAliasQry  := GetNextAlias()
	Local cFiliaisIN := ""
	Local cQuery     := ""
	Local nIndex     := 0
	Local nPos       := 0
	Local nTotal     := 0
	Local oJson      := JsonObject():New()

	ticketME(cTicket, .F., , , , aFiliais)
	nTotal := Len(aFiliais)
	If nTotal == 0
		cFiliaisIN := "'" + xFilial("HWB") + "'"
	Else
		For nIndex := 1 To nTotal
			If nIndex > 1
				cFiliaisIN += ","
			EndIf
			cFiliaisIN += "'" + aFiliais[nIndex][1] + "'"
		Next nIndex
	EndIf

	cQuery := "SELECT H.HWB_PRODUT,"
	cQuery +=       " H.HWB_IDOPC,"
	cQuery +=       " SUM(H.HWB_QTNECE) HWB_QTNECE"
	cQuery +=  " FROM " + RetSqlName("HWB") + " H"
	cQuery += " WHERE H.HWB_FILIAL IN (" + cFiliaisIN + ")"
	cQuery +=   " AND H.HWB_TICKET = '" + cTicket + "'"
	cQuery +=   " AND H.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY H.HWB_PRODUT, H.HWB_IDOPC"
	cQuery += " ORDER BY H.HWB_PRODUT, H.HWB_IDOPC"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'HWB_QTNECE', 'N', _aTamQtd[1], _aTamQtd[2])

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():new())
        nPos := Len(oJson["items"])
       	oJson["items"][nPos]['product']           := (cAliasQry)->HWB_PRODUT
		oJson["items"][nPos]['optionalId']        := (cAliasQry)->HWB_IDOPC
		oJson["items"][nPos]['necessityQuantity'] := (cAliasQry)->HWB_QTNECE
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"],0)
	FreeObj(oJson)
	aSize(aFiliais, 0)

Return aResult

/*/{Protheus.doc} GET EVENTS api/pcp/v1/mrpresults/ticket/{ticket}
Consulta um documento do MRP na tabela de documentos aglutinados.
@type  WSMETHOD
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param	ticket      , Character, Codigo �nico do processo para fazer a pesquisa.
@param	filterEvent , Character, filtro aplicado a todas as colunas da busca
@param	concatDoc   , NUmeral  ,  1/0 Indica se concatena os campos doc e item no resultado ( usado na tela em PO UI)
/*/
WSMETHOD GET EVENTS WSRECEIVE filterEvent, concatDoc PATHPARAM ticket WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetLog( Self:ticket, Self:filterEvent, Self:concatDoc )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetLog

@type  WSMETHOD
@author douglas.heydt
@since
@version P12.1.27
@param	cTicket    , Character, Codigo �nico do processo para fazer a pesquisa.
@param	cFilter    , Character, filtro aplicado a todas as colunas da busca
@param	nConcatDoc , Numeral  , 1/0 Indica se concatena os campos doc e item no resultado ( usado na tela em PO UI)
/*/
Function MrpGetLog(cTicket, cFilter, nConcatDoc)

	Local aResult 	:= {.T., "", 204}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nPos      := 0
	Local oJson     := JsonObject():New()

	Default cFilter := ""
	Default cConcatDoc := 0

	cQuery := "SELECT HWM_FILIAL, HWM_TICKET,HWM_PRODUT, HWM_EVENTO, HWM_LOGMRP, HWM_DOC, HWM_ITEM, HWM_ALIAS, HWM_PRDORI"
	cQuery += " FROM " + RetSqlName("HWM") + " WHERE "

	If !ticketME(cTicket, .F.)
		cQuery += " HWM_FILIAL = '" + xFilial("HWM") + "' AND"
	EndIf

	cQuery +=   " HWM_TICKET = '" + cTicket + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	If !Empty(cFilter)
		cQuery += "AND (
		cQuery += "	HWM_FILIAL like '%"+cFilter+"%' OR
		cQuery += "	HWM_PRODUT like '%"+cFilter+"%' OR
		cQuery += "	HWM_EVENTO like '%"+cFilter+"%' OR
		cQuery += "	HWM_LOGMRP like '%"+cFilter+"%' OR
		cQuery += "	HWM_DOC    like '%"+cFilter+"%' OR
		cQuery += "	HWM_ITEM   like '%"+cFilter+"%' OR
		cQuery += "	HWM_ALIAS  like '%"+cFilter+"%' OR
		cQuery += "	HWM_PRDORI like '%"+cFilter+"%' )
	EndIf
	cQuery += " ORDER BY HWM_PRODUT, HWM_EVENTO"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():new())
        nPos := Len(oJson["items"])
       	oJson["items"][nPos]['branchId'  ] := (cAliasQry)->HWM_FILIAL
		oJson["items"][nPos]['ticket'    ] := (cAliasQry)->HWM_TICKET
		oJson["items"][nPos]['product'   ] := (cAliasQry)->HWM_PRODUT
		oJson["items"][nPos]['event'     ] := (cAliasQry)->HWM_EVENTO
		oJson["items"][nPos]['logMrp'    ] := (cAliasQry)->HWM_LOGMRP
		IF nConcatDoc == 1
			oJson["items"][nPos]['doc'   ] := (cAliasQry)->HWM_DOC +(cAliasQry)->HWM_ITEM
		Else
			oJson["items"][nPos]['doc'    ] := (cAliasQry)->HWM_DOC
			oJson["items"][nPos]['logItem'] := (cAliasQry)->HWM_ITEM
		EndIf
		oJson["items"][nPos]['logAlias'  ] := cAliasDesc((cAliasQry)->HWM_EVENTO, (cAliasQry)->HWM_ALIAS)
		oJson["items"][nPos]['productOri'] := (cAliasQry)->HWM_PRDORI
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJSON())
		aResult[3] := 200
	EndIf

	aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} POST MAT_ALTERA api/pcp/v1/mrpresults/updMat
Altera um registro da matriz de resultados do MRP
@type WSMETHOD
@author marcelo.neumann
@since 23/10/2020
@version P12
@return lRet, Logical, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST MAT_ALTERA WSSERVICE mrpresults
	Local aReturn := {}
	Local cBody   := ""
	Local cError  := ""
	Local lRet    := .T.
	Local oBody   := JsonObject():New()

	Self:SetContentType("application/json")

	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)
	If Empty(cError)
		aReturn := MrpPostHWB(oBody)
	Else
		aAdd(aReturn, 400)
		aAdd(aReturn, cError)
	EndIf

	MRPApi():restReturn(Self, aReturn, "POST", @lRet)

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} POST MrpPostHWB
Altera um registro da matriz de resultados do MRP
@author marcelo.neumann
@since 23/10/2020
@version P12
@param  oBody  , Object, Objeto JSON com o registro alterado
@return aReturn, Array , Retorno da execu��o do m�todo
/*/
Function MrpPostHWB(oBody)

	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
	oMRPApi:setBody(oBody)

	//Executa o processamento do POST
	oMRPApi:processar(LISTA_ALTERACAO_MATRIZ)

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil

Return aReturn

/*/{Protheus.doc} POST RAS_ALTERA api/pcp/v1/mrpresults/updRas
Altera um documento do MRP
@type WSMETHOD
@author marcelo.neumann
@since 23/10/2020
@version P12
@return lRet, Logical, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST RAS_ALTERA WSSERVICE mrpresults
	Local aReturn := {}
	Local cBody   := ""
	Local cError  := ""
	Local lRet    := .T.
	Local oBody   := JsonObject():New()

	Self:SetContentType("application/json")

	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)
	If Empty(cError)
		aReturn := MrpPostHWC(oBody)
	Else
		aAdd(aReturn, 400)
		aAdd(aReturn, cError)
	EndIf

	MRPApi():restReturn(Self, aReturn, "POST", @lRet)

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} POST MrpPostHWC
Altera um documento do MRP
@author marcelo.neumann
@since 23/10/2020
@version P12
@param  oBody  , Object, Objeto JSON com o registro alterado
@return aReturn, Array , Retorno da execu��o do m�todo
/*/
Function MrpPostHWC(oBody)

	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
	oMRPApi:setBody(oBody)

	//Executa o processamento do POST
	oMRPApi:processar(LISTA_ALTERACAO_RASTREIO)

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil

Return aReturn

/*/{Protheus.doc} POST LOG_ALTERA api/pcp/v1/mrpresults/logAlt
Registra o log de altera��o de um documento do MRP
@type WSMETHOD
@author parffit.silva
@since 20/11/2020
@version P12
@return lRet, Logical, Informa se o processo foi executado com sucesso
/*/
WSMETHOD POST LOG_ALTERA WSSERVICE mrpresults
	Local aReturn := {}
	Local cBody   := ""
	Local cError  := ""
	Local lRet    := .T.
	Local oBody   := JsonObject():New()

	Self:SetContentType("application/json")

	cBody  := Self:GetContent()
	cError := oBody:FromJson(cBody)
	If Empty(cError)
		aReturn := MrpPostSMG(oBody)
	Else
		aAdd(aReturn, 400)
		aAdd(aReturn, cError)
	EndIf

	MRPApi():restReturn(Self, aReturn, "POST", @lRet)

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} POST MrpPostSMG
Registra o log de altera��o de um documento do MRP
@author parffit.silva
@since 20/11/2020
@version P12
@param  oBody  , Object, Objeto JSON com o registro alterado
@return aReturn, Array , Retorno da execu��o do m�todo
/*/
Function MrpPostSMG(oBody)

	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
	oMRPApi:setBody(oBody)

	//Executa o processamento do POST
	oMRPApi:processar(LISTA_LOG_ALTERACAO)

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil

Return aReturn

/*/{Protheus.doc} GET DOC_ORIG api/pcp/v1/mrpresults/docorig/{ticket}/{docMrp}
Consulta um documento do MRP na tabela de documentos aglutinados.
@type  WSMETHOD
@author douglas.heydt
@since 28/10/2020
@version P12.1.30
@param Ticket, Character, Codigo �nico do processo para fazer a pesquisa.
@param DocMRP, Character, Documento gerado pelo ERP
/*/
WSMETHOD GET DOC_ORIG PATHPARAM ticket, docMrp WSSERVICE mrpresults
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGDocOri(Self:ticket, Self:docMrp)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGDocOri
Consulta o documento origem do MRP na tabela de documentos aglutinados. (usado na gera��o de documentos)
@type  Function
@author douglas.heydt
@since 28/10/2020
@version P12.1.30
@param cTicket, Character, Codigo �nico do processo para fazer a pesquisa.
@param cDocMRP, Character, Documento gerado pelo ERP
/*/
Function MrpGDocOri(cTicket, cDocMRP)

	Local aResult 	:= {}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nPos      := 0
	Local oJson     := JsonObject():New()

	cQuery := "SELECT HWG.HWG_DOCORI"
	cQuery +=  " FROM " + RetSqlName("HWG") + " HWG"
	cQuery += " WHERE HWG.HWG_FILIAL = '" + xFilial("HWG") + "'"
	cQuery +=   " AND HWG.HWG_TICKET = '" + cTicket + "'"
	cQuery +=   " AND HWG.HWG_DOCAGL = '" + cDocMRP + "'"
	cQuery +=   " AND HWG.D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():new())
        nPos := Len(oJson["items"])
		oJson["items"][nPos]['originDocument'] := (cAliasQry)->HWG_DOCORI

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET RAS_DEM api/pcp/v1/mrpresults/rasDem/{ticket}
Consulta o rastreio das demandas processadas no ticket
@type  WSMETHOD
@author marcelo.neumann
@since 02/12/2020
@version P12.1.31
@param Ticket, Character, Codigo �nico do processo para fazer a pesquisa
@return lRet , Logic    , Indica se a connslta foi realizada com sucesso
/*/
WSMETHOD GET RAS_DEM PATHPARAM ticket WSSERVICE mrpresults
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetRasD(Self:ticket)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetRasD
Retorna o rastreio das demandas
@type  Function
@author marcelo.neumann
@since 02/12/2020
@version P12.1.31
@param cTicket , Character, Codigo �nico do processo para fazer a pesquisa.
@param cDocMRP , Character, Documento gerado pelo ERP
@return aResult, Array    , Resultado da consulta
/*/
Function MrpGetRasD(cTicket)

	Local aResult 	:= {}
	Local cAliasQry := GetNextAlias()
	Local cBanco    := TCGetDB()
	Local cTpSaida  := ""
	Local cTxtES    := MrpDGetSTR("ES")
	Local cTxtPPed  := MrpDGetSTR("PP")
	Local cQuery    := ""
	Local lLoteSME  := !Empty(GetSX3Cache("ME_LOTE", "X3_TAMANHO")) .And. !Empty(GetSX3Cache("ME_SLOTE", "X3_TAMANHO"))
	Local nPos      := 0
	Local nTamOp    := GetSX3Cache("T4Q_OP", "X3_TAMANHO")
	Local oJson     := JsonObject():New()

	cTpSaida := "'1','2','3','4','5','9','" + cTxtES + "','"+cTxtPPed+"','ESTNEG'"

	cQuery := "WITH RastroRecursivo(ME_FILIAL, DEMANDA, ME_TIPO, ME_TPDCENT, ME_NMDCENT, ME_PRODUTO, ME_TRT,"
	cQuery +=                     " ME_DATA, ME_QUANT, ME_TPDCSAI, ME_NMDCSAI, PROD_SAIDA, TRT_SAIDA, ME_IDREG,"
	cQuery +=                     " QTD_DOC, QTD_PAI, LOTE, SUBLOTE)"
	cQuery +=  " AS (SELECT SME_Base.ME_FILIAL,"
	cQuery +=             " SME_Base.ME_NMDCSAI DEMANDA,"
	cQuery +=             " SME_Base.ME_TIPO,"
	cQuery +=             " SME_Base.ME_TPDCENT,"
	cQuery +=             " SME_Base.ME_NMDCENT,"
	cQuery +=             " SME_Base.ME_PRODUTO,"
	cQuery +=             " SME_Base.ME_TRT,"
	cQuery +=             " SME_Base.ME_DATA,"
	cQuery +=             " SME_Base.ME_QUANT,"
	cQuery +=             " SME_Base.ME_TPDCSAI,"
	cQuery +=             " SME_Base.ME_NMDCSAI,"
	cQuery +=             " SME_Base.ME_PRODUTO PROD_SAIDA,"
	cQuery +=             " SME_Base.ME_TRT TRT_SAIDA,"
	cQuery +=             " SME_Base.ME_IDREG,"
	cQuery +=             " SME_Base.ME_QUANT QTD_DOC,"
	cQuery +=             " SME_Base.ME_QUANT QTD_PAI,"

	If lLoteSME
		cQuery += " SME_Base.ME_LOTE  LOTE,"
		cQuery += " SME_Base.ME_SLOTE SUBLOTE"
	Else
		cQuery += " '' LOTE,"
		cQuery += " '' SUBLOTE"
	EndIf

	cQuery +=        " FROM " + RetSqlName("SME") + " SME_Base"
	cQuery +=       " WHERE SME_Base.ME_FILIAL  = '" + xFilial("SME") + "'"
	cQuery +=         " AND SME_Base.D_E_L_E_T_ = ' '"
	cQuery +=         " AND SME_Base.ME_TICKET  = '" + cTicket + "'"
	cQuery +=         " AND SME_Base.ME_TIPO    IN ('2','3')"
	cQuery +=         " AND (SME_Base.ME_TPDCSAI IN ("+cTpSaida+")"
	cQuery +=           " OR (SME_Base.ME_TPDCSAI = 'Pr�-OP' "
	cQuery +=           " AND SubString(SME_Base.ME_NMDCENT, 1, 4) <> 'Pre_'"
	cQuery +=           " AND SME_Base.ME_NMDCENT <> 'SaldoInicial'))"

	cQuery +=       " UNION ALL"

	cQuery +=      " SELECT SME_Rec.ME_FILIAL,"
	cQuery +=             " Qry_Recurs.DEMANDA DEMANDA,"
	cQuery +=             " SME_Rec.ME_TIPO,"
	cQuery +=             " SME_Rec.ME_TPDCENT,"
	cQuery +=             " SME_Rec.ME_NMDCENT,"
	cQuery +=             " SME_Rec.ME_PRODUTO,"
	cQuery +=             " SME_Rec.ME_TRT,"
	cQuery +=             " SME_Rec.ME_DATA,"
	cQuery +=             " SME_Rec.ME_QUANT,"
	cQuery +=             " SME_Rec.ME_TPDCSAI,"
	cQuery +=             " SME_Rec.ME_NMDCSAI,"
	cQuery +=             " Qry_Recurs.ME_PRODUTO PROD_SAIDA,"
	cQuery +=             " Qry_Recurs.ME_TRT TRT_SAIDA,"
	cQuery +=             " SME_Rec.ME_IDREG,"
	cQuery +=             " CASE WHEN "
	If cBanco == "ORACLE"
		cQuery +=              " SubStr(SME_Rec.ME_NMDCENT, 1, 4) = 'Pre_' THEN"
	Else
		cQuery +=              " LEFT(SME_Rec.ME_NMDCENT, 4) = 'Pre_' THEN"
	EndIf
	cQuery +=                " (SELECT SME.ME_QUANT "
	cQuery +=                   " FROM " + RetSqlName("SME") + " SME "
	cQuery +=                  " WHERE SME.ME_FILIAL = '" + xFilial("SME") + "'"
	cQuery +=                    " AND SME.ME_TICKET = '" + cTicket + "'"
	cQuery +=                    " AND SME.ME_TIPO   = '1'"
	cQuery +=                    " AND SME.ME_NMDCENT = SME_Rec.ME_NMDCENT"
	cQuery +=                    " AND SME.ME_TPDCENT = SME_Rec.ME_TPDCENT"
	cQuery +=                    " AND SME.D_E_L_E_T_ = ' ' ) "
	cQuery +=             " ELSE "
	cQuery +=                 " SME_Rec.ME_QUANT "
	cQuery +=             " END QTD_DOC, "
	cQuery +=             " CASE WHEN "
	If cBanco == "ORACLE"
		cQuery +=              " SubStr(SME_Rec.ME_NMDCSAI, 1, 4) = 'Pre_' THEN"
	Else
		cQuery +=              " LEFT(SME_Rec.ME_NMDCSAI, 4) = 'Pre_' THEN"
	EndIf
	cQuery +=                " COALESCE((SELECT T4Q.T4Q_QUANT
	cQuery +=                   " FROM " + RetSqlName("T4Q") + " T4Q
	cQuery +=                  " WHERE T4Q.T4Q_FILIAL = '" + xFilial("T4Q") + "' "
	cQuery +=                    " AND T4Q.D_E_L_E_T_ = ' '
	cQuery +=                    " AND T4Q.T4Q_OP     = SubString(SME_Rec.ME_NMDCSAI, 5, " + cValToChar(nTamOp) + ")) , "
	cQuery +=                " (SELECT SME.ME_QUANT "
	cQuery +=                   " FROM " + RetSqlName("SME") + " SME "
	cQuery +=                  " WHERE SME.ME_FILIAL = '" + xFilial("SME") + "'"
	cQuery +=                    " AND SME.ME_TICKET = '" + cTicket + "'"
	cQuery +=                    " AND SME.ME_TIPO   = '1'"
	cQuery +=                    " AND SME.ME_NMDCENT = SME_Rec.ME_NMDCSAI"
	cQuery +=                    " AND SME.D_E_L_E_T_ = ' ' ) ) "
	cQuery +=             " ELSE "
	cQuery +=                 " SME_Rec.ME_QUANT "
	cQuery +=             " END QTD_PAI, "

	If lLoteSME
		cQuery += " SME_Rec.ME_LOTE  LOTE, "
		cQuery += " SME_Rec.ME_SLOTE SUBLOTE "
	Else
		cQuery += " '' LOTE, "
		cQuery += " '' SUBLOTE "
	EndIf

	cQuery +=        " FROM " + RetSqlName("SME") + " SME_Rec"
	cQuery +=       " INNER JOIN RastroRecursivo Qry_Recurs"
	cQuery +=          " ON Qry_Recurs.ME_NMDCENT = SME_Rec.ME_NMDCSAI"
	cQuery +=         " AND (  (SME_Rec.ME_IDPAI = ' ') "
	cQuery +=                " OR (SME_Rec.ME_IDPAI = Qry_Recurs.ME_IDREG) "
	cQuery +=                " OR (RTRIM(Qry_Recurs.ME_IDREG) LIKE '%|' || RTRIM(SME_Rec.ME_IDPAI) || '|') "
	cQuery +=              ") "
	cQuery +=       " WHERE SME_Rec.ME_FILIAL  = '" + xFilial("SME") + "'"
	cQuery +=         " AND Qry_Recurs.ME_NMDCSAI <> SME_Rec.ME_NMDCENT "
	cQuery +=         " AND SME_Rec.D_E_L_E_T_ = ' '"
	cQuery +=         " AND SME_Rec.ME_TICKET  = '" + cTicket + "'"
	cQuery +=         " AND SME_Rec.ME_TIPO    IN ('2','3')"
	cQuery +=         " AND SME_Rec.ME_TPDCSAI NOT IN ("+cTpSaida+"))"

	cQuery += " SELECT DISTINCT Resultado.ME_FILIAL   FILIAL,"
	cQuery +=                 " Resultado.DEMANDA     DEMANDA,"
	cQuery +=                 " Resultado.ME_TIPO     TIPO,"
	cQuery +=                 " Resultado.ME_TPDCENT  TPDCENT,"
	cQuery +=                 " Resultado.ME_NMDCENT  NMDCENT,"
	cQuery +=                 " Resultado.ME_PRODUTO  PRODUTO,"
	cQuery +=                 " Resultado.ME_TRT      TRT,"
	cQuery +=                 " Resultado.ME_DATA     DATADOC,"
	cQuery +=                 " Resultado.ME_QUANT    QUANT,"
	cQuery +=                 " Resultado.ME_TPDCSAI  TIP_DOCSAIDA,"
	cQuery +=                 " Resultado.ME_NMDCSAI  DOCSAIDA,"
	cQuery +=                 " Resultado.PROD_SAIDA  PRODSAIDA,"
	cQuery +=                 " Resultado.TRT_SAIDA   TRTSAIDA,"
	cQuery +=                 " Resultado.ME_IDREG    IDREG,"
	cQuery +=                 " (SELECT Min(HWB_NIVEL) "
	cQuery +=                    " FROM " + RetSqlName("HWB")
	cQuery +=                   " WHERE HWB_FILIAL = '" + xFilial("HWB") + "'"
	cQuery +=                     " AND HWB_TICKET = '" + cTicket + "' "
	cQuery +=                     " AND HWB_PRODUT = Resultado.ME_PRODUTO "
	cQuery +=                     " AND HWB_DATA = Resultado.ME_DATA) NIVEL, "
	cQuery +=                 " Resultado.QTD_DOC,"
	cQuery +=                 " Resultado.QTD_PAI,"
	cQuery +=                 " Resultado.LOTE,"
	cQuery +=                 " Resultado.SUBLOTE"
	cQuery +=   " FROM RastroRecursivo Resultado "
	cQuery += 	" ORDER BY 15"

	//Realiza ajustes da Query para cada banco
	If cBanco == "POSTGRES"
		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Corrige Falhas internas de Bin�rio - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	ElseIf cBanco == "ORACLE"
		cQuery := StrTran(cQuery, 'SubString(', 'SubStr(')

	ElseIf "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, '||', '+')

	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T.)

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())

		aAdd(oJson["items"], JsonObject():new())

		nPos++
		oJson["items"][nPos]["branchId"              ] := (cAliasQry)->FILIAL
		oJson["items"][nPos]["demandId"              ] := (cAliasQry)->DEMANDA
		oJson["items"][nPos]["type"                  ] := (cAliasQry)->TIPO
		oJson["items"][nPos]["documentType"          ] := (cAliasQry)->TPDCENT
		oJson["items"][nPos]["document"              ] := (cAliasQry)->NMDCENT
		oJson["items"][nPos]["product"               ] := (cAliasQry)->PRODUTO
		oJson["items"][nPos]["productLevel"          ] := (cAliasQry)->NIVEL
		oJson["items"][nPos]["sequenceInStructure"   ] := (cAliasQry)->TRT
		oJson["items"][nPos]["date"                  ] := (cAliasQry)->DATADOC
		oJson["items"][nPos]["quantity"              ] := (cAliasQry)->QUANT
		oJson["items"][nPos]["id"                    ] := (cAliasQry)->IDREG
		oJson["items"][nPos]["parentDocumentType"    ] := (cAliasQry)->TIP_DOCSAIDA
		oJson["items"][nPos]["parentDocument"        ] := (cAliasQry)->DOCSAIDA
		oJson["items"][nPos]["quantityDocumentIn"    ] := (cAliasQry)->QTD_DOC
		oJson["items"][nPos]["quantityDocumentFather"] := (cAliasQry)->QTD_PAI

		If (cAliasQry)->PRODUTO == (cAliasQry)->PRODSAIDA
			oJson["items"][nPos]["parentProduct"  ] := ""
			oJson["items"][nPos]["parentSequence" ] := ""
		Else
			oJson["items"][nPos]["parentProduct"  ] := (cAliasQry)->PRODSAIDA
			oJson["items"][nPos]["parentSequence" ] := (cAliasQry)->TRTSAIDA
		EndIf

		oJson["items"][nPos]["lote"   ] := (cAliasQry)->LOTE
		oJson["items"][nPos]["subLote"] := (cAliasQry)->SUBLOTE

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} ticketME
Verifica se determinado ticket foi processado considerando multi-empresas.

@type  Static Function
@author lucas.franca
@since 18/11/2020
@version P12
@param cTicket   , Character, Numera��o do ticket do MRP
@param lRetObj   , Logic    , Indica se deve retornar os objetos por refer�ncia.
@param oParametro, Object   , Refer�ncia do objeto de par�metros. Retornado por refer�ncia se lRetObj = .T.
@param oDominio  , Object   , Refer�ncia do objeto da camada de dominio. Retornado por refer�ncia se lRetObj = .T.
@param oLogs     , Object   , Refer�ncia do objeto da camada de logs. Retornado por refer�ncia se lRetObj = .T.
@param aFiliais  , Array    , Filial centralizadora e filiais centralizadas do processamento
@return lUsaME, Logic, Indica se o ticket foi processado com multi-empresas
/*/
Static Function ticketME(cTicket, lRetObj, oParametro, oDominio, oLogs, aFiliais)
	Local cFilPrinci := ""
	Local cFilFilhas := ""
	Local lUsaME     := .F.
	Local nSizePar   := GetSx3Cache("HW1_PARAM", "X3_TAMANHO")

	If HW1->(dbSeek(xFilial("HW1") + cTicket + PadR("branchCentralizing", nSizePar)))
		cFilPrinci := HW1->HW1_VAL

		If HW1->(dbSeek(xFilial("HW1") + cTicket + PadR("centralizedBranches", nSizePar)))
			cFilFilhas := HW1->HW1_LISTA
		EndIf
	EndIf

	If !Empty(cFilPrinci) .And. !Empty(cFilFilhas)
		oParametro := JsonObject():New()
		oParametro["ticket"             ] := cTicket
		oParametro["cChaveExec"         ] := cTicket + "GET_HWC"
		oParametro["branchCentralizing" ] := cFilPrinci
		oParametro["centralizedBranches"] := cFilFilhas

		MrpAplicacao():parametrosDefault(@oParametro)

		oLogs    := MrpDados_Logs():New(oParametro)
		oDominio := MrpDominio():New(oParametro, oLogs, .T.)

		lUsaME   := oDominio:oMultiEmp:utilizaMultiEmpresa()
		aFiliais := oDominio:oMultiEmp:retornaFiliais()

		If !lRetObj .Or. !lUsaME
			FreeObj(oLogs)
			oDominio:oDados:destruir()
			FreeObj(oDominio)
			FreeObj(oParametro)
		EndIf
	EndIf

Return lUsaME

/*/{Protheus.doc} GET CHKME api/pcp/v1/mrpresults/checkmultibranch/{ticket}
Verifica se um ticket do MRP foi processado com multi-empresas

@type  WSMETHOD
@author lucas.franca
@since 08/12/2020
@version P12
@param	ticket, Character, Codigo �nico do processo para fazer a pesquisa.
/*/
WSMETHOD GET CHKME PATHPARAM ticket WSSERVICE mrpresults
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpTiktME( Self:ticket, .F. )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpTiktME
Verifica se um ticket do MRP foi processado com multi-empresas

@type  Function
@author lucas.franca
@since 08/12/2020
@version P12
@param	ticket  , Character, Codigo �nico do processo para fazer a pesquisa.
@param lRetJSON , Logical  , Identifica se o retorno deve ser em JSON ou em STRING
/*/
Function MrpTiktME(cTicket, lRetJSON)

	Local aResult 	 := {.T.,"",200}
	Local lUsaME     := .F.
	Local oDados     := JsonObject():New()

	lUsaME := ticketME(cTicket, .F.)

	oDados["useMultiBranches"] := lUsaME

	aResult[2] := Iif(lRetJSON, oDados, oDados:toJson())

	aResult[1] := .T.
	aResult[3] := 200

	If !lRetJSON
		FreeObj(oDados)
	EndIf

Return aResult

/*/{Protheus.doc} GET PROD_PAI api/pcp/v1/mrpresults/prodPai/{branchId}/{ticket}/{cDocPai}
Fun��o para retornar o produto pai de um documento gerado pelo MRP

@type  WSMETHOD
@author marcelo.neumann
@since 05/01/2021
@version P12
@param 01 branchId  , Caracter, Codigo da filial para fazer a pesquisa
@param 02 ticket    , Caracter, Codigo �nico do processo para fazer a pesquisa.
@param 03 docPai    , Caracter, Documento pai do registro
@return   lRet      , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PROD_PAI PATHPARAM branchId, ticket, docPai QUERYPARAM Fields,Order,Page,PageSize WSSERVICE mrpresults
	Local aReturn  := {}
	Local lRet     := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetPrdP(Self:branchId, Self:ticket, Self:docPai)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetPrdP
Fun��o para retornar o produto pai de um documento gerado pelo MRP

@type  Function
@author marcelo.neumann
@since 05/01/2021
@version P12
@param 01 cBranch, Caracter, Codigo da filial
@param 02 cTicket, Caracter, Codigo �nico do processo
@param 03 cDocPai, Caracter, Documento pai do registro
@return   aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - L�gico   - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Caracter - JSON com o produto pai oJson["00000101001"]
						aReturn[3] - Num�rico - Codigo de erro
/*/
Function MrpGetPrdP(cBranch, cTicket, cDocPai)
	Local aFiliais   := {}
	Local aReturn    := {}
	Local cAliasQry  := GetNextAlias()
	Local cFiliaisIN := xFilial("HWC", cBranch)
	Local cQuery     := ""
	Local nIndex     := 0
	Local nTotal     := 0
	Local oJson      := JsonObject():New()

	//Se est� preenchido, n�o � compartilhada, verifica demais filiais
	If !Empty(cFiliaisIN)
		ticketME(cTicket, .F., , , , aFiliais)

		nTotal := Len(aFiliais)
		If nTotal > 0
			cFiliaisIN := ""
			For nIndex := 1 To nTotal
				If nIndex > 1
					cFiliaisIN += "','"
				EndIf
				cFiliaisIN += aFiliais[nIndex][1]
			Next nIndex
		EndIf
	EndIf

	cQuery := "SELECT HWC_PRODUT"                           + ;
               " FROM " + RetSqlName("HWC")                 + ;
		 	  " WHERE HWC_FILIAL IN ('" + cFiliaisIN + "')" + ;
				" AND HWC_TICKET = '" + cTicket + "'"       + ;
				" AND HWC_DOCFIL = '" + cDocPai + "'"       + ;
				" AND D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof())
		oJson[cDocPai] := (cAliasQry)->HWC_PRODUT

		aAdd(aReturn, .T.)
		aAdd(aReturn, oJson:toJSON())
		aAdd(aReturn, 200)
	Else
		oJson[cDocPai] := ""

		aAdd(aReturn, .F.)
		aAdd(aReturn, oJson:toJSON())
		aAdd(aReturn, 400)
	End
	(cAliasQry)->(dbCloseArea())

	aSize(aFiliais, 0)
	FreeObj(oJson)

Return aReturn

/*/{Protheus.doc} cAliasDesc
Retorna a descri��o do Alias na tabela SX2 ou espec�ficos definidos

@type  Function
@author douglas.Heydt
@since 03/08/2021
@version P12.1.30
@param cEvento , Caracter, C�digo do evento do log MRP
@param cAlias  , Caracter, Alias da tabela que gerou o evento
@return cDesc  , Caracter, Descri��o do alias no dicion�rio
/*/
Function cAliasDesc(cEvento, cAlias)
	Local cDesc := ""

	Do Case
		Case cEvento == "001" .And. Empty(cAlias)
			cDesc := STR0029 //"Saldo"
		Case cEvento == "004"
			IF Empty(cAlias)
				cDesc := STR0030 //"Sa�da de estrutura"
			ELSE
				cDesc := STR0031 //"Demanda"
			ENDIF
		Case cEvento == "009"
			cDesc := STR0032 //produto
		OTHERWISE
			If cAlias == "T4T"
				cDesc := STR0033 //"Solicita��o de compra"
			ElseIf cAlias == "T4U"
				cDesc := STR0034 //"Pedido de compra"
			ElseIf cAlias == "T4Q"
				cDesc := STR0035 //"Ordem de produ��o"
			ElseIf cAlias == "T4J"
				cDesc := STR0036 //"Demanda"
			ElseIf cAlias == "T4S"
				cDesc := STR0037 //"Empenho"
			EndIf
	EndCase

	If Empty(cDesc)
		cDesc := Alltrim(FWX2Nome(cAlias))
	EndIf

Return cDesc

/*/{Protheus.doc} formatPar
Formata os par�metros para exibi��o em tela.

@type  Static Function
@author lucas.franca
@since 07/02/2022
@version P12
@param aReturn, Array, Array com o retorno padr�o da API de consulta de par�metros
@return aReturn, Array, Array com o conte�do formatado para exibi��o em tela
/*/
Static Function formatPar(aReturn)
	Local aParAux  := {}
	Local aParTela := {}
	Local cError   := ""
	Local nIndex   := 0
	Local nTotal   := 0
	Local oDados   := JsonObject():New()

	If aReturn[1]
		cError := oDados:FromJson(aReturn[2])
		If Empty(cError)
			nTotal := Len(oDados["items"])
			For nIndex := 1 To nTotal
				If oDados["items"][nIndex]["parameter"] == "cAutomacao" .Or. ;
				   oDados["items"][nIndex]["parameter"] == "setupCode"  .Or. ;
				   oDados["items"][nIndex]["parameter"] == "ticket"     .Or. ;
				   oDados["items"][nIndex]["parameter"] == "structurePrecision"
					Loop
				EndIf

				If oDados["items"][nIndex]["parameter"] $ PARAMETRO_TELA
					aAdd(aParTela, getParam(oDados["items"][nIndex]["parameter"],;
				                            oDados["items"][nIndex]["value"    ],;
				                            oDados["items"][nIndex]["list"     ]))
				Else
					aAdd(aParAux, getParam(oDados["items"][nIndex]["parameter"],;
				                           oDados["items"][nIndex]["value"    ],;
				                           oDados["items"][nIndex]["list"     ]))
				EndIf
			Next nIndex

			aSort(aParAux,,, {|x,y| x["parameter"] < y["parameter"]})
			aSort(aParTela,,, {|x,y| x["position"] < y["position"]})
			aEval(aParAux, {|x| aAdd(aParTela, x)})
			aSize(oDados["items"], 0)

			oDados["items"] := aParTela
			aReturn[2] := FwHTTPEncode(oDados:ToJson())

			FreeObj(oDados)
			aSize(aParAux, 0)
			aSize(aParTela, 0)
		EndIf
	EndIf

	FreeObj(oDados)
Return aReturn

/*/{Protheus.doc} getParam
Faz a tratativa para cada par�metro

@type  Static Function
@author lucas.franca
@since 07/02/2022
@version P12
@param 01 cParam, Character, C�digo do par�metro
@param 02 cValue, Character, Valor do par�metro
@param 03 cList , Character, Valor (LISTA) do par�metro
@return oParam, Object  , JSONObject com os dados formatados
/*/
Static Function getParam(cParam, cValue, cList)
	Local oParam := JsonObject():New()

	oParam["code"     ] := cParam
	oParam["parameter"] := cParam
	oParam["value"    ] := Iif(Empty(cValue), cList, cValue)
	oParam["position" ] := 99

	Do Case
		Case cParam == "user"
			oParam["parameter"       ] := STR0038 //"Usu�rio"
			oParam["valueDescription"] := UsrFullName(cValue)

		Case cParam == "numberOfPeriods"
			oParam["parameter"] := STR0039 //"N�mero de Per�odos"
			oParam["position" ] := 8

		Case cParam == "demandStartDate"
			oParam["parameter"       ] := STR0040 //"Data In�cio Demandas"
			oParam["valueDescription"] := DtoC(StoD(StrTran(cValue,"-","")))
			oParam["position"        ] := 2

		Case cParam == "demandEndDate"
			oParam["parameter"       ] := STR0041 //"Data Fim Demandas"
			oParam["valueDescription"] := DtoC(StoD(StrTran(cValue,"-","")))
			oParam["position"        ] := 3

		Case cParam == "mrpStartDate"
			oParam["parameter"       ] := STR0042 //"Data In�cio MRP"
			oParam["valueDescription"] := DtoC(StoD(StrTran(cValue,"-","")))

		Case cParam == "orderPoint"
			oParam["parameter"       ] := STR0043 //"Ponto de Pedido"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o
			oParam["position"        ] := 16

		Case cParam == "firmHorizon"
			oParam["parameter"       ] := STR0044 //"Horizonte Firme"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o
			oParam["position"        ] := 10

		Case cParam == "leadTime"
			oParam["parameter"       ] := STR0045 //"Lead Time"
			oParam["valueDescription"] := Iif(cValue=="1", STR0082, Iif(cValue=="2", STR0083, STR0084) )  // 1-Sem Calend�rio/2-Dias Corridos/3-Dias �teis
			oParam["position"        ] := 9

		Case cParam == "demandType"
			oParam["parameter"       ] := STR0046 //"Tipo Demanda"
			oParam["valueDescription"] := GetDemanda(cValue)  // 1-Pedido Venda/2-Previs�o Vendas/3-Plano Mestre/4-Empenhos Projeto/5-Manual
			oParam["position"        ] := 23

		Case cParam == "documentType"
			oParam["parameter"       ] := STR0047 //"Tipo Documento"
			oParam["valueDescription"] := GetDocumen(cValue)  // 1-Previstas/2-Suspensas/3-Sacramentadas
			oParam["position"        ] := 24

		Case cParam == "safetyStock"
			oParam["parameter"       ] := STR0048 //"Estoque Seguran�a"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o
			oParam["position"        ] := 15

		Case cParam == "rejectedQuality"
			oParam["parameter"       ] := STR0049 //"Estoque Rejeitado CQ"
			oParam["valueDescription"] := Iif(cValue=="1", STR0085, STR0086)  // 1-Subtrai/2-Mant�m
			oParam["position"        ] := 13

		Case cParam == "maxStock"
			oParam["parameter"       ] := STR0050 //"Estoque M�ximo"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "consignedIn"
			oParam["parameter"       ] := STR0051 //"Estoque DE Terceiro"
			oParam["valueDescription"] := Iif(cValue=="1", STR0085, STR0086)  // 1-Subtrai/2-Mant�m
			oParam["position"        ] := 12

		Case cParam == "cEmpAnt"
			oParam["parameter"] := STR0052 //"Empresa"

		Case cParam == "cFilAnt"
			oParam["parameter"] := STR0053 //"Filial"

		Case cParam == "periodType"
			oParam["parameter"       ] := STR0054 //"Tipo de Per�odo"
			oParam["valueDescription"] := GetTpPer(cValue) // 1-Di�rio/2-Semanal/3-Quinzenal/4-Mensal
			oParam["position"        ] := 7

		Case cParam == "consignedOut"
			oParam["parameter"       ] := STR0055 //"Estoque EM Terceiro"
			oParam["valueDescription"] := Iif(cValue=="1",STR0087,STR0088) // 1-Soma/2-N�o Soma
			oParam["position"        ] := 11

		Case cParam == "blockedLot"
			oParam["parameter"       ] := STR0056 //"Estoque Bloqueado por Lote"
			oParam["valueDescription"] := Iif(cValue=="1", STR0085, STR0086)  // 1-Subtrai/2-Mant�m
			oParam["position"        ] := 14

		Case cParam == "consolidatePurchaseRequest"
			oParam["parameter"       ] := STR0057 //"Aglutina Solicita��o de Compras"
			oParam["valueDescription"] := GetAglut(cValue)  // 1-Aglutina/2-N�o Aglutina/3-Aglutina Somente Demandas
			oParam["position"        ] := 19

		Case cParam == "consolidateProductionOrder"
			oParam["parameter"       ] := STR0058 //"Aglutina Ordem de Produ��o"
			oParam["valueDescription"] := GetAglut(cValue)  // 1-Aglutina/2-N�o Aglutina/3-Aglutina Somente Demandas
			oParam["position"        ] := 20

		Case cParam == "demandsProcessed"
			oParam["parameter"       ] := STR0059 //"Considera Demandas j� Processadas"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o
			oParam["position"        ] := 4

		Case cParam == "usesProductIndicator"
			oParam["parameter"       ] := STR0060 //"Considera a tabela Indicador de Produto"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "usesInProcessLocation"
			oParam["parameter"       ] := GetDescMV( "MV_GRVLOCP")
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "inProcessLocation"
			oParam["parameter"       ] := GetDescMV( "MV_LOCPROC")
			oParam["valueDescription"] := cValue

		Case cParam == "lGeraDoc"
			oParam["parameter"       ] := STR0061 //"Gerar Documentos ao T�rmino do C�lculo"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o
			oParam["position"        ] := 6

		Case cParam == "expiredLot"
			oParam["parameter"       ] := GetDescMV( "MV_LOTVENC")
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "packingQuantityFirst"
			oParam["parameter"       ] := GetDescMV( "MV_USAQTEM" )
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "productionOrderPerLot"
			oParam["parameter"       ] := GetDescMV( "MV_QUEBROP" )
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "purchaseRequestPerLot"
			oParam["parameter"       ] := GetDescMV( "MV_QUEBRSC" )
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "breakByMinimunLot"
			oParam["parameter"       ] := GetDescMV( "MV_FORCALM" )
			oParam["valueDescription"] := Iif(cValue=="1", STR0089, STR0090) // 1 - verdadeiro/2-falso

		Case cParam == "minimunLotAsEconomicLot"
			oParam["parameter"       ] := GetDescMV( "MV_SUBSLE" )
			oParam["valueDescription"] := Iif(cValue=="1", STR0089, STR0090) // 1 - verdadeiro/2-falso

		Case cParam == "productGroups"
			oParam["parameter"       ] := STR0062 //"Grupo de produtos"
			oParam["valueDescription"] := cList

		Case cParam == "productTypes"
			oParam["parameter"       ] := STR0063 //"Tipo de produtos"
			oParam["valueDescription"] := cList

		Case cParam == "documents"
			oParam["parameter"       ] := STR0064 //"Documentos"
			oParam["valueDescription"] := cList

		Case cParam == "warehouses"
			oParam["parameter"       ] := STR0065 //"Armaz�ns"
			oParam["valueDescription"] := cList

		Case cParam == "demandCodes"
			oParam["parameter"       ] := STR0066 //"Demandas do MRP"
			oParam["valueDescription"] := cList

		Case cParam == "products"
			oParam["parameter"       ] := STR0067 //"Produtos"
			oParam["valueDescription"] := cList

		Case cParam == "eventLog"
			oParam["parameter"       ] := STR0068 //"Gerar Log de Eventos"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o
			oParam["position"        ] := 5

		Case cParam == "productionOrderNumber"
			oParam["parameter"       ] := STR0069 //"Incrementa Ordem de Produ��o"
			oParam["valueDescription"] := Iif(cValue=="1",STR0091, STR0092) // 1-Por Item/2-Por N�mero
			oParam["position"        ] := 18

		Case cParam == "purchaseRequestNumber"
			oParam["parameter"       ] := STR0070 //"Incrementa Solicita��o de Compras"
			oParam["valueDescription"] := Iif(cValue=="1",STR0091, STR0092) // 1-Por Item/2-Por N�mero
			oParam["position"        ] := 17

		Case cParam == "productionOrderType"
			oParam["parameter"       ] := STR0071 //"Gerar Documentos"
			oParam["valueDescription"] := Iif(cValue=="1",STR0093,STR0094) // 1-Previstos/2-Firmes
			oParam["position"        ] := 21

		Case cParam == "qualityWarehouse"
			oParam["parameter"] := STR0072 //"MV_CQ: Armaz�m usado no controle da qualidade."

		Case cParam == "usesLaborProduct"
			oParam["parameter"       ] := GetDescMV( "MV_PRODMOD" ) //Indicado para clientes que n�o utilizam produtos m�o de obra (B1_CCCUSTO) e desejam melhorar a performance das rotinas de fechamento.
			oParam["valueDescription"] := Iif(cValue == "1", STR0095, STR0096) // "1 - Habilita utiliza��o de produto MOD com o preenchimento do campo B1_CCCUSTO." + "2 - Desabilita utiliza��o de produto MOD com o preenchimento do campo B1_CCCUSTO."

		Case cParam == "standardTimeUnit"
			oParam["parameter"       ] := GetDescMV( "MV_TPHR" ) //Unidade de medida da mao de obra na  estrutura  do produto. H = Horas por peca, P = Pecas por hora.
			oParam["valueDescription"] := Iif(cValue == "N", STR0097, Iif(cValue == "C", STR0098, cValue)) //"N = Normal" + "C = Centesimal"

		Case cParam == "unitOfLaborInTheBOM"
			oParam["parameter"       ] := GetDescMV( "MV_UNIDMOD" ) //Define a unidade padrao para tempos utilizados pelo sistema de PCP e ESTOQUE. O tipo de hora pode ser "N" -> Normal ou "C" -> Centesimal.
			oParam["valueDescription"] := Iif(cValue == "H", STR0099, Iif(cValue == "P", STR0100, cValue)) //"H = Horas por pe�a" + "P = Pe�as por hora"

		Case cParam == "allocationSuggestion"
			oParam["parameter"       ] := STR0073 //"Sugere Lote e Endere�o nos Empenhos"
			oParam["valueDescription"] := Iif(AllTrim(cValue)=="1",STR0080, STR0081) // 1-Sim/2-N�o
			oParam["position"        ] := 22

		Case cParam == "lRastreiaEntradas"
			oParam["parameter"       ] := STR0074 //"Gravar Rastreio das Entradas"
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "branchCentralizing"
			oParam["parameter"] := STR0075 //"Filial Centralizadora"

		Case cParam == "centralizedBranches"
			oParam["parameter"       ] := STR0076 //"Filiais Centralizadas"
			oParam["valueDescription"] := cList

		Case cParam == "setupDescription"
			oParam["parameter"] := STR0077 //"Setup"
			oParam["position" ] := 1

		Case cParam == "transportingLanes"
			oParam["parameter"       ] := GetDescMV( "MV_PCPMADI" ) //Indica se utiliza Malha de Distribui��o no MRP.
			oParam["valueDescription"] := Iif(cValue=="1", STR0089, STR0090) // 1 - verdadeiro/2-falso

		Case cParam == "memoryLoadType"
			oParam["parameter"       ] := GetDescMV( "MV_MRPCMEM" ) //Identifica o modo de carga de mem�ria que ser� utilizado pelo MRP Mem�ria (PCPA712).0=Carga total;1=Carga seletiva.
			oParam["valueDescription"] := cValue + " - " + Iif(cValue=="1", STR0101, STR0102) //"Carga seletiva", "Carga total"

		Case cParam == "revisionInProductIndicator"
			oParam["parameter"       ] := GetDescMV( "MV_REVFIL" )
			oParam["valueDescription"] := Iif(cValue=="1",STR0080, STR0081) // 1-Sim/2-N�o

		Case cParam == "scGenerationDate"
			oParam["parameter"       ] := STR0120 //"Per�odos da Gera��o de SCs"
			oParam["valueDescription"] := cList

		Case cParam == "opGenerationDate"
			oParam["parameter"       ] := STR0121 //"Per�odos da Gera��o de OPs"
			oParam["valueDescription"] := cList

		Case cParam == "processLogs"
			oParam["parameter"] := STR0079 //"Logs de processamento"

		Case cParam == "stockPolicyPMP"
			oParam["parameter"       ] := GetDescMV( "MV_POLPMP" )
			oParam["valueDescription"] := Iif(cValue=="S", STR0089, STR0090) // S-verdadeiro / N-falso

		Case cParam == "allocationBenefit"
			oParam["parameter"       ] := GetDescMV( "MV_EMPBN" )
			oParam["valueDescription"] := Iif(cValue=="S", STR0089, STR0090) // S-verdadeiro / N-falso

		Case cParam == "limiteQuebraLE"
			oParam["parameter"       ] := GetDescMV( "MV_QLIMITE" )
			oParam["valueDescription"] := cValue

	EndCase
	If Empty(oParam["valueDescription"])
		oParam["valueDescription"] := oParam["value"]
	EndIf

Return oParam

/*/{Protheus.doc} GetDemanda
Fun��o para trazer a descri��o do parametro informado

@type  Static Function
@author lucas.franca
@since 07/02/2022
@version P12
@param 01 cParam, Character, C�digo do par�metro
@return cParDesc, caracter, descri��o do parametro
/*/
Static Function GetDemanda(cParam)
	Local cParDesc := ""
	Local cPar     := ""
	Local cDes     := ""
	Local nIndex   := 0

	For nIndex := 1 To Len(cParam)
		cDes := ""
		cPar := SubStr(cParam,nIndex,1)
		Do Case
			Case cPar == "1"
				cDes := STR0103 //"Pedido de Venda"
			Case cPar == "2"
				cDes := STR0104 //"Previs�o de Vendas"
			Case cPar == "3"
				cDes := STR0105 //"Plano Mestre"
			Case cPar == "4"
				cDes := STR0106 //"Empenhos Projeto"
			Case cPar == "9"
				cDes := STR0107 //"Manual"
		EndCase
		If Empty(cParDesc)
			cPardesc := cDes
		Else
			If !Empty(cDes)
				cPardesc := cPardesc + ", " + cDes
			EndIf
		EndIf
	Next nIndex
Return cParDesc

/*/{Protheus.doc} GetDocumen
Fun��o para trazer a descri��o do parametro informado

@type  Static Function
@author lucas.franca
@since 07/02/2022
@version P12
@param 01 cParam, Character, C�digo do par�metro
@return cParDesc, caracter, descri��o do parametro
/*/
Static Function GetDocumen(cParam)
	Local cParDesc := ""

	If "|1.1|" $ cParam
		cPardesc := STR0108 //"Previstos -> Exclui"
	EndIf

	If "|1.2|" $ cParam
		cPardesc := STR0109 //"Previstos -> N�o Exclui"
	EndIf

	If "|1.3|" $ cParam
		cPardesc := STR0110 //"Previstos -> Entra no MRP"
	EndIf

	If "|2|" $ cParam
		cPardesc := cPardesc + ", " + STR0111 //"Suspensas"
	EndIf

	If "|3|" $ cParam
		cPardesc := cPardesc + ", " + STR0112 //"Sacramentadas"
	EndIf

Return cParDesc

/*/{Protheus.doc} GetTpPer
Fun��o para trazer a descri��o do parametro informado

@type  Static Function
@author lucas.franca
@since 07/02/2022
@version P12
@param 01 cParam, Character, C�digo do par�metro
@return cParDesc, caracter, descri��o do parametro
/*/
Static Function GetTpPer(cParam)
	Local cParDesc := ""
	Do Case
	Case cParam == "1"
		cParDesc := STR0113 //"Di�rio"
	Case cParam == "2"
		cParDesc := STR0114 //"Semanal"
	Case cParam == "3"
		cParDesc := STR0115 //"Quinzenal"
	Case cParam == "4"
		cParDesc := STR0116 //"Mensal"
	EndCase
Return cParDesc

/*/{Protheus.doc} GetAglut
Fun��o para trazer a descri��o do parametro informado

@type  Static Function
@author lucas.franca
@since 07/02/2022
@version P12
@param 01 cParam, Character, C�digo do par�metro
@return cParDesc, caracter, descri��o do parametro
/*/
Static Function GetAglut(cParam)
	Local cParDesc := ""
	Do Case
	Case cParam == "1"
		cParDesc := STR0117 //"Aglutina"
	Case cParam == "2"
		cParDesc := STR0118 //"N�o Aglutina"
	Case cParam == "3"
		cParDesc := STR0119 //"Aglutina Somente Demandas"
	EndCase
Return cParDesc

/*/{Protheus.doc} GetDescMV
Fun��o para trazer a descri��o do parametro MV

@type  Static Function
@author lucas.franca
@since 07/02/2022
@version P12
@param 01 cParam, Character, C�digo do par�metro
@return cParDesc, caracter, descri��o do parametro
/*/
Static Function GetDescMV( cParam )
	Local cParDesc := ""
	If FWSX6Util():ExistsParam( cParam )
		GetMV(cParam)
		cParDesc := StrTran(x6Descric() + " ", "  ", " ")
		cParDesc += StrTran(x6Desc1() + " " , "  ", " ")
		cParDesc += x6Desc2()
		cParDesc := cParam + ": " + StrTran(AllTrim(cParDesc), "  ", " ")
		If "- " $ cParDesc .And. Substr(cParDesc,  At("- ", cParDesc) - 1, 1) != " "
			cParDesc := StrTran(AllTrim(cParDesc), "- ", "")
		EndIf
	Else
		cParDesc := cParam
	EndIf
Return cParDesc
