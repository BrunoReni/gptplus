#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROVISAOCONSOLIDADA.CH"

REGISTER EXTRACTOR HYT

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProvisaoConsolidada
A tabela fato Vendas apresenta informações dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Class BIXProvisaoConsolidada from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Helio Leal
@since   23/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXProvisaoConsolidada
	_Super:New( FACT, "HYT", STR0001, "NSZ", { JURIDICO } ) //"Provisão Consolidada"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   23/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXProvisaoConsolidada 
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o período de extração para o primeio até o 
	// último dia do mês da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )
	
	oModel:AddField( "HYT_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HYT_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HYT_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HYT_CREDEN"   ,	"C",	32, 00, .T., "HKJ" ) // "Credenciado"
	oModel:AddField( "HYT_ASSUNT"   ,	"C",	32, 00, .T., "HYO" ) // "Assunto Jurídico"
	oModel:AddField( "HYT_MOEDA" 	,	"C",	32, 00, .T., "HJ6" ) //"Moeda"	
	oModel:AddField( "HYT_COMARC"   ,	"C",	32, 00, .T., "HYH" ) // "Comarca"
	oModel:AddField( "HYT_PROGNO"   ,	"C",	32, 00, .T., "HYI" ) // "Prognóstico"
	oModel:AddField( "HYT_DATA"		,	"D",	08, 00, .F., "HK2" ) // "Data"
	oModel:AddField( "HYT_VLPROV"	, 	"N", 	18, 04	) // "Valor Provisão"
	oModel:AddField( "HYT_VLDESP"	, 	"N", 	18, 04	) // "Despesa"
	

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

@author  Helio Leal
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXProvisaoConsolidada
	Local aMoeda	:= BIXGetMxF( ::cEntity )
    Local cMoeda	:= "" 
    Local nMoeda	:= 1  
	Local aInterval	:= BIXInterval( cFrom, cTo, .T. )
	Local nInterval	:= 0  
	Local cFlow		:= ""

	For nInterval := 1 To Len( aInterval ) 	
		//-------------------------------------------------------------------
		// Recupera o fluxo de dados da fato.
		//-------------------------------------------------------------------
		cFlow := ::Flow( aInterval[nInterval][1], aInterval[nInterval][2] )
	
		//-------------------------------------------------------------------
		// Itera por todos os registros do fluxo principal. 
		//-------------------------------------------------------------------  
	 	While ! ( cFlow )->( Eof() ) 
	 		For nMoeda := 1 To Len( aMoeda )
	  			cMoeda 	:= aMoeda[nMoeda][1]

		 		//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 
				oRecord:Init()
				
				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "NYB_COD"		, (cFlow)->NSZ_TIPOAS )
				oRecord:SetValue( "NQ6_COD"		, (cFlow)->NUQ_CCOMAR )
				oRecord:SetValue( "A2_COD"		, (cFlow)->CORRES )
				oRecord:SetValue( "A2_LOJA"		, (cFlow)->LOJA )
				oRecord:SetValue( "NQ7_COD"		, (cFlow)->NSZ_CPROGN )

				//-------------------------------------------------------------------
				// Lookups.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HYT_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
				oRecord:SetValue( "HYT_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HYT_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HYT_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
				oRecord:SetValue( "HYT_CREDEN"	, oSeeker:Seek( "HKJ", { (cFlow)->CORRES, (cFlow)->LOJA } ) )
				oRecord:SetValue( "HYT_ASSUNT"	, oSeeker:Seek( "HYO", { (cFlow)->NSZ_TIPOAS } ) )
				oRecord:SetValue( "HYT_COMARC"	, oSeeker:Seek( "HYH", { (cFlow)->NUQ_CCOMAR } ) )
				oRecord:SetValue( "HYT_PROGNO"	, oSeeker:Seek( "HYI", { (cFlow)->NSZ_CPROGN } ) )

				//-------------------------------------------------------------------
				// Grava o último dia do período
				//-------------------------------------------------------------------   			
				oRecord:SetValue( "HYT_DATA"	, SToD( aInterval[nInterval][2] ) )

				//-------------------------------------------------------------------
				// Grava a Quantidade de Entregas. 
				//-------------------------------------------------------------------
				oRecord:SetValue( "HYT_VLPROV"	, ( cFlow )->PROVISAO )

				//-------------------------------------------------------------------
				// Grava o valor das despesas. 
				//-------------------------------------------------------------------
				oRecord:SetValue( "HYT_VLDESP"	, ( cFlow )->DESPESA )

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------
				oOutput:Send( oRecord )
			Next nMoeda

	 		( cFlow )->( DBSkip() ) 
	 	EndDo 
	 Next

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
	oOutput:Release()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma única tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Período inicial de extração.
@param cTo, caracter, Período final de extração.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restrição na recuperação de dados no formato {{campo, operação, valor}}. 
@return cFlow, Alias temporário. 

@author  Helio Leal
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXProvisaoConsolidada
	Local cDML := ""  

	cDML += " SELECT "
	cDML += " 	SUM( NSZ.NSZ_VLPROV ) PROVISAO, "
	cDML += " 	SUM( NT3.NT3_VALOR ) DESPESA, "
	cDML += " 	NSZ.NSZ_TIPOAS NSZ_TIPOAS, "
	cDML += " 	NSZ.NSZ_CPROGN NSZ_CPROGN, "
	cDML += " 	NUQ.NUQ_CCOMAR NUQ_CCOMAR, "
	cDML += " 	NSZ.NSZ_CMOPRO NSZ_CMOPRO, "
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ) CORRES, "
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ) LOJA "
	cDML += " FROM " + RetSQLName("NSZ") + " NSZ "
	cDML += " INNER JOIN " + RetSQLName("NUQ") + " NUQ ON ( "
	cDML += " 	NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND "
	cDML += "	 	NUQ.NUQ_INSATU = '1' AND "
	cDML += " 	NUQ.D_E_L_E_T_ = ' ' AND "
	cDML += " 	NUQ.NUQ_FILIAL = '" + xFilial("NUQ") + "' ) "
	cDML += " LEFT JOIN " + RetSQLName("NT3") + " NT3 ON ( "
	cDML += " 	NT3.NT3_CAJURI = NSZ.NSZ_COD AND "
	cDML += " 	NT3.D_E_L_E_T_ = ' ' AND "
	cDML += " 	NT3.NT3_FILIAL = '" + xFilial("NT3") + "' ) "
	cDML += " WHERE " 
	cDML += " 	NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' AND "
	cDML += " ((NSZ.NSZ_DTINCL BETWEEN '" + cFrom + "' AND '" + cTo + "' AND NSZ.NSZ_SITUAC = '1') OR "	
	cDML += "  (NSZ.NSZ_DTENCE BETWEEN '" + cFrom + "' AND '" + cTo + "' AND NSZ.NSZ_SITUAC = '2')) AND "
	cDML += " 	NSZ.D_E_L_E_T_ = ' ' "
	cDML += " GROUP BY "
	cDML += " 	NSZ.NSZ_TIPOAS, "
	cDML += " 	NSZ.NSZ_CPROGN, "
	cDML += " 	NUQ.NUQ_CCOMAR, "
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ), "
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ), "
	cDML += " 	NSZ.NSZ_CMOPRO "

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)	
Return ::cFlow