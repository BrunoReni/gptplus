#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDiaUTI
Descricao: 	Critica referente ao Campo.
				-> BKR_DIAUTI
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDiaUTI From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDiaUTI
	_Super:New()
	self:setCodCrit('M039' )
	self:setMsgCrit('O N�mero de di�rias de UTI preenchida para uma guia inv�lida.')
	self:setSolCrit('O N�mero de di�rias de UTI n�o deve ser preenchido para guia que n�o seja de Interna��o')
	self:setCpoCrit('BKR_DIAUTI')
	self:setCodAns('1304')
Return Self

Method getWhereCrit() Class CritDiaUTI
	Local cQuery := ""
	cQuery += " 	AND BKR_TPEVAT <> '3' "
	cQuery += " 	AND ( (BKR_OREVAT='1') OR (BKR_OREVAT='2') OR (BKR_OREVAT='3') ) "
	cQuery += " 	AND BKR_DIAUTI <> '' "
Return cQuery


