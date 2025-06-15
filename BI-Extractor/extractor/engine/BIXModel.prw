#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMODEL.CH"

#DEFINE FIELD 1
#DEFINE TYPE 2
#DEFINE LENGHT 3
#DEFINE DECIMAL 4
#DEFINE KEY 5
#DEFINE LOOKUP 6

Static __aLookup := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXModel
Classe reponsável por representar o modelo de uma entidade. O modelo
contém a representaçãode todas as características fixas de uma entidade.

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Class BIXModel
	Data aField
	Data aLookup
	Data aUnifier
	Data aBK
	Data cSK
	Data cEntity
	Data nType
	Data nPeriod
	Data lSnapshot
	Data lUndefined
	Data lFormula
	Data lDefault

	Method New( nType, cEntity, lDefault ) CONSTRUCTOR
	Method Build( oEntity ) CONSTRUCTOR
	Method SetEntity( cEntity )
	Method SetType( nType )
	Method SetSK( cSK ) 
	Method SetBK( aBK ) 
	Method SetPeriod( nPeriod )		
	Method AddField( cField, nType, nLength, nDecimal, lKey, cLookup )  
	Method DefaultField( ) 
	Method FreeField( )
	Method AddUnifier( aField, cTitle )
	Method GetEntity( )
	Method GetType( )
	Method GetField( )
	Method GetIndex( )
	Method GetLookup( )	
	Method GetUnifier( )	
	Method GetPeriod( )
	Method GetBK( ) 
	Method GetSK( )
	Method IsSnapshot( lSnapshot )
	Method HasUndefined( lUndefined )
	Method HasFormula( lFormula )
	Method HasDefault( )
	Method Destroy( ) 	
	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método contrutor.
 
@param nType, caracter, Tipo da entidade. 
@param cEntity, caracter, Entidade.
@param [lDefault], lógico, Identifica se devem ser criados os campos obrigatórios. 
@Return Self, Instância da Classe.   

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method New( nType, cEntity, lDefault ) Class BIXModel
	Default cEntity 	:= ""
	Default nType 		:= ""
	Default lDefault	:= .T.
	
	::aField		:= {}
	::aLookup		:= {}
	::aUnifier		:= {}
	::aBK			:= {}
	::cSK			:= ""
	::cEntity		:= cEntity
	::nType			:= nType
	::nPeriod		:= PERIOD_RANGE
	::lSnapshot		:= .F. 
	::lUndefined	:= .T. 
	::lFormula		:= .F. 
	::lDefault		:= lDefault
	
	If ( lDefault )
		::DefaultField()
	EndIf
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Build  
Método contrutor.
 
@param oEntity, objeto, Objeto de uma entidade.
@param [lDefault], lógico, Identifica se devem ser criados os campos obrigatórios. 
@Return Self, Instância da Classe.   

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Build( oEntity, lDefault ) Class BIXModel
	Local cEntity 	:= ""
	Local nType		:= ""
	
	Default oEntity		:= nil 
	Default lDefault	:= .T. 
	
	If ! ( Empty( oEntity ) )
		cEntity	:= oEntity:GetEntity() 
		nType	:= oEntity:GetType()
	
		::New( nType, cEntity, lDefault )
	EndIf 
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetEntity
Define a entidade. 

@param cEntity, Entidade. 
@Return cEntity, Retorna a entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetEntity( cEntity ) Class BIXModel
	Default cEntity := ""
	
	::cEntity := cEntity
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} SetType
Define o tipo da entidade. 

@param nType, numérico, Tipo da entidade.
@Return nType, Retorna a entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetType( nType ) Class BIXModel
	Default nType := ""
	
	::nType := nType
Return ::nType

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSK 
IdentIfica o campo que armazena a surrogate key da entidade. 

@param cSK, caracter, Campo que armazena a surrogate key da entidade.
@Return cSK, Campo que armazena a surrogate key da entidade. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method SetSK( cSK ) Class BIXModel
	Default cSK := ""
	
	::cSK := cSK
Return ::cSK

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBK  
IdentIfica o campo que armazena a business key da entidade.

