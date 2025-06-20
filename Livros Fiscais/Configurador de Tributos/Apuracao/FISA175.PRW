#INCLUDE "PROTHEUS.CH"

// D�bitos
#DEFINE RES_OPTRIB 01
#DEFINE RES_ESTCRD 02
#DEFINE RES_AJUDEB 03
#DEFINE RES_TOTDEB 04

// Saldo Credor de Per�odos Anteriores
#DEFINE RES_SLDANT 05
// Saldo credor de per�odos anteriores utilizado
#DEFINE RES_SLDUTI 06

// Cr�ditos
#DEFINE RES_OPCRED 07
#DEFINE RES_ESTDEB 08
#DEFINE RES_AJUCRD 09
#DEFINE RES_TOTCRD 10

// Saldos Finais
#DEFINE RES_SLDDEV 11
#DEFINE RES_SLDCRD 12

//-------------------------------------------------------------------
/*/{Protheus.doc} x175Processa()

Fun��o respons�vel por processar as movimenta��es e interpretar a regra
de apura��o vinculada.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 19/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function x175Processa(aFil, aParams)

Local nX := 0
Local nY := 0
Local cAliasApu := ""
Local aParamQry := {}
Local cIdApur := ""
Local cCredDeb := ""
Local cRegraApur := ""
Local nValTrib := 0
Local nValDev := 0
Local cRegraTrib := ""
Local aApurIDs := {}
Local cAlsSldAnt := ""
Local aTrbSel := {}
Local nPosTrb := 0
Local aDadosF2I := {}
Local aAreaSM0 := {}

BEGIN TRANSACTION

    // Processamento inicial de todos os tributos selecionados - na vis�o da filial centralizadora:
    // 1 - Grava��o do cabe�alho de apura��o.
    // 2 - Grava��o dos saldos transportados do per�odo anterior.
    aTrbSel := StrToKArr(aParams[4], "|")
    For nY := 1 to Len(aTrbSel)
        
        // Chamada da x175GrvF2H para gerar um novo "Cabe�alho" de apura��o
        cIDApur := x175GrvF2H(aTrbSel[nY], aParams[1], aParams[2], @aApurIDs)

        // Execu��o da query para retornar o saldo credor do per�odo anterior (se houver)
        aParamQry := {aTrbSel[nY], aParams[1], "1"}
        cAlsSldAnt := x175Query("SALDO_PER_ANT", aParamQry)
 
        While (cAlsSldAnt)->(!Eof())

            aDadosF2I := x175SldStr()

            aDadosF2I[1] := ""                       // ID da F2I - Neste caso ser� gerado pela fun��o de grava��o.
            aDadosF2I[2] := (cAlsSldAnt)->F2I_TPSLD
            aDadosF2I[3] := (cAlsSldAnt)->F2I_SLDFIN // Saldo final do m�s anterior ser� o inicial deste m�s.
            aDadosF2I[4] := 0
            aDadosF2I[5] := 0
            aDadosF2I[6] := (cAlsSldAnt)->F2I_DTORI

            // Chamada da x175GrvF2I p/ grava��o dos saldos transportados do per�odo anterior.
            x175GrvF2I(cIDApur, aDadosF2I)

            (cAlsSldAnt)->(dbSkip())

        EndDo

        (cAlsSldAnt)->(dbCloseArea())
        
    Next nY

    aAreaSM0 := SM0->(GetArea())

    // Processamento das filiais selecionadas.
    For nX := 1 to Len(aFil)

        SM0->(DbGoTop ())
        SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
        cFilAnt := FWGETCODFILIAL

        // Execu��o da query para retornar as movimenta��es
        aParamQry := {aParams[1], aParams[2], aParams[4]}
        cAliasApu  := x175Query("F2D", aParamQry)

        While (cAliasApu)->(!Eof())

            // Busco no array de ID's gerados qual o ID do tributo em quest�o.
            nPosTrb := aScan(aApurIDs, {|x| AllTrim(x[1]) == AllTrim((cAliasApu)->F2E_TRIB)})

            If nPosTrb > 0

                // Recupera o ID gerado anteriormente
                cIdApur := aApurIDs[nPosTrb, 2]

                // Chamada da x175RegrAp para interpretar a regra de apura��o e retornar se a movimenta��o � um cr�dito ou d�bito.
                cCredDeb := x175RegrAp(cAliasApu)

                IF !Empty(cCredDeb)

                    cRegraApur := (cAliasApu)->F2G_ID
                    cRegraTrib := (cAliasApu)->F2B_ID

                    If (cAliasApu)->FT_TIPO == "D"
                        nValDev := (cAliasApu)->VALOR_TRIBUTO
                        nValTrib := 0
                    Else
                        nValTrib := (cAliasApu)->VALOR_TRIBUTO
                        nValDev := 0
                    EndIf
                    
                    // Grava��o da tabela F2J
                    x175GrvF2J(cIdApur, cRegraApur, cCredDeb, cRegraTrib, nValTrib, nValDev)
                    
                EndIF

            EndIf

            (cAliasApu)->(dbSkip())

        EndDo

        // Fecha o alias da query.
        (cAliasApu)->(dbCloseArea())

    Next nX

    // Restauro a �rea da SM0 e o cFilAnt pois daqui para baixo o processamento
    // � todo feito na vis�o da filial centralizadora.
    RestArea(aAreaSM0)
    cFilAnt := FWGETCODFILIAL

    // Com a apura��o por regra de tributo feita (F2J), o pr�ximo passo
    // � consolidar os resultados das regras em um resumo por tributo (F2K). 
    // Para isso vou utilizar os ID's das apura��es gerados anteriormente.
    For nY := 1 to Len(aApurIDs)
        x175ResApu(aApurIDs[nY, 2], aParams)
        //Chama fun��o para atualizar o Status da Apura��o
	    x175AtuSts(aApurIDs[nY, 2])
    Next nY

END TRANSACTION

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x175Query()

Fun��o respons�vel por centralizar as queries utilizadas pela apura��o.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 19/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function x175Query(cTpQuery, aParamQry)

Local cAlsRet := GetNextAlias()
Local cSelect := ""
Local cFrom := ""
Local cWhere := ""
Local cOrder := ""
Local cGroup := ""
Local cQryAltF2b:= Iif(F2B->(Fieldpos("F2B_ALTERA")) > 0," AND F2B_ALTERA <>'1' " ,"")

Do Case

    Case cTpQuery == "F2D"

        cSelect := "F2D.F2D_FILIAL, SFT.FT_TIPOMOV, SFT.FT_TIPO, F2B.F2B_ID, F2B.F2B_REGRA, F2E.F2E_TRIB, F2G.F2G_ID, F2G.F2G_CODIGO, F2G.F2G_ENTRAD, F2G.F2G_SAIDA, F2G.F2G_DEVOL, "
        cSelect += "SUM(F2D.F2D_VALOR) VALOR_TRIBUTO "

        cFrom := RetSqlName("F2D") + " F2D "
        cFrom += "LEFT JOIN " + RetSqlName("SFT") + " SFT ON (SFT.FT_FILIAL = "  + ValToSql(xFilial("SFT")) + " AND SFT.FT_IDTRIB = F2D.F2D_IDREL AND SFT.FT_ENTRADA >= " + ValToSql(aParamQry[1]) + " AND SFT.FT_ENTRADA <= " + ValToSql(aParamQry[2]) + " AND SFT.D_E_L_E_T_ = ' ') "                
        cFrom += "JOIN "      + RetSqlName("F2B") + " F2B ON (F2B.F2B_FILIAL = " + ValToSql(xFilial("F2B")) + " AND F2B.F2B_REGRA = F2D.F2D_TRIB AND F2B.D_E_L_E_T_ = ' ' " + cQryAltF2b + " )"
        cFrom += "JOIN "      + RetSqlName("F2E") + " F2E ON (F2E.F2E_FILIAL = " + ValToSql(xFilial("F2E")) + " AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.F2E_TRIB IN " + FormatIn(aParamQry[3], "|") + " AND F2E.D_E_L_E_T_ = ' ') "
        cFrom += "JOIN "      + RetSqlName("F2G") + " F2G ON (F2G.F2G_FILIAL = " + ValToSql(xFilial("F2G")) + " AND F2G.F2G_CODIGO = F2B.F2B_RAPUR AND F2G.D_E_L_E_T_ = ' ') "

        cWhere := "F2D.F2D_FILIAL = " + ValToSql(xFilial("F2D")) + " AND "
        cWhere += "F2D.F2D_DTEXCL = ' ' AND "
        cWhere += "F2D.D_E_L_E_T_ = ' ' "

        cGroup := "GROUP BY F2D.F2D_FILIAL, SFT.FT_TIPOMOV, SFT.FT_TIPO, F2B.F2B_ID, F2B.F2B_REGRA, F2E.F2E_TRIB, F2G.F2G_ID, F2G.F2G_CODIGO, F2G.F2G_ENTRAD, F2G.F2G_SAIDA, F2G.F2G_DEVOL "

        cOrder := "ORDER BY F2D.F2D_FILIAL, F2B.F2B_ID"

    Case cTpQuery == "F2J_X_F2K"

        cSelect := "F2J.F2J_FILIAL, F2J.F2J_TIPO, SUM(F2J.F2J_VLTRIB) VALOR_TRIBUTO, SUM(F2J.F2J_VLDEV) VALOR_DEVOLUCOES " 

        cFrom := RetSqlName("F2J") + " F2J "

        cWhere += "F2J.F2J_IDAPUR = " + ValToSql(aParamQry[1]) + " AND "
        cWhere += "F2J.D_E_L_E_T_ = ' '"

        cGroup := "GROUP BY F2J.F2J_FILIAL, F2J.F2J_TIPO"

    Case cTpQuery == "F2J"

        cSelect := "F2B.F2B_REGRA, F2B.F2B_DESC, SUM(F2J.F2J_VLTRIB) VALOR_TRIBUTO, SUM(F2J.F2J_VLDEV) VALOR_DEVOLUCOES " 

        cFrom := RetSqlName("F2J") + " F2J "
        cFrom += "JOIN " + RetSqlName("F2B") + " F2B ON (F2B.F2B_FILIAL = " + ValToSql(xFilial("F2B")) + " AND F2B.F2B_ID = F2J.F2J_RTRIB AND F2B.D_E_L_E_T_ = ' '" + cQryAltF2b + " )"

        cWhere := "F2J.F2J_FILIAL = " + ValToSql(xFilial('F2J')) + " AND "
        cWhere += "F2J.F2J_IDAPUR = " + ValToSql(aParamQry[1]) + " AND "
        cWhere += "F2J.F2J_TIPO = " + ValToSql(aParamQry[2]) + " AND "
        cWhere += "F2J.D_E_L_E_T_ = ' '"

        cGroup := "GROUP BY F2B.F2B_REGRA, F2B.F2B_DESC "

    Case cTpQuery == "F2K"        
        
        cSelect := "F2K.F2K_ID, F2K.F2K_OPTRIB, F2K.F2K_ESTCRD, F2K.F2K_TOTDEB, F2K.F2K_SLDANT, 
        cSelect += "F2K.F2K_OPCRED, F2K.F2K_ESTDEB, F2K.F2K_TOTCRD, F2K.F2K_SLDDEV, F2K.F2K_SLDATU, " 
        cSelect += "F2K.F2K_AJUDEB, F2K.F2K_SLDUTI, F2K.F2K_AJUCRD "

        cFrom := RetSqlName("F2K") + " F2K "        

        cWhere := "F2K.F2K_FILIAL = " + ValToSql(xFilial('F2K')) + " AND "
        cWhere += "F2K.F2K_IDAPUR = " + ValToSql(aParamQry[1]) + " AND "       
        cWhere += "F2K.D_E_L_E_T_ = ' '"

    Case cTpQuery == "SALDO_PER_ANT"
        
        cSelect := "F2I.F2I_FILIAL, F2I.F2I_DTORI, F2I.F2I_SLDFIN, F2I.F2I_TPSLD "

        cFrom := RetSqlName("F2I") + " F2I "

        cWhere := "F2I.F2I_FILIAL = " + ValToSql(xFilial("F2I")) + " AND "
        cWhere += "F2I.F2I_IDAPUR = ("
        cWhere +=   "SELECT F2H1.F2H_ID "
        cWhere +=   "FROM " + RetSqlName("F2H") + " F2H1 "
        cWhere +=   "WHERE F2H1.F2H_FILIAL = " + ValToSql(xFilial("F2H")) + " AND "
        cWhere +=   "F2H1.F2H_TRIB = " + ValToSql(aParamQry[1]) + " AND "
        cWhere +=   "F2H1.F2H_DTFIN = (" 
        cWhere +=       "SELECT MAX(F2H2.F2H_DTFIN) DTFIN "
        cWhere +=       "FROM " + RetSqlName("F2H") + " F2H2 "
        cWhere +=       "WHERE F2H2.F2H_FILIAL = " + ValToSql(xFilial("F2H")) + " AND "
        cWhere +=       "F2H2.F2H_TRIB = " + ValToSql(aParamQry[1]) + " AND "
        cWhere +=       "F2H2.F2H_DTFIN < " + ValToSql(aParamQry[2]) + " AND "
        cWhere +=       "F2H2.D_E_L_E_T_ = ' ') AND "
        cWhere +=   "F2H1.D_E_L_E_T_ = ' ') AND "
        cWhere += "F2I.F2I_TPSLD = "  + ValToSql(aParamQry[3])   + " AND "
        cWhere += "F2I.F2I_SLDFIN > 0 AND "
        cWhere += "F2I.D_E_L_E_T_ = ' ' "
    
    Case cTpQuery == "F2H"
        
        cSelect := "F2H.F2H_ID, F2H.F2H_TRIB, F2H.F2H_STATUS " 

        cFrom := RetSqlName("F2H") + " F2H "        
        cWhere := "F2H.F2H_FILIAL = " + ValToSql(xFilial('F2H')) + " AND "
        cWhere += "F2H.F2H_TRIB IN " + FormatIn(aParamQry[3], "|") + " AND "
        cWhere  += "( (" + ValToSQL(aParamQry[1]) + " >= F2H.F2H_DTINI  AND " + ValToSQL(aParamQry[1]) + " <= F2H.F2H_DTFIN ) OR "
        cWhere  += "( " + ValToSQL(aParamQry[2]) + " >= F2H.F2H_DTINI  AND " + ValToSQL(aParamQry[2]) + " <= F2H.F2H_DTFIN )) AND  "
        cWhere += "F2H.D_E_L_E_T_ = ' '"        

    Case cTpQuery == "F2M"

        cSelect := "F2M.F2M_FILIAL, F2M.F2M_TPAJUS, SUM(F2M.F2M_VALOR) VALOR_AJUSTE "

        cFrom := RetSqlName("F2M") + " F2M "

        cWhere := "F2M.F2M_FILIAL = " + ValToSql(xFilial("F2M")) + " AND "
        cWhere += "F2M.F2M_IDRAPU = " + ValToSql(aParamQry[1]) + " AND "
        cWhere += "F2M.D_E_L_E_T_ = ' ' "

        cGroup := "GROUP BY F2M.F2M_FILIAL, F2M.F2M_TPAJUS "

    Case cTpQuery == "F2I"

        cSelect := "F2I.F2I_FILIAL, F2I.F2I_ID, F2I.F2I_TPSLD, F2I.F2I_SLDINI, F2I.F2I_SLDUTI, F2I.F2I_SLDFIN, F2I.F2I_DTORI "

        cFrom := RetSqlName("F2I") + " F2I "
        cFrom += "JOIN " + RetSqlName("F2H") + " F2H ON (F2H.F2H_FILIAL = " + ValToSql(xFilial("F2H")) + " AND F2H.F2H_ID = F2I.F2I_IDAPUR) "

        cWhere := "F2I.F2I_FILIAL = " + ValToSql(xFilial("F2I")) + " AND "
        cWhere += "F2I.F2I_IDAPUR = " + ValToSql(aParamQry[1]) + " AND "
        cWhere += "F2I.F2I_TPSLD = " + ValToSql(aParamQry[2]) + " AND "
        cWhere += "F2I.F2I_DTORI < F2H.F2H_DTINI AND "
        cWhere += "F2I.D_E_L_E_T_ = ' ' "

        cOrder := "ORDER BY F2I.F2I_DTORI "

    Case cTpQuery == 'F2JXFIL'

        cSelect := "F2J.F2J_FILIAL "

        cFrom := RetSqlName("F2J") + " F2J "

        cWhere += "F2J.F2J_IDAPUR = " + ValToSql(aParamQry[1]) + " AND "
        cWhere += "F2J.F2J_TIPO = " + ValToSql(aParamQry[2]) + " AND "
        cWhere += "F2J.D_E_L_E_T_ = ' '"

        cGroup := "GROUP BY F2J.F2J_FILIAL "
EndCase

// Prepara��o da query para execu��o do BeginSQL
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + cGroup + cOrder + "%"

BeginSql Alias cAlsRet

    SELECT
        %Exp:cSelect%
    FROM
        %Exp:cFrom%
    WHERE
        %Exp:cWhere%

EndSql

dbSelectArea(cAlsRet)
(cAlsRet)->(dbGoTop())

Return cAlsRet

//-------------------------------------------------------------------
/*/{Protheus.doc} x175RegrAp()

