#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXNATOPERACAO.CH"

REGISTER EXTRACTOR HJ9

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXNatOperacao
As informa��es s�o visualizadas por c�digo ou descri��o da Natureza de 
Opera��o. Permitir identificar as caracter�sticas fiscais dos itens 
referentes � opera��o fiscal que est� sendo realizada..

@author  Tamara Clemente
@since   13/05/2016
/*/
//-------------------------------------------------------------------
Class BIXNatOperacao from BIXEntity
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
Method New() class BIXNatOperacao
	_Super:New( DIMENSION, "HJ9", STR0001, "SF4" )//Natureza da Opera��o 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXNatOperacao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ9_NATOPR" )
	oModel:SetBK( { "HJ9_CODIGO" } )

	oModel:AddField( "HJ9_NATOPR" , "C", 32, 0 )
	oModel:AddField( "HJ9_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HJ9_DESC"   , "C", 40, 0 )		
	oModel:AddField( "HJ9_MERCAD" , "C", 30, 0 )		
	oModel:AddField( "HJ9_ATUSTA" , "C", 01, 0 )		
	oModel:AddField( "HJ9_DRAWBK" , "C", 01, 0 )		
	oModel:AddField( "HJ9_GERDUP" , "C", 01, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXNatOperacao
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "F4_CODIGO","F4_TEXTO","F4_DUPLIC" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "F4_CODIGO", (cFlow)->F4_CODIGO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJ9_NATOPR" , oKey:GetKey( { (cFlow)->F4_CODIGO } ) )		
		oRecord:SetValue( "HJ9_CODIGO", (cFlow)->F4_CODIGO )
		oRecord:SetValue( "HJ9_DESC", (cFlow)->F4_TEXTO )
		oRecord:SetValue( "HJ9_GERDUP", (cFlow)->F4_DUPLIC )
		oRecord:SetValue( "HJ9_MERCAD"  , " " )
		oRecord:SetValue( "HJ9_ATUSTA"  , " " )
		oRecord:SetValue( "HJ9_DRAWBK"  , " " )
		
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