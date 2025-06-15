#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOMPRAS.CH"

REGISTER EXTRACTOR HKO

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCompras
Classe do extrator para a fato Compras do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   31/08/2010
/*/
//-------------------------------------------------------------------
Class BIXCompras from BIXEntity
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
Method New() Class BIXCompras
	_Super:New( FACT, "HKO", STR0001, "SC7", { MATERIAIS } ) // "Compras" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   23/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCompras
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKO_FORNEC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HKO_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKO_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKO_TRANSP", "C", 32, 0, .T., "HJ2" )
	oModel:AddField( "HKO_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKO_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKO_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKO_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKO_CMPRDR", "C", 32, 0, .T., "HJZ" )
	oModel:AddField( "HKO_CONDPG", "C", 32, 0, .T., "HJA" )	
	oModel:AddField( "HKO_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKO_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKO_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HKO_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKO_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HKO_SITCMP", "C", 32, 0, .T., "HQG" )
	oModel:AddField( "HKO_NATCMP", "C", 32, 0, .T., "HQH" )
	oModel:AddField( "HKO_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HKO_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKO_UNITEM", "C", 32, 0, .T., "HHW" ) 
	oModel:AddField( "HKO_EMERG" , "C", 1, 0 )
	oModel:AddField( "HKO_ORDEM" , "C", 10, 0 )
	oModel:AddField( "HKO_PEDIDO", "C", 10, 0 )
	oModel:AddField( "HKO_DATA"  , "D", 8, 0 )
	oModel:AddField( "HKO_DTENTR", "D", 8, 0 )
	oModel:AddField( "HKO_DTEORD", "D", 8, 0 )
	oModel:AddField( "HKO_NUMPRG", "N", 4, 0 )
	oModel:AddField( "HKO_QORDCP", "N", 16, 4 )
	oModel:AddField( "HKO_QCOMPR", "N", 16, 4 )
	oModel:AddField( "HKO_QCPMAT", "N", 16, 4 )
	oModel:AddField( "HKO_VCOMPR", "N", 16, 2 )
	oModel:AddField( "HKO_VIPICP", "N", 16, 2 )
	oModel:AddField( "HKO_VICMCP", "N", 16, 2 )
	oModel:AddField( "HKO_VIPINC", "N", 16, 2 )
	oModel:AddField( "HKO_VIPNIN", "N", 16, 2 )

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
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCompras
	Local oRegion	:= NIL
	Local aMoedas 	 := {}
	Local cMoeda  	 := ""   
	Local nInd    	 := 1
	Local lBra	  	 := cPaisLoc == "BRA"	// Define se a instalação do Protheus é "Brasil"
	Local aImpInf 	 := {}					// Vetor com as informações dos impostos
	Local nI		 := 0
	Local nTotVIPINC := 0					// Valor Total dos Impostos Incidentes
	Local nTotVIPNIN := 0					// Valor Total dos Impostos Não Incidentes
	Local cCampo	 := ""
	Local cFlow		 := ""
	Local nTxMoeda	 := 0
	Local lTxMoeda	 := LoadTxMoeda() //Define a utilização da taxa negociada na conversão de moeda.

	ChkFile("SC1") 
	SC1->( dbSetOrder(1) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD                                                                                                                       
	
	aMoedas := BIXGetMxF( ::cEntity )
	oRegion := BIXRegiao():New()
	lTxMoeda := LoadTxMoeda() 

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 
	
   	While (cFlow)->(! EoF() )
		nTxMoeda := 0

		//-------------------------------------------------------------------
		// No Mercado internacional, as tabelas SC5, SC7, SF1, SF2, SE1, 
		// SE5 e SE2 utilizam o campo ??_TXMOEDA (TAXA NEGOCIADA) que define
		// a taxa usada para a operação, caso seja ZERO deve ser considerada 
		// a cotação da moeda para o dia.
		//-------------------------------------------------------------------				
		If cPaisLoc != "BRA" .Or. lTxMoeda
			nTxMoeda := (cFlow)->C7_TXMOEDA
		EndIf

		// Calcula o Valor Total dos Impostos
		nTotVIPINC := 0
		nTotVIPNIN := 0
		If !lBra
			aImpInf := TesImpInf((cFlow)->C7_TES)

			For nI := 1 to Len (aImpInf)
				cCampo := aImpInf[nI][02]
				
				//Renomeia os campos, para pegar a referência da tabela SC7
				cCampo := StrTran(cCampo, 'D1_', 'C7_')
				cCampo := StrTran(cCampo, 'D2_', 'C7_')
				
				If (cFlow)->(FieldPos(cCampo)) > 0
					If aImpInf[nI][3] == "1" //Incidentes
						nTotVIPINC += (cFlow)->(FieldGet(FieldPos(cCampo)))
					Else // Nao Incidentes
						nTotVIPNIN += (cFlow)->(FieldGet(FieldPos(cCampo)))
					EndIf
				EndIf
			Next
		EndIf

		For nInd := 1 To Len(aMoedas)
			cMoeda := aMoedas[nInd][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "C7_NUM" 		, (cFlow)->C7_NUM )
			oRecord:SetValue( "C7_ITEM" 	, (cFlow)->C7_ITEM )
			oRecord:SetValue( "C7_SEQUEN"	, (cFlow)->C7_SEQUEN )
			
			oRecord:SetValue( "A2_COD" 		, (cFlow)->C7_FORNECE )
			oRecord:SetValue( "A2_LOJA" 	, (cFlow)->C7_LOJA )
			oRecord:SetValue( "B1_COD" 		, (cFlow)->C7_PRODUTO )
			oRecord:SetValue( "ACU_COD" 	, (cFlow)->ACV_CATEGO )
			oRecord:SetValue( "E4_CODIGO" 	, (cFlow)->C7_COND )
			oRecord:SetValue( "CTT_CUSTO" 	, (cFlow)->C7_CC )
			oRecord:SetValue( "Y1_COD" 		, (cFlow)->C7_COMPRA )
			oRecord:SetValue( "AH_UNIMED" 	, (cFlow)->C7_UM )
			oRecord:SetValue( "BM_GRUPO" 	, (cFlow)->B1_GRUPO )
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKO_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKO_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKO_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HKO_FORNEC", oSeeker:Seek( "HKJ", { (cFlow)->C7_FORNECE, (cFlow)->C7_LOJA } ) ) 
			oRecord:SetValue( "HKO_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) )
			oRecord:SetValue( "HKO_FAMCOM", oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) )
			oRecord:SetValue( "HKO_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HKO_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->C7_PRODUTO } ) )
			oRecord:SetValue( "HKO_CMPRDR", oSeeker:Seek( "HJZ", { (cFlow)->C7_COMPRA } ) )
			oRecord:SetValue( "HKO_CONDPG", oSeeker:Seek( "HJA", { (cFlow)->C7_COND } ) ) 
			oRecord:SetValue( "HKO_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A2_EST, (cFlow)->A2_COD_MUN, (cFlow)->A2_PAIS ) } ) ) 
			oRecord:SetValue( "HKO_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HKO_CCUSTO", oSeeker:Seek( "HJ5", { (cFlow)->C7_CC } ) ) 
			oRecord:SetValue( "HKO_GRPFOR", oSeeker:Seek( "HGE", { (cFlow)->A2_GRUPO } ) )
			oRecord:SetValue( "HKO_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->C7_UM } ) ) 
			oRecord:SetValue( "HKO_TRANSP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKO_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKO_NATCMP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKO_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )

			oRecord:SetValue( "HKO_SITCMP", oSeeker:Seek( "HQG", { (cFlow)->C7_TPOP } ) )
			If (cFlow)->C7_QUJE > 0 .And. (cFlow)->C7_QUJE < (cFlow)->C7_QUANT
				oRecord:SetValue( "HKO_SITCMP", oSeeker:Seek( "HQG", { "R" } ) )
			ElseIf (cFlow)->C7_QUJE >= (cFlow)->C7_QUANT                           
				oRecord:SetValue( "HKO_SITCMP", oSeeker:Seek( "HQG", { "I" } ) )
			EndIf
			
			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HKO_ORDEM", (cFlow)->C7_NUMSC )
			oRecord:SetValue( "HKO_PEDIDO", (cFlow)->C7_NUM )
			oRecord:SetValue( "HKO_NUMPRG", 0 )
			oRecord:SetValue( "HKO_EMERG", " " )
			oRecord:SetValue( "HKO_DATA", IIf(!Empty((cFlow)->C7_EMISSAO), (cFlow)->C7_EMISSAO, DATE_EMPTY) )
			oRecord:SetValue( "HKO_DTENTR", IIf(!Empty((cFlow)->C7_DATPRF), (cFlow)->C7_DATPRF, DATE_EMPTY) )
			
			// Data de Emissao da Ordem
			oRecord:SetValue( "HKO_DTEORD", DATE_EMPTY )				
			If SC1->(dbSeek(xFilial("SC1") + (cFlow)->C7_NUMSC + (cFlow)->C7_ITEMSC))
				oRecord:SetValue( "HKO_DTEORD", IIf(!Empty(SC1->C1_EMISSAO), SC1->C1_EMISSAO, DATE_EMPTY) )
			EndIf	
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKO_QORDCP", 1 )
			oRecord:SetValue( "HKO_QCPMAT", 0 )

			If lBra
				oRecord:SetValue( "HKO_VIPICP", BIXValue((cFlow)->C7_VALIPI , (cFlow)->C7_MOEDA, cMoeda, (cFlow)->C7_EMISSAO, nTxMoeda) )
				oRecord:SetValue( "HKO_VICMCP", BIXValue((cFlow)->C7_VALICM , (cFlow)->C7_MOEDA, cMoeda, (cFlow)->C7_EMISSAO, nTxMoeda) )
				oRecord:SetValue( "HKO_VIPINC", 0 )
				oRecord:SetValue( "HKO_VIPNIN", 0 )
			Else
				oRecord:SetValue( "HKO_VIPICP", 0 )
				oRecord:SetValue( "HKO_VICMCP", 0 )
				oRecord:SetValue( "HKO_VIPINC", BIXValue(nTotVIPINC, (cFlow)->C7_MOEDA, cMoeda, (cFlow)->C7_EMISSAO, nTxMoeda) )
				oRecord:SetValue( "HKO_VIPNIN", BIXValue(nTotVIPNIN, (cFlow)->C7_MOEDA, cMoeda, (cFlow)->C7_EMISSAO, nTxMoeda) )
			EndIf

			If (cFlow)->C7_RESIDUO == 'S'
				oRecord:SetValue( "HKO_QCOMPR", (cFlow)->C7_QUJE )
				oRecord:SetValue( "HKO_VCOMPR", BIXValue((cFlow)->(C7_QUJE * C7_PRECO), (cFlow)->C7_MOEDA, cMoeda, (cFlow)->C7_EMISSAO, nTxMoeda) )
			Else
				oRecord:SetValue( "HKO_QCOMPR", (cFlow)->C7_QUANT )
				oRecord:SetValue( "HKO_VCOMPR", BIXValue((cFlow)->C7_TOTAL, (cFlow)->C7_MOEDA, cMoeda, (cFlow)->C7_EMISSAO, nTxMoeda) )
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCompras
	Local cQuery 	:= ""
	Local lBra		:= cPaisLoc == "BRA"	// Define se a instalação do Protheus é "Brasil"
	
	If lBra
		cQuery := "SELECT C7_NUM, C7_ITEM, C7_SEQUEN, C7_TXMOEDA, C7_FORNECE, C7_LOJA, C7_PRODUTO, C7_UM, C7_TES, C7_TPOP, C7_QUJE, " + ;
			"C7_QUANT, C7_NUMSC, C7_EMISSAO, C7_DATPRF, C7_VALIPI, C7_MOEDA, C7_EMISSAO, C7_VALICM, " + ;
			"C7_PRECO, C7_TOTAL, C7_ITEMSC, C7_COND, C7_CC, C7_COMPRA, C7_RESIDUO, SC7.R_E_C_N_O_ ID, "
	Else
		cQuery := "SELECT SC7.R_E_C_N_O_ ID, SC7.*, " 
	EndIf
	cQuery += " ACV_FILIAL, ACV_CATEGO, A2_FILIAL, A2_GRUPO, A2_EST, A2_COD_MUN, A2_PAIS, "
	cQuery += " B1_FILIAL, B1_TIPO, B1_GRUPO, E4_FILIAL, CTT_FILIAL, Y1_FILIAL "
	cQuery += " FROM " + RetSqlName("SC7") + " SC7 " 
	cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "   AND B1_COD  = C7_PRODUTO "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
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
	cQuery += " LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cQuery += "	ON ACV_FILIAL = '" + xFilial("ACV") + "' "
	cQuery += "   AND ACV_CODPRO = C7_PRODUTO "
	cQuery += "   AND ACV.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += "		AND C7_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	cQuery += "		AND (C7_RESIDUO <> 'S' OR C7_QUJE > 0 ) " 
	cQuery += "		AND SC7.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  		
	cQuery := ChangeQuery( cQuery )
	
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//------------------------------------------------------------------- 	
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), ::cFlow := GetNextAlias(), .T., .T.)       	
	
	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "C7_EMISSAO", "D", 8, 0 ) 		
	TcSetField( ::cFlow, "C7_DATPRF",  "D", 8, 0 )
	TcSetField( ::cFlow, "C7_EMISSAO", "D", 8, 0 )
	
Return ::cFlow 