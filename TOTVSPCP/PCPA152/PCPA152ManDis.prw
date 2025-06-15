#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"

/*/{Protheus.doc} PCPA152MANDIS
API Para manipulação dos dados da disponibilidade (SMR e SMK)

@type  WSCLASS
@author lucas.franca
@since 28/02/2023
@version P12
/*/
WSRESTFUL PCPA152MANDIS DESCRIPTION "PCPA152MANDIS" FORMAT APPLICATION_JSON
	WSDATA Page                AS INTEGER OPTIONAL
	WSDATA PageSize            AS INTEGER OPTIONAL
	WSDATA qtdRegistroExcluido AS INTEGER OPTIONAL
	WSDATA programacao         AS STRING  OPTIONAL
	WSDATA idDisponibilidade   AS STRING  OPTIONAL
	WSDATA dataInicial         AS STRING  OPTIONAL
	WSDATA dataFinal           AS STRING  OPTIONAL
	WSDATA recurso             AS STRING  OPTIONAL

	WSMETHOD GET DISP;
		DESCRIPTION STR0110; //"Retorna a disponibilidade dos recursos"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/recursos/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152mandis/recursos/{programacao}" ;
		TTALK "v1"

	WSMETHOD DELETE DISP;
		DESCRIPTION STR0111; //"Exclui a disponibilidade de um recurso em uma data"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/recursos/{programacao}/{idDisponibilidade}" ;
		PATH "/api/pcp/v1/pcpa152mandis/recursos/{programacao}/{idDisponibilidade}" ;
		TTALK "v1"

	WSMETHOD POST ADDDISP;
		DESCRIPTION STR0112; //"Inclui a disponibilidade de um recurso em uma data"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/recursos/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152mandis/recursos/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST UPDDISP;
		DESCRIPTION STR0113; //"Altera a disponibilidade de um recurso em uma data"
		WSSYNTAX "/api/pcp/v1/pcpa152mandis/recursos/{programacao}/{idDisponibilidade}" ;
		PATH "/api/pcp/v1/pcpa152mandis/recursos/{programacao}/{idDisponibilidade}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET DISP /api/pcp/v1/pcpa152mandis/recursos
Retorna a disponibilidade dos recursos

@type  WSMETHOD
@author lucas.franca
@since 28/02/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD GET DISP PATHPARAM programacao QUERYPARAM Page, PageSize, qtdRegistroExcluido, dataInicial, dataFinal, recurso WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getDisp(Self:programacao, Self:Page, Self:PageSize, Self:qtdRegistroExcluido, Self:dataInicial, Self:dataFinal, Self:recurso)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getDisp
Busca os dados de disponibilidade

