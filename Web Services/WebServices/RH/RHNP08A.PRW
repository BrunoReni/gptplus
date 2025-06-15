#INCLUDE "TOTVS.CH"
#INCLUDE "RHNP08.CH"

/*/{Protheus.doc} VldDtFer13
Valida se o usuário podera solicitar 13 em férias iniciadas em Jan e Dez.
@author: Marcelo Silveira
@since:	06/08/2021
@param:	dDtIniFer - Data de inicio das férias.
@return: Nil
/*/

Function VldDtFer13(dDtIniFer)

Local lPermite    := SuperGetMV("MV_MRHS13F",,.T.)
Local nMonth      := Month(dDtIniFer)
Local cMsgValid   := ""

If !lPermite .And. ( nMonth == 1 .Or. nMonth == 12 )
    cMsgValid := OemToAnsi(STR0074) // N�o � permitido solicitar o adiantamento do 13 Salario em f�rias iniciadas em Janeiro ou Dezembro..
EndIf

Return cMsgValid
