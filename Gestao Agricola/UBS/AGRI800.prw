#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "AGRI800.CH"

Static cMessage   := "AgriculturalCulture"
Static cModelId   := "AGRA800"
Static nTamCod    := TamSX3("NP3_CODIGO")[1]

/*/{Protheus.doc} AGRI800
Fun��o de integra��o com o adapter EAI para envio e recebimento do cadastro de
culturas (NP3) utilizando o conceito de mensagem �nica.

@param   cXml          Vari�vel com conte�do XML para envio/recebimento.
@param   cTypeTrans    Tipo de transa��o (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Vers�o da mensagem.
@param   cTransac      Nome da transa��o.

@author  Felipe Raposo
@version P12
@since   04/09/2018
@return  aRet  - (array)    Cont�m o resultado da execu��o e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execu��o da fun��o
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem
/*/
Function AGRI800(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aRet := {.F., "", cMessage}

If (cTypeMsg == EAI_MESSAGE_WHOIS)
	aRet[1] := .T.
	aRet[2] := '2.000'

ElseIf (cTypeTrans == TRANS_SEND .or. cTypeTrans == TRANS_RECEIVE)
	If cVersion = "2."
		aRet := v2000(cXml, cTypeTrans, cTypeMsg, cVersion)
	Else
		aRet[2] := STR0001  // "A vers�o da mensagem informada n�o foi implementada!"
	Endif
Endif

Return aRet


/*/{Protheus.doc} v2000
Implementa��o do adapter EAI, vers�o 2.x

@author  Felipe Raposo
@version P12
@since   04/09/2018
/*/
Static Function v2000(cXml, cTypeTrans, cTypeMsg, cVersion)

Local lRet       := .F.
Local cXmlRet    := ""
Local nX

Local oXml, oModel, cRefer, cEvent, nMVCOper
Local aErro, cErro

Local lFound     := .F.
Local xValue     := nil
Local cNodePath  := ""
Local aIntID     := {}
Local aValInt    := {}
Local cValInt    := ""
Local cValExt    := ""

If (cTypeTrans == TRANS_SEND)
	If (cTypeMsg == EAI_MESSAGE_BUSINESS)
		lRet    := .T.
		oModel  := FwModelActive()
		cValInt := oModel:GetValue('NP3MASTER', 'NP3_CODIGO')

		cXMLRet := '<BusinessEvent>'
		cXMLRet += ' <Entity>' + cMessage + '</Entity>'
		cXMLRet += ' <Event>' + If(oModel:GetOperation() = MODEL_OPERATION_DELETE, 'delete', 'upsert') + '</Event>'
		cXMLRet += ' <Identification><key name="code">' + cValInt + '</key></Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet += ' <CompanyId>' + _NoTags(RTrim(cEmpAnt)) + '</CompanyId>'
		cXMLRet += ' <BranchId>' + _NoTags(RTrim(cFilAnt)) + '</BranchId>'
		cXMLRet += ' <CompanyInternalId>' + _NoTags(RTrim(cEmpAnt + '|' + cFilAnt)) + '</CompanyInternalId>'
		cXMLRet += ' <InternalId>' + AI800IntId(nil, cValInt) + '</InternalId>'
		cXMLRet += ' <Code>' + _NoTags(RTrim(cValInt)) + '</Code>'
		If (oModel:GetOperation() <> MODEL_OPERATION_DELETE)
			cXMLRet += ' <Description>' + StrTran(_NoTags(RTrim(oModel:GetValue('NP3MASTER', 'NP3_OBS'))), CRLF, "&#x0d;&#x0a;") + '</Description>'
			cXMLRet += ' <ShortDescription>' + _NoTags(RTrim(oModel:GetValue('NP3MASTER', 'NP3_DESCRI'))) + '</ShortDescription>'
			cXMLRet += ' <PlantationType>' + _NoTags(RTrim(oModel:GetValue('NP3MASTER', 'NP3_TIPO'))) + '</PlantationType>'
			cXMLRet += ' <PlantationDateType>' + _NoTags(RTrim(oModel:GetValue('NP3MASTER', 'NP3_DTPLAN'))) + '</PlantationDateType>'
			cXMLRet += ' <AgeCalculationType>' + _NoTags(RTrim(oModel:GetValue('NP3MASTER', 'NP3_BASE'))) + '</AgeCalculationType>'
			cXMLRet += ' <EstimateType>' + _NoTags(RTrim(oModel:GetValue('NP3MASTER', 'NP3_TPEST'))) + '</EstimateType>'
			cXMLRet += ' <RoundingType>' + _NoTags(RTrim(oModel:GetValue('NP3MASTER', 'NP3_TPARRE'))) + '</RoundingType>'
		Endif
		cXMLRet += '</BusinessContent>'
		oModel := nil
	Endif

ElseIf (cTypeTrans == TRANS_RECEIVE)
	If (cTypeMsg == EAI_MESSAGE_RESPONSE)  // Resposta da mensagem �nica TOTVS.
		// Gravo o de/para local, caso tenha sido gravado o dado no sistema remoto.
		lRet := .T.
		oXml := tXmlManager():New()
		oXml:Parse(cXml)
		If Empty(cErro := oXml:Error())
			If upper(oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ProcessingInformation/Status')) = "OK"
				cRefer := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
				cEvent := AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/ResponseMessage/ReceivedMessage/Event')))
				aIntID := oXml:XPathGetChildArray('/TOTVSMessage/ResponseMessage/ReturnContent/ListOfInternalId')
				For nX := 1 to len(aIntID)
					cValExt := oXml:xPathGetNodeValue(aIntID[nX, 2] + '/Destination')
					cValInt := oXml:xPathGetNodeValue(aIntID[nX, 2] + '/Origin')
					If cEvent = 'DELETE' .and. !empty(cValInt)
						CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", nil, cValInt, .T.)
					ElseIf !empty(cValInt) .and. !empty(cValExt)
						CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", cValExt, cValInt)
					Else
						lRet  := .F.
						cErro := STR0002 + "|"  // "Erro no processamento pela outra aplica��o"
						cErro += STR0003        // "Erro ao processar de/para de c�digos."
					Endif
				Next nX
			Else
				lRet  := .F.
				cErro := STR0002 + "|"  // "Erro no processamento pela outra aplica��o|"
				aErro := oXml:XPathGetChildArray('/TOTVSMessage/ResponseMessage/ProcessingInformation/ListOfMessages')
				For nX := 1 To len(aErro)
					cErro += oXml:xPathGetAtt(aErro[nX, 2], 'type') + ": " + Alltrim(oXml:xPathGetNodeValue(aErro[nX, 2])) + "|"
				Next nX
			Endif
		Endif
		oXml := nil

	ElseIf (cTypeMsg == EAI_MESSAGE_RECEIPT)  // Recibo.
		// N�o realiza nenhuma a��o.

	ElseIf (cTypeMsg == EAI_MESSAGE_BUSINESS)  // Chegada de mensagem de neg�cios.
		oXml := tXmlManager():New()
		oXml:Parse(cXml)
		If Empty(cErro := oXml:Error())
			lRet    := .T.
			cRefer  := oXml:xPathGetAtt('/TOTVSMessage/MessageInformation/Product', 'name')
			cEvent  := AllTrim(Upper(oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessEvent/Event')))
			cValExt := oXml:xPathGetNodeValue('/TOTVSMessage/BusinessMessage/BusinessContent/InternalId')
			cValInt := RTrim(CFGA070Int(cRefer, "NP3", "NP3_CODIGO", cValExt))
			aValInt := StrToKarr2(cValInt, "|", .T.)

			// Verifica se encontrou uma chave no de/para.
			If len(aValInt) > 2
				NP3->(dbSetOrder(1))  // NP3_FILIAL, NP3_CODIGO.
				lFound := NP3->(dbSeek(xFilial(nil, aValInt[2]) + aValInt[3], .F.))
			Endif

			If lFound
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_UPDATE
				ElseIf cEvent == 'DELETE'
					nMVCOper := MODEL_OPERATION_DELETE
				Else
					lRet  := .F.
					cErro := STR0004  // "Opera��o inv�lida. Somente s�o permitidas as opera��es UPSERT e DELETE."
				Endif
			Else
				If cEvent == 'UPSERT'
					nMVCOper := MODEL_OPERATION_INSERT
				ElseIf cEvent == 'DELETE'
					lRet  := .F.
					cErro := STR0005  // "Registro n�o encontrado no Protheus."
				Else
					lRet  := .F.
					cErro := STR0004  // "Opera��o inv�lida. Somente s�o permitidas as opera��es UPSERT e DELETE."
				Endif
			Endif

			If lRet
				oModel := FwLoadModel(cModelId)
				oModel:SetOperation(nMVCOper)
				If oModel:Activate()
					If nMVCOper <> MODEL_OPERATION_DELETE
						cNodePath := '/TOTVSMessage/BusinessMessage/BusinessContent/'

						// Se for inclus�o, trata o c�digo do registro.
						If nMVCOper == MODEL_OPERATION_INSERT
							// Usa o inicializador padr�o do campo de c�digo.
							cValInt := oModel:GetValue('NP3MASTER', 'NP3_CODIGO')

							// Se o c�digo n�o tiver inicializador padr�o, tenta usar o c�digo do sistema de origem.
							If empty(cValInt)
								If oXml:XPathHasNode(cNodePath + 'Code')
									cValInt := RTrim(oXml:xPathGetNodeValue(cNodePath + 'Code'))
								Endif

								// Se o c�digo for maior do que o campo do Protheus, n�o usar esse c�digo.
								If len(cValInt) > nTamCod
									cValInt := ""
								Endif
							Endif

							// Se o c�digo j� existir na base, n�o usar esse c�digo.
							If !empty(cValInt)
								cValInt := PadR(cValInt, nTamCod)
								NP3->(dbSetOrder(1))  // NP3_FILIAL, NP3_CODIGO.
								If NP3->(dbSeek(xFilial() + cValInt, .F.))
									cValInt := ""
								Endif
							Endif

							// Se n�o puder usar o mesmo c�digo da origem, usa numera��o sequencial autom�tica.
							If empty(cValInt)
								cValInt := GetSXENum('NP3', 'NP3_CODIGO')
							Endif

							// Atualiza o c�digo no modelo.
							If oModel:GetValue('NP3MASTER', 'NP3_CODIGO') <> cValInt
								oModel:SetValue('NP3MASTER', 'NP3_CODIGO', cValInt)
							Endif

							cValInt := AI800IntId(nil, cValInt)
						Endif

						If oXml:XPathHasNode(cNodePath + 'Description')
							xValue := oXml:xPathGetNodeValue(cNodePath + 'Description')
							oModel:SetValue('NP3MASTER', 'NP3_OBS',    xValue)
						Endif
						If oXml:XPathHasNode(cNodePath + 'ShortDescription')
							xValue := oXml:xPathGetNodeValue(cNodePath + 'ShortDescription')
							oModel:SetValue('NP3MASTER', 'NP3_DESCRI', xValue)
						Endif
						If oXml:XPathHasNode(cNodePath + 'PlantationType')
							xValue := oXml:xPathGetNodeValue(cNodePath + 'PlantationType')
							oModel:SetValue('NP3MASTER', 'NP3_TIPO', xValue)
						Endif
						If oXml:XPathHasNode(cNodePath + 'PlantationDateType')
							xValue := oXml:xPathGetNodeValue(cNodePath + 'PlantationDateType')
							oModel:SetValue('NP3MASTER', 'NP3_DTPLAN', xValue)
						Endif
						If oXml:XPathHasNode(cNodePath + 'AgeCalculationType')
							xValue := oXml:xPathGetNodeValue(cNodePath + 'AgeCalculationType')
							oModel:SetValue('NP3MASTER', 'NP3_BASE', xValue)
						Endif
						If oXml:XPathHasNode(cNodePath + 'EstimateType')
							xValue := oXml:xPathGetNodeValue(cNodePath + 'EstimateType')
							oModel:SetValue('NP3MASTER', 'NP3_TPEST', xValue)
						Endif
						If oXml:XPathHasNode(cNodePath + 'RoundingType')
							xValue := oXml:xPathGetNodeValue(cNodePath + 'RoundingType')
							oModel:SetValue('NP3MASTER', 'NP3_TPARRE', xValue)
						Endif
					Endif
					lRet := oModel:VldData() .and. oModel:CommitData()

					// Se gravou certo, retorna o c�digo gravado.
					If lRet
						// Atualiza o de/para local.
						If nMVCOper = MODEL_OPERATION_DELETE
							CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", nil, cValInt, .T.)
						ElseIf nMVCOper = MODEL_OPERATION_INSERT
							CFGA070Mnt(cRefer, "NP3", "NP3_CODIGO", cValExt, cValInt)
						Endif

						cXmlRet := '<ListOfInternalId>'
						cXmlRet += ' <InternalId>'
						cXmlRet += '  <Origin>' + cValExt + '</Origin>'
						cXmlRet += '  <Destination>' + cValInt + '</Destination>'
						cXmlRet += ' </InternalId>'
						cXmlRet += '</ListOfInternalId>'
					Endif
				Else
					lRet  := .F.
					cErro := StrTran(STR0006, "%cModelId%", cModelId)  // "Erro ao ativar modelo %cModelId%."
				Endif

				If !lRet
					cErro := STR0007  // "A integra��o n�o foi bem sucedida. "
					aErro := oModel:GetErrorMessage()
					If !Empty(aErro)
						cErro += STR0008 + Alltrim(aErro[5]) + '-' + AllTrim(aErro[6])  // "Foi retornado o seguinte erro: "
						If !Empty(Alltrim(aErro[7]))
							cErro += CRLF + STR0009 + AllTrim(aErro[7])  // "Solu��o: "
						Endif
					Else
						cErro += STR0010  // "Verifique os dados enviados."
					Endif
				Endif
				oModel:Deactivate()
				oModel:Destroy()
				oModel := nil
			Endif
		Else
			lRet := .F.
		Endif
		oXml := nil
	Endif
EndIf

DelClassIntF()

// Se deu erro no processamento.
If !empty(cErro)
	lRet    := .F.
	cXmlRet := "<![CDATA[" + _NoTags(cErro) + "]]>"
Endif

Return {lRet, cXmlRet, cMessage}


/*/{Protheus.doc} AI800IntId
Monta o InternalId do registro.

@author  Felipe Raposo
@version P12
@since   04/09/2018
/*/
Function AI800IntId(cFilOrig, cCodOrig)
Default cFilOrig := cFilAnt
Default cCodOrig := NP3->NP3_CODIGO
Return _NoTags(cEmpAnt + '|' + xFilial("NP3", cFilOrig) + '|' + cCodOrig)


/*/{Protheus.doc} AI800Cod
Busca a chave local do registro a partir do InternalId do sistema remoto.

@author  Felipe Raposo
@version P12
@since   04/09/2018
/*/
Function AI800Cod(cRefer, cValExt)
Local cValInt := RTrim(CFGA070Int(cRefer, "NP3", "NP3_CODIGO", cValExt))
Local aValInt := StrToKarr2(cValInt, "|", .T.)
Return aValInt
