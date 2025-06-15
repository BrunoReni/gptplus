#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDominio.ch'

#DEFINE ARRAY_FILIAIS_FILIAL              1
#DEFINE ARRAY_FILIAIS_PRIORIDADE          2
#DEFINE ARRAY_FILIAIS_TAMANHO             2

#DEFINE TRANF_POS_FILIAL_DESTINO          1
#DEFINE TRANF_POS_FILIAL_ORIGEM           2
#DEFINE TRANF_POS_PRODUTO                 3
#DEFINE TRANF_POS_DATA                    4
#DEFINE TRANF_POS_QUANTIDADE              5
#DEFINE TRANF_POS_DOCUMENTO               6
#DEFINE TRANF_POS_DATA_RECEBIMENTO        7
#DEFINE TRANF_TAMANHO                     7

#DEFINE ABAIXA_POS_CHAVE                  1
#DEFINE ABAIXA_POS_DOCPAI                 2
#DEFINE ABAIXA_POS_NECESSIDADE            3
#DEFINE ABAIXA_POS_QTD_ESTOQUE            4
#DEFINE ABAIXA_POS_CONSUMO_ESTOQUE        5
#DEFINE ABAIXA_POS_QTD_SUBSTITUICAO       6
#DEFINE ABAIXA_POS_QUEBRAS_QUANTIDADE     7
#DEFINE ABAIXA_POS_TIPO_PAI               8
#DEFINE ABAIXA_POS_NEC_ORIG               9
#DEFINE ABAIXA_POS_REGRA_ALT             10
#DEFINE ABAIXA_POS_CHAVE_SUBST           11
#DEFINE ABAIXA_POS_TRANSFERENCIA_ENTRADA 12
#DEFINE ABAIXA_POS_TRANSFERENCIA_SAIDA   13
#DEFINE ABAIXA_POS_DOCFILHO              14
#DEFINE ABAIXA_POS_RASTRO_AGLUTINACAO    15
#DEFINE ABAIXA_SIZE                      15

Static snTamCod := 90
Static _lLogM1  := Nil

/*/{Protheus.doc} MrpDominio_MultiEmpresa
Processamentos do Multi-empresa

@author    lucas.franca
@since     11/09/2020
@version   P12
/*/
CLASS MrpDominio_MultiEmpresa FROM LongClassName

	DATA aFiliais         AS ARRAY
	DATA lUsaMultiEmpresa AS LOGICAL
	DATA nTotalFiliais    AS NUMERIC
	DATA nTamanhoFilial   AS NUMERIC
	DATA oDados           AS OBJECT
	DATA oDominio         AS OBJECT //Instância da classe de domínio (MRPDOMINIO)
	DATA oParametros      AS OBJECT //Instância dos parâmetros
	DATA oTempTable       AS OBJECT
	DATA oCachexFilial    AS OBJECT

	METHOD new(oDominio) CONSTRUCTOR
	METHOD alternativosMultiEmpresa(cFilAux, cProduto, nPeriodo, cIDOpc, aBaixaPorOP, nQtdNec, lWait, aMinMaxAlt)
	METHOD buscaFilialEstrutura(cFilAux, cProduto)
	METHOD carregaArrayFiliais()
	METHOD carregaCacheFiliais()
	METHOD consumirEstoqueME(cFilAux, cProduto, nPeriodo, cIDOpc, nSaldo, lWait, nQtTotTran, lTransfere, lSemTran, lPrdAlt, aTransf)
	METHOD criaTempFiliais()
	METHOD desfazSaidaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aBaixaPorOP, nQtrSai, nSaldo, lForcaTran)
	METHOD desfazEntradaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aDados, cChvCheck, lEfetiva, cPrdLoop)
	METHOD dropTempFiliais()
	METHOD filialPorIndice(nIndex)
	METHOD getFilialTabela(cTabela, cFilAux)
	METHOD gravaDadosTransferencia(cFilDes, cFilOri, cProduto, cPeriodo, cDocumento, nQtdTran, lProducao, cRecebTran)
	METHOD novoIdTransferencia()
	METHOD processaEstruturaMultiempresa(cFilAux,cProduto,cIDOpc,nPeriodo,aBaixaPorOP,nQtdNec,nQtdTran)
	METHOD queryFilial(cTable, cField, lAddTable, cAlias)
	METHOD retornaFiliais()
	METHOD tamanhoFilial()
	METHOD totalDeFiliais()
	METHOD utilizaMultiEmpresa()
ENDCLASS

/*/{Protheus.doc} new
Metodo construtor

@author lucas.franca
@since 11/09/2020
@version P12
Return Self, objeto, instancia desta classe
/*/
METHOD new(oDominio) CLASS MrpDominio_MultiEmpresa
	Self:aFiliais         := Nil
	Self:lUsaMultiEmpresa := Nil
	Self:nTotalFiliais    := 0
	Self:nTamanhoFilial   := -1
	Self:oDominio         := oDominio
	Self:oParametros      := oDominio:oParametros
	Self:oDados           := oDominio:oDados
	Self:oTempTable       := Nil
	Self:oCachexFilial    := Nil
Return Self

/*/{Protheus.doc} carregaArrayFiliais
Carrega o array de filiais para processamento.
Filial com prioridade 0 é a filial centralizadora. As demais filiais serão as filiais centralizadas.

@author lucas.franca
@since 11/09/2020
@version P12
/*/
METHOD carregaArrayFiliais() CLASS MrpDominio_MultiEmpresa
	Local aFilCent := {}
	Local nIndex   := 0
	Local nTotal   := 0
	Local nSizeFil := 0

	If Self:aFiliais == Nil
		Self:aFiliais := {}

		If Self:oParametros["branchCentralizing"] != Nil .And. Self:oParametros["centralizedBranches"] != Nil
			aFilCent := StrToKArr(Self:oParametros["centralizedBranches"], "|")
			nTotal   := Len(aFilCent)

			If nTotal > 0
				nSizeFil            := FwSizeFilial()
				Self:nTamanhoFilial := nSizeFil

				aAdd(Self:aFiliais, {PadR(Self:oParametros["branchCentralizing"], nSizeFil), 0})
			Else
				Self:nTamanhoFilial := 0
			EndIf
			For nIndex := 1 To nTotal
				aAdd(Self:aFiliais, {PadR(aFilCent[nIndex], nSizeFil), nIndex})
			Next nIndex

			aSize(aFilCent, 0)
		EndIf
	EndIf
Return

/*/{Protheus.doc} carregaCacheFiliais
Carrega cache de filiais (xFilial) para utilização em buscas nas tabelas do cálculo.

@author lucas.franca
@since 14/10/2020
@version P12
/*/
METHOD carregaCacheFiliais() CLASS MrpDominio_MultiEmpresa
	Local cFil   := ""
	Local nIndex := 0

	If Self:oCachexFilial == Nil .And. Self:utilizaMultiEmpresa()
		Self:oCachexFilial := JsonObject():New()

		For nIndex := 1 To Self:totalDeFiliais()
			cFil := Self:filialPorIndice(nIndex)
			Self:oCachexFilial["T4N" + cFil] := xFilial("T4N", cFil)
		Next nIndex
	EndIf
Return

/*/{Protheus.doc} getFilialTabela
Recupera a filial para utilização em busca da tabela

@author lucas.franca
@since 14/10/2020
@version P12
@param cTabela, character, Tabela utilizada
@param cFilAux, character, Código da filial utilizada.
/*/
METHOD getFilialTabela(cTabela, cFilAux) CLASS MrpDominio_MultiEmpresa
	Local cFilRet := cFilAux

	If Self:oCachexFilial[cTabela + cFilAux] != Nil
		cFilRet := Self:oCachexFilial[cTabela + cFilAux]
	EndIf

Return cFilRet

/*/{Protheus.doc} totalDeFiliais
Retorna a quantidade total de filiais para processar

@author lucas.franca
@since 06/10/2020
@version P12
@return nTotal, Numeric, Total de filiais
/*/
METHOD totalDeFiliais() CLASS MrpDominio_MultiEmpresa
	If Self:lUsaMultiEmpresa == Nil
		Self:utilizaMultiEmpresa()
	EndIf
Return Self:nTotalFiliais

/*/{Protheus.doc} filialPorIndice
Retorna o código da filial de processamento por índice

@author lucas.franca
@since 06/10/2020
@version P12
@return cFilIdx, Character, Filial correspondente ao índice
/*/
METHOD filialPorIndice(nIndex) CLASS MrpDominio_MultiEmpresa
	Local cFilIdx := Nil

	If Self:lUsaMultiEmpresa == Nil
		Self:utilizaMultiEmpresa()
	EndIf
	If nIndex <= Self:nTotalFiliais
		cFilIdx := Self:aFiliais[nIndex][ARRAY_FILIAIS_FILIAL]
	EndIf
Return cFilIdx

