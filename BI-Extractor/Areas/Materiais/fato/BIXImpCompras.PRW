#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXIMPCOMPRAS.CH"

REGISTER EXTRACTOR HQI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXImpCompras
Classe do extrator para a tabela fato Importação - Compras do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   16/10/2012

/*/
//-------------------------------------------------------------------
Class BIXImpCompras from BIXEntity
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
Method New() Class BIXImpCompras
	_Super:New( FACT, "HQI", STR0001, "SD1", { MATERIAIS } ) // "Importação - Compras"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   24/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXImpCompras 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HQI_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HQI_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HQI_FORNEC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQI_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HQI_NATOPR", "C", 32, 0, .T., "HJ9" )
	oModel:AddField( "HQI_CFOP"  , "C", 32, 0, .T., "HG0" )
	oModel:AddField( "HQI_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HQI_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HQI_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HQI_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HQI_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HQI_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HQI_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HQI_CMPRDR", "C", 32, 0, .T., "HJZ" )
	oModel:AddField( "HQI_CONDPG", "C", 32, 0, .T., "HJA" )
	oModel:AddField( "HQI_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HQI_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HQI_TRANSP", "C", 32, 0, .T., "HJ2" )
	oModel:AddField( "HQI_BCO"   , "C", 32, 0, .T., "HGK")
	oModel:AddField( "HQI_FORNDP", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQI_FORNDX", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQI_FORNFB", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQI_INCOTR", "C", 32, 0, .T., "HGM" )
	oModel:AddField( "HQI_PAIS"  , "C", 32, 0, .T., "HQL" )
	oModel:AddField( "HQI_SITIMP", "C", 32, 0, .T., "HQM" )
	oModel:AddField( "HQI_VIATRA", "C", 32, 0, .T., "HGR" )
	oModel:AddField( "HQI_ITINER", "C", 32, 0, .T., "HGQ" )
	oModel:AddField( "HQI_FORNAC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQI_FORNSG", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQI_FORNCS", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQI_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HQI_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HQI_DATA"  , "D", 8, 0 )		
	oModel:AddField( "HQI_DATADI", "D", 8, 0 )		
	oModel:AddField( "HQI_DTPEDC", "D", 8, 0 )		
	oModel:AddField( "HQI_SERDOC", "C", 8, 0 )		
	oModel:AddField( "HQI_NUMDOC", "C", 35, 0 )		
	oModel:AddField( "HQI_SEQINF", "C", 10, 0 )		
	oModel:AddField( "HQI_NUMEMB", "C", 12, 0 )		
	oModel:AddField( "HQI_NPRIMP", "C", 17, 0 )		
	oModel:AddField( "HQI_ORDEM" , "C", 10, 0 )		
	oModel:AddField( "HQI_PEDIDO", "C", 10, 0 )		
	oModel:AddField( "HQI_EMERG" , "C", 1, 0 )		
	oModel:AddField( "HQI_CEMBHO", "C", 25, 0 )		
	oModel:AddField( "HQI_CEMBMA", "C", 25, 0 )		
	oModel:AddField( "HQI_NUMFAT", "C", 35, 0 )		
	oModel:AddField( "HQI_DECIMP", "C", 20, 0 )		
	oModel:AddField( "HQI_EMBENC", "C", 1, 0 )		
	oModel:AddField( "HQI_UNFORN", "C", 15, 0 )
	oModel:AddField( "HQI_NLCIMP", "C", 20, 0 )		
	oModel:AddField( "HQI_NCRTCR", "C", 20, 0 )		
	oModel:AddField( "HQI_NMADIT", "C", 10, 0 )		
	oModel:AddField( "HQI_SQADIT", "C", 10, 0 )		
	oModel:AddField( "HQI_NATODB", "C", 20, 0 )		
	oModel:AddField( "HQI_PARCEL", "N", 4, 0 )		
	oModel:AddField( "HQI_VLIMPI", "N", 16, 2 )
	oModel:AddField( "HQI_VINCOT", "N", 16, 2 )
	oModel:AddField( "HQI_VCOFIN", "N", 16, 2 )
	oModel:AddField( "HQI_VDESPE", "N", 16, 2 )
	oModel:AddField( "HQI_VLSEGU", "N", 16, 2 )
	oModel:AddField( "HQI_VFRTNF", "N", 16, 2 )
	oModel:AddField( "HQI_VICMSF", "N", 16, 2 )
	oModel:AddField( "HQI_VIPIFT", "N", 16, 2 )
	oModel:AddField( "HQI_VPISFT", "N", 16, 2 )
	oModel:AddField( "HQI_VCOMPR", "N", 16, 2 )
	oModel:AddField( "HQI_VLCIF" , "N", 16, 2 )
	oModel:AddField( "HQI_VLCFR" , "N", 16, 2 )
	oModel:AddField( "HQI_VLFOB" , "N", 16, 2 )
	oModel:AddField( "HQI_VFOBCI", "N", 16, 2 )
	oModel:AddField( "HQI_VLTXDI", "N", 16, 2 )
	oModel:AddField( "HQI_VCUSTI", "N", 16, 2 )
	oModel:AddField( "HQI_QCOMPR", "N", 16, 4 )	
	oModel:AddField( "HQI_QTPESL", "N", 16, 4 )	
	oModel:AddField( "HQI_QTPESB", "N", 16, 4 )	
	oModel:AddField( "HQI_VALIQI", "N", 16, 4 )	

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXImpCompras
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local cMoeda    := ""
	Local cFlow    := ""
	Local nInd      := 1
	Local nVLIncot := 0
	Local nVCusti := 0
	
	aMoedas := BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While (cFlow)->( !Eof() )
		For nInd := 1 To Len(aMoedas)
			nVLIncot := 0
			nVCusti := 0

			cMoeda := aMoedas[nInd][1]
			nVLIncot := BIXValue( (cFlow)->VINCOT , 1 , cMoeda, StoD((cFlow)->DATADI))
			nVCusti := BIXValue( (cFlow)->VCUSTI , 1 , cMoeda, StoD((cFlow)->DATADI))
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D1_DOC"   	, (cFlow)->NUMDOC )
			oRecord:SetValue( "D1_SERIE"   	, (cFlow)->D1_SERIE )
			oRecord:SetValue( "D1_FORNECE"  , (cFlow)->FORNEC )
			oRecord:SetValue( "D1_LOJA"   	, (cFlow)->LOJA )
			oRecord:SetValue( "D1_ITEM"   	, (cFlow)->SEQINF )
			oRecord:SetValue( "A2_COD" 		, (cFlow)->FORNEC )
			oRecord:SetValue( "A2_LOJA" 	, (cFlow)->LOJA )		
			oRecord:SetValue( "B1_COD" 		, (cFlow)->ITEM )			
			oRecord:SetValue( "ACU_COD" 	, (cFlow)->FAMCOM )
			oRecord:SetValue( "BM_GRUPO" 	, (cFlow)->GRPEST )
			oRecord:SetValue( "Y1_COD" 		, (cFlow)->CMPRDR )
			oRecord:SetValue( "E4_CODIGO" 	, (cFlow)->CONDPG )			
			oRecord:SetValue( "A4_COD" 		, (cFlow)->TRANSP )
			oRecord:SetValue( "YJ_COD" 		, (cFlow)->INCOTR )
			oRecord:SetValue( "F4_CODIGO" 	, (cFlow)->TES )		
			oRecord:SetValue( "CTT_CUSTO" 	, (cFlow)->CCUSTO )		
			oRecord:SetValue( "A6_COD" 		, (cFlow)->BCO )
			oRecord:SetValue( "A6_AGENCIA" 	, (cFlow)->BCOAGE )
			oRecord:SetValue( "A6_NUMCON" 	, (cFlow)->BCOCONTA )			
			oRecord:SetValue( "AH_UNIMED" 	, (cFlow)->UM )
			oRecord:SetValue( "YA_CODGI" 	, (cFlow)->A2_PAIS )
			
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HQI_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HQI_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HQI_FORNEC", oSeeker:Seek( "HKJ", { (cFlow)->FORNEC, (cFlow)->LOJA} ) ) 
			oRecord:SetValue( "HQI_GRPFOR", oSeeker:Seek( "HGE", { (cFlow)->GRPFOR } ) ) 
			oRecord:SetValue( "HQI_NATOPR", oSeeker:Seek( "HJ9", { (cFlow)->TES } ) )
			oRecord:SetValue( "HQI_CFOP"  , oSeeker:Seek( "HG0", { (cFlow)->CFOP } ) )
			oRecord:SetValue( "HQI_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HQI_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) )
			oRecord:SetValue( "HQI_ITEM"  , oSeeker:Seek( "HJ8", { (cFlow)->ITEM } ) )
			oRecord:SetValue( "HQI_FAMCOM", oSeeker:Seek( "HG2", { (cFlow)->FAMCOM } ) )
			oRecord:SetValue( "HQI_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->FAMMAT } ) )
			oRecord:SetValue( "HQI_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->GRPEST } ) ) 
			oRecord:SetValue( "HQI_CCUSTO", oSeeker:Seek( "HJ5", { (cFlow)->CCUSTO } ) ) 
			oRecord:SetValue( "HQI_CMPRDR", oSeeker:Seek( "HJZ", { (cFlow)->CMPRDR } ) ) 
			oRecord:SetValue( "HQI_CONDPG", oSeeker:Seek( "HJA", { (cFlow)->CONDPG } ) ) 
			oRecord:SetValue( "HQI_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A2_EST, (cFlow)->A2_COD_MUN, (cFlow)->A2_PAIS ) } ) ) 
			oRecord:SetValue( "HQI_TRANSP", oSeeker:Seek( "HJ2", { (cFlow)->TRANSP } ) )
			oRecord:SetValue( "HQI_BCO"   , oSeeker:Seek( "HGK", { (cFlow)->BCO,(cFlow)->BCOAGE,(cFlow)->BCOCONTA } ) ) 
			oRecord:SetValue( "HQI_FORNDP", oSeeker:Seek( "HKJ", { (cFlow)->FORNDP ,(cFlow)->LJFORNDP } ) ) 
			oRecord:SetValue( "HQI_FORNFB", oSeeker:Seek( "HKJ", { (cFlow)->FORNFB ,(cFlow)->LJFORNFB } ) ) 
			oRecord:SetValue( "HQI_INCOTR", oSeeker:Seek( "HGM", { (cFlow)->INCOTR  } ) ) 
			oRecord:SetValue( "HQI_PAIS"  , oSeeker:Seek( "HJB", { oRegion:Key( "", "", (cFlow)->PAIS ) } ) ) 
			oRecord:SetValue( "HQI_SITIMP", oSeeker:Seek( "HQM", { DI500Status((cFlow)->NPRIMP) } ) ) 
			oRecord:SetValue( "HQI_VIATRA", oSeeker:Seek( "HGR", { (cFlow)->VIATRA  } ) ) 
			oRecord:SetValue( "HQI_FORNAC", oSeeker:Seek( "HKJ", { (cFlow)->FORNAC ,(cFlow)->LJFORNAC } ) ) 
			oRecord:SetValue( "HQI_FORNSG", oSeeker:Seek( "HKJ", { (cFlow)->FORNSG ,(cFlow)->LJFORNSG } ) ) 
			oRecord:SetValue( "HQI_FORNCS", oSeeker:Seek( "HKJ", { (cFlow)->FORNCS ,(cFlow)->LJFORNCS } ) ) 
			oRecord:SetValue( "HQI_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->UM } ) )
			oRecord:SetValue( "HQI_ITINER", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQI_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQI_FORNDX", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQI_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			

			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQI_SERDOC" , SerieNFID(cFlow, 2, "D1_SERIE") ) // Série do Documento
			oRecord:SetValue( "HQI_NUMDOC" , (cFlow)->NUMDOC )      // Documento
			oRecord:SetValue( "HQI_SEQINF" , (cFlow)->SEQINF )     // Sequência do Item na Nota
			oRecord:SetValue( "HQI_NPRIMP" , (cFlow)->NPRIMP )      // Número Processo Importação
			oRecord:SetValue( "HQI_ORDEM" , (cFlow)->ORDEM  )      // Ordem de Compra
			oRecord:SetValue( "HQI_PEDIDO" , (cFlow)->PEDIDO )      // Número do Pedido de Compra
			oRecord:SetValue( "HQI_CEMBHO" , (cFlow)->CEMBHO )      // Conhecimento Embarque House
			oRecord:SetValue( "HQI_CEMBMA" , (cFlow)->CEMBMA )      // Conhecimento Embarque Master
			oRecord:SetValue( "HQI_NUMFAT" , (cFlow)->NUMFAT )      // Número Fatura Comercial
			oRecord:SetValue( "HQI_DECIMP" , (cFlow)->DECIMP )      // Declaração Importação
			oRecord:SetValue( "HQI_UNFORN" , (cFlow)->UNFORN )      // Unidade Fornecedor 
			oRecord:SetValue( "HQI_NLCIMP" , (cFlow)->NLCIMP )      // Número Licença Importação 
			oRecord:SetValue( "HQI_NCRTCR" , (cFlow)->NCRTCR )      // Número da Carta de Crédito 
			oRecord:SetValue( "HQI_NMADIT" , (cFlow)->NMADIT )      // Número de Adição 
			oRecord:SetValue( "HQI_SQADIT" , (cFlow)->SQADIT )      // Sequência de Adição 
			oRecord:SetValue( "HQI_NATODB" , (cFlow)->NATODB )      // Número Ato Concessório 
			oRecord:SetValue( "HQI_DATA"   , IIf(!Empty(StoD((cFlow)->DATA)),StoD((cFlow)->DATA),DATE_EMPTY) )   // Data de Emissão da Nota Fiscal
			oRecord:SetValue( "HQI_DATADI" , IIf(!Empty(StoD((cFlow)->DATADI)),StoD((cFlow)->DATADI),DATE_EMPTY)) // Data da Declaração de Importação 
			oRecord:SetValue( "HQI_DTPEDC" , IIf(!Empty(StoD((cFlow)->DTPEDC)),StoD((cFlow)->DTPEDC),DATE_EMPTY)) // Data do Pedido de Compra 

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQI_QCOMPR" , (cFlow)->QCOMPR )      // Qtde Comprada 
			oRecord:SetValue( "HQI_QTPESL" , (cFlow)->QTPESL )      // Peso Líquido 
			oRecord:SetValue( "HQI_QTPESB" , (cFlow)->QTPESB )      // Peso Bruto 
			oRecord:SetValue( "HQI_VLIMPI" , BIXValue( (cFlow)->VLIMPI , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl Imposto Importação
			oRecord:SetValue( "HQI_VINCOT" , nVLIncot ) // Vl Incoterm Negociada   
			oRecord:SetValue( "HQI_VCOFIN" , BIXValue( (cFlow)->VCOFIN , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl COFINS
			oRecord:SetValue( "HQI_VDESPE" , BIXValue( (cFlow)->VDESPE , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl Total Despesas 
			oRecord:SetValue( "HQI_VLSEGU" , BIXValue( (cFlow)->VLSEGU , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl Seguro 
			oRecord:SetValue( "HQI_VFRTNF" , BIXValue( (cFlow)->VFRTNF , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl Frete NF 
			oRecord:SetValue( "HQI_VICMSF" , BIXValue( (cFlow)->VICMSF , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl ICMS 
			oRecord:SetValue( "HQI_VIPIFT" , BIXValue( (cFlow)->VIPIFT , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl IPI 
			oRecord:SetValue( "HQI_VPISFT" , BIXValue( (cFlow)->VPISFT , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl PIS 
			oRecord:SetValue( "HQI_VCUSTI" , nVCusti ) // Vl Custo Internado 
			oRecord:SetValue( "HQI_VALIQI" , BIXValue( (cFlow)->VALIQI , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl Aliquota Importação 
			oRecord:SetValue( "HQI_VLCIF"  , BIXValue( (cFlow)->VLCIF  , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl CIF 
			oRecord:SetValue( "HQI_VLCFR"  , BIXValue( (cFlow)->VLCFR  , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl CFR  
			oRecord:SetValue( "HQI_VLTXDI" , BIXValue( (cFlow)->VLTXDI , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl Taxa Declaração 
			oRecord:SetValue( "HQI_VCOMPR" , BIXValue(Round(((cFlow)->W8_PRECO * (cFlow)->W8_QTDE) * (cFlow)->VLTXDI, AVSX3("W9_FOB_TOT", 4))  , 1 , cMoeda, StoD((cFlow)->DATADI)) ) // Vl Comprado 
		
			oRecord:SetValue( "HQI_PARCEL" , 0 )		// Parcela da Ordem de Compra 
			oRecord:SetValue( "HQI_NUMEMB" , " " )   // Número do Embarque 
			oRecord:SetValue( "HQI_EMERG"  , " " )   // Pedido Emergencial 
                                                         
			// Embarque Encerrado 
			If !Empty((cFlow)->EMBENC)
				oRecord:SetValue( "HQI_EMBENC", "S" )
			Else
				oRecord:SetValue( "HQI_EMBENC", "N" )
			EndIf 
			
			If (cFlow)->INCOTR == "FOB"
				oRecord:SetValue( "HQI_VLFOB"  , nVLIncot )	// Vl FOB
				oRecord:SetValue( "HQI_VFOBCI" , nVCusti )	// Vl FOB CI 
			Else
				oRecord:SetValue( "HQI_VLFOB"  , 0) // Vl FOB
				oRecord:SetValue( "HQI_VFOBCI" , 0) // Vl FOB CI 			
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
@since   24/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXImpCompras
	Local cQuery    := ""
	Local cTpDocImp := superGetMV("MV_TDOCIMP",.F., "") //Parâmetro responsável por realizar a extração dos tipos de documento de importação.

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cQuery := "SELECT D1_COD as ITEM, D1_CF as CFOP, D1_TES as TES, D1_FORNECE as FORNEC, D1_LOJA as LOJA, D1_CC as CCUSTO, " 
	cQuery += "	D1_SERIE as D1_SERIE, D1_DOC as NUMDOC, D1_ITEM as SEQINF, D1_UM as UM, D1_CONHEC as NPRIMP, "
	cQuery += "	D1_PEDIDO as ORDEM, D1_EMISSAO as DATA, D1_PESO as QTPESB, D1_TOTAL as VCUSTI, SD1.R_E_C_N_O_ as RECNO_, "
	cQuery += "	A2_GRUPO as GRPFOR, A2_PAIS as A2_PAIS, A2_EST AS A2_EST, A2_COD_MUN AS A2_COD_MUN, A2_BANCO as BCO, "
	cQuery += "	A2_AGENCIA as BCOAGE, A2_NUMCON as BCOCONTA, "
	cQuery += "	ACV_CATEGO as FAMCOM, "
	cQuery += "	B1_TIPO as FAMMAT, B1_GRUPO as GRPEST, "
	cQuery += "	C7_COMPRA as CMPRDR, C7_COND as CONDPG, C7_FABRICA as FORNFB, C7_LOJFABR as LJFORNFB, "
	cQuery += "	F1_TRANSP as TRANSP, "
	cQuery += "	W6_PAISPRO as PAIS, W6_FORNECS as FORNSG, W6_LOJAS as LJFORNSG, W6_HOUSE as CEMBHO, W6_MAWB as CEMBMA, "
	cQuery += "	W6_DI_NUM as DECIMP, W6_DTREG_D as DATADI, W6_DT_ENCE as EMBENC, "
	cQuery += "	WN_SI_NUM as PEDIDO, WN_INVOICE as NUMFAT, WN_ADICAO as NMADIT, WN_SEQ_ADI as SQADIT, WN_IIVAL as VLIMPI, "
	cQuery += "	WN_QUANT as QCOMPR, WN_VLRCOF as VCOFIN, (WN_DESPADU + WN_DESPICM) as VDESPE, WN_SEGURO as VLSEGU, WN_FRETE as VFRTNF, "
	cQuery += "	WN_VALICM as VICMSF, WN_VALIPI as VIPIFT, WN_VLRPIS as VPISFT, WN_PESOL as QTPESL, WN_IITX as VALIQI, "
	cQuery += "	WN_CIF as VLCIF, (WN_FOB_R + WN_FRETE) as VLCFR, "
	cQuery += "	A5_UNID as UNFORN, "
	cQuery += "	Y5_FORNECE as FORNDP, Y5_LOJAF as LJFORNDP, "	
	cQuery += "	W9_INCOTER as INCOTR, W9_TX_FOB as VLTXDI, "
	cQuery += "	SUBSTRING(YQ_COD_DI, 1, 1) as VIATRA, "
	cQuery += "	Y4_FORN as FORNAC, Y4_LOJA as LJFORNAC, "
	cQuery += "	YW_FORN as FORNCS, YW_LOJA as LJFORNCS, "
	cQuery += "	YH_LC_NUM as NCRTCR, "
	cQuery += "	W8_AC as NATODB, W8_FOBTOTR as VINCOT, W8_PRECO as W8_PRECO, W8_QTDE as W8_QTDE, "
	cQuery += "	W2_PO_DT as DTPEDC, "
	cQuery += "	WP_REGIST as NLCIMP "
	cQuery += "FROM	" + RetSqlName("SD1") + " SD1 " 
	cQuery += "LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "	ON ( A2_FILIAL = '" + xFilial("SA2") + "' "
	cQuery += "	AND D1_FORNECE = A2_COD "
	cQuery += "	AND D1_LOJA = A2_LOJA "
	cQuery += "	AND SA2.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("ACV") + " ACV "
	cQuery += "	ON ( ACV_FILIAL = '" + xFilial("ACV") + "' "
	cQuery += "	AND D1_COD = ACV_CODPRO "
	cQuery += "	AND ACV.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "	ON ( B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "	AND D1_COD = B1_COD "
	cQuery += "	AND SB1.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SC7") + " SC7 "
	cQuery += "	ON ( C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += "	AND D1_PEDIDO = C7_NUM "
	cQuery += "	AND D1_ITEMPC = C7_ITEM "
	cQuery += "	AND SC7.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SF1") + " SF1 "
	cQuery += "	ON ( F1_FILIAL = '" + xFilial("SF1") + "' "
	cQuery += "	AND D1_DOC  = F1_DOC "
	cQuery += "	AND D1_SERIE = F1_SERIE "
	cQuery += "	AND D1_FORNECE = F1_FORNECE "
	cQuery += "	AND D1_LOJA = F1_LOJA "
	cQuery += "	AND SF1.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW6") + " SW6 "
	cQuery += "	ON ( W6_FILIAL = '" + xFilial("SW6") + "' "
	cQuery += "	AND D1_CONHEC = W6_HAWB "
	cQuery += "	AND SW6.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SWN") + " SWN "
	cQuery += "	ON ( WN_FILIAL = '" + xFilial("SWN") + "' "
	cQuery += "	AND D1_DOC = WN_DOC "
	cQuery += "	AND D1_SERIE = WN_SERIE "
	cQuery += "	AND D1_FORNECE = WN_FORNECE "
	cQuery += "	AND D1_LOJA = WN_LOJA "
	cQuery += "	AND D1_ITEM = WN_LINHA "
	cQuery += "	AND SWN.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SY5") + " SY5 "
	cQuery += "	ON ( Y5_FILIAL = '" + xFilial("SY5") + "' "
	cQuery += "	AND W6_DESP = Y5_COD "
	cQuery += "	AND SY5.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW9") + " SW9 "
	cQuery += "	ON ( W9_FILIAL = '" + xFilial("SW9") + "' "
	cQuery += "	AND WN_INVOICE = W9_INVOICE "
	cQuery += "	AND SW9.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SYQ") + " SYQ "
	cQuery += "	ON ( YQ_FILIAL = '" + xFilial("SYQ") + "' "
	cQuery += "	AND W6_VIA_TRA = YQ_VIA "
	cQuery += "	AND SYQ.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SY4") + " SY4 "
	cQuery += "	ON ( Y4_FILIAL = '" + xFilial("SY4") + "' "
	cQuery += "	AND W6_AGENTE = Y4_COD "
	cQuery += "	AND SY4.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SYW") + " SYW "
	cQuery += "	ON ( YW_FILIAL = '" + xFilial("SYW") + "' "
	cQuery += "	AND W6_CORRETO = YW_COD "
	cQuery += "	AND SYW.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SYH") + " SYH "
	cQuery += "	ON ( YH_FILIAL = '" + xFilial("SYH") + "' "
	cQuery += "	AND WN_PO_EIC = YH_PO_GI "
	cQuery += "	AND SYH.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW8") + " SW8 "
	cQuery += "	ON ( W8_FILIAL = '" + xFilial("SW8") + "' "
	cQuery += "	AND WN_HAWB = W8_HAWB "
	cQuery += "	AND WN_INVOICE = W8_INVOICE "
	cQuery += "	AND WN_PO_EIC = W8_PO_NUM "
	cQuery += "	AND WN_ITEM = W8_POSICAO "
	cQuery += "	AND WN_PGI_NUM = W8_PGI_NUM "
	cQuery += "	AND SW8.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SW2") + " SW2 "
	cQuery += "	ON ( W2_FILIAL = '" + xFilial("SW2") + "' "
	cQuery += "	AND WN_PO_EIC = W2_PO_NUM "
	cQuery += "	AND SW2.D_E_L_E_T_ = ' ') "
	cQuery += "LEFT JOIN " + RetSqlName("SWP") + " SWP "
	cQuery += "	ON ( WP_FILIAL = '" + xFilial("SWP") + "' "
	cQuery += "	AND W8_PGI_NUM = WP_PGI_NUM "
	cQuery += "	AND W8_SEQ_LI = WP_SEQ_LI "
	cQuery += "	AND SWP.D_E_L_E_T_ = ' ') "     
	cQuery += "LEFT JOIN " + RetSqlName("SA5") + " SA5 "
	cQuery += "	ON ( A5_FILIAL = '" + xFilial("SA5") + "' "
	cQuery += "	AND D1_FORNECE = A5_FORNECE "
	cQuery += "	AND D1_LOJA = A5_LOJA "
	cQuery += "	AND D1_COD = A5_PRODUTO "
	cQuery += "	AND W8_FABR = A5_FABR "
	cQuery += "	AND SA5.D_E_L_E_T_ = ' ') "
	cQuery += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' "
	cQuery += "	AND D1_CONHEC <> ' ' "
	cQuery += "	AND ( D1_TIPO_NF = '1' OR D1_TIPO_NF = '3' OR D1_TIPO_NF = '5' "
	If !EMPTY(cTpDocImp)
		cQuery += " OR D1_TIPO_NF = '"
		cQuery += cTpDocImp + "' "
	EndIf
	cQuery += "	)"
	cQuery += "	AND D1_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	cQuery += "	AND SD1.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Transforma a query em ANSI.
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária.
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ::cFlow := GetNextAlias(), .T., .F.)
Return ::cFlow
