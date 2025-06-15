#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEVOLUCAO.CH"

REGISTER EXTRACTOR HSS 

#DEFINE CLOSED	"|1|2|"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEvolucao
A tabela fato Vendas apresenta informa��es dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXEvolucao from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Helio Leal
@since   29/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class	 BIXEvolucao
	_Super:New( FACT, "HSS", STR0003, "AIJ", { CRM } ) //"Evolu��o de Venda"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXEvolucao 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HSS_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HSS_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HSS_STTOPO"	,	"C",	32, 00, .T., "HSG" ) //"Status da Oportunidade"	
	oModel:AddField( "HSS_OPOVEN"	,	"C",	32, 00, .T., "HSM" ) //"Oportunidade de Venda"		
	oModel:AddField( "HSS_PROVEN"	,	"C",	32, 00, .T., "HSN" ) //"Processo de Venda"	
	oModel:AddField( "HSS_UNICOM"	,	"C",	32, 00, .T., "HSP" ) //"Unidade Comercial"
	oModel:AddField( "HSS_EQUVEN" 	,	"C",	32, 00, .T., "HSO" ) //"Equipe de Venda"
	oModel:AddField( "HSS_CLIENT"	,	"C",	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HSS_PROSPE"	,	"C",	32, 00, .T., "HSR" ) //"Prospect"			
	oModel:AddField( "HSS_REGIAO"	,	"C",	32, 00, .T., "HJB" ) //"Regi�o"
	oModel:AddField( "HSS_AREA"	 	,	"C",	32, 00, .T., "HOK" ) //"�rea" 	
	oModel:AddField( "HSS_STTEST"	,	"C",	32, 00, .T., "HSJ" ) //"Status do Est�gio" 	

	oModel:AddField( "HSS_DTINIE"	,	"D",	08, 00, .F., "HK2" ) //"Data do In�cio do Est�gio"
	oModel:AddField( "HSS_DTFIME"	, 	"D", 	08, 00	) //Data de Encerramento do Est�gio
	oModel:AddField( "HSS_DTINIO"	, 	"D", 	08, 00	) //Data de In�cio da Oportunidade
	oModel:AddField( "HSS_DTFIMO"	, 	"D", 	08, 00	) //Data de T�rmino da Oportunidade
	
	oModel:AddField( "HSS_HRINIE"	, 	"C", 	08, 00	) //Hora do in�cio do Est�rio				
	oModel:AddField( "HSS_HRFIME"	, 	"C", 	08, 00	) //Hora do Encerramento do Est�gio
	oModel:AddField( "HSS_ULTEST"	, 	"C", 	03, 00	) //�ltimo Est�gio da Oportunidade	
	oModel:AddField( "HSS_QTDADE"	, 	"N", 	04, 00	) //Quantidade
	oModel:AddField( "HSS_QTMINT"	, 	"N", 	10, 00	) //Dura��o em minutos

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

@author  Helio Leal
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXEvolucao
	Local aAlias			:= {} 
	Local aDinamicAlias 	:= {}   
	Local aRegion			:= {} 
	Local cArea			:= ""  
	Local cFlow			:= ""	
	Local dLastExtraction:= BIXPerFinal( "HSS" )
	Local nVlReceita		:= 0
	Local nPercVend		:= 0
	Local cStatus			:= 0
	Local cDateExt		:= Date()
	Local cHoraExt		:= Time()
	Local dDataEnc		:= Nil
	Local nDayToMinute 	:= 0 
	Local nHourToMinute 	:= 0
	Local nMinute 		:= 0
	Local cUltEst			:= ""
	Local cHoraEnc		:= ""
	Local oRegion			:= Nil
	
	//-------------------------------------------------------------------
	// Recupera os par�metros da fato. 
	//-------------------------------------------------------------------
	oRegion	:= BIXRegiao():New()
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! (cFlow)->( Eof() ) 
		aDinamicAlias	:= {}   
 		aRegion       	:= {}  
 		cArea			:= ""
		nVlReceita		:= 0
   		nPercVend		:= 0
   		nDayToMinute 	:= 0 
		nHourToMinute 	:= 0
		nMinute 		:= 0
		cUltEst			:= ""
		cHoraEnc		:= ""

 		//-------------------------------------------------------------------
		// No fluxo principal de dados s�o consideradas as informa��es de cada 
		// item da evolu��o de vendas com data de in�cio entre o per�odo 
		// indicado para extra��o. Al�m destes itens da evolu��o de vendas, 
		// tamb�m s�o considerados todos os itens de evolu��o com status do 
		// est�gio em andamento e em atraso ou que foram encerradas (com valor 
		// 1 ou 2) ap�s a data da �ltima extra��o executada. 
		//-------------------------------------------------------------------  
 		If ( ( (cFlow)->AIJ_DTINIC >= SToD( cFrom ) .And. (cFlow)->AIJ_DTENCE <= SToD( cTo ) ) .Or. Empty((cFlow)->AIJ_STATUS) .Or.;
 		   ( (cFlow)->AIJ_STATUS $ CLOSED .And. (cFlow)->AIJ_DTENCE >= dLastExtraction ) )

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customiza��o.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "AIJ_NROPOR"	, (cFlow)->AD1_NROPOR )
			oRecord:SetValue( "AIJ_REVISA"	, (cFlow)->AD1_REVISA )
			oRecord:SetValue( "AIJ_PROVEN"	, (cFlow)->AD1_PROVEN )
			oRecord:SetValue( "AIJ_STAGE"	, (cFlow)->AD1_STAGE )			
			oRecord:SetValue( "AD1_NROPOR"	, (cFlow)->AD1_NROPOR )
			oRecord:SetValue( "AD1_REVISA"	, (cFlow)->AD1_REVISA )
			oRecord:SetValue( "AC2_PROVEN"	, (cFlow)->AD1_PROVEN )
			oRecord:SetValue( "AC2_STAGE"	, (cFlow)->AD1_STAGE )
			oRecord:SetValue( "ADK_COD"		, (cFlow)->AO3_CODUND )
			oRecord:SetValue( "ACA_GRPREP"	, (cFlow)->AO3_CODEQP )	
	
	 		//-------------------------------------------------------------------
			// Define a data e hora de encerramento 
			//-------------------------------------------------------------------   
	 		dDataEnc := If ( Empty((cFlow)->AIJ_DTENCE), cDateExt, (cFlow)->AIJ_DTENCE )
	 		cHrEnc := If ( Empty((cFlow)->AIJ_HRENCE), cHoraExt, (cFlow)->AIJ_HRENCE )
	 		
	 		Do Case
	 			Case Empty((cFlow)->AIJ_STATUS) .And. DToS((cFlow)->AIJ_DTLIMI) + (cFlow)->AIJ_HRLIMI > dtos(cDateExt) + cHoraExt
	 				cStatus := '1'	//Em andamento
	 			Case Empty((cFlow)->AIJ_STATUS) .And. DToS((cFlow)->AIJ_DTLIMI) + (cFlow)->AIJ_HRLIMI < dtos(cDateExt) + cHoraExt
	 				cStatus := '2'	//Em atraso
				Case (cFlow)->AIJ_STATUS == '1'
	 				cStatus := '3' 	//Encerrado sem atraso		
				Case (cFlow)->AIJ_STATUS == '2'
	 				cStatus := '4'	//Encerrado com atraso
	 		EndCase
	
 			//------------------------------------------------------------------------------
			// Caso a entidade seja o cliente utiliza-se os campos ADY_CODIGO + ADY_LOJA,  
			// caso contr�rio, o campo de cliente ser� preenchido com INDEFINIDO e o campo 
			// de Prospect ter� seu valor preenchido.
			//------------------------------------------------------------------------------
	 		If ( !Empty( (cFlow)->AD1_CODCLI ) ) 
	 			If ( SA1->( DBSeek( xFilial("SA1") + (cFlow)->AD1_CODCLI + (cFlow)->AD1_LOJCLI ) ) )
					oRecord:SetValue( "A1_COD"	, (cFlow)->AD1_CODCLI )
					oRecord:SetValue( "A1_LOJA"	, (cFlow)->AD1_LOJCLI )
					
					oRecord:SetValue( "HSS_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->AD1_CODCLI, (cFlow)->AD1_LOJCLI } ) )						
					oRecord:SetValue( "HSS_AREA"	, oSeeker:Seek( "HOK", { SA1->A1_REGIAO } ) )	
					oRecord:SetValue( "HSS_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) )
	 			EndIf   			
	 		Else 
	 			If ( SUS->( DBSeek( xFilial("SUS") + (cFlow)->AD1_PROSPE + (cFlow)->AD1_LOJPRO ) ) )
					oRecord:SetValue( "US_COD"	, (cFlow)->AD1_PROSPE )
					oRecord:SetValue( "US_LOJA"	, (cFlow)->AD1_LOJPRO )

					oRecord:SetValue( "HSS_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->AD1_PROSPE, (cFlow)->AD1_LOJPRO } ) )						
					oRecord:SetValue( "HSS_AREA"	, oSeeker:Seek( "HOK", { SUS->US_REGIAO } ) )
					oRecord:SetValue( "HSS_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SUS->US_EST, SUS->US_MUN, SUS->US_PAIS ) } ) )
	 			EndIf 
	 		EndIf   	
			
			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------	
			oRecord:SetValue( "HSS_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HSS_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HSS_UNICOM" 	, oSeeker:Seek( "HSP", { (cFlow)->AO3_CODUND } ) )
			oRecord:SetValue( "HSS_EQUVEN" 	, oSeeker:Seek( "HSO", { (cFlow)->AO3_CODEQP } ) )
			oRecord:SetValue( "HSS_OPOVEN" 	, oSeeker:Seek( "HSM", { (cFlow)->AD1_NROPOR, (cFlow)->AD1_REVISA } ) )
			oRecord:SetValue( "HSS_PROVEN" 	, oSeeker:Seek( "HSM", { (cFlow)->AD1_PROVEN, (cFlow)->AD1_STAGE } ) )
			oRecord:SetValue( "HSS_STTOPO"  , oSeeker:Seek( "HSG", { (cFlow)->AD1_STATUS } ) )


	 		//-------------------------------------------------------------------
			// Define o �ltimo est�gio da Oportunidade 
			//-------------------------------------------------------------------
			If ( (cFlow)->AIJ_PROVEN == (cFlow)->AD1_PROVEN .And. (cFlow)->AIJ_STAGE == (cFlow)->AD1_STAGE )
				cUltEst := STR0001	//"Sim"
			Else
				cUltEst := STR0002	//"N�o"
			EndIf   

	 		//-------------------------------------------------------------------
			// Define a dura��o em minutos 
			//-------------------------------------------------------------------   
			nDayToMinute   			:= ( nBIVal( dDataEnc - (cFlow)->AIJ_DTINIC ) ) * 1440 
       	nHourToMinute  			:= ( nBIVal( Substr( cHrEnc, 1, 2 ) ) - nBIVal( Substr( (cFlow)->AIJ_HRINIC, 1, 2 ) ) ) * 60
       	nMinute        			:= ( nBIVal( Substr( cHrEnc, 4, 2 ) ) - nBIVal( Substr( (cFlow)->AIJ_HRINIC, 4, 2 ) ) )
	
	  		//-------------------------------------------------------------------
			// ...e os lookups sem valida��o. 
			//-------------------------------------------------------------------  
			oRecord:SetValue( "HSS_STTEST", cStatus )    

	   		//-------------------------------------------------------------------
			// Grava a Quantidade. 
			//-------------------------------------------------------------------   			
	 		oRecord:SetValue( "HSS_QTDADE", 1 )
	 		
	   		//-------------------------------------------------------------------
			// Grava a Dura�ao em Minutos. 
			//-------------------------------------------------------------------
	   	 	oRecord:SetValue( "HSS_QTMINT", ( nDayToMinute + nHourToMinute + nMinute ) )

	   		//-------------------------------------------------------------------
			// Grava a Data de Inicio do Estagio 
			//-------------------------------------------------------------------
	   	 	oRecord:SetValue( "HSS_DTINIE", (cFlow)->AIJ_DTINIC )

	   		//-------------------------------------------------------------------
			// Grava a Hora de Inicio do Estagio 
			//-------------------------------------------------------------------
	   	 	oRecord:SetValue( "HSS_HRINIE", (cFlow)->AIJ_HRINIC )

	   		//-------------------------------------------------------------------
			// Grava a Data de Encerramento do Estagio 
			//-------------------------------------------------------------------
	   	 	oRecord:SetValue( "HSS_DTFIME", (cFlow)->AIJ_DTENCE )

	   		//-------------------------------------------------------------------
			// Grava a Hora de Encerramento do Estagio 
			//-------------------------------------------------------------------
	   	 	oRecord:SetValue( "HSS_HRFIME",(cFlow)->AIJ_HRENCE )

	   		//-------------------------------------------------------------------
			// Grava o �ltimo Est�gio da Oportunidade 
			//-------------------------------------------------------------------
	   	 	oRecord:SetValue( "HSS_ULTEST", cUltEst )

	   		//-------------------------------------------------------------------
			// Grava os campos de data. 
			//-------------------------------------------------------------------   			
	 		oRecord:SetValue( "HSS_DTINIO", (cFlow)->AD1_DTINI )
	  		oRecord:SetValue( "HSS_DTFIMO", If ( (cFlow)->AD1_STATUS $ '1|3', (cFlow)->AD1_DTPENC, (cFlow)->AD1_DTFIM )	 )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		EndIf  
	 	
	 	(cFlow)->( DBSkip() ) 
 	EndDo 
 		 
  	//-------------------------------------------------------------------
	// Fecha a �rea de trabalho tempor�ria. 
	//-------------------------------------------------------------------  		  
 	If ! ( Select( cFlow ) == 0 )
 		( cFlow )->( DBCloseArea() ) 
 	EndIf 		
	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return Nil

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

@author  Helio Leal
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXEvolucao
	Local nInterval		:= BIXParInfo( "BIX_DIASEV", "N", 0 )
	Local cInterval		:= DToS( SToD( cTo ) - ( nBIVal( nInterval ) * ( 30 ) ) )    
	Local cDML    		:= ""  
	
	//-------------------------------------------------------------------
	// Define a data inicial da extra��o de acordo com o BIXINTREC. 
	//-------------------------------------------------------------------                    
	cDML := If ( cFrom > cInterval, cInterval, cFrom )
	
	cDML := "SELECT AD1_STATUS, AD1_NROPOR, AD1_PROVEN, AD1_CODCLI, AD1_LOJCLI, AD1_PROSPE, " + ;
		"AD1_LOJPRO, AD1_DTINI, AD1_DTPENC, AD1_DTFIM, AD1_STAGE, AD1_REVISA, AIJ_STATUS, AIJ_PROVEN, AIJ_STAGE, AIJ_DTLIMI, " + ;
		"AIJ_HRLIMI, AIJ_DTINIC, AIJ_HRINIC, AIJ_DTENCE, AIJ_HRENCE, AO3_CODUND, AO3_CODEQP " + ;
		"FROM " + RetSQLName("AIJ") + " AIJ " + ;
		"JOIN " + RetSQLName("AD1") + " AD1 " + ; 
		"ON AD1_NROPOR = AIJ_NROPOR " + ;
			"AND AD1_REVISA = AIJ_REVISA " + ; 
			"AND AD1_FILIAL = '" + xFilial("AD1") + "' " + ;
			"AND AD1.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN  " + RetSQLName("AO3") + " AO3 " + ;
		"ON AO3_VEND = AD1_VEND " + ;
			"AND AO3_FILIAL = '" + xFilial("AO3") + "' " + ; 	
			"AND AO3.D_E_L_E_T_ = ' ' " + ;
		"WHERE AIJ_DTINIC BETWEEN '" + cFrom + "' AND '" + cTo + "' " + ; 
			"AND AIJ_FILIAL = '" + xFilial("AIJ") + "' " + ;
			"AND AIJ.D_E_L_E_T_ = ' '"
		
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
	TcSetField( ::cFlow, "AIJ_DTINIC"	, "D", 8, 0 )
	TcSetField( ::cFlow, "AIJ_DTENCE"	, "D", 8, 0 )
	TcSetField( ::cFlow, "AIJ_DTLIMI"	, "D", 8, 0 )
	TcSetField( ::cFlow, "AD1_DTINI"	, "D", 8, 0 )
	TcSetField( ::cFlow, "AD1_DTFIM"	, "D", 8, 0 )      
	TcSetField( ::cFlow, "AD1_DTPENC"	, "D", 8, 0 )
Return ::cFlow