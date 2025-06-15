#INCLUDE "BIXEXTRACTOR.CH"

#DEFINE FIELD 	1
#DEFINE VALUE 	2
#DEFINE TYPE 	3
#DEFINE LENGHT 	4
#DEFINE DECIMAL 5
#DEFINE KEY		6
#DEFINE OUTPUT	7


//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRecord  
Classe responsável por representar um registro. Um registro contém os 
campos fixos e os que são inseridos de forma dinâmica em um entidade. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Class BIXRecord
	Data oField
	Data aField
	Data cCompany
	Data cUnitBusiness
	Data _cFilial 
	Data cDatabase
	Data nType
	Data cFilOrig
	Data cGrpCompany
	Data lIsDim
	Data cEntity
	Data cTable
	Data cLastExec
	Data lUseLGI
	Data lUseLGA	

	Method New( cCompany, cUnitBusiness, _cFilial, cTable, aField, aUnifier, aLookup, nType, cEntity, cLastExec, lIsDim, lUnified ) CONSTRUCTOR
	Method Build( oEntity ) CONSTRUCTOR
	Method Init( lDefault )
	Method AddField( cField, cType, nLength, nDecimal, lKey, lOutput  )
	Method AddERPField( cTable ) 
	Method AddInternal( cKey, cTitle ) 
	Method SetValue( cField, uValue ) 
	Method GetValue( cField )
	Method GetStruct( lOutput )	
	Method ListField( lOutput )
	Method ListValue( lFormat )
	Method SetFilOrig( uValue ) 
	Method GetFilOrig( )
	Method SetUseLG( nType )
	Method GetUseLG( nType )
	Method ChkModify( )
	Method Destroy( ) 	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método contrutor.
 
@param cGrpCompany, caracter, Grupo de Empresa.
@param cCompany, caracter, Empresa da entidade.
@param cUnitBusiness, caracter, Unidade de negócio da entidade. 
@param _cFilial, caracter, Filial da entidade. 
@param cTable, caracter, Tabela da entidade.
@param oModel, objeto, Modelo de dados da entidade. 
@param aField, array, Campos do registro.
@param [aUnifier], array, Campos para consolidação de dados.
@param [aLookup], array, Campos chave dos lookups.
@param nType, numerico, 
;@param lUseFilOrig, lógico, Define se a entidade usa o conceito de filial origem
@param cEntity, caracter, Identificação da entidade
@param cLastExec, caracter, Data da última execução da entidade 
@param lIsDim, lógico, Determina se é a entidade é uma dimensão
@param lUnified, lógico, Determina se a entidade (dimensão), está consolidada. 
@Return self, Instância da Classe.    
  
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method New( cGrpCompany, cCompany, cUnitBusiness, _cFilial, cTable, aField, aUnifier, aLookup, nType, cEntity, cLastExec, lIsDim, lUnified ) Class BIXRecord
	Local aGroup	:= {}
	Local aKey		:= {}
	Local cKey		:= ""
	Local nKey		:= 0
	Local nLookup	:= 0
	Local nGroup	:= 0
	Local nField 	:= 0

	Default aLookup		  := {}
	Default aUnifier	  := {}
	Default aField 		  := {}	
	Default cCompany	  := ""
	Default cUnitBusiness := ""
	Default _cFilial	  := ""
	Default cTable		  := ""
	Default nType         := 0
	Default cGrpCompany	  := ""
	Default cEntity		  := ""
	Default cLastExec	  := ""
	Default lIsDim		  := .F.
	Default lUnified      := .F.

	//-------------------------------------------------------------------
	// Inicializa a estrutura do registro.
	//-------------------------------------------------------------------	
	::aField 		:= {}
	::oField		:= THashMap():New( )
	::cDatabase		:= TCGetDB( )
	::nType         := nType 
	::cFilOrig		:= ""
	::cEntity		:= cEntity
	::cTable		:= cTable
	::cLastExec	    := cLastExec
	::lIsDim		:= lIsDim
	::lUseLGI		:= Nil
	::lUseLGA		:= Nil	

	//-------------------------------------------------------------------
	// Verifica se entidade está consolidada.
	//------------------------------------------------------------------- 
	If ( lUnified )
		::cGrpCompany   := ""
		::cUnitBusiness	:= ""
		::cCompany		:= ""
		::_cFilial 		:= ""
	Else
		::cGrpCompany	:= cGrpCompany
		::cUnitBusiness	:= cUnitBusiness
		::cCompany		:= cCompany
		::_cFilial 		:= _cFilial
	EndIf
	
	//-------------------------------------------------------------------
	// Adiciona os campos do modelo de dados.
	//-------------------------------------------------------------------
	For nField := 1 to Len( aField )
		::AddField( aField[nField][1], aField[nField][2], aField[nField][3], aField[nField][4], aField[nField][5] )
	Next nField		
		
	//-------------------------------------------------------------------
	// Adiciona os campos da PK da tabela principal.
	//-------------------------------------------------------------------	
	If ! ( Empty( cTable ) )
		If ! ( cTable == "SX5" )
			cKey := BIXPk( cTable )
			
			If ( ! Empty( cKey ) )
				aKey := aBItoken( cKey, "+")
		
				For nKey := 1 to Len( aKey )	
					::AddERPField( aKey[nKey] )
				Next nKey
			EndIf
		EndIf
	EndIf	
		
	//-------------------------------------------------------------------
	// Adiciona os campos da PK das tabelas dos lookups.
	//-------------------------------------------------------------------
	For nLookup := 1 to Len( aLookup )
		If ! ( aLookup[nLookup][3] == "SX5" )
			If ! ( Empty( aLookup[nLookup][3] ) )
				cKey := BIXPk( aLookup[nLookup][3] )
				
				If ( ! Empty( cKey ) )
					aKey := aBItoken( cKey, "+")
			
					For nKey := 1 to Len( aKey )	
						::AddERPField( aKey[nKey] )
					Next nKey
				EndIf	
			EndIf
		EndIf
	Next nLookup
	
	//-------------------------------------------------------------------
	// Adiciona os campos dos consolidadores.
	//-------------------------------------------------------------------	
	If ! ( Empty( aUnifier) )
		aGroup := aUnifier[2]
	
		For nGroup := 1 to Len( aGroup )
			For nField := 1 To Len ( aGroup[nGroup][2] )
				::AddERPField( aGroup[nGroup][2][nField] )
			Next nField		
		Next nGroup		
	EndIf		
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Build  
Método contrutor.
 
