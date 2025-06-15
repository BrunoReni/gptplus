#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXOUTPUT.CH"
	
#DEFINE INSERT_LIMIT_DIM  	100
#DEFINE INSERT_LIMIT_FACT  	50

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOutput  
Classe responsável por representar a saída de dados de um processo de 
extração. Os registros enviados para o output do extrator são armazenados 
em um pool e posteriomente inseridos na Fluig Smart Data. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Class BIXOutput
	Data aPool
	Data cField
	Data cEntity
	Data nType
	Data cDatabase
	Data nRecord
	Data lEntryPoint
	Data lIsDim

	Method New( cEntity, nType, aField, aIndex, lUpdate ) CONSTRUCTOR
	Method Build( oEntity, lUpdate ) CONSTRUCTOR
	Method SetEntity( cEntity )
	Method SetDatabase( cDatabase )
	Method Send( oRecord ) 
	Method Pool( )
	Method GetEntity( )
	Method GetDatabase( )
	Method Release( )
	Method Truncate( )
	Method Destroy( )
EndClass 

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método contrutor.
  
@param cEntity, caracter, Entidade.
@param nType, caracter, Tipo da entidade.
@param aField, array, Campos da tabela da entidade.
@param aIndex, caracter, Índices da tabela da entidade.
@param lUpdate, boolean, Identifica se deve verificar a estrutura da tabela.
@Return Self, Instância da Classe.   

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method New( cEntity, nType, aField, aIndex, lUpdate ) Class BIXOutput 
	Default aField  := {}
	Default aIndex  := {}
	Default cEntity := ""
	Default nType   := 3 //Dimension
	Default lUpdate := .F. 
	
	::aPool       := {}	
	::cField      := ""	
	::cEntity     := cEntity
	::cDatabase   := TCGetDB( )
	::nType       := nType
	::nRecord     := 0
	::lEntryPoint := BIXHasEntryPoint( ::cEntity )
	::lIsDim	  := (::nType == DIMENSION ) 
	 
	
	IF ::lEntryPoint
		BIXRunUsrTab( ::cEntity )
	EndIf

	If ( lUpdate )
		If ! ( Empty( BIXLinkFSD( ) ) )				
			BIXTable( ::cEntity, aField, aIndex )
			
			If ( ::cDatabase $ "MSSQL" )
				TCSQLExec( "ALTER TABLE " + ::cEntity + " NOCHECK CONSTRAINT ALL" ) 
			EndIf
			
			BIXUnlinkFSD( )
		EndIf
	EndIf
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Build  
Método contrutor.
 
@param oEntity, objeto, Objeto de uma entidade.
@param lUpdate, boolean, Identifica se deve verificar a estrutura da tabela.
@Return Self, Instância da Classe.   

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Build( oEntity, lUpdate ) Class BIXOutput
	Local oModel	:= nil
	Local aField	:= {}
	Local aIndex	:= {}
	Local cEntity 	:= ""
	Local nType		:= ""
	
	Default oEntity	:= nil 
	Default lUpdate	:= .F.
	
	If ! ( Empty( oEntity ) )
		oModel 	:= oEntity:GetModel()
		cEntity	:= oEntity:GetEntity( ) 
		nType	:= oEntity:GetType( )
		
		If ! ( Empty( oModel ) )
			aField	:= oModel:GetField( )
			aIndex	:= oModel:GetIndex( )			
		EndIf
		
		::New( cEntity, nType, aField, aIndex, lUpdate )
	EndIf 
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetEntity 
Define a entidade.  

@param cEntity, caracter, Entidades. 
@Return cEntity, Entidade. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method SetEntity( cEntity ) Class BIXOutput
	Default cEntity := ""
	
	::cEntity := cEntity
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDatabase 
Define o tipo de banco de dados.  

@param cDatabase, caracter, Tipo de banco de dados.
@Return cDatabase, Tipo de banco de dados.

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method SetDatabase( cDatabase ) Class BIXOutput
	Default cDatabase := ""
	
	::cDatabase := cDatabase
