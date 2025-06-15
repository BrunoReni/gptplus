#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOTASVENDAS.CH"

REGISTER EXTRACTOR HL5 

Static cAliasSC9 := RetSqlName("SC9")
Static cAliasSC5 := RetSqlName("SC5")
Static cAliasSC6 := RetSqlName("SC6")
Static cFilSC9 := xFilial("SC9")
Static cFilSC5 := xFilial("SC5")
Static cFilSC6 := xFilial("SC6")

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCotasVendas
Classe do extrator para a tabela fato Cotas de Vendas.

@author  BI TEAM
@since   02/09/2010
/*/
//-------------------------------------------------------------------
Class BIXCotasVendas From BIXEntity
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCotasVendas
	_Super:New( FACT, "HL5", STR0001, "SCT", { COMERCIAL } ) // "Cotas Vendas" 
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCotasVendas 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HL5_EMPRES",	"C",	32,	00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HL5_ESTABL",	"C",	32,	00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL5_REPRES",	"C",	32, 00, .T., "HJC" ) //"Representante
	oModel:AddField( "HL5_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Clientes"
	oModel:AddField( "HL5_CLIENT",	"C",	32, 00, .T., "HJ7" ) //"Clientes"
	oModel:AddField( "HL5_MOEDA",	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL5_REGIAO",	"C",	32,	00, .T., "HJB" ) //"Região"
	oModel:AddField( "HL5_ITEM",	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HL5_FAMCOM",	"C",	32, 00, .T., "HG1" ) //"Família Comercial"
	oModel:AddField( "HL5_FAMMAT",	"C",	32, 00, .T., "HG2" ) //"Família Material"
	oModel:AddField( "HL5_GRPEST",	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HL5_PRDUTO",	"C",	32, 00, .T., "HJ3" ) //"Produto
	oModel:AddField( "HL5_REGCOM",	"C",	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL5_MICREG",	"C",	32, 00, .T., "HGB" ) //"Microrregião"
	oModel:AddField( "HL5_CANALV",	"C",	32, 00, .T., "HGA" ) //"Canal Vendas"
	oModel:AddField( "HL5_REFER",	"C",	32, 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HL5_UNITEM",	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"
	
	oModel:AddField( "HL5_DATA",	"D",	08,	00 )
	oModel:AddField( "HL5_QUOTID",	"C",	12,	00 )
	oModel:AddField( "HL5_VCOTAP",	"N",	16, 04 )
	oModel:AddField( "HL5_VCOTRP",	"N",	16,	04 )
	oModel:AddField( "HL5_VCOTRF",	"N",	16,	04 )
	oModel:AddField( "HL5_VPRCMP",	"N",	16,	04 )
	oModel:AddField( "HL5_VCOTCP",	"N",	16,	04 )
	oModel:AddField( "HL5_VCOTCF",	"N",	16,	04 )
	oModel:AddField( "HL5_VCOSUS",	"N",	16,	04 )
	oModel:AddField( "HL5_VCOREP" ,	"N",	16,	04 )

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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCotasVendas
	Local aMoedas	:= {}
	Local cMoeda  := "" 
	Local nMoeda  := 0
	Local nVCotRp := 0
	Local nVCotRf := 0
	Local nVlrTmp	:= 0
	Local nVCoSus	:= 0

	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 
	aMoedas	:= BIXGetMxF(::cEntity)
		
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While (cFlow)->(! EoF() )
		nVCotRp := FtPdVendas(2, (cFlow)->CT_VEND, (cFlow)->CT_DATA, (cFlow)->CT_DATA, (cFlow)->CT_TIPO, ;
										   (cFlow)->CT_GRUPO, (cFlow)->CT_PRODUTO, 1, "", "", "")

		nVCotRf := FtNfVendas(2, (cFlow)->CT_VEND, (cFlow)->CT_DATA, (cFlow)->CT_DATA, "", (cFlow)->CT_TIPO, ;
										   (cFlow)->CT_GRUPO, (cFlow)->CT_PRODUTO, 1, "", "", "", "")
										   
		nVlrTmp := (cFlow)->CT_VALOR / (cFlow)->CT_QUANT
	
		nVCoSus := BIXCotSusp( (cFlow)->CT_PRODUTO , (cFlow)->CT_DATA , (cFlow)->CT_VEND )

		For nMoeda := 1 to Len(aMoedas)
			cMoeda := aMoedas[nMoeda][1]

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "CT_DOC"	 , (cFlow)->CT_DOC )
			oRecord:SetValue( "CT_SEQUEN", (cFlow)->CT_SEQUEN )
			oRecord:SetValue( "A3_COD"	 , (cFlow)->CT_VEND )
			oRecord:SetValue( "B1_COD"	 , (cFlow)->CT_PRODUTO )
			oRecord:SetValue( "ACU_COD"	 , (cFlow)->CT_CATEGO )
			oRecord:SetValue( "BM_GRUPO" , (cFlow)->CT_GRUPO )
			oRecord:SetValue( "AH_UNIMED", (cFlow)->B1_UM )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HL5_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HL5_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HL5_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) )
			oRecord:SetValue( "HL5_REPRES" 	, oSeeker:Seek( "HJC", { (cFlow)->CT_VEND  } ) ) 	
			oRecord:SetValue( "HL5_ITEM"	, oSeeker:Seek( "HJ8", { (cFlow)->CT_PRODUTO } ) ) 	
			oRecord:SetValue( "HL5_FAMCOM"  , oSeeker:Seek( "HG1", { (cFlow)->CT_CATEGO } ) ) 	
			oRecord:SetValue( "HL5_FAMMAT"	, oSeeker:Seek( "HG2", { (cFlow)->CT_TIPO } ) ) 	
			oRecord:SetValue( "HL5_GRPEST"	, oSeeker:Seek( "HG3", { (cFlow)->CT_GRUPO } ) ) 	
			oRecord:SetValue( "HL5_UNITEM" 	, oSeeker:Seek( "HHW", { (cFlow)->B1_UM } ) ) 	
			oRecord:SetValue( "HL5_PRDUTO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 	
			oRecord:SetValue( "HL5_GRPCLI" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 	
			oRecord:SetValue( "HL5_CLIENT" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 	
			oRecord:SetValue( "HL5_REGIAO" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 	
			oRecord:SetValue( "HL5_MICREG" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) ) 	
			oRecord:SetValue( "HL5_REFER" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL5_CANALV" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL5_REGCOM" 	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL5_QUOTID" 	, (cFlow)->CT_DOC + (cFlow)->CT_SEQUEN )
			oRecord:SetValue( "HL5_DATA" 	, IIf(!Empty( (cFlow)->CT_DATA), (cFlow)->CT_DATA, DATE_EMPTY) ) 	
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 	
			oRecord:SetValue( "HL5_VCOTAP"	, (cFlow)->CT_QUANT )	
			oRecord:SetValue( "HL5_VCOTRP"	, BIXValue( nVCotRp	, 1, cMoeda, (cFlow)->CT_DATA ) )	
			oRecord:SetValue( "HL5_VCOTRF"	, BIXValue( nVCotRf, 1, cMoeda, (cFlow)->CT_DATA ) )	
			oRecord:SetValue( "HL5_VPRCMP"	, BIXValue( nVlrTmp, (cFlow)->CT_MOEDA, cMoeda, (cFlow)->CT_DATA ) )	
			oRecord:SetValue( "HL5_VCOSUS"	, nVCoSus )	
			oRecord:SetValue( "HL5_VCOTCP"	, 0 )	
			oRecord:SetValue( "HL5_VCOTCF"	, 0 )	
			oRecord:SetValue( "HL5_VCOREP"	, 0 )

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
			
		Next nInd	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCotasVendas
	Local cDML	:= ""

	cDML := "SELECT CT_DOC, CT_SEQUEN, CT_DATA, CT_QUANT, CT_VEND, CT_TIPO, " + ;
		"CT_GRUPO, CT_PRODUTO, CT_CATEGO, CT_VALOR, CT_MOEDA, B1_UM " + ;
		"FROM " + RetSqlName("SCT") + " SCT " + ;
		"LEFT JOIN " + RetSQLName("SB1") + " SB1 " + ;
		"ON B1_FILIAL = '" + xFilial("SB1") + "' " + ;
			"AND B1_COD = CT_PRODUTO " + ;
			"AND SB1.D_E_L_E_T_= ' ' " + ;
		"WHERE CT_FILIAL = '" + xFilial("SCT") + "' " + ;
			"AND CT_DATA BETWEEN '" + cFrom + "' AND '" + cTo + "' " + ;
			"AND SCT.D_E_L_E_T_ = ' '"
	
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )
	
	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cDML ), ::cFlow := GetNextAlias() , .T., .F. )

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "CT_DATA", "D", 8, 0 )
Return ::cFlow

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCotSusp
Efetua o cálculos das cotas suspensas.

@return nValor, Valor da cotas suspensas. 

@author  Marcia Junko
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Static Function BIXCotSusp( cProduto , dDataLib , cVendedor )
	Local cQuery    := ""       
	Local aArea     := GetArea()
	Local cAliasTMP := "BIXCOTSUSPAUX"
	Local nValor    := 0

	cQuery := "SELECT SUM(C6_QTDVEN - C6_QTDEMP - C6_QTDENT) VAL_TOT "
	cQuery += "FROM " + cAliasSC9 + " SC9 "
	cQuery += "INNER JOIN " + cAliasSC5 + " SC5 "
	cQuery += "ON (SC5.C5_FILIAL = '" + cFilSC5 + "' AND "
	cQuery += "   SC5.C5_NUM = SC9.C9_PEDIDO AND "
	cQuery += "   SC5.C5_VEND1 = '" + cVendedor + "' AND "
	cQuery += "   SC5.D_E_L_E_T_  = ' ' ) "
	cQuery += "INNER JOIN " + cAliasSC6 + " SC6 "
	cQuery += "ON (SC6.C6_FILIAL = '" + cFilSC6 + "' AND "
	cQuery += "   SC6.C6_NUM = SC9.C9_PEDIDO AND "
	cQuery += "   SC6.C6_ITEM = SC9.C9_ITEM AND "
	cQuery += "   SC6.C6_PRODUTO = '" + cProduto + "' AND "
	cQuery += "   SC6.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE SC9.C9_FILIAL = '" + cFilSC9 + "' AND "
	cQuery += "   SC9.C9_DATALIB = '" + DtoS(dDataLib) + "' AND "
	cQuery += "   ( (SC9.C9_BLCRED IS NOT NULL AND SC9.C9_BLCRED NOT IN ('09','10','ZZ')) OR "
	cQuery += "   (SC9.C9_BLEST  IS NOT NULL AND SC9.C9_BLEST  NOT IN ('09','10','ZZ')) OR "
	cQuery += "   (SC9.C9_BLWMS  IS NOT NULL AND SC9.C9_BLWMS  IN ('05','04','03', '02', '01')) OR "
	cQuery += "	(SC9.C9_BLTMS <> '' ) ) AND SC9.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTMP, .T., .T.)      

	nValor := (cAliasTMP)->VAL_TOT
	
	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
Return nValor 
