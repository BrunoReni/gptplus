#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDOCESPEC.CH"

REGISTER EXTRACTOR HJG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDocEspec
Visualiza as informa��es por esp�cie de documento utilizado pela 
empresa. Esp�cies de documentos identificam os tipos de documentos 
utilizados dentro da organiza��o, facilitando o controle.

@author  BI TEAM
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Class BIXDocEspec from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXDocEspec
	_Super:New( DIMENSION, "HJG", STR0001 , "SX5" ) //"Esp�cie do Documento"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@version P12 
@since   22/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXDocEspec
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJG_ESPDOC" )
	oModel:SetBK( { "HJG_CODIGO" } )

	oModel:AddField( "HJG_ESPDOC" 	, "C", 32, 0 )
	oModel:AddField( "HJG_TIPO" 	, "C", 1, 0  )
	oModel:AddField( "HJG_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HJG_DESC"   	, "C", 55, 0 )

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

@author  BI TEAM
@since   22/02/2017
/*/
//-------------------------------------------------------------------
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXDocEspec
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "05" )

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
		oRecord:SetValue( "HJG_ESPDOC", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HJG_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HJG_DESC"  , aContent[nI][4] )
		oRecord:SetValue( "HJG_TIPO"  , "" )
	
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