Return ::cDatabase

//-------------------------------------------------------------------
/*/{Protheus.doc} Send  
Envia o registro para o pool de gravação. 

@param oRecord, objeto, Registro.

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Send( oRecord ) Class BIXOutput	
	Default oRecord := Nil
	
	//---------------------------------------------------------------
	// Execução dos pontos de entrada.
	//---------------------------------------------------------------
	If ( ::lEntryPoint )
		BIXRunEntryPoint( oRecord, ::lEntryPoint, ::cEntity, ::lIsDim )
	EndIf	

	::Pool( oRecord, Iif(::nType == DIMENSION, INSERT_LIMIT_DIM, INSERT_LIMIT_FACT ) )
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Pool  
Pool para gravação de registros em lote. 

@param oRecord, objeto, Registro.
@param nLimit, integer, Limite de armazemaneto do pool.
@param lLog, boolean, verifica se grava log em modo debug.

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Pool( oRecord, nLimit, lLog ) Class BIXOutput
	Local aRecord := {}
	Local aField  := {}
	Local aValue  := {}
	Local cDML    := ""
	Local nRecord := 0

	Default oRecord := nil
	Default nLimit  := 1
	Default lLog    := .F.

	//-------------------------------------------------------------------
	// Recupera os campos e valores do registro.
	//-------------------------------------------------------------------
	If ! ( Empty ( oRecord ) ) 
		If ( Empty ( ::cField ) )		
			aField	:= oRecord:listField( )
			
			If ! ( Empty( aField ) )
				::cField := BIXConcatWSep( ",", aField )
			EndIf
		EndIf

		aValue := oRecord:ListValue( )
	EndIf

	//-------------------------------------------------------------------
	// Insere o registro no pool de gravação.
	//-------------------------------------------------------------------
	If ! ( Empty( aValue ) )
		AAdd( ::aPool, aValue )
		::nRecord ++
	EndIf 

	//-------------------------------------------------------------------
	// Identifica se deve liberar o pool de gravação.
	//-------------------------------------------------------------------	
	If ( Len( ::aPool ) >= nLimit )	
		//-------------------------------------------------------------------
		// Monta a DML.
		//-------------------------------------------------------------------		
		If ( ::cDatabase $ "ORACLE" )
			cDML := " INSERT ALL "
			
			For nRecord := 1 to Len( ::aPool )			
				cDML += " INTO " + ::cEntity + " (" + ::cField + ")"
				cDML += " VALUES " + "(" + BIXConcatWSep( ",", ::aPool[nRecord] ) + ")"   
			Next nRecord
			
			cDML += " SELECT 1 FROM DUAL"						
		Else
			cDML := " INSERT INTO " + ::cEntity + " (" + ::cField + ")"
			
			For nRecord := 1 to Len( ::aPool )	
				AAdd( aRecord, "(" + BIXConcatWSep( ",", ::aPool[nRecord] ) + ")" ) 
			Next nRecord
			
			cDML +=	" VALUES " + BIXConcatWSep( ",", aRecord )		
		EndIf

		//-------------------------------------------------------------------
		// Limpa o pool.
		//-------------------------------------------------------------------
		aSize( ::aPool, 0 )

		//-------------------------------------------------------------------
		// Loga a instrução SQL de inclusão de registros.
		//-------------------------------------------------------------------
		If ( lLog )
			If ! ( Empty( cDML ) )
				BIXSetLog( LOG_DEBUG, ::cEntity,,,,, STR0002 + ": " + cDML ) //"REGISTROS"
			EndIf
		EndIf

		//-------------------------------------------------------------------
		// Conecta na Fluig Smart Data.
		//-------------------------------------------------------------------		
		If ! ( Empty( BIXLinkFSD() ) )
			//-------------------------------------------------------------------
			// Executa a DML.
			//-------------------------------------------------------------------	
			If ! ( TCSQLExec( cDML ) == 0 )
				cDML := BIXCleanText( cDML )
				
				//-------------------------------------------------------------------
				// Limpa o DML e tenta novamente.
				//-------------------------------------------------------------------
				If ! ( TCSQLExec( cDML ) == 0 )
					BIXSysOut( "BIXOUTPUT", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "][" + ::cEntity  + "]" + TCSQLError() )
				EndIf 
  			EndIf

			//-------------------------------------------------------------------
			// Desconecta da Fluig Smart Data.
			//-------------------------------------------------------------------			
			BIXUnlinkFSD()
		EndIf 
	
	 	//-------------------------------------------------------------------
		// Mata as variáveis do tipo array para diminuir o consumo de memória 
		//-------------------------------------------------------------------  		  
		If !Empty(aField)
			aSize(aField, 0)
			aField := Nil
		EndIf
		
		If !Empty(aRecord)
			aSize(aRecord, 0)
			aRecord := Nil
		EndIf
		
		If !Empty(aValue) 
			aSize(aValue, 0)
			aValue := Nil
		EndIf
	EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Truncate  
Limpa todos os dados da entidade. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Truncate( lDefault ) Class BIXOutput
	Local cDDL 		 := ""
	
	Default lDefault := .T. 
	
	//-------------------------------------------------------------------
	// Monta a DDL.
	//-------------------------------------------------------------------
	If ! ( AllTrim( GetSrvProfString( "BIMULTINSTANCE", "0" ) ) == "1" ) 
		cDDL := "TRUNCATE TABLE " + ::cEntity
	Else
		cDDL := " DELETE FROM " + ::cEntity 

		If ( lDefault )
			cDDL += " 	WHERE " 
			cDDL +=		::cEntity + "_ISTCIA = '" + BIXInstance() + "'"
			cDDL += " 	AND " 
			cDDL += 	::cEntity + "_LINPRO = '" + "P " + "'"
		EndIf 	
	EndIf 
	
	//-------------------------------------------------------------------
	// Conecta na Fluig Smart Data.
	//-------------------------------------------------------------------	
	If ! ( Empty( BIXLinkFSD() ) )			
		//-------------------------------------------------------------------
		// Executa a DDL.
		//-------------------------------------------------------------------
		If ! ( TCSQLExec( cDDL ) == 0 )
			BIXSysOut( "BIXOUTPUT", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "][" + ::cEntity  + "] " + TCSQLError() )
		EndIf

		//-------------------------------------------------------------------
		// Desconecta da Fluig Smart Data.
		//-------------------------------------------------------------------		
		BIXUnlinkFSD()
	EndIf
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Retorna a entidade. 

@Return cEntity, Entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetEntity() Class BIXOutput
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDatabase
Retorna o tipo de banco de dados. 

@Return cDatabase, Tipo de banco de dados.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetDatabase() Class BIXOutput
Return ::cDatabase

//-------------------------------------------------------------------
/*/{Protheus.doc} Release  
Libera o pool e grava os registros pendentes. 

@param lLog, boolean, Identifica se loga a operação. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Release( lLog ) Class BIXOutput
	Default lLog := .T. 
	
	If ( lLog )
		BIXSysOut( "BIXOUTPUT", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "][" + ::cEntity  + "] " +  cBIStr( ::nRecord ) + " " + STR0001 ) //" Registros extraídos"		
		BIXSetLog( LOG_RUNNING, ::cEntity,,,, ::nRecord ) 
	EndIf
	
	::Pool( , , lLog )
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy  
Destroi o objeto e libera a memória alocada. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Destroy() Class BIXOutput
	aSize( ::aPool, 0 )

	::aPool       := Nil
	::cField      := Nil
	::cEntity     := Nil
	::nType       := Nil
	::cDatabase   := Nil
	::nRecord     := Nil
	::lEntryPoint := Nil
	::lIsDim	  := Nil
Return nil