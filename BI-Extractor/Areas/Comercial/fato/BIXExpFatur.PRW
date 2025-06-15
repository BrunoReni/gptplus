#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEXPFATUR.CH"

REGISTER EXTRACTOR HQ2 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXExpFatur
Fato Exportação - Faturamento apresenta informações relacionadas aos valores
faturados no processo de exportação

@author  Helio Leal
@since   05/05/2017
/*/
//-------------------------------------------------------------------
Class BIXExpFatur from BIXEntity
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
@since   05/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXExpFatur
	_Super:New( FACT, "HQ2", STR0001, "SD2", { COMERCIAL } ) //"Exportação - Faturamento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   14/09/2015
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXExpFatur 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HQ2_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HQ2_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HQ2_CANALV",	"C",	32, 00, .T., "HGA" ) //"Canal Vendas"
	oModel:AddField( "HQ2_REGCOM",	"C",	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HQ2_MICREG",	"C",	32, 00, .T., "HGB" ) //"Microrregião"
	oModel:AddField( "HQ2_TRANSP",	"C", 	32, 00, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HQ2_FORNTI",	"C",	32, 00, .T., "HJ2" ) //Transportadora Internacional
	oModel:AddField( "HQ2_FORNAC",	"C",	32, 00, .T., "HJ2" ) //Agente Carga 
	oModel:AddField( "HQ2_FORNDP",	"C",	32, 00, .T., "HJ2" ) //Despachante
	oModel:AddField( "HQ2_FORNSG",	"C",	32, 00, .T., "HJ2" ) //Seguradora
	oModel:AddField( "HQ2_REPRES",	"C",	32, 00, .T., "HJC" ) //"Representante"	
	oModel:AddField( "HQ2_ITEM",	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HQ2_FAMCOM",	"C",	32, 00, .T., "HG1" ) //"Família Comercial"	
	oModel:AddField( "HQ2_FAMMAT",	"C",	32, 00, .T., "HG2" ) //"Famíalia Material"	
	oModel:AddField( "HQ2_GRPEST",	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HQ2_PRDUTO",	"C",	32, 00, .T., "HJ3" ) //"Produto"
	oModel:AddField( "HQ2_REFER",	"C",	32, 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HQ2_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HQ2_CONDPG",	"C", 	32, 00, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HQ2_CLIENT",	"C",	32, 00, .T., "HJ7" ) //"Clientes"
	oModel:AddField( "HQ2_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"
	oModel:AddField( "HQ2_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HQ2_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HQ2_UNITEM",	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HQ2_NATOPR",	"C",	32, 00, .T., "HJ9" ) //"Natureza da Operação"
	oModel:AddField( "HQ2_CFOP",	"C",	32, 00, .T., "HG0" ) //"CFOP"
	oModel:AddField( "HQ2_SITEXP",	"C",	32, 00, .T., "HGJ" ) //"Situação Exportação"
	oModel:AddField( "HQ2_VIATRA",	"C",	32, 00, .T., "HGR" ) //"Via Transporte"
	oModel:AddField( "HQ2_INCOTR",	"C",	32, 00, .T., "HGM" ) //"Incoterm"
	oModel:AddField( "HQ2_NATEXP",	"C",	32, 00, .T., "HGP" ) //"Natureza Exportação"
	oModel:AddField( "HQ2_ITINER",	"C",	32, 00, .T., "HGQ" ) //"Itinerário"
	oModel:AddField( "HQ2_DATA",	"D",	08, 00, .F., "HK2" ) //"Período"
	oModel:AddField( "HQ2_DTEXPP",	"D",	08, 00 ) // "Data de Implantação da Exportação"
	oModel:AddField( "HQ2_DTEMBA",	"D",	08, 00 ) // "Data de Embarque"
	oModel:AddField( "HQ2_VLULIQ",	"N",	16,	02 ) // "Vl Unitário Líquido"
	oModel:AddField( "HQ2_VLUORI",	"N",	16,	02 ) // "Vl Unitário Original"
	oModel:AddField( "HQ2_QFATIT",	"N",	16,	04 ) // "Qtde Faturada Item"
	oModel:AddField( "HQ2_VLTOTP",	"N",	16,	02 ) // "Vl Total do Processo"
	oModel:AddField( "HQ2_VDESEX",	"N",	16,	02 ) // "Vl Desconto Exportação"
	oModel:AddField( "HQ2_VDESPD",	"N",	16,	02 ) // "Vl Despesa Direta"
	oModel:AddField( "HQ2_VDESPI",	"N",	16,	02 ) // "Vl Despesa Indireta"
	oModel:AddField( "HQ2_VLLIQP",	"N",	16,	02 ) // "Vl Líquido do Processo"
	oModel:AddField( "HQ2_VDSEXT",	"N",	16,	02 ) // "Vl Complementar"
	oModel:AddField( "HQ2_QTPESL",	"N",	16,	04 ) // "Peso Líquido"
	oModel:AddField( "HQ2_QTPESB",	"N",	16,	04 ) // "Peso Bruto"
	oModel:AddField( "HQ2_SEQINF",	"C",	10, 00 ) // "Sequência do Item na Nota"
	oModel:AddField( "HQ2_SERNF",	"C",	08, 00 ) // "Série da Nota Fiscal"
	oModel:AddField( "HQ2_NUMNF",	"C",	35, 00 ) // "Número da Nota Fiscal"
	oModel:AddField( "HQ2_NPREXP",	"C",	20, 00 ) // "Número Processo Exportação"
	oModel:AddField( "HQ2_PEDIDO",	"C",	12, 00 ) // "Número do Pedido de Venda"
	oModel:AddField( "HQ2_SEQIPE",	"C",	10, 00 ) // "Sequência do Item no Pedido" 

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
@since   05/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXExpFatur
	Local nFee		:= 0
	Local nMoeda	:= 0
	Local aMoeda  := {}
	Local cMoeda  := ""
	Local cFlow	:= ""
	Local oRegion	:= Nil	
	Local lFee		:= .F.
	Local lRepres := .F.

	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato.
	//-------------------------------------------------------------------
	aMoeda 	:= BIXGetMxF( ::cEntity )	
	lFee 		:= BIXParInfo( "BIX_TXMOED"	, "L", .F. )
	lRepres 	:= BIXParInfo( "BIX_REPRES"	, "L", .F. )
	oRegion 	:= BIXRegiao():New()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )
	
	While ! (cFlow)->( Eof() )
		//-------------------------------------------------------------------
		// Identifica se utiliza a taxa negociada para moeda. 
		//------------------------------------------------------------------- 
		If ( ! cPaisLoc == "BRA" .Or. lFee )
			nFee := (cFlow)->F2_TXMOEDA
		Endif

		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro.
			//-------------------------------------------------------------------
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D2_DOC"		, (cFlow)->D2_DOC )
			oRecord:SetValue( "D2_SERIE"	, (cFlow)->D2_SERIE )
			oRecord:SetValue( "D2_CLIENTE"	, (cFlow)->D2_CLIENTE )
			oRecord:SetValue( "D2_LOJA"		, (cFlow)->D2_LOJA )
			oRecord:SetValue( "D2_ITEM"		, (cFlow)->D2_ITEM )
			oRecord:SetValue( "A1_COD"		, (cFlow)->D2_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->D2_LOJA ) 
			oRecord:SetValue( "ACU_COD"		, (cFlow)->ACV_CATEGO )
			oRecord:SetValue( "ACY_GRPVEN"	, (cFlow)->A1_GRPVEN )
			oRecord:SetValue( "B1_COD"		, (cFlow)->D2_COD )	
			oRecord:SetValue( "BM_GRUPO"	, (cFlow)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cFlow)->D2_UM )
			oRecord:SetValue( "YJ_COD"		, (cFlow)->EEC_INCOTE )				
			oRecord:SetValue( "A4_COD"		, (cFlow)->F2_TRANSP )
			oRecord:SetValue( "E4_CODIGO"	, (cFlow)->F2_COND )
			oRecord:SetValue( "F4_CODIGO"	, (cFlow)->D2_TES )
			oRecord:SetValue( "A3_COD"		, iif( lRepres, (cFlow)->A1_VEND, (cFlow)->F2_VEND1 ) )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HQ2_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HQ2_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HQ2_REGCOM"	, oSeeker:Seek( "HGD", { (cFlow)->A1_GRPVEN } ) )
			oRecord:SetValue( "HQ2_MICREG"	, oSeeker:Seek( "HGB", { (cFlow)->A1_REGIAO } ) )
			oRecord:SetValue( "HQ2_TRANSP"	, oSeeker:Seek( "HJ2", { (cFlow)->F2_TRANSP } ) )
			oRecord:SetValue( "HQ2_REPRES"	, oSeeker:Seek( "HJC", { iif( lRepres, (cFlow)->A1_VEND, (cFlow)->F2_VEND1 ) } ) )
			oRecord:SetValue( "HQ2_ITEM"	, oSeeker:Seek( "HJ8", { (cFlow)->D2_COD } ) ) 
			oRecord:SetValue( "HQ2_FAMCOM" 	, oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) )
			oRecord:SetValue( "HQ2_FAMMAT"	, oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) )
			oRecord:SetValue( "HQ2_GRPEST"	, oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) )
			oRecord:SetValue( "HQ2_GRPCLI"	, oSeeker:Seek( "HJ0", { (cFlow)->A1_TIPO } ) )
			oRecord:SetValue( "HQ2_CONDPG"	, oSeeker:Seek( "HJA", { (cFlow)->F2_COND } ) )
			oRecord:SetValue( "HQ2_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->D2_CLIENTE, (cFlow)->D2_LOJA } ) )
			oRecord:SetValue( "HQ2_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A1_EST, (cFlow)->A1_COD_MUN, (cFlow)->A1_PAIS ) } ) )
			oRecord:SetValue( "HQ2_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HQ2_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HQ2_UNITEM" 	, oSeeker:Seek( "HHW", { (cFlow)->D2_UM } )) 
			oRecord:SetValue( "HQ2_NATOPR" 	, oSeeker:Seek( "HJ9", { (cFlow)->D2_TES } )) 
			oRecord:SetValue( "HQ2_CFOP" 	, oSeeker:Seek( "HG0", { (cFlow)->D2_CF } ))
			oRecord:SetValue( "HQ2_SITEXP" 	, oSeeker:Seek( "HGJ", { (cFlow)->EEC_STATUS } ))
			oRecord:SetValue( "HQ2_INCOTR" 	, oSeeker:Seek( "HGM", { (cFlow)->EEC_INCOTE } ))
			oRecord:SetValue( "HQ2_NATEXP" 	, oSeeker:Seek( "HGP", { iif( Empty( (cFlow)->EEC_TIPO ), '1', (cFlow)->EEC_TIPO ) } ))
			oRecord:SetValue( "HQ2_FORNTI"	, oSeeker:Seek( "HJ2", { AE100GetEmpr((cFlow)->D2_PREEMB,"B","Y5_FORNECE"), AE100GetEmpr((cFlow)->D2_PREEMB,"B","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ2_FORNAC"	, oSeeker:Seek( "HJ2", { AE100GetEmpr((cFlow)->D2_PREEMB,"1","Y5_FORNECE"), AE100GetEmpr((cFlow)->D2_PREEMB,"1","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ2_FORNDP"	, oSeeker:Seek( "HJ2", { AE100GetEmpr((cFlow)->D2_PREEMB,"6","Y5_FORNECE"), AE100GetEmpr((cFlow)->D2_PREEMB,"6","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ2_FORNSG"	, oSeeker:Seek( "HJ2", { AE100GetEmpr((cFlow)->D2_PREEMB,"A","Y5_FORNECE"), AE100GetEmpr((cFlow)->D2_PREEMB,"A","Y5_LOJAF") } ) )
			oRecord:SetValue( "HQ2_VIATRA" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQ2_CANALV" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQ2_PRDUTO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 	
			oRecord:SetValue( "HQ2_REFER" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQ2_ITINER" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQ2_SEQINF"	, (cFlow)->D2_ITEM )
			oRecord:SetValue( "HQ2_SERNF"	, SerieNFID( cFlow, 2, "F2_SERIE") )
			oRecord:SetValue( "HQ2_NUMNF"	, (cFlow)->F2_DOC )
			oRecord:SetValue( "HQ2_NPREXP"	, (cFlow)->D2_PREEMB )
			oRecord:SetValue( "HQ2_PEDIDO"	, (cFlow)->D2_PEDIDO )
			oRecord:SetValue( "HQ2_SEQIPE"	, (cFlow)->D2_ITEMPV )
			oRecord:SetValue( "HQ2_QFATIT"	, (cFlow)->D2_QUANT )			
			oRecord:SetValue( "HQ2_DATA" 	, IIf(!Empty( (cFlow)->F2_EMISSAO), (cFlow)->F2_EMISSAO, DATE_EMPTY) )			
			oRecord:SetValue( "HQ2_DTEXPP" 	, IIf(!Empty( (cFlow)->EEC_DTPROC), (cFlow)->EEC_DTPROC, DATE_EMPTY) )			
			oRecord:SetValue( "HQ2_DTEMBA" 	, IIf(!Empty( (cFlow)->EEC_DTEMBA), (cFlow)->EEC_DTEMBA, DATE_EMPTY) )			
			oRecord:SetValue( "HQ2_VLULIQ"	, BIXValue((cFlow)->D2_PRCVEN ,(cFlow)->F2_MOEDA,cMoeda,(cFlow)->F2_EMISSAO, nFee) )			
			oRecord:SetValue( "HQ2_VLUORI"	, BIXValue((cFlow)->D2_PRUNIT ,(cFlow)->F2_MOEDA,cMoeda,(cFlow)->F2_EMISSAO, nFee) )
			oRecord:SetValue( "HQ2_VLTOTP"	, BIXValue((cFlow)->D2_VALBRUT,(cFlow)->F2_MOEDA,cMoeda,(cFlow)->F2_EMISSAO, nFee) )
			oRecord:SetValue( "HQ2_VDESEX"	, BIXValue((cFlow)->D2_DESCON ,(cFlow)->F2_MOEDA,cMoeda,(cFlow)->F2_EMISSAO, nFee) )
			oRecord:SetValue( "HQ2_VLLIQP"	, BIXValue((cFlow)->D2_TOTAL  ,(cFlow)->F2_MOEDA,cMoeda,(cFlow)->F2_EMISSAO, nFee) )
			oRecord:SetValue( "HQ2_VDESPD"	, BIXValue(( (cFlow)->D2_DESPESA + (cFlow)->D2_VALFRE + (cFlow)->D2_SEGURO ) ,(cFlow)->F2_MOEDA,cMoeda,(cFlow)->F2_EMISSAO, nFee) ) 

			If SC5->( DBSeek( xFilial("SC5") + (cFlow)->D2_PEDIDO ))
				oRecord:SetValue( "HQ2_QTPESL"	, CalcPeso( SC5->C5_PEDEXP , (cFlow)->D2_ITEMPV , (cFlow)->D2_QUANT)[1] )
				oRecord:SetValue( "HQ2_QTPESB"	, CalcPeso( SC5->C5_PEDEXP , (cFlow)->D2_ITEMPV , (cFlow)->D2_QUANT)[2] )
			Else     
				oRecord:SetValue( "HQ2_QTPESL"	, 0)
				oRecord:SetValue( "HQ2_QTPESB"	, 0)                                                                                 
			EndIf
			
			oRecord:SetValue( "HQ2_VDESPI"	, 0)
			oRecord:SetValue( "HQ2_VDSEXT"	, 0)
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda	

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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXExpFatur
	Local cDML 	:= ""

	cDML := "SELECT D2_CLIENTE, D2_LOJA, D2_COD, D2_CF, D2_TES, D2_DOC, "
	cDML += "   D2_SERIE, D2_PREEMB, D2_ITEM, D2_PEDIDO, D2_ITEMPV, "
	cDML += "   D2_QUANT, D2_PRCVEN, D2_PRUNIT, D2_VALBRUT, D2_DESCON, "
	cDML += "   D2_TOTAL, D2_DESPESA, D2_VALFRE, D2_SEGURO, D2_UM, SD2.R_E_C_N_O_ ID, "
	cDML += "   F2_SERIE, F2_DOC, F2_EMISSAO, F2_MOEDA, F2_TRANSP, "
	cDML += "   F2_COND, F2_VEND1, F2_TXMOEDA, "
	cDML += "   B1_GRUPO, B1_TIPO, "
	cDML += "   A1_GRPVEN, A1_REGIAO, A1_VEND, A1_TIPO, A1_EST, A1_COD_MUN, A1_PAIS, "
	cDML += "   EEC_STATUS, EEC_DTPROC, EEC_DTEMBA, EEC_INCOTE, EEC_TIPO, "
	cDML += "   ACV_CATEGO "
	cDML += "FROM " + RetSQLName("SD2") + " SD2 "
	cDML += "INNER JOIN " + RetSqlName("SF2") + " SF2 "
	cDML += "ON F2_FILIAL = '" + xFilial("SF2") + "' "
	cDML += "   AND F2_DOC = D2_DOC " 
	cDML += "   AND F2_SERIE = D2_SERIE "
	cDML += "   AND F2_CLIENTE = D2_CLIENTE "
	cDML += "   AND F2_LOJA = D2_LOJA "
	cDML += "   AND SF2.D_E_L_E_T_ = ' ' "
	cDML += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cDML += "ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cDML += "   AND B1_COD = D2_COD "
	cDML += "   AND SB1.D_E_L_E_T_ = ' ' "
	cDML += "LEFT JOIN " + RetSQLName("SA1") + " SA1 "
	cDML += "	ON (A1_FILIAL = '" +	 xFilial("SA1") + "' AND SA1.A1_COD = D2_CLIENTE "
	cDML += "   AND SA1.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("EEC") + " EEC "
	cDML += "	ON (EEC_FILIAL = '" +	 xFilial("EEC") + "' AND EEC.EEC_PREEMB = SD2.D2_PREEMB "
	cDML += "   AND EEC.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cDML += "	ON (ACV_FILIAL = '" +	 xFilial("ACV") + "' AND ACV_CODPRO = D2_COD "
	cDML += "   AND ACV.D_E_L_E_T_ = ' ') "		
	cDML += "WHERE D2_FILIAL = '" + xFilial("SD2") + "' "
	cDML += "   AND D2_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' " 
	cDML += "   AND D2_PREEMB <> ' ' " 
	cDML += "   AND SD2.D_E_L_E_T_ = ' ' " 
	cDML += "ORDER BY D2_EMISSAO"

	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias() , .T., .F. )

	//-------------------------------------------------------------------
	// Converte os campos para o tipo correto.
	//-------------------------------------------------------------------  	
	TCSetField( ::cFlow, "F2_EMISSAO", "D", 08, 0 )	
Return ::cFlow 