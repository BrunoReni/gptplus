#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltTax
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTTAXDIA
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltTax  From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltTax
	_Super:New()
	self:setCodCrit('M045')
	self:setMsgCrit('O Valor Total Pago de taxas e alugueis � inv�lido.')
	self:setSolCrit('O Valor Total Pago de taxas e alugueis da Guia n�o pode ser um valor menor que 0 nas opera��es de Inclus�o ou Altera��o.')
	self:setCpoCrit('BKR_VLTTAX')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltTax
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPRGMN='1') or (BKR_TPRGMN='2') ) "
	cQuery += " 	AND BKR_VLTTAX < 0 "
Return cQuery
