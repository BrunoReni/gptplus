#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL VISGER

//-------------------------------------------------------------------
/*/{Protheus.doc} BCContaContabil
Visualiza as informações  das visões gerenciais

@author  Marcia Junko
@since   07/10/2019

/*/
//-------------------------------------------------------------------
Class BCVisaoGerencial from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Marcia Junko
@since   07/10/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCVisaoGerencial
	_Super:Setup("VisaoGerencial", DIMENSION, "CTS")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   07/10/2019

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCVisaoGerencial
	Local cView := ""
	
	cView := "SELECT " + ;
		"<<CODE_LINE>>  TOTVS_LINHA_PRODUTO, " + ;
		"<<CODE_INSTANCE>>  INSTANCIA, " + ;
		"<<CODE_COMPANY>>  EMPRESA, " + ;
		"'<<CTS_COMPANY>>'  TABELA, " + ;
		"CTS_FILIAL  FILIAL, " + ;
		"CTS_CODPLA  COD_VISAO, " + ;
		"CTS_NOME  NOME_VISAO_GERENCIAL, " + ;
		"CTS_ORDEM  ORDEM_EXIBICAO, " + ;
		"CTS_CONTAG  ENT_GERENCIAL, " + ;
		"CTS_CTASUP  ENT_SUPERIOR, " + ;
		"CTS_DESCCG  DESC_ENT_GERENCIAL, " + ;
		"CTS_NORMAL  COND_NORMAL, " + ;
		"CTS_COLUNA  COLUNA, " + ;
		"CTS_CLASSE  CLASSE, " + ;
		"CTS_IDENT  IDENTIFICADOR, " + ;
		"CTS_LINHA  LINHA_COMPOSICAO, " + ;
		"CTS_CT1INI  CONTA_CONTABIL_INICIAL, " + ;
		"CTS_CT1FIM  CONTA_CONTABIL_FINAL, " + ;
		"CTS_CTTINI  CCUSTO_INICIAL, " + ;
		"CTS_CTTFIM  CCUSTO_FINAL, " + ;
		"CTS_CTDINI  ITEM_INICIAL, " + ;
		"CTS_CTDFIM  ITEM_FINAL, " + ;
		"CTS_CTHINI  CLASSE_INICIAL, " + ;
		"CTS_CTHFIM  CLASSE_FINAL, " + ;
		"CTS_TPSALD  TIPO_SALDO, " + ;
		"I13.I13_TIPO  TIPO_CONTA" + ;
		"FROM <<CTS_COMPANY>> " + ;
		"LEFT JOIN" + ; 
			"(" + ;
			"SELECT MAX(SUBSTRING(I13_COD_CC,1,1)) INICIO_CONTA, I13_TIPO, I13_FILIAL " + ;
  			"FROM I13 " + ;
  			"WHERE I13.I13_EMPRES = <<CODE_COMPANY>>" + ;
			"AND I13.D_E_L_E_T_ = ' ' " + ;
  			"GROUP BY I13_TIPO, I13_FILIAL) " + ;
			" I13 ON SUBSTRING(CTS_CT1INI,1,1) = I13.INICIO_CONTA " + ;
			"AND I13_FILIAL = <<SUBSTR_CT1_CTS_FILIAL>> " + ;
			"WHERE D_E_L_E_T_ = ' ' " + ;	
		"<<TEST_QUERY>> "

Return cView	