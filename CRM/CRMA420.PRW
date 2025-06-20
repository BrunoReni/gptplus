#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA420.CH"

 //------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA420

Rotina que faz a chamada para o relatorio de oportunidades

@sample	CRMA420()

@return	Nenhum

@author	Thiago Tavares
@since		10/04/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA420()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "S� um momento, localizando as oportunidades..." 

FATR010( .T. )		// Relatorio de Oportunidades

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

Private aRotina := StaticCall( FATR010 , MENUDEF )

Return( aRotina )