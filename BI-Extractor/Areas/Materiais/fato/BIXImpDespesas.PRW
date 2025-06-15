#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXIMPDESPESAS.CH"

REGISTER EXTRACTOR HQJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXImpDespesas
Classe do extrator para a tabela fato Importação - Despesas do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   16/10/2012
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXImpDespesas from BIXEntity
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
@since   24/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXImpDespesas
	_Super:New( FACT, "HQJ", STR0001, "SWW", { MATERIAIS } ) // "Importação - Despesas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   24/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXImpDespesas 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HQJ_EMPRES", "C", 	32, 0, .T., "HJ4" )
	oModel:AddField( "HQJ_ESTABL", "C", 	32, 0, .T., "HKK" )
	oModel:AddField( "HQJ_FORNEC", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_GRPFOR", "C", 	32, 0, .T., "HGE" )
	oModel:AddField( "HQJ_NATOPR", "C", 	32, 0, .T., "HJ9" )
	oModel:AddField( "HQJ_CFOP"  , "C", 	32, 0, .T., "HG0" )
	oModel:AddField( "HQJ_UNDNEG", "C", 	32, 0, .T., "HJ1" )
	oModel:AddField( "HQJ_MOEDA" , "C", 	32, 0, .T., "HJ6" )
	oModel:AddField( "HQJ_ITEM"  , "C", 	32, 0, .T., "HJ8" )
	oModel:AddField( "HQJ_FAMCOM", "C", 	32, 0, .T., "HG1" )
	oModel:AddField( "HQJ_FAMMAT", "C", 	32, 0, .T., "HG2" )
	oModel:AddField( "HQJ_GRPEST", "C", 	32, 0, .T., "HG3" )
	oModel:AddField( "HQJ_CCUSTO", "C", 	32, 0, .T., "HJ5" )
	oModel:AddField( "HQJ_CMPRDR", "C", 	32, 0, .T., "HJZ" )
	oModel:AddField( "HQJ_CONDPG", "C", 	32, 0, .T., "HJA" )
	oModel:AddField( "HQJ_REGIAO", "C", 	32, 0, .T., "HJB" )
	oModel:AddField( "HQJ_REFER" , "C", 	32, 0, .T., "HJH" )
	oModel:AddField( "HQJ_TRANSP", "C", 	32, 0, .T., "HJ2" )
	oModel:AddField( "HQJ_BCO"   , "C", 	32, 0, .T., "HGK" )
	oModel:AddField( "HQJ_FORNDP", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_FORNDX", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_FORNFB", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_INCOTR", "C", 	32, 0, .T., "HGM" )
	oModel:AddField( "HQJ_PAIS"  , "C", 	32, 0, .T., "HQL" )
	oModel:AddField( "HQJ_SITIMP", "C", 	32, 0, .T., "HQM" )
	oModel:AddField( "HQJ_VIATRA", "C", 	32, 0, .T., "HGR" )
	oModel:AddField( "HQJ_ITINER", "C", 	32, 0, .T., "HGQ" )
	oModel:AddField( "HQJ_FORNAC", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_FORNSG", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_FORNCS", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_PLCCST", "C", 	32, 0, .T., "HKF" )
	oModel:AddField( "HQJ_PTOCTR", "C", 	32, 0, .T., "HGS" )
	oModel:AddField( "HQJ_DESPES", "C", 	32, 0, .T., "HGL" )
	oModel:AddField( "HQJ_FORNDS", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_CPDESP", "C", 	32, 0, .T., "HKJ" )
	oModel:AddField( "HQJ_UNITEM", "C", 	32, 0, .T., "HHW" )
	oModel:AddField( "HQJ_DATA"  , "D", 	8, 0 )		
	oModel:AddField( "HQJ_DATADI", "D", 	8, 0 )		
	oModel:AddField( "HQJ_DTPEDC", "D", 	8, 0 )		
	oModel:AddField( "HQJ_SERDOC", "C", 	8, 0 )		
	oModel:AddField( "HQJ_NUMDOC", "C", 	35, 0 )		
	oModel:AddField( "HQJ_SEQINF", "C", 	10, 0 )		
	oModel:AddField( "HQJ_NUMEMB", "C", 	12, 0 )		
	oModel:AddField( "HQJ_NPRIMP", "C", 	12, 0 )		
	oModel:AddField( "HQJ_ORDEM" , "C", 	10, 0 )		
	oModel:AddField( "HQJ_PEDIDO", "C", 	10, 0 )		
	oModel:AddField( "HQJ_EMERG" , "C", 	1, 0 )		
	oModel:AddField( "HQJ_CEMBHO", "C", 	25, 0 )		
	oModel:AddField( "HQJ_CEMBMA", "C", 	25, 0 )		
	oModel:AddField( "HQJ_NUMFAT", "C", 	35, 0 )		
	oModel:AddField( "HQJ_DECIMP", "C", 	20, 0 )		
	oModel:AddField( "HQJ_EMBENC", "C", 	1, 0 )		
	oModel:AddField( "HQJ_UNFORN", "C", 	15, 0 )		
	oModel:AddField( "HQJ_NLCIMP", "C", 	20, 0 )		
	oModel:AddField( "HQJ_NCRTCR", "C", 	20, 0 )		
	oModel:AddField( "HQJ_NMADIT", "C", 	10, 0 )		
	oModel:AddField( "HQJ_SQADIT", "C", 	10, 0 )		
	oModel:AddField( "HQJ_NATODB", "C", 	20, 0 )		
	oModel:AddField( "HQJ_PARCEL", "N", 	4, 0 )		
	oModel:AddField( "HQJ_VDESPE", "N", 	16, 2 )	
	oModel:AddField( "HQJ_VDENFC", "N", 	16,	2 )	

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
@since   24/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXImpDespesas
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local cMoeda    := ""
	Local cFlow     := ""
	Local nInd      := 1

	aMoedas   := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While (cFlow)->( !Eof() )
		For nInd := 1 To Len(aMoedas)
			cMoeda := aMoedas[nInd][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "WW_NF_COMP" 		, (cFlow)->WW_NF_COMP )
			oRecord:SetValue( "WW_SE_NFC" 		, (cFlow)->WW_SE_NFC )
			oRecord:SetValue( "WW_FORNECE" 		, (cFlow)->WW_FORNECE )
			oRecord:SetValue( "WW_LOJA" 		, (cFlow)->WW_LOJA )
			
			oRecord:SetValue( "A2_COD" 		, (cFlow)->FORNEC )
			oRecord:SetValue( "A2_LOJA" 	, (cFlow)->LOJA )
			oRecord:SetValue( "B1_COD" 		, (cFlow)->ITEM )
			oRecord:SetValue( "ACU_COD" 	, (cFlow)->FAMCOM )
			oRecord:SetValue( "BM_GRUPO" 	, (cFlow)->GRPEST )
			oRecord:SetValue( "Y1_COD" 		, (cFlow)->CMPRDR )		
			oRecord:SetValue( "E4_CODIGO" 	, (cFlow)->CONDPG )
			oRecord:SetValue( "A4_COD" 		, (cFlow)->TRANSP )
			oRecord:SetValue( "YJ_COD" 		, (cFlow)->INCOTR )
			oRecord:SetValue( "CTT_CUSTO" 	, (cFlow)->CCUSTO )			
			oRecord:SetValue( "A6_COD" 		, (cFlow)->BCO )
			oRecord:SetValue( "A6_AGENCIA" 	, (cFlow)->BCOAGE )
			oRecord:SetValue( "A6_NUMCON" 	, (cFlow)->BCOCONTA )			
			oRecord:SetValue( "YB_DESP" 	, (cFlow)->DESPES )
			oRecord:SetValue( "AH_UNIMED" 	, (cFlow)->UM )
			oRecord:SetValue( "F4_CODIGO" 	, (cFlow)->TES )
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HQJ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
			oRecord:SetValue( "HQJ_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HQJ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HQJ_FORNEC", oSeeker:Seek( "HKJ", { (cFlow)->FORNEC, (cFlow)->LOJA } ) ) 
			oRecord:SetValue( "HQJ_GRPFOR", oSeeker:Seek( "HGE", { (cFlow)->GRPFOR } ) ) 
			oRecord:SetValue( "HQJ_NATOPR", oSeeker:Seek( "HJ9", { (cFlow)->TES } ) )
			oRecord:SetValue( "HQJ_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HQJ_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->ITEM } ) ) 
			oRecord:SetValue( "HQJ_FAMCOM", oSeeker:Seek( "HG1", { (cFlow)->FAMCOM } ) ) 
			oRecord:SetValue( "HQJ_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->FAMMAT } ) ) 
			oRecord:SetValue( "HQJ_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->GRPEST } ) ) 
			oRecord:SetValue( "HQJ_CCUSTO", oSeeker:Seek( "HJ5", { (cFlow)->CCUSTO } ) ) 
			oRecord:SetValue( "HQJ_CMPRDR", oSeeker:Seek( "HJZ", { (cFlow)->CMPRDR } ) ) 
			oRecord:SetValue( "HQJ_CONDPG", oSeeker:Seek( "HJA", { (cFlow)->CONDPG } ) ) 
			oRecord:SetValue( "HQJ_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A2_EST, (cFlow)->A2_COD_MUN, (cFlow)->A2_PAIS ) } ) ) 
			oRecord:SetValue( "HQJ_TRANSP", oSeeker:Seek( "HJ2", { (cFlow)->TRANSP } ) )
			oRecord:SetValue( "HQJ_BCO"   , oSeeker:Seek( "HGK", { oRegion:Key((cFlow)->BCO,(cFlow)->BCOAGE,(cFlow)->BCOCONTA ) } ) ) 
			oRecord:SetValue( "HQJ_FORNDP", oSeeker:Seek( "HKJ", { (cFlow)->FORNDP ,(cFlow)->LJFORNDP } ) ) 
			oRecord:SetValue( "HQJ_FORNFB", oSeeker:Seek( "HKJ", { (cFlow)->FORNDP ,(cFlow)->LJFORNDP } ) ) 
			oRecord:SetValue( "HQJ_INCOTR", oSeeker:Seek( "HGM", { oRegion:Key((cFlow)->INCOTR ) } ) ) 
			oRecord:SetValue( "HQJ_PAIS"  , oSeeker:Seek( "HJB", { oRegion:Key((cFlow)->PAIS ) } ) ) 
			oRecord:SetValue( "HQJ_SITIMP", oSeeker:Seek( "HQM", { DI500Status((cFlow)->NPRIMP) } ) ) 
			oRecord:SetValue( "HQJ_VIATRA", oSeeker:Seek( "HGR", { oRegion:Key((cFlow)->VIATRA ) } ) ) 
			oRecord:SetValue( "HQJ_FORNAC", oSeeker:Seek( "HKJ", { (cFlow)->FORNDP ,(cFlow)->LJFORNDP } ) ) 
			oRecord:SetValue( "HQJ_FORNSG", oSeeker:Seek( "HKJ", { (cFlow)->FORNDP ,(cFlow)->LJFORNDP } ) ) 
			oRecord:SetValue( "HQJ_FORNCS", oSeeker:Seek( "HKJ", { (cFlow)->FORNDP ,(cFlow)->LJFORNDP } ) ) 
			oRecord:SetValue( "HQJ_DESPES", oSeeker:Seek( "HGL", { (cFlow)->DESPES } ) ) 
			oRecord:SetValue( "HQJ_FORNDS", oSeeker:Seek( "HKJ", { (cFlow)->FORNDP ,(cFlow)->LJFORNDP } ) ) 
			oRecord:SetValue( "HQJ_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->UM } ) )
			oRecord:SetValue( "HQJ_CFOP"  , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQJ_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQJ_FORNDX", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQJ_ITINER", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQJ_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQJ_PTOCTR", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQJ_CPDESP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQJ_SERDOC", SerieNFID( cFlow, 2, "D1_SERIE"))	// Série do Documento
			oRecord:SetValue( "HQJ_NUMDOC", (cFlow)->NUMDOC )     // Documento
			oRecord:SetValue( "HQJ_SEQINF", (cFlow)->SEQINF )      // Sequência do Item na Nota
			oRecord:SetValue( "HQJ_NPRIMP", (cFlow)->NPRIMP )      // Número Processo Importação
			oRecord:SetValue( "HQJ_ORDEM" , (cFlow)->ORDEM  )       // Ordem de Compra
			oRecord:SetValue( "HQJ_PEDIDO", (cFlow)->PEDIDO )      // Número do Pedido de Compra
			oRecord:SetValue( "HQJ_CEMBHO", (cFlow)->CEMBHO )      // Conhecimento Embarque House
			oRecord:SetValue( "HQJ_CEMBMA", (cFlow)->CEMBMA )      // Conhecimento Embarque Master
			oRecord:SetValue( "HQJ_NUMFAT", (cFlow)->NUMFAT )      // Número Fatura Comercial
			oRecord:SetValue( "HQJ_DECIMP", (cFlow)->DECIMP )      // Declaração Importação
			oRecord:SetValue( "HQJ_UNFORN", (cFlow)->UNFORN )      // Unidade Fornecedor
			oRecord:SetValue( "HQJ_NLCIMP", (cFlow)->NLCIMP )      // Número Licença Importação
			oRecord:SetValue( "HQJ_NCRTCR", (cFlow)->NCRTCR )      // Número da Carta de Crédito
			oRecord:SetValue( "HQJ_NMADIT", (cFlow)->NMADIT )      // Número de Adição
			oRecord:SetValue( "HQJ_SQADIT", (cFlow)->SQADIT )      // Sequência de Adição
			oRecord:SetValue( "HQJ_NATODB", (cFlow)->NATODB )      // Número Ato Concessório
			oRecord:SetValue( "HQJ_DATA"  , IIf( !Empty( StoD( (cFlow)->DATA)), StoD((cFlow)->DATA), DATE_EMPTY) )     // Data de Emissão da Nota Fiscal
			oRecord:SetValue( "HQJ_DATADI", IIf( !Empty( StoD( (cFlow)->DATADI)), StoD((cFlow)->DATADI), DATE_EMPTY) )  // Data da Declaração de Importação
			oRecord:SetValue( "HQJ_DTPEDC", IIf( !Empty( StoD( (cFlow)->DTPEDC)), StoD((cFlow)->DTPEDC), DATE_EMPTY) )  // Data do Pedido de Compra
			oRecord:SetValue( "HQJ_NUMEMB", " " )                // Número do Embarque
			oRecord:SetValue( "HQJ_EMERG" , " " )                // Pedido Emergencial

			If !Empty((cFlow)->EMBENC)
				oRecord:SetValue( "HQJ_EMBENC", "S" )
			Else
				oRecord:SetValue( "HQJ_EMBENC", "N" )
			EndIf

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQJ_VDESPE", BIXValue( (cFlow)->VDESPE , 1 , cMoeda , StoD((cFlow)->DATADI) )) // Vl Total Despesas
			oRecord:SetValue( "HQJ_PARCEL", 0 )                // Parcela da Ordem de Compra
			oRecord:SetValue( "HQJ_VDENFC", 0 )                // Vl Despesa Complementar
			
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
@since   24/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXImpDespesas
	Local cQuery    := ""
	Local cSubstr   := If("SQL" $ TCGetDB(),"SUBSTRING","SUBSTR")

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cQuery := "	SELECT " + cSubstr + "(SWW.WW_DESPESA, 1," + Trim(Str(TamSX3("YB_DESP")[1])) + ") as DESPES, "
	cQuery += "		SWW.WW_INVOICE as NUMFAT, SWW.WW_VALOR as VDESPE, SWN.WN_SI_NUM as PEDIDO, SWN.WN_ADICAO as NMADIT, SWN.WN_SEQ_ADI as SQADIT, "
	cQuery += "     SWW.WW_NF_COMP, SWW.WW_SE_NFC, SWW.WW_FORNECE, SWW.WW_LOJA, "
	cQuery += "		SD1.D1_FORNECE as FORNEC, SD1.D1_LOJA as LOJA, SD1.D1_COD as ITEM, SD1.D1_CC as CCUSTO, SD1.D1_TES as TES, "	
	cQuery += "		SD1.D1_SERIE as D1_SERIE, SD1.D1_DOC as NUMDOC, SD1.D1_ITEM as SEQINF, SD1.D1_UM as UM, "
	cQuery += "		SD1.D1_CONHEC as NPRIMP, SD1.D1_PEDIDO as ORDEM, SD1.D1_EMISSAO as DATA, SD1.R_E_C_N_O_ as RECNO_, "
	cQuery += "		SA2.A2_GRUPO as GRPFOR, SA2.A2_PAIS as A2_PAIS, SA2.A2_EST as A2_EST, SA2.A2_COD_MUN as A2_COD_MUN, "
	cQuery += "		SA2.A2_BANCO as BCO, SA2.A2_AGENCIA as BCOAGE, SA2.A2_NUMCON as BCOCONTA, "
	cQuery += "		ACV.ACV_CATEGO as FAMCOM, "
	cQuery += "		SB1.B1_TIPO as FAMMAT, SB1.B1_GRUPO as GRPEST, "
	cQuery += "		SC7.C7_COMPRA as CMPRDR, SC7.C7_COND as CONDPG, SC7.C7_FABRICA as FORNFB, SC7.C7_LOJFABR as LJFORNFB, "
	cQuery += "		SF1.F1_TRANSP as TRANSP, "
	cQuery += "		SW6.W6_PAISPRO as PAIS, SW6.W6_FORNECS as FORNSG, SW6.W6_LOJAS as LJFORNSG, SW6.W6_HOUSE as CEMBHO, "
	cQuery += "		SW6.W6_MAWB as CEMBMA, SW6.W6_DI_NUM as DECIMP, SW6.W6_DTREG_D as DATADI, SW6.W6_DT_ENCE as EMBENC, "
	cQuery += "		SW9.W9_INCOTER as INCOTR, "
	cQuery += "		" + cSubstr + "(SYQ.YQ_COD_DI,1,1) as VIATRA, "
	cQuery += "		SY4.Y4_FORN as FORNAC, SY4.Y4_LOJA as LJFORNAC, "
	cQuery += "		SYW.YW_FORN as FORNCS, SYW.YW_LOJA as LJFORNCS, "
	cQuery += "		SWD.WD_FORN as FORNDS, SWD.WD_LOJA as LJFORNDS, "
	cQuery += "		SA5.A5_UNID as UNFORN, "
	cQuery += "		SY5.Y5_FORNECE as FORNDP, SY5.Y5_LOJAF as LJFORNDP, "
	cQuery += "		SW8.W8_AC as NATODB, "
	cQuery += "		SWP.WP_REGIST as NLCIMP, "
	cQuery += "		SYH.YH_LC_NUM as NCRTCR, "
	cQuery += "		SW2.W2_PO_DT as DTPEDC "
	cQuery += "FROM " + RetSqlName("SWW") + " SWW "
	cQuery += "LEFT JOIN " + RetSqlName("SWN") + " SWN ON (	SWW.WW_NF_COMP = SWN.WN_DOC AND "
	cQuery += "		SWW.WW_SE_NFC = SWN.WN_SERIE AND "
	cQuery += "		SWW.WW_FORNECE = SWN.WN_FORNECE AND "
	cQuery += "		SWW.WW_LOJA = SWN.WN_LOJA AND "
	cQuery += "		SWN.WN_FILIAL = '" + xFilial("SWN") + "' AND "
	cQuery += "		SWN.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SD1") + " SD1 ON (	SWN.WN_DOC = SD1.D1_DOC AND "
	cQuery += "		SWN.WN_SERIE = SD1.D1_SERIE AND "
	cQuery += "		SWN.WN_FORNECE = SD1.D1_FORNECE AND "
	cQuery += "		SWN.WN_LOJA = SD1.D1_LOJA AND "
	cQuery += "		SWN.WN_PRODUTO = SD1.D1_COD AND "
	cQuery += "		SWN.WN_LINHA = SD1.D1_ITEM AND "
	cQuery += "		SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "
	cQuery += "		SD1.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON (	SD1.D1_FORNECE = SA2.A2_COD AND "
	cQuery += "		SD1.D1_LOJA = SA2.A2_LOJA AND "
	cQuery += "		SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND "
	cQuery += "		SA2.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("ACV") + " ACV ON ( SD1.D1_COD = ACV.ACV_CODPRO AND "
	cQuery += "		ACV.ACV_FILIAL = '" + xFilial("ACV") + "' AND "
	cQuery += "		ACV.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SB1") + " SB1 ON (	SD1.D1_COD = SB1.B1_COD AND "
	cQuery += "		SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
	cQuery += "		SB1.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SC7") + " SC7 ON (	SD1.D1_PEDIDO = SC7.C7_NUM AND "
	cQuery += "		SD1.D1_ITEMPC = SC7.C7_ITEM AND "
	cQuery += "		SC7.C7_FILIAL = '" + xFilial("SC7") + "' AND "
	cQuery += "		SC7.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON (	SD1.D1_DOC = SF1.F1_DOC AND "
	cQuery += "		SD1.D1_SERIE = SF1.F1_SERIE AND "
	cQuery += "		SD1.D1_FORNECE = SF1.F1_FORNECE AND "
	cQuery += "		SD1.D1_LOJA = SF1.F1_LOJA AND "
	cQuery += "		SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND "
	cQuery += "		SF1.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW6") + " SW6 ON ( SD1.D1_CONHEC = SW6.W6_HAWB AND "
	cQuery += "		SW6.W6_FILIAL = '" + xFilial("SW6") + "' AND "
	cQuery += "		SW6.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW9") + " SW9 ON (	SWN.WN_INVOICE = SW9.W9_INVOICE AND "
	cQuery += "		SW9.W9_FILIAL = '" + xFilial("SW9") + "' AND "
	cQuery += "		SW9.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SYQ") + " SYQ ON (	SW6.W6_VIA_TRA = SYQ.YQ_VIA AND "
	cQuery += "		SYQ.YQ_FILIAL = '" + xFilial("SYQ") + "' AND "
	cQuery += "		SYQ.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SY4") + " SY4 ON (	SW6.W6_AGENTE = SY4.Y4_COD AND "
	cQuery += "		SY4.Y4_FILIAL = '" + xFilial("SY4") + "' AND "
	cQuery += "		SY4.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SYW") + " SYW ON (	SW6.W6_CORRETO = SYW.YW_COD AND  "
	cQuery += "		SYW.YW_FILIAL = '" + xFilial("SYW") + "' AND "
	cQuery += "		SYW.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SWD") + " SWD ON (	SWW.WW_HAWB = SWD.WD_HAWB AND "
	cQuery += "		" + cSubstr + "(SWW.WW_DESPESA, 1," + Trim(Str(TamSX3("YB_DESP")[1])) + ") = SWD.WD_DESPESA AND "
	cQuery += "		SWD.WD_FILIAL = '" + xFilial("SWD") + "' AND "
	cQuery += "		SWD.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SY5") + " SY5 ON (	SW6.W6_DESP = SY5.Y5_COD AND "
	cQuery += "		SY5.Y5_FILIAL = '" + xFilial("SY5") + "' AND "
	cQuery += "		SY5.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW8") + " SW8 ON (SWN.WN_HAWB = SW8.W8_HAWB AND "
	cQuery += "		SWN.WN_INVOICE = SW8.W8_INVOICE AND "
	cQuery += "		SWN.WN_PO_EIC = SW8.W8_PO_NUM AND "
	cQuery += "		SWN.WN_ITEM = SW8.W8_POSICAO AND "
	cQuery += "		SWN.WN_PGI_NUM = SW8.W8_PGI_NUM AND "
	cQuery += "		SW8.W8_FILIAL = '" + xFilial("SW8") + "' AND "
	cQuery += "		SW8.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SA5") + " SA5 ON (SD1.D1_FORNECE = SA5.A5_FORNECE AND "
	cQuery += "		SD1.D1_LOJA = SA5.A5_LOJA AND "
	cQuery += "		SD1.D1_COD = SA5.A5_PRODUTO AND "
	cQuery += "		SW8.W8_FABR = SA5.A5_FABR AND "
	cQuery += "		SA5.A5_FILIAL = '" + xFilial("SA5") + "' AND "
	cQuery += "		SA5.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SWP") + " SWP ON (SW8.W8_PGI_NUM = SWP.WP_PGI_NUM AND "
	cQuery += "		SW8.W8_SEQ_LI = SWP.WP_SEQ_LI AND "
	cQuery += "		SWP.WP_FILIAL = '" + xFilial("SWP") + "' AND "
	cQuery += "		SWP.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SYH") + " SYH ON (	SWN.WN_PO_EIC = SYH.YH_PO_GI AND "
	cQuery += "		SYH.YH_FILIAL = '" + xFilial("SYH") + "' AND "
	cQuery += "		SYH.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW2") + " SW2 ON ( SWN.WN_PO_EIC = SW2.W2_PO_NUM AND "
	cQuery += "		SW2.W2_FILIAL = '" + xFilial("SW2") + "' AND "
	cQuery += "		SW2.D_E_L_E_T_ = ' ') "
	cQuery += "WHERE SW6.W6_DTREG_D BETWEEN '" + cFrom + "' AND '" + cTo + "' AND "
	cQuery += "		SWW.WW_FILIAL = '" + xFilial("SWW") + "' AND "
	cQuery += "		SWW.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Transforma a query em ANSI.
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária.
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ::cFlow := GetNextAlias(), .T., .F.)
Return ::cFlow