@param oEntity, objeto, Objeto de uma entidade.
@Return Self, Instância da Classe.   

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Build( oEntity ) Class BIXRecord
	Local aField      := {}
	Local aUnifier    := {}
	Local aLookup     := {}
	Local cTable      := ""
	Local _cFilial    := ""
	Local oModel      := nil
	Local cGrpCompany := ""
	Local lShare	  := .F.
	Local cEmpinfo	  := ""
	Local cShare	  := ""
	Local cEmpInfo	  := ""
	Local cEntity	  := ""
	Local lIsDim      := .F.
	Local cLastExec   := ""
	Local lUseLGI     := .F.
	Local lUseLGA     := .F.
	
	Default oEntity   := nil 
	
	If ! ( Empty( oEntity ) )
		oModel        := oEntity:GetModel() 
		cTable        := oEntity:GetTable() 
		_cFilial      := oEntity:Filial() 
		cUnitBusiness := oEntity:GetUnitBusiness() 
		cCompany      := oEntity:GetCompany() 
		nType         := oEntity:GetType()
		cEntity		  := oEntity:GetEntity()
		cLastExec     := oEntity:GetExec()
		lIsDim        := ( oEntity:GetType() == DIMENSION )
		lShare        := oEntity:GetUseShare()
		lUnified      := oEntity:GetUnified( ) 
		
		If ! ( Empty( oModel ) )
			aField   := oModel:GetField( )
			aUnifier := oModel:GetUnifier( )
			aLookup  := oModel:GetLookup( )
		EndIf

		If lShare		
			cTable := oEntity:GetTable()
			
			//-------------------------------------------------------------------
			// Identifica se a tabela de origem da entidade está no dicionário.
			//-------------------------------------------------------------------
			If ( ! Empty( cTable ) ) .And. ( AliasInDic( cTable ) )
				cShare := AllTrim( FWSX2Util():GetFile( cTable ) )	
				cEmpInfo := Subs( cShare, 4, 2)								
			EndIf
		EndIf
		
		If Empty( cEmpInfo )
			cEmpInfo := cEmpAnt
		EndIf
	
		::New( cEmpInfo, cCompany, cUnitBusiness, _cFilial, cTable, aField, aUnifier, aLookup, nType, cEntity, cLastExec, lIsDim, lUnified) 
	EndIf 
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Init  
Prepara o registro para inclusão de valores, o método Init deve ser 
invocado a cada novo registro incluído. 