@type  Static Function
@author lucas.franca
@since 28/02/2023
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 nPage     , Numeric , Página para consulta
@param 03 nPageSize , Numeric , Tamanho da página
@param 04 nQtdRegDel, Numeric , Quantidade de registros excluídos para considerar na paginação
@param 05 cDataIni  , Caracter, Data inicial para filtro dos dados
@param 06 cDataFim  , Caracter, Data final para filtro dos dados
@param 07 cRecurso  , Caracter, Código do recurso para filtro dos dados
@param 08 cIdDisp   , Caracter, ID da disponibilidade
@return aReturn, Array, Array com os dados de retorno da API
/*/
Static Function getDisp(cProg, nPage, nPageSize, nQtdRegDel, cDataIni, cDataFim, cRecurso, cIdDisp)
	Local aReturn  := {.T., 200, ""}
	Local cAlias   := getNextAlias()
	Local cFields  := ""
	Local cFrom    := ""
	Local cWhere   := ""
	Local cOrder   := ""
	Local nPos     := 0
	Local oJsRet   := JsonObject():New()
	Local oJsPos   := JsonObject():New()
	Local oJsDet   := Nil

	Default nPage      := 1
	Default nPageSize  := 20
	Default nQtdRegDel := 0
	Default cIdDisp    := ""

	cFields := /*SELECT */"SMR.MR_RECURSO,"
	cFields +=           " SH1.H1_DESCRI,"
	cFields +=           " SMR.MR_DATDISP,"
	cFields +=           " SMR.MR_TEMPODI,"
	cFields +=           " SMR.MR_TEMPOBL,"
	cFields +=           " SMR.MR_TEMPOPA,"
	cFields +=           " SMR.MR_TEMPOEX,"
	cFields +=           " SMR.MR_TEMPOTO,"
	cFields +=           " SMR.MR_DISP,"
	cFields +=           " SMK.MK_SEQ,"
	cFields +=           " SMK.MK_HRINI,"
	cFields +=           " SMK.MK_HRFIM,"
	cFields +=           " SMK.MK_TIPO,"
	cFields +=           " SMK.MK_BLOQUE,"
	cFields +=           " T4X.T4X_STATUS"
	cFrom := /*FROM*/ RetSqlName("SMR") + " SMR "
	cFrom += " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cFrom +=         " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cFrom +=        " AND SH1.H1_CODIGO  = SMR.MR_RECURSO"
	cFrom +=        " AND SH1.D_E_L_E_T_ = ' ' "
	cFrom += " INNER JOIN " + RetSqlName("SMK") + " SMK "
	cFrom +=         " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "' "
	cFrom +=        " AND SMK.MK_PROG    = SMR.MR_PROG"
	cFrom +=        " AND SMK.MK_DISP    = SMR.MR_DISP"
	cFrom +=        " AND SMK.D_E_L_E_T_ = ' ' "
	cFrom += " INNER JOIN " + RetSqlName("T4X") + " T4X "
	cFrom +=         " ON T4X.T4X_FILIAL = '" + xFilial("T4X") + "' "
	cFrom +=        " AND T4X.T4X_PROG   = SMR.MR_PROG "
	cFrom +=        " AND T4X.D_E_L_E_T_ = ' ' "
	cWhere := /*WHERE*/" SMR.MR_FILIAL  = '" + xFilial("SMR") + "' "
	cWhere +=      " AND SMR.MR_PROG    = '" + cProg + "' "
	cWhere +=      " AND SMR.D_E_L_E_T_ = ' '"

	If !Empty(cRecurso)
		cWhere +=  " AND SMR.MR_RECURSO IN ('" + StrTran(cRecurso, ", ", "','") + "')"
	EndIf

	If !Empty(cDataIni)
		cWhere +=  " AND SMR.MR_DATDISP >= '" + StrTran(cDataIni, "-", "") + "'"
	EndIf

	If !Empty(cDataFim)
		cWhere +=  " AND SMR.MR_DATDISP <= '" + StrTran(cDataFim, "-", "") + "'"
	EndIf

	If !Empty(cIdDisp)
		cWhere +=  " AND SMR.MR_DISP = '" + cIdDisp + "'"
	EndIf

	cOrder := /*ORDER BY*/" SMR.MR_RECURSO, SMR.MR_DATDISP, SMK.MK_SEQ "

	cFields := "%" + cFields + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	cOrder  := "%" + cOrder  + "%"

	BeginSql Alias cAlias
		SELECT %Exp:cFields%
		  FROM %Exp:cFrom%
		 WHERE %Exp:cWhere%
		 ORDER BY %Exp:cOrder%
	EndSql

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			nStart := qtdRegDisp(nStart, nQtdRegDel, cFrom, cWhere)
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oJsRet["items"] := {}
	While (cAlias)->(!Eof())
		If oJsPos:HasProperty((cAlias)->MR_DISP)
			nPos := oJsPos[(cAlias)->MR_DISP]
		Else
			aAdd(oJsRet["items"], JsonObject():New())
			nPos := Len(oJsRet["items"])

			//Verifica tamanho da página
			If nPos > nPageSize
				aSize(oJsRet["items"], nPos-1) //Remove último array que foi adicionado
				Exit
			EndIf

			oJsPos[(cAlias)->MR_DISP] := nPos

			oJsRet["items"][nPos]["idDisponibilidade"  ] := (cAlias)->MR_DISP
			oJsRet["items"][nPos]["recurso"            ] := RTrim((cAlias)->MR_RECURSO)
			oJsRet["items"][nPos]["descricaoRecurso"   ] := RTrim((cAlias)->H1_DESCRI)
			oJsRet["items"][nPos]["dataDisponibilidade"] := PCPConvDat((cAlias)->MR_DATDISP, 4)
			oJsRet["items"][nPos]["horaDisponivel"     ] := __Min2Hrs((cAlias)->MR_TEMPODI, .T.)
			oJsRet["items"][nPos]["horaBloqueada"      ] := __Min2Hrs((cAlias)->MR_TEMPOBL, .T.)
			oJsRet["items"][nPos]["horaParada"         ] := __Min2Hrs((cAlias)->MR_TEMPOPA, .T.)
			oJsRet["items"][nPos]["horaExtra"          ] := __Min2Hrs((cAlias)->MR_TEMPOEX, .T.)
			oJsRet["items"][nPos]["horaTotal"          ] := __Min2Hrs((cAlias)->MR_TEMPOTO, .T.)
			oJsRet["items"][nPos]["detail"             ] := {}
			If (cAlias)->T4X_STATUS == "4"
				oJsRet["items"][nPos]["actions"] := {"editar","excluir"}
			EndIf
		EndIf

		oJsDet := JsonObject():New()
		oJsDet["sequencia"         ] := (cAlias)->MK_SEQ
		oJsDet["horaInicial"       ] := (cAlias)->MK_HRINI
		oJsDet["horaFinal"         ] := (cAlias)->MK_HRFIM
		oJsDet["tipo"              ] := (cAlias)->MK_TIPO
		oJsDet["tipoDescricao"     ] := PCPA152Disponibilidade():descricaoTipoHora((cAlias)->MK_TIPO)
		oJsDet["bloqueado"         ] := (cAlias)->MK_BLOQUE
		oJsDet["bloqueadoDescricao"] := Iif((cAlias)->MK_BLOQUE=="1",STR0050,STR0049) //"Sim" # "Não"


		aAdd(oJsRet["items"][nPos]["detail"], oJsDet)
		oJsDet := Nil

		(cAlias)->(dbSkip())
	End

	//Verifica se existem mais dados para retornar
	oJsRet["hasNext"] := (cAlias)->(!Eof())
	(cAlias)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oJsRet:toJson()
	Else
		oJsRet["_messages"] := {JsonObject():New()}
		oJsRet["_messages"][1]["code"           ] := "404"
		oJsRet["_messages"][1]["message"        ] := STR0114 //"Não existem dados de disponibilidade que atendam aos filtros informados."
		oJsRet["_messages"][1]["detailedMessage"] := ""

		aReturn[3] := oJsRet:toJson()
	EndIf

	aSize(oJsRet["items"], 0)
	FreeObj(oJsRet)
	FreeObj(oJsPos)

