#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL BAL_DAY

//-------------------------------------------------------------------
/*/{Protheus.doc} BCDRE
Visualiza as informações do DRE da área de Controladoria.

@author  Marcia Junko
@since   17/06/2019

/*/
//-------------------------------------------------------------------
Class BCBalance_day from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Marcia Junko
@since   17/06/2019

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCBalance_day
	_Super:Setup("Balance_day", FACT, "CQ1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   17/06/2019

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCBalance_day
	Local cView := ""
	
	cView := "SELECT " + ;
		"<<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
		"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		"<<CODE_COMPANY>> AS EMPRESA, " + ;
		"'<<CQ1_COMPANY>>' AS TABELA_SALDOS, " + ;
		"CQ1_FILIAL AS FILIAL_SALDO, " + ;
		"CQ1_DATA AS DATA, " + ;
		"CQ1_CONTA AS COD_CONTA, " + ;
		"CQ1_MOEDA AS COD_MOEDA, " + ;
		"CQ1_TPSALD AS TIPO_SALDO, " + ;
		"CQ1_LP AS FLAG_LP, " + ;
		"CQ1_DTLP AS DATA_APURACAO, " + ; 
		"<<FORMATVALUE(CQ1_CREDIT)>> AS VLR_CRD, " + ; 
		"<<FORMATVALUE(CQ1_DEBITO)>> AS VLR_DEB, " + ;
		"CASE CT1_NORMAL " + ;
			"WHEN '1' " + ; 
				"THEN COALESCE(CQ1_DEBITO - CQ1_CREDIT, 0) " + ;
			"WHEN '2' " + ;
				"THEN COALESCE(CQ1_CREDIT - CQ1_DEBITO, 0) " + ; 
			"ELSE 0 " + ;
			"END AS SALDO, " + ;
		"I13.I13_TIPO AS TIPO_CONTA, " + ;
		"CT1_FILIAL AS FILIAL_PLANO_CONTAS, " + ;
		"'<<CT1_COMPANY>>' AS TABELA_PLANO_CONTAS, " + ;
		"CT1_NORMAL AS COND_NORMAL, " + ;
		"CT1_DESC01 AS DESC_CONTA, " + ;
		"CASE CT1_NORMAL WHEN '1' THEN 'D' WHEN '2' THEN 'R' ELSE  '' END AS TIPO, " + ;
		"CT1_CTASUP AS CONTA_SUPERIOR " + ;
	"FROM <<CQ1_COMPANY>> CQ1 " + ;
	"INNER JOIN <<CT1_COMPANY>> CT1 " + ;
		"ON CT1_FILIAL = <<SUBSTR_CT1_CQ1_FILIAL>> " + ;
		"AND CT1_CONTA = CQ1_CONTA " + ;
		"AND CT1.D_E_L_E_T_ = ' '  " + ;	
	"INNER JOIN " + ;
		"I13 I13 ON I13.I13_COD_CC = CT1.CT1_CONTA  AND " + ;
		"I13.I13_FILIAL = CT1.CT1_FILIAL AND " + ;
		"I13.I13_EMPRES = <<CODE_COMPANY>> AND " + ;
		"I13.I13_TIPO IN ('A', 'P') AND " + ;
		"I13.D_E_L_E_T_ = ' ' " + ;
	"WHERE " + ;
		"CQ1_DATA >= <<HISTORIC_PERIOD(2)>> "  + ;
		"AND CQ1.D_E_L_E_T_ = ' ' " + ;
		"<<TEST_QUERY>> "

Return cView	
