#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNES9T
Descricao: 	Critica referente ao Campo CNES - Cadastro Nacional de Estabelecimentos de Sa�de
				-> B9T_CNES
@author Jos� Paulo
@since 16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNES9T From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCNES9T
	_Super:New()
	self:setCodCrit('M112' )
	self:setMsgCrit('N�mero do CNES Inv�lido .')
	self:setSolCrit('Preencha o campo com N�mero do CNES v�lido e existente no Minist�rio da Sa�de.')
	self:setCpoCrit('B9T_CNES')
	self:setCodANS('1202')
Return Self

Method getWhereCrit() Class CritCNES9T
	Local cQuery := ""	
	cQuery += " 	AND (B9T_CNES='0000000') "
Return cQuery


