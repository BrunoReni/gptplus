#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "ResultadosEnsaiosInspecaoDeProcessosAPI.CH"

Static slQLTMetrics := FindClass("QLTMetrics")
Static lQP215ExAAm  := Nil

//Desconsiderado o uso de FWAPIManager devido complexidade de DE-PARA das tabelas QPK, QPS, QPQ x API Mobile

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} processinspectiontestresults
API Resultados Ensaios da Inspeção de Processos - Qualidade
@author brunno.costa
@since  23/05/2022
/*/
WSRESTFUL processinspectiontestresults DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Resultados Ensaios Inspeção de Processos"

    WSDATA Fields      as STRING OPTIONAL
	WSDATA IDTest      as STRING OPTIONAL
	WSDATA OperationID as STRING OPTIONAL
    WSDATA Order       as STRING OPTIONAL
    WSDATA Page        as INTEGER OPTIONAL
    WSDATA PageSize    as INTEGER OPTIONAL
    WSDATA RecnoQPK    as STRING OPTIONAL
	WSDATA RecnoQPR    as STRING OPTIONAL
	WSDATA RecnoQQM    as STRING OPTIONAL
    WSDATA RecnosQPR   as STRING OPTIONAL

    WSMETHOD GET result;
    DESCRIPTION STR0015; //"Retorna Resultado da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/result/{RecnoQPK}/{RecnosQPR}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/result/{RecnoQPK}/{RecnosQPR}/{Order}/{Page}/{PageSize}" ;
    TTALK "v1"

    WSMETHOD GET testhistory;
    DESCRIPTION STR0015; //"Retorna Resultado da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/testhistory/{RecnoQPK}/{OperationID}/{IDTest}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/testhistory" ;
    TTALK "v1"

	WSMETHOD GET history;
    DESCRIPTION STR0016; //"Retorna Histórico de Resultados da Inspeção de Processos"
    WSSYNTAX "api/qip/v1/history/{RecnoQPK}/{Order}/{Page}/{PageSize}" ;
    PATH "/api/qip/v1/history" ;
    TTALK "v1"

	WSMETHOD GET listattachments;
    DESCRIPTION STR0049; //"Retorna lista de anexos de uma amostra de resultados"
    WSSYNTAX "api/qip/v1/listattachments/{RecnoQPR}" ;
    PATH "/api/qip/v1/listattachments" ;
    TTALK "v1"

	WSMETHOD GET attachedfile;
    DESCRIPTION STR0050; //"Retorna Arquivo em base 64"
    WSSYNTAX "api/qip/v1/attachedfile/{RecnoQQM}" ;
    PATH "/api/qip/v1/attachedfile" ;
    TTALK "v1"

	WSMETHOD DELETE attachedfile;
    DESCRIPTION STR0056; //"Deleta arquivo anexo"
    WSSYNTAX "api/qip/v1/attachedfile/{RecnoQQM}" ;
    PATH "/api/qip/v1/attachedfile" ;
    TTALK "v1"
	
	WSMETHOD POST save;
	DESCRIPTION STR0002; //"Salva Resultado"
	WSSYNTAX "api/qip/v1/save" ;
	PATH "/api/qip/v1/save" ;
	TTALK "v1"

	WSMETHOD POST savefile;
	DESCRIPTION STR0042; //"Salva Arquivo Anexo"
	WSSYNTAX "api/qip/v1/savefile" ;
	PATH "/api/qip/v1/savefile" ;
	TTALK "v1"

	WSMETHOD DELETE result;
	DESCRIPTION STR0031; //"Deleta Informações de uma Amostra"
	WSSYNTAX "api/qip/v1/result/{RecnoQPR}" ;
    WSSYNTAX "api/qip/v1/result" ;
	TTALK "v1"

	WSMETHOD GET canreceivefiles;
	DESCRIPTION STR0043; //"Indica se o ambiente está preparado para o recebimento de arquivos";
	WSSYNTAX "api/qip/v1/canreceivefiles" ;
	PATH "/api/qip/v1/canreceivefiles" ;
	TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET result PATHPARAM RecnoQPK, RecnosQPR, Order, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Local aRecnosQPR := Nil
	Default Self:RecnoQPK  := ""
	Default Self:RecnosQPR := ""
	Default Self:Order     := ""
	Default Self:Page      := 1
	Default Self:PageSize  := 5
	Default Self:Fields    := ""
	aRecnosQPR := StrTokArr2( Self:RecnosQPR, ";")
Return oAPIClass:RetornaResultadosInspecao(Self:RecnoQPK, Self:Order, aRecnosQPR, Self:Page, Self:PageSize, Self:Fields)

WSMETHOD GET testhistory PATHPARAM RecnoQPK, IDTest, OperationID, Order, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Default Self:RecnoQPK    := ""
	Default Self:IDTest      := ""
	Default Self:OperationID := ""
	Default Self:Order       := ""
	Default Self:Page        := 1
	Default Self:PageSize    := 5
	Default Self:Fields      := ""
Return oAPIClass:RetornaResultadosInspecaoPorEnsaio(Self:RecnoQPK, Self:Order, Self:IDTest, Self:OperationID, Self:Page, Self:PageSize, Self:Fields)

WSMETHOD GET history PATHPARAM RecnoQPK, Order, Page, PageSize QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Local aRecnosQPR := Nil
	Default Self:RecnoQPK  := ""
	Default Self:Order     := ""
	Default Self:Page      := 1
	Default Self:PageSize  := 5
	Default Self:Fields    := ""
Return oAPIClass:RetornaResultadosInspecao(Self:RecnoQPK, Self:Order, aRecnosQPR, Self:Page, Self:PageSize, Self:Fields)

WSMETHOD POST save QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
Return oAPIClass:Salva(DecodeUTF8(Self:GetContent()))

WSMETHOD DELETE result PATHPARAM RecnoQPR WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Self:SetContentType("application/json")
Return oAPIClass:DeletaAmostra(Val(Self:RecnoQPR))

WSMETHOD POST savefile QUERYPARAM Fields WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
Return oAPIClass:SalvaAnexo(DecodeUTF8(Self:GetContent()))

WSMETHOD GET canreceivefiles WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
Return oAPIClass:PodeReceberArquivos()

WSMETHOD GET listattachments PATHPARAM RecnoQPR WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
Return oAPIClass:RetornaListaDeAnexosDeUmaAmostra(Val(Self:RecnoQPR))

WSMETHOD GET attachedfile PATHPARAM RecnoQQM WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
Return oAPIClass:RetornaAnexoAPartirDoRecnoDaQQM(Val(Self:RecnoQQM))

WSMETHOD DELETE attachedfile PATHPARAM RecnoQQM WSSERVICE processinspectiontestresults
    Local oAPIClass  := ResultadosEnsaiosInspecaoDeProcessosAPI():New(Self)
	Self:SetContentType("application/json")
Return oAPIClass:DeletaAnexoAmostra(Val(Self:RecnoQQM))

/*/{Protheus.doc} ResultadosEnsaiosInspecaoDeProcessosAPI
Regras de Negocio - API Inspeção de Processos
@author brunno.costa
@since  23/05/2022
/*/
CLASS ResultadosEnsaiosInspecaoDeProcessosAPI FROM LongNameClass

	DATA aCamposAPI                  as ARRAY
	DATA aCamposQPQ                  as ARRAY
	DATA aCamposQPR                  as ARRAY
	DATA aCamposQPS                  as ARRAY
	DATA cDetailedMessage            as STRING
	DATA cErrorMessage               as STRING
	DATA cOperacao                   as STRING
	DATA lExcluiuRegistroNumerico    as LOGICAL
	DATA lForcaInexistenciaDiretorio as LOGICAL
	DATA lProcessaRetorno            as LOGICAL
	DATA lSalvouRegistroNumerico     as LOGICAL
	DATA lTemQQM                     as LOGICAL
	DATA nCamposQPR                  as NUMERIC
	DATA nRecnoQPK                   as NUMERIC
	DATA nRegistros                  as NUMERIC
	DATA oAPIManager                 as OBJECT
    DATA oWSRestFul                  as OBJECT

    METHOD new(oWSRestFul) CONSTRUCTOR
	METHOD DeletaAmostra(nRecnoQPR, cUsuario)
	METHOD DeletaAmostraSemResponse(nRecnoQPR, cChaveQPK)
	METHOD DeletaAnexoAmostra(nRecnoQQM)
    METHOD Salva(cJsondata)
     
    //Métodos Internos
	METHOD AtualizaChaveQPRParaMedia(oRegistro)
	METHOD AtualizaEnsaiadorQPR(cLogin, oRegistro)
	METHOD AtualizaStatusQPKComChaveQPK(cChaveQPK)
	METHOD AtualizaStatusQPKComRecno(nRecnoQPK)
	METHOD CriaAliasResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos, cAlias)
	METHOD CriaPasta(cDiretorio)
	METHOD DefineFatores()
	METHOD EnsaioComMedia(cTipo, cFormula)
	METHOD ErrorBlock(e)
	METHOD ExcluiAnexosERelacionamento(cChave)
	METHOD ExcluiArquivoAnexo(cNome)
	METHOD ExisteLaudoRelacionadoAoPost(oDadosJson)
	METHOD GeraChaveQPR()
	METHOD IdentificaRecnosInspecoesEEnsaios(oDadosJson, aRecsQPK, aRecsQP7, aRecsQP8)
	METHOD MapeiaCamposAPI(cCampos)
	METHOD MapeiaCamposQPQ(cCampos)
	METHOD MapeiaCamposQPR(cCampos)
	METHOD MapeiaCamposQPS(cCampos)
	METHOD MapeiaCamposQQM(cCampos)
	METHOD NaoImplantado()
	METHOD PodeReceberArquivos()
	METHOD PreparaDadosQPQ(oItemAPI)
	METHOD PreparaDadosQPS(oItemAPI)
	METHOD PreparaRegistroInclusaoQPR(oItemAPI, oRegistro)
	METHOD PreparaRegistroQPR(oItemAPI, oRegistro)
	METHOD ProcessaItensRecebidos(oDadosJson, aRecnosQPR)
	METHOD RecuperaCamposQP7paraQPR(oRegistro, nRecnoQP7)
	METHOD RecuperaCamposQP8paraQPR(oRegistro, nRecnoQP8)
	METHOD RecuperaCamposQPKParaQPR(oRegistro, nRecnoQPK)
	METHOD RegistraAnexo(oContent, cStatus, cChave)
	METHOD RegistraAnexos(oItemAPI, oRegistro)
	METHOD RetornaAnexoAPartirDoRecnoDaQQM(nRecnoQQM)
	METHOD RetornaListaDeAnexosDeUmaAmostra(nRecnoQPR)
	METHOD RetornaResultadosInspecao(nRecnoQPK, cOrdem, aRecnosQPR, nPagina, nTamPag, cCampos)
	METHOD RetornaResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos)
	METHOD SalvaAnexo(cContent, lSucesso)
    METHOD SalvaRegistroNumerico(oItemAPI)
	METHOD SalvaRegistroQPSSequencialmente(oDadosQPS)
	METHOD SalvaRegistros(oItemAPI)
	METHOD SalvaRegistroTexto(oItemAPI)
	METHOD ValidaEnsaiador(oRegistro)
	METHOD ValidaEnsaioEditavel(cEnsaio, cOperacao)
	METHOD ValidaEnsaioEditavelPorQPR(cOperacao)
	METHOD ValidaEnsaioEditavelPorRegistro(oRegistro, cOperacao)
	METHOD ValidaFormatosCamposItem(oItemAPI, aCamposAPI)
	METHOD ValidaInexistenciaLaudoLaboratorio(cChaveQPL, cOperacao)
	METHOD ValidaPermissaoEnsaioNumerico(nRecnoQP7)
	METHOD ValidaPermissaoEnsaioTexto(nRecnoQP8)
	METHOD ValidaQuantidadeMedicoesEnsaio(oItemAPI, nMedicoes, cEnsaio)
	METHOD ValidaUsuarioProtheus(oItemAPI)

ENDCLASS

METHOD new(oWSRestFul) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
     Self:oWSRestFul                  := oWSRestFul
	 Self:oAPIManager                 := QualityAPIManager():New(Nil, oWSRestFul, Nil)
	 Self:lProcessaRetorno            := .T.
	 Self:lSalvouRegistroNumerico     := .F.
	 Self:lExcluiuRegistroNumerico    := .F.
	 Self:lForcaInexistenciaDiretorio := .F.
	 Self:lTemQQM                     := !Empty(FWX2Nome( "QQM" ))
	 Self:cErrorMessage               := ""
	 Self:cDetailedMessage            := ""
Return Self

/*/{Protheus.doc} MapeiaCamposAPI
Mapeia os Campos da Interface da API
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposAPI(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "RecnoInspecao"     , "recnoInspection"     , "RECNOQPK"   , "NN" ,                                       0, 0, "QPK"})    //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.T., "RecnoEnsaio"       , "recnoTest"           , "RECNOTEST"  , "NN" ,                                       0, 0, "QP7QP8"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.F., "Ensaio"            , "testID"              , "QPR_ENSAIO" , "CN" , GetSx3Cache("QPR_ENSAIO" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "Data"              , "measurementDate"     , "QPR_DTMEDI" , "D"  , GetSx3Cache("QPR_DTMEDI" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "Hora"              , "measurementTime"     , "QPR_HRMEDI" , "H"  , GetSx3Cache("QPR_HRMEDI" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "CodigoEnsaiador"   , "rehearserID"         , "QPR_ENSR"   , "C"  , GetSx3Cache("QPR_ENSR"   ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "Ensaiador"         , "rehearser"           , "QAA_NOME"   , "C"  , GetSx3Cache("QAA_NOME"   ,"X3_TAMANHO"), 0, "QAA"})
	aAdd(aMapaCampos, {.T., "NumeroAmostra"     , "sampleNumber"        , "QPR_AMOSTR" , "N"  , GetSx3Cache("QPR_AMOSTR" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "TipoEnsaio"        , "testType"            , "TIPO"       , "C"  ,                                       1, 0, "N/A"})
	aAdd(aMapaCampos, {.F., "ArrayMedicoes"     , "measurements"        , "MEDICOES"   , "A"  ,                                       0, 0, "QPS"})
	aAdd(aMapaCampos, {.F., "TextoStatus"       , "textStatus"          , "QPR_RESULT" , "C"  , GetSx3Cache("QPR_RESULT" ,"X3_TAMANHO"), 0, "QPR"})
	aAdd(aMapaCampos, {.F., "TextoDetalhes"     , "textDetail"          , "QPQ_MEDICA" , "C"  , GetSx3Cache("QPQ_MEDICA" ,"X3_TAMANHO"), 0, "QPQ"})
	aAdd(aMapaCampos, {.F., "UsuarioProtheus"   , "protheusLogin"       , "QAA_LOGIN"  , "C"  , GetSx3Cache("QAA_LOGIN"  ,"X3_TAMANHO"), 0, "QAA"})
	aAdd(aMapaCampos, {.T., "Recno"             , "recno"               , "RECNOQPR"   , "NN" ,                                       0, 0, "QPR"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
	aAdd(aMapaCampos, {.T., "TemAnexo"          , "hasAttachment"       , "TEMANEXO"   , "C"  ,                                       0, 0, "QQM"})
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Titulo_API)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCamposQPR
Mapeia os Campos da tabela QPR do Protheus - Dados Genéricos das Medições
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQPR(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "Data"              , "measurementDate"     , "QPR_DTMEDI"        , "D"  , GetSx3Cache("QPR_DTMEDI" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "Hora"              , "measurementTime"     , "QPR_HRMEDI"        , "C"  , GetSx3Cache("QPR_HRMEDI" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "Ensaiador"         , "rehearser"           , "QPR_ENSR"          , "C"  , GetSx3Cache("QPR_ENSR"   ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "TextoStatus"       , "textStatus"          , "QPR_RESULT"        , "C"  , GetSx3Cache("QPR_RESULT" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "NumeroAmostra"     , "sampleNumber"        , "QPR_AMOSTR"        , "N"  , GetSx3Cache("QPR_AMOSTR" ,"X3_TAMANHO"), 0, "QPR" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_CHAVE"         , "C"  ,                                       0, 0, "QPR" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_FILMAT"        , "C"  ,                                       0, 0, "QAA"   , "QAA_FILIAL"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_REVI"          , "C"  ,                                       0, 0, "QPK"   , "QPK_REVI"  })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_OP"            , "C"  ,                                       0, 0, "QPK"   , "QPK_OP"    })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_DTENTR"        , "C"  ,                                       0, 0, "QPK"   , "QPK_EMISSA"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_LOTE"          , "C"  ,                                       0, 0, "QPK"   , "QPK_LOTE"  })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_NUMSER"        , "C"  ,                                       0, 0, "QPK"   , "QPK_NUMSER"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_PRODUT"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_PRODUT"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_LABOR"         , "C"  ,                                       0, 0, "QP7QP8", "QP7_LABOR" })
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_ENSAIO"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_ENSAIO"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_OPERAC"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_OPERAC"})
	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPR_ROTEIR"        , "C"  ,                                       0, 0, "QP7QP8", "QP7_CODREC"})
	aAdd(aMapaCampos, {.T., "Recno"             , "recno"               , "R_E_C_N_O_"        , "NN" ,                                           0, 0, "QPR"}) //NN para não formatar como número pois não temos certeza do tamanho configurado na tabela do cliente
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

	Self:nCamposQPR := Len(aMapaCampos)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCamposQQM
Mapeia os Campos da tabela QQM do Protheus - Anexos Inspeção Qualidade     
@author rafael.hesse
@since  13/04/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQQM(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "UID"         , "uid"         , "QQM_MSUID" , "C"  , GetSx3Cache("QQM_MSUID" ,"X3_TAMANHO"), 0, "QQM" })
	aAdd(aMapaCampos, {.T., "TipoMime"    , "mimeType"    , "QQM_MIME"  , "C"  , GetSx3Cache("QQM_MIME"  ,"X3_TAMANHO"), 0, "QQM" })
	aAdd(aMapaCampos, {.T., "NomeOriginal", "originalName", "QQM_NOMEOR", "C"  , GetSx3Cache("QQM_NOMEOR","X3_TAMANHO"), 0, "QQM" })
	aAdd(aMapaCampos, {.T., "Recno"       , "recno"       , "RECNOQQM"  , "NN" , 0                                     , 0, "QQM" })
	aAdd(aMapaCampos, {.T., "Tamanho"     , "size"        , "QQM_SIZE"  , "N"  , GetSx3Cache("QQM_SIZE","X3_TAMANHO")  , 0, "QQM" })
	

    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCampos
Mapeia os Campos da tabela QPS do Protheus - Processo Medições Mensuráveis - Dados Numéricos
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQPS(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QPS_CODMED", "C"  ,0, 0, "QPR", "QPR_CHAVE"})
	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QPS_MEDICA", "C"  ,0, 0, "QPS" }) //MEDICAO
	aAdd(aMapaCampos, {.T., "N/A", "N/A", "QPS_INDMED", "C"  ,0, 0, "QPS" }) //SEQUENCIAL MEDICOES ARRAY 1-3 ou vazio acima de 4
 
    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} MapeiaCamposQPQ
Mapeia os Campos da tabela QPS do Protheus - Valores das Medições (Texto)  
@author brunno.costa
@since  23/06/2022
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQPQ(cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "N/A"               , "N/A"                 , "QPQ_CODMED"        , "C"  ,                                       0, 0, "QPR", "QPR_CHAVE"})
	aAdd(aMapaCampos, {.F., "TextoDetalhes"     , "textDetail"          , "QPQ_MEDICA"        , "C"  , GetSx3Cache("QPQ_MEDICA" ,"X3_TAMANHO"), 0})
	
	aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} Salva
Método para Salvar um Registro Recebido via API no DB Protheus
@author brunno.costa
@since  23/05/2022
@param 01 - cJsonData, caracter, string JSON com os dados para interpretação e gravação
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD Salva(cJsonData) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local aRecnosQPR            := {}
	Local bErrorBlock           := Nil
	Local cError                := Nil
	Local lSucesso              := .T.
    Local oDadosJson            := Nil
	Local oQIPEnsaiosCalculados := Nil
	Local oSelf                 := Self
	
	bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e)})

	Self:oWSRestFul:SetContentType("application/json")

	oDadosJson  := JsonObject():New() 
	cError := oDadosJson:fromJson(cJsonData)
	If cError == Nil
		Begin Transaction
			Begin Sequence

				lSucesso := !Self:ExisteLaudoRelacionadoAoPost(oDadosJson)
				If !lSucesso .And. Empty(Self:oAPIManager:cErrorMessage)
					Self:oAPIManager:lWarningError := .T.
					Self:cErrorMessage            := STR0041 //"Operação não permitida! Existe laudo relacionado a esta inspeção."
					Self:cDetailedMessage         := STR0041 //"Operação não permitida! Existe laudo relacionado a esta inspeção."
				EndIf

				If lSucesso
					lSucesso := Self:ProcessaItensRecebidos(@oDadosJson, @aRecnosQPR)
				EndIf

				If lSucesso .And. oDadosJson['responseItems'] == Nil .OR. oDadosJson['responseItems']
					lSucesso := Self:RetornaResultadosInspecao(Self:nRecnoQPK, Nil, aRecnosQPR)
				EndIf

				If !lSucesso .And. Empty(Self:cErrorMessage) .And. Empty(Self:oAPIManager:cErrorMessage)
					cError := Iif(cError == Nil, "", cError)
					//"Não foi possível realizar o processamento."
					//"Ocorreu erro durante a gravação dos dados: "
					Self:cErrorMessage    := STR0003          
					Self:cDetailedMessage := STR0004 + cError 
				EndIf
					
			Recover
				lSucesso := .F.
			End Sequence

			If !lSucesso 
				DisarmTransaction()
			EndIf

		End Transaction		

	Else
		//"Não foi possível interpretar os dados recebidos."
		//"Ocorreu erro ao transformar os dados recebidos em objeto JSON: "
		Self:cErrorMessage    := STR0005         
		Self:cDetailedMessage := STR0006 + cError
		lSucesso              := .F.
	EndIf

	If lSucesso
		Self:AtualizaStatusQPKComRecno(Self:nRecnoQPK)
		If Self:nRegistros == 1 .And. Self:lSalvouRegistroNumerico
			oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(Self:nRecnoQPK, Self:cOperacao, {})
			oQIPEnsaiosCalculados:PersisteEnsaiosCalculados(oDadosJson["items"][1])
		EndIf
	Else
		Self:oAPIManager:RespondeValor("result", .F., Self:cErrorMessage, Self:cDetailedMessage)
	EndIf

	FwFreeObj(oDadosJson)

	ErrorBlock(bErrorBlock)

Return lSucesso

