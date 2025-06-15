#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMENSALESTOQUE.CH"

REGISTER EXTRACTOR HKR

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMensalEstoque
Classe do extrator para a tabela fato Estoque Mensal do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   25/10/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXMensalEstoque from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   24/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXMensalEstoque
	_Super:New( FACT, "HKR", STR0001, "SB2", { MATERIAIS } ) // "Estoque Mensal" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   24/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXMensalEstoque
	Local oModel := BIXModel():Build( Self )

	//-------------------------------------------------------------------
	// Converte o período de extração informado para o primeio dia do mês 
	// da data inicial até o último dia do mês da data final. 
	//-------------------------------------------------------------------	
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )
	//aParms := BIXBEVMonth(aParam , STR0008 + "(HKR)", 2) // "Estoque Mensal "
	
	oModel:AddField( "HKR_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKR_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKR_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKR_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKR_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKR_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKR_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKR_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKR_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKR_DATA"  , "D", 8, 0 )
	oModel:AddField( "HKR_QINISD", "N", 16, 4 )
	oModel:AddField( "HKR_QFINSD", "N", 16, 4 )
	oModel:AddField( "HKR_VINISD", "N", 16, 2 )
	oModel:AddField( "HKR_VFINSD", "N", 16, 2 )
	oModel:AddField( "HKR_QSDMED", "N", 16, 4 )
	oModel:AddField( "HKR_VSDMED", "N", 16, 2 )
	oModel:AddField( "HKR_QEREAL", "N", 16, 4 )
	oModel:AddField( "HKR_VEPREV", "N", 16, 2 )
	oModel:AddField( "HKR_VEREAL", "N", 16, 2 )
	oModel:AddField( "HKR_VESEGU", "N", 16, 2 )
	oModel:AddField( "HKR_QEPREV", "N", 16, 4 )

	oModel:FreeField()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extração dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extração. 
@param cTo, caracter, Data final de extração.
@param dToday, data, Data de inicio do processo de extração.  
@param oOutput, objeto, Objeto para gravação dos dados.
@param oRecord, objeto, Objeto para extração dos dados.
@param oKey, objeto, Objeto para validação de integridade referencial.

@author  Marcia Junko
@since   24/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXMensalEstoque
	Local aMoedas	 := {}
	Local nInd       := 1 
	Local cMoeda	 := ""      
	Local cFlow		 := ""
	
	aMoedas	 := BIXGetMxF(::cEntity)
	
	// chamada da funcao da area de materiais
	cFlow := BIXFuncWrapper("KPIEstoque", "Manufatura - Materiais", {1, StoD(cFrom), StoD(cTo), cFilAnt}, ::cEntity )
	
	DBSelectArea(cFlow)
	
	(cFlow)->( dbGoTop() )

	While (cFlow)->( ! EoF() )
		
		For nInd := 1 To Len(aMoedas) 
			cMoeda := aMoedas[nInd][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "ACU_COD" 	, (cFlow)->FAMCOM )
			oRecord:SetValue( "BM_GRUPO" 	, (cFlow)->GRUPO )
			oRecord:SetValue( "B1_COD" 		, (cFlow)->ITEM )
			oRecord:SetValue( "AH_UNIMED" 	, (cFlow)->UM )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKR_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKR_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKR_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKR_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->FAMMAT } ) ) 
			oRecord:SetValue( "HKR_FAMCOM", oSeeker:Seek( "HG1", { (cFlow)->FAMCOM } ) ) 
			oRecord:SetValue( "HKR_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->GRUPO } ) ) 
			oRecord:SetValue( "HKR_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->ITEM } ) ) 
			oRecord:SetValue( "HKR_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HKR_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->UM } ) ) 

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HKR_DATA"  , IIf(!Empty((cFlow)->(DATAMOV)),(cFlow)->(DATAMOV),DATE_EMPTY) )

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKR_QEREAL", (cFlow)->(QEREAL) )
			oRecord:SetValue( "HKR_QEPREV", (cFlow)->(QEPREV) )
			oRecord:SetValue( "HKR_QINISD", (cFlow)->(QINISD) )
			oRecord:SetValue( "HKR_QFINSD", (cFlow)->(QFINSD) )
			oRecord:SetValue( "HKR_QSDMED", (cFlow)->(QSDMED) )
			oRecord:SetValue( "HKR_VEPREV", BIXValue((cFlow)->(VEPREV),(cFlow)->(MOEDA),cMoeda,(cFlow)->DATAMOV) )
			oRecord:SetValue( "HKR_VEREAL", BIXValue((cFlow)->(VEREAL),(cFlow)->(MOEDA),cMoeda,(cFlow)->DATAMOV) )
			oRecord:SetValue( "HKR_VESEGU", BIXValue((cFlow)->(VESEGU),(cFlow)->(MOEDA),cMoeda,(cFlow)->DATAMOV) )
			oRecord:SetValue( "HKR_VINISD", BIXValue((cFlow)->(VINISD),(cFlow)->(MOEDA),cMoeda,(cFlow)->DATAMOV) )
			oRecord:SetValue( "HKR_VFINSD", BIXValue((cFlow)->(VFINSD),(cFlow)->(MOEDA),cMoeda,(cFlow)->DATAMOV) )
			oRecord:SetValue( "HKR_VSDMED", BIXValue((cFlow)->(VSDMED),(cFlow)->(MOEDA),cMoeda,(cFlow)->DATAMOV) )

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		 Next nInd
		 
		(cFlow)->( dbSkip() ) 
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
	
	//----------------------------------------------------------------------
	//³ARQUIVO TEMPORARIO DE MEMORIA (CTREETMP)                            ³
	//³A funcao MSCloseTemp ira substituir a linha de codigo abaixo:       ³
	//(cFlow)->( dbCloseArea() )											   |
	//----------------------------------------------------------------------	
	MSCloseTemp( cFlow, cFlow )	
Return NIL