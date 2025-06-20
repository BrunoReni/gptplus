#include "Totvs.ch"
#include "OFValLicenca.ch"

/*/
{Protheus.doc} OFValLicenca
Classe de valida��o do uso e exist�ncia de licen�as nas rotinas do DMS.
@type   Function
@author Ot�vio Favarelli
@since  19/10/2021
@param  nil
@return nil
/*/
Class OFValLicenca

	Method New() CONSTRUCTOR
	Static Method ValidaLicencaDMS()
	
EndClass

/*/
{Protheus.doc} ValidaLicencaDMS
M�todo que realiza a valida��o de chamadas das rotinas do DMS para verifica��o do uso correto das licen�as.
@type   Function
@author Ot�vio Favarelli
@since  19/10/2021
@param  nil
@return nil
/*/
Method ValidaLicencaDMS() Class OFValLicenca
	Local lAmiin

	FwBlkUserFunction(.t.)
	lAmiin := AMIIn(11,14,41) // 11=Veiculos | 14=Oficina | 41=Auto Pecas
	FwBlkUserFunction(.f.)

	If !lAmiin
		Aviso(STR0001,STR0002,{STR0003}) // Imposs�vel Continuar! | As rotinas dos m�dulos de Varejo Automotivo � DMS s� podem ser acessadas diretamente nestes m�dulos (SIGAOFI, SIGAVEI e SIGAPEC), que necessitam de licenciamento espec�fico. | OK
	EndIf

Return lAmiin
