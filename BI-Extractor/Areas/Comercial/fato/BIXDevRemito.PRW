#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDEVREMITO.CH"

REGISTER EXTRACTOR HHB 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDevRemito
A tabela fato devolu��o de remito apresenta informa��es relacionadas �s
devolu��es de remito, como valores e quantidades devolvidas.

@author  Helio Leal
@since   08/05/2017
/*/
//-------------------------------------------------------------------
Class BIXDevRemito from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author Helio Leal  
@since   08/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXDevRemito
	_Super:New( FACT, "HHB", STR0001, "SD1", { COMERCIAL } ) //"Devolu��o de Remito"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author Helio Leal  
@since   08/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXDevRemito
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HHB_EMPRES"	,	"C",	32,	 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HHB_ESTABL"	,	"C",	32,	 00, .T., "HKK" ) //"Estabelecimento""
	oModel:AddField( "HHB_ROTA"		,	"C",	32,	 00, .T., "HGI") //"Rota"
	oModel:AddField( "HHB_CANALV"	,	"C",	32,	 00, .T., "HGA" ) //"Canal de Venda"
	oModel:AddField( "HHB_PRDUTO"	,	"C",	32,	 00, .T., "HJ3" ) //"Produto Comercial"
	oModel:AddField( "HHB_MICREG"	,	"C",	32,	 00, .T., "HGB" ) //"Microrregi�o"
	oModel:AddField( "HHB_GRPCLI"	,	"C",	32,	 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HHB_MOEDA"	,	"C",	32,	 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HHB_REFER"	,	"C",	32,	 00, .T., "HJH" ) //"Refer�ncia"
	oModel:AddField( "HHB_UNDNEG"	,	"C",	32,	 00, .T., "HJ1" ) //"Unidade de Neg�cio"
	oModel:AddField( "HHB_REGIAO"	,	"C",	32,	 00, .T., "HJB" ) //"Regi�o"
	oModel:AddField( "HHB_NATOPR"	,	"C",	32,	 00, .T., "HJ9" ) //"Natureza de Opera��o"
	oModel:AddField( "HHB_CFOP"		,	"C",	32,	 00, .T., "HG0" ) //"CFOP"
	oModel:AddField( "HHB_TRANSP"	,	"C",	32,	 00, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HHB_CONDPG"	,	"C",	32,	 00, .T., "HJA" ) //"Condi��o de Pagamento"
	oModel:AddField( "HHB_ITEM"		,	"C",	32,	 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HHB_FAMCOM"	,	"C",	32,	 00, .T., "HG1" ) //"Fam�lia Comercial"
	oModel:AddField( "HHB_FAMMAT"	,	"C",	32,	 00, .T., "HG2" ) //"Fam�lia Material"
	oModel:AddField( "HHB_GRPEST"	,	"C",	32,	 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HHB_REGCOM"	,	"C",	32,	 00, .T., "HGD" ) //"Regi�o Comercial"
	oModel:AddField( "HHB_REPRES"	,	"C",	32,	 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HHB_CLIENT"	,	"C",	32,	 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HHB_UNITEM"	,	"C",	32,	 00, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HHB_DATA"		, 	"D",	08,	 00, .F., "HK2" ) //"Per�odo"
	
	oModel:AddField( "HHB_SERDEV"	,	"C",	08,	 00 ) // S�rie do Documento Cliente
	oModel:AddField( "HHB_NUMDEV"	,	"C",	35,	 00 ) // N�mero do Documento Cliente
	oModel:AddField( "HHB_SEQDEV"	,	"C",	10,	 00 ) // N�mero do Item do Documento
	oModel:AddField( "HHB_SERNF"	,	"C",	08,	 00 ) // S�rie da Nota Fiscal
	oModel:AddField( "HHB_NUMNF"	,	"C",	35,	 00 ) // N�mero da Nota Fiscal
	oModel:AddField( "HHB_SEQNF"	, 	"C",	12,	 00 ) // N�mero do Item da Nota Fiscal
	oModel:AddField( "HHB_REMITO"	,	"C",	13,	 00 ) // N�mero Remito
	oModel:AddField( "HHB_SERREM"	,	"C",	03,	 00 ) // Serie do Remito
	oModel:AddField( "HHB_ITEREM"	,	"C",	04,	 00 ) // Item Remito
	                                                   
	oModel:AddField( "HHB_QDEVFC"	,	"N",	16,	 04 ) // Qtde Devolvida Fam�lia Comercial
	oModel:AddField( "HHB_QDEVIT"	,	"N",	16,	 04 ) // Qtde Devolvida Item
	oModel:AddField( "HHB_QDEVFM"	,	"N",	16,	 04 ) // Qtde Devolvida Familia Material
	oModel:AddField( "HHB_QDVREM"	,	"N",	16,	 04 ) // Qtde Devolvida Remito	
	oModel:AddField( "HHB_VDEVTO"	,	"N",	16,	 02 ) // Vl Devolu��o Total
	oModel:AddField( "HHB_VDESDV"	,	"N",	16,	 02 ) // Vl Desconto Devolu��o
	oModel:AddField( "HHB_VDEVLQ"	,	"N",	16,	 02 ) // Vl Devolu��o L�quida|
	oModel:AddField( "HHB_VDEVME"	,	"N",	16,	 02 ) // Vl Devolu��o Mercadoria
	oModel:AddField( "HHB_VCSTDV"	,	"N",	16,	 02 ) // Vl Custo Devolu��o
	oModel:AddField( "HHB_VCTCTB"	,	"N",	16,	 02 ) // Vl Custo Cont�bil

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
@param oSeeker, objeto, Objeto para valida��o de integridade referencial.

@author  Helio Leal
@since   08/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXDevRemito
	Local oRegion		:= Nil
	Local aMoeda 		:= {}
	Local lFee			:= .F.
	Local lBrasil	 	:= .T.
	Local cTipoDoc		:= "" 
	Local cMoedaCab		:= ""
	Local xDataCab		:= ""
	Local nMoeda		:= 0
	Local nFee			:= 0
	Local nVlrCusto 	:= 0
	Private cRetAlias		:= ''

	//-------------------------------------------------------------------
	// Recupera os par�metros da fato.
	//-------------------------------------------------------------------
	aMoeda		:= BIXGetMxF( ::cEntity )
	lFee 		:= BIXParInfo( "BIX_TXMOED"	, "L", .F. )
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
		If !IsRemito( 1, '(cRetAlias)->D1_TIPODOC')
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

		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customiza��o.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D1_DOC"		, (cRetAlias)->D1_DOC )
			oRecord:SetValue( "D1_SERIE"	, (cRetAlias)->D1_SERIE )
			oRecord:SetValue( "D1_FORNECE"	, (cRetAlias)->D1_FORNECE )
			oRecord:SetValue( "D1_LOJA"		, (cRetAlias)->D1_LOJA ) 
			oRecord:SetValue( "B1_ITEM"		, (cRetAlias)->D1_ITEM )
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
			oRecord:SetValue( "HHB_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HHB_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HHB_MICREG"	, oSeeker:Seek( "HGB", { (cRetAlias)->A1_REGIAO } ) )
			oRecord:SetValue( "HHB_GRPCLI"	, oSeeker:Seek( "HJ0", { (cRetAlias)->A1_GRPVEN } ) )
			oRecord:SetValue( "HHB_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HHB_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HHB_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( (cRetAlias)->A1_EST, (cRetAlias)->A1_COD_MUN, (cRetAlias)->A1_PAIS ) } ) )
			oRecord:SetValue( "HHB_NATOPR" 	, oSeeker:Seek( "HJ9", { (cRetAlias)->D1_TES } ))
			oRecord:SetValue( "HHB_CFOP" 	, oSeeker:Seek( "HG0", { (cRetAlias)->D1_CF } ))
			oRecord:SetValue( "HHB_TRANSP"	, oSeeker:Seek( "HJ2", { (cRetAlias)->TRANSP } ) )
			oRecord:SetValue( "HHB_CONDPG"	, oSeeker:Seek( "HJA", { (cRetAlias)->COND } ) )
			oRecord:SetValue( "HHB_ITEM"	, oSeeker:Seek( "HJ8", { (cRetAlias)->D1_COD } ) ) 	
			oRecord:SetValue( "HHB_FAMCOM" 	, oSeeker:Seek( "HG1", { (cRetAlias)->ACV_CATEGO } ) ) 	
			oRecord:SetValue( "HHB_FAMMAT"	, oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) ) 	
			oRecord:SetValue( "HHB_GRPEST"	, oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) ) 	
			oRecord:SetValue( "HHB_REGCOM"	, oSeeker:Seek( "HGD", { (cRetAlias)->A1_GRPVEN } ) )
			oRecord:SetValue( "HHB_REPRES"	, oSeeker:Seek( "HJC", { (cRetAlias)->VEND } ) )
			oRecord:SetValue( "HHB_CLIENT"	, oSeeker:Seek( "HJ7", { (cRetAlias)->D1_FORNECE, (cRetAlias)->D1_LOJA } ) )
			oRecord:SetValue( "HHB_UNITEM" 	, oSeeker:Seek( "HHW", { (cRetAlias)->D1_UM } ) )
			oRecord:SetValue( "HHB_ROTA"	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
			oRecord:SetValue( "HHB_CANALV" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HHB_PRDUTO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HHB_REFER" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HHB_DATA" 	, IIf(!Empty( (cRetAlias)->D1_DTDIGIT), (cRetAlias)->D1_DTDIGIT, DATE_EMPTY) )

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HHB_NUMDEV"	, (cRetAlias)->D1_DOC )			
			oRecord:SetValue( "HHB_NUMNF"	, (cRetAlias)->NOTA )
			oRecord:SetValue( "HHB_SEQDEV"	, (cRetAlias)->D1_ITEM ) 
			oRecord:SetValue( "HHB_SERDEV"	, SerieNFID(cRetAlias, 2, "D1_SERIE") )

			If lBrasil
				oRecord:SetValue( "HHB_SERNF"	, SerieNFID(cRetAlias, 2, "F2_SERIE") )
			Else
				oRecord:SetValue( "HHB_SERNF"	, SerieNFID(cRetAlias, 2, "F1_SERIE") ) // S�rie da Nota Fiscal
			EndIf 

			oRecord:SetValue( "HHB_SEQNF"	, (cRetAlias)->(D1_DOC + SerieNFID(cRetAlias, 2, "D1_SERIE")) )
			oRecord:SetValue( "HHB_REMITO"	, (cRetAlias)->D1_REMITO )
			oRecord:SetValue( "HHB_SERREM"	, SerieNFID(cRetAlias, 2, "D1_SERIREM") )
			oRecord:SetValue( "HHB_ITEREM"	, (cRetAlias)->D1_ITEMREM )

			//-------------------------------------------------------------------
			// Indicadores.
			//-------------------------------------------------------------------	
			oRecord:SetValue( "HHB_QDEVFC"	, 0 )
			oRecord:SetValue( "HHB_QDEVFM"	, 0 )
			oRecord:SetValue( "HHB_QDVREM"	, (cRetAlias)->D1_QUANT )
			oRecord:SetValue( "HHB_QDEVIT"	, (cRetAlias)->D1_QUANT )
			oRecord:SetValue( "HHB_VDESDV"	, BIXValue((cRetAlias)->(D1_TOTAL-D1_VALDESC),&cMoedaCab,cMoeda,&xDataCab, nFee) )
			oRecord:SetValue( "HHB_VDEVME"	, BIXValue((cRetAlias)->(D1_TOTAL-D1_VALDESC),&cMoedaCab,cMoeda,&xDataCab, nFee) )
			oRecord:SetValue( "HHB_VDEVTO"	, BIXValue((cRetAlias)->D1_TOTAL,&cMoedaCab,cMoeda,&xDataCab, nFee) )
			oRecord:SetValue( "HHB_VDEVLQ"	, BIXValue((cRetAlias)->D1_TOTAL,&cMoedaCab,cMoeda,&xDataCab, nFee) ) 

			If Val(cMoeda) == 1
				nVlrCusto := (cRetAlias)->D1_CUSTO
			Else
				nVlrCusto := &("(cRetAlias)->D1_CUSTO" + cMoeda)
			EndIf
			oRecord:SetValue( "HHB_VCTCTB"	, BIXValue(nVlrCusto,&cMoedaCab,cMoeda,&xDataCab, nFee) )

			If SB2->( MsSeek(xFilial("SB2") + (cRetAlias)->D1_COD + (cRetAlias)->D1_LOCAL) )
				oRecord:SetValue( "HHB_VCSTDV"	, (cRetAlias)->D1_QUANT * & ("SB2->B2_CM" + cMoeda) )
			EndIf

			oOutput:Send( oRecord )						
		Next nMoeda

		(cRetAlias)->( DBSkip() )
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------
	oOutput:Release()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma �nica tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Per�odo inicial de extra��o.
@param cTo, caracter, Per�odo final de extra��o.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restri��o na recupera��o de dados no formato {{campo, opera��o, valor}}. 
@return cRetAlias, Alias tempor�rio. 

@author  Helio Leal
@since   08/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXDevRemito
	Local cDML 	:= ""
	Local lBrasil	:= cPaisLoc == "BRA"

	If lBrasil
		cDML := "SELECT D1_DOC, D1_SERIE, D1_TIPODOC, D1_TIPO, D1_NFORI, "
		cDML += "   D1_SERIORI, D1_FORNECE, D1_LOJA, D1_COD, D1_LOCAL, D1_UM, "
		cDML += "   D1_CF, D1_ITEM, D1_TES, D1_DTDIGIT, D1_QUANT, D1_VALDESC, "
		cDML += "   D1_TOTAL, D1_VALDESC, D1_VALIPI, D1_ICMSRET, D1_ICMSRET, "
		cDML += "   D1_VALIMP5, D1_VALIMP6, D1_VALINS, D1_VALICM, D1_VALIPI, "  
		cDML += "   D1_VALPIS, D1_VALCOF, D1_REMITO, D1_SERIREM, D1_ITEMREM, "
		cDML += "   D1_CUSTO, D1_CUSTO2, D1_CUSTO3, D1_CUSTO4, D1_CUSTO5, SD1.R_E_C_N_O_ ID, "
		cDML += "   F2_DOC NOTA, F2_SERIE, F2_TRANSP TRANSP, F2_COND COND, "
		cDML += "   F2_VEND1 VEND, F2_MOEDA, F2_TXMOEDA, F2_EMISSAO, "
	Else
		//-------------------------------------------------------------------
		// Colocado para trazer todos os campos no MI, pois v�rios campos 
		// podem ser selecionados para realizar o c�lculo dos impostos 
		//-------------------------------------------------------------------
		cDML := "SELECT SD1.R_E_C_N_O_ ID, SD1.*, "
		cDML += "   F1_DOC NOTA, F1_SERIE, F1_TRANSP TRANSP, F1_COND COND, "
		cDML += "   ' ' VEND, F1_MOEDA, F1_EMISSAO, F1_TXMOEDA, "
	EndIf

	cDML += "   A1_REGIAO, A1_GRPVEN, A1_EST, A1_COD_MUN, A1_PAIS, "
	cDML += "   B1_TIPO, B1_GRUPO, ACV_CATEGO "
	cDML += "FROM " + RetSQLName("SD1") + " SD1 "
	
	If lBrasil
		cDML += "INNER JOIN " + RetSQLName("SF2") + " SF2 "
		cDML += "ON F2_FILIAL = '" + xFilial("SF2") + "' "
		cDML += "   AND F2_DOC = D1_NFORI "
		cDML += "   AND F2_SERIE = D1_SERIORI "
		cDML += "   AND F2_CLIENTE = D1_FORNECE "
		cDML += "   AND F2_LOJA = D1_LOJA "
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
	cDML += "	AND D1_DTDIGIT BETWEEN '" + cFrom + "' AND '" + cTo + "' "

	If lBrasil
		cDML += "AND D1_NFORI <> ' ' "
	Else
		//-------------------------------------------------------------------
		// No Mercado Internacional, podem existir devolu��es sem ter os 
		// dados da nota fiscal original, por este motivo a valida��o do 
		// registro deve ser ??_TIPO = D
		//-------------------------------------------------------------------
		cDML += "AND D1_TIPO = 'D' "
	EndIf

	cDML += "AND SD1.D_E_L_E_T_ = ' '"
	
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
	TcSetField( ::cFlow, "D1_DTDIGIT", "D", 8, 0 )

	If lBrasil
		TcSetField( ::cFlow, "F2_EMISSAO", "D", 8, 0 )
	Else
		TcSetField( ::cFlow, "F1_EMISSAO", "D", 8, 0 )
	EndIf
Return ::cFlow 