#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPPRODVERSION.CH"

Static _aMapField := MapFields()

//dummy function
Function prodversion()
Return

/*/{Protheus.doc} Vers�o da Produ��o MRP
API de integra��o de Vers�o da Produ��o do MRP
@author		Douglas Heydt
@since		10/04/2018
/*/
WSRESTFUL mrpproductionversion DESCRIPTION STR0017 FORMAT APPLICATION_JSON //"Vers�o da Produ��o MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code       AS STRING  OPTIONAL

	WSMETHOD GET prodversion;
		DESCRIPTION STR0001;//"Retorna todos os registros de vers�o da produ��o MRP";
		WSSYNTAX "api/pcp/v1/mrpproductionversion" ;
		PATH "/api/pcp/v1/mrpproductionversion" ;
		TTALK "v1"

	WSMETHOD GET code;
		DESCRIPTION STR0002;//"Retorna um registro espec�fico de vers�o da produ��o MRP";
		WSSYNTAX "api/pcp/v1/mrpproductionversion/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrpproductionversion/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST prodversion;
		DESCRIPTION STR0003; //"Inclui ou atualiza um ou mais registros de vers�o da produ��o MRP";
		WSSYNTAX "api/pcp/v1/mrpproductionversion" ;
		PATH "/api/pcp/v1/mrpproductionversion" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0018; //"Sincroniza��o da vers�o da produ��o no MRP"
		WSSYNTAX "api/pcp/v1/mrpproductionversion/sync" ;
		PATH "/api/pcp/v1/mrpproductionversion/sync" ;
		TTALK "v1"

	WSMETHOD DELETE prodversion;
		DESCRIPTION STR0004; //"Exclui um ou mais registro(s) de vers�ao da produ��o MRP";
		WSSYNTAX "api/pcp/v1/mrpproductionversion" ;
		PATH "/api/pcp/v1/mrpproductionversion" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET /api/pcp/v1/ProdVersion
Retorna todos os registros de Vers�o da Produ��o MRP

@param	Order		, caracter, Ordena��o da tabela principal
@param	Page		, num�rico, N�mero da p�gina inicial da consulta
@param	PageSize	, num�rico, N�mero de registro por p�ginas
@param	Fields		, caracter, Campos que ser�o retornados no GET.

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD GET prodversion WSRECEIVE Order, Page, PageSize, Fields WSSERVICE mrpproductionversion
	Local aReturn := {}
	Local lRet    := .T.

    Self:SetContentType("application/json")

	aReturn := MrpVPGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET /api/pcp/v1/ProdVersion/{code}
Retorna um registro espec�fico de Vers�o da Produ��o MRP

@param	branchId, caracter, C�digo da filial para utilizar na consulta,
@param	code    , caracter, C�digo da vers�o de produ��o para utilizar na consulta.
@param	Fields  , caracter, Campos que ser�o retornados no GET.

@return lRet    , L�gico, Informa se o processo foi executado com sucesso.

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD GET code PATHPARAM branchId, code WSRECEIVE Fields WSSERVICE mrpproductionversion
	Local aReturn := {}
	Local lRet    := .T.

	Default Self:branchId := ""
	Default Self:code     := ""

	Self:SetContentType("application/json")

	aReturn := MrpVPGCod(self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST MRPPRODVERSION/api/pcp/v1/ProdVersion
Cadastra uma nova Vers�o da Produ��o MRP

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD POST prodversion WSSERVICE mrpproductionversion
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpVPPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0005), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/ProdVersion/Sync
Sincroniza��o da vers�o da produ��o no MRP (Apaga todas os registros existentes na base, e inclui as recebidas na requisi��o)

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Ricardo Prandi
@since		01/08/2019
@version	12.1.28
/*/
WSMETHOD POST sync WSSERVICE mrpproductionversion
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpVPSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0005), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE MRPPRODVERSION/api/pcp/v1/ProdVersion/
Exclui um registro de Vers�o da Produ��o MRP

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.

@author		Douglas Heydt
@since		16/04/2019
@version	12.1.23
/*/
WSMETHOD DELETE prodversion WSSERVICE mrpproductionversion
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpVPDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0005), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

Return lRet

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4M

@type  Static Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()
	Local aFields := {{"branchId"  		, "T4M_FILIAL", "C", FWSizeFilial()                         , 0},;
	                  {"product"   		, "T4M_PROD"  , "C", GetSx3Cache("T4M_PROD"  , "X3_TAMANHO"), 0},;
					  {"routing"   		, "T4M_ROTEIR", "C", GetSx3Cache("T4M_ROTEIR", "X3_TAMANHO"), 0},;
					  {"warehouse"      , "T4M_ARMCON", "C", GetSx3Cache("T4M_ARMCON", "X3_TAMANHO"), 0},;
                      {"startDate"      , "T4M_DTINI" , "D", 8                                      , 0},;
                      {"endDate"      	, "T4M_DTFIN" , "D", 8                                      , 0},;
	                  {"startQuantity"  , "T4M_QNTDE" , "N", GetSx3Cache("T4M_QNTDE" , "X3_TAMANHO"), GetSx3Cache("T4M_QNTDE", "X3_DECIMAL")},;
                      {"endQuantity"  	, "T4M_QNTATE", "N", GetSx3Cache("T4M_QNTATE", "X3_TAMANHO"), GetSx3Cache("T4M_QNTATE", "X3_DECIMAL")},;
					  {"revision"  		, "T4M_REV"   , "C", GetSx3Cache("T4M_REV"   , "X3_TAMANHO"), 0},;
                      {"code"      		, "T4M_IDREG" , "C", GetSx3Cache("T4M_IDREG" , "X3_TAMANHO"), 0};
	                 }
