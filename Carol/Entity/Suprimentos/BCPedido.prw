#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL PEDIDO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProduto
Visualizacao das informa��es  dos pedidos.
 
@author  jose.delmondes
@since   09/04/2020

/*/
//-------------------------------------------------------------------
Class BCPedido from BCEntity
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
Method Setup( ) Class BCPedido
	_Super:Setup("BCPedido", FACT, "SC7", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   09/04/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCPedido
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
			        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		            "<<CODE_COMPANY>> AS EMPRESA, " + ;
		            "C7_FILIAL AS FILIAL, C7_ITEM AS ITEM, C7_PRODUTO AS PRODUTO, C7_CC AS CENTROCUSTO, " + ;
		            "C7_QUANT AS QUANTIDADE, C7_PRECO AS VLUNITARIO, C7_TOTAL AS VLTOTAL, " + ;
		            "C7_FORNECE AS FORNECEDOR, C7_LOJA AS LOJA, C7_DESCRI AS DESCPRODUTO, C7_SEQUEN AS SEQUENCIA, C7_ITEMGRD AS ITEMGRADE,  " + ;
		            "C7_EMISSAO AS EMISSAO, C7_NUM AS NUMERO, C7_QUJE AS QTDENTREGUE, C7_MOEDA AS MOEDA " + ;
             "FROM <<SC7_COMPANY>> SC7 " + ; 
             "WHERE SC7.D_E_L_E_T_ = ' ' AND C7_TIPO = '1' " + ;
			 "AND C7_EMISSAO >= <<HISTORIC_PERIOD(2)>> " 
             
Return cView
