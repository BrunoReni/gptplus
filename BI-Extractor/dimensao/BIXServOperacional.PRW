#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSERVOPERACIONAL.CH"

REGISTER EXTRACTOR HO3

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXServOperacional
Visualiza as informa��es pelo servi�o operacional. O servi�o operacional 
caracteriza a execu��o de uma ou mais tarefas, como Viagem SP x RJ, 
Viagem SC X AM, etc.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXServOperacional from BIXEntity
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
Method New() class BIXServOperacional
	_Super:New( DIMENSION, "HO3", STR0001, "SX5" ) //"Servi�o Operacional"
Return Self  
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXServOperacional 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO3_SEROPE" )
	oModel:SetBK( { "HO3_CODIGO" } )

	oModel:AddField( "HO3_SEROPE" , "C", 32, 0 )
	oModel:AddField( "HO3_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HO3_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXServOperacional
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "L4" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO3_SEROPE", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HO3_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HO3_DESC"  , aContent[nI][4] )
		
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