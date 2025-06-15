#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPMONITORDEF.ch"

/*/{Protheus.doc} PrevisaoEntregaOP
Classe para prover os dados do Monitor de Previsão de entrega de ordens de produção
@type Class
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@return Nil
/*/
Class PrevisaoEntregaOP FROM LongNameClass
    //Métodos
    Static Method CargaMonitor()
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
    Static Method BuscaDetalhes(oFiltros, nPagina)
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class PrevisaoEntregaOP
    Local aDetalhes   := {}
    Local aTags       := {}
    Local lRet        := .T.
    Local oCarga      := PCPMonitorCarga():New()
    Local oSeries     := JsonObject():New()    
    Local oPrmAdc    := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("PrevisaoEntregaOP")

        oSeries["Quantidade"] := {{10, 20, 5}, COR_AZUL }

        aTags := {}
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]     := "01/02/2023 - 28/03/2023"
        aTags[1]["colorTexto"]:= ""
        aTags[1]["icone"]     := "po-icon-calendar"

        oCarga:setaTitulo("Entregas previstas")
        oCarga:setaObjetivo("Monitorar o número de ordens de produção com data de entrega prevista para um período específico.")
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("PrevisaoEntregaOP")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("column;bar;line")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries,aTags,aDetalhes,{"20/02","13/03", "25/03"},"bar")

        oPrmAdc["01_C2_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["01_C2_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_C2_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["01_C2_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_C2_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["01_C2_FILIAL"]["valorSelect"]                  := "Code"

        oPrmAdc["02_C2_PRODUTO"]                                    := JsonObject():New()
        oPrmAdc["02_C2_PRODUTO"]["filtroServico"]                   := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]               := JsonObject():New()
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]["filial"]     := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]["metodo"]     := "PCPMonitorConsultas():BuscaProdutos"
        oPrmAdc["02_C2_PRODUTO"]["selecaoMultipla"]                 := .F.
        oPrmAdc["02_C2_PRODUTO"]["colunas"]                         := {}
        aAdd(oPrmAdc["02_C2_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_C2_PRODUTO"]["colunas"][1]["property"]      := "Code"
            oPrmAdc["02_C2_PRODUTO"]["colunas"][1]["label"]         := GetSx3Cache("B1_COD","X3_TITULO")
        aAdd(oPrmAdc["02_C2_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_C2_PRODUTO"]["colunas"][2]["property"]      := "Description"
            oPrmAdc["02_C2_PRODUTO"]["colunas"][2]["label"]         := GetSx3Cache("B1_DESC","X3_TITULO")
        oPrmAdc["02_C2_PRODUTO"]["labelSelect"]                     := "Description"
        oPrmAdc["02_C2_PRODUTO"]["valorSelect"]                     := "Code"
        oPrmAdc["02_C2_PRODUTO"]["fieldFormat"]                     := {"Code","Description"}

        oPrmAdc["03_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["03_TIPOPERIODO"]["opcoes"]                     := "Diário:D;Semanal:S;Quinzenal:Q;Mensal:M"

        oCarga:setaPropriedade("01_C2_FILIAL","","Filial",7,GetSx3Cache("C2_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["01_C2_FILIAL"])
        oCarga:setaPropriedade("02_C2_PRODUTO","","Produto",8,GetSx3Cache("C2_PRODUTO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["02_C2_PRODUTO"])
        oCarga:setaPropriedade("03_TIPOPERIODO","D","Tipo Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["03_TIPOPERIODO"])
        oCarga:setaPropriedade("04_PERIODO","10","Quantidade de períodos",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aTags)
    FREEOBJ(oSeries)

Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class PrevisaoEntregaOP
    Local aSaldos    := {}
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
    Local aChaves    := {}
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cQuery     := ""
    Local cProdDesc  := ""
    Local cUnMed     := ""
    Local dDataAjust := Nil
    Local nTotPer    := Len(aPeriodos)
    Local nSaldoPer  := 0
    Local nX         := 0
    Local oJsonRet   := JsonObject():New()
    Local oPeriods   := JsonObject():New()
    
    oJsonRet["corTitulo"] := "black"
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["tags"]   := {}
    oJsonRet["series"] := {}

    cQuery += " SELECT C2_DATPRF, SUM(C2_QUANT) AS QUANTIDADE, B1_UM, B1_DESC "
    cQuery += " FROM "+RetSqlName("SC2")+" SC2 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" ON B1_COD = C2_PRODUTO  "
    cQuery += " WHERE C2_FILIAL = '"+oFiltros["01_C2_FILIAL"]+"' "
    cQuery += " AND C2_PRODUTO = '"+oFiltros["02_C2_PRODUTO"]+"' "
    cQuery += " AND C2_DATPRF BETWEEN '"+dToS(aPeriodos[1][1])+"' AND '"+dToS(aPeriodos[nTotPer][2])+"' "
    cQuery += " AND SC2.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY C2_DATPRF, B1_UM, B1_DESC "
    cQuery += " ORDER BY C2_DATPRF, QUANTIDADE "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
   
    WHile (cAliasQry)->(!Eof())
        dDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["03_TIPOPERIODO"],sToD((cAliasQry)->C2_DATPRF)))
        nSaldoPer  += (cAliasQry)->QUANTIDADE
        cUnMed     := (cAliasQry)->B1_UM
        cProdDesc  := (cAliasQry)->B1_DESC
        If oPeriods:HasProperty(dDataAjust) 
            oPeriods[dDataAjust] += (cAliasQry)->QUANTIDADE
        Else
            oPeriods[dDataAjust] := (cAliasQry)->QUANTIDADE
        EndIf
        (cAliasQry)->(DBSKIP())
    End
    (cAliasQry)->(dbCloseArea())

    aChaves := oPeriods:GetNames()

    For nX := 1 To Len(aChaves)
        aAdd(aSaldos, oPeriods[aChaves[nX]])
    Next nX

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_AZUL
    oJsonRet["series"][1]["data"]    := aSaldos
    oJsonRet["series"][1]["label"]   := "Quantidade"
    oJsonRet["categorias"] := aChaves

    oJsonRet["tags"] := {}
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][1]["texto"]      := cValToChar(aPeriodos[1][1])+" - "+cValToChar(aPeriodos[nTotPer][2])
    oJsonRet["tags"][1]["colorTexto"] := ""
    oJsonRet["tags"][1]["icone"]      := "po-icon-calendar"

    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][2]["icone"]      := "po-icon-calculator"
    oJsonRet["tags"][2]["texto"]      := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"])
    oJsonRet["tags"][2]["colorTexto"] := ""

    aAdd(oJsonRet["tags"], JsonObject():New())	
    oJsonRet["tags"][3]["texto"]      := oFiltros["02_C2_PRODUTO"]
    oJsonRet["tags"][3]["colorTexto"] := ""
    oJsonRet["tags"][3]["icone"]      := "po-icon-bar-code"

    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][4]["icone"]      := "po-icon-star-filled"
    oJsonRet["tags"][4]["texto"]      := "Total: " + CVALTOCHAR( nSaldoPer ) + " " + cUnMed
    oJsonRet["tags"][4]["colorTexto"] := ""

    cJsonDados :=  oJsonRet:toJson()

    FreeObj(oJsonRet)
    
Return cJsonDados

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param	oFiltros  , objeto Json , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico    , Número da página desejada para busca
@return cJsonDados, caracter    , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
@return Nil
/*/
Method BuscaDetalhes(oFiltros,nPagina) Class PrevisaoEntregaOP
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
    Local cAliasQry  := GetNextAlias()
    Local cQuery     := ""
    Local dDataIni   := Nil
    Local dDataFin   := Nil
    Local lExpResult := .F.
    Local nPos       := 0
    Local nTotPer    := Len(aPeriodos)
    Local nStart     := 1
    Local nQuantTot  := 0
    Local nTamPagina := 20
    Local nX         := 1
    Local oDados     := JsonObject():New()
    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf

    If !Empty(oFiltros["CATEGORIA"])
        For nX := 1 To nTotPer
            If Dtoc(aPeriodos[nX][1]) == oFiltros["CATEGORIA"]
                 dDataIni := aPeriodos[nX][1]
                 dDataFin := aPeriodos[nX][2]
            EndiF
        Next nX
    Else
        dDataIni := aPeriodos[1][1]
        dDataFin := aPeriodos[nTotPer][2]
    EndIf

    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][1]["icone"]      := "po-icon-calendar"
    oDados["tags"][1]["colorTexto"] := ""
    oDados["tags"][1]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)

    cQuery += " SELECT C2_FILIAL, C2_OP, C2_PRODUTO, B1_DESC, C2_LOCAL, C2_DATPRI, C2_DATPRF, C2_QUANT, C2_QUJE, B1_UM, "
    cQuery += " ( SELECT SUM(C2_QUANT) AS QUANTIDADE   FROM "+RetSqlName("SC2")+" WHERE C2_FILIAL = '"+oFiltros["01_C2_FILIAL"]+"'  AND C2_PRODUTO = '"+oFiltros["02_C2_PRODUTO"]+"'   AND C2_DATPRF BETWEEN '"+dToS(dDataIni)+"' AND '"+dToS(dDataFin)+"'  AND D_E_L_E_T_ = ' ' )  AS TOTAL "
    cQuery += " FROM "+RetSqlName("SC2")+" SC2 LEFT JOIN "+RetSqlName("SB1")+" SB1 "
    cQuery += " ON C2_PRODUTO = B1_COD  "
    cQuery += " where C2_FILIAL = '"+oFiltros["01_C2_FILIAL"]+"' AND C2_PRODUTO = '"+oFiltros["02_C2_PRODUTO"]+"' "
    cQuery += " AND C2_DATPRF BETWEEN '"+dToS(dDataIni)+"' AND '"+dToS(dDataFin)+"' " 
    cQuery += " AND SC2.D_E_L_E_T_  = ' ' AND SB1.D_E_L_E_T_ = ' ' "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

    If (cAliasQry)->(!Eof())
        nQuantTot += (cAliasQry)->TOTAL
        cUnMed    := (cAliasQry)->B1_UM
    EndIF

    While (cAliasQry)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        oDados["items"][nPos]["C2_FILIAL"]  := (cAliasQry)->C2_FILIAL
        oDados["items"][nPos]["C2_OP"]      := (cAliasQry)->C2_OP
        oDados["items"][nPos]["C2_PRODUTO"] := (cAliasQry)->C2_PRODUTO
        oDados["items"][nPos]["B1_DESC"]    := (cAliasQry)->B1_DESC
        oDados["items"][nPos]["C2_LOCAL"]   := (cAliasQry)->C2_LOCAL
        oDados["items"][nPos]["C2_DATPRI"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRI, 5)
        oDados["items"][nPos]["C2_DATPRF"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRF, 5)
        oDados["items"][nPos]["C2_QUANT"]   := (cAliasQry)->C2_QUANT
        oDados["items"][nPos]["C2_QUJE"]    := (cAliasQry)->C2_QUJE
        (cAliasQry)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAliasQry)->(!Eof())
    (cAliasQry)->(dbCloseArea())    

    aAdd(oDados["tags"], JsonObject():New())
    oDados["tags"][2]["icone"]      := "po-icon-calculator"
    oDados["tags"][2]["texto"]      := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"])
    oDados["tags"][2]["colorTexto"] := ""

    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][3]["icone"]      := "po-icon-bar-code"
    oDados["tags"][3]["colorTexto"] := ""
    oDados["tags"][3]["texto"]      := "Produto: "+oFiltros["02_C2_PRODUTO"]

    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][4]["icone"]      := "po-icon-star-filled"
    oDados["tags"][4]["texto"]      := "Total: " + CVALTOCHAR( nQuantTot ) + " " + cUnMed
    oDados["tags"][4]["colorTexto"] := ""

Return oDados:ToJson()

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class PrevisaoEntregaOP
   Local aFiliais  := FWLoadSM0()
   Local aRetorno  := {.T.,""}
   Local nFilSeg   := 0

    If Empty(oFiltros["01_C2_FILIAL"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Filial deve ser preenchido."
    Else
        nFilSeg := aScan(aFiliais, {|x| x[1] == cEmpAnt .And. AllTrim(x[2]) == AllTrim(oFiltros["01_C2_FILIAL"]) } )
        If nFilSeg > 0
            If !aFiliais[nFilSeg][11]
                aRetorno[1] := .F.
                aRetorno[2] := "Usuário não tem permissão na filial "+oFiltros["01_C2_FILIAL"]+"."
            EndIf
        Else
            aRetorno[1] := .F.
            aRetorno[2] := "Preencha uma Filial válida para a consulta."
        EndIf
    EndIf

    If aRetorno[1] .And. Empty(oFiltros["02_C2_PRODUTO"])
        aRetorno[1] := .F.
        aRetorno[2] := "O produto deve ser informado."
    EndIf

    If !oFiltros:HasProperty("04_PERIODO") .Or. oFiltros["04_PERIODO"] == Nil .Or. Empty(oFiltros["04_PERIODO"])
     aRetorno[1] := .F.
     aRetorno[2] := "Deve ser informada a quantidade de períodos."
    EndIf

    FwFreeArray(aFiliais)

Return aRetorno


/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author douglas.heydt
@since 30/06/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult)
    Local aColumns := {}
    Local nPos     := 0

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_FILIAL"
    aColumns[nPos]["label"]    := "Filial"
    aColumns[nPos]["type"]     := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_OP"
    aColumns[nPos]["label"]    := "OP"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_PRODUTO"
    aColumns[nPos]["label"]    := "Produto"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B1_DESC"
    aColumns[nPos]["label"]    := "Desc. Produto"
    aColumns[nPos]["type"]     := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_LOCAL"
    aColumns[nPos]["label"]    := "Armazém"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_DATPRI"
    aColumns[nPos]["label"]    := "Previsão Início"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_DATPRF"
    aColumns[nPos]["label"]    := "Previsão Entrega"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_QUANT"
    aColumns[nPos]["label"]    := "Quantidade"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_QUJE"
    aColumns[nPos]["label"]    := "Quant Produzida"
    aColumns[nPos]["type"]     := "string"
Return aColumns
