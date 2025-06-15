#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDiaAco
Descricao: 	Critica referente ao Campo.
				-> BKR_DIAACP
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDiaAco From CritGrpBKR

	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDiaAco
	_Super:New()
	self:setCodCrit('M038' )
	self:setMsgCrit('O N�mero de di�rias de acompanhante n�o � v�lido.')
	self:setSolCrit('Preencha o Campo N�mero de di�rias de acompanhante com a quantidade de di�rias onde houve pagamento de acompanhante.')
	self:setCpoCrit('BKR_DIAACP')
	self:setCodAns('1304')
Return Self

Method getWhereCrit() Class CritDiaAco
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT = '3' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND BKR_DIAACP = '' "
Return cQuery



