#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPDOCTRANSPORTE.CH"

REGISTER EXTRACTOR HO2

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpDocTransporte
Visualiza as informa��es pelo tipo do documento de transporte. O tipo de 
documento de transporte caracteriza os faturamentos extras a partir do 
tipo do documento que o gerou: Reentrega e/ou devolu��o.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpDocTransporte from BIXEntity
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
Method New() class BIXTpDocTransporte
	_Super:New( DIMENSION, "HO2", STR0001 ) //"Tipo de Documento de Transporte"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpDocTransporte
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO2_TIPDOC" )
	oModel:SetBK( { "HO2_CODIGO" } )

	oModel:AddField( "HO2_TIPDOC"	, "C", 32, 0 )
	oModel:AddField( "HO2_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HO2_DESC"   	, "C", 30, 0 )
	
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
@since   14/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpDocTransporte
	Local aTipo := TMSValField( "DOCTMS", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    

	For nTipo := 1 To Len( aTipo )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO2_TIPDOC", oKey:GetKey( { aTipo[nTipo][1] }, , .F. ) )		
		oRecord:SetValue( "HO2_CODIGO", aTipo[nTipo][1] )
		oRecord:SetValue( "HO2_DESC"  , aTipo[nTipo][2] )

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
