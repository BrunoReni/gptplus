#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpwarehouse.ch"

Static _aMapFields := MapFields()

//dummy function
Function mrpWareh()
Return
  
/*/{Protheus.doc} mrpwarehouse
API de integracao de Armaz�ns no MRP

@type  WSCLASS
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
/*/
WSRESTFUL mrpwarehouse DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Armaz�m do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code       AS STRING  OPTIONAL

	WSMETHOD GET ALL;
		DESCRIPTION STR0002; //"Retorna todos os Armaz�ms"
		WSSYNTAX "api/pcp/v1/mrpwarehouse" ;
		PATH "/api/pcp/v1/mrpwarehouse" ;
		TTALK "v1"

	WSMETHOD GET WAREHOUSE;
		DESCRIPTION STR0003; //"Retorna um armaz�m espec�fico"
		WSSYNTAX "api/pcp/v1/mrpwarehouse/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrpwarehouse/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST WAREHOUSE;
		DESCRIPTION STR0004; //"Inclui ou atualiza um ou mais armaz�ns"
		WSSYNTAX "api/pcp/v1/mrpwarehouse" ;
		PATH "/api/pcp/v1/mrpwarehouse" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0005; //"Sincroniza��o de armaz�ns"
		WSSYNTAX "api/pcp/v1/mrpwarehouse/sync" ;
		PATH "/api/pcp/v1/mrpwarehouse/sync" ;
		TTALK "v1"

	WSMETHOD DELETE WAREHOUSE;
		DESCRIPTION STR0006; //"Exclui um ou mais armaz�ns"
		WSSYNTAX "api/pcp/v1/mrpwarehouse" ;
		PATH "/api/pcp/v1/mrpwarehouse" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALL /api/pcp/v1/mrpwarehouse
Retorna todos os armaz�ns do MRP

@type  WSMETHOD
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@param	Order   , caracter, Ordenacao da tabela principal
@param	Page    , numerico, N�mero da pagina inicial da consulta
@param	PageSize, numerico, N�mero de registro por paginas
@param	Fields  , caracter, Campos que ser�o retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALL QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpwarehouse
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpWAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET WAREHOUSE /api/pcp/v1/mrpwarehouse
Retorna um armaz�m espec�fico

