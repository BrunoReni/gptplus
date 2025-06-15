#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA134.CH"
#INCLUDE "FWEDITPANEL.CH"
//#DEFINE CLRF         CHR(13)+CHR(10)

Static scUltCodD  := ""
Static oDbTree
Static oView
Static oViewExec
Static saAnterior := {}
Static saDbTree
Static slConfPesq := .F.
Static slRefresh  := .F.

/*/{Protheus.doc} Pesquisa
Abre tela de pesquisa
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oViewPai , object, objeto da View Principal
@param 02 aDbTree  , array , array dbtree do fonte PCPA134
@param 03 oDbTreeX , object, objeto dbtree do fonte PCPA134
@param 04 lRefresh , l�gico, for�a refresh na pesquisa
@param 05 lOpenView, l�gico, indica se deve abrir a view de pesquisa
@return .T.
/*/
Function PCPA134Pes(oViewPai, aDbTree, oDbTreeX, lRefresh, lOpenView)

	Local oModel		:= oViewPai:GetModel()
	Local oModelCab     := oModel:GetModel("FLD_PESQUISA")
	Local lPrevia       := oModelCab:GetValue("lPrevia")
	Local cCodigo       := Alltrim(oModelCab:GetValue("cCodigo"))
	Local cDescricao    := Alltrim(oModelCab:GetValue("cDescricao"))
	Local lCancelar 	:= .F.
	Local lChgPrevia    := .F.

	Default lRefresh    := .F.
	Default lOpenView   := .T.
	slRefresh := @lRefresh

	//Prote��o para execu��o com View ativa.
	If oViewPai != Nil .And. oViewPai:isActive()

		//Carrega variaveis estaticas
		oView 		:= Nil
		oViewExec 	:= FWViewExec():New()
		saDbTree    := @aDbTree
		oDbTree     := oDbTreeX

		//Ajusta opera��o do modelo e view anteriores (PCPA134) para Inclus�o para que os Get's da
		//pesquisa funcionem adequadamente
		oViewPai:SetOperation(OP_INCLUIR)
		oViewPai:oModel:nOperation := MODEL_OPERATION_INSERT

		oView := ViewDef(oViewPai)
		If lPrevia
			oView:AddUserButton(STR0041,"",{|| lChgPrevia := .T., oView:CloseOwner() }, STR0041,,,.T.) //"Ocultar Pr�via"
		Else
			oView:AddUserButton(STR0042,"",{|| lChgPrevia := .T., oView:CloseOwner() }, STR0042,,,.T.) //"Ver Pr�via"
		EndIf
		oView:AddUserButton(STR0044 + " " + STR0057,"",{|| Posiciona(oViewPai, .T., .F.) }, STR0044,,,.T.) //Anterior [F6]
		oView:AddUserButton(STR0045 + " " + STR0058,"",{|| Posiciona(oViewPai, .F., .T.) }, STR0045,,,.T.) //Pr�ximo [F7]
		oView:AddUserButton(STR0043 /*+ " " + STR0056*/,"",{|| slConfPesq := .F., lCancelar := .T., oView:CloseOwner() }, STR0043,,,.T.) //Fechar [ESC]

		//Determina teclas de atalho
	 	SetKey( VK_F5, { || oView:CloseOwner(), slConfPesq := .T., Posiciona(oViewPai, .F., .F.), FwViewActive(oViewPai) } )
		SetKey( VK_F6, { || oView:CloseOwner(), slConfPesq := .T., Posiciona(oViewPai, .T., .F.), FwViewActive(oViewPai) } )
		SetKey( VK_F7, { || oView:CloseOwner(), slConfPesq := .T., Posiciona(oViewPai, .F., .F.), FwViewActive(oViewPai) } )

		//Prepara ViewExec para abertura da tela
		oViewExec:setModel(oModel)
	  	oViewExec:setView(oView)
	  	oViewExec:setTitle(STR0040) //Pesquisa
	  	oViewExec:setOperation(MODEL_OPERATION_INSERT)
	  	If lPrevia
			oViewExec:setReduction(65)
		Else
			oViewExec:setSize(76, 385)
		EndIf
	  	oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0046 + " " + STR0059},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //Posicionar e Fechar [F5]
	  	oViewExec:SetCloseOnOk({|o| Posiciona(oViewPai, .F., .F.) })
	  	oViewExec:SetModal(.T.)

		//Abre a tela
		If lOpenView
	  		oViewExec:openView(.F.)
		Else
			If !Empty(cCodigo)
				//Limpa pesquisa
				oModelCab:SetValue("cCodigo", "")
				//Reaplica a pesquisa
				oModelCab:SetValue("cCodigo", cCodigo)
			EndIf
			If !Empty(cDescricao)
				oModelCab:SetValue("cDescricao", "")
				oModelCab:SetValue("cDescricao", cDescricao)
			EndIf
		EndIf

		//Tratativas de fechamento de tela
		If lCancelar .Or. !slConfPesq .OR. lChgPrevia
		  	CancPesq(oView, oViewPai, oViewExec)

	  	Else
	    	slConfPesq := .F.
	  		CancPesq(oView, oViewPai, oViewExec)
	  	Endif

		//Oculta ou exibe a grid
		If lChgPrevia
			ChgPrevia(oViewPai, oModelCab)
		EndIf

	EndIf

	//Retorna opera��o do modelo e view anteriores (PCPA134) para visualiza��o
	oViewPai:SetOperation(OP_VISUALIZAR)
	oViewPai:oModel:nOperation := MODEL_OPERATION_VIEW

Return .T.

/*/{Protheus.doc} CancPesq()
Cancela pesquisa
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oView    , object, objeto da View
@param 02 oViewPai , object, objeto da View Principal
@param 03 oViewExec, object, objeto da ExecView
@return .F.
/*/
Static Function CancPesq(oView, oViewPai, oViewExec)
	If oView:IsActive()
		oViewExec:DeActivate()
		oView:DeActivate()
		oView:Destroy()
	EndIf
	SetKey( VK_F5, { ||  } )
	SetKey( VK_F6, { ||  } )
	SetKey( VK_F7, { ||  } )
 Return .F.

 /*/{Protheus.doc} ChgPrevia()
Oculta ou Exibe a grid de pr�via dos resultados da pesquisa
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oViewPai , object, objeto da View Principal
@param 02 oModelCab, object, objeto modelo do cabe�alho
/*/
Static Function ChgPrevia(oViewPai, oModelCab)
	oModelCab:SetValue("lPrevia", !oModelCab:GetValue("lPrevia"))
	FwViewActive(oViewPai)
	PCPA134Pes(oViewPai, saDbTree, oDbTree)
Return

/*/{Protheus.doc} Posiciona()
Posiciona o registro - Chamada barra de processamento
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oViewPai , object, objeto da View Principal
@param 02 lAnterior, l�gico, indica se deve posicionar no registro anterior
@param 03 lProximo , l�gico, indica se deve posicionar no pr�ximo registro
@param 04 lRefresh , l�gico, indica se deve for�ar o refresh da pesquisa
@return .T.
/*/
Static Function Posiciona(oViewPai, lAnterior, lProximo, lRefresh)
	Local lAbort := .F.
	Processa({|| PosicionaX(oViewPai, lAnterior, lProximo, lRefresh)}, STR0062, STR0066, lAbort) //"Aguarde..." - "Posicionando..."
Return .T.

/*/{Protheus.doc} PosicionaX()
Posiciona o registro
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oViewPai , object, objeto da View Principal
@param 02 lAnterior, l�gico, indica se deve posicionar no registro anterior
@param 03 lProximo , l�gico, indica se deve posicionar no pr�ximo registro
@param 04 lRefresh , l�gico, indica se deve for�ar o refresh da pesquisa
@return .T.
/*/
Static Function PosicionaX(oViewPai, lAnterior, lProximo, lRefresh)

	Local cCaminho
	Local cChvAnteO   := ""
	Local nTamChv     := 0
	Local nTamCod     := GetSx3Cache("B1_COD","X3_TAMANHO")
	Local oModel      := oViewPai:GetModel()
	Local oGridPesq   := oModel:GetModel("GRID_RESULTS")
	Local oModelCab   := oModel:GetModel("FLD_PESQUISA")
	Local cProdAlvo   := Alltrim(oModelCab:GetValue("cCodigo"))
	Local cDescricao  := Alltrim(oModelCab:GetValue("cDescricao"))
	Local lPrevia     := oModelCab:GetValue("lPrevia")
	Local nLine       := oGridPesq:GetLine()

	Default lAnterior := .F.
	Default lProximo  := .F.
	Default lRefresh  := .F.

	//Seta regua infinita
	ProcRegua(0)

	If lRefresh
		aSize(saAnterior,0)
		lAnterior := .F.
		lProximo  := .F.
		//Refaz pesquisa quando necess�rio
		PCPA134Pes(oViewPai, saDbTree, oDbTree, lRefresh, .F.)
	EndIf

	//Posicionamento por c�digo do produto
	If !Empty(cProdAlvo)
		cCaminho  := AllTrim(oGridPesq:GetValue("cCaminho")) + "   "
		nTamChv   := At(cProdAlvo, cCaminho)+Len(AllTrim(cProdAlvo))+2
		cChvAnteO := Left(cCaminho, nTamChv)

		//Posiciona no alvo anterior
		If lAnterior
			If nLine > 1
				oGridPesq:GoLine(nLine - 1)
			Else
				oGridPesq:GoLine(oGridPesq:Length(.F.))
			EndIf
			While nLine != oGridPesq:GetLine()
				//Processa a Regua
				IncProc()
				If cChvAnteO != Left(oGridPesq:GetValue("cCaminho"), nTamChv);
					.OR. (nTamChv == 0 .AND. AllTrim(Left(oGridPesq:GetValue("cCaminho"), nTamCod)) != cProdAlvo)
					Exit
				EndIf
				If oGridPesq:GetLine() > 1
					oGridPesq:GoLine(oGridPesq:GetLine() - 1)
				Else
					oGridPesq:GoLine(oGridPesq:Length(.F.))
				EndIf
			EndDo

		//Posiciona no pr�ximo alvo
		ElseIf lProximo
			If nLine < oGridPesq:Length(.F.)
				oGridPesq:GoLine(nLine + 1)
			Else
				oGridPesq:GoLine(1)
			EndIf
			While nLine != oGridPesq:GetLine()
				//Processa a Regua
				IncProc()
				If cChvAnteO != Left(oGridPesq:GetValue("cCaminho"), nTamChv);
					.OR. (nTamChv == 0 .AND. AllTrim(Left(oGridPesq:GetValue("cCaminho"), nTamCod)) != cProdAlvo)
					Exit
				EndIf
				If oGridPesq:GetLine() < oGridPesq:Length(.F.)
					oGridPesq:GoLine(oGridPesq:GetLine() + 1)
				Else
					oGridPesq:GoLine(1)
				EndIf
			EndDo
		EndIf
	EndIf

	//Posiciona por DESCRI��O - CONT�M
	If !Empty(cDescricao) .AND. Empty(cProdAlvo)
		cProdAlvo := GetAlvo(lAnterior, lProximo, .T., oViewPai)
	EndIf

	//Posiciona na Tree
	If !Empty(cProdAlvo) .OR. !(lAnterior .OR. lProximo)
		FwViewActive(oViewPai)	//Determina oViewPai como ativa atual

		TreeSeek(cProdAlvo, "", oGridPesq:GetValue("cCaminho"))
	EndIf

	If oView != Nil .AND. oView:IsActive()
		If lPrevia
			//Determina oView como ativa atual
			FwViewActive(oView)
		Else
			//Fecha oView atual
			oView:CloseOwner()
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} TreeSeek()
Posiciona o registro na Tree
@author brunno.costa
@since 18/01/2019
@version 1.0
@param 01 cProduto , caracter, c�digo do produto alvo do posicionamento
@param 02 cCargoPai, caracter, cargo do produto Pai
@param 03 cCaminho , caracter, chave do caminho do produto
@return cCargo, caracter, cargo do item posicionado na Tree
/*/
Static Function TreeSeek(cProduto, cCargoPai, cCaminho)

	Local cCargo      := ""
	Local aCaminho    := {}
	Local nNivAtu     := 0
	Local nTamCod     := GetSx3Cache("B1_COD","X3_TAMANHO")

	Default cCargoPai := ""
	Default cCaminho  := ""

	aCaminho := Strtokarr2( cCaminho, STR0047, .F.)//" -> "

	For nNivAtu := 1 to Len(aCaminho)
		//Posiciona na Tree
		nScan     := aScan(saDbTree, {|x|;
					AllTrim(Left(x[1],nTamCod)) == AllTrim(aCaminho[nNivAtu]);
					.AND. Iif(Empty(cCargoPai), Empty(x[2]),;
							Left(x[2],Len(cCargoPai)-4) == Left(cCargoPai,Len(cCargoPai)-4)) })
		If nScan > 0
			cCargo := saDbTree[nScan][1]
			If cCargo != oDbTree:GetCargo()
				oDbTree:TreeSeek(cCargo)
				StaticCall(PCPA134, AcaoTreeCh)
			EndIf
			cCargoPai := saDbTree[nScan][1]
		EndIf

		//Posiciona no produto pesquisado
		//Sai do for quando encontrar o produto
		If !Empty(cProduto)
			If AllTrim(cProduto) == AllTrim(aCaminho[nNivAtu])
				Exit
			EndIf
		Else
			Exit
		EndIf
	Next nNivAtu

Return cCargo

/*/{Protheus.doc} GetAlvo()
Retorna o c�digo do produto algo (pr�ximo-anterior) e posiciona na oGridPesq correspondnete
@author brunno.costa
@since 18/01/2019
@version 1.0
@param 01 lAnterior , l�gico  , indica se o alvo � anterior
@param 02 lProximo  , l�gico  , indica se o alvo � posterior
@param 03 lReinicia , l�gico  , indica se permite realizar loop no posisionamento oGridPesq
@param 04 oViewPai  , objeto  , objeto da view pai
@param 05 cChvAnteO , caracter, chave anterior do registro posicionado
@return cProdAlvo   , caracter, c�digo do produto alvo
/*/
Static Function GetAlvo(lAnterior, lProximo, lReinicia, oViewPai, cChvAnteO)

	Local aDescricao  := {}
	Local cProdAlvo   := ""
	Local oModel      := oViewPai:GetModel()
	Local oGridPesq   := oModel:GetModel("GRID_RESULTS")
	Local nLine       := oGridPesq:GetLine()
	Local nLineD      := oGridPesq:GetLine()
	Local nScan       := 0
	Local lReiniciou  := .F.
	Local nIndAux1    := 0
	Local nIndAux2    := 0
	Local cBkpChvAnt  := ""
	Local cChvAnte    := ""
	Local cChvPoste   := ""
	Local cChvPosteO  := ""
	Local nTamCod     := GetSx3Cache("B1_COD", "X3_TAMANHO")
	Local cPathD      := ""
	Local cBkUltCodD
	Default lReinicia := .T.

	//Grava em cChvAnteO o posicionamento atual da Tree
	Default cChvAnteO := AjsCaminho(GetCaminho(AllTrim(oDbTree:GetCargo())))

	//Identifica o ALVO ANTERIOR - Com base na regra do Pr�ximo Alvo
	If  lAnterior
		cBkpChvAnt := cChvAnteO
		//Monta Array saAnterior
		If Len(saAnterior) < oGridPesq:Length(.F.) //Empty(saAnterior)
			nScan := aScan(saAnterior, {|x| CompChave(cBkpChvAnt, x[2], ">", nil, .T.);
					.AND. CompChave(cBkpChvAnt, x[6], "<=", nil, .T.)})
			If  nScan == 0
				//Loop entre todas as linhas de caminhos existentes
				For nIndAux1 := oGridPesq:Length(.F.) to 1 Step -1
					oGridPesq:GoLine(nIndAux1)

					//Retorna caminho contendo apenas c�digos de produtos com descri��o v�lida
					cPathD     := AjsCaminho(oGridPesq:GetValue("cCaminhoD"))
					aSize(aDescricao, 0)
					aDescricao := Strtokarr2( cPathD, '|', .F.)

					//Loop entre Seek's internos - Mesmo Caminho
					For nIndAux2 := 1 to Len(aDescricao)
						oGridPesq:GoLine(nIndAux1)
						scUltCodD   := PadR(aDescricao[nIndAux2],nTamCod)
						cChvAnteO   := AjsCaminho(oGridPesq:GetValue("cCaminho"))
						cChvAnte    := StrTran(Left(cChvAnteO, At('|'+scUltCodD+'|', cChvAnteO) + Len('|'+scUltCodD+'|') - 1) + '|', '||','|')
						nLine1      := oGridPesq:GetLine()
						cProdAlvo   := PadR(GetAlvo(.F., .T., .T., oViewPai, cChvAnte),nTamCod)
						cChvPosteO  := AjsCaminho(oGridPesq:GetValue("cCaminho"))
						cChvPoste   := StrTran(Left(cChvPosteO, At('|'+cProdAlvo+'|', cChvPosteO) + Len('|'+cProdAlvo+'|') - 1) + '|', '||','|')

						nScan := aScan(saAnterior, {|x|   CompChave(AjsCaminho(cChvPoste, .T.), x[6], "==", nil, .T.);
													.AND. CompChave(AjsCaminho(cChvAnte, .T.), x[2], "==", nil, .T.)})
						If nScan == 0
							aAdd(saAnterior, {PadR(aDescricao[nIndAux2],nTamCod),;  //1 - Produto anterior
											AjsCaminho(cChvAnte, .T.),;		        //2 - Chave anterior
											cChvAnteO,;						        //3 - Chave original anterior
											nLine1,;						        //4 - Linha anterior
											cProdAlvo,;						        //5 - Produto posterior
											AjsCaminho(cChvPoste, .T.),;	        //6 - Chave posterior
											cChvPosteO,;					        //7 - Chave original posterior
											oGridPesq:GetLine()})			        //8 - Linha posterior
						Else
							nScan := 0
						EndIf

						If nScan == 0
							nScan := aScan(saAnterior, {|x|   CompChave(cBkpChvAnt, x[2], ">", nil, .T.);
														.AND. CompChave(cBkpChvAnt, x[6], "<=", nil, .T.)})
						EndIf
					Next nIndAux2
					If nScan > 0
						Exit
					EndIf
				Next nIndAux1
				cChvAnteO  := cBkpChvAnt
				saAnterior := aSort(saAnterior,,, {|x,y| x[6]+x[2] < y[6]+y[2] })
			EndIf
		Endif

		//Verifica qual a maior chave existente no array saAnterior igual ou anterior ao registro posiconado na Tree
		nIndAux1 := 0
		For nIndAux2 := 1 to Len(saAnterior)
			If CompChave(saAnterior[nIndAux2][6], cChvAnteO, "<=", nil, .T.)
				If nIndAux1 > 0
					If CompChave(saAnterior[nIndAux2][6], saAnterior[nIndAux1][6], ">=", nil, .T.);
						.AND. CompChave(saAnterior[nIndAux2][6], saAnterior[nIndAux1][6], ">=", nil, .T.)
						nIndAux1 := nIndAux2
					EndIf
				Else
					nIndAux1 := nIndAux2
				EndIf
			EndIf
		Next nIndAux2
		nIndAux2 := nIndAux1

		//Identifica o c�digo do produto alvo anterior e posiciona na linha da grid oGridPesq
		While nIndAux2 > 0
			If CompChave(saAnterior[nIndAux2][6], cChvAnteO, "==", NIL, .T.)
				oGridPesq:GoLine(saAnterior[nIndAux2][4])
				cProdAlvo := saAnterior[nIndAux2][1]
				Exit
			ElseIf CompChave(saAnterior[nIndAux2][6], cChvAnteO, "<", NIL, .T.)
				oGridPesq:GoLine(saAnterior[nIndAux2][8])
				cProdAlvo := saAnterior[nIndAux2][5]
				Exit
			EndIf
		EndDo
	Endif

	If !lAnterior .AND. Empty(cProdAlvo)
		cBkUltCodD  := PadR(RetPrdCarg(oDbTree:GetCargo(), .F.),nTamCod)
		If !('|'+PadR(cBkUltCodD,nTamCod)+'|' $ AjsCaminho(oGridPesq:GetValue("cCaminhoD")))
			cBkUltCodD  := ""
		Else
			cChvAnte    := StrTran(Left(cChvAnteO, At('|'+cBkUltCodD+'|', cChvAnteO) + Len('|'+cBkUltCodD+'|') - 1) + '|', '||','|')
			nLine1      := oGridPesq:GetLine()
		EndIf

		//Defini��o de in�cio da pesquisa na Grid de resultados lAnterior
		If (oView == Nil .OR. !oView:IsActive())
			scUltCodD := ""
			nLine    := 1
			nLineD   := 1
			oGridPesq:GoLine(nLineD)
		Else
			cBkUltCodD  := ""
		EndIf
	Endif

	//Identifica o PR�XIMO ALVO
	While !lAnterior .and. Empty(cProdAlvo)
		//Retorna caminho contendo apenas c�digos de produtos com descri��o v�lida
		cPathD     := AjsCaminho(oGridPesq:GetValue("cCaminhoD"))
		aDescricao := Strtokarr2( cPathD, '|', .F.)

		//no MESMO CAMINHO
		For nIndAux1 := 1 to Len(aDescricao)
			If AllTrim(scUltCodD) == AllTrim(aDescricao[nIndAux1])
				scUltCodD := cProdAlvo
				Exit
			Else
				cCaminho  := AjsCaminho(oGridPesq:GetValue("cCaminho"))
				If lProximo .AND. CompChave(cCaminho, cChvAnteO, "<=", PadR(aDescricao[nIndAux1],nTamCod)) .AND. !lReiniciou
					Loop
				EndIf
				cProdAlvo  := PadR(AllTrim(aDescricao[nIndAux1]),nTamCod)
				scUltCodD  := cProdAlvo
				Exit
			EndIf
		Next nIndAux1

		//no pr�ximo CAMINHO
		If Empty(cProdAlvo)
			If nLine < oGridPesq:Length(.F.)
				oGridPesq:GoLine(nLine + 1)
				nLine++

			ElseIf lReinicia
				lReinicia  := .F.
				lReiniciou := .T.
				nLine      := 1
				oGridPesq:GoLine(nLine)
				cChvAnteO := ""
				nLineD := oGridPesq:Length(.F.)

			Else
				Exit
			EndIf
		EndIf
		If Empty(cProdAlvo)
			scUltCodD := ""
		EndIf
	EndDo

	If !lAnterior .AND. !Empty(cProdAlvo) .AND. !Empty(cBkUltCodD)
		//cProdAlvo   := PadR(GetAlvo(.F., .T., .T., oViewPai, cChvAnte),nTamCod)
		cChvPosteO  := AjsCaminho(oGridPesq:GetValue("cCaminho"))
		cChvPoste   := StrTran(Left(cChvPosteO, At('|'+cProdAlvo+'|', cChvPosteO) + Len('|'+cProdAlvo+'|') - 1) + '|', '||','|')

		nScan := aScan(saAnterior, {|x|   CompChave(AjsCaminho(cChvPoste, .T.), x[6], "==", nil, .T.);
									.AND. CompChave(AjsCaminho(cChvAnte, .T.), x[2], "==", nil, .T.)})
		If nScan == 0
			aAdd(saAnterior, {cBkUltCodD,;           		//1 - Produto anterior
							AjsCaminho(cChvAnte, .T.),;		//2 - Chave anterior
							cChvAnteO,;						//3 - Chave original anterior
							nLine1,;						//4 - Linha anterior
							cProdAlvo,;						//5 - Produto posterior
							AjsCaminho(cChvPoste, .T.),;	//6 - Chave posterior
							cChvPosteO,;					//7 - Chave original posterior
							oGridPesq:GetLine()})			//8 - Linha posterior
			saAnterior := aSort(saAnterior,,, {|x,y| x[6]+x[2] < y[6]+y[2] })
		EndIf
	EndIf

Return cProdAlvo

/*/{Protheus.doc} GetCaminho
Retorna a string do caminho de um cCargo espec�fico
@author brunno.costa
@since 18/01/2019
@version P12
@param cCargo  , characters, cargo relacionado
@return componente, caracters, c�digo do produto relacionado ao cCargo
@type Function
/*/
Static Function GetCaminho(cCargo)
	Local cCaminho := ""
	Local cProdAux := RetPrdCarg(cCargo, .F.)
	Local nScan    := 1

	cCaminho := RetPrdCarg(cCargo, .F.)
	nScan    := aScan(saDbTree, {|x| x[1] = cCargo })
	While nScan > 0
		cProdAux := RetPrdCarg(cCargo, .T.)
		If !Empty(cProdAux)// .AND. !(cProdAux $ cCaminho)
			cCaminho := cProdAux + STR0047 + cCaminho //" -> "
		EndIf
		cCargo := saDbTree[nScan][2]
		nScan  := aScan(saDbTree, {|x| x[1] = cCargo })
	EndDo
Return cCaminho

/*/{Protheus.doc} AjsCaminho()
Retorna o c�digo do produto algo (pr�ximo-anterior) e posiciona na oGridPesq correspondnete
@author brunno.costa
@since 18/01/2019
@version 1.0
@param 01 cCaminho , caracter, transforma o caminho (->) na chave de pesquisa e compara��o (|)
@param 02 lEspacos , l�gico  , indica se padroniza o espa�amento pelo tamanho do produto (B1_COD)
@return cReturn    , caracter, string chave de pesquisa e compara��o
/*/
Static Function AjsCaminho(cCaminho, lEspacos)
	Local cReturn    := '|'+StrTran(AllTrim(StrTran(cCaminho,STR0047, '|')),' ', '|')+'|'//" -> "
	Local aAuxiliar
	Local nIndAux
	Local nTamCod
	Default lEspacos := .T.
	If lEspacos
		nTamCod     := GetSx3Cache("B1_COD", "X3_TAMANHO")
		aAuxiliar   := Strtokarr2( cReturn, '|', .F.)
		For nIndAux := 1 to Len(aAuxiliar)
			aAuxiliar[nIndAux] := PadR(aAuxiliar[nIndAux], nTamCod)
		Next nIndAux
		cReturn := '|'+ArrTokStr(aAuxiliar,"|", 0)+'|'
	EndIf
Return cReturn

/*/{Protheus.doc} CompChave()
Retorna o c�digo do produto algo (pr�ximo-anterior) e posiciona na oGridPesq correspondnete
@author brunno.costa
@since 18/01/2019
@version 1.0
@param 01 cAnterior , caracter, string de chave anterior para compara��o
@param 02 cPosterior, caracter, string de chave posterior para compara��o
@param 03 cOperacao , caracter, opera��o de compara��o
@param 04 cProduto  , caracter, c�digo do produto alvo, caso necess�rio cortar a string
@param 05 lAnterior , l�gico  , indica se � compara��o em opera��o lAnterior
@param 06 lRefaz    , l�gico  , indica se deve refazer as strings de compara��o com espa�amento padr�o B1_COD
@return cReturn     , l�gico  , resultado l�gico da compara��o
/*/
Static Function CompChave(cAnterior, cPosterior, cOperacao, cProduto, lAnterior, lRefaz)
	Local saAnterior := Strtokarr2( cAnterior, '|', .F.)
	Local aPosterior := Strtokarr2( cPosterior, '|', .F.)
	Local nIndAux    := 0
	Local nTamCod    := GetSx3Cache("B1_COD", "X3_TAMANHO")
	Local lResult    := .F.
	Local nLargura

	Default lRefaz := .F.

	cProduto := PadR(cProduto, nTamCod)

	If lRefaz
		For nIndAux := 1 to Len(saAnterior)
			saAnterior[nIndAux] := PadR(saAnterior[nIndAux], nTamCod)
		Next nIndAux

		For nIndAux := 1 to Len(aPosterior)
			aPosterior[nIndAux] := PadR(aPosterior[nIndAux], nTamCod)
		Next nIndAux

		cAnterior  := '|'+ArrTokStr(saAnterior,"|", 0)+'|'
		cPosterior := '|'+ArrTokStr(aPosterior,"|", 0)+'|'
	EndIf

	If !lAnterior
		If Empty(cProduto)
			nLargura := Len(cAnterior)
		Else
			nLargura   := At('|'+cProduto+'|', cAnterior)+Len(cProduto)
		EndIf
	Else
		nLargura := Len(cAnterior)
		If Len(cPosterior) > nLargura
			nLargura := Len(cPosterior)
		EndIf
	EndIf
	lResult := &("PadR(cAnterior,nLargura)" + cOperacao + "PadR(cPosterior,nLargura)")
Return lResult

/*/{Protheus.doc} RetPrdCarg
Retorna o c�digo do produto selecionado referente o cargo
@author brunno.costa
@since 18/01/2019
@version P12
@param cCargo  , characters, cargo relacionado
@param lProdPai, l�gico    , indica se deve retornar o c�digo do produto pai ou filho
@return x      , caracters , c�digo do produto relacionado ao cCargo
@type Function
/*/
Static Function RetPrdCarg(cCargo, lProdPai)
Return AllTrim(StaticCall(PCPA134, RetPrdCarg, cCargo, lProdPai))

/*/{Protheus.doc} ModelDef
Defini��o do Modelo
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oModel, object  , objeto modelo da tela principal
@param 02 cOwner, caracter, nome do field master/owner
@return oModel
/*/
Static Function ModelDef(oModel, cOwner)

	Local oStruCab := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local oStruRes := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})

	Default oModel   := MPFormModel():New('PCPA134Pes')

	//Altera os campos da estrutura
	AltStruMod(@oStruCab, @oStruRes)

	//FLD_PESQUISA - Modelo do cabe�alho
	oModel:AddFields("FLD_PESQUISA", cOwner, oStruCab)
	oModel:GetModel("FLD_PESQUISA"):SetDescription(STR0040) //Pesquisa
	oModel:GetModel("FLD_PESQUISA"):SetOnlyQuery(.T.)

	//GRID_RESULTS - Grid de resultados
	oModel:AddGrid("GRID_RESULTS", "FLD_PESQUISA", oStruRes)
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0048) //Resultados
	oModel:GetModel("GRID_RESULTS"):SetOnlyQuery(.T.)
	oModel:SetOptional("GRID_RESULTS", .T.)

	oModel:SetDescription(STR0040) //Pesquisa
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Defini��o da View
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oViewOwner, object  , objeto view da tela principal
@return oView
/*/
Static Function ViewDef(oViewOwner)

	Local oView
	Local oModel    := oViewOwner:GetModel()
	Local oModelCab := oModel:GetModel("FLD_PESQUISA")
	Local oStruCab  := FWFormStruct(2, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local oStruRes  := FWFormStruct(2, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local lPrevia   := oModelCab:GetValue("lPrevia")

	Default oViewOwner := NIL

	oView    := FWFormView():New(oViewOwner)

	//Altera os campos da estrutura para a view
	AltStrView(@oStruCab, @oStruRes)

	oView:SetModel(FWLoadModel("PCPA134Pes"))

	If lPrevia
		//V_FLD_PESQUISA - View do Cabe�alho
		oView:AddField("V_FLD_PESQUISA", oStruCab, "FLD_PESQUISA")
		oView:SetViewProperty("V_FLD_PESQUISA", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 3 })

		//V_GRID_RESULTS - View da Grid de Resultados
		oView:AddGrid("V_GRID_RESULTS"   , oStruRes ,"GRID_RESULTS")

		//Divis�o da tela
		oView:CreateHorizontalBox("BOX_HEADER", 74, , .T.)
		oView:CreateHorizontalBox("BOX_GRID"  , 100)

		//Relaciona a SubView com o Box
		oView:SetOwnerView("V_FLD_PESQUISA", 'BOX_HEADER')
		oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

		//Atribui posicionamento com Duplo Clique na GRID
		oView:SetViewProperty("V_GRID_RESULTS", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| oView:CloseOwner(), Posiciona(oViewOwner, .F., .F.) }})

	Else

		//V_FLD_PESQUISA - View do Cabe�alho
		oView:AddField("V_FLD_PESQUISA", oStruCab, "FLD_PESQUISA")
		oView:SetViewProperty("V_FLD_PESQUISA", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 2 })

		//Divis�o da tela
		oView:CreateHorizontalBox("BOX_HEADER", 74, , .T.)

		//Relaciona a SubView com o Box
		oView:SetOwnerView("V_FLD_PESQUISA", 'BOX_HEADER')

	EndIf

	oView:showUpdateMsg(.F.)
	oView:showInsertMsg(.F.)

	//Seta bloco AfterViewActivate
	oView:SetAfterViewActivate({|oView| AfterView(oView)})

