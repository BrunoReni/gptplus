#Include "Totvs.ch"

#DEFINE INTER_OBST '3'
#DEFINE DNASC_VIVO '1'
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDNVObs
Descricao: 	Critica referente ao Campo.
				-> BKR_TIPINT
@author Everton Lima
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDNVObs From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass
Method New() Class CritDNVObs
	_Super:New()
	self:setCodCrit('M119')
	self:setMsgCrit('Para declarar nascidos vivos, tipo de interna��o deve ser obst�trica.')
	self:setSolCrit('Quando preenchido declara��es de nascido(s) vivo(s), tipo de interna��o deve ser obst�trica. (Tipo 3)')
	self:setCpoCrit('BKR_TIPINT')
	self:setCodANS('')
Return Self

/*
	Tipo de interna��o deve ser Obst�trica
	para declara��o de nascidos vivos

	Tipo de interna��o Diferente de Obst�trica
	BKR_TIPINT <> 3

	Declara��o de nascido vivo
	BN0_TIPO = 1
*/
Method getWhereCrit() Class CritDNVObs
	Local cQuery := ""
	cQuery	+= " AND BKR_TIPINT <> '" + INTER_OBST + "' "
	cQuery	+= " AND ( "
	cQuery	+= " 	SELECT count(*) FROM "+ RetSqlName("BN0") +" "
	cQuery	+= " 	WHERE 1=1 "
	cQuery	+= " 		AND BN0_CODOPE = BKR_CODOPE "
	cQuery	+= " 		AND BN0_TIPO = '" + DNASC_VIVO + "' "
	cQuery	+= " 		AND BN0_NMGOPE = BKR_NMGOPE "
	cQuery	+= " 		AND BN0_ANO = BKR_ANO "
	cQuery	+= " 		AND BN0_CDCOMP = BKR_CDCOMP "
	cQuery	+= " 		AND BN0_CDOBRI = BKR_CDOBRI "
	cQuery	+= " ) > 0 "
Return cQuery