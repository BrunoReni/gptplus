#INCLUDE "TOTVS.CH"
#INCLUDE "FWLIBVERSION.CH"
#include 'Fileio.CH'

/*/{Protheus.doc} QLTMetrics
Envia M�trica em Thread
@author brunno.costa
@since 13/02/2023
@version P12.1.2310
@param 01 - cEmpAux   , caracter, grupo de empresa para prepara��o do ambiente
@param 02 - cFilAux   , caracter, filial para prepara��o do ambiente
@param 03 - cSiglaModu, caracter, sigla do m�dulo para prepara��o do ambiente
@param 04 - nOpc      , caracter, id interno da m�trica para disparo:
                    nOpc == 1 Self:enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco()
/*/

Main Function QLTMetrics(cEmpAux, cFilAux, cSiglaModu, nOpc)

    Local lAmbiente     := .F.
    Local lSemInterface := .T.
    Local oSelf         := Nil

    Default nOpc        := 0

    RPCSetType(3)
    lAmbiente := RpcSetEnv(cEmpAux, cFilAux,,,cSiglaModu)

    If lAmbiente
        oSelf := QLTMetrics():New(lSemInterface)

        If nOpc == 1
            oSelf:enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco()
        EndIf
        RpcClearEnv()
    EndIf

Return 

/*/{Protheus.doc} QLTMetrics
Classe de Controle do Envio de M�tricas dos M�dulos de Qualidade
@type  Classe
@author brunno.costa
@since 13/02/2023
@version P12.1.2310
/*/
CLASS QLTMetrics FROM LongNameClass
    
    DATA cBanco        as String
    DATA lSemInterface as Logical
    DATA lSincrono     as Logical

    //M�todos p�blicos
    METHOD new(lSemInterface) Constructor
    METHOD abreThreadExtracaoBancoEEnvioMetricaQuantidadeResultadosEnsaiosDigitadosQIP()
    METHOD enviaMetricaNaoConformidadeAberta(cModulo)
    METHOD enviaMetricaPlanoDeAcaoAberto(cModulo)
    METHOD enviaMetricaQuantidadeDocumentosLidosQDO(cRotina, cQAA_TPWORD, cTipoDoc)
    METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP(cRotina, nResultados)

    //M�todos Internos
    METHOD checaPrimeiroEnvioSincrono(cChave)
    METHOD confirmaEnvioSemInterfaceSincrono(cUsuario, cIDModulo, cSubRotina)
    METHOD enviaMetrica(cIDModulo, cRotina, cSubRotina, cIDMetric, nResultados)
    METHOD enviaMetricaAssincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco()
    METHOD enviaMetricaSincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    METHOD retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco()
    METHOD retornaTipoExibicaoDocumentoDoUsuario()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@since 13/02/2023
