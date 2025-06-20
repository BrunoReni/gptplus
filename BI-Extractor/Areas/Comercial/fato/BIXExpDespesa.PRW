#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEXPDESPESA.CH"

REGISTER EXTRACTOR HQ3 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXExpDespesa
Representa��o do extrator.

@author  Helio Leal
@since   29/05/2017

/*/
//-------------------------------------------------------------------
Class BIXExpDespesa from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author Helio Leal
@since   29/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXExpDespesa
	_Super:New( FACT, "HQ3", STR0001, "EET", { COMERCIAL } ) //  "Exporta��o - Despesas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXExpDespesa
	Local oModel := BIXModel():Build( Self )
	 
	oModel:AddField( "HQ3_EMPRES"	, "C",	32,	00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HQ3_ESTABL"	, "C",	32,	00, .T., "HKK" ) //"Estabelecimento""
	oModel:AddField( "HQ3_GRPCLI"	, "C",	32,	00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HQ3_MOEDA"	, "C",	32,	00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HQ3_FORNTI"	, "C",  32,	00, .T., "HKJ" ) //Transportadora Internacional
	oModel:AddField( "HQ3_FORNAC"	, "C",  32,	00, .T., "HKJ" ) //Agente Carga             
	oModel:AddField( "HQ3_FORNDP"	, "C",  32,	00, .T., "HKJ" ) //Despachante              
	oModel:AddField( "HQ3_FORNSG"	, "C",  32,	00, .T., "HKJ" ) //Seguradora               
	oModel:AddField( "HQ3_NATEXP"	, "C",  32,	00, .T., "HGP" ) //"Natureza Exporta��o"	
	oModel:AddField( "HQ3_ITINER"	, "C",  32,	00, .T., "HGQ" ) //"Itiner�rio"	
	oModel:AddField( "HQ3_PTOCTR"	, "C",  32,	00, .T., "HGS" ) //"Ponto Controle"	
	oModel:AddField( "HQ3_FORNDS"	, "C",  32,	00, .T., "HKJ" ) //Fornecedor Despesa       
	oModel:AddField( "HQ3_CLDESP"	, "C",  32,	00, .T., "HGO" ) //"Classe Despesa"		
	oModel:AddField( "HQ3_SITEXP"	, "C",  32,	00, .T., "HGJ" ) //"Situa��o Exporta��o"	
	oModel:AddField( "HQ3_CLIENT"	, "C",	32,	00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HQ3_REGIAO"	, "C",	32,	00, .T., "HJB" ) //"Regi�o"	
	oModel:AddField( "HQ3_INCOTR"	, "C",  32,	00, .T., "HGM" ) //"Incoterm"
	oModel:AddField( "HQ3_DESPES"	, "C",  32,	00, .T., "HGL" ) //"Despesa"	
	oModel:AddField( "HQ3_CONDPG"	, "C",	32,	00, .T., "HJA" ) //"Condi��o de Pagamento"
	oModel:AddField( "HQ3_VIATRA"	, "C",  32,	00, .T., "HGR" ) //"Via Transporte" 
	oModel:AddField( "HQ3_DATA"		, "D",	08,	00, .F., "HK2" ) //"Data Implanta��o da Exporta��o"
	oModel:AddField( "HQ3_DTEMBA"	, "D",  08,	00 )	//Data de Embarque         
	oModel:AddField( "HQ3_DTPPTC"	, "D",  08,	00 )	//Data de Previs�o Ponto Controle
	oModel:AddField( "HQ3_DTULPV"	, "D",  08,	00 )	//Data da �ltima Previs�o  
	oModel:AddField( "HQ3_DTEPTC"	, "D",  08,	00 )	//Data Efetiva��o Ponto Controle
	oModel:AddField( "HQ3_DTCBDP"	, "D",  08,	00 )	//Data de Cobran�a da Despesa
	
	oModel:AddField( "HQ3_NPREXP"	, "C",	20, 00 )	//N�mero Processo Exporta��o

	oModel:AddField( "HQ3_SEQPTO"	, "N",  04, 00 )	//Sequencia Ponto Controle 
	oModel:AddField( "HQ3_VDESPD"	, "N",  16, 02 )	//Vl Despesa Direta        
	oModel:AddField( "HQ3_VDESPI"	, "N",  16, 02 )	//Vl Despesa Indireta      
	oModel:AddField( "HQ3_VTXFIN"	, "N",  16, 02 )	//Vl Taxa Financeira       
	oModel:AddField( "HQ3_VDESDX"	, "N",  16, 02 )	//Vl Desconto Despesa 
		
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

@author  Marcia Junko
@since   22/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXExpDespesa
	Local oRegion	:= Nil	
	Local aMoedas := {}
	Local cMoeda  := ""      
	Local nMoeda  := 1 

	//-------------------------------------------------------------------
	// Recupera os par�metros da fato.
	//-------------------------------------------------------------------
	aMoedas	:= BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 
	
	While (cFlow)->(! EoF() ) 
		For nMoeda := 1 To Len(aMoedas)
			cMoeda := aMoedas[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customiza��o.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "EET_PEDIDO"	, (cFlow)->EET_PEDIDO )
			oRecord:SetValue( "EET_OCORRE"	, (cFlow)->EET_OCORRE )
			oRecord:SetValue( "EET_SEQ"		, (cFlow)->EET_SEQ )
			oRecord:SetValue( "EET_DESPES"	, (cFlow)->EET_DESPES )
			oRecord:SetValue( "A1_COD"		, (cFlow)->EEC_IMPORT )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->EEC_IMLOJA ) 
			oRecord:SetValue( "YJ_COD"		, (cFlow)->EEC_INCOTE )
			oRecord:SetValue( "YB_DESP"		, (cFlow)->EET_DESPES )
			oRecord:SetValue( "YA_CODGI"	, (cFlow)->A1_PAIS )			
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HQ3_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 		
			oRecord:SetValue( "HQ3_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HQ3_GRPCLI", oSeeker:Seek( "HJ0", { (cFlow)->A1_TIPO } ) )
			oRecord:SetValue( "HQ3_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) )
			oRecord:SetValue( "HQ3_FORNTI", oSeeker:Seek( "HKJ", { AE100GetEmpr((cFlow)->EET_PEDIDO,"B","Y5_FORNECE"), AE100GetEmpr((cFlow)->EET_PEDIDO,"B","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ3_FORNAC", oSeeker:Seek( "HKJ", { AE100GetEmpr((cFlow)->EET_PEDIDO,"1","Y5_FORNECE"), AE100GetEmpr((cFlow)->EET_PEDIDO,"1","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ3_FORNDP", oSeeker:Seek( "HKJ", { AE100GetEmpr((cFlow)->EET_PEDIDO,"6","Y5_FORNECE"), AE100GetEmpr((cFlow)->EET_PEDIDO,"6","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ3_FORNSG", oSeeker:Seek( "HKJ", { AE100GetEmpr((cFlow)->EET_PEDIDO,"A","Y5_FORNECE"), AE100GetEmpr((cFlow)->EET_PEDIDO,"A","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ3_NATEXP", oSeeker:Seek( "HGP", { Iif(Empty((cFlow)->EEC_TIPO), "1", (cFlow)->EEC_TIPO ) } ) )
			oRecord:SetValue( "HQ3_FORNDS", oSeeker:Seek( "HKJ", { (cFlow)->EET_FORNEC, (cFlow)->EET_LOJAF } ) )
			oRecord:SetValue( "HQ3_SITEXP", oSeeker:Seek( "HGJ", { (cFlow)->EEC_STATUS } ) )
			oRecord:SetValue( "HQ3_CLIENT", oSeeker:Seek( "HJ7", { (cFlow)->EEC_IMPORT, (cFlow)->EEC_IMLOJA } ) )
			oRecord:SetValue( "HQ3_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A1_EST, (cFlow)->A1_COD_MUN, (cFlow)->A1_PAIS ) } ) )
			oRecord:SetValue( "HQ3_INCOTR", oSeeker:Seek( "HGM", { (cFlow)->EEC_INCOTE } ) )
			oRecord:SetValue( "HQ3_DESPES", oSeeker:Seek( "HGL", { (cFlow)->EET_DESPES } ) )
			oRecord:SetValue( "HQ3_VIATRA", oSeeker:Seek( "HGR", { SubStr( (cFlow)->YQ_COD_DI , 1 , 1 ) } ) )
			oRecord:SetValue( "HQ3_DATA"  , IIf(!Empty((cFlow)->EEC_DTPROC),(cFlow)->EEC_DTPROC, DATE_EMPTY) )
			oRecord:SetValue( "HQ3_DTEMBA", IIf(!Empty((cFlow)->EEC_DTEMBA),(cFlow)->EEC_DTEMBA, DATE_EMPTY) )
			oRecord:SetValue( "HQ3_DTCBDP", IIf(!Empty((cFlow)->EET_DESADI),(cFlow)->EET_DESADI, DATE_EMPTY) )
			oRecord:SetValue( "HQ3_ITINER", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQ3_PTOCTR", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQ3_CLDESP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQ3_CONDPG", oSeeker:oKey:GetKey( { UNDEFINED } ) )	

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HQ3_NPREXP", (cFlow)->EET_PEDIDO	)
			oRecord:SetValue( "HQ3_DTPPTC", DATE_EMPTY )
			oRecord:SetValue( "HQ3_DTULPV", DATE_EMPTY )
			oRecord:SetValue( "HQ3_DTEPTC", DATE_EMPTY )
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQ3_VDESPD", BIXValue((cFlow)->EET_VALORR ,(cFlow)->EEC_MOEDA, cMoeda,(cFlow)->EEC_DTPROC) ) 
			oRecord:SetValue( "HQ3_SEQPTO", 0 )
			oRecord:SetValue( "HQ3_VDESPI", 0 )
			oRecord:SetValue( "HQ3_VTXFIN", 0 )
			oRecord:SetValue( "HQ3_VDESDX", 0 )

			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next 	
		(cFlow)->( DbSkip() )   
	EndDo
	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return nil

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

@author  Marcia Junko
@since   22/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXExpDespesa
	Local cDML 	:= ""
	
	cDML := "SELECT EET_PEDIDO, EET_FORNEC, EET_LOJAF, "
	cDML += "   EET_DESADI, EET_SEQ, EET_DESPES, EET_VALORR, EET.R_E_C_N_O_ ID, "
	cDML += "   EEC_IMPORT, EEC_IMLOJA, EEC_VIA, EEC_TIPO, "
	cDML += "   EEC_DTPROC, EEC_DTEMBA, EEC_MOEDA, "
	cDML += "   EEC_INCOTE, EEC_STATUS, A1_TIPO, A1_EST, A1_COD_MUN, A1_PAIS, YQ_COD_DI "
	cDML += "FROM " + RetSqlName("EET") + " EET "
	cDML += "INNER JOIN " + RetSqlName("EEC") + " EEC "
	cDML += "ON EEC_FILIAL = EET_FILIAL "
	cDML += "   AND EEC_PREEMB = EET_PEDIDO "
	cDML += "   AND EEC_DTPROC BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	cDML += "   AND EEC.D_E_L_E_T_ = ' ' "
	cDML += "LEFT JOIN " + RetSqlName("SYQ") + " SYQ "
	cDML += "ON YQ_FILIAL = '" + xFilial("SYQ") + "' "
	cDML += "   AND YQ_VIA = EEC_VIA "
	cDML += "   AND SYQ.D_E_L_E_T_ = ' ' "
	cDML += "LEFT JOIN " + RetSQLName("SA1") + " SA1 "
	cDML += "ON A1_FILIAL = '" + xFilial("SA1") + "' "
	cDML += "	 AND A1_COD = EEC_IMPORT "
	cDML += "   AND A1_LOJA = EEC_IMLOJA "
	cDML += "	 AND SA1.D_E_L_E_T_ = ' ' "	
	cDML += "WHERE EET_FILIAL = '" + xFilial("EET") + "' "
	cDML += "   AND EET_OCORRE = 'Q' 
	cDML += "   AND EET.D_E_L_E_T_ = ' '" 

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  		
	cDML := ChangeQuery( cDML )

	//-------------------------------------------------------------------
	// Abre a �rea de trabalho tempor�ria. 
	//------------------------------------------------------------------- 	
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)       	

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "EET_DESADI", "D", 8, 0 )
	TcSetField( ::cFlow, "EEC_DTPROC", "D", 8, 0 )
	TcSetField( ::cFlow, "EEC_DTEMBA", "D", 8, 0 )
Return ::cFlow 