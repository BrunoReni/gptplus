#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPALLOCATIONS.CH"

Static _aMapFields := MapFields()

//dummy function
Function MrpAllocat()
Return

/*/{Protheus.doc} MrpAllocations
API de integra��o de EMPENHOS do MRP

@type  WSCLASS
@author lucas.franca
@since 10/06/2019
@version P12.1.27
/*/
WSRESTFUL mrpallocations DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Empenhos do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code       AS STRING  OPTIONAL

	WSMETHOD GET ALLALLOCAT;
		DESCRIPTION STR0002; //"Retorna todos os empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations" ;
		PATH "/api/pcp/v1/mrpallocations" ;
		TTALK "v1"

	WSMETHOD GET ALLOCATION;
		DESCRIPTION STR0003; //"Retorna um empenho do MRP espec�fico"
		WSSYNTAX "api/pcp/v1/mrpallocations/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrpallocations/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST ALLOCATION;
		DESCRIPTION STR0004; //"Inclui ou atualiza um ou mais empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations" ;
		PATH "/api/pcp/v1/mrpallocations" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0009; //"Sincroniza��o empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations/sync" ;
		PATH "/api/pcp/v1/mrpallocations/sync" ;
		TTALK "v1"

	WSMETHOD DELETE ALLOCATION;
		DESCRIPTION STR0005; //"Exclui um ou mais empenhos do MRP"
		WSSYNTAX "api/pcp/v1/mrpallocations" ;
		PATH "/api/pcp/v1/mrpallocations" ;
		TTALK "v1"
ENDWSRESTFUL

/*/{Protheus.doc} GET ALLALLOCAT /api/pcp/v1/mrpallocations
Retorna todos os Empenhos MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param	Order   , caracter, Ordena��o da tabela principal
@param	Page    , num�rico, N�mero da p�gina inicial da consulta
@param	PageSize, num�rico, N�mero de registro por p�ginas
@param	Fields  , caracter, Campos que ser�o retornados no GET.
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLALLOCAT QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpallocations
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpEmpGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET ALLOCATION /api/pcp/v1/mrpallocations
Retorna um empenho espec�fico do MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param	branchId, Character, C�digo da filial para fazer a pesquisa
@param	code    , Character, C�digo �nico do empenho para fazer a pesquisa.
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLOCATION PATHPARAM branchId, code QUERYPARAM Fields WSSERVICE mrpallocations
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a fun��o para retornar os dados.
	aReturn := MrpEmpGet(Self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST ALLOCATION /api/pcp/v1/mrpallocations
Inclui ou altera um ou mais empenhos do MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@return lRet, L�gico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST ALLOCATION WSSERVICE mrpallocations
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEmpPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST sync /api/pcp/v1/mrpallocations/sync
Sincroniza��o dos empenhos do MRP

@type  WSMETHOD
@author douglas.heydt
@since 05/08/2019
@version P12.1.27
@return lRet, L�gico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST sync WSSERVICE mrpallocations
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEmpSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE ALLOCATION /api/pcp/v1/mrpallocations
Deleta um ou mais empenhos do MRP

@type  WSMETHOD
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@return lRet, L�gico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ALLOCATION WSSERVICE mrpallocations
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEmpDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpEmpPost
Fun��o para disparar as a��es da API de empenhos do MRP, para o m�todo POST (Inclus�o/Altera��o).

@type    Function
@author  lucas.franca
@since   10/06/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEmpPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST

	//Seta as fun��es de valida��o de cada mapeamento.
	oMRPApi:setValidData("fields", "MRPEMPVLD")

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

/*/{Protheus.doc} MrpEmpSync
Fun��o para disparar as a��es da API de empenhos do MRP, para o m�todo Sync (sincroniza��o).

