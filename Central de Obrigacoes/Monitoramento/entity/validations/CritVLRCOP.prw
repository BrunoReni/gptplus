#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLRCOP
Descricao: 	Critica referente ao Campo.
				-> BKS_VLRCOP  
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLRCOP From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLRCOP
	_Super:New()
	self:setCodCrit('M069')
	self:setMsgCrit('O Valor de co-participa��o � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo Valor da co-participa��o do benefici�rio referente � realiza��o dos procedimentos conforme guia enviada.')
	self:setCpoCrit('BKS_VLRCOP')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVLRCOP
	Local cQuery := ""
	cQuery += " 	AND BKS_VLRCOP < 0 "
Return cQuery
