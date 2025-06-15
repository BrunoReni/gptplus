#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritINDTPRG
Descricao: 	Critica referente ao Campo.
				-> B9T_TPRGMN
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritINDTPRG From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritINDTPRG
	_Super:New()
	self:setCodCrit('M073')
	self:setMsgCrit('O Indicador do tipo de registro � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo Indicador de tipo do registro que est� sendo enviado � ANS.')
	self:setCpoCrit('B9T_TPRGMN')
	self:setCodAns('M073')
Return Self

Method getWhereCrit() Class CritINDTPRG
	Local cQuery := ""
	cQuery += " 	AND ( (B9T_TPRGMN<>'1') AND (B9T_TPRGMN<>'2') AND (B9T_TPRGMN<>'3') ) "
Return cQuery