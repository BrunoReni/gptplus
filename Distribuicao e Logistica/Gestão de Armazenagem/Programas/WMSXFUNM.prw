#include "protheus.ch"
/*
+---------+--------------------------------------------------------------------+
|Fun��o   | WMSXFUNM - Fun��es Para Automa��o de Testes                        |
+---------+--------------------------------------------------------------------+
|Objetivo | Dever� agrupar todas as fun��es que ser�o utilizadas na            |
|         | automa��o de testes.                                               |
+---------+--------------------------------------------------------------------+
*/


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsAutCmt
Realiza a valida��o da automa��o, verificando o conte�do dos registros criados.
@type function
@author Wander Horongoso
@version 12.1.31
@since 16/11/2020
@param
oHelper: objeto helper da automa��o
lAssert: indica se a autom��o deve retornar execu��o com (.T.) ou sem (.F.) sucesso.
lCommit: Se verdadeiro  efetua o commit. Sen�o n�o faz, pois j� foi feito externamente.
aFields: rela��o de campos a serem validados.
	aFields[1]: nome do campo
	aFields[2]: conte�do do campo
	aFields[3]: se o campo ser� usado 	para a pesquisa/condi��o where (.T.) ou para valida��o do cont�udo gravado (.F.).
/*/
//-------------------------------------------------------------------------------------------------
Function WmsAutCmt(oHelper, lAssert, lCommit, aFields)
Local cQuery := ''
Local cTable := ''
Local cTableFld := ''
Local nTable := 0
Local nField := 0
Local xVal := nil

	If lCommit
		lCommit := oHelper:UTCommitData()
	Else
		lCommit := .T.		
	EndIf	
	
	If lCommit
		For nTable := 1 to Len(aFields)
			cMsgTab := ''

			cTable := aFields[nTable][1] 
			If cTable $ 'SD1|SD2|SF1|SF2|SA1|SA2|SB1|SB2|SB5|SB8'
				cTableFld := Substr(cTable,2,2)
			Else	
				cTableFld := cTable
			EndIf

			cQuery := cTable + "." + cTableFld + "_FILIAL = '" + xFilial(cTable) + "'"
			
			For nField := 1 To Len(aFields[nTable][2])
				If aFields[nTable][2][nField][3]
				    xVal := aFields[nTable][2][nField][2]
	
				    Iif (ValType(xVal) == 'C', xVal := "'" + xVal + "'",)
					Iif (ValType(xVal) == 'N', xVal := Str(xVal),)
				    
					cQuery  += ' AND ' + cTable + "." + aFields[nTable][2][nField][1] + " = " + xVal
				EndIf
			Next nField
			
			For nField := 1 To Len(aFields[nTable][2])
				If !aFields[nTable][2][nField][3]				
					xVal := aFields[nTable][2][nField][2]

					Iif (ValType(xVal) == 'D', xVal := DTOS(xVal),)

					oHelper:UTQueryDB(cTable,aFields[nTable][2][nField][1], cQuery, aFields[nTable][2][nField][2])
				EndIf			
			Next nField
	
		Next nTable
	EndIf

	Iif (lAssert, oHelper:AssertTrue(), oHelper:AssertFalse())

Return oHelper

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsAutRpt
Realiza a valida��o de relat�rios gerados pela automa��o.
Mais detalhes: https://tdn.totvs.com/pages/viewpage.action?pageId=271860745 (1.2.4. Desenvolvimento de Scripts para Relat�rios)
@type function
@author Wander Horongoso
@since 25/05/2020
@param
cRpt: nome do caso de teste a ser executado
cPerg: nome do pergunte a ser carregado
aPerg: array com o pergunte e o valor a ser atribu�do
cDtBase: data base para execu��o da rotina (se necess�rio).
/*/
//-------------------------------------------------------------------------------------------------
function WMSAutRpt(cRpt, cPerg, aPerg, cDtBase) 
//-------------------------------------------------------------------
Local oHelper := FWTestHelper():New() 
Local nI      := 0 

Default cDtBase := '01/01/2015' //Se n�o houver necessidade, remover posteriormente este par�metro

	oHelper:UTSetParam( "MV_TREPORT", 2, .T. ) // 2 = Utiliza
	oHelper:Activate()
	dDatabase := CtoD(cDtBase)

	For nI := 1 To Len(aPerg)
		oHelper:UTChangePergunte(cPerg, PadL(Str(aPerg[nI,1],2),2,'0'), aPerg[nI,2])
	Next nI
 
	oHelper:UTStartRpt(cRpt)
	oHelper:UTPrtCompare(cRpt)
	oHelper:AssertTrue(oHelper:lOk, "")
 
	dDatabase := Date()
	oHelper:UTRestParam(oHelper:aParamCT)
 
Return(oHelper)
