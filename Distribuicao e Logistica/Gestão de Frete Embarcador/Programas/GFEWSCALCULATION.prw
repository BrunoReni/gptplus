#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
 
WSRESTFUL FREIGHTCALCULATION DESCRIPTION "Servi�o especifico para execu��o do calculo de frete do m�dulo SIGAGFE - GEST�O DE FRETE EMBARCADOR"
 
WSMETHOD GET  DESCRIPTION "Exemplo de arquivo JSON para utilizar com base no c�lculo de frete no m�dulo SIGAGFE - GEST�O DE FRETE EMBARCADOR"                         WSSYNTAX "supply/gfe/v1/freightcalculations || /GET/{id}"
WSMETHOD POST DESCRIPTION "Executa o c�lculo de frete e recebe as mensagens de retorno de cada romaneio solicitado no m�dulo SIGAGFE - GEST�O DE FRETE EMBARCADOR"    WSSYNTAX "supply/gfe/v1/freightcalculations || /POST/{id}"

END WSRESTFUL

WSMETHOD GET WSSERVICE FREIGHTCALCULATION
	Local oResponse   := JsonObject():New()

	/* DEFINI��O DOS TAMANHOS DOS CAMPOS*/
	Local nGWN_NRROM  := TamSX3("GWN_NRROM")[1]
	
	/* A FILIAL DEVE SER ENVIADA VIA PROTOCOLO REST NO HEADER tenantId CONFORME DOCUMENTA��O DO PROTOCOLO REST NA TDN*/  

	// define o tipo de retorno do m�todo
	::SetContentType("application/json")
	 
	//oResponse["description"] := EncodeUTF8("API PARA CALCULO DE FRETE NO M�DULO SIGAGFE - GEST�O DE FRETE EMBARCADOR (WEB SERVICE - REST)")
	
	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())

	oResponse["content"][1]["Items"][1]["Manifest"] := {}

	Aadd(oResponse["content"][1]["Items"][1]["Manifest"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"] := {}
	
	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["id"] := "ManifestNumber"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["length"] := nGWN_NRROM
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["Description"] := "N�mero do Romaneio para c�lculo"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][1]["Items"])["value"] := PADR("1",nGWN_NRROM,'0')

	Aadd(oResponse["content"][1]["Items"][1]["Manifest"], JsonObject():New())
	oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"] := {}
	
	Aadd(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"], JsonObject():New())
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["id"] := "ManifestNumber"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["length"] := nGWN_NRROM
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["type"] := "string"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["Description"] := "N�mero do Romaneio para c�lculo"
	aTail(oResponse["content"][1]["Items"][1]["Manifest"][2]["Items"])["value"] := PADR("2",nGWN_NRROM,'0')


	::SetResponse(EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.)))
	
Return .T.

WSMETHOD POST WSSERVICE FREIGHTCALCULATION
	Local oContent		:= Nil
	Local aRetCalc
	Local aRetRom		:= {}
	Local cContent		:= ""
	Local lRet			:= .T.
	Local aRet			:= {}
	Local cReturn		:= ""
	Local nCont 		:= 0
	Local cMsg			:= ""
	Local cArqLogCalc	:= ""
	
	// define o tipo de retorno do m�todo
	::SetContentType("application/json")
	
	cContent :=  ::GetContent()
	
	aRet := ValidContent(cContent)
	If !aRet[1]
		::SetResponse(EncodeUTF8(FWJsonSerialize(aRet[2], .F., .F., .T.)))
		Return .T.
	EndIf
	
	FWJsonDeserialize(cContent,@oContent)
	
	aRet := ReadContent(oContent)
	
	for nCont:= 1 to Len(aRet)
		cArqLogCalc := ""
		cMsg		:= ""
		if aRet[nCont][1]
			GWN->(dbSetOrder(1))
			GWN->(dbSeek(xFilial("GWN") + aRet[nCont][2]))

			aRetCalc := GFE050CALC(Nil,.F.,@cMsg,,,@cArqLogCalc) 

			if aRetCalc .AND. Empty(cMsg)
				aAdd(aRetRom,{aRet[nCont][2],"C�lculo realizado com sucesso","ok",cArqLogCalc})
			else
				aAdd(aRetRom,{aRet[nCont][2],cMsg,'error',cArqLogCalc})
			EndIf
		Else
			aAdd(aRetRom,{aRet[nCont][2],aRet[nCont][3],'error',cArqLogCalc})
		EndIf
	next
	
	cReturn := FWJsonSerialize(WriteCalculation(aRetRom), .F., .F., .T.)
	
	::SetResponse(EncodeUTF8(cReturn))
Return .T.

