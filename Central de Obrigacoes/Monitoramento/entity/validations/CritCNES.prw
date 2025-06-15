#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNES
Descricao: 	Critica referente ao Campo CNES - Cadastro Nacional de Estabelecimentos de Sa�de
				-> BKR_CNES
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNES From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCNES
	_Super:New()
	self:setCodCrit('M001' )
	self:setMsgCrit('N�mero do CNES Inv�lido .')
	self:setSolCrit('Preencha o campo com N�mero do CNES v�lido e existente no Minist�rio da Sa�de.')
	self:setCpoCrit('BKR_CNES')
	self:setCodANS('1202')
Return Self

Method getWhereCrit() Class CritCNES
	Local cQuery := ""
	cQuery += " 	AND (BKR_CNES='0000000') "
Return cQuery


