#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpproductionorder.CH"

Static _aMapOrd   := MapFields()

Function MrpPrdOrd()
Return

/*/{Protheus.doc} MrpProductionOrders
API de integra��o de Ordens de Produ��o MRP
@type  WSCLASS
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
/*/
WSRESTFUL mrpproductionorders DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ordem de Produ��o MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL

	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA code    	  AS STRING  OPTIONAL

	WSMETHOD GET ALLORDERS;
		DESCRIPTION STR0002;//"Retorna todas as Ordens de Produ��o MRP"
		WSSYNTAX "api/pcp/v1/mrpproductionorders" ;
		PATH "/api/pcp/v1/mrpproductionorders" ;
		TTALK "v1"

	WSMETHOD GET ORDER;
		DESCRIPTION STR0003;//"Retorna um registro de Ordem de Produ��o MRP"
		WSSYNTAX "api/pcp/v1/mrpproductionorders/{branchId}/{code}" ;
		PATH "/api/pcp/v1/mrpproductionorders/{branchId}/{code}" ;
		TTALK "v1"

	WSMETHOD POST ORDER;
		DESCRIPTION STR0004;//"Inclui ou atualiza uma ou mais ordens de produ��o MRP"
		WSSYNTAX "api/pcp/v1/mrpproductionorders" ;
		PATH "/api/pcp/v1/mrpproductionorders" ;
		TTALK "v1"

	WSMETHOD POST sync;
		DESCRIPTION STR0011; //"Sincroniza��o das ordens de produ��o o no MRP"
		WSSYNTAX "api/pcp/v1/mrpproductionorders/sync" ;
		PATH "/api/pcp/v1/mrpproductionorders/sync" ;
		TTALK "v1"


	WSMETHOD DELETE ORDERS;
		DESCRIPTION STR0005;//"Exclui uma ou mais ordens de produ��o MRP"
		WSSYNTAX "api/pcp/v1/mrpproductionorders" ;
		PATH "/api/pcp/v1/mrpproductionorders" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALLORDERS /api/pcp/v1/mrpproductionorders
Retorna todas as Ordens de produ��o MRP
@type  WSMETHOD
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@param	Order   , caracter, Ordena��o da tabela principal
@param	Page    , num�rico, N�mero da p�gina inicial da consulta
@param	PageSize, num�rico, N�mero de registro por p�ginas
@param	Fields  , caracter, Campos que ser�o retornados no GET.
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLORDERS QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpproductionorders

	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpGAllOrd(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
    MRPApi():restReturn(Self, aReturn, "GET", @lRet)

Return lRet

/*/{Protheus.doc} GET ORDER /api/pcp/v1/mrpproductionorders
Retorna um registro de Ordem de Produ��o MRP
@type  WSMETHOD
@author douglas.heydt
@since 07/06/2019
@version P12.1.27
@param	Fields  , caracter, Campos que ser�o retornados no GET.
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ORDER PATHPARAM branchId, code QUERYPARAM Fields WSSERVICE mrpproductionorders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a fun��o para retornar os dados.
	aReturn := MrpGetOrd(Self:branchId, Self:code, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST ORDER /api/pcp/v1/mrpproductionorders
Inclui ou atualiza uma ou mais ordens de produ��o MRP
@type  WSMETHOD
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST ORDER WSSERVICE mrpproductionorders
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpOrdPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/ProdVersion/Sync
Sincroniza��o das ordens de produ��o no MRP (Apaga todas os registros existentes na base, e inclui as recebidas na requisi��o)

@return lRet	, L�gico, Informa se o processo foi executado com sucesso.
@author		brunno.costa
@since		05/08/2019
@version	12.1.28
/*/
WSMETHOD POST sync WSSERVICE mrpproductionorders
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpOPSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0005), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil

Return lRet

/*/{Protheus.doc} DELETE ORDER /api/pcp/v1/mrpbillofmaterial
Exclui uma ou mais ordens de produ��o MRP
@type  WSMETHOD
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ORDER WSSERVICE mrpproductionorders
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpOrdDel(oBody)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0006), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
Return lRet


/*/{Protheus.doc} MrpOrdPost
Fun��o para disparar as a��es da API para o m�todo POST (Inclus�o/Altera��o).
@type    Function
@author  douglas.heydt
@since   10/06/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpOrdPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST

	//Seta valores default de campos
	oMRPApi:setDefaultValues("fields", "situation", "1")

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


/*/{Protheus.doc} MRPORDVLD
Fun��o respons�vel por validar as informa��es recebidas.
@type  Function
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@param oMRPApi   , Object   , Refer�ncia da classe MRPApi que est� processando os dados.
@param cMapCode  , Character, C�digo do mapeamento que ser� validado
@param oItem     , Object   , Refer�ncia do objeto JSON com os dados que devem ser validados.
@return lRet     , L�gico   , Identifica se os dados est�o v�lidos.
/*/
Function MRPORDVLD(oMRPApi, cMapCode,oItem)
	Local lRet := .T.
	Default cMapCode := "fields"

	lRet := vldOrdem(oMRPApi, oItem)

Return lRet

/*/{Protheus.doc} vldOrdem
Faz a valida��o do item.
@type  Static Function
@author douglas.heydt
@since 11/06/2019
@version P12.1.27
@param oMRPApi, Object    , Refer�ncia da classe MRPAPI que est� executando o processo.
@param oItem  , JsonObject, Objeto JSON do item que ser� validado
@return lRet  , Logical   , Indica se o item poder� ser processado.
/*/
Static Function vldOrdem(oMRPApi, oItem)
	Local lRet      := .T.
	Local nIndex
	Local nErrCode
	Local cError

	If lRet .And. Empty(oItem["code"])
		lRet     := .F.
		oMRPApi:SetError(400, STR0007 + " 'code' " + STR0008) //"Atributo 'XXX' n�o foi informado."
	EndIf

	If oMRPApi:cMethod != "DELETE"
		If lRet .And. Empty(oItem["productionOrder"])
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'productionOrder' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. Empty(oItem["product"])
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'product' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. (Empty(oItem["quantity"]) .Or. oItem["quantity"] <= 0)
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'quantity' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. oItem["productionAmount"] == Nil
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'productionAmount' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. Empty(oItem["startDate"])
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'startDate' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. Empty(oItem["deliveryDate"])
			lRet     := .F.
			oMRPApi:SetError(400, STR0007 + " 'deliveryDate' " + STR0008) //"Atributo 'XXX' n�o foi informado."
		EndIf

		//Valida se os opcionais est�o no formato correto.
		If lRet .And. oItem["optional"] != Nil
			If ValType(oItem["optional"]) != "A"
				lRet     := .F.
				nErrCode := 400
				cError   := STR0007 + " 'optional' " + STR0009 //"Atributo 'XXX' enviado em formato incorreto."
			EndIf
			If lRet
				nTam := Len(oItem["optional"])
				For nIndex := 1 To nTam
					If oItem["optional"][nIndex]["key"] == Nil
						lRet     := .F.
						nErrCode := 400
						cError   := STR0007 + " 'key' " + STR0010 //"Atributo 'XXX' n�o informado para os opcionais."
						Exit
					EndIf
					If oItem["optional"][nIndex]["value"] == Nil
						lRet     := .F.
						nErrCode := 400
						cError   := STR0007 + " 'value' " + STR0010 //"Atributo 'XXX' n�o informado para os opcionais."
						Exit
					EndIf
				Next nIndex
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} MrpOPSync
Fun��o para disparar as a��es da API de ordens de produ��o do MRP, para o m�todo Sync (Sincroniza��o).

@type    Function
@author  brunno.costa
@since   05/08/2019
@version P12.1.28
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@param   lBuffer, L�gico, Define a sincroniza��o em processo de buffer.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpOPSync(oBody, lBuffer)
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

/*/{Protheus.doc} MrpOrdDel
Fun��o para disparar as a��es da API para o m�todo DELETE (Exclus�o)
@type  Function
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@param oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpOrdDel(oBody)
	Local aReturn  := {201, ""}
	Local oMRPApi  := defMRPApi("DELETE","") //Inst�ncia da classe MRPApi para o m�todo DELETE

	//Seta as fun��es de valida��o de cada mapeamento.
	oMRPApi:setValidData("fields", "MRPORDVLD")

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

/*/{Protheus.doc} MrpGetOrd
Fun��o para disparar as a��es da API para o m�todo GET (Consulta) de uma ordem de produ��o espec�fica
@type  Function
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@param cBranch , Caracter, C�digo da filial
@param cCode, Caracter, C�digo do registro da ordem de produ��o
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informa��es da requisi��o.
                        aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Function MrpGetOrd(cBranch, cCode, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"CODE" , cCode})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a fun��o para retornar os dados.
	aReturn := ORDERGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MrpGAllOrd
