#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSEEKER.CH"

#DEFINE LOOKUP 	1	  // Dimensão em que o lookup será executado
#DEFINE FILIAL 	2	  // Chave da Filial da tabela de origem no Protheus
#DEFINE TABLE 	3	  // Tabela de Origem no Protheus
#DEFINE SK 		4	  // Campo chave da dimensão
#DEFINE BK 		5	  // Vetor com os campos da entidade que compõem a chave
#DEFINE UNIFIER	6	  // Identifica se utiliza chave consolidada
#DEFINE PK		7	  // Chave para efetuar as buscas no Protheus


//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSeeker
Classe responsável por representar os lookups de uma entidade. Realiza
a validação de integridade por meio da pesquisa em uma entidade da Fluig 
Smart Data. Todas as pesquisas são mantidas em memória, minimizando a 
necessidade de acesso constante ao banco de dados.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Class BIXSeeker
	Data oSeeker
	Data oLookup
	Data oWhere
	Data oKey
	Data aLookup
	Data cEntity
	Data cInstance
	Data lLog
	Data lFindInERP
	Data lShare	
	Data cTable
	Data cDatabase

	Method New( cEntity, aLookup, lUseLG, lShare, cTable )  CONSTRUCTOR
	Method Build( oEntity ) CONSTRUCTOR 
	Method Seek( cLookup, aKey ) 
	Method Query( aKey, cLookup, _cFilial, cSK, aBK, lUnified, cTable, cPK ) 
	Method FindERPInfo( cTable, cPK, aKey, aUnifier )
	Method Destroy( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método contrutor.

@param cEntity, Nome da entidade
@param aLookup, Lista de lookups para pesquisa no formato {{ lookup, filial, sk, bk, unifier? }}.
@param lUseLG, Identifica se a entidade possui controle de inclusão\alteração
@param lShare, Identifica se a entidade é compartilhada entre empresas
@param cTable, Tabela de origem do Protheus
@Return Self, Instância da Classe.   

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method New( cEntity, aLookup, lUseLG, lShare, cTable) class BIXSeeker
	Local nLookup 	:= 0
	
	Default aLookup := nil
	Default lUseLG	:= .F.
	Default lShare	:= BIXParInfo( "BIX_CMPEMP", "L", .F. )
	Default cTable	:= ""
	
	::aLookup 	 := {}	
	::oKey		 := BIXKey():New( )
	::oSeeker 	 := THashMap():New( )
	::oLookup 	 := THashMap():New( )
	::oWhere	 := THashMap():New( )
	::cInstance	 := BIXInstance()
	::cEntity	 := cEntity
	::lLog		 := SuperGetMV( "MV_LOGBI",,.F. )
	::lFindInERP := lUseLG
	::lShare	 := lShare
	::cTable	 := cTable
	::cDatabase  := TCGetDB( )

	If ! ( Empty( aLookup ) )
		::aLookup := aLookup
		
		For nLookup := 1 To Len( ::aLookup )
			::oLookup:Set( ::aLookup[nLookup][LOOKUP], nLookup )		
		Next nLookup
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
Method Build( oEntity ) Class BIXSeeker
	Local oModel	:= nil
	Local aLookup	:= {}
	Local cEntity	:= ""
	Local lUseLG	:= .F.
	Local lShare	:= .F.
	Local cTable	:= ""
	
	Default oEntity	:= nil 
	
	If ! ( Empty( oEntity ) )
		oModel	:= oEntity:GetModel( )
		cEntity	:= oEntity:GetEntity( )
		lUseLG	:= oEntity:GetUseLG( )
		lShare	:= oEntity:GetUseShare( )
		cTable	:= oEntity:GetTable( )
		
		If ! ( Empty( oModel ) )
			aLookup := oModel:GetLookup( )
		EndIf

		::New( cEntity, aLookup, lUseLG, lShare, cTable )
	EndIf 
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Seek
Pesquisa uma chave em um lookup. 

@param cLookup, caracter, Lookup a ser pesquisado. 
@param aKey, array, Chave a ser pesquisada no lookup. 
@param [lMap], lógico, Identifica se deve manter a pesquisa em cache.
@param aOtherKey, array, Chave a ser pesquisada no lookup no caso de uso da _FILORIG 
@return cKey, Chave encontrada. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method Seek( cLookup, aKey, lMap, aOtherKey ) class BIXSeeker
	Local cKey		:= ""
	Local cHash		:= ""
	Local nLookup	:= 0
	Local lShareFact:= .F.

	Default aKey	:= {}
	Default cLookup := ""
	Default lMap	:= .T.
	Default aOtherKey := {}
	
	If ( ::oLookup:Get( cLookup, @nLookup ) )	
		lShareFact := Empty( xfilial( ::cTable ) )
		
		cHash := AllTrim( cLookup + "|" + BIXConcatWSep( "|", aKey ) )
		
		//-------------------------------------------------------------------
		// Procura pelo lookup.
		//-------------------------------------------------------------------			
		If ( ! ( lMap ) .Or. ! ( ::oSeeker:Get( cHash, @cKey ) ) )
			//-------------------------------------------------------------------
			// Procura pelo lookup no banco de dados.
			//-------------------------------------------------------------------
			cKey := ::Query( aKey, ::aLookup[nLookup][LOOKUP], ::aLookup[nLookup][FILIAL], ::aLookup[nLookup][SK], ::aLookup[nLookup][BK], ::aLookup[nLookup][UNIFIER], ::aLookup[nLookup][TABLE], ::aLookup[nLookup][PK], lShareFact  )
			
			If ( lMap )
				//-------------------------------------------------------------------
				// Mantém a pesquisa em memória
				//-------------------------------------------------------------------	
				::oSeeker:Set( cHash, cKey )
			EndIf
		EndIf 	
	Else
		UserException ( STR0001 + cLookup + STR0002 ) //"O lookup "###" não foi encontrado!"
	EndIf
Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} Query
Pesquisa uma chave na tabela do lookup na Fluig Smart Data. 

@param aKey, array, Chave a ser pesquisada no lookup.
@param cLookup, caracter, Lookup a ser pesquisado. 
@param _cFilial, caracter, Filial no qual o dado será pesquisado.  
@param cSK, caracter, Campo no qual é armazenada a surrogate key. 
@param aBK, caracter, Campo no qual é armazenada a business key. 
@param lUnified, lógico, Identifica se a chave é consolidada. 
@param cTableERP, caracter, Tabela de origem a ser pesquisada no Protheus
@param cPK, caracter, Chave para efetuar as buscas no Protheus 
@param lShareFact, lógico, Identifica se a fato é compartilhada  

@return cKey, Chave encontrada. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method Query( aKey, cLookup, _cFilial, cSK, aBK, lUnified, cTableERP, cPK, lShareFact ) class BIXSeeker
	Local oKey		 := Nil
	Local cTemp		 := ""
	Local cDML		 := ""
	Local cKey		 := ""
	Local cWhere	 := ""
	Local nKey		 := 0
	Local cEmpInfo	 := ""
	Local nLookup	 := 0
	Local lUseTable	 := .F.
	Local cTable	 := ""
	Local cShare	 := ""
	Local lFind	     := .F.
	Local cSeek	     := ""
	Local lFindInERP := .F.
	Local cFieldLG	 := ""
	Local aKeyAux    := {}
	Local aUnifier   := {}
	Local lIncUnify  := .F.
	Local oEntity    := nil
	
	Default aKey	  := {}
	Default aBK		  := {}
	Default cSK		  := ""	
	Default cLookup	  := ""
	Default _cFilial  := ""
	Default lUnified  := .F.
	Default cTableERP := ""
	Default cPK		  := ""
	Default lShareFact := .F.
	
	//-------------------------------------------------------------------
	// Ajusta a informação da empresa caso utilizado a opção de compartilhamento
	//-------------------------------------------------------------------	
	nLookup := Ascan( ::aLookup, {|aLookup| Alltrim( aLookup[LOOKUP]) == cLookup })
	
	If nLookup > 0
		//-------------------------------------------------------------------
		// Identifica se o compartilhamento está configurado.
		//-------------------------------------------------------------------
		If ::lShare				
			cTable := ::aLookup[nLookup][TABLE]
			
			//-------------------------------------------------------------------
			// Identifica se a tabela de origem da entidade está no dicionário.
			//-------------------------------------------------------------------
			If ( ! Empty( cTable ) ) .And. ( AliasInDic( cTable ) )
				cShare := AllTrim( FWSX2Util():GetFile( cTable ) )
				cEmpInfo := Subs( cShare, 4, 2)								
			EndIf
		EndIf
	EndIf

	If Empty( cEmpInfo )
		cEmpInfo := cEmpAnt
	EndIf
	
	//-------------------------------------------------------------------
	// Monta o DML.
	//-------------------------------------------------------------------					
	cDML := " SELECT " + cSK			
	cDML += " FROM 	 " + cLookup
	cDML += " WHERE  "

	//-------------------------------------------------------------------
	// Filtra pela BK.
	//-------------------------------------------------------------------
	For nKey := 1 To Len( aBK )	
		cDML +=   aBK[nKey] + " = '" + If( Len( aKey ) >= nKey, StrTran( Rtrim( aKey[nKey] ), "'", "''" ), "" ) + "'"
		cDML += " AND "
	Next nKey	

	//-------------------------------------------------------------------
	// Filtra pelos campos padrão da entidade.
	//-------------------------------------------------------------------
	If ! ( ::oWhere:Get( cLookup, @cWhere ) )
		
		If ! ( lUnified )
			If ( Empty( AScan( aBK, { | x | "_FILIAL" $ x } ) ) ) .And. !lShareFact
				If ( ::cDatabase $ "ORACLE" ) .And. Empty( _cFilial )
					cWhere += cLookup + "_FILIAL = ' ' "
				else
					cWhere += cLookup + "_FILIAL = '" + _cFilial + "'"
				EndIf	
				cWhere += " AND "
			EndIf			

			cWhere += cLookup + "_GRPEMP = '" + cEmpInfo + "'" 
			cWhere += " AND "
		EndIf
		
		cWhere += cLookup + "_ISTCIA = '" + ::cInstance + "'"
		
		::oWhere:Set( cLookup, cWhere )
	EndIf

	cDML += cWhere
	
	//-------------------------------------------------------------------
	If ( BIXLinkFSD() > 0 )
		cDML := ChangeQuery( cDML ) 

		//-------------------------------------------------------------------
		// Executa o DML.
		//-------------------------------------------------------------------
		DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), cTemp := GetNextAlias(), .F., .T.) 	

		//-------------------------------------------------------------------
		// Recupera a chave do lookup.
		//-------------------------------------------------------------------
		If ! ( ( cTemp )->( Eof( ) ) )
			cKey := ( cTemp )->&( cSK )
			lFind := .T.
		EndIf

		//-------------------------------------------------------------------
		// Fecha a área temporária.
		//-------------------------------------------------------------------
		( cTemp )->( DBCloseArea( ) )
	
		//-------------------------------------------------------------------
		// Desconecta na Fluig Smart Data.
		//-------------------------------------------------------------------					
		BIXUnlinkFSD()
	EndIf
	
	IF !lFind
		IF !Empty( cTableERP ) .And. cTableERP $ "SA1|SB1|" 
			cFieldLG := BIXAddLGField( cTableERP, 2 )
			
			IF !Empty( cFieldLG )
				lFindInERP := .T.
			Else
				lFindInERP := .F. 
			EndIf
		EndIf
		
		If lFindInERP .And. ( cLookup $ "HJ7|HJ8|" )
			oEntity   := BIXObject( cLookup )
			::oKey    := BIXKey():Build( oEntity )
			aUnifier  := ::oKey:LoadUnifier()
			lIncUnify := ( ! Empty( aUnifier ) )
			aKeyAux   := ::FindERPInfo( cTableERP, cPK, aKey, aUnifier )				
		EndIf

		If ( ! Empty( aKeyAux ) )
			cKey := ::oKey:GetKey( aKeyAux, /*lGroup*/, /*lFilial*/, /*lAllTrim*/, /*lSK*/, lIncUnify )
			
			If ! Empty( oEntity )
				oEntity:Destroy( )
				FreeObj( oEntity )				
			EndIf
		Else
			cKey := ::oKey:GetKey( { UNDEFINED } ) 

			//-------------------------------------------------------------------
			// Loga falhas na integridade referencial.
			//-------------------------------------------------------------------
			If ( ::lLog )			
				BIXLogIntegrity( ::cEntity, cLookup, aBK, _cFilial, aKey )
			EndIf
		EndIf
		
		If ! Empty( oKey )
			oKey:Destroy( )
			FreeObj( oKey )				
		EndIf
		
	EndIf
Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} FindERPInfo
Pesquisa uma chave na tabela do lookup na Fluig Smart Data. 

