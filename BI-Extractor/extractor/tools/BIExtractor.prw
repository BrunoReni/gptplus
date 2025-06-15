#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIEXTRACTOR.CH"

Static __cTaskID
Static dStartRunning

//-------------------------------------------------------------------
/*/{Protheus.doc} BIExtractor 
Extrator central de todas as dimens�es e fatos para o TOTVS KPI.
Esta fun��o dever� ser chamada via Protheus Scheduler

@param aParameter, array, Par�metros do schedule para execu��o. 
@param [cTaskID], caracter, ID da tarefa em execu��o. 
@param [cCompany], caracter, Empresa.
@param [cBranch], caracter, Filial.

@author  BI TEAM
@since   31/01/2011
/*/
//-------------------------------------------------------------------
Function BIExtractor( aParameter, cTaskID, cCompany, cBranch )
	Local cFunName := FunName()
	Local lWait	   := .T.
	
	Default cTaskID	 := FWGetIDTask()
	Default cCompany := cEmpAnt 
	Default cBranch	 := cFilAnt


	//-------------------------------------------------------------------
	// Se a execu��o for pelo perfil o job n�o deve aguardar  
	// o fim da execu��o 
	//------------------------------------------------------------------- 	
	If Upper(Alltrim(cFunName)) == "BIXPROFILE"
		lWait := .F.
	EndIf

	//-------------------------------------------------------------------
	// Recupera os par�metros de extra��o. 
	//------------------------------------------------------------------- 	
	If ( Empty( aParameter ) )
		aParameter := BIXPergunte( )
	EndIf

	//-------------------------------------------------------------------
	// Executa o processo de extra��o. 
	//------------------------------------------------------------------- 	
	If ( AllTrim( GetSrvProfString("BIDEBUG","0") ) == "1" ) 
		BIXJobExtractor( cCompany, cBranch, aParameter, cTaskID )
	Else
		StartJob( "BIXJOBEXTRACTOR", GetEnvServer(), lWait, cCompany, cBranch, aParameter, cTaskID )
	EndIf
	
	//-------------------------------------------------------------------
	// Limpeza das vari�veis est�ticas.
	//-------------------------------------------------------------------
	BIXClearEnv()
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXJobExtractor
Fun��o respons�vel por iniciar o processo de extra��o. 

@param aParameter, caracter, Parametros para execu��o.
@param cTaskID, caracter, ID do processo de extra��o.
@param cCompany, caracter, Empresa.
@param cBranch, caracter, Filial.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Function BIXJobExtractor( cCompany, cBranch, aParameter, cTaskID )
	Local oRunner		:= nil
	Local aTable		:= {}

	Default aParameter	:= {}	
	Default cTaskID		:= ""
	Default cCompany	:= ""
	Default cBranch		:= ""

	RPCSetType( 3 )
 	RPCSetEnv( cCompany, cBranch ) 

	//-------------------------------------------------------------------
	// Identifica as tabelas da engine de extra��o. 
	//------------------------------------------------------------------- 	
	aTable	:= { "HJJ", "HKC", "HK4", "HK3", "HH1" }

	//-------------------------------------------------------------------
	// Recupera o ID da extra��o. 
	//------------------------------------------------------------------- 
	__cTaskID := cTaskID	

	//-------------------------------------------------------------------
	// Identifica se tem licen�a dispon�vel.
	//-------------------------------------------------------------------		
	If ( BIXHasLicense( ) ) 
		//-------------------------------------------------------------------
		// Identifica se tem conex�o dispon�vel.
		//-------------------------------------------------------------------		
		If ! ( Empty( BIXLinkFSD() ) )		
			BIXUnlinkFSD()
			
			//-------------------------------------------------------------------
			// Atualiza o status do processo. 
			//------------------------------------------------------------------- 
			BIXSaveParam( "START" , DToS( Date( ) ) + " " + StrTran( Time( ), ":", "" ) )

			BIXSysOut("BIEXTRACTOR", I18n( STR0001, { SToD( aParameter[1] ), SToD(  aParameter[2] ) } ) ) //"Per�odo para extra��o [de #1 at� #2]"
			
			//-------------------------------------------------------------------
			// Atualiza o status da extra��o. 
			//------------------------------------------------------------------- 
			BIXSaveParam( "STATUS", "RUNNING" )
			
			//-------------------------------------------------------------------
			// Executa o processo de extra��o. 
			//-------------------------------------------------------------------	
			oRunner := BIXRunner( ):New( )
			oRunner:SetFromDate( aParameter[1] )
			oRunner:SetToDate( aParameter[2] )
			oRunner:SetProfile( aParameter[4]  )
			oRunner:Init( aTable )
			dStartRunning	:= Date()

			If ( oRunner:Go( BIXGetFact( aParameter ) ) )
				BIXSaveParam( "STATUS", "OK" )
			Else
				BIXSaveParam( "STATUS", "ERROR" )
			EndIf
			
			FreeObj( oRunner )
			
			//-------------------------------------------------------------------
			// Atualiza o status do processo. 
			//-------------------------------------------------------------------
			BIXSaveParam( "FINISH", DToS( Date( ) ) + " " + StrTran( Time( ), ":", "" ) )
			
			//-------------------------------------------------------------------
			// Realiza a limpeza do log de extra��o. 
			//-------------------------------------------------------------------   	
			If ( BIXLogStatus() == LOG_FINISH )
				BIXClearLog()
			EndIf 
		Else
			BIXSetLog( LOG_LINK )
		EndIf	
	Else
		BIXSysOut( "BIEXTRACTOR", STR0003 ) //"N�o h� licen�a para execu��o do extrator."
		BIXSetLog( LOG_LICENSE )
	Endif 
