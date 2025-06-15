#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA020.ch'

/*/{Protheus.doc} MATA020EVTAF
Eventos do MVC relacionados a integração de Fornecedor com o TAF.
Qualquer regra que seja referente ao TAF deve ser criada aqui.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA020EVTAF FROM FWModelEvent
		
	METHOD New() CONSTRUCTOR
	
	METHOD InTTS()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA020EVTAF
Return

/*/{Protheus.doc} InTTS
Depois da gravação do fornecedor, integra com o TAF.

@type metodo
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
METHOD InTTS(oModel, cID) CLASS MATA020EVTAF
Local nOpc := oModel:GetOperation()
	
	// ==============================================
	// Demetrio - 11/2014 - Integração TAF 
	// ==============================================
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE 
		TAFIntOnLn("T003FOR",nOpc,cFilAnt)
	EndIf
	
Return .T.