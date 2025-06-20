#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTURNO.CH"

REGISTER EXTRACTOR HJU 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTurno
As informa��es s�o visualizadas por c�digo ou descri��o dos turnos de 
trabalho existentes na empresa. Exemplo: Turno Matutino, Turno Noturno, 
Turno Normal. 

@author  BI TEAM
@since   09/08/2010
/*/
//-------------------------------------------------------------------
Class BIXTurno from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   09/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXTurno
	_Super:New( DIMENSION, "HJU", STR0001, "SR6" ) //"Turno"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTurno
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJU_TURNO" )
	oModel:SetBK( { "HJU_CODIGO" } )

	oModel:AddField( "HJU_TURNO", "C", 32, 0 )
	oModel:AddField( "HJU_CODIGO", "C", 10, 0 )
	oModel:AddField( "HJU_DESC"  , "C", 50, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTurno
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "R6_TURNO", "R6_DESC"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "R6_TURNO"		, (cFlow)->R6_TURNO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJU_TURNO"	,  oKey:GetKey( { (cFlow)->R6_TURNO } ) )
		oRecord:SetValue( "HJU_CODIGO"	, (cFlow)->R6_TURNO )
		oRecord:SetValue( "HJU_DESC"	, (cFlow)->R6_DESC )

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