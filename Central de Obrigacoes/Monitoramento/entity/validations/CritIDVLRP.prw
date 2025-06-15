#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIDVLRP
Descricao: 	Critica referente ao Campo.
				-> BKR_IDVLRP
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIDVLRP From CriticaB3F

	Method New() Constructor
	Method Validar()

EndClass

Method New() Class CritIDVLRP

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M052' )
	self:setMsgCrit('O Identificador de contrata��o por valor pr�-estabelecido � inv�lido.')
	self:setSolCrit('Preencha corretamente com o N�mero atribu�do pela operadora para identificar uma contrata��o por valor pr�-estabelecido')
	self:setCpoCrit('BKR_IDVLRP')
	self:setCodAns('5052')

Return Self

Method Validar() Class CritIDVLRP

	Local lRet		:= .T.
	Local oCltBW8	:= Nil

	If !Empty(Self:oEntity:getValue("presetValueIdent"))

		oCltBW8	:= CenCltBw8():New()

		oCltBw8:SetValue("operatorRecord"		,Self:oEntity:getValue("operatorRecord"))
		oCltBw8:SetValue("formSequential"		,Self:oEntity:getValue("presetValueIdent"))
		
		lRet := oCltBw8:bscChaPrim()

		oCltBw8:destroy()
		FreeObj(oCltBw8)
		oCltBw8 := nil

	EndIf

Return  lRet
