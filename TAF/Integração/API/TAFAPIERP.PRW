#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFAPIERP.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPIERP

Disponibiliza servi�o para executar integra��o de informa��es com o TAF.

@Param		cEscopo	-	1 = Fiscal
						2 = eSocial
						3 = ECF

@Author	Felipe C. Seolin
@Since		15/02/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFAPIERP( cEscopo, lAutomato, lMthr )

Local oProcess	as object

Default cEscopo	:=	"1"
Default lAutomato	:= .F.
Default lMthr	    :=	.F.

oProcess	:=	Nil

If !lAutomato
	oProcess := TAFProgress():New( { || ProcUnif( @oProcess,, lMthr, cEscopo ) }, STR0001 ) //"Processando Integra��o"
	oProcess:Activate()
Else
	ProcUnif( @oProcess, lAutomato, lMthr,cEscopo )
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ProcUnif

Rotina que unifica o processo de integra��o com o TAF.

@Param		oProcess - Objeto de r�gua de processamento

@Author	Felipe C. Seolin
@Since		15/02/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ProcUnif( oProcess, lAutomato, lMthr, cEscopo )

Local lOk			:=	.T.

Default lAutomato	:=	.F.
Default lMthr	    :=	.T.
Default cEscopo		:=	"1"

lOk	:=	.T.

//Tratamento para corre��o na grava��o da variavel cEscopo, que esta invertida na chamada da fun��o TAFAINTEG()
// 1-Fiscal, 2-ECF, 3-eSocial e 9-Todos
If cEscopo == '3'
	cEscopo := '2'
ElseIf cEscopo == '2'
	cEscopo := '3'
EndIf

If !lAutomato

	oProcess:Set1Progress( 5 )
	
	oProcess:Inc1Progress( STR0004 ) //"Preparando transfer�ncia de dados..."
		
	TAFAInteg( , 0,, @lOk, .T., @oProcess, cEscopo , lMThr )
Else
	TAFAInteg( aPar, 0, , @lOk, .F., @oProcess, cEscopo , lMThr )
EndIf

If lOk

	If !lAutomato

		oProcess:Inc1Progress( STR0005 ) //"Transfer�ncia de dados ao TAF finalizada..."
	
		oProcess:Set2Progress( 7 )
	
		oProcess:Inc2Progress( STR0006 ) //"Preparando integra��o de dados..."
		TAFAInteg( , 2,, @lOk, .T., @oProcess, cEscopo , lMThr )
	
		If lOk
			oProcess:Inc2Progress( STR0007 ) //"Integra��o de dados aos cadastros do TAF finalizada..."
	
			If FindFunction("ProtData")
				If ProtData(.F.)
					If Aviso( STR0008, STR0009, { STR0010, STR0011 }, 2 ) == 1 //##"Monitor de Integra��o" ##"Integra��o finalizada, deseja visualizar o monitor de integra��o?" ##"Sim" ##"N�o"
						TAFTicket( .T. )
					EndIf
				Else
					MsgAlert(STR0020, STR0021)
				EndIf
			Else
				If Aviso( STR0008, STR0009, { STR0010, STR0011 }, 2 ) == 1 //##"Monitor de Integra��o" ##"Integra��o finalizada, deseja visualizar o monitor de integra��o?" ##"Sim" ##"N�o"
					TAFTicket( .T. )
				EndIf
			EndIf
		Else
			oProcess:Inc2Progress( STR0012 ) //"Falha na integra��o de dados..."
			Aviso( STR0013, STR0012, { STR0014 } ) //##"Aten��o!" ##"Falha na integra��o de dados..." ##"Sair"
		EndIf

	Else

		TAFAInteg( aPar, 2, , @lOk, .F., @oProcess, cEscopo , lMThr )
	
	EndIf
Else
	
	If !lAutomato
		oProcess:Inc1Progress( STR0015 ) //"Falha na transfer�ncia de dados..."
		Aviso( STR0013, STR0015, { STR0014 } ) //##"Aten��o!" ##"Falha na transfer�ncia de dados..." ##"Sair"
	EndIf

EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDelTicket

Disponibiliza servi�o para excluir Tickets de integra��o com o TAF.

