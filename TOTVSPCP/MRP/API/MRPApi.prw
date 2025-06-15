#INCLUDE "TOTVS.CH"
#INCLUDE "MRPApi.ch"

//Dummy Function
Function MRPApi()
Return

/*/{Protheus.doc} MRPApi
Classe para realizar o processamento de APIs do MRP com dados em LOTE.

@type  CLASS
@author lucas.franca
@since 03/06/2019
@version P12
/*/
Class MRPApi

	DATA aQryParams         AS Array
	DATA aFields            AS Array
	DATA aSuccess           AS Array
	DATA aError             AS Array
	DATA cMapCodePrincipal  AS Character
	DATA cMapCodeDelete     AS Character
	DATA cFields            AS Character
	DATA cFilDelIN          AS Character
	DATA cMethod            AS Character
	DATA cMessage           AS Character
	DATA nPage              AS Numeric
	DATA nPageSize          AS Numeric
	DATA nStatus            AS Numeric
	DATA lBuffer			AS Logic
	DATA lDelStruct         AS Logic
	DATA lSync              AS Logic
	DATA lUmRegistro        AS Logic
	DATA lUsaTransaction    AS Logic
	DATA lForcaTransacao    AS Logic
	DATA lValidouRequisicao AS Logic
	DATA oBody              AS Object
	DATA oDadosInclui       AS Object
	DATA oJsonRet           AS Object
	DATA oApiMap            AS Object
	DATA oMapRel            AS Object
	DATA oKeySearch         AS Object
	DATA oValid             AS Object
	DATA oValorDefault      AS Object
	DATA oContrDadosPai     AS Object

	//M�todos de inicializa��o/destrui��o.
	Method New(cMethod) Constructor
	Method Destroy()

	//M�todos de SET
	Method setAPIMap(cMapCode, aMap, cAlias, lDistinct, cOrder)
	Method setMapRelation(cCodePai, cCodeFilho, aRelac, lObrigat)
	Method setFilDel(cFilDelIN)
	Method setFields(cFields)
	Method setPage(nPage)
	Method setPageSize(nPageSize)
	Method setQueryParams(aQryParams)
	Method setUmRegistro(lUmRegistro)
	Method setBody(oBody)
	Method setValidData(cMapCode, cVldFunc)
	Method setKeySearch(cMapCode, aFields)
	Method setError(nStatus, cMessage)
	Method setDefaultValues(cMapCode, cField, xValue)
	Method setMapDelete(cMapCode)
	Method setSync(lSync)
	Method setBuffer(lBuffer)
	Method setDelStruct(lDelStruct)

	//M�todos de GET
	Method getRetorno(nTipo)
	Method getStatus()
	Method getMessage()

	//M�todos de processamento
	Method processar(cMapCode)
	Method executaGet(aDados, cMapCode, aFilters, aFilterVal)
	Method executaPost()
	Method executaDelete()
	Method procPost(cMapCode, oItem, oInfoPai, lInclusao, lProcIns, aSqlRun, lVldItems)
	Method procDelete(cMapCode, oItem, oInfoPai)
	Method buscaRegistro(cMapCode, aKeySearch, cWhere)
	Method updateReg(nRecno, cMapCode, oItem)
	Method deletaFilhos(cMapCode, cWhere)
	Method deleteReg(cWhere, cTabela)
	Method adicionaArrayInclusao(cMapCode, oItem, oInfoPai, lVldItems)
	Method processaInclusao(cMapCode)
	Method cargaCabUpdate(oInfoCab)
	Method regPaiIncluido(oInfoPai)

	//M�todos de valida��o
	Method canProcReq()
	Method validaItem(cMapCode, oItem)
	Method validaTamanhos(cMapCode, oItem)

	//M�todos auxiliares
	Method montaQuery(cMapCode, aFilters)
	Method montaCampoQuery(cOperacao, cQuery, cAlias, cColuna, cTipo, cValor)
	Method montaInfoPai(aKeyFilho, cMapCode, oItem, oInfoPai)
	Method forcaTransacao(lForca)
	Method formatDado(cValType, xValue, cOrigem, nTamanho)
	Method restReturn(oWsRest, aReturn, cMethod, lReturn)
	Method msgRetorno(cMetodo, lStatus, aSuccess, aError, cMessage, cDetMsg, nErrCode, aReturn)
	Method defineTransaction()
	Method getKeySearch(cMapCode, oItem, oInfoPai)
	Method ordenaMap(cMapCode)
	Method validaDicionario()

EndClass

/*/{Protheus.doc} New
M�todo construtor da classe MRPApi

@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMethod   , Caracter, M�todo que ser� executado (GET/POST/DELETE)
@return Self     , Object  , Refer�ncia da classe MRPApi
/*/
Method New(cMethod) CLASS MRPApi
	Self:aQryParams         := {}
	Self:aFields            := {}
	Self:aSuccess           := {}
	Self:aError             := {}
	Self:cFilDelIN          := ""
	Self:cMethod            := cMethod
	Self:cMapCodePrincipal  := "fields"
	Self:cMapCodeDelete     := "fields"
	Self:cFields            := ""
	Self:cMessage           := ""
	Self:nStatus            := 200
	Self:nPage              := 1
	Self:nPageSize          := 20
	Self:lUmRegistro        := .F.
	Self:lValidouRequisicao := .F.
	Self:lUsaTransaction    := .F.
	Self:lForcaTransacao    := .F.
	Self:lSync              := .F.
	Self:lBuffer			:= .F.
	Self:lDelStruct         := .F.
	Self:oBody              := Nil
	Self:oApiMap            := JsonObject():New()
	Self:oDadosInclui       := JsonObject():New()
	Self:oMapRel            := JsonObject():New()
	Self:oJsonRet           := JsonObject():New()
	Self:oValid             := JsonObject():New()
	Self:oKeySearch         := JsonObject():New()
	Self:oValorDefault      := JsonObject():New()
	Self:oContrDadosPai     := JsonObject():New()
Return Self

/*/{Protheus.doc} Destroy
Limpa os objetos da mem�ria

@author lucas.franca
@since 03/06/2019
@version P12.1.27
@return Nil
/*/
Method Destroy() CLASS MRPApi
	aSize(Self:aQryParams  , 0)
	aSize(Self:aFields     , 0)
	aSize(Self:aSuccess    , 0)
	aSize(Self:aError      , 0)
	Self:cMapCodePrincipal  := "fields"
	Self:cMapCodeDelete     := "fields"
	Self:cMethod            := ""
	Self:cFields            := ""
	Self:cMessage           := ""
	Self:nStatus            := 0
	Self:nPage              := 0
	Self:nPageSize          := 0
	Self:lUmRegistro        := .F.
	Self:lUsaTransaction    := .F.
	Self:lValidouRequisicao := .F.
	Self:lSync              := .F.
	FreeObj(Self:oApiMap)
	Self:oApiMap := Nil
	FreeObj(Self:oDadosInclui)
	Self:oDadosInclui := Nil
	FreeObj(Self:oMapRel)
	Self:oMapRel := Nil
	FreeObj(Self:oJsonRet)
	Self:oJsonRet := Nil
	FreeObj(Self:oValid)
	Self:oValid := Nil
	FreeObj(Self:oKeySearch)
	Self:oKeySearch := Nil
	FreeObj(Self:oValorDefault)
	Self:oValorDefault := Nil
	If Self:oBody != Nil
		FreeObj(Self:oBody)
		Self:oBody := Nil
	EndIf
	FreeObj(Self:oContrDadosPai)
	Self:oContrDadosPai := Nil
Return Nil

/*/{Protheus.doc} setAPIMap
Faz o SET do APIMAP que ser� utilizado no processamento
Informa��es utilizadas para buscar os dados da tabela

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode , Caracter, C�digo do mapeamento
@param aMap     , Array   , Array com o mapeamento dos campos da API x Campos do Protheus.
                            O array aMap deve possuir a seguinte estrutura:
                            - aMap[1]
                            - aMap[1][1] = Nome do elemento do JSON que cont�m a informa��o.
                            - aMap[1][2] = Nome da coluna da tabela correspondente a informa��o.
                            - aMap[1][3] = Tipo de dado no banco de dados.
                            - aMap[1][4] = Tamanho do campo.
                            - aMap[1][5] = Decimais do campo, quando � do tipo Num�rico.
@param cAlias   , Caracter, Tabela (alias) utilizada para fazer a consulta.
@param lDistinct, Logic   , Indica se a query dever� ser montada com SELECT DISTINCT
@param cOrder   , Caracter, Ordena��o que dever� ser utilizada
@return Nil
/*/
Method setAPIMap(cMapCode, aMap, cAlias, lDistinct, cOrder) CLASS MRPApi
	Local nIndex    := 0
	Local nTotal    := Len(aMap)
	Local aOrder    := {}
	Local aAux      := {}
	Local aFieldOrd := {}

	If !Empty(cOrder)
		aOrder := strTokArr(cOrder, ",")
		//Separa as colunas de ordenamento em um array
		For nIndex := 1 To Len(aOrder)
			aAux := strTokArr(aOrder[nIndex], "|")
			If Len(aAux) < 2
				aAdd(aFieldOrd, {aAux[1], " "})//caso a coluna nao tenha  ordenamento, adiciona posi��o vazia no array
			Else
				aAdd(aFieldOrd, aAux)
			EndIf
		Next nIndex
	EndIf

	If Empty(cMapCode)
		cMapCode := "fields"
	EndIf

	Self:oApiMap[cMapCode]                  := JsonObject():New()
	Self:oApiMap[cMapCode]["map"]           := aClone(aMap)
	Self:oApiMap[cMapCode]["alias"]         := cAlias
	Self:oApiMap[cMapCode]["tabela"]        := RetSqlName(cAlias)
	Self:oApiMap[cMapCode]["distinct"]      := lDistinct
	Self:oApiMap[cMapCode]["order"]         := aFieldOrd
	Self:oApiMap[cMapCode]["apiFields"]     := JsonObject():New() //Utilizado para buscar informa��es de forma mais r�pida
	Self:oApiMap[cMapCode]["aliasColumns"]  := JsonObject():New() //Utilizado para buscar informa��es de forma mais r�pida
	Self:oApiMap[cMapCode]["returnFields"]  := Nil
	Self:oApiMap[cMapCode]["oQuery"]        := Nil

	//Ordena o MAP para que os campos do tipo MEMO fiquem no final do array
	Self:ordenaMap(cMapCode)

	aMap := Self:oApiMap[cMapCode]["map"]

	For nIndex := 1 To nTotal
		Self:oApiMap[cMapCode]["apiFields"][Upper(aMap[nIndex][1])]    := nIndex
		Self:oApiMap[cMapCode]["aliasColumns"][Upper(aMap[nIndex][2])] := nIndex
	Next nIndex
Return Nil

/*/{Protheus.doc} setMapRelation
Faz o SET dos relacionamentos entre os mapeamentos do APIMAP

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cCodePai  , Caracter, C�digo do mapeamento PAI
@param cCodeFilho, Caracter, C�digo do mapeamento FILHO
@param aRelac    , Array   , Array contendo as colunas de relacionamento entre o alias pai e o alias filho
                             - Formato do array:
                             - aRelac[1]
                             - aRelac[1][1] = Coluna da tabela PAI
                             - aRelac[1][2] = Coluna da tabela FILHO
@param lObrigat  , Logic   , Identifica se o item filho � de preenchimento obrigat�rio ou opcional
@return Nil
/*/
Method setMapRelation(cCodePai, cCodeFilho, aRelac, lObrigat) CLASS MRPApi
	Local nPos := 0

	If Self:oMapRel[cCodePai] == Nil
		Self:oMapRel[cCodePai] := {}
	EndIf

	If lObrigat == Nil
		lObrigat := .F.
	EndIf

	aAdd(Self:oMapRel[cCodePai], JsonObject():New())
	nPos := Len(Self:oMapRel[cCodePai])
	Self:oMapRel[cCodePai][nPos]["filho"]          := cCodeFilho
	Self:oMapRel[cCodePai][nPos]["obrigatorio"]    := lObrigat
	Self:oMapRel[cCodePai][nPos]["relacionamento"] := aClone(aRelac)
Return Nil

/*/{Protheus.doc} setFields
Faz o SET dos campos que devem ser retornados na API

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cFields, Caracter, Campos que devem ser retornados na API.
@return Nil
/*/
Method setFields(cFields) CLASS MRPApi
	Self:cFields := cFields
	If !Empty(Self:cFields)
		Self:aFields := StrTokArr(Self:cFields,",")
	EndIf
Return Nil

/*/{Protheus.doc} setPage
Faz o SET da p�gina que dever� ser retornada para o m�todo GET

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param nPage, Numeric, P�gina que dever� ser retornada no GET
@return Nil
/*/
Method setPage(nPage) CLASS MRPApi
	If nPage != Nil .And. nPage > 0
		Self:nPage := nPage
	EndIf
Return Nil

/*/{Protheus.doc} setPageSize
Faz o SET do tamanho das p�ginas retornadas no m�todo GET

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param nPageSize, Numeric, Tamanho das p�ginas que s�o retornadas no m�todo GET
@return Nil
/*/
Method setPageSize(nPageSize) CLASS MRPApi
	If nPageSize != Nil .And. nPageSize > 0
		Self:nPageSize := nPageSize
	EndIf
Return Nil

/*/{Protheus.doc} setQueryParams
Faz o SET do tamanho das p�ginas retornadas no m�todo GET

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param aQryParams, Array, Query Parameters recebidos na requisi��o
@return Nil
/*/
Method setQueryParams(aQryParams) CLASS MRPApi
	Self:aQryParams := aQryParams
Return Nil

/*/{Protheus.doc} setUmRegistro
Faz o SET do indicador de que deve retornar apenas um registro no GET

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param lUmRegistro, Logic, Indicador de que ser� retornado apenas um registro no GET
@return Nil
/*/
Method setUmRegistro(lUmRegistro) CLASS MRPApi
	Self:lUmRegistro := lUmRegistro
Return Nil

