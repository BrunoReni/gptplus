#Include 'FIVEWIN.CH'  
#Include 'WMSR230.CH'

//----------------------------------------------------------
/*/{Protheus.doc} WMSR230
Reabastecimento

@author  Flavio Luiz Vicco
@version	P11
@since   18/10/2006
/*/
//----------------------------------------------------------
Function WMSR230()
Local cMensagem := ""
	cMensagem := "Rotina descontinuada."+CRLF
	cMensagem += "Para emitir a listagem de movimentos de reabastecmento pendentes"+CRLF
	cMensagem += "utilize a rotina de impress�o de lista de atividades (WMSR311)."+CRLF
	cMensagem += "Esta rotina ir� gerar um mapa de movimentos para o usu�rio que"+CRLF
	cMensagem += "dever� ser utilizado para apontar a finaliza��o destas atividades." 
	WmsMessage(cMensagem)
Return NIL
