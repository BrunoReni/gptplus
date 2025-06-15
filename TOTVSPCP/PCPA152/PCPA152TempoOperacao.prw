#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA152.CH"

#DEFINE CHAR_ETAPAS_CALC_TEMP "calculo_tempo_operacao"
#DEFINE CHAR_ETAPAS_DIST_ORD  "distribui_ordem"
#DEFINE CHAR_ETAPAS_GRAVACAO  "gravacao_resultado"

#DEFINE ARRAY_MF_FILIAL  1
#DEFINE ARRAY_MF_PROG    2
#DEFINE ARRAY_MF_ID      3
#DEFINE ARRAY_MF_PRIOR   4
#DEFINE ARRAY_MF_OP      5
#DEFINE ARRAY_MF_SALDO   6
#DEFINE ARRAY_MF_ROTEIRO 7
#DEFINE ARRAY_MF_OPER    8
#DEFINE ARRAY_MF_RECURSO 9
#DEFINE ARRAY_MF_TEMPO   10
#DEFINE ARRAY_MF_DTINI   11
#DEFINE ARRAY_MF_DTENT   12
#DEFINE TAMANHO_ARRAY_MF 12

#DEFINE ARRAY_VM_FILIAL   1
#DEFINE ARRAY_VM_PROG     2
#DEFINE ARRAY_VM_ID       3
#DEFINE ARRAY_VM_SEQ      4
#DEFINE ARRAY_VM_DATA     5
#DEFINE ARRAY_VM_INICIO   6
#DEFINE ARRAY_VM_FIM      7
#DEFINE ARRAY_VM_TEMPO    8
#DEFINE TAMANHO_ARRAY_VM  8

#DEFINE ARRAY_DISP_RECURSO_DATA        1
#DEFINE ARRAY_DISP_RECURSO_HORA_INICIO 2
#DEFINE ARRAY_DISP_RECURSO_HORA_FIM    3
#DEFINE ARRAY_DISP_RECURSO_TEMPO       4

#DEFINE ARRAY_PERIODO_OPER_DATA        1
#DEFINE ARRAY_PERIODO_OPER_HORA_INICIO 2
#DEFINE ARRAY_PERIODO_OPER_HORA_FIM    3
#DEFINE ARRAY_PERIODO_OPER_TEMPO       4
#DEFINE ARRAY_PERIODO_OPER_TAMANHO     4

#DEFINE LISTA_DADOS_SMF "DADOS_SMF"
#DEFINE LISTA_DADOS_SVM "DADOS_SVM"

#DEFINE FACTORY_OPC_BASE     1
#DEFINE FACTORY_OPC_DISP     2
#DEFINE FACTORY_OPC_TEMPOPER 3

/*/{Protheus.doc} PCPA152TempoOperacao
Classe responsável por calcular os tempos das operações.
@author Lucas Fagundes
@since 17/03/2023
@version P12
/*/
Class PCPA152TempoOperacao From LongClassName
	Private Data cFilialSMF as Caracter
	Private Data cFilialSVM as Caracter
	Private Data cProg      as Caracter
	Private Data oInfoOper  as Object
	Private Data oParametro as Object
	Private Data oProcesso  as Object
	Private Data oQryBlock  as Object
	Private Data oDispRecur as Object

	// Construtor e destrutor
	Public Method new(oProcesso) Constructor
	Public Method destroy()

	// Métodos para a etapa de calculo do tempo das operações
	Private Method calculaSaldo()
	Private Method calculaTempoOperacao()
	Private Method carregaApontamentos()
	Private Method retornaQuery()
	Public Method processaOperacao(cJson)
	Public Method processaTempoOperacao()

	// Métodos para a etapa de distribuição das ordens
	Private Method criaPeriodoOperacao(dData, nHoraIni, nHoraFim, nTempo)
	Private Method getPeriodosOperacao(aOperacao, aProcs, cOrdem)
	Private Method removePerAnteriores(cRecurso, dData, cHora)
	Private Method removePeriodosInvalidos(cRecurso, aOperacao, aProcs)
	Private Method removePerPosteriores(cRecurso, dData, cHora)
	Public Method distribuiOperacoes(aOrdem)
	Public Method processaDistribuicao()

	// Métodos para a etapa de gravação
	Public Method gravaDados()
	Public Method gravaTabela(cTabela, aDados)

	// Métodos auxiliares
	Private Method aguardaFimProcessamento(cEtapa)
	Private Method atualizaPercentual(cEtapa)
	Private Method getQuantidades(cEtapa, nProcs, nTotal)

	// Métodos estaticos
	Static Method horasCentesimaisParaNormais(nHora)
	Static Method horasNormaisParaCentesimais(nHora)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe PCPA152TempoOperacao.
@author Lucas Fagundes
@since 17/03/2023
@version P12
@param oProcesso, Object, Instancia da classe de controle do processamento.
@return Self
/*/
Method new(oProcesso) Class PCPA152TempoOperacao

	Self:oProcesso  := oProcesso
	Self:cProg      := Self:oProcesso:retornaProgramacao()
	Self:cFilialSMF := xFilial("SMF")
	Self:cFilialSVM := xFilial("SVM")
	Self:oInfoOper  := Nil
	Self:oQryBlock  := Nil

	/*
	* Parametros:
	* tipoOP: 1 - Firmes; 2 - Previstas; 3 - Ambas
	* tipoProgramacao: 1 - Data de inicio; 2 - Data de entrega
	*/
	Self:oParametro := JsonObject():New()
	Self:oParametro["tipoOP"         ] := Self:oProcesso:retornaParametro("tipoOP"         )
	Self:oParametro["tipoProgramacao"] := Self:oProcesso:retornaParametro("tipoProgramacao")
	Self:oParametro["centroTrabalho" ] := Self:oProcesso:retornaParametro("centroTrabalho" )
	Self:oParametro["recursos"       ] := Self:oProcesso:retornaParametro("recursos"       )
	Self:oParametro["ordemProducao"  ] := Self:oProcesso:retornaParametro("ordemProducao"  )
	Self:oParametro["produto"        ] := Self:oProcesso:retornaParametro("produto"        )
	Self:oParametro["grupoProduto"   ] := Self:oProcesso:retornaParametro("grupoProduto"   )
	Self:oParametro["tipoProduto"    ] := Self:oProcesso:retornaParametro("tipoProduto"    )
	Self:oParametro["MV_PERDINF"     ] := Self:oProcesso:retornaParametro("MV_PERDINF"     )
	Self:oParametro["MV_TPHR"        ] := Self:oProcesso:retornaParametro("MV_TPHR"        )
	Self:oParametro["dataInicial"    ] := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataInicial")),3))
	Self:oParametro["dataFinal"      ] := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataFinal")),3))

