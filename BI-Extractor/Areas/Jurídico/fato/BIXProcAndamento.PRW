#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROCANDAMENTO.CH"

REGISTER EXTRACTOR HYP

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProcAndamento

@author  Helio Leal
@since   08/05/2013
/*/
//-------------------------------------------------------------------
Class BIXProcAndamento from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Helio Leal
@since   08/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXProcAndamento
	_Super:New( FACT, "HYP", STR0001, "NSZ", { JURIDICO } ) //"Processos em Andamento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   08/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXProcAndamento
	Local oModel := BIXModel():Build( Self )

	//----------------------------------------------------------
	// Converte o per�odo de extra��o para o primeio at� o 
	// �ltimo dia do m�s da janela informada
	//----------------------------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )

	oModel:AddField( "HYP_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HYP_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HYP_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Neg�cio"
	oModel:AddField( "HYP_ASSUNT"   ,	"C",	32, 00, .T., "HYO" ) // "Assunto Jur�dico"
	oModel:AddField( "HYP_AREAJU"   ,	"C",	32, 00, .T., "HYJ" ) // "�rea Jur�dica"
	oModel:AddField( "HYP_COMARC"   ,	"C",	32, 00, .T., "HYH" ) // "Comarca"
	oModel:AddField( "HYP_CREDEN"   ,	"C",	32, 00, .T., "HKJ" ) // "Credenciado"
	oModel:AddField( "HYP_DATA"		,	"D",	08, 00,	.F., "HK2" ) //"Data"

	oModel:AddField( "HYP_QTDPRO",	"N",	04,	00 ) //Quantidade de Processos

	oModel:FreeField()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para valida��o de integridade referencial.

@author  Helio Leal
@since   08/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXProcAndamento
	Local cFlow		:= ""
	Local aInterval	:= BIXInterval( cFrom, cTo, .T. )
	Local nInterval	:= 0  

	For nInterval := 1 To Len( aInterval ) 	
		//-------------------------------------------------------------------
		// Recupera o fluxo de dados da fato.
		//-------------------------------------------------------------------*/
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
			// Customiza��o.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "NYB_COD"		, (cFlow)->NSZ_TIPOAS )
			oRecord:SetValue( "NQ6_COD"		, (cFlow)->NUQ_CCOMAR )
			oRecord:SetValue( "NRB_COD"		, (cFlow)->NSZ_CAREAJ )
			oRecord:SetValue( "A2_COD"		, (cFlow)->CORRES )
			oRecord:SetValue( "A2_LOJA"		, (cFlow)->LOJA )

			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HYP_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HYP_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HYP_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HYP_ASSUNT"	, oSeeker:Seek( "HYO", { (cFlow)->NSZ_TIPOAS } ) )
			oRecord:SetValue( "HYP_AREAJU"  , oSeeker:Seek( "HYJ", { (cFlow)->NSZ_CAREAJ } ) )
			oRecord:SetValue( "HYP_COMARC"	, oSeeker:Seek( "HYH", { (cFlow)->NUQ_CCOMAR } ) )
			oRecord:SetValue( "HYP_CREDEN"	, oSeeker:Seek( "HKJ", { (cFlow)->CORRES, (cFlow)->LOJA } ) )

			//-------------------------------------------------------------------
			// Grava o �ltimo dia do per�odo
			//-------------------------------------------------------------------   			
			oRecord:SetValue( "HYP_DATA"	, SToD( aInterval[nInterval][2] ) )

			//-------------------------------------------------------------------
			// Grava a Quantidade de Entregas. 
			//-------------------------------------------------------------------   			
			oRecord:SetValue( "HYP_QTDPRO"	, ( cFlow )->PROCESSOS )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o. 
			//-------------------------------------------------------------------	
			oOutput:Send( oRecord )	
			
	 		( cFlow )->( DBSkip() ) 
	 	EndDo 
	 Next
	 
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------
	oOutput:Release()
return   

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma �nica tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Per�odo inicial de extra��o.
@param cTo, caracter, Per�odo final de extra��o.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restri��o na recupera��o de dados no formato {{campo, opera��o, valor}}. 
@return cFlow, Alias tempor�rio. 

@author  Marcia Junko
@since   15/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXProcAndamento
	Local cDML := ""  

	cDML += " SELECT "
	cDML += " 	NSZ.NSZ_TIPOAS NSZ_TIPOAS,"
	cDML += " 	NSZ.NSZ_CAREAJ NSZ_CAREAJ,"
	cDML += " 	NUQ.NUQ_CCOMAR NUQ_CCOMAR,"
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ) CORRES,"
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE ) LOJA,"
	cDML += " 	COUNT( NSZ.NSZ_COD ) PROCESSOS" 
	cDML += " FROM " + RetSQLName("NSZ") + " NSZ "
	cDML += " INNER JOIN " + RetSQLName("NUQ") + " NUQ ON ( "
	cDML += " 	NUQ.NUQ_CAJURI = NSZ.NSZ_COD AND "
	cDML += " 	NUQ.NUQ_INSATU = '1' AND "
	cDML += " 	NUQ.D_E_L_E_T_ = ' ' AND " 
	cDML += " 	NUQ.NUQ_FILIAL = '" + xFilial("NUQ") + "' ) " 
	cDML += " WHERE " 
	cDML += " 	NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' AND "
	cDML += " 	(NSZ.NSZ_DTINCL <= '" + cTo + "' AND (NSZ.NSZ_SITUAC = '1' OR NSZ.NSZ_DTENCE > '" + cTo + "')) AND" 
	cDML += " 	NSZ.D_E_L_E_T_ = ' ' "
	cDML += " GROUP BY "
	cDML += " 	NSZ.NSZ_TIPOAS,"
	cDML += " 	NSZ.NSZ_CAREAJ,"
	cDML += " 	NUQ.NUQ_CCOMAR,"
	cDML += " 	COALESCE( NUQ.NUQ_CCORRE, NSZ.NSZ_CCORRE ),"
	cDML += " 	COALESCE( NUQ.NUQ_LCORRE, NSZ.NSZ_LCORRE )"	

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)	
Return ::cFlow