#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PCPMonitorCarga
Classe para realizar a carga dos Monitores na base de dados
@type Class
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Class PCPMonitorCarga FROM LongNameClass

    Private DATA cCodigoMonitor              AS Character
    Private DATA cMensagemErro               AS Character
    Private DATA nNumeroPropriedadesMonitor  AS Numeric
    Private DATA oMonitor                    AS Object
    Private DATA oExemploJson                AS Object
    Private DATA oPropriedadesMonitor        AS Object
    
    //Método construtor da classe
    Public Method New() Constructor
    Public Method Destroy()

    //Métodos
    Public Method setaTitulo(cTitulo)
    Public Method setaObjetivo(cObjetivo)
    Public Method setaAgrupador(cAgrup)
    Public Method setaFuncaoNegocio(cAPINeg)
    Public Method setaTiposPermitidos(cTiposPer)
    Public Method setaTiposGraficoPermitidos(cTpGrafPer)
    Public Method setaTipoPadrao(cTpPdr)
    Public Method setaTipoGraficoPadrao(cTpGrfPdr)
    Public Method setaExemploJsonGrafico(oSeries,aTags,aDetalhes,aCategorias,cTpGrfExp)
    Public Method setaExemploJsonTexto(lTabs,oExemplos)    
    Public Method setaPropriedade(cCodigo,cValPadrao,cTitulo,nTipo,cTamanho,cDecimal,cClasses,oEstilos,cIcone,oPrmAdc)
    Public Method setaTipoDetalhe(cTpDetalhe)
    Public Method gravaMonitorPropriedades()
    Public Method recuperaMensagemErro()
    Public Method registraErroTransacao(oErro)
    Private Method persisteCadastroMonitor()
    Private Method persisteCadastroPropriedadesMonitor()
    Private Method montaJsonExemploTexto(oExemplo,oJson)
    Static Method monitorAtualizado(cApiNeg)
EndClass

/*/{Protheus.doc} New
Método construtor
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method New() Class PCPMonitorCarga
    ::oMonitor                    := JsonObject():New()
    ::oExemploJson                := JsonObject():New()
    ::oPropriedadesMonitor        := {}
    ::nNumeroPropriedadesMonitor  := 0
    ::cCodigoMonitor              := ""
    ::cMensagemErro               := ""
Return

/*/{Protheus.doc} Destroy
Libera os objetos da memória
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method Destroy() Class PCPMonitorCarga
	FreeObj(::oMonitor)
    FreeObj(::oExemploJson)
    FreeObj(::oPropriedadesMonitor)
Return

/*/{Protheus.doc} setaTitulo
Inclui o atributo titulo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTitulo, caracter, Titulo do Monitor
@return Nil
/*/
Method setaTitulo(cTitulo) Class PCPMonitorCarga
    ::oMonitor["titulo"] := cTitulo
Return

/*/{Protheus.doc} setaObjetivo
Inclui o atributo objetivo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cObjetivo, caracter, Objetivo do Monitor
@return Nil
/*/
Method setaObjetivo(cObjetivo) Class PCPMonitorCarga
    ::oMonitor["objetivo"] := cObjetivo
Return

/*/{Protheus.doc} setaAgrupador
Inclui o atributo agrupador
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cAgrup, caracter, Agrupador do Monitor
@return Nil
/*/
Method setaAgrupador(cAgrup) Class PCPMonitorCarga
    ::oMonitor["agrupador"] := cAgrup
Return

/*/{Protheus.doc} setaFuncaoNegocio
Inclui o atributo apiNegocio
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cAPINeg, caracter, Função de negócio que retornará os dados do Monitor
@return Nil
/*/
Method setaFuncaoNegocio(cAPINeg) Class PCPMonitorCarga
    ::oMonitor["apiNegocio"] := cAPINeg
Return

/*/{Protheus.doc} setaTiposPermitidos
Inclui o atributo opcoesTipo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTiposPer, caracter, Tipos permitidos para o monitor (info;chart)
@return Nil
/*/
Method setaTiposPermitidos(cTiposPer) Class PCPMonitorCarga
    ::oMonitor["opcoesTipo"] := cTiposPer
Return

/*/{Protheus.doc} setaTiposGraficoPermitidos
Inclui o atributo opcoesSubtipo
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTpGrafPer, caracter, Tipos permitidos de gráfico (pie;column;bar)
@return Nil
/*/
Method setaTiposGraficoPermitidos(cTpGrafPer) Class PCPMonitorCarga
    ::oMonitor["opcoesSubtipo"] := cTpGrafPer
Return

Method setaTipoPadrao(cTpPdr) Class PCPMonitorCarga
    ::oMonitor["tipo"] := cTpPdr
Return

