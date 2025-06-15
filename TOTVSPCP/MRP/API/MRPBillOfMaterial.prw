#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPBILLOFMATERIAL.CH"

Static _aMapCab   := MapFields(1)
Static _aMapComp  := MapFields(2)
Static _aMapAlt   := MapFields(3)

#DEFINE LISTA_DE_COMPONENTES  "listOfMRPComponents"
#DEFINE LISTA_DE_ALTERNATIVOS "listOfMRPAlternatives"

//dummy function
Function MrpBillOfM()
Return

/*/{Protheus.doc} MrpBillOfMaterial
API de integra��o de ESTRUTURAS do MRP

@type  WSCLASS
@author lucas.franca
@since 18/05/2019
@version P12.1.27
/*/
WSRESTFUL mrpbillofmaterial DESCRIPTION STR0029 FORMAT APPLICATION_JSON //"Estruturas do MRP"
	WSDATA Fields     AS STRING  OPTIONAL
	WSDATA Order      AS STRING  OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL
	WSDATA branchId   AS STRING  OPTIONAL
	WSDATA product    AS STRING  OPTIONAL

	WSMETHOD GET ALLBOM;
		DESCRIPTION STR0001; //"Retorna todas as estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial" ;
		PATH "/api/pcp/v1/mrpbillofmaterial" ;
		TTALK "v1"

	WSMETHOD GET BOM;
		DESCRIPTION STR0002; //"Retorna uma estrutura espec�fica"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/{branchId}/{product}" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/{branchId}/{product}" ;
		TTALK "v1"

	WSMETHOD POST BOM;
		DESCRIPTION STR0003; //"Inclui ou atualiza uma ou mais estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial" ;
		PATH "/api/pcp/v1/mrpbillofmaterial" ;
		TTALK "v1"

	WSMETHOD POST SYNC;
		DESCRIPTION STR0030; //"Sincroniza��o de estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/sync" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/sync" ;
		TTALK "v1"

	WSMETHOD DELETE ESTRUT;
		DESCRIPTION STR0004; //"Exclui uma ou mais estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial" ;
		PATH "/api/pcp/v1/mrpbillofmaterial" ;
		TTALK "v1"

	WSMETHOD DELETE COMPON;
		DESCRIPTION STR0005; //"Exclui um ou mais componentes das estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/component" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/component" ;
		TTALK "v1"

	WSMETHOD DELETE ALTERN;
		DESCRIPTION STR0006; //"Exclui um ou mais alternativos dos componentes das estruturas do MRP"
		WSSYNTAX "api/pcp/v1/mrpbillofmaterial/alternative" ;
		PATH "/api/pcp/v1/mrpbillofmaterial/alternative" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALLBOM /api/pcp/v1/mrpbillofmaterial
