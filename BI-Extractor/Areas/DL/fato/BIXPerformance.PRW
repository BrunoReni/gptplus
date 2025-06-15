#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPERFORMANCE.CH"

REGISTER EXTRACTOR HOE 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPerformance
A tabela fato Vendas apresenta informações dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Class BIXPerformance from BIXEntity
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXPerformance
	_Super:New( FACT, "HOE", STR0001, "DTW", { DL } ) //"Performance de Entrega"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPerformance 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOE_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HOE_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HOE_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HOE_TIPTRA"	,	"C",	32, 00, .T., "HHX" ) //"Tipo Transporte"	
	oModel:AddField( "HOE_SERTRA"	,	"C",	32, 00, .T., "HO1" ) //"Serviço de Transporte"
	oModel:AddField( "HOE_SEROPE"	,	"C",	32, 00, .T., "HO3" ) //"Serviço Operacional"
	oModel:AddField( "HOE_TAREFA"	,	"C",	32, 00, .T., "HO4" ) //"Tarefa"
	oModel:AddField( "HOE_ATIVID"	,	"C",	32, 00, .T., "HO5" ) //"Atividade"
	oModel:AddField( "HOE_TIPOPE"	,	"C",	32, 00, .T., "HO6" ) //"Tipo de Operação"	
	oModel:AddField( "HOE_VIAGEM"	,	"C",	32, 00, .T., "HO7" ) //"Viagem"	
	oModel:AddField( "HOE_FILATV"	,	"C",	32, 00, .T., "HO9" ) //"Filial de Atividade" 
	oModel:AddField( "HOE_DATA"		,	"D",	08, 00, .F., "HK2" ) //"Data da Entrega"

	oModel:AddField( "HOE_PERFOR"	, 	"N", 	10, 00	) //Performance

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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPerformance
    Local nDayToMinute	:= 0
    Local nHourToMinute := 0  
    Local nMinute   	:= 0
	Local cFlow			:= ""


	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )
 
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
		oRecord:SetValue( "DTQ_VIAGEM"	, (cFlow)->DTW_VIAGEM )
		
		//-------------------------------------------------------------------
		// Lookups.
		//-------------------------------------------------------------------	
		oRecord:SetValue( "HOE_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
		oRecord:SetValue( "HOE_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
		oRecord:SetValue( "HOE_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
		oRecord:SetValue( "HOE_SEROPE" 	, oSeeker:Seek( "HO3", { (cFlow)->DTW_SERVIC } ) )
		oRecord:SetValue( "HOE_TAREFA" 	, oSeeker:Seek( "HO4", { (cFlow)->DTW_TAREFA } ) )
		oRecord:SetValue( "HOE_ATIVID" 	, oSeeker:Seek( "HO5", { (cFlow)->DTW_ATIVID } ) )
		oRecord:SetValue( "HOE_VIAGEM" 	, oSeeker:Seek( "HO7", { (cFlow)->DTW_VIAGEM } ) )
		
  		//-------------------------------------------------------------------
		// ...e os lookups sem validação. 
		//-------------------------------------------------------------------  
		oRecord:SetValue("HOE_FILATV" ,  oSeeker:Seek( "HO9", { ( cFlow )->DTW_FILATI } ) )	
		oRecord:SetValue("HOE_TIPTRA" ,  ( cFlow )->DTW_TIPTRA )
		oRecord:SetValue("HOE_SERTRA" ,  ( cFlow )->DTW_SERTMS )
		oRecord:SetValue("HOE_TIPOPE" ,  ( cFlow )->DTW_TIPOPE )

   		//-------------------------------------------------------------------
		// Calcula e grava a Performance. 
		//-------------------------------------------------------------------   			
		nDayToMinute   			:= ( nBIVal( ( cFlow )->DTW_DATPRE - ( cFlow )->DTW_DATREA ) ) * 1440 
       	nHourToMinute  			:= ( nBIVal( Substr( ( cFlow )->DTW_HORPRE, 1, 2 ) ) - nBIVal( Substr( ( cFlow )->DTW_HORREA, 1, 2 ) ) ) * 60
       	nMinute        			:= ( nBIVal( Substr( ( cFlow )->DTW_HORPRE, 3, 4 ) ) - nBIVal( Substr( ( cFlow )->DTW_HORREA, 3, 4 ) )  )  
 		oRecord:SetValue("HOE_PERFOR", ( nDayToMinute + nHourToMinute + nMinute ) )

   	 	//-------------------------------------------------------------------
		// Grava os campos data. 
		//------------------------------------------------------------------- 	
     	oRecord:SetValue("HOE_DATA", ( cFlow )->DTW_DATREA )
		
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXPerformance
	Local cDML 	:= ""  

	cDML += " SELECT" 
	cDML += " 		DTW.DTW_FILATI,
	cDML += " 		DTW.DTW_TIPTRA,
	cDML += " 		DTW.DTW_SERTMS,
	cDML += " 		DTW.DTW_SERVIC,
	cDML += " 		DTW.DTW_TAREFA,
	cDML += " 		DTW.DTW_ATIVID,
	cDML += " 		DTW.DTW_TIPOPE,
	cDML += " 		DTW.DTW_VIAGEM,
	cDML += " 		DTW.DTW_DATREA,
	cDML += " 		DTW.DTW_DATPRE, 
	cDML += " 		DTW.DTW_HORPRE, 
	cDML += " 		DTW.DTW_HORREA 
	cDML += " FROM " + RetSQLName("DTW") + " DTW"
	cDML += " WHERE 
	cDML += "		DTW.DTW_FILIAL = '" + xFilial("DTW") + "'"
	cDML += "	   	AND"                   
	cDML += "		DTW.DTW_DATREA BETWEEN '" + cFrom + "' AND '" + cTo + "'"              
	cDML += "		AND" 
	cDML += " 		DTW.DTW_STATUS = '2'
	cDML += "		AND" 
	cDML += "	   	DTW.D_E_L_E_T_ = ''"   	 	 

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
	TcSetField( ::cFlow, "DTW_DATREA", "D", 8, 0 )   
	TcSetField( ::cFlow, "DTW_DATPRE", "D", 8, 0 )   
Return ::cFlow