/*/{Protheus.doc} ValidaEnsaioEditavelPorQPR
Valida Se é Permitida Alteração/Inclusão/Alteração na QPR por posicionamento em registro da QPR
@author brunno.costa
@since  10/08/2022
@param 01 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavelPorQPR(cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local lPermite := .T.

	Default cOperacao := "I"

	If QPR->(!Eof())
		lPermite := Self:ValidaEnsaioEditavel(QPR->QPR_ENSAIO, cOperacao)

		If lPermite
			lPermite := Self:ValidaInexistenciaLaudoLaboratorio(QPR->(QPR_OP+QPR_LOTE+QPR_NUMSER+QPR_ROTEIR+QPR_OPERAC+QPR_LABOR), cOperacao)
		EndIf
	EndIf

Return lPermite

/*/{Protheus.doc} ValidaEnsaioEditavelPorRegistro
Valida Se é Permitida Alteração/Inclusão/Alteração na QPR por oRegistro da QPR
@author brunno.costa
@since  10/08/2022
@param 01 - oRegistro , objeto, retorna por referência os dados para gravação na tabela QPR do DB
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavelPorRegistro(oRegistro, cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local lPermite := .T.

	Default cOperacao := "I"

	lPermite := Self:ValidaEnsaioEditavel(oRegistro["QPR_ENSAIO"], cOperacao)

	If lPermite
		lPermite := Self:ValidaInexistenciaLaudoLaboratorio(oRegistro["QPR_OP"]+;
                                                            oRegistro["QPR_LOTE"]+;
                                                            oRegistro["QPR_NUMSER"]+;
                                                            oRegistro["QPR_ROTEIR"]+;
                                                            oRegistro["QPR_OPERAC"]+;
                                                            oRegistro["QPR_LABOR"], cOperacao)
	EndIf

Return lPermite

/*/{Protheus.doc} ValidaInexistenciaLaudoLaboratorio
Valida inexistência do laudo de laboratório na QPL
@author brunno.costa
@since  10/08/2022
@param 01 - cChaveQPL, caracter, chave de posicionamento na QPL
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lNaoExiste, lógico, indica se não existe laudo de laboratório
/*/
METHOD ValidaInexistenciaLaudoLaboratorio(cChaveQPL, cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lNaoExiste := .T.
	Local cMessage   := Nil

	Default cOperacao := "I"

	cMessage := Iif(cOperacao == "I", STR0037, cMessage) //"Falha na Inclusão da Amostra"
	cMessage := Iif(cOperacao == "A", STR0038, cMessage) //"Falha na Alteração da Amostra"
	cMessage := Iif(cOperacao == "E", STR0033, cMessage) //"Falha na Exclusão da Amostra"

	DbSelectArea("QPL")
	QPL->(DbSetOrder(3)) //QPL_FILIAL+QPL_OP+QPL_LOTE+QPL_NUMSER+QPL_ROTEIR+QPL_OPERAC+QPL_LABOR
	If QPL->(DbSeek(xFilial("QPL") + cChaveQPL))
		lNaoExiste := Empty(QPL->QPL_LAUDO)
		Self:cErrorMessage    := Iif(lNaoExiste,Self:cErrorMessage, cMessage)
		Self:cDetailedMessage := Iif(lNaoExiste,Self:cDetailedMessage, STR0036) //"Esta inspeção já possui laudo"
	EndIf

Return lNaoExiste

/*/{Protheus.doc} ValidaEnsaioEditavel
Valida Se é Permitida Alteração/Inclusão/Alteração para este Ensaio
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQPR, número  , RECNO do registro da amostra na tabela QPR
@param 02 - cOperacao, caracter, I = Inclusão, A = Alteração, E = Exclusão 
@return lPermite, lógico, indica se permite editar o ensaio
/*/
METHOD ValidaEnsaioEditavel(cEnsaio, cOperacao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	
	Local cMessage := Nil
	Local lPermite := .T.

	Default cOperacao := "I"

	cMessage := Iif(cOperacao == "I", STR0037, cMessage) //"Falha na Inclusão da Amostra"
	cMessage := Iif(cOperacao == "A", STR0038, cMessage) //"Falha na Alteração da Amostra"
	cMessage := Iif(cOperacao == "E", STR0033, cMessage) //"Falha na Exclusão da Amostra"

	/*
	DbSelectArea("QP1")
	QP1->(DbSetOrder(1))
	If QP1->(DbSeek(xFilial("QP1") + cEnsaio))
		lPermite := QP1->QP1_TIPO=="D"
		Self:cErrorMessage    := Iif(lPermite,Self:cErrorMessage, cMessage)
		Self:cDetailedMessage := Iif(QP1->QP1_TIPO=="D",Iif(QP1->QP1_CARTA!="TMP",Self:cDetailedMessage, STR0034), STR0035) //"A carta deste ensaio é TMP" + "Este ensaio é calculado"
	EndIf
	*/

Return lPermite

/*/{Protheus.doc} DeletaAmostraSemResponse
Método para Deletar uma Amostra via API no DB Protheus
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQPR, número  , RECNO do registro da amostra na tabela QPR
@param 02 - cChaveQPK, caracter, retorna por referência a chave do registro na QPK
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD DeletaAmostraSemResponse(nRecnoQPR, cChaveQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local bErrorBlock := Nil
	Local cChaveQPR   := Nil
	Local cError      := Nil
	Local lSucesso    := .T.
    Local oDadosJson  := Nil
	Local oSelf       := Self

	Default cChaveQPK := ""
	
	bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e)})

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPR")
			QPR->(DbGoTo(nRecnoQPR))
			If QPR->(!Eof())
				cChaveQPR := QPR->QPR_CHAVE

				lSucesso := Self:ValidaEnsaioEditavelPorQPR("E")

				If lSucesso
					DbSelectArea("QPQ")
					QPQ->(DbSetOrder(1))
					If QPQ->(DbSeek(xFilial("QPQ") + cChaveQPR))
						While lSucesso .AND. xFilial("QPQ") + cChaveQPR == QPQ->(QPQ_FILIAL+QPQ_CODMED)
							RecLock("QPQ", .F.)
							QPQ->(DbDelete())
							QPQ->(MsUnLock())
							QPQ->(DBSkip())
						EndDo
					EndIf

					DbSelectArea("QPS")
					QPS->(DbSetOrder(1))
					If lSucesso .AND. QPS->(DbSeek(xFilial("QPS") + cChaveQPR))
						While lSucesso .AND. xFilial("QPS") + cChaveQPR == QPS->(QPS_FILIAL+QPS_CODMED)
							RecLock("QPS", .F.)
							QPS->(DbDelete())
							QPS->(MsUnLock())
							Self:lExcluiuRegistroNumerico := Iif(!Self:lExcluiuRegistroNumerico, lSucesso, .T.)
							QPS->(DBSkip())
						EndDo
					EndIf

					cChaveQPK := QPR->(QPR_OP+QPR_LOTE+QPR_NUMSER+QPR_PRODUT+QPR_REVI)

					lQP215ExAAm := Iif(lQP215ExAAm == Nil, FindFunction("QP215ExAAm"), lQP215ExAAm)
					If lQP215ExAAm
						StartJob("QP215ExAAm", GetEnvServer(), .F., cEmpAnt, cFilAnt, QPR->QPR_FILIAL, QPR->QPR_CHAVE)
					EndIf
					RecLock("QPR", .F.)
					QPR->(DbDelete())
					QPR->(MsUnLock())
				EndIf
			EndIf
				
		Recover
			lSucesso := .F.
		End Sequence

		If !lSucesso 
			DisarmTransaction()
		EndIf

	End Transaction	

	FwFreeObj(oDadosJson)

	ErrorBlock(bErrorBlock)

Return lSucesso

/*/{Protheus.doc} DeletaAmostra
Método para Deletar uma Amostra via API no DB Protheus
@author brunno.costa
@since  10/08/2022
@param 01 - nRecnoQPR, número  , RECNO do registro da amostra na tabela QPR
@param 02 - cUsuario , caracter, indica o usuário que realizou a exclusão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD DeletaAmostra(nRecnoQPR, cUsuario) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cChaveQPK             := ""
	Local cResp                 := Nil
	Local lSucesso              := .T.
	Local nRecnoQPK             := Nil
	Local oQIPEnsaiosCalculados := Nil
	Local oResponse             := JsonObject():New()

	Self:oWSRestFul:SetContentType("application/json")

	lSucesso := Self:DeletaAmostraSemResponse(nRecnoQPR, @cChaveQPK)

	If lSucesso
		Self:AtualizaStatusQPKComChaveQPK(cChaveQPK)
		If Self:lExcluiuRegistroNumerico
			QPK->(DbSetOrder(1))
			If QPK->(DbSeek(xFilial("QPK")+cChaveQPK))
				nRecnoQPK := QPK->(Recno())
			EndIf
			oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(nRecnoQPK, Self:cOperacao, {})
			oQIPEnsaiosCalculados:ExcluiMedicoesCalculadas(cUsuario)
		EndIf

		HTTPSetStatus(204)
		oResponse['code'] := 204
		oResponse['response'] := STR0032 //"Amostra Excluída com Sucesso"
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
	Else
		SetRestFault(403, EncodeUtf8(Self:cErrorMessage), .T.,;
		             403, EncodeUtf8(Self:cDetailedMessage))
		oResponse['code'         ] := 403
		oResponse['errorCode'    ] := 403
		oResponse['message'      ] := Self:cErrorMessage
		oResponse['errorMessage' ] := Self:cDetailedMessage
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
	EndIf	

Return lSucesso

/*/{Protheus.doc} SalvaRegistroNumerico
Método para Salvar um Registro NUMÉRICO Recebido via API no DB Protheus
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroNumerico(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso   := .T.
	Local oDadosQPS  := JsonObject():New()

	If lSucesso
		oDadosQPS                    := Self:PreparaDadosQPS(oItemAPI, @oDadosQPS)
		lSucesso                     := Self:SalvaRegistroQPSSequencialmente(oDadosQPS)
		Self:lSalvouRegistroNumerico := Iif(!Self:lSalvouRegistroNumerico, lSucesso, .T.)
	EndIf

	FwFreeObj(oDadosQPS)

Return lSucesso


/*/{Protheus.doc} SalvaRegistroTexto
Método para Salvar um Registro TEXTO Recebido via API no DB Protheus
@author brunno.costa
@since  23/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroTexto(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cCpsErro  := ""
	Local lSucesso  := .T.
	Local oRegistro := Nil

	oRegistro := Self:PreparaDadosQPQ(oItemAPI)
	lSucesso  := Self:oAPIManager:ValidaCamposObrigatorios(oRegistro, "|QPQ_CODMED|QPQ_MEDICA|", @cCpsErro)
	If lSucesso
		Self:oAPIManager:SalvaRegistroDB("QPQ", @oRegistro, Self:aCamposQPQ)
	Else
		//"Dados para Integração Inválidos"
		//"Campo(s) obrigatório(s) inválido(s)"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oRegistro:toJson()
	EndIf

	FwFreeObj(oRegistro)
Return lSucesso

/*/{Protheus.doc} PreparaDadosQPQ
Prepara os Dados Recebidos para Gravação na tabela QPQ
@author brunno.costa
@since  23/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return oRegistro, objeto, retorna os dados para gravação na tabela QPQ do DB
/*/
METHOD PreparaDadosQPQ(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local oRegistro     := Nil

	If Self:aCamposQPQ  == Nil
		Self:aCamposQPQ := Self:MapeiaCamposQPQ("*")
	EndIf

	oRegistro               := Self:oAPIManager:InicializaCamposPadroes("QPQ")
	oRegistro["QPQ_CODMED"] := oItemAPI["QPR_CHAVE"]
	oRegistro["QPQ_MEDICA"] := oItemAPI["textDetail"]

	QPQ->(DbSetOrder(1))
	If QPQ->(DbSeek(xFilial("QPQ")+oRegistro["QPQ_CODMED"]))
		oRegistro['R_E_C_N_O_'] := QPQ->(Recno())
	EndIf

	If slQLTMetrics
		QLTMetrics():enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP("API", 1)
	EndIf

Return oRegistro

/*/{Protheus.doc} RetornaResultadosInspecao
Retorna a Lista de Resultados da Inspeção nRecnoQPK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQPK , numérico, número do recno da inspeção na QPK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - aRecnosQPR, array   , NIL e Vazio para retornar todos ou array com os RECNOS da QPR para receber na resposta do POST
@param 04 - nPagina   , numérico, página atual dos dados para consulta
@param 05 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 06 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@param 07 - lMedicao  , lógico  , retorna por referência indicando se existem Medições relacionadas
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RetornaResultadosInspecao(nRecnoQPK, cOrdem, aRecnosQPR, nPagina, nTamPag, cCampos, lMedicao) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias      := Nil
	Local cFIlQAA     := xFilial("QAA")
	Local cFilQP7     := xFilial("QP7")
	Local cFilQP8     := xFilial("QP8")
	Local cFilQPQ     := xFilial("QPQ")
	Local cFIlQPR     := xFilial("QPR")
	Local cFIlQPS     := xFilial("QPS")
	Local cINRecQPR   := ""
	Local cOrdemDB    := Nil
    Local cQuery      := ""
	Local lSucesso    := .T.
    Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)
	Local oExec		  := Nil

	Default cOrdem   := "measurementDate,measurementTime"
	Default nPagina  := 1
	Default nTamPag  := 99
	Default lMedicao := .F.

	If Self:NaoImplantado() .AND. Self:lProcessaRetorno
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf

	nRecnoQPK := Iif(ValType(nRecnoQPK)=="C", Val(nRecnoQPK), nRecnoQPK)
	nRecnoQPK := Iif(ValType(nRecnoQPK)!="N", -1            , nRecnoQPK)

	//cQuery +=  " /*INICIO MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " WITH Query_Recursiva (Recursao, QPS_CODMED, QPS_MEDICA, Recno) "
	cQuery +=  " AS "
	cQuery +=  " ( "
	//cQuery +=      " /*INICIO 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " SELECT 1 As Recursao, "
	cQuery +=              " QPS_CODMED, "
	cQuery +=              "CONCAT(CONCAT('" + '"' + "', Cast(QPS_MEDICA as VarChar(8000)) ),'" + '"' + "')" + " MEDICAO, "
	cQuery +=              " R_E_C_N_O_ Recno "
	cQuery +=      " FROM " + RetSQLName("QPS") + " QPS "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE  "
	cQuery +=           " FROM " + RetSQLName("QPR")
	cQuery +=           " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=               " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=          " QPR  "
	cQuery +=      " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=      " INNER JOIN "
	cQuery +=        "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN ) C2_OP, "
	cQuery +=               " C2_ROTEIRO "
	cQuery +=        " FROM " + RetSQLName("SC2") + " "
	cQuery +=        " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=      " ON C2_OP = QPR_OP "
	cQuery +=        " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE "
	cQuery +=              " FROM " + RetSQLName("QPK")
	cQuery +=              " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + ")) "
	cQuery +=          " QPK  "
	cQuery +=      " ON      QPR.QPR_OP     = QPK.QPK_OP "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=      " WHERE   QPS.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QPS.QPS_FILIAL = '" + cFilQPS + "' "
	//cQuery +=      " /*FIM 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " UNION ALL "
	//cQuery +=      " /*INICIO RECURSIVIDADE*/ "
	cQuery +=      " SELECT  "
	cQuery +=          " Recursao + 1 as Recursao, "
	cQuery +=          " REC.QPS_CODMED, "
	cQuery +=          " CONCAT(CONCAT(CONCAT(REC.QPS_MEDICA , '," + '"' + "' ), QPS.QPS_MEDICA ), '" + '"' + "') AS MEDICAO, "
	cQuery +=          " QPS.Recno "
	cQuery +=      " FROM Query_Recursiva REC "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPS_CODMED, QPS_MEDICA, R_E_C_N_O_ Recno "
	cQuery +=           " FROM " + RetSQLName("QPS")
	cQuery +=           " WHERE   D_E_L_E_T_ = ' ' "
	cQuery +=              " AND  QPS_FILIAL = '" + cFilQPS + "') QPS "
	cQuery +=      " ON      QPS.Recno > REC.Recno  "
	cQuery +=          " AND QPS.QPS_CODMED = REC.QPS_CODMED "
	//cQuery +=      " /*FIM RECURSIVIDADE*/ "
	cQuery +=   " ) "
	
	//cQuery +=   " /*FIM MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " SELECT RECNOQPK, "
	cQuery +=  		  " RECNOTEST, "
	cQuery += 		  " QPR_DTMEDI, "
	cQuery += 		  " QPR_HRMEDI, "
	cQuery += 		  " QPR_ENSR, "
	cQuery += 		  " TIPO, "
	cQuery += 		  " CONCAT(CONCAT('[' , RTRIM(QPS_MEDICA)) , ']') AS MEDICOES, "
	cQuery += 		  " QPR_RESULT, "
	cQuery += 		  " QPQ_MEDICA, "
	cQuery += 		  " QAA_LOGIN, "
	cQuery += 		  " QAA_NOME, "
	cQuery += 		  " QPR_ENSAIO, "
	cQuery += 		  " RECNOQPR, "
	cQuery += 		  " QPR_AMOSTR, "

	If Self:lTemQQM
		cQuery += 		  " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery += 		  " 'F' TEMANEXO "
	EndIf

	cQuery +=  " FROM Query_Recursiva  "
	cQuery +=  " INNER JOIN "
	cQuery +=      " (SELECT QPS_CODMED, Count(*) MAXRECURSAO "
	cQuery +=       " FROM " + RetSQLName("QPS")
	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE  "
	cQuery +=          " FROM " + RetSQLName("QPR")
	cQuery +=          " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=          " QPR  "
	cQuery +=       " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN) AS C2_OP, "
	cQuery +=                " C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	cQuery +=         " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=       " ON C2_OP = QPR_OP "
	cQuery +=         " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE "
	cQuery +=          " FROM " + RetSQLName("QPK")
	cQuery +=          " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + " )) "
	cQuery +=          " QPK  "
	cQuery +=       " ON QPR.QPR_OP = QPK.QPK_OP  "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT  "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=       " WHERE  D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QPS_FILIAL = '" + cFilQPS + "' "
	cQuery +=       " GROUP BY QPS_CODMED) "
	cQuery +=       " QUERYMAXRECURSAO "
	cQuery +=  " ON    Query_Recursiva.QPS_CODMED = QUERYMAXRECURSAO.QPS_CODMED "
	cQuery +=      " AND Query_Recursiva.Recursao = QUERYMAXRECURSAO.MAXRECURSAO "
	cQuery +=  " INNER JOIN     "
	cQuery +=      " (    SELECT  "
	cQuery +=              " '' AS QPQ_MEDICA, "
	cQuery +=              " 'N' AS TIPO, "
	cQuery +=              " QPR.QPR_DTMEDI, "
	cQuery +=              " QPR.QPR_HRMEDI, "
	cQuery +=              " QPR.QPR_ENSR, "
	cQuery +=              " QPR.QPR_RESULT, "
	cQuery +=              " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=              " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=              " QAA.QAA_LOGIN, "
	cQuery +=              " QAA.QAA_NOME, "
	cQuery +=              " QPR.QPR_ENSAIO, "
	cQuery +=              " QP7.R_E_C_N_O_ RECNOTEST, "
	cQuery +=              " QPR_CHAVE, "
	cQuery +=              " QPR.QPR_AMOSTR, "
	cQuery +=              " QPR.QPR_FILIAL "
	cQuery +=          " FROM            "
	cQuery +=                  " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_FILIAL "
	cQuery +=                  " FROM " + RetSQLName("QPR")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                      " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=                  " QPR  "

	cQuery +=              " INNER JOIN "
	cQuery +=                "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN) AS C2_OP, "
	cQuery +=                       " C2_ROTEIRO "
	cQuery +=                " FROM " + RetSQLName("SC2") + " "
	cQuery +=                " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=              " ON C2_OP = QPR_OP "
	cQuery +=                " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE "
	cQuery +=                  " FROM " + RetSQLName("QPK")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                      " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + ")) "
	cQuery +=                  " QPK  "
	cQuery +=              " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=                  " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=                  " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=                  " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=                   " FROM " + RetSQLName("QAA")
	cQuery +=                  " WHERE D_E_L_E_T_=' ' "
	cQuery +=                      " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=                  " QAA "
	cQuery +=              " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QP7_PRODUT, QP7_REVI, QP7_ENSAIO, QP7_LABOR, R_E_C_N_O_, QP7_OPERAC, QP7_CODREC "
	cQuery +=                   " FROM " + RetSQLName("QP7")
	cQuery +=                   " WHERE D_E_L_E_T_  = ' ' "
	cQuery +=                      " AND QP7_FILIAL = '" + cFilQP7 + "') "
	cQuery +=              " QP7 "
	cQuery +=              " ON QP7.QP7_PRODUT   = QPR.QPR_PRODUT  "
	cQuery +=               " AND QP7.QP7_REVI   = QPR.QPR_REVI "
	cQuery +=               " AND QP7.QP7_LABOR  = QPR.QPR_LABOR "
	cQuery +=               " AND QP7.QP7_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=               " AND QP7.QP7_OPERAC = QPR.QPR_OPERAC "
	cQuery +=               " AND QP7.QP7_CODREC = QPR.QPR_ROTEIR "
	cQuery +=      " ) NAORECURSIVA  "
	cQuery +=  " ON NAORECURSIVA.QPR_CHAVE = Query_Recursiva.QPS_CODMED "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QPR_FILIAL = QQM_FILQPR "
	EndIf
	
	If aRecnosQPR != Nil .And. !Empty(aRecnosQPR)
		cINRecQPR := FormatIn(ArrToKStr(aRecnosQPR),"|")
		cQuery    += "WHERE RECNOQPR IN " + cINRecQPR
	EndIf

	cQuery +=  " UNION "

	//RESULTADO DE TEXTO
	cQuery += " SELECT   "
	cQuery +=     " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=     " QP8.R_E_C_N_O_ RECNOTEST, "
	cQuery +=     " QPR.QPR_DTMEDI, "
	cQuery +=     " QPR.QPR_HRMEDI, "
	cQuery +=     " QPR.QPR_ENSR, "
	cQuery +=     " 'T' AS TIPO, "
	cQuery +=     " '[]' AS MEDICOES, "
	cQuery +=     " QPR.QPR_RESULT, "
	cQuery +=     " QPQ_MEDICA, "
	cQuery +=     " QAA.QAA_LOGIN, "
	cQuery +=     " QAA.QAA_NOME, "
	cQuery +=     " QPR.QPR_ENSAIO, "
	cQuery +=     " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=     " QPR.QPR_AMOSTR, "
	If Self:lTemQQM
		cQuery +=     " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery +=     " 'F' TEMANEXO "
	EndIf
	cQuery += " FROM "
	cQuery +=         " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_FILIAL "
	cQuery +=         " FROM " + RetSQLName("QPR")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=             " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=         " QPR "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QPR_FILIAL = QQM_FILQPR "
	EndIf

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN) C2_OP, "
	cQuery +=                " C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	cQuery +=         " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=       " ON C2_OP = QPR_OP "
	cQuery +=         " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE "
	cQuery +=         " FROM " + RetSQLName("QPK")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=             " AND (R_E_C_N_O_ =  " + cValToChar(nRecnoQPK) + " )) "
	cQuery +=         " QPK "
	cQuery +=     " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=      " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=      " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=      " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=         " FROM " + RetSQLName("QAA")
	cQuery +=         " WHERE D_E_L_E_T_=' ' "
	cQuery +=             " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=         " QAA "
	cQuery +=     " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QP8_PRODUT, QP8_REVI, QP8_ENSAIO, QP8_LABOR, R_E_C_N_O_, QP8_OPERAC, QP8_CODREC "
	cQuery +=         " FROM " + RetSQLName("QP8")
	cQuery +=         " WHERE D_E_L_E_T_  = ' ' "
	cQuery +=             " AND QP8_FILIAL = '" + cFilQP8 + "') "
	cQuery +=     " QP8 "
	cQuery +=     " ON QP8.QP8_PRODUT   = QPR.QPR_PRODUT "
	cQuery +=      " AND QP8.QP8_REVI   = QPR.QPR_REVI "
	cQuery +=      " AND QP8.QP8_LABOR  = QPR.QPR_LABOR "
	cQuery +=      " AND QP8.QP8_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=      " AND QP8.QP8_OPERAC = QPR.QPR_OPERAC "
	cQuery +=      " AND QP8.QP8_CODREC = QPR.QPR_ROTEIR "

	cQuery += 	" INNER JOIN "
	cQuery +=     " (SELECT QPQ_CODMED, QPQ_MEDICA "
	cQuery +=  	  " FROM " + RetSQLName("QPQ")
	cQuery +=  	  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=         " AND QPQ_FILIAL = '" + cFilQPQ + "') "
	cQuery +=     " QPQ "
	cQuery +=     " ON QPQ.QPQ_CODMED = QPR.QPR_CHAVE "

	If aRecnosQPR != Nil .And. !Empty(aRecnosQPR)
		cQuery    += "WHERE QPR.R_E_C_N_O_ IN " + cINRecQPR
	EndIf

	cOrdemDB := oAPIManager:RetornaOrdemDB(cOrdem)
	If !Empty(cOrdemDB)
		cQuery += " ORDER BY " + cOrdemDB
	EndIf
	
    cQuery := oAPIManager:ChangeQueryAllDB(cQuery)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
	
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

	Self:cErrorMessage := ""

	lMedicao := (cAlias)->(!Eof())
	If Self:lProcessaRetorno
    	lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())
	oExec:Destroy()
	oExec := nil 
