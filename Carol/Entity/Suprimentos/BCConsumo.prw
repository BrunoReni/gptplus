#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL CONSUMO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProduto
Visualizacao das informa��es de   consumo.

@author  jose.delmondes
@since   09/04/2020

/*/
//-------------------------------------------------------------------
Class BCConsumo from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padr�o.

@author  jose.delmondes
@since   09/04/2020

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCConsumo
	_Super:Setup("BCConsumo", FACT, "SD1", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   09/04/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCConsumo
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
                  "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
                  "<<CODE_COMPANY>> AS EMPRESA, " + ;
                  "FILIAL, " + ;
                  "PRODUTO, " + ; 
                  "SUBSTRING(EMISSAO,1,4) ANO, " + ; 
                  "SUBSTRING(EMISSAO,5,2) MES, " + ; 
                  "EMISSAO, " +;
                  "(COALESCE(SUM(SD2_QUANT),0) + COALESCE(SUM(SD3_SAIDA_QUANT),0)) AS DEMANDA, " + ;
                  "COALESCE(SUM(SD3_ENTRADA_QUANT),0) + COALESCE(SUM(SD1_QUANT),0) AS DEVOLUCOES, " + ;
                  "TIPO, " + ;
                  "GRUPO " + ;
             "FROM (SELECT D2_FILIAL AS FILIAL, " + ;
                          "D2_COD AS PRODUTO, " + ;
                          "D2_EMISSAO AS EMISSAO, " + ;
                          "SUM(D2_QUANT) AS SD2_QUANT, " + ;
                          "0 AS SD3_ENTRADA_QUANT, " + ;
                          "0 AS SD3_SAIDA_QUANT, " + ;
                          "0 AS SD1_QUANT, " + ;
                          "B1_TIPO AS TIPO,  " + ;
                          "B1_GRUPO AS GRUPO " + ;
                     "FROM <<SB1_COMPANY>> SB1 INNER JOIN " + ;
                          "<<SD2_COMPANY>> SD2 " + ; 
                       "ON SB1.B1_COD = D2_COD " + ;
                      "AND D2_FILIAL = <<SUBSTR_SD2_B1_FILIAL>> " + ; 
                    "WHERE D2_ORIGLAN <> 'LF' " + ;
                      "AND D2_TIPO NOT IN ('D','B') " + ;
					            "AND D2_EMISSAO >= <<HISTORIC_PERIOD(4)>> " + ; 
                      "AND COALESCE(RTRIM(D2_REMITO),' ') = ' ' " + ;
                      "AND SD2.D_E_L_E_T_ = '' " + ;
                      "AND SB1.D_E_L_E_T_ = ' ' " + ;
                    "GROUP BY D2_FILIAL, D2_COD, D2_EMISSAO, B1_TIPO, B1_GRUPO " + ;
					          "UNION ALL " + ;
                   "SELECT D3_FILIAL AS FILIAL, " + ;
	                      "D3_COD AS PRODUTO, " + ;
                          "D3_EMISSAO AS EMISSAO, " + ;
                          "0 AS SD2_QUANT, " + ;
                          "0 AS SD3_ENTRADA_QUANT, " + ;
                          "SUM(D3_QUANT) AS SD3_SAIDA_QUANT, " + ;
                          "0 AS SD1_QUANT, " + ;
                          "B1_TIPO AS TIPO, " + ;
                          "B1_GRUPO AS GRUPO " + ;
                     "FROM <<SB1_COMPANY>> SB1 INNER JOIN " + ;
                          "<<SD3_COMPANY>> SD3 " + ;
                       "ON SB1.B1_COD = D3_COD " + ;
                      "AND D3_FILIAL = <<SUBSTR_SD3_B1_FILIAL>> " + ;  
                    "WHERE SUBSTRING(D3_CF, 2, 1) = 'E' " + ;
                      "AND SUBSTRING(D3_CF, 3, 1) NOT IN ('3','4','7') " + ;
					            "AND D3_EMISSAO >= <<HISTORIC_PERIOD(4)>> " + ; 
                      "AND SD3.D_E_L_E_T_ = ' ' " + ;
                      "AND D3_TM > '500' " + ;
                      "AND SB1.D_E_L_E_T_ = ' ' " + ;
                    "GROUP BY D3_FILIAL, D3_COD, D3_EMISSAO, B1_TIPO, B1_GRUPO " + ;
                    "UNION ALL " + ;
                   "SELECT D3_FILIAL AS FILIAL, " + ;
                          "D3_COD AS PRODUTO, " + ;
                          "D3_EMISSAO AS EMISSAO, " + ;
                          "0 AS SD2_QUANT, " + ;
                          "SUM(D3_QUANT) AS SD3_ENTRADA_QUANT, " + ;
                          "0 AS SD3_SAIDA_QUANT, " + ;
                          "0 AS SD1_QUANT, " + ;
                          "B1_TIPO AS TIPO, " + ; 
                          "B1_GRUPO AS GRUPO " + ;
                    "FROM <<SB1_COMPANY>> SB1 INNER JOIN " + ;
                         "<<SD3_COMPANY>> SD3 " + ;
                      "ON SB1.B1_COD = D3_COD " + ;
                     "AND D3_FILIAL = <<SUBSTR_SD3_B1_FILIAL>> " + ;  
                   "WHERE SUBSTRING(D3_CF, 2, 1) = 'E' " + ;
                     "AND SUBSTRING(D3_CF, 3, 1) NOT IN ('3','4','7') " + ; 
                     "AND D3_EMISSAO >= <<HISTORIC_PERIOD(4)>> " + ; 
                     "AND SD3.D_E_L_E_T_ = ' ' " + ;
                     "AND D3_TM <= '500' " + ;
                     "AND SB1.D_E_L_E_T_ = ' ' " + ;
                   "GROUP BY D3_FILIAL, D3_COD, D3_EMISSAO, B1_TIPO, B1_GRUPO " + ;
                   "UNION ALL " + ;
                  "SELECT D1_FILIAL AS FILIAL, " + ;
                         "D1_COD AS PRODUTO, " + ;
                         "D1_EMISSAO AS EMISSAO, " + ;
                         "0 AS SD2_QUANT, " + ;
                         "0 AS SD3_ENTRADA_QUANT, " + ;
                         "0 AS SD3_SAIDA_QUANT, " + ;
                         "SUM(D1_QUANT) AS SD1_QUANT, " + ;
                         "B1_TIPO AS TIPO, " + ; 
                         "B1_GRUPO AS GRUPO " + ;
                   "FROM <<SB1_COMPANY>> SB1 INNER JOIN " + ;
                        "<<SD1_COMPANY>> SD1 " + ;
                     "ON SB1.B1_COD = D1_COD " + ;
                    "AND D1_FILIAL = <<SUBSTR_SD1_B1_FILIAL>> " + ; 
                  "WHERE D1_ORIGLAN <> 'LF' " + ;
                    "AND D1_TIPO = 'D' " + ;
                    "AND D1_EMISSAO >= <<HISTORIC_PERIOD(4)>> " + ; 
                    "AND COALESCE(RTRIM(D1_REMITO),' ') = ' ' " + ;
                    "AND SD1.D_E_L_E_T_ = ' ' " + ;
                    "AND SB1.D_E_L_E_T_ = ' ' " + ;
                  "GROUP BY D1_FILIAL, D1_COD, D1_EMISSAO, B1_TIPO, B1_GRUPO " + ;
            ") X GROUP BY FILIAL,PRODUTO, EMISSAO, TIPO, GRUPO" 
             
Return cView