/*/{Protheus.doc} setBody
Faz o SET do conte�do recebido no corpo da requisi��o.

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param oBody, Object, JSON recebido no corpo da requisi��o
@return Nil
/*/
Method setBody(oBody) CLASS MRPApi
	Self:oBody := oBody
Return Nil

/*/{Protheus.doc} setValidData
Faz o SET dos relacionamentos entre os mapeamentos do APIMAP

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode, Caracter, C�digo do mapeamento PAI
@param cVldFunc, Caracter, Fun��o que ser� executada para valida��es espec�ficas
@return Nil
/*/
Method setValidData(cMapCode, cVldFunc) CLASS MRPApi
	If Empty(cMapCode)
		cMapCode := "fields"
	EndIf

	If Empty(cVldFunc)
		cVldFunc := ""
	EndIf
	Self:oValid[cMapCode] := cVldFunc
Return Nil

/*/{Protheus.doc} setKeySearch
Faz o SET das chaves de pesquisa que ser�o utilizadas

@type  METHOD
@author lucas.franca
@since 05/06/2019
@version P12.1.27
@param cMapCode, Caracter, C�digo do mapeamento PAI
@param aFields , Array   , Array com os campos que ser�o utilizados.
@return Nil
/*/
Method setKeySearch(cMapCode, aFields) CLASS MRPApi
	Self:oKeySearch[cMapCode] := aFields
Return Nil

/*/{Protheus.doc} setError
Seta um c�digo e mensagem de erro.

@type  METHOD
@author lucas.franca
@since 05/06/2019
@version P12.1.27
@param nStatus , Numeric  , C�digo do erro
@param cMessage, Character, Mensagem de erro
@return Nil
/*/
Method setError(nStatus, cMessage) CLASS MRPApi
	Self:nStatus  := nStatus
	Self:cMessage := cMessage
Return Nil

/*/{Protheus.doc} setDefaultValues
Configura os valores default que ser�o assumidos durante a inclus�o
caso os valores n�o sejam recebidos.

@type  METHOD
@author lucas.franca
@since 05/06/2019
@version P12.1.27
@param cMapCode, Character, C�digo do mapeamento PAI
@param cField  , Character, Campo da API que ter� valor default
@param xValue  , Any      , Valor default que ser� assumido para o campo
@return Nil
/*/
Method setDefaultValues(cMapCode, cField, xValue) CLASS MRPApi
	If Self:oValorDefault[cMapCode] == Nil
		Self:oValorDefault[cMapCode] := JsonObject():New()
	EndIf
	Self:oValorDefault[cMapCode][cField] := xValue
Return Nil

/*/{Protheus.doc} setMapDelete
Define qual dos mapeamentos ser� deletado durante o processamento.

@type  METHOD
@author lucas.franca
@since 05/06/2019
@version P12.1.27
@param cMapCode, Character, C�digo do mapeamento que deve ser deletado
@return Nil
/*/
Method setMapDelete(cMapCode) CLASS MRPApi
	Self:cMapCodeDelete := cMapCode
Return Nil

/*/{Protheus.doc} setSync
Seta a propriedade de sincronismo na API.

@type  METHOD
@author lucas.franca
@since 05/06/2019
@version P12.1.27
@param lSync, Logic, Flag identificadora de processo de sincronismo
@return Nil
/*/
Method setSync(lSync) CLASS MRPApi
	Self:lSync := lSync
Return Nil

/*/{Protheus.doc} setBuffer
Seta a propriedade de carregamento do buffer.

@type  METHOD
@author mauricio.joao
@since 18/12/2020
@version P12.1.27
@param lBuffer, Logic, Flag identificadora de processo de buffer
@return Nil
/*/
Method setBuffer(lBuffer) CLASS MRPApi
	Self:lBuffer := lBuffer
Return Nil

/*/{Protheus.doc} setFilDel
Seta a propriedade das filiais a serem exclu�das na sincroniza��o.

@type  METHOD
@author marcelo.neumann
@since 18/01/2021
@version P12.1.33
@param cFilDelIN, Character, Filiais para a limpeza dos registros na sincroniza��o
@return Nil
/*/
Method setFilDel(cFilDelIN) CLASS MRPApi
	Self:cFilDelIN := cFilDelIN
Return Nil

/*/{Protheus.doc} setDelStruct
Seta a propriedade de sincronismo na API.

@type  METHOD
@author douglas.heydt
@since 01/08/2019
@version P12.1.27
@param lSync, Logic, Flag identificadora para deletar registros da estrutura
@return Nil
/*/
Method setDelStruct(lDelStruct) CLASS MRPApi
	Self:lDelStruct := lDelStruct
Return Nil

/*/{Protheus.doc} getRetorno
Retorna a string JSON ou o objeto JSON com os dados do processamento.

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param nTipo, Numeric, Identifica o tipo do retorno. 1=String;2=Objeto
@return xRet, Caracter/Object, Retorno do processamento.
/*/
Method getRetorno(nTipo) CLASS MRPApi
	Local xRet    := Nil

	xRet := Self:oJsonRet
	If Self:cMethod == "GET"
		If Self:lUmRegistro
			If Self:oJsonRet["items"] != Nil .And. Len(Self:oJsonRet["items"]) > 0
				xRet := Self:oJsonRet["items"][1]
			EndIf
		EndIf
	EndIf
	If nTipo == 1
		xRet := xRet:ToJson()
	EndIf
Return xRet

/*/{Protheus.doc} getStatus
Retorna o c�digo do status que dever� ser retornado pela API

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@return Self:nStatus, Numeric, C�digo do status do processo
/*/
Method getStatus() CLASS MRPApi
Return Self:nStatus

/*/{Protheus.doc} getMessage
Retorna a mensagem de erro, caso tenha ocorrido.

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@return Self:cMessage, Character, Mensagem de erro
/*/
Method getMessage() CLASS MRPApi
Return Self:cMessage

/*/{Protheus.doc} processar
M�todo que dispara o processamento

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode, Character, C�digo do API MAP principal que ir� disparar o processo
@return lStatus, Logic    , Indica se o processamento foi realizado com sucesso.
/*/
Method processar(cMapCode) CLASS MRPApi
	Local aReturn  := {}
	Local cMessage := ""
	Local cChaveLock := "SYNCDATA_"
	Local cTblLock   := ""
	Local lStatus  := .F.
	Local lRet       := .T.

	Self:cMapCodePrincipal := cMapCode

	cTblLock := Self:oApiMap[Self:cMapCodePrincipal]["tabela"]
	If Self:cMethod $ "|POST|DELETE|"
		/*
			Verifica��o para n�o ocorrer execu��es paralelas
			quando houver um processo de sincroniza��o em andamento.
		*/
		lRet := SemafTable(.T., cTblLock, cChaveLock)
		If !Self:lSync .And. lRet
			//N�o � um processo de sincroniza��o e conseguiu obter o lock.
			//Libera o sem�foro.
			SemafTable(.F., cTblLock, cChaveLock)
		EndIf
	EndIf
	If !lRet
		//Se n�o conseguiu obter o sem�foro, retorna erro.
		lStatus := .F.
		Self:setError(400, STR0018) //"Existe uma sincroniza��o em execu��o neste momento. Atualiza��o de dados n�o permitida."
	ElseIf (lStatus := Self:validaDicionario())

		If Self:cMethod == "GET"
			Self:oJsonRet["items"]   := {}
			Self:oJsonRet["hasNext"] := .F.

			lStatus := Self:executaGet(@Self:oJsonRet["items"], Self:cMapCodePrincipal)
		ElseIf Self:cMethod == "POST"
			lStatus := Self:executaPost()
		ElseIf Self:cMethod == "DELETE"
			lStatus := Self:executaDelete()
		Else
			lStatus := .F.
			Self:setError(400, STR0001) //"Metodo para processamento inv�lido"
		EndIf
	EndIf

	If Self:cMethod $ "|POST|DELETE|"
		If !Self:lValidouRequisicao
			cMessage := STR0002 //"N�o foi poss�vel processar a mensagem."
		Else
			cMessage := Self:cMessage
		EndIf
		Self:msgRetorno(Self:cMethod, Self:lValidouRequisicao, Self:aSuccess, Self:aError, cMessage, Self:cMessage, Self:nStatus, @aReturn)
		Self:nStatus := aReturn[1]
		Self:oJsonRet:FromJson(aReturn[2])
		If Self:lSync .And. lRet
			SemafTable(.F., cTblLock, cChaveLock)
		EndIf
	EndIf
Return lStatus

/*/{Protheus.doc} executaGet
M�todo que executa o processamento do m�todo GET

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param aDados    , Array   , Array que ir� armazenar os registros a retornar
@param cMapCode  , Caracter, C�digo do mapeamento setado.
@param aFilters  , Array   , Filtros que ser�o adicionados na query. Usado para buscar registros filhos.
@param aFilterVal, Array   , Array com os valores dos filtros que ser�o adicionados na query.
@param aNomRelac , Array   , Array com os nomes dos campos do mapa pai passado pelo filtro.
@return lAchou   , Logic   , Indica se encontrou algum registro.
/*/
Method executaGet(aDados, cMapCode, aFilters, aFilterVal, aNomRelac) CLASS MRPApi
	Local aRelac     := {}
	Local aValRelac  := {}
	Local aFieldRet  := {}
	Local aPosMap    := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQuery     := ""
	Local cFieldsQry := ""
	Local cCondQry   := ""
	Local nPos       := 0
	Local nPosMap    := 0
	Local nStart     := 0
	Local nIndex     := 0
	Local nIndRel    := 0
	Local nTotRel    := 0
	Local nTotal     := 0
	Local nTotalFld  := 0
	Local lAchou     := .F.
	Local oQuery     := Self:oApiMap[cMapCode]["oQuery"]
	Local xValue     := Nil

	Default aNomRelac := {}

	If Self:oMapRel[cMapCode] != Nil
		aRelac := Self:oMapRel[cMapCode]
	EndIf

	If oQuery == Nil
		oQuery := Self:montaQuery(cMapCode, aFilters, aNomRelac)
		If oQuery == Nil
			Self:setError(404, STR0004) //"N�o foi poss�vel identificar a chave de pesquisa do item em processamento."
			Return lAchou
		EndIf
	EndIf

	If aFilters != Nil .And. aFilterVal != Nil
		oQuery:setParams(aFilterVal)
	EndIf

	//Monta vari�vel de controle dos campos que ser�o retornados pela API
	If Self:oApiMap[cMapCode]["returnFields"] == Nil
		Self:oApiMap[cMapCode]["returnFields"] := JsonObject():New()
		nTotal := 0
		If Self:aFields != Nil
			nTotal := Len(Self:aFields)
		EndIf
		//Se setou na API quais campos devem ser retornados, utiliza somente os parametrizados.
		If nTotal > 0
			For nIndex := 1 To nTotal
				If Self:oApiMap[cMapCode]["apiFields"][Upper(Self:aFields[nIndex])] != Nil
					Self:oApiMap[cMapCode]["returnFields"][Self:aFields[nIndex]] := ;
					Self:oApiMap[cMapCode]["map"][Self:oApiMap[cMapCode]["apiFields"][Upper(Self:aFields[nIndex])]][2]
				EndIf
			Next nIndex
		Else
			//N�o setou nenhum campo para retornar, ir� retornar todos os campos que est�o definidos no MAP da api.
			nTotal := Len(Self:oApiMap[cMapCode]["map"])
			For nIndex := 1 To nTotal
				Self:oApiMap[cMapCode]["returnFields"][Self:oApiMap[cMapCode]["map"][nIndex][1]] := Self:oApiMap[cMapCode]["map"][nIndex][2]
			Next nIndex
		EndIf
	EndIf

	//Recupera a query montada.
	cQuery := oQuery:GetFixQuery()

	//Separa a query nas vari�veis cFieldsQry e cCondQry para utilizar o Embedded SQL (BeginSql Alias).
	//Necess�rio utilizar o Embedded SQL para retornar as informa��es de campos do tipo MEMO.
	nPos := At("FROM",cQuery)
	cFieldsQry := "%" + StrTran(SubStr(cQuery,1,nPos-1),"SELECT","") + "%"
	cCondQry   := "%" + StrTran(SubStr(cQuery, nPos, (Len(cQuery)-nPos)+1),"FROM","")+ "%"

	BeginSql Alias cAliasQry
		%noparser%
		SELECT %Exp:cFieldsQry%
		FROM %Exp:cCondQry%
	EndSql

	//Ajusta o tipo dos campos DATA, L�GICO e NUM�RICO de acordo com os tamanhos definidos no MAP da API.
	nTotal := Len(Self:oApiMap[cMapCode]["map"])
	For nIndex := 1 To nTotal
		If Self:oApiMap[cMapCode]["map"][nIndex][3] $ "|D|L|N|"
			TcSetField(cAliasQry, Self:oApiMap[cMapCode]["map"][nIndex][2],;
			           Self:oApiMap[cMapCode]["map"][nIndex][3],;
			           Self:oApiMap[cMapCode]["map"][nIndex][4],;
			           Self:oApiMap[cMapCode]["map"][nIndex][5])
		EndIf
	Next nIndex

	//Posiciona no registro correto de acordo com a pagina��o.
	If Self:nPage > 1 .And. cMapCode == Self:cMapCodePrincipal
		nStart := ( (Self:nPage-1) * Self:nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	aFieldRet := Self:oApiMap[cMapCode]["returnFields"]:GetNames()
	nTotalFld := Len(aFieldRet)

	nTotal := Len(aRelac)

	While (cAliasQry)->(!Eof())
		lAchou := .T.
		aAdd(aDados,JsonObject():New())
		nPos := Len(aDados)

		//Carrega as informa��es que devem ser retornadas
		For nIndex := 1 To nTotalFld
			nPosMap := Self:oApiMap[cMapCode]["apiFields"][Upper(aFieldRet[nIndex])]
			aPosMap := Self:oApiMap[cMapCode]["map"][nPosMap]
			xValue  := &("(cAliasQry)->(" + aPosMap[2] + ")")
			aDados[nPos][aFieldRet[nIndex]] := Self:formatDado(aPosMap[3], xValue, "2", aPosMap[4])
		Next nIndex

		//Carrega os itens filhos (listas)
		For nIndex := 1 To nTotal
			aDados[nPos][aRelac[nIndex]["filho"]] := {}
			//Antes de fazer a chamada recursiva para carregar os dados da lista, verifica se existe algum registro.
			If !Empty(&("(cAliasQry)->(relac" + cValToChar(nIndex) + ")"))
				nTotRel := Len(aRelac[nIndex]["relacionamento"])
				aValRelac := {}
				aNomRelac := {}
				For nIndRel := 1 To nTotRel
					aAdd(aValRelac, &("(cAliasQry)->(" + aRelac[nIndex]["relacionamento"][nIndRel][1] + ")"))
					aAdd(aNomRelac, self:oapimap[cMapCode]["map"][self:oapimap[cMapCode]["aliasColumns"][aRelac[nIndex]["relacionamento"][nIndRel][1]]][1])
				Next nIndRel
				Self:executaGet(aDados[nPos][aRelac[nIndex]["filho"]],;
				                aRelac[nIndex]["filho"],;
				                aRelac[nIndex]["relacionamento"],;
				                aValRelac,;
								aNomRelac)
			EndIf
		Next nIndex

		(cAliasQry)->(dbSkip())

		//Se chegou no limite de registros por p�gina, sai do loop e retorna os dados.
		If cMapCode == Self:cMapCodePrincipal
			If nPos >= Self:nPageSize
				Exit
			EndIf

			//Se ir� retornar apenas um registro espec�fico, sai do loop.
			If Self:lUmRegistro
				Exit
			EndIf
		EndIf
	End
	If cMapCode == Self:cMapCodePrincipal .And. (cAliasQry)->(!Eof())
		Self:oJsonRet["hasNext"] := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

	If cMapCode == Self:cMapCodePrincipal
		If !lAchou
			Self:setError(404, STR0003) //"Nenhum registro foi encontrado."
		Else
			Self:nStatus  := 200
		EndIf
	EndIf

Return lAchou

/*/{Protheus.doc} executaPost
Executa o processamento do m�todo POST

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@return lRet, Logic, Identifica se o processamento foi executado com sucesso
/*/
Method executaPost() CLASS MRPApi
	Local aNames    := {}
	Local aSqlRun   := {}
	Local cJsonFil  := ""
	Local cFieldFil := ""
	Local cFiliais  := ""
	Local cWhere    := " WHERE 1=1 "
	Local lRet      := .T.
	Local lInclusao := .F.
	Local lOnlyDel  := .F.
	Local lError    := .F.
	Local nTamFil   := FwSizeFilial()
	Local nPos      := 0
	Local nIndex    := 0
	Local nIndAux   := 0
	Local nTotAux   := 0
	Local nTotal    := 0
	Local oCopyData := JsonObject():New()

	Self:defineTransaction()

	lRet := Self:canProcReq()
	If lRet
		//Se for sincroniza��o, primeiro ir� apagar todos os dados existentes.
		If Self:lSync .and. !Self:lBuffer
			nPos := aScan(Self:oApiMap[Self:cMapCodePrincipal]["map"], {|x| Upper(x[1]) == "BRANCHID"})
			If nPos > 0
				cJsonFil := Self:oApiMap[Self:cMapCodePrincipal]["map"][nPos][1]
				//Verifica se existem filiais para adicionar no filtro de exclus�o.
				If Empty(Self:cFilDelIN)
					If Self:oBody["items"] != Nil
						nTotal := Len(Self:oBody["items"])
						For nIndex := 1 To nTotal
							If Self:oBody["items"][nIndex][cJsonFil] != Nil
								Self:oBody["items"][nIndex][cJsonFil] := PadR(Self:oBody["items"][nIndex][cJsonFil], nTamFil)
								If ! ("'"+Self:oBody["items"][nIndex][cJsonFil]+"'" $ cFiliais)
									If !Empty(cFiliais)
										cFiliais += ","
									EndIf
									cFiliais += "'" + Self:oBody["items"][nIndex][cJsonFil] + "'"
								EndIf
							EndIf
						Next nIndex
					EndIf
				Else
					If Empty(xFilial(Self:oBody["items"][1][cJsonFil]))
						cFiliais := xFilial(Self:oBody["items"][1][cJsonFil])
					Else
						cFiliais := Self:cFilDelIN
					EndIf
				EndIf
			EndIf

			BEGIN TRANSACTION
			aNames := Self:oApiMap:GetNames()
			nTotal := Len(aNames)
			For nIndex := 1 To nTotal
				If !Empty(cFiliais)
					If aNames[nIndex] == Self:cMapCodePrincipal
						cFieldFil := Self:oApiMap[aNames[nIndex]]["map"][nPos][2]

						cWhere := " WHERE " + cFieldFil + " IN (" + cFiliais + ") "
					ElseIf Self:oKeySearch[aNames[nIndex]] != Nil
						nPos := aScan(Self:oKeySearch[aNames[nIndex]], {|x| "_FILIAL" $ x })
						If nPos > 0
							cFieldFil := Self:oKeySearch[aNames[nIndex]][nPos]
							cWhere    := " WHERE " + cFieldFil + " IN (" + cFiliais + ") "
						EndIf
					EndIf
				EndIf
				If !Self:deleteReg(cWhere, Self:oApiMap[aNames[nIndex]]["tabela"])
					DisarmTransaction()
					lRet := .F.
					aAdd(Self:aError, {Self:oBody, Self:nStatus, Self:cMessage})
					Exit
				EndIf
			Next nIndex
			END TRANSACTION
			
			aSize(aNames, 0)

			If Self:oBody["items"] != Nil
				lOnlyDel := .T.
				nTotal   := Len(Self:oBody["items"])
				nTotAux  := Len(Self:oApiMap[Self:cMapCodePrincipal]["map"])

				For nIndex := 1 To nTotal
					For nIndAux := 1 To nTotAux
						If Upper(Self:oApiMap[Self:cMapCodePrincipal]["map"][nIndAux][1]) == "BRANCHID"
							Loop
						EndIf
						If !Empty(Self:oBody["items"][nIndex][Self:oApiMap[Self:cMapCodePrincipal]["map"][nIndAux][1]])
							lOnlyDel := .F.
							Exit
						EndIf
					Next nIndAux
					If !lOnlyDel
						Exit
					EndIf
				Next nIndex

				If lOnlyDel
					//Sincroniza��o apenas para excluir dados.
					//Inicializa o "items" para n�o processar mais nada.
					aSize(Self:oBody["items"], 0)
					Self:oBody["items"] := Nil
				EndIf
			EndIf
		EndIf

		If lRet .And. Self:oBody["items"] != Nil
			//Utiliza um objeto com c�pia dos dados para executar as valida��es.
			//Faz isso para n�o adicionar tags com valor null no JSON que ser� retornado.
			oCopyData:FromJson(Self:oBody:ToJson())
			nTotal := Len(Self:oBody["items"])
			For nIndex := 1 To nTotal
				lRet := Self:validaItem(Self:cMapCodePrincipal, oCopyData["items"][nIndex])
				If !lRet
					//Ocorreu erro de valida��o. N�o processa este item.
					aAdd(Self:aError, {Self:oBody["items"][nIndex], Self:nStatus, Self:cMessage})
				Else
					//deleta os itens antes de inserir novamente
					If Self:lDelStruct
						BEGIN TRANSACTION
							lRet := Self:procDelete('fields', Self:oBody["items"][nIndex], Nil)
							If !lRet
								aAdd(Self:aError, {Self:oBody["items"][nIndex], Self:nStatus, Self:cMessage})
								DisarmTransaction()
							EndIf
						END TRANSACTION
						If !lRet
							Loop
						EndIf
					EndIf

					//Validou os dados, executa a atualiza��o dos dados.
					If Self:lUsaTransaction .And. !Self:lSync
						BEGIN TRANSACTION
						lRet := Self:procPost(Self:cMapCodePrincipal, Self:oBody["items"][nIndex], Nil, @lInclusao, .T., @aSqlRun, .F.)
						If !lRet
							DisarmTransaction()
						EndIf
						END TRANSACTION
						If lRet
							aAdd(Self:aSuccess, Self:oBody["items"][nIndex])
						Else
							aAdd(Self:aError, {Self:oBody["items"][nIndex], Self:nStatus, Self:cMessage})
						EndIf
					Else
						lRet := Self:procPost(Self:cMapCodePrincipal, Self:oBody["items"][nIndex], Nil, @lInclusao, .T., @aSqlRun, .F.)
						If !lRet
							aAdd(Self:aError, {Self:oBody["items"][nIndex], Self:nStatus, Self:cMessage})
						EndIf
						If lRet .And. !lInclusao
							//Registros de inclus�o somente s�o adicionados no array ap�s inserir os dados.
							aAdd(Self:aSuccess, Self:oBody["items"][nIndex])
						EndIf
					EndIf
				EndIf
			Next nIndex
			If !Self:lUsaTransaction .Or. Self:lSync
				aNames := Self:oDadosInclui:GetNames()
				nTotal := Len(aNames)
				//Grava os dados
				BEGIN TRANSACTION
					For nIndex := 1 To nTotal
						If Len(Self:oDadosInclui[aNames[nIndex]]["dados"]) > 0 .And. !lError
							lRet    := Self:processaInclusao(aNames[nIndex])
							lError  := Iif(lError, lError, !lRet)
						EndIf
					Next nIndex

					If !lError
						nTotal := Len(aSqlRun)
						For nIndex := 1 To nTotal 
							If TcSqlExec(aSqlRun[nIndex]) < 0
								//N�o conseguiu atualizar os dados adicionais do cabe�alho.
								lError := .T.
								Self:setError(400, tcSQLError())
							EndIf
						Next nIndex
					EndIf

					If lError
						//Realiza rollback caso tenha ocorrido erro em algum registro.
						DisarmTransaction()
					EndIf
				END TRANSACTION
				//Ap�s gravar os dados, adiciona os arrays aError e aSuccess de todos os dados inclu�dos.
				nTotal := Len(aNames)
				For nIndex := 1 To nTotal
					nTotAux := Len(Self:oDadosInclui[aNames[nIndex]]["items"])
					For nIndAux := 1 To nTotAux
						If lError
							aAdd(Self:aError, {Self:oDadosInclui[aNames[nIndex]]["items"][nIndAux], Self:nStatus, Self:cMessage})
						Else
							aAdd(Self:aSuccess, Self:oDadosInclui[aNames[nIndex]]["items"][nIndAux])
						EndIf
					Next nIndAu
				Next nIndex

				aSize(aNames, 0)
			EndIf
		EndIf
	EndIf

	aSize(aSqlRun, 0)

	FreeObj(oCopyData)
	oCopyData := Nil
Return lRet



/*/{Protheus.doc} executaDelete
Executa o processamento do m�todo DELETE

@type  METHOD
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@return lRet, Logic, Identifica se o processamento foi executado com sucesso
/*/
Method executaDelete() CLASS MRPApi
	Local lRet      := .T.
	Local nIndex    := 0
	Local nTotal    := 0
	Local oCopyData := JsonObject():New()

	Self:defineTransaction()

	//Verifica se os dados de entrada s�o v�lidos
	lRet := Self:canProcReq()
	If lRet
		//Utiliza um objeto com c�pia dos dados para executar as valida��es.
		//Faz isso para n�o adicionar tags com valor null no JSON que ser� retornado.
		oCopyData:FromJson(Self:oBody:ToJson())
		//Processa os items
		nTotal := Len(Self:oBody["items"])
		For nIndex := 1 To nTotal
			lRet := Self:validaItem(Self:cMapCodePrincipal, oCopyData["items"][nIndex])
			If !lRet
				//Ocorreu erro de valida��o. N�o processa este item.
				aAdd(Self:aError, {Self:oBody["items"][nIndex], Self:nStatus, Self:cMessage})
			Else
				//Validou os dados, executa a exclus�o dos dados.
				If Self:lUsaTransaction
					BEGIN TRANSACTION
					lRet := Self:procDelete(Self:cMapCodePrincipal, Self:oBody["items"][nIndex], Nil)
					If !lRet
						DisarmTransaction()
					EndIf
					END TRANSACTION
				Else
					lRet := Self:procDelete(Self:cMapCodePrincipal, Self:oBody["items"][nIndex], Nil)
				EndIf
				If lRet
					aAdd(Self:aSuccess, Self:oBody["items"][nIndex])
				Else
					aAdd(Self:aError, {Self:oBody["items"][nIndex], Self:nStatus, Self:cMessage})
				EndIf
			EndIf
		Next nIndex
	EndIf
	FreeObj(oCopyData)
	oCopyData := Nil
Return lRet

/*/{Protheus.doc} procPost
Executa o processamento da atualiza��o dos dados.

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode , Character, C�digo do mapeamento que est� sendo processado.
@param oItem    , Object   , Objeto JSON do item que ser� processado.
@param oInfoPai , Object   , Objeto JSON com os dados de relacionamento do item PAI
@param lInclusao, Logic    , Enviar por refer�ncia. Retorna se o registro foi inclu�do ou atualizado.
@param lProcIns , Logic    , Indica se dever� executar o insert. Utilizado quando a entidade pai e filha inserem a mesma tabela.
@param aSqlRun  , Array    , Retorna por refer�ncia comandos SQL de atualiza��o que devem ser executados dentro da transa��o
@param lVldItems, Logic    , Indica que deve ser realizada valida��o antes da inclus�o de dados em Self:oDadosInclui[cMapCode]["items"] no m�todo adicionaArrayInclusao
@return lRet , Logic , Identifica se o processamento foi executado com sucesso
/*/
Method procPost(cMapCode, oItem, oInfoPai, lInclusao, lProcIns, aSqlRun, lVldItems) CLASS MRPApi
	Local aRelac     := {}
	Local aKeyFilho  := {}
	Local aKeySearch := {}
	Local cMapFilho  := ""
	Local lRet       := .T.
	Local lIncFilho  := .F.
	Local nIndex     := 0
	Local nIndAux    := 0
	Local nTotal     := 0
	Local nTotAux    := 0
	Local oInfo      := Nil

	If Self:oMapRel[cMapCode] != Nil
		aRelac := Self:oMapRel[cMapCode]
	EndIf

	//Verifica se existe uma lista filha que utiliza a mesma tabela do cabe�alho.
	//(Mestre/Detalhe com apenas 1 tabela)
	//Nesse caso, os dados ser�o inclusos somente pelo filho, copiando os dados do cabe�alho.
	nTotal := Len(aRelac)
	For nIndex := 1 To nTotal
		If Self:oApiMap[cMapCode]["alias"] == Self:oApiMap[aRelac[nIndex]["filho"]]["alias"]
			lIncFilho := .T.
			cMapFilho := aRelac[nIndex]["filho"]
			aKeyFilho := aRelac[nIndex]["relacionamento"]
			Exit
		EndIf
	Next nIndex

	If lIncFilho
		oInfo := Self:montaInfoPai(aKeyFilho, cMapCode, oItem, oInfoPai)

		//Carrega as informa��es adicionais do cabe�alho que devem ser
		//atualizadas.
		//A atualiza��o ocorre ap�s o insert/update de todos os dados filhos.
		Self:cargaCabUpdate(oInfo)

		nTotal := Len(oItem[cMapFilho])
		For nIndex := 1 To nTotal
			lRet := Self:procPost(cMapFilho, oItem[cMapFilho][nIndex], oInfo, @lInclusao, .F., @aSqlRun, .T.)
			If !lRet
				Exit
			EndIf
		Next nIndex

		If lRet                 .And. ; //Se est� com o processamento sem erros
		   Self:lUsaTransaction .And. ; //Se utiliza transa��o a cada item
		   !Self:lSync          .And. ; //Se n�o � uma Sincroniza��o
		   Self:oDadosInclui[cMapFilho] != Nil .And. Len(Self:oDadosInclui[cMapFilho]["dados"]) > 0 //Se existem dados para incluir
			lRet := Self:processaInclusao(cMapFilho)
		EndIf

		//Atualiza as demais informa��es que constam no cabe�alho,
		//mas que n�o fazem parte do relacionamento com os filhos
		//Utiliza o SQL montado no m�todo cargaCabUpdate
		If oInfo["SQLUpdateData"] != Nil
			If Self:lSync 
				aAdd(aSqlRun, oInfo["SQLUpdateData"])
			Else 
				If TcSqlExec(oInfo["SQLUpdateData"]) < 0
					//N�o conseguiu atualizar os dados adicionais do cabe�alho.
					lRet := .F.
					Self:setError(400, tcSQLError())
				EndIf
			EndIf
		EndIf
		FreeObj(oInfo)
		oInfo := Nil
	Else
		If Self:lSync
			//Na sincroniza��o, sempre inclui todos os registros.
			//N�o � necess�rio verificar se j� existe, pois no come�o da sincroniza��o
			//tudo � apagado.
			lRet := Self:adicionaArrayInclusao(cMapCode, oItem, oInfoPai, lVldItems)
			lInclusao := .T.
		Else
			//Carrega a chave de pesquisa do item, para verificar se existe registro no banco.
			aKeySearch := Self:getKeySearch(cMapCode, oItem, oInfoPai)
			If Len(aKeySearch) > 0
				nRecno := Self:buscaRegistro(cMapCode, aKeySearch)
				If nRecno > 0
					//Registro j� existe, executa a atualiza��o.
					lRet := Self:updateReg(nRecno, cMapCode, oItem)
					lInclusao := .F.
				Else
					//Registro ainda n�o existe, ir� fazer inclus�o.
					lRet := Self:adicionaArrayInclusao(cMapCode, oItem, oInfoPai, lVldItems)
					lInclusao := .T.
				EndIf
			Else
				lRet := .F.
				Self:setError(400, STR0004) //"N�o foi poss�vel identificar a chave de pesquisa do item em processamento."
			EndIf
		EndIf
	EndIf

	//Processa os itens filhos se houver
	If lRet .And. !lIncFilho
		nTotal := Len(aRelac)
		For nIndex := 1 To nTotal
			cMapFilho := aRelac[nIndex]["filho"]
			aKeyFilho := aRelac[nIndex]["relacionamento"]
			If oItem[cMapFilho] != Nil
				oInfo   := Self:montaInfoPai(aKeyFilho, cMapCode, oItem, oInfoPai)
				nTotAux := Len(oItem[cMapFilho])
				For nIndAux := 1 To nTotAux
					lRet := Self:procPost(cMapFilho, oItem[cMapFilho][nIndAux], oInfo, @lInclusao, .T., @aSqlRun, .F.)
				Next nIndAux
				FreeObj(oInfo)
				oInfo := Nil
			Else
				oItem[cMapFilho] := {}
			EndIf
			If !lRet
				Exit
			EndIf
		Next nIndex
	EndIf

	If lRet .And. !lIncFilho .And. ; //Se processou com sucesso e a inclus�o n�o � feita pelo filho
	   Self:lUsaTransaction  .And. ; //E se utiliza transa��o a cada item
	   !Self:lSync           .And. ; //E se n�o � uma sincroniza��o
	   lProcIns              .And. ; //E se deve executar a inclus�o nesta intera��o
	   Self:oDadosInclui[cMapCode] != Nil .And. Len(Self:oDadosInclui[cMapCode]["dados"]) > 0 //Se existem dados para incluir
		lRet := Self:processaInclusao(cMapCode)
	EndIf
Return lRet

/*/{Protheus.doc} procDelete
Executa o processamento da exclus�o dos dados.

@type  METHOD
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@param cMapCode , Character, C�digo do mapeamento que est� sendo processado.
@param oItem    , Object   , Objeto JSON do item que ser� processado.
@param oInfoPai , Object   , Objeto JSON com os dados de relacionamento do item PAI
@return lRet , Logic , Identifica se o processamento foi executado com sucesso
/*/
Method procDelete(cMapCode, oItem, oInfoPai) CLASS MRPApi
	Local aRelac     := {}
	Local aKeyFilho  := {}
	Local aKeySearch := {}
	Local cWhere     := ""
	Local cMapFilho  := ""
	Local lRet       := .T.
	Local nRecno     := 0
	Local nIndex     := 0
	Local nIndAux    := 0
	Local nTotal     := 0
	Local nTotAux    := 0
	Local oInfo      := Nil

	If Self:oMapRel[cMapCode] != Nil
		aRelac := Self:oMapRel[cMapCode]
	EndIf

	//Se o MAPCODE atual n�o � o MAPCODE que deve ser deletado,
	//percorre os itens filhos at� encontrar o que deve ser deletado.
	//Enquanto percorre os itens filhos, vai passando os valores de relacionamento entre as tabelas.
	If cMapCode != Self:cMapCodeDelete
		nTotal := Len(aRelac)
		For nIndex := 1 To nTotal
			cMapFilho := aRelac[nIndex]["filho"]
			aKeyFilho := aRelac[nIndex]["relacionamento"]
			If oItem[cMapFilho] != Nil
				oInfo   := Self:montaInfoPai(aKeyFilho, cMapCode, oItem, oInfoPai)
				nTotAux := Len(oItem[cMapFilho])
				For nIndAux := 1 To nTotAux
					lRet := Self:procDelete(cMapFilho, oItem[cMapFilho][nIndAux], oInfo)
					If !lRet
						Exit
					EndIf
				Next nIndAux
				FreeObj(oInfo)
				oInfo := Nil
			Else
				oItem[cMapFilho] := {}
			EndIf
			If !lRet
				Exit
			EndIf
		Next nIndex
	Else
		//Carrega a chave de pesquisa do item, para verificar se existe registro no banco.
		aKeySearch := Self:getKeySearch(cMapCode, oItem, oInfoPai)
		If Len(aKeySearch) > 0 .And. Len(Self:oKeySearch[cMapCode]) == Len(aKeySearch)
			nRecno := Self:buscaRegistro(cMapCode, aKeySearch, @cWhere)
			If nRecno > 0
				//Registro existe, executa a exclus�o dos filhos primeiro.
				lRet := Self:deletaFilhos(cMapCode, cWhere)
				//Se conseguiu excluir os filhos, executa a pr�pria exclus�o.
				If lRet
					lRet := Self:deleteReg(cWhere, Self:oApiMap[cMapCode]["tabela"])
				EndIf
			EndIf
		Else
			lRet := .F.
			Self:setError(400, STR0006) //"N�o foi poss�vel identificar a chave de pesquisa do item em processamento."
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} buscaRegistro
M�todo que monta a query para processar o GET

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode  , Character, C�digo do mapeamento setado.
@param aKeySearch, Array    , Array com os dados utilizados na busca.
@param cWhere    , Character, Vari�vel para recuperar o whereclause utilizado na query.
@return nRecno   , Numeric  , N�mero do RECNO do registro. Se n�o encontrar, retorna 0
/*/
Method buscaRegistro(cMapCode, aKeySearch, cWhere) CLASS MRPApi
	Local aValues := {}
	Local cAlias  := PCPAliasQr()
	Local cQuery  := ""
	Local nRecno  := 0
	Local nIndex  := 0
	Local nTotal  := 0
	Local oQuery  := Nil

	If Self:oApiMap[cMapCode]["oQuery"] == Nil
		//Ainda n�o montou query de pesquisa deste item.
		cQuery := " SELECT R_E_C_N_O_ REGISTRO "
		cQuery +=   " FROM " + Self:oApiMap[cMapCode]["tabela"]
		cQuery +=  " WHERE D_E_L_E_T_ = ' ' "

		nTotal := Len(aKeySearch)
		For nIndex := 1 To nTotal
			cQuery += " AND " + aKeySearch[nIndex][1] + " = ? "
		Next nIndex

		oQuery := FWPreparedStatement():New(cQuery)
		Self:oApiMap[cMapCode]["oQuery"] := oQuery
	Else
		//Recupera a query que j� foi montada
		oQuery := Self:oApiMap[cMapCode]["oQuery"]
	EndIf

	//Monta o array com os valores de filtro
	nTotal := Len(aKeySearch)
	For nIndex := 1 To nTotal
		aAdd(aValues, aKeySearch[nIndex][2])
	Next nIndex

	//Seta os valores de filtro na query
	oQuery:setParams(aValues)

	cQuery := oQuery:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
	If (cAlias)->(!Eof())
		nRecno := (cAlias)->(REGISTRO)
	EndIf
	(cAlias)->(dbCloseArea())

	cWhere := SubStr(cQuery, At("WHERE", cQuery))

Return nRecno

/*/{Protheus.doc} updateReg
Executa o UPDATE para atualizar um registro.

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param nRecno    , Numeric , RECNO do registro que ser� atualizado.
@param cMapCode  , Caracter, C�digo do mapeamento setado.
@param oItem     , Object  , Objeto JSON com os dados que ser�o atualizados.
@return lRet     , Logic   , Idetifica se a atualiza��o foi executada.
/*/
Method updateReg(nRecno, cMapCode, oItem) CLASS MRPApi
	Local aMap       := aClone(Self:oApiMap[cMapCode]["map"])
	Local aKeySearch := Self:oKeySearch[cMapCode]
	Local cAlias     := Self:oApiMap[cMapCode]["alias"]
	Local nIndex     := 0
	Local nTotal     := 0
	Local nPos       := 0
	Local lRet       := .T.

	//Remove os campos de chave �nica do array aMap, para que estes campos n�o sejam atualizados
	nTotal := Len(aKeySearch)
	For nIndex := 1 To nTotal
		nPos := Self:oApiMap[cMapCode]["aliasColumns"][aKeySearch[nIndex]]
		If nPos != Nil .And. nPos > 0
			aMap[nPos] := Nil
		EndIf
	Next nIndex
	//Posiciona o registro
	(cAlias)->(dbGoTo(nRecno))

	If (cAlias)->(!Eof())
		nTotal := Len(aMap)

		//Atualiza os dados
		RecLock(cAlias, .F.)
		For nIndex := 1 To nTotal
			If aMap[nIndex] == Nil
				//Campos que pertencem a chave e foram removidos. Pula para o pr�ximo campo
				Loop
			EndIf
			If oItem[aMap[nIndex][1]] == Nil
				//Campo n�o foi informado. Pula para o pr�ximo

				//Adiciona no JSON os valores que est�o na tabela, para retornar na resposta da requisi��o.
				oItem[aMap[nIndex][1]] := Self:formatDado(aMap[nIndex][3], &(cAlias+"->"+aMap[nIndex][2]),"2", aMap[nIndex][4])
				Loop
			EndIf
			&(cAlias+"->"+aMap[nIndex][2]) := Self:formatDado(aMap[nIndex][3], oItem[aMap[nIndex][1]], "1", aMap[nIndex][4])
		Next nIndex
		(cAlias)->(MsUnLock())
	Else
		lRet := .F.
		Self:setError(400, STR0007) //"Falha ao posicionar no registro para atualiza��o."
	EndIf

Return lRet

/*/{Protheus.doc} deletaFilhos
Executa o DELETE dos filhos de determinado registro

