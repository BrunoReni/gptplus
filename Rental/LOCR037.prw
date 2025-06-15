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
 
//Colunas
#Define COL_01      0015
#Define COL_02      0038
#Define COL_03      0060
#Define COL_04      0160
#Define COL_05      0310
#Define COL_06      0470

//---------------------------------------------------------------------
/*/{Protheus.doc} LOCR037
Relatorio Custo Extra
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Function LOCR037()
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
    Local cQryFPG   := ""
    Local cQrySTL   := ""
    Local cAliasFPG := GetNextAlias()
    Local cAliasSTL := GetNextAlias()
    Local cWhere    := ""
    Local cDocOri   := ""
    Local cTipoReg  := ""
    Local cCodProd  := ""
    Local cProd     := ""
    Local cUnid     := ""

    Local nX        := 0
    Local nAtual    := 0
    Local nTotal    := 0
    Local nSomaVlTot:= 0
    Local nTotOrcame:= 0
    Local nTotGeral := 0
    Local nColObs   := 470
    Local nLargTit  := 0

    Local aAnexos  := {}
    Local aChavAnex:= {}
    Local aAreaFp0  := FP0->(GetArea())
    Local aAreaStl  := STL->(GetArea())
    Local aAreaStj  := STJ->(GetArea())
    Local aAreaFpg  := FPG->(GetArea())
    Local aAreaSb1  := SB1->(GetArea())
    Local aFpgStat  := {}
    
    Local lPrimeiro := .T.
    Local lWhere    := .F.
    Local lLOCR037A := ExistBlock("LOCR037A") 

    Private nLinAtu   := 000
    Private nTamLin   := 010
    Private nLinFin   := 820
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
     
    //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
    cCaminho  := GetTempPath()
    cArquivo  := "locr037_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
        
    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)

    If Pergunte("LOCR037", .T.)

        //Corrige pergunte de combo, caso não tenha sido alterado o valor
        If valtype(MV_PAR05) == "N"
            MV_PAR05 := cValToChar(MV_PAR05)
        EndIf

        //faz de para dos status
        aFpgStat := StrToKarr(MV_PAR07,";") // 1 = Cobrar , 2 = Nao cobrar     , 3 = Falta Classific , 4 = Faturar
        If Len(aFpgStat) > 0
            cWhere += " AND ( "
            For nX := 1 To Len(aFpgStat)
                If lWhere
                    cWhere += " OR "
                EndIf
                If aFpgStat[nX] == "1"
                    cWhere += " (FPG_PVNUM = ''  AND FPG_STATUS = '1' AND FPG_COBRA = 'S' AND FPG_DTENT BETWEEN '" + DtoS(MV_PAR02) +  "' AND '" + DtoS(MV_PAR03) +  "') "  //Cobrar
                    lWhere := .T.
                ElseIf aFpgStat[nX] == "2"
                    cWhere += " (FPG_PVNUM = ''  AND FPG_STATUS = '1' AND FPG_COBRA = 'N') " //Nao Cobrar
                    lWhere := .T.
                ElseIf aFpgStat[nX] == "3"
                    cWhere += " (FPG_PVNUM = ''  AND FPG_STATUS = '1' AND (FPG_COBRA <> 'S' AND FPG_COBRA <> 'N')) " //Falta Classificar 
                    lWhere := .T.
                ElseIf aFpgStat[nX] == "4"
                    cWhere += " (FPG_PVNUM <> '' AND FPG_STATUS = '2' AND FPG_COBRA = 'S' AND FPG_DTENT BETWEEN '" + DtoS(MV_PAR02) +  "' AND '" + DtoS(MV_PAR03) +  "') " //Faturado
                    lWhere := .T.
                EndIf
            Next nX
            cWhere += " ) "
        EndIf

        FP0->(DbSetOrder(1)) //FP0_FILIAL+FP0_PROJET
        FP0->(DbSeek(xFilial("FP0") + AllTrim(MV_PAR01) ))
        
        //Setando os atributos necessários do relatório
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetPortrait()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(60, 60, 60, 60)

        //Localizo o centro da pagina
        nLargTit := oPrintPvt:nHorzSize()
  
        //Imprime o cabeçalho
        fImpCab1()
        fImpCab2()

        //verifica se já contém campos novos
        If STJ->(FIELDPOS("TJ_PROJET")) == 0 .And. STJ->(FIELDPOS("TJ_AS")) == 0
            cCpoProj  := "TJ_XPROJET"
            cCpoAs    := "TJ_XAS"
        EndIf

        //Montando a consulta
        cQryFPG := " SELECT " + CRLF
        cQryFPG += "    TJ_POSCONT, TJ_CODBEM,TJ_DTPPFIM,TJ_CODBEM, STJ.R_E_C_N_O_ RECSTJ, TJ_ORDEM, TJ_PLANO, TJ_SEQRELA, TJ_FILIAL, " + CRLF
        cQryFPG += "    FPA_NFRET , FPA_SERRET, FPA_DNFRET, " + CRLF
        cQryFPG += "    FQ4_POSCON, FQ4_DOCUME, FQ4_SERIE, " + CRLF
        cQryFPG += "    FPG_PROJET,FPG_OBRA,FPG_NRAS,FPG_PRODUT,FPG_DESCRI, FPG_VALOR,FPG_VALTOT,FPG_QUANT,FPG_QUANT,FPG_STATUS,FPG_SEQ, FPG_DOCORI, " + CRLF
        cQryFPG += "    FQ5_GUINDA " + CRLF
        cQryFPG += " FROM " + RetSqlName("FPG") + " FPG " + CRLF
        cQryFPG += " INNER JOIN " + RetSqlName("FPA") + " FPA  " + CRLF
        cQryFPG += " ON  " + CRLF
        cQryFPG += "    FPA_FILIAL = '" + xFilial("FPA") + "' " + CRLF
        cQryFPG += "    AND FPA.D_E_L_E_T_ =  ' ' " + CRLF
        cQryFPG += "    AND FPA_PROJET = FPG_PROJET " + CRLF
        cQryFPG += "    AND FPA_AS = FPG_NRAS " + CRLF
        cQryFPG += " LEFT JOIN " + RetSqlName("FQ4") + " FQ4 " + CRLF
        cQryFPG += " ON  " + CRLF
        cQryFPG += "    FQ4_FILIAL = '" + xFilial("FQ4") + "' " + CRLF
        cQryFPG += "    AND FQ4.D_E_L_E_T_ =  ' ' " + CRLF
        cQryFPG += "    AND FPA_GRUA = FQ4_CODBEM " + CRLF
        cQryFPG += "    AND FQ4_DOCUME = FPA_NFREM " + CRLF
        cQryFPG += "    AND FQ4_SERIE = FPA_SERREM " + CRLF
        cQryFPG += "    AND FQ4_DOCUME <> '' " + CRLF
        cQryFPG += " LEFT JOIN " + RetSqlName("STJ") + " STJ " + CRLF
        cQryFPG += " ON  " + CRLF
        cQryFPG += "    TJ_FILIAL = '" + xFilial("STJ") + "' " + CRLF
        cQryFPG += "    AND STJ.D_E_L_E_T_ =  ' ' " + CRLF
        cQryFPG += "    AND " + cCpoProj + " = FPG_PROJET " + CRLF
        cQryFPG += "    AND " + cCpoAs + " = FPG_NRAS " + CRLF
        cQryFPG += "    AND TJ_ORDEM = FPG_DOCORI " + CRLF
        cQryFPG += " INNER JOIN " + RetSqlName("FQ5") + " FQ5 " + CRLF
        cQryFPG += "  ON   " + CRLF
        cQryFPG += "     FQ5_FILIAL = '" + xFilial("FQ5") + "'  " + CRLF
        cQryFPG += "     AND FQ5.D_E_L_E_T_ =  ' '  " + CRLF
        cQryFPG += " AND FQ5_TPAS = 'L' " + CRLF
        cQryFPG += " AND FQ5_SOT = FPG_PROJET " + CRLF
        cQryFPG += " AND FQ5_AS = FPG_NRAS " + CRLF
        cQryFPG += " WHERE " + CRLF
        cQryFPG += "    FPG_FILIAL = '" + xFilial("FPG") + "' " + CRLF
        cQryFPG += "    AND FPG.D_E_L_E_T_ =  ' ' " + CRLF
        cQryFPG += "    AND FPG_PROJET = '" + MV_PAR01 +  "' " + CRLF
        //cQryFPG += "    AND FPG_DTENT BETWEEN '" + DtoS(MV_PAR02) +  "' AND '" + DtoS(MV_PAR03) +  "' " + CRLF
        cQryFPG += "    AND FPG_NRAS = '" + MV_PAR04 +  "' " + CRLF
        //condições do status
        cQryFPG += cWhere
        //Ordena query
        cQryFPG += "    ORDER BY TJ_ORDEM DESC " + CRLF

        cQryFPG := ChangeQuery(cQryFPG)
        MsAguarde( { || dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryFPG),cAliasFPG,.T.,.T.)},"Aguarde... Processando Dados...")
        
        //Conta o total de registros, seta o tamanho da régua, e volta pro topo
        Count To nTotal
        (cAliasFPG)->(dbgotop())
        ProcRegua(nTotal)
        nAtual := 0
        
        //Enquanto houver registros
        If  !(cAliasFPG)->(EoF())
            While !(cAliasFPG)->(EoF())

                //se for documento original diferente imprime
                If cDocOri <> (cAliasFPG)->FPG_DOCORI

                    //adiciona chave da STL para localizar os anexos
                    If MV_PAR05 = "1"
                        Aadd(aChavAnex,"STJ"+xFilial("STJ")+(cAliasFPG)->FPG_DOCORI)
                    EndIf

                    //inicia variaveis
                    nSomaVlTot  := 0
                    nTotOrcame  := 0
                    lPrimeiro   := .T.
                    nAtual++
                    IncProc("Imprimindo OS " + AllTrim((cAliasFPG)->FPG_DOCORI) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

                    fImpCab3(cAliasFPG)

                    //roda query com os itens da STL
                    cQrySTL := " SELECT  " + CRLF
                    cQrySTL += "     TL_CODIGO,TL_QUANTID,TL_UNIDADE,TL_CODIGO,TL_TIPOREG, STL.R_E_C_N_O_ RECSTL,  " + CRLF
                    cQrySTL += "     TJ_POSCONT, TJ_CODBEM,TJ_DTPPFIM,TJ_CODBEM, STJ.R_E_C_N_O_ RECSTJ, TJ_ORDEM, TJ_PLANO, TJ_SEQRELA, " + CRLF
                    cQrySTL += "     FPG_FILIAL, FPG_PROJET,FPG_OBRA,FPG_NRAS,FPG_PRODUT,FPG_DESCRI, FPG_VALOR,FPG_VALTOT,FPG_QUANT,FPG_STATUS,FPG_SEQ, FPG_DOCORI, FPG.R_E_C_N_O_ RECFPG  " + CRLF
                    cQrySTL += "  FROM " + RetSqlName("FPG") + " FPG  " + CRLF
                    cQrySTL += "  LEFT JOIN " + RetSqlName("STJ") + " STJ  " + CRLF
                    cQrySTL += "  ON   " + CRLF
                    cQrySTL += "     TJ_FILIAL = '" + xFilial("STJ") + "'  " + CRLF
                    cQrySTL += "     AND STJ.D_E_L_E_T_ =  ' '  " + CRLF
                    cQrySTL += "     AND TJ_PROJETO = FPG_PROJET  " + CRLF
                    cQrySTL += "     AND TJ_AS = FPG_NRAS  " + CRLF
                    cQrySTL += " AND TJ_ORDEM = FPG_DOCORI " + CRLF
                    cQrySTL += "  LEFT JOIN " + RetSqlName("STL") + " STL " + CRLF
                    cQrySTL += "  ON   " + CRLF
                    cQrySTL += "     TL_FILIAL = '" + xFilial("STL") + "'  " + CRLF
                    cQrySTL += "     AND STL.D_E_L_E_T_ =  ' '  " + CRLF
                    cQrySTL += "     AND TL_ORDEM = TJ_ORDEM " + CRLF
                    cQrySTL += "    AND TL_PLANO = TJ_PLANO " + CRLF
                    //cQrySTL += "    AND TL_SEQRELA = TJ_SEQRELA " + CRLF
                    //cQrySTL += "    AND TL_CODIGO = FPG_PRODUT " + CRLF
                    cQrySTL += "    AND TL_QUANTID = FPG_QUANT " + CRLF
                    cQrySTL += "    AND TL_REPFIM <> ' ' " + CRLF
                    cQrySTL += "  WHERE  " + CRLF
                    cQrySTL += "     FPG_FILIAL = '" + xFilial("FPG") + "'  " + CRLF
                    cQrySTL += "     AND FPG.D_E_L_E_T_ =  ' '  " + CRLF
                    cQrySTL += "     AND FPG_PROJET = '" + MV_PAR01 + "'  " + CRLF
                    cQrySTL += "     AND FPG_NRAS = '" + MV_PAR04 + "'      " + CRLF
                    cQrySTL += "     AND FPG_DOCORI = '" + (cAliasFPG)->FPG_DOCORI + "'  " + CRLF
                    //condições do status
                    cQrySTL += cWhere
                    cQrySTL += "  ORDER BY TL_TIPOREG DESC "

                    cQrySTL := ChangeQuery(cQrySTL)
                    DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQrySTL),cAliasSTL,.T.,.T.)

                    //busca os itens 
                    While !(cAliasSTL)->(EoF())

                        //define se cabeçalho é de mão de obra ou produto
                        If (cAliasSTL)->TL_TIPOREG == "M"
                            cTitulo := "Relação de serviços a serem executados" 
                        Else
                            cTitulo := "Relação de peças a serem utilizadas" 
                        EndIf

                        //primeira linha ou quando muda o tipo de serviço (M ou P)
                        If lPrimeiro .Or. cTipoReg  <> (cAliasSTL)->TL_TIPOREG

                            cTipoReg    := (cAliasSTL)->TL_TIPOREG

                            If nLinAtu + nTamLin > (nLinFin - 60)
                                fImpRod()
                                fImpCab1()
                            EndIf
                            
                            //cabeçalho primeira linha
                            oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin , nColFin }, oBrush1, "-2")
                            oPrintPvt:SayAlign(nLinAtu, 150, cTitulo , oFontDetN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)
                            nLinAtu := nLinAtu + nTamLin

                            oPrintPvt:SayAlign(nLinAtu, COL_01, "Qtde"          , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_02, "UN"            , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_03, "Código"        , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_04, "Material"      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_05, "Detalhamento"  , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_06, "Valor Total"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                            nLinAtu += nTamLin

                            lPrimeiro   := .F.
                            nSomaVlTot  := 0

                        EndIf
                        
                        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
                        If nLinAtu + nTamLin > (nLinFin - 60)
                            fImpRod()
                            fImpCab1()
                            //cabeçalho primeira linha
                            oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin , nColFin }, oBrush1, "-2")
                            oPrintPvt:SayAlign(nLinAtu, 150, cTitulo, oFontDetN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)

                            nLinAtu := nLinAtu + nTamLin

                            oPrintPvt:SayAlign(nLinAtu, COL_01, "Qtde"          , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_02, "UN"            , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_03, "Código"        , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_04, "Material"      , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_05, "Detalhamento"  , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT  , 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_06, "Valor Total"   , oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT , 0)
                            nLinAtu := nLinAtu + nTamLin + 3
                        EndIf

                        STL->(DbGoTo((cAliasSTL)->RECSTL))
                        STJ->(DbGoTo((cAliasSTL)->RECSTJ))
                        FPG->(DbGoTo((cAliasSTL)->RECFPG))

                        //adiciona chave da FPG para localizar os anexos
                        If MV_PAR05 = "1"
                            Aadd(aChavAnex,"FPG" + (cAliasSTL)->FPG_FILIAL + (cAliasSTL)->FPG_FILIAL + (cAliasSTL)->FPG_PROJET + (cAliasSTL)->FPG_NRAS + (cAliasSTL)->FPG_SEQ)
                        EndIf

                        //Em 18/05/2023 Lui solicitou que as informações da FPG quando NÃO HOUVER STL
                        //Pega produto ou funcoinario 
                        If !Empty((cAliasSTL)->TJ_ORDEM) .And. !Empty((cAliasSTL)->TL_CODIGO)
                            cUnid       := (cAliasSTL)->TL_UNIDADE
                            cCodProd    := (cAliasSTL)->TL_CODIGO
                            cProd       := RetProd((cAliasSTL)->TL_CODIGO, (cAliasSTL)->TL_TIPOREG)
                        Else
                            cUnid       := Posicione("SB1" , 1 , xFilial("SB1")+(cAliasFPG)->FPG_PRODUT , "B1_UM")
                            cCodProd    := (cAliasSTL)->FPG_PRODUT
                            cProd       := (cAliasSTL)->FPG_DESCRI
                        EndIf

                        //Para não truncar a descrição
                        cProd := SubStr(cProd,1,28)

                        //Observação para o Detalhamento
                        cObserva := STL->TL_OBSERVA

                        //Ponto de Entrada para customizar o Detalhamento do item
                        If lLOCR037A
                            cObserva := ExecBlock("LOCR037A" , .T. , .T. , NIL)
                        EndIf

                        //soma no total
                        nSomaVlTot  += (cAliasSTL)->FPG_VALTOT
                        nTotOrcame  += (cAliasSTL)->FPG_VALTOT
                        nTotGeral   += (cAliasSTL)->FPG_VALTOT
                        
                        //Imprimindo a linha atual
                        oPrintPvt:SayAlign(nLinAtu, COL_01, cValToChar((cAliasSTL)->FPG_QUANT) ,  oFontDet, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
                        oPrintPvt:SayAlign(nLinAtu, COL_02, cUnid                   ,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
                        oPrintPvt:SayAlign(nLinAtu, COL_03, cCodProd                ,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
                        oPrintPvt:SayAlign(nLinAtu, COL_04, cProd                   ,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
                        oPrintPvt:SayAlign(nLinAtu, COL_05, cObserva                ,  oFontDet, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
                        oPrintPvt:SayAlign(nLinAtu, COL_06, "R$ " + AllTrim(Transform((cAliasSTL)->FPG_VALTOT,"@E 999,999,999.99"))     ,  oFontDet, 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
                        nLinAtu += nTamLin
                        
                        (cAliasSTL)->(DbSkip())

                        //imprime sub total
                        If (cAliasSTL)->(EoF()) .Or. cTipoReg  <> (cAliasSTL)->TL_TIPOREG

                            nLinAtu += (nTamLin * 0.5)
                            oPrintPvt:SayAlign(nLinAtu, COL_05 + 100, "Total "         ,  oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
                            oPrintPvt:SayAlign(nLinAtu, COL_06, "R$ " + AllTrim(Transform(nSomaVlTot,"@E 999,999,999.99"))     ,  oFontDetN, 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)

                            nLinAtu += nTamLin

                        EndIf
                                
                    EndDo

                    (cAliasSTL)->(DbCloseArea())

                EndIf

                //carrega documento atual
                cDocOri := (cAliasFPG)->FPG_DOCORI

                (cAliasFPG)->(DbSkip())

                //se for documento original diferente ou final de arquivo imprime
                If cDocOri <> (cAliasFPG)->FPG_DOCORI .Or. (cAliasFPG)->(Eof())
                    oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin , nColFin }, oBrush1, "-2")
                    oPrintPvt:SayAlign(nLinAtu, 150, "Total do Orçamento", oFontDetN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)
                    nLinAtu := nLinAtu + (nTamLin * 2)
                    //oPrintPvt:SayAlign(nLinAtu, 150, "Desconto: 0,00", oFontDetN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)
                    //nLinAtu := nLinAtu + (nTamLin * 2)
                    //oPrintPvt:SayAlign(nLinAtu, 175, "R$ " + AllTrim(Transform(nTotOrcame,"@E 999,999,999.99")) + "(" + Extenso(nTotOrcame,.F.,1) + ")"     ,  oFontDetN, 0200, nTamLin, COR_PRETO, PAD_CENTER, 0)
                    oPrintPvt:SayAlign(nLinAtu, 0, "R$ " + AllTrim(Transform(nTotOrcame,"@E 999,999,999.99")) + "(" + Extenso(nTotOrcame,.F.,1) + ")"     ,  oFontDetN, nLargTit, nTamLin, COR_PRETO, PAD_CENTER, 0)
                    //Linha Separatória
                    nLinAtu += (nTamLin * 2)
                    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
                    nLinAtu += (nTamLin * 2)
                EndIf

            EndDo
                   
            //Se ainda tiver linhas sobrando na página, imprime o rodapé final
            //If nLinAtu <= (nLinFin - 60)
                oPrintPvt:Fillrect( {nLinAtu, nColIni, nLinAtu + nTamLin + 5 , nColFin }, oBrush1, "-2")
                oPrintPvt:SayAlign(nLinAtu, 150, "Total Geral ", oFontTitN, 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)
                nLinAtu := nLinAtu + (nTamLin * 2) + 5
                //oPrintPvt:SayAlign(nLinAtu, 175, "R$ " + AllTrim(Transform(nTotGeral,"@E 999,999,999.99")) + "(" + Extenso(nTotGeral,.F.,1) + ")"     ,  oFontDetN, 0200, nTamLin, COR_PRETO, PAD_CENTER, 0)
                oPrintPvt:SayAlign(nLinAtu, 0, "R$ " + AllTrim(Transform(nTotGeral,"@E 999,999,999.99")) + "(" + Extenso(nTotGeral,.F.,1) + ")"     ,  oFontDetN, nLargTit, nTamLin, COR_PRETO, PAD_CENTER, 0)
                nLinAtu := nLinAtu + (nTamLin * 2)
                fAssina()
                fImpRod()
                If MV_PAR05 = "1"
                    aAnexos := fAnexos(aChavAnex)
                EndIf
            //EndIf

        Else
            oPrintPvt:SayAlign(nLinAtu, nColIni + 60    , "Não existem registros para o filtro selcionado."                   , oFontDet  , nColObs, nTamLin, COR_PRETO, PAD_JUSTIF   , 0)
        EndIf

        (cAliasFPG)->(DbCloseArea())

        oPrintPvt:Preview()

    EndIf

    RestArea(aAreaFp0)
    RestArea(aAreaFpg)
    RestArea(aAreaStl)
    RestArea(aAreaStj)
    RestArea(aAreaSb1)

Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpCab1                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
 *---------------------------------------------------------------------*/
 