@Return aBK, array, Campo que armazena a business key da entidade.
@Return aBK, Campo que armazena a business key da entidade.

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method SetBK( aBK ) Class BIXModel
	Default aBK := {}

	::aBK := aBK
Return ::aBK

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPeriod  
Identifica o período de extração de uma entidade. 

@Return nPeriod, numérico, Período de extração de uma entidade.
@Return nPeriod, Período de extração de uma entidade.

@author  Valdiney V GOMES
@since   26/01/2017
/*/
//------------------------------------------------------------------- 
Method SetPeriod( nPeriod ) Class BIXModel
	Default nPeriod := PERIOD_RANGE

	::nPeriod := nPeriod
Return ::nPeriod

//-------------------------------------------------------------------
/*/{Protheus.doc} AddField  
Insere um campo no modelo. 

@param cField, caracter, Nome do campo. 
@param nType, caracter, Tipo do campo. 
@param nLength, numérico, Tamanho do campo. 
@param nDecimal, numérico, Tamanho do parte decimal do campo. 
@param lKey, lógico, Identifica se o campo é chave. 
@param cLookup, caracter, Identifica o lookup para o campo.
@Return aField, Lista de campos.

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method AddField( cField, nType, nLength, nDecimal, lKey, cLookup ) Class BIXModel
	Local nField		:= 0
	
	Default cField		:= ""
	Default nType		:= ""
	Default cLookup		:= ""
	Default	nLength		:= 0
	Default	nDecimal	:= 0
	Default lKey		:= .F. 

	nField := AScan( ::aField, { |x| x[1] == cField } )
	
	If ( Empty( nField ) )
		//-------------------------------------------------------------------
		// Identifica se o campo é chave.
		//-------------------------------------------------------------------	
		If ( AllTrim( cField ) == AllTrim( ::cSK )  )
			lKey := .T. 
		EndIf 
	
		AAdd( ::aField, { AllTrim( cField ), nType, nLength, nDecimal, lKey, cLookup } )
	EndIf 
Return ::aField

//-------------------------------------------------------------------
/*/{Protheus.doc} AddUnifier  
Adiciona um consolidador. 

@param aField, array, Campo consolidador. 
@param cTitle, array, Título do consolidador. 
@Return aUnifier, Lista de campos para consolidação. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method AddUnifier( aField, cTitle ) Class BIXModel
	Local nUnifier	:= 0
	
	Default aField	:= {}
	Default cTitle	:= ""

	nUnifier := AScan( ::aUnifier, {|x| cBIStr( x[1] ) == cBIStr( aField ) } )
	
	If ( Empty( nUnifier ) )
		If ( Empty( ::aUnifier ) )
			AAdd( ::aUnifier, { ::cSK, { }, STR0004 } ) //"Inconsolidado"
		EndIf
	
		AAdd( ::aUnifier, { ::cSK, aField, cTitle } )
	EndIf 
Return ::aUnifier

//-------------------------------------------------------------------
/*/{Protheus.doc} DefaultField  
Adiciona os campos padrão no modelo de dados.  

@Return aField, Lista de campos.

@author  Valdiney V GOMES
@since   20/01/2017
/*/
//------------------------------------------------------------------- 
Method DefaultField( ) Class BIXModel
	Local aField 	:= {}
	Local nField	:= 0

	//-------------------------------------------------------------------
	// Define a estrutura dos campos padrão.
	//-------------------------------------------------------------------	
 	AAdd( aField, { "_ISTCIA" , "C", 02, 0 } )
 	AAdd( aField, { "_LINPRO" , "C", 02, 0 } )
 	AAdd( aField, { "_FILIAL" , "C", FWSizeFilial(), 0 } )	
	
	 If ( ::nType == DIMENSION )
		//-------------------------------------------------------------------
		// Define a estrutura dos campos padrão das dimensões.
		//-------------------------------------------------------------------
		AAdd( aField, { "_GRPEMP" , "C", 10, 0 } )
 		AAdd( aField, { "_CDUNEG" , "C", 10, 0 } )
 		AAdd( aField, { "_CDEMPR" , "C", 10, 0 } )	
	EndIf  

	//-------------------------------------------------------------------
	// Adiciona os campos do framework no modelo.
	//-------------------------------------------------------------------
	For nField := 1 To Len( aField )
		::AddField( AllTrim( ::cEntity ) + aField[nField][1], aField[nField][2], aField[nField][3], aField[nField][4] )
	Next nField
Return ::aField


//-------------------------------------------------------------------
/*/{Protheus.doc} FreeField  
Adiciona os campos livres no modelo de dados. 

