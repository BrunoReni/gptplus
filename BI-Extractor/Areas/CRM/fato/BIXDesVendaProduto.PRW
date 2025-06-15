#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDESVENDAPRODUTO.CH"

REGISTER EXTRACTOR HST 

#DEFINE OPENED	"|1|3|"   	
#DEFINE CLOSED	"|2|9|"     

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDesVendaProduto
A tabela fato Vendas apresenta informa��es dos pedidos de vendas como 
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Class BIXDesVendaProduto from BIXEntity
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
Method New() Class BIXDesVendaProduto
	_Super:New( FACT, "HST", STR0001, "ADZ", { CRM } ) //"Desempenho de Vendas de Produtos"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXDesVendaProduto 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HST_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HST_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HST_ITEM"		,	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HST_FAMCOM"	,	"C",	32, 00, .T., "HG1" ) //"Fam�lia Comercial"	
	oModel:AddField( "HST_GRPEST"	,	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HST_REPRES"	,	"C",	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HST_MOEDA" 	,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HST_CLIENT"	,	"C",	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HST_REGIAO"	,	"C",	32, 00, .T., "HJB" ) //"Regi�o"
	oModel:AddField( "HST_UNITEM" 	,	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"	
	oModel:AddField( "HST_STTPRO"	,	"C",	32, 00, .T., "HSI" ) //"Status da Proposta Comercial"
	oModel:AddField( "HST_STTOPO"	,	"C",	32, 00, .T., "HSG" ) //"Status da Oportunidade"	
	oModel:AddField( "HST_PROBAB"	,	"C",	32, 00, .T., "HSH" ) //"Probabilidade de Sucesso"
	oModel:AddField( "HST_OPOVEN"	,	"C",	32, 00, .T., "HSM" ) //"Oportunidade de Venda"		
	oModel:AddField( "HST_PROVEN"	,	"C",	32, 00, .T., "HSN" ) //"Processo de Venda"	
	oModel:AddField( "HST_UNICOM"	,	"C",	32, 00, .T., "HSP" ) //"Unidade Comercial"
	oModel:AddField( "HST_EQUVEN" 	,	"C",	32, 00, .T., "HSO" ) //"Equipe de Venda"			
	oModel:AddField( "HST_PROSPE"	,	"C",	32, 00, .T., "HSR" ) //"Prospect"			
	oModel:AddField( "HST_AREA"	 	,	"C",	32, 00, .T., "HOK" ) //"�rea" 	
	oModel:AddField( "HST_DTAINI"	,	"D",	08, 00, .F., "HK2" ) //"Per�odo - Data da Venda"
	oModel:AddField( "HST_DTAFIM"	, 	"D", 	08, 00	) //Data da Entrega
	
	oModel:AddField( "HST_PROCOM"	, 	"C", 	06, 00	) //Proposta Comercial				
	oModel:AddField( "HST_REVPRO"	, 	"C", 	02, 00	) //Revis�o da Proposta Comercial	
	oModel:AddField( "HST_QTITEM"	, 	"N", 	04, 00	) //Quantidade de Itens				
	oModel:AddField( "HST_QTPROD"	, 	"N", 	10, 00	) //Quantidade de Produto			
	oModel:AddField( "HST_VLVEND"	, 	"N", 	18, 04	) //Pre�o de Venda					
	oModel:AddField( "HST_VLTABE"	, 	"N", 	18, 04	) //Pre�o de Tabela					
	oModel:AddField( "HST_VLTOTV"	, 	"N", 	18, 04	) //Valor Total						
	oModel:AddField( "HST_VLPDES"	, 	"N", 	18, 04	) //% de Desconto					
	oModel:AddField( "HST_VLDESC"	, 	"N", 	18, 04	) //Valor de Desconto			

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXDesVendaProduto
	Local aAlias			:= {} 
    Local aDinamicAlias 	:= {}   
    Local aRegion			:= {} 
    Local aMoeda       		:= {}
    Local cArea				:= ""  
    Local cMoeda			:= "" 
    Local nMoeda			:= 1  
    Local dDate				:= Nil 
    Local dLastExtraction	:= BIXPerFinal( "HST" ) 
	Local oRegion			:= Nil

   	//-------------------------------------------------------------------
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
				oRecord:SetValue( "ADZ_PROPOS"	, (cFlow)->ADZ_PROPOS )
				oRecord:SetValue( "ADZ_REVISA"	, (cFlow)->ADZ_REVISA )	
				oRecord:SetValue( "ADZ_FOLDER"	, (cFlow)->ADZ_FOLDER )
				oRecord:SetValue( "ADZ_ITEM"	, (cFlow)->ADZ_ITEM )	
				oRecord:SetValue( "B1_COD"		, (cFlow)->ADZ_PRODUT )
				oRecord:SetValue( "ACU_COD"		, (cFlow)->ACV_CATEGO )
				oRecord:SetValue( "BM_GRUPO"	, (cFlow)->B1_GRUPO )				
				oRecord:SetValue( "AD1_NROPOR"	, (cFlow)->AD1_NROPOR )
				oRecord:SetValue( "AD1_REVISA"	, (cFlow)->AD1_REVISA )				
				oRecord:SetValue( "A3_COD"		, (cFlow)->AO3_VEND )
				oRecord:SetValue( "AC2_PROVEN"	, (cFlow)->AD1_PROVEN )
				oRecord:SetValue( "AC2_STAGE"	, (cFlow)->AD1_STAGE )
				oRecord:SetValue( "ADK_COD"		, (cFlow)->AO3_CODUND )
				oRecord:SetValue( "ACA_GRPREP"	, (cFlow)->AO3_CODEQP )
				oRecord:SetValue( "AH_UNIMED"	, (cFlow)->B1_UM )
		
				//-------------------------------------------------------------------
				// Para o preenchimento do campo Cliente deve-se verificar se a entidade 
				// da proposta comercial � o cliente (ADY_ENTIDA = 1, a partir de ADZ_PROPOS 
				// utilizando �ndice 1). Caso a entidade seja o cliente utiliza-se os campos 
				// ADY_CODIGO + ADY_LOJA, caso contr�rio, o campo de cliente ser� preenchido 
				// com INDEFINIDO e o campo de Prospect ter� seu valor preenchido.
				//------------------------------------------------------------------- 
		 		If ( ADY_ENTIDA == "1" ) 
		 			If ( SA1->( DBSeek( xFilial("SA1") + (cFlow)->ADY_CODIGO + (cFlow)->ADY_LOJA ) ) )
						oRecord:SetValue( "A1_COD"	, (cFlow)->ADY_CODIGO )
						oRecord:SetValue( "A1_LOJA"	, (cFlow)->ADY_LOJA )
						
						oRecord:SetValue( "HST_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->ADY_CODIGO, (cFlow)->ADY_LOJA } ) )						
						oRecord:SetValue( "HST_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) )
		 				cArea := SA1->A1_REGIAO
		 			EndIf
		 		Else 
		 			If ( SUS->( DBSeek( xFilial("SUS") + (cFlow)->ADY_CODIGO + (cFlow)->ADY_LOJA ) ) )
						oRecord:SetValue( "US_COD"	, (cFlow)->ADY_CODIGO )
						oRecord:SetValue( "US_LOJA"	, (cFlow)->ADY_LOJA )

						oRecord:SetValue( "HST_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->ADY_CODIGO, (cFlow)->ADY_LOJA } ) )						
						oRecord:SetValue( "HST_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SUS->US_EST, SUS->US_MUN, SUS->US_PAIS ) } ) )
						cArea := SUS->US_REGIAO
		 			EndIf
		 		EndIf
				
				//-------------------------------------------------------------------
				// Lookups.
				//-------------------------------------------------------------------	
				oRecord:SetValue( "HST_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
				oRecord:SetValue( "HST_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				
				oRecord:SetValue( "HST_UNICOM" 	, oSeeker:Seek( "HSP", { (cFlow)->AO3_CODUND } ) )
				oRecord:SetValue( "HST_EQUVEN" 	, oSeeker:Seek( "HSO", { (cFlow)->AO3_CODEQP } ) )
				oRecord:SetValue( "HST_OPOVEN" 	, oSeeker:Seek( "HSM", { (cFlow)->AD1_NROPOR, (cFlow)->AD1_REVISA } ) )
				oRecord:SetValue( "HST_PROVEN" 	, oSeeker:Seek( "HSM", { (cFlow)->AD1_PROVEN, (cFlow)->AD1_STAGE } ) )
				oRecord:SetValue( "HST_ITEM" 	, oSeeker:Seek( "HJ8", { (cFlow)->ADZ_PRODUT } ) )
				oRecord:SetValue( "HST_FAMCOM" 	, oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) )		
				oRecord:SetValue( "HST_GRPEST" 	, oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) )
				oRecord:SetValue( "HST_REPRES" 	, oSeeker:Seek( "HJC", { (cFlow)->AO3_VEND } ) )						
				oRecord:SetValue( "HST_UNITEM" 	, oSeeker:Seek( "HHW", { (cFlow)->B1_UM } ) )
				oRecord:SetValue( "HST_MOEDA"	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
				oRecord:SetValue( "HST_STTOPO"  , oSeeker:Seek( "HSG", { (cFlow)->AD1_STATUS } ) )

		  		//-------------------------------------------------------------------
				// ...e os lookups sem valida��o. 
				//-------------------------------------------------------------------  
				oRecord:SetValue( "HST_STTPRO"	, (cFlow)->ADY_STATUS ) 
				oRecord:SetValue( "HST_PROBAB"	, (cFlow)->AD1_FEELIN )
				oRecord:SetValue( "HST_AREA"	, cArea )
				oRecord:SetValue( "HST_PROCOM"	, (cFlow)->ADZ_PROPOS )
				oRecord:SetValue( "HST_REVPRO"	, (cFlow)->ADZ_REVISA )	
	
		   		//-------------------------------------------------------------------
				// Grava a Quantidade de Itens. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_QTITEM"	, 1 )
		 		
		   		//-------------------------------------------------------------------
				// Grava a Quantidade de Produto. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_QTPROD"	, (cFlow)->ADZ_QTDVEN )
		 
		  		//-------------------------------------------------------------------
				// Grava o Pre�o de Venda. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_VLVEND"	, BIXValue( (cFlow)->ADZ_PRCVEN, 1, cMoeda, dDate) )
		 		
		   		//-------------------------------------------------------------------
				// Grava o Pre�o de Tabela. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_VLTABE"	, BIXValue( (cFlow)->ADZ_PRCTAB, 1, cMoeda, dDate) )
		 	
		   		//-------------------------------------------------------------------
				// Grava o Valor Total. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_VLRTOT"	, BIXValue( (cFlow)->ADZ_TOTAL, 1, cMoeda, dDate) )
		 	
		   		//-------------------------------------------------------------------
				// Grava o Desconto em %. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_VLPDES"	, (cFlow)->ADZ_DESCON )
		 
		   		//-------------------------------------------------------------------
				// Grava o Valor de Desconto. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_VLDESC"	, BIXValue( (cFlow)->ADZ_VALDES, 1, cMoeda, dDate) )
		   
		   		//-------------------------------------------------------------------
				// Grava os campos de data. 
				//-------------------------------------------------------------------   			
		 		oRecord:SetValue( "HST_DTAINI", (cFlow)->AD1_DTINI )
		  		oRecord:SetValue( "HST_DTAFIM", If ( (cFlow)->AD1_STATUS $ OPENED, (cFlow)->AD1_DTPENC, (cFlow)->AD1_DTFIM ) )
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXDesVendaProduto
	Local nInterval		:= BIXParInfo( "BIX_DIASPR", "N", 0 ) 
	Local cInterval		:= DToS( SToD( cTo ) - ( nBIVal( nInterval ) * ( 30 ) ) )    
	Local cDML    		:= ""  
	
	//-------------------------------------------------------------------
	// Define a data inicial da extra��o de acordo com o BIXINTREC. 
	//-------------------------------------------------------------------                    
	cFrom := If ( cFrom > cInterval, cInterval, cFrom )	
      
	cDML += " SELECT"
	cDML += " 		ADZ.ADZ_PRODUT," 
	cDML += " 		ADZ.ADZ_PROPOS," 
	cDML += " 		ADZ.ADZ_REVISA,"
	cDML += " 		ADZ.ADZ_FOLDER,"
	cDML += " 		ADZ.ADZ_ITEM,"
	cDML += " 		ADZ.ADZ_QTDVEN,"
	cDML += " 		ADZ.ADZ_PRCVEN,"
	cDML += " 		ADZ.ADZ_PRCTAB,"
	cDML += " 		ADZ.ADZ_TOTAL,"
	cDML += " 		ADZ.ADZ_DESCON,"
	cDML += " 		ADZ.ADZ_VALDES,"
	cDML += " 		ADY.ADY_STATUS,"
	cDML += " 		ADY.ADY_OPORTU," 
	cDML += " 		ADY.ADY_REVISA," 
	cDML += " 		ADY.ADY_VEND,"
	cDML += " 		ADY.ADY_ENTIDA,"
	cDML += " 		ADY.ADY_CODIGO,"
	cDML += " 		ADY.ADY_LOJA,"
	cDML += " 		AD1.AD1_STATUS,"
	cDML += " 		AD1.AD1_FEELIN,"
	cDML += " 		AD1.AD1_NROPOR,"  
	cDML += " 		AD1.AD1_REVISA,"
	cDML += " 		AD1.AD1_PROVEN,"
	cDML += " 		AD1.AD1_DTINI," 
	cDML += " 		AD1.AD1_DTFIM,"
	cDML += " 		AD1.AD1_DTPENC,"	 
	cDML += " 		AD1.AD1_STAGE,"	
	cDML += " 		AO3.AO3_CODUND,"
	cDML += " 		AO3.AO3_CODEQP,"
	cDML += " 		AO3.AO3_VEND," 
	cDML += " 		SB1.B1_GRUPO,"
	cDML += " 		SB1.B1_UM,"
	cDML += " 		ACV.ACV_CATEGO" 
	cDML += " FROM " + RetSQLName("ADZ") + " ADZ " 
	cDML += " INNER JOIN " + RetSQLName("ADY") + " ADY "
	cDML += " ON" 
	cDML += " 		ADY.ADY_PROPOS = ADZ.ADZ_PROPOS"	
	cDML += "	   	AND"   
	cDML += "		ADY.ADY_FILIAL = '" + xFilial("ADY") + "'" 
	cDML += " 		AND"
	cDML += " 		ADY.D_E_L_E_T_ = ''"
	cDML += " INNER JOIN  " + RetSQLName("AD1") + " AD1 "
	cDML += " ON"
	cDML += " 		AD1.AD1_NROPOR = ADY.ADY_OPORTU" 
	cDML += " 		AND"
	cDML += " 		AD1.AD1_REVISA = ADY.ADY_REVISA" 
	cDML += " 		AND"
	cDML += " 		AD1.AD1_DTINI BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cDML += "	   	AND"   
	cDML += "		AD1.AD1_FILIAL = '" + xFilial("AD1") + "'" 	
	cDML += " 		AND"
	cDML += " 		AD1.D_E_L_E_T_ = ''"
	cDML += " LEFT JOIN  " + RetSQLName("AO3") + " AO3 "
	cDML += " ON"
	cDML += " 		AO3.AO3_VEND = ADY.ADY_VEND" 
	cDML += "	   	AND"   
	cDML += "		AO3.AO3_FILIAL = '" + xFilial("AO3") + "'" 	
	cDML += " 		AND"
	cDML += " 		AO3.D_E_L_E_T_ = ''"
	cDML += " LEFT JOIN " + RetSQLName("SB1") + " SB1 "
	cDML += " ON" 
	cDML += " 		SB1.B1_COD = ADZ.ADZ_PRODUT" 
	cDML += "	   	AND"   
	cDML += "		SB1.B1_FILIAL = '" + xFilial("SB1") + "'"    
	cDML += " 		AND"
	cDML += " 		SB1.D_E_L_E_T_ = ''"
	cDML += " LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cDML += " ON"	
	cDML += " 		ACV.ACV_CODPRO = ADZ.ADZ_PRODUT"
	cDML += "	   	AND"   
	cDML += "		ACV.ACV_FILIAL = '" + xFilial("ACV") + "'"    
	cDML += " 		AND"
	cDML += " 		ACV.D_E_L_E_T_ = ''"		
	cDML += " WHERE" 
	cDML += " 		ADZ.D_E_L_E_T_ = ''" 
	cDML += "	   	AND"   
	cDML += "		ADZ.ADZ_FILIAL = '" + xFilial("ADZ") + "'"       

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
	TcSetField( ::cFlow, "AD1_DTPENC"	, "D", 8, 0 )
Return ::cFlow