#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCARTMATPRMA.CH"

REGISTER EXTRACTOR HLZ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCartMatPrma
Classe do extrator para a tabela fato Matéria-Prima - Prevista Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXCartMatPrma from BIXEntity
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCartMatPrma
	_Super:New( FACT, "HLZ", STR0001, "SD4", { PRODUCAO } ) //"Matéria-Prima - Carteira"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCartMatPrma
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLZ_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLZ_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLZ_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLZ_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLZ_ITMPAI", "C", 32, 0, .T., "HJ8" ) 
	oModel:AddField( "HLZ_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLZ_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLZ_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLZ_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLZ_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HLZ_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLZ_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLZ_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLZ_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLZ_OPERA" , "C", 32, 0, .T., "HQC" )
	oModel:AddField( "HLZ_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLZ_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLZ_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLZ_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLZ_DTEXTR", "D", 8, 0 )		
	oModel:AddField( "HLZ_DTEMIS", "D", 8, 0 )		
	oModel:AddField( "HLZ_DTTERM", "D", 8, 0 )		
	oModel:AddField( "HLZ_PEDIDO", "C", 12, 0 )		
	oModel:AddField( "HLZ_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLZ_ORDEM" , "C", 13, 0 )		
	oModel:AddField( "HLZ_TIPSOB", "C", 30, 0 )		
	oModel:AddField( "HLZ_QCARTE", "N", 16, 4 )	
	oModel:AddField( "HLZ_QCRFMT", "N", 16, 4 )	
	oModel:AddField( "HLZ_QCRFCM", "N", 16, 4 )	
	oModel:AddField( "HLZ_VCRTMP", "N", 16, 2 )	

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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCartMatPrma
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local cMoeda    := ""	
	Local nMoeda    := 1
	Local cGRPCLI   := ""
	Local cTipITM	:= ""

	Private cRetAlias := ""

	aMoedas  := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cRetAlias := ::Flow( cFrom, cTo )

	While (cRetAlias)->(! EoF() )
		cGRPCLI	:= ""
		cTipITM := ""
				
		// Considera apenas produtos que não são Mão de Obra	
		If IsProdMod((cRetAlias)->D4_COD)
			(cRetAlias)->( dbSkip() )
			Loop
		EndIf		

		If !Empty( (cRetAlias)->G1_COD )
			If (cRetAlias)->B1_TIPO == "MP"
				cTipITM := "3" // Matéria Prima
			Else
				cTipITM := "2" // Fabricado
			EndIf
		Else                                  	
			cTipITM := "1" // Comprado
		EndIf
		
		For nMoeda := 1 To Len(aMoedas)
			cMoeda := aMoedas[nMoeda][1]
		
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D4_COD"		, (cRetAlias)->D4_COD )
			oRecord:SetValue( "D4_OP"		, (cRetAlias)->D4_OP )
			
			oRecord:SetValue( "ACU_COD"		, (cRetAlias)->ACV_CATEGO )
			oRecord:SetValue( "A1_COD"		, (cRetAlias)->C5_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cRetAlias)->C5_LOJACLI )
			oRecord:SetValue( "B1_COD"		, (cRetAlias)->D4_COD )
			oRecord:SetValue( "BM_GRUPO"	, (cRetAlias)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cRetAlias)->B1_UM )
			oRecord:SetValue( "G2_PRODUTO"	, (cRetAlias)->H6_PRODUTO )
			oRecord:SetValue( "G2_OPERAC"	, (cRetAlias)->H6_OPERAC )
			oRecord:SetValue( "G2_CODIGO"	, (cRetAlias)->G2_CODIGO )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLZ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HLZ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HLZ_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HLZ_ITEM"  , oSeeker:Seek( "HJ8", { (cRetAlias)->D4_COD } ) ) 
			oRecord:SetValue( "HLZ_ITMPAI", oSeeker:Seek( "HJ8", { (cRetAlias)->C2_PRODUTO } ) ) 
			oRecord:SetValue( "HLZ_FAMMAT", oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) ) 
			oRecord:SetValue( "HLZ_FAMCOM", oSeeker:Seek( "HG1", { (cRetAlias)->ACV_CATEGO } ) )
			oRecord:SetValue( "HLZ_GRPEST", oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HLZ_DEPOSI", oSeeker:Seek( "HJD", { (cRetAlias)->C2_LOCAL } ) ) 
			oRecord:SetValue( "HLZ_CLIENT", oSeeker:Seek( "HJ7", { (cRetAlias)->C5_CLIENTE, (cRetAlias)->C5_LOJACLI } ) )
			oRecord:SetValue( "HLZ_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cRetAlias)->A1_EST, (cRetAlias)->A1_COD_MUN, (cRetAlias)->A1_PAIS ) } ) ) 
			oRecord:SetValue( "HLZ_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HLZ_GRPCLI", oSeeker:Seek( "HJ0", { (cRetAlias)->A1_TIPO } ) )
			oRecord:SetValue( "HLZ_OPERA" , oSeeker:Seek( "HQC", { (cRetAlias)->H6_PRODUTO, (cRetAlias)->H6_OPERAC, (cRetAlias)->G2_CODIGO } ) )
			oRecord:SetValue( "HLZ_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
			oRecord:SetValue( "HLZ_UNITEM", oSeeker:Seek( "HHW", { (cRetAlias)->B1_UM } ) ) 
			oRecord:SetValue( "HLZ_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLZ_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLZ_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			
					
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			
			oRecord:SetValue( "HLZ_SEQCIA", (cRetAlias)->C2_SEQUEN ) 	// Sequência da Ordem 
			oRecord:SetValue( "HLZ_PEDIDO", (cRetAlias)->C2_PEDIDO ) 	// Atributo Número do Pedido
			oRecord:SetValue( "HLZ_TIPSOB", " " )      					// Tipo de Sobra (Não tem conceito para SD4.)
			oRecord:SetValue( "HLZ_ORDEM" , (cRetAlias)->D4_OP )      	// Ordem de Produção 

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLZ_DTEMIS", (cRetAlias)->C2_EMISSAO ) // Data de Emissão da Ordem
			oRecord:SetValue( "HLZ_DTTERM", (cRetAlias)->C2_DATPRF  ) // Data de Término da Ordem   
			oRecord:SetValue( "HLZ_QCARTE", (cRetAlias)->D4_QUANT )  // Qtde Carteira
			oRecord:SetValue( "HLZ_VCRTMP", (cRetAlias)->D4_QUANT * & ("(cRetAlias)->B2_CM" + cMoeda) ) // Indicador Vl Carteira Matéria Prima
			oRecord:SetValue( "HLZ_QCRFMT", 0 )       // Qtde Carteira UN FM
			oRecord:SetValue( "HLZ_QCRFCM", 0 )       // Qtde Carteira UN FC

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda
			
		(cRetAlias)->( dbSkip() ) 
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	

	(cRetAlias)->( DBCloseArea() )
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
@since   24/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCartMatPrma
	Local cQuery		:= ""
	Local cBeginDate	:= ""
	Local cConcat		:= If ( "MSSQL" $ TCGetDB(), "+", "||" ) 

	//-------------------------------------------------------------------
	// Define a partir de qual período a matéria prima será considerada.  
	//-------------------------------------------------------------------	
	cBeginDate	:= BIXIniDate(cFrom, "BIX_CARTMP")

	cQuery := "SELECT D4_COD, D4_OP, D4_QUANT, SD4.R_E_C_N_O_ ID, " + ;
		"C2_PEDIDO, C2_PRODUTO, C2_LOCAL, C2_SEQUEN, C2_EMISSAO, C2_DATPRF, "+ ; 
		"B1_COD, B1_TIPO, B1_GRUPO, B1_LOCPAD, B1_UM, " + ;
		"ACV_CATEGO, C5_CLIENTE, C5_LOJACLI, A1_EST, A1_COD_MUN, A1_PAIS, A1_TIPO, " + ;
		"H6_PRODUTO, H6_OPERAC, G1_COD, G2_CODIGO, " + ;
		"B2_CM1, B2_CM2, B2_CM3, B2_CM4, B2_CM5 " + ;
		"FROM " + RetSQLName("SD4") + " SD4 " + ;
		"INNER JOIN " + RetSQLName("SB1") + " SB1 " + ;
		"ON B1_FILIAL = '" + xFilial("SB1") + "' " + ;
			"AND B1_COD = D4_COD " + ;
			"AND SB1.D_E_L_E_T_= ' ' " + ;
		"INNER JOIN " + RetSQLName("SC2") + " SC2 " + ;
		"ON C2_FILIAL = '" + xFilial("SC2") + "' " + ;
			"AND C2_NUM " + cConcat + " C2_ITEM " + cConcat + " C2_SEQUEN " + cConcat + " C2_ITEMGRD = D4_OP " + ;
			"AND C2_EMISSAO >= '" + cBeginDate + "' " + ;
			"AND C2_EMISSAO <= '" + cTo + "' " + ;
			"AND C2_QUJE > 0 " + ;
			"AND C2_QUANT <> C2_QUJE " + ; 
			"AND C2_DATRF = ' ' " + ;
			"AND SC2.D_E_L_E_T_= ' ' " + ;
		"LEFT JOIN " + RetSqlName("SC5") + " SC5 " + ;
		"ON SC5.C5_FILIAL = '" + xFilial("SC5") + "' " + ;
			"AND SC5.C5_NUM = SC2.C2_PEDIDO " + ;
			"AND SC5.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN " + RetSqlName("SA1") + " SA1 " + ;
		"ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + ;
			"AND SA1.A1_COD = SC5.C5_CLIENTE " + ;
			"AND SA1.A1_LOJA = SC5.C5_LOJACLI " + ;
			"AND SA1.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN " + RetSqlName("ACV") + " ACV " + ;
		"ON ACV.ACV_FILIAL = '" + xFilial("ACV") + "' " + ;
			"AND ACV.ACV_CODPRO = SC2.C2_PRODUTO " + ;
			"AND ACV.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN " + RetSqlName("SH6") + " SH6 " + ;
		"ON SH6.H6_FILIAL = '" + xFilial("SH6") + "' " + ;
			"AND SH6.H6_OP = SD4.D4_OP " + ;
			"AND SH6.H6_PRODUTO = SD4.D4_COD " + ;
			"AND SH6.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN " + RetSqlName("SG1") + " SG1 " + ;
		"ON SG1.G1_FILIAL = '" + xFilial("SG1") + "' " + ;
			"AND SG1.G1_COD = SB1.B1_COD " + ;
			"AND SG1.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN " + RetSqlName("SG2") + " SG2 " + ;
		"ON SG2.G2_FILIAL = '" + xFilial("SG2") + "' " + ;
			"AND SG2.G2_PRODUTO = SH6.H6_PRODUTO " + ;
			"AND SG2.G2_OPERAC = SH6.H6_OPERAC " + ;
			"AND SG2.D_E_L_E_T_ = ' ' " + ;
		"LEFT JOIN " + RetSqlName("SB2") + " SB2 " + ;
		"ON SB2.B2_FILIAL = '" + xFilial("SB2") + "' " + ;
			"AND SB2.B2_COD = SD4.D4_COD " + ;
			"AND SB2.B2_LOCAL = SB1.B1_LOCPAD " + ;
			"AND SB2.D_E_L_E_T_ = ' ' " + ;
		"WHERE D4_FILIAL = '" + xFilial("SD4") + "' " + ;
			"AND D4_QUANT <> 0 " + ;
			"AND SD4.D_E_L_E_T_ = ' ' " + ;
		"ORDER BY D4_FILIAL, D4_COD, D4_OP"

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)
	
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRetAlias := GetNextAlias(), .T., .F.)

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( cRetAlias, "C2_EMISSAO", "D", 8, 0 )  
	TcSetField( cRetAlias, "C2_DATPRF", "D", 8, 0 )
Return cRetAlias