Return Self

/*/{Protheus.doc} destroy
Metodo destrutor da classe PCPA152TempoOperacao.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return Nil
/*/
Method destroy() Class PCPA152TempoOperacao

	Self:oProcesso  := Nil
	Self:cProg      := Nil
	Self:cFilialSMF := Nil

	FreeObj(Self:oParametro )
	FwFreeObj(Self:oInfoOper)
	FwFreeObj(Self:oQryBlock)

Return Nil

/*/{Protheus.doc} processaTempoOperacao
Executa o processamento da classe.
@author Lucas Fagundes
@since 17/03/2023
@version P12
@return lSucesso, Logico, Indica se concluiu o processamento com sucesso.
/*/
Method processaTempoOperacao() Class PCPA152TempoOperacao
	Local aQuery     := Self:retornaQuery()
	Local cAlias     := GetNextAlias()
	Local cId        := '0000000000'
	Local lSucesso   := .T.
	Local nDelegados := 0
	Local nLotePad   := 0
	Local nTotal     := 0
	Local oInfo      := JsonObject():New()

	BeginSql Alias cAlias
		SELECT COUNT(1) TOTAL
		  FROM %Exp:aQuery[2]%
		 WHERE %Exp:aQuery[3]%
	EndSql

	If (cAlias)->(!EoF())
		nTotal := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

	If nTotal > 0
		Self:oProcesso:gravaValorGlobal("TOTAL_OPERACOES", nTotal)
		Self:oProcesso:gravaValorGlobal("OPERACOES_FINALIZADAS", 0)

		BeginSql Alias cAlias
			SELECT %Exp:aQuery[1]%
			  FROM %Exp:aQuery[2]%
			 WHERE %Exp:aQuery[3]%
			 ORDER BY %Exp:aQuery[4]%
		EndSql

		While (cAlias)->(!EoF()) .And. lSucesso
			cId := Soma1(cId)

			nLotePad := (cAlias)->G2_LOTEPAD

			// Considera lote padrão igual a um se estiver zerado.
			If nLotePad == 0
				nLotePad := 1
			EndIf

			oInfo["ordemProducao"] := (cAlias)->C2_NUM + (cAlias)->C2_ITEM + (cAlias)->C2_SEQUEN + (cAlias)->C2_ITEMGRD
			oInfo["quantidade"   ] := (cAlias)->C2_QUANT
			oInfo["qtdProduzida" ] := (cAlias)->C2_QUJE
			oInfo["perda"        ] := (cAlias)->C2_PERDA
			oInfo["dataInicio"   ] := (cAlias)->C2_DATPRI
			oInfo["dataEntrega"  ] := (cAlias)->C2_DATPRF
			oInfo["idOperacao"   ] := cId
			oInfo["prioridade"   ] := cId
			oInfo["roteiro"      ] := (cAlias)->G2_CODIGO
			oInfo["operacao"     ] := (cAlias)->G2_OPERAC
			oInfo["recurso"      ] := (cAlias)->G2_RECURSO
			oInfo["tempoPadrao"  ] := (cAlias)->G2_TEMPAD
			oInfo["lotePadrao"   ] := nLotePad

			Self:oProcesso:delegar("P152CalTem", oInfo:toJson(), Self:cProg)
			nDelegados++

			If nDelegados == 50
				Self:atualizaPercentual(CHAR_ETAPAS_CALC_TEMP)
				nDelegados := 0
			EndIf

			(cAlias)->(dbSkip())
			lSucesso := Self:oProcesso:permiteProsseguir()
		End
		(cAlias)->(dbCloseArea())

		Self:aguardaFimProcessamento(CHAR_ETAPAS_CALC_TEMP)
	EndIf

	FwFreeObj(oInfo)
	aSize(aQuery, 0)
Return lSucesso

/*/{Protheus.doc} atualizaPercentual
Atualiza a porcentagem atual da etapa de cálculo das operações.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param cEtapa, Caracter, Etapa que irá atualizar o percentual.
@return Nil
/*/
Method atualizaPercentual(cEtapa) Class PCPA152TempoOperacao
	Local nAtuPerct := 0
	Local nQtdProc  := 0
	Local nTotal    := 0

	Self:getQuantidades(cEtapa, @nQtdProc, @nTotal)

	nAtuPerct := (nQtdProc * 100) / nTotal
	Self:oProcesso:gravaPercentual(cEtapa, nAtuPerct)

Return Nil

/*/{Protheus.doc} getQuantidades
Retorna a quantidade total de registros e a quantidade processada de uma etapa.
@author Lucas Fagundes
@since 05/04/2023
@version P21
@param 01 cEtapa, Caracter, Etapa que irá buscar as quantidades.
@param 02 nProcs, Numerico, Retorna por referencia a quantidade de registros processados.
@param 03 nTotal, Numerico, Retorna por referencia a quantidade total de registros.
@return Nil
/*/
Method getQuantidades(cEtapa, nProcs, nTotal) Class PCPA152TempoOperacao

	If cEtapa == CHAR_ETAPAS_CALC_TEMP
		nProcs := Self:oProcesso:retornaValorGlobal("OPERACOES_FINALIZADAS")
		nTotal := Self:oProcesso:retornaValorGlobal("TOTAL_OPERACOES")

	ElseIf cEtapa == CHAR_ETAPAS_DIST_ORD
		nProcs := Self:oProcesso:retornaValorGlobal("OPERS_DISTRIBUIDAS")
		nTotal := Self:oProcesso:retornaValorGlobal("TOTAL_DISTRIBUICAO")

	ElseIf cEtapa == CHAR_ETAPAS_GRAVACAO
		nProcs := Self:oProcesso:retornaValorGlobal("REGISTROS_GRAVADOS")
		nTotal := Self:oProcesso:retornaValorGlobal("TOTAL_GRAVACAO")

	EndIf

Return Nil

