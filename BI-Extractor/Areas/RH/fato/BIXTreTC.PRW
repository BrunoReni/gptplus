#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTRETC.CH"

REGISTER EXTRACTOR HQV

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTreTC
Apresenta informações dos treinamentos realizados e em andamento, e 
das bolsas de estudo, em quantidades e valores por tipo de custo.

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXTreTC from BIXEntity
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
Method New() class BIXTreTC
	_Super:New( FACT, "HQV", STR0001, "", { RH } ) //"Treinamentos por Tipo de Custo"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTreTC 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HQV_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HQV_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HQV_FXASAL", "C", 32, 0, .T., "HKG" )
	oModel:AddField( "HQV_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HQV_CATSAL", "C", 32, 0, .T., "HJT" )
	oModel:AddField( "HQV_LOCALI", "C", 32, 0, .T., "HQO" )
	oModel:AddField( "HQV_SINDIC", "C", 32, 0, .T., "HJV" )
	oModel:AddField( "HQV_TURNO" , "C", 32, 0, .T., "HJU" )
	oModel:AddField( "HQV_TIPMOB", "C", 32, 0, .T., "HJQ" )
	oModel:AddField( "HQV_COLABR", "C", 32, 0, .T., "HJM" )
	oModel:AddField( "HQV_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HQV_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HQV_PLOTAC", "C", 32, 0, .T., "HQP" )
	oModel:AddField( "HQV_ULOTAC", "C", 32, 0, .T., "HQT" )
	oModel:AddField( "HQV_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HQV_INSTIT", "C", 32, 0, .T., "HJN" )
	oModel:AddField( "HQV_INSTRU", "C", 32, 0, .T., "HJO" )
	oModel:AddField( "HQV_CURSO" , "C", 32, 0, .T., "HJL" )
	oModel:AddField( "HQV_TIPCUR", "C", 32, 0, .T., "HG6" )
	oModel:AddField( "HQV_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HQV_ESTCIV", "C", 32, 0, .T., "HKE" )
	oModel:AddField( "HQV_FXAETA", "C", 32, 0, .T., "HK8" )
	oModel:AddField( "HQV_GRAINS", "C", 32, 0, .T., "HK9" )
	oModel:AddField( "HQV_NIVHIE", "C", 32, 0, .T., "HG5" )
	oModel:AddField( "HQV_RELTRB", "C", 32, 0, .T., "HKD" )
	oModel:AddField( "HQV_TPCASA", "C", 32, 0, .T., "HKH" )
	oModel:AddField( "HQV_TPCARG", "C", 32, 0, .T., "HKI" )
	oModel:AddField( "HQV_CARGO" , "C", 32, 0, .T., "HJP" )
	oModel:AddField( "HQV_SECAO" , "C", 32, 0, .T., "HQ0" )
	oModel:AddField( "HQV_BOLSA" , "C", 32, 0, .T., "HQA" )
	oModel:AddField( "HQV_TIPCST", "C", 32, 0, .T., "HQS" )
	oModel:AddField( "HQV_MOTTRE", "C", 32, 0, .T., "HQR" )
	oModel:AddField( "HQV_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HQV_STTREI", "C", 1, 0 )
	oModel:AddField( "HQV_VTREIN", "N", 16, 2 )	

	oModel:FreeField() 
Return oModel
