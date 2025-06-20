#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSA130EVOMS.CH"

#DEFINE OMS130EV01 "OMS130EV01"
#DEFINE OMS130EV02 "OMS130EV02"

//-------------------------------------------------------------------
CLASS OMSA130EVOMS FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD GridLinePosVld(oSubModel, cModelID, nLine)
	METHOD ModelPosVld(oModel, cModelId)
ENDCLASS

METHOD New()�CLASS OMSA130EVOMS
Return

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o da linha do Grid
//-------------------------------------------------------------------
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS OMSA130EVOMS
Local oModel  := FWModelActive()

	If cModelID == "MdGridIDAG"

		If oSubModel:GetValue("DAG_TEMPO") == "0000:00"
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS130EV01,OmsFmtMsg(STR0001,{{"[VAR01]",FWX3Titulo("DAG_TEMPO")}}),OmsFmtMsg(STR0002,{{"[VAR01]",}})) // "Valor inv�lido para o campo [VAR01]." // "Preencha o campo [VAR01] com um valor diferente de 0000:00."
			Return .F.
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS OMSA130EVOMS
Local oModelFld := Nil
Local cGrpCli   := ""
Local cCodCli   := ""
Local cCodLoj   := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

		oModelFld := oModel:GetModel("MdFieldCDAF")
		cGrpCli   := oModelFld:GetValue("DAF_GRPCLI")
		cCodCli   := oModelFld:GetValue("DAF_CODCLI")
		cCodLoj   := oModelFld:GetValue("DAF_LOJA"  )

		If Empty(cGrpCli) .And. (Empty(cCodCli) .Or. Empty(cCodLoj))
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,OMS130EV02,STR0003,OmsFmtMsg(STR0004,{{"[VAR01]",FWX3Titulo("DAF_GRPCLI")},{"[VAR02]",FWX3Titulo("DAF_CODCLI")},{"[VAR03]",FWX3Titulo("DAF_LOJA")}})) // "Um ou mais campos obrigat�rios n�o foram preenchidos." // "� necess�rio informar um valor para o campo [VAR01] ou para o conjunto de campos [VAR02] e [VAR03]."
			Return .F.
		EndIf

	EndIf

Return .T.
