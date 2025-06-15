#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOMPCART.CH"

REGISTER EXTRACTOR HKQ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCompCart
Classe do extrator para a dimensão Compras Carteira do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   31/08/2010
/*/
//------------------------------------------------------------------- 
Class BIXCompCart from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()	
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   23/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCompCart
	_Super:New( FACT, "HKQ", STR0001, "SC7", { MATERIAIS } ) // "Compras Carteira" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   23/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCompCart
	Local oModel := BIXModel():Build( Self )
	
	oModel:AddField( "HKQ_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKQ_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKQ_FORNEC", "C", 32, 0, .T., "HKJ" )	
	oModel:AddField( "HKQ_TRANSP", "C", 32, 0, .T., "HJ2" )
	oModel:AddField( "HKQ_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKQ_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKQ_GRPEST", "C", 32, 0, .T., "HG3" ) 
	oModel:AddField( "HKQ_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKQ_CMPRDR", "C", 32, 0, .T., "HJZ" )
	oModel:AddField( "HKQ_CONDPG", "C", 32, 0, .T., "HJA" )	
	oModel:AddField( "HKQ_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKQ_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKQ_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HKQ_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKQ_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HKQ_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HKQ_SITCMP", "C", 32, 0, .T., "HQG" )	
	oModel:AddField( "HKQ_NATCMP", "C", 32, 0, .T., "HQH" )
	oModel:AddField( "HKQ_UNITEM", "C", 32, 0, .T., "HHW" ) 
	oModel:AddField( "HKQ_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKQ_ORDEM" , "C", 10, 0 )	
	oModel:AddField( "HKQ_PEDIDO", "C", 10, 0 )	
	oModel:AddField( "HKQ_EMERG" , "C", 1, 0 )	
	oModel:AddField( "HKQ_DTENTR", "D", 8, 0 )	
	oModel:AddField( "HKQ_DTPEDC", "D", 8, 0 )	
	oModel:AddField( "HKQ_DTEXTR", "D", 8, 0 )	
	oModel:AddField( "HKQ_DTEORD", "D", 8, 0 )	
	oModel:AddField( "HKQ_QDSATR", "N", 4, 0 )	
	oModel:AddField( "HKQ_NUMPRG", "N", 4, 0 )	
	oModel:AddField( "HKQ_QDSANT", "N", 4, 0 )	
	oModel:AddField( "HKQ_VCARTE", "N", 16, 2 )
	oModel:AddField( "HKQ_QCTFMT", "N", 16, 4 )
	oModel:AddField( "HKQ_QENTAT", "N", 16, 4 )
	oModel:AddField( "HKQ_QENTAN", "N", 16, 4 )
	oModel:AddField( "HKQ_QCARTE", "N", 16, 4 )
	
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

@author  Marcia Junko
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCompCart
	Local oRegion			:= NIL
	Local aMoedas	   		:= {}
	Local cMoeda	   		:= ""
	Local cFlow	   		:= ""
	Local dStartDate   	:= BIXInitRunning() 
	Local nInd         	:= 1
	Local nVlrTmp      	:= 0
	Local nDiasAtCart		:= 0
	Local nDiasAntCart	:= 0
	Local nTxMoeda	   	:= 0
	Local lTxMoeda		:= .F.
	Local dDataDigit   	:= SToD("")
	
	aMoedas	:= BIXGetMxF( ::cEntity )
	lTxMoeda	:= LoadTxMoeda() //Define a utilização da taxa negociada na conversão de moeda.
	oRegion	:= BIXRegiao():New()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While (cFlow)->(! EoF() )
		nTxMoeda := 0
		nDiasAtCart := 0
		nDiasAntCart := 0

		//-------------------------------------------------------------------
		// No Mercado internacional, as tabelas SC5, SC7, SF1, SF2, SE1, 
		// SE5 e SE2 utilizam o campo ??_TXMOEDA (TAXA NEGOCIADA) que define
		// a taxa usada para a operação, caso seja ZERO deve ser considerada 
		// a cotação da moeda para o dia.
		//-------------------------------------------------------------------				
		If cPaisLoc != "BRA" .Or. lTxMoeda
			nTxMoeda := (cFlow)->C7_TXMOEDA
		EndIf

		nVlrTmp := (cFlow)->( (C7_QUANT - C7_QUJE) * C7_PRECO )
		
		dDataDigit := BIXRetDtDgt( (cFlow)->C7_NUM , (cFlow)->C7_ITEM )
			
		For nInd := 1 To Len(aMoedas)
			cMoeda := aMoedas[nInd][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "C7_FILIAL" 	, (cFlow)->C7_FILIAL )
			oRecord:SetValue( "C7_NUM" 		, (cFlow)->C7_NUM )
			oRecord:SetValue( "C7_ITEM" 	, (cFlow)->C7_ITEM )
			oRecord:SetValue( "C7_SEQUEN" 	, (cFlow)->C7_SEQUEN )
			oRecord:SetValue( "A2_FILIAL" 	, (cFlow)->A2_FILIAL )
			oRecord:SetValue( "A2_COD" 		, (cFlow)->C7_FORNECE )
			oRecord:SetValue( "A2_LOJA" 	, (cFlow)->C7_LOJA )
			oRecord:SetValue( "A2_EST" 		, (cFlow)->A2_EST )
			oRecord:SetValue( "A2_COD_MUN" 	, (cFlow)->A2_COD_MUN )
			oRecord:SetValue( "A2_PAIS" 	, (cFlow)->A2_PAIS )
			oRecord:SetValue( "B1_FILIAL" 	, (cFlow)->B1_FILIAL )
			oRecord:SetValue( "B1_COD" 		, (cFlow)->C7_PRODUTO )
			oRecord:SetValue( "ACU_COD" 	, (cFlow)->ACV_CATEGO )
			oRecord:SetValue( "E4_FILIAL" 	, (cFlow)->E4_FILIAL )
			oRecord:SetValue( "E4_CODIGO" 	, (cFlow)->C7_COND )
			oRecord:SetValue( "CTT_FILIAL" 	, (cFlow)->CTT_FILIAL )
			oRecord:SetValue( "CTT_CUSTO" 	, (cFlow)->C7_CC )
			oRecord:SetValue( "Y1_FILIAL" 	, (cFlow)->Y1_FILIAL )
			oRecord:SetValue( "Y1_COD" 		, (cFlow)->C7_COMPRA )
			oRecord:SetValue( "BM_GRUPO"	, (cFlow)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cFlow)->C7_UM )
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKQ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKQ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKQ_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKQ_FORNEC", oSeeker:Seek( "HKJ", { (cFlow)->C7_FORNECE, (cFlow)->C7_LOJA } ) ) 
			oRecord:SetValue( "HKQ_GRPFOR", oSeeker:Seek( "HGE", { (cFlow)->A2_GRUPO } ) ) 
			oRecord:SetValue( "HKQ_SITCMP", oSeeker:Seek( "HQG", { (cFlow)->C7_TPOP } ) ) 
			oRecord:SetValue( "HKQ_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->C7_UM } ) ) 
			oRecord:SetValue( "HKQ_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) ) 
			oRecord:SetValue( "HKQ_FAMCOM", oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) ) 
			oRecord:SetValue( "HKQ_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HKQ_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->C7_PRODUTO } ) ) 
			oRecord:SetValue( "HKQ_CMPRDR", oSeeker:Seek( "HJZ", { (cFlow)->C7_COMPRA } ) ) 
			oRecord:SetValue( "HKQ_CONDPG", oSeeker:Seek( "HJA", { (cFlow)->C7_COND } ) ) 
			oRecord:SetValue( "HKQ_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A2_EST, (cFlow)->A2_COD_MUN, (cFlow)->A2_PAIS ) } ) ) 
			oRecord:SetValue( "HKQ_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HKQ_CCUSTO", oSeeker:Seek( "HJ5", { (cFlow)->C7_CC } ) ) 
			oRecord:SetValue( "HKQ_TRANSP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKQ_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKQ_NATCMP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKQ_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKQ_DTEXTR"	, dToday  )
			
			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HKQ_ORDEM" , (cFlow)->C7_NUMSC )
			oRecord:SetValue( "HKQ_PEDIDO", (cFlow)->C7_NUM )
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKQ_DTENTR", IIf( !Empty( (cFlow)->C7_DATPRF), (cFlow)->C7_DATPRF, DATE_EMPTY ) )
			oRecord:SetValue( "HKQ_DTPEDC", IIf( !Empty( (cFlow)->C7_EMISSAO), (cFlow)->C7_EMISSAO, DATE_EMPTY) )
			oRecord:SetValue( "HKQ_QCARTE", (cFlow)->(C7_QUANT - C7_QUJE ) )
			oRecord:SetValue( "HKQ_DTEORD", DATE_EMPTY )
			oRecord:SetValue( "HKQ_NUMPRG", 0 )
			oRecord:SetValue( "HKQ_QCTFMT", 0 )

			oRecord:SetValue( "HKQ_VCARTE", BIXValue( nVlrTmp, (cFlow)->C7_MOEDA, cMoeda, (cFlow)->C7_EMISSAO, nTxMoeda) )
			
			If !Empty ((cFlow)->C7_DATPRF) .And. !Empty(dStartDate)
				If (cFlow)->C7_DATPRF > dStartDate
					nDiasAtCart := 0
				Else
					nDiasAtCart := (dStartDate - (cFlow)->C7_DATPRF)
				EndIf
			EndIf
			oRecord:SetValue( "HKQ_QDSATR", nDiasAtCart )

			If nDiasAtCart > 0
				oRecord:SetValue( "HKQ_QENTAT", 1 )
			Else
				oRecord:SetValue( "HKQ_QENTAT", 0 )
			EndIf

			If dDataDigit < (cFlow)->C7_DATPRF
				nDiasAntCart := BIXVldValor((cFlow)->C7_DATPRF , dDataDigit , 3) 
			Else
				nDiasAntCart := 0
			EndIf
			oRecord:SetValue( "HKQ_QDSANT", nDiasAntCart)
			
			If nDiasAntCart > 0
				oRecord:SetValue( "HKQ_QENTAN", 1 )
			Else
				oRecord:SetValue( "HKQ_QENTAN", 0 )
			EndIf

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nInd
		
		(cFlow)->( dbSkip() )
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
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCompCart
	Local nInterval	 := BIXParInfo( "BIX_CRTCOM", "N", 2 )
	Local cBeginDate := ""  
	Local cQuery	 := ""

	//-------------------------------------------------------------------
	// Define o período em que a carteira de qualidade será considerada.  
	//-------------------------------------------------------------------	
	cBeginDate	:= DToS( SToD( cFrom ) - ( nBIVal( nInterval ) * ( 30 ) ) )
      
	cQuery := " SELECT C7_FILIAL, C7_EMISSAO, C7_QUANT, C7_QUJE, C7_RESIDUO, C7_NUM, C7_TXMOEDA, "
	cQuery += "		C7_PRODUTO, C7_FORNECE, C7_LOJA, C7_ITEM, C7_TPOP, C7_NUMSC, C7_DATPRF, C7_PRECO, "
	cQuery += "		C7_MOEDA, C7_COND, C7_CC, C7_COMPRA, C7_UM, C7_SEQUEN, SC7.R_E_C_N_O_,  "
	cQuery += "		B1_FILIAL, B1_TIPO, B1_GRUPO, ACV_FILIAL, ACV_CATEGO, A2_FILIAL, A2_EST, A2_COD_MUN, "
	cQuery += "		A2_PAIS, A2_GRUPO, D1_DTDIGIT, E4_FILIAL, CTT_FILIAL, Y1_FILIAL "
	cQuery += " FROM " + RetSQLName("SC7") + " SC7 "
	cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "   AND B1_COD  = C7_PRODUTO "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cQuery += "	ON ACV_FILIAL = '" + xFilial("ACV") + "' "
	cQuery += "   AND ACV_CODPRO = C7_PRODUTO "
	cQuery += "   AND ACV.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("SA2") + " SA2 "
	cQuery += " ON A2_FILIAL = '" +	xFilial("SA2") + "' "
	cQuery += "	  AND A2_COD =  C7_FORNECE "
	cQuery += "   AND A2_LOJA = C7_LOJA "
	cQuery += "	  AND SA2.D_E_L_E_T_ = ' ' "	
	cQuery += " LEFT JOIN " + RetSQLName("SE4") + " SE4 "
	cQuery += " ON E4_FILIAL = '" +	xFilial("SE4") + "' "
	cQuery += "	  AND E4_CODIGO =  C7_COND "
	cQuery += "	  AND SE4.D_E_L_E_T_ = ' ' "	
	cQuery += " LEFT JOIN " + RetSQLName("CTT") + " CTT "
	cQuery += " ON CTT_FILIAL = '" + xFilial("CTT") + "' "
	cQuery += "	  AND CTT_CUSTO =  C7_CC "
	cQuery += "	  AND CTT.D_E_L_E_T_ = ' ' "	
	cQuery += " LEFT JOIN " + RetSQLName("SY1") + " SY1 "
	cQuery += " ON Y1_FILIAL = '" + xFilial("SY1") + "' "
	cQuery += "	  AND Y1_COD =  C7_COMPRA "
	cQuery += "	  AND SY1.D_E_L_E_T_ = ' ' "	
	cQuery += " LEFT JOIN " + RetSqlName("SD1") + " SD1 "
	cQuery += " ON D1_FILIAL = '" + xFilial("SD1") + "' "
	cQuery += "   AND D1_PEDIDO = C7_NUM "
	cQuery += "   AND D1_ITEMPC = C7_ITEM "
	cQuery += "   AND D1_COD = C7_PRODUTO "
	cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += "		AND C7_EMISSAO BETWEEN '" + cBeginDate + "' AND '" + cTo + "' " 
	cQuery += " 	AND C7_RESIDUO <> 'S' "
	cQuery += "		AND (C7_QUANT - C7_QUJE > 0) "
	cQuery += "		AND SC7.D_E_L_E_T_ = ' ' "

	
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ::cFlow := GetNextAlias() , .T., .F.)

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "C7_DATPRF"	, "D", 8, 0 )  
	TcSetField( ::cFlow, "C7_EMISSAO"	, "D", 8, 0 )
	TcSetField( ::cFlow, "D1_DTDIGIT"	, "D", 8, 0 )
Return ::cFlow

// Retornar a data de digitação do pedido de compras
Function BIXRetDtDgt( cPedido , cItemPC )
   Local cFilter    := ""
   Local dDataDigit := SToD("")
   Local aArea      := {}

	aArea := GetArea()

	  	SD1->( dbSetOrder(6) ) // D1_FILIAL+DTOS(D1_DTDIGIT)+D1_NUMSEQ

	 	cFilter := " D1_PEDIDO = '" + cPedido + "' "
	 	cFilter += " .AND. D1_ITEMPC = '" + cItemPC + "' "
	 	cFilter += " .AND. D1_FILIAL == '" + xFilial("SD1") + "' "

		SD1->( DBSetFilter ( {|| &cFilter}, cFilter) )
		SD1->( dbGoTop() )

		dDataDigit := SD1->D1_DTDIGIT

	RestArea(aArea)
	SD1->( DBClearFilter() )
Return dDataDigit