#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFORMAPGTO.CH"

REGISTER EXTRACTOR HS9

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFormaPgto
Visualiza as informa��es por c�digo e descri��o da forma de pagamento. 
A forma de pagamento � o meio oferecido ao cliente para que efetue o 
pagamento de suas compras. Exemplo: Cart�o de Cr�dito, Dinheiro, etc.

@author  Valdiney V GOMES
@version P12 
@since   10/04/2014
/*/
//-------------------------------------------------------------------
Class BIXFormaPgto from BIXEntity
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
Method New() class BIXFormaPgto
	_Super:New( DIMENSION, "HS9", STR0010) // "Forma de Pagamento" 
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFormaPgto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HS9_FORPAG" )
	oModel:SetBK( { "HS9_CODIGO" } )

	oModel:AddField( "HS9_FORPAG", "C", 32, 0 )
	oModel:AddField( "HS9_CODIGO", "C", 10, 0 )
	oModel:AddField( "HS9_DESC"  , "C", 20, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFormaPgto
	Local aForma 	:= {}
	Local nForma	:= 1  
	
	aAdd( aForma, {"CC", STR0001} ) //"Cart�o de Cr�dito"				    
	aAdd( aForma, {"VA", STR0002} )	//"Vales"
	aAdd( aForma, {"CO", STR0003} ) //"Conv�nio"	
	aAdd( aForma, {"FI", STR0004} ) //"Financiado"	
	aAdd( aForma, {"CD", STR0005} ) //"Cart�o de D�bito"
	aAdd( aForma, {"CH", STR0006} ) //"Cheque"	
	aAdd( aForma, {"CR", STR0007} ) //"Cr�dito"	
	aAdd( aForma, {"R$", STR0008} ) //"Dinheiro"		
	aAdd( aForma, {"FID", STR0009} ) //"Cart�o Fidelidade"	
			
	For nForma := 1 To Len( aForma )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HS9_FORPAG", oKey:GetKey( { aForma[nForma][1] }, , .F. ) )		
		oRecord:SetValue( "HS9_CODIGO", aForma[nForma][1] )
		oRecord:SetValue( "HS9_DESC"  , aForma[nForma][2] )

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