#INCLUDE "BADEFINITION.CH"

NEW ENTITY ULTMOVRENTAL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAUltMovRental
Visualiza as informações das Últimas Movimentações.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Class BAUltMovRental from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAUltMovRental
	_Super:Setup("UltimaMovimentacao", FACT, "FQ4")
Return
  
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Djalma Mathias da Silva
@since   24/08/2022
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAUltMovRental
	Local cQuery := ""

	cQuery += " SELECT DISTINCT "
	cQuery += " <<KEY_SQ4_T9_FILIAL+T9_CODBEM>> 		AS BK_CADBEM, "
	cQuery += " <<KEY_FQ4_FQ4_FILIAL+FQ4_STATUS>> 		AS BK_STATUS, "
	cQuery += " <<KEY_SA1_A1_FILIAL+A1_COD+A1_LOJA>> 	AS BK_CLIENTE, "
	cQuery += " CASE "
	cQuery += " 	WHEN A1_COD_MUN = ' ' THEN 'P |01|<<CC2_COMPANY>>|'+ COALESCE(NULLIF(RTRIM( COALESCE(A1_EST,' ') ),' '), '|')  "
	cQuery += " 	ELSE 'P |01|<<CC2_COMPANY>>|'+ COALESCE(NULLIF(RTRIM( COALESCE(A1_EST, ' ') )+RTRIM( COALESCE(A1_COD_MUN, ' ') ), ' '), '|') "
	cQuery += " END  AS BK_REGIAO, "
	cQuery += " CASE "
	cQuery += " 	WHEN FQ4_PROJET = ' ' "
	cQuery += " 	THEN 'P |01|<<FPA_COMPANY>>||' "
	cQuery += " ELSE 'P |01|<<FPA_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(T9_FILIAL, ' '))+'|'+RTRIM(COALESCE(FQ4_PROJET, ' ')), ' '), '|') "
	cQuery += " END AS BK_LOCPROJ, "
	cQuery += " CASE "
	cQuery += " 	WHEN FQ4_OBRA = ' ' THEN 'P |01|<<FP1_COMPANY>>||' "
	cQuery += " 	ELSE 'P |01|<<FP1_COMPANY>>|' + COALESCE(NULLIF(Rtrim( COALESCE(T9_FILIAL, ' ') )+'|'+Rtrim( COALESCE( FQ4_PROJET, ' ') )+Rtrim( COALESCE(FQ4_OBRA, ' ') ), ' '), '|')  "
	cQuery += " END AS BK_OBRAS, "
	cQuery += " CONVERT(VARCHAR(8), CONVERT(DATE, SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-18, 10), 103), 112) AS DATA_EVENTO, "
	cQuery += " <<CODE_INSTANCE>> 						AS INSTANCIA "
	cQuery += " FROM <<FQ4_COMPANY>> FQ4 " 
	cQuery += " LEFT JOIN <<ST9_COMPANY>> ST9 ON FQ4.FQ4_CODBEM = ST9.T9_CODBEM AND FQ4_FILIAL = '      ' "
	cQuery += " LEFT JOIN <<SA1_COMPANY>> SA1 ON SA1.A1_COD=FQ4.FQ4_CODCLI AND SA1.A1_LOJA=FQ4.FQ4_LOJCLI "
	cQuery += " LEFT JOIN <<ST6_COMPANY>> ST6 ON ST6.T6_CODFAMI = FQ4.FQ4_CODFAM "
	cQuery += " WHERE  FQ4.D_E_L_E_T_ = ' ' "
	cQuery += "   AND FQ4.FQ4_SEQ IN "
	cQuery += "     (SELECT MAX(SEQUENCIA) "
	cQuery += "      FROM "
	cQuery += "        (SELECT 'P |01|<<SQ4_COMPANY>>|'+ COALESCE(NULLIF(RTRIM(COALESCE(T9_FILIAL, ' '))+'|'+RTRIM(COALESCE(T9_CODBEM, ' ')), ' '), '|') AS BK_CADBEM, "
	cQuery += "   		FQ4.FQ4_SEQ AS SEQUENCIA "
	cQuery += "         FROM <<FQ4_COMPANY>> FQ4
	cQuery += " 		LEFT JOIN <<ST9_COMPANY>> ST9 ON FQ4.FQ4_CODBEM = ST9.T9_CODBEM AND FQ4_FILIAL = '      ' "
	cQuery += " 		LEFT JOIN <<SA1_COMPANY>> SA1 ON SA1.A1_COD=FQ4.FQ4_CODCLI AND SA1.A1_LOJA=FQ4.FQ4_LOJCLI
	cQuery += " 		LEFT JOIN <<ST6_COMPANY>> ST6 ON ST6.T6_CODFAMI = FQ4.FQ4_CODFAM) AS CENTRALBENS
	cQuery += "      	GROUP BY BK_CADBEM)

Return cQuery

