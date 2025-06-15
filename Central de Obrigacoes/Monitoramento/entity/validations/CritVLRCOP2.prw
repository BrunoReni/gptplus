#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLRCOP2
Descricao: 	Critica referente ao Campo.
				-> BVT_VLRCOP
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLRCOP2 From CritGrpBVT
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLRCOP2
	_Super:New()
	self:setCodCrit('M097')
	self:setMsgCrit('Valor total da co-participa��o informado no item assistencial � inv�lido.')
	self:setSolCrit('O valor da coparticipa��o deve ser maior ou igual a zero.')
	self:setCpoCrit('BVT_VLRCOP')
	self:setCodAns('')
Return Self

Method getWhereCrit() Class CritVLRCOP2
	Local cQuery := ""
	cQuery += " 	AND BVT_VLRCOP < 0 "
Return cQuery