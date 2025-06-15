#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "InspecoesDeProcessosAPI.CH"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} processinspections
API de Inspeção de Processos - Qualidade
@author brunno.costa
@since  23/05/2022
/*/
WSRESTFUL processinspections DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Inspeções de Processos"

    WSDATA Fields           as STRING OPTIONAL
	WSDATA IncompleteReport as BOOLEAN OPTIONAL
	WSDATA Laboratory       as STRING OPTIONAL
    WSDATA Login            as STRING OPTIONAL
	WSDATA NotStarted       as BOOLEAN OPTIONAL
	WSDATA OperationID      as STRING OPTIONAL
    WSDATA Order            as STRING OPTIONAL
	WSDATA OrderType        as STRING OPTIONAL
    WSDATA Page             as INTEGER OPTIONAL
    WSDATA PageSize         as INTEGER OPTIONAL
	WSDATA Recno            as STRING OPTIONAL
    WSDATA Text             as STRING OPTIONAL
	WSDATA WithoutReport    as BOOLEAN OPTIONAL

    WSMETHOD GET pendinglist;
	DESCRIPTION STR0002; //"Retorna Lista Inspeções de Processos Pendentes"
	WSSYNTAX "api/qip/v1/pendinglist/{Login}/{Laboratory}/{Order}/{OrderType}/{Page}/{PageSize}/{NotStarted}/{WithoutReport}/{IncompleteReport}" ;
	PATH "/api/qip/v1/pendinglist" ;
	TTALK "v1"

    WSMETHOD GET search;
    DESCRIPTION STR0003; //"Pesquisa Lista Inspeções de Processos"
    WSSYNTAX "api/qip/v1/search/{Login}/{Laboratory}/{Text}/{Order}/{OrderType}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/search" ;
    TTALK "v1"

	WSMETHOD GET inspection;
    DESCRIPTION STR0005; //"Retorna uma Inspeção de Processos"
    WSSYNTAX "api/qip/v1/inspection/{Login}/{Laboratory}/{Recno}/{OperationID}" ;
    PATH "/api/qip/v1/inspection" ;
    TTALK "v1"

	WSMETHOD GET userExist;
	DESCRIPTION STR0004; //"Retorna se o usuário possui cadastro ativo no módulo inspeção de processos"
	WSSYNTAX "api/qip/v1/userExist/{Login}" ;
	PATH "/api/qip/v1/userExist" ;
	TTALK "v1"

	WSMETHOD GET cards;
    DESCRIPTION STR0008; //"Retorna Resumo dos Cards de Inspeção"
    WSSYNTAX "api/qip/v1/cards/{Login}/{Laboratory}/{Text}" ;
    PATH "/api/qip/v1/cards" ;
    TTALK "v1"

	WSMETHOD POST completeStockRelease;
	DESCRIPTION STR0009; // "Movimenta as pendências de estoque CQ automaticamente"
	WSSYNTAX "api/qip/v1/completestockrelease" ;
	PATH    "/api/qip/v1/completestockrelease" ;
	TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET pendinglist PATHPARAM Login, Laboratory, Order, OrderType, Page, PageSize, NotStarted, WithoutReport, IncompleteReport QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass               := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login            := ""
	Default Self:Laboratory       := ""
	Default Self:Order            := ""
	Default Self:OrderType        := ""
	Default Self:Page             := 1
	Default Self:PageSize         := 5
	Default Self:Fields           := ""
	Default Self:NotStarted       := .F.
    Default Self:WithoutReport    := .F.
    Default Self:IncompleteReport := .F.

Return oAPIClass:PesquisaLista(Self:Login, Self:Laboratory, "", Self:Order, Self:OrderType, Self:Page, Self:PageSize, Self:Fields, Nil, Nil, Self:NotStarted, Self:WithoutReport, Self:IncompleteReport)

WSMETHOD GET search PATHPARAM Login, Laboratory, Text, Order, OrderType, Page, PageSize, NotStarted, WithoutReport, IncompleteReport QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass               := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login            := ""
	Default Self:Laboratory       := ""
	Default Self:Text             := ""
	Default Self:Order            := ""
	Default Self:OrderType        := ""
	Default Self:Page             := 1
	Default Self:PageSize         := 5
	Default Self:Fields           := ""
	Default Self:NotStarted       := .F.
    Default Self:WithoutReport    := .F.
    Default Self:IncompleteReport := .F.
Return oAPIClass:PesquisaLista(Self:Login, Self:Laboratory, Self:Text, Self:Order, Self:OrderType, Self:Page, Self:PageSize, Self:Fields, Nil, Nil, Self:NotStarted, Self:WithoutReport, Self:IncompleteReport)

WSMETHOD GET inspection PATHPARAM Login, Laboratory, Recno QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass          := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login       := ""
	Default Self:Recno       := "0"
	Default Self:Fields      := ""
	Default Self:OperationID := ""
Return oAPIClass:PesquisaLista(Self:Login, "", "", "", "", 1, 9999, Self:Fields, Self:Recno, Self:OperationID)

WSMETHOD GET userExist PATHPARAM Login WSSERVICE processinspections
    Local oAPIClass  := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login    := ""
Return oAPIClass:UsuarioExistente(Self:Login)

WSMETHOD GET cards PATHPARAM Login, Text, Laboratory QUERYPARAM Fields WSSERVICE processinspections
    Local oAPIClass         := InspecoesDeProcessosAPI():New(Self)
	Default Self:Login      := ""
	Default Self:Laboratory := ""
	Default Self:Text       := ""
Return oAPIClass:RetornaContagemCards(Self:Login, Self:Text, Self:Laboratory)


WSMETHOD POST completeStockRelease QUERYPARAM Fields WSSERVICE processinspections
    
    Local cError     := ""
    Local cJsonData  := DecodeUTF8(Self:GetContent())
    Local lSucesso   := .F.
    Local oAPIClass  := QIPLaudosEnsaios():New(Self)
    Local oData 	 := JsonObject():New()

    oData:fromJson(cJsonData)
	nRecnoQPK := oData['recno']
    lSucesso  := oAPIClass:MovimentaEstoqueCQ(nRecnoQPK)
    cError 	  := oAPIClass:oAPIManager:cErrorMessage

    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)

Return 

/*/{Protheus.doc} InspecoesDeProcessosAPI
Regras de Negocio - API Inspeção de Processos
@author brunno.costa
@since  23/05/2022
/*/
CLASS InspecoesDeProcessosAPI FROM LongNameClass
	DATA oAPIManager   as OBJECT
    DATA oWSRestFul    as OBJECT
	DATA oQueryManager as OBJECT
    METHOD new(oWSRestFul) CONSTRUCTOR
    METHOD CriaAliasPesquisa(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos)
	METHOD PesquisaLista(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos)
	METHOD RetornaContagemCards(cLogin, cTexto, cLaboratorio)
	METHOD UsuarioExistente(cLogin)
     
    //Métodos Internos
    METHOD MapeiaCampos(cCampos)
	METHOD NaoImplantado()
	METHOD RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTexto, cLaboratorio)
	METHOD RetornaQueryFiltroCardSemLaudos(cLogin, cTexto, cLaboratorio)
ENDCLASS

METHOD new(oWSRestFul) CLASS InspecoesDeProcessosAPI
     Self:oWSRestFul  := oWSRestFul
	 Self:oQueryManager := QLTQueryManager():New()
Return Self

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCampos(cCampos) CLASS InspecoesDeProcessosAPI

    Local aMapaCampos := {}
	Local oQltAPIManager := QualityAPIManager():New(nil, Self:oWSRestFul)

    aAdd(aMapaCampos, {.F., "CodigoProduto"           , "productID"              , "QPK_PRODUT"      , "C" , oQltAPIManager:GetSx3Cache("QPK_PRODUT" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Produto"                 , "product"                , "B1_DESC"         , "C" , oQltAPIManager:GetSx3Cache("B1_DESC"    ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "OrdemDeProducao"         , "productionOrderID"      , "QPK_OP"          , "C" , oQltAPIManager:GetSx3Cache("QPK_OP"     ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "CodigoRoteiro"           , "operationRoutines"      , "QQK_CODIGO"      , "C" , oQltAPIManager:GetSx3Cache("QQK_CODIGO" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "CodigoOperacao"          , "operationID"            , "QQK_OPERAC"      , "C" , oQltAPIManager:GetSx3Cache("QQK_OPERAC" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Operacao"                , "operation"              , "QQK_DESCRI"      , "C" , oQltAPIManager:GetSx3Cache("QQK_DESCRI" ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "Recurso"                 , "resource"               , "H1_DESCRI"       , "C" , oQltAPIManager:GetSx3Cache("H1_DESCRI"  ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "Quantidade"              , "lotSize"                , "QPK_TAMLOT"      , "N" , oQltAPIManager:GetSx3Cache("QPK_TAMLOTE","X3_TAMANHO"), oQltAPIManager:GetSx3Cache("QPK_TAMLOTE","X3_DECIMAL")})
	aAdd(aMapaCampos, {.F., "CodigoUM"                , "lotUnitID"              , "QPK_UM"          , "C" , oQltAPIManager:GetSx3Cache("QPK_UM"     ,"X3_TAMANHO"), 0})
	aAdd(aMapaCampos, {.F., "UnidadeMedida"           , "lotUnit"                , "AH_DESCPO"       , "C" , oQltAPIManager:GetSx3Cache("AH_DESCPO"  ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "Lote"                    , "lot"                    , "QPK_LOTE"        , "C" , oQltAPIManager:GetSx3Cache("QPK_LOTE"   ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "NumeroDeSerie"           , "serialNumber"           , "QPK_NUMSER"      , "C" , oQltAPIManager:GetSx3Cache("QPK_NUMSER" ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "DataEmissao"             , "date"                   , "QPK_EMISSA"      , "D" , oQltAPIManager:GetSx3Cache("QPK_EMISSAO","X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "ClienteLoja"             , "customer"               , "ClienteLoja"     , "C" , oQltAPIManager:GetSx3Cache("A1_NOME"    ,"X3_TAMANHO") + oQltAPIManager:GetSx3Cache("QPK_CLIENT","X3_TAMANHO") + oQltAPIManager:GetSx3Cache("QPK_LOJA","X3_TAMANHO") + 4, 0})
    aAdd(aMapaCampos, {.F., "VersaEspecificacao"      , "specificationVersion"   , "QPK_REVI"        , "C" , oQltAPIManager:GetSx3Cache("QPK_REVI"   ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "DataProducao"            , "productionDate"         , "QPK_DTPROD"      , "D" , oQltAPIManager:GetSx3Cache("QPK_DTPROD" ,"X3_TAMANHO"), 0})
    aAdd(aMapaCampos, {.F., "UsuarioPermitido"        , "allowedUser"            , "Permitido"       , "L" ,                                       3, 0})
	aAdd(aMapaCampos, {.F., "LaudoOperacao"           , "operationReport"        , "QPM_LAUDO"       , "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.F., "Status"                  , "status"                 , "Status"          , "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.F., "LaudoIncompleto"         , "incompleteReport"       , "incompletereport", "C" ,                                       1, 0})
	aAdd(aMapaCampos, {.T., "RecnoInspecao"           , "recno"                  , "R_E_C_N_O_"      , "NN",                                       0, 0}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
 
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} CriaAliasPesquisa
Cria Alias para Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin            , caracter, login do usuário para validação das permissões de acesso
@param 02 - cLaboratorio      , caracter, laboratório para filtro
@param 02 - cTexto            , caracter, texto para pesquisa nos campos de OP e Produto
@param 03 - cOrdem            , caracter, ordenação para retornar a listagem dos dados
@param 03 - cTipoOrdem        , caracter, tipo de ordenação para retornar a listagem dos dados (Ascencente ou Decrescente)
@param 04 - nPagina           , numérico, página atual dos dados para consulta
@param 05 - nTamPag           , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 06 - cCampos           , caracter, campos que deverão estar contidos na mensagem
@param 07 - cRecno            , caracter, recno do registro para filtro
@param 08 - cOperacao         , caracter, operacao da inspecao para filtro
@param 09 - lNaoIniciadas     , lógico  , indica se realiza filtro de inspeções não iniciadas
@param 10 - lSemLaudos        , lógico  , indica se realiza filtro de inspeções sem laudos
@param 11 - lLaudosIncompletos, lógico  , indica se realiza filtro de inspeções com laudos incompletos
@return cAlias, caracter, alias com os dados da pesquisa
/*/
METHOD CriaAliasPesquisa(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos) CLASS InspecoesDeProcessosAPI
     
    Local cAlias               := Nil
	Local cOrdemDB             := Nil
    Local cQuery               := Nil
	Local cTextoOrig           := cTexto
	Local bErrorBlock          := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})

	Default cLogin             := ""
	Default cLaboratorio       := ""
	Default cTexto             := ""
	Default cOrdem             := ""
	Default cTipoOrdem         := ""
	Default nPagina            := 1
	Default nTamPag            := 999999
	Default cCampos            := "*"
	Default cRecno             := ""
	Default cOperacao          := ""
	Default lNaoIniciadas      := .F.
	Default lSemLaudos         := .F.
	Default lLaudosIncompletos := .F.

	BEGIN SEQUENCE
		Self:MapeiaCampos(cCampos)

		cTexto := FwQtToChr(cTexto)

		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario()

		cQuery := " SELECT DISTINCT "
		cQuery +=        " QPK.QPK_PRODUT, "
		cQuery +=        " QPK.QPK_OP, "
		cQuery +=        " QQK.QQK_CODIGO, "
		cQuery +=        " QQK.QQK_OPERAC, "
		cQuery +=        " QPK.QPK_TAMLOT, "
		cQuery +=        " QPK.QPK_UM, "
		cQuery +=        " QPK.QPK_LOTE, "
		cQuery +=        " QPK.QPK_NUMSER, "
		cQuery +=        " QPK.QPK_EMISSA, "
		cQuery +=        " COALESCE ((CASE QPK_CLIENT "
		cQuery +=                       " WHEN NULL THEN '' "
		cQuery +=                       " ELSE CONCAT( CONCAT( CONCAT( CONCAT( A1_COD , '-' ) , A1_LOJA ) , ' ' ) , A1_NOME ) "
		cQuery +=                   " END), ' ') ClienteLoja, "
		cQuery +=        " QPK.QPK_REVI, "
		cQuery +=        " QPK.QPK_DTPROD, "
		cQuery +=        " QPK.R_E_C_N_O_, "
		cQuery +=        " QAA.Permitido, "
		cQuery +=        " QUERY_STATUS.QPM_LAUDO, "
		
		cQuery +=        " (CASE QPK.QPK_SITOP "
		cQuery +=             " WHEN '2' THEN 'A' "
		cQuery +=             " WHEN '3' THEN 'R' "
		cQuery +=             " WHEN '4' THEN 'U' "
		cQuery +=             " WHEN '5' THEN 'C' "
		cQuery +=             " WHEN '6' THEN 'E' "
		cQuery +=             " ELSE "

		cQuery +=             " COALESCE (QUERY_STATUS.QPM_LAUDO, "
		cQuery +=                      " (CASE COALESCE (QPR_RESULT, "
		cQuery +=                                       "'N') "
		cQuery +=                           " WHEN 'N' THEN 'N' "
		cQuery +=                           " ELSE 'I' "
		cQuery +=                       " END))

		cQuery +=        " END) Status, "


		If (lNaoIniciadas .OR. lSemLaudos)
			cQuery +=        " 'false' incompletereport, "
		Else
			cQuery +=        " (CASE WHEN INCOMPLETOS.CHAVE_OPERACAO IS NULL THEN 'false' ELSE 'true' END) incompletereport, "
		EndIf

		cQuery +=        " SB1.B1_DESC, "
		cQuery +=        " QQK.QQK_DESCRI, "
		cQuery +=        " QQK.QQK_CODIGO, "
		cQuery +=        " SH1.H1_DESCRI, "
		cQuery +=        " SAH.AH_DESCPO "
		cQuery += " FROM "
		cQuery +=   "(SELECT AH_UNIMED, "
		cQuery +=          " AH_DESCPO "
		cQuery +=   " FROM " + RetSQLName("SAH") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (AH_FILIAL = '" + xFilial("SAH") + "')) SAH "
		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT H1_CODIGO, "
		cQuery +=          " H1_DESCRI "
		cQuery +=   " FROM " + RetSQLName("SH1") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (H1_FILIAL = '" + xFilial("SH1") + "')) SH1 "
		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT QPM.QPM_PRODUT, "
		cQuery +=          " QPM.QPM_OP, "
		cQuery +=          " QPM.QPM_ROTEIR, "
		cQuery +=          " QPM.QPM_OPERAC, "
		cQuery +=          " QPM.QPM_LOTE, "
		cQuery +=           "(CASE QPD.QPD_CATEG "
		cQuery +=               " WHEN '2' THEN 'C' "
		cQuery +=               " ELSE (CASE QPM.QPM_LAUDO "
		cQuery +=                         " WHEN 'A' THEN 'A' "
		cQuery +=                         " WHEN 'E' THEN 'R' "
		cQuery +=                         " WHEN 'U' THEN 'U' "
		cQuery +=                         " ELSE NULL "
		cQuery +=                     " END) "
		cQuery +=           " END) QPM_LAUDO "
		cQuery +=   " FROM " + RetSQLName("QPM") + " QPM "
		cQuery +=   " INNER JOIN "
		cQuery +=     "(SELECT QPD_CODFAT, "
		cQuery +=            " QPD_CATEG "
		cQuery +=     " FROM " + RetSQLName("QPD") + " "
		cQuery +=     " WHERE (D_E_L_E_T_ = ' ')) QPD "
		cQuery +=   " ON QPM.QPM_LAUDO = QPD.QPD_CODFAT "
		cQuery +=   " WHERE (QPM.D_E_L_E_T_ = ' ') "
		cQuery +=     " AND (QPM.QPM_FILIAL = '" + xFilial("QPM") + "') "
		If !Empty(cTextoOrig)
			cQuery +=        " AND (    (UPPER(QPM_PRODUT) LIKE CONCAT(CONCAT('%',UPPER(" + cTexto + ")),'%')) "   //5
			cQuery +=              " OR (UPPER(QPM_OP)     LIKE CONCAT(CONCAT('%',UPPER(" + cTexto + ")),'%')) ) " //6
		EndIf
		cQuery += " ) QUERY_STATUS "

		cQuery += " RIGHT JOIN "
		cQuery +=   "(SELECT QPK_PRODUT, "
		cQuery +=          " QPK_OP, "
		cQuery +=          " QPK_TAMLOT, "
		cQuery +=          " QPK_UM, "
		cQuery +=          " QPK_LOTE, "
		cQuery +=          " QPK_NUMSER, "
		cQuery +=          " QPK_EMISSA, "
		cQuery +=          " QPK_REVI, "
		cQuery +=          " QPK_DTPROD, "
		cQuery +=          " QPK_CLIENT, "
		cQuery +=          " QPK_LOJA, "
		cQuery +=          " R_E_C_N_O_, "
		cQuery +=          " QPK_SITOP "
		cQuery +=   " FROM " + RetSQLName("QPK") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "

		If !Empty(cRecno) .AND. cRecno <> "0"
			cQuery +=    " AND (R_E_C_N_O_ = " + cRecno + ") "
		EndIf

		If !Empty(cTextoOrig)
			cQuery +=        " AND (    (UPPER(QPK_PRODUT) LIKE CONCAT(CONCAT('%',UPPER(" + cTexto + ")),'%')) "   //5
			cQuery +=              " OR (UPPER(QPK_OP)     LIKE CONCAT(CONCAT('%',UPPER(" + cTexto + ")),'%')) ) " //6
		EndIf
		cQuery += " ) QPK "

		cQuery += " INNER JOIN "
		cQuery +=   "(SELECT QQK_CODIGO, "
		cQuery +=          " QQK_OPERAC, "
		cQuery +=          " QQK_PRODUT, "
		cQuery +=          " QQK_REVIPR, "
		cQuery +=          " QQK_DESCRI, "
		cQuery +=          " QQK_RECURS "
		cQuery +=   " FROM " + RetSQLName("QQK") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (QQK_FILIAL = '" + xFilial("QQK") + "')) QQK "
		cQuery += " ON QPK.QPK_REVI = QQK.QQK_REVIPR "
		cQuery +=   " AND QPK.QPK_PRODUT = QQK.QQK_PRODUT "
		
		If !Empty(cOperacao)
			cQuery +=   " AND QQK.QQK_OPERAC = '" + cOperacao + "' "
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(cLaboratorio)
			cQuery += " INNER JOIN "
			cQuery += " (SELECT QP8_PRODUT AS PRODUTO, QP8_REVI AS REVISAO, QP8_CODREC, QP8_OPERAC, QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP8") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP8_FILIAL = '" + xFilial("QP8") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP8_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cLogin)
			cQuery += " UNION "
			cQuery += " SELECT QP7_PRODUT, QP7_REVI, QP7_CODREC, QP7_OPERAC, QP7_LABOR "
			cQuery += " FROM " + RetSQLName("QP7") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP7_FILIAL = '" + xFilial("QP7") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP7_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cLogin)
			cQuery += " ) FILTROLAB ON QPK.QPK_PRODUT = FILTROLAB.PRODUTO "
			cQuery +=            " AND QPK.QPK_REVI   = FILTROLAB.REVISAO "
		EndIf

		cQuery += " INNER JOIN "
		cQuery +=   "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN) C2_OP, "
		cQuery +=          " C2_ROTEIRO "
		cQuery +=   " FROM " + RetSQLName("SC2") + " "
		cQuery +=   " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
		cQuery += " ON C2_OP = QPK_OP "
		cQuery +=   " AND C2_ROTEIRO = QQK_CODIGO "

		If lNaoIniciadas .OR. lSemLaudos
			cQuery += " LEFT JOIN ( " + Self:RetornaQueryFiltroCardSemLaudos(cLogin, cTexto, cLaboratorio) + ") LAUDOS "
			cQuery += " ON CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC) = LAUDOS.CHAVE_OPERACAO "
		ElseIf lLaudosIncompletos
			cQuery += " INNER JOIN ( " + Self:RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTexto, cLaboratorio) + ") INCOMPLETOS"
			cQuery += " ON CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC) = INCOMPLETOS.CHAVE_OPERACAO "
		Else
			cQuery += " LEFT JOIN ( " + Self:RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTexto, cLaboratorio) + ") INCOMPLETOS"
			cQuery += " ON CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC) = INCOMPLETOS.CHAVE_OPERACAO "
		EndIf

		cQuery += " LEFT JOIN "
		cQuery +=   "(SELECT A1_COD, "
		cQuery +=          " A1_LOJA, "
		cQuery +=          " A1_NOME "
		cQuery +=   " FROM " + RetSQLName("SA1") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (A1_FILIAL = '" + xFilial("SA1") + "')) SA1 "
		cQuery += " ON SA1.A1_COD = QPK.QPK_CLIENT "
		cQuery +=   " AND SA1.A1_LOJA = QPK.QPK_LOJA "

		cQuery += " INNER JOIN "
		cQuery +=   "(SELECT B1_COD, "
		cQuery +=          " B1_DESC "
		cQuery +=   " FROM " + RetSQLName("SB1") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (B1_FILIAL = '" + xFilial("SB1") + "')) SB1 "
		cQuery += " ON SB1.B1_COD = QPK.QPK_PRODUT "

		cQuery += " LEFT JOIN "
		cQuery +=   "(SELECT DISTINCT QPR.QPR_OP, "
		cQuery +=                   " QPR.QPR_PRODUT, "
		cQuery +=                   " QPR.QPR_OPERAC, "
		cQuery +=                   " QPR.QPR_ROTEIR, "
		cQuery +=                   " QPR.QPR_LOTE, "
		cQuery +=                   " 'X' QPR_RESULT "
		cQuery +=   " FROM " + RetSQLName("QPR") + " QPR "

		cQuery +=   " LEFT JOIN "
		cQuery +=     "(SELECT DISTINCT QPS_CODMED "
		cQuery +=     " FROM " + RetSQLName("QPS") + " "
		cQuery +=     " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=      " AND (QPS_MEDICA <> ' ') "
		cQuery +=      " AND (QPS_FILIAL = '" + xFilial("QPS") + "') "
		cQuery +=     " UNION SELECT DISTINCT QPQ_CODMED "
		cQuery +=     " FROM " + RetSQLName("QPQ") + " "
		cQuery +=     " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=      " AND (QPQ_MEDICA <> ' ') "
		cQuery +=      " AND (QPQ_FILIAL = '" + xFilial("QPQ") + "')) MEDICOES "
		cQuery +=   " ON QPR.QPR_CHAVE = MEDICOES.QPS_CODMED "
		cQuery +=   " WHERE (QPR.D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (QPR.QPR_FILIAL = '" + xFilial("QPR") + "') "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(cLaboratorio)
			If !Empty(cLaboratorio)
				cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cLogin)
		EndIf

		If !Empty(cTextoOrig)
			cQuery +=        " AND (    (UPPER(QPR_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
			cQuery +=              " OR (UPPER(QPR_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
		EndIf
		cQuery += " ) AMOSTRAGENS "
		
		cQuery += " ON QQK.QQK_CODIGO = AMOSTRAGENS.QPR_ROTEIR "
		cQuery +=   " AND QQK.QQK_OPERAC = AMOSTRAGENS.QPR_OPERAC "
		cQuery +=   " AND QPK.QPK_OP = AMOSTRAGENS.QPR_OP "
		cQuery +=   " AND QPK.QPK_PRODUT = AMOSTRAGENS.QPR_PRODUT "
		cQuery +=   " AND QPK.QPK_LOTE = AMOSTRAGENS.QPR_LOTE "
		cQuery += " ON QUERY_STATUS.QPM_LOTE = QPK.QPK_LOTE "
		cQuery +=   " AND QUERY_STATUS.QPM_OP = QPK.QPK_OP "
		cQuery +=   " AND QUERY_STATUS.QPM_PRODUT = QPK.QPK_PRODUT "
		cQuery +=   " AND QUERY_STATUS.QPM_OPERAC = QQK.QQK_OPERAC "
		cQuery +=   " AND QUERY_STATUS.QPM_ROTEIR = QQK.QQK_CODIGO "
		cQuery += " ON SH1.H1_CODIGO = QQK.QQK_RECURS "
		cQuery += " ON SAH.AH_UNIMED = QPK.QPK_UM "

		cQuery += " CROSS JOIN "
		cQuery +=   "(SELECT COALESCE( MAX(CASE "
		cQuery +=                         " WHEN QAA_NIVEL = NULL "
		cQuery += 							   " OR QAA_STATUS <> '1' "
		cQuery += 							   " OR (UPPER(RTRIM(QAA_LOGIN)) = '' ) "
		cQuery += 							   " THEN '.F.' "
		cQuery +=                         " ELSE '.T.' "
		cQuery +=                         " END), '.F.') Permitido "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=    " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "
		cQuery +=  " ) QAA "

		cQuery += " WHERE 1=1 "
		If Empty(cTextoOrig) .AND. Empty(cRecno) .AND. !lNaoIniciadas .AND. !lSemLaudos .AND. !lLaudosIncompletos
			cQuery += " AND COALESCE(QUERY_STATUS.QPM_LAUDO,  "
			cQuery +=         " (CASE AMOSTRAGENS.QPR_OP "
			cQuery +=             " WHEN NULL THEN 'N' "
			cQuery +=             " ELSE 'I' "
			cQuery +=         " END))  "
			cQuery +=    " NOT IN ('A','R','U', 'C') "
			cQuery += " AND QPK_SITOP NOT IN ('2','3','4','5','6') "

		ElseIf lNaoIniciadas 
			cQuery += " AND LAUDOS.CHAVE IS NULL "
			cQuery += " AND LAUDOS.CHAVE_OPERACAO IS NULL "
			cQuery += " AND (CASE QPK.QPK_SITOP "
			cQuery +=             " WHEN '2' THEN 'A' "
			cQuery +=             " WHEN '3' THEN 'R' "
			cQuery +=             " WHEN '4' THEN 'U' "
			cQuery +=             " WHEN '5' THEN 'C' "
			cQuery +=             " WHEN '6' THEN 'E' "
			cQuery +=             " ELSE "
			cQuery +=             " COALESCE (QUERY_STATUS.QPM_LAUDO, "
			cQuery +=                      " (CASE COALESCE (QPR_RESULT, "
			cQuery +=                                       "'N') "
			cQuery +=                           " WHEN 'N' THEN 'N' "
			cQuery +=                           " ELSE 'I' "
			cQuery +=                       " END))
			cQuery +=        " END) = 'N' "

		ElseIf lSemLaudos
			cQuery += " AND LAUDOS.CHAVE_OPERACAO IS NULL "
			cQuery += " AND (CASE QPK.QPK_SITOP "
			cQuery +=             " WHEN '2' THEN 'A' "
			cQuery +=             " WHEN '3' THEN 'R' "
			cQuery +=             " WHEN '4' THEN 'U' "
			cQuery +=             " WHEN '5' THEN 'C' "
			cQuery +=             " WHEN '6' THEN 'E' "
			cQuery +=             " ELSE "
			cQuery +=             " COALESCE (QUERY_STATUS.QPM_LAUDO, "
			cQuery +=                      " (CASE COALESCE (QPR_RESULT, "
			cQuery +=                                       "'N') "
			cQuery +=                           " WHEN 'N' THEN 'N' "
			cQuery +=                           " ELSE 'I' "
			cQuery +=                       " END))
			cQuery +=        " END) = 'I' "
			//cQuery += " AND (QPK_SITOP = '7') " //Desconsiderardo devido inconsistência nas bases
		EndIf

		cOrdemDB := Self:oAPIManager:RetornaOrdemDB(cOrdem,cTipoOrdem)
		If !Empty(cOrdemDB)
			cQuery += " ORDER BY " + cOrdemDB
		EndIf

		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)
		cAlias := Self:oQueryManager:executeQuery(cQuery)

	RECOVER
	END SEQUENCE
	ErrorBlock({|e| bErrorBlock })

