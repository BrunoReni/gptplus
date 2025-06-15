#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXATIVUSUARIO.CH"

REGISTER EXTRACTOR HSF

#DEFINE OPENED		"|1|2|4|5|6|7|"   	
#DEFINE CLOSED 		"|3|8|"
#DEFINE TODAY 		Date() 
#DEFINE NOW 		Substr( Time(), 1, 5 )

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAtivUsuario
A tabela fato Vendas apresenta informações dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Class BIXAtivUsuario from BIXEntity
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
@since   26/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXAtivUsuario
	_Super:New( FACT, "HSF", STR0001, "AOF", { CRM } ) //"Atividades"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXAtivUsuario 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HSF_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HSF_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HSF_REPRES"	,	"C",	32, 00, .T., "HJC" ) //"Representante"	
	oModel:AddField( "HSF_STTATV"	,	"C",	32, 00, .T., "HSK" ) //"Status da Atividade"	
	oModel:AddField( "HSF_TIPATV"	,	"C",	32, 00, .T., "HSL" ) //"Tipo de Atividade"	
	oModel:AddField( "HSF_USUARI"	,	"C",	32, 00, .T., "HSQ" ) //"Usuário" 			
	oModel:AddField( "HSF_UNICOM"	,	"C",	32, 00, .T., "HSP" ) //"Unidade Comercial"	
	oModel:AddField( "HSF_EQUVEN"	,	"C",	32, 00, .T., "HSO" ) //"Equipe de Venda"	
	oModel:AddField( "HSF_DTAINI"	,	"D",	08, 00, .F., "HK2" ) //"Data de Início"
	oModel:AddField( "HSF_DTAFIM"	, 	"D", 	08, 00	) //Data de Término

	oModel:AddField( "HSF_HORAIN"	, 	"C", 	08, 00	) //Hora de Início
	oModel:AddField( "HSF_HORAFI"	, 	"C", 	08, 00	) //Hora de Término
	oModel:AddField( "HSF_QTATIV"	, 	"N", 	04, 00	) //Quantidade de Atividades
	oModel:AddField( "HSF_QTMINT"	, 	"N", 	10, 00	) //Duração em minutos 

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
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXAtivUsuario
	Local cFlow				:= ""
    Local nDayToMinute 		:= 0  
    Local nHourToMinute		:= 0   
    Local nMinute      		:= 0 
    Local dLastExtraction	:= BIXPerFinal( "HSF" ) 

   	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )
		
	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! (cFlow)->( Eof() )
 		//-------------------------------------------------------------------
 		// No fluxo principal de dados são consideradas as informações das Atividades 
 		// (AOF) com data de início da atividade (AOF_DTINIC) dentro do período indicado 
 		// para extração. Além das atividades dentro do período indicado, também são 
 		// consideradas as atividades abertas (AOF_STATUS com valores 1, 2, 4, 5, 6 e 7) 
 		// ou que foram Concluídas (AOF_STATUS com valores 3 e 8) após a última data de extração.
  		//-------------------------------------------------------------------	
 		If ( ( (cFlow)->AOF_DTINIC >= SToD( cFrom ) .And. (cFlow)->AOF_DTINIC <= SToD( cTo ) ) .Or. (cFlow)->AOF_STATUS $ OPENED .Or.;
 		   ( (cFlow)->AOF_STATUS $ CLOSED .And. (cFlow)->AOF_DTFIM >= dLastExtraction ) )
	 	   
	 		//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "ACA_GRPREP"	, (cFlow)->AO3_CODEQP )				
			oRecord:SetValue( "ADK_COD"		, (cFlow)->AO3_CODUND )			
			oRecord:SetValue( "AOF_CODIGO"	, (cFlow)->AOF_CODIGO )
			oRecord:SetValue( "AO3_CODUSR"	, (cFlow)->AOF_CODUSR )
			oRecord:SetValue( "A3_COD"		, (cFlow)->AO3_VEND )
			
			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------	
			oRecord:SetValue( "HSF_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HSF_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HSF_REPRES"	, oSeeker:Seek( "HJC", { (cFlow)->AO3_VEND } ) )
			oRecord:SetValue( "HSF_USUARI" 	, oSeeker:Seek( "HSQ", { (cFlow)->AOF_CODUSR } ) )
			oRecord:SetValue( "HSF_UNICOM" 	, oSeeker:Seek( "HSP", { (cFlow)->AO3_CODUND } ) )
			oRecord:SetValue( "HSF_EQUVEN" 	, oSeeker:Seek( "HSO", { (cFlow)->AO3_CODEQP } ) )

	  		//-------------------------------------------------------------------
			// ...e os lookups sem validação. 
			//-------------------------------------------------------------------  
			oRecord:SetValue( "HSF_STTATV", (cFlow)->AOF_STATUS )
			oRecord:SetValue( "HSF_TIPATV", (cFlow)->AOF_TIPO )
	
	   		//-------------------------------------------------------------------
			// Grava a Quantidade de Atividades. 
			//-------------------------------------------------------------------   			
	 		oRecord:SetValue( "HSF_QTATIV" , 1 )
                      
	   	 	//-------------------------------------------------------------------
			// Grava a data de início e fim da atividade. 
			//------------------------------------------------------------------- 	
	     	oRecord:SetValue( "HSF_DTAINI", (cFlow)->AOF_DTINIC )
	     	oRecord:SetValue( "HSF_DTAFIM", If( Empty( (cFlow)->AOF_DTFIM ), TODAY, (cFlow)->AOF_DTFIM ) )
	     	
	   	 	//-------------------------------------------------------------------
			// Grava a hora de início e fim da atividade. 
			//------------------------------------------------------------------- 	     	
	     	oRecord:SetValue( "HSF_HORAIN", (cFlow)->AOF_HRINIC )
	     	oRecord:SetValue( "HSF_HORAFI", If( Empty( (cFlow)->AOF_HRFIM ), NOW, (cFlow)->AOF_HRFIM ) )
	     	
	  	   	//-------------------------------------------------------------------
			// Grava a Duração - em minutos. 
			//-------------------------------------------------------------------   
			nDayToMinute   			:= ( nBIVal( oRecord:GetValue( "HSF_DTAFIM" ) - oRecord:GetValue( "HSF_DTAINI" ) ) ) * 1440 
			nHourToMinute  			:= ( nBIVal( Substr( oRecord:GetValue( "HSF_HORAFI"), 1, 2 ) ) - nBIVal( Substr( oRecord:GetValue( "HSF_HORAIN"), 1, 2 ) ) ) * 60
			nMinute        			:= ( nBIVal( Substr( oRecord:GetValue( "HSF_HORAFI"), 3, 4 ) ) - nBIVal( Substr( oRecord:GetValue( "HSF_HORAIN"), 3, 4 ) ) )  
	
	   	 	oRecord:SetValue( "HSF_QTMINT", ( nDayToMinute + nHourToMinute + nMinute ) )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		EndIf

 		(cFlow)->( DBSkip() ) 
 	EndDo 

 	//-------------------------------------------------------------------
	// Fecha a área de trabalho temporária. 
	//-------------------------------------------------------------------  		  
 	If ! ( Select( cFlow ) == 0 )
 		( cFlow )->( DBCloseArea() ) 
 	EndIf

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
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXAtivUsuario
	Local nInterval		:= BIXParInfo( "BIX_DIASAT", "N", 0 ) 
	Local cInterval		:= DToS( SToD( cTo ) - ( nBIVal( nInterval ) * ( 30 ) ) )    
	Local cDML    		:= ""  
	
	//-------------------------------------------------------------------
	// Define a data inicial da extração de acordo com o BIXINTREC. 
	//-------------------------------------------------------------------                    
	cFrom := If ( cFrom > cInterval, cInterval, cFrom )	
      
	cDML += " SELECT" 
	cDML += " 		AOF.AOF_STATUS,"
	cDML += " 		AOF.AOF_TIPO,"
	cDML += " 		AOF.AOF_CODIGO," 
	cDML += " 		AOF.AOF_CODUSR,"
	cDML += " 		AOF.AOF_DTINIC,"
	cDML += " 		AOF.AOF_HRINIC,"
	cDML += " 		AOF.AOF_DTFIM,"
	cDML += " 		AOF.AOF_HRFIM,"
	cDML += " 		AO3.AO3_VEND,"
	cDML += " 		AO3.AO3_CODUND,"
	cDML += " 		AO3.AO3_CODEQP" 
	cDML += " FROM " 
	cDML += 		RetSQLName("AOF") + " AOF, "
	cDML +=  		RetSQLName("AO3") + " AO3 "   
	cDML += " WHERE "
	cDML += " 		AO3.AO3_CODUSR = AOF.AOF_CODUSR" 
	cDML += "	   	AND"   
	cDML += "		AO3.AO3_FILIAL = '" + xFilial("AO3") + "'" 
	cDML += "	   	AND"   
	cDML += "		AOF.AOF_FILIAL = '" + xFilial("AOF") + "'"
	cDML += "	   	AND"                   
	cDML += "		AOF.AOF_DTINIC BETWEEN '" + cFrom + "' AND '" + cTo + "'"               
	cDML += "		AND" 	
	cDML += "	   	AOF.D_E_L_E_T_ = ''"   
	cDML += "		AND" 
	cDML += "	   	AO3.D_E_L_E_T_ = ''" 

	//--------------------------------------------------------------
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
	TcSetField( ::cFlow, "AOF_DTINIC"	, "D", 8, 0 )
	TcSetField( ::cFlow, "AOF_DTFIM"	, "D", 8, 0 )  
Return ::cFlow