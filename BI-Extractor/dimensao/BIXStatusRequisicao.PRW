#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTATUSREQUISICAO.CH"

REGISTER EXTRACTOR HQE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXStatusRequisicao
As informa��es s�o visualizadas por status em que se encontra a requisi��o
 de contrata��o. Exemplo: Em Andamento, Aprovada, Pendente etc. 

@author  BI TEAM
@since   17/11/2010
/*/
//-------------------------------------------------------------------
Class BIXStatusRequisicao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   17/11/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXStatusRequisicao
	_Super:New( DIMENSION, "HQE", STR0003 ) //"Status de Requisi��o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXStatusRequisicao
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQE_STAREQ" )
	oModel:SetBK( { "HQE_CODIGO" } )

	oModel:AddField( "HQE_STAREQ" , "C", 32, 0 )
	oModel:AddField( "HQE_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQE_DESC"   , "C", 20, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXStatusRequisicao
	Local aStatus := {}
	Local nStatus  := 0
	
	aAdd( aStatus, { "F", STR0001 } ) //"FINALIZADA" 
	aAdd( aStatus, { "A", STR0002 } ) //"ABERTA" 

	For nStatus := 1 To Len( aStatus )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQE_STAREQ", oKey:GetKey( { aStatus[nStatus][1] },,.F.) )		
		oRecord:SetValue( "HQE_CODIGO", aStatus[nStatus][1] )
		oRecord:SetValue( "HQE_DESC"  , aStatus[nStatus][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nStatus

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil
