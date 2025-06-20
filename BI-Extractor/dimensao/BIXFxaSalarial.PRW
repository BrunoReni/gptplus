#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFXASALARIAL.CH"

REGISTER EXTRACTOR HKG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFxaSalarial
Visualiza as informa��es pelas Faixas de Sal�rios dos colaboradores. 
Os colaboradores ser�o enquadrados dentro de uma determinada faixa.

@author  BI TEAM
@since   16/12/2010
/*/
//-------------------------------------------------------------------
Class BIXFxaSalarial from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXFxaSalarial
	_Super:New( DIMENSION, "HKG", STR0003) //"Faixa Salarial"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFxaSalarial 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKG_FXASAL" )
	oModel:SetBK( { "HKG_CODIGO" } )

	oModel:AddField( "HKG_FXASAL", "C", 32, 0 )
	oModel:AddField( "HKG_CODIGO", "C", 10, 0 )
	oModel:AddField( "HKG_DESC"  , "C", 40, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFxaSalarial
	Local aRange 			:= {} 	
	Local cRange			:= BIXParInfo( "FXSALA", "C", "" ) 	
	Local cLabel 			:= ""
	Local cMinimun		:= "" 
	Local cMaximun		:= ""
	Local nRange			:= 0

	//-------------------------------------------------------------------
	// Recupera as faixas dos par�metros.  
	//-------------------------------------------------------------------
	aRange := aBIToken( cRange, ";", .F. )

	//-------------------------------------------------------------------
	// Percorre as faixa de dados.
	//-------------------------------------------------------------------
	For nRange := 1 To Len( aRange ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
		
		cMinimun := AllTrim( Transform( nBIVal( aRange[nRange] ), "@E 999,999,999.99" ) )
		
		//-------------------------------------------------------------------
		// Monta a descri��o.  
		//-------------------------------------------------------------------			
		If ! ( nRange == Len( aRange ) ) 
			cMaximun 	:= AllTrim( Transform( nBIVal( aRange[nRange + 1] ), "@E 999,999,999.99" ) )
			cLabel 	:=  cMinimun + " " + STR0002 + " " + cMaximun 	//"Maior que"
		Else
			cLabel :=  STR0001 + " " + cMinimun //"at�"
		EndIf 

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HKG_FXASAL", oKey:GetKey( { cBIStr( nRange ) } ) )		
		oRecord:SetValue( "HKG_CODIGO", cBIStr( nRange ) )
		oRecord:SetValue( "HKG_DESC"  , cLabel )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nRange

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil