#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA500.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA500

Rotina que faz a chamada para o cadastro de parceiros

@sample	CRMA500()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA500()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "S� um momento, localizando os parceiros..." 

FATA030()    // Parceiros

Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Opera��es que ser�o utilizadas pela aplica��o

@return   	aRotina - Array das opera��es

@author		Vendas CRM
@since		15/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := StaticCall( FATA030 , MENUDEF )

Return( aRotina )