#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusLotesAVencer
Classe para prover os dados do Monitor de Status dos Lotes  a vencer
@type Class
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@return Nil
/*/
Class StatusLotesAVencer FROM LongNameClass
	//Métodos
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltro,nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass


/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class StatusLotesAVencer
    Local lRet      := .T.
    Local oCarga    := PCPMonitorCarga():New()
    Local oExemplo  := JsonObject():New()
    Local oStyle    := JsonObject():New()
    Local oStyleQtd := JsonObject():New()
    Local oPrmAdc   := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusLotesAVencer")
        oExemplo["corFundo"]  := COR_VERDE_FORTE
        oExemplo["corTitulo"] := "white"
        oExemplo["tags"]      := {}
        oExemplo["linhas"]    := {}
        oStyle["color"] := "white"

        aAdd(oExemplo["tags"],JsonObject():New())
        oExemplo["tags"][1]["icone"]      := "po-icon-calendar"
        oExemplo["tags"][1]["colorTexto"] := ""
        oExemplo["tags"][1]["texto"]      := "01/01/23 - 15/01/23"
        aAdd(oExemplo["tags"],JsonObject():New())
        oExemplo["tags"][2]["icone"]      := "po-icon-bar-code"
        oExemplo["tags"][2]["colorTexto"] := ""
        oExemplo["tags"][2]["texto"]      := "GUIL01"
        
        aAdd(oExemplo["linhas"],JsonObject():New())
        oStyleQtd["font-weight"] := "bold"
        oStyleQtd["font-size"]   := "120px"
        oStyleQtd["line-height"] := "130px"
        oStyleQtd["text-align"]  := "center"
        oStyleQtd["color"]       := oStyle["color"]
        oExemplo["linhas"][1]["texto"]           := "15"
        oExemplo["linhas"][1]["tipo"]            := "texto"
        oExemplo["linhas"][1]["classeTexto"]     := "po-sm-12"
        oExemplo["linhas"][1]["styleTexto"]      := oStyleQtd:ToJson()
        oExemplo["linhas"][1]["tituloProgresso"] := ""
        oExemplo["linhas"][1]["valorProgresso"]  := ""
        oExemplo["linhas"][1]["icone"]           := ""

        aAdd(oExemplo["linhas"],JsonObject():New())
        oExemplo["linhas"][2]["texto"]           := "1350 Kg"
        oExemplo["linhas"][2]["tipo"]            := "texto"
        oExemplo["linhas"][2]["classeTexto"]     := "po-font-title po-text-center po-sm-12 po-pt-1 bold-text"
        oExemplo["linhas"][2]["styleTexto"]      := oStyle:ToJson()
        oExemplo["linhas"][2]["tituloProgresso"] := ""
        oExemplo["linhas"][2]["valorProgresso"]  := ""
        oExemplo["linhas"][2]["icone"]           := ""

        oCarga:setaTitulo("Lotes a vencer")
        oCarga:setaObjetivo("Apresentar o número de lotes e a quantidade a vencer de um determinado produto, dentro de um período futuro configurado, utilizando o conceito de semáforo para indicar o nível de atenção ou urgência.")
        oCarga:setaAgrupador("Estoque")
        oCarga:setaFuncaoNegocio("StatusLotesAVencer")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonTexto(.F.,oExemplo)

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
            oPrmAdc["02_B8_PRODUTO"]["colunas"][1]["property"]  := "Code"
            oPrmAdc["02_B8_PRODUTO"]["colunas"][1]["label"]     := GetSx3Cache("B1_COD","X3_TITULO")
        aAdd(oPrmAdc["02_B8_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_B8_PRODUTO"]["colunas"][2]["property"]  := "Description"
            oPrmAdc["02_B8_PRODUTO"]["colunas"][2]["label"]     := GetSx3Cache("B1_DESC","X3_TITULO")
        oPrmAdc["02_B8_PRODUTO"]["labelSelect"]                 := "Code"
        oPrmAdc["02_B8_PRODUTO"]["valorSelect"]                 := "Code"
        oPrmAdc["04_TIPOSEMAFORO"]                              := JsonObject():New()
        oPrmAdc["04_TIPOSEMAFORO"]["opcoes"]                    := "Número de Lotes:L;Quantidade do Produto:Q"
        oPrmAdc["05_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["05_TIPOPERIODO"]["opcoes"]                     := "Dia Atual:D; Semana Atual:S; Quinzena Atual:Q; Mês Atual:M; Personalizado:X"

        oCarga:setaPropriedade("01_B8_FILIAL","","Filial",7,GetSx3Cache("B8_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12 po-pr-6",/*oEstilos*/,/*cIcone*/,oPrmAdc["01_B8_FILIAL"])
        oCarga:setaPropriedade("02_B8_PRODUTO","","Produtos",8,GetSx3Cache("B8_PRODUTO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["02_B8_PRODUTO"])
        oCarga:setaPropriedade("03_SEMAFORO","Atenção;Urgente (Lotes/Quantidade)","Semáforo (Lotes/Quantidade)",1,30,0,"po-lg-8 po-xl-8 po-md-8 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oPrmAdc*/)
        oCarga:setaPropriedade("04_TIPOSEMAFORO","L","Lotes/Quantidade",4,/*cTamanho*/,/*cDecimal*/,"po-lg-4 po-xl-4 po-md-4 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["04_TIPOSEMAFORO"])
        oCarga:setaPropriedade("05_TIPOPERIODO","D","Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,oPrmAdc["05_TIPOPERIODO"])
        oCarga:setaPropriedade("06_PERIODO","10","Período personalizado (dias)",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FreeObj(oExemplo)
    FreeObj(oStyle)
    FreeObj(oPrmAdc)
    FreeObj(oStyleQtd)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter   , Tipo chart/info
@param	cSubTipo  , caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusLotesAVencer
    Local aSemaforo  := StrToKArr(oFiltros["03_SEMAFORO"], ";")
    Local cAliasQry  := GetNextAlias()
    Local cCodProd   := oFiltros["02_B8_PRODUTO"]
    Local cJsonDados := ""
    Local cQuery     := ""
    Local cUnMedida  := ""
    Local dFilterDat := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["05_TIPOPERIODO"],ddatabase,cValtoChar(oFiltros["06_PERIODO"]))
    Local nLotes     := 0
    Local nPos       := 0
    Local nSaldo     := 0
    Local oJsonRet   := JsonObject():New()

    oFiltros["01_B8_FILIAL"] := PadR(oFiltros["01_B8_FILIAL"], FWSizeFilial())
    cUnMedida  := Posicione("SB1",1,xFilial("SB1",oFiltros["01_B8_FILIAL"])+cCodProd,"B1_UM")

    cQuery += " SELECT "
    cQuery += "     SB8.B8_PRODUTO CODIGO_PRODUTO, "
    cQuery += "     SUM(SB8.B8_SALDO) SALDO, "
    cQuery += "     COUNT(SB8.R_E_C_N_O_) QUANTIDADE_LOTES "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8",oFiltros["01_B8_FILIAL"]) + "' "
    cQuery += "   AND SB8.B8_PRODUTO = '" + cCodProd + "' "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+DTOS(ddatabase)+"' AND  '"+DTOS(dFilterDat)+"' "
    cQuery += "   AND SB8.D_E_L_E_T_  = ' ' "
    cQuery += " GROUP BY SB8.B8_FILIAL,SB8.B8_PRODUTO  "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)
    If  (cAliasQry)->(!Eof())
        cCodProd   := AllTrim((cAliasQry)->CODIGO_PRODUTO)
        nLotes     := (cAliasQry)->QUANTIDADE_LOTES
        nSaldo     := (cAliasQry)->SALDO
    End
    (cAliasQry)->(dbCloseArea())

    If cTipo == "info"
        montaInfo(oJsonRet,nLotes,nSaldo,aSemaforo,oFiltros["04_TIPOSEMAFORO"],cCodProd,cUnMedida)
    Else
        montaGraf(oJsonRet,nLotes,nSaldo,aSemaforo,oFiltros["04_TIPOSEMAFORO"],cCodProd,cUnMedida)
    EndIf

    oJsonRet["tags"]     := {}
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPos++
    oJsonRet["tags"][nPos]["texto"]      := " "+cValToChar(ddatabase)+" - "+cValToChar(dFilterDat)+" "
    oJsonRet["tags"][nPos]["colorTexto"] := ""
    oJsonRet["tags"][nPos]["icone"]      := "po-icon-calendar"
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPos++
    oJsonRet["tags"][nPos]["texto"]      := cCodProd
    oJsonRet["tags"][nPos]["colorTexto"] := ""
    oJsonRet["tags"][nPos]["icone"]      := "po-icon-bar-code"

    If cTipo == "info" .And. oFiltros["04_TIPOSEMAFORO"] == "Q"
        aAdd(oJsonRet["tags"], JsonObject():New())
        nPos++
        oJsonRet["tags"][nPos]["texto"]      := "Un. Medida: " + cUnMedida
        oJsonRet["tags"][nPos]["colorTexto"] := ""
        oJsonRet["tags"][nPos]["icone"]      := "po-icon-weight"
    EndIf
    If cTipo == "chart"
        aAdd(oJsonRet["tags"], JsonObject():New())
        nPos++
        oJsonRet["tags"][nPos]["texto"]      := IIF(oFiltros["04_TIPOSEMAFORO"] == "L",cValToChar(nSaldo) + " " + cUnMedida,cValToChar(nLotes) + IIF(nLotes > 1," Lotes"," Lote"))
        oJsonRet["tags"][nPos]["colorTexto"] := ""
        oJsonRet["tags"][nPos]["icone"]      := "po-icon-star-filled"
    EndIf
    cJsonDados :=  oJsonRet:toJson()

    FwFreeArray(aSemaforo)
    FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusLotesAVencer
    Local aFiliais  := FWLoadSM0()
    Local aRetorno  := {.T.,""}
    Local aSemaforo := {}
    Local nFilSeg   := 0
    Local nX        := 1

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

    If aRetorno[1] .And. oFiltros["05_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("06_PERIODO") .Or. oFiltros["06_PERIODO"] == Nil .Or. Empty(oFiltros["06_PERIODO"])
            aRetorno[1] := .F.
            aRetorno[2] := "Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf

    If aRetorno[1] 
        If !oFiltros:HasProperty("03_SEMAFORO") .Or. oFiltros["03_SEMAFORO"] == Nil .Or. Empty(oFiltros["03_SEMAFORO"])
            aRetorno[1] := .F.
            aRetorno[2] := "O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
        Else 
            aSemaforo := STRTOKARR( oFiltros["03_SEMAFORO"], ";" )
            If Len(aSemaforo) <> 2
                aRetorno[1] := .F.
                aRetorno[2] := "O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
            Else
                For nX := 1 To 2
                    If Empty(aSemaforo[nX])
                        aRetorno[1] := .F.
                        aRetorno[2] := "O campo 'Semáforo' deve ser preenchido com 2 valores separados por ponto e vírgula (ex.: '10;100'), definindo o número de lotes/quantidade que indicam Atenção e Urgência, respectivamente"
                        Exit
                    EndIf
                Next nX

                If Val(aSemaforo[1]) >= Val(aSemaforo[2])
                    aRetorno[1] := .F.
                    aRetorno[2] := "No campo 'Semáforo', o primeiro valor, referente ao status 'Atenção', deve ser menor que o segundo, que representa 'Urgência'"
                EndIf
            EndIf
        EndIf
    EndIf
    FwFreeArray(aFiliais)
    FwFreeArray(aSemaforo)
Return aRetorno

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author douglas.heydt
@since 12/04/2023
@version P12.1.2310
@return Nil
/*/
Method BuscaDetalhes(oFiltro,nPagina) Class StatusLotesAVencer
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local dDataFim   := PCPMonitorUtils():RetornaPeriodoFinal(AllTrim(oFiltro["05_TIPOPERIODO"]),ddatabase,cValToChar(oFiltro["06_PERIODO"]))
    Local lExpResult := .F.
    Local nPos       := 0
    Local nStart     := 1
    Local nTamPagina := 20
    Local oDados     := JsonObject():New()

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf

    oFiltro["01_B8_FILIAL"] := PadR(oFiltro["01_B8_FILIAL"], FWSizeFilial())

    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["canExportCSV"] := .T.
    oDados["tags"]         := {}
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][1]["icone"]      := "po-icon-calendar"
    oDados["tags"][1]["colorTexto"] := ""
    oDados["tags"][1]["texto"]      := dToC(dDatabase) + " - " + dToC(dDataFim)
    aAdd(oDados["tags"],JsonObject():New())
    oDados["tags"][2]["icone"]      := "po-icon-bar-code"
    oDados["tags"][2]["colorTexto"] := ""
    oDados["tags"][2]["texto"]      := oFiltro["02_B8_PRODUTO"]

    cQuery += " SELECT "
    cQuery += "     SB8.B8_FILIAL,  SB8.B8_QTDORI,  SB8.B8_PRODUTO,  SB8.B8_LOCAL,  SB8.B8_DTVALID, "
    cQuery += "     SB8.B8_SALDO, SB8.B8_LOTECTL, SB1.B1_DESC, SB8.B8_NUMLOTE, SB1.B1_UM "
    cQuery += " FROM "+RetSqlName("SB8")+" SB8 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltro["01_B8_FILIAL"])+"' AND SB1.B1_COD = SB8.B8_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8",oFiltro["01_B8_FILIAL"]) + "' "
    cQuery += "   AND SB8.B8_PRODUTO = '"+oFiltro["02_B8_PRODUTO"]+"'  "
    cQuery += "   AND SB8.B8_DTVALID BETWEEN '"+DTOS(ddatabase)+"' AND  '"+DTOS(dDataFim)+"' "
    cQuery += "   AND SB8.D_E_L_E_T_  = ' ' "
    cQuery += " ORDER BY SB8.B8_FILIAL,SB8.B8_DTVALID,SB8.B8_LOTECTL  "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

    While (cAlias)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        oDados["items"][nPos]["B8_FILIAL"  ] := (cAlias)->B8_FILIAL
        oDados["items"][nPos]["B8_LOTECTL" ] := (cAlias)->B8_LOTECTL
        oDados["items"][nPos]["B8_NUMLOTE" ] := (cAlias)->B8_NUMLOTE
        oDados["items"][nPos]["B8_PRODUTO" ] := (cAlias)->B8_PRODUTO
        oDados["items"][nPos]["B1_DESC"    ] := (cAlias)->B1_DESC
        oDados["items"][nPos]["B8_QTDORI"  ] := (cAlias)->B8_QTDORI
        oDados["items"][nPos]["B1_UM"      ] := (cAlias)->B1_UM
        oDados["items"][nPos]["B8_LOCAL"   ] := (cAlias)->B8_LOCAL
        oDados["items"][nPos]["B8_DTVALID" ] := PCPMonitorUtils():FormataData((cAlias)->B8_DTVALID, 5)
        oDados["items"][nPos]["B8_SALDO"   ] := (cAlias)->B8_SALDO
        (cAlias)->(dbSkip())
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAlias)->(!Eof())
    (cAlias)->(dbCloseArea())
Return oDados:ToJson()

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author douglas.heydt
@since 13/04/2023
@version P12.1.2310
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
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

/*/{Protheus.doc} retCorSmf
Retorna a cor do semáforo de acordo com a quantidade parametrizada
@type Static Function
@author douglas.heydt
@since 13/04/2023
@version P12.1.2310
@param  nQuant   , numerico, Quantidade de lotes ou de unidades
@param  aSemaforo, array, contem os ranges definidos para cada cor resultante baseado no número de lotes ou quantidade de produtos
@return aColumns , array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function retCorSmf(nQuant, aSemaforo)
    If nQuant < Val(aSemaforo[1])
        Return COR_VERDE_FORTE
    ElseIf nQuant < Val(aSemaforo[2])
        Return COR_AMARELO_ESCURO
    EndIf
Return COR_VERMELHO_FORTE

/*/{Protheus.doc} montaGraf
Monta objeto json com os dados para mostrar o gauge
@type Static Function
@author renan.roeder
@since 01/06/2023
@version P12.1.2310
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nLotes    , numerico   , Número de lotes retornado da consulta
@param  nSaldo    , numerico   , Saldo dos lotes retornados na consulta
@param  aSemaforo , array      , Array com os números do semáforo
@param  cTipoSemaf, caracter   , L - Quantidade Lotes / Q - Saldo Lotes
@param  cProduto  , caracter   , Codigo do produto
@param  cUnMedida , caracter   , Unidade de medida do produto
@return Nil
/*/
Static Function montaGraf(oJsonRet,nLotes,nSaldo,aSemaforo,cTipoSemaf,cProduto,cUnMedida)
    Local cLabel    := ""
    Local cValorFim := ""
    Local nQuant    := 0
    Local nValorFim := 0

    If cTipoSemaf == "L"
        nQuant  := nLotes
        cLabel  := IIF(nLotes > 1,"Lotes","Lote")
    Else
        nQuant  := nSaldo
        cLabel  := cUnMedida
    EndIf
    If nQuant > Val(aSemaforo[2])
        nValorFim := nQuant + (Val(aSemaforo[2]) - Val(aSemaforo[1]))
    Else
        nValorFim := Val(aSemaforo[2]) + (Val(aSemaforo[2]) - Val(aSemaforo[1]))
    EndIf
    cValorFim := cValToChar(nValorFim)

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["detalhes"]   := {}
    oJsonRet["gauge"]      := JsonObject():New()
    oJsonRet["gauge"]["type"]       := "arch"
    oJsonRet["gauge"]["value"]      := nQuant
    oJsonRet["gauge"]["max"]        := nValorFim
    oJsonRet["gauge"]["label"]      := cLabel
    oJsonRet["gauge"]["append"]     := ""
    oJsonRet["gauge"]["thick"]      := 20
    oJsonRet["gauge"]["margin"]     := 15
    oJsonRet["gauge"]["valueStyle"] := JsonObject():New()
    oJsonRet["gauge"]["valueStyle"]["color"]       := retCorSmf(nQuant,aSemaforo)
    oJsonRet["gauge"]["valueStyle"]["font-weight"] := "bold"
    oJsonRet["gauge"]["labelStyle"] := JsonObject():New()
    oJsonRet["gauge"]["labelStyle"]["font-weight"] := "bold"
    oJsonRet["gauge"]["thresholds"] := JsonObject():New()
    oJsonRet["gauge"]["thresholds"]["0"]                       := JsonObject():New()
    oJsonRet["gauge"]["thresholds"]["0"]["color"]              := COR_VERDE_FORTE
    oJsonRet["gauge"]["thresholds"]["0"]["bgOpacity"]          := 0.2
    oJsonRet["gauge"]["thresholds"][aSemaforo[1]]              := JsonObject():New()
    oJsonRet["gauge"]["thresholds"][aSemaforo[1]]["color"]     := COR_AMARELO_QUEIMADO
    oJsonRet["gauge"]["thresholds"][aSemaforo[1]]["bgOpacity"] := 0.2
    oJsonRet["gauge"]["thresholds"][aSemaforo[2]]              := JsonObject():New()
    oJsonRet["gauge"]["thresholds"][aSemaforo[2]]["color"]     := COR_VERMELHO_FORTE
    oJsonRet["gauge"]["thresholds"][aSemaforo[2]]["bgOpacity"] := 0.2
    oJsonRet["gauge"]["markers"] := JsonObject():New()
    If Val(aSemaforo[1]) > 0
        oJsonRet["gauge"]["markers"]["0"]   :=  JsonObject():New()
        oJsonRet["gauge"]["markers"]["0"]["color"]   := COR_PRETO
        oJsonRet["gauge"]["markers"]["0"]["size"]    := 6
        oJsonRet["gauge"]["markers"]["0"]["label"]   := "0"
        oJsonRet["gauge"]["markers"]["0"]["type"]    := "line"
    EndIf
    oJsonRet["gauge"]["markers"][aSemaforo[1]] :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][aSemaforo[1]]["color"]   := COR_PRETO
    oJsonRet["gauge"]["markers"][aSemaforo[1]]["size"]    := 6
    oJsonRet["gauge"]["markers"][aSemaforo[1]]["label"]   := aSemaforo[1]
    oJsonRet["gauge"]["markers"][aSemaforo[1]]["type"]    := "line"
    oJsonRet["gauge"]["markers"][aSemaforo[2]] :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][aSemaforo[2]]["color"]   := COR_PRETO
    oJsonRet["gauge"]["markers"][aSemaforo[2]]["size"]    := 6
    oJsonRet["gauge"]["markers"][aSemaforo[2]]["label"]   := aSemaforo[2]
    oJsonRet["gauge"]["markers"][aSemaforo[2]]["type"]    := "line"
    oJsonRet["gauge"]["markers"][cValorFim]    :=  JsonObject():New()
    oJsonRet["gauge"]["markers"][cValorFim]["color"]      := COR_PRETO
    oJsonRet["gauge"]["markers"][cValorFim]["size"]       := 6
    oJsonRet["gauge"]["markers"][cValorFim]["label"]      := cValorFim
    oJsonRet["gauge"]["markers"][cValorFim]["type"]       := "line"
Return

/*/{Protheus.doc} montaInfo
Monta objeto json com os dados para mostrar o gráfico de informações
@type Static Function
@author renan.roeder
@since 01/06/2023
@version P12.1.2310
@param  oJsonRet  , objeto json, Objeto json que receberá os dados do gauge
@param  nLotes    , numerico   , Número de lotes retornado da consulta
@param  nSaldo    , numerico   , Saldo dos lotes retornados na consulta
@param  aSemaforo , array      , Array com os números do semáforo
@param  cTipoSemaf, caracter   , L - Quantidade Lotes / Q - Saldo Lotes
@param  cProduto  , caracter   , Codigo do produto
@param  cUnMedida , caracter   , Unidade de medida do produto
@return Nil
/*/
Static Function montaInfo(oJsonRet,nLotes,nSaldo,aSemaforo,cTipoSemaf,cProduto,cUnMedida)
    Local cTxtPrc    := ""
    Local cTxtSec    := ""
    Local nQuant     := 0
    Local oStyle     := JsonObject():New()
    Local oStyleQtd  := JsonObject():New()

    oJsonRet["corTitulo"] := "white"
    oStyle["color"] := "white"
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["linhas"] := {}

    If cTipoSemaf == "L"
        nQuant  := nLotes
        cTxtPrc := cValToChar(nLotes)
        cTxtSec := cValToChar(nSaldo) + " " + cUnMedida
    Else
        nQuant  := nSaldo
        cTxtPrc := cValToChar(nSaldo)
        cTxtSec := cValToChar(nLotes) + IIF(nLotes > 1," Lotes"," Lote")
    EndIf

    If nLotes > 0
        oJSonRet["corFundo"] := retCorSmf(nQuant,aSemaforo)

        If oJSonRet["corFundo"] == COR_AMARELO_ESCURO
            oStyle["color"]       := "black"
            oJsonRet["corTitulo"] := "black"
        EndIf
        aAdd(oJsonRet["linhas"],JsonObject():New())
        oStyleQtd["font-weight"] := "bold"
        oStyleQtd["font-size"]   := "120px"
        oStyleQtd["line-height"] := "130px"
        oStyleQtd["text-align"]  := "center"
        oStyleQtd["color"]       := oStyle["color"]
        oStyleQtd["cursor"]      := "pointer"
        oJsonRet["linhas"][1]["texto"]           := cTxtPrc
        oJsonRet["linhas"][1]["tipo"]            := "texto"
        oJsonRet["linhas"][1]["classeTexto"]     := "po-sm-12"
        oJsonRet["linhas"][1]["styleTexto"]      := oStyleQtd:ToJson()
        oJsonRet["linhas"][1]["tituloProgresso"] := ""
        oJsonRet["linhas"][1]["valorProgresso"]  := ""
        oJsonRet["linhas"][1]["icone"]           := ""
        oJsonRet["linhas"][1]["tipoDetalhe"]     := "detalhe"
        aAdd(oJsonRet["linhas"],JsonObject():New())
        oJsonRet["linhas"][2]["texto"]           := cTxtSec
        oJsonRet["linhas"][2]["tipo"]            := "texto"
        oJsonRet["linhas"][2]["classeTexto"]     := "po-font-title po-text-center po-sm-12 po-pt-1 bold-text"
        oJsonRet["linhas"][2]["styleTexto"]      := oStyle:ToJson()
        oJsonRet["linhas"][2]["tituloProgresso"] := ""
        oJsonRet["linhas"][2]["valorProgresso"]  := ""
        oJsonRet["linhas"][2]["icone"]           := ""
    Else
        oJsonRet["corFundo"] := COR_VERDE_FORTE
        aAdd(oJsonRet["linhas"],JsonObject():New())
        oJsonRet["linhas"][1]["texto"]           := "Nenhum lote do produto vencerá no período selecionado."
        oJsonRet["linhas"][1]["tipo"]            := "texto"
        oJsonRet["linhas"][1]["classeTexto"]     := "po-font-text-large-bold po-text-center po-sm-12 po-pt-4"
        oJsonRet["linhas"][1]["styleTexto"]      := oStyle:ToJson()
        oJsonRet["linhas"][1]["tituloProgresso"] := ""
        oJsonRet["linhas"][1]["valorProgresso"]  := ""
        oJsonRet["linhas"][1]["icone"]           := ""
        oJsonRet["linhas"][1]["tipoDetalhe"]     := ""
    EndIf
Return
