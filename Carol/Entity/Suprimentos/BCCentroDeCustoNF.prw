#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL CCUSTONF

//-------------------------------------------------------------------
/*/{Protheus.doc} BCCentroDeCustoNF
Visualizacao das informacoes dos  centros  de custo dos documentos de entrada.

@author  andreia.lima
@since   19/11/2020

/*/
//-------------------------------------------------------------------
Class BCCentroDeCustoNF from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  andreia.lima
@since   19/11/2020

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCCentroDeCustoNF
	_Super:Setup("BCCentroCustoNF", FACT, "SD1", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  andreia.lima
@since   19/11/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCCentroDeCustoNF
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
                  "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
                  "<<CODE_COMPANY>> AS EMPRESA, " + ;
                    "D1_FILIAL AS FILIAL, " + ;
                    "D1_EMISSAO AS EMISSAO, " + ; 
                    "D1_DOC AS NF, D1_SERIE AS SERIE, " + ; 
                    "D1_FORNECE AS FORNECE, D1_LOJA AS LOJA, A2_NOME AS NOME_FORNECEDOR, " + ;
                    "C7_CONTRA AS CONTRATO, "  + ;
                    "D1_PEDIDO AS PEDIDO, " + ;
                    "D1_ITEM AS ITEMNF, D1_COD AS PRODUTO, B1_DESC AS PRODUTO_DESCRICAO, D1_UM AS UNIDADE, " + ;
                    "F1_COND AS CONDICAO, F1_MOEDA AS MOEDA, F1_RECBMTO AS RECEBIMENTO, " + ;
                    "DE_ITEM AS ITEMCC, " + ;
                    "CASE " + ;
                      "WHEN (DE_CC IS NULL) THEN D1_CC " + ;
                      "ELSE DE_CC " + ;
                    "END AS CENTROCUSTO, " + ;
                    "COALESCE(CTT2.CTT_DESC01, CTT.CTT_DESC01) AS CENTROCUSTO_DESCRICAO, " +;
                    "D1_VUNIT AS VALORUNITARIO, " + ;
                    "CASE " + ;
					            "WHEN (DE_PERC IS NULL) THEN D1_QUANT " + ;
                      "ELSE (D1_QUANT * DE_PERC)/100 " + ;
                    "END AS QUANTIDADE, " + ;
                    "CASE " + ;
                      "WHEN (DE_PERC IS NULL) THEN D1_TOTAL " + ;
                      "ELSE (D1_QUANT * DE_PERC)/100 * D1_VUNIT " + ;
                    "END AS VALORTOTAL " + ;    
               "FROM <<SD1_COMPANY>> SD1 " + ;
               "LEFT JOIN <<SF1_COMPANY>> SF1 " + ; 
             		 "ON SF1.F1_FILIAL = <<SUBSTR_SF1_D1_FILIAL>> " +;
             		"AND SF1.F1_DOC = SD1.D1_DOC " +;
             		"AND SF1.F1_SERIE = SD1.D1_SERIE " +;
             		"AND SF1.F1_FORNECE = SD1.D1_FORNECE " +;
             		"AND SF1.F1_LOJA = SD1.D1_LOJA " +;
             		"AND SF1.F1_FORMUL = SD1.D1_FORMUL " +;
             		"AND SF1.D_E_L_E_T_ = ' ' " + ;
               "LEFT OUTER JOIN <<SDE_COMPANY>> SDE " + ; 
                 "ON DE_FILIAL = <<SUBSTR_SDE_D1_FILIAL>> " + ; 
                "AND D1_DOC = DE_DOC " + ; 
                "AND D1_FORNECE = DE_FORNECE " + ;
                "AND D1_LOJA = DE_LOJA " + ;
                "AND D1_SERIE = DE_SERIE " + ;
                "AND D1_ITEM = DE_ITEMNF " + ; 
                "AND SD1.D_E_L_E_T_ = SDE.D_E_L_E_T_ " + ; 
               "LEFT JOIN <<SA2_COMPANY>> SA2 " + ;
                 "ON A2_FILIAL = <<SUBSTR_SA2_D1_FILIAL>> " + ;
                "AND A2_COD = SD1.D1_FORNECE " + ;
                "AND A2_LOJA = SD1.D1_LOJA " + ;
                "AND SA2.D_E_L_E_T_ = ' ' " + ;
               "LEFT JOIN <<SB1_COMPANY>> SB1 " + ;
                 "ON B1_FILIAL = <<SUBSTR_SB1_D1_FILIAL>> " + ;
                "AND B1_COD = SD1.D1_COD " + ;
                "AND SB1.D_E_L_E_T_ = ' ' " + ;
               "LEFT JOIN <<CTT_COMPANY>> CTT " + ;
                 "ON CTT.CTT_FILIAL = <<SUBSTR_CTT_D1_FILIAL>> " +;
                "AND CTT.CTT_CUSTO = SD1.D1_CC " + ;
                "AND CTT.D_E_L_E_T_ = ' ' " + ;
               "LEFT JOIN <<CTT_COMPANY>> CTT2 " + ;
                 "ON CTT2.CTT_FILIAL = <<SUBSTR_CTT_DE_FILIAL>> " +;
                "AND CTT2.CTT_CUSTO = SDE.DE_CC " + ;
                "AND CTT2.D_E_L_E_T_ = ' ' " + ;
               "LEFT JOIN <<SC7_COMPANY>> SC7 " + ; 
             		 "ON SC7.C7_FILIAL = <<SUBSTR_SC7_D1_FILIAL>> " +;
             		"AND SC7.C7_NUM = SD1.D1_PEDIDO " +;
             		"AND SC7.C7_ITEM = SD1.D1_ITEMPC " +;
             		"AND SC7.D_E_L_E_T_ = ' ' " + ;  
              "WHERE SD1.D_E_L_E_T_= ' ' " + ;
                "AND ( (COALESCE(RTRIM(D1_CC),' ') <> ' ') OR (DE_DOC IS NOT NULL) ) " + ;
                "AND D1_EMISSAO >= <<HISTORIC_PERIOD(4)>> "     
             
Return cView	