#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0066
Fun��o para permitir que a classe seja visualizada
no inspetor de objetos
@author  Squad OMS
@since   18/02/2019
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0066()
Return Nil

/*/{Protheus.doc} MATA010EVOMS
Eventos do MVC relacionados a integra��o de complemento de produto com o Cockpit Log�stico

Todas as valida��es de modelo, linha, pr� e pos, tamb�m todas as intera��es com a grava��o
s�o definidas nessa classe.

Importante: Use somente a fun��o Help para exibir mensagens ao usuario, pois apenas o help
� tratado pelo MVC. 

Documenta��o sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    class
@author  guilherme.metzger
@since   05/12/2018
@version 12
/*/
CLASS MATA180EVOMS FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD InTTS()
ENDCLASS

METHOD New() CLASS MATA180EVOMS
Return

/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit ap�s as grava��es,
por�m antes do final da transa��o

@type    method
@author  guilherme.metzger
@since   05/12/2018
@version 12
/*/
METHOD InTTS(oModel) CLASS MATA180EVOMS
	//Chamada de fun��o OMS para verificar integra��o com o CPL
	If !(oModel:GetOperation() == MODEL_OPERATION_DELETE) .And. FindFunction("OMSXCPLINT")
		OMSXCPLINT("SB5")
	EndIf
Return