@version P12.1.2310
@param 01 - lSemInterface, l�gico, indica execu��o sem interface
@return Self, objeto, inst�ncia da classe
/*/
METHOD new(lSemInterface) CLASS QLTMetrics
    Default lSemInterface  := IsBlind()
    Self:lSincrono     := .F.
    Self:lSemInterface := lSemInterface
    Self:cBanco        := Upper(TcgetDB())
Return Self

/*/{Protheus.doc} enviaMetrica
Envia M�trica pela Regra Padr�o de Qualidade: primeiro envio s�ncrono, demais ass�ncronos semanais.
@since 13/02/2023
@version P12.1.2310
@param 01 - cIDModulo  , caracter, c�digo do m�dulo
@param 02 - cRotina    , caracter, indica a rotina em execu��o
@param 03 - cSubRotina , caracter, indica a subrotina para detalhamento da m�trica
@param 04 - cIDMetric  , caracter, indica o ID da M�trica
@param 05 - nResultados, num�rico, indica a quantidade de resultados para registro da m�trica
/*/
METHOD enviaMetrica(cIDModulo, cRotina, cSubRotina, cIDMetric, nResultados) CLASS QLTMetrics

    If Self:checaPrimeiroEnvioSincrono(cIDMetric + "_" + cSubRotina)
        Self:enviaMetricaSincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    Else
        Self:enviaMetricaAssincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    EndIf
    Self:confirmaEnvioSemInterfaceSincrono(Nil, cIDModulo, cSubRotina)

Return

/*/{Protheus.doc} enviaMetricaSincrona
Envia M�trica de forma S�ncrona
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execu��o
@param 02 - cSubRotina , caracter, indica a subrotina para detalhamento da m�trica
@param 03 - cIDMetric  , caracter, indica o ID da M�trica
@param 04 - nResultados, num�rico, indica a quantidade de resultados para registro da m�trica
/*/
METHOD enviaMetricaSincrona(cRotina, cSubRotina, cIDMetric, nResultados) CLASS QLTMetrics

    Local cBkpRotina := Nil

     If FwLibVersion() >= "20200727"
        cSubRotina := Lower(cSubRotina)
        cBkpRotina := FunName()
        SetFunName(cRotina)
        FWMetrics():addMetrics(cSubRotina, {{cIDMetric, nResultados }} )
        SetFunName(cBkpRotina)
    EndIf

Return

/*/{Protheus.doc} enviaMetricaAssincrona
Envia M�trica de Forma Ass�ncrona - Semanal
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execu��o
@param 02 - cSubRotina , caracter, indica a subrotina para detalhamento da m�trica
@param 03 - cIDMetric  , caracter, indica o ID da M�trica
@param 04 - nResultados, num�rico, indica a quantidade de resultados para registro da m�trica
/*/
METHOD enviaMetricaAssincrona(cRotina, cSubRotina, cIDMetric, nResultados) CLASS QLTMetrics

    Local dDataEnvio := Nil

    If FwLibVersion() >= "20210517" .and. !("|"+Self:cBanco+"|" $ "|OPENEDGE|INFORMIX|DB2|")
        cSubRotina := Lower(cSubRotina)
        dDataEnvio := LastDayWeek(Date())
        FwCustomMetrics():setSumMetric(cSubRotina, cIDMetric, nResultados, dDataEnvio, /*nLapTime*/, cRotina)
    EndIf

Return


/*/{Protheus.doc} enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP
Envia M�trica Quantidade de Resultados Ensaios Digitados do QIP por Rotina e Quantidade
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execu��o
@param 02 - nResultados, num�rico, indica a quantidade de resultados para registro da m�trica
/*/
METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP(cRotina, nResultados) CLASS QLTMetrics

    Local cIDMetric   := "gestao-da-qualidade-protheus_quantidade-de-resultados-de-ensaios-digitados-no-modulo-de-inspecao-de-processos_total"
    Local cIDModulo   := "25"
    Local cSubRotina  := "protheus_sigaqip_"
    Local cSufPRAPONT := ""
    Local cSufQINSPEC := ""
    Local cSufQIPMAT  := ""

    Default cRotina  := ""

    Self:new(.F.)
    cSufQIPMAT  := "MV_QIPMAT_"  + AllTrim(    SuperGetMV("MV_QIPMAT" , .F., "N"))
    cSufQINSPEC := "MV_QINSPEC_" + AllTrim(    SuperGetMV("MV_QINSPEC", .F., "2"))
    cSufPRAPONT := "MV_PRAPONT_" + AllTrim(Str(SuperGetMV("MV_PRAPONT", .F., 2 )))

    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"    , cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQIPMAT         , cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQINSPEC        , cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufPRAPONT        , cIDMetric, nResultados)

Return

/*/{Protheus.doc} abreThreadExtracaoBancoEEnvioMetricaQuantidadeResultadosEnsaiosDigitadosQIP
Abre Thread para Envio da M�trica Quantidade de Resultados Ensaios Digitados no QIP baseados no Volume de Dados do Banco de Dados
@since 13/02/2023
@version P12.1.2310
/*/
METHOD abreThreadExtracaoBancoEEnvioMetricaQuantidadeResultadosEnsaiosDigitadosQIP() CLASS QLTMetrics
    StartJob("QLTMetrics" , GetEnvServer() , .F. , cEmpAnt, cFilAnt, "QIP", 1) //nOpc==1 -> enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco
Return

