#INCLUDE "PROTHEUS.CH"
Static aCacheSX3 := {}
Static nLenDICSX3 := 0

//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX312118
//Fun��o para verificar se o campo existe
@author felipe.m
@since 22/08/2017
@version 1.0
@param cAlias, characters, alias da tabela
@param cCampo, characters, campo da tabela
@param lVerUso, logical, verifica x3_uso do campo
@return return, l�gico .T. ou .F.
@example
If WmsX312118("D12","D12_IDUNIT",.F.)
[...]
EndIf
@see DLOGWMSMSP-1481
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX312118(cAlias,cCampo,lVerUso)
Local lRet := .F.
Local cAliasAtu := GetArea()
Default lVerUso := .T.

	// Quando a fun��o for chamada no MenuDef, os Alias ainda n�o existem.
	// Estamos colocando esta prote��o para evitar erro ao montar o menu na tela inicial do protheus
	If Select('SX3') > 0
		If lVerUso
			lRet := WmsX3Uso(cCampo)
		EndIf
	EndIf
	
	RestArea(cAliasAtu)

Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX312120
//Fun��o para verificar se o campo existe
@author SQUAD WMS Protheus
@since 24/01/2018
@version 1.0
@param cAlias, characters, alias da tabela
@param cCampo, characters, campo da tabela
@param lVerUso, logical, verifica x3_uso do campo
@return return, l�gico .T. ou .F.
@example
If WmsX312120("D12","D12_IDUNIT",.F.)
[...]
EndIf
@see DLOGWMSMSP-1886
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX312120(cAlias,cCampo,lVerUso)
Local lRet := .F.
Default lVerUso := .T.

	// Quando a fun��o for chamada no MenuDef, os Alias ainda n�o existem.
	// Estamos colocando esta prote��o para evitar erro ao montar o menu na tela inicial do protheus
	If Select('SX3') == 0
		Return .F.
	EndIf

	If lVerUso
		Return WmsX3Uso(cCampo)
	EndIf

	If (cAlias)->(FieldPos(cCampo)) > 0
		lRet := .T.
	EndIf
Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX312123
//Fun��o para verificar se o campo existe
@author SQUAD WMS Protheus
@since 16/08/2018
@version 1.0
@param cAlias, characters, alias da tabela
@param cCampo, characters, campo da tabela
@param lVerUso, logical, verifica x3_uso do campo
@return return, l�gico .T. ou .F.
@example
If WmsX312123("DCF","DCF_HORA",.F.)
[...]
EndIf
@see DLOGWMSMSP-4603
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX312123(cAlias,cCampo,lVerUso)
Local lRet := .F.
Default lVerUso := .T.

	// Quando a fun��o for chamada no MenuDef, os Alias ainda n�o existem.
	// Estamos colocando esta prote��o para evitar erro ao montar o menu na tela inicial do protheus
	If Select('SX3') == 0
		Return .F.
	EndIf

	If lVerUso
		Return WmsX3Uso(cCampo)
	EndIf

	If (cAlias)->(FieldPos(cCampo)) > 0
		lRet := .T.
	EndIf
Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX3Uso
// Fun��o para verificar se o campo existe no dicion�rio e � usado
@author felipe.m
@since 22/08/2017
@version 1.0
@param cCampo, characters, campo para verifica��o do x3_uso
@return return, l�gico .T. ou .F.
@example
If WmsX3Uso("D12_DOC")
[...]
EndIf
@see DLOGWMSMSP-1481
/*/
//---------------------------------------------------------------------------------------------------------
Static Function WmsX3Uso(cCampo)
Local nPos := 0

	If (nPos := aScan(aCacheSX3,{|x| x[1] == cCampo})) == 0
		aAdd(aCacheSX3,{cCampo,X3Usado(cCampo)})
		nLenDICSX3++
		Return aCacheSX3[nLenDICSX3,2]
	EndIf

Return aCacheSX3[nPos,2]
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX212118
//Fun��o para verificar se o alias existe
@author felipe.m
@since 22/08/2017
@version 1.0
@param cAlias, characters, alias da tabela
@return return, l�gico .T. ou .F.
@example
If WmsX212118("D0T")
[...]
EndIf
@see DLOGWMSMSP-1481
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX212118(cAlias)
	// Quando a fun��o for chamada no MenuDef, os Alias ainda n�o existem.
	// Estamos colocando esta prote��o para evitar erro ao montar o menu na tela inicial do protheus
	If Select("SX2") > 0
		SX2->(DbSetOrder(1))
	Else
		Return .F.
	EndIf
Return SX2->(MsSeek(cAlias))
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX212120
//Fun��o para verificar se o alias existe
@author SQUAD WMS Protheus
@since 24/01/2018
@version 1.0
@param cAlias, characters, alias da tabela
@return return, l�gico .T. ou .F.
@example
If WmsX212120("D0T")
[...]
EndIf
@see DLOGWMSMSP-1886
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX212120(cAlias)
	// Quando a fun��o for chamada no MenuDef, os Alias ainda n�o existem.
	// Estamos colocando esta prote��o para evitar erro ao montar o menu na tela inicial do protheus
	If Select("SX2") > 0
		SX2->(DbSetOrder(1))
	Else
		Return .F.
	EndIf
Return SX2->(MsSeek(cAlias))
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX212123
//Fun��o para verificar se o alias existe
@author SQUAD WMS Protheus
@since 13/01/2019
@version 1.0
@param cAlias, characters, alias da tabela
@return return, l�gico .T. ou .F.
@example
If WmsX212123("D0X")
[...]
EndIf
@see DLOGWMSMSP-6082
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX212123(cAlias)
	// Quando a fun��o for chamada no MenuDef, os Alias ainda n�o existem.
	// Estamos colocando esta prote��o para evitar erro ao montar o menu na tela inicial do protheus
	If Select("SX2") > 0
		SX2->(DbSetOrder(1))
	Else
		Return .F.
	EndIf
Return SX2->(MsSeek(cAlias))
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsXB12118
//Fun��o para verificar se a consulta padr�o existe
@author felipe.m
@since 22/08/2017
@version 1.0
@param cConsulta, characters, consulta padr�o
@return return, l�gico .T. ou .F.
@example
If WmsXB12118("D0T")
[...]
EndIf
@see DLOGWMSMSP-1481
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsXB12118(cConsulta)
Local lRet := .F.

	If SXB->(MsSeek(cConsulta))
		lRet := .T.
	EndIf
Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsXB12120
//Fun��o para verificar se a consulta padr�o existe
@author SQUAD WMS Protheus
@since 24/01/2018
@version 1.0
@param cConsulta, characters, consulta padr�o
@return return, l�gico .T. ou .F.
@example
If WmsXB12120("D0T")
[...]
EndIf
@see DLOGWMSMSP-1886
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsXB12120(cConsulta)
Local lRet := .F.

	If SXB->(MsSeek(cConsulta))
		lRet := .T.
	EndIf
Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX112118
//Fun��o para verificar se o pergunte e/ou a ordem existem
@author felipe.m
@since 22/08/2017
@version 1.0
@param cPergunte, characters, pergunte
@param cOrdem, characters, ordem do par�metro
@return return, l�gico .T. ou .F.
@example
If WmsX112118("WMSA225","09")
[...]
EndIf
@see DLOGWMSMSP-1481
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX112118(cPergunte,cOrdem)
Local lRet := .F.
Default cOrdem := ""

	SX1->(DbSetOrder(1))
	If SX1->(MsSeek(PadR(cPergunte,10)+cOrdem))
		lRet := .T.
	EndIf
Return lRet
//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsX112120
//Fun��o para verificar se o pergunte e/ou a ordem existem
@author SQUAD WMS Protheus
@since 24/01/2018
@version 1.0
@param cPergunte, characters, pergunte
@param cOrdem, characters, ordem do par�metro
@return return, l�gico .T. ou .F.
@example
If WmsX112120("WMSA225","09")
[...]
EndIf
@see DLOGWMSMSP-1886
/*/
//---------------------------------------------------------------------------------------------------------
Function WmsX112120(cPergunte,cOrdem)
Local lRet := .F.
Default cOrdem := ""

	SX1->(DbSetOrder(1))
	If SX1->(MsSeek(PadR(cPergunte,10)+cOrdem))
		lRet := .T.
	EndIf
Return lRet