Return lSucesso

/*/{Protheus.doc} RetornaResultadosInspecaoPorEnsaio
Retorna a Lista de Resultados da Inspeção nRecnoQPK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQPK , numérico, número do recno da inspeção na QPK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - cIDTest   , caracter, ID do ensaio relacionado
@param 04 - cOperacao , caracter, código da operação relacionada
@param 05 - nPagina   , numérico, página atual dos dados para consulta
@param 06 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RetornaResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias      := Nil
	Local lSucesso    := .T.
    Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)

	Default cOrdem  := "measurementDate,measurementTime"
	Default nPagina := 1
	Default nTamPag := 99

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return
	EndIf

	If (lSucesso := Self:CriaAliasResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos, @cAlias, oAPIManager))
    	lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())

Return lSucesso

/*/{Protheus.doc} CriaAliasResultadosInspecao
Cria Alias para Retornar a Lista de Resultados da Inspeção nRecnoQPK
@author brunno.costa
@since  23/05/2022
@param 01 - nRecnoQPK , numérico, número do recno da inspeção na QPK
@param 02 - cOrdem    , caracter, ordem para retorno dos resultados do banco
@param 03 - cIDTest   , caracter, ID do ensaio relacionado
@param 04 - cOperacao , caracter, operação da inspeção relacionada
@param 05 - nPagina   , numérico, página atual dos dados para consulta
@param 06 - nTamPag   , numérico, tamanho de página padrão com a quantidade de registros para retornar
@param 07 - cCampos   , caracter, campos que deverão estar contidos na mensagem
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD CriaAliasResultadosInspecaoPorEnsaio(nRecnoQPK, cOrdem, cIDTest, cOperacao, nPagina, nTamPag, cCampos, cAlias, oAPIManager) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cFIlQAA     := xFilial("QAA")
	Local cFilQP7     := xFilial("QP7")
	Local cFilQP8     := xFilial("QP8")
	Local cFilQPQ     := xFilial("QPQ")
	Local cFIlQPR     := xFilial("QPR")
	Local cFIlQPS     := xFilial("QPS")
	Local cOrdemDB    := Nil
    Local cQuery      := ""
	Local lSucesso    := .T.
	Local oExec		  := Nil

	Default cOrdem      := "measurementDate,measurementTime"
	Default nPagina     := 1
	Default nTamPag     := 99
    Default oAPIManager := QualityAPIManager():New(Self:MapeiaCamposAPI(cCampos), Self:oWSRestFul)

	nRecnoQPK := Iif(ValType(nRecnoQPK)=="C", Val(nRecnoQPK), nRecnoQPK)
	nRecnoQPK := Iif(ValType(nRecnoQPK)!="N", -1            , nRecnoQPK)

	//cQuery +=  " /*INICIO MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " WITH Query_Recursiva (Recursao, QPS_CODMED, QPS_MEDICA, Recno) "
	cQuery +=  " AS "
	cQuery +=  " ( "
	//cQuery +=      " /*INICIO 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " SELECT 1 As Recursao, "
	cQuery +=              " QPS_CODMED, "
	cQuery +=              "CONCAT(CONCAT('" + '"' + "', Cast(QPS_MEDICA as VarChar(8000))) ,'" + '"' + "')" + " MEDICAO, "
	cQuery +=              " R_E_C_N_O_ Recno "
	cQuery +=      " FROM " + RetSQLName("QPS") + " QPS "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE  "
	cQuery +=           " FROM " + RetSQLName("QPR")
	cQuery +=           " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=               " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=          " QPR  "
	cQuery +=      " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=      " INNER JOIN "
	cQuery +=        "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN ) C2_OP, "
	cQuery +=               " C2_ROTEIRO "
	cQuery +=        " FROM " + RetSQLName("SC2") + " "
	cQuery +=        " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=      " ON C2_OP = QPR_OP "
	cQuery +=        " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE "
	cQuery +=              " FROM " + RetSQLName("QPK")
	cQuery +=              " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + ")) "
	cQuery +=          " QPK  "
	cQuery +=      " ON      QPR.QPR_OP     = QPK.QPK_OP "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=      " WHERE   QPS.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QPS.QPS_FILIAL = '" + cFilQPS + "' "
	//cQuery +=      " /*FIM 1 ANCORA DA RECURSIVIDADE*/ "
	cQuery +=      " UNION ALL "
	//cQuery +=      " /*INICIO RECURSIVIDADE*/ "
	cQuery +=      " SELECT  "
	cQuery +=          " Recursao + 1 as Recursao, "
	cQuery +=          " REC.QPS_CODMED, "
	cQuery +=          " CONCAT(CONCAT(CONCAT(REC.QPS_MEDICA , '," + '"' + "') , QPS.QPS_MEDICA) , '" + '"' + "') MEDICAO, "
	cQuery +=          " QPS.Recno "
	cQuery +=      " FROM Query_Recursiva REC "
	cQuery +=      " INNER JOIN "
	cQuery +=          " (SELECT QPS_CODMED, QPS_MEDICA, R_E_C_N_O_ Recno "
	cQuery +=           " FROM " + RetSQLName("QPS")
	cQuery +=           " WHERE   D_E_L_E_T_ = ' ' "
	cQuery +=              " AND  QPS_FILIAL = '" + cFilQPS + "') QPS "
	cQuery +=      " ON      QPS.Recno > REC.Recno  "
	cQuery +=          " AND QPS.QPS_CODMED = REC.QPS_CODMED "
	//cQuery +=      " /*FIM RECURSIVIDADE*/ "
	cQuery +=   " ) "
	
	//cQuery +=   " /*FIM MONTAGEM QUERY RECURSIVA*/ "
	cQuery +=  " SELECT RECNOQPK, "
	cQuery +=         " RECNOTEST, "
	cQuery +=         " QPR_DTMEDI, "
	cQuery +=         " QPR_HRMEDI, "
	cQuery +=         " QPR_ENSR, "
	cQuery +=         " TIPO, "
	cQuery +=         " CONCAT(CONCAT('[' , RTRIM(QPS_MEDICA)) , ']') MEDICOES, "
	cQuery +=         " QPR_RESULT, "
	cQuery +=         " QPQ_MEDICA, "
	cQuery +=         " QAA_LOGIN, "
	cQuery +=         " QAA_NOME, "
	cQuery +=         " QPR_ENSAIO, "
	cQuery +=         " RECNOQPR, "
	cQuery +=         " QPR_AMOSTR, "
	
	If Self:lTemQQM
		cQuery +=         " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery +=         " 'F' TEMANEXO "
	EndIf

	cQuery +=  " FROM Query_Recursiva  "
	cQuery +=  " INNER JOIN "
	cQuery +=      " (SELECT QPS_CODMED, Count(*) MAXRECURSAO "
	cQuery +=       " FROM " + RetSQLName("QPS")
	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE  "
	cQuery +=          " FROM " + RetSQLName("QPR")
	cQuery +=          " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=          " QPR  "
	cQuery +=       " ON QPR.QPR_CHAVE = QPS_CODMED "

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN) AS C2_OP, "
	cQuery +=                " C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	cQuery +=         " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=       " ON C2_OP = QPR_OP "
	cQuery +=         " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=       " INNER JOIN "
	cQuery +=          " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, QPK_LOTE "
	cQuery +=          " FROM " + RetSQLName("QPK")
	cQuery +=          " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=              " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + " )) "
	cQuery +=          " QPK  "
	cQuery +=       " ON QPR.QPR_OP = QPK.QPK_OP  "
	cQuery +=          " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT  "
	cQuery +=          " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=          " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=       " WHERE  D_E_L_E_T_ = ' ' "
	cQuery +=          " AND QPS_FILIAL = '" + cFilQPS + "' "
	cQuery +=       " GROUP BY QPS_CODMED) "
	cQuery +=       " QUERYMAXRECURSAO "
	cQuery +=  " ON    Query_Recursiva.QPS_CODMED = QUERYMAXRECURSAO.QPS_CODMED "
	cQuery +=      " AND Query_Recursiva.Recursao = QUERYMAXRECURSAO.MAXRECURSAO "
	cQuery +=  " INNER JOIN     "
	cQuery +=      " (    SELECT  "
	cQuery +=              " '' QPQ_MEDICA, "
	cQuery +=              " 'N' TIPO, "
	cQuery +=              " QPR.QPR_DTMEDI, "
	cQuery +=              " QPR.QPR_HRMEDI, "
	cQuery +=              " QPR.QPR_ENSR, "
	cQuery +=              " QPR.QPR_RESULT, "
	cQuery +=              " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=              " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=              " QAA.QAA_LOGIN, "
	cQuery +=              " QAA.QAA_NOME, "
	cQuery +=              " QPR.QPR_ENSAIO, "
	cQuery +=              " QP7.R_E_C_N_O_ RECNOTEST, "
	cQuery +=              " QPR_CHAVE, "
	cQuery +=              " QPR.QPR_AMOSTR, "
	cQuery += 			   " QPR.QPR_FILIAL  "
	cQuery +=          " FROM            "
	cQuery +=                  " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_FILIAL "
	cQuery +=                  " FROM " + RetSQLName("QPR")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cOperacao)
		cQuery +=                      " AND (QPR_OPERAC = '" + cOperacao + "') "
	EndIf

	cQuery +=                      " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=                  " QPR  "

	cQuery +=              " INNER JOIN "
	cQuery +=                "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN ) C2_OP, "
	cQuery +=                       " C2_ROTEIRO "
	cQuery +=                " FROM " + RetSQLName("SC2") + " "
	cQuery +=                " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=              " ON C2_OP = QPR_OP "
	cQuery +=                " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE "
	cQuery +=                  " FROM " + RetSQLName("QPK")
	cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                      " AND (R_E_C_N_O_ = " + cValToChar(nRecnoQPK) + ")) "
	cQuery +=                  " QPK  "
	cQuery +=              " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=                  " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=                  " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=                  " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=                   " FROM " + RetSQLName("QAA")
	cQuery +=                  " WHERE D_E_L_E_T_=' ' "
	cQuery +=                      " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=                  " QAA "
	cQuery +=              " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=              " INNER JOIN "
	cQuery +=                  " (SELECT QP7_PRODUT, QP7_REVI, QP7_ENSAIO, QP7_LABOR, R_E_C_N_O_, QP7_OPERAC, QP7_CODREC "
	cQuery +=                   " FROM " + RetSQLName("QP7")
	cQuery +=                   " WHERE D_E_L_E_T_  = ' ' "

	If !Empty(cOperacao)
		cQuery +=                      " AND (QP7_OPERAC = '" + cOperacao + "') "
	EndIf
	
	If cIDTest != Nil .And. !Empty(cIDTest)
		cQuery +=                  " AND QP7_ENSAIO = '" + cIDTest + "'"
	EndIf

	cQuery +=                      " AND QP7_FILIAL = '" + cFilQP7 + "') "
	cQuery +=              " QP7 "
	cQuery +=              " ON QP7.QP7_PRODUT   = QPR.QPR_PRODUT  "
	cQuery +=               " AND QP7.QP7_REVI   = QPR.QPR_REVI "
	cQuery +=               " AND QP7.QP7_LABOR  = QPR.QPR_LABOR "
	cQuery +=               " AND QP7.QP7_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=               " AND QP7.QP7_OPERAC = QPR.QPR_OPERAC "
	cQuery +=               " AND QP7.QP7_CODREC = QPR.QPR_ROTEIR "
	cQuery +=      " ) NAORECURSIVA  "
	cQuery +=  " ON NAORECURSIVA.QPR_CHAVE = Query_Recursiva.QPS_CODMED "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QPR_FILIAL = QQM_FILQPR "
	EndIf

	cQuery +=  " UNION "

	//RESULTADO DE TEXTO
	cQuery += " SELECT   "
	cQuery +=     " QPK.R_E_C_N_O_ RECNOQPK, "
	cQuery +=     " QP8.R_E_C_N_O_ RECNOTEST, "
	cQuery +=     " QPR.QPR_DTMEDI, "
	cQuery +=     " QPR.QPR_HRMEDI, "
	cQuery +=     " QPR.QPR_ENSR, "
	cQuery +=     " 'T' AS TIPO, "
	cQuery +=     " '[]' AS MEDICOES, "
	cQuery +=     " QPR.QPR_RESULT, "
	cQuery +=     " QPQ_MEDICA, "
	cQuery +=     " QAA.QAA_LOGIN, "
	cQuery +=     " QAA.QAA_NOME, "
	cQuery +=     " QPR.QPR_ENSAIO, "
	cQuery +=     " QPR.R_E_C_N_O_ RECNOQPR, "
	cQuery +=     " QPR.QPR_AMOSTR, "

	If Self:lTemQQM
	cQuery += 	  " COALESCE(TEMANEXO,'F') TEMANEXO "
	Else
		cQuery += 	  " 'F' TEMANEXO "
	EndIf
	cQuery += " FROM "
	cQuery +=         " (SELECT QPR_OP, QPR_PRODUT, QPR_REVI, QPR_DTMEDI, QPR_HRMEDI, QPR_ENSR, QPR_RESULT, R_E_C_N_O_, QPR_LABOR, QPR_ENSAIO, QPR_OPERAC, QPR_CHAVE, QPR_ROTEIR, QPR_AMOSTR, QPR_LOTE, QPR_FILIAL "
	cQuery +=         " FROM " + RetSQLName("QPR")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cOperacao)
		cQuery +=                      " AND (QPR_OPERAC = '" + cOperacao + "') "
	EndIf

	cQuery +=             " AND (QPR_FILIAL = '" + cFilQPR + "')) "
	cQuery +=         " QPR "

	If Self:lTemQQM
		cQuery += 		 " LEFT OUTER JOIN "
		cQuery += 		  " (SELECT DISTINCT 'T' TEMANEXO, "
		cQuery += 		 		   " QQM_FILQPR,  "
		cQuery += 				   " QQM_CHAVE "
		cQuery += 		  " FROM " + RetSqlName("QQM")
		cQuery +=					" WHERE D_E_L_E_T_ = ' ' ) QQM ON QPR_CHAVE  = QQM.QQM_CHAVE "
		cQuery += 												" AND QPR_FILIAL = QQM_FILQPR "
	EndIf

	cQuery +=       " INNER JOIN "
	cQuery +=         "(SELECT CONCAT(CONCAT(C2_NUM , C2_ITEM) , C2_SEQUEN) AS C2_OP, "
	cQuery +=                " C2_ROTEIRO "
	cQuery +=         " FROM " + RetSQLName("SC2") + " "
	cQuery +=         " WHERE D_E_L_E_T_=' ' AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
	cQuery +=       " ON C2_OP = QPR_OP "
	cQuery +=         " AND C2_ROTEIRO = QPR_ROTEIR "

	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QPK_OP, QPK_PRODUT, QPK_REVI, R_E_C_N_O_, QPK_LOTE "
	cQuery +=         " FROM " + RetSQLName("QPK")
	cQuery +=         " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=             " AND (R_E_C_N_O_ =  " + cValToChar(nRecnoQPK) + " )) "
	cQuery +=         " QPK "
	cQuery +=     " ON QPR.QPR_OP = QPK.QPK_OP "
	cQuery +=      " AND QPR.QPR_PRODUT = QPK.QPK_PRODUT "
	cQuery +=      " AND QPR.QPR_REVI   = QPK.QPK_REVI "
	cQuery +=      " AND QPR.QPR_LOTE   = QPK.QPK_LOTE "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QAA_LOGIN, QAA_MAT, QAA_NOME "
	cQuery +=         " FROM " + RetSQLName("QAA")
	cQuery +=         " WHERE D_E_L_E_T_=' ' "
	cQuery +=             " AND QAA_FILIAL='" + cFilQAA + "') "
	cQuery +=         " QAA "
	cQuery +=     " ON QAA.QAA_MAT = QPR.QPR_ENSR "
	cQuery +=     " INNER JOIN "
	cQuery +=         " (SELECT QP8_PRODUT, QP8_REVI, QP8_ENSAIO, QP8_LABOR, R_E_C_N_O_, QP8_OPERAC, QP8_CODREC "
	cQuery +=         " FROM " + RetSQLName("QP8")
	cQuery +=         " WHERE D_E_L_E_T_  = ' ' "
	
	If !Empty(cOperacao)
		cQuery +=                      " AND (QP8_OPERAC = '" + cOperacao + "') "
	EndIf

	If cIDTest != Nil .And. !Empty(cIDTest)
		cQuery +=         " AND QP8_ENSAIO = '" + cIDTest + "'"
	EndIf

	cQuery +=             " AND QP8_FILIAL = '" + cFilQP8 + "') "
	cQuery +=     " QP8 "
	cQuery +=     " ON QP8.QP8_PRODUT   = QPR.QPR_PRODUT "
	cQuery +=      " AND QP8.QP8_REVI   = QPR.QPR_REVI "
	cQuery +=      " AND QP8.QP8_LABOR  = QPR.QPR_LABOR "
	cQuery +=      " AND QP8.QP8_ENSAIO = QPR.QPR_ENSAIO "
	cQuery +=      " AND QP8.QP8_OPERAC = QPR.QPR_OPERAC "
	cQuery +=      " AND QP8.QP8_CODREC = QPR.QPR_ROTEIR "

	cQuery += 	" INNER JOIN "
	cQuery +=     " (SELECT QPQ_CODMED, QPQ_MEDICA "
	cQuery +=  	  " FROM " + RetSQLName("QPQ")
	cQuery +=  	  " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=         " AND QPQ_FILIAL = '" + cFilQPQ + "') "
	cQuery +=     " QPQ "
	cQuery +=     " ON QPQ.QPQ_CODMED = QPR.QPR_CHAVE "


	cOrdemDB := oAPIManager:RetornaOrdemDB(cOrdem)
	If !Empty(cOrdemDB)
		cQuery += " ORDER BY " + cOrdemDB
	EndIf
	
    cQuery := oAPIManager:ChangeQueryAllDB(cQuery)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "

	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

	Self:cErrorMessage := ""

	oExec:Destroy()
	oExec := nil 