/*/{Protheus.doc} enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco
Envia da M�trica Quantidade de Resultados Ensaios Digitados no QIP baseados no Volume de Dados do Banco de Dados
@since 13/02/2023
@version P12.1.2310
/*/
METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco() CLASS QLTMetrics

    Local cIDMetric   := "gestao-da-qualidade-protheus_quantidade-de-resultados-de-ensaios-digitados-no-modulo-de-inspecao-de-processos_total"
    Local cIDModulo   := "25"
    Local cRotina     := "QIPLOAD"
    Local cSubRotina  := "protheus_sigaqip_"
    Local cSufPRAPONT := ""
    Local cSufQINSPEC := ""
    Local cSufQIPMAT  := ""
    Local nResultados := 0
    Local oQLTManager := Nil

    If FindClass("QLTQueryManager")
	    oQLTManager := QLTQueryManager():New()
        If oQLTManager:confirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "QLTMetrics_QIPLOAD_" + cIDMetric, Nil, 1, .T.)
            Self:new(.F.)
            cSufQIPMAT  := "MV_QIPMAT_"  + AllTrim(    SuperGetMV("MV_QIPMAT" , .F., "N"))
            cSufQINSPEC := "MV_QINSPEC_" + AllTrim(    SuperGetMV("MV_QINSPEC", .F., "2"))
            cSufPRAPONT := "MV_PRAPONT_" + AllTrim(Str(SuperGetMV("MV_PRAPONT", .F., 2 )))

            nResultados := Self:retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco()
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, nResultados)
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQIPMAT         , cIDMetric, nResultados)
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQINSPEC        , cIDMetric, nResultados)
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufPRAPONT        , cIDMetric, nResultados)
        EndIf
    EndIf
Return

