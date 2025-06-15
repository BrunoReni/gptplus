#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNES1
Descricao: 	Critica referente ao Campo CNES - Cadastro Nacional de Estabelecimentos de Sa�de
				-> BKR_CNES1
@author Jos� Paulo
@since 16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNES1 From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCNES1
	_Super:New()
	self:setCodCrit('M131' )
	self:setMsgCrit('N�mero do CNES Inv�lido .')
	self:setSolCrit('Preencha o campo com N�mero do CNES v�lido e existente no Minist�rio da Sa�de.')
	self:setCpoCrit('BKR_CNES')
	self:setCodANS('5029')
Return Self

Method getWhereCrit() Class CritCNES1
	Local cQuery := ""
	cQuery += " 	AND (BKR_CNES='') "
Return cQuery

