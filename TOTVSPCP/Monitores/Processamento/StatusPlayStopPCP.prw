#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusPlayStopPCP
Classe para prover os dados do Monitor de Apontamentos Cronômetro PCP
@type Class
@author renan.roeder
@since 09/02/2023
@version P12.1.2310
@return Nil
/*/
Class StatusPlayStopPCP FROM LongNameClass
	Static Method BuscaDados(oFiltros, cTipo, cSubTipo)
	Static Method BuscaDetalhes(oFiltros, nPagina)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)
EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do monitor no banco de dados, 
permitindo a exibição de um exemplo desse monitor para uso na aplicação.
@type Method
@author douglas.heydt
@since 13/03/2023
@version P12.1.2310
@return lRet, logico, Indica se a carga do Monitor foi realizada com sucesso.
/*/
Method CargaMonitor() Class StatusPlayStopPCP
    Local aDetalhes := {}
    Local aTags     := {}
    Local lRet      := .T.
    Local oCarga    := PCPMonitorCarga():New()
    Local oPrmAdc   := JsonObject():New()
    Local oSeries   := JsonObject():New()    
        
    If !PCPMonitorCarga():monitorAtualizado("StatusPlayStopPCP")
        oSeries["Produção"] := {{4,10}, COR_VERDE }
        oSeries["Pausa"]    := {{2,3 }, COR_VERMELHO }

        aTags := {}
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]      := "01/02/2023 - 28/02/2023"
        aTags[1]["colorTexto"] := ""
        aTags[1]["icone"]      := "po-icon-calendar"

        oPrmAdc["01_HZA_FILIAL"]                                := JsonObject():New()
        oPrmAdc["01_HZA_FILIAL"]["filtroServico"]               := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["01_HZA_FILIAL"]["parametrosServico"]           := JsonObject():New()
        oPrmAdc["01_HZA_FILIAL"]["parametrosServico"]["metodo"] := "PCPMonitorConsultas():BuscaFiliais"
        oPrmAdc["01_HZA_FILIAL"]["labelSelect"]                 := "Description"
        oPrmAdc["01_HZA_FILIAL"]["valorSelect"]                 := "Code"
        oPrmAdc["02_C2_PRODUTO"]                                := JsonObject():New()
        oPrmAdc["02_C2_PRODUTO"]["filtroServico"]               := "/api/pcp/v1/pcpmonitorapi/consulta"
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]           := JsonObject():New()
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]["filial"] := "${this.monitor.propriedades?.[0]?.valorPropriedade}"
        oPrmAdc["02_C2_PRODUTO"]["parametrosServico"]["metodo"] := "PCPMonitorConsultas():BuscaProdutos"
        oPrmAdc["02_C2_PRODUTO"]["selecaoMultipla"]             := .F.
        oPrmAdc["02_C2_PRODUTO"]["colunas"]                     := {}
        aAdd(oPrmAdc["02_C2_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_C2_PRODUTO"]["colunas"][1]["property"]  := "Code"
            oPrmAdc["02_C2_PRODUTO"]["colunas"][1]["label"]     := GetSx3Cache("B1_COD","X3_TITULO")
        aAdd(oPrmAdc["02_C2_PRODUTO"]["colunas"], JsonObject():New())
            oPrmAdc["02_C2_PRODUTO"]["colunas"][2]["property"]  := "Description"
            oPrmAdc["02_C2_PRODUTO"]["colunas"][2]["label"]     := GetSx3Cache("B1_DESC","X3_TITULO")
        oPrmAdc["02_C2_PRODUTO"]["labelSelect"]                 := "Code"
        oPrmAdc["02_C2_PRODUTO"]["valorSelect"]                 := "Code"
        oPrmAdc["04_TIPOPERIODO"]                               := JsonObject():New()
        oPrmAdc["04_TIPOPERIODO"]["opcoes"]                     := "Dia Atual:D;Semana Atual:S;Quinzena Atual:Q;Mês Atual:M;Personalizado:X"

        oCarga:setaTitulo("Acompanhamento Play/Stop PCP")
        oCarga:setaObjetivo("Acompanhar os números de apontamentos de produção e horas improdutivas que estão em andamento e que foram finalizados utilizando o Play/Stop do PCP, além de visualizar seus detalhes.")
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusPlayStopPCP")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("column;bar")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("column")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes, {"Em andamento","Concluída"},"column")
        oCarga:setaPropriedade("01_HZA_FILIAL","","Filial",7,GetSx3Cache("HZA_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["01_HZA_FILIAL"])
        oCarga:setaPropriedade("02_C2_PRODUTO","","Produto",8,GetSx3Cache("C2_PRODUTO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["02_C2_PRODUTO"])
        oCarga:setaPropriedade("03_HZA_OPERAD","","Operador",1,GetSx3Cache("HZA_OPERAD","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
        oCarga:setaPropriedade("04_TIPOPERIODO","D","Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_TIPOPERIODO"])
        oCarga:setaPropriedade("05_PERIODO","0","Período Personalizado (Dias)",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
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
@type Method
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param	oFiltros  , objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param	cTipo     , caracter, Tipo chart/info
@param	cSubTipo  , caracter, Tipo de grafico pie/bar/column
@return cJsonDados, caracter, Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusPlayStopPCP
    Local aFiltros   := {}
    Local cAliasQry  := GetNextAlias()
    Local cQuery     := ""
    Local cStatus    := ""
    Local dFilterDat
    Local nX         := 0
    Local nPosTags   := 0
    Local oDados     := JsonObject():New()
    Local oJsonRet   := JsonObject():New()

    oDados["andamento"] := JsonObject():New()
    oDados["concluida"] := JsonObject():New()
    oDados["andamento"]["producao"] := 0
    oDados["andamento"]["pausa"]    := 0
    oDados["concluida"]["producao"] := 0
    oDados["concluida"]["pausa"]    := 0

    //oJsonRet["titulo"]     := ""
    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {"Em andamento","Concluída"}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}

    cQuery +="  SELECT CASE "
    cQuery +="         WHEN HZA_STATUS = '1' AND HZA_TPTRNS = '1' THEN 'PROD-EM-ANDAMENTO' "
    cQuery +="         WHEN HZA_STATUS = '1' AND HZA_TPTRNS = '2' THEN 'PAUSA-EM-ANDAMENTO' "
    cQuery +="         WHEN HZA_STATUS = '2' AND HZA_TPTRNS = '1' THEN 'PROD-CONCLUIDA' "
    cQuery +="         WHEN HZA_STATUS = '2' AND HZA_TPTRNS = '2' THEN 'PAUSA-CONCLUIDA' "
    cQuery +="         ELSE ' ' "
    cQuery +="     END AS STATUS, "
    cQuery += " COUNT(*) AS REGS "
    cQuery += " FROM "+RetSqlName("HZA")+" HZA "
    cQuery += " INNER JOIN "+RetSqlName("SC2")+" SC2 "
    cQuery += "   ON (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD) = HZA.HZA_OP AND SC2.D_E_L_E_T_ = ' '"
    cQuery += "WHERE HZA_STATUS IN ('1','2') AND "

    If !Empty(oFiltros["01_HZA_FILIAL"])
        aAdd(aFiltros, "HZA.HZA_FILIAL" +" = '"+ oFiltros["01_HZA_FILIAL"]+"' ")
    EndIf
    If !Empty(oFiltros["02_C2_PRODUTO"])
        aAdd(aFiltros, "SC2.C2_PRODUTO" +" = '"+ oFiltros["02_C2_PRODUTO"]+"' ")
    EndIf
    dFilterDat := PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],ddatabase,cValtoChar(oFiltros["05_PERIODO"]))
    aAdd(aFiltros, '( HZA_DTINI BETWEEN '+DTOS(dFilterDat)+' AND '+ DTOS(ddatabase)+')')
    If !Empty(oFiltros["03_HZA_OPERAD"])
        aAdd(aFiltros, "HZA_OPERAD" +" = '"+ oFiltros["03_HZA_OPERAD"]+"' ")
    EndIf
    If !Empty(aFiltros)
        For nX := 1 To Len(aFiltros)
            cQuery += aFiltros[nX] + " AND "
        Next nX
    EndIf
    cQuery += " HZA.D_E_L_E_T_ = ' ' "
    cQuery += "  GROUP BY HZA_TPTRNS, HZA_STATUS "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	While (cAliasQry)->(!Eof())
        cStatus := Alltrim((cAliasQry)->STATUS)
        Do Case
            Case  cStatus == "PROD-EM-ANDAMENTO"
                oDAdos["andamento"]["producao"] := (cAliasQry)->REGS
            Case  cStatus == "PAUSA-EM-ANDAMENTO"
                oDAdos["andamento"]["pausa"]    := (cAliasQry)->REGS
            Case  cStatus == "PROD-CONCLUIDA"
                oDAdos["concluida"]["producao"] := (cAliasQry)->REGS
            Case  cStatus == "PAUSA-CONCLUIDA"
                oDAdos["concluida"]["pausa"]    := (cAliasQry)->REGS
        EndCase
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())
    
    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_VERDE
    oJsonRet["series"][1]["data"]    := {oDados["andamento"]["producao"],oDados["concluida"]["producao"]}
    oJsonRet["series"][1]["tooltip"] := ""
    oJsonRet["series"][1]["label"]   := "Produção"
    aAdd(oJsonRet["series"], JsonObject():New())	
    oJsonRet["series"][2]["color"]   := COR_VERMELHO
    oJsonRet["series"][2]["data"]    := {oDados["andamento"]["pausa"],oDados["concluida"]["pausa"]}
    oJsonRet["series"][2]["tooltip"] := ""
    oJsonRet["series"][2]["label"]   := "Pausa"
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTags++
    oJsonRet["tags"][nPosTags]["icone"]     := "po-icon-calendar"
    oJsonRet["tags"][nPosTags]["texto"]     := cValToChar(dFilterDat)+" - "+cValToChar(dDatabase)
    oJsonRet["tags"][nPosTags]["colorTexto"] := ""

    If !Empty(oFiltros["02_C2_PRODUTO"])
        aAdd(oJsonRet["tags"],JsonObject():New())
        nPosTags++
        oJsonRet["tags"][nPosTags]["icone"]      := "po-icon-bar-code"
        oJsonRet["tags"][nPosTags]["colorTexto"] := ""
        oJsonRet["tags"][nPosTags]["texto"]      := oFiltros["02_C2_PRODUTO"]
    EndIf
    If !Empty(oFiltros["03_HZA_OPERAD"])
        aAdd(oJsonRet["tags"],JsonObject():New())
        nPosTags++
        oJsonRet["tags"][nPosTags]["icone"]      := "po-icon-user"
        oJsonRet["tags"][nPosTags]["colorTexto"] := ""
        oJsonRet["tags"][nPosTags]["texto"]      := oFiltros["03_HZA_OPERAD"]
    EndIf

    FwFreeArray(aFiltros)
    FreeObj(oDados)
Return oJsonRet:ToJson()

/*/{Protheus.doc} BuscaDetalhes
Responsável por realizar a busca dos dados que serão exibidos no detalhamento do monitor
@type Method
@author douglas.heydt
@since 13/03/2023
@version P12.1.2310
@param	oFiltros  , objeto   , Contém as propriedades do monitor usadas para filtrar a query de busca
@param	nPagina   , numerico , Número da página desejada para busca
@return cJsonDados, caracter , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDetalhes(oFiltros, nPagina) Class StatusPlayStopPCP
    Local aFiltros   := {}
    Local cAliasQry  := GetNextAlias()
    Local cSerie     := ""
    Local cCateg     := ""
    Local cFiltStat  := ""
    Local cJsonDados := ""
	Local cQuery     := ""
    Local dFilterDat
    Local lExpResult := .F.
	Local nPos       := 0
    Local nPosTags   := 0
    Local nStart     := 0    
    Local nX         := 0
	Local oDados     := JsonObject():New()

    Default nPagina := 1
    Default nPageSize := 20

    If nPagina == 0
        lExpResult := .T.
    EndIf

    cSerie := IIF(oFiltros:HasProperty("SERIE"),oFiltros["SERIE"],"")
    cCateg := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    cFiltStat := getStatus(cSerie, cCateg)
    cQuery += " SELECT HZA.HZA_FILIAL,HZA.HZA_OP,HZA.HZA_OPERAC,HZA.HZA_OPERAD, "
    cQuery += "        HZA.HZA_DTINI,HZA.HZA_HRINI,HZA.HZA_DTFIM,HZA.HZA_HRFIM, "
    cQuery += "        HZA.HZA_FORM,HZA.HZA_IDAPON,HZA.HZA_RECUR, "
    cQuery += "        CASE "
    cQuery += "          WHEN HZA.HZA_STATUS = '1' AND HZA.HZA_TPTRNS = '1' THEN 'PROD-EM-ANDAMENTO' "
    cQuery += "          WHEN HZA.HZA_STATUS = '1' AND HZA.HZA_TPTRNS = '2' THEN 'PAUSA-EM-ANDAMENTO' "
    cQuery += "          WHEN HZA.HZA_STATUS = '2' AND HZA.HZA_TPTRNS = '1' THEN 'PROD-CONCLUIDA' "
    cQuery += "          WHEN HZA.HZA_STATUS = '2' AND HZA.HZA_TPTRNS = '2' THEN 'PAUSA-CONCLUIDA' "
    cQuery += "          ELSE ' ' "
    cQuery += "        END AS STATUS, "
    cQuery += "        SC2.C2_PRODUTO, SB1.B1_DESC, SB1.B1_OPERPAD, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ROTEIRO, "
    cQuery += "        SH6.H6_PRODUTO, SH6.H6_LOCAL, SH6.H6_IDENT, SH6.H6_QTDPERD, SH6.H6_TEMPO, SH6.H6_MOTIVO, SH6.H6_QTDPROD, SH6.H6_RECURSO, SH6.H6_OPERAC "
    cQuery += " FROM "+RetSqlName("HZA")+" HZA " 
    cQuery += " INNER JOIN "+RetSqlName("SC2")+" SC2 "
    cQuery += "   ON (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD) = HZA.HZA_OP AND SC2.D_E_L_E_T_ = ' '"
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SC2.C2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN "+RetSqlName("SH6")+" SH6 ON (SH6.H6_FILIAL+SH6.H6_PRODUTO+SH6.H6_LOCAL+SH6.H6_IDENT) = HZA.HZA_IDAPON "
    cQuery += " AND SH6.D_E_L_E_T_ = ' ' "

    aAdd(aFiltros, "HZA_FILIAL" +" = '"+ oFiltros["01_HZA_FILIAL"]+"' ")
    If !Empty(oFiltros["02_C2_PRODUTO"])
        aAdd(aFiltros, "C2_PRODUTO" +" = '"+ oFiltros["02_C2_PRODUTO"]+"' ")
    EndIf
    dFilterDat := PCPMonitorUtils():RetornaPeriodoInicial(oFiltros["04_TIPOPERIODO"],ddatabase,cValtoChar(oFiltros["05_PERIODO"]))
    aAdd(aFiltros, '( HZA_DTINI BETWEEN '+DTOS(dFilterDat)+' AND '+ DTOS(ddatabase)+')')
    If !Empty(oFiltros["03_HZA_OPERAD"])
        aAdd(aFiltros, "HZA_OPERAD" +" = '"+ oFiltros["03_HZA_OPERAD"]+"' ")
    EndIF
    If !Empty(cFiltStat)
        aAdd(aFiltros, cFiltStat)
    EndIF
    cQuery += "WHERE HZA_STATUS IN ('1','2') AND "
    If !Empty(aFiltros)
        For nX := 1 To Len(aFiltros)
            cQuery += aFiltros[nX] + " AND "
        Next nX
    EndIf
    cQuery += " HZA.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY HZA.HZA_FILIAL, HZA.HZA_DTINI, HZA.HZA_HRINI "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

    oDados["items"]        := {}
    oDados["columns"]      := montaColun(lExpResult)
    oDados["headers"]      := {}
    oDados["canExportCSV"] := .T.

    oDados["tags"] := {}
    aAdd(oDados["tags"],JsonObject():New())
    nPosTags++
    oDados["tags"][nPosTags]["icone"]      := "po-icon-calendar"
    oDados["tags"][nPosTags]["colorTexto"] := ""
    oDados["tags"][nPosTags]["texto"]      := cValToChar(dFilterDat)+" - "+cValToChar(dDatabase)

    If !Empty(oFiltros["02_C2_PRODUTO"])
        aAdd(oDados["tags"],JsonObject():New())
        nPosTags++
        oDados["tags"][nPosTags]["icone"]      := "po-icon-bar-code"
        oDados["tags"][nPosTags]["colorTexto"] := ""
        oDados["tags"][nPosTags]["texto"]      := oFiltros["02_C2_PRODUTO"]
    EndIf
    If !Empty(oFiltros["03_HZA_OPERAD"])
        aAdd(oDados["tags"],JsonObject():New())
        nPosTags++
        oDados["tags"][nPosTags]["icone"]      := "po-icon-user"
        oDados["tags"][nPosTags]["colorTexto"] := ""
        oDados["tags"][nPosTags]["texto"]      := oFiltros["03_HZA_OPERAD"]
    EndIF
    If !Empty(cFiltStat)
        aAdd(oDados["tags"],JsonObject():New())
        nPosTags++
        oDados["tags"][nPosTags]["icone"]      := "po-icon-filter"
        oDados["tags"][nPosTags]["colorTexto"] := ""
        oDados["tags"][nPosTags]["texto"]      := cSerie+" "+cCateg
    EndIF

     If nPagina > 1
		nStart := ( (nPagina-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf
	nPos := 0
    While (cAliasQry)->(!Eof())
        aAdd(oDados["items"], JsonObject():New())
        nPos++
        cRoteiro := IIF(!Empty((cAliasQry)->C2_ROTEIRO),(cAliasQry)->C2_ROTEIRO,IIF(!Empty((cAliasQry)->B1_OPERPAD),(cAliasQry)->B1_OPERPAD,"01"))
        oDados["items"][nPos]["HZA_FILIAL"] := (cAliasQry)->HZA_FILIAL
        oDados["items"][nPos]["HZA_OP"]     := (cAliasQry)->HZA_OP
        oDados["items"][nPos]["HZA_OPERAC"] := (cAliasQry)->HZA_OPERAC
        oDados["items"][nPos]["G2_DESCRI"]  := AllTrim(Posicione("SG2",1,xFilial("SG2",PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial()))+(cAliasQry)->C2_PRODUTO+cRoteiro+(cAliasQry)->HZA_OPERAC,"G2_DESCRI"))
        oDados["items"][nPos]["C2_PRODUTO"] := (cAliasQry)->C2_PRODUTO
        oDados["items"][nPos]["B1_DESC"]    := (cAliasQry)->B1_DESC
        oDados["items"][nPos]["HZA_OPERAD"] := UsrRetName((cAliasQry)->HZA_OPERAD)
        oDados["items"][nPos]["HZA_DTINI"]  := PCPMonitorUtils():FormataData((cAliasQry)->HZA_DTINI, 5)
        oDados["items"][nPos]["HZA_HRINI"]  := (cAliasQry)->HZA_HRINI 
        oDados["items"][nPos]["HZA_DTFIM"]  := PCPMonitorUtils():FormataData((cAliasQry)->HZA_DTFIM, 5)
        oDados["items"][nPos]["HZA_HRFIM"]  := (cAliasQry)->HZA_HRFIM
        oDados["items"][nPos]["RECURSO"]    := Iif(Empty((cAliasQry)->H6_RECURSO), (cAliasQry)->HZA_RECUR, (cAliasQry)->H6_RECURSO )  
        oDados["items"][nPos]["H1_DESCRI"]  := AllTrim(Posicione("SH1",1,xFilial("SH1",PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial()))+oDados["items"][nPos]["RECURSO"],"H1_DESCRI"))
        oDados["items"][nPos]["HZA_FORM"]   := (cAliasQry)->HZA_FORM
        oDados["items"][nPos]["H6_QTDPROD"] := (cAliasQry)->H6_QTDPROD
        oDados["items"][nPos]["H6_QTDPERD"] := (cAliasQry)->H6_QTDPERD
        oDados["items"][nPos]["H6_TEMPO"]   := (cAliasQry)->H6_TEMPO
        oDados["items"][nPos]["H6_MOTIVO"]  := (cAliasQry)->H6_MOTIVO
        oDados["items"][nPos]["CYN_DSSP"]   := AllTrim(Posicione("CYN",1,xFilial("CYN",PadR(oFiltros["01_HZA_FILIAL"], FWSizeFilial()))+(cAliasQry)->H6_MOTIVO, "CYN_DSSP"))
        oDados["items"][nPos]["STATUS"]     := Alltrim((cAliasQry)->STATUS)
		(cAliasQry)->(dbSkip())
        //Verifica tamanho da página
		If !lExpResult .And. nPos >= nPageSize
			Exit
		EndIf
	End
    oDados["hasNext"] := (cAliasQry)->(!Eof())
    (cAliasQry)->(dbCloseArea())
	cJsonDados :=  oDados:toJson()
    FwFreeArray(aFiltros)
    FreeObj(oDados)
Return cJsonDados

/*/{Protheus.doc} montaColun
Realiza a criação de objeto Json que define as colunas utilizadas na grid de detalhamento do monitor

@type Static Function
@author douglas.heydt
@since 09/02/2023
@version P12.1.2310
@param  lExpResult, logico, Indica se trata todas as colunas como visible
@return oColumns, objeto Json, Contém as definições das colunas da grid do monitor
/*/
Static Function montaColun(lExpResult) 
    Local aColumns := {}
    Local nPos := 0

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "STATUS"
    aColumns[nPos]["label"]    := "Tipo"
    aColumns[nPos]["type"]     := "cellTemplate"
    aColumns[nPos]["width"]    := "120px"
    aColumns[nPos]["labels"]   := {}
    aColumns[nPos]["visible"]  := lExpResult
        aAdd(aColumns[nPos]["labels"], JsonObject():New())
        aColumns[nPos]["labels"][1]["value"] := "PROD-EM-ANDAMENTO"
        aColumns[nPos]["labels"][1]["color"] := COR_VERDE
        aColumns[nPos]["labels"][1]["label"] := 'Prod. em and.'
        aColumns[nPos]["labels"][1]["textColor"] := COR_BRANCO

        aAdd(aColumns[nPos]["labels"], JsonObject():New())
        aColumns[nPos]["labels"][2]["value"] := 'PAUSA-EM-ANDAMENTO'
        aColumns[nPos]["labels"][2]["color"] := COR_VERMELHO
        aColumns[nPos]["labels"][2]["label"] := 'Pausa em and.'
        aColumns[nPos]["labels"][2]["textColor"] := COR_BRANCO

        aAdd(aColumns[nPos]["labels"], JsonObject():New())
        aColumns[nPos]["labels"][3]["value"] := 'PROD-CONCLUIDA'
        aColumns[nPos]["labels"][3]["color"] := COR_VERDE
        aColumns[nPos]["labels"][3]["label"] := 'Prod. concluída'
        aColumns[nPos]["labels"][3]["textColor"] := COR_BRANCO

        aAdd(aColumns[nPos]["labels"], JsonObject():New())
        aColumns[nPos]["labels"][4]["value"] := 'PAUSA-CONCLUIDA'
        aColumns[nPos]["labels"][4]["color"] := COR_VERMELHO
        aColumns[nPos]["labels"][4]["label"] := 'Pausa concluída'
        aColumns[nPos]["labels"][4]["textColor"] := COR_BRANCO
    aColumns[nPos]["visible"]  := .T.

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_FILIAL"
    aColumns[nPos]["label"]    := "Filial"
    aColumns[nPos]["type"]     := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_OP"
    aColumns[nPos]["label"]   := "OP"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_OPERAC"
    aColumns[nPos]["label"]   := "Operação"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "G2_DESCRI"
    aColumns[nPos]["label"]   := "Desc. Operação"
    aColumns[nPos]["type"]   := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "C2_PRODUTO"
    aColumns[nPos]["label"]   := "Produto"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "B1_DESC"
    aColumns[nPos]["label"]   := "Desc. Produto"
    aColumns[nPos]["type"]   := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_OPERAD"
    aColumns[nPos]["label"]   := "Operador"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_DTINI"
    aColumns[nPos]["label"]   := "Data Inicial"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_HRINI"
    aColumns[nPos]["label"]   := "Hora Inicial"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_DTFIM"
    aColumns[nPos]["label"]   := "Data Final"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_HRFIM"
    aColumns[nPos]["label"]   := "Hora Final"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "H6_QTDPROD"
    aColumns[nPos]["label"]   := "Produção"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "H6_QTDPERD"
    aColumns[nPos]["label"]   := "Perda"
    aColumns[nPos]["type"]   := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "H6_TEMPO"
    aColumns[nPos]["label"]   := "Tempo real"
    aColumns[nPos]["type"]   := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "HZA_FORM"
    aColumns[nPos]["label"]   := "Formulário"
    aColumns[nPos]["type"]   := "string"
    aColumns[nPos]["visible"]  := lExpResult

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "RECURSO"
    aColumns[nPos]["label"]   := "Recurso"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "H1_DESCRI"
    aColumns[nPos]["label"]   := "Desc. Recurso"
    aColumns[nPos]["type"]   := "string"
    aColumns[nPos]["visible"]  := lExpResult
    
    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "H6_MOTIVO"
    aColumns[nPos]["label"]   := "Motivo"
    aColumns[nPos]["type"]   := "string"

    aAdd(aColumns, JsonObject():New())
    nPos++
    aColumns[nPos]["property"] := "CYN_DSSP"
    aColumns[nPos]["label"]   := "Desc. motivo"
    aColumns[nPos]["type"]   := "string"
    aColumns[nPos]["visible"]  := lExpResult
Return aColumns

/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class StatusPlayStopPCP
    Local aFiliais := FWLoadSM0()
    Local aRetorno := {.T.,""}
    Local nFilSeg  := 0

    If Empty(oFiltros["01_HZA_FILIAL"])
        aRetorno[1] := .F.
        aRetorno[2] := "O filtro de Filial deve ser preenchido."
    Else
        nFilSeg := aScan(aFiliais, {|x| x[1] == cEmpAnt .And. AllTrim(x[2]) == AllTrim(oFiltros["01_HZA_FILIAL"]) } )
        If nFilSeg > 0
            If !aFiliais[nFilSeg][11]
                aRetorno[1] := .F.
                aRetorno[2] := "Usuário não tem permissão na filial "+oFiltros["01_HZA_FILIAL"]+"."
            EndIf
        Else
            aRetorno[1] := .F.
            aRetorno[2] := "Preencha uma Filial válida para a consulta."
        EndIf
    EndIf

    If aRetorno[1] .And. oFiltros["04_TIPOPERIODO"] == "X"
        If !oFiltros:HasProperty("05_PERIODO") .Or. oFiltros["05_PERIODO"] == Nil .Or. Empty(oFiltros["05_PERIODO"])
            aRetorno[1] := .F.
            aRetorno[2] := "Deve ser informada a quantidade de dias para o período personalizado."
        EndIf
    EndIf
    FwFreeArray(aFiliais)
Return aRetorno

/*/{Protheus.doc} getStatus
Cria o filtro de serie e categoria quando o usuario clica no gráfico
@type Method
@author douglas.heydt
@since 24/04/2023
@version P12.1.2310
@param  cSerie, caracter , Serie clicada no gráfico
@param  cCateg, caracter , Categoria clicada no gráfico
@return cFiltro, caracter, Filtro que será usado na query
/*/
Static Function getStatus(cSerie, cCateg)
    Local cFiltro := ""

    If cCateg == "Em andamento"
        If cSerie == "Pausa"
           cFiltro := " HZA.HZA_STATUS = '1' AND HZA.HZA_TPTRNS = '2' "
        Else
            cFiltro :=  " HZA.HZA_STATUS = '1' AND HZA.HZA_TPTRNS = '1' " 
        EndIf
    ElseIf cCateg == "Concluída"
        If cSerie == "Pausa"
           cFiltro := " HZA.HZA_STATUS = '2' AND HZA.HZA_TPTRNS = '2' "
        Else
            cFiltro :=  " HZA.HZA_STATUS = '2' AND HZA.HZA_TPTRNS = '1' "
        EndIf
    EndIF
Return cFiltro
