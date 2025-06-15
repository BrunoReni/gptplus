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
	If oMdlSB1:GetValue("B1_TIPOCQ") == "Q" .AND. SuperGetMv("MV_INTGIQE", .F., .F.)
		GIQINT(oModel) 
	EndIf
Return .T.

/*/{Protheus.doc} GIQINT
	@author Michelle Ramos Henriques
	@since 19/11/2020
	@version 1.0
/*/
Function GIQINT(oModel)

	Local cAliasTop 	:= GetNextAlias()
	Local cQuery    	:= ""
	Local nIndice		:= 0
	Local nFornecedores	:= 0
	Local oMdlSA5 		:= oModel:GetModel("MdGridSA5")
	Local oMdlSB1 		:= oModel:GetModel("SB1MASTER")
	Local oJson 		:= JsonObject():New()
	Local oFornecedor   := JsonObject():New()
	Local oGIQ0003Class := GIQ0003Class():New()
    	
	oJson["codigo"] 		:= TRIM(oMdlSB1:GetValue("B1_COD"))
	oJson["descricao"]  	:= TRIM(EncodeUTF8(oMdlSB1:GetValue("B1_DESC")))
	oJson["nome"] 			:= TRIM(EncodeUTF8(oMdlSB1:GetValue("B1_DESC")))
	oJson["unidadeMedida"] 	:= TRIM(oMdlSB1:GetValue("B1_UM"))

	If oModel:GetOperation() == MODEL_OPERATION_DELETE 
		oJson["delete"] := .T.
	Else
		oJson["delete"] := .F.
	EndIf

	oJson['fornecedores'] = {}
	nFornecedores := 0
	If oMdlSA5 != NIL .AND. !oMdlSA5:isEmpty()
		SA2->(dbSetOrder(1))
		For nIndice := 1 To oMdlSA5:Length() 
			oMdlSA5:GoLine(nIndice) 
			If isEmpty(oMdlSA5:GetValue("A5_FORNECE"))
				exit 
			ElseIf !oMdlSA5:IsDeleted()
				nFornecedores++
				Aadd(oJson['fornecedores'], JsonObject():New())
				oJson['fornecedores'][nFornecedores]['codigo'] := TRIM(oMdlSA5:GetValue("A5_FORNECE")) + '-' + TRIM(oMdlSA5:GetValue("A5_LOJA"))
				If SA2->(dbSeek(xFilial("SA2")+ oMdlSA5:GetValue("A5_FORNECE") + oMdlSA5:GetValue("A5_LOJA")))
					oJson['fornecedores'][nFornecedores]['nome']			:=  TRIM(EncodeUTF8(SA2 -> A2_NOME))
					If Empty(SA2 -> A2_CGC)
						oJson['fornecedores'][nFornecedores]['documento'] 	:= nil
					Else
						oJson['fornecedores'][nFornecedores]['documento'] 	:= TRIM(SA2 -> A2_CGC)
					EndIf
				EndIf

				oFornecedor = oGIQ0003Class:CriaFornecedorJson("SA2")
        		IntegraGIQ():enviaFornecedorParaGIQ(oFornecedor)
				FreeObj(oFornecedor)
				oFornecedor := Nil
			EndIf
		Next nIndice
		SA2->(dbCloseArea())
	Else
		cQuery := " SELECT DISTINCT A5_FORNECE, A5_LOJA, A5_NOMEFOR " 
		cQuery += " FROM " + RetSqlName("SA5") + " SA5 "
		cQuery += " WHERE SA5.A5_FILIAL = '" + xFilial("SA5") + "' "
		cQuery += " AND SA5.D_E_L_E_T_ = ' ' " 
		cQuery += " AND SA5.A5_produto = '" + oMdlSB1:GetValue("B1_COD") + "' "
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)

		SA2->(dbSetOrder(1))
		While !(cAliasTop)->(Eof())
			nFornecedores++
			Aadd(oJson['fornecedores'], JsonObject():New())
			oJson['fornecedores'][nFornecedores]['codigo'] := TRIM((cAliasTop)->A5_FORNECE) + '-' + TRIM((cAliasTop)->A5_LOJA)
			oJson['fornecedores'][nFornecedores]['nome']   := TRIM(EncodeUTF8((cAliasTop)->A5_NOMEFOR))
			If SA2->(dbSeek(xFilial("SA2") + (cAliasTop)->A5_FORNECE + (cAliasTop)->A5_LOJA))
				If Empty(SA2 -> A2_CGC)
					oJson['fornecedores'][nFornecedores]['documento'] := nil
				Else
					oJson['fornecedores'][nFornecedores]['documento'] := TRIM(SA2 -> A2_CGC)
				EndIf
				oFornecedor = oGIQ0003Class:CriaFornecedorJson("SA2")
        		IntegraGIQ():enviaFornecedorParaGIQ(oFornecedor)
				FreeObj(oFornecedor)
				oFornecedor := Nil
			EndIf
			(cAliasTop)->(dbSkip())
		EndDo
		(cAliasTop)->(dbCloseArea())
		SA2->(dbCloseArea())
	EndIf

	IntegraGIQ():enviaProdutoParaGIQ(oJson)
	FreeObj(oJson)
	oJson := Nil
	
Return
