#INCLUDE "BADEFINITION.CH"

NEW ENTITY PAGAMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPagamento
Visualiza as informacoes das titulos a pagar que foram emitidos e que
foram parcialmente ou totalmente pagos.

@author  Helio Leal
@since   04/01/2018
/*/
//-------------------------------------------------------------------
Class BAPagamento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao

@author  Helio Leal
@since   04/01/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPagamento
	_Super:Setup("Pagamento", FACT, "SE2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@since   04/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPagamento
	Local cQuery := ""

	cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA " +;
					" ,E5_TIPO AS TIPO " +;
					" ,<<KEY_FILIAL_E2_FILIAL>> AS BK_FILIAL " +;
					" ,<<KEY_SX5_DOCESP.X5_FILIAL+E2_TIPO>> AS BK_ESPEC_DOC " +;
					" ,<<KEY_SA2_A2_FILIAL+E2_FORNECE+E2_LOJA>>  AS BK_FORNECE " +;
					" ,<<KEY_STTIT_X5_FILIAL+E5_SITUACA>> AS BK_MODALCOBRANCA " +;
					" ,<<KEY_CTT_CTT_FILIAL+E2_CCUSTO>> AS BK_CENTRO_CUSTO " +;
					" ,<<KEY_SED_ED_FILIAL+E2_NATUREZ>> AS BK_NAT_FINANCEIRA " +;
					" ,<<KEY_SA6_A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON>> AS BK_BCO " +;
					" ,<<KEY_FILIAL_E2_FILORIG>>  AS BK_FILIAL_ORIGEM " +;
					" ,CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END AS BK_REGIAO " +;
					" ,<<KEY_SX5_GRPFORN.X5_FILIAL+A2_GRUPO>> AS BK_GRUPO_FORNECEDOR " +;
					" ,E2_EMISSAO AS DATA_DE_EMISSAO_TITULO " +;
					" ,E2_VENCREA AS VENCIMENTO_REAL " +;
					" ,E5_PREFIXO AS PREFIXO_TITULO " +;
					" ,E5_NUMERO AS NUMERO_TITULO " +;
					" ,E5_PARCELA AS NUMERO_DA_PARCELA " +;
					" ,E2_NUMBOR AS NUMERO_DO_BORDERO " +;
					" ,coalesce(E2_VALOR, E5_VALOR) AS VALOR_ORIGINAL " +;
					" ,E5_VALOR AS VALOR_DA_MOVIMENTACAO " +;
					" ,CASE WHEN E2_SALDO > 0 THEN E2_SALDO - E2_INSS - E2_PIS - E2_COFINS - E2_CSLL - E2_IRRF - E2_VRETISS - E2_SDDECRE + E2_SDACRES ELSE E2_SALDO END AS SALDO_PAGAR " +;
					" ,E5_DATA AS DATA_DA_BAIXA_DO_TITULO " +;
					" ,E5_VLDESCO AS VALOR_DO_DESCONTO " +;
					" ,E5_VLJUROS AS VALOR_DO_JUROS " +;
					" ,E5_VLMULTA AS VALOR_DA_MULTA " +;
					" ,E5_VLACRES AS VALOR_ACRESCIMO " +;
					" ,E5_VLDECRE AS VALOR_DECRESCIMO " +;
					" ,E5_DTDISPO AS DATA_DA_DISPONIBILIDADE " +;
					" ,E2_VENCTO AS VENCIMENTO " +;
					" ,E5_VRETINS AS VALOR_INSS " +;
					" ,E5_VRETPIS AS VALOR_PIS " +;
					" ,E5_VRETCOF AS VALOR_COFINS " +;
					" ,E5_VRETCSL AS VALOR_CSLL " +;
					" ,E5_VRETIRF AS VALOR_IRRF " +;
					" ,E2_ISS AS VALOR_ISS " +;
					" ,E5_VRETISS AS VALOR_ISS_RETIDO " +;
					" ,E2_VALLIQ AS VALOR_LIQUIDO " +;
					" ,E2_SDDECRE AS SALDO_DECRESCIMO " +;
					" ,E2_SDACRES AS SALDO_ACRESCIMO " +;
					" ,E2_TIPOLIQ AS TIPO_LIQUIDACAO " +;
					" ,E5_TIPODOC AS TIPO_DOC_E5 " +;
					" ,(CASE WHEN E5_TIPODOC IN ('TR', 'TE') THEN 'NOR' ELSE E5_MOTBX END) AS MOTIVO_BAIXA " +;
					" ,'' AS CODIGO_PEDIDO_VENDA " +;
					" ,E2_HIST AS HISTORICO " +;
					" ,E5_VALOR " +;
					" ,E5_DTDIGIT AS DATA_DIGITACAO " +;
					" ,E2_FLUXO " +;
					" ,CASE WHEN E5_CLIENTE <> '' THEN 'CLIENTE' ELSE 'FORNECEDOR' END AS TIPO_CLIFOR " +;
					" ,<<CODE_INSTANCE>> AS INSTANCIA " +;
					" ,<<KEY_MOEDA_E2_MOEDA>> AS BK_MOEDA  " +;
					" ,COALESCE(E2_TXMOEDA,0) AS TAXA_MOEDA  " +;
				" FROM <<SE5_COMPANY>> SE5 WITH (NOLOCK) " +;
				" LEFT OUTER JOIN SE2_COMPANY>> SE2 WITH (NOLOCK) " +;
					" ON SE2.E2_FILORIG = SE5.E5_FILORIG " +;
						" AND SE2.E2_FILIAL  = <<SUBSTR_SE2_E5_FILIAL>> " +;
						" AND SE2.E2_NUM = SE5.E5_NUMERO " +;
						" AND SE2.E2_PREFIXO = SE5.E5_PREFIXO " +;
						" AND SE2.E2_PARCELA = SE5.E5_PARCELA " +;
						" AND SE2.E2_FORNECE = SE5.E5_FORNECE " +;
						" AND SE2.E2_LOJA = SE5.E5_LOJA " +;
						" AND SE2.D_E_L_E_T_ = ' ' " +;
				" LEFT JOIN <<SA2_COMPANY>> SA2 WITH (NOLOCK) " +;
					" ON A2_FILIAL = <<SUBSTR_SA2_E5_FILIAL>> " +;
						" AND SA2.A2_COD = E5_FORNECE " +;
						" AND SA2.A2_LOJA = E5_LOJA " +;
						" AND SA2.D_E_L_E_T_ = ' ' " +;
				" LEFT JOIN <<CTT_COMPANY>> CTT WITH (NOLOCK) " +;
					" ON CTT_CUSTO = E5_CCUSTO " +;
						" AND CTT.D_E_L_E_T_ = ' ' " +;
				" LEFT JOIN <<SED_COMPANY>> SED WITH (NOLOCK) " +;
					" ON ED_FILIAL = <<SUBSTR_SE2_E5_FILIAL>> " +;
						" AND ED_CODIGO = E5_NATUREZ " +;
						" AND SED.D_E_L_E_T_ = ' ' " +;
				" LEFT JOIN <<SA6_COMPANY>> SA6 WITH (NOLOCK) " +;
					" ON A6_FILIAL = <<SUBSTR_SA6_E5_FILIAL>> " +;
						" AND A6_COD = E5_BANCO " +;
						" AND A6_AGENCIA = E5_AGENCIA " +;
						" AND A6_NUMCON = E5_CONTA " +;
						" AND SA6.D_E_L_E_T_ = ' ' " +;
				" LEFT JOIN <<SX5_COMPANY>> TPTIT WITH (NOLOCK) " +;
					" ON X5_FILIAL = <<ALIAS_TPTIT>><<SUBSTR_SX5_E5_FILIAL>> " +;
						" AND X5_TABELA = '05' " +;
						" AND X5_CHAVE = E5_TIPO " +;
						" AND TPTIT.D_E_L_E_T_ = ' ' " +;
				" LEFT JOIN <<SX5_COMPANY>> STTIT WITH (NOLOCK) " +;
					" ON STTIT.X5_FILIAL = <<ALIAS_STTIT>><<SUBSTR_SX5_E5_FILIAL>> " +;
						" AND STTIT.X5_TABELA = '07' " +;
						" AND STTIT.X5_CHAVE = E5_SITUACA " +;
						" AND STTIT.D_E_L_E_T_ = ' ' " +;
				" WHERE SE5.E5_TIPO NOT IN ('AB-', 'FB-', 'FC-', 'FU-', 'IR-', 'IN-', 'IS-', 'PI-', 'CF-', 'CS-', 'FE-', 'IV-', 'DIC', 'DC ') " +;
					" AND SE5.E5_TIPODOC NOT IN ('MT', 'ES', 'JR', 'DC') " +;
					" AND SE5.E5_RECPAG = 'P' " +;
					" AND SE5.E5_DTCANBX = '' " +;
					" AND SE5.E5_SITUACA <> 'C' " +;
					" AND SE5.D_E_L_E_T_ = ' ' " +;
					" AND SE5.E5_DATA BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " +;
					" <<AND_XFILIAL_E2_FILIAL>>  " 



 Return cQuery	
