#include 'PROTHEUS.CH'
#include 'FINXAPP.CH'

Static __cAppName := ""

/*
	Fonte generico para os arquivos .app do Financeiro
*/


/*/{Protheus.doc} FINAPP001
	Analise de credito financeiro (Protheus x Vadu)
	@type  Function
	@author Vitor Duca
	@since 16/12/2022
	@version 1.0
/*/
Function FINAPP001()
	If AliasInDic("F7F") 
		__cAppName := 'finapp001.app'
		FwCallApp("FINAPP001")
	Else
		Help(, , "FINAPP001DIC", , STR0001, 1, 0) //"Dicionário incompatível com a aplicação."
	Endif	
Return

/*/{Protheus.doc} JsToAdvpl
    configura o preLoad do sistema

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author renato.ito
    @since 09/12/2022
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)
	Local jStorage as Json

	Do Case
		Case cType == "preLoad"
			jStorage := JsonObject():New()
			// objeto para adicionar na sessionStorage de forma dinamica
			jStorage['AppVersion']  := SubStr(DtoS(getapoinfo(__cAppName)[4]), 3)
			jStorage["PaisLoc"]	:= cPaisLoc
			oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())
			FreeObj(jStorage)
	EndCase

Return
