#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXVENDAS.CH"

REGISTER EXTRACTOR HL4 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVendas
A tabela fato Vendas apresenta informações dos pedidos de vendas como
quantidades e valores dos pedidos de venda e impostos.

@author  Helio Leal
@since   10/05/2017
/*/
//-------------------------------------------------------------------
Class BIXVendas from BIXEntity
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
@since   10/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXVendas
	_Super:New( FACT, "HL4", STR0001, "SC5", { COMERCIAL } ) //"Vendas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   10/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXVendas 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HL4_EMPRES"	,	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HL4_ESTABL"	,	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL4_PRDUTO"	,	"C",	32, 00, .T., "HJ3" ) //"Produto Comercial"
	oModel:AddField( "HL4_GRPCLI"	,	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"	
	oModel:AddField( "HL4_UNDNEG"	,	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HL4_MOEDA" 	,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL4_CANALV"	,	"C",	32, 00, .T., "HGA" ) //"Canal de Venda"	
	oModel:AddField( "HL4_MICREG"	,	"C",	32, 00, .T., "HGB" ) //"Microrregião"
	oModel:AddField( "HL4_REFER"	,	"C",	32, 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HL4_REPRES"	,	"C",	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HL4_NATOPR"	,	"C",	32, 00, .T., "HJ9" ) //"Natureza da Operação"
	oModel:AddField( "HL4_CFOP"		,	"C",	32, 00, .T., "HG0" ) //"CFOP"
	oModel:AddField( "HL4_ITEM"		,	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HL4_FAMCOM"	,	"C",	32, 00, .T., "HG1" ) //"Família Comercial"	
	oModel:AddField( "HL4_FAMMAT"	,	"C",	32, 00, .T., "HG2" ) //"Famíalia Material"
	oModel:AddField( "HL4_GRPEST"	,	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HL4_CONDPG"	,	"C",	32, 00, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HL4_REGIAO"	,	"C",	32, 00, .T., "HJB" ) //"Região"
	oModel:AddField( "HL4_CLIENT"	,	"C",	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HL4_REGCOM"	,	"C",	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL4_ROTA"		,	"C",	32, 00, .T., "HGI" ) //"Rota"	
	oModel:AddField( "HL4_TABPCO"	,	"C",	32, 00, .T., "HGN" ) //"Tabela de Preço"
	oModel:AddField( "HL4_UNITEM" 	,	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"	
	oModel:AddField( "HL4_TRANSP"	,	"C",	32, 00, .T., "HJ2" ) //"Transportadora"	
	oModel:AddField( "HL4_TRARED"	,	"C",	32, 00, .T., "HJ2" ) //"Transportadora de Redespacho"
	oModel:AddField( "HL4_STCRED"	,	"C",	32, 00, .T., "HK1" ) //"Situação de Crédito"

	oModel:AddField( "HL4_DATA"		,	"D",	08, 00, .F., "HK2" ) //"Período - Data da Venda"
	oModel:AddField( "HL4_DTENTR"	, 	"D", 	08, 00	) //Data da Entrega
	oModel:AddField( "HL4_DTIMPL"	, 	"D", 	08, 00	) //Data da Implantação

	oModel:AddField( "HL4_PEDIDO"	, 	"C", 	12, 00	) //Número do Pedido
	oModel:AddField( "HL4_NMITVD"	, 	"C", 	10, 00	) //Número do Item
	oModel:AddField( "HL4_STPEDV"	, 	"C", 	20, 00	) //Situação do Pedido
	oModel:AddField( "HL4_STITPV"	, 	"C", 	20, 00	) //Situação do Item do Pedido
	oModel:AddField( "HL4_TPCPIT"	, 	"C", 	20, 00	) //Tipo de Item do Pedido

	oModel:AddField( "HL4_NMPRIO"	, 	"N", 	04, 00	) //Prioridade do Pedido     
	oModel:AddField( "HL4_VVENDA"	, 	"N", 	16, 02	) //Valor da Venda Total        
	oModel:AddField( "HL4_QVENDA"	, 	"N", 	16, 04	) //Quantidade Vendida             
	oModel:AddField( "HL4_VIMPVD"	, 	"N", 	16, 02	) //Valor Impostos Venda        
	oModel:AddField( "HL4_VVMERC"	, 	"N", 	16, 02	) //Valor Venda Mercadoria      
	oModel:AddField( "HL4_VVNDLQ"	, 	"N", 	16, 02	) //Valor Venda Líquida         
	oModel:AddField( "HL4_QVENFC"	, 	"N", 	16, 04	) //Quantidade Vendida Familia Comercial
	oModel:AddField( "HL4_QVENFM"	, 	"N", 	16, 04	) //Quantidade Vendida Familia Material
	oModel:AddField( "HL4_VLDESV"	, 	"N", 	16, 02	) //Valor Desconto Venda        
	oModel:AddField( "HL4_VIPNIN"	, 	"N", 	16, 02	) //Valor Impostos não incidentes 

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
@since   10/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXVendas
	Local oRegion		:= Nil
	Local aMoeda 		:= {}
	Local lFee			:= .F. // Define se a taxa negociada na conversão de moeda é utilizada.
	Local lRepres		:= .F.
	Local lBrasil		:= .T.
	Local nFee			:= 0	// Recebe a taxa negociada na conversão de moeda.
	Local nMoeda		:= 0
	Local nVlrTmp		:= 0
	Local nVlVenda	:= 0
	Local cFlow		:= ""
	Local cMoeda		:= ""
	Local cBlqCred	:= ""
                                                                                                                                                  
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//-------------------------------------------------------------------
	aMoeda		:= BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()
	lFee 		:= BIXParInfo( "BIX_TXMOED"	, "L", .F. )
	lRepres 	:= BIXParInfo( "BIX_REPRES"	, "L", .F. )
	lBrasil	:= cPaisLoc == "BRA"

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	While ! (cFlow)->( Eof() )
		//-------------------------------------------------------------------
		// Identifica se utiliza a taxa negociada para moeda.
		//------------------------------------------------------------------- 
		If ( ! lBrasil .Or. lFee )
			nFee := (cFlow)->C5_TXMOEDA
		Endif

		//-------------------------------------------------------------------
		// Inicia variável que contém o valor da venda.
		//-------------------------------------------------------------------
		nVlVenda := 0 

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
			oRecord:SetValue( "F4_CODIGO"	, (cFlow)->C6_TES )
			oRecord:SetValue( "ACU_COD"		, (cFlow)->ACV_CATEGO )	
			oRecord:SetValue( "B1_COD"		, (cFlow)->C6_PRODUTO ) 
			oRecord:SetValue( "BM_GRUPO"	, (cFlow)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cFlow)->C6_UM )
			oRecord:SetValue( "A1_COD"		, (cFlow)->C5_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->C5_LOJACLI )	
			oRecord:SetValue( "ACY_GRPVEN"	, (cFlow)->A1_GRPVEN )		
			oRecord:SetValue( "A4_COD"		, (cFlow)->C5_TRANSP )
			oRecord:SetValue( "A3_COD"		, (cFlow)->C5_VEND1 )
			oRecord:SetValue( "E4_CODIGO"	, (cFlow)->C5_CONDPAG )
			oRecord:SetValue( "DA0_CODTAB"	, (cFlow)->C5_TABELA )		

			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------	
			oRecord:SetValue( "HL4_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HL4_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HL4_GRPCLI"	, oSeeker:Seek( "HJ0", { (cFlow)->A1_TIPO } ) )
			oRecord:SetValue( "HL4_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HL4_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HL4_MICREG"	, oSeeker:Seek( "HGB", { (cFlow)->A1_REGIAO } ) )
			oRecord:SetValue( "HL4_REPRES"	, oSeeker:Seek( "HJC", { iif( lRepres, (cFlow)->A1_VEND, (cFlow)->C5_VEND1 ) } ) )
			oRecord:SetValue( "HL4_NATOPR" 	, oSeeker:Seek( "HJ9", { (cFlow)->C6_TES } ) )
			oRecord:SetValue( "HL4_CFOP" 	, oSeeker:Seek( "HG0", { (cFlow)->F4_CF } ) )
			oRecord:SetValue( "HL4_ITEM"	, oSeeker:Seek( "HJ8", { (cFlow)->C6_PRODUTO } ) )
			oRecord:SetValue( "HL4_FAMCOM" 	, oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) )
			oRecord:SetValue( "HL4_FAMMAT"	, oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) )
			oRecord:SetValue( "HL4_GRPEST"	, oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) )
			oRecord:SetValue( "HL4_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A1_EST, (cFlow)->A1_COD_MUN, (cFlow)->A1_PAIS ) } ) )
			oRecord:SetValue( "HL4_CONDPG"	, oSeeker:Seek( "HJA", { (cFlow)->C5_CONDPAG } ) )
			oRecord:SetValue( "HL4_CLIENT"	, oSeeker:Seek( "HJ7", { (cFlow)->C5_CLIENTE, (cFlow)->C5_LOJACLI } ) )
			oRecord:SetValue( "HL4_REGCOM"	, oSeeker:Seek( "HGD", { (cFlow)->A1_GRPVEN } ) )
			oRecord:SetValue( "HL4_UNITEM" 	, oSeeker:Seek( "HHW", { (cFlow)->C6_UM } ) )
			oRecord:SetValue( "HL4_TRANSP"	, oSeeker:Seek( "HJ2", { (cFlow)->C5_TRANSP } ) )
			oRecord:SetValue( "HL4_TRARED"	, oSeeker:Seek( "HJ2", { (cFlow)->C5_REDESP } ) )
			oRecord:SetValue( "HL4_TABPCO"	, oSeeker:Seek( "HGN", { (cFlow)->C5_TABELA } ) )
			oRecord:SetValue( "HL4_STCRED"	, oSeeker:Seek( "HK1", { if( MaAvalCred((cFlow)->A1_COD,(cFlow)->A1_LOJA,(cFlow)->C6_VALOR,1,.T.,@cBlqCred), "3", "4" ) } ) )
			oRecord:SetValue( "HL4_PRDUTO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL4_CANALV" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL4_REFER" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL4_ROTA"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Dates.
			//-------------------------------------------------------------------	
			oRecord:SetValue( "HL4_DATA"	, IIf( !Empty( (cFlow)->C5_EMISSAO),(cFlow)->C5_EMISSAO,DATE_EMPTY	))
			oRecord:SetValue( "HL4_DTENTR"	, IIf( !Empty( (cFlow)->C6_ENTREG ),(cFlow)->C6_ENTREG ,DATE_EMPTY	))
			oRecord:SetValue( "HL4_DTIMPL"	, IIf( !Empty( (cFlow)->C5_EMISSAO),(cFlow)->C5_EMISSAO,DATE_EMPTY	))
			
			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			
			//-------------------------------------------------------------------
			// Situação do Item do Pedido
			//-------------------------------------------------------------------
			If SC9->( DbSeek(xFilial("SC9") + (cFlow)->C6_NUM + (cFlow)->C6_ITEM ) )
				Do Case
					Case Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLTMS) .And. (Empty(SC9->C9_BLWMS) .Or. SC9->C9_BLWMS >= '5') 
						oRecord:SetValue( "HL4_STITPV", STR0002 ) // "Liberado"
					Case (SC9->C9_BLCRED == '10' .Or. SC9->C9_BLCRED == 'ZZ') .And. (SC9->C9_BLEST == '10' .Or. SC9->C9_BLEST == 'ZZ') 
						oRecord:SetValue( "HL4_STITPV", STR0003 ) // "Faturado"
					Case !Empty(SC9->C9_BLCRED) .And. (SC9->C9_BLCRED <> '09' .Or. SC9->C9_BLCRED <> '10' .Or. SC9->C9_BLCRED <> 'ZZ') 
						oRecord:SetValue( "HL4_STITPV", STR0004 ) // "Bloq. por Crédito"
					Case !Empty(SC9->C9_BLEST) .And. (SC9->C9_BLEST  <> '09' .Or. SC9->C9_BLEST == '10' .Or. SC9->C9_BLEST == 'ZZ') 
						oRecord:SetValue( "HL4_STITPV", STR0005 )// "Bloq. por Estoque"
					Case !Empty(SC9->C9_BLWMS) .And. (SC9->C9_BLWMS <= '5')
						oRecord:SetValue( "HL4_STITPV", STR0006 ) // "Bloq. por WMS"
					Case !Empty(SC9->C9_BLTMS) 
						oRecord:SetValue( "HL4_STITPV", STR0007 ) // "Bloq. por TMS"
					Case SC9->C9_BLCRED == '09'	
						oRecord:SetValue( "HL4_STITPV", STR0007 ) // "Bloq. por TMS"
				EndCase
			EndIf
			
			//-------------------------------------------------------------------
			// Situação do Pedido
			//-------------------------------------------------------------------
			Do Case
				Case Empty((cFlow)->C5_LIBEROK) .And. Empty((cFlow)->C5_NOTA) .And. Empty((cFlow)->C5_BLQ)
					oRecord:SetValue( "HL4_STPEDV", STR0008 ) // "Aberto"
				Case !Empty((cFlow)->C5_NOTA) .Or. ((cFlow)->C5_LIBEROK == 'E') .And. Empty((cFlow)->C5_BLQ)
					oRecord:SetValue( "HL4_STPEDV", STR0009 ) // "Encerrado"
				Case !Empty((cFlow)->C5_LIBEROK) .And. Empty((cFlow)->C5_NOTA) .And. Empty((cFlow)->C5_BLQ)
					oRecord:SetValue( "HL4_STPEDV", STR0010 ) // "Liberado"
				Case ((cFlow)->C5_BLQ == '1')
			   		oRecord:SetValue( "HL4_STPEDV", STR0011 ) // "Bloqueado por Regra"
				Case ((cFlow)->C5_BLQ == '2')
			  		oRecord:SetValue( "HL4_STPEDV", STR0012 ) // "Bloqueado por Verba"
			EndCase

			oRecord:SetValue( "HL4_TPCPIT", " " )
			oRecord:SetValue( "HL4_NMPRIO", 0 )
			oRecord:SetValue( "HL4_PEDIDO", (cFlow)->C5_NUM  )
			oRecord:SetValue( "HL4_NMITVD", (cFlow)->C6_ITEM	)

			//-------------------------------------------------------------------
			// Indicadores.
			//-------------------------------------------------------------------
			nVlrTmp 	:= ( BIXVldValor((cFlow)->C6_PRUNIT, (cFlow)->C6_PRCVEN, 1) * (cFlow)->C6_QTDVEN )
			nVlVenda 	:= BIXValue( (cFlow)->C6_VALOR, (cFlow)->C5_MOEDA, cMoeda, (cFlow)->C5_EMISSAO, nFee )

			oRecord:SetValue( "HL4_QVENDA", (cFlow)->C6_QTDVEN )
			oRecord:SetValue( "HL4_VLDESV", BIXValue(nVlrTmp,(cFlow)->C5_MOEDA,cMoeda,(cFlow)->C5_EMISSAO, nFee) )
			oRecord:SetValue( "HL4_VVNDLQ", nVlVenda )
			oRecord:SetValue( "HL4_VVMERC", nVlVenda )
			oRecord:SetValue( "HL4_VVENDA", nVlVenda )
			oRecord:SetValue( "HL4_VIPNIN", 0 )
			oRecord:SetValue( "HL4_VIMPVD", 0 )
			oRecord:SetValue( "HL4_QVENFC", 0 )
			oRecord:SetValue( "HL4_QVENFM", 0 )

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
@since   10/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXVendas
	Local cDML 	:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cDML := "SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_TRANSP, C5_VEND1, " 
	cDML += "   C5_CONDPAG, C5_TABELA, C5_LIBEROK, C5_NOTA, C5_BLQ, "
	cDML += "   C5_EMISSAO, C5_REDESP, C5_TXMOEDA, C5_MOEDA, SC5.R_E_C_N_O_ ID, "
	cDML += "   C6_NUM, C6_PRODUTO, C6_ITEM, C6_ENTREG, C6_TES, C6_VALOR, "
	cDML += "   C6_PRUNIT, C6_PRCVEN, C6_QTDVEN, C6_UM, " 
	cDML += " 	A1_COD, A1_LOJA, A1_TIPO, A1_REGIAO, A1_VEND, A1_EST, A1_COD_MUN, A1_PAIS, A1_GRPVEN, "
	cDML += " 	F4_CF, ACV_CATEGO, B1_TIPO, B1_GRUPO "
 	cDML += "FROM " + RetSqlName("SC5") + " SC5 "
 	cDML += "INNER JOIN " + RetSQLName("SC6") + " SC6 "
 	cDML += "ON C6_FILIAL = C5_FILIAL "
	cDML += "   AND C6_NUM = C5_NUM "
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
	cDML += "WHERE C5_FILIAL = '" + xFilial("SC5") + "' " 
	cDML += "   AND C5_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	cDML += "   AND C5_TIPO = 'N'  " 
	cDML += "   AND SC5.D_E_L_E_T_ = ' ' "
	cDML += "ORDER BY C5_EMISSAO"

	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML ) 

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)

	//-------------------------------------------------------------------
	// Converte os campos para o tipo correto.
	//-------------------------------------------------------------------
	TcSetField( ::cFlow, "C5_EMISSAO"	, "D", 8, 0 )
	TcSetField( ::cFlow, "C6_ENTREG"	, "D", 8, 0 )
Return ::cFlow 