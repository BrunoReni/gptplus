#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFATURAMENTO.CH"

REGISTER EXTRACTOR HL2 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFaturamento
Classe do extrator para a tabela fato Faturamento do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   17/08/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXFaturamento from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author Marcia Junko
@since   30/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXFaturamento
	_Super:New( FACT, "HL2", STR0001, "SD2", { COMERCIAL, DL, VAREJO } ) // "Faturamento" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   30/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXFaturamento
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HL2_EMPRES", "C", 32, 0, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HL2_ESTABL", "C", 32, 0, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL2_PRDUTO", "C", 32, 0, .T., "HJ3" ) //"Produto Comercial"
	oModel:AddField( "HL2_GRPCLI", "C", 32, 0, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HL2_MOEDA",  "C", 32, 0, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL2_UNDNEG", "C", 32, 0, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HL2_CANALV", "C", 32, 0, .T., "HGA" ) //"Canal de Venda" 
	oModel:AddField( "HL2_REFER",  "C", 32, 0, .T., "HJH" ) //"Referência"
	oModel:AddField( "HL2_MICREG", "C", 32, 0, .T., "HGB" ) //"Microrregião"
	oModel:AddField( "HL2_TRARED", "C", 32, 0, .T., "HJ2" ) //"Transportadora Redespacho"
	oModel:AddField( "HL2_CLIREM", "C", 32, 0, .T., "HJ7" ) //"Cliente Remetente"
	oModel:AddField( "HL2_CLIDES", "C", 32, 0, .T., "HJ7" ) //"Cliente Destinatário"
	oModel:AddField( "HL2_CLIDEV", "C", 32, 0, .T., "HJ7" ) //"Cliente Devedor"
	oModel:AddField( "HL2_REGDES", "C", 32, 0, .T., "HO0" ) //Região de Transporte Destino"
	oModel:AddField( "HL2_SERTRA", "C", 32, 0, .T., "HO1" ) //"Serviço de Transporte"
	oModel:AddField( "HL2_TIPDOC", "C", 32, 0, .T., "HO2" ) //"Tipo de Documento de Transporte"
	oModel:AddField( "HL2_TIPTRA", "C", 32, 0, .T., "HHX" ) //"Tipo Transporte"
	oModel:AddField( "HL2_FILORI", "C", 32, 0, .T., "HO9" ) //"Filial Origem"
	oModel:AddField( "HL2_FXHORA", "C", 32, 0, .T., "HS8" ) //"Faixa de Hora 
	oModel:AddField( "HL2_FORPAG", "C", 32, 0, .T., "HS9" ) //"Forma de Pagamento"
	oModel:AddField( "HL2_ORILAN", "C", 32, 0, .T., "HS7" ) //"Origem Lançamento"
	oModel:AddField( "HL2_ITEM",   "C", 32, 0, .T., "HJ8" ) //"Item"
	oModel:AddField( "HL2_FAMCOM", "C", 32, 0, .T., "HG1" ) //"Família Comercial"
	oModel:AddField( "HL2_FAMMAT", "C", 32, 0, .T., "HG2" ) //"Família Material"
	oModel:AddField( "HL2_GRPEST", "C", 32, 0, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HL2_REPRES", "C", 32, 0, .T., "HJC" ) //"Representante"
	oModel:AddField( "HL2_TRANSP", "C", 32, 0, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HL2_NATOPR", "C", 32, 0, .T., "HJ9" ) //"Natureza da Operação"
	oModel:AddField( "HL2_CFOP",   "C", 32, 0, .T., "HG0" ) //CFOP"
	oModel:AddField( "HL2_CLIENT", "C", 32, 0, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HL2_REGIAO", "C", 32, 0, .T., "HJB" ) //"Região"
	oModel:AddField( "HL2_CONDPG", "C", 32, 0, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HL2_TABPCO", "C", 32, 0, .T., "HGN" ) //"Tabela de Preço"
	oModel:AddField( "HL2_ROTA",   "C", 32, 0, .T., "HGI" ) //"Rota"
	oModel:AddField( "HL2_REGCOM", "C", 32, 0, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL2_UNITEM", "C", 32, 0, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HL2_VIAGEM", "C", 32, 0, .T., "HO7" ) //"Viagem"
	oModel:AddField( "HL2_REGTRA", "C", 32, 0, .T., "HO0"  ) //"Região Transporte Origem"
	oModel:AddField( "HL2_CANMID", "C", 32, 0, .T., "HS6" ) //"Mídia"
	oModel:AddField( "HL2_FORNEC", "C", 32, 0, .T., "HKJ" ) //"Fornecedor
	oModel:AddField( "HL2_DATA",   "D", 8, 0 ) //Data Periodo
	oModel:AddField( "HL2_DTSANF", "D", 8, 0 ) //Data Saída NF 
	oModel:AddField( "HL2_SERNF",  "C", 8, 	0 ) //Série NF	
	oModel:AddField( "HL2_NUMNF",  "C", 35,	0 ) //Nota Fiscal
	oModel:AddField( "HL2_PEDIDO", "C", 12,	0 ) //Num. Pedido
	oModel:AddField( "HL2_NMITNF", "C", 10,	0 ) //Numero Item
	oModel:AddField( "HL2_FGERDP", "C", 1, 	0 ) //Item Gera Duplicata
	oModel:AddField( "HL2_TPFRET", "C", 3, 	0 ) //Tipo de Frete
	oModel:AddField( "HL2_TPNOTA", "C", 20,	0 ) //Tipo de Nota
	oModel:AddField( "HL2_FBXEST", "C", 1, 	0 ) //Item Baixa Estoque
	oModel:AddField( "HL2_TPCPIT", "C", 20,	0 ) //Tipo de Item 
	oModel:AddField( "HL2_REMITO", "C", 13,	0 ) //Remito
	oModel:AddField( "HL2_SERREM", "C", 3, 	0 ) //Série Remito
	oModel:AddField( "HL2_ITEREM", "C", 4, 	0 ) //Item Remito
	
	oModel:AddField( "HL2_VFATOT", "N", 16, 2 ) //Valor Faturamento Total  
	oModel:AddField( "HL2_VCMFAT", "N", 16, 2 ) //Valor Comissão Faturamento 
	oModel:AddField( "HL2_VLCSFT", "N", 16, 2 ) //Valor Custo Faturamento  
	oModel:AddField( "HL2_VICMSF", "N", 16, 2 ) //ICMS do Faturamento      
	oModel:AddField( "HL2_VIPIFT", "N", 16, 2 ) //Valor IPI Faturamento    
	oModel:AddField( "HL2_VRECFI", "N", 16, 2 ) //Receita Financeira      
	oModel:AddField( "HL2_VFRTNF", "N", 16, 2 ) //Valor Frete NF           
	oModel:AddField( "HL2_VDESPE", "N", 16, 2 ) //Valor das Despesas       
	oModel:AddField( "HL2_VFATME", "N", 16, 2 ) //Faturamento Mercadoria   
	oModel:AddField( "HL2_VFATLQ", "N", 16, 2 ) //Faturmaneto Líquido      
	oModel:AddField( "HL2_VPISFT", "N", 16, 2 ) //PIS do Faturamento       
	oModel:AddField( "HL2_VCOFIN", "N", 16, 2 ) //COFINS do Faturamento    
	oModel:AddField( "HL2_QFATIT", "N", 16, 2 ) //Qtde de Item Faturada    
	oModel:AddField( "HL2_VISSFT", "N", 16, 2 ) //ISS do Faturamento       
	oModel:AddField( "HL2_VICMSS", "N", 16, 2 ) //Vl ICMS Subst Faturamento
	oModel:AddField( "HL2_VLDESF", "N", 16, 2 ) //Vl Desconto Faturamento  
	oModel:AddField( "HL2_VLIRFF", "N", 16, 2 ) //Vl IRF Faturamento       
	oModel:AddField( "HL2_VINSSF", "N", 16, 2 ) //Vl INSS Faturamento      
	oModel:AddField( "HL2_QPRZDP", "N", 16, 4 ) //Qtde Prazo Duplicata     
	oModel:AddField( "HL2_QTPESL", "N", 16, 4 ) //Peso Líquido
	oModel:AddField( "HL2_QTPESB", "N", 16, 4 ) //Peso Bruto
	oModel:AddField( "HL2_VIPINC", "N", 16, 2 ) //Vl Imposto Incidente 
	oModel:AddField( "HL2_VIPNIN", "N", 16, 2 ) //Vl Imposto não Incidente
	oModel:AddField( "HL2_QTDVEN", "N", 16, 4 ) //Quantidade Vendida
	oModel:AddField( "HL2_VLUNIT", "N", 16, 2 ) //Valor Unitário
	oModel:AddField( "HL2_VLCMEV", "N", 16, 2 ) //Custo da Mercadoria Vendida
	oModel:AddField( "HL2_QFATFC", "N", 16, 4 ) //Quantidade Faturada Familia Comercial     
	oModel:AddField( "HL2_QFATFM", "N", 16, 4 ) //Quantidade Faturada Familia Material 

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

@author  Marcia Junko
@since   30/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXFaturamento
	Local oRegion		:= NIL
	Local aMoedas		:= {}
	Local cMoeda		:= ""      
	Local nInd       	:= 1 
	Local nDuplicata 	:= 0
	Local nQtdDuplic 	:= 0
	Local nComisFat 	:= 0 
	Local nFatLiq    	:= 0
	Local lBra			:= cPaisLoc == "BRA"	// Define se a instalação do Protheus é "Brasil"
	Local aImpInf 		:= {}					// Vetor com as informações dos impostos
	Local nI			:= 0
	Local nTotVIPINC	:= 0					// Valor Total dos Impostos Incidentes
	Local nTotVIPNIN	:= 0					// Valor Total dos Impostos Não Incidentes
	Local lDescSai		:= Iif( GetMv("MV_DESCSAI") == "1", .T., .F. )	// Define se visualiza o preço de venda com desconto
	Local nVlImp		:= 0					// Valor Total dos impostos 
	Local nVlFatLiq		:= 0					// Valor Faturamento líquido 
	Local lHasDUD		:= .F.
	Local lHasDT6		:= .F.   
	Local lHasSL1		:= .F.
	Local lHasSL4		:= .F. 
	Local nTxMoeda		:= 0
	Local lTxMoeda 		:= .F.
	Local lRepres 		:= .F.
	Local cDupli		:= ""
	Local cEstoq		:= ""
	Local cPrefixo		:= ""
	Local nTamPref		:= TamSX3("E1_PREFIXO")[1] 	
	Local lFindSA1 		:= .F.
	Local lFindACV 	 	:= .F.
	Local lFindSC5 	 	:= .F.
	Local nAuxVIPINC 	:= 0
	Local nAuxVIPNIN 	:= 0

	Local nJ			:= 0
	Local nK			:= 0
	Local nExecutions	:= 1
	Local nExecFlow		:= 1
	Local nVIPInc 		:= 0
	Local nVIPNin 		:= 0

	Private cRetAlias := getNextAlias()  

	//-------------------------------------------------------------------
	// Para o México, define a execução de dois fluxos para extrair os 
	// dados de nota de crédito (NCC) 
	//-------------------------------------------------------------------  
	If cPaisloc == "MEX"
		nExecutions := 2
	EndIf
	
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 
	aMoedas 	:= BIXGetMxF( ::cEntity )
	oRegion		:= BIXRegiao():New()
	lTxMoeda	:= LoadTxMoeda() //Define a utilização da taxa negociada na conversão de moeda.
	lRepres 	:= LoadRepres() //Define a utilização do representante pelo cadastro do cliente.
	cDupli		:= BIXParInfo( "BIX_TESDUP", "C", "3" ) 
	cEstoq		:= BIXParInfo( "BIX_TESEST", "C", "3" )
	
	//-------------------------------------------------------------------
	// Identifica se deve considerar notas em que TES gera duplicata. 
	//-------------------------------------------------------------------  	
	If ( cDupli == "1" )
		cDupli := "S"
	ElseIf( cDupli == "2" )
		cDupli := "N"
	Else 
		cDupli := "SN"	
	EndIf 
	
	//-------------------------------------------------------------------
	// Identifica se deve considerar notas em que TES movimenta estoque. 
	//-------------------------------------------------------------------  
	If ( cEstoq == "1" )
		cEstoq := "S"
	ElseIf( cEstoq == "2" )
		cEstoq := "N"
	Else 
		cEstoq := "SN"	
	EndIf			
		
	SA1->( dbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
	SA3->( dbSetOrder(1) ) // A3_FILIAL+A3_COD       
	SF4->( dbSetOrder(1) ) 
	SE1->( dbSetOrder(2) )
	DT6->( dbSetOrder(1) ) 
	DUD->( dbSetOrder(1) ) 
	ACV->( dbSetOrder(5) )

	For nExecFlow := 1 to nExecutions
		//-------------------------------------------------------------------
		// Recupera o fluxo de dados da fato. 
		//------------------------------------------------------------------- 
		cRetAlias := ::Flow( cFrom, cTo, nExecFlow ) 
		
		While (cRetAlias)->(! EoF() )
			If IsRemito(1,'(cRetAlias)->TIPODOC')
				(cRetAlias)->(dBSkip())
				Loop
			Endif

			If !AvalTes( (cRetAlias)->TES, cEstoq, cDupli )
				(cRetAlias)->(dBSkip())
				Loop
			Endif
			
			lHasDUD		:= .F.
			lHasDT6	   	:= .F.
			lHasSL1		:= .F. 
			lHasSL4		:= .F. 
			lFindACV 	:= .F.
			lFindSC5 	:= .F.
			lFindSA1 	:= .F.
			nTxMoeda 	:= 0

			//-------------------------------------------------------------------
			// No Mercado internacional, as tabelas SC5, SC7, SF1, SF2, SE1, 
			// SE5 e SE2 utilizam o campo ??_TXMOEDA (TAXA NEGOCIADA) que define
			// a taxa usada para a operação, caso seja ZERO deve ser considerada 
			// a cotação da moeda para o dia.
			//-------------------------------------------------------------------			
			If cPaisLoc != "BRA" .Or. lTxMoeda
				nTxMoeda := (cRetAlias)->TXMOEDA
			EndIf   			
				 
			//-------------------------------------------------------------------
			// Posiciona as tabelas de Entrega (DT6) e Movimento de Vagem (DUD) (Fase 5).  
			//------------------------------------------------------------------- 		     
			If ( DT6->( MsSeek( xFilial("DT6") + xFilial("SD2") + (cRetAlias)->DOCD + (cRetAlias)->SERIED ) ) )
				lHasDT6 := .T. 
			EndIf  
			
			If ( DUD->( MsSeek( xFilial("DUD") + xFilial("SD2") + (cRetAlias)->DOCD + (cRetAlias)->SERIED ) ) )
				lHasDUD := .T. 
			EndIf  	   
				 
			//-------------------------------------------------------------------
			// Posiciona as tabelas de OrÇamento (SL1) e Condição Negociada (SL4) (Fase 5).  
			//------------------------------------------------------------------- 				          
			SL2->( DBSetOrder(3) )
			If ( SL2->( MsSeek( xFilial("SL2") + (cRetAlias)->SERIED + (cRetAlias)->DOCD + (cRetAlias)->COD ) ) )
				SL1->( DBSetOrder(2) )
				lHasSL1 := ( SL1->( MsSeek( xFilial("SL1") + SL2->L2_SERIE + SL2->L2_DOC ) ) )
				
				If ( lHasSL1 ) 
					lHasSL4 :=  ( SL4->( MsSeek( xFilial("SL4") + SL1->L1_NUM  ) ) )
				EndIf 
			EndIf  

			If SA1->( MsSeek( xFilial("SA1") + (cRetAlias)->CLIENTE + (cRetAlias)->LOJA ) )
				lFindSA1 := .T.
			EndIf   
			
			If ACV->( MsSeek( xFilial("ACV") + (cRetAlias)->COD ) )
				lFindACV := .T.
			EndIf
			
			If SC5->( MsSeek( xFilial("SC5") + (cRetAlias)->PEDIDO ) )
				lFindSC5 := .T.
			EndIf
				
			nDuplicata := 0
			nQtdDuplic := 0
			
			cPrefixo := Iif( Empty((cRetAlias)->PREFIXO ), &(SuperGetMV("MV_1DUPREF")), (cRetAlias)->PREFIXO)		
			cPrefixo := Padr( cPrefixo, nTamPref )		
			// Qtde Prazo Duplicata 
			If SE1->(MsSeek(xFilial("SE1") + (cRetAlias)->CLIENTE + (cRetAlias)->LOJA + cPrefixo + (cRetAlias)->DOCF))
				While SE1->(!Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == (cRetAlias)->CLIENTE .And. ;
					SE1->E1_LOJA == (cRetAlias)->LOJA .And. SE1->E1_PREFIXO == cPrefixo .And. SE1->E1_NUM == (cRetAlias)->DOCF
					If (SE1->E1_TIPO == 'NF ')
						nDuplicata += (SE1->E1_VENCTO - SE1->E1_EMISSAO)
						nQtdDuplic += 1
					EndIf
					SE1->(DbSkip())						
				EndDo	
			EndIf

			// Calcula o Valor Total dos Impostos
			nAuxVIPINC := 0
			nAuxVIPNIN := 0
			nVlImp	   := 0
			If !lBra
				aImpInf := TesImpInf((cRetAlias)->TES)

				For nI := 1 to Len (aImpInf)				
					If (cRetAlias)->(FieldPos(aImpInf[nI][02])) > 0					
						If aImpInf[nI][3] == "1" //Incidentes
							nAuxVIPINC += (cRetAlias)->(FieldGet(FieldPos(aImpInf[nI][02])))
						Else // Nao Incidentes
							nAuxVIPNIN += (cRetAlias)->(FieldGet(FieldPos(aImpInf[nI][02])))
						EndIf					
					EndIf
				Next
			EndIf   

			For nInd := 1 To Len(aMoedas)
				cMoeda := aMoedas[nInd][1]
				nTotVIPINC := 0
				nTotVIPNIN := 0
				

				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 				
				oRecord:Init()

				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "D2_DOC"		, (cRetAlias)->DOCD ) 
				oRecord:SetValue( "D2_SERIE"	, (cRetAlias)->SERIED ) 
				oRecord:SetValue( "D2_CLIENTE"	, (cRetAlias)->CLIENTE )
				oRecord:SetValue( "D2_LOJA"		, (cRetAlias)->LOJA )
				oRecord:SetValue( "D2_ITEM"		, (cRetAlias)->ITEM )
				oRecord:SetValue( "B1_COD"		, (cRetAlias)->COD )
				oRecord:SetValue( "BM_GRUPO"	, (cRetAlias)->B1_GRUPO )
				oRecord:SetValue( "A4_COD"		, (cRetAlias)->TRANSP )
				oRecord:SetValue( "F4_CODIGO"	, (cRetAlias)->TES )
				oRecord:SetValue( "A1_COD"		, (cRetAlias)->CLIENTE )
				oRecord:SetValue( "A1_LOJA"		, (cRetAlias)->LOJA )	
				oRecord:SetValue( "E4_CODIGO"	, (cRetAlias)->COND )	
				oRecord:SetValue( "AH_UNIMED"	, (cRetAlias)->UM )	
				oRecord:SetValue( "A2_COD"		, (cRetAlias)->B1_PROC ) 		
				oRecord:SetValue( "A2_LOJA"		, (cRetAlias)->B1_LOJPROC )		
					
				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HL2_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HL2_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HL2_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HL2_TRARED", oSeeker:Seek( "HJ2", { (cRetAlias)->REDESP } ) )
				oRecord:SetValue( "HL2_ORILAN", oSeeker:Seek( "HS7", { (cRetAlias)->ORIGLAN } ) )
				oRecord:SetValue( "HL2_ITEM",   oSeeker:Seek( "HJ8", { (cRetAlias)->COD } ) )
				oRecord:SetValue( "HL2_FAMMAT", oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) )
				oRecord:SetValue( "HL2_GRPEST", oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) )
				oRecord:SetValue( "HL2_TRANSP", oSeeker:Seek( "HJ2", { (cRetAlias)->TRANSP } ) )
				oRecord:SetValue( "HL2_NATOPR", oSeeker:Seek( "HJ9", { (cRetAlias)->TES } ) )
				oRecord:SetValue( "HL2_CFOP",   oSeeker:Seek( "HG0", { (cRetAlias)->CF } ) )
				oRecord:SetValue( "HL2_CONDPG", oSeeker:Seek( "HJA", { (cRetAlias)->COND } ) )
				oRecord:SetValue( "HL2_FORNEC", oSeeker:Seek( "HKJ", { (cRetAlias)->B1_PROC, (cRetAlias)->B1_LOJPROC } ) )
				oRecord:SetValue( "HL2_UNITEM", oSeeker:Seek( "HHW", { (cRetAlias)->UM } ) )
				oRecord:SetValue( "HL2_CLIENT", oSeeker:Seek( "HJ7", { (cRetAlias)->CLIENTE, (cRetAlias)->LOJA } ) )
				oRecord:SetValue( "HL2_MOEDA",  oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) )
				
				If !lRepres
					oRecord:SetValue( "A3_COD"		, (cRetAlias)->VEND1 )	
					oRecord:SetValue( "HL2_REPRES", oSeeker:Seek( "HJC", { (cRetAlias)->VEND1 } ) )
				Else
					oRecord:SetValue( "A3_COD"		, "" )
					oRecord:SetValue( "HL2_REPRES", oSeeker:Seek( "HJC", { UNDEFINED } ) )
				EndIf
				
				iF lFindSA1
					oRecord:SetValue( "ACY_GRPVEN"	, SA1->A1_GRPVEN )				
				
					oRecord:SetValue( "HL2_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
					oRecord:SetValue( "HL2_REGCOM", oSeeker:Seek( "HGD", { SA1->A1_GRPVEN } ) )
					oRecord:SetValue( "HL2_MICREG", oSeeker:Seek( "HGB", { SA1->A1_REGIAO } ) )	
					oRecord:SetValue( "HL2_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS  ) } ) )
					
					If lRepres
						oRecord:SetValue( "A3_COD"		, SA1->A1_VEND )	
						oRecord:SetValue( "HL2_REPRES", oSeeker:Seek( "HJC", { SA1->A1_VEND } ) )
					EndIf
				Else
					oRecord:SetValue( "ACY_GRPVEN"	, "" )				
					
					oRecord:SetValue( "HL2_CLIENT", oSeeker:Seek( "HJ7", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_GRPCLI", oSeeker:Seek( "HJ0", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_REGCOM", oSeeker:Seek( "HGD", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_MICREG", oSeeker:Seek( "HGB", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_REGIAO", oSeeker:Seek( "HJB", { UNDEFINED } ) ) 
				EndIf		

				If lFindSC5
					oRecord:SetValue( "DA0_CODTAB"	, SC5->C5_TABELA )
					oRecord:SetValue( "HL2_TABPCO", oSeeker:Seek( "HGN", { SC5->C5_TABELA } ) )
				Else
					oRecord:SetValue( "DA0_CODTAB"	, "" )
				
					oRecord:SetValue( "HL2_TABPCO", oSeeker:Seek( "HGN", { UNDEFINED } ) ) 
				EndIf
				
				If lFindACV
					oRecord:SetValue( "ACU_COD"		, ACV->ACV_CATEGO )
								
					oRecord:SetValue( "HL2_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) )
				Else
					oRecord:SetValue( "ACU_COD"		, "" )			
				
					oRecord:SetValue( "HL2_FAMCOM", oSeeker:Seek( "HG1", { UNDEFINED } ) ) 
				EndIf
				
				IF lHasDUD
					oRecord:SetValue( "DTQ_VIAGEM"	, DUD->DUD_VIAGEM )
					
					oRecord:SetValue( "HL2_FILORI", oSeeker:Seek( "HO9", { DUD->DUD_FILORI } ) )
					oRecord:SetValue( "HL2_VIAGEM", oSeeker:Seek( "HO7", { DUD->DUD_VIAGEM } ) )
				Else
					oRecord:SetValue( "DTQ_VIAGEM"	, ""  )
				
					oRecord:SetValue( "HL2_FILORI", oSeeker:Seek( "HO9", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_VIAGEM", oSeeker:Seek( "HO7", { UNDEFINED } ) ) 
				EndIf
				
				If lHasDT6
					oRecord:SetValue( "DUY_GRPVEN"	, DT6->DT6_CDRORI )	
					oRecord:SetValue( "DA8_COD"		, DT6->DT6_ROTENT )
				
					oRecord:SetValue( "HL2_SERTRA", oSeeker:Seek( "HO1", { DT6->DT6_SERTMS } ) )
					oRecord:SetValue( "HL2_TIPDOC", oSeeker:Seek( "HO2", { DT6->DT6_DOCTMS } ) )
					oRecord:SetValue( "HL2_TIPTRA", oSeeker:Seek( "HHX", { DT6->DT6_TIPTRA } ) )
					oRecord:SetValue( "HL2_REGTRA", oSeeker:Seek( "HO0", { DT6->DT6_CDRORI } ) )			
					oRecord:SetValue( "HL2_ROTA",   oSeeker:Seek( "HGI", { DT6->DT6_ROTENT } ) )
					
					IF !Empty(DT6->DT6_CLIREM) .And. !Empty(DT6->DT6_LOJREM)
						oRecord:SetValue( "HL2_CLIREM", oSeeker:Seek( "HJ7", { DT6->DT6_CLIREM, DT6->DT6_LOJREM } ) )
					Else
						oRecord:SetValue( "HL2_CLIREM", oSeeker:Seek( "HJ7", { UNDEFINED } ) ) 
					EndIf
					
					IF !Empty( DT6->DT6_CLIDES ) .And. !Empty( DT6->DT6_LOJDES )
						oRecord:SetValue( "HL2_CLIDES", oSeeker:Seek( "HJ7", { DT6->DT6_CLIDES, DT6->DT6_LOJDES } ) )
					Else
						oRecord:SetValue( "HL2_CLIDES", oSeeker:Seek( "HJ7", { UNDEFINED } ) ) 
					EndIf
					
					IF !Empty( DT6->DT6_CLIDEV ) .And. !Empty( DT6->DT6_LOJDEV )
						oRecord:SetValue( "HL2_CLIDEV", oSeeker:Seek( "HJ7", { DT6->DT6_CLIDEV, DT6->DT6_LOJDEV } ) )
					Else
						oRecord:SetValue( "HL2_CLIDEV", oSeeker:Seek( "HJ7", { UNDEFINED } ) ) 
					EndIf	
					
					IF !Empty( DT6->DT6_CDRDES )
						oRecord:SetValue( "HL2_REGDES", oSeeker:Seek( "HJB", { DT6->DT6_CDRDES } ) )
					Else
						oRecord:SetValue( "HL2_REGDES", oSeeker:Seek( "HJB", { UNDEFINED } ) ) 
					EndIf	
				Else
					oRecord:SetValue( "DUY_GRPVEN"	, "" )	
					oRecord:SetValue( "DA8_COD"		, "" )
				
					oRecord:SetValue( "HL2_SERTRA", oSeeker:Seek( "HO1", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_TIPDOC", oSeeker:Seek( "HO2", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_TIPTRA", oSeeker:Seek( "HHX", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_REGTRA", oSeeker:Seek( "HO0", { UNDEFINED } ) ) 		
					oRecord:SetValue( "HL2_ROTA",   oSeeker:Seek( "HGI", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_CLIREM", oSeeker:Seek( "HJ7", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_CLIDES", oSeeker:Seek( "HJ7", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_CLIDEV", oSeeker:Seek( "HJ7", { UNDEFINED } ) ) 
					oRecord:SetValue( "HL2_REGDES", oSeeker:Seek( "HJB", { UNDEFINED } ) ) 
				EndIf
				
				If lHasSL1
					oRecord:SetValue( "UH_MIDIA"	, SL1->L1_MIDIA )
					
					oRecord:SetValue( "HL2_CANMID", oSeeker:Seek( "HS6", { SL1->L1_MIDIA } ) )
					oRecord:SetValue( "HL2_FXHORA", oSeeker:Seek( "HS8", { SL1->L1_HORA } ) )
				Else
					oRecord:SetValue( "UH_MIDIA"	, "" )
					
					oRecord:SetValue( "HL2_CANMID", oSeeker:Seek( "HS6", { UNDEFINED } ) )
					oRecord:SetValue( "HL2_FXHORA", oSeeker:Seek( "HS8", { UNDEFINED } ) )				
				EndIf	
				
				If lHasSL4
					oRecord:SetValue( "HL2_FORPAG", oSeeker:Seek( "HS9", { SL4->L4_FORMA } ) )
				Else
					oRecord:SetValue( "HL2_FORPAG", oSeeker:Seek( "HS9", { UNDEFINED } ) )
				EndIf
				
				oRecord:SetValue( "HL2_PRDUTO", oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
				oRecord:SetValue( "HL2_CANALV", oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
				oRecord:SetValue( "HL2_REFER",  oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
				
				//-------------------------------------------------------------------
				// Atributos.
				//-------------------------------------------------------------------
				If lBra
					If !Empty((cRetAlias)->F2_EMINFE)
						oRecord:SetValue( "HL2_DTSANF", (cRetAlias)->F2_EMINFE )
					Else
						oRecord:SetValue( "HL2_DTSANF", IIf(!Empty((cRetAlias)->EMISSAOF), (cRetAlias)->EMISSAOF, DATE_EMPTY) )
					EndIf
				Else
					oRecord:SetValue( "HL2_DTSANF", IIf(!Empty((cRetAlias)->EMISSAOF), (cRetAlias)->EMISSAOF, DATE_EMPTY) )
				EndIf
			
				// Atributos - Dimensão Degeneradas
				oRecord:SetValue( "HL2_DATA", IIf(!Empty((cRetAlias)->EMISSAOF),(cRetAlias)->EMISSAOF, DATE_EMPTY) ) // Data da Emissão da Nota Fiscal
				oRecord:SetValue( "HL2_SERNF", SerieNFID( cRetAlias, 2, Iif(nExecFlow == 1, "F2_SERIE", "F1_SERIE") ) )		// Série da Nota Fiscal
				oRecord:SetValue( "HL2_NUMNF", (cRetAlias)->DOCF )                     	// Número da Nota Fiscal
				oRecord:SetValue( "HL2_PEDIDO", (cRetAlias)->PEDIDO )                 	// Número do Pedido de Venda
				oRecord:SetValue( "HL2_NMITNF", (cRetAlias)->ITEM )                   	// Número do Item
				oRecord:SetValue( "HL2_TPFRET", (cRetAlias)->TPFRETE )                	// Tipo de Frete
				oRecord:SetValue( "HL2_TPNOTA", (cRetAlias)->TIPO )                   	// Tipo de Nota Fiscal
				oRecord:SetValue( "HL2_REMITO", (cRetAlias)->REMITO )                 	// Remito
				oRecord:SetValue( "HL2_SERREM", SerieNFID( cRetAlias, 2, Iif(nExecFlow ==1, "D2_SERIREM", "D1_SERIREM") ) )	// Serie Remito
				oRecord:SetValue( "HL2_ITEREM", (cRetAlias)->ITEMREM )               	// Item Remito
				oRecord:SetValue( "HL2_TPCPIT", " " )                                   	// Tipo de Item da Nota Fiscal
				
				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
			
				// Vl Comissão Faturamento
				If SA3->(MsSeek(xFilial("SA3") + (cRetAlias)->VEND1))
					nComisFat := ((cRetAlias)->TOTAL * (SA3->A3_COMIS/100))
				Else
					nComisFat := 0
				EndIf
				
				oRecord:SetValue( "HL2_QPRZDP", Round((nDuplicata / nQtdDuplic), 4) )	// Qtde Prazo Duplicata
				
				If SF4->(MsSeek(xFilial("SF4") + (cRetAlias)->TES ))
					oRecord:SetValue( "HL2_FBXEST", SF4->F4_ESTOQUE )
					oRecord:SetValue( "HL2_FGERDP", SF4->F4_DUPLIC )
				Else
					oRecord:SetValue( "HL2_FBXEST", " " )
					oRecord:SetValue( "HL2_FGERDP", " " )
				EndIf
					   
				oRecord:SetValue( "HL2_QTDVEN", 1 ) //Quantidade 
				oRecord:SetValue( "HL2_QFATIT", (cRetAlias)->QUANT )// Qtde Faturada Item
				oRecord:SetValue( "HL2_QTPESL", ((cRetAlias)->PESO * (cRetAlias)->QUANT) )          // Peso Líquido
				oRecord:SetValue( "HL2_QTPESB", ((cRetAlias)->B1_PESBRU * (cRetAlias)->QUANT) )		// Peso Bruto
				oRecord:SetValue( "HL2_VLCSFT", ( &("(cRetAlias)->" + iIF(nExecFlow == 1, "D2_CUSTO" + Alltrim(cMoeda), Iif(cMoeda == "1", "D1_CUSTO", "D1_CUSTO" + Alltrim(cMoeda) )) ) * Iif( nExecFlow == 1, 1, -1) ) )  		// Vl Custo Faturamento
				oRecord:SetValue( "HL2_VCMFAT", ( BIXValue( nComisFat,(cRetAlias)->MOEDA, cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda ) * Iif( nExecFlow == 1, 1, -1) )) // Vl Comissão Faturamento
				
				If lBra
					oRecord:SetValue( "HL2_VFATOT", BIXValue((cRetAlias)->D2_VALBRUT, (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl Faturamento Total								
					oRecord:SetValue( "HL2_VISSFT", BIXValue((cRetAlias)->D2_VALISS, (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl ISS Faturamento
					oRecord:SetValue( "HL2_VICMSS", BIXValue((cRetAlias)->D2_ICMSRET, (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl ICMS Subst Faturamento
					oRecord:SetValue( "HL2_VLIRFF", BIXValue((cRetAlias)->D2_VALIRRF, (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl IRF Faturamento
					oRecord:SetValue( "HL2_VINSSF", BIXValue((cRetAlias)->D2_VALINS, (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl INSS Faturamento
					oRecord:SetValue( "HL2_VPISFT", BIXValue((cRetAlias)->D2_VALIMP6, (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl PIS Faturamento
					oRecord:SetValue( "HL2_VCOFIN", BIXValue((cRetAlias)->D2_VALIMP5, (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl COFINS Faturamento
					oRecord:SetValue( "HL2_VICMSF", BIXValue((cRetAlias)->D2_VALICM  , (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl ICMS Faturamento
					oRecord:SetValue( "HL2_VIPIFT", BIXValue((cRetAlias)->D2_VALIPI  , (cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda) )  // Vl IPI Faturamento
					oRecord:SetValue( "HL2_VIPINC", 0 )	// Vl Impostos Incidentes
					oRecord:SetValue( "HL2_VIPNIN", 0 )	// Vl Impostos não incidentes

					//Calcula o valor dos impostos
					nVlImp := (cRetAlias)->( D2_VALISS + D2_ICMSRET + D2_VALIRRF + D2_VALINS + D2_VALIMP6 + D2_VALIMP5 + D2_VALICM + D2_VALIPI )
					
					nVlFatLiq := (cRetAlias)->D2_VALBRUT - BIXValue(nVlImp, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda)  
				else
					nTotVIPINC := BIXValue(nAuxVIPINC, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda) 
					nTotVIPNIN := BIXValue(nAuxVIPNIN, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda)

					oRecord:SetValue( "HL2_VFATOT", ( BIXValue((cRetAlias)->TOTAL,(cRetAlias)->MOEDA,cMoeda,(cRetAlias)->EMISSAOD, nTxMoeda)  * Iif( nExecFlow == 1, 1, -1) ) )   // Vl Faturamento Total							
					oRecord:SetValue( "HL2_VISSFT", 0 )  				// Vl ISS Faturamento
					oRecord:SetValue( "HL2_VICMSS", 0 )  				// Vl ICMS Subst Faturamento
					oRecord:SetValue( "HL2_VLIRFF", 0 )  				// Vl IRF Faturamento
					oRecord:SetValue( "HL2_VINSSF", 0 )  				// Vl INSS Faturamento
					oRecord:SetValue( "HL2_VPISFT", 0 )  				// Vl PIS Faturamento
					oRecord:SetValue( "HL2_VCOFIN", 0 )  				// Vl COFINS Faturamento
					oRecord:SetValue( "HL2_VICMSF", 0 )  				// Vl ICMS Faturamento
					oRecord:SetValue( "HL2_VIPIFT", 0 )  				// Vl IPI Faturamento
					oRecord:SetValue( "HL2_VIPINC", nTotVIPINC  * Iif( nExecFlow == 1, 1, -1) )		// Vl Impostos Incidentes
					oRecord:SetValue( "HL2_VIPNIN", nTotVIPNIN  * Iif( nExecFlow == 1, 1, -1) )		// Vl Impostos não incidentes

					//Calcula o valor dos impostos
					nVlImp := nTotVIPINC + nTotVIPNIN
					
					nVlFatLiq := (cRetAlias)->TOTAL - nVlImp				
				EndIf
				
				oRecord:SetValue( "HL2_VFRTNF", ( BIXValue((cRetAlias)->VALFRE, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda) * Iif( nExecFlow == 1, 1, -1) ) ) // Vl Frete NF
				oRecord:SetValue( "HL2_VLDESF", ( BIXValue((cRetAlias)->DESCON, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda) * Iif( nExecFlow == 1, 1, -1) ) )  // Vl Desconto Faturamento
				oRecord:SetValue( "HL2_VDESPE", ( BIXValue((cRetAlias)->DESPESA, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda) * Iif( nExecFlow == 1, 1, -1) ) )  // Vl Despesas
				oRecord:SetValue( "HL2_VFATME", ( BIXValue((cRetAlias)->TOTAL, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda) * Iif( nExecFlow == 1, 1, -1) ) )  // Vl Faturamento Mercadoria
						
				If lDescSai
					nVlFatLiq := nVlFatLiq - (cRetAlias)->DESCON
				EndIf
				
				oRecord:SetValue( "HL2_VFATLQ", ( BIXValue(nVlFatLiq, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD, nTxMoeda)  * Iif( nExecFlow == 1, 1, -1) ) ) // Vl Faturamento Líquido
				
				If nExecFlow == 1
					oRecord:SetValue( "HL2_VLUNIT", BIXValue( (cRetAlias)->D2_PRUNIT, (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD,  nTxMoeda ) ) //Valor Unitário      
				else
					oRecord:SetValue( "HL2_VLUNIT", 0 ) //Valor Unitário      
				EndIf
				
				oRecord:SetValue( "HL2_VLCMEV", ( BIXValue( PegaCMAtu((cRetAlias)->COD, (cRetAlias)->LOCAL)[1], (cRetAlias)->MOEDA, cMoeda, (cRetAlias)->EMISSAOD,  nTxMoeda ) * Iif( nExecFlow == 1, 1, -1) ) ) 					//Custo da Mercadoria Vendida 
				oRecord:SetValue( "HL2_QFATFM", 0 )			                                            // Qtde Faturada Familia Material
				oRecord:SetValue( "HL2_QFATFC", 0 )			                                            // Qtde Faturada Familia Comercial
				oRecord:SetValue( "HL2_VRECFI", 0 )                                                     // Vl Receita Financeira

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nInd
			(cRetAlias)->( DbSkip() )
		EndDo
		(cRetAlias)->( DBCloseArea() )
	Next
	
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
@param nExecFlow, caracter, Identificador do fluxo.  

@author  Marcia Junko
@since   30/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, nExecFlow ) Class BIXFaturamento
	Local cQuery 	:= ""
	Local lBra		:= cPaisLoc == "BRA"	// Define se a instalação do Protheus é "Brasil"
	Local cNumFields := ""
	
	//-------------------------------------------------------------------
	// Foram criados dois fluxos, para que quando for extraída uma 
	// base México, também sejam inseridas na fato os dados de nota 
	// de crédito (NCC) vindas da SF1\SD1. 
	//-------------------------------------------------------------------  
	If nExecFlow == 1
		cQuery := "SELECT D2_CLIENTE CLIENTE, D2_LOJA LOJA, D2_COD COD, D2_CF CF, D2_TIPODOC TIPODOC, " 
		cQuery += "   D2_DOC DOCD, D2_SERIE SERIED, D2_ITEM ITEM, D2_PEDIDO PEDIDO, D2_TES TES, "
		cQuery += "   D2_TIPO TIPO, D2_TOTAL TOTAL, D2_QUANT QUANT, D2_PESO PESO, D2_EMISSAO EMISSAOD, "
		cQuery	+= "  D2_VALFRE VALFRE, D2_DESCON DESCON, D2_DESPESA DESPESA, D2_UM UM, "
		cQuery += "		D2_LOCAL LOCAL, D2_REMITO REMITO, D2_SERIREM, D2_ITEMREM ITEMREM, "
		cQuery += "		D2_ORIGLAN ORIGLAN, SD2.R_E_C_N_O_ ID, "

		cQuery += cBIConcatWSep( ",", BIXGetNumField( "SD2" )) + ", "
			
		If lBra
			cQuery += "  F2_EMINFE, "
		EndIf 

		cQuery += "   F2_SERIE, F2_PREFIXO PREFIXO, F2_DOC DOCF, F2_EMISSAO EMISSAOF, F2_TPFRETE TPFRETE, F2_REDESP REDESP, "
		cQuery += "   F2_MOEDA MOEDA, F2_TXMOEDA TXMOEDA, F2_TRANSP TRANSP, F2_COND COND, F2_VEND1 VEND1, "
		cQuery += "   B1_GRUPO, B1_TIPO, B1_PESBRU, B1_PROC, B1_LOJPROC "
		cQuery += "FROM " + RetSQLName("SD2") + " SD2 "
		cQuery += "INNER JOIN " + RetSqlName("SF2") + " SF2 "
		cQuery += "ON F2_FILIAL = '" + xFilial("SF2") + "' "
		cQuery += "   AND F2_DOC = D2_DOC " 
		cQuery += "   AND F2_SERIE = D2_SERIE "
		cQuery += "   AND F2_CLIENTE = D2_CLIENTE "
		cQuery += "   AND F2_LOJA = D2_LOJA "
		cQuery += "   AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "ON B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += "   AND B1_COD = D2_COD "
		cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D2_FILIAL = '" + xFilial("SD2") + "' " 	
		cQuery += "AND D2_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' "
		cQuery += "AND D2_TIPO NOT IN ('B', 'D') AND SD2.D_E_L_E_T_ = ' '"   
	Else
		cQuery := "SELECT D1_FORNECE CLIENTE, D1_LOJA LOJA, D1_COD COD, D1_CF CF, D1_TIPODOC TIPODOC, " 
		cQuery += "   D1_DOC DOCD, D1_SERIE SERIED, D1_ITEM ITEM, D1_PEDIDO PEDIDO, D1_TES TES, "
		cQuery += "   D1_TIPO TIPO, D1_TOTAL TOTAL, D1_QUANT QUANT, D1_PESO PESO, D1_EMISSAO EMISSAOD, " 
		cQuery += "   D1_VALFRE VALFRE, D1_VALDESC DESCON, D1_DESPESA DESPESA , D1_UM UM, "
		cQuery += "	  D1_LOCAL LOCAL, D1_REMITO REMITO, D1_SERIREM, D1_ITEMREM ITEMREM, "
		cQuery += "   D1_ORIGLAN ORIGLAN, SD1.R_E_C_N_O_ ID, "

		cQuery += cBIConcatWSep( ",", BIXGetNumField( "SD1" )) + ", "

		cQuery += "   F1_SERIE, F1_PREFIXO PREFIXO, F1_DOC DOCF, F1_EMISSAO EMISSAOF, '' TPFRETE, '' REDESP, "
		cQuery += "   F1_MOEDA MOEDA, F1_TXMOEDA TXMOEDA, F1_TRANSP TRANSP, F1_COND COND, F1_VEND1 VEND1, "
		cQuery += "   B1_GRUPO, B1_TIPO, B1_PESBRU, B1_PROC, B1_LOJPROC "
		cQuery += "FROM " + RetSQLName("SD1") + " SD1 "
		cQuery += "INNER JOIN " + RetSqlName("SF1") + " SF1 "
		cQuery += "ON F1_FILIAL = '" + xFilial("SF1") + "' "
		cQuery += "   AND F1_DOC = D1_DOC " 
		cQuery += "   AND F1_SERIE = D1_SERIE "
		cQuery += "   AND F1_FORNECE = D1_FORNECE "
		cQuery += "   AND F1_LOJA = D1_LOJA "
		cQuery += "   AND SF1.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "ON B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += "   AND B1_COD = D1_COD "
		cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' " 	
		cQuery += "AND D1_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' "
		cQuery += "AND F1_ESPECIE = 'NCC' AND SD1.D_E_L_E_T_ = ' '"  
	EndIf

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), ::cFlow := GetNextAlias() , .T., .F. )
	
	TcSetField( ::cFlow, "EMISSAOD", "D", 8, 0 ) 		
	TcSetField( ::cFlow, "EMISSAOF", "D", 8, 0 )

	If nExecFlow == 1	
		If lBra
			TcSetField( ::cFlow, "F2_EMINFE", "D", 8, 0 )
		EndIf
	EndIf
Return ::cFlow

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetNumField
Função auxiliar para retorno dos campos com tipo numérico.

@param cAlias	 	Alias da tabela 

@author  Marcia Junko
@since   06/06/2017
/*/
//-------------------------------------------------------------------
Static Function BIXGetNumField( cAlias )
	Local aStru := (cAlias)->(DbStruct())
	Local aRet	:= {}
	
	aEval(aStru, {|x| Iif( x[2] == "N",  Aadd( aRet, x[1]), ) } )
	
Return aRet 