Method setaTipoGraficoPadrao(cTpGrfPdr) Class PCPMonitorCarga
    ::oMonitor["subtipo"] := cTpGrfPdr
Return

/*/{Protheus.doc} setaExemploJsonGrafico
Atribui as configurações do exemplo do Monitor
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  oSeries  , objeto Json, Objeto Json com as Series do chart
@param  aTags    , array objetos, Array de objetos Json com as tags do Monitor
@param  aDetalhes, array objetos, Array de objetos Json com os detalhes do Monitor
@return Nil
/*/
Method setaExemploJsonGrafico(oSeries,aTags,aDetalhes,aCategorias,cTpGrfExp,oGaugeProp) Class PCPMonitorCarga
    Local aNSeries := oSeries:GetNames()
    Local nIndice  := 0

    Default oSeries := JsonObject():New(), aTags := {}, aDetalhes := {}, aCategorias := {}, oGaugeProp := JsonObject():New()

    ::oExemploJson["tipo"]    := "chart"
    ::oExemploJson["subtipo"] := cTpGrfExp
    ::oExemploJson["exemplo"] := JsonObject():New()
	::oExemploJson["exemplo"]["altura"]     := 250
    ::oExemploJson["exemplo"]["categorias"] := aCategorias
    ::oExemploJson["exemplo"]["gauge"]      := oGaugeProp
    ::oExemploJson["exemplo"]["series"]     := {}
    For nIndice := 1 To Len(aNSeries)
	    aAdd(::oExemploJson["exemplo"]["series"], JsonObject():New())
        ::oExemploJson["exemplo"]["series"][nIndice]["color"]   := oSeries[aNSeries[nIndice]][2]
        ::oExemploJson["exemplo"]["series"][nIndice]["data"]    := oSeries[aNSeries[nIndice]][1]
        ::oExemploJson["exemplo"]["series"][nIndice]["tooltip"] := ""
        ::oExemploJson["exemplo"]["series"][nIndice]["label"]   := aNSeries[nIndice]
    Next nIndice
    ::oExemploJson["exemplo"]["tags"] := {}
    For nIndice := 1 To Len(aTags)
        aAdd(::oExemploJson["exemplo"]["tags"], JsonObject():New())
        ::oExemploJson["exemplo"]["tags"][nIndice]["texto"]      := aTags[nIndice]["texto"]
        ::oExemploJson["exemplo"]["tags"][nIndice]["colorTexto"] := aTags[nIndice]["colorTexto"]
        ::oExemploJson["exemplo"]["tags"][nIndice]["icone"]      := aTags[nIndice]["icone"]
    Next nIndice     
    ::oExemploJson["exemplo"]["detalhes"] := {}
    For nIndice := 1 To Len(aDetalhes)
        aAdd(::oExemploJson["exemplo"]["detalhes"], JsonObject():New())
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["texto"]     := aDetalhes[nIndice]["texto"]
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["hyperlink"] := aDetalhes[nIndice]["hyperlink"]
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["classe"]    := aDetalhes[nIndice]["classe"]
        ::oExemploJson["exemplo"]["detalhes"][nIndice]["icone"]     := aDetalhes[nIndice]["icone"]
    Next nIndice   
Return

Method setaExemploJsonTexto(lTabs,oExemplos) Class PCPMonitorCarga
    Local nIndice := 0

    ::oExemploJson["tipo"]    := "info"
    ::oExemploJson["usaTabs"] := lTabs
    If ::oExemploJson["usaTabs"]
        ::oExemploJson["exemplo"] := {}
        For nIndice := 1 To Len(oExemplos)
            aAdd(::oExemploJson["exemplo"], JsonObject():New())
            ::montaJsonExemploTexto(oExemplos[nIndice],::oExemploJson["exemplo"][nIndice])
        Next nIndice
    Else
        ::oExemploJson["exemplo"] := JsonObject():New()
        ::montaJsonExemploTexto(oExemplos,::oExemploJson["exemplo"])
    EndIf
Return

