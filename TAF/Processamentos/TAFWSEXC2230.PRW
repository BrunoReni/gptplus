#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFWSEXC2230
@type			method
@description	Servi�o de elimina��o dos registros do evento de afastamento ( S-2230 ) do eSocial.
@author			Felipe C. Seolin
@since			06/11/2018
/*/
//---------------------------------------------------------------------
WSRESTFUL TAFWSEXC2230 DESCRIPTION "Servi�o de elimina��o dos registros do evento de afastamento ( S-2230 ) do eSocial" FORMAT APPLICATION_JSON

WSDATA sourceBranch AS STRING
WSDATA verifStatus3 AS BOOLEAN OPTIONAL

WSMETHOD GET	DESCRIPTION "M�todo para consultar o status do processamento da exclus�o dos registros do evento de afastamento do eSocial ( S-2230 )"	WSSYNTAX "/post/getStatus/"	PATH "/post/getStatus/"
WSMETHOD POST	DESCRIPTION "M�todo para executar a exclus�o dos registros do evento de afastamento do eSocial ( S-2230 )"

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	M�todo para executar a exclus�o dos registros do evento de afastamento do eSocial ( S-2230 ).
@author			Felipe C. Seolin
@since			06/11/2018
@return			lRet	-	Indica se o m�todo aceitou a execu��o do processo
/*/
//---------------------------------------------------------------------
WSMETHOD POST WSSERVICE TAFWSEXC2230

Local cFuncIPC		:=	""
Local cFuncREST		:=	"TAFDEL2230"
Local cChave		:=	"PROCDEL2230"
Local cUID			:=	"UIDPROCDEL2230"
Local cValorR		:=	"RESPPROCDEL2230"
Local cCodErr		:=	""
Local cDescErr		:=	""
Local cCodFilERP	:=	""
Local cFilTAF		:=	""
Local cBody			:=	::GetContent()
Local nVal			:=	0
Local lRet			:=	.T.

VarGetXD( cUID, cChave, @nVal )

If nVal == 1
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Existe um processamento em andamento. Aguarde o t�rmino para uma nova requisi��o." ) )
Else
	VarSetUID( cUID, .T. )

	If Empty( cBody )
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Requisi��o n�o possui par�metros no corpo da mensagem." ) )
	Else
		cCodFilERP := WSGetPostFil( cBody )

		If Empty( cCodFilERP )
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "N�o foi poss�vel identificar o par�metro sourceBranch no corpo da mensagem." ) )
		Else
			If WSST2ValFil( cCodFilERP, @cFuncIPC, @cCodErr, @cDescErr, .T., @cFilTAF )
				::Self:SetContentType( "application/json" )

				If TAFSCALLIPC( cFuncIPC, cFuncREST, cUID, cChave, cValorR, {}, cBody, cFilTAF )
					lRet := .T.
					::Self:SetResponse( SetMsgResp( "Requisi��o atendida, opera��o em processamento" ) )
				Else
					lRet := .F.
					SetRestFault( 408, EncodeUTF8( "Time Out." ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( cDescErr ) )
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	M�todo para consultar o status do processamento da exclus�o dos registros do evento de afastamento do eSocial ( S-2230 ).
@author			Felipe C. Seolin
@since			06/11/2018
@return			lRet	-	Indica se o m�todo aceitou a execu��o do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET WSSERVICE TAFWSEXC2230

Local cUID		:=	"UIDPROCDEL2230"
Local cChave	:=	"PROCDEL2230"
Local nVal 		:=	0
Local lRet		:= .T.

::SetContentType( "application/json" )

If Len( ::aURLParms ) > 1
	If ::aURLParms[2] == "getStatus"
		If VarGetXD( cUID, cChave, @nVal )
			If nVal == 1
				lRet := .T.
				::Self:SetResponse( SetMsgResp( "Processo de exclus�o em execu��o.", "2" ) )
			ElseIf nVal == 9
				lRet := .T.
				::Self:SetResponse( SetMsgResp( "Para que o processo seja executado, � necess�rio que o par�metro MV_TAF2230 esteja definido com valor .T.", "9" ) )
			Else
				lRet := .T.
				::Self:SetResponse( SetMsgResp( "Processo de exclus�o finalizado.", "0" ) )
			EndIf
		Else
			lRet := .T.
			::Self:SetResponse( SetMsgResp( "N�o ocorreu nenhuma execu��o do processo de exclus�o ap�s a inicializa��o do ambiente.", "9" ) )
		EndIf
	Else
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Par�metro inv�lido." ) )
	EndIf
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDEL2230
@type			function
@description	Rotina para gerar registros do evento S-3000 a partir dos registros do evento S-2230.
@author			Felipe C. Seolin
@since			02/10/2018
@param			cUID		-	Identificador da sess�o de vari�veis globais
@param			cChave		-	Identificador da chave ( Tabela X ) HashMap
@param			cValorR		-	Vari�vel onde ser� armazenado o valor da chave ( Tabela A )
@param			aQryParam	-	Par�metros de entrada do m�todo
@param			cBody		-	Mensagem enviada no corpo da mensagem
@param			cFilTAF		-	Filial do TAF
/*/
//---------------------------------------------------------------------
Function TAFDEL2230( cUID, cChave, cValorR, aQryParam, cBody, cFilTAF )

Local a3000			:=	{}
Local aDelete		:=	{}
Local aPendency		:=	{}
Local lVerifSts3	:=	.T.
Local lTrans2230	:=	.F.

Private oJson		:=	Nil

cFilAnt := cFilTAF

lTrans2230 := GetMV( "MV_TAF2230",, .F. )

If lTrans2230
	VarSetXD( cUID, cChave, 1 )

	If FWJsonDeserialize( cBody, @oJson )
		If Type( "oJson:verifStatus3" ) <> "U"
			lVerifSts3 := oJson:verifStatus3
		EndIf
	EndIf

	CheckTrans( @aPendency, lVerifSts3 )

	If !Empty( aPendency )
		MontaMsg( cUID, cChave, cValorR,,, aPendency )
	Else
		Begin Transaction
			CriaS3000( @a3000, @aDelete )
			MontaMsg( cUID, cChave, cValorR, a3000, aDelete )
		End Transaction
	EndIf
Else
	VarSetXD( cUID, cChave, 9 )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} CheckTrans
@type			function
@description	Verifica se h� registros do evento S-2230 aguardando retorno de transmiss�o ou inconsistentes.
@author			Felipe C. Seolin
@since			24/10/2018
@param			aPendency	-	Array com os eventos Inconsistentes ou Aguardando Retorno de Transmiss�o
@param			lVerifSts3	-	Indica se deve verificar exist�ncia de registros do evento de afastamento ( S-2230 ) com status de inconsist�ncia ( 3 )
/*/
//---------------------------------------------------------------------
Static Function CheckTrans( aPendency, lVerifSts3 )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""

cQuery := "SELECT CM6.CM6_FILIAL, CM6.CM6_ID, CM6.CM6_VERSAO, CM6.CM6_DTAFAS, CM6.CM6_DTFAFA, CM6.CM6_FUNC, C9V.C9V_CPF, C9V.C9V_NIS, CM6.CM6_STATUS "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "LEFT JOIN " + RetSqlName( "C9V" ) + " C9V "
cQuery += "  ON C9V.C9V_FILIAL = CM6.CM6_FILIAL "
cQuery += " AND C9V.C9V_ID = CM6.CM6_FUNC "
cQuery += " AND C9V.C9V_ATIVO = '1' "
cQuery += " AND C9V.D_E_L_E_T_ = '' "
cQuery += "WHERE CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
cQuery += "  AND ( CM6.CM6_STATUS = '2' "

If lVerifSts3
	cQuery += "        OR ( CM6.CM6_STATUS = '3' AND CM6.CM6_ATIVO = '1' ) "
EndIf

cQuery += "        OR ( CM6.CM6_STATUS = '4' AND CM6.CM6_PROTUL = '' ) "
cQuery += "      ) "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

TCSetField( cAliasQry, "CM6_DTAFAS", "D" )
TCSetField( cAliasQry, "CM6_DTFAFA", "D" )

While ( cAliasQry )->( !Eof() )
	aAdd( aPendency, { ( cAliasQry )->CM6_FILIAL, ( cAliasQry )->CM6_ID, ( cAliasQry )->CM6_VERSAO, DToC( ( cAliasQry )->CM6_DTAFAS ), DToC( ( cAliasQry )->CM6_DTFAFA ), ( cAliasQry )->CM6_FUNC, ( cAliasQry )->C9V_CPF, ( cAliasQry )->C9V_NIS, ( cAliasQry )->CM6_STATUS } )

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaS3000
@type			function
@description	Cria registros do evento S-3000 para os registros do evento S-2230 encontrados.
@author			Felipe C. Seolin
@since			02/10/2018
@param			a3000	-	Array com registros do evento S-3000 ( Refer�ncia )
@param			aDelete	-	Array com registros do evento S-2230 apagados ( Refer�ncia )
/*/
//---------------------------------------------------------------------
Static Function CriaS3000( a3000, aDelete )

Local oModelCM6		:=	Nil
Local oModelCMJ		:=	Nil
Local cAliasQry		:=	GetNextAlias()
Local cQuery		:=	""
Local lDeslig		:=	.F.
Local lRetif		:=	.F.

CM6->( DBSetOrder( 1 ) )

oModelCM6 := FWLoadModel( "TAFA261" )
oModelCMJ := FWLoadModel( "TAFA269" )

cQuery := "SELECT CM6.R_E_C_N_O_ CM6_RECONHECIMENTO, CMJ.CMJ_NRRECI "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "LEFT JOIN " + RetSqlName( "CMJ" ) + " CMJ "
cQuery += "  ON CMJ.CMJ_FILIAL = CM6.CM6_FILIAL "
cQuery += " AND CMJ.CMJ_TPEVEN = '" + Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2230", "C8E_ID" ) + "' "
cQuery += " AND CMJ.CMJ_NRRECI = CM6.CM6_PROTUL "
cQuery += " AND CMJ.D_E_L_E_T_ = '' "
cQuery += "WHERE CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
cQuery += "  AND CM6.D_E_L_E_T_ = '' "
cQuery += "ORDER BY CM6.R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

( cAliasQry )->( DBGoTop() )

While ( cAliasQry )->( !Eof() )
	CM6->( DBGoTo( ( cAliasQry )->CM6_RECONHECIMENTO ) )

	If TAFChkDesl( CM6->CM6_FUNC )
		lDeslig := .T.
	Else
		lDeslig := .F.
	EndIf

	If TAFChkRetif( CM6->CM6_FUNC, CM6->CM6_PROTUL )
		lRetif := .T.
	Else
		lRetif := .F.
	EndIf

	If !lDeslig .and. !lRetif
		C9V->( DBSetOrder( 2 ) )
		C9V->( MsSeek( xFilial( "C9V" ) + CM6->CM6_FUNC + "1" ) )

		If CM6->CM6_STATUS == "4" .and. Empty( ( cAliasQry )->CMJ_NRRECI ) .and. CM6->CM6_EVENTO <> "E"
			GeraCMJ( @oModelCMJ, @a3000 )
		EndIf

		aAdd( aDelete, { CM6->CM6_FILIAL, CM6->CM6_ID, CM6->CM6_VERSAO, DToC( CM6->CM6_DTAFAS ), DToC( CM6->CM6_DTFAFA ), CM6->CM6_FUNC, C9V->C9V_CPF, C9V->C9V_NIS } )

		oModelCM6:SetOperation( MODEL_OPERATION_DELETE )
		oModelCM6:Activate()
		FWFormCommit( oModelCM6 )
		oModelCM6:DeActivate()
	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

oModelCM6:Destroy()
oModelCMJ:Destroy()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraCMJ
@type			function
@description	Gera o registro no modelo da tabela CMJ, referente ao Evento S-3000.
@author			Felipe C. Seolin
@since			02/10/2018
@param			oModelCMJ	-	Objeto do modelo da tabela CMJ - Evento S-3000 ( Refer�ncia )
@param			a3000		-	Array com registros do evento S-3000 ( Refer�ncia )
/*/
//---------------------------------------------------------------------
Static Function GeraCMJ( oModelCMJ, a3000 )

Local cNIS		:=	""
Local cDTAfast	:=	DToS( CM6->CM6_DTAFAS )

oModelCMJ:SetOperation( MODEL_OPERATION_INSERT )
oModelCMJ:Activate()

cNIS := TAF250Nis( C9V->C9V_FILIAL, C9V->C9V_ID, C9V->C9V_NIS, SubStr( cDTAfast, 1, 4 ) + "/" + SubStr( cDTAfast, 5, 2 ), C9V->C9V_NOMEVE )

oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_VERSAO", xFunGetVer() )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_TPEVEN", Posicione( "C8E", 2, xFilial( "C8E" ) + "S-2230", "C8E_ID" ) )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_CPF", C9V->C9V_CPF )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_NIS", cNIS )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_REGREF", CM6->( Recno() ) )
oModelCMJ:LoadValue( "MODEL_CMJ", "CMJ_NRRECI", CM6->CM6_PROTUL )

