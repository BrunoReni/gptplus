#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITEXPORTACAO.CH"

REGISTER EXTRACTOR HGJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitExportacao
As informa��es s�o visualizadas pela situa��o do processo de exporta��o. 
Exemplo: Aberto, Faturado, Embarcado, Cancelado. 

@author  BI TEAM
@since   12/08/2010
/*/
//-------------------------------------------------------------------
Class BIXSitExportacao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   18/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXSitExportacao
	_Super:New( DIMENSION, "HGJ", STR0001, "SX5" )//Situa��o de Exporta��o 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSitExportacao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGJ_SITEXP" )
	oModel:SetBK( { "HGJ_CODIGO" } )

	oModel:AddField( "HGJ_SITEXP" , "C", 32, 0 )
	oModel:AddField( "HGJ_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HGJ_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSitExportacao
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "YC" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGJ_SITEXP", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HGJ_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HGJ_DESC"  , aContent[nI][4] )
		
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