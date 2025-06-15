#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL LANCCTB

//-------------------------------------------------------------------
/*/{Protheus.doc} BCDRE
Visualiza as informações do DRE da  área de Controladoria.

@author  Marcia Junko
@since   11/09/2019

/*/
//-------------------------------------------------------------------
Class BCLanc_Contabil from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Marcia Junko
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCLanc_Contabil
	_Super:Setup("Lanc_Contabil", FACT, "CT2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query DRE com saldo diário

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   11/09/2019
/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCLanc_Contabil
	Local cView := ""

	cView := "SELECT " + ;
		"<<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
		"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		"'<<CT2_COMPANY>>' AS TABELA_LANCAMENTO, " + ;
		"CT2_EMPORI AS EMPRESA, " + ;		
		"CT2_FILORI AS FILIAL_LANC, " + ;
		"CT2_DATA AS DATA, " + ;
		"CT2_LOTE AS LOTE, " + ;
		"CT2_SBLOTE AS SUBLOTE, " + ; 
		"CT2_DOC AS DOCUMENTO, " + ;
		"CT2_MOEDLC AS COD_MOEDA, " + ;
		"CT2_LINHA AS LINHA, " + ; 
		"CT2_SEQHIS AS SEQ_HISTORICO, " + ;
		"CT2_SEQLAN AS SEQ_LANC, " + ;
		"CT2_DC AS TIPO_LANC, " + ;
		"CT2_TPSALD AS TIPO_SALDO, " + ;
		"CT2_DEBITO AS CONTA_DEBITO, " + ;
		"CT2_CREDIT AS CONTA_CREDITO, " + ; 
		"<<FORMATVALUE(CT2_VALOR)>> AS VALOR, " + ;
		"CT2_HIST AS HISTORICO_LANC, " + ; 
		"CT2_CCD AS CCUSTO_DEBITO, " + ; 
		"CT2_CCC AS CCUSTO_CREDITO, " + ; 
		"CT2_ITEMD AS ITEM_DEBITO, " + ; 
		"CT2_ITEMC AS ITEM_CREDITO, " + ; 
		"CT2_CLVLDB AS CLASSE_DEBITO, " + ; 
		"CT2_CLVLCR AS CLASSE_CREDITO, " + ;
		"CT2_SEQIDX AS SEQUENCIA, " + ;
		"D_E_L_E_T_, " + ;
		"R_E_C_N_O_ " + ;
		"FROM( " + ;
		"SELECT " + ;
		"CT2_EMPORI, CT2_FILORI, CT2_DATA, CT2_LOTE, CT2_SBLOTE, " + ;
		"CT2_DOC, CT2_MOEDLC, CT2_LINHA, CT2_SEQHIS, CT2_SEQLAN, " + ;
		"CT2_DC, CT2_TPSALD, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, " + ;
		"CT2_HIST, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, " + ;
		"CT2_CLVLCR, CT2_SEQIDX, D_E_L_E_T_, R_E_C_N_O_, " + ;
		"ROW_NUMBER() OVER (PARTITION BY CT2_EMPORI, CT2_FILORI, " + ;
		"CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_MOEDLC, CT2_LINHA, " + ;
		"CT2_SEQHIS, CT2_SEQLAN, CT2_DC, CT2_TPSALD ORDER BY R_E_C_N_O_ DESC) RANKING " + ;
		"FROM <<CT2_COMPANY>> CT2 " + ;
		"WHERE CT2_DATA >= <<HISTORIC_PERIOD(1)>> " + ;
		") SUB " + ;
		"WHERE RANKING = 1  "+ ;
		"<<TEST_QUERY>> "

Return cView	