Return aReturn

/*/{Protheus.doc} qtdRegDisp
Verifica qual é o registro correto para paginação dos dados, considerando o agrupamento
dos registros que é realizado por RECURSO + DATA.

@type  Static Function
@author lucas.franca
@since 01/03/2023
@version P12
@param 01 nStart    , Numeric , Posição para início dos dados agrupados
@param 02 nQtdRegDel, Numeric , Quantidade de registros excluídos para considerar na paginação
@oaram 03 cFrom     , Caracter, Condição "FROM" da query de busca dos dados
@oaram 04 cWhere    , Caracter, Condição "WHERE" da query de busca dos dados
@return nStart, Numeric, Nova posição para busca dos dados, sem o agrupamento
/*/
Static Function qtdRegDisp(nStart, nQtdRegDel, cFrom, cWhere)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cBanco := TcGetDb()

	//Remove os caracteres % de controle do BeginSql, do início e do fim de cFrom e cWhere
	cFrom  := AllTrim(cFrom)
	cFrom  := Right(cFrom, Len(cFrom)-1)
	cFrom  := Left(cFrom, Len(cFrom)-1)
	cWhere := AllTrim(cWhere)
	cWhere := Right(cWhere, Len(cWhere)-1)
	cWhere := Left(cWhere, Len(cWhere)-1)

	cQuery := "SELECT SUM(TMP.TOTAL) AS TOTAL"
	If "MSSQL" $ cBanco
		cQuery += " FROM (SELECT TOP " + cValToChar(nStart)
	Else
		cQuery += " FROM (SELECT "
	EndIf
	cQuery +=          " SMR.MR_RECURSO, SMR.MR_DATDISP, COUNT(*) TOTAL"
	cQuery +=     " FROM " + cFrom
	cQuery +=    " WHERE " + cWhere
	cQuery +=    " GROUP BY SMR.MR_DATDISP, SMR.MR_RECURSO"
	cQuery +=    " ORDER BY SMR.MR_RECURSO, SMR.MR_DATDISP"

	If cBanco == "POSTGRES"
		cQuery += " LIMIT " + cValToChar( nStart )
	EndIf
	cQuery += ") TMP"

	If cBanco == "ORACLE"
		cQuery += " WHERE ROWNUM <= " + cValToChar( nStart )
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	If (cAlias)->TOTAL > nStart
		nStart := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

	nStart -= nQtdRegDel
Return nStart

/*/{Protheus.doc} DELETE DISP /api/pcp/v1/pcpa152mandis/recursos
Exclui a disponibilidade de um recurso

@type  WSMETHOD
@author lucas.franca
@since 28/02/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD DELETE DISP PATHPARAM programacao, idDisponibilidade WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := delDisp(Self:programacao, Self:idDisponibilidade)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} delDisp
Faz a exclusão de uma disponibilidade

@type  Static Function
@author lucas.franca
@since 02/03/2023
@version P12
@param 01 cProg  , Caracter, Código da programação
@param 02 cIdDisp, Caracter, Código da disponibilidade
@return aReturn, Array, Array com os dados de retorno da API
/*/
Static Function delDisp(cProg, cIdDisp)
	Local aReturn  := {.T., 200, ""}
	Local cChaveMK := ""

	cProg   := PadR(cProg  , GetSX3Cache("MR_PROG", "X3_TAMANHO"))
	cIdDisp := PadR(cIdDisp, GetSX3Cache("MR_DISP", "X3_TAMANHO"))

	SMR->(dbSetOrder(1))
	If SMR->(dbSeek(xFilial("SMR") + cProg + cIdDisp))
		cChaveMK := xFilial("SMK") + cProg + cIdDisp
		BEGIN TRANSACTION

			//Deleta os registros da SMK
			deletaSMK(cChaveMK)

			//Deleta a SMR
			RecLock("SMR", .F.)
				SMR->(dbDelete())
			SMR->(MsUnLock())

		END TRANSACTION
	EndIf
Return aReturn

/*/{Protheus.doc} deletaSMK
Percorre a SMK e deleta os registros.

@type  Static Function
@author lucas.franca
@since 09/03/2023
@version P12
@param cChave, Caracter, Chave da tabela SMK para exclusão
@return Nil
/*/
Static Function deletaSMK(cChave)
	SMK->(dbSetOrder(1))
	While SMK->(dbSeek(cChave))
		RecLock("SMK", .F.)
			SMK->(dbDelete())
		SMK->(MsUnLock())
	End
Return Nil

/*/{Protheus.doc} POST UPDDISP /api/pcp/v1/pcpa152mandis/recursos
Altera a disponibilidade de um recurso em uma data.

@type  WSMETHOD
@author lucas.franca
@since 09/03/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD POST UPDDISP PATHPARAM programacao, idDisponibilidade WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		oBody:FromJson(Self:getContent())

		aReturn := updDisp(Self:programacao, Self:idDisponibilidade, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)

Return lReturn

/*/{Protheus.doc} POST ADDDISP /api/pcp/v1/pcpa152mandis/recursos
Adiciona a disponibilidade de um recurso em uma data.

@type  WSMETHOD
@author lucas.franca
@since 09/03/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD POST ADDDISP PATHPARAM programacao WSSERVICE PCPA152MANDIS
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManDis"), Break(oError)})
	Local lReturn   := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		oBody:FromJson(Self:getContent())

		aReturn := updDisp(Self:programacao, "", oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)

Return lReturn

/*/{Protheus.doc} updDisp
Faz a alteração dos registros da disponibilidade

@type  Static Function
@author lucas.franca
@since 09/03/2023
@version P12
@param 01 cProg  , Caracter  , Código da programação
@param 02 cIdDisp, Caracter  , ID da disponibilidade
@param 03 oDados , JsonObject, JSON com os dados recebidos para alteração
@return aReturn, Array, Array com os dados do processamento para retorno do rest
/*/
Static Function updDisp(cProg, cIdDisp, oDados)
	Local aReturn   := {.T., 200, ""}
	Local cAlias    := ""
	Local cFilSMK   := xFilial("SMK")
	Local cFilSMR   := ""
	Local lInclui   := Empty(cIdDisp)
	Local lContinua := .T.
	Local nTamDisp  := GetSX3Cache("MR_DISP", "X3_TAMANHO")
	Local nIndex    := 0
	Local nTotal    := Len(oDados["detalhes"])

	cProg   := PadR(cProg  , GetSX3Cache("MR_PROG", "X3_TAMANHO"))
	cIdDisp := PadR(cIdDisp, nTamDisp)

	If lInclui
		//Valida se os dados para inclusão estão corretos
		lContinua := validaInc(@aReturn, oDados, cProg)
	EndIf

	SMR->(dbSetOrder(1))
	If lContinua .And. (lInclui .Or. SMR->(dbSeek(xFilial("SMR") + cProg + cIdDisp)))

		If lInclui
			cFilSMR    := xFilial("SMR")
			cIdDisp    := StrZero(0, nTamDisp)
			_cChavLock := "PCPA152_RESERVA_NOVO_IDDISP" + cProg

			//Faz lock para evitar gerar um ID duplicado
			While !lockByName(_cChavLock, .T., .F.)
				nIndex++
				If nIndex > 500
					_cChavLock := Nil
					aReturn[1] := .F.
					aReturn[2] := 500
					aReturn[3] := STR0115 //"Não foi possível gerar um novo ID para a inclusão da disponibilidade."
					Return aReturn
				EndIf
				Sleep(100)
			End

			//Busca última sequencia
			cAlias := GetNextAlias()
			BeginSql Alias cAlias
				SELECT MAX(SMR.MR_DISP) DISP
				  FROM %Table:SMR% SMR
				 WHERE SMR.MR_FILIAL = %Exp:cFilSMR%
				   AND SMR.MR_PROG   = %Exp:cProg%
				   AND SMR.%NotDel%
			EndSql
			If !Empty((cAlias)->(DISP))
				cIdDisp := (cAlias)->(DISP)
			EndIf
			(cAlias)->(dbCloseArea())

			cIdDisp := Soma1(cIdDisp)
		EndIf

		BEGIN TRANSACTION
			//Atualiza os totalizadores da SMR ou inclui o registro
			RecLock("SMR", lInclui)
				If lInclui
					SMR->MR_FILIAL  := xFilial("SMR")
					SMR->MR_PROG    := cProg
					SMR->MR_DISP    := cIdDisp
					SMR->MR_RECURSO := oDados["recurso"]
					SMR->MR_DATDISP := oDados["data"]
					SMR->MR_TIPO    := "1"
					SMR->MR_SITUACA := "1"
				EndIf

				SMR->MR_TEMPODI := __Hrs2Min(oDados["horaDisponivel"])
				SMR->MR_TEMPOBL := __Hrs2Min(oDados["horaBloqueada" ])
				SMR->MR_TEMPOPA := __Hrs2Min(oDados["horaParada"    ])
				SMR->MR_TEMPOEX := __Hrs2Min(oDados["horaExtra"     ])
				SMR->MR_TEMPOTO := __Hrs2Min(oDados["horaTotal"     ])
			SMR->(MsUnLock())

			//Se for alteração, irá deletar os dados da SMK e inserir novamente.
			If lInclui == .F.
				deletaSMK(cFilSMK + cProg + cIdDisp)
			EndIf

			For nIndex := 1 To nTotal
				RecLock("SMK", .T.)
					SMK->MK_FILIAL  := cFilSMK
					SMK->MK_PROG    := cProg
					SMK->MK_DISP    := cIdDisp
					SMK->MK_DATDISP := SMR->MR_DATDISP
					SMK->MK_SEQ     := oDados["detalhes"][nIndex]["sequencia"  ]
					SMK->MK_HRINI   := oDados["detalhes"][nIndex]["horaInicial"]
					SMK->MK_HRFIM   := oDados["detalhes"][nIndex]["horaFinal"  ]
					SMK->MK_TIPO    := oDados["detalhes"][nIndex]["tipo"       ]
					SMK->MK_BLOQUE  := oDados["detalhes"][nIndex]["bloqueado"  ]
				SMK->(MsUnLock())
			Next nIndex
		END TRANSACTION

		If lInclui
			unlockByName(_cChavLock, .T., .F.)
		EndIf

		//Recupera os dados do banco e monta o retorno para a API
		aReturn := getDisp(cProg, 1, 1, 0, Nil, Nil, Nil, cIdDisp)
	EndIf

Return aReturn

/*/{Protheus.doc} validaInc
Faz a validação dos dados para uma nova inclusão

@type  Static Function
@author lucas.franca
@since 14/03/2023
@version P12
@param 01 aReturn, Array   , Array para retorno da API em caso de erro
@param 02 oDados , Object  , Json recebido na API com os dados para inclusão
@param 03 cProg  , Caracter, Código da programação
@return lRet, Logic, Indica se os dados estão válidos
/*/
Static Function validaInc(aReturn, oDados, cProg)
	Local cAlias  := GetNextAlias()
	Local cParam  := ""
	Local cData   := ""
	Local cRec    := ""
	Local nTamRec := GetSX3Cache("H1_CODIGO", "X3_TAMANHO")
	Local lRet    := .T.
	Local oParam  := JsonObject():New()

	//Ajusta os tipos das informações
	oDados["data"   ] := PCPConvDat(oDados["data"], 1)
	oDados["recurso"] := PadR(oDados["recurso"], nTamRec)

	//Busca os parâmetros da T4Y para validação
	BeginSql Alias cAlias
		SELECT T4Y.T4Y_PARAM, T4Y.T4Y_VALOR, T4Y.T4Y_LISTA
		  FROM %Table:T4Y% T4Y
		 WHERE T4Y.T4Y_FILIAL = %xFilial:T4Y%
		   AND T4Y.T4Y_PROG   = %Exp:cProg%
		   AND T4Y.T4Y_PARAM IN ('dataInicial','dataFinal')
		   AND T4Y.%NotDel%
	EndSql

	While (cAlias)->(!Eof())
		cParam := Trim((cAlias)->(T4Y_PARAM))
		oParam[cParam] := PCPConvDat(Trim( (cAlias)->T4Y_VALOR ), 1)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If oParam['dataInicial'] > oDados['data'] .Or. oParam['dataFinal'] < oDados['data']
		lRet       := .F.
		aReturn[2] := 400
		aReturn[3] := I18N(STR0116, {PCPConvDat( DtoS(oParam['dataInicial']), 4 ),PCPConvDat( DtoS(oParam['dataFinal']), 4 )})//"Data da disponibilidade deve estar dentro do período de processamento da programação. Início: #1[DATAINI]# Fim: #2[DATAFIM]#"
	EndIf

	If lRet
		cData := DtoS(oDados['data'])
		cRec  := oDados["recurso"]
		BeginSql Alias cAlias
			SELECT 1
			  FROM %Table:SMR%
			 WHERE MR_FILIAL  = %xFilial:SMR%
			   AND MR_PROG    = %Exp:cProg%
			   AND MR_RECURSO = %Exp:cRec%
			   AND MR_DATDISP = %Exp:cData%
			   AND %NotDel%
		EndSql
		If (cAlias)->(!Eof())
			lRet       := .F.
			aReturn[2] := 400
			aReturn[3] := I18N(STR0118, {Trim(cRec), PCPConvDat(cData, 4)})//"Já existe disponibilidade para o recurso #1[RECURSO]# no dia #2[DATA]#. Utilize a opção de Alteração para manipular a disponibilidade."
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

	aReturn[1] := lRet
	FreeObj(oParam)
Return lRet