Fun��o respons�vel por interpretar a regra de apura��o e retornar se
a movimenta��o em quest�o deve ser considerada como um d�bito ou um cr�dito.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 19/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175RegrAp(cAliasApu)

Local cCredDeb := ""

// Se for uma entrada avalio a configura��O para entradas na regra de apura��o.
If (cAliasApu)->FT_TIPOMOV == "E"

    // Se for devolu��o avalio a configura��o da regra de apura��o para devolu��es...
    If (cAliasApu)->FT_TIPO == "D"

        // Se for contrapartida vou verificar a configura��o da regra de sa�da
        // para que o valor da devolu��o seja gerado conforme a opera��o original.
        If (cAliasApu)->F2G_DEVOL == "2"

            Do Case
                Case (cAliasApu)->F2G_SAIDA == "2" // Debita
                    cCredDeb := "1" // Tipo 1 - D�bito.
                Case (cAliasApu)->F2G_SAIDA == "3" // Credita
                    cCredDeb := "2" // Tipo 2 - Cr�dito.
            EndCase

        EndIf

    // Caso contr�rio s� interpreto a regra de entrada.
    Else

        Do Case
            Case (cAliasApu)->F2G_ENTRAD == "2" // Debita
                cCredDeb := "1" // Tipo 1 - D�bito.
            Case (cAliasApu)->F2G_ENTRAD == "3" // Credita
                cCredDeb := "2" // Tipo 2 - Cr�dito.
        EndCase

    EndIf

