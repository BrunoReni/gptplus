#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL TABELAPRECO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCTabelaPreco
Visualizacao das informações das  tabelas  de preco.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Class BCTabelaPreco from BCEntity
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
Method Setup( ) Class BCTabelaPreco
	_Super:Setup("BCTabelaPreco", FACT, "AIA", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCTabelaPreco
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
			        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		            "<<CODE_COMPANY>> AS EMPRESA, " + ;
		            "AIA_FILIAL AS FILIAL, AIA_CODTAB AS TABELA, AIA_CODFOR AS FORNECEDOR, " + ;
		            "AIA_LOJFOR AS LOJA, AIA_CONDPG AS CONDPG, AIA_DATDE AS DATADE, AIA_DATATE AS DATATE, " + ;
		            "AIB_ITEM AS ITEM, AIB_CODPRO AS PRODUTO, AIB_PRCCOM AS PRECO, AIB_MOEDA AS MOEDA, " + ;
		            "AIB_FRETE AS FRETE, E4_DESCRI AS COND_DESCRICAO, B1_DESC AS PRODUTO_DESCRICAO " + ;
             "FROM <<AIA_COMPANY>> AIA " + ;
             "INNER JOIN <<AIB_COMPANY>> AIB " + ; 
             		"ON AIB.AIB_FILIAL = <<SUBSTR_AIB_AIA_FILIAL>> " +;
             		"AND AIB.AIB_CODTAB = AIA.AIA_CODTAB " +;
             		"AND AIB.AIB_CODFOR = AIA.AIA_CODFOR " +;
             		"AND AIB.AIB_LOJFOR = AIA.AIA_LOJFOR " +;
             		"AND AIB.D_E_L_E_T_ = ' ' " + ; 
             "LEFT JOIN <<SE4_COMPANY>> SE4 " + ; 
             		"ON SE4.E4_FILIAL = <<SUBSTR_SE4_AIA_FILIAL>> " +;
             		"AND SE4.E4_CODIGO = AIA.AIA_CONDPG " +;
             		"AND SE4.D_E_L_E_T_ = ' ' " + ;
              "LEFT JOIN <<SB1_COMPANY>> SB1 " + ; 
             		"ON SB1.B1_FILIAL = <<SUBSTR_SB1_AIA_FILIAL>> " +;
             		"AND SB1.B1_COD = AIB.AIB_CODPRO " +;
             		"AND SB1.D_E_L_E_T_ = ' ' " + ;
             "WHERE AIB.D_E_L_E_T_ = ' ' " +;
			 "  AND AIA.D_E_L_E_T_ = ' ' "
             
Return cView	