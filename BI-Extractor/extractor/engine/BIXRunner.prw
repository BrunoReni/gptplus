#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRUNNER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRunner
Classe respons�vel por executar a extra��o dos dados das entidades.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Class BIXRunner
	Data cProfile
	Data dFrom
	Data dTo
	Data dToday

	Method New( ) CONSTRUCTOR
	Method SetFromDate( dFrom )
	Method SetToDate( dTo )
	Method SetProfile( cProfile )
	Method Init( aTable ) 	
	Method Go( aFact )	
	Method Sort( aEntity, nEntity )
	Method Run( oEntity )
	Method Destroy( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo contrutor.

@Return Self, Inst�ncia da Classe.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method New( ) Class BIXRunner
	::cProfile := ""
	::dToday   := Date( )
	::dFrom    := Date( )
	::dTo      := Date( )
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFromDate
Define a data inicial de extra��o.

@param dFrom, caracter, Data inicial de extra��o. 
@Return dFrom, Data inicial de extra��o.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method SetFromDate( dFrom ) Class BIXRunner
	Default dFrom := Date( )
	
	If ! ( ValType( dFrom ) == "D" )
		dFrom := xBIConvTo( "D", dFrom )
	EndIf
	
	::dFrom := dFrom
Return ::dFrom

//-------------------------------------------------------------------
/*/{Protheus.doc} SetToDate
Define a data To de extra��o. 

@param dTo, caracter, Data To de extra��o. 
@Return dTo, Data inicial de extra��o.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method SetToDate( dTo ) Class BIXRunner
	Default dTo := Date( )

	If ! ( ValType( dTo ) == "D" )
		dTo := xBIConvTo( "D", dTo )
	EndIf
	
	::dTo := dTo
Return ::dTo

//-------------------------------------------------------------------
/*/{Protheus.doc} SetProfile
Define o perfil de extra��o. 

@param cProfile, caracter, Perfil de extra��o. 
@Return cProfile, Perfil de extra��o. 

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method SetProfile( cProfile ) Class BIXRunner
	Default cProfile := ""
	
	::cProfile := cProfile
Return ::cProfile

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Prepara todas as entidades para o processo de extra��o. Nesta etapa,
as tabelas s�o criadas ou atualizada, truncadas e os registros especiais 
inclu�dos.

@param aTable, array, Tabelas do engine de extra��o.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method Init( aTable ) Class BIXRunner
	Local oTopology	:= nil 
	Local oRecord	:= nil 
	Local oKey		:= nil 
	Local oOutput	:= nil 
	Local oModel	:= nil
	Local aEntity  	:= {}
	Local cEntity	:= ""
	Local nEntity	:= 0
	Local lIdentity	:= .F.
	
	Default aTable := {}

	BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "]" + " " + STR0009 ) //"Manuten��o iniciada"

	//-------------------------------------------------------------------
	// Identifica se utiliza recno autoincremental. 
	//-------------------------------------------------------------------  
	lIdentity := BIXParInfo( "BIX_IDENTI", "L", .F. )	

	//-------------------------------------------------------------------
	// Atualiza as tabelas do engine.
	//-------------------------------------------------------------------  
	For nEntity := 1 To Len( aTable )
		If ( BIXLinkFSD() > 0 )
			BIXSetupTable( aTable[nEntity] )  
			BIXUnlinkFSD()
		EndIf 
	Next nDefault

	//-------------------------------------------------------------------
	// Recupera todas as entidades registradas. 
	//-------------------------------------------------------------------	
	oTopology := BIXTopology():New()	
	aEntity := oTopology:ListEntity( )
	FreeObj( oTopology )
	
	For nEntity := 1 To Len( aEntity )	
		//-------------------------------------------------------------------
		// Identifica se deve inicializar a entidade. 
		//-------------------------------------------------------------------
		If ( BIXCheckHistory( aEntity[nEntity][1],, .T. ) ) 		
			oEntity := BIXObject( aEntity[nEntity][1] )
		
			If ! ( Empty( oEntity ) )
				//-------------------------------------------------------------------
				// Recupera os atributos. 
				//-------------------------------------------------------------------
				oModel 	:= oEntity:GetModel( )
				cEntity := oEntity:GetEntity( )
				cType	:= oEntity:GetType( )

				If ! ( Empty( oModel ) )
					//-------------------------------------------------------------------
					// Identifica se deve dropar a tabela. 
					//-------------------------------------------------------------------
					If ! ( lIdentity )
						If ( BIXLinkFSD() > 0 )
							If ( TCCanOpen( cEntity ) )
								TCDelFile( cEntity ) 		
							EndIf
							
							BIXUnlinkFSD()
						EndIf			
					EndIf	
								
					//-------------------------------------------------------------------
					// Cria a tabela. 
					//-------------------------------------------------------------------
					oOutput	:= BIXOutput():Build( oEntity, .T. )

					//-------------------------------------------------------------------
					// Trunca a tabela. 
					//-------------------------------------------------------------------
					oOutput:Truncate( oModel:HasDefault( ) )	
	
					//-------------------------------------------------------------------
					// Identifica se � uma dimens�o. 
					//-------------------------------------------------------------------				
					If ( cType == DIMENSION )
					 	oRecord := BIXRecord():Build( oEntity )
					 	oKey    := BIXKey():Build( oEntity ) 
					 	
						 //-------------------------------------------------------------------
					 	// Insere o registro f�rmula. 
					 	//-------------------------------------------------------------------				 	
					 	If ( oModel:HasFormula( ) )
					 		oRecord:Init( .F. )
					 		oRecord:AddInternal( FORMULA, STR0001 ) //"FORMULA"
					 		oOutput:Send( oRecord ) 
					 	EndIf 				 	
					 	
					 	//-------------------------------------------------------------------
					 	// Insere o registro indefinido. 
					 	//-------------------------------------------------------------------
					 	If ( oModel:HasUndefined( ) )
					 		oRecord:Init( .F. )
					 		oRecord:AddInternal( UNDEFINED, "INDEFINIDO" ) //N�o internacionalizar!
					 		oOutput:Send( oRecord ) 
					 	EndIf 

					 	oOutput:Release( .F. )
	 
					 	FreeObj( oOutput )	
	 					FreeObj( oRecord )
	 					FreeObj( oKey )
					EndIf  
				EndIf
						
				oEntity:Destroy( )
				FreeObj( oEntity )				
			EndIf 
		EndIf 				
	Next nEntity  
	
	//-------------------------------------------------------------------
	// Trunca a tabela de per�odos de extra��o.
	//-------------------------------------------------------------------  	
	If ( BIXCheckHistory( "HJJ",, .T. ) )  
		oOutput	:= BIXOutput():New( "HJJ" )
		oOutput:Truncate( .F. )

		FreeObj( oOutput )
	EndIf	
	
	//-------------------------------------------------------------------
	// Atualiza os par�metos do engine.
	//------------------------------------------------------------------- 
	If ( BIXCheckHistory( "HJK",, .T. ) )  
		BIXSysOut( "BIXRUNNER", AllTrim( STR0008 ) + ": " + BIXBuild( ) ) //"Extrator"
	
	  	If ! ( lIdentity )	  	
	  		BIXSaveParam( "BIX_IDENTI", "T" )
  		EndIf	
  		
 		If ( Empty( BIXParInfo( "LINPRO", "C", "" ) ) )	  	
	  		BIXSaveParam( "LINPRO", "P " )
	  	EndIf	
	
		If ( Empty( BIXParInfo( "DB_TYPE", "C", "" ) ) )
			BIXSaveDBParam( BIXLinkProperty( , "DATABASE" ) )
		Endif	
	EndIf
	
	BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "]" + " " + STR0010 ) //"Manuten��o finalizada"  
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Go
Executa a extra��o de uma ou mais fatos e suas dimens�es. 

