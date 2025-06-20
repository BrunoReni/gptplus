#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSECAO.CH"

REGISTER EXTRACTOR HQ0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSecao
As informa��es s�o visualizadas pelas se��es onde os funcion�rios est�o 
alocados, como: Endere�o, Filial, Departamento, Dados para INSS, etc. 
Cada funcion�rio est� vinculado a uma se��o, exemplo: Funcion�rios da 
�rea administrativa est�o vinculados a se��o Administrativa. Funcion�rios 
do departamento de Desenvolvimento est�o vinculados a se��o relativa ao 
Desenvolvimento

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXSecao from BIXEntity
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
Method New() class BIXSecao
	_Super:New( DIMENSION, "HQ0", STR0001, "SQB" ) //"Se��o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSecao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQ0_SECAO" )
	oModel:SetBK( { "HQ0_CODIGO" } )

	oModel:AddField( "HQ0_SECAO" , "C", 32, 0 )
	oModel:AddField( "HQ0_CODIGO" , "C", 35, 0 )		
	oModel:AddField( "HQ0_DESC"   , "C", 60, 0 )		
	
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
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSecao
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "QB_DEPTO", "QB_DESCRIC" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "QB_DEPTO", 	(cFlow)->QB_DEPTO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQ0_SECAO", oKey:GetKey( { (cFlow)->QB_DEPTO } ) )		
		oRecord:SetValue( "HQ0_CODIGO", (cFlow)->QB_DEPTO )
		oRecord:SetValue( "HQ0_DESC"  , (cFlow)->QB_DESCRIC )
		
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