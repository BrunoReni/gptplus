#INCLUDE "BIXEXTRACTOR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPrfSXBProfile
Consulta espec�fica para perfis de extra��o.

@param cVariable, caracter, Vari�vel que ser� atualizada pela consulta.

@author  Valdiney V GOMES
@since   11/11/2013 
/*/
//-------------------------------------------------------------------
function BIXPrfSXBProfile( cVariable )
Return BIXChooseProfile( @cVariable )
                  