FWFormCommit( oModelCMJ )

aAdd( a3000, { cFilAnt, oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_ID" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_VERSAO" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_TPEVEN" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_CPF" ), oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_NIS" ) ,oModelCMJ:GetModel( "MODEL_CMJ" ):GetValue( "CMJ_NRRECI" ) } )

oModelCMJ:DeActivate()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TafChkDesl
@type			function
@description	Verifica se o trabalhador est� desligado.
@author			Diego Rodolfo dos Santos
@since			09/10/2018
@param			cIDFunc	-	ID do Trabalhador
@return			lRet	-	Indica se o trabalhador est� desligado
/*/
//---------------------------------------------------------------------
Static Function TAFChkDesl( cIDFunc )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""
Local aArea		:=	GetArea()
Local lRet		:=	.F.

cQuery := "SELECT CMD.CMD_STATUS "
cQuery += "FROM " + RetSqlName( "CMD" ) + " CMD "
cQuery += "WHERE CMD.CMD_FILIAL = '" + xFilial( "CMD" ) + "' "
cQuery += "  AND CMD.CMD_FUNC = '" + cIDFunc + "' "
cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY CMD.R_E_C_N_O_ "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

While ( cAliasQry )->( !Eof() )
	If AllTrim( ( cAliasQry )->CMD_STATUS ) == "4"
		lRet := .T.
	ElseIf AllTrim( ( cAliasQry )->CMD_STATUS ) == "7"
		lRet := .F.
	EndIf
	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

RestArea( aArea )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFChkRetif
@type			function
@description	Verifica se o registro do evento de afastamento do eSocial ( S-2230 ) sofreu retifica��o.
@author			Felipe C. Seolin
@since			28/11/2018
@param			cIDFunc	-	ID do Trabalhador
@param			cRecibo	-	Recibo do registro do evento de afastamento
@return			lRet	-	Indica se o registro do evento de afastamento sofreu retifica��o
/*/
//---------------------------------------------------------------------
Static Function TAFChkRetif( cIDFunc, cRecibo )

Local cAliasQry	:=	GetNextAlias()
Local cQuery	:=	""
Local lRet		:=	.F.

cQuery := "SELECT CM6.CM6_ID "
cQuery += "FROM " + RetSqlName( "CM6" ) + " CM6 "
cQuery += "WHERE CM6.CM6_FILIAL = '" + xFilial( "CM6" ) + "' "
cQuery += "  AND CM6.CM6_FUNC = '" + cIDFunc + "' "
cQuery += "  AND CM6.CM6_PROTPN = '" + cRecibo + "' "
cQuery += "  AND CM6.CM6_STATUS = '4' "
cQuery += "  AND CM6.CM6_EVENTO = 'R' "

cQuery := ChangeQuery( cQuery )

DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry, .F., .T. )

