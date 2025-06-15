#INCLUDE "TOTVS.CH"
#INCLUDE "GIQ0002.CH"

#DEFINE ARRAY_POS_MARK_IMG   1
#DEFINE ARRAY_POS_API_TXT    2
#DEFINE ARRAY_POS_STATUS_TXT 3
#DEFINE ARRAY_POS_IDREG      4
#DEFINE ARRAY_POS_DTENV      5
#DEFINE ARRAY_POS_HRENV      6
#DEFINE ARRAY_POS_PROG       7
#DEFINE ARRAY_POS_DTREP      8
#DEFINE ARRAY_POS_HRREP      9
#DEFINE ARRAY_POS_TIPO       10
#DEFINE ARRAY_POS_TENT       11
#DEFINE ARRAY_POS_MSGRET     12
#DEFINE ARRAY_POS_STATUS_ID  13
#DEFINE ARRAY_POS_API_ID     14
#DEFINE ARRAY_POS_MARK_ID    15
#DEFINE ARRAY_POS_RECNO      16
#DEFINE ARRAY_POS_MSGENV     17
#DEFINE ARRAY_SIZE           17

#DEFINE IN_STATUS_PENDENTE_REPROCESSAMENTO   "'1'"
#DEFINE IN_STATUS_LIMITE_TENTATIVAS_ATINGIDO "'2'"

#DEFINE TAMANHO_ITEM_TREE   150

