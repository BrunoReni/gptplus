#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXHISTORY.CH"      

Static __aTable
Static __cTaskTime	

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOpenHistory
Define a estrutura da tabela de hist�rico de extra��o e realiza a cria��o, 
abertura e ajustes na estrutura do arquivo. 

@author  Valdiney V GOMES
@since   28/11/2013
/*/
//-------------------------------------------------------------------
Function BIXOpenHistory()   
	Local oHistory 	:= nil   
	Local nTable	:= 1

	If ( __aTable == nil )
		//-------------------------------------------------------------------
		// Lista de tabelas do hist�rico.
		//-------------------------------------------------------------------
		__aTable := {}	 
		
		//-------------------------------------------------------------------
		// Cria a tabela de per�odos. 
		//-------------------------------------------------------------------  
		oHistory	:= TBITable():New( "HY6", "HY6" ) 
	
		oHistory:AddField( TBIField():New( "HY6_TABLE" 		,"C",03	,0))
		oHistory:AddField( TBIField():New( "HY6_FILE"  		,"C",06 ,0))
		oHistory:AddField( TBIField():New( "HY6_OPER"  		,"C",01 ,0))	
		oHistory:AddField( TBIField():New( "HY6_GRPEMP"  	,"C",02 ,0))	
		oHistory:AddField( TBIField():New( "HY6_CDEMPR"  	,"C",12	,0))	
		oHistory:AddField( TBIField():New( "HY6_CDUNEG"  	,"C",12	,0))	    
		oHistory:AddField( TBIField():New( "HY6_FILIAL"  	,"C",12	,0))
		oHistory:AddField( TBIField():New( "HY6_DATE"  		,"C",08 ,0))	
		oHistory:AddField( TBIField():New( "HY6_EXEC"  		,"C",32 ,0))
		oHistory:addIndex( TBIIndex():New( "HY61", {"HY6_TABLE", "HY6_FILE", "HY6_OPER", "HY6_CDEMPR", "HY6_CDUNEG", "HY6_FILIAL", "HY6_GRPEMP"}, .F.) )  
			
		aAdd( __aTable, oHistory )
	EndIf 

	//-------------------------------------------------------------------
	// Abre a tabela. 
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( __aTable )
		If !( __aTable[nTable]:lIsOpen( ) )
			__aTable[nTable]:bLogger( {|x| BIXSysOut("BIXHISTORY", __aTable[nTable]:cTablename() + " " + x )} )
			__aTable[nTable]:ChkStruct( .F., .F., .F., .T. )
			__aTable[nTable]:lOpen( )
		EndIf
	Next nTable 
Return .T.        

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSetHistory
Grava o hist�rico de extra��o da entidade. 

@param cEntity, caracter, Tabela de Smart Area que ter� o hist�rico gravado. 
@param lUnique, l�gico, Indica se � limpeza ou extra��o. 

@author  Valdiney V GOMES
@since   28/11/2013
/*/
//-------------------------------------------------------------------
Static Function BIXSetHistory( cEntity, lUnique ) 
   	Local oEntity			:= nil
	Local cCompany	   		:= Space( 12 ) 
	Local cUnitBusiness		:= Space( 12 )
	Local cBranch			:= Space( 12 )  
	Local cFile				:= Space( 06 )  
	Local cGrpEmp	   		:= Space( 02 )   
	Local cTable			:= ""
	Local cOperation		:= ""
	Local nLog				:= 0
	Local lHistory			:= .F. 
	Local lShared			:= .F. 
	Local lUseFilOrig       := SuperGetMV("MV_BIXFORI", .F., .F.)

	Default cEntity			:= ""
	Default lUnique			:= .F.
	
	BIXOpenHistory() 
	
	//-------------------------------------------------------------------
	// Identifica a opera��o que es� sendo realizada. 
	//-------------------------------------------------------------------	
	cOperation := If( lUnique, "1", "2" )

	//-------------------------------------------------------------------
	// Identifica se a op��o de compartilhamento de tabelas entre 
	// empresas est� habilitada. 
	//-------------------------------------------------------------------
	lShared := BIXParInfo( "BIX_CMPEMP", "L", .F. )
	
	//-------------------------------------------------------------------
	// Identifica a tabela do fluxo principal da entidade. 
	//-------------------------------------------------------------------
	If ! ( Empty( cEntity ) )
		oEntity := BIXObject( cEntity )
		
		If ! ( Empty( oEntity ) )
			cTable := oEntity:GetTable( )
			
			//-------------------------------------------------------------------
			// Identifica o compartilhamento da tabela. 
			//-------------------------------------------------------------------		
			If ! ( lUnique )
				cFile 			:= BIXGetFile( cTable, cEntity )
				cCompany		:= PadR( oEntity:GetCompany( )		, 12 )
				cUnitBusiness	:= PadR( oEntity:GetUnitBusiness( )	, 12 )
				
				//-------------------------------------------------------------------
				// Ajusta as informa��es caso utilize a op��o de Filial Origem. 
				//-------------------------------------------------------------------		
				If lUseFilOrig .And. cEntity == "HKK"
					cGrpEmp := PadR( cEmpAnt, 02 )
					cBranch := Space( 12 )  		
				Else
					cBranch := PadR( oEntity:GetFilial( ), 12 ) 
	
					If ! ( lShared ) .And. ! ( cEntity == "HK2" )  
						cGrpEmp := PadR( cEmpAnt, 02 )
					EndIf
				EndIf				
			EndIf
			
			FreeObj( oEntity ) 
		EndIf
	EndIf	
 
	//-------------------------------------------------------------------
	// Identifica se grava ou atualiza o hist�rico. 
	//-------------------------------------------------------------------    
   	lHistory := HY6->( DBSeek( cEntity + cFile + cOperation + cCompany + cUnitBusiness + cBranch + cGrpEmp) )
   
	//-------------------------------------------------------------------
	// Insere a entidade no hist�rico. 
	//-------------------------------------------------------------------
 	If ( ( lHistory .And. HY6->( SimpleLock() ) ) .Or. ! lHistory )
	 	If ( RecLock( "HY6", ! lHistory  ) )
			HY6->HY6_TABLE	:= cEntity
			HY6->HY6_FILE	:= cFile
			HY6->HY6_OPER	:= cOperation
			HY6->HY6_GRPEMP := cGrpEmp
			HY6->HY6_CDEMPR := cCompany
			HY6->HY6_CDUNEG := cUnitBusiness
			HY6->HY6_FILIAL := cBranch  
			HY6->HY6_DATE  	:= DToC( Date() )   
			HY6->HY6_EXEC	:= BIXGetRun()

			HY6->( MsUnlock() )
		EndIf 
	EndIf 
Return nil 
        
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetFile  
Retorna o nome do arquivo f�sico de uma tabela do Protheus. Quando for 
informada uma tabela que n�o faz parte do dicion�rio do Protheus, ser�
retornada entidade da Fluig Smart Data concaternada com o grupo de em_
presa corrente. 

@param cTable, caracter, Alias de uma tabela do Protheus. 
@param cEntity, caracter, Entidade em processamento.   
@return cFile, Nome do arquivo no banco de dados.

@author  Valdiney V GOMES
@since   29/02/2015
/*/
//-------------------------------------------------------------------
Static Function BIXGetFile( cTable, cEntity )
	Local oEntity	:= nil
	Local oModel	:= nil
	Local cGroup	:= ""
	Local cFile 	:= ""
	
	Default cTable	:= ""
	Default cEntity	:= ""
	
	//-------------------------------------------------------------------
	// Retorna o nome da tabela da entidade  
	//-------------------------------------------------------------------	
	If ( ! Empty( cTable ) .And. AliasInDic( cTable ) )
		cFile := AllTrim( FWSX2Util():GetFile( cTable ) )		
	Else
		//-------------------------------------------------------------------
		// Recupera o nome da entidade.  
		//-------------------------------------------------------------------  	
		If ! ( Empty( cEntity ) )
			oEntity := BIXObject( cEntity )
			
			If ! ( Empty( oEntity ) )
				oModel := oEntity:GetModel( )
				
				If ! ( Empty( oModel ) ) 
					If ( oModel:HasDefault( ) )
						cGroup 	:= PadR( FWGrpCompany(), 2 )
						cFile 	:= PadR( cEntity + cGroup, 6, "0" )
					Else
						cFile := PadR( cEntity, 6, "0" )
					EndIf
				EndIf	
				
				FreeObj( oEntity )
			EndIf 
		EndIf			
	EndIf 
Return cFile  
        
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCheckHistory
Identifica se uma determinada entidade da Smart Area, relacionada com 
uma tabela do Protheus, deve ser extra�da.

@param cEntity, caracter, Tabela da Smart Area que ser� extra�da. 
@param lSet, l�gico, Identifica se deve atualizar o hist�rico. 
@param lUnique, l�gico, Identifica se a verifica��o � �nica, ou seja, identifica apenas se a entidade j� foi verificada em um processo de extra��o.   
@return Indica se haver� extra��o da dimens�o. 

@author  Valdiney V GOMES
@since   28/11/2013
/*/
//-------------------------------------------------------------------
Function BIXCheckHistory( cEntity, lSet, lUnique ) 
	Local oEntity			:= nil
	Local cCompany	   		:= Space( 12 ) 
	Local cUnitBusiness		:= Space( 12 )
	Local cBranch			:= Space( 12 )    
	Local cFile				:= Space( 06 ) 
	Local cGrpEmp	   		:= Space( 02 )   
	Local cTable			:= ""
	Local cOperation		:= ""
	Local cLock				:= ""
	Local nLog				:= 0
	Local nHandle			:= 0
	Local lHistory			:= .F. 
	Local lExtract			:= .T. 
	Local lUseFilOrig       := SuperGetMV("MV_BIXFORI", .F., .F.)
	
	Default cEntity			:= ""
	Default lSet 			:= .T. 
	Default lUnique			:= .F.
	
	BIXOpenHistory()  
	
	//-------------------------------------------------------------------
	// Monta o lock. 
	//------------------------------------------------------------------- 
	cLock 	:= BIXLock( "CHECK", cEntity, .F. )  

	// ------------------------------------------------------
	// Realiza o lock da entidade. 
	// ------------------------------------------------------
	While ( ( nHandle := FCreate( cLock, 1 ) ) == -1 )
		Sleep( 100 )    
	EndDo	
	
	//-------------------------------------------------------------------
	// Identifica a opera��o que es� sendo realizada. 
	//-------------------------------------------------------------------	
	cOperation := If( lUnique, "1", "2" )

	//-------------------------------------------------------------------
	// Identifica se a op��o de compartilhamento de tabelas entre 
	// empresas est� habilitada. 
	//-------------------------------------------------------------------
	lShared := BIXParInfo( "BIX_CMPEMP", "L", .F. )

	//-------------------------------------------------------------------
	// Identifica a tabela do fluxo principal da entidade. 
	//-------------------------------------------------------------------
	If ! ( Empty( cEntity ) )
		oEntity := BIXObject( cEntity )
		
		If ! ( Empty( oEntity ) )
			cTable := oEntity:GetTable( )
			
			//-------------------------------------------------------------------
			// Identifica o compartilhamento da tabela. 
			//-------------------------------------------------------------------		
			If ! ( lUnique )
				cFile 			:= BIXGetFile( cTable, cEntity )
				cCompany		:= PadR( oEntity:GetCompany( )		, 12 )
				cUnitBusiness	:= PadR( oEntity:GetUnitBusiness( )	, 12 )

				//-------------------------------------------------------------------
				// Ajusta as informa��es caso utilize a op��o de Filial Origem. 
				//-------------------------------------------------------------------		
				If lUseFilOrig .And. cEntity == "HKK"
					cGrpEmp := PadR( cEmpAnt, 02 )
					cBranch := Space( 12 )  		
				Else
					cBranch := PadR( oEntity:GetFilial( ), 12 ) 
	
					If ! ( lShared ) .And. ! ( cEntity == "HK2" )   
						cGrpEmp := PadR( cEmpAnt, 02 )
					EndIf
				EndIf   
			EndIf
			
			FreeObj( oEntity ) 
		EndIf
	EndIf
	
	//-------------------------------------------------------------------
	// Localiza as informa��es do hist�rico. 
	//-------------------------------------------------------------------
	lHistory := HY6->( DBSeek( cEntity + cFile + cOperation + cCompany + cUnitBusiness + cBranch + cGrpEmp ) )  	
	
	//-------------------------------------------------------------------
	// Verifica se a entidade j� foi extra�da. 
	//-------------------------------------------------------------------
	If ( lHistory ) 

		If ( BIXGetRun() == AllTrim( HY6->HY6_EXEC )	)

			lExtract := .F.
		EndIf
	EndIf 		
	
	
	//-------------------------------------------------------------------
	// Atualiza o hist�rico de extra��o. 
	//------------------------------------------------------------------- 
	If ( lSet )
		BIXSetHistory( cEntity, lUnique ) 
	EndIf 
	
	//-------------------------------------------------------------------
	// Remove a marca de bloqueio do processo. 
	//------------------------------------------------------------------- 
	If ! ( nHandle == -1 )
		FClose( nHandle )  
		FErase( cLock )
	EndIf
Return lExtract  

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetRun  
Retorna a data e hora do agendamento da extra��o realizada. 

@param cTaskID, caracter, Tarefa em execu��o no schedule.
@return cExecution, caracter, Data e hora do agendamento em execu��o. 

@author  Valdiney V GOMES
@since   11/09/2013
/*/
//-------------------------------------------------------------------
Function BIXGetRun( cTaskID )
	Local cTemp			:= ""
	Local cQuery 		:= ""
	Local cExecution 	:= ""
	
	Default cTaskID		:= ""
	
	//-------------------------------------------------------------------
	// Recupera o ID da tarefa em execu��o pelo schedule. 
	//-------------------------------------------------------------------		
	If ( Empty( cTaskID ) )
		cTaskID := BIXTaskID()
	EndIf

	//-------------------------------------------------------------------
	// Recupera a data e hora de execu��o. 
	//-------------------------------------------------------------------		
	cExecution	:= DToS( Date() ) + Substr( Time(), 1, 5 ) 	

	If ! ( Empty( cTaskID ) )
		//-------------------------------------------------------------------
		// Verifica se a hora do agendamento est� em cache. 
		//-------------------------------------------------------------------		
		If ( Empty( __cTaskTime ) ) 
			//-------------------------------------------------------------------
			// Verifica se a extra��o est� sendo executada simulando o schedule. 
			//-------------------------------------------------------------------				
			If ( "DUMMY" $ Upper( cTaskID ) )		
				__cTaskTime := StrTran( cTaskID, "DUMMY", "" )
			Else
				If ( TCCanOpen( "SCHDTSK" ) )
					cTemp		:= GetNextAlias() 
					
				    //-------------------------------------------------------------------
					// Monta a query para recuperar a hora de execu��o do agendamento. 
					//-------------------------------------------------------------------			
					cQuery := " SELECT TSK_DIA, TSK_HORA" 
					cQuery += " FROM SCHDTSK"
					cQuery += " WHERE "
					cQuery += "		TSK_CODIGO = '" + SubStr( cTaskID, 1, 6 ) + "'" 
					cQuery += "		AND " 
					cQuery += "		TSK_ITEM   = '" + SubStr( cTaskID, 7 ) + "'" 
		
				 	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTemp, .T., .F.)
				 	
				 	//-------------------------------------------------------------------
					// Recupera a hora de execu��o da tarefa. 
					//-------------------------------------------------------------------		
				 	If ! (cTemp)->( Eof() )
				 		__cTaskTime 	:= AllTrim( (cTemp)->TSK_DIA + (cTemp)->TSK_HORA )
				 	EndIf 
				 	
					(cTemp)->( DBCloseArea() )
				EndIf 
			EndIf
			 
			//-------------------------------------------------------------------
			// Retorna a hora de execu��o da tarefa.  
			//-------------------------------------------------------------------		
			If ! ( Empty( __cTaskTime ) )
				cExecution := AllTrim( __cTaskTime )
			EndIf
		Else	
		 	//-------------------------------------------------------------------
			// Retorna, do cache, a hora de execu��o da tarefa. 
			//-------------------------------------------------------------------	
			cExecution := AllTrim( __cTaskTime )
		EndIf 
 	EndIf 
Return cExecution

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLogField  
Retorna o nome do campo de log de inclus�o e altera��o de uma tabela. 

@return cField 	Nome do campo do log de altera��o e inclus�o. 

@author  Marcia Junko
@since   07/06/2017
/*/
//-------------------------------------------------------------------
Function BIXLogField( cTable, cLog )
	Local cField   := ""
	
	Default cTable := ""
 	Default cLog   := "USERLGI"
 
 	If ( cLog == "USERLGI" ) 
 		//-------------------------------------------------------------------
		// Campo do log de inclus�o. 
		//-------------------------------------------------------------------
		If ( Substr(cTable, 1, 1) == "S" )
			cField 	:= Substr(cTable,2) + "_USERLGI"
		Else
			cField 	:= cTable + "_USERGI"
		EndIf 
 	Else
 	 	//-------------------------------------------------------------------
		// Campo do log de altera��o. 
		//-------------------------------------------------------------------
		If ( Substr(cTable, 1, 1) == "S" )
			cField 	:= Substr(cTable,2) + "_USERLGA"
		Else
			cField 	:= cTable + "_USERGA"
		EndIf 
 	EndIf
Return cField


//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAddLGField  
Retorna a data e hora do agendamento da extra��o realizada. 

@param cTable, caracter, Alias de uma tabela do Protheus. 
@return cCampos, caracter, Cont�m os campos _USERLGI\_USERLGA 

@author  Marcia Junko
@since   05/06/2017
/*/
//-------------------------------------------------------------------
Function BIXAddLGField( cTable, nType ) 
	Local aArea		 := GetArea()
	Local cCampos 	 := ""
	Local cInsertLog := BIXLogField( cTable, "USERLGI" )      
   	Local cUpdateLog := BIXLogField( cTable, "USERLGA" )
   	Local lUpdateLog := .F. 
   	Local lInsertLog := .F.    	
	
	Default cTable	 := ""
	Default nType    := 1
	
	If !Empty(cTable) 	
		DBSelectArea( cTable ) 	
		
		//-------------------------------------------------------------------
		// Localiza os campos do log de registro. 
		//-------------------------------------------------------------------
	   	lInsertLog := ( cTable )->( FieldPos( cInsertLog ) ) > 0
	   	lUpdateLog := ( cTable )->( FieldPos( cUpdateLog ) ) > 0  
		
		//-------------------------------------------------------------------
		// Monta a instru��o de campos do USERLGI\USERLGA 
		//-------------------------------------------------------------------
		If nType == 1
			cCampos := Iif(lInsertLog, cInsertLog, "' '") + " USERLGI, " + Iif(lUpdateLog, cUpdateLog, "' '") + " USERLGA"
		Else
			cCampos := Iif(lInsertLog, cInsertLog, " ") + Iif(lUpdateLog, cUpdateLog, " ")
		EndIf	
		
		RestArea( aArea )
	EndIf
Return cCampos 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLastExec  
Retorna a data e hora do agendamento da extra��o realizada. 

@param cTable, caracter, Alias de uma tabela do Protheus. 
@return cCampos, caracter, Cont�m os campos _USERLGI\_USERLGA 

@author  Marcia Junko
@since   05/06/2017
/*/
//-------------------------------------------------------------------
Function BIXLastExec( cEntity )
 	Local cSvAlias  := Alias()
	Local cQuery    := ""
	Local cTmpTbl   := GetNextAlias()
	Local cLastExec := ""
	
	cQuery := "SELECT HY6_DATE FROM HY6 WHERE HY6_TABLE = '" + cEntity + "' AND HY6_OPER = 1 AND D_E_L_E_T_ = ' '"
	
	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTmpTbl, .T., .F. )
	
	If (cTmpTbl)->(!Eof())
		cLastExec := Dtos(CTOD((cTmpTbl)->HY6_DATE))
	EndIf

	(cTmpTbl)->(DBCloseArea())
	
	If !Empty( cSvAlias )
		DbSelectArea( cSvAlias )
	EndIf
Return cLastExec

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLeLg  
Retorna a data da inclus�o\altera��o de determinado registro

@param cValue, caracter, conte�do a ser validado 
@return cDateLG, caracter, data da inclus�o\altera��o do registro

@author  Marcia Junko
@since   05/06/2017
/*/
//-------------------------------------------------------------------
Function BIXLeLg(cValue)
	Local cLGDecript := ""
	Local cDateLG	 := ""
	
	Default cValue   := ""
	
	If !Empty(cValue)
		//-------------------------------------------------------------------
		//Desembaralha o conte�do da _USERLG
		//-------------------------------------------------------------------
		cLGDecript := Embaralha(cValue, 1)
		
		//-------------------------------------------------------------------
		// Converte a data
		//-------------------------------------------------------------------
		cDateLG := Dtos(CTOD("01/01/96","DDMMYY") + Load2In4(Substr(cLGDecript,16)))
	EndIf	
Return cDateLG