Return nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetFact
Retorna as fatos que devem ser processadas. 
 
@param aParameter, array, Par�metros para extra��o. 
@return aFact, Lista de fatos para processamento. 

@author  Valdiney V GOMES
@since   03/02/2017
/*/
//-------------------------------------------------------------------
Static Function BIXGetFact( aParameter )
	Local oTopology		:= nil
	Local aAllApps		:= {}
	Local aAppChecked	:= {}
	Local aStack		:= {}
	Local aFact			:= {}
	Local aApp			:= {}
	Local nPosition		:= 0
	Local nApp			:= 0
	Local nStack		:= 0
	Local nFact			:= 0
	
	Default aParameter 	:= { }
	
	If ( BIXHasProfile( aParameter ) )  
		BIXSysOut("BIEXTRACTOR", STR0002 + " [" + AllTrim( HRC->HRC_TITLE ) + "]" ) //"Extra��o por perfil ["
	
		//-------------------------------------------------------------------
		// Loga o perfil que ser� processado. 
		//------------------------------------------------------------------- 			   	
		BIXSetLog( LOG_RUNNING,,,, HRC->HRC_TITLE )	  

		//-------------------------------------------------------------------
		// Lista os apps e fatos configuradas no perfil. 
		//------------------------------------------------------------------- 				
		aApp := aBIToken( HRC->HRC_AREA, "|", .F.) 			
		aFact := aBIToken( HRC->HRC_FACT, "|", .F.) 
	Else   	
		//-------------------------------------------------------------------
		// Lista os apps configuradas no schedule. 
		//------------------------------------------------------------------- 		
		aApp := aBIToken( aParameter[3], ",", .F. )
	
		//-------------------------------------------------------------------
		// Lista as fatos dos apps configurados no schedule. 
		//------------------------------------------------------------------- 		
		oTopology 	:= BIXTopology():New( )
		aStack 		:= oTopology:GetTopology( aApp )
		FreeObj( oTopology )
		
		For nStack := 1 To Len( aStack )
			For nFact := 1 To Len( aStack[nStack][3] )
				AAdd( aFact, aStack[nStack][3][nFact][1] )
			 Next nFact 
		Next nStack					
	EndIf 

	//-------------------------------------------------------------------
	// Recupera os apps registrados. 
	//------------------------------------------------------------------- 	
	aAllApps := BIXRegister() 	

	//-------------------------------------------------------------------
	// Identifica os apps que ser�o processados. 
	//------------------------------------------------------------------- 		
	For nApp := 1 To Len( aApp )
		nPosition := AScan( aAllApps, { | x | x[1] == aApp[nApp] } )
	
		If ! ( Empty( nPosition ) )
			AAdd( aAppChecked, aAllApps[nPosition][2] )
		EndIf
	Next nApp
	
	//-------------------------------------------------------------------
	// Loga os apps que ser�o processados. 
	//------------------------------------------------------------------- 					   	
	BIXSetLog( LOG_RUNNING,,,,,,, BIXConcatWSep( ",", aAppChecked ) )		
Return aFact

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTaskID
Retorna o identificado da tarefa do schedule. 
 
@return __cTaskID, Identificador da tarefa. 

@author  M�rcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Function BIXTaskID()
Return __cTaskID

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPergunte
Recupera os par�metros para execu��o do extrator. 

@return aParameter, Par�metros para execu��o do extrator. 

@author  M�rcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Static Function BIXPergunte(  )
	Local aParameter := { }

	Do Case
		//-------------------------------------------------------------------
		// Dia atual.
		//-------------------------------------------------------------------
		Case ( MV_PAR01 == 1 )
			AAdd( aParameter, DToS( Date( ) ) )
			AAdd( aParameter, DToS( Date( )  ) )
		//-------------------------------------------------------------------
		// Dia Anterior.
		//-------------------------------------------------------------------
		Case ( MV_PAR01 == 2 )
			AAdd( aParameter, DToS( Date( )  - 1 ) )
			AAdd( aParameter, DToS( Date( )  - 1 ) )
		//-------------------------------------------------------------------
		// M�s atual.
		//-------------------------------------------------------------------
		Case ( MV_PAR01 == 3 ) 
			AAdd( aParameter, DToS( FirstDay( Date( ) ) ) )
			AAdd( aParameter, DToS( LastDay( Date( ) ) ) )
		//-------------------------------------------------------------------
		// M�s anterior.
		//-------------------------------------------------------------------
		Case ( MV_PAR01 == 4 ) 
			AAdd( aParameter, DToS( FirstDay( FirstDay( Date( ) ) - 1 ) ) )
			AAdd( aParameter, DToS( LastDay( FirstDay( Date( ) ) - 1 ) ) )
		//-------------------------------------------------------------------
		// Data espec�fica.
		//-------------------------------------------------------------------
		Otherwise
			AAdd( aParameter, DToS( MV_PAR02 ) ) 
			AAdd( aParameter, DToS( MV_PAR03 ) ) 
	EndCase

	//-------------------------------------------------------------------
	// �reas para carga da stage.
	//-------------------------------------------------------------------
	If ! ( Type( "MV_PAR04" ) == "U" )
		AAdd( aParameter, MV_PAR04 )

		//-------------------------------------------------------------------
		// Perfil de extra��o.
		//-------------------------------------------------------------------
		If ! ( Type( "MV_PAR05" ) == "U" )
			AAdd( aParameter, MV_PAR05 )
		EndIf
	EndIf
Return aParameter

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Habilita a rotina para ser schedulada. 

@return aRet, Informa��es da tarefa. 

@author  M�rcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Static Function SchedDef( )
Return { "P", "BIXDT1", "", { }, }

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXStartRunning
Retorna a data de in�cio do processo de extra��o da thread.  

@return dStartRunning, caracter, Data de inicio da extra��o. 

@author  Helio Leal
@since   30/05/2017
/*/
//-------------------------------------------------------------------
Function BIXInitRunning( )
	If ( Empty( dStartRunning ) )
		dStartRunning := Date()
	EndIf 
Return dStartRunning

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXClearEnv
Limpeza das vari�veis est�ticas. 

@author  Helio Leal
@version P12
@since   18/01/2017
/*/
//-------------------------------------------------------------------
Static Function BIXClearEnv()
	dStartRunning	:= Nil
Return Nil