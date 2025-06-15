#Include "Totvs.ch" 
#Include "WMSDTCDemandaUnitizacaoDelete.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0058
Fun��o para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inova��o WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0058()
Return Nil
//-------------------------------------------------
/*/{Protheus.doc} WMSDTCDemandaUnitizacaoDelete
Classe Exclus�o demanda de unitiza��o
@author Squad WMS
@since 05/05/2017
@version 1.0
/*/
//-------------------------------------------------
CLASS WMSDTCDemandaUnitizacaoDelete FROM WMSDTCDemandaUnitizacao
	// Method
	METHOD New() CONSTRUCTOR
	METHOD SetQtdDel(nQtdDel)
	METHOD CanDelete()
	METHOD DeleteD0Q()
	METHOD Destroy()
ENDCLASS
//-------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor
@author Squad WMS
@since 05/05/2017
@version 1.0
/*/
//-------------------------------------------------
METHOD New() CLASS WMSDTCDemandaUnitizacaoDelete
	_Super:New()
Return

METHOD Destroy() CLASS WMSDTCDemandaUnitizacaoDelete
	//Mantido para compatibilidade
Return

METHOD SetQtdDel(nQtdDel) CLASS WMSDTCDemandaUnitizacaoDelete
	Self:nQtdDel := nQtdDel
Return 

//-------------------------------------------------
/*/{Protheus.doc} CanDelete
Verifica se pode deletar
@author Squad WMS
@since 05/05/2017
@version 1.0
/*/
//-------------------------------------------------
METHOD CanDelete() CLASS WMSDTCDemandaUnitizacaoDelete
Local lRet      := .T.
Local cAliasD0Q := GetNextAlias()
	BeginSql Alias cAliasD0Q
		SELECT D0Q.D0Q_ID,
				D0Q.D0Q_CODPRO,
				D0Q.D0Q_STATUS
		FROM %Table:D0Q% D0Q 
		WHERE D0Q.D0Q_FILIAL = %xFilial:D0Q%
		AND D0Q.D0Q_DOCTO = %Exp:Self:cDocumento%
		AND D0Q.D0Q_SERIE = %Exp:Self:cSerie%
		AND D0Q.D0Q_CLIFOR = %Exp:Self:cCliFor%
		AND D0Q.D0Q_LOJA = %Exp:Self:cLoja%
		AND D0Q.D0Q_STATUS <> '1'
		AND D0Q.%NotDel%
	EndSql
	If (cAliasD0Q)->(!EoF())
		If (cAliasD0Q)->D0Q_STATUS == "2"
			Self:cErro := STR0004 // "A demanda de unitiza��o est� em andamento no processo WMS."
		Else
			Self:cErro := STR0005 // "A demanda de unitiza��o est� finalizada no processo WMS."
		EndIf
		Self:cErro += CRLF + STR0001 // "Dever� ser desfeito o processo de unitiza��o no WMS manualmente."
		lRet := .F.
	EndIf
	(cAliasD0Q)->(dbCloseArea())
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} DeleteD0Q
Deleta a Demanda de Unitiza��o
@author Squad WMS
@since 05/05/2017
@version 1.0
/*/
//-------------------------------------------------
METHOD DeleteD0Q() CLASS WMSDTCDemandaUnitizacaoDelete
Local lRet       := .T.
	If !(lRet := Self:CanDelete())
		lRet := .F.
	EndIf
	If lRet
		If !(lRet := Self:UndoIntegr())
			Self:cErro := STR0002 // N�o foi poss�vel desfazer a integra��o da demanda de unitiza��o! 
		EndIf
	EndIf
	If lRet
		If !(lRet := Self:ExcludeD0Q())
			Self:cErro := STR0003 // N�o foi poss�vel excluir a demanda de unitiza��o!
		EndIf
	EndIf
Return lRet
