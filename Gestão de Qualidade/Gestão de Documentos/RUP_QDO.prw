//-------------------------------------------------------------------
/*{Protheus.doc}  RUP_QDO( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
@author brunno.costa
@version P12
@since   15/12/2021
@param  cVersion   - Vers�o do Protheus
@param  cMode      - Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localiza��o (pa�s). Ex: BRA     
*/
//-------------------------------------------------------------------
Function Rup_QDO( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	//cVersion  - Execucao apenas na release 12
	//cRelStart - Execucao do ajuste apartir da 12.1.2210
	//cMode     - Execucao por grupo de empresas
	If cVersion >= "12"
		If cRelFinish >= "033" .And. cMode == "1"
			QDOAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
		EndIf
	EndIf
Return

/*{Protheus.doc} QDOAjuX3Ti
Renomeia o T�tulo do Campo QAA_TPWORD para 'Tipo Exibi��o'.
@author brunno.costa
@version P12
@since   15/12/2021
@param  cVersion   - Vers�o do Protheus
@param  cMode      - Modo de execu��o. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localiza��o (pa�s). Ex: BRA 
*/
Static Function QDOAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local aSaveArea	as Array

	aSaveArea := SX3->(GetArea())

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek('QAA_TPWORD'))
		RecLock("SX3", .F.)
			SX3->X3_TITULO := 'Tipo Exib.'
			SX3->X3_TITSPA := 'Tipo Visu.'
			SX3->X3_TITENG := 'Display Tp' 
		SX3->(MsUnlock())
	EndIf
       
	RestArea(aSaveArea)
Return
