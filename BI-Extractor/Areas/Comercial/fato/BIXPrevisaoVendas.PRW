#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPREVISAOVENDAS.CH"

REGISTER EXTRACTOR HL1

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPrevisaoVendas
Fato Previsão de Vendas

@author  Tamara Clemente
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Class BIXPrevisaoVendas from BIXEntity
	Method New() CONSTRUCTOR
	Method Model()
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara Clemente
@since   03/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXPrevisaoVendas
	_Super:New( FACT, "HL1", STR0001, "SC4", { COMERCIAL } ) //"Previsão de Vendas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/09/2015
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPrevisaoVendas 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HL1_EMPRES",	"C",	32, 00, .T., "HJ4" ) //"Empresa"	
	oModel:AddField( "HL1_ESTABL",	"C",	32, 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HL1_UNDNEG",	"C",	32, 00, .T., "HJ1" ) //"Unidade de Negócio"
	oModel:AddField( "HL1_MOEDA" ,	"C",	32, 00, .T., "HJ6" ) //"Moeda"
	oModel:AddField( "HL1_FAMCOM",	"C",	32, 00, .T., "HG1" ) //"Família Comercial"	
	oModel:AddField( "HL1_ITEM",	"C",	32, 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HL1_GRPEST",	"C",	32, 00, .T., "HG3" ) //"Grupo de Estoque"
	oModel:AddField( "HL1_UNITEM" ,	"C",	32, 00, .T., "HHW" ) //"Unidade de Medida do Item"
	oModel:AddField( "HL1_FAMMAT",	"C",	32, 00, .T., "HG2" ) //"Famíalia Material"	
	oModel:AddField( "HL1_MICREG",	"C",	32, 00, .T., "HGB" ) //"MIcrorregião"
	oModel:AddField( "HL1_GRPCLI",	"C",	32, 00, .T., "HJ0" ) //"Grupo de Cliente"
	oModel:AddField( "HL1_REPRES",	"C",	32, 00, .T., "HJC" ) //"Representante"
	oModel:AddField( "HL1_PRDUTO",	"C",	32, 00, .T., "HJ3" ) //"Produto"
	oModel:AddField( "HL1_REFER",	"C",	32, 00, .T., "HJH" ) //"Referência"
	oModel:AddField( "HL1_REGCOM",	"C",	32, 00, .T., "HGD" ) //"Região Comercial"
	oModel:AddField( "HL1_DATA",	"D",	08, 00,	.F., "HK2" ) //"Período"
	
	oModel:AddField( "HL1_VPREVI",	"N",	16,	02 ) //Valor Previsto
	oModel:AddField( "HL1_QPREVI",	"N",	16,	04 ) //Quantidade Prevista
	oModel:AddField( "HL1_QPREFC",	"N",	16,	04 ) //Quantidade Prevista Família Comercial
	oModel:AddField( "HL1_QPREFM",	"N",	16,	04 ) //Quantidade Prevista Família Material
	oModel:AddField( "HL1_NUMPRV",	"C",	20, 00 ) //Número da Previsão 
		
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

@author  Tamara Clemente
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPrevisaoVendas
	Local aMoeda 	:= {}
	Local cMoeda	:= ""
	Local cFlow		:= ""
	Local nMoeda	:= 0 
	
	//-------------------------------------------------------------------
	// Recupera os parâmetros da fato. 
	//------------------------------------------------------------------- 	
	aMoeda 	  := BIXGetMxF( ::cEntity )
	
	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 

	While ! (cFlow)->( Eof() ) 
		For nMoeda := 1 to Len( aMoeda )
			cMoeda := aMoeda[nMoeda][1]
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "C4_PRODUTO"	, (cFlow)->C4_PRODUTO ) 
			oRecord:SetValue( "C4_DATA"		, (cFlow)->C4_DATA ) 
			oRecord:SetValue( "ACU_COD"		, (cFlow)->ACV_CATEGO )
			oRecord:SetValue( "B1_COD"		, (cFlow)->C4_PRODUTO )
			oRecord:SetValue( "BM_GRUPO"	, (cFlow)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cFlow)->B1_UM )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HL1_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HL1_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HL1_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HL1_MOEDA" 	, oSeeker:Seek( "HJ6", { aMoeda[nMoeda][2] } ) )
			oRecord:SetValue( "HL1_FAMCOM"	, oSeeker:Seek( "HG1", { (cFlow)->ACV_CATEGO } ) )			
			oRecord:SetValue( "HL1_ITEM"	, oSeeker:Seek( "HJ8", { (cFlow)->C4_PRODUTO } ) )
 			oRecord:SetValue( "HL1_GRPEST"	, oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) )
 			oRecord:SetValue( "HL1_UNITEM"	, oSeeker:Seek( "HHW", { (cFlow)->B1_UM } ) )
 			oRecord:SetValue( "HL1_FAMMAT"	, oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) )
 			oRecord:SetValue( "HL1_MICREG"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL1_GRPCLI"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL1_REPRES"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL1_PRDUTO"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL1_REFER"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
 			oRecord:SetValue( "HL1_REGCOM"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HL1_DATA"	, (cFlow)->C4_DATA )	
			
			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HL1_NUMPRV"	, " " )			 	
		
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HL1_VPREVI"	, BIXValue((cFlow)->C4_VALOR, 1, cMoeda, (cFlow)->C4_DATA ))
			oRecord:SetValue( "HL1_QPREVI"	, (cFlow)->C4_QUANT )
			oRecord:SetValue( "HL1_QPREFC"	, 0)
			oRecord:SetValue( "HL1_QPREFM"	, 0)
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda	
		
		(cFlow)->( DBSkip() )
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
@since   22/07/2014
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXPrevisaoVendas
	Local cDML 		:= ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cDML := "SELECT C4_PRODUTO, C4_DOC, C4_QUANT, C4_DATA, C4_VALOR, SC4.R_E_C_N_O_ ID, "
 	cDML += "	B1_TIPO, B1_UM, B1_GRUPO, ACV_CATEGO "
	cDML += "FROM " + RetSQLName("SC4") + " SC4 "
	cDML += "LEFT JOIN " + RetSQLName("SB1") + " SB1 "
	cDML += "	ON (B1_FILIAL = '" +	 xFilial("SB1") + "' AND B1_COD = C4_PRODUTO "
	cDML += "   AND SB1.D_E_L_E_T_ = ' ') "
	cDML += "LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cDML += "	ON (ACV_FILIAL = '" +	 xFilial("ACV") + "' AND ACV_CODPRO = C4_PRODUTO "
	cDML += "   AND ACV.D_E_L_E_T_ = ' ') "	
	cDML += "WHERE C4_FILIAL = '" + xFilial("SC4") + "' "
	cDML += "   AND C4_DATA BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	cDML += "   AND SC4.D_E_L_E_T_ = ' ' "	
	
	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )  

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias() , .T., .F. )
	
	//-------------------------------------------------------------------
	// Converte os campos para o tipo correto.
	//-------------------------------------------------------------------  	
	TCSetField( ::cFlow, "C4_DATA", "D", 08, 0 )	
Return ::cFlow 