/*/{Protheus.doc} retornaFiliais
Retorna as filiais que devem ser consideradas no processamento do MRP

@author lucas.franca
@since 11/09/2020
@version P12
@return aFiliais, Array, Array com as filiais para processamento.
/*/
METHOD retornaFiliais() CLASS MrpDominio_MultiEmpresa
	Local aFiliais := {}

	If Self:utilizaMultiEmpresa()
		aFiliais := Self:aFiliais
	EndIf

Return aFiliais

/*/{Protheus.doc} utilizaMultiEmpresa
Verifica se o MRP está parametrizado para execução com multi-empresas

@author lucas.franca
@since 11/09/2020
@version P12
@return lUsaME, Logic, Indica se o Multi-empresa está habilitado ou não.
/*/
METHOD utilizaMultiEmpresa() CLASS MrpDominio_MultiEmpresa
	Local lUsaME := .F.

	If Self:lUsaMultiEmpresa == Nil
		Self:lUsaMultiEmpresa := .F.
		//Se existirem os parâmetros de filial centralizada/filiais centralizadoras, verifica se é multi-empresa.
		If Self:oParametros["branchCentralizing"] != Nil .And. Self:oParametros["centralizedBranches"] != Nil .And. FwAliasInDic("SMB", .F.)
			//Carrega o array de filiais de acordo com os parâmetros recebidos.
			Self:carregaArrayFiliais()

			//Se existir mais de uma filial para processamento, considera que o MRP é Multi-empresa.
			Self:nTotalFiliais := Len(Self:aFiliais)
			If Self:nTotalFiliais > 1
				Self:lUsaMultiEmpresa := .T.
			EndIf
		EndIf

		If Self:lUsaMultiEmpresa
			Self:carregaCacheFiliais()
		EndIf

	EndIf
	lUsaME := Self:lUsaMultiEmpresa

Return lUsaME

/*/{Protheus.doc} consumirEstoqueME
Verifica e consome o estoque das outras filiais conforme prioridade

@author ricardo.prandi
@since 11/11/2020
@version P12
@param 01 cFilAux   , Character, Filial que está sendo processada
@param 02 cProduto  , Character, Código do produto que está sendo processado
@param 03 nPeriodo  , Numeric  , Número do período que está sendo processado
@param 04 cIDOpc    , Character, Id do opcional relacionado
@param 05 nSaldo    , Numeric  , Saldo a ser verifica nas outras filiais
@param 06 lWait     , Logic    , Retorna por referencia indicando se existe na Matriz de Calculo, mas nao foi calculado. Interrompe o consumo.
@param 07 nQtTotTran, Numeric  , Retorna a quantidade total de transferÊncia efetuada
@param 08 lTransfere, Logic    , Identifica se deve transferir, ou somente verificar se existe saldo a transferir.
@param 09 lSemTran  , Logic    , Identifica que as tentativas de buscar saldo deste produto em outras filiais se esgotaram, e não deve ser
                                 realizada nova tentativa de consumo de estoque neste cálculo (retorna por referência)
@param 10 lPrdAlt   , Logic    , Indica que está fazendo transferências para a regra de produtos alternativos
@param 11 aTransf   , Array    , Retorna por referência informações de filial e quantidade transferida
@return nSaldo, Numeric, Retorna a quantidade restante de necessidade do produto
/*/
METHOD consumirEstoqueME(cFilAux, cProduto, nPeriodo, cIDOpc, nSaldo, lWait,;
                         nQtTotTran, lTransfere, lSemTran, lPrdAlt, aTransf) CLASS MrpDominio_MultiEmpresa
	Local aRetAux     := {}
	Local aAreaPRD    := Self:oDados:retornaArea("PRD")
	Local cChaveMAT   := ""
	Local cChaveOrig  := cFilAux + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
	Local cChaveProd  := ""
	Local cMatrizOri  := ""
	Local cDtTrans    := ""
	Local dDtTrans    := ""
	Local cChaveWait  := ""
	Local cChaveAlt   := ""
	Local lCalculado  := .F.
	Local lErrorMat   := .F.
	Local lEncerra    := .F.
	Local lError      := .F.
	Local nIndFil     := 1
	Local nPerAux     := 1
	Local nPerTran    := nPeriodo
	Local nQtdTran    := 0
	Local nSaldoFil   := 0
	Local nSobra      := 0
	Local nSaldoNec   := 0
	Local nTentativa  := 0
	Local nThrPrd     := 0
	Local nPerCal     := 0
	Local oTranfDisp  := Nil

	Default lWait      := .F.
	Default lSemTran   := .F.
	Default lTransfere := .T.
	Default lPrdAlt    := .F.

	nSaldo  := nSaldo * -1
	nSobra  := nSaldo
	aTransf := {}

	dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
	Self:oDominio:oLeadTime:aplicar(cFilAux, cFilAux + cProduto, @nPerTran, @dDtTrans, .T., .T.)

	_lLogM1 := Iif(_lLogM1==Nil, Self:oDados:oLogs:logValido("M1"), _lLogM1)

	If lPrdAlt
		//Transferência realizada para substituição de alternativos
		//Utiliza o oTranfDisp para identificar quantidades de transferências
		//que já foram realizadas e reutiliza essas transferências.
		oTranfDisp := Self:oDominio:oAlternativo:oTranfDisp
	EndIf

	//Percorre o array de filiais para buscar os estoques
	For nIndFil := 1 To Self:nTotalFiliais
		//Se for a mesma filial da origem, vai para a próxima filial
		If Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] == cFilAux
			Loop
		Endif

		If lPrdAlt 
			cChaveAlt := Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + RTrim(cProduto)
			If oTranfDisp:HasProperty(cChaveAlt) .And. oTranfDisp[cChaveAlt] > 0
				//Se for produto alternativo e existir dados em Self:oDominio:oAlternativo:oTranfDisp,
				//indica que já existem transferências realizadas. Não é necessário criar uma nova.
				nSaldoFil  := oTranfDisp[cChaveAlt]
				nSobra     := nSaldo - nSaldoFil
				nSobra     := If(nSobra < 0, 0, nSobra)
				nQtdTran   := nSaldo-nSobra
				nQtTotTran += nQtdTran
				nSaldo     := nSobra

				If lTransfere
					oTranfDisp[cChaveAlt] -= nQtdTran
				EndIf
			EndIf
		EndIf

		If nSaldo > 0
			cChaveProd := Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")

			nPerTran := Self:oDominio:oPeriodos:buscaPeriodoDaData(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] , dDtTrans, .T.)
			dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] , nPerTran)
			cDtTrans := DtoS(dDtTrans)

			//Percorre período até achar saldo
			For nPerAux := nPerTran to 1 step -1
				cChaveMAT  := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], nPerAux)) + cChaveProd
				lErrorMat  := .F.
				Self:oDados:retornaCampo("MAT" , 1, cChaveMAT, "MAT_SALDO", @lErrorMat)

				If !lErrorMat
					lCalculado := Self:oDados:foiCalculado(cChaveProd, nPerAux, /*lAvMinimo*/, @nPerCal)
					If !lCalculado
						nThrPrd := Self:oDados:oProdutos:getflag("PROD_THREAD_PER_CAL" + RTrim(cChaveProd), .F., .F.)
						If !Empty(nThrPrd) .And. nThrPrd == ThreadID() .And. nPerCal+1 == nPerAux
							lCalculado := .T.
						EndIf
					EndIf
					If lCalculado
						If Self:oDados:reservaProduto(cChaveProd)

							aRetAux   := ::oDados:retornaCampo("MAT", 1, cChaveMAT, {"MAT_NECESS","MAT_SALDO"}, @lErrorMat, , , , , , .T. /*lVarios*/)
							If nPerAux == nPeriodo
								//Período atual, considera o saldo final do período.
								nSaldoFil := aRetAux[2]
								nSaldoFil -= Self:oDominio:oRastreio:necPPed_ES(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux)
								nSaldoNec := 0
							Else
								//Período anterior, considera o saldo que será gerado para o próximo período.
								nSaldoFil := aRetAux[2]
								nSaldoFil += aRetAux[1]
								nSaldoFil -= Self:oDominio:oRastreio:necPPed_ES(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux)
								nSaldoNec := nSaldoFil - aRetAux[2]
							EndIf

							aSize(aRetAux, 0)

							If nSaldoFil > 0
								nSobra := nSaldo - nSaldoFil
								nSobra := If(nSobra < 0, 0, nSobra)

								nQtdTran := nSaldo-nSobra

								nQtTotTran += nQtdTran

								If lTransfere
									//Grava Matriz do produto a ser transferido
									cChaveMAT  := cDtTrans + cChaveProd
									cMatrizOri := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cChaveOrig

									Self:oDados:oMatriz:trava(cChaveMAT)
									Self:oDados:gravaCampo("MAT", 1, cChaveMAT, {"MAT_QTRSAI", "MAT_SALDO"}, {nQtdTran, -nQtdTran}, .F., .T., /*08*/, .T.)

									If Empty(cIdOpc)
										Self:oDominio:oOpcionais:separaIdChaveProduto(@cProduto, @cIdOpc)
									EndIf

									If _lLogM1
										Self:oDados:oLogs:log("Registra transferencia do produto: [" + RTrim(cProduto) + "]" +;
										                      " no periodo: [" + cValToChar(nPeriodo) + "]" + ;
										                      " Qtd: [" + cValToChar(nQtdTran) + "]" +;
										                      " Filial origem -> destino: [" +;
										                      Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + "] -> [" + cFilAux + "]", "M1")
									EndIf

									Self:oDominio:oRastreio:incluiNecessidade(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL],;
																			"TRANF_ES"                                  ,;
																			cMatrizOri                                  ,;
																			cProduto                                    ,;
																			cIDOpc                                      ,;
																			/*cTRT*/                                    ,;
																			0                                           ,;
																			nPerTran                                    ,;
																			/*cListOrig*/                               ,;
																			/*cRegra*/                                  ,;
																			/*cOrdSubst*/                               ,;
																			/*cRoteiro*/                                ,;
																			/*cOperacao*/                               ,;
																			/*nQtrEnt*/                                 ,;
																			nQtdTran                                    ,;
																			/*cDocFilho*/                               ,;
																			nSaldoFil                                    )
									If nSaldoNec > 0
										//Quando utiliza um saldo que sobrou de uma necessidade, não é necessário
										//recalcular o período atual do produto, apenas os próximos.
										Self:oDados:gravaPeriodosProd(cChaveProd, nPerTran+1)
										If !Self:oDados:oMatriz:existList("Periodos_Produto_" + cChaveProd)
											Self:oDados:oMatriz:createList("Periodos_Produto_" + cChaveProd)
										EndIf
										Self:oDados:oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPerTran+1), nPerTran+1)
									Else
										Self:oDados:gravaPeriodosProd(cChaveProd, nPerTran)
									EndIf
									Self:oDados:oMatriz:destrava(cChaveMAT)
									Self:oDados:decrementaTotalizador(cChaveProd)

									//Grava Matriz do produto origem
									Self:oDados:gravaCampo("MAT", 1, cMatrizOri, {"MAT_QTRENT", "MAT_SALDO"}, {nQtdTran, nQtdTran}, .F., .T., /*08*/, .T.)

									Self:gravaDadosTransferencia(cFilAux, Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, cDtTrans, cMatrizOri, nQtdTran, .F., DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)))

									//Grava array de transferências realizadas para gravar os dados na global
									//e reutilizar no objeto oTranfDisp dos produtos alternativos.
									aAdd(aTransf, {Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], nQtdTran})
								EndIf
							EndIf

							Self:oDados:liberaProduto(cChaveProd)
							Exit
						Else
							If Self:oDominio:oParametros["nThreads"] > 1
								Self:oDados:oLiveLock:setResult(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto , 1, .F., .T., .T.)
							EndIf
							lWait := .T.
							Exit
						EndIf
					Else
						cChaveWait := Self:oDados:oProdutos:getFlag("|WaitRecalculo|"+cChaveOrig+"|", @lError)
						If !lError .And. cChaveWait == cChaveProd
							Self:oDados:oProdutos:setFlag("|WaitRecalculoCount|"+cChaveOrig+"|", @nTentativa,,,,.T.)

							If nTentativa >= 10
								lEncerra := .T.
							EndIf
						EndIf

						If !lEncerra
							If Self:oDominio:oParametros["nThreads"] > 1
								Self:oDados:oLiveLock:setResult(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto , 1, .F., .T., .T.)
							EndIf

							Self:oDados:oProdutos:setFlag("|WaitRecalculo|"+cChaveOrig+"|", cChaveProd, @lError)

							lWait := .T.
						EndIf

						Exit
					EndIf
				Else
					nSaldoFil := Self:oDominio:saldoInicial(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux, , cIDOpc)
					If nSaldoFil > 0

						If !Self:oDados:existeMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux, , cIDOpc) .And. Self:oDados:oMatriz:trava(cChaveMAT)

							//Decrementa totalizador relacionado ao oDominio:loopNiveis
							If !Self:oDados:existeMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, , , , cIDOpc) .or. !Self:oDados:possuiPendencia(cChaveProd, .T.)
								Self:oDados:decrementaTotalizador(cChaveProd)
							EndIf

							//"Inclui novo registro na Matriz: " + " - Periodo: " + " - nNecessidade: "
							Self:oDados:atualizaMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], Self:oDominio:oPeriodos:retornaDataPeriodo(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], nPerAux), cProduto, Nil, {"MAT_SLDINI", "MAT_SALDO"}, {nSaldoFil, nSaldoFil},,,,.F.)
							Self:oDados:gravaPeriodosProd(cChaveProd, nPerAux)
							Self:oDados:oMatriz:destrava(cChaveMAT)
							lWait := .T.

							If Self:oDominio:oParametros["nThreads"] > 1
								Self:oDados:oLiveLock:setResult(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto , 1, .F., .T., .T.)
							EndIf

							Exit
						ElseIf Self:oDados:existeMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux, , cIDOpc)
							nPerAux++
							Loop
						EndIf
					Else
						Loop
					EndIf
				EndIf
			Next nPerAux
		EndIf
		
		nSaldo := nSobra

		If lWait .Or. nSobra == 0 .Or. lEncerra
			Exit
		EndIf
	Next nIndFil

	If !lWait
		Self:oDados:oProdutos:setFlag("|WaitRecalculo|"+cChaveOrig+"|", "", @lError)
		Self:oDados:oProdutos:setFlag("|WaitRecalculoCount|"+cChaveOrig+"|", 0, @lError)
	EndIf

	If lEncerra
		//Se lEncerra = .T., indica que as tentativas de buscar saldo deste produto
		//em outra filial se esgotaram. Portanto, lSemTran := .T. irá indicar que neste cálculo
		//do MRP não deve ser executada nova chamada do consumirEstoqueME.
		lSemTran := .T.
	Else
		//Se lEncerra = .F., indica que ainda podem ser realizadas tentativas de buscar
		//o saldo deste produto em outras filiais.
		lSemTran := .F.
	EndIf

	Self:oDados:setaArea(aAreaPRD)
	aSize(aAreaPRD, 0)

	nSaldo := nSaldo * -1

Return nSaldo

/*/{Protheus.doc} gravaDadosTransferencia
Verifica e consome o estoque das outras filiais conforme prioridade

@author ricardo.prandi
@since 11/11/2020
@version P12
@param 01 cFilDes   , Character, Filial destino da transferência
@param 02 cFilOri   , Character, Filial origem da transferência
@param 03 cProduto  , Character, Produto que está sendo transferido
@param 04 cPeriodo  , Character, Data da transferência
@param 05 cDocumento, Character, Documento usado na trasferência
@param 06 nQtdTran  , Numeric  , Quantidade transferida
@param 07 lProducao , Logic    , Indica que é uma transferência do tipo TRANF_PR.
@param 08 cRecebTran, Character, Data de recebimento da transferência na filial destino
@return nil
/*/
METHOD gravaDadosTransferencia(cFilDes, cFilOri, cProduto, cPeriodo, cDocumento, nQtdTran, lProducao, cRecebTran) CLASS MrpDominio_MultiEmpresa
	Local aDados    := {}
	Local aTransf   := {}
	Local cChave  	:= cProduto + cFilDes + cFilOri + cPeriodo + cDocumento
	Local lError    := .F.
	Local oTransf 	:= Self:oDados:oTransferencia

	If oTransf:getRow(1, cChave, Nil, @aDados, .F., .T.)
		aDados[TRANF_POS_QUANTIDADE] += nQtdTran

		If !oTransf:updRow(1, cChave, Nil, aDados, .F., .T.)
			Self:oDados:oLogs:log(STR0170 + "'" + AllTrim(cProduto) + "'", "E") //"Erro na atualização dos dados de transferência - Produto: "
		EndIf
	Else
		aDados := Array(TRANF_TAMANHO)

		aDados[TRANF_POS_FILIAL_DESTINO  ] := cFilDes
		aDados[TRANF_POS_FILIAL_ORIGEM   ] := cFilOri
		aDados[TRANF_POS_PRODUTO         ] := cProduto
		aDados[TRANF_POS_DATA            ] := cPeriodo
		aDados[TRANF_POS_QUANTIDADE      ] := nQtdTran
		aDados[TRANF_POS_DOCUMENTO       ] := cDocumento
		aDados[TRANF_POS_DATA_RECEBIMENTO] := cRecebTran

		If !oTransf:addRow(cChave, aDados)
			Self:oDados:oLogs:log(STR0171 + "'" + AllTrim(cProduto) + "'", "E")
		EndIf
	EndIf

	If lProducao
		oTransf:setFlag("TRF_DOCS" + CHR(13) + cDocumento, cChave, @lError)
	Else
		aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cDocumento, @lError)
		If lError
			aTransf := {cChave}
			lError  := .F.
		Else
			aAdd(aTransf, cChave)
		EndIf
		oTransf:setItemAList("TRANSF_ESTOQUE", cDocumento, aTransf, @lError, .F., .F.)
		aSize(aTransf, 0)
	EndIf

	aSize(aDados, 0)

Return Nil

/*/{Protheus.doc} queryFilial
Monta filtro de filial para query de acordo com as filiais utilizadas no cálculo.

@author lucas.franca
@since 06/10/2020
@version P12
@param 01 cTable   , Character, Tabela que será feita o filtro de filial.
@param 02 cField   , Character, Coluna de filial utilizada para filtro.
@param 03 lAddTable, Logic    , Identifica se deve adicionar o nome da tabela como Alias.
@param 04 cAlias   , Character, Alias para utilizar na tabela.
@return cQuery  , Character, Query formatada para filtro das filiais.
/*/
METHOD queryFilial(cTable, cField, lAddTable, cAlias) CLASS MrpDominio_MultiEmpresa
	Local cQuery := cField
	Local nIndex := 0
	Local nTotal := 0

	Default cAlias := cTable

	If Self:utilizaMultiEmpresa()
		cQuery += " IN ("
		nTotal := Len(Self:aFiliais)
		For nIndex := 1 To nTotal
			If nIndex > 1
				cQuery += ","
			EndIf
			cQuery += "'" + xFilial(cTable, Self:aFiliais[nIndex][ARRAY_FILIAIS_FILIAL]) + "'"
		Next nIndex
		cQuery += ")"
	Else
		cQuery += " = '" + xFilial(cTable) + "' "
	EndIf

	If lAddTable
		cQuery := cAlias + "." + cQuery
	EndIf
Return cQuery

/*/{Protheus.doc} tamanhoFilial
Retorna o tamanho que deve ser considerado para a informação da filial

@author lucas.franca
@since 08/10/2020
@version P12
@return Self:nTamanhoFilial
/*/
METHOD tamanhoFilial() CLASS MrpDominio_MultiEmpresa

	If Self:nTamanhoFilial == -1
		If Self:utilizaMultiEmpresa()
			Self:nTamanhoFilial := Len(Self:aFiliais[1][ARRAY_FILIAIS_FILIAL])
		Else
			Self:nTamanhoFilial := 0
		EndIf
	EndIf
Return Self:nTamanhoFilial

/*/{Protheus.doc} criaTempFiliais
Cria tabela temporária com as informações das filiais para utilização em query.

@author lucas.franca
@since 09/10/2020
@version P12
@return cTableName, character, Nome da tabela para utilização em query.
/*/
METHOD criaTempFiliais() CLASS MrpDominio_MultiEmpresa
	Local aFields    := {}
	Local cTableName := ""
	Local cAlias     := GetNextAlias()
	Local cCols      := "FILIAL,PRIORI"

	If Self:utilizaMultiEmpresa()
		//Cria a temporária
		Self:oTempTable := FWTemporaryTable():New( cAlias )

		aAdd(aFields,{"FILIAL", "C", Self:tamanhoFilial(), 0})
		aAdd(aFields,{"PRIORI", "N", 2, 0})

		Self:oTempTable:SetFields( aFields )
		Self:oTempTable:AddIndex("01", {"FILIAL"} )
		Self:oTempTable:AddIndex("02", {"PRIORI"} )

		Self:oTempTable:Create()

		cTableName := Self:oTempTable:GetRealName()

		//Inclui as informações de filial e prioridade na tabela temporária
		If TcDbInsert(Self:oTempTable:cTableName, cCols, Self:aFiliais) < 0
			UserException(tcSQLError())
		EndIf
	EndIf

Return cTableName

/*/{Protheus.doc} dropTempFiliais
Elimina tabela temporária com as informações das filiais.

@author lucas.franca
@since 09/10/2020
@version P12
@return Nil
/*/
METHOD dropTempFiliais() CLASS MrpDominio_MultiEmpresa
	If Self:oTempTable != Nil
		Self:oTempTable:Delete()
		FreeObj(Self:oTempTable)
	EndIf
Return Nil

/*/{Protheus.doc} processaEstruturaMultiempresa
Busca se o produto possui estrutura em outra filial e gera as informação na MATRIZ e RASTREIO para o processamento

@author ricardo.prandi
@since 04/02/2021
@version P12
@param 01 cFilAux    , Character, Filial que está sendo processada
@param 02 cProduto   , Character, Código do produto que está sendo processado
@param 03 cIDOpc     , Character, Id do opcional relacionado
@param 04 nPeriodo   , Numeric  , Número do período que está sendo processado
@param 05 aBaixaPorOP, Array    , Informações da tabela de rastreio do produto que está sendo processado
@param 06 nQtdNec    , Numeric  , Quantidade da necessidade restante para ser processada
@param 07 nQtdTran   , Numeric  , Retorna a quatidade transferida
@return nQtdNec, Numeric, Retorna a quantidade restante de necessidade do produto
/*/
METHOD processaEstruturaMultiempresa(cFilAux,cProduto,cIDOpc,nPeriodo,aBaixaPorOP,nQtdNec,nQtdTran) CLASS MrpDominio_MultiEmpresa
	Local cChaveMAT  := ""
	local cChaveProd := ""
	Local cFilEst    := ""
	Local cProxId    := ""
	Local cDtTrans   := ""
	Local dDtTrans   := ""
	Local nPerTran   := nPeriodo
	Local lEstrutura := .F.
	Local lError     := .F.

	nQtdTran := 0

	lEstrutura := Self:oDados:oProdutos:getFlag("|PossuiEstrutura|"+cProduto+"|", @lError)

	If !lError .And. lEstrutura
		cFilEst := Self:buscaFilialEstrutura(cFilAux, cProduto)

		If !Empty(cFilEst)
			dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
			Self:oDominio:oLeadTime:aplicar(cFilAux, cFilAux + cProduto, nPerTran, @dDtTrans, .T., .T.)

			nPerTran := Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilEst, dDtTrans, .T.)
			dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilEst, nPerTran)
			cDtTrans := DtoS(dDtTrans)

			If "|TRANF" $ "|"+aBaixaPorOP[ABAIXA_POS_DOCFILHO]
				cProxId := aBaixaPorOP[ABAIXA_POS_DOCFILHO]
			Else
				cProxId := Self:novoIdTransferencia()
				aBaixaPorOP[ABAIXA_POS_DOCFILHO] := cProxId
			EndIf

			aBaixaPorOP[ABAIXA_POS_TRANSFERENCIA_ENTRADA] += nQtdNec

			//Grava filial destino
			cChaveMAT := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cFilAux + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
			Self:oDados:gravaCampo("MAT", 1, cChaveMAT, {"MAT_QTRENT", "MAT_SALDO"}, {nQtdNec, nQtdNec}, .F., .T., /*08*/, .T.)

			//Grava filial origem
			Self:oDominio:oAglutina:preparaEInclui(cFilEst, "6", "TRANF_PR"                    , ;
												   {                                             ;
													aBaixaPorOP[ABAIXA_POS_TIPO_PAI]           , ;
												    aBaixaPorOP[ABAIXA_POS_DOCPAI]             , ;
													cProduto                                   , ;
													aBaixaPorOP[ABAIXA_POS_DOCFILHO]             ;
												   }                                           , ;
												   cProxId, cProduto, cIDOpc, " ", 0, nPerTran , ;
												   /*cRegra*/, /*lAglutina*/, .F., /*cRoteiro*/, ;
												   /*cOperacao*/, /*nQtrEnt*/, nQtdNec, cProxId)

			cChaveProd := cFilEst + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
			cChaveMAT  := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilEst, nPerTran)) + cChaveProd

			If Self:oDados:oMatriz:trava(cChaveMAT)
				If Self:oDados:existeMatriz(cFilEst, cProduto, nPerTran, @cChaveMAT, cIDOpc)
					Self:oDados:gravaCampo("MAT", 1, cChaveMAT, {"MAT_QTRSAI", "MAT_SALDO"}, {nQtdNec, -nQtdNec}, .F., .T., /*08*/, .T.)
				Else
					Self:oDados:atualizaMatriz(cFilEst, Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPerTran), cProduto, cIDOpc, {"MAT_QTRSAI", "MAT_SALDO"}, {nQtdNec, -nQtdNec})
				Endif

				Self:oDados:gravaPeriodosProd(cChaveProd, nPerTran)
				Self:oDados:oMatriz:destrava(cChaveMAT)
			EndIf

			Self:gravaDadosTransferencia(cFilAux, cFilEst, cProduto, cDtTrans, cProxId, nQtdNec, .T., DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)))

			nQtdTran := nQtdNec
			nQtdNec  := 0
		EndIf
	EndIf

Return nQtdNec

/*/{Protheus.doc} buscaFilialEstrutura
Retorna a filial na qual o produto possui estrutura

@author ricardo.prandi
@since 04/02/2021
@version P12
@param 01 cFilAux    , Character, Filial que está sendo processada
@param 02 cProduto   , Character, Código do produto que está sendo processado
@return cFilEst, Character, Retorna a filial na qual o produto possui estrutura
/*/
METHOD buscaFilialEstrutura(cFilAux, cProduto) CLASS MrpDominio_MultiEmpresa
	Local aAreaPRD  := {}
	Local cFilEst   := ""
	Local cEntraMRP := ""
	Local lError    := .F.
	Local lErrorPrd := .F.
	Local nIndFil   := 0

	cFilEst := Self:oDados:oProdutos:getFlag("|FilialEstrutura|"+cProduto+"|", @lError)

	If lError .Or. Empty(cFilEst)
		aAreaPRD := Self:oDados:retornaArea("PRD")
		For nIndFil := 1 To Self:nTotalFiliais
			If Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] == cFilAux
				Loop
			Endif

			If Self:oDados:possuiEstrutura(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto)
				lErrorPrd := .F.
				cEntraMRP := Self:oDados:retornaCampo("PRD", 1, Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto, "PRD_MRP", @lErrorPrd,.F.)

				If !lErrorPrd .And. cEntraMRP $ " 1"
					cFilEst := Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL]
					Self:oDados:oProdutos:setFlag("|FilialEstrutura|"+cProduto+"|", cFilEst)
					Exit
				EndIf
			EndIf
		Next nIndfil
		Self:oDados:setaArea(aAreaPRD)
		aSize(aAreaPRD, 0)

		If Empty(cFilEst)
			//Não encontrou estrutura válida em nenhuma filial, limpa a flag indicadora de produto com estrutura.
			Self:oDados:oProdutos:setFlag("|PossuiEstrutura|"+cProduto+"|", .F.)
		EndIf
	Endif

Return cFilEst

/*/{Protheus.doc} novoIdTransferencia
Identifica o próximo código de transferência
@author    ricardo.prandi
@since     04/02/2020
@version   1
@return cProxId, caracter, próximo número de ordem de produção
/*/
METHOD novoIdTransferencia() CLASS MrpDominio_MultiEmpresa

	Local cProxId := ""
	Local lError  := .F.
	Local nVal    := 0

	Self:oDados:oTransferencia:setFlag("ProximoIdTransferencia", @nVal, @lError, , .T., .T.)

	If lError .Or. nVal < 1
		cProxId := "TRANF000001"
	Else
		cProxId := "TRANF" + strZero(nVal, 6)
	EndIf

Return cProxId

/*/{Protheus.doc} desfazSaidaTransferencias
Desfaz as transferências de saída já criadas para novo cálculo do produto
@author    ricardo.prandi
@since     19/02/2020
@version   1
@param 01 cFilAux    , Character, Filial atual de processamento
@param 02 cProduto   , Character, Produto atual de processamento
@param 03 nPeriodo   , Numeric  , Período atual de processamento
@param 04 cIDOpc     , Character, ID de Opcional do registro atual
@param 05 cChaveOrig , Character, Chave da matriz do registro em processamento
@param 06 aBaixaPorOP, Array    , Array de rastreio com os dados do produto atual
@param 07 nQtrSai    , Numeric  , Quantidade de transferência de saída do produto atual. Retorna atualizado por referência.
@param 08 nSaldo     , Numeric  , Saldo do produto atual. Retorna atualizado por referência.
@param 09 lForcaTran , Logic    , Indica que a transferência de estoque deve ser desfeita sempre.
@return Nil
/*/
METHOD desfazSaidaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aBaixaPorOP, nQtrSai, nSaldo, lForcaTran) CLASS MrpDominio_MultiEmpresa
	Local aDocsPais  := {}
	Local aDadosChvs := {}
	Local aDadosTrf  := {}
	Local aIndBxAtu  := {}
	Local aRastreio  := {}
	Local aTransf    := {}
	Local aTranDisp  := {}
	Local cChave  	 := ""
	Local cChaveMat  := ""
	Local cChaveProd := ""
	Local cKey       := ""
	Local cList      := ""
	Local cFilDest   := ""
	Local lError     := .F.
	Local lTranfPR   := .F.
	Local lAglutina  := Self:oDominio:oAglutina:avaliaAglutinacao(cFilAux, cProduto)
	Local nIndex     := 0
	Local nIndRastro := 0
	Local nDesfez    := 0
	Local nQtdTran   := 0
	Local nQtdTrSaid := 0
	Local nIndPais   := 0
	Local nTotal     := Len(aBaixaPorOP)
	Local nTotTransf := 0
	Local nTotPais   := 0
	Local nTotRastro := 0
	Local nPos       := 0
	Local nPerDest   := nPeriodo
	Local nPosDocFil := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("DOCFILHO")
	Local nPosTrfEnt := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("TRANSFERENCIA_ENTRADA")
	Local nPosChvSub := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("CHAVE_SUBSTITUICAO")
	Local nPosPeriod := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("PERIODO")
	Local nPosCompon := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("COMPONENTE")
	Local oTransf 	 := Self:oDados:oTransferencia
	Local oDadosRast := Self:oDominio:oRastreio:oDados_Rastreio

	_lLogM1 := Iif(_lLogM1==Nil, Self:oDados:oLogs:logValido("M1"), _lLogM1)

	/*
		lForcaTran indica que houve alteração no saldo inicial do período.
		Irá desfazer todas as transferências de saída existentes neste produto.
	*/
	If !lForcaTran
		For nIndex := 1 To nTotal
			If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_PR"
				nQtdTrSaid += aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
			EndIf
			If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_ES" .And. ;
			   aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] < aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
				nQtdTrSaid -= aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
			EndIf
		Next nIndex
		If nQtdTrSaid > 0 .And. nSaldo + nQtdTrSaid >= 0
			Return
		EndIf
	EndIf

	For nIndex := 1 To nTotal
		//Se for transferência de estoque, irá desfazer.
		If aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA] > 0 .And. ;
		   (aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_ES" .Or. ;
		    (aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_PR" .And. lForcaTran))

			lTranfPR := aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_PR"

			//Remove a transferência de saída do registro atual.
			nQtdTran   := aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
			aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA] := 0

			//Adiciona array de controle de atualização da global do aBaixaPorOP
			aAdd(aIndBxAtu, nIndex)

			//Busca os documentos pais para desfazer as transferências.
			aDocsPais := getDocsPai(cFilAux, nPeriodo, cProduto, cIDOpc, Self:oDominio:oAglutina, aBaixaPorOP[nIndex][ABAIXA_POS_DOCPAI], nQtdTran, lTranfPR, lAglutina)

			nTotPais := Len(aDocsPais)
			For nIndPais := 1 To nTotPais

				nTotTransf += aDocsPais[nIndPais][2]
				nQtdTran   := aDocsPais[nIndPais][2]
				//Elimina o registro de transferência (SMA)
				//Chave = Produto + filial destino + filial origem + data + documento
				If lTranfPR
					lError    := .F.
					cChave    := oTransf:getFlag("TRF_DOCS" + CHR(13) + aDocsPais[nIndPais][1], @lError)
					cFilDest  := SubStr(cChave, Len(cProduto)+1, Self:tamanhoFilial())
				Else
					cFilDest := SubStr(aDocsPais[nIndPais][1], 9, Self:tamanhoFilial())

					cChave := cProduto
					cChave += cFilDest
					cChave += cFilAux
					cChave += DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo))
					cChave += aDocsPais[nIndPais][1]

					cChaveMat := aDocsPais[nIndPais][1]
				EndIf

				//Antes de excluir a transferência, recuperar a data de recebimento da transferência
				//na filial destino, para considerar a data correta ao desfazer a Rastreabilidade (HWC).
				lError := .F.
				oTransf:getRow(1, cChave, Nil, @aDadosTrf, lError, .F.)
				If !lError
					nPerDest := Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, StoD(aDadosTrf[TRANF_POS_DATA_RECEBIMENTO]), .F.)
					lError := .F.
					If !oTransf:delRow(1, cChave, @lError)
						::oDados:oLogs:log(STR0172 + AllTrim(cProduto) + ". " + STR0173 + cChave, "E")  //"Erro ao eliminar transferência do produto: " "Chave: "
					EndIf
					aSize(aDadosTrf, 0)
				Else
					nPerDest := nPeriodo
					::oDados:oLogs:log(STR0172 + AllTrim(cProduto) + ". " + STR0173 + cChave, "E")  //"Erro ao eliminar transferência do produto: " "Chave: "
				EndIf

				If lTranfPR
					cChaveMat := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPerDest)) + cFilDest + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
					oTransf:delFlag("TRF_DOCS" + CHR(13) + aDocsPais[nIndPais][1], @lError)
				Else
					lError  := .F.
					aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cChaveMat, @lError)
					If !lError
						nPos := aScan(aTransf, {|x| x == cChave})
						If nPos > 0
							aDel(aTransf, nPos)
							aSize(aTransf, Len(aTransf)-1)
							oTransf:setItemAList("TRANSF_ESTOQUE", cChaveMat, aTransf, @lError, .F., .F.)
						EndIf

						aSize(aTransf, 0)
					EndIf
				EndIf

				//Busca o registro que recebeu o saldo de transferência para desfazer a entrada.
				//Remove da MATRIZ a transferência de entrada. (HWB)
				Self:oDados:gravaCampo("MAT", 1, cChaveMat, {"MAT_QTRENT", "MAT_SALDO"}, {-nQtdTran, -nQtdTran}, .F., .T., /*08*/, .T.)

				If _lLogM1
					::oDados:oLogs:log("Desfez transferencia (saida). Produto: '" + RTrim(cFilAux + cProduto) + "'. Quantidade: " + cValToChar(nQtdTran), "M1")
				EndIf

				//Remove do RASTREIO a transferência de entrada. (HWC)
				aDadosChvs := buscaRastreio(cFilDest, cProduto, cIDOpc, nPerDest, Self:oDominio:oRastreio, @cList, .T.)

				nTotRastro := Len(aDadosChvs)

				For nIndRastro := 1 to nTotRastro
					cChave    := aDadosChvs[nIndRastro][1]
					aRastreio := aDadosChvs[nIndRastro][2]

					If !lTranfPR .Or. ;
					   (lTranfPR .And. aRastreio[nPosDocFil] == aDocsPais[nIndPais][1])
						
						If _lLogM1
							::oDados:oLogs:log("Desfez transferencia. Removeu entrada. cList+|+cChave: " + StrTran(RTrim(cList)+"|"+RTrim(cChave), CHR(13), "") + "Qtd antes: " + cValToChar(aRastreio[nPosTrfEnt]), "M1")
						EndIf

						nDesfez := aRastreio[nPosTrfEnt]
						If aRastreio[nPosTrfEnt] > 0
							If aRastreio[nPosTrfEnt] > nQtdTran
								aRastreio[nPosTrfEnt] -= nQtdTran
								nQtdTran := 0
							Else
								nQtdTran -= aRastreio[nPosTrfEnt]
								aRastreio[nPosTrfEnt] := 0
							EndIf
						EndIf

						nDesfez := nDesfez - aRastreio[nPosTrfEnt]

						If !Empty(aRastreio[nPosChvSub])
							//Possui transferência com substituição. Verifica necessidade de limpar informações de transferências disponíveis.
							cKey      := "KEY_" + RTrim(SubStr(aRastreio[nPosChvSub], 1, Self:tamanhoFilial() + snTamCod)) + "_" + cValToChar(aRastreio[nPosPeriod])
							aTranDisp := Self:oDados:oAlternativos:getItemAList("transferencias_alternativos", cKey)
							If !Empty(aTranDisp)
								nPos := aScan(aTranDisp, {|x| x[1] == aRastreio[nPosCompon]})
								If nPos > 0 .And. aTranDisp[nPos][2]:HasProperty(cFilAux)
									aTranDisp[nPos][2][cFilAux] -= nDesfez
									Self:oDados:oAlternativos:setItemAList("transferencias_alternativos", cKey, aTranDisp, .F., .T., .F.)
									If _lLogM1
										::oDados:oLogs:log("Desfez transferencia. Removeu transf. disponivel. cList+|+cChave: " + StrTran(RTrim(cList)+"|"+RTrim(cChave), CHR(13), "") + "Qtd: " + cValToChar(nDesfez), "M1")
									EndIf
								EndIf
								FwFreeArray(aTranDisp)
							EndIf
						EndIf

						If _lLogM1
							::oDados:oLogs:log("Desfez transferencia. Removeu entrada. cList+|+cChave: " + StrTran(RTrim(cList)+"|"+RTrim(cChave), CHR(13), "") + "Qtd apos: " + cValToChar(aRastreio[nPosTrfEnt]), "M1")
						EndIf
						oDadosRast:oDados:setItemAList(cList, cChave, aRastreio)
					EndIf

					aSize(aRastreio, 0)

					If nQtdTran == 0
						Exit
					EndIf
				Next nIndRastro

				aSize(aDadosChvs, 0)

				//Atualiza flag de recalcular o produto na filial que recebeu a transferência.
				cChaveProd := cFilDest + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
				Self:oDados:gravaPeriodosProd(cChaveProd, nPerDest)
				Self:oDados:decrementaTotalizador(cChaveProd)
			Next nIndPais

		EndIf
		aSize(aDocsPais, 0)
	Next nIndex

	nSaldo  += nTotTransf
	nQtrSai -= nTotTransf

	If nTotTransf > 0
		//Remove da MATRIZ a transferência de saída. (HWB)
		Self:oDados:gravaCampo("MAT", 1, cChaveOrig, "MAT_QTRSAI", -nTotTransf, .F., .T.)
	EndIf

	If Len(aIndBxAtu) > 0
		//Grava as informações de controle para as quebras de produção/compra
		//no arquivo de rastreabilidade.
		cChaveProd := cFilAux + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
		Self:oDominio:oRastreio:atualizaRastreio(cFilAux, cChaveProd, nPeriodo, @aBaixaPorOP, aIndBxAtu, cProduto)
	EndIf

Return

/*/{Protheus.doc} desfazEntradaTransferencias
Desfaz as transferências de entrada já criadas para novo cálculo do produto
@author    ricardo.prandi
@since     19/02/2020
@version   1
@param 01 cFilAux    , Character, Filial atual de processamento
@param 02 cProduto   , Character, Produto atual de processamento
@param 03 nPeriodo   , Numeric  , Período atual de processamento
@param 04 cIDOpc     , Character, ID de Opcional do registro atual
@param 05 cChaveOrig , Character, Chave da matriz do registro em processamento
@param 06 aDados     , Array    , Array com os dados da global de rastreabilidade
@param 07 cChvCheck  , Character, Chave do produto que iniciou o processo de desfazer o cálculo para avaliação de loop
@param 08 lEfetiva   , Logic    , indica se deverá efetivar as exclusões de transferência, ou se está apenas validando recursividade.
@param 09 cPrdLoop   , Character, string com os códigos de produtos concatenados. Utilizado para msg de erro em caso de recursividade.
@return Nil
/*/
METHOD desfazEntradaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aDados, cChvCheck, lEfetiva, cPrdLoop) CLASS MrpDominio_MultiEmpresa
	Local aChaves    := {}
	Local aDadosTran := {}
	Local aDadosChvs := {}
	Local aTransf    := {}
	Local aRastreio  := {}
	Local cChave     := ""
	Local cChaveMat  := ""
	Local cChaveRast := ""
	Local cChaveProd := ""
	Local cDocFilho  := ""
	Local cList      := ""
	Local lError     := .F.
	Local lPossuiPR  := .F.
	Local nPos       := 0
	Local nPosQtrEnt := Self:oDominio:oRastreio:getPosicao("TRANSFERENCIA_ENTRADA")
	Local nPosQtrSai := Self:oDominio:oRastreio:getPosicao("TRANSFERENCIA_SAIDA")
	Local nPosDocFil := Self:oDominio:oRastreio:getPosicao("DOCFILHO")
	Local nPosTipPai := Self:oDominio:oRastreio:getPosicao("TIPOPAI")
	Local nPosDocPai := Self:oDominio:oRastreio:getPosicao("DOCPAI")
	Local nPerOrigem := nPeriodo
	Local nIndex     := 0
	Local nIndRastro := 0
	Local nTotal     := 0
	Local nTotRastro := 0
	Local nQuant     := 0
	Local nDesfazRas := 0
	Local nTotDesfaz := 0
	Local oDadosRast := Self:oDominio:oRastreio:oDados_Rastreio
	Local oTransf    := Self:oDados:oTransferencia

	//Remover da HWB, na filial do registro recebido em aDados, a quantidade de transferência de entrada.
	If lEfetiva
		Self:oDados:gravaCampo("MAT", 1, cChaveOrig, {"MAT_QTRENT", "MAT_SALDO"}, {-aDados[nPosQtrEnt], -aDados[nPosQtrEnt]}, .F., .T., /*08*/, .T.)
	EndIf

	//Identificar nas transferências, todas as transferências de saída que compõem a entrada existente no aDados.
	If !Empty(aDados[nPosDocFil])
		cChave := oTransf:getFlag("TRF_DOCS" + CHR(13) + aDados[nPosDocFil], @lError)
		If !lError
			aAdd(aChaves, {cChave, .T.})
			lPossuiPR := .T.
		EndIf
	EndIf
	lError  := .F.
	aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cChaveOrig, @lError)
	If !lError
		nTotal := Len(aTransf)
		For nIndex := 1 To nTotal
			aAdd(aChaves, {aTransf[nIndex], .F.})
		Next nIndex

		aSize(aTransf, 0)
	EndIf

	nTotal := Len(aChaves)
	For nIndex := 1 To nTotal
		If oTransf:getRow(1, aChaves[nIndex][1], Nil, @aDadosTran, .F., .T.)
			nQuant := 0

			nPerOrigem := Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, StoD(aDadosTran[TRANF_POS_DATA]), .F.)

			If aDados[nPosQtrEnt] <= aDadosTran[TRANF_POS_QUANTIDADE]
				nQuant := aDados[nPosQtrEnt]
			Else
				nQuant := aDadosTran[TRANF_POS_QUANTIDADE]
			EndIf

			If nQuant <= 0
				Loop
			EndIf

			cDocFilho := getDocAgl(aDadosTran[TRANF_POS_FILIAL_ORIGEM], nPerOrigem, cProduto, cIDOpc, Self:oDominio:oAglutina, aDados[nPosDocFil], nQuant, lPossuiPR, lEfetiva)

			//Para cada transferência de saída:
			//   1: Eliminar a quantidade de transferência correspondente da tabela HWB.
			cChaveMat := aDadosTran[TRANF_POS_DATA] + aDadosTran[TRANF_POS_FILIAL_ORIGEM] + aDadosTran[TRANF_POS_PRODUTO] + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
			If lEfetiva
				Self:oDados:gravaCampo("MAT", 1, cChaveMat, {"MAT_QTRSAI", "MAT_SALDO"}, {-nQuant, nQuant}, .F., .T., /*08*/, .T.)
			EndIf

			//   2: Eliminar a transferência da tabela HWC.
			aDadosChvs := buscaRastreio(aDadosTran[TRANF_POS_FILIAL_ORIGEM], cProduto, cIDOpc, nPerOrigem, Self:oDominio:oRastreio, @cList, .F.)
			nTotRastro := Len(aDadosChvs)

			aSort(aDadosChvs, , , {|x,y| Iif( x[2][nPosTipPai] == "TRANF_PR" .And. lPossuiPR, "0", "1") +;
			                             Iif( x[2][nPosTipPai] == "TRANF_ES"                , "0", "1")  ;
			                            < ;
			                             Iif( y[2][nPosTipPai] == "TRANF_PR" .And. lPossuiPR, "0", "1") +;
			                             Iif( y[2][nPosTipPai] == "TRANF_ES"                , "0", "1") } )

			nDesfazRas := 0

			For nIndRastro := 1 to nTotRastro
				cChaveRast := aDadosChvs[nIndRastro][1]
				aRastreio  := aDadosChvs[nIndRastro][2]

				If (aRastreio[nPosTipPai] == "TRANF_PR" .And. ;
				    (Empty(cDocFilho)                     .Or.  ;
				     cDocFilho != aRastreio[nPosDocPai])) .Or. ;
				   (aRastreio[nPosTipPai] == "TRANF_ES" .And. ;
				    aRastreio[nPosDocPai] != cChaveOrig) .Or. ;
				   (aRastreio[nPosTipPai] != "TRANF_ES" .And. aRastreio[nPosTipPai] != "TRANF_PR")
					Loop
				EndIf

				If aRastreio[nPosQtrSai] <= (nQuant-nDesfazRas)
					nTotDesfaz            += aRastreio[nPosQtrSai]
					nDesfazRas            += aRastreio[nPosQtrSai]
					aRastreio[nPosQtrSai] := 0
				Else
					nTotDesfaz            += (nQuant-nDesfazRas)
					aRastreio[nPosQtrSai] -= (nQuant-nDesfazRas)
					nDesfazRas            += (nQuant-nDesfazRas)
				EndIf

				If lEfetiva
					oDadosRast:oDados:setItemAList(cList, cChaveRast, aRastreio)
				EndIf

				//Chama o método de desfazer o cálculo deste produto somente para avaliação
				//se existe recursividade nas estruturas. Não irá desfazer nada, somente verificar.
				Self:oDominio:oRastreio:desfazExplosoes(aDadosTran[TRANF_POS_FILIAL_ORIGEM], cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPerOrigem, cChvCheck, cPrdLoop)

				aSize(aRastreio, 0)

				If nTotDesfaz >= nQuant
					Exit
				EndIf

			Next nIndRastro
			aSize(aDadosChvs, 0)

			//   3: Excluir a tabela de transferência (SMA)
			lError := .F.
			If lEfetiva
				If aDadosTran[TRANF_POS_QUANTIDADE] <= nTotDesfaz
					If !oTransf:delRow(1, aChaves[nIndex][1], @lError)
						::oDados:oLogs:log(STR0172 + AllTrim(cProduto) + ". " + STR0173 + aChaves[nIndex], "E")  //"Erro ao eliminar transferência do produto: " "Chave: "
					EndIf

					If aChaves[nIndex][2]
						oTransf:delFlag("TRF_DOCS" + CHR(13) + aDados[nPosDocFil], @lError)
					Else
						lError  := .F.
						aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cChaveOrig, @lError)
						If !lError
							nPos := aScan(aTransf, {|x| x == aChaves[nIndex][1]})
							If nPos > 0
								aDel(aTransf, nPos)
								aSize(aTransf, Len(aTransf)-1)
								oTransf:setItemAList("TRANSF_ESTOQUE", cChaveOrig, aTransf, @lError, .F., .F.)
							EndIf

							aSize(aTransf, 0)
						EndIf
					EndIf

				Else
					aDadosTran[TRANF_POS_QUANTIDADE] -= nTotDesfaz
					If !oTransf:updRow(1, aChaves[nIndex][1], Nil, aDadosTran, .F., .T.)
						Self:oDados:oLogs:log(STR0170 + "'" + AllTrim(cProduto) + "'", "E") //"Erro na atualização dos dados de transferência - Produto: "
					EndIf
				EndIf

				//   4: Setar o produto para ser recalculado
				cChaveProd := aDadosTran[TRANF_POS_FILIAL_ORIGEM] + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
				Self:oDados:gravaPeriodosProd(cChaveProd, nPerOrigem)
				Self:oDados:decrementaTotalizador(cChaveProd)
			EndIf

			aSize(aDadosTran, 0)
		EndIf

		If nTotDesfaz >= aDados[nPosQtrEnt]
			Exit
		EndIf
	Next nIndex

	aSize(aChaves, 0)
