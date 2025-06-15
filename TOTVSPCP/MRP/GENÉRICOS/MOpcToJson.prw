#INCLUDE "TOTVS.CH"

Static _nTamPrd  := Nil
Static _nTamTrt  := Nil
Static _nTamGrp  := Nil
Static _nTamItm  := Nil
Static _oPrdFant := JsonObject():New()

/*/{Protheus.doc} MOpcToJson
Faz a convers�o das informa��es dos opcionais do formato MEMO (Array convertido para string) 
para o formato JSON, aplicando algumas regras para diminuir o volume de informa��es. 

@type  Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
@param 01 mOpc    , Character , String do campo MEMO de Opcionais
@param 02 nType   , Numeric, Indica o tipo de retorno do JSON. 
                              1=Retorna uma STRING representando o array de opcionais em JSON.
                              2=Retorna o ARRAY com os objetos JSON.
@param 03 lRetPath, Logic, Indica se deve montar o PATH desta OP para retornar. Quando .T., pr�ximos par�metros s�o obrigat�rios.
@param 04 cPathOpc, Character, Retorna por refer�ncia o PATH desta OP.
@param 05 cProdOp , Character, Produto da OP atual.
@param 06 cOpcOp  , Character, Opcional CHAR da OP atual.
@return xOpcJson, String, Informa��es de opcionais convertidas para Json, em formato STRING ou ARRAY, de acordo com o par�metro nType
/*/
Function MOpcToJson(mOpc, nType, lRetPath, cPathOp, cProdOp, cOpcOp)
	Local aOpc       := Nil 
	Local cAliasOpc  := ""
	Local cConcat    := ""
	Local cPai       := ""
	Local cComp      := ""
	Local cTrt       := ""
	Local cQuery     := ""
	Local cNewPath   := ""
	Local cNewOpc    := ""
	Local cNameSG1   := RetSqlName("SG1")
	Local cFilSG1    := xFilial("SG1")
	Local lPaiFant   := .F.
	Local nIndex     := 0
	Local nTam       := 0
	Local nTamPath   := 0
	Local oNewOpc    := Nil
	Local xOpcJson   := Nil

	Default lRetPath := .F.
	Default cPathOp  := Nil
	Default cProdOp  := ""
	Default cOpcOp   := ""

	TamFields()

	//Verifica se a string recebida por par�metro � v�lida para processar a convers�o.
	//Se n�o for, ir� retornar NIL
	If mOpc != Nil .And. mOpc != "" .And. (aOpc := Str2Array(mOpc,.F.)) != Nil
		nTam := Len(aOpc)
		
		If Upper(TcGetDb()) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
			cConcat += "||"
		Else
			cConcat += "+"
		EndIf

		oNewOpc := JsonObject():New()

		For nIndex := 1 To nTam
			//Se n�o existir informa��o de grupo/item opcional, desconsidera este item.
			If AllTrim(aOpc[nIndex][2]) == '/'
				Loop
			EndIf

			//Recupera as informa��es do PATH, referente ao �ltimo Produto Pai + Produto Componente + TRT Componente.
			nTamPath := Len(aOpc[nIndex][1])

			//Se � uma informa��o do 1� n�vel, deve desconsiderar o TRT, pois no primeiro produto PAI n�o tem esta informa��o
			If nTamPath == (_nTamPrd*2)+_nTamTrt
				cPai  := SubStr(Right(aOpc[nIndex][1], (_nTamPrd*2)+3), 1, _nTamPrd)
			Else
				cPai  := SubStr(Right(aOpc[nIndex][1], (_nTamPrd*2)+_nTamTrt+3), 1, _nTamPrd)
			EndIf
			
			cComp := SubStr(Right(aOpc[nIndex][1], _nTamPrd+_nTamTrt), 1, _nTamPrd)
			cTrt  := Right(aOpc[nIndex][1], _nTamTrt)

			//Verifica na SG1 se para o PAI+COMP+TRT, existem GRUPO+ITEM opcionais cadastrados, e se s�o v�lidos
			//de acordo com os opcionais que est�o marcados no array.
			cQuery := " SELECT COUNT(*) TOTAL "
			cQuery +=   " FROM " + cNameSG1 + " SG1 "
			cQuery +=  " WHERE SG1.G1_FILIAL  = '" + cFilSG1 + "' "
			cQuery +=    " AND SG1.G1_COD     = '" + cPai + "' "
			cQuery +=    " AND SG1.G1_COMP    = '" + cComp + "' "
			cQuery +=    " AND SG1.G1_TRT     = '" + cTrt + "' "
			cQuery +=    " AND SG1.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND '" + aOpc[nIndex][2] + "' LIKE '%'" + cConcat + "SG1.G1_GROPC" + cConcat + "SG1.G1_OPC" + cConcat + "'%'"

			cAliasOpc := GetNextAlias() + StrTran(cValToChar(MicroSeconds()),'.','')

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasOpc,.T.,.T.)
			If lRetPath .Or. (cAliasOpc)->(TOTAL) > 0
				cNewPath := ConvPath(aOpc[nIndex][1], .F.)
				cNewOpc  := ConvOpc(aOpc[nIndex][2])

				If Empty(cPathOp)
					lPaiFant := .F.
					If (cPai == cProdOp .Or. (lPaiFant := vldPaiFant(cPai, cProdOp, aOpc[nIndex][1]))) .And.;
					   (vldGrupOpc(cOpcOp, aOpc, nIndex) .Or. vldCmpFant(cComp, aOpc, cOpcOp, nIndex))
						cPathOp := cNewPath
						If lPaiFant
							//Se o produto pai � fantasma, remove do PATH o c�digo do produto fantasma, 
							//mantendo o path at� o produto anterior.
							cPathOp := TrimPath(cPathOp, .T.)
						EndIf
					EndIf
				EndIf
			EndIf

			If (cAliasOpc)->(TOTAL) > 0
				addJson(cNewPath, cNewOpc, @oNewOpc)
			EndIf
			(cAliasOpc)->(dbCloseArea())

		Next nIndex
		xOpcJson := getStrOpc(@oNewOpc, nType)

		//Verifica preenchimento do PATH de opcionais para o primeiro produto PAI.
		If lRetPath .And. nTam > 0
			If Empty(cPathOp) .And. cProdOp == Left(aOpc[1][1], _nTamPrd)
				cPathOp := RTrim(cProdOp)
			EndIf
			If Empty(cPathOp)
				If !opcNivInf(aOpc, cProdOp, @cPathOp)
					cPathOp := "|SEM_PATH|"
				EndIf
			Else
				cPathOp := TrimPath(cPathOp, .F.)
			EndIf
		EndIf

		FreeObj(oNewOpc)
		oNewOpc := Nil
	EndIf

Return xOpcJson

/*/{Protheus.doc} TamFields
Carrega as vari�veis est�ticas com o tamanho dos campos.

@type  Static Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
/*/
Static Function TamFields()
	If _nTamGrp == Nil
		_nTamGrp := GetSx3Cache("GA_GROPC","X3_TAMANHO")
	EndIf
	If _nTamItm == Nil
		_nTamItm := GetSx3Cache("GA_OPC","X3_TAMANHO")
	EndIf
	If _nTamPrd == Nil
		_nTamPrd := GetSx3Cache("B1_COD","X3_TAMANHO")
	EndIf
	If _nTamTrt == Nil
		_nTamTrt := GetSx3Cache("G1_TRT","X3_TAMANHO")
	EndIf
Return Nil

/*/{Protheus.doc} ConvPath
Converte um PATH da estrutura para o formato que dever� ser utilizado no JSON.
Remove os espa�os desnecess�rios e adiciona separadores nas informa��es.

@type  Static Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
@param cPath   , String, Path da estrutura que dever� ser convertida.
@param lTrimTRT, Logic , Indica se deve fazer o trim do TRT antes de concatenar ao path.
@return cNewPath, String, Path da estrutura convertida.
/*/
Static Function ConvPath(cPath, lTrimTRT)
	Local cNewPath := ""
	Local cProduto := ""
	Local cTrt     := ""
	Local lFirst   := .T.

	//Remove o �ltimo COMPONENTE+TRT do Path.
	cPath := SubStr(cPath, 1, Len(cPath)-(_nTamPrd+_nTamTrt))

	While !Empty(cPath)
		cProduto := Left(cPath, _nTamPrd)
		cTrt     := SubStr(cPath, _nTamPrd+1, _nTamTrt)
		If lTrimTRT
			cTrt := RTrim(cTrt)
		EndIf
		If lFirst
			cNewPath := RTrim(cProduto)
			cPath    := SubStr(cPath, _nTamPrd+1, Len(cPath))
		Else
			cNewPath += "|" + RTrim(cProduto) + ";" + cTrt
			cPath    := SubStr(cPath, _nTamPrd+_nTamTrt+1, Len(cPath))
		EndIf
		
		lFirst := .F.
	End
