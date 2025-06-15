#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CriTPADMTd
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPADM 
@author Jos� Paulo
@since 08/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CriTPADMTd From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CriTPADMTd
	_Super:New()
	self:setCodCrit('M110')
	self:setMsgCrit('O C�digo do car�ter do atendimento � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo C�digo do car�ter do atendimento conforme tabela dom�nio 23 vigente na vers�o que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPADM')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CriTPADMTd
	Local cQuery := ""

	cQuery += " 	AND ( (BKR_TPEVAT='2') OR (BKR_TPEVAT='3') ) "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND BKR_TIPADM <> '' "
	cQuery += " AND BKR_TIPADM NOT IN ( "
	cQuery += " SELECT B2R_CDTERM "
	cQuery += "  FROM " + RetSqlName("B2R") + " "
	cQuery += " WHERE B2R_CODTAB = '23' "
	cQuery += "  AND B2R_VIGDE <> '' "
	cQuery += "  AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
	cQuery += " ) "

Return cQuery