#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNS2
Descricao: 	Critica referente ao Campo.
				-> BVQ_MATRIC
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNS2 From CritCNS
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCNS2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M082')
	self:setMsgCrit('N�mero do Cart�o Nacional de Sa�de do Benefici�rio est� vazio ou � Inv�lido.')
	self:setSolCrit('Corrigir o conte�do do N�mero do Cart�o Nacional de Sa�de do Benefici�rio para um n�mero v�lido.')
	self:setCpoCrit('BVQ_MATRIC')
	self:setTpVld('1')
	self:setCodAns('1002')
Return Self

Method Validar() Class CritCNS2

	Local lRet		:= .T.
	Local oCritCNS	:= CritCNS():new()
	
	oCritCNS:setEntity(self:oEntity)
	lRet := oCritCNS:validar()
	Self:SetCodANS(oCritCNS:getCodANS())
	Self:setMsgCrit(oCritCNS:getMsgCrit())
	Self:setSolCrit(oCritCNS:getSolCrit())
	
	oCritCNS:destroy()
	oCritCNS := nil
	FreeObj(oCritCNS)

Return lRet