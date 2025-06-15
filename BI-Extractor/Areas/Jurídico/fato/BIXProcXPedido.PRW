#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROCXPEDIDO.CH"

REGISTER EXTRACTOR HYS

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProcXPedido

@author  Helio Leal
@since   24/05/2017
/*/
//-------------------------------------------------------------------
Class BIXProcXPedido from BIXEntity
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
@since   24/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXProcXPedido
	_Super:New( FACT, "HYS", STR0001, "NSY", { JURIDICO } ) //"Análise Processo x Pedidos"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   24/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXProcXPedido
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o período de extração para o primeio até o 
	// último dia do mês da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )

	oModel:AddField( "HYS_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) // "Empresa"	
	oModel:AddField( "HYS_ESTABL"	,	"C",	32, 00, .T., "HKK" ) // "Estabelecimento"
	oModel:AddField( "HYS_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) // "Unidade de Negócio"
	oModel:AddField( "HYS_ASSUNT"   ,	"C",	32, 00, .T., "HYO" ) // "Assunto Jurídico"
	oModel:AddField( "HYS_AREAJU"   ,	"C",	32, 00, .T., "HYJ" ) // "Área Jurídica"
	oModel:AddField( "HYS_COMARC"   ,	"C",	32, 00, .T., "HYH" ) // "Comarca"
	oModel:AddField( "HYS_CREDEN"   ,	"C",	32, 00, .T., "HKJ" ) // "Credenciado"
	oModel:AddField( "HYS_PEDJUR"   ,	"C",	32, 00, .T., "HYL" ) // "Pedidos Jurídicos"
	oModel:AddField( "HYS_DATA"		,	"D",	08, 00,	.F., "HK2" ) // "Data"
	oModel:AddField( "HYS_QTDPPE"	,	"N",	04,	00 ) // "Quantidade de Processos x Pedidos"
	oModel:AddField( "HYS_VLPPE"	,	"N",	18,	04 ) // "Valor de Processos x Pedidos"

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
@since   24/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXProcXPedido
	Local cFlow     := ""
	Local aInterval := BIXInterval( cFrom, cTo, .T. )
	Local nInterval := 0  

	For nInterval := 1 To Len( aInterval ) 	
		//-------------------------------------------------------------------
		// Recupera o fluxo de dados da fato.
		//-------------------------------------------------------------------
		cFlow := ::Flow( aInterval[nInterval][1], aInterval[nInterval][2] )

		//-------------------------------------------------------------------
		// Itera por todos os registros do fluxo principal. 
		//-------------------------------------------------------------------  
	 	While ! (cFlow)->( Eof() )
	 		//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
	 		
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "NYB_COD"		, (cFlow)->NSZ_TIPOAS )
			oRecord:SetValue( "NRB_COD"		, (cFlow)->NSZ_CAREAJ )			
			oRecord:SetValue( "NQ6_COD"		, (cFlow)->NUQ_CCOMAR )			
			oRecord:SetValue( "A2_COD"		, (cFlow)->CORRES )
			oRecord:SetValue( "A2_LOJA"		, (cFlow)->LOJA )
			oRecord:SetValue( "NSP_COD"		, (cFlow)->NSY_CPEVLR )

			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HYS_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HYS_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HYS_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HYS_ASSUNT"	, oSeeker:Seek( "HYO", { (cFlow)->NSZ_TIPOAS } ) )
			oRecord:SetValue( "HYS_AREAJU"  , oSeeker:Seek( "HYJ", { (cFlow)->NSZ_CAREAJ } ) )
			oRecord:SetValue( "HYS_COMARC"	, oSeeker:Seek( "HYH", { (cFlow)->NUQ_CCOMAR } ) )
			oRecord:SetValue( "HYS_CREDEN"	, oSeeker:Seek( "HKJ", { (cFlow)->CORRES, (cFlow)->LOJA } ) )
			oRecord:SetValue( "HYS_PEDJUR"	, oSeeker:Seek( "HYL", { (cFlow)->NSY_CPEVLR } ) )

			//-------------------------------------------------------------------
			// Grava o último dia do período
			//-------------------------------------------------------------------   			
			oRecord:SetValue( "HYS_DATA"	, SToD( aInterval[nInterval][2] ) )
	
			//-------------------------------------------------------------------
			// Grava a Quantidade de Entregas. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HYS_QTDPPE"	,  ( cFlow )->PEDIDOS )

			//-------------------------------------------------------------------
			// Grava o valor do Pedido. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HYS_VLPPE"	,  ( cFlow )->VLRPEDIDO )			
	
	 		//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------	
			oOutput:Send( oRecord )	
			
	 		( cFlow )->( DBSkip() ) 
	 	EndDo 
	 Next
	 
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
	oOutput:Release()	 
return   

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

@author  Marcia Junko
@since   15/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXProcXPedido
	Local cDML 	:= ""  

	cDML += " SELECT "
	cDML += " 	COUNT( NSY.NSY_COD ) PEDIDOS, "
	cDML += " 	NSY.NSY_CPEVLR NSY_CPEVLR, "
	cDML += " 	SUM( NSY.NSY_PEVLR ) VLRPEDIDO, "
	cDML += " 	NSZ.NSZ_TIPOAS NSZ_TIPOAS, "
	cDML += " 	NSZ.NSZ_CAREAJ NSZ_CAREAJ,"
	cDML += " 	NUQ.NUQ_CCOMAR NUQ_CCOMAR, "
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ) CORRES, "
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ) LOJA "
	cDML += " FROM " + RetSQLName("NSY") + " NSY "
	cDML += " INNER JOIN " + RetSQLName("NSZ") + " NSZ ON ( "
	cDML += " 	NSZ.NSZ_COD = NSY.NSY_CAJURI AND "
	cDML += " 	NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' AND "
	cDML += " 	NSZ.D_E_L_E_T_ = ' ' ) "
	cDML += " INNER JOIN " + RetSQLName("NUQ") + " NUQ ON ( "
	cDML += " 	NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND "
	cDML += " 	NUQ.NUQ_INSATU = '1' AND "
	cDML += " 	NUQ.D_E_L_E_T_ = ' ' AND "
	cDML += " 	NUQ.NUQ_FILIAL = '" + xFilial("NUQ") + "' ) "
	cDML += " WHERE "
	cDML += " 	NSY.NSY_FILIAL = '" + xFilial("NSY") + "' AND "
	cDML += " ((NSZ.NSZ_DTINCL BETWEEN '" + cFrom + "' AND '" + cTo + "' AND NSZ.NSZ_SITUAC = '1') OR "	
	cDML += "  (NSZ.NSZ_DTENCE BETWEEN '" + cFrom + "' AND '" + cTo + "' AND NSZ.NSZ_SITUAC = '2')) AND "
	cDML += " 	NSY.D_E_L_E_T_ = ' ' " 
	cDML += " GROUP BY "
	cDML += "	 	NSY.NSY_CPEVLR, "
	cDML += " 	NSZ.NSZ_TIPOAS, "
	cDML += " 	NSZ.NSZ_CAREAJ, "
	cDML += " 	NUQ.NUQ_CCOMAR, "
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ), "
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ) "	

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)	
Return ::cFlow