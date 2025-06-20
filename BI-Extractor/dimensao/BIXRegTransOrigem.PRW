#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREGTRANSORIGEM.CH"

REGISTER EXTRACTOR HO0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRegTransOrigem
Visualiza as informa��es pela regi�o que originou o transporte. 
As regi�es de transporte n�o s�o necessariamente regi�es geogr�ficas, 
podendo ser definidas de acordo com trajeto e pre�os aplicados pela 
transportadora.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXRegTransOrigem from BIXEntity
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
Method New() class BIXRegTransOrigem
	_Super:New( DIMENSION, "HO0", STR0001, "DUY" ) //"Regi�o de Transporte de Origem"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRegTransOrigem 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO0_REGTRA" )
	oModel:SetBK( { "HO0_CODIGO" } )

	oModel:AddField( "HO0_REGTRA" , "C", 32, 0 )
	oModel:AddField( "HO0_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HO0_DESC"   , "C", 30, 0 )		
	
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
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRegTransOrigem
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "DUY_GRPVEN", "DUY_DESCRI" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "DUY_GRPVEN", 	(cFlow)->DUY_GRPVEN )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO0_REGTRA", oKey:GetKey( { (cFlow)->DUY_GRPVEN } ) )		
		oRecord:SetValue( "HO0_CODIGO", (cFlow)->DUY_GRPVEN )
		oRecord:SetValue( "HO0_DESC"  , (cFlow)->DUY_DESCRI )
		
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