@type    Function
@author  douglas.heydt
@since   10/06/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@param   lBuffer, L�gico, Define a sincroniza��o em processo de buffer.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEmpSync(oBody, lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST

	//Seta as fun��es de valida��o de cada mapeamento.
	oMRPApi:setValidData("fields", "MRPEMPVLD")

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

/*/{Protheus.doc} MrpEmpDel
Fun��o para disparar as a��es da API de Empenhos do MRP, para o m�todo DELETE (Exclus�o).

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEmpDel(oBody)
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

/*/{Protheus.doc} MrpEmpGAll
Fun��o para disparar as a��es da API de Empenhos do MRP, para o m�todo GET (Consulta) para v�rios empenhos.

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo MRPApi.
/*/
Function MrpEmpGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := EmpGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpEmpGet
Fun��o para disparar as a��es da API de Empenhos do MRP, para o m�todo GET (Consulta) de um empenho espec�fico.

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param cBranch , Caracter, C�digo da filial
@param cCode   , Caracter, C�digo �nico do empenho
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informa��es da requisi��o.
                        aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						aReturn[3] - Numeric   - C�digo de erro identificado pelo MRPApi.
/*/
Function MrpEmpGet(cBranch, cCode, cFields)
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
	aReturn := EmpGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4S

@type  Static Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()
	Local aFields := {}

/*
	O array de mapeamento do JSON � composto por:
	aArray[1]
	aArray[1][1] = Nome do elemento do JSON que cont�m a informa��o.
	aArray[1][2] = Nome da coluna da tabela correspondente a informa��o.
	aArray[1][3] = Tipo de dado no banco de dados.
	aArray[1][4] = Tamanho do campo.
	aArray[1][5] = Decimais do campo, quando � do tipo Num�rico.
*/
	aFields := { ;
	            {"branchId"           , "T4S_FILIAL", "C", FWSizeFilial()                        , 0},;
	            {"code"               , "T4S_IDREG" , "C", GetSx3Cache("T4S_IDREG" ,"X3_TAMANHO"), 0},;
	            {"product"            , "T4S_PROD"  , "C", GetSx3Cache("T4S_PROD"  ,"X3_TAMANHO"), 0},;
	            {"productionOrder"    , "T4S_OP"    , "C", GetSx3Cache("T4S_OP"    ,"X3_TAMANHO"), 0},;
	            {"productionOrderOrig", "T4S_OPORIG", "C", GetSx3Cache("T4S_OPORIG","X3_TAMANHO"), 0},;
	            {"allocationDate"     , "T4S_DT"    , "D", 8                                     , 0},;
	            {"sequence"           , "T4S_SEQ"   , "C", GetSx3Cache("T4S_SEQ"   ,"X3_TAMANHO"), 0},;
	            {"quantity"           , "T4S_QTD"   , "N", GetSx3Cache("T4S_QTD"   ,"X3_TAMANHO"), GetSx3Cache("T4S_QTD"  , "X3_DECIMAL")},;
	            {"suspendedQuantity"  , "T4S_QSUSP" , "N", GetSx3Cache("T4S_QSUSP" ,"X3_TAMANHO"), GetSx3Cache("T4S_QSUSP", "X3_DECIMAL")},;
	            {"warehouse"          , "T4S_LOCAL" , "C", GetSx3Cache("T4S_LOCAL" ,"X3_TAMANHO"), 0};
	           }
Return aFields

/*/{Protheus.doc} EmpGet
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
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo MRPApi.
/*/
Static Function EmpGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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

/*/{Protheus.doc} MRPBOMVLD
Fun��o respons�vel por validar as informa��es recebidas.

@type  Function
@author lucas.franca
@since 10/06/2019
@version P12.1.27
@param oMRPApi   , Object   , Refer�ncia da classe MRPApi que est� processando os dados.
@param cMapCode  , Character, C�digo do mapeamento que ser� validado
@param oItem     , Object   , Refer�ncia do objeto JSON com os dados que devem ser validados.
@return lRet     , L�gico   , Identifica se os dados est�o v�lidos.
/*/
Function MRPEMPVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	If cMapCode == "fields"
		If lRet .And. Empty(oItem["code"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'code' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. Empty(oItem["product"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'product' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf
		If lRet .And. Empty(oItem["productionOrder"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'productionOrder' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf
		If lRet .And. Empty(oItem["allocationDate"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'allocationDate' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf
		If lRet .And. Empty(oItem["quantity"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'quantity' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf
		If lRet .And. Empty(oItem["warehouse"])
			lRet := .F.
			oMRPApi:SetError(400, STR0007 + " 'warehouse' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf
	EndIf
Return lRet

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
	oMRPApi:setAPIMap("fields", _aMapFields , "T4S", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"T4S_IDREG"})
Return oMRPApi

/*/{Protheus.doc} MrpEmpMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpEmpMap()
Return {_aMapFields}
