#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNE9T1
Descricao: 	Critica referente ao Campo CNES - Cadastro Nacional de Estabelecimentos de Sa�de
				-> B9T_CNES
@author Jos� Paulo
@since 16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNE9T1 From CritGrpB9T
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCNE9T1
	_Super:New()
	self:setCodCrit('M130' )
	self:setMsgCrit('N�mero do CNES Inv�lido .')
	self:setSolCrit('Preencha o campo com N�mero do CNES v�lido e existente no Minist�rio da Sa�de.')
	self:setCpoCrit('B9T_CNES')
	self:setCodANS('5029')
Return Self

Method getWhereCrit() Class CritCNE9T1
	Local cQuery := ""
	cQuery += " 	AND (B9T_CNES='') "
Return cQuery