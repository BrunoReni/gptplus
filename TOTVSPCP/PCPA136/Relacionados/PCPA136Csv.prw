#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA136.CH"

Static __lDicAtu := Nil

/*/{Protheus.doc} PCPA136Csv
Importa��o de Demandas via CSV
@type Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param oModel  , Objeto, Modelo de dados. Utilizado quando a importa��o � realizada dentro da edi��o das demandas.
@return lStatus, L�gico, Identifica se a importa��o foi executada ou n�o.
/*/
Function PCPA136Csv(oModel)

	Local aArea   := GetArea()
	Local lStatus := .F.

	If AbrePergun()
		//Executa a importa��o
		Processa({|| lStatus := ProcImport(oModel)}, STR0049, STR0050, .F.) //"Importando Demandas" - "Aguarde..."
	EndIf

	RestArea(aArea)

Return lStatus

/*/{Protheus.doc} PCPDirOpen
Fun��o da Consulta Padr�o 'PCPDIR' que abre janela para selecionar um arquivo
@type Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@return .T.
/*/
Function PCPDirOpen()

	Local cType    := STR0103 + " (*.csv) |*.csv|" //"Arquivo CSV"
	Local cArquivo := ""
	Default lAutoMacao := .F.

	IF !lAutoMacao
		cArquivo := cGetFile(cType, STR0102, , , .T.) //"Selecione o arquivo para importa��o"
	ENDIF

	If !Empty(cArquivo)
		MV_PAR01 := AllTrim(cArquivo)
	EndIf

Return .T.

/*/{Protheus.doc} PCPDirRet
Fun��o de retorno da Consulta Padr�o 'PCPDIR'
@type Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@return MV_PAR01, Caracter, Identifica se a importa��o foi executada ou n�o.
/*/
Function PCPDirRet()

Return MV_PAR01

