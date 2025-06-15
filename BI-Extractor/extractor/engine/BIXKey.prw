#INCLUDE "BIXEXTRACTOR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXKey
Classe responsável por representar a surrogate key de uma entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Class BIXKey
	Data oRecord
	Data aUnifier	
	Data _cFilial 	
	Data cTable
	Data cEntity
	Data cShare	
	Data lShare 
	
	Method New( cEntity, _cFilial, cTable, oRecord ) CONSTRUCTOR
	Method Build( oEntity, oRecord ) CONSTRUCTOR
	Method SetEntity( cEntity )
	Method SetTable( cTable )
	Method GetKey( aBK, lGroup, lFilial, lRTRIM, lSK, lIncUnify )
	Method LoadUnifier( ) 
	Method GetShare( ) 
	Method Destroy( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método contrutor.

@param cEntity, caracter, Entidade.
@param _cFilial, caracter, Filial.
@param cTable, caracter, Tabela origem da entidade.
@param [oRecord], objeto, Objeto do registro quando a entidade é consolidada.
@Return Self, Instância da Classe.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method New( cEntity, _cFilial, cTable, oRecord, lShare ) Class BIXKey
	Default _cFilial	:= ""
	Default cTable		:= ""
	Default cEntity		:= ""
	Default oRecord		:= nil
	Default lShare		:= BIXParInfo( "BIX_CMPEMP", "L", .F. )	

	::cEntity	:= cEntity
	::_cFilial 	:= _cFilial
	::cTable 	:= cTable
	::oRecord	:= oRecord 
	::cShare	:= ""
	::lShare 	:= lShare	
	
	::aUnifier	:= ::LoadUnifier()
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Build  
Método contrutor.
 
@param oEntity, objeto, Objeto de uma entidade.
@param [oRecord], objeto, Objeto do registro quando a entidade é consolidada.
@Return Self, Instância da Classe.   

@author  Valdiney V GOMES
@since   16/01/2017
/*/
//------------------------------------------------------------------- 
Method Build( oEntity, oRecord ) Class BIXKey
	Local cEntity 	:= ""
	Local _cFilial	:= ""
	Local cTable	:= ""
	Local lShare	:= .F.
		
	Default oEntity	:= nil 
	Default oRecord	:= nil 
	
	If ! ( Empty( oEntity ) )
		cEntity		:= oEntity:GetEntity() 
		_cFilial	:= oEntity:GetFilial()
		cTable		:= oEntity:GetTable()
		lShare		:= oEntity:GetUseShare()
			
		::New( cEntity, _cFilial, cTable, oRecord, lShare )
	EndIf 
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetEntity
Define a entidade. 

@param cEntity, Entidade. 
@Return cEntity, Entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetEntity( cEntity ) Class BIXKey
	Default cEntity := ""
	
	::cEntity := cEntity
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTable
Define a tabela de origem da entidade no Protheus

@param cTable, Tabela de origem da entidade no Protheus. 
@Return cTable, Tabela de origem da entidade no Protheus.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetTable( cTable ) Class BIXKey
	Default cTable := ""
	
	::cTable := cTable
Return ::cTable

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadUnifier
Recupera os campos que serão utilizados para consolidar os dados de uma 
entidade.  

@return aUnifier, Campos consolidadores. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method LoadUnifier( ) Class BIXKey
	Local aUnifier 	:= {}

	If ( ::aUnifier == nil )
		::aUnifier := { }
	EndIf 

	If ( ! Empty( ::cEntity ) )
		//-------------------------------------------------------------------
		// Recupera o consolidador configurado para entidade.
		//-------------------------------------------------------------------
		aUnifier := BIXGetUnifier( ::cEntity )
		
		If ! ( Empty( aUnifier ) )
			//-------------------------------------------------------------------
			// Recupera os campos para consolidação dos dados.
			//-------------------------------------------------------------------
			::aUnifier := aBItoken( aUnifier[2], "+", .F. ) 
		EndIf 
	EndIf
Return ::aUnifier

//-------------------------------------------------------------------
/*/{Protheus.doc} GetShare
Define a tabela ou empresa de origem dos dados no Protheus. Quando o 
compartilhamento estive ligado é utilizado o nome da tabela na chave. 
Nos outros casos, é utilizado o código do grupo de empresas.  

@Return cShare, Retorna o grupo de empresa ou nome da origem da entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetShare( ) Class BIXKey
	If ( Empty( ::cShare ) )
		//-------------------------------------------------------------------
		// Recupera o grupo de empresas.
		//-------------------------------------------------------------------
		::cShare := cEmpAnt
		
		//-------------------------------------------------------------------
		// Identifica se o compartilhamento está configurado.
		//-------------------------------------------------------------------
		If ( ::lShare )
			//-------------------------------------------------------------------
			// Identifica se a tabela de origem da entidade está no dicionário.
			//-------------------------------------------------------------------
			If ( ! Empty( ::cTable ) ) .And. ( AliasInDic( ::cTable ) )
				::cShare := AllTrim( FWSX2Util():GetFile( ::cTable ) )
			EndIf 
		EndIf
	EndIf
Return ::cShare

//-------------------------------------------------------------------
/*/{Protheus.doc} GetKey  
Retorna a surrogate key para uma business key. 
   
@param aBK, array, Business key. 
@param [lGroup], lógico, Identifica se o grupo de empresas será incluído na chave.. 
@param [lFilial], lógico, Identifica se a filial deve ser incluída na chave. 
@param [lRTRIM], lógico, Identifica se remove os espaçoes da chave. 
@param [lSK], lógico, Identifica se é o campo chave da entidade.
@param [lIncUnify], lógico, Identifica se usa registro incremental e consolidado.  
@return cKey, Surrogate key.
   
@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method GetKey( aBK, lGroup, lFilial, lRTRIM, lSK, lIncUnify ) Class BIXKey
	Local aKey		:= {}
	Local cSK		:= ""
	Local cKey		:= ""
	Local nKey 		:= 0
	Local lUnify	:= .F. 

	Default aBK 		:= {}
	Default lGroup		:= .T. 
	Default lFilial		:= .T. 
	Default lRTRIM	    := .T.
	Default lSK			:= .T.
	Default lIncUnify   := .F.

	//-------------------------------------------------------------------
	// Identifica se a chave é consolidada.
	//-------------------------------------------------------------------	
	lUnify := ! ( Empty( ::aUnifier ) )

	//-------------------------------------------------------------------
	// Recupera a parte fixa da surrogate key.
	//-------------------------------------------------------------------	
	cSK	:= "P " + "|" + BIXInstance()  + "|"

	//-------------------------------------------------------------------
	// Recupera a business key.
	//-------------------------------------------------------------------	
	If ( lUnify .And. lSK ) .And.  (! lIncUnify )
		If ! ( Empty( ::oRecord ) ) 
			For nKey := 1 To Len( ::aUnifier  )
				AAdd( aKey, RTRIM( cBIStr( ::oRecord:GetValue( ::aUnifier[nKey] ) ) ) )
			Next nKey
		EndIf		
	Else
		For nKey := 1 To Len( aBK )
			If ( lRTRIM )
				AAdd( aKey, RTRIM( cBIStr( aBK[nKey] ) ) )
			Else
				AAdd( aKey, aBK[nKey] )
			EndIf
		Next nKey
	EndIf
	
	//-------------------------------------------------------------------
	// Monta a surrogate key.
	//-------------------------------------------------------------------
	//-------------------------------------------------------------------
	// Tratamento especial para a dimensão HKA (Situação Colaborador) e 
	// HJS (Motivo Afastamento), pois possuem registros com código em 
	// branco (" ") e não pode gerar a chave como INDEFINIDO.
	//-------------------------------------------------------------------				
	If ( Empty( StrTran( BIXConcatWSep( "", aKey ), UNDEFINED, "" ) ) ) .And. !( ::cEntity $ 'HKA|HJS')
		cKey := cSK + UNDEFINED + "|"+ UNDEFINED + "|" 	
	ElseIf ( Empty( StrTran( BIXConcatWSep( "", aKey ), FORMULA, "" ) ) ) .And. !( ::cEntity $ 'HKA|HJS')	
		cKey := cSK + UNDEFINED + "|"+ FORMULA + "|"	
	Else
		If ( lUnify ) 
			cKey := cSK + BIXConcatWSep( "|", aKey ) + "|"
		Else
			cKey := cSK
			
			//-------------------------------------------------------------------
			// Identifica se considera o grupo de empresas.
			//-------------------------------------------------------------------		
			If ( lGroup )  
				cKey += ::GetShare() + "|"
			EndIf

			//-------------------------------------------------------------------
			// Ajusta o parâmetro de filial caso não tenha sido informada a tabela
			// Ex: Faixa de tempo de casa e tempo de cargo.
			//-------------------------------------------------------------------		
			If ( lFilial .And. Empty( ::cTable ) )  
				lFilial := .F.
			EndIf

			//-------------------------------------------------------------------
			// Identifica se considera a filial.
			//-------------------------------------------------------------------	
			If ( lFilial )
				cKey += RTRIM( cBIStr( ::_cFilial ) ) + "|" + BIXConcatWSep( "|", aKey ) + "|"
			Else
				cKey += BIXConcatWSep( "|", aKey ) + "|"
			EndIf 	
		EndIf
	EndIf 
Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy  
Destroi o objeto e libera a memória alocada. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method Destroy( ) Class BIXKey
	ASize( ::aUnifier,  0 )
	
	::aUnifier	:= nil 
	::_cFilial	:= nil 	
	::cTable	:= nil
	::cEntity	:= nil
	::cShare	:= nil
	::lShare 	:= nil
Return nil