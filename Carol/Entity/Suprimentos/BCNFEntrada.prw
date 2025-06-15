#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL NFENTRADA

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProduto
Visualizacao das informacoes  dos documentos  de entrada.

@author  jose.delmondes
@since   13/02/2020

/*/
//-------------------------------------------------------------------

Class BCNFEntrada from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  jose.delmondes
@since   13/02/2020

/*/
//-------------------------------------------------------------------

Method Setup( ) Class BCNFEntrada
	_Super:Setup("BCNFEntrada", FACT, "SD1", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   13/02/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCNFEntrada
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
			        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		            "<<CODE_COMPANY>> AS EMPRESA, " + ;
		            "D1_FILIAL AS FILIAL, D1_ITEM AS ITEM, D1_COD AS PRODUTO, D1_UM AS UNIDADE, D1_QUANT AS QUANTIDADE, " +;
		            "D1_VUNIT AS VALORUNITARIO, D1_TOTAL AS VALORTOTAL, D1_DESC AS DESCONTO, D1_VALDESC AS VALDESC, " + ;
		            "D1_CONTA AS CONTA, D1_ITEMCTA AS ITEMCTA, D1_CC AS CENTROCUSTO, D1_CLVL AS CLASSE, D1_PEDIDO AS PEDIDO, " +;
		            "D1_ITEMPC AS ITEMPC, D1_FORNECE AS FORNECE, D1_LOJA AS LOJA, D1_DOC AS NF, D1_EMISSAO AS EMISSAO, " + ;
		            "D1_TIPO AS TIPONF,D1_SERIE AS SERIE, D1_VALFRE AS VALFRETE, D1_SEGURO AS SEGURO, D1_DESPESA AS DESPESA, " + ;
		            "D1_CUSTO AS CUSTO, F1_COND AS CONDICAO, F1_MOEDA AS MOEDA, F1_RECBMTO AS RECEBIMENTO, F1_DUPL AS TITULO, F1_FORMUL AS FORMULARIO ,  " + ;
					"B1_DESC AS DESCRICAO, A2_NOME AS NOME_FORNECEDOR, " + ;
		            "B5_TIPO AS MATERIAL_SERVICO, CASE WHEN D1_TEC = '' THEN B1_POSIPI ELSE D1_TEC END AS NCM, B1_GRUPO AS GRUPO, B1_TIPO AS TIPO, C7_EMISSAO EMISSAO_PC, " + ;
					"C7_DATPRF PREVISAO_ENTREGA, C7_CONTRA AS CONTRATO, VENCTO AS PRAZO_PAGAMENTO, QTD_DEV, VLR_DEV " + ;
             "FROM <<SD1_COMPANY>> SD1 " + ; 
             "LEFT JOIN <<SF1_COMPANY>> SF1 " + ; 
             		"ON SF1.F1_FILIAL = <<SUBSTR_SF1_D1_FILIAL>> " +;
             		"AND SF1.F1_DOC = SD1.D1_DOC " +;
             		"AND SF1.F1_SERIE = SD1.D1_SERIE " +;
             		"AND SF1.F1_FORNECE = SD1.D1_FORNECE " +;
             		"AND SF1.F1_LOJA = SD1.D1_LOJA " +;
             		"AND SF1.F1_FORMUL = SD1.D1_FORMUL " +;
             		"AND SF1.D_E_L_E_T_ = ' ' " + ;
             "LEFT JOIN <<SB1_COMPANY>> SB1 " + ; 
             		"ON SB1.B1_FILIAL = <<SUBSTR_SB1_D1_FILIAL>> " +;
             		"AND SB1.B1_COD = SD1.D1_COD " +;
             		"AND SB1.D_E_L_E_T_ = ' ' " + ;
             "LEFT JOIN <<SB5_COMPANY>> SB5 " + ; 
             		"ON SB5.B5_FILIAL = <<SUBSTR_SB5_D1_FILIAL>> " +;
             		"AND SB5.B5_COD = SD1.D1_COD " +;
             		"AND SB5.D_E_L_E_T_ = ' ' " + ;
             "LEFT JOIN <<SA2_COMPANY>> SA2 " + ; 
             		"ON SA2.A2_FILIAL = <<SUBSTR_SA2_D1_FILIAL>> " +;
             		"AND SA2.A2_COD = SD1.D1_FORNECE " +;
             		"AND SA2.A2_LOJA = SD1.D1_LOJA " +;
             		"AND SA2.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN <<SC7_COMPANY>> SC7 " + ; 
             		"ON SC7.C7_FILIAL = <<SUBSTR_SC7_D1_FILIAL>> " +;
             		"AND SC7.C7_NUM = SD1.D1_PEDIDO " +;
             		"AND SC7.C7_ITEM = SD1.D1_ITEMPC " +;
             		"AND SC7.D_E_L_E_T_ = ' ' " + ;
			"LEFT JOIN (SELECT  D2_FILIAL,D2_CLIENTE,D2_LOJA,D2_COD,D2_ITEMORI,D2_NFORI, SUM(D2_QUANT) AS QTD_DEV, SUM(D2_TOTAL) AS VLR_DEV " +;
					"FROM <<SD2_COMPANY>> SD2 " +; 
					"WHERE SD2.D_E_L_E_T_ = ' ' " +; 
					"GROUP BY D2_FILIAL,D2_NFORI,D2_CLIENTE,D2_LOJA,D2_COD,D2_ITEMORI ) DEV " +; 
					"ON  DEV.D2_FILIAL = SD1.D1_FILIAL "+; 
					"AND DEV.D2_NFORI = SD1.D1_DOC "+; 
					"AND DEV.D2_CLIENTE = SD1.D1_FORNECE "+; 
					"AND DEV.D2_LOJA = SD1.D1_LOJA "+; 
					"AND DEV.D2_COD = SD1.D1_COD "+;
					"AND DEV.D2_ITEMORI = SD1.D1_ITEM "+; 
			"LEFT JOIN ( SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_TIPO, MAX(E2_VENCTO) AS VENCTO" +; 
					"FROM <<SE2_COMPANY>> " +;
					"WHERE D_E_L_E_T_ = ' ' " +; 
					"GROUP BY E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_TIPO ) SE2 "+; 
					"ON SE2.E2_FILIAL = <<SUBSTR_SE2_D1_FILIAL>> " +;
					"AND SE2.E2_NUM = F1_DOC " +;
					"AND SE2.E2_FORNECE = F1_FORNECE " +;
					"AND SE2.E2_LOJA = F1_LOJA " +;
					"AND SE2.E2_PREFIXO = F1_SERIE " +;
					"AND SE2.E2_TIPO =  '"+MVNOTAFIS+"' " +;
            "WHERE SD1.D_E_L_E_T_ = ' ' " +;
			"  AND D1_EMISSAO >= <<HISTORIC_PERIOD(4)>> "
             
Return cView	
