#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCARTQUALIDADE.CH"

REGISTER EXTRACTOR HKP

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCartQualidade
Classe do extrator para a tabela fato Qualidade Carteira do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   26/01/2011
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXCartQualidade from BIXEntity
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
@since   23/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCartQualidade
	_Super:New( FACT, "HKP", STR0001, "SD7", { MATERIAIS } ) // "Qualidade Carteira" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   23/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCartQualidade
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKP_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKP_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKP_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKP_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKP_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKP_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKP_FORNEC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HKP_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKP_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKP_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKP_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HKP_REFER" , "C", 32, 0, .T., "HJH" )	
	oModel:AddField( "HKP_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKP_CRITIC", "C", 32, 0, .T., "HGF" )	
	oModel:AddField( "HKP_DTEXTR", "D", 8 , 0 )	
	oModel:AddField( "HKP_FICHA",  "C", 10, 0 )	
	oModel:AddField( "HKP_SEQCIA", "C", 10, 0 )	
	oModel:AddField( "HKP_QPENDT", "N", 16, 4 )
	oModel:AddField( "HKP_QPDFMT", "N", 16, 4 )
	oModel:AddField( "HKP_QPDFMC", "N", 16, 4 )
	oModel:AddField( "HKP_VPENDT", "N", 16, 2 )

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
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCartQualidade
	Local oRegion	:= NIL
	Local cMoeda    := ""
	Local cFlow 	:= ""		
	Local nMoeda     := 1
	Local cLKEmpFil := (FWCompany() + FWFilial())  
	
	chkfile("SB2")
	SB2->( dbSetOrder(1) )
		
	aMoedas	:= BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo ) 
	
	While (cFlow)->(! EoF() ) 		
		For nMoeda := 1 To Len(aMoedas)
			cMoeda := aMoedas[nMoeda][1]
		
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "D7_SEQ", 	(cFlow)->D7_SEQ )
			oRecord:SetValue( "D7_NUMERO",  (cFlow)->D7_NUMERO )
			oRecord:SetValue( "ACU_COD",  	(cFlow)->ACV_CATEGO )
			oRecord:SetValue( "BM_GRUPO",  	(cFlow)->B1_GRUPO )
			oRecord:SetValue( "B1_COD",  	(cFlow)->D7_PRODUTO )   
			oRecord:SetValue( "A2_COD",  	(cFlow)->D7_FORNECE )   
			oRecord:SetValue( "A2_LOJA",  	(cFlow)->D7_LOJA )
			oRecord:SetValue( "AH_UNIMED",  (cFlow)->B1_UM )      
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKP_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKP_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HKP_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKP_FAMMAT", oSeeker:Seek( "HG2", { (cFlow)->B1_TIPO } ) ) 
			oRecord:SetValue( "HKP_FAMCOM", oSeeker:Seek( "HG2", { (cFlow)->ACV_CATEGO } ) ) 
			oRecord:SetValue( "HKP_GRPEST", oSeeker:Seek( "HG3", { (cFlow)->B1_GRUPO } ) ) 
			oRecord:SetValue( "HKP_ITEM",   oSeeker:Seek( "HJ8", { (cFlow)->D7_PRODUTO } ) ) 
			oRecord:SetValue( "HKP_UNITEM", oSeeker:Seek( "HHW", { (cFlow)->B1_UM } ) ) 
			oRecord:SetValue( "HKP_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->A2_EST, (cFlow)->A2_COD_MUN, (cFlow)->A2_PAIS ) } ) ) 
			oRecord:SetValue( "HKP_MOEDA",  oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) )
			oRecord:SetValue( "HKP_GRPFOR", oSeeker:Seek( "HGE", { (cFlow)->A2_GRUPO } ) )	
			oRecord:SetValue( "HKP_REFER",  oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKP_CRITIC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKP_DTEXTR", dToday  )

			If Empty((cFlow)->D7_FORNECE) .And. Empty((cFlow)->D7_LOJA)
				oRecord:SetValue( "HKP_FORNEC", oSeeker:Seek( "HKJ", { Padl(cLKEmpFil, 6, '#') , '00'}  ) )
			Else 
				oRecord:SetValue( "HKP_FORNEC", oSeeker:Seek( "HKJ", { (cFlow)->D7_FORNECE, (cFlow)->D7_LOJA } ) )
			EndIf

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HKP_FICHA",  (cFlow)->D7_NUMERO )
			oRecord:SetValue( "HKP_SEQCIA",  (cFlow)->D7_SEQ )

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKP_QPENDT",  (cFlow)->D7_SALDO )
			
			// Indicadores
			If SB2->( dbSeek( xFilial("SB2") + (cFlow)->D7_PRODUTO + (cFlow)->D7_LOCAL))
				oRecord:SetValue( "HKP_VPENDT",  Round( ((cFlow)->D7_SALDO  * &("SB2->B2_CM" + cMoeda)), 2) )
			EndIf			
			oRecord:SetValue( "HKP_QPDFMT",  0 )
			oRecord:SetValue( "HKP_QPDFMC",  0 )

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
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXCartQualidade
	Local nInterval		:= BIXParInfo( "BIX_CRTQUA", "N", 24 ) 
	Local cBeginDate	:= ""
	Local cQuery		:= ""

	//-------------------------------------------------------------------
	// Define o período em que a carteira de qualidade será considerada.  
	//-------------------------------------------------------------------	
	cBeginDate	:= DToS( SToD( cFrom ) - ( nBIVal( nInterval ) * ( 30 ) ) )     
	
	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cQuery := " SELECT D7_PRODUTO, D7_LOCAL, D7_FORNECE, D7_LOJA, D7_SALDO, D7_NUMERO, D7_SEQ, A.R_E_C_N_O_, "
	cQuery += " B1_TIPO, B1_GRUPO, B1_UM, ACV_CATEGO, A2_EST, A2_COD_MUN, A2_PAIS, A2_GRUPO "
	cQuery += " FROM " + RetSqlName("SD7") + " A "
	cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "   AND B1_COD = D7_PRODUTO "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("ACV") + " ACV "
	cQuery += "	ON ACV_FILIAL = '" + xFilial("ACV") + "' "
	cQuery += "   AND ACV_CODPRO = D7_PRODUTO "
	cQuery += "   AND ACV.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSQLName("SA2") + " SA2 "
	cQuery += " ON A2_FILIAL = '" +	xFilial("SA2") + "' "
	cQuery += "	  AND A2_COD =  D7_FORNECE "
	cQuery += "   AND A2_LOJA = D7_LOJA "
	cQuery += "	  AND SA2.D_E_L_E_T_ = ' ' "	
	cQuery += " WHERE D7_FILIAL = '" + xFilial("SD7") + "' "
	cQuery += "	AND D7_SEQ = (SELECT MAX(D7_SEQ) FROM " + RetSqlName("SD7") + " B WHERE A.D7_NUMERO = B.D7_NUMERO) "
	cQuery += "	AND D7_DATA BETWEEN '" + cBeginDate + "' AND '" + cTo + "' " 
	cQuery += " AND D7_SALDO > 0 "
	cQuery += "	AND A.D_E_L_E_T_ = ' '"
	
	//-------------------------------------------------------------------
	// Transforma a query em ANSI.
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária.
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ::cFlow := GetNextAlias(), .T., .F.)
Return ::cFlow
