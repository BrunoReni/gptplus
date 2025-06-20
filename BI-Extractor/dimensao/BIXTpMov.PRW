#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPMOV.CH"

REGISTER EXTRACTOR HK6

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpMov
Visualiza as informa��es por Tipo de Movimento, como entrada, 
sa�da ou saldo inicial.

@author  BI TEAM
@since   17/11/2010
/*/
//-------------------------------------------------------------------
Class BIXTpMov from BIXEntity
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
Method New() class BIXTpMov
	_Super:New( DIMENSION, "HK6", STR0005) //"Tipo de Movimento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpMov
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HK6_TIPMOV" )
	oModel:SetBK( { "HK6_CODIGO" } )

	oModel:AddField( "HK6_TIPMOV", "C", 32, 0 )
	oModel:AddField( "HK6_CODIGO", "C", 10, 0 )
	oModel:AddField( "HK6_DESC"  , "C", 40, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpMov
	Local nInd := 0
	Local aOrigem := {{ "1", STR0001 },; // "SALDO INICIAL" 
						{ "2", STR0002 },; // "ENTRADA" 
						{ "3", STR0003 },; // "SAIDA"
						{ "4", STR0004 } } // "MOVIMENTOS INTERNOS - Op��o exclusiva ao WMS"

	For nInd := 1 to len( aOrigem )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HK6_TIPMOV", oKey:GetKey( { aOrigem[nInd][1] },,.F.) )		
		oRecord:SetValue( "HK6_CODIGO", aOrigem[nInd][1] )
		oRecord:SetValue( "HK6_DESC"  , aOrigem[nInd][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nInd

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil	
