#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CritDDatNas
Descricao: 	Critica referente ao Campo.

@author jose.paulo
@since 30/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDDtNas From CritGrpB2W
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDDtNas
	_Super:New()
	self:setCodCrit('DM10')
	self:setMsgCrit('O Campo Data de Nascimento do Dependente inv�lido.')
	self:setSolCrit('O Campo Data de Nascimento � obrigat�rio para menores de 18 anos que n�o tenham informado CPF.Campo de tamanho 8 e padr�o AAAAMMDD')
	self:setCpoCrit('B2W_DTNASD')
	self:setCodANS('')
Return Self

Method getWhereCrit() Class CritDDtNas
	Local cQuery := ""
	cQuery += "  AND B2W_CPFBEN = '' "
	cQuery += "  AND B2W_DTNASD = '' "
	cQuery += "  AND B2W_IDEREG = '3' "
Return cQuery

