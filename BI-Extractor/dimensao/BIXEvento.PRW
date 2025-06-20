#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEVENTO.CH"

REGISTER EXTRACTOR HJR 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEvento
Visualiza as informa��es por c�digo ou descri��o do evento da folha 
de pagamento. Evento representa as ocorr�ncias da folha de pagamento 
do colaborador, as vari�veis que envolvem todos os c�lculos 
(proventos e descontos) correspondentes aos funcion�rios e suas 
incid�ncias legais (INSS, FGTS, Imposto de Renda).

@author  BI TEAM
@since   10/08/2010
/*/
//-------------------------------------------------------------------
Class BIXEvento from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )  
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   10/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXEvento
	_Super:New( DIMENSION, "HJR", STR0001, "SRV" ) //"Evento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXEvento 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJR_EVENTO" )
	oModel:SetBK( { "HJR_CODIGO" } )

	oModel:AddField( "HJR_EVENTO" , "C", 32, 0 )
	oModel:AddField( "HJR_CODIGO" , "C", 40, 0 )		
	oModel:AddField( "HJR_DESC"   , "C", 80, 0 )		
	oModel:AddField( "HJR_INCIDE" , "C", 60, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXEvento
 	Local cFlow := ""
		
	cFlow := ::Flow( cFrom, cTo, { "RV_COD", "RV_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RV_COD", 	(cFlow)->RV_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJR_EVENTO" ,  oKey:GetKey( { (cFlow)->RV_COD } ) )		
		oRecord:SetValue( "HJR_CODIGO" , (cFlow)->RV_COD  )
		oRecord:SetValue( "HJR_DESC"   , (cFlow)->RV_DESC )
		oRecord:SetValue( "HJR_INCIDE" , ' ' )
		
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