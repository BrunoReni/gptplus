#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritRegInt
Descricao: 	Critica referente ao Campo.
				-> BKR_REGINT
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritRegInt From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritRegInt
	_Super:New()
	self:setCodCrit('M031')
	self:setMsgCrit('Tipo de Regime de Interna��o � inv�lido.')
	self:setSolCrit('Preencha o Campo de acordo com os c�digos disponiveis na tabela 41 - Terminologia de Regime de Interna��o.')
	self:setCpoCrit('BKR_REGINT')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritRegInt
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT = '3' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND ( (BKR_REGINT<>'1') AND (BKR_REGINT<>'2') AND (BKR_REGINT<>'3') ) "
Return cQuery