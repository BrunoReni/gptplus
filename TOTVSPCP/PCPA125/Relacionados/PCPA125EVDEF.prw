#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA125.CH"

#DEFINE CAMPOS_DESCRICAO "|D3_CODDSC|H6_PROEDSC|CYV_CDACSC|C2_PRODESC|"
#DEFINE CAMPOS_VISIVEIS_OP "|C2_PRODUTO|C2_QUANT|C2_DATPRI|C2_DATPRF|"
Static _lLoadData := .F.

/*/{Protheus.doc} PCPA125EVDEF
//EVENTOS PCPA125
@author Thiago Zoppi
@since 12/05/2018
/*/
CLASS PCPA125EVDEF FROM FWModelEvent

	DATA lPossuiSMJ AS Logic
	DATA lPossuiHWX AS Logic
	DATA lPossuiSMC AS Logic

	METHOD New() CONSTRUCTOR

	METHOD Activate(oModel, lCopy)
	METHOD BeforeTTS(oModel, cModelId)
	METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
	METHOD InTTS(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
	METHOD GridLinePosVld()

ENDCLASS

METHOD New() CLASS  PCPA125EVDEF
	Self:lPossuiSMJ := AliasInDic("SMJ")
	Self:lPossuiHWX := AliasInDic("HWS")
	Self:lPossuiSMC := AliasInDic("SMC")
Return

/*/{Protheus.doc} Activate
//Método que é chamado pelo MVC quando ocorrer a ativação do Model.
@author tp.thiago.zoppi
@since 15/05/2018
/*/
METHOD Activate(oModel, lCopy) CLASS PCPA125EVDEF
	Local oModelSMC  := oModel:getModel("DETAIL_SMC")
	Local oModelSOY  := oModel:getModel("DETAIL_SOY")

	If oModel:getOperation() == MODEL_OPERATION_UPDATE  // NÃO DEIXA APAGAR E INSERIR NOVAS LINHA
		//Habilita inclusão de novas linhas.
		oModelSOY:SetNoDeleteLine(.F.)
		oModelSOY:SetNoInsertLine(.F.)

		addNewReg(oModel)
		
		//Desabilita inclusão de novas linhas.
		oModelSOY:SetNoDeleteLine(.T.)
		oModelSOY:SetNoInsertLine(.T.)
	Else
		oModelSOY:SetNoDeleteLine(.F.)
		oModelSOY:SetNoInsertLine(.F.)
	EndIf

	If Self:lPossuiSMJ .And. ;
	   (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		cargaSMJ(oModel)
	EndIf

	If Self:lPossuiSMC .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE 
		//Se o formulário existia antes da criação da SMC, faz a carga dos registros
		If oModelSMC:Length() <= 1
			cargaSMC(oModel, oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON"))
		ElseIf oModelSMC:Length() <= 20 .And. oModelSMC:HasField("MC_TABELA") //Se o formulário existia antes da criação dos campos do tipo lista
			updateSMC(oModel, oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON"))
		EndIf

		loadSMCEmp(oModelSMC,oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON"))
	EndIf

Return .T.

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.

@type  METHOD
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel  , Object   , Referência do modelo de dados
@param cModelId, Character, ID do submodelo.
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS PCPA125EVDEF
	Local cIdForm    := ""
	Local cVisual    := ""
	Local cInclui    := ""
	Local cAltera    := ""
	Local cExclui    := ""
	Local nIndex     := 0
	Local nTotal     := 0
	Local oMdlSMJ    := Nil
	Local oMdlPermis := Nil

	If Self:lPossuiSMJ .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
		//Atualiza as informações de permissões do modelo DETAIL_SMJ, com as informações existentes no modelo SMJ_PERMISSAO
		cIdForm    := oModel:GetModel("OXMASTER"):GetValue("OX_FORM")
		oMdlSMJ    := oModel:GetModel("DETAIL_SMJ")
		oMdlPermis := oModel:GetModel("SMJ_PERMISSAO")

		cVisual    := oMdlPermis:GetValue("MJ_VISUAL")
		cInclui    := oMdlPermis:GetValue("MJ_INCLUI")
		cAltera    := oMdlPermis:GetValue("MJ_ALTERA")
		cExclui    := oMdlPermis:GetValue("MJ_EXCLUI")

		nTotal := oMdlSMJ:Length()
		For nIndex := 1 To nTotal
			oMdlSMJ:GoLine(nIndex)

			oMdlSMJ:SetValue("MJ_CODFORM", cIdForm)
			oMdlSMJ:SetValue("MJ_VISUAL" , cVisual)
			oMdlSMJ:SetValue("MJ_INCLUI" , cInclui)
			oMdlSMJ:SetValue("MJ_ALTERA" , cAltera)
			oMdlSMJ:SetValue("MJ_EXCLUI" , cExclui)

		Next nIndex
	EndIf
Return Nil

/*/{Protheus.doc} FieldPreVld
//Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field

@author tp.thiago.zoppi
@since 15/05/2018
@version 1.0
/*/
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS PCPA125EVDEF
	Local aCampSOY	 := {}
	Local aCamposADD := {}
	Local cDescFld   := ""
	Local cVisivel   := ""
	Local cEdita     := ""
	Local lRet		 := .T.
	Local nX		 := 0
	Local nLinha	 := 1
	Local nTamHeader := 0
	Local nIndex     := 0
	Local nTotal     := 0
	Local oModel	 := FWModelActive()
	Local oModelSOY	 := oModel:GetModel("DETAIL_SOY")
	Local oMdlSMJ    := Nil

	If (cAction == 'UNDELETE' .Or. cAction == 'SETVALUE' ) .And. cId == 'OX_PRGAPON'
		If Self:lPossuiSMC
			cargaSMC(oModel, xValue)
		EndIf

		oModelSOY:SetNoInsertLine(.F.)
		oModelSOY:SetNoDeletetLine(.F.)

		If oModelSOY:Length() > 1
			//Apaga todas a linhas da grid
			For nX := 1 to oModelSOY:Length()
				oModelSOY:GoLine(nX)
				oModelSOY:DeleteLine(.T.,.T.)
			Next nX

			//LIMPAR LINHAS DELETAS, NAO DEIXANDO LINHAS CINZAS NA GRID
			nTamHeader	:= LEN(oModelSOY:aHeader)
			oModelSOY:GoLine(1)
			ASIZE(oModelSOY:aDataModel, 1)
			ASIZE(oModelSOY:aCols, 1)

			For nX := 1 To nTamHeader
				oModel:ClearField('DETAIL_SOY' , oModelSOY:aHeader[nX][2])
			Next nX

			//AddLine Força um refresh no grid, os aSizes removem a nova linha em branco.
			oModelSOY:AddLine()
			ASIZE(oModelSOY:aDataModel, 1)
			ASIZE(oModelSOY:aCols, 1)

			oModelSOY:GoLine(1)
			oModelSOY:UnDeleteLine() // sempre fica uma linha deletada na grid, entao retiramos o delete;
		EndIf

		If xValue == "1" //CAMPOS DA ROTINA MATA250
			aCamposADD := {"D3_TM"     , "D3_COD"    , "D3_CODDSC" , "D3_UM"     , "D3_QUANT"  ,;
						   "D3_CONTA"  , "D3_OP"     , "D3_LOCAL"  , "D3_DOC"    , "D3_EMISSAO",;
						   "D3_CC"     , "D3_PARCTOT", "D3_SEGUM"  , "D3_QTSEGUM", "D3_PERDA"  ,;
						   "D3_LOTECTL", "D3_DTVALID", "D3_POTENCI", IIF(IntWms(), "D3_SERVIC",'')}

		ElseIf xValue == "2" //CAMPOS DA ROTINA MATA680
			aCamposADD := {"H6_OP"     , "H6_PRODUTO", "H6_OPERAC" , "H6_RECURSO", "H6_FERRAM" ,;
						   "H6_DATAINI", "H6_HORAINI", "H6_DATAFIN", "H6_HORAFIN", "H6_QTDPROD",;
						   "H6_QTDPERD", "H6_PT"     , "H6_DTAPONT", "H6_DESDOBR", "H6_TEMPO"  ,;
						   "H6_LOTECTL", "H6_NUMLOTE", "H6_DTVALID", "H6_OPERADO", "H6_SEQ"    ,;
						   "H6_QTDPRO2", "H6_POTENCI", "H6_RATEIO" , "H6_LOCAL"}

		ElseIf xValue == "3" //CAMPOS DA ROTINA MATA681
			aCamposADD := {"H6_OP"     , "H6_PRODUTO", "H6_PROEDSC", "H6_OPERAC" , "H6_RECURSO",;
						   "H6_FERRAM" , "H6_DATAINI", "H6_HORAINI", "H6_DATAFIN", "H6_HORAFIN",;
						   "H6_QTDPROD", "H6_QTDPERD", "H6_PT"     , "H6_DTAPONT", "H6_DESDOBR",;
						   "H6_TEMPO"  , "H6_LOTECTL", "H6_NUMLOTE", "H6_DTVALID", "H6_OBSERVA",;
						   "H6_OPERADO", "H6_SEQ"    , "H6_QTDPRO2", "H6_POTENCI", "H6_RATEIO" , "H6_LOCAL"}

		ElseIf xValue == "4"
			aCamposADD := {'CYV_CDMQ'  ,'CYV_NRORPO','CYV_IDATQO','CYV_CDAT','CYV_CDACRP','CYV_CDACSC',;
						   'CYV_DTBGSU','CYV_HRBGSU','CYV_DTEDSU','CYV_HREDSU','CYV_CDSU','CYV_QTATAP',;
						   'CYV_DTRPBG','CYV_HRRPBG','CYV_DTRPED','CYV_HRRPED','CYV_CDTN','CYV_NRDO'  ,;
						   'CYV_NRSR'  ,'CYV_CDDP'  ,'CYV_CDLOSR','CYV_DTVDLO','CYW_CDOE','CYW_CDGROE','CZ0_CDFE'}

		ElseIf xValue == "5" //CAMPO DA ROTINA MATA250 SEM O CAMPO D3_OP
			aCamposADD := {"D3_TM"     , "D3_COD"    , "D3_UM"     , "D3_QUANT"  , "D3_CONTA",;
						   "D3_LOCAL"  , "D3_DOC"    , "D3_EMISSAO", "D3_CC"     , "D3_PARCTOT",;
						   "D3_SEGUM"  , "D3_QTSEGUM", "D3_PERDA"  , "D3_LOTECTL", "D3_DTVALID",;
						   "D3_POTENCI",IIF(IntWms(),"D3_SERVIC",'')}
		ElseIf xValue == "6"
			aCamposADD := { "C2_PRODUTO", "C2_PRODESC", "C2_LOCAL" , "C2_CC"     , "C2_QUANT",;
							"C2_UM"     , "C2_DATPRI" , "C2_DATPRF", "C2_OBS"    , "C2_EMISSAO",;
							"C2_PRIOR"  , "C2_STATUS" , "C2_SEGUM" , "C2_QTSEGUM", "C2_ROTEIRO",;
							"C2_PEDIDO" , "C2_ITEMPV" , "C2_TPOP"  , "C2_REVISAO", "C2_ITEMCTA",;
							"C2_CLVL"   , "C2_SEQMRP" , "C2_LINHA" , "C2_PROGRAM", "C2_DIASOCI",;
							"C2_OPTERCE", "C2_TPPR" }
		EndIf

		For nX := 1 to Len(aCamposADD)
			If !Empty(aCamposADD[nX])
				If "|" + aCamposADD[nX] + "|" $ CAMPOS_DESCRICAO
					cDescFld := STR0034 //"Descrição do produto"
				Else
					cDescFld := FWSX3Util():GetDescription(aCamposADD[nX])
				EndIf
				Aadd(aCampSOY,{aCamposADD[nX], cDescFld})
			EndIf
		Next

		//Variável de controle para não executar validações de WHEN da SOY.
		_lLoadData := .T.
		For nX := 1 To Len(aCampSOY)
			If !Empty(oModelSOY:GetValue("OY_CAMPO"))
				oModelSOY:AddLine()
			EndIf

			If "|" + aCampSOY[nx][1] + "|" $ CAMPOS_DESCRICAO
				cEdita   := "2"
				If xValue == "4"
					cVisivel := "1"
				Else
					cVisivel := "2"
				EndIf
			Else
				cEdita   := "1"
				cVisivel := "1"
			EndIf

			If xValue == "6"
				If !(aCampSOY[nx][1] $ CAMPOS_VISIVEIS_OP)
					cVisivel := "2"
				EndIf
			EndIf

			oModelSOY:SetValue("OY_CAMPO"  , aCampSOY[nx][1])
			oModelSOY:SetValue("OY_DESCAMP", aCampSOY[nx][2])
			oModelSOY:SetValue("OY_CODBAR" , '2')
			oModelSOY:SetValue("OY_VISIVEL", cVisivel)
			oModelSOY:SetValue("OY_EDITA"  , cEdita)
			oModelSOY:SetValue("OY_VALPAD" ,  "")
		Next nX
		_lLoadData := .F.

		If oModelSOY:Length() > 0
			oModelSOY:goLine(nLinha)
		EndIf

		If Self:lPossuiSMJ .And. cAction == 'SETVALUE' .And. xValue $ "|1|5|"
			oMdlSMJ := oModel:GetModel("DETAIL_SMJ")
			nTotal := oMdlSMJ:Length()
			For nIndex := 1 To nTotal
				If AllTrim(oMdlSMJ:GetValue("MJ_CAMPO", nIndex)) == "D4_OPERAC"
					If oMdlSMJ:GetValue("MJ_EDITA", nIndex) == "1"
						nLinha := oMdlSMJ:GetLine()
						oMdlSMJ:GoLine(nIndex)
						oMdlSMJ:LoadValue("MJ_EDITA", "2")
						oMdlSMJ:ClearField("MJ_VALPAD")
						oMdlSMJ:GoLine(nLinha)
					EndIf
					Exit
				EndIf
			Next nIndex
		EndIf

		oModelSOY:SetNoDeletetLine(.T.) //Bloqueia exclusao de linhas
		oModelSOY:SetNoInsertLine(.T.) //Bloqueia inclusão de linhas
	EndIf

Return lRet

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.

@type  METHOD
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel  , Object   , Referência do modelo de dados
@param cModelId, Character, ID do submodelo.
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA125EVDEF
	Local cCdMq      := ""
	Local cFormular  := ""
	Local nOperation := oModel:GetOperation()
	Local nI         := 0
	Local oHWS       := Nil

	If Self:lPossuiHWX
		cFormular := oModel:GetModel("OXMASTER"):GetValue("OX_FORM")
		oHWS      := oModel:GetModel('DETAIL_HWS')

		HWS->(dbSetOrder(1))

		For nI := 1 To oHWS:Length()
			cCdMq := oHWS:GetValue("HWS_CDMQ", nI)

			If HWS->(dbSeek(xFilial("HWS")+cFormular+cCdMq))
				If nOperation == MODEL_OPERATION_DELETE .Or. !oHWS:GetValue("MARCA", nI)
					RecLock("HWS",.F.)
					HWS->(dbDelete())
					HWS->(MsUnlock())
				EndIf
			ElseIf oHWS:GetValue("MARCA", nI)
				RecLock("HWS",.T.)
				HWS->HWS_FILIAL := xFilial('HWS')
				HWS->HWS_FORM   := cFormular
				HWS->HWS_CDMQ   := cCdMq
				HWS->(MsUnlock())
			EndIf
		Next nI
	EndIf

Return Nil

/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model

@type  METHOD
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel  , Object   , Referência do modelo de dados
@param cModelId, Character, ID do submodelo.
@return lRet, Logic, Retorno se o modelo está válido
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA125EVDEF
	Local cProgApont := oModel:GetModel("OXMASTER"):GetValue("OX_PRGAPON")
	Local lRet       := .T.
	Local nI         := 0
	Local nOperation := oModel:GetOperation()
	Local oMdlHWS    := Nil
	Local oMdlPermis := Nil
	Local oMdlSMJ    := Nil

	If Self:lPossuiHWX
		oMdlHWS := oModel:GetModel('DETAIL_HWS')
		If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. cProgApont == '4'
			lRet := .F.
			For nI := 1 To oMdlHWS:Length()
				If oMdlHWS:GetValue("MARCA", nI)
					lRet := .T.
					Exit
				EndIf
			Next

			If !lRet
				Help(' ',1,"Help" ,,STR0014,; //"Nenhuma Máquina foi selecionada."
			         2,0,,,,,,{STR0015}) //"Deverá ser selecionada pelo menos uma máquina."
			EndIf
		EndIf
	EndIf

	If Self:lPossuiSMJ .And. lRet
		oMdlPermis := oModel:GetModel("SMJ_PERMISSAO")
		oMdlSMJ    := oModel:GetModel("DETAIL_SMJ")

		If oMdlPermis:GetValue("MJ_VISUAL") == "2" .And. ;
		   (oMdlPermis:GetValue("MJ_INCLUI") == "1" .Or. ;
		    oMdlPermis:GetValue("MJ_ALTERA") == "1" .Or. ;
		    oMdlPermis:GetValue("MJ_EXCLUI") == "1")

			Help(' ', 1, "Help",, STR0027,; //"Permissão de visualização de empenhos inválida."
			     2, 0, , , , , , {STR0028}) //"Quando as permissões de Inclusão, Alteração ou Exclusão estão selecionadas como Sim, a permissão de Visualização deve possuir conteúdo Sim. Ajuste as permissões na aba 'Empenhos'."
			lRet := .F.
		EndIf

		If lRet
			If cProgApont == '6'
				oMdlSMJ:ClearData(.T., .F.)
				oMdlPermis:ClearData(.T., .F.)
			EndIf
		EndIf

	EndIf
Return lRet

/*/{Protheus.doc} GridLinePosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação da linha do Grid
@author renan.roeder
@since 03/11/2021
@version 1.0
@param 01 oSubModel    , Objeto  , Modelo principal
@param 02 cModelId     , Caracter, Id do submodelo
@param 03 nLine        , Numérico, Linha do grid
@return lOK
/*/
METHOD GridLinePosVld(oSubModel, cModelID, nLine) CLASS PCPA125EVDEF
	Local lRet      := .T.
	Local cCampo    := ""	
	Local cTabela   := ""
	Local cTipo     := ""
	Local cValPad   := ""
	Local aDadosSX5 := {}

	If cModelID == "DETAIL_SMC"
		If oSubModel:HasField("MC_TABELA")
			If "CustomFieldList" $ oSubModel:GetValue("MC_TIPO", nLine)
				cTabela := AllTrim(oSubModel:GetValue("MC_TABELA", nLine))
				cValPad := RTrim(oSubModel:GetValue("MC_VALPAD", nLine))
				cCampo  := AllTrim(oSubModel:GetValue("MC_CAMPO", nLine))
				If Empty(cTabela) .And. !Empty(cValPad)
						Help(' ',1,"Help" ,,STR0035 + STR0038,; //"O Valor Padrão não está vinculado a uma Tabela."
							2,0,,,,,,{STR0039}) //"Informe a tabela para estabelecer o Valor Padrão da lista."
						lRet := .F.
				ElseIf !Empty(cTabela) .And. !Empty(cValPad)
					aDadosSX5 := FWGetSX5(cTabela, cValPad)
					If Len(aDadosSX5) == 0
						Help(' ',1,"Help" ,,STR0035 + "'" + cValPad + "'" + STR0036 + "'" + cTabela + "'.",; //"O Valor Padrão '" + cValPad + "' não pertence a Tabela '" + cTabela + "'."
							2,0,,,,,,{STR0037}) //"O Valor Padrão deve pertencer a tabela selecionada."
						lRet := .F.
					EndIf
				EndIf
				If lRet 
					cTipo := GetSX3Cache(cCampo,"X3_TIPO")
					If !Empty(cTipo) .And. cTipo != "C"
						Help(' ',1,"Help" ,,STR0049 + "'" + cCampo + "'" + STR0050,; //"O campo " + cCampo + " não é do tipo caracter."
							2,0,,,,,,{STR0051}) //"Informe um campo do tipo caracter para receber a informação da lista."
						lRet := .F.
					EndIf
				EndIf				
			EndIf
		EndIf
		If lRet .And. oSubModel:HasField("TPFORM")
			lRet := validCampo(oSubModel, nLine)
		EndIf
	EndIf

Return lRet

Function validCampo(oSubModel, nLine)
	Local lRet      := .T.
	Local cAliasInp := SUBSTR(oSubModel:GetValue("MC_CAMPO",nLine),1,aT("_",oSubModel:GetValue("MC_CAMPO",nLine)))
	Local cAliasVal := ""
	Local cPrgApon  := oSubModel:GetModel():GetValue("OXMASTER", "OX_PRGAPON")
	Local cTpForm   := AllTrim(oSubModel:GetValue("TPFORM",nLine))

	If cTpForm == STR0042 //"Empenho"
		cAliasVal := "D4_"
		If cAliasInp != cAliasVal
			lRet := .F.
		EndIf
	ElseIf cTpForm == STR0043 //"Apontamento"
		If (cPrgApon == "1" .Or. cPrgApon == "5")
			cAliasVal := "D3_"
			If cAliasInp != cAliasVal
				lRet := .F.
			EndIf
		ElseIf (cPrgApon == "2" .Or. cPrgApon == "3")
			cAliasVal := "H6_"
			If cAliasInp != cAliasVal
				lRet := .F.
			EndIf
		ElseIf cPrgApon == "4"
			cAliasVal := "CYV_"
			If cAliasInp != cAliasVal
				lRet := .F.
			EndIf
		EndIf
	ElseIf cTpForm == STR0044 //"Cadastro OP"
		cAliasVal := "C2_"
		If cAliasInp != cAliasVal
			lRet := .F.
		EndIf	
	EndIf
	If !lRet
		Help(' ',1,"Help" ,,STR0045,; //"Foi atribuido valor incorreto ao atributo 'Campo'."
			2,0,,,,,,{STR0046 + "'"+cAliasVal+"'."}) //"O valor deve ter o prefixo "
	EndIf

Return lRet

/*/{Protheus.doc} cargaSMJ
Carrega os dados da tabela SMJ

@type  Static Function
@author lucas.franca
@since 02/03/2021
@version P12
@param oModel, Object, Referência do modelo de dados
@return Nil
/*/
Static Function cargaSMJ(oModel)
	Local oMdlSMJ    := oModel:GetModel("DETAIL_SMJ")
	Local oMdlPermis := oModel:GetModel("SMJ_PERMISSAO")

	If oMdlSMJ:IsEmpty()

		oMdlPermis:setValue("MJ_VISUAL", "1")
		oMdlPermis:setValue("MJ_INCLUI", "2")
		oMdlPermis:setValue("MJ_ALTERA", "2")
		oMdlPermis:setValue("MJ_EXCLUI", "2")

		//Remove restrições de modificação do modelo da SMJ
		A125PropMJ(oMdlSMJ, oMdlSMJ:GetStruct(), "REMOVER")

		//Adiciona os valores padrões na grid da tabela SMJ
		addGridSMJ(oMdlSMJ)

		//Adiciona novamente as restrições de modificação do modelo da SMJ
		A125PropMJ(oMdlSMJ, oMdlSMJ:GetStruct(), "ADICIONAR")
	EndIf
Return Nil

/*/{Protheus.doc} addGridSMJ
Retorna os valores default do formulário de empenhos

@type  Static Function
@author lucas.franca
@since 03/03/2021
@version P12
@param oModel, Object, Referência do modelo de dados da SMJ.
@return aData, Array , Array com os valores de carga do formulário de empenhos
/*/
Static Function addGridSMJ(oModel)
	Local aData      := {}
	Local aValues    := {}
	Local aFields    := oModel:oFormModelStruct:aFields
	Local nTamCmp    := GetSX3Cache("MJ_CAMPO"  , "X3_TAMANHO")
	Local nTamDesc   := GetSX3Cache("MJ_DESCAMP", "X3_TAMANHO")
	Local nIndex     := 0
	Local nTotal     := 0
	Local nIndFields := 0
	Local nTotalFld  := Len(aFields)
	Local oPosition  := JsonObject():New()

	oPosition["MJ_CAMPO"  ] := 1
	oPosition["MJ_CODBAR" ] := 2
	oPosition["MJ_VISIVEL"] := 3
	oPosition["MJ_EDITA"  ] := 4
	oPosition["MJ_VISUAL" ] := 5
	oPosition["MJ_INCLUI" ] := 6
	oPosition["MJ_ALTERA" ] := 7
	oPosition["MJ_EXCLUI" ] := 8
	oPosition["MJ_DESCAMP"] := 0

	//aValues - MJ_CAMPO, MJ_CODBAR, MJ_VISIVEL, MJ_EDITA, MJ_VISUAL, MJ_INCLUI, MJ_ALTERA, MJ_EXCLUI
	aAdd(aValues, {PadR("D4_COD"    , nTamCmp), "1", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_LOCAL"  , nTamCmp), "2", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_DATA"   , nTamCmp), "2", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_QTDEORI", nTamCmp), "2", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_QUANT"  , nTamCmp), "2", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_TRT"    , nTamCmp), "2", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_LOTECTL", nTamCmp), "1", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_NUMLOTE", nTamCmp), "1", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_DTVALID", nTamCmp), "2", "1", "2", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_OPORIG" , nTamCmp), "2", "1", "2", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_QTSEGUM", nTamCmp), "2", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_POTENCI", nTamCmp), "2", "1", "2", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_SEQ"    , nTamCmp), "2", "1", "2", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_EMPROC" , nTamCmp), "2", "1", "1", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_PRODUTO", nTamCmp), "2", "1", "2", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_OPERAC" , nTamCmp), "2", "1", "2", "1", "2", "2", "2"})
	aAdd(aValues, {PadR("D4_PRDORG" , nTamCmp), "1", "1", "1", "1", "2", "2", "2"})

	nTotal := Len(aValues)
	For nIndex := 1 To nTotal
		If !Empty(oModel:GetValue("MJ_CAMPO"))
			oModel:AddLine()
		EndIf

		For nIndFields := 1 To nTotalFld
			If oPosition[aFields[nIndFields][3]] != Nil
				If aFields[nIndFields][3] == "MJ_DESCAMP"
					oModel:SetValue("MJ_DESCAMP", PadR(FWSX3Util():GetDescription(aValues[nIndex][oPosition["MJ_CAMPO"]]), nTamDesc))
				Else
					oModel:SetValue(aFields[nIndFields][3], aValues[nIndex][oPosition[aFields[nIndFields][3]]])
				EndIf
			EndIf
		Next nIndFields
	Next nIndex

	aSize(aValues, 0)
	FreeObj(oPosition)

Return aData

/*/{Protheus.doc} cargaSMC
Carrega os dados da tabela SMC

@type Static Function
@author marcelo.neumann
@since 23/06/2021
@version P12
@param oModel   , Object   , Referência do modelo de dados
@param cProgApon, Character, Indicador do Programa de Apontamento
@return Nil
/*/
Static Function cargaSMC(oModel, cProgApon)
	Local aCampSMC  := {}
	Local nIndex    := 1
	Local nTotal    := 0
	Local oModelSMC := oModel:GetModel("DETAIL_SMC")

	//Permite a inclusão e exclusão de linhas
	oModelSMC:SetNoInsertLine(.F.)
	oModelSMC:SetNoDeletetLine(.F.)

	nTotal := oModelSMC:Length()
	If nTotal > 1
		//Apaga todas a linhas da grid
		For nIndex := 1 To nTotal
			oModelSMC:GoLine(nIndex)
			oModelSMC:DeleteLine(.T.,.T.)
		Next nIndex

		//LIMPAR LINHAS DELETADAS, NÃO DEIXANDO LINHAS CINZAS NA GRID
		nTotal := Len(oModelSMC:aHeader)

		oModelSMC:GoLine(1)
		aSize(oModelSMC:aDataModel, 1)
		aSize(oModelSMC:aCols, 1)

		For nIndex := 1 To nTotal
			oModel:ClearField('DETAIL_SMC', oModelSMC:aHeader[nIndex][2])
		Next nIndex

		//AddLine Força um refresh no grid, os aSizes removem a nova linha em branco.
		oModelSMC:AddLine()
		aSize(oModelSMC:aDataModel, 1)
		aSize(oModelSMC:aCols, 1)

		oModelSMC:GoLine(1)
		oModelSMC:UnDeleteLine() //Sempre fica uma linha deletada na grid, entao retiramos o delete
	EndIf

	If cProgApon == '1' //CAMPOS DA ROTINA MATA250
		addCampSMC(@aCampSMC,"D3",oModelSMC)
		addCampSMC(@aCampSMC,"D4",oModelSMC)
	ElseIf cProgApon == '2' //CAMPOS DA ROTINA MATA680
		addCampSMC(@aCampSMC,"H6",oModelSMC)
		addCampSMC(@aCampSMC,"D4",oModelSMC)
	ElseIf cProgApon == '3' //CAMPOS DA ROTINA MATA681
		addCampSMC(@aCampSMC,"H6",oModelSMC)
		addCampSMC(@aCampSMC,"D4",oModelSMC)
	ElseIF cProgApon == '4'
		addCampSMC(@aCampSMC,"CYV",oModelSMC)
		addCampSMC(@aCampSMC,"D4",oModelSMC)
	ElseIF cProgApon == '5' //CAMPO DA ROTINA MATA250 SEM O CAMPO D3_OP
		addCampSMC(@aCampSMC,"D3",oModelSMC)
		addCampSMC(@aCampSMC,"D4",oModelSMC)
	ElseIf cProgApon == '6' //CAMPOS DA ROTINA MATA650
		addCampSMC(@aCampSMC,"C2",oModelSMC)
	EndIf

	oModelSMC:GoLine(oModelSMC:GetLine())
	nTotal := Len(aCampSMC)
	For nIndex := 1 To nTotal
		If !Empty(oModelSMC:GetValue("MC_CAMPO"))
			oModelSMC:AddLine()
		EndIf

		oModelSMC:SetValue("MC_TIPO"   , aCampSMC[nIndex][1])
		oModelSMC:SetValue("MC_CAMPO"  , aCampSMC[nIndex][2])
		oModelSMC:SetValue("TPFORM"    , aCampSMC[nIndex][3])
		oModelSMC:SetValue("MC_CODBAR" ,'2')
		oModelSMC:SetValue("MC_VISIVEL",'2')
		oModelSMC:SetValue("MC_EDITA"  ,'2')
		oModelSMC:SetValue("MC_VALPAD" , '')
	Next nIndex

	If oModelSMC:Length() > 0
		oModelSMC:GoLine(1)
	EndIf

	//Bloqueia inclusão e exclusão de linhas
	oModelSMC:SetNoInsertLine(.T.)
	oModelSMC:SetNoDeletetLine(.T.)

Return

Static Function addCampSMC(aCampSMC,cAlias,oModelSMC)
	Local cTpForm := IIF(cAlias == "D4",STR0042,IIF(cAlias == "C2", STR0044,STR0043)) //"Empenho" "Cadastro OP" "Apontamento"

	Aadd(aCampSMC, {"CustomFieldCharacter01",cAlias+"_CCCA01",cTpForm})
	Aadd(aCampSMC, {"CustomFieldCharacter02",cAlias+"_CCCA02",cTpForm})
	Aadd(aCampSMC, {"CustomFieldCharacter03",cAlias+"_CCCA03",cTpForm})
	Aadd(aCampSMC, {"CustomFieldCharacter04",cAlias+"_CCCA04",cTpForm})
	Aadd(aCampSMC, {"CustomFieldCharacter05",cAlias+"_CCCA05",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDecimal01"	,cAlias+"_CCDE01",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDecimal02"	,cAlias+"_CCDE02",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDecimal03"	,cAlias+"_CCDE03",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDecimal04"	,cAlias+"_CCDE04",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDecimal05"	,cAlias+"_CCDE05",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDate01"		,cAlias+"_CCDA01",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDate02"		,cAlias+"_CCDA02",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDate03"		,cAlias+"_CCDA03",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDate04"		,cAlias+"_CCDA04",cTpForm})
	Aadd(aCampSMC, {"CustomFieldDate05"		,cAlias+"_CCDA05",cTpForm})
	Aadd(aCampSMC, {"CustomFieldLogical01"	,cAlias+"_CCLO01",cTpForm})
	Aadd(aCampSMC, {"CustomFieldLogical02"	,cAlias+"_CCLO02",cTpForm})
	Aadd(aCampSMC, {"CustomFieldLogical03"	,cAlias+"_CCLO03",cTpForm})
	Aadd(aCampSMC, {"CustomFieldLogical04"	,cAlias+"_CCLO04",cTpForm})
	Aadd(aCampSMC, {"CustomFieldLogical05"	,cAlias+"_CCLO05",cTpForm})
	If oModelSMC:HasField("MC_TABELA")
		Aadd(aCampSMC, {"CustomFieldList01"	,cAlias+"_CCLI01",cTpForm})
		Aadd(aCampSMC, {"CustomFieldList02"	,cAlias+"_CCLI02",cTpForm})
		Aadd(aCampSMC, {"CustomFieldList03"	,cAlias+"_CCLI03",cTpForm})
		Aadd(aCampSMC, {"CustomFieldList04"	,cAlias+"_CCLI04",cTpForm})
		Aadd(aCampSMC, {"CustomFieldList05"	,cAlias+"_CCLI05",cTpForm})
	EndIf

Return

/*/{Protheus.doc} updateSMC
Carrega os dados de lista da tabela SMC

@type Static Function
@author renan.roeder
@since 05/11/2021
@version P12
@param oModel   , Object   , Referência do modelo de dados
@param cProgApon, Character, Indicador do Programa de Apontamento
@return Nil
/*/
Static Function updateSMC(oModel, cProgApon)
	Local aCampSMC  := {}
	Local nIndex    := 1
	Local nTotal    := 0
	Local oModelSMC := oModel:GetModel("DETAIL_SMC")

	//Permite a inclusão e exclusão de linhas
	oModelSMC:SetNoInsertLine(.F.)
	oModelSMC:SetNoDeletetLine(.F.)

	If cProgApon == '1' //CAMPOS DA ROTINA MATA250
		addListSMC(@aCampSMC,"D3")
	ElseIf cProgApon == '2' //CAMPOS DA ROTINA MATA680
		addListSMC(@aCampSMC,"H6")		
	ElseIf cProgApon == '3' //CAMPOS DA ROTINA MATA681
		addListSMC(@aCampSMC,"H6")
	ElseIF cProgApon == '4'
		addListSMC(@aCampSMC,"CYV")
	ElseIF cProgApon == '5' //CAMPO DA ROTINA MATA250 SEM O CAMPO D3_OP
		addListSMC(@aCampSMC,"D3")
	ElseIF cProgApon == '6'
		addListSMC(@aCampSMC,"C2")
	EndIf

	oModelSMC:GoLine(oModelSMC:GetLine())
	nTotal := Len(aCampSMC)
	For nIndex := 1 To nTotal
		If !Empty(oModelSMC:GetValue("MC_CAMPO"))
			oModelSMC:AddLine()
		EndIf

		oModelSMC:SetValue("MC_TIPO"   , aCampSMC[nIndex][1])
		oModelSMC:SetValue("MC_CAMPO"  , aCampSMC[nIndex][2])
		oModelSMC:SetValue("MC_CODBAR" ,'2')
		oModelSMC:SetValue("MC_VISIVEL",'2')
		oModelSMC:SetValue("MC_EDITA"  ,'2')
		oModelSMC:SetValue("MC_VALPAD" , '')
	Next nIndex

	If oModelSMC:Length() > 0
		oModelSMC:GoLine(1)
	EndIf

	//Bloqueia inclusão e exclusão de linhas
	oModelSMC:SetNoInsertLine(.T.)
	oModelSMC:SetNoDeletetLine(.T.)

Return

/*/{Protheus.doc} loadSMCEmp
Carrega os registros de campos customizados do empenho para os apontamentos

@type Static Function
@author renan.roeder
@since 04/11/2022
@version P12
@param oModelSMC, Object   , Referência do modelo de dados
@param cProgApon, Character, Indicador do Programa de Apontamento
@return Nil
/*/
Static Function loadSMCEmp(oModelSMC,cProgApon)
	Local aCampSMC := {}
	Local nIndex   := 0

	If cProgApon != "6" .And. !oModelSMC:SeekLine({{"MC_CAMPO" , "D4_"}})
		addCampSMC(@aCampSMC,"D4",oModelSMC)
		//Permite a inclusão e exclusão de linhas
		oModelSMC:SetNoInsertLine(.F.)
		oModelSMC:SetNoDeletetLine(.F.)

		oModelSMC:GoLine(oModelSMC:GetLine())
		nTotal := Len(aCampSMC)
		For nIndex := 1 To nTotal
			If !Empty(oModelSMC:GetValue("MC_CAMPO"))
				oModelSMC:AddLine()
			EndIf

			oModelSMC:SetValue("MC_TIPO"   , aCampSMC[nIndex][1])
			oModelSMC:SetValue("MC_CAMPO"  , aCampSMC[nIndex][2])
			oModelSMC:SetValue("TPFORM"    , aCampSMC[nIndex][3])
			oModelSMC:SetValue("MC_CODBAR" ,'2')
			oModelSMC:SetValue("MC_VISIVEL",'2')
			oModelSMC:SetValue("MC_EDITA"  ,'2')
			oModelSMC:SetValue("MC_VALPAD" , '')
		Next nIndex

		If oModelSMC:Length() > 0
			oModelSMC:GoLine(1)
		EndIf

		//Bloqueia inclusão e exclusão de linhas
		oModelSMC:SetNoInsertLine(.T.)
		oModelSMC:SetNoDeletetLine(.T.)		
	EndIf

Return

Static Function addListSMC(aCampSMC, cAlias)
		Aadd(aCampSMC, {"CustomFieldList01"	,cAlias+"_CCLI01"})
		Aadd(aCampSMC, {"CustomFieldList02"	,cAlias+"_CCLI02"})
		Aadd(aCampSMC, {"CustomFieldList03"	,cAlias+"_CCLI03"})
		Aadd(aCampSMC, {"CustomFieldList04"	,cAlias+"_CCLI04"})
		Aadd(aCampSMC, {"CustomFieldList05"	,cAlias+"_CCLI05"})
Return

/*/{Protheus.doc} A125WhnSOY
Função de avaliação de WHEN para os campos da tabela SOY.

@type  Function
@author lucas.franca
@since 12/07/2021
@version P12
@param oModel, Object   , Referência do modelo de dados
@param cCampo, Character, Indica qual campo está sendo analisado.
@return lRet , Logic    , Indica se o campo pode ter seu conteúdo modificado
/*/
Function A125WhnSOY(oModel, cCampo)
	Local lRet := .T.

	If !_lLoadData .And. "|" + AllTrim(oModel:GetValue("OY_CAMPO")) + "|" $ CAMPOS_DESCRICAO
		lRet := .F.
	EndIf
Return lRet 

/*/{Protheus.doc} addNewReg
Verifica a necessidade de incluir novos registros na SMY.

@type  Static Function
@author lucas.franca
@since 12/07/2021
@version P12
@param oModel, Object, Modelo de dados da rotina.
@return Nil
/*/
Static Function addNewReg(oModel)
	Local cCampo    := ""
	Local cValue    := "2"
	Local oModelSOX := oModel:GetModel("OXMASTER")
	Local oModelSOY := oModel:GetModel("DETAIL_SOY")

	Do Case
		Case oModelSOX:GetValue("OX_PRGAPON") == "1"
			cCampo := "D3_CODDSC"
		Case oModelSOX:GetValue("OX_PRGAPON") == "3"
			cCampo := "H6_PROEDSC"
		Case oModelSOX:GetValue("OX_PRGAPON") == "4"
			cCampo := "CYV_CDACSC"
			cValue := "1"
		Case oModelSOX:GetValue("OX_PRGAPON") == "6"
			cCampo := "C2_PRODESC"
	EndCase

	If Empty(cCampo)
		Return
	EndIf

	cCampo := PadR(cCampo, GetSX3Cache("OY_CAMPO", "X3_TAMANHO"))

	If !oModelSOY:SeekLine({{"OY_CAMPO", cCampo}}, .F., .F.)
		oModelSOY:AddLine()
		
		_lLoadData := .T.
		oModelSOY:SetValue("OY_CAMPO"  , cCampo)
		oModelSOY:SetValue("OY_DESCAMP", STR0034) //"Descrição do produto"
		oModelSOY:SetValue("OY_CODBAR" , "2")
		oModelSOY:SetValue("OY_VISIVEL", cValue)
		oModelSOY:SetValue("OY_EDITA"  , "2")
		oModelSOY:SetValue("OY_VALPAD" ,  "")
		_lLoadData := .F.

		orderSOY(oModel)
	EndIf
Return Nil

/*/{Protheus.doc} orderSOY
Ordena registros da tabela SOY.

@type  Static Function
@author lucas.franca
@since 12/07/2021
@version P12
@param oModel, Object, Modelo de dados da rotina.
@return Nil
/*/
Static Function orderSOY(oModel)
	Local cCampoCod  := ""
	Local cCampoDsc  := ""
	Local nLineAtu   := 0
	Local nLineCod   := 0
	Local nLineDsc   := 0
	Local nLineTroca := 0
	Local nTotal     := 0
	Local oModelSOX  := oModel:GetModel("OXMASTER")
	Local oModelSOY  := oModel:GetModel("DETAIL_SOY")

	Do Case
		Case oModelSOX:GetValue("OX_PRGAPON") == "1"
			cCampoCod := "D3_COD"
			cCampoDsc := "D3_CODDSC"
		Case oModelSOX:GetValue("OX_PRGAPON") == "3"
			cCampoCod := "H6_PRODUTO"
			cCampoDsc := "H6_PROEDSC"
		Case oModelSOX:GetValue("OX_PRGAPON") == "4"
			cCampoCod := "CYV_CDACRP"
			cCampoDsc := "CYV_CDACSC"
		Case oModelSOX:GetValue("OX_PRGAPON") == "6"
			cCampoCod := "C2_PRODUTO"
			cCampoDsc := "C2_PRODESC"
	EndCase

	If Empty(cCampoDsc)
		Return
	EndIf

	cCampoDsc := PadR(cCampoDsc, GetSX3Cache("OY_CAMPO", "X3_TAMANHO"))
	cCampoCod := PadR(cCampoCod, GetSX3Cache("OY_CAMPO", "X3_TAMANHO"))

	//Linha que está posicionada antes da ordenação.
	nLineAtu := oModelSOY:GetLine()

	//Procura a linha onde está o campo de Descrição.
	If oModelSOY:SeekLine({{"OY_CAMPO", cCampoDsc}}, .F., .T.)
		nLineDsc := oModelSOY:GetLine()
		//Procura a linha onde está o campo de código.
		If oModelSOY:SeekLine({{"OY_CAMPO", cCampoCod}}, .F., .T.)
			nLineCod := oModelSOY:GetLine()
			//Encontrou a linha do código e da descrição. Verifica se a descrição está após o código. Se não estiver, executa a ordenação.
			If nLineCod + 1 != nLineDsc
				If nLineCod > nLineDsc
					nLineTroca := nLineDsc+1
				Else
					nLineTroca := nLineDsc-1
				EndIf
				nTotal := oModelSOY:Length()
				While .T.
					//Troca as linhas até que a linha da descrição fique abaixo da linha do código do produto.
					oModelSOY:lineShift(nLineDsc, nLineTroca)
					If nLineCod > nLineDsc
						nLineTroca++
						nLineDsc++
					Else
						nLineTroca--
						nLineDsc--
					EndIf

					If nLineTroca < 1 .Or. nLineTroca > nTotal .Or. nLineDsc == nLineCod+1
						Exit
					EndIf
				End
			EndIf
		EndIf
	EndIf

	//Restaura a linha posicionada originalmente.
	If oModelSOY:GetLine() != nLineAtu
		oModelSOY:GoLine(nLineAtu)
	EndIf
Return