/*/{Protheus.doc} WriteCalculation
//TODO Monta o Json da c�lculo de frete realizado.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return oResponse, ${Objeto Json da c�lculo de frete}
@param aRetFrete, array, Array com a c�lculo de frete calculado
@type function
/*/
Static Function WriteCalculation(aRetFrete)
	Local oResponse	:= JsonObject():New()
	Local nCont		:= 0
	
	oResponse["content"] := {}
	Aadd(oResponse["content"], JsonObject():New())

	oResponse["content"][1]["Items"] := {}
	Aadd(oResponse["content"][1]["Items"], JsonObject():New())
	
	oResponse["content"][1]["Items"][1]["Status"]	:= "ok" 
	oResponse["content"][1]["Items"][1]["Message"]	:= "freightcalculations: C�lculo(s) de Frete realizado(s). Verifique o Status de cada Romaneio calculado."

	oResponse["content"][1]["Items"][1]["FreightCalculation"] := {}

	for nCont:= 1 to Len(aRetFrete)

		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"] := {}
		
		Aadd(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"], JsonObject():New())
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["id"] 			:= "ManifestNumber"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["value"] 		:= aRetFrete[nCont][1]
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Description"] := "N�mero do Romaneio para c�lculo"
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Message"] 	:= aRetFrete[nCont][2]
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["Status"] 		:= aRetFrete[nCont][3]
		aTail(oResponse["content"][1]["Items"][1]["FreightCalculation"][nCont]["Items"])["FileMessage"] := aRetFrete[nCont][4]

	next

Return oResponse

/*/{Protheus.doc} ReadContent
//TODO Realiza a leitura do conteudo enviado no m�todo POST.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param oContent, object, descri��o
@type function
/*/
Static Function ReadContent(oContent)
	Local aManifest
	Local nContent			:= 0
	Local aAgrFrt		:= {} // Agrupadores de frete
	Local aAux			:= {}
	Local lRet			:= .T.
	Local cMsgErro		:= ""
	Local cAuxMN
	/* DEFINI��O DE TAMANHO DE CAMPOS*/
	
	Local nGWN_NRROM  := TamSX3("GWN_NRROM")[1] 
	
	For nContent:= 1 to Len(oContent["content"][1]["Items"][1]["Manifest"])
		aManifest 			:= oContent["content"][1]["Items"][1]["Manifest"][nContent]["Items"]
		
		aAux	:= {}
		lRet	:= .T.
		
		cAuxMN := GFEGETVALUE(aManifest,"ManifestNumber",nGWN_NRROM)
		If lRet .AND. Empty(cAuxMN)
			lRet := .F.
			cMsgErro := 'Campo ManifestNumber. N�mero do Romaneio n�o informado. Informe um n�mero de romaneio. '
			aAux := {lRet, cAuxMN, cMsgErro}
		EndIf

		If lRet
			GWN->(dbSetOrder(1))
			If !GWN->(dbSeek(xFilial("GWN") + cAuxMN))
				lRet := .F.
				cMsgErro := 'Campo ManifestNumber. N�mero do Romaneio informado n�o � v�lido, romaneio n�o encontrado na base de dados. ('+xFilial("GWN") + cAuxMN+')'
				aAux := {lRet, cAuxMN, cMsgErro}
			EndIf
		EndIf

		If lRet
			lRet := .T.
			cMsgErro := ''
			aAux := {lRet, cAuxMN, cMsgErro}
		EndIf

		AADD(aAgrFrt, aAux)
	next

Return aAgrFrt


/*/{Protheus.doc} GFEGETVALUE
//TODO Descri��o Retorna o valor do campo de um objeto Json.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return Conteudo do objeto 
@param jValues, TJson , Ojeto Json
@param cCampo, characters, Nome do conteudo a ser encontrado
@type function
/*/
Static Function GFEGETVALUE(jValues,cCampo,nTamSX3,cDefault)
	Local nCampos := 0
	Local cRet := ""
	Default nTamSX3 := 0
	for nCampos:= 1 to Len(jValues)
		if Upper(jValues[nCampos]["id"]) == Upper(cCampo)
			cRet	:= jValues[nCampos]["value"]
			Loop
		EndIf
	next
	if Empty(cRet) .AND. !Empty(cValToChar(cDefault))
		cRet := cDefault
	EndIf
	if nTamSX3 > 0
		cRet := PadR(cRet,nTamSX3)
	EndIf
Return cRet


/*/{Protheus.doc} ValidContent
//TODO Realiza as valida�oes dos arquivo.
@author andre.wisnheski
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cContent, characters, descri��o
@type function
/*/
Static Function ValidContent(cContent)
	Local oResponse   := JsonObject():New()
	
	if Empty(cContent)
		oResponse["content"] := {}
		Aadd(oResponse["content"], JsonObject():New())
	
		oResponse["content"][1]["Items"] := {}
		Aadd(oResponse["content"][1]["Items"], JsonObject():New())
		oResponse["content"][1]["Items"][1]["Status"]	:= "error" 
		oResponse["content"][1]["Items"][1]["Message"]	:= "freightcalculations: N�o foi poss�vel executar o c�lculo de frete."
		oResponse["content"][1]["Items"][1]["Error"]	:= "freightcalculations: Dados do c�lculo n�o encontrado no corpo da requisi��o. No m�todo POST deve ser enviado no corpo da mensagem os dados para realizar o c�lculo de frete. Execute o m�todo GET para pegar JSON de exemplo."
		
		Return {.F., oResponse}
	EndIf
Return {.T.,nil}














