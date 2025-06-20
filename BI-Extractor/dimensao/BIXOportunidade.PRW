#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXOPORTUNIDADE.CH"

REGISTER EXTRACTOR HSM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOportunidade
Visualiza as informa��es por c�digo ou descri��o da oportunidade de 
venda. A oportunidade de venda � destinada ao acompanhamento de uma 
venda potencial, visando a gera��o de receita e que precisa ser 
monitorada atrav�s de um processo de venda at� sua conclus�o.

@author  Helio Leal
@since   30/05/2017
/*/
//-------------------------------------------------------------------
Class BIXOportunidade from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )    
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Helio Leal
@since   30/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXOportunidade
	_Super:New( DIMENSION, "HSM", STR0001, "AD1" ) // Oportunidade de venda
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   30/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXOportunidade 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSM_OPOVEN" )
	oModel:SetBK( { "HSM_CODIGO" } )

	oModel:AddField( "HSM_OPOVEN" , "C", 32, 0 )
	oModel:AddField( "HSM_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HSM_DESC"   , "C", 30, 0 )
	oModel:AddField( "HSM_REVISA" , "C", 03, 0 )

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
@since   30/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXOportunidade
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "AD1_NROPOR", "AD1_DESCRI", "AD1_REVISA" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "AD1_NROPOR", 	(cFlow)->AD1_NROPOR )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSM_OPOVEN", oKey:GetKey( { (cFlow)->AD1_NROPOR } ) )		
		oRecord:SetValue( "HSM_CODIGO", (cFlow)->AD1_NROPOR )
		oRecord:SetValue( "HSM_DESC"  , (cFlow)->AD1_DESCRI )
		oRecord:SetValue( "HSM_REVISA", (cFlow)->AD1_REVISA )

		
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
Return Nil