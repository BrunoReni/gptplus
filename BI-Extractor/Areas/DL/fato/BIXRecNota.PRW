#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRECNOTA.CH"

REGISTER EXTRACTOR HOG 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRecNota
A tabela fato Vendas apresenta informa��es dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Class BIXRecNota from BIXEntity
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXRecNota
	_Super:New( FACT, "HOG", STR0001, "DTC", { DL } ) //"Recebimento de Notas Fiscais de Clientes"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXRecNota 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOG_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HOG_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HOG_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Neg�cio"
	oModel:AddField( "HOG_TIPTRA"	,	"C",	32, 00, .T., "HHX" ) //"Tipo Transporte"	
	oModel:AddField( "HOG_SERTRA"	,	"C",	32, 00, .T., "HO1" ) //"Servi�o de Transporte"
	oModel:AddField( "HOG_CLIREM"	,	"C",	32, 00, .T., "HJ7" ) //"Cliente Remetente"
	oModel:AddField( "HOG_CLIDES"	,	"C",	32, 00, .T., "HJ7" ) //"Cliente Destinat�rio"
	oModel:AddField( "HOG_CLIDEV"	,	"C",	32, 00, .T., "HJ7" ) //"Cliente Devedor"
	oModel:AddField( "HOG_REGTRA"	,	"C",	32, 00, .T., "HO0" ) //"Regi�o de Transporte de Origem"	
	oModel:AddField( "HOG_REGDES"	,	"C",	32, 00, .T., "HO0" ) //"Regi�o de Transporte de Destino"	
	oModel:AddField( "HOG_DATA"		,	"D",	08, 00, .F., "HK2" ) //"Data de Recebimento"
	oModel:AddField( "HOG_DTEXPE"	,	"D",	08, 00, .F., "HK2" ) //"Data de Expedi��o"	

	oModel:AddField( "HOG_QTDREC"	, 	"N", 	04, 00	) //Qtde Recebida
	oModel:AddField( "HOG_QTDEXP"	, 	"N", 	04, 00	) //Qtde Expedida

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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXRecNota
	Local cFlow		:= ""

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! (cFlow)->( Eof() ) 
 		//-------------------------------------------------------------------
 		// Dever� ser considerado o par�metro BIXINTREC que determinar� at� 
 		// quantos meses anteriores, em rela��o a data da extra��o, ser�o 
 		// considerados para atualiza��o da tabela fato. No per�odo determinado 
 		// pelo par�metro, fora do per�odo normal de extra��o, dever�o ser extra�dos 
 		// apenas os registros cuja a Quantidade Expedida for igual 0. 
		//-------------------------------------------------------------------
 		If ( (cFlow)->EXPEDIDO == 0 .Or. ( (cFlow)->DTC_DATENT >= SToD( cFrom ) .And. (cFlow)->DTC_DATENT <= SToD( cTo ) ) )
	 		//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
	 		
	 		//-------------------------------------------------------------------
			// Customiza��o.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "DUY_GRPVEN"	, (cFlow)->DTC_CDRORI )
			
			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------	
			oRecord:SetValue( "HOG_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HOG_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HOG_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HOG_CLIREM" 	, oSeeker:Seek( "HJ7", { (cFlow)->DTC_CLIREM, (cFlow)->DTC_LOJREM } ) )
			oRecord:SetValue( "HOG_CLIDES" 	, oSeeker:Seek( "HJ7", { (cFlow)->DTC_CLIDES, (cFlow)->DTC_LOJDES } ) )
			oRecord:SetValue( "HOG_CLIDEV" 	, oSeeker:Seek( "HJ7", { (cFlow)->DTC_CLIDEV, (cFlow)->DTC_LOJDEV } ) )
			oRecord:SetValue( "HOG_REGTRA" 	, oSeeker:Seek( "HO0", { (cFlow)->DTC_CDRORI } ) )
			oRecord:SetValue( "HOG_REGDES" 	, oSeeker:Seek( "HO0", { (cFlow)->DTC_CDRDES } ) )
	
			//-------------------------------------------------------------------
			// ...e os lookups sem valida��o. 
			//-------------------------------------------------------------------  
			oRecord:SetValue( "HOG_TIPTRA", (cFlow)->DTC_TIPTRA )
			oRecord:SetValue( "HOG_SERTRA", (cFlow)->DTC_SERTMS )
	
	   		//-------------------------------------------------------------------
			// Grava a Quantidade Recebida e Quantidade Expedida. 
			//-------------------------------------------------------------------   			
	 		oRecord:SetValue( "HOG_QTDREC", 1 )
	 		oRecord:SetValue( "HOG_QTDEXP", (cFlow)->EXPEDIDO )
	   	 
	   	 	//-------------------------------------------------------------------
			// Grava os campos data. 
			//------------------------------------------------------------------- 	
	     	oRecord:SetValue( "HOG_DATA", (cFlow)->DTC_DATENT )
	     	
	  		If ( DUD->( DBSeek( xFilial("DUD") + (cFlow)->DTC_FILDOC + (cFlow)->DTC_DOC + (cFlow)->DTC_SERIE ) ) ) 
	  			While ( ! DUD->( Eof() ) .And. DUD->DUD_FILDOC == (cFlow)->DTC_FILDOC .And. DUD->DUD_DOC == (cFlow)->DTC_DOC .And. DUD->DUD_SERIE == (cFlow)->DTC_SERIE )
		  		  	If ( DUD->DUD_STATUS $ "2|4" .And. ! Empty( DUD->DUD_VIAGEM ) )  
			  		  	DTQ->( DBSetOrder( 2 ) ) 
			   			    
			   			If ( DTQ->( DBSeek( xFilial("DTQ") + DUD->DUD_FILORI + DUD->DUD_VIAGEM ) ) ) 
			   	  			oRecord:SetValue( "HOG_DTEXPE", DTQ->DTQ_DATGER	)
							Exit
			   			EndIf
		   			EndIf 
		   			
		   			DUD->( DBSkip() ) 
	   			EndDo	   		 
	   		EndIf 

			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		EndIf
 		(cFlow)->( DBSkip() ) 
 	EndDo 
	
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXRecNota
	Local nInterval		:= BIXParInfo( "BIX_INTREC", "N", 0 )
	Local cInterval		:= DToS( SToD( cTo ) - ( nBIVal( nInterval ) * ( 30 ) ) )    
	Local cDML    		:= ""  
	
	//-------------------------------------------------------------------
	// Define a data inicial da extra��o de acordo com o BIXINTREC. 
	//-------------------------------------------------------------------                    
	cFrom := If ( cFrom > cInterval, cInterval, cFrom )	

	cDML += " SELECT DTC_TIPTRA, DTC_SERTMS, DTC_CLIREM, DTC_LOJREM, DTC_CLIDES," 
	cDML += " 		DTC_LOJDES, DTC_CLIDEV, DTC_LOJDEV, DTC_CDRORI, DTC_CDRDES,"
	cDML += " 		DTC_DATENT, DTC_FILDOC, DTC_DOC, DTC_SERIE, "  	
	cDML += " 		("     
	cDML += " 			SELECT COUNT(*) FROM " + RetSQLName("DUD") + " DUD"  
	cDML += " 			WHERE DUD_FILIAL = '" + xFilial("DUD") + "'"
	cDML += " 	   			AND DUD_FILDOC = DTC_FILDOC"
	cDML += " 				AND DUD_DOC = DTC_DOC"
	cDML += " 	   			AND DUD_SERIE = DTC_SERIE"
	cDML += " 				AND DUD_STATUS IN ( '2', '4' )" 
	cDML += " 	   			AND DUD.D_E_L_E_T_ = ' '"
	cDML += " 		) AS EXPEDIDO"
	cDML += " 	FROM " + RetSQLName("DTC") + " DTC" 
	cDML += " 	WHERE DTC_FILIAL = '" + xFilial("DT6") + "'"
	cDML += "	   	AND DTC_DATENT BETWEEN '" + cFrom + "' AND '" + cTo + "'"               
	cDML += "		AND DTC.D_E_L_E_T_ = ' '"  	 

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
	TcSetField( ::cFlow, "DTC_DATENT", "D", 8, 0 )   
Return ::cFlow