@Return aField, Lista de campos. 

@author  Valdiney V GOMES
@since   20/01/2017
/*/
//------------------------------------------------------------------- 
Method FreeField( ) Class BIXModel
	Local aField 	:= {}
	Local nField	:= 0
	
	//-------------------------------------------------------------------
	// Define a estrutura dos campos livre das fatos.
	//-------------------------------------------------------------------	
 	If ( ::nType == FACT  )
	 	AAdd( aField, { "_LIVRE0", "N", 16, 4 } )
	    AAdd( aField, { "_LIVRE1", "N", 16, 4 } )
	    AAdd( aField, { "_LIVRE2", "N", 16, 4 } )
	    AAdd( aField, { "_LIVRE3", "N", 16, 4 } )
	    AAdd( aField, { "_LIVRE4", "N", 16, 4 } )
	    AAdd( aField, { "_LIVRE5", "D", 08, 0 } )
	    AAdd( aField, { "_LIVRE6", "D", 08, 0 } )	 
		AAdd( aField, { "_LIVRE7", "D", 08, 0 } )	
		AAdd( aField, { "_LIVRE8", "C", 50, 0 } )
		AAdd( aField, { "_LIVRE9", "C", 50, 0 } ) 
	ElseIf ( ::nType == DIMENSION )
		//-------------------------------------------------------------------
		// Define a estrutura dos campos livre das dimensões.
		//-------------------------------------------------------------------
		AAdd( aField, { "_LIVRE0", "C", 50, 0 } )
	    AAdd( aField, { "_LIVRE1", "C", 50, 0 } )
	    AAdd( aField, { "_LIVRE2", "C", 50, 0 } )
	    AAdd( aField, { "_LIVRE3", "C", 50, 0 } )
	    AAdd( aField, { "_LIVRE4", "C", 50, 0 } )
	    AAdd( aField, { "_LIVRE5", "C", 50, 0 } )
	    AAdd( aField, { "_LIVRE6", "C", 50, 0 } )
		AAdd( aField, { "_LIVRE7", "C", 50, 0 } )
		AAdd( aField, { "_LIVRE8", "C", 50, 0 } )
		AAdd( aField, { "_LIVRE9", "C", 50, 0 } )
	EndIf  

	//-------------------------------------------------------------------
	// Adiciona os campos livres no modelo.
	//-------------------------------------------------------------------
	For nField := 1 To Len( aField )
		::AddField( AllTrim( ::cEntity ) + aField[nField][1], aField[nField][2], aField[nField][3], aField[nField][4] )
	Next nField
Return ::aField

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUnifier  
Retorna os consolidadores configurados.

@Return aUnifier, Lista de consolidadores configurados.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method GetUnifier( ) class BIXModel
	Local aUnifier := {}
	
	If ! ( Empty( ::aUnifier ) )
		aUnifier := { ::cEntity, ::aUnifier }
	EndIf
Return aUnifier

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLookup  
Retorna os lookups configurados para cada campo. 

@Return aLookup, Lista de lookups configurados. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method GetLookup( ) class BIXModel
	Local oModel		:= nil
	Local oEntity		:= nil
	Local aBusinessKey	:= {}
	Local aLookupField	:= {}
	Local cEntity		:= ""
	Local _cFilial		:= ""
	Local cSurrogateKey	:= ""
	Local cKey			:= ""
	Local cTable        := ""
	Local nField 		:= 0
	Local nLookup		:= 0
	Local nLookupField	:= 0
	Local lUnified		:= .F. 
	Local ALookupOnly	:= {}

	//-------------------------------------------------------------------
	// Recupera o objeto do lookup.
	//-------------------------------------------------------------------		
	aEval( ::aField, {|x| iif( x[KEY], Aadd(ALookupOnly, x[LOOKUP]), )})

	For nField := 1 To Len( ALookupOnly )
		cKey := ""
		//-------------------------------------------------------------------
		// Se não achar no cache do lookup, realiza a carga 
		//-------------------------------------------------------------------	
		nLookup := AScan( __aLookup, {|x| x[1] == ALookupOnly[nField] } )
		
		If ( Empty( nLookup ) )
			//-------------------------------------------------------------------
			// Recupera o objeto do lookup.
			//-------------------------------------------------------------------	
			oEntity := BIXObject( ALookupOnly[nField] ) 
		
			If ! ( Empty( oEntity ) )				
				//-------------------------------------------------------------------
				// Recupera os atributos do lookup.
				//-------------------------------------------------------------------
				cEntity    := oEntity:GetEntity()
				_cFilial   := oEntity:GetFilial()	
				cTable 	   := oEntity:GetTable()					
				oModel 	   := oEntity:GetModel()

				If !Empty( cTable )
					cKey := BIXPk( cTable )
				EndIf
			
				If ! ( Empty( oModel ) )
					cSurrogateKey	:= oModel:GetSK()
					aBusinessKey	:= oModel:GetBK()					
					aLookupField 	:= oModel:GetField()
				EndIf
				
				//-------------------------------------------------------------------
				// Identifica se a consolidação está configurada para o lookup.
				//-------------------------------------------------------------------			
				lUnified := ! ( Empty( BIXGetUnifier( cEntity ) ) )

				//-------------------------------------------------------------------
				// Lista o lookup. 
				//-------------------------------------------------------------------				
				AAdd( ::aLookup, { cEntity, _cFilial, cTable, cSurrogateKey, aBusinessKey, lUnified, cKey  } )
				
				//-------------------------------------------------------------------
				// Adiciona as informações no cache 
				//-------------------------------------------------------------------				
				AAdd( __aLookup, { cEntity, _cFilial, cTable, cSurrogateKey, aBusinessKey, lUnified, cKey  } )

				//-------------------------------------------------------------------
				// Localiza a surrogate key do lookup.
				//-------------------------------------------------------------------										
				nLookupField := AScan( aLookupField, {|x| x[1] == cSurrogateKey } )

				//-------------------------------------------------------------------
				// Valida a surrogate key do lookup.
				//-------------------------------------------------------------------		
				If ( Empty( nLookupField ) )
					UserException ( STR0001  + cSurrogateKey + STR0002 ) //"O campo "###" identificado como surrogate key não foi encontrado no modelo!"
				Else
					If ! ( aLookupField[nLookupField][KEY] )
						UserException ( STR0001 + cSurrogateKey + STR0003 ) //"O campo "###" identificado como surrogate key não é chave do modelo!"
					EndIf
				EndIf 	

				//-------------------------------------------------------------------
				// Remove a referência do objeto. 
				//-------------------------------------------------------------------	
				FreeObj( oEntity )
			EndIf  
		Else
			//-------------------------------------------------------------------
			// Adiciona ao modelo as informações do cache. 
			//-------------------------------------------------------------------				
			AAdd( ::aLookup, aClone( __aLookup[nLookup] ) )
		EndIf
	Next nField	
Return ::aLookup

//-------------------------------------------------------------------
/*/{Protheus.doc} GetType
Retorna o tipo da entidade. 

