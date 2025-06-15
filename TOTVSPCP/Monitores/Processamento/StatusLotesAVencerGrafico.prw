#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusLotesAVencerGrafico
Classe para prover os dados do Monitor de Status dos Lotes  a vencer ( gráfico )
@type Class
@author douglas.heydt
@since 09/05/2023
@version P12.1.2310
@return Nil
/*/
Class StatusLotesAVencerGrafico FROM LongNameClass
    Static Method CargaMonitor()
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
    Static Method BuscaDetalhes(oFiltros, nPagina)
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author douglas.heydt
@since 09/05/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class StatusLotesAVencerGrafico
    Local aCategorias := {}
    Local aDetalhes   := {}
    Local aTags       := {}
    Local lRet        := .T.
    Local oCarga      := PCPMonitorCarga():New()
    Local oSeries     := JsonObject():New()    
    Local oPrmAdc     := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusLotesAVencerGrafico")

        oSeries["Lotes"] := {{10, 20, 5}, COR_AZUL }

        aTags   := {}
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]      := "01/02/2023 - 28/03/2023"
        aTags[1]["colorTexto"] := ""
        aTags[1]["icone"]      := "po-icon-calendar"
        aAdd(aTags, JsonObject():New())
        aTags[2]["icone"]      := "po-icon-calculator"
        aTags[2]["texto"]      := PCPMonitorUtils():RetornaDescricaoTipoPeriodo("D")
        aTags[2]["colorTexto"] := ""
        aAdd(aTags, JsonObject():New())	
        aTags[3]["texto"]      := "TUBO_CANETA"
        aTags[3]["colorTexto"] := ""
        aTags[3]["icone"]      := "po-icon-bar-code"
        aAdd(aTags, JsonObject():New())
        aTags[4]["icone"]      := "po-icon-star-filled"
        aTags[4]["texto"]      := "3 Lotes"
        aTags[4]["colorTexto"] := ""
        aAdd(aTags, JsonObject():New())
        aTags[5]["icone"]      := "po-icon-star-filled"
        aTags[5]["texto"]      := "150 UN"
        aTags[5]["colorTexto"] := ""

        oCarga:setaTitulo("Acomp. Lotes A Vencer")
        oCarga:setaObjetivo("Apresentar um gráfico contendo o número de lotes ou a quantidade a vencer de um determinado produto, dentro de um número de períodos futuros configurado.")
        oCarga:setaAgrupador("Estoque")
        oCarga:setaFuncaoNegocio("StatusLotesAVencerGrafico")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("column;bar;line")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries,aTags,aDetalhes,{"20/02/23","13/03/23","25/03/23"},"line")

        oPrmAdc["01_B8_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["01_B8_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_B8_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["01_B8_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_B8_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["01_B8_FILIAL"]["valorSelect"]                  := "Code"
        oPrmAdc["02_B8_PRODUTO"]                                := JsonObject():New()
        oPrmAdc["02_B8_PRODUTO"]["filtroServico"]               := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_B8_PRODUTO"]["parametrosServico"]           := JsonObject():New()
        oPrmAdc["02_B8_PRODUTO"]["parametrosServico"]["filial"] := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
        oPrmAdc["02_B8_PRODUTO"]["parametrosServico"]["metodo"] := "PCPMonitorConsultas():BuscaProdutos"
        oPrmAdc["02_B8_PRODUTO"]["selecaoMultipla"]             := .F.
        oPrmAdc["02_B8_PRODUTO"]["colunas"]                     := {}
        aAdd(oPrmAdc["02_B8_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_B8_PRODUTO"]["colunas"][1]["property"]      := "Code"
            oPrmAdc["02_B8_PRODUTO"]["colunas"][1]["label"]         := GetSx3Cache("B1_COD","X3_TITULO")
        aAdd(oPrmAdc["02_B8_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_B8_PRODUTO"]["colunas"][2]["property"]      := "Description"
            oPrmAdc["02_B8_PRODUTO"]["colunas"][2]["label"]         := GetSx3Cache("B1_DESC","X3_TITULO")
        oPrmAdc["02_B8_PRODUTO"]["labelSelect"]                 := "Code"
        oPrmAdc["02_B8_PRODUTO"]["valorSelect"]                 := "Code"
        oPrmAdc["03_TIPOINFO"]                                  := JsonObject():New()
        oPrmAdc["03_TIPOINFO"]["opcoes"]                        := "Número de Lotes:L;Quantidade do Produto:Q"
        oPrmAdc["04_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["04_TIPOPERIODO"]["opcoes"]                     := "Diário:D;Semanal:S;Quinzenal:Q;Mensal:M"

        oCarga:setaPropriedade("01_B8_FILIAL","","Filial",7,GetSx3Cache("B8_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["01_B8_FILIAL"])
        oCarga:setaPropriedade("02_B8_PRODUTO","","Produto",8,GetSx3Cache("B8_PRODUTO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["02_B8_PRODUTO"])
        oCarga:setaPropriedade("03_TIPOINFO","L","Lotes/Quantidade",4,/*cTamanho*/,/*cDecimal*/,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["03_TIPOINFO"])
        oCarga:setaPropriedade("04_TIPOPERIODO","D","Tipo Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["04_TIPOPERIODO"])
        oCarga:setaPropriedade("05_PERIODO","10","Quantidade de períodos",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aTags)
    FwFreeArray(aCategorias)
    FwFreeArray(aDetalhes)
    FreeObj(oSeries)
    FreeObj(oPrmAdc)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)
