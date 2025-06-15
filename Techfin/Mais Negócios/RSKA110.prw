#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FwSchedule.ch"
#INCLUDE "RSKA110.ch"
#INCLUDE "RSKDefs.ch"

#DEFINE  CLIENT          	1
#DEFINE  PROVIDER        	2
#DEFINE  BANK            	3
#DEFINE  BILLING         	4
#DEFINE  OFFBALANCE      	5
#DEFINE  SCHEDULE      	    6

#DEFINE  SIZE_ENTITY     10
#DEFINE  SIZE_OFFBALANCE 11
#DEFINE  SIZE_SCHEDULE   3

// posi��es do array OFFBALANCE
#DEFINE CAROL_URL               1
#DEFINE PLATFORM_URL_RISK       2
#DEFINE CAROL_CONNID            3
#DEFINE CAROL_TOKEN             4
#DEFINE RAC_URL                 5
#DEFINE TENANT                  6
#DEFINE RISK_TYPE_DESC          7
#DEFINE RISK_TYPE               8
#DEFINE RISK_CLIENT_ID          9
#DEFINE RISK_CLIENT_SECRET      10
#DEFINE PLATFORM_URL_FMSCASH    11

// posi��es do array de entidades 
#DEFINE ENT_BRANCH      1 // filial (Ex: A1_FILIAL)
#DEFINE ENT_CODE        2 // c�digo de busca (Ex: A1_COD)
#DEFINE ENT_STORE       3 // c�digo adicional de busca (Ex: A1_LOJA)
#DEFINE ENT_DESC        4 // descri��o do registro (Ex: A1_NOME)
#DEFINE ENT_AUX_DESC    5 // descri��o auxiliar
#DEFINE ENT_PARAMETER   6 // nome do par�metro
#DEFINE ENT_ALIAS       7 // tabela da entidade
#DEFINE ENT_IDENT       8 // identificador
#DEFINE ENT_CONTENT     9 // conte�do do par�metro
#DEFINE ENT_MODEL       10 // vetor com o registro modelo

// posi��es do array de schedules
#DEFINE MVRSKPLS1        1
#DEFINE MVRSKPLS2        2
#DEFINE MVRSKPLS3        3
#DEFINE OPCOES_SCHEDULE  1
#DEFINE ESCOLHA_SCHEDULE 2

Static __lRegistry   := FindFunction( "FINA138B" )
Static __oTFRegistry := Nil
//-------------------------------------------------------------------------------------
/*/
	{Protheus.doc} RSKA110
	Fun��o de montagem dos componentes de cadastro
	@type Function
	@author Lucas Silva Vieira
	@since 27/04/2023
/*/
//-------------------------------------------------------------------------------------
Function RSKA110() As Logical

Local aWizParam As Array
Local lValid    As Logical

aWizParam := Array( 6 ) //posi��es dos agrupadores
lValid    := .T.

If RskVldDic()
	If __lRegistry .And. __oTFRegistry == Nil
		__oTFRegistry := FINA138BTFRegistry():New()
	EndIf

	aWizParam[ CLIENT ]     := Array( SIZE_ENTITY )
	aWizParam[ PROVIDER ]   := Array( SIZE_ENTITY )
	aWizParam[ BANK ]       := Array( SIZE_ENTITY )
	aWizParam[ BILLING ]    := Array( SIZE_ENTITY )
	aWizParam[ OFFBALANCE ] := Array( SIZE_OFFBALANCE )
	aWizParam[ SCHEDULE ]   := Array( SIZE_SCHEDULE )

	LoadPlatInfo( aWizParam[ OFFBALANCE ] )
	aWizParam[ CLIENT ]   := LoadParamInfo( CLIENT )
	aWizParam[ PROVIDER ] := LoadParamInfo( PROVIDER )
	aWizParam[ BANK ]     := LoadParamInfo( BANK )
	aWizParam[ BILLING ]  := LoadParamInfo( BILLING )
	
	aWizParam[ SCHEDULE ]                   := Array(2)
	aWizParam[ SCHEDULE ][ESCOLHA_SCHEDULE] := ''
	aWizParam[ SCHEDULE ][OPCOES_SCHEDULE]  := LoadParamInfo( SCHEDULE, .F. )
	
	lValid := MakeStep1( aWizParam )
Else
	ApMsgAlert( I18N( STR0002, { SM0->M0_CODIGO } ), STR0001 ) //"Uma ou mais fun��es n�o foram encontradas para execu��o do Wizard. Verifique se o ambiente possui a expedi��o cont�nua do m�dulo Financeiro com o pacote de programas (LIB) mais recente." # "Wizard Mais Neg�cios"
	lValid := .F.
EndIf

FWFreeArray( aWizParam )

Return lValid