ElseIf (cAliasApu)->FT_TIPOMOV == "S"

    // Se for devolu��o avalio a configura��o da regra de apura��o para devolu��es...
    If (cAliasApu)->FT_TIPO == "D"

        // Se for contrapartida vou verificar a configura��o da regra de entrada
        // para que o valor da devolu��o seja gerado conforme a opera��o original.
        If (cAliasApu)->F2G_DEVOL == "2"

            Do Case
                Case (cAliasApu)->F2G_ENTRAD == "2" // Debita
                    cCredDeb := "1" // Tipo 1 - D�bito.
                Case (cAliasApu)->F2G_ENTRAD == "3" // Credita
                    cCredDeb := "2" // Tipo 2 - Cr�dito.
            EndCase

        EndIf

    // Caso contr�rio s� interpreto a regra de sa�da.
    Else

        Do Case
            Case (cAliasApu)->F2G_SAIDA == "2" // Debita
                cCredDeb := "1" // Tipo 1 - D�bito.
            Case (cAliasApu)->F2G_SAIDA == "3" // Credita
                cCredDeb := "2" // Tipo 2 - Cr�dito
        EndCase

    EndIf

EndIf

Return cCredDeb

//-------------------------------------------------------------------
/*/{Protheus.doc} x175ResApu()

Fun��o respons�vel por efetuar a consolida��o da apura��o do tributo.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 20/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function x175ResApu(cIDApur, aParams, cIdF2K)

Local cAliasF2J := ""
Local cAliasF2M := ""
Local aParamQry := {}
Local aResumo := Array(12)
Local aSaldosAnt := {}
Local aSaldoAtu := {}
Local nTotSldAnd := 0
Local nX := 0
Local nTotDeb := 0
Local dDtOriSld := cTod("//")

DEFAULT cIDF2K := ""
DEFAULT aParams := {}

//Obtenho a data final da apura��o que est� sendo processada para usar como
//data de origem do saldo que pode vir a ser gerado por ela.
dbSelectArea("F2H")
F2H->(dbSetOrder(3))
If F2H->(MsSeek(xFilial("F2H") + cIDApur))
    dDtOriSld := F2H->F2H_DTFIN
EndIf

//Deleto o saldo credor que tenha sido eventualmente gerado pela apura��o
//pois no final do processamento do resumo, caso haja saldo credor, este
//ser� gravado novamente. 
dbSelectArea("F2I")
F2I->(dbSetOrder(2)) // F2I_FILIAL+F2I_IDAPUR+F2I_TPSLD+DTOS(F2I_DTORI)
If F2I->(dbSeek(xFilial("F2I") + cIDApur + "1" + dToS(dDtOriSld)))
    x175DelF2I(cIDApur, dDtOriSld)
EndIf

// Inicializando array de resumo
aFill(aResumo, 0)

// Grava��o inicial do resumo de apura��o - zerado.
cIdF2K := x175GrvF2K(cIDApur, cIDF2K ,aResumo)

// ----- SALDO DO PER�ODO ANTERIOR ----- //

aSaldosAnt := x175Saldo(cIDApur, "1")
aEval(aSaldosAnt, {|aSaldo| nTotSldAnd += aSaldo[3]}) // Soma o saldo inicial.
aResumo[RES_SLDANT] := nTotSldAnd

// ----- PROCESSANDO MOVIMENTA��O ----- //

// Execu��o da query na F2J para retornar as movimenta��es processadas.
aParamQry := {cIDApur}
cAliasF2J := x175Query("F2J_X_F2K", aParamQry)

While (cAliasF2J)->(!Eof())

    If AllTrim((cAliasF2J)->F2J_TIPO) == "1" // D�bito

        aResumo[RES_OPTRIB] += (cAliasF2J)->VALOR_TRIBUTO // Operacoes tributadas (+)
        aResumo[RES_ESTDEB] += (cAliasF2J)->VALOR_DEVOLUCOES // Estornos de d�bito (+)        

    ElseIf AllTrim((cAliasF2J)->F2J_TIPO) == "2" //Cr�dito

        aResumo[RES_OPCRED] += (cAliasF2J)->VALOR_TRIBUTO // Operacoes c/ direito a cr�dito (+)
        aResumo[RES_ESTCRD] += (cAliasF2J)->VALOR_DEVOLUCOES // Estornos de cr�dito (+)

    EndIf
    
    (cAliasF2J)->(dbSkip())

EndDo

// Fecha o alias da F2J
(cAliasF2J)->(dbCloseArea())

// ----- PROCESSANDO AJUSTES ----- //

// Execu��o da query na F2M para retornar os ajustes,.
aParamQry := {cIDF2K}
cAliasF2M := x175Query("F2M", aParamQry)

While (cAliasF2M)->(!Eof())

    Do Case
        
        // Ajuste de estorno de d�bito...
        Case (cAliasF2M)->F2M_TPAJUS == "1"
            aResumo[RES_AJUDEB] += (cAliasF2M)->VALOR_AJUSTE // Estornos de cr�dito (+)
        // Ajuste de estorno de cr�dito...
        Case (cAliasF2M)->F2M_TPAJUS == "2"
            aResumo[RES_AJUCRD] += (cAliasF2M)->VALOR_AJUSTE // Estornos de d�bito (+)

    EndCase

     (cAliasF2M)->(dbSkip())                                                                       

EndDo

// Fecha o alias da F2M
(cAliasF2M)->(dbCloseArea())

// ----- C�LCULO DO RESUMO - VALORES FINAIS ----- //

aResumo[RES_TOTDEB] := aResumo[RES_OPTRIB] + aResumo[RES_ESTCRD] + aResumo[RES_AJUDEB] // Total de d�bitos
aResumo[RES_TOTCRD] := aResumo[RES_OPCRED] + aResumo[RES_ESTDEB] + aResumo[RES_AJUCRD] // Total de cr�ditos

// Consumo dos saldos do per�odo anterior que foram transportados para esta apura��o...
nTotDeb := aResumo[RES_TOTDEB]
For nX := 1 to Len(aSaldosAnt)

    // Se conseguiu abater todo o d�bito posso parar o la�o.
    // Caso contr�rio atualizo o saldo credor, o total de d�bitos restante, e passo para o pr�ximo saldo p/ tentar abater..
    If aSaldosAnt[nX, 3] - nTotDeb >= 0
        aSaldosAnt[nX, 4] += nTotDeb
        nTotDeb := 0
    Else
        nTotDeb -= aSaldosAnt[nX, 3]
        aSaldosAnt[nX, 4] := aSaldosAnt[nX, 3]          
    EndIf

    aSaldosAnt[nX, 5] := aSaldosAnt[nX, 3] - aSaldosAnt[nX, 4]
    aResumo[RES_SLDUTI] += aSaldosAnt[nX, 4]

Next nX

If ((aResumo[RES_TOTDEB] - aResumo[RES_SLDUTI]) - aResumo[RES_TOTCRD]) > 0  // Saldo Devedor
    aResumo[RES_SLDDEV] := ((aResumo[RES_TOTDEB] - aResumo[RES_SLDUTI]) - aResumo[RES_TOTCRD]) 
Else // Saldo Credor
    aResumo[RES_SLDCRD] := ((aResumo[RES_SLDANT] - aResumo[RES_SLDUTI]) + (aResumo[RES_TOTCRD] - (aResumo[RES_TOTDEB] - aResumo[RES_SLDUTI]))) 
EndIf

// Saldo credor gerado por esta apura��o -> N�o posso considerar o saldo que foi transportado!
If (aResumo[RES_TOTCRD] - (aResumo[RES_TOTDEB] - aResumo[RES_SLDUTI]))> 0

    aSaldoAtu := x175SldStr()

    aSaldoAtu[1] := ""
    aSaldoAtu[2] := "1"
    aSaldoAtu[3] := (aResumo[RES_TOTCRD] - (aResumo[RES_TOTDEB] - aResumo[RES_SLDUTI]))
    aSaldoAtu[4] := 0
    aSaldoAtu[5] := (aResumo[RES_TOTCRD] - (aResumo[RES_TOTDEB] - aResumo[RES_SLDUTI]))
    aSaldoAtu[6] := dDtOriSld

    x175GrvF2I(cIDApur, aSaldoAtu)   

EndIf

// Atualiza��o da F2I...
For nX := 1 to Len(aSaldosAnt)
    x175GrvF2I(cIDApur, aSaldosAnt[nX])
Next nX

// Atualiza��o da F2K ap�s os c�lculos...
x175GrvF2K(cIDApur, cIDF2K, aResumo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x175GrvF2H()

Fun��o respons�vel por efetuar a grava��o da tabela F2H.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 20/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175GrvF2H(cTributo, dDataIni, dDataFim, aApurIDs)

Local cIdApur := ""

DEFAULT aApurIDs := {}

dbSelectArea("F2H")
F2H->(dbSetOrder(1)) // F2H_FILIAL+F2H_TRIB+DTOS(F2H_DTINI)+DTOS(F2H_DTFIN)+F2H_ID

If !F2H->(MsSeek(xFilial("F2H") + dToS(dDataIni) + dToS(dDataFim) + cTributo))

    cIdApur := FWUUID("F2H")

    Reclock("F2H", .T.)
    F2H->F2H_FILIAL = xFilial("F2H")
    F2H->F2H_ID := cIdApur
    F2H->F2H_STATUS := "4" // N�o gerou t�tulo...
    F2H->F2H_TRIB := cTributo
    F2H->F2H_DTINI := dDataIni
    F2H->F2H_DTFIN := dDataFim
    F2H->(MsUnlock())

    // Guardo o ID gerado para utilizar na consolida��o da apura��o.
    aAdd(aApurIDs, {cTributo, cIdApur})

Else

    cIdApur := F2H->F2H_ID

EndIf

Return cIdApur

//-------------------------------------------------------------------
/*/{Protheus.doc} x175GrvF2J()

