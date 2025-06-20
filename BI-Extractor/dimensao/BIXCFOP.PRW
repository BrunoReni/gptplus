#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCFOP.CH"

REGISTER EXTRACTOR HG0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCFOP
Visualiza as informa��es por c�digo e descri��o do C�digo Fiscal de 
Opera��es e Presta��es. Esta informa��o compreende uma classifica��o 
de todas as opera��es da empresa, regularizada pelo Fisco (Governo).

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Class BIXCFOP from BIXEntity
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
Method New() class BIXCFOP
	_Super:New( DIMENSION, "HG0", STR0001, "SX5" ) //CFOP
Return Self  


//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCFOP 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG0_CFOP" )
	oModel:SetBK( { "HG0_CODIGO" } )

	oModel:AddUnifier( { "HG0_CODIGO" }, STR0001 ) //CFOP
	
	oModel:AddField( "HG0_CFOP" 	, "C", 32, 0 )
	oModel:AddField( "HG0_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HG0_DESC"   	, "C", 80, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCFOP
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "13" )

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
		oRecord:SetValue( "HG0_CFOP", oKey:GetKey( { aContent[nI][3] }, , , , , .T. ) )		
		oRecord:SetValue( "HG0_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HG0_DESC"  , aContent[nI][4] )

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