#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "LaudosInspecaoDeProcessosAPI.CH"

/*/{Protheus.doc} processinspectiontestreports
API Laudos Ensaios Inspeção de Processos
@author brunno.costa
@since  22/09/2022
/*/
WSRESTFUL processinspectiontestreports DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Laudos Inspeções de Processos"

    WSDATA HasMeasurement       as LOGICAL OPTIONAL
    WSDATA Laboratories         as STRING OPTIONAL
    WSDATA Laboratory           as STRING OPTIONAL
    WSDATA Login                as STRING OPTIONAL
    WSDATA Operation            as STRING OPTIONAL
    WSDATA OperationRoutines    as STRING OPTIONAL
    WSDATA Operations           as STRING OPTIONAL
    WSDATA ProductID            as STRING OPTIONAL
	WSDATA RecnoQPK             as INTEGER OPTIONAL
    WSDATA ReportLevel          as STRING OPTIONAL
    WSDATA ReportLevelPage      as STRING OPTIONAL
    WSDATA ReportSelected       as STRING OPTIONAL
    WSDATA ShelfLife            as DATE OPTIONAL
    WSDATA SpecificationVersion as STRING OPTIONAL

    WSMETHOD GET standardreportpage;
    DESCRIPTION STR0002; //"Identifica Página de Laudo Padrão Relacionada"
    WSSYNTAX "api/qip/v1/standardreportpage/{Login}/{RecnoQPK}" ;
    PATH "/api/qip/v1/standardreportpage" ;
    TTALK "v1"

	WSMETHOD GET canusergeneratereport;
    DESCRIPTION STR0003; //"Identifica se o usuário pode gerar laudo"
    WSSYNTAX "api/qip/v1/canusergeneratereport/{Login}/{ReportLevel}" ;
    PATH "/api/qip/v1/canusergeneratereport" ;
    TTALK "v1"

    WSMETHOD GET suggestsopinionreport;
    DESCRIPTION STR0005; //"Sugere Parecer Laudo"
    WSSYNTAX "api/qip/v1/suggestsopinionreport/{Login}/{RecnoQPK}/{ReportLevel}/{Operations}/{Laboratories}" ;
    PATH "/api/qip/v1/suggestsopinionreport" ;
    TTALK "v1"

    WSMETHOD GET shelflifereport;
    DESCRIPTION STR0006; //"Identifica a data de laudo para sugestão"
    WSSYNTAX "api/qip/v1/shelflifereport/{ProductID}/{SpecificationVersion}" ;
    PATH "/api/qip/v1/shelflifereport" ;
    TTALK "v1"

    WSMETHOD GET reportDateValid;
    DESCRIPTION STR0007; //"Valida a data de validade do laudo digitado"
    WSSYNTAX "api/qip/v1/reportDateValid/{ShelfLife}/{ReportSelected}" ;
    PATH "/api/qip/v1/reportDateValid" ;
    TTALK "v1"

    WSMETHOD POST savegeneralreport;
	DESCRIPTION STR0008; //"Salva Laudo Geral"
	WSSYNTAX "api/qip/v1/savegeneralreport" ;
	PATH "/api/qip/v1/savegeneralreport" ;
	TTALK "v1"

    WSMETHOD POST savelaboratoryreport;
	DESCRIPTION STR0009; //"Salva Laudo de Laboratório"
	WSSYNTAX "api/qip/v1/savelaboratoryreport" ;
	PATH "/api/qip/v1/savelaboratoryreport" ;
	TTALK "v1"

    WSMETHOD POST saveoperationreport;
	DESCRIPTION STR0010; //"Salva Laudo de Operação"
	WSSYNTAX "api/qip/v1/saveoperationreport" ;
	PATH "/api/qip/v1/saveoperationreport" ;
	TTALK "v1"

    WSMETHOD GET generalreport;
    DESCRIPTION STR0011; //"Retorna Laudo Geral"
    WSSYNTAX "api/qip/v1/generalreport/{RecnoQPK}/{OperationRoutines}" ;
    PATH "/api/qip/v1/generalreport" ;
    TTALK "v1"

    WSMETHOD GET laboratoryreport;
    DESCRIPTION STR0012; //"Retorna Laudo do Laboratório"
    WSSYNTAX "api/qip/v1/laboratoryreport/{RecnoQPK}/{OperationRoutines}/{Operation}/{Laboratory}" ;
    PATH "/api/qip/v1/laboratoryreport" ;
    TTALK "v1"

    WSMETHOD GET operationreport;
    DESCRIPTION STR0013; //"Retorna Laudo de Operação"
    WSSYNTAX "api/qip/v1/operationreport/{RecnoQPK}/{OperationRoutines}/{Operation}" ;
    PATH "/api/qip/v1/operationreport" ;
    TTALK "v1"

    WSMETHOD GET reopeninspection;
    DESCRIPTION STR0014; //"Reabre a inspeção"
    WSSYNTAX "api/qip/v1/reopeninspection/{Login}/{RecnoQPK}/{OperationRoutines}/{HasMeasurement}" ;
    PATH "/api/qip/v1/reopeninspection" ;
    TTALK "v1"

    WSMETHOD GET caneditreport;
    DESCRIPTION STR0015; //"Avalia se o Laudo Pode Ser Editado"
    WSSYNTAX "api/qip/v1/caneditreport/{RecnoQPK}/{OperationRoutines}/{Operation}/{Laboratory}/{ReportLevelPage}" ;
    PATH "/api/qip/v1/caneditreport" ;
    TTALK "v1"

    WSMETHOD GET hasallaccessinoperation;
    DESCRIPTION STR0016; //"Avalia se o Usuário possui acesso a toda a operação da inspeção"
    WSSYNTAX "api/qip/v1/hasallaccessinoperation/{Login}/{RecnoQPK}/{Operation}" ;
    PATH "/api/qip/v1/hasallaccessinoperation" ;
    TTALK "v1"

    WSMETHOD GET dellabrep;
    DESCRIPTION STR0017; //"Exclui Laudo do Laboratório"
    WSSYNTAX "api/qip/v1/dellabrep/{Login}/{RecnoQPK}/{OperationRoutines}/{Operation}/{Laboratory}/{HasMeasurement}" ;
    PATH "/api/qip/v1/dellabrep" ;
    TTALK "v1"

    WSMETHOD GET deloperep;
    DESCRIPTION STR0018; //"Exclui Laudo da Operação"
    WSSYNTAX "api/qip/v1/deloperep/{Login}/{RecnoQPK}/{OperationRoutines}/{Operation}/{HasMeasurement}" ;
    PATH "/api/qip/v1/deloperep" ;
    TTALK "v1"

    WSMETHOD GET delgenrep;
    DESCRIPTION STR0019; //"Exclui Laudo Geral"
    WSSYNTAX "api/qip/v1/delgenrep/{Login}/{RecnoQPK}/{OperationRoutines}/{HasMeasurement}" ;
    PATH "/api/qip/v1/delgenrep" ;
    TTALK "v1"

    WSMETHOD GET reopoper;
    DESCRIPTION STR0020; //"Reabre a Operação"
    WSSYNTAX "api/qip/v1/reopoper/{Login}/{RecnoQPK}/{OperationRoutines}/{Operation}/{HasMeasurement}" ;
    PATH "/api/qip/v1/reopoper" ;
    TTALK "v1"

    WSMETHOD GET alllaboratorieshavereports;
    DESCRIPTION "Todos os Laboratórios Possuem Laudos"; 
    WSSYNTAX "api/qip/v1/alllaboratorieshavereports/{Login}/{RecnoQPK}" ;
    PATH "/api/qip/v1/alllaboratorieshavereports" ;
    TTALK "v1"

    WSMETHOD GET alloperationshavereports;
    DESCRIPTION "Todas as Operações Possuem Laudos"; 
    WSSYNTAX "api/qip/v1/alloperationshavereports/{Login}/{RecnoQPK}" ;
    PATH "/api/qip/v1/alloperationshavereports" ;
    TTALK "v1"
    
    WSMETHOD get failintegrationmessages;
	DESCRIPTION STR0021; //"Retorna mensagens de erro em caso de integraçao com outros módulos"
	WSSYNTAX "api/qip/v1/failintegrationmessages" ;
	PATH "/api/qip/v1/failintegrationmessages" ;
	TTALK "v1"

    WSMETHOD GET integrationStock;
    DESCRIPTION STR0022; //"Identifica se tem integração com o estoque habilitado";
    WSSYNTAX "api/qip/v1/integrationStock/" ;
    PATH "/api/qip/v1/integrationStock" ;
    TTALK "v1"
    
