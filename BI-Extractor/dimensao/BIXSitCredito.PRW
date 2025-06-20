#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITCREDITO.CH"

REGISTER EXTRACTOR HK1

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitCredito
Visualiza as informa��es por Situa��o de Cr�dito do cliente para as 
vendas que est�o em aberto. Exemplos: Vendas Aprovadas, Vendas Reprovadas, 
Vendas Avaliadas.

@author  BI TEAM
@since   04/02/2011
/*/
//-------------------------------------------------------------------
Class BIXSitCredito from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.  

@author  Helio Leal
@since   18/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXSitCredito
	_Super:New( DIMENSION, "HK1", STR0006 ) // "Situa��o de Cr�dito"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@version P12 
@since   04/11/2016
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSitCredito 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HK1_STCRED" )
	oModel:SetBK( { "HK1_CODIGO" } )

	oModel:AddField( "HK1_STCRED" , "C", 32, 0 )
	oModel:AddField( "HK1_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HK1_DESC"   , "C", 30, 0 ) 

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
@version P12 
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSitCredito
 	Local aSituation 	:= {}
	Local nSituation 	:= 0

 	AAdd( aSituation, { "0", "INDEFINIDO" } ) //"INDEFINIDO" 
  	AAdd( aSituation, { "1", STR0001 } ) //"N�o Avaliado"
   	AAdd( aSituation, { "2", STR0002 } ) //"Avaliado" 
	AAdd( aSituation, { "3", STR0003 } ) //"Aprovado" 
	AAdd( aSituation, { "4", STR0004 } ) //"N�o Aprovado"
	AAdd( aSituation, { "5", STR0005 } ) // Pendente Informa��o" 

	For nSituation := 1 to len( aSituation )
		oRecord:Init()
	
		oRecord:SetValue( "HK1_STCRED", oKey:GetKey( { aSituation[nSituation][1] } , , .F. ))
		oRecord:SetValue( "HK1_CODIGO", aSituation[nSituation][1] )
		oRecord:SetValue( "HK1_DESC", 	aSituation[nSituation][2] )
	
		oOutput:Send( oRecord ) 
	Next nSituation

 	oOutput:Release()
Return nil