Method montaJsonExemploTexto(oExemplo,oJson) Class PCPMonitorCarga
    Local nIndice := 0

    oJson["corFundo"]  := oExemplo["corFundo"]
    oJson["corTitulo"] := oExemplo["corTitulo"]
    oJson["tags"]   := {}
    For nIndice := 1 To Len(oExemplo["tags"])
        aAdd(oJson["tags"],JsonObject():New())
        oJson["tags"][nIndice]["icone"]      := oExemplo["tags"][nIndice]["icone"]       
        oJson["tags"][nIndice]["colorTexto"] := oExemplo["tags"][nIndice]["colorTexto"]  
        oJson["tags"][nIndice]["texto"]      := oExemplo["tags"][nIndice]["texto"]       
    Next nIndice
    oJson["linhas"]    := {}
    For nIndice := 1 To Len(oExemplo["linhas"])
        aAdd(oJson["linhas"],JsonObject():New())
        oJson["linhas"][nIndice]["texto"]           := oExemplo["linhas"][nIndice]["texto"]
        oJson["linhas"][nIndice]["tipo"]            := oExemplo["linhas"][nIndice]["tipo"]          
        oJson["linhas"][nIndice]["classeTexto"]     := oExemplo["linhas"][nIndice]["classeTexto"]
        oJson["linhas"][nIndice]["styleTexto"]      := oExemplo["linhas"][nIndice]["styleTexto"]    
        oJson["linhas"][nIndice]["tituloProgresso"] := oExemplo["linhas"][nIndice]["tituloProgresso"]
        oJson["linhas"][nIndice]["valorProgresso"]  := oExemplo["linhas"][nIndice]["valorProgresso"]
        oJson["linhas"][nIndice]["icone"]           := oExemplo["linhas"][nIndice]["icone"] 
    Next nIndice
Return

/*/{Protheus.doc} setaPropriedade
Atribui uma propriedade ao filtro do Monitor
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cCodigo   , caracter   , Codigo da Propriedade
@param  cValPadrao, caracter   , Valor Padrão
@param  cTitulo   , caracter   , Titulo
@param  nTipo     , numerico   , Tipo do componente(1-Text;2-Numerico;3-Data;4-Select;5-Multi-Select)
@param  cTamanho  , caracter   , Tamanho do campo texto ou numerico
@param  cDecimal  , caracter   , Número de casas decimais do campo numerico
@param  cClasses  , caracter   , Classes para formatar o componente
@param  oEstilos  , objeto Json, Estilos para formatar o componente
@param  cIcone    , caracter   , Icone do componente
@param  oPrmAdc   , objeto json, Parametros adicionais
@return Nil
/*/
Method setaPropriedade(cCodigo,cValPadrao,cTitulo,nTipo,cTamanho,cDecimal,cClasses,oEstilos,cIcone,oPrmAdc) Class PCPMonitorCarga
    Default cValPadrao := "", cTamanho := 0, cDecimal := 0,cClasses := "",oEstilos := JsonObject():New(), cIcone := "",oPrmAdc := JsonObject():New()

    ::nNumeroPropriedadesMonitor++
    aAdd(::oPropriedadesMonitor, JsonObject():New())
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["codPropriedade"]       := cCodigo
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["valorPadrao"]          := cValPadrao
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["titulo"]               := cTitulo
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tipo"]                 := nTipo
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tamanhoTexto"]         := IIF(nTipo == 1,cTamanho,0)
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tamanhoNumerico"]      := IIF(nTipo == 2,cTamanho,0)
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["tamanhoDecimal"]       := cDecimal
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["classes"]              := cClasses
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["estilos"]              := oEstilos:ToJson()
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["icone"]                := cIcone
    ::oPropriedadesMonitor[::nNumeroPropriedadesMonitor]["parametrosAdicionais"] := oPrmAdc:ToJson()
Return

/*/{Protheus.doc} setaTipoDetalhe
Inclui o atributo tipoDetalhe
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cTpDetalhe, caracter, Tipo de abertura do detalhe (modal;detalhe;externo(datasul))
@return Nil
/*/
Method setaTipoDetalhe(cTpDetalhe) Class PCPMonitorCarga
    ::oMonitor["tipoDetalhe"] := cTpDetalhe
Return

/*/{Protheus.doc} gravaMonitorPropriedades
Gerencia a gravação do Monitor e suas propriedades em base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method gravaMonitorPropriedades() Class PCPMonitorCarga
    Local bErrorBlck := Nil
    Local lRet        := .T.

	bErrorBlck := ErrorBlock({|oErro| ::registraErroTransacao(oErro), Break(oErro) })
    Begin Transaction
        Begin Sequence
                ::persisteCadastroMonitor()
                ::persisteCadastroPropriedadesMonitor()                    
        Recover
            lRet := .F.
        End Sequence
    End Transaction
    ErrorBlock(bErrorBlck)
Return lRet

/*/{Protheus.doc} persisteCadastroMonitor
Persiste o Monitor em base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method persisteCadastroMonitor() Class PCPMonitorCarga
    Local cAlias   := GetNextAlias()

    BeginSql Alias cAlias
		%noparser%
		SELECT MAX(HZE_CODIGO) AS HZE_CODIGO FROM %Table:HZE% WHERE %NotDel%
	EndSql
        If Empty((cAlias)->HZE_CODIGO)
        ::cCodigoMonitor := PadL("1", GetSx3Cache("HZE_CODIGO","X3_TAMANHO"), "0")
    Else
        ::cCodigoMonitor := Soma1(PadL((cAlias)->HZE_CODIGO, GetSx3Cache("HZE_CODIGO","X3_TAMANHO"), "0"))
    EndIf
    RecLock("HZE", .T.)
        HZE->HZE_FILIAL := xFilial("HZE")
        HZE->HZE_CODIGO := ::cCodigoMonitor
        HZE->HZE_TITULO := ::oMonitor["titulo"]
        HZE->HZE_OBJTV  := ::oMonitor["objetivo"]
        HZE->HZE_AGRUP  := ::oMonitor["agrupador"]
        HZE->HZE_APINEG := ::oMonitor["apiNegocio"]
        HZE->HZE_TIPO   := ::oMonitor["opcoesTipo"]
        HZE->HZE_TIPOGR := ::oMonitor["opcoesSubtipo"]
        HZE->HZE_PADRAO := "S"
        HZE->HZE_EXJSON := ::oExemploJson:ToJson()
        HZE->HZE_TPDETL := ::oMonitor["tipoDetalhe"]
        HZE->HZE_TPPD   := ::oMonitor["tipo"]
        HZE->HZE_TPGRPD := ::oMonitor["subtipo"]
    MsUnlock()
