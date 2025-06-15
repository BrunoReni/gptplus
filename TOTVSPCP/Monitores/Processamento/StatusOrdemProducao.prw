#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusOrdemProducao
Classe para prover os dados do Monitor de Status de Ordem de Producao
@type Class
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@return Nil
/*/
Class StatusOrdemProducao FROM LongNameClass
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
    Static Method BuscaDetalhes(oFiltros, nPagina)
    Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do monitor no banco de dados, permitindo a exibição de um exemplo desse monitor para 
ser escolhido para uso na aplicação.
@type Class
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@return lRet, logico, Define se a carga do Monitor foi realizada com sucesso
/*/
Method CargaMonitor() Class StatusOrdemProducao
    
    Local aCategoria := {}
    Local aTags      := {}
    Local lRet       := .T.
    Local oSeries    := JsonObject():New()
    Local oCarga     := PCPMonitorCarga():New()
    Local oPrmAdc    := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusOrdemProducao")
        oSeries["Prevista"]         := {2, COR_AMARELO} 
        oSeries["Em Aberto"]        := {7, COR_VERDE }
        oSeries["Iniciada"]         := {4, COR_LARANJA}
        oSeries["Ociosa"]           := {9, COR_CINZA} 
        oSeries["Enc.Parcialmente"] := {1, COR_AZUL}
        oSeries["Enc.Totalmente"]   := {5, COR_VERMELHO} 

        aTags   := {}
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]     := "01/02/2023 - 28/02/2023"
        aTags[1]["colorTexto"]:= ""
        aTags[1]["icone"]     := "po-icon-calendar"
        aAdd(aTags, JsonObject():New())
        aTags[2]["texto"]     := "28 Ordens"
        aTags[2]["colorTexto"]:= ""
        aTags[2]["icone"]     := "po-icon-star-filled"

        oPrmAdc["01_C2_FILIAL"]                                 := JsonObject():New()
        oPrmAdc["01_C2_FILIAL"]["filtroServico"]                := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_C2_FILIAL"]["parametrosServico"]            := JsonObject():New()
        oPrmAdc["01_C2_FILIAL"]["parametrosServico"]["metodo"]  := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_C2_FILIAL"]["labelSelect"]                  := "Description"
        oPrmAdc["01_C2_FILIAL"]["valorSelect"]                  := "Code"
        oPrmAdc["02_C2_PRODUTO"]                                := JsonObject():New()
        oPrmAdc["02_C2_PRODUTO"]["filtroServico"]               := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]           := JsonObject():New()
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]["filial"] := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]["metodo"] := "PCPMonitorConsultas():BuscaProdutos"
        oPrmAdc["02_C2_PRODUTO"]["selecaoMultipla"]             := .T.
        oPrmAdc["02_C2_PRODUTO"]["colunas"]                     := {}
        aAdd(oPrmAdc["02_C2_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_C2_PRODUTO"]["colunas"][1]["property"]  := "Code"
            oPrmAdc["02_C2_PRODUTO"]["colunas"][1]["label"]     := GetSx3Cache("B1_COD","X3_TITULO")
        aAdd(oPrmAdc["02_C2_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_C2_PRODUTO"]["colunas"][2]["property"]  := "Description"
            oPrmAdc["02_C2_PRODUTO"]["colunas"][2]["label"]     := GetSx3Cache("B1_DESC","X3_TITULO")
        oPrmAdc["02_C2_PRODUTO"]["labelSelect"]                 := "Code"
        oPrmAdc["02_C2_PRODUTO"]["valorSelect"]                 := "Code"
        oPrmAdc["04_FILTRODATA"]                                := JsonObject():New()
        oPrmAdc["04_FILTRODATA"]["opcoes"]                      := "Data de Início:C2_DATPRI; Previsão de Entrega:C2_DATPRF"
        oPrmAdc["05_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["05_TIPOPERIODO"]["opcoes"]                     := "Dia Atual:D;Semana Atual:S;Quinzena Atual:Q;Mês Atual:M;Personalizado:X"
        oPrmAdc["03_STATUS"]                                    := JsonObject():New()
        oPrmAdc["03_STATUS"]["opcoes"]                          := "Prevista:1;Em aberto:2;Iniciada:3;Ociosa:4;Enc. Parcialmente:5;Enc. Totalmente:6"

        oCarga:setaTitulo("Situação de ordens de produção")
        oCarga:setaObjetivo("Acompanhar a situação das ordens de produção existentes no sistema, sendo as opções monitoradas: Prevista, Em aberto, Iniciada, Ociosa, Encerrada parcialmente ou Encerrada totalmente.")
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusOrdemProducao")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("pie;bar;column")
        oCarga:setaTipoGraficoPadrao("pie")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries,aTags,aCategoria,"pie")
        oCarga:setaPropriedade("01_C2_FILIAL","","Filial",7,GetSx3Cache("C2_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["01_C2_FILIAL"])
        oCarga:setaPropriedade("02_C2_PRODUTO","","Produto",8,GetSx3Cache("C2_PRODUTO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["02_C2_PRODUTO"])
        oCarga:setaPropriedade("03_STATUS","1,2,3,4,5,6","Status",5,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["03_STATUS"])
        oCarga:setaPropriedade("04_FILTRODATA","C2_DATPRI","Data de referência",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_FILTRODATA"])
        oCarga:setaPropriedade("05_TIPOPERIODO","X","Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["05_TIPOPERIODO"])
        oCarga:setaPropriedade("06_PERIODO","0","Período personalizado (dias)",2,3,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        If !oCarga:gravaMonitorPropriedades()
            lRet := .F.
        EndIf
        oCarga:Destroy()
    EndIf
    FwFreeArray(aTags)
    FreeObj(oPrmAdc)
    FreeObj(oSeries)
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
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusOrdemProducao
    Local aNames     := {}
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cOp        := ""
    Local cQuery     := ""
    Local cStatusFlt := ArrTokStr(oFiltros["03_STATUS"])
    Local cStatusOp  := ""
    Local dDataIni   := dDataBase
    Local dDataFin   := dDataBase
    Local nIndice    := 0
    Local nPos       := 0
    Local nPosTags   := 0
    Local nTotOP     := 0
    Local oJsonRet   := JsonObject():New()
    Local oDados     := JsonObject():New()

    //oJsonRet["titulo"]     := oBody["titulo"]
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"]         := {"Situação"}
    oJsonRet["series"]             := {}

    cQuery := montaQuery(oFiltros, @dDataIni, @dDataFin)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    oDados["Prevista"]          := {0, COR_AMARELO} 
    oDados["Em aberto"]         := {0, COR_VERDE }
    oDados["Iniciada"]          := {0, COR_LARANJA}
    oDados["Ociosa"]            := {0, COR_CINZA} 
    oDados["Enc. Parcialmente"] := {0, COR_AZUL}
    oDados["Enc. Totalmente"]   := {0, COR_VERMELHO} 

    nPos := 0
    While (cAliasQry)->(!Eof())
        cOp := (cAliasQry)->C2_NUM+(cAliasQry)->C2_ITEM+(cAliasQry)->C2_SEQUEN+(cAliasQry)->C2_ITEMGRD
        cStatusOp := fStatusOp(cOp, (cAliasQry)->C2_TPOP, (cAliasQry)->C2_DATRF, (cAliasQry)->C2_QUJE, (cAliasQry)->C2_QUANT, (cAliasQry)->C2_DIASOCI, (cAliasQry)->C2_DATPRI) 
        If cStatusOp $ cStatusFlt
            Do Case
                Case  cStatusOp == "1"
                    ++oDados["Prevista"][1]
                Case  cStatusOp == "2"
                    ++oDados["Em aberto"][1]
                Case  cStatusOp == "3"
                    ++oDados["Iniciada"][1]
                Case  cStatusOp == "4"
                    ++oDados["Ociosa"][1]
                Case  cStatusOp == "5"
                    ++oDados["Enc. Parcialmente"][1]
                Case  cStatusOp == "6"
                    ++oDados["Enc. Totalmente"][1]
            EndCase
        EndIf
        (cAliasQry)->(dbSkip())
    End
    (cAliasQry)->(dbCloseArea())

    aNames := oDados:GetNames()
    For nIndice := 1 To Len(aNames)
        aAdd(oJsonRet["series"], JsonObject():New())	
        oJsonRet["series"][nIndice]["label"]   := aNames[nIndice]
        oJsonRet["series"][nIndice]["color"]   := oDados[aNames[nIndice]][2]
        oJsonRet["series"][nIndice]["tooltip"] := ""
        If cSubTipo <> 'pie'
            oJsonRet["series"][nIndice]["data"]   := {}
            aAdd(oJsonRet["series"][nIndice]["data"],  oDados[aNames[nIndice]][1] )
        Else
            oJsonRet["series"][nIndice]["data"]   :=  oDados[aNames[nIndice]][1]
        EndIf
        nTotOP += oDados[aNames[nIndice]][1]
    Next nIndice

    oJsonRet["tags"] := {}
    aAdd(oJsonRet["tags"], JsonObject():New())	
    nPosTags++
    oJsonRet["tags"][nPosTags]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    oJsonRet["tags"][nPosTags]["colorTexto"] := ""
    oJsonRet["tags"][nPosTags]["icone"]      := "po-icon-calendar"
    aAdd(oJsonRet["tags"], JsonObject():New())	
    nPosTags++
    oJsonRet["tags"][nPosTags]["texto"]      := cValToChar(nTotOP) + IIF(nTotOP > 1," Ordens"," Ordem")
    oJsonRet["tags"][nPosTags]["colorTexto"] := ""
    oJsonRet["tags"][nPosTags]["icone"]      := "po-icon-star-filled"
    If oFiltros:HasProperty("03_STATUS") .And. ValType(oFiltros["03_STATUS"]) == "A" .And. Len(oFiltros["03_STATUS"]) < 6
        For nIndice := 1 To Len(oFiltros["03_STATUS"])
            aAdd(oJsonRet["tags"], JsonObject():New())
            nPosTags++
            oJsonRet["tags"][nPosTags]["texto"]      := buscaSerie(oFiltros["03_STATUS"][nIndice])
            oJsonRet["tags"][nPosTags]["colorTexto"] := ""
            oJsonRet["tags"][nPosTags]["icone"]      := "po-icon-filter"
        Next nIndice
    EndIf
    If oFiltros:HasProperty("02_C2_PRODUTO") .And. ValType(oFiltros["02_C2_PRODUTO"]) == "A"
        For nIndice := 1 To Len(oFiltros["02_C2_PRODUTO"])
            aAdd(oJsonRet["tags"], JsonObject():New())
            nPosTags++
            oJsonRet["tags"][nPosTags]["texto"]      := oFiltros["02_C2_PRODUTO"][nIndice]
            oJsonRet["tags"][nPosTags]["colorTexto"] := ""
            oJsonRet["tags"][nPosTags]["icone"]      := "po-icon-bar-code"
        Next nIndice
    EndIf
    cJsonDados := oJsonRet:toJson()
    FwFreeArray(aNames)
    FreeObj(oDados)
    FreeObj(oJsonRet)
Return cJsonDados

/*/{Protheus.doc} BuscaDetalhes
Responsável por realizar a busca dos dados que serão exibidos no detalhamento do monitor
@type Class
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param	oFiltros  , objeto Json , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico    , Número da página desejada para busca
@return cJsonDados, caracter    , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class StatusOrdemProducao
    Local cAliasQry  := GetNextAlias()
    Local cJsonDados := ""
    Local cQuery     := ""
    Local cOp        := ""
    Local cStatusFlt := ArrTokStr(oFiltros["03_STATUS"])
    Local cStatusOp  := ""
    Local dDataIni   := dDataBase
    Local dDataFin   := dDataBase
    Local lExpResult := .F.
    Local nIndice    := 0
    Local nPos       := 0
    Local nPosTags   := 0
    Local nStart     := 0
    Local oDados     := JsonObject():New()

    Default nPagina    := 1
    Default nTamPagina := 20

    If nPagina == 0
        lExpResult := .T.
    EndIf
    
    cQuery := montaQuery(oFiltros, @dDataIni, @dDataFin)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    oDados["items"]   := {}
    oDados["columns"] := montaColun(lExpResult)
    oDados["headers"] := {}
    oDados["tags"] := {}
    oDados["canExportCSV"] := .T.

    aAdd(oDados["tags"],JsonObject():New())
    nPosTags++
    oDados["tags"][nPosTags]["icone"]      := "po-icon-calendar"
    oDados["tags"][nPosTags]["colorTexto"] := ""
    oDados["tags"][nPosTags]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    If !Empty(oFiltros["SERIE"])
        aAdd(oDados["tags"],JsonObject():New())
        nPosTags++
        oDados["tags"][nPosTags]["icone"]      := "po-icon-filter"
        oDados["tags"][nPosTags]["colorTexto"] := ""
        oDados["tags"][nPosTags]["texto"]      := oFiltros["SERIE"]
    Else
        If oFiltros:HasProperty("03_STATUS") .And. ValType(oFiltros["03_STATUS"]) == "A" .And. Len(oFiltros["03_STATUS"]) < 6
            For nIndice := 1 To Len(oFiltros["03_STATUS"])
                aAdd(oDados["tags"], JsonObject():New())
                nPosTags++
                oDados["tags"][nPosTags]["texto"]      := buscaSerie(oFiltros["03_STATUS"][nIndice])
                oDados["tags"][nPosTags]["colorTexto"] := ""
                oDados["tags"][nPosTags]["icone"]      := "po-icon-filter"
            Next nIndice
        EndIf
    EndIf
    If oFiltros:HasProperty("02_C2_PRODUTO") .And. ValType(oFiltros["02_C2_PRODUTO"]) == "A"
        For nIndice := 1 To Len(oFiltros["02_C2_PRODUTO"])
            aAdd(oDados["tags"], JsonObject():New())
            nPosTags++
            oDados["tags"][nPosTags]["texto"]      := oFiltros["02_C2_PRODUTO"][nIndice]
            oDados["tags"][nPosTags]["colorTexto"] := ""
            oDados["tags"][nPosTags]["icone"]      := "po-icon-bar-code"
        Next nIndice
    EndIf

    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	nPos := 0
    While (cAliasQry)->(!Eof())
        cOp       := (cAliasQry)->C2_NUM+(cAliasQry)->C2_ITEM+(cAliasQry)->C2_SEQUEN+(cAliasQry)->C2_ITEMGRD
        cStatusOp := fStatusOp(cOp, (cAliasQry)->C2_TPOP, (cAliasQry)->C2_DATRF, (cAliasQry)->C2_QUJE, (cAliasQry)->C2_QUANT, (cAliasQry)->C2_DIASOCI, (cAliasQry)->C2_DATPRI, oFiltros["01_C2_FILIAL"])
        
        If !Empty(oFiltros["SERIE"])
            If oFiltros["SERIE"] == buscaSerie(cStatusOp)
                aAdd(oDados["items"], JsonObject():New())
                nPos++
                oDados["items"][nPos]["C2_FILIAL"]  := (cAliasQry)->C2_FILIAL
                oDados["items"][nPos]["C2_OP"]      := Iif( !Empty((cAliasQry)->C2_OP), (cAliasQry)->C2_OP, cOp)
                oDados["items"][nPos]["C2_PRODUTO"] := (cAliasQry)->C2_PRODUTO
                oDados["items"][nPos]["B1_DESC"]    := (cAliasQry)->B1_DESC
                oDados["items"][nPos]["C2_LOCAL"]   := (cAliasQry)->C2_LOCAL
                oDados["items"][nPos]["C2_DATPRI"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRI, 5)
                oDados["items"][nPos]["C2_DATPRF"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRF, 5)
                oDados["items"][nPos]["C2_QUJE"]    := (cAliasQry)->C2_QUJE
                oDados["items"][nPos]["C2_QUANT"]   := (cAliasQry)->C2_QUANT
                oDados["items"][nPos]["C2_DIASOCI"] := (cAliasQry)->C2_DIASOCI
                oDados["items"][nPos]["STATUS"]     := cStatusOp
            EndIf
        Else
            If cStatusOp $ cStatusFlt
                aAdd(oDados["items"], JsonObject():New())
                nPos++
                oDados["items"][nPos]["C2_FILIAL"]  := (cAliasQry)->C2_FILIAL
                oDados["items"][nPos]["C2_OP"]      := Iif( !Empty((cAliasQry)->C2_OP), (cAliasQry)->C2_OP, cOp)
                oDados["items"][nPos]["C2_PRODUTO"] := (cAliasQry)->C2_PRODUTO
                oDados["items"][nPos]["B1_DESC"]    := (cAliasQry)->B1_DESC
                oDados["items"][nPos]["C2_LOCAL"]   := (cAliasQry)->C2_LOCAL
                oDados["items"][nPos]["C2_DATPRI"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRI, 5)
                oDados["items"][nPos]["C2_DATPRF"]  := PCPMonitorUtils():FormataData((cAliasQry)->C2_DATPRF, 5)
                oDados["items"][nPos]["C2_QUJE"]    := (cAliasQry)->C2_QUJE
                oDados["items"][nPos]["C2_QUANT"]   := (cAliasQry)->C2_QUANT
                oDados["items"][nPos]["C2_DIASOCI"] := (cAliasQry)->C2_DIASOCI
                oDados["items"][nPos]["STATUS"]     := cStatusOp
            EndIf
        EndIf
        (cAliasQry)->(dbSkip())

        //Verifica tamanho da página
        If !lExpResult .And. nPos >= nTamPagina
            Exit
        EndIf
    End
    oDados["hasNext"] := (cAliasQry)->(!Eof())
    (cAliasQry)->(dbCloseArea())
    cJsonDados := oDados:toJson()
    FreeObj(oDados)
Return cJsonDados


/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return aColumns, array objetos, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult)
    Local aColumns := {}
    Local nPos     := 0

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "STATUS"
    aColumns[nPos]["label"]    := "Status"
    aColumns[nPos]["type"]     := "cellTemplate"
    aColumns[nPos]["labels"]   := {}
    aAdd(aColumns[nPos]["labels"], JsonObject():New())
    aColumns[nPos]["labels"][1]['value']     := '1'
    aColumns[nPos]["labels"][1]['color']     := COR_AMARELO
    aColumns[nPos]["labels"][1]['label']     := 'Prevista'
    aColumns[nPos]["labels"][1]['textColor'] := COR_PRETO
    aAdd(aColumns[nPos]["labels"], JsonObject():New())
    aColumns[nPos]["labels"][2]['value']     := '2'
    aColumns[nPos]["labels"][2]['color']     := COR_VERDE
    aColumns[nPos]["labels"][2]['label']     := 'Em aberto'
    aColumns[nPos]["labels"][2]['textColor'] := COR_BRANCO
    aAdd(aColumns[nPos]["labels"], JsonObject():New())
    aColumns[nPos]["labels"][3]['value']     := '3'
    aColumns[nPos]["labels"][3]['color']     := COR_LARANJA
    aColumns[nPos]["labels"][3]['label']     := 'Iniciada'
    aColumns[nPos]["labels"][3]['textColor'] := COR_BRANCO
    aAdd(aColumns[nPos]["labels"], JsonObject():New())
    aColumns[nPos]["labels"][4]['value']     := '4'
    aColumns[nPos]["labels"][4]['color']     := COR_CINZA
    aColumns[nPos]["labels"][4]['label']     := 'Ociosa'
    aColumns[nPos]["labels"][4]['textColor'] := COR_BRANCO
    aAdd(aColumns[nPos]["labels"], JsonObject():New())
    aColumns[nPos]["labels"][5]['value']     :='5'
    aColumns[nPos]["labels"][5]['color']     :=COR_AZUL
    aColumns[nPos]["labels"][5]['label']     :='Enc.Parcialmente'
    aColumns[nPos]["labels"][5]['textColor'] := COR_BRANCO
    aAdd(aColumns[nPos]["labels"], JsonObject():New())
    aColumns[nPos]["labels"][6]['value']     :='6'
    aColumns[nPos]["labels"][6]['color']     := COR_VERMELHO
    aColumns[nPos]["labels"][6]['label']     :='Enc.Totalmente'
    aColumns[nPos]["labels"][6]['textColor'] := COR_BRANCO

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

/*/{Protheus.doc} montaQuery
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor
@type Static Function
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param	oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	dDataIni, data       , Data inicial do filtro
@param	dDataFin, data       , Data final do filtro
@return cQuery  , caracter   , Query utilizada para busca no banco de dados
/*/
Static Function montaQuery(oFiltros, dDataIni, dDataFin)
    Local cPerDias  := cValtoChar(oFiltros["06_PERIODO"])
    Local cProdutos := ""
    Local cQuery    := ""
    Local nIndice   := 0

    cQuery := " SELECT "
    cQuery += "     SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_OP, SC2.C2_LOCAL,"
	cQuery += "     SC2.C2_PRODUTO, SB1.B1_DESC, SC2.C2_TPOP, SC2.C2_DATRF, SC2.C2_DATPRF, SC2.C2_QUJE, SC2.C2_QUANT, SC2.C2_DIASOCI, SC2.C2_DATPRI"
    cQuery += " FROM " +RetSqlName("SC2")+ " SC2 "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1",oFiltros["01_C2_FILIAL"])+"' AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.D_E_L_E_T_ = ' ' " 
    cQuery += " WHERE SC2.C2_FILIAL = '"+ xFilial("SC2", oFiltros["01_C2_FILIAL"])+"' "

    If oFiltros:HasProperty("02_C2_PRODUTO") .And. ValType(oFiltros["02_C2_PRODUTO"]) == "A"
        For nIndice := 1 To Len(oFiltros["02_C2_PRODUTO"])
            If Empty(cProdutos)
                cProdutos := "'" + oFiltros["02_C2_PRODUTO"][nIndice] + "'"
            Else
                cProdutos +=  ",'" + oFiltros["02_C2_PRODUTO"][nIndice] + "'"
            EndIf
        Next nIndice
    EndIf
    If !Empty(cProdutos)
        cQuery += " AND SC2.C2_PRODUTO" +" IN ("+cProdutos+") "
    EndIf
    If oFiltros["05_TIPOPERIODO"] == "X"
        If Val(cPerDias) >= 0
            dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["05_TIPOPERIODO"],dDataIni,cPerDias)
        Else
            dDataIni := PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["05_TIPOPERIODO"],dDataFin,cValtoChar(ABS(Val(cPerDias))))
        EndIf
    Else
        dDataIni := PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["05_TIPOPERIODO"],dDataFin,cPerDias)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["05_TIPOPERIODO"],dDataIni,cPerDias)
    EndIf
    cQuery += " AND SC2."+oFiltros["04_FILTRODATA"]+" BETWEEN '"+dToS(dDataIni)+"' AND '"+dToS(dDataFin)+"' "
    cQuery += " AND SC2.D_E_L_E_T_ = ' ' "
Return cQuery

/*/{Protheus.doc} Static Function fStatusOp
Retorna o Status da Ordem de Produção
@type  Static Function
@author douglas.heydt
@since 07/03/2023
@version P12.1.2310
@param  cOP       , caracter, Ordem de Produção
@param  cTpo      , caracter, Tipo da Ordem de Produção / Firme ou Prevista
@param  cDatrf    , caracter, Data de Encerramento
@param  nQuje     , numerico, Quantidade Apontada
@param  nQuant    , numerico, Quantidade Prevista
@param  cFilterFil, caracter, Filial informada no filtro
@return cStatusOp , caracter, Status da OP - 1-Prevista/2-Em aberto/3-Iniciada/4-Ociosa/5-Enc.Parcialmente/6-Enc.Totalmente
/*/
Static Function fStatusOp(cOp, cTpo, cDatrf, nQuje, nQuant, cDatOci, cDTINI, cFilterFil)
    Local cAliasTemp  := ""
    Local cQuery 	  := ""
    Local dEmissao	  := dDatabase
    Local nRegSD3	  := 0
    Local nRegSH6	  := 0

    Default cOp       := ""
    Default cTpo      := ""
    Default cDatrf    := ""
    Default nQuant    := 0
    Default nQuje     := 0
    
    cDTINI := STOD(cDTINI)

    If cTpo == "P" //1-Prevista
        Return '1'
    EndIf
    If cTpo == "F" .And. !Empty(cDatrf) .And. (nQuje < nQuant)  //5-Enc.Parcialmente
        Return '5'
    EndIf
    If cTpo == "F" .And. !Empty(cDatrf) .And. (nQuje >= nQuant) //6-Enc.Totalmente
        Return '6'
    EndIf

    cAliasTemp:= "SD3TMP"
    cQuery	  := "  SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
    cQuery	  += "   FROM " + RetSqlName('SD3')
    cQuery	  += "   WHERE D3_FILIAL   = '" + xFilial( "SC2", cFilterFil ) + "'"
    cQuery	  += "     AND D3_OP 	   = '" + cOp + "'"
    cQuery	  += "     AND D3_ESTORNO <> 'S' "
    cQuery	  += "     AND D_E_L_E_T_  = ' '"
    cQuery    += " 	   GROUP BY D3_EMISSAO "
    cQuery    := ChangeQuery(cQuery)
    dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

    If !SD3TMP->(Eof())
        dEmissao := STOD(SD3TMP->EMISSAO)
        nRegSD3 := SD3TMP->RegSD3
    EndIf

    cAliasTemp:= "SH6TMP"
    cQuery	  := "  SELECT COUNT(*) AS RegSH6 "
    cQuery	  += "   FROM " + RetSqlName('SH6')
    cQuery	  += "   WHERE H6_FILIAL   = '" + xFilial('SH6', cFilterFil)+ "'"
    cQuery	  += "     AND H6_OP 	   = '" + cOp + "'"
    cQuery	  += "     AND D_E_L_E_T_  = ' '"
    cQuery    := ChangeQuery(cQuery)
    dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

    If !SH6TMP->(Eof())
        nRegSH6 := SH6TMP->RegSH6
    EndIf

    SD3TMP->(DbCloseArea())
    SH6TMP->(DbCloseArea())

    If cTpo == "F" .And. Empty(cDatrf)
        If (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - cDTINI,0) < If(cDatOci==0,1,cDatOci)) //2-Em aberto            
            Return '2'
        EndIf
        If (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((ddatabase - dEmissao),0) > If(cDatOci >= 0,-1,cDatOci)) //3-Iniciada
            Return '3'
        EndIf
        If (Max((ddatabase - dEmissao),0) > cDatOci .Or. Max((ddatabase - cDTINI),0) >= cDatOci)  //4-Ociosa
           Return '4'
        EndIf
    EndIf
Return

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusOrdemProducao
    Local aFiliais := FWLoadSM0()
    Local aRetorno := {.T.,""}
    Local nFilSeg  := 0

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

    If aRetorno[1] .And. oFiltros["05_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("06_PERIODO") .Or. oFiltros["06_PERIODO"] == Nil .Or. Empty(oFiltros["06_PERIODO"])
            aRetorno[1] := .F.
            aRetorno[2] := "Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf
    FwFreeArray(aFiliais)
Return aRetorno

/*/{Protheus.doc} buscaSerie
Realiza um "De Para" buscando o texto relativo ao código de status das OPs
@type Static Function
@author douglas.heydt
@since 02/05/2023
@version P12.1.2310
@param  cStatusOp , caracter, Código do status da ordem de produção
@return cDscStatus, caracter, Descrição do status da ordem de produção
/*/
Static Function buscaSerie(cStatusOp)
    Local cDscStatus := ""

    Do Case
        Case cStatusOp == "1"
            cDscStatus :=  "Prevista"
        Case cStatusOp == "2"
            cDscStatus := "Em aberto"
        Case cStatusOp == "3"
            cDscStatus := "Iniciada"
        Case cStatusOp == "4"
            cDscStatus := "Ociosa"
        Case cStatusOp == "5"
            cDscStatus := "Enc. Parcialmente"
        Case cStatusOp == "6"
            cDscStatus := "Enc. Totalmente"
    EndCase
Return cDscStatus
