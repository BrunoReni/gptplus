#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUNMEDITEM.CH"

REGISTER EXTRACTOR HHW

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXUnMedItem
Visualiza as informa��es pela Unidade de Medida do Item. 
� a unidade de medida padr�o adotada pela empresa para quantificar o 
item. Permite uma vis�o unificada de Unidades de medida de Itens.

@author  BI TEAM
@since   25/10/2013
/*/
//-------------------------------------------------------------------
Class BIXUnMedItem from BIXEntity
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
Method New() class BIXUnMedItem
	_Super:New( DIMENSION, "HHW", STR0001, "SAH" ) //"Unidade de Medida do Item"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXUnMedItem 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HHW_UNITEM" )
	oModel:SetBK( { "HHW_CODIGO" } )
	
	oModel:AddUnifier( { "AH_UNIMED" }, STR0001 ) //"Unidade de Medida do Item"

	oModel:AddField( "HHW_UNITEM"	, "C", 32, 0 )
	oModel:AddField( "HHW_CODIGO" 	, "C", 05, 0 )
	oModel:AddField( "HHW_DESC"   	, "C", 40, 0 )
	oModel:AddField( "HHW_DESCAB" 	, "C", 09, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUnMedItem
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "AH_UNIMED", "AH_UMRES", BIXSAHTitle()} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "AH_UNIMED"		, (cFlow)->AH_UNIMED )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HHW_UNITEM"	, oKey:GetKey( { (cFlow)->AH_UNIMED } ) )
		oRecord:SetValue( "HHW_CODIGO"	, (cFlow)->AH_UNIMED )
		oRecord:SetValue( "HHW_DESCAB"	, (cFlow)->AH_UMRES )
		oRecord:SetValue( "HHW_DESC"	, (cFlow)->AH_DESCPO)

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

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSAHTitle
Retorna o campo de descri��o do SAH, para ser utilizad de acordo com o pais.

@return cField, Campo de descri��o do SAH. 

@author  Tamara Clemente
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Static Function BIXSAHTitle( )
	Local cField := "" 
	Local cLang := FWRetIdiom()

	If cLang == "es"
		cField := "AH_DESCES AH_DESCPO"
	Else
		If cLang == "en"
			cField := "AH_DESCIN AH_DESCPO"
		Else
	   		cField := "AH_DESCPO"
		EndIf
	EndIf
Return cField
