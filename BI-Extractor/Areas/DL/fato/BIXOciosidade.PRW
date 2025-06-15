#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXOCIOSIDADE.CH"

REGISTER EXTRACTOR HOB 

#DEFINE BIX_TODAY 	Date()
#DEFINE BIX_NOW 	Substr( Time(), 1, 2 ) + Substr( Time(), 4, 2 )

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOciosidade
A tabela fato Vendas apresenta informações dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Class BIXOciosidade from BIXEntity
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
Method New() Class BIXOciosidade
	_Super:New( FACT, "HOB", STR0001, "DTR", { DL } ) //"Ociosidade de Veículo"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXOciosidade 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOB_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HOB_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HOB_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"	
	oModel:AddField( "HOB_FILBAS"	,	"C",	32, 00, .T., "HO9" ) //"Filial Base"
	oModel:AddField( "HOB_VEICLO"	,	"C",	32, 00, .T., "HHZ" ) //"Veículo"
	oModel:AddField( "HOB_DATA"		,	"D",	08, 00, .F., "HK2" ) //"Data de Chegada do Veículo"
	oModel:AddField( "HOB_DTSAID"	, 	"D", 	08, 00	) //Data de Saída do Veículo
	
	oModel:AddField( "HOB_HORACH"	, 	"C", 	10, 00	) //Hora de Chegada do Veículo
	oModel:AddField( "HOB_HORASA"	, 	"C", 	10, 00	) //Hora de Saída do Veículo
	oModel:AddField( "HOB_CONCLU"	, 	"C", 	01, 00	) //Concluído  
	oModel:AddField( "HOB_TEMPO"	, 	"N", 	10, 00	) //Tempo de Ociosidade em minutos      

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXOciosidade
    Local aVehicle 			:= {}
    Local nVehicle			:= 0  
    Local nDayToMinute 		:= 0  
    Local nHourToMinute		:= 0   
    Local nMinute      		:= 0
    Local dDateDeparture	:= Nil
    Local cTimeDeparture	:= ""  
    Local lComplete			:= .F. 
    Local dLastExtraction	:= BIXPerFinal( "HOB" )  
   	Local cFlow 			:= ""
	
   	Private cSubTemp	:= GetNextAlias()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! ( cFlow )->( Eof() ) 
 	    aVehicle := {}
 	    
 	    If ( ! Empty( (cFlow)->DTR_CODVEI ), aAdd( aVehicle, (cFlow)->DTR_CODVEI ), )          
  	    If ( ! Empty( (cFlow)->DTR_CODRB1 ), aAdd( aVehicle, (cFlow)->DTR_CODRB1 ), )     	    
  	    If ( ! Empty( (cFlow)->DTR_CODRB2 ), aAdd( aVehicle, (cFlow)->DTR_CODRB2 ), )      	    
	 	
	 	//-------------------------------------------------------------------
		// Itera por todos os registros do sub-fluxo. 
		//-------------------------------------------------------------------      
		For nVehicle := 1 To Len( aVehicle )
			
			//-------------------------------------------------------------------
			// Identifica o status do processo de chegada e saída. 
			//-------------------------------------------------------------------     
		 	BIXSubFlow( cSubTemp, aVehicle[nVehicle], (cFlow)->DTW_FILORI , (cFlow)->DTW_DATREA, (cFlow)->DTW_HORREA )
			lComplete := ! ( cSubTemp )->( Eof() ) 
		
			//-------------------------------------------------------------------
			// Identifica a data e hora de saída para a nova viagem. 
			//------------------------------------------------------------------- 		
			dDateDeparture := If ( lComplete, (cSubTemp)->DTW_DATREA, BIX_TODAY )
			cTimeDeparture := If ( lComplete, (cSubTemp)->DTW_HORREA, BIX_NOW )

	 		//-------------------------------------------------------------------	 				
			// São consideradas informações em que a data da realização da viajem 
			// encontre-se entre o período indicado para extração ou que a data de 
			// saída para a nova viagem seja maior que a última extração 
			// realizada, desde que a data da realização da viagem (DTW_DATREA) seja 
			// maior ou igual ao conteúdo do parâmetro BIXDTOCIO
			//-------------------------------------------------------------------
 	   		If ( ( (cFlow)->DTW_DATREA >= SToD( cFrom ) .And. (cFlow)->DTW_DATREA <= SToD( cTo ) ) .Or. dDateDeparture > dLastExtraction )		
		 		//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 
				oRecord:Init()

				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "DA3_COD"	, cBIStr( aVehicle[nVehicle] ) )

				//-------------------------------------------------------------------
				// Lookups.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HOB_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
				oRecord:SetValue( "HOB_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HOB_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HOB_VEICLO" 	, oSeeker:Seek( "HHZ", { aVehicle[nVehicle] } ) )

		  		//-------------------------------------------------------------------
				// ...e os lookups sem validação. 
				//-------------------------------------------------------------------  
				If ( DA3->( DBSeek( xFilial("DA3") + aVehicle[nVehicle] ) ) ) 
				 	oRecord:SetValue( "HOB_FILBAS" , oSeeker:Seek( "HO9", { ( cFlow )->DTW_FILORI } ) )	
				Else
					oRecord:SetValue( "HOB_FILBAS" , "_" )
				EndIf
	
		 	 	//-------------------------------------------------------------------
				// Grava a Data de Saída do Veículo e Hora de Saída do Veículo. 
				//------------------------------------------------------------------- 		
	 			oRecord:SetValue( "HOB_DTSAID" , dDateDeparture )
	 			oRecord:SetValue( "HOB_HORASA" , cTimeDeparture )
		 	   
		 		//-------------------------------------------------------------------
				// Grava a Data de Chegada do Veículo e Hora de Chegada do Veículo. 
				//-------------------------------------------------------------------   	    
		 		oRecord:SetValue( "HOB_DATA"  	, (cFlow)->DTW_DATREA )
				oRecord:SetValue( "HOB_HORACH" 	, (cFlow)->DTW_HORREA )
		 		        
		 	 	//-------------------------------------------------------------------
				// Grava o  Tempo de Ociosidade . 
				//-------------------------------------------------------------------  
				nDayToMinute   			:= ( nBIVal( oRecord:GetValue( "HOB_DTSAID" ) - oRecord:GetValue( "HOB_DATA" ) ) ) * 1440 
		      	nHourToMinute  			:= ( nBIVal( Substr( oRecord:GetValue( "HOB_HORASA"), 1, 2 ) ) - nBIVal( Substr( oRecord:GetValue( "HOB_HORACH"), 1, 2 ) ) ) * 60
		      	nMinute        			:= ( nBIVal( Substr( oRecord:GetValue( "HOB_HORASA"), 3, 4 ) ) - nBIVal( Substr( oRecord:GetValue( "HOB_HORACH"), 3, 4 ) ) )  
		
		 		oRecord:SetValue( "HOB_TEMPO" , ( nDayToMinute + nHourToMinute + nMinute ) )
		 		
		 	 	//-------------------------------------------------------------------
				// Grava se o rocesso de chegada e saída foi concluído. 
				//-------------------------------------------------------------------  
		 		oRecord:SetValue( "HOB_CONCLU" , If( lComplete, "S", "N" ) )
				
				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
	 		EndIf
	 		
	 		If ! ( Select( cSubTemp ) == 0 )
	 			( cSubTemp )->( DBCloseArea() ) 
	 		EndIf 	
      	Next nVehicle
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXOciosidade
	Local nInterval		:= BIXParInfo( "BIX_DTOCIO", "N", 0 ) 
	Local cInterval		:= DToS( SToD( cTo ) - ( nBIVal( nInterval ) * ( 30 ) ) )   
	Local cDML 			:= ""  
	
	//-------------------------------------------------------------------
	// Define a data inicial da extração de acordo com o BIXDTOCIO. 
	//-------------------------------------------------------------------                    
	cFrom := If ( cFrom > cInterval, cInterval, cFrom )		

	cDML += " SELECT DTW_DATREA, DTW_HORREA, DTW_FILORI, DTW_VIAGEM, "
	cDML += " 		DTR_CODVEI, DTR_CODRB1, DTR_CODRB2" 
	cDML += " FROM " 
	cDML += 		RetSQLName("DTR") + " DTR, "
	cDML +=  		RetSQLName("DTW") + " DTW "   
	cDML += " WHERE DTR.DTR_FILIAL = '" + xFilial("DTR") + "'"
	cDML += "	   	AND DTR_FILORI  = DTW_FILORI" 
	cDML += " 		AND DTR_VIAGEM = DTW_VIAGEM" 
	cDML += " 		AND DTR.D_E_L_E_T_ = ''"	
	cDML += " 		AND DTW_FILIAL = '" + xFilial("DTW") + "'"  
	cDML += "	   	AND DTW_DATREA BETWEEN '" + cFrom + "' AND '" + cTo + "'"      
	cDML += "	   	AND DTW_STATUS = '2'"
	cDML += " 		AND DTW_ATIVID = '" + GetMv("MV_ATIVCHG") + "'"
	cDML += " 		AND DTW.D_E_L_E_T_ = ''" 
                 
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
	
Return ::cFlow

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSubFlow
•	A Data e Hora de Saída do Veículo é definida a partir da primeira 
DTW_DATREA após a data de chegada do veículo tratada no fluxo principal. 
O registro é definido como saída de veículo quando o campo de atividade 
(DTW_ATIVID)possui conteúdo igual ao conteúdo do parâmetro padrão do 
MV_ATIVSAI. 

@param cVeiculo 	Veículo Ocioso. 
@param cFilOri	 	Filial de Origem.
@param dDataIni	Data de início da Ociosidade
@param cHoraIni	Hora de início da Ociosidade 

@author  Tamara Clemente
@version P12 
@since   25/08/2014  
/*/
//-------------------------------------------------------------------
Static Function BIXSubFlow( cSubTemp, cVeiculo, cFilOri, dDataIni, cHoraIni ) 
	Local cFlow 		:= ""
	
	cFlow += " SELECT " 
	cFlow += "		DTW.DTW_DATREA, "
	cFlow += "		DTW.DTW_HORREA " 
	cFlow += " FROM " 
	cFlow += 		RetSQLName("DTR") + " DTR, "
	cFlow +=  		RetSQLName("DTW") + " DTW "   
	cFlow += " WHERE "
	cFlow += "		DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
	cFlow += "	   	AND "
	cFlow += "		( "
	cFlow += "			DTR.DTR_CODVEI = '" + cVeiculo + "' "
	cFlow += "			OR "
	cFlow += "			DTR.DTR_CODRB1 = '" + cVeiculo + "' "
	cFlow += "			OR "
	cFlow += "			DTR.DTR_CODRB2 = '" + cVeiculo + "' "
	cFlow += "		) "
	cFlow += "	   	AND "
	cFlow += "		DTR.D_E_L_E_T_ = '' "
	cFlow += "		AND "
	cFlow += "		DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
	cFlow += "		AND "	
	cFlow += "		DTW.DTW_FILORI = '" + cFilOri + "' "
	cFlow += "		AND "
	cFlow += "		DTW.DTW_VIAGEM = DTR.DTR_VIAGEM "
	cFlow += "		AND "
	cFlow += "		DTW.DTW_ATIVID = '" + GetMv("MV_ATIVSAI") + "' "
	cFlow += "		AND "
	cFlow += "		( "
	cFlow += "			DTW.DTW_DATREA > '" + DToS(dDataIni) + "' "
	cFlow += "			OR "
	cFlow += "			( "
	cFlow += "				DTW.DTW_DATREA = '" + DToS(dDataIni) + "' "
	cFlow += "				AND "
	cFlow += "				DTW.DTW_HORREA > '" + cHoraIni + "' "
	cFlow += "			) "
	cFlow += "		) "
	cFlow += "		AND "
	cFlow += "		DTW.D_E_L_E_T_ = '' "	
	cFlow += "		ORDER BY "
	cFlow += "			DTW.DTW_DATREA, "
	cFlow += "			DTW.DTW_HORREA"  
      
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cFlow := ChangeQuery( cFlow )  

	
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cFlow ), cSubTemp, .T., .F. )

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( cSubTemp, "DTW_DATREA", "D", 8, 0 )      
Return Nil