//-------------------------------------------------------------------------------------
/*/
	{Protheus.doc} MakeStep1
	Fun��o de montagem dos componentes de cadastro
	@type  Static Function
	@author Lucas Silva Vieira
	@since 27/04/2023
/*/
//-------------------------------------------------------------------------------------
Static Function MakeStep1( aWizParam As Array ) As Logical
	Local oClient    As Object    
	Local oStore     As Object   
	Local oName      As Object  
	Local oPanel     As Object
	Local oBtnClient As Object 
	Local oAntecipa  As Object
	Local oCbxSched  As Object
	Local lExistSA1  As Logical
	Local lExistSA2  As Logical
	Local lExistSA6  As Logical
	Local lValid	 As Logical

	lExistSA1 := .F.
	lExistSA2 := .F.
	lExistSA6 := .F.
	lValid	  := .F.	
	oAntecipa := Nil

	lExistSA1 := CheckParam( CLIENT, aWizParam[ CLIENT ] )
	lExistSA2 := CheckParam( PROVIDER, aWizParam[ PROVIDER ] )
	lExistSA6 := CheckParam( BANK, aWizParam[ BANK ] )

	DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10

	DEFINE MSDIALOG oPanel TITLE STR0003 + FwGrpCompany() STYLE DS_MODALFRAME FROM 230,180 TO 780,900 PIXEL 
    oPanel:lEscClose := .F.

	@ 01, 10 SAY STR0004 OF oPanel PIXEL FONT oCHFont   //"Defina os dados que ser�o utilizados para a integra��o com a Supplier"

	@ 11, 10 GROUP TO 50, 353 PROMPT STR0005 OF oPanel PIXEL    //'Dados do cliente'

	@ 21, 15 SAY STR0006 OF oPanel PIXEL FONT oCHFont   //"C�digo:"
	@ 31, 15 MSGET oClient VAR aWizParam[ CLIENT ][ ENT_CODE ]  SIZE 70, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA1

	@ 21, 90 SAY STR0007 OF oPanel PIXEL FONT oCHFont   //"Loja:"
	@ 31, 90 MSGET oStore VAR aWizParam[ CLIENT ][ ENT_STORE ]  SIZE 30, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA1

	@ 21, 125 SAY STR0008 OF oPanel PIXEL FONT oCHFont  //"Nome:"
	@ 31, 125 MSGET oName VAR aWizParam[ CLIENT ][ ENT_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN .F.

	@ 31, 277 BUTTON oBtnClient PROMPT STR0009 SIZE 30, 11 OF oPanel PIXEL WHEN !lExistSA1 ACTION ( SetActionMn( CLIENT, aWizParam[ CLIENT ], lExistSA1, .T. ) )    //"Pesquisar"
	@ 31, 310 BUTTON oBtnClient PROMPT STR0010 SIZE 30, 11 OF oPanel PIXEL WHEN !lExistSA1 ACTION ( SetActionMn( CLIENT, aWizParam[ CLIENT ], lExistSA1, .F. ) )    //"Incluir"

	@ 53, 10 GROUP TO 92, 353 PROMPT STR0011 OF oPanel PIXEL    //'Dados do fornecedor'

	@ 63, 15 SAY STR0006 OF oPanel PIXEL FONT oCHFont   //"C�digo:"
	@ 73, 15 MSGET oClient VAR aWizParam[ PROVIDER ][ ENT_CODE ]  SIZE 70, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA2

	@ 63, 90 SAY STR0007 OF oPanel PIXEL FONT oCHFont   //"Loja:"
	@ 73, 90 MSGET oStore VAR aWizParam[ PROVIDER ][ ENT_STORE ]  SIZE 30,10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA2

	@ 63, 125 SAY STR0008 OF oPanel PIXEL FONT oCHFont  //"Nome:"
	@ 73, 125 MSGET oName VAR aWizParam[ PROVIDER ][ ENT_DESC ]  SIZE 150,10 OF oPanel Font oCMFont PIXEL WHEN .F.

	@ 73, 277 BUTTON oBtnProvider PROMPT STR0009 SIZE 30, 11 OF oPanel PIXEL WHEN !lExistSA2 ACTION ( SetActionMn( PROVIDER, aWizParam[ PROVIDER ], lExistSA2, .T. ) )    //"Pesquisar"
	@ 73, 310 BUTTON oBtnProvider PROMPT STR0010 SIZE 30, 11 OF oPanel PIXEL WHEN !lExistSA2 ACTION ( SetActionMn( PROVIDER, aWizParam[ PROVIDER ], lExistSA2, .F. ) )    //"Incluir"

	@ 95, 10 GROUP TO 159, 353 PROMPT STR0012 OF oPanel PIXEL  //'Dados do Banco'

	@ 105, 15 SAY STR0006 OF oPanel PIXEL FONT oCHFont  //"C�digo:"
	@ 115, 15 MSGET oClient VAR aWizParam[ BANK ][ ENT_CODE ]  SIZE 40, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

	@ 105, 60 SAY STR0013 OF oPanel PIXEL FONT oCHFont  //"Ag�ncia:"
	@ 115, 60 MSGET oStore VAR aWizParam[ BANK ][ ENT_STORE ]  SIZE 60, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

	@ 105, 125 SAY STR0014 OF oPanel PIXEL FONT oCHFont //"Conta:"
	@ 115, 125 MSGET oName VAR aWizParam[ BANK ][ ENT_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

	@ 115, 277 BUTTON oBtnProvider PROMPT STR0009 SIZE 30, 11 OF oPanel PIXEL WHEN !lExistSA6 ACTION ( SetActionMn( BANK, aWizParam[ BANK ], lExistSA6, .T. ) ) //"Pesquisar"
	@ 115, 310 BUTTON oBtnProvider PROMPT STR0010 SIZE 30, 11 OF oPanel PIXEL WHEN !lExistSA6 ACTION ( SetActionMn( BANK, aWizParam[ BANK ], lExistSA6, .F. ) ) //"Incluir"

	@ 130, 15 SAY STR0015 OF oPanel PIXEL FONT oCHFont  //"Nome do banco:"
	@ 140, 15 MSGET oName VAR aWizParam[ BANK ][ ENT_AUX_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN .F.

	@ 162, 10 GROUP TO 201, 353 PROMPT STR0016 OF oPanel PIXEL    //'Carteira Devolu��o - P�s Faturamento'

	@ 172, 15 SAY STR0006 SIZE 200, 20 OF oPanel PIXEL FONT oCHFont //"C�digo"
	@ 182, 15 MSGET oCodSitCob VAR aWizParam[ BILLING ][ ENT_CODE ] SIZE 30, 9 OF oPanel PIXEL PICTURE "@!" WHEN .F. VALID RSKVlAlfaNum(aWizParam[ BILLING ][ ENT_CODE ] )

	@ 172, 54 SAY STR0017  SIZE 250, 20 OF oPanel PIXEL FONT oCHFont //"Descri��o"
	@ 182, 54 MSGET oDescSitCob VAR aWizParam[ BILLING ][ ENT_STORE ] SIZE 200, 9 OF oPanel PIXEL PICTURE "@!" WHEN .F.

	@ 204, 10 GROUP TO 248, 353 PROMPT STR0058 OF oPanel PIXEL    //'Configura��o do Schedule'

	@ 214, 15 SAY STR0059 SIZE 200, 20 OF oPanel PIXEL FONT oCHFont //"Escolha a op��o desejada:"
	@ 224, 15 MSCOMBOBOX oCbxSched VAR aWizParam[ SCHEDULE ][ ESCOLHA_SCHEDULE ] ITEMS aWizParam[ SCHEDULE ][ OPCOES_SCHEDULE ] SIZE 95,35 OF oPanel PIXEL WHEN .T.
	
	@ 255,313 BUTTON STR0018 SIZE 040, 015 PIXEL OF oPanel ACTION ( FWMsgRun( ,{ || lValid := VldStep1( aWizParam, @oAntecipa ) }, Nil, STR0019 ), oPanel:End() ) // "Finalizar" # "Ativando a integra��o"
	ACTIVATE DIALOG oPanel CENTERED

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldStep1
	Fun��o de valida��o - Dados de integra��o com a Supplier
	@type  Static Function
	@author Lucas Silva Vieira
	@since 27/04/2023
	@return Logical
/*/
//-------------------------------------------------------------------------------------
Static Function VldStep1( aWizParam as Array, oAntecipa As Object ) as Logical
	Local lValid As Logical
	Local cMsg 	 As Character

	lValid := .T.
	cMsg   := ''

	If Empty( aWizParam[ CLIENT ][ ENT_CODE ] ) .Or. Empty( aWizParam[ CLIENT ][ ENT_STORE ] ) .Or. Empty( aWizParam[ CLIENT ][ ENT_DESC ] )
		lValid := .F.
		cMsg := STR0020     //"Informe os dados do cliente para a integra��o com a Supplier."
	else
		lValid := CheckParam( CLIENT, aWizParam[ CLIENT ] )

		IF !lValid
			cMsg := STR0021     //"Preencha os dados complementares para a inclus�o do cliente pelo bot�o 'Informar dados'."
		EndIf
	Endif

	If lValid
		If Empty( aWizParam[ PROVIDER ][ ENT_CODE ] ) .Or. Empty( aWizParam[ PROVIDER ][ ENT_STORE ] ) .Or. Empty( aWizParam[ PROVIDER ][ ENT_DESC ] )
			lValid := .F.
			cMsg := STR0022     //"Informe os dados do fornecedor para a integra��o com a Supplier."
		else
			lValid := CheckParam( PROVIDER, aWizParam[ PROVIDER ] )

			IF !lValid
				cMsg := STR0023     //"Preencha os dados complementares para a inclus�o do fornecedor pelo bot�o 'Informar dados'."
			EndIf
		Endif
	EndIf

	If lValid
		If Empty( aWizParam[ BANK ][ ENT_CODE ] ) .Or. Empty( aWizParam[ BANK ][ ENT_STORE ] ) .Or. Empty( aWizParam[ BANK ][ ENT_DESC] )
			lValid := .F.
			cMsg := STR0024     //"Informe os dados do banco para a integra��o com a Supplier."
		else
			lValid := CheckParam( BANK, aWizParam[ BANK ])

			IF !lValid
				cMsg := STR0025     //"Preencha os dados complementares para a inclus�o do banco pelo bot�o 'Informar dados'."
			EndIf
		Endif
	ENDIF

	If !lValid
		ApMsgAlert( cMsg )
	Else
		lValid := ChkPlatRisk(  @aWizParam[ OFFBALANCE ] )
		lValid := lValid .And. ChkPlatAntecipa(  @aWizParam[ OFFBALANCE ], @oAntecipa )
		lValid := lValid .And. CheckCarol(  @aWizParam[ OFFBALANCE ], oAntecipa[ "apiToken" ],  oAntecipa[ "connectorId" ] )
		SaveConfig( aWizParam )
	EndIf

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetActionMn
	Fun��o executada ao clicar no bot�o Informar dados.
	Esta fun��o � respons�vel por montar a AXINCLUI para informar os dados adicionais ao 
	incluir o registro na base de dados.
	@type  Static Function
	@author user
	@since 27/04/2023
	@param nType, number, identifica qual a entidade est� sendo validada, onde:
		[1] - cliente
		[2] - fornecedor
		[3] - banco
		[4] - situa��o de cobran�a
	@param aArray, array, armezena os dados da entidade
	@param @lExist, boolean, vari�vel de controle do bot�o. Se ocorrer a inclus�o pela
	fun��o, o bot�o no wizard deve ser desabilitado. 
	@param  lAutomato, boolean, Indica que a fun��o foi chamada por um script ADVPR
/*/
//-------------------------------------------------------------------------------------
Static Function SetActionMn( nType as Numeric, aArray as Array, lExist as Logical, lPesqCad as Logical, lAutomato as Logical )
	Local aSvAlias 		as Array
	Local aParam   		as Array
	Local aFields  		as Array
	Local cAlias   		as Character
	Local nPos     		as Numeric

	Private cCadastro
	Private aRotina   	:= MenuDef()
	Private lAtuCad   	:= .F.

	Default lAutomato 	:= .F.
	Default lPesqCad  	:= .F.

	aSvAlias 			:= GetArea()
	aParam   			:= Array(4)
	aFields  			:= {}
	cAlias   			:= ''
	nPos     			:= 0

	If nType == CLIENT
		cCadastro := STR0027    //"Configura��o do cliente - OffBalance"
		aFields   := {'A1_FILIAL', 'A1_COD', 'A1_LOJA', 'A1_NOME', 'A1_NREDUZ'}
	ElseIf nType == PROVIDER
		cCadastro := STR0028    //"Configura��o do fornecedor - OffBalance"
		aFields   := {'A2_FILIAL', 'A2_COD', 'A2_LOJA', 'A2_NOME', 'A2_NREDUZ'}
	ElseIf nType == BANK
		cCadastro := STR0029    //"Configura��o do banco - OffBalance"
		aFields   := {'A6_FILIAL', 'A6_COD', 'A6_AGENCIA', 'A6_NUMCON', 'A6_NOME', 'A6_NREDUZ'}
	EndIf

	cAlias := aArray[ ENT_ALIAS ]

	If lPesqCad
		If .Not. lAutomato
			mBrowse(6,1,22,75,cAlias)
		EndIf
	Else
		aArray := LoadParamInfo(nType)
		aParam[1] := {|| SetFldEnch( nType, aFields, aArray )}
		aParam[2] := {|| .T. }
		aParam[3] := {|| .T. }
		aParam[4] := {|| .T. }

		If !lAutomato .And. AxInclui( cAlias, , , , , , , , , , aParam ) == 1
			lAtuCad := .T.
			lExist  := .T.
		EndIf
	EndIf

	If lAtuCad
		For nPos := 1 To Len( aFields ) - 1
			aArray[ nPos ] := ( cAlias )->&( aFields[ nPos ])
		Next
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aParam )
	FWFreeArray( aSvAlias )
	FWFreeArray( aFields )
	FWFreeArray( aRotina )
Return

//-------------------------------------------------------------------------------------
/*/
{Protheus.doc} CheckParam
Fun��o de verifica se o registro existe no banco de dados

@param nType, number, identifica qual a entidade est� sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situa��o de cobran�a

@param aInfo, array, armezena os dados da entidade a ser pesquisada

@return boolean, indica se o registro em quest�o existe no banco de dados.

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function CheckParam( nType as Numeric, aInfo as Array ) as Logical
	Local lExist 	 As Logical
	Local cQuery 	 As Character
	Local cTempAlias As Character
	Local aSvAlias 	 As Array

	lExist 	   := .F.
	cQuery 	   := ''
	cTempAlias := ''
	aSvAlias   := GetArea()

	IF nType == CLIENT
		cQuery := "SELECT A1_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
			" WHERE A1_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
			" AND A1_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
			" AND A1_LOJA = '" + aInfo[ ENT_STORE ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseIf nType == PROVIDER
		cQuery := "SELECT A2_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
			" WHERE A2_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
			" AND A2_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
			" AND A2_LOJA = '" + aInfo[ ENT_STORE ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseIf nType == BANK
		cQuery := "SELECT A6_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
			" WHERE A6_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
			" AND A6_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
			" AND A6_AGENCIA = '" + aInfo[ ENT_STORE ] + "' " + ;
			" AND A6_NUMCON = '" + aInfo[ ENT_DESC ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	EndIf

	IF !Empty( cQuery )
		cQuery := ChangeQuery( cQuery )

		cTempAlias := MPSysOpenQuery( cQuery )
		If ( cTempAlias )->( !Eof() )
			lExist := .T.
		EndIf
		( cTempAlias )->( DbCloseArea() )
	EndIf

	RestArea( aSvAlias )
	FWFreeArray( aSvAlias )
Return lExist

//-------------------------------------------------------------------------------------
/*
	{Protheus.doc} SetFldEnch
	Fun��o respons�vel em atribuir um conte�do padr�o aos campos da enchoice.
	@type  Static Function
	@author user
	@since 27/04/2023
	@param nType, number, identifica qual a entidade est� sendo validada, onde:
		[1] - cliente
		[2] - fornecedor
		[3] - banco
		[4] - situa��o de cobran�a
	@param aEnchFields, array, lista de campos que ter� um conte�do pr�-estabelecido na enchoice
	@param aValue, array, armezena os dados da entidade
/*/
//-------------------------------------------------------------------------------------
Static Function SetFldEnch( nType as Numeric, aEnchFields as Array, aValue as Array )
	Local nPos 	   As Numeric
	Local cAuxDesc As Character 
	Local cField   As Character
	Local lOther   As Logical

	nPos 	 := 0
	cAuxDesc := 'SUPPLIER OFFBALANCE'
	cField 	 := ''
	lOther 	 := .F.

	For nPos := 1 To Len( aEnchFields )
		cField := aEnchFields[ nPos ]
		lOther := .F.

		If cField == 'A6_NOME'
			cAuxDesc := STR0030     //'SUPPLIER - CONTA TRANSIT�RIA'
			lOther := .T.
		elseIf cField == 'A6_NREDUZ'
			cAuxDesc := 'SUPPLIER'
			lOther := .T.
		EndIF

		If nPos != len( aEnchFields ) .And. !lOther
			M->&( aEnchFields[ nPos ] ) := aValue[ nPos ]
		Else
			M->&( aEnchFields[ nPos ] ) := cAuxDesc
		EndIF
	Next

	If nType == CLIENT .OR. nType == PROVIDER
		SetOtherFlds( nType )
	EndIf
Return Nil

//-------------------------------------------------------------------------------------
/*/
	{Protheus.doc} LoadPlatInfo
	Fun��o que busca os par�metros de conex�o com a plataforma RISK e a Carol
	@type  Static Function
	@author user
	@since 27/04/2023
	@param @aPlatInfo, array, vetor com informa��es de conex�o com a plataforma
		[1] - URL da plataforma Carol
		[2] - URL da plataforma RISK
		[3] - ID do conector da Carol
		[4] - Token da API da Carol
		[5] - URL do RAC
		[6] - ID do tenant
		[7] - Descri��o do tipo de uso
		[8] - Tipo de uso (salvo no par�metro MV_RISKTIP)
		[9] - Client ID
		[10] - Secret
/*/
//-------------------------------------------------------------------------------------
Static Function LoadPlatInfo( aPlatInfo as Array )
	Local aSvAlias 		As Array
	Local nRiskType 	As Numeric
	Local nTamInfo 		As Numeric
	Local cRacURL 		As Character
	Local cPlatform 	As Character 
	Local cPlatfCash 	As Character 
	Local cClientID 	As Character 
	Local cCarolURL 	As Character 
	Local cCarolConnID 	As Character 
	Local cCarolToken 	As Character 
	Local cTenant 		As Character 
	Local cTypeDesc 	As Character 
	Local oConfig		As Object

	aSvAlias 	 := GetArea()
	nRiskType 	 := 2
	nTamInfo 	 := 120
	cRacURL 	 := ''
	cPlatform 	 := ''
	cPlatfCash 	 := ''
	cClientID 	 := ''
	cCarolURL 	 := ''
	cCarolConnID := ''
	cCarolToken  := ''
	cTenant 	 := ''
	cTypeDesc 	 := STR0031 // "Mais Neg�cios"
	oConfig		 := Nil

	oConfig   := FWTFConfig()
	cClientID := oConfig[ "platform-clientId" ]

	If !Empty( cClientID )
		cPlatform    := SuperGetMV( 'MV_RSKPLAT', .F., '' )
		cCarolURL    := oConfig[ "carol-endpoint" ]
		cPlatfCash   := oConfig[ "platform-endpoint" ]
		cCarolConnID := oConfig[ "carol-connectorId" ]
		cCarolToken  := oConfig[ "carol-apiToken" ]
		cRacURL      := oConfig[ "rac-endpoint" ]
		cTenant      := oConfig[ "platform-tenantId" ]
		cSecret      := oConfig[ "platform-secret" ]
	Else
		cCarolURL    := SuperGetMV( 'MV_RSKCURL', .F., '' )
		cPlatform    := SuperGetMV( 'MV_RSKPLAT', .F., '' )
		cCarolConnID := SuperGetMV( 'MV_RSKCCID', .F., '' )
		cCarolToken  := SuperGetMV( 'MV_RSKCTOK', .F., '' )
		cRacURL 	 := SuperGetMV( 'MV_RSKRAC', .F., '' )
		If Empty( cRacURL)
		    If __lRegistry
	            cRacURL := Left( __oTFRegistry:oUrlTF["rac-token-V1"], AT( '/totvs.rac/', __oTFRegistry:oUrlTF["rac-token-V1"] ) - 1 )
				If Empty( cPlatform )
					cPlatform := Left( __oTFRegistry:oUrlTF["risk-protheusapi-credit-ticket-V1"], AT( '/protheus-api/', __oTFRegistry:oUrlTF["risk-protheusapi-credit-ticket-V1"] ) - 1 )
				EndIf
    	    Else
        	    cRacURL := RSKSetRacURL( NIL, cPlatform )
        	EndIf
		EndIf
		cTenant 	 := SuperGetMV( 'MV_RSKTENA', .F., '' )
		cClientID 	 := SuperGetMV( 'MV_RSKCID', .F., '' )
		cSecret 	 := SuperGetMV( 'MV_RSKSID', .F., '' )
	EndIf
	aPlatInfo[ CAROL_URL ]            := AllTrim( cCarolURL )
	aPlatInfo[ PLATFORM_URL_RISK ]    := AllTrim( cPlatform )
	aPlatInfo[ CAROL_CONNID ]         := AllTrim( cCarolConnID )
	aPlatInfo[ CAROL_TOKEN ]          := AllTrim( cCarolToken )
	aPlatInfo[ RAC_URL ]              := AllTrim( cRacURL )
	aPlatInfo[ TENANT ]               := AllTrim( cTenant )
	aPlatInfo[ RISK_TYPE ]            := nRiskType
	aPlatInfo[ RISK_TYPE_DESC ]       := Padr( cTypeDesc, nTamInfo )
	aPlatInfo[ RISK_CLIENT_ID ]       := AllTrim( cClientID )
	aPlatInfo[ RISK_CLIENT_SECRET ]   := AllTrim( cSecret )
	aPlatInfo[ PLATFORM_URL_FMSCASH ] := AllTrim( cPlatfCash )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FreeObj( oConfig )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadParamInfo
	Esta fun��o � respons�vel por retornar os dados padr�es do par�metro (caso n�o esteja 
	preenchido) ou os dados existentes no banco de dados.
	@type  Static Function
	@author user
	@since 27/04/2023
	@param nType, number, identifica qual a entidade est� sendo validada, onde:
		[1] - cliente
		[2] - fornecedor
		[3] - banco
		[4] - situa��o de cobran�a
	@param lPesqComp, Logical, define como ser� o retorno da fun��o
	@return, array, armezena os dados da entidade
		aReturn[1] := filial (Ex: A1_FILIAL)
		aReturn[2] := c�digo de busca (Ex: A1_COD)
		aReturn[3] := c�digo auxiliar de busca (Ex: A1_LOJA)
		aReturn[4] := descri��o do registro (Ex: A1_NOME)
		aReturn[5] := descri��o auxiliar  
		aReturn[6] := nome do par�metro
		aReturn[7] := tabela da entidade
		aReturn[8] := identifica��o
		aReturn[9] := conte�do do par�metro
		aReturn[10] := vetor com o registro modelo
/*/
//-------------------------------------------------------------------------------------
Static Function LoadParamInfo( nType as Numeric, lPesqComp as Logical) as Array
	Local aSvAlias 		As Array
	Local cContent 		As Character
	Local cAux 			As Character
	Local cDefaultText	As Character
	Local cSupplierName As Character
	Local aReturn 		As Array
	Local aContent 		As Array
	Local cSeek 		As Character
	Local cAlias 		As Character

	aSvAlias 	  := GetArea()
	cContent 	  := ''
	cAux 		  := ''
	cDefaultText  := 'SUPPLIER'
	cSupplierName := 'SUPPLIER ADM. DE CARTOES DE CREDITO S/A' //Nunca traduzir
	aReturn 	  := Iif(nType == SCHEDULE, Array( SIZE_SCHEDULE ), Array( SIZE_ENTITY ))
	aContent 	  := {}
	cSeek 		  := ''
	cAlias 		  := ''

	Default lPesqComp := .T.

	If nType == CLIENT
		aReturn[ ENT_CODE ]      := Padr( cDefaultText, TamSX3( 'A1_COD' )[1] )
		aReturn[ ENT_STORE ]     := StrZero( 1, TamSX3( "A1_LOJA" )[1] )
		aReturn[ ENT_DESC ]      := Padr( cSupplierName, TamSX3( "A1_NOME" )[1] )
		aReturn[ ENT_AUX_DESC ]  := ''
		aReturn[ ENT_PARAMETER ] := 'MV_RSKCPAY'
		aReturn[ ENT_ALIAS ]     := 'SA1'
		aReturn[ ENT_IDENT]      := 'Client'
	ElseIf nType == PROVIDER
		aReturn[ ENT_CODE ]      := Padr( cDefaultText, TamSX3( 'A2_COD' )[1] )
		aReturn[ ENT_STORE ]     := StrZero( 1, TamSX3( "A2_LOJA" )[1] )
		aReturn[ ENT_DESC ]      := Padr( cSupplierName, TamSX3( "A2_NOME" )[1] )
		aReturn[ ENT_AUX_DESC ]  := ''
		aReturn[ ENT_PARAMETER ] := 'MV_RSKFPAY'
		aReturn[ ENT_ALIAS ]     := 'SA2'
		aReturn[ ENT_IDENT ]     := 'Provider'
	ElseIf nType == BANK
		aReturn[ ENT_CODE ]      := Padr( cDefaultText, TamSX3( 'A6_COD' )[1] )
		aReturn[ ENT_STORE ]     := Padr( cDefaultText, TAMSX3( "A6_AGENCIA" )[1] )
		aReturn[ ENT_DESC ]      := Padr( cDefaultText, TAMSX3( "A6_NUMCON" )[1] )
		aReturn[ ENT_AUX_DESC ]  := Padr( STR0030, TAMSX3( "A6_NOME" )[1] )  //'SUPPLIER - CONTA TRANSITORIA'
		aReturn[ ENT_PARAMETER ] := 'MV_RSKBPAY'
		aReturn[ ENT_ALIAS ]     := 'SA6'
		aReturn[ ENT_IDENT ]     := 'Bank'
	ElseIf nType == BILLING
		aReturn[ ENT_CODE ]      := ValidCart()
		aReturn[ ENT_STORE ]     := Padr( STR0016, TamSx3( "FRV_DESCRI" )[1] )  //'CARTEIRA DEVOLUCAO POS FATURAMENTO'
		aReturn[ ENT_DESC ]      := ''
		aReturn[ ENT_AUX_DESC ]  := ''
		aReturn[ ENT_PARAMETER ] := 'MV_RSKSNCC'
		aReturn[ ENT_ALIAS ]     := 'FRV'
		aReturn[ ENT_IDENT ]     := 'Billing'
	ElseIf nType == SCHEDULE
		aReturn[ MVRSKPLS1 ]     := TEXT_MVRSKPLS_1
		aReturn[ MVRSKPLS2 ]     := TEXT_MVRSKPLS_2
		aReturn[ MVRSKPLS3 ]     := TEXT_MVRSKPLS_3
	EndIf

	If nType # SCHEDULE
		aReturn[ ENT_BRANCH ]  := xFilial( aReturn[ ENT_ALIAS ] )
		aReturn[ ENT_CONTENT ] := ''
		aReturn[ ENT_MODEL ]   := {}

		cContent := SuperGetMV( aReturn[ ENT_PARAMETER ], .T., '' )
	EndIf

	If !Empty( cContent ) .And. lPesqComp
		cAlias   := aReturn[ ENT_ALIAS ]
		cSeek    := StrTran( cContent, '|', '' )
		aContent := StrtokArr( cContent , '|' )

		aReturn[ ENT_CODE ] := aContent[1]

		If nType == BANK
			cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_AGENCIA' )
			If !Empty( cAux )
				aReturn[ ENT_STORE ] := cAux
			Else
				aReturn[ ENT_STORE ] := aContent[2]
			EndIf

			cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_NUMCON' )
			If !Empty( cAux )
				aReturn[ ENT_DESC ] := cAux
			Else
				aReturn[ ENT_DESC ] := aContent[3]				
			EndIf

			cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_NOME' )
			If !Empty( cAux )
				aReturn[ ENT_AUX_DESC ] := cAux
			EndIf
		ElseIf nType == BILLING
			cAux := Posicione( 'FRV', 1, xFilial('FRV') + cSeek , 'FRV_DESCRI' )
			If !Empty( cAux )
				aReturn[ ENT_STORE ] := cAux
			EndIf
		Else
			aReturn[ ENT_STORE ] := aContent[2]
			aReturn[ ENT_DESC ]  := Posicione( cAlias, 1, xFilial( cAlias ) + cSeek, PrefixoCPO( cAlias ) + '_NOME' )
		EndIf

		aReturn[ ENT_CONTENT ] := cContent
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aContent )
Return aReturn

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskVldDic
	Valida se o dicionario de dados est� atualizado.
	@type  Static Function
	@author user
	@since 27/04/2023
	@return Logico, Verdadeiro se o dicionario est� atualizado.
/*/
//-------------------------------------------------------------------------------------
Static Function RskVldDic() As Logical
	Local lRet As Logical
	
	lRet := .T.

	DBSelectArea( "SX2" )
	DBSetOrder(1)

	If SX2->( DBSeek( "AGA" ) ) .And. Empty( SX2->X2_UNICO )
		lRet := .F.
	EndIf

	If lRet
		If SX2->( DBSeek( "AGB" ) ) .And. Empty( SX2->X2_UNICO )
			lRet := .F.
		EndIf
	EndIf

	If lRet
		DBSelectArea( "SX3" )
		DBSetOrder(2)
		If !SX3->( DBSeek( "AR0_FILNFS" ) )
			lRet := .F.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveParameters
	Salva os par�metros na base de dados.
	@type  Static Function
	@author user
	@since 27/04/2023
	@param aSX6, array, Lista de par�metros a gravar
	@param aOffBalance, array, vetor com as informar��es de conex�o da plataforma
/*/
//-------------------------------------------------------------------------------------
Static Function SaveParameters( aSX6 as Array, aOffBalance as Array )
	Local aStruct 		 As Array
	Local aSvAlias 		 As Array 
	Local nTamSX6 		 As Numeric
	Local lFind    		 As Logical
	Local cEndpoint  	 As Character
	Local nParams 		 As Numeric
	Local nFields 		 As Numeric
	Local cCarolURL 	 As Character
	Local cPlatform 	 As Character
	Local cCarolConnID 	 As Character
	Local cCarolAPIToken As Character
	Local cRiskType 	 As Character
	Local cRacURL 		 As Character
	Local cTenant 		 As Character
	Local cClientID 	 As Character
	Local cSecret 		 As Character

	aStruct 		:= { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_DESC1", "X6_DESC2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI", "X6_PYME" }
	aSvAlias 		:= GetArea()
	nTamSX6 		:= 0
	lFind    		:= .F.
	cEndpoint  		:= ''
	nParams 		:= 0
	nFields 		:= 0
	cCarolURL 		:= ''
	cPlatform 		:= ''
	cCarolConnID 	:= ''
	cCarolAPIToken 	:= ''
	cRiskType 		:= ''
	cRacURL 		:= ''
	cTenant 		:= ''
	cClientID 		:=''	
	cSecret			:= ''

	Default aSX6 := {}

	IF Empty( aSX6 )
		nTamSX6 := TamSX3( "A1_FILIAL" )[1]

		cEndpoint      := alltrim( aOffBalance[ PLATFORM_URL_RISK ] ) + '/entities'
		cCarolURL      := aOffBalance[ CAROL_URL ]
		cPlatform      := aOffBalance[ PLATFORM_URL_RISK ]
		cCarolConnID   := aOffBalance[ CAROL_CONNID ]
		cCarolAPIToken := aOffBalance[ CAROL_TOKEN ]
		cRiskType      := Alltrim( Str( aOffBalance[ RISK_TYPE ] ) )
		cRacURL        := aOffBalance[ RAC_URL ]
		cTenant        := aOffBalance[ TENANT ]
		cClientID      := aOffBalance[ RISK_CLIENT_ID ]
		cSecret        := aOffBalance[ RISK_CLIENT_SECRET ]

		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RISKAPI', 'C', STR0032, '', '', cEndpoint, cEndpoint, cEndpoint, 'S', 'S'} )    //'Informe a URL de integra��o com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCURL', 'C', STR0033, '', '', cCarolURL, cCarolURL, cCarolURL, 'S', 'S'} )    //'Informe a URL da plataforma Carol com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKPLAT', 'C', STR0034, '', '', cPlatform, cPlatform, cPlatform, 'S', 'S'} )    //'Informe a URL da plataforma Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCCID', 'C', STR0035, '', '', cCarolConnID, cCarolConnID, cCarolConnID, 'S', 'S'} )   //'Informe o Connector ID da Carol com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCTOK', 'C', STR0036, '', '', cCarolAPIToken, cCarolAPIToken, cCarolAPIToken, 'S', 'S'} )     //'Informe o API Token da Carol com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RISKTIP', 'N', STR0037, '', '', cRiskType, cRiskType, cRiskType, 'S', 'S'} )    //'Define o tipo de integracao Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKRAC' , 'C', STR0038, '', '', cRacURL, cRacURL, cRacURL, 'S', 'S'} )       //'Informe a URL do RAC utilizada no Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKTENA', 'C', STR0039, '', '', cTenant, cTenant, cTenant, 'S', 'S'} )      //'Informe o tenant utilizado no Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCID' , 'C', STR0040, '', '', cClientID, cClientID, cClientID, 'S', 'S'} ) //'Informe o Client ID para acessar o Mais Neg�cios'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKSID' , 'C', STR0041, '', '', cSecret, cSecret, cSecret, 'S', 'S'} )       //'Informe o Secret para acessar o Mais Neg�cios'
	EndIf

	dbSelectArea( "SX6" )
	dbSetOrder(1)
	For nParams := 1 To Len( aSX6 )
		If !Empty( aSX6[ nParams ][2] )
			If !dbSeek( aSX6[ nParams, 1] + aSX6[ nParams, 2] )
				lFind := .F.
			Else
				lFind := .T.
			EndIf

			RecLock( "SX6", !lFind )
			For nFields := 1 To Len( aSX6[ nParams ] )
				If !Empty( FieldName( FieldPos( aStruct[ nFields ] ) ) )
					IF !lFind .Or. "X6_CONT" $ aStruct[ nFields ]
						FieldPut( FieldPos( aStruct[ nFields ] ), AllTrim(aSX6[ nParams, nFields]) )
					EndIf
				EndIf
			Next
			MsUnLock()
		EndIf
	Next

	RestArea( aSvAlias )

	FwFreeArray( aSvAlias )
	FWFreeArray( aSX6 )
Return

/*/{Protheus.doc} ValidCart
	Verifia se carteira R esta disponivel, caso esta esteja em uso sugere um nova carteira.
	@type  Static Function
	@author Lucas Silva Vieira
	@since 07/07/2022
	@return cCarteira, Character, numero da carteira 
/*/
Static Function ValidCart() As Character
	Local cCodCart   As Character
	Local cCartParam As Character
	Local cCarteira  As Character
	Local aAreaFRV	 As Array
	Local nTamFRV	 As Numeric

	cCarteira  := 'R'
	cCartParam := SuperGetMV("MV_RSKSNCC",.F.,"")
	nTamFRV	   := TamSX3( "FRV_CODIGO" )[1]
	cCodCart   := Replicate( "0", nTamFRV )
	aAreaFRV   := FRV->( GetArea() )

	If (Empty(cCartParam))
		FRV->(dbSetOrder(1))
		If FRV->(MsSeek( xFilial( "FRV" ) + cCarteira))
			cCodCart := SubStr(cCodCart, 1, nTamFRV)
			While cCodCart != SubStr(Replicate("Z", nTamFRV), 1, nTamFRV)
				If FRV->(MsSeek( xFilial( "FRV" ) + cCodCart))
					cCodCart := Soma1(cCodCart)
				Else
					cCarteira := cCodCart
					Exit
				EndIf
			EndDo
		Endif
	Else
		cCarteira := cCartParam
	Endif
	RestArea( aAreaFRV )
	FWFreeArray( aAreaFRV )
Return cCarteira

//-------------------------------------------------------------------------------------
/*/
	{Protheus.doc} SaveConfig
	Fun��o de montagem dos componentes da aba - dados da plataforma P�s Faturamento
	@param aWizParam, array, vetor com as informar��es mostradas no Wizard. 
	@author  Marcia Junko
	@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveConfig( aWizParam As Array )

// Salva as informa��es da plataforma - Antecipa
SaveAntecipa( aWizParam[ OFFBALANCE ] )
// Grava o Job de integra��o do RISK na tabela do Schedule
SaveSchedule( aWizParam[ SCHEDULE ][ ESCOLHA_SCHEDULE ] )
// Cria o registro do cliente de integra��o com a Supplier
SaveEntity( aWizParam )
// Cria os par�metros de integra��o com o RISK
SaveParameters( , aWizParam[ OFFBALANCE ] )
// Integra os par�metros do Protheus na plataforma
SyncCarolSX6( aWizParam[ OFFBALANCE ] )
// Cria cadastros necess�rios para baixa Protheus.
RskIncMOtBX()

Return

//-------------------------------------------------------------------------------------
/*/
	{Protheus.doc} SaveAntecipa
	Fun��o que grava os dados de conex�o com o Antecipa

	@param aOffBalance, array, vetor com as informar��es de conex�o da plataforma
	@param oAntecipa, object, objeto de valida��o da plataforma do Antecipa

	@author  Marcia Junko
	@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveAntecipa( aOffBalance As Array )
	Local oConfig  As Object
	Local aSvAlias As Array

	aSvAlias := GetArea()
	oConfig  := JsonObject():New()
	oConfig[ "platform-clientId" ] := AllTrim( aOffBalance[ RISK_CLIENT_ID ] )
	oConfig[ "platform-secret"   ] := AllTrim( aOffBalance[ RISK_CLIENT_SECRET ] )
	oConfig[ "platform-endpoint" ] := AllTrim( aOffBalance[ PLATFORM_URL_FMSCASH ] )
	oConfig[ "platform-tenantid" ] := AllTrim( aOffBalance[ TENANT ] )
	oConfig[ "carol-connectorId" ] := AllTrim( aOffBalance[ CAROL_CONNID ] )
	oConfig[ "carol-apiToken" ]    := AllTrim( aOffBalance[ CAROL_TOKEN ] )
	oConfig[ "carol-endpoint" ]    := AllTrim( aOffBalance[ CAROL_URL ] )
	oConfig[ "rac-endpoint" ]      := AllTrim( aOffBalance[ RAC_URL ] )
	FwTFSetConfig( oConfig )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FreeObj( oConfig )
Return

//-------------------------------------------------------------------------------------
/*/
	{Protheus.doc} SaveSchedule
	Fun��o que grava os JOBs no Schedule

	@author  Marcia Junko
	@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveSchedule(cOpcSched As Character)
	Local aJobs       As Array
	Local aSchdComp   As Array
	Local aSvAlias    As Array
	Local cAgend      As Character
	Local cExecComp   As Character
	Local cRecurrence As Character
	Local cStatus     As Character
	Local cTaskID     As Character
	Local cTime       As Character
	Local nAux        As Numeric
	Local nItem       As Numeric
	Local oDASchedule As Object
	Local oSched      As Object

	If cOpcSched == TEXT_MVRSKPLS_1
		aJobs := {'FWTECHFINJOB', 'RSKJOBCOMMAND', 'RSKJobBank'}
	ElseIf cOpcSched == TEXT_MVRSKPLS_2
		aJobs := {'FWTECHFINJOB', 'RSKJOBMOVEMENT', 'RSKJOBGETRECORDS', 'RSKJobBank'}
	ElseIf cOpcSched == TEXT_MVRSKPLS_3
		aJobs := {'FWTECHFINJOB', 'RSKJOBPOST', 'RSKJOBMOVEMENT', 'RSKJOBGETRECORDS ', 'RSKJobBank'}
	Else
		aJobs := {'FWTECHFINJOB', 'RSKJOBCOMMAND', 'RSKJobBank'}
	EndIf

	aSchdComp   := {}
	aSvAlias    := GetArea()
	cAgend      := ""
	cRecurrence := ""
	cStatus     := ""
	cTaskID     := ""
	cTime       := ""
	nAux        := 0
	nItem       := 1
	oDASchedule := Nil
	oSched      := Nil
	cExecComp   := cEmpAnt + "/" + cFilAnt + ";"

	For nItem := 1 To Len( aJobs )
		cRecurrence := 'A'
		cTime       := '00:00'
		cStatus     := SCHD_ACTIVE

		If aJobs[ nItem ] == "RSKJOBCOMMAND" .Or. aJobs[ nItem ] == "RSKJOBMOVEMENT" .Or. aJobs[ nItem ] == "RSKJOBGETRECORDS" .Or. aJobs[ nItem ] == "RSKJOBPOST"
			cRecurrence := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(288 );Interval(00:05);Discard;"
		ElseIf aJobs[ nItem ] == "RSKJobBank"
			cRecurrence := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(1   );Interval(00:00);Discard;"
			cTime := '22:00'
		EndIf

		cTaskID := FwSchdByFunction( aJobs[ nItem ] )
		If !Empty( cTaskID )
			oDASchedule := FWDASchedule():New()
			oSched      := oDASchedule:getSchedule( cTaskID )
			cRecurrence := oSched:getPeriod()
			cTime       := oSched:getTime()
			cStatus     := oSched:getStatus()

			FWDelSchedule( cTaskID )
		EndIf

		cAgend := FwInsSchedule( aJobs[ nItem ], __cUserID, , cRecurrence, cTime, Upper( GetEnvServer() ), cExecComp, cStatus, Date(), 5, NIL )
	Next

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aJobs )
	FWFreeArray( aSchdComp )

	FwFreeObj( oDASchedule )
	FwFreeObj( oSched )
Return

//-------------------------------------------------------------------------------------
/*/
	{Protheus.doc} SaveEntity
	Fun��o que grava as entidades relacionados aos par�metros e dispara a grava��o dos 
	par�metros por filial.

	@param oStatus, object, Painel onde ser�o mostrados as etapas de grava��o.
	@param aSM0, array, vetor com todas as filiais do SIGAMAT
	@param aWizParam, array, vetor com as informar��es mostradas no Wizard. 

	@author  Marcia Junko
	@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveEntity( aWizParam As Array )
	Local aSvAlias 	  	As Array
	Local aSX6 		  	As Array
	Local aParam	  	As Array
	Local aModel 	  	As Array
	Local aItemsSX6   	As Array
	Local aWhere 	  	As Array
	Local nEmp 		  	As Numeric
	Local nFields 	  	As Numeric
	Local nSizeFilial 	As Numeric
	Local cCompExec     As Character
	Local cBranchExec   As Character
	Local cClientExec   As Character
	Local cNewClient    As Character
	Local cLastClient   As Character
	Local cNewProvider  As Character
	Local cLastProvider As Character
	Local cNewBank 	    As Character
	Local cLastBank 	As Character
	Local cNewBilling 	As Character
	Local cLastBilling 	As Character
	Local cContent 		As Character
	Local cFindBranch 	As Character
	Local cProviderExec As Character
	Local cBankExec 	As Character
	Local cBillingExec 	As Character
	Local lDiference 	As Logical
	Local nElem			As Numeric
	Local cSeek 		As Character
	Local cParamContent As Character
	Local cSeekAlias  	As Character
	Local cNewBranch  	As Character
	Local lExecute    	As Logical
	Local aSM0          As Array
	Local nTamSX6       As Numeric
	Local cOpcSched     As Character

	aSvAlias	  := GetArea()
	aSX6 		  := {}
	aParam		  := {}
	aModel 		  := {}
	aItemsSX6 	  := {}
	aWhere		  := {}
	nEmp 		  := 0
	nFields 	  := 0
	nSizeFilial   := FWSizeFilial( SM0->M0_CODIGO )
	cCompExec     := cEmpAnt
	cBranchExec   := cFilAnt
	cClientExec   := aWizParam[ CLIENT ][ ENT_CODE ]
	cNewClient    := ''
	cLastClient   := ''
	cNewProvider  := ''
	cLastProvider := ''
	cNewBank      := ''
	cLastBank 	  := ''
	cNewBilling   := ''
	cLastBilling  := ''
	cContent 	  := ''
	cFindBranch   := ''
	cProviderExec := aWizParam[ PROVIDER ][ ENT_CODE ]
	cBankExec     := aWizParam[ BANK ][ ENT_CODE]
	cBillingExec  := aWizParam[ BILLING ][ ENT_CODE ]
	lDiference 	  := .F.
	nElem		  := 0
	cSeek 		  := ''
	cParamContent := ''
	cSeekAlias    := ''
	cNewBranch    := ''
	lExecute      := .F.
	aSM0          := FWLoadSM0()
	nTamSX6       := TamSX3( "A1_FILIAL" )[1]
	
	If Empty( aWizParam[ CLIENT ][ ENT_MODEL ] )
		aWizParam[ CLIENT ][ ENT_MODEL ] := GetModel( CLIENT, aWizParam[ CLIENT ] )
	EndIf

	If Empty( aWizParam[ PROVIDER ][ ENT_MODEL ] )
		aWizParam[ PROVIDER ][ ENT_MODEL ] := GetModel( PROVIDER, aWizParam[ PROVIDER ] )
	EndIf

	If Empty( aWizParam[ BANK ][ ENT_MODEL ] )
		aWizParam[ BANK ][ ENT_MODEL ] := GetModel( BANK, aWizParam[ BANK ] )
	EndIf

	If Empty( aWizParam[ BILLING ][ ENT_MODEL ] )
		aWizParam[ BILLING ][ ENT_MODEL ] := GetModel( BILLING, aWizParam[ BILLING ] )
	EndIf

	For nEmp := 1 To Len( aSM0 )
		cNewClient   := FwxFilial( "SA1", aSM0[ nEmp ][2], FWModeAccess('SA1',1), FWModeAccess('SA1',2), FWModeAccess('SA1',3))
		cNewProvider := FwxFilial( "SA2", aSM0[ nEmp ][2], FWModeAccess('SA2',1), FWModeAccess('SA2',2), FWModeAccess('SA2',3))
		cNewBank     := FwxFilial( "SA6", aSM0[ nEmp ][2], FWModeAccess('SA6',1), FWModeAccess('SA6',2), FWModeAccess('SA6',3))
		cNewBilling  := FwxFilial( "FRV", aSM0[ nEmp ][2], FWModeAccess('FRV',1), FWModeAccess('FRV',2), FWModeAccess('FRV',3))

		If aSM0[ nEmp ][1] == cCompExec
			nSizeFilial := FWSizeFilial( aSM0[ nEmp ][1] )

			IF cNewClient != cLastClient .or. cNewProvider != cLastProvider .or. cNewBank != cLastBank  .or. cNewBilling != cLastBilling
				RPCClearEnv()
				ConnectComp( aSM0[ nEmp ][1], aSM0[ nEmp ][2] )

				For nElem := 1 To 4
					lDiference  := .F.
					cNewBranch  := ''
					cLastBranch := ''
					aModel 		:= {}
					aWhere 		:= {}
					aElem 		:= aWizParam[ nElem ]
					aModel 		:= aElem[ ENT_MODEL ]

					If nElem == CLIENT
						lDiference := ( cNewClient != cLastClient )
						cNewBranch := cNewClient
						aWhere := { { 'A1_FILIAL', xFilial( 'SA1' ) }, { 'A1_COD', aElem[ ENT_CODE ] }, { 'A1_LOJA', aElem[ ENT_STORE ] } }
					Elseif nElem == PROVIDER
						lDiference := ( cNewProvider != cLastProvider )
						cNewBranch := cNewProvider
						aWhere := { { 'A2_FILIAL', xFilial( 'SA2' ) }, { 'A2_COD', aElem[ ENT_CODE ] }, { 'A2_LOJA', aElem[ ENT_STORE ] } }
					ElseIf nElem == BANK
						lDiference := ( cNewBank != cLastBank )
						cNewBranch := cNewBank
						aWhere := { { 'A6_FILIAL', xFilial( cSeekAlias ) }, { 'A6_COD', aElem[ ENT_CODE ] }, { 'A6_AGENCIA', aElem[ ENT_STORE ] }, {'A6_NUMCON', aElem[ ENT_DESC ] } }
					Else
						lDiference := ( cNewBilling != cLastBilling )
						cNewBranch := cNewBilling
						aWhere := { { 'FRV_FILIAL', xFilial( cSeekAlias ) }, { 'FRV_CODIGO', aElem[ ENT_CODE ] } }
					EndIf

					If lDiference
						cSeekAlias := aElem[ ENT_ALIAS ]
						cSeek 	   := aElem[ ENT_CODE ]

						If cSeekAlias != "FRV"
							cSeek += aElem[ ENT_STORE ]

							If cSeekAlias == "SA6"
								cSeek += aElem[ ENT_DESC ]
							EndIf
						EndIf

						cParamContent := aElem[ ENT_CONTENT ]
						// Verifico se ja foi executado antes
						If Empty(cParamContent)
							cLastBranch := xFilial( cSeekAlias )
							if cSeekAlias == 'FRV'
								cContent := aElem[ ENT_CODE ]
							Elseif cSeekAlias == 'SA6'
								cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ] + '|' + aElem[ ENT_DESC ]
							ELSE
								cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ]
							ENDIF
							cFindBranch := Space( nSizeFilial )

							If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cFindBranch .and. x[2] == aElem[ ENT_PARAMETER ] } ) > 0
								cParamContent := cContent
							EndIf
						EndIf

						DBSelectArea( cSeekAlias )
						DbSetOrder(1)

						IF Empty( cParamContent ) .or. !dbSeek( xFilial( cSeekAlias ) + cSeek )
							If !dbSeek( xFilial( cSeekAlias ) + cSeek ) .and. !dbSeek( cNewBranch + cSeek )
								If cSeekAlias <> 'FRV'
									If ValidaCadastro( nElem, cSeekAlias, cNewBranch, cSeek )
										RecLock( cSeekAlias, .T.)
										For nFields := 1 To Len( aModel[2] )
											aFields := aModel[2][ nFields ]
											If '_FILIAL' $ aFields[1]
												FieldPut( FieldPos( aFields[1] ), cNewBranch )
											else
												FieldPut( FieldPos( aFields[1] ), aFields[2] )
											EndIf
										Next
										MsUnLock()
									EndIf
								Else
									FTFWGrvFRV( { aElem[ ENT_CODE ], aElem[ ENT_STORE ], "2", "2", "2", "1", "2", "2" } )
								EndIf
							EndIf
						EndIf

						cLastBranch := xFilial( cSeekAlias )
						if cSeekAlias == 'FRV'
							cContent := aElem[ ENT_CODE ]
						Elseif cSeekAlias == 'SA6'
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ] + '|' + aElem[ ENT_DESC ]
						ELSE
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ]
						ENDIF
						cFindBranch := Space( nSizeFilial )

						If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cFindBranch .and. x[2] == aElem[ ENT_PARAMETER ] } ) == 0
							Aadd( aSX6, {  cFindBranch , aElem[ ENT_PARAMETER ], 'C', ;
								I18N( STR0044, { IIF( cSeekAlias == 'SA1', STR0045, IIF( cSeekAlias == 'SA2', STR0046, IIF( cSeekAlias == 'SA6', STR0047, STR0048 ) ) ) } ), ;
								'', cContent, cContent, cContent, 'S', 'S'} )   //"#1 utilizado para gerar contas a pagar para o parceiro Supplier."###'Cliente'###'Fornecedor'###'Banco'###'Situa��o'
						EndIf
					EndIf
				NEXT
			Else
				for nElem := 1 to 4
					aElem := aWizParam[ nElem ]

					cParameter := aElem[ ENT_PARAMETER ]
					cSeekAlias := aElem[ ENT_ALIAS ]
					cAuxBranch := xFilial( cSeekAlias )

					If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cAuxBranch  .and. x[ ENT_CODE ] == cParameter } ) == 0
						if cSeekAlias == 'FRV'
							cContent := aElem[ ENT_CODE ]
						Elseif cSeekAlias == 'SA6'
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ] + '|' + aElem[ ENT_DESC ]
						Else
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ]
						ENDIF

						Aadd( aSX6, { cAuxBranch , cParameter, 'C', ;
							i18N( STR0044, { IIF( nElem == 1, STR0045, IIF( nElem == 2, STR0046, IIF( nElem == 3, STR0047, STR0048 ) ) ) } ), ;
							'',  cContent, cContent, cContent, 'S', 'S' } )     //"#1 utilizado para gerar contas a pagar para o parceiro Supplier."###'Cliente'###'Fornecedor'###'Banco'###'Situa��o'
					ENDIF
				Next
			ENDIF
			// Associa o cliente ao fornecedor
			RSKRlCusXSup( aSX6 )
			// Grava os dados da natureza TOTVS Mais Neg�cios
			CreateNature( @aSX6 )

			cLastClient   := FwxFilial( "SA1", aSM0[ nEmp ][2], FWModeAccess('SA1',1), FWModeAccess('SA1',2), FWModeAccess('SA1',3))
			cLastProvider := FwxFilial( "SA2", aSM0[ nEmp ][2], FWModeAccess('SA2',1), FWModeAccess('SA2',2), FWModeAccess('SA2',3))
			cLastBank     := FwxFilial( "SA6", aSM0[ nEmp ][2], FWModeAccess('SA6',1), FWModeAccess('SA6',2), FWModeAccess('SA6',3))
			cLastBilling  := FwxFilial( "FRV", aSM0[ nEmp ][2], FWModeAccess('FRV',1), FWModeAccess('FRV',2), FWModeAccess('FRV',3))
			lExecute      := .T.

		ElseIf lExecute

			cLastClient   := ''
			cLastProvider := ''
			cLastBank     := ''
			cLastBilling  := ''

		EndIF

		aWizParam[ CLIENT ][ ENT_CODE ]   := cClientExec
		aWizParam[ PROVIDER ][ ENT_CODE ] := cProviderExec
		aWizParam[ BANK ][ ENT_CODE ]     := cBankExec
		aWizParam[ BILLING ][ ENT_CODE ]  := cBillingExec
		lUnique := .T.
	Next

	If Len(aWizParam) >= 6
		If aWizParam[ SCHEDULE ][ ESCOLHA_SCHEDULE ] == TEXT_MVRSKPLS_1
			cOpcSched := '1'
		ElseIf aWizParam[ SCHEDULE ][ ESCOLHA_SCHEDULE ] == TEXT_MVRSKPLS_2
			cOpcSched := '2'
		ElseIf aWizParam[ SCHEDULE ][ ESCOLHA_SCHEDULE ] == TEXT_MVRSKPLS_3
			cOpcSched := '3'
		EndIf

		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKSPLS', 'N', STR0060, STR0061, STR0062, cOpcSched, cOpcSched, cOpcSched, 'S', 'S' } )
	EndIf

	aItemsSX6 := ConsParameters( aSX6 )
	SaveParameters( aItemsSX6 )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aSX6 )
	FWFreeArray( aParam )
	FWFreeArray( aModel )
	FWFreeArray( aItemsSX6 )
	FWFreeArray( aWhere )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Esta fun��o � respons�vel por retornar os dados padr�es do par�metro (caso n�o esteja 
preenchido) ou os dados existentes no banco de dados.

@param nType, number, identifica qual a entidade est� sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situa��o de cobran�a
@param aArray, array, vetor com as informa��es da entidade

@return, array, cont�m os dados modelo para replicar nas outras empresas/filiais
    [1] - recno do registro
    [2] - vetor com as informa��es do registro.
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetModel( nType As Numeric , aArray As Array ) As Array
	Local aStru    As Array
	Local nFields  As Numeric
	Local nRecno   As Numeric
	Local aInfo    As Array
	Local aSvAlias As Array
	Local cField   As Character
	Local cAlias   As Character
	Local aWhere   As Array
	Local xContent

	aSvAlias := GetArea()
	nFields  := 0
	nRecno   := 0
	aInfo    := {}
	aSvAlias := {}
	cField   := ''
	cAlias   := aArray[ ENT_ALIAS ]
	aStru    := ( cAlias )->( DBStruct() )
	aWhere   := {}

	If nType == CLIENT
		aWhere := { { 'A1_FILIAL', aArray[ ENT_BRANCH ] }, { 'A1_COD', aArray[ ENT_CODE ] }, { 'A1_LOJA', aArray[ ENT_STORE ]} }
	ElseIf nType == PROVIDER
		aWhere := { { 'A2_FILIAL', aArray[ ENT_BRANCH ] }, { 'A2_COD', aArray[ ENT_CODE ] }, { 'A2_LOJA', aArray[ ENT_STORE ]} }
	ElseIf nType == BANK
		aWhere := { { 'A6_FILIAL', aArray[ ENT_BRANCH ] }, { 'A6_COD', aArray[ ENT_CODE ] }, { 'A6_AGENCIA', aArray[ ENT_STORE ]}, {'A6_NUMCON', aArray[ ENT_DESC ]} }
	ElseIf nType == BILLING
		aWhere := { { 'FRV_FILIAL', aArray[ ENT_BRANCH ] }, { 'FRV_CODIGO', aArray[ ENT_CODE ]} }
	EndIf

	nRecno := GetID( cAlias, aWhere )

	DBSelectArea( cAlias )
	DBGoto( nRecno )

	For nFields := 1 To Len( aStru )
		cField := aStru[ nFields ][1]
		xContent := ( cAlias )->( FieldGet( FieldPos( aStru[ nFields ][1] ) ) )
		IF !Empty( xContent ) .And. !( cField $ "USERLGI|USERLGA" )
			aAdd( aInfo, { cField, xContent }  )
		EndIf
	Next

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aStru )
Return { nRecno, aInfo }

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetID
Esta fun��o resgata o R_E_C_N_O_ do registro de acordo com a condi��o pesquisada.

@param cAlias, caracter, Alias da tabela a ser pesquisada
@param aWhere, array, vetor com os campos e condi��es do WHERE

@return, number, R_E_C_N_O_ do registro

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetID( cAlias As Character, aWhere As Array ) As Numeric
	Local aSvAlias 	 As Array
	Local cQuery 	 As Character
	Local cTempAlias As Character
	Local nItems 	 As Numeric
	Local nRecno 	 As Numeric

	aSvAlias   := GetArea()
	cQuery     := "SELECT R_E_C_N_O_ AS ID FROM " + RetSqlName( cAlias ) + " WHERE "
	cTempAlias := ''
	nItems     := 0
	nRecno     := 0

	For nItems := 1 To Len( aWhere )
		If nItems != 1
			cQuery += " AND "
		EndIf
		cQuery += aWhere[ nItems ][1] + " = '" + aWhere[ nItems ][2] + "' "
	Next
	cQuery += " AND D_E_L_E_T_ = ' '"

	cTempAlias := MPSysOpenQuery( cQuery )

	if ( cTempAlias )->( !EOF() )
		nRecno := ( cTempAlias )->ID
	EndIf

	( cTempAlias )->( DbCloseArea() )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
Return nRecno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRlCusXSup
Esta fun��o associa o fornecedor Suplier ao cliente Supplier de acordo com o conte�do
que ser� gravado no par�metro.

@param aSX6, array, vetor com os par�metros que ser�o gravados pelo Wizard.

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRlCusXSup( aSX6 As Array )
	Local aSvAlias        As Array
	Local aProvider       As Array
	Local aClient         As Array
	Local aWhere          As Array
	Local cBranchProvider As Character
	Local cBranchClient   As Character
	Local nProvider       As Numeric
	Local nClient         As Numeric
	Local nRecClient      As Numeric
	Local nRecProvider    As Numeric

	aSvAlias        := GetArea()
	aProvider       := {}
	aClient         := {}
	aWhere          := {}
	cBranchProvider := xFilial( "SA2" )
	cBranchClient   := xFilial( "SA1" )
	nProvider       := Ascan( aSX6, {|x| x[1] == cBranchProvider .And. x[2] == "MV_RSKFPAY" } )
	nClient         := 0
	nRecClient      := 0
	nRecProvider    := 0

	If nProvider == 0
		nProvider := Ascan( aSX6, {|x| Empty( x[1] ) .And. x[2] == "MV_RSKFPAY" } )
	EndIf

	If nProvider > 0
		nClient := Ascan( aSX6, {|x| x[1] == cBranchClient .And. x[2] == "MV_RSKCPAY" } )
		If nClient == 0
			nClient := Ascan( aSX6, {|x| Empty( x[1] ) .And. x[2] == "MV_RSKCPAY" } )
		EndIf

		aProvider := StrTokArr( aSX6[ nProvider ][7], '|' )
		If !Empty( aProvider )
			aWhere := { { 'A2_FILIAL', cBranchProvider }, { 'A2_COD', aProvider[1] }, { 'A2_LOJA', aProvider[2] } }
			nRecProvider := GetID( 'SA2', aWhere )

			If nRecProvider > 0
				SA2->( DbGoTo( nRecProvider) )
				aClient := StrTokArr( aSX6[ nClient ][7], '|' )
				If !Empty( aClient )
					aWhere := { { 'A1_FILIAL', cBranchClient }, { 'A1_COD', aClient[1] }, { 'A1_LOJA', aClient[2] } }
					nRecClient := GetID( 'SA1', aWhere )

					If nRecClient > 0
						RecLock("SA2", .F.)
						SA2->A2_CLIENTE := aClient[1]
						SA2->A2_LOJCLI  := aClient[2]
						MSUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aProvider )
	FWFreeArray( aClient )
	FWFreeArray( aWhere )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateNature
Esta fun��o � repons�vel por chamar a cria��o da natureza do TOTVS Mais Neg�cios 
na tabela SED via Wizard.

@param oStatus, object, Painel onde ser�o mostrados as etapas de grava��o.

@author  Marcia Junko
@since   04/12/2020
/*/
//-------------------------------------------------------------------------------------
Static Function CreateNature( aSX6 As Array )
	Local cMessage    As Character
	Local cContent    As Character
	Local cBranch     As Character
	Local nSizeBranch As Numeric

	cMessage    := ''
	cContent    := ''
	cBranch     := xFilial( "SED" )
	nSizeBranch := FWSizeFilial()

	cContent := RskSeekNature( INCOME_NATURE, @cMessage )
	If !Empty( cMessage )
		Help(Nil, Nil, "NONAT", "", STR0049, 1,,,,,,,)    //'A T E N � � O - Ocorreu um erro na grava��o da natureza de receita do TOTVS Mais Neg�cios.'
	EndIf
	cMessage := ''
	cContent := RskSeekNature( EXPENSE_NATURE, @cMessage )
	If !Empty( cMessage )
		Help(Nil, Nil, "NONAT", "", STR0050, 1,,,,,,,)    //'A T E N � � O - Ocorreu um erro na grava��o da natureza de despesa do TOTVS Mais Neg�cios.'
	EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConsParameters
Fun��o repons�vel por avaliar o conte�do dos par�metros para n�o gravar os par�metros
em duplicidade, caso o conte�do seja o mesmo para todas as filiais.

@param aListParameters, array, lista com os par�metros para validar o conte�do
@return array, lista de par�metros para gravar na SX6

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ConsParameters( aListParameters As Array ) As Array
	Local nItem    As Numeric
	Local aItems   As Array
	Local cParam   As Character
	Local cContent As Character
	Local nPos     As Numeric

	nItem    := 0
	aItems   := {}
	cParam   := ''
	cContent := ''
	nPos     := 0

	aSort( aListParameters, , , { |x,y| x[1] + x[2] < y[1] + y[2] } )
	For nItem := 1 to len( aListParameters )
		If ( nPos := Ascan( aItems, {|x| x[2] == aListParameters[ nItem ][2] }) ) == 0
			Aadd( aItems, aListParameters[ nItem ] )
		Else
			If aItems[ nPos ][7] != aListParameters[ nItem ][7]
				Aadd( aItems , aListParameters[ nItem ] )
			EndIf
		EndIf

		cParam := aListParameters[ nItem ][2]
		cContent := aListParameters[ nItem ][7]
	Next
Return aItems

//-------------------------------------------------------------------------------------
/*/
{Protheus.doc} SyncCarolSX6
Esta fun��o � respons�vel por sincronizar alguns par�metros do Protheus com a Carol.

@param aOffBalance, array, vetor com as informar��es de conex�o da plataforma

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SyncCarolSX6( aOffBalance As Array )
	Local aSvAlias       As Array
	Local aHeader        As Array
	Local oRestClient    As Object
	Local nSM0           As Numeric
	Local nParam         As Numeric
	Local nLenItem       As Numeric
	Local aJsonItem      As Array
	Local aSM0Data       As Array
	Local aParameters    As Array
	Local cPath          As Character
	Local cParameters    As Character
	Local cBranch        As Character
	Local cContent       As Character
	Local cCarolConnID   As Character
	Local cCarolAPIToken As Character
	Local cCarolURL      As Character

	aSvAlias       := GetArea()
	aHeader        := {}
	oRestClient    := Nil
	nSM0           := 0
	nParam         := 0
	nLenItem       := 0
	aJsonItem      := {}
	aSM0Data       := {}
	aParameters    := { "MV_RISCOB", "MV_RISCOC", "MV_RISCOD", "MV_PEDIDOA", "MV_PEDIDOB", "MV_PEDIDOC", "MV_RISKTIP", "MV_1DUP" }
	cParameters    := ''
	cBranch        := ''
	cContent       := ''
	cCarolURL      := AllTrim( aOFFBalance[ CAROL_URL ] )
	cCarolConnID   := AllTrim( aOFFBalance[ CAROL_CONNID ] )
	cCarolAPIToken := AllTrim( aOFFBalance[ CAROL_TOKEN ] )
	cPath          := "/v2/staging/intake/parameters?connectorId=" + cCarolConnID + "&returnData=false"

	AAdd( aHeader, "Content-Type: application/json" )
	AAdd( aHeader, "Accept: application/json" )
	AAdd( aHeader, "X-Auth-Key: "          + cCarolAPIToken )
	AAdd( aHeader, "X-Auth-ConnectorId: "  + cCarolConnID )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	aSM0Data    := FWLoadSM0()
	oJson       := JsonObject():New()

	DBSelectArea( "SX6" )
	DBSetOrder(1)
	For nSM0 := 1 To Len( aSM0Data )
		If aSM0Data[ nSM0 ][1] == cEmpAnt
			For nParam := 1 To Len( aParameters )
				cParameters := aParameters[ nParam ]

				AAdd( aJsonItem, JsonObject():New())
				nLenItem := Len( aJsonItem )

				If DBSeek( aSM0Data[ nSM0 ][2] + cParameters )
					cBranch  := aSM0Data[ nSM0 ][2]
					cContent := SuperGetMv( cParameters, .F., , cBranch )
				Else
					cBranch  := Space( FWSizeFilial() )
					cContent := SuperGetMv( cParameters , .F. )
				EndIf

				aJsonItem[ nLenItem ][ "protheus_pk" ] := cEmpAnt + "|" + cParameters
				aJsonItem[ nLenItem ][ "branch" ]      := cBranch
				aJsonItem[ nLenItem ][ "content" ]     := cContent
				aJsonItem[ nLenItem ][ "parameter" ]   := cParameters
			Next
		EndIf
	Next

	oJson:Set( aJsonItem )
	cJson := EncodeUTF8( oJson:ToJson() )

	oRestClient := FWRest():New( cCarolURL )
	oRestClient:SetPath( cPath )
	oRestClient:SetPostParams( cJson )

	If !oRestClient:Post( aHeader )
		Help(Nil, Nil, "NOPLAT", "", STR0051, 1,,,,,,,) //'A T E N � � O - Ocorreu erro no envio dos par�metros para a plataforma.'
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aHeader )
	FWFreeArray( aJsonItem )
	FWFreeArray( aSM0Data )
	FWFreeArray( aParameters )
	FreeObj( oRestClient )
	FreeObj( oJson )
Return

//-------------------------------------------------------------------------------------
/*/
{Protheus.doc} RskIncMOtBX
Inclui o motivo de baixa que ser� utilizado no +Negocios.

@return Logico, Verdadeiro se for inclu�do.
@author Squad NT TechFin
@since  08/09/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RskIncMOtBX() As Logical
	Local aSvAlias   As Array
	Local aCampos    As Array
	Local aMotBaixas As Array
	Local lRet       As Logical
	Local cFile	     As Character

	aSvAlias   := GetArea()
	aCampos    := {}
	aMotBaixas := {}
	lRet       := .T.
	cFile	   := "SIGAADV.MOT"

	// Executa a fun��o de leitura das baixas para for�ar a cria��o do arquivo, caso n�o exista.
	aMotBaixas := ReadMotBx()

	aCampos:={	{"SIGLA"	, "C", 03, 0 },;
		{"DESCR"	, "C", 10, 0 },;
		{"CARTEIRA"	, "C", 01, 0 },;
		{"MOVBANC"	, "C", 01, 0 },;
		{"COMIS"	, "C", 01, 0 },;
		{"CHEQUE"	, "C", 01, 0 },;
		{"ESPECIE"	, "C", 01, 0 }	}

	_oFINA4901 := FWTemporaryTable():New( "cArqTmp" )
	_oFINA4901:SetFields( aCampos )
	_oFINA4901:Create()

	cAlias := "cArqTmp"
	dbSelectArea( cAlias )

	APPEND FROM &cFile SDF
	dbGoTop()

	while CARQTMP->( !EOF() )
		if CARQTMP->SIGLA == 'OFF'
			lRet := .F.
			exit
		ENDIF

		CARQTMP->( dbSkip() )
	END

	IF ( lRet )

		lRet := .F.

		BEGIN TRANSACTION
			RecLock( cAlias , .T. )
			CARQTMP->Sigla    := "OFF"
			CARQTMP->Descr    := "+NEGOCIOS "
			CARQTMP->Carteira := "A"
			CARQTMP->MovBanC  := "N"
			CARQTMP->Comis    := "N"
			CARQTMP->Cheque   := "N"
			CARQTMP->Especie  := "N"
			MsUnLock()

			dbSelectArea( "cArqTmp" )
			FERASE( cFile )
			Copy to &cFile SDF

			lRet := .T.
		END TRANSACTION
	Endif

	RestArea( aSvAlias )

	FWFreeArray( aCampos )
	FWFreeArray( aSvAlias )
	FWFreeArray( aMotBaixas )
Return lRet

/*/
	{Protheus.doc} ValidaCadastro
	(long_description)
	@type  Static Function
	@author user
	@since 21/07/2022
	@version version
	@param nElem, Numeric, tipo de cadastro que ser� validado
	@param cSeekAlias, Character, alias do cadastro
	@param cNewBranch, Character, filial do cadastro
	@param cSeek, Character, �ndice do cadastro
	@param oStatus, Object, status do processamento
	@return lRetConsulta, Logical, retorna se a pesquisa encontrou o registro
/*/
Static Function ValidaCadastro( nElem As Numeric, cSeekAlias As Character, cNewBranch As Character, cSeek As Character ) As Logical

Local aCadOriginal As Array
Local aAreaBkp     As Array
Local cCamposPesq  As Character
Local cCnpjSup	   As Character
Local lRetConsulta As Logical
Local lValidOk	   As Logical

aCadOriginal := LoadParamInfo(nElem, .F.)
lRetConsulta := .F.
lValidOk	 := .F.
aAreaBkp     := ( cSeekAlias )->( GetArea() )

If nElem == 3
	If cSeek <> aCadOriginal[ ENT_CODE ] + aCadOriginal[ ENT_STORE ] + aCadOriginal[ ENT_DESC ]
		lValidOk := .T.
	EndIf
Else
	If cSeek <> aCadOriginal[ENT_CODE] + aCadOriginal[ENT_STORE]
		lValidOk := .T.
	EndIf
EndIf

If lValidOk
	If nElem == 1 .Or. nElem == 2
		cCamposPesq  := IIf( nElem == 1 ,'A1_COD+A1_LOJA', 'A2_COD+A2_LOJA')
		cCnpjSup	 := '06951711000128'
		DBSelectArea( cSeekAlias )	
		DbSetOrder(3)
		If ( cSeekAlias )->( MsSeek( xFilial( cSeekAlias ) + cCnpjSup ))
			Help(Nil, Nil, "VALIDA", "", I18N( STR0052, { cSeekAlias, ( cSeekAlias )->&(cCamposPesq) } ), 1,,,,,,,)  // " - A T E N � � O - TABELA #1 - CNPJ encontrado no Codigo/Loja - #2"
		Else
			Help(Nil, Nil, "VALIDA", "", I18N( STR0053, { cSeekAlias, cNewBranch } ), 1,,,,,,,) // " - A T E N � � O - TABELA #1 - Codigo n�o encontrado - FILIAL #2"
		EndIf
	Else
		Help(Nil, Nil, "VALIDA", "", I18N( STR0053, { cSeekAlias, cNewBranch } ), 1,,,,,,,) // " - A T E N � � O - TABELA #1 - Codigo n�o encontrado - FILIAL #2"
	EndIf
Else
	lRetConsulta := .T.
EndIf

RestArea(aAreaBkp)

FwFreeArray(aCadOriginal)
FwFreeArray(aAreaBkp)

Return lRetConsulta

/*/
	{Protheus.doc} MenuDef
	Menu funcional da rotina de cadastros (Cliente, Fornecedor e Banco)
	@type  Static Function
	@author Daniel Moda
	@since 19/07/2022
	@return aRotina, Array, Op��es do Menu
/*/
Static Function MenuDef() As Array

Local aRotina As Array

aRotina := {{"Selecionar" ,"Rsk110Sele",0, 6, 0, Nil},; //"Selecionar"
			{"Visualizar" ,"AxVisual" ,0, 2, 0, Nil}}  //"Visualizar"

Return aRotina

/*/
	{Protheus.doc} RskWizSel
	Bot�o chamado quando � selecionado um cadastro no Mbrowse
	@type  Function
	@author Daniel Moda
	@since 19/07/2022
	@return Nil
/*/
Function Rsk110Sele()

Local oBrowseCad As Object

oBrowseCad := GetObjBrow()

lAtuCad := .T.
oBrowseCad:oBrowse:oWnd:End()

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetOtherFlds
Fun��o respons�vel em atribuir um conte�do padr�o aos campos da enchoice que n�o est�o 
no array de controle.

@param nType, number, identifica qual a entidade est� sendo validada, onde:
    [1] - cliente
    [2] - fornecedor

@author  Marcia Junko
@since   05/10/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SetOtherFlds( nType As Numeric )
	Local aContent As Array
	Local cPrefix  As Character
	Local cField   As Character
	Local nItem    As Numeric

	aContent := {}
	cPrefix  := ''
	cField   := ''
	nItem    := 0

	// Nunca traduzir estes dados, pois s�o os dados de cadastro da Supplier
	aContent := { { 'CGC', '06951711000128' }, ;
		{ 'END', 'Av. Paulista, 1728' }, ;
		{ 'COMPLEM', '13� andar' }, ;
		{ 'COD_MUN', '50308' }, ;
		{ 'MUN', 'SAO PAULO' }, ;
		{ 'BAIRRO', 'Cerqueira Cesar' }, ;
		{ 'EST', 'SP' }, ;
		{ 'CEP', '01310200' }, ;
		{ 'TEL', '11 4081-4000' }, ;
		{ 'EMAIL', 'controladoria@supplier.com.br' }, ;
		{ 'PAIS', '105' } }

	If nType == CLIENT
		cPrefix := PrefixoCpo( 'SA1' )

		Aadd( aContent, { 'A1_PESSOA', 'J' } )
		Aadd( aContent, { 'A1_TIPO', 'F' } )
	Else
		cPrefix := PrefixoCpo( 'SA2' )

		Aadd( aContent, { 'A2_TIPO', 'J' } )
	EndIf

	For nItem := 1 to len( aContent )
		cField := aContent[ nItem ][1]

		IF !( cPrefix + '_' $ cField )
			cField := cPrefix + '_' + cField
		EndIf
		M->&( cField ) := aContent[ nItem ][2]
	Next

	FWFreeArray( aContent )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConnectComp
Fun��o auxliar para abertura do ambiente.

@param cCompany, caracter, empresa onde o ambiente ser� aberto
@param cBranch, caracter, filial onde o ambiente ser� aberto
@param cUser, caracter, nome do usu�rio
@param cPsw, caracter, senha

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ConnectComp( cCompany As Character, cBranch As Character ) As Logical
	Local lRet As Logical
	
	lRet := .T.

	SuperGetMV()
	RPCSetType( 3 )
	lRet := RpcSetEnv( cCompany, cBranch )
	oApp:cInternet := Nil
	__cInternet    := NIL
	lMsHelpAuto    := .F.

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkPlatAntecipa
Fun��o de valida��o das informa��es de conex�o com o Antencipa

@param @aOffBalance, array, vetor com as informar��es de conex�o da plataforma
@param @oAntecipa, object, objeto de valida��o da plataforma do Antecipa

@return boolean, informa se h� erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ChkPlatAntecipa( aOffBalance As Array, oAntecipa As Object ) As Logical
	Local lValid      As Logical
	Local aHeader     As Array
	Local aToken      As Array
	Local cBody       As Character
	Local cEndPoint   As Character
	Local cResult     As Character
	Local cClientID   As Character
	Local cSecret     As Character
	Local cPlatafCash As Character
	Local cTenant     As Character
	Local cMessage    As Character
	Local oConfig     As Object
	Local oJson       As Object
	Local oRest       As Object
	Local cPathRac    As Character

	lValid      := .F.
	aHeader     := {}
	aToken      := {}
	cBody       := ''
	cEndPoint   := ''
	cResult     := ''
	cClientID   := ''
	cSecret     := ''
	cPlatafCash := ''
	cTenant     := ''
	cMessage    := ''
	oConfig     := Nil
	oJson       := Nil
	oRest       := Nil
	cPathRac    := '/totvs.rac/connect/token'
	cClientID   := aOffBalance[ RISK_CLIENT_ID ]
	cSecret     := aOffBalance[ RISK_CLIENT_SECRET ]
	cPlatafCash := aOffBalance[ PLATFORM_URL_FMSCASH ]

	If __lRegistry
		cEndPoint := __oTFRegistry:oUrlTF["rac-token-V1"]
		cPathRac  := ""
	Else
		cEndPoint := RSKSetRacURL( oConfig, cPlatafCash )
	EndIf

	AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
	AAdd( aHeader, "charset: UTF-8" )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	cBody := "client_id=" + cClientId + "&"
	cBody += "client_secret=" + cSecret + "&"
	cBody += "grant_type=client_credentials&"
	cBody += "scope=authorization_api"

	oRest := FWRest():New( cEndPoint )
	oRest:setPath( cPathRac )
	oRest:SetPostParams( cBody )

	If oRest:Post( aHeader )
		cResult := oRest:GetResult()
		oJson := JsonObject():New()
		oJson:fromJson( cResult )

		aHeader := {}
		cResult := ''

		AAdd( aHeader, "Content-Type: application/json" )
		AAdd( aHeader, "Authorization: Bearer " + oJson[ "access_token" ] )
		AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

		oRest := FWRest():New( cPlatafCash )
		oRest:setPath( '/integration/api/v1/carol-accesses' )

		If oRest:Get( aHeader )
			cResult := oRest:GetResult()
			oAntecipa := JsonObject():New()
			oAntecipa:fromJson( cResult )

			cTenant := GetTokenInfo( oJson[ "access_token" ], "http://www.tnf.com/identity/claims/tenantId" )
			If !Empty( cTenant )
				aOffBalance[ TENANT ] := cTenant
			EndIf
			lValid := .T.
		EndIf
	EndIf

	If !lValid
		IF !Empty( oRest:GetHTTPCode() ) .And. oRest:GetHTTPCode() != "200"
			cMessage := CRLF + CRLF + STR0054 + oRest:GetLastError() + ' - ' + oRest:GetResult()  //'Status da requisi��o: '
		EndIf

		MsgStop( STR0055 + cMessage )  //"Informa��es de conex�o inv�lidas na plataforma Antecipa."
	EndIf

	FwFreeArray( aHeader )
	FwFreeArray( aToken )
	FreeObj( oJson )
	FreeObj( oRest )
Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkPlatRisk
Fun��o de valida��o das informa��es de conex�o com o Risk

@param @aOffBalance, array, vetor com as informar��es de conex�o da plataforma

@return boolean, informa se h� erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ChkPlatRisk( aOffBalance As Array ) As Logical
	Local lValid      As Logical
	Local aHeader     As Array
	Local aToken      As Array
	Local cBody       As Character
	Local cEndPoint   As Character
	Local cResult     As Character
	Local cClientID   As Character
	Local cSecret     As Character
	Local cPlatafRisk As Character
	Local cMessage    As Character
	Local oConfig     As Object
	Local oJson       As Object
	Local oRest       As Object
	Local cPathRac    As Character
	Local cPathTkt    As Character

	lValid      := .F.
	aHeader     := {}
	aToken      := {}
	cBody       := ''
	cEndPoint   := ''
	cResult     := ''
	cClientID   := ''
	cSecret     := ''
	cPlatafRisk := ''
	cMessage    := ''
	oConfig     := Nil
	oJson       := Nil
	oRest       := Nil
	cPathRac    := '/totvs.rac/connect/token'
	cPathTkt    := '/protheus-api/v1/credit_ticket'

	cClientID   := aOffBalance[ RISK_CLIENT_ID ]
	cSecret     := aOffBalance[ RISK_CLIENT_SECRET ]
	cPlatafRisk := aOffBalance[ PLATFORM_URL_RISK ]

	If __lRegistry
		cEndPoint   := __oTFRegistry:oUrlTF["rac-token-V1"]
		cPlatafRisk := __oTFRegistry:oUrlTF["risk-protheusapi-credit-ticket-V1"]
		cPathRac    := ""
		cPathTkt    := ""
	Else
		cEndPoint := RSKSetRacURL( oConfig, cPlatafRisk, 2 )
	EndIf

	AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
	AAdd( aHeader, "charset: UTF-8" )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	cBody := "client_id=" + cClientId + "&"
	cBody += "client_secret=" + cSecret + "&"
	cBody += "grant_type=client_credentials&"
	cBody += "scope=authorization_api"

	oRest := FWRest():New( cEndPoint )
	oRest:setPath( cPathRac )
	oRest:SetPostParams( cBody )

	If oRest:Post( aHeader )
		cResult := oRest:GetResult()
		oJson := JsonObject():New()
		oJson:fromJson( cResult )

		aHeader := {}
		cResult := ''

		AAdd( aHeader, "Content-Type: application/json" )
		AAdd( aHeader, "Authorization: Bearer " + oJson[ "access_token" ] )
		AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

		oRest := FWRest():New( cPlatafRisk )
		oRest:setPath( cPathTkt )

		If oRest:Get( aHeader )
			lValid := .T.
		EndIf
	EndIf

	If !lValid
		IF !Empty( oRest:GetHTTPCode() ) .And. oRest:GetHTTPCode() != "200"
			cMessage := CRLF + CRLF + STR0054 + oRest:GetLastError() + ' - ' + oRest:GetResult()  //'Status da requisi��o: '
		EndIf

		MsgStop( STR0056 + cMessage )      //"Informa��es de conex�o inv�lidas na plataforma Risk."
	EndIf

	FwFreeArray( aHeader )
	FwFreeArray( aToken )
	FreeObj( oJson )
	FreeObj( oRest )

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTokenInfo
Fun��o que retorna dados espec�ficos relacionados ao token

@param cToken, caracter, token
@param cInfo, caracter, propriedade a pesquisar

@return caracter, conte�do pesquisado
@author  Marcia Junko
@since   04/08/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetTokenInfo( cToken As Character, cInfo As Character ) As Character
	Local aToken   As Array
	Local cJson    As Character
	Local cResult  As Character
	Local oPayLoad As Object

	aToken   := {}
	cJson    := ''
	cResult  := ''
	oPayLoad := Nil

	oPayLoad := JsonObject():New()

	aToken := StrTokArr( cToken, "." )
	cJson := Decode64( aToken[ 2 ] )

	oPayLoad:fromJson( cJson )
	cResult := oPayLoad[ cInfo ]

	FWFreeArray( aToken )
	FreeObj( oPayLoad )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckCarol
Fun��o de valida��o das informa��es de conex�o com o Antencipa

@param @aOffBalance, array, vetor com as informar��es de conex�o da plataforma
@param oAntecipa, object, objeto de valida��o da plataforma do Antecipa

@return boolean, informa se h� erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function CheckCarol( aOffBalance As Array, cAPIToken As Character, cConnector As Character ) As Logical
	Local aHeader   As Array
	Local cResult   As Character
	Local cURL      As Character
	Local cEndpoint As Character
	Local cMessage  As Character
	Local lValid    As Logical
	Local oResponse As Object
	Local oRest     As Object

	Default cAPIToken  := ""
	Default cConnector := ""

	aHeader   := {}
	cResult   := ''
	cURL      := aOffBalance[ CAROL_URL ]
	cEndpoint := ''
	cMessage  := ''
	lValid    := .F.
	oResponse := Nil
	oRest     := Nil
	cEndpoint := "/v2/apiKey/details?connectorId=" + cConnector + "&apiKey=" + cAPIToken

	AAdd( aHeader, "X-Auth-Key: " + cAPIToken  )
	AAdd( aHeader, "X-Auth-ConnectorId: " + cConnector )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	oRest := FWRest():New( cURL )
	oRest:setPath( cEndPoint )

	If oRest:Get( aHeader )
		cResult := oRest:GetResult()
		oResponse := JsonObject():New()
		oResponse:fromJson( cResult )
		lValid := oResponse[ "connectorId" ] != Nil

		If lValid
			aOffBalance[ CAROL_CONNID ] := cConnector
			aOffBalance[ CAROL_TOKEN ] := cAPIToken
		EndIf
	Else
		IF !Empty( oRest:GetHTTPCode() ) .And. oRest:GetHTTPCode() != "200"
			cMessage := CRLF + CRLF + STR0054 + oRest:GetLastError() + ' - ' + oRest:GetResult()  //'Status da requisi��o: '
		EndIf

		MsgStop( STR0057 + cMessage )   //"Informa��es de conex�o inv�lidas na Carol."
	EndIf

	FwFreeArray( aHeader )
	FwFreeObj( oResponse )
	FwFreeObj( oRest )

Return lValid
