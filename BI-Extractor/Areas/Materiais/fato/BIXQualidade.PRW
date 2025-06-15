#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXQUALIDADE.CH"

REGISTER EXTRACTOR HKN

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXQualidade
Classe do extrator para a tabela fato Qualidade do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   26/01/2011
/*/
//-------------------------------------------------------------------
Class BIXQualidade from BIXEntity
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
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXQualidade
	_Super:New( FACT, "HKN", STR0001, "SD7", { MATERIAIS } ) // "Qualidade"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXQualidade 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKN_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKN_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKN_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKN_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKN_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKN_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKN_MOTREJ", "C", 32, 0, .T., "HK0" )
	oModel:AddField( "HKN_FORNEC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HKN_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKN_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKN_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKN_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKN_CRITIC", "C", 32, 0, .T., "HGF" )
	oModel:AddField( "HKN_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HKN_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKN_DATA"  , "D", 8, 0 )
	oModel:AddField( "HKN_FICHA" , "C", 10, 0 )
	oModel:AddField( "HKN_SEQCIA", "C", 10, 0 )
	oModel:AddField( "HKN_QAPROV", "N", 16, 4 )
	oModel:AddField( "HKN_QCONSU", "N", 16, 4 )
	oModel:AddField( "HKN_QORIGI", "N", 16, 4 )
	oModel:AddField( "HKN_QREJEI", "N", 16, 4 )
	oModel:AddField( "HKN_QCSFMT", "N", 16, 4 )
	oModel:AddField( "HKN_QORFMT", "N", 16, 4 )
	oModel:AddField( "HKN_QRJFMT", "N", 16, 4 )
	oModel:AddField( "HKN_QCSFMC", "N", 16, 4 )
	oModel:AddField( "HKN_QORFMC", "N", 16, 4 )
	oModel:AddField( "HKN_QRJFMC", "N", 16, 4 )
	oModel:AddField( "HKN_QLEADT", "N", 16, 4 )
	oModel:AddField( "HKN_QAPFMT", "N", 16, 4 )
	oModel:AddField( "HKN_QAPFMC", "N", 16, 4 )
	oModel:AddField( "HKN_QROTEI", "N", 16, 4 )
	oModel:AddField( "HKN_QACFMT", "N", 16, 4 )
	oModel:AddField( "HKN_QACFMC", "N", 16, 4 )
	oModel:AddField( "HKN_QAPRCD", "N", 16, 4 )
	oModel:AddField( "HKN_VAPROV", "N", 16, 2 )
	oModel:AddField( "HKN_VCONSU", "N", 16, 2 )
	oModel:AddField( "HKN_VREJEI", "N", 16, 2 )
	oModel:AddField( "HKN_VORIGI", "N", 16, 2 )
	oModel:AddField( "HKN_VAPRCD", "N", 16, 2 )

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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXQualidade
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local nInd      := 1
	Local cMoeda    := ""
	Local cLKEmpFil := (FWCompany() + FWFilial())  

	Private cRetAlias := ""

	aMoedas := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cRetAlias := ::Flow( cFrom, cTo ) 
		
	While (cRetAlias)->( !Eof() )
		For nInd := 1 to Len(aMoedas)
			cMoeda := aMoedas[nInd][1]
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()

			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "B1_COD" 		, (cRetAlias)->PRODUTO )
			oRecord:SetValue( "BM_GRUPO" 	, (cRetAlias)->PRODGRP )
			oRecord:SetValue( "ACU_COD" 	, (cRetAlias)->CATEGO )
			oRecord:SetValue( "AH_UNIMED" 	, (cRetAlias)->UM )
			oRecord:SetValue( "A2_COD" 		, (cRetAlias)->FORN )
			oRecord:SetValue( "A2_LOJA" 	, (cRetAlias)->LOJA )
			oRecord:SetValue( "YA_CODGI" 	, (cRetAlias)->A2_EST )
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			If !Empty((cRetAlias)->FORN) .And. !Empty((cRetAlias)->LOJA)
				oRecord:SetValue( "HKN_FORNEC", oSeeker:Seek( "HKJ", { (cRetAlias)->FORN, (cRetAlias)->LOJA } ) ) 
			Else 
				oRecord:SetValue( "HKN_FORNEC", oSeeker:Seek( "HKJ", { Padl(cLKEmpFil,6,'#'), '00' } ) ) 
			EndIf			
			oRecord:SetValue( "HKN_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKN_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKN_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKN_FAMMAT", oSeeker:Seek( "HG2", { (cRetAlias)->TIPO } ) )
			oRecord:SetValue( "HKN_FAMCOM", oSeeker:Seek( "HG1", { (cRetAlias)->CATEGO } ) ) 
			oRecord:SetValue( "HKN_GRPEST", oSeeker:Seek( "HG3", { (cRetAlias)->PRODGRP } ) ) 
			oRecord:SetValue( "HKN_ITEM"  , oSeeker:Seek( "HJ8", { (cRetAlias)->PRODUTO } ) ) 
			oRecord:SetValue( "HKN_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cRetAlias)->A2_EST, (cRetAlias)->A2_COD_MUN, (cRetAlias)->A2_PAIS ) } ) ) 
			oRecord:SetValue( "HKN_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HKN_GRPFOR", oSeeker:Seek( "HGE", { (cRetAlias)->GRUPO } ) ) 
			oRecord:SetValue( "HKN_UNITEM", oSeeker:Seek( "HHW", { (cRetAlias)->UM } ) ) 
			oRecord:SetValue( "HKN_MOTREJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKN_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKN_CRITIC", oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HKN_DATA"  , IIf(!Empty(SToD((cRetAlias)->DATAINS)),SToD((cRetAlias)->DATAINS),DATE_EMPTY) ) // Data da Inspeção 
			oRecord:SetValue( "HKN_FICHA" , (cRetAlias)->NUMERO )    // Numero da Ficha
			oRecord:SetValue( "HKN_SEQCIA", " ") 					// Sequencia		
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKN_QORIGI", (cRetAlias)->TIPO0  )								// Qtde Original 
			oRecord:SetValue( "HKN_QAPROV", (cRetAlias)->TIPO1  )								// Qtde Aprovada 
			oRecord:SetValue( "HKN_QREJEI", (cRetAlias)->TIPO2  )								// Qtde Rejeitada 		
			oRecord:SetValue( "HKN_VAPROV", Round( &("(cRetAlias)->VAPROV" + cMoeda), 2 ))	// Vl Aprovado 
			oRecord:SetValue( "HKN_VREJEI", Round( &("(cRetAlias)->VREJEI" + cMoeda), 2 ))	// Vl Rejeitado 
			oRecord:SetValue( "HKN_VORIGI", Round( &("(cRetAlias)->VORIG"  + cMoeda), 2 ))	// Vl Original 
			oRecord:SetValue( "HKN_QROTEI", 0 ) // Qtde Roteiros 
			oRecord:SetValue( "HKN_QAPRCD", 0 ) // Qtde Aprovada Condicionalmente 
			oRecord:SetValue( "HKN_QCONSU", 0 ) // Qtde Consumida 
			oRecord:SetValue( "HKN_QACFMT", 0 ) // Qtde Aprovada Condicionalmente Família Material 
			oRecord:SetValue( "HKN_QACFMC", 0 ) // Qtde Aprovada Condicionalmente Família Comercial 			
			oRecord:SetValue( "HKN_QCSFMT", 0 ) // Qtde Consumida Familia Material 
			oRecord:SetValue( "HKN_QORFMT", 0 ) // Qtde Original Familia Material 
			oRecord:SetValue( "HKN_QRJFMT", 0 ) // Qtde Rejeitada Familia Material 
			oRecord:SetValue( "HKN_QAPFMT", 0 ) // Qtde Aprovada Familia Material 
			oRecord:SetValue( "HKN_QCSFMC", 0 ) // Qtde Consumida Familia Comercial 
			oRecord:SetValue( "HKN_QORFMC", 0 ) // Qtde Original Familia Comercial 
			oRecord:SetValue( "HKN_QRJFMC", 0 ) // Qtde Rejeitada Familia Comercial 
			oRecord:SetValue( "HKN_QAPFMC", 0 ) // Qtde Aprovada Familia Comercial 
			oRecord:SetValue( "HKN_VAPRCD", 0 ) // Vl Aprovado Condicionalmente 
			oRecord:SetValue( "HKN_VCONSU", 0 ) // Vl Consumido 
			oRecord:SetValue( "HKN_QLEADT", 0 ) // Lead Time 

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
@return cRetAlias, Alias temporário. 

@author  Marcia Junko
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXQualidade
	Local cQuery    := ""

	//-------------------------------------------------------------------
	// Monta o DML. 
	//-------------------------------------------------------------------
	cQuery += "SELECT DISTINCT D7_NUMERO AS NUMERO , " 
	cQuery += "       D7_PRODUTO     AS PRODUTO, "
	cQuery += "       D7_LOCAL       AS LOCAL  , "
	cQuery += "       D7_FORNECE     AS FORN   , "
	cQuery += "       D7_LOJA        AS LOJA   , "  
	cQuery += "       B1.B1_TIPO     AS TIPO   , "
	cQuery += "       B1.B1_GRUPO    AS PRODGRP, "
	cQuery += "       B1.B1_UM       AS UM     , "
	cQuery += "       A2.A2_GRUPO    AS GRUPO  , "
	cQuery += "       A2.A2_EST      AS A2_EST , "
	cQuery += "		  A2.A2_COD_MUN  AS A2_COD_MUN , "
	cQuery += "		  A2.A2_PAIS	 AS A2_PAIS   , "
	cQuery += "       ACV.ACV_CATEGO AS CATEGO , "
	
	cQuery += "(SELECT MAX(X.D7_DATA) AS DATA "
	cQuery += "   FROM " + RetSqlName("SD7") + " X "
	cQuery += "   WHERE X.D_E_L_E_T_ = ' '  "
	cQuery += "     AND X.D7_FILIAL = '" + xFilial("SD7") + "' "
	cQuery += "     AND (X.D7_ESTORNO <> 'S' OR (X.D7_ESTORNO = 'S' AND X.D7_SEQ = '001')) AND X.D7_TIPO = '0'"
	cQuery += "     AND X.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X.D7_NUMERO, X.D7_TIPO) AS DATAINS, "  
	
	cQuery += "(SELECT SUM(X1.D7_QTDE) AS QUANT "
	cQuery += "   FROM " + RetSqlName("SD7") + " X1 "
	cQuery += "   WHERE X1.D_E_L_E_T_ = ' ' "
	cQuery += "     AND X1.D7_FILIAL = '" + xFilial("SD7") + "' "
	cQuery += "     AND (X1.D7_ESTORNO <> 'S' OR (X1.D7_ESTORNO = 'S' AND X1.D7_SEQ = '001')) AND X1.D7_TIPO = '0' "
	cQuery += "     AND X1.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X1.D7_NUMERO, X1.D7_TIPO) AS TIPO0, "   
	
	cQuery += "(SELECT SUM(X2.D7_QTDE) AS QUANT "
	cQuery += "   FROM " + RetSqlName("SD7") + " X2 "
	cQuery += "   WHERE X2.D_E_L_E_T_ = ' ' "
	cQuery += "     AND X2.D7_FILIAL = '" + xFilial("SD7") + "' "
	cQuery += "     AND (X2.D7_ESTORNO <> 'S' OR (X2.D7_ESTORNO = 'S' AND X2.D7_SEQ = '001')) AND X2.D7_TIPO = '1' "
	cQuery += "     AND X2.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X2.D7_NUMERO, X2.D7_TIPO) AS  TIPO1, "     
	
	cQuery += "(SELECT SUM(X3.D7_QTDE) AS QUANT "
	cQuery += "   FROM " + RetSqlName("SD7") + " X3 "
	cQuery += "   WHERE X3.D_E_L_E_T_ = ' ' "                                   
	cQuery += "     AND X3.D7_FILIAL = '" + xFilial("SD7") + "' "
	cQuery += "     AND (X3.D7_ESTORNO <> 'S' OR (X3.D7_ESTORNO = 'S' AND X3.D7_SEQ = '001')) AND X3.D7_TIPO = '2' "
	cQuery += "     AND X3.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X3.D7_NUMERO, X3.D7_TIPO) AS TIPO2, "     

	cQuery += "(SELECT SUM(X4.D7_SALDO * B2.B2_CM1) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X4 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X4.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X4.D7_LOCAL "
	cQuery += "   WHERE X4.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_ = ' ' AND X4.D7_FILIAL = '" + xFilial("SD7") + "' "    
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X4.D7_ESTORNO <> 'S' OR (X4.D7_ESTORNO = 'S' AND X4.D7_SEQ = '001')) AND X4.D7_SEQ = '001' "
	cQuery += "     AND X4.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X4.D7_NUMERO, X4.D7_TIPO) AS VORIG1, "
	
	cQuery += "(SELECT SUM(X5.D7_SALDO * B2.B2_CM2) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X5 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X5.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X5.D7_LOCAL "
	cQuery += "   WHERE X5.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_ = ' ' AND X5.D7_FILIAL = '" + xFilial("SD7") + "' "           
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X5.D7_ESTORNO <> 'S' OR (X5.D7_ESTORNO = 'S' AND X5.D7_SEQ = '001')) AND X5.D7_SEQ = '001' "
	cQuery += "     AND X5.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X5.D7_NUMERO, X5.D7_TIPO) AS VORIG2, "
	
	cQuery += "(SELECT SUM(D7_SALDO * B2.B2_CM3) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X6 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X6.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X6.D7_LOCAL "
	cQuery += "   WHERE X6.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_ = ' ' AND X6.D7_FILIAL = '" + xFilial("SD7") + "' "   
	cQuery += "     AND B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X6.D7_ESTORNO <> 'S' OR (X6.D7_ESTORNO = 'S' AND X6.D7_SEQ = '001')) AND X6.D7_SEQ = '001' "
	cQuery += "     AND X6.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X6.D7_NUMERO, X6.D7_TIPO) AS VORIG3, "
	
	cQuery += "(SELECT SUM(X7.D7_SALDO * B2.B2_CM4) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X7 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X7.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X7.D7_LOCAL "
	cQuery += "   WHERE X7.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_ = ' ' AND X7.D7_FILIAL = '" + xFilial("SD7") + "' "    
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X7.D7_ESTORNO <> 'S' OR (X7.D7_ESTORNO = 'S' AND X7.D7_SEQ = '001')) AND X7.D7_SEQ = '001' "
	cQuery += "     AND X7.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X7.D7_NUMERO, X7.D7_TIPO) AS VORIG4, "
	
	cQuery += "(SELECT SUM(X8.D7_SALDO * B2.B2_CM5) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X8 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X8.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X8.D7_LOCAL "
	cQuery += "   WHERE X8.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_ = ' ' AND X8.D7_FILIAL = '" + xFilial("SD7") + "' "     
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X8.D7_ESTORNO <> 'S' OR (X8.D7_ESTORNO = 'S' AND X8.D7_SEQ = '001')) AND X8.D7_SEQ = '001' "
	cQuery += "     AND X8.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X8.D7_NUMERO, X8.D7_TIPO) AS VORIG5, "   
	
	cQuery += "(SELECT SUM(X9.D7_QTDE * B2_CM1) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X9 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X9.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X9.D7_LOCAL "
	cQuery += "   WHERE X9.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X9.D7_FILIAL = '" + xFilial("SD7") + "'  "  
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X9.D7_ESTORNO <> 'S' OR (X9.D7_ESTORNO = 'S' AND X9.D7_SEQ = '001')) AND X9.D7_TIPO = '2' "
	cQuery += "     AND X9.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X9.D7_NUMERO, X9.D7_TIPO) AS VREJEI1, "

	cQuery += "(SELECT SUM(X10.D7_QTDE * B2.B2_CM2) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X10 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X10.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X10.D7_LOCAL "
	cQuery += "   WHERE X10.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X10.D7_FILIAL = '" + xFilial("SD7") + "' "   
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X10.D7_ESTORNO <> 'S' OR (X10.D7_ESTORNO = 'S' AND X10.D7_SEQ = '001')) AND X10.D7_TIPO = '2' "
	cQuery += "     AND X10.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X10.D7_NUMERO, X10.D7_TIPO) AS VREJEI2, "

	cQuery += "(SELECT SUM(X11.D7_QTDE * B2.B2_CM3) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X11 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X11.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X11.D7_LOCAL "
	cQuery += "   WHERE X11.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X11.D7_FILIAL = '" + xFilial("SD7") + "' "   
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X11.D7_ESTORNO <> 'S' OR (X11.D7_ESTORNO = 'S' AND X11.D7_SEQ = '001')) AND X11.D7_TIPO = '2' "
	cQuery += "     AND X11.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X11.D7_NUMERO, X11.D7_TIPO) AS VREJEI3, "

	cQuery += "(SELECT SUM(X12.D7_QTDE * B2_CM4) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X12 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X12.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X12.D7_LOCAL "
	cQuery += "   WHERE X12.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X12.D7_FILIAL = '" + xFilial("SD7") + "' "       
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X12.D7_ESTORNO <> 'S' OR (X12.D7_ESTORNO = 'S' AND X12.D7_SEQ = '001')) AND X12.D7_TIPO = '2' "
	cQuery += "     AND X12.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X12.D7_NUMERO, X12.D7_TIPO) AS VREJEI4, "

	cQuery += "(SELECT SUM(X13.D7_QTDE * B2.B2_CM5) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X13 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X13.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X13.D7_LOCAL "
	cQuery += "   WHERE X13.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X13.D7_FILIAL = '" + xFilial("SD7") + "' "     
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X13.D7_ESTORNO <> 'S' OR (X13.D7_ESTORNO = 'S' AND X13.D7_SEQ = '001')) AND X13.D7_TIPO = '2' "
	cQuery += "     AND X13.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X13.D7_NUMERO, X13.D7_TIPO) AS VREJEI5, " 
	
	cQuery += "(SELECT SUM(X14.D7_QTDE * B2.B2_CM1) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X14 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X14.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X14.D7_LOCAL "
	cQuery += "   WHERE X14.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X14.D7_FILIAL = '" + xFilial("SD7") + "'  "  
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X14.D7_ESTORNO <> 'S' OR (X14.D7_ESTORNO = 'S' AND X14.D7_SEQ = '001')) AND X14.D7_TIPO = '1' "
	cQuery += "     AND X14.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X14.D7_NUMERO, X14.D7_TIPO) AS VAPROV1, "

	cQuery += "(SELECT SUM(X15.D7_QTDE * B2.B2_CM2) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X15 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X15.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X15.D7_LOCAL "
	cQuery += "   WHERE X15.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X15.D7_FILIAL = '" + xFilial("SD7") + "' "   
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X15.D7_ESTORNO <> 'S' OR (X15.D7_ESTORNO = 'S' AND X15.D7_SEQ = '001')) AND X15.D7_TIPO = '1' "
	cQuery += "     AND X15.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X15.D7_NUMERO, X15.D7_TIPO) AS VAPROV2, "

	cQuery += "(SELECT SUM(X16.D7_QTDE * B2.B2_CM3) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X16 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X16.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X16.D7_LOCAL "
	cQuery += "   WHERE X16.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X16.D7_FILIAL = '" + xFilial("SD7") + "' "   
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X16.D7_ESTORNO <> 'S' OR (X16.D7_ESTORNO = 'S' AND X16.D7_SEQ = '001')) AND X16.D7_TIPO = '1' "
	cQuery += "     AND X16.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X16.D7_NUMERO, X16.D7_TIPO) AS VAPROV3, "

	cQuery += "(SELECT SUM(X17.D7_QTDE * B2.B2_CM4) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X17 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X17.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X17.D7_LOCAL "
	cQuery += "   WHERE X17.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X17.D7_FILIAL = '" + xFilial("SD7") + "' "       
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X17.D7_ESTORNO <> 'S' OR (X17.D7_ESTORNO = 'S' AND X17.D7_SEQ = '001')) AND X17.D7_TIPO = '1' "
	cQuery += "     AND X17.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X17.D7_NUMERO, X17.D7_TIPO) AS VAPROV4, "

	cQuery += "(SELECT SUM(X18.D7_QTDE * B2.B2_CM5) "
	cQuery += "   FROM " + RetSqlName("SD7") + " X18 "
	cQuery += "   INNER JOIN " + RetSqlName("SB2") + " B2 "
	cQuery += "      ON B2.B2_COD   = X18.D7_PRODUTO "
	cQuery += "     AND B2.B2_LOCAL = X18.D7_LOCAL "
	cQuery += "   WHERE X18.D_E_L_E_T_ = ' ' AND B2.D_E_L_E_T_= ' ' AND X18.D7_FILIAL = '" + xFilial("SD7") + "' "     
	cQuery += "     AND B2.B2_FILIAL = '" + xFilial("SB2") + "' " 
	cQuery += "     AND (X18.D7_ESTORNO <> 'S' OR (X18.D7_ESTORNO = 'S' AND X18.D7_SEQ = '001')) AND X18.D7_TIPO = '1' "
	cQuery += "     AND X18.D7_NUMERO = C.D7_NUMERO "
	cQuery += "GROUP BY X18.D7_NUMERO, X18.D7_TIPO) AS VAPROV5 "

	cQuery += " FROM " + RetSqlName("SD7") + " C "   
	cQuery += " LEFT JOIN " + RetSqlName("SB1") + " B1 "
	cQuery += "   ON B1.B1_COD = C.D7_PRODUTO "
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " A2 "
	cQuery += "   ON A2.A2_COD  = C.D7_FORNECE "
	cQuery += "  AND A2.A2_LOJA = C.D7_LOJA "   
	cQuery += "	LEFT JOIN " + RetSqlName("ACV") + " ACV "
	cQuery += "   ON ACV.ACV_CODPRO = C.D7_PRODUTO "
	cQuery += " WHERE C.D_E_L_E_T_ = ' ' "
	cQuery += "   AND C.D7_FILIAL = '" + xFilial("SD7") + "' "                          
	cQuery += "	  AND C.D7_DATA BETWEEN '" + cFrom + "' AND '" + cTo + "' "	
	cQuery += "   AND (C.D7_ESTORNO <> 'S' OR (C.D7_ESTORNO = 'S' AND C.D7_SEQ = '001')) "
	cQuery += "ORDER BY NUMERO, PRODUTO, LOCAL, FORN, LOJA, TIPO, PRODGRP, UM, GRUPO, A2_EST, A2_COD_MUN, A2_PAIS, CATEGO"

	//-------------------------------------------------------------------
	// Transforma a query em ANSI.
	//-------------------------------------------------------------------  
	cQuery := ChangeQuery(cQuery)
	
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária.
	//------------------------------------------------------------------- 
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ::cFlow := GetNextAlias(), .T., .F.)
Return ::cFlow