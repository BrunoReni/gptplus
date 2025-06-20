#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOEDA.CH"

REGISTER EXTRACTOR HJ6

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMoeda
As informa��es s�o visualizadas por nome ou s�mbolo da Moeda e dizemos
que moeda � uma unidade financeira utilizada quando se faz necess�ria 
a convers�o de valores.

@author  BI TEAM
@since   23/06/2010
/*/
//-------------------------------------------------------------------
Class BIXMoeda from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Valdiney V GOMES
@since   07/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXMoeda
	_Super:New( DIMENSION, "HJ6", STR0001 ) //"Moeda"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMoeda 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ6_MOEDA" )
	oModel:SetBK( { "HJ6_CODIGO" } )

	oModel:AddField( "HJ6_MOEDA"  , "C", 32, 0  )
	oModel:AddField( "HJ6_CODIGO" , "C", 10, 0  )
	oModel:AddField( "HJ6_NOME"   , "C", 40, 0  ) 
	
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

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMoeda
  	Local aMoeda  		:= {}
  	Local nMoeda  		:= 0
  	Local lConsolidate 	:= BIXParInfo( "BIX_CMOEDA", "L", .F. )  

  	aMoeda  := BIXLoadMoeda()
 	  	
  	For nMoeda := 1 To Len( aMoeda )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   		  
	   	oRecord:Init()
	   	
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
    	If ( lConsolidate )
	    	oRecord:SetValue( "HJ6_MOEDA"	, BIXCMValue( cBIStr( nMoeda ), 1 ) ) 
    	Else
	    	oRecord:SetValue( "HJ6_MOEDA"	, oKey:GetKey( { BIXCMValue( cBIStr( nMoeda ), 1 ) },.T., .F. ) ) 
    	EndIf
    	
    	oRecord:SetValue( "HJ6_CODIGO"	, BIXCMValue( cBIStr( nMoeda ), 1 ) )
	    oRecord:SetValue( "HJ6_NOME"	, BIXCMValue( cBIStr( nMoeda ), 2 ) )
	    
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 	    	
    Next nMoeda
    
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------
 	oOutput:Release()
Return nil 