#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPARAMETER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSavePeriodo
Grava o periodo de extra��o na tabela HJJ (utilizado posteriormente no DM)

@param cEntity		Entidade que ter� o per�odo salvo.
@param aParam		Par�metros para extra��o.
@param lSnapshot	Identifica se a entidade � snapshot

@author  M�rcia Junko
@version P12
@since   03/07/2015
/*/
//-------------------------------------------------------------------
function BIXSavePeriodo( cEntity, aPeriod, lSnapShot )
	Local oEntity	:= nil
	Local aArea   	:= getArea()
	Local cCompany	:= ""
	Local cBranch	:= ""
	Local lInsert	:= .F.

	Default cEntity	:= ""
	Default lSnapshot := .F.

	//-------------------------------------------------------------------
	// Loga o per�odo de extra��o de entidades.
	//-------------------------------------------------------------------
	BIXSetLog( LOG_RUNNING, cEntity, SToD( aPeriod[1] ), SToD( aPeriod[2] ) )

	//-------------------------------------------------------------------
	// Identifica se a entidade � uma fato. 
	//-------------------------------------------------------------------	
	oEntity := BIXObject( cEntity )
	
	If ! ( Empty( oEntity ) )
		If ( oEntity:GetType( ) == FACT )
			//-------------------------------------------------------------------
			// Recupera a informa��o da empresa e filial.  
			//-------------------------------------------------------------------			
			cCompany 	:= BIXCompany()
			cBranch		:= BIXBranch( cEntity ) 
		
			//-------------------------------------------------------------------
			// Conecta na Fluig Smart Data. 
			//-------------------------------------------------------------------	
			If ! ( BIXLinkFSD() == 0 )
				BIXSetupTable("HJJ")
	
				//-------------------------------------------------------------------
				// Abre a tabela. 
				//-------------------------------------------------------------------	
				DBUseArea(.T., "TOPCONN", "HJJ", "HJJ", .T., .F.)
	
				//-------------------------------------------------------------------
				// Seleciona o �ndice. 
				//-------------------------------------------------------------------	
				HJJ->( dbSetIndex("HJJ1") )
				HJJ->( dbSetIndex("HJJ2") )
				HJJ->( DBSetOrder( 2 ) )
			
				//-------------------------------------------------------------------
				// Identifica se insere ou atualiza um per�odo. 
				//------------------------------------------------------------------- 	
				lInsert := !( HJJ->( dbSeek(xFilial("HJJ") + cCompany + cBranch + cEntity) ) )
				
				//-------------------------------------------------------------------
				// Grava os intervalos das fatos. 
				//------------------------------------------------------------------- 			
				RecLock( "HJJ", lInsert )
					//------------------------------------------------------------------------
					// Todas as fatos dever�o ser geradas com o tipo 'T' no campo HJJ_INFPER
					// pois o Agent j� faz o tratamento.
					//------------------------------------------------------------------------
					HJJ->HJJ_INFPER := 'T'  		//T = Informa per�odo.  
					If !lSnapShot 
						HJJ->HJJ_PERINI := aPeriod[1]  
						HJJ->HJJ_PERFIN := aPeriod[2] 	 
					EndIf  
			       
					HJJ->HJJ_EMPRES	:= cCompany				
					HJJ->HJJ_ESTABL	:= cBranch
					HJJ->HJJ_CDFATO := cEntity      
					HJJ->HJJ_TIPFXA := 'I' 		   //I = Faixa de per�odo informada.        
			 	MsUnlock()
	
				HJJ->( DBCloseArea() )
				BIXUnlinkFSD()
			EndIf
		EndIf 
		
		FreeObj( oEntity )
	EndIf	
	
	RestArea( aArea )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPerFinal
Retorna a data final do per�odo de extra��o para uma fato.

@param cEntity, caracter, Fato que queremos saber quando foi extra�da. 
@return cFinal, caracter, Data final do per�odo de extra��o. 

@author  M�rcia Junko
@version P12 
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Function BIXPerFinal( cEntity )
	Local cFinal	:= ""
	Local cCompany	:= ""
	Local cBranch	:= ""
	
	Default cEntity := ""
	
	//-------------------------------------------------------------------
	// Recupera a informa��o da empresa e filial.  
	//-------------------------------------------------------------------	
	cCompany 	:= BIXCompany()
	cBranch		:= BIXBranch( cEntity ) 	
	
	//-------------------------------------------------------------------
	// Conecta na Fluig Smart Data. 
	//-------------------------------------------------------------------
	If ! ( BIXLinkFSD() == 0 )
		BIXSetupTable("HJJ")
		
		//-------------------------------------------------------------------
		// Abre a tabela. 
		//-------------------------------------------------------------------	
		DBUseArea(.T., "TOPCONN", "HJJ", "HJJ", .T., .F.)
		
		//-------------------------------------------------------------------
		// Seleciona o �ndice. 
		//-------------------------------------------------------------------	
		HJJ->( dbSetIndex("HJJ1") )
		HJJ->( dbSetIndex("HJJ2") )
		HJJ->( DBSetOrder( 2 ) )
		
		//-------------------------------------------------------------------
		// Localiza a informa��o do per�odo final. 
		//-------------------------------------------------------------------		
		If ( HJJ->( DBSeek(xFilial("HJJ") + cCompany + cBranch + cEntity  ) ) )
			cFinal := HJJ->HJJ_PERFIN 
		EndIf
		
		HJJ->( DBCloseArea() )
		BIXUnlinkFSD()
	EndIf
Return SToD( cFinal )

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCompany
Retorna a BK do campo empresa. 

@return cKey, caracter, retorna a chave. 

@author  Valdiney V GOMES
@version P12 
@since   08/06/2012
/*/
//-------------------------------------------------------------------
Static Function BIXCompany()
	Local oKey	:= nil 
  	Local cKey 	:= ""

	//-------------------------------------------------------------------
	// Recupera a informa��o do grupo de empresa e empresa.   
	//-------------------------------------------------------------------
 	cKey := FWGrpCompany() + "|" + FWCompany()

	//-------------------------------------------------------------------
	// Verifica se a empresa � vazia.   
	//-------------------------------------------------------------------
  	If ( Empty( AllTrim( Replace( cKey, "|", "" ) ) ) )
    	cKey 	:= UNDEFINED
  	EndIf
  	
	//-------------------------------------------------------------------
	// Monta a chave para a empresa.   
	//-------------------------------------------------------------------
	oKey := BIXKey( ):New( )
	cKey := oKey:GetKey( { cKey }, .T., .F., .F. ) 
	FreeObj( oKey )	
