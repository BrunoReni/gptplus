#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_GPE
Funções de compatibilização e/ou conversão de dados para as tabelas do sistema
(Executa antes das atualizações de dicionário na migração de release)

@param cVersion - Versão do Protheus
@param cMode - Modo de execução - "1" = Por grupo de empresas / "2" = Por grupo de empresas + filial (filial completa)
@param cRelStart - Release de partida - (Este seria o Release no qual o cliente está)
@param cRelFinish - Release de chegada - (Este seria o Release ao final da atualização)
@param cLocaliz - Localização (país) - Ex. "BRA"

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
Avalia ajuste do grupo de campos 160 Código de Função (RH)
- Criado no release 12.1.2310
Como o campo referência RJ_FUNCAO permite que seu tamanho seja alterado, assim como outros que contém este código,
é preciso ver se no cliente houve alteração de tamanho, para pré-ajustar o grupo 160.
Caso contrário, é só deixar o UPDDISTR seguir com a atualização normalmente.

@author TOTVS - SIGAGPE
@since 14/03/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function UpdSXG160()
	Local aArea			:= GetArea()
	Local nTamCodFun	:= TamSX3('RJ_FUNCAO')[1]

	DbSelectArea('SXG')
	//- Efetua a busca do grupo e valida o tamanho do campo entre minimo e o máximo.
	//- Esse ponto é usado pelo fato de estar sendo criado o grupo a partir da versão 2310.
	If !SXG->( dbSeek('160') ) .AND. nTamCodFun > 5 .and. nTamCodFun < 10
		RecLock('SXG', .T.)
		SXG->XG_GRUPO   := '160'
		SXG->XG_DESCRI  := 'Código de Função (RH)'
		SXG->XG_DESSPA  := 'Código de función (RRHH)'
		SXG->XG_DESENG  := 'Role Code (HR)'
		SXG->XG_SIZEMAX := 9
		SXG->XG_SIZEMIN := 5
		SXG->XG_SIZE    := nTamCodFun
		SXG->XG_PICTURE	:= '@!'
		SXG->( MsUnlock() )
	EndIf

	RestArea(aArea)

Return .T.