Return cAlias

/*/{Protheus.doc} PesquisaLista
Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin      , caracter, login do usuário para validação das permissões de acesso
@param 02 - cLaboratorio, caracter, laboratório para filtro
@param 02 - cTexto      , caracter, texto para pesquisa nos campos de OP e Produto
@param 03 - cOrdem      , caracter, ordenação para retornar a listagem dos dados
@param 03 - cTipoOrdem  , caracter, tipo de ordenação para retornar a listagem dos dados (Ascencente ou Decrescente)
@param 04 - nPagina     , numérico, página atual dos dados para consulta
@param 05 - nTamPag     , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 06 - cCampos     , caracter, campos que deverão estar contidos na mensagem
@param 07 - cRecno      , caracter, recno do registro para filtro
@param 08 - cOperacao   , caracter, operacao da inspecao para filtro
@param 09 - lNaoIniciadas     , lógico, indica se realiza filtro de inspeções não iniciadas
@param 10 - lSemLaudos        , lógico, indica se realiza filtro de inspeções sem laudos
@param 11 - lLaudosIncompletos, lógico, indica se realiza filtro de inspeções com laudos incompletos
@return lRetorno, lógico, indica se conseguiu realizar o processamento
/*/
METHOD PesquisaLista(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos) CLASS InspecoesDeProcessosAPI
     
    Local cAlias      := Nil
    Local lRetorno    := .T.

	Default cRecno    := ""
	Default cOperacao := ""

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0006), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0007))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf

    cAlias := Self:CriaAliasPesquisa(cLogin, cLaboratorio, cTexto, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cRecno, cOperacao, lNaoIniciadas, lSemLaudos, lLaudosIncompletos)

	If cAlias == Nil .OR. Empty(cAlias)
		lRetorno := .F.
		Self:oAPIManager:RespondeValor("message", Self:oAPIManager:cErrorMessage, Self:oAPIManager:cErrorMessage, Self:oAPIManager:cDetailedMessage)
	Else	
		lRetorno := Self:oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
		(cAlias)->(dbCloseArea())
	EndIf

