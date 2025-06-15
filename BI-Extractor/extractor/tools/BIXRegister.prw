#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREGISTER.CH"

#DEFINE BUILD "20190129"

Static __aRegister

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXBuild
Retorna a build do extrator.

@return cVersion, Build do extrator.

@author  Valdiney V GOMES
@since   17/02/2017
/*/
//-------------------------------------------------------------------
Function BIXBuild( )
Return BUILD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRegister
Apps habilitados.

@return aRegister, Lista de apps habilitados. 

@author  Valdiney V GOMES
@since   10/02/2017
/*/
//-------------------------------------------------------------------
Function BIXRegister( )
	If( __aRegister == nil )
		__aRegister := { }
	EndIf
	
	If ( Empty( __aRegister ) )
		AAdd(__aRegister, { COMERCIAL		, STR0001 } ) //"Comercial"
		AAdd(__aRegister, { CONTROLADORIA	, STR0002 } ) //"Controladoria"
		AAdd(__aRegister, { FINANCEIRO		, STR0003 } ) //"Financeiro"
		AAdd(__aRegister, { MATERIAIS		, STR0004 } ) //"Materiais"
		AAdd(__aRegister, { PRODUCAO		, STR0005 } ) //"Produção"
		AAdd(__aRegister, { RH				, STR0006 } ) //"RH"
		AAdd(__aRegister, { DL				, STR0008 } ) //"DL"
		AAdd(__aRegister, { SERVICO			, STR0009 } ) //"Serviços"
		AAdd(__aRegister, { VAREJO			, STR0010 } ) //"Varejo"
		AAdd(__aRegister, { CRM				, STR0011 } ) //"CRM"
		AAdd(__aRegister, { JURIDICO		, STR0012 } ) //"Jurídico"
		
		//-------------------------------------------------------------------
		// Identifica se exibe o app de desenvolvimento.
		//-------------------------------------------------------------------	
		If ( AllTrim( GetSrvProfString("BIDEVELOPER","0") ) == "1" ) 
			AAdd(__aRegister, { DEVELOPER, STR0013 } ) //"Desenvolvimento"
		EndIf 
	EndIf
Return __aRegister