/*/{Protheus.doc} GIQ0002
Programa para consultar as pendências de integração do Protheus com o GIQ.

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Function GIQ0002()

	Local aTabsFil   := {}
	Local aTamanhos  := {}
	Local aCoors     := FWGetDialogSize( oMainWnd )
	Local nAltura    := 0
	Local nLargura   := aCoors[4]
	Local nHeight    := aCoors[3] - 15
	Local nIndice    := 0
	Local oDialog    := Nil
	Local oCheckAll  := Nil
	Local oPanelSup  := Nil
	Local oPanelInf  := Nil
	Local oPanelEsq  := Nil
	Local oPanelDir  := Nil
	Local oPnlGrid   := Nil
	Local oPnlMemos  := Nil

	Local oFont      := TFont():New("Arial", , -12, , .F.)

	Private oGiqFil    := GIQ0002FIL():NEW({||FiltraInfo()})
	Private aDados     := {}
	Private aColunas   := {}
	Private aAllReg	   := {}
	Private aChecks	   := {}
	Private cMsgRet    := ""
	Private lChange    := .F.
	Private lCBAllGrid := .T.
	Private nRecnoMemo := 0
	Private oMsgRet    := Nil
	Private oMsgEnv    := Nil
	Private oList      := Nil
	Private oTabsFil   := JsonObject():New()
	Private oJsonDesc  := JsonObject():New()

	oTabsFil["MATA010GIQ"                   ] := { STR0001, 1} //"Produtos"
	oTabsFil["MATA020GIQ"                   ] := { STR0002, 2} //"Fornecedores"
	oTabsFil["SolicitacaoInspecaoNFE"       ] := { STR0003, 3} //"Solicitação Inspeção Entrada"
	oTabsFil["retornaLaudosGeraisPendentes" ] := { STR0004, 4} //"Laudos Gerais"
	oTabsFil["ProcessaBaixaCQxMATA175"      ] := { STR0005, 5} //"Baixa CQ"
	
	//Define a janela da tela
	oDialog := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0006,,,,nOr(WS_VISIBLE,WS_POPUP),,CLR_WHITE,,,.T.,,,,,,.T.) //"Pedencias Integração GIQ"

	//Não fecha com ESC
	oDialog:lEscClose := .F.

	//Definição dos paineis utilizados na estruturação dos componentes em tela.
	//Painel superior, com filtros e dados.
	oPanelSup := TPanel():New(0,0,,oDialog,,,,,, nLargura/2, (nHeight/2), .F., .T.)
	oPanelSup:Align := CONTROL_ALIGN_TOP
	//Painel Lateral esquerdo
	oPanelEsq  := TPanel():New(0,0,,oPanelSup,,,,,, 110, oPanelSup:nHeight, .F.,.T.)
	//Painel da direita, com os dados.
	oPanelDir  := TPanel():New(0,110,,oPanelSup,,,,,,(oPanelSup:nWidth/2)-110, (oPanelSup:nHeight/2), .F.,.T.)
	//Painel para a GRID
	oPnlGrid   := TPanel():New(0,0,,oPanelDir,,,,,,(oPanelDir:nWidth/2), (oPanelDir:nHeight/2)*0.7, .F.,.F. )
	//Painel para a mensagem do erro
	oPnlMemos  := TPanel():New((oPanelDir:nHeight/2)*0.7,0,,oPanelDir,,,,,,(oPanelDir:nWidth/2), (oPanelDir:nHeight/2)*0.3, .F.,.F. )
	//Painel Inferior
	oPanelInf  := TPanel():New((nHeight/2),0,,oDialog,,,,,, (nLargura/2), 20, .T.,.F.)
	oPanelInf:Align := CONTROL_ALIGN_BOTTOM

	//Define os CHECKBOX de filtro, no lado esquerdo da tela
	//Checkbox para marcar/desmarcar todos os filtros
	@ 05, 05 CHECKBOX oCheckAll VAR lChange PROMPT STR0007 WHEN PIXEL OF oPanelEsq SIZE 100,015 MESSAGE "" //"Marca/Desmarca todos"
	oCheckAll:bChange := {|| ChangCheck(lChange)}
	//Adiciona os CHECKBOX, de acordo com o que foi definido no oTabsFil
	aTabsFil := oTabsFil:GetNames()
	aTabsFil := aSort(aTabsFil,,,{|x,y| oTabsFil[x][2] < oTabsFil[y][2]})
	nAltura  := 20
	For nIndice := 1 To Len(aTabsFil)
		aAdd(aChecks , GIQ0002C():New(oPanelEsq, aTabsFil[nIndice], oTabsFil[aTabsFil[nIndice]][1], nAltura, 05, {|| buscaDados(), FiltraInfo()}))
		nAltura += 15
	Next nIndice

	//Monta o componente da GRID
	aAdd(aColunas ," ")
	aAdd(aTamanhos, 10)
	aAdd(aColunas ,STR0008) //"Transação"
	aAdd(aTamanhos, 70)
	aAdd(aColunas ,STR0009) //"Status"
	aAdd(aTamanhos, 60)
	aAdd(aColunas ,STR0010) //"Identificador"
	aAdd(aTamanhos, 100)
	aAdd(aColunas ,STR0011) //"Data Envio"
	aAdd(aTamanhos, 40)
	aAdd(aColunas ,STR0012) //"Hora Envio"
	aAdd(aTamanhos, 40)
	aAdd(aColunas ,STR0013) //"Programa"
	aAdd(aTamanhos, 40)
	aAdd(aColunas ,STR0014) //"Data Reprocessamento"
	aAdd(aTamanhos, 70)
	aAdd(aColunas ,STR0015) //"Hora Reprocessamento"
	aAdd(aTamanhos, 70)
	aAdd(aColunas , STR0016) //"Tipo"
	aAdd(aTamanhos, 70)
	aAdd(aColunas , STR0017) //"Tentativas"
	aAdd(aTamanhos, 40)

	oList := TWBrowse():New(0, 0, 500, 500, , aColunas, aTamanhos, oPnlGrid,,,,,,,,,,,, .F.,, .T.,, .F.,,,)
	oList:Align := CONTROL_ALIGN_ALLCLIENT

	//Inicializa o array de dados.
	initDados()

	oList:SetArray(aDados)
	oList:bLine        := {|| bLineData(oList:nAt, Len(aColunas)) }
	oList:bChange      := {|| AlteraMemo(oList:nAt) }
	oList:bLDblClick   := {|| TrocaCheck(oList:nAt) }
	oList:bHeaderClick := {|oBrw, nCol| IIf(nCol == 1, MarcaTodos(oBrw), Nil)}

	//Monta o componente para exibição dos dados trafegados
	oMsgEnv := DbTree():New(13, 0, oPnlMemos:nHeight/2, (oPnlMemos:nWidth/4)-2, oPnlMemos, {|| }, , .F., , oFont, PadR(STR0019,60) + ";" + PadR(STR0019,80)) //"Campo" + "Valor"
	oMsgEnv:SetScroll(1,.T.) // Habilita a barra de rolagem horizontal
	oMsgEnv:SetScroll(2,.T.) // Habilita a barra de rolagem vertical
	TSay():New(5, 1, {|| STR0018 }, oPnlMemos, , , , , , .T., , , 100, 20) //"Dados da Transação:"

	//Monta o componente para exibição da mensagem de retorno
	oMsgRet := tMultiget():new(13, (oPnlMemos:nWidth/4)+2, {|u| If(PCount()==0,cMsgRet,cMsgRet:=u)}, oPnlMemos, (oPnlMemos:nWidth/4)-2, (oPnlMemos:nHeight/2)-13,,,,,,.T.,,,{||.T.},,,.T.)
	TSay():New(5, (oPnlMemos:nWidth/4)+3, {|| STR0021 }, oPnlMemos, , , , , , .T., , , 100, 20)  //"Mensagem:"

	//Monta os botões de ação, na parte inferior da tela
	@ 05,(nLargura/2)-390 BUTTON oBtn PROMPT STR0022 SIZE 60, 12 WHEN (.T.) ACTION (buscaDados(),FiltraInfo(),AlteraMemo(oList:nAt,.T.)) OF oPanelInf PIXEL //"Atualizar"
	@ 05,(nLargura/2)-325 BUTTON oBtn PROMPT STR0023 SIZE 60, 12 WHEN (.T.) ACTION (oGiqFil:TelaFiltro(),AlteraMemo(oList:nAt,.T.))      OF oPanelInf PIXEL //"Filtro"
	@ 05,(nLargura/2)-260 BUTTON oBtn PROMPT STR0024 SIZE 60, 12 WHEN (.T.) ACTION (Excluir(),AlteraMemo(oList:nAt,.T.))                 OF oPanelInf PIXEL //"Excluir"
	@ 05,(nLargura/2)-195 BUTTON oBtn PROMPT STR0025 SIZE 60, 12 WHEN (.T.) ACTION (Reprocessa(),AlteraMemo(oList:nAt,.T.))              OF oPanelInf PIXEL //"Reprocessar"
	@ 05,(nLargura/2)-130 BUTTON oBtn PROMPT STR0026 SIZE 60, 12 WHEN (.T.) ACTION (Pergunte("GIQ0002",.T.))                             OF oPanelInf PIXEL //"Parâmetros"
	@ 05,(nLargura/2)-65  BUTTON oBtn PROMPT STR0027 SIZE 60, 12 WHEN (.T.) ACTION (oDialog:End())                                       OF oPanelInf PIXEL //"Sair"

	//Abre a tela
	oDialog:Activate(,,,.T.,,,{|| oList:Refresh(), AlteraMemo(oList:nAt) } )

	FreeObj(oTabsFil)
	oTabsFil := NIL

	FreeObj(oJsonDesc)
	oJsonDesc := NIL

Return Nil

/*/{Protheus.doc} initDados
Verifica se é necessário adicionar um registro em branco no array aDados

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function initDados()
	Local nIndex := 0

	If Len(aDados) == 0
		aAdd(aDados,Array(ARRAY_SIZE))

		For nIndex := 1 To ARRAY_SIZE
			If nIndex == ARRAY_POS_MARK_IMG
				aDados[1][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBOK" )
			ElseIf nIndex == ARRAY_POS_DTENV .Or. nIndex == ARRAY_POS_DTREP
				aDados[1][nIndex] := SToD(" ")
			ElseIf nIndex == ARRAY_POS_RECNO
				aDados[1][nIndex] := 0
			Else
				aDados[1][nIndex] := ""
			EndIf
		Next nIndex
		aDados[1][ARRAY_POS_MARK_ID] := .T.
	EndIf
Return

/*/{Protheus.doc} bLineData
Monta linha de dados para o objeto TWBrowse

@author brunno.costa / renan.roeder
@since  09/09/2021

@param nAt     , Numeric, Linha posicionada na grid
@param nColunas, Numeric, Total de colunas da grid
@return aRet   , Array  , Array com os dados para exibição.
/*/
Static Function bLineData(nAt,nColunas)
	Local aRet   := {}
	Local nIndex := 0

	For nIndex := 1 To nColunas
		If nIndex == ARRAY_POS_TIPO
			If aDados[nAt][ARRAY_POS_TIPO] == '1'
				aAdd(aRet,STR0028) //"Inclusão"
			ElseIf aDados[nAt][ARRAY_POS_TIPO] == '2'
				aAdd(aRet,STR0029) //"Exclusão"
			ElseIf aDados[nAt][ARRAY_POS_TIPO] == '3'
				aAdd(aRet,STR0030) //"Atualização"
			Else
				aAdd(aRet," ")
			EndIf
		ElseIf nIndex == ARRAY_POS_IDREG .AND. AllTrim(aDados[nAt][ARRAY_POS_API_ID]) == 'retornaLaudosGeraisPendentes'
			aAdd(aRet," ")
		Else
			aAdd(aRet,aDados[nAt][nIndex])
			
		EndIf
	Next nIndex
Return aRet

/*/{Protheus.doc} MarcaTodos
Marca/Desmarca todos os registros da grid.

@author brunno.costa / renan.roeder
@since  09/09/2021

@param oBrw, Object, Objeto da GRID exibida em tela
/*/
Static Function MarcaTodos(oBrw)
	Local cImg   := Iif(lCBAllGrid,"LBOK","LBNO")
	Local nIndex := 0
	Local nTotal := 0

	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		aDados[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), cImg )
		aDados[nIndex][ARRAY_POS_MARK_ID ] := lCBAllGrid
	Next nIndex

	nTotal := Len(aAllReg)
	For nIndex := 1 To nTotal
		aAllReg[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), cImg )
		aAllReg[nIndex][ARRAY_POS_MARK_ID ] := lCBAllGrid
	Next nIndex

	lCBAllGrid := !lCBAllGrid

	oBrw:Refresh()

