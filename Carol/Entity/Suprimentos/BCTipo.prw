#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL TIPO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProduto
 Visualizacao das informações dos  produtos.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Class BCTipo from BCEntity
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
Method Setup( ) Class BCTipo
	_Super:Setup("BCTipo", DIMENSION, "SX5", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCTipo
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
			        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		            "<<CODE_COMPANY>> AS EMPRESA, " + ;
		            "X5_FILIAL AS FILIAL, X5_CHAVE AS CODIGO, X5_DESCRI AS DESCRICAO " + ;
             "FROM <<SX5_COMPANY>> SX5 " + ; 
             "WHERE SX5.D_E_L_E_T_ = ' ' " +; 
                    "AND SX5.X5_TABELA = '02' "
Return cView	