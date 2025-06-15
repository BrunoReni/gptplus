#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODTAB
Descricao: 	Critica referente ao Campo.
				-> BKS_CODTAB 
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODTAB From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCODTAB
	_Super:New()
	self:setAlias('BKS')
	self:setCodCrit('M057')
	self:setMsgCrit('O C�digo da Tabela de refer�ncia do procedimento ou item assistencial realizado � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo C�digo da tabela TUSS de identifica��o dos procedimentos ou itens assistenciais, conforme tabela de dom�nio n� 87.')
	self:setCpoCrit('BKS_CODTAB')
	self:setCodAns('5029')

Return Self

Method getWhereCrit() Class CritCODTAB
	Local cQuery := ""
	cQuery += " 	AND BKS_CODTAB NOT IN ("
	cQuery += " 		SELECT B2R_CDTERM "
	cQuery += " 		FROM " + RetSqlName('B2R') + " B2R " 
	cQuery += " 		WHERE  1=1 "
	cQuery += "				AND B2R_CODTAB = '87' AND B2R_CDTERM IN ('00','18','19','20','22','90','98') "
	cQuery += "				AND (B2R_VIGATE = '' OR B2R_VIGATE <= '" + DtoS(Date()) + "') "
	cQuery += "				AND D_E_L_E_T_ = '' ) "

Return cQuery