Return lRetorno

/*/{Protheus.doc} UsuarioExistente
Identifica se o usuário possui cadastro na QAA
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@return lRetorno, lógico, indica se o usuário é permitido
/*/
METHOD UsuarioExistente(cLogin) CLASS InspecoesDeProcessosAPI
     
    Local cAlias         := Nil
    Local cQuery         := Nil
    Local lRetorno       := .T.
    Local oExec          := Nil
	Local oQltAPIManager := QualityAPIManager():New(, Self:oWSRestFul)
	Local oResponse      := JsonObject()       :New()
	
	If oQltAPIManager:ValidaPrepareInDoAmbiente()

		cQuery :=   "SELECT COALESCE( MAX(CASE "
		cQuery +=                         " WHEN QAA_NIVEL = NULL "
		cQuery += 							   " OR QAA_STATUS <> '1' "
		cQuery += 							   " OR (UPPER(RTRIM(QAA_LOGIN)) = '' ) "
		cQuery += 							   " THEN 'false' "
		cQuery +=                         " ELSE 'true' "
		cQuery +=                         " END), 'false') Permitido "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=    " AND (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=    " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		oResponse['exist'        ] := Alltrim((cAlias)->Permitido )
		oResponse['hasNext'      ] := .F.
		(cAlias)->(dbCloseArea())

		Self:oWSRestFul:SetContentType("application/json")

		//Processou com sucesso.
		HTTPSetStatus(200)
		oResponse['code'         ] := 200
		Self:oWSRestFul:SetResponse(EncodeUtf8(oResponse:toJson()))
	EndIf

