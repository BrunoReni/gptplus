#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXROTA.CH"

REGISTER EXTRACTOR HGI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRota
Visualiza as informa��es por Rota. Rota s�o itiner�rios (caminhos) 
definidos pela transportadora.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXRota from BIXEntity
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
Method New() class BIXRota
	_Super:New( DIMENSION, "HGI", STR0001, "DA8" )//Rota 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRota 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGI_ROTA" )
	oModel:SetBK( { "HGI_CODIGO" } )

	oModel:AddField( "HGI_ROTA"   , "C", 32, 0 )
	oModel:AddField( "HGI_CODIGO" , "C", 12, 0 )		
	oModel:AddField( "HGI_DESC"   , "C", 40, 0 )		
	
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
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRota
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "DA8_COD", "DA8_DESC" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "DA8_COD", 	(cFlow)->DA8_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGI_ROTA", oKey:GetKey( { (cFlow)->DA8_COD } ) )		
		oRecord:SetValue( "HGI_CODIGO", (cFlow)->DA8_COD )
		oRecord:SetValue( "HGI_DESC"  , (cFlow)->DA8_DESC )
		
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