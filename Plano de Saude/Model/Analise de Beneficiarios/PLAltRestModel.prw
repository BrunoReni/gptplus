#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
 
//--------------------------------------------------------------------
/*/ {Protheus.doc} PLAltRestModel
Publica��o dos modelos de altera��o de benefici�rio que ficaram dispon�veis 
no REST.

@author Vinicius Queiros Teixeira
@since 11/08/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Class PLAltRestModel From FwRestModel

    Method SetFilter(cFilter)

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter
M�todo respons�vel por setar algum filtro que tenha sido informado
por Query String no REST.

@param  cFilter - Valor do filtro a ser aplicado no alias
@return lRet - Indica se o filtro foi aplicado corretamente
@author Vinicius Queiros Teixeira
@since 17/08/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetFilter(cFilter)  Class PLAltRestModel

	Self:cFilter := Alltrim(cFilter)

    If !Empty(Self:cFilter)
        Self:cFilter += " AND "  
    EndIf

    Self:cFilter += "BBA_TIPMAN = 2" // 1 = Altera��o

Return .T.