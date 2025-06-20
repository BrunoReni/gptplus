#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOTIVOAFASTAMENTO.CH"

REGISTER EXTRACTOR HJS

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMotivoAfastamento
Visualiza as informa��es por c�digo ou descri��o do motivo de 
movimenta��o. Representa os motivos dos desligamentos, contrata��es, 
afastamentos, aumentos salariais e transfer�ncias de colaboradores na 
empresa.

@author  BI TEAM
@since   09/08/2010
/*/
//-------------------------------------------------------------------
Class BIXMotivoAfastamento from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   09/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXMotivoAfastamento
	_Super:New( DIMENSION, "HJS", STR0001, "SX5" ) //"Motivo de Afastamento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMotivoAfastamento 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJS_MOTMOV" )
	oModel:SetBK( { "HJS_CODIGO" } )

	oModel:AddField( "HJS_MOTMOV" , "C", 32, 0 )
	oModel:AddField( "HJS_CODIGO" , "C", 60, 0 )		
	oModel:AddField( "HJS_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMotivoAfastamento
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "30" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJS_MOTMOV", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HJS_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HJS_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	Next

	//-------------------------------------------------------------------
	// Muda tabela de origem em tempo de execu��o.
	//-------------------------------------------------------------------		
	::SetTable( "SRX" )
	cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "RX_COD", "RX_TXT" }, { { "RX_TIP", "=", "32" } } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	(cFlow)->RX_COD )
		oRecord:SetValue( "X5_TABELA", 	'32' )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJS_MOTMOV", oKey:GetKey( { (cFlow)->RX_COD } ) )		
		oRecord:SetValue( "HJS_CODIGO", (cFlow)->RX_COD )
		oRecord:SetValue( "HJS_DESC"  , (cFlow)->RX_TXT )
		
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

	FWFreeArray( aContent )
Return nil