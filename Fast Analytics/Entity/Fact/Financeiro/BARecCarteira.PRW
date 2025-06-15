#INCLUDE "BADEFINITION.CH"

NEW ENTITY RECARTEIRA

//-------------------------------------------------------------------
/*/{Protheus.doc} BARecCarteira
Visualiza as informacoes do Contas a Receber Carteira da area Financeiro.

@author  BI TEAM
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Class BARecCarteira from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  BI TEAM
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BARecCarteira
	_Super:Setup("ReceberCarteira", FACT, "SE1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrùi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  BI TEAM
@since   05/01/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BARecCarteira
    Local cQuery := ""
	
    cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA " +;
                        " ,<<KEY_FILIAL_E1_FILIAL>> AS BK_FILIAL " +;
                        " ,<<KEY_SX5_TIPO.X5_FILIAL+E1_TIPO>> AS BK_ESPEC_DOC " +;
                        " ,<<KEY_CTT_CTT_FILIAL+E1_CCUSTO>> AS BK_CENTRO_CUSTO " +;
                        " ,<<KEY_SED_ED_FILIAL+E1_NATUREZ>> AS BK_NAT_FINANCEIRA " +;
                        " ,<<KEY_SA1_A1_FILIAL+E1_CLIENTE+E1_LOJA>> AS BK_CLIENTE " +;
                        " ,<<KEY_FILIAL_E1_FILORIG>> AS BK_FILIAL_ORIGEM " +;
                        " ,CASE WHEN SA1.A1_COD_MUN = ' ' THEN <<KEY_CC2_A1_EST>> ELSE <<KEY_CC2_A1_EST+A1_COD_MUN>> END AS BK_REGIAO " +;
                        " ,<<KEY_SA3_A3_FILIAL+E1_VEND1>> AS BK_VENDEDOR " +;
                        " ,<<KEY_SA6_A6_FILIAL+E1_BCOCLI+E1_AGEDEP+E1_NUMCON>> AS BK_BCO " +;
                        " ,E1_EMISSAO AS DATA_DE_EMISSAO " +;
                        " ,CASE WHEN E1_SALDO > 0 THEN '' ELSE E1_BAIXA END AS DATA_DA_BAIXA_DO_TITULO " +;
                        " ,E1_MOVIMEN AS DATA_DA_MOVIMENTACAO " +;
                        " ,E1_VENCREA AS VENCIMENTO_REAL " +;
                        " ,E1_NUM AS NUMERO_TITULO " +;
                        " ,E1_PARCELA AS NUMERO_DA_PARCELA " +;
                        " ,E1_NUMBOR AS NUMERO_DO_BORDERO " +;
                        " ,E1_LOJA AS LOJA " +;
                        " ,A1_TIPO AS TIPO_DE_FORNECEDOR " +;
                        " ,E1_PREFIXO AS PREFIXO_TITULO " +;
                        " ,E1_SEQBX AS SEQUENCIA_DA_BAIXA " +;
                        " ,CASE WHEN E1_TIPO IN ('NCC', 'RA') THEN (CASE WHEN E1_VALOR <> E1_SALDO THEN E1_SALDO ELSE E1_VALOR END) * - 1 ELSE (CASE WHEN E1_VALOR <> E1_SALDO THEN E1_SALDO ELSE E1_VALOR END) END AS VALOR_DA_MOVIMENTACAO " +;
                        " ,CASE WHEN E1_TIPO IN ('NCC', 'RA') THEN E1_VALOR * - 1 ELSE E1_VALOR END AS VALOR_ORIGINAL " +;
                        " ,CASE WHEN E1_TIPO IN ('NCC', 'RA') THEN E1_SALDO * - 1 ELSE E1_SALDO END AS VALOR_VENCIMENTO " +;
                        " ,E1_DESCONT AS VALOR_DO_DESCONTO " +;
                        " ,E1_JUROS AS VALOR_DO_JUROS " +;
                        " ,E1_MULTA AS VALOR_DA_MULTA " +;
                        " ,E1_ACRESC AS VALOR_ACRESCIMO " +;
                        " ,E1_DECRESC AS VALOR_DECRESCIMO " +;
                        " ,E1_MOVIMEN AS DATA_DA_DISPONIBILIDADE " +;
                        " ,E1_TIPO AS TIPO " +;
                        " ,E1_VENCTO AS VENCIMENTO_ORIGINAL " +;
                        " ,E1_HIST AS HISTORICO " +;
                        " ,E1_FLUXO " +;
                        " ,E1_EMIS1 AS DT_DIGITACAO " +;
                        " ,CAST('CLIENTE' AS CHAR(10)) AS TIPO_CLIFOR " +;
                        " ,<<CODE_INSTANCE>> AS INSTANCIA " +;
                " ,<<KEY_MOEDA_E1_MOEDA>> AS BK_MOEDA  " +;
                " ,COALESCE(E1_TXMOEDA,0) AS TAXA_MOEDA  " +;
                " FROM SE1010 SE1 " +;
                " LEFT JOIN SA1010 SA1 " +;
                        " ON A1_FILIAL = <<SUBSTR_SA3_E1_FILIAL>>  " +;
                                " AND A1_COD = E1_CLIENTE " +;
                                " AND A1_LOJA = E1_LOJA " +;
                                " AND SA1.D_E_L_E_T_ = ' ' " +;
                " LEFT JOIN SA6010 SA6 " +;
                        " ON A6_FILIAL = <<SUBSTR_SA6_E1_FILIAL>>  " +;
                                " AND SA6.A6_COD = E1_BCOCLI " +;
                                " AND SA6.A6_AGENCIA = E1_AGECLI " +;
                                " AND SA6.A6_NUMCON = E1_CTACLI " +;
                                " AND SA6.D_E_L_E_T_ = ' ' " +;
                " LEFT JOIN SX5010 DOCESP " +;
                        " ON DOCESP.X5_FILIAL = <<ALIAS_DOCESP>><<SUBSTR_SX5_E1_FILIAL>>  " +;
                                " AND DOCESP.X5_TABELA = '05' " +;
                                " AND DOCESP.X5_CHAVE = E1_TIPO " +;
                                " AND DOCESP.D_E_L_E_T_ = ' ' " +;
                " LEFT JOIN CTT010 CTT " +;
                        " ON CTT_FILIAL = <<SUBSTR_CTT_E1_FILIAL>>  " +;
                                " AND CTT_CUSTO = E1_CCUSTO " +;
                                " AND CTT.D_E_L_E_T_ = ' ' " +;
                " LEFT JOIN SED010 SED " +;
                        " ON ED_FILIAL = <<SUBSTR_SED_E1_FILIAL>>  " +;
                                " AND ED_CODIGO = E1_NATUREZ " +;
                                " AND SED.D_E_L_E_T_ = ' ' " +;
                " LEFT JOIN <<SA3_COMPANY>> SA3  " +;
                " ON SA3.A3_FILIAL = <<SUBSTR_SA3_E1_FILIAL>>  " +;
                        " AND SA3.A3_COD = SE1.E1_VEND1  " +;
                        " AND SA3.D_E_L_E_T_ = ' ' " +;
                " WHERE ( " +;
                                " E1_BAIXA = ' ' " +;
                                " OR E1_SALDO > 0 " +;
                                " ) " +;
                        " AND SE1.D_E_L_E_T_ = ' ' " +;
                        " AND E1_VENCTO BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " +;
                        " <<AND_XFILIAL_E1_FILIAL>> " 
                        
Return cQuery	
