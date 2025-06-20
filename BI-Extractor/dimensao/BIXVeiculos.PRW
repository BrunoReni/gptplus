#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXVEICULOS.CH"

REGISTER EXTRACTOR HHZ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVeiculos
Visualiza as informa��es por ve�culo de transporte. O ve�culo � o 
transporte utilizado pela transportadora para a entrega da mercadoria.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXVeiculos from BIXEntity
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
Method New() class BIXVeiculos
	_Super:New( DIMENSION, "HHZ", STR0001, "DA3" )  //"Ve�culos"
Return Self 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXVeiculos
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HHZ_VEICLO" )
	oModel:SetBK( { "HHZ_CODIGO" } )

	oModel:AddField( "HHZ_VEICLO"	, "C", 32, 0 )
	oModel:AddField( "HHZ_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HHZ_DESC"   	, "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXVeiculos
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "DA3_COD", "DA3_DESC"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "DA3_COD"		, (cFlow)->DA3_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HHZ_VEICLO"	, oKey:GetKey( { (cFlow)->DA3_COD } ) )
		oRecord:SetValue( "HHZ_CODIGO"	, (cFlow)->DA3_COD )
		oRecord:SetValue( "HHZ_DESC"	, (cFlow)->DA3_DESC )

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
			