#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PCPMonitorUtils
Classe com os métodos para consultas dos dados nas propriedades do Monitor
@type Class
@author renan.roeder
@since 26/04/2023
@version P12.1.2310
@return Nil
/*/
Class PCPMonitorUtils FROM LongNameClass
    Static Method CalculaTempoApontamentoOperacao(cFilFlt,cRecursos,aPeriodo,lDtAgrup,cTpAgrup,cDatRef)
    Static Method FormataData(xData, nTipo)
    Static Method BuscaPeriodoAnterior(cTipo,dData)
    Static Method BuscaProximoPeriodo(cTipo,dData)
    Static Method RetornaDescricaoTipoPeriodo(cTpPeriodo)
    Static Method RetornaDescricaoRecurso(cCodFilial,cCodRecur)
    Static Method RetornaPeriodoInicial(cTipo,dDataFim,cDias)
    Static Method RetornaPeriodoFinal(cTipo,dDataIni,cDias)
    Static Method RetornaListaPeriodosPassado(cTipo,cPeriodos)
    Static Method RetornaListaPeriodosFuturo(cTipo,cPeriodos)
    Static Method RetornaQuantidadesProducaoProduto(cFilFlt,cProduto,dDataIni,dDataFin,lDtAgrup,cTpAgrup)
    Static Method TransformaTempoParaMinutosCentesimais(cTempo,nTipoTempo)
    Static Method TransformaMinutosCentesimaisParaTempo(nMinCent,nTipoTempo)
EndClass

/*/{Protheus.doc} CalculaTempoApontamentoOperacao
Calcula o tempo total de apontamento num período
@type Method
@author renan.roeder
@since 17/05/2023
@version P12.1.2310
@param  cFilFlt   , caracter   , Filial do filtro
@param  cRecursos , caracter   , Codigo dos recursos separado por virgula
@param  aPeriodo  , array      , array com período inicial e final
@param  lDtAgrup  , logico     , define se agrupa os apontamentos por período
@param  cTpAgrup  , caracter   , tipo de período para agrupamento
@param  cDataRef  , caracter   , data de referência para filtro da query
@return oJsonTempo, objeto json, Objeto json com os apontamentos dos períodos
/*/
Method CalculaTempoApontamentoOperacao(cFilFlt,cRecursos,aPeriodo,lDtAgrup,cTpAgrup,cDataRef) Class PCPMonitorUtils
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local cDataAjust := dToC(dDatabase)
    Local nTempAjust := 0
    Local oJsonTempo := JsonObject():New()

    If !lDtAgrup
        oJsonTempo[cDataAjust] := JsonObject():New()
        oJsonTempo[cDataAjust]["P"] := 0
        oJsonTempo[cDataAjust]["I"] := 0
    EndIf
    cQuery := " SELECT SH6.H6_TIPO TIPO,SH6.H6_TEMPO TEMPO,SH6.H6_TIPOTEM TIPO_TEMPO,SH6."+cDataRef+" DATA_FILTRO "
    cQuery += " FROM "+RetSqlName("SH6")+" SH6 "
    cQuery += " WHERE SH6.D_E_L_E_T_ = ' ' "
    cQuery += "   AND SH6.H6_FILIAL = '" + xFilial("SH6",cFilFlt) + "' "
    cQuery += "   AND SH6.H6_RECURSO IN ("+cRecursos+") "
    cQuery += "   AND (SH6."+cDataRef+" >= '"+dToS(aPeriodo[1])+"' AND SH6."+cDataRef+" <= '"+dToS(aPeriodo[2])+"') "
    cQuery += " ORDER BY SH6.H6_FILIAL,SH6."+cDataRef+" "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    While (cAlias)->(!Eof()) 
        If lDtAgrup
            cDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(cTpAgrup,sToD((cAlias)->DATA_FILTRO)))
            If !oJsonTempo:HasProperty(cDataAjust)
                oJsonTempo[cDataAjust] := JsonObject():New()
                oJsonTempo[cDataAjust]["P"] := 0
                oJsonTempo[cDataAjust]["I"] := 0
            EndIf
        EndIf
        nTempAjust := PCPMonitorUtils():TransformaTempoParaMinutosCentesimais((cAlias)->TEMPO,(cAlias)->TIPO_TEMPO)
        oJsonTempo[cDataAjust][(cAlias)->TIPO] += nTempAjust
        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

Return oJsonTempo

/*/{Protheus.doc} FormataData
Formata a data conforme o tipo definido
@type  Method
@author douglas.heydt
@since 13/03/2023
@version P12.1.2310
@param cData, Date   , Data que será convertida
@param nTipo, numeral, tipo de conversão executada
		1 - date para DD/MM/AAAA
		2 - AAAA-MM-DD para AAAAMMDD
		3 - AAAA-MM-DD para DD/MM/AAAA
		4 - AAAAMMDD para AAAA-MM-DD
        5 - AAAAMMDD para DD/MM/AAAA
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Method FormataData(xData, nTipo) Class PCPMonitorUtils

	If !Empty(xData)
		If nTipo == 1
			xData := StrZero(Day(xData),2) + "/" + StrZero(Month(xData),2) + "/" +  StrZero(Year(xData),4)
		ElseIf nTipo == 2
			xData := StrTran(xData, "-", "")
		ElseIf nTipo == 3
			xData := StrTran(xData, "-", "")
			xData := SUBSTR(xData, 7, 2)  + "/" + SUBSTR(xData, 5, 2)  + "/" +  SUBSTR(xData, 0, 4)
		ElseIf nTipo == 4
			xData := SUBSTR(xData, 0, 4) +"-"+ SUBSTR(xData, 5, 2)+"-"+SUBSTR(xData, 7, 2)
        ElseIf nTipo == 5
            xData := SUBSTR(xData, 7, 2) +"/"+SUBSTR(xData, 5, 2) +"/"+SUBSTR(xData, 0, 4)
		EndIf
	EndIf
