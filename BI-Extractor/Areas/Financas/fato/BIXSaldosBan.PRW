#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSALDOSBAN.CH"

REGISTER EXTRACTOR HYF

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSaldosBan
Apresenta informa��es de valores monet�rios armazenados em banco.

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
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Valdiney V GOMES
@since   08/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXSaldosBan
	_Super:New( FACT, "HYF", STR0001 , "SE8", { FINANCEIRO } ) //"Saldos Banc�rios"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
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
	oModel:AddField( "HYF_UNDNEG",	"C",	32,	00, .T., "HJ1" ) //"Unidade de Neg�cio"
	oModel:AddField( "HYF_MOEDA" ,	"C",	32,	00, .T., "HJ6" ) //"Moeda"	
	oModel:AddField( "HYF_BCO" 	 ,	"C",	32,	00, .T., "HG4" ) //"Portador"
	oModel:AddField( "HYF_DATA"	 ,	"D",	08,	00, .F., "HK2" ) //"Per�odo"
	
	oModel:AddField( "HYF_VALOR",	"N",	15,	02 )	
	oModel:AddField( "HYF_DTEXTR",	"D",	08,	00 )

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
	// Recupera os par�metros da fato. 
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
			// Customiza��o. 
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
			// Envia o registro para o pool de grava��o. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next
		
 		( cFlow )->( DBSkip() ) 
 	EndDo 
 	
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------		
	oOutput:Release()	 
return nil 
 
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