@param aFact, array, Lista de fatos que ser�o extra�das.
@param lOk, boolean, Identifica se o processo foi executado com sucesso.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method Go( aFact ) Class BIXRunner
	Local oTopology   := nil
	Local oFact       := nil
	Local oDimension  := nil 
	Local aEntity     := {}
	Local nFact       := 0
	Local nDimension  := 0
	Local lOk         := .T. 	
	
	Default aFact 	:= {}

	BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "]" + " " + STR0003 ) //"Processo iniciado"

	//-------------------------------------------------------------------
	// Monta a fila de execu��o. 
	//-------------------------------------------------------------------	
	oTopology  := BIXTopology():New()	
	aDimension := oTopology:ListLookup( aFact )
	FreeObj( oTopology )

	//-------------------------------------------------------------------
	// Executa as dimens�es. 
	//-------------------------------------------------------------------			
	For nDimension := 1 To Len( aDimension )
		aDimension := ::Sort( aDimension, nDimension )

		//-------------------------------------------------------------------
		// Recupera o objeto da dimens�o. 
		//-------------------------------------------------------------------
		oDimension := BIXObject( aDimension[nDimension]  )
		
		//-------------------------------------------------------------------
		// Executa a dimens�o. 
		//-------------------------------------------------------------------			
		If ! ( Empty( oDimension ) )
			If ! ( lOk := ::Run( oDimension ) )
				Exit
			Endif 

			//-------------------------------------------------------------------
			// Destroi a inst�ncia da dimens�o. 
			//-------------------------------------------------------------------							
			oDimension:Destroy()
			FreeObj( oDimension )
		EndIf
	Next nDimension

	//-------------------------------------------------------------------
	// Executa as fatos. 
	//-------------------------------------------------------------------
	If ( lOk )
		//-------------------------------------------------------------------
		// Itera pelas fatos. 
		//-------------------------------------------------------------------	
		For nFact := 1 To Len( aFact )
			aFact := ::Sort( aFact, nFact )
			
			//-------------------------------------------------------------------
			// Identifica se a dimens�o foi processada.
			//-------------------------------------------------------------------										
			If ( Empty( AScan( aEntity, { | x | x == aFact[nFact] } ) ) )
				//-------------------------------------------------------------------
				// Recupera o objeto da fato. 
				//-------------------------------------------------------------------
				oFact := BIXObject( aFact[nFact] ) 
			
				//-------------------------------------------------------------------
				// Executa a fato. 
				//-------------------------------------------------------------------			
				If ! ( Empty( oFact ) )				
					If ! ( lOk := ::Run( oFact ) )
						Exit
					EndIf 
					
					//-------------------------------------------------------------------
					// Identifica que a fato foi processada. 
					//-------------------------------------------------------------------							
					AAdd( aEntity, aFact[nFact] )
	
					//-------------------------------------------------------------------
					// Destroi a inst�ncia da fato. 
					//-------------------------------------------------------------------				
					oFact:Destroy()				
					FreeObj( oFact )
				EndIf
			EndIF
		Next nFact
	EndIf

	BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "]" + " " + STR0004 ) //"Processo finalizado"
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} Sort
Ordena a lista de entidades para que seja minimizada a concorr�ncia 
na acesso as tabelas do banco de dados.

@param aEntity, array, Lista de entidades.
@param nEntity, objeto, Entidade.
@return aEntity, Lista de entidades reordenada.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method Sort( aEntity, nEntity ) Class BIXRunner
	Local aAuxiliar	:= {}
	Local nPosition := 0

	Default aEntity	:= {}
	Default nEntity	:= {}

	If ( BIXHasLock( aEntity[nEntity], "RUN" ) )
		For nPosition := nEntity To Len( aEntity )
			If ! ( BIXHasLock( aEntity[nPosition], "RUN" ) ) 
				aAuxiliar 			:= aEntity[nEntity]
				aEntity[nEntity] 	:= aEntity[nPosition]
				aEntity[nPosition]	:= aAuxiliar

				Exit
			EndIf 
		Next nPosition
	EndIf
Return aEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Executa a extra��o de uma entidade. 

@param oEntity, objeto, Entidade.
@return lOk, Identifica se a entidade foi executada com sucesso.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method Run( oEntity ) Class BIXRunner
	Local oTopology   := nil
 	Local oRecord     := nil
 	Local oKey        := nil
 	Local oOutput     := nil
 	Local oSeeker     := nil
	Local oDate       := nil 
	Local oModel      := nil
	Local bError      := nil
	Local aDimension  := {}
	Local aDate       := {}
	Local aUnifier    := {}
	Local cError      := ""
	Local cTime       := ""
	Local cEntity     := ""
	Local nLock       := 0
	Local nDimension  := 0
	Local lOk         := .T.
	Local lRunning    := .T.
	
	Default oEntity	:= nil 
	
	bError := ErrorBlock( { | e | lOk := .F., cError := e:ErrorStack, Break( e ) } )
	oModel := oEntity:GetModel()

	If ! ( Empty( oModel ) )
		cEntity := oEntity:GetEntity()
  
 		//-------------------------------------------------------------------
		// Identifica que a entidade est� bloqueada. 
		//-------------------------------------------------------------------                            
		nLock := FCreate( BIXLock( "RUN", cEntity, .F. ), 1 ) 	

		//-------------------------------------------------------------------
		// Recupera o per�odo de extra��o das fatos. 
		//-------------------------------------------------------------------
		If ( oEntity:GetType( ) == FACT )
			oDate := BIXDate():New( ::dFrom, ::dTo, oModel:GetPeriod() )
			aDate := BIXGetPeriod( cEntity, { oDate:GetFrom( .T. ), oDate:GetTo( .T. ),, ::cProfile } )
		Else
			aDate := { DToS( ::dFrom ), DToS( ::dTo ) }
		EndIf		

		//-------------------------------------------------------------------
		// Atualiza o per�odo de extra��o da entidade. 
		//-------------------------------------------------------------------			
		BIXSavePeriodo( cEntity, aDate, oModel:IsSnapshot() )

		//-------------------------------------------------------------------
		// Atualiza o status da entidade. 
		//-------------------------------------------------------------------	
		BIXSaveParam( "STATUS", "RUNNING", cEntity )			
		
		cTime := Time()
		//-------------------------------------------------------------------
		// Identifica se deve executar a entidade. 
		//-------------------------------------------------------------------					
		If ( BIXCheckHistory( cEntity, .T. ) )		
			BEGIN SEQUENCE
				//-------------------------------------------------------------------
				// Inicia as depend�ncias. 
				//-------------------------------------------------------------------
			  	oOutput := BIXOutput():Build( oEntity ) 
			 	oRecord := BIXRecord():Build( oEntity )
			 	oSeeker := BIXSeeker():Build( oEntity )
			 	oKey    := BIXKey():Build( oEntity, oRecord )
			 	
				//-------------------------------------------------------------------
				// Executa o processo de extra��o. 
				//-------------------------------------------------------------------	
				BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "][" + cEntity  + "]" + " " + STR0005 ) //"Iniciada"			 	
			 	
			 	If ( oEntity:GetType( ) == FACT )			 	
					oTopology  := BIXTopology():New()	
					aDimension := oTopology:ListLookup( { cEntity } )
								 	
				 	While ( lRunning )
				 		For nDimension := 1 To Len( aDimension )
				 			lRunning := BIXHasLock( aDimension[nDimension], "RUN" )
				 			
				 			If ( lRunning )
				 				BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "][" + cEntity  + "]" + " " + STR0011 + aDimension[nDimension] ) //"Aguardando extra��o da dimens�o "		 				
				 				Sleep( 10000 )
				 				
				 				Exit
				 			EndIf 
				 		Next nDimension
				 	EndDo
				 	
				 	FreeObj( oTopology )
			 	EndIf

				If ( BIXIsDebug() )
					BIXSetLog( LOG_DEBUG, cEntity,,,,, STR0012 + ": " + If( oKey:lShare, STR0013, STR0014 ) ) //"TABELAS COMPARTILHADAS"###"Sim"###"N�o"

					//-------------------------------------------------------------------
					// Identifica se a consolida��o est� configurada para a entidade.
					//-------------------------------------------------------------------			
					aUnifier := BIXGetUnifier( cEntity )
					
					//-------------------------------------------------------------------
					// Loga o consolidador de dados.
					//------------------------------------------------------------------- 
					If ! Empty( aUnifier )
						BIXSetLog( LOG_DEBUG, cEntity,,,,, STR0015 + ": " + cBIConcatWSep( ", " + STR0016 + ": ", aUnifier ) ) //"Consolidador"###" Chave"
					EndIf
				EndIf

				If ( oEntity:GetType( ) == FACT )
					oEntity:Run( aDate[1], aDate[2], ::dToday, oOutput, oRecord, oSeeker )
				Else
					oEntity:SetUseLG( )
					oEntity:Run( aDate[1], aDate[2], ::dToday, oOutput, oRecord, oKey )
				EndIf

				//-------------------------------------------------------------------
				// Libera as depend�ncias. 
				//-------------------------------------------------------------------				
				oOutput:Destroy()
				oRecord:Destroy()
				oSeeker:Destroy()
				oKey:Destroy()
								
				FreeObj( oOutput )
				FreeObj( oRecord )
				FreeObj( oSeeker )
				FreeObj( oKey )
			RECOVER
				//----------------------------------------------------------------------------
				// Apresenta mensagem do erro que ocorreu no processo de extra��o da entidade.
				//----------------------------------------------------------------------------
				MSGStop( cError )

				//----------------------------------------------------------------------------
				// Seta vari�vel como false para atualizar o status corretamente da entidade.
				//----------------------------------------------------------------------------
				lOk := .F.
			END SEQUENCE
		Else
			BIXSetLog( LOG_UPDATED, cEntity, SToD( aDate[1] ), SToD( aDate[2] ) )
		EndIf

		//-------------------------------------------------------------------		
		// Identifica se a entidade foi executada com �xito.
		//-------------------------------------------------------------------
		If ( lOk )
			BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "][" + cEntity  + "]" + " " + STR0006 + cBIStr( ElapTime( cTime, Time( ) ) ) ) //"Finalizada em "

			//-------------------------------------------------------------------
			// Atualiza o status da entidade. 
			//-------------------------------------------------------------------
			BIXSaveParam( "STATUS", "OK", cEntity )
		Else
			BIXSysOut( "BIXRUNNER", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "][" + cEntity  + "]" + " " + STR0007 ) //"Finalizada com erro "
			
			//-------------------------------------------------------------------
			// Atualiza o status da entidade. 
			//-------------------------------------------------------------------
			BIXSaveParam( "STATUS", "ERROR", cEntity,,,,, cError )
		EndIf

 		//-------------------------------------------------------------------
		// Identifica que a entidade est� dispon�vel. 
		//-------------------------------------------------------------------  
		If ! ( nLock == -1 )
			FClose( nLock )  
			FErase( BIXLock( "RUN", cEntity, .F. ) )
		EndIf
	EndIf

	ErrorBlock( bError )	
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto e libera a mem�ria alocada. 

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method Destroy( ) Class BIXRunner
	ASize( ::aDimension, 0 )
	
	::cProfile		:= nil
	::dFrom			:= nil
	::dTo			:= nil
	::dToday		:= nil	
Return Self