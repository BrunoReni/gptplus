#INCLUDE "BCDEFINITION.CH"
#INCLUDE "TOTVS.CH"

NEW DATAMODEL PRODUTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProduto
Visualizacao das informações  dos  produtos.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Class BCProduto from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCProduto
	_Super:Setup("BCProduto", DIMENSION, "SB1", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCProduto
	Local cView 	:= ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " +;
			        "<<CODE_INSTANCE>> AS INSTANCIA, " +;
		            "<<CODE_COMPANY>> AS EMPRESA, " +;
		            "B1_FILIAL AS FILIAL, B1_COD AS CODIGO, B1_DESC AS DESCRICAO, B1_TIPO AS TIPO, " +;
		            "B1_UM AS UM, B1_GRUPO AS GRUPO, B1_POSIPI AS NCM, B1_CUSTD AS CUSTO_PADRAO, B1_UPRC AS ULTIMO_PRECO, " +;
		            "B1_UCALSTD AS ULTIMO_CUSTO_DATA, B1_UCOM AS ULTIMO_PRECO_DATA, BM_DESC AS GRUPO_DESCRICAO, " +;
		            "B5_TIPO AS MATERIAL_SERVICO, YD_DESC_P AS NCM_DESCRICAO, X5_DESCRI AS TIPO_DESCRICAO " +;
             "FROM <<SB1_COMPANY>> SB1 " +; 
             "LEFT JOIN <<SBM_COMPANY>> SBM " +; 
             		"ON SBM.BM_FILIAL = <<SUBSTR_SBM_B1_FILIAL>> " +;
             		"AND SBM.BM_GRUPO = SB1.B1_GRUPO " +;
             		"AND SBM.D_E_L_E_T_ = ' ' " +;
             "LEFT JOIN <<SB5_COMPANY>> SB5 " +; 
             		"ON SB5.B5_FILIAL = <<SUBSTR_SB5_B1_FILIAL>> " +;
             		"AND SB5.B5_COD = SB1.B1_COD " +;
             		"AND SB5.D_E_L_E_T_ = ' ' " +;
             "LEFT JOIN <<SYD_COMPANY>> SYD " +; 
             		"ON SYD.YD_FILIAL = <<SUBSTR_SYD_B1_FILIAL>> " +; 
             		"AND SYD.YD_TEC = SB1.B1_POSIPI " +;
             		"AND SYD.D_E_L_E_T_ = ' ' " + ;
			 "LEFT JOIN <<SX5_COMPANY>> SX5 " + ; 
             		"ON SX5.X5_FILIAL = <<SUBSTR_SX5_B1_FILIAL>> " +;
             		"AND SX5.X5_TABELA = '02' " +;
             		"AND SX5.X5_CHAVE = SB1.B1_TIPO " +;
             		"AND SX5.D_E_L_E_T_ = ' ' " + ;
             "WHERE SB1.D_E_L_E_T_ = ' ' "
             
Return cView	
