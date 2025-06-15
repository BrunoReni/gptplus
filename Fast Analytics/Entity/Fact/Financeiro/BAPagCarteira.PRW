#INCLUDE "BADEFINITION.CH"

NEW ENTITY PAGCARTEIRA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPagCarteira
Visualiza as informacoes de Contas a Pagar Carteira da area do Financeiro.

@author  Andreia Lima
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Class BAPagCarteira from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Andreia Lima
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPagCarteira
	_Super:Setup("PagamentoCarteira", FACT, "SE2")   
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andreia Lima
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPagCarteira
	Local cQuery := ""
	
	cQuery := "SELECT <<KEY_COMPANY>> AS BK_EMPRESA " +;
                " ,E2_DECRESC AS VALOR_DECRESCIMO " +;
                " ,E2_DATALIB AS DATA_DA_DISPONIBILIDADE " +;
                " ,E2_TIPO AS TIPO " +;
                " ,<<KEY_FILIAL_E2_FILIAL>> AS BK_FILIAL " +;
                " ,<<KEY_SX5_TIPO.X5_FILIAL+E2_TIPO>>AS BK_ESPEC_DOC " +;
                " ,<<KEY_CTT_CTT_FILIAL+E2_CCUSTO>> AS BK_CENTRO_CUSTO " +;
                " ,<<KEY_SED_ED_FILIAL+E2_NATUREZ>>  AS BK_NAT_FINANCEIRA " +;
                " ,<<KEY_SA2_A2_FILIAL+E2_FORNECE+E2_LOJA>>AS BK_FORNECEDOR " +;
                " ,<<KEY_FILIAL_E2_FILORIG>> AS BK_FILIAL_ORIGEM " +;
                " ,CASE WHEN A2_COD_MUN = ' ' THEN <<KEY_CC2_A2_EST>> ELSE <<KEY_CC2_A2_EST+A2_COD_MUN>> END  AS BK_REGIAO " +;
                " ,<<KEY_SX5_GRU.X5_FILIAL+A2_GRUPO>> AS BK_GRUPO_FORNECEDOR " +;
                " ,<<KEY_SA6_A6_FILIAL+E2_BCOPAG+A6_AGENCIA+A6_NUMCON>>  AS BK_BCO " +;
                " ,<<EXTRACTION_DATE>> AS DATA_DA_EXTRACAO " +;
                " ,E2_EMISSAO AS DATA_DE_EMISSAO " +;
                " ,CASE WHEN E2_SALDO > 0 THEN '' ELSE E2_BAIXA END AS DATA_DA_BAIXA_DO_TITULO " +;
                " ,E2_MOVIMEN AS DATA_DA_MOVIMENTACAO " +;
                " ,E2_VENCREA AS VENCIMENTO_REAL " +;
                " ,E2_NUM AS NUMERO_TITULO " +;
                " ,E2_PARCELA AS NUMERO_DA_PARCELA " +;
                " ,E2_NUMBOR AS NUMERO_DO_BORDERO " +;
                " ,E2_LOJA AS LOJA " +;
                " ,A2_TIPO AS TIPO_DE_FORNECEDOR " +;
                " ,E2_PREFIXO AS PREFIXO_TITULO " +;
                " ,E2_SEQBX AS SEQUENCIA_DA_BAIXA " +;
                " ,CASE WHEN E2_TIPO IN ('NDF', 'PA') THEN (CASE WHEN E2_VALOR <> E2_SALDO THEN E2_SALDO ELSE E2_VALOR END) * - 1 ELSE (CASE WHEN E2_VALOR <> E2_SALDO THEN E2_SALDO ELSE E2_VALOR END) END AS VALOR_DA_MOVIMENTACAO " +;
                " ,CASE WHEN E2_TIPO IN ('NDF', 'PA') THEN E2_VALOR * - 1 ELSE E2_VALOR END AS VALOR_ORIGINAL " +;
                " ,CASE WHEN E2_TIPO IN ('NDF', 'PA') THEN E2_SALDO * - 1 ELSE E2_SALDO END AS VALOR_VENCIMENTO " +;
                " ,E2_DESCONT AS VALOR_DO_DESCONTO " +;
                " ,E2_JUROS AS VALOR_DO_JUROS " +;
                " ,E2_MULTA AS VALOR_DA_MULTA " +;
                " ,E2_ACRESC AS VALOR_ACRESCIMO " +;
                " ,E2_VENCTO AS VENCIMENTO_ORIGINAL " +;
                " ,E2_HIST AS HISTORICO " +;
                " ,E2_FLUXO " +;
                " ,E2_EMIS1 AS DT_DIGITACAO " +;
                " ,CAST('FORNECEDOR' AS CHAR(10)) AS TIPO_CLIFOR " +;
                " ,<<CODE_INSTANCE>> AS INSTANCIA " +;
                " ,<<KEY_MOEDA_E2_MOEDA>> AS BK_MOEDA " +;
                " ,COALESCE(E2_TXMOEDA,0) AS TAXA_MOEDA " +;
            " FROM <<SE2_COMPANY>> SE2 " +;
            " LEFT JOIN SA2_COMPANY>> SA2 " +;
                " ON A2_FILIAL = <<SUBSTR_SA2_E2_FILIAL>> " +;
                    " AND A2_COD = E2_FORNECE " +;
                    " AND A2_LOJA = E2_LOJA " +;
                    " AND SA2.D_E_L_E_T_ = ' ' " +;
            " LEFT JOIN <<SA6_COMPANY>> SA6 " +;
                " ON A6_FILIAL = <<SUBSTR_SA6_E2_FILIAL>> " +;
                    " AND SA6.A6_COD = E2_BCOPAG " +;
                    " AND SA6.A6_AGENCIA = E2_FORAGE " +;
                    " AND SA6.A6_NUMCON = E2_FORCTA " +;
                    " AND SA6.D_E_L_E_T_ = ' ' " +;
            " LEFT JOIN <<SX5_COMPANY>> DOCESP " +;
                " ON DOCESP.X5_FILIAL = <<ALIAS_DOCESP>><<SUBSTR_SX5_E2_FILIAL> " +;
                    " AND DOCESP.X5_TABELA = '05' " +;
                    " AND DOCESP.X5_CHAVE = E2_TIPO " +;
                    " AND DOCESP.D_E_L_E_T_ = ' ' " +;
            " LEFT JOIN <<CTT_COMPANY>> CTT " +;
                " ON CTT_FILIAL = <<SUBSTR_CTT_E2_FILIAL>> " +;
                    " AND CTT_CUSTO = E2_CCUSTO " +;
                    " AND CTT.D_E_L_E_T_ = ' ' " +;
            " LEFT JOIN <<SED_COMPANY>> SED " +;
                " ON ED_FILIAL = <<SUBSTR_SED_E2_FILIAL>> " +;
                    " AND ED_CODIGO = E2_NATUREZ " +;
                    " AND SED.D_E_L_E_T_ = ' ' " +;
            " LEFT JOIN <<SX5_COMPANY>> GRPFORN " +;
                " ON GRPFORN.X5_FILIAL = <<ALIAS_GRPFORN>><<SUBSTR_SX5_E2_FILIAL> " +;
                    " AND GRPFORN.X5_TABELA = 'Y7' " +;
                    " AND GRPFORN.X5_CHAVE = A2_GRUPO " +;
                    " AND GRPFORN.D_E_L_E_T_ = ' ' " +;
            " WHERE ( " +;
            " 		E2_BAIXA = ' ' " +;
                    " OR E2_SALDO > 0 " +;
                    " ) " +;
                " AND SE2.D_E_L_E_T_ = ' ' " +;
                " AND E2_VENCTO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " +;
                " <<AND_XFILIAL_E2_FILIAL>>  "
                
Return cQuery	
