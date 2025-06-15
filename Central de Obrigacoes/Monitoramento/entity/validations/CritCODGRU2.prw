#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODGRU2
Descricao: 	Critica referente ao Campo.
				-> BVT_CODGRU
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODGRU2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODGRU2
	_Super:New()
	self:setAlias('BVT')
	self:setCodCrit('M093')
	self:setMsgCrit('O campo C�digo do grupo do procedimento ou item assistencial � inv�lido.')
	self:setSolCrit('O conte�do do Campo C�digo TUSS identificador do grupo de itens assistenciais fornecidos deve ser um c�digo v�lido, conforme tabela de dom�nio n� 63.')
	self:setCpoCrit('BVT_CODGRU')
	self:setCodAns('5929')
Return Self

Method Validar() Class CritCODGRU2
	Local lRet			:= .T.

	If !Empty(self:oEntity:getValue("procedureGroup"))
		If !ExisTabTiss((Self:cAlias)->BVT_CODGRU,'63') 
			lRet	:= .F.
			self:setCodANS('5036')
			self:setSolCrit('Deve ser um c�digo v�lido na base de termos da tabela TUSS - Tabela 63 - Terminologia de Grupos de procedimentos e itens assistenciais para envio para ANS')
		Else
			oColBVT	:= CenCltBVT():New()
			oColBVT:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
			oColBVT:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
			oColBVT:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
			oColBVT:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
			oColBVT:setValue("providerFormNumber",self:oEntity:getValue("providerFormNumber"))
			oColBVT:setValue("formProcDt",self:oEntity:getValue("formProcDt"))
			oColBVT:setValue("procedureGroup",self:oEntity:getValue("procedureGroup"))
			oColBVT:setValue("tableCode",self:oEntity:getValue("tableCode"))

			If oColBVT:qtdGrupo() > 1
				lRet := .F.
				self:setCodANS('5053')
				self:setSolCrit('N�o deve haver repeti��o da tabela de refer�ncia em conjunto com o c�digo do grupo ou item assistencial no fornecimento direto de materiais e medicamentos.')
			EndIf 
			oColBVT:destroy()
			FreeObj(oColBVT)
			oColBVT := nil
		EndIf
	EndIf
Return lRet 
