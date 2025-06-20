#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGRPCLIENTE.CH"

REGISTER EXTRACTOR HJ0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGrpCliente
As informa��es s�o visualizadas por c�digo ou descri��o do Grupo de 
Clientes, que � o agrupamento dos mesmos com caracter�sticas comuns.
Exemplo: Atacadista, Varejista, Consumidor Final.

@author  BI TEAM
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Class BIXGrpCliente from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da Classe.

@author  Tamara Clemente
@since   04/11/2016
/*/
//-------------------------------------------------------------------  
Method New() Class BIXGrpCliente
	_Super:New( DIMENSION, "HJ0", STR0001 ) //"Grupo de Clientes"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXGrpCliente 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ0_GRPCLI" )
	oModel:SetBK( { "HJ0_CODIGO" } )

	oModel:AddField( "HJ0_GRPCLI" , "C", 32, 0 )
	oModel:AddField( "HJ0_CODIGO" , "C", 11, 0 )
	oModel:AddField( "HJ0_DESC"   , "C", 40, 0 ) 

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) Class BIXGrpCliente
	Local aGroup := {}
	Local nGroup := 0	

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek("A1_TIPO" ) ) )
		aGroup := aBIToken( X3CBox(), ";" )
	
		For nGroup := 1 to Len( aGroup )	
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------	
	    	oRecord:SetValue( "HJ0_GRPCLI", oKey:GetKey( { aBIToken( aGroup[nGroup], "=", .F. )[1] },.T., .F. ) )
			oRecord:SetValue( "HJ0_CODIGO", aBIToken( aGroup[nGroup], "=", .F. )[1] )
			oRecord:SetValue( "HJ0_DESC"  , aBIToken( aGroup[nGroup], "=", .F. )[2] )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o da Fluig Smart Data. 
			//-------------------------------------------------------------------		
			oOutput:Send( oRecord ) 		
		Next nGroup
	EndIf
	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------
 	oOutput:Release()	
Return nil 