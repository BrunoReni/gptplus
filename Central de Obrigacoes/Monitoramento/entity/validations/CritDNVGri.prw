#Include "Totvs.ch"

#DEFINE RESU_INTER '3'
#DEFINE DNASC_VIVO '1'
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDNVGri
Descricao: 	Critica referente ao Campo.
				-> BKR_TPEVAT
@author Everton Lima
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDNVGri From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDNVGri
	_Super:New()
	self:setCodCrit('M118')
	self:setMsgCrit('A informa��o da Declara��o de Nascido Vivo s� pode constar em guias de Resumo de Interna��o.')
	self:setSolCrit('N�o deve ser preenchido Declara��es de Nascidos Vivos em guias que n�o sejam de Resumo de Interna��o (Tipo 3).')
	self:setCpoCrit('BKR_TPEVAT')
	self:setCodANS('')
Return Self

/*
	N�o deve ser incluido declara��es de nascido vivo
	Em guias que n�o sejam de interna��o

	Diferente de resumo de interna��o
	BKR_TPEVAT <> 3

	Declara��o de nascido vivo
	BN0_TIPO = 1
*/
Method getWhereCrit() Class CritDNVGri
	Local cQuery := ""
	cQuery	+= " AND BKR_TPEVAT <> '" + RESU_INTER + "' "
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