Return lSucesso

/*/{Protheus.doc} ProcessaItensRecebidos
Processa os Itens Recebidos
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - aRecnosQPR, array , retorna por referência os RECNOS da QPR relacionados
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD ProcessaItensRecebidos(oDadosJson, aRecnosQPR) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local lSucesso   := .T.
	Local nIndReg    := Nil
	Local nRegistros := Len(oDadosJson["items"])
	Local oItemAPI   := Nil
	Local oRegistro  := Nil

	Default aRecnosQPR := {}

	Self:nRegistros := nRegistros
	If nRegistros <= 0
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não existem registros para gravação"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0009
	Else

		Self:aCamposAPI := Iif(Self:aCamposAPI == Nil, Self:MapeiaCamposAPI("*"), Self:aCamposAPI)
		Self:aCamposQPR := IIf(Self:aCamposQPR == Nil, Self:MapeiaCamposQPR("*"), Self:aCamposQPR)

		For nIndReg := 1 to nRegistros
			oItemAPI := oDadosJson["items"][nIndReg]
			
			lSucesso := Self:ValidaFormatosCamposItem(oItemAPI)

			lSucesso := IIf(lSucesso, Self:ValidaUsuarioProtheus(oItemAPI), lSucesso)

			lSucesso := IIf(lSucesso, Self:PreparaRegistroQPR(oItemAPI, @oRegistro), lSucesso)

			Self:RegistraAnexos(oItemAPI, oRegistro)

			lSucesso := IIf(lSucesso, Self:ValidaEnsaiador(oRegistro), lSucesso)

			lSucesso := IIf(lSucesso, Self:SalvaRegistros(oItemAPI, oRegistro, @aRecnosQPR), lSucesso)

			If !lSucesso
				Exit
			EndIf

		Next nIndReg

	EndIf
Return lSucesso

/*/{Protheus.doc} PreparaRegistroInclusaoQPR
Prepara Registro
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, retorna por referência os dados para gravação na tabela QPR do DB
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD PreparaRegistroInclusaoQPR(oItemAPI, oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cTipo      := Nil
	Local lSucesso   := .T.

	oRegistro := Self:oAPIManager:InicializaCamposPadroes("QPR")
	oRegistro := Self:oAPIManager:AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, "QPR", Self:aCamposAPI)

	cTipo := oItemAPI["testType"]
	
	If cTipo == "N"        //Tipo N -> Array Numérico -> QP7
		lSucesso := Self:RecuperaCamposQP7paraQPR(@oRegistro, oItemAPI["recnoTest"])

	ElseIf cTipo == "T"    //Tipo T -> Texto -> QP8
		lSucesso := Self:RecuperaCamposQP8paraQPR(@oRegistro, oItemAPI["recnoTest"])

	EndIf

	If lSucesso
		lSucesso := Self:RecuperaCamposQPKParaQPR(@oRegistro, oItemAPI["recnoInspection"])
	EndIf

	If lSucesso
		oRegistro["QPR_CHAVE"]     := oItemAPI["QPR_CHAVE"]
		If oItemAPI["QPR_CHAVE"] == Nil
			If Self:EnsaioComMedia(cTipo, QP7->QP7_FORMUL)
				Self:AtualizaChaveQPRParaMedia(oRegistro)
			Else
				oRegistro["QPR_CHAVE"] := Self:GeraChaveQPR()
			EndIf
			oItemAPI["QPR_CHAVE"]  := oRegistro["QPR_CHAVE"]
		EndIf
		Self:AtualizaEnsaiadorQPR(oItemAPI["protheusLogin"], @oRegistro)
	EndIf

Return lSucesso

/*/{Protheus.doc} EnsaioComMedia
Avalia se é um ensaio numérico com fórmula de média
@author brunno.costa
@since  04/10/2022
@return lEnsaioComMedia, lógico, indica se o ensaio atual corresponde a um registro numérico e com média na fórmula
/*/
METHOD EnsaioComMedia(cTipo, cFormula) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local lEnsaioComMedia := cTipo == "N" .AND. At("AVG", cFormula)
Return lEnsaioComMedia

