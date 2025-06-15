#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITORDEF.CH"

/*/{Protheus.doc} StatusApontamentoHoras
Classe para prover os dados do Monitor de acompanhamento das horas apontadas no recurso
@type Class
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@return Nil
/*/
Class StatusApontamentoHoras FROM LongNameClass
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
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class StatusApontamentoHoras
    Local aPeriodos  := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
    Local aProdHr    := {}
    Local aImprodHr  := {}
    Local cRecursos  := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local nIndice    := 0
    Local nPosTag    := 0
    Local nTotCateg  := 0
    Local nTotPrdHr  := 0
    Local nTotImpHr  := 0
    Local oJsonRet   := JsonObject():New()
    Local oJsonTempo := Nil

    oJsonRet["alturaMinimaWidget"] := "350px"
    oJsonRet["alturaMaximaWidget"] := "500px"
    oJsonRet["categorias"] := {}
    oJsonRet["series"]     := {}
    oJsonRet["tags"]       := {}
    oJsonRet["detalhes"]   := {}
    
    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        If Empty(cRecursos)
            cRecursos := "'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        Else
            cRecursos +=  ",'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        EndIf
    Next nIndice
    dDataIni := aPeriodos[Len(aPeriodos)][1]
    dDataFin := aPeriodos[1][2]
    oJsonTempo := PCPMonitorUtils():CalculaTempoApontamentoOperacao(oFiltros["01_H6_FILIAL"],cRecursos,{dDataIni,dDataFin},.T.,oFiltros["04_TIPOPERIODO"],oFiltros["03_FILTRODATA"])
    oJsonRet["categorias"] := oJsonTempo:GetNames()
    nTotCateg := Len(oJsonTempo:GetNames())
    For nIndice := 1 To nTotCateg
        nTotPrdHr += oJsonTempo[oJsonRet["categorias"][nIndice]]["P"]
        nTotImpHr += oJsonTempo[oJsonRet["categorias"][nIndice]]["I"]
        aAdd(aProdHr,PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonTempo[oJsonRet["categorias"][nIndice]]["P"],2))
        aAdd(aImprodHr,PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(oJsonTempo[oJsonRet["categorias"][nIndice]]["I"],2))
    Next nIndice
    nTotPrdHr := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(nTotPrdHr,2)
    nTotImpHr := PCPMonitorUtils():TransformaMinutosCentesimaisParaTempo(nTotImpHr,2)

    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][1]["color"]   := COR_VERDE
    oJsonRet["series"][1]["data"]    := aClone(aProdHr)
    oJsonRet["series"][1]["tooltip"] := ""
    oJsonRet["series"][1]["label"]   := "Horas Produtivas"
    aAdd(oJsonRet["series"], JsonObject():New())
    oJsonRet["series"][2]["color"]   := COR_VERMELHO
    oJsonRet["series"][2]["data"]    := aClone(aImprodHr)
    oJsonRet["series"][2]["tooltip"] := ""
    oJsonRet["series"][2]["label"]   := "Horas Improdutivas"

    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"])
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-calendar"
    oJsonRet["tags"][nPosTag]["texto"]      := dToC(dDataIni) + " - " + dToC(dDataFin)
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-calculator"
    oJsonRet["tags"][nPosTag]["texto"]      := cTpPerDesc
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-star"
    oJsonRet["tags"][nPosTag]["texto"]      := "Horas Improdutivas: " + cValToChar(nTotImpHr) + " Horas"
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    aAdd(oJsonRet["tags"], JsonObject():New())
    nPosTag++
    oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-star-filled"
    oJsonRet["tags"][nPosTag]["texto"]      := "Horas Produtivas: " + cValToChar(nTotPrdHr) + " Horas"
    oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        aAdd(oJsonRet["tags"], JsonObject():New())
        nPosTag++
        oJsonRet["tags"][nPosTag]["icone"]      := "po-icon-manufacture"
        oJsonRet["tags"][nPosTag]["texto"]      := oFiltros["02_H6_RECURSO"][nIndice]
        oJsonRet["tags"][nPosTag]["colorTexto"] := ""
    Next nIndice

    FwFreeArray(aPeriodos)
    FwFreeArray(aProdHr)
    FwFreeArray(aImprodHr)
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
Method BuscaDetalhes(oFiltros, nPagina) Class StatusApontamentoHoras
    Local aPeriodos  := {}
    Local cAlias     := GetNextAlias()
    Local cCategoria := ""
    Local cQuery     := ""
    Local cRecursos  := ""
    Local cSerie     := ""
    Local cTempo     := ""
    Local cTpPerDesc := ""
    Local dDataIni   := dDatabase
    Local dDataFin   := dDatabase
    Local lExpResult := .F.
    Local oDados     := JsonObject():New()
    Local nIndice    := 0
    Local nPosCon    := 0
    Local nPosTag    := 0
    Local nStart     := 1
    Local nTamPagina := 20

    Default nPagina := 1

    If nPagina == 0
        lExpResult := .T.
    EndIf
    cCategoria := IIF(oFiltros:HasProperty("CATEGORIA"),oFiltros["CATEGORIA"],"")
    cSerie     :=  IIF(oFiltros:HasProperty("SERIE"),IF(oFiltros["SERIE"] == "Horas Produtivas","P","I"),"")
    If !Empty(cCategoria)
        dDataIni := cToD(cCategoria)
        dDataFin := PCPMonitorUtils():RetornaPeriodoFinal(oFiltros["04_TIPOPERIODO"],cToD(cCategoria))
    Else
        aPeriodos := PCPMonitorUtils():RetornaListaPeriodosPassado(oFiltros["04_TIPOPERIODO"],cValToChar(oFiltros["05_PERIODO"]))
        dDataIni := aPeriodos[Len(aPeriodos)][1]
        dDataFin := aPeriodos[1][2]
    EndIf
    oFiltros["01_H6_FILIAL"] := PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        If Empty(cRecursos)
            cRecursos := "'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        Else
            cRecursos +=  ",'" + oFiltros["02_H6_RECURSO"][nIndice] + "'"
        EndIf
    Next nIndice
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
    cQuery += "   AND SH6.H6_RECURSO IN ("+cRecursos+") "
    cQuery += "   AND (SH6."+AllTrim(oFiltros["03_FILTRODATA"])+" >= '"+dToS(dDataIni)+"' AND SH6."+AllTrim(oFiltros["03_FILTRODATA"])+" <= '"+dToS(dDataFin)+"') "
    If !Empty(cSerie)
        cQuery += "AND SH6.H6_TIPO = '" + cSerie + "' "
    EndIf
    cQuery += " ORDER BY SH6.H6_FILIAL,SH6.H6_RECURSO,SH6."+AllTrim(oFiltros["03_FILTRODATA"])+" "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPagina > 1
		nStart := ( (nPagina-1) * nTamPagina )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    cTpPerDesc := PCPMonitorUtils():RetornaDescricaoTipoPeriodo(oFiltros["04_TIPOPERIODO"])
    oDados["items"]   := {}
    oDados["columns"] := bscColunas(lExpResult,oFiltros["03_FILTRODATA"])
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
    For nIndice := 1 To Len(oFiltros["02_H6_RECURSO"])
        aAdd(oDados["tags"], JsonObject():New())
        nPosTag++
        oDados["tags"][nPosTag]["icone"]      := "po-icon-manufacture"
        oDados["tags"][nPosTag]["texto"]      := oFiltros["02_H6_RECURSO"][nIndice]
        oDados["tags"][nPosTag]["colorTexto"] := ""
    Next nIndice
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
Method CargaMonitor() Class StatusApontamentoHoras
    Local aCategr   := {}
    Local aDetalhes := {}
    Local aTags     := {}
    Local lRet      := .T.
    Local oCarga    := PCPMonitorCarga():New()
    Local oPrmAdc   := JsonObject():New()
    Local oSeries   := JsonObject():New()
        
    If !PCPMonitorCarga():monitorAtualizado("StatusApontamentoHoras")
        oSeries["Horas Produtivas"]   := {{5,6.75,8.5,6,7.5,8}, COR_VERDE }
        oSeries["Horas Improdutivas"] := {{2,3.5,1.75,1,0,1}, COR_VERMELHO }
        aCategr := {"16/04/23","23/04/23","30/04/23","07/05/23","14/05/23","21/05/23"}

        aTags   := {}
        aAdd(aTags, JsonObject():New())
        aTags[1]["texto"]      := "16/04/2023 - 28/05/2023"
        aTags[1]["colorTexto"] := ""
        aTags[1]["icone"]      := "po-icon-calendar"
        aAdd(aTags, JsonObject():New())
        aTags[2]["texto"]      := "Semanal"
        aTags[2]["colorTexto"] := ""
        aTags[2]["icone"]      := "po-icon-calculator"
        aAdd(aTags, JsonObject():New())
        aTags[3]["icone"]      := "po-icon-star"
        aTags[3]["texto"]      := "Horas Improdutivas: 54 Horas"
        aTags[3]["colorTexto"] := ""
        aAdd(aTags, JsonObject():New())
        aTags[4]["icone"]      := "po-icon-star-filled"
        aTags[4]["texto"]      := "Horas Produtivas: 54 Horas"
        aTags[4]["colorTexto"] := ""
        aAdd(aTags,JsonObject():New())
        aTags[5]["icone"]      := "po-icon-manufacture"
        aTags[5]["colorTexto"] := ""
        aTags[5]["texto"]      := "GUIL01"

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
        oPrmAdc["02_H6_RECURSO"]["selecaoMultipla"]             := .T.
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
        oPrmAdc["04_TIPOPERIODO"]["opcoes"]                     := "Diário:D;Semanal:S;Quinzenal:Q;Mensal:M"

        oCarga:setaTitulo("Acomp. Horas Apontadas")
        oCarga:setaObjetivo("Acompanhar a quantidade de horas apontadas no recurso em uma linha do tempo conforme o tipo de período parametrizado.")
        oCarga:setaAgrupador("PCP")
        oCarga:setaFuncaoNegocio("StatusApontamentoHoras")
        oCarga:setaTiposPermitidos("chart")
        oCarga:setaTiposGraficoPermitidos("line;column;bar")
        oCarga:setaTipoPadrao("chart")
        oCarga:setaTipoGraficoPadrao("line")
        oCarga:setaTipoDetalhe("detalhe")
        oCarga:setaExemploJsonGrafico(oSeries, aTags, aDetalhes,aCategr,"line")
        oCarga:setaPropriedade("01_H6_FILIAL","","Filial",7,GetSx3Cache("H6_FILIAL","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["01_H6_FILIAL"])
        oCarga:setaPropriedade("02_H6_RECURSO","","Recurso",8,GetSx3Cache("H6_RECURSO","X3_TAMANHO"),0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["02_H6_RECURSO"])
        oCarga:setaPropriedade("03_FILTRODATA","H6_DATAINI","Data de referência",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["03_FILTRODATA"])
        oCarga:setaPropriedade("04_TIPOPERIODO","D","Tipo Período",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,oPrmAdc["04_TIPOPERIODO"])
        oCarga:setaPropriedade("05_PERIODO","7","Quantidade Períodos",2,2,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")
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
Method ValidaPropriedades(oFiltros) Class StatusApontamentoHoras
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
			If !SH1->(dbSeek(xFilial("SH1",PadR(oFiltros["01_H6_FILIAL"], FWSizeFilial())) + PadR(oFiltros["02_H6_RECURSO"][1],GetSx3Cache("H6_RECURSO","X3_TAMANHO")), .F.))
                aRetorno[1] := .F.
                aRetorno[2] := "O Recurso não existe na Filial informada."
            EndIf
        EndIf
    EndIf
    If aRetorno[1] .And. Empty(oFiltros["05_PERIODO"])
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
