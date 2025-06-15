#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL CONTACONTABIL

//-------------------------------------------------------------------
/*/{Protheus.doc} BCContaContabil
Visualiza as informaçõeses das  contas  contabeis.
 
@author  Andr�ia Lima
@since   13/08/2019

/*/
//-------------------------------------------------------------------
Class BCContaContabil from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padr�o.

@author  Andr�ia Lima
@since   13/08/2019

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCContaContabil
	_Super:Setup("ContaContabil", DIMENSION, "CT1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andr�ia Lima
@since   13/08/2019

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCContaContabil
	Local cView := ""

	
	cView := "SELECT " + ;
		"<<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
		"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		"<<CODE_COMPANY>> AS EMPRESA, " + ;
		"'<<CT1_COMPANY>>' AS TABELA, " + ;
		"CT1.CT1_FILIAL AS FILIAL, " + ;
		"CT1.CT1_CONTA AS COD_CONTA_CONTABIL, " + ;
		"CT1.CT1_CTASUP AS CONTA_SUPERIOR, " + ;
		"CT1.CT1_DESC01 AS DESC_CONTA, " + ;
		"CT1.CT1_DESC02 AS DESC_CONTA_2, " + ;
		"CT1.CT1_DESC03 AS DESC_CONTA_3, " + ;
		"CT1.CT1_DESC04 AS DESC_CONTA_4, " + ;
		"CT1.CT1_DESC05 AS DESC_CONTA_5, " + ;
		"CT1.CT1_CLASSE AS CLASSE_CONTA, " + ;
		"CT1.CT1_NORMAL AS COND_NORMAL, " + ;
		"CT1.CT1_RES AS CODIGO_REDUZIDO, " + ;
		"CT1.CT1_CTALP AS CONTA_LP, " + ;
		"CT1.CT1_CTAPON AS CONTA_PONTE_LP, " + ;
		"CT1.CT1_GRUPO AS GRUPO_CONTABIL, " + ;
		"CT1.CT1_NTSPED AS NATUREZA_SPED, " + ; 
		"CT1.CT1_NATCTA AS NATUREZA_CONTA, " + ;
		"I13.I13_TIPO AS TIPO " + ;
		"FROM <<CT1_COMPANY>> CT1 LEFT JOIN " + ;
		"I13 I13 ON I13.I13_COD_CC = CT1.CT1_CONTA  AND " + ;
		"I13.I13_FILIAL = CT1.CT1_FILIAL AND " + ;
		"I13.I13_EMPRES = <<CODE_COMPANY>>" + ;
		"WHERE CT1.D_E_L_E_T_ = ' ' " + ;	
		"<<TEST_QUERY>> "

Return cView	