@Return nType, Tipo da entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetType( ) Class BIXModel
Return ::nType

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Retorna a entidade. 

@Return cEntity, Retorna a entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetEntity( ) Class BIXModel
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSK 
Retorna o campo que armazena a surrogate key da entidade.  

@Return cSK, Campo que armazena a surrogate key da entidade. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method GetSK( ) Class BIXModel
Return ::cSK

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBK  
Retorna o campo que armazena a business key da entidade. 

@Return aBK, Campo que armazena a business key da entidade.  

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method GetBK( ) Class BIXModel
Return ::aBK

//-------------------------------------------------------------------
/*/{Protheus.doc} GetField 
Retorna os campos do modelo de dados. 

@Return aField, Campos do modelo de dados. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method GetField( ) Class BIXModel
Return ::aField

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIndex 
Retorna o índice para consulta no modelo de dados. O índice deve ser
criado do campo mais restritivo para o menos restritivo. A ordem de
criação dos índices NÃO deve ser alterada. 

@Return aIndex, Índice para consulta no modelo de dados. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method GetIndex( ) Class BIXModel
	Local aIndex	:= {}
	Local aField 	:= {}
	Local nField	:= 0
	
	For nField := 1 To Len( ::aBK )
		AAdd( aField, ::aBK[nField] )
	Next nField	
	
	If ( Empty( AScan( aField, { | x | x == ::cEntity + "_FILIAL" } ) ) )
		AAdd( aField, ::cEntity + "_FILIAL" )
	EndIf	
	
	AAdd( aField, ::cEntity + "_GRPEMP" )
	AAdd( aField, ::cEntity + "_ISTCIA" )
	
	If ! ( Empty( ::cSK ) )
		If ( Empty( AScan( aField, { | x | x == ::cSK } ) ) )
			AAdd( aField, ::cSK )
		EndIf
	EndIf		

	AAdd( aIndex, BIXConcatWSep( "+", aField ) )
Return aIndex

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPeriod 
Retorna o período de extração de uma entidade.

@Return nPeriod, Período de extração de uma entidade. 

@author  Valdiney V GOMES
@since   26/01/2017
/*/
//------------------------------------------------------------------- 
Method GetPeriod( ) Class BIXModel
Return ::nPeriod

