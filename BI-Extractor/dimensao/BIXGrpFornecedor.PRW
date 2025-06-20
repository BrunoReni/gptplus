#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGRPFORNECEDOR.CH

REGISTER EXTRACTOR HGE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGrpFornecedor
As informa��es s�o visualizadas por Grupo de Fornecedores que � um 
agrupamento dos mesmos com caracter�sticas comuns.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXGrpFornecedor from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Valdiney V GOMES
@since   21/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXGrpFornecedor
	_Super:New( DIMENSION, "HGE", STR0001, "SX5" ) //"Grupo de Fornecedor"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   03/03/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXGrpFornecedor
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGE_GRPFOR" )
	oModel:SetBK( { "HGE_CODIGO" } )

	oModel:AddField( "HGE_GRPFOR" , "C", 32, 0 )
	oModel:AddField( "HGE_CODIGO" , "C", 11, 0 )
	oModel:AddField( "HGE_DESC"   , "C", 40, 0 )

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
@since   11/08/2010
/*/
//-------------------------------------------------------------------
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXGrpFornecedor
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "Y7" )

 	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGE_GRPFOR", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HGE_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HGE_DESC"  , aContent[nI][4] )
	
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