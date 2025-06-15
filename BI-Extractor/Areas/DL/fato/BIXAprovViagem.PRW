#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXAPROVVIAGEM.CH"

REGISTER EXTRACTOR HOD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAprovViagem
A tabela fato Devolução de Vendas apresenta informações relacionadas as 
devoluções das vendas, como valores e quantidades devolvidas e impostos.

@author  Helio Leal
@since   09/05/2017
/*/
//-------------------------------------------------------------------
Class BIXAprovViagem from BIXEntity
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
Method New() Class BIXAprovViagem
	_Super:New( FACT, "HOD", STR0001, "DTQ", { DL } ) //"Aproveitamento de Viagem"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author Helio Leal  
@since   09/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXAprovViagem
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOD_EMPRES"	,	"C",	32,	 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HOD_ESTABL"	,	"C",	32,	 00, .T., "HKK" ) //"Estabelecimento""
	oModel:AddField( "HOD_UNDNEG"	,	"C",	32,	 00, .T., "HJ1" ) //"Unidade de Negócio"	
	oModel:AddField( "HOD_ROTA"		,	"C",	32,	 00, .T., "HGI") //"Rota"
	oModel:AddField( "HOD_SERTRA"	,	"C",	32,	 00, .T., "HO1") //"Serviço de Transporte"
	oModel:AddField( "HOD_TIPTRA"	,	"C",	32,	 00, .T., "HHX") //"Tipo Transporte"
	oModel:AddField( "HOD_VIAGEM"	,	"C",	32,	 00, .T., "HO7") //"Viagem"	
	oModel:AddField( "HOD_DATA"		, 	"D",	08,	 00, .F., "HK2" ) //"Período"
	                                                  
	oModel:AddField( "HOD_PESO"		,	"N",	18,	 04 ) //Peso da Viagem
	oModel:AddField( "HOD_PESOM3"	,	"N",	18,	 04 ) // Peso da Viagem em M³
	oModel:AddField( "HOD_CPDADE"	,	"N",	18,	 04 ) // Capacidade da Viagem	
	oModel:AddField( "HOD_CPDAM3"	,	"N",	18,	 04 ) // Capacidade da Viagem em M³


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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXAprovViagem
	Local cFlow		:= ""
	
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
		oRecord:SetValue( "DA8_COD"	, (cFlow)->DTQ_ROTA )
		oRecord:SetValue( "DTQ_VIAGEM"	, (cFlow)->DTQ_VIAGEM )	
		
		//-------------------------------------------------------------------
		// Lookups.
		//-------------------------------------------------------------------	
		oRecord:SetValue( "HOD_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
		oRecord:SetValue( "HOD_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
		oRecord:SetValue( "HOD_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
		oRecord:SetValue( "HOD_VIAGEM" 	, oSeeker:Seek( "HO7", { (cFlow)->DTQ_VIAGEM } ) )
		oRecord:SetValue( "HOD_ROTA" 	, oSeeker:Seek( "HGI", { (cFlow)->DTQ_ROTA } ) )

  		//-------------------------------------------------------------------
		// ...e os lookups sem validação. 
		//-------------------------------------------------------------------  		
 	   	oRecord:SetValue( "HOD_SERTRA" , ( cFlow )->DTQ_SERTMS )
   		oRecord:SetValue( "HOD_TIPTRA" , ( cFlow )->DTQ_TIPTRA )

   		//-------------------------------------------------------------------
		// Grava o Peso da Viagem e o Peso da Viagem em M³. 
		//-------------------------------------------------------------------   			
 		oRecord:SetValue( "HOD_PESO"	, ( cFlow )->PESO )
 	 	oRecord:SetValue( "HOD_PESOM3"	, ( cFlow )->PESOM3 )
 	 	
    	//-------------------------------------------------------------------
		// Grava a Capacidade da Viagem e Capacidade da Viagem em M³.  
		//-------------------------------------------------------------------  	 
		If ! ( Empty( ( cFlow )->DTR_CODRB1 ) )   
			//-------------------------------------------------------------------
			// Cavalo e mais um ou dois reboques. 
			//------------------------------------------------------------------- 
 			If ( DA3->( DBSeek( xFilial("DA3") + ( cFlow )->DTR_CODRB1 ) ) )		
    			oRecord:SetValue( "HOD_CPDADE", DA3->DA3_CAPACM  )
        		oRecord:SetValue( "HOD_CPDAM3", ( DA3->DA3_LARINT * DA3->DA3_COMINT * DA3->DA3_ALTINT ) )
    		EndIf  

        	If ! Empty( ( cFlow )->DTR_CODRB2 )  
        		If ( DA3->( DBSeek( xFilial("DA3") + ( cFlow )->DTR_CODRB2 ) ) )		
        			oRecord:SetValue( "HOD_CPDADE" , DA3->DA3_CAPACM   )
        			oRecord:SetValue( "HOD_CPDAM3" , ( DA3->DA3_LARINT * DA3->DA3_COMINT * DA3->DA3_ALTINT )   )
        		EndIf 
          	EndIf 
		Else  
			//-------------------------------------------------------------------
			// Carro único com capacidade de carga. 
			//------------------------------------------------------------------- 
  			If ( DA3->( DBSeek( xFilial("DA3") + ( cFlow )->DTR_CODVEI ) ) )		
        		oRecord:SetValue( "HOD_CPDADE" , DA3->DA3_CAPACM   )
        		oRecord:SetValue( "HOD_CPDAM3" , ( DA3->DA3_LARINT * DA3->DA3_COMINT * DA3->DA3_ALTINT )   )
        	EndIf 
     	EndIf

   	 	//-------------------------------------------------------------------
		// Grava os campos data. 
		//------------------------------------------------------------------- 	
   		oRecord:SetValue( "HOD_DATA" , ( cFlow )->DTQ_DATINI )
		
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXAprovViagem
	Local cDML := "" 

	cDML += " SELECT" 
	cDML += " 		DTQ.DTQ_FILIAL," 
	cDML += "		DTQ.DTQ_FILORI," 
	cDML += "		DTQ.DTQ_SERTMS," 
	cDML += "		DTQ.DTQ_TIPTRA," 
	cDML += "		DTQ.DTQ_ROTA," 
	cDML += "		DTQ.DTQ_VIAGEM," 
	cDML += "		DTQ.DTQ_DATINI," 
	cDML += "		DTR.DTR_CODVEI," 
	cDML += "		DTR.DTR_CODRB1," 
	cDML += "		DTR.DTR_CODRB2, " 		
	cDML += " 		(
	cDML += " 			SELECT" 
	cDML += " 				SUM( DT6_PESO )"
	cDML += " 			FROM " + RetSQLName("DUD") + " DUD"
	cDML += " 			LEFT JOIN " + RetSQLName("DT6") + " DT6"
	cDML += " 			ON "
	cDML += "	   			DT6.DT6_FILIAL  = '"  + xFilial("DT6") + "'" 
	cDML += " 				AND" 
	cDML += " 				DT6.DT6_FILDOC	= DUD.DUD_FILDOC" 
	cDML += " 				AND" 
	cDML += " 				DT6.DT6_DOC		= DUD.DUD_DOC" 
	cDML += " 				AND"
	cDML += " 				DT6.DT6_SERIE	= DUD.DUD_SERIE"
	cDML += " 				AND" 
	cDML += " 				DT6.D_E_L_E_T_ = ''"			
	cDML += " 			"
	cDML += " 			WHERE"  
	cDML += "	   			DUD.DUD_FILIAL  = '"  + xFilial("DUD") + "'" 
	cDML += " 				AND" 	
	cDML += " 				DUD.DUD_FILORI = DTQ.DTQ_FILORI"
	cDML += " 				AND" 
	cDML += " 				DUD.DUD_VIAGEM = DTQ.DTQ_VIAGEM" 
	cDML += " 				AND" 
	cDML += " 				DUD.D_E_L_E_T_ = ''"
	cDML += " 		)  AS PESO"
	cDML += " 		,"  
	cDML += " 		("
	cDML += " 			SELECT" 
	cDML += " 				SUM( DT6_PESOM3 )"
	cDML += " 			FROM " + RetSQLName("DUD") + " DUD"
	cDML += " 			LEFT JOIN " + RetSQLName("DT6") + " DT6"
	cDML += " 			ON " 
	cDML += "	   			DT6.DT6_FILIAL  = '"  + xFilial("DT6") + "'" 
	cDML += " 				AND"	
	cDML += " 				DT6.DT6_FILDOC	= DUD.DUD_FILDOC" 
	cDML += " 				AND"
	cDML += " 				DT6.DT6_DOC		= DUD.DUD_DOC" 
	cDML += " 				AND"
	cDML += " 				DT6.DT6_SERIE	= DUD.DUD_SERIE	"
	cDML += " 				AND" 
	cDML += " 				DT6.D_E_L_E_T_ = ''"
	cDML += " 			"
	cDML += " 			WHERE"  
	cDML += "	   			DUD.DUD_FILIAL  = '"  + xFilial("DUD") + "'" 
	cDML += " 				AND" 	
	cDML += " 				DUD.DUD_FILORI = DTQ.DTQ_FILORI"
	cDML += " 				AND" 
	cDML += " 				DUD.DUD_VIAGEM = DTQ.DTQ_VIAGEM" 
	cDML += " 				AND" 
	cDML += " 				DUD.D_E_L_E_T_ = ''"
	cDML += " 		) AS PESOM3"
	cDML += " FROM " + RetSQLName("DTQ") + " DTQ" 	
	cDML += " LEFT JOIN " + RetSQLName("DTR") + " DTR" 
	cDML += " ON "
	cDML += "		DTR.DTR_FILIAL = '"  + xFilial("DTR") + "'" 
	cDML += "		AND" 
	cDML += "		DTR.DTR_FILORI = DTQ.DTQ_FILORI" 
	cDML += "		AND" 
	cDML += "		DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM" 
	cDML += "		AND" 
	cDML += "		DTR.D_E_L_E_T_ = ''"	
	cDML += " " 
	cDML += " LEFT JOIN " + RetSQLName("DA3") + " DA3"
	cDML += " ON "
	cDML += "		DA3.DA3_FILIAL  = '" + xFilial("DA3") + "'"  
	cDML += "		AND"
	cDML += "		("
	cDML += "			DA3.DA3_COD = DTR.DTR_CODVEI" 
	cDML += "			OR" 
	cDML += "			DA3.DA3_COD = DTR.DTR_CODRB1" 
	cDML += "			OR" 
	cDML += "			DA3.DA3_COD = DTR.DTR_CODRB2"
	cDML += "		)"
	cDML += "		AND" 
	cDML += "		DA3.D_E_L_E_T_ = ''"		
	cDML += " "	
	cDML += " WHERE "  
	cDML += "		DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "'"
	cDML += "		AND"                 
	cDML += "		DTQ.DTQ_DATINI BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cDML += "		AND" 
	cDML += "		DTQ.D_E_L_E_T_ = ''"   
  	 
	 
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
	TcSetField( ::cFlow, "DTQ_DATINI", "D", 8, 0 )  
Return ::cFlow