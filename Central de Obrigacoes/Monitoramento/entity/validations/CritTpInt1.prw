#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTpInt1
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPINT
@author Jos� Paulo
@since 12/06/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTpInt1 From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritTpInt1
	_Super:New()
	self:setCodCrit('M115')
	self:setMsgCrit('Tipo de Interna��o � inv�lido (em branco).')
	self:setSolCrit('Preencha o Campo de Tipo de Interna��o conforme tabela de dom�nio vigente na vers�o que a guia foi enviada.')
	self:setCpoCrit('BKR_TIPINT')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritTpInt1
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT = '3' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND BKR_TIPINT = '' "
Return cQuery

