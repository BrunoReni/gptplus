#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFLUXOCAIXA.CH"

REGISTER EXTRACTOR HYY

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFluxoCaixa
Apresenta informa��es relacionadas ao fluxo de caixa da empresa.

@author  Valdiney V GOMES
@since   08/03/2017
/*/
//-------------------------------------------------------------------
Class BIXFluxoCaixa from BIXEntity
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
Method New() Class BIXFluxoCaixa
	_Super:New( FACT, "HYY", STR0001, "FIV", { FINANCEIRO } ) //"Fluxo de caixa"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   08/04/2016
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXFluxoCaixa 
	Local oModel := BIXModel():Build( Self )
	
	//-------------------------------------------------------------------
	// Converte o per�odo de extra��o informado para o primeio dia do m�s 
	// da data inicial at� o �ltimo dia do m�s da data final. 
	//-------------------------------------------------------------------	
	oModel:SetPeriod ( PERIOD_MONTH_RANGE )

	oModel:AddField( "HYY_EMPRES",	"C",	32,	00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HYY_ESTABL",	"C",	32,	00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HYY_UNDNEG",	"C",	32,	00, .T., "HJ1" ) //"Unidade de Neg�cio"
	oModel:AddField( "HYY_MOEDA" ,	"C",	32,	00, .T., "HJ6" ) //"Moeda"	
	oModel:AddField( "HYY_ORIGEM",	"C",	32,	00, .T., "HK7" ) //"Origem"
	oModel:AddField( "HYY_TPCART",	"C",	32,	00, .T., "HYX" ) //"Tipo de Carteira"	
	oModel:AddField( "HYY_NATFIN",	"C",	32,	00, .T., "HYE" ) //"Natureza Financeira"		
	oModel:AddField( "HYY_CCUSTO",	"C",	32,	00, .T., "HJ5" ) //"Centro de Custo"		
	oModel:AddField( "HYY_DATA"	 ,	"D",	08,	00, .F., "HK2" ) //"Per�odo"
	
	oModel:AddField( "HYY_VLPREV",	"N",	18,	04 )	
	oModel:AddField( "HYY_VLREAL",	"N",	18,	04 )

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

@author  Valdiney V GOMES
@since   08/04/2016
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXFluxoCaixa    
    Local aMoeda    := {}
    Local cMoeda	:= "" 
    Local cFlow		:= ""
    Local nMoeda	:= 1  

	//-------------------------------------------------------------------
	// Recupera os par�metros da fato. 
	//------------------------------------------------------------------- 		
	aMoeda 	:= BIXGetMxF( ::cEntity )

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow 	:= ::Flow( cFrom, cTo ) 
 
 	While ! (cFlow)->( Eof() ) 
 	 	For nMoeda := 1 To Len( aMoeda ) 
  			cMoeda := aMoeda[nMoeda][1]   
  			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
 			//-------------------------------------------------------------------
			// Customiza��o.  
			//------------------------------------------------------------------- 	
			oRecord:SetValue( "FIV_NATUR"	, (cFlow)->FIV_NATUR )
			oRecord:SetValue( "FIV_MOEDA"	, (cFlow)->FIV_MOEDA )
			oRecord:SetValue( "FIV_TPSALD"	, (cFlow)->FIV_TPSALD )
			oRecord:SetValue( "FIV_CARTEI"	, (cFlow)->FIV_CARTEI )
			oRecord:SetValue( "FIV_DATA" 	, (cFlow)->FIV_DATA )
			oRecord:SetValue( "ED_CODIGO"	, (cFlow)->FIV_NATUR )
 	
 	   		//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HYY_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HYY_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HYY_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) ) 	
			oRecord:SetValue( "HYY_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )	
			oRecord:SetValue( "HYY_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->FIV_NATUR } ) ) 
			oRecord:SetValue( "HYY_TPCART"	, oSeeker:Seek( "HYX", { If ( (cFlow)->FIV_TPSALD == "2", "P", "R" ) } ) ) 
			oRecord:SetValue( "HYY_ORIGEM"	, oSeeker:Seek( "HK7", { If ( (cFlow)->FIV_CARTEI == "R", "1", "2" ) } ) ) 
 			oRecord:SetValue( "HYY_CCUSTO"	, oSeeker:Seek( "HJ5", { UNDEFINED } ) ) 
			oRecord:SetValue( "HYY_DATA"	, (cFlow)->FIV_DATA )	

	   		//-------------------------------------------------------------------
			// Indicadores.  
			//-------------------------------------------------------------------   								
			If ( (cFlow)->FIV_TPSALD == "2" )
				oRecord:SetValue( "HYY_VLPREV", BIXValue( (cFlow)->FIV_VALOR, 1, cMoeda, (cFlow)->FIV_DATA ) )
			Else	
				oRecord:SetValue( "HYY_VLREAL", BIXValue( (cFlow)->FIV_VALOR, 1, cMoeda, (cFlow)->FIV_DATA ) )
			EndIf
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
     	Next nMoeda 
     	
 		(cFlow)->( DBSkip() ) 
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
@return cDML, Alias tempor�rio. 

@author  Valdiney V GOMES
@since   08/04/2016  
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXFluxoCaixa
	Local cDML := ""  

	cDML += " SELECT" 
	cDML += " 		FIV.FIV_FILIAL,"
	cDML += " 		FIV.FIV_NATUR,"
	cDML += " 		FIV.FIV_MOEDA,"
	cDML += " 		FIV.FIV_TPSALD,"
	cDML += " 		FIV.FIV_CARTEI,"
	cDML += " 		FIV.FIV_DATA,"
	cDML += " 		SUM( FIV.FIV_VALOR ) FIV_VALOR
	cDML += " FROM " + RetSQLName("FIV") + " FIV"
	cDML += " WHERE 
	cDML += "		FIV.FIV_FILIAL = '" + xFilial("FIV") + "'"
	cDML += "	   	AND"                   
	cDML += "		FIV.FIV_DATA BETWEEN '" + cFrom + "' AND '" + cTo + "'"              
	cDML += "		AND" 
	cDML += " 		( FIV.FIV_TPSALD = '2' OR FIV.FIV_TPSALD = '3' )
	cDML += "		AND" 
	cDML += "	   	FIV.D_E_L_E_T_ = ' '" 
	cDML += " GROUP BY " 
	cDML += " 		FIV.FIV_FILIAL,"
	cDML += " 		FIV.FIV_NATUR,"
	cDML += " 		FIV.FIV_MOEDA,"
	cDML += " 		FIV.FIV_TPSALD,"
	cDML += " 		FIV.FIV_CARTEI,"
	cDML += " 		FIV.FIV_DATA"  	 	 
	
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
	TCSetField( ::cFlow, "FIV_DATA", "D", 8, 0 ) 
  
Return ::cFlow