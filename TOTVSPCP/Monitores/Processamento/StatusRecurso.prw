#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusRecurso
Classe para prover os dados do Monitor de Status do Recurso
@type Class
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@return Nil
/*/
Class StatusRecurso FROM LongNameClass
    Static Method BuscaDados(oFiltros)
    Static Method BuscaDetalhes(oFiltro,nPagina)
    Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} BuscaDados
Realiza a busca dos dados para o Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDados(oFiltros) Class StatusRecurso
    Local cHrDispRec := ""
    Local cCodRecur  := ""
    Local cWhere     := ""
    Local dDataFin   := dDatabase
    Local dDataIni   := dDatabase
    Local oJsRet     := Nil
    Local oJsTmpApt  := Nil
    Local oJsUltApt  := Nil

    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    dDataFin              := dDatabase
    dDataIni              := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["04_TIPOPERIODO"]),dDataFin,cValToChar(oFiltros["05_PERIODO"]))
    cCodRecur             := AllTrim(oFiltros["02_H6_RECURSO"])
    cWhere                := filtroQuery(oFiltros,dToS(dDataIni),dToS(dDataFin))
    cHrDispRec            := PCPA152Disponibilidade():buscaHorasRecurso(cCodRecur,dDataIni,dDataFin)["totalHoras"]
    oJsTmpApt             := calcTmpApt(oFiltros,dDataIni,dDataFin)
    oJsUltApt             := ultApontam(cWhere,oFiltros["01_H6_FILIAL"])
    oJsRet                := fmtRetorno(cHrDispRec,oJsTmpApt,oJsUltApt,cCodRecur,dDataIni,dDataFin)
Return oJsRet:ToJson()

/*/{Protheus.doc} fmtRetorno
Monta objeto json para retornar os dados do Monitor
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	cHrDispRec, caracter   , Horas disponiveis no recurso
@param	oJsTmpApt , objeto json, Objeto json com os tempos de apontamento no período
@param	oJsUltApt , objeto json, Objeto json com o ultimo apontamento
@param	cCodRecur , caracter   , Codigo do recurso
@param	dDataIni  , data       , Data Inicial
@param	dDataFin  , data       , Data Final
@return oJson     , objeto json, Objeto json com os dados para retorno
/*/
Static Function fmtRetorno(cHrDispRec,oJsTmpApt,oJsUltApt,cCodRecur,dDataIni,dDataFin)
    Local oJson      := JsonObject():New()
    Local oJsCxVerde := JsonObject():New()
    Local oJsCxVmlha := JsonObject():New()

    oJsCxVerde["background-color"] := COR_VERDE
    oJsCxVerde["border-radius"]    := "3px"
    oJsCxVerde["border-color"]     := COR_VERDE
    oJsCxVerde["border"]           := "5px"
    oJsCxVerde["cursor"]           := "pointer"
    oJsCxVmlha["background-color"] := COR_VERMELHO
    oJsCxVmlha["border-radius"]    := "3px"
    oJsCxVmlha["border-color"]     := COR_VERMELHO
    oJsCxVmlha["border"]           := "5px"
    oJsCxVmlha["cursor"]           := "pointer"

    oJson["alturaMinimaWidget"] := "350px"
    oJson["alturaMaximaWidget"] := "500px"
    oJson["corFundo"]  := "white"
    oJson["corTitulo"] := ""
    oJson["tags"]   := {}
    aAdd(oJson["tags"],JsonObject():New())
    oJson["tags"][1]["icone"]      := "po-icon-calendar"
    oJson["tags"][1]["colorTexto"] := ""
    oJson["tags"][1]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    aAdd(oJson["tags"],JsonObject():New())
    oJson["tags"][2]["icone"]      := "po-icon-manufacture"
    oJson["tags"][2]["colorTexto"] := ""
    oJson["tags"][2]["texto"]      := cCodRecur
    oJson["linhas"] := {}
    aAdd(oJson["linhas"],JsonObject():New())
    oJson["linhas"][1]["texto"]             := "Horas Produtivas"
    oJson["linhas"][1]["tipo"]              := "texto"
    oJson["linhas"][1]["classeTexto"]       := "po-font-text-large po-text-center po-sm-6 po-pt-2"
    oJson["linhas"][1]["styleTexto"]        := ""
    oJson["linhas"][1]["tituloProgresso"]   := ""
    oJson["linhas"][1]["valorProgresso"]    := ""
    oJson["linhas"][1]["icone"]             := ""
    aAdd(oJson["linhas"],JsonObject():New())
    oJson["linhas"][2]["texto"]             := "Horas Improdutivas"
    oJson["linhas"][2]["tipo"]              := "texto"
    oJson["linhas"][2]["classeTexto"]       := "po-font-text-large po-text-center po-sm-6 po-pt-2"
    oJson["linhas"][2]["styleTexto"]        := ""
    oJson["linhas"][2]["tituloProgresso"]   := ""
    oJson["linhas"][2]["valorProgresso"]    := ""
    oJson["linhas"][2]["icone"]             := ""
    aAdd(oJson["linhas"],JsonObject():New())
    oJson["linhas"][3]["texto"]             := oJsTmpApt["P"]
    oJson["linhas"][3]["tipo"]              := "texto"
    oJson["linhas"][3]["classeTexto"]       := "po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2"
    oJson["linhas"][3]["styleTexto"]        := oJsCxVerde:ToJson()
    oJson["linhas"][3]["tituloProgresso"]   := ""
    oJson["linhas"][3]["valorProgresso"]    := ""
    oJson["linhas"][3]["icone"]             := ""
    oJson["linhas"][3]["tipoDetalhe"]       := "detalhe"
    oJson["linhas"][3]["parametrosDetalhe"] := "SH6.H6_TIPO = 'P'"
    aAdd(oJson["linhas"],JsonObject():New())
    oJson["linhas"][4]["texto"]             := oJsTmpApt["I"]
    oJson["linhas"][4]["tipo"]              := "texto"
    oJson["linhas"][4]["classeTexto"]       := "po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2"
    oJson["linhas"][4]["styleTexto"]        := oJsCxVmlha:ToJson()
    oJson["linhas"][4]["tituloProgresso"]   := ""
    oJson["linhas"][4]["valorProgresso"]    := ""
    oJson["linhas"][4]["icone"]             := ""
    oJson["linhas"][4]["tipoDetalhe"]       := "detalhe"
    oJson["linhas"][4]["parametrosDetalhe"] := "SH6.H6_TIPO = 'I'"
    aAdd(oJson["linhas"],JsonObject():New())
    oJson["linhas"][5]["texto"]             := "Calendário do recurso possui <b>"+cHrDispRec+" horas</b>."
    oJson["linhas"][5]["tipo"]              := "texto"
    oJson["linhas"][5]["classeTexto"]       := "po-font-text-large po-text-left po-sm-12 po-pt-1 po-pl-0"
    oJson["linhas"][5]["styleTexto"]        := ""
    oJson["linhas"][5]["tituloProgresso"]   := ""
    oJson["linhas"][5]["valorProgresso"]    := ""
    oJson["linhas"][5]["icone"]             := ""
    If oJsUltApt:HasProperty("ORDEM_PRODUCAO")
        aAdd(oJson["linhas"],JsonObject():New())
        oJson["linhas"][6]["texto"]             := "Última Produção:"
        oJson["linhas"][6]["tipo"]              := "texto"
        oJson["linhas"][6]["classeTexto"]       := "po-font-text-large-bold po-text-left po-sm-12 po-pt-1 po-pl-0"
        oJson["linhas"][6]["styleTexto"]        := ""
        oJson["linhas"][6]["tituloProgresso"]   := ""
        oJson["linhas"][6]["valorProgresso"]    := ""
        oJson["linhas"][6]["icone"]             := ""
        aAdd(oJson["linhas"],JsonObject():New())
        oJson["linhas"][7]["texto"]             := "Ordem "+oJsUltApt["ORDEM_PRODUCAO"]+"</br>Produto "+oJsUltApt["CODIGO_PRODUTO"]+" - "+oJsUltApt["DESCRICAO_PRODUTO"]+"</br>Operação "+oJsUltApt["CODIGO_OPERACAO"]+" - "+oJsUltApt["DESCRICAO_OPERACAO"]+""
        oJson["linhas"][7]["tipo"]              := "texto"
        oJson["linhas"][7]["classeTexto"]       := "po-font-text-small po-text-left po-sm-12 po-pl-0"
        oJson["linhas"][7]["styleTexto"]        := ""
        oJson["linhas"][7]["tituloProgresso"]   := ""
        oJson["linhas"][7]["valorProgresso"]    := ""
        oJson["linhas"][7]["icone"]             := ""
    EndIf
    FreeObj(oJsCxVerde)
    FreeObj(oJsCxVmlha)
Return oJson

/*/{Protheus.doc} ultApontam
Busca o ultimo apontamento de produção pro recurso
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	cWhere    , caracter   , Condição para a consulta sql
@param	cFilialFlt, caracter   , Filial informada no filtro
@return oJsUltApon, objeto json, Objeto json com os dados do último apontamento de produção do recurso
/*/
Static Function ultApontam(cWhere,cFilialFlt)
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local cRoteiro   := ""
    Local oJsUltApon := JsonObject():New()

    cQuery := "SELECT "
    cQuery += " SH6.H6_OP ORDEM_PRODUCAO,SH6.H6_PRODUTO CODIGO_PRODUTO,SB1.B1_DESC DESCRICAO_PRODUTO,"
    cQuery += " SH6.H6_OPERAC CODIGO_OPERACAO,SH6.H6_TIPO TIPO_APONTAMENTO, "
    cQuery += " SB1.B1_OPERPAD ROTEIRO_PADRAO, SC2.C2_ROTEIRO ROTEIRO_ORDEM "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",cFilialFlt)+"' AND SB1.B1_COD = SH6.H6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",cFilialFlt)+"' AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD = SH6.H6_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += cWhere
    cQuery += " AND SH6.H6_TIPO = 'P' "
    cQuery += " ORDER BY SH6.H6_IDENT DESC"

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If (cAlias)->(!Eof())
        cRoteiro := IIF(!Empty((cAlias)->ROTEIRO_ORDEM),(cAlias)->ROTEIRO_ORDEM,IIF(!Empty((cAlias)->ROTEIRO_PADRAO),(cAlias)->ROTEIRO_PADRAO,"01"))
        oJsUltApon["ORDEM_PRODUCAO"]     := AllTrim((cAlias)->ORDEM_PRODUCAO)
        oJsUltApon["CODIGO_PRODUTO"]     := AllTrim((cAlias)->CODIGO_PRODUTO)
        oJsUltApon["DESCRICAO_PRODUTO"]  := AllTrim((cAlias)->DESCRICAO_PRODUTO)
        oJsUltApon["CODIGO_OPERACAO"]    := AllTrim((cAlias)->CODIGO_OPERACAO)
        oJsUltApon["DESCRICAO_OPERACAO"] := AllTrim(Posicione("SG2",1,xFilial("SG2",cFilialFlt)+(cAlias)->CODIGO_PRODUTO+cRoteiro+(cAlias)->CODIGO_OPERACAO,"G2_DESCRI"))
        oJsUltApon["TIPO_APONTAMENTO"]   := AllTrim((cAlias)->TIPO_APONTAMENTO)
        (cAlias)->(dbSkip())
    EndIf
    (cAlias)->(dbCloseArea())    

Return oJsUltApon

/*/{Protheus.doc} calcTmpApt
Calcula a quantidade de horas de apontamento produtivo e improdutivo no período
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  cWhere    , caracter   , Condição sql com base nos filtros do Monitor
@return oJsonTempo, objeto json, Objeto json com a quantidade de horas produtivas e improdutivas
/*/
Static Function calcTmpApt(oFiltros,dDataIni,dDataFin)
    Local oJsonCalc  := Nil
    Local oJsonTempo := JsonObject():New()

    oJsonCalc := PCPMonitorUtils():CalculaTempoApontamentoOperacao(oFiltros["01_H6_FILIAL"],"'"+oFiltros["02_H6_RECURSO"]+"'",{dDataIni,dDataFin},.F.,,oFiltros["03_FILTRODATA"])
    oJsonTempo["P"] := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonCalc[dToC(dDatabase)]["P"],1)
    oJsonTempo["I"] := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonCalc[dToC(dDatabase)]["I"],1)
    FreeObj(oJsonCalc)
Return oJsonTempo

/*/{Protheus.doc} filtroQuery
Atribui o filtro padrão para ser usado nos métodos da busca de dados e detalhes
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	oFiltro , objeto json, Objeto json com as propriedades que devem ser consideradas no filtro
@param	cDataIni, caracter   , Data inicial calculada para o filtro
@param	cDataFin, caracter   , Data final com base na database do sistema
@return cWhere  , caracter   , Condição sql para a query
/*/
Static Function filtroQuery(oFiltro,cDataIni,cDataFin)
    Local cWhere   := "WHERE SH6.D_E_L_E_T_ = ' ' "

    cWhere += " AND SH6.H6_FILIAL = '" + xFilial("SH6",oFiltro["01_H6_FILIAL"]) + "' "
    cWhere += " AND SH6.H6_RECURSO = '" + AllTrim(oFiltro["02_H6_RECURSO"]) + "' "
    cWhere += " AND (SH6."+AllTrim(oFiltro["03_FILTRODATA"])+" >= "+cDataIni+" AND SH6."+AllTrim(oFiltro["03_FILTRODATA"])+" <= "+cDataFin+") "
Return cWhere

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@return Nil
/*/
Method BuscaDetalhes(oFiltro,nPagina) Class StatusRecurso
    Local cAlias     := GetNextAlias()
    Local cFilialFlt := ""
    Local cParamDet  := ""
    Local cRecurFlt  := ""
    Local cQuery     := ""
    Local cRoteiro   := ""
    Local dDataFin   := dDatabase
    Local dDataIni   := dDatabase
    Local lExpResult := .F.
    Local nPos       := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    oFiltro["01_H6_FILIAL"] := PadR(oFiltro["01_H6_FILIAL"], FWSizeFilial())
    cFilialFlt           := oFiltro["01_H6_FILIAL"]
    cParamDet            := IIF(oFiltro:HasProperty("PARAMETROSDETALHE"),oFiltro["PARAMETROSDETALHE"],"")
    cRecurFlt            := oFiltro["02_H6_RECURSO"]
    dDataFin             := dDatabase
    dDataIni             := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltro["04_TIPOPERIODO"]),dDataFin,cValToChar(oFiltro["05_PERIODO"]))

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cQuery := "SELECT "
    cQuery += "  SH6.H6_FILIAL,SH6.H6_OP,SH6.H6_PRODUTO,SH6.H6_OPERAC,SH6.H6_RECURSO,SH6.H6_DTAPONT, "
    cQuery += "  SH6.H6_DATAINI,SH6.H6_HORAINI,SH6.H6_DATAFIN,SH6.H6_HORAFIN,SH6.H6_TEMPO,SH6.H6_QTDPROD, "
    cQuery += "  SH6.H6_QTDPERD,SH6.H6_TIPO,SH6.H6_TIPOTEM, "
    cQuery += "  SB1.B1_DESC, SB1.B1_OPERPAD, SC2.C2_ROTEIRO "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",cFilialFlt)+"' AND SB1.B1_COD = SH6.H6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",cFilialFlt)+"' AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD = SH6.H6_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += filtroQuery(oFiltro,dToS(dDataIni),dToS(dDataFin))
    If !Empty(cParamDet)
        cQuery += " AND " + cParamDet
    EndIf
    cQuery += " ORDER BY SH6."+AllTrim(oFiltro["03_FILTRODATA"])+",SH6.H6_TIPO DESC"
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    oDados["items"]   := {}
    oDados["columns"] := bscColunas(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]    := {}
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][1]["icone"]      := "po-icon-calendar"
    oDados["tags"][1]["colorTexto"] := ""
    oDados["tags"][1]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][2]["icone"]      := "po-icon-manufacture"
    oDados["tags"][2]["colorTexto"] := ""
    oDados["tags"][2]["texto"]      := cRecurFlt
    If !Empty(cParamDet)
        aAdd(oDados["tags"],JsonObject():New())
        oDados["tags"][3]["icone"]      := "po-icon-filter"
        oDados["tags"][3]["colorTexto"] := ""
        oDados["tags"][3]["texto"]      := "Horas " + IIF("'P'" $ cParamDet,"Produtivas","Improdutivas")
    EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        cRoteiro := IIF(!Empty((cAlias)->C2_ROTEIRO),(cAlias)->C2_ROTEIRO,IIF(!Empty((cAlias)->B1_OPERPAD),(cAlias)->B1_OPERPAD,"01"))
        oDados["items"][nPos]["H6_FILIAL"]  := (cAlias)->H6_FILIAL
        oDados["items"][nPos]["H6_OP"]      := (cAlias)->H6_OP
        oDados["items"][nPos]["H6_PRODUTO"] := (cAlias)->H6_PRODUTO
        oDados["items"][nPos]["B1_DESC"]    := (cAlias)->B1_DESC
        oDados["items"][nPos]["H6_OPERAC"]  := (cAlias)->H6_OPERAC
        oDados["items"][nPos]["G2_DESCRI"]  := AllTrim(Posicione("SG2",1,xFilial("SG2",cFilialFlt)+(cAlias)->H6_PRODUTO+cRoteiro+(cAlias)->H6_OPERAC,"G2_DESCRI"))
        oDados["items"][nPos]["H6_RECURSO"] := (cAlias)->H6_RECURSO
        oDados["items"][nPos]["H6_DTAPONT"] := PCPMonitorUtils():FormataData((cAlias)->H6_DTAPONT,4)
        oDados["items"][nPos]["H6_DATAINI"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAINI,4)
        oDados["items"][nPos]["H6_HORAINI"] := (cAlias)->H6_HORAINI
        oDados["items"][nPos]["H6_DATAFIN"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAFIN,4)
        oDados["items"][nPos]["H6_HORAFIN"] := (cAlias)->H6_HORAFIN
        oDados["items"][nPos]["H6_TEMPO"]   := IIF((cAlias)->H6_TIPOTEM == 2,A680ConvHora((cAlias)->H6_TEMPO,"C","N"),(cAlias)->H6_TEMPO)
        oDados["items"][nPos]["H6_QTDPROD"] := (cAlias)->H6_QTDPROD
        oDados["items"][nPos]["H6_QTDPERD"] := (cAlias)->H6_QTDPERD
        oDados["items"][nPos]["H6_TIPO"]    := (cAlias)->H6_TIPO
        (cAlias)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())    
