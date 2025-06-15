#INCLUDE "BCDEFINITION.CH"

NEW DATAMODEL MOEDACTB

//-------------------------------------------------------------------
/*/{Protheus.doc} BCMoedaCTB
Visualiza as informações de  moeda contábil

@author  Marcia Junko
@since   07/10/2019

/*/
//-------------------------------------------------------------------
Class BCMoedaCTB from BCEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildView( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc}  Setup
Construtor padrão.

@author  Marcia Junko
@since   07/10/2019

/*/
//-------------------------------------------------------------------
Method Setup( ) Class BCMoedaCTB
	_Super:Setup("MoedaCTB", DIMENSION, "CTO")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Marcia Junko
@since   07/10/2019

/*/
//-------------------------------------------------------------------
Method BuildView( ) Class BCMoedaCTB
	Local cView := ""
	
	cView := " SELECT " + ;
		"<<CODE_LINE>> AS TOTVS_LINHA_PRODUTO, " + ;
		"<<CODE_INSTANCE>> AS INSTANCIA, " + ;
		"<<CODE_COMPANY>> AS EMPRESA, " + ;
		"'<<CTO_COMPANY>>' AS TABELA, " + ;
		"CTO_FILIAL AS FILIAL, " + ;
		"CTO_MOEDA AS COD_MOEDA, " + ;
		"CTO_DESC AS DESC_MOEDA, " + ;
		"CTO_SIMB AS SIMBOLO " + ;
		"FROM <<CTO_COMPANY>> CTO " + ; 
		"WHERE D_E_L_E_T_ = ' ' " + ;
		"<<TEST_QUERY>> "	 
             
Return cView	