@type  METHOD
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@param cMapCode  , Character, C�digo do mapeamento em processamento.
@param aKeySearch, Array    , Array com as informa��es de relacionamento entre o pai e o filho.
@param cWhere    , Character, WHERE CLAUSE que deve ser utilizado na dele��o.
@return lRet     , Logic    , Idetifica se a exclus�o foi executada.
/*/
Method deletaFilhos(cMapCode, cWhere) CLASS MRPApi
	Local aRelac     := {}
	Local cAlias     := ""
	Local cQuery     := ""
	Local cWhereAtu  := ""
	Local cFilho     := ""
	Local cTabFilho  := ""
	Local nIndex     := 0
	Local nTotal     := 0
	Local nIndAux    := 0
	Local nTotAux    := 0
	Local lRet       := .T.

	If Self:oMapRel[cMapCode] != Nil
		aRelac := Self:oMapRel[cMapCode]
		nTotal := Len(aRelac)
	EndIf

	For nIndex := 1 To nTotal
		cFilho    := aRelac[nIndex]["filho"]
		cTabFilho := Self:oApiMap[cFilho]["tabela"]

		If cTabFilho == Self:oApiMap[cMapCode]["tabela"]
			//Se a tabela do pai � a mesma do filho, as opera��es s�o feitas no item filho.
			lRet := Self:deletaFilhos(cFilho, cWhere)
		Else
			cQuery := " SELECT " + cTabFilho +".R_E_C_N_O_ REC "
			cQuery += " FROM " + cTabFilho + " "
			cWhereAtu := " WHERE " + cTabFilho + ".D_E_L_E_T_ = ' ' "
			cWhereAtu += " AND EXISTS ( SELECT 1 "
			cWhereAtu +=                " FROM " + Self:oApiMap[cMapCode]["tabela"] + " "
			cWhereAtu += cWhere

			nTotAux := Len(aRelac[nIndex]["relacionamento"])
			For nIndAux := 1 To nTotAux
				cWhereAtu += " AND " + cTabFilho + "." + aRelac[nIndex]["relacionamento"][nIndAux][2]
				cWhereAtu += " = " + Self:oApiMap[cMapCode]["tabela"] + "." + aRelac[nIndex]["relacionamento"][nIndAux][1]
			Next nIndAux
			cWhereAtu += " ) "
			cQuery += cWhereAtu

			cAlias := PCPAliasQr()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
			If (cAlias)->(!Eof())
				//Chama esta fun��o de forma recursiva, para verificar se este filho possui outros filhos
				//Sempre faz a exclus�o dos filhos primeiro e depois de seus pais.
				lRet := Self:deletaFilhos(cFilho, cWhereAtu)
				//Excluiu todos os filhos. Agora exclui o registro pai.
				If lRet
					lRet := Self:deleteReg(cWhereAtu, Self:oApiMap[cFilho]["tabela"])
				EndIf
			EndIf
			(cAlias)->(dbCloseArea())
		EndIf
	Next nIndex
Return lRet

/*/{Protheus.doc} deleteReg
Executa o DELETE de um registro espec�fico

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cWhere , Character, WHERE CLAUSE que deve ser utilizado na dele��o. Obter atrav�s do m�todo buscaRegistro
@param cTabela, Character, Tabela que ir� ter os dados exclu�dos
@return lRet  , Logic    , Idetifica se a exclus�o foi executada.
/*/
Method deleteReg(cWhere, cTabela) CLASS MRPApi
	Local cDelete := ""
	Local lRet    := .T.

	If Empty(cWhere)
		lRet := .F.
		Self:setError(400, STR0008) //"N�o � poss�vel excluir todos os dados da tabela."
	Else
		cDelete := " DELETE FROM " + cTabela + " " + cWhere
		If TcSqlExec(cDelete) < 0
			lRet := .F.
			Self:setError(400, tcSQLError())
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} adicionaArrayInclusao
Adiciona os itens que devem ser inclu�dos no objeto Self:oDadosInclui, para executar a inclus�o em lote.

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode  , Character, C�digo do mapeamento setado.
@param oItem     , Object   , Objeto JSON com os dados que ser�o atualizados.
@param oInfoPai  , Object   , Objeto JSON com os dados de relacionamento do item PAI
@param lVldItems, Logic    , Indica que deve ser realizada valida��o antes da inclus�o de dados em Self:oDadosInclui[cMapCode]["items"]
@return lRet     , Logic    , Idetifica se a atualiza��o foi executada.
/*/
Method adicionaArrayInclusao(cMapCode, oItem, oInfoPai, lVldItems) CLASS MRPApi
	Local aNames    := {}
	Local aMapPai   := {}
	Local cName     := ""
	Local cMapPai   := ""
	Local lRet      := .T.
	Local nIndex    := 0
	Local nIndDados := 0
	Local nTotal    := 0
	Local nPos      := 0
	Local nPosPai   := 0
	Local nSize     := 0
	Local xValue    := Nil

	If oInfoPai != Nil
		aNames := oInfoPai["valores"]:GetNames()
	EndIf
	nSize := Len(aNames)
	If nSize > 0
		nTotal := nSize
		For nIndex := 1 To nTotal
			If oInfoPai["valores"][aNames[nIndex]] == Nil
				nSize--
			EndIf
		Next nIndex
	EndIf
	nSize += Len(Self:oApiMap[cMapCode]["map"])

	If Self:oDadosInclui[cMapCode] == Nil
		Self:oDadosInclui[cMapCode] := JsonObject():New()
	EndIf

	If Self:oDadosInclui[cMapCode]["items"] == Nil
		Self:oDadosInclui[cMapCode]["items"] := {}
	EndIf

	If Self:oDadosInclui[cMapCode]["dados"] == Nil
		Self:oDadosInclui[cMapCode]["dados"] := {}
	EndIf

	aAdd(Self:oDadosInclui[cMapCode]["dados"], Array(nSize))
	nPos := Len(Self:oDadosInclui[cMapCode]["dados"])

	nIndDados := 0

	nTotal := Len(aNames)
	If nTotal > 0
		For nIndex := 1 To nTotal
			If oInfoPai["valores"][aNames[nIndex]] == Nil
				Loop
			EndIf
			nIndDados++
			xValue  := oInfoPai["valores"][aNames[nIndex]]

			cMapPai := oInfoPai["mapCodePai"]
			nPosPai := Self:oApiMap[cMapPai]["aliasColumns"][aNames[nIndex]]
			If nPosPai != Nil
				aMapPai := Self:oApiMap[cMapPai]["map"][nPosPai]
				Self:oDadosInclui[cMapCode]["dados"][nPos][nIndDados] := Self:formatDado(aMapPai[3], xValue, "1", aMapPai[4])
			Else
				//Se � um campo que j� veio de um PAI, n�o precisa fazer o formatDado novamente.
				Self:oDadosInclui[cMapCode]["dados"][nPos][nIndDados] := xValue
			EndIf
		Next nIndex
	EndIf

	nTotal := Len(Self:oApiMap[cMapCode]["map"])
	For nIndex := 1 To nTotal
		cName := Self:oApiMap[cMapCode]["map"][nIndex][1]
		If oItem[cName] == Nil .And. Self:oValorDefault[cMapCode] != Nil
			If Self:oValorDefault[cMapCode][cName] != Nil
				oItem[cName] := Self:oValorDefault[cMapCode][cName]
			EndIf
		EndIf

		nIndDados++
		If oItem[cName] != Nil
			Self:oDadosInclui[cMapCode]["dados"][nPos][nIndDados] := Self:formatDado(Self:oApiMap[cMapCode]["map"][nIndex][3], oItem[cName], "1", Self:oApiMap[cMapCode]["map"][nIndex][4])
		ElseIf Self:oApiMap[cMapCode]["map"][nIndex][3] == "N"
			Self:oDadosInclui[cMapCode]["dados"][nPos][nIndDados] := 0
			oItem[cName] := 0
		ElseIf Self:oApiMap[cMapCode]["map"][nIndex][3] == "C"
			Self:oDadosInclui[cMapCode]["dados"][nPos][nIndDados] := Space(Self:oApiMap[cMapCode]["map"][nIndex][4])
			oItem[cName] := ""
		ElseIf Self:oApiMap[cMapCode]["map"][nIndex][3] == "D"
			Self:oDadosInclui[cMapCode]["dados"][nPos][nIndDados] := Space(8)
		Else
			Self:oDadosInclui[cMapCode]["dados"][nPos][nIndDados] := Nil
		EndIf
	Next nIndex

	Self:oDadosInclui[cMapCode]["pai"] := oInfoPai
	If oInfoPai != Nil .And. oInfoPai["referenciaPai"] != Nil
		//Quando possui registros PAI/FILHO, somente adiciona nos items a informa��o do JSON Pai que j� contem todos os filhos.
		If lVldItems .And. oInfoPai["mapCodePai"] == Self:cMapCodePrincipal .And. ! Self:regPaiIncluido(oInfoPai)
			aAdd(Self:oDadosInclui[cMapCode]["items"], oInfoPai["referenciaPai"])
		EndIf
	Else
		aAdd(Self:oDadosInclui[cMapCode]["items"], oItem)
	EndIf
