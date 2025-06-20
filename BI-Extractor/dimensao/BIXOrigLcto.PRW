#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXORIGLCTO.CH"

REGISTER EXTRACTOR HS7

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOrigLcto
Visualiza as informa��es pela origem do lan�amento. A origem do 
lan�amento determina se ele � proveniete do m�dulo de faturamento ou 
do varejo.

@author  Valdiney V GOMES
@since   10/04/2014
/*/
//-------------------------------------------------------------------
Class BIXOrigLcto from BIXEntity
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
Method New() class BIXOrigLcto
	_Super:New( DIMENSION, "HS7", STR0004 ) // "Origem do Lan�amento" 
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXOrigLcto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HS7_ORILAN" )
	oModel:SetBK( { "HS7_CODIGO" } )

	oModel:AddField( "HS7_ORILAN" , "C", 32, 0 )
	oModel:AddField( "HS7_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HS7_DESC"   , "C", 15, 0 )		
	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXOrigLcto
	Local aOrigem 	:= {}
	Local nOrigem	:= 1  
	
	aAdd( aOrigem, {"LF", STR0001} ) //"Livro Fiscal"			    
	aAdd( aOrigem, {"VD", STR0002} ) //"Venda Direta"
	aAdd( aOrigem, {"LO", STR0003} ) //"Loja"
			
	For nOrigem := 1 To Len( aOrigem )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		oRecord:SetValue( "HS7_ORILAN" , oKey:GetKey( { aOrigem[nOrigem][1] }, , .F. ) )		
		oRecord:SetValue( "HS7_CODIGO" , aOrigem[nOrigem][1] )
		oRecord:SetValue( "HS7_DESC"   , aOrigem[nOrigem][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
return nIL