@param [lDefault], lógico, Identifica se utiliza valor padrão dos campos do framework. 
 
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Init( lDefault ) Class BIXRecord
	Local cField	:= ""
	Local uValue	:= nil 	
	Local nField 	:= 1
	
	Default lDefault	:= .T. 

	For nField := 1 to Len( ::aField )
		If ( ::aField[nField][TYPE] == "C" )
			//-------------------------------------------------------------------
			// Identifica se utiliza o valor padrão dos campos do framework.
			//-------------------------------------------------------------------			
			If( lDefault )			
				//-------------------------------------------------------------------
				// Recupera os atributos do campo.
				//-------------------------------------------------------------------
				cField 	:= ::aField[nField][FIELD]
				uValue	:= ::aField[nField][VALUE]

				Do Case		
					//-------------------------------------------------------------------
					// Identifica se é um campo do framework e atribui o valor padrão.
					//-------------------------------------------------------------------		
					Case ( "_ISTCIA" $ cField )
						If ( Empty( uValue ) )
							uValue := BIXInstance()
						EndIf
					Case ( "_LINPRO" $ cField )
						If ( Empty( uValue ) )
							uValue := "P "
						EndIf
					Case ( "_FILIAL" $ cField )
						If ( Empty( uValue ) )
							uValue := ::_cFilial
						EndIf
					Case ( "_GRPEMP" $ cField )
						If ( Empty( uValue ) )
							uValue := ::cGrpCompany
						EndIf
					Case ( "_CDUNEG" $ cField )
						If ( Empty( uValue ) )
							uValue := ::cUnitBusiness
						EndIf
					Case ( "_CDEMPR" $ cField )
						If ( Empty( uValue ) )
							uValue := ::cCompany
						EndIf
					OtherWise
						uValue := ""
				EndCase
			Else
				uValue := ""
			Endif
		ElseIf ( ::aField[nField][TYPE] == "N" )
			uValue := 0
		ElseIf ( ::aField[nField][TYPE] == "D" )
			uValue := cToD("")
		EndIf
	
		//-------------------------------------------------------------------
		// Inicializa o valor do campo do registro.
		//-------------------------------------------------------------------	
		::aField[nField][VALUE] := uValue
	Next nField 
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddField  
Insere um novo campo no registro. 

@param cField, caracter, Nome do campo. 
@param cType, caracter, Tipo do campo. 
@param nLength, numérico, Tamanho do campo. 
@param nDecimal, numérico, Tamanho do parte decimal do campo. 
@param lKey, lógico, IdentIfica se o campo é chave. 
@param lOutput, lógico, IdentIfica se o campo será persistido. 
@Return aField, Lista de campos. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method AddField( cField, cType, nLength, nDecimal, lKey, lOutput ) Class BIXRecord
	Local uValue		:= nil	
	Local nField		:= 0

	Default cField		:= ""
	Default cType		:= ""
	Default	nLength		:= 0
	Default	nDecimal	:= 0
	Default lKey		:= .F. 
	Default lOutput		:= .T.
	
	nField := AScan( ::aField, {|x| x[FIELD] == cField } )
	
	If ( Empty( nField ) )
		AAdd( ::aField, { cField, uValue, cType, nLength, nDecimal, lKey, lOutput } )
		::oField:Set( cField, Len( ::aField ) )
	EndIf 
Return ::aField

//-------------------------------------------------------------------
/*/{Protheus.doc} SetValue  
Insere um valor em um campo do registro. 
  
@param cField, caracter, Nome do campo.   
@param uValue, indefinido, Valor a ser inserido no campo.
@Return uValue, Valor inserido no campo.   
  
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method SetValue( cField, uValue ) Class BIXRecord
	Local nField 	:= 0
	
	Default cField	:= ""
	Default uValue	:= nil

	If ( ::oField:Get( cField, @nField ) )
		::aField[nField][VALUE] := uValue
	EndIf
Return uValue

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValue  
Retorna o valor de um campo do registro. 
 
@param cField, caracter, Nome do campo. 
@Return uValue, Valor do campo.  
 
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method GetValue( cField ) Class BIXRecord
	Local uValue	:= nil 
	Local nField 	:= 0
	
	If ( ::oField:Get( cField, @nField ) )
		uValue := ::aField[nField][VALUE]
	EndIf
Return uValue

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStruct  
Retorna a estrutura do registro. 

@param lOutput, lógico, Identifica se deve retornar apenas campos graváveis. 
@Return aField, Estrutura do registro.

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method GetStruct( lOutput ) Class BIXRecord
	Local aField 	:= {}
	Local nField 	:= 1
	
	Default lOutput	:= .T.
	
	If( lOutput )
		For nField := 1 to Len( ::aField )
			If ( ::aField[nField][OUTPUT] )
				AAdd( aField, ::aField[nField] )
			EndIf
		Next nField 
	Else
		aField := ::aField
	EndIf	
Return aField

//-------------------------------------------------------------------
/*/{Protheus.doc} ListField  
Retorna os campos do registro. 

@param lOutput, lógico, Identifica se deve retornar apenas campos graváveis. 
@Return aField, Lista de campos do registro.  
 
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method ListField( lOutput ) Class BIXRecord
	Local aField 	:= {}
	Local nField 	:= 1
	
	Default lOutput	:= .T.

	For nField := 1 to Len( ::aField )
		If( lOutput )
			If ( ::aField[nField][OUTPUT] )
				AAdd( aField, ::aField[nField][FIELD] )
			EndIf
		Else
			AAdd( aField, ::aField[nField][FIELD] )
		EndIf 
	Next nField 
Return aField

//-------------------------------------------------------------------
/*/{Protheus.doc} ListValue   
Retorna os valores dos campos do registro. 

@param lFormat, caracter, IdentIfica se deve retornar o valor formatado. 
@Return aValue, Lista de campos do registro. 
 
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method ListValue( lFormat ) Class BIXRecord
	Local aRecord 	:= {}
	Local nField 	:= 1
	Local uValue	:= nil
	Local lUseFilOrig := SuperGetMV("MV_BIXFORI", .F., .F.)
	
	Default lFormat	:= .T. 

	For nField := 1 to Len( ::aField )
		If ( ::aField[nField][OUTPUT] )
			//-------------------------------------------------------------------
			// Identifica se o campo deve ser formatado para gravação.
			//-------------------------------------------------------------------
			If ( lFormat ) 
				uValue 	:= ::aField[nField][VALUE] 

				If ( ::aField[nField][TYPE] == "C" ) 
					uValue := StrTran( uValue, Chr(09), "" ) //"Tab"
					uValue := StrTran( uValue, Chr(10), "" ) //"Line Feed"
					uValue := StrTran( uValue, Chr(13), "" ) //"Carriage Return"
					uValue := StrTran( uValue, "'", "''" ) //"Apóstrofe"	
				
					//-------------------------------------------------------------------
					// Identifica se o campo é chave. 
					//-------------------------------------------------------------------
					If ( ::aField[nField][KEY] )
						//-------------------------------------------------------------------
						// Codifica em MD5 chaves que excedem o tamanho do campo. 
						//-------------------------------------------------------------------
						If ( Len( Trim( uValue ) ) > ::aField[nField][LENGHT] )
							uValue := Upper( MD5( uValue, 2 ) )
						EndIf 
						
						AAdd( aRecord, "'" + PadR( uValue, ::aField[nField][LENGHT] ) + "'" ) 
					Else
						If ! ( "_LINPRO" $ ::aField[nField][FIELD] )
							//-------------------------------------------------------------------
							// Não dá ALLTRIM no código para não afetar a pesquisa e a integridade
							// dos registros
							//-------------------------------------------------------------------
							If !( "_CODIGO" $ ::aField[nField][FIELD] ) 
								uValue := AllTrim( uValue )
							Else
								uValue := RTrim( uValue )
							EndIf
							
							If ( "_DESC" $ ::aField[nField][FIELD] ) .or. ( "_NOME" $ ::aField[nField][FIELD])
								If ( ::nType == DIMENSION ) .And. ! Empty( uValue )
									uValue := BIXCleanText( uValue ) 
								EndIf
							ElseIf "_FILIAL" $ ::aField[nField][FIELD]
								
							 	If lUseFilOrig .and. !(Subs(::aField[nField][FIELD], 1, 3) == "HKK")
								 	If !Empty( ::cFilOrig )
								 		uValue := ::cFilOrig
								 	Else
								 		uValue := ' '
								 	EndIf
								EndIf
							EndIf 
							
							//-------------------------------------------------------------------
							// Identifica o tipo do banco de dados. 
							//-------------------------------------------------------------------                                                                                                                                                                                      
							If ( ::cDatabase $ "ORACLE" )
								If ( Empty( uValue ) )
									//-------------------------------------------------------------------
									// Impede a inserção de valores NULL. 
									//-------------------------------------------------------------------          
									uValue := ' '
								EndIf 
							EndIf
						EndIf
					
						AAdd( aRecord, "'" + Left( uValue, ::aField[nField][LENGHT] ) + "'" ) 
					EndIf 
				Else
					If ( ::aField[nField][TYPE] == "D" )
						//-------------------------------------------------------------------
						// Converte campos do tipo data em caracter. 
						//-------------------------------------------------------------------	
						AAdd( aRecord, "'" + DToS( uValue ) + "'" )  
					ElseIf ( ::aField[nField][TYPE] == "N" )
						//-------------------------------------------------------------------
						// Converte campos numérico em caracter. 
						//-------------------------------------------------------------------	
						AAdd( aRecord, cBIStr( uValue ) ) 
					EndIf 
				EndIf		
			Else
				AAdd( aRecord, ::aField[nField][VALUE] )
			EndIf
		EndIf
	Next nField 
Return aRecord

//-------------------------------------------------------------------
/*/{Protheus.doc} AddERPField  
Adiciona campos do dicionário de dados no registro.
  
@param cField, caracter, Campo do dicionáriod de dados.   
@Return aField, Lista de campos.  
  
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method AddERPField( cField ) Class BIXRecord
	Local cType		:= ""
	Local nLenght	:= 0
	Local nDecimal	:= 0

	Default cField	:= ""
	
	//-------------------------------------------------------------------
	// Ignora o campo filial. 
	//-------------------------------------------------------------------
	If ( ! Empty( cField ) .And. ! "_FILIAL" $ cField )
		SX3->( DBSetOrder( 2 ) )

		//-------------------------------------------------------------------
		// Localiza o campo no dicionário de dados. 
		//-------------------------------------------------------------------
		If ( SX3->( MSSeek( cField ) ) )
			//-------------------------------------------------------------------
			// Recupera os atributos do campo. 
			//-------------------------------------------------------------------
			cType		:= SX3->X3_TIPO
			nLenght		:= SX3->X3_TAMANHO
			nDecimal	:= SX3->X3_DECIMAL

			//-------------------------------------------------------------------
			// Lista o campo recupera do dicionário. 
			//-------------------------------------------------------------------
			::AddField( AllTrim( cField ), cType, nLenght, nDecimal, .F., .F. )		
		EndIf 		
	EndIf				
Return ::aField

//-------------------------------------------------------------------
/*/{Protheus.doc} AddInternal  
Insere o registro interno com o valor e descrição informada.

@param cKey, caracter, Valor para montagem da chave.   
@param cTitle, caracter, Descrição para os campos do registro. 
@Return aField, Lista de campos. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method AddInternal( cKey, cTitle ) Class BIXRecord
	Local oKey		:= nil
	Local cField	:= ""
	Local nField 	:= 1
	Local uValue	:= nil 	

	Default cKey 	:= ""
	Default cTitle 	:= ""

	For nField := 1 to Len( ::aField )
		If ( ::aField[nField][TYPE] == "C" )
			//-------------------------------------------------------------------
			// Recupera o campo do registro. 
			//-------------------------------------------------------------------
			cField 	:= ::aField[nField][FIELD]
			
			Do Case		
				//-------------------------------------------------------------------
				// Define o valor dos campos obrigatórios. 
				//-------------------------------------------------------------------	
				Case ( "_ISTCIA" $ cField )
					uValue := BIXInstance()
				Case ( "_LINPRO" $ cField )
					uValue := "P "
				Case ( "_FILIAL" $ cField )
					uValue := "__"
				OtherWise
					//-------------------------------------------------------------------
					// Define o valor da surrogate key. 
					//-------------------------------------------------------------------
					If ( ::aField[nField][KEY] )
						oKey   := BIXKey():New()
						uValue := oKey:GetKey( { cKey } )

						FreeObj( oKey )
					Else
						uValue := cTitle
					EndIf
			EndCase
		ElseIf ( ::aField[nField][TYPE] == "D" )
			uValue := SToD( "18000101" )
		ElseIf ( ::aField[nField][TYPE] == "N" )
			uValue := 0

		ElseIf ( aFields[nField, FIELD_TYPE] == "L" )
			uValue := 'F'
		EndIf
		
		//-------------------------------------------------------------------
		// Inicializa o valor do campo do registro.
		//-------------------------------------------------------------------	
		::aField[nField][VALUE] := uValue
	Next nField 
Return ::aField

//-------------------------------------------------------------------
/*/{Protheus.doc} SetValue  
Insere um valor em um campo do registro. 
  
