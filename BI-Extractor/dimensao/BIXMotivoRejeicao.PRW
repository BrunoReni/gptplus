#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOTIVOREJEICAO.CH"

REGISTER EXTRACTOR HK0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMotivoRejeicao
Visualiza as informa��es por c�digo ou descri��o do motivo de rejei��o. 
Possibilita analisar o motivo da rejei��o e aprova��o condicional dos 
roteiros de inspe��o pela empresa.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXMotivoRejeicao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Helio Leal
@since   02/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXMotivoRejeicao
	_Super:New( DIMENSION, "HK0", STR0001, "EY1" ) //"Motivo de Rejei��o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMotivoRejeicao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HK0_MOTREJ" )
	oModel:SetBK( { "HK0_CODIGO" } )

	oModel:AddField( "HK0_MOTREJ" , "C", 32, 0 )
	oModel:AddField( "HK0_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HK0_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMotivoRejeicao
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "EY1_CLAREJ", "EY1_DSCREJ"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "EY1_CLAREJ", 	(cFlow)->EY1_CLAREJ )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HK0_MOTREJ" , oKey:GetKey( { (cFlow)->EY1_CLAREJ } ) )		
		oRecord:SetValue( "HK0_CODIGO", (cFlow)->EY1_CLAREJ )
		oRecord:SetValue( "HK0_DESC"  , (cFlow)->EY1_DSCREJ )
		
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