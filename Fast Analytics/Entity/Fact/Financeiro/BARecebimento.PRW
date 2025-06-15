#INCLUDE "BADEFINITION.CH"

NEW ENTITY RECEBIMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BARecebimento
Visualiza as informacoes das Contas a Receber da area de Financeiro.

@author  Angelo Lee
@since   02/01/2018
/*/
//-------------------------------------------------------------------
Class BARecebimento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BARecebimento
	_Super:Setup("Recebimento", FACT, "SE1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author Helio Leal
@since   06/11/2017
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARecebimento
	Local cQuery := ""

	cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA " +;
				" ,<<KEY_FILIAL_E1_FILIAL>> AS BK_FILIAL " +;
				" ,<<KEY_SX5_TPTIT.X5_FILIAL+E5_TIPO>> AS BK_ESPEC_DOC " +;
				" ,<<KEY_SA1_A1_FILIAL+E1_CLIENTE+E1_LOJA>> AS BK_CLIENTE " +;
				" ,<<KEY_SX5_STTIT.X5_FILIAL+E1_SITUACA>> AS BK_MODALCOBRANCA " +;
				" ,<<KEY_CTT_CTT_FILIAL+E1_CCUSTO>> AS BK_CENTRO_CUSTO " +;
				" ,<<KEY_SED_ED_FILIAL+E1_NATUREZ>> AS BK_NAT_FINANCEIRA " +;
				" ,<<KEY_SA6_A6_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA>> AS BK_BCO " +;
				" ,<<KEY_FILIAL_E5_FILORIG>> AS BK_FILIAL_ORIGEM " +;
				" ,CASE WHEN A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO " +;
				" ,<<KEY_SA1_A1_FILIAL+A1_TIPO>> AS BK_GRUPO_CLIENTE " +;
				" ,E1_EMISSAO AS DATA_DE_EMISSAO_TITULO " +;
				" ,E1_VENCREA AS VENCIMENTO_REAL " +;
				" ,E1_PREFIXO AS PREFIXO_TITULO " +;
				" ,E1_NUM AS NUMERO_TITULO " +;
				" ,E1_PARCELA AS NUMERO_DA_PARCELA " +;
				" ,E1_NUMBOR AS NUMERO_DO_BORDERO " +;
				" ,E1_VALOR AS VALOR_DA_MOVIMENTACAO " +;
				" ,CASE WHEN E1_SALDO > 0 THEN E1_SALDO - E1_INSS - E1_PIS - E1_COFINS - E1_CSLL - E1_IRRF - E1_VRETISS - E1_SDDECRE + E1_SDACRES ELSE E1_SALDO END AS SALDO_RECEBER " +;
				" ,E5_DATA AS DATA_DA_BAIXA_DO_TITULO " +;
				" ,E1_DESCONT AS VALOR_DO_DESCONTO " +;
				" ,E1_JUROS AS VALOR_DO_JUROS " +;
				" ,E1_MULTA AS VALOR_DA_MULTA " +;
				" ,E1_ACRESC AS VALOR_ACRESCIMO " +;
				" ,E1_DECRESC AS VALOR_DECRESCIMO " +;
				" ,E1_MOVIMEN AS DATA_DA_DISPONIBILIDADE " +;
				" ,E5_TIPO AS TIPO " +;
				" ,E1_VENCTO AS VENCIMENTO " +;
				" ,E1_INSS AS VALOR_INSS " +;
				" ,E1_PIS AS VALOR_PIS " +;
				" ,E1_COFINS AS VALOR_COFINS " +;
				" ,E1_CSLL AS VALOR_CSLL " +;
				" ,E1_IRRF AS VALOR_IRRF " +;
				" ,E1_ISS AS VALOR_ISS " +;
				" ,E1_VRETISS AS VALOR_ISS_RETIDO " +;
				" ,E1_VALLIQ AS VALOR_LIQUIDO " +;
				" ,E1_SDDECRE AS SALDO_DECRESCIMO " +;
				" ,E1_SDACRES AS SALDO_ACRESCIMO " +;
				" ,E1_TIPOLIQ AS TIPO_LIQUIDACAO " +;
				" ,E5_TIPODOC AS TIPO_DOC_E5 " +;
				" ,E1_PEDIDO AS CODIGO_PEDIDO_VENDA " +;
				" ,E1_HIST AS HISTORICO " +;
				" ,E5_VALOR " +;
				" ,E5_DTDIGIT AS DATA_DIGITACAO " +;
				" ,E1_FLUXO " +;
				" ,CASE WHEN E5_CLIENTE <> '' THEN 'CLIENTE' ELSE 'FORNECEDOR' END AS TIPO_CLIFOR " +;
				" ,<<CODE_INSTANCE>> AS INSTANCIA " +;
				" ,<<KEY_MOEDA_E1_MOEDA>> AS BK_MOEDA  " +;
				" ,COALESCE(E1_TXMOEDA,0) AS TAXA_MOEDA  " +;
			" FROM <<SE5_COMPANY>> SE5 WITH (NOLOCK) " +;
			" LEFT OUTER JOIN SE1010 SE1 WITH (NOLOCK) " +;
				" ON SE1.E1_FILIAL = <<SUBSTR_SE1_E5_FILIAL>> " +;
					" AND SE5.E5_FILORIG = SE1.E1_FILORIG " +;
					" AND SE5.E5_NUMERO = SE1.E1_NUM " +;
					" AND SE5.E5_PREFIXO = SE1.E1_PREFIXO " +;
					" AND SE5.E5_PARCELA = SE1.E1_PARCELA " +;
					" AND SE5.E5_CLIENTE = SE1.E1_CLIENTE " +;
					" AND SE5.E5_LOJA = SE1.E1_LOJA " +;
					" AND SE1.D_E_L_E_T_ = ' ' " +;
			" LEFT JOIN <<SA1_COMPANY>> SA1 WITH (NOLOCK) " +;
				" ON A1_FILIAL = <<SUBSTR_SA1_E5_FILIAL>> " +;
					" AND SA1.A1_COD = E5_CLIENTE " +;
					" AND SA1.A1_LOJA = E5_LOJA " +;
					" AND SA1.D_E_L_E_T_ = ' ' " +;
			" LEFT JOIN <<CTT_COMPANY>> CTT WITH (NOLOCK) " +;
				" ON CTT_FILIAL = <<SUBSTR_CTT_E5_FILIAL>>  " +;
					" AND CTT_CUSTO = E1_CCUSTO " +;
					" AND CTT.D_E_L_E_T_ = ' ' " +;
			" LEFT JOIN <<SED_COMPANY>> SED WITH (NOLOCK) " +;
				" ON ED_FILIAL = <<SUBSTR_SED_E5_FILIAL>> " +;
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
			" LEFT JOIN SX5010 STTIT WITH (NOLOCK) " +;
				" ON STTIT.X5_FILIAL = <<ALIAS_STTIT>><<SUBSTR_SX5_E5_FILIAL>> " +;
					" AND STTIT.X5_TABELA = '07' " +;
					" AND STTIT.X5_CHAVE = E5_SITUACA " +;
					" AND STTIT.D_E_L_E_T_ = ' ' " +;
			" WHERE SE5.E5_TIPO NOT IN ('AB-', 'FB-', 'FC-', 'FU-', 'IR-', 'IN-', 'IS-', 'PI-', 'CF-', 'CS-', 'FE-', 'IV-', 'DIC') " +;
				" AND SE5.E5_TIPODOC NOT IN ('MT', 'ES') " +;
				" AND SE5.E5_RECPAG = 'R' " +;
				" AND SE5.E5_DTCANBX = '' " +;
				" AND SE5.E5_SITUACA <> 'C' " +;
				" AND SE5.D_E_L_E_T_ = ' ' " +;
				" AND SE5.E5_DATA BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " +;
				" <<AND_XFILIAL_E5_FILIAL>> "  	

Return cQuery
