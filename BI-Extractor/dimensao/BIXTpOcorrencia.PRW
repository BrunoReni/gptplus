#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPOCORRENCIA.CH"

REGISTER EXTRACTOR HO8

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpOcorrencia
Visualiza as informa��es pela ocorr�ncia. Ocorr�ncias s�o os fatos 
ocorridos durante uma viagem. As ocorr�ncias representadas por esta 
dimens�o ser�o apenas ocorr�ncias que geraram pend�ncias ou indeniza��o 
durante a viagem.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpOcorrencia from BIXEntity
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
Method New() class BIXTpOcorrencia
	_Super:New( DIMENSION, "HO8", STR0001) //"Tipo de Ocorr�ncia"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpOcorrencia 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO8_TIPOCO" )
	oModel:SetBK( { "HO8_CODIGO" } )

	oModel:AddField( "HO8_TIPOCO", "C", 32, 0 )
	oModel:AddField( "HO8_CODIGO", "C", 10, 0 )
	oModel:AddField( "HO8_DESC"  , "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpOcorrencia
	Local aTipo := TMSValField( "TIPOCO", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    

	For nTipo := 1 To Len( aTipo )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO8_TIPOCO", oKey:GetKey( { aTipo[nTipo][1] },,.F.) )		
		oRecord:SetValue( "HO8_CODIGO", aTipo[nTipo][1] )
		oRecord:SetValue( "HO8_DESC"  , aTipo[nTipo][2] )

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