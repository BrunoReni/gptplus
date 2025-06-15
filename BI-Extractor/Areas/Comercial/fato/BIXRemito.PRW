#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREMITO.CH"

REGISTER EXTRACTOR HHA 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRemito

@author  Tamara Clemente
@since   08/05/2013
/*/
//-------------------------------------------------------------------
Class BIXRemito from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara Clemente
@since   08/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXRemito
	_Super:New( FACT, "HHA", STR0001, "SD2", { COMERCIAL } ) //"Remito"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   08/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXRemito 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HHA_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HHA_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HHA_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HHA_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HHA_TABPCO",	"C",	32, 00, .T., "HGN" ) //"Tabela de Preço"
	oModel:AddField( "HHA_CANALV",	"C",	32, 00, .T., "HGA" ) //"Canal de Venda"	
	oModel:AddField( "HHA_ITEM",	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HHA_FAMCOM",	"C",	32, 00, .T., "HG1" ) //"Família Comercial"	
	oModel:AddField( "HHA_FAMMAT",	"C",	32, 00, .T., "HG2" ) //"Famíalia Material"
	oModel:AddField( "HHA_GRPEST",	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HHA_PRDUTO",	"C",	32, 00, .T., "HJ3" ) //"Produto"
	oModel:AddField( "HHA_REPRES",	"C",	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HHA_TRANSP",	"C",	32, 00, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HHA_ROTA",	"C",	32, 00, .T., "HGI" ) //"Rota"
	oModel:AddField( "HHA_NATOPR",	"C",	32, 00, .T., "HJ9" ) //"Natureza da Operação"
	oModel:AddField( "HHA_CFOP",	"C",	32, 00, .T., "HG0" ) //"CFOP"
	oModel:AddField( "HHA_REGCOM",	"C",	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HHA_MICREG",	"C",	32, 00, .T., "HGB" ) //"Microrregião"
	oModel:AddField( "HHA_REFER",	"C",	32, 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HHA_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HHA_CLIENT",	"C",	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HHA_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"
	oModel:AddField( "HHA_CONDPG",	"C",	32, 00, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HHA_UNITEM" ,	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HHA_TRARED",	"C",	32, 00, .T., "HJ2" ) //"Transportadora de Redespacho"	
	oModel:AddField( "HHA_DATA",	"D",	08, 00,	.F., "HK2" ) //"Período - Data da Emissão da Nota Fiscal"
	
	oModel:AddField( "HHA_DTSANF",	"D",	08, 00) //"Data de Saída da Nota Fiscal"	
	
	oModel:AddField( "HHA_SERNF",	"C",	08, 00 ) //Série da Nota Fiscal
	oModel:AddField( "HHA_NUMNF",	"C",	35, 00 ) //Número da Nota Fiscal
	oModel:AddField( "HHA_NMITNF",	"C",	10, 00 ) //Número do Item
	oModel:AddField( "HHA_REMITO",	"C",	13, 00 ) //Número do Remito
	oModel:AddField( "HHA_SERREM",	"C",	03, 00 ) //Série do Remito
	oModel:AddField( "HHA_ITEREM",	"C",	04, 00 ) //Item do Remito
	oModel:AddField( "HHA_PEDIDO",	"C",	12, 00 ) //Número do Pedido de Venda
	oModel:AddField( "HHA_FGERDP",	"C",	01, 00 ) //Item Gera Duplicata?
	oModel:AddField( "HHA_TPFRET",	"C",	03, 00 ) //Tipo de Frete
	oModel:AddField( "HHA_TPNOTA",	"C",	20, 00 ) //Tipo de Nota Fiscal
	oModel:AddField( "HHA_FBXEST",	"C",	01, 00 ) //Item Baixa Estoque?
	oModel:AddField( "HHA_TPCPIT",	"C",	20, 00 ) //Tipo de Item da Nota Fiscal
	
	oModel:AddField( "HHA_VFATOT",	"N",	16,	02 ) //Vl Faturamento Total
	oModel:AddField( "HHA_VCMFAT",	"N",	16,	02 ) //Vl Comissão Faturamento
	oModel:AddField( "HHA_VLCSFT",	"N",	16,	02 ) //Vl Custo Faturamento
	oModel:AddField( "HHA_VLDESF",	"N",	16,	02 ) //Vl Desconto Faturamento
	oModel:AddField( "HHA_VRECFI",	"N",	16,	02 ) //Vl Receita Financeira
	oModel:AddField( "HHA_VFRTNF",	"N",	16,	02 ) //Vl Frete NF
	oModel:AddField( "HHA_VDESPE",	"N",	16,	02 ) //Vl Despesas
	oModel:AddField( "HHA_VFATME",	"N",	16,	02 ) //Vl Faturamento Mercadoria
	oModel:AddField( "HHA_VFATLQ",	"N",	16,	02 ) //Vl Faturamento Líquido
	oModel:AddField( "HHA_VCTCTB",	"N",	16,	02 ) //Vl Custo Contábil
	oModel:AddField( "HHA_QFATIT",	"N",	16,	04 ) //Quantidade Faturada Item
	oModel:AddField( "HHA_QFATFM",	"N",	16,	04 ) //Quantidade Faturada Familia Material
	oModel:AddField( "HHA_QFATFC",	"N",	16,	04 ) //Quantidade Faturada Familia Comercial
	oModel:AddField( "HHA_QPDREM",	"N",	16,	04 ) //Quantidade Pedida Remito
	oModel:AddField( "HHA_QPRZDP",	"N",	16,	04 ) //Quantidade Prazo Duplicata 
	oModel:AddField( "HHA_QTPESL",	"N",	16,	04 ) //Peso Líquido
	oModel:AddField( "HHA_QTPESB",	"N",	16,	04 ) //Peso Bruto

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

@author  Tamara Clemente
@since   08/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXRemito
	Local oRegion		:= nil	
	Local aMoeda 		:= {}
	Local aCFOP     	:= XFUNCFRec()	
	Local cMoeda		:= ""
	Local cCampoCusto	:= ""
	Local nMoeda		:= 0
	Local nVlFatLiquido	:= 0 
	Local nTxMoeda		:= 0
	Local nQtdFatItem	:= 0
	Local nDuplicata	:= 0
	Local nQtdDuplic	:= 0
	Local nComisaoFat	:= 0	
	
	//-------------------------------------------------------------------
	// Define se visualiza o preço de venda com desconto
	//------------------------------------------------------------------- 	
	Local lDescSai		:= Iif( GetMv("MV_DESCSAI") == "1", .T., .F. )
	//-------------------------------------------------------------------
	// Define se a instalação do Protheus é "Brasil"
	//------------------------------------------------------------------- 	
	Local lBra			:= cPaisLoc == "BRA"
	//-------------------------------------------------------------------
	// Define a utilização da taxa negociada na conversão de moeda.
	//------------------------------------------------------------------- 	
	Local lTxMoeda 		:= LoadTxMoeda()
	
	Private cRetAlias	:= ""		
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda 	  := BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cRetAlias := ::Flow( cFrom, cTo ) 

	While ! (cRetAlias)->( Eof() )
	  	If lBra .And. At(AllTrim((cRetAlias)->D2_CF) , aCFOP[1]) == 0
			(cRetAlias)->(DbSkip()) 
			Loop                
	   	EndIf

		If !IsRemito(1,'(cRetAlias)->D2_TIPODOC')
			(cRetAlias)->(dBSkip())
			Loop
		Endif	

		nQtdFatItem := 0	 
		nTxMoeda 	:= 0
		
		//-------------------------------------------------------------------
		// No Mercado internacional, as tabelas SC5, SC7, SF1, SF2, SE1, 
		// SE5 e SE2 utilizam o campo ??_TXMOEDA (TAXA NEGOCIADA) que define
		// a taxa usada para a operação, caso seja ZERO deve ser considerada 
		// a cotação da moeda para o dia.
		//-------------------------------------------------------------------			
		If cPaisLoc != "BRA" .Or. lTxMoeda
			nTxMoeda := (cRetAlias)->F2_TXMOEDA 
		EndIf

		//-------------------------------------------------------------------
		// Determina a qtd faturada do item
		//-------------------------------------------------------------------				
		SD2->( dbSetOrder(9) )
		If SD2->(MsSeek(xFilial("SD2") + (cRetAlias)->D2_CLIENTE + (cRetAlias)->D2_LOJA + (cRetAlias)->D2_SERIE + (cRetAlias)->D2_DOC + (cRetAlias)->D2_ITEM))
			nQtdFatItem := (cRetAlias)->D2_QUANT
		Else
			nQtdFatItem := 0			
		EndIf

		//-------------------------------------------------------------------
		// Determina o valor de comissão do vendedor
		//-------------------------------------------------------------------			
		If SA3->(MsSeek(xFilial("SA3") + (cRetAlias)->F2_VEND1))
			nComisaoFat := ((cRetAlias)->D2_TOTAL * (SA3->A3_COMIS/100))
		Else
			nComisaoFat := 0
		EndIf		

		//-------------------------------------------------------------------
		// Determina o valor do faturamento líquido
		//-------------------------------------------------------------------		
		If lDescSai
			nVlFatLiquido := (cRetAlias)->D2_TOTAL - (cRetAlias)->D2_DESCON
		Else
			nVlFatLiquido := (cRetAlias)->D2_TOTAL
		EndIf
		
		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]
			cCampoCusto := "(cRetAlias)->D2_CUSTO" + cMoeda
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D2_DOC"		, (cRetAlias)->D2_DOC ) 
			oRecord:SetValue( "D2_SERIE"	, (cRetAlias)->D2_SERIE ) 
			oRecord:SetValue( "D2_CLIENTE"	, (cRetAlias)->D2_CLIENTE )
			oRecord:SetValue( "D2_LOJA"		, (cRetAlias)->D2_LOJA )
			oRecord:SetValue( "D2_ITEM"		, (cRetAlias)->D2_ITEM )
			oRecord:SetValue( "DA0_CODTAB"	, (cRetAlias)->C5_TABELA )
			oRecord:SetValue( "B1_COD"		, (cRetAlias)->D2_COD )
			oRecord:SetValue( "ACU_COD"		, (cRetAlias)->ACV_CATEGO )			
			oRecord:SetValue( "BM_GRUPO"	, (cRetAlias)->B1_GRUPO )
			oRecord:SetValue( "A3_COD"		, (cRetAlias)->F2_VEND1 )
			oRecord:SetValue( "A4_COD"		, (cRetAlias)->F2_TRANSP )
			oRecord:SetValue( "F4_CODIGO"	, (cRetAlias)->D2_TES )
			oRecord:SetValue( "ACY_GRPVEN"	, (cRetAlias)->A1_GRPVEN )
			oRecord:SetValue( "A1_COD"		, (cRetAlias)->D2_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cRetAlias)->D2_LOJA )	
			oRecord:SetValue( "E4_CODIGO"	, (cRetAlias)->F2_COND )	
			oRecord:SetValue( "AH_UNIMED"	, (cRetAlias)->D2_UM )	

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HHA_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HHA_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HHA_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HHA_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HHA_TABPCO"	, oSeeker:Seek( "HGN", { (cRetAlias)->C5_TABELA } ) )	
			oRecord:SetValue( "HHA_ITEM"	, oSeeker:Seek( "HJ8", { (cRetAlias)->D2_COD } ) )
			oRecord:SetValue( "HHA_FAMCOM"	, oSeeker:Seek( "HG2", { (cRetAlias)->ACV_CATEGO } ) )
			oRecord:SetValue( "HHA_FAMMAT"	, oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) )
 			oRecord:SetValue( "HHA_GRPEST"	, oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) )
			oRecord:SetValue( "HHA_REPRES"	, oSeeker:Seek( "HJC", { (cRetAlias)->F2_VEND1 } ) )
			oRecord:SetValue( "HHA_TRANSP"	, oSeeker:Seek( "HJ2", { (cRetAlias)->F2_TRANSP } ) )
			oRecord:SetValue( "HHA_NATOPR"	, oSeeker:Seek( "HJ9", { (cRetAlias)->D2_TES } ) )
 			oRecord:SetValue( "HHA_CFOP"	, oSeeker:Seek( "HG0", { (cRetAlias)->D2_CF } ) )
			oRecord:SetValue( "HHA_REGCOM"	, oSeeker:Seek( "HGD", { (cRetAlias)->A1_GRPVEN } ) )
			oRecord:SetValue( "HHA_MICREG"	, oSeeker:Seek( "HGB", { (cRetAlias)->A1_REGIAO } ) )			
			oRecord:SetValue( "HHA_GRPCLI"	, oSeeker:Seek( "HJ0", { (cRetAlias)->A1_TIPO } ) )
			oRecord:SetValue( "HHA_CLIENT"	, oSeeker:Seek( "HJ7", { (cRetAlias)->D2_CLIENTE, (cRetAlias)->D2_LOJA } ) )			
			oRecord:SetValue( "HHA_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( (cRetAlias)->A1_EST, (cRetAlias)->A1_COD_MUN, (cRetAlias)->A1_PAIS ) } ) )
			oRecord:SetValue( "HHA_CONDPG"	, oSeeker:Seek( "HJA", { (cRetAlias)->F2_COND } ) )
 			oRecord:SetValue( "HHA_UNITEM"	, oSeeker:Seek( "HHW", { (cRetAlias)->D2_UM } ) )
			oRecord:SetValue( "HHA_TRARED"	, oSeeker:Seek( "HJ2", { (cRetAlias)->F2_REDESP } ) )
			oRecord:SetValue( "HHA_CANALV"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )					
 			oRecord:SetValue( "HHA_PRDUTO"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HHA_ROTA"	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 						
 			oRecord:SetValue( "HHA_REFER"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )

			oRecord:SetValue( "HHA_DATA"	, IIf(!Empty((cRetAlias)->F2_EMISSAO), (cRetAlias)->F2_EMISSAO, DATE_EMPTY) )
			oRecord:SetValue( "HHA_DTSANF"	, IIf(!Empty((cRetAlias)->F2_EMISSAO), (cRetAlias)->F2_EMISSAO, DATE_EMPTY) )				

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HHA_SERNF", SerieNFID( cRetAlias, 2, "F2_SERIE"))
			oRecord:SetValue( "HHA_NUMNF" , (cRetAlias)->F2_DOC	)
			oRecord:SetValue( "HHA_NMITNF", (cRetAlias)->D2_ITEM )
			oRecord:SetValue( "HHA_REMITO", (cRetAlias)->D2_REMITO)
			oRecord:SetValue( "HHA_SERREM", SerieNFID( cRetAlias, 2, "D2_SERIREM"))
			oRecord:SetValue( "HHA_ITEREM", (cRetAlias)->D2_ITEMREM)
			oRecord:SetValue( "HHA_PEDIDO", (cRetAlias)->D2_PEDIDO)
			oRecord:SetValue( "HHA_TPFRET", (cRetAlias)->F2_TPFRETE)
			oRecord:SetValue( "HHA_TPNOTA", (cRetAlias)->D2_TIPO)
			oRecord:SetValue( "HHA_TPCPIT", " ")
			If SF4->(MsSeek(xFilial("SF4") + (cRetAlias)->D2_TES ))
				oRecord:SetValue( "HHA_FBXEST", SF4->F4_ESTOQUE )
				oRecord:SetValue( "HHA_FGERDP", SF4->F4_DUPLIC )
			Else
				oRecord:SetValue( "HHA_FBXEST", " " )
				oRecord:SetValue( "HHA_FGERDP", " " )
			EndIf			

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HHA_VFATOT", BIXValue((cRetAlias)->D2_TOTAL, 1, cMoeda, (cRetAlias)->D2_EMISSAO, nTxMoeda ))
			oRecord:SetValue( "HHA_VCMFAT", BIXValue(nComisaoFat, 1, cMoeda, (cRetAlias)->D2_EMISSAO, nTxMoeda ))
			oRecord:SetValue( "HHA_VLCSFT", &cCampoCusto)
			oRecord:SetValue( "HHA_VLDESF", BIXValue((cRetAlias)->D2_DESCON, 1, cMoeda, (cRetAlias)->D2_EMISSAO, nTxMoeda ))
			oRecord:SetValue( "HHA_VRECFI", 0)
			oRecord:SetValue( "HHA_VFRTNF", BIXValue((cRetAlias)->D2_VALFRE, 1, cMoeda, (cRetAlias)->D2_EMISSAO, nTxMoeda ))
			oRecord:SetValue( "HHA_VDESPE", BIXValue((cRetAlias)->D2_DESPESA, 1, cMoeda, (cRetAlias)->D2_EMISSAO, nTxMoeda ))
			oRecord:SetValue( "HHA_VFATME", BIXValue((cRetAlias)->D2_TOTAL, 1, cMoeda, (cRetAlias)->D2_EMISSAO, nTxMoeda ))
			oRecord:SetValue( "HHA_VFATLQ", BIXValue(nVlFatLiquido, 1, cMoeda, (cRetAlias)->D2_EMISSAO, nTxMoeda ))
			oRecord:SetValue( "HHA_VCTCTB", &cCampoCusto )
			oRecord:SetValue( "HHA_QFATIT", nQtdFatItem)
			oRecord:SetValue( "HHA_QFATFM", 0 )
			oRecord:SetValue( "HHA_QFATFC", 0 )
			oRecord:SetValue( "HHA_QPDREM", (cRetAlias)->D2_QUANT)
			oRecord:SetValue( "HHA_QPRZDP", ( nDuplicata/nQtdDuplic ) )
			oRecord:SetValue( "HHA_QTPESL", ( (cRetAlias)->D2_PESO * (cRetAlias)->D2_QUANT) )
			oRecord:SetValue( "HHA_QTPESB", ( (cRetAlias)->B1_PESBRU * (cRetAlias)->D2_QUANT) )

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda	
		
		(cRetAlias)->( DBSkip() )
	EndDo	
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return nil

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

@author  Marcia Junko
@since   22/07/2014
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXRemito
	Local cDML 		:= ""
	//-------------------------------------------------------------------
	// Define se a instalação do Protheus é "Brasil"
	//-------------------------------------------------------------------
	Local lBra		:= cPaisLoc == "BRA"

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	If lBra
		cDML += "SELECT D2_CLIENTE, D2_LOJA, D2_COD, D2_CF, D2_TIPODOC, " 
		cDML += "   D2_DOC, D2_SERIE, D2_ITEM, D2_PEDIDO, D2_TES, "
		cDML += "   D2_TIPO, D2_TOTAL, D2_QUANT, D2_PESO, D2_EMISSAO, "
		cDML += "   D2_CUSTO1, D2_CUSTO2, D2_CUSTO3, D2_CUSTO4, D2_CUSTO5, "
		cDML += "   D2_VALFRE, D2_DESCON, D2_DESPESA, D2_VALISS, D2_ICMSRET, " 
		cDML += "   D2_VALIRRF, D2_VALINS, D2_VALIMP6, D2_VALIMP5, "
		cDML += "   D2_VALICM, D2_VALIPI, D2_UM, D2_PRUNIT, D2_LOCAL, "
		cDML += "   D2_REMITO, D2_SERIREM, D2_ITEMREM, SD2.R_E_C_N_O_ ID, "
	Else
		//-------------------------------------------------------------------
		// Adiciona todos os campos no MI, pois vários campos podem ser
		// selecionados para realizar o cálculo dos impostos
		//-------------------------------------------------------------------	
		cDML := "SELECT SD2.R_E_C_N_O_ ID, SD2.*, "
	EndIf 
	
	cDML += "   F2_SERIE, F2_DOC, F2_EMISSAO, F2_TPFRETE, F2_REDESP, "
	cDML += "   F2_MOEDA, F2_TXMOEDA, F2_TRANSP, F2_COND, F2_VEND1, ACV_CATEGO,  "
	cDML += "   A1_GRPVEN, A1_REGIAO, A1_EST, A1_COD_MUN, A1_PAIS, A1_TIPO, "
	cDML += "   B1_GRUPO, B1_TIPO, B1_PESBRU, C5_TABELA "		
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
	cDML += "LEFT JOIN " + RetSQLName("SC5") + " SC5 "
	cDML += "	ON (C5_FILIAL = '" +	 xFilial("SC5") + "' AND C5_NUM = D2_PEDIDO "
	cDML += "   AND SC5.D_E_L_E_T_ = ' ') "		
	cDML += "LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cDML += "	ON (ACV_FILIAL = '" +	 xFilial("ACV") + "' AND ACV_CODPRO = D2_COD "
	cDML += "   AND ACV.D_E_L_E_T_ = ' ') "	
	cDML += "LEFT JOIN " + RetSQLName("SA1") + " SA1 "
	cDML += "	ON (A1_FILIAL = '" +	 xFilial("SA1") + "' AND A1_COD = D2_CLIENTE "
	cDML += "   AND A1_LOJA = D2_LOJA AND SA1.D_E_L_E_T_ = ' ') "	
	cDML += "WHERE D2_FILIAL = '" + xFilial("SD2") + "' " 	
	cDML += "AND D2_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	cDML += "AND D2_TIPO <> 'D' AND SD2.D_E_L_E_T_ = ' '"  
	
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
	TCSetField( ::cFlow, "D2_EMISSAO", "D", 08, 0 )
	TCSetField( ::cFlow, "F2_EMISSAO", "D", 08, 0 )	
Return ::cFlow 