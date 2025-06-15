#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUNIFIER.CH"

#DEFINE ENTITY		1
#DEFINE ATTRIBUTE	2

Static __aTable
Static __aGroup
Static __oUnifier

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXUnifier
Funçao principal, exibe a tela do consolidador no modo de atualização. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Function BIXUnifier()
	Local aButton 	:= {}
	Local nButton	:= 0
	
	//-------------------------------------------------------------------
	// Desabilita os botões desnecessários.
	//-------------------------------------------------------------------  
	For nButton := 1 To 14
		AAdd( aButton, { ( nButton > 3 ), nil } )
	Next nButton

	FWExecView( STR0001, "BIXUNIFIER", MODEL_OPERATION_UPDATE, , , , , aButton  ) //"Consolidador"
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOpenUnifier
Criar, atualiza, e abre a tabela do consolidador. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function BIXOpenUnifier()   
	Local oUnifier	:= Nil
	Local nTable	:= 1      
  		 
	If ( Empty ( __aTable  ) )
		__aTable := {}	
		
		//-------------------------------------------------------------------
		// Monta a estrutura da tabela do consolidador.
		//-------------------------------------------------------------------  	  	                 
		oUnifier := TBITable():New( "HYW", "HYW" ) 
		oUnifier:AddField( TBIField():New( "HYW_ENTITY" ,"C" ,03 ,0))
		oUnifier:AddField( TBIField():New( "HYW_ATTR" 	,"C" ,10 ,0))
		oUnifier:AddField( TBIField():New( "HYW_FIELD" 	,"C" ,100 ,0))
		oUnifier:AddIndex( TBIIndex():New( "HYW1", {"HYW_ENTITY"}, .T.) )  		
		
		//-------------------------------------------------------------------
		// Adiciona a estrutura na memória.
		//-------------------------------------------------------------------			
		aAdd( __aTable, oUnifier )
	EndIf
	
	//-------------------------------------------------------------------
	// Abre a tabela. 
	//------------------------------------------------------------------- 
	For nTable := 1 To Len( __aTable ) 
		If !( __aTable[nTable]:lIsOpen( ) )
			__aTable[nTable]:ChkStruct( .F., .F., .F., .T. )
			__aTable[nTable]:lOpen( )
		EndIf 
	Next nTable
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do consolidador.

@return oModel, Modelo de dados do consolidador. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel		:= Nil
	Local oModelStruct 	:= Nil
	Local aGroup 		:= {}	
	Local cField		:= ""
	Local cTitle		:= ""
	Local nGroup		:= 0  
	
	//-------------------------------------------------------------------
	// Define o modelo de dados. 
	//-------------------------------------------------------------------		    
	oModel	:= MPFormModel():New( "BIXUNIFIER",,, { | oModel | BIXCommitUnifier( oModel ) } )		    
	
	//-------------------------------------------------------------------
	// Define os campos do modelo. 
	//-------------------------------------------------------------------
	oModelStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Recupera os consolidadores de dados. 
	//-------------------------------------------------------------------
	aGroup 	:= BIXGetGroup()

	For nGroup := 1 To Len( aGroup )
		//-------------------------------------------------------------------
		// Recupera os atributos do campo. 
		//-------------------------------------------------------------------
		cField := aGroup[nGroup][ENTITY]
		cTitle := cField + " - " + BIXGetTitle( cField )
		
		//-------------------------------------------------------------------
		// Adiciona o campo. 
		//-------------------------------------------------------------------
		oModelStruct:AddField( cTitle, "", cField, "N", 1 , 0  ) 
	Next nGroup 
	
	//-------------------------------------------------------------------
	// Ativa a estrutura de dados.
	//-------------------------------------------------------------------
	oModelStruct:Activate()
 
	//-------------------------------------------------------------------
	// Define a estrutura do modelos de dados. 
	//-------------------------------------------------------------------
	oModel:AddFields( "MODEL_MAIN",, oModelStruct,,, {|| BIXLoadUnifier( oModel ) } )

    //-------------------------------------------------------------------
	// Define a chave primária da tabela principal do modelo. 
	//-------------------------------------------------------------------
	oModel:SetPrimaryKey( {} ) 
	
	//-------------------------------------------------------------------
	// Define a descrição dos modelos de dados. 
	//-------------------------------------------------------------------	
	oModel:SetDescription( STR0001 )  //"Consolidador"
	oModel:GetModel("MODEL_MAIN"):SetDescription( STR0001 )  //"Consolidador"
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada de visualização do consolidador. 

@return oView, Objeto da camada de visualização.

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView 		:= Nil
	Local oModel 		:= Nil
	Local oModelStruct	:= Nil
	Local oViewStruct	:= Nil
	Local aGroup 		:= {}
	Local aOption		:= {}
	Local cTitle		:= ""
	Local cField 		:= ""
	Local cOrder  		:= ""
	Local cTooltip		:= ""
	Local nGroup 		:= 0  
	Local nAttribute	:= 0

	//-------------------------------------------------------------------
	// Recupera o modelo de dados.
	//-------------------------------------------------------------------	
	oModel		 := FWLoadModel( "BIXUNIFIER" )	
	oModelStruct := oModel:GetModel("MODEL_MAIN" ):GetStruct()

	//-------------------------------------------------------------------
	// Define a camada de visualização.
	//-------------------------------------------------------------------
	oView 		:= FWFormView():New()
	oViewStruct	:= FWFormViewStruct():New()

	//-------------------------------------------------------------------
	// Recupera os consolidadores de dados. 
	//-------------------------------------------------------------------
	aGroup 	:= BIXGetGroup()

	For nGroup := 1 To Len( aGroup )
		//-------------------------------------------------------------------
		// Recupera os atributos do campo. 
		//-------------------------------------------------------------------	
		aOption 	:= {}
		cField 		:= aGroup[nGroup][ENTITY]
		cOrder  	:= StrZero( nGroup, 2)
		cTitle 		:= oModelStruct:GetProperty( aGroup[nGroup][ENTITY], MODEL_FIELD_TITULO )
		cTooltip	:= oModelStruct:GetProperty( aGroup[nGroup][ENTITY], MODEL_FIELD_TOOLTIP )
	
		//-------------------------------------------------------------------
		// Recupera as opções de seleção. 
		//-------------------------------------------------------------------
		For nAttribute := 1 To Len( aGroup[nGroup][ATTRIBUTE] )
			If ! ( Empty( aGroup[nGroup][ATTRIBUTE][nAttribute] ) )
				aAdd( aOption, cBIStr( nAttribute  ) + "=" + Upper( AllTrim( aGroup[nGroup][ATTRIBUTE][nAttribute][3] ) ) ) 
			EndIf
		Next nAttribute
		
		//-------------------------------------------------------------------
		// Adiciona o campo. 
		//-------------------------------------------------------------------
		oViewStruct:AddField( cField, cOrder, cTitle, cTooltip,,"N",,,,,,,aOption, 10 )
	Next nGroup 	

	//-------------------------------------------------------------------
	// Ativa a estrutura de dados.
	//-------------------------------------------------------------------
	oViewStruct:Activate()       

	//-------------------------------------------------------------------
	// Define o modelo utilizado pela camada de visualização.
	//-------------------------------------------------------------------		 	 
	oView:SetModel( oModel )

	//-------------------------------------------------------------------
	// Define a estrutura da da camada de visualização. 
	//------------------------------------------------------------------
	oView:AddField( "VIEW_MAIN", oViewStruct, "MODEL_MAIN" )
	oView:CreateHorizontalBox( "ALL", 100 )
	oView:SetOwnerView( "VIEW_MAIN", "ALL" )	
	oView:EnableTitleView("VIEW_MAIN", STR0001 ) //"Consolidador"
	oView:SetViewProperty("VIEW_MAIN","SETLAYOUT", {FF_LAYOUT_VERT_DESCR_TOP, 3})
    oView:SetCloseOnOk( { || .T. } )
Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadUnifier
Carrega as informações configuradas no consolidador. 

