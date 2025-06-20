#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITATENDENTE.CH" 

REGISTER EXTRACTOR HOM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitAtendente
Visualiza as informa��es pelo c�digo e descri��o da situa��o do atendente.
Situa��o do atendente � a classifica��o do atendente quanto a sua agenda.
Exemplo: Alocado, Ocioso, etc.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXSitAtendente from BIXEntity
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
Method New() class BIXSitAtendente
	_Super:New( DIMENSION, "HOM", STR0004 ) //"Situa��o do Atendente"
Return Self   
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSitAtendente 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOM_SITATE" )
	oModel:SetBK( { "HOM_CODIGO" } )

	oModel:AddField( "HOM_SITATE" , "C", 32, 0 )
	oModel:AddField( "HOM_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HOM_DESC"   , "C", 15, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSitAtendente
	Local aSituacao 	:= {} 
	Local nSituacao		:= 1 
	
	aAdd( aSituacao, {"01", STR0001 } ) //"Alocado"  
	aAdd( aSituacao, {"02", STR0002 } ) //"Ocioso"
	aAdd( aSituacao, {"03", STR0003 } ) //"Folga"

	For nSituacao := 1 To Len( aSituacao )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOM_SITATE", oKey:GetKey( { aSituacao[nSituacao][1] },,.F.) )		
		oRecord:SetValue( "HOM_CODIGO", aSituacao[nSituacao][1] )
		oRecord:SetValue( "HOM_DESC"  , aSituacao[nSituacao][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil