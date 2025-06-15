#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREALPRODUCAO.CH"

REGISTER EXTRACTOR HKW

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRealProducao
Classe do extrator para a tabela fato Produção - Realizada Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXRealProducao from BIXEntity
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
@since   28/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXRealProducao
	_Super:New( FACT, "HKW", STR0001, "SD3", { PRODUCAO } ) //"Produção - Realizada"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   28/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXRealProducao
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKW_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKW_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKW_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKW_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKW_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKW_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKW_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKW_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HKW_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HKW_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HKW_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKW_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKW_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HKW_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HKW_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HKW_TIPPRD", "C", 32, 0, .T., "HQU" )
	oModel:AddField( "HKW_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKW_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKW_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKW_ORDEM" , "C", 13, 0 )
	oModel:AddField( "HKW_PEDIDO", "C", 12, 0 )
	oModel:AddField( "HKW_SEQCIA", "C", 10, 0 )
	oModel:AddField( "HKW_PRIORI", "C", 10, 0 )
	oModel:AddField( "HKW_QRELET", "N", 4, 0 )
	oModel:AddField( "HKW_QPRODU", "N", 16, 4 )
	oModel:AddField( "HKW_QREFUG", "N", 16, 4 )
	oModel:AddField( "HKW_QPRFMT", "N", 16, 4 )
	oModel:AddField( "HKW_QREFMT", "N", 16, 4 )
	oModel:AddField( "HKW_QPRFCM", "N", 16, 4 )
	oModel:AddField( "HKW_QREFCM", "N", 16, 4 )
	oModel:AddField( "HKW_VCSPRD", "N", 16, 2 )
	oModel:AddField( "HKW_VCSMAT", "N", 16, 2 )
	oModel:AddField( "HKW_VCSMOB", "N", 16, 2 )
	oModel:AddField( "HKW_VCSGGF", "N", 16, 2 )
	oModel:AddField( "HKW_QORDPD", "N", 16, 4 )
	oModel:AddField( "HKW_VCSRFG", "N", 16, 2 )

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
@since   28/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXRealProducao
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local lFindACV := .F.
	Local lFindSA1 := .F.
	Local lFindSC2 := .F.
	Local cTipITM  := ""
	Local cMoeda     := ""
	Local nMoeda     := 1
	Local nVCSMOB := 0
	Local nVCSMAT := 0

	Private cRetAlias := ""
	Private cAuxAlias := getNextAlias()  

	aMoedas := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()
	
	dbSelectArea("SA1")
	SA1->( dbSetOrder(1) ) // A1_FILIAL + A1_COD + A1_LOJA

	DbSelectArea("SC5")	
	SC5->( dbSetOrder(1) ) // Filial + C5_NUM
    
	DbSelectArea("ACV")
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cRetAlias := ::Flow( cFrom, cTo )
	
	While (cRetAlias)->(! Eof() )
		lFindACV := .F.
		lFindSA1 := .F.
		lFindSC2 := .F.
		cTipITM	 := ""
		nVCSMOB := 0
		nVCSMAT := 0
					
		//-------------------------------------------------------------------
		// Verifica a integridade referencial das dimensões.  
		//-------------------------------------------------------------------
		IF ACV->(MsSeek( xFilial("ACV") + (cRetAlias)->C2_PRODUTO) )
			lFindACV := .T.
		EndIf

		If SC5->(MsSeek( xFilial("SC5") + (cRetAlias)->C2_PEDIDO ) ) 
			If SA1->(MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
				lFindSA1 := .T.
			EndIf
		EndIf 	
		
		If !Empty((cRetAlias)->C2_LOCAL)
			lFindSC2 := .T.
		EndIf 

		If !Empty((cRetAlias)->G1_COD)
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
			oRecord:SetValue( "D3_OP"     , (cRetAlias)->D3_OP )
			oRecord:SetValue( "D3_COD"     , (cRetAlias)->D3_COD )
						
			oRecord:SetValue( "ACU_COD"    , ACV->ACV_CATEGO )			
			oRecord:SetValue( "A1_COD"     , SC5->C5_CLIENTE )
			oRecord:SetValue( "A1_LOJA"    , SC5->C5_LOJACLI )
			oRecord:SetValue( "B1_COD"     , (cRetAlias)->D3_COD )
			oRecord:SetValue( "BM_GRUPO"   , (cRetAlias)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"  , (cRetAlias)->D3_UM )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKW_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKW_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKW_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKW_FAMMAT", oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) ) 
			oRecord:SetValue( "HKW_GRPEST", oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HKW_ITEM"  , oSeeker:Seek( "HJ8", { (cRetAlias)->D3_COD } ) ) 
			oRecord:SetValue( "HKW_DEPOSI", oSeeker:Seek( "HJD", { (cRetAlias)->C2_LOCAL } ) ) 
			oRecord:SetValue( "HKW_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HKW_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
			oRecord:SetValue( "HKW_UNITEM", oSeeker:Seek( "HHW", { (cRetAlias)->D3_UM } ) )
			oRecord:SetValue( "HKW_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			oRecord:SetValue( "HKW_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			oRecord:SetValue( "HKW_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )	

			If lFindACV
				oRecord:SetValue( "HKW_FAMCOM", oSeeker:Seek( "HG1", { (cRetAlias)->ACV_CATEGO } ) ) 
			Else
				oRecord:SetValue( "HKW_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf
			
			If lFindSA1
				oRecord:SetValue( "HKW_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
				oRecord:SetValue( "HKW_CLIENT", oSeeker:Seek( "HJ7", { SC5->C5_CLIENTE, SC5->C5_LOJACLI} ) )
				oRecord:SetValue( "HKW_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) ) 
			Else
				oRecord:SetValue( "HKW_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKW_CLIENT", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKW_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf

			If (cRetAlias)->C2_TPOP == "F" .Or. (cRetAlias)->C2_TPOP == "P"
				oRecord:SetValue( "HKW_TIPPRD", oSeeker:Seek( "HQU", { (cRetAlias)->C2_TPOP } ) ) 
			Else
				oRecord:SetValue( "HKW_TIPPRD", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf
			
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKW_PRIORI", (cRetAlias)->C2_PRIOR )                                // Prioridade da Ordem
			oRecord:SetValue( "HKW_SEQCIA", (cRetAlias)->C2_SEQUEN )                               // Sequência da Ordem
			oRecord:SetValue( "HKW_PEDIDO", (cRetAlias)->C2_PEDIDO )                               // Número do Pedido
			oRecord:SetValue( "HKW_ORDEM", (cRetAlias)->( C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD ) )  // Numero da Ordem

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKW_DATA", 	(cRetAlias)->D3_EMISSAO )               // Data de Movimento do Item da Ordem
			oRecord:SetValue( "HKW_QPRODU", (cRetAlias)->D3_QUANT   )               // Qtde Produzida
			oRecord:SetValue( "HKW_QREFUG", (cRetAlias)->D3_PERDA   )               // Qtde Refugada
			oRecord:SetValue( "HKW_QRELET", BIXVldValor((cRetAlias)->C2_DATRF, (cRetAlias)->C2_EMISSAO, 3) ) // Real Lead Time
			oRecord:SetValue( "HKW_VCSPRD", Round( &("(cRetAlias)->D3_CUSTO" + cMoeda), 2) )	// Vl Custo Produção

		 	BIXSubFlow( cAuxAlias, (cRetAlias)->D3_OP )	
			
			While (cAuxAlias)->( !Eof() ) 
				If IsProdMod((cAuxAlias)->D3_COD)
					nVCSMOB += Round( &("(cAuxAlias)->D3_CUSTO" + cMoeda), 2) // Vl Custo MOB Produção
				Else                     
					nVCSMAT += Round( &("(cAuxAlias)->D3_CUSTO" + cMoeda), 2) // Vl Custo Material Produção
				EndIf
				(cAuxAlias)->( dbSkip() )
			EndDo
			(cAuxAlias)->(DbCloseArea())

			oRecord:SetValue( "HKW_VCSMOB", Round( nVCSMOB, 2) )		// Qtde Refugada UN FC
			oRecord:SetValue( "HKW_VCSMAT", Round( nVCSMAT, 2) )       // Vl Custo GGF Produção

            // Vl Custo Produção Refugada
			If ((cRetAlias)->D3_QUANT + (cRetAlias)->D3_PERDA) > 0
				oRecord:SetValue( "HKW_VCSRFG", Round( (&("(cRetAlias)->D3_CUSTO" + cMoeda) / ((cRetAlias)->D3_QUANT+(cRetAlias)->D3_PERDA)) * (cRetAlias)->D3_PERDA, 2) )
			Else
				oRecord:SetValue( "HKW_VCSRFG", 0 )
			EndIf

			oRecord:SetValue( "HKW_QORDPD", 1 )         // Qtde Ordem Produzida
			oRecord:SetValue( "HKW_QPRFMT", 0 )         // Qtde Produzida UN FM
			oRecord:SetValue( "HKW_QREFMT", 0 )         // Qtde Refugada UN FM      
			oRecord:SetValue( "HKW_QPRFCM", 0 )         // Qtde Produzida UN FC     
			oRecord:SetValue( "HKW_QREFCM", 0 )         // Qtde Refugada UN FC
			oRecord:SetValue( "HKW_VCSGGF", 0 )			// Vl Custo GGF Produção

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
	
	(cRetAlias)->(DbCloseArea())
Return NIL

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
@since   28/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXRealProducao
	Local cQuery 	:= ""

	cQuery := "SELECT D3_OP, D3_COD, D3_EMISSAO, D3_QUANT, D3_PERDA, D3_CUSTO1, D3_CUSTO2, " + ;
			"D3_CUSTO3, D3_CUSTO4, D3_CUSTO5, D3_CF, D3_UM, SD3.R_E_C_N_O_ ID, " + ;
			"C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, C2_DATRF, C2_EMISSAO, C2_LOCAL, " + ;
			"C2_PRODUTO, C2_PEDIDO, C2_TPOP, C2_PRIOR, C2_SEQUEN, " + ;  
			"B1_COD, B1_TIPO, B1_GRUPO, ACV_CATEGO,  " + ;
			"(SELECT MAX(G1_COD) " + ;
				"FROM " + RetSqlName("SG1")+ " SG1 " + ;			
				"WHERE G1_FILIAL = '" + xFilial("SG1") + "' " + ; 
				"AND G1_COD = D3_COD " + ;
				"AND SG1.D_E_L_E_T_ = ' ') G1_COD " + ;
			"FROM " + RetSqlName("SD3")+ " SD3 " + ;
			"INNER JOIN " + RetSqlName("SC2") + " SC2 " + ;
			"ON C2_FILIAL = '" + xFilial("SC2") + "' " + ;
				"AND C2_NUM || C2_ITEM || C2_SEQUEN || C2_ITEMGRD = D3_OP " + ;
				"AND C2_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' " + ;
				"AND SC2.D_E_L_E_T_= ' ' " + ;
			"INNER JOIN " + RetSqlName("SB1") + " SB1 " + ;
			"ON B1_FILIAL = '" + xFilial("SB1") + "' " + ;
				"AND B1_COD = D3_COD " + ;
				"AND SB1.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN " + RetSQLName("ACV") + " ACV " + ;
			"	ON (ACV_FILIAL = '" +	 xFilial("ACV") + "' AND ACV_CODPRO = C2_PRODUTO " + ;
			"   AND ACV.D_E_L_E_T_ = ' ') " + ;
			"WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + ;
				"AND D3_ESTORNO <> 'S' " + ;
				"AND D3_CF IN ('PR0', 'PR1') " + ;
				"AND SD3.D_E_L_E_T_ = ' ' " + ;
			"ORDER BY D3_FILIAL, D3_OP, D3_COD, D3_LOCAL"
		
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)
			
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cRetAlias := GetNextAlias(), .T., .T.)       	
	
	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( cRetAlias, "D3_EMISSAO", "D", 8, 0 )
	TcSetField( cRetAlias, "C2_EMISSAO", "D", 8, 0 ) 	 		
	TcSetField( cRetAlias, "C2_DATRF", "D", 8, 0 )
Return cRetAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSubFlow
Criação da query do fluxo auxiliar

@param cAuxAlias, String, Alias utilizado pela query
@param cNumOP, String, Número da OP a ser pesquisada 

@author  Marcia Junko
@version P12
@since   04/08/2015
/*/
//-------------------------------------------------------------------
Static Function BIXSubFlow( cAuxAlias, cNumOP )
	Local cQuery 	:= ""
	Local cSubstr   := If("SQL" $ TCGetDB(),"SUBSTRING","SUBSTR")	

	cQuery := "SELECT D3_COD, SUM(D3_CUSTO1) D3_CUSTO1, SUM(D3_CUSTO2) D3_CUSTO2, SUM(D3_CUSTO3) D3_CUSTO3, " + ;
				"SUM(D3_CUSTO4) D3_CUSTO4, SUM(D3_CUSTO5) D3_CUSTO5 " + ;
			"FROM " + RetSqlName("SD3")+ " SD3 " + ;
			"WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + ;
				"AND D3_OP = '" + cNumOP + "' " + ;
				"AND " + cSubstr + "(D3_CF, 1,2) = 'RE' " + ;
				"AND SD3.D_E_L_E_T_ = ' ' " + ;
			"GROUP BY D3_COD"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAuxAlias, .T., .T.)       	

Return NIL

