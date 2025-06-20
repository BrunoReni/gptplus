#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUNORGANIZACIONAL.CH"

REGISTER EXTRACTOR HQ8

//--------------------------------------------------------------------
/*/{Protheus.doc} BIXUnOrganizacional
Visualiza as informa��es por Unidade Organizacional. 
Este conceito trata a forma de organizar um grupo empresarial, que 
pode ser feito, por exemplo, por divis�o, grupo, empresa, estabelecimento.

@author  BI TEAM
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Class BIXUnOrganizacional from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Helio Leal
@since   10/04/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXUnOrganizacional
	_Super:New( DIMENSION, "HQ8", STR0001 )	//"Unidade Organizacional"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   10/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXUnOrganizacional 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQ8_UNIORG" )
	oModel:SetBK( { "HQ8_CODIGO" } )

	oModel:AddField("HQ8_UNIORG" , "C",  32, 0 )
	oModel:AddField("HQ8_CODIGO" , "C",  10, 0 )
	oModel:AddField("HQ8_DESC" 	 , "C",  40, 0 )

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

@author  Helio Leal
@since   10/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUnOrganizacional
 	Local cCompany		:= ""

	cCompany  := FWGrpCompany( )
	
	If ! ( Empty( cCompany ) )	
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------			
		oRecord:SetValue( "HQ8_UNIORG"	, oKey:GetKey( { cCompany }, .T., .F., .F. ) )
		oRecord:SetValue( "HQ8_CODIGO"	, cCompany )
		oRecord:SetValue( "HQ8_DESC"	, FWGrpName( ) )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------			
		oOutput:Send( oRecord ) 
		
	 	//-------------------------------------------------------------------
		// Libera o pool de grava��o. 
		//-------------------------------------------------------------------		
	 	oOutput:Release() 
 	EndIf
Return Nil