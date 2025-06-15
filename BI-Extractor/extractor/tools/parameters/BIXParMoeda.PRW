#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPARAMETER.CH"

Static __oMoeda

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetMxF
MoeFato
Lista de moedas configuradas para uma fato.

@param cFact		Fato que será analisada.
@return aMoeda		Lista de moedas configuradas a fato.

@author  Márcia Junko
@version P12
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXGetMxF( cFact )
	Local aMoeda	:= {}
	Local cMoeda 	:= ""
	Local nMoeda	:= 0

	Default cFact	:= ""
	
	cMoeda := BIXParInfo( "BIX_MOEDA", "C", "", cFact ) 
	
	//-------------------------------------------------------------------
	// Recupera as moedas configuradas para a fato.  
	//-------------------------------------------------------------------
	aMoeda := aBIToken( cMoeda, ";", .F. )

	If ( Len( aMoeda ) == 0 )
		//-------------------------------------------------------------------
		// Define a moeda padrão.  
		//-------------------------------------------------------------------
		aAdd( aMoeda, "1" ) 
	EndIf 	

	//-------------------------------------------------------------------
	// Retorna o código da moeda no ERP e o código consolidado. 
	//------------------------------------------------------------------- 
	For nMoeda := 1 To Len( aMoeda )  
	  	aMoeda[ nMoeda ] := { aMoeda[nMoeda], BIXCMValue( aMoeda[nMoeda] ) }
  	Next nMoeda   	
Return aMoeda

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGrvCMoeda
Funcao Responsavel por Gravar o De / Para dos Codigos de Moeda
Se a Opcao de Chave Consolidada de Moeda For Habilitada

