#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODMUN2
Descricao: 	Critica referente ao Campo.
				-> BVQ_MATRIC
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODMUN2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODMUN2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M085')
	self:setCpoCrit('BVQ_MATRIC')
Return Self

Method Validar() Class CritCODMUN2

	Local lValido		:= .T.
	Local lValidMun := .T.
	Local cCNS      := ''
	Local cCodMun   := ''
	Local cCodANS	  := ''
  Local cMsgCrit  := ''
  Local cSolCrit  := ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	  := nil

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	//Encontrou a Matricula
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())
		cCNS := oBenef:getCNS()
		cCodMun := oBenef:getCodMun()
		lValidMun := GetCdMun(cCodMun)

		If Empty(cCNS) .AND. Empty(cCodMun)
			lValido		:= .F.
			cCodANS		:= '5029'
			cMsgCrit	:= 'C�digo do munic�pio e CNS do benefici�rio em branco.'
			cSolCrit	:= 'Preencher o c�digo do munic�pio e/ou c�digo da CNS do benefici�rio com um valor v�lido.'
		Elseif !(Empty(cCodMun)) .AND. !(lValidMun)
			lValido		:= .F.
			cCodANS		:= '5030'
			cMsgCrit	:= 'C�digo do Munic�pio do Executante Inv�lido.'
			cSolCrit	:= 'O C�digo do Munic�pio informado deve ser um c�digo v�lido e incluso na base de dados de munic�pios do IBGE.'
		EndIf

		oBenef:destroy()

	else
		lValido		:= .F.
		cCodANS		:= '5029'
		cMsgCrit	:= 'C�digo de Munic�pio Inv�lido.'
		cSolCrit	:= 'Verifique se Benefici�rio est� cadastrado na tabela de Benefici�rios.'
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
