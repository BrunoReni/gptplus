#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusProducaoProduto
Classe para prover os dados do Monitor de acompanhamento de produção do produto
@type Class
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@return Nil
/*/
Class StatusProducaoProduto FROM LongNameClass
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
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusProducaoProduto
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
    Local aProdData  := {}
    Local cCodProd   := ""
    Local cTpPerDesc := ""
    Local cUnMedProd := ""
    Local dDataIni   := aPeriodos[Len(aPeriodos)][1]
    Local dDataFin   := aPeriodos[1][2]
    Local nIndex     := 0
    Local nTotCateg  := 0
    Local nTotProd   := 0
    Local oJsonDados := Nil
    Local oJsonRet   := JsonObject():New()

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}
    oJsonRet["detalhes"]   := {}

    oFiltros["01_D3_FILIAL"] := PadR(oFiltros["01_D3_FILIAL"], FWSizeFilial())
    cCodProd   := PadR(oFiltros["02_D3_COD"],TamSX3("D3_COD")[1])
    cUnMedProd := Posicione("SB1",1,xFilial("SB1",oFiltros["01_D3_FILIAL"])+cCodProd,"B1_UM")
    oJsonDados := PCPMonitorUtils():RetornaQuantidadesProducaoProduto(oFiltros["01_D3_FILIAL"],cCodProd,dDataIni,dDataFin,oFiltros["03_TIPOPERIODO"])
    oJsonRet["categorias"] := oJsonDados["PERIODOS"]:GetNames()
    nTotCateg := Len(oJsonRet["categorias"])
    For nIndex := 1 To nTotCateg
        nTotProd += oJsonDados["PERIODOS"][oJsonRet["categorias"][nIndex]]
        aAdd(aProdData,oJsonDados["PERIODOS"][oJsonRet["categorias"][nIndex]])
    Next nIndex

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_AZUL
    oJsonRet["series"][1]["data"]    := aProdData
    oJsonRet["series"][1]["tooltip"] := ""
    oJsonRet["series"][1]["label"]   := cUnMedProd

    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"])
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][1]["icone"]      := "po-icon-calendar"
    oJsonRet["tags"][1]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    oJsonRet["tags"][1]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][2]["icone"]      := "po-icon-calculator"
    oJsonRet["tags"][2]["texto"]      := cTpPerDesc
    oJsonRet["tags"][2]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][3]["icone"]      := "po-icon-bar-code"
    oJsonRet["tags"][3]["texto"]      := AllTrim(cCodProd)
    oJsonRet["tags"][3]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][4]["icone"]      := "po-icon-star-filled"
    oJsonRet["tags"][4]["texto"]      := cValToChar(oJsonDados["TOTAL_PRODUCAO"]) + " " + cUnMedProd
    oJsonRet["tags"][4]["colorTexto"] := ""
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
Method BuscaDetalhes(oFiltros, nPagina) Class StatusProducaoProduto
    Local aPeriodos  := {}
    Local cAlias     := GetNextAlias()
    Local cCategoria := ""
    Local cCodProd   := ""
    Local cQuery     := ""
    Local cTpPerDesc := ""
    Local cUnMedProd := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local lExpResult := .F.
    Local oDados     := JsonObject():New()
    Local nPosCon    := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    If !Empty(cCategoria)
        dDataIni := cToD(cCategoria)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["03_TIPOPERIODO"],cToD(cCategoria))
    Else
        aPeriodos := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["03_TIPOPERIODO"],cValToChar(oFiltros["04_PERIODO"]))
        dDataIni := aPeriodos[Len(aPeriodos)][1]
        dDataFin := aPeriodos[1][2]
    EndIf
    oFiltros["01_D3_FILIAL"] := PadR(oFiltros["01_D3_FILIAL"], FWSizeFilial())
    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["03_TIPOPERIODO"])
    cCodProd   := PadR(oFiltros["02_D3_COD"],TamSX3("D3_COD")[1])
    cUnMedProd := Posicione("SB1",1,xFilial("SB1",oFiltros["01_D3_FILIAL"])+cCodProd,"B1_UM")
    cQuery := " SELECT SD3.D3_FILIAL,SD3.D3_COD,SB1.B1_DESC,SD3.D3_UM,SD3.D3_EMISSAO,SD3.D3_QUANT,SD3.D3_OP "
    cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
    cQuery += " LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_D3_FILIAL"])+"' AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial("SD3",oFiltros["01_D3_FILIAL"])+"' "
    cQuery += "   AND SD3.D3_COD = '"+cCodProd+"' "
    cQuery += "   AND (SD3.D3_EMISSAO >= '"+dToS(dDataIni)+"' AND SD3.D3_EMISSAO <= '"+dToS(dDataFin)+"') "
    cQuery += "   AND SD3.D3_CF IN ('PR0','PR1') "
    cQuery += "   AND SD3.D3_ESTORNO <> 'S' "
    cQuery += "   AND SD3.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_EMISSAO "
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
    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPosCon++
        oDados["items"][nPosCon]["D3_FILIAL"]  := (cAlias)->D3_FILIAL
        oDados["items"][nPosCon]["D3_COD"]     := (cAlias)->D3_COD
        oDados["items"][nPosCon]["B1_DESC"]    := (cAlias)->B1_DESC
        oDados["items"][nPosCon]["D3_UM"]      := (cAlias)->D3_UM
        oDados["items"][nPosCon]["D3_EMISSAO"] := PCPMonitorUtils():FormataData((cAlias)->D3_EMISSAO,4)
        oDados["items"][nPosCon]["D3_QUANT"]   := (cAlias)->D3_QUANT
        oDados["items"][nPosCon]["D3_OP"]      := (cAlias)->D3_OP
        (cAlias)->(dbSkip())
        If !lExpResult .And. nPosCon >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())

    aAdd(oDados["tags"], JsonObject():New())
    nPosTag++   
    oDados["tags"][nPosTag]["icone"]      := "po-icon-calendar"
    oDados["tags"][nPosTag]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    oDados["tags"][nPosTag]["colorTexto"] := ""
    If Empty(cCategoria)
        aAdd(oDados["tags"], JsonObject():New())
        nPosTag++
        oDados["tags"][nPosTag]["icone"]      := "po-icon-calculator"
        oDados["tags"][nPosTag]["texto"]      := cTpPerDesc
        oDados["tags"][nPosTag]["colorTexto"] := ""
    EndIf
    aAdd(oDados["tags"], JsonObject():New())
    nPosTag++
    oDados["tags"][nPosTag]["icone"]      := "po-icon-bar-code"
    oDados["tags"][nPosTag]["texto"]      := AllTrim(cCodProd)
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
Method CargaMonitor() Class StatusProducaoProduto
    Local aCategr   := {}
    Local aDetalhes := {}
    Local aTags     := {}
    Local lRet      := .T.
    Local oCarga    := PCPMonitorCarga():New()
    Local oPrmAdc   := JsonObject():New()
    Local oSeries   := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusProducaoProduto")
        oSeries["UN"] := {{5,10,12,8,10,9}, COR_AZUL }
        aCategr := {"16/04/23","23/04/23","30/04/23","07/05/23","14/05/23","21/05/23"}

        aTags   := {}
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]     := "16/04/2023 - 28/05/2023"
        aTags[1]["colorTexto"]:= ""
        aTags[1]["icone"]     := "po-icon-calendar"
        aAdd(aTags, JsonObject():New())
        aTags[2]["texto"]     := "Semanal"
        aTags[2]["colorTexto"]:= ""
        aTags[2]["icone"]     := "po-icon-calculator"
        aAdd(aTags, JsonObject():New())
        aTags[3]["texto"]     := "CANETA"
        aTags[3]["colorTexto"]:= ""
        aTags[3]["icone"]     := "po-icon-bar-code"
        aAdd(aTags, JsonObject():New())
        aTags[4]["icone"]      := "po-icon-star-filled"
        aTags[4]["texto"]      := "54 UN"
        aTags[4]["colorTexto"] := ""

        oPrmAdc["01_D3_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["01_D3_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_D3_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["01_D3_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_D3_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["01_D3_FILIAL"]["valorSelect"]                  := "Code"
        oPrmAdc["02_D3_COD"]                                    := JsonObject():New()
        oPrmAdc["02_D3_COD"]["filtroServico"]                   := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_D3_COD"]["parametrosServico"]               := JsonObject():New()
        oPrmAdc["02_D3_COD"]["parametrosServico"]["filial"]     := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
        oPrmAdc["02_D3_COD"]["parametrosServico"]["metodo"]     := "PCPMonitorConsultas():BuscaProdutos"
        oPrmAdc["02_D3_COD"]["selecaoMultipla"]                 := .F.
        oPrmAdc["02_D3_COD"]["colunas"]                         := {}
        aAdd(oPrmAdc["02_D3_COD"]["colunas"], JsonObject():New())
            oPrmAdc["02_D3_COD"]["colunas"][1]["property"]      := "Code"
            oPrmAdc["02_D3_COD"]["colunas"][1]["label"]         := GetSx3Cache("B1_COD","X3_TITULO")
        aAdd(oPrmAdc["02_D3_COD"]["colunas"], JsonObject():New())
            oPrmAdc["02_D3_COD"]["colunas"][2]["property"]      := "Description"
            oPrmAdc["02_D3_COD"]["colunas"][2]["label"]         := GetSx3Cache("B1_DESC","X3_TITULO")
        oPrmAdc["02_D3_COD"]["labelSelect"]                     := "Code"
        oPrmAdc["02_D3_COD"]["valorSelect"]                     := "Code"
        oPrmAdc["03_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["03_TIPOPERIODO"]["opcoes"]                     := "Diário:D;Semanal:S;Quinzenal:Q;Mensal:M"

        oCarga:setaTitulo("Acomp. Produção Produto")
        oCarga:setaObjetivo("Acompanhar a quantidade produzida de um determinado produto em uma linha do tempo conforme o tipo de período parametrizado.")
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusProducaoProduto")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("line;column;bar")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes,aCategr,"line")
        oCarga:setaPropriedade("01_D3_FILIAL","","Filial",7,GetSx3Cache("D3_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["01_D3_FILIAL"])
        oCarga:setaPropriedade("02_D3_COD","","Produto",8,GetSx3Cache("D3_COD","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["02_D3_COD"])
        oCarga:setaPropriedade("03_TIPOPERIODO","D","Tipo Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["03_TIPOPERIODO"])
        oCarga:setaPropriedade("04_PERIODO","7","Quantidade Períodos",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aCategr)
    FwFreeArray(aDetalhes)
    FwFreeArray(aTags)
    FreeObj(oPrmAdc)
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
Method ValidaPropriedades(oFiltros) Class StatusProducaoProduto
    Local aFiliais := FWLoadSM0()
    Local aRetorno := {.T.,""}
    Local nFilSeg  := 0

    If Empty(oFiltros["01_D3_FILIAL"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Filial deve ser preenchido."
    Else
        nFilSeg := aScan(aFiliais, {|x| x[1] == cEmpAnt .And. AllTrim(x[2]) == AllTrim(oFiltros["01_D3_FILIAL"]) } )
        If nFilSeg > 0
            If !aFiliais[nFilSeg][11]
                aRetorno[1] := .F.
                aRetorno[2] := "Usuário não tem permissão na filial "+oFiltros["01_D3_FILIAL"]+"."
            EndIf
        Else
            aRetorno[1] := .F.
            aRetorno[2] := "Preencha uma Filial válida para a consulta."
        EndIf
    EndIf
    If aRetorno[1] .And. Empty(oFiltros["02_D3_COD"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Produto deve ser preenchido."
    Else
        If aRetorno[1]
            SB1->(dbSetOrder(1))
			If !SB1->(dbSeek(xFilial("SB1",PadR(oFiltros["01_D3_FILIAL"], FWSizeFilial())) + PadR(oFiltros["02_D3_COD"],GetSx3Cache("D3_COD","X3_TAMANHO")), .F.))
                aRetorno[1] := .F.
                aRetorno[2] := "O Produto não existe na Filial informada."
            EndIf
        EndIf
    EndIf
    If aRetorno[1] .And. Empty(oFiltros["04_PERIODO"])
        aRetorno[1] := .F.
        aRetorno[2] := "Deve ser informada a quantidade de períodos que será visualizada."
    EndIf
    FwFreeArray(aFiliais)
Return aRetorno

/*/{Protheus.doc} bscColunas
Cria array de objetos no formato poTableColumn com as colunas da table de detalhamento
@type Static Function
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return aColunas  , array , Array de objetos com as colunas da table po-ui
/*/
Static Function bscColunas(lExpResult)
    Local aColunas := {}
    Local nPos     := 0

    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "D3_FILIAL"
    aColunas[nPos]["label"]    := "Filial"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "D3_COD"
    aColunas[nPos]["label"]    := "Produto"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "B1_DESC"
    aColunas[nPos]["label"]    := "Desc. Prod."
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "D3_UM"
    aColunas[nPos]["label"]    := "UM"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := lExpResult
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "D3_EMISSAO"
    aColunas[nPos]["label"]    := "Dt. Emiss."
    aColunas[nPos]["type"]     := "date"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "D3_QUANT"
    aColunas[nPos]["label"]    := "Qt. Prod."
    aColunas[nPos]["type"]     := "number"
    aColunas[nPos]["visible"]  := .T.
    aAdd(aColunas, JsonObject():New())
    nPos++
    aColunas[nPos]["property"] := "D3_OP"
    aColunas[nPos]["label"]    := "OP"
    aColunas[nPos]["type"]     := "string"
    aColunas[nPos]["visible"]  := .T.
Return aColunas
