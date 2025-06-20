#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXAREAPOSTO.CH"

REGISTER EXTRACTOR HOK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAreaPosto
Representa��o do extrator.

@author  Valdiney V GOMES
@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Class BIXAreaPosto from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXAreaPosto
	_Super:New( DIMENSION, "HOK", STR0001, "SX5" ) //"�rea do Posto"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXAreaPosto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOK_AREA" )
	oModel:SetBK( { "HOK_CODIGO" } )

	oModel:AddField( "HOK_AREA" , "C", 32, 0 )
	oModel:AddField( "HOK_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HOK_DESC"   , "C", 55, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXAreaPosto
 	Local aContent := {}
	Local nI	   := 0

	aContent := FWGetSX5( "A2" )

	For nI := 1 to Len( aContent ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE",  aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOK_AREA", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HOK_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HOK_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
 	Next

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent )
Return nil
