#include 'Protheus.ch'
#include 'FWMVCDef.ch' 

/*/{Protheus.doc} MATA010EVOMS
Eventos do MVC relacionados a integra��o de fornecedor com o Cockpit Log�sitco (OMS)
Qualquer regra que seja referente ao OMS deve ser criada aqui.

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type class
 
@author amanda.vieira
@since 12/04/2018
@version 12.1.17
/*/
CLASS MATA010EVOMS FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD InTTS()
ENDCLASS

METHOD New() CLASS MATA010EVOMS
Return
/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit ap�s as grava��es,
por�m antes do final da transa��o

@type method
 
@author amanda.vieira
@since 12/04/2018
@version 12.1.17
/*/
METHOD InTTS(oModel) CLASS MATA010EVOMS
	//Chamada de fun��o OMS para verificar integra��o com o CPL
	If !(oModel:GetOperation() == MODEL_OPERATION_DELETE) .And. FindFunction("OMSXCPLINT")
		OMSXCPLINT("SB1")
	EndIf
Return