If ( cAliasQry )->( !Eof() )
	lRet := .T.
EndIf

( cAliasQry )->( DBCloseArea() )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} MontaMsg
@type			function
@description	Monta mensagem de diverg�ncias encontradas.
@author			Felipe C. Seolin
@since			02/10/2018
@param			cUID		-	Identificador da sess�o de vari�veis globais
@param			cChave		-	Identificador da chave ( Tabela X ) HashMap
@param			cValorR		-	Vari�vel onde ser� armazenado o valor da chave ( Tabela A )
@param			a3000		-	Array com registros do evento S-3000
@param			aDelete		-	Array com registros do evento S-2230 apagados
@param			aPendency	-	Array com os eventos Inconsistentes ou Aguardando Retorno de Transmiss�o
@return			aMessage	-	Array com a mensagem formatada para exibi��o dos registros do evento S-3000 gerados
/*/
//---------------------------------------------------------------------
Static Function MontaMsg( cUID, cChave, cValorR, a3000, aDelete, aPendency )

Local cStatus		:=	""
Local cEncode		:=	""
Local aMessage		:=	{}
Local aEncode		:=	{}
Local lCabecSts2	:=	.T.
Local lCabecSts3	:=	.T.
Local lCabecSts4	:=	.T.
Local nI			:=	0

Default a3000		:=	{}
Default aDelete		:=	{}
Default aPendency	:=	{}

If !Empty( a3000 ) .or. !Empty( aDelete )
	aAdd( aMessage, '"status": "0"' )
ElseIf Empty( a3000 ) .and. Empty( aDelete ) .and. Empty( aPendency )
	aAdd( aMessage, '"status": "3"' )
Else
	aAdd( aMessage, '"status": "1"' )
EndIf

aAdd( aMessage, '"lastExecution" : "' )

If !Empty( a3000 )
	aAdd( aEncode, "Eventos S-3000 criados automaticamente:" )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

	For nI := 1 to Len( a3000 )
		aAdd( aEncode, "Filial: '" + AllTrim( a3000[nI,1] ) + "' - " )
		aAdd( aEncode, "ID: '" + AllTrim( a3000[nI,2] ) + "' - " )
		aAdd( aEncode, "Vers�o: '" + AllTrim( a3000[nI,3] ) + "' - " )
		aAdd( aEncode, "Tipo Evento: '" + AllTrim( a3000[nI,4] ) + "' - " )
		aAdd( aEncode, "CPF: '" + AllTrim( a3000[nI,5] ) + "' - " )
		aAdd( aEncode, "NIS: '" + AllTrim( a3000[nI,6] ) + "' - " )
		aAdd( aEncode, "Recibo: '" + AllTrim( a3000[nI,7] ) + "' " )
		aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	Next nI

	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
EndIf

If !Empty( aDelete )
	aAdd( aEncode, "Eventos S-2230 apagados logicamente devido a n�o existir transmiss�o do registro ao governo:" )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

	For nI := 1 to Len( aDelete )
		aAdd( aEncode, "Filial: '" + AllTrim( aDelete[nI,1] ) + "' - " )
		aAdd( aEncode, "ID: '" + AllTrim( aDelete[nI,2] ) + "' - " )
		aAdd( aEncode, "Vers�o: '" + AllTrim( aDelete[nI,3] ) + "' - " )
		aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aDelete[nI,4] ) + "' - " )
		aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aDelete[nI,5] ) + "' - " )
		aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aDelete[nI,6] ) + "' - " )
		aAdd( aEncode, "CPF: '" + AllTrim( aDelete[nI,7] ) + "' - " )
		aAdd( aEncode, "NIS: '" + AllTrim( aDelete[nI,8] ) + "' " )
		aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
	Next nI
EndIf

If !Empty( aPendency )
	aSort( aPendency,,, { |x,y| x[9] < y[9] } )

	For nI := 1 to Len( aPendency )
		If nI > 1 .and. cStatus <> aPendency[nI,9]
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		EndIf

		cStatus := aPendency[nI,9]

		If cStatus == "2"
			If lCabecSts2
				aAdd( aEncode, "Eventos aguardando retorno de transmiss�o ( Necess�rio reconsultar por meio do Monitor de Transmiss�o do eSocial ):" )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

				lCabecSts2 := .F.
			EndIf

			aAdd( aEncode, "Filial: '" + AllTrim( aPendency[nI,1] ) + "' - " )
			aAdd( aEncode, "ID: '" + AllTrim( aPendency[nI,2] ) + "' - " )
			aAdd( aEncode, "Vers�o: '" + AllTrim( aPendency[nI,3] ) + "' - " )
			aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aPendency[nI,4] ) + "' - " )
			aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aPendency[nI,5] ) + "' - " )
			aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aPendency[nI,6] ) + "' - " )
			aAdd( aEncode, "CPF: '" + AllTrim( aPendency[nI,7] ) + "' - " )
			aAdd( aEncode, "NIS: '" + AllTrim( aPendency[nI,8] ) + "' " )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		ElseIf cStatus = "3"
			If lCabecSts3
				aAdd( aEncode, "Eventos com inconsist�ncias a serem avaliadas ( Necess�rio avaliar e sanar a inconsist�ncia ):" )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

				lCabecSts3 := .F.
			EndIf

			aAdd( aEncode, "Filial: '" + AllTrim( aPendency[nI,1] ) + "' - " )
			aAdd( aEncode, "ID: '" + AllTrim( aPendency[nI,2] ) + "' - " )
			aAdd( aEncode, "Vers�o: '" + AllTrim( aPendency[nI,3] ) + "' - " )
			aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aPendency[nI,4] ) + "' - " )
			aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aPendency[nI,5] ) + "' - " )
			aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aPendency[nI,6] ) + "' - " )
			aAdd( aEncode, "CPF: '" + AllTrim( aPendency[nI,7] ) + "' - " )
			aAdd( aEncode, "NIS: '" + AllTrim( aPendency[nI,8] ) + "' " )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		ElseIf cStatus = "4"
			If lCabecSts4
				aAdd( aEncode, "Eventos consistentes mas que n�o possuem o recibo gravado ( Necess�rio aplicar o Ajuste de Recibo ):" )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
				aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )

				lCabecSts4 := .F.
			EndIf

			aAdd( aEncode, "Filial: '" + AllTrim( aPendency[nI,1] ) + "' - " )
			aAdd( aEncode, "ID: '" + AllTrim( aPendency[nI,2] ) + "' - " )
			aAdd( aEncode, "Vers�o: '" + AllTrim( aPendency[nI,3] ) + "' - " )
			aAdd( aEncode, "Data do Afastamento: '" + AllTrim( aPendency[nI,4] ) + "' - " )
			aAdd( aEncode, "Data do Fim do Afastamento: '" + AllTrim( aPendency[nI,5] ) + "' - " )
			aAdd( aEncode, "ID Trabalhador: '" + AllTrim( aPendency[nI,6] ) + "' - " )
			aAdd( aEncode, "CPF: '" + AllTrim( aPendency[nI,7] ) + "' - " )
			aAdd( aEncode, "NIS: '" + AllTrim( aPendency[nI,8] ) + "' " )
			aAdd( aEncode, Chr( 13 ) + Chr( 10 ) )
		EndIf
	Next nI
EndIf

If Empty( a3000 ) .and. Empty( aDelete ) .and. Empty( aPendency )
	aAdd( aEncode, "N�o foram localizados eventos para exclus�o" )
EndIf

For nI := 1 to Len( aEncode )
	cEncode += aEncode[nI]
Next nI

aAdd( aMessage, Encode64( EncodeUTF8( cEncode ) ) )
aAdd( aMessage, '"' )
aAdd( aMessage, ',' )
aAdd( aMessage, Chr( 13 ) + Chr( 10 ) )
aAdd( aMessage, '"date" : "' + DToC( Date() ) + '"' )
aAdd( aMessage, ',' )
aAdd( aMessage, Chr( 13 ) + Chr( 10 ) )
aAdd( aMessage, '"time" : "' + Time() + '"' )

VarInfo( "aMessage", aMessage )

TAFFinishWS( cChave, cUID, cValorR, aMessage, 3 )

Return( aMessage )

//---------------------------------------------------------------------
/*/{Protheus.doc} SetMsgResp
@type			function
@description	Formata a mensagem no padr�o Json.
@author			Felipe C. Seolin
@since			06/11/2018
@param			cMessage	-	Descri��o da execu��o
@param			cStatus		-	Status da opera��o:
									0 - Exclus�o Finalizada
									1 - Exclus�o em Andamento
									9 - Exclus�o n�o executada nenhuma vez antes da chamada do m�todo GET
