#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritMunBen
Descricao: 	Critica referente ao Campo de C�digo de Municipio
				-> B3K_CODMUN
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritMunBen From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritMunBen

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M013' )
	self:setMsgCrit('C�digo do Munic�pio do Benefici�rio Inv�lido.')
	self:setSolCrit('')
	self:setCpoCrit('B3K_CODMUN')
	self:setCodAns('5030')
	
Return Self

Method Validar() Class CritMunBen

	Local cSolCrit		:= ''
	Local lRet			:= .T.
	Local oDaoBenef 	:= DaoCenBenefi():new()
	Local oBscBenef 	:= BscCenBenefi():new(oDaoBenef)

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))

	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())  
		self:setRecno(BKR->(Recno()))

		cCNS := oBenef:getCNS()

		If (!GetCdMun(oBenef:getCodMun()) .AND. !Empty(oBenef:getCodMun()) ) .OR. (Empty(cCNS) .AND. Empty(oBenef:getCodMun()))
			lRet	:= .F.
			cSolCrit		:= 'O C�digo do Munic�pio informado deve ser um c�digo v�lido e incluso na base de dados de munic�pios do IBGE.
		EndIf
		oBenef:destroy()
		FreeObj(oBenef)
		oBenef := nil		
	Else
		lRet	:= .F.
		cSolCrit		:= 'Verifique o preenchimento do Campo C�digo do Munic�pio do Benefici�rio.'
		self:setCodAns('5029')
	EndIf
	
	Self:setSolCrit(cSolCrit)

	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
