#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA410.CH"

 //------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA410

Rotina que faz a chamada para a associa��o de contato

@sample	CRMA410()

@return	Nenhum

@author	Thiago Tavares
@since		10/04/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA410()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "S� um momento, localizando as entidades..." 

FATA330( .T. )		// Associacao de Contatos

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

Private aRotina := StaticCall( FATA330 , MENUDEF )

Return( aRotina )