/*/{Protheus.doc} GeraChaveQPR
Gecha próxima numeração para o campo QPR_CHAVE
@author brunno.costa
@since  23/05/2022
@return cChave, caracter, próxima numeração para a chave
/*/
METHOD GeraChaveQPR() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local nSaveSX8 := GetSX8Len()
	Local cChave   := QA_SXESXF("QPR","QPR_CHAVE",,4)
	While ( GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo
Return cChave

/*/{Protheus.doc} AtualizaChaveQPRParaMedia
Recupera a Chave da QPR para Registro de Média, ou seja, primeiro registro existente da amostra ou chave nova
@author brunno.costa
@since  04/10/2022
@param 01 - oRegistro, objeto, registro JSON com os dados para gravação na QPR que serão atualizados
/*/
METHOD AtualizaChaveQPRParaMedia(oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	QPR->(DbSetOrder(1))
	If QPR->(DbSeek(xFilial("QPR")+oRegistro["QPR_OP"]+oRegistro["QPR_OPERAC"]+oRegistro["QPR_LABOR"]+oRegistro["QPR_ENSAIO"]))
		oRegistro["QPR_CHAVE"]  := QPR->QPR_CHAVE
		oRegistro['R_E_C_N_O_'] := QPR->(Recno())
	EndIf
	If oRegistro["QPR_CHAVE"] == Nil
		oRegistro["QPR_CHAVE"] := Self:GeraChaveQPR()
	EndIf
Return

/*/{Protheus.doc} AtualizaEnsaiadorQPR
Atualiza Ensaiador no oRegistro com base no cLogin recebido
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin   , caracter, nome do login de usuário utilizado no Protheus pelo usuário do APP
@param 02 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
/*/
METHOD AtualizaEnsaiadorQPR(cLogin, oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	DbSelectArea("QAA")
	QAA->(DbSetOrder(6))
	If QAA->(DbSeek(Upper(cLogin))) .OR. QAA->(DbSeek(Lower(cLogin)))
		oRegistro["QPR_FILMAT"] := QAA->QAA_FILIAL
		oRegistro["QPR_ENSR"  ] := QAA->QAA_MAT
	EndIf
Return 

/*/{Protheus.doc} RecuperaCamposQP7paraQPR
Recupera campos referência da tabela QP7 para gravação na QPR
@author brunno.costa
@since  23/05/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
@param 02 - nRecnoQP7, numérico, recno do registro referência da QP7
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQP7paraQPR(oRegistro, nRecnoQP7) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCampo     := Nil
	Local cCampoQP7  := Nil
	Local lSucesso   := .T.
	Local nCamposQPR := Len(Self:aCamposQPR)
	Local nIndCampo  := 0

	Default nRecnoQP7   := -1

	DbSelectArea("QP7")
	QP7->(DbGoTo(nRecnoQP7))
	If nRecnoQP7 <= 0 .OR. QP7->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro da QP7 de RECNO[recnoTest]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0011 + cValToChar(nRecnoQP7)
	Else
		For nIndCampo := 1 to nCamposQPR
			If Self:aCamposQPR[nIndCampo][nPosCPS_Alias] == "QP7QP8"
				cCampo            := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus]
				cCampoQP7         := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus_Externo]
				oRegistro[cCampo] := QP7->&(cCampoQP7)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} RecuperaCamposQP8paraQPR
Recupera campos referência da tabela QP8 para gravação na QPR
@author brunno.costa
@since  23/06/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
@param 02 - nRecnoQP8, numérico, recno do registro referência da QP8
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQP8paraQPR(oRegistro, nRecnoQP8) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCampo     := Nil
	Local cCampoQP8  := Nil
	Local lSucesso   := .T.
	Local nCamposQPR := Len(Self:aCamposQPR)
	Local nIndCampo  := 0

	Default nRecnoQP8   := -1

	DbSelectArea("QP8")
	QP8->(DbGoTo(nRecnoQP8))
	If nRecnoQP8 <= 0 .OR. QP8->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro da QP8 de RECNO[recnoTest]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0019 + cValToChar(nRecnoQP8)
	Else
		For nIndCampo := 1 to nCamposQPR
			If Self:aCamposQPR[nIndCampo][nPosCPS_Alias] == "QP7QP8"
				cCampo            := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus]
				cCampoQP8         := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus_Externo]
				cCampoQP8         := StrTran(cCampoQP8, "QP7", "QP8")
				oRegistro[cCampo] := QP8->&(cCampoQP8)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} RecuperaCamposQPKParaQPR
Recupera campos referência da tabela QPK para gravação na QPR
@author brunno.costa
@since  23/05/2022
@param 01 - oRegistro, objeto  , registro JSON com os dados para gravação na QPR que serão atualizados
@param 02 - nRecnoQPK, numérico, recno do registro referência da QPK
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD RecuperaCamposQPKParaQPR(oRegistro, nRecnoQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCampo     := Nil
	Local cCampoQPK  := Nil
	Local lSucesso   := .T.
	Local nCamposQPR := Len(Self:aCamposQPR)
	Local nIndCampo  := 0

	Default nRecnoQPK   := -1

	DbSelectArea("QPK")
	QPK->(DbGoTo(nRecnoQPK))
	If nRecnoQPK <= 0 .OR. QPK->(Eof())
		lSucesso              := .F.
		//"Dados para Integração Inválidos"
		//"Não foi possível encontrar o registro da QPK de RECNO[recnoInspection]: "
		Self:cErrorMessage    := STR0008                        
		Self:cDetailedMessage := STR0012 + cValToChar(nRecnoQPK)
	Else
		For nIndCampo := 1 to nCamposQPR
			If Self:aCamposQPR[nIndCampo][nPosCPS_Alias] == "QPK"
				cCampo            := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus]
				cCampoQPK         := Self:aCamposQPR[nIndCampo][nPosCPS_Protheus_Externo]
				oRegistro[cCampo] := QPK->&(cCampoQPK)
			EndIf
		Next nIndCampo
	EndIf
	
Return lSucesso

/*/{Protheus.doc} PreparaDadosQPS
Prepara os Dados Recebidos para Gravação na tabela QPS
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - oDadosQPS , objeto, retorna por referência os dados para gravação na tabela QPR do DB
@return oDadosQPS, objeto, retorna os dados para gravação na tabela QPS do DB
/*/
METHOD PreparaDadosQPS(oItemAPI, oDadosQPS) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local nIndMedicoes := Nil
	Local nMedicoes    := Nil
	Local oRegistro    := Nil
	Local cJsonQPSDef  := ""

	If Self:aCamposQPS       == Nil
		Self:aCamposQPS      := Self:MapeiaCamposQPS("*")
	EndIf

	oDadosQPS['items'  ]     := {}

	oRegistro   := Self:oAPIManager:InicializaCamposPadroes("QPS")
	cJsonQPSDef := oRegistro:toJson()

	nMedicoes := Len(oItemAPI["measurements"])
	For nIndMedicoes := 1 to nMedicoes
		oRegistro                   := JsonObject():New()
		oRegistro:fromJson(cJsonQPSDef)
		oRegistro["QPS_MEDICA"]     := oItemAPI["measurements"][nIndMedicoes]
		oRegistro["QPS_CODMED"]     := oItemAPI["QPR_CHAVE"]
		If nIndMedicoes == 1
			oRegistro["QPS_INDMED"] := "A"
		Elseif nIndMedicoes == 2
			oRegistro["QPS_INDMED"] := "N"
		Elseif nIndMedicoes == 3
			oRegistro["QPS_INDMED"] := "P"
		EndIf
		//TODO O QUE É ISSO NO FONTE?
		//If nY == 4
		//	QPS->QPS_MEDICA := StrTran(Str(aResultados[nPosOpe,_MED,nPosLab,nPosEns,nPosMed,(nMed+nY)-1],TamSx3("QPS_MEDICA")[1],2),".",",")
		//Else
		//	QPS->QPS_MEDICA := Str(aResultados[nPosOpe,_MED,nPosLab,nPosEns,nPosMed,(nMed+nY)-1],TamSx3("QPS_MEDICA")[1],TamSx3("QPS_MEDIPP")[2])
		//EndIf
		aAdd(oDadosQPS['items'], oRegistro)
	Next nIndMedicoes

	If slQLTMetrics
		QLTMetrics():enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP("API", nMedicoes)
	EndIf

Return oDadosQPS

/*/{Protheus.doc} SalvaRegistroQPSSequencialmente
Grava os Registros NUMÉRICOS Sequencialmente na Tabela QPS
@author brunno.costa
@since  23/05/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON que serão gravados na QPS
@return lSucesso, lógico, indica se o processo foi executado com sucesso
/*/
METHOD SalvaRegistroQPSSequencialmente(oDadosJson) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cCpsErro   := ""
	Local cFilQPS    := xFilial("QPS")
	Local lSucesso   := .T.
	Local nIndReg    := Nil
	Local nRegistros := Len(oDadosJson[ 'items' ])

	If nRegistros > 0
		If oDadosJson['items'][1]['QPS_CODMED'] == Nil .OR. oDadosJson['items'][1]['QPS_MEDICA'] == Nil
			//"Dados para Integração Inválidos"
			//"Dados para gravação na QPS inválidos no registro: "
			Self:cErrorMessage    := STR0008                                  
			Self:cDetailedMessage := STR0013 + oDadosJson['items'][1]:toJson()
			lSucesso              := .F.
			Return lSucesso
		EndIf

		DbSelectArea("QPS")
		QPS->(DbSetOrder(1))
		QPS->(DbSeek(cFilQPS+oDadosJson['items'][1]['QPS_CODMED']))
		For nIndReg  := 1 to nRegistros
			lSucesso := Self:oAPIManager:ValidaCamposObrigatorios(oDadosJson['items'][nIndReg], "|QPS_CODMED|QPS_MEDICA|", @cCpsErro)
			If lSucesso
				lSucesso := Self:oAPIManager:ValidaFormatosCamposItem(oDadosJson['items'][nIndReg], Self:aCamposQPS, @cCpsErro, nPosCPS_Protheus)
				If lSucesso
					If oDadosJson['items'][nIndReg]['QPS_CODMED'] == QPS->QPS_CODMED
						RecLock("QPS", .F.)
					Else
						RecLock("QPS", .T.)
					EndIf

					QPS->QPS_FILIAL := cFilQPS
					QPS->QPS_CODMED := oDadosJson['items'][nIndReg]['QPS_CODMED']
					QPS->QPS_MEDICA := oDadosJson['items'][nIndReg]['QPS_MEDICA']
					QPS->QPS_INDMED := oDadosJson['items'][nIndReg]['QPS_INDMED']

					QPS->(MsUnlock())
					QPS->(dbSkip())
				Else
					//"Dados para Integração Inválidos"
					//"Falha no formato de dado(s) do(s) campo(s)"
					Self:cErrorMessage    := STR0008
					Self:cDetailedMessage := STR0021 + " '" + cCpsErro + "': " + oDadosJson['items'][nIndReg]:toJson()
					Exit
				EndIf
			Else
				//"Dados para Integração Inválidos"
				//"Campo(s) obrigatório(s) inválido(s)"
				Self:cErrorMessage    := STR0008
				Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oDadosJson['items'][nIndReg]:toJson()
				Exit
			EndIf

		Next nIndReg
	EndIf

Return lSucesso

/*/{Protheus.doc} ErrorBlock
Proteção para Execução de Error.log
@author brunno.costa
@since  23/05/2022
@param 01 - e, objeto, objeto de errror.log
/*/
METHOD ErrorBlock(e) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cCallStack := ""
	Local nIndAux    := Nil
	Local nTotal     := 10
	
	For nIndAux := 2 to (1+nTotal)
		cCallStack += " <- " + ProcName(nIndAux) + " line " + cValToChar(ProcLine(nIndAux))
	Next nIndAux

	Self:cErrorMessage    := Iif(Empty(Self:cErrorMessage) , STR0014 + " - ResultadosEnsaiosInspecaoDeProcessosAPI", Self:cErrorMessage ) //Erro Interno
	Self:cDetailedMessage := e:Description + cCallStack
	Break

Return .F.

/*/{Protheus.doc} ValidaFormatosCamposItem
Valida Formatos de Campos Recebidos no Item
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaFormatosCamposItem(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cCpsErro := ""
	Local lSucesso := .T.

	If !Self:oAPIManager:ValidaFormatosCamposItem(oItemAPI, Self:aCamposAPI, @cCpsErro)
		//"Dados para Integração Inválidos"
		//"Falha no formato de dado(s) do(s) campo(s)"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0021 + " '" + cCpsErro + "': " + oItemAPI:toJson()
		lSucesso              := .F.
	EndIf

Return lSucesso

/*/{Protheus.doc} PreparaRegistroQPR
Prepara e Valida Registros para Inclusão na QPR
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, retorna por referência os dados do registro da QPR para gravação
@return lSucesso, lógico, indica sucesso na operação
/*/
METHOD PreparaRegistroQPR(oItemAPI, oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso := .T.
	Local nRecno   := oItemAPI["recno"]

	Self:nRecnoQPK := Iif(Self:nRecnoQPK == Nil, oItemAPI["recnoInspection"], Self:nRecnoQPK)
	If (nRecno == Nil .OR. nRecno <= 0)
		lSucesso := Self:PreparaRegistroInclusaoQPR(@oItemAPI, @oRegistro)
		If lSucesso
			lSucesso := Self:ValidaEnsaioEditavelPorRegistro(oRegistro, "I")
		EndIf
	Else
		lSucesso := Self:oAPIManager:AtualizaCamposBancoNoRegistro(@oRegistro, "QPR", nRecno, Self:aCamposQPR)
		If lSucesso
			QPR->(DbGoTo(nRecno))
			lSucesso := Self:ValidaEnsaioEditavelPorQPR("A")
		EndIf
		If lSucesso
			oItemAPI["QPR_CHAVE"] := oRegistro["QPR_CHAVE"]
			oRegistro := Self:oAPIManager:AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, "QPR", Self:aCamposAPI)
		Else
			//"Dados para Integração Inválidos"
			//"Não foi possível encontrar o registro da QPR de RECNO[recno]: "
			Self:cErrorMessage    := STR0008                          
			Self:cDetailedMessage := STR0010 + cValToChar(nRecno)     
		EndIf
		Self:AtualizaEnsaiadorQPR(oItemAPI["protheusLogin"], @oRegistro)
	EndIf

	If lSucesso
		Self:cOperacao := oRegistro["QPR_OPERAC"]
	EndIf

Return lSucesso

/*/{Protheus.doc} SalvaRegistros
Salva Registros no Banco de Dados
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI  , objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - oRegistro , objeto, registro JSON com os dados para gravação na QPR
@param 03 - aRecnosQPR, array , NIL e Vazio para retornar todos ou array com os RECNOS da QPR para receber na resposta do POST
@return lSucesso, lógico, indica sucesso na operação
/*/
METHOD SalvaRegistros(oItemAPI, oRegistro, aRecnosQPR) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cCpsErro   := ""
	Local cEnsaio    := ""
	Local lSucesso   := .T.
	Local nMedicoes  := 0
	Local nRecnoErro := Nil

	oRegistro["QPR_DTMEDI"] := Iif(Empty(oRegistro["QPR_DTMEDI"]), Date()         , oRegistro["QPR_DTMEDI"])
	oRegistro["QPR_HRMEDI"] := Iif(Empty(oRegistro["QPR_HRMEDI"]), Left(Time(), 5), oRegistro["QPR_HRMEDI"])
	oRegistro["QPR_AMOSTR"] := Iif(Self:nRegistros == 1, 2, 1)
	lSucesso  := Self:oAPIManager:ValidaCamposObrigatorios(oRegistro, "|QPR_ENSR|", @cCpsErro)
	If lSucesso
		lSucesso := Self:oAPIManager:SalvaRegistroDB("QPR", @oRegistro, Self:aCamposQPR, @nRecnoErro)
		If lSucesso                                    //Trecho de ELSE é Código Morto - Desvio já tratado no retorno de AtualizaCamposBancoNoRegistro
			aAdd(aRecnosQPR, oRegistro["R_E_C_N_O_"])
		EndIf
	Else
		//"Dados para Integração Inválidos"
		//"Campo(s) obrigatório(s) inválido(s)"
		Self:cErrorMessage    := STR0008
		Self:cDetailedMessage := STR0020 + " '" + AllTrim(cCpsErro) + "': " + oRegistro:toJson()
	EndIf

	If lSucesso
		If oItemAPI['testType'] == "N"
			If Self:ValidaPermissaoEnsaioNumerico(oItemAPI["recnoTest"])
				lSucesso := Self:ValidaQuantidadeMedicoesEnsaio(oItemAPI, @nMedicoes, @cEnsaio)
				If lSucesso
					lSucesso := Self:SalvaRegistroNumerico(oItemAPI)
				Else
					//"Informe as"  + "medições"
					//"O ensaio" + "requer o preenchimento de" + "medições"
					Self:cErrorMessage    := STR0022 + " " + CValToChar(nMedicoes)+ " " + STR0023 + "."
					Self:cDetailedMessage := STR0024 + " '" + cEnsaio + "' " + STR0025 + " " + CValToChar(nMedicoes) + " " + STR0026 + ": " + oItemAPI:toJson()
				EndIf
			Else
				lSucesso := .F.
				//"A inspeção não permite o lançamento de medições do tipo numérica"
				Self:cErrorMessage    := STR0027 + "."
				Self:cDetailedMessage := STR0027 + ": " + oItemAPI:toJson()
			EndIf
		ElseIf oItemAPI['testType'] == "T"
			If Self:ValidaPermissaoEnsaioTexto(oItemAPI["recnoTest"])
				lSucesso := Self:SalvaRegistroTexto(oItemAPI)
			Else
				lSucesso := .F.
				//"A inspeção não permite o lançamento de medições do tipo texto"
				Self:cErrorMessage    := STR0028 + "."
				Self:cDetailedMessage := STR0028 + ":" + oItemAPI:toJson()
			EndIf
		Else
			lSucesso := .F.
			Self:cErrorMessage    := STR0017 // "TIPO do item inválido"
			Self:cDetailedMessage := STR0018 + oItemAPI:toJson() //"Informe um TIPO de item válido, somente são válidos os tipos de item N ou T. Item recebido: "
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaEnsaiador
Valida se o Ensaiador está cadastrado na QAA
@author brunno.costa
@since  24/06/2022
@param 01 - oRegistro, objeto, registro JSON com os dados para gravação na QPR
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaEnsaiador(oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso   := .T.

	lSucesso := IIf(lSucesso, Self:oAPIManager:ValidaChaveEstrangeira("QAA", 1, xFilial("QAA") + AllTrim(oRegistro["QPR_ENSR"])), lSucesso)
	If !lSucesso
		//"Ensaiador não cadastrado no cadastro de usuários (QAA)"
		Self:cErrorMessage    := STR0029 + "."
		Self:cDetailedMessage := STR0029 + ": " + AllTrim(oRegistro["QPR_ENSR"])
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaUsuarioProtheus
Valida se o Usuário do Protheus está cadastrado no configurador
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI, objeto, objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaUsuarioProtheus(oItemAPI) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local lSucesso   := .T.

	lSucesso := Self:oAPIManager:ValidaUsuarioProtheus(oItemAPI["protheusLogin"])
	If !lSucesso
		//"Login de usuário não cadastrado no configurador do Protheus"
		Self:cErrorMessage    := STR0030 + "."
		Self:cDetailedMessage := STR0030 + ": " + oItemAPI["protheusLogin"]
	EndIf

Return lSucesso

/*/{Protheus.doc} ValidaPermissaoEnsaioNumerico
Valida se o ensaio de nRecnoQP7 permite recebimento de resultado Numérico
@author brunno.costa
@since  24/06/2022
@param 01 - nRecnoQP7, número, recno do ensaio na QP7
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaPermissaoEnsaioNumerico(nRecnoQP7) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias   := Nil
	Local cFIlQP1  := xFilial("QP1")
	Local cFIlQP7  := xFilial("QP7")
    Local cQuery   := ""
	Local lSucesso := .T.
	Local oExec    := Nil

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return .F.
	EndIf

	cQuery += " SELECT QP7_ENSAIO "
	cQuery += " FROM " + RetSQLName("QP7")  + " QP7 "
	cQuery += 	" INNER JOIN "
	cQuery += 	" (SELECT QP1_ENSAIO "
	cQuery += 	" FROM " + RetSQLName("QP1")
	cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
	cQuery += 		" AND QP1_CARTA  != 'TXT' "
	cQuery += 		" AND QP1_FILIAL = '" + cFIlQP1 + "') "
	cQuery += 	" QP1  "
	cQuery += 	" ON QP7_ENSAIO = QP1_ENSAIO "
	cQuery += " WHERE D_E_L_E_T_=' ' "
	cQuery += 	" AND QP7_FILIAL = '" + cFIlQP7 + "' "
	cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQP7)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
	
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

	Self:cErrorMessage := ""
    lSucesso := !(cAlias)->(Eof())
    (cAlias)->(dbCloseArea())
	oExec:Destroy()
	oExec := nil 

Return lSucesso

/*/{Protheus.doc} ValidaPermissaoEnsaioTexto
Valida se o ensaio de nRecnoQP8 permite recebimento de resultado Texto
@author brunno.costa
@since  24/06/2022
@param 01 - nRecnoQP8, número, recno do ensaio na QP8
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaPermissaoEnsaioTexto(nRecnoQP8) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias   := Nil
	Local cFIlQP1  := xFilial("QP1")
	Local cFIlQP8  := xFilial("QP8")
    Local cQuery   := ""
	Local lSucesso := .T.
	Local oExec    := Nil

	If Self:NaoImplantado()
		SetRestFault(405, EncodeUtf8(STR0039), .T.,; //"Módulo não está implantado"
		             405, EncodeUtf8(STR0040))       //"Fale com a TOTVS e faça implantação do módulo!"
		Return .F.
	EndIf

	cQuery += " SELECT QP8_ENSAIO "
	cQuery += " FROM " + RetSQLName("QP8")  + " QP8 "
	cQuery += 	" INNER JOIN "
	cQuery += 	" (SELECT QP1_ENSAIO "
	cQuery += 	" FROM " + RetSQLName("QP1")
	cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
	cQuery += 		" AND QP1_CARTA  = 'TXT' "
	cQuery += 		" AND QP1_FILIAL = '" + cFIlQP1 + "') "
	cQuery += 	" QP1  "
	cQuery += 	" ON QP8_ENSAIO = QP1_ENSAIO "
	cQuery += " WHERE D_E_L_E_T_=' ' "
	cQuery += 	" AND QP8_FILIAL = '" + cFIlQP8 + "' "
	cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQP8)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
	
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()
	
	Self:cErrorMessage := ""
    lSucesso := !(cAlias)->(Eof())
    (cAlias)->(dbCloseArea())
	oExec:Destroy()
	oExec := nil 

Return lSucesso

/*/{Protheus.doc} ValidaQuantidadeMedicoesEnsaio
Valida se o ensaio de nRecnoQP8 permite recebimento de resultado Texto
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI , objeto  , objeto Json com UM ITEM DOS REGISTROS JSON recebidos da API para conversão
@param 02 - nMedicoes, número  , retorna por referência a quantidade de medições do ensaio
@param 03 - cEnsaio  , caracter, retorna por referência o código do ensaio
@return lSucesso, lógico, indica sucesso na validação
/*/
METHOD ValidaQuantidadeMedicoesEnsaio(oItemAPI, nMedicoes, cEnsaio) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias    := Nil
	Local cFIlQP1   := xFilial("QP1")
	Local cFIlQP7   := xFilial("QP7")
    Local cQuery    := ""
	Local lSucesso  := .T.
	Local nRecnoQP7 := oItemAPI["recnoTest"]
	Local oExec     := Nil

	If oItemAPI["measurements"] == Nil .OR. Len(oItemAPI["measurements"]) == 0
		lSucesso := .F.
	EndIf

	cQuery += " SELECT QP1_ENSAIO, "
	cQuery +=        " (CASE QP1_CARTA "
	cQuery +=           " WHEN 'XBR' THEN QP1_QTDE "
	cQuery +=           " WHEN 'XBS' THEN QP1_QTDE "
	cQuery +=           " WHEN 'XMR' THEN QP1_QTDE "
	cQuery +=           " WHEN 'HIS' THEN QP1_QTDE "
	cQuery +=           " WHEN 'NP ' THEN QP1_QTDE "
	cQuery +=           " WHEN 'P  ' THEN 3 "
	cQuery +=           " WHEN 'U  ' THEN 2 "
	cQuery +=           " ELSE 1 END) QP1_QTDE "
	cQuery += " FROM " + RetSQLName("QP7")  + " QP7 "
	cQuery += 	" INNER JOIN "
	cQuery += 	" (SELECT QP1_ENSAIO, QP1_CARTA, QP1_QTDE "
	cQuery += 	" FROM " + RetSQLName("QP1")
	cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
	cQuery += 		" AND QP1_CARTA  != 'TXT' "
	cQuery += 		" AND QP1_FILIAL = '" + cFIlQP1 + "') "
	cQuery += 	" QP1  "
	cQuery += 	" ON QP7_ENSAIO = QP1_ENSAIO "
	cQuery += " WHERE D_E_L_E_T_=' ' "
	cQuery += 	" AND QP7_FILIAL = '" + cFIlQP7 + "' "
	cQuery += 	" AND R_E_C_N_O_ = " + cValToChar(nRecnoQP7)

	Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "
	
	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()
	
	Self:cErrorMessage := ""
	lSucesso  := Iif(lSucesso, !(cAlias)->(Eof())                                 , lSucesso)
	lSucesso  := Iif(lSucesso, (cAlias)->QP1_QTDE == Len(oItemAPI["measurements"]), lSucesso)
	nMedicoes := (cAlias)->QP1_QTDE
	cEnsaio   := (cAlias)->QP1_ENSAIO
	(cAlias)->(dbCloseArea())
	oExec:Destroy()
	oExec := nil 

Return lSucesso

/*/{Protheus.doc} NaoImplantado
Indica se o Módulo QIP não está implantado
@author brunno.costa
@since  16/08/2022
@return lNaoImplantado, lógico, indica se o módulo QIP não está implantado
/*/
METHOD NaoImplantado() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
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

/*/{Protheus.doc} AtualizaStatusQPKComRecno
Atualiza Status do Registro na QPK com base em RECNO da QPK
@author brunno.costa
@since  16/08/2022
@param 01 - nRecnoQPK, número, recno para posicionamento na QPK
/*/
METHOD AtualizaStatusQPKComRecno(nRecnoQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cLaudo   := " "
	Local lMedicao := .F.
	Self:lProcessaRetorno := .F.
	Self:RetornaResultadosInspecao(nRecnoQPK, "", Nil, Nil, Nil, "", @lMedicao)
	QPK->(DbGoTo(nRecnoQPK))
	If QPK->(!Eof())
		Private cFatApC := ""
		Private cFatApr := ""
		Private cFatLU  := ""
		Private cFatRep := ""

		RecLock("QPK",.F.)
		QPK->QPK_SITOP := " "
		MsUnLock()

		Self:DefineFatores()
		StaticCall( QIPA215, QP215AtuSit, cLaudo, lMedicao)
	EndIf
	QPK->(DbCloseArea())
Return

/*/{Protheus.doc} AtualizaStatusQPKComChaveQPK
Atualiza Status do Registro na QPK com base em Chave do Registro da QPK
@author brunno.costa
@since  18/11/2022
@param 01 - cChaveQPK, caracter, chave do registro na QPK
/*/
METHOD AtualizaStatusQPKComChaveQPK(cChaveQPK) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	IF !Empty(cChaveQPK)
		QPK->(DbSetOrder(1))
		If QPK->(DbSeek(xFilial("QPK")+cChaveQPK))
			nRecnoQPK := QPK->(Recno())
		EndIf
		Self:AtualizaStatusQPKComRecno(nRecnoQPK)
	EndIf
Return

/*/{Protheus.doc} DefineFatores
Define os Fatores Aprovado, Aprovado Condicional e Reprovado
@author brunno.costa
@since  16/08/2022
/*/
METHOD DefineFatores() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	If QPD->(dbSeek(xFilial("QPD")))
		While !QPD->(Eof())
			If QPD->QPD_CATEG == "1"
				cFatApr := Iif(Empty(cFatApr),QPD->QPD_CODFAT,cFatApr)
			ElseIf QPD->QPD_CATEG == "2"
				cFatApC += QPD->QPD_CODFAT
			ElseIf QPD->QPD_CATEG == "3"
				cFatRep := Iif(Empty(cFatRep),QPD->QPD_CODFAT,cFatRep)
			ElseIf QPD->QPD_CATEG == "4"
				cFatLU := Iif(Empty(cFatLU),QPD->QPD_CODFAT,cFatLU)
			EndIf
			QPD->(dbSkip())
		EndDo
	Endif
Return

/*/{Protheus.doc} ExisteLaudoRelacionadoAoPost
Indica se existe laudo relacionado aos dados do POST
@author brunno.costa
@since  27/11/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@return lExiste, lógico, indica se existe laudo (.T.) relacionado aos dados do POST 
(ou .T. TAMBÉM em caso de falha, para interromper processo e exibir mensagem de falha)
/*/
METHOD ExisteLaudoRelacionadoAoPost(oDadosJson) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local aRecsQP7    := Nil
	Local aRecsQP8    := Nil
	Local aRecsQPK    := Nil
	Local bErrorBlock := Nil
	Local cAlias      := Nil
    Local cQuery      := ""
	Local lExiste     := .F.
    Local oExec       := Nil

	Self:oAPIManager := QualityAPIManager():New(Nil, Self:oWSRestFul)
	bErrorBlock := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, e:Description), lExiste := .T., Break(e)})

	Self:IdentificaRecnosInspecoesEEnsaios(oDadosJson, @aRecsQPK, @aRecsQP7, @aRecsQP8)
	
	BEGIN SEQUENCE

		cQuery += " SELECT DISTINCT "
		cQuery +=         " COALESCE(COALESCE(LAUDO_GERAL.CHAVE_INSPECAO, LAUDO_LABORATORIO.CHAVE_LABORATORIO), LAUDO_OPERACAO.CHAVE_OPERACAO) TEM_LAUDO "
		cQuery +=  " FROM  "


		cQuery += " (SELECT "
		cQuery += 		" CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO) CHAVE_INSPECAO, "
		cQuery += 		" CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC) CHAVE_OPERACAO, "
		cQuery += 		" CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPK_OP, QPK_LOTE), QPK_NUMSER), QQK_CODIGO), QQK_OPERAC), QP8_LABOR) CHAVE_LABORATORIO, "
		cQuery += 		" QPK_SITOP "
		cQuery += " FROM (SELECT DISTINCT QPK.QPK_PRODUT, QPK.QPK_OP, QQK.QQK_CODIGO, QQK.QQK_OPERAC, QPK.QPK_LOTE, QPK.QPK_NUMSER, QPK.QPK_REVI, QPK.QPK_SITOP, QP8_LABOR "
		cQuery +=       " FROM (SELECT QPK_PRODUT, QPK_OP, QPK_LOTE, QPK_NUMSER, QPK_REVI, QPK_SITOP "
		cQuery +=             " FROM " + RetSQLName("QPK")
		cQuery +=             " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=               " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQPK),"|") + ") "
		cQuery +=               " AND (QPK_FILIAL = '" + xFilial("QPK") + "') ) QPK "
		
		cQuery += " INNER JOIN (SELECT QQK_CODIGO, QQK_OPERAC, QQK_PRODUT, QQK_REVIPR "
		cQuery +=             " FROM " + RetSQLName("QQK")
		cQuery +=             " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=               " AND (QQK_FILIAL = '" + xFilial("QQK") + "')) QQK "
		cQuery +=             " ON    QPK.QPK_REVI = QQK.QQK_REVIPR "
		cQuery +=             " AND QPK.QPK_PRODUT = QQK.QQK_PRODUT "
		cQuery +=             " INNER JOIN (SELECT CONCAT(CONCAT(C2_NUM, C2_ITEM), C2_SEQUEN) C2_OP, C2_ROTEIRO "
		cQuery +=                         " FROM " + RetSQLName("SC2")
		cQuery +=                         " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=                         " AND C2_FILIAL = '" + xFilial("SC2") + "') SC2 "
		cQuery +=             " ON C2_OP = QPK_OP "
		cQuery +=             " AND C2_ROTEIRO = QQK_CODIGO "

		cQuery += " INNER JOIN "
		cQuery += " ( "
		If Len(aRecsQP8) > 0
			cQuery += " SELECT QP8_PRODUT AS PRODUTO, QP8_REVI AS REVISAO, QP8_CODREC, QP8_OPERAC AS OPERACAO, QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP8") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP8_FILIAL = '" + xFilial("QP8") + "') "
			cQuery += " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQP8),"|") + ") "
		EndIf
		If Len(aRecsQP7) > 0 .AND. Len(aRecsQP8) > 0
			cQuery += " UNION "
		EndIf
		If Len(aRecsQP7) > 0
			cQuery += " SELECT QP7_PRODUT AS PRODUTO, QP7_REVI AS REVISAO, QP7_CODREC AS QP8_CODREC, QP7_OPERAC AS OPERACAO, QP7_LABOR AS QP8_LABOR "
			cQuery += " FROM " + RetSQLName("QP7") + " "
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND (QP7_FILIAL = '" + xFilial("QP7") + "') "
			cQuery += " AND (R_E_C_N_O_ IN " + FormatIn(ArrToKStr(aRecsQP7),"|") + ") "
		EndIf
		cQuery += " ) FILTROLAB ON QPK.QPK_PRODUT = FILTROLAB.PRODUTO "
		cQuery +=            " AND QPK.QPK_REVI   = FILTROLAB.REVISAO "
		cQuery +=            " AND QQK.QQK_OPERAC = FILTROLAB.OPERACAO "
		
		cQuery += " ) DADOS) INSPECOES "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR) CHAVE_INSPECAO, "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(CONCAT(QPM_OP, QPM_LOTE), QPM_NUMSER), QPM_ROTEIR), QPM_OPERAC) CHAVE_OPERACAO "
		cQuery +=            " FROM " + RetSQLName("QPM") + " "
		cQuery +=            " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=            " AND (QPM_LAUDO <> ' ') "
		cQuery +=            " AND (QPM_OPERAC <> ' ') "
		cQuery +=            " AND (QPM_FILIAL = '" + xFilial("QPM") + "')) LAUDO_OPERACAO "
		cQuery += " ON LAUDO_OPERACAO.CHAVE_OPERACAO = INSPECOES.CHAVE_OPERACAO "


		cQuery += " LEFT JOIN (SELECT DISTINCT
		cQuery +=                   " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO, "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR), QPL_OPERAC), QPL_LABOR) CHAVE_LABORATORIO "
		cQuery +=            " FROM " + RetSQLName("QPL") + " "
		cQuery +=            " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=            " AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
		cQuery +=            " AND (QPL_LAUDO <> ' ') "
		cQuery +=            " AND (QPL_OPERAC <> ' ')) LAUDO_LABORATORIO "
		cQuery += " ON LAUDO_LABORATORIO.CHAVE_LABORATORIO = INSPECOES.CHAVE_LABORATORIO "


		cQuery += " LEFT JOIN (SELECT DISTINCT "
		cQuery +=                   " CONCAT(CONCAT(CONCAT(QPL_OP, QPL_LOTE), QPL_NUMSER), QPL_ROTEIR) CHAVE_INSPECAO "
		cQuery +=       " FROM " + RetSQLName("QPL")
		cQuery +=       " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=       "   AND (QPL_FILIAL = '" + xFilial("QPL") + "') "
		cQuery +=       "   AND (QPL_LAUDO <> ' ') "
		cQuery +=       "   AND (QPL_LABOR = ' ') "
		cQuery +=       "   AND (QPL_OPERAC = ' ')) LAUDO_GERAL "
		cQuery += " ON LAUDO_GERAL.CHAVE_INSPECAO = INSPECOES.CHAVE_INSPECAO "

		cQuery += " WHERE COALESCE(COALESCE(LAUDO_GERAL.CHAVE_INSPECAO, LAUDO_LABORATORIO.CHAVE_LABORATORIO), LAUDO_OPERACAO.CHAVE_OPERACAO) IS NOT NULL "


		cQuery := Self:oAPIManager:ChangeQueryAllDB(cQuery)

		oExec       := FwExecStatement():New(cQuery)
		cAlias      := oExec:OpenAlias()
		lExiste     := (cAlias)->(!Eof())
		oExec:Destroy()
		oExec       := nil

		(cAlias)->(dbCloseArea())
	RECOVER
	END SEQUENCE

	ErrorBlock(bErrorBlock)

