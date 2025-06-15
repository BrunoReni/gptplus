#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCARTPRODUCAO.CH"

REGISTER EXTRACTOR HLY

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCartProducao
Classe do extrator para a tabela fato Produção - Carteira Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXCartProducao from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
endClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCartProducao
	_Super:New( FACT, "HLY", STR0001, "SC2", { PRODUCAO } ) //"Produção - Carteira"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCartProducao
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLY_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLY_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLY_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLY_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLY_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLY_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLY_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLY_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLY_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HLY_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLY_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLY_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLY_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLY_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLY_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLY_TIPPRD", "C", 32, 0, .T., "HQU" )
	oModel:AddField( "HLY_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLY_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLY_DTEXTR", "D", 8, 0 )
	oModel:AddField( "HLY_DTEMIS", "D", 8, 0 )
	oModel:AddField( "HLY_DTTERM", "D", 8, 0 )
	oModel:AddField( "HLY_ORDEM" , "C", 13, 0 )		
	oModel:AddField( "HLY_PEDIDO", "C", 12, 0 )		
	oModel:AddField( "HLY_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLY_PRIORI", "C", 10, 0 )
	oModel:AddField( "HLY_QCARTE", "N", 16, 4 )
	oModel:AddField( "HLY_QCTFCM", "N", 16, 4 )
	oModel:AddField( "HLY_QCTFMT", "N", 16, 4 )
	oModel:AddField( "HLY_QCTODP", "N", 16, 4 )
	oModel:AddField( "HLY_VCTPRD", "N", 16, 2 )
	oModel:AddField( "HLY_VCTMOB", "N", 16, 2 )
	oModel:AddField( "HLY_VCTGGF", "N", 16, 2 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCartProducao
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local cMoeda    := ""
	Local nMoeda    := 1  
	Local cGRPCLI   := ""
	Local cC2OP		:= ""
	Local cTipITM	:= ""
	Local cLocPad	:= ""
	Local cOperPad	:= ""
	Local cFlow		:= ""
	Local nVCTMOB 	:= 0
	Local nVCTPRD 	:= 0
	
	
	aMoedas := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()

	DbSelectArea("SB2")
	SB2->( dbSetOrder(1) )

	DbSelectArea("SB3")
	SB3->( dbSetOrder(1) )
	
	DbSelectArea("SD4")
	SD4->( dbSetOrder(2) )
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo )
	
	While (cFlow)->(! Eof() )
		cLocPad := ""
   		nVCTMOB := 0
		nVCTPRD := 0
		cGRPCLI := ""
		cOperPad := ""
		cC2OP 	:= (cFlow)->( C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD )

		If !Empty( (cFlow)->G1_COD )
			If (cFlow)->B1_TIPO == "MP"
				cTipITM := "3" // Matéria Prima
			Else
				cTipITM := "2" // Fabricado
			EndIf
		Else                                  	
			cTipITM := "1" // Comprado
		EndIf

		If !Empty((cFlow)->C2_ROTEIRO)
			cOperPad := (cFlow)->C2_ROTEIRO
		Else
			cOperPad := (cFlow)->B1_OPERPAD
		EndIf
		
		
		For nMoeda := 1 To Len(aMoedas)
			cLocPad := ""
			nVCTMOB := 0
			nVCTPRD := 0
   		
			cMoeda := aMoedas[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "C2_NUM"		, (cFlow)->C2_NUM )
			oRecord:SetValue( "C2_ITEM"		, (cFlow)->C2_ITEM )
			oRecord:SetValue( "C2_SEQUEN"	, (cFlow)->C2_SEQUEN )
			
			oRecord:SetValue( "ACU_COD"		, (cFlow)->ACV_CATEGO )
			oRecord:SetValue( "A1_COD"		, (cFlow)->C5_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->C5_LOJACLI )
			oRecord:SetValue( "B1_COD"		, (cFlow)->C2_PRODUTO )
			oRecord:SetValue( "BM_GRUPO"	, (cFlow)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cFlow)->C2_UM )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLY_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HLY_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HLY_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HLY_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) ) 
			oRecord:SetValue( "HLY_FAMCOM", oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) ) 
			oRecord:SetValue( "HLY_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HLY_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->C2_PRODUTO } ) ) 
			oRecord:SetValue( "HLY_GRPCLI", oSeeker:Seek( "HJ0", { (cFlow)->A1_TIPO } ) )
			oRecord:SetValue( "HLY_DEPOSI", oSeeker:Seek( "HJD", { (cFlow)->C2_LOCAL } ) ) 
			oRecord:SetValue( "HLY_CLIENT", oSeeker:Seek( "HJ7", { (cFlow)->C5_CLIENTE, (cFlow)->C5_LOJACLI } ) )
			oRecord:SetValue( "HLY_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A1_EST, (cFlow)->A1_COD_MUN, (cFlow)->A1_PAIS ) } ) ) 
			oRecord:SetValue( "HLY_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HLY_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
			oRecord:SetValue( "HLY_TIPPRD", oSeeker:Seek( "HQU", { (cFlow)->C2_TPOP } ) ) 
			oRecord:SetValue( "HLY_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->C2_UM } ) ) 
			oRecord:SetValue( "HLY_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLY_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLY_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLY_PRIORI", (cFlow)->C2_PRIOR ) 	// Prioridade da Ordem
			oRecord:SetValue( "HLY_SEQCIA", (cFlow)->C2_SEQUEN )	// Sequência da Ordem
			oRecord:SetValue( "HLY_PEDIDO", (cFlow)->C2_PEDIDO )	// Atributo Número do Pedido
			oRecord:SetValue( "HLY_DTEMIS", (cFlow)->C2_EMISSAO )   // Data de Emissão da Ordem
			oRecord:SetValue( "HLY_DTTERM", (cFlow)->C2_DATPRF  )   // Data de Término da Ordem

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			If SD4->( MsSeek( xFilial("SD4") + cC2OP ) )
				While SD4->( !Eof() ) .And. SD4->D4_OP == cC2OP .And. SD4->D4_FILIAL == xFilial("SD4")
					cLocPad  := Posicione("SB1", 1, xFilial("SB1") + SD4->D4_COD, "B1_LOCPAD")
					
					If SB2->( dbSeek( xFilial("SB2") + SD4->D4_COD + cLocPad))
						If IsProdMod(SD4->D4_COD)
							nVCTMOB += ( SD4->D4_QUANT * &("SB2->B2_CM" + cMoeda))
							
							// Desconsidera valor de mão de obra? ja utilizado no processo
							If SD3->( MsSeek( xFilial("SD3") +  cC2OP) )
								While SD3->( !Eof() ) .And. SD3->D3_OP == cC2OP .And. SD3->D3_FILIAL == xFilial("SD3")
									If !Empty(SD3->D3_IDENT) .And. SD3->D3_COD == SD4->D4_COD
										nVCTMOB -= &("SD3->D3_CUSTO" + cMoeda)
									EndIf
								
									SD3->(dbSkip()) 
								EndDo
							EndIf
						Else
							nVCTPRD += (SD4->D4_QUANT * &("SB2->B2_CM" + cMoeda))
						EndIf
					EndIf
					SD4->( dbSkip() )
				EndDo
			EndIf  
			
			nVCTMOB += RetCostRoteiro( 1, (cFlow)->C2_PRODUTO, If(Empty(cOperPad), "01", cOperPad), cMoeda)[1]

			oRecord:SetValue( "HLY_VCTMOB", nVCTMOB )
			oRecord:SetValue( "HLY_VCTPRD", nVCTPRD )
			oRecord:SetValue( "HLY_QCARTE", (cFlow)->C2_QUANT - (cFlow)->C2_QUJE )	// Qtde Carteira
			oRecord:SetValue( "HLY_QCTODP", 1 ) // Qtde Ordens Produção Carteira
			oRecord:SetValue( "HLY_QCTFCM", 0 ) // Qtde Carteira UN FC
			oRecord:SetValue( "HLY_QCTFMT", 0 ) // Qtde Carteira UN FM
			oRecord:SetValue( "HLY_VCTGGF", 0 ) // Vl Carteira GGF Produção
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda
		(cFlow)->( dbSkip() )   
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCartProducao
	Local cQuery		:= ""
	Local cBeginDate	:= ""

	//-------------------------------------------------------------------
	// Define a partir de qual período a matéria prima será considerada.  
	//-------------------------------------------------------------------	
	cBeginDate	:= BIXIniDate(cFrom, "BIX_CARTPR")

	cQuery := "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, C2_LOCAL, " + ;
			"C2_PRODUTO, C2_PEDIDO, C2_TPOP, C2_PRIOR, C2_EMISSAO, C2_UM, " + ;
			"C2_DATPRF, C2_QUANT, C2_QUJE, C2_ROTEIRO,  SC2.R_E_C_N_O_ ID, " + ; 
			"B1_COD, B1_TIPO, B1_GRUPO, B1_OPERPAD, G1_COD, " + ;
			"ACV_CATEGO, C5_CLIENTE, C5_LOJACLI, A1_EST, A1_COD_MUN, A1_PAIS, A1_TIPO " + ;
			"FROM " + RetSqlName("SC2") + " SC2 " + ;
			"INNER JOIN " + RetSqlName("SB1") + " SB1 " + ;
				"ON B1_FILIAL = '" + xFilial("SB1") + "' " + ;
				"AND B1_COD = C2_PRODUTO " + ;
				"AND SB1.D_E_L_E_T_ = ' ' " + ;
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
			"LEFT JOIN " + RetSqlName("SG1") + " SG1 " + ;
			"ON SG1.G1_FILIAL = '" + xFilial("SG1") + "' " + ;
				"AND SG1.G1_COD = SB1.B1_COD " + ;
				"AND SG1.D_E_L_E_T_ = ' ' " + ;
			"WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + ;
				"AND C2_EMISSAO >= '" + cBeginDate + "' " + ;
				"AND C2_EMISSAO <= '" + cTo + "' " + ;
				"AND C2_QUJE > 0 " + ;
				"AND C2_QUANT <> C2_QUJE " + ; 
				"AND C2_DATRF = ' ' " + ;
				"AND SC2.D_E_L_E_T_ = ' ' " + ;
				"ORDER BY C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_ITEMGRD"

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)
	
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ::cFlow := GetNextAlias(), .T., .F.)

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "C2_EMISSAO", "D", 8, 0 )  
	TcSetField( ::cFlow, "C2_DATPRF" , "D", 8, 0 )
Return ::cFlow
