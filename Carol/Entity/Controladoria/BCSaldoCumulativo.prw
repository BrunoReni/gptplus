#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL SALDOCUMULATIVO

/*/{Protheus.doc} BCSaldoCumulativo
	Visualiza as informações de Saldo Cumulativo por  Conta
	@type class
	@author Ademar Fernandes Jr.
	@since 20/09/2021
/*/
Class BCSaldoCumulativo from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass


/*/{Protheus.doc} Setup
	Construtor padrão.
	@type Method
	@author Ademar Fernandes Jr.
	@since 20/09/2021
/*/
Method Setup( ) Class BCSaldoCumulativo
	_Super:Setup("Balance_Acc", FACT, "CQ0")
Return


/*/{Protheus.doc} BuildQuery
	Constrói a query da entidade.
	@type Method
	@author Ademar Fernandes Jr.
	@since 20/09/2021
	@return cView, caracter, Retorna a View
/*/
Method BuildView( ) Class BCSaldoCumulativo
	Local cView := ""
	Local cDtBase := Upper( TcGetDb() )
	Local nLess  := 3

	cView := "SELECT "
	cView += "TOTVS_LINHA_PRODUTO,INSTANCIA,EMPRESA,TABELA_SALDOS,FILIAL_SALDO, "
	cView += "COD_CONTA,COD_MOEDA,TIPO_SALDO,FLAG_LP, "
	cView += "SUM(SALDO) SALDO, "
	cView += "CAST(SUM(COALESCE(CQ0_CREDIT, 0)) AS DECIMAL(16, 2)) AS VLR_CRD, "
	cView += "CAST(SUM(COALESCE(CQ0_DEBITO, 0)) AS DECIMAL(16, 2)) AS VLR_DEB, "
	cView += "DATA_APURACAO,TIPO_CONTA,FILIAL_PLANO_CONTAS, "
	cView += "TABELA_PLANO_CONTAS,COND_NORMAL,DESC_CONTA,TIPO,CONTA_SUPERIOR, "
	Do Case
		Case ( "ORACLE" $ cDtBase )
			cView += "CONCAT(EXTRACT(YEAR FROM SYSDATE) -"+Str(nLess,1,0)+",'1231') AS ULTIMO_DIA "
		Case ( "POSTGRES" $ cDtBase )
			cView += "CONCAT(date_part('year', current_date - interval '"+Str(nLess,1,0)+" years'),'1231') AS ULTIMO_DIA "
		OtherWise // SQL SERVER.
			cView += "CONCAT(DATEPART(YEAR,DATEADD(yy, -"+Str(nLess,1,0)+",GetDate())),'1231') AS ULTIMO_DIA "
	EndCase
	cView += "from ( "

	cView += "SELECT "
	cView += "<<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " 
	cView += "<<CODE_INSTANCE>> AS INSTANCIA, " 
	cView += "<<CODE_COMPANY>> AS EMPRESA, " 
	cView += "'<<CQ0_COMPANY>>' AS TABELA_SALDOS, " 
	cView += "CQ0_FILIAL AS FILIAL_SALDO, " 
	cView += "CQ0_DATA AS DATA, " 
	cView += "CQ0_CONTA AS COD_CONTA, " 
	cView += "CQ0_MOEDA AS COD_MOEDA, " 
	cView += "CQ0_TPSALD AS TIPO_SALDO, " 
	cView += "CQ0_LP AS FLAG_LP, " 
	cView += "CQ0_DTLP AS DATA_APURACAO, "  
	cView += "CQ0_CREDIT, "  
	cView += "CQ0_DEBITO, " 
	cView += "CASE CT1_NORMAL "
	cView += "	WHEN '1' THEN COALESCE(CQ0_DEBITO - CQ0_CREDIT, 0) "
	cView += "	WHEN '2' THEN COALESCE(CQ0_CREDIT - CQ0_DEBITO, 0) "
	cView += "	ELSE 0 END AS SALDO, "

	cView += "I13.I13_TIPO AS TIPO_CONTA, " 
	cView += "CT1_FILIAL AS FILIAL_PLANO_CONTAS, " 
	cView += "'<<CT1_COMPANY>>' AS TABELA_PLANO_CONTAS, " 
	cView += "CT1_NORMAL AS COND_NORMAL, " 
	cView += "CT1_DESC01 AS DESC_CONTA, " 
	cView += "CT1_CTASUP AS CONTA_SUPERIOR, " 
	cView += "CASE CT1_NORMAL "
	cView += "	WHEN '1' THEN 'D' "
	cView += "	WHEN '2' THEN 'R' "
	cView += "	ELSE '' END AS TIPO "

	cView += "FROM <<CQ0_COMPANY>> CQ0 "
	cView += "INNER JOIN <<CT1_COMPANY>> CT1 ON "
	cView += 	"CT1_FILIAL = <<SUBSTR_CT1_CQ0_FILIAL>> "
	cView += 	"AND CT1_CONTA = CQ0_CONTA "
	cView += 	"AND CT1_NTSPED IN ( '01' ,'02' ,'03' ) " 	//-01=Conta de Ativo;02=Conta de Passivo;03=Patrimônio Líquido;04=Conta de Resultado;05=Conta de Compensação;09=Outras
	cView += 	"AND CT1.D_E_L_E_T_ = ' '  "
	cView += "LEFT JOIN I13 I13 ON "
	cView += 	"I13.I13_COD_CC = CT1.CT1_CONTA "
	cView += 	"AND I13.I13_FILIAL = CT1.CT1_FILIAL "
	cView += 	"AND I13.I13_EMPRES = <<CODE_COMPANY>> "
	cView += 	"AND I13.D_E_L_E_T_ = ' ' " 
	cView += "WHERE " 
	cView += 	"CQ0.D_E_L_E_T_ = ' ' "

	// cView += 	"AND CQ0_DATA < <<HISTORIC_PERIOD(3)>> "
	Do Case
		Case ( "ORACLE" $ cDtBase )
			cView += "AND CQ0_DATA < CONCAT(EXTRACT(YEAR FROM SYSDATE) -"+Str(nLess-1,1,0)+",'0101') "
		Case ( "POSTGRES" $ cDtBase )
			cView += "AND CQ0_DATA < CONCAT(date_part('year', current_date - interval '"+Str(nLess-1,1,0)+" years'),'0101') "
		OtherWise // SQL SERVER.
			cView += "AND CQ0_DATA < CONCAT(DATEPART(YEAR,DATEADD(yy, -"+Str(nLess-1,1,0)+",GetDate())),'0101') "
	EndCase

	cView += 	") CAROL_BALANCE_ACCUM "
	cView += "GROUP BY TOTVS_LINHA_PRODUTO,INSTANCIA,EMPRESA,TABELA_SALDOS,FILIAL_SALDO,COD_CONTA, "
	cView += "COD_MOEDA,TIPO_SALDO,FLAG_LP,  DATA_APURACAO,TIPO_CONTA,FILIAL_PLANO_CONTAS, "
	cView += "TABELA_PLANO_CONTAS,COND_NORMAL,DESC_CONTA,TIPO,CONTA_SUPERIOR "

Return cView
