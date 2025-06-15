#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritGrpBKR
Classe abstrata das cr�ticas em grupo das guias do monitoramento TISS (BKR)
@author everton.mateus
@since 27/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritGrpBKR From CriticaB3F
	Method New() Constructor
	Method getQryCrit()
EndClass

Method New() Class CritGrpBKR
	_Super:New()
	self:setAlias('BKR')
Return Self

Method getQryCrit() Class CritGrpBKR
	Local cQuery := ""
	Local cDB	 := TCGetDB()
    Local cConcat:= IIf(SubStr(Alltrim(Upper(cDB)),1,5) == "MSSQL","+","||")

	cQuery += " SELECT BKR_FILIAL B3F_FILIAL "
	cQuery += " 	,BKR_CODOPE B3F_CODOPE "
	cQuery += " 	,BKR_CDOBRI B3F_CDOBRI "
	cQuery += " 	,BKR_CDCOMP B3F_CDCOMP "
	cQuery += " 	,BKR_ANO B3F_ANO "
	cQuery += " 	,'" + self:getAlias() + "' B3F_ORICRI "
	cQuery += " 	,BKR.R_E_C_N_O_ B3F_CHVORI "
	cQuery += " 	,'" + self:getCodCrit() + "' B3F_CODCRI "
	cQuery += " 	,BKR_LOTE B3F_DESORI "
	cQuery += " 	,BKR_CODOPE" +cConcat+ "BKR_NMGOPE" +cConcat+ "BKR_CDOBRI" +cConcat+ "BKR_ANO" +cConcat+ "BKR_CDCOMP" +cConcat+ "BKR_LOTE" +cConcat+ "BKR_DTPRGU B3F_IDEORI "
	cQuery += " 	,'" + self:getTpVld() + "' B3F_TIPO "
	cQuery += " 	,'" + self:getCpoCrit() + "' B3F_CAMPOS "
	cQuery += " 	,'" + self:getSolCrit() + "' B3F_SOLUCA "
	cQuery += " 	,'" + self:getStatus() + "' B3F_STATUS "
	cQuery += " 	,'" + self:getCodANS() + "' B3F_CRIANS "
	cQuery += " 	,'" + self:getMsgCrit() + "' B3F_DESCRI "
	cQuery += " 	,ROW_NUMBER() OVER (ORDER BY R_E_C_N_O_) + "

	If cDB == "POSTGRES"
		cQuery += "COALESCE"
	Elseif cDB == "ORACLE"
		cQuery += "NVL"
	Else 
		cQuery += "ISNULL"
	Endif
	
	cQuery += "((SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName('B3F') + " B3F),0)  R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName('BKR') + " BKR "
	cQuery += " WHERE 1 = 1 "
	cQuery += " 	AND BKR_FILIAL = '" + xFilial("B3F") + "' "
	cQuery += " 	AND BKR_STATUS IN ('','1','2','3') "
	cQuery += " 	AND BKR_CODOPE = '" + self:getOper() + "' "
	cQuery += self:getWhereCrit()
	cQuery += " 	AND BKR.D_E_L_E_T_ = ' ' "
Return cQuery