@param oModel, objeto, Modelo de dados. 
@return aLoad, Valores para carga do consolidador. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function BIXLoadUnifier( oModel )
	Local oModelStruct 	:= Nil 
	Local aField		:= Nil 
	Local aLoad			:= {}
	Local aAttribute	:= {}
	Local cAttribute	:= ""
	Local cField		:= ""
	Local nAttribute	:= 0
	Local nField		:= 0
	Local nOption		:= 0

	Default oModel		:= Nil 

	If ( BIXOpenUnifier() )
		//-------------------------------------------------------------------
		// Recupera a estrutura de modelo de dados.  
		//------------------------------------------------------------------- 		
		oModelStruct := oModel:GetModel("MODEL_MAIN"):GetStruct()
		
		//-------------------------------------------------------------------
		// Recupera os campos do modelo de dados.  
		//------------------------------------------------------------------- 	
		aField := oModelStruct:GetFields()
	
		For nField := 1 To Len( aField )
			nOption	:= 0
			
			//-------------------------------------------------------------------
			// Recupera os atributos disponíveis para seleção.  
			//------------------------------------------------------------------- 
			aAttribute 	:= BIXGetAttribute( aField[nField][3] )
	
			//-------------------------------------------------------------------
			// Recupera a opção para seleção.  
			//------------------------------------------------------------------- 	
			If ! ( Empty( aAttribute ) )	
				If( HYW->( MSSeek( aAttribute[ENTITY] ) ) )
					If ! ( Empty( aAttribute[ATTRIBUTE] ) )
						For nAttribute := 1 To Len( aAttribute[ATTRIBUTE] )
							If ! ( Empty( aAttribute[ATTRIBUTE][nAttribute] ) )
								cAttribute	:= aAttribute[ATTRIBUTE][nAttribute][1]
								cField		:= BIXConcatWSep( "+", aAttribute[ATTRIBUTE][nAttribute][2] ) 
							
								If ( AllTrim( cAttribute ) == AllTrim( HYW->HYW_ATTR ) .And. AllTrim( cField ) == AllTrim( HYW->HYW_FIELD )  )
									nOption := nAttribute
									Exit
								EndIf
							EndIf
						Next nAttribute					
					EndIf
				EndIf
			EndIf 
			
			//-------------------------------------------------------------------
			// Lista os valores a serem carregados no modelo.  
			//------------------------------------------------------------------- 		
			aAdd( aLoad, If( Empty( nOption), 1, nOption ) )
		Next nField
	EndIf 
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCommitUnifier
Grava as informação configuradas no consolidador. 

@param oModel, objeto, Modelo de dados. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function BIXCommitUnifier( oModel )
	Local oModelStruct 	:= Nil 
	Local aField		:= Nil 
	Local aAttribute	:= {}
	Local cAttribute	:= ""
	Local cField		:= ""
	Local nField		:= 0
	Local nOption		:= 0

	Default oModel		:= Nil 
	
	If ( BIXOpenUnifier() )
		//-------------------------------------------------------------------
		// Recupera a estrutura de modelo de dados.  
		//------------------------------------------------------------------- 		
		oModelStruct := oModel:GetModel("MODEL_MAIN"):GetStruct()
		
		//-------------------------------------------------------------------
		// Recupera os campos do modelo de dados.  
		//------------------------------------------------------------------- 	
		aField := oModelStruct:GetFields()
	
		For nField := 1 To Len( aField )
			cAttribute	:= ""
			cField 		:= ""
		
			//-------------------------------------------------------------------
			// Recupera as opções selecionadas para cada campo.  
			//-------------------------------------------------------------------			
			nOption	:= oModel:GetValue( "MODEL_MAIN", aField[nField][3] )		
		
			//-------------------------------------------------------------------
			// Recupera as opções para cada campo.
			//------------------------------------------------------------------- 			
			aAttribute 	:= BIXGetAttribute( aField[nField][3] )
		
			//-------------------------------------------------------------------
			// Identifica se insere ou atualiza uma entidade.  
			//------------------------------------------------------------------- 
			lEntity := HYW->( MSSeek( aAttribute[ENTITY] ) )			

			//-------------------------------------------------------------------
			// Grava os dados da entidade. 
			//------------------------------------------------------------------- 		
			Reclock( "HYW", ! lEntity ) 
				HYW->HYW_ENTITY := aAttribute[ENTITY]
				
				If ! ( nOption == 1 ) 
					If ( Len( aAttribute[ATTRIBUTE] ) >= nOption ) 
						cAttribute 	:= aAttribute[2][nOption][1]
						cField 		:= BIXConcatWSep( "+", aAttribute[2][nOption][2] )
					EndIf 
				EndIf 
	
				HYW->HYW_ATTR 	:= cAttribute
				HYW->HYW_FIELD 	:= cField
			MSUnlock()
		 
		Next nField
	EndIf
Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetTitle
Retorna o nome de uma entidade do tipo dimensão. 

@param cEntity, caracter, Entidade a ser verificada. 
@return cTitle, Nome da entidade. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function BIXGetTitle( cEntity )
	Local oEntity	:= nil
	Local cTitle	:= ""

	Default cEntity := ""
	
	//-------------------------------------------------------------------
	// Instancia a entidade.  
	//------------------------------------------------------------------- 
	oEntity := BIXObject( cEntity )
    
	//-------------------------------------------------------------------
	// Recupera o título da entidade.  
	//-------------------------------------------------------------------  	
	If ! ( Empty( oEntity) )
		cTitle:= oEntity:GetTitle( )
		FreeObj( oEntity )
	EndIf
Return cTitle

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetGroup
Retorna os atributos configurados para consolidação de todas as entidades.