Static Function fImpCab1()
    //Local cTexto 	:= ""
    Local cLogoRel	:= RetLogo()
    Local nLinCab	:= 030
	Local nLogoH	:= 33
    Local nLogoW	:= 112
	Local aEmpInfo	:= FWSM0Util():GetSM0Data()
	Local cEmpNome	:= AllTrim(aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_FILIAL"})][2])
	Local cEmpFone	:= "Telefone: " + aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_TEL"})][2]
	Local cEmpEnde	:= aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_ENDENT"})][2]
	Local cEmpBair	:= aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_BAIRENT"})][2]
	Local cEmpEsta	:= aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_CIDENT"})][2]
	Local cEmpCida	:= aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_ESTENT"})][2]
	Local cEmpCEP	:= aEmpInfo[ascan(aEmpInfo,{|x| AllTrim(x[1]) == "M0_CEPENT"})][2]
     
    //Iniciando Página
    oPrintPvt:StartPage()

	oPrintPvt:SayBitmap( nLinCab, nColIni, cLogoRel, nLogoW, nLogoH)
     
    //Cabeçalho
    //cTexto := "Relação de Grupos de Produtos"
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cEmpNome, oFontTitN, 240, 20, COR_PRETO, PAD_CENTER, 0)
	nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cEmpEnde, oFontTit , 240, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinCab, nColHora, DtoC(dDataGer) + " " + cHoraGer,	oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
    nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cEmpBair, oFontTit , 240, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinCab, nColHora, cNomeUsr, 						oFontDet , 0080, nTamLin, COR_PRETO, PAD_RIGHT, 0)
    nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, AllTrim(cEmpCida) + " - " + AllTrim(cEmpEsta) + " - " + AllTrim(cEmpCEP), oFontTit , 240, 20, COR_PRETO, PAD_CENTER, 0)
    nLinCab += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinCab, nColMeio - 120, cEmpFone, oFontTit , 240, 20, COR_PRETO, PAD_CENTER, 0)
    
    //Linha Separatória
    nLinCab += (nTamLin * 2)
    oPrintPvt:Line(nLinCab, nColIni, nLinCab, nColFin, COR_CINZA)
	
    //Cabeçalho das colunas
    nLinCab += nTamLin
     
    //Atualizando a linha inicial do relatório
    nLinAtu := nLinCab + 3