@param cField, caracter, Nome do campo.   
@param uValue, indefinido, Valor a ser inserido no campo.
@Return uValue, Valor inserido no campo.   
  
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method SetFilOrig( uValue ) Class BIXRecord
	Default uValue	:= nil

	If ! (  uValue == nil )
		::cFilOrig := uValue
	EndIf
Return uValue

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValue  
Retorna o valor de um campo do registro. 
 
@param cField, caracter, Nome do campo. 
@Return uValue, Valor do campo.  
 
@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method GetFilOrig(  ) Class BIXRecord
Return ::cFilOrig

//-------------------------------------------------------------------
/*/{Protheus.doc} AddInternal  
Insere o registro interno com o valor e descrição informada.

@Return lEnd, Identifica se chegou ao fim da tabela temporária 

@author  Marcia Junko
@since   07/06/2017
/*/
//------------------------------------------------------------------- 
Method GetUseLG( nType ) Class BIXRecord
	Local lRet := .F.
	
	Default nType := 1
	
	If nType == 1
		If ::lUseLGI == Nil
			lRet := ::SetUseLG( 1 )
		Else
			lRet := ::lUseLGI
		Endif
	Else
		If ::lUseLGA == Nil
			lRet := ::SetUseLG( 2 )
		Else
			lRet := ::lUseLGA
		Endif
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AddInternal  
Insere o registro interno com o valor e descrição informada.

@Return lEnd, Identifica se chegou ao fim da tabela temporária 

@author  Marcia Junko
@since   07/06/2017
/*/
//------------------------------------------------------------------- 
Method SetUseLG( nType ) Class BIXRecord
 	Local aArea  := GetArea()
	Local lUseLG := .F.
	Local cField := ""
		
   	Default nType := 1

	DBSelectArea( ::cTable ) 	

	cField := BIXLogField( ::cTable, Iif( nType == 1, "USERLGI", "USERLGA" ) )

	//-------------------------------------------------------------------
	// Localiza os campos do log de registro. 
	//-------------------------------------------------------------------
   lUseLG := ( ::cTable )->( FieldPos( cField ) ) > 0
   
   If nType == 1
   		::lUseLGI := lUseLG
   	Else
   		::lUseLGA := lUseLG
   	EndIf
	RestArea( aArea )
Return lUseLG


//-------------------------------------------------------------------
/*/{Protheus.doc} AddInternal  
Insere o registro interno com o valor e descrição informada.

@Return lEnd, Identifica se chegou ao fim da tabela temporária 

@author  Marcia Junko
@since   07/06/2017
/*/
//------------------------------------------------------------------- 
Method ChkModify( cInsert, cUpdate ) Class BIXRecord
 	Local aArea   := GetArea()
 	Local cDataI  := ""
 	Local cDataA  := ""
	Local lUseLGI := .F.
	Local lUseLGA := .F.
	Local lExec   := .F.
	
   	Default cInsert := ""
   	Default cUpdate := ""
    
	If ::lIsDim
		lUseLGI := ::GetUseLG( 1 )
		lUseLGA := ::GetUseLG( 2 )
		cDataI  := BIXLeLg( cInsert )
 		cDataA  := BIXLeLg( cUpdate )

		If ( Empty(::cLastExec) .Or. ( !lUseLGI .And. !lUseLGA ) .Or. ( ( lUseLGI .And. ( cDataI >= ::cLastExec) ) .Or. ( lUseLGA .And. ( cDataA >= ::cLastExec ) ) ) )
			lExec := .T.
		EndIf
		RestArea( aArea )
	EndIf 
Return lExec

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy  
Destroi o objeto e libera a memória alocada. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Destroy() Class BIXRecord
	aSize( ::aField, 0 )
	HMClean( ::oField )
	
	::oField		:= nil
	::aField		:= nil
	::cCompany		:= nil
	::cUnitBusiness	:= nil
	::_cFilial		:= nil
	::cLastExec	    := nil
Return nil
