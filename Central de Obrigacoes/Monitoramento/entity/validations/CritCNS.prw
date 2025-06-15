#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNS
Descricao: 	Critica referente ao Campo Numero do Lote.
				-> BKR_CNS
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNS From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCNS

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M018')
	self:setMsgCrit('')
	self:setSolCrit('')
	self:setCpoCrit('B3K_CNS')
	
Return Self

Method Validar() Class CritCNS

	Local lRet		:= .T.
	Local cMsgCrit	:= ''
	Local cSolCrit  := ''
	Local cCodANS	:= ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	:= nil

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	//Encontrou a Matricula
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())
		
		If Empty(oBenef:getCNS()) .OR. !CenVldCns(oBenef:getCNS())
			lRet	:= .F.	
			cCodANS		:= '1002'
			cMsgCrit	:= 'N�mero do Cart�o Nacional de Sa�de do Benefici�rio est� vazio ou � Inv�lido.'
			cSolCrit	:= 'Corrigir o conte�do do N�mero do Cart�o Nacional de Sa�de do Benefici�rio para um n�mero v�lido.'
		EndIf 
		oBenef:destroy()
		FreeObj(oBenef)
		oBenef := nil
	Else
		cCodANS		:= '5029'
		cMsgCrit	:= 'N�mero do Cart�o Nacional de Sa�de do Benefici�rio � Inv�lido.'
		cSolCrit	:= 'Verifique se Benefici�rio est� cadastrado na tabela de Benefici�rios.'
		lRet		:= .F.
	EndIf

	Self:SetCodANS(cCodANS)
	Self:setMsgCrit(cMsgCrit)
	Self:setSolCrit(cSolCrit)
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