@return			cResponse	-	Resposta formatada no padr�o Json
/*/
//---------------------------------------------------------------------
Static Function SetMsgResp( cMessage, cStatus )

Local cResponse	:=	""
Local cUID		:=	"UIDPROCDEL2230"
Local cValorR	:=	"RESPPROCDEL2230"
Local cComp		:=	""
Local nI		:=	0
Local aRetorno	:=	{}
Local lVirgula	:=	.F.

Default cMessage	:=	""
Default cStatus		:=	""

If cStatus == "0"
	If VarGetAD( cUID, cValorR, @aRetorno )
		If !Empty( aRetorno )
			cComp += ','
			For nI := 1 to Len( aRetorno )
				If nI == 1
					If aRetorno[nI] == '"status": "0"'
						cStatus := "0"
					ElseIf aRetorno[nI] == '"status": "1"'
						cStatus := "1"
					ElseIf aRetorno[nI] == '"status": "3"'
						cStatus := "3"
					EndIf
				Else
					cComp += aRetorno[nI]
				EndIf
			Next nI
			aSize( aRetorno, 0 )
		EndIf
	EndIf
EndIf

cResponse := '{'

If !Empty( cStatus )
	cResponse += '"status" : "' + cStatus + '"'
	lVirgula := .T.
EndIf

If lVirgula
	cResponse += ','
EndIf
cResponse += '"description" : "' + EncodeUTF8( cMessage ) + '"'

If !Empty( cComp )
	cResponse += cComp
EndIf

cResponse += '}'

Return( cResponse )