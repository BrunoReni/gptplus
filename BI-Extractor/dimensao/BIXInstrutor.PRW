#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXINSTRUTOR.CH"

REGISTER EXTRACTOR HJO

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXInstrutor
Visualiza as informa��es por c�digo ou nome do Instrutor do curso/treinamento.

@author  BI TEAM
@since   10/08/2010
/*/
//-------------------------------------------------------------------
Class BIXInstrutor from BIXEntity
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
Method New() class BIXInstrutor
	_Super:New( DIMENSION, "HJO", STR0001, "RA7" ) //"Instrutor"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXInstrutor 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJO_INSTRU" )
	oModel:SetBK( { "HJO_CODIGO" } )

	oModel:AddField( "HJO_INSTRU" , "C", 32, 0 )
	oModel:AddField( "HJO_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HJO_NOME"   , "C", 120, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXInstrutor
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "RA7_INSTRU", "RA7_NOME"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RA7_INSTRU", 	(cFlow)->RA7_INSTRU )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJO_INSTRU" , oKey:GetKey( { (cFlow)->RA7_INSTRU } ) )		
		oRecord:SetValue( "HJO_CODIGO", (cFlow)->RA7_INSTRU )
		oRecord:SetValue( "HJO_NOME"  , (cFlow)->RA7_NOME )
		
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