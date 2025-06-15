#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGGFPREVISTO.CH"

REGISTER EXTRACTOR HLT

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGGFPrevisto

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXGGFPrevisto from BIXEntity
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
Method New() class BIXGGFPrevisto
	_Super:New( FACT, "HLT", STR0001, "", { PRODUCAO } ) //"GGF - Previsto"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXGGFPrevisto 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLT_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLT_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLT_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLT_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLT_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLT_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLT_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLT_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLT_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLT_GRPMAQ", "C", 32, 0, .T., "HJY" )
	oModel:AddField( "HLT_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLT_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLT_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLT_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLT_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLT_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLT_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLT_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLT_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLT_DATA"  , "D", 8, 0, .F., "HK2" )		
	oModel:AddField( "HLT_PEDIDO", "C", 12, 0 )		
	oModel:AddField( "HLT_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLT_ORDEM" , "C", 13, 0 )		
	oModel:AddField( "HLT_QHRGFP", "N", 16, 4 )	
	oModel:AddField( "HLT_VCSGFP", "N", 16, 2 )	
		
	oModel:FreeField() 
Return oModel
