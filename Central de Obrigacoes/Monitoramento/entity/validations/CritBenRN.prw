#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritBenRN
Descricao: 	Critica referente ao Campo.
				-> BKR_INAVIV
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritBenRN From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritBenRN

	_Super:New()
	self:setCodCrit('M028')
	self:setMsgCrit('Indicador de Rec�m-Nato Inv�lido.')
	self:setSolCrit('Preencha o Campo de Indicador de Atendimento de Rec�m-Nato nos termos do Art. 12, inciso III, al�nea a, da Lei 9.656, de 03 de junho de 1998.')
	self:setCpoCrit('BKR_INAVIV')
	self:setCodANS('5032')
Return Self

Method getWhereCrit() Class CritBenRN
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPEVAT='1') OR (BKR_TPEVAT='2') OR (BKR_TPEVAT='3') ) "
	cQuery += " 	AND ( (BKR_INAVIV<>'S') AND (BKR_INAVIV<>'N') )"
Return cQuery