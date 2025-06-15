#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCDDENT
Descricao: 	Critica referente ao Campo.
				-> BKS_CDDENT 
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCDDENT From CritGrpBKS
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCDDENT
	_Super:New()
	self:setCodCrit('M060')
	self:setMsgCrit('O C�digo de Identifica��o da denti��o permanente ou dec�dua � inv�lido.')
	self:setSolCrit('Preencha corretamente o campo Identifica��o da denti��o permanente ou dec�dua segundo tabela de dom�nio de dentes na vigente vers�o que a guia foi enviada.')
	self:setCpoCrit('BKS_CDDENT')
	self:setCodANS('5029')
Return Self

Method getWhereCrit() Class CritCDDENT
	Local cQuery := ""
	    cQuery += " 	AND (BKS_CDFACE <> '' AND BKS_CDDENT = '') OR ( BKS_CDDENT <> '' AND BKS_CDDENT NOT IN ( "
		cQuery += " SELECT B2R_CDTERM "
		cQuery += " FROM " + RetSqlName("B2R") + " "
		cQuery += " WHERE B2R_CODTAB = '28' "
		cQuery += " AND B2R_VIGDE <> '' "
		cQuery += " AND B2R_VIGDE <= '" + DTOS(Date()) + "' "
		cQuery += " AND (B2R_VIGATE = '' OR B2R_VIGATE >= '" + DTOS(Date()) + "' "

		cQuery += " )))"

Return cQuery