@type Method
@author douglas.heydt
@since 09/05/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusLotesAVencerGrafico
    Local aSaldos    := {}
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
    Local aChaves    := {}
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cUnMed     := ""
    Local cQuery     := ""
    Local dDataAjust := Nil
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local nLtsTotal  := 0
    Local nQtPTotal  := 0
    Local nX         := 0
    Local oDados     := JsonObject():New()
    Local oJsonRet   := JsonObject():New()
    Local oStyle     := JsonObject():New()
    Local oPeriods   := JsonObject():New()
    
    oJsonRet["corTitulo"] := "white"
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["tags"]   := {}
    oJsonRet["series"] := {}
    oStyle["color"] := "white"

    oFiltros["01_B8_FILIAL"] := PadR(oFiltros["01_B8_FILIAL"], FWSizeFilial())
    cUnMed := Posicione("SB1",1,xFilial("SB1",oFiltros["01_B8_FILIAL"])+oFiltros["02_B8_PRODUTO"],"B1_UM")
    dDataIni := aPeriodos[1][1]
    dDataFin := aPeriodos[Len(aPeriodos)][2]
    cQuery := " SELECT "
    cQuery += "     SB8.B8_FILIAL, "
    cQuery += "     SB8.B8_PRODUTO, "
    cQuery += "     SB8.B8_DTVALID, "
    cQuery += "     SUM(SB8.B8_SALDO) QUANTIDADE_PRODUTO, "
    cQuery += "     COUNT(SB8.B8_LOTECTL) NUMERO_LOTES "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " WHERE SB8.B8_FILIAL  = '"+xFilial("SB8",oFiltros["01_B8_FILIAL"])+"' "
    cQuery += "   AND SB8.B8_PRODUTO = '"+oFiltros["02_B8_PRODUTO"]+"' "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+dToS(dDataIni)+"' AND '"+dToS(dDataFin)+"' "
    cQuery += "   AND SB8.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SB8.B8_FILIAL,SB8.B8_PRODUTO,SB8.B8_DTVALID "
    cQuery += " ORDER BY SB8.B8_FILIAL,SB8.B8_PRODUTO,SB8.B8_DTVALID "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
    While (cAliasQry)->(!Eof())
        dDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],sToD((cAliasQry)->B8_DTVALID)))
        nLtsTotal   += (cAliasQry)->NUMERO_LOTES
        nQtPTotal   += (cAliasQry)->QUANTIDADE_PRODUTO
        If oPeriods:HasProperty(dDataAjust) 
            oPeriods[dDataAjust] += IIF(oFiltros["03_TIPOINFO"] == "L",(cAliasQry)->NUMERO_LOTES,(cAliasQry)->QUANTIDADE_PRODUTO)
        Else
            oPeriods[dDataAjust] := IIF(oFiltros["03_TIPOINFO"] == "L",(cAliasQry)->NUMERO_LOTES,(cAliasQry)->QUANTIDADE_PRODUTO)
        EndIf
        (cAliasQry)->(dbSkip())
    End
    (cAliasQry)->(dbCloseArea())

    aChaves := oPeriods:GetNames()
    For nX := 1 To Len(aChaves)
        aAdd(aSaldos, oPeriods[aChaves[nX]])
    Next nX

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_AZUL
    oJsonRet["series"][1]["data"]    := aSaldos
    oJsonRet["series"][1]["label"]   := IIF(oFiltros["03_TIPOINFO"] == "L","Lotes",cUnMed)
    oJsonRet["categorias"] := aChaves

    oJsonRet["tags"]     := {}
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][1]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    oJsonRet["tags"][1]["colorTexto"] := ""
    oJsonRet["tags"][1]["icone"]      := "po-icon-calendar"
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][2]["icone"]      := "po-icon-calculator"
    oJsonRet["tags"][2]["texto"]      := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"])
    oJsonRet["tags"][2]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())	
    oJsonRet["tags"][3]["texto"]      := oFiltros["02_B8_PRODUTO"]
    oJsonRet["tags"][3]["colorTexto"] := ""
    oJsonRet["tags"][3]["icone"]      := "po-icon-bar-code"
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][4]["icone"]      := "po-icon-star-filled"
    oJsonRet["tags"][4]["texto"]      := cValToChar(nLtsTotal) + IIF(nLtsTotal > 1," Lotes"," Lote") 
    oJsonRet["tags"][4]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    oJsonRet["tags"][5]["icone"]      := "po-icon-star-filled"
    oJsonRet["tags"][5]["texto"]      := cValToChar(nQtPTotal) + " " + cUnMed 
    oJsonRet["tags"][5]["colorTexto"] := ""

    cJsonDados :=  oJsonRet:toJson()

    FwFreeArray(aChaves)
    FwFreeArray(aPeriodos)
    FwFreeArray(aSaldos)
    FreeObj(oDados)
    FreeObj(oJsonRet)
    FreeObj(oStyle)