@return aAttribute, Atributos para consolidação no formato {{ ENTIDADE, {{ ATRIBUTO, DESCRICAO}, ...} }, ...}. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function BIXGetGroup()
	Local oTopology		:= nil 
	Local aAttribute	:= {}
	Local aDimension	:= {}
	Local cDimension	:= ""
	Local nDimension	:= 0

	If ( Empty( __aGroup ) )
		__aGroup := {}

	    //-------------------------------------------------------------------
	    // Recupera a lista de dimensões registradas. 
	    //------------------------------------------------------------------- 
		oTopology 	:= BIXTopology():New( )
		aDimension 	:= oTopology:ListEntity( DIMENSION )
		FreeObj( oTopology )	

		//-------------------------------------------------------------------
		// Percorre as dimensões do modelo.  
		//-------------------------------------------------------------------  
		For nDimension := 1 To Len( aDimension )
	 		//-------------------------------------------------------------------
			// Recupera a entidade.  
			//------------------------------------------------------------------- 		
			cDimension := aDimension[nDimension][1] 
	
	 		//-------------------------------------------------------------------
			// Recupera os atributos para consolidação.  
			//-------------------------------------------------------------------  	   		
			aAttribute := BIXGetAttribute( cDimension )
	
	 		//-------------------------------------------------------------------
			// Lista os atributos.  
			//-------------------------------------------------------------------			
			If ! ( Empty( aAttribute ) )
				aAdd( __aGroup, aAttribute )
			EndIf 
		Next nDimension
	
	 	//-------------------------------------------------------------------
		// Ordena as dimensões em ordem alfabética.  
		//-------------------------------------------------------------------			
		ASort( __aGroup	, , , {|x,y| BIXGetTitle( y[1] )  > BIXGetTitle( x[1] ) } )
	EndIf 
Return __aGroup

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetAttribute
Retorna os atributos para consolidação de uma entidade.

@param cEntity, caracter, Entidade a ser verificada. 
@return aAttribute, Atributos para consolidação de uma entidade no formato { ENTIDADE, {{ ATRIBUTO, DESCRICAO}, ...} }. 

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Static Function BIXGetAttribute( cEntity )
	Local oEntity		:= nil
	Local oModel		:= nil
	Local aAttribute	:= {}
	
	Default cEntity		:= ""

	If ( Empty( __oUnifier ) )
		__oUnifier := THashMap():New( )
	EndIf

	If ! ( __oUnifier:Get( cEntity, @aAttribute ) )
		//-------------------------------------------------------------------
		// Instancia a classe da dimensão.  
		//------------------------------------------------------------------- 
		oEntity := BIXObject( cEntity )
		
		//-------------------------------------------------------------------
		// Recupera os atributos.  
		//-------------------------------------------------------------------  	
		If ! ( Empty( oEntity) )
			oModel := oEntity:GetModel( )
		
			If ! ( Empty( oModel) )
				aAttribute := oModel:GetUnifier()
			EndIf
			
			FreeObj( oEntity )
		EndIf

	 	//-------------------------------------------------------------------
		// Mantém os atributos da entidade em memória.  
		//-------------------------------------------------------------------		
		__oUnifier:Set( cEntity, aAttribute )
	EndIf
Return aAttribute

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetUnifier
Retorna o atributo para consolidação de uma entidade. 

@param cEntity, caracter, Entidade a ser verificada. 
@return aUnifier, Atributo para consolidação da entidade.  

@author  Valdiney V GOMES
@since   08/03/2016
/*/
//-------------------------------------------------------------------
Function BIXGetUnifier( cEntity )
	Local aUnifier	 	:= {} 
	Local cAttribute 	:= ""
	Local cField		:= ""
		
	Default cEntity  	:= ""
	
	If ( BIXOpenUnifier() )
		//-------------------------------------------------------------------
		// Localiza a entidade no consolidador.  
		//------------------------------------------------------------------- 
		If ( HYW->( MSSeek( cEntity ) ) )
			//-------------------------------------------------------------------
			// Recupera o atributo para consolidação.  
			//------------------------------------------------------------------- 	
			cAttribute	:= AllTrim( HYW->HYW_ATTR )
			cField		:= AllTrim( HYW->HYW_FIELD )
			
			//-------------------------------------------------------------------
			// Retorna o atributo.  
			//------------------------------------------------------------------- 				
			If ( ! Empty( cAttribute ) .And. ! Empty( cField ) )
				aUnifier := { cAttribute, cField }
			EndIf
		EndIf 	
	EndIf	
Return aUnifier