Return

/*/{Protheus.doc} persisteCadastroPropriedadesMonitor
Persiste as propriedades do Monitor em base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method persisteCadastroPropriedadesMonitor() Class PCPMonitorCarga
    Local nIndice := 0

    For nIndice := 1 To ::nNumeroPropriedadesMonitor
        RecLock("HZF", .T.)
            HZF->HZF_FILIAL := xFilial("HZF")
            HZF->HZF_CODIGO := ::oPropriedadesMonitor[nIndice]["codPropriedade"]
            HZF->HZF_MONIT  := ::cCodigoMonitor
            HZF->HZF_VALPAD := ::oPropriedadesMonitor[nIndice]["valorPadrao"]
            HZF->HZF_TITULO := ::oPropriedadesMonitor[nIndice]["titulo"]
            HZF->HZF_TIPO   := ::oPropriedadesMonitor[nIndice]["tipo"]
            HZF->HZF_TAMTXT := ::oPropriedadesMonitor[nIndice]["tamanhoTexto"]
            HZF->HZF_TAMNUM := ::oPropriedadesMonitor[nIndice]["tamanhoNumerico"]
            HZF->HZF_TAMDEC := ::oPropriedadesMonitor[nIndice]["tamanhoDecimal"]
            HZF->HZF_CLSCMP := ::oPropriedadesMonitor[nIndice]["classes"]
            HZF->HZF_ESTCMP := ::oPropriedadesMonitor[nIndice]["estilos"]
            HZF->HZF_ICNCMP := ::oPropriedadesMonitor[nIndice]["icone"]
            HZF->HZF_PRMADC := ::oPropriedadesMonitor[nIndice]["parametrosAdicionais"]
        MsUnlock()
    Next nIndice
Return

/*/{Protheus.doc} registraErroTransacao
Registra o log de erro no appserver desfaz o que foi gravado na base de dados
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method registraErroTransacao(oErro) Class PCPMonitorCarga

    ::cMensagemErro := oErro:Description
	LogMsg('PCPMonitorCarga', 14, 4, 1, '', '',oErro:Description + CHR(10) + oErro:ErrorStack + CHR(10) + oErro:ErrorEnv)
	If InTransact()
		DisarmTransaction()
	EndIf
Return

/*/{Protheus.doc} recuperaMensagemErro
Recupera o atributo da classe com a mensagem de erro
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@return Nil
/*/
Method recuperaMensagemErro() Class PCPMonitorCarga
Return ::cMensagemErro

/*/{Protheus.doc} recuperaMensagemErro
Recupera o atributo da classe com a mensagem de erro
@type Method
@author renan.roeder
@since 27/01/2023
@version P12.1.2310
@param  cApiNeg, caracter, Função de negócio vinculada ao Monitor
@return lRet   , logico  , Retorna verdadeiro se a carga do Monitor já foi realizada
/*/
Method monitorAtualizado(cApiNeg) Class PCPMonitorCarga
    Local cAlias := GetNextAlias()
    Local lRet   := .F.

    BeginSql Alias cAlias
		SELECT 
            COUNT(HZE.HZE_CODIGO) AS TOTAL 
        FROM %Table:HZE% HZE
        WHERE HZE.HZE_FILIAL = %xFilial:HZE% 
          AND HZE.HZE_APINEG = %exp:cApiNeg% 
          AND HZE.%NotDel%
	EndSql
    If (cAlias)->TOTAL > 0
        lRet := .T.
    EndIf
    (cAlias)->(DbCloseArea())
Return lRet
