#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fisa305.ch"

/*/{Protheus.doc} FISA305
    (Fun��o inicializadora para gera��o do arquivo de servi�os tomados do munic�pio de S�o Jos� dos Campos)
    @type  Function
    @author pereira.weslley
    @since 02/12/2020
    @version 1.0
    @param none
    @return none
    @example
    (Fun��o inicializadora para gera��o do arquivo de servi�os tomados do munic�pio de S�o Jos� dos Campos)
    @see (links_or_references)
    /*/
function FISA305()
    Local lLGPD  	:= FindFunction("Verpesssen") .And. Verpesssen()
    Local lAutomato := Iif(IsBlind(), .T., .F.)

    If lLGPD
        If !lAutomato
            If Pergunte('FISA305', .T., STR0001) //"Par�metros para gera��o do arquivo"
                FwMsgRun(,{|oSay| MainSJC(oSay)}, STR0002, "") //"Processando arquivo"
            Else
                Alert("Pergunte n�o encontrado - Atualize a base de dados")
            EndIf
        Else
            MainSJC()
        EndIf
    EndIf

Return 

/*/{Protheus.doc} MainSJC
    (Fun��o principal da rotina de gera��o do arquivo de servi�os tomados do munic�pio de S�o Jos� dos Campos)
    @type  Function
    @author pereira.weslley
    @since 02/12/2020
    @version 1.0
    @param oSay, Objeto, Componente que ser� sobreposto com o painel
    @return none
    @example
    (Fun��o principal da rotina de gera��o do arquivo de servi�os tomados do munic�pio de S�o Jos� dos Campos)
    @see (links_or_references)
    /*/
Static function MainSJC(oSay)
    Local oParamArq  := SJCGEN():New(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
    Local oRegT      := REGT():New()
    Local cAliasProc := GetNextAlias()
    Local cAliasSJC  := GetNextAlias()
    Local lContinua  := .T.
    Local cMensagem  := ''
    Local lAutomato  := Iif(IsBlind(), .T., .F.)

    If !lAutomato
        If (Empty(oParamArq:GetDtIni()) .Or. Empty(oParamArq:GetDtFim()))
            lContinua := .F.
            cMensagem += STR0005 + CRLF // Necessario informar a Data Inicio e a Data Fim.
        EndIf

        If oParamArq:GetDtIni() > oParamArq:GetDtFim()
            lContinua := .F.
            cMensagem += STR0011 + CRLF // Data Inicial n�o pode ser maior que Data Final
        EndIf

        If Empty(oParamArq:GetPath())
            lContinua := .F.
            cMensagem += STR0006 + CRLF // Necessario informar o Diret�rio.
        EndIf

        If Empty(oParamArq:GetArcName())
            lContinua := .F.
            cMensagem += STR0007 //Necessario informar o Nome do Arquivo.
        EndIf        
    EndIf

    If lContinua
        //Busca os documentos fiscais que ir�o comp�r o arquivo
        QuerySJC(oParamArq, @cAliasProc)

        dbSelectArea(cAliasProc)
        (cAliasProc)->(dbGoTop())

        //Loop para inserir cada documento fiscal da query em um objeto Reg T e posteriormente grava-lo na tabela tempor�ria
        While !(cAliasProc)->(Eof())
            oRegT:GravaRegT(oRegT, cAliasProc)
            GravaTbSJC(@cAliasSJC, oRegT)
            (cAliasProc)->(DBSkip())
            oRegT:LimpaObj()
        End

        //Caso existam registros na tabela, gera o arquivo
        If Select(cAliasSJC) > 0 .And. !(cAliasSJC)->(EoF())
            GeraArqSJC(cAliasSJC, oParamArq)
        Else
            MsgInfo(STR0008, STR0003) //Imposs�vel prosseguir! - N�o existem documentos v�lidos no per�odo informado.
        EndIf
    Else
        MsgInfo(STR0008, cMensagem) // Imposs�vel prosseguir! - Mensagem acumulada
    EndIf

    //Fecha todos Alias e libera todos os objetos
    If Select(cAliasProc) > 0
        (cAliasProc)->(DbCloseArea())
    EndIf

    If Select(cAliasSJC) > 0
        (cAliasSJC)->(DbCloseArea())
        LimpOTBSJC()
        FreeObj(oRegT)
    EndIf

    If !lAutomato
        Alert(STR0010) //"Processamento Conclu�do"
    EndIf

Return