/*/{Protheus.doc} aguardaFimProcessamento
Aguarda o fim do processamento das operações delegadas.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param cEtapa, Caracter, Etapa que irá aguardar o processamento.
@return Nil
/*/
Method aguardaFimProcessamento(cEtapa) Class PCPA152TempoOperacao
	Local nIndex   := 0
	Local nQtdProc := 0
	Local nTotal   := 0

	// Se estiver aguardando a gravação, espera as threads delegadas iniciarem.
	If cEtapa == CHAR_ETAPAS_GRAVACAO
		While (Self:oProcesso:retornaValorGlobal("GRAVACAO_SMF") == "INI" .Or.   ;
		       Self:oProcesso:retornaValorGlobal("GRAVACAO_SVM") == "INI") .And. ;
		       Self:oProcesso:permiteProsseguir()
			Sleep(50)
		End
	EndIf

	Self:getQuantidades(cEtapa, @nQtdProc, @nTotal)

	While nQtdProc != nTotal .And. Self:oProcesso:permiteProsseguir()
		Sleep(500)

		nIndex++
		If nIndex == 5
			Self:atualizaPercentual(cEtapa)
			nIndex := 0
		EndIf

		Self:getQuantidades(cEtapa, @nQtdProc)
	End

Return Nil

/*/{Protheus.doc} P152CalTem
Inicia o cálculo de uma operação.
@type  Function
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param 01 cJson, Caracter, Json com as informações da op que vai calcular o tempo das operações.
@param 02 cProg, Caracter, Código da programação que está sendo executada.
@return Nil
/*/
Function P152CalTem(cJson, cProg)
	Local oTempoOper := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		oTempoOper:processaOperacao(cJson)
	EndIf

Return Nil

/*/{Protheus.doc} processaOperacao
Realiza o cálculo da operação.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param cJson, Caracter, Json com as informações da operação.
@return Nil
/*/
Method processaOperacao(cJson) Class PCPA152TempoOperacao
	Local aDadosSMF := Array(TAMANHO_ARRAY_MF)
	Local cChave    := ""

	Self:oInfoOper := JsonObject():New()
	Self:oInfoOper:fromJson(cJson)

	aDadosSMF[ARRAY_MF_FILIAL ] := Self:cFilialSMF
	aDadosSMF[ARRAY_MF_PROG   ] := Self:cProg
	aDadosSMF[ARRAY_MF_ID     ] := Self:oInfoOper["idOperacao"   ]
	aDadosSMF[ARRAY_MF_PRIOR  ] := Self:oInfoOper["prioridade"   ]
	aDadosSMF[ARRAY_MF_OP     ] := Self:oInfoOper["ordemProducao"]
	aDadosSMF[ARRAY_MF_ROTEIRO] := Self:oInfoOper["roteiro"      ]
	aDadosSMF[ARRAY_MF_OPER   ] := Self:oInfoOper["operacao"     ]
	aDadosSMF[ARRAY_MF_RECURSO] := Self:oInfoOper["recurso"      ]
	aDadosSMF[ARRAY_MF_DTINI  ] := StoD(Self:oInfoOper["dataInicio" ])
	aDadosSMF[ARRAY_MF_DTENT  ] := StoD(Self:oInfoOper["dataEntrega"])

	Self:calculaSaldo()
	aDadosSMF[ARRAY_MF_SALDO] := Self:oInfoOper["saldo"]

	Self:calculaTempoOperacao()
	aDadosSMF[ARRAY_MF_TEMPO] := __Hrs2Min(Self:oInfoOper["tempoOperacao"])

	cChave := Self:oInfoOper["ordemProducao"]
	Self:oProcesso:adicionaListaGlobal(LISTA_DADOS_SMF, cChave, aDadosSMF, .T.)

	Self:oProcesso:gravaValorGlobal("OPERACOES_FINALIZADAS", 1, .T., .T.)

	aSize(aDadosSMF, 0)
	FwFreeObj(Self:oInfoOper)
Return Nil

/*/{Protheus.doc} calculaSaldo
Calcula o saldo de uma operação.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return Nil
/*/
Method calculaSaldo() Class PCPA152TempoOperacao
	Local aApont := Self:carregaApontamentos()
	Local nPerda := 0
	Local nProd  := 0
	Local nQtdOP := 0
	Local nSaldo := 0

	If Empty(aApont)
		nQtdOP := Self:oInfoOper["quantidade"  ]
		nProd  := Self:oInfoOper["qtdProduzida"]
		nPerda := Self:oInfoOper["perda"       ]
	ElseIf !aApont[3]
		nQtdOP := Self:oInfoOper["quantidade"]
		nProd  := aApont[1]
		nPerda := aApont[2]
	EndIf

	If !Self:oParametro["MV_PERDINF"]
		nProd += nPerda
	EndIf

	nSaldo := nQtdOP - nProd
	Self:oInfoOper["saldo"] := nSaldo

	aSize(aApont, 0)
Return Nil

/*/{Protheus.doc} carregaApontamentos
Carrega os apontamentos da operação que está em Self:oInfoOper
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return aAponts, Array, Array com os apontamentos no seguinte formato: aAponts[1] - Quantidade produziada.
                                                                       aAponts[2] - Quantidade perdida.
                                                                       aAponts[3] - .T. se houve apontamento total.
/*/
Method carregaApontamentos() Class PCPA152TempoOperacao
	Local aAponts := {}
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local lTotal  := .F.

	If Self:oQryBlock == Nil
		cQuery := " SELECT SUM(SH6.H6_QTDPROD) qtdProduzida, "
		cQuery +=        " SUM(SH6.H6_QTDPERD) qtdPerda,     "
		cQuery +=        " SH6.H6_PT "
		cQuery +=   " FROM " + RetSqlName("SH6") + " SH6 "
		cQuery +=  " WHERE SH6.H6_FILIAL  = ? "
		cQuery +=    " AND SH6.D_E_L_E_T_ = ? "
		cQuery +=    " AND SH6.H6_OP      = ? "
		cQuery +=    " AND SH6.H6_OPERAC  = ? "
		cQuery +=  " GROUP BY SH6.H6_PT,      "
		cQuery +=           " SH6.H6_QTDPROD, "
		cQuery +=           " SH6.H6_QTDPERD  "

		Self:oQryBlock := FwExecStatement():New(cQuery)

		Self:oQryBlock:setString(1, xFilial("SH6")) // H6_FILIAL
		Self:oQryBlock:setString(2, ' '           ) // D_E_L_E_T_
	EndIf

	Self:oQryBlock:setString(3, Self:oInfoOper["ordemProducao"]) // H6_OP
	Self:oQryBlock:setString(4, Self:oInfoOper["operacao"     ]) // H6_OPERAC

	cAlias := Self:oQryBlock:OpenAlias()

	If (cAlias)->(!EoF())
		aAponts := {0, 0, .F.}

		While (cAlias)->(!EoF())
			lTotal := AllTrim((cAlias)->H6_PT) == "T"

			aAponts[1] += (cAlias)->qtdProduzida
			aAponts[2] += (cAlias)->qtdPerda

			If !aAponts[3] .And. lTotal
				aAponts[1] := 0
				aAponts[2] := 0
				aAponts[3] := .T.
				Exit
			EndIf

			(cAlias)->(dbSkip())
		End
	EndIf
	(cAlias)->(dbCloseArea())

Return aAponts

/*/{Protheus.doc} calculaTempoOperacao
Calcula o tempo de uma operação.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return Nil
/*/
Method calculaTempoOperacao() Class PCPA152TempoOperacao
	Local nLotePad  := Self:oInfoOper["lotePadrao" ]
	Local nSaldo    := Self:oInfoOper["saldo"      ]
	Local nTempoPad := Self:oInfoOper["tempoPadrao"]

	If Self:oParametro["MV_TPHR"] == "N"
		nTempoPad := Self:horasNormaisParaCentesimais(nTempoPad)
	EndIf

	nTempo := nSaldo * (nTempoPad / nLotePad)

	Self:oInfoOper["tempoOperacao"] := Self:horasCentesimaisParaNormais(nTempo, .T.)

Return Nil

/*/{Protheus.doc} gravaDados
Delega a gravação das tabelas para as threads.
@author Lucas Fagundes
@since 11/04/2023
@version P12
@return lSucesso, Logico, Indica se teve sucesso na gravação dos dados.
/*/
Method gravaDados() Class PCPA152TempoOperacao
	Local lSucesso := .T.

	Self:oProcesso:gravaValorGlobal("REGISTROS_GRAVADOS", 0)
	Self:oProcesso:gravaValorGlobal("TOTAL_GRAVACAO"    , 0)

	Self:oProcesso:gravaValorGlobal("GRAVACAO_SMF", "INI")
	Self:oProcesso:delegar("P152CalGrv", Self:cProg, "SMF")

	Self:oProcesso:gravaValorGlobal("GRAVACAO_SVM", "INI")
	Self:oProcesso:delegar("P152CalGrv", Self:cProg, "SVM")


	Self:aguardaFimProcessamento(CHAR_ETAPAS_GRAVACAO)

	lSucesso := Self:oProcesso:retornaValorGlobal("GRAVACAO_SMF") != "ERRO" .And. Self:oProcesso:retornaValorGlobal("GRAVACAO_SVM") != "ERRO"

Return lSucesso

/*/{Protheus.doc} P152CalGrv
Realiza a gravação de uma tabela em outra thread.
@type  Function
@author Lucas Fagundes
@since 11/04/2023
@version P12
@param 01 cProg  , Caracter, Código da programação que está em execução.
@param 02 cTabela, Caracter, Alias da tabela que irá gravar.
@param 03 aDados , Arrray  , Array com os dados para gravar na tabela.
@return Nil
/*/
Function P152CalGrv(cProg, cTabela)
	Local aDados := {}
	Local cLista := ""
	Local oTempoOper := Nil
	Local oProcesso  := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper) .And. PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)
		If cTabela == "SMF"
			cLista := LISTA_DADOS_SMF
		ElseIf cTabela == "SVM"
			cLista := LISTA_DADOS_SVM
		EndIf

		aDados := oProcesso:retornaListaGlobal(cLista)
		nTotal := Len(aDados)

		oProcesso:gravaValorGlobal("TOTAL_GRAVACAO", @nTotal, .T., .T., nTotal)
		oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "PROC")

		oTempoOper:gravaTabela(cTabela, aDados)
	EndIf

Return Nil

/*/{Protheus.doc} gravaTabela
Realiza a gravação dos dados em uma tabela.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param 01 cTabela, Caracter, Alias da tabela que irá gravar os dados.
@param 02 aDados , Array   , Dados que irá gravar na tabela.
@return Nil
/*/
Method gravaTabela(cTabela, aDados) Class PCPA152TempoOperacao
	Local aAux      := {}
	Local lSucesso  := .T.
	Local nIndChave := 1
	Local nIndDados := 1
	Local nTotChave := Len(aDados)
	Local nTotDados := 0
	Local oBulk     := FwBulk():New()

	oBulk:setTable(RetSqlName(cTabela))
	oBulk:setFields(estrutTab(cTabela))

	While nIndChave <= nTotChave .And. lSucesso
		aAux      := aDados[nIndChave][2]
		nTotDados := Len(aAux)
		nIndDados := 1

		While nIndDados <= nTotDados .And. lSucesso
			lSucesso := oBulk:addData(aAux[nIndDados])
			aSize(aAux[nIndDados], 0)

			If lSucesso
				nIndDados++
				lSucesso := Self:oProcesso:permiteProsseguir()
			EndIf
		End

		aSize(aAux, 0)
		aSize(aDados[nIndChave], 0)

		Self:oProcesso:gravaValorGlobal("REGISTROS_GRAVADOS", 1, .T., .T.)

		If lSucesso
			nIndChave++
			lSucesso := Self:oProcesso:permiteProsseguir()
		EndIf
	End

	If lSucesso
		lSucesso := oBulk:close()
	EndIf

	If !lSucesso
		Self:oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "ERRO")
		Self:oProcesso:gravaErro(CHAR_ETAPAS_GRAVACAO, i18n(STR0182, {cTabela}), oBulk:getError()) // "Erro na gravação da tabela #1[tabela]#."
	EndIf

	oBulk:destroy()
	aSize(aDados, 0)
Return Nil

/*/{Protheus.doc} estrutTab
Carrega o array com a estrutura da tabela SMF para a gravação dos dados.
@type  Static Function
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return aEstrut, Array, Array com a estrutura da tabela SMF.
/*/
Static Function estrutTab(cTabela)
	Local aEstrut := {}

	Do Case
		Case cTabela == "SMF"
			aAdd(aEstrut, {"MF_FILIAL" })
			aAdd(aEstrut, {"MF_PROG"   })
			aAdd(aEstrut, {"MF_ID"     })
			aAdd(aEstrut, {"MF_PRIOR"  })
			aAdd(aEstrut, {"MF_OP"     })
			aAdd(aEstrut, {"MF_SALDO"  })
			aAdd(aEstrut, {"MF_ROTEIRO"})
			aAdd(aEstrut, {"MF_OPER"   })
			aAdd(aEstrut, {"MF_RECURSO"})
			aAdd(aEstrut, {"MF_TEMPO"  })
			aAdd(aEstrut, {"MF_DTINI"  })
			aAdd(aEstrut, {"MF_DTENT"  })

		Case cTabela == "SVM"
			aAdd(aEstrut, {"VM_FILIAL"})
			aAdd(aEstrut, {"VM_PROG"  })
			aAdd(aEstrut, {"VM_ID"    })
			aAdd(aEstrut, {"VM_SEQ"   })
			aAdd(aEstrut, {"VM_DATA"  })
			aAdd(aEstrut, {"VM_INICIO"})
			aAdd(aEstrut, {"VM_FIM"   })
			aAdd(aEstrut, {"VM_TEMPO" })

	EndCase

Return aEstrut

/*/{Protheus.doc} retornaQuery
Retorna a query para busca das operações.
@author Lucas Fagundes
@since 20/03/2023
@version P12
@return aQuery, Array, Array com os dados para a query, no seguinte formato: aQuery[1] = Campos da consulta
                                                                             aQuery[2] = From da consulta
                                                                             aQuery[3] = Where da consulta
                                                                             aQuery[4] = Order by da consulta
/*/
Method retornaQuery() Class PCPA152TempoOperacao
	Local aQuery  := {}
	Local cBanco  := TcGetDb()
	Local cCampos := ""
	Local cFrom   := ""
	Local cOrder  := ""
	Local cWhere  := ""

	cCampos += /*SELECT*/" SC2.C2_NUM,     "
	cCampos +=           " SC2.C2_ITEM,    "
	cCampos +=           " SC2.C2_SEQUEN,  "
	cCampos +=           " SC2.C2_ITEMGRD, "
	cCampos +=           " SC2.C2_QUANT,   "
	cCampos +=           " SC2.C2_QUJE,    "
	cCampos +=           " SC2.C2_PERDA,   "
	cCampos +=           " SC2.C2_DATPRI,  "
	cCampos +=           " SC2.C2_DATPRF,  "
	cCampos +=           " SG2.G2_CODIGO,  "
	cCampos +=           " SG2.G2_OPERAC,  "
	cCampos +=           " SG2.G2_RECURSO, "
	cCampos +=           " SG2.G2_TEMPAD,  "
	cCampos +=           " SG2.G2_LOTEPAD  "

	cFrom +=   /*FROM*/" " + RetSqlName("SC2") + " SC2 "

	cFrom +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cFrom +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cFrom +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cFrom +=    " AND SB1.D_E_L_E_T_ = ' ' "

	If !Empty(Self:oParametro["produto"])
		cFrom += " AND SB1.B1_COD IN " + inFilt(Self:oParametro["produto"])
	EndIf

	If !Empty(Self:oParametro["grupoProduto"])
		cFrom += " AND SB1.B1_GRUPO IN " + inFilt(Self:oParametro["grupoProduto"])
	EndIf

	If !Empty(Self:oParametro["tipoProduto"])
		cFrom += " AND SB1.B1_TIPO IN " + inFilt(Self:oParametro["tipoProduto"])
	EndIf

	cFrom +=  " INNER JOIN " + RetSqlName("SG2") + " SG2 "
	cFrom +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
	cFrom +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cFrom +=    " AND SG2.G2_CODIGO  = "
	cFrom +=        " CASE "
	cFrom +=            " WHEN SC2.C2_ROTEIRO != ' ' THEN SC2.C2_ROTEIRO "
	cFrom +=            " WHEN SB1.B1_OPERPAD != ' ' THEN SB1.B1_OPERPAD "
	cFrom +=            " ELSE '01' "
	cFrom +=        " END "
	cFrom +=    " AND SG2.D_E_L_E_T_ = ' ' "
	cFrom +=    " AND ( "
	cFrom +=         " (SG2.G2_DTINI  <= '" + DtoS(Self:oParametro["dataInicial"]) + "') OR "
	cFrom +=         " (SG2.G2_DTINI = ' ') "
	cFrom +=    " ) "
	cFrom +=    " AND ( "
	cFrom +=         " (SG2.G2_DTFIM  >= '" + DtoS(Self:oParametro["dataFinal"  ]) + "') OR "
	cFrom +=         " (SG2.G2_DTFIM  = ' ') "
	cFrom +=    " ) "

	If !Empty(Self:oParametro["recursos"])
		cFrom += " AND SG2.G2_RECURSO IN " + inFilt(Self:oParametro["recursos"])
	EndIf

	cFrom +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cFrom +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cFrom +=    " AND SG2.G2_RECURSO = SH1.H1_CODIGO "
	cFrom +=    " AND SH1.D_E_L_E_T_ = ' ' "

	cWhere += /*WHERE*/" SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cWhere +=      " AND SC2.D_E_L_E_T_ =  ' ' "
	cWhere +=      " AND SC2.C2_DATRF   =  ' ' "
	cWhere +=      " AND SC2.C2_DATPRF  >= '" + DtoS(Self:oParametro["dataInicial"]) + "' "
	cWhere +=      " AND SC2.C2_DATPRF  <= '" + DtoS(Self:oParametro["dataFinal"  ]) + "' "

	If Self:oParametro["tipoOP"] == 1
		cWhere += " AND SC2.C2_TPOP = 'F' "
	ElseIf Self:oParametro["tipoOP"] == 2
		cWhere += " AND SC2.C2_TPOP = 'P' "
	EndIf

	If !Empty(Self:oParametro["centroTrabalho"])
		cWhere += " AND ( "
		cWhere +=     " (SG2.G2_CTRAB IN " + inFilt(Self:oParametro["centroTrabalho"]) + " ) OR "
		cWhere +=     " (SG2.G2_CTRAB = ' ' AND SH1.H1_CTRAB IN " + inFilt(Self:oParametro["centroTrabalho"]) + " ) "
		cWhere += " ) "
	EndIf

	If !Empty(Self:oParametro["ordemProducao"])
		cWhere += " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD IN " + inFilt(Self:oParametro["ordemProducao"])

		If "MSSQL" $ cBanco
			cWhere := StrTran(cWhere, "||", "+")
		EndIf
	EndIf

	If Self:oParametro["tipoProgramacao"] == 1
		cOrder += /*ORDER BY*/" SC2.C2_DATPRI, SC2.C2_SEQPAI DESC, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SG2.G2_OPERAC "
	Else
		cOrder += /*ORDER BY*/" SC2.C2_DATPRF DESC, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SG2.G2_OPERAC DESC "
	EndIf

	cCampos := "%" + cCampos + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	cOrder  := "%" + cOrder  + "%"

	aQuery := {cCampos, cFrom, cWhere, cOrder}

Return aQuery

