#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITUACOLABORADOR.CH"

REGISTER EXTRACTOR HKA

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSituaColaborador
As informa��es s�o visualizadas por c�digo ou descri��o da Situa��o do 
colaborador junto a empresa. As situa��es s�o: Situa��o Trabalhando, 
Sa�da por Transfer�ncia, F�rias, Rescis�o, Afastado.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXSituaColaborador from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   11/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXSituaColaborador
	_Super:New( DIMENSION, "HKA", STR0001, "SX5" ) //"Situa��o do Colaborador"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSituaColaborador
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKA_SITCLB" )
	oModel:SetBK( { "HKA_CODIGO" } )

	oModel:AddField( "HKA_SITCLB" , "C", 32, 0 )
	oModel:AddField( "HKA_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HKA_DESC"   , "C", 50, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSituaColaborador
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "31" )

	For nI := 1 to Len( aContent ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HKA_SITCLB",  oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HKA_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HKA_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	Next

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent )
Return nil
