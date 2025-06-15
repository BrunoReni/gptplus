#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL GRUPO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCProduto
Visualizacao das informações  dos  produtos.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Class BCGrupo from BCEntity
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
Method Setup( ) Class BCGrupo
	_Super:Setup("BCGrupo", DIMENSION, "SBM", , .F.)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  jose.delmondes
@since   16/01/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCGrupo
	Local cView := ""
	
	cView := "SELECT <<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
			        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		            "<<CODE_COMPANY>> AS EMPRESA, " + ;
		            "BM_FILIAL AS FILIAL, BM_GRUPO AS GRUPO, BM_DESC AS DESCRICAO " + ;
             "FROM <<SBM_COMPANY>> SBM " + ; 
             "WHERE SBM.D_E_L_E_T_ = ' ' " 
             
Return cView	