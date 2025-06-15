#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXAVLCREDITO.CH"

REGISTER EXTRACTOR HL0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAvlCredito
A fato Avaliação de Crédito apresenta informações históricas de
limite de crédito dos clientes. 

@author  Helio Leal
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Class BIXAvlCredito from BIXEntity
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXAvlCredito
	_Super:New( FACT, "HL0", STR0001, "SA1", { COMERCIAL } ) //"Avaliação de Crédito"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXAvlCredito
	Local oModel := BIXModel():Build( Self )

	oModel:IsSnapshot( .T. )

	oModel:AddField( "HL0_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HL0_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL0_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HL0_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL0_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"
	oModel:AddField( "HL0_REPRES",	"C", 	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HL0_CLIENT",	"C", 	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HL0_STCRED",	"C", 	32, 00, .T., "HK1" ) //"Situação de Crédito"
	oModel:AddField( "HL0_CANALV",	"C", 	32, 00, .T., "HGA" ) //"Canal de Vendas"
	oModel:AddField( "HL0_MICREG",	"C", 	32, 00, .T., "HGB" ) //"Microregião"
	oModel:AddField( "HL0_CONDPG",	"C", 	32, 00, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HL0_TRANSP",	"C", 	32, 00, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HL0_TABPCO",	"C", 	32, 00, .T., "HGN" ) //"Tabela de Preço"
	oModel:AddField( "HL0_REGCOM",	"C", 	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL0_DTEXTR",	"D",	08, 00, .F., "HK2" ) //"Período"
	oModel:AddField( "HL0_VLMCDD",	"N",	16,	02 ) // Limite do Crédito disponível
	oModel:AddField( "HL0_VLMCDT",	"N",	16,	02 ) // Valor Limite Crédito		    

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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXAvlCredito
	Local oRegion		:= nil
	Local aMoeda 		:= {}
	Local cMoeda		:= ""
	Local cFlow		:= ""
	Local nMoeda		:= 0 
	Local cBlqCred	:= ""

	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda 	:= BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	While ! (cFlow)->( Eof() )
		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->A1_LOJA )
			oRecord:SetValue( "A1_COD"		, (cFlow)->A1_COD )	
			oRecord:SetValue( "A3_COD"		, (cFlow)->A1_VEND ) 
			oRecord:SetValue( "E4_CODIGO"	, (cFlow)->A1_COND )
			oRecord:SetValue( "DA0_CODTAB"	, (cFlow)->A1_TABELA )
			oRecord:SetValue( "A4_COD"		, (cFlow)->A1_TRANSP )
			oRecord:SetValue( "ACY_GRPVEN"	, (cFlow)->A1_GRPVEN )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HL0_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HL0_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HL0_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HL0_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A1_EST, (cFlow)->A1_COD_MUN, (cFlow)->A1_PAIS ) } ) )
			oRecord:SetValue( "HL0_REPRES"	, oSeeker:Seek( "HJC", { (cFlow)->A1_VEND } ) )
			oRecord:SetValue( "HL0_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->A1_COD, (cFlow)->A1_LOJA } ) )
			oRecord:SetValue( "HL0_CONDPG"	, oSeeker:Seek( "HJA", { (cFlow)->A1_COND } ) )
			oRecord:SetValue( "HL0_TRANSP"	, oSeeker:Seek( "HJ2", { (cFlow)->A1_TRANSP } ) )
		 	oRecord:SetValue( "HL0_TABPCO"	, oSeeker:Seek( "HGN", { (cFlow)->A1_TABELA } ) )
			oRecord:SetValue( "HL0_REGCOM"	, oSeeker:Seek( "HGD", { (cFlow)->A1_GRPVEN } ) )
			oRecord:SetValue( "HL0_GRPCLI"	, oSeeker:Seek( "HJ0", { (cFlow)->A1_TIPO } ) )
			oRecord:SetValue( "HL0_STCRED"	, oSeeker:Seek( "HK1", { if( MaAvalCred( (cFlow)->A1_COD, (cFlow)->A1_LOJA, 0, 1, .T., @cBlqCred ), "3", "4" ) } ) )
			oRecord:SetValue( "HL0_MICREG"	, oSeeker:Seek( "HGB", { (cFlow)->A1_REGIAO } ) )
			oRecord:SetValue( "HL0_CANALV" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL0_DTEXTR"	, dToday  )

			//-------------------------------------------------------------------
			// Indicadores.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HL0_VLMCDD"	, BIXValue( (cFlow)->(A1_LC - A1_SALDUP) , (cFlow)->A1_MOEDALC, cMoeda, dToday ) )
			oRecord:SetValue( "HL0_VLMCDT"	, BIXValue( (cFlow)->A1_LC, (cFlow)->A1_MOEDALC, cMoeda, dToday ) )

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda

		(cFlow)->( DBSkip() )
	EndDo

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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXAvlCredito
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//------------------------------------------------------------------- 
	cDML += " SELECT SA1.A1_VEND, SA1.A1_COND, SA1.A1_TABELA, SA1.A1_TRANSP, " + ;
		"SA1.A1_GRPVEN, SA1.A1_EST, SA1.A1_COD_MUN, " + ;
		"SA1.A1_PAIS, SA1.A1_LOJA, SA1.A1_COD, SA1.A1_REGIAO, SA1.A1_LC, " + ;
		"SA1.A1_SALDUP, A1_TIPO, SA1.A1_MOEDALC " + ;
		" FROM " + RetSQLName( "SA1" ) + " SA1 " + ;
			" WHERE SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' " + ;
			" AND SA1.D_E_L_E_T_ = ' '" 

	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias() , .T., .F. )
Return ::cFlow 