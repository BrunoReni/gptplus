#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXESTADOCIVIL.CH"

REGISTER EXTRACTOR HKE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEstadoCivil
Visualiza as informa��es por Estado Civil do colaborador. 
Exemplo: Solteiro, Casado, Separado, Desquitado.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXEstadoCivil from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )  
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXEstadoCivil
	_Super:New( DIMENSION, "HKE", STR0001, "SX5" ) //"Estado Civil"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXEstadoCivil
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKE_ESTCIV" )
	oModel:SetBK( { "HKE_CODIGO" } )

	oModel:AddField( "HKE_ESTCIV" , "C", 32, 0 )
	oModel:AddField( "HKE_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HKE_DESC"   , "C", 50, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXEstadoCivil
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "33" )

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
		oRecord:SetValue( "HKE_ESTCIV", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HKE_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HKE_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	NEXT
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent )
Return nil	