Fun��o respons�vel por efetuar a grava��o/atualiza��o da tabela F2J.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 20/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175GrvF2J(cIdApur, cRegraApur, cCredDeb, cRegraTrib, nValTrib, nValDev)

Local cIDF2J := ""

DEFAULT nValDev := 0

dbSelectArea("F2J")
F2J->(dbSetOrder(1)) // F2J_FILIAL+F2J_IDAPUR+F2J_RTRIB+F2J_TIPO

If !F2J->(MsSeek(xFilial("F2J") + cIdApur + cRegraTrib + cCredDeb))

    cIDF2J := FWUUID("F2J")

    RecLock("F2J", .T.)
    F2J->F2J_FILIAL := xFilial("F2J")
    F2J->F2J_ID := cIDF2J
    F2J->F2J_IDAPUR := cIdApur
    F2J->F2J_RAPUR := cRegraApur
    F2J->F2J_TIPO := cCredDeb
    F2J->F2J_RTRIB := cRegraTrib
    F2J->F2J_VLTRIB := nValTrib
    F2J->F2J_VLDEV := nValDev
    F2J->(MsUnlock())

Else

    cIDF2J := F2J->F2J_ID

    RecLock("F2J", .F.)
    F2J->F2J_VLTRIB += nValTrib
    F2J->F2J_VLDEV += nValDev
    F2J->(MsUnlock())

