#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIndAcid
Descricao: 	Critica referente ao Campo.
				-> BKR_INDACI
@author Hermiro J�nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIndAcid From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritIndAcid
	_Super:New()
	self:setCodCrit('M029' )
	self:setMsgCrit('Indicador de Acidente ou Doen�a Relacionada � inv�lido.')
	self:setSolCrit('Preencha o Campo de Indicador se o atendimento � devido a acidente ocorrido com o benefici�rio ou doen�a relacionada, conforme tabela de dom�nio vigente na vers�o que a guia foi enviada.')
	self:setCpoCrit('BKR_INDACI')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritIndAcid
	Local cQuery := ""
	cQuery += " 	AND ( BKR_INDACI NOT IN ('','0','1','2','9') "
	cQuery += " 		OR ( BKR_TPEVAT IN ('1','2','3') "
	cQuery += " 	  		AND BKR_OREVAT IN ('1','2','3') "
	cQuery += " 	 		AND BKR_INDACI = '' ) "
	cQuery += " 	  ) "
Return cQuery