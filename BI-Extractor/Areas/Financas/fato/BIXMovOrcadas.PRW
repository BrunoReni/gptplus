#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOVORCADAS.CH"

REGISTER EXTRACTOR HYG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMovOrcadas
Apresenta informações de valores monetários orçados para a 
movimentações mensais.

@author  Marcia Junko
@since   14/09/2015
/*/
//-------------------------------------------------------------------
Class BIXMovOrcadas from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
	Method BudgetedValue()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara
@since   06/03/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXMovOrcadas
	_Super:New( FACT, "HYG", STR0001, "SE7", { FINANCEIRO } ) //"Movimentações Financeiras Orçadas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/09/2015
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXMovOrcadas 
	Local oModel := BIXModel():Build( Self )
	
	oModel:AddField( "HYG_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HYG_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HYG_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HYG_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HYG_CCUSTO",	"C",	32, 00, .T., "HJ5" ) //"Centro Custo"	
	oModel:AddField( "HYG_NATFIN",	"C",	32, 00, .T., "HYE" ) //"Natureza Financeira"
	oModel:AddField( "HYG_DATA",	"D",	08, 00,	.F., "HK2" ) //"Período"
	
	oModel:AddField( "HYG_VALOR",	"N",	15,	02 )	

	oModel:FreeField()
	
	//-------------------------------------------------------------------
	// Manipula o periodo de extração indicado para período completo
	//-------------------------------------------------------------------	
	oModel:SetPeriod( PERIOD_MONTH_RANGE ) 
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXMovOrcadas
	Local aMoeda 	:= {}
	Local aInterval := {}
	Local cMoeda	:= ""
	Local cFlow		:= ""
	Local cYear		:= ""
	Local nMoeda	:= 0 
   	Local nI		:= 0
	
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda 	  := BIXGetMxF( ::cEntity )
	aInterval := BIXInterval( cFrom, cTo )
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While ! (cFlow)->( Eof() ) 

		For nI := 1 to Len( aInterval )
			cYear := Alltrim(Str(Year(aInterval[nI][1]))) 		

			If cYear == (cFlow)->E7_ANO

				For nMoeda := 1 to Len( aMoeda )
					cMoeda := aMoeda[nMoeda][1]
			
					//-------------------------------------------------------------------
					// Inicializa o registro. 
					//------------------------------------------------------------------- 				
					oRecord:Init()

					//-------------------------------------------------------------------
					// Customização.
					//------------------------------------------------------------------- 
					oRecord:SetValue( "E7_NATUREZ"	, (cFlow)->E7_NATUREZ )
					oRecord:SetValue( "E7_ANO"		, (cFlow)->E7_ANO ) 
					oRecord:SetValue( "E7_CMOEDA"	, (cFlow)->E7_CMOEDA )
					oRecord:SetValue( "CTT_CUSTO"	, (cFlow)->E7_CCUSTO )
					oRecord:SetValue( "ED_CODIGO"	, (cFlow)->E7_NATUREZ ) 
					
					//-------------------------------------------------------------------
					// Lookups.
					//------------------------------------------------------------------- 
					oRecord:SetValue( "HYG_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
					oRecord:SetValue( "HYG_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
					oRecord:SetValue( "HYG_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
					oRecord:SetValue( "HYG_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
					oRecord:SetValue( "HYG_NATFIN"	, oSeeker:Seek( "HYE", { (cFlow)->E7_NATUREZ } ) )			
					oRecord:SetValue( "HYG_CCUSTO"	, oSeeker:Seek( "HJ5", { (cFlow)->E7_CCUSTO } ) ) 
					oRecord:SetValue( "HYG_DATA"	, aInterval[nI][1]  )					
			
					//-------------------------------------------------------------------
					// Indicadores.
					//------------------------------------------------------------------- 			
					oRecord:SetValue( "HYG_VALOR"	, ( BIXValue( ::BudgetedValue( aInterval[nI][1], cFlow ), (cFlow)->E7_MOEDA, cMoeda, aInterval[nI][1])))
			
					//-------------------------------------------------------------------
					// Envia o registro para o pool de gravação. 
					//-------------------------------------------------------------------				
					oOutput:Send( oRecord ) 
				Next nMoeda	
			EndIf
		Next nI	
		(cFlow)->( DBSkip() )
	EndDo	
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return nil

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

@author  Tamara Clemente
@since   03/03/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXMovOrcadas
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//------------------------------------------------------------------- 
	cDML += " SELECT "
	cDML += "		SE7.E7_NATUREZ,"
	cDML += "		SE7.E7_CCUSTO,"	
	cDML += " 		SE7.E7_MOEDA,"
	cDML += " 		SE7.E7_ANO,"
	cDML += " 		SE7.E7_VALJAN1,"
	cDML += " 		SE7.E7_VALFEV1,"
	cDML += " 		SE7.E7_VALMAR1,"	
	cDML += " 		SE7.E7_VALABR1,"
	cDML += " 		SE7.E7_VALMAI1,"
	cDML += " 		SE7.E7_VALJUN1,"
	cDML += " 		SE7.E7_VALJUL1,"
	cDML += " 		SE7.E7_VALAGO1,"
	cDML += " 		SE7.E7_VALSET1,"
	cDML += " 		SE7.E7_VALOUT1,"
	cDML += " 		SE7.E7_VALNOV1,"
	cDML += " 		SE7.E7_VALDEZ1,"
	cDML += " 		SE7.E7_CMOEDA"	
	cDML += " FROM "
	cDML += 		RetSQLName( "SE7" ) + " SE7 "
	cDML += " WHERE " 
	cDML += "		SE7.E7_FILIAL = '" + xFilial( "SE7" ) + "'" 
	cDML +=  "		AND"
	cDML += "		E7_ANO BETWEEN '" + Subs(cFrom, 1, 4) + "' AND '" + Subs(cTo, 1, 4) + "' "
	cDML += "		AND" 	
	cDML += "	   	SE7.D_E_L_E_T_ = ' '" 
	
	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias() , .T., .F. )
Return ::cFlow

//-------------------------------------------------------------------
/*/{Protheus.doc} BudgetedValue
Retorna o valor orçado de acordo com a data passada

@param cData	 Data para verificação do valor orçado
@param cMainFlow Fluxo de dados principal com os valores posicionados 

@author  Marcia Junko
@since   14/09/2015
/*/
//-------------------------------------------------------------------
Method BudgetedValue( cData, cMainFlow ) Class BIXMovOrcadas
	Local nValue := 0
	Local nMonth := Month( cData )
	
	Do Case
		Case nMonth == 1
			nValue := (cMainFlow)->E7_VALJAN1
		Case nMonth == 2
			nValue := (cMainFlow)->E7_VALFEV1
		Case nMonth == 3
			nValue := (cMainFlow)->E7_VALMAR1
		Case nMonth == 4
			nValue := (cMainFlow)->E7_VALABR1
		Case nMonth == 5
			nValue := (cMainFlow)->E7_VALMAI1
		Case nMonth == 6
			nValue := (cMainFlow)->E7_VALJUN1
		Case nMonth == 7
			nValue := (cMainFlow)->E7_VALJUL1
		Case nMonth == 8
			nValue := (cMainFlow)->E7_VALAGO1
		Case nMonth == 9
			nValue := (cMainFlow)->E7_VALSET1
		Case nMonth == 10
			nValue := (cMainFlow)->E7_VALOUT1
		Case nMonth == 11
			nValue := (cMainFlow)->E7_VALNOV1
		Case nMonth == 12
			nValue := (cMainFlow)->E7_VALDEZ1
	End 
Return nValue