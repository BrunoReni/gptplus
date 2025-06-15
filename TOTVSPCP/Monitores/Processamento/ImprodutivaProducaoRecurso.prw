#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} ImprodutivaProducaoRecurso
Classe para prover os dados do Monitor de acompanhamento do percentual de utilização do recurso com produção
@type Class
@author renan.roeder
@since 24/05/2023
@version P12.1.2310
@return Nil
/*/
Class ImprodutivaProducaoRecurso FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltros, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} BuscaDados
Realiza a busca dos dados para o Monitor
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@param	cTipo   , caracter   , Tipo Monitor chart/info
@param	cSubTipo, caracter   , Tipo do grafico pie/bar/column/line
@return cJson   , caracter   , string json com os dados para retorno
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class ImprodutivaProducaoRecurso
    Local aNiveis    := {}
    Local dDataFin   := Date()
    Local dDataIni   := Date()
    Local nGaugeVal  := 0
    Local nHrProd    := 0
    Local nHrParada  := 0
    Local nPosTag    := 0
    Local oJsonCalc  := Nil
    Local oJsonRet   := JsonObject():New()

    cCodRecur  := AllTrim(oFiltros["02_H6_RECURSO"])
    cDscRecur  := PCPMonitorUtils():RetornaDescricaoRecurso(oFiltros["01_H6_FILIAL"],cCodRecur)
    aNiveis    := StrTokArr(oFiltros["03_NIVEIS"],";")
    dDataFin   := dDatabase
    dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["05_TIPOPERIODO"]),dDataFin,cValToChar(oFiltros["06_PERIODO"]))
    oJsonCalc  := PCPMonitorUtils():CalculaTempoApontamentoOperacao(oFiltros["01_H6_FILIAL"],cCodRecur,{dDataIni,dDataFin},.F.,,oFiltros["04_FILTRODATA"])
    nHrProd    := oJsonCalc[dToC(Date())]["P"]
    nHrParada  := oJsonCalc[dToC(Date())]["I"]
    nGaugeVal  := Round((nHrParada / nHrProd) * 100,2)

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}
    oJsonRet["detalhes"]   := {}
    oJsonRet["gauge"]      := JsonObject():New()
    oJsonRet["gauge"]["type"]       := "arch"
    oJsonRet["gauge"]["value"]      := nGaugeVal
    oJsonRet["gauge"]["label"]      := "% Improdutiva"
    oJsonRet["gauge"]["append"]     := ""
    oJsonRet["gauge"]["thick"]      := 20
    oJsonRet["gauge"]["margin"]     := 15
    oJsonRet["gauge"]["valueStyle"] := JsonObject():New()
    oJsonRet["gauge"]["valueStyle"]["color"]       := IIF(nGaugeVal <= Val(aNiveis[1]),COR_VERDE_FORTE,IIF(nGaugeVal <= Val(aNiveis[2]),COR_AMARELO_QUEIMADO,COR_VERMELHO_FORTE))
    oJsonRet["gauge"]["valueStyle"]["font-weight"] := "bold"
    oJsonRet["gauge"]["labelStyle"] := JsonObject():New()
    oJsonRet["gauge"]["labelStyle"]["font-weight"] := "bold"
    oJsonRet["gauge"]["thresholds"] := JsonObject():New()
    oJsonRet["gauge"]["thresholds"]["0"]                     := JsonObject():New()
    oJsonRet["gauge"]["thresholds"]["0"]["color"]            := COR_VERDE_FORTE
    oJsonRet["gauge"]["thresholds"]["0"]["bgOpacity"]        := 0.2
    oJsonRet["gauge"]["thresholds"][aNiveis[1]]              := JsonObject():New()
    oJsonRet["gauge"]["thresholds"][aNiveis[1]]["color"]     := COR_AMARELO_QUEIMADO
    oJsonRet["gauge"]["thresholds"][aNiveis[1]]["bgOpacity"] := 0.2
    oJsonRet["gauge"]["thresholds"][aNiveis[2]]              := JsonObject():New()
    oJsonRet["gauge"]["thresholds"][aNiveis[2]]["color"]     := COR_VERMELHO_FORTE
    oJsonRet["gauge"]["thresholds"][aNiveis[2]]["bgOpacity"] := 0.2
    oJsonRet["gauge"]["markers"] := JsonObject():New()
    If Val(aNiveis[1]) > 0
        oJsonRet["gauge"]["markers"]["0"]   :=  JsonObject():New()
        oJsonRet["gauge"]["markers"]["0"]["color"]   := COR_PRETO
        oJsonRet["gauge"]["markers"]["0"]["size"]    := 6
        oJsonRet["gauge"]["markers"]["0"]["label"]   := "0"
        oJsonRet["gauge"]["markers"]["0"]["type"]    := "line"
    EndIf
    oJsonRet["gauge"]["markers"][aNiveis[1]]   :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][aNiveis[1]]["color"]   := COR_PRETO
    oJsonRet["gauge"]["markers"][aNiveis[1]]["size"]    := 6
    oJsonRet["gauge"]["markers"][aNiveis[1]]["label"]   := aNiveis[1]
    oJsonRet["gauge"]["markers"][aNiveis[1]]["type"]    := "line"
    oJsonRet["gauge"]["markers"][aNiveis[2]]   :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][aNiveis[2]]["color"]   := COR_PRETO
    oJsonRet["gauge"]["markers"][aNiveis[2]]["size"]    := 6
    oJsonRet["gauge"]["markers"][aNiveis[2]]["label"]   := aNiveis[2]
    oJsonRet["gauge"]["markers"][aNiveis[2]]["type"]    := "line"
    If Val(aNiveis[2]) < 100
        oJsonRet["gauge"]["markers"]["100"] :=  JsonObject():New()
        oJsonRet["gauge"]["markers"]["100"]["color"] := COR_PRETO
        oJsonRet["gauge"]["markers"]["100"]["size"]  := 6
        oJsonRet["gauge"]["markers"]["100"]["label"] := "100"
        oJsonRet["gauge"]["markers"]["100"]["type"]  := "line"
    EndIf
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++   
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-calendar"
    oJsonRet["tags"][nPosTag]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-manufacture"
    oJsonRet["tags"][nPosTag]["texto"]      := cCodRecur + " - " + cDscRecur
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-star"
    oJsonRet["tags"][nPosTag]["texto"]      := "Horas Impr.: "+cValToChar(nHrParada)+" horas"
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-star-filled"
    oJsonRet["tags"][nPosTag]["texto"]      := "Horas Prod.: "+cValToChar(nHrProd)+" horas"
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    FwFreeArray(aNiveis)
Return oJsonRet:ToJson()

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return cJson   , caracter   , string json com os dados para retorno
@return Nil
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class ImprodutivaProducaoRecurso
    Local aPeriodos  := {}
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local cTempo     := ""
    Local cTpPerDesc := ""
    Local lExpResult := .F.
    Local nPosCon    := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cCodRecur  := AllTrim(oFiltros["02_H6_RECURSO"])
    cDscRecur  := PCPMonitorUtils():RetornaDescricaoRecurso(oFiltros["01_H6_FILIAL"],cCodRecur)
    dDataFin   := dDatabase
    dDataIni   := PCPMonitorUtils():RetornaPeriodoInicial(AllTrim(oFiltros["05_TIPOPERIODO"]),dDataFin,cValToChar(oFiltros["06_PERIODO"]))
    oJsonCalc  := PCPMonitorUtils():CalculaTempoApontamentoOperacao(oFiltros["01_H6_FILIAL"],cCodRecur,{dDataIni,dDataFin},.F.,,oFiltros["04_FILTRODATA"])
    nHrProd    := oJsonCalc[dToC(Date())]["P"]
    nHrParada  := oJsonCalc[dToC(Date())]["I"]

    cQuery := " SELECT "
    cQuery += "  SH6.H6_FILIAL,SH6.H6_OP,SH6.H6_PRODUTO,SH6.H6_OPERAC,SH6.H6_RECURSO,SH6.H6_DTAPONT, "
    cQuery += "  SH6.H6_DATAINI,SH6.H6_HORAINI,SH6.H6_DATAFIN,SH6.H6_HORAFIN,SH6.H6_TEMPO,SH6.H6_QTDPROD, "
    cQuery += "  SH6.H6_QTDPERD,SH6.H6_TIPO,SH6.H6_TIPOTEM, "
    cQuery += "  SB1.B1_DESC, SB1.B1_OPERPAD, SC2.C2_ROTEIRO "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_H6_FILIAL"])+"' AND SB1.B1_COD = SH6.H6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2",oFiltros["01_H6_FILIAL"])+"' AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD = SH6.H6_OP AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SH6.D_E_L_E_T_ = ' ' "
    cQuery += "   AND SH6.H6_FILIAL = '" + xFilial("SH6",oFiltros["01_H6_FILIAL"]) + "' "
    cQuery += "   AND SH6.H6_RECURSO = '" + AllTrim(oFiltros["02_H6_RECURSO"]) + "' "
    cQuery += "   AND (SH6."+AllTrim(oFiltros["04_FILTRODATA"])+" >= "+DToS(dDataIni)+" AND SH6."+AllTrim(oFiltros["04_FILTRODATA"])+" <= "+DToS(dDataFin)+") "
    cQuery += " ORDER BY SH6.H6_FILIAL,SH6.H6_RECURSO,SH6."+AllTrim(oFiltros["04_FILTRODATA"])+" "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["05_TIPOPERIODO"])
    oDados["items"]   := {}
    oDados["columns"] := bscColunas(lExpResult,oFiltros["04_FILTRODATA"])
    oDados["canExportCSV"] := .T.
    oDados["tags"]    := {}

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPosCon++
        cRoteiro := IIF(!Empty((cAlias)->C2_ROTEIRO),(cAlias)->C2_ROTEIRO,IIF(!Empty((cAlias)->B1_OPERPAD),(cAlias)->B1_OPERPAD,"01"))
        cTempo := cValToChar(Val(StrTran(IIF((cAlias)->H6_TIPOTEM == 1,A680ConvHora((cAlias)->H6_TEMPO,"N","C"),(cAlias)->H6_TEMPO),":",".")))
        oDados["items"][nPosCon]["H6_FILIAL"]  := (cAlias)->H6_FILIAL
        oDados["items"][nPosCon]["H6_OP"]      := (cAlias)->H6_OP
        oDados["items"][nPosCon]["H6_PRODUTO"] := (cAlias)->H6_PRODUTO
        oDados["items"][nPosCon]["B1_DESC"]    := (cAlias)->B1_DESC
        oDados["items"][nPosCon]["H6_OPERAC"]  := (cAlias)->H6_OPERAC
        oDados["items"][nPosCon]["G2_DESCRI"]  := AllTrim(Posicione("SG2",1,xFilial("SG2",oFiltros["01_H6_FILIAL"])+(cAlias)->H6_PRODUTO+cRoteiro+(cAlias)->H6_OPERAC,"G2_DESCRI"))
        oDados["items"][nPosCon]["H6_RECURSO"] := (cAlias)->H6_RECURSO
        oDados["items"][nPosCon]["H1_DESCRI"]  := PCPMonitorUtils():RetornaDescricaoRecurso(oFiltros["01_H6_FILIAL"],(cAlias)->H6_RECURSO)
        oDados["items"][nPosCon]["H6_DTAPONT"] := PCPMonitorUtils():FormataData((cAlias)->H6_DTAPONT,4)
        oDados["items"][nPosCon]["H6_DATAINI"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAINI,4)
        oDados["items"][nPosCon]["H6_HORAINI"] := (cAlias)->H6_HORAINI
        oDados["items"][nPosCon]["H6_DATAFIN"] := PCPMonitorUtils():FormataData((cAlias)->H6_DATAFIN,4)
        oDados["items"][nPosCon]["H6_HORAFIN"] := (cAlias)->H6_HORAFIN
        oDados["items"][nPosCon]["H6_TEMPO"]   := cTempo
        oDados["items"][nPosCon]["H6_QTDPROD"] := (cAlias)->H6_QTDPROD
        oDados["items"][nPosCon]["H6_QTDPERD"] := (cAlias)->H6_QTDPERD
        oDados["items"][nPosCon]["H6_TIPO"]    := (cAlias)->H6_TIPO
        (cAlias)->(dbSkip())
        If !lExpResult .And. nPosCon >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())

    aAdd(oDados["tags"], JsonObject():New())
    nPosTag++   
    oDados["tags"][nPosTag]["icone"]        := "po-icon-calendar"
    oDados["tags"][nPosTag]["texto"]        := dToC(dDataIni) + " - " + dToC(dDataFin)
    oDados["tags"][nPosTag]["colorTexto"]   := ""
    aAdd(oDados["tags"], JsonObject():New())
    nPosTag++
    oDados["tags"][nPosTag]["icone"]        := "po-icon-manufacture"
    oDados["tags"][nPosTag]["texto"]        := cCodRecur + " - " + cDscRecur
    oDados["tags"][nPosTag]["colorTexto"]   := ""
    aAdd(oDados["tags"], JsonObject():New())
    nPosTag++
    oDados["tags"][nPosTag]["icone"]      := "po-icon-star"
    oDados["tags"][nPosTag]["texto"]      := "Horas Impr.: "+cValToChar(nHrParada)+" horas"
    oDados["tags"][nPosTag]["colorTexto"] := ""
    aAdd(oDados["tags"], JsonObject():New())
    nPosTag++
    oDados["tags"][nPosTag]["icone"]      := "po-icon-star-filled"
    oDados["tags"][nPosTag]["texto"]      := "Horas Prod.: "+cValToChar(nHrProd)+" horas"
    oDados["tags"][nPosTag]["colorTexto"] := ""
    FwFreeArray(aPeriodos)
Return oDados:ToJson()

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class ImprodutivaProducaoRecurso
    Local aCategr    := {}
    Local aDetalhes  := {}
    Local aTags      := {}
    Local lRet       := .T.
    Local oCarga     := PCPMonitorCarga():New()
    Local oPrmAdc    := JsonObject():New()
    Local oProdGauge := JsonObject():New()
    Local oSeries    := JsonObject():New()

    If !PCPMonitorCarga():monitorAtualizado("ImprodutivaProducaoRecurso")
        aTags   := {}
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]      := "01/05/2023 - 31/05/2023"
        aTags[1]["colorTexto"] := ""
        aTags[1]["icone"]      := "po-icon-calendar"
        aAdd(aTags, JsonObject():New())
        aTags[2]["texto"]      := "INJ001 - Injetora 001"
        aTags[2]["colorTexto"] := ""
        aTags[2]["icone"]      := "po-icon-manufacture"
        aAdd(aTags, JsonObject():New())
        aTags[3]["texto"]      := "Horas Impr.: 20 horas"
        aTags[3]["colorTexto"] := ""
        aTags[3]["icone"]      := "po-icon-star"
        aAdd(aTags, JsonObject():New())
        aTags[4]["texto"]      := "Horas Prod.: 200 horas"
        aTags[4]["colorTexto"] := ""
        aTags[4]["icone"]      := "po-icon-star-filled"

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
        oPrmAdc["02_H6_RECURSO"]["labelSelect"]                 := "Description"
        oPrmAdc["02_H6_RECURSO"]["valorSelect"]                 := "Code"
        oPrmAdc["02_H6_RECURSO"]["fieldFormat"]                 := {"Code","Description"}
        oPrmAdc["04_FILTRODATA"]                                := JsonObject():New()
        oPrmAdc["04_FILTRODATA"]["opcoes"]                      := "Data Início:H6_DATAINI;Data Final:H6_DATAFIN;Data Apontamento:H6_DTAPONT"
        oPrmAdc["05_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["05_TIPOPERIODO"]["opcoes"]                     := "Dia Atual:D;Semana Atual:S;Quinzena Atual:Q;Mês Atual:M;Personalizado:X"

        oProdGauge["type"]       := "arch"
        oProdGauge["value"]      := 15
        oProdGauge["label"]      := "% Improdutiva"
        oProdGauge["append"]     := ""
        oProdGauge["thick"]      := 20
        oProdGauge["margin"]     := 15
        oProdGauge["valueStyle"] := JsonObject():New()
        oProdGauge["valueStyle"]["color"]       := COR_AMARELO_QUEIMADO
        oProdGauge["valueStyle"]["font-weight"] := "bold"
        oProdGauge["labelStyle"] := JsonObject():New()
        oProdGauge["labelStyle"]["font-weight"] := "bold"
        oProdGauge["thresholds"] := JsonObject():New()
        oProdGauge["thresholds"]["0"]               := JsonObject():New()
        oProdGauge["thresholds"]["0"]["color"]      := COR_VERDE_FORTE
        oProdGauge["thresholds"]["0"]["bgOpacity"]  := 0.2
        oProdGauge["thresholds"]["10"]              := JsonObject():New()
        oProdGauge["thresholds"]["10"]["color"]     := COR_AMARELO_QUEIMADO
        oProdGauge["thresholds"]["10"]["bgOpacity"] := 0.2
        oProdGauge["thresholds"]["25"]              := JsonObject():New()
        oProdGauge["thresholds"]["25"]["color"]     := COR_VERMELHO_FORTE
        oProdGauge["thresholds"]["25"]["bgOpacity"] := 0.2
        oProdGauge["markers"] := JsonObject():New()
        oProdGauge["markers"]["0"] :=  JsonObject():New()
        oProdGauge["markers"]["0"]["color"] := COR_PRETO
        oProdGauge["markers"]["0"]["size"]  := 6
        oProdGauge["markers"]["0"]["label"] := "0"
        oProdGauge["markers"]["0"]["type"]  := "line"
        oProdGauge["markers"]["10"] :=  JsonObject():New()
        oProdGauge["markers"]["10"]["color"] := COR_PRETO
        oProdGauge["markers"]["10"]["size"]  := 6
        oProdGauge["markers"]["10"]["label"] := "10"
        oProdGauge["markers"]["10"]["type"]  := "line"
        oProdGauge["markers"]["25"] :=  JsonObject():New()
        oProdGauge["markers"]["25"]["color"] := COR_PRETO
        oProdGauge["markers"]["25"]["size"]  := 6
        oProdGauge["markers"]["25"]["label"] := "25"
        oProdGauge["markers"]["25"]["type"]  := "line"
        oProdGauge["markers"]["100"] :=  JsonObject():New()
        oProdGauge["markers"]["100"]["color"] := COR_PRETO
        oProdGauge["markers"]["100"]["size"]  := 6
        oProdGauge["markers"]["100"]["label"] := "100"
        oProdGauge["markers"]["100"]["type"]  := "line"

        oCarga:setaTitulo("Horas Improdutivas X Produção")
        oCarga:setaObjetivo("Acompanhar o percentual de horas improdutivas em relação às horas produtivas apontadas no recurso no período estabelecido.")
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("ImprodutivaProducaoRecurso")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("gauge")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes,aCategr,"gauge",oProdGauge)
        oCarga:setaPropriedade("01_H6_FILIAL","","Filial",7,GetSx3Cache("H6_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["01_H6_FILIAL"])
        oCarga:setaPropriedade("02_H6_RECURSO","","Recurso",8,GetSx3Cache("H6_RECURSO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["02_H6_RECURSO"])
        oCarga:setaPropriedade("03_NIVEIS","Atenção;Urgente","Níveis (% Improd. X Produção)",1,30,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        oCarga:setaPropriedade("04_FILTRODATA","H6_DATAINI","Data de referência",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_FILTRODATA"])
        oCarga:setaPropriedade("05_TIPOPERIODO","D","Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["05_TIPOPERIODO"])
        oCarga:setaPropriedade("06_PERIODO","10","Período personalizado (dias)",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aCategr)
    FwFreeArray(aDetalhes)
    FwFreeArray(aTags)
    FreeObj(oPrmAdc)
    FreeObj(oProdGauge)
    FreeObj(oSeries)
Return lRet

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class ImprodutivaProducaoRecurso
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
    If aRetorno[1] .And. oFiltros["05_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("06_PERIODO") .Or. oFiltros["06_PERIODO"] == Nil
            aRetorno[1] := .F.
            aRetorno[2] := "Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf
    FwFreeArray(aFiliais)
Return aRetorno

/*/{Protheus.doc} bscColunas
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type Static Function
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  lExpResult, logico  , Indica se trata todas as colunas como visible
@param  cDataRef  , caracter, Data usada como referência para a consulta
@return aColunas  , array   , Array de objetos com as colunas da table po-ui
/*/
Static Function bscColunas(lExpResult,cDataRef)
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
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H1_DESCRI"
    aColunas[nPos]["label"]    := "Desc Recurso"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_OP"
    aColunas[nPos]["label"]    := "OP"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_PRODUTO"
    aColunas[nPos]["label"]    := "Produto"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "B1_DESC"
    aColunas[nPos]["label"]    := "Desc Produto"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult    
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_OPERAC"
    aColunas[nPos]["label"]    := "Operação"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "G2_DESCRI"
    aColunas[nPos]["label"]    := "Desc Oper"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_TEMPO"
    aColunas[nPos]["label"]    := "Tempo"
    aColunas[nPos]["type"]     := "string"   
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_DTAPONT"
    aColunas[nPos]["label"]    := "Dt Apont"
    aColunas[nPos]["type"]     := "date"
    aColunas[nPos]["visible"]  := IIF(lExpResult .Or. cDataRef == aColunas[nPos]["property"],.T.,.F.)
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_DATAINI"
    aColunas[nPos]["label"]    := "Dt Ini"
    aColunas[nPos]["type"]     := "date"
    aColunas[nPos]["visible"]  := IIF(lExpResult .Or. cDataRef == aColunas[nPos]["property"],.T.,.F.)
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
    aColunas[nPos]["visible"]  := IIF(lExpResult .Or. cDataRef == aColunas[nPos]["property"],.T.,.F.)
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "H6_HORAFIN"
    aColunas[nPos]["label"]    := "Hora Fin"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
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
