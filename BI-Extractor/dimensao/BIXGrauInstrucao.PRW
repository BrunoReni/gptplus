#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGRAUINSTRUCAO.CH"

REGISTER EXTRACTOR HK9 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGrauInstrucao
Visualiza as informa��es por Grau de Instru��o do colaborador. 
Exemplo: Prim�rio, 2� grau, Superior Incompleto, Superior Completo, 
Especializa��o.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXGrauInstrucao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXGrauInstrucao
	_Super:New( DIMENSION, "HK9", STR0001, "SX5" ) //"Grau de Instru��o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXGrauInstrucao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HK9_GRAINS" )
	oModel:SetBK( { "HK9_CODIGO" } )

	oModel:AddField( "HK9_GRAINS", "C", 32,  0 )
	oModel:AddField( "HK9_CODIGO", "C", 10,  0 )
	oModel:AddField( "HK9_DESC"  , "C", 120, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXGrauInstrucao
 	Local aContent := {}
	Local nI := 0	

	aContent := FWGetSX5( "26" )

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
		oRecord:SetValue( "HK9_GRAINS", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HK9_CODIGO", aContent[nI][3]  )
		oRecord:SetValue( "HK9_DESC"  , aContent[nI][4] )
		
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