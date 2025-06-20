#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXOPERACAO.CH"

REGISTER EXTRACTOR HQC

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOperacao
Visualiza as informa��es por opera��o do processo de produ��o.

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Class BIXOperacao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Tamara Clemente
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXOperacao
	_Super:New( DIMENSION, "HQC", STR0001, "SG2" ) //"Opera��o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXOperacao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQC_OPERA" )
	oModel:SetBK( { "HQC_CODIGO" } )

	oModel:AddField( "HQC_OPERA"  , "C", 32, 0 )
	oModel:AddField( "HQC_CODROT" , "C", 16, 0 )		
	oModel:AddField( "HQC_CODPRO" , "C", 30, 0 )		
	oModel:AddField( "HQC_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQC_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXOperacao
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "G2_PRODUTO", "G2_CODIGO", "G2_OPERAC", "G2_REFGRD", "G2_DESCRI"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "G2_CODIGO", 	(cFlow)->G2_CODIGO )
		oRecord:SetValue( "G2_PRODUTO", 	(cFlow)->G2_PRODUTO )
		oRecord:SetValue( "G2_REFGRD", 	(cFlow)->G2_REFGRD )
		oRecord:SetValue( "G2_OPERAC", 	(cFlow)->G2_OPERAC )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQC_OPERA" , oKey:GetKey( { (cFlow)->G2_OPERAC } ) )		
		oRecord:SetValue( "HQC_CODIGO", (cFlow)->G2_OPERAC )
		oRecord:SetValue( "HQC_CODPRO", (cFlow)->G2_PRODUTO )
		oRecord:SetValue( "HQC_CODROT", (cFlow)->G2_CODIGO )
		oRecord:SetValue( "HQC_DESC"  , (cFlow)->G2_DESCRI )
		
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