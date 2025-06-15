#INCLUDE "TOTVS.CH"

#DEFINE SINTETICO 	1,1
#DEFINE ATIVIDADE 	2,1

/*/{Protheus.doc} WS0022060
    Retorna os registros pendentes de apuração para o evento R-2060
    @author Matheus Prada
    @since 13/01/2020
    @version 1.0
    @return Alias da tabela de onde serão extraídos os protocolos.
/*/
Function WS0022060(aApurac, oCprbVld, cPerApu, oErrorVld)

    local nPos  as numeric

    default oCprbVld["eventDetail"]  := {}
    default oErrorVld["registryKey"] := {}

    nPos    :=  0

    (aApurac[SINTETICO])->(DbSetOrder(2))
    (aApurac[SINTETICO])->(dbGoTop())

    IF TAFColumnPos("V48_PROCID")
        while (aApurac[SINTETICO])->(!EOF())
            aadd(oCprbVld["eventDetail"],JsonObject():New())
            nPos := len(oCprbVld["eventDetail"])

            //Filial do registro
            oCprbVld["eventDetail"][nPos]['branchId']                                            := (aApurac[SINTETICO])->FILIAL

            //Id do registro
            oCprbVld["eventDetail"][nPos]['key']                                                 := (aApurac[SINTETICO])->CHAVE

            //Status do evento
            oCprbVld["eventDetail"][nPos]['status']                                              := Iif(RetStQtd((aApurac[SINTETICO])->FILIAL, (aApurac[SINTETICO])->ID, (aApurac[SINTETICO])->CTPINSC, (aApurac[SINTETICO])->CNRINSC, cPerApu) $ ' |0|1|2|', 'notValidated', 'validated')

            //Periodo do evento
            oCprbVld["eventDetail"][nPos]['period']                                              := (aApurac[SINTETICO])->CPERIODO

            //Tipo de inscricao
            oCprbVld["eventDetail"][nPos]['typeOfInscription']                                   := (aApurac[SINTETICO])->CTPINSC + Iif((aApurac[SINTETICO])->CTPINSC == '1', " - CNPJ", " - CNO")

            //Numero de inscricao
            oCprbVld["eventDetail"][nPos]['taxNumber']                                           := (aApurac[SINTETICO])->CNRINSC

            //Numero de inscricao
            oCprbVld["eventDetail"][nPos]['totalInvoice']                                        := CntAtiv(aApurac, (aApurac[SINTETICO])->FILIAL, (aApurac[SINTETICO])->CHAVE)

            //Valor da Receita Bruta Total
            oCprbVld["eventDetail"][nPos]['totalGrossValue']                                     := (aApurac[SINTETICO])->VLRECBTT

            //Valor total de CPRB
            oCprbVld["eventDetail"][nPos]['sociaSecurityContributionValue']                      := (aApurac[SINTETICO])->VLCPAPUT

            //Valor total da contribuição previdenciária com exigibilidade suspensa
            oCprbVld["eventDetail"][nPos]['socialSecurityContributionValueSuspended']            := (aApurac[SINTETICO])->VLCSUSPT

            //Propriedade errors que habilita o icone no frontend
            oCprbVld["eventDetail"][nPos]["errors"]                                              := 'errors'

            If Len(oErrorVld["registryKey"]) > 0
                // Chave de busca do erro da apuração
                oCprbVld["eventDetail"][nPos]["keyValidationErrors"]                             := KeyError(oCprbVld["eventDetail"][nPos], oErrorVld)
            EndIf

            (aApurac[SINTETICO])->(dbSkip())
        EndDo
    Else
        aadd(oCprbVld["eventDetail"],JsonObject():New())
        //Verifica se o campo V48_PROCID existe.
        oCprbVld["eventDetail"][1]['existProcId']                                                := EncodeUTF8("Atualize o sistema com o último pacote do portal para utilizar essa funcionalidade.")
    EndIF

return oCprbVld

/*/{Protheus.doc} WS002D2060
    Retorna o detalhe dos registros pendentes de apuração
    @author Bruno Cremaschi
    @since 13/01/2020
    @version 1.0
    @return Alias da tabela de onde serão extraídos os protocolos.
/*/
Function WS002D2060(aApurac, oCprbVld, cChave)

    local nPos as numeric

    default oCprbVld["invoices"] := {}

    nPos :=  0

    (aApurac[ATIVIDADE])->(DbSetOrder(2))
    (aApurac[ATIVIDADE])->(dbGoTop())

    while (aApurac[ATIVIDADE])->(!EOF())
        if Alltrim((aApurac[ATIVIDADE])->CHAVE) $ cChave
            aadd(oCprbVld["invoices"],JsonObject():New())
            nPos := len(oCprbVld["invoices"])

            //Código de Atividade
            oCprbVld["invoices"][nPos]['activityCode']                       := (aApurac[ATIVIDADE])->CODATIV + " - " + EncodeUTF8( Alltrim( ( aApurac[ATIVIDADE])->CDSATIV ) )

            //Valor de Atividade
            oCprbVld["invoices"][nPos]['totalGrossValue']                    := (aApurac[ATIVIDADE])->C5MVATIV

            //Valor base
            oCprbVld["invoices"][nPos]['totalTaxBase']                       := (aApurac[ATIVIDADE])->VBCCPRB

            //Valor adicional de ajuste
            oCprbVld["invoices"][nPos]['additionalValueOfAdjustment']        := (aApurac[ATIVIDADE])->T9TVAJU

            //Valor de exclusão do ajuste
            if (aApurac[ATIVIDADE])->T9TVEXC > 0 
                oCprbVld["invoices"][nPos]['exclusionValueOfAdjustment']     := (aApurac[ATIVIDADE])->T9TVEXC
            else
                oCprbVld["invoices"][nPos]['exclusionValueOfAdjustment']     := (aApurac[ATIVIDADE])->C5MVEXC
            endIf

            //Alíquota
            oCprbVld["invoices"][nPos]['aliquot']                            := (aApurac[ATIVIDADE])->ALQATIV

            //Valor de contribuição
            oCprbVld["invoices"][nPos]['contributionValue']                  := Round(((aApurac[ATIVIDADE])->ALQATIV * (aApurac[ATIVIDADE])->VBCCPRB) / 100,2)
        EndIf

        (aApurac[ATIVIDADE])->(dbSkip())
    EndDo

return oCprbVld

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetStQtd
Função responsável por retornar o status dos documentos

@author Matheus Prada
@since 13/01/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function RetStQtd(cFil, cId, cTpInsc, cNrInsc, cPerApu)

    Local cAlQry    as character
    Local cStatus   as character
    Local cCNPJ     as character
    Local cFilIn    as character
    Local cWhere    as character
    Local cBd       as character
    Local aLoadFil  as array
    Local aFils     as array
    Local nX        as numeric

    cCNPJ   := Posicione("SM0",1,cEmpAnt+cFil, "M0_CGC")
    cStatus := " "
    cAlQry  := GetNextAlias()
    aFils   := {}
    cFilIn  := ""
    cWhere  := ""
    cBd		:= TcGetDb()
    cPerApu := SUBSTR(cPerApu,3,4) +SUBSTR(cPerApu,1,2)

    AADD(aFils, cFil)

    If cTpInsc == "1"

        aLoadFil := WsLoadFil()

        For nX := 1 to Len(aLoadFil)
            If aLoadFil[nX][6] != cCNPJ
                AADD(aFils, aLoadFil[nX][3])
            EndIf
        Next

        For nX := 1 to Len(aFils)
            If nX == Len(aFils)
                cFilIn += "'" + aFils[nX] + "'"
            Else
                cFilIn += "'" + aFils[nX] + "',"
            EndIf
        Next

        If cBd $ "ORACLE|POSTGRES|DB2"
            cWhere += " SUBSTR(C5M.C5M_DTINI,1,6) = '" + cPerApu + "' AND SUBSTR(C5M.C5M_DTFIM,1,6) = '" + cPerApu + "' "
        ElseIf cBd $ "INFORMIX"
            cWhere	+= " C5M.C5M_DTINI[1,6] = '" + cPerApu + "' AND C5M.C5M_DTFIM[1,6] = '" + cPerApu + "' "
        Else
            cWhere	+= " SUBSTRING(C5M.C5M_DTINI,1,6) = '" + cPerApu + "' AND SUBSTRING(C5M.C5M_DTFIM,1,6) = '" + cPerApu + "' "
        EndIf

        cWhere	:= "%" + cWhere + "%"

        BeginSQl Alias cAlQry
        SELECT 
            COUNT(*) TOTAL
        FROM ( SELECT 
        CASE
                WHEN C5M.C5M_PROCID <> ' ' THEN '3'
                WHEN C5M.C5M_PROCID = ' ' THEN ' ' 
        END AS STATUS
        FROM 
            %Table:C5M% C5M
        WHERE 
            C5M.C5M_FILIAL IN (%Exp:cFil%)
            AND %Exp:cWhere%
            AND C5M.%NotDel% ) STATUS
        WHERE 
            STATUS.STATUS = ''
    EndSQL
Else
    BeginSQl Alias cAlQry
        SELECT 
            COUNT(*) TOTAL
        FROM (SELECT 
    CASE
                WHEN V48.V48_PROCID <> ' ' THEN '3'
                WHEN V48.V48_PROCID = ' ' THEN ' ' 
    END AS STATUS
        FROM 
            %Table:V48% V48
        INNER JOIN %Table:T9C% T9C
            ON T9C.T9C_FILIAL = V48.V48_FILIAL
            AND T9C.T9C_ID = V48.V48_IDCNO
            AND T9C.%NotDel%
        WHERE 
            T9C_NRINSC = %Exp:cNrInsc%
            AND V48.%NotDel% ) STATUS
        WHERE 
            STATUS.STATUS = ''
EndSQL
EndIf

cStatus := Iif( (cAlQry)->TOTAL > 0, "0", "3")

(cAlQry)->(DbCloseArea())

Return cStatus

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CntAtiv
Função responsável por retornar a quantidade e o status dos documentos

@author Matheus Prada
@since 13/01/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CntAtiv(aApurac, cFil, cId)

    Local nQtdDocs  as numeric

    nQtdDocs    := 0

    (aApurac[ATIVIDADE])->(dbSeek(cId))

    while (aApurac[ATIVIDADE])->(!eof()) .And. (aApurac[ATIVIDADE])->CHAVE $ cId
        nQtdDocs++

        (aApurac[ATIVIDADE])->(DbSkip())
    endDo

return nQtdDocs


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oCprbVld, oErrorVld)

    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oErrorVld["registryKey"])
        if alltrim(oErrorVld["registryKey"][nX]["branchId"]) == alltrim(oCprbVld["branchId"])
            if alltrim(oErrorVld["registryKey"][nX]["id"]) == alltrim(oCprbVld["key"])
                cKeyError := oErrorVld["registryKey"][nX]["error"]
            endif
        endif
    Next nX

return ( cKeyError )
