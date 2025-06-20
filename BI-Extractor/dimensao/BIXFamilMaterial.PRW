#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFAMILMATERIAL.CH"

REGISTER EXTRACTOR HG2

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFamilMaterial
Visualiza as informa��es por c�digo ou descri��o da Fam�lia de 
Material. Fam�lia de Material � um conjunto de itens do estoque, 
agrupados segundo crit�rios t�cnicos de afinidade de materiais, como 
natureza, composi��o e aplica��o, voltada para a �rea industrial.

@author  BI TEAM
@since   05/08/2010
/*/
//-------------------------------------------------------------------
Class BIXFamilMaterial from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Tamara Clemente
@since   28/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXFamilMaterial
	_Super:New( DIMENSION, "HG2", STR0001, "SX5" ) //"Fam�lia Material"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFamilMaterial 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG2_FAMMAT" )
	oModel:SetBK( { "HG2_CODIGO" } )

	oModel:AddField( "HG2_FAMMAT"	, "C", 32, 0 )
	oModel:AddField( "HG2_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HG2_DESC"   	, "C", 30, 0 )
	oModel:AddField( "HG2_UNFAMA"  	, "C", 05, 0 )
	
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
@since   25/10/2013
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFamilMaterial
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "02" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG2_FAMMAT"	, oKey:GetKey( { aContent[nI][3] } ) )
		oRecord:SetValue( "HG2_CODIGO"	, aContent[nI][3] )
		oRecord:SetValue( "HG2_DESC"	, aContent[nI][4] )
		oRecord:SetValue( "HG2_UNFAMA"	, " " )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 

	NEXT
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent )
Return nil