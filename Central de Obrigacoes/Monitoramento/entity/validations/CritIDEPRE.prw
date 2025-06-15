#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIDEPRE
Descricao: 	Critica referente ao Campo.
				-> B9T_IDEPRE
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIDEPRE From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritIDEPRE
	_Super:New()
	self:setCodCrit('M075')
	self:setMsgCrit('O Tipo da identifica��o do prestador executante � inv�lido.')
	self:setSolCrit('Preencha corretamente o Tipo da identifica��o do prestador com um c�digo v�lido.')
	self:setCpoCrit('B9T_IDEPRE')
	self:setCodAns('M075')
Return Self

Method getWhereCrit() Class CritIDEPRE
	Local cQuery := ""
	cQuery += " 	AND ( B9T_IDEPRE = '' OR ( (B9T_IDEPRE<>'1') AND (B9T_IDEPRE<>'2') ) ) "
Return cQuery