Return aFields

/*/{Protheus.doc} canProcItm
Fun��o que valida se determinado item da lista poder� ser processado ou n�o.

@type  Static Function
@author lucas.franca
@since 26/04/2019
@version P12.1.25
@param oMRPApi   , Object   , Refer�ncia da classe MRPApi que est� processando os dados.
@param cMapCode  , Character, C�digo do mapeamento que ser� validado
@param oItem     , Object   , Refer�ncia do objeto JSON com os dados que devem ser validados.
@return lRet     , L�gico   , Identifica se os dados est�o v�lidos.
/*/
Function MRPVPVLD(oMRPApi, cMapCode, oItem)
	Local lRet   := .T.

	If lRet .And. Empty(oItem["code"])
		lRet     := .F.
		oMRPApi:SetError(400, STR0007 + " 'code' " + STR0011) //"Atributo 'XXX' n�o foi informado."
	EndIf

	If oMRPApi:cMethod == "POST"

		If lRet .And. oItem["product"] == Nil
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'product' " + STR0011) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. (oItem["startQuantity"] <= 0 .Or. oItem["startQuantity"] == Nil)
			lRet     := .F.
			oMRPApi:SetError(400, STR0012) //"O campo Quantidade � obrigat�rio e seu valor n�o pode ser igual ou menor que 0."
		EndIf

		If lRet .And. (oItem["endQuantity"] <= 0 .Or. oItem["endQuantity"] == Nil)
			lRet     := .F.
			oMRPApi:SetError(400, STR0012) //"O campo Quantidade � obrigat�rio e seu valor n�o pode ser igual ou menor que 0."
		EndIf

		If lRet .And. oItem["revision"] == Nil
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'revision' " + STR0011) //"Atributo 'XXX' n�o foi informado."
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} MrpVPPost
Fun��o para disparar as a��es da API de vers�o de produ��o do MRP, para o m�todo POST (Inclus�o).

@type    Function
@author  lucas.franca
@since   24/04/2019
@version P12.1.25
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpVPPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST

	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
	oMRPApi:setBody(oBody)

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

/*/{Protheus.doc} MrpVPSync
Fun��o para disparar as a��es da API de vers�o de produ��o do MRP, para o m�todo Sync (Sincroniza��o).

@type    Function
@author  ricardo.prandi
@since   01/08/2019
@version P12.1.28
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@param   lBuffer, L�gico, Define a sincroniza��o em processo de buffer.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpVPSync(oBody, lBuffer)
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

/*/{Protheus.doc} MrpVPDel
Fun��o para disparar as a��es da API de vers�o de produ��o do MRP, para o m�todo DELETE (Exclus�o).

@type  Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@oaram oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpVPDel(oBody)
	Local aReturn  := {201, ""}
	Local oMRPApi  := defMRPApi("DELETE","") //Inst�ncia da classe MRPApi para o m�todo DELETE

	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
	oMRPApi:setBody(oBody)

	oMRPApi:setMapDelete("fields")

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

/*/{Protheus.doc} MrpVPGCod
Fun��o para disparar as a��es da API de vers�o de produ��o do MRP, para o m�todo GET (Consulta) de um c�digo espec�fico.

@type  Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@param param, param_type, param_descr
@return aReturn, Array, Array com as informa��es da requisi��o.
                        aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Function MrpVPGCod(cBranch, cCode, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"CODE"    , cCode})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a fun��o para retornar os dados.
	aReturn := VPGet(.F., aQryParam, Nil, Nil, Nil, cFields)
Return aReturn

/*/{Protheus.doc} MrpVPGAll
Fun��o para disparar as a��es da API de vers�o de produ��o do MRP, para o m�todo GET (Consulta) para v�rios registros.

@type  Function
@author lucas.franca
@since 24/04/2019
@version P12.1.25
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "DATE"
                                      Array[2][2] = "2019-04-24"
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Function MrpVPGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := VPGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} VPGet
Executa o processamento do m�todo GET de acordo com os par�metros recebidos.

@type  Static Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param lLista   , Logic    , Indica se dever� retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "REVISION"
                                      Array[2][2] = "001"
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo MRPApi.
/*/
Static Function VPGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Inst�ncia da classe MRPApi para o m�todo GET

	//Seta os par�metros de pagina��o, filtros e campos para retorno
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

	//Libera o objeto MRPApi da mem�ria.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} defMRPApi
Faz a inst�ncia da classe MRPAPI e seta as propriedades b�sicas.

@type  Static Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param cMethod  , Character, M�todo que ser� executado (GET/POST/DELETE)
@param cOrder   , Character, Ordena��o para o GET
@return oMRPApi , Object   , Refer�ncia da classe MRPApi com as defini��es j� executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabe�alho)
	oMRPApi:setAPIMap("fields", _aMapField , "T4M", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"T4M_FILIAL","T4M_IDREG"})

	If cMethod == "POST"
		//Seta as fun��es de valida��o de cada mapeamento.
		oMRPApi:setValidData("fields", "MRPVPVLD")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpOrdMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpVPMap()
Return {_aMapField}