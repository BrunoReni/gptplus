#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLTGLO2
Descricao: 	Critica referente ao Campo.
				-> BVZ_VLTGLO
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLTGLO2 From CritGrpBVZ
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLTGLO2
	_Super:New()
	self:setCodCrit('M107')
	self:setMsgCrit('O campo Valor total de glosa � inv�lido.')
	self:setSolCrit('O Valor total glosado do recebedor na compet�ncia deve  ser maior ou igual a zero. ')
	self:setCpoCrit('BVZ_VLTGLO')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVLTGLO2
	Local cQuery := ""
	cQuery += " 	AND BVZ_VLTGLO < 0 "
Return cQuery