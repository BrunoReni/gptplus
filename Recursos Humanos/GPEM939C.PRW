#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM939.CH"

Static lTpInt

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEM939C
Efetua a consulta dos lotes de integra��o com o P&M (Performance & Metas)/a Feedz pelo Schedule
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Function GPEM939C()

Private aMarkREF    := {}
Private cFeedzTok	:= ""
Private cFeedzURL	:= ""
Private cPMToken	:= ""
Private cPMURL		:= ""
Private cPMClient	:= ""
Private cPMSecret	:= ""

If FWGetRunSchedule()
    cFeedzTok	:= SuperGetMv( 'MV_APIFEE2', Nil, "" )
    cFeedzURL	:= SuperGetMv( 'MV_APIFEE1', Nil, "" )
    cPMToken	:= SuperGetMv( 'MV_APIPEM0', Nil, "" )
    cPMURL		:= SuperGetMv( 'MV_APIPEM1', Nil, "" ) 
    cPMClient	:= SuperGetMv( 'MV_APIPEM2', Nil, "" )
    cPMSecret	:= SuperGetMv( 'MV_APIPEM3', Nil, "" )

    If !ChkFile("REF")
        Conout( FwNoAccent(STR0001) )//"Aten��o"
        Conout( FwNoAccent(STR0002) )//"A tabela REF n�o existe no dicion�rio. � necess�rio atualiza��o do ambiente para acesso � rotina"
        Conout( FwNoAccent(STR0003) )//"Contate o administrador do sistema para efetuar a atualiza��o do ambiente"
        Return .F.
    EndIf

    If Empty(cPMURL) .And. Empty(cFeedzURL)
        //"Aten��o"###"A rotina de consulta somente deve ser utilizada quando a integra��o com o P&M ou com a Feedz estiver ativa."###"Contate o administrador do sistema para efetuar o ajuste na parametriza��o no m�dulo Configurador."
        Conout( FwNoAccent(STR0001) )//"Aten��o"
        Conout( FwNoAccent(STR0271) )//"A rotina de consulta somente deve ser utilizada quando a integra��o com o P&M ou com a Feedz estiver ativa."
        Conout( FwNoAccent(STR0265) )//"Contate o administrador do sistema para efetuar o ajuste na parametriza��o no m�dulo Configurador."
        Return .F.
    EndIf

    If Empty(cFeedzURL)
        If Empty(cPMToken) .Or. Empty(cPMClient) .Or. Empty(cPMSecret)
            Conout( FwNoAccent(STR0001) )//"Aten��o"
            Conout( FwNoAccent(STR0013) )//"Os par�metros MV_APIPEM0, MV_APIPEM2 e/ou MV_APIPEM3 n�o est�o preenchidos."
            Conout( FwNoAccent(STR0072) )//"Contate o administrador do sistema para revisar a configura��o dos par�metros MV_APIPEM0, MV_APIPEM2 e/ou MV_APIPEM3 no m�dulo Configurador"
            Return .F.
        EndIf
    Else
        If Empty(cFeedzTok)
            Conout( FwNoAccent(STR0001) )//"Aten��o"
            Conout( FwNoAccent(STR0266) )//#"O par�metro MV_APIFEE2 n�o est� preenchido."
            Conout( FwNoAccent(STR0267) )//"Contate o administrador do sistema para revisar a configura��o do par�metro MV_APIFEE2 no m�dulo Configurador."
            Return .F.
        EndIf
    EndIf

    Conout("===============================================================")
    Conout( FwNoAccent(STR0140) )//"| In�cio da consulta dos status dos lotes          		   |"
    Conout("===============================================================")

    Conout( FwNoAccent(STR0147) )//"Obs.: para mais informa��es sobre a integra��o, consulte a(s) documenta��o(�es) abaixo:"
    If Empty(cFeedzURL)
        Conout( "https://tdn.totvs.com/pages/viewpage.action?pageId=680969647" )
        Conout( "https://tdn.totvs.com/pages/viewpage.action?pageId=676047532" )
    Else
        Conout( "https://tdn.totvs.com/pages/viewpage.action?pageId=756450483" )
    EndIf

    fQryREF()
    fStat939B( .T. )

    Conout("===============================================================")
    Conout( FwNoAccent(STR0141) )//"| T�rmino da consulta dos status dos lotes          		   |"
    Conout("===============================================================")
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fQryREF
Efetua o filtro dos lotes pendentes de consulta
@author  Allyson Luiz Mesashi
@since   06/05/2022
/*/
//-------------------------------------------------------------------
Static Function fQryREF()

Local cAliasQRY 	:= "QRYREF"
Local cQuery        := ""

DEFAULT lTpInt      := REF->( ColumnPos( "REF_TPINT" ) ) > 0

cQuery	:= "SELECT R_E_C_N_O_ AS RECNO "
cQuery 	+= "FROM " + RetSqlName("REF") + " "
cQuery 	+= "WHERE REF_STATUS IN ('0', '1') AND "
If lTpInt
    If Empty(cFeedzURL)
        cQuery 	+= "REF_TPINT IN (' ', '1') AND "
    Else
        cQuery 	+= "REF_TPINT = '2' AND "
    EndIf
EndIf
cQuery  += "D_E_L_E_T_ = ' '"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

While (cAliasQRY)->( !EoF() )
    aAdd( aMarkREF, (cAliasQRY)->RECNO )
    (cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Fun��o com as configura��es de schedule
@author  Allyson Luiz Mesashi
@since   09/05/2022
/*/
//-------------------------------------------------------------------
Static Function SchedDef()  

Local aOrd      := {}
Local aParam    := { "P", "PARAMDEF", "REF", aOrd, "" }

Return aParam
