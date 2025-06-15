#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVLRPRE
Descricao: 	Critica referente ao Campo.
				-> B9T_VLRPRE
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVLRPRE From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVLRPRE
	_Super:New()
	self:setCodCrit('M079' )
	self:setMsgCrit('O Valor da cobertura contratada na compet�ncia � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo Valor da cobertura contratada, referente ao per�odo de compet�ncia (m�s e ano) informado, em uma contrata��o por valor pr�-estabelecido.')
	self:setCpoCrit('B9T_VLRPRE')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVLRPRE
	Local cQuery := ""
	cQuery += " 	AND B9T_VLRPRE <= 0 "
Return cQuery