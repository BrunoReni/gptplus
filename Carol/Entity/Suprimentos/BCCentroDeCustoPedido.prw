#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL CCUSTOPEDIDO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCCentroDeCustoPedido
Visualizacao das informacoes dos centros  de custo  dos pedidos.

@author  andreia.lima
@since   27/11/2020

/*/
//-------------------------------------------------------------------
Class BCCentroDeCustoPedido from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  andreia.lima
@since   27/11/2020

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCCentroDeCustoPedido
	_Super:Setup("BCCentroCustoPedido", FACT, "SC7", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  andreia.lima
@since   27/11/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCCentroDeCustoPedido
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
                  "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
                  "<<CODE_COMPANY>> AS EMPRESA, " + ;
                    "C7_FILIAL AS FILIAL, " + ;
                    "C7_EMISSAO AS EMISSAO, " + ; 
                    "C7_FORNECE AS FORNECE, C7_LOJA AS LOJA, A2_NOME AS NOME_FORNECEDOR, " + ;
                    "C7_NUM AS PEDIDO, " + ;
                    "C7_ITEM AS ITEMPEDIDO, C7_PRODUTO AS PRODUTO, B1_DESC AS PRODUTO_DESCRICAO, " + ;
                    "CH_ITEM AS ITEMCC, " + ;
                    "CASE " + ;
                      "WHEN (CH_CC IS NULL) THEN C7_CC " + ;
                      "ELSE CH_CC " + ;
                    "END AS CENTROCUSTO, " + ;
                    "COALESCE(CTT2.CTT_DESC01, CTT.CTT_DESC01) AS CENTROCUSTO_DESCRICAO, " +;
                    "C7_PRECO AS VALORUNITARIO, " + ;
                    "CASE " + ;
					            "WHEN (CH_PERC IS NULL) THEN C7_QUANT " + ;
                      "ELSE (C7_QUANT * CH_PERC)/100 " + ;
                    "END AS QUANTIDADE, " + ;
                    "CASE " + ;
                      "WHEN (CH_PERC IS NULL) THEN C7_TOTAL " + ;
                      "ELSE (C7_QUANT * CH_PERC)/100 * C7_PRECO " + ;
                    "END AS VALORTOTAL, " + ;
                    "C7_QUJE AS QTDENTREGUE, C7_MOEDA AS MOEDA " + ;    
               "FROM <<SC7_COMPANY>> SC7 " + ;
               "LEFT OUTER JOIN <<SCH_COMPANY>> SCH " + ; 
                 "ON CH_FILIAL = <<SUBSTR_SCH_C7_FILIAL>> " + ; 
                "AND C7_NUM = CH_PEDIDO " + ; 
                "AND C7_FORNECE = CH_FORNECE " + ;
                "AND C7_LOJA = CH_LOJA " + ;
                "AND C7_ITEM = CH_ITEMPD " + ; 
                "AND SC7.D_E_L_E_T_ = SCH.D_E_L_E_T_ " + ; 
               "LEFT JOIN <<SA2_COMPANY>> SA2 " + ;
                 "ON A2_FILIAL = <<SUBSTR_SA2_C7_FILIAL>> " + ;
                "AND A2_COD = SC7.C7_FORNECE " + ;
                "AND A2_LOJA = SC7.C7_LOJA " + ;
                "AND SA2.D_E_L_E_T_ = ' ' " + ;
               "LEFT JOIN <<SB1_COMPANY>> SB1 " + ;
                 "ON B1_FILIAL = <<SUBSTR_SB1_C7_FILIAL>> " + ;
                "AND B1_COD = SC7.C7_PRODUTO " + ;
                "AND SB1.D_E_L_E_T_ = ' ' " + ;
               "LEFT JOIN <<CTT_COMPANY>> CTT " + ;
                 "ON CTT.CTT_FILIAL = <<SUBSTR_CTT_C7_FILIAL>> " +;
                "AND CTT.CTT_CUSTO = SC7.C7_CC " + ;
                "AND CTT.D_E_L_E_T_ = ' ' " + ;
               "LEFT JOIN <<CTT_COMPANY>> CTT2 " + ;
                 "ON CTT2.CTT_FILIAL = <<SUBSTR_SCH_C7_FILIAL>> " +;
                "AND CTT2.CTT_CUSTO = SCH.CH_CC " + ;
                "AND CTT2.D_E_L_E_T_ = ' ' " + ;
              "WHERE SC7.D_E_L_E_T_= ' ' " + ;
                "AND ( (COALESCE(RTRIM(C7_CC),' ') <> ' ') OR (CH_PEDIDO IS NOT NULL) ) " + ;
                "AND C7_EMISSAO >= <<HISTORIC_PERIOD(4)>> "		     
             
Return cView	
