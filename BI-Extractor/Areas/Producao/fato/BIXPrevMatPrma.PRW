#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPREVMATPRMA.CH"

REGISTER EXTRACTOR HLV

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPrevMatPrma
Classe do extrator para a tabela fato Matéria-Prima - Prevista Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXPrevMatPrma from BIXEntity
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
Method New() Class BIXPrevMatPrma
	_Super:New( FACT, "HLV", STR0001, "SD4", { PRODUCAO } ) //"Matéria-Prima - Prevista"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   28/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPrevMatPrma
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLV_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLV_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLV_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLV_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLV_ITMPAI", "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLV_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLV_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLV_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLV_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLV_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLV_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLV_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HLV_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLV_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLV_OPERA" , "C", 32, 0, .T., "HQC" )
	oModel:AddField( "HLV_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLV_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLV_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLV_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLV_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HLV_PEDIDO", "C", 12, 0 )
	oModel:AddField( "HLV_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLV_ORDEM" , "C", 13, 0 )		
	oModel:AddField( "HLV_TIPSOB", "C", 30, 0 )		
	oModel:AddField( "HLV_QPRPDR", "N", 16, 4 )
	oModel:AddField( "HLV_QPDFCM", "N", 16, 2 )	
	oModel:AddField( "HLV_QPDFMT", "N", 16, 4 )
	oModel:AddField( "HLV_VPRPDR", "N", 16, 2 )	

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPrevMatPrma
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local cMoeda    := ""
	Local nMoeda    := 1 
	Local cTipITM	:= ""
	Local lFindSA1 := .F.
	Local lFindSC2 := .F.
	Local lFindACV := .F.
	Local lFindSH6 := .F.
	
	Private cRetAlias	:= ""

	aMoedas := BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("SC2")	
	SC2->( dbSetOrder(1) ) // Filial + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD

	DbSelectArea("SC5")
	SC5->( dbSetOrder(1) ) // Filial + C5_NUM
    
	DbSelectArea("ACV")	
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	DbSelectArea("SH6")	
	SH6->( dbSetOrder(1) ) // Filial + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cRetAlias := ::Flow( cFrom, cTo )

	While (cRetAlias)->(! Eof() ) 
		// Considera apenas produtos que não são Mão de Obra	
		If IsProdMod((cRetAlias)->D4_COD)
			(cRetAlias)->( dbSkip() )
			Loop
		EndIf	

		lFindSA1 := .F.
		lFindSC2 := .F.
		lFindACV := .F.
		lFindSH6 := .F.
		cTipITM	 := ""

		If SC5->( MsSeek( xFilial("SC5") + (cRetAlias)->C2_PEDIDO ) )
			If SA1->( MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
				lFindSA1 := .T.
			EndIF
		EndIf	

		If ACV->( MsSeek( xFilial("ACV") + (cRetAlias)->C2_PRODUTO ) )            
			lFindACV := .T.
		EndIf
		
		IF SH6->( MsSeek( xFilial("SH6") + (cRetAlias)->D4_OP + (cRetAlias)->D4_COD ) ) 	
			lFindSH6 := .T.
		EndIF
		
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
			oRecord:SetValue( "D4_COD"     , (cRetAlias)->D4_COD )
			oRecord:SetValue( "D4_OP"     , (cRetAlias)->D4_OP )
			oRecord:SetValue( "B1_COD"     , (cRetAlias)->D4_COD )
			oRecord:SetValue( "BM_GRUPO"   , (cRetAlias)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"  , (cRetAlias)->B1_UM )
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLV_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HLV_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HLV_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HLV_ITEM"  , oSeeker:Seek( "HJ8", { (cRetAlias)->D4_COD } ) ) 
			oRecord:SetValue( "HLV_ITMPAI", oSeeker:Seek( "HJ8", { (cRetAlias)->C2_PRODUTO } ) ) 
			oRecord:SetValue( "HLV_FAMMAT", oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) ) 
			oRecord:SetValue( "HLV_GRPEST", oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HLV_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HLV_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
			oRecord:SetValue( "HLV_UNITEM", oSeeker:Seek( "HHW", { (cRetAlias)->B1_UM } ) ) 
			oRecord:SetValue( "HLV_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			oRecord:SetValue( "HLV_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			oRecord:SetValue( "HLV_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )	

			If lFindSA1
				oRecord:SetValue( "A1_COD"     , SC5->C5_CLIENTE )
				oRecord:SetValue( "A1_LOJA"    , SC5->C5_LOJACLI )
			
				oRecord:SetValue( "HLV_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
				oRecord:SetValue( "HLV_CLIENT", oSeeker:Seek( "HJ7", { SC5->C5_CLIENTE, SC5->C5_LOJACLI} ) )
				oRecord:SetValue( "HLV_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) ) 
			Else
				oRecord:SetValue( "A1_COD"     , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "A1_LOJA"    , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			
				oRecord:SetValue( "HLV_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLV_CLIENT", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLV_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			EndIf
			
			If lFindSC2
				oRecord:SetValue( "HLV_DEPOSI", oSeeker:Seek( "HJD", { (cRetAlias)->C2_LOCAL } ) ) 
			Else
				oRecord:SetValue( "HLV_DEPOSI", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			EndIf	
			
			If lFindACV
				oRecord:SetValue( "ACU_COD"    , (cRetAlias)->ACV_CATEGO )		
				oRecord:SetValue( "HLV_FAMCOM", oSeeker:Seek( "HG1", { (cRetAlias)->ACV_CATEGO } ) ) 
			Else
				oRecord:SetValue( "ACU_COD"   , oSeeker:oKey:GetKey( { UNDEFINED } ) )		
				oRecord:SetValue( "HLV_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			EndIF
			
			IF lFindSH6
				oRecord:SetValue( "G2_PRODUTO" , SH6->H6_PRODUTO )
				oRecord:SetValue( "G2_OPERAC"  , SH6->H6_OPERAC )
				oRecord:SetValue( "HLV_OPERA"  , oSeeker:Seek( "HQC", { SH6->H6_PRODUTO, SH6->H6_OPERAC } ) )
			Else
				oRecord:SetValue( "G2_PRODUTO" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "G2_OPERAC"  , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLV_OPERA"  , oSeeker:oKey:GetKey( { UNDEFINED } ) )	
			EndIf
			
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLV_PEDIDO", (cRetAlias)->C2_PEDIDO ) // Número do Pedido
			oRecord:SetValue( "HLV_SEQCIA", (cRetAlias)->C2_SEQUEN ) // Sequência da Ordem
			oRecord:SetValue( "HLV_ORDEM ", (cRetAlias)->D4_OP )     // Ordem de Produção
			oRecord:SetValue( "HLV_TIPSOB", " " )     // Tipo de Sobra (Não tem conceito para SD4.)

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLV_DATA", (cRetAlias)->C2_EMISSAO ) // Data de Emissão da Ordem
			oRecord:SetValue( "HLV_QPRPDR", (cRetAlias)->D4_QTDEORI ) // Qtde Padrão
			oRecord:SetValue( "HLV_VPRPDR", (cRetAlias)->D4_QTDEORI * & ("(cRetAlias)->B2_CM" + cMoeda ) ) // Vl Padrão
			oRecord:SetValue( "HLV_QPDFMT", 0 )       // Qtde Padrao UN FM
			oRecord:SetValue( "HLV_QPDFCM", 0 )       // Qtde Padrao UN FC	

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
	
	(cRetAlias)->(DbCloseArea()) // Remove filtro
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXPrevMatPrma
	Local cQuery 	:= ""
	
	cQuery := "SELECT D4_COD, D4_OP, D4_QTDEORI, SD4.R_E_C_N_O_ ID, " + ;
			"B1_COD, B1_TIPO, B1_GRUPO, B1_UM, B1_LOCPAD, " + ;
			"C2_NUM, C2_ITEM, C2_ITEMGRD, C2_LOCAL, C2_EMISSAO,  " + ;
		   	"C2_QUANT, C2_QUJE, C2_PEDIDO, C2_PRODUTO, C2_SEQUEN, " + ;
		   	"B2_COD, B2_LOCAL, B2_CM1, B2_CM2, B2_CM3, B2_CM4, B2_CM5, " + ;
		   	"(SELECT MAX(G1_COD) " + ;
				"FROM " + RetSqlName("SG1")+ " SG1 " + ;			
				"WHERE G1_FILIAL = '" + xFilial("SG1") + "' " + ; 
				"AND G1_COD = D4_COD " + ;
				"AND SG1.D_E_L_E_T_ = ' ') G1_COD " + ;
			"FROM " + RetSqlName("SD4")+ " SD4 " + ;
			"INNER JOIN " + RetSqlName("SB1") + " SB1 " + ;
				"ON B1_FILIAL = '" + xFilial("SB1") + "' " + ;
				"AND B1_COD = D4_COD " + ;
				"AND SB1.D_E_L_E_T_ = ' ' " + ;
			"INNER JOIN " + RetSqlName("SC2") + " SC2 " + ;
				"ON C2_FILIAL = '" + xFilial("SC2") + "' " + ;
				"AND C2_NUM || C2_ITEM || C2_SEQUEN || C2_ITEMGRD = D4_OP " + ;
				"AND C2_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' " + ;
				"AND C2_QUANT > 0 " + ;
				"AND C2_QUJE = 0 " + ;
				"AND SC2.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN " + RetSqlName("SB2") + " SB2 " + ;
				"ON B2_FILIAL = '" + xFilial("SB2") + "' " + ;
				"AND B2_COD = D4_COD " + ;
				"AND B2_LOCAL = B1_LOCPAD " + ;
				"AND SB2.D_E_L_E_T_ = ' ' " + ;
			"WHERE D4_FILIAL = '" + xFilial("SD4") + "' " + ;
				"AND SD4.D_E_L_E_T_ = ' ' " + ;
			"ORDER BY D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE"
			
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
	TcSetField( cRetAlias, "C2_EMISSAO", "D", 8, 0 ) 
Return cRetAlias
