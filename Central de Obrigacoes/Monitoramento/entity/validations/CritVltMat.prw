#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltMat
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTMAT
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltMat From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltMat
	_Super:New()
	self:setCodCrit('M046')
	self:setMsgCrit('O Valor Total dos materiais � inv�lido.')
	self:setSolCrit('O Valor Total dos materiais da Guia n�o pode ser um valor menor que 0 nas opera��es de Inclus�o ou Altera��o. ')
	self:setCpoCrit('BKR_VLTMAT')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltMat
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPRGMN='1') OR (BKR_TPRGMN='2') )"
	cQuery += " 	AND BKR_VLTMAT < 0 "
Return cQuery

	

