#INCLUDE "BIXEXTRACTOR.CH"

Static __aSource

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXObject
Inst�ncia uma classe a partir de uma entidade registrada.

@param cEntity, caracter, Entidade da qual o extrator ser�o carregados.
@return oObject, Objeto do extrator da entidade.

@author  Valdiney V GOMES
@version P12
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Function BIXObject( cEntity )
	Local oObject 	:= nil
	Local cSource	:= ""

	Default cEntity := ""

	//-------------------------------------------------------------------
	// Identifica o fonte da entidade.
	//-------------------------------------------------------------------
	cSource := BIXSource( cEntity )
	
	//-------------------------------------------------------------------
	// Retorna uma int�ncia da classe da entidade.
	//-------------------------------------------------------------------
	If ! ( Empty( cSource ) )
		oObject	:= BIXClass( cSource )
	EndIf 	
Return oObject

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSource
Identifica o fonte de uma entidade.

@param cEntity, caracter, Entidade.  
@return cSource, Fonte da entidade. 

@author  Valdiney V GOMES
@version P12
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Function BIXSource( cEntity )
	Local aSource	:= {}	
	Local cSource	:= ""
	Local cFunction	:= ""

	Default cEntity := ""

	//-------------------------------------------------------------------
	// Define a fun��o que ser� pesquisada.
	//-------------------------------------------------------------------	
	cFunction := ( cEntity + "_BI_" )

	If ( FindFunction( cFunction ) )
		//-------------------------------------------------------------------
		// Pesquisa pela fun��o no RPO.
		//-------------------------------------------------------------------
		GetFuncArray( cFunction,, aSource )

		//-------------------------------------------------------------------
		// Identifica o fonte da entidade.
		//-------------------------------------------------------------------		
		If ! ( Empty( aSource ) )
			cSource	:= aSource[ Len( aSource ) ] 
		EndIf 
	EndIf 	
Return cSource

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXClass
Inst�ncia uma classe.

@param cSource, caracter, Fonte da entidade. 
@return oObject, Inst�ncia da classe. 

@author  Valdiney V GOMES
@version P12
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Function BIXClass( cSource )
	Local bErro 	:= nil
	Local oObject 	:= nil
	
	Default cSource	:= ""
	
	bErro := ErrorBlock( { | e | BIXSysOut( "BIXOBJECT", "[" + cEmpAnt + "][" + AllTrim( cFilAnt ) + "] " + e:ErrorStack )  } )
	
	//-------------------------------------------------------------------
	// Instancia a classe informada.
	//-------------------------------------------------------------------
	BEGIN SEQUENCE
		oObject	:= &( SubStr( cSource, 1, At(".", cSource ) - 1 ) + "():New()" ) 
	END SEQUENCE 

	ErrorBlock( bErro )
Return oObject