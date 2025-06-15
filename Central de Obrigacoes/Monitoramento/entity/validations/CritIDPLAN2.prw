#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIDPLAN2
Descricao: 	Critica referente ao Campo.
				-> BVQ_MATRIC
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIDPLAN2 From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritIDPLAN2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M086')
	self:setMsgCrit('N�mero de registro do plano do benefici�rio (RPS) ou n�mero de cadastro do plano (SCPA) � inv�lido.')
	self:setSolCrit('Corrija o conte�do do campo N�mero de registro do plano do benefici�rio (RPS) ou n�mero de cadastro do plano do benefici�rio (SCPA).')
	self:setCpoCrit('BVQ_MATRIC')
	self:setCodAns('1024')
Return Self

Method Validar() Class CritIDPLAN2
	Local lRet		:= .T.
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())  
		self:setRecno(BKR->(Recno()))

		If Empty(oBenef:getSusep()) .And. Empty(oBenef:getScpa())
			lRet := .F.
		EndIf
		oBenef:destroy()
		FreeObj(oBenef)
		oBenef := nil
	Else
		lRet	:= .F.
	EndIf
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