Return lRetorno

/*/{Protheus.doc} NaoImplantado
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@return lNaoImplantado, lógico, indica se o módulo QIP não está implantado
/*/
METHOD NaoImplantado() CLASS InspecoesDeProcessosAPI
	Local lNaoImplantado := Nil
	If (AlLTrim(SuperGetMV("MV_QIPMAT", .F., "N")) == "S")
		lNaoImplantado := .F.
	Else
		DbSelectArea("QPK")
		QPK->(DbSetOrder(1))
		QPK->(DbSeek(xFilial("QPK")))
		lNaoImplantado := QPK->(Eof())
	EndIf
Return lNaoImplantado


/*/{Protheus.doc} RetornaContagemCards
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@param 01 - cLogin      , caracter, login de usuário relacionado
@param 02 - cTexto      , caracter, texto de pesquisa
@param 03 - cLaboratorio, caracter, laboratório de filtro
@return oRetorno, JsonObject, objeto json com os dados para retorno
		oRetorno['notStarted']        = Inspeções não iniciadas
		oRetorno['withoutReport']     = Inspeções sem laudos
		oRetorno['incompleteReports'] = Inspeções com laudos incompletos
/*/
METHOD RetornaContagemCards(cLogin, cTexto, cLaboratorio) CLASS InspecoesDeProcessosAPI
	
	Local bErrorBlock := Nil
	Local cAlias      := Nil
    Local cQuery      := Nil
	Local cTextoOrig  := cTexto
    Local oExec       := Nil
	Local oRetorno    := JsonObject():New()

	Default cTexto       := ""
	Default cLaboratorio := ""

	Self:oAPIManager := QualityAPIManager():New(Nil, Self:oWSRestFul)
	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
	
	BEGIN SEQUENCE
		cTexto := FwQtToChr(cTexto)

		cQuery := " SELECT "
		cQuery += 	" SUM( "
		cQuery += 	    " ( "
		cQuery += 	      " CASE UNIAO.INSPECOES WHEN 'X' THEN 0 ELSE  "
		cQuery += 	 	    " (CASE UNIAO.LAUDO WHEN 'X' THEN  "
		cQuery += 	 	       " (CASE UNIAO.AMOSTRAS WHEN 'X' THEN "
		cQuery += 	 	          " (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 1 ELSE 0 END) "
		cQuery +=               " ELSE 0 END) "
		cQuery += 	 	     " ELSE 0 END) "
		cQuery += 	 	 " END "
		cQuery += 	    " ) "
		cQuery += 	  " ) NAO_INICIADA, "

		cQuery += 	" SUM(CASE UNIAO.AMOSTRAS
		cQuery +=       " WHEN 'X' THEN 0 "
		cQuery +=       " ELSE (CASE UNIAO.LAUDO WHEN 'X' THEN  "
		cQuery +=			   " (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN  "
		cQuery +=				   " (CASE QPK_SITOP WHEN ' ' THEN 0 ELSE 1 END) "
		cQuery +=			    " ELSE 0 END) "
		cQuery +=            " ELSE 0 END) "
		cQuery +=     " END) SEM_LAUDO, "

		cQuery += 	" (CASE WHEN SUM(CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - SUM(CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) > 0 "
		cQuery += 	      " THEN SUM(CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - SUM(CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) "
		cQuery += 	 " ELSE 0 END) INCOMPLETO "

		cQuery += " FROM "
		cQuery += 	   " (SELECT DISTINCT "
		cQuery +=              " COALESCE(COALESCE(AMOSTRAS.CHAVE_OPERACAO, COALESCE(LAUDO.CHAVE_OPERACAO, LAUDO_GERAL.CHAVE_INSPECAO)), INSPECOES.CHAVE_INSPECAO) CHAVE, "
		cQuery +=              " INSPECOES.QPK_SITOP, "
		cQuery +=              " COALESCE(INSPECOES.CHAVE_OPERACAO, 'X') INSPECOES, "
		cQuery +=              " COALESCE(AMOSTRAS.CHAVE_OPERACAO, 'X') AMOSTRAS, "
		cQuery +=              " COALESCE(LAUDO.CHAVE_OPERACAO, 'X') LAUDO, "
		cQuery +=              " COALESCE(LAUDO_GERAL.CHAVE_INSPECAO, 'X') LAUDO_GERAL "
		cQuery +=       " FROM  "


		cQuery += " (SELECT "
		cQuery +=   " CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO) CHAVE_INSPECAO, "
		cQuery +=   " CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC) CHAVE_OPERACAO, QPK_SITOP "
		cQuery += " FROM (SELECT DISTINCT QPK.QPK_PRODUT, QPK.QPK_OP, QQK.QQK_CODIGO, QQK.QQK_OPERAC, QPK.QPK_LOTE, QPK.QPK_NUMSER, QPK.QPK_REVI, QPK.QPK_SITOP "
		cQuery +=       " FROM (SELECT QPK_PRODUT, QPK_OP, QPK_LOTE, QPK_NUMSER, QPK_REVI, QPK_SITOP "
		cQuery +=             " FROM " + RetSQLName("QPK")
		cQuery +=             " WHERE (D_E_L_E_T_ = ' ') "
		If !Empty(cTextoOrig)
			cQuery +=         " AND (    (UPPER(QPK_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
			cQuery +=               " OR (UPPER(QPK_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
		EndIf
		cQuery +=               " AND (QPK_FILIAL = '" + xFilial("QPK") + "') ) QPK "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario .OR. !Empty(cLaboratorio) //Filtro de Laboratórios - INSPECOES
			cQuery += " INNER JOIN "
			cQuery += " (SELECT QP8_PRODUT AS PRODUTO, QP8_REVI AS REVISAO, QP8_CODREC, QP8_OPERAC, QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP8") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP8_FILIAL = '" + xFilial("QP8") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP8_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cLogin)
			cQuery += " UNION "
			cQuery += " SELECT QP7_PRODUT, QP7_REVI, QP7_CODREC, QP7_OPERAC, QP7_LABOR "
			cQuery += " FROM " + RetSQLName("QP7") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP7_FILIAL = '" + xFilial("QP7") + "') "
			If !Empty(cLaboratorio)
				cQuery += " AND (QP7_LABOR = '" + cLaboratorio + "') "
			EndIf
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cLogin)
			cQuery += " ) FILTROLAB ON QPK.QPK_PRODUT = FILTROLAB.PRODUTO "
			cQuery +=            " AND QPK.QPK_REVI   = FILTROLAB.REVISAO "
		EndIf
		
		cQuery +=             " INNER JOIN (SELECT QQK_CODIGO, QQK_OPERAC, QQK_PRODUT, QQK_REVIPR "
		cQuery +=             " FROM " + RetSQLName("QQK")
		cQuery +=             " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=               " AND (QQK_FILIAL = '" + xFilial("QQK") + "')) QQK "
		cQuery +=             " ON    QPK.QPK_REVI = QQK.QQK_REVIPR "
		cQuery +=             " AND QPK.QPK_PRODUT = QQK.QQK_PRODUT "

		If Empty(cTextoOrig)
			cQuery +=         " AND QPK.QPK_SITOP NOT IN ('2','3','4','5') "
		EndIf

		cQuery +=             " INNER JOIN (SELECT CONCAT(CONCAT(C2_NUM, C2_ITEM), C2_SEQUEN) C2_OP, C2_ROTEIRO "
		cQuery +=                         " FROM " + RetSQLName("SC2")
		cQuery +=                         " WHERE (D_E_L_E_T_ = ' ') "
		If !Empty(cTextoOrig)
			cQuery +=                     " AND (    (UPPER(C2_PRODUTO) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
			cQuery +=                           " OR (UPPER(CONCAT(CONCAT(C2_NUM, C2_ITEM), C2_SEQUEN)) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
		EndIf
		cQuery +=                         " AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
		cQuery +=             " ON C2_OP = QPK_OP "
		cQuery +=             " AND C2_ROTEIRO = QQK_CODIGO) DADOS) INSPECOES "



		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=   " CONCAT(CONCAT(CONCAT(QPR_OP, QPR_LOTE), QPR_NUMSER), QPR_ROTEIR) CHAVE_INSPECAO, "
		cQuery +=   " CONCAT(CONCAT(CONCAT(CONCAT(QPR_OP, QPR_LOTE), QPR_NUMSER), QPR_ROTEIR), QPR_OPERAC) CHAVE_OPERACAO "
		cQuery += " FROM " + RetSQLName("QPR")
		cQuery += " WHERE (D_E_L_E_T_ = ' ') "
		If !Empty(cTextoOrig)
			cQuery += " AND (    (UPPER(QPR_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
			cQuery +=       " OR (UPPER(QPR_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
		EndIf
		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf
		cQuery += " AND (QPR_FILIAL = '" + xFilial("QPR") + "') " + ") AMOSTRAS "
		cQuery +=   " ON AMOSTRAS.CHAVE_OPERACAO = INSPECOES.CHAVE_OPERACAO "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " CHAVE_INSPECAO, CHAVE_OPERACAO "
		cQuery +=            " FROM (SELECT DISTINCT "
		cQuery +=                         " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO, "
		cQuery +=                         " CONCAT(CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR), QPL_OPERAC) CHAVE_OPERACAO "
		cQuery +=                  " FROM " + RetSQLName("QPL")
		cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=                    " AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
		cQuery +=                    " AND (QPL_LAUDO <> ' ') "
		cQuery +=                    " AND (QPL_OPERAC <> ' ') "
		If !Empty(cTextoOrig)
			cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
			cQuery +=         " OR (UPPER(QPL_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
		EndIf
		cQuery +=                  " UNION "
		cQuery +=                  " SELECT DISTINCT "
		cQuery +=                         " CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR) CHAVE_INSPECAO, "
		cQuery +=                         " CONCAT(CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR), QPM_OPERAC) CHAVE_OPERACAO "
		cQuery +=                  " FROM " + RetSQLName("QPM")
		cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=                    " AND (QPM_LAUDO <> ' ') "
		cQuery +=                    " AND (QPM_OPERAC <> ' ') "
		If !Empty(cTextoOrig)
			cQuery +=              " AND (    (UPPER(QPM_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
			cQuery +=                    " OR (UPPER(QPM_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
		EndIf
		cQuery +=                  " AND (QPM_FILIAL = '" + xFilial("QPM") + "') " + ") LAUDOS) LAUDO "
		cQuery += " ON LAUDO.CHAVE_OPERACAO = INSPECOES.CHAVE_OPERACAO "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO "
		cQuery +=       " FROM " + RetSQLName("QPL")
		cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=       "   AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
		cQuery +=       "   AND (QPL_LAUDO <> ' ') "
		If !Empty(cTextoOrig)
			cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
			cQuery +=         " OR (UPPER(QPL_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
		EndIf
		cQuery +=       "   AND (QPL_LABOR = ' ') "
		cQuery +=       "   AND (QPL_OPERAC = ' ')) LAUDO_GERAL "
		cQuery += " ON LAUDO_GERAL.CHAVE_INSPECAO = INSPECOES.CHAVE_INSPECAO ) UNIAO "


		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)

		oExec       := FwExecStatement():New(cQuery)
		cAlias      := oExec:OpenAlias()
		oRetorno['notStarted']        := (cAlias)->NAO_INICIADA
		oRetorno['withoutReport']     := (cAlias)->SEM_LAUDO
		oRetorno['incompleteReports'] := (cAlias)->INCOMPLETO
		(cAlias)->(dbCloseArea())
	RECOVER
	END SEQUENCE

	ErrorBlock(bErrorBlock)

	Self:oAPIManager:RespondeJson(oRetorno)