@param cTable, caracter, Tabela no Protheus onde a pesquisa será executada 
@param cPK, caracter, Chave para efetuar as buscas no Protheus
@param aKey, array, Chave a ser pesquisada no lookup.
@param aUnifier, array, Campos do consolidado.
@return lRet, Identifica se o registro correspondente foi localizado. 

@author  Marcia Junko
@since   09/06/2017
/*/
//------------------------------------------------------------------- 
Method FindERPInfo( cTable, cPK, aKey, aUnifier, lShareFact ) class BIXSeeker
	Local cSeek     := "" 
	Local cField    := ""
	Local aBK       := {}
	Local nCount    := 0
	
	Default aUnifier := {}
	Default lShareFact := .F.
	
	If !Empty(cTable)
		
		cSeek := BIXConcatWSep( "", aKey )
		
			
		If (cTable)->( DbSeek( xFilial(cTable) + cSeek ) )
		
			//-------------------------------------------------------------------
			// Dimensão utiliza forma consolidada
			//-------------------------------------------------------------------
			If ! ( Empty( aUnifier ) )
				For nCount := 1 to Len( aUnifier )
					cField := aUnifier[nCount]
					AAdd( aBK, (cTable)->&cField )
				Next
			Else
				aBK := aKey
			EndIf	
		EndIf
	EndIf	
	
Return aBK

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto e libera a memória alocada. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//------------------------------------------------------------------- 
Method Destroy() class BIXSeeker
	aSize( ::aLookup, 0 )
	HMClean( ::oLookup )
	HMClean( ::oSeeker )
	HMClean( ::oWhere )
	
	::aLookup 	 := nil
	::oLookup	 := nil
	::oKey		 := nil
	::oSeeker 	 := nil
	::cInstance	 := nil
	::cEntity	 := nil
	::lLog		 := nil
    ::lFindInERP := nil
    ::cTable	 := nil	
	::cDatabase  := nil
Return

