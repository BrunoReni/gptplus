#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt10C 		:= TFont():New("Arial",12,12,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt12L 		:= TFont():New("Arial",09,09,,.F., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)
STATIC oFnt10L      := TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENRDEFUI

Relat�rio do Quadro Agrupamento de Contratos

@author Jos� Paulo
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CENRDEFUI(lTodosQuadros,lAuto)

    Local aSays      := {}
    Local aButtons   := {}
    Local cCadastro  := "                                              Capital Baseado em Riscos - Risco de Cr�dito - Parcela 2"//"Detalhamento Fundos Investimentos p/Apura��o do Capital Referente ao Risco de Cr�ditos (Parcela 2)"
    Local aResult    := {}
    Local cDesc1      := FunDesc() //"Valor de Cobran�a"
    Local cDesc2      := ""
    Local cDesc3      := ""
    Local cAlias      := "B6Z"
    Local cRel        := "CENRDEFUI"
    Local aOrdens     := { "Operadora+Obriga��o+Ano+C�digo Compromisso+Refer�ncia", "Operadora+Obriga��o+Ano+C�digo Compromisso+Refer�ncia" }
    Local lDicion     := .F.
    Local lCompres    := .F.
    Local lCrystal    := .F.
    Local lFiltro     := .T.
    Default lTodosQuadros := .F.
    Default lAuto := .F.

    If !lTodosQuadros

        Private cTitulo   := cCadastro
        Private oReport   := nil
        Private cRelName := "DIOPS_Det_Fun_Investimentos_"+CriaTrab(NIL,.F.)
        Private nPagina   := 0		// J� declarada PRIVATE na chamada de todos os quadros
        Private aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }

        oReport := FWMSPrinter():New(cRelName,IMP_PDF,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
        oReport:setDevice(IMP_PDF)
        oReport:setResolution(72)
        oReport:SetLandscape(.T.)
        oReport:SetPaperSize(9)
        oReport:setMargin(10,10,10,10)

        If lAuto
            oReport:CFILENAME  := cRelName
            oReport:CFILEPRINT := oReport:CPATHPRINT + oReport:CFILENAME
        Else
            oReport:Setup()  //Tela de configura��es
        EndIf

    EndIf

    Processa( {|| aResult := CENDEFUIN() }, cCadastro)

    // Se n�o h� dados a apresentar
    If !aResult[1]
        If !lAuto
            MsgAlert('N�o h� dados a apresentar referente a Agrupamento de Contratos')
        EndIf
        Return
    EndIf

    lRet := PRINTDFIN(aResult[2]) //Recebe Resultado da Query e Monta Relat�rio

    If !lTodosQuadros .and. lRet
        oReport:EndPage()
        oReport:Print()
    EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTAGCIN
@description Imprime Agrupamento de Contratos
@author Jos� Paulo
@since 01/04/201
/*/
//------------------------------------------------------------------
Static Function PRINTDFIN(aValores)

    Local nSom		:= 0
    Local nI		:= 1
    Local oBrush1 	:= TBrush():New( , RGB(224,224,224))  //Cinza claro
    Local cTitulo   := "                                              Capital Baseado em Riscos - Risco de Cr�dito - Parcela 2"//"Detalhamento Fundos Investimentos p/Apura��o do Capital Referente ao Risco de Cr�ditos (Parcela 2)"
    Local nLinha	:= 100
    Local lRet      := .t.
    Local nJ        := 0

    PlsRDCab(cTitulo,160)

    oReport:box(nLinha, 020, nLinha+25, 805)
    nLinha+=25
    oReport:box(nLinha, 020, nLinha+60, 805)
    nLinha+=60
    oReport:box(nLinha, 020, nLinha+60, 805)
    nLinha+=60
    oReport:box(nLinha, 020, nLinha+60, 805)
    nLinha+=60
    oReport:box(nLinha, 020, nLinha+160, 805)
    nLinha+=160
    oReport:box(nLinha, 020, nLinha+35, 805)

    nLinha:=118
    oReport:Say(nLinha, 023 , "C�digo Campo", oFnt10N)
    oReport:Say(nLinha, 200 , "T�tulo", oFnt10N)
    oReport:Say(nLinha, 480 , "Descri��o", oFnt10N)
    oReport:Say(nLinha, 720 , "Valor", oFnt10N)

    oReport:Say(nLinha+40, 030 , "Campo1", oFnt10N)
    nLinha+=60
    oReport:Say(nLinha+40, 030 , "Campo2", oFnt10N)
    nLinha+=60
    oReport:Say(nLinha+40, 030 , "Campo3", oFnt10N)
    nLinha+=60
    oReport:Say(nLinha+090, 030 , "Campo4", oFnt10N)
    nLinha+=60
    oReport:Say(nLinha+125, 030 , "Campo5", oFnt10N)

    nLinha:=140
    oReport:Say(nLinha, 120 , "Total em Aplica��es em quotas de Fundos de Investimento dedicados ao", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "setor suplementar (FDSS) definidos conforme a RN n� 392/2015 que", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "informarem o Fator de Pondera��o de Risco (FPR) calculado � ANS no", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "trimestre de c�lculo, no �mbito do conv�nio firmado", oFnt12L)

    nLinha:=200
    oReport:Say(nLinha, 120 , "Fator Ponderador de Risco para o Total em Aplica��es em quotas de", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "FDSS definidos conforme a RN n� 392/2015 que informarem o FPR", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "calculado � ANS no trimestre de c�lculo, no �mbito do conv�nio firmado", oFnt12L)

    nLinha:=260
    oReport:Say(nLinha, 120 , "Total em Aplica��es em quotas de fundos de investimentos que n�o se", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "enquadram como FDSS ou de FDSS que n�o informem o FPR calculado", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "� ANS no trimestre de c�lculo, no �mbito do conv�nio firmado", oFnt12L)

    nLinha:=330
    oReport:Say(nLinha, 120 , "FPR para o Total em Aplica��es em quotas de fundos de investimentos", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "que n�o se enquadram como FDSS ou de FDSS que n�o informem o", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "FPR calculado � ANS no trimestre de c�lculo, no �mbito do conv�nio", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 120 , "firmado", oFnt12L)

    nLinha:=480
    oReport:Say(nLinha, 120 , "Total em Aplica��es em quotas de fundos de investimentos", oFnt12L)
    nLinha:=140
    oReport:Say(nLinha, 380 , "Deve ser informado o total agregado aplicado nestes fundos que coincide com o total", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "informado nos saldos juntos aos gestores destes recursos informados � ANS.", oFnt12L)

    nLinha:=200
    oReport:Say(nLinha, 380 , "Conforme previs�o do item 13.6, do Anexo III-A da RN 451, de 2020, a ANS divulgar� no", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "seu site os valores de FPR de cada fundo dedicado que informar o valor � ANS. Com esses", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "valores, a Operadora poder� calcular o valor m�dio ponderado de acordo com suas", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "aplica��es nesses fundos.", oFnt12L)

    nLinha:=260
    oReport:Say(nLinha, 380 , "Deve ser informado o total agregado aplicados nestes fundos.", oFnt12L)

    nLinha:=330
    oReport:Say(nLinha, 380 , "Por padr�o o valor deve ser de 100%, caso a operadora n�o opte por efetuar o c�lculo do", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "FPR conforme estabelecido no item 13 do Anexo III-A da RN 451, de 2020.", oFnt12L)
    nLinha+=40
    oReport:Say(nLinha, 380 , "As operadoras que optarem por essa faculdade, conforme estabelecido no item 13.3 do", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "Anexo VII da RN 451, de 2020, nas datas-base referentes ao envio do DIOPS, os c�lculos", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "trimestrais do FPR dever�o ser objeto de procedimento previamente acordado (PPA)", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "elaborado por empresa de auditoria cont�bil independente registrada junto � Comiss�o", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "de Valores Mobili�rios (CVM), devendo o relat�rio resultante ser encaminhado � ANS por", oFnt12L)
    nLinha+=10
    oReport:Say(nLinha, 380 , "meio do DIOPS.", oFnt12L)

    nLinha:=480
    oReport:Say(nLinha, 380 , "Valor total aplicado em fundos de investimentos.", oFnt12L)

    nSom:=100
    nLin:=100

    For nJ := 1 to 3
        If nSom >= 0
            oReport:Line(nLin, nSom, nLin+400, nSom)
            If nsom == 100
                nSom+=260
            Else
                nSom+=330
            endif
        EndIf
    Next nJ

    oReport:Say(160, 700   , PadL(Transform(aValores[nI,1]  ,Moeda),20), oFnt10L)
    oReport:Say(220, 740   , cValToChar(aValores[nI,2])+"%"+" ",oFnt10L)
    oReport:Say(280, 700   , PadL(Transform(aValores[nI,3] ,Moeda),20), oFnt10L)
    oReport:Say(390, 740   , cValToChar(aValores[nI,4])+"%"+" ",oFnt10L)
    oReport:Say(480, 700   , PadL(Transform(aValores[nI,5] ,Moeda),20), oFnt10L)

Return lRet

Static Function CENDEFUIN()

    Local nCount   := 0
    Local aRetCdOp := {}
    Local cSql 	   := ""

    cSql := " SELECT B6Z_VLRTAQ,B6Z_PERFPR,B6Z_VLRTAF,B6Z_PERTAQ,B6Z_VLRTAI "
    cSql += " FROM " + RetSqlName("B6Z")
    cSql += " WHERE B6Z_FILIAL = '" + xFilial("B6Z") + "' "
    cSql += " AND B6Z_CODOPE = '" + B3D->B3D_CODOPE + "' "
    cSql += " AND B6Z_CODOBR = '" + B3D->B3D_CDOBRI + "' "
    cSql += " AND B6Z_ANOCMP = '" + B3D->B3D_ANO + "' "
    cSql += " AND B6Z_CDCOMP = '" + B3D->B3D_CODIGO + "' "
    cSql += " AND D_E_L_E_T_ = ' ' "
    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBDFI",.F.,.T.)

    If !TRBDFI->(Eof())
        Do While !TRBDFI->(Eof())
            AADD(aRetCdOp,{TRBDFI->B6Z_VLRTAQ,TRBDFI->B6Z_PERFPR,TRBDFI->B6Z_VLRTAF,TRBDFI->B6Z_PERTAQ,TRBDFI->B6Z_VLRTAI})
            nCount++
            TRBDFI->(DbSkip())
        EndDo
    EndIf
    TRBDFI->(DbCloseArea())

Return( { nCount > 0 , aRetCdOp } )