ENDWSRESTFUL

WSMETHOD GET standardreportpage PATHPARAM Login, RecnoQPK WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := Nil
    Local cError            := Nil

	oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
	cPagina           := oQIPLaudosEnsaios:DirecionaParaTelaDeLaudoPorInspecaoEUsuario(Self:RecnoQPK, Self:Login, @cError)
    If Empty(cPagina) .OR. cPagina == "X"
        oQIPLaudosEnsaios:oAPIManager:lWarningError := .T.
	    oQIPLaudosEnsaios:oAPIManager:RespondeValor("reportLevelPage", cPagina, Iif(Empty(cError), STR0004, cError)) //"Usuário sem acesso a inclusão de Laudos (Revise o parâmetro MV_QPLDNIV)."
    Else
        oQIPLaudosEnsaios:oAPIManager:RespondeValor("reportLevelPage", cPagina)
    EndIf

Return 

WSMETHOD GET hasallaccessinoperation PATHPARAM Login, RecnoQPK, Operation WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := Nil
    Local lSucesso          := Nil

	oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
	lSucesso          := oQIPLaudosEnsaios:AvaliaAcessoATodaOperacao(Self:RecnoQPK, Self:Login, Self:Operation)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET canusergeneratereport PATHPARAM Login, ReportLevel WSSERVICE processinspectiontestreports
	
	Local cError            := Nil
    Local oQIPLaudosEnsaios := Nil

	oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
	If oQIPLaudosEnsaios:UsuarioPodeGerarLaudo(Self:Login, Self:ReportLevel, @cError)
		oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", .T., "")
	Else
        oQIPLaudosEnsaios:oAPIManager:lWarningError := .T.
		oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", .F., Iif(Empty(cError), STR0004, cError)) //"Usuário sem acesso a inclusão de Laudos (Revise o parâmetro MV_QPLDNIV)."
	EndIf

