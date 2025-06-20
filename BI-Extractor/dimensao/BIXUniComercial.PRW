#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUNICOMERCIAL.CH"

REGISTER EXTRACTOR HSP

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXUniComercial
Visualiza as informa��es por c�digo ou descri��o da unidade comercial. 
A unidade comercial permite o controle das unidades de neg�cio de uma 
organiza��o ou empresa, como: filiais, franquias e revendas.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXUniComercial from BIXEntity
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
Method New() class BIXUniComercial
	_Super:New( DIMENSION, "HSP", STR0001, "ADK" ) //"Unidade Comercial"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXUniComercial
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSP_UNICOM" )
	oModel:SetBK( { "HSP_CODIGO" } )

	oModel:AddField( "HSP_UNICOM"	, "C", 32, 0 )
	oModel:AddField( "HSP_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HSP_NOME"   	, "C", 40, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUniComercial
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "ADK_COD", "ADK_NOME"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "ADK_COD"		, (cFlow)->ADK_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSP_UNICOM"	, oKey:GetKey( { (cFlow)->ADK_COD } ) )
		oRecord:SetValue( "HSP_CODIGO"	, (cFlow)->ADK_COD )
		oRecord:SetValue( "HSP_NOME"	, (cFlow)->ADK_NOME )

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