Return lRet

/*/{Protheus.doc} processaInclusao
Faz o processamento da inclus�o dos dados contidos no Self:oDadosInclui

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode  , Caracter, C�digo do mapeamento setado.
@return lRet     , Logic   , Idetifica se a atualiza��o foi executada.
/*/
Method processaInclusao(cMapCode) CLASS MRPApi
	Local aNames  := {}
	Local cCols   := ""
	Local cTabela := Self:oApiMap[cMapCode]["tabela"]
	Local nIndex  := 0
	Local nTotal  := 0
	Local lFirst  := .T.
	Local lRet    := .T.

	If Self:oDadosInclui[cMapCode]["pai"] != Nil
		//Adiciona os campos do pai, referente as colunas de relacionamento
		aNames := Self:oDadosInclui[cMapCode]["pai"]["valores"]:GetNames()
		nTotal := Len(aNames)
		For nIndex := 1 To nTotal
			If Self:oDadosInclui[cMapCode]["pai"]["valores"][aNames[nIndex]] == Nil
				Loop
			EndIf
			If !lFirst
				cCols += ","
			EndIf
			lFirst := .F.
			cCols += aNames[nIndex]
		Next nIndex
	EndIf

	//Adiciona as colunas que ser�o inclu�das
	nTotal := Len(Self:oApiMap[cMapCode]["map"])
	For nIndex := 1 To nTotal
		If !lFirst
			cCols += ","
		EndIf
		lFirst := .F.
		cCols += Self:oApiMap[cMapCode]["map"][nIndex][2]
	Next nIndex

	If lRet
		//Executa o INSERT dos dados em bloco.
		If TCDBInsert(cTabela,cCols,Self:oDadosInclui[cMapCode]["dados"]) < 0
			lRet := .F.
			Self:setError(400, tcSQLError())
		EndIf
	EndIf
	aSize(Self:oDadosInclui[cMapCode]["dados"],0)
Return lRet

/*/{Protheus.doc} cargaCabUpdate
Carrega quais campos do cabe�alho devem ser atualizados ap�s a inclus�o dos itens filhos.
(Utilizado somente quando o cadastro � do tipo Mestre/Detalhe com apenas uma tabela.)

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param oInfoCab, Object, Objeto JSON com as informa��es do cabe�alho.
@return Nil
/*/
Method cargaCabUpdate(oInfoCab) CLASS MRPApi
	Local aMap     := {}
	Local aNames   := {}
	Local aUpdFlds := {}
	Local cAlias   := ""
	Local cQuery   := ""
	Local cWhere   := ""
	Local cTipo    := ""
	Local cUpdate  := ""
	Local nIndex   := 0
	Local nTotal   := 0
	Local nIndAux  := 0
	Local nTotAux  := 0
	Local lFirst   := .T.
	Local oCab     := JsonObject():New()
	Local xValue   := Nil

	//Faz uma c�pia do JSON recebido por par�metro, para que
	//durante as verifica��es feitas nesta fun��o o objeto original
	//n�o seja alterado.
	oCab:FromJson(oInfoCab:ToJson())

	aMap   := Self:oApiMap[oCab["mapCodePai"]]["map"]
	nTotal := Len(aMap)

	//Verifica se existe algum campo do mapeamento do cabe�alho que n�o ser� inclu�do junto com os filhos.
	For nIndex := 1 To nTotal
		If oCab["valores"][aMap[nIndex][2]] == Nil
			//Se encontrou um campo que n�o ser� atualizado automaticamente
			//na inclus�o/atualiza��o dos filhos, verifica se recebeu a informa��o
			//na requisi��o.
			xValue := oCab["referenciaPai"][aMap[nIndex][1]]
			If xValue == Nil
				//N�o recebeu a informa��o.
				//Verifica se j� existem registros no banco com esta informa��o, para assumir o mesmo valor.
				cQuery := " SELECT DISTINCT " + aMap[nIndex][2] + " VALATU "
				cQuery += " FROM " + Self:oApiMap[oCab["mapCodePai"]]["tabela"]
				If Empty(cWhere)
					cWhere += " WHERE D_E_L_E_T_ = ' ' "
					aNames := oInfoCab["valores"]:GetNames()
					nTotAux := Len(aNames)
					For nIndAux := 1 To nTotAux
						cTipo := ValType(oInfoCab["valores"][aNames[nIndAux]])
						cWhere += " AND " + aNames[nIndAux] + " = "
						If cTipo == "C"
							cWhere += "'" + oInfoCab["valores"][aNames[nIndAux]] + "'"
						ElseIf cTipo == "N"
							cWhere += cValToChar(oInfoCab["valores"][aNames[nIndAux]])
						ElseIf cTipo == "D"
							cWhere += "'" + DtoS(oInfoCab["valores"][aNames[nIndAux]]) + "'"
						Else
							cWhere += "'" + AllToChar(oInfoCab["valores"][aNames[nIndAux]]) + "'"
						EndIf
					Next nIndAux
				EndIf
				cQuery += cWhere
				cAlias := PCPAliasQr()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
				If (cAlias)->(!Eof())
					xValue := (cAlias)->(VALATU)
				Else
					If Self:oValorDefault[oCab["mapCodePai"]][aMap[nIndex][1]] != Nil
						xValue := Self:oValorDefault[oCab["mapCodePai"]][aMap[nIndex][1]]
					EndIf
				EndIf
				(cAlias)->(dbCloseArea())
			EndIf

			//Ou a informa��o foi enviada na requisi��o,
			//Ou encontrou registros j� populados com esta informa��o
			//Ou pegou valor padr�o para esta informa��o.
			//Em qualquer um dos casos acima, ir� atualizar todos os registros
			//relacionados com o mesmo dado.
			If xValue != Nil
				oInfoCab["referenciaPai"][aMap[nIndex][1]] := xValue
				aAdd(aUpdFlds, {xValue, nIndex})
			EndIf
		EndIf
	Next nIndex

	nTotal := Len(aUpdFlds)
	If nTotal > 0
		//Existem dados para atualizar. Monta a query de update
		//que ser� executada posteriormente.
		cUpdate := " UPDATE " + Self:oApiMap[oCab["mapCodePai"]]["tabela"]
		cUpdate += " SET "
		For nIndex := 1 To nTotal
			If !lFirst
				cUpdate += ","
			EndIf
			lFirst := .F.
			cUpdate += aMap[aUpdFlds[nIndex][2]][2] + " = "
			If aMap[aUpdFlds[nIndex][2]][3] == "C"
				cUpdate += "'" + aUpdFlds[nIndex][1] + "'"
			ElseIf aMap[aUpdFlds[nIndex][2]][3] == "N"
				cUpdate += cValToChar(aUpdFlds[nIndex][1])
			ElseIf aMap[aUpdFlds[nIndex][2]][3] == "D"
				cUpdate += "'" + DtoS(aUpdFlds[nIndex][1]) + "'"
			Else
				cUpdate += "'" + AllToChar(aUpdFlds[nIndex][1]) + "'"
			EndIf
		Next nIndex

		If Empty(cWhere)
			cWhere += " WHERE D_E_L_E_T_ = ' ' "
			aNames := oInfoCab["valores"]:GetNames()
			nTotAux := Len(aNames)
			For nIndAux := 1 To nTotAux
				cTipo := ValType(oInfoCab["valores"][aNames[nIndAux]])
				cWhere += " AND " + aNames[nIndAux] + " = "
				If cTipo == "C"
					cWhere += "'" + oInfoCab["valores"][aNames[nIndAux]] + "'"
				ElseIf cTipo == "N"
					cWhere += cValToChar(oInfoCab["valores"][aNames[nIndAux]])
				ElseIf cTipo == "D"
					cWhere += "'" + DtoS(oInfoCab["valores"][aNames[nIndAux]]) + "'"
				Else
					cWhere += "'" + AllToChar(oInfoCab["valores"][aNames[nIndAux]]) + "'"
				EndIf
			Next nIndAux
		EndIf
		cUpdate += cWhere
		//Adiciona o comando update nas informa��es do pai
		oInfoCab["SQLUpdateData"] := cUpdate
	EndIf

	//Tira o objeto tempor�rio da mem�ria
	FreeObj(oCab)
	oCab := Nil
Return Nil

/*/{Protheus.doc} canProcReq
Valida se a requisi��o poder� ser processada ou n�o.

@type  Method
@author lucas.franca
@since 21/05/2019
@version P12.1.27
@return lRet, Logic, Indica se a requisi��o poder� ser processada.
/*/
Method canProcReq() CLASS MRPApi
	Local lRet := .T.

	If Self:oBody == Nil
		lRet := .F.
		Self:setError(400, STR0010) //"Par�metros n�o recebidos para processar (oBody)."
	EndIf

	If !Self:lSync
		If lRet .And. Self:oBody["items"] == Nil
			lRet := .F.
			Self:setError(400, STR0011 + " 'items' " + STR0012) //"Atributo 'XXX' "n�o recebido na requisi��o."
		EndIf

		If lRet .And. ValType(Self:oBody["items"]) != "A"
			lRet := .F.
			Self:setError(400, STR0011 + " 'items' " + STR0013) //"Atributo 'XXX' "enviado em formato incorreto."
		EndIf

		If lRet .And. Len(Self:oBody["items"]) < 1
			lRet := .F.
			Self:setError(400, STR0011 + " 'items' " + STR0014) //"Atributo 'XXX' enviado sem nenhum dado para processar."
		EndIf
	EndIf

	Self:lValidouRequisicao := lRet
Return lRet

/*/{Protheus.doc} validaItem
Executa as valida��es do item que ser� processado

@type  Method
@author lucas.franca
@since 21/05/2019
@version P12.1.27
@param cMapCode, Character, C�digo do mapeamento que ser� validado
@param oItem   , Numeric  , Item que ser� processado.
@return lRet, Logic, Indica se o item poder� ser processado.
/*/
Method validaItem(cMapCode, oItem, oPai) CLASS MRPApi
	Local aRelac    := {}
	Local nIndex    := 0
	Local nIndexAux := 0
	Local nTotal    := 0
	Local nTotalAux := 0
	Local lRet      := .T.
	Local lVldFilho := .T.

	If Self:cMethod == "DELETE"
		If Self:cMapCodeDelete == cMapCode
			//Se este � o item que ser� exclu�do, n�o � necess�rio validar os seus filhos.
			lVldFilho := .F.
		EndIf
	EndIf

	If Self:oMapRel[cMapCode] != Nil .And. lVldFilho
		aRelac := Self:oMapRel[cMapCode]
		nTotal := Len(aRelac)
		//Dispara a valida��o dos mapeamentos filhos (listas)
		For nIndex := 1 To nTotal
			//Se o filho � de preenchimento obrigat�rio e n�o foi enviado. retorna erro.
			If aRelac[nIndex]["obrigatorio"] .And. oItem[aRelac[nIndex]["filho"]] == Nil
				lRet := .F.
				Self:setError(400, STR0011 + " '"+aRelac[nIndex]["filho"]+"' " + STR0012) //"Atributo 'XXX' n�o recebido na requisi��o."
				Exit
			EndIf
			If oItem[aRelac[nIndex]["filho"]] != Nil
				If lRet .And. ValType(oItem[aRelac[nIndex]["filho"]]) != "A"
					lRet := .F.
					Self:setError(400, STR0011 + " '"+aRelac[nIndex]["filho"]+"' " + STR0013) //"Atributo 'XXX' enviado em formato incorreto."
					Exit
				EndIf
				nTotalAux := Len(oItem[aRelac[nIndex]["filho"]])
				If aRelac[nIndex]["obrigatorio"] .And. nTotalAux < 1
					lRet := .F.
					Self:setError(400, STR0011 + " '"+aRelac[nIndex]["filho"]+"' " + STR0014) //"Atributo 'XXX' enviado sem nenhum dado para processar."
				EndIf
				If nTotalAux > 0
					For nIndexAux := 1 To nTotalAux
						lRet := Self:validaItem(aRelac[nIndex]["filho"], oItem[aRelac[nIndex]["filho"]][nIndexAux], oItem)
						If !lRet //Sai do for nIndexAux
							Exit
						EndIf
					Next nIndexAux
					If !lRet // sai do For nIndex
						Exit
					EndIf
				EndIf
			EndIf
		Next nIndex
	EndIf

	//Executa fun��o para valida��es espec�ficas.
	If lRet .And. !Empty(Self:oValid[cMapCode])
		lRet := &(Self:oValid[cMapCode] + "(Self, cMapCode, oItem, oPai)")
	EndIf

	//Valida se o tamanho das informa��es est�o de acordo com o limite de cada campo
	If lRet
		lRet := Self:validaTamanhos(cMapCode, oItem)
	EndIf

Return lRet

/*/{Protheus.doc} validaTamanhos
Valida se os tamanhos das informa��es do item est�o corretas

@type  Method
@author lucas.franca
@since 21/05/2019
@version P12.1.27
@param cMapCode, Character, C�digo do mapeamento que ser� validado
@param oItem   , Numeric  , Item que ser� processado.
@return lRet, Logic, Indica se o item poder� ser processado.
/*/
Method validaTamanhos(cMapCode, oItem) CLASS MRPApi
	Local aMapFld := Self:oApiMap[cMapCode]["map"]
	Local aValue  := {}
	Local cMaxVal := ""
	Local nIndex  := 0
	Local nIndAux := 0
	Local nTotal  := Len(aMapFld)
	Local lRet    := .T.

	For nIndex := 1 To nTotal
		If oItem[aMapFld[nIndex][1]] == Nil
			Loop
		EndIf
		If aMapFld[nIndex][3] == "C"
			oItem[aMapFld[nIndex][1]] := RTrim(oItem[aMapFld[nIndex][1]])
			If Len(oItem[aMapFld[nIndex][1]]) > aMapFld[nIndex][4]
				lRet := .F.
				Self:setError(400, STR0011 + " '" + aMapFld[nIndex][1] + "' " + STR0015) //"Atributo 'XXX' possui dados com tamanho acima do m�ximo suportado."
			EndIf
		ElseIf aMapFld[nIndex][3] == "N"
			//Valida a quantidade decimal
			If aMapFld[nIndex][5] > 0
				aValue := StrTokArr(cValToChar(oItem[aMapFld[nIndex][1]]),".")
				If Len(aValue) > 1 .And. Len(aValue[2]) > aMapFld[nIndex][5]
					lRet := .F.
					Self:setError(400, STR0011 + " '" + aMapFld[nIndex][1] + "' " + STR0015) //"Atributo 'XXX' possui dados com tamanho acima do m�ximo suportado."
					Exit
				EndIf
			EndIf

			//Valida a quantidade inteira.
			cMaxVal := ""
			//Tamanho da parte inteira �: Tamanho total do campo - tamanho de decimais - 1. -1 � pq o ponto � considerado no tamanho do campo.
			For nIndAux := 1 To (aMapFld[nIndex][4]-aMapFld[nIndex][5]) - (If(aMapFld[nIndex][5] > 0, 1, 0))
				cMaxVal += "9"
			Next nIndAux
			If Int(oItem[aMapFld[nIndex][1]]) > Val(cMaxVal)
				lRet := .F.
				Self:setError(400, STR0011 + " '" + aMapFld[nIndex][1] + "' " + STR0015) //"Atributo 'XXX' possui dados com tamanho acima do m�ximo suportado."
				Exit
			EndIf
		ElseIf aMapFld[nIndex][3] == "D"
			If oItem[aMapFld[nIndex][1]] != Nil .And. !Empty(oItem[aMapFld[nIndex][1]])
				If Empty(StoD(getDate(oItem[aMapFld[nIndex][1]])))
					lRet := .F.
					Self:setError(400, STR0011 + " '" + aMapFld[nIndex][1] + "' " + STR0013) //"Atributo 'XXX' enviado em formato incorreto
				EndIf
			EndIf
		ElseIf aMapFld[nIndex][3] == "L"
			If ValType(oItem[aMapFld[nIndex][1]]) != "L"
				lRet := .F.
				Self:setError(400, STR0011 + " '" + aMapFld[nIndex][1] + "' " + STR0013) //"Atributo 'XXX' enviado em formato incorreto
			EndIf
		EndIf
		If !lRet
			Exit
		EndIf
	Next nIndex

Return lRet

/*/{Protheus.doc} montaQuery
M�todo que monta a query para processar o GET

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cMapCode, Caracter, C�digo do mapeamento setado.
@param aFilters , Array   , Filtros que ser�o adicionados na query. Usado para buscar registros filhos.
@param aNomRelac, Array   , Nomes referentes aos filtros que ser�o adicionados naquery. Usado para buscar do registro pai.
@return oQuery , Object  , Objeto representando a query.
/*/
Method montaQuery(cMapCode, aFilters, aNomRelac) CLASS MRPApi
	Local aRelac    := {}
	Local aOrder    := {}
	Local cFilName  := ""
	Local cQuery    := ""
	Local cColuna   := ""
	Local cAlias    := ""
	Local cTipo     := ""
	Local cOrderBy  := ""
	Local nPos      := 0
	Local nIndex    := 0
	Local nIndexAux := 0
	Local nTotal    := 0
	Local nTotalAux := 0
	Local nIndRelac := 0
	Local lAddOrder := .F.
	Local oQuery    := Nil

	Default aNomRelac := {}

	If Self:oMapRel[cMapCode] != Nil
		aRelac := Self:oMapRel[cMapCode]
	EndIf

	If Left(Self:oApiMap[cMapCode]["alias"], 1) == "S"
		cFilName := Right(Self:oApiMap[cMapCode]["alias"],2) + "_FILIAL"
	Else
		cFilName := Self:oApiMap[cMapCode]["alias"] + "_FILIAL"
	EndIf

	//Monta a query que ser� executada
	cQuery := " SELECT "
	If Self:oApiMap[cMapCode]["distinct"] .Or. Len(aRelac) > 0
		cQuery += " DISTINCT "
	EndIf

	//Se n�o existe o campo FILIAL no MAP da api, adiciona na query.
	If Self:oApiMap[cMapCode]["aliasColumns"][Upper(cFilName)] == Nil
		cQuery += cMapCode + "." + cFilName + ","
	EndIf

	//Adiciona os campos definidos no mapeamento
	nTotal := Len(Self:oApiMap[cMapCode]["map"])
	For nIndex := 1 To nTotal
		If nIndex > 1
			cQuery += ","
		EndIf
		cQuery += cMapCode + "." + Self:oApiMap[cMapCode]["map"][nIndex][2]
	Next nIndex

	//Adiciona coluna para identificar se existe registros filhos.
	nTotal := Len(aRelac)
	For nIndex := 1 To nTotal
		nIndRelac := 0
		//Procura um campo de relacionamento que n�o seja a filial.
		While nIndRelac < Len(aRelac[nIndex]["relacionamento"])
			nIndRelac++
			If !("_FILIAL" $ aRelac[nIndex]["relacionamento"][nIndRelac][2])
				Exit
			EndIf
		End
		If nIndRelac > Len(aRelac[nIndex]["relacionamento"]) .Or. nIndRelac < 1
			nIndRelac := Len(aRelac[nIndex]["relacionamento"])
		EndIf
		cQuery += "," + aRelac[nIndex]["filho"] + "." + aRelac[nIndex]["relacionamento"][nIndRelac][2] + " relac" + cValToChar(nIndex)
	Next nIndex

	cQuery +=  " FROM " + Self:oApiMap[cMapCode]["tabela"] + " " + cMapCode

	//Adiciona as tabelas de relacionamento
	nTotal    := Len(aRelac)
	nTotalAux := Len(Self:aQryParams)

	For nIndex := 1 To nTotal
		If aRelac[nIndex]["obrigatorio"]
			cQuery += " INNER "
		Else
			cQuery += " LEFT "
		EndIf
		cQuery += " JOIN " + Self:oApiMap[aRelac[nIndex]["filho"]]["tabela"] + " " + aRelac[nIndex]["filho"]
		nTotalAux := Len(aRelac[nIndex]["relacionamento"])
		cQuery += " ON " + aRelac[nIndex]["filho"] + ".D_E_L_E_T_ = ' ' "
		For nIndexAux := 1 To nTotalAux
			cQuery += " AND "
			cQuery += cMapCode + "." + aRelac[nIndex]["relacionamento"][nIndexAux][1] +;
			         " = " + aRelac[nIndex]["filho"] + "." + aRelac[nIndex]["relacionamento"][nIndexAux][2]
		Next nIndexAux
	Next nIndex

	cQuery += " WHERE " + cMapCode + ".D_E_L_E_T_ = ' ' "

	nTotal := Len(Self:aQryParams)
	For nIndex := 1 To nTotal
		If "|"+Upper(Self:aQryParams[nIndex][1])+"|" $ "|PAGE|PAGESIZE|ORDER|FIELDS|"
			Loop
		EndIf

		//Verifica se o campo pertence ao mapeamento que est� sendo executado
		nPos := Self:oApiMap[cMapCode]["apiFields"][Upper(Self:aQryParams[nIndex][1])]
		If nPos == Nil
			//Verifica se o campo pertence a algum mapeamento filho
			nTotalAux := Len(aRelac)
			For nIndexAux := 1 To nTotalAux
				nPos := Self:oApiMap[aRelac[nIndexAux]["filho"]]["apiFields"][Upper(Self:aQryParams[nIndex][1])]
				If nPos != Nil .And. nPos > 0
					cAlias  := aRelac[nIndexAux]["filho"]
					cColuna := Self:oApiMap[aRelac[nIndexAux]["filho"]]["map"][nPos][2]
					cTipo   := Self:oApiMap[aRelac[nIndexAux]["filho"]]["map"][nPos][3]
				EndIf
			Next nIndexAux
		Else
			cAlias  := cMapCode
			cColuna := Self:oApiMap[cMapCode]["map"][nPos][2]
			cTipo   := Self:oApiMap[cMapCode]["map"][nPos][3]
		EndIf
		If nPos != Nil .And. nPos > 0
			If Left(Self:aQryParams[nIndex][2], 4) == ".IN."
				Self:aQryParams[nIndex][2] := StrTran(Self:aQryParams[nIndex][2], '.IN.', '')
				::montaCampoQuery("IN", @cQuery, cAlias, cColuna, cTipo, Self:aQryParams[nIndex][2])
			Else
				::montaCampoQuery("AND", @cQuery, cAlias, cColuna, cTipo, Self:aQryParams[nIndex][2])
			EndIf
		Else
			nPos := aScan(aNomRelac, {|x| Upper(x) == Upper(Self:aQryParams[nIndex][1]) })
			If nPos <= 0
				Return oQuery
			EndIf
		EndIf
	Next nIndex

	If aFilters != Nil
		nTotal := Len(aFilters)
		For nIndex := 1 To Len(aFilters)
			cQuery += " AND " + cMapCode + "." + aFilters[nIndex][2] + " = ?"
		Next nIndex
	EndIf

	If Empty(Self:oApiMap[cMapCode]["order"])
		If Self:oKeySearch[cMapCode] != Nil
			cQuery += " ORDER BY "
			nTotal := Len(Self:oKeySearch[cMapCode])

			For nIndex := 1 To nTotal
				If nIndex > 1
					cQuery += ","
				EndIf
				cQuery += Self:oKeySearch[cMapCode][nIndex]
			Next nIndex
		EndIf
	Else
		aOrder := Self:oApiMap[cMapCode]["order"]
		nTotal := Len(aOrder)
		If nTotal > 0
			cOrderBy := " ORDER BY "
		EndIf
		lAddOrder := .F.
		For nIndex := 1 To nTotal
			nPos := Self:oApiMap[cMapCode]["apiFields"][Upper(aOrder[nIndex][1])]
			If nPos != Nil .And. nPos > 0
				If lAddOrder
					cOrderBy += ", "
				EndIf
				lAddOrder := .T.
				cOrderBy += Self:oApiMap[cMapCode]["map"][nPos][2] + " "+aOrder[nIndex][2]
			EndIf
		Next nIndex
		If lAddOrder
			cQuery += cOrderBy
		EndIf
	EndIf

	oQuery := FWPreparedStatement():New(cQuery)

	Self:oApiMap[cMapCode]["oQuery"] := oQuery

Return oQuery

/*/{Protheus.doc} montaCampoQuery
Concatena os dados do campo na montagem da montaQuery

@type  METHOD
@author brunno.costa
@since 27/12/2019
@version P12.1.27
@param cOperacao, caracter, indica a operacao:
                            AND - padr�o da monta query para adicionar novos campos com condi��o AND
							FORMATA_CAMPO - Chamada v�rias vezes nas formata��es dos campos por tipo de atributo
							IN - Chamada pontualmente em situa��es onde h� necessidade de considerar o filtro IN de um campo espec�fico
@param cQuery   , caracter, retorna por refer�ncia a query com os dados alterados
@param cAlias   , caracter, indica o alias da tabela no banco
@param cColuna  , caracter, indica o nome da coluna no banco
@param cTipo    , caracter, indica o formato do campo no banco
@param cValor   , caracter, conteudo do campo para prepara��o
/*/
Method montaCampoQuery(cOperacao, cQuery, cAlias, cColuna, cTipo, cValor) CLASS MRPApi

	Local nInd     := 0
	Local nTotal   := 0
	Local aValores

	Default cOperacao = "AND"

	If cOperacao == "AND"
		cQuery += " AND " + cAlias + "." + cColuna + " = "
		::montaCampoQuery("FORMATA_CAMPO", @cQuery, cAlias, cColuna, cTipo, cValor)

	ElseIf cOperacao == "FORMATA_CAMPO"
		If cTipo == "C"
			If Empty(cValor)
				cQuery += "' '"
			Else
				cQuery += "'" + cValor + "' "
			EndIf
		ElseIf cTipo == "L"
			If ValType(cValor) == "L"
				cQuery += "'" + Iif(cValor,"T","F")
			Else
				cQuery += "'" + Iif(Upper(cValor)=="TRUE","T","F")
			EndIf
		ElseIf cTipo == "N"
			If ValType(cValor) == "N"
				cQuery += cValToChar(cValor)
			Else
				cQuery += cValor
			EndIf
		ElseIf cTipo == "D"
			cQuery += "'" + StrTran(cValor,"-","") + "' "
		EndIf

	ElseIf cOperacao == "IN"
		aValores := strTokArr(cValor, ",")
		nTotal   := Len(aValores)
		If nTotal > 0
			cQuery += " AND " + cAlias + "." + cColuna + " IN ("
			For nInd := 1 to nTotal
				If nInd != 1
					cQuery += ","
				EndIf
				::montaCampoQuery("FORMATA_CAMPO", @cQuery, cAlias, cColuna, cTipo, aValores[nInd])
			Next
			cQuery += ")"
		EndIf
	EndIf

Return cQuery

/*/{Protheus.doc} montaInfoPai
Monta um objeto JSON com dados de relacionamento entre items pais e filhos.

@type  METHOD
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@param aKeyFilho, Array    , Array com o relacionamento entre o pai e o filho
@param cMapCode , Character, C�digo do mapeamento setado.
@param oItem    , Object   , Objeto do item que est� sendo processado
@param oInfoPai , Object   , Objeto de informa��es do item pai, caso exista.
@return oInfo   , Object   , Objeto com as informa��es de relacionamento.
/*/
Method montaInfoPai(aKeyFilho, cMapCode, oItem, oInfoPai) CLASS MRPApi
	Local aMap   := Self:oApiMap[cMapCode]["map"]
	Local cName  := ""
	Local nIndex := 0
	Local nPos   := 0
	Local nTotal := Len(aKeyFilho)
	Local oInfo  := JsonObject():New()

	oInfo["valores"]     := JsonObject():New()
	oInfo["tipoValores"] := JsonObject():New()
	For nIndex := 1 To nTotal
		nPos := Self:oApiMap[cMapCode]["aliasColumns"][Upper(aKeyFilho[nIndex][1])]
		If nPos != Nil
			cName := aMap[nPos][1]
			If cName != Nil
				oInfo["valores"][aKeyFilho[nIndex][2]] := Self:formatDado(aMap[nPos][3], oItem[cName], "1", aMap[nPos][4])
				oInfo["tipoValores"][aKeyFilho[nIndex][2]] := aMap[nPos][3]
			EndIf
		ElseIf oInfoPai != Nil
			//Procura a informa��o no pai deste item.
			If oInfoPai["valores"][Upper(aKeyFilho[nIndex][1])] != Nil
				nPos := Self:oApiMap[oInfoPai["mapCodePai"]]["aliasColumns"][Upper(aKeyFilho[nIndex][1])]
				If nPos != Nil
					cName := Self:oApiMap[oInfoPai["mapCodePai"]]["map"][nPos][1]
					If cName != Nil
						oInfo["valores"][aKeyFilho[nIndex][2]] := oInfoPai["referenciaPai"][cName]
						oInfo["tipoValores"][aKeyFilho[nIndex][2]] := Self:oApiMap[oInfoPai["mapCodePai"]]["map"][nPos][3]
					EndIf
				EndIf
			EndIf
		EndIf
	Next nIndex
	oInfo["mapCodePai"]    := cMapCode
	oInfo["referenciaPai"] := oItem
Return oInfo

/*/{Protheus.doc} formatDado
Formata uma informa��o recebida pela API de acordo com o campo correspondente no APIMAP.

@type  METHOD
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cValType, Character, Tipo do valor para convers�o. (C=Caracter,D=Date,L-Logic,N=Numeric)
@param xValue  , Any      , Valor que ser� tratado
@param cOrigem , Character, Origem da convers�o. 1=JSON para ADVPL. 2=ADVPL para JSON.
@param nTamanho , Numeric , Tamanho do campo.
@return xNewValue, any, Campo formatado no formato correto.
/*/
Method formatDado(cValType, xValue, cOrigem, nTamanho) CLASS MRPApi
	Local xNewValue := Nil
	Local oJsonAux  := Nil

	Do Case
		Case cValType == "C"
			If cOrigem == "1"
				xNewValue := PadR(xValue, nTamanho)
			Else
				xNewValue := RTrim(xValue)
			EndIf
		Case cValType == "D"
			If cOrigem == "1"
				xNewValue := StoD(getDate(xValue))
			Else
				If !Empty(xValue)
					xNewValue := xValue
					xNewValue := StrZero(Year(xNewValue),4) + "-" + StrZero(Month(xNewValue),2) + "-" + StrZero(Day(xNewValue),2)
				Else
					xNewValue := ""
				EndIf
			EndIf
		Case cValType == "O"
			If cOrigem == "2"
				If ValType(xValue) == "C"
					oJsonAux := JsonObject():New()
					oJsonAux:FromJson('{"convObject":'+xValue+'}')
					xNewValue := oJsonAux["convObject"]
					FreeObj(oJsonAux)
					oJsonAux := Nil
				Else
					xNewValue := xValue
				EndIf
			Else
				If ValType(xValue) != "C"
					xNewValue := FwJsonSerialize(xValue,.F.,.F.)
				Else
					xNewValue := xValue
				EndIf
			EndIf
		Otherwise
			xNewValue := xValue
	EndCase
Return xNewValue

/*/{Protheus.doc} restReturn
Seta o retorno do m�todo REST para a API. Utilizar somente quando estiver na inst�ncia de um WSSERVICE.
N�o � necess�rio instanciar a classe MRPApi para executar este m�todo.
Exemplo de chamada:
MRPApi():restReturn(Self, aReturn, cMethod, @lRet)

@type  Method
@author lucas.franca
@since 27/05/2019
@version P12.1.27
@param oWsRest, Object  , Objeto do servi�o REST em execu��o
@param aReturn, Array   , Array com o c�digo de retorno e mensagens de retorno.
@param cMethod, Caracter, M�todo REST que est� sendo executado.
@param lReturn, L�gico  , Status que dever� ser retornado pelo m�todo REST.
@return Nil
/*/
Method restReturn(oWsRest, aReturn, cMethod, lReturn) CLASS MRPApi
	Local aDetail  := {}
	Local cMessage := ""
	Local cDetMsg  := ""
	Local nCode    := 0
	Local nIndex   := 0
	Local nTam     := 0
	Local oReturn  := Nil

	lReturn := .T.
	If cMethod == "GET"
		//Verifica se processou com sucesso ou n�o.
		If !aReturn[1]
			//N�o processou com sucesso. Seta o c�digo e mensagem de erro para retorno.
			SetRestFault(aReturn[3], aReturn[2])
			lReturn := .F.
		Else
			//Processou com sucesso.
			oWsRest:SetResponse(aReturn[2])
		EndIf
	ElseIf aReturn[1] >= 400
		//Ocorreu erro em todos os items processados. Retorna erro.
		lReturn := .F.
		//Monta o array para utilizar na fun��o SetRestFault, retornando os detalhes de erro.
		oReturn := JsonObject():New()
		oReturn:FromJson(aReturn[2])

		//Informa��es gen�ricas do erro.
		nCode    := oReturn["code"]
		cMessage := EncodeUtf8(oReturn["message"])
		cDetMsg  := EncodeUtf8(oReturn["detailedMessage"])

		//Array dos itens que tiveram erro.
		If oReturn["details"] != Nil
			nTam := Len(oReturn["details"])
			For nIndex := 1 To nTam
				aAdd(aDetail,{oReturn["details"][nIndex]["code"],;
								EncodeUtf8(oReturn["details"][nIndex]["message"]),;
								oReturn["details"][nIndex]["detailedMessage"],;
								"",{}})
			Next nIndex
		Else
			aDetail := Nil
		EndIf

		//Faz o SET do retorno de erro.
		SetRestFault(nCode, cMessage, .T., nCode, cDetMsg, "", aDetail )

		//Retira da mem�ria o objeto de retorno utilizado.
		FreeObj(oReturn)
		oReturn := Nil
	Else
		//Mensagem processada, retorna a msg de sucesso.
		HTTPSetStatus(aReturn[1])
		If cMethod == "DELETE" .And. aReturn[1] == 204
			oWsRest:SetResponse("")
		Else
			oWsRest:SetResponse(EncodeUtf8(aReturn[2]))
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} msgRetorno
Monta a mensagem de retorno no padr�o definido pela API.

@type  Method
@author lucas.franca
@since 22/05/2019
@version P12.1.27
@param cMetodo , Character, M�todo que est� sendo executado (POST/DELETE)
@param lStatus , Logical  , Status do processamento. .F. = N�o processou nada| .T. = Processou pelo menos 1 item da mensagem.
@param aSuccess, Array    , Array contendo os itens processados com sucesso. Utilizado quando lStatus = .T.
@param aError  , Array    , Array contendo os itens processado com algum erro. Utilizado quando lStatus = .T.
                            Este array possui 3 posi��es.
														[1] - Item processado;
														[2] - C�digo do erro ocorrido para o item.
														[3] - Mensagem do erro ocorrido para o item.
@param cMessage, Character, Mensagem de erro gen�rica. Utilizada quando lStatus = .F.
@param cDetMsg , Character, Mensagem de erro detalhada. Utilizada quando lStatus = .F.
@param nErrCode, Numeric  , C�digo do erro que ocorreu. Utilizado quando lStatus = .F.
@param aReturn , Array, Array contendo o c�digo HTTP que dever� ser retornado pela API, e JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. C�digo HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
@return Nil
/*/
Method msgRetorno(cMetodo, lStatus, aSuccess, aError, cMessage, cDetMsg, nErrCode, aReturn) CLASS MRPApi
	Local cAtributo := ""
	Local nIndex    := 0
	Local nTam      := 0
	Local oJsonRet  := JsonObject():New()

	aReturn := {200,Nil}

	If lStatus
		If aSuccess == Nil
			aSuccess := {}
		EndIf
		If aError == Nil
			aError := {}
		EndIf
		If Len(aSuccess) > 0
			If cMetodo == "DELETE"
				//M�todo DELETE, quando conseguir excluir tudo deve retornar o c�digo
				//HTTP 204 (No Content)
				aReturn[1] := 204
			Else
				//M�todo POST, quando conseguir incluir/atualizar tudo deve retornar o
				//c�digo HTTP 201 (Created)
				aReturn[1] := 201
			EndIf
			//Adiciona os items incluidos/alterados/exclu�dos com sucesso.
			//Quando exclus�o, somente ir� adicionar os items exclu�dos com sucesso quando
			//tamb�m existirem items que tiveram erro.
			//Se todos os items foram exclu�dos com sucesso, ir� retornar status 204, e nenhuma informa��o no corpo da resposta.
			If cMetodo == "POST" .Or. (cMetodo == "DELETE" .And. Len(aError) > 0)
				oJsonRet["items"]   := aClone(aSuccess)
				//Adiciona o hasNext com valor .F. para atender
				//a padroniza��o definida na documenta��o da API.
				oJsonRet["hasNext"] := .F.
			EndIf
		EndIf
		nTam := Len(aError)
		If nTam > 0
			If Len(aSuccess) > 0
				//Se processou parcialmente a lista,
				//deve retornar o c�digo HTTP 207 (Multi-Status)
				aReturn[1] := 207
				cAtributo := "_messages"
			Else
				//Todos os items da lista deram erro.
				//Retorna o c�digo HTTP 400 (Bad Request)
				aReturn[1] := 400
				oJsonRet["code"]            := 400
				oJsonRet["message"]         := STR0016 //"N�o foi poss�vel processar os itens."
				oJsonRet["detailedMessage"] := STR0017 //"Verifique os erros ocorridos em cada item para obter detalhes."
				cAtributo := "details"
			EndIf
			//Monta na tag details as informa��es do erro ocorrido em cada item.
			oJsonRet[cAtributo] := Array(nTam)
			For nIndex := 1 To nTam
				oJsonRet[cAtributo][nIndex] := JsonObject():New()
				oJsonRet[cAtributo][nIndex]["code"]            := aError[nIndex][2]
				oJsonRet[cAtributo][nIndex]["message"]         := aError[nIndex][3]
				oJsonRet[cAtributo][nIndex]["detailedMessage"] := aError[nIndex][1]
			Next nIndex
		EndIf
	Else
		If cMetodo == "DELETE"
			//M�todo delete com ERRO, retorna status 200 (OK)
			aReturn[1] := 200
		Else
			//M�todo POST com ERRO, retorna status 400 (Bad Request)
			aReturn[1] := 400
		EndIf
		If ValType(nErrCode) == "C"
			oJsonRet["code"]        := Val(nErrCode)
		Else
			oJsonRet["code"]        := nErrCode
		EndIf
		oJsonRet["message"]         := cMessage
		oJsonRet["detailedMessage"] := cDetMsg
	EndIf

	aReturn[2] := oJsonRet:ToJson()

	FreeObj(oJsonRet)
	oJsonRet := Nil
Return Nil

/*/{Protheus.doc} defineTransaction
Define se ser� utilizada transa��o a cada item processado.

@type  Method
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@return Nil
/*/
Method defineTransaction() CLASS MRPApi

	If Self:lForcaTransacao
		Self:lUsaTransaction := .T.
	Else
		//Quando ser� processado mais de uma tabela por item, sempre utiliza transa��o.
		If Self:oMapRel[Self:cMapCodePrincipal] != Nil
			Self:lUsaTransaction := .T.
		Else
			Self:lUsaTransaction := .F.
		EndIf
	EndIf
Return

/*/{Protheus.doc} getKeySearch
Monta o array com as chaves de pesquisa de determinado item

@type  Method
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@param cMapCode , Character, C�digo do mapeamento em processamento.
@param oItem    , Object   , Objeto JSON do item que est� sendo processado.
@param oInfoPai , Object   , Objeto JSON com as informa��es de relacionamento do PAI
@return aKeySearch, Array  , Array com os valores de busca do item
/*/
Method getKeySearch(cMapCode, oItem, oInfoPai) CLASS MRPApi
	Local aKeySearch := {}
	Local aMap       := {}
	Local cName      := ""
	Local nIndex     := 0
	Local nPos       := 0
	Local nTotal     := 0
	Local xInfo      := Nil

	If Self:oKeySearch[cMapCode] != Nil
		aMap   := Self:oApiMap[cMapCode]["map"]
		nTotal := Len(Self:oKeySearch[cMapCode])
		For nIndex := 1 To nTotal
			xInfo := Nil
			nPos := Self:oApiMap[cMapCode]["aliasColumns"][Upper(Self:oKeySearch[cMapCode][nIndex])]
			If nPos != Nil
				//A informa��o est� presente no item processado
				cName := aMap[nPos][1]
				If aMap[nPos][3] == "C" .And. oItem[cName] != Nil .And. Empty(oItem[cName])
					xInfo := " "
				ElseIf aMap[nPos][3] == "D"
					xInfo := getDate(oItem[cName])
				Else
					xInfo := oItem[cName]
				EndIf
			ElseIf oInfoPai != Nil
				//A informa��o n�o est� presente no item processado.
				//Tenta encontrar nos dados do item PAI
				If oInfoPai["tipoValores"][Self:oKeySearch[cMapCode][nIndex]] == "C" .And. ;
				   oInfoPai["valores"][Self:oKeySearch[cMapCode][nIndex]] != Nil .And. ;
				   Empty( oInfoPai["valores"][Self:oKeySearch[cMapCode][nIndex]] )
				   	xInfo := " "
				Else
					xInfo := oInfoPai["valores"][Self:oKeySearch[cMapCode][nIndex]]
				EndIf
			EndIf
			If xInfo != Nil
				aAdd(aKeySearch, Array(2))
				nPos := Len(aKeySearch)
				aKeySearch[nPos][1] := Self:oKeySearch[cMapCode][nIndex]
				aKeySearch[nPos][2] := xInfo
			EndIf
		Next nIndex
	EndIf
Return aKeySearch

/*/{Protheus.doc} ordenaMap
Ordena o array de mapeamento recebido, colocando os campos do tipo MEMO no final da lista.

@type  Method
@author lucas.franca
@since 06/06/2019
@version P12.1.27
@param cMapCode , Character, C�digo do mapeamento em processamento.
@return Nil
/*/
Method ordenaMap(cMapCode) CLASS MRPApi
	Local aMap      := Self:oApiMap[cMapCode]["map"]
	Local aMapDel   := {}
	Local aMemos    := {}
	Local nIndex    := 0
	Local nTotal    := Len(aMap)
	Local nTotMemos := 0

	//Armazena os campos do tipo memo em array auxiliar
	For nIndex := 1 To nTotal
		If GetSx3Cache(aMap[nIndex][2], "X3_TIPO") == "M"
			aAdd(aMemos, aClone(aMap[nIndex]))
			aAdd(aMapDel, nIndex)
		EndIf
	Next nIndex

	//Apaga os campos memos do array de mapeamentos
	nTotMemos := Len(aMapDel)
	For nIndex := nTotMemos To 1 step -1
		aDel(aMap, aMapDel[nIndex])
		//Adiciona o campo memo novamente, no final do array de mapeamento
		aMap[nTotal] := aClone(aMemos[1])
		//Elimina o campo memo do array auxiliar
		aDel(aMemos, 1)
		aSize(aMemos, Len(aMemos)-1)
	Next nIndex
Return Nil

/*/{Protheus.doc} validaDicionario
Verifica se o s campos utilizados pela API est�o cadastrados no dicion�rio de dados

@type  Method
@author lucas.franca
@since 11/06/2020
@version P12.1.27
@return lRet, Logic, Identifica se o dicion�rio est� correto.
/*/
Method validaDicionario() CLASS MRPApi
	Local aNames  := Self:oApiMap:GetNames()
	Local lRet    := .T.
	Local nIndex  := 0
	Local nTotal  := Len(aNames)
	Local nIndMap := 0
	Local nTotMap := 0

	For nIndex := 1 To nTotal
		nTotMap := Len(Self:oApiMap[aNames[nIndex]]["map"])
		For nIndMap := 1 To nTotMap
			If Self:oApiMap[aNames[nIndex]]["map"][nIndMap][2] != "R_E_C_N_O_" .And. Empty( GetSx3Cache( Self:oApiMap[aNames[nIndex]]["map"][nIndMap][2], "X3_TIPO" ) )
				lRet := .F.
				Self:setError("400", STR0019 + AllTrim(Self:oApiMap[aNames[nIndex]]["map"][nIndMap][2]) + STR0020) //"Dicion�rio de dados inv�lido. Coluna '" xxx "' n�o existe."
				Exit
			EndIf
		Next nIndMap
		If !lRet
			Exit
		EndIf
	Next nIndex

Return lRet

/*/{Protheus.doc} forcaTransacao
For�a a utiliza��o de transa��o nas atualiza��es de registros

@type  Method
@author marcelo.neumann
@since 29/07/2021
@version P12
@param lForca, Logic, Indica se a classe deve for�ar o uso de transa��o
@return Nil
/*/
Method forcaTransacao(lForca) CLASS MRPApi
	Default lForca := .T.

	Self:lForcaTransacao := lForca

Return

/*/{Protheus.doc} regPaiIncluido
Verifica se um JSON Pai j� foi adicionado em Self:oDadosInclui[cMapCode]["items"]

@type  Method
@author lucas.franca
@since 10/02/2022
@version P12
@param oInfoPai, JsonObject, JSONOBJECT com os dados do registro pai
@return lRet, Logic, Indica se o registro j� foi adicionado ou n�o.
/*/
Method regPaiIncluido(oInfoPai) CLASS MRPApi
	Local aNames := aSort(oInfoPai["valores"]:GetNames())
	Local cChave := ""
	Local lRet   := .F.
	Local nIndex := 0
	Local nTotal := Len(aNames)

	For nIndex := 1 To nTotal 
		If oInfoPai["valores"][aNames[nIndex]] != Nil
			cChave += RTrim(AllToChar(oInfoPai["valores"][aNames[nIndex]])) + "|"
		EndIf
	Next nIndex
	
	lRet := Self:oContrDadosPai:hasProperty(cChave)
	Self:oContrDadosPai[cChave] := .T.

	aSize(aNames, 0)
Return lRet

/*/{Protheus.doc} getDate
Formata uma string de data no formato AAAA-MM-DD para o formato AAAAMMDD

@type  Static Function
@author lucas.franca
@since 03/06/2019
@version P12.1.27
@param cData, Character, Data no formato AAAA-MM-DD
@return cData, Character, Data no formato AAAAMMDD
/*/
Static Function getDate(cData)
Return StrTran(cData,'-','')

/*/{Protheus.doc} SemafTable
Cria sem�foro para inclus�o da tabela T4N, para controlar corretamente o RECNO da tabela.
Utilizado somente quando a tabela T4N n�o possuir RECNO Auto Incremental.

@type  Static Function
@author lucas.franca
@since 22/05/2019
@version P12.1.27
@param lLock , Logical  , Se verdadeiro, ir� tentar fazer o LOCK. Se falso, ir� liberar o lock.
@param cTable, Character, Tabela que est� sendo processada para criar o sem�foro.
@return lRet , Logical  , Se verdadeiro, conseguiu fazer o lock.
/*/
Static Function SemafTable(lLock, cTable, cPrefix)
	Local nTry := 0

	Default cPrefix := "INCMRPAPI"
	If lLock
		While !LockByName(cPrefix+cTable+cEmpAnt,.T.,.T.)
			nTry++
			If nTry > 500
				Return .F.
			EndIf
			Sleep(200)
		End
	Else
		UnLockByName(cPrefix+cTable+cEmpAnt,.T.,.T.)
	EndIf
Return .T.