Retorna todas as Estruturas MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@param	Order   , caracter, Ordena��o da tabela principal
@param	Page    , num�rico, N�mero da p�gina inicial da consulta
@param	PageSize, num�rico, N�mero de registro por p�ginas
@param	Fields  , caracter, Campos que ser�o retornados no GET.
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLBOM QUERYPARAM Order, Page, PageSize, Fields WSSERVICE mrpbillofmaterial
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := MrpBOMGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} GET BOM /api/pcp/v1/mrpbillofmaterial
Retorna uma estrutura espec�fica do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@param  branchId, Character, C�digo da filial para fazer a busca
@param  product , Character, C�digo do produto para fazer a busca
@param	Fields  , Character, Campos que ser�o retornados no GET.
@return lRet    , L�gico   , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET BOM PATHPARAM branchId, product QUERYPARAM Fields WSSERVICE mrpbillofmaterial
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a fun��o para retornar os dados.
	aReturn := MrpBOMGPrd(Self:branchId, Self:product, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
Return lRet

/*/{Protheus.doc} POST BOM /api/pcp/v1/mrpbillofmaterial
Inclui ou altera uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST BOM WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpBOMPost(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} POST SYNC /api/pcp/v1/mrpbillofmaterial/sync
Sincroniza��o de estruturas

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST SYNC WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpBOMSync(oBody)
		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE BOM /api/pcp/v1/mrpbillofmaterial
Deleta uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ESTRUT WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEstrDel(oBody, 1)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE BOM /api/pcp/v1/mrpbillofmaterial/component
Deleta uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE COMPON WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEstrDel(oBody, 2)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} DELETE BOM /api/pcp/v1/mrpbillofmaterial/alternative
Deleta uma ou mais estruturas do MRP

@type  WSMETHOD
@author lucas.franca
@since 18/05/2019
@version P12.1.27
@return lRet    , L�gico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ALTERN WSSERVICE mrpbillofmaterial
	Local aReturn  := {}
	Local cBody    := ""
	Local cError   := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	cError := oBody:FromJson(cBody)

	If cError == Nil
		aReturn := MrpEstrDel(oBody, 3)
		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		lRet    := .F.
		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"N�o foi poss�vel interpretar os dados recebidos."
	EndIf

	FreeObj(oBody)
	oBody := Nil
Return lRet

/*/{Protheus.doc} MrpBOMPost
Fun��o para disparar as a��es da API de Estruturas do MRP, para o m�todo POST (Inclus�o/Altera��o).

@type    Function
@author  lucas.franca
@since   20/05/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpBOMPost(oBody)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST

	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
	oMRPApi:setBody(oBody)

	//Aciona flag para que a cada atualiza��o, os dados sejam deletados e reinseridos
	oMRPApi:setDelStruct(.T.)

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

/*/{Protheus.doc} MrpBOMSync
Fun��o para disparar as a��es da API de Estruturas do MRP, para o m�todo SYNC (Sincroniza��o).

@type    Function
@author  lucas.franca
@since   05/08/2019
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@param   lBuffer, L�gico, Define a sincroniza��o em processo de buffer.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpBOMSync(oBody,lBuffer)
	Local aReturn := {201, ""}
	Local oMRPApi := defMRPApi("POST","") //Inst�ncia da classe MRPApi para o m�todo POST

	Default lBuffer := .F.

	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
	oMRPApi:setBody(oBody)

	//Seta FLAG que indica o processo de sincroniza��o.
	oMRPApi:setSync(.T.)

	//Seta FLAG que indica o processo de buffer.
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

/*/{Protheus.doc} MrpEstrDel
Fun��o para disparar as a��es da API de Estruturas do MRP, para o m�todo DELETE (Exclus�o) de toda a estrutura.

@type  Function
@author lucas.franca
@since 20/05/2019
@version P12.1.27
@oaram oBody, JsonObject, Objeto JSON com as informa��es recebidas no corpo da requisi��o.
@param nTipo, Numeric   , Identifica o tipo da exclus�o. 1=Estrutura completa. 2=Componente da estrutura; 3=Alternativo do componente.
@return aReturn, Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
Function MrpEstrDel(oBody, nTipo)
	Local aReturn  := {201, ""}
	Local cMapCode := ""
	Local oMRPApi  := defMRPApi("DELETE","") //Inst�ncia da classe MRPApi para o m�todo DELETE

	//Adiciona os par�metros recebidos no corpo da requisi��o (BODY)
	oMRPApi:setBody(oBody)

	Do Case
		Case nTipo == 1
			cMapCode := "fields"
		Case nTipo == 2
			cMapCode := LISTA_DE_COMPONENTES
		Case nTipo == 3
			cMapCode := LISTA_DE_ALTERNATIVOS
	EndCase

	oMRPApi:setMapDelete(cMapCode)

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

/*/{Protheus.doc} MrpBOMGAll
Fun��o para disparar as a��es da API de Estruturas do MRP, para o m�todo GET (Consulta) para v�rias estruturas.

@type  Function
@author lucas.franca
@since 20/05/2019
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "COMPONENT"
                                      Array[2][2] = "PRODUTO002"
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Function MrpBOMGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := BOMGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} MrpBOMGPrd
Fun��o para disparar as a��es da API de Estruturas do MRP, para o m�todo GET (Consulta) de uma estrutura espec�fica.

@type  Function
@author lucas.franca
@since 21/05/2019
@version P12.1.27
@param cBranch , Caracter, C�digo da filial
@param cProduct, Caracter, C�digo do produto pai da estrutura
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informa��es da requisi��o.
                        aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Function MrpBOMGPrd(cBranch, cProduct, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"PRODUCT" , cProduct})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a fun��o para retornar os dados.
	aReturn := BOMGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela T4N e T4O

@type  Static Function
@author lucas.franca
@since 20/05/2019
@version P12.1.27
@param nType, Numeric, Tipo da estrutura (1=Cabe�alho; 2=Componentes; 3=Alternativos)
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields(nType)
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

	If nType == 1
		//Estrutura do cabe�alho
		aFields := { ;
		            {"branchId"  , "T4N_FILIAL", "C", FWSizeFilial()                      , 0},;
		            {"product"   , "T4N_PROD"  , "C", GetSx3Cache("T4N_PROD","X3_TAMANHO"), 0},;
		            {"itemAmount", "T4N_QTDB"  , "N", GetSx3Cache("T4N_QTDB","X3_TAMANHO"), GetSx3Cache("T4N_QTDB","X3_DECIMAL")};
		           }
	ElseIf nType == 2
		//Estrutura da lista de componentes
		aFields := { ;
		            {"component"      , "T4N_COMP"  , "C", GetSx3Cache("T4N_COMP"  ,"X3_TAMANHO"), 0},;
		            {"sequence"       , "T4N_SEQ"   , "C", GetSx3Cache("T4N_SEQ"   ,"X3_TAMANHO"), 0},;
		            {"startRevison"   , "T4N_REVINI", "C", GetSx3Cache("T4N_REVINI","X3_TAMANHO"), 0},;
		            {"endRevison"     , "T4N_REVFIM", "C", GetSx3Cache("T4N_REVFIM","X3_TAMANHO"), 0},;
		            {"quantity"       , "T4N_QTD"   , "N", GetSx3Cache("T4N_QTD"   ,"X3_TAMANHO"), GetSx3Cache("T4N_QTD","X3_DECIMAL")},;
		            {"startDate"      , "T4N_DTINI" , "D", 8, 0},;
		            {"endDate"        , "T4N_DTFIM" , "D", 8, 0},;
		            {"percentageScrap", "T4N_PERDA" , "N", GetSx3Cache("T4N_PERDA" ,"X3_TAMANHO"), GetSx3Cache("T4N_PERDA","X3_DECIMAL")},;
		            {"fixedQuantity"  , "T4N_FIXA"  , "C", GetSx3Cache("T4N_FIXA"  ,"X3_TAMANHO"), 0},;
		            {"optionalGroup"  , "T4N_GROPC" , "C", GetSx3Cache("T4N_GROPC" ,"X3_TAMANHO"), 0},;
		            {"optionalItem"   , "T4N_ITOPC" , "C", GetSx3Cache("T4N_ITOPC" ,"X3_TAMANHO"), 0},;
		            {"potency"        , "T4N_POTEN" , "N", GetSx3Cache("T4N_POTEN" ,"X3_TAMANHO"), GetSx3Cache("T4N_POTEN" ,"X3_DECIMAL")},;
		            {"warehouse"      , "T4N_ARMCON", "C", GetSx3Cache("T4N_ARMCON","X3_TAMANHO"), 0},;
		            {"isGhostMaterial", "T4N_FANTAS", "L", 1, 0},;
		            {"code"           , "T4N_IDREG" , "C", GetSx3Cache("T4N_IDREG" ,"X3_TAMANHO"), 0};
		           }
	ElseIf nType == 3
		//Estrutura dos produtos alternativos.
		aFields := { ;
		            {"sequence"        , "T4O_SEQ"   , "C", GetSx3Cache("T4O_SEQ"   ,"X3_TAMANHO"), 0},;
		            {"alternative"     , "T4O_ALTERN", "C", GetSx3Cache("T4O_ALTERN","X3_TAMANHO"), 0},;
		            {"conversionType"  , "T4O_TPCONV", "C", GetSx3Cache("T4O_TPCONV","X3_TAMANHO"), 0},;
		            {"conversionFactor", "T4O_FATCON", "N", GetSx3Cache("T4O_FATCON","X3_TAMANHO"), GetSx3Cache("T4O_FATCON","X3_DECIMAL")},;
		            {"vigency"         , "T4O_DATA"  , "D", GetSx3Cache("T4O_DATA"  ,"X3_TAMANHO"), 0},;
		            {"inventory"       , "T4O_ESTOQ" , "C", GetSx3Cache("T4O_ESTOQ" ,"X3_TAMANHO"), 0};
		           }
	EndIf
Return aFields

/*/{Protheus.doc} BOMGet
Executa o processamento do m�todo GET de acordo com os par�metros recebidos.

@type  Static Function
@author lucas.franca
@since 30/05/2019
@version P12.1.27
@param lLista   , Logic    , Indica se dever� retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "COMPONENT"
                                      Array[2][2] = "PRODUTO002"
@param cOrder   , Character, Ordena��o desejada do retorno.
@param nPage    , Numeric  , P�gina dos dados. Se n�o enviado, considera p�gina 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por p�gina. Se n�o enviado, considera 20 registros por p�gina.
@param cFields  , Character, Campos que devem ser retornados. Se n�o enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informa��es da requisi��o.
                             aReturn[1] - L�gico    - Indica se a requisi��o foi processada com sucesso ou n�o.
						     aReturn[2] - Character - JSON com o resultado da requisi��o, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - C�digo de erro identificado pelo FwApiManager.
/*/
Static Function BOMGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
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
@since 27/05/2019
@version P12.1.27
@param oMRPApi   , Object   , Refer�ncia da classe MRPApi que est� processando os dados.
@param cMapCode  , Character, C�digo do mapeamento que ser� validado
@param oItem     , Object   , Refer�ncia do objeto JSON com os dados que devem ser validados.
@return lRet     , L�gico   , Identifica se os dados est�o v�lidos.
/*/
Function MRPBOMVLD(oMRPApi, cMapCode, oItem)
	Local lRet := .T.

	Do Case
		Case cMapCode == "fields"
			lRet := validaCab(oMRPApi, oItem)
		Case cMapCode == LISTA_DE_COMPONENTES
			lRet := vldCompons(oMRPApi, oItem)
		Case cMapCode == LISTA_DE_ALTERNATIVOS
			lRet := vldAlterns(oMRPApi, oItem)
	EndCase
Return lRet

/*/{Protheus.doc} validaCab
Faz a valida��o do cabe�alho.

@type  Static Function
@author lucas.franca
@since 05/06/2019
@version P12.1.27
@param oMRPApi, Object    , Refer�ncia da classe MRPAPI que est� executando o processo.
@param oItem  , JsonObject, Objeto JSON do item que ser� validado
@return lRet  , Logical   , Indica se o item poder� ser processado.
/*/
Static Function validaCab(oMRPApi, oItem)
	Local lRet := .T.

	If lRet .And. Empty(oItem["product"])
		lRet := .F.
		oMRPApi:SetError(400, STR0010 + " 'product' " + STR0014) //
	EndIf

Return lRet

/*/{Protheus.doc} vldCompons
Executa as valida��es referentes � lista de componentes para um determinado item.

@type  Static Function
@author lucas.franca
@since 27/05/2019
@version P12.1.27
@param oMRPApi , Object    , Refer�ncia da classe MRPAPI que est� executando o processo.
@param oListCmp, JsonObject, Objeto JSON do item que ser� validado
@return lRet   , L�gico    , Identifica se os dados est�o v�lidos.
/*/
Static Function vldCompons(oMRPApi, oListCmp)
	Local lRet   := .T.

	//C�digo �nico do componente
	If lRet .And. Empty(oListCmp["code"])
		lRet := .F.
		oMRPApi:SetError(400, STR0010 + " 'code' " + STR0014) //"Atributo 'XXX' n�o foi informado."
	EndIf

	If lRet .And. oMRPApi:cMethod == "POST"
		//C�digo do componente preenchido.
		If lRet .And. Empty(oListCmp["component"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'component' " + STR0014) //"Atributo 'XXX' n�o foi informado."
		EndIf

		//Quantidade necess�ria preenchida
		If lRet .And. Empty(oListCmp["quantity"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'quantity' " + STR0014) //"Atributo 'XXX' n�o foi informado."
		EndIf

		If lRet .And. !Empty(oListCmp["fixedQuantity"])
			If !oListCmp["fixedQuantity"] $ "|1|2|"
				lRet := .F.
				oMRPApi:SetError(400, STR0010 + " 'fixedQuantity' " + STR0024) //"Atributo 'XXX' informado incorretamente. Valores suportados: 1=Sim;2=N�o."
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} vldAlterns
Executa as valida��es referentes � lista de componentes para um determinado item.

@type  Static Function
@author lucas.franca
@since 27/05/2019
@version P12.1.27
@param oMRPApi , Object    , Refer�ncia da classe MRPAPI que est� executando o processo.
@param oListAlt, JsonObject, Objeto JSON do item que ser� validado
@return lRet     , L�gico    , Identifica se os dados est�o v�lidos.
/*/
Static Function vldAlterns(oMRPApi, oListAlt)
	Local lRet   := .T.

	//Se enviou lista de alternativos, verifica se os dados est�o v�lidos.
	If lRet .And. Empty(oListAlt["sequence"])
		lRet := .F.
		oMRPApi:SetError(400, STR0010 + " 'sequence' " + STR0014) //"Atributo 'XXX' n�o foi informado."
	EndIf
	If oMRPApi:cMethod == "POST"
		If lRet .And. Empty(oListAlt["alternative"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'alternative' " + STR0014) //"Atributo 'XXX' n�o foi informado."
		EndIf
		If lRet .And. Empty(oListAlt["conversionType"])
			lRet     := .F.
			oMRPApi:SetError(400, STR0010 + " 'conversionType' " + STR0014) //"Atributo 'XXX' n�o foi informado."
		EndIf
		If lRet .And. !oListAlt["conversionType"] $ "|1|2|"
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'conversionType' " + STR0025) ////"Atributo 'XXX' informado incorretamente. Valores suportados: 1=Multiplica��o;2=Divis�o."
		EndIf
		If lRet .And. Empty(oListAlt["conversionFactor"])
			lRet := .F.
			oMRPApi:SetError(400, STR0010 + " 'conversionFactor' " + STR0014) //"Atributo 'XXX' n�o foi informado."
		EndIf
		If lRet .And. !Empty(oListAlt["inventory"])
			If !oListAlt["inventory"] $ "|1|2|3|"
				lRet := .F.
				oMRPApi:SetError(400, STR0010 + " 'inventory' " + STR0026) //"Atributo 'XXX' informado incorretamente. Valores suportados: 1=Original e Alternativo Produz Original;2=Original e Alternativo Produz Alternativo;3=Alternativo. Produz Alternativo."
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} defMRPApi
Faz a inst�ncia da classe MRPAPI e seta as propriedades b�sicas.

@type  Static Function
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@param cMethod  , Character, M�todo que ser� executado (GET/POST/DELETE)
@param cOrder   , Character, Ordena��o para o GET
@return oMRPApi , Object   , Refer�ncia da classe MRPApi com as defini��es j� executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local aRelac  := {}
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabe�alho)
	oMRPApi:setAPIMap("fields"             , _aMapCab , "T4N", .T., "branchId,product")
	//Seta o APIMAP da lista de componentes
	oMRPApi:setAPIMap(LISTA_DE_COMPONENTES , _aMapComp, "T4N", .F., cOrder)
	//Seta o APIMAP da lista de alternativos
	oMRPApi:setAPIMap(LISTA_DE_ALTERNATIVOS, _aMapAlt , "T4O", .F., "sequence")

	//Adiciona o relacionamento entre o cabe�alho e a lista de componentes
	aRelac := {}
	aAdd(aRelac, {"T4N_FILIAL", "T4N_FILIAL"})
	aAdd(aRelac, {"T4N_PROD"  , "T4N_PROD"  })
	oMRPApi:setMapRelation("fields", LISTA_DE_COMPONENTES, aRelac, .T.)

	//Adiciona o relacionamento entre a lista de componentes e a lista de alternativos
	aRelac := {}
	aAdd(aRelac, {"T4N_FILIAL", "T4O_FILIAL"})
	aAdd(aRelac, {"T4N_IDREG" , "T4O_IDEST" })
	oMRPApi:setMapRelation(LISTA_DE_COMPONENTES, LISTA_DE_ALTERNATIVOS, aRelac, .F.)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields"             ,{"T4N_FILIAL","T4N_PROD"})
	oMRPApi:setKeySearch(LISTA_DE_COMPONENTES ,{"T4N_FILIAL","T4N_IDREG"})
	oMRPApi:setKeySearch(LISTA_DE_ALTERNATIVOS,{"T4O_FILIAL","T4O_IDEST","T4O_SEQ"})

	If cMethod == "POST"
		//Seta as fun��es de valida��o de cada mapeamento.
		oMRPApi:setValidData("fields"             , "MRPBOMVLD")
		oMRPApi:setValidData(LISTA_DE_COMPONENTES , "MRPBOMVLD")
		oMRPApi:setValidData(LISTA_DE_ALTERNATIVOS, "MRPBOMVLD")

		//Seta valores default para os campos
		oMRPApi:setDefaultValues("fields"             , "itemAmount"     , 1)
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "endRevison"     , "ZZZ")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "startDate"      , "1980-01-01")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "endDate"        , "2999-12-31")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "fixedQuantity"  , "2")
		oMRPApi:setDefaultValues(LISTA_DE_COMPONENTES , "isGhostMaterial", .F.)
		oMRPApi:setDefaultValues(LISTA_DE_ALTERNATIVOS, "inventory"      , "1")
	EndIf
Return oMRPApi

/*/{Protheus.doc} MrpBOMMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  marcelo.neumann
@since   18/10/2019
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function MrpBOMMap()
Return {_aMapCab, _aMapComp, _aMapAlt}
