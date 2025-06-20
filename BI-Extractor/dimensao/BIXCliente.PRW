#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCLIENTE.CH"

REGISTER EXTRACTOR HJ7

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCliente
As informa��es s�o visualizadas por c�digo ou nome do Cliente. 

@author  BI TEAM
@since   23/06/2010
/*/
//-------------------------------------------------------------------
Class BIXCliente from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXCliente
	_Super:New( DIMENSION, "HJ7", STR0001, "SA1", /*aApp*/, /*lShare*/, .T. ) //"Cliente"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCliente 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ7_CLIENT" )
	oModel:SetBK( { "HJ7_CODIGO", "HJ7_LOJA" } )

	oModel:AddUnifier( { "A1_COD" }, STR0002 ) //"C�digo do cliente"
	oModel:AddUnifier( { "A1_CGC" }, STR0003 ) //"CPF do cliente"

	oModel:AddField( "HJ7_CLIENT" , "C", 32, 0 )
	oModel:AddField( "HJ7_CODIGO" , "C", 25, 0 )
	oModel:AddField( "HJ7_LOJA"   , "C", 02, 0 )
	oModel:AddField( "HJ7_CLIEMT" , "C", 25, 0 )
	oModel:AddField( "HJ7_NOME"   , "C", 60, 0 )
	oModel:AddField( "HJ7_MATRIZ" , "C", 60, 0 )
	oModel:AddField( "HJ7_RAMO"   , "C", 30, 0 )
	oModel:AddField( "HJ7_MATCLI" , "C", 32, 0, .T. )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCliente
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "A1_COD", "A1_LOJA", "A1_CGC", "A1_NOME", "A1_SATIV1" } )

 	While ! (cFlow)->( Eof() )
 		If oRecord:ChkModify( (cFlow)->USERLGI, (cFlow)->USERLGA )  
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 		
			oRecord:Init()
	
			//-------------------------------------------------------------------
			// Alimenta os campos de customiza��o. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "A1_COD"		, (cFlow)->A1_COD )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->A1_LOJA )
			oRecord:SetValue( "A1_CGC"		, (cFlow)->A1_CGC )
			
			//-------------------------------------------------------------------
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HJ7_CLIENT"	, oKey:GetKey( { (cFlow)->A1_COD, (cFlow)->A1_LOJA } ) )
			oRecord:SetValue( "HJ7_CODIGO"	, (cFlow)->A1_COD )
			oRecord:SetValue( "HJ7_LOJA"	, (cFlow)->A1_LOJA )
			oRecord:SetValue( "HJ7_NOME"	, (cFlow)->A1_NOME )
			oRecord:SetValue( "HJ7_RAMO"	, (cFlow)->A1_SATIV1 )
			oRecord:SetValue( "HJ7_MATCLI"	, oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HJ7_MATRIZ"	, STR0004 ) //"INDEFINIDO"
			oRecord:SetValue( "HJ7_CLIEMT"	, UNDEFINED )
	
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o da Fluig Smart Data. 
			//-------------------------------------------------------------------	
			oOutput:Send( oRecord ) 
		EndIf
		
 		(cFlow)->( DBSkip() ) 
 	EndDo  
 	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil 