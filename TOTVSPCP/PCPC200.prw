#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPC200.CH"

//Constantes para uso no array saCargos
#DEFINE IND_ACARGO_PAI  1
#DEFINE IND_ACARGO_COMP 2

//Constantes referentes aos �cones da tree
#DEFINE VALIDO_A   "FOLDER5"
#DEFINE VALIDO_F   "FOLDER6"
#DEFINE INVALIDO_A "FOLDER7"
#DEFINE INVALIDO_F "FOLDER8"

Static soDbTree   := NIL
Static snSeqTree  := 0
Static saCargos   := {}
Static saTreeLoad := {}

Static snTamCod   := GetSx3Cache("G1_COD"    ,"X3_TAMANHO")
Static snTamComp  := GetSx3Cache("G1_COMP"   ,"X3_TAMANHO")
Static snTamTRT   := GetSx3Cache("G1_TRT"    ,"X3_TAMANHO")
Static snTamRev   := GetSx3Cache("B1_REVATU" ,"X3_TAMANHO")
Static snTamPromp := TamPrompt()

/*/{Protheus.doc} PCPC200()
Consulta de Estrutura do Item
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return NIL
/*/
Function PCPC200()
	Local aArea := GetArea()

	//Prote��o do fonte para n�o ser utilizado pelos clientes neste momento.
	If !(FindFunction("RodaNewPCP") .And. RodaNewPCP())
		Help(' ',1,"Help" ,,STR0002,2,0,,,,,,) // STR0002 - "Rotina n�o dispon�vel nesta release."
		Return
	EndIf

	If Pergunte("PCPC200",.T.)
		P200Proces()
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} ModelDef
Defini��o do Modelo
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return oModel
/*/
Static Function ModelDef()
	Local oStruCab := P200StrCab(.T.) // N�o exibido
	Local oModel   := MPFormModel():New("PCPC200")

	// Mestre
	oModel:AddFields("MASTER", /*cOwner*/, oStruCab, , ,{|| P200LoadM()})
	oModel:GetModel ("MASTER" ):SetDescription(STR0001) // STR0001 - "Consulta da Estrutura do Item"
	oModel:GetModel ("MASTER" ):SetOnlyQuery()

	// Demais defini��es do modelo
	oModel:SetPrimaryKey( {} )
	oModel:SetDescription(STR0001) // STR0001 - "Consulta da Estrutura do Item"

Return oModel

/*/{Protheus.doc} ViewDef
Defini��o da View
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return oView
/*/
Static Function ViewDef()

	Local oModel   := FWLoadModel("PCPC200")
	Local oStruCab := P200StrCab(.F.) // N�o exibido
	Local oView    := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_MASTER", oStruCab, "MASTER" )

	// V_TREE - Cria View da Tree
	oView:AddOtherObject("V_TREE", {|oPanel| MontaTree(oPanel)})

	oView:CreateHorizontalBox("HEADER",   0) // N�o exibe cabe�alho
	oView:CreateHorizontalBox("DETAIL", 100)

	oView:SetOwnerView("VIEW_MASTER", "HEADER")
	oView:SetOwnerView("V_TREE", "DETAIL")

	oView:AddUserButton(STR0003, "", {|oModel| P200AltPar(oModel) }, , , MODEL_OPERATION_VIEW, .T.) // STR0003 - "Par�metros"

Return oView

/*/{Protheus.doc} P200AltPar
Fun��o acionada no bot�o "Par�metros" - abre novamente a Pergunta
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@param 01 oModel - Modelo de dados
@return NIL
/*/
Static Function P200AltPar(oModel)
	If Pergunte("PCPC200",.T.)
		MontaTree()
	EndIf

Return

/*/{Protheus.doc} P200StrCab
Monta estrutura de campos do Cabe�alho (n�o ser� exibido o cabe�alho)
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@param 01 lModel - Modelo de dados
@return oStru
/*/
Static Function P200StrCab(lModel)
	Local oStru := NIL

	// MVC exige que tenha campo no modelo Mestre - Esses campos n�o s�o exibidos na VIEW
	If lModel
		oStru := FWFormModelStruct():New()
		oStru:AddField(STR0004,STR0004,"CABECALHO","C",1,0,NIL,NIL,NIL,.F.,NIL,NIL,NIL,.T.) // STR0004 - "Cabe�alho"
	Else
		oStru := FWFormViewStruct():New()
		oStru:AddField("CABECALHO","01",STR0004,STR0004,NIL,"C","",NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,NIL,NIL) // STR0004 - "Cabe�alho"
	EndIf

Return oStru

/*/{Protheus.doc} P200LoadM
Fun��o para carregar o cabe�alho (n�o exibido)
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return aLoad
/*/
Static Function P200LoadM()
	Local aLoad := {" "}

Return aLoad

/*/{Protheus.doc} P200Proces
Fun��o para abertura da tela
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return nValor
/*/
Static Function P200Proces()
	Local nValor	:= 0
	Local aButtons	:= { { .F., Nil }    ,;  	//  1 - Copiar
	                     { .F., Nil }    ,;  	//  2 - Recortar
	                     { .F., Nil }    ,;  	//  3 - Colar
	                     { .T., Nil }    ,;  	//  4 - Calculadora
	                     { .T., Nil }    ,;  	//  5 - Spool
	                     { .T., Nil }    ,;  	//  6 - Imprimir
	                     { .F., ""  }    ,;  	//  7 - Cancelar
	                     { .T., Nil }    ,;  	//  8 - "Fechar"
	                     { .F., Nil }    ,;		//  9 - WalkTrhough
	                     { .T., Nil }    ,;  	// 10 - Ambiente
	                     { .F., Nil }    ,;  	// 11 - Mashup
	                     { .T., Nil }    ,;  	// 12 - Help
	                     { .T., Nil }    ,;  	// 13 - Formul�rio HTML
	                     { .F., Nil } }      	// 14 - ECM
	Default lAutoMacao := .F.

	IF !lAutoMacao
		nValor := FWExecView(STR0005,"PCPC200",OP_PESQUISAR,/*oDlg*/,{||.T.},/*bOk*/,/*50*/,aButtons) // STR0005 - "Consulta"
	ENDIF
Return nValor

/*/{Protheus.doc} MontaTree
Fun��o respons�vel por fazer a cria��o do objeto da TREE
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@param 01 oPanel - Painel onde deve ser criada a tree
@return Nil
/*/
Static Function MontaTree(oPanel)
	//Local lMontouTree  := .F.

	// Inicializa as vari�veis do tipo Static deste fonte
	snSeqTree  := 0
	saCargos   := {}
	saTreeLoad := {}

	// Cria ou Reseta a Tree
	If soDbTree == Nil
		soDbTree := DbTree():New(0, 0, 100, 100, oPanel, {|| TreeChange()}, /*bRClick*/, .T.,,,	STR0010 				+ ";" + ; // STR0010 - "C�digo"
																								STR0011					+ ";" + ; // STR0011 - "Descri��o"
																								RetTitle("B1_TIPO")		+ ";" + ;
																								RetTitle("B1_UM")		+ ";" + ;
																								STR0015					+ ";" + ; // STR0015 - "Sequ�ncia"
																								RetTitle("G1_QUANT")	+ ";" + ;
																								STR0012					+ ";" + ; // STR0012 - "�ndice Perda"
																								RetTitle("G1_INI")		+ ";" + ;
																								RetTitle("G1_FIM")		+ ";" + ;
																								RetTitle("G1_FIXVAR")	+ ";" + ;
																								RetTitle("G1_GROPC")	+ ";" + ;
																								RetTitle("G1_OPC")		+ ";" + ;
																								RetTitle("G1_REVINI")	+ ";" + ;
																								RetTitle("G1_REVFIM")	+ ";" + ;
																								STR0013					+ ";" + ; // STR0013 - "N�vel"
																								RetTitle("G1_FANTASM")	+ ";" + ;
																								RetTitle("G1_LISTA")	+ ";" + ;
																								STR0016					+ ";" + ; // STR0016 - "Roteiro"
																								STR0017					+ ";" + ; // STR0017 - "Opera��o"
																								STR0014)						  // STR0014 - "Observa��o"

		soDbTree:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		soDbTree:Reset()
		snSeqTree := 0
	EndIf

	AddPaiTree(MV_PAR01)

	TreeChange()

	If !Empty(saTreeLoad)
		soDbTree:EndTree()
	EndIf

