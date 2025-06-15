#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fisa307.ch"

//------------------------------------------------------------------
/*/{Protheus.doc} FISA307

Rotina para gera��o de arquivo XML para a obriga��o DMST-e referente
a servi�os tomados no Municipio de Caxias do Sul - RS

@author Alexandre Esteves
@since 28/10/2021
@version 12.1.33
/*/
//------------------------------------------------------------------

Function FISA307()
	Local lLGPD  	  := FindFunction("Verpesssen") .And. Verpesssen()
	Local lAutomato   := IiF(IsBlind(),.T.,.F.)

    If !lAutomato .And. lLGPD
        If Pergunte('FISA307',.T., STR0001)  //"Par�metros de gera��o do arquivo"
            FwMsgRun(,{|oSay| MainDMS(oSay) },STR0002,"")	  //"Processando do arquivo"
        Else
            Alert("Pergunte n�o encontrado - Atualize a base de dados")
        EndIf
    Else
        MainDMS()
    EndIf
Return

//------------------------------------------------------------------
/*/{Protheus.doc} MainDMS
Fun��o principal da rotina de gera��o do arquivo de servi�os 
tomados do munic�pio de de Caxias do Sul - RS
/*/
//------------------------------------------------------------------

Static function MainDMS(oSay)
    Local oParamArq  := DMSGEN():New(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)
    Local oRegDms    := DMSREG():New()
    Local cAliasProc := GetNextAlias()
    Local cAliasDMS  := GetNextAlias()
    Local lContinua  := .T.
    Local cMensagem  := ''
    Local lAutomato  := Iif(IsBlind(), .T., .F.)

    If !lAutomato
        If (Empty(oParamArq:GetDtIni()) .Or. Empty(oParamArq:GetDtFim()))
            lContinua := .F.
            cMensagem += STR0005 + CRLF //"Necessario informar a Data Inicio e a Data Fim"
        EndIf

        If oParamArq:GetDtIni() > oParamArq:GetDtFim()
            lContinua := .F.
            cMensagem += STR0011 + CRLF //"Data Inicial n�o pode ser maior que a Data Final"
        EndIf

        If Empty(oParamArq:GetPath())
            lContinua := .F.
            cMensagem += STR0006 + CRLF //"Necessario Informar o Diret�rio"
        EndIf

        If Empty(oParamArq:GetArqName())
            lContinua := .F.
            cMensagem +=  STR0007 + CRLF //"Necessario Informar o Nome do Arquivo" 
        EndIf        
    EndIf

    If lContinua
        //Busca os documentos fiscais que ir�o comp�r o arquivo
        QueryDMS(oParamArq, @cAliasProc)

        dbSelectArea(cAliasProc)
        (cAliasProc)->(dbGoTop())

        //Loop para inserir cada documento fiscal da query em um objeto DMSREG e posteriormente grava-lo na tabela tempor�ria
        While !(cAliasProc)->(Eof())
            oRegDms:GravaReg(oRegDms, cAliasProc)
            GravaTbDMS(@cAliasDMS, oRegDms)
            (cAliasProc)->(DBSkip())
            oRegDms:LimpaObj()
        End

        //Caso existam registros na tabela, gera o arquivo
        If Select(cAliasDMS) > 0 .And. !(cAliasDMS)->(EoF())
            GeraArqDMS(cAliasDMS, oParamArq)
        Else
        //De acordo com o Leiaute quando n�o h� movimento tem que ser gerado um XML especifico
            MsgInfo(STR0008) //"N�o existem documentos v�lidos no per�odo informado, ser� gerado o arquivo sem movimento"
            GeraArqSMV(oParamArq) // Rotina para gerar XML sem movimento 
        EndIf
    Else
        MsgInfo(STR0003, cMensagem) //"Processamento Interrompido"-Mensagem acumulada
    EndIf

    //Fecha todos Alias e libera todos os objetos
    If Select(cAliasProc) > 0
        (cAliasProc)->(DbCloseArea())
    EndIf

    If Select(cAliasDMS) > 0
        (cAliasDMS)->(DbCloseArea())
        LimpOTbDms()
        FreeObj(oRegDms)
    EndIf

    If !lAutomato
        MsgInfo(STR0010) //"Processamento Conclu�do"
    EndIf

Return