#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} MATA010GIQ
Classe de eventos relacionados com o produto x GIQ
@author Michelle Ramos Henriques
@since 18/11/2020
@version 1.0
/*/
CLASS MATA010GIQ FROM FWModelEvent

	METHOD New() CONSTRUCTOR
//	METHOD Activate()
	METHOD AfterTTS()

ENDCLASS

METHOD New(oModel) CLASS MATA010GIQ

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
METHOD AfterTTS(oModel) Class MATA010GIQ

	Local oMdlSB1 	:= oModel:GetModel("SB1MASTER")

	if oMdlSB1:GetValue("B1_TIPOCQ") == "Q"
		GIQINT(oModel) 
	endIf


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
Function GIQINT(oModel)

	//Local aPrd    := {}
	Local lRet		:= .T.
	Local nI		:= 0
	Local nI1		:= 0
	Local cAliasTop := GetNextAlias()
	Local cQuery    := ""
	Local oMdlSA5 	:= oModel:GetModel("MdGridSA5")
	Local oMdlSB1 	:= oModel:GetModel("SB1MASTER")
	Local cURL 		:= SUPERGETMV("MV_URLGIQ",.F. )
    Local cResource := ":443/giq/core/api/v1/produtos/integracao"
    Local oRest     := FwRest():New(cURL)                              
    Local aHeadOut  := {}
	Local oJson := JsonObject():New()
    
    oRest:SetPath(cResource)

    aHeadOut := ParamIntGIQ() // Traz o token para realizar a integração
    	
	oJson["codigo"] 		:= TRIM(oMdlSB1:GetValue("B1_COD"))
	oJson["descricao"]  	:= TRIM(EncodeUTF8(oMdlSB1:GetValue("B1_DESC")))
	oJson["nome"] 			:= TRIM(EncodeUTF8(oMdlSB1:GetValue("B1_DESC")))
	oJson["unidadeMedida"] 	:= TRIM(oMdlSB1:GetValue("B1_UM"))

	if oModel:GetOperation() == MODEL_OPERATION_DELETE 
		oJson["delete"] := .T.
	else
		oJson["delete"] := .F.
	End if

	oJson['fornecedores'] = {}
	nI1 := 0
	if !oMdlSA5:isEmpty()
		For nI := 1 To oMdlSA5:Length() 
			oMdlSA5:GoLine(nI) 
			if isEmpty(oMdlSA5:GetValue("A5_FORNECE"))
				exit 
			elseif !oMdlSA5:IsDeleted()
				Aadd(oJson['fornecedores'], JsonObject():New())
				nI1++
				oJson['fornecedores'][nI1]['codigo'] := TRIM(oMdlSA5:GetValue("A5_FORNECE")) + '-' + TRIM(oMdlSA5:GetValue("A5_LOJA"))
				SA2->(dbSetOrder(1))
				If SA2->(dbSeek(xFilial("SA2")+ oMdlSA5:GetValue("A5_FORNECE") + oMdlSA5:GetValue("A5_LOJA")))
					
					oJson['fornecedores'][nI1]['nome']		:=  TRIM(EncodeUTF8(SA2 -> A2_NOME))
					
					If empty(SA2 -> A2_CGC)
						oJson['fornecedores'][nI1]['documento'] := nil
					else
						oJson['fornecedores'][nI1]['documento'] 	:= TRIM(SA2 -> A2_CGC)
					endIf
				EndIf
				SA2->(dbCloseArea())
			EndIf
		Next nI
	else
		cQuery := " SELECT DISTINCT A5_FORNECE, A5_LOJA, A5_NOMEFOR " 
		cQuery += " FROM " + RetSqlName("SA5") + " SA5 "
		cQuery += " WHERE SA5.A5_FILIAL = '" + xFilial("SA5") + "' "
		cQuery += " AND SA5.D_E_L_E_T_ = ' ' " 
		cQuery += " AND SA5.A5_produto = '" + oMdlSB1:GetValue("B1_COD") + "' "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

		While !(cAliasTop)->(Eof())
			Aadd(oJson['fornecedores'], JsonObject():New())
			nI1++
			oJson['fornecedores'][nI1]['codigo'] := TRIM((cAliasTop)->A5_FORNECE) + '-' + TRIM((cAliasTop)->A5_LOJA)
			oJson['fornecedores'][nI1]['nome']	 :=  TRIM(EncodeUTF8((cAliasTop)->A5_NOMEFOR))
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+ (cAliasTop)->A5_FORNECE + (cAliasTop)->A5_LOJA))
				If empty(SA2 -> A2_CGC)
					oJson['fornecedores'][nI1]['documento'] := nil
				else
					oJson['fornecedores'][nI1]['documento'] := TRIM(SA2 -> A2_CGC)
				endIf
			EndIf
			SA2->(dbCloseArea())
			(cAliasTop)->(dbSkip())
		End
		(cAliasTop)->(dbCloseArea())
	Endif

    oRest:SetPostParams(oJson:toJson())
    If (oRest:Post(aHeadOut))
		lRet = .T.
    Else
		lRet = .F.
	endIf
	
	
Return lRet

