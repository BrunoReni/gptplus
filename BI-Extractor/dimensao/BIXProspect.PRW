#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROSPECT.CH"

REGISTER EXTRACTOR HSR

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProspect
Visualiza as informa��espor c�digo ou descri��o do prospect. 
O prospect � uma conta para ser trabalhada atrav�s de uma 
oportunidade de venda afim de gerar um cliente no futuro.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXProspect from BIXEntity
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
Method New() class BIXProspect
	_Super:New( DIMENSION, "HSR", STR0001, "SUS" ) //"Prospect"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXProspect 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSR_PROSPE" )
	oModel:SetBK( { "HSR_CODIGO" } )

	oModel:AddField( "HSR_PROSPE" , "C", 32, 0 )
	oModel:AddField( "HSR_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSR_LOJA"   , "C", 02, 0 )		
	oModel:AddField( "HSR_RAZAO"  , "C", 40, 0 )		
	oModel:AddField( "HSR_NOME"   , "C", 20, 0 )		
	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXProspect
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "US_COD", "US_LOJA", "US_NOME", "US_NREDUZ" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "US_COD", (cFlow)->US_COD )
		oRecord:SetValue( "US_LOJA", (cFlow)->US_LOJA )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSR_PROSPE" , oKey:GetKey( { (cFlow)->US_COD, (cFlow)->US_LOJA } ) )		
		oRecord:SetValue( "HSR_CODIGO" , (cFlow)->US_COD )
		oRecord:SetValue( "HSR_LOJA"   , (cFlow)->US_LOJA )
		oRecord:SetValue( "HSR_RAZAO"   , (cFlow)->US_NOME )
		oRecord:SetValue( "HSR_NOME"   , (cFlow)->US_NREDUZ )
		
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