Return Nil

/*/{Protheus.doc} TreeChange
Execu��es de a��es durante clique/change na Tree
@author Carlos Alexandre da Silveira
@since 11/01/2019
@version 1.0
@return NIL
/*/
Static Function TreeChange()
	Local oView  := FwViewActive()
	Local cCargo := soDbTree:GetCargo()

	// Verifica no array saTreeLoad se este item j� foi carregado (segundo n�vel)
	If Carregado(cCargo)
		Return
	EndIf

	// Altera cursor do mouse indicando processamento
	CursorWait()

	// Adiciona componentes na tree de acordo com o que foi carregado no modelo de componentes
	AddCmpTree(cCargo, "COMP")

	// Retorna cursor do mouse
	CursorArrow()

	soDbTree:SetFocus()

Return

/*/{Protheus.doc} AddPaiTree
Adiciona o item pai na tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCodPai, - C�digo do item pai
@param 02 oModel   - Modelo de dados
@return Nil
/*/
Static Function AddPaiTree(cCodPai,oModel)
	Local cAliasPai    := GetNextAlias()
	Local cRevAtu	   := ""
	Local cPicQuant    := GetSx3Cache("G1_QUANT","X3_PICTURE")
	Local cPrompt      := ""
	Local lValido	   := .T.
	Local cFolderA     := VALIDO_A
	Local cFolderF     := VALIDO_F
	Default lAutoMacao := .F.

	P200TrataP()

	BeginSQL Alias cAliasPai
		SELECT DISTINCT SG1.G1_COD, SB1.B1_DESC, SB1.B1_REVATU, SB1.B1_TIPO, SB1.B1_UM, SG1.G1_NIV, SG1.G1_INI, SG1.G1_FIM
		  FROM %Table:SG1% SG1,
		       %Table:SB1% SB1
		 WHERE SG1.G1_FILIAL = %XFilial:SG1%
		   AND SB1.B1_FILIAL = %XFilial:SB1%
		   AND SB1.B1_COD    = SG1.G1_COD
		   AND SG1.G1_COD    = %Exp:cCodPai%
		   AND SG1.%NotDel%
		   AND SB1.%NotDel%
	EndSQL

	If !(cAliasPai)->(Eof())
		// Revis�o?
		If Empty(MV_PAR05)
			cRevAtu := (cAliasPai)->B1_REVATU
		Else
			cRevAtu := MV_PAR05
		EndIf

		// Itens vencidos?
		If MV_PAR07 = 1
			If dDataBase < StoD((cAliasPai)->G1_INI) .Or. dDataBase > StoD((cAliasPai)->G1_FIM)
				lValido := .F.
			EndIf
		EndIf

		//If P200ValRot((cAliasPai)->G1_COD)
			cCargo  := MontaCargo(MV_PAR01, MV_PAR01, "", cRevAtu, "CPAI")

			cFolderA  := If(lValido, VALIDO_A, INVALIDO_A)
			cFolderF  := If(lValido, VALIDO_F, INVALIDO_F)

			cPrompt :=	(cAliasPai)->G1_COD 			+ ";" + ;
						(cAliasPai)->B1_DESC 			+ ";" + ;
						(cAliasPai)->B1_TIPO 			+ ";" + ;
						(cAliasPai)->B1_UM				+ ";" + ;
						" "								+ ";" + ;
						Transform((MV_PAR06), cPicQuant)+ ";" + ;
						" " 							+ ";" + ;
						" " 							+ ";" + ;
						" " 							+ ";" + ;
						" "  							+ ";" + ;
						" "								+ ";" + ;
						" " 							+ ";" + ;
						cRevAtu 						+ ";" + ;
						cRevAtu				 			+ ";" + ;
						(cAliasPai)->G1_NIV 			+ ";" + ;
						" "								+ ";" + ;
						" "								+ ";" + ;
						" "								+ ";" + ;
						" "								+ ";" + ;
						" "
			IF !lAutoMacao
				soDbTree:AddTree(PadR(cPrompt,snTamPromp), .T., cFolderA, cFolderF, , , cCargo)
				soDbTree:TreeSeek(cCargo)
				soDbTree:Refresh()
				soDbTree:SetFocus()
			ENDIF
		//EndIf
	EndIf

	(cAliasPai)->(DbCloseArea())

Return

/*/{Protheus.doc} AddCmpTree
Adiciona os componentes na tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCargoPai	- Cargo do n�vel pai de onde os componentes ser�o adicionados.
@param 02 cTipo		- Indicador de tipo de registro:
					ESTR - Componente da estrutura
					TEMP - N� tempor�rio da tree, utilizado apenas para exibir a op��o de expandir o n�vel (+)
@return Nil
/*/
Static Function AddCmpTree(cCargoPai, cTipo)
	Local cAliasSG1 	:= GetNextAlias()
	Local cAliasSGF 	:= GetNextAlias()
	Local cDataRef		:= DToS(MV_PAR03)
	Local cCargo    	:= ""
	Local cCodPai   	:= RetInf(cCargoPai, "COMP")
	Local cRevAtu   	:= RetInf(cCargoPai, "REV")
	Local nPos      	:= aScan(saCargos, { |x| x[IND_ACARGO_PAI]  == cCargoPai })
	Local lValido		:= .T.
	Local cFolderA  	:= VALIDO_A
	Local cFolderF  	:= VALIDO_F
	Local cFixVar		:= ""
	Local cFantasm		:= ""
	Local cPicPerda     := GetSx3Cache("G1_PERDA","X3_PICTURE")
	Local cPicQuant     := GetSx3Cache("G1_QUANT","X3_PICTURE")
	Local cRotPai		:= ""
	Local cRoteiro		:= ""
	Local cOperacao		:= ""
	Local cNivelEstr	:= ""
	Local nQtBase       := 1
	Default lAutoMacao  := .F.

	If nPos > 0
		If RetInf(saCargos[nPos][IND_ACARGO_COMP], "TIPO") == "TEMP"
			soDbTree:TreeSeek(saCargos[nPos][2])
			soDbTree:DelItem()
			soDbTree:TreeSeek(cCargoPai)
		EndIf
	EndIf

	If MV_PAR07 = 1
		BeginSQL Alias cAliasSG1
			SELECT SG1.G1_COMP,	 SG1.G1_TRT, SB1.B1_DESC,   SB1.B1_TIPO,   SB1.B1_UM,	  SG1.G1_TRT,  SG1.G1_QUANT,   SG1.G1_PERDA, SG1.G1_INI,     SG1.G1_FIM,    SG1.G1_FIXVAR,
				   SG1.G1_GROPC, SG1.G1_OPC, SG1.G1_REVINI, SG1.G1_REVFIM, SB1.B1_REVATU, SG1.G1_NIV,  SG1.G1_FANTASM, SG1.G1_LISTA, SB1.B1_OPERPAD, SG1.G1_OBSERV
			FROM %Table:SG1% SG1,
				 %Table:SB1% SB1
			WHERE SG1.G1_FILIAL  = %XFilial:SG1%
			AND SB1.B1_FILIAL  = %XFilial:SB1%
			AND SB1.B1_COD     = SG1.G1_COMP
			AND SG1.G1_COD     = %Exp:cCodPai%
			AND SG1.G1_REVINI <= %Exp:cRevAtu%
			AND SG1.G1_REVFIM >= %Exp:cRevAtu%
			AND SG1.%NotDel%
			AND SB1.%NotDel%
			ORDER BY SG1.G1_COMP, SG1.G1_TRT
		EndSQL
	Else
		BeginSQL Alias cAliasSG1
			SELECT SG1.G1_COMP,	 SG1.G1_TRT, SB1.B1_DESC,   SB1.B1_TIPO,   SB1.B1_UM,	  SG1.G1_TRT,  SG1.G1_QUANT,   SG1.G1_PERDA, SG1.G1_INI,     SG1.G1_FIM,    SG1.G1_FIXVAR,
				   SG1.G1_GROPC, SG1.G1_OPC, SG1.G1_REVINI, SG1.G1_REVFIM, SB1.B1_REVATU, SG1.G1_NIV,  SG1.G1_FANTASM, SG1.G1_LISTA, SB1.B1_OPERPAD, SG1.G1_OBSERV
			FROM %Table:SG1% SG1,
				 %Table:SB1% SB1
			WHERE SG1.G1_FILIAL  = %XFilial:SG1%
			AND SB1.B1_FILIAL  = %XFilial:SB1%
			AND SB1.B1_COD     = SG1.G1_COMP
			AND SG1.G1_COD     = %Exp:cCodPai%
			AND SG1.G1_INI    <= %Exp:cDataRef%
			AND SG1.G1_FIM    >= %Exp:cDataRef%
			AND SG1.G1_REVINI <= %Exp:cRevAtu%
			AND SG1.G1_REVFIM >= %Exp:cRevAtu%
			AND SG1.%NotDel%
			AND SB1.%NotDel%
			ORDER BY SG1.G1_COMP, SG1.G1_TRT
		EndSQL
	EndIf

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + cCodPai))
	cRotPai := SB1->B1_OPERPAD
	nQtBase := SB1->B1_QB
	
	If nQtBase == 0
		nQtBase := 1
	ENDIF


	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))

	dbSelectArea("SGF")
	SGF->(dbSetOrder(2))

	BeginSQL Alias cAliasSGF
		SELECT DISTINCT(GF_ROTEIRO)
		FROM %Table:SGF%
	 	WHERE GF_FILIAL	= %XFilial:SGF%
	   	AND GF_PRODUTO 	= %Exp:cCodPai%
	   	AND %NotDel%
    EndSQL

    Count To nCountRot

	(cAliasSGF)->(dbGoTop())

    If nCountRot == 1
    	cRotPai := (cAliasSGF)->GF_ROTEIRO
    EndIf

	While !(cAliasSG1)->(Eof())
		lValido := .T.

		If SG1->(MsSeek(xFilial("SG1")+(cAliasSG1)->G1_COMP))
			cNivelEstr := SG1->G1_NIV
		Else
			cNivelEstr := "99"
		EndIf

		// Itens vencidos?
		If MV_PAR07 = 1
			If cDataRef < ((cAliasSG1)->G1_INI) .Or. cDataRef > ((cAliasSG1)->G1_FIM)
				lValido := .F.
			EndIf
		EndIf

		cCargo := MontaCargo(cCodPai, (cAliasSG1)->G1_COMP, (cAliasSG1)->G1_TRT, (cAliasSG1)->B1_REVATU, cTipo)

		cFolderA  := If(lValido, VALIDO_A, INVALIDO_A)
		cFolderF  := If(lValido, VALIDO_F, INVALIDO_F)

		// Tipo Quantidade
		If (cAliasSG1)->G1_FIXVAR = "V"
			cFixVar = STR0008 // STR0008 - "Vari�vel"
		Else
			cFixVar = STR0009 // STR0009 - "Fixa"
		EndIf

		// Fantasma?
		If (cAliasSG1)->G1_FANTASM = "1"
			cFantasm = STR0006 // STR0006 - "Sim"
		Else
			cFantasm = STR0007 // STR0007 - "N�o"
		EndIf

		// Roteiro
		cRoteiro  := ""
		cOperacao := ""

		If Empty(MV_PAR02)
			If !Empty(cRotPai)
				SGF->(dbSeek(xFilial("SGF") + cCodPai + cRotPai + (cAliasSG1)->G1_COMP))
				If SGF->GF_PRODUTO == cCodPai .And. SGF->GF_COMP == (cAliasSG1)->G1_COMP .And. SGF->GF_ROTEIRO == cRotPai
					cRoteiro  := SGF->GF_ROTEIRO
					cOperacao := SGF->GF_OPERAC
				EndIf
			EndIf
		Else
			SGF->(dbSeek(xFilial("SGF") + cCodPai + MV_PAR02 + (cAliasSG1)->G1_COMP))
			If SGF->GF_PRODUTO == cCodPai .And. SGF->GF_COMP == (cAliasSG1)->G1_COMP .And. SGF->GF_ROTEIRO == MV_PAR02
				cRoteiro  := SGF->GF_ROTEIRO
				cOperacao := SGF->GF_OPERAC
			Else
				(cAliasSG1)->(dbSkip())
				Loop
			EndIf
		EndIf

		If cTipo == "TEMP"
			If Empty(MV_PAR04) .Or. AllTrim( (cAliasSG1)->B1_TIPO ) == AllTrim( MV_PAR04 )
				soDbTree:AddItem(" ", cCargo, cFolderA, cFolderF, , , 2)
				aAdd(saCargos, {cCargoPai, cCargo})
				Exit
			EndIf
		Else
			// Tipo do item ?
			If Empty(MV_PAR04) .Or. AllTrim( (cAliasSG1)->B1_TIPO ) == AllTrim( MV_PAR04 )
				cPrompt :=	(cAliasSG1)->G1_COMP 					   				+ ";" + ;
							(cAliasSG1)->B1_DESC 									+ ";" + ;
							(cAliasSG1)->B1_TIPO									+ ";" + ;
							(cAliasSG1)->B1_UM										+ ";" + ;
							(cAliasSG1)->G1_TRT										+ ";" + ;
							Transform((((cAliasSG1)->G1_QUANT * MV_PAR06)/nQtBase), cPicQuant)+ ";" + ;
							Transform((cAliasSG1)->G1_PERDA, cPicPerda)             + ";" + ;
							DToC(SToD((cAliasSG1)->G1_INI ))						+ ";" + ;
							DToC(SToD((cAliasSG1)->G1_FIM ))						+ ";" + ;
							cFixVar													+ ";" + ;
							(cAliasSG1)->G1_GROPC									+ ";" + ;
							(cAliasSG1)->G1_OPC 									+ ";" + ;
							(cAliasSG1)->G1_REVINI									+ ";" + ;
							(cAliasSG1)->G1_REVFIM									+ ";" + ;
							cNivelEstr												+ ";" + ;
							cFantasm												+ ";" + ;
							(cAliasSG1)->G1_LISTA									+ ";" + ;
							cRoteiro												+ ";" + ;
							cOperacao												+ ";" + ;
							(cAliasSG1)->G1_OBSERV
				IF !lAutoMacao
					soDbTree:AddItem(cPrompt, cCargo, cFolderA, cFolderF, , , 2)

					soDbTree:TreeSeek(cCargo)
					AddCmpTree(cCargo, "TEMP")
					aAdd(saCargos, {cCargoPai, cCargo})
					soDbTree:TreeSeek(cCargoPai)
				ENDIF
			EndIf
		EndIf

		(cAliasSG1)->(dbSkip())
	End

	(cAliasSG1)->(DbCloseArea())
	(cAliasSGF)->(DbCloseArea())

Return

/*/{Protheus.doc} P200TrataP
Fun��o para tratar os par�metros informados na Pergunta
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@return NIL
/*/
Static Function P200TrataP()
	// Data refer�ncia?
	If Empty(MV_PAR03)
		MV_PAR03 := dDataBase
	EndIf

	// Quantidade necess�ria?
	If Empty(MV_PAR06) .Or. MV_PAR06 <= 0
		MV_PAR06 := 1
	EndIf

Return

/*/{Protheus.doc} P200ValRot
Fun��o para validar se o item pertence ao roteiro informado no par�metro
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cProduto - C�digo do item
@return lRet
/*/
Static Function P200ValRot(cProduto)
	Local lRet := .F.

	// Roteiro?
	If Empty(MV_PAR02)
		lRet := .T.
	Else
		SGF->(dbSeek( xFilial("SGF") + cProduto + MV_PAR02 ))
		If !SGF->(Eof()) .And. SGF->GF_PRODUTO == cProduto .And. SGF->GF_ROTEIRO == MV_PAR02
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} MontaCargo
Monta o campo CARGO do registro
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCodPai 	- C�digo do item pai
@param 02 cComp		- C�digo do item componente
@param 03 cTRT 		- Sequencia do item
@param 04 cRevAtu	- Revis�o atual do item
@param 05 cTipo		- Indicador de tipo de registro:
					ESTR - Componente da estrutura
					TEMP - N� tempor�rio da tree, utilizado apenas para exibir a op��o de expandir o n�vel (+)
@return cCargo - Campo CARGO formatado com o padr�o do programa
/*/
Static Function MontaCargo(cCodPai,cComp,cTRT,cRevAtu,cTipo)
	Local cCargo := ""

	snSeqTree++

	cCargo := PadR(cCodPai , snTamCod)  + ;
	          PadR(cComp   , snTamComp) + ;
	          PadR(cTRT    , snTamTRT)  + ;
	          PadR(cRevAtu , snTamRev)  + ;
	          StrZero(snSeqTree, 9)     + ;
	          PadR(cTipo   , 4)

Return cCargo

/*/{Protheus.doc} RetInf
Extrai informa��es do  CARGO da Tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCargo - Cargo o qual as informa��es ser�o extra�das
@param 02 cInfo	 - Indica a informa��o a ser extra�da:
				 "IND"   - Indicador (IND_ESTR, IND_TEMP)
				 "PAI"   - Pai
				 "COMP"  - Componente
				 "RECNO" - Recno
				 "INDEX" - Index
				 "POS"   - Posi��o no array de controle (saCargos)
@return xRet - Informa��o solicitada
/*/
Static Function RetInf(cCargo, cInfo)
	Local xRet
	Local nStart   := 0
	Local nTamanho := 0

	Default cInfo := "COMP"

	If cInfo == "PAI"
		// Pai
		xRet := Left(cCargo, snTamCod)

	ElseIf cInfo == "COMP"
		// Componente
		nStart   := snTamCod + 1
		nTamanho := snTamComp
		xRet := Substr(cCargo, nStart, nTamanho)

	ElseIf cInfo == "TRT"
		// Sequencia
		nStart   := snTamCod + snTamComp + 1
		nTamanho := snTamTRT
		xRet := Substr(cCargo, nStart, nTamanho)

	ElseIf cInfo == "REV"
		// Revis�o
		nStart   := snTamCod + snTamComp + snTamTRT + 1
		nTamanho := snTamRev
		xRet := Substr(cCargo, nStart, nTamanho)

	ElseIf cInfo == "INDEX"
		// Index
		nStart   := snTamCod + snTamComp + snTamTRT + snTamRev + 1
		nTamanho := 9
		xRet := Val(Substr(cCargo, nStart, nTamanho))

	ElseIf cInfo == "TIPO"
		// Tipo
		nStart   := snTamCod + snTamComp + snTamTRT + snTamRev + 9 + 1
		nTamanho := 4
		xRet := Substr(cCargo, nStart, nTamanho)
	EndIf

Return xRet

/*/{Protheus.doc} Carregado
Extrai informa��es do Cargo da Tree
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@param 01 cCargo - Cargo o qual as informa��es ser�o extra�das
@return lExiste - Indica se o item j� foi carregado na tree
/*/
Static Function Carregado(cCargo)
	Local lExiste := .F.

	// Verifica no array saTreeLoad se este item j� foi carregado
	// Se j� foi adicionado na TREE, n�o faz a carga novamente
	If aScan(saTreeLoad,{|x| x==cCargo}) > 0
		lExiste := .T.
	Else
		aAdd(saTreeLoad,cCargo)
	EndIf

Return lExiste

/*/{Protheus.doc} TamPrompt
Indica o tamanho do Prompt conforme os campos
@author Carlos Alexandre da Silveira
@since 14/01/2019
@version 1.0
@return - Tamanho do Prompt
/*/
Static Function TamPrompt()

Return 	GetSx3Cache("G1_COD"    , "X3_TAMANHO") + ;
		GetSx3Cache("B1_DESC"   , "X3_TAMANHO") + ;
		GetSx3Cache("B1_TIPO"   , "X3_TAMANHO") + ;
		GetSx3Cache("B1_UM"     , "X3_TAMANHO") + ;
		GetSx3Cache("G1_TRT"    , "X3_TAMANHO") + ;
		GetSx3Cache("G1_QUANT"  , "X3_TAMANHO") + GetSx3Cache("G1_QUANT","X3_DECIMAL") + 1 + ;
		GetSx3Cache("G1_PERDA"  , "X3_TAMANHO") + GetSx3Cache("G1_PERDA","X3_DECIMAL") + 1 + ;
		GetSx3Cache("G1_INI"    , "X3_TAMANHO") + 2 + ;
		GetSx3Cache("G1_FIM"    , "X3_TAMANHO") + 2 + ;
		GetSx3Cache("G1_FIXVAR" , "X3_TAMANHO") + ;
		GetSx3Cache("G1_GROPC"  , "X3_TAMANHO") + ;
		GetSx3Cache("G1_OPC"    , "X3_TAMANHO") + ;
		GetSx3Cache("G1_REVINI" , "X3_TAMANHO") + ;
		GetSx3Cache("G1_REVFIM" , "X3_TAMANHO") + ;
		GetSx3Cache("G1_NIV"    , "X3_TAMANHO") + ;
		GetSx3Cache("G1_FANTASM", "X3_TAMANHO") + 2 + ;
		GetSx3Cache("G1_LISTA"  , "X3_TAMANHO") + ;
		GetSx3Cache("G1_OBSERV" , "X3_TAMANHO")

/*/{Protheus.doc} C200VldPrd
Valida o produto informado (par�metro MV_PAR01)
@author Marcelo Neumann
@since 07/03/2019
@version 1.0
@return lValido -  Indica se o produto digitado possui estrutura
/*/
Function C200VldPrd()

	Local lValido := .T.
	Default lAutoMacao := .F.

	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))
	If !SG1->(dbSeek(xFilial("SG1") + MV_PAR01))
		lValido := .F.
		IF !lAutoMacao
			Help( , , 'Help', ,   STR0018, ; //"N�o existe estrutura para esse produto."
				1, 0, , , , , , {STR0019})  //"Informe um produto que possua estrutura cadastrada."
		ENDIF
	EndIf

Return lValido
