#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_GPE
Fun��es de compatibiliza��o e/ou convers�o de dados para as tabelas do sistema
(Executa antes das atualiza��es de dicion�rio na migra��o de release)

@param cVersion - Vers�o do Protheus
@param cMode - Modo de execu��o - "1" = Por grupo de empresas / "2" = Por grupo de empresas + filial (filial completa)
@param cRelStart - Release de partida - (Este seria o Release no qual o cliente est�)
@param cRelFinish - Release de chegada - (Este seria o Release ao final da atualiza��o)
@param cLocaliz - Localiza��o (pa�s) - Ex. "BRA"

@return lRet

@author TOTVS - SIGAGPE
@since 14/03/2023
@version P12
/*/
//-------------------------------------------------------------------
Function RBE_GPE( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local lRet			:= .T.

	Default cVersion	:= ''
	Default cMode		:= ''
	Default cRelStart	:= ''
	Default cRelFinish	:= ''
	Default cLocaliz	:= ''

	If cMode == "1"  // Nivel do grupo de empresas

		If cRelStart < '2310' .And. cRelFinish >= '2310'
			lRet := UpdSXG160()
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdSXG160
Avalia ajuste do grupo de campos 160 C�digo de Fun��o (RH)
- Criado no release 12.1.2310
Como o campo refer�ncia RJ_FUNCAO permite que seu tamanho seja alterado, assim como outros que cont�m este c�digo,
� preciso ver se no cliente houve altera��o de tamanho, para pr�-ajustar o grupo 160.
Caso contr�rio, � s� deixar o UPDDISTR seguir com a atualiza��o normalmente.

@author TOTVS - SIGAGPE
@since 14/03/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function UpdSXG160()
	Local aArea			:= GetArea()
	Local nTamCodFun	:= TamSX3('RJ_FUNCAO')[1]

	DbSelectArea('SXG')
	//- Efetua a busca do grupo e valida o tamanho do campo entre minimo e o m�ximo.
	//- Esse ponto � usado pelo fato de estar sendo criado o grupo a partir da vers�o 2310.
	If !SXG->( dbSeek('160') ) .AND. nTamCodFun > 5 .and. nTamCodFun < 10
		RecLock('SXG', .T.)
		SXG->XG_GRUPO   := '160'
		SXG->XG_DESCRI  := 'C�digo de Fun��o (RH)'
		SXG->XG_DESSPA  := 'C�digo de funci�n (RRHH)'
		SXG->XG_DESENG  := 'Role Code (HR)'
		SXG->XG_SIZEMAX := 9
		SXG->XG_SIZEMIN := 5
		SXG->XG_SIZE    := nTamCodFun
		SXG->XG_PICTURE	:= '@!'
		SXG->( MsUnlock() )
	EndIf

	RestArea(aArea)

Return .T.
