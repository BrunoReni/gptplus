#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDESTIMEVENDAS.CH"

REGISTER EXTRACTOR HSE

#DEFINE OPENED	"|1|3|"   	
#DEFINE CLOSED	"|2|9|"       

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDesTimeVendas
A tabela fato Vendas apresenta informa��es dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Class BIXDesTimeVendas from BIXEntity
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
@since   26/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXDesTimeVendas
	_Super:New( FACT, "HSE", STR0001, "AD1", { CRM } ) //"Desempenho do Time De vendas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXDesTimeVendas 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HSE_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HSE_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HSE_MOEDA" 	,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HSE_REPRES"	,	"C",	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HSE_CLIENT"	,	"C",	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HSE_REGIAO"	,	"C",	32, 00, .T., "HJB" ) //"Regi�o"
	oModel:AddField( "HSE_STTOPO"	,	"C",	32, 00, .T., "HSG" ) //"Status da Oportunidade" 	
	oModel:AddField( "HSE_PROBAB"	,	"C",	32, 00, .T., "HSH" ) //"Probabilidade de Sucesso"
	oModel:AddField( "HSE_OPOVEN"	,	"C",	32, 00, .T., "HSM" ) //"Oportunidade de Venda" 	
	oModel:AddField( "HSE_PROVEN" 	,	"C",	32, 00, .T., "HSN" ) //"Processo de Venda"		
	oModel:AddField( "HSE_UNICOM"	,	"C",	32, 00, .T., "HSP" ) //"Unidade Comercial" 		
	oModel:AddField( "HSE_EQUVEN"	,	"C",	32, 00, .T., "HSO" ) //"Equipe de Venda" 		
	oModel:AddField( "HSE_PROSPE"	,	"C",	32, 00, .T., "HSR" ) //"Prospect" 				
	oModel:AddField( "HSE_AREA"		,	"C",	32, 00, .T., "HOK" ) //"�rea" 					

	oModel:AddField( "HSE_DTAINI"	,	"D",	08, 00, .F., "HK2" ) //"Data de In�cio"
	oModel:AddField( "HSE_DTAFEC"	, 	"D", 	08, 00	) //Data de Fechamento

	oModel:AddField( "HSE_QTDADE"	, 	"N", 	04, 00	) //"Quantidade"				   
	oModel:AddField( "HSE_VRECEI"	, 	"N", 	18, 04	) //"Receita"							   
	oModel:AddField( "HSE_PARTIC"	, 	"N", 	18, 04	) //"Percentual de Participa��o"		   
	oModel:AddField( "HSE_SUCESS"	, 	"N", 	18, 04	) //"Percentual de Sucesso"			   
	oModel:AddField( "HSE_PROCES"	, 	"N", 	18, 04	) //"Percentual do Processo de Venda   

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
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXDesTimeVendas
	Local cFlow				:= ""
    Local aDinamicAlias 	:= {}   
    Local aRegion			:= {} 
    Local aMoeda       		:= {}
    Local cArea				:= ""  
    Local cMoeda			:= "" 
    Local nMoeda			:= 1  
    Local dDate				:= Nil 
    Local dLastExtraction	:= BIXPerFinal( "HSE" )
    Local nVlReceita		:= 0
    Local nPercVend			:= 0
	Local oRegion			:= Nil
	Local cEst				:= UNDEFINED
	Local cCodMun			:= UNDEFINED
	Local cPais			:= UNDEFINED
	
	//-------------------------------------------------------------------*/
	// Recupera os par�metros da fato. 
	//-------------------------------------------------------------------
	aMoeda	:= BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()
		 
   	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )
	
	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal. 
	//-------------------------------------------------------------------  
 	While ! (cFlow)->( Eof() ) 
 		//-------------------------------------------------------------------
		// Define a data para convers�o de moeda. 
		//-------------------------------------------------------------------   
 		dDate	:= If ( (cFlow)->AD1_STATUS $ OPENED, Date(), (cFlow)->AD1_DTFIM ) 
 			 		
 		For nMoeda := 1 To Len( aMoeda ) 
  			cMoeda 			:= aMoeda[nMoeda][1]    
	 		aDinamicAlias	:= {}   
	 		aRegion       	:= {}  
	 		cArea			:= ""
			nVlReceita		:= 0
    		nPercVend		:= 0
    		
	 		//-------------------------------------------------------------------
			// No fluxo principal de dados s�o consideradas as informa��es de cada 
			// item das propostas comerciais com data de in�cio entre o per�odo 
			// indicado para extra��o. Al�m destes itens da proposta comercial, 
			// tamb�m s�o considerados todos os itens de oportunidades de vendas 
			// Abertas ou Suspensas (com valor 1 ou 3) ou que foram Ganha ou Perdidas 
			// (com valor 2 ou 9) ap�s a data da �ltima extra��o executada. 
			//-------------------------------------------------------------------  
	 		If ( ( (cFlow)->AD1_DTINI >= SToD( cFrom ) .And. (cFlow)->AD1_DTFIM <= SToD( cTo ) ) .Or. (cFlow)->AD1_STATUS $ OPENED .Or.;
	 		   ( (cFlow)->AD1_STATUS $ CLOSED .And. (cFlow)->AD1_DTFIM >= dLastExtraction ) )
	 		   
		 		//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 
				oRecord:Init()
		
				//-------------------------------------------------------------------
				// Customiza��o.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "AD1_NROPOR"	, (cFlow)->AD1_NROPOR )
				oRecord:SetValue( "AD1_REVISA"	, (cFlow)->AD1_REVISA )
				oRecord:SetValue( "AC2_PROVEN"	, (cFlow)->AD1_PROVEN )
				oRecord:SetValue( "AC2_STAGE"	, (cFlow)->AD1_STAGE )

				//------------------------------------------------------------------------------
				// Caso a entidade seja o cliente utiliza-se os campos ADY_CODIGO + ADY_LOJA,  
				// caso contr�rio, o campo de cliente ser� preenchido com INDEFINIDO e o campo 
				// de Prospect ter� seu valor preenchido.
				//------------------------------------------------------------------------------
		 		If ( !Empty( (cFlow)->AD1_CODCLI ) ) 
		 			If ( SA1->( DBSeek( xFilial("SA1") + (cFlow)->AD1_CODCLI + (cFlow)->AD1_LOJCLI ) ) )
		 				cEst 	:= SA1->A1_EST
		 				cCodMun := SA1->A1_COD_MUN
		 				cPais	:= SA1->A1_PAIS
						
						oRecord:SetValue( "A1_COD"	, (cFlow)->AD1_CODCLI )
						oRecord:SetValue( "A1_LOJA"	, (cFlow)->AD1_LOJCLI )

						oRecord:SetValue( "HSE_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->AD1_CODCLI, (cFlow)->AD1_LOJCLI } ) )						
						oRecord:SetValue( "HSE_AREA"	, oSeeker:Seek( "HOK", { SA1->A1_REGIAO } ) )						
		 			EndIf   			
		 		Else
		 			If ( SUS->( DBSeek( xFilial("SUS") + (cFlow)->AD1_PROSPE + (cFlow)->AD1_LOJPRO ) ) )
		 				cEst 	:= SUS->US_EST
		 				cCodMun := SUS->US_COD_MUN
		 				cPais	:= SUS->US_PAIS

						oRecord:SetValue( "US_COD"	, (cFlow)->AD1_PROSPE )
						oRecord:SetValue( "US_LOJA"	, (cFlow)->AD1_LOJPRO )	

						oRecord:SetValue( "HSE_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->AD1_PROSPE, (cFlow)->AD1_LOJPRO } ) )						
						oRecord:SetValue( "HSE_AREA"	, oSeeker:Seek( "HOK", { SUS->US_REGIAO} ) )												
		 			EndIf 
		 		EndIf				

				//------------------------------------------------------------------------------
				// Caso haja time de venda para a oportunidade de venda, o representante   
				// dever� ser preenchido com o campo AD2_VEND, caso contr�rio, o campo de 
				// representante ser� preenchido com AD1_VEND.
				//------------------------------------------------------------------------------
		 		If ( !Empty( (cFlow)->AD2_VEND ) ) 
		 			If ( SA3->( DBSeek( xFilial("SA3") + (cFlow)->AD2_VEND  ) ) )
						oRecord:SetValue( "A3_COD"		, (cFlow)->AD2_VEND )
						oRecord:SetValue( "ADK_COD"		, (cFlow)->AD2_VEND )
						oRecord:SetValue( "ACA_GRPREP"	, (cFlow)->AD2_VEND )
						
						oRecord:SetValue( "HSE_REPRES" 	, oSeeker:Seek( "HJC", { (cFlow)->AD2_VEND } ) )
						oRecord:SetValue( "HSE_UNICOM" 	, oSeeker:Seek( "HSP", { (cFlow)->AD2_VEND } ) )
						oRecord:SetValue( "HSE_EQUVEN" 	, oSeeker:Seek( "HSO", { (cFlow)->AD2_VEND } ) )
		 			EndIf
		 		Else
		 			If ( SA3->( DBSeek( xFilial("SA3") + (cFlow)->AD1_VEND ) ) )
						oRecord:SetValue( "A3_COD"	, (cFlow)->AD1_VEND )
						oRecord:SetValue( "ADK_COD"	, (cFlow)->AD1_VEND )
						oRecord:SetValue( "ACA_GRPREP"	, (cFlow)->AD1_VEND )
						
						oRecord:SetValue( "HSE_REPRES" 	, oSeeker:Seek( "HJC", { (cFlow)->AD1_VEND } ) )
						oRecord:SetValue( "HSE_UNICOM" 	, oSeeker:Seek( "HSP", { (cFlow)->AD1_VEND } ) )
						oRecord:SetValue( "HSE_EQUVEN" 	, oSeeker:Seek( "HSO", { (cFlow)->AD1_VEND } ) )
		 			EndIf 
		 		EndIf

				//-------------------------------------------------------------------
				// Lookups.
				//-------------------------------------------------------------------	
				oRecord:SetValue( "HSE_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
				oRecord:SetValue( "HSE_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HSE_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( cEst, cCodMun, cPais ) } ) )
				oRecord:SetValue( "HSE_OPOVEN"	, oSeeker:Seek( "HSM", { (cFlow)->AD1_NROPOR, (cFlow)->AD1_REVISA } ) )
				oRecord:SetValue( "HSE_PROVEN"	, oSeeker:Seek( "HSN", { (cFlow)->AD1_PROVEN, (cFlow)->AD1_STAGE } ) )
				oRecord:SetValue( "HSE_MOEDA"	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
				oRecord:SetValue( "HSE_STTOPO"  , oSeeker:Seek( "HSG", { (cFlow)->AD1_STATUS } ) )

		  		//-------------------------------------------------------------------
				// ...e os lookups sem valida��o. 
				//-------------------------------------------------------------------  
				oRecord:SetValue("HSE_PROBAB",  (cFlow)->AD1_FEELIN  )

			
		   		//-------------------------------------------------------------------
				// Grava a Quantidade. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue("HSE_QTDADE", 1 )

		   		//-------------------------------------------------------------------
				// Grava a Receita.
				//-------------------------------------------------------------------
				nVlReceita		:= If ( (cFlow)->AD1_STATUS $ OPENED, (cFlow)->AD1_VERBA, (cFlow)->AD1_RCREAL )
	    		nPercVend		:= If ( (cFlow)->AD2_PERC > 0 , (cFlow)->AD2_PERC, 100 )
		 		oRecord:SetValue("HSE_VRECEI", BIXValue( nVlReceita * (nPercVend / 100 ), 1, cMoeda, dDate) )

		  		//-------------------------------------------------------------------
				// Grava o Percentual de Participa��o. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue("HSE_PARTIC", nPercVend )
		 		
		   		//-------------------------------------------------------------------
				// Grava o Percentual de Sucesso. 
				//-------------------------------------------------------------------
				If (cFlow)->AD1_FEELIN == '1'
					oRecord:SetValue("HSE_SUCESS", 30 )
				ElseIf (cFlow)->AD1_FEELIN == '2'
					oRecord:SetValue("HSE_SUCESS", 60 )
				ElseIf (cFlow)->AD1_FEELIN == '3'
					oRecord:SetValue("HSE_SUCESS", 90 )
				EndIf

		   		//-------------------------------------------------------------------
				// Grava o Percentual do Processo de Venda. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue("HSE_PROCES", (cFlow)->AC2_RELEVA )

		   		//-------------------------------------------------------------------
				// Grava os campos de data. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue("HSE_DTAINI", (cFlow)->AD1_DTINI ) 
		  		oRecord:SetValue("HSE_DTAFEC", If ( (cFlow)->AD1_STATUS $ OPENED, (cFlow)->AD1_DTPENC, (cFlow)->AD1_DTFIM )	 )
				
				//-------------------------------------------------------------------
				// Envia o registro para o pool de grava��o. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
		  	EndIf 
	 	Next nMoeda  
	 	
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
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXDesTimeVendas
	Local nInterval		:= BIXParInfo( "BIX_DIASTM", "N", 0 )
	Local cInterval		:= DToS( SToD( cTo ) - ( nBIVal( nInterval ) * ( 30 ) ) )    
	Local cDML    		:= "" 

	//-------------------------------------------------------------------
	// Define a data inicial da extra��o de acordo com o BIXINTREC. 
	//-------------------------------------------------------------------                    
	cFrom := If ( cFrom > cInterval, cInterval, cFrom )

	cDML := "SELECT AD1_STATUS, AD1_FEELIN, AD1_NROPOR, AD1_REVISA, AD1_PROVEN, AD1_STAGE, " + ;
		"AD1_CODCLI, AD1_LOJCLI, AD1_PROSPE, AD1_LOJPRO, AD1_VERBA, AD1_RCREAL, " + ;
		"AD1_DTINI, AD1_DTPENC, AD1_DTFIM, AD1_VEND, AD2_VEND, AD2_PERC, AC2_RELEVA " + ;
		"FROM " + RetSQLName("AD1") + " AD1 " + ;
		"LEFT JOIN " + RetSQLName("AD2") + " AD2 " + ;
		"ON AD2_NROPOR = AD1_NROPOR " + ;
			"AND AD2_REVISA = AD1_REVISA " + ;
			"AND AD2_FILIAL = '" + xFilial("AD2") + "' " + ;
			"AND AD2.D_E_L_E_T_= ' ' " + ;
		"INNER JOIN " + RetSQLName("AC2") + " AC2 " + ;
		"ON AC2_PROVEN = AD1_PROVEN " + ;
			"AND AC2_STAGE = AD1_STAGE " + ;
			"AND AC2_FILIAL = '" + xFilial("AC2") + "' " + ;
			"AND AC2.D_E_L_E_T_ = ' ' " + ;
		"WHERE AD1_DTINI BETWEEN '" + cFrom + "' AND '" + cTo + "' " + ;
			"AND AD1_FILIAL = '" + xFilial("AD1") + "' " + ;
			"AND AD1.D_E_L_E_T_ = ' '" 

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
	TcSetField( ::cFlow, "AD1_DTINI"	, "D", 8, 0 )   
	TcSetField( ::cFlow, "AD1_DTFIM"	, "D", 8, 0 )   
	TcSetField( ::cFlow, "AD1_DTPENC", "D", 8, 0 )
Return ::cFlow