#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROCABERTXENCERRA.CH"

REGISTER EXTRACTOR HYQ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProcAbertxEncerra

@author  Helio Leal
@since   08/05/2013
/*/
//-------------------------------------------------------------------
Class BIXProcAbertxEncerra from BIXEntity
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
@since   08/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXProcAbertxEncerra
	_Super:New( FACT, "HYQ", STR0001, "NSZ", { JURIDICO } ) //"Processos Abertos e Encerrados"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   08/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXProcAbertxEncerra 
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o período de extração para o primeio até o 
	// último dia do mês da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )

	oModel:AddField( "HYQ_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HYQ_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HYQ_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HYQ_CREDEN"   ,	"C",	32, 00, .T., "HKJ" ) // "Credenciado"
	oModel:AddField( "HYQ_ASSUNT"   ,	"C",	32, 00, .T., "HYO" ) // "Assunto Jurídico"
	oModel:AddField( "HYQ_COMARC"   ,	"C",	32, 00, .T., "HYH" ) // "Comarca"
	oModel:AddField( "HYQ_MOTIVO"   ,	"C",	32, 00, .T., "HYK" ) // "Motivo Encerramento" /*/
	oModel:AddField( "HYQ_AREAJU"   ,	"C",	32, 00, .T., "HYJ" ) // "Área Jurídica"
	oModel:AddField( "HYQ_CLIENT"   ,	"C",	32, 00, .T., "HJ7" ) // "Cliente"
	oModel:AddField( "HYQ_DATA"		,	"D",	08, 00,	.F., "HK2" ) //"Data"

	oModel:AddField( "HYQ_QTDABE",	"N",	04,	00 ) //Quantidade Abertos
	oModel:AddField( "HYQ_QTDENC",	"N",	04,	00 ) //Quantidade Encerrados

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
@since   08/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXProcAbertxEncerra
	Local cFlow		:= ""
	Local aInterval	:= BIXInterval( cFrom, cTo, .T. )
	Local nInterval	:= 0  

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
			oRecord:SetValue( "NQ6_COD"		, (cFlow)->NUQ_CCOMAR )
			oRecord:SetValue( "A2_COD"		, (cFlow)->CORRES )
			oRecord:SetValue( "A2_LOJA"		, (cFlow)->LOJA )
			oRecord:SetValue( "A1_COD"		, (cFlow)->NSZ_CCLIEN )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->NSZ_LCLIEN )
			oRecord:SetValue( "NQI_COD"		, (cFlow)->NSZ_CMOENC )
			oRecord:SetValue( "NRB_COD"		, (cFlow)->NSZ_CAREAJ )
			
			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------	
			oRecord:SetValue( "HYQ_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HYQ_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HYQ_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HYQ_CREDEN"	, oSeeker:Seek( "HKJ", { (cFlow)->CORRES, (cFlow)->LOJA } ) )
			oRecord:SetValue( "HYQ_ASSUNT"	, oSeeker:Seek( "HYO", { (cFlow)->NSZ_TIPOAS } ) )
			oRecord:SetValue( "HYQ_COMARC"	, oSeeker:Seek( "HYH", { (cFlow)->NUQ_CCOMAR } ) )
			oRecord:SetValue( "HYQ_MOTIVO"  , oSeeker:Seek( "HYK", { (cFlow)->NSZ_CMOENC } ) )
			oRecord:SetValue( "HYQ_AREAJU"  , oSeeker:Seek( "HYJ", { (cFlow)->NSZ_CAREAJ } ) )
			oRecord:SetValue( "HYQ_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->NSZ_CCLIEN, (cFlow)->NSZ_LCLIEN } ) )

			//-------------------------------------------------------------------
			// Grava o último dia do período
			//-------------------------------------------------------------------   			
			oRecord:SetValue( "HYQ_DATA"	, SToD( aInterval[nInterval][2] ) )
				
			//-------------------------------------------------------------------
			// Grava a Quantidade de Entregas. 
			//-------------------------------------------------------------------   			
			oRecord:SetValue( "HYQ_QTDABE"	, ( cFlow )->ABERTOS )
			oRecord:SetValue( "HYQ_QTDENC"  , ( cFlow )->FECHADOS )
	
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXProcAbertxEncerra
	Local cDML := ""  

	cDML += " SELECT "
	cDML += " 	NSZ.NSZ_TIPOAS NSZ_TIPOAS, "
	cDML += " 	NSZ.NSZ_CCLIEN NSZ_CCLIEN, "
	cDML += " 	NSZ.NSZ_LCLIEN NSZ_LCLIEN, "
	cDML += " 	NSZ.NSZ_CAREAJ NSZ_CAREAJ, "
	cDML += " 	NSZ.NSZ_CMOENC NSZ_CMOENC, "
	cDML += " 	NUQ.NUQ_CCOMAR NUQ_CCOMAR, "
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ) CORRES, "
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ) LOJA, "
	cDML += " 	COUNT( ABERTOS.NSZ_COD ) ABERTOS, "
	cDML += " 	COUNT( FECHADOS.NSZ_COD ) FECHADOS "
	cDML += " FROM " + RetSQLName("NSZ") + " NSZ "
	cDML += " LEFT JOIN ( "
	cDML += " 	SELECT " 
	cDML += " 		NSZA.NSZ_COD "
	cDML += " 	FROM " + RetSQLName("NSZ") + " NSZA "
	cDML += " 	WHERE " 
	cDML += " 		NSZA.NSZ_DTINCL between '" + cFrom + "' and '" + cTo + "' AND "
	cDML += " 		NSZA.NSZ_FILIAL = '" + xFilial("NSZ") + "' AND "
	cDML += " 		NSZA.D_E_L_E_T_ = ' ' " 
	cDML += " ) ABERTOS " 
	cDML += "	ON ( NSZ.NSZ_COD = ABERTOS.NSZ_COD ) "
	cDML += " LEFT JOIN ( "
	cDML += " 	SELECT "
	cDML += " 		NSZF.NSZ_COD "
	cDML += " 	FROM " + RetSQLName("NSZ") + " NSZF "
	cDML += " 	WHERE "
	cDML += " 		NSZF.NSZ_DTENCE between '" + cFrom + "' and '" + cTo + "' AND "
	cDML += " 		NSZF.NSZ_SITUAC = '2' AND "
	cDML += " 		NSZF.NSZ_FILIAL = '" + xFilial("NSZ") + "' AND "
	cDML += "			 NSZF.D_E_L_E_T_ = ' ' "
	cDML += " ) FECHADOS " 
	cDML += " ON ( NSZ.NSZ_COD = FECHADOS.NSZ_COD ) "
	cDML += " INNER JOIN " + RetSQLName("NUQ") + " NUQ ON ( "
	cDML += " 	NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND "
	cDML += " 	NUQ.NUQ_INSATU = '1' AND "
	cDML += " 	NUQ.D_E_L_E_T_ = ' ' AND "
	cDML += " 	NUQ.NUQ_FILIAL = '" + xFilial("NUQ") + "' ) "
	cDML += " WHERE "
	cDML += "	 	NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' AND "
	cDML += " 	NSZ.D_E_L_E_T_ = ' ' AND "
	cDML += " 	COALESCE( FECHADOS.NSZ_COD, ABERTOS.NSZ_COD, '-') <> '-' "
	cDML += " GROUP BY "
	cDML += " 	NSZ.NSZ_TIPOAS, "
	cDML += " 	NSZ.NSZ_CCLIEN, "
	cDML += " 	NSZ.NSZ_LCLIEN, "
	cDML += " 	NSZ.NSZ_CAREAJ, "
	cDML += " 	NUQ.NUQ_CCOMAR, "
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ), "
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ), "
	cDML += " 	NSZ.NSZ_CMOENC "

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)	
Return ::cFlow