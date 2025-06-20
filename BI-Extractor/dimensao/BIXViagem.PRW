#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXVIAGEM.CH"

REGISTER EXTRACTOR HO7

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXViagem
Visualiza as informa��es pela viagem. A viagem � a identifica��o de 
cada servi�o prestado pela transportado ao cliente.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXViagem from BIXEntity
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
Method New() class BIXViagem
	_Super:New( DIMENSION, "HO7", STR0001, "DTQ" ) // "Viagem" 
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXViagem
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO7_VIAGEM" )
	oModel:SetBK( { "HO7_CODIGO" } )

	oModel:AddField( "HO7_VIAGEM"	, "C", 32, 0 )
	oModel:AddField( "HO7_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HO7_FILORV"  	, "C", 12, 0 )
	
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
@since   14/05/2017

/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXViagem
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "DTQ_VIAGEM", "DTQ_FILORI"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "DTQ_VIAGEM"		, (cFlow)->DTQ_VIAGEM )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO7_VIAGEM"	, oKey:GetKey( { (cFlow)->DTQ_VIAGEM } ) )
		oRecord:SetValue( "HO7_CODIGO"	, (cFlow)->DTQ_VIAGEM )
		oRecord:SetValue( "HO7_FILORV"	, (cFlow)->DTQ_FILORI )

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