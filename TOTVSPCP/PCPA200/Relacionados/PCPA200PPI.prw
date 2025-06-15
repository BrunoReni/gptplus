#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PCPA200.CH"

Static __aErros   := {}
Static __aSucesso := {}

/*/{Protheus.doc} MATA200PPI
Realiza a integra��o com o PC-Factory - PPI Multitask
@author Marcelo Neumann
@version P12
@since 08/05/2020
@param 01 cXml     , caracter, XML que ser� enviado.
                               Caso n�o seja passado esse parametro, ser� realizada a chamada do Adapter para cria��o do XML.
			       		       Se for passado esse par�metro, n�o ser� exibida a mensagem de erro caso exista,
			       		       nem ser� considerado o filtro da tabela SOE.
@param 02 cProduto , caracter, obrigat�rio quando utilizado o par�metro cXml. Cont�m o c�digo do produto
@param 03 nOperacao, num�rico, indica a opera��o que est� sendo realizada.
@param 04 lFiltra  , l�gico  , identifica se ser� realizado ou n�o o filtro do registro.
@param 05 lPendAut , l�gico  , indica se ser� gerada a pend�ncia sem realizar a pergunta para o usu�rio, caso ocorra algum erro.
@return   lRet     , l�gico  , indica se a integra��o com o PC-Factory foi realizada sem erro
/*/
Function PCPA200PPI(cXml, cProduto, nOperacao, lFiltra, lPendAut)
	Local aArea       := GetArea()
	Local aAreaSG1    := SG1->(GetArea())
	Local lRet        := .T.
	Local aRetXML     := {}
	Local aRetWS      := {}
	Local aRetData    := {}
	Local aRetArq     := {}
	Local cNomeXml    := ""
	Local cGerouXml   := ""
	Local lProc       := .F.

	Default cXml      := ""
	Default cProduto  := ""
	Default lFiltra   := .T.
	Default lPendAut  := .T.

	Private lRunPPI   := .T. //Vari�vel utilizada para identificar que est� sendo executada a integra��o para o PPI dentro do MATI200.
	Private Inclui    := nOperacao == MODEL_OPERATION_INSERT
	Private Altera    := nOperacao == MODEL_OPERATION_UPDATE

	If !Empty(cProduto) .And. nOperacao <> MODEL_OPERATION_DELETE
		SG1->(dbSetOrder(1))
		If !SG1->(dbSeek(xFilial("SG1") + cProduto))
			Altera := .F.
			If lFiltra .And. PCPFiltPPI("SG1", cProduto, "SG1")
				lProc := .T.
			EndIf
		EndIf
	EndIf

	//Realiza filtro na tabela SOE, para verificar se o produto entra na integra��o.
	If lFiltra
		//Faz o filtro posicionando em todos os componentes.
		//Se qualquer componente entrar na integra��o, ser� realizado o processamento.
		While SG1->(!Eof()) .And. xFilial("SG1") + cProduto == SG1->G1_FILIAL + SG1->G1_COD
			If PCPFiltPPI("SG1", cProduto, "SG1")
				lProc := .T.
				Exit
			EndIf
			SG1->(dbSkip())
		End
	Else
		lProc := .T.
	EndIf

	If lProc
		//Adapter para cria��o do XML
		If Empty(cXml)
			aRetXML := MATI200("", TRANS_SEND, EAI_MESSAGE_BUSINESS)
		Else
			aRetXML := {.T.,cXml}
		EndIf
		/*
		aRetXML[1] - Status da cria��o do XML
		aRetXML[2] - String com o XML
		*/

		If aRetXML[1]
			//Retira os caracteres especiais
			aRetXML[2] := EncodeUTF8(aRetXML[2])

			//Busca a data/hora de gera��o do XML
			aRetData := PCPxDtXml(aRetXML[2])
			/*
				aRetData[1] - Data de gera��o AAAAMMDD
				aRetData[1] - Hora de gera��o HH:MM:SS
			*/

			//Envia o XML para o PCFactory
			aRetWS := PCPWebsPPI(aRetXML[2])
			/*
				aRetWS[1] - Status do envio ("1" - OK, "2" - Pendente, "3" - Erro.)
				aRetWS[2] - Mensagem de retorno do PPI
			*/
			If aRetWS[1] == "3"
				lRet := .F.
			EndIf

			//Cria o XML fisicamente no diret�rio parametrizado
			aRetArq := PCPXmLPPI(aRetWS[1], "SG1", cProduto, aRetData[1], aRetData[2], aRetXML[2])
			/*
				aRetArq[1] Status da cria��o do arquivo. .T./.F.
				aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso n�o tenha criado o XML.
			*/
			If aRetArq[1]
				cNomeXml := aRetArq[2]
			Else
				If Empty(cXml) .And. !lPendAut
					Help( ,, 'Help',, aRetArq[2], 1, 0)
				EndIf
				lRet := .F.
			EndIf

			If Empty(cNomeXml)
				cGerouXml := "2"
			Else
				cGerouXml := "1"
			EndIf

			//Cria a tabela SOF
			PCPCriaSOF("SG1", cProduto, aRetWS[1], cGerouXml, cNomeXml, aRetData[1], aRetData[2], __cUserId, aRetWS[2], aRetXML[2])

			//Array com os componentes que tiveram erro.
			If aRetWS[1] == "1"
				aAdd(__aSucesso, {cProduto})
			Else
				aAdd(__aErros  , {cProduto, AllTrim(aRetWS[2])})
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSG1)

Return lRet

/*/{Protheus.doc} P200ErrPPI
Exibe uma tela com as mensagens de erro que aconteceram durante a integra��o
@author Marcelo Neumann
@version P12
@since 08/05/2020
@return Nil
/*/
Function P200ErrPPI()

	Local oDlgErr, oPanel, oBrwErr, oGetTot, oGetErr, oGetSuc
	Local aDadosInt := {}
	Local cMsg      := ""
	Local nTotErr   := Len(__aErros)
	Local nTotOk    := Len(__aSucesso)
	Local nTotal    := nTotErr + nTotOk
	Local nInd      := 1

	If nTotErr == 1
		cMsg := STR0236 + AllTrim(__aErros[1][1]) + ". " + STR0237 //"N�o foi poss�vel realizar a integra��o com o TOTVS MES para o produto " XXX. "Foi gerada uma pend�ncia de integra��o para este produto."
		HelpInDark(.F.)
		Help( ,, 'Help',, cMsg, 1, 0)
		HelpInDark(.T.)

	ElseIf nTotErr > 1
		For nInd := 1 To nTotErr
			aAdd(aDadosInt, {__aErros[nInd][1], Posicione("SB1",1,xFilial("SB1") + __aErros[nInd][1], 'B1_DESC'), STR0134, __aErros[nInd][2]}) //"Erro"
		Next nInd

		For nInd := 1 To nTotOk
			aAdd(aDadosInt, {__aSucesso[nInd][1], Posicione("SB1",1,xFilial("SB1") + __aSucesso[nInd][1], 'B1_DESC'), STR0235, STR0133}) //"Ok" / "Processado com sucesso"
		Next nInd

		DEFINE MSDIALOG oDlgErr TITLE STR0230 FROM 0,0 TO 350,800 PIXEL //"Erros integra��o TOTVS MES"

		oPanel := tPanel():Create(oDlgErr,01,01,,,,,,,401,156)

		//Cria Browse
		oBrwErr := TCBrowse():New(0, 0, 400, 155, , ;
								{STR0011, STR0018, STR0231, STR0135}, ; //"Produto" / "Descri��o" / "Status" / "Mensagem"
								{80, 110, 30, 400}, oPanel,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)

		//Seta vetor para a browse
		oBrwErr:SetArray(aDadosInt)
		oBrwErr:bLine := {||{ aDadosInt[oBrwErr:nAT,1],;
							  aDadosInt[oBrwErr:nAt,2],;
							  aDadosInt[oBrwErr:nAt,3],;
							  aDadosInt[oBrwErr:nAt,4]}}
		oPanel:Refresh()
		oPanel:Show()

		@ 162, 02 Say STR0232 Of oDlgErr Pixel //"Total de registros:"
		@ 160, 48 MSGET oGetTot VAR nTotal  SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

		@ 162, 90 Say STR0233 Of oDlgErr Pixel //"Processados com erro:"
		@ 160,150 MSGET oGetErr VAR nTotErr SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

		@ 162,190 Say STR0234 Of oDlgErr Pixel //"Processados com sucesso:"
		@ 160,260 MSGET oGetSuc VAR nTotOk  SIZE 30,8 OF oDlgErr PIXEL NO BORDER WHEN .F.

		DEFINE SBUTTON FROM 160,373 TYPE 1 ACTION (oDlgErr:End()) ENABLE OF oDlgErr
		ACTIVATE DIALOG oDlgErr CENTERED
	EndIf

	aSize(__aSucesso, 0)
	aSize(__aErros  , 0)

Return Nil