Return oView

/*/{Protheus.doc} AfterView
Fun��o executada ap�s ativar a view
@author brunno.costa
@since 15/01/2019
@version 1.0
@param 01 oView, object, objeto da View
@return Nil
/*/
Static Function AfterView(oView)
	Local lPrevia    := oView:GetModel():GetModel("FLD_PESQUISA"):GetValue("lPrevia")
	Local oModel
	Local oModelCab
	Local cCodigo
	Local cDescricao

	If slRefresh
		slRefresh  := .F.
		aSize(saAnterior,0)
		oModel     := oView:GetModel()
		oModelCab  := oModel:GetModel("FLD_PESQUISA")
		cCodigo    := oModelCab:GetValue("cCodigo")
		cDescricao := oModelCab:GetValue("cDescricao")
		If !Empty(cCodigo)
			//Limpa pesquisa
			oModelCab:SetValue("cCodigo", "")
			//Reaplica a pesquisa
			oModelCab:SetValue("cCodigo", cCodigo)
		EndIf
		If !Empty(cDescricao)
			oModelCab:SetValue("cDescricao", "")
			oModelCab:SetValue("cDescricao", cDescricao)
		EndIf
	EndIf

	If lPrevia
		//Realiza refresh da GridView de resultados para que o posicionamento em tela fique correto, igual ao da Model
		oView:Refresh("V_GRID_RESULTS")
	EndIf
Return

/*/{Protheus.doc} AltStruMod
Edita os campos da estrutura do Model
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oStruCab, object, estrutura do modelo FLD_PESQUISA
@param 02 oStruRes, object, estrutura do modelo GRID_RESULTS
@return Nil
/*/
Static Function AltStruMod(oStruCab, oStruRes)

	//Campos ddo cabe�alho da pesquisa
	oStruCab:AddField(STR0049                              ,; // [01]  C   Titulo do campo - "C�digo do produto:"
                      STR0049                              ,; // [02]  C   ToolTip do campo - "C�digo do produto:"
                      "cCodigo"                            ,; // [03]  C   Id do Field
                      "C"                                  ,; // [04]  C   Tipo do campo
                      GetSx3Cache("G1_COD","X3_TAMANHO")   ,; // [05]  N   Tamanho do campo
                      0                                    ,; // [06]  N   Decimal do campo
					  NIL                                  ,; // [07]  B   Code-block de valida��o do campo
					  NIL                                  ,; // [08]  B   Code-block de valida��o When do campo
					  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
					  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
					  .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update
                      .T.)                                    // [14]  L   Indica se o campo � virtual

	oStruCab:AddField(STR0061                              ,; // [01]  C   Titulo do campo - "Descri��o:"
                      STR0061                              ,; // [02]  C   ToolTip do campo - "Descri��o:"
                      "cDescricao"                         ,; // [03]  C   Id do Field
                      "C"                                  ,; // [04]  C   Tipo do campo
                      30                                   ,; // [05]  N   Tamanho do campo
                      0                                    ,; // [06]  N   Decimal do campo
					  NIL                                  ,; // [07]  B   Code-block de valida��o do campo
					  NIL                                  ,; // [08]  B   Code-block de valida��o When do campo
					  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
					  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
					  .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update
                      .T.)                                    // [14]  L   Indica se o campo � virtual

	oStruCab:AddField(STR0051                              ,; // [01]  C   Titulo do campo - "Pr�via"
                      STR0051                              ,; // [02]  C   ToolTip do campo - "Pr�via"
                      "lPrevia"                            ,; // [03]  C   Id do Field
                      "L"                                  ,; // [04]  C   Tipo do campo
                      1                                    ,; // [05]  N   Tamanho do campo
                      0                                    ,; // [06]  N   Decimal do campo
					  NIL                                  ,; // [07]  B   Code-block de valida��o do campo
					  NIL                                  ,; // [08]  B   Code-block de valida��o When do campo
					  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
					  {|| .T.}                             ,; // [11]  B   Code-block de inicializacao do campo
					  .F.                                  ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update
                      .T.)                                    // [14]  L   Indica se o campo � virtual

	oStruCab:SetProperty( "cCodigo"   ,  MODEL_FIELD_VALID ,FWBuildFeature(STRUCT_FEATURE_VALID,"a134Filtra('cCodigo')"))
	oStruCab:SetProperty( "cDescricao",  MODEL_FIELD_VALID ,FWBuildFeature(STRUCT_FEATURE_VALID,"a134Filtra('cDescricao')"))
	oStruCab:SetProperty( "G1_COD"    ,  MODEL_FIELD_KEY   , .T.)

	//Campos da GRID de resultados
	oStruRes:RemoveField("G1_COD")
	oStruRes:AddField(STR0052                              ,; // [01]  C   Titulo do campo - "N�veis"
                      STR0052                              ,; // [02]  C   ToolTip do campo - "N�veis"
                      "cNiveis"                            ,; // [03]  C   Id do Field
                      "C"                                  ,; // [04]  C   Tipo do campo
                      2                                    ,; // [05]  N   Tamanho do campo
                      0                                    ,; // [06]  N   Decimal do campo
					  NIL                                  ,; // [07]  B   Code-block de valida��o do campo
					  NIL                                  ,; // [08]  B   Code-block de valida��o When do campo
					  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
					  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
					  NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update
                      .T.)                                    // [14]  L   Indica se o campo � virtual

	oStruRes:AddField(STR0053                              ,; // [01]  C   Titulo do campo - Caminho
                      STR0053                              ,; // [02]  C   ToolTip do campo - Caminho
                      "cCaminho"                           ,; // [03]  C   Id do Field
                      "C"                                  ,; // [04]  C   Tipo do campo
                      255                                  ,; // [05]  N   Tamanho do campo
                      0                                    ,; // [06]  N   Decimal do campo
					  NIL                                  ,; // [07]  B   Code-block de valida��o do campo
					  NIL                                  ,; // [08]  B   Code-block de valida��o When do campo
					  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
					  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
					  NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update
                      .T.)                                    // [14]  L   Indica se o campo � virtual

	oStruRes:AddField("STR0053"                              ,; // [01]  C   Titulo do campo - Caminho
                      "STR0053"                              ,; // [02]  C   ToolTip do campo - Caminho
                      "cCaminhoD"                          ,; // [03]  C   Id do Field
                      "C"                                  ,; // [04]  C   Tipo do campo
                      255                                  ,; // [05]  N   Tamanho do campo
                      0                                    ,; // [06]  N   Decimal do campo
					  NIL                                  ,; // [07]  B   Code-block de valida��o do campo
					  NIL                                  ,; // [08]  B   Code-block de valida��o When do campo
					  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
					  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
					  NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update
                      .T.)                                    // [14]  L   Indica se o campo � virtual

	oStruRes:AddField(STR0050                              ,; // [01]  C   Titulo do campo - "Descri��o do componente"
                      STR0050                              ,; // [02]  C   ToolTip do campo - "Descri��o do componente"
                      "cDescricao"                         ,; // [03]  C   Id do Field
                      "C"                                  ,; // [04]  C   Tipo do campo
                      GetSx3Cache("B1_DESC","X3_TAMANHO")  ,; // [05]  N   Tamanho do campo
                      0                                    ,; // [06]  N   Decimal do campo
					  NIL                                  ,; // [07]  B   Code-block de valida��o do campo
					  NIL                                  ,; // [08]  B   Code-block de valida��o When do campo
					  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
                      .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigat�rio
					  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
					  NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
                      .T.                                  ,; // [13]  L   Indica se o campo pode receber valor em uma opera��o de update
                      .T.)                                    // [14]  L   Indica se o campo � virtual

Return Nil

/*/{Protheus.doc} AltStrView
Edita os campos da estrutura da View
@author brunno.costa
@since 14/01/2019
@version 1.0
@param 01 oStruCab, object, estrutura da View V_FLD_PESQUISA
@param 02 oStruRes, object, estrutura da View V_GRID_RESULTS
@return Nil
/*/
Static Function AltStrView(oStruCab, oStruRes)

	//Campos ddo cabe�alho da pesquisa
	oStruCab:RemoveField("G1_COD")
	oStruCab:AddField("cCodigo"                           ,; // [01]  C   Nome do Campo
	                  "1"                                 ,; // [02]  C   Ordem
	                  STR0049                             ,; // [03]  C   Titulo do campo - "C�digo do produto:"
	                  STR0049                             ,; // [04]  C   Descricao do campo - "C�digo do produto:"
	                  NIL                                 ,; // [05]  A   Array com Help
	                  "C"                                 ,; // [06]  C   Tipo do campo
	            	  GetSx3Cache("G1_COD","X3_PICTURE")  ,; // [07]  C   Picture
					  NIL                                 ,; // [08]  B   Bloco de Picture Var
					  "SB1"                               ,; // [09]  C   Consulta F6
					  .T.                                 ,; // [10]  L   Indica se o campo � alteravel
					  NIL                                 ,; // [11]  C   Pasta do campo
					  NIL                                 ,; // [12]  C   Agrupamento do campo
					  NIL                                 ,; // [13]  A   Lista de valores permitido do campo (Combo)
					  NIL                                 ,; // [14]  N   Tamanho maximo da maior op��o do combo
					  NIL                                 ,; // [15]  C   Inicializador de Browse
					  .T.                                 ,; // [16]  L   Indica se o campo � virtual
					  NIL                                 ,; // [17]  C   Picture Variavel
					  NIL                                 )  // [18]  L   Indica pulo de linha ap�s o campo

	oStruCab:AddField("cDescricao"                        ,; // [01]  C   Nome do Campo
	                  "2"                                 ,; // [02]  C   Ordem
	                  STR0061                             ,; // [03]  C   Titulo do campo - "Descri��o:"
	                  STR0061                             ,; // [04]  C   Descricao do campo - "Descri��o:"
	                  NIL                                 ,; // [05]  A   Array com Help
	                  "C"                                 ,; // [06]  C   Tipo do campo
	            	  GetSx3Cache("B1_DESC","X3_PICTURE") ,; // [07]  C   Picture
					  NIL                                 ,; // [08]  B   Bloco de Picture Var
					  NIL                                 ,; // [09]  C   Consulta F6
					  .T.                                 ,; // [10]  L   Indica se o campo � alteravel
					  NIL                                 ,; // [11]  C   Pasta do campo
					  NIL                                 ,; // [12]  C   Agrupamento do campo
					  NIL                                 ,; // [13]  A   Lista de valores permitido do campo (Combo)
					  NIL                                 ,; // [14]  N   Tamanho maximo da maior op��o do combo
					  NIL                                 ,; // [15]  C   Inicializador de Browse
					  .T.                                 ,; // [16]  L   Indica se o campo � virtual
					  NIL                                 ,; // [17]  C   Picture Variavel
					  NIL                                 )  // [18]  L   Indica pulo de linha ap�s o campo

	//Campos da GRID de resultados
	oStruRes:RemoveField("G1_COD")
	oStruRes:AddField("cCaminho"                          ,; // [01]  C   Nome do Campo
					"1"                                   ,; // [02]  C   Ordem
					STR0053                               ,; // [03]  C   Titulo do campo - "Caminho"
					STR0053                               ,; // [04]  C   Descricao do campo - "Caminho"
					NIL                                   ,; // [05]  A   Array com Help
					"C"                                   ,; // [06]  C   Tipo do campo
					NIL                                   ,; // [07]  C   Picture
					NIL                                   ,; // [08]  B   Bloco de Picture Var
					NIL                                   ,; // [09]  C   Consulta F6
					.F.                                   ,; // [10]  L   Indica se o campo � alteravel
					NIL                                   ,; // [11]  C   Pasta do campo
					NIL                                   ,; // [12]  C   Agrupamento do campo
					NIL                                   ,; // [13]  A   Lista de valores permitido do campo (Combo)
					NIL                                   ,; // [14]  N   Tamanho maximo da maior op��o do combo
					NIL                                   ,; // [15]  C   Inicializador de Browse
					.T.                                   ,; // [16]  L   Indica se o campo � virtual
					NIL                                   ,; // [17]  C   Picture Variavel
					NIL                                   )  // [18]  L   Indica pulo de linha ap�s o campo

	oStruRes:AddField("cDescricao"                        ,; // [01]  C   Nome do Campo
					"2"                                   ,; // [02]  C   Ordem
					STR0050                               ,; // [03]  C   Titulo do campo - "Descri��o do componente:"
					STR0050                               ,; // [04]  C   Descricao do campo - "Descri��o do componente:"
					NIL                                   ,; // [05]  A   Array com Help
					"C"                                   ,; // [06]  C   Tipo do campo
					NIL                                   ,; // [07]  C   Picture
					NIL                                   ,; // [08]  B   Bloco de Picture Var
					NIL                                   ,; // [09]  C   Consulta F6
					.F.                                   ,; // [10]  L   Indica se o campo � alteravel
					NIL                                   ,; // [11]  C   Pasta do campo
					NIL                                   ,; // [12]  C   Agrupamento do campo
					NIL                                   ,; // [13]  A   Lista de valores permitido do campo (Combo)
					NIL                                   ,; // [14]  N   Tamanho maximo da maior op��o do combo
					NIL                                   ,; // [15]  C   Inicializador de Browse
					.T.                                   ,; // [16]  L   Indica se o campo � virtual
					NIL                                   ,; // [17]  C   Picture Variavel
					NIL                                   )  // [18]  L   Indica pulo de linha ap�s o campo

	oStruRes:AddField("cNiveis"                           ,; // [01]  C   Nome do Campo
					"3"                                   ,; // [02]  C   Ordem
					STR0052                               ,; // [03]  C   Titulo do campo - "N�veis"
					STR0052                               ,; // [04]  C   Descricao do campo - "N�veis"
					NIL                                   ,; // [05]  A   Array com Help
					"C"                                   ,; // [06]  C   Tipo do campo
					NIL                                   ,; // [07]  C   Picture
					NIL                                   ,; // [08]  B   Bloco de Picture Var
					NIL                                   ,; // [09]  C   Consulta F6
					.F.                                   ,; // [10]  L   Indica se o campo � alteravel
					NIL                                   ,; // [11]  C   Pasta do campo
					NIL                                   ,; // [12]  C   Agrupamento do campo
					NIL                                   ,; // [13]  A   Lista de valores permitido do campo (Combo)
					NIL                                   ,; // [14]  N   Tamanho maximo da maior op��o do combo
					NIL                                   ,; // [15]  C   Inicializador de Browse
					.T.                                   ,; // [16]  L   Indica se o campo � virtual
					NIL                                   ,; // [17]  C   Picture Variavel
					NIL                                   )  // [18]  L   Indica pulo de linha ap�s o campo

	oStruRes:SetProperty("cNiveis"   , MVC_VIEW_WIDTH, 60)
	oStruRes:SetProperty("cDescricao", MVC_VIEW_WIDTH, 250)
Return Nil

/*/{Protheus.doc} a134Filtra()
Filtra os dados da pesquisa - Tela de Processamento
@author brunno.costa
@since 14/01/2019
@version 1.0
@return .T.
/*/
Function a134Filtra()
	Local lAbort := .F.
	Processa({|| Filtra() }, STR0062, STR0064, lAbort) //"Aguarde..." - "Pesquisando as op��es..."
Return !lAbort

/*/{Protheus.doc} Filtra()
Filtra os dados da pesquisa
@author brunno.costa
@since 14/01/2019
@version 1.0
@return .T.
/*/
Static Function Filtra()

	Local aArea 	 := GetArea()
	Local oModel     := FWModelActive()
	Local oModelCab  := oModel:GetModel("FLD_PESQUISA")
	Local oGridPesq  := oModel:GetModel("GRID_RESULTS")
	Local cCodigo    := oModelCab:GetValue("cCodigo")
	Local cDescricao := oModelCab:GetValue("cDescricao")
	Local lPrevia    := oModelCab:GetValue("lPrevia")
	Local aPaths     := {}
	Local cCaminho   := ""
	Local cCaminhoD  := ""
	Local lLimpa     := .F.
	Local nInd       := 0
	Local lAbort     := .F.

	//Seta regua infinita
	ProcRegua(0)

	If oModel != Nil
		If !Empty(cCodigo + cDescricao)
			//Avalia onde o componente � usado
			Processa({|| PCPCmpUsd(.F., cCodigo, cDescricao, .T., @aPaths) }, STR0062, STR0065, lAbort) //"Aguarde..." - "Lendo as op��es no banco..."
		EndIf

		If Len(aPaths) > 0 .AND. !lAbort
			oGridPesq:SetNoUpdateLine(.F.)
			oGridPesq:SetNoDeleteLine(.F.)
			oGridPesq:SetNoInsertLine(.F.)
			oGridPesq:ClearData(.F.,.T.)

			For nInd := 1 to Len(aPaths)
				//Processa a Regua
				IncProc()

				If nInd > 1
					oGridPesq:AddLine()
				EndIf
				cCaminho := AllTrim(aPaths[nInd][1])
				cCaminho := StrTran(cCaminho, ' ', '')
				cCaminho := StrTran(cCaminho, '|', ' -> ')

				cCaminhoD := AllTrim(aPaths[nInd][5])
				cCaminhoD := StrTran(cCaminhoD, ' ', '')
				cCaminhoD := StrTran(cCaminhoD, '|', ' -> ')

				oGridPesq:LoadValue("cNiveis"    , PadL(cValToChar(aPaths[nInd][3]), 2, '0'))
				oGridPesq:LoadValue("cCaminho"   , AllTrim(cCaminho))
				oGridPesq:LoadValue("cCaminhoD"  , AllTrim(cCaminhoD))
				oGridPesq:LoadValue("cDescricao" , Alltrim(aPaths[nInd][4]))
			Next nInd

			oGridPesq:GoLine(1)
			oGridPesq:SetNoUpdateLine(.T.)
			oGridPesq:SetNoDeleteLine(.T.)
			oGridPesq:SetNoInsertLine(.T.)
		Else
			lLimpa := .T.
		Endif

		If lLimpa
			oGridPesq:ClearData(.F.,.T.)
			oGridPesq:DeActivate()
			oGridPesq:Activate()
		EndIf

		If lPrevia .AND. oView != Nil .And. oModel != Nil .And. oView:IsActive()
			oView:Refresh("V_GRID_RESULTS")
		EndIf
	EndIf

	RestArea(aArea)

Return !lAbort

/*/{Protheus.doc} PCPCmpUsd
Query recursiva que avalia onde os componentes s�o utilizados
@author brunno.costa
@since 14/01/2019
@version 1.0
@param lPreEstrutura, l�gico   , indicador l�gico se o produto � de pr�-estrutura
@param cCodProduto  , caracter , c�digo do componente a ser avaliado
@param cDescricao   , caracter , parte da descri��o do componente a ser avaliada
@param lGetPath     , l�gico   , indica se retorna por refer�ncia os caminhos
@param aPaths       , array    , array com os caminhos do componente na estrutura, retorno por refer�ncia
                                 aPaths[x] := {Path, Componente, Nivel}
@param cCmplWhere   , caracter , complemento de filtro para montagem recursiga da clausula where
@return Nil
/*/
Static Function PCPCmpUsd(lPreEstrutura, cCodProduto, cDescricao, lGetPath, aPaths, cCmplWhere)

	Local aArea        := GetArea()
	Local aAreaSB1     := SB1->(GetArea())
	Local cAliasTop    := GetNextAlias()
	Local cAliasSelect := Iif(lPreEstrutura, RetSqlName( "SGG" ), RetSqlName( "SG1" ))
	Local cBanco       := TCGetDB()
	Local cQuery       := ""
	Local cQueryBase   := ""
	Local lReturn      := .F.
	Local oModel       := FWModelActive()

	Default lPreEstrutura := .F.
	Default cCodProduto   := ""
	Default cDescricao    := ""
	Default lGetPath      := .F.
	Default aPaths        := {}
	Default cCmplWhere    := ""

	oModel:lModify := .T.

	//Tratamentos de SQL Injection
	cCodProduto := StrTran(cCodProduto,"'","")
	cDescricao  := StrTran(cDescricao ,"'","")

	//Seta regua infinita
	ProcRegua(0)

	If !Empty(cCodProduto) .OR. !Empty(cDescricao)

		//Processa Filtro - Componente
		StaticCall( PCPA134, RgrFiltro, 1, @cCmplWhere)

		//Cria Query base para todos os bancos
		cQueryBase := " WITH EstruturaRecursiva(G1_COMP, B1_DESC, G1_REVINI, G1_REVFIM, G1_COD, Nivel, Path, PathA, PathD)" //+ CLRF
		cQueryBase += " AS ("
		cQueryBase +=     " SELECT G1_COMP,"  //+ CLRF
		cQueryBase +=            " SB1_COMP.B1_DESC,"  //+ CLRF
		cQueryBase +=            " G1_REVINI,"  //+ CLRF
		cQueryBase +=            " G1_REVFIM,"  //+ CLRF
		cQueryBase +=            " G1_COD,"  //+ CLRF
		cQueryBase +=            " 1 as Nivel,"  //+ CLRF
		cQueryBase +=            " Cast(G1_COMP || '|' || G1_COD AS VarChar(8000)) AS Path,"  //+ CLRF
		cQueryBase +=            " Cast(G1_COMP AS VarChar(8000)) AS PathA," //+ CLRF
		If !Empty(cDescricao)
			If cBanco == "MSSQL"
				cQueryBase +=    " Cast( (CASE WHEN SB1_COMP.B1_DESC LIKE '%" + AllTrim(cDescricao) + "%' THEN G1_COMP || '|' ELSE '' END) +"
				cQueryBase +=          " (CASE WHEN SB1_PROD.B1_DESC LIKE '%" + AllTrim(cDescricao) + "%' THEN G1_COD  || '|' ELSE '' END) AS VarChar(8000) ) AS PathD"  //+ CLRF
			Else
				cQueryBase +=    " Cast( Concat((CASE WHEN SB1_COMP.B1_DESC LIKE '%" + AllTrim(cDescricao) + "%' THEN G1_COMP || '|' ELSE '' END),"
				cQueryBase +=                 " (CASE WHEN SB1_PROD.B1_DESC LIKE '%" + AllTrim(cDescricao) + "%' THEN G1_COD  || '|' ELSE '' END)) AS VarChar(8000) ) AS PathD"  //+ CLRF
			EndIf
		Else
			cQueryBase +=        " ' ' AS PathD "  //+ CLRF
		EndIf
		cQueryBase +=       " FROM " + cAliasSelect + " g1_p"  //+ CLRF
		cQueryBase +=      " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_COMP"  //+ CLRF
		cQueryBase +=         " ON SB1_COMP.B1_COD     = g1_p.G1_COMP"  //+ CLRF
		cQueryBase +=        " AND SB1_COMP.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQueryBase +=        " AND SB1_COMP.D_E_L_E_T_ = ' '"  //+ CLRF
		cQueryBase +=      " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_PROD"  //+ CLRF
		cQueryBase +=         " ON SB1_PROD.B1_COD     = g1_p.G1_COD"  //+ CLRF
		cQueryBase +=        " AND SB1_PROD.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQueryBase +=        " AND SB1_PROD.D_E_L_E_T_ = ' '"  //+ CLRF
		cQueryBase +=      " WHERE g1_p.D_E_L_E_T_ = ' '"  //+ CLRF
		cQueryBase +=        " AND g1_p.G1_FILIAL  = '" + xFilial("SG1") + "' "

		//Processa Filtro - Intermedi�rios e PA
		StaticCall( PCPA134, RgrFiltro, 1, @cCmplWhere, .T.)

		cQueryBase += cCmplWhere
		cQueryBase +=      " UNION ALL"  //+ CLRF
		cQueryBase +=     " SELECT rec.G1_COMP,"  //+ CLRF
		cQueryBase +=            " rec.B1_DESC,"  //+ CLRF
		cQueryBase +=            " estrutura.G1_REVINI,"  //+ CLRF
		cQueryBase +=            " estrutura.G1_REVFIM,"  //+ CLRF
		cQueryBase +=            " estrutura.G1_COD,"  //+ CLRF
		cQueryBase +=            " rec.Nivel + 1 AS Nivel,"  //+ CLRF
		cQueryBase +=            " Cast((rec.Path || '|' || estrutura.G1_COD) AS VarChar(8000)) Path,"  //+ CLRF
		cQueryBase +=            " rec.Path PathA," //+ CLRF
		If !Empty(cDescricao)
			If cBanco == "MSSQL"
				cQueryBase +=    " Cast( rec.PathD + (CASE WHEN SB1_PROD.B1_DESC LIKE '%" + AllTrim(cDescricao) + "%' THEN estrutura.G1_COD || '|' ELSE '' END) AS VarChar(8000)) PathD"  //+ CLRF
			Else
				cQueryBase +=    " Cast( Concat(rec.PathD,"
				cQueryBase +=                 " (CASE WHEN SB1_PROD.B1_DESC LIKE '%" + AllTrim(cDescricao) + "%' THEN estrutura.G1_COD || '|' ELSE '' END)) AS VarChar(8000)) PathD"  //+ CLRF
		EndIf

		Else
			cQueryBase +=        " ' ' AS PathD"  //+ CLRF
		EndIf
		cQueryBase +=       " FROM " + cAliasSelect + " estrutura"  //+ CLRF
		cQueryBase +=      " INNER JOIN EstruturaRecursiva rec"  //+ CLRF
		cQueryBase +=         " ON estrutura.G1_COMP = rec.G1_COD"  //+ CLRF
		cQueryBase +=      " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_COMP"  //+ CLRF
		cQueryBase +=         " ON SB1_COMP.B1_COD     = estrutura.G1_COMP"  //+ CLRF
		cQueryBase +=        " AND SB1_COMP.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQueryBase +=        " AND SB1_COMP.D_E_L_E_T_ = ' '"  //+ CLRF
		cQueryBase +=      " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_PROD"  //+ CLRF
		cQueryBase +=         " ON SB1_PROD.B1_COD     = estrutura.G1_COD"  //+ CLRF
		cQueryBase +=        " AND SB1_PROD.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQueryBase +=        " AND SB1_PROD.D_E_L_E_T_ = ' '"  //+ CLRF
		cQueryBase +=      " WHERE estrutura.D_E_L_E_T_ = ' '"  //+ CLRF
		cQueryBase +=        " AND estrutura.G1_FILIAL  = '" + xFilial("SG1") + "' "
		cQueryBase +=        " AND rec.Path NOT LIKE '%|' || estrutura.G1_COD || '%'"

		cCmplWhere := ""
		//Processa Filtro - Intermedi�rios e PA
		StaticCall( PCPA134, RgrFiltro, 1, @cCmplWhere, .F.)

		cQueryBase += StrTran(cCmplWhere, "G1_", "estrutura.G1_")
		cQueryBase +=  " )"  //+ CLRF
		cQueryBase +=  " SELECT DISTINCT E1.G1_COMP as Componente, E1.Nivel, E1.Path, E1.B1_DESC AS DescrCompo, E1.PathD"  //+ CLRF
		cQueryBase +=    " FROM EstruturaRecursiva E1"  //+ CLRF
		cQueryBase +=    " LEFT JOIN EstruturaRecursiva E2"  //+ CLRF
		cQueryBase +=      " ON E1.Path = E2.PathA"
 		cQueryBase +=   " WHERE E2.Path IS NULL"  //+ CLRF
		If !Empty(cCodProduto)
			cQueryBase += " AND '|' || Replace(E1.Path, ' ', '|') || '|' like '%|" + StrTran(AllTrim(cCodProduto), ' ', '|') + "|%'"  //+ CLRF
		EndIf
		If !Empty(cDescricao)
			cQueryBase += " AND E1.PathD != ' '"  //+ CLRF
		EndIf

		//Atribui Query Padr�o
		cQuery := cQueryBase

		//Realiza ajustes da Query para cada banco
		If cBanco == "ORACLE"

			//Limita a 1 registro
			If !lGetPath
				cQuery +=  " AND ROWNUM = 1"
			EndIf

			//Ordena por Path
			cQuery +=  " ORDER BY 3"

		ElseIf cBanco == "POSTGRES"

			//Altera sintaxe da clausula WITH
			cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

			//Altera sintaxe da clausula WITH
			cQuery := StrTran(cQuery, "AND E1.PathD != ' '", "AND Trim(E1.PathD) != ''")


			//Ordena por Path
			cQuery += " ORDER BY 3"

			//Limita a 1 registro
			If !lGetPath
				cQuery += " LIMIT 1"
			EndIf

			//Medida paliativa banco POSTGRES. Banco suporta VarChar(8000), entretanto DbAccess com PostGres funciona em bases desatualizadas
			//cQuery := StrTran(cQuery,"VarChar(8000)","VarChar(255)")

			//Corrige Falhas internas de Bin�rio - POSTGRES
			cQuery := StrTran(cQuery, chr(13), " ")
			cQuery := StrTran(cQuery, chr(10), " ")
			cQuery := StrTran(cQuery, chr(09), " ")

		//ElseIf cBanco == "MSSQL"
		Else
			//Substitui concatena��o || por +
			cQuery := StrTran(cQuery, '||', '+')

			//Limita a 1 registro
			If !lGetPath
				cQuery := StrTran(cQuery, 'G1_COMP as Componente', 'TOP 1 G1_COMP as Componente')
			EndIf

			//Ordena por Path
			cQuery +=  "ORDER BY 3"
		EndIf

		If lPreEstrutura
			cQuery := StrTran(cQuery, 'G1_', 'GG_')
		EndIf
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	If !(cAliasTop)->(Eof())
		lReturn := .T.
	EndIf
	If lGetPath
		While !(cAliasTop)->(Eof())
			//Processa a Regua
			IncProc()

			aAdd(aPaths, {(cAliasTop)->Path, (cAliasTop)->Componente, (cAliasTop)->Nivel, (cAliasTop)->DescrCompo, (cAliasTop)->PathD})
			(cAliasTop)->(DbSkip())
		EndDo
	EndIf
	(cAliasTop)->(dbCloseArea())
	RestArea(aAreaSB1)
	RestArea(aArea)

Return lReturn