Return 

WSMETHOD GET suggestsopinionreport PATHPARAM Login, RecnoQPK, ReportLevel, Operations, Laboratories WSSERVICE processinspectiontestreports
	
	Local cError            := Nil
    Local cParecer          := ""
    Local oQIPLaudosEnsaios := Nil
    Local aOperacoes        := StrToKArr(Self:Operations  , ",")
    Local aLaboratorios     := StrToKArr(Self:Laboratories, ",")

	oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    cParecer := oQIPLaudosEnsaios:SugereParecerLaudo(Self:ReportLevel, Self:RecnoQPK, aOperacoes, aLaboratorios, Self:Login, @cError)
    If Empty(cError)
		oQIPLaudosEnsaios:oAPIManager:RespondeValor("suggestionOpinion", cParecer, "")
	Else
		oQIPLaudosEnsaios:oAPIManager:RespondeValor("suggestionOpinion", "", cError)
	EndIf

Return 

WSMETHOD GET shelflifereport PATHPARAM ProductID, SpecificationVersion WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local cReturn           := ""

	cReturn := oQIPLaudosEnsaios:BuscaDataDeValidadeDoLaudo(Self:ProductID, Self:SpecificationVersion)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("date", cReturn)

Return 

WSMETHOD GET reportDateValid PATHPARAM ShelfLife, ReportSelected WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lReturn           := .T.
    Local cError            := ""

	lReturn := oQIPLaudosEnsaios:ValidaDataDeValidadeDoLaudo(Self:ShelfLife, Self:ReportSelected, @cError )
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("ValidDate", lReturn, cError)

Return 

WSMETHOD POST savegeneralreport QUERYPARAM Fields WSSERVICE processinspectiontestreports
    
    Local cError     := ""
    Local cJsonData  := DecodeUTF8(Self:GetContent())
    Local oAPIClass  := QIPLaudosEnsaios():New(Self)
    Local oDadosJson := JsonObject()      :New()
    Local lSucesso   := .T.

    cError   := oDadosJson:fromJson(cJsonData)
    lSucesso := Empty(cError)
    If lSucesso
        lSucesso := oAPIClass:GravaLaudoGeral(oDadosJson["Login"]            ,;
                                              oDadosJson["RecnoInspection"]  ,;
                                              oDadosJson["OperationRoutines"],;
                                              oDadosJson["ReportSelected"]   ,;
                                              oDadosJson["Justification"]    ,;
                                              oDadosJson["RejectedQuantity"] ,;
                                              oDadosJson["ShelfLife"]        ,;
                                              oDadosJson["ReleaseStock"]     )
    EndIf
    cError := Iif(Empty(cError), oAPIClass:oAPIManager:cErrorMessage, cError)
    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)

