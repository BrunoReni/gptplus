#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXBENEFICIOECON.CH"

REGISTER EXTRACTOR HYR

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXBeneficioEcon
A tabela fato Vendas apresenta informações dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Class BIXBeneficioEcon from BIXEntity
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
Method New() Class BIXBeneficioEcon
	_Super:New( FACT, "HYR", STR0001, "NSZ", { JURIDICO } ) //"Benefício Economico"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   23/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXBeneficioEcon 
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o período de extração para o primeio até o 
	// último dia do mês da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )
	
	oModel:AddField( "HYR_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HYR_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HYR_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HYR_CREDEN"   ,	"C",	32, 00, .T., "HKJ" ) // "Credenciado"
	oModel:AddField( "HYR_ASSUNT"   ,	"C",	32, 00, .T., "HYO" ) // "Assunto Jurídico"
	oModel:AddField( "HYR_COMARC"   ,	"C",	32, 00, .T., "HYH" ) // "Comarca"
	oModel:AddField( "HYR_MOEDA" 	,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HYR_DATA"		,	"D",	08, 00, .F., "HK2" ) // "Data"
	
	oModel:AddField( "HYR_VLPROV"	, 	"N", 	18, 04	) //Valor Provisão
	oModel:AddField( "HYR_VLFINC"   , 	"N", 	18, 04	) //Valor Final do Caso
	oModel:AddField( "HYR_VLENVO"   , 	"N", 	18, 04	) //Valor Envolvido

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXBeneficioEcon
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
	
		While ! (cFlow)->( Eof() )
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

				//-------------------------------------------------------------------
				// Lookups.
				//-------------------------------------------------------------------	
				oRecord:SetValue( "HYR_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
				oRecord:SetValue( "HYR_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HYR_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HYR_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
				oRecord:SetValue( "HYR_CREDEN"	, oSeeker:Seek( "HKJ", { (cFlow)->CORRES, (cFlow)->LOJA } ) )
				oRecord:SetValue( "HYR_ASSUNT"	, oSeeker:Seek( "HYO", { (cFlow)->NSZ_TIPOAS } ) )
				oRecord:SetValue( "HYR_COMARC"	, oSeeker:Seek( "HYH", { (cFlow)->NUQ_CCOMAR } ) )

				//-------------------------------------------------------------------
				// Grava o último dia do período
				//-------------------------------------------------------------------   			
				oRecord:SetValue( "HYR_DATA"	, SToD( aInterval[nInterval][2] ) )
		
				//-------------------------------------------------------------------
				// Grava a Quantidade de Entregas. 
				//-------------------------------------------------------------------   			
				oRecord:SetValue( "HYR_VLPROV"  , ( cFlow )->PROVISAO )
				oRecord:SetValue( "HYR_VLENVO"  , ( cFlow )->ENVOLVIDO )
				oRecord:SetValue( "HYR_VLFINC"  , ( cFlow )->VLFINAL )	
				
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXBeneficioEcon
	Local cDML 	:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cDML += " SELECT "
	cDML += " 	SUM( NSZ.NSZ_VLPROV ) PROVISAO, "
	cDML += " 	SUM( NSZ.NSZ_VLENVO ) ENVOLVIDO, "
	cDML += " 	SUM( NSZ.NSZ_VLFINA ) VLFINAL, "
	cDML += " 	NSZ.NSZ_TIPOAS NSZ_TIPOAS, "
	cDML += " 	NUQ.NUQ_CCOMAR NUQ_CCOMAR, "
	cDML += " 	NSZ.NSZ_CMOPRO NSZ_CMOPRO, "
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ) CORRES, "
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ) LOJA "
	cDML += " FROM " + RetSQLName("NSZ") + " NSZ "
	cDML += " INNER JOIN " + RetSQLName("NUQ") + " NUQ ON ( "
	cDML += " 	NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND " 
	cDML += " 	NUQ.NUQ_INSATU = '1' AND "
	cDML += " 	NUQ.D_E_L_E_T_ = ' ' AND "
	cDML += " 	NUQ.NUQ_FILIAL = '" + xFilial("NUQ") + "' ) "
	cDML += " WHERE "
	cDML += " 	NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' AND "
	cDML += " 	NSZ.NSZ_SITUAC = '2' AND "
	cDML += " 	NSZ.NSZ_DTENCE BETWEEN '" + cFrom + "' AND '" + cTo + "' AND "
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