Return xData

/*/{Protheus.doc} BuscaPeriodoAnterior
Busca a data de inicio do período anterior
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param	cTipo, caracter, Tipo do período (D,S,Q,M)
@param	dData, data    , Data base para o cálculo
@return Nil
/*/
Method BuscaPeriodoAnterior(cTipo,dData) Class PCPMonitorUtils
    Do Case
        Case cTipo == "D"
            dData--
        Case cTipo == "S"
            dData -= 7
            While Dow(dData) > 1
                dData--
            End
        Case cTipo == "Q"
            If Day(dData) < 15
                dData := FirstDate(MonthSub(dData,1)) + 15
            Else
                dData := FirstDate(dData,1)
            EndIf
        Case cTipo == "M"
            dData := FirstDate(MonthSub(dData,1))
    EndCase
Return

/*/{Protheus.doc} BuscaProximoPeriodo
Busca a data de inicio do próximo período
@type Method
@author douglas.heydt
@since 08/05/2023
@version P12.1.2310
@param	cTipo, caracter, Tipo do período (D,S,Q,M)
@param	dData, data    , Data base para o cálculo
@return Nil
/*/
Method BuscaProximoPeriodo(cTipo,dData) Class PCPMonitorUtils
    Do Case
        Case cTipo == "D"
            dData++
        Case cTipo == "S"
            dData += 7
            While Dow(dData) > 1
                dData--
            End
        Case cTipo == "Q"
            If Day(dData) < 15
                dData := FirstDate(dData,1) + 15
            Else
                dData := FirstDate(MonthSum(dData,1))
            EndIf
        Case cTipo == "M"
            dData := FirstDate(MonthSum(dData,1))
    EndCase
Return

/*/{Protheus.doc} RetornaDescricaoTipoPeriodo
Retorna a descrição do tipo de período
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param	cTpPeriodo, caracter, Tipo do período (D,S,Q,M)
@return cTpPerDesc, caracter, Descrição do tipo de período
/*/
Method RetornaDescricaoTipoPeriodo(cTpPeriodo) Class PCPMonitorUtils
    Local cTpPerDesc := ""

    Do Case
            Case cTpPeriodo == "D"
                cTpPerDesc := "Diário"
            Case cTpPeriodo == "S"
                cTpPerDesc := "Semanal"
            Case cTpPeriodo == "Q"
                cTpPerDesc := "Quinzenal"
            Case cTpPeriodo == "M"
                cTpPerDesc := "Mensal"
    End Case
Return cTpPerDesc

/*/{Protheus.doc} RetornaDescricaoRecurso
Retorna a descrição do recurso
@type Method
@author renan.roeder
@since 09/05/2023
@version P12.1.2310
@param	cCodFilial, caracter, Codigo Filial
@param	cCodRecur , caracter, Codigo Recurso
@return cDscRecur , caracter, Descricao Recurso
/*/
Method RetornaDescricaoRecurso(cCodFilial,cCodRecur) Class PCPMonitorUtils
    Local cDscRecur := AllTrim(Posicione("SH1",1,xFilial("SH1",cCodFilial)+cCodRecur,"H1_DESCRI"))
Return cDscRecur