Return 

WSMETHOD POST savelaboratoryreport QUERYPARAM Fields WSSERVICE processinspectiontestreports
    
    Local cError     := ""
    Local cJsonData  := DecodeUTF8(Self:GetContent())
    Local oAPIClass  := QIPLaudosEnsaios():New(Self)
    Local oDadosJson := JsonObject()      :New()
    Local lSucesso   := .T.

    cError   := oDadosJson:fromJson(cJsonData)
    lSucesso := Empty(cError)
    If lSucesso
        lSucesso := oAPIClass:GravaLaudoLaboratorio(oDadosJson["Login"]            ,;
                                                    oDadosJson["RecnoInspection"]  ,;
                                                    oDadosJson["OperationRoutines"],;
                                                    oDadosJson["OperationID"]      ,;
                                                    oDadosJson["Laboratory"]       ,;
                                                    oDadosJson["ReportSelected"]   ,;
                                                    oDadosJson["Justification"]    ,;
                                                    oDadosJson["RejectedQuantity"] ,;
                                                    oDadosJson["ShelfLife"])

    EndIf
    cError := Iif(Empty(cError), oAPIClass:oAPIManager:cErrorMessage, cError)
    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)

Return 

WSMETHOD POST saveoperationreport QUERYPARAM Fields WSSERVICE processinspectiontestreports
    
    Local cError     := ""
    Local cJsonData  := DecodeUTF8(Self:GetContent())
    Local oAPIClass  := QIPLaudosEnsaios():New(Self)
    Local oDadosJson := JsonObject()      :New()
    Local lSucesso   := .T.

    cError   := oDadosJson:fromJson(cJsonData)
    lSucesso := Empty(cError)
    If lSucesso
        lSucesso := oAPIClass:GravaLaudoOperacao(oDadosJson["Login"]            ,;
                                                 oDadosJson["RecnoInspection"]  ,;
                                                 oDadosJson["OperationRoutines"],;
                                                 oDadosJson["OperationID"]      ,;
                                                 oDadosJson["ReportSelected"]   ,;
                                                 oDadosJson["Justification"]    ,;
                                                 oDadosJson["RejectedQuantity"] ,;
                                                 oDadosJson["ShelfLife"])

    EndIf
    cError := Iif(Empty(cError), oAPIClass:oAPIManager:cErrorMessage, cError)
    oAPIClass:oAPIManager:RespondeValor("success", lSucesso, cError)

Return 

WSMETHOD GET generalreport PATHPARAM RecnoQPK, OperationRoutines WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local oDados            := Nil

	oDados := oQIPLaudosEnsaios:RetornaLaudoGeral(Self:RecnoQPK, Self:OperationRoutines)
    oDados['shelfLife'] := oQIPLaudosEnsaios:oAPIManager:FormataDado("D", oDados['shelfLife'], "2", 10)
    oQIPLaudosEnsaios:oAPIManager:RespondeJson(oDados)

Return 

WSMETHOD GET laboratoryreport PATHPARAM RecnoQPK, OperationRoutines, Operation, Laboratory WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local oDados            := Nil

	oDados := oQIPLaudosEnsaios:RetornaLaudoLaboratorio(Self:RecnoQPK, Self:OperationRoutines, Self:Operation, Self:Laboratory)
    oDados['shelfLife'] := oQIPLaudosEnsaios:oAPIManager:FormataDado("D", oDados['shelfLife'], "2", 10)
    oQIPLaudosEnsaios:oAPIManager:RespondeJson(oDados)

Return 

WSMETHOD GET operationreport PATHPARAM RecnoQPK, OperationRoutines, Operation WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local oDados            := Nil

	oDados := oQIPLaudosEnsaios:RetornaLaudoOperacao(Self:RecnoQPK, Self:OperationRoutines, Self:Operation)
    oDados['shelfLife'] := oQIPLaudosEnsaios:oAPIManager:FormataDado("D", oDados['shelfLife'], "2", 10)
    oQIPLaudosEnsaios:oAPIManager:RespondeJson(oDados)

