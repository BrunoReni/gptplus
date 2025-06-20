#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTIPOPRODUCAO.CH"

REGISTER EXTRACTOR HQU

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTipoProducao
Visualiza as informa��es por Tipo de Produ��o. � uma classifica��o 
das informa��es de produ��o. Exemplos: Produ��o Interna, Produ��o 
Externa, Produ��o Ativo Fixo, Produ��o Manuten��o.

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Class BIXTipoProducao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Tamara Clemente
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXTipoProducao
	_Super:New( DIMENSION, "HQU", STR0003 ) //"Tipo de Produ��o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTipoProducao
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQU_TIPPRD" )
	oModel:SetBK( { "HQU_CODIGO" } )

	oModel:AddField( "HQU_TIPPRD" , "C", 32, 0 )
	oModel:AddField( "HQU_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQU_DESC"   , "C", 60, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTipoProducao
	Local aType 	:= {}  
	Local nCombo 	:= 1      
	Local aCombo	:= {}

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "C2_TPOP" ) ) )  
		aCombo := aBIToken( X3CBox(), ";" )
	
		For nCombo := 1 To Len( aCombo )
			aType := aBIToken( aCombo[nCombo], "=", .F. )
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HQU_TIPPRD", oKey:GetKey( { aType[1] },,.F.) )		
			oRecord:SetValue( "HQU_CODIGO", aType[1] )
			oRecord:SetValue( "HQU_DESC"  , aType[2] )
			
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