/*/{Protheus.doc} inFilt
Monta a condição IN da query para os centros de trabalho e recursos.
@type  Static Function
@author Lucas Fagundes
@since 20/03/2023
@version P12
@param aFiltro, Array, Array com os dados para o filtro.
@return cInQuery, Caracter, Condição IN para filtrar a query.
/*/
Static Function inFilt(aFiltro)
	Local cInQuery := ""
	Local nIndex   := 0
	Local nTotal   := Len(aFiltro)

	cInQuery += "("
	For nIndex := 1 To nTotal
		cInQuery += "'" + aFiltro[nIndex] + "'"

		If nIndex != nTotal
			cInQuery += ", "
		EndIf
	Next
	cInQuery += ")"

Return cInQuery

/*/{Protheus.doc} horasNormaisParaCentesimais
Converte horas normais para horas centesimais.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param nHora, Numerico, Hora normal que será convertida.
@return nHoraConv, Numerico, Hora normal convertida para hora centesimal.
/*/
Method horasNormaisParaCentesimais(nHora) Class PCPA152TempoOperacao
	Local nHoraConv := 0

	nHoraConv := Int(nHora) + (((nHora - Int(nHora)) / 60) * 100)

Return nHoraConv

/*/{Protheus.doc} horasCentesimaisParaNormais
Converte horas centesimais para horas normais.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param nHora, Numerico, Hora centesimal que será convertida.
@return nHoraConv, Numerico, Hora centesimal convertida para hora normal.
/*/
Method horasCentesimaisParaNormais(nHora) Class PCPA152TempoOperacao
	Local nHoraAux  := 0
	Local nMinutos  := 0
	Local nHoraConv := 0

	nHoraAux := Int(nHora)
	nMinutos := (nHora - nHoraAux) * 0.6

	nHoraConv := nHoraAux + nMinutos

Return nHoraConv

/*/{Protheus.doc} processaDistribuicao()
Processa a distribuição das operações.
@author Lucas Fagundes
@since 04/04/2023
@version P12
@return lSucesso, Logico, Indica se teve sucesso na distribuição das operações.
/*/
Method processaDistribuicao() Class PCPA152TempoOperacao
	Local aOrdens    := {}
	Local lSucesso   := .T.
	Local nDelegados := 0
	Local nIndex     := 1
	Local nTotal     := 0

	aOrdens := Self:oProcesso:retornaListaGlobal(LISTA_DADOS_SMF)
	nTotal     := Len(aOrdens)

	Self:oProcesso:gravaValorGlobal("TOTAL_DISTRIBUICAO", nTotal)
	Self:oProcesso:gravaValorGlobal("OPERS_DISTRIBUIDAS", 0     )

	While nIndex <= nTotal .And. lSucesso
		Self:oProcesso:delegar("P152Dist", Self:cProg, aOrdens[nIndex])
		aSize(aOrdens[nIndex], 0)

		nDelegados++
		If nDelegados == 10
			Self:atualizaPercentual(CHAR_ETAPAS_DIST_ORD)
			nDelegados := 0
		EndIf

		nIndex++
		lSucesso := Self:oProcesso:permiteProsseguir()
	End

	Self:aguardaFimProcessamento(CHAR_ETAPAS_DIST_ORD)

	aSize(aOrdens, 0)
Return lSucesso

/*/{Protheus.doc} P152Dist
Realiza a distribuição das operações de uma ordem.
@type  Function
@author Lucas Fagundes
@since 04/04/2023
@version P12
@param 01 cProg , Caracter, Código da operação que está executando.
@param 02 aOrdem, Array   , Array com as informações da ordem que irá distribuir as operações.
@return Nil
/*/
Function P152Dist(cProg, aOrdem)
	Local oTempoOper := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		oTempoOper:distribuiOperacoes(aOrdem)
	EndIf

Return Nil

/*/{Protheus.doc} distribuiOperacoes
Realiza a distribuição do tempo das operações de uma ordem.
@author Lucas Fagundes
@since 04/04/2023
@version P12
@param aOrdem, Array, Array com as informações da ordem de produção que irá distribuir as operações.
@return Nil
/*/
Method distribuiOperacoes(aOrdem) Class PCPA152TempoOperacao
	Local aDados    := aOrdem[2]
	Local aItem     := {}
	Local aOperacao := {}
	Local aPeriodos := {}
	Local aRegs     := {}
	Local cOrdem    := aOrdem[1]
	Local cRecurso  := ""
	Local nIndOper  := 1
	Local nIndPer   := 0
	Local nSeq      := 1
	Local nTotOper  := 0
	Local nTotPer   := 0
	Local oDisp     := Nil

	Self:oDispRecur := JsonObject():New()

	Self:oProcesso:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

	aSort(aDados,,,{|x,y| x[ARRAY_MF_PRIOR] < y[ARRAY_MF_PRIOR]})

	nTotOper := Len(aDados)
	While nIndOper <= nTotOper .And. Self:oProcesso:permiteProsseguir()
		aOperacao := aDados[nIndOper]
		nSeq := 0

		cRecurso  := aOperacao[ARRAY_MF_RECURSO]
		If !Self:oDispRecur:hasProperty(cRecurso)
			Self:oDispRecur[cRecurso] := oDisp:getDisponibilidadeRecurso(cRecurso)
		EndIf

		aPeriodos := Self:getPeriodosOperacao(aOperacao, aRegs, cOrdem)

		nTotPer   := Len(aPeriodos)
		For nIndPer := 1 To nTotPer
			aItem := Array(TAMANHO_ARRAY_VM)
			nSeq++

			aItem[ARRAY_VM_FILIAL] := Self:cFilialSVM
			aItem[ARRAY_VM_PROG  ] := Self:cProg
			aItem[ARRAY_VM_ID    ] := aOperacao[ARRAY_MF_ID]
			aItem[ARRAY_VM_SEQ   ] := nSeq
			aItem[ARRAY_VM_DATA  ] := aPeriodos[nIndPer][ARRAY_PERIODO_OPER_DATA]
			aItem[ARRAY_VM_INICIO] := __Min2Hrs(aPeriodos[nIndPer][ARRAY_PERIODO_OPER_HORA_INICIO], .T.)
			aItem[ARRAY_VM_FIM   ] := __Min2Hrs(aPeriodos[nIndPer][ARRAY_PERIODO_OPER_HORA_FIM   ], .T.)
			aItem[ARRAY_VM_TEMPO ] := aPeriodos[nIndPer][ARRAY_PERIODO_OPER_TEMPO]

			aAdd(aRegs, aItem)
		Next

		aSize(aPeriodos, 0)
		aSize(aOperacao, 0)
		nIndOper++
	End

	Self:oProcesso:adicionaListaGlobal(LISTA_DADOS_SVM, cOrdem, aRegs, .F.)

	Self:oProcesso:gravaValorGlobal("OPERS_DISTRIBUIDAS", 1, .T., .T.)

	aSize(aDados, 0)
	FwFreeArray(aRegs)
	FwFreeObj(Self:oDispRecur)
Return Nil

/*/{Protheus.doc} getPeriodosOperacao
Busca os periodos que uma operação irá utilizar um recurso.
@author Lucas Fagundes
@since 05/04/2023
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 aProcs   , Array   , Array com as operações que já foram distribuidas.
@param 03 cOrdem   , Caracter, Código da ordem de produção que está processando.
@return aPeriodos, Array, Array com o periodo que a operação ficara no recurso.
/*/
Method getPeriodosOperacao(aOperacao, aProcs, cOrdem) Class PCPA152TempoOperacao
	Local aDispRec   := {}
	Local aPeriodos  := {}
	Local nHoraFim   := 0
	Local nHoraIni   := 0
	Local cRecurso   := aOperacao[ARRAY_MF_RECURSO]
	Local dData      := Nil
	Local lContinua  := .T.
	Local lEntrega   := Self:oParametro["tipoProgramacao"] == 2
	Local nIndDisp   := 0
	Local nTempoOper := aOperacao[ARRAY_MF_TEMPO]

	Self:removePeriodosInvalidos(cRecurso, aOperacao, aProcs)

	If lEntrega
		// Se distribui pela data de entrega, verifica sempre o ultimo registro.
		nIndDisp := Len(Self:oDispRecur[cRecurso])
	Else
		// Se distribui pela data de inicio, verifica sempre o primeiro registro.
		nIndDisp := 1
	EndIf

	lContinua := nTempoOper > 0 .And. Len(Self:oDispRecur[cRecurso]) > 0
	While lContinua
		aDispRec := Self:oDispRecur[cRecurso][nIndDisp]
		dData    := aDispRec[ARRAY_DISP_RECURSO_DATA]

		// Tempo da operação for maior que o tempo do recurso, considera todo o tempo do recurso.
		If nTempoOper >= aDispRec[ARRAY_DISP_RECURSO_TEMPO]
			nHoraIni := aDispRec[ARRAY_DISP_RECURSO_HORA_INICIO]
			nHoraFim := aDispRec[ARRAY_DISP_RECURSO_HORA_FIM   ]

			// Remove este tempo do recurso, pois já foi totalmente utilizado.
			aSize(aDispRec, 0)
			aDel(Self:oDispRecur[cRecurso], nIndDisp)
			aSize(Self:oDispRecur[cRecurso], Len(Self:oDispRecur[cRecurso])-1)

			// Se distribui os periodos pela data de entrega, verifica sempre o ultimo registro.
			If lEntrega
				nIndDisp := Len(Self:oDispRecur[cRecurso])
			EndIf

		// Tempo da operação menor que o tempo do recurso, considera tempo parcial.
		Else
			// Se distribui pela data de entrega, considera tempo parcial a partir da entrega.
			If lEntrega
				// Finaliza o perido no horario que acaba o recurso.
				nHoraFim := aDispRec[ARRAY_DISP_RECURSO_HORA_FIM]

				// Calcula a hora de inicio do periodo, a partir da hora de termino e o tempo da operação.
				nHoraIni := nHoraFim - nTempoOper

				// Ajusta a hora de termino do recurso com a hora final do periodo.
				aDispRec[ARRAY_DISP_RECURSO_HORA_FIM] := nHoraIni

			// Se distribui pela data de inicio, considera tempo parcial a partir do inicio.
			Else
				// Inicia o periodo na data de inicio do recurso.
				nHoraIni := aDispRec[ARRAY_DISP_RECURSO_HORA_INICIO]

				// Considera como horario final o horario de inicio mais o tempo que a operação ira levar.
				nHoraFim := nHoraIni + nTempoOper

				// Ajusta a hora de inicio do recurso com a hora final do periodo.
				aDispRec[ARRAY_DISP_RECURSO_HORA_INICIO] := nHoraFim
			EndIf

			// Ajusta o tempo de disponibilidade do recurso.
			aDispRec[ARRAY_DISP_RECURSO_TEMPO] := aDispRec[ARRAY_DISP_RECURSO_HORA_FIM] - aDispRec[ARRAY_DISP_RECURSO_HORA_INICIO]
		EndIf

		// Busca o tempo do periodo.
		nTempo := nHoraFim - nHoraIni

		aAdd(aPeriodos, Self:criaPeriodoOperacao(dData, nHoraIni, nHoraFim, nTempo))

		// Remove o tempo do periodo do tempo da operação.
		nTempoOper := nTempoOper - nTempo

		lContinua := nTempoOper > 0 .And. Len(Self:oDispRecur[cRecurso]) > 0
	End

	If nTempoOper > 0
		Self:oProcesso:log(i18n(STR0183, {aOperacao[ARRAY_MF_OPER], cOrdem, cRecurso})) // "A Operação #1[operacao]# da ordem de produção #2[codigoDaOrdem]# não foi totalmente distribuida, pois faltou disponibilidade no recurso #3[recurso]#."
	EndIf

Return aPeriodos

/*/{Protheus.doc} removePeriodosInvalidos
Remove os periodos invalidos do recurso de acordo com o tipo de distribuição.
@author Lucas Fagundes
@since 17/04/2023
@version P12
@param 01 cRecurso , Caracter, Código do recurso que irá remover os periodos.
@param 02 aOperacao, Array   , Array com as informações da operação.
@param 03 aProcs   , Array   , Array com as operações que já foram distribuidas.
@return Nil
/*/
Method removePeriodosInvalidos(cRecurso, aOperacao, aProcs) Class PCPA152TempoOperacao
	Local cHora     := ""
	Local dData     := Nil
	Local nTamProcs := 0

	// Se distribui pela data de inicio, deixa apenas os tempos após a ultima operação ou após a data de inicio da op.
	If Self:oParametro["tipoProgramacao"] == 1

		If !Empty(aProcs)
			nTamProcs := Len(aProcs)
			dData := aProcs[nTamProcs][ARRAY_VM_DATA]
			cHora := aProcs[nTamProcs][ARRAY_VM_FIM ]
		Else
			dData := aOperacao[ARRAY_MF_DTINI]
			cHora := "00:00"
		EndIf

		Self:removePerAnteriores(cRecurso, dData, cHora)

	// Se distribui pela data de entrega, deixa apenas os tempos antes do inicio da ultima operação ou antes da entrega da op.
	Else

		If !Empty(aProcs)
			nTamProcs := Len(aProcs)
			dData  := aProcs[nTamProcs][ARRAY_VM_DATA  ]
			cHora  := aProcs[nTamProcs][ARRAY_VM_INICIO]
		Else
			dData := aOperacao[ARRAY_MF_DTENT]
			cHora := "24:00"
		EndIf

		Self:removePerPosteriores(cRecurso, dData, cHora)
	EndIf