Return 

/*/{Protheus.doc} RetornaQueryFiltroCardLaudoIncompleto
Retorna Query para Filtro doo CARD Laudo Incompleto
@author brunno.costa
@since  16/08/2022
@param 01 - cLogin      , caracter, login de usuário relacionado
@param 02 - cTexto      , caracter, texto de pesquisa
@param 03 - cLaboratorio, caracter, laboratório de filtro
@return cQuery, caracter, string de filtro dos status de CARDS
/*/
METHOD RetornaQueryFiltroCardLaudoIncompleto(cLogin, cTexto, cLaboratorio) CLASS InspecoesDeProcessosAPI
	
	Local cQuery         := ""
	Local cTextoOrig     := cTexto

	Default cTexto       := ""
	Default cLaboratorio := ""

	cQuery := " SELECT DISTINCT "
	cQuery += 	" CHAVE, "
	cQuery += 	" CHAVE_OPERACAO "
	cQuery += " FROM (SELECT "
	cQuery +=              " COALESCE(LAUDO.CHAVE_INSPECAO, LAUDO_GERAL.CHAVE_INSPECAO) CHAVE, "
	cQuery +=              " LAUDO.CHAVE_OPERACAO, "
	cQuery +=              " COALESCE(LAUDO.CHAVE_INSPECAO, 'X') LAUDO, "
	cQuery +=              " COALESCE(LAUDO_GERAL.CHAVE_INSPECAO, 'X') LAUDO_GERAL "
	cQuery +=       " FROM (SELECT DISTINCT "
	cQuery +=                    " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO "
	cQuery +=       " FROM " + RetSQLName("QPL")
	cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=       "   AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
	cQuery +=       "   AND (QPL_LAUDO <> ' ') "
	If !Empty(cTextoOrig)
		cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
		cQuery +=         " OR (UPPER(QPL_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
	EndIf
	cQuery +=       "   AND (QPL_LABOR = ' ') "
	cQuery +=       "   AND (QPL_OPERAC = ' ')) LAUDO_GERAL "
	

	cQuery += " FULL JOIN (SELECT DISTINCT "
	cQuery +=                   " CHAVE_INSPECAO, "
	cQuery +=                   " CHAVE_OPERACAO "
	cQuery +=            " FROM (SELECT DISTINCT "
	cQuery +=                         " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO, "
	cQuery +=                         " CONCAT(CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR), QPL_OPERAC) CHAVE_OPERACAO "
	cQuery +=                  " FROM " + RetSQLName("QPL")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                    " AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
	cQuery +=                    " AND (QPL_LAUDO <> ' ') "
	If !Empty(cTextoOrig)
		cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
		cQuery +=         " OR (UPPER(QPL_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
	EndIf
	cQuery +=                  " UNION "
	cQuery +=                  " SELECT DISTINCT "
	cQuery +=                         " CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR) CHAVE_INSPECAO, "
	cQuery +=                         " CONCAT(CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR), QPM_OPERAC) CHAVE_OPERACAO "
	cQuery +=                  " FROM " + RetSQLName("QPM") 
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                    " AND (QPM_LAUDO <> ' ') "
	If !Empty(cTextoOrig)
		cQuery +=              " AND (    (UPPER(QPM_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
		cQuery +=                    " OR (UPPER(QPM_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
	EndIf
	cQuery +=                  " AND (QPM_FILIAL = '" + xFilial("QPM") + "') " + ") LAUDOS) LAUDO "
	cQuery += " ON LAUDO.CHAVE_INSPECAO = LAUDO_GERAL.CHAVE_INSPECAO ) UNIAO "

	cQuery += " WHERE (CASE WHEN (CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) > 0 "
	cQuery +=             " THEN (CASE UNIAO.LAUDO WHEN 'X' THEN 0 ELSE 1 END) - (CASE UNIAO.LAUDO_GERAL WHEN 'X' THEN 0 ELSE 1 END) "
	cQuery +=        " ELSE 0 END) = 1 "//Filtra Laudos Incompletos

