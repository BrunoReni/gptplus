#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPOPERACAO.CH"

REGISTER EXTRACTOR HO6

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpOperacao
Visualiza as informa��es por tipo de opera��o. O tipo da opera��o indica 
se o servi�o operacional � do tipo transporte ou carregamento.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpOperacao from BIXEntity
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
Method New() class BIXTpOperacao
	_Super:New( DIMENSION, "HO6", STR0003) //"Tipo de Opera��o"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpOperacao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO6_TIPOPE" )
	oModel:SetBK( { "HO6_CODIGO" } )

	oModel:AddField( "HO6_TIPOPE", "C", 32, 0 )
	oModel:AddField( "HO6_CODIGO", "C", 10, 0 )
	oModel:AddField( "HO6_DESC"  , "C", 12, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpOperacao
	Local aOperacao 	:= { {"1", "CARREGAMENTO" }, {"2", "TRANSPORTE" } }  //"CARREGAMENTO"###"TRANSPORTE"
	Local nOperacao		:= 1				    
	
	For nOperacao := 1 To Len( aOperacao )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO6_TIPOPE", oKey:GetKey( { aOperacao[nOperacao][1] },,.F.) )		
		oRecord:SetValue( "HO6_CODIGO", aOperacao[nOperacao][1] )
		oRecord:SetValue( "HO6_DESC"  , aOperacao[nOperacao][2] )

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