/*/{Protheus.doc} RetornaPeriodoInicial
Calcula a data inicial do período da consulta conforme a data final e o tipo do período
@type Method
@author renan.roeder
@since 10/03/2023
@version P12.1.2310
@param	cTipo   , caracter, Tipo do período
@param	dDataFim, data    , Data final que por padrão é a database do sistema
@param	cDias   , caracter, Quantidade de dias quando o período for personalizado
@return dDataIni, data    , Data inicial calculada conforme a data final e o tipo
/*/
Method RetornaPeriodoInicial(cTipo,dDataFim,cDias) Class PCPMonitorUtils
    Local dDataIni := dDataFim

    Default cTipo := "D", dDataFim = dDatabase, cDias := "0"

    Do Case
        Case cTipo == "D"
            dDataIni := dDataFim
        Case cTipo == "S"
            While Dow(dDataIni) > 1
                dDataIni--
            End
        Case cTipo == "Q"
            If Day(dDataFim) < 15
                dDataIni := FirstDate(dDataFim)
            Else
                dDataIni := FirstDate(dDataFim) + 14
            EndIf        
        Case cTipo == "M"
            dDataIni := FirstDate(dDataFim)
        Case cTipo == "X"
            dDataIni := dDataIni - Val(cDias)
    End Case
Return dDataIni

/*/{Protheus.doc} RetornaPeriodoFinal
Calcula a data final do período da consulta conforme a data atual e o tipo do período
@type Method
@author douglas.heydt
@since 10/04/2023
@version P12.1.2310
@param  cTipo   , caracter, Tipo do período
@param  dDataIni, data    , Data inicial que por padrão é a database do sistema
@param  cDias   , caracter, Quantidade de dias quando o período for personalizado
@return dDataFim, data    , Data final calculada conforme a data final e o tipo
/*/
Method RetornaPeriodoFinal(cTipo,dDataIni,cDias) Class PCPMonitorUtils
    Local dDataFim := dDataIni

    Default cTipo := "D", dDataIni = dDatabase, cDias := "0"

    Do Case
        Case cTipo == "D"
           dDataFim :=  dDataIni
        Case cTipo == "S"
            While Dow(dDataFim) < 7
                dDataFim++
            End
        Case cTipo == "Q"
            If Day(dDataIni) < 15
                dDataFim := FirstDate(dDataIni)+14
            Else
                dDataFim := LastDate(dDataIni)
            EndIf        
        Case cTipo == "M"
            dDataFim := LastDate(dDataIni)
        Case cTipo == "X"
            dDataFim := dDataFim + Val(cDias)
    End Case
Return dDataFim

/*/{Protheus.doc} RetornaListaPeriodosPassado
Retorna um array com os períodos calculados conforme o tipo
@type Method
@author renan.roeder
@since 08/05/2023
@version P12.1.2310
@param	cTipo     , caracter, Tipo do período (D,S,Q,M)
@param	cPeriodos , caracter, Quantidade de períodos
@return aPeriodos , array   , Array com os períodos gerados
/*/
Method RetornaListaPeriodosPassado(cTipo,cPeriodos) Class PCPMonitorUtils
    Local aPeriodos := {}
    Local nPeriodos := Val(cPeriodos)
    Local nIndex    := 0
    Local dData     := PCPMonitorUtils():RetornaPeriodoInicial(cTipo,dDatabase)

	aAdd(aPeriodos, {dData,dDatabase})
    For nIndex := 1 To nPeriodos
        PCPMonitorUtils():BuscaPeriodoAnterior(cTipo,@dData)
        aAdd(aPeriodos, {dData,PCPMonitorUtils():RetornaPeriodoFinal(cTipo,dData)})
	Next nIndex
Return aPeriodos

/*/{Protheus.doc} RetornaListaPeriodosFuturo
Retorna um array com os períodos calculados conforme o tipo
@type Static Function
@author douglas.heydt
@since 08/05/2023
@version P12.1.2310
@param	cTipo     , caracter, Tipo do período (D,S,Q,M)
@param	cPeriodos , caracter, Quantidade de períodos
@return aPeriodos , array   , Array com os períodos gerados
/*/
Method RetornaListaPeriodosFuturo(cTipo,cPeriodos) Class PCPMonitorUtils
    Local aPeriodos := {}
    Local nPeriodos := Val(cPeriodos)
    Local nIndex    := 0
    Local dData     := dDatabase

    aAdd(aPeriodos, {dData, PCPMonitorUtils():RetornaPeriodoFinal(cTipo,dData) })
    For nIndex := 1 To nPeriodos
        PCPMonitorUtils():BuscaProximoPeriodo(cTipo,@dData)
        aAdd(aPeriodos, {dData,PCPMonitorUtils():RetornaPeriodoFinal(cTipo,dData)})
	Next nIndex
Return aPeriodos

/*/{Protheus.doc} RetornaQuantidadesProducaoProduto
Retorna o total de unidades produzidas por período
@type Method
@author renan.roeder
@since 02/06/2023
@version P12.1.2310
@param  cFilFlt   , caracter   , Filial do filtro
@param  cProduto  , caracter   , Codigo do produto
@param  dDataIni  , data       , Data inicial
@param  dDataFin  , data       , Data final
@param  cTpAgrup  , caracter   , tipo de período para agrupamento
@return oJsonDados, objeto json, Objeto json com as quantidades apontadas por período
/*/
Method RetornaQuantidadesProducaoProduto(cFilFlt,cProduto,dDataIni,dDataFin,cTpAgrup) Class PCPMonitorUtils
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local dDataAjust := dDatabase
    Local nTotProd   := 0
    Local oJsonDados := JsonObject():New()

    Default cTpAgrup := "D"

    oJsonDados["PERIODOS"] := JsonObject():New()
    cQuery := " SELECT SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_EMISSAO,SD3.D3_QUANT "
    cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
    cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial("SD3",cFilFlt)+"' "
    cQuery += "   AND SD3.D3_COD = '"+cProduto+"' "
    cQuery += "   AND (SD3.D3_EMISSAO >= '"+dToS(dDataIni)+"' AND SD3.D3_EMISSAO <= '"+dToS(dDataFin)+"') "
    cQuery += "   AND SD3.D3_CF IN ('PR0','PR1') "
    cQuery += "   AND SD3.D3_ESTORNO <> 'S' "
    cQuery += "   AND SD3.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_EMISSAO "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    While (cAlias)->(!Eof())
        dDataAjust := dToC(PCPMonitorUtils():RetornaPeriodoInicial(cTpAgrup,sToD((cAlias)->D3_EMISSAO)))
        nTotProd   += (cAlias)->D3_QUANT
        If oJsonDados["PERIODOS"]:HasProperty(dDataAjust) 
            oJsonDados["PERIODOS"][dDataAjust] += (cAlias)->D3_QUANT
        Else
            oJsonDados["PERIODOS"][dDataAjust] := (cAlias)->D3_QUANT
        EndIf
        (cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())
    oJsonDados["TOTAL_PRODUCAO"] := nTotProd
Return oJsonDados

/*/{Protheus.doc} TransformaTempoParaMinutosCentesimais
Transforma o tempo no formato do campo H6_TEMPO para minutos em formato centesimal
@type Method
@author renan.roeder
@since 06/06/2023
@version P12.1.2310
@param  cTempo    , caracter, String com o tempo no formato do campo H6_TEMPO
@param  nTipoTempo, numerico, Tipo do tempo no campo cTempo (1 - Normal / 2 - Centesimal)
@return nMinCent  , numerico, Tempo em minutos no formato centesimal
/*/
Method TransformaTempoParaMinutosCentesimais(cTempo,nTipoTempo) Class PCPMonitorUtils
    Local aHora     := StrTokArr(cTempo,":")
    Local nHoras    := Val(aHora[1])
    Local nMinutos  := Val(aHora[2])
    Local nMinCent  := 0

    nMinCent := (nHoras * 100)
    If nTipoTempo == 1
        nMinCent += nMinutos / .6
    Else
        nMinCent += nMinutos
    EndIf
Return nMinCent

/*/{Protheus.doc} TransformaMinutosCentesimaisParaTempo
Transforma o tempo no formato do campo H6_TEMPO para minutos em formato centesimal
@type Method
@author renan.roeder
@since 06/06/2023
@version P12.1.2310
@param  nMinCent  , numerico         , Tempo em minutos no formato centesimal
@param  nTipoTempo, numerico         , Tipo do tempo no campo cTempo (1 - Normal / 2 - Centesimal)
@return xTempo    , caracter/numerico, Tempo no formato indicado no parâmetro nTipoTempo
/*/
Method TransformaMinutosCentesimaisParaTempo(nMinCent,nTipoTempo) Class PCPMonitorUtils
    Local xTempo   := ""
    Local nHoras   := 0
    Local nMinutos := 0

    If nTipoTempo == 1
        nMinCent := nMinCent * 0.6
        nHoras   := Int(nMinCent / 60)
        nMinutos := Int(nMinCent % 60)
        xTempo   := IIF(nHoras < 10,StrZero(nHoras,2),cValToChar(nHoras)) + ":" + IIF(nMinutos < 10,StrZero(nMinutos,2),cValToChar(nMinutos))
    Else
        xTempo   := Round(nMinCent / 100,2)
    EndIf
Return xTempo

