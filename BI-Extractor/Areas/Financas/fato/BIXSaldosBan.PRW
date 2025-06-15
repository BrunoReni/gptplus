#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSALDOSBAN.CH"

REGISTER EXTRACTOR HYF

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSaldosBan
Apresenta informações de valores monetários armazenados em banco.

@author  Valdiney V GOMES
@since   08/03/2017
/*/
//-------------------------------------------------------------------
Class BIXSaldosBan from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Valdiney V GOMES
@since   08/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXSaldosBan
	_Super:New( FACT, "HYF", STR0001 , "SE8", { FINANCEIRO } ) //"Saldos Bancários"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/09/2015
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXSaldosBan 
	Local oModel := BIXModel():Build( Self )

	oModel:IsSnapshot( .T. )

	oModel:AddField( "HYF_EMPRES",	"C",	32,	00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HYF_ESTABL",	"C",	32,	00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HYF_UNDNEG",	"C",	32,	00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HYF_MOEDA" ,	"C",	32,	00, .T., "HJ6" ) //"Moeda"	
	oModel:AddField( "HYF_BCO" 	 ,	"C",	32,	00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HYF_DATA"	 ,	"D",	08,	00, .F., "HK2" ) //"Período"
	
	oModel:AddField( "HYF_VALOR",	"N",	15,	02 )	
	oModel:AddField( "HYF_DTEXTR",	"D",	08,	00 )

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
@since   14/09/2015
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXSaldosBan  
	Local aMoeda := {}
	Local cFlow  := ""
	Local cMoeda := ""
	Local nMoeda := 0

	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 		
	aMoeda 	:= BIXGetMxF( ::cEntity )

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow 	:= ::Flow( cFrom, cTo ) 
	
	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! ( cFlow )->( Eof() ) 
		For nMoeda := 1 to len(aMoeda)
			cMoeda := aMoeda[nMoeda][1]
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização. 
			//------------------------------------------------------------------- 			
	 		oRecord:SetValue( "E8_BANCO"  	, (cFlow)->E8_BANCO )
	 		oRecord:SetValue( "E8_AGENCIA"	, (cFlow)->E8_AGENCIA )
	 		oRecord:SetValue( "E8_CONTA"	, (cFlow)->E8_CONTA )
	 		oRecord:SetValue( "E8_DTSALAT"	, (cFlow)->E8_DTSALAT )
			oRecord:SetValue( "A6_COD"		, (cFlow)->E8_BANCO )
			oRecord:SetValue( "A6_AGENCIA"	, (cFlow)->E8_AGENCIA )
			oRecord:SetValue( "A6_NUMCON"	, (cFlow)->E8_CONTA ) 		
	 		
	   		//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HYF_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HYF_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HYF_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) ) 
			oRecord:SetValue( "HYF_BCO"		, oSeeker:Seek( "HG4", { (cFlow)->E8_BANCO, (cFlow)->E8_AGENCIA, (cFlow)->E8_CONTA } ) ) 
	 		oRecord:SetValue( "HYF_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
	 		oRecord:SetValue( "HYF_DATA"	, (cFlow)->E8_DTSALAT )
	 		oRecord:SetValue( "HYF_DTEXTR"	, dToday )	

	   		//-------------------------------------------------------------------
			// Indicadores.
			//-------------------------------------------------------------------   			
			oRecord:SetValue( "HYF_VALOR"	, BIXValue( (cFlow)->E8_SALATUA, (cFlow)->E8_MOEDA , cMoeda, (cFlow)->E8_DTSALAT)  )	
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next
		
 		( cFlow )->( DBSkip() ) 
 	EndDo 
 	
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------		
	oOutput:Release()	 
return nil 
 
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
@since   14/09/2015
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXSaldosBan
	Local cDML	:= ""

	cDML += " SELECT"
	cDML += " 		E8_MOEDA,"
	cDML += " 		E8_BANCO,"
	cDML += " 		E8_AGENCIA,"
	cDML += " 		E8_CONTA,"
	cDML += " 		E8_DTSALAT,"
	cDML += " 		E8_SALATUA"
	cDML += " FROM "
	cDML +=  		RetSqlName("SE8") + " SE8 " 
	cDML += " WHERE "
	cDML += "		E8_FILIAL = '" + xFilial("SE8") + "' "
	cDML += " 		AND "
	cDML += " 		SE8.R_E_C_N_O_ IN ( "
	cDML += " 			SELECT "
	cDML += "					MAX( R_E_C_N_O_ ) "
	cDML += "			FROM " 
	cDML += 					RetSqlName("SE8") + " SE8B "
	cDML += "			WHERE "
	cDML += "					SE8B.E8_FILIAL  = SE8.E8_FILIAL "
	cDML += "					AND "
	cDML += "					SE8B.E8_BANCO  = SE8.E8_BANCO "	
	cDML += "					AND "
	cDML += "					SE8B.E8_AGENCIA = SE8.E8_AGENCIA "	
	cDML += "					AND "
	cDML += "					SE8B.E8_CONTA = SE8.E8_CONTA " 	
	cDML += "					AND "
	cDML += "					SE8B.E8_DTSALAT <= '" + cFrom + "' "
	cDML += "					AND "
	cDML += "					SE8B.D_E_L_E_T_ = ' ') "
	cDML += " 		AND " 
	cDML += " 		SE8.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias() , .T., .F. )

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "E8_DTSALAT", "D", 8, 0 )     
Return ::cFlow
