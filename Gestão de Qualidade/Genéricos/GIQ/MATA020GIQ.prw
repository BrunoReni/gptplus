#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} MATA020GIQ
Classe de eventos relacionados com o produto x GIQ
@author Michelle Ramos Henriques
@since 18/11/2020
@version 1.0
/*/
CLASS MATA020GIQ FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS()

ENDCLASS

METHOD New(oModel) CLASS MATA020GIQ

Return

/*/{Protheus.doc} ModelPosVld
Pós Commit do modelo
@author Michelle Ramos Henriques
@since 18/11/2020
@version 1.0
@param 01 oModel  , Object   , Modelo de dados que será validado
@return   lRet    , Logical  , Indica se o modelo foi validado com sucesso
/*/
METHOD AfterTTS(oModel) Class MATA020GIQ
	If SuperGetMv("MV_INTGIQE", .F., .F.)
		GIQFornec(oModel)
	EndIf
Return .T.

Function GIQFornec(oModel, cBeare)

	Local oMdlSA2 	:= oModel:GetModel("SA2MASTER")
	Local oJson     := JsonObject():New()

	oJson["codigo"] 		:= TRIM(oMdlSA2:GetValue("A2_COD")) + '-' + TRIM(oMdlSA2:GetValue("A2_LOJA"))
	oJson['nome']			:= TRIM(EncodeUTF8(oMdlSA2:GetValue("A2_NOME")))
	If empty(oMdlSA2:GetValue("A2_CGC"))
		oJson['documento'] := Nil
	else
		oJson['documento'] 	:= TRIM(EncodeUTF8(oMdlSA2:GetValue("A2_CGC")))
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_DELETE 
		oJson["delete"] := .T.
	else
		oJson["delete"] := .F.
	EndIf

	IntegraGIQ():enviaFornecedorParaGIQ(oJson)
	FreeObj(oJson)
	oJson := Nil
	
Return