@type  WSMETHOD
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@param	branchId, Character, Codigo da filial
@param	code    , Character, Codigo �nico do registro de armaz�m.
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET WAREHOUSE PATHPARAM branchId, code QUERYPARAM Fields WSSERVICE mrpwarehouse
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpWGet(Self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST WAREHOUSE /api/pcp/v1/mrpwarehouse
Inclui ou altera um ou mais armaz�ns

@type  WSMETHOD
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST WAREHOUSE WSSERVICE mrpwarehouse
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpWPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Nao foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/mrpwarehouse/sync
Sincroniza��o dos armaz�ns (Apaga todas os registros existentes na base, e inclui as recebidas na requisi��o)

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		douglas.heydt
@since		06/08/2019
@version	12.1.28
/*/
WSMETHOD POST sync WSSERVICE mrpwarehouse
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpWSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE WAREHOUSE /api/pcp/v1/mrpwarehouse
Deleta um ou mais armaz�ns

@type  WSMETHOD
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE WAREHOUSE WSSERVICE mrpwarehouse
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpWDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Nao foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpWPost
Dispara as acoes da API de armaz�ns no MRP, para o metodo POST (Inclusao/Alteracao).

@type    Function
@author  douglas.heydt
@since   02/08/2020
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpWPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Instancia da classe MRPApi para o metodo POST

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
	oMRPApi:setBody(oBody)

	//Executa o processamento do POST
	oMRPApi:processar("fields")

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpWSync
Fun��o para disparar as a��es da API de armaz�ns no MRP, para o m�todo Sync (Sincroniza��o).

@type    Function
@author  douglas.heydt
@since   06/08/2019
@version P12.1.28
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@param   lBuffer, L�gico, Define a sincroniza��o em processo de buffer.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpWSync(oBody, lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST

	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
	oMRPApi:setBody(oBody)

	//Seta FLAG que indica o processo de sincroniza��o.
	oMRPApi:setSync(.T.)

	//Seta Flag que indica o processo de buffer.
	oMRPApi:setBuffer(lBuffer)

	//Executa o processamento do POST
	oMRPApi:processar("fields")

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()
	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da mem�ria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpWDel
Dispara as acoes da API de Armaz�ns, para o metodo DELETE (Exclusao).

@type  Function
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informacoes recebidas no corpo da requisicao.
@return aReturn, Array, Array contendo o Codigo HTTP que devera ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Codigo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpWDel(oBody)
	Local aReturn  := {201, ""}
	Local oMRPApi  := defMRPApi("DELETE","") //Instancia da classe MRPApi para o metodo DELETE

	//Adiciona os parametros recebidos no corpo da requisicao (BODY)
	oMRPApi:setBody(oBody)

	oMRPApi:setMapDelete("fields")

	//Executa o processamento do POST
	oMRPApi:processar("fields")

	//Recupera o status do processamento
	aReturn[1] := oMRPApi:getStatus()

	//Recupera o JSON com os dados do retorno do processo.
	aReturn[2] := oMRPApi:getRetorno(1)

	//Libera o objeto MRPApi da memoria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} MrpWAll
Dispara as acoes da API de Armaz�ns, para o metodo GET (Consulta) para varios armaz�ns.

@type  Function
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpWAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := WhGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpWGet
Funcao para disparar as acoes da API de Armaz�ns no MRP, para o metodo GET (Consulta)

@type  Function
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@param cBranch , Caracter, Codigo da filial
@param cCode   , Caracter, Codigo �nico da registro de armaz�m
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informacoes da requisicao.
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Function MrpWGet(cBranch, cCode, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"CODE"    , cCode})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a funcao para retornar os dados.
	aReturn := WhGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela HWY

@type  Static Function
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()
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
	aFields := { ;
	            {"branchId"             	, "HWY_FILIAL"  , "C", FWSizeFilial()                        , 0},;
	            {"warehouse"              	, "HWY_COD"     , "C", GetSx3Cache("HWY_COD"   ,"X3_TAMANHO"), 0},;
	            {"type"                     , "HWY_TIPO"    , "C", GetSx3Cache("HWY_TIPO"  ,"X3_TAMANHO"), 0},;
	            {"usemrp"            	    , "HWY_MRP"     , "C", GetSx3Cache("HWY_MRP"   ,"X3_TAMANHO"), 0},;
	            {"code"                 	, "HWY_IDREG"   , "C", GetSx3Cache("HWY_IDREG" ,"X3_TAMANHO"), 0};
	           }

Return aFields

/*/{Protheus.doc} WhGet
Executa o processamento do metodo GET de acordo com os parametros recebidos.

@type  Static Function
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@param lLista   , Logic    , Indica se devera retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordenacao desejada do retorno.
@param nPage    , Numeric  , Pagina dos dados. Se Nao enviado, considera pagina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por pagina. Se Nao enviado, considera 20 registros por pagina.
@param cFields  , Character, Campos que devem ser retornados. Se Nao enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informacoes da requisicao.
                             aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao.
						     aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi.
/*/
Static Function WhGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Instancia da classe MRPApi para o metodo GET

	//Seta os parametros de paginacao, filtros e campos para retorno
	oMRPApi:setFields(cFields)
	oMRPApi:setPage(nPage)
	oMRPApi:setPageSize(nPageSize)
	oMRPApi:setQueryParams(aQuery)
	oMRPApi:setUmRegistro(!lLista)

	//Executa o processamento
	aReturn[1] := oMRPApi:processar("fields")
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

/*/{Protheus.doc} MrpWVLD
Funcao responsavel por validar as informacoes recebidas.

@type  Function
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@param oMRPApi   , Object   , Refer�ncia da classe MRPApi que esta processando os dados.
@param cMapCode  , Character, Codigo do mapeamento que sera validado
@param oItem     , Object   , Refer�ncia do objeto JSON com os dados que devem ser validados.
@return lRet     , Logico   , Identifica se os dados est�o validos.
/*/
Function MrpWVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"

        If lRet .And. Empty(oItem["warehouse"])
			lRet := .F.
			oMRPApi:SetError(400, STR0008 + "product" + STR0009) //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. Empty(oItem["type"])
			lRet := .F.
			oMRPApi:SetError(400, STR0008 + "type" + STR0009) //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. Empty(oItem["usemrp"])
			lRet := .F.
			oMRPApi:SetError(400, STR0008 + "usemrp" + STR0009) //"Atributo 'XXX' Nao foi informado."
		EndIf

		If lRet .And. Empty(oItem["code"])
			lRet := .F.
			oMRPApi:SetError(400, STR0008 + "code" + STR0009) //"Atributo 'XXX' Nao foi informado."
		EndIf

	EndIf
Return lRet

/*/{Protheus.doc} defMRPApi
Faz a instancia da classe MRPAPI e seta as propriedades basicas.

@type  Static Function
@author douglas.heydt
@since 02/08/2020
@version P12.1.27
@param cMethod  , Character, Metodo que sera executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenacao para o GET
@return oMRPApi , Object   , Refer�ncia da classe MRPApi com as definicoes ja executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	Default lKeyProd := .F.

	//Seta o APIMAP do item principal (cabe�alho)
	oMRPApi:setAPIMap("fields", _aMapFields , "HWY", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"HWY_FILIAL","HWY_IDREG"})

	If cMethod == "POST"
		//Seta as fun��es de valida��o de cada mapeamento.
		oMRPApi:setValidData("fields", "MrpWVLD")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpWMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  douglas.heydt
@since   02/08/2020
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpWMap()
Return {_aMapFields}
