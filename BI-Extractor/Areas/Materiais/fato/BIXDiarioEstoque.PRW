#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDIARIOESTOQUE.CH"

REGISTER EXTRACTOR HKS

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDiarioEstoque
Classe do extrator para a tabela fato Estoque Diário do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   11/11/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXDiarioEstoque from BIXEntity
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
Method New() Class BIXDiarioEstoque
	_Super:New( FACT, "HKS", STR0001, "SB2", { MATERIAIS } ) // "Estoque Diário" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   24/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXDiarioEstoque
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKS_EMPRES", "C", 	32, 0, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HKS_ESTABL", "C", 	32, 0, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HKS_FAMMAT", "C", 	32, 0, .T., "HG2" ) //"Famíalia Material"
	oModel:AddField( "HKS_FAMCOM", "C", 	32, 0, .T., "HG1" ) //"Família Comercial"
	oModel:AddField( "HKS_GRPEST", "C", 	32, 0, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HKS_ITEM"  , "C", 	32, 0, .T., "HJ8" ) //"Item"
	oModel:AddField( "HKS_MOEDA" , "C", 	32, 0, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HKS_CCUSTO", "C", 	32, 0, .T., "HJ5" ) // "Centro de Custo"
	oModel:AddField( "HKS_DEPOSI", "C", 	32, 0, .T., "HJD" ) //"Deposito"
	oModel:AddField( "HKS_UNDNEG", "C", 	32, 0, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HKS_PLCCST", "C", 	32, 0, .T., "HKF" ) //"Plano Centro de Custo"
	oModel:AddField( "HKS_NATOPR", "C", 	32, 0, .T., "HJ9" ) //"Natureza da Operação"
	oModel:AddField( "HKS_REFER" , "C", 	32, 0, .T., "HJH" ) //"Referência"
	oModel:AddField( "HKS_CFOP"  , "C", 	32, 0, .T., "HG0" ) //"CFOP"
	oModel:AddField( "HKS_UNITEM", "C", 	32, 0, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HKS_NUMDOC", "C", 	40, 0 )	
	oModel:AddField( "HKS_SERDOC", "C", 	8, 0 )	
	oModel:AddField( "HKS_CODLOC", "C", 	10, 0 )	
	oModel:AddField( "HKS_NMLOTE", "C", 	10, 0 )	
	oModel:AddField( "HKS_DATA"  , "D", 	8, 0 )	
	oModel:AddField( "HKS_NMTRAN", "N", 	4, 0 )	
	oModel:AddField( "HKS_VENTRA", "N", 	16, 2 )
	oModel:AddField( "HKS_VSAIDA", "N", 	16, 2 )
	oModel:AddField( "HKS_VSDMED", "N", 	16, 2 )
	oModel:AddField( "HKS_VMATES", "N", 	16, 2 )
	oModel:AddField( "HKS_VMOBES", "N", 	16, 2 )
	oModel:AddField( "HKS_VGGFES", "N", 	16, 2 )
	oModel:AddField( "HKS_QGIRO" , "N", 	16, 4 )
	oModel:AddField( "HKS_QENTRA", "N", 	16, 4 )
	oModel:AddField( "HKS_QSAIDA", "N", 	16, 4 )
	oModel:AddField( "HKS_QSDMED", "N", 	16, 4 )
	oModel:AddField( "HKS_QSAIAC", "N", 	16, 4 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXDiarioEstoque
	Local aMoedas    	:= {}
	Local aVmates		:= TamSX3("HKS_VMATES") 
	Local aGiro			:= TamSX3("HKS_QGIRO")	
	Local cMoeda     	:= ""
	Local cFlow     	:= ""
	Local nMoeda       	:= 1
	Local nVmates		:= 0
	Local nGiro			:= 0
	Local nMaxVmates	:= 0
	Local nMaxGiro		:= 0	
	Local lIgnoreZero 	:= ! IsLoadZero() 
	Local nVSMed 		:= 0
	
	aMoedas := BIXGetMxF( ::cEntity )
	
	//-------------------------------------------------------------------
	// Identifica o limite dos campos principais.  
	//------------------------------------------------------------------- 		
	nMaxVmates := nBIVal( Replicate( "9", ( aVmates[1] - aVmates[2] - 2 ) ) )
	nMaxGiro   := nBIVal( Replicate( "9", ( aGiro[1] - aGiro[2] - 2 ) )	)

	//-------------------------------------------------------------------
	// Recupera as informações do estoque.  
	//------------------------------------------------------------------- 	
	cFlow := BIXFuncWrapper("KPIEstoque", "Manufatura - Materiais", {2, StoD(cFrom), StoD(cTo), cFilAnt, lIgnoreZero }, ::cEntity )
	
	DBSelectArea(cFlow)
	
	(cFlow)->(dbGoTop())	
	
	While (cFlow)->(! EoF() )
		nGiro := 0

		//-------------------------------------------------------------------
		// Calcula a quatidade de dias de giro.
		//-------------------------------------------------------------------
		If (cFlow)->QINISD != 0 .And. (cFlow)->(QSAIAC)  != 0
			nGiro := ( (cFlow)->QINISD / ( (cFlow)->(QSAIAC)  / ( StoD( cFrom ) - StoD( cTo ) ) ) )
		Else
			nGiro := 0
		EndIf
		
		//-------------------------------------------------------------------
		// Limita a quatidade de dias de giro.
		//-------------------------------------------------------------------
		If ( Abs( nGiro ) > nMaxGiro )
			nGiro := ( nMaxGiro * If ( nGiro >= 0, 1, -1 ) )		   
		EndIf	
	
		For nMoeda  := 1 To Len(aMoedas)
			nVmates	:= 0
			nVSMed := 0
			cMoeda  := aMoedas[nMoeda][1]

			nVSMed := BIXValue((cFlow)->(VSDMED), (cFlow)->(MOEDA), cMoeda, (cFlow)->(DATAMOV))
			nVmates := (cFlow)->QSDMED * nVSMed

			//-------------------------------------------------------------------
			// Limita o valor total de material em estoque.
			//-------------------------------------------------------------------
			If ( Abs( nVMates ) > nMaxVmates )
				nVmates := ( nMaxVmates * If ( nVmates >= 0, 1, -1 ) )		   
			EndIf

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
			oRecord:SetValue( "HKS_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKS_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKS_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKS_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->FAMMAT } ) ) 
			oRecord:SetValue( "HKS_FAMCOM", oSeeker:Seek( "HG1", { (cFlow)->FAMCOM } ) ) 
			oRecord:SetValue( "HKS_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->GRUPO } ) ) 
			oRecord:SetValue( "HKS_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->ITEM } ) ) 
			oRecord:SetValue( "HKS_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HKS_DEPOSI", oSeeker:Seek( "HJD", { (cFlow)->DEPOSITO } ) ) 
			oRecord:SetValue( "HKS_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->UM } ) )
			oRecord:SetValue( "HKS_CCUSTO", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKS_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKS_NATOPR", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKS_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKS_CFOP"  , oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HKS_DATA"  , IIf( !Empty( (cFlow)->(DATAMOV)), (cFlow)->(DATAMOV), DATE_EMPTY) )
			oRecord:SetValue( "HKS_NUMDOC", " " )	
			oRecord:SetValue( "HKS_SERDOC", " " )	
			oRecord:SetValue( "HKS_CODLOC", " " )	
			oRecord:SetValue( "HKS_NMLOTE", " " )	

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKS_VENTRA", BIXValue((cFlow)->(VENTRA), (cFlow)->(MOEDA), cMoeda, (cFlow)->(DATAMOV)) )
			oRecord:SetValue( "HKS_VSAIDA", BIXValue((cFlow)->(VSAIDA), (cFlow)->(MOEDA), cMoeda, (cFlow)->(DATAMOV)) )
			oRecord:SetValue( "HKS_VSDMED", nVSMed )
			oRecord:SetValue( "HKS_VMATES", Round( nVmates, 2 ) )
			oRecord:SetValue( "HKS_QGIRO" , Round( nGiro, 2 ) )
			oRecord:SetValue( "HKS_QENTRA", (cFlow)->(QENTRA) )
			oRecord:SetValue( "HKS_QSAIDA", (cFlow)->(QSAIDA) )
			oRecord:SetValue( "HKS_QSDMED", (cFlow)->(QSDMED) )
			oRecord:SetValue( "HKS_QSAIAC", (cFlow)->(QSAIAC) )
			oRecord:SetValue( "HKS_VMOBES", 0 )
			oRecord:SetValue( "HKS_VGGFES", 0 )
			oRecord:SetValue( "HKS_NMTRAN", 0 )	

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda
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
