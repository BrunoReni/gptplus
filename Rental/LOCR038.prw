//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define PAD_JUSTIF  3
 
//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
 
//Colunas Pedido de Venda
#Define COL_01      0015
#Define COL_02      0040
#Define COL_03      0120
#Define COL_04      0250
#Define COL_05      0350
#Define COL_06      0390
#Define COL_07      0400
#Define COL_08      0470

// Colunas Medição
#Define MCOL_01      0015
#Define MCOL_02      0050
#Define MCOL_03      0085
#Define MCOL_04      0170
#Define MCOL_05      0215
#Define MCOL_06      0200
#Define MCOL_07      0215
#Define MCOL_08      0260
#Define MCOL_09      0300
#Define MCOL_10      0345
#Define MCOL_11      0380
#Define MCOL_12      0420
#Define MCOL_13      0470

#Define COL_TOT      370

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR038
Relatorio Custo Extra
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Function LOCR038()
    Local aArea  := GetArea()
     
    Processa({|| fMontaRel()}, "Processando...")

    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Função que monta o relatório                                 |
 *---------------------------------------------------------------------*/
Static Function fMontaRel()
    Local cCaminho  := ""
    Local cArquivo  := ""
    Local cQry038   := ""
    Local cAlias038 := GetNextAlias()
    Local cPerLoc   := ""
    Local cPedAtu   := ""
    Local cNota     := ""

    Local nAtual    := 0
    Local nTotal    := 0
    Local nTotGeral := 0
    Local nColObs   := 470
    Local nLargTit  := 0
    Local nPagina   := 1
    Local nValPed   := 0
    Local nTotPed   := 0
    Local nTotMed   := 0
    Local nTotCus   := 0
    Local nDiasPer  := 0

    Local aAreaFp0  := FP0->(GetArea())
    Local aAreaFpa  := FPA->(GetArea())
    Local aAreaFpn  := FPN->(GetArea())
    Local aAreaFpg  := FPG->(GetArea())
    Local aAreaSC6  := SC6->(GetArea())
    
    Local lPriPed   := .T.
    Local lPedido   := .T.
    Local lPriMed   := .T.
    Local lMedicao  := .F.
    Local lPriCus   := .T.
    Local lCustoExt := .F.
    Local lContinua := .F.

    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 800
    Private nColIni   := 010
    Private nColFin   := 550
    Private nColHora  := 470
    Private nColMeio  := (nColFin-nColIni)/2
    //Objeto de Impressão
    Private oPrintPvt
    //Variáveis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    Private nPagAtu   := 1
    Private cNomeUsr  := UsrRetName(RetCodUsr())
    Private cCpoProj  := "TJ_PROJETO"
    Private cCpoAs    := "TJ_AS"
    //Fontes
    Private cNomeFont := "Arial"
    Private oFontGigN := TFont():New(cNomeFont, 9, -20, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTitN := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .F., 5, .T., 5, .T., .F.)
    Private oBrush1   := TBrush():New( , CLR_HGRAY)

    Private ECOL_01 := 015
    Private ECOL_02 := 060
    Private ECOL_03 := 120
    Private ECOL_04 := 180
    Private ECOL_05 := 250
    Private ECOL_06 := 470
     
    //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
    cCaminho  := GetTempPath()
    cArquivo  := "LOCR038_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
        
    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)
    //altera local de impressão para não gerar problema em alguns ambientes
    oPrintPvt:cFilePrint := cCaminho + cArquivo

    If Pergunte("LOCR038", .T.)

        //Setando os atributos necessários do relatório
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(60, 60, 60, 60)

        //Localizo o centro da pagina
        nLargTit := oPrintPvt:nHorzSize()

        //Montando a consulta dos pedidos
        cQry038 := " SELECT FP0_PROJET, FP0_CLI,FP0_LOJA, " + CRLF
        cQry038 += "        SA1A. A1_NOME CLIFP0,SA1A. A1_CGC,  " + CRLF
        cQry038 += "        A3_NOME,SA1B. A1_COD CODSC5, SA1B. A1_LOJA LOJSC5, SA1B. A1_NOME CLISC5,  " + CRLF
        cQry038 += "        C6_NOTA, C6_SERIE,C6_DATFAT, C6_VALOR , " + CRLF
        cQry038 += "        C5_FILIAL, C5_NUM, C6_QTDVEN, C6_DESCRI, C6_XPERLOC," + CRLF
        cQry038 += "        FPA_NFREM , FPA_SERREM, FPA_DNFREM, FPA_GRUA, FPA_TIPOSE, FPA_VRHOR " + CRLF
        cQry038 += " FROM " + RetSqlName("SC5") + " SC5 " + CRLF

        cQry038 += " INNER JOIN " + RetSqlName("FP0") + " FP0 ON " + CRLF
        cQry038 += "    FP0_FILIAL = '" + xFilial("FP0") + "' " + CRLF
        cQry038 += "    AND FP0.D_E_L_E_T_ = ' '  " + CRLF
        cQry038 += "    AND FP0_PROJET = C5_XPROJET " + CRLF

        cQry038 += " INNER JOIN " + RetSqlName("FPA") + " FPA ON " + CRLF
        cQry038 += "    FPA_FILIAL = FP0_FILIAL " + CRLF
        cQry038 += "    AND FPA.D_E_L_E_T_ = ' ' " + CRLF
        cQry038 += "    AND FPA_PROJET = FP0_PROJET " + CRLF
        
        cQry038 += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON " + CRLF
        cQry038 += "    C6_FILIAL = C5_FILIAL " + CRLF
        cQry038 += "    AND SC6.D_E_L_E_T_ = ' ' " + CRLF
        cQry038 += "    AND C6_NUM = C5_NUM " + CRLF
        cQry038 += "   AND C6_XAS = FPA_AS " + CRLF

        // Pedidos Faturados 1=Sim, 2=Não, 3=Ambos
        If MV_PAR06 == 1
            cQry038 += "   AND C6_NOTA <> '' " + CRLF   
        ElseIf MV_PAR06 == 2
            cQry038 += "   AND C6_NOTA = '' " + CRLF   
        EndIf

        cQry038 += " INNER JOIN " + RetSqlName("SA1") + " SA1A ON " + CRLF
        cQry038 += "    SA1A.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
        cQry038 += "    AND SA1A.D_E_L_E_T_ = ' '  " + CRLF
        cQry038 += "    AND SA1A.A1_COD = FP0_CLI " + CRLF
        cQry038 += "    AND SA1A.A1_LOJA = FP0_LOJA " + CRLF

        cQry038 += " INNER JOIN " + RetSqlName("SA1") + " SA1B ON " + CRLF
        cQry038 += "    SA1B.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
        cQry038 += "    AND SA1B.D_E_L_E_T_ = ' '  " + CRLF
        cQry038 += " AND SA1B.A1_COD = C5_CLIENTE " + CRLF
        cQry038 += " AND SA1B.A1_LOJA = C5_LOJACLI " + CRLF

        cQry038 += " LEFT JOIN " + RetSqlName("SA3") + " SA3 ON " + CRLF
        cQry038 += "    A3_FILIAL = '" + xFilial("SA3") + "' " + CRLF
        cQry038 += "    AND SA3.D_E_L_E_T_ = ' '  " + CRLF
        cQry038 += "    AND A3_COD = FP0_VENDED " + CRLF

        cQry038 += " WHERE " + CRLF
        cQry038 += "    C5_FILIAL = '" + xFilial("SC5") + "'  " + CRLF
        cQry038 += "    AND SC5.D_E_L_E_T_ = ' '  " + CRLF
        cQry038 += "    AND C5_ORIGEM = 'LOCA021' " + CRLF //Somento LOCA021 - informação passado pelo Lui em 18/05/2023
        cQry038 += "    AND C5_XPROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
        cQry038 += "    AND C5_NUM BETWEEN '" + AllTrim(MV_PAR02) + "' AND '" + AllTrim(MV_PAR03) + "' " + CRLF
        cQry038 += "    AND C5_EMISSAO BETWEEN '" + DtoS(MV_PAR04) + "' AND '" + DtoS(MV_PAR05) + "' " + CRLF

        //não traz pedidos que estão no Custo Extra
        //cQry038 += "    AND C5_NUM NOT IN (" + CRLF
        //cQry038 += "        SELECT FPG_PVNUM FROM " + RetSqlName("FPG") + CRLF
        cQry038 += "    AND C5_NUM+C6_ITEM NOT IN (" + CRLF
        cQry038 += "        SELECT FPG_PVNUM+FPG_PVITEM FROM " + RetSqlName("FPG") + CRLF
        cQry038 += "        WHERE FPG_FILIAL = '" + xFilial("FPG") + "' " + CRLF
        cQry038 += "        AND D_E_L_E_T_ = ' ' " + CRLF
        cQry038 += "        AND FPG_PVNUM <> '' " + CRLF
        cQry038 += "        AND FPG_PROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
        cQry038 += "    ) " + CRLF

        cQry038 += " ORDER BY C6_NUM, C6_XPERLOC, FPA_SERREM, FPA_NFREM, C6_ITEM " + CRLF

        //Executa consulta
        IncProc("Buscando Pedidos de Venda...")
        cQry038 := ChangeQuery(cQry038)
        DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry038),cAlias038,.T.,.T.)
        
        //Conta o total de registros, seta o tamanho da régua, e volta pro topo
        Count To nTotal
        (cAlias038)->(dbgotop())
        ProcRegua(nTotal)
        nAtual := 0
        
        //Pedidos Faturamento Automatico
        If  !(cAlias038)->(EoF())

            lContinua := .T.
            
            //Pega período
            //cPerLoc := (cAlias038)->C6_XPERLOC
            cPerLoc := RetPeriod((cAlias038)->C5_FILIAL,(cAlias038)->C5_NUM) //retorna menor e maior periodo do pedido

            While !(cAlias038)->(EoF())
                
                //totalizadores
                nValPed += (cAlias038)->C6_VALOR
                nTotPed += (cAlias038)->C6_VALOR

                //Gera cabeçalho
                GeraCabs(@nLinAtu,@nPagina,@lPriPed,@lPedido,@lPriMed,@lMedicao,@lPriCus,@lCustoExt,cAlias038,@cPerLoc,@cPedAtu,@cNota)

                //calcula dias do periodo
                nDiasPer := CtoD(Substr((cAlias038)->C6_XPERLOC,14,10)) - CtoD(Substr((cAlias038)->C6_XPERLOC,1,10)) + 1 

                //imprime os campos
                oPrintPvt:SayAlign(nLinAtu, COL_01, MascCampo("SC6","C6_QTDVEN",(cAlias038)->C6_QTDVEN) , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                oPrintPvt:SayAlign(nLinAtu, COL_02, (cAlias038)->C6_DESCRI                              , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                oPrintPvt:SayAlign(nLinAtu, COL_03, (cAlias038)->FPA_GRUA                               , oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                oPrintPvt:SayAlign(nLinAtu, COL_04, (cAlias038)->C6_XPERLOC                               , oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                oPrintPvt:SayAlign(nLinAtu, COL_05, cValToChar(nDiasPer)                                , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                oPrintPvt:SayAlign(nLinAtu, COL_06, IIF((cAlias038)->FPA_TIPOSE == "S","Sim","Não")     , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                oPrintPvt:SayAlign(nLinAtu, COL_07, MascCampo("FPA","FPA_VRHOR",(cAlias038)->FPA_VRHOR) , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                oPrintPvt:SayAlign(nLinAtu, COL_08, MascCampo("SC6","C6_VALOR",(cAlias038)->C6_VALOR)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                
                nLinAtu := nLinAtu + nTamLin   
      
                (cAlias038)->(DbSkip())

                //apresenta o total
                If cPedAtu <> (cAlias038)->C5_NUM
                    oPrintPvt:SayAlign(nLinAtu, COL_TOT, "Total Pedido: " + MascCampo("SC6","C6_VALOR",nValPed)   , oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    nLinAtu := nLinAtu + nTamLin   
                    nValPed := 0
                EndIf

            EndDo
        EndIf

        //fecha query PV
        (cAlias038)->(DbCloseArea())

        // Medições
        If MV_PAR07 == 1

            //atualiza variaveis para cabeçalho
            lMedicao    := .T.
            lPriMed     := .T.
            lPedido     := .F.
            lPriPed     := .F.
            
            //monta consulta
            cQry038 := " SELECT FPN_FILIAL,FPN_COD,FPN_NUMPV,FPN_DTINIC,FPN_DTFIM,FPN_CONANT,FPN_POSCON,FPN_VALTOT,FPN_VALSER,  " + CRLF
            cQry038 += " FPA_HRFRAQ,FPA_VLHREX,FPA_GRUA, " + CRLF
            cQry038 += " B1_UM " + CRLF
            cQry038 += " FROM " + RetSqlName("FPN") + " FPN " + CRLF
            cQry038 += " INNER JOIN " + RetSqlName("FPA") + " FPA ON " + CRLF
            cQry038 += " FPA_FILIAL = '" + xFilial("FPA") + "' " + CRLF
            cQry038 += " AND FPA.D_E_L_E_T_ = ' ' " + CRLF
            cQry038 += " AND FPA_AS = FPN_AS " + CRLF
            cQry038 += " AND FPA_AS <> '' " + CRLF
            cQry038 += " INNER JOIN " + RetSqlName("ST9") + " ST9 ON " + CRLF
            cQry038 += " FPA_FILIAL = '" + xFilial("ST9") + "' " + CRLF
            cQry038 += " AND ST9.D_E_L_E_T_ = ' ' " + CRLF
            cQry038 += " AND T9_CODBEM = FPA_GRUA " + CRLF
            cQry038 += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON " + CRLF
            cQry038 += " B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
            cQry038 += " AND SB1.D_E_L_E_T_ = ' ' " + CRLF
            cQry038 += " AND T9_CODESTO = B1_COD " + CRLF
            cQry038 += " WHERE FPN_FILIAL = '" + xFilial("FPN") + "' " + CRLF
            cQry038 += " AND FPN.D_E_L_E_T_ = ' ' " + CRLF
            cQry038 += " AND FPN_NUMPV <> '' " + CRLF
            cQry038 += " AND FPN_PROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF

            //executa consulta
            IncProc("Buscando Medições...")
            cQry038 := ChangeQuery(cQry038)
            DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry038),cAlias038,.T.,.T.)

            If !(cAlias038)->(EoF())

                lContinua := .T.

                While !(cAlias038)->(EoF())

                    //totalizador
                    nTotMed += (cAlias038)->FPN_VALSER

                    //monta cabeçalho
                    GeraCabs(@nLinAtu,@nPagina,@lPriPed,@lPedido,@lPriMed,@lMedicao,@lPriCus,@lCustoExt,cAlias038,@cPerLoc,@cPedAtu,@cNota)

                    oPrintPvt:SayAlign(nLinAtu, MCOL_01, (cAlias038)->FPN_COD               , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_02, (cAlias038)->FPN_NUMPV             , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_03, (cAlias038)->FPA_GRUA              , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_04, DtoC(StoD((cAlias038)->FPN_DTINIC)), oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_05, DtoC(StoD((cAlias038)->FPN_DTFIM)) , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_06, MascCampo("FPN","FPN_POSCON",(cAlias038)->FPN_POSCON - (cAlias038)->FPN_CONANT)  , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_07, (cAlias038)->B1_UM                 , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_08, MascCampo("FPA","FPA_HRFRAQ",(cAlias038)->FPA_HRFRAQ)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_09, MascCampo("FPN","FPN_CONANT",(cAlias038)->FPN_CONANT)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_10, MascCampo("FPN","FPN_POSCON",(cAlias038)->FPN_POSCON)   , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_11, SomaHoras((cAlias038)->FPN_FILIAL,(cAlias038)->FPN_COD ), oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_12, MascCampo("FPA","FPA_VLHREX",(cAlias038)->FPA_VLHREX)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    oPrintPvt:SayAlign(nLinAtu, MCOL_13, MascCampo("FPN","FPN_VALSER",(cAlias038)->FPN_VALSER)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)

                    nLinAtu := nLinAtu + nTamLin
                    
                    (cAlias038)->(DbSkip())

                EndDo

                //apresenta totalizador
                oPrintPvt:SayAlign(nLinAtu, COL_TOT, "Total Medições: " + MascCampo("FPN","FPN_VALSER",nTotMed)   , oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                nLinAtu := nLinAtu + nTamLin   

            EndIf

            (cAlias038)->(DbCloseArea())
        EndIf

        // Custo Extra
        If MV_PAR08 == 1

            //variaveis para cabeçalho
            lMedicao    := .F.
            lPriMed     := .F.
            lCustoExt   := .T.
            lPriCus     := .T.
            
            //monta consulta
            cQry038 := " SELECT FPG.R_E_C_N_O_ RECFPG, SC6.R_E_C_N_O_ RECSC6 FROM " + RetSqlName("FPG") + " FPG " + CRLF
            cQry038 += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON " + CRLF
            cQry038 += "    C6_FILIAL = '" + xFilial("SC6") + "'  " + CRLF
            cQry038 += "    AND SC6.D_E_L_E_T_ = ' '  " + CRLF
            cQry038 += "    AND C6_NUM = FPG_PVNUM " + CRLF
            cQry038 += "    AND C6_ITEM = FPG_PVITEM " + CRLF
            cQry038 += " WHERE FPG_FILIAL = '" + xFilial("FPG") + "' " + CRLF
            cQry038 += "    AND FPG.D_E_L_E_T_ = ' ' " + CRLF
            cQry038 += "    AND FPG_PVNUM <> '' " + CRLF
            cQry038 += "    AND FPG_PROJET = '" + AllTrim(MV_PAR01) + "' " + CRLF
            cQry038 += "    AND FPG_DTENT BETWEEN '" + DtoS(MV_PAR09) + "' AND '" + DtoS(MV_PAR10) + "' " + CRLF
            cQry038 += " ORDER BY FPG_DTENT " + CRLF

            //executa
            cQry038 := ChangeQuery(cQry038)
            IncProc("Buscando Custos Extra...")
            DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry038),cAlias038,.T.,.T.)

            If  !(cAlias038)->(EoF())

                lContinua   := .T.
                lPedido     := .F.
                
                While !(cAlias038)->(EoF())

                    //cabeçalho
                    GeraCabs(@nLinAtu,@nPagina,@lPriPed,@lPedido,@lPriMed,@lMedicao,@lPriCus,@lCustoExt,cAlias038,@cPerLoc,@cPedAtu,@cNota)

                    //posiciona no custo extra
                    FPG->(DbGoTo((cAlias038)->RECFPG))
                    SC6->(DbGoTo((cAlias038)->RECSC6))

                    //totalizador
                    nTotCus += FPG->FPG_VALTOT

                    oPrintPvt:SayAlign(nLinAtu, ECOL_01, AllTrim(FPG->FPG_PVNUM)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, ECOL_02, DtoC(FPG->FPG_DTENT)    , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, ECOL_03, MascCampo("FPG","FPG_QUANT",FPG->FPG_QUANT )  , oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    //oPrintPvt:SayAlign(nLinAtu, ECOL_04, AllTrim(FPG->FPG_DESCRI)    , oFontDet, 0160, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    oPrintPvt:SayAlign(nLinAtu, ECOL_04, AllTrim(FPG->FPG_DESCRI)    , oFontDet, 0160, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                    If FPG->(FieldPos("FPG_OBSERV")) > 0    //proteger campo caso não exista
                        oPrintPvt:SayAlign(nLinAtu, ECOL_05, (FPG->FPG_OBSERV)   , oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT  , 0) 
                    EndIf
                    oPrintPvt:SayAlign(nLinAtu, ECOL_06, MascCampo("FPG","FPG_VALTOT",FPG->FPG_VALTOT )  , oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                    nLinAtu := nLinAtu + nTamLin
                    
                    (cAlias038)->(DbSkip())

                EndDo

                //totalizador
                oPrintPvt:SayAlign(nLinAtu, COL_TOT, "Total Custo Extra: " + MascCampo("FPG","FPG_VALTOT",nTotCus)   , oFontDetN, 0180, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                nLinAtu := nLinAtu + nTamLin   

            EndIf

            (cAlias038)->(DbCloseArea())
        EndIf
                
        If lContinua

            //Se ainda tiver linhas sobrando na página, imprime o rodapé final
            nLinAtu := nLinAtu + nTamLin

            nTotGeral := nTotPed + nTotMed + nTotCus
            oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin + 5 , nColFin }, oBrush1, "-2")
            oPrintPvt:SayAlign(nLinAtu, 150, "Total Geral ", oFontTitN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)
            nLinAtu := nLinAtu + (nTamLin * 2) + 5
            oPrintPvt:SayAlign(nLinAtu, 0, "R$ " + AllTrim(Transform(nTotGeral,"@E 999,999,999.99")) + " (" + Extenso(nTotGeral,.F.,1) + " )"     ,  oFontDetN, nLargTit, nTamLin, COR_PRETO, PAD_CENTER, 0)
            nLinAtu := nLinAtu + (nTamLin * 2)

        Else
            oPrintPvt:SayAlign(nLinAtu, nColIni + 60    , "Não existem registros para o filtro selecionado."                   , oFontDet  , nColObs, nTamLin, COR_PRETO, PAD_JUSTIF   , 0)
        EndIf

        oPrintPvt:Preview()

    EndIf 

    RestArea(aAreaFp0)
    RestArea(aAreaFpa)
    RestArea(aAreaFpn)
    RestArea(aAreaFpg)
    RestArea(aAreaSC6)

Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpCab1                                                     |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/
Static Function fImpCab1(nPagina)
    //Local cTexto 	:= ""
    Local cLogoRel	:= RetLogo()
    Local nLinCab	:= 030
	Local nLogoH	:= 33
    Local nLogoW	:= 112
	Local aEmpInfo	:= FWSM0Util():GetSM0Data()
	Local cEmpNome	:= AllTrim(aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_FILIAL"})][2])
	Local cEmpCom	:= AllTrim(aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_NOMECOM"})][2])
    Local cNomeRel  := "Demonstrativo de Faturamento"
     
    Default nPagina := 0

    //Iniciando Página
    oPrintPvt:StartPage()
    
    //Cabeçalho
	nLinCab += (nTamLin * 1.5)
	oPrintPvt:SayBitmap( nLinCab, nColIni, cLogoRel, nLogoW, nLogoH)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cEmpNome, oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinCab, nColHora, DtoC(dDataGer) + " " + cHoraGer,	oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
    nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cNomeRel, oFontTitN, 240, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinCab, nColHora, cEmpCom + IIF(!Empty(cEmpCom),"/","") + cNomeUsr, 						oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
    nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColHora, "página " + cValToChar(nPagina), 						oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
    
    //Linha Separatória
    nLinCab += (nTamLin * 2)
    oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, COR_CINZA)
	
    //Cabeçalho das colunas
    nLinCab += nTamLin
     
    //Atualizando a linha inicial do relatório
    nLinAtu := nLinCab + 3
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fImpCab2
Imprime segundo cabeçalho
@author Jose Eulalio
@since 16/05/2023
/*/
//---------------------------------------------------------------------
Static Function fImpCab2(cAlias038)

    Local aAreaSa1  := SA1->(GetArea())
    Local cCgc      := ""

    Local cProjeto  := (cAlias038)->FP0_PROJET

    SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
    SA1->(DbSeek(xFilial("SA1") + (cAlias038)->(FP0_CLI+FP0_LOJA) ))
    cCgc := MascCgc(SA1->A1_CGC,SA1->A1_PESSOA)

    oPrintPvt:SayAlign(nLinAtu-08, nColIni         , "Projeto: " + cProjeto , oFontTitN, 0240, nTamLin, COR_PRETO, PAD_LEFT  , 0)
	nLinAtu += nTamLin

    //Cabeçalho 2
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Cliente:"        , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
   // oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_NOME      , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , AllTrim(SA1->A1_COD) +"|" + AllTrim(SA1->A1_LOJA) + " - " + SA1->A1_NOME      , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "CNPJ:"           , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , cCgc              , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06 - 40     , "Inscr.Estadual:", oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06 + 20     , SA1->A1_INSCR     , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Contato:"        , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    //oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_CONTATO   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , AllTrim(FP0->FP0_CLICON) + " - " + FP0->FP0_NOMECON, oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06 - 40   , "Fone:"             , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06        , SA1->A1_TEL         , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
	nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Endereço:"       , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_END       , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Vendedor:"       , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    //oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_VEND      , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , AllTrim(FP0->FP0_VENDED) + " - " + FP0->FP0_NOMVEN      , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06 - 40     , "Faturar para:"   , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    //oPrintPvt:SayAlign(nLinAtu, COL_06 + 20     , (cAlias038)->CLISC5  , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, COL_06 + 20     , AllTrim((cAlias038)->CODSC5) +"|" + AllTrim((cAlias038)->LOJSC5) + " - " + (cAlias038)->CLISC5  , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)

    //Linha Separatória
    //nLinAtu += (nTamLin * 2)
    //oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
	
    //Cabeçalho das colunas
    nLinAtu += nTamLin

    //Atualizando a linha inicial do relatório
    nLinAtu := nLinAtu + 3

    RestArea(aAreaSa1)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} RetLogo
Retorna logotipo da empresa
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function RetLogo()
Local cLogo := SuperGetMv("MV_LOCXLOG",.F.,"C:\itup\img\logo_totvs.jpg") // define via parametro o logo do relatorio

// se não pega logo customizado
If Empty(cLogo) .Or. !File(cLogo)
	/*
	cLogo := "LGMID" + cEmpAnt + cFilAnt + ".PNG"
	If !File(cLogo)
		cLogo := "LGMID" + cEmpAnt + ".PNG"
	EndIf
	If !File(cLogo)
		cLogo := "LGMID.PNG"
	EndIf
	*/
	If !File(cLogo)
		cLogo := "lgrl" + cEmpAnt + ".bmp"
	EndIf
	If !File(cLogo)
		cLogo := "lgrl.bmp"
	EndIf
	If !File(cLogo)
		cLogo := ""
	EndIf
EndIf

Return cLogo

//---------------------------------------------------------------------
/*/{Protheus.doc} MascCgc
Retorna CGC com máscara para CPF ou CNPJ
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function MascCgc(cCgc,cPessoa)
Local cMascara  := ""

If cPessoa == "F"
    cMascara := "@R 999.999.999-99"
Else
    cMascara := "@R 99.999.999/9999-99"
EndIf

cCgc := Transform(cCgc,cMascara)

Return cCgc

//---------------------------------------------------------------------
/*/{Protheus.doc} MascCampo
Retorna valor de acordo com a máscara do campo
@author Jose Eulalio
@since 16/05/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function MascCampo(cAliasMasc,cCampoMasc,xValor)
Local cRet      := ""
Local cMascara  := PesqPict( cAliasMasc, cCampoMasc )

cRet := AllTrim(Transform(xValor,cMascara))

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraCabs
Gera os cabeçalhos de acordo a necesidade
@author Jose Eulalio
@since 16/05/2023
/*/
//---------------------------------------------------------------------
Static Function GeraCabs(nLinAtu,nPagina,lPriPed,lPedido,lPriMed,lMedicao,lPriCus,lCustoExt,cAlias038,cPerLoc,cPedAtu,cNota)

If (lPedido .And. (lPriPed .Or. cPedAtu <> (cAlias038)->C5_NUM )) .Or. nLinAtu + nTamLin > (nLinFin - 60)

    //Imprime o cabeçalho
    If lPriPed .Or.  nLinAtu + nTamLin > (nLinFin - 60)
        fImpCab1(@nPagina)
        If lPedido
            fImpCab2(cAlias038)
        EndIf
    EndIf
    
    If lPedido
        //cPerLoc     := (cAlias038)->C6_XPERLOC
        cPerLoc     := RetPeriod((cAlias038)->C5_FILIAL,(cAlias038)->C5_NUM)

        //cabeçalho primeira linha
        nLinAtu := nLinAtu + 03
        oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin , nColFin }, oBrush1, "-2")
        oPrintPvt:SayAlign(nLinAtu, COL_02, "Período de Faturamento: " + cPerLoc       , oFontDetN, 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, COL_04, "Pedido de Venda: " + (cAlias038)->C5_NUM  , oFontDetN, 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)
        nLinAtu := nLinAtu + nTamLin
    EndIf

EndIf

If lMedicao .And. lPriMed
    nLinAtu := nLinAtu + nTamLin

    oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin + 5 , nColFin }, oBrush1, "-2")
    oPrintPvt:SayAlign(nLinAtu, 150, "MEDIÇÕES ", oFontTitN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)

    nLinAtu := nLinAtu + nTamLin + 10

    oPrintPvt:SayAlign(nLinAtu, MCOL_01, "Medição"      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_02, "P.Venda"      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_03, "Patrimônio"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_04, "Dt Inicial"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_05, "Dt Final"     , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_06, "Quant"        , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_07, "UN"           , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_08, "Contratado"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_09, "Cont.Inic."   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_10, "Cont.Final"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_11, "Cobrado"      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_12, "Vlr. Unit."   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    oPrintPvt:SayAlign(nLinAtu, MCOL_13, "Vlr. Total"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
    
    nLinAtu := nLinAtu + nTamLin
    
    lPriPed := .F.
    lPriMed := .F.
EndIf

If lCustoExt .And. lPriCus
    nLinAtu := nLinAtu + nTamLin

    oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin + 5 , nColFin }, oBrush1, "-2")
    oPrintPvt:SayAlign(nLinAtu, 150, "CUSTO EXTRA ", oFontTitN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)

    nLinAtu := nLinAtu + nTamLin + 10

    oPrintPvt:SayAlign(nLinAtu, ECOL_01, "Ped.Venda"    , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, ECOL_02, "Data Base"    , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, ECOL_03, "Quantidade"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, ECOL_04, "Descrição"    , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, ECOL_05, "Observação"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, ECOL_06, "Valor Total"  , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)

    nLinAtu := nLinAtu + nTamLin
    
    lPriMed := .F.
    lPriCus := .F.
EndIf

If lPedido
    If (lPriPed .Or. cNota <> AllTrim((cAlias038)->FPA_NFREM) + "-" + AllTrim((cAlias038)->FPA_SERREM) .Or. cPedAtu <> (cAlias038)->C5_NUM) 

        lPriPed     := .F.
        cNota       := AllTrim((cAlias038)->FPA_NFREM) + "-" + AllTrim((cAlias038)->FPA_SERREM)
        cPedAtu     := (cAlias038)->C5_NUM

        oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)

        oPrintPvt:SayAlign(nLinAtu, COL_02      , "Remessa: "   , oFontDetN , 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, COL_02 + 50 , cNota         , oFontDet  , 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)

        oPrintPvt:SayAlign(nLinAtu, COL_04, "Data: "            , oFontDetN, 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)
        oPrintPvt:SayAlign(nLinAtu, COL_04 + 50, DtoC(StoD((cAlias038)->FPA_DNFREM)), oFontDet , 0240, nTamLin, COR_PRETO, PAD_LEFT, 0)

        nLinAtu := nLinAtu + nTamLin

        oPrintPvt:SayAlign(nLinAtu, COL_01, "Qtde"          , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
        oPrintPvt:SayAlign(nLinAtu, COL_02, "Equipamento"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
        oPrintPvt:SayAlign(nLinAtu, COL_03, "Bem"           , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
        oPrintPvt:SayAlign(nLinAtu, COL_04, "Periodo"           , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
        oPrintPvt:SayAlign(nLinAtu, COL_05, "Qtd.Dias"       , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
        oPrintPvt:SayAlign(nLinAtu, COL_06, "Subs"          , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
        oPrintPvt:SayAlign(nLinAtu, COL_07, "Valor Base"    , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
        oPrintPvt:SayAlign(nLinAtu, COL_08, "Valor Total"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
        
        nLinAtu := nLinAtu + nTamLin

    EndIf
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SomaHoras
Retorna as horas de uma medição
@author Jose Eulalio
@since 16/05/2023
/*/
//---------------------------------------------------------------------
Static Function SomaHoras(cFilFPP,cCodFPP)
Local cHoras    := ""
Local nHoras    := 0
Local aAreaFPP  := FPP->(GetArea())

FPP->(DbSetOrder(1)) //FPP_FILIAL+FPP_COD+FPP_ITEM+DTOS(FPP_DTMEDI)
If FPP->(DbSeek(cFilFPP+cCodFPP))
    While !(FPP->(Eof())) .And. FPP->(FPP_FILIAL+FPP_COD) == cFilFPP+cCodFPP
        nHoras += FPP->FPP_QTDHR
        FPP->(DbSkip())
    EndDo
EndIf

cHoras := cValToChar(nHoras)

RestArea(aAreaFPP)

Return cHoras

//---------------------------------------------------------------------
/*/{Protheus.doc} RetPeriod
Retorna String com maior e menor periodo de um pedido
@author Jose Eulalio
@since 18/05/2023
/*/
//---------------------------------------------------------------------
Static Function RetPeriod(cFilialPV,cNumPv)
Local cNewPeriod    := ""
Local dDataMin      := StoD("")
Local dDataMax      := StoD("")
Local dDataAux      := StoD("")
Local aAreaSC6      := SC6->(GetArea())

SC6->(DbSetOrder(1))
If SC6->(DbSeek(xFilial("SC6") + cNumPV))
    While !( SC6->(Eof())) .And. SC6->(C6_FILIAL+C6_NUM) == cFilialPV+cNumPv
        //pega menor data
        dDataAux := CtoD(Substr(SC6->C6_XPERLOC,1,10)) 
        If Empty(dDataMin) .Or. dDataAux < dDataMin
            dDataMin := dDataAux
        EndIf
        //pega maior data
        dDataAux := CtoD(Substr(SC6->C6_XPERLOC,14,10)) 
        If Empty(dDataMax) .Or. dDataAux > dDataMax
            dDataMax := dDataAux
        EndIf
        SC6->(DbSkip())
    EndDo
    cNewPeriod := DtoC(dDataMin) + " A " + DtoC(dDataMax)
EndIf

RestArea(aAreaSC6)

Return cNewPeriod