@Param		aTicket	- Array com os Tickets a serem exclu�dos
			lJob		- Indica execu��o via Job
			lMsgEmp 	- Indica que deve ser exibido Mensagem informando
						  a existencia do registro S-1000.

@Author	Felipe C. Seolin
@Since		20/12/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFDelTicket( aTicket, lJob, lMsgEmp )

Local cAliasQry		as character
Local cQuery		as character
Local cAlias		as character
Local cLayout		as character
Local cEscopo		as character
Local cMsg			as character
Local cSqlTafKey 	as character
Local nRecno		as numeric
Local nI			as numeric
Local nX			as numeric
Local aInfo			as array
Local aRegExc		as array
Local aCU0			as array
Local aTafKeys		as array
Local aTafKeysExc	as array
Local lEnd			as logical
Local lVirgula		as logical
Local lRegEmp		as logical
Local lAcesso		as logical
Local nQtdTafKey 	as numeric

Local cRotinaModelo as character

Default aTicket	:=	{}
Default lJob		:=	.F.
Default lMsgEmp	:= .F.

cRotinaModelo := ""

cQuery		:=	""
cAlias		:=	""
cLayout		:=	""
cEscopo		:=	""
cSqlTafKey	:=	""
cMsg 		:= 	""
nRecno		:=	0
nI			:=	0
nX			:=	0
aInfo		:=	{}
aRegExc		:=	{}
aCU0		:=	{}
aTafKeys	:=	{}
aTafKeysExc :=  {}
lEnd		:=	.F.
lVirgula	:= 	.F.
lRegEmp		:=	.F.
lAcesso		:=  .T.
nQtdTafKey 	:= 	0

