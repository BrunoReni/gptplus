#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGGFREALIZADO.CH"

REGISTER EXTRACTOR HKY

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGGFRealizado

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXGGFRealizado from BIXEntity
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
Method New() class BIXGGFRealizado
	_Super:New( FACT, "HKY", STR0001, "", { PRODUCAO } ) //"GGF - Realizado"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXGGFRealizado 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKY_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKY_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKY_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKY_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKY_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKY_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKY_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HKY_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HKY_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HKY_GRPMAQ", "C", 32, 0, .T., "HJY" )
	oModel:AddField( "HKY_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKY_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HKY_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKY_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKY_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HKY_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HKY_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HKY_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKY_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKY_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKY_PEDIDO", "C", 12, 0 )
	oModel:AddField( "HKY_SEQCIA", "C", 10, 0 )
	oModel:AddField( "HKY_ORDEM" , "C", 13, 0 )
	oModel:AddField( "HKY_QHRGGF", "N", 16, 4 )
	oModel:AddField( "HKY_VCSGGF", "N", 16,	2 )

	oModel:FreeField() 
Return oModel
