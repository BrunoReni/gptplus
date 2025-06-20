#Include "PROTHEUS.CH
#INCLUDE "STMEMRYFISC.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} STBMemVal
Function valida��o da janela de Memoria Fiscal
@param   	nTipoRel -Tipo do relat�rio
@param   	oReducIni - Redu��o Inicial
@param   	oReducFim - Redu��o Final�
@param   	oCheck1 - Objeto CheckBox
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Abertura com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBMemVal(nTipoRel, oReducIni, oReducFim, oCheck1)
	If nTipoRel == 1 
		oReducIni:Picture	:= '@E 9999'
		oReducFim:Picture	:= '@E 9999'
		oCheck1:Enable()
	ElseIf nTipoRel == 2
		oReducIni:Picture	:= '@E 999999'
		oReducFim:Picture	:= '@E 999999'
		oCheck1:Disable()
	EndIf
	oReducIni:Refresh()
	oReducFim:Refresh()
	oCheck1:Refresh()
Return .T.