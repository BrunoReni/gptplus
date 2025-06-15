#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltTBP
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTTBP
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltTBP From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltTBP
	_Super:New()
	self:setCodCrit('M101')
	self:setMsgCrit('O Valor total pago em tabela pr�pria da operadora � inv�lido.')
	self:setSolCrit('O Valor total pago em tabela pr�pria da operadora da Guia n�o pode ser um valor menor que 0 nas opera��es de Inclus�o ou Altera��o. ')
	self:setCpoCrit('BKR_VLTTBP')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltTBP
	Local cQuery := ""
	cQuery += " 	AND BKR_VLTTBP < 0 "
Return cQuery