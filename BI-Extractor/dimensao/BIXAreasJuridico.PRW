#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXAREASJURIDICO.CH"

REGISTER EXTRACTOR HYJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAreasJuridico
Visualiza as informa��es dos assuntos jur�dicos de acordo com a �rea 
jur�dica respons�vel.

@author  Jorge Luis Branco Martins Junior
@since   23/05/2016
/*/
//-------------------------------------------------------------------
Class BIXAreasJuridico from BIXEntity
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
Method New() class BIXAreasJuridico
	_Super:New( DIMENSION, "HYJ", STR0001, "NRB" ) //"�reas Jur�dico"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Jorge Luis Branco Martins Junior
@version P12 
@since   23/05/2016
/*/
//------------------------------------------------------------------- 
Method Model() class BIXAreasJuridico 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYJ_AREAJU" )
	oModel:SetBK( { "HYJ_CODIGO" } )

	oModel:AddField( "HYJ_AREAJU" , "C", 32, 0 )
	oModel:AddField( "HYJ_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HYJ_DESC"   , "C", 50, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXAreasJuridico
 	Local cFlow  := ""

	cFlow := ::Flow( cFrom, cTo, { "NRB_COD", "NRB_DESC" } )

 	While ! ( (cFlow)->( Eof() ) )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "NRB_COD"		, (cFlow)->NRB_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------		
		oRecord:SetValue( "HYJ_AREAJU"	, oKey:GetKey( { (cFlow)->NRB_COD } ) )	
		oRecord:SetValue( "HYJ_CODIGO"	, (cFlow)->NRB_COD )
		oRecord:SetValue( "HYJ_DESC"	, (cFlow)->NRB_DESC )
		
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
