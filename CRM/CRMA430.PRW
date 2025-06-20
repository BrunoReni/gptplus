#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA430.CH"

 //------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA430

Rotina que faz a chamada para o relatorio de despesas financeiras  

@sample	CRMA430()

@return	Nenhum

@author	Thiago Tavares
@since		10/04/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA430()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "S� um momento, localizando as despesas..." 

FATR040( .T. )		// Relatorio de Despesas Financeiras

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

Private aRotina := StaticCall( FATR040 , MENUDEF )

Return( aRotina )