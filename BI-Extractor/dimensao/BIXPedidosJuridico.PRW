#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPEDIDOSJURIDICO.CH"

REGISTER EXTRACTOR HYL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPedidosJuridico
Visualiza as informa��es do assuntors jur�dicos de acordo com os tipo 
de pedidos realizados em um processo.

@author  Jorge Luis Branco Martins Junior
@since   23/05/2016
/*/
//-------------------------------------------------------------------
Class BIXPedidosJuridico from BIXEntity
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
Method New() class BIXPedidosJuridico
	_Super:New( DIMENSION, "HYL", STR0001, "NSP" ) //"Pedidos Jur�dico"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXPedidosJuridico 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYL_PEDJUR" )
	oModel:SetBK( { "HYL_CODIGO" } )

	oModel:AddField( "HYL_PEDJUR" , "C", 32, 0 )
	oModel:AddField( "HYL_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HYL_DESC"   , "C", 100, 0 )		
	oModel:AddField( "HYL_TIPO"   , "C", 15, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXPedidosJuridico
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "NSP_COD", "NSP_DESC", "NSP_TIPO" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "NSP_COD", (cFlow)->NSP_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HYL_PEDJUR" , oKey:GetKey( { (cFlow)->NSP_COD } ) )		
		oRecord:SetValue( "HYL_CODIGO" , (cFlow)->NSP_COD )
		oRecord:SetValue( "HYL_DESC"   , (cFlow)->NSP_DESC )
		oRecord:SetValue( "HYL_TIPO"   , (cFlow)->NSP_TIPO )
		
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
