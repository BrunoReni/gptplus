#include "PROTHEUS.CH" 

/*/{Protheus.doc} GIQ0001
Executa Agendamentos de Integração GIQ x Proteus
@author    brunno.costa
@since     30/08/2021
/*/
Function GIQ0001()

	Local bErrorBlock    := ErrorBlock({|e| IntegraGIQ():incluiMensagemPendente('retornaLaudosGeraisPendentes', 'retornaLaudosGeraisPendentes', '', e:Description) })
	
	Begin Sequence
		IntegraGIQ():processaTodasBaixasEstoqueCQ()
	End Sequence
	ErrorBlock({|e| .T. })
	
	Begin Sequence
		IntegraGIQ():reprocessaPendenciasEnvioParaGIQ()
	End Sequence
	ErrorBlock(bErrorBlock)
Return Nil

/*/{Protheus.doc} SchedDef
Executar o programa GIQ0001 no schedule
@author  Michelle RAmos Henriques
@since   30/03/2021
/*/
Static Function SchedDef()
	Local aMov := {}
	Local aParam := {}
	aParam := { "P",;
				"PARAMDEF",;
				"SD7",;
				aMov,;
			}
Return aParam
