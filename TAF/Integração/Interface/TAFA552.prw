#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TAFA552.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC lLaySimplif := taflayEsoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552A
@type			function
@description	Programa de inicializa��o do Portal THF/Portinari do TAF ( eSocial )
@author			Flavio Lopes Rasta
@since			07/08/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552A()

If IsMatrizC1E( 2 )
	//Verifica se o ambiente est� com todas as configura��es para uso da fun��o FWCallApp
	If lCfgPainelTAF( "A" )
		If TAFAlsInDic( "V3J" ) .and. TAFAlsInDic( "V45" )
			FWMsgRun( , { || EraseData() }, STR0001, STR0002 ) //##"Aguarde" ##"Aplicando limpeza das tabelas de requisi��es"
		EndIf

		CallAppTAF()
	EndIf
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
@type			function
@description	Bloco de c�digo que receber� as chamadas JavaScript.
@author			Robson Santos
@since			20/09/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel, cType, cContent )

	Local aContent     as array
	Local aRotinas     as array
	Local cAlias       as character
	Local cChave       as character
	Local cContext     as character
	Local cEvento      as character
	Local cFonte       as character
	Local cIsTAFFull   as character
	Local cJsonCodUser as character
	Local cJsonCompany as character
	Local cJsonContext as character
	Local cJsonTAFFeat as character
	Local cJsonTAFFull as character
	Local cOperation   as character
	Local cTipo        as character
	Local cFilBkp	   as character
	Local nI           as numeric
	Local nIndex       as numeric
	Local nOk          as numeric
	Local lErrFil      as logical
	Local lChangeFil   as logical
	Local cTafTsi	   as character
	Local cJsonTafTsi  as character

	Private aSX9Rel    as array

	aContent     := {}
	aRotinas     := {}
	cAlias       := ""
	cChave       := ""
	cContext     := ""
	cEvento      := ""
	cFonte       := ""
	cIsTAFFull   := "true"
	cJsonCodUser := ""
	cJsonCompany := ""
	cJsonContext := ""
	cJsonTAFFeat := ""
	cJsonTAFFull := ""
	cOperation   := ""
	cTipo        := ""
	cFilBkp		 :=	""
	nI           := 0
	nIndex       := 0
	nOk          := 1
	lErrFil      := .F.
	lChangeFil   := .F.
	aSX9Rel 	 := {}
	cTafTsi		 := "noTsi"
	cJsonTafTsi	 := ""

	If FWIsInCallStack( "TAFA552A" )
		cContext := "esocial"
	ElseIf FWIsInCallStack( "TAFA552B" )
		cContext := "reinf"

		If TemRegSFT()
			cTafTsi := "tsi"
		EndIf	
	ElseIf FWIsInCallStack( "TAFA552C" )
		cContext := "gpe"
		cIsTAFFull := "false"
	ElseIf FWIsInCallStack( "TAFA552D" )
		cContext := "labor-process"
		cIsTAFFull := "false"
	ElseIf FWIsInCallStack("TAFA552E")
		cContext := "evolucao"

		If TemRegSFT()
			cTafTsi := "tsi"
		EndIf	
	EndIf

	Do Case

		Case cType == "preLoad"

			cJsonCompany := '{ "company_code" : "' + FWGrpCompany() + '", "branch_code" : "' + FWCodFil() + '" }'
			cJsonContext := '{ "context" : "' + cContext + '" }'
			cJsonTAFFull := '{ "tafFull" : "' + cIsTAFFull + '" }'
			cJsonCodUser := '{ "codUser" : "' + RetCodUsr() + '" }'
			cJsonTafTsi  := '{ "tafTsi" : "' + cTafTsi + '" }'
			cJsonTAFFeat := GetTAFFeatures()

			oWebChannel:AdvPLToJS( "setCompany", cJsonCompany )
			oWebChannel:AdvPLToJS( "setContext", cJsonContext )
			oWebChannel:AdvPLToJS( "setTafTsi", cJsonTafTsi )
			oWebChannel:AdvPLToJS( "setlIsTafFull", cJsonTAFFull )
			oWebChannel:AdvPLToJS( "setCodUser", cJsonCodUser )
			oWebChannel:AdvPLToJS( "setFeatures", cJsonTAFFeat )
	
		Case cType == "saveFileZip"

			//Chama fun��o para realizar a c�pia dos arquivos para esta��o
			TafSaveZip(oWebChannel, cContent)

		Case cType == "execView"

			aContent := StrTokArr( cContent, "|" )

			For nI := 1 to Len( aContent )
				If nI == 1
					cOperation := aContent[nI]
				ElseIf nI == 2
					cEvento  := aContent[nI]
					aRotinas := TAFRotinas( cEvento, 4, .F., 2 )
					cFonte   := aRotinas[1]
					cAlias   := aRotinas[3]
				ElseIf nI == 3
					If cFilAnt <> aContent[nI]
						lErrFil := VldTabTAF(cAlias, 1) != "C" .And. !(FWFilExist( cEmpAnt, aContent[nI] ))
						If !(lErrFil)
							cFilBkp    := cFilAnt
							cFilAnt    := aContent[nI]
							lChangeFil := .T.
						EndIf
					EndIf

					cChave += aContent[nI]
				Else
					If nI <> 4
						cChave += aContent[nI]
					EndIf
				EndIf
			Next nI

			If !lErrFil

				If Len(aRotinas) <> 0		

					If cEvento $ 'S-2410|S-2416|S-2418|S-2420'
						nIndex := 2
					Else
						nIndex  := TAFGetIdIndex( cAlias )
					EndIf

					If cOperation == "insert"

						If cEvento $ 'S-2500'
							DBSelectArea( cAlias )
							( cAlias )->( DBSetOrder( nIndex ) )
							TAF608Inc( cAlias, (cAlias)->(Recno()))
						Else
							nOk := FWExecView( STR0020, cFonte, MODEL_OPERATION_INSERT )
						EndIf

					ElseIf cOperation == "update"

						DBSelectArea( cAlias )
						( cAlias )->( DBSetOrder( nIndex ) )
						If ( cAlias )->( MsSeek( cChave ) )
							If cEvento = "S-2190" .And. !lLaySimplif
								nOk := TAFVAltEsocial(cAlias, cFonte)
							Else
								nOk := FWExecView( STR0021, cFonte, MODEL_OPERATION_UPDATE )
							EndIf
						EndIf

					ElseIf cOperation == "delete"

						DBSelectArea( cAlias )
						( cAlias )->( DBSetOrder( nIndex ) )
						If ( cAlias )->( MsSeek( cChave ) )
							If (Empty(&(( cAlias )->(cAlias + "_PROTUL"))) .And. &(( cAlias )->(cAlias + "_STATUS")) <> "4" .And. cEvento <> 'S-3000') .Or. cEvento $ "S-1000|S-1005|S-1010|S-1020|S-1030|S-1035|S-1040|S-1050|S-1060|S-1070|S-1080|S-1298|S-1299" 
								nOk := FWExecView( STR0022, cFonte, MODEL_OPERATION_DELETE, ,{|| .T. },{|| TafDisableSX9( cAlias ) })
								TafEnableSX9( cAlias )
							Else
								nOk := xTafVExc(cAlias, (cAlias)->(Recno()), 1)
							EndIf
						EndIf						

					ElseIf cOperation == "view"

						DBSelectArea( cAlias )
						( cAlias )->( DBSetOrder( nIndex ) )
						If ( cAlias )->( MsSeek( cChave ) )
							nOk := FWExecView( STR0023, cFonte, MODEL_OPERATION_VIEW )
						EndIf
						
					EndIf

				EndIf

				If lChangeFil .And. cFilAnt <> cFilBkp
					cFilAnt := cFilBkp
				EndIf
			EndIf

			If nOk == 0 .Or. nOk == Nil
				oWebChannel:advplToJs( "setFinishExecView", "true" )
			Else
				oWebChannel:advplToJs( "setFinishExecView", "false" )
			EndIf

	EndCase

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTAFFeatures
@type			function
@description	Fun��o respons�vel por verificar todas as features que necessitam de atualiza��o de
@description	bin�rio, lib, etc e retorna um json informando se a feature encontra-se dispon�vel ou n�o.
@author			Diego Santos
@since			14/07/2020
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function GetTAFFeatures()

	Local cBuildSmart	as character
	Local cBuildAppSrv	as character
	Local cLibVersion	as character
	Local cRet			as character
	Local nX			as numeric
	Local aFeatures		as array

	cBuildSmart		:=	GetBuild( .T. )
	cBuildAppSrv	:=	GetBuild( .F. )
	cLibVersion		:=	FWLibVersion()
	cRet			:=	""
	nX				:=	0
	aFeatures		:=	{}
	
	//Feature downloadXLS
	If cBuildSmart >= "7.00.191205P-20200504" .and. cBuildAppSrv >= "7.00.191205P-20200629" .and. cLibVersion >= "20200615" .and. FindFunction( "FWDLEXLIST" )
		aAdd( aFeatures, { "downloadXLS", .T., Encode64( "Dispon�vel." ) } )
	Else
		aAdd( aFeatures, { "downloadXLS", .F., Encode64( "Funcionalidade dispon�vel a partir do bin�rio AppServer: 7.00.191205P-20200629, SmartClient: 7.00.191205P-20200504, Lib superior � 15/06/2020 e pacote acumulado do TAF igual ou superior � 09/2020." ) } )
	EndIf
	
	If ExistStamp(,,"SFT") .and. TafColumnPos("C20_STAMP")
		aAdd( aFeatures, { "tsiStamp", .T., Encode64( STR0030 ) } ) //"Dispon�vel."
	Else
		aAdd( aFeatures, { "tsiStamp", .F., Encode64( STR0031 ) } ) //"Foi identificado que o TSI ainda n�o est� configurado em seu ambiente. Certifique-se de que seu ambiente est� atualizado e se os campos STAMPs foram criados ap�s a execu��o da rotina da wizard de configura��o TAF."
	EndIf	
	//Exemplo de json esperado
	//'{
	//	"feature1" : { "access" : true, "message" : "Teste1" },
	//	"feature2" : { "access" : false, "message" : "Teste2" },
	//	"feature3" : { "access" : false, "message" : "Teste3" }
	//}'

	cRet += "{ "

	For nX := 1 to Len( aFeatures )
		cRet += '"' + aFeatures[nX,1] + '" : { "access" : ' + Iif( aFeatures[nX,2], "true", "false" ) + ', "message" : "' + aFeatures[nX,3] + '" }'

		If Len( aFeatures ) > 1 .and. nX <> Len( aFeatures )
			cRet += ", "
		EndIf
	Next nX

	cRet += " }"
	
Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} EraseData
@type			function
@description	Exclui os dados vol�teis dos relat�rios.
@author			Robson Santos
@since			20/09/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function EraseData()

	Local cQuery	as character
	Local cDate		as character

	cQuery	:=	""
	cDate	:=	DToS( dDataBase )

	cQuery := "DELETE FROM " + RetSqlName( "V45" ) + " "
	cQuery += "WHERE V45_ID IN ( SELECT V3J_ID FROM " + RetSqlName( "V3J" ) + " WHERE V3J_DTREQ < '" + cDate + "' )

	TCSQLExec( cQuery )

	cQuery := "DELETE FROM " + RetSqlName( "V3J" ) + " "
	cQuery += "WHERE V3J_DTREQ < '" + cDate + "' "

	TCSQLExec( cQuery )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552B