Return Nil

/*/{Protheus.doc} removePerAnteriores
Remove os periodos anteriores a data recebida.
@author Lucas Fagundes
@since 06/04/2023
@version P12
@param 01 cRecurso, Caracter, Recurso que irá remover os períodos.
@param 02 dData   , Date    , Data final dos periodos que irá remover.
@param 03 cHora   , Caracter, Hora final dos periodos que irá remover.
@return Nil
/*/
Method removePerAnteriores(cRecurso, dData, cHora) Class PCPA152TempoOperacao
	Local aPeriodo   := {}
	Local lRemove    := .F.
	Local nHora      := 0
	Local nHoraIni   := 0
	Local nIndex     := 1
	Local nRemovidos := 0
	Local nTotal     := 0

	nHora := __Hrs2Min(cHora)

	nTotal := Len(Self:oDispRecur[cRecurso])
	While nIndex <= nTotal
		aPeriodo := Self:oDispRecur[cRecurso][nIndex]
		lRemove  := .F.

		// Disponibilidade em data posterior a data valida, para de verificar.
		If aPeriodo[ARRAY_DISP_RECURSO_DATA] > dData
			Exit
		EndIf

		// Disponibilidade com data anterior a data valida, remove.
		If aPeriodo[ARRAY_DISP_RECURSO_DATA] < dData
			lRemove := .T.
		EndIf

		// Disponibilidade com data igual a data de remoção, verifica os horarios.
		If aPeriodo[ARRAY_DISP_RECURSO_DATA] == dData
			nHoraIni := aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO]

			// Inicia em horario valido, ignora.
			If nHoraIni >= nHora
				nIndex++
				Loop
			EndIf

			// Inicia em horario invalido, verifica a hora de finalização.
			nHoraFim := aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM]

			// Finaliza em horario invalido, remove completamente.
			If nHoraFim <= nHora
				lRemove := .T.

			// Finaliza em horario valido, ajusta para iniciar em horario valido.
			Else
				aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO] := nHora

				aPeriodo[ARRAY_DISP_RECURSO_TEMPO] := aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM] - aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO]
			EndIf
		EndIf

		If lRemove
			aDel(Self:oDispRecur[cRecurso], nIndex)
			nRemovidos++
			nTotal--
		Else
			nIndex++
		EndIf
	End

	If nRemovidos > 0
		// Ajusta o tamanho do array com as posições removidas
		aSize(Self:oDispRecur[cRecurso], nTotal)
	EndIf

Return Nil

/*/{Protheus.doc} removePerPosteriores
Remove os periodos posteriores a data recebida.
@author Lucas Fagundes
@since 17/04/2023
@version P12
@param 01 cRecurso, Caracter, Recurso que irá remover os períodos.
@param 02 dData   , Date    , Data final dos periodos que irá remover.
@param 03 cHora   , Caracter, Hora final dos periodos que irá remover.
@return Nil
/*/
Method removePerPosteriores(cRecurso, dData, cHora) Class PCPA152TempoOperacao
	Local aPeriodo := {}
	Local nHora    := 0
	Local nHoraFim := 0
	Local nHoraIni := 0
	Local nIndex   := 0
	Local nRemovidos := 0

	nHora := __Hrs2Min(cHora)

	For nIndex := Len(Self:oDispRecur[cRecurso]) To 1 Step -1
		aPeriodo := Self:oDispRecur[cRecurso][nIndex]

		// Data da disponibilidade anterior a data desejada, ignora.
		If aPeriodo[ARRAY_DISP_RECURSO_DATA] < dData
			Loop
		EndIf

		// Data da disponibilidade maior que a data desejada, remove.
		If aPeriodo[ARRAY_DISP_RECURSO_DATA] > dData
			aDel(Self:oDispRecur[cRecurso], nIndex)
			nRemovidos++
			Loop
		EndIf
		// Data da disponibilidade igual a data desejada, verifica o horario de inicio.
		nHoraIni := aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO]

		// Hora de inicio da disponibilidade posterior ou igual a hora desejada, remove.
		If nHoraIni >= nHora
			aDel(Self:oDispRecur[cRecurso], nIndex)
			nRemovidos++
			Loop
		EndIf
		// Hora de inicio anterior a hora desejada, verifica a hora final
		nHoraFim := aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM]

 		// Disponibilidade inica em horario valido e encerra em horario invalido, ajusta a disponibilidade para encerrar no horario desejado.
		If nHoraFim > nHora
			aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM] := nHora

			aPeriodo[ARRAY_DISP_RECURSO_TEMPO] := aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM] - aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO]
		EndIf
	Next

	If nRemovidos > 0
		// Ajusta o tamanho do array com as posições removidas
		aSize(Self:oDispRecur[cRecurso], Len(Self:oDispRecur[cRecurso])-nRemovidos)
	EndIf

Return Nil

/*/{Protheus.doc} criaPeriodoOperacao
Realiza a criação de um array com o periodo de uma operação.
@author Lucas Fagundes
@since 04/05/2023
@version P12
@param 01 dData   , Date    , Data do periodo.
@param 02 nHoraIni, Numerico, Hora inicial do periodo.
@param 03 nHoraFim, Numerico, Hora final do periodo.
@param 04 nTempo  , Numerico, Tempo do periodo.
@return aPeriodo, Array, Array de periodo de uma operação.
/*/
Method criaPeriodoOperacao(dData, nHoraIni, nHoraFim, nTempo) Class PCPA152TempoOperacao
	Local aPeriodo := Array(ARRAY_PERIODO_OPER_TAMANHO)

	aPeriodo[ARRAY_PERIODO_OPER_DATA       ] := dData
	aPeriodo[ARRAY_PERIODO_OPER_HORA_INICIO] := nHoraIni
	aPeriodo[ARRAY_PERIODO_OPER_HORA_FIM   ] := nHoraFim
	aPeriodo[ARRAY_PERIODO_OPER_TEMPO      ] := nTempo

Return aPeriodo