Return 

WSMETHOD GET reopeninspection PATHPARAM Login, RecnoQPK, OperationRoutines, HasMeasurement WSSERVICE processinspectiontestreports
	
    Local lSucesso          := .F.
    Local nOpc              := -1
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
    lSucesso := oQIPLaudosEnsaios:ReabreInspecaoEEstornaMovimentosCQ(Self:Login, Self:RecnoQPK, Self:OperationRoutines, Self:HasMeasurement, nOpc)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET reopoper PATHPARAM Login, RecnoQPK, OperationRoutines, Operation, HasMeasurement WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lSucesso          := .F.

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
	lSucesso := oQIPLaudosEnsaios:ReabreOperacao(Self:Login, Self:RecnoQPK, Self:OperationRoutines, Self:Operation, Self:HasMeasurement)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET caneditreport PATHPARAM RecnoQPK, OperationRoutines, Operation, Laboratory, ReportLevelPage WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lSucesso          := .F.

	lSucesso := oQIPLaudosEnsaios:LaudoPodeSerEditado(Self:RecnoQPK, Self:OperationRoutines, Self:Operation, Self:Laboratory, Self:ReportLevelPage)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET dellabrep PATHPARAM Login, RecnoQPK, OperationRoutines, Operation, Laboratory, HasMeasurement WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lSucesso          := .F.

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
	lSucesso := oQIPLaudosEnsaios:ExcluiLaudoLaboratorio(Self:Login, Self:RecnoQPK, Self:OperationRoutines, Self:Operation, Self:Laboratory, Self:HasMeasurement)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET deloperep PATHPARAM Login, RecnoQPK, OperationRoutines, Operation, HasMeasurement WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lSucesso          := .F.

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
	lSucesso := oQIPLaudosEnsaios:ExcluiLaudoOperacao(Self:Login, Self:RecnoQPK, Self:OperationRoutines, Self:Operation, Self:HasMeasurement)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET delgenrep PATHPARAM Login, RecnoQPK, OperationRoutines, HasMeasurement WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lSucesso          := .F.

    Self:HasMeasurement := Iif(ValType(Self:HasMeasurement) == "C", Self:HasMeasurement == "true", Self:HasMeasurement)
	lSucesso := oQIPLaudosEnsaios:ExcluiLaudoGeralEEstornaMovimentosCQ(Self:Login, Self:RecnoQPK, Self:OperationRoutines, Self:HasMeasurement)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lSucesso)

Return 

WSMETHOD GET alllaboratorieshavereports PATHPARAM Login, RecnoQPK WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lTodosLaudos      := .F.

	lTodosLaudos := oQIPLaudosEnsaios:ChecaTodosOsLaboratoriosComLaudos(Self:Login, Self:RecnoQPK)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lTodosLaudos)

Return 

WSMETHOD GET alloperationshavereports PATHPARAM Login, RecnoQPK WSSERVICE processinspectiontestreports
	
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local lTodosLaudos      := .F.

	lTodosLaudos := oQIPLaudosEnsaios:ChecaTodasAsOperacoesComLaudos(Self:Login, Self:RecnoQPK)
    oQIPLaudosEnsaios:oAPIManager:RespondeValor("success", lTodosLaudos)

Return 

WSMETHOD GET failintegrationmessages WSSERVICE processinspectiontestreports

    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)
    Local aMensagens        := oQIPLaudosEnsaios:RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos()

    oQIPLaudosEnsaios:oAPIManager:RespondeValor("integrationMessage", aMensagens)

Return

WSMETHOD GET integrationStock WSSERVICE processinspectiontestreports
	
    Local lReturn           := .F.
    Local oQIPA215Estoque   := QIPA215Estoque()  :New(-1)
    Local oQIPLaudosEnsaios := QIPLaudosEnsaios():New(Self)

    lReturn                 := oQIPA215Estoque:lIntegracaoEstoqueHabilitada

    oQIPLaudosEnsaios:oAPIManager:RespondeValor("integrationEnabled", lReturn)

Return 