Return Nil

/*/{Protheus.doc} AlteraMemo
Atualiza o conteúdo do campo memo em tela

@author brunno.costa / renan.roeder
@since  09/09/2021

@param 01 nAt    , Numeric, Linha posicionada da grid
@param 02 lReload, Logical, Indica se deve forçar o recarregamento do Memo
/*/
Static Function AlteraMemo(nAt, lReload)

	Default lReload    := .F.

	//Se não tem registro selecionado, limpa os campos
	If Empty(aDados[nAt][ARRAY_POS_API_ID])
		nRecnoMemo := 0
		cMsgRet    := ""

		SetFocus(oMsgRet:HWND)
		oMsgEnv:Reset()

	Else
		//Só atualiza se mudar o registro selecionado
		If nRecnoMemo <> aDados[nAt][ARRAY_POS_RECNO] .Or. lReload
			nRecnoMemo := aDados[nAt][ARRAY_POS_RECNO]
			cMsgRet    := aDados[nAt][ARRAY_POS_MSGRET]
			SetFocus(oMsgRet:HWND)
			TrataJson(nAt)
		EndIf
	EndIf

	SetFocus(oMsgEnv:HWND)
	SetFocus(oList:HWND)

Return Nil

/*/{Protheus.doc} TrocaCheck
Inverte a seleção do checkbox em um registro da grid

@author brunno.costa / renan.roeder
@since  09/09/2021

@param nAt, Numeric, Linha posicionada da grid
/*/
Static Function TrocaCheck(nAt)
	Local nIndex := 0
	Local nTotal := 0

	//Inverte o valor do check
	If aDados[nAt][ARRAY_POS_STATUS_ID] == "3"
		HELP(' ', 1, "Help",, STR0031,2, 0, , , , , , {}) //"Registros que estão com o status 'Processado' não podem ser marcados para reprocessar."
	Else
		aDados[nAt][ARRAY_POS_MARK_ID] := !aDados[nAt][ARRAY_POS_MARK_ID]

		If aDados[nAt][ARRAY_POS_MARK_ID]
			aDados[nAt][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBOK" )
		Else
			aDados[nAt][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBNO" )
		EndIf

		nTotal := Len(aAllReg)
		For nIndex := 1 To nTotal
			If aAllReg[nIndex][ARRAY_POS_RECNO] == aDados[nAt][ARRAY_POS_RECNO]

				//Inverte o valor do check
				aAllReg[nIndex][ARRAY_POS_MARK_ID] := aDados[nAt][ARRAY_POS_MARK_ID]

				If aDados[nAt][ARRAY_POS_MARK_ID]
					aAllReg[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBOK" )
				Else
					aAllReg[nIndex][ARRAY_POS_MARK_IMG] := LoadBitmap( GetResources(), "LBNO" )
				EndIf
				Exit
			EndIf
		Next
	EndIf
Return Nil

/*/{Protheus.doc} ChangCheck
Inverte a seleção do checkbox para filtro dos dados

@author brunno.costa / renan.roeder
@since  09/09/2021

@param lTipo, Logic, Identifica se os checkbox de filtro devem ser marcados ou desmarcados.
/*/
Static Function ChangCheck(lTipo)
	Local nIndex := 0

	For nIndex := 1 To Len(aChecks)
		aChecks[nIndex]:lValue := lTipo
		aChecks[nIndex]:oCheckBox:Refresh()
	Next nIndex

	buscaDados()
	FiltraInfo()
Return .T.

/*/{Protheus.doc} buscaDados
Dispara a consulta dos dados no banco.

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function buscaDados()
	Processa( {|| consultar() }, STR0032, STR0033,.F.) //"Aguarde..." + "Executando consulta..."
Return .T.

/*/{Protheus.doc} consultar
Consulta dos dados no banco.

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function consultar()
	Local cAliasTop := GetNextAlias()
	Local cAliasCnt := GetNextAlias()
	Local cQueryCnt := ""
	Local lPrimeiro := .T.
	Local nIndex    := 0
	Local nTotal    := 0
	Local cFiltro   := ""

	aSize(aAllReg,0)
	aSize(aDados ,0)

	For nIndex := 1 To Len(aChecks)
		If aChecks[nIndex]:lValue
			If lPrimeiro
				cFiltro := "(("
				lPrimeiro := .F.
			Else
				cFiltro += " OR ("
			EndIf

			cFiltro += " QF0.QF0_API = '" + aChecks[nIndex]:cId + "'"
			If !Empty(oGiqFil:dDataAte)
				cFiltro += " AND QF0.QF0_DTENV <= '" + DtoS(oGiqFil:dDataAte) + "' "
			EndIf
			If !Empty(oGiqFil:dDataDe)
				cFiltro += " AND QF0.QF0_DTENV >= '" + DtoS(oGiqFil:dDataDe) + "' "
			EndIf
			If !Empty(oGiqFil:cPrograma)
				cFiltro += " AND QF0.QF0_PROG = '" + oGiqFil:cPrograma + "' "
			EndIf

			cFiltro += " AND QF0.QF0_STATUS IN(''"

			If oGiqFil:lPendente
				cFiltro += "," + IN_STATUS_PENDENTE_REPROCESSAMENTO
			EndIf
			If oGiqFil:lLimiteAtingido
				cFiltro += "," + IN_STATUS_LIMITE_TENTATIVAS_ATINGIDO
			EndIf
			cFiltro += ")" //Fecha o comando IN de filtro do QF0_STATUS

			cFiltro += ")"
		EndIf
	Next nI
	If !Empty(cFiltro)
		cFiltro := cFiltro + ") "
	Else
		cFiltro := " 1 = 1 "
	EndIf

	cQueryCnt := "SELECT COUNT(*) TOTAL "
	cQueryCnt +=  " FROM (SELECT 1 TOTAL "
	cQueryCnt +=          " FROM " + RetSqlName("QF0") + " QF0 "
	cQueryCnt +=         " WHERE QF0.QF0_FILIAL = '" + xFilial("QF0") + "' "
	cQueryCnt +=           " AND QF0.D_E_L_E_T_ = ' ' "
	cQueryCnt +=           " AND " + cFiltro + " ) T"


	cFiltro +=  " ORDER BY QF0.QF0_FILIAL ASC, "
	cFiltro +=     " (CASE QF0.QF0_DTREP WHEN '' THEN QF0.QF0_DTENV ELSE QF0.QF0_DTREP END) DESC, "
	cFiltro +=     " (CASE QF0.QF0_HRREP WHEN '' THEN QF0.QF0_HRENV ELSE QF0.QF0_HRREP END) DESC, "
	cFiltro +=     " QF0.QF0_API ASC "

	cFiltro := "% " + cFiltro + " %"

	BeginSql Alias cAliasTop
		%noparser%
		column QF0_DTENV as Date
		column QF0_DTREP as Date
		SELECT QF0.QF0_API,
		       QF0.QF0_STATUS,
		       QF0.QF0_IDREG,
		       QF0.QF0_DTENV,
		       QF0.QF0_HRENV,
		       QF0.QF0_PROG,
		       QF0.QF0_MSGREI,
		       QF0.QF0_DTREP,
		       QF0.QF0_HRREP,
		       QF0.R_E_C_N_O_,
			   QF0.QF0_TIPO,
			   QF0.QF0_TENT,
		       QF0.QF0_MSGRER,
			   QF0.QF0_DADOS
		  FROM %table:QF0% QF0
		 WHERE QF0.QF0_FILIAL = %xfilial:QF0%
		   AND QF0.%notDel%
		   AND %Exp:cFiltro%
	EndSql

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasCnt,.T.,.T.)
	nTotal := (cAliasCnt)->(TOTAL)
	(cAliasCnt)->(dbCloseArea())

	ProcRegua(nTotal)

	While !(cAliasTop)->(Eof())
		IncProc()

		aAdd(aDados, Array(ARRAY_SIZE))

		nTotal := Len(aDados)

		aDados[nTotal][ARRAY_POS_IDREG    ] := Rtrim((cAliasTop)->QF0_IDREG)
		aDados[nTotal][ARRAY_POS_DTENV    ] := (cAliasTop)->QF0_DTENV
		aDados[nTotal][ARRAY_POS_HRENV    ] := (cAliasTop)->QF0_HRENV
		aDados[nTotal][ARRAY_POS_PROG     ] := AllTrim((cAliasTop)->QF0_PROG)
		aDados[nTotal][ARRAY_POS_DTREP    ] := (cAliasTop)->QF0_DTREP
		aDados[nTotal][ARRAY_POS_HRREP    ] := (cAliasTop)->QF0_HRREP

		If !Empty((cAliasTop)->QF0_MSGRER)
			aDados[nTotal][ARRAY_POS_MSGRET   ] := AllTrim((cAliasTop)->QF0_MSGRER)
		else
			aDados[nTotal][ARRAY_POS_MSGRET   ] := AllTrim((cAliasTop)->QF0_MSGREI)	
		EndIf

		aDados[nTotal][ARRAY_POS_STATUS_ID] := (cAliasTop)->QF0_STATUS
		aDados[nTotal][ARRAY_POS_API_ID   ] := AllTrim((cAliasTop)->QF0_API)
		aDados[nTotal][ARRAY_POS_RECNO    ] := (cAliasTop)->R_E_C_N_O_
		aDados[nTotal][ARRAY_POS_MSGENV   ] := (cAliasTop)->QF0_DADOS
		aDados[nTotal][ARRAY_POS_TIPO     ] := (cAliasTop)->QF0_TIPO
		aDados[nTotal][ARRAY_POS_TENT     ] := (cAliasTop)->QF0_TENT

		If aDados[nTotal][ARRAY_POS_STATUS_ID] == "3"
			aDados[nTotal][ARRAY_POS_MARK_IMG ] := LoadBitmap( GetResources(), "LBNO" )
			aDados[nTotal][ARRAY_POS_MARK_ID  ] := .F.
		Else
			aDados[nTotal][ARRAY_POS_MARK_IMG ] := LoadBitmap( GetResources(), "LBOK" )
			aDados[nTotal][ARRAY_POS_MARK_ID  ] := .T.
		EndIf

		If aDados[nTotal][ARRAY_POS_STATUS_ID] == "1"
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := STR0034 //"Pendente"
		ElseIf aDados[nTotal][ARRAY_POS_STATUS_ID] == "2"
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := STR0035 //"Limite Tentativas Atingido"
		ElseIf aDados[nTotal][ARRAY_POS_STATUS_ID] == "3"
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := STR0036 //"Processado"
		Else
			aDados[nTotal][ARRAY_POS_STATUS_TXT] := ""
		EndIf

		If oTabsFil[aDados[nTotal][ARRAY_POS_API_ID]] != Nil
			aDados[nTotal][ARRAY_POS_API_TXT] := oTabsFil[aDados[nTotal][ARRAY_POS_API_ID]][1]
		Else
			aDados[nTotal][ARRAY_POS_API_TXT] := (cAliasTop)->QF0_API
		EndIf

		(cAliasTop)->(dbSkip())
	End

	aAllReg := aClone(aDados)

	(cAliasTop)->(dbCloseArea())

	initDados()

	lCBAllGrid := .T.

	oList:nAt  := 1
	oList:Refresh()
	AlteraMemo(oList:nAt)

Return

/*/{Protheus.doc} FiltraInfo
Filtra os dados nos arrays

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function FiltraInfo()
	Local aFiltros   := {}
	Local nIndRegs   := 0
	Local nIndFilt   := 0
	Local nCount     := 0
	Local oIndexFilt := JsonObject():New()

	For nIndRegs := 1 To Len(aChecks)
		If aChecks[nIndRegs]:lValue
			aAdd(aFiltros,aChecks[nIndRegs]:cId)
			nCount++
			oIndexFilt[AllTrim(aChecks[nIndRegs]:cId)] := nCount
		EndIf
	Next nIndRegs

	aSize(aDados,0)

	For nIndRegs := 1 To Len(aAllReg)

		nIndFilt := oIndexFilt[AllTrim(aAllReg[nIndRegs][ARRAY_POS_API_ID])]

		//Se a API não estiver no índice de filtros é pq não foi selecionada na consulta.
		If nIndFilt == Nil
			Loop
		EndIf

		//Verifica o filtro de PROGRAMA.
		If !Empty(oGiqFil:cPrograma) .And. !(AllTrim(oGiqFil:cPrograma) == aAllReg[nIndRegs][ARRAY_POS_PROG])
			Loop
		EndIf

		//Verifica o filtro de registros PENDENTES
		If !oGiqFil:lPendente .And. aAllReg[nIndRegs][ARRAY_POS_STATUS_ID] == "1"
			Loop
		EndIf

		//Verifica o filtro de registros AGUARDANDO SCHEDULE
		If !oGiqFil:lLimiteAtingido .And. aAllReg[nIndRegs][ARRAY_POS_STATUS_ID] == "2"
			Loop
		EndIf

		//Verifica filtro de DATAS. Se estiver dentro do filtro, adiciona o registro no array de tela.
		IF oGiqFil:dDataDe <= aAllReg[nIndRegs][ARRAY_POS_DTENV] .And. oGiqFil:dDataAte >= aAllReg[nIndRegs][ARRAY_POS_DTENV]
			aAdd(aDados,aClone(aAllReg[nIndRegs]))
		EndIf
	Next nIndRegs

	initDados()

	oList:Refresh()
	AlteraMemo(oList:nAt)

	FreeObj(oIndexFilt)
	oIndexFilt := Nil

Return Nil

/*/{Protheus.doc} GIQ0002Fil
Classe para montar tela de filtros

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Class GIQ0002FIL
	//Método construtor da classe
	Method New(bOk) Constructor

	//Propriedades
	Data bOk
	Data cId
	Data cPrograma
	Data cOldPrograma
	Data dDataDe
	Data dDataAte
	Data dOldDataDe
	Data dOldDataAte
	Data lLimiteAtingido
	Data lOldLimiteAtingido
	Data lPendente
	Data lOldPendente

	//Métodos
	Method TelaFiltro()
	Method Restaura()
EndClass

/*/{Protheus.doc} New
Método construtor da classe GIQ0002Fil

@author brunno.costa / renan.roeder
@since  09/09/2021

@param bOk    , CodeBlock, Bloco de código que será excecutado na confirmação do filtro.
/*/
Method New(bOk) Class GIQ0002FIL

	Self:bOk             := bOk
	Self:cPrograma       := Space(255)
	Self:dDataDe         := SToD("20000101")
	Self:dDataAte        := SToD("29990101")
	Self:lLimiteAtingido := .T.
	Self:lPendente       := .T.

Return Self

/*/{Protheus.doc} Dialog
Construção da tela de filtros

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Method TelaFiltro() Class GIQ0002FIL
	Local oBtn    := Nil
	Local oGroup  := Nil
	Local oDlgFil := Nil

	//Armazena os valores atuais para restaurar caso o usuário clique em cancelar
	Self:cOldPrograma       := Self:cPrograma
	Self:dOldDataDe         := Self:dDataDe
	Self:dOldDataAte        := Self:dDataAte
	Self:lOldLimiteAtingido := Self:lLimiteAtingido
	Self:lOldPendente       := Self:lPendente

	DEFINE DIALOG oDlgFil TITLE "Filtro" FROM 0,0 TO 190,429 PIXEL

	//Faixa data
	oGroup := TGroup():New(05, 09, 30, 204, STR0037, oDlgFil,,, .T.) //"Datas"
	TGet():New(13, 13 , {|u| If(PCount()==0,Self:dDataDe ,Self:dDataDe :=u)}, oGroup, 60, 10, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,, "Self:dDataDe",,,,.T.,,, STR0038, 2) //"Envio de:"
	TGet():New(13, 110, {|u| If(PCount()==0,Self:dDataAte,Self:dDataAte:=u)}, oGroup, 60, 10, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"Self:dDataAte",,,,.T.,,, STR0039, 2) //"Envio até:"

	//Filtro de status
	oGroup := TGroup():New(32, 09, 53, 204, STR0040, oDlgFil,,, .T.) //"Status"


	TCheckBox():New(42, 13, STR0041, {|| Self:lPendente }, oGroup, 80,,, ; //"Pendente Reprocessamento"
				   {|| Self:lPendente:=!Self:lPendente},,,,,,, STR0042)    //"Quando marcado, irá exibir os registros com status igual à 'Pendente Reprocessamento'."

	TCheckBox():New(42, 100, STR0043, {|| Self:lLimiteAtingido }, oGroup, 80,,, ;   //"Limite Tentativas Atingido"
				   {|| Self:lLimiteAtingido:=!Self:lLimiteAtingido},,,,,,, STR0044) //"Quando marcado, irá exibir os registros com status igual à 'Limite Tentativas Atingido'."

	//Programa
	TGet():New(58, 09, {|u| If(PCount()==0,Self:cPrograma,Self:cPrograma:=u)}, oDlgFil, 171, 10,,, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"Self:cPrograma",,,,.T.,,, STR0045, 2) //"Programa:"

	//Botão Confirmar
	@ 77, 009 BUTTON oBtn PROMPT STR0046 SIZE 63,15 WHEN (.T.) ACTION {||Eval(Self:bOk),oDlgFil:End()} OF oDlgFil PIXEL //"Confirmar"
	//Botão Cancelar
	@ 77, 075 BUTTON oBtn PROMPT STR0047 SIZE 61,15 WHEN (.T.) ACTION {||Self:Restaura(),oDlgFil:End()} OF oDlgFil PIXEL //"Cancelar"

	ACTIVATE MSDIALOG oDlgFil CENTERED


Return Nil

/*/{Protheus.doc} Restaura
Restaura os valores da tela.

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Method Restaura() Class GIQ0002FIL
	Self:cPrograma       := Self:cOldPrograma
	Self:dDataDe         := Self:dOldDataDe
	Self:dDataAte        := Self:dOldDataAte
	Self:lLimiteAtingido := Self:lOldLimiteAtingido
	Self:lPendente       := Self:lOldPendente
Return

/*/{Protheus.doc} Reprocessa
Executa o reprocessamento das mensagens.

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function Reprocessa()
	Local nIndex  := 0
	Local nTotal  := 0
	Local nQtdReg := 0

	nTotal := Len(aDados)
	If nTotal == 1 .And. aDados[1][ARRAY_POS_API_ID] == ""
		//Tratativa para quando não existem dados na tela.
		HELP(' ',1,"HELP",,STR0048,2,0,,,,,, {STR0049}) //"Não existem dados consultados." + "Execute a pesquisa antes de realizar o processamento."
		Return Nil
	EndIf

	For nIndex := 1 To nTotal
		If aDados[nIndex][ARRAY_POS_MARK_ID]
			nQtdReg++
		EndIf
	Next nIndex

	If nQtdReg == 0
		HELP(' ',1,"NAOMARCADO",,STR0050,2,0,,,,,, {STR0051}) //"Nenhum registro selecionado para reprocessar" + "Selecione os registros para executar o reprocessamento."
		Return
	ElseIf nQtdReg > 0
		If !MsgYesNo(STR0051 + " " + cValToChar(nQtdReg) + " " + STR0052, STR0053) // "Deseja reprocessar o(s)" + "registro(s) selecionado(s)?" + "Atenção"
			Return Nil
		EndIf
	EndIf

	Processa( {|| ExecReproc() }, STR0054, STR0055,.F.) //"Aguarde..." + "Reprocessando registros..."
Return Nil

/*/{Protheus.doc} ExecReproc
Executa o reprocessamento das mensagens.

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function ExecReproc()
	Local nIndex     := 0
	Local nTotal     := 0

	//Monta JSON com os dados que serão reprocessados
	nTotal := Len(aDados)
	ProcRegua((nTotal*3)+2)
	DbSelectArea("QF0")
	For nIndex := 1 To nTotal
		IncProc()
		If aDados[nIndex][ARRAY_POS_MARK_ID]			
			QF0->(DbGoTo(aDados[nIndex][ARRAY_POS_RECNO]))
			IntegraGIQ():enviaPendenciaParaGIQ(.T.)
		EndIf
	Next nIndex

	IntegraGIQ():limpaRegistrosExcluidos()
	QF0->(DbCloseArea())

	//Refaz a consulta para exibir os dados atualizados em tela
	IncProc()
	buscaDados()
	IncProc()
	FiltraInfo()
Return Nil

/*/{Protheus.doc} Excluir
Marca Registros Excluídos no Banco de Dados

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function Excluir()
	Local nIndex  := 0
	Local nTotal  := 0
	Local nQtdReg := 0

	nTotal := Len(aDados)
	If nTotal == 1 .And. aDados[1][ARRAY_POS_API_ID] == ""
		//Tratativa para quando não existem dados na tela.
		HELP(' ',1,"HELP",,STR0056,2,0,,,,,, {STR0057}) //"Não existem dados consultados." + "Execute a pesquisa antes de realizar o processamento."
		Return Nil
	EndIf

	For nIndex := 1 To nTotal
		If aDados[nIndex][ARRAY_POS_MARK_ID]
			nQtdReg++
		EndIf
	Next nIndex

	If nQtdReg == 0
		HELP(' ',1,"NAOMARCADO",,STR0058,2,0,,,,,, {STR0059}) //"Nenhum registro selecionado para excluir" + "Selecione os registros para executar a exclusão."
		Return
	ElseIf nQtdReg > 0
		If !MsgYesNo(STR0060 + " " + cValToChar(nQtdReg) + " ", STR0063) //"Deseja excluir o(s)" + "registro(s) selecionado(s)?" + "Atenção"
			Return Nil
		EndIf
	EndIf

	Processa( {|| ExecExcl() }, STR0062, STR0063,.F.) //"Aguarde..." + "Excluindo registros..."
Return Nil

/*/{Protheus.doc} ExecExcl
Executa marcação de registros excluídos no banco de dados.

@author brunno.costa / renan.roeder
@since  09/09/2021
/*/
Static Function ExecExcl()
	Local nIndex     := 0
	Local nTotal     := 0

	//Monta JSON com os dados que serão reprocessados
	nTotal := Len(aDados)
	ProcRegua((nTotal*3)+2)
	DbSelectArea("QF0")
	For nIndex := 1 To nTotal
		IncProc()
		If aDados[nIndex][ARRAY_POS_MARK_ID]			
			QF0->(DbGoTo(aDados[nIndex][ARRAY_POS_RECNO]))
			RecLock("QF0", .F.)
			QF0->(DbDelete())
			QF0->(MsUnlock())
		EndIf
	Next nIndex

	QF0->(DbCloseArea())

	//Refaz a consulta para exibir os dados atualizados em tela
	IncProc()
	buscaDados()
	IncProc()
	FiltraInfo()
Return Nil

/*/{Protheus.doc} TrataJson
Trata a mensagem Json para ser exibida

@author brunno.costa / renan.roeder
@since  09/09/2021

@param nAt, Numeric, Linha posicionada da grid
/*/
Static Function TrataJson(nAt)

	Local cError   := ""
	Local oJsonMsg := JsonObject():New()

	oMsgEnv:BeginUpdate()
	oMsgEnv:Reset()

	If !Empty(aDados[nAt][ARRAY_POS_MSGENV])
		cError := oJsonMsg:FromJson(aDados[nAt][ARRAY_POS_MSGENV])

		If cError == Nil
			aDados[nAt][ARRAY_POS_API_ID] := AllTrim(aDados[nAt][ARRAY_POS_API_ID])
			
			//Informa a descrição dos atributos que agrupam as listas (inexistentes no mapfields da API)
			Do Case
				Case aDados[nAt][ARRAY_POS_API_ID] == "MATA010GIQ"
					oJsonDesc["MATA010GIQ"] := STR0001 //"Produtos"

				Case aDados[nAt][ARRAY_POS_API_ID] == "MATA020GIQ"
					oJsonDesc["MATA020GIQ"] := STR0002 //"Fornecedores"

				Case aDados[nAt][ARRAY_POS_API_ID] == "SolicitacaoInspecaoNFE"
					oJsonDesc["SolicitacaoInspecaoNFE"] := STR0003 //"Solicitação Inspeção Entrada"

				Case aDados[nAt][ARRAY_POS_API_ID] == "retornaLaudosGeraisPendentes"
					oJsonDesc["retornaLaudosGeraisPendentes"] := STR0004 //"Laudos Gerais"

				Case aDados[nAt][ARRAY_POS_API_ID] == "ProcessaBaixaCQxMATA175"
					oJsonDesc["ProcessaBaixaCQxMATA175"] := STR0005 //"Baixa CQ"

			EndCase

			MontaTree(oJsonMsg, 1)
		Else
			oMsgEnv:AddItem(PadR(cError, TAMANHO_ITEM_TREE), , , , , , 1)
		EndIf
	EndIf

	oMsgEnv:EndUpdate()

	FreeObj(oJsonMsg)
	oJsonMsg := Nil

Return cError

/*/{Protheus.doc} MontaTree
Monta uma tree de acordo com o objeto oJson

@author brunno.costa / renan.roeder
@since  09/09/2021

@param 01 oJson , Object , objeto JSON a ser convertido para tree
@param 02 nNivel, Numeric, indica onde os filhos devem ser incluídos em relação ao posicionado: 1 - Mesmo nível
                                                                                                2 - Nível abaixo
/*/
Static Function MontaTree(oJson, nNivel)

	Local aNames    := oJson:GetNames()
	Local nIndNames := 0
	Local nIndArray := 0
	Local nLenNames := 0
	Local cNode     := ""
	Local cNodeAgr  := ""
	Local cNodePri  := ""

	//Ordena as chaves pois o GetNames
	aSort(aNames)

	//Percorre as chaves do JSON
	nLenNames := Len(aNames)
	For nIndNames := 1 To nLenNames
		//Se não existe descrição, usa a chave como descrição (tratamento de erro)
		If oJsonDesc[aNames[nIndNames]] == NIL
			oJsonDesc[aNames[nIndNames]] := aNames[nIndNames]
		EndIf

				//Se for uma lista, cria os nós de agrupamento e chama a função MontaTree (recursiva)
		If ValType(oJson[aNames[nIndNames]]) == "A"
			oMsgEnv:AddItem(PadR(oJsonDesc[aNames[nIndNames]],TAMANHO_ITEM_TREE), , , , , , nNivel)
			cNode := LastNode()
			oMsgEnv:PTGotoToNode(cNode)

			//Percorre o array com a lista
			nLenArray := Len(oJson[aNames[nIndNames]])
			For nIndArray := 1 To nLenArray
				//Adiciona um agrupador para os campos das listas
				oMsgEnv:AddItem("[" + cValToChar(nIndArray) + "]", , , , , , 2)
				cNodeAgr := LastNode()
				oMsgEnv:PTGotoToNode(cNodeAgr)

				//Chama recursivamente, pois é um novo Json
				MontaTree(oJson[aNames[nIndNames]][nIndArray], 2)

				//Posiciona no pai e Recolhe a tree
				oMsgEnv:PTGotoToNode(cNodeAgr)
				oMsgEnv:PTCollapse()
				oMsgEnv:PTGotoToNode(cNode)
			Next nIndArray
			oMsgEnv:PTCollapse()

			//O registro passa a ficar posicionado na lista, logo, deve-se inserir no mesmo nível os próximos atributos
			nNivel := 1
		Elseif ValType(oJson[aNames[nIndNames]]) == "J"

				oMsgEnv:AddItem(PadR(oJsonDesc[aNames[nIndNames]],TAMANHO_ITEM_TREE), , , , , , nNivel)
				cNode := LastNode()
				oMsgEnv:PTGotoToNode(cNode)

				//Adiciona um agrupador para os campos das listas
				cNodeAgr := LastNode()
				oMsgEnv:PTGotoToNode(cNodeAgr)

				//Chama recursivamente, pois é um novo Json
				MontaTree(oJson[aNames[nIndNames]], 2)

				//Posiciona no pai e Recolhe a tree
				oMsgEnv:PTGotoToNode(cNodeAgr)
				oMsgEnv:PTCollapse()
				oMsgEnv:PTGotoToNode(cNode)

				oMsgEnv:PTCollapse()

				//O registro passa a ficar posicionado na lista, logo, deve-se inserir no mesmo nível os próximos atributos
				nNivel := 1
		Else

			If ValType(oJson[aNames[nIndNames]]) == "N"
				oJson[aNames[nIndNames]] := cValToChar(oJson[aNames[nIndNames]])
			ElseIf ValType(oJson[aNames[nIndNames]]) == "L"
				oJson[aNames[nIndNames]] := IIf(oJson[aNames[nIndNames]], STR0064, STR0065) //"Verdadeiro" + "Falso"
			ElseIf ValType(oJson[aNames[nIndNames]]) == "U"
				oJson[aNames[nIndNames]] := ""
			EndIf

			oMsgEnv:AddItem(PadR(oJsonDesc[aNames[nIndNames]] + ";" + oJson[aNames[nIndNames]],TAMANHO_ITEM_TREE), , , , , , nNivel)
		Endif		

		//Armazena o primeiro item inserido
		If nIndNames == 1 .And. nNivel == 1
			cNodePri := LastNode()
			oMsgEnv:PTGotoToNode(cNodePri)
		EndIf
	Next nIndNames

	//Pocisiona no primeiro item incluído
	oMsgEnv:PTGotoToNode(cNodePri)

Return

/*/{Protheus.doc} LastNode
Retorna o ID do último nó da Tree

@author brunno.costa / renan.roeder
@since  09/09/2021

@return Character, Quantidade de nós da tree formatado com "0" à esquerda
/*/
Static Function LastNode()
Return PadL(oMsgEnv:PTGetNodeCount(), Len(oMsgEnv:CurrentNodeId), "0")


/*/{Protheus.doc} GIQ0002C
Classe construtura de checkbox dinamico

@author brunno.costa / renan.roeder
@since  09/09/2021

@return Character, Quantidade de nós da tree formatado com "0" à esquerda
/*/
Class GIQ0002C
	//Método construtor da classe
	Method New(oDlg, cId, cDesc, nPosAlt, nPosLar, bChange) Constructor
	
	//Propriedades
	Data lValue
	Data oCheckBox
	Data cId
EndClass

Method New(oDlg, cId, cDesc, nPosAlt, nPosLar, bChange) Class GIQ0002C
	Default bChange := {|| }
	Self:cId := cId
	Self:lValue := lChange
	@ nPosAlt, nPosLar CHECKBOX Self:oCheckBox VAR Self:lValue PROMPT cDesc WHEN PIXEL OF oDlg SIZE 100,015 MESSAGE ""
	Self:oCheckBox:bChange := bChange
Return Self
