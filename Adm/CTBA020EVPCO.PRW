#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/**
Fonte contendo o processo de integra��o com o SIGAPCO
*/

Class CTBA020EVPCO FROM FWModelEvent

	Data lIntPco

	Method New()
	Method VldActivate(oModel, cModelId)
	Method BeforeTTS(oModel, cModelId)
	Method InTTS(oModel, cModelId)

End Class

Method New() Class CTBA020EVPCO
	If SuperGetMv("MV_PCOINTE") == "1" .And. SuperGetMv("MV_PCOSINC") == "2"
		Self:lIntPco := .T.
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPreVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de
pre valida��o do Model

@author TOTVS
@version P12
/*/
//-------------------------------------------------------------------
Method VldActivate(oModel, cModelId) Class CTBA020EVPCO
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()

	// Verifica a integra��o com o SIGAPCO
	If Self:lIntPco .And. nOperation == MODEL_OPERATION_DELETE
		lRet := PCOA010ELK()
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
Inicio da transa��o antes da grava��o

@author TOTVS
@version P12
/*/
//-------------------------------------------------------------------
Method BeforeTTS(oModel, cModelId) Class CTBA020EVPCO
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()

	If Self:lIntPco .And. nOperation == MODEL_OPERATION_DELETE

		If PCOVldSinc("CT1",oModel:GetValue("CT1MASTER","CT1_CONTA"))
			PcoSincCO("CT1",3)
		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
Ap�s as grava��es por�m antes do final da transa��o

@author TOTVS
@version P12
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class CTBA020EVPCO
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()

	If Self:lIntPco

		If nOperation == MODEL_OPERATION_INSERT

			PcoSincCO("CT1",1)

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			PcoSincCO("CT1",2)

		EndIf

	EndIf

	FWModelActive(oModel)

Return lRet