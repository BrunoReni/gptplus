#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXATENDENTE.CH"

REGISTER EXTRACTOR HOH

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAtendente
Visualiza as informa��es pelo c�digo e nome do atendente. 
Atendente representa a pessoa/recurso dispon�vel para a presta��o 
de servi�os contratados.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXAtendente from BIXEntity
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
Method New() class BIXAtendente
	_Super:New( DIMENSION, "HOH", STR0001, "AA1" ) //"Atendente"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXAtendente 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOH_ATENDE" )
	oModel:SetBK( { "HOH_CODIGO" } )

	oModel:AddField( "HOH_ATENDE" , "C", 32, 0 )
	oModel:AddField( "HOH_CODIGO" , "C", 30, 0 )
	oModel:AddField( "HOH_NOME"   , "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXAtendente
 	Local cFlow  := ""

	cFlow := ::Flow( cFrom, cTo, { "AA1_CODTEC", "AA1_NOMTEC" } )

 	While ! ( (cFlow)->( Eof() ) )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "AA1_CODTEC"		, (cFlow)->AA1_CODTEC )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------		
		oRecord:SetValue( "HOH_ATENDE"	, oKey:GetKey( { (cFlow)->AA1_CODTEC } ) )	
		oRecord:SetValue( "HOH_CODIGO"	, (cFlow)->AA1_CODTEC )
		oRecord:SetValue( "HOH_NOME"	, (cFlow)->AA1_NOMTEC )
		
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