Return cJsonDados

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@param	oFiltros  , objeto Json , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico    , Número da página desejada para busca
@return cJsonDados, caracter    , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
@return Nil
/*/
Method BuscaDetalhes(oFiltros,nPagina) Class StatusLotesAVencerGrafico
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosFuturo(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
    Local cAliasQry  := GetNextAlias()
    Local cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    Local cQuery     := ""
    Local dDataIni   := Nil
    Local dDataFin   := Nil
    Local lExpResult := .F.
    Local nPos       := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf

    oFiltros["01_B8_FILIAL"] := PadR(oFiltros["01_B8_FILIAL"], FWSizeFilial())
    If !Empty(cCategoria)
        dDataIni := cToD(cCategoria)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["04_TIPOPERIODO"],cToD(cCategoria))
    Else
        dDataIni := aPeriodos[1][1]
        dDataFin := aPeriodos[Len(aPeriodos)][2]
    EndIf

    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}

    cQuery += " SELECT "
    cQuery += "     SB8.B8_FILIAL, SB8.B8_QTDORI, SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_DTVALID, "
    cQuery += "     SB8.B8_SALDO, SB8.B8_LOTECTL, SB1.B1_DESC, SB8.B8_NUMLOTE, SB1.B1_UM "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_B8_FILIAL"])+"' AND SB1.B1_COD = SB8.B8_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8",oFiltros["01_B8_FILIAL"]) + "' "
    cQuery += "   AND SB8.B8_PRODUTO = '"+oFiltros["02_B8_PRODUTO"]+"'  "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+DTOS(dDataIni)+"' AND  '"+DTOS(dDataFin)+"' "
    cQuery += "   AND SB8.D_E_L_E_T_  = ' ' "
    cQuery += " ORDER BY SB8.B8_FILIAL,SB8.B8_DTVALID,SB8.B8_LOTECTL  "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf
    While (cAliasQry)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        oDados["items"][nPos]["B8_FILIAL"  ] := (cAliasQry)->B8_FILIAL
        oDados["items"][nPos]["B8_LOTECTL" ] := (cAliasQry)->B8_LOTECTL
        oDados["items"][nPos]["B8_NUMLOTE" ] := (cAliasQry)->B8_NUMLOTE
        oDados["items"][nPos]["B8_PRODUTO" ] := (cAliasQry)->B8_PRODUTO
        oDados["items"][nPos]["B1_DESC"    ] := (cAliasQry)->B1_DESC
        oDados["items"][nPos]["B8_QTDORI"  ] := (cAliasQry)->B8_QTDORI
        oDados["items"][nPos]["B1_UM"      ] := (cAliasQry)->B1_UM
        oDados["items"][nPos]["B8_LOCAL"   ] := (cAliasQry)->B8_LOCAL
        oDados["items"][nPos]["B8_DTVALID" ] := PCPMonitorUtils():FormataData((cAliasQry)->B8_DTVALID, 5)
        oDados["items"][nPos]["B8_SALDO"   ] := (cAliasQry)->B8_SALDO
        (cAliasQry)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAliasQry)->(!Eof())
    (cAliasQry)->(dbCloseArea())    

    aAdd(oDados["tags"],JsonObject():New())
    nPosTag++
    oDados["tags"][nPosTag]["icone"]      := "po-icon-calendar"
    oDados["tags"][nPosTag]["colorTexto"] := ""
    oDados["tags"][nPosTag]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    If Empty(cCategoria)
        aAdd(oDados["tags"], JsonObject():New())
        nPosTag++
        oDados["tags"][nPosTag]["icone"]      := "po-icon-calculator"
        oDados["tags"][nPosTag]["texto"]      := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"])
        oDados["tags"][nPosTag]["colorTexto"] := ""
    EndIf
    aAdd(oDados["tags"],JsonObject():New())
    nPosTag++
    oDados["tags"][nPosTag]["icone"]      := "po-icon-bar-code"
    oDados["tags"][nPosTag]["colorTexto"] := ""
    oDados["tags"][nPosTag]["texto"]      := oFiltros["02_B8_PRODUTO"]
Return oDados:ToJson()

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author douglas.heydt
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusLotesAVencerGrafico
    Local aFiliais  := FWLoadSM0()
    Local aRetorno  := {.T.,""}
    Local aSemaforo := {}
    Local nFilSeg   := 0

    If Empty(oFiltros["01_B8_FILIAL"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Filial deve ser preenchido."
    Else
        nFilSeg := aScan(aFiliais, {|x| x[1] == cEmpAnt .And. AllTrim(x[2]) == AllTrim(oFiltros["01_B8_FILIAL"]) } )
        If nFilSeg > 0
            If !aFiliais[nFilSeg][11]
                aRetorno[1] := .F.
                aRetorno[2] := "Usuário não tem permissão na filial "+oFiltros["01_B8_FILIAL"]+"."
            EndIf
        Else
            aRetorno[1] := .F.
            aRetorno[2] := "Preencha uma Filial válida para a consulta."
        EndIf
    EndIf

	If aRetorno[1] .And. Empty(oFiltros["02_B8_PRODUTO"])
        aRetorno[1] := .F.
        aRetorno[2] := "O produto deve ser informado."
    EndIf

    If aRetorno[1] .And. (!oFiltros:HasProperty("05_PERIODO") .Or. oFiltros["05_PERIODO"] == Nil .Or. Empty(oFiltros["05_PERIODO"]))
        aRetorno[1] := .F.
        aRetorno[2] := "Deve ser informada a quantidade de períodos."
    EndIf
    
    FwFreeArray(aFiliais)
    FwFreeArray(aSemaforo)

Return aRetorno

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Class
@author douglas.heydt
@since 13/04/2023
@version P12.1.2310
@param  lExpResult, logico, Define se exporta resultado mostrando as colunas não visíveis por padrão
@return aColumns  , array , Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult)
    Local aColumns := {}
    Local nPos     := 0

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B8_FILIAL"
    aColumns[nPos]["label"]    := "Filial"
    aColumns[nPos]["type"]     := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B8_LOTECTL"
    aColumns[nPos]["label"]    := "Lote"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B8_NUMLOTE"
    aColumns[nPos]["label"]    := "Sub-Lote"
    aColumns[nPos]["type"]     := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B8_PRODUTO"
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
    aColumns[nPos]["property"] := "B8_LOCAL"
    aColumns[nPos]["label"]    := "Armazém"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B8_DTVALID"
    aColumns[nPos]["label"]    := "Validade"
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B8_QTDORI"
    aColumns[nPos]["label"]    := "Quant. Orig."
    aColumns[nPos]["type"]     := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B8_SALDO"
    aColumns[nPos]["label"]    := "Saldo"
    aColumns[nPos]["type"]     := "string"  

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B1_UM"
    aColumns[nPos]["label"]    := "Un. Medida"
    aColumns[nPos]["type"]     := "string"
    aColumns[nPos]["visible"]  := lExpResult
Return aColumns
