#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCSTOPER.CH"

REGISTER EXTRACTOR HQB

Static cAliasSC2 := RetSqlName("SC2")
Static cAliasSD3 := RetSqlName("SD3")
Static cAliasSB1 := RetSqlName("SB1")
Static cAliasSH6 := RetSqlName("SH6")
Static cFilSC2   := xFilial("SC2")
Static cFilSD3   := xFilial("SD3")
Static cFilSB1   := xFilial("SB1")
Static cFilSH6   := xFilial("SH6")

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCstOper
Extrator para a tabela fato Custo por Operação - Consumida Extrator TOTVS B.I.

@author  BI TEAM
@since   14/03/2012
/*/
//-------------------------------------------------------------------
Class BIXCstOper from BIXEntity
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
Method New() Class BIXCstOper
	_Super:New( FACT, "HQB", STR0001, "SD3", { PRODUCAO } ) //"Custo por Operação"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCstOper
	Local oModel := BIXModel():Build( Self )

	//--------------------------------------------------------------------
	// Caso a carga seja histórica, o Período de Extração considera
	// os registros até o mês anterior a data de extração
	// Mas caso a carga seja incremental, o Período de Extração considera
	// somente o mês corrente
	//--------------------------------------------------------------------	
	oModel:SetPeriod ( PERIOD_MONTH_HIST_INC )
	
	oModel:AddField( "HQB_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HQB_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HQB_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HQB_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HQB_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HQB_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HQB_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HQB_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HQB_OPERA" , "C", 32, 0, .T., "HQC" )
	oModel:AddField( "HQB_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HQB_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HQB_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HQB_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HQB_DATA"  , "D", 8, 0,  .F., "HK2" )	
	oModel:AddField( "HQB_DTEXTR", "D", 8, 0 )
	oModel:AddField( "HQB_VCUSTP", "N", 16, 2 )
	
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
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCstOper
	Local aMoedas   := {}
	Local cMoeda    := ""
	Local nInd      := 1 
	Local lCatego 	:= .F.
	Local lOpera  	:= .F.

	Private cRetAlias := GetNextAlias()	

	aMoedas := BIXGetMxF(::cEntity)

	DbSelectArea("ACV")	
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	DbSelectArea("SH6")
	SH6->( dbSetOrder(1) ) // Filial + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cRetAlias := ::Flow( cFrom, cTo )
	
	While (cRetAlias)->(! Eof() )   
		lCatego := .F.
		lOpera  := .F.
		
		If ACV->( MSSeek( xFilial("ACV") + (cRetAlias)->C2_PRODUTO ) )
			lCatego := .T.
		EndIf
		
		If SH6->( MSSeek( xFilial("SH6") + (cRetAlias)->D3_OP + (cRetAlias)->D3_COD ) )
			lOpera := .T.
		EndIf

		For nInd := 1 To Len(aMoedas)
			cMoeda := aMoedas[nInd][1]
		
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D3_OP"	, (cRetAlias)->D3_OP )
			oRecord:SetValue( "D3_COD"	, (cRetAlias)->D3_COD )	
			oRecord:SetValue( "CTT_CUSTO"	, (cRetAlias)->D3_CC )
			oRecord:SetValue( "ACU_COD"		, ACV->ACV_CATEGO )
			oRecord:SetValue( "B1_COD"		, (cRetAlias)->D3_COD )
			oRecord:SetValue( "BM_GRUPO"	, (cRetAlias)->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, (cRetAlias)->D3_UM )			
			oRecord:SetValue( "G2_PRODUTO"	, SH6->H6_PRODUTO )
			oRecord:SetValue( "G2_OPERAC"	, SH6->H6_OPERAC )
		
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HQB_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HQB_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HQB_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HQB_ITEM"  , oSeeker:Seek( "HJ8", { (cRetAlias)->D3_COD } ) ) 
			oRecord:SetValue( "HQB_FAMMAT", oSeeker:Seek( "HG2", { (cRetAlias)->B1_TIPO } ) ) 
			oRecord:SetValue( "HQB_GRPEST", oSeeker:Seek( "HG3", { (cRetAlias)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HQB_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) )
			oRecord:SetValue( "HQB_CCUSTO", oSeeker:Seek( "HJ5", { (cRetAlias)->D3_CC } ) ) 
			oRecord:SetValue( "HQB_UNITEM", oSeeker:Seek( "HHW", { (cRetAlias)->D3_UM } ) ) 

			If lCatego
				oRecord:SetValue( "HQB_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) )
			Else
				oRecord:SetValue( "HQB_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf
			
			If lOpera
				oRecord:SetValue( "HQB_OPERA" , oSeeker:Seek( "HQC", { SH6->H6_PRODUTO, SH6->H6_OPERAC } ) ) 
			Else
				oRecord:SetValue( "HQB_OPERA" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf
			
			oRecord:SetValue( "HQB_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HQB_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
							
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQB_DATA", (cRetAlias)->D3_EMISSAO )              // Data do Custo do Item
			oRecord:SetValue( "HQB_DTEXTR", Lastday(date()))	  
 			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQB_VCUSTP", Round( &("(cRetAlias)->D3_CUSTO" + cMoeda ), 2) )// Valor Custo das Operações

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nInd
		(cRetAlias)->( dbSkip() )
	EndDo
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	

	(cRetAlias)->( dbCloseArea() )
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
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCstOper
	Local nInterval	 := BIXParInfo( "BIX_CUSTOP", "N", 2 )
	Local cBeginDate := ""    
	Local cFlow		 := ""
	Local cAuxFlow	 := ""
	Local cSubFlow	 := ""
	Local cConcat	:= If ( "MSSQL" $ TCGetDB(), "+", "||" ) 
	local lHist		:= ( Month(SToD(cFrom)) <> Month(SToD(cTo)) )	
	 		
	//-------------------------------------------------------------------
	// Define o período em que as operações não finalizadas serão consideradas.  
	//-------------------------------------------------------------------	
	cBeginDate	:= DToS( SToD( cFrom ) - ( nBIVal( nInterval ) * ( 30 ) ) )  	
		                  
	//-------------------------------------------------------------------
	// Adiciona comandos para verificação da condição de operações não 
	// finalizadas em caso de carga não histórica.  
	//-------------------------------------------------------------------		
	if !lHist
		cAuxFlow := "SELECT DISTINCT H6.H6_OP " + ;
					"FROM "+ cAliasSH6 + " H6, " + cAliasSC2 + " C2 " + ;
					"WHERE H6.H6_FILIAL = '" + cFilSH6 + "' AND " + ;
						"C2.C2_FILIAL = '" + cFilSC2 + "' AND " + ;
						"C2.C2_NUM " + cConcat + " C2.C2_ITEM " + cConcat + " C2.C2_SEQUEN " + cConcat + " C2.C2_ITEMGRD = H6.H6_OP AND " + ;
						"C2.C2_EMISSAO BETWEEN '" + cBeginDate + "' AND '" + cFrom + "' AND " + ;
						"H6.H6_PT = 'T' AND " + ;	
						"C2.D_E_L_E_T_ = ' ' AND " + ;
						"H6.D_E_L_E_T_ = ' ' "
                      
		cSubFlow := "OR (D3_OP in ( SELECT DISTINCT SH6.H6_OP " + ;
					"FROM "+ cAliasSH6 + " SH6, " + cAliasSC2 + " SC2 "  + ;
					"WHERE SH6.H6_FILIAL = '" + cFilSH6 + "' AND " + ;
						"SC2.C2_FILIAL = '" + cFilSC2 + "' AND " + ; 
						"SC2.C2_NUM " + cConcat + " SC2.C2_ITEM " + cConcat + " SC2.C2_SEQUEN " + cConcat + " SC2.C2_ITEMGRD = SH6.H6_OP AND " + ;
						"SC2.C2_EMISSAO BETWEEN '" + cBeginDate + "' AND '" + cFrom + "' AND " + ;
						"SH6.H6_PT = 'P' AND " + ;
						"SH6.H6_OP NOT IN ( " + cAuxFlow + " ) AND " +;
						"SC2.D_E_L_E_T_ = ' ' AND " + ;
						"SH6.D_E_L_E_T_ = ' ' ) )"						
	EndIf	

	cFlow := "SELECT D3_EMISSAO, D3_COD, D3_CUSTO1, D3_CUSTO2, D3_CUSTO3, D3_CUSTO4, D3_UM, "  + ;
				"D3_CUSTO5, D3_CC, SD3.R_E_C_N_O_ ID, B1_COD, B1_TIPO, B1_GRUPO, D3_OP, SC.C2_PRODUTO " + ;
			 "FROM " + cAliasSD3 + " SD3 " + ; 
			 "INNER JOIN " + cAliasSB1 + " SB1 " + ;
			 "ON (B1_FILIAL = '" + cFilSB1 + "' AND " + ; 
			 	"B1_COD = D3_COD AND "  + ;
				"SB1.D_E_L_E_T_ = ' ') "  + ;
			 "INNER JOIN " + cAliasSC2 + " SC "  + ;
			 "ON (SC.C2_FILIAL = '" + cFilSC2 + "' AND "  + ;
				"SC.C2_NUM " + cConcat + " SC.C2_ITEM " + cConcat + " SC.C2_SEQUEN " + cConcat + " SC.C2_ITEMGRD = D3_OP AND "  + ;
				"SC.D_E_L_E_T_ = ' ') " + ;     
			 "WHERE D3_FILIAL = '" + cFilSD3 + "' AND "  + ;
				"D3_OP <> '' AND " + ;
				"D3_ESTORNO <> 'S' AND " + ;
				"SUBSTRING(D3_CF, 1, 2) = 'RE' AND " + ;
				"SD3.D_E_L_E_T_ = ' ' AND " + ;
				"((SC.C2_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "') " + cSubFlow + " )"
	  
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  		
	cFlow := ChangeQuery( cFlow )
       
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//------------------------------------------------------------------- 	
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cFlow), cRetAlias, .T., .T.)       	

	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TCSetField( cRetAlias, "D3_EMISSAO", "D", 8, 0 )
Return cRetAlias
