#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "EnsaiosInspecaoDeProcessosAPI.CH"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} processinspectiontest
API de Ensaio de Inspeção de Processos - Qualidade
@author rafael.hesse
@since  31/05/2022
/*/
WSRESTFUL processinspectiontest DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaio de Inspeção de Processos"

    WSDATA Fields      as STRING OPTIONAL
	WSDATA IDEnsaio    as STRING OPTIONAL
	WSDATA Laboratory  as STRING OPTIONAL
	WSDATA Login       as STRING OPTIONAL
	WSDATA OperationID as STRING OPTIONAL
    WSDATA Order       as STRING OPTIONAL
	WSDATA OrderType   as STRING OPTIONAL
    WSDATA Page        as INTEGER OPTIONAL
    WSDATA PageSize    as INTEGER OPTIONAL
    WSDATA Recno       as STRING OPTIONAL

    WSMETHOD GET list;
    DESCRIPTION STR0002; //"Retorna Lista de Ensaios de Inspeções de Processos"
    WSSYNTAX "api/qip/v1/list/{Recno}/{OperationID}/{Order}/{OrderType}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/list" ;
    TTALK "v1"

	WSMETHOD GET test;
    DESCRIPTION STR0003; //"Retorna um Ensaio da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/test/{Recno}/{OperationID}/{IDEnsaio}" ;
    PATH "/api/qip/v1/test" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET list PATHPARAM Recno, OperationID, Laboratory, Order, OrderType, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontest
    Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:Fields      := ""
	Default Self:Laboratory  := ""
	Default Self:Login       := ""
	Default Self:OperationID := ""
	Default Self:Order       := ""
	Default Self:OrderType   := ""
	Default Self:Page        := 1
	Default Self:PageSize    := 5
	Default Self:Recno       := 0
	oAPIClass:cEndPoint := "/api/qip/v1/list"
Return oAPIClass:RetornaLista(Self:Recno, Self:OperationID, Self:Laboratory, Self:Order, Self:OrderType, Self:Page, Self:PageSize, Self:Fields, Nil, Self:Login)

WSMETHOD GET test PATHPARAM Recno, OperationID, Laboratory, IDEnsaio QUERYPARAM Fields WSSERVICE processinspectiontest
    Local oAPIClass  := EnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:Fields     := ""
	Default Self:IDEnsaio   := ""
	Default Self:Login      := ""
	Default Self:OperationID := ""
	Default Self:Recno      := 0
	oAPIClass:cEndPoint := "/api/qip/v1/test"
Return oAPIClass:RetornaLista(Self:Recno, Self:OperationID, Self:Laboratory, "", "", 1, 1, Self:Fields, Self:IDEnsaio, Self:Login)

/*/{Protheus.doc} EnsaiosInspecaoDeProcessosAPI
Regras de Negocio - API Ensaios de Inspeção de Processos
@author rafael.hesse
@since  31/05/2022
/*/
CLASS EnsaiosInspecaoDeProcessosAPI FROM LongNameClass
    
	DATA cEndPoint        as STRING
	DATA oAPIManager      as OBJECT
	DATA oQueryManager    as OBJECT
	DATA oWSRestFul       as OBJECT

    METHOD new(oWSRestFul) CONSTRUCTOR
	METHOD CriaAliasEnsaiosPesquisa(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
    METHOD RetornaLista(nRecno, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
     
    //Métodos Internos
    METHOD MapeiaCampos(cCampos)
	METHOD NaoImplantado()
	METHOD RetornaFiltroPELaboratoriosRelacionadosAoUsuario(cCampo, cUsuario)
ENDCLASS

METHOD new(oWSRestFul) CLASS EnsaiosInspecaoDeProcessosAPI
	 Self:oWSRestFul    := oWSRestFul
	 Self:oQueryManager := QLTQueryManager():New()
Return Self

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos
@author rafael.hesse
@since  01/06/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCampos(cCampos) CLASS EnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

   	aadd(aMapaCampos, {.T., "RecnoInspecao"        , "recnoInspection"     , "RECNOQPK"            , "NN", 0                                      , 0, "QPK"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "RecnoEnsaio"          , "recnoTest"           , "RECNOTEST"           , "NN", 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "Ensaio"               , "testID"              , "QP7_ENSAIO"          , "C" , 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.T., "Sequencia"            , "sequence"            , "QP7_SEQLAB"          , "NN", 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aadd(aMapaCampos, {.T., "Obrigatorio"          , "obrigatory"          , "ENSOBRI"             , "LL", 0                                      , 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
    aadd(aMapaCampos, {.F., "Titulo"               , "title"               , "QP1_DESCPO"          , "C" , GetSx3Cache("QP1_DESCPO" ,"X3_TAMANHO"), 0, "QP1"})
    aAdd(aMapaCampos, {.F., "QuantidadeMedicoes"   , "numberOfMeasurements", "QP1_QTDE"            , "N" , GetSx3Cache("QP1_QTDE"   ,"X3_TAMANHO"), 0, "QP1"})
	aadd(aMapaCampos, {.F., "Tipo"                 , "type"                , "QP1_TIPO"            , "C" , GetSx3Cache("QP1_TIPO"   ,"X3_TAMANHO"), 0, "QP1"})
    aadd(aMapaCampos, {.F., "Laboratorio"          , "laboratory"          , "X5_DESCRI"           , "C" , GetSx3Cache("X5_DESCRI"  ,"X3_TAMANHO"), 0, "SX5"})
	aadd(aMapaCampos, {.F., "IDLaboratorio"        , "laboratoryID"        , "X5_CHAVE"            , "C" , GetSx3Cache("X5_CHAVE"   ,"X3_TAMANHO"), 0, "SX5"})
    aadd(aMapaCampos, {.F., "EspecificacaoResumida", "summarySpecification", "SUMMARYSPECIFICATION", "C" , 20                                     , 0, "N/A"})
    aadd(aMapaCampos, {.F., "UnidadeDeMedida"      , "lotUnitID"           , "QP7_UNIMED"          , "C" , 2                                      , 0, "N/A"})
    aadd(aMapaCampos, {.F., "TipoDeControle"       , "controlType"         , "CONTROLTYPE"         , "C" , 1                                      , 0, "N/A"})
    aadd(aMapaCampos, {.F., "ValorNominal"         , "nominalValue"        , "QP7_NOMINA"          , "C" , GetSx3Cache("QP7_NOMINA" ,"X3_TAMANHO"), 0, "N/A"})
	aadd(aMapaCampos, {.F., "AfastamentoInferior"  , "lowerDeviation"      , "QP7_LIE"             , "C" , GetSx3Cache("QP7_LIE" ,"X3_TAMANHO")   , 0, "N/A"})
    aadd(aMapaCampos, {.F., "AfastamentoSuperior"  , "upperDeviation"      , "QP7_LSE"             , "C" , GetSx3Cache("QP7_LSE" ,"X3_TAMANHO")   , 0, "N/A"})
	aadd(aMapaCampos, {.F., "Operação"             , "operationID"         , "QP7_OPERAC"          , "C" , GetSx3Cache("QP7_OPERAC" ,"X3_TAMANHO"), 0, "N/A"})
    aadd(aMapaCampos, {.T., "TipoEnsaio"           , "testType"            , "TIPO"                , "V" , 1                                      , 0, "N/A"})
	aadd(aMapaCampos, {.T., "LaudoLaboratorio"     , "laboratoryReport"    , "QPL_LAUDO"           , "C" , GetSx3Cache("QPL_LAUDO" ,"X3_TAMANHO") , 0, "QPL"})
    aadd(aMapaCampos, {.T., "Status"               , "status"              , "STATUS"              , "C" , 1                                      , 0, "N/A"})
	
	Self:oAPIManager := QualityAPIManager():New(aMapaCampos, Self:oWSRestFul)
	Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos


/*/{Protheus.doc} CriaAliasEnsaiosPesquisa
Cria Alias para Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author rafael.hesse
@since  31/05/2022
@param 01 - nRecno      , numérico, R_E_C_N_O_ para buscar informações da tabela QPK
@param 02 - cOperacao   , numérico, R_E_C_N_O_ para buscar informações da tabela QPK
@param 03 - cLaboratorio, caracter, código do laboratório para filtro
@param 04 - cOrdem      , caracter, ordenação para retornar a listagem dos dados
@param 05 - cTipoOrdem  , caracter, tipo de ordenação para retornar a listagem dos dados (Ascedente ou Decrescente)
@param 06 - nPagina     , numérico, página atual dos dados para consulta
@param 07 - nTamPag     , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 08 - cCampos     , caracter, campos que deverão estar contidos na mensagem
@param 09 - cIDEnsaio   , caracter, código do ensaio
@param 10 - cUsuario    , caracter, código do usuário consumindo a API
@return cAlias, caracter, alias com os dados da Lista
/*/
METHOD CriaAliasEnsaiosPesquisa(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario) CLASS EnsaiosInspecaoDeProcessosAPI
	
	Local bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), Break(e)})
    Local cAlias      := Nil
	Local cOrdemDB    := Nil
    Local cQuery      := ""

    Begin Sequence

		Self:MapeiaCampos(cCampos)
		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario()

		//Ensaios do tipo Numérico
		cQuery +=  " SELECT RECNOQPK, "
		cQuery +=         " RECNOTEST, "
		cQuery +=         " QP7_ENSAIO, "
		cQuery +=         " QP7_SEQLAB, "
		cQuery += 		  " CONTROLTYPE, "
		cQuery += 		  " QP7_NOMINA, "
		cQuery += 		  " QP7_LIE, "
		cQuery += 		  " QP7_LSE, "
		cQuery += 		  " QP7_OPERAC, "
		cQuery += 		  " ENSOBRI, "
		cQuery +=         " QP1_DESCPO, "
		cQuery +=         " QP1_TIPO, "
		cQuery += 		  " QP1_QTDE, "
		cQuery +=         " X5_CHAVE, "
		cQuery +=         " X5_DESCRI, "
		cQuery +=         " SUMMARYSPECIFICATION, "
		cQuery += 		  " QP7_UNIMED, "
		cQuery +=         " (CASE COALESCE(QPR_RESULT,'') "
		cQuery += 				" WHEN '' "
		cQuery += 				" THEN ( "
		cQuery += 						" CASE ENSOBRI " 
		cQuery += 							" WHEN 'N' "
		cQuery += 							" THEN 'N' "
		cQuery += 						" ELSE 'P' END )  " 
		cQuery +=         " ELSE QPR_RESULT "
		cQuery +=         " END ) STATUS, "
		cQuery +=         " COALESCE(QPL_LAUDO, '') QPL_LAUDO, "
		cQuery +=         " TIPO "
		cQuery +=  " FROM "
		cQuery +=  " (SELECT "
		cQuery +=      " QPK.R_E_C_N_O_ RECNOQPK, "
		cQuery +=      " QP7.R_E_C_N_O_ RECNOTEST, "
		cQuery +=      " QP7.QP7_ENSAIO, "
		cQuery +=      " QP7.QP7_SEQLAB, "
		cQuery +=      " QP7.CONTROLTYPE, "
		cQuery +=      " QP7.QP7_NOMINA, "
		cQuery +=      " (CASE WHEN QP7.QP7_MINMAX = '1' OR QP7.QP7_MINMAX = '2' THEN QP7.QP7_LIE ELSE 'n/c' END) QP7_LIE, "
		cQuery +=      " (CASE WHEN QP7.QP7_MINMAX = '1' OR QP7.QP7_MINMAX = '3' THEN QP7.QP7_LSE ELSE 'n/c' END) QP7_LSE, "
		cQuery +=      " QP7.QP7_OPERAC, "
		cQuery +=      " QP7.QP7_UNIMED, "
		cQuery +=      " COALESCE(QP1.QP1_DESCPO, '') QP1_DESCPO, "
		cQuery +=      " COALESCE(QP1.QP1_TIPO, '') QP1_TIPO, "
		cQuery +=	   " COALESCE(QP1.QP1_QTDE, 1) QP1_QTDE, "
		cQuery +=      " COALESCE(SX5.X5_CHAVE, '') X5_CHAVE, "
		cQuery +=      " COALESCE(SX5.X5_DESCRI, '') X5_DESCRI, "
		cQuery +=      " CONCAT(CONCAT(( "
		cQuery +=          " CASE "
		cQuery +=              " WHEN QP7.QP7_MINMAX = '2' "                                                                                // Controla mínimo
		cQuery += 				"	THEN CONCAT(CONCAT(RTRIM(QP7.QP7_NOMINA) , ' ') , RTRIM(QP7.QP7_LIE)) " // Exemplo: 20 -1 cm
		cQuery +=              " WHEN QP7.QP7_MINMAX = '3' "                                                                                // Controla máximo
		cQuery +=  				"	THEN CONCAT(CONCAT(RTRIM(QP7.QP7_NOMINA) , ' ' ), RTRIM(QP7.QP7_LSE)) " // Exemplo: 20 5 cm
		cQuery +=              " ELSE "                                                                                                     // Controla mínimo e máximo
		cQuery += 				"	CONCAT(CONCAT(CONCAT(CONCAT(RTRIM(QP7.QP7_NOMINA) , ' ' ), RTRIM(QP7.QP7_LIE)) , '/' ), RTRIM(QP7.QP7_LSE))  " // Exemplo: 20 -1/5 cm
		cQuery +=          " END "
		cQuery +=      " ) , ' ') , QP7.QP7_UNIMED) SUMMARYSPECIFICATION, "
		cQuery +=      " QP7.QP7_ENSOBR ENSOBRI, "
		cQuery +=      " QPL_LAUDO, "
		cQuery +=      " QPR_RESULT, "
		cQuery +=       "'N' TIPO "
		cQuery +=  " FROM "
		cQuery +=      " (SELECT "
		cQuery +=              " X5_CHAVE, "
		cQuery +=              " X5_DESCRI "
		cQuery +=          " FROM " + RetSqlName("SX5")
		cQuery +=          " WHERE "
		cQuery +=              " (D_E_L_E_T_ = ' ') "
		cQuery +=              " AND (X5_FILIAL = '" + xFilial("SX5") +"') " 
		cQuery +=              " AND (X5_TABELA = 'Q2') "

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("X5_CHAVE", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery +=           " AND (X5_CHAVE = '" + cLaboratorio + "') "
		EndIf

		cQuery +=       " ) SX5 "
		cQuery += 		" RIGHT OUTER JOIN "
		cQuery +=       " ( SELECT	"
		cQuery +=              " QPK_PRODUT, "
		cQuery +=              " QPK_REVI, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QPK_LAUDO,	"
		cQuery +=              " QPK_LOTE, "
		cQuery +=              " QPK_NUMSER, "
		cQuery +=              " QPK_OP "
		cQuery +=          " FROM	" + RetSqlName("QPK")
		cQuery +=          " WHERE "
		cQuery +=              " (D_E_L_E_T_ = ' ') "
		cQuery += 			   " AND (QPK_FILIAL = '" + xFilial("QPK") +"') " 
		cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecno) +") " 
		cQuery +=       " ) QPK "
		cQuery +=       " INNER JOIN  "
		cQuery +=       " ( SELECT "
		cQuery +=              " QP7_PRODUT, "
		cQuery +=              " QP7_REVI, "
		cQuery +=              " QP7_ENSAIO, "
		cQuery +=              " QP7_LABOR, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QP7_NOMINA, "
		cQuery +=              " QP7_LIE, "
		cQuery +=              " QP7_LSE, "
		cQuery +=              " QP7_UNIMED, "
		cQuery +=              " QP7_MINMAX, "
		cQuery +=              " QP7_ENSOBR, "
		cQuery +=              " QP7_SEQLAB, "
		cQuery += 			   " QP7_MINMAX CONTROLTYPE, "
		cQuery += 			   " QP7_CODREC, "
		cQuery += 			   " QP7_OPERAC "
		cQuery +=          " FROM " + RetSqlName("QP7")
		cQuery +=          " WHERE "
		cQuery +=              " (D_E_L_E_T_ = ' ') "
		cQuery +=              " AND (QP7_FILIAL = '" + xFilial("QP7") +"') " 

		If !Empty(cOperacao)
			cQuery +=          " AND (QP7_OPERAC = '" + cOperacao +"') " 
		EndIf

		If !Empty(cIDEnsaio)
			cQuery +=          " AND (QP7_ENSAIO = '" + cIDEnsaio +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=          Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QP7_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=      	 " ) QP7 ON QP7.QP7_PRODUT = QPK.QPK_PRODUT "
		cQuery +=      		  " AND QP7.QP7_REVI = QPK.QPK_REVI "		

		cQuery +=        " INNER JOIN "
		cQuery +=          "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM ), C2_SEQUEN) C2_OP, "
		cQuery +=                 " C2_ROTEIRO "
		cQuery +=          " FROM " + RetSQLName("SC2") + " "
		cQuery +=          " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
		cQuery +=        " ON C2_OP = QPK_OP "
		cQuery +=          " AND C2_ROTEIRO = QP7_CODREC "

		cQuery +=      	 " LEFT OUTER JOIN "
		cQuery +=		 " (SELECT DISTINCT COALESCE(R.ENSAIO, A.ENSAIO) ENSAIO, "
		cQuery +=	           " COALESCE(R.QPR_ROTEIR, A.QPR_ROTEIR) QPR_ROTEIR, "
		cQuery +=	           " COALESCE(R.QPR_OPERAC, A.QPR_OPERAC) QPR_OPERAC, "
		cQuery +=              " COALESCE (R.QPR_RESULT, A.QPR_RESULT) QPR_RESULT "
		cQuery +=		   " FROM
		cQuery +=		       " (SELECT DISTINCT CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPR_OP, QPR_PRODUT), QPR_LOTE), QPR_LABOR), QPR_ENSAIO), QPR_ROTEIR), QPR_OPERAC) ENSAIO, "
		cQuery +=		 	   		   " QPR_ROTEIR, "
		cQuery +=		 	   		   " QPR_OPERAC, "
		cQuery +=		 	   		   " QPR_RESULT "
		cQuery +=		 	    " FROM " + RetSqlName("QPR")
		cQuery +=		   	    " WHERE (D_E_L_E_T_ = ' ') "
		cQuery += 			 		  " AND (QPR_FILIAL = '" + xFilial("QPR") + "') "

		If !Empty(cOperacao)
			cQuery +=           " AND (QPR_OPERAC = '" + cOperacao +"') " 
		EndIf
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=		 	 		  " AND (QPR_RESULT = 'R')) R "
		cQuery +=              " FULL OUTER JOIN "
		cQuery +=              " (SELECT DISTINCT CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPR_OP, QPR_PRODUT), QPR_LOTE), QPR_LABOR), QPR_ENSAIO), QPR_ROTEIR), QPR_OPERAC) ENSAIO, "
		cQuery +=		 	   		   " QPR_ROTEIR, "
		cQuery +=		 	   		   " QPR_OPERAC, "
		cQuery +=               	   " QPR_RESULT "
		cQuery +=              " FROM " + RetSqlName("QPR") + " QPR990_1 "
		cQuery +=              " WHERE (D_E_L_E_T_ = ' ') "

		If !Empty(cOperacao)
			cQuery +=          " AND (QPR_OPERAC = '" + cOperacao +"') " 
		EndIf
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=           Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=              		  " AND (QPR_RESULT = 'A')) A ON R.ENSAIO = A.ENSAIO
		cQuery +=          " ) ENSAIO ON CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP , QPK_PRODUT), QPK_LOTE), QP7_LABOR), QP7_ENSAIO), QP7_CODREC), QP7_OPERAC) = ENSAIO.ENSAIO "
		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=      " SELECT "
		cQuery +=           " QP1_ENSAIO, "
		cQuery +=           " QP1_FILIAL, "
		cQuery += 		    " (CASE QP1_CARTA "
		cQuery +=           " WHEN 'XBR' THEN QP1_QTDE "
		cQuery +=           " WHEN 'XBS' THEN QP1_QTDE "
		cQuery +=           " WHEN 'XMR' THEN QP1_QTDE "
		cQuery +=           " WHEN 'HIS' THEN QP1_QTDE "
		cQuery +=           " WHEN 'NP ' THEN QP1_QTDE "
		cQuery +=           " WHEN 'P  ' THEN 3 "
		cQuery +=           " WHEN 'U  ' THEN 2 "
		cQuery +=           " ELSE 1 "
		cQuery +=           " END) QP1_QTDE, "
		cQuery +=           " QP1_DESCPO, "
		cQuery +=           " QP1_TIPO "
		cQuery +=      " FROM " + RetSqlName("QP1")
		cQuery +=      " WHERE "
		cQuery +=           " (D_E_L_E_T_ = ' ') "
		cQuery +=           " AND (QP1_FILIAL = '" + xFilial("QP1") +"') " 
		cQuery +=      		" ) QP1 ON QP7.QP7_ENSAIO = QP1.QP1_ENSAIO "
		cQuery += 	   " ON SX5.X5_CHAVE = QP7.QP7_LABOR "	

		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=       " SELECT QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC, QPL_LABOR, QPL_LAUDO "
		cQuery +=       " FROM " + RetSqlName("QPL")
		cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
		
		If !Empty(cOperacao)
			cQuery +=   " AND (QPL_OPERAC = '" + cOperacao +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPL_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPL_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=            " AND (QPL_FILIAL = '" + xFilial("QPL") +"') " 
		cQuery +=       " ) QPL "
		cQuery += 	   " ON CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QP7_CODREC), QP7_OPERAC), QP7_LABOR) "
		cQuery += 	    " = CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR), QPL_OPERAC), QPL_LABOR) "	

		cQuery +=  " UNION "

		// Ensaios do tipo TEXTO
		cQuery +=  " SELECT "
		cQuery +=      " QPK.R_E_C_N_O_ RECNOQPK, "
		cQuery +=      " QP8.R_E_C_N_O_ RECNOTEST, "
		cQuery +=      " QP8.QP8_ENSAIO, "
		cQuery +=      " QP8.QP8_SEQLAB, "
		cQuery +=      " '' CONTROLTYPE, "
		cQuery +=      " '' QP7_NOMINA, "
		cQuery +=      " '' QP7_LIE, "
		cQuery +=      " '' QP7_LSE, "
		cQuery +=      " QP8.QP8_OPERAC, "
		cQuery +=      " '' QP7_UNIMED, "
		cQuery +=      " COALESCE(QP1.QP1_DESCPO, '') QP1_DESCPO, "
		cQuery +=      " COALESCE(QP1.QP1_TIPO, '') QP1_TIPO, "
		cQuery +=      " 1 QP1_QTDE, "
		cQuery +=      " COALESCE(SX5.X5_CHAVE, '') X5_CHAVE, "
		cQuery +=      " COALESCE(SX5.X5_DESCRI, '') X5_DESCRI, "
		cQuery +=      " QP8.QP8_TEXTO SUMMARYSPECIFICATION,	"
		cQuery +=      " QP8.QP8_ENSOBR ENSOBRI,	"
		cQuery +=      " QPL_LAUDO, "
		cQuery +=      " QPR_RESULT, "
		cQuery +=      " 'T' TIPO "
		cQuery +=  " FROM "
		cQuery +=      " ( SELECT "
		cQuery +=              " X5_CHAVE, "
		cQuery +=              " X5_DESCRI "
		cQuery +=       " FROM " + RetSqlName("SX5")
		cQuery +=       " WHERE "
		cQuery +=              " (D_E_L_E_T_ = ' ') "
		cQuery +=              " AND (X5_FILIAL = '" + xFilial("SX5") + "') " 
		cQuery +=              " AND (X5_TABELA = 'Q2') "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("X5_CHAVE", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (X5_CHAVE = '" + cLaboratorio + "') "
		EndIf

		cQuery +=       " ) SX5 "
		cQuery +=       " RIGHT OUTER JOIN "
		cQuery +=       " ( SELECT "
		cQuery +=              " QPK_PRODUT, "
		cQuery +=              " QPK_REVI, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QPK_LAUDO, "
		cQuery +=              " QPK_LOTE, "
		cQuery +=              " QPK_NUMSER, "
		cQuery +=              " QPK_OP "
		cQuery +=       " FROM " + RetSqlName("QPK")
		cQuery +=       " WHERE "
		cQuery +=              " (D_E_L_E_T_ = ' ') "
		cQuery += 			   " AND (QPK_FILIAL = '" + xFilial("QPK") +"') "
		cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecno) +") "
		cQuery +=       " ) QPK "
		cQuery +=       " INNER JOIN "
		cQuery +=       " (SELECT "
		cQuery +=              " QP8_PRODUT, "
		cQuery +=              " QP8_REVI, "
		cQuery +=              " QP8_ENSAIO, "
		cQuery +=              " QP8_LABOR, "
		cQuery +=              " R_E_C_N_O_, "
		cQuery +=              " QP8_TEXTO, "
		cQuery +=              " QP8_ENSOBR, "
		cQuery +=              " QP8_SEQLAB, "
		cQuery +=              " QP8_CODREC, "
		cQuery +=              " QP8_OPERAC "
		cQuery +=       " FROM " + RetSqlName("QP8")
		cQuery +=       " WHERE "
		cQuery +=              " (D_E_L_E_T_ = ' ') "
		cQuery +=              " AND (QP8_FILIAL = '" + xFilial("QP8") +"') "

		If !Empty(cOperacao)
			cQuery +=          " AND (QP8_OPERAC = '" + cOperacao +"') " 
		EndIf

		If !Empty(cIDEnsaio)
			cQuery +=          " AND (QP8_ENSAIO = '" + cIDEnsaio +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QP8_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=       " ) QP8 ON QP8.QP8_PRODUT = QPK.QPK_PRODUT "
		cQuery +=            " AND QP8.QP8_REVI = QPK.QPK_REVI "

		cQuery +=       " INNER JOIN "
		cQuery +=         "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM ), C2_SEQUEN) AS C2_OP, "
		cQuery +=                " C2_ROTEIRO "
		cQuery +=         " FROM " + RetSQLName("SC2") + " "
		cQuery +=         " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
		cQuery +=       " ON C2_OP = QPK_OP "
		cQuery +=         " AND C2_ROTEIRO = QP8_CODREC "

		cQuery +=       " LEFT OUTER JOIN "
		cQuery +=		" (SELECT "
		cQuery += 		 	   " DISTINCT COALESCE (R.ENSAIO, A.ENSAIO) ENSAIO, "
		cQuery +=	           " COALESCE(R.QPR_ROTEIR, A.QPR_ROTEIR) QPR_ROTEIR, "
		cQuery +=	           " COALESCE(R.QPR_OPERAC, A.QPR_OPERAC) QPR_OPERAC, "
		cQuery += 		 	   " COALESCE (R.QPR_RESULT, "
		cQuery += 		 	   " A.QPR_RESULT) QPR_RESULT "
		cQuery += 		" FROM "
		cQuery += 		 	   " (SELECT DISTINCT CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPR_OP, QPR_PRODUT), QPR_LOTE), QPR_LABOR), QPR_ENSAIO), QPR_ROTEIR), QPR_OPERAC) ENSAIO, "
		cQuery +=		 	   		   " QPR_ROTEIR, "
		cQuery +=		 	   		   " QPR_OPERAC, "
		cQuery += 		 	   		   " QPR_RESULT "
		cQuery += 		 	   " FROM " + RetSqlName("QPR")
		cQuery += 		 	   " WHERE "
		cQuery += 		 	   		   " (D_E_L_E_T_ = ' ') "
		
		If !Empty(cOperacao)
			cQuery +=          " AND (QPR_OPERAC = '" + cOperacao +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery += 		 	   		   " AND (QPR_RESULT = 'R')) R "
		cQuery += 		 	   " FULL OUTER JOIN "
		cQuery += 		 	   " (SELECT DISTINCT CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPR_OP, QPR_PRODUT), QPR_LOTE), QPR_LABOR), QPR_ENSAIO), QPR_ROTEIR), QPR_OPERAC) ENSAIO, "
		cQuery +=		 	   		   " QPR_ROTEIR, "
		cQuery +=		 	   		   " QPR_OPERAC, "
		cQuery += 		 	   		   " QPR_RESULT "
		cQuery += 		 	   " FROM " + RetSqlName("QPR") + " QPR990_1 "
		cQuery += 		 	   " WHERE "
		cQuery += 		 	   		   " (D_E_L_E_T_ = ' ') "
		
		If !Empty(cOperacao)
			cQuery +=          " AND (QPR_OPERAC = '" + cOperacao +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPR_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPR_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery += 		 	   		   " AND (QPR_RESULT = 'A')) A ON R.ENSAIO = A.ENSAIO "
		cQuery += 		" ) ENSAIO ON CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPK.QPK_OP, QPK.QPK_PRODUT), QPK.QPK_LOTE), QP8.QP8_LABOR), QP8.QP8_ENSAIO), QP8.QP8_CODREC), QP8.QP8_OPERAC) = ENSAIO.ENSAIO "
		cQuery +=       " LEFT OUTER JOIN "
		cQuery +=       " (SELECT "
		cQuery +=              " QP1_ENSAIO, "
		cQuery +=              " QP1_FILIAL, "
		cQuery +=              " QP1_DESCPO, "
		cQuery +=              " QP1_TIPO "
		cQuery +=       " FROM " + RetSqlName("QP1")
		cQuery +=       " WHERE "
		cQuery +=              " (D_E_L_E_T_ = ' ')	"
		cQuery +=              " AND (QP1_FILIAL = '" + xFilial("QP1") + "') " 
		cQuery +=       " ) QP1 ON QP8.QP8_ENSAIO = QP1.QP1_ENSAIO "
		cQuery +=       " ON SX5.X5_CHAVE = QP8.QP8_LABOR"
		
		cQuery +=      " LEFT OUTER JOIN ( "
		cQuery +=       " SELECT QPL_OP, QPL_LOTE, QPL_NUMSER, QPL_ROTEIR, QPL_OPERAC, QPL_LABOR, QPL_LAUDO "
		cQuery +=       " FROM " + RetSqlName("QPL")
		cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=            " AND (QPL_FILIAL = '" + xFilial("QPL") +"') " 
		
		If !Empty(cOperacao)
			cQuery +=          " AND (QPL_OPERAC = '" + cOperacao +"') " 
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QPL_LABOR", cUsuario)
		EndIf

		If !Empty(cLaboratorio)
			cQuery += " AND (QPL_LABOR = '" + cLaboratorio + "') "
		EndIf

		cQuery +=       " ) QPL "
		cQuery += 	   " ON CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QP8_CODREC), QP8_OPERAC), QP8_LABOR) "
		cQuery += 		" = CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR), QPL_OPERAC), QPL_LABOR) "	

		cQuery += " ) UNIAO "

		cOrdemDB := Self:oAPIManager:RetornaOrdemDB(cOrdem, cTipoOrdem)
		If !Empty(cOrdemDB)
			cQuery += " ORDER BY " + cOrdemDB
		EndIf

		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)
		cAlias := Self:oQueryManager:executeQuery(cQuery)

	End Sequence	
	ErrorBlock(bErrorBlock)

Return cAlias

/*/{Protheus.doc} RetornaLista
Pesquisa Lista de Inspeções de Processo com Base em Texto nos Campos Produto, OP
@author brunno.costa
@since  25/10/2022
@param 01 - nRecno      , numérico, R_E_C_N_O_ para buscar informações da tabela QPK
@param 02 - cOperacao   , numérico, R_E_C_N_O_ para buscar informações da tabela QPK
@param 03 - cLaboratorio, caracter, código do laboratório para filtro
@param 04 - cOrdem      , caracter, ordenação para retornar a listagem dos dados
@param 05 - cTipoOrdem  , caracter, tipo de ordenação para retornar a listagem dos dados (Ascedente ou Decrescente)
@param 06 - nPagina     , numérico, página atual dos dados para consulta
@param 07 - nTamPag     , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 08 - cCampos     , caracter, campos que deverão estar contidos na mensagem
@param 09 - cIDEnsaio   , caracter, código do ensaio
@param 10 - cUsuario    , caracter, código do usuário consumindo a API
@return lRetorno, lógico, indica se conseguiu realizar o processamento
/*/
METHOD RetornaLista(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario) CLASS EnsaiosInspecaoDeProcessosAPI
     
    Local cAlias      := Nil
    Local lRetorno    := .T.

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0004), .T.,; //"Módulo não está implantado"
					 405, EncodeUtf8(STR0005))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf
		
	cAlias := Self:CriaAliasEnsaiosPesquisa(nRecno, cOperacao, cLaboratorio, cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)

	If Empty(Self:oAPIManager:cErrorMessage)
		lRetorno := Self:oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
    	(cAlias)->(dbCloseArea())
	Else
		lRetorno := .F.
		SetRestFault(400, EncodeUtf8(Self:oAPIManager:cErrorMessage), .T.,;
		             400, EncodeUtf8(Self:oAPIManager:cDetailedMessage))
	EndIf

Return lRetorno

/*/{Protheus.doc} NaoImplantado
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@return lNaoImplantado, lógico, indica se o módulo QIP não está implantado
/*/
METHOD NaoImplantado() CLASS EnsaiosInspecaoDeProcessosAPI
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
