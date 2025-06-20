#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTTPROPCOMERCIAL.CH"

REGISTER EXTRACTOR HSI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSttPropComercial
Visualiza as informa��es pelo status em que se encontra a proposta 
comercial vinculada a oportunidade de venda. Ex: Aberta, fechada, Cancelada, etc.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXSttPropComercial from BIXEntity
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
Method New() class BIXSttPropComercial
	_Super:New( DIMENSION, "HSI", STR0007 ) //"Status da Proposta Comercial"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSttPropComercial 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSI_STTPRO" )
	oModel:SetBK( { "HSI_CODIGO" } )

	oModel:AddField( "HSI_STTPRO" , "C", 32, 0 )
	oModel:AddField( "HSI_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSI_DESC"   , "C", 12, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSttPropComercial
   Local aStatus 	:= {} 
	Local nStatus	:= 1
	
	aAdd( aStatus, {"A", STR0001 } )  //"Aberta"
	aAdd( aStatus, {"B", STR0002 } )  //"Fechada"	
	aAdd( aStatus, {"C", STR0003 } )  //"Cancelada"
	aAdd( aStatus, {"D", STR0004 } )  //"N�o Aprovada"
	aAdd( aStatus, {"E", STR0005 } )  //"Aprovada"
	aAdd( aStatus, {"F", STR0006 } )  //"Bloqueada"					    
	
	For nStatus := 1 To Len( aStatus )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSI_STTPRO", oKey:GetKey( { aStatus[nStatus][1] },,.F.) )		
		oRecord:SetValue( "HSI_CODIGO", aStatus[nStatus][1] )
		oRecord:SetValue( "HSI_DESC"  , aStatus[nStatus][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	
 	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil