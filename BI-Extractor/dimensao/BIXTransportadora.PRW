#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTRANSPORTADORA.CH"

REGISTER EXTRACTOR HJ2

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTransportadora
As informa��es s�o visualizadas por c�digo ou nome do Cliente. 

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------
Class BIXTransportadora from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXTransportadora
	_Super:New( DIMENSION, "HJ2", STR0001, "SA4" ) //"Transportadora"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTransportadora 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ2_TRANSP" )
	oModel:SetBK( { "HJ2_CODIGO" } )

	oModel:AddField( "HJ2_TRANSP" , "C", 32, 0 )
	oModel:AddField( "HJ2_CODIGO" , "C", 15, 0 )
	oModel:AddField( "HJ2_NOME"   , "C", 50, 0 )
	oModel:AddField( "HJ2_NOMEAB" , "C", 20, 0 )
	
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

@author  Helio Leal
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTransportadora
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "A4_COD", "A4_NOME", "A4_NREDUZ" } )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "A4_COD"		, (cFlow)->A4_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJ2_TRANSP"	, oKey:GetKey( { (cFlow)->A4_COD} ) )
		oRecord:SetValue( "HJ2_CODIGO"	, (cFlow)->A4_COD )
		oRecord:SetValue( "HJ2_NOME"	, (cFlow)->A4_NOME )
		oRecord:SetValue( "HJ2_NOMEAB"	, (cFlow)->A4_NREDUZ )

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