#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREPRESENTANTE.CH"                                                                                                                                                                                                                                           

REGISTER EXTRACTOR HJC

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRepresentante
Visualiza as informa��es por c�digo ou nome do Representante da empresa. 
Representante � a identifica��o de pessoa f�sica ou jur�dica que 
representa comercialmente determinada empresa em uma regi�o geogr�fica. 
Normalmente o representante comercializa a mercadoria ou servi�o de 
determinada empresa em troca de um percentual de comiss�o do valor 
negociado.

@author  BI TEAM
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Class BIXRepresentante from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.  

@author  Helio Leal
@since   07/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXRepresentante
	_Super:New( DIMENSION, "HJC", STR0001, "SA3" ) //"Representante"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRepresentante 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJC_REPRES" )
	oModel:SetBK( { "HJC_CODIGO" } )

	oModel:AddUnifier( { "A3_COD" }, STR0002 ) //"C�digo do representante"
	oModel:AddUnifier( { "A3_CGC" }, STR0003 ) //"CPF do representante"

	oModel:AddField( "HJC_REPRES" , "C", 32, 0 )
	oModel:AddField( "HJC_CODIGO" , "C", 15, 0 )
	oModel:AddField( "HJC_NOME"   , "C", 40, 0 ) 
	
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
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRepresentante
 	Local cFlow  := ""

	cFlow := ::Flow( cFrom, cTo, { "A3_COD", "A3_NOME", "A3_CGC" } )

 	While ! ( (cFlow)->( Eof() ) )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "A3_COD"		, (cFlow)->A3_COD )
		oRecord:SetValue( "A3_CGC"		, (cFlow)->A3_CGC )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------		
		oRecord:SetValue( "HJC_REPRES"	, oKey:GetKey( { (cFlow)->A3_COD } ) )	
		oRecord:SetValue( "HJC_CODIGO"	, (cFlow)->A3_COD )
		oRecord:SetValue( "HJC_NOME"	, (cFlow)->A3_NOME )
		
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