Return

Static Function fImpCab2()

    Local aAreaSa1  := SA1->(GetArea())
    Local cCgc      := ""

    SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
    SA1->(DbSeek(xFilial("SA1") + FP0->(FP0_CLI+FP0_LOJA) ))
    cCgc := MascCgc(SA1->A1_CGC,SA1->A1_PESSOA)

    //Cabeçalho 2
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Cliente:"    , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_NOME  , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora - 30   , "Projeto:"    , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora        , MV_PAR01      , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
	nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Endereço:"   , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_END   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "CNPJ:"       , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , cCgc          , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Contato:"    , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_CONTATO, oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora - 30   , "Fone:"       , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora        , SA1->A1_TEL   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "E-mail:"     , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 50    , SA1->A1_EMAIL , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora - 30   , "Fax:"        , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora        , SA1->A1_FAX   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)

    //Linha Separatória
    nLinAtu += (nTamLin * 2)
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
	
    //Cabeçalho das colunas
    nLinAtu += nTamLin

    //Atualizando a linha inicial do relatório
    nLinAtu := nLinAtu + 3

    RestArea(aAreaSa1)

Return

Static Function fImpCab3(cAliasFPG)

    Local cObs      := "What is Lorem Ipsum? " + CRLF + "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
    Local cEquip    := ""
    Local cEquipDesc:= ""
    Local nTamObs   := 0
    Local nColObs   := 470
    Local nQtLinObs := 0
    Local nLinObs   := 0

    STJ->(DbGoTo((cAliasFPG)->RECSTJ))

    cObs := STJ->TJ_OBSERVA
    nTamObs   := oPrintPvt:GetTextWidth(cObs,oFontDet)
    nQtLinObs := Int(nTamObs / nColObs) 
    nLinObs   := nQtLinObs * 20

    If nLinAtu + ( nTamLin * 6 ) > (nLinFin - 60)
        fImpRod()
        fImpCab1()
    EndIf

    //Cabeçalho 3
    oPrintPvt:SayAlign(nLinAtu-10, nColIni         , "Orçamento"   , oFontGigN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu   , nColMeio - 120  , "Emissão"     , oFontTitN , 240, 20, COR_PRETO, PAD_CENTER , 0)
    oPrintPvt:SayAlign(nLinAtu   , nColHora - 220  , "Validade"    , oFontTitN , 240, 20, COR_PRETO, PAD_RIGHT , 0)
	nLinAtu += (nTamLin * 1.5)
    oPrintPvt:SayAlign(nLinAtu, nColIni         , " Ordem de Serviço nº " + (cAliasFPG)->FPG_DOCORI , oFontTitN, 0240, nTamLin, COR_PRETO, PAD_LEFT  , 0)
    oPrintPvt:SayAlign(nLinAtu, nColMeio - 120  , DtoC(dDataGer)            , oFontDet , 0240, nTamLin, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora - 220  , DtoC(dDataGer + MV_PAR06) , oFontDet , 0240, 20     , COR_PRETO, PAD_RIGHT , 0)
	nLinAtu += (nTamLin * 1.5)

     //Cabeçalho 3
    //If !Empty((cAliasFPG)->TJ_CODBEM)
    If !Empty((cAliasFPG)->FQ5_GUINDA) //Solicitado por Lui e Maricato para alterar para FQ5
        //cEquip      := (cAliasFPG)->TJ_CODBEM
        cEquip      := (cAliasFPG)->FQ5_GUINDA
        //cEquipDesc  := Posicione("ST9" , 1 , xFilial("ST9")+(cAliasFPG)->TJ_CODBEM , "T9_NOME")
        cEquipDesc  := Posicione("ST9" , 1 , xFilial("ST9")+(cAliasFPG)->FQ5_GUINDA , "T9_NOME")
    Else
        cEquip      := (cAliasFPG)->FPG_PRODUT
        cEquipDesc  := (cAliasFPG)->FPG_DESCRI
    EndIF

    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Equipamento:"                        , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 60    , SubStr(cEquipDesc,1,28)               , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColMeio - 50   , "Contador Remes.:"                    , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColMeio + 20   , cValToChar((cAliasFPG)->FQ4_POSCON)   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora - 40   , "Contador OS:"                        , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora + 20   , cValToChar((cAliasFPG)->TJ_POSCONT)   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
	nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Bem:"                    , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 60    , cEquip                    , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColMeio - 50   , "Contador:"               , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColMeio + 20   , cValToChar(Posicione("ST9" , 1 , xFilial("ST9")+(cAliasFPG)->TJ_CODBEM , "T9_POSCONT"))               , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "NF retorno:"                         , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 60    , AllTrim((cAliasFPG)->FPA_NFRET)+"-"+AllTrim((cAliasFPG)->FPA_SERRET)       , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColMeio - 50   , "Data retorno:"                       , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColMeio + 20   , DtoC(StoD((cAliasFPG)->FPA_DNFRET))   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora - 40   , "Previsão Entrega:"                   , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColHora + 30   , DtoC(StoD((cAliasFPG)->TJ_DTPPFIM))   , oFontDet  , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu += nTamLin
    If nLinAtu + ( nTamLin + (nTamLin * ((nQtLinObs / 2) + 2))) > (nLinFin - 60)
        fImpRod()
        fImpCab1()
    EndIf
    oPrintPvt:SayAlign(nLinAtu, nColIni         , "Problemas:"           , oFontDetN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    oPrintPvt:SayAlign(nLinAtu, nColIni + 60    , cObs                   , oFontDet  , nColObs, nLinObs, COR_PRETO, PAD_JUSTIF   , 0)

    //Linha Separatória
    nLinAtu += (nTamLin * ((nQtLinObs / 2) + 2))
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
	
    //Cabeçalho das colunas
    nLinAtu += nTamLin

    //Atualizando a linha inicial do relatório
    nLinAtu := nLinAtu + 3
Return
 
/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodapé                                  |
 *---------------------------------------------------------------------*/
Static Function fImpRod()
    Local nLinRod   := nLinFin + nTamLin
    Local cTextoEsq := ''
    Local cTextoDir := ''
 
    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)
    nLinRod += 3
     
    //Dados da Esquerda e Direita
    cTextoEsq := dToC(dDataGer) + "    " + cHoraGer + "    " + FunName() + "    " + cNomeUsr
    cTextoDir := "Página " + cValToChar(nPagAtu)
     
    //Imprimindo os textos
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTextoDir, oFontRod, 040, 05, COR_CINZA, PAD_RIGHT, 0)
     
    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAssina
Assinatura antes do ultimo rodape
@author Jose Eulalio
@since 27/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function fAssina()

//Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
If nLinAtu + nTamLin > (nLinFin - 60)
    fImpRod()
    fImpCab1()
EndIf

nLinAtu := 700

oPrintPvt:SayAlign(nLinAtu, nColIni     , "APROVADO"                , oFontTitN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
oPrintPvt:SayAlign(nLinAtu, COL_03+30   , "(  ) SIM"                , oFontTitN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
oPrintPvt:SayAlign(nLinAtu, COL_04      , "(  ) NÃO"                , oFontTitN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
oPrintPvt:SayAlign(nLinAtu, COL_05+30   , "DATA: ____/____/_______" , oFontTitN , 240, 20, COR_PRETO, PAD_LEFT   , 0)

nLinAtu += (nTamLin * 5)

oPrintPvt:Line(nLinAtu, COL_01+20, nLinAtu, COL_04+65, COR_PRETO)
oPrintPvt:Line(nLinAtu, COL_05, nLinAtu, nColFin-40, COR_PRETO)


oPrintPvt:SayAlign(nLinAtu, COL_03      , "Técnico Responsável"     , oFontDet , 240, 20, COR_PRETO, PAD_LEFT   , 0)
oPrintPvt:SayAlign(nLinAtu, COL_05      , "Assinatura do Cliente"   , oFontDet , 240, 20, COR_PRETO, PAD_CENTER   , 0)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fAnexos
Imprime página de anexos
@author Jose Eulalio
@since 27/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function fAnexos(aChavAnex)
Local cDirDoc   := Alltrim(SuperGetMv("MV_DIRDOC",.F.,""))
Local cPathBco  := ""
Local cChave    := ""
Local nX        := 0
Local nImgH	    := 200
Local nImgW     := 200
Local nImgPerc  := 0
Local aAnexos   := {}
Local aAreaAC9  := AC9->(GetArea())
Local aAreaACB  := ACB->(GetArea())
Local aPrefixo  := {}
Local aTamanho := {0, 0}
Local oTamImg

AC9->(DbSetOrder(2)) //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
ACB->(DbSetOrder(1)) //ACB_FILIAL+ACB_CODOBJ

For nX := 1 To Len(aChavAnex)
    //posiciona no banco de conhecimento da entidade
    If AC9->(DbSeek(xFilial("AC9") + AllTrim(aChavAnex[nX])))

        //Se o ultimo caracter nao for uma \, acrescenta ela, e depois configura o diretorio com a subpasta co01\shared
        If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
            cDirDoc := cDirDoc + "\"
        EndIf
        cPathBco := cDirDoc + 'co' + cEmpAnt + '\shared\'

        //pega chave para trazer todos os anexos
        cChave := AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT)

        //roda os arquivos da mesma entidade
        While cChave == AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT)
            
            //Posiciona no objeto do banco de conhecimento
            If ACB->(DbSeek(xFilial("ACB") + AC9->AC9_CODOBJ))

                //pega o nome do arquivo e sua descrição
                Aadd(aAnexos, {AllTrim(ACB->ACB_OBJETO),AllTrim(ACB->ACB_DESCRI)})
    
            EndIf
            
            AC9->(DbSkip())

        EndDo
    EndIf
Next nX

If Len(aAnexos) > 0

    fImpCab1()

    oPrintPvt:SayAlign(nLinAtu-10,  nColMeio - 100        , "Banco de Conhecimento"   , oFontGigN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
    nLinAtu := nLinAtu + nTamLin
    //Linha Separatória
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)

    For nX := 1 To Len(aAnexos)
        aPrefixo := StrToKarr(aAnexos[nX][1],".")  
        nLinAtu := nLinAtu + nTamLin

        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
        If nLinAtu + nTamLin > (nLinFin - 60)
            fImpRod()
            fImpCab1()

            oPrintPvt:SayAlign(nLinAtu-10,  nColMeio - 100        , "Banco de Conhecimento"   , oFontGigN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
            nLinAtu := nLinAtu + nTamLin
            //Linha Separatória
            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
        EndIf

        oPrintPvt:SayAlign(nLinAtu-10,  COL_01         , aAnexos[nX][2]   , oFontTitN , 240, 20, COR_PRETO, PAD_LEFT   , 0)
        If UPPER(aTail(aPrefixo)) $ "PNG|JPG|BMP"

            //Criando o objeto com a imagem passada via parâmetro
            oTamImg := TBitmap():New(01,01,,,,cPathBco + aAnexos[nX][1],,,,,,,,,,,,,)
                
            //Auto ajusta o tamanho, sem ele, é retornado 0
            oTamImg:lAutoSize := .T.
                
            //Altura
            aTamanho[1] := oTamImg:nClientHeight
                
            //Largura
            aTamanho[2] := oTamImg:nClientWidth

            nImgPerc := nImgH / aTamanho[1] 

            //se passar de 400 força a largura
            nImgW := Min(400,aTamanho[2] * nImgPerc)

	        oPrintPvt:SayBitmap( nLinAtu, COL_04, cPathBco + aAnexos[nX][1], nImgW , nImgH) 
            nLinAtu := nLinAtu + nImgH
        Else  
            oPrintPvt:SayAlign(nLinAtu-10,  COL_04         , aAnexos[nX][1]   , oFontTit , 240, 20, COR_PRETO, PAD_LEFT   , 0)
        EndIf
        //Linha Separatória
        nLinAtu := nLinAtu + nTamLin
        oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_CINZA)
    Next nX
    
    fImpRod()

EndIf

RestArea(aAreaAC9)
RestArea(aAreaACB)

Return aAnexos

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
Local cLogo := "C:\itup\img\logo_totvs.jpg" // SuperGetMv("MV_LOCXLOG",.F.,"") // define via parametro o logo do relatorio

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
/*/{Protheus.doc} RetProd
Retorna produto ou funcionario de acordo com tipo de registro
@author Jose Eulalio
@since 22/02/2023
@version 1.0
@type function
/*/
//---------------------------------------------------------------------
Static Function RetProd(cCodProd,cTipoReg)
Local cProdNome := ""
Local aAreaSB1  := SB1->(GetArea())
Local aAreaST1  := ST1->(GetArea())

//Mao de Obra
If cTipoReg == "M"
    ST1->(DbSetOrder(1)) // T1_FILIAL+T1_CODFUNC
    If ST1->(DbSeek(xFilial("ST1") + cCodProd))
        cProdNome := ST1->T1_NOME
    EndIf
//Produto
Else
    SB1->(DbSetOrder(1)) // T1_FILIAL+T1_CODFUNC
    If SB1->(DbSeek(xFilial("SB1") + cCodProd))
        cProdNome := SB1->B1_DESC
    EndIf
EndIf

RestArea(aAreaSB1)
RestArea(aAreaST1)

Return cProdNome
