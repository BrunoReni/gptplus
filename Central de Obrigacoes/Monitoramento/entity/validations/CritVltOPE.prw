#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltOPE
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTOPM
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltOPE From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritVltOPE
	_Super:New()
	self:setCodCrit('M047' )
	self:setMsgCrit('O Valor total das �rteses, pr�teses e materiais especiais selecionados (OPME) � inv�lido.')
	self:setSolCrit('O Valor total das �rteses, pr�teses e materiais especiais selecionados (OPME) da Guia n�o pode ser um valor menor que 0 nas opera��es de Inclus�o ou Altera��o. ')
	self:setCpoCrit('BKR_VLTOPM')
	self:setCodAns('5034')
Return Self

Method getWhereCrit() Class CritVltOPE
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPRGMN='1') OR (BKR_TPRGMN='2') ) "
	cQuery += " 	AND BKR_VLTOPM < 0 "
Return cQuery