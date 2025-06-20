#Include "FINA136D.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} F136Bonifi
Rotina API para bonifica��o de t�tulo. Efetua a compensa��o da NCC e/ou aplica��o de desconto no t�tulo.

@type       Function
@author     Rafael Riego
@since      30/04/2020
@version    P12.1.27
@param      oParcela, object, objeto JSON contendo as informa��es do t�tulo
@param      cMsgErro, character, vari�vel mensagem passada por refer�ncia
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Function F136Bonifi(oParcela As JSon, cMsgErro As Character) As Logical

    Local aArea         As Array
    Local aDadosSE1     As Array
    Local aNCC          As Array
    Local aParametro    As Array
    Local aSE1          As Array
    Local aValores      As Array

    Local cHistorico    As Character

    Local nNCC          As Numeric
    Local nSaldoComp    As Numeric

    Default cMsgErro    := ""

    aArea       := {SE1->(GetArea()), GetArea()}
    aDadosSE1   := {}
    aNCC        := {}
    aParametro  := {.T., .F., .F., .F., .F., .F.}
    aSE1        := {}
    aValores    := {}
    nSaldoComp  := oParcela["localAmount"]

    If Empty(oParcela["history"])
        cHistorico := STR0001 // "Bonifica��o Totvs Antecipa"
    Else
        cHistorico := oParcela["history"]
    EndIf

    AAdd(aSE1, SE1->(RecNo()))

    For nNCC := 1 To Len(oParcela["creditUnits"])
        AAdd(aNCC, oParcela["creditUnits"][nNCC]["recordId"])
        SE1->(DbGoTo(oParcela["creditUnits"][nNCC]["recordId"]))
        AAdd(aDadosSE1, {SE1->(RecNo()), cHistorico, FaVlAtuCr("SE1", dDataBase)})
    Next nNCC
    AAdd(aValores, oParcela["localAmount"])
    //Caso tenha compensa��o, executa
    If oParcela["localAmount"] > 0 .Or. FwIsInCallStack("FCompDevol")
        If !(MaIntBxCr(3, aSE1, /*3*/, aNCC, /*5*/, aParametro, /*7*/, /*8*/, aDadosSE1,/*10*/, nSaldoComp,;
            /*12*/, aValores, /*14*/, /*15*/, /*16*/, /*17*/, /*18*/, /*19*/))
            cMsgErro := FinGetHelp()
            If Empty(cMsgErro)
                cMsgErro := "N�o foi poss�vel realizar a compensa��o da NCC '" + SE1->E1_PARCELA + "."
            EndIf
        EndIf
        //Reposiciona registro ap�s a MaIntBxCr movimentar o ponteiro para o final do arquivo
        SE1->(DbGoTo(aSE1[1]))
    EndIf

    //Gera aplica��o de desconto no t�tulo
    If Empty(cMsgErro) .And. oParcela["discountAmount"] > 0
        AplicDesco(oParcela, @cMsgErro)
    EndIf

    //Gera a movimenta��o do cr�dito aplicado (NCCs) e Desconto
    If Empty(cMsgErro) .And. (oParcela["localAmount"] > 0 .Or. oParcela["debitPrincipalAmount"] > 0)
        MovCredito(oParcela, @cMsgErro)
    EndIf

    //Gera taxa da movimenta��o
    If Empty(cMsgErro) .And. oParcela["feeAmount"] > 0
        F136GerMov(oParcela, @cMsgErro, oParcela["feeAmount"])
    EndIf

    //Realiza transfer�ncia banc�ria da taxa original
    If Empty(cMsgErro) .And. oParcela["feeAmountOrigin"] > 0
        F136GerMov(oParcela, @cMsgErro, oParcela["feeAmountOrigin"] , 4)
    EndIf
    FwFreeArray(aDadosSE1)
    FwFreeArray(aNCC)
    FwFreeArray(aValores)
    
    AEval(aArea, {|area| RestArea(area)})
    
Return Empty(cMsgErro)

/*/{Protheus.doc} AplicDesco
Rotina para aplica��o de desconto na parcela.

@type       Static Function
@author     Rafael Riego
@since      06/05/2020
@version    P12.1.27
@param      oParcela, object, objeto JSON contendo as informa��es do t�tulo
@param      cMsgErro, character, vari�vel mensagem passada por refer�ncia
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Static Function AplicDesco(oParcela As JSon, cMsgErro As Character) As Logical

    Local cOldHistor    As Character

    Default cMsgErro    := ""

    cOldHistor := oParcela["history"]
    oParcela["history"] := STR0003 // "Desconto TOTVS Antecipa"

    F136Baixa(oParcela, @cMsgErro)
    
    oParcela["history"] := cOldHistor


Return Empty(cMsgErro)

/*/{Protheus.doc} MovCredito
Rotina para gerar movimenta��o banc�ria com o valor do cr�dito aplicado na NF.

@type       Static Function
@author     Rafael Riego
@since      20/05/2020
@version    P12.1.27
@param      oParcela, object, objeto JSON contendo as informa��es do t�tulo
@param      cMsgErro, character, vari�vel mensagem passada por refer�ncia
@return     logical, verdadeiro caso nenhum erro tenha sido encontrado
/*/
Static Function MovCredito(oParcela As JSon, cMsgErro As Character) As Logical

    Local cOldHistor    As Character

    Default cMsgErro    := ""

    cOldHistor := oParcela["taxHistory"]
    //Compensa��o por devolu��o
    If FwIsInCallStack("FCompDevol")
        oParcela["taxHistory"] := STR0005 // "DEVOLUCAO"
        F136GerMov(oParcela, @cMsgErro, oParcela["debitPrincipalAmount"] + oParcela["feeAmountOrigin"])    
    Else
        oParcela["taxHistory"] := STR0004 // "BONIFICACAO"
        F136GerMov(oParcela, @cMsgErro, oParcela["localAmount"])
    EndIf

    oParcela["taxHistory"] := cOldHistor

Return Empty(cMsgErro)
