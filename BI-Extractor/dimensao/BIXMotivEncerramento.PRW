#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOTIVENCERRAMENTO.CH"

REGISTER EXTRACTOR HYK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMotivEncerramento
Visualiza as informa��es dos assuntos jur�dicos por motivos de 
encerramento do processo jur�dico

@author  Jorge Luis Branco Martins Junior
@since   23/05/2016
/*/
//-------------------------------------------------------------------
Class BIXMotivEncerramento from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Jorge Luis Branco Martins Junior
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXMotivEncerramento
	_Super:New( DIMENSION, "HYK", STR0001, "NQI" ) //"Motivo Encerramento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMotivEncerramento 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYK_MOTIVO" )
	oModel:SetBK( { "HYK_CODIGO" } )

	oModel:AddField( "HYK_MOTIVO" , "C", 32, 0 )
	oModel:AddField( "HYK_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HYK_DESC"   , "C", 80, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMotivEncerramento
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "NQI_COD", "NQI_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "NQI_COD", 	(cFlow)->NQI_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HYK_MOTIVO" , oKey:GetKey( { (cFlow)->NQI_COD } ) )		
		oRecord:SetValue( "HYK_CODIGO", (cFlow)->NQI_COD )
		oRecord:SetValue( "HYK_DESC"  , (cFlow)->NQI_DESC )
		
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