Return cQuery


/*/{Protheus.doc} RetornaQueryFiltroCardSemLaudos
Retorna Query para Filtro doo CARD Laudo Incompleto
@author brunno.costa
@since  16/08/2022
@param 01 - cLogin      , caracter, login de usuário relacionado
@param 02 - cTexto      , caracter, texto de pesquisa
@param 03 - cLaboratorio, caracter, laboratório de filtro
@return cQuery, caracter, string de filtro dos status de CARDS
/*/
METHOD RetornaQueryFiltroCardSemLaudos(cLogin, cTexto, cLaboratorio) CLASS InspecoesDeProcessosAPI
	
	Local cQuery         := ""
	Local cTextoOrig     := cTexto

	Default cTexto       := ""
	Default cLaboratorio := ""

	cQuery := " SELECT  "
	cQuery += 	" DISTINCT CHAVE, CHAVE_OPERACAO "
	cQuery += " FROM (SELECT "
	cQuery +=              " COALESCE(LAUDO.CHAVE_INSPECAO, LAUDO_GERAL.CHAVE_INSPECAO) CHAVE, "
	cQuery +=              " LAUDO.CHAVE_OPERACAO, "
	cQuery +=              " COALESCE(LAUDO.CHAVE_INSPECAO, 'X') LAUDO, "
	cQuery +=              " COALESCE(LAUDO_GERAL.CHAVE_INSPECAO, 'X') LAUDO_GERAL "
	cQuery +=       " FROM (SELECT DISTINCT "
	cQuery +=                    " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO "
	cQuery +=       " FROM " + RetSQLName("QPL")
	cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=       "   AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
	cQuery +=       "   AND (QPL_LAUDO <> ' ') "
	If !Empty(cTextoOrig)
		cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
		cQuery +=         " OR (UPPER(QPL_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
	EndIf
	cQuery +=       "   AND (QPL_LABOR = ' ') "
	cQuery +=       "   AND (QPL_OPERAC = ' ')) LAUDO_GERAL "
	

	cQuery += " FULL JOIN (SELECT DISTINCT "
	cQuery +=                   " CHAVE_INSPECAO, CHAVE_OPERACAO "
	cQuery +=            " FROM (SELECT DISTINCT "
	cQuery +=                    " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO, "
	cQuery +=                         " CONCAT(CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR), QPL_OPERAC) CHAVE_OPERACAO "
	cQuery +=                  " FROM " + RetSQLName("QPL")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                    " AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
	cQuery +=                    " AND (QPL_LAUDO <> ' ') "
	cQuery +=                    " AND (QPL_OPERAC <> ' ') "
	If !Empty(cTextoOrig)
		cQuery +=   " AND (    (UPPER(QPL_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
		cQuery +=         " OR (UPPER(QPL_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
	EndIf
	cQuery +=                  " UNION "
	cQuery +=                  " SELECT DISTINCT "
	cQuery +=                         " CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR) CHAVE_INSPECAO, "
	cQuery +=                         " CONCAT(CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR), QPM_OPERAC) CHAVE_OPERACAO "
	cQuery +=                  " FROM " + RetSQLName("QPM")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                    " AND (QPM_LAUDO <> ' ') "
	cQuery +=                    " AND (QPM_OPERAC <> ' ') "
	If !Empty(cTextoOrig)
		cQuery +=              " AND (    (UPPER(QPM_PRODUT) LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) "  
		cQuery +=                    " OR (UPPER(QPM_OP)     LIKE CONCAT(CONCAT('%' , UPPER("+cTexto+")) , '%')) ) "
	EndIf
	cQuery +=                  " AND (QPM_FILIAL = '" + xFilial("QPM") + "') " + ") LAUDOS) LAUDO "
	cQuery += " ON LAUDO.CHAVE_INSPECAO = LAUDO_GERAL.CHAVE_INSPECAO ) UNIAO "

Return cQuery

