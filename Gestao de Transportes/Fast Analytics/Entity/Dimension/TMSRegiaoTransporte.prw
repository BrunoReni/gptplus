#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43REGTR

//----------------------------------------------------------------------------------
/*{Protheus.doc } BARegiaoTransporte
Demonstra as regi�es cadastradas no TMS.
@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSRegiaoTransporte from BAEntity
    Method Setup() CONSTRUCTOR  
    Method BuildQuery() 
EndClass


//----------------------------------------------------------------------------------
/*{Protheus.doc } Setup
Construtor Padr�o


@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method Setup() Class TMSRegiaoTransporte
    
    _Super:Setup("TMS Regiao Transporte", DIMENSION, "DUY")
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSRegiaoTransporte

    Local cQuery := ""

    //Regi�es de Transporte

	cQuery += " SELECT "
	cQuery += " 		<<KEY_DUY_DUY_FILIAL+DUY_GRPVEN>> AS BK_REGIAO, "
	cQuery += " 		DUY.DUY_GRPVEN AS COD_REGIAO, "
    cQuery += " 		DUY.DUY_DESCRI AS DES_REGIAO, "
	cQuery += " 	    <<CODE_INSTANCE>> AS INSTANCIA"
	cQuery += " 	FROM <<DUY_COMPANY>> DUY" 
	cQuery += " 	WHERE "
	cQuery += "	   	DUY.D_E_L_E_T_ = ' ' "
	cQuery += " 	<<AND_XFILIAL_DUY_FILIAL>> "
    
Return cQuery