EndIf

Return cIDF2J

//-------------------------------------------------------------------
/*/{Protheus.doc} x175GrvF2K()

Fun��o respons�vel por efetuar a grava��o/atualiza��o da tabela F2K.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 20/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175GrvF2K(cIDApur, cIDF2K, aResumo)

DEFAULT cIDF2K := ""

dbSelectArea("F2K")
F2K->(dbSetOrder(1)) // F2K_FILIAL+F2K_IDAPUR+F2K_ID

If !F2K->(MsSeek(xFilial("F2K") + cIDApur + cIDF2K))

    cIDF2K := FWUUID("F2K")

    RecLock("F2K", .T.)
    F2K->F2K_FILIAL := xFilial("F2K")
    F2K->F2K_ID := cIDF2K
    F2K->F2K_IDAPUR := cIdApur
   
Else

    RecLock("F2K", .F.)

EndIf

F2K->F2K_OPTRIB := aResumo[RES_OPTRIB]
F2K->F2K_ESTCRD := aResumo[RES_ESTCRD]
F2K->F2K_AJUDEB := aResumo[RES_AJUDEB]
F2K->F2K_TOTDEB := aResumo[RES_TOTDEB]
F2K->F2K_SLDANT := aResumo[RES_SLDANT]
F2K->F2K_SLDUTI := aResumo[RES_SLDUTI]
F2K->F2K_OPCRED := aResumo[RES_OPCRED]
F2K->F2K_ESTDEB := aResumo[RES_ESTDEB]
F2K->F2K_AJUCRD := aResumo[RES_AJUCRD]
F2K->F2K_TOTCRD := aResumo[RES_TOTCRD]
F2K->F2K_SLDDEV := aResumo[RES_SLDDEV]
F2K->F2K_SLDATU := aResumo[RES_SLDCRD]

F2K->(MsUnlock())

Return cIDF2K

//-------------------------------------------------------------------
/*/{Protheus.doc} x175GrvF2I()

Fun��o respons�vel por efetuar a grava��o/atualiza��o da tabela F2I.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 21/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175GrvF2I(cIDApur, aDadosF2I)

Local cIDF2I := ""

dbSelectArea("F2I")
F2I->(dbSetOrder(3)) //F2I_FILIAL+F2I_ID

If Empty(aDadosF2I[1]) .Or. !F2I->(MsSeek(xFilial("F2I") + aDadosF2I[1]))

    cIDF2I := FWUUID("F2I")

    RecLock("F2I", .T.)
    F2I->F2I_FILIAL := xFilial("F2I")
    F2I->F2I_ID := cIDF2I
    F2I->F2I_IDAPUR := cIDApur
    F2I->F2I_TPSLD := aDadosF2I[2]
    F2I->F2I_SLDINI := aDadosF2I[3]
    F2I->F2I_SLDUTI := aDadosF2I[4]
    F2I->F2I_SLDFIN := aDadosF2I[5]
    F2I->F2I_DTORI  := IIf(ValType(aDadosF2I[6]) == "C", StoD(aDadosF2I[6]), aDadosF2I[6])
    F2I->(MsUnlock())

Else

    cIDF2I := F2I->F2I_ID

    RecLock("F2I", .F.)
    F2I->F2I_SLDUTI := aDadosF2I[4]
    F2I->F2I_SLDFIN := aDadosF2I[5]
    F2I->(MsUnlock())

EndIf

Return cIDF2I

//-------------------------------------------------------------------
/*/{Protheus.doc} x175Saldo()

Fun��o respons�vel por retornar os saldos de per�odos anteriores em 
formato de array para que sejam processados e utilizados na apura��o.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 21/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175Saldo(cIDApur, cTpSaldo)

Local aParamQry := {}
Local cAliasF2I := ""
Local aSaldos := {}
Local aSaldo := {}

aParamQry := {cIDApur, cTpSaldo}
cAliasF2I := x175Query("F2I", aParamQry)

While (cAliasF2I)->(!Eof())

    aSaldo := x175SldStr()

    aSaldo[1] := (cAliasF2I)->F2I_ID
    aSaldo[2] := (cAliasF2I)->F2I_TPSLD
    aSaldo[3] := (cAliasF2I)->F2I_SLDINI
    aSaldo[4] := 0
    aSaldo[5] := (cAliasF2I)->F2I_SLDFIN
    aSaldo[6] := (cAliasF2I)->F2I_DTORI

    aAdd(aSaldos, aSaldo)

    (cAliasF2I)->(dbSkip())

EndDo

(cAliasF2I)->(dbCloseArea())

Return aClone(aSaldos)

//-------------------------------------------------------------------
/*/{Protheus.doc} x175AtuSts()

Fun��o respons�vel por atualizar o status da apura��o.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 21/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function x175AtuSts(cIDApur, lContab)

Local cAliasLoad	:= x175Query('F2K', {cIdApur})
Local cStatus       := ""
Default lContab     :=.F.

If (cAliasLoad)->(!Eof())

    //Verifica se existe saldo devedor
    IF (cAliasLoad)->F2K_SLDDEV > 0
        cStatus := "1"
        
        //Precisa verificar na tabela F2L se existe t�tulo para esta apura��o
        dbSelectArea("F2L")
        F2L->(dbSetOrder(2)) //F2L_FILIAL+F2L_IDAPUR 
        IF F2L->(MsSeek(xFilial("F2L") + cIDApur))
            //Apura��o com saldo devedor que possui t�tulo gerado.            
            cStatus := Iif(lContab, "5", "2")
        EndIF

    //Verifica se existe valor de saldo credor
    ElseIF (cAliasLoad)->F2K_SLDATU > 0
        cStatus := "3"
    //Sem saldo devedor/credor
    ElseIF (cAliasLoad)->F2K_SLDATU +  (cAliasLoad)->F2K_SLDDEV == 0
        cStatus := "4"
    EndIF

EndIF

//Fecha o alias da query
(cAliasLoad)->(dbCloseArea())

//Atualiza F2H
dbSelectArea("F2H")
F2H->(dbSetOrder(3)) //F2H_FILIAL+F2H_ID
If !Empty(cStatus) .AND. F2H->(MsSeek(xFilial("F2H") + cIDApur))
    RecLock("F2H", .F.)
    F2H->F2H_STATUS := cStatus
    F2H->(MsUnlock())
EndIf

// Retorna F2H p/ �ndice 1 para n�o afetar o browse do FISA170.
F2H->(dbSetOrder(1)) //F2H_FILIAL+DTOS(F2H_DTINI)+DTOS(F2H_DTFIN)+F2H_TRIB+F2H_ID

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} x175SldStr()

Fun��o respons�vel por retornar a estrutura do array a ser utilizado
para manipula��o dos saldos da apura��o (tabela F2I). Sempre que for 
necess�rio manipular ou retornar informa��es sobre saldos esta estrutura
deve ser respeitada.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 22/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175SldStr()

Local aRet := Array(6)

aRet[1] := "" // ID da F2I - Opcional
aRet[2] := "" // Tipo do Saldo
aRet[3] := 0 // Saldo Inicial
aRet[4] := 0 // Saldo Utilizado
aRet[5] := 0 // Saldo Final
aRet[6] := cToD("//") // Data de origem

Return aClone(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} x175DelF2I()

Fun��o respons�vel por excluir uma linha espec�fica da tabela F2I.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 06/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function x175DelF2I(cIdApur, dDtOriSld)

Local cQuery := ""

cQuery := "DELETE FROM " + RetSqlName("F2I") + " "
cQuery += "WHERE F2I_FILIAL = " + ValToSQL(xFilial("F2I")) + " AND "
cQuery += "F2I_IDAPUR = " + ValToSQL(cIdApur) + " AND "
cQuery += "F2I_DTORI = " + ValToSQL(dDtOriSld)

TcSqlExec(cQuery)

Return