Return lExiste

/*/{Protheus.doc} IdentificaRecnosInspecoesEEnsaios
Identifica os Recnos da QPK, QP7 e QP8 relacionados a inspeção
@author brunno.costa
@since  27/11/2022
@param 01 - oDadosJson, objeto, objeto Json com os dados JSON recebidos da API para conversão
@param 02 - aRecsQPK  , array , retorna por referência relação de RECNOS da QPK relacionados
@param 03 - aRecsQP7  , array , retorna por referência relação de RECNOS da QP7 relacionados
@param 04 - aRecsQP8  , array , retorna por referência relação de RECNOS da QP8 relacionados
/*/
METHOD IdentificaRecnosInspecoesEEnsaios(oDadosJson, aRecsQPK, aRecsQP7, aRecsQP8) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local nIndReg    := Nil
	Local nRegistros := Len(oDadosJson["items"])
	Local oItemAPI   := Nil

	Default aRecsQPK := {}
	Default aRecsQP7 := {}
	Default aRecsQP8 := {}

	If nRegistros > 0
		For nIndReg := 1 to nRegistros
			oItemAPI := oDadosJson["items"][nIndReg]
			aAdd(aRecsQPK, oItemAPI["recnoInspection"])
			If oItemAPI['testType'] == "N"
				aAdd(aRecsQP7, oItemAPI["recnoTest"])
			Else
				aAdd(aRecsQP8, oItemAPI["recnoTest"])
			EndIf
		Next nIndReg
	EndIf
Return 

/*/{Protheus.doc} SalvaAnexo
Salva Anexo
@author brunno.costa
@since  12/04/2023
@param 01 - cContent, caracter, conteúdo em JSON
@param 02 - lSucesso, lógico  , variável para facilitar cobertura de erro
/*/
METHOD SalvaAnexo(cContent, lSucesso) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local aBase64     := {}
	Local bErrorBlock := Nil
	Local cBase64     := Nil
	Local cError      := ""
	Local cNomeOrig   := ""
	Local cNomeReal   := ""
	Local cPath       := SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\")
	Local cResp       := Nil
	Local oContent    := JsonObject():New()
	Local oResponse   := JsonObject():New()
	Local oSelf       := Self
	
	Default lSucesso := Self:lTemQQM

	bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e)})
	Begin Sequence
		oContent:fromJson(cContent)
		cNomeOrig := oContent['originalFileName']
		cNomeReal := oContent['uid'] + "." + aTail(StrtoKarr(oContent['originalFileName'],"."))
		If lSucesso
			aBase64   := StrtoKarr(oContent['base64File'],",")
			cBase64   := aBase64[2]
			lSucesso  := Self:CriaPasta(cPath) == 0
			lSucesso  := lSucesso .AND. !Empty(Decode64(cBase64, Lower(cPath + cNomeReal)))
		EndIf
	Recover
	End Sequence
	ErrorBlock(bErrorBlock)

	Self:oWSRestFul:SetContentType("application/json")

	If lSucesso
		HTTPSetStatus(204)
		oResponse['code'] := 204
		//STR0045 - "Anexo"
		//STR0046 - "salvo com sucesso."
		oResponse['response'] := STR0045  + " '" + cNomeOrig + "' " + STR0046
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )

		Self:registraAnexo(oContent, "2")
		
	Else
		oResponse['code'         ] := 403
		oResponse['errorCode'    ] := 403

		//STR0044 - "Falha ao salvar o anexo"
		oResponse['response'     ] := STR0044 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'."
		oResponse['message'      ] := STR0044 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cErrorMessage
		oResponse['errorMessage' ] := STR0044 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cDetailedMessage
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		SetRestFault(403, EncodeUtf8(STR0044 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cErrorMessage), .T.,;
					403, EncodeUtf8(STR0044 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cDetailedMessage))
	EndIf