//-------------------------------------------------------------------
/*/{Protheus.doc} IsSnapshot 
Indica se a entidade é extraída como snapshot. 

@param [IsSnapshot], lógico, Indica se a entidade é extraída como snapshot. 
@return IsSnapshot, Indica se a entidade é extraída como snapshot. 

@author  Valdiney V GOMES
@since   23/01/2017
/*/
//------------------------------------------------------------------- 
Method IsSnapshot( lSnapshot ) Class BIXModel
	If ! (  lSnapshot == nil )
		::lSnapshot := lSnapshot
	EndIf
Return ::lSnapshot

//-------------------------------------------------------------------
/*/{Protheus.doc} HasUndefined 
Identifica se deve ser gerado o registro indefinido. 

@param [lUndefined], lógico, Identifica se deve ser gerado o registro indefinido.
@return lUndefined, Identifica se deve ser gerado o registro indefinido. 

@author  Valdiney V GOMES
@since   23/01/2017
/*/
//------------------------------------------------------------------- 
Method HasUndefined( lUndefined ) Class BIXModel
	If ! ( lUndefined == nil )
		::lUndefined := lUndefined
	EndIf
Return ::lUndefined

//-------------------------------------------------------------------
/*/{Protheus.doc} HasFormula 
Identifica se deve ser gerado o registro fórmula. 

@param [lFormula], lógico, Identifica se deve ser gerado o registro fórmula. 
@return lFormula Identifica se deve ser gerado o registro fórmula.

@author  Valdiney V GOMES
@since   23/01/2017
/*/
//------------------------------------------------------------------- 
Method HasFormula( lFormula ) Class BIXModel
	If ! (  lFormula == nil  )
		::lFormula := lFormula
	EndIf
Return ::lFormula

//-------------------------------------------------------------------
/*/{Protheus.doc} HasDefault 
Identifica se o modelo tem os campos padrão. 

@return lDefault, Identifica se o modelo tem os campos padrão.

@author  Valdiney V GOMES
@since   08/02/2017
/*/
//------------------------------------------------------------------- 
Method HasDefault( ) Class BIXModel
Return ::lDefault

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy  
Destroi o objeto e libera a memória alocada. 

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Destroy() Class BIXModel
	aSize( ::aBK, 0 )
	aSize( ::aField, 0 )
	aSize( ::aLookup, 0 )
	aSize( ::aUnifier, 0 )

	::aBK			:= nil
	::aField		:= nil
	::aLookup		:= nil
	::aUnifier		:= nil
	::cSK			:= nil
	::cEntity		:= nil
	::nType			:= nil
	::cEntity		:= nil
	::nType			:= nil
	::nPeriod		:= nil 
	::lSnapshot		:= nil 
	::lUndefined	:= nil 
	::lFormula		:= nil 
	::lDefault		:= nil
Return nil