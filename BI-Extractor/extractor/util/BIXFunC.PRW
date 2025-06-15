#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFUN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXParamTrim
Retorna String com um, ou mais, elemento(s) com seu tamanho modificado e entre aspas simples para ser
utilizado dentro de uma clausula IN (WHERE) em um SELECT no banco de dados.

@param cInfo, caracter, Informação(oes) que estarão dentro do IN do SELECT, entre aspas e com o tamanho adaptado.
@param cPipe, caracter, Caracter que será avaliada pela função StrTokArr()
@return String com um, ou mais, elemento(s) com seu tamanho modificado e entre aspas simples para ser
		utilizado dentro de uma clausula IN (WHERE) em um SELECT no banco de dados.

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------
Function BIXParamTrim( cInfo, cPipe )
	Local aAux := {}
	Local cRet := ""
	Local nInd := 0     

	aAux := StrTokArr(cInfo, cPipe)
	
	For nInd := 1 To Len(aAux)
		If nInd == Len(aAux)
			cRet += "'"+AllTrim(aAux[nInd])+"'"
		Else
			cRet += "'"+AllTrim(aAux[nInd])+"',"
		EndIf
	Next nInd
	
 	//-------------------------------------------------------------------
	// Mata as variáveis do tipo array para diminuir o consumo de memória 
	//------------------------------------------------------------------- 
	aSize(aAux, 0)
	aAux := Nil	

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXBookLoad
Carrega o livro digitado anteriormente pelo usuario. Se não existir retorna vazio.

@return cRet, Livro

@author  Márcia Junko
@since   03/07/2015
/*/
//-------------------------------------------------------------------  
Function BIXBookLoad()
	Local cRet := "BIX"

	If ( HNA->( DBseek( xFilial("HNA") + "BIX_LIV_") ) )
		cRet := HNA->HNA_CODVGE
	EndIf
Return cRet