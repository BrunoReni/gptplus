#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltDia
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTDIA
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltDia From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltDia
	_Super:New()
	self:setCodCrit('M044')
	self:setMsgCrit('O Valor Total Pago nas Di�rias da Guia � inv�lido.')
	self:setSolCrit('O Valor Total Pago nas Di�rias da Guia n�o pode ser um valor menor que 0 nas opera��es de Inclus�o ou Altera��o. ')
	self:setCpoCrit('BKR_VLTDIA')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltDia
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPRGMN='1') OR (BKR_TPRGMN='2') )"
	cQuery += " 	AND BKR_VLTDIA < 0 "
Return cQuery