Return 

/*/{Protheus.doc} RegistraAnexos
Registra início do recebimento do anexo
@author brunno.costa
@since  12/04/2023
@param 01 - oItemAPI , objeto, objeto com os dados do item recebidos na API
@param 02 - oRegistro, objeto, objeto JSON com os dados para gravação na QPR
/*/
METHOD RegistraAnexos(oItemAPI, oRegistro) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local nAnexos   := 0
	Local nIndAnexo := 0

	If !Self:lTemQQM
		Self:oAPIManager:lWarningError := .T.
		Self:cErrorMessage             := STR0047 //"Protheus desatualizado, atualize o dicionário para inclusão da tabela QQM - Anexos Inspeção Qualidade."
		Self:cDetailedMessage          := STR0047 //"Protheus desatualizado, atualize o dicionário para inclusão da tabela QQM - Anexos Inspeção Qualidade."
	ElseIf oItemAPI[ 'attachments' ] != Nil .AND. ValType(oItemAPI[ 'attachments' ]) == "A"
		nAnexos   := Len(oItemAPI[ 'attachments' ])
		For nIndAnexo := 1 to nAnexos
			Self:RegistraAnexo(oItemAPI[ 'attachments', nIndAnexo], "1", oRegistro["QPR_CHAVE"])
		Next
	EndIf

Return

/*/{Protheus.doc} RegistraAnexo
Rergistra atualização de status do anexo
@author brunno.costa
@since  12/04/2023
@param 01 - oContent, objeto  , objeto JSON com os dados do anexo para registro
@param 02 - cStatus , caracter, status do anexo: 1=Registrado; 2=Upload Completo
@param 03 - cChave  , caracter, QPR_CHAVE relacionado ao anexo
/*/
METHOD RegistraAnexo(oContent, cStatus, cChave) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	DbSelectArea("QQM")
	QQM->(DbSetOrder(2))
	RecLock("QQM", !QQM->(DbSeek(Upper(oContent['uid']))))
	QQM->QQM_FILIAL := xFilial("QQM")
	QQM->QQM_FILQPR := xFilial("QPR")
	QQM->QQM_MSUID  := Upper(oContent['uid'])
	QQM->QQM_MIME   := oContent['mimeType']
	QQM->QQM_SIZE   := oContent['size']
	QQM->QQM_NOMEOR := oContent['originalFileName']
	QQM->QQM_LOCAL  := "2"
	QQM->QQM_STATUP := Iif(QQM->QQM_STATUP != "2", cStatus, QQM->QQM_STATUP)
	If !Empty(cChave) .AND. Empty(QQM->QQM_CHAVE)
		QQM->QQM_CHAVE := cChave
	EndIf
	QQM->(MsUnlock())

Return 

/*/{Protheus.doc} CriaPasta
Método que cria pastas e sub-pastas conforme parametro caso estas não existam.
@type  METHOD
@author brunno.costa
@since  12/04/2023
@param 01 - cDiretorio, caractere, diretório a ser criado.
@return nReturn, numérico, código do erro na criação do diretório
/*/
METHOD CriaPasta(cDiretorio) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local aPastas  := StrTokArr(cDiretorio, "\")
	Local cCaminho := "\"
	Local nPasta   := 0
	Local nPastas  := Len(aPastas)
	Local nReturn  := 0

	For nPasta := 1 to nPastas
		cCaminho += aPastas[nPasta] + "\"
		If !ExistDir(cCaminho)
			nReturn  := MakeDir(cCaminho)
			If nReturn != 0 .Or. Self:lForcaInexistenciaDiretorio //Apoio cobertura
				//STR0048 - "Erro na criação do diretório"
				Self:cDetailedMessage += STR0048 + " '" + cDiretorio + "': " + cValToChar(nReturn)
				nReturn := Iif(Self:lForcaInexistenciaDiretorio, -1, Self:lForcaInexistenciaDiretorio)
				Exit
			EndIf
		EndIf
	Next

Return nReturn

/*/{Protheus.doc} PodeReceberArquivos
Indica se o ambiente está preparado para o recebimento de arquivos
@author brunno.costa
@since  12/04/2023
@return lRetorno, lógico, indica se o ambiente está preparado para o recebimento de arquivos
/*/
METHOD PodeReceberArquivos() CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
     
    Local lRetorno  := Self:lTemQQM
	Local oResponse := JsonObject():New()
	Local cResp     := ""
	
	oResponse['canReceveFiles' ] := Iif(lRetorno, 'true', 'false')

	Self:oWSRestFul:SetContentType("application/json")

	If lRetorno
		//Processou com sucesso.
		HTTPSetStatus(200)
		oResponse['code'         ] := 200
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		
	Else
		oResponse['showWarningError' ] := .T.
		oResponse['code'         ]     := 403
		oResponse['errorCode'    ]     := 403
		oResponse['errorMessage' ]     := STR0047 //"Protheus desatualizado, atualize o dicionário para inclusão da tabela QQM - Anexos Inspeção Qualidade."
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		SetRestFault(403, cResp, .T.,;
		             403, cResp)
	EndIf

Return lRetorno


/*/{Protheus.doc} RetornaListaDeAnexosDeUmaAmostra
Retorna uma lista de anexos referentes a amostra 
@type method
@author rafael.hesse
@since 13/04/2023
@param nRecnoQPR, numérico, RECNO da amostra de resultados
@return lSucesso, lógico, indica se conseguiu retornar a lista
/*/
METHOD RetornaListaDeAnexosDeUmaAmostra(nRecnoQPR) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	
	Local cAlias      := Nil
    Local cQuery      := ""
	Local lSucesso    := .F.
	Local nPagina     := 1
	Local nTamPag     := 999
	Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposQQM("*"), Self:oWSRestFul)
	Local oQLTQueryM  := QLTQueryManager():New()

	If Self:lTemQQM

		cQuery := " SELECT QQM_NOMEOR, "
		cQuery +=		 " RECNOQQM, "
		cQuery +=		 " QQM_MSUID, "
		cQuery += 		 " QQM_MIME, "
		cQuery += 		 " QQM_SIZE "
		cQuery += " FROM "
		cQuery +=  " (SELECT QPR_FILIAL, "
		cQuery += 		   " QPR_CHAVE "
		cQuery +=	" FROM " + RetSqlName("QPR")
		cQuery +=	" WHERE R_E_C_N_O_ = '" + cValToChar(nRecnoQPR) + "' "
		cQuery +=		  " AND D_E_L_E_T_ = ' ' ) QPR "
		cQuery += " INNER JOIN "
		cQuery +=  " (SELECT QQM_FILQPR, "
		cQuery += 		   " QQM_CHAVE, "
		cQuery += 		   " R_E_C_N_O_ RECNOQQM, "
		cQuery +=		   " QQM_NOMEOR, "
		cQuery +=		   " QQM_MSUID, "
		cQuery += 		   " QQM_MIME, "
		cQuery += 		   " QQM_SIZE "
		cQuery += 	" FROM " + RetSqlName("QQM")
		cQuery += 	" WHERE D_E_L_E_T_ = ' ' ) QQM ON QQM_FILQPR = QPR.QPR_FILIAL "
		cQuery += 		  						" AND QQM_CHAVE = QPR_CHAVE "

		Self:cErrorMessage := STR0007 + cQuery //"Erro na execução da query: "

		cQuery := oQLTQueryM:changeQuery(cQuery)
		cAlias := oQLTQueryM:executeQuery(cQuery)

		Self:cErrorMessage := ""
		
		If lSucesso := (cAlias)->(!Eof())
			lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
		EndIf

		(cAlias)->(dbCloseArea())

	EndIf

Return lSucesso

/*/{Protheus.doc} RetornaAnexoAPartirDoRecnoDaQQM
Retorna anexo em base64 a partir do recno
@type method
@author rafael.hesse
@since 13/04/2023
@param nRecnoQQM, numerico, RECNO do anexo 
@return lSucesso, lógico, indica se conseguiu retornar o anexo
/*/
METHOD RetornaAnexoAPartirDoRecnoDaQQM(nRecnoQQM) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cArquivo   := ""
	Local cBase64    := Nil
	Local cPath      := AllTrim(SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\"))
	Local lSizeError := .F.
	Local lSucesso   := .F.
	Local lTemArqui  := .F.
	Local oResponse  := JsonObject():New()

	If Self:lTemQQM
		DbSelectArea("QQM")
		QQM->(DbGoTo(nRecnoQQM))
		cArquivo := AllTrim(Alltrim(QQM->QQM_MSUID) + "." + aTail(StrtoKarr(QQM->QQM_NOMEOR,".")))

		If Val(GetPvProfString( "GENERAL", "MAXSTRINGSIZE", "0", GetSrvIniName() )) < 100
			lSizeError := .T.
			//STR0059 - "Vulneravilidade identificada no download de arquivos do APP Inspecao de Processos."
			//STR0058 - "Informe na tag MaxStringSize do AppServer.Ini um valor igual ou superior a 100."
			FWLogMsg("WARN", "", "SIGAQIP", "ResultadosEnsaiosInspecaoDeProcessosAPI", "", "", STR0059 + STR0058, 0, 0)
		EndIf

		If (lTemArqui := File(cPath + cArquivo))
			cBase64  := StartJob("QIP64Data", GetEnvServer(), .T., Lower( cPath + cArquivo ))
			lSucesso := !Empty(cBase64)
		EndIf

		Self:oWSRestFul:SetContentType("application/json")

		If lSucesso
			Self:oWSRestFul:SetResponse( cBase64 )
			HTTPSetStatus(200)

		Else
			If lSizeError .AND. lTemArqui
				Self:cErrorMessage    := STR0051 + " " + STR0058            // "Não foi possivel recuperar o arquivo selecionado." - "Informe na tag MaxStringSize do AppServer.Ini um valor igual ou superior a 100."
				Self:cDetailedMessage := STR0051 + " " + STR0058            // "Não foi possivel recuperar o arquivo selecionado." - "Informe na tag MaxStringSize do AppServer.Ini um valor igual ou superior a 100."
			Else
				Self:cErrorMessage 	  := STR0051 						   	//STR0051 - "Não foi possivel recuperar o arquivo selecionado."
				Self:cDetailedMessage := Iif(!lTemArqui,STR0052 + cPath ,; 	//STR0052 - "Arquivo não localizado na pasta ##"
														STR0053) 			//STR0053 - "Falha ao recuperar o arquivo."
			EndIf

			oResponse['code'         ] := 403
			oResponse['errorCode'    ] := 403
			oResponse['message'      ] := Self:cErrorMessage
			oResponse['errorMessage' ] := Self:cDetailedMessage
			cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
			Self:oWSRestFul:SetResponse( cResp )

			SetRestFault(403, EncodeUtf8(Self:cErrorMessage), .T.,;
			             403, EncodeUtf8(Self:cDetailedMessage))
		EndIf
	EndIf
Return lSucesso

/*/{Protheus.doc} QIP64Data
Thread Intermediária para tratamento de erro de binário devido MaxStringSize pequeno
@type function
@author brunno.costa
@since 25/04/2023
@return cData64, caracter, dados do arquivo em Base64
/*/
Function QIP64Data(cFilePath)
Return StartJob("QIP64DataX", GetEnvServer(), .T., cFilePath)

/*/{Protheus.doc} QIP64DataX
Função que chama método do binário para retornar arquivo em base 64, utilizado em Thread para garantir continuidade no fluxo de execução principal
@type function
@author brunno.costa
@since 25/04/2023
@return cData64, caracter, dados do arquivo em Base64
/*/
Function QIP64DataX(cFilePath)
Return Encode64(, cFilePath)

/*/{Protheus.doc} ExcluiAnexosERelacionamento
Exclui Anexos e relacionamentos relacionados a amostra QPR_CHAVE
@author brunno.costa
@since  18/04/2023
@param 01 - cFilQPR , caracter, filial do registro da QPR
@param 02 - cChave  , caracter, QPR_CHAVE relacionado ao anexo
/*/
METHOD ExcluiAnexosERelacionamento(cFilQPR, cChave) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI

	Local cFilQQM     := ""
	Local nMaximo     := 60 //60 * 10 = 600 segundos = 10 minutos
	Local nTentativas := 0

	Default cFilQPR := ""
	Default cChave  := ""

	Self:lTemQQM := Iif(Self:lTemQQM == Nil, !Empty(FWX2Nome( "QQM" )), Self:lTemQQM)
	If Self:lTemQQM
		cFilQQM     := xFilial("QQM")
		DbSelectArea("QQM")
		QQM->(DbSetOrder(1))
		If QQM->(DbSeek(cFilQQM + cFilQPR + cChave ))
			While !QQM->(Eof())            .AND.;
				QQM->QQM_FILIAL == cFilQQM .AND.;
				QQM->QQM_FILQPR == cFilQPR .AND.;
				QQM->QQM_CHAVE  == cChave

				While QQM->QQM_STATUP == "1" .AND. nTentativas < nMaximo
					Sleep(10000)//10 segundos
					nTentativas++
					QQM->(DbSeek(cFilQQM + cFilQPR + cChave ))
				EndDo

				Self:ExcluiArquivoAnexo(Lower(AllTrim(QQM->QQM_MSUID) + "." + aTail(StrTokArr(AllTrim(QQM->QQM_NOMEOR), "."))))

				RecLock("QQM", .F.)
				QQM->(DbDelete())
				QQM->(MsUnlock())
				
				QQM->(DbSkip())
			EndDo
		EndIf
	EndIf

Return 

/*/{Protheus.doc} ExcluiArquivoAnexo
Exclui arquivo anexo
@author brunno.costa
@since  18/04/2023
@param 01 - cNome , caracter, nome do arquivo anexo com extensão
/*/
METHOD ExcluiArquivoAnexo(cNome) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cPath  := SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\")
	Local nErase := fErase(cPath + cNome)
	//STR0054 - "Falha"
	//STR0055 - "na deleção do Arquivo"
	Iif(nErase == -1, FWLogMsg('INFO',, 'SIGAQIP', FunName(), '', '01', STR0054 + " '" + cValToChar(nErase) + "' " + STR0055 + " '" + cPath + cNome + "'." , 0, 0, {}), "")
Return

/*/{Protheus.doc} DeletaAnexoAmostra
Chamado pelo Endpoint para exclusão do anexo da amostra
@author brunno.costa
@since  20/04/2023
@param 01 - nRecnoQQM, número  , RECNO do registro do anexo na tabela QQM
/*/
METHOD DeletaAnexoAmostra(nRecnoQQM) CLASS ResultadosEnsaiosInspecaoDeProcessosAPI
	Local cResp                 := Nil
	Local oResponse             := JsonObject():New()

	Self:oWSRestFul:SetContentType("application/json")

	DbSelectArea("QQM")
	QQM->(DbGoTo(nRecnoQQM))
	Self:ExcluiArquivoAnexo(Lower(AllTrim(QQM->QQM_MSUID) + "." + aTail(StrTokArr(AllTrim(QQM->QQM_NOMEOR), "."))))

	RecLock("QQM", .F.)
	QQM->(DbDelete())
	QQM->(MsUnlock())

	HTTPSetStatus(204)
	oResponse['code'] := 204
	oResponse['response'] := STR0057 //"Anexo Excluído com Sucesso"
	cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
	Self:oWSRestFul:SetResponse( cResp )

Return