/*/{Protheus.doc} ProcImport
Processa a importa��o do arquivo CSV
@type Static Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param oModel, Objeto, Modelo de dados. Se n�o for passado, ser� ativado sem view.
@return Nil
/*/
Static Function ProcImport(oModel)

	Local aError     := {}
	Local aLinhas    := {}
	Local aRegistro  := {}
	Local cDocum     := ""
	Local cMOpc      := ""
	Local cOpc       := ""
	Local cProduto   := ""
	Local cTipo      := ""
	Local dData      := ""
	Local lBrowse    := .F.
	Local lContinua  := .T.
	Local lErro      := .F.
	Local lImpArmz   := .T.
	Local nIndLin    := 1
	Local nLenGrid   := 0
	Local nLenReg    := 0
	Local nLinAtual  := 0
	Local nLinErro   := 0
	Local nQuant     := 0
	Local nTotal     := 0
	Local oFile      := FWFileReader():New(MV_PAR01)
	Local oModelErr  := Nil
	Local oModelGrid := Nil
	Default lAutoMacao := .F.

	//Se houver erro de abertura abandona processamento
	IF !lAutoMacao
		If !oFile:Open()
			Help(' ', 1, "Help", , STR0104, ; //"Falha na abertura do arquivo."
				2, 0, , , , , ,  {STR0105})  //"Verifique se o arquivo informado � v�lido."
			Return .F.
		EndIf
	ENDIF

	//Recupera todas as linhas do arquivo
	aLinhas := oFile:getAllLines()
	oFile:Close()
	FreeObj(oFile)

	nTotal := Len(aLinhas)
	If nTotal == 0
		Return .F.
	EndIf

	//Total da barra de progresso
	ProcRegua(nTotal)

	//Se n�o receber o modelo de dados, ativa na demanda posicionada no browse
	If oModel == Nil
		lBrowse := .T.
		oModel  := FWLoadModel("PCPA136")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		IF !lAutoMacao
			oModel:Activate()
		ENDIF
	EndIf

	oModelGrid := oModel:GetModel("SVR_DETAIL")

	//Inicia o modelo para listar os registros inconsistentes
	oModelErr  := FWLoadModel("PCPA136Imp")
	oModelErr:SetOperation(MODEL_OPERATION_INSERT)
	oModelErr:Activate()
	
	If P136ParExt("PCP136CSV", 9)
		lImpArmz := MV_PAR09 == 1
	EndIf

	//Percorre todas as linhas do arquivo
	For nIndLin := 1 To nTotal
		IncProc(STR0107 + cValToChar(nIndLin) + STR0108 + cValToChar(nTotal) + ".") //"Importando" "de"

		aSize(aRegistro, 0)
		aLinhas[nIndLin] := CorrigeLin(aLinhas[nIndLin])
		aRegistro        := StrTokArr(aLinhas[nIndLin], ";")
		nLenReg          := Len(aRegistro)

		If nLenReg > 0
			//Verifica se a linha atual est� v�lida
			If !oModelGrid:IsEmpty()
				nLenGrid  := oModelGrid:Length()
				nLinAtual := oModelGrid:AddLine()
				If nLinAtual == nLenGrid .And. nLinAtual <> nLinErro
					GravaLog(oModelErr, oModel)
					oModelGrid:DeleteLine(.T.,.T.)
				EndIf
			EndIf

			lErro := .F.

			//Tratamento para n�o abortar caso seja informada uma posi��o inexistente
			If MV_PAR02 <> 0 .And. nLenReg >= MV_PAR02
				cTipo := aRegistro[MV_PAR02]
			EndIf
			If !cTipo $ "12349"
				cTipo := '5'
			EndIf

			If nLenReg >= MV_PAR03
				cProduto := aRegistro[MV_PAR03]
			EndIf

			If nLenReg >= MV_PAR04
				If cPaisLoc # "EUA"
					nQuant := StrTran(aRegistro[MV_PAR04], ".", "" )
					nQuant := StrTran(aRegistro[MV_PAR04], ",", ".")
				EndIf
				nQuant := Val(nQuant)
			EndIf

			If MV_PAR05 <> 0 .And. nLenReg >= MV_PAR05 .And. !Empty(aRegistro[MV_PAR05])
				dData := CToD(aRegistro[MV_PAR05])
			Else
				dData := MV_PAR06
			EndIf

			If MV_PAR07 <> 0 .And. nLenReg >= MV_PAR07 .And. !Empty(aRegistro[MV_PAR07])
				cDocum := AllTrim(aRegistro[MV_PAR07])
			Else
				cDocum := MV_PAR08
			EndIf

			//Verifica se o valor pode ser atribu�do nos devidos campos
			//Data
			If Empty(dData)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0100) //"Data n�o informada."
				lErro := .T.
			Else
				If !oModelGrid:SetValue("VR_DATA", dData)
					GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData)
					lErro := .T.
				EndIf
			EndIf
			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Produto
			If Empty(cProduto)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0101) //"Produto n�o informado."
				lErro := .T.
			Else
				If !oModelGrid:SetValue("VR_PROD", cProduto)
					GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData)
					lErro := .T.
				EndIf
			EndIf
			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Quantidade
			If Empty(nQuant)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0109) //"Quantidade n�o informada."
				lErro := .T.
			Else
				If !oModelGrid:LoadValue("VR_QUANT", nQuant)
					GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData)
					lErro := .T.
				EndIf
			EndIf
			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Busca informa��es do Produto
			If !GetInfoPrd(cProduto, @cOpc, @cMopc)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0110) //"Produto n�o encontrado."
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf
 
			// Se par�metrizado para n�o importar o armaz�m padr�o na demadnda limpa o campo VR_LOCAL
			// Se importa o armaz�m padr�o deixa o valor preenchido pela trigger do campo VR_PROD
			If !lImpArmz
				oModelGrid:SetValue("VR_LOCAL", "")
			EndIf

			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Carrega demais informa��es
			oModelGrid:LoadValue("VR_TIPO"  , cTipo)
			oModelGrid:LoadValue("VR_DOC"   , cDocum)
			oModelGrid:LoadValue("VR_OPC"   , cOpc)
			oModelGrid:LoadValue("VR_MOPC"  , cMopc)
			oModelGrid:LoadValue("VR_REGORI", 0)
			If __lDicAtu
				oModelGrid:LoadValue("VR_ORIGEM", 'CSV')
			EndIf
		EndIf
	Next nIndLin

	//Se ocorreu algum erro alerta o usu�rio e abre a tela de registros inconsistentes
	If nLinErro > 0
		oModelGrid:VldData()

		Help(' ',1,"Help",,STR0055,2,0,,,,,,) //"Alguns registros n�o ser�o importados pois n�o atendem todos os crit�rios de valida��o deste programa."

		oModelErr:nOperation := MODEL_OPERATION_VIEW
		FWExecView(STR0071             , ; //Titulo da janela - "Registros inconsistentes"
				   'PCPA136Imp'        , ; //Nome do programa-fonte
				   MODEL_OPERATION_VIEW, ; //Indica o c�digo de opera��o
				   NIL                 , ; //Objeto da janela em que o View deve ser colocado
				   NIL                 , ; //Bloco de valida��o do fechamento da janela
				   NIL                 , ; //Bloco de valida��o do bot�o OK
				   55                  , ; //Percentual de redu��o da janela
				   NIL                 , ; //Bot�es que ser�o habilitados na janela
				   NIL                 , ; //Bloco de valida��o do bot�o Cancelar
				   NIL                 , ; //Identificador da op��o do menu
				   NIL                 , ; //Indica o relacionamento com os bot�es da tela
				   oModelErr)              //Model que ser� usado pelo View

		If lBrowse
			lContinua := MsgYesNo(STR0073,STR0072) //"Deseja importar os registros v�lidos?" - "Continuar a importa��o?"
		EndIf
	EndIf

	If lContinua
		If lBrowse
			IF !lAutoMacao
				If !oModel:VldData( ,.T.) .Or. !oModel:CommitData()
					aError := oModel:GetErrorMessage()
					Help(' ', 1, "Help", , aError[MODEL_MSGERR_MESSAGE], 1, 0, , , , , ,  {aError[MODEL_MSGERR_SOLUCTION]})
					aSize(aError, 0)
					aError := Nil
				EndIf

				oModel:DeActivate()
			ENDIF
		Else
			oModelGrid:GoLine(1)
		EndIf
	EndIf

	//Limpa os arrays da mem�ria
	aSize(aRegistro, 0)
	aRegistro := Nil
	aSize(aLinhas, 0)
	aLinhas := Nil

Return

/*/{Protheus.doc} GravaLog
Grava o modelo de Log de importa��o com o erro ocorrido
@type Static Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param 01 oModelErr, Objeto  , Modelo onde ser�o gravados os registros n�o importados
@param 02 oModel   , Objeto  , Modelo principal
@param 03 cTipo    , Caracter, Tipo de demanda
@param 04 cProduto , Caracter, C�digo do produto
@param 05 nQuant   , Num�rico, Quantidade da demanda
@param 06 dData    , Caracter, Data da demanda
@return Nil
/*/
Static Function GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, cMsgErro)

	Local aError     := oModel:GetErrorMessage()
	Default cTipo    := oModel:GetModel("SVR_DETAIL"):GetValue("VR_TIPO")
	Default cProduto := oModel:GetModel("SVR_DETAIL"):GetValue("VR_PROD")
	Default nQuant   := oModel:GetModel("SVR_DETAIL"):GetValue("VR_QUANT")
	Default dData    := oModel:GetModel("SVR_DETAIL"):GetValue("VR_DATA")
	Default cMsgErro := ""
	Default lAutoMacao := .F.

	IF !lAutoMacao
		If !oModelErr:GetModel("GRID_LOG"):IsEmpty()
			oModelErr:GetModel("GRID_LOG"):AddLine()
		EndIf
	ENDIF

	If Empty(cMsgErro)
		cMsgErro := AllTrim(aError[MODEL_MSGERR_MESSAGE])
	EndIf

	IF !lAutoMacao
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_TIPO" , cTipo)
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_PROD" , cProduto)
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_QUANT", nQuant)
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_DATA" , dData)
		oModelErr:GetModel("GRID_LOG"):LoadValue("CMOTIVO" , cMsgErro)
	ENDIF

Return

/*/{Protheus.doc} GetInfoPrd
Grava o modelo de Log de importa��o com o erro ocorrido
@type Static Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param 01 cProduto, Caracter, C�digo do produto
@param 02 cOpc    , Caracter, C�digo do opcional (retorna por refer�ncia)
@param 03 cMopc   , Caracter, Memo do opcional (retorna por refer�ncia)
@return lExiste, L�gico, Indica se o produto foi encontrado na SB1
/*/
Static Function GetInfoPrd(cProduto, cOpc, cMopc)

	Local aAreaB1 := SB1->(GetArea())
	Local lExiste := .F.

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1") + cProduto))
		cOpc    := SB1->B1_OPC
		cMopc   := SB1->B1_MOPC
		lExiste := .T.
	EndIf
	SB1->(RestArea(aAreaB1))

Return lExiste

/*/{Protheus.doc} CorrigeLin
Corrige a linha para a utiliza��o do StrTokArr
@type Static Function
@author marcelo.neumann
@since 06/04/2020
@version P12
@param  cLinha, Caracter, Linha a ser corrigida
@return cLinha, Caracter, Linha corrigida
/*/
Static Function CorrigeLin(cLinha)

	cLinha := StrTran(cLinha, ";;", "; ;")
	cLinha := StrTran(cLinha, ";;", "; ;")

	If SubStr(cLinha,1,1) == ";"
		cLinha := " " + cLinha
	EndIf

Return cLinha

/*/{Protheus.doc} AbrePergun
Abre a tela com os par�metros para importa��o
@type Static Function
@author marcelo.neumann
@since 31/08/2020
@version P12
@return lStatus, L�gico, Indica se a tela de Pergunte foi confirmada
/*/
Static Function AbrePergun()

	Local lStatus := .F.
	Default lAutoMacao := .F.
/*
	Valores do pergunte PCP136IMP:
	MV_PAR01 - Diret�rio
	MV_PAR02 - Posi��o Tipo
	MV_PAR03 - Posi��o Produto
	MV_PAR04 - Posi��o Quantidade
	MV_PAR05 - Posi��o Data Previs�o
	MV_PAR06 - Data Previs�o
	MV_PAR07 - Posi��o Documento
	MV_PAR08 - Documento
	MV_PAR09 - Utiliza armaz�m padr�o
*/
	If ExistePerg()
		IF !lAutoMacao
			While Pergunte("PCP136CSV")
				If ParamOk()
					lStatus := .T.
					Exit
				EndIf
			End
		ENDIF
	Else
		lStatus := InformaPar()
	EndIf

Return lStatus


/*/{Protheus.doc} ExistePerg
Verifica se o dicion�rio de dados est� atualizado com a Pergunta da importa��o CSV
@type Static Function
@author lucas.franca
@since 03/08/2020
@version P12
@return lRet, L�gico, Indica se a op��o de importa��o CSV dever� utilizar a Pergunte do dicion�rio
/*/
Static Function ExistePerg()
	Local lRet   := .T.
	Local oPergs := Nil

	If __lDicAtu == Nil
		oPergs := FwSX1Util():New()
		oPergs:AddGroup("PCP136CSV")
		oPergs:SearchGroup()
		__lDicAtu := Len(oPergs:GetGroup("PCP136CSV")[2]) > 0

		FreeObj(oPergs)
	EndIf

	lRet := __lDicAtu

Return lRet

/*/{Protheus.doc} InformaPar
Abre tela para informar os par�metros de processamento (quando n�o possui a Pergunte no dicion�rio)
@type Static Function
@author marcelo.neumann
@since 31/08/2020
@version P12
@return lRet, L�gico, Indica se os par�metros foram informados
/*/
Static Function InformaPar()

	Local aRet       := {}
	Local aParamBox  := {}
	Local lObrigaTip := !__lDicAtu
	Local lRet       := .F.
	Default lAutoMacao := .F.

	aAdd(aParamBox, {6, STR0112, Space(99)     , "" ,     "", "",  80, .T., STR0103 + " (*.csv) |*.csv|"}) //"Diret�rio" - "Arquivo CSV"
	aAdd(aParamBox, {1, STR0113, 0             , "9",   , "", "",  20, lObrigaTip}) //"Posi��o Tipo"
	aAdd(aParamBox, {1, STR0114, 0             , "9",   , "", "",  20, .T.}) //"Posi��o Produto"
	aAdd(aParamBox, {1, STR0115, 0             , "9",   , "", "",  20, .T.}) //"Posi��o Quantidade"
	aAdd(aParamBox, {1, STR0116, 0             , "9",   , "", "",  20, .F.}) //"Posi��o Data"
	aAdd(aParamBox, {1, STR0117, CToD(Space(8)), "" , "", "", "",  50, .F.}) //"Data"
	aAdd(aParamBox, {1, STR0118, 0             , "9",   , "", "",  20, .F.}) //"Posi��o Documento"
	aAdd(aParamBox, {1, STR0119, Space(30)     , "" , "", "", "", 100, .F.}) //"Documento"

	IF !lAutoMacao
		If ParamBox(aParamBox, STR0120, @aRet, {|| ParamOk()}, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, "PCPA136CSV", .T., .F.) //"Par�metros -"
			lRet := .T.
		EndIf
	ENDIF

Return lRet

/*/{Protheus.doc} ParamOk
Valida os par�metros para processamento
@type Static Function
@author marcelo.neumann
@since 31/08/2020
@version P12
@return lRet, L�gico, Indica se os par�metros est�o v�lidos
/*/
Static Function ParamOk()

	Local lRet := .F.

	If Empty(MV_PAR03) .Or. MV_PAR03 == 0
		Help(' ', 1, "Help", , STR0094, ; //"N�o foi informada a posi��o do produto no arquivo."
			 2, 0, , , , , ,  {STR0095})  //"Informe a posi��o do produto no arquivo."

	ElseIf Empty(MV_PAR04) .Or. MV_PAR04 == 0
		Help(' ', 1, "Help", , STR0096, ; //"N�o foi informada a posi��o da quantidade no arquivo."
			 2, 0, , , , , ,  {STR0097})  //"Informe a posi��o da quantidade no arquivo."

	ElseIf Empty(MV_PAR05) .And. Empty(MV_PAR06)
		Help(' ', 1, "Help", , STR0098, ; //"N�o foi informada a data ou a posi��o da data no arquivo."
			 2, 0, , , , , ,  {STR0099})  //"Informe a data a ser utilizada ou a posi��o da data no arquivo."
	Else
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} validaPar
Verifica se um par�metro esta presente no grupo de perguntas.
@type  Function
@author Lucas Fagundes
@since 17/02/2023
@version P12
@param 01 cGrupoPerg, Caracter, Nome do grupo de perguntas.
@param 02 nParam    , Numerico, Posi��o do par�metro no grupo de perguntas.
@return lRet, Logico, Indica que o par�metro existe.
/*/
Function P136ParExt(cGrupoPerg, nParam)
	Local lRet     := .F.
	Local oSx1Util := FwSX1Util():New()

	oSx1Util:addGroup(cGrupoPerg)
	oSx1Util:searchGroup()
	
	If Len(oSx1Util:getGroup(cGrupoPerg)[2]) >= nParam
		lRet := .T.
	EndIf

	FwFreeObj(oSx1Util)
Return lRet