@protected
@author  Márcia Junko
@version P12 
@since   03/07/2015
@param aCMoeda, Vetor com as Informacoes de De / Para da Moeda
@param lCMoeda, Define se a Opcao de Chave Consolidada Esta Habilitada
@return Variavel Logica Informando se a Operacao foi realizada com Sucesso.
/*/
//-------------------------------------------------------------------
Function BIXGrvCMoeda( aCMoeda, lCMoeda )
	Local lRet        := .T.
	Local lFound      := .F.
	Local nInd        := 0
	Local nCount      := 0
	Local aArea       := GetArea()
	Local aMoeda      := BIXLoadMoeda()
	Local cHH1Alias   := GetNextAlias()
	
	If BIXLinkFSD() > 0
		BIXSetupTable( "HH1" )
		dbUseArea(.T., __cRdd, "HH1" , cHH1Alias , .T., .F.)
		( cHH1Alias )->( dbSetIndex( "HH11" ) )
		
		dbSelectArea( cHH1Alias )
		( cHH1Alias )->( dbSetOrder( 1 ) )
		
		If !lCMoeda
			For nInd := 1 To Len( aCMoeda )
				For nCount := 1 To Len( aMoeda )
					If ( cHH1Alias )->( dbSeek( xFilial( 'HH1' ) + cValToChar( aMoeda[ nCount ][ 01 ] ) ) )
						RecLock( ( cHH1Alias ), .F. )
						( cHH1Alias )->( dbDelete() )
						( cHH1Alias )->( MsUnLock() )
					EndIf
				Next nCount
			Next nInd
		EndIf
		
		For nInd := 1 To Len( aCMoeda )
			For nCount := 1 To Len( aMoeda )
				lFound := !( cHH1Alias )->( dbSeek( xFilial( 'HH1' ) + cValToChar( aMoeda[ nCount ][ 01 ] ) ) )
				
				If lCMoeda
					RecLock( cHH1Alias, lFound )
					( cHH1Alias )->HH1_FILIAL := xFilial( 'HH1' )
					( cHH1Alias )->HH1_CODERP := cValToChar( aMoeda[ nCount ][ 01 ] )
					( cHH1Alias )->HH1_MOEDES := aMoeda[ nCount ][ 02 ]
					( cHH1Alias )->HH1_CODCON := IIf( Empty( aCMoeda[ nInd  ][ nCount ] ), cValToChar( aMoeda[ nCount ][ 01 ] ) , aCMoeda[ nInd  ][ nCount ] )
					( cHH1Alias )->( MsUnLock() )
				EndIf
				
			Next nCount
		Next nInd
		
		IIf( Select( cHH1Alias ) > 0, ( cHH1Alias )->( dbCloseArea() ), Nil )
		BIXUnlinkFSD()
	EndIf
	
	RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCMValue
Retorna o código da moeda. Neste processo é verificado se a moeda é 
consolidada.
         
@param cMoeda, caracter, Código da moeda. 
@param nOption, numérico, Identifica se retorna o código ou a descrição. 
@return cResult, Código ou descrição da moeda 

@author  Valdiney V GOMES
@since   06/02/2017
/*/
//-------------------------------------------------------------------
Function BIXCMValue( cMoeda, nOption )
	Local aMoeda	:= {}
	Local cTemp		:= ""
	Local cResult  := ""
	Local cDML		:= ""
	Local nMoeda	:= 0
	Local lUnified  := .F. 
  
	Default cMoeda  	:= ""  
	Default nOption  	:= 1  

	If ( Empty( __oMoeda ) )
		__oMoeda := THashMap():New( )
	Endif

	If ! ( __oMoeda:Get( cBIStr( nOption ) + cMoeda, @cResult ) ) 
		//-------------------------------------------------------------------
		// Identifica se a moeda é consolidada.
		//-------------------------------------------------------------------		
		lUnified  := BIXParInfo( "BIX_CMOEDA", "L", .F. ) 
		
	 	If ! ( lUnified ) 
	 	 	If ( nOption == 1 )
	 	 		cResult := cMoeda
	 		Else
	 			aMoeda := BIXLoadMoeda()
	 		    nMoeda := Ascan( aMoeda,{ | x | cBIStr( x[ 01 ] ) == cMoeda } )
	 		    
	 			If ! ( nMoeda == 0 ) 
	 				cResult := aMoeda[nMoeda][ 2 ] 
	 			EndIf
	 		Endif 
	 	Else 
	 		//-------------------------------------------------------------------
	 		// Monta o DML. 
	 		//-------------------------------------------------------------------	
	 		cDML := " SELECT "
	 		cDML += "	HH1_CODCON, HH1_MOEDES" 
	 		cDML += " FROM HH1 "
	 		cDML += " WHERE "
	 		cDML += " 	HH1.HH1_CODERP = '" + cMoeda + "'"
	 		cDML += " 	AND "
	 		cDML += " 	HH1.HH1_FILIAL = '" + xFilial( "HH1" ) + "'"
	 		cDML += " 	AND "
	 		cDML += " 	HH1.D_E_L_E_T_ = ' '"
	
	 		//-------------------------------------------------------------------
	 		// Conecta na Fluig Smart Data. 
	 		//-------------------------------------------------------------------		 	
	 		If ! ( Empty( BIXLinkFSD() ) )  
	 			//-------------------------------------------------------------------
	 			// Executa o DML. 
	 			//-------------------------------------------------------------------	
				DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), cTemp := GetNextAlias(), .F., .T. ) 	
				
		    	//-------------------------------------------------------------------
		    	// Recupera o código da moeda consolidada. 
		    	//-------------------------------------------------------------------					
		    	If ! ( ( cTemp )->( Eof( ) ) )
		    		cResult := If( nOption == 1, ( cTemp )->HH1_CODCON, ( cTemp )->HH1_MOEDES )
		    	EndIf 

			   ( cTemp )->( DBCloseArea() )  
			   
			   	//-------------------------------------------------------------------
	 			// Desconecta da Fluig Smart Data. 
	 			//-------------------------------------------------------------------			    	
			    BIXUnlinkFSD()  
		    EndIf	 
	 	EndIf 
	 	
	 	__oMoeda:Set( cBIStr( nOption ) + cMoeda, cResult )
 	EndIf
Return cResult