For nI := 1 to Len( aTicket )

	cAliasQry	:=	GetNextAlias()

	cQuery := " SELECT DISTINCT "
	cQuery += " XERP.TAFALIAS TAFALIAS"
	cQuery += " ,XERP.TAFRECNO TAFRECNO"
	cQuery += " ,XERP.TAFKEY TAFKEY"
	cQuery += " ,ST2.TAFTPREG LAYOUT"
	cQuery += " FROM TAFXERP XERP"
	cQuery += " LEFT JOIN TAFST2 ST2"
	cQuery += " ON XERP.TAFKEY = ST2.TAFKEY"
	cQuery += " AND XERP.TAFTICKET = ST2.TAFTICKET"
	cQuery += " WHERE XERP.TAFTICKET = '" + aTicket[nI] + "' "
	cQuery += " AND XERP.TAFSTATUS IN ( '1', '2', '3', '4', '7', '9' ) " //Incluido exclus�o de status '3', '4', '7' e '9' para permitir que o cliente opte em ter ou n�o o ticket
	cQuery += " AND XERP.D_E_L_E_T_ <> '*'"
	cQuery += " AND ST2.D_E_L_E_T_ <> '*'"

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cAliasQry )
	
	While ( cAliasQry )->( !Eof() )

		cAlias  := ( cAliasQry )->TAFALIAS
		nRecno  := ( cAliasQry )->TAFRECNO
		cLayout := AllTrim((cAliasQry)->LAYOUT)
		
		//Verifico se o usu�rio corrente tem acesso a rotina
		If ProcName() != "TAFDELTICKET".And. !(FPerAcess(,cLayout,,,,lJob))
			lAcesso := .F.
			EXIT
		EndIf
		
		aInfo := TAFRotinas(cLayout, 4, .F., 0 )
		cEscopo := aInfo[5]

		If Len(aInfo) > 0
			cRotinaModelo	:= aInfo[1]
		EndIf

		If cAlias == "C1E"
			lRegEmp := .T.
			aAdd(aTafKeys,(cAliasQry)->TAFKEY)
		Else
		
			If nRecno <> 0  
				( cAlias )->( DBGoTo( nRecno ) )
				If TAFColumnPos( cAlias + "_STATUS")
					If !( cAlias )-> &(cAlias + "_STATUS") $ '2|4|6' //S� posso excluir registros que n�o foram transmitidos
						aAdd( aRegExc, { cLayout, cAlias, nRecno, cEscopo, cRotinaModelo } )
						aAdd( aCU0, { cAlias, nRecno } )
						aAdd(aTafKeysExc,(cAliasQry)->TAFKEY) //Indica quais tafkeys ser�o excluidos da tafst2
					EndIf
				Else
					aAdd( aRegExc, { cLayout, cAlias, nRecno, cEscopo, cRotinaModelo } )
					aAdd( aCU0, { cAlias, nRecno } )
					aAdd(aTafKeysExc,(cAliasQry)->TAFKEY) //Indica quais tafkeys ser�o excluidos da tafst2
				EndIf
			Else
				aAdd(aTafKeysExc,(cAliasQry)->TAFKEY) //Exclui Tafkeys de eventos que nem existem na base
			EndIf
			
		EndIf

		( cAliasQry )->( DBSkip() )
	EndDo
	
	//Se encontrado algum registro sem permiss�o de acesso, eu saio do la�o
	If !lAcesso
		EXIT
	EndIf

	If !Empty( aRegExc )
		If lJob
			 TAFExcReg2(,,aRegExc,lJob )
		Else
			oProcess := TAFProgress():New( { |lEnd| TAFExcReg2( @lEnd, @oProcess, aRegExc,, lJob ) }, STR0016 ) //"Excluindo Informa��es"
			oProcess:Activate()
		EndIf

		GravaCU0( 3, aCU0, .T., lJob )
	EndIf
	
	If Len(aTafKeys) > 0
		cSqlTafKey += " AND TAFKEY NOT IN ("
	EndIf
	
	For nX := 1 To Len(aTafKeys) 
		IIf (lVirgula,cSqlTafKey += ",",lVirgula := .T.)
		cSqlTafKey += "'"+rTrim(aTafKeys[nX])+"'"
	Next nX
	
	If Len(aTafKeys) > 0
		cSqlTafKey += ")"
	EndIf
	
	If Len(aTafKeysExc) > 0
		cSqlTafKey += " AND TAFKEY IN ("
	EndIf
	lVirgula := .F.
	For nX := 1 To Len(aTafKeysExc) 
		IIf (lVirgula,cSqlTafKey += ",",lVirgula := .T.)
		cSqlTafKey += "'"+rTrim(aTafKeysExc[nX])+"'"
		
		If nQtdTafKey == 30 //Se tiver mais de 30 tafkeys ele executa o delete para n�o ter problema de estourar o tamanho da string
			cSqlTafKey += ")"
			
			TCSQLExec( "DELETE FROM TAFST2 WHERE TAFTICKET = '"  + aTicket[nI] + "'" + cSqlTafKey)
			TCSQLExec( "DELETE FROM TAFXERP WHERE TAFTICKET = '" + aTicket[nI] + "'" + cSqlTafKey)
			
			cSqlTafKey := " AND TAFKEY IN ("
			nQtdTafKey := 0
			lVirgula   := .F.
		EndIf
		
		nQtdTafKey++
	Next nX
	
	If Len(aTafKeysExc) > 0 .and. !Empty(cSqlTafKey)
		cSqlTafKey += ")"
	EndIf
	
	If Len(aTafKeys) > 0 .or. Len(aTafKeysExc) > 0	.and. !Empty(cSqlTafKey) .and. !("()" $ cSqlTafKey)
		TCSQLExec( "DELETE FROM TAFST2 WHERE TAFTICKET = '"  + aTicket[nI] + "'" + cSqlTafKey)
		TCSQLExec( "DELETE FROM TAFXERP WHERE TAFTICKET = '" + aTicket[nI] + "'" + cSqlTafKey)
	EndIf	
	
	cSqlTafKey  := ""
	lLayEmp 	:= .F.
	aTafKeys 	:= {}
	aTafKeysExc	:= {}
	( cAliasQry )->( DBCloseArea() )

Next nI

If lAcesso .And. !lJob .And. lRegEmp
	cMsg := STR0018 //"N�o � permitido a exclus�o de registros de complemento de empresa."
	If Len(aRegExc) > 0
		cMsg += STR0019 //"Os demais registros foram excluidos com sucesso."
	EndIf

	Aviso(STR0017,cMsg,{STR0003}, 2 ) //##"Registro de Complemento de Empresa"#"Fechar"
EndIf

TAFEncArr( @aInfo )
TAFEncArr( @aRegExc )
TAFEncArr( @aCU0 )
TAFEncArr( aTafKeys )
TAFEncArr( aTafKeysExc )

Return()
