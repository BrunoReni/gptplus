#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidDic
Valida se o dicionario de dados est� atualizado.

@return Logico, Verdadeiro se o dicionario est� atualizado.
@author  Marcia Junko
@since   16/02/2022
/*/
//-------------------------------------------------------------------------------------
Static Function ValidDic()
    Local lRet := .F.

	// Avalia se as tabelas do GRR existem no ambiente.
    If AliasInDic( "HRH" )
        lRet := .T.
    EndIf
Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} IsGRRUpdated
Fun��o que valida se a estrutura do GRR est� dispon�vel

@return l�gico, Retorna se o ambiente est� atualizado com as tabelas do GRR
@author Marcia Junko
@since  14/06/2022
/*/
//-------------------------------------------------------------------------------
Function IsGRRUpdated()
Return ValidDic() 
