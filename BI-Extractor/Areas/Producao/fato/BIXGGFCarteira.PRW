#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGGFCARTEIRA.CH"

REGISTER EXTRACTOR HLW

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGGFCarteira

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXGGFCarteira from BIXEntity
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
Method New() class BIXGGFCarteira
	_Super:New( FACT, "HLW", STR0001, "", { PRODUCAO } ) //"GGF - Carteira"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXGGFCarteira 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLW_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLW_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLW_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLW_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLW_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLW_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLW_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLW_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLW_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLW_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLW_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLW_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLW_GRPMAQ", "C", 32, 0, .T., "HJY" )
	oModel:AddField( "HLW_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLW_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLW_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLW_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLW_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLW_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLW_DTEXTR", "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HLW_DTEMIS", "D", 8, 0 )		
	oModel:AddField( "HLW_DTTERM", "D", 8, 0 )		
	oModel:AddField( "HLW_PEDIDO", "C", 12, 0 )		
	oModel:AddField( "HLW_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLW_ORDEM" , "C", 13, 0 )
	oModel:AddField( "HLW_QHRGFC", "N", 16,	4 )	
	oModel:AddField( "HLW_VCSGFC", "N", 16,	2 )	

	oModel:FreeField() 
Return oModel
