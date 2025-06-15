#INCLUDE "BIXEXTRACTOR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTopology
Classe responsável por representar a topologia dos extratores.

@author  Valdiney V GOMES
@since   10/02/2017
/*/
//-------------------------------------------------------------------
Class BIXTopology
	Data aTopology

	Method New( ) CONSTRUCTOR
	Method GetTopology( )
	Method ListEntity( nType )
	Method ListLookup( aFact )
	Method Destroy( )
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método contrutor.

@Return Self, Instância da Classe.

@author  Valdiney V GOMES
@since   10/02/2017
/*/
//-------------------------------------------------------------------
Method New( ) Class BIXTopology
	::aTopology	:= {}
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Build
Monta a topologia das entidades registradas. 

@param [aApp], array, Apps para relacionamento entre fatos e dimensões. 
@return aTopology, Relacionamento entre fatos e dimensões. 

@author  Valdiney V GOMES
@since   10/02/2017
/*/
//-------------------------------------------------------------------
Method GetTopology( aApp ) Class BIXTopology
	Local oFact			:= nil
	Local oEntity			:= nil
	Local oModel			:= nil
	Local aLookup			:= {}
	Local aRegister 		:= {}
	Local aFact			:= {}
	Local aFactLookup		:= {}
	Local aAppFact		:= {}
	Local nRegister		:= 0
	Local nFact			:= 0
	Local nLookup			:= 0
	Local aAuxFacts		:= {}
	Local aAuxDim			:= {}
	Local nPos				:= 0

	Default aApp	:= { }

	If ( Empty( ::aTopology ) )
		//-------------------------------------------------------------------
		// Recupera os apps registrados. 
		//-------------------------------------------------------------------
		aRegister := BIXRegister( )
		
		//-------------------------------------------------------------------
		// Recupera as fatos registradas. 
		//-------------------------------------------------------------------	
		aFact := ::ListEntity( FACT )
		
		For nRegister := 1 To Len( aRegister )
			aAppFact := {}
			aAuxFacts := {}
			
			//-------------------------------------------------------------------
			// Recupera as fatos atreladas ao APP. 
			//-------------------------------------------------------------------			
			aEval( aFact, {|x| iif( AScan( x[4], { | y | y == aRegister[nRegister][1] } ) > 0 , Aadd(aAuxFacts, {x[1], x[2]}), )})
			
			aFactLookup := { }

			For nFact := 1 to len(aAuxFacts)
				//-------------------------------------------------------------------
				// Recupera o objeto da fato. 
				//-------------------------------------------------------------------
				oFact := BIXObject( aAuxFacts[nFact][1] )
				
				If ! ( Empty( oFact ) )
					//-------------------------------------------------------------------
					// Recupera o modelo de dados da fato. 
					//-------------------------------------------------------------------
					oModel := oFact:GetModel( )
					
					If ! ( Empty( oModel ) )
						//-------------------------------------------------------------------
						// Recupera os lookups do modelo de dados. 
						//-------------------------------------------------------------------
						aLookup := oModel:GetLookup( )
		
						For nLookup := 1 To Len( aLookup )
							If (nPos := AScan( aAuxDim , { | x | x[1] == aLookup[nLookup][1] } ) ) == 0
								//-------------------------------------------------------------------
								// Recupera o objeto do lookup. 
								//-------------------------------------------------------------------
								oEntity := BIXObject( aLookup[nLookup][1]  )
		
								//-------------------------------------------------------------------
								// Lista as dimensões da fato. 
								//-------------------------------------------------------------------						
								If ! ( Empty( oEntity ) )
									AAdd( aFactLookup, { oEntity:GetEntity( ), oEntity:GetTitle( ), oEntity:GetTable( ) } )
									Aadd( aAuxDim, { oEntity:GetEntity( ), oEntity:GetTitle( ), oEntity:GetTable( ) } )
								EndIf 	
								
								//-------------------------------------------------------------------
								// Remove o lookup da memória. 
								//-------------------------------------------------------------------
								FreeObj( oEntity )
							Else
								If AScan( aFactLookup , { | x | x[1] == aLookup[nLookup][1] } ) == 0
									AAdd( aFactLookup, aClone(aAuxDim[nPos]) )
								EndIf
							EndIf
						Next nLookup
						
						//-------------------------------------------------------------------
						// Remove o lookup da memória. 
						//-------------------------------------------------------------------
						FreeObj( aLookup )						
					EndIf
					
					//-------------------------------------------------------------------
					// Lista as fatos do app. 
					//-------------------------------------------------------------------				
					If ! ( Empty( aFactLookup ) )
						AAdd( aAppFact, { oFact:GetEntity( ), oFact:GetTitle( ), oFact:GetTable( ), AClone( aFactLookup ) } )
					EndIf
	
					//-------------------------------------------------------------------
					// Remove a fato e o modelo da memória. 
					//-------------------------------------------------------------------
					FreeObj( oFact )
					FreeObj( oModel )
				EndIf
			Next nFact 
	
			//-------------------------------------------------------------------
			// Retorna a topologia dos extratores registrados. 
			//-------------------------------------------------------------------		
			If ! ( Empty( aAppFact ) )
				AAdd( ::aTopology, { aRegister[nRegister][1], aRegister[nRegister][2], AClone( aAppFact ) } )
			EndIf
		Next nRegister
	EndIf

Return ::aTopology

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntity
Recupera a lista de entidades registrada de acordo com o tipo informado. 

@param nType, numérico, Tipo de entidades que serão listadas.
@param cEntity, String, Entidade a ser pesquisada. Caso esse parâmetro seja setado, somente ele será procurado nos registros.
@return aEntity, Lista de entidades.   

@author  Valdiney V GOMES
@since   10/02/2017
/*/
//-------------------------------------------------------------------
Method ListEntity( nType, cEntity ) Class BIXTopology
	Local oEntity := nil 
	Local aFile   := {}	
	Local aEntity := {}
	Local nFile   := 0
	
	Default nType	:= 0
	Default cEntity := "*"

	If ( nType == APP )
		aEntity := BIXRegister( )
	Else
		//-------------------------------------------------------------------
		// Pesquisa todas as entidades registradas.
		//-------------------------------------------------------------------
		GetFuncArray( cEntity + "_BI_*",, aFile )
		
		If ! ( Empty( aFile ) )
			For nFile := 1 To Len( aFile )
				//-------------------------------------------------------------------
				// Instância cada entidada.
				//-------------------------------------------------------------------
				oEntity	:= BIXClass( aFile[nFile] )
	
				If ! ( Empty( oEntity ) )
					//-------------------------------------------------------------------
					// Retorna a lista de entidades encontradas.
					//-------------------------------------------------------------------
					If ( Empty( nType ) )
						AAdd( aEntity, { oEntity:GetEntity( ), oEntity:GetTitle( ), oEntity:GetTable( ), oEntity:GetApp( ) } )
					Else
						If ( oEntity:GetType( ) == nType )
							AAdd( aEntity, { oEntity:GetEntity( ), oEntity:GetTitle( ), oEntity:GetTable( ), oEntity:GetApp( ) } )
						EndIf
					EndIf
				EndIf
			Next nFile
		EndIf
	EndIf
Return aEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} ListLookup
Retorna a lista de lookups das fatos informadas. 

@param aFact, array, Lista de fatos.
@return aEntity, Lista de lookup das fatos.

@author  Valdiney V GOMES
@since   30/01/2017
/*/
//-------------------------------------------------------------------
Method ListLookup( aFact ) Class BIXTopology
	Local oFact		:= nil
	Local oEntity	:= nil 
	Local oModel	:= nil	
	Local aLookup	:= {}
	Local aEntity	:= {}
	Local nFact		:= 0
	Local nLookup	:= 0
			
	Default aFact 	:= {}

	For nFact := 1 To Len( aFact )
		//-------------------------------------------------------------------
		// Recupera o objeto da fato. 
		//-------------------------------------------------------------------
		oFact := BIXObject( aFact[nFact] ) 
	
		If ! ( Empty( oFact ) )	
			oModel := oFact:GetModel()
					
			If ! ( Empty( oModel ) )			
				//-------------------------------------------------------------------
				// Recupera a lista os lookups da fato. 
				//-------------------------------------------------------------------
				aLookup := oModel:GetLookup( )
			
				//-------------------------------------------------------------------
				// Lista os lookups. 
				//-------------------------------------------------------------------			
				For nLookup := 1 To Len( aLookup )									
					If ( Empty( AScan( aEntity, { | x | x == aLookup[nLookup][1] } ) ) )
						//-------------------------------------------------------------------
						// Recupera o objeto do lookup. 
						//-------------------------------------------------------------------
						oEntity := BIXObject( aLookup[nLookup][1]  )
						
						If ! ( Empty( oEntity ) )						
							AAdd( aEntity, oEntity:GetEntity() )

							//-------------------------------------------------------------------
							// Remove o lookup da memória. 
							//-------------------------------------------------------------------	
							FreeObj( oEntity )	
						EndIf 	
					EndIf			
				Next nLookup
			EndIf	
		EndIf
	Next nFact 
	
	//Compatibilidade com o Cognos
	If ! (AScan(aEntity, {| x | x == "HK2"}))
		AAdd(aEntity, "HK2")
	EndIf 
	
Return aEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy  
Destroi o objeto e libera a memória alocada. 

@author  Valdiney V GOMES
@since   10/02/2017
/*/
//------------------------------------------------------------------- 
Method Destroy() Class BIXTopology
	aSize( ::aTopology, 0 )

	::aTopology	:= nil
Return nil