Fun��o para disparar as a��es da API para o m�todo GET (Consulta) de uma lista de ordens de produ��o
@type  Function
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
*/
Function MrpGAllOrd(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := ORDERGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} ORDERGet
Executa o processamento do m�todo GET de acordo com os par�metros recebidos.

@type  Static Function
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@param lLista   , Logic    , Indica se dever� retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Static Function ORDERGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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
@author douglas.heydt
@since 06/06/2019
@version P12.1.27
@param cMethod  , Character, M�todo que ser� executado (GET/POST/DELETE)
@param cOrder   , Character, Ordena��o para o GET
@return oMRPApi , Object   , Refer�ncia da classe MRPApi com as defini��es j� executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabe�alho)
	oMRPApi:setAPIMap("fields"             , _aMapOrd , "T4Q", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields"          , {"T4Q_FILIAL","T4Q_IDREG"})

	If cMethod == "POST"
		//Seta as fun��es de valida��o de cada mapeamento.
		oMRPApi:setValidData("fields", "MRPORDVLD")
	EndIf

Return oMRPApi

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da tabela T4Q
@type  Static Function
@author douglas.heydt
@since 10/06/2019
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()

	Local aFields := {}
	aFields := {;
	            {"branchId"           , "T4Q_FILIAL"  , "C", FWSizeFilial()                        , 0 },;
	            {"product"            , "T4Q_PROD"    , "C", GetSx3Cache("T4Q_PROD"  ,"X3_TAMANHO"), 0 },;
	            {"productionOrder"    , "T4Q_OP"      , "C", GetSx3Cache("T4Q_OP"    ,"X3_TAMANHO"), 0 },;
	            {"mainProductionOrder", "T4Q_OPPAI"   , "C", GetSx3Cache("T4Q_OPPAI" ,"X3_TAMANHO"), 0 },;
	            {"warehouse"          , "T4Q_LOCAL"   , "C", GetSx3Cache("T4Q_LOCAL" ,"X3_TAMANHO"), 0 },;
	            {"quantity"           , "T4Q_QUANT"   , "N", GetSx3Cache("T4Q_QUANT" ,"X3_TAMANHO"), GetSx3Cache("T4Q_QUANT","X3_DECIMAL") },;
	            {"productionAmount"   , "T4Q_SALDO"   , "N", GetSx3Cache("T4Q_SALDO" ,"X3_TAMANHO"), GetSx3Cache("T4Q_SALDO","X3_DECIMAL") },;
	            {"startDate"          , "T4Q_DATPRI"  , "D", 8                                     , 0 },;
	            {"deliveryDate"       , "T4Q_DATA"    , "D", 8                                     , 0 },;
	            {"type"               , "T4Q_TIPO"    , "C", GetSx3Cache("T4Q_TIPO"  ,"X3_TAMANHO"), 0 },;
	            {"situation"          , "T4Q_SITUA"   , "C", GetSx3Cache("T4Q_SITUA" ,"X3_TAMANHO"), 0 },;
	            {"code"               , "T4Q_IDREG"   , "C", GetSx3Cache("T4Q_IDREG" ,"X3_TAMANHO"), 0 },;
	            {"erpStringOptional"  , "T4Q_ERPOPC"  , "C", GetSx3Cache("T4Q_ERPOPC","X3_TAMANHO"), 0 },;
	            {"erpMemoOptional"    , "T4Q_ERPMOP"  , "M", 10                                    , 0 },;
	            {"optional"           , "T4Q_MOPC"    , "O", GetSx3Cache("T4Q_MOPC"  ,"X3_TAMANHO"), 0 };
	           }

	nTamanho := GetSx3Cache("T4Q_PATHOP", "X3_TAMANHO")
	If nTamanho > 0
		aAdd(aFields, {"optionalPathStructure", "T4Q_PATHOP", "M", 10, 0})
	EndIf
Return aFields

/*/{Protheus.doc} MrpOrdMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpOrdMap()
Return {_aMapOrd}
