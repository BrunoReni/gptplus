#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXENTREGAS.CH"

REGISTER EXTRACTOR HOF

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEntregas
A tabela fato Devolução de Vendas apresenta informações relacionadas as 
devoluções das vendas, como valores e quantidades devolvidas e impostos.

@author  Helio Leal
@since   09/05/2017
/*/
//-------------------------------------------------------------------
Class BIXEntregas from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author Helio Leal  
@since   09/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXEntregas
	_Super:New( FACT, "HOF", STR0001, "DTQ", { DL } ) //"Entregas"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author Helio Leal  
@since   09/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXEntregas
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOF_EMPRES"	,	"C",	32,	 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HOF_ESTABL"	,	"C",	32,	 00, .T., "HKK" ) //"Estabelecimento""
	oModel:AddField( "HOF_UNDNEG"	,	"C",	32,	 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HOF_TIPTRA"	,	"C",	32,	 00, .T., "HHX") //"Tipo Transporte"
	oModel:AddField( "HOF_ROTA"		,	"C",	32,	 00, .T., "HGI") //"Rota"
	oModel:AddField( "HOF_VIAGEM"	,	"C",	32,	 00, .T., "HO7") //"Viagem"	
	oModel:AddField( "HOF_CLIREM"	,	"C",	32,	 00, .T., "HJ7") //"Cliente Remetente"	
	oModel:AddField( "HOF_CLIDES"	,	"C",	32,	 00, .T., "HJ7") //"Cliente Destinatário"	
	oModel:AddField( "HOF_CLIDEV"	,	"C",	32,	 00, .T., "HJ7") //"Cliente Devedor"	
	oModel:AddField( "HOF_REGTRA"	,	"C",	32,	 00, .T., "HO0") //"Região de Transporte de Origem"	
	oModel:AddField( "HOF_REGDES"	,	"C",	32,	 00, .T., "HO0") //"Região de Transporte de Destino"	
	oModel:AddField( "HOF_FILORI"	,	"C",	32,	 00, .T., "HO9") //"Filial de Origem"	
	oModel:AddField( "HOF_STAENT"	,	"C",	32,	 00, .T., "HOA") //"Status Entrega"		
	oModel:AddField( "HOF_DATA"		, 	"D",	08,	 00, .F., "HK2" ) //"Data da Entrega"
	oModel:AddField( "HOF_DTPREV"	, 	"D",	08,	 00, .F., "HK2" ) //"Data Previsão de Entrega"

	oModel:AddField( "HOF_QTDENT"	,	"N",	04,	 00 ) //Qtde Entregas

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
@param oSeeker, objeto, Objeto para validação de integridade referencial.

@author  Helio Leal
@since   09/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXEntregas
	Local cFlow	:= ""
    	 
   	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! ( cFlow )->( Eof() ) 
 		//-------------------------------------------------------------------
		// Inicializa o registro.
		//-------------------------------------------------------------------
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Customização.
		//------------------------------------------------------------------- 
		oRecord:SetValue( "DUY_GRPVEN"	, (cFlow)->DT6_CDRORI )
		oRecord:SetValue( "DTQ_VIAGEM"	, (cFlow)->DUD_VIAGEM )
		oRecord:SetValue( "DA8_COD"	    , (cFlow)->DT6_ROTENT )		
		
		//-------------------------------------------------------------------
		// Lookups.
		//-------------------------------------------------------------------	
		oRecord:SetValue( "HOF_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
		oRecord:SetValue( "HOF_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
		oRecord:SetValue( "HOF_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
		oRecord:SetValue( "HOF_VIAGEM" 	, oSeeker:Seek( "HO7", { (cFlow)->DUD_VIAGEM } ) )
		oRecord:SetValue( "HOF_ROTA" 	, oSeeker:Seek( "HGI", { (cFlow)->DT6_ROTENT } ) )
		oRecord:SetValue( "HOF_CLIREM" 	, oSeeker:Seek( "HJ7", { (cFlow)->DT6_CLIREM, (cFlow)->DT6_LOJREM } ) )
		oRecord:SetValue( "HOF_CLIDES" 	, oSeeker:Seek( "HJ7", { (cFlow)->DT6_CLIDES, (cFlow)->DT6_LOJDES } ) )
		oRecord:SetValue( "HOF_CLIDEV" 	, oSeeker:Seek( "HJ7", { (cFlow)->DT6_CLIDEV, (cFlow)->DT6_LOJDEV } ) )
		oRecord:SetValue( "HOF_REGTRA" 	, oSeeker:Seek( "HO0", { (cFlow)->DT6_CDRORI } ) )
		oRecord:SetValue( "HOF_REGDES" 	, oSeeker:Seek( "HO0", { (cFlow)->DT6_CDRDES } ) )

  		//-------------------------------------------------------------------
		// ...e os lookups sem validação. 
		//-------------------------------------------------------------------  
		oRecord:SetValue( "HOF_TIPTRA" , ( cFlow )->DT6_TIPTRA )
   		oRecord:SetValue( "HOF_FILORI" , oSeeker:Seek( "HO9", { ( cFlow )->DUD_FILORI } ) )	
   		oRecord:SetValue( "HOF_STAENT" , If( ( cFlow )->DT6_DATENT <= ( cFlow )->DT6_PRZENT, "1", "2" ) )
   		
   		//-------------------------------------------------------------------
		// Grava a Quantidade de Entregas. 
		//-------------------------------------------------------------------   			
 		oRecord:SetValue( "HOF_QTDENT" , 1 )
   	 
   	 	//-------------------------------------------------------------------
		// Grava os campos data. 
		//------------------------------------------------------------------- 	
   		oRecord:SetValue( "HOF_DTPREV"  , ( cFlow )->DT6_PRZENT )
     	oRecord:SetValue( "HOF_DATA"	, ( cFlow )->DT6_DATENT )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação. 
		//-------------------------------------------------------------------				
		oOutput:Send( oRecord ) 
		
 		( cFlow )->( DBSkip() ) 
 	EndDo 

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
	oOutput:Release()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma única tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Período inicial de extração.
@param cTo, caracter, Período final de extração.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restrição na recuperação de dados no formato {{campo, operação, valor}}. 
@return cRetAlias, Alias temporário. 

@author  Helio Leal
@since   09/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXEntregas
	Local cDML 	:= ""  
	Local lPostgres	:= (TCGetDB() == "POSTGRES")
	Local lOracle	:= (TCGetDB() == "ORACLE")

	cDML += "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_TIPTRA, DT6_CLIREM, " 
	cDML += "	DT6_LOJREM, DT6_CLIDES, DT6_LOJDES, DT6_CLIDEV, DT6_LOJDEV, " 
	cDML += " 	DT6_CDRORI, DT6_CDRDES, DT6_ROTENT, DT6_PRZENT, DT6_DATENT, "		
	cDML += " 	("   
	cDML += " 		SELECT"
	
	If ( ( !lPostgres ) .And. ( !lOracle ) )
		cDML += "	TOP 1 "  
	EndIf 
	
	cDML += "		DUD.DUD_FILORI FROM " + RetSQLName("DUD") + " DUD"  
	cDML += " 		WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
	cDML += " 			AND DUD_FILDOC = DT6_FILDOC" 
	cDML += " 			AND DUD_DOC = DT6_DOC" 
	cDML += " 			AND DUD_SERIE = DT6_SERIE"  
	cDML += " 			AND DUD_SERTMS = '3'"
	cDML += " 			AND DUD_VIAGEM <> ' '"
	cDML += " 			AND DUD.D_E_L_E_T_ = ' '"
	
	If ( lOracle )
		cDML += " AND ROWNUM = 1 "
	EndIf
		
	If lPostgres
		cDML += " 	LIMIT 1"
	EndIf
	
	cDML += " 	) AS DUD_FILORI," 
	cDML += " 	(" 
	cDML += " 		SELECT" 
	
	If ( ( !lPostgres ) .And. ( !lOracle ) )
		cDML += "	TOP 1 "  
	EndIf 
	
	cDML += " 		DUD_VIAGEM FROM " + RetSQLName("DUD") + " DUD"  
	cDML += " 		WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
	cDML += " 			AND DUD_FILDOC = DT6_FILDOC" 
	cDML += " 			AND DUD_DOC = DT6_DOC" 
	cDML += " 			AND DUD_SERIE = DT6_SERIE" 
	cDML += " 		   	AND DUD_SERTMS = '3'"
	cDML += " 		   	AND DUD_VIAGEM <> ' '"
	cDML += " 			AND DUD.D_E_L_E_T_ = ' '" 

	If ( lOracle )
		cDML += " AND ROWNUM = 1 "
	EndIf

	If lPostgres
		cDML += " 	LIMIT 1"
	EndIf

	cDML += " 	) AS DUD_VIAGEM" 
	cDML += " FROM " + RetSQLName("DT6") + " DT6"
	cDML += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "'"
	cDML += "		AND DT6_DATENT BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cDML += "		AND DT6_SERTMS = '3'"	                 
	cDML += "		AND DT6.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML ) 

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "DT6_PRZENT", "D", 8, 0 )
	TcSetField( ::cFlow, "DT6_DATENT", "D", 8, 0 ) 	
Return ::cFlow