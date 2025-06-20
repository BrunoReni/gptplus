#INCLUDE "PROTHEUS.CH"
#INCLUDE "QUICKSEARCH.CH"
#INCLUDE "TECQ016.CH"

QSSTRUCT TECQ016 DESCRIPTION STR0001 MODULE 28 // "Contratos a vencer com saldo de materiais de implanta��o" 

QSMETHOD INIT QSSTRUCT TECQ016
Local cWhere := ""

	QSTABLE "CN9" JOIN "TFJ" ON "TFJ.TFJ_CONTRT = CN9.CN9_NUMERO AND TFJ.TFJ_CONREV = CN9.CN9_REVISA"
	QSTABLE "CN9" JOIN "CNC" ON "CNC.CNC_NUMERO = CN9.CN9_NUMERO AND CNC.CNC_REVISA = CN9.CN9_REVISA"
	QSTABLE "CN9" JOIN "TFF" ON "TFF.TFF_CONTRT = CN9.CN9_NUMERO AND TFF.TFF_CONREV = CN9.CN9_REVISA"
	QSTABLE "TFF" JOIN "TFG" ON "TFG.TFG_CODPAI = TFF.TFF_COD AND TFG.TFG_SLD > 0" 
	QSTABLE "CN9" LEFT JOIN "CN1" ON "CN1.CN1_CODIGO = CN9.CN9_TPCTO" 
	QSTABLE "TFG" LEFT JOIN "SB1" ON "SB1.B1_COD = TFG.TFG_PRODUT" 
	
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "CN9_NUMERO" INDEX ORDER 1
	QSPARENTFIELD "TFG_PRODUT" INDEX ORDER 4 
	
	// campos do SX3
	QSFIELD "CN9_NUMERO","CN9_DTFIM","B1_DESC" 
	QSFIELD SUM "TFG_QTDVEN"
	QSFIELD SUM "TFG_SLD"
	
	cWhere := "CN9.CN9_SITUAC = '05' AND CN9.CN9_DTFIM BETWEEN '"+ DTOS(Date())+"' AND '{1}'"
	
	QSFILTER STR0002 WHERE "CN9.CN9_SITUAC = '05' AND CN9.CN9_DTFIM = '"+ DTOS(Date()) +"'" // "Hoje" 
	QSFILTER STR0003 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 7)) // "Pr�ximos 7 dias" 
	QSFILTER STR0004 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 30)) // "Pr�ximos 30 dias" 
	QSFILTER STR0005 WHERE StrTran(cWhere, "{1}", DTOS(Date() + 60)) // "Pr�ximos 60 dias"
Return
