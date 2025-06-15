#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCARTVENDAS.CH"

REGISTER EXTRACTOR HL3

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCartVendas
Apresenta informações dos pedidos de venda em aberto, armazenando o
histórico diário da carteira de pedidos.

@author  BI TEAM
@since   01/09/2010
/*/
//-------------------------------------------------------------------  
Class BIXCartVendas from BIXEntity
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
@since   05/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCartVendas
	_Super:New( FACT, "HL3", STR0001, "SC5", { COMERCIAL } ) //"Carteira de Vendas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   05/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCartVendas 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HL3_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HL3_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL3_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HL3_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL3_STCRED",	"C",	32, 00, .T., "HK1" ) //"Situação de Crédito"
	oModel:AddField( "HL3_REPRES",	"C",	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HL3_TRANSP",	"C",	32, 00, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HL3_ROTA",	"C",	32, 00, .T., "HGI" ) //"Rota"
	oModel:AddField( "HL3_CANALV",	"C",	32, 00, .T., "HGA" ) //"Canal de Venda"
	oModel:AddField( "HL3_FAMCOM",	"C",	32, 00, .T., "HG1" ) //"Família Comercial"	
	oModel:AddField( "HL3_FAMMAT",	"C",	32, 00, .T., "HG2" ) //"Famíalia Material"
	oModel:AddField( "HL3_GRPEST",	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HL3_ITEM",	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HL3_REGCOM",	"C",	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL3_MICREG",	"C",	32, 00, .T., "HGB" ) //"Microrregião"
	oModel:AddField( "HL3_NATOPR",	"C",	32, 00, .T., "HJ9" ) //"Natureza da Operação"
	oModel:AddField( "HL3_CFOP",	"C",	32, 00, .T., "HG0" ) //"CFOP"
	oModel:AddField( "HL3_PRDUTO",	"C",	32, 00, .T., "HJ3" ) //"Produto"
	oModel:AddField( "HL3_TABPCO",	"C",	32, 00, .T., "HGN" ) //"Tabela de Preço"
	oModel:AddField( "HL3_REFER",	"C",	32, 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HL3_CONDPG",	"C",	32, 00, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HL3_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"
	oModel:AddField( "HL3_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HL3_CLIENT",	"C",	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HL3_UNITEM",	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HL3_TRARED",	"C",	32, 00, .T., "HJ2" ) //"Transportadora de Redespacho"
	oModel:AddField( "HL3_DTEXTR",	"D",	08, 00,	.F., "HK2" ) //"Período"

	oModel:AddField( "HL3_DTENTR",	"D",	08, 00) //"Data de Entrega"
	
	oModel:AddField( "HL3_PEDIDO",	"C",	12, 00 ) //Número do Pedido de Venda
	oModel:AddField( "HL3_NMITVD",	"C",	10, 00 ) //Número do Item
	oModel:AddField( "HL3_STPEDV",	"C",	20, 00 ) //Situação do Pedido
	oModel:AddField( "HL3_STITPV",	"C",	20, 00 ) //Situação do Item do Pedido
	oModel:AddField( "HL3_TPCPIT",	"C",	20, 00 ) //Tipo de Item do Pedido	
	
	oModel:AddField( "HL3_QCARFC",	"N",	16,	04 ) //Qtde Carteira Família Comercial
	oModel:AddField( "HL3_QCARFM",	"N",	16,	04 ) //Qtde Carteira Família Material
	oModel:AddField( "HL3_VCARTE",	"N",	16,	02 ) //Vl Carteira
	oModel:AddField( "HL3_QCARTE",	"N",	16,	04 ) //Quantidade Carteira
	oModel:AddField( "HL3_NMPRIO",	"N",	04,	00 ) //Prioridade do Pedido	
		
	oModel:FreeField()
	
	oModel:IsSnapshot( .T. )	
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
@since   05/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCartVendas
	Local oRegion		:= nil
	Local aMoeda 	 	:= {}
	Local cMoeda	 	:= ""
	Local cFlow		 	:= ""
	Local cBlqCred   	:= ""
	Local cPedido	 	:= ""
	Local cSituaPedido	:= ""
	Local cSituaItem	:= ""	
	Local nMoeda	 	:= 0
	Local nVlr			:= 0
	Local nTotalPedido 	:= 0
	Local nTxMoeda		:= 0
	Local lCredito		:= .F.
	Local lTxMoeda 		:= LoadTxMoeda() //Define a utilização da taxa negociada na conversão de moeda.
	Local lRepres 		:= LoadRepres() //Define a utilização do representante pelo cadastro do cliente.
	
	
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda 	  := BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While ! (cFlow)->( Eof() ) 
		nTxMoeda 		:= 0
		nTotalPedido 	:= 0
		
		//-------------------------------------------------------------------
		// No Mercado internacional, as tabelas SC5, SC7, SF1, SF2, SE1, 
		// SE5 e SE2 utilizam o campo ??_TXMOEDA (TAXA NEGOCIADA) que define
		// a taxa usada para a operação, caso seja ZERO deve ser considerada 
		// a cotação da moeda para o dia.
		//-------------------------------------------------------------------			
		If cPaisLoc != "BRA" .Or. lTxMoeda
			nTxMoeda := (cFlow)->C5_TXMOEDA 
		EndIf
		
		//-------------------------------------------------------------------
		// Calcula o valor total do pedido.  
		//-------------------------------------------------------------------  
		If ! ( cPedido == (cFlow)->C5_NUM )	      
	  		nTotalPedido := BIXCalcTotPedido( (cFlow)->C5_NUM ) 
		 	 
		 	//-------------------------------------------------------------------
			// Identifica o pedido que está sendo processado.  
			//-------------------------------------------------------------------		 	  
		 	cPedido := (cFlow)->C5_NUM
		 	
		 	//-------------------------------------------------------------------
			// Verifica a situação de crédito do cliente.  
			//-------------------------------------------------------------------
			lCredito := MaAvalCred((cFlow)->A1_COD, (cFlow)->A1_LOJA, nTotalPedido, 1, .T., @cBlqCred )  
	 	EndIf			 			
	
	 	//-------------------------------------------------------------------
		// Determina a Situação do Item do Pedido  
		//-------------------------------------------------------------------   
			Do Case
			Case Empty((cFlow)->C9_BLEST) .And. Empty((cFlow)->C9_BLCRED) .And. Empty((cFlow)->C9_BLTMS) .And. (Empty((cFlow)->C9_BLWMS) .Or. (cFlow)->C9_BLWMS >= '5') 
				cSituaItem := STR0002 // "Liberado"
			Case ((cFlow)->C9_BLCRED == '10' .Or. (cFlow)->C9_BLCRED == 'ZZ') .And. ((cFlow)->C9_BLEST == '10' .Or. (cFlow)->C9_BLEST == 'ZZ') 
				cSituaItem := STR0003 // "Faturado"					
			Case !Empty((cFlow)->C9_BLCRED) .And. ((cFlow)->C9_BLCRED <> '09' .Or. (cFlow)->C9_BLCRED <> '10' .Or. (cFlow)->C9_BLCRED <> 'ZZ')
				cSituaItem := STR0004 // "Bloqueado por Crédito"                                                                           
			Case !Empty((cFlow)->C9_BLEST) .And. ((cFlow)->C9_BLEST  <> '09' .Or. (cFlow)->C9_BLEST == '10' .Or. (cFlow)->C9_BLEST == 'ZZ')   
				cSituaItem := STR0005 // "Bloq. por Estoque"
			Case !Empty((cFlow)->C9_BLWMS) .And. ((cFlow)->C9_BLWMS <= '5') 
				cSituaItem := STR0006 // "Bloq. por WMS"  
			Case !Empty((cFlow)->C9_BLTMS)   
				cSituaItem := STR0007 // "Bloq. por TMS"
			Case (cFlow)->C9_BLCRED == '09'   
				cSituaItem := STR0008 // "Bloq. por TMS"
			EndCase
				
	 	//-------------------------------------------------------------------
		// Determina a Situação do Pedido  
		//-------------------------------------------------------------------
		Do Case
		Case Empty((cFlow)->C5_LIBEROK) .And. Empty((cFlow)->C5_NOTA) .And. Empty((cFlow)->C5_BLQ)
			cSituaPedido := STR0009 // "Aberto"
		Case !Empty((cFlow)->C5_NOTA) .Or. ((cFlow)->C5_LIBEROK == 'E') .And. Empty((cFlow)->C5_BLQ)
	   		cSituaPedido := STR0010 // "Encerrado"
		Case !Empty((cFlow)->C5_LIBEROK) .And. Empty((cFlow)->C5_NOTA) .And. Empty((cFlow)->C5_BLQ)
			cSituaPedido := STR0011 // "Liberado" 
		Case ((cFlow)->C5_BLQ == '1')                                                                   
			cSituaPedido := STR0012 // "Bloqueado por Regra"							 	
		Case ((cFlow)->C5_BLQ == '2')                                        
			cSituaPedido := STR0013 // "Bloqueado por Verba"
		EndCase	
	
		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "C5_NUM"		, (cFlow)->C5_NUM ) 
			oRecord:SetValue( "B1_COD"		, (cFlow)->C6_PRODUTO ) 
			oRecord:SetValue( "ACU_COD"		, (cFlow)->ACV_CATEGO )			
			oRecord:SetValue( "BM_GRUPO"	, (cFlow)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cFlow)->C6_UM )			
			oRecord:SetValue( "F4_CODIGO"	, (cFlow)->C6_TES )
			oRecord:SetValue( "A1_COD"		, (cFlow)->C5_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->C5_LOJACLI )			
			oRecord:SetValue( "A4_COD"		, (cFlow)->C5_TRANSP )
			oRecord:SetValue( "E4_CODIGO"	, (cFlow)->C5_CONDPAG )			
			oRecord:SetValue( "DA0_CODTAB"	, (cFlow)->C5_TABELA )			
			oRecord:SetValue( "ACY_GRPVEN"	, (cFlow)->A1_GRPVEN )			
			oRecord:SetValue( "A3_COD"		, (cFlow)->C5_VEND1 )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HL3_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HL3_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HL3_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HL3_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HL3_ITEM"	, oSeeker:Seek( "HJ8", { (cFlow)->C6_PRODUTO } ) )
 			oRecord:SetValue( "HL3_FAMMAT"	, oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) )
 			oRecord:SetValue( "HL3_FAMCOM"	, oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) )	
 			oRecord:SetValue( "HL3_GRPEST"	, oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) ) 
 			oRecord:SetValue( "HL3_UNITEM"	, oSeeker:Seek( "HHW", { (cFlow)->C6_UM } ) )
 			oRecord:SetValue( "HL3_NATOPR"	, oSeeker:Seek( "HJ9", { (cFlow)->C6_TES } ) )
 			oRecord:SetValue( "HL3_CFOP"	, oSeeker:Seek( "HG0", { (cFlow)->F4_CF } ) )
			oRecord:SetValue( "HL3_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->C5_CLIENTE, (cFlow)->C5_LOJACLI } ) )
			oRecord:SetValue( "HL3_GRPCLI"	, oSeeker:Seek( "HJ0", { (cFlow)->A1_TIPO } ) )
			oRecord:SetValue( "HL3_TRANSP"	, oSeeker:Seek( "HJ2", { (cFlow)->C5_TRANSP } ) )
			oRecord:SetValue( "HL3_TRARED"	, oSeeker:Seek( "HJ2", { (cFlow)->C5_REDESP } ) )			
			oRecord:SetValue( "HL3_CONDPG"	, oSeeker:Seek( "HJA", { (cFlow)->C5_CONDPAG } ) )
			oRecord:SetValue( "HL3_TABPCO"	, oSeeker:Seek( "HGN", { (cFlow)->C5_TABELA } ) )
			oRecord:SetValue( "HL3_MICREG"	, oSeeker:Seek( "HGB", { (cFlow)->A1_REGIAO } ) )
			oRecord:SetValue( "HL3_REGCOM"	, oSeeker:Seek( "HGD", { (cFlow)->A1_GRPVEN } ) )					
			oRecord:SetValue( "HL3_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A1_EST, (cFlow)->A1_COD_MUN, (cFlow)->A1_PAIS ) } ) )
			oRecord:SetValue( "HL3_STCRED"	, oSeeker:Seek( "HK1", { iIf( lCredito, "3", "4" ) } ) )
			oRecord:SetValue( "HL3_REPRES"	, oSeeker:Seek( "HJC", { iIf( lRepres, (cFlow)->A1_VEND  , (cFlow)->C5_VEND1 ) } ) )
 			oRecord:SetValue( "HL3_PRDUTO"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL3_CANALV"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL3_REFER"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL3_ROTA"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			
			//-------------------------------------------------------------------
			// Datas.
			//-------------------------------------------------------------------  			
			oRecord:SetValue( "HL3_DTEXTR"	, dToday )
			oRecord:SetValue( "HL3_DTENTR"	, iIf(Empty((cFlow)->C9_ID), DATE_EMPTY ,iIf(!Empty((cFlow)->F2_DTENTR),(cFlow)->F2_DTENTR, iIf(!Empty((cFlow)->C6_ENTREG),(cFlow)->C6_ENTREG, DATE_EMPTY))))
			
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HL3_PEDIDO"	, (cFlow)->C5_NUM )
			oRecord:SetValue( "HL3_NMITVD"	, (cFlow)->C6_ITEM )
			oRecord:SetValue( "HL3_STPEDV"	, cSituaPedido )
			oRecord:SetValue( "HL3_STITPV"	, cSituaItem )
			oRecord:SetValue( "HL3_TPCPIT"	, " " )
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HL3_QCARFC"	, 0 )	
			oRecord:SetValue( "HL3_QCARFM"	, 0 )	
			oRecord:SetValue( "HL3_NMPRIO"	, 0 )
			oRecord:SetValue( "HL3_QCARTE"	, (cFlow)->C6_QTDVEN - (cFlow)->C6_QTDENT )
			nVlr := (((cFlow)->C6_QTDVEN-(cFlow)->C6_QTDENT) * (cFlow)->C6_PRCVEN)
			oRecord:SetValue( "HL3_VCARTE"	, BIXValue(nVlr,(cFlow)->C5_MOEDA,cMoeda,(cFlow)->C6_ENTREG, nTxMoeda) )
							
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
@return cFlow, Alias temporário. 

@author  Marcia Junko
@since   22/07/2014
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCartVendas
	Local nInterval		:= BIXParInfo( "BIX_PVENDA", "N", 24 ) 
	Local cBeginDate	:= ""
	Local cDML 			:= ""
	Local lCarteira 	:= superGetMV("MV_BIXCVEN",.F.,.F.)//Parametro responsavel por realizar a extração dos pedidos de venda por status.


 	
	//-------------------------------------------------------------------
	// Define a data de início da extração com base na parametrização. 
	//-------------------------------------------------------------------
	cBeginDate	:= DToS( Date() - ( nBIVal( nInterval ) * ( 30 ) ) )   
	
	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cDML += "SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_LIBEROK, C5_NOTA, "
	cDML += "   C5_BLQ, C5_REDESP, C5_MOEDA, C5_TXMOEDA, C5_VEND1, "
	cDML += "   C5_TRANSP, C5_CONDPAG, C5_TABELA, SC5.R_E_C_N_O_ ID, " 
	cDML += "   C6_NUM, C6_ITEM, C6_PRODUTO, C6_TES, C6_QTDVEN, "
	cDML += "   C6_QTDENT, C6_PRCVEN, C6_ENTREG, C6_UM, B1_TIPO, B1_GRUPO, "
	cDML += "   F4_CF, A1_GRPVEN, A1_COD, A1_LOJA, A1_VEND, A1_REGIAO, A1_EST, "
	cDML += "   A1_COD_MUN, A1_PAIS, A1_TIPO, ACV_CATEGO, SC9.R_E_C_N_O_ C9_ID, F2_DTENTR, "
	cDML += "   C9_BLEST, C9_BLCRED, C9_BLTMS, C9_BLWMS "		
	cDML += "FROM " + RetSqlName("SC5") + " SC5 " 
	cDML += "INNER JOIN " + RetSqlName("SC6") + " SC6 "
	cDML += "   ON C5_FILIAL = C6_FILIAL "
	cDML += "   AND C5_NUM = C6_NUM "
	cDML += "   AND SC6.D_E_L_E_T_ = ' ' "
	cDML += "LEFT JOIN " + RetSQLName("SB1") + " SB1 "
	cDML += "	ON (B1_FILIAL = '" +	 xFilial("SB1") + "' AND B1_COD = C6_PRODUTO "
	cDML += "   AND SB1.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("SF4") + " SF4 "
	cDML += "	ON (F4_FILIAL = '" +	 xFilial("SF4") + "' AND F4_CODIGO = C6_TES "
	cDML += "   AND SF4.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("SA1") + " SA1 "
	cDML += "	ON (A1_FILIAL = '" +	 xFilial("SA1") + "' AND A1_COD = C5_CLIENTE "
	cDML += "   AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cDML += "	ON (ACV_FILIAL = '" +	 xFilial("ACV") + "' AND ACV_CODPRO = C6_PRODUTO "
	cDML += "   AND ACV.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("SC9") + " SC9 "
	cDML += "	ON (C9_FILIAL = '" +	 xFilial("SC9") + "' AND C9_PEDIDO = C6_NUM "
	cDML += "   AND C9_PRODUTO = C6_PRODUTO AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("SF2") + " SF2 "
	cDML += "	ON (F2_FILIAL = '" +	 xFilial("SF2") + "' AND F2_DOC = C9_NFISCAL "
	cDML += "   AND F2_SERIE = C9_SERIENF AND F2_CLIENTE = C9_CLIENTE AND F2_LOJA = C9_LOJA "
	cDML += "   AND SF2.D_E_L_E_T_ = ' ') "									
	cDML += "WHERE C5_FILIAL = '" + xFilial("SC5") + "' "
	If !lCarteira 
		cDML += "   AND C5_LIBEROK = ' ' "
		cDML += "   AND C5_NOTA = ' ' "
	EndIf 
	cDML += "   AND C5_TIPO = 'N'  "  
	cDML += "   AND C5_EMISSAO >= '" + cBeginDate + "' "
	cDML += "   AND SC5.D_E_L_E_T_ = ' ' "
	cDML += "ORDER BY C5_EMISSAO"
	
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
	TCSetField( ::cFlow, "C6_ENTREG", "D", 08, 0 )	
Return ::cFlow

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCalcTotPedido
Efetua o cálculos de valor total do pedido.

@param cPedido, caracter, Pedido a ser totalizado o valor.
@return nTotal, numérico, Valor total do pedido. 

@author  Tamara Clemente
@since   05/05/2017
/*/
//-------------------------------------------------------------------
Static Function BIXCalcTotPedido( cPedido )
	Local cQuery    := ""       
	Local aArea     := GetArea()
	Local cAliasTMP := "BIXCALCTOTPEDIDO"
	Local nTotal    := 0

	cQuery := "SELECT SUM((C6_QTDVEN-C6_QTDENT) * C6_PRCVEN) TOTAL_PEDIDO "
	cQuery += "FROM " + RetSqlName("SC6") + " SC6 " 
	cQuery += "WHERE C6_FILIAL = '" + xFilial("SC6") + "' "
	cQuery += "   AND C6_NUM = '" + cPedido + "' "
	cQuery += "   AND SC6.D_E_L_E_T_ = ' ' "	
	
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTMP, .T., .T.)      

	nTotal := (cAliasTMP)->TOTAL_PEDIDO
	
	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
Return nTotal 