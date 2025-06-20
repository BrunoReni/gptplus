#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRELTRABALHO.CH"

REGISTER EXTRACTOR HKD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRelTrabalho
As informa��es s�o visualizadas por c�digo ou descri��o da Rela��o de 
Trabalho entre empresa e colaborador. Exemplos: Estagi�rio, Cooperado, 
Funcion�rio, S�cio, Tempor�rio, Contratado.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXRelTrabalho from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   04/01/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXRelTrabalho
	_Super:New( DIMENSION, "HKD", STR0001, "SX5" ) //"Rela��o de Trabalho"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRelTrabalho 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKD_RELTRB" )
	oModel:SetBK( { "HKD_CODIGO" } )

	oModel:AddField( "HKD_RELTRB" , "C", 32, 0 )
	oModel:AddField( "HKD_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HKD_DESC"   , "C", 50, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRelTrabalho
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "38" )

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
		oRecord:SetValue( "HKD_RELTRB", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HKD_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HKD_DESC"  , aContent[nI][4] )
		
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