Return

/*/{Protheus.doc} alternativosMultiEmpresa
Verifica a necessidade de utilizar produtos alternativos com saldo em outras filiais.

@author    lucas.franca
@since     13/04/2021
@version   P12
@param 01 cFilAux    , Character, Filial atual de processamento
@param 02 cProduto   , Character, Produto atual de processamento
@param 03 nPeriodo   , Numeric  , Período atual de processamento
@param 04 cIDOpc     , Character, ID de Opcional do registro atual
@param 05 aBaixaPorOP, Array    , Array de rastreio do registro que está sendo processado.
@param 07 nQtdNec    , Numeric  , Quantidade da necessidade
@param 08 lWait      , Logic    , Retorna por referencia indicando se existe na Matriz de Calculo, mas nao foi calculado. Interrompe o consumo.
@param 09 aMinMaxAlt , Array    , Array com o nMin e nMax de sequência do alternativo
@return nSubstitui, Numeric, Quantidade do produto original que foi substituída.
/*/
METHOD alternativosMultiEmpresa(cFilAux, cProduto, nPeriodo, cIDOpc, aBaixaPorOP, nQtdNec, lWait, aMinMaxAlt) CLASS MrpDominio_MultiEmpresa
	Local aAuxAlt    := {}
	Local aBaixa     := {}
	Local cChaveProd := cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
	Local nSaldo     := 0
	Local nSubstitui := 0
	Local nTotAlt    := 0
	Local nIndAlt    := 0

	aAdd(aBaixa, aClone(aBaixaPorOP))

	nSaldo := Self:oDominio:oAlternativo:consumirAlternativos(cFilAux, cProduto, -nQtdNec, nPeriodo, "", @lWait, cIDOpc, nQtdNec, aBaixa, aMinMaxAlt, .T.)

	If !lWait
		nSubstitui := nQtdNec - Abs(nSaldo)
	EndIf

	If nSubstitui <> 0
		Self:oDominio:oRastreio:atualizaSubstituicao(cFilAux, cChaveProd, nPeriodo, @aBaixa, .F., .T., nSubstitui + aBaixa[1][ABAIXA_POS_QTD_SUBSTITUICAO], .T.)

		nTotAlt     := Len(Self:oDominio:oAlternativo:aPeriodos_Alternativos)
		For nIndAlt := 1 to nTotAlt
			aAuxAlt := Self:oDominio:oAlternativo:aPeriodos_Alternativos[nIndAlt]

			Self:oDados:gravaPeriodosProd(cFilAux + aAuxAlt[1], aAuxAlt[2])
		Next
		aSize(Self:oDominio:oAlternativo:aPeriodos_Alternativos, 0)
		aSize(aAuxAlt, 0)
		aBaixaPorOP := aClone(aBaixa[1])
	EndIf

	//Limpa o array com os dados de transferências de alternativos realizadas
	//após a utilização para gravar os dados de substituição no método atualizaSubstituicao
	If !Empty(Self:oDominio:oAlternativo:aSubsTranf)
		aSize(Self:oDominio:oAlternativo:aSubsTranf, 0)
	EndIf

	aSize(aBaixa, 0)

Return nSubstitui

/*/{Protheus.doc} getDocsPai
Busca os documentos pais que devem ter as transferências de estoque desfeitas.

@type  Static Function
@author ricardo.prandi
@since 23/02/2021
@version P12
@param 01 cFilAux  , Character, Código da filial
@param 02 nPeriodo , Numeric  , Número do período
@param 03 cProduto , Character, Código do produto
@param 04 cIDOpc   , Character, ID de opcional
@param 05 oAglutina, Object   , Referência da classe de aglutinação
@param 06 cDocPai  , Character, Documento pai do registro
@param 07 nQtdTran , Numeric  , Quantidade de transferência
@param 08 lTranfPR , Logic    , Indica que o processo é para desfazer transferência de produção
@param 09 lAglutina, Logic    , Parâmetro de aglutinação do produto
@return aDocsPais, Array, Array com os documentos pais que devem ter as transferências desfeitas
/*/
Static Function getDocsPai(cFilAux, nPeriodo, cProduto, cIDOpc, oAglutina, cDocPai, nQtdTran, lTranfPR, lAglutina)
	Local aDocsPais  := {}
	Local aDadosAgl  := {}
	Local cChaveAgl  := ""
	Local lError     := .F.
	Local nIndex     := 0
	Local nTotal     := 0
	Local nPosPais   := oAglutina:getPosicao("ADOC_PAI")
	Local nPosIdTran := oAglutina:getPosicao("ID_TRANSF")
	Local nPosQtran  := oAglutina:getPosicao("TRANSF_SAIDA")

	If lTranfPR .And. lAglutina
		//Transferência de produção com aglutinação. Verifica os documentos na HWG.
		cChaveAgl := cFilAux + cValToChar(nPeriodo) + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
		oAglutina:oAglutinacao:getFlag("6" + chr(13) + cChaveAgl, @lError)
		If !lError
			aDadosAgl := oAglutina:oAglutinacao:getItemAList("6", cChaveAgl)
			nTotal := Len(aDadosAgl[nPosPais])
			For nIndex := 1 To nTotal
				aAdd(aDocsPais, {aDadosAgl[nPosPais][nIndex][nPosIdTran], aDadosAgl[nPosPais][nIndex][nPosQtran]})
			Next nIndex

			oAglutina:oAglutinacao:delItemAList("6", cChaveAgl, @lError)
			oAglutina:oAglutinacao:delFlag("6" + chr(13) + cChaveAgl, @lError)

			aSize(aDadosAgl, 0)
		Else
			aDocsPais := {{cDocPai, nQtdTran}}
		EndIf
	Else
		aDocsPais := {{cDocPai, nQtdTran}}
	EndIf
Return aDocsPais

/*/{Protheus.doc} getDocAgl
Busca o número do documento aglutinador quando o produto possui aglutinação

@type  Static Function
@author ricardo.prandi
@since 23/02/2021
@version P12
@param 01 cFilOri  , Character, Código da filial da origem da transferência
@param 02 nPeriodo , Numeric  , Número do período
@param 03 cProduto , Character, Código do produto
@param 04 cIDOpc   , Character, ID de opcional
@param 05 oAglutina, Object   , Referência da classe de aglutinação
@param 06 cDocFilho, Character, Documento filho do registro atual
@param 07 nQuant   , Numeric  , Quantidade de transferência
@param 08 lPossuiPR, Logic    , Indica que existe registro de transferência de produção (TRANF_PR)
@param 09 lEfetiva   , Logic    , indica se deverá efetivar as exclusões de transferência, ou se está apenas validando recursividade.
@return cDocAgl    , Character, Documento aglutinador se existir, caso contrário mesmo conteúdo de cDocFilho
/*/
Static Function getDocAgl(cFilOri, nPeriodo, cProduto, cIDOpc, oAglutina, cDocFilho, nQuant, lPossuiPR, lEfetiva)
	Local aDadosAgl  := {}
	Local cChaveAgl  := ""
	Local cDocAgl    := cDocFilho
	Local lError     := .F.
	Local nPos       := 0
	Local nPosDocAgl := oAglutina:getPosicao("DOCUMENTO")
	Local nPosIdTran := oAglutina:getPosicao("ID_TRANSF")
	Local nPosPais   := oAglutina:getPosicao("ADOC_PAI")
	Local nPosTrfSai := oAglutina:getPosicao("TRANSF_SAIDA")

	If lPossuiPR .And. oAglutina:avaliaAglutinacao(cFilOri, cProduto) .And. !Empty(cDocFilho)
		cChaveAgl := cFilOri + cValToChar(nPeriodo) + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
		oAglutina:oAglutinacao:getFlag("6" + chr(13) + cChaveAgl, @lError)
		If !lError
			aDadosAgl := oAglutina:oAglutinacao:getItemAList("6", cChaveAgl)
			nPos := aScan(aDadosAgl[nPosPais], {|x| x[nPosIdTran] == cDocFilho })

			If nPos > 0
				cDocAgl := aDadosAgl[nPosDocAgl]
				If lEfetiva
					aDadosAgl[nPosPais][nPos][nPosTrfSai] -= nQuant
					If aDadosAgl[nPosPais][nPos][nPosTrfSai] <= 0
						aDel(aDadosAgl[nPosPais], nPos)
						aSize(aDadosAgl[nPosPais], Len(aDadosAgl[nPosPais])-1)
					EndIf
					If Len(aDadosAgl[nPosPais]) == 0
						oAglutina:oAglutinacao:delItemAList("6", cChaveAgl, @lError)
						oAglutina:oAglutinacao:delFlag("6" + chr(13) + cChaveAgl, @lError)
					Else
						oAglutina:oAglutinacao:setItemAList("6", cChaveAgl, aDadosAgl)
					EndIf
				EndIf
			EndIf

			aSize(aDadosAgl, 0)
		EndIf
	EndIf
Return cDocAgl

/*/{Protheus.doc} buscaRastreio
Busca os dados de rastreio para desfazer as transferências.

@type  Static Function
@author ricardo.prandi
@since 23/02/2021
@version P12
@param 01 cFilDest , Character, Código da filial
@param 02 cProduto , Character, Código do produto
@param 03 cIDOpc   , Character, ID de opcional
@param 04 nPeriodo , Numeric  , Número do período
@param 05 oRastreio, Object   , Referência da classe de domínio da rastreabilidade
@param 06 cList    , Character, Retorna por referência o código da lista
@param 07 lOrdena  , Logic    , Indica se deve ordenar o array de retorno
@return aDadosChvs, Array, Array com as informações de rastreio
/*/
Static Function buscaRastreio(cFilDest, cProduto, cIDOpc, nPeriodo, oRastreio, cList, lOrdena)
	Local aChaves    := {}
	Local aDados     := {}
	Local aDadosChvs := {}
	Local cChave     := ""
	Local lError     := .F.
	Local nContador  := 0
	Local nIndex     := 0
	Local nTotal     := 0
	Local oDadosRast := oRastreio:oDados_Rastreio

	cList   := cFilDest + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + chr(13) + cValToChar(nPeriodo)
	aChaves := oDadosRast:getDocsComponente(cList)
	nTotal  := Len(aChaves)

	//Recupera registros de rastreabilidade dos chaves
	For nIndex := 1 to nTotal
		lError    := .F.
		aDados    := {}
		cChave    := aChaves[nIndex]
		aDados    := oDadosRast:oDados:getItemAList(cList, cChave, @lError)
		If !lError
			nContador++
            aAdd(aDadosChvs, {cChave, aDados, StrZero(nContador, 5)})
		EndIf
	Next nIndex
	aSize(aChaves, 0)

	nTotal := Len(aDadosChvs)
	If nTotal > 0 .And. lOrdena
		aDadosChvs := oRastreio:ordenaRastreio(aDadosChvs, .T.)
	EndIf

Return aDadosChvs
