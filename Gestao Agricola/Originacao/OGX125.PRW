#Include 'OGX125.ch'
#Include 'Protheus.ch'

/**{Protheus.doc} OGX125
Valida��o no Cancelamento da Baixa de T�tulos a receber
Gerar titulos do tipo NDC de comissao para a corretora
@param: 	Nil
@author: 	Jos� Leite de Barros Neto
@since: 	16/07/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado Por: Marcelo R. Ferrari
Alterado em: 19/08/201
@Uso: 		SIGAFIN - Financeiro - desabilitado para revisar todo processo de comissao 
@Alterado Por: Vanilda Moggio
Alterado em: 13/04/2014
**/
//Programa Original:  ARMXPE19.PRW
Function OGX125()
	If FindFunction("OGXUTOG") //Encontra a fun��o
		If OGXUTOG()
			If FindFunction("OGX125A")
				OGX125A()
		   Endif
		Endif 
	EndIf	
Return( Nil )	