Return cKey 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXBranch
Retorna a BK do cammpo estabelecimento. 

@param cEntity, caracter, Tabela fato. 
@return cKey, caracter, retorna a chave. 

@author  Valdiney V GOMES
@version P12 
@since   08/06/2012
/*/
//-------------------------------------------------------------------
Static Function BIXBranch( cEntity )
	Local oEntity				:= nil 
	Local cKey					:= ""
	Local _cFilial			:= ""
	Local cBranch 			:= ""
	Local cTable				:= ""
	Local cTableBranch		:= ""
	Local cTableCompany		:= ""
	Local cTableUnitBusiness	:= ""
	Local cLayoutCompany		:= ""
	Local cLayoutUnitBusiness:= ""
	
	Default cEntity 	:= ""

	//-------------------------------------------------------------------
	// Recupera o layout da gest�o de empresas.   
	//-------------------------------------------------------------------	
	cLayoutCompany	 		:= FWSM0Layout(, 1) 
	cLayoutUnitBusiness	 	:= FWSM0Layout(, 2) 
	
	//-------------------------------------------------------------------
	// Recupera a tabela principal da entidade.   
	//-------------------------------------------------------------------
	oEntity := BIXObject( cEntity )
	
	If ! ( Empty( oEntity ) )
		cTable := oEntity:GetTable( )
		FreeObj( oEntity )
	EndIf 	

	//-------------------------------------------------------------------
	// Recupera as informa��es da tabela principal.   
	//-------------------------------------------------------------------		
	_cFilial			:= If( ! Empty( xFilial( cTable ) ), xFilial( cTable ), cFilAnt )	
 	cBranch 			:= If( Empty( _cFilial ), "__|" , FWFilial() + "|") 
	cTableBranch		:= FWFilial( cTable ) + "|"
	cTableCompany		:= FWCompany( cTable ) 
	cTableUnitBusiness	:= FWUnitBusiness( cTable )

	//-------------------------------------------------------------------
	// Verifica se a filial � vazia.   
	//-------------------------------------------------------------------
  	If ( Empty( AllTrim( Replace( cBranch, "|", "" ) ) ) )
    	cBranch := UNDEFINED
   	EndIf
  	
	If ( UNDEFINED $ cBranch )
    	cTableBranch := cBranch
    EndIf

	//-------------------------------------------------------------------
	// Recupera a informa��o da empresa e unidade de neg�cio.   
	//-------------------------------------------------------------------
	If ( ! Empty( cLayoutCompany ) .Or. ! Empty( cLayoutUnitBusiness ) )
		If ! ( Empty( cTableCompany ) )
			cKey += cTableCompany + "|"
		EndIf

		If ! ( Empty( cTableUnitBusiness ) )
			cKey += cTableUnitBusiness + "|"
		EndIf
	EndIf

	//-------------------------------------------------------------------
	// Verifica se a filial � vazia.   
	//-------------------------------------------------------------------
   	If ( ! Empty( AllTrim( Replace( cTableBranch, "|", "" ) ) ) )
		cKey += cTableBranch
	Else
		cKey += "__|" 
  	EndIf

	//-------------------------------------------------------------------
	// Monta a chave para a filial.   
	//-------------------------------------------------------------------
	cKey := "P |" + BIXInstance() + "|" + cEmpAnt + "|" + cKey
	
Return cKey