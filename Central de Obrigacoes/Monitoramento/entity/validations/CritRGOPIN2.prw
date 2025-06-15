#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritRGOPIN2
Descricao: 	Critica referente ao Campo.
				-> B9T_RGOPIN
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritRGOPIN2 From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritRGOPIN2
	_Super:New()
	self:setCodCrit('M078')
	self:setMsgCrit('O Registro ANS da operadora intermedi�ria � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo Registro da operadora intermedi�ria contratada por valor pr�-estabelecido.')
	self:setCpoCrit('B9T_RGOPIN')
	self:setCodAns('5027')
Return Self

Method getWhereCrit() Class CritRGOPIN2
	Local cQuery := ""
	cQuery += " AND (B9T_RGOPIN =''	OR B9T_CODOPE = B9T_RGOPIN) "

Return cQuery