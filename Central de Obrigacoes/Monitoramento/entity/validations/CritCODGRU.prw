#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODGRU
Descricao: 	Critica referente ao Campo.
				-> BKS_CODGRU 
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODGRU From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODGRU
	_Super:New()
	self:setAlias('BKS')
	self:setCodCrit('M058' )
	self:setMsgCrit('O C�digo TUSS identificador do grupo de procedimentos ou itens assistenciais � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo C�digo TUSS identificador do grupo de procedimentos ou itens assistenciais, conforme tabela de dom�nio n� 63.')
	self:setCpoCrit('BKS_CODTAB')
	self:setCodAns('5029')
Return Self

Method Validar() Class CritCODGRU
	Local lRet			:= .T.

	If !Empty(self:oEntity:getValue("procedureGroup"))
		If !ExisTabTiss((Self:cAlias)->BKS_CODGRU,'63') 
			lRet	:= .F.
			self:setSolCrit('Deve ser um c�digo v�lido na base de termos da tabela TUSS - Tabela 63 - Terminologia de Grupos de procedimentos e itens assistenciais para envio para ANS')
		Else
			oColBKS	:= CenCltBKS():New()
			oColBKS:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
			oColBKS:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
			oColBKS:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
			oColBKS:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
			oColBKS:setValue("operatorFormNumber",self:oEntity:getValue("operatorFormNumber"))
			oColBKS:setValue("formProcDt",self:oEntity:getValue("formProcDt"))
			oColBKS:setValue("procedureGroup",self:oEntity:getValue("procedureGroup"))
			oColBKS:setValue("tableCode",self:oEntity:getValue("tableCode"))

			If oColBKS:qtdGrupo() > 1
				lRet := .F.
				self:setSolCrit('N�o deve haver repeti��o da tabela de refer�ncia em conjunto com o c�digo do grupo ou item assistencial no fornecimento direto de materiais e medicamentos.')
			EndIf 
			oColBKS:destroy()
			FreeObj(oColBKS)
			oColBKS := nil
		EndIf
	EndIf
Return lRet 