Return oDados:ToJson()

/*/{Protheus.doc} bscColunas
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type Static Function
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Static Function bscColunas(lExpResult)
    Local aColunas := {}
    Local nPos     := 0

    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_FILIAL"
    aColunas[nPos]["label"]    := "Filial"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_TIPO"
    aColunas[nPos]["label"]    := "Tp Apon"
    aColunas[nPos]["type"]     := "cellTemplate"
    aColunas[nPos]["width"]    := "5%"
    aColunas[nPos]["labels"]   := {}
        aAdd(aColunas[nPos]["labels"], JsonObject():New())
        aColunas[nPos]["labels"][1]["value"] := "I"
        aColunas[nPos]["labels"][1]["color"] := COR_VERMELHO
        aColunas[nPos]["labels"][1]["label"] := "Improdutivo"
        aColunas[nPos]["labels"][1]["textColor"] := COR_BRANCO
        aAdd(aColunas[nPos]["labels"], JsonObject():New())
        aColunas[nPos]["labels"][2]["value"] := "P"
        aColunas[nPos]["labels"][2]["color"] := COR_VERDE
        aColunas[nPos]["labels"][2]["label"] := "Produtivo"
        aColunas[nPos]["labels"][2]["textColor"] := COR_BRANCO
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_RECURSO"
    aColunas[nPos]["label"]    := "Recurso"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_OP"
    aColunas[nPos]["label"]    := "OP"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["width"]    := "10%"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_PRODUTO"
    aColunas[nPos]["label"]    := "Produto"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["width"]    := "15%"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "B1_DESC"
    aColunas[nPos]["label"]    := "Desc Produto"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["width"]    := "20%"
    aColunas[nPos]["visible"]  := .T.    
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_OPERAC"
    aColunas[nPos]["label"]    := "Operação"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["width"]    := "5%"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "G2_DESCRI"
    aColunas[nPos]["label"]    := "Desc Oper"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["width"]    := "15%"
    aColunas[nPos]["visible"]  := .T.    
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_DTAPONT"
    aColunas[nPos]["label"]    := "Dt Apont"
    aColunas[nPos]["type"]     := "date"
    aColunas[nPos]["width"]    := "5%"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_DATAINI"
    aColunas[nPos]["label"]    := "Dt Ini"
    aColunas[nPos]["type"]     := "date"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_HORAINI"
    aColunas[nPos]["label"]    := "Hora Ini"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_DATAFIN"
    aColunas[nPos]["label"]    := "Dt Fin"
    aColunas[nPos]["type"]     := "date"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_HORAFIN"
    aColunas[nPos]["label"]    := "Hora Fin"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_TEMPO"
    aColunas[nPos]["label"]    := "Tempo"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["width"]    := "5%"    
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_QTDPROD"
    aColunas[nPos]["label"]    := "Qtd Prod"
    aColunas[nPos]["type"]     := "number"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_QTDPERD"
    aColunas[nPos]["label"]    := "Qtd Perda"
    aColunas[nPos]["type"]     := "number"
    aColunas[nPos]["visible"]  := lExpResult
Return aColunas

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class StatusRecurso
    Local lRet       := .T.
    Local oCarga     := PCPMonitorCarga():New()
    Local oExemplo   := JsonObject():New()
    Local oJsCxVerde := JsonObject():New()
    Local oJsCxVmlha := JsonObject():New()
    Local oPrmAdc    := JsonObject():New()
 
    If !PCPMonitorCarga():monitorAtualizado("StatusRecurso")
        oJsCxVerde["background-color"] := COR_VERDE
        oJsCxVerde["border-radius"]    := "3px"
        oJsCxVerde["border-color"]     := COR_VERDE
        oJsCxVerde["border"]           := "5px"
        oJsCxVerde["cursor"]           := "pointer"
        oJsCxVmlha["background-color"] := COR_VERMELHO
        oJsCxVmlha["border-radius"]    := "3px"
        oJsCxVmlha["border-color"]     := COR_VERMELHO
        oJsCxVmlha["border"]           := "5px"
        oJsCxVmlha["cursor"]           := "pointer"
        oExemplo["corFundo"]  := "white"
        oExemplo["corTitulo"] := ""
        oExemplo["tags"]   := {}
        aAdd(oExemplo["tags"],JsonObject():New())
        oExemplo["tags"][1]["icone"]      := "po-icon-calendar"
        oExemplo["tags"][1]["colorTexto"] := ""
        oExemplo["tags"][1]["texto"]      := "01/01/23 - 15/01/23"
        aAdd(oExemplo["tags"],JsonObject():New())
        oExemplo["tags"][2]["icone"]      := "po-icon-manufacture"
        oExemplo["tags"][2]["colorTexto"] := ""
        oExemplo["tags"][2]["texto"]      := "GUIL01"
        oExemplo["linhas"] := {}
        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][1]["texto"]             := "Horas Produtivas"
        oExemplo["linhas"][1]["tipo"]              := "texto"
        oExemplo["linhas"][1]["classeTexto"]       := "po-font-text-large po-text-center po-sm-6 po-pt-2"
        oExemplo["linhas"][1]["styleTexto"]        := ""
        oExemplo["linhas"][1]["tituloProgresso"]   := ""
        oExemplo["linhas"][1]["valorProgresso"]    := ""
        oExemplo["linhas"][1]["icone"]             := ""
        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][2]["texto"]             := "Horas Improdutivas"
        oExemplo["linhas"][2]["tipo"]              := "texto"
        oExemplo["linhas"][2]["classeTexto"]       := "po-font-text-large po-text-center po-sm-6 po-pt-2"
        oExemplo["linhas"][2]["styleTexto"]        := ""
        oExemplo["linhas"][2]["tituloProgresso"]   := ""
        oExemplo["linhas"][2]["valorProgresso"]    := ""
        oExemplo["linhas"][2]["icone"]             := ""
        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][3]["texto"]             := "5:30"
        oExemplo["linhas"][3]["tipo"]              := "texto"
        oExemplo["linhas"][3]["classeTexto"]       := "po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2"
        oExemplo["linhas"][3]["styleTexto"]        := oJsCxVerde:ToJson()
        oExemplo["linhas"][3]["tituloProgresso"]   := ""
        oExemplo["linhas"][3]["valorProgresso"]    := ""
        oExemplo["linhas"][3]["icone"]             := ""
        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][4]["texto"]             := "3:15"
        oExemplo["linhas"][4]["tipo"]              := "texto"
        oExemplo["linhas"][4]["classeTexto"]       := "po-font-title po-text-center bold-text po-sm-6 po-pt-2 po-pb-2"
        oExemplo["linhas"][4]["styleTexto"]        := oJsCxVmlha:ToJson()
        oExemplo["linhas"][4]["tituloProgresso"]   := ""
        oExemplo["linhas"][4]["valorProgresso"]    := ""
        oExemplo["linhas"][4]["icone"]             := ""
        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][5]["texto"]             := "Calendário do recurso possui <b>10:00 horas</b>."
        oExemplo["linhas"][5]["tipo"]              := "texto"
        oExemplo["linhas"][5]["classeTexto"]       := "po-font-text-large po-text-left po-sm-12 po-pt-1 po-pl-0"
        oExemplo["linhas"][5]["styleTexto"]        := ""
        oExemplo["linhas"][5]["tituloProgresso"]   := ""
        oExemplo["linhas"][5]["valorProgresso"]    := ""
        oExemplo["linhas"][5]["icone"]             := ""
        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][6]["texto"]             := "Última Produção:"
        oExemplo["linhas"][6]["tipo"]              := "texto"
        oExemplo["linhas"][6]["classeTexto"]       := "po-font-text-large-bold po-text-left po-sm-12 po-pt-1 po-pl-0"
        oExemplo["linhas"][6]["styleTexto"]        := ""
        oExemplo["linhas"][6]["tituloProgresso"]   := ""
        oExemplo["linhas"][6]["valorProgresso"]    := ""
        oExemplo["linhas"][6]["icone"]             := ""
        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][7]["texto"]             := "Ordem 10000101001</br>Produto CHAPAALUMINIO23 - Chapa de Alumínio 2x3</br>Operação 20 - Corte"
        oExemplo["linhas"][7]["tipo"]              := "texto"
        oExemplo["linhas"][7]["classeTexto"]       := "po-font-text-small po-text-left po-sm-12 po-pl-0"
        oExemplo["linhas"][7]["styleTexto"]        := ""
        oExemplo["linhas"][7]["tituloProgresso"]   := ""
        oExemplo["linhas"][7]["valorProgresso"]    := ""
        oExemplo["linhas"][7]["icone"]             := ""

        oPrmAdc["01_H6_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["01_H6_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_H6_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["01_H6_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_H6_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["01_H6_FILIAL"]["valorSelect"]                  := "Code"
        oPrmAdc["02_H6_RECURSO"]                                := JsonObject():New()
        oPrmAdc["02_H6_RECURSO"]["filtroServico"]               := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_H6_RECURSO"]["parametrosServico"]           := JsonObject():New()
        oPrmAdc["02_H6_RECURSO"]["parametrosServico"]["filial"] := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
        oPrmAdc["02_H6_RECURSO"]["parametrosServico"]["metodo"] := "PCPMonitorConsultas():BuscaRecursos"
        oPrmAdc["02_H6_RECURSO"]["selecaoMultipla"]             := .F.
        oPrmAdc["02_H6_RECURSO"]["colunas"]                     := {}
        aAdd(oPrmAdc["02_H6_RECURSO"]["colunas"], JsonObject():New())
            oPrmAdc["02_H6_RECURSO"]["colunas"][1]["property"]  := "Code"
            oPrmAdc["02_H6_RECURSO"]["colunas"][1]["label"]     := GetSx3Cache("H1_CODIGO","X3_TITULO")
        aAdd(oPrmAdc["02_H6_RECURSO"]["colunas"], JsonObject():New())
            oPrmAdc["02_H6_RECURSO"]["colunas"][2]["property"]  := "Description"
            oPrmAdc["02_H6_RECURSO"]["colunas"][2]["label"]     := GetSx3Cache("H1_DESCRI","X3_TITULO")
        oPrmAdc["02_H6_RECURSO"]["labelSelect"]                 := "Code"
        oPrmAdc["02_H6_RECURSO"]["valorSelect"]                 := "Code"
        oPrmAdc["03_FILTRODATA"]                                := JsonObject():New()
        oPrmAdc["03_FILTRODATA"]["opcoes"]                      := "Data Início:H6_DATAINI;Data Final:H6_DATAFIN;Data Apontamento:H6_DTAPONT"
        oPrmAdc["04_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["04_TIPOPERIODO"]["opcoes"]                     := "Dia Atual:D;Semana Atual:S;Quinzena Atual:Q;Mês Atual:M;Personalizado:X"

        oCarga:setaTitulo("Situação do Recurso")
        oCarga:setaObjetivo("Monitorar o uso do recurso na fábrica, mostrando sua capacidade produtiva no período, detalhes do último apontamento, total de apontamentos de produção e horas improdutivas, além da possibilidade de visualizar em detalhes os apontamentos.")
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusRecurso")
        oCarga:setaTiposPermitidos("info")
        oCarga:setaTiposGraficoPermitidos("")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonTexto(.F.,oExemplo)
        oCarga:setaPropriedade("01_H6_FILIAL","","Filial",7,GetSx3Cache("H6_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["01_H6_FILIAL"])
        oCarga:setaPropriedade("02_H6_RECURSO","","Recurso",8,GetSx3Cache("H6_RECURSO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["02_H6_RECURSO"])
        oCarga:setaPropriedade("03_FILTRODATA","H6_DATAINI","Data de referência",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["03_FILTRODATA"])
        oCarga:setaPropriedade("04_TIPOPERIODO","D","Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_TIPOPERIODO"])
        oCarga:setaPropriedade("05_PERIODO","10","Período personalizado (dias)",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FreeObj(oJsCxVerde)
    FreeObj(oJsCxVmlha)
    FreeObj(oExemplo)
    FreeObj(oPrmAdc)
Return lRet

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusRecurso
    Local aFiliais := FWLoadSM0()
    Local aRetorno := {.T.,""}
    Local nFilSeg  := 0

    If Empty(oFiltros["01_H6_FILIAL"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Filial deve ser preenchido."
    Else
        nFilSeg := aScan(aFiliais, {|x| x[1] == cEmpAnt .And. AllTrim(x[2]) == AllTrim(oFiltros["01_H6_FILIAL"]) } )
        If nFilSeg > 0
            If !aFiliais[nFilSeg][11]
                aRetorno[1] := .F.
                aRetorno[2] := "Usuário não tem permissão na filial "+oFiltros["01_H6_FILIAL"]+"."
            EndIf
        Else
            aRetorno[1] := .F.
            aRetorno[2] := "Preencha uma Filial válida para a consulta."
        EndIf
    EndIf
    If aRetorno[1] .And. Empty(oFiltros["02_H6_RECURSO"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Recurso deve ser preenchido."
    Else
        If aRetorno[1]
            SH1->(dbSetOrder(1))
			If !SH1->(dbSeek(xFilial("SH1",PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())) + PadR(oFiltros["02_H6_RECURSO"],GetSx3Cache("H6_RECURSO","X3_TAMANHO")), .F.))
                aRetorno[1] := .F.
                aRetorno[2] := "O Recurso não existe na Filial informada."
            EndIf
        EndIf
    EndIf
    If aRetorno[1] .And. oFiltros["04_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("05_PERIODO") .Or. oFiltros["05_PERIODO"] == Nil
            aRetorno[1] := .F.
            aRetorno[2] := "Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf
    FwFreeArray(aFiliais)
Return aRetorno