@type			function
@description	Programa de inicializa��o do Portal THF/Portinari do TAF ( Reinf ).
@author			Robson Santos
@since			26/11/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552B()

	If IsMatrizC1E( 1 )
		//Verifica se o ambiente est� com todas as configura��es para uso da fun��o FWCallApp
		If lCfgPainelTAF( "B" )
			CallAppTAF()
		EndIf
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552C
@type			function
@description	Programa de inicializa��o do Portal THF/Portinari do TAF ( GPE ).
@author			Robson Santos
@since			26/11/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552C()

//Verifica se o ambiente est� com todas as configura��es para uso da fun��o FWCallApp
If lCfgPainelTAF( "C" )
	CallAppTAF()
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552D
@type			function
@description	Programa de inicializa��o do Portal PO UI do TAF ( GPE - Processos Trabalhistas ).
@author			Felipe C. Seolin
@since			28/12/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552D()

//Verifica se o ambiente est� com todas as configura��es para uso da fun��o FWCallApp
If lCfgPainelTAF( "D" )
	CallAppTAF()
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} IsMatrizC1E
@type			function
@description	Verifica se a Filial logada � a Filial Matriz para executar as apura��es.
@param			nAmbiente	-	1 para Reinf e 2 para eSocial
@return			lRet		-	Retorna se a Filial logada est� cadastrada como Matriz
@author			Karen Honda
@since			10/02/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Function IsMatrizC1E( nAmbiente as numeric ) as logical

	Local cCNPJFil   as character
	Local nOpcAviso  as numeric
	Local lMatriz    as logical
	Local lReinfAtu  as logical
	Local lTransFil  as logical
	Local lNoVldEst  as logical
	Local lOkC8E     as logical
	Local lRet       as logical
	Local lWsLoadFil as logical
	Local cCodFil    as character

	Default nAmbiente	:=	1

	cCNPJFil	:=	""
	lMatriz		:=	.F.
	lReinfAtu	:=	.F.
	lRet		:=	.F.
	lWsLoadFil	:=  IsInCallStack("wsLoadFil")

	If !( FindFunction( "PROTDATA" ) .and. ProtData() .or. !FindFunction( "PROTDATA" ) )
		Return( .F. )
	EndIf

	DBSelectArea( "C1E" )
	C1E->( DBSetOrder( 3 ) )
	cCodFil := IIF(lWsLoadFil .AND. nAmbiente == 1 , AllTrim(cFilAnt), AllTrim( SM0->M0_CODFIL))
	
	If C1E->( DBSeek( xFilial( "C1E" ) + PadR( cCodFil, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		If C1E->C1E_MATRIZ == .T.
			lMatriz := .T.
		EndIf

		cCNPJFil := AllTrim( Posicione( "SM0", 1, cEmpAnt + C1E->C1E_FILTAF, "M0_CGC" ) )
	EndIf

	If !lWsLoadFil
		If nAmbiente == 1 //Ambiente Reinf
			If lMatriz
				lReinfAtu := TAFColumnPos( "V0W_CNOEST" ) .and. !X3Obrigat( "V0B_PGTOS" )
			EndIf

			If lMatriz .and. Len( cCNPJFil ) >= 11 .and. lReinfAtu
				lRet := .T.
			Else
				lRet := .F.

				If !lMatriz
					Aviso( STR0005, STR0006, { STR0007 }, 2 ) //##"Rotina indispon�vel" ##"Esta funcionalidade est� dispon�vel apenas para a filial marcada como matriz no complemento cadastral." ##"Sair"
				ElseIf Len( cCNPJFil ) < 11
					Aviso( STR0005, STR0008, { STR0007 }, 2 ) //##"Rotina indispon�vel" ##"O c�digo de inscri��o ( CNPJ ) da matriz n�o est� preenchido no cadastro de empresas." ##"Sair"
				ElseIf !lReinfAtu
					nOpcAviso := Aviso( STR0009, STR0010 + CRLF + CRLF +; //##"Ambiente desatualizado!" ##"O ambiente do TAF encontra-se desatualizado com rela��o as altera��es referentes ao layout 1.04.00 da EFD Reinf."
										STR0011 + CRLF + CRLF +; //"As rotinas dispon�veis no reposit�rio de dados ( RPO ) est�o mais atualizadas do que o dicion�rio de dados."
										STR0012 + CRLF + CRLF +; //"Para atualiza��o dessa funcionalidade, ser� necess�rio atualizar o dicion�rio de dados, utilizando o �ltimo arquivo diferencial disponibilizado no portal da TOTVS, utilizando a ferramenta UPDDISTR e, em seguida, executar o compatibilizador de dicion�rio de dados UPDTAF."
										STR0013 + CRLF +; //"**IMPORTANTE**"
										STR0014, { STR0007, STR0015 }, 3 ) //##"No caso do arquivo diferencial referente ao layout 1.4 da EFD Reinf j� ter sido executado, siga as instru��es do FAQ." ##"Sair" ##"FAQ"

					If nOpcAviso == 2 //FAQ
						ShellExecute( "Open", "http://tdn.totvs.com/x/y4DlGg", "", "", 1 )
					EndIf
				EndIf
			EndIf
		Else //Ambiente eSocial
			lTransFil := SuperGetMv( "MV_TAFTFIL", .F., .F. ) //Permite que seja realizado a transmiss�o pela Filial
			lNoVldEst := SuperGetMv( "MV_TAFVLUF", .F., .F. ) //Permite que seja realizado a integra��o de c�digos de munic�pios incompat�veis com a UF
			lOkC8E := .T.

			DBSelectArea( "C8E" )
			C8E->( DBSetOrder( 2 ) )
			C8E->( DBGoTop() )
			If C8E->( Eof() )
				lOkC8E := .F.
			EndIf

			If ( lMatriz .or. lTransFil ) .and. TAFAlsInDic( "T0X" ) .and. TAFColumnPos( "T0X_USER" ) .and. lOkC8E .and. !lNoVldEst
				lRet := .T.
			Else
				lRet := .F.

				If !lMatriz .and. !lTransFil
					Aviso( STR0005, STR0006, { STR0007 }, 2 ) //##"Rotina indispon�vel" ##"Esta funcionalidade est� dispon�vel apenas para a filial marcada como matriz no complemento cadastral." ##"Sair"
				ElseIf !lOkC8E
					Aviso( STR0005, STR0017, { STR0007 }, 2 ) //##"Rotina indispon�vel" ##"Autocontidas desatualizadas. � necess�rio executar a Wizard de Configura��o do TAF e a atualiza��o das tabelas autocontidas para o correto funcionamento da aplica��o." ##"Sair"
				ElseIf lNoVldEst
					Aviso( STR0005, STR0018, { STR0007 }, 2 ) //##"Rotina indispon�vel" ##"N�o � permitido realizar a transmiss�o de eventos com o par�metro MV_TAFVLUF habilitado. Este par�metro desabilita a valida��o do c�digo de munic�pio e pode gerar inconsist�ncias nos envios de eventos relativos ao trabalhador, o mesmo deve ser utilizado somente para a carga de arquivos XMLs na rotina de migra��o." ##"Sair"
				Else
					Aviso( STR0005, STR0019, { STR0007 }, 2 ) //##"Rotina indispon�vel" ##"Dicion�rio de dados desatualizado, � necess�rio que as atualiza��es de dicion�rio do layout 2.04.01 estejam aplicadas para o correto funcionamento da aplica��o." ##"Sair"
				EndIf
			EndIf
		EndIf
	EndIf

Return( lRet )


//---------------------------------------------------------------------
/*/{Protheus.doc} lCfgPainelTAF
@type			function
@description	Verifica se o ambiente est� com todos as config para uso da fun��o FWCallApp e apresenta msg caso n�o estiver configurado
@param			cRotina   	-	"A" - TAFA552A, "B" - TAFA552B, "C" - TAFA552C, "E" - TAFA552E - Utilizar para futuras valida��es
@return			lRet		-	Retorna se ambiente est� corretamente configurado
@author			Renan Gomes
@since			07/06/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function lCfgPainelTAF(cRotina,cBuild)

	Local lMPP		as logical
	Local lREST		as logical
	Local lHTTP		as logical
	Local lConfig	as logical
	Local lRet	    as logical
	Local lAutomato as logical

	lMPP	  := .F.
	lREST	  := .F.
	lHTTP	  := .F.
	lConfig	  := .F.
	lRet      := .F.
	lAutomato := IsBlind()

	Default cRotina := ""
	Default cBuild  := GetBuild()

	If cBuild >= "7.00.170117A-20190628" .and. FWLibVersion() >= "20200325"
		lMPP	:= Iif( FindFunction( "AmIOnRestEnv" ), AmIOnRestEnv(), .F. )
		lREST	:= !Empty( GetNewPar( "MV_BACKEND", "" ) )
		lHTTP	:= !Empty( GetNewPar( "MV_GCTPURL", "" ) )
		lConfig	:= TAFVldRP( .F. )

		If lMPP .or. ( lREST .and. lHTTP .and. lConfig )
			lRet := .T.
		Else
			If FWIsAdmin( __cUserID ) .and. !lAutomato .and. !IsInCallStack('ExtFisxTaf') //Se usu�rio for ADM ou tiver no grupo de adm e n�o tiver o ExtFisxTaf na pilha de chamada, mostro tela de configura��es
				If TAFFUTPAR()
					lRet := .T.
				EndIf
			Else
				MsgAlert( STR0003 ) //"As configura��es para o funcionamento dos Paineis em POUI n�o foram realizadas. Contate o administrador do sistema."
			EndIf
		EndIf
	Else
		MsgAlert( STR0004 ) //"Para utilizar as funcionalidades dos Paineis em POUI voc� deve atualizar o seu sistema para uma build 64 bits."
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSaveZip
@type			function
@description	Chama cGetFile para selecionar onde ir�o ser copiados os arquivos zip
@param			oWebChannel    - Clase WebChannel
@param			cContent       - Json em formato de string com os arquivos que dever�o ser copiados

@return			lRet		-	Retorna se conseguiu copiar
@author			Renan Gomes
@since			22/06/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function TafSaveZip(oWebChannel, cContent)
	Local cCaminho  := ""
	Local lRet 		:= .F.
	Local lWebApp	:= GetRemoteType() == 5
	Local lJob		:= isBlind()

	//Se for WEBAPP, mando o diret�rio como "\" e as fun��es de c�pia salvam no users\downloads
	If lJob .or. lWebApp
		cCaminho := "\"
	else	
		cCaminho := cGetFile( "",STR0024, 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY + GETF_NETWORKDRIVE, .F. )
	Endif

	if(!Empty(cCaminho))
		oJson := JsonObject():New()
		lRet := ValType(oJson:FromJson(cContent)) <> "C"
		if !lRet
			oWebChannel:AdvplToJs("retSaveFileZip", STR0025)
		else
			lRet := TafCpyZip(oJson,cCaminho)
			if lRet
				if lWebApp
					oWebChannel:advplToJs( "retSaveFileZip", STR0026)
				else
					oWebChannel:advplToJs( "retSaveFileZip", STR0027 +cCaminho)
				Endif
			Else
				oWebChannel:advplToJs( "retSaveFileZip", STR0028 )
			Endif
		Endif
	else
		oWebChannel:advplToJs( "retSaveFileZip", STR0029 )
	Endif	
Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TafCpyZip
@type			function
@description	Copia arquivos do protheus_data para m�quina local do usu�rio
@param			oJson    - JSON com os caminhos zipados
@param			cCaminho - Caminho local onde dever� ser salvado os arquivos 
@return			lRet		-	Retorna se conseguiu copiar
@author			Renan Gomes
@since			22/06/2022
@version		1.0
/*/
//---------------------------------------------------------------------
Function TafCpyZip(oJson,cCaminho)
	Local nFile 	:= 0
	Local lRetCopy  := .t.
	
	//Copio arquivos para m�quina locaL e deleto arquivo
	for nFile := 1 to len(oJson['aFiles'])
		//Se der algum erro para de copiar os arquivos,mas deleto arquivo da protheus_Data
		If lRetCopy
			lRetCopy := CpyS2T(oJson['aFiles'][nFile],cCaminho)
		Endif
		FErase(oJson['aFiles'][nFile])
	next

Return lRetCopy

//---------------------------------------------------------------------
/*/{Protheus.doc} CallAppTAF
@type			function
@description	Programa de inicializa��o do Portal PO UI do TAF de acordo
@description	com Release, por conta da garantia estendida da Release 12.1.27.
@author			Felipe C. Seolin
@since			09/02/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function CallAppTAF()

If GetRPORelease() <= "12.1.027"
	FWCallApp( "TAFA612" )
Else
	FWCallApp( "TAFA552" )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA552E
@type			function
@description	Programa de inicializa��o do Portal PO UI do TAF (Evolu��o)
@author			Melkz Siqueira
@since			15/02/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA552E()

	If IsMatrizC1E(1)
		If lCfgPainelTAF("E")
			CallAppTAF()
		EndIf
	EndIf

Return
