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
//	METHOD Activate()
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
@param 02 cModelId, Character, ID do modelo de dados que está sendo validado
@return   lRet    , Logical  , Indica se o modelo foi validado com sucesso
/*/
METHOD AfterTTS(oModel) Class MATA020GIQ

	
	GIQFornec(oModel) 
	
Return .T.

/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 19/11/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function GIQFornec(oModel, cBeare)

	Local lRet		:= .T.
	Local oMdlSA2 	:= oModel:GetModel("SA2MASTER")
	Local cURL 		:= SUPERGETMV("MV_URLGIQ",.F. )
    Local cResource := ":443/giq/core/api/v1/fornecedores/integracao"
    Local oRest     := FwRest():New(cURL)                              
    Local aHeadOut  := {}
	Local oJson := JsonObject():New()
    
    oRest:SetPath(cResource)

    aHeadOut := ParamIntGIQ() // Traz o token para realizar a integração
    	
	oJson["codigo"] 		:= TRIM(oMdlSA2:GetValue("A2_COD")) + '-' + TRIM(oMdlSA2:GetValue("A2_LOJA"))
	oJson['nome']			:= TRIM(EncodeUTF8(oMdlSA2:GetValue("A2_NOME")))
	If empty(oMdlSA2:GetValue("A2_CGC"))
		oJson['documento'] := nil
	else
		oJson['documento'] 	:= TRIM(EncodeUTF8(oMdlSA2:GetValue("A2_CGC")))
	endIf

	if oModel:GetOperation() == MODEL_OPERATION_DELETE 
		oJson["delete"] := .T.
	else
		oJson["delete"] := .F.
	End if

    oRest:SetPostParams(oJson:toJson())
    If (oRest:Post(aHeadOut))
		lRet = .T.
	endIf
	
	
Return .T.

