#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDEPOSITO.CH"

REGISTER EXTRACTOR HJD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDeposito
Visualiza as informa��es por c�digo ou descri��o do dep�sito. 
Dep�sito � o local f�sico onde s�o armazenados itens diversos 
(mat�rias-primas, componentes, produtos acabados).

@author  BI TEAM
@since   06/08/2010
/*/
//-------------------------------------------------------------------
Class BIXDeposito from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Helio Leal
@version P12 
@since   02/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXDeposito
	_Super:New( DIMENSION, "HJD", STR0001, "SB2" ) //"Dep�sito"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXDeposito 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJD_DEPOSI" )
	oModel:SetBK( { "HJD_CODIGO" } )

	oModel:AddField( "HJD_DEPOSI" , "C", 32, 0 )
	oModel:AddField( "HJD_CODIGO" , "C", 15, 0 )		
	oModel:AddField( "HJD_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXDeposito
 	Local cFlow := ""
	Local cDescri := ""
	Local cIdioma := FWRetIdiom()
	Local aArmazen := {}
	
	If cIdioma == "es"
		cDescri := GetSx3Cache("B2_LOCAL","X3_TITSPA")
	Else
		If cIdioma == "en"
			cDescri := GetSx3Cache("B2_LOCAL","X3_TITENG")
		Else
			cDescri := GetSx3Cache("B2_LOCAL","X3_TITULO")
		EndIf
	EndIf

 	cDescri := alltrim(cDescri) + " "
	
	cFlow := ::Flow( cFrom, cTo, { "B2_LOCAL" } )

 	While ! ( (cFlow)->( Eof() ) ) 
 		If !Empty( (cFlow)->B2_LOCAL) .and. aScan(aArmazen,{|x| x == (cFlow)->B2_LOCAL }) == 0		
			aAdd(aArmazen, (cFlow)->B2_LOCAL)
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()
		
			//-------------------------------------------------------------------
			// Alimenta os campos para customiza��o e consolida��o. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "B2_COD", 	' ' )
			oRecord:SetValue( "B2_LOCAL", 	(cFlow)->B2_LOCAL )			
			//-------------------------------------------------------------------
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HJD_DEPOSI" , oKey:GetKey( { (cFlow)->B2_LOCAL, } ) )		
			oRecord:SetValue( "HJD_CODIGO" , (cFlow)->B2_LOCAL )
			oRecord:SetValue( "HJD_DESC"   , cDescri + (cFlow)->B2_LOCAL )
			
			//--------------------------------------------------------------------
			// Envia o registro para o pool de grava��o da Fluig Smart Data. 
			//--------------------------------------------------------------------		
			oOutput:Send( oRecord )
		EndIf
		(cFlow)->( DBSkip() )  
	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil
