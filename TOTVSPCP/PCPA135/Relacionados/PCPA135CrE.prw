#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA135.CH"

//Est�ticas para guardar os par�metros do Wizard
Static soProgrBar := Nil
Static snNivel    := 1
Static snStatus   := 3
Static snComps    := 2
Static sdDataDe   := SToD("        ")
Static sdDataAte  := SToD("        ")
Static snJaExist  := 1
Static snPreEstr  := 2
Static slAltPai   := .F.
Static scNovoPai  := CriaVar("G1_COD")

//Est�ticas de controle
Static saRegInclu := {}  //{GG_COD, GG_COMP, GG_TRT}
Static saRegExclu := {}  //{GG_COD, GG_COMP, GG_TRT}
Static saListaCmp := {}  //{GG_LISTA, GG_COMP, GG_TRT, CARGOPAI, INDICADOR, LINHA}

//Est�ticas para guardar os par�metros
Static sMvAPRESTR := SuperGetMV("MV_APRESTR",.F.,.F.)
Static sMvPCPRLEP := SuperGetMV("MV_PCPRLEP",.F., 2)

//Est�ticas de integra��o
Static sIntgPPI   := PCPIntgPPI()

/*/{Protheus.doc} PCPA135CrE
Cria estrutura a partir da pr�-estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lCriou, logical, indica se foi criada a estrutura
/*/
Function PCPA135CrE(aAutoCab)

	Local lCriou    := .F.
	Local lOk       := .T.
	Local oNewModel := FWLoadModel("PCPA135")
	Local oNewView  := FWLoadView("PCPA135")
	Local oViewExec := Nil
	Local cMsgErro := ""

	Default aAutoCab := Nil

	If aAutoCab <> Nil

		// Verificar se existe se foi passado o parametro AUTNIVCRIAEST - Considera Niveis
		nPos := aScan(aAutoCab, {|x| x[1] == "AUTNIVCRIAEST"})
		If nPos > 0 .And. !Empty(aAutoCab[nPos][2])
			// Verifica se os dados s�o validos
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|"
				snNivel := aAutoCab[nPos][2]
			Else
				cMsgErro := STR0293 								// "Valor informado no par�metro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inv�lido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor v�lido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Par�metro "
				cMsgErro += "AUTNIVCRIAEST" + " "
				cMsgErro += STR0302 	// "n�o infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
			EndIf
			lOk := .F.
		EndIf
		
		nPos := aScan(aAutoCab, {|x| x[1] == "AUTCONSIDSTT"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|3|"
				//Se o utiliza a al�ada de aprova��o, s� considera pr�-estruturas aprovadas
				If sMvAPRESTR
					If aAutoCab[nPos][2] == 1
						snStatus := aAutoCab[nPos][2]
					Else
						cMsgErro := STR0299 		// "Devido ao par�metro MV_APRESTR, apenas pr�-estruturas aprovadas podem gerar estrutura"
						Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0300})  // "Aprove a pr�-estrutura antes de gerar a estrutra"
						lOk := .F.
					EndIf
				Else
					snStatus := aAutoCab[nPos][2]
				EndIf
			Else
				cMsgErro := STR0293 								// "Valor informado no par�metro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inv�lido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor v�lido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Par�metro "
				cMsgErro += "AUTCONSIDSTT" + " "
				cMsgErro += STR0302 	// "n�o infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
			EndIf
			lOk := .F.
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTCONSIDCOMP"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|3|"
				snComps := aAutoCab[nPos][2]
				// Caso selecionado a op��o "Validos no periodo", atribui as datas.
				If snComps == 3
					nPos := aScan(aAutoCab, {|x| x[1] == "AUTDTDE"})
					If nPos > 0 .And. !Empty(aAutoCab[nPos][2])
						sdDataDe := aAutoCab[nPos][2]
					Else
						cMsgErro := STR0301 	// "Par�metro "
						cMsgErro += "AUTDTDE" + " "
						cMsgErro += STR0302 	// "n�o infromado"
						Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTDE"})  // "Informe o par�metro "
						lOk := .F.
					EndIf
					nPos := aScan(aAutoCab, {|x| x[1] == "AUTDTATE"})
					If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
						sdDataAte := aAutoCab[nPos][2]
					Else
						If lOk
							cMsgErro := STR0301 	// "Par�metro "
							cMsgErro += "AUTDTATE" + " "
							cMsgErro += STR0302 	// "n�o infromado"
							Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
						EndIf
						lOk := .F.
					EndIf
				EndIf
			Else
				cMsgErro := STR0293 								// "Valor informado no par�metro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inv�lido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor v�lido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Par�metro "
				cMsgErro += "AUTCONSIDCOMP" + " "
				cMsgErro += STR0302 	// "n�o infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
			EndIf
			lOk := .F.
		EndIf

		If lOk
			lOk := ValidaPag2()
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTESTEX"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|"
				snNivel := aAutoCab[nPos][2]
			Else
				cMsgErro := STR0293 								// "Valor informado no par�metro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inv�lido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor v�lido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Par�metro "
				cMsgErro += "AUTESTEX" + " "
				cMsgErro += STR0302 	// "n�o infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
			EndIf
			lOk := .F.
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTPREESTGRAV"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|"
				snNivel := aAutoCab[nPos][2]
			Else
				cMsgErro := STR0293 								// "Valor informado no par�metro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inv�lido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor v�lido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Par�metro "
				cMsgErro += "AUTPREESTGRAV" + " "
				cMsgErro += STR0302 	// "n�o infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
			EndIf
			lOk := .F.
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTALTPAI"})
		If lOk .and. (nPos > 0 .And. (aAutoCab[nPos][2] == .T. .Or. aAutoCab[nPos][2] == .F.))
			If aAutoCab[nPos][2]
				slAltPai := .T.
				nPos := aScan(aAutoCab, {|x| x[1] == "AUTNVPAI"})
				If nPos > 0 .And. !Empty(aAutoCab[nPos][2])
					scNovoPai := aAutoCab[nPos][2]
				Else
					If lOk
						cMsgErro := STR0301 	// "Par�metro "
						cMsgErro += "AUTNVPAI" + " "
						cMsgErro += STR0302 	// "n�o infromado"
						Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
					EndIf
				EndIf
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Par�metro "
				cMsgErro += "AUTALTPAI" + " "
				cMsgErro += STR0302 	// "n�o infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o par�metro "
			EndIf
			lOk := .F.
		EndIf

		If lOk
			lCriou := ValidaPag3(oNewModel, .T.)
		EndIf

	Else
		oViewExec := FWViewExec():New()

		//Desabilita a edi��o dos campos
		oNewView:SetOnlyView("V_FLD_MASTER")
		oNewView:SetOnlyView("V_FLD_SELECT")
		oNewView:SetOnlyView("V_GRID_DETAIL")
		oNewView:setUpdateMessage(" ", STR0181) //"Estrutura criada com sucesso."

		oViewExec:setTitle(STR0169) //"Criar Estrutura"
		oViewExec:setOK({|oNewModel| lCriou := WizCriacao(oNewModel)})
		oViewExec:setCancel({|oNewModel| CanCriacao(oNewModel)})
		oViewExec:setSource("PCPA135")
		oViewExec:setView(oNewView)
		oViewExec:setModel(oNewModel)
		oViewExec:setOperation(MODEL_OPERATION_UPDATE)
		oViewExec:setModal(.F.)
		oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0038},; //"Confirmar"
							{.T.,STR0037},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})   //"Cancelar"
		oViewExec:openView(.T.)
	EndIf

Return lCriou

/*/{Protheus.doc} CanCriacao
Fun��o acionada ao Cancelar a opera��o
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return .T., logical, permite o cancelamento
/*/
Static Function CanCriacao(oModel)

	oModel:lModify := .F.

Return .T.

/*/{Protheus.doc} WizCriacao
Abre o Wizard para a cria��o da estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lCriou, logical, indica se o processamento foi confirmado e criou a estrutura
/*/
Static Function WizCriacao(oModel)

	Local oStepWiz := FWWizardControl():New(,{520, 670})
	Local oNewPag  := Nil
	Local lCriou   := .F.

	//Adiciona os passos no Wizard
	oStepWiz:ActiveUISteps()

	//P�gina 1
	oNewPag := oStepWiz:AddStep("1", {|oPanel| MontaPag1(oPanel)})
	oNewPag:SetStepDescription(STR0182) //"In�cio"

	//P�gina 2
	oNewPag := oStepWiz:AddStep("2", {|oPanel| MontaPag2(oPanel)})
	oNewPag:SetStepDescription(STR0183) //"Leitura"
	oNewPag:SetNextAction({|| ValidaPag2()})

	//P�gina 3
	oNewPag := oStepWiz:AddStep("3", {|oPanel| MontaPag3(oPanel)})
	oNewPag:SetStepDescription(STR0184) //"Grava��o"
	oNewPag:SetNextAction({|| lCriou := ValidaPag3(oModel)})

	oStepWiz:Activate()
	oStepWiz:Destroy()

	aSize(saListaCmp,0)

Return lCriou

