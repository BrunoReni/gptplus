#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPENDENCIA.CH"

REGISTER EXTRACTOR HOC 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPendencia
A tabela fato Vendas apresenta informações dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Class BIXPendencia from BIXEntity
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
Method New() Class BIXPendencia
	_Super:New( FACT, "HOC", STR0001, "DUA", { DL } ) //"Pendências"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPendencia 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOC_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HOC_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HOC_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HOC_ROTA"		,	"C",	32, 00, .T., "HGI" ) //"Rota"
	oModel:AddField( "HOC_TIPTRA"	,	"C",	32, 00, .T., "HHX" ) //"Tipo Transporte"
	oModel:AddField( "HOC_SERTRA"	,	"C",	32, 00, .T., "HO1" ) //"Serviço de Transporte"	
	oModel:AddField( "HOC_TIPOCO"	,	"C",	32, 00, .T., "HO8" ) //"Tipo Ocorrência"	
	oModel:AddField( "HOC_TIPPEN"	,	"C",	32, 00, .T., "HHY" ) //"Tipo Pendência"	
	oModel:AddField( "HOC_VEICLO"	,	"C",	32, 00, .T., "HHZ" ) //"Veículo"
	oModel:AddField( "HOC_REGTRA"	,	"C",	32, 00, .T., "HO0" ) //"Região de Transporte de Origem"
	oModel:AddField( "HOC_REGDES"	,	"C",	32, 00, .T., "HO0" ) //"Região de Transporte de Destino"
	oModel:AddField( "HOC_VIAGEM"	,	"C",	32, 00, .T., "HO7" ) //"Viagem"
	oModel:AddField( "HOC_DATA"		,	"D",	08, 00, .F., "HK2" ) //"Data da Ocorrência"
	
	oModel:AddField( "HOC_VOLUME"	, 	"N", 	18, 04	) //Volume     
	oModel:AddField( "HOC_PESO"		, 	"N", 	18, 04	) //Peso        
	oModel:AddField( "HOC_QTDOCO"	, 	"N", 	04, 00	) //Qtde Ocorrências

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPendencia
	Local cFlow := ""

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
		oRecord:SetValue( "DA3_COD"		, (cFlow)->DTR_CODVEI )
		oRecord:SetValue( "DA8_COD"		, (cFlow)->DTQ_ROTA )
		oRecord:SetValue( "DUY_GRPVEN"	, (cFlow)->DA8_CDRORI )
		oRecord:SetValue( "DTQ_VIAGEM"	, (cFlow)->DTQ_VIAGEM )

		//-------------------------------------------------------------------
		// Lookups.
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOC_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
		oRecord:SetValue( "HOC_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
		oRecord:SetValue( "HOC_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
		oRecord:SetValue( "HOC_ROTA" 	, oSeeker:Seek( "HGI", { (cFlow)->DTQ_ROTA } ) )
		oRecord:SetValue( "HOC_VEICLO" 	, oSeeker:Seek( "HHZ", { (cFlow)->DTR_CODVEI } ) )
		oRecord:SetValue( "HOC_REGTRA" 	, oSeeker:Seek( "HO0", { (cFlow)->DA8_CDRORI } ) )
		oRecord:SetValue( "HOC_REGDES" 	, oSeeker:Seek( "HO0", { (cFlow)->DUD_CDRDES } ) )
		oRecord:SetValue( "HOC_VIAGEM" 	, oSeeker:Seek( "HO7", { (cFlow)->DTQ_VIAGEM } ) )
	
  		//-------------------------------------------------------------------
		// ...e os lookups sem validação. 
		//-------------------------------------------------------------------  
		oRecord:SetValue( "HOC_TIPTRA" , (cFlow)->DTQ_TIPTRA ) 
   		oRecord:SetValue( "HOC_SERTRA" , (cFlow)->DUA_SERTMS )
   		oRecord:SetValue( "HOC_TIPOCO" , (cFlow)->DT2_TIPOCO )
    	oRecord:SetValue( "HOC_TIPPEN" , (cFlow)->DT2_TIPPND )
    		  		
   		//-------------------------------------------------------------------
		// Grava o Volume, Peso e Qtd Ocorrências. 
		//-------------------------------------------------------------------   			
 		oRecord:SetValue( "HOC_VOLUME"	, (cFlow)->DUA_QTDOCO )
  		oRecord:SetValue( "HOC_PESO"  	, (cFlow)->DUA_PESOCO )
   		oRecord:SetValue( "HOC_QTDOCO"  , 1 )
   		  	 
   	 	//-------------------------------------------------------------------
		// Grava os campos data. 
		//------------------------------------------------------------------- 	
   		oRecord:SetValue( "HOC_DATA" , (cFlow)->DUA_DATOCO )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação. 
		//-------------------------------------------------------------------				
		oOutput:Send( oRecord ) 
		
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXPendencia
	Local cDML 	:= ""  

	cDML += " SELECT" 
	cDML += " 		DUA.DUA_FILORI," 
	cDML += " 		DUA.DUA_VIAGEM," 
	cDML += " 		DUA.DUA_SERTMS,"
	cDML += " 		DUA.DUA_DATOCO,"
	cDML += " 		DUA.DUA_QTDOCO," 
	cDML += " 		DUA.DUA_PESOCO," 
	cDML += " 		DT2.DT2_TIPOCO," 
	cDML += " 		DT2.DT2_TIPPND," 
	cDML += " 		("
	cDML += " 			SELECT "
	cDML += " 				DTR.DTR_CODVEI " 
	cDML += " 			FROM " + RetSQLName("DTR") + " DTR "
	cDML += " 			WHERE" 
	cDML += "				DTR.DTR_FILIAL = '" + xFilial("DTR") + "'"
	cDML += "				AND" 
	cDML += " 				DTR.DTR_FILORI = DUA.DUA_FILORI"
	cDML += " 				AND"
	cDML += " 				DTR.DTR_VIAGEM = DUA.DUA_VIAGEM"
	cDML += " 				AND"
	cDML += " 				DTR.D_E_L_E_T_ = ''"
	cDML += " 		) DTR_CODVEI,"
	cDML += " 		("
	cDML += " 			SELECT "
	cDML += " 		   		DTQ.DTQ_TIPTRA" 
	cDML += " 			FROM " + RetSQLName("DTQ") + " DTQ "
	cDML += " 			WHERE" 
	cDML += "				DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	cDML += "				AND" 
	cDML += " 				DTQ.DTQ_FILORI = DUA.DUA_FILORI"
	cDML += " 				AND"
	cDML += " 				DTQ.DTQ_VIAGEM = DUA.DUA_VIAGEM"
	cDML += " 				AND"
	cDML += " 				DTQ.D_E_L_E_T_ = ''"
	cDML += " 		) DTQ_TIPTRA,"
	cDML += " 		("
	cDML += " 			SELECT "
	cDML += " 		   		DTQ.DTQ_ROTA"  
	cDML += " 			FROM " + RetSQLName("DTQ") + " DTQ "
	cDML += " 			WHERE" 
	cDML += "				DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	cDML += "				AND" 
	cDML += " 				DTQ.DTQ_FILORI = DUA.DUA_FILORI"
	cDML += " 				AND"
	cDML += " 				DTQ.DTQ_VIAGEM = DUA.DUA_VIAGEM"
	cDML += " 				AND"
	cDML += " 				DTQ.D_E_L_E_T_ = ''"
	cDML += " 		) DTQ_ROTA,"
	cDML += " 		("
	cDML += " 			SELECT "
	cDML += " 		   		DTQ.DTQ_VIAGEM  "  
	cDML += " 			FROM " + RetSQLName("DTQ") + " DTQ "
	cDML += " 			WHERE" 
	cDML += "				DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	cDML += "				AND" 
	cDML += " 				DTQ.DTQ_FILORI = DUA.DUA_FILORI"
	cDML += " 				AND"
	cDML += " 				DTQ.DTQ_VIAGEM = DUA.DUA_VIAGEM"
	cDML += " 				AND"
	cDML += " 				DTQ.D_E_L_E_T_ = ''"
	cDML += " 		) DTQ_VIAGEM,"
	cDML += " 		("
	cDML += " 			SELECT "
	cDML += " 		   		DUD.DUD_CDRDES"  
	cDML += " 			FROM " + RetSQLName("DUD") + " DUD "
	cDML += " 			WHERE  
	cDML += "				DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
	cDML += "				AND" 
	cDML += " 				DUD.DUD_FILORI = DUA.DUA_FILORI"
	cDML += " 				AND"
	cDML += " 				DUD.DUD_VIAGEM = DUA.DUA_VIAGEM"
	cDML += " 				AND"
	cDML += " 				DUD.DUD_DOC = DUA.DUA_DOC"
	cDML += " 				AND"
	cDML += " 				DUD.D_E_L_E_T_ = ''"
	cDML += " 		) DUD_CDRDES,"
	cDML += " 		("
	cDML += " 			SELECT "
	cDML += " 		   		DA8.DA8_CDRORI"
	cDML += " 			FROM " + RetSQLName("DA8") + " DA8 "
	cDML += " 			LEFT JOIN " + RetSQLName("DTQ") + " DTQ "
	cDML += " 			ON"   
	cDML += "				DA8.DA8_FILIAL = '" + xFilial("DA8") + "'"
	cDML += "				AND" 
	cDML += " 				DA8.DA8_COD = DTQ.DTQ_ROTA"
	cDML += " 				AND"
	cDML += " 				DA8.D_E_L_E_T_ = ''"
	cDML += " 			WHERE" 
	cDML += "				DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	cDML += "				AND" 
	cDML += " 				DTQ.DTQ_FILORI = DUA.DUA_FILORI"
	cDML += " 				AND"
	cDML += " 				DTQ.DTQ_VIAGEM = DUA.DUA_VIAGEM"
	cDML += " 				AND"
	cDML += " 				DTQ.D_E_L_E_T_ = ''"
	cDML += " 		) DA8_CDRORI"  
	cDML += " FROM " 
	cDML +=		RetSQLName("DUA") + " DUA, " 
	cDML +=		RetSQLName("DT2") + " DT2 " 	
	cDML += " WHERE " 
	cDML += "		DUA.DUA_FILIAL = '" + xFilial("DUA") + "'"
	cDML += "		AND" 
	cDML += "		DT2.DT2_FILIAL = '" + xFilial("DT2") + "'"
	cDML += "		AND"   
	cDML += "		DUA.DUA_CODOCO = DT2.DT2_CODOCO" 
	cDML += "		AND" 
	cDML += "		DT2.DT2_TIPOCO IN('06','09')" 
	cDML += "		AND"
	cDML += "		DT2.DT2_TIPPND IN('01','02','03')"    
	cDML += "		AND"         
	cDML += "		DUA.DUA_DATOCO BETWEEN '" + cFrom + "' AND '" + cTo + "'"              
	cDML += "		AND" 
	cDML += "		DUA.D_E_L_E_T_ = ''" 
	cDML += "		AND" 
	cDML += "		DT2.D_E_L_E_T_ = ''"   

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
	TcSetField( ::cFlow, "DUA_DATOCO", "D", 8, 0 ) 
Return ::cFlow