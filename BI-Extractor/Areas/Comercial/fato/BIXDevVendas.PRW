#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDEVVENDAS.CH"

REGISTER EXTRACTOR HL6 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDevVendas
A tabela fato Devolução de Vendas apresenta informações relacionadas as
devoluções das vendas, como valores e quantidades devolvidas e impostos.

@author  Helio Leal
@since   09/05/2017
/*/
//-------------------------------------------------------------------
Class BIXDevVendas from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author Helio Leal  
@since   09/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXDevVendas
	_Super:New( FACT, "HL6", STR0001, "SD1", { COMERCIAL } ) //"Devolução de Vendas"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author Helio Leal  
@since   09/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXDevVendas
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HL6_EMPRES"	,	"C",	32,	 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HL6_ESTABL"	,	"C",	32,	 00, .T., "HKK" ) //"Estabelecimento""
	oModel:AddField( "HL6_PRDUTO"	,	"C",	32,	 00, .T., "HJ3" ) //"Produto Comercial"	
	oModel:AddField( "HL6_ROTA"		,	"C",	32,	 00, .T., "HGI") //"Rota"
	oModel:AddField( "HL6_CANALV"	,	"C",	32,	 00, .T., "HGA" ) //"Canal de Venda"	
	oModel:AddField( "HL6_MICREG"	,	"C",	32,	 00, .T., "HGB" ) //"Microrregião"	
	oModel:AddField( "HL6_GRPCLI"	,	"C",	32,	 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HL6_MOEDA"	,	"C",	32,	 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL6_REFER"	,	"C",	32,	 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HL6_UNDNEG"	,	"C",	32,	 00, .T., "HJ1" ) //"Unidade de Negócio"	
	oModel:AddField( "HL6_REGIAO"	,	"C",	32,	 00, .T., "HJB" ) //"Região"	
	oModel:AddField( "HL6_NATOPR"	,	"C",	32,	 00, .T., "HJ9" ) //"Natureza de Operação"
	oModel:AddField( "HL6_CFOP"		,	"C",	32,	 00, .T., "HG0" ) //"CFOP"	
	oModel:AddField( "HL6_TRANSP"	,	"C",	32,	 00, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HL6_CONDPG"	,	"C",	32,	 00, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HL6_ITEM"		,	"C",	32,	 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HL6_FAMCOM"	,	"C",	32,	 00, .T., "HG1" ) //"Família Comercial"
	oModel:AddField( "HL6_FAMMAT"	,	"C",	32,	 00, .T., "HG2" ) //"Família Material"
	oModel:AddField( "HL6_GRPEST"	,	"C",	32,	 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HL6_REGCOM"	,	"C",	32,	 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL6_REPRES"	,	"C",	32,	 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HL6_CLIENT"	,	"C",	32,	 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HL6_UNITEM"	,	"C",	32,	 00, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HL6_DATA"		, 	"D",	08,	 00, .F., "HK2" ) //"Período"
	
	oModel:AddField( "HL6_SERDEV"	,	"C",	08,	 00 ) // Série do Documento Cliente
	oModel:AddField( "HL6_NUMDEV"	,	"C",	35,	 00 ) // Número do Documento Cliente
	oModel:AddField( "HL6_SEQDEV"	,	"C",	10,	 00 ) // Número do Item do Documento
	oModel:AddField( "HL6_SERNF"	,	"C",	08,	 00 ) // Série da Nota Fiscal
	oModel:AddField( "HL6_NUMNF"	,	"C",	35,	 00 ) // Número da Nota Fiscal
	oModel:AddField( "HL6_SEQNF"	, 	"C",	12,	 00 ) // Número do Item da Nota Fiscal
	oModel:AddField( "HL6_REMITO"	,	"C",	13,	 00 ) // Número Remito
	oModel:AddField( "HL6_SERREM"	,	"C",	03,	 00 ) // Serie do Remito
	oModel:AddField( "HL6_ITEREM"	,	"C",	04,	 00 ) // Item Remito
	                                                   
	oModel:AddField( "HL6_QDEVFC"	,	"N",	16,	 04 ) // Qtde Devolvida Família Comercial
	oModel:AddField( "HL6_QDEVIT"	,	"N",	16,	 04 ) // Qtde Devolvida Item
	oModel:AddField( "HL6_QDEVFM"	,	"N",	16,	 04 ) // Qtde Devolvida Familia Material	
	oModel:AddField( "HL6_VDEVTO"	,	"N",	16,	 02 ) // Vl Devolução Total
	oModel:AddField( "HL6_VDESDV"	,	"N",	16,	 02 ) // Vl Desconto Devolução
	oModel:AddField( "HL6_VDEVLQ"	,	"N",	16,	 02 ) // Vl Devolução Líquida
	oModel:AddField( "HL6_VDEVME"	,	"N",	16,	 02 ) // Vl Devolução Mercadoria
	oModel:AddField( "HL6_VCSTDV"	,	"N",	16,	 02 ) // Vl Custo Devolução		
	oModel:AddField( "HL6_VICMSD"	,	"N",	16,	 02 ) // Vl Devolução ICMS
	oModel:AddField( "HL6_VIPIDV"	,	"N",	16,	 02 ) // Vl Devolução IPI
	oModel:AddField( "HL6_VPISDV"	,	"N",	16,	 02 ) // Vl Devolução PIS
	oModel:AddField( "HL6_VCOFID"	,	"N",	16,	 02 ) // Vl Devolução COFINS
	oModel:AddField( "HL6_VICMSS"	,	"N",	16,	 02 ) // Vl Devolução ICMS Subst.
	oModel:AddField( "HL6_VINSSD"	,	"N",	16,	 02 ) // Vl Devolução INSS
	oModel:AddField( "HL6_VIPINC"	,	"N",	16,	 02 ) // Vl Imposto Incidente.
	oModel:AddField( "HL6_VIPNIN"	,	"N",	16,	 02 ) // Vl Imposto não Incidente. 

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
@param oSeeker, objeto, Objeto para validação de integridade referencial.

@author  Helio Leal
@since   09/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXDevVendas
	Local oRegion		:= Nil
	Local aMoeda 		:= {}
	Local aImpInf 	:= {} // Vetor com as informações dos impostos
	Local lFee			:= .F.
	Local lBrasil	 	:= .T.
	Local lRepres		:= .F.
	Local cMoedaCab	:= ""
	Local cMoeda		:= ""
	Local xDataCab	:= ""
	Local nMoeda		:= 0
	Local nFee			:= 0
	Local nTotVIPINC 	:= 0 // Valor Total dos Impostos Incidentes
	Local nTotVIPNIN 	:= 0 // Valor Total dos Impostos Não Incidentes
	Local nVlImp	 	:= 0
	Local nImp			:= 0
	Private cRetAlias		:= ""
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato.
	//-------------------------------------------------------------------
	aMoeda		:= BIXGetMxF( ::cEntity )
	lFee 		:= BIXParInfo( "BIX_TXMOED"	, "L", .F. )
	lRepres 	:= BIXParInfo( "BIX_REPRES"	, "L", .F. )
	oRegion	:= BIXRegiao():New()
	lBrasil	:= cPaisLoc == "BRA"

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cRetAlias := ::Flow( cFrom, cTo )

	If lBrasil
		cMoedaCab	:= "(cRetAlias)->F2_MOEDA"
		xDataCab	:= "(cRetAlias)->F2_EMISSAO"
	Else
		cMoedaCab	:= "(cRetAlias)->F1_MOEDA"
		xDataCab	:= "(cRetAlias)->F1_EMISSAO"
	EndIf

	While ! (cRetAlias)->( Eof() )
		If IsRemito( 1, '(cRetAlias)->D1_TIPODOC' )
			(cRetAlias)->( DBSkip() )
			Loop
		EndIf

		//-------------------------------------------------------------------
		// Identifica se utiliza a taxa negociada para moeda.
		//------------------------------------------------------------------- 
		If ( ! lBrasil .Or. lFee )
			If lBrasil
				nFee := (cRetAlias)->F2_TXMOEDA
			Else
				nFee := (cRetAlias)->F1_TXMOEDA
			EndIf
		Endif

		//-------------------------------------------------------------------
		// Calcula o Valor Total dos Impostos
		//-------------------------------------------------------------------
		nTotVIPINC	:= 0
		nTotVIPNIN	:= 0
		nVlImp	   	:= 0

		If !lBrasil
			aImpInf := TesImpInf((cRetAlias)->D1_TES)

			For nImp := 1 to Len (aImpInf)
				If (cRetAlias)->(FieldPos(aImpInf[nImp][02])) > 0
					If aImpInf[nImp][3] == "1" //Incidentes
						nTotVIPINC += (cRetAlias)->(FieldGet(FieldPos(aImpInf[nImp][02])))
					Else // Nao Incidentes
						nTotVIPNIN += (cRetAlias)->(FieldGet(FieldPos(aImpInf[nImp][02])))
					EndIf
				EndIf
			Next
		EndIf

		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D1_DOC"		, (cRetAlias)->D1_DOC )
			oRecord:SetValue( "D1_SERIE"	, (cRetAlias)->D1_SERIE )
			oRecord:SetValue( "D1_FORNECE"	, (cRetAlias)->D1_FORNECE )
			oRecord:SetValue( "D1_LOJA"		, (cRetAlias)->D1_LOJA )
			oRecord:SetValue( "D1_ITEM"		, (cRetAlias)->D1_ITEM )  
			oRecord:SetValue( "A1_COD"		, (cRetAlias)->D1_FORNECE )
			oRecord:SetValue( "A1_LOJA"		, (cRetAlias)->D1_LOJA ) 
			oRecord:SetValue( "ACY_GRPVEN"	, (cRetAlias)->A1_GRPVEN )			
			oRecord:SetValue( "B1_COD"		, (cRetAlias)->D1_COD )
			oRecord:SetValue( "BM_GRUPO"	, (cRetAlias)->B1_GRUPO )			
			oRecord:SetValue( "AH_UNIMED"	, (cRetAlias)->D1_UM )
			oRecord:SetValue( "ACU_COD"		, (cRetAlias)->ACV_CATEGO )
			oRecord:SetValue( "A4_COD"		, (cRetAlias)->TRANSP )			
			oRecord:SetValue( "E4_CODIGO"	, (cRetAlias)->COND )
			oRecord:SetValue( "A3_COD"		, (cRetAlias)->VEND )			
			oRecord:SetValue( "F4_CODIGO"	, (cRetAlias)->D1_TES )		

			//-------------------------------------------------------------------
			// Lookups.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HL6_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HL6_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HL6_MICREG"	, oSeeker:Seek( "HGB", { (cRetAlias)->A1_REGIAO } ) )
			oRecord:SetValue( "HL6_GRPCLI"	, oSeeker:Seek( "HJ0", { (cRetAlias)->A1_TIPO } ) )
			oRecord:SetValue( "HL6_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HL6_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HL6_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( (cRetAlias)->A1_EST, (cRetAlias)->A1_COD_MUN, (cRetAlias)->A1_PAIS ) } ) )
			oRecord:SetValue( "HL6_NATOPR" 	, oSeeker:Seek( "HJ9", { (cRetAlias)->D1_TES } ))
			oRecord:SetValue( "HL6_CFOP" 	, oSeeker:Seek( "HG0", { (cRetAlias)->D1_CF } ))
			oRecord:SetValue( "HL6_TRANSP"	, oSeeker:Seek( "HJ2", { (cRetAlias)->TRANSP } ) )
			oRecord:SetValue( "HL6_CONDPG"	, oSeeker:Seek( "HJA", { (cRetAlias)->COND } ) )
			oRecord:SetValue( "HL6_ITEM"	, oSeeker:Seek( "HJ8", { (cRetAlias)->D1_COD } ) ) 	
			oRecord:SetValue( "HL6_FAMCOM" 	, oSeeker:Seek( "HG1", { (cRetAlias)->ACV_CATEGO } ) ) 	
			oRecord:SetValue( "HL6_FAMMAT"	, oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) ) 	
			oRecord:SetValue( "HL6_GRPEST"	, oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) ) 	
			oRecord:SetValue( "HL6_REGCOM"	, oSeeker:Seek( "HGD", { (cRetAlias)->A1_GRPVEN } ) )
			oRecord:SetValue( "HL6_REPRES"	, oSeeker:Seek( "HJC", { (cRetAlias)->VEND } ) )
			oRecord:SetValue( "HL6_CLIENT"	, oSeeker:Seek( "HJ7", { (cRetAlias)->D1_FORNECE, (cRetAlias)->D1_LOJA } ) )
			oRecord:SetValue( "HL6_UNITEM" 	, oSeeker:Seek( "HHW", { (cRetAlias)->D1_UM } ) )
			oRecord:SetValue( "HL6_ROTA"	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
			oRecord:SetValue( "HL6_CANALV" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL6_PRDUTO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL6_REFER" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL6_DATA" 	, IIf(!Empty( (cRetAlias)->D1_DTDIGIT), (cRetAlias)->D1_DTDIGIT, DATE_EMPTY) )

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HL6_NUMDEV"	, (cRetAlias)->D1_DOC )

			If lBrasil
				oRecord:SetValue( "HL6_NUMNF"	, (cRetAlias)->F2_DOC )
				oRecord:SetValue( "HL6_SERNF"	, SerieNFID(cRetAlias, 2, "F2_SERIE") )
			Else
				oRecord:SetValue( "HL6_NUMNF"	, (cRetAlias)->D1_NFORI )
				oRecord:SetValue( "HL6_SERNF"	, SerieNFID(cRetAlias, 2, "D1_SERIORI") ) // Série da Nota Fiscal
			EndIf

			oRecord:SetValue( "HL6_SEQDEV"	, (cRetAlias)->D1_ITEM )
			oRecord:SetValue( "HL6_SERDEV"	, SerieNFID(cRetAlias, 2, "D1_SERIE") )
			oRecord:SetValue( "HL6_SEQNF"	, (cRetAlias)->(D1_DOC + SerieNFID(cRetAlias, 2, "D1_SERIE")) )
			oRecord:SetValue( "HL6_REMITO"	, (cRetAlias)->D1_REMITO )
			oRecord:SetValue( "HL6_SERREM"	, SerieNFID(cRetAlias, 2, "D1_SERIREM") )
			oRecord:SetValue( "HL6_ITEREM"	, (cRetAlias)->D1_ITEMREM )

			//-------------------------------------------------------------------
			// Indicadores.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HL6_QDEVFC"	, 0 )
			oRecord:SetValue( "HL6_QDEVFM"	, 0 )
			oRecord:SetValue( "HL6_QDEVIT"	, (cRetAlias)->D1_QUANT )
			oRecord:SetValue( "HL6_VDESDV"	, BIXValue((cRetAlias)->D1_VALDESC,&cMoedaCab,cMoeda,&xDataCab, nFee) )
			oRecord:SetValue( "HL6_VDEVME"	, BIXValue((cRetAlias)->(D1_TOTAL-D1_VALDESC),&cMoedaCab,cMoeda,&xDataCab, nFee) )
			oRecord:SetValue( "HL6_VDEVTO"	, BIXValue((cRetAlias)->(D1_TOTAL+D1_VALIPI+D1_ICMSRET),&cMoedaCab,cMoeda,&xDataCab, nFee) )

			If lBrasil
				oRecord:SetValue( "HL6_VINSSD" , BIXValue((cRetAlias)->D1_VALINS,&cMoedaCab,cMoeda,&xDataCab, nFee) )
				oRecord:SetValue( "HL6_VICMSD" , BIXValue((cRetAlias)->D1_VALICM,&cMoedaCab,cMoeda,&xDataCab, nFee)	)
				oRecord:SetValue( "HL6_VIPIDV" , BIXValue((cRetAlias)->D1_VALIPI,&cMoedaCab,cMoeda,&xDataCab, nFee)	)
				oRecord:SetValue( "HL6_VPISDV" , BIXValue((cRetAlias)->D1_VALIMP6,&cMoedaCab,cMoeda,&xDataCab, nFee) )
				oRecord:SetValue( "HL6_VCOFID" , BIXValue((cRetAlias)->D1_VALIMP5,&cMoedaCab,cMoeda,&xDataCab, nFee) )
				oRecord:SetValue( "HL6_VICMSS" , BIXValue((cRetAlias)->D1_ICMSRET,&cMoedaCab,cMoeda,&xDataCab, nFee) )
				oRecord:SetValue( "HL6_VIPINC" , 0 )
				oRecord:SetValue( "HL6_VIPNIN" , 0 )
				nVlImp := (cRetAlias)->D1_VALICM + (cRetAlias)->D1_VALIMP5 + (cRetAlias)->D1_VALIMP6 + (cRetAlias)->D1_VALDESC

				oRecord:SetValue( "HL6_VDEVLQ" , BIXValue(((cRetAlias)->D1_TOTAL - nVlImp),&cMoedaCab,cMoeda,&xDataCab, nFee) )
			Else
				oRecord:SetValue( "HL6_VINSSD" , 0 )
				oRecord:SetValue( "HL6_VICMSD" , 0 )
				oRecord:SetValue( "HL6_VIPIDV" , 0 )
				oRecord:SetValue( "HL6_VPISDV" , 0 )
				oRecord:SetValue( "HL6_VCOFID" , 0 )
				oRecord:SetValue( "HL6_VICMSS" , 0 )
				oRecord:SetValue( "HL6_VIPINC" , BIXValue(nTotVIPINC, &cMoedaCab, cMoeda, &xDataCab, nFee) )
				oRecord:SetValue( "HL6_VIPNIN" , BIXValue(nTotVIPNIN, &cMoedaCab, cMoeda, &xDataCab, nFee) )
				nVlImp := oRecord:GetValue( "HL6_VIPINC" ) + oRecord:GetValue( "HL6_VIPNIN" )

				oRecord:SetValue( "HL6_VDEVLQ" , BIXValue(((cRetAlias)->D1_TOTAL - nVlImp), &cMoedaCab, cMoeda, &xDataCab, nFee) ) 
			EndIf

			//-------------------------------------------------------------------
			// Valor Custo Devolução.
			//-------------------------------------------------------------------
			If SB2->( MsSeek(xFilial("SB2") + (cRetAlias)->D1_COD + (cRetAlias)->D1_LOCAL) )
				//-------------------------------------------------------------------
				// Força a gravação para 2 casas decimais, pois é um valor.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HL6_VCSTDV" , Round((cRetAlias)->D1_QUANT * & ("SB2->B2_CM" + cMoeda), 2) )
			EndIf

			oOutput:Send( oRecord )						
		Next nMoeda

		(cRetAlias)->( DBSkip() )
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
	oOutput:Release()
Return

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

@author  Helio Leal
@since   09/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXDevVendas
	Local cDML 			:= ""
	Local lBrasil			:= cPaisLoc == "BRA"
	Local lIgnoreClient 	:= BIXParInfo( "BIX_DEVVEN", "L", .F. )
	
	If lBrasil
		cDML := "SELECT D1_DOC, D1_SERIE, D1_TIPODOC, D1_TIPO, D1_NFORI, "
		cDML += "   D1_SERIORI, D1_FORNECE, D1_LOJA, D1_COD, D1_LOCAL, "
		cDML += "   D1_CF, D1_ITEM, D1_TES, D1_DTDIGIT, D1_QUANT, D1_VALDESC, "
		cDML += "   D1_TOTAL, D1_VALDESC, D1_VALIPI, D1_ICMSRET, D1_ICMSRET, "
		cDML += "   D1_VALIMP5, D1_VALIMP6, D1_VALINS, D1_VALICM, D1_VALIPI, "  
		cDML += "   D1_VALIMP6, D1_VALIMP5, D1_REMITO, D1_SERIREM, D1_ITEMREM, "
		cDML += "   D1_UM, SD1.R_E_C_N_O_ ID, "
		cDML += "   F2_DOC, F2_SERIE, F2_TRANSP TRANSP, F2_COND COND, F2_VEND1 VEND, F2_TXMOEDA, F2_MOEDA, F2_EMISSAO, "
	Else
		// Colocado para trazer todos os campos no MI, pois vários campos 
		// podem ser selecionados para realizar o cálculo dos impostos 
		cDML := "SELECT SD1.R_E_C_N_O_ ID, SD1.*, "
		cDML += "   F1_MOEDA, F1_TRANSP TRANSP, F1_COND COND, ' ' VEND, F1_EMISSAO, F1_TXMOEDA, "
	EndIf

	cDML += "   A1_REGIAO, A1_TIPO, A1_GRPVEN, A1_EST, A1_COD_MUN, A1_PAIS, "
	cDML += "   B1_TIPO, B1_GRUPO, ACV_CATEGO "
	cDML += "FROM " + RetSQLName("SD1") + " SD1 "

	If lBrasil
		cDML += "INNER JOIN " + RetSQLName("SF2") + " SF2 "
		cDML += "ON F2_FILIAL = '" + xFilial("SF2") + "' "
		cDML += "   AND F2_DOC = D1_NFORI "
		cDML += "   AND F2_SERIE = D1_SERIORI "

		//-------------------------------------------------------------------
		// Identifica se deve ignorar o cliente para relacionar o documento 
		// de saída com o documento de entrada do tipo devolução. 
		//-------------------------------------------------------------------	
		If ! ( lIgnoreClient )
			cDML += "   AND F2_CLIENTE = D1_FORNECE "
			cDML += "   AND F2_LOJA = D1_LOJA "
		EndIf 

		cDML += "   AND SF2.D_E_L_E_T_ = ' ' "	
	Else
		cDML += "INNER JOIN " + RetSQLName("SF1") + " SF1 "
		cDML += "ON F1_FILIAL = '" + xFilial("SF1") + "' "
		cDML += "   AND F1_DOC = D1_DOC "
		cDML += "   AND F1_SERIE = D1_SERIE "
		cDML += "   AND F1_FORNECE = D1_FORNECE "
		cDML += "   AND F1_LOJA = D1_LOJA "
		cDML += "   AND SF1.D_E_L_E_T_ = ' ' "
	EndIf
	
	cDML += "LEFT JOIN " + RetSQLName("SA1") + " SA1 "
	cDML += "	ON (A1_FILIAL = '" +	 xFilial("SA1") + "' AND SA1.A1_COD = SD1.D1_FORNECE "
	cDML += " 	AND SA1.A1_LOJA = SD1.D1_LOJA AND SA1.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("SB1") + " SB1 "
	cDML += "	ON (B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD "
	cDML += "	AND SB1.D_E_L_E_T_= ' ') "
	cDML += "LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cDML += "	ON (ACV_FILIAL = '" +	 xFilial("ACV") + "' AND ACV.ACV_CODPRO = SD1.D1_COD "
	cDML += "	AND ACV.D_E_L_E_T_ = ' ') "	

	cDML += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
	cDML += "   AND D1_DTDIGIT BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	
	//-------------------------------------------------------------------
	// No Mercado Internacional, podem existir devoluções sem ter os 
	// dados da nota fiscal original
	//-------------------------------------------------------------------
	If lBrasil
		cDML += "AND D1_NFORI <> ' ' "
	EndIf
	cDML += "AND D1_TIPO = 'D' "
	cDML += "AND SD1.D_E_L_E_T_ = ' '"
	
	cDML := ChangeQuery(cDML)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias(), .T., .T.)       	
	
	TcSetField( ::cFlow, "D1_DTDIGIT", "D", 8, 0 )
	If lBrasil
		TcSetField( ::cFlow, "F2_EMISSAO", "D", 8, 0 )
	Else
		TcSetField( ::cFlow, "F1_EMISSAO", "D", 8, 0 )
	EndIf
Return ::cFlow 