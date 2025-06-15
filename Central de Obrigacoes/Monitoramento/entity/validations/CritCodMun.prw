#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCodMun
Descricao: 	Critica referente ao Campo de C�digo de Municipio
				-> BKR_CDMNEX
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCodMun From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCodMun

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M020')
	self:setMsgCrit('C�digo do Munic�pio do Executante Inv�lido.')
	self:setSolCrit('O C�digo do Munic�pio informado deve ser um c�digo v�lido e incluso na base de dados de munic�pios do IBGE.')
	self:setCpoCrit('BKR_CDMNEX')
	self:setCodAns('5030')

Return Self

Method Validar() Class CritCodMun
	Local lValido   := .T.
	Local lValidMun := .T.
	Local cCNS      := ''
	Local cCodMun   := ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	  := nil
	Local cCodANS	  := ''
	Local cMsgCrit  := ''
	Local cSolCrit  := ''

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	//Encontrou a Matricula
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())
		cCNS := oBenef:getCNS()
		cCodMun := Self:oEntity:getValue("executingCityCode")

		lValidMun := GetCdMun(cCodMun)

		// If Empty(cCNS) .AND. Empty(cCodMun)
		// 	lValido   := .F.
		// 	cCodANS		:= '5029'
		// 	cMsgCrit	:= 'C�digo do munic�pio e CNS do benefici�rio em branco.'
		// 	cSolCrit	:= 'Preencher o c�digo do munic�pio e/ou c�digo da CNS do benefici�rio com um valor v�lido.'
		If !(Empty(cCodMun)) .AND. !(lValidMun)
			lValido   := .F.
			cCodANS		:= '5030'
			cMsgCrit	:= 'C�digo do Munic�pio do Executante Inv�lido.'
			cSolCrit	:= 'O C�digo do Munic�pio informado deve ser um c�digo v�lido e incluso na base de dados de munic�pios do IBGE.'
		EndIf

		oBenef:destroy()
	Else
		cCodANS		:= '5029'
		cMsgCrit	:= 'C�digo de Munic�pio Inv�lido.'
		cSolCrit	:= 'Verifique se Benefici�rio est� cadastrado na tabela de Benefici�rios.'
		lValido		:= .F.
	EndIf

	Self:SetCodANS(cCodANS)
	Self:setMsgCrit(cMsgCrit)
	Self:setSolCrit(cSolCrit)
	
	oBscBenef:destroy()
	oBscBenef := nil
	oBenef := nil
	FreeObj(oBscBenef)
	FreeObj(oBenef)

Return lValido
