#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSALDODIARIOESTOQUE.CH"

REGISTER EXTRACTOR HKT

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSaldoDiarioEstoque
Classe do extrator para a tabela fato Saldo Diário Estoque do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   11/11/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXSaldoDiarioEstoque from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXSaldoDiarioEstoque
	_Super:New( FACT, "HKT", STR0001, "SB2", { MATERIAIS } ) // "Saldo do Estoque Diário" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXSaldoDiarioEstoque
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKT_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKT_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKT_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKT_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKT_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKT_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKT_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HKT_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKT_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKT_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKT_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKT_DATA"  , "D", 8, 0 )
	oModel:AddField( "HKT_CODLOC", "C", 10, 0 )
	oModel:AddField( "HKT_NMLOTE", "C", 10, 0 )
	oModel:AddField( "HKT_QINISD", "N", 16, 4 )
	oModel:AddField( "HKT_QFINSD", "N", 16, 4 )
	oModel:AddField( "HKT_VINISD", "N", 16, 2 )
	oModel:AddField( "HKT_VFINSD", "N", 16, 2 )

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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXSaldoDiarioEstoque
	Local aMoedas := {}
	Local cMoeda  := ""    
	Local nInd    := 1 
	Local lIgnoreZero := !( IsLoadZero() )

	Private cFlow    := ""
	
	aMoedas := BIXGetMxF(::cEntity)

	//-------------------------------------------------------------------
	// Recupera as informações do estoque.  
	//------------------------------------------------------------------- 	
	cFlow := BIXFuncWrapper("KPIEstoque", "Manufatura - Materiais", {3, StoD(cFrom), StoD(cTo), cFilAnt, lIgnoreZero }, ::cEntity )
	
	DBSelectArea(cFlow)
	
	(cFlow)->( dbGoTop() )
	
	While (cFlow)->(! EoF() )
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
			oRecord:SetValue( "HKT_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKT_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKT_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->FAMMAT } ) ) 
			oRecord:SetValue( "HKT_FAMCOM", oSeeker:Seek( "HG1", { (cFlow)->FAMCOM } ) ) 
			oRecord:SetValue( "HKT_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->GRUPO } ) ) 
			oRecord:SetValue( "HKT_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->ITEM } ) ) 
			oRecord:SetValue( "HKT_DEPOSI", oSeeker:Seek( "HJD", { (cFlow)->DEPOSITO } ) )
			oRecord:SetValue( "HKT_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) )
			oRecord:SetValue( "HKT_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKT_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->UM } ) ) 
			oRecord:SetValue( "HKT_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HKT_DATA" 	, IIf(!Empty((cFlow)->(DATAMOV)),(cFlow)->(DATAMOV),DATE_EMPTY) )// Data do Movimento
			oRecord:SetValue( "HKT_NMLOTE", " " )
			oRecord:SetValue( "HKT_CODLOC", " " )

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKT_QINISD", (cFlow)->(QINISD) )
			oRecord:SetValue( "HKT_QFINSD", (cFlow)->(QFINSD) )
			oRecord:SetValue( "HKT_VINISD", BIXValue((cFlow)->(VINISD), (cFlow)->(MOEDA), cMoeda, (cFlow)->(DATAMOV)) )
			oRecord:SetValue( "HKT_VFINSD", BIXValue((cFlow)->(VFINSD), (cFlow)->(MOEDA), cMoeda, (cFlow)->(DATAMOV)) )

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
	MSCloseTemp(cFlow, cFlow)		
Return nil
