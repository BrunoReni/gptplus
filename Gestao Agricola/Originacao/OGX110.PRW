#INCLUDE "OGX110.ch"
#Include 'Protheus.ch'

/**{Protheus.doc} OGX110
Valida��o na Inclus�o de T�tulos a Pagar
garantindo que o t�tulo a ser incluso j� n�o exista
e tamb�m que esteja amarrado a um contrato.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	03/05/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado por: Marcelo R. Ferrari
@Data Altera��o: 19/08/2014
**/

//Programa Original: ARMXPE15.PRW

Function OGX110()
Local lRetorno 	:= .T.
	If FindFunction("OGXUTOG") //Encontra a fun��o
		If OGXUTOG()
			If FindFunction("OGX110A")
				lRetorno := OGX110A()
			Endif
		Endif 
	EndIf	
	
Return( lRetorno )