/*/{Protheus.doc} retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco
Retorna quantidade de resultados de ensaios digitados no banco de dados do grupo de empresas
@since 13/02/2023
@version P12.1.2310
@return nResultados, num�rico, quantidade de resultados QPQ e QPS existentes na base do cliente (indiferente a filial)
/*/
METHOD retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco() CLASS QLTMetrics

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT QTDQPQ + QTDQPS AS TOTAL "
    cQuery += " FROM  "

    cQuery += 	" (SELECT COUNT(*) QTDQPQ "
    cQuery += 	" FROM " + RetSQLName("QPQ")
    cQuery += 	" WHERE D_E_L_E_T_= ' ' "
    cQuery += 	" AND QPQ_FILIAL = '" + xFilial("QPQ") + "') QPQ, "

    cQuery += 	" (SELECT COUNT(*) QTDQPS "
    cQuery += 	" FROM "+RetSQLName("QPS")
    cQuery += 	" WHERE D_E_L_E_T_= ' ' "
    cQuery += 	" AND QPS_FILIAL = '" + xFilial("QPS") + "') QPS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DBGotop())
	If (cAliasQry)->(!EOF())
        nResultados := (cAliasQry)->TOTAL
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} confirmaEnvioSemInterfaceSincrono
Fun��o de tratamento de envio sem interface s�ncrono
@since 13/02/2023
@version P12.1.2310
@param 01 - cUsuario  , caracter, indica o c�digo do usu�rio logado no sistema
@param 02 - cIDModulo , caracter, indica o c�digo do m�dulo para v�nculo a m�trica
@param 03 - cSubRotina, caracter, indica a subrotina para detalhamento da m�trica
/*/
METHOD confirmaEnvioSemInterfaceSincrono(cUsuario, cIDModulo, cSubRotina) CLASS QLTMetrics
    If Self:lSemInterface .and. Self:lSincrono
        FWLsPutAsyncInfo("LS006", cUsuario, cIDModulo, cSubRotina)
    EndIf
Return

/*/{Protheus.doc} checaPrimeiroEnvioSincrono
Fun��o que checa necessidade de primeiro envio s�ncrono baseado em sem�foro criado fisicamente no diret�rio de sem�foros
@since 13/02/2023
@version P12.1.2310
@param 01 - cChave, caracter, indica a chave para checagem de primeiro envio
@return lSincrono, l�gico, indica se � o primeiro retorno s�ncrono (.T.) ou se n�o � (.F.)
/*/
METHOD checaPrimeiroEnvioSincrono(cChave) CLASS QLTMetrics
    Local lSincrono   := .F.
    Local oQLTManager := Nil
    If FindClass("QLTQueryManager")
	    oQLTManager := QLTQueryManager():New()
        If oQLTManager:confirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "QLTMetrics_" + cChave, Nil, 9999, .T.) //9999 meses - 833 anos)
            lSincrono := .T.
        EndIf
    EndIf
    Self:lSincrono := lSincrono
Return lSincrono

/*/{Protheus.doc} enviaMetricaQuantidadeDocumentosLidosQDO
Envia M�trica Quantidade de Documentos Lidos no QDO
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execu��o
@param 02 - cTipoDoc   , caracter, tipo do documento (I - Interno) ou (E - Externo)
@param 03 - cQAA_TPWORD, caracter, indica a quantidade de resultados para registro da m�trica
/*/
METHOD enviaMetricaQuantidadeDocumentosLidosQDO(cRotina, cTipoDoc, cQAA_TPWORD) CLASS QLTMetrics

    Local cIDMetric   := "gestao-da-qualidade-protheus_quantidade-de-documentos-lidos-no-modulo-sigaqdo-no-cliente_total"
    Local cIDModulo   := "24"
    Local cSubRotina  := "protheus_sigaqdo_"

    Default cRotina     := ""
    Default cQAA_TPWORD := Self:retornaTipoExibicaoDocumentoDoUsuario()
    Default cTipoDoc    := Iif(M->QDH_DTOIE == Nil .OR. Empty(M->QDH_DTOIE), QDH->QDH_DTOIE, M->QDH_DTOIE)

    Self:new(.F.)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"             , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina         , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "QAA_TPWORD_" + cQAA_TPWORD , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "tipo_documento_" + cTipoDoc, cIDMetric, 1)
Return

/*/{Protheus.doc} retornaTipoExibicaoDocumentoDoUsuario
Retorna Tipo de Exibi��o Documento do Usuario
@since 13/02/2023
@version P12.1.2310
@return cQAA_TPWORD, caracter, modo de leitura do documento vinculada ao usu�rio
/*/
METHOD retornaTipoExibicaoDocumentoDoUsuario() CLASS QLTMetrics

    Local aArea       := GetArea()
    Local cAlias      := GetNextAlias()
    Local cLogin      := ""
    Local cQAA_TPWORD := ""
    Local cUsuario    := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    BeginSql Alias cAlias
        SELECT QAA_TPWORD
		FROM %Table:QAA% 
		WHERE %NotDel%
            AND LTRIM(RTRIM(UPPER(QAA_LOGIN))) =  %Exp:cLogin%
            AND QAA_LOGIN                      <> ' '
    EndSql

    If !(cAlias)->(Eof()) 
        cQAA_TPWORD := (cAlias)->QAA_TPWORD
    EndIf 

    (cAlias)->(DbCloseArea())

    RestArea(aArea)
Return cQAA_TPWORD

/*/{Protheus.doc} enviaMetricaNaoConformidadeAberta
Envia M�trica Quantidade N�o Conformidade Aberta
@since 13/02/2023
@version P12.1.2310
@param 01 - cModulo, caracter, sigla do m�dulo origem
/*/
METHOD enviaMetricaNaoConformidadeAberta(cModulo) CLASS QLTMetrics

    Local cIDMetric  := "gestao-da-qualidade-protheus_quantidade-de-nao-conformidades-geradas-no-cliente_total"
    Local cIDModulo  := "36"
    Local cRotina    := FunName()
    Local cSubRotina := "protheus_sigaqnc_"

    Default cModulo   := "QNC"

    Self:new(.F.)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"    , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "modulo_" + cModulo, cIDMetric, 1)

Return

/*/{Protheus.doc} enviaMetricaPlanoDeAcaoAberto
Envia M�trica Quantidade Plano de A��o Aberto
@since 13/02/2023
@version P12.1.2310
@param 01 - cModulo, caracter, sigla do m�dulo origem
/*/
METHOD enviaMetricaPlanoDeAcaoAberto(cModulo) CLASS QLTMetrics

    Local cIDMetric  := "gestao-da-qualidade-protheus_quantidade-de-nao-conformidades-geradas-no-cliente_total"
    Local cIDModulo  := "36"
    Local cRotina    := FunName()
    Local cSubRotina := "protheus_sigaqnc_plano_de_acao_"

    Default cModulo   := "QNC"

    Self:new(.F.)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"    , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "modulo_" + cModulo, cIDMetric, 1)

Return
