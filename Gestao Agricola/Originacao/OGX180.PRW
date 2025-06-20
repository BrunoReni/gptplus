#INCLUDE "OGX180.ch"
#include "protheus.ch"


/** {Protheus.doc} OGX180
Rotina chamada a partir do bot�o "Estorno" da rotina de Documentos de Sa�da ( MATA460A )
Chamado: Ma461Estor (MATA461)

@param: 	Nil
@return:	Nil
@author: 	Equipe Agroindustria
@since: 	02/03/2018
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGX180()
	Local aArea	:= GetArea()
	Local lRetorno := .t.

	dbSelectArea("NJ5")
	dbSetOrder(1)
	If dbSeek(xFilial("NJ5") + SC9->C9_PEDIDO)
		Help("",1,STR0001,,STR0002,1) //"Estorno n�o permitido!"###"J� foi realizada a Programa��o de Entrega para o pedido!"
		lRetorno := .f.
	EndIf

	RestArea(aArea)

Return(lRetorno)