/*/{Protheus.doc} MontaPag1
Monta a primeira p�gina do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da p�gina
@return Nil
/*/
Static Function MontaPag1(oPanel)

	//Configura��o as fontes
	Local oFont13B := TFont():New("Arial", , -13, , .T.)
	Local oFont12  := TFont():New("Arial", , -12, , .F.)
	Local oFont12B := TFont():New("Arial", , -12, , .T.)

	//Textos da tela ("Bem-Vindo...")
	Local oSay1 := TSay():New(05, 10, {|| STR0185 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Cria��o de Estrutura"
	Local oSay2 := TSay():New(50, 10, {|| STR0186 }, oPanel, , oFont12B, , , , .T., , , 290, 20) //"Bem-Vindo..."
	Local oSay3 := TSay():New(70, 10, {|| STR0187 }, oPanel, , oFont12 , , , , .T., , , 320, 100, , , , , , , 3) //"Este assistente permite o preenchimento das informa��es para cria��o de estruturas com base nas pr�-estruturas."

Return Nil

/*/{Protheus.doc} MontaPag2
Monta a segunda p�gina do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oPanel, object , painel a serem adicionados os componentes da p�gina
@return Nil
/*/
Static Function MontaPag2(oPanel)

	//Configura��o as fontes
	Local oFont13B := TFont():New("Arial", , -13, , .T.)
	Local oFont11  := TFont():New("Arial", , -11, , .F.)

	//Texto do cabe�alho
	Local oTitulo   := TSay():New(05, 10, {|| STR0188 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Par�metros para leitura"
	Local oDecricao := TSay():New(15, 10, {|| STR0189 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os par�metros relacionados a leitura dos dados."

	//Grupo: Considera n�veis
	Local oGroup1 := TGroup():New(45, 40, 90, 120, STR0190, oPanel, , , .T.) //"Considera n�veis"
	Local oRadio1 := TRadMenu():New(55, 50, {STR0191, STR0192}, {|u| If(PCount() == 0, snNivel, snNivel := u)}, oGroup1, , , , , , , , 60, 40, , , , .T.) //"Todos","Primeiro N�vel"

	//Grupo: Considera status
	Local oGroup2 := Nil
	Local oRadio2 := Nil

	//Grupo: Considera componentes
	Local oGroup3 := TGroup():New(45, 150, 150, 295, STR0193, oPanel, , , .T.) //"Considera componentes"
	Local oSay1   := TSay():New(097, 195, {|| STR0194 }, oGroup3, , oFont11, , , , .T., , , 30, 20) //"De:"
	Local oSay2   := TSay():New(112, 195, {|| STR0195 }, oGroup3, , oFont11, , , , .T., , , 30, 20) //"At�:"
	Local oTGet1  := TGet():New(095, 210, {|u| If(PCount() == 0, sdDataDe , sdDataDe  := u)}, oGroup3, 60, 10, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"sdDataDe" ,,,,.T.)
	Local oTGet2  := TGet():New(110, 210, {|u| If(PCount() == 0, sdDataAte, sdDataAte := u)}, oGroup3, 60, 10, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"sdDataAte",,,,.T.)
	Local oRadio3 := TRadMenu():New(55, 160, {STR0196, STR0197, STR0198}, ; //"Qualquer data" - "Data v�lida" - "V�lidos no per�odo"
	                                {|u| If(PCount() == 0, snComps, snComps := u)}, oGroup3, , ;
									{||  If(snComps == 3, EnableData(oTGet1, oTGet2, .T.), EnableData(oTGet1, oTGet2, .F.) )}, , , , , , 100, 60, , , , .T.)

	//Desabilita os campos de Data
	If snComps <> 3
		oTGet1:Disable()
		oTGet2:Disable()
	EndIf

	//Se o utiliza a al�ada de aprova��o, s� considera pr�-estruturas aprovadas
	If sMvAPRESTR
		snStatus := 1
	Else
		oGroup2 := TGroup():New(100, 40, 150, 120, STR0199, oPanel, , , .T.) //"Considera status"
		oRadio2 := TRadMenu():New(110, 50, {STR0200, STR0201, STR0202}, ; //"Aprovados" - "Rejeitados" - "Todos"
		                          {|u| If(PCount() == 0, snStatus, snStatus := u)}, oGroup2, , , , , , , , 60, 40, , , , .T.)
	EndIf

Return Nil

/*/{Protheus.doc} MontaPag3
Monta a terceira p�gina do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da p�gina
@return Nil
/*/
Static Function MontaPag3(oPanel)

	//Configura��o as fontes
	Local oFont13B := TFont():New("Arial", , -13, , .T.)
	Local oFont11  := TFont():New("Arial", , -11, , .F.)

	//Texto do cabe�alho
	Local oTitulo   := TSay():New(05, 10, {|| STR0203 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Par�metros para grava��o"
	Local oDecricao := TSay():New(15, 10, {|| STR0204 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os par�metros relacionados a grava��o dos dados."

	//Grupo: Estruturas j� existentes
	Local oGroup1 := TGroup():New(45, 40, 90, 145, STR0205, oPanel, , , .T.) //"Estruturas j� existentes"
	Local oRadio1 := TRadMenu():New(55,  50, {STR0206, STR0207}, {|u| If(PCount() == 0, snJaExist, snJaExist := u)}, oGroup1, , , , , , , , 60, 40, , , , .T.) //"Sobrescreve" - "Mant�m"

	//Grupo: Pr�-Estrutura gravada
	Local oGroup2 := TGroup():New(45, 190, 90, 295, STR0208, oPanel, , , .T.) //"Pr�-Estrutura gravada"
	Local oRadio2 := TRadMenu():New(55, 200, {STR0209, STR0223}, {|u| If(PCount() == 0, snPreEstr, snPreEstr := u)}, oGroup2, , , , , , , , 60, 40, , , , .T.) //"Apaga" - "Mant�m"

	//Altera codigo do pai?
	Local oCheck1 := TCheckBox():New(107, 40, STR0210, {|u| If(PCount() == 0, slAltPai, slAltPai := u)}, oPanel, 90, 40, , ; //"Altera c�digo do produto pai "
	                                 {|| If(slAltPai, oTGet1:Enable(), ( scNovoPai := CriaVar("G1_COD"), oTGet1:Disable(), oTGet1:CtrlRefresh()) )  }, , , , , , .T., , , )
	Local oTGet1  := TGet():New(105, 130, {|u| If(PCount() == 0, scNovoPai, scNovoPai := u)}, oPanel, 100, 10, "@!", {|| ValidaPai()}, , , , , , .T., , , , , , , .F., .F., , "scNovoPai", , , , , .F.)

 	oTGet1:cF3 := "SB1"

	//Desabilita o campo Produto
	If !slAltPai
		oTGet1:Disable()
	EndIf

	//Define a barra de progresso
	soProgrBar := Nil
	soProgrBar := TMeter():New(140, 40, , 100, oPanel, 255, 12, , .T.)
	soProgrBar:lVisible := .F.

Return Nil

/*/{Protheus.doc} ValidaPai
Emite alerta caso o produto informado j� possua estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lOk, logic, indica se o produto informado pode ser utilizado
/*/
Static Function ValidaPai()

	Local lOk := .T.

	If !Empty(scNovoPai)
		SG1->(dbSetOrder(1))
		If SG1->(dbSeek(xFilial("SG1") + scNovoPai))
			Aviso(STR0211, STR0212,{"Ok"}) //"Aten��o!" - "J� existe estrutura para esse produto."
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} EnableData
Habilita ou Desabilita os campos Data De e Data At�
@author Marcelo Neumann
@since 18/02/2019
@version P12
@param 01 oTGet1 , object, objeto do componente Data De
@param 02 oTGet2 , object, objeto do componente Data At�
@param 03 lEnable, logic , indica se dever� habilitar (.T.) ou desabiliar (.F.) os componentes
@return Nil
/*/
Static Function EnableData(oTGet1, oTGet2, lEnable)

	If lEnable
		oTGet1:Enable()
		oTGet2:Enable()
	Else
		sdDataDe  := SToD("        ")
		sdDataAte := SToD("        ")
		oTGet1:CtrlRefresh()
		oTGet2:CtrlRefresh()
		oTGet1:Disable()
		oTGet2:Disable()
	EndIf

Return Nil

/*/{Protheus.doc} ValidaPag2
Valida��o da segunda p�gina do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lRet, logic, indica se a p�gina est� v�lida
/*/
Static Function ValidaPag2()

	Local lRet := .T.

	If snComps == 3
		If Empty(sdDataDe) .Or. Empty(sdDataAte)
			Help( ,  , "Help", , STR0213, 1, 0, , , , , , {""})  //"Per�odo informado inv�lido."
			lRet := .F.
		EndIf

		If sdDataDe > sdDataAte
			Help( ,  , "Help", ,  STR0213, ; //"Per�odo informado inv�lido."
			     1, 0, , , , , , {STR0214	} ) //"Data De deve ser menor que Data At�."
			lRet := .F.
		EndIf
	EndIf

	//Se a p�gina estiver v�lida, esconde a barra de progresso (caso ela j� tenha sido criada/exibida)
	If lRet
		If !Empty(soProgrBar)
			soProgrBar:lVisible := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ValidaPag3
Valida��o da terceira p�gina do Wizard e processamento
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal
@return lRet, logic, indica se o processamento foi finalizado com sucesso
/*/
Static Function ValidaPag3(oModel, lAuto)

	Local lRet := .T.

	If slAltPai
		If Empty(scNovoPai)
			Help( ,  , "Help", ,  STR0215, ; //"C�digo do Produto n�o informado."
				 1, 0, , , , , , {STR0216} ) //"Informe um c�digo para o produto pai ou desmarque a op��o de altera��o de c�digo."
			lRet := .F.
		Else
			lRet := ExistCpo("SB1", scNovoPai)
		EndIf
	EndIf

	//Se a p�gina est� v�lida, inicia a grava��o da estrutura
	If lRet
		lRet := GravaSG1(oModel, lAuto)
	EndIf
	If lRet
		If ExistBlock ("MTA202CRIA")
			ExecBlock ("MTA202CRIA",.F.,.F.,{oModel:GetModel("FLD_MASTER"):GetValue("GG_COD"),scNovoPai})
		Endif
	EndIf

Return lRet

/*/{Protheus.doc} GravaSG1
Realiza o processamento da grava��o da estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal
@return lRet, logic, indica se o processamento foi finalizado com sucesso
/*/
Static Function GravaSG1(oModel, lAuto)

	Local aCab      := {}
	Local aItem     := {}
	Local cBkpPai   := scNovoPai
	Local cCargoPai := ""
	Local nQtdBase  := Nil
	Local nTotal    := Nil
	Local nOperAuto := 3
	Local lRet      := .F.
	Local oView     := FWViewActive()
	Local nAcao		:= 1 	// 1 = Cria a estrutura // 2 = Altera a pr�-estrutura // 3 = Mant�m no Wizard

	Private lMsErroAuto := .F.

	If lAuto
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		oModel:GetModel("FLD_MASTER"):SetValue("CEXECAUTO", "S")
		//Adiciona o produto PAI.
		cCargoPai := P135AddPai(oModel:GetModel("FLD_MASTER"):GetValue("GG_COD"))
		//Carrega os componentes
		P135TreeCh(.F.,cCargoPai)
		nQtdBase  := oModel:GetModel("FLD_MASTER"):GetValue("NQTBASE")
		nTotal    := oModel:GetModel("GRID_DETAIL"):Length() + 1
	Else
		nQtdBase  := oModel:GetModel("FLD_MASTER"):GetValue("NQTBASE")
		nTotal    := oModel:GetModel("GRID_DETAIL"):Length() + 1
	EndIf
	
	//Limpa as mensagens de HELP
	FwClearHLP()

	If !lAuto
		//Exibe a barra de progresso
		soProgrBar:SetTotal(nTotal)
		soProgrBar:Set(0)
		soProgrBar:lVisible := .T.
	EndIf

	//Inicializa as vari�veis de controle
	IniciaArr()

	//Verifica se ser� utilizado um pai diferente
	If !slAltPai
		scNovoPai := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	EndIf

	If !lAuto
		cCargoPai := oModel:GetModel("FLD_MASTER"):GetValue("CARGO")
		P135TrSeek(cCargoPai, , .T.)
	EndIf

	//Cabe�alho para o ExecAuto
	aCab := {{"G1_COD"   , scNovoPai, NIL},; //C�digo do produto PAI
	         {"G1_QUANT" , nQtdBase , NIL},; //Quantidade base do produto PAI
	         {"ATUREVSB1", "N"      , NIL},; //A vari�vel ATUREVSB1 � utilizada para gerar nova revis�o quando MV_REVAUT=.F.
	         {"NIVALT"   , "N"      , NIL}}  //A vari�vel NIVALT � utilizada para recalcular ou n�o os n�veis da estrutura.

	//Prepara as tabelas que ser�o usadas na fun��o recursiva
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	dbSelectArea("SVG")
	SVG->(dbSetOrder(1))
	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1") + scNovoPai))
		//Se j� existe estrutura para o pai, altera para Modifica��o
		nOperAuto := 4
	EndIf

	//Carrega os componentes
	lRet := CargaItens(aItem, oModel, .F., cCargoPai, lAuto)

	If lRet
		If Empty(aItem)
			Help( ,  , "Help", ,  STR0217, ; //"N�o existem registros para criar a estrutura."
			     1, 0, , , , , , {STR0218} ) //"Revise os par�metros informados."
			lRet := .F.
		Else
			//Valida a Lista de Componente
			nAcao := ValidLista(oModel, lAuto)
			If nAcao == 1
				//Carrega os registros que dever�o ser exclu�dos
				ExcluiSG1(aItem)

				//Processa a Cria��o/Altera��o da estrutura
				MSExecAuto({|x,y,z,w| PCPA200(x,y,z,w)}, aCab, aItem, nOperAuto, "PCPA135CrE")

				If !lAuto
					//Seta valor m�ximo na barra de progresso
					soProgrBar:Set(nTotal)
				EndIf

				//Verifica se ocorreu algum erro, e exibe a mensagem
				If lMsErroAuto
					lRet := .F.
					MostraErro()
					DesfazAltP(oModel)
				Else
					//Se integra com o MES, exibe a mensagem de alerta caso tenha ocorrido algum erro
					If sIntgPPI
						P200ErrPPI()
					EndIf
					lRet := .T.
				EndIf
			ElseIf nAcao == 2
				oView:SetUpdateMessage(" ", STR0276) //"Pr�-estrutura alterada com sucesso."
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//Retorna a vari�vel com o pai informado pelo usu�rio
	scNovoPai := cBkpPai

Return lRet

/*/{Protheus.doc} IniciaArr
Inicializa as vari�veis utilizadas no processamento
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return Nil
/*/
Static Function IniciaArr()

	If saRegInclu == NIL
		saRegInclu := {}
	Else
		aSize(saRegInclu,0)
	EndIf

	If saRegExclu == NIL
		saRegExclu := {}
	Else
		aSize(saRegExclu,0)
	EndIf

Return Nil

/*/{Protheus.doc} CargaItens
Seleciona os registros que ser�o utilizados na cria��o da estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem     , array 	, array com os itens a serem enviados ao ExecAuto
@param 02 oModel    , object	, modelo principal
@param 03 lRecursiva, logic 	, indica se � uma chamada recursiva da fun��o
@param 04 cCargoPai , characters, campo CARGO do pai
@return lRet, logic, indica se ouve erro durante a carga dos dados
/*/
Static Function CargaItens(aItem, oModel, lRecursiva, cCargoPai, lAuto)

	Local oMdlGrd    := oModel:GetModel("GRID_DETAIL")
	Local oMdlSelec	 := oModel:GetModel("FLD_SELECT")
	Local cCargoAtu  := oMdlSelec:GetValue("CARGO")
	Local cCodSeek   := ""
	Local lExiste    := .T.
	Local nInd       := 1
	Local lRet       := .T.

	Default lAuto := .F.

	//Se estiver na primeira chamada, pai pode n�o ser o que est� carregado no modelo
	If lRecursiva
		cCodSeek := oMdlGrd:GetValue("GG_COD", 1)
	Else
		cCodSeek := scNovoPai
	EndIf

	//Verifica se o produto possui estrutura
	If SG1->(dbSeek(xFilial("SG1") + cCodSeek))
		//Sobrescreve
		If snJaExist == 1
			While !SG1->(Eof())                     .And. ;
				   SG1->G1_FILIAL == xFilial("SG1") .And. ;
				   SG1->G1_COD    == cCodSeek

				If ExistNaRev()
					//Se o componente n�o est� na pr�-estrutura, deve deletar o registro (sobrescrever estrutura)
					If aScan(saRegInclu, {|x| x[1] == SG1->G1_COD  .And. ;
											  x[2] == SG1->G1_COMP .And. ;
											  x[3] == SG1->G1_TRT}) == 0
						aAdd(saRegExclu, {SG1->G1_COD, SG1->G1_COMP, SG1->G1_TRT})
					EndIf
				EndIf

				SG1->(dbSkip())
			End

		//Mant�m
		Else
			//Se foi marcado para manter as estruturas existentes, retorna
			Return lRet
		EndIf
	EndIf

	//Percorre os componentes da pr�-estrutura
	For nInd := 1 To oMdlGrd:Length()

		//Tratativa para n�o processar mais de uma vez o mesmo componente
		If aScan(saRegInclu, {|x| x[1] == oMdlGrd:GetValue("GG_COD" , nInd) .And. ;
		                          x[2] == oMdlGrd:GetValue("GG_COMP", nInd) .And. ;
		                          x[3] == oMdlGrd:GetValue("GG_TRT" , nInd)}) == 0

			oMdlGrd:GoLine(nInd)
			aAdd(saRegInclu, {oMdlGrd:GetValue("GG_COD" ),;
			                  oMdlGrd:GetValue("GG_COMP"),;
							  oMdlGrd:GetValue("GG_TRT" )})

			//Valida os parametros informados na tela
			If ValidParam(oMdlGrd)

				//Verifica se o componente existe
				lExiste := .F.
				If SG1->(dbSeek(xFilial("SG1") + cCodSeek + oMdlGrd:GetValue("GG_COMP") + oMdlGrd:GetValue("GG_TRT")))
					While !SG1->(Eof())                                  .And. ;
					       SG1->G1_FILIAL == xFilial("SG1")              .And. ;
					       SG1->G1_COD    == cCodSeek                    .And. ;
					       SG1->G1_COMP   == oMdlGrd:GetValue("GG_COMP") .And. ;
					       SG1->G1_TRT    == oMdlGrd:GetValue("GG_TRT")

						If ExistNaRev()
							//Sobrescreve
							If snJaExist == 1
								//Se o componente existe na estrutura na revis�o atual, o mesmo ser� alterado ao inv�s de exclu�do
								nPos := aScan(saRegExclu, {|x| x[1] == cCodSeek                    .And. ;
								                               x[2] == oMdlGrd:GetValue("GG_COMP") .And. ;
															   x[3] == oMdlGrd:GetValue("GG_TRT")})
								aDel(saRegExclu, nPos)
								aSize(saRegExclu,Len(saRegExclu) - 1)
							EndIf

							lExiste := .T.
							Exit
						EndIf

						SG1->(dbSkip())
					End
				EndIF

				//Se o componente veio de uma lista de componentes, valida se continua consistente
				If !Empty(oMdlGrd:GetValue("GG_LISTA"))
					//Valida os campos do componente com a lista
					aAdd(saListaCmp, {oMdlGrd:GetValue("GG_LISTA"), ;
					                  oMdlGrd:GetValue("GG_COMP") , ;
									  oMdlGrd:GetValue("GG_TRT")  , ;
									  cCargoPai                   , ;
									  ValCpoList(oMdlGrd, nInd)   , ;
									  oMdlGrd:GetLine()} )
				EndIf

				//Carrega o array aItem com as informa��es do componente
				CargaComp(aItem, oMdlGrd, nInd, lRecursiva, lExiste)

				//Grava a altera��o na Pr�-Estrutura
				GravAltPre(oModel)

				//Todos os n�veis
				If snNivel == 1
					//Muda o produto selecionado na tree e faz a chamada recursiva
					P135TrSeek(oMdlGrd:GetValue("CARGO"), , .T.)
					If !oMdlGrd:IsEmpty()
						lRet := CargaItens(aItem, oModel, .T., oMdlSelec:GetValue("CARGO"))
					EndIf
					P135TrSeek(cCargoAtu, , .T.)
				EndIf
			EndIf
		EndIf

		
		//Atualiza a barra de progresso quando estiver no produto PAI
		If !lRecursiva .and. !lAuto
			soProgrBar:Set(nInd)
		EndIf
	
	Next nInd

Return lRet

/*/{Protheus.doc} CargaComp
Carrega as informa��es do componente no array do ExecAuto
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem     , array  , array dos itens (ExecAuto)
@param 02 oMdlGrd   , object , modelo da grid dos componentes
@param 03 nLine     , numeric, indica a linha do componente
@param 04 lRecursiva, logic  , indica se � uma chamada recursiva da fun��o
@param 05 lAltera   , logic  , indica se � uma altera��o (se componente existe)
@return Nil
/*/
Static Function CargaComp(aItem, oMdlGrd, nLine, lRecursiva, lAltera)

	Local aFields := oMdlGrd:oFormModelStruct:aFields
	Local aGets   := {}
	Local cUsaAlt := "1"
	Local nIndCps := 1

	//Percorre todos os campos do componente da pr�-estrutura
	For nIndCps := 1 To Len(aFields)
		If !oMdlGrd:oFormModelStruct:GetProperty(aFields[nIndCps][3], MODEL_FIELD_VIRTUAL)
			If aFields[nIndCps][3] == "GG_COD" .And. !lRecursiva
				aAdd(aGets, { NomeNaSG1(aFields[nIndCps][3]), scNovoPai, NIL })
			ElseIf aFields[nIndCps][3] == "GG_FILIAL"
				aAdd(aGets, { NomeNaSG1(aFields[nIndCps][3]), xFilial("SG1"), NIL })
			Else
				aAdd(aGets, { NomeNaSG1(aFields[nIndCps][3]), oMdlGrd:GetValue(aFields[nIndCps][3], nLine), NIL })
			EndIf
		EndIf
	Next nIndCps

	If lAltera
		aAdd(aGets, {"LINPOS", "G1_COD+G1_COMP+G1_TRT", SG1->G1_COD, SG1->G1_COMP, SG1->G1_TRT})
	EndIf

	cUsaAlt := InitPad(GetSX3Cache("G1_USAALT","X3_RELACAO"))

	//Atribui conte�do default para o campo G1_USAALT
	aAdd(aGets, { "G1_USAALT", cUsaAlt, NIL })

	aAdd(aItem, aGets)

Return Nil

/*/{Protheus.doc} ValidParam
Valida o componente com os filtros informados no Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oMdlGrd, object, modelo da grid dos componentes
@return lRet, logic, indica se o componente deve ser utilizado na cria��o da estrutura
/*/
Static Function ValidParam(oMdlGrd)

	If !Empty(oMdlGrd:GetValue("GG_LISTA"))
		Return .T.
	EndIf

	//Considera Status
	Do Case
		//Aprovados
		Case snStatus == 1
			If oMdlGrd:GetValue("CSTATUS") <> "2"
				Return .F.
			EndIf

		//Rejeitados
		Case snStatus == 2
			If oMdlGrd:GetValue("CSTATUS") <> "3"
				Return .F.
			EndIf
	EndCase

	//Considera Componentes
	Do Case
		//Data v�lida
		Case snComps == 2
			If dDataBase < oMdlGrd:GetValue("GG_INI") .Or. dDataBase > oMdlGrd:GetValue("GG_FIM")
				Return .F.
			EndIf

		//V�lidos no per�odo
		Case snComps == 3
			If oMdlGrd:GetValue("GG_INI") > sdDataAte
				Return .F.
			EndIf

			If oMdlGrd:GetValue("GG_FIM") < sdDataDe
				Return .F.
			EndIf
	EndCase

Return .T.

/*/{Protheus.doc} NomeNaSG1
Converte o nome do campo entre SGG e SG1
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 cCampo, characters, campo a ser convertido
@return cCampo, characters, campo convertido - StrTran(cCampo, "GG_", "G1_")
/*/
Static Function NomeNaSG1(cCampo)

Return StrTran(cCampo, "GG_", "G1_")

/*/{Protheus.doc} GravAltPre
Altera o componente no modelo da pr�-estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal (pr�-estrutura)
@return Nil
/*/
Static Function GravAltPre(oModel)

	Local oMdlGrid  := oModel:GetModel("GRID_DETAIL")
	Local oMdlGrava := oModel:GetModel("GRAVA_SGG")
	Local aFields   := oMdlGrid:oFormModelStruct:aFields
	Local nIndCps   := 0
	Local cCampo    := ""

	If !oMdlGrava:IsEmpty()
		oMdlGrava:AddLine()
	EndIf

	//Inclui o componente no modelo de grava��o do PCPA135
	For nIndCps := 1 to Len(aFields)
		cCampo := AllTrim(aFields[nIndCps][3])
		oMdlGrava:LoadValue(cCampo, oMdlGrid:GetValue(cCampo))
	Next nIndCps

	oMdlGrava:LoadValue("LINHA", oMdlGrid:GetLine())

	//Mant�m pr�-estrutura
	If snPreEstr == 2
		oMdlGrava:LoadValue("CSTATUS", "4")
	Else
		oMdlGrava:LoadValue("DELETE", .T.)
	EndIf

Return Nil

/*/{Protheus.doc} DesfazAltP
Limpa o modelo de grava��o do PCPA135 para n�o alterar nenhuma informa��o
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal (pr�-estrutura)
@return Nil
/*/
Static Function DesfazAltP(oModel)

	Local oMdlGrava := oModel:GetModel("GRAVA_SGG")
	Local nInd      := 0

	FwModelActive(oModel)

	For nInd := 1 to oMdlGrava:Length()
		If oMdlGrava:IsDeleted(nInd)
			Loop
		EndIf

		oMdlGrava:GoLine(nInd)
		oMdlGrava:DeleteLine()
	Next nInd

Return Nil

/*/{Protheus.doc} ExcluiSG1
Carrega o array com os registros que dever�o ser exclu�dos
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem, array, array com os itens a serem enviados ao ExecAuto
@return Nil
/*/
Static Function ExcluiSG1(aItem)

	Local nInd  := 1

	//Sobrescreve
	If snJaExist == 1
		For nInd := 1 to Len(saRegExclu)
			If !Empty(saRegExclu[nInd][1])
				AddRegDel(aItem, nInd)
			EndIf
		Next nInd
	EndIf

Return Nil

/*/{Protheus.doc} AddRegDel
Adiciona no array aItem (ExecAuto) o componente que deve ser exclu�do
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem, array  , array com os itens a serem enviados ao ExecAuto
@param 02 nInd , numeric, posi��o do array saRegExclu com o registro a ser exclu�do
@return Nil
/*/
Static Function AddRegDel(aItem, nInd)

	Local aGets := {}

	aAdd(aGets, {"G1_COD"   , saRegExclu[nInd][1]    , NIL})
	aAdd(aGets, {"G1_COMP"  , saRegExclu[nInd][2]    , NIL})
	aAdd(aGets, {"G1_TRT"   , saRegExclu[nInd][3]    , NIL})
	aAdd(aGets, {"LINPOS"   , "G1_COD+G1_COMP+G1_TRT", saRegExclu[nInd][1], saRegExclu[nInd][2], saRegExclu[nInd][3]})
	aAdd(aGets, {"AUTDELETA", "S"                    , NIL})
	aAdd(aItem, aGets)

Return Nil

/*/{Protheus.doc} ExistNaRev
Verifica se o componente existe na revis�o atual da SB1
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lExiste, logic, indica que o componente existe na revis�o atual
/*/
Static Function ExistNaRev()

	Local cRevAtu := CriaVar('B1_REVATU')
	Local lExiste := .F.

	If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))
		cRevAtu := SB1->B1_REVATU
	EndIf

	If cRevAtu >= SG1->G1_REVINI .And. cRevAtu <= SG1->G1_REVFIM
		lExiste := .T.
	EndIf

Return lExiste

/*/{Protheus.doc} ValCpoList
Valida as informa��es do componente com as informa��es da lista
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oMdlGrd, object 	 , modelo da grid dos componentes
@param 02 nLine  , numeric	 , n�mero da linha referente ao componente
@return cAcao	 , characters, indica se o componente foi alterado ou removido da lista
							   "NIL" - componente est� ok
							   "UPD" - houve altera��o em algum campo da lista
							   "DEL" - componente foi removido da lista
/*/
Static Function ValCpoList(oMdlGrd, nLine)

	Local aFields  := oMdlGrd:oFormModelStruct:aFields
	Local nIndCps  := 1
	Local cCampoVG := ""
	Local cAcao	   := "NIL"

	//Se o par�metro de r�plica est� desativado, n�o valida a lista
	If sMvPCPRLEP <> 1
		Return "NIL"
	EndIf

	//Verifica se o componente existe na lista
	If SVG->(dbSeek(xFilial("SVG") + oMdlGrd:GetValue("GG_LISTA", nLine) + oMdlGrd:GetValue("GG_TRT", nLine) + oMdlGrd:GetValue("GG_COMP", nLine) ))
		//Percorre e compara todos os campos
		For nIndCps := 1 To Len(aFields)
			cCampoVG := ConvCampo(aFields[nIndCps][3])

			//Se for o campo Data Inicial ou Data Final, s� valida se estiver preenchido na lista
			IF cCampoVG $ "|VG_INI|VG_FIM|"
				If Empty(SVG->(&(cCampoVG)))
					Loop
				EndIf
			EndIf

			//Compara o campo
			If SVG->(FieldPos(cCampoVG)) > 0
				If SVG->(&(cCampoVG)) <> oMdlGrd:GetValue(aFields[nIndCps][3], nLine)
					cAcao := "UPD"
					Exit
				EndIf
			EndIf
		Next nIndCps
	Else
		cAcao := "DEL"
	EndIf

Return cAcao

/*/{Protheus.doc} ConvCampo
Converte o campo da SGG para SVG
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param cCampo , characters, campo a ser convertido
@return cCampo, characters, campo convertido
/*/
Static Function ConvCampo(cCampo)

	cCampo := AllTrim(cCampo)

	Do Case
		Case cCampo == "GG_LISTA"
			cCampo := "VG_COD"

		Case cCampo == "GG_COD"
			cCampo := "NAO_USADO"

		Otherwise
			cCampo := Strtran(cCampo,"GG_","VG_")
	EndCase

Return cCampo

/*/{Protheus.doc} ValidLista
Valida as listas de componentes utilizadas na pr�-estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal
@return nAcao, numeric, 1 = Cria a estrutura
						2 = Altera a pr�-estrutura
						3 = Mant�m no Wizard
/*/
Static Function ValidLista(oModel, lAuto)

	Local nIndLista  := 1
	Local cLisAnteri := ""
	Local lOk        := .T.
	Local nInd		 := 1
	Local oModelAuxG := Nil
	Local lPergunta  := .F.
	Local lAlteraSta := .F.
	Local nAcao		 := 1
	Local cPaiAnteri := ""
	Local cCargoAtu  := oModel:GetModel("FLD_SELECT"):GetValue("CARGO")

	Default lAuto := .F.

	//Se o par�metro de r�plica est� desativado, n�o valida a lista
	If sMvPCPRLEP <> 1
		Return 1
	EndIf

	//Ordena o array para poupar consultas no banco de dados
	aSort(saListaCmp, , , { | x,y | x[4] + x[1] + x[5] < y[4] + y[1] + y[5] } )

	SVG->(dbSetOrder(1))

	If aScan(saListaCmp, { |x| x[5] $ "UPD|DEL" }) > 0
		lPergunta := .T.
		//STR0046 - Informa��o
		//STR0219 - A lista de componentes utilizada na pr�-estrutura possui altera��es que n�o foram replicadas para esta pr�-estrutura.
		//STR0273 - Deseja voltar a pr�-estrutura para a situa��o em cria��o e corrigir conforme a lista de componentes?
		//STR0011 - Sim
		//STR0012 - Voltar
		If Aviso(STR0046, STR0219 + STR0273, {STR0011, STR0012}) == 1
			DesfazAltP(oModel)
		Else
			Return 3
		EndIf
	EndIf

	//Percorre o array carregado com as listas e componentes da pr�-estrutura atual
 	For nIndLista := 1 To Len(saListaCmp)
	 	oModelAuxG := oModel:GetModel("GRID_DETAIL")

		//Tratamento para consultar somente uma vez as listas
		If Empty(cLisAnteri)
			cLisAnteri := saListaCmp[1][1]
			cPaiAnteri := saListaCmp[1][4]
			P135TrSeek(saListaCmp[1][4], , .T.)
		Else
			If cLisAnteri == saListaCmp[nIndLista][1] .And. cPaiAnteri == saListaCmp[nIndLista][4] .And. saListaCmp[nIndLista][5] <> "UPD"
				Loop
			Else
				cLisAnteri := saListaCmp[nIndLista][1]
				cPaiAnteri := saListaCmp[nIndLista][4]
				P135TrSeek(saListaCmp[nIndLista][4], , .T.)
			EndIf
		EndIf

		If saListaCmp[nIndLista][5] == "DEL"
			oModelAuxG:GoLine(saListaCmp[nIndLista][6])
			oModelAuxG:DeleteLine()
			lAlteraSta := .T.
		EndIf

		//Verifica se a lista existe
		If SVG->(dbSeek(xFilial("SVG") + saListaCmp[nIndLista][1]))
			While !SVG->(Eof()) .And. ;
				SVG->VG_FILIAL == xFilial("SVG") .And. ;
				SVG->VG_COD    == saListaCmp[nIndLista][1]

				If oModelAuxG:SeekLine({ {"GG_COMP", SVG->VG_COMP} , {"GG_TRT", SVG->VG_TRT} , {"GG_LISTA", SVG->VG_COD} } , .F., .T.)
					If saListaCmp[nIndLista][5] == "NIL"
						SVG->(dbSkip())
						Loop
					EndIf
				Else
					//STR0046 - Informa��o
					//STR0219 - A lista de componentes utilizada na pr�-estrutura possui altera��es que n�o foram replicadas para esta pr�-estrutura.
					//STR0273 - Deseja voltar a pr�-estrutura para a situa��o em cria��o e corrigir conforme a lista de componentes?
					//STR0011 - Sim
					//STR0012 - Voltar
					If !lPergunta
						lPergunta := .T.
						If Aviso(STR0046, STR0219 + STR0273, {STR0011, STR0012}) == 1
							DesfazAltP(oModel)
						Else
							lOk := .F.
							Exit
						EndIf
					EndIf

					If lOk
						oModelAuxG:AddLine()
					EndIf
				EndIf

				lAlteraSta := .T.

				//Valida a atribui��o dos valores dos campos principais
				If !oModelAuxG:SetValue("GG_COMP",SVG->VG_COMP)
					lOk := .F.
					Exit
				EndIf

				If !oModelAuxG:SetValue("GG_TRT",SVG->VG_TRT)
					lOk := .F.
					Exit
				EndIf

				If !oModelAuxG:SetValue("GG_QUANT",SVG->VG_QUANT)
					lOk := .F.
					Exit
				EndIf

				If !Empty(SVG->VG_INI)
					oModelAuxG:SetValue("GG_INI",SVG->VG_INI)
				EndIf

				If !Empty(SVG->VG_FIM)
					oModelAuxG:SetValue("GG_FIM",SVG->VG_FIM)
				EndIf

				oModelAuxG:SetValue("GG_FIXVAR"  , SVG->VG_FIXVAR)
				oModelAuxG:SetValue("GG_GROPC"   , SVG->VG_GROPC)
				oModelAuxG:SetValue("GG_OPC"     , SVG->VG_OPC)
				oModelAuxG:SetValue("GG_POTENCI" , SVG->VG_POTENCI)
				oModelAuxG:SetValue("GG_TIPVEC"  , SVG->VG_TIPVEC)
				oModelAuxG:SetValue("GG_VECTOR"  , SVG->VG_VECTOR)
				oModelAuxG:SetValue("GG_LISTA"   , SVG->VG_COD)
				oModelAuxG:SetValue("GG_LOCCONS" , SVG->VG_LOCCONS)
				oModelAuxG:LoadValue("CSTATUS","1")

				SVG->(dbSkip())
			End
		Else
			lOk := .F.
			Help( ,  , "Help", ,  STR0221, 1, 0, , , , , ,     ; //"A lista de componentes utilizada na pr�-estrutura n�o existe."
				{STR0220 + AllTrim(saListaCmp[nIndLista][1])} ) //"Revise os componentes da lista: "
			nAcao := 3
			Exit
		EndIf
		If lAlteraSta
			//Se houver diverg�ncias, percorre todos os itens da grid e alterar o status pra 1
			For nInd := 1 to oModelAuxG:Length()
				If oModelAuxG:GetValue("CSTATUS", nInd) <> "1"
					oModelAuxG:GoLine(nInd)
					oModelAuxG:LoadValue("CSTATUS","1")
				EndIf
			Next
			lAlteraSta := .F.
			nAcao := 2
		EndIf

		If !lOk
			nAcao := 3
			Exit
		EndIf

	Next nIndLista

	If !lAuto
		P135TrSeek(cCargoAtu, , .T.)
	Else
		P135TreeCh(.T., cCargoAtu)
	EndIf

Return nAcao
