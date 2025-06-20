#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"


/*/{Protheus.doc} SUPA001
Fun��o para reservar o nome do fonte. 

@author  Wesley Alves Pereira - TOTVS
@version P12 
@since   20/06/2017
/*/

Function SUPA001()

FwIntegDef("SUPA001")

Return

/*/{Protheus.doc} IntegDef
Fun��o para chamar o adapter de mensagem �nica de substitui��o de t�tulo a receber.

@author  Wesley Alves Pereira - TOTVS
@version P12
@since   22/05/2017

@param cXML, caracter, XML da mensagem �nica para envio/recebimento.
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transa��o da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posi��es sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/


Static Function IntegDef(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aRet := {}

aRet := SUPI001(cXML, nTypeTrans, cTypeMessage, AllTrim(cVersion))
   
Return aRet