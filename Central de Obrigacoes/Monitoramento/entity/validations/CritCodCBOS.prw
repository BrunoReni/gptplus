#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCodCBOS
Descricao: 	Critica referente ao Campo.
				-> BKR_CBOS
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCodCBOS From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCodCBOS

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M027')
	self:setMsgCrit('CBO do Executante Inv�lido.')
	self:setSolCrit('Preencha o C�digo CBOS do executante do Procedimento conforme tabela de dom�nio vigente na vers�o que a guia foi enviada.')
	self:setCpoCrit('BKR_CBOS')
	self:setCodAns('1213')
Return Self

Method Validar() Class CritCodCBOS

	Local lRet		:= .T.
	Local cCodANS	:= ''

	If AllTrim(Self:oEntity:getValue("cboSCode")) == '999999' .Or. AllTrim(Self:oEntity:getValue("cboSCode")) == ''
		lRet		:= .F.
		cCodANS	:= '1213'		
	EndIf
	
	Self:SetCodANS(cCodANS)

Return lRet
