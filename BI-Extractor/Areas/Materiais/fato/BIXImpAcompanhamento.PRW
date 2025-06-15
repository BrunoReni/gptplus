#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXImpAcompanhamento.CH"

REGISTER EXTRACTOR HQK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXImpAcompanhamento

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXImpAcompanhamento from BIXEntity
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
Method New() class BIXImpAcompanhamento
	_Super:New( FACT, "HQK", STR0001, "", { MATERIAIS } ) // "Importação - Acompanhamento" 
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXImpAcompanhamento 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HQK_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HQK_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HQK_FORNEC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQK_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HQK_NATOPR", "C", 32, 0, .T., "HJ9" )
	oModel:AddField( "HQK_CFOP"  , "C", 32, 0, .T., "HG0" )
	oModel:AddField( "HQK_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HQK_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HQK_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HQK_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HQK_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HQK_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HQK_CMPRDR", "C", 32, 0, .T., "HJZ" )
	oModel:AddField( "HQK_CONDPG", "C", 32, 0, .T., "HJA" )
	oModel:AddField( "HQK_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HQK_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HQK_TRANSP", "C", 32, 0, .T., "HJ2" )
	oModel:AddField( "HQK_BCO"   , "C", 32, 0, .T., "HGK" )
	oModel:AddField( "HQK_FORNDP", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQK_FORNDX", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQK_FORNFB", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQK_INCOTR", "C", 32, 0, .T., "HGM" )
	oModel:AddField( "HQK_PAIS"  , "C", 32, 0, .T., "HQL" )
	oModel:AddField( "HQK_SITIMP", "C", 32, 0, .T., "HQM" )
	oModel:AddField( "HQK_VIATRA", "C", 32, 0, .T., "HGR" )
	oModel:AddField( "HQK_ITINER", "C", 32, 0, .T., "HGQ" )
	oModel:AddField( "HQK_FORNAC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQK_FORNSG", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQK_FORNCS", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQK_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HQK_PTOCTR", "C", 32, 0, .T., "HGS" )
	oModel:AddField( "HQK_TIPEVE", "C", 32, 0, .T., "HQN" )
	oModel:AddField( "HQK_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HQK_DATA"  , "D", 8, 0, .F., "HK2" )	
	oModel:AddField( "HQK_DATADI", "D", 8, 0 )		
	oModel:AddField( "HQK_DTPEDC", "D", 8, 0 )		
	oModel:AddField( "HQK_DTPPTC", "D", 8, 0 )		
	oModel:AddField( "HQK_DTULPV", "D", 8, 0 )		
	oModel:AddField( "HQK_SERDOC", "C", 8, 0 )			
	oModel:AddField( "HQK_NUMDOC", "C", 35, 0 )			
	oModel:AddField( "HQK_NUMEMB", "C", 12, 0 )			
	oModel:AddField( "HQK_NPRIMP", "C", 12, 0 )			
	oModel:AddField( "HQK_ORDEM" , "C", 10, 0 )			
	oModel:AddField( "HQK_PEDIDO", "C", 10, 0 )			
	oModel:AddField( "HQK_EMERG" , "C", 1, 0 )			
	oModel:AddField( "HQK_CEMBHO", "C", 25, 0 )			
	oModel:AddField( "HQK_CEMBMA", "C", 25, 0 )			
	oModel:AddField( "HQK_NUMFAT", "C", 35, 0 )			
	oModel:AddField( "HQK_DECIMP", "C", 20, 0 )			
	oModel:AddField( "HQK_EMBENC", "C", 1, 0 )			
	oModel:AddField( "HQK_UNFORN", "C", 15, 0 )			
	oModel:AddField( "HQK_NLCIMP", "C", 20, 0 )			
	oModel:AddField( "HQK_NCRTCR", "C", 20, 0 )			
	oModel:AddField( "HQK_NATODB", "C", 20, 0 )			
	oModel:AddField( "HQK_VETRAN", "C", 20, 0 )			
	oModel:AddField( "HQK_DTEPTC", "C", 8, 0 )			
	oModel:AddField( "HQK_SEQINF", "N", 4, 0 )			
	oModel:AddField( "HQK_PARCEL", "N", 4, 0 )			
	oModel:AddField( "HQK_NMADIT", "N", 4, 0 )			
	oModel:AddField( "HQK_SQADIT", "N", 4, 0 )			
	oModel:AddField( "HQK_SEQPTO", "N", 4, 0 )			
	oModel:AddField( "HQK_QPTOCT", "N", 4, 0 )			
		
	oModel:FreeField() 
Return oModel
