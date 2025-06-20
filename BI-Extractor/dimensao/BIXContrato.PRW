#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCONTRATO.CH"

REGISTER EXTRACTOR HOJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXContrato
Visualiza as informa��es pelo c�digo e revis�o do contrato. 
Contrato � o acordo firmado entre as partes que define os recursos 
necess�rios na contrata��o da presta��o do servi�o.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXContrato from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )   
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXContrato
	_Super:New( DIMENSION, "HOJ", STR0001, "CN9" ) //"Contrato"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXContrato 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOJ_CONTRA" )
	oModel:SetBK( { "HOJ_CODIGO" } )

	oModel:AddField( "HOJ_CONTRA", "C", 60, 0 )
	oModel:AddField( "HOJ_CODIGO", "C", 15, 0 )
	oModel:AddField( "HOJ_REVISA", "C", 3, 0 )		
	
	oModel:FreeField() 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXContrato
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "CN9_NUMERO", "CN9_REVISA"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CN9_NUMERO", 	(cFlow)->CN9_NUMERO )
		oRecord:SetValue( "CN9_REVISA", 	(cFlow)->CN9_REVISA )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOJ_CONTRA" , oKey:GetKey( { (cFlow)->CN9_NUMERO, (cFlow)->CN9_REVISA } ) )		
		oRecord:SetValue( "HOJ_CODIGO", (cFlow)->CN9_NUMERO )
		oRecord:SetValue( "HOJ_REVISA"  , (cFlow)->CN9_REVISA )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
 	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil