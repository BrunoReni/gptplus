#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL CCUSTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BCCentroDeCusto
Visualiza as informacoes de  centro  de custo

@author  andreia.lima
@since   19/11/2020

/*/
//-------------------------------------------------------------------
Class BCCentroDeCusto from BCEntity
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
Method Setup( ) Class BCCentroDeCusto
	_Super:Setup("BCCentroCusto", DIMENSION ,"CTT")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  andreia.lima
@since   19/11/2020

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCCentroDeCusto
	Local cView := ""
	
	cView := " SELECT " + ;
		"<<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
		"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		"<<CODE_COMPANY>> AS EMPRESA, " + ;
		"CTT_FILIAL AS FILIAL, " + ;
		"CTT_CUSTO AS CENTROCUSTO, " + ;
		"CTT_DESC01 AS DESCRICAO," +;
		"CTT_CLASSE AS CLASSE, " + ;
		"CTT_NORMAL AS CONDICAO_NORMAL, " + ;
		"CTT_CCSUP AS CENTROCUSTO_SUPERIOR "  + ;
		"FROM <<CTT_COMPANY>> CTT " + ; 
		"WHERE D_E_L_E_T_ = ' ' " + ;
		"<<TEST_QUERY>> "	 
             
Return cView	