Return cNewPath

/*/{Protheus.doc} ConvOpc
Converte os opcionais, retirando espa�os desnecess�rios e adicionando separadores nas informa��es.

@type  Static Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
@param cOpc, String, Opcionais que ser�o convertidos
@return cNewOpc, String, Opcionais convertidos.
/*/
Static Function ConvOpc(cOpc)
	Local aOpc    := StrTokArr(cOpc, '/')
	Local cNewOpc := ""
	Local cGrupo  := ""
	Local cItem   := ""
	Local nIndex  := 0
	Local nTam    := Len(aOpc)

	For nIndex := 1 To nTam
		cGrupo := SubStr(aOpc[nIndex], 1, _nTamGrp)
		cItem  := SubStr(aOpc[nIndex], _nTamGrp+1, _nTamItm)

		If nIndex > 1
			cNewOpc += "|"
		EndIf

		cNewOpc += RTrim(cGrupo) + ';' + RTrim(cItem)
	Next nIndex
	
Return cNewOpc

/*/{Protheus.doc} addJson
Adiciona a informa��o de PATH e OPCIONAL no objeto JSON.

@type  Static Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
@param cNewPath , String, Path de estrutura que dever� ser salvo no JSON
@param cNewOpc  , String, Opcionais da estrutura que devem ser salvos no JSON
@param oOpcJson , Object, Objeto JSON com as informa��es dos opcionais. Passar por refer�ncia.
@return Nil
/*/
Static Function addJson(cNewPath, cNewOpc, oOpcJson)
	Local aQuebraOpc := {}
	Local nIndex     := 0
	Local nTam       := 0

	If oOpcJson[cNewPath] == Nil
		//PATH ainda n�o existe, apenas adiciona o PATH e Opcionais no objeto.
		oOpcJson[cNewPath] := JsonObject():New()
		oOpcJson[cNewPath]["key"]   := cNewPath
		oOpcJson[cNewPath]["value"] := cNewOpc
	Else
		//PATH j� existe. Verifica se precisa adicionar algum opcional no PATH j� existente.
		aQuebraOpc := StrTokArr(cNewOpc, '|')
		nTam := Len(aQuebraOpc)
		For nIndex := 1 To nTam
			If At(aQuebraOpc[nIndex], oOpcJson[cNewPath]["value"]) == 0
				//Se o GRUPO+ITEM n�o existir ainda no objeto JSON, adiciona.
				oOpcJson[cNewPath]["value"] += "|" + aQuebraOpc[nIndex]
			EndIf
		Next nIndex
	EndIf

Return Nil

/*/{Protheus.doc} getStrOpc
Converte o OBJETO Json criado com as novas informa��es de Opcionais para STRING

@type  Static Function
@author lucas.franca
@since 11/05/2019
@version P12.1.25
@param oNewOpc, Object, Objeto JSON com as informa��es dos opcionals
@param nType  , Numeric, Indica o tipo de retorno do JSON. 
                          1=Retorna uma STRING representando o array de opcionais em JSON.
                          2=Retorna o ARRAY com os objetos JSON.
@return xNewOpc, String, Informa��es de opcionais convertidas para Json, em formato STRING ou ARRAY, de acordo com o par�metro nType
/*/
Static Function getStrOpc(oNewOpc, nType)
	Local aKeys   := oNewOpc:GetNames()
	Local aNewOpc := {}
	Local xNewOpc := ""
	Local nIndex  := 0
	Local nTam    := Len(aKeys)

	//Formata as informa��es contidas no JSON criado, para ser um ARRAY com as informa��es de PATH e OPCIONAL
	For nIndex := 1 To nTam
		aAdd(aNewOpc, oNewOpc[aKeys[nIndex]])
	Next nIndex

	//Converte o ARRAY para o formato JSON.
	If nType == 1
		xNewOpc := FwJsonSerialize(aNewOpc,.F.,.F.)
	Else
		xNewOpc := aNewOpc
	EndIf
	
Return xNewOpc

/*/{Protheus.doc} vldPaiFant
Faz a an�lise do produto atual com rela��o aos produtos pais fantasmas.

@type  Static Function
@author lucas.franca
@since 28/05/2021
@version P12
@param 01 cPai    , Character, C�digo do produto pai
@param 02 cProdOp , Character, Produto da ordem de produ��o atual
@param 03 cPathAtu, Character, Path de estrutura atual
@return lOk, Logic, Identifica que o path atual corresponde a OP
/*/
Static Function vldPaiFant(cPai, cProdOp, cPathAtu)
	Local nLenPath := Len(cPathAtu)
	Local lOk      := .F.

	If nLenPath > (_nTamPrd*2)+_nTamTrt .And. prodFantas(cPai)
		cPai := SubStr(Right(cPathAtu, (_nTamPrd*3)+_nTamTrt*2+3), 1, _nTamPrd)
		If cPai == cProdOp
			lOk := .T.
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} vldCmpFant
Faz a an�lise do produto atual com rela��o aos produtos filhos fantasmas.

@type  Static Function
@author lucas.franca
@since 28/05/2021
@version P12
@param 01 cComp     , Character, C�digo do componente
@param 02 aOpc      , Array    , Array com a sele��o de opcionais.
@param 03 cOpcOp    , Character, Opcionais selecionados na OP atual
@param 04 nIndOpcAtu, Numeric  , �ndice do aOpc em processamento
@return lOk, Logic, Identifica que o path atual corresponde a OP
/*/
Static Function vldCmpFant(cComp, aOpc, cOpcOp, nIndOpcAtu)
	Local aGrupoOP  := {}
	Local cPathAtu  := aOpc[nIndOpcAtu][1]
	Local nIndex    := 0
	Local nTotal    := 0
	Local nLenPath  := Len(cPathAtu)
	Local lOk       := .T.
	Local nPos      := nIndOpcAtu
	Local oOpcPath  := JsonObject():New()

	If prodFantas(cComp)
		aGrupoOP := StrTokArr(cOpcOp, "/")
		oOpcPath[AllTrim(StrTran(aOpc[nIndOpcAtu][2], "/", ""))] := .T.

		//Se for produto fantasma, busca na �rvore de opcionais todos os grupos de opcionais que foram selecionados para este produto.
		While (nPos := aScan(aOpc, {|x| SubStr(x[1], 1, nLenPath) == cPathAtu}, nPos+1)) > 0
			oOpcPath[AllTrim(StrTran(aOpc[nPos][2], "/", ""))] := .T.
		End

		nTotal := Len(aGrupoOP)
		For nIndex := 1 To nTotal
			If Empty(aGrupoOP[nIndex])
				Loop
			EndIf

			If oOpcPath[AllTrim(aGrupoOP[nIndex])] == Nil
				//N�o encontrou todos os opcionais na �rvore. 
				//Este n�o � o path correto para esta ordem.
				lOk := .F.
				Exit
			EndIf
		Next nIndex

		aSize(aGrupoOP, 0)
	Else
		lOk := .F.
	EndIf

	FreeObj(oOpcPath)
	oOpcPath := Nil
Return lOk

/*/{Protheus.doc} vldGrupOpc
Verifica se o grupo de opcionais da OP � correspondente ao
path de estrutura atual.

@type  Static Function
@author lucas.franca
@since 31/05/2021
@version P12
@param 01 cOpcOp, Character, Opcionais da OP
@param 02 aOpc  , Array    , Array de opcionais
@param 03 nIndex, Numeric  , �ndice de aOpc em processamento
@return lRet, Logic, Indica se o opcional � o corredo do path atual
/*/
Static Function vldGrupOpc(cOpcOp, aOpc, nIndex)
	Local aGrupoOP := {}
	Local lRet     := AllTrim(aOpc[nIndex][2]) == AllTrim(cOpcOp)
	Local cPathAtu := aOpc[nIndex][1]
	Local nLenOrig := Len(cPathAtu)
	Local nLenPath := Len(cPathAtu) - (_nTamPrd + _nTamTrt)
	Local nPos     := nIndex
	Local nIndOpc  := 0
	Local nTotal   := 0
	Local oOpcPath := JsonObject():New()
	
	If !lRet
		aGrupoOP := StrTokArr(cOpcOp, "/")
		//Remove �ltimo elemento caso esteja vazio.
		If Empty(aTail(aGrupoOP))
			aSize(aGrupoOP, Len(aGrupoOP)-1)
		EndIf
		oOpcPath[AllTrim(StrTran(aOpc[nIndex][2], "/", ""))] := .T.

		//Busca no array por outros grupos selecionados para este mesmo produto.
		While (nPos := aScan(aOpc, {|x| SubStr(x[1], 1, nLenPath) == cPathAtu .And. Len(x[1] == nLenOrig)}, nPos+1)) > 0
			oOpcPath[AllTrim(StrTran(aOpc[nPos][2], "/", ""))] := .T.
		End

		nTotal := Len(aGrupoOP)
		For nIndOpc := 1 To nTotal
			If Empty(aGrupoOP[nIndOpc])
				Loop
			EndIf

			If oOpcPath[AllTrim(aGrupoOP[nIndOpc])] == Nil
				//N�o encontrou todos os opcionais na �rvore. 
				//Este n�o � o path correto para esta ordem.
				lRet := .F.
				Exit
			EndIf
		Next nIndOpc
		If nIndOpc >= nTotal
			//Se percorreu todos os itens de aGrupoOP sem sair do FOR, este � o path correto.
			lRet := .T.
		EndIf
		aSize(aGrupoOP, 0)
		FreeObj(oOpcPath)
	EndIf

Return lRet

/*/{Protheus.doc} prodFantas
Verifica se um produto � fantasma.

@type  Static Function
@author lucas.franca
@since 31/05/2021
@version P12
@param 01 cProd, Character, C�digo do produto
@return lRet, Logic, Identifica se o produto � fantasma.
/*/
Static Function prodFantas(cProd)
	Local lRet := .F.

	If _oPrdFant[cProd] == Nil
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProd))
		_oPrdFant[cProd] := RetFldProd(SB1->B1_COD, "B1_FANTASM") == "S"
	EndIf

	lRet := _oPrdFant[cProd]
Return lRet

/*/{Protheus.doc} TrimPath
Remove os espa�os existentes ap�s os c�digos de produto e TRT.

@type  Static Function
@author lucas.frnaca
@since 01/06/2021
@version P12
@param 01 cPathOp, Character, Path da ordem de produ��o
@param 02 lRemove, Logic    , Indica que deve remover o �ltimo elemento correspondente a produto fantasma.
@return cTrimPath, Character, Path da OP sem os espa�os ap�s produto/trt.
/*/
Static Function TrimPath(cPathOp, lRemove)
	Local aPathArray := StrTokArr(cPathOp, "|")
	Local cTrimPath  := ""
	Local nIndex     := 0
	Local nTotal     := Len(aPathArray)

	For nIndex := 1 To nTotal
		If Empty(aPathArray[nIndex]) .Or. (lRemove .And. nIndex == nTotal)
			Loop
		EndIf
		If !Empty(cTrimPath)
			cTrimPath += "|"
		EndIf
		cTrimPath += RTrim(aPathArray[nIndex])
	Next nIndex
	
	aSize(aPathArray, 0)

Return cTrimPath

/*/{Protheus.doc} opcNivInf
Verifica se existem opcionais em n�veis inferiores ao atual.

@type  Static Function
@author lucas.franca
@since 02/06/2021
@version P12
@param 01 aOpc    , Array    , Array de opcionais
@param 02 cProdOp , Character, C�digo do produto da OP atual
@param 03 cPathOp , Character, Retorna por refer�ncia o path que ser� utilizado.
@return lAchouPath, Logic, Identifica se existe ou n�o path para este produto
/*/
Static Function opcNivInf(aOpc, cProdOp, cPathOp)
	Local lAchouPath := .F.
	Local nIndex     := 0
	Local nPosPath   := 0
	Local nTotalOpc  := Len(aOpc)

	For nIndex := 1 To nTotalOpc
		If AllTrim(aOpc[nIndex][2]) == "/"
			Loop
		EndIf

		nPosPath := At(cProdOp, aOpc[nIndex][1])

		If nPosPath > 0 .And. Len(aOpc[nIndex][1]) > (nPosPath-1)+_nTamPrd+_nTamTrt
			cPathOp    := SubStr(aOpc[nIndex][1], 1, (nPosPath-1)+((_nTamPrd+_nTamTrt)*2))
			cPathOp    := ConvPath(cPathOp, .T.)
			lAchouPath := .T.
			Exit
		EndIf
	Next nIndex
Return lAchouPath


