#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXNATFINANCEIRA.CH"

REGISTER EXTRACTOR HYE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXNatFinanceira
Visualiza as informa��es hierarquizadas da natureza do fluxo de caixa.

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Class BIXNatFinanceira from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXNatFinanceira
	_Super:New( DIMENSION, "HYE", STR0003, "SED" ) //"Natureza Financeira"
Return Self   
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   22/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXNatFinanceira 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYE_NATFIN" )
	oModel:SetBK( { "HYE_CODIGO" } )

	oModel:AddUnifier( { "ED_CODIGO" }, STR0003 ) //"Natureza Financeira"

	oModel:AddField( "HYE_NATFIN"   , "C", 32, 0 )
	oModel:AddField( "HYE_CODIGO"   , "C", 40, 0 )
	oModel:AddField( "HYE_DESC"     , "C", 100, 0 )
	oModel:AddField( "HYE_NATPAI"   , "C", 32, 0, .T. )
	oModel:AddField( "HYE_CODPAI"   , "C", 40, 0 )

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
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXNatFinanceira
	Local aNatPai 	:= {}
	Local cNatPai 	:= ""
 	Local cFlow 	:= ""

	cFlow := ::Flow( cFrom, cTo, { "ED_CODIGO", "ED_DESCRIC", "ED_PAI", "ED_TIPO" } )	
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "ED_CODIGO", 	(cFlow)->ED_CODIGO )

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio.
		//-------------------------------------------------------------------
		oRecord:SetValue( "HYE_NATFIN", oKey:GetKey( { (cFlow)->ED_CODIGO } ) )
		oRecord:SetValue( "HYE_CODIGO", (cFlow)->ED_CODIGO )
		oRecord:SetValue( "HYE_DESC"  , (cFlow)->ED_DESCRIC )

		//-------------------------------------------------------------------
		// Armazena a natureza superior.
		//-------------------------------------------------------------------
		cNatPai := (cFlow)->ED_PAI
		
		//-------------------------------------------------------------------
		// Posiciona o registro e verifica se a natureza � sint�tica
		//-------------------------------------------------------------------
		SED->( DBSetOrder(1) )
		
		If ( SED->( DBSeek(xFilial("SED") + cNatPai ) ) .And. SED->ED_TIPO == "1" )
			oRecord:SetValue( "HYE_CODPAI", cNatPai )
			oRecord:SetValue( "HYE_NATPAI", oKey:GetKey( { cNatPai },,,,.F. ) )
		Else
			oRecord:SetValue( "HYE_NATPAI", oKey:GetKey( { UNDEFINED },,,,.F. ) )
			oRecord:SetValue( "HYE_CODPAI", UNDEFINED )
			
			If ! ( Empty( cNatPai ) )
				If ( aScan( aNatPai, {|x| Alltrim( x ) == Alltrim( cNatPai ) } ) == 0 )
					Aadd( aNatPai, Alltrim( cNatPai ) )
				EndIf
			EndIf			
		EndIf

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

	If ! ( Empty( aNatPai ) )
		BIXSetLog( LOG_RUNNING, "HYE",,,,, CHR(9) + STR0001 + BIXConcatWSep( ",", aNatPai )  + STR0002 ) //Natureza Financeira [###] identificada(s) como superior na hierarquia natureza financeira n�o s�o sint�ticas.
	EndIf
return nil