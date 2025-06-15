#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_JURI.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} RBE_JURI
Fun��o de compatibiliza��o antes da execu��o de Base do UPDDISTR.
Esta fun��o � relativa ao m�dulo Juridico.

@param  cVersion   - Vers�o do Protheus
@param  cMode      - Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release del chegada Ex: 005
@param  cLocaliz   - Localiza��o (pa�s). Ex: BRA

@Author Willian Kazahaya
@since 03/03/2015
@version P12
*/
//-------------------------------------------------------------------
Function RBE_JURI(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	Default cVersion	:= ''
	Default cMode		:= '1'
	Default cRelStart	:= "017"
	Default cRelFinish	:= ''
	Default cLocaliz	:= ''

	#IFNDEF TOP
		Return Nil
	#ENDIF

	conout("[RBE_JURI] Versao:" + cVersion + " | Modo: " + cMode + " | Release Inicial:" + cRelStart + "| Release Final: " + cRelFinish + "|")
	conout("[RBE_JURI] Inicio: " + Time())

	If cRelStart >= "017"
		If (FWX2Unico('NUM') == "NUM_FILIAL+NUM_COD+NUM_DOC")
			RBEJUR3862()
		EndIf
	EndIf

	conout("[RBE_JURI] Final: " + Time())
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RBEJUR3862()
Ajuste no ID dos Anexos para atualiza��o do X2_UNICO

@since 	 16/05/2018
@author Willian.Kazahaya
@version 1.0
/*/
//-------------------------------------------------------------------
Function RBEJUR3862()
Local cQuery  := ""
Local cQrySel := ""
Local cQryFrm := ""
Local cQryWhr := ""
Local cQryHvg := ""
Local cQryGrp := ""
Local cQryOrd := ""
Local cAlias  := ""
Local cSubAls := ""
Local cNumCod := ""
Local lRet    := .T.

	// Query para buscar os ID's duplicados
	cQrySel := " SELECT NUM_COD "
	cQrySel +=       " ,NUM_FILIAL "
	cQrySel +=       " ,COUNT(*) Quant "

	cQryFrm := " FROM " + RetSqlName("NUM") + " NUM "
	cQryWhr := " WHERE NUM_FILIAL = '" + xFilial("NUM") + "'"
	cQryGrp := " GROUP BY NUM_COD, NUM_FILIAL "
	cQryHvg := " HAVING COUNT(*) > 1 "

	cQryOrd := " ORDER BY NUM_COD "

	cQuery := cQrySel + cQryFrm + cQryWhr + cQryGrp + cQryHvg + cQryOrd

	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	// Loop para atualizar os ID's
	While !(cAlias)->(Eof())
		( "NUM" )->( dbSetOrder( 1 ) )
		While ( "NUM" )->( dbSeek ( (cAlias)->NUM_FILIAL + (cAlias)->NUM_COD ) )
			cNumCod := GetSXENum("NUM","NUM_COD")
			lRet    := RecLock( "NUM" , .F.  )

			NUM->NUM_COD := cNumCod
			MsUnLock()
		EndDo

		While __lSX8
			If lRet
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf

			lRet := .T.
		EndDo
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
Return Nil
