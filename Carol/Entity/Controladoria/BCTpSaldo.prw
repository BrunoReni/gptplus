#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL TPSALDO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCTpSaldo
Visualiza as informações  de tipo de saldo.

@author  Marcia Junko
@since   07/10/2019
/*/
//-------------------------------------------------------------------
Class BCTpSaldo from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Marcia Junko
@since   07/10/2019

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCTpSaldo
	_Super:Setup("TpSaldo", DIMENSION, "SX5")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   07/10/2019

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCTpSaldo
	Local cView := ""
	
	cView := " SELECT " + ;
		"<<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
		"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		"<<CODE_COMPANY>> AS EMPRESA, " + ;
		"'<<SX5_COMPANY>>' AS TABELA, " + ;
		"SX5.X5_FILIAL AS FILIAL, " + ;
		"SX5.X5_CHAVE AS COD_TPSALDO, " + ;
		BISX5Title() + " AS DESC_TPSALDO " + ;
		"FROM <<SX5_COMPANY>> SX5 " + ; 
		"WHERE X5_TABELA = 'SL' AND " + ;
		"SX5.D_E_L_E_T_ = ' ' " + ;
		"<<TEST_QUERY>> "	 
             
Return cView	