/*/LOCM004.PRW
ITUP Business - TOTVS RENTAL
P.E. antes da exclusao do pedido de vendas
Validar se exclusao será efetuada ou não.
@type Function
@author Frank Zwarg Fuga
@since 17/02/2021
@version P12
@history 17/02/2021, Frank Zwarg Fuga, ponto de entrada solicitado pelo Rafael nos testes do 94.
/*/

#Include "totvs.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "locm004.ch"

Function LOCM004
Local _aAreaSC6     := SC6->(GetArea())
Local _aAreaSC5     := SC5->(GetArea())
Local _aAreaFPY
Local _lRet         := .T.
Local lMvLocBac		:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cQry
Local cContrato     := ""

    If lMvLocBac
        _aAreaFPY := FPY->(GetArea("FPY"))
        FPY->(dbSetOrder(1))
        If FPY->(dbSeek(xFilial("FPY")+SC5->C5_NUM))
            cContrato := FPY->FPY_PROJET
            If select("QRY") > 0
                QRY->(dbclosearea())
            endif
            cQry := " SELECT FPY.R_E_C_N_O_ AS REG "
            cQry += " FROM "+RetSqlName("FPY")+" FPY " 
            cQry += " WHERE FPY.FPY_PROJET = '"+cContrato+"' "
            cQry += " AND FPY.D_E_L_E_T_ = '' AND FPY.FPY_STATUS <> '2' AND FPY.FPY_PEDVEN > '"+SC5->C5_NUM+"' "
            cQry := changequery(cQry) 
            TcQuery cQry New Alias "QRY"
            If !QRY->(Eof())
                _lRet := .F.
            EndIf
            QRY->(dbCloseArea())
        EndIF
        FPY->(RestArea(_aAreaFPY))
    Else
        If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
            If !empty(SC6->C6_XAS)
                FPA->(dbSetOrder(3))
                If FPA->(dbSeek(xFilial("FPA")+SC6->C6_XAS))
                    cContrato := FPA->FPA_PROJET
                    If select("QRY") > 0
                        QRY->(dbclosearea())
                    endif
                    cQry := " SELECT SC5.R_E_C_N_O_ AS REG "
                    cQry += " FROM "+RetSqlName("SC5")+" SC5 " 
                    cQry += " WHERE SC5.C5_XPROJET = '"+cContrato+"' AND SC5.C5_NUM > '"+SC5->C5_NUM+"' "
                    cQry += " AND SC5.D_E_L_E_T_ = '' "
                    cQry := changequery(cQry) 
                    TcQuery cQry New Alias "QRY"
                    If !QRY->(Eof())
                        _lRet := .F.
                    EndIf
                    QRY->(dbCloseArea())
                EndIF
            EndIF
        EndIF
    EndIF

    If !_lRet
        MsgAlert(STR0001,STR0002) // "Existe uma nota emitida para o orçamento com data superior a que você está tendando excluir."###"LOCM004 - Exclusão bloqueada."
    EndIf

    SC6->(RestArea(_aAreaSC6))
    SC5->(RestArea(_aAreaSC5))

Return _lRet
