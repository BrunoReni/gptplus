#INCLUDE "BIXEXTRACTOR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPrfSXBProfile
Consulta específica para perfis de extração.

@param cVariable, caracter, Variável que será atualizada pela consulta.

@author  Valdiney V GOMES
@since   11/11/2013 
/*/
//-------------------------------------------------------------------
function BIXPrfSXBProfile( cVariable )
Return BIXChooseProfile( @cVariable )
                  