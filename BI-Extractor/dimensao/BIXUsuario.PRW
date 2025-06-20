#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUSUARIO.CH"

REGISTER EXTRACTOR HSQ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXUsuario
Visualiza as informa��es por c�digo ou nome do usu�rio do CRM.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXUsuario from BIXEntity
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
Method New() class BIXUsuario
	_Super:New( DIMENSION, "HSQ", STR0001, "AO3" ) //"Usu�rio"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   15/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXUsuario
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSQ_USUARI" )
	oModel:SetBK( { "HSQ_CODIGO" } )

	oModel:AddField( "HSQ_USUARI"	, "C", 32, 0 )
	oModel:AddField( "HSQ_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HSQ_NOME"  	, "C", 50, 0 )
	
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
@since   15/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUsuario
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "AO3_CODUSR" } )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "AO3_CODUSR"		, (cFlow)->AO3_CODUSR )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSQ_USUARI"	, oKey:GetKey( { (cFlow)->AO3_CODUSR } ) )
		oRecord:SetValue( "HSQ_CODIGO"	, (cFlow)->AO3_CODUSR )
		oRecord:SetValue( "HSQ_NOME"	, UsrFullName( (cFlow)->AO3_CODUSR ) )

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