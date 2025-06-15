#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEXPLEADTIME.CH"

REGISTER EXTRACTOR HQ4 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXExpLeadTime

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXExpLeadTime from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXExpLeadTime
	_Super:New( FACT, "HQ4", STR0001, "", { COMERCIAL } ) //"Exportação - Lead Time"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXExpLeadTime 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HQ4_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HQ4_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HQ4_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HQ4_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HQ4_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HQ4_TRCHCT", "C", 32, 0, .T., "HGT" )
	oModel:AddField( "HQ4_SITEXP", "C", 32, 0, .T., "HGJ" )
	oModel:AddField( "HQ4_FORNTI", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQ4_FORNAC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQ4_FORNDP", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQ4_FORNSG", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQ4_INCOTR", "C", 32, 0, .T., "HGM" )
	oModel:AddField( "HQ4_NATEXP", "C", 32, 0, .T., "HGP" )
	oModel:AddField( "HQ4_ITINER", "C", 32, 0, .T., "HGQ" )
	oModel:AddField( "HQ4_VIATRA", "C", 32, 0, .T., "HGR" )
	oModel:AddField( "HQ4_DATA"  , "D", 8, 0, .F., "HK2" )		
	oModel:AddField( "HQ4_DTEMBA", "D", 8, 0 )
	oModel:AddField( "HQ4_DTPRIN", "D", 8, 0 )
	oModel:AddField( "HQ4_DTPRFI", "D", 8, 0 )
	oModel:AddField( "HQ4_DTUPIN", "D", 8, 0 )
	oModel:AddField( "HQ4_DTUPFI", "D", 8, 0 )
	oModel:AddField( "HQ4_DTEFIN", "D", 8, 0 )
	oModel:AddField( "HQ4_DTEFFI", "D", 8, 0 )
	oModel:AddField( "HQ4_NPREXP", "C", 20, 0 )		
	oModel:AddField( "HQ4_QLTPRV", "N", 16, 4 )	
	oModel:AddField( "HQ4_QLTUPV", "N", 16, 4 )	
	oModel:AddField( "HQ4_QLDEFT", "N", 16, 4 )

	oModel:FreeField() 
Return oModel 
