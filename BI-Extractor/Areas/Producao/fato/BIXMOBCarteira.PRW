#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOBCARTEIRA.CH"

REGISTER EXTRACTOR HKZ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMOBCarteira
Classe do extrator para a tabela fato Mão de Obra Carteira Extrator TOTVS B.I.

@author  BI TEAM
@version P11 
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXMOBCarteira from BIXEntity
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
@since   26/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXMOBCarteira
	_Super:New( FACT, "HKZ", STR0001, "SC2", { PRODUCAO } ) //"Mão-de-Obra-Carteira"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXMOBCarteira
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKZ_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKZ_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKZ_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKZ_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKZ_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKZ_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKZ_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKZ_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HKZ_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HKZ_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HKZ_GRPMAQ", "C", 32, 0, .T., "HJY" )
	oModel:AddField( "HKZ_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HKZ_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKZ_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKZ_DTEXTR", "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKZ_DTEMIS", "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKZ_DTTERM", "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKZ_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HKZ_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HKZ_LINHAP", "C", 32, 0, .T., "HGZ" )
	oModel:AddField( "HKZ_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKZ_MOBDIR", "C", 32, 0, .T., "HGH" )
	oModel:AddField( "HKZ_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKZ_PEDIDO", "C", 12, 0 )
	oModel:AddField( "HKZ_SEQCIA", "C", 10, 0 )
	oModel:AddField( "HKZ_ORDEM" , "C", 13, 0 )
	oModel:AddField( "HKZ_QHRMOC", "N", 16, 4 )
	oModel:AddField( "HKZ_VCSMOC", "N", 16, 2 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXMOBCarteira
	Local oRegion  := NIL
	Local aMoedas  := {}
	Local cFlow    := ""
	Local cMoeda   := ""	
	Local cNumOp   := ""
	Local nMoeda   := 1
	Local lFindSA1 := .F.
	Local lFindACV := .F.
	Local cTipITM  := ""
	Local cOperPad := ""
	Local nVCSMOC  := 0
	Local nQHRMOC  := 0

	aMoedas := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("SC5")
	SC5->( dbSetOrder(1) ) // Filial + C5_NUM

	DbSelectArea("SA1")
	SA1->( dbSetOrder(1) )
	
	DbSelectArea("ACV")	
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO
	
	DbSelectArea("SD4")
	SD4->( dbSetOrder(2) ) // Filial + ...
   
	DbSelectArea("SB1")	
	SB1->( dbSetOrder(1) ) // Filial + B1_COD

	DbSelectArea("SG1")
	SG1->( dbSetOrder(1) ) // Filial + G1_COD + G1_COMP + G1_TRT

	DbSelectArea("SB2")
	SB2->( dbSetOrder(1) )

	DbSelectArea("SD3")
	SD3->( dbSetOrder(1) )

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo )

	While (cFlow)->(! EoF() )
		lFindSA1 := .F.
		lFindACV := .F.
		cTipITM := ""
		cOperPad := ""
		nVCSMOC := 0
		nQHRMOC := 0

		cNumOp 	:= ((cFlow)->C2_NUM + (cFlow)->C2_ITEM + (cFlow)->C2_SEQUEN + (cFlow)->C2_ITEMGRD)	
		
		//-------------------------------------------------------------------
		// Verifica a integridade referencial das dimensões.  
		//------------------------------------------------------------------- 
		If SC5->( MsSeek( xFilial("SC5") + (cFlow)->C2_PEDIDO ) )
			If SA1->( MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
				lFindSA1 := .T.
			EndIf
		EndIf				

		If ACV->( MsSeek( xFilial("ACV") + (cFlow)->C2_PRODUTO ) )
			lFindACV := .T.
		EndIf
		
		If SG1->( MsSeek( xFilial("SG1") + (cFlow)->B1_COD) )
			If (cFlow)->B1_TIPO == "MP"
				cTipITM := "3" // Matéria Prima
			Else
				cTipITM := "2" // Fabricado
			EndIf
		Else                                  	
			cTipITM := "1" // Comprado
		EndIf
	
		// Determina o roteiro para o cálculo
		If !Empty((cFlow)->C2_ROTEIRO)
			cOperPad := (cFlow)->C2_ROTEIRO
		Else
			cOperPad := Posicione("SB1", 1, xFilial("SB1") + (cFlow)->C2_PRODUTO, "B1_OPERPAD")
		EndIf			
		
		For nMoeda := 1 To Len(aMoedas)
			nVCSMOC := 0
			nQHRMOC := 0
			
			cMoeda := aMoedas[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "C2_NUM"  , (cFlow)->C2_NUM )
			oRecord:SetValue( "C2_ITEM"  , (cFlow)->C2_ITEM )
			oRecord:SetValue( "C2_SEQUEN"  , (cFlow)->C2_SEQUEN )
			
			oRecord:SetValue( "CTT_CUSTO"  , (cFlow)->C2_CC )
			oRecord:SetValue( "ACU_COD"    , ACV->ACV_CATEGO )			
			oRecord:SetValue( "A1_COD"     , SC5->C5_CLIENTE )
			oRecord:SetValue( "A1_LOJA"    , SC5->C5_LOJACLI )
			oRecord:SetValue( "B1_COD"     , (cFlow)->C2_PRODUTO )
			oRecord:SetValue( "BM_GRUPO"   , (cFlow)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"  , (cFlow)->C2_UM )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKZ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKZ_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKZ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKZ_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) ) 
			oRecord:SetValue( "HKZ_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HKZ_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->C2_PRODUTO } ) ) 
			oRecord:SetValue( "HKZ_CCUSTO", oSeeker:Seek( "HJ5", { (cFlow)->C2_CC } ) ) 
			oRecord:SetValue( "HKZ_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HKZ_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
			oRecord:SetValue( "HKZ_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->C2_UM } ) ) 

			If lFindSA1
				oRecord:SetValue( "HKZ_CLIENT", oSeeker:Seek( "HJ7", { SC5->C5_CLIENTE, SC5->C5_LOJACLI} ) )
				oRecord:SetValue( "HKZ_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
				oRecord:SetValue( "HKZ_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) )
			Else
				oRecord:SetValue( "HKZ_CLIENT", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKZ_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKZ_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf
			
			If lFindACV
				oRecord:SetValue( "HKZ_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
			Else
				oRecord:SetValue( "HKZ_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf
			
			oRecord:SetValue( "HKZ_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKZ_GRPMAQ", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKZ_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKZ_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKZ_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKZ_MOBDIR", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKZ_DTEXTR"	, dToday  ) 

			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKZ_SEQCIA", (cFlow)->C2_SEQUEN ) // Sequência da Ordem 
			oRecord:SetValue( "HKZ_PEDIDO", (cFlow)->C2_PEDIDO ) // Atributo Número do Pedido
			oRecord:SetValue( "HKZ_ORDEM ", cNumOp )        	 // Ordem de Produção 

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKZ_DTEMIS", (cFlow)->C2_EMISSAO ) // Data da Emissão da Ordem 
			oRecord:SetValue( "HKZ_DTTERM", (cFlow)->C2_DATPRF  ) // Data de Término da Ordem
			
			SD4->(MsSeek(xFilial("SD4") + cNumOp))
			While SD4->(!EoF()) .And. SD4->D4_FILIAL == (cFlow)->C2_FILIAL .And. SD4->D4_OP == cNumOp					
				If !IsProdMod(SD4->D4_COD) .And. SD4->D4_QUANT != 0
					SD4->( dbSkip() )
					Loop
				EndIf 

				If SB2->( dbSeek( xFilial("SB2") + SD4->D4_COD + (cFlow)->B1_LOCPAD ) ) .And. SB1->( dbSeek( xFilial("SB1") + SD4->D4_COD ) )
					nVCSMOC += SD4->D4_QUANT * & ("SB2->B2_CM" + cMoeda) // Vl Custo MOB Carteira
					nQHRMOC += SD4->D4_QUANT                             // Qtde Horas MOB Carteira
					
					// Desconsidera valor de mão de obra e horas ja utilizados no processo
					If SD3->( MsSeek( xFilial("SD3") +  SD4->D4_OP) )
						While SD3->( !Eof() ) .And. SD3->D3_OP == SD4->D4_OP .And. SD3->D3_FILIAL == xFilial("SD3")
							If !Empty(SD3->D3_IDENT) .And. SD3->D3_COD == SD4->D4_COD
								nVCSMOC -= &("SD3->D3_CUSTO" + cMoeda) // Vl Custo MOB Carteira
								nQHRMOC -= SD3->D3_QUANT               // Qtde Horas MOB Carteira
							EndIf
							SD3->(dbSkip()) 
						EndDo
					EndIf					
				EndIf
				SD4->( dbSkip() ) 
			EndDo
			
			nVCSMOC += RetCostRoteiro(1, (cFlow)->C2_PRODUTO, If(Empty(cOperPad), "01", cOperPad), cMoeda)[1] // Vl Custo MOB Carteira
			nQHRMOC += RetCostRoteiro(1, (cFlow)->C2_PRODUTO, If(Empty(cOperPad), "01", cOperPad), cMoeda)[2] // Qtde Horas MOB Carteira									

			oRecord:SetValue( "HKZ_VCSMOC", nVCSMOC )	// Vl Custo MOB Carteira
			oRecord:SetValue( "HKZ_QHRMOC", nQHRMOC ) 	// Qtde Horas MOB Carteira									
			
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

	(cFlow)->(DbCloseArea())	
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
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXMOBCarteira
	Local cQuery		:= ""
	Local cBeginDate	:= ""

	//-------------------------------------------------------------------
	// Define a partir de qual período a mão de obra será considerada.  
	//-------------------------------------------------------------------	
	cBeginDate	:= BIXIniDate(cFrom, "BIX_CARTMO")

	cQuery := "SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, C2_PEDIDO, " + ;
		"C2_EMISSAO, C2_DATPRF, C2_PRODUTO, C2_ROTEIRO, C2_CC, C2_UM, SC2.R_E_C_N_O_ ID, " + ; 
		"B1_COD, B1_TIPO, B1_GRUPO, B1_LOCPAD " + ;
		"FROM " + RetSQLName("SC2") + " SC2 " + ;
			"INNER JOIN " + RetSQLName("SB1") + " SB1 " + ;
			"ON B1_FILIAL = '" + xFilial("SB1") + "' " + ;
				"AND B1_COD = C2_PRODUTO " + ;
				"AND SB1.D_E_L_E_T_= ' ' " + ;
		"WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + ;
				"AND C2_EMISSAO >= '" + cBeginDate + "' " + ;
				"AND C2_EMISSAO <= '" + cTo + "' " + ;
				"AND C2_QUJE > 0 " + ;
				"AND C2_QUANT <> C2_QUJE " + ; 
				"AND C2_DATRF = ' ' " + ;
				"AND SC2.D_E_L_E_T_= ' ' " + ;
		"ORDER BY C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD"
			
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
	TcSetField( ::cFlow, "C2_EMISSAO"	, "D", 8, 0 )  
	TcSetField( ::cFlow, "C2_DATPRF"	, "D", 8, 0 )
Return ::cFlow