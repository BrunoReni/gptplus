#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCPFCNPJ2
Descricao: 	Critica referente ao Campo.
				-> BVZ_CPFCNP
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCPFCNPJ2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCPFCNPJ2
	_Super:New()
	self:setAlias('BVZ')
	self:setCodCrit('M100')
	self:setMsgCrit('O campo N�mero de cadastro do recebedor na Receita Federal � inv�lido.')
	self:setSolCrit('O CPF / CNPJ deve ser um n�mero v�lido e existir na base de dados da Receita Federal.')
	self:setCpoCrit('BVZ_CPFCNP')
	self:setTpVld('1')
	self:setCodAns('1206')
Return Self

Method Validar() Class CritCPFCNPJ2
Return !Empty(Self:oEntity:getValue("providerCpfCnpj")) .And. (AllTrim(Self:oEntity:getValue("providerCpfCnpj")) != '00000000000000' .And. CGC(Self:oEntity:getValue("providerCpfCnpj"),,.F.))
