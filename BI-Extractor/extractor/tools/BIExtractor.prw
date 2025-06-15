#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIEXTRACTOR.CH"

Static __cTaskID
Static dStartRunning

//-------------------------------------------------------------------
/*/{Protheus.doc} BIExtractor 
Extrator central de todas as dimensões e fatos para o TOTVS KPI.
Esta função deverá ser chamada via Protheus Scheduler

@param aParameter, array, Parâmetros do schedule para execução. 
@param [cTaskID], caracter, ID da tarefa em execução. 
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
	// Se a execução for pelo perfil o job não deve aguardar  
	// o fim da execução 
	//------------------------------------------------------------------- 	
	If Upper(Alltrim(cFunName)) == "BIXPROFILE"
		lWait := .F.
	EndIf

	//-------------------------------------------------------------------
	// Recupera os parâmetros de extração. 
	//------------------------------------------------------------------- 	
	If ( Empty( aParameter ) )
		aParameter := BIXPergunte( )
	EndIf

	//-------------------------------------------------------------------
	// Executa o processo de extração. 
	//------------------------------------------------------------------- 	
	If ( AllTrim( GetSrvProfString("BIDEBUG","0") ) == "1" ) 
		BIXJobExtractor( cCompany, cBranch, aParameter, cTaskID )
	Else
		StartJob( "BIXJOBEXTRACTOR", GetEnvServer(), lWait, cCompany, cBranch, aParameter, cTaskID )
	EndIf
	
	//-------------------------------------------------------------------
	// Limpeza das variáveis estáticas.
	//-------------------------------------------------------------------
	BIXClearEnv()
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXJobExtractor
Função responsável por iniciar o processo de extração. 

@param aParameter, caracter, Parametros para execução.
@param cTaskID, caracter, ID do processo de extração.
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
	// Identifica as tabelas da engine de extração. 
	//------------------------------------------------------------------- 	
	aTable	:= { "HJJ", "HKC", "HK4", "HK3", "HH1" }

	//-------------------------------------------------------------------
	// Recupera o ID da extração. 
	//------------------------------------------------------------------- 
	__cTaskID := cTaskID	

	//-------------------------------------------------------------------
	// Identifica se tem licença disponível.
	//-------------------------------------------------------------------		
	If ( BIXHasLicense( ) ) 
		//-------------------------------------------------------------------
		// Identifica se tem conexão disponível.
		//-------------------------------------------------------------------		
		If ! ( Empty( BIXLinkFSD() ) )		
			BIXUnlinkFSD()
			
			//-------------------------------------------------------------------
			// Atualiza o status do processo. 
			//------------------------------------------------------------------- 
			BIXSaveParam( "START" , DToS( Date( ) ) + " " + StrTran( Time( ), ":", "" ) )

			BIXSysOut("BIEXTRACTOR", I18n( STR0001, { SToD( aParameter[1] ), SToD(  aParameter[2] ) } ) ) //"Período para extração [de #1 até #2]"
			
			//-------------------------------------------------------------------
			// Atualiza o status da extração. 
			//------------------------------------------------------------------- 
			BIXSaveParam( "STATUS", "RUNNING" )
			
			//-------------------------------------------------------------------
			// Executa o processo de extração. 
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
			// Realiza a limpeza do log de extração. 
			//-------------------------------------------------------------------   	
			If ( BIXLogStatus() == LOG_FINISH )
				BIXClearLog()
			EndIf 
		Else
			BIXSetLog( LOG_LINK )
		EndIf	
	Else
		BIXSysOut( "BIEXTRACTOR", STR0003 ) //"Não há licença para execução do extrator."
		BIXSetLog( LOG_LICENSE )
	Endif 
Return nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetFact
Retorna as fatos que devem ser processadas. 
 
@param aParameter, array, Parâmetros para extração. 
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
		BIXSysOut("BIEXTRACTOR", STR0002 + " [" + AllTrim( HRC->HRC_TITLE ) + "]" ) //"Extração por perfil ["
	
		//-------------------------------------------------------------------
		// Loga o perfil que será processado. 
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
	// Identifica os apps que serão processados. 
	//------------------------------------------------------------------- 		
	For nApp := 1 To Len( aApp )
		nPosition := AScan( aAllApps, { | x | x[1] == aApp[nApp] } )
	
		If ! ( Empty( nPosition ) )
			AAdd( aAppChecked, aAllApps[nPosition][2] )
		EndIf
	Next nApp
	
	//-------------------------------------------------------------------
	// Loga os apps que serão processados. 
	//------------------------------------------------------------------- 					   	
	BIXSetLog( LOG_RUNNING,,,,,,, BIXConcatWSep( ",", aAppChecked ) )		
Return aFact

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTaskID
Retorna o identificado da tarefa do schedule. 
 
@return __cTaskID, Identificador da tarefa. 

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Function BIXTaskID()
Return __cTaskID

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPergunte
Recupera os parâmetros para execução do extrator. 

@return aParameter, Parâmetros para execução do extrator. 

@author  Márcia Junko
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
		// Mês atual.
		//-------------------------------------------------------------------
		Case ( MV_PAR01 == 3 ) 
			AAdd( aParameter, DToS( FirstDay( Date( ) ) ) )
			AAdd( aParameter, DToS( LastDay( Date( ) ) ) )
		//-------------------------------------------------------------------
		// Mês anterior.
		//-------------------------------------------------------------------
		Case ( MV_PAR01 == 4 ) 
			AAdd( aParameter, DToS( FirstDay( FirstDay( Date( ) ) - 1 ) ) )
			AAdd( aParameter, DToS( LastDay( FirstDay( Date( ) ) - 1 ) ) )
		//-------------------------------------------------------------------
		// Data específica.
		//-------------------------------------------------------------------
		Otherwise
			AAdd( aParameter, DToS( MV_PAR02 ) ) 
			AAdd( aParameter, DToS( MV_PAR03 ) ) 
	EndCase

	//-------------------------------------------------------------------
	// Áreas para carga da stage.
	//-------------------------------------------------------------------
	If ! ( Type( "MV_PAR04" ) == "U" )
		AAdd( aParameter, MV_PAR04 )

		//-------------------------------------------------------------------
		// Perfil de extração.
		//-------------------------------------------------------------------
		If ! ( Type( "MV_PAR05" ) == "U" )
			AAdd( aParameter, MV_PAR05 )
		EndIf
	EndIf
Return aParameter

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Habilita a rotina para ser schedulada. 

@return aRet, Informações da tarefa. 

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Static Function SchedDef( )
Return { "P", "BIXDT1", "", { }, }

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXStartRunning
Retorna a data de início do processo de extração da thread.  

@return dStartRunning, caracter, Data de inicio da extração. 

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
Limpeza das variáveis estáticas. 

@author  Helio Leal
@version P12
@since   18/01/2017
/*/
//-------------------------------------------------------------------
Static Function BIXClearEnv()
	dStartRunning	:= Nil
Return Nil