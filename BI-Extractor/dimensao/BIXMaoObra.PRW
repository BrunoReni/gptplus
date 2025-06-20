#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMAOOBRA.CH"

REGISTER EXTRACTOR HJQ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMaoObra
Visualiza as informa��es pela descri��o do tipo de M�o de Obra, ao 
qual cada colaborador est� associado. Exemplo: Direta, Indireta.

@author  BI TEAM
@since   01/09/2010
/*/
//-------------------------------------------------------------------
Class BIXMaoObra from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Valdiney V GOMES
@since   04/01/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXMaoObra
	_Super:New( DIMENSION, "HJQ", STR0001 ) //"M�o de Obra"
Return Self  
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMaoObra 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJQ_TIPMOB" )
	oModel:SetBK( { "HJQ_CODIGO" } )

	oModel:AddField( "HJQ_TIPMOB" , "C", 32, 0 )
	oModel:AddField( "HJQ_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HJQ_DESC"   , "C", 20, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMaoObra
	Local aLabor := {}
	Local nLabor   := 1	
	       

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "RJ_MAOBRA" ) ) )  
		aLabor  := aBIToken( X3CBox(), ";" )
	
		For nLabor  := 1 To Len( aLabor  )
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()

			//-------------------------------------------------------------------
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HJQ_TIPMOB", oKey:GetKey( { aBIToken( aLabor[nLabor], "=", .F. )[1] },,.F.) )
			oRecord:SetValue( "HJQ_CODIGO", aBIToken( aLabor[nLabor], "=", .F. )[1] )
			oRecord:SetValue( "HJQ_DESC"  , aBIToken( aLabor[nLabor], "=", .F. )[2] )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o da Fluig Smart Data. 
			//-------------------------------------------------------------------		
			oOutput:Send( oRecord ) 
		Next

		//-------------------------------------------------------------------
		// Libera o pool de grava��o. 
		//-------------------------------------------------------------------	
		oOutput:Release()
	EndIf	
Return nil