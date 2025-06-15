#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXENTVENDAS.CH"

REGISTER EXTRACTOR HL7 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEntVendas
A tabela fato Entregas de Vendas apresenta informações relacionadas aos processo de entrega
das mercadorias com quantidade de entrega e lead time das entregas.

@author  BI TEAM
@since   03/09/2010
/*/
//-------------------------------------------------------------------
Class BIXEntVendas from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Helio Leal
@since   17/01/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXEntVendas
	_Super:New( FACT, "HL7", STR0001, "SC9", { COMERCIAL } ) // "Entregas de Vendas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   15/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXEntVendas
	Local oModel := BIXModel():Build( Self )
	 
	oModel:AddField( "HL7_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HL7_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL7_PRDUTO",	"C",	32, 00, .T., "HJ3" ) //"Produto"
	oModel:AddField( "HL7_CANALV",	"C", 	32, 00, .T., "HGA" ) //"Canal de Vendas"
	oModel:AddField( "HL7_REFER",	"C",	32, 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HL7_ROTA",	"C",	32, 00, .T., "HGI" ) //"Rota"
	oModel:AddField( "HL7_REPRES",	"C", 	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HL7_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HL7_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HL7_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL7_MICREG",	"C", 	32, 00, .T., "HGB" ) //"Microregião"
	oModel:AddField( "HL7_TRARED",	"C",	32, 00, .T., "HJ2" ) //"Transportadora de Redespacho"

	oModel:AddField( "HL7_REGIAO",	"C",	32, 00, .T., "HJB" ) //"Região"
	oModel:AddField( "HL7_FAMCOM",	"C",	32, 00, .T., "HG1" ) //"Família Comercial"	
	oModel:AddField( "HL7_CLIENT",	"C", 	32, 00, .T., "HJ7" ) //"Cliente"
	oModel:AddField( "HL7_TRANSP",	"C", 	32, 00, .T., "HJ2" ) //"Transportadora"
	oModel:AddField( "HL7_ITEM",	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HL7_GRPEST",	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HL7_CONDPG",	"C", 	32, 00, .T., "HJA" ) //"Condição de Pagamento"
	oModel:AddField( "HL7_REGCOM",	"C", 	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL7_NATOPR",	"C",	32, 00, .T., "HJ9" ) //"Natureza da Operação"
	oModel:AddField( "HL7_UNITEM" ,	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HL7_CFOP",	"C",	32, 00, .T., "HG0" ) //"CFOP"
	oModel:AddField( "HL7_FAMMAT",	"C",	32, 00, .T., "HG2" ) //"Famíalia Material"	

	oModel:AddField( "HL7_DATA"   	, "D", 08, 0 ) // Data Entrega
	oModel:AddField( "HL7_DTIMPL"   , "D", 08, 0 ) // Data Implantação
	oModel:AddField( "HL7_DTVEND"   , "D", 08, 0 ) // Data Venda
	oModel:AddField( "HL7_DTFATU"   , "D", 08, 0 ) // Dt Emissão NF
	oModel:AddField( "HL7_QNRENT"   , "N", 04, 0 ) // Nr Entregas
	oModel:AddField( "HL7_QLEADT"   , "N", 04, 0 ) // Lead Time En
	oModel:AddField( "HL7_QDSATR"   , "N", 04, 0 ) // Dias Atraso
	oModel:AddField( "HL7_QDSANT"   , "N", 04, 0 ) // Dias Antecip
	oModel:AddField( "HL7_QDEMIP"   , "N", 04, 0 ) // LD TM Emiss
	oModel:AddField( "HL7_NMPRIO"   , "N", 04, 0 ) // Priorida Ped
	oModel:AddField( "HL7_PEDIDO"   , "C", 12, 0 ) // Número do Pedido
	oModel:AddField( "HL7_SERNF"   	, "C", 08, 0 ) // Serie NF
	oModel:AddField( "HL7_NUMNF"   	, "C", 35, 0 ) // Num. NF
	oModel:AddField( "HL7_NMITEN"   , "C", 10, 0 ) // N·m do Item
	oModel:AddField( "HL7_STPEDV"   , "C", 20, 0 ) // Situação Pedido
	oModel:AddField( "HL7_STITPV"   , "C", 20, 0 ) // Situação Item Pedido
	oModel:AddField( "HL7_TPCPIT"   , "C", 20, 0 ) // Tipo de Item

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
@since   15/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXEntVendas
	Local aMoeda 		:= {}  
	Local lRepres 	:= .F.
	Local cMoeda		:= ""
	Local dD2Emissao	:= ""
	Local dDataEnt	:= ""
	Local nMoeda    	:= 1
	Local cStiTPV		:= ""
	Local cStPedV		:= ""
	Local nQLEADT		:= 0
	Local nQDSANT 	:= 0
	Local nQDSATR 	:= 0
		
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//-------------------------------------------------------------------  	
	aMoeda 	:= BIXGetMxF( ::cEntity )
	oRegion	:= BIXRegiao():New()
	lRepres	:= LoadRepres() //Define a utilização do representante pelo cadastro do cliente.
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While (cFlow)->(! EoF() )
		cStiTPV	:= ""
		cStPedV	:= ""
		nQLEADT := 0
		nQDSANT := 0
		nQDSATR := 0
		dD2Emissao := ""
		dDataEnt := ""
		
		If (Empty((cFlow)->C6_ENTREG) .AND. Empty((cFlow)->F2_DTENTR)) .OR.;
		   !(((DtoS((cFlow)->C6_ENTREG) >= cFrom) .AND.(DtoS((cFlow)->C6_ENTREG) <= cTo)) .OR. ;
		   	((DtoS((cFlow)->F2_DTENTR) >= cFrom) .AND.(DtoS((cFlow)->F2_DTENTR) <= cTo)))
    	 		(cFlow)->(DbSkip())
     			Loop                
	   	EndIf

	 	//-------------------------------------------------------------------
		// Determina a Situação do Pedido  
		//-------------------------------------------------------------------
		Do Case
			Case Empty((cFlow)->C9_BLEST) .And. Empty((cFlow)->C9_BLCRED) .And. Empty((cFlow)->C9_BLTMS) .And. (Empty((cFlow)->C9_BLWMS) .Or. (cFlow)->C9_BLWMS >= '5')  
				cStiTPV := STR0002 // "Liberado" 
			Case ((cFlow)->C9_BLCRED == '10' .Or. (cFlow)->C9_BLCRED == 'ZZ') .And. ((cFlow)->C9_BLEST == '10' .Or. (cFlow)->C9_BLEST == 'ZZ') 
				cStiTPV := STR0003 // "Faturado"
			Case !Empty((cFlow)->C9_BLCRED) .And. ((cFlow)->C9_BLCRED <> '09' .Or. (cFlow)->C9_BLCRED <> '10' .Or. (cFlow)->C9_BLCRED <> 'ZZ') 
				cStiTPV := STR0004 // "Bloq. por Crédito"        
			Case !Empty((cFlow)->C9_BLEST) .And. ((cFlow)->C9_BLEST  <> '09' .Or. (cFlow)->C9_BLEST == '10' .Or. (cFlow)->C9_BLEST == 'ZZ') 
				cStiTPV := STR0005 // "Bloq. por Estoque" 
			Case !Empty((cFlow)->C9_BLWMS) .And. ((cFlow)->C9_BLWMS <= '5')     
				cStiTPV := STR0006 // "Bloq. por WMS"
			Case !Empty((cFlow)->C9_BLTMS)	
				cStiTPV := STR0007 // "Bloq. por TMS"
			Case (cFlow)->C9_BLCRED == '09'	
				cStiTPV := STR0007 // "Bloq. por TMS"
		EndCase
					
		//-------------------------------------------------------------------
		// Determina o Status do Pedido  
		//-------------------------------------------------------------------
		Do Case
		Case Empty((cFlow)->C5_LIBEROK) .And. Empty((cFlow)->C5_NOTA) .And. Empty((cFlow)->C5_BLQ)
			cStPedV := STR0008 // "Aberto"
		Case !Empty((cFlow)->C5_NOTA) .Or. ((cFlow)->C5_LIBEROK == 'E') .And. Empty((cFlow)->C5_BLQ)
			cStPedV := STR0009 // "Encerrado"							 	
		Case !Empty((cFlow)->C5_LIBEROK) .And. Empty((cFlow)->C5_NOTA) .And. Empty((cFlow)->C5_BLQ)
			cStPedV := STR0002 // "Liberado"
		Case ((cFlow)->C5_BLQ == '1')
			cStPedV := STR0010 // "Bloqueado por Regra"					 	
		Case ((cFlow)->C5_BLQ == '2')
			cStPedV := STR0011 // "Bloqueado por Verba"
		EndCase           
						
		//-------------------------------------------------------------------
		// Determina a Data da Entrega 
		//-------------------------------------------------------------------
		Do Case
		Case !Empty((cFlow)->F2_DTENTR)
			dDataEnt := (cFlow)->F2_DTENTR 
		Case !Empty((cFlow)->C6_ENTREG)
			dDataEnt := (cFlow)->C6_ENTREG			
		EndCase

		dD2Emissao := (cFlow)->F2_EMISSAO 
		If !Empty(dD2Emissao)
			//Lead Time Entrega
			If !Empty((cFlow)->C5_EMISSAO)
				If dD2Emissao > (cFlow)->C5_EMISSAO
					nQLEADT := dD2Emissao - (cFlow)->C5_EMISSAO
				Else
					nQLEADT := 0
				EndIf
				
				If !Empty(dDataEnt)
					If dDataEnt > dD2Emissao
						//Dias Antecipação
						nQDSANT := dDataEnt - dD2Emissao
						nQDSATR := 0		
					Else
						//Dias Atraso
						nQDSATR := dD2Emissao - dDataEnt
						nQDSANT := 0
					EndIf
				EndIf 
			EndIf
		EndIf 		
					
		For nMoeda := 1 To Len(aMoeda)
			cMoeda := aMoeda[nMoeda][1]
	
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "C9_PEDIDO"	, (cFlow)->C9_PEDIDO )
			oRecord:SetValue( "C9_ITEM"		, (cFlow)->C9_ITEM )  
			oRecord:SetValue( "C9_SEQUEN"	, (cFlow)->C9_SEQUEN )
			oRecord:SetValue( "C9_PRODUTO"	, (cFlow)->C9_PRODUTO )  
			oRecord:SetValue( "B1_COD"		, (cFlow)->C9_PRODUTO ) 
			oRecord:SetValue( "ACU_COD"		, (cFlow)->ACV_CATEGO )			
			oRecord:SetValue( "BM_GRUPO"	, (cFlow)->C9_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cFlow)->C6_UM )			
			oRecord:SetValue( "F4_CODIGO"	, (cFlow)->C6_TES )
			oRecord:SetValue( "A1_COD"		, (cFlow)->C9_CLIENTE )
			oRecord:SetValue( "A1_LOJA"		, (cFlow)->C9_LOJA )	
			oRecord:SetValue( "A3_COD"		, iIf( lRepres, (cFlow)->A1_VEND  , (cFlow)->C5_VEND1 ) )
			oRecord:SetValue( "A4_COD"		, (cFlow)->C5_TRANSP )
			oRecord:SetValue( "E4_CODIGO"	, (cFlow)->C5_CONDPAG )			
			oRecord:SetValue( "ACY_GRPVEN"	, (cFlow)->A1_GRPVEN )					
	
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HL7_EMPRES"   , oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )  
			oRecord:SetValue( "HL7_ESTABL"   , oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )  
			oRecord:SetValue( "HL7_REPRES"   , oSeeker:Seek( "HJC", { iIf( lRepres, (cFlow)->A1_VEND  , (cFlow)->C5_VEND1 ) } ) ) 
			oRecord:SetValue( "HL7_GRPCLI"   , oSeeker:Seek( "HJ0", { (cFlow)->A1_TIPO } ) ) 
			oRecord:SetValue( "HL7_UNDNEG"   , oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) ) 
			oRecord:SetValue( "HL7_MOEDA"    , oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) ) 
			oRecord:SetValue( "HL7_MICREG"   , oSeeker:Seek( "HGB", { (cFlow)->A1_REGIAO } ) ) 
			oRecord:SetValue( "HL7_TRARED"   , oSeeker:Seek( "HJ2", { (cFlow)->C5_REDESP } ) )
			oRecord:SetValue( "HL7_REGIAO"   , oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A1_EST, (cFlow)->A1_COD_MUN, (cFlow)->A1_PAIS ) } ) )
			oRecord:SetValue( "HL7_FAMCOM"   , oSeeker:Seek( "HG2", { (cFlow)->ACV_CATEGO } ) )
			oRecord:SetValue( "HL7_CLIENT"   , oSeeker:Seek( "HJ7", { (cFlow)->C9_CLIENTE, (cFlow)->C9_LOJA } ) )
			oRecord:SetValue( "HL7_TRANSP"   , oSeeker:Seek( "HJ2", { (cFlow)->C5_TRANSP } ) )
			oRecord:SetValue( "HL7_ITEM"   	 , oSeeker:Seek( "HJ8", { (cFlow)->C9_PRODUTO } ) )
			oRecord:SetValue( "HL7_GRPEST"   , oSeeker:Seek( "HG3", { (cFlow)->C9_GRUPO } ) ) 
			oRecord:SetValue( "HL7_CONDPG"   , oSeeker:Seek( "HJA", { (cFlow)->C5_CONDPAG } ) )
			oRecord:SetValue( "HL7_REGCOM"   , oSeeker:Seek( "HGD", { (cFlow)->A1_GRPVEN } ) )
			oRecord:SetValue( "HL7_NATOPR"   , oSeeker:Seek( "HJ9", { (cFlow)->C6_TES } ) )
			oRecord:SetValue( "HL7_UNITEM"   , oSeeker:Seek( "HHW", { (cFlow)->C6_UM } ) ) 
			oRecord:SetValue( "HL7_CFOP"   	 , oSeeker:Seek( "HG0", { (cFlow)->F4_CF } ) )
			oRecord:SetValue( "HL7_FAMMAT"   , oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) ) 
			oRecord:SetValue( "HL7_PRDUTO"   , oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
			oRecord:SetValue( "HL7_CANALV"   , oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
			oRecord:SetValue( "HL7_REFER"    , oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
			oRecord:SetValue( "HL7_ROTA"   	 , oSeeker:oKey:GetKey( { UNDEFINED } ) ) 

			//-------------------------------------------------------------------
			// Datas.
			//-------------------------------------------------------------------  			
			oRecord:SetValue( "HL7_DATA"   	 , dDataEnt ) 
			oRecord:SetValue( "HL7_DTIMPL"   , IIf(!Empty((cFlow)->C5_EMISSAO),(cFlow)->C5_EMISSAO, STOD('18000101') ) )
			oRecord:SetValue( "HL7_DTVEND"   , IIf(!Empty((cFlow)->C5_EMISSAO),(cFlow)->C5_EMISSAO, STOD('18000101') ) )
			oRecord:SetValue( "HL7_DTFATU"   , IIf(!Empty((cFlow)->F2_EMISSAO),(cFlow)->F2_EMISSAO, STOD('18000101') ) )

			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HL7_PEDIDO"   , (cFlow)->C9_PEDIDO )
			oRecord:SetValue( "HL7_SERNF"    , SerieNFID( cFlow, 2, "C9_SERIENF") )
			oRecord:SetValue( "HL7_NUMNF"    , (cFlow)->C9_NFISCAL )
			oRecord:SetValue( "HL7_NMITEN"   , (cFlow)->C9_ITEM + (cFlow)->C9_SEQUEN )
			oRecord:SetValue( "HL7_STPEDV"   , cStPedV ) 
			oRecord:SetValue( "HL7_STITPV"   , cStiTPV ) 
			oRecord:SetValue( "HL7_TPCPIT"   , " " )

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HL7_QNRENT"   , 1 )
			oRecord:SetValue( "HL7_QLEADT"   , nQLEADT ) 
			oRecord:SetValue( "HL7_QDSATR"   , nQDSATR ) 
			oRecord:SetValue( "HL7_QDSANT"   , nQDSANT ) 
			oRecord:SetValue( "HL7_QDEMIP"   , 0 )
			oRecord:SetValue( "HL7_NMPRIO"   , 0 )

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda		   			
		(cFlow)->( DbSkip() )	
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
@since   15/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXEntVendas
	Local nInterval	:= BIXParInfo( "BIX_EVENDA", "N", 2 )
	Local cBeginDate	:= ""    
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Define o período em que os pedidos liberados serão considerados.  
	//-------------------------------------------------------------------	
	cBeginDate	:= DToS( SToD( cFrom ) - ( nBIVal( nInterval ) * ( 30 ) ) )  	
				
	cDML := "SELECT SC9.C9_PEDIDO, SC9.C9_SERIENF, SC9.C9_NFISCAL, SC9.C9_ITEM, SC9.C9_SEQUEN, " 
	cDML += "	SC9.C9_PRODUTO, SC9.C9_GRUPO, SC9.C9_CLIENTE, SC9.C9_LOJA, SC9.C9_BLEST, SC9.C9_BLCRED," 
	
	//-------------------------------------------------------------------
	// Verifica a existência do campo C9_BLTMS. 
	//-------------------------------------------------------------------  
	If ! ( SC9->(FieldPos("C9_BLTMS")) == 0 )
		cDML += "  SC9.C9_BLTMS," 
	EndIf 
	
	//-------------------------------------------------------------------
	// Verifica a existência do campo C9_BLWMS. 
	//-------------------------------------------------------------------  	
	If ! ( SC9->(FieldPos("C9_BLWMS")) == 0 )	
		cDML += "   SC9.C9_BLWMS," 
	EndIf
	
	cDML += "	SC9.R_E_C_N_O_ ID," 
	cDML += "   SC5.C5_VEND1, SC5.C5_TRANSP, SC5.C5_CONDPAG, SC5.C5_LIBEROK, "
	cDML += "   SC5.C5_NOTA, SC5.C5_BLQ, SC5.C5_REDESP, SC5.C5_EMISSAO, "
	cDML += "   SC6.C6_NUM, SC6.C6_TES, SC6.C6_ENTREG, SC6.C6_UM, "  
	cDML += "	SF2.F2_DTENTR, SF2.F2_EMISSAO, SF4.F4_CF, SA1.A1_VEND, SA1.A1_TIPO, "
	cDML += "	SA1.A1_REGIAO, SA1.A1_EST, SA1.A1_COD_MUN, SA1.A1_PAIS, SA1.A1_GRPVEN, "
	cDML += "	SB1.B1_TIPO, ACV.ACV_CATEGO "
	cDML += "FROM " + RetSqlName("SC9") + " SC9 " 
	cDML += "INNER JOIN " + RetSqlName("SC5") + " SC5 " 
	cDML += " 	ON ( SC5.C5_FILIAL = '" + xFilial("SC5") + "'  AND SC5.C5_NUM = SC9.C9_PEDIDO " 
	cDML += "   AND SC5.C5_TIPO = 'N' AND SC5.D_E_L_E_T_ = ' ' ) " 
	cDML += "INNER JOIN " + RetSqlName("SC6") + " SC6 " 
	cDML += " 	ON ( SC6.C6_FILIAL = '" + xFilial("SC6") + "' AND SC6.C6_NUM = SC9.C9_PEDIDO " 
	cDML += "   AND SC6.C6_ITEM = SC9.C9_ITEM AND SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC6.D_E_L_E_T_ = ' ' ) " 
	cDML += "LEFT JOIN " + RetSQLName("SF2") + " SF2 "
	cDML += "	ON (F2_FILIAL = '" + xFilial("SF2") + "' AND F2_DOC = C9_NFISCAL "
	cDML += "   AND F2_SERIE = C9_SERIENF AND F2_CLIENTE = C9_CLIENTE AND F2_LOJA = C9_LOJA "
	cDML += "   AND SF2.D_E_L_E_T_ = ' ') "									
	cDML += "LEFT JOIN " + RetSQLName("SF4") + " SF4 "
	cDML += "	ON (F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = C6_TES "
	cDML += "   AND SF4.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("SA1") + " SA1 "
	cDML += "	ON (A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C9_CLIENTE "
	cDML += "   AND A1_LOJA = C9_LOJA AND SA1.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cDML += "	ON (ACV_FILIAL = '" + xFilial("ACV") + "' AND ACV_CODPRO = C6_PRODUTO "
	cDML += "   AND ACV.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("SB1") + " SB1 "
	cDML += "	ON (B1_FILIAL = '" +	 xFilial("SB1") + "' AND B1_COD = C9_PRODUTO "
	cDML += "   AND SB1.D_E_L_E_T_ = ' ') "
	cDML += "WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' " 
	cDML += "	AND SC9.C9_DATALIB BETWEEN '" + cBeginDate + "' AND '" + cTo + "' "
	cDML += "   AND SC9.D_E_L_E_T_ = ' '" 

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  		
	cDML := ChangeQuery( cDML )

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//------------------------------------------------------------------- 	
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)       	

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TCSetField( ::cFlow, "C5_EMISSAO", "D", 8, 0 )
	TCSetField( ::cFlow, "C6_ENTREG", "D", 8, 0 )
	TCSetField( ::cFlow, "F2_DTENTR", "D", 8, 0 )
	TCSetField( ::cFlow, "F2_EMISSAO", "D", 8, 0 )
Return ::cFlow 
