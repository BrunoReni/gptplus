#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

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
#DEFINE ABAIXA_POS_DOC_AGLUTINADOR       16
#DEFINE ABAIXA_SIZE                      16

#DEFINE AREVISOES_POS_REVISAO             1
#DEFINE AREVISOES_POS_ROTEIRO             2
#DEFINE AREVISOES_POS_LOCAL               3
#DEFINE AREVISOES_POS_QTDE_TOTAL          4
#DEFINE AREVISOES_POS_aBaixaPorOP         5
#DEFINE AREVISOES_POS_VERSAOPROD          6

Static soDominio     := Nil             //Instancia da camada de dominio
Static soAlternativo := Nil
Static slRecria      := .T.
Static scTextPPed    := STR0144
Static slLog19       := Nil

/*/{Protheus.doc} MrpDominio
Regras de Negocio - Processamento Calculo do MRP
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDominio FROM LongClassName

	//Declaracao de propriedades da classe
	DATA oAlternativo       AS OBJECT   //Classe para regras de Alternativos
	DATA oAglutina          AS OBJECT   //Classe para regras de Aglutina��o
	DATA oDados             AS OBJECT   //Instancia da camada de dados
	DATA oFantasma          AS OBJECT   //Classe para processamento de produto fantasma
	DATA oHorizonteFirme    AS OBJECT   //Classe para processamento de horizonte firme
	DATA oLeadTime          AS OBJECT   //Classe para manipulacao de Lead Time
	DATA oLogs              AS OBJECT   //Classe para manipulacao de logs
	DATA oOpcionais         AS OBJECT   //Classe para manipulacao de opcionais
	DATA oParametros        AS OBJECT   //Objeto JSON com todos os parametros do MRP - Consulte MRPAplicacao():parametrosDefault()
	DATA oPeriodos          AS OBJECT   //Classe para regras de periodos
	DATA oRastreio          AS OBJECT   //Classe para regras de rastreabilidade
	DATA oVersaoDaProducao  AS OBJECT   //Classe para regras de vers�o da Produ��o
	DATA oSubProduto        AS OBJECT   //Classe para regras de SubProdutos
	DATA oEventos           AS OBJECT   //Classe para regras de Log de Eventos
	DATA oRastreioEntradas  AS OBJECT   //Classe para regras de Rastreio das Entradas
	DATA oSeletivos         AS OBJECT   //Classe para regras de Seletivos Multivalorados
	DATA oMOD               AS OBJECT   //Classe para regras de MOD - Mao de Obra de Produto
	DATA oMultiEmp          AS OBJECT   //Classe para regras de Multi-empresas

	METHOD new(oParametros, oLogs, lRecursiva, oPeriodos) CONSTRUCTOR
	METHOD aguardaProcesso(lFimPrd, cNivelAtu, cNivelAnt, nInexistente, nInxstLoop, nReinicios, nDistrib, nIgnorados) //Aguarda processos multi-thread
	METHOD agrupaRevisoes(cProduto, nPeriodo, aBaixaPorOP)                 //Agrupa demandas por revis�o
	METHOD ajustarNecessidadeExplosao(cFilAux, cComponente, nNecPai, nNecComp, lQtdFixa, nFPotencia, nFPotEstru, nFatPerda, nQtdBase) //Aplica ajustes na necessidade para explosao da estrutura
	METHOD ajustarArrayQuebrasQtd(aQuant)              //Converte um array de quantidades para a matriz QTD,DOCUMENTO
	METHOD aplicarPotencia(cFilAux, cProduto, nFPotencia, nNecComp, nFPotEstru) //Aplicar fator de potencia
	METHOD aplicarPerda(nNecComp, nFatPerda)           //Aplica fator de perda
	METHOD arredondarExplosao(cFilAux, cCompon, nNecess)        //Faz o arredondamento de acordo com par�metros do produto.
	METHOD avaliaAglutinaProduto(cFilAux, cProduto, dData, nPerLead, nAgluPRD, cIdOpc)
	METHOD checarFimLoop()
	METHOD calcularLotes(cProduto, nNecess, nQtdLotes, nPeriodo, cFilAux) //Calcula a quebra de lotes do produto.
	METHOD calcularNivel()                             //Calcula o nivel da estrutura
	METHOD destruir()                                  //Destroi a classe
	METHOD descontouLoteVencido(cFilAux, cProduto, cIdOpc, dData)
	METHOD explodeAgrupadoPorRevisao(cFilAux, cChaveProd, cProduto, nPerLead, nPeriodo, nPerMaximo, cIDOpcPai, aBaixaPorOP, dLTReal, cNivelAtu) //Explode a estrutura do produto agrupado por revis�o do produto
	METHOD explodirEstrutura(cFilAux, cProduto, nNecPai, nPerLead, nPeriodo, cFantasma, cIDOpcPai, aBaixaPorOP, cRevisao, cRoteiro, cLocal, cList, oRastrPais, cVersao, lExplodiu, dLTReal, cCodPrPais, cNivelAtu) //Explode a estrutura do produto
	METHOD interrompeCalculo(cMsg)
	METHOD loopNiveis()                                //Loop niveis + produtos para calcular
	METHOD periodoMaxComponentes(cFilAux, cProduto, nPeriodo)   //Atualiza os periodos maximos dos componentes do produto
	METHOD periodoAnterior(cChaveProd, nPeriodo, aPRDPeriodos, lErrorMAT)  //Identifica o periodo anterior do produto existente na matriz
	METHOD periodoPosterior(cChaveProd, nPeriodo, aPRDPeriodos, lErrorMAT) //Identifica o periodo anterior do produto existente na matriz
	METHOD politicaDeEstoque(cFilAux, cChaveProd, nSaldoAtu, lAtual, nPeriodo, lReinicia, aBaixaPorOP, lAlternativo, lProcAGL, cProduto, nQtrEnt, cNivel, cIDOpc, nQtdTran, lProcAll, lWait, lErrorALT, aMinMaxAlt, nSomaSubTr, lSemTran) //Aplica regras da politica de estoque do produto
	METHOD registraProcessados()                       //Atualiza os status dos registros que foram processados
	METHOD revisaoProduto(cProduto, cRoteiro)          //Identifica a revis�o e roteiro atual do produto
	METHOD reduzPMPSaldo(nSaldo, aBaixaPorOP, nQtdEnt, nQtdSai)          //Desconta qtd. de PMP do saldo.
	METHOD saldoInicial(cFilAux, cProduto, nPeriodo, lSomaNec, cIDOpc)  //Identifica o saldo anterior ao periodo
	METHOD saldoFinal(cFilAux, cProduto, nPeriodo, lSomaNec)    //Identifica o saldo final do produto no periodo atual
	METHOD saldoPosterior(cFilAux, cProduto, nPeriodo, lSldIniAtual, lSldProduto, aPRDPeriodos, cIDOpc)          //Identifica o saldo inicial do produto no periodo posterior ao periodo atual
	METHOD validaLotesVencidos(cFilAux, cProduto, nPeriodo, nSldInicial, aRetLotes, cChaveProd, cIDOpc) //Desconta os lotes vencidos do saldo inicial do produto
	METHOD getUsoPotencia(cFilAux, cCompon)
	METHOD salvaPMPPeriodo(cChave, nPeriodo, nQtdPMP)
	METHOD getPMPPeriodo(cChave, nPeriodo)
ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oParametros, objeto, objeto JSON com todos os parametros do MRP - Consulte MRPAplicacao():parametrosDefault()
@param 02 - oLogs      , objeto, instancia da classe de logs
@param 03 - lRecursiva , numero, indica se refere-se a execucao recursiva
@param 04 - oPeriodos  , objeto, inst�ncia da classe dos periodos de processamento
/*/
METHOD new(oParametros, oLogs, lRecursiva, oPeriodos) CLASS MrpDominio
	Local nTentativas := 0
	Local oStatus     := Nil

	Default lRecursiva := .F.

	::oPeriodos   := oPeriodos

	//Instancia propriedade da classe de parametros
	::oParametros := oParametros

	//Instancia propriedade da classe de Logs
	::oLogs       := oLogs

	If lRecursiva
		//Instancia propriedade da camada de repositorio de dados
		::oDados := MrpDados():New(::oParametros, ::oPeriodos, ::oLogs, lRecursiva)
	Else
		//Instancia objeto da camada de repositorio de dados
		::oDados := MrpDados():New(::oParametros, , ::oLogs, lRecursiva .AND. ::oParametros["nOpcCarga"] == 1)
	EndIf


	//Instancia propriedade da classe de Periodos
	::oPeriodos   := MrpDominio_Periodos():New(Self)

	//Verifica se � uma thread
	If !lRecursiva
		oStatus := MrpDados_Status():New(::oParametros["ticket"])
		If ::oParametros["nThreads"] > 0 .And. ::oParametros["nOpcCarga"] == 1
			PCPIPCStart(::oParametros["cSemaforoThreads"], ::oParametros["nThreads"], 0, ::oParametros["cEmpAnt"], ::oParametros["cFilAnt"], "PCPA712_MRP_" + oParametros["ticket"]) //Inicializa as Threads
		EndIf

		//Faz a carga do Calend�rio MRP antes de montar os Per�odos
		If ::oParametros["nOpcCarga"] == 2
			oStatus:preparaAmbiente(::oDados)
			While ::oDados:oCalendario:getFlag("termino_carga", .T.) <> "S" .And. oStatus:getStatus("status") != "4"
				ntentativas++
				Sleep(100)
				If Mod(ntentativas, 100) == 0
					::oDados:oLogs:log(STR0145 + Time(), "C") //"Aguardando carga calendario "
				EndIf
			EndDo

			If oStatus:getStatus("status") != "4"
				::oMultiEmp := MrpDominio_MultiEmpresa():New(Self)

				::oPeriodos:criarArrayPeriodos(::oParametros["dDataIni"], ::oParametros["nTipoPeriodos"], ::oParametros["nPeriodos"])  //Monta Array de Periodos
			EndIf
		Else
			//Grava variaveis globais com os dados para popular as Statics das Threads
			PutGlbVars("PCP_aParam" + ::oParametros["ticket"], {::oParametros:toJson(), ::oPeriodos, {}, "1"})

			::oDados:oLogs:log(STR0107 + Time(), "C") //"pre-carga;inicio;"
			::oDados:oCargaMemoria:preCarga()
			oStatus:setStatus("cargaInicialConcluida", "2")
			::oDados:oLogs:log(STR0108 + Time(), "C") //"pre-carga;fim;"
		EndIf

		//Seta o objeto de controle dos per�odos na camada de dados
		::oDados:setOPeriodos(::oPeriodos)
	EndIf

	//Seta instancia do objeto
	::oDados:setoDominio(Self)

	//Instancia propriedade da classe de manipulacao de opcionais
	::oOpcionais := MrpDominio_Opcional():New(::oDados)

	//Instancia propriedade da classe de processamento de produtos fantasmas
	::oFantasma  := MrpDominio_Fantasma():New(Self)

	//Instancia classe para manipulacao de lead time
	::oLeadTime  := MrpDominio_LeadTime():New(Self)

	//Instancia propriedade da classe de processamento de Horizonte Firme
	::oHorizonteFirme := MrpDominio_HorizonteFirme():New(Self)

	//Instancia propriedade da classe de processamento de Rastreabilidade
	::oRastreio := MrpDominio_Rastreio():New(::oDados)

	//Instancia propriedade da classe de processamento de Vers�o da Produ��o
	::oVersaoDaProducao := MrpDominio_VersaoDaProducao():New(Self)

	//Instancia propriedade da classe de processamento de SubProdutos
	::oSubProduto := MrpDominio_Subproduto():New(Self)

	//Instancia propriedade da classe de processamento de Log de Eventos
	::oEventos := MrpDominio_Eventos():New(Self)

	//Instancia propriedade da classe de processamento de Seletivos Multivalorados
	::oSeletivos := MrpDominio_Seletivos():New(Self)

	//Instancia propriedade da classe de processamento de alternativos
	::oAlternativo := MrpDominio_Alternativo():New(Self)

	//Instancia propriedade da classe de processamento de alternativos
	::oAglutina := MrpDominio_Aglutina():New(::oDados)

	//Instancia propriedade da classe de processamento de Rastreio de Entradas
	::oRastreioEntradas := MrpDominio_RastreioEntradas():New(Self)

	//Instancia propriedade da classe de processamento de MOD - Produto Mao de Obra
	::oMOD := MrpDominio_MOD():New()

	//Instancia propriedade da classe de processamento de Multi-empresas
	If ::oMultiEmp == Nil
		::oMultiEmp := MrpDominio_MultiEmpresa():New(Self)
	EndIf

	If !lRecursiva
		If ::oParametros["nOpcCarga"] == 2
			If oStatus:getStatus("status") != "4"
				//Carrega dados em memoria
				::oDados:oLogs:log(STR0051 + Time(), "C") //"carga_inicial;inicio;"
				::oDados:oCargaMemoria:carregaRegistros()
				::oDados:oLogs:log(STR0052 + Time(), "C") //"carga_inicial;fim;"
			EndIf
		Else
			If oStatus:getStatus("status") == "4";                 //Cancelado
				.AND. oStatus:getStatus("finalizado") $ '|true|1|' //Execu��o do C�lculo Conclu�da ou N�o Iniciada
				If oStatus:getStatus("memoria") $ "1|2" //Pendente / Em Mem�ria
					oLogs:log(STR0035, "R")             //"Processamento cancelado, memoria descarregada!"
					oStatus:setStatus("memoria", "4")   //Descarregado
					oStatus:persistir(Self:oDados)
					Self:destruir()
				EndIf
			EndIf
		EndIf
	EndIf

Return Self
/*/{Protheus.doc} loopNiveis
Loop niveis + produtos para calculo das necessidades do MRP
@author    brunno.costa
@since     25/04/2019
@version 1.0
/*/
METHOD loopNiveis() CLASS MrpDominio

	Local aAreaPRD
	Local aCachePRD      := {}
	Local aCposPRD       := {"PRD_COD","PRD_IDOPC","PRD_PPED","PRD_ESTSEG","PRD_NIVEST","PRD_SLDDIS"}
	Local aRetAux
	Local cChaveProd
	Local cFilProd        := ""
	Local cFilAux         := ""
	Local cIDOpc          := ""
	Local cProduto        := ""
	Local cNivelAnt
	Local cNivelAtu
	Local lErrorPRD       := .F.
	Local lDelegar        := .T.
	Local lCacheLocal     := .F.
	Local lLogPerc        := .T. //::oLogs:logValido("%") - For�ado para exibir em tela.
	Local lPercent        := lLogPerc
	Local lUsaME          := Self:oMultiEmp:utilizaMultiEmpresa()
	Local nInexistente    := 0
	Local nInexistLoop    := 0
	Local nEstSeg         := 0
	Local nIndCache       := 0
	Local nLiveLock       := 0
	Local nPontoPed       := 0
	Local nProdutos       := ::oDados:oProdutos:getRowsNum()
	Local nDistribuicoes  := 0 //Quantidade de chamadas ao calculo da necessidade do produto
	Local nIgnorados      := 0 //Quantidade de vezes que avalia produto sem execucao
	Local nMaxaCache
	Local nReinicios      := 0 //Reinicios loopNiveis
	Local nSecIni         := Seconds()
	Local nSecUlt         := nSecIni
	Local nSecAtu
	Local nSldDisp        := 0
	Local nThreads        := ::oParametros["nThreads"]
	Local nPosFilial      := 0
	Local oDados          := ::oDados
	Local oProdutos       := oDados:oProdutos
	Local oLiveLock       := oDados:oLiveLock
	Local oStatus         := MrpDados_Status():New(::oParametros["ticket"])
	Local oExisteMAT      := JsonObject():New()

	::oLogs:log(STR0001 + " " + Iif(::oParametros["lPorNivel"], STR0002, STR0003) + " - " + Time(), "L") //"Inicio do loop master de delegacao dos processamentos" + "por nivel" + "multi-nivel"

	//Seta variaveis de controle globais
	oProdutos:setflag("cNivMin"                   , "01", .F., .F.) //Menor nivel ja processado
	oProdutos:setflag("nThreadsOk"                , 0   , .F., .T.) //Processos finalizados nas Threads
	oProdutos:setflag("nProdCalcT"                , 0   , .F., .T.) //Total de produtos calculados
	oProdutos:setflag("nProcessNv"                , 0   , .F., .T.) //Produtos processados por nivel
	oProdutos:setflag("nProdutosT"                , nProdutos , .F., .F.) //Total de produtos
	oProdutos:setflag("lPercentX"                 , .F. , .F., .F.) //Controle de impressao do percentual multi-thread
	oLiveLock:setflag("nJobLiveLock"              , 0   , .F., .F.) //Seta variavel de controle de JOB's em LiveLock
	oProdutos:setflag("calculationPercentage"     , 0   , .F., .F.) //Indica o % de conclusao do calculo
	oProdutos:setflag("memoryLoadPercentage"      , 0   , .F., .F.) //Indica o % de conclus�o na etapa de carga mem�ria
	oStatus:setStatus("documentEventLogPercentage", 0   , .F., .F.) //Indica o % de conclusao da an�lise de documentos do Log de Eventos
	oStatus:setStatus("documentEventLogStatus"    , "1" , .F., .F.) //Indica o status da an�lise de documentos do Log de Eventos

	If ::oLogs:logValido("CS")
		::oLogs:log(STR0069, "CS") //"Periodo/Produto -> Saldo  := Sld.Inicial + Ent.Prevista - Saida Prev. - Saida Estrutura"
	EndIf

	If oStatus:getStatus("status") == "4"
		::oLogs:log(STR0065 + Time(), "L") //"Fim do loop master de delegacao dos processamentos - "
		Return
	EndIf

	If lUsaME
		aAdd(aCposPRD, "PRD_FILIAL")
		nPosFilial := Len(aCposPRD)
	EndIf

	//Percorre todos os Produtos - Indice: Nivel + Produto
	lErrorPRD := .T.

	While .T.
		If lErrorPRD	//EOF ou BOF
			lErrorPRD  := .F.
			cNivelAnt  := oProdutos:getflag("cNivMin"              , .F., .F.)
			cChaveProd := oProdutos:getflag("cPriNivel" + cNivelAnt, .F., .F.)
			cNivelAtu  := cNivelAnt

			If lCacheLocal
				nIndCache := 1
				aRetAux   := aCachePRD[nIndCache]

			ElseIf cChaveProd == Nil
				aRetAux   := oDados:retornaCampo("PRD", 2, , aCposPRD, @lErrorPRD, .F., .T. /*lPrimeiro*/, , , , .T. /*lVarios*/)
				If !lErrorPRD
					aAdd(aCachePRD, aRetAux)
				EndIf
				If lErrorPRD
					Exit
				EndIf
			Else
				aRetAux   := oDados:retornaCampo("PRD", 2, Iif(cNivelAnt == "00", "01", cNivelAnt) + cChaveProd, aCposPRD, @lErrorPRD, , , , , , .T. /*lVarios*/)
				If !lErrorPRD
					aAdd(aCachePRD, aRetAux)
				EndIf
			EndIf
			cProduto  := aRetAux[1]
			cIDOpc    := aRetAux[2]
			nPontoPed := aRetAux[3]
			nEstSeg   := aRetAux[4]
			nSldDisp  := aRetAux[6]
			If lUsaME
				cFilAux := aRetAux[nPosFilial]
			EndIf
			cFilProd := cFilAux + cProduto
		EndIf

		If !::oParametros['lEstoqueSeguranca'] .And. nEstSeg > 0
			oDados:gravaCampo("PRD", 2, , {"PRD_SLDDIS", "PRD_ESTSEG"}, {nEstSeg, -nEstSeg}, .T., .T.,, .T. /*lVarios*/)
			nSldDisp   += nEstSeg
			aRetAux[4] := 0
			nEstSeg    := 0
		EndIf

		//Verifica se o produto deve ser calculado
		lDelegar := .F.
		If Self:oSeletivos:consideraProduto(cFilAux, cProduto, oDados)
			If !oExisteMAT[cFilAux + cProduto + cIDOpc] .AND. !oDados:existeMatriz(cFilAux, cProduto, , , cIDOpc)
				oExisteMAT[cFilAux + cProduto + cIDOpc] := .F.
				If (nPontoPed > 0 .Or. nEstSeg > 0 .Or. nSldDisp <> 0);
				   .And. !Self:oMOD:produtoMOD(cFilAux, cProduto, oDados);
				   .And. oDados:possuiPendencia(cFilProd, .F., cIDOpc)
					lDelegar   := .T.
				EndIf
			Else
				oExisteMAT[cFilProd + cIDOpc] := .T.
				lDelegar                      := !Self:oMOD:produtoMOD(cFilAux, cProduto, oDados);
				                                 .AND. oDados:possuiPendencia(cFilProd, .F., cIDOpc)
			EndIf
		Else
			If nEstSeg > 0
				oDados:gravaCampo("PRD", 2, , {"PRD_SLDDIS", "PRD_ESTSEG"}, {nEstSeg, -nEstSeg}, .T., .T.,, .T. /*lVarios*/)
				aRetAux[4] := 0
			EndIf
		EndIf

		If lDelegar
			If lPercent
				If oProdutos:getflag("lPercentX")
					lPercent := .F. //Nao delega novamente, pois ha operacao em andamento
				Else
					oProdutos:setflag("lPercentX", .T., .F., .F.)
				EndIf
			EndIf

			nDistribuicoes++
			If nThreads > 1
				nLiveLock := oLiveLock:getResult(cFilAux + cProduto)
				If oStatus:getStatus("status") != "4"
					If (nLiveLock == Nil .OR. nLiveLock == 0)
						PCPIPCGO(::oParametros["cSemaforoThreads"], .F., "MRPCalculo", cFilAux, Nil, cProduto, cIDOpc, Nil, lPercent, nInexistLoop, , ::oParametros["ticket"])  //Delega calculo para Threa
					Else
						//Delega thread para execucoes exclusivas de produtos em live-lock em single-thread
						If oLiveLock:getflag("nJobLiveLock") == 0
							oLiveLock:setFlag("nJobLiveLock", 1)
							PCPIPCGO(::oParametros["cSemaforoThreads"], .F., "PCPCalcLL", ::oParametros["ticket"])
						EndIf
					EndIf
				EndIf
			Else
				aAreaPRD   := oDados:retornaArea("PRD")
				MRPCalculo(cFilAux, Self, cProduto, cIDOpc, Nil, lPercent, nInexistLoop, , ::oParametros["ticket"])  //Realiza o calculo single Thread
				oDados:setaArea(aAreaPRD)
			EndIf

			If lPercent
				lPercent := .F.
				nSecUlt  := Seconds()
			EndIf

		Else
			nInexistente++
			nInexistLoop++
			nIgnorados++

			If Self:oLogs:logValido("29")
				::oLogs:log(STR0083 + cProduto + Iif(!Empty(cIDOpc), cIDOpc, ""), "29") //"Produto sem matriz ou sem pendencia: "
			EndIf
		EndIf

		//Identifica o proximo produto e Nivel
		cNivelAnt := cNivelAtu

		If lCacheLocal
			nIndCache++
			If nIndCache <= nMaxaCache
				aRetAux := aCachePRD[nIndCache]
			Else
				lErrorPRD := .T.
			EndIf
		Else
			aRetAux   := oDados:retornaCampo("PRD", 2, Nil, aCposPRD, @lErrorPRD, , , .T. /*lProximo*/, , , .T. /*lVarios*/)
			If !lErrorPRD
				aAdd(aCachePRD, aRetAux)
			EndIf
		EndIf

		If !lErrorPRD //!EOF
			cProduto  := aRetAux[1]
			cIDOpc    := aRetAux[2]
			nPontoPed := aRetAux[3]
			nEstSeg   := aRetAux[4]
			cNivelAtu := aRetAux[5]
			nSldDisp  := aRetAux[6]
			If lUsaME
				cFilAux := aRetAux[nPosFilial]
			EndIf
			cFilProd  := cFilAux + cProduto
		EndIf

		//Seta impressao do percentual de cobertura do calculo a cada x segundos
		If lLogPerc
			nSecAtu  := Seconds()
			If (nSecAtu - nSecUlt) > 10
				lPercent := .T.
			EndIf
		EndIf

		//Checa cancelamento a cada X produtos
		If Mod((nDistribuicoes + nInexistLoop), ::oParametros["nX_Para_Cancel"]) == 0 .AND.;
		   oStatus:getStatus("status") == "4"
			Exit
		EndIf

		If (lErrorPRD .Or. (cNivelAtu  != cNivelAnt))  //EOF ou Troca de Nivel
			If lErrorPRD
				lCacheLocal := .T.
				nMaxaCache  := Len(aCachePRD)
			EndIf

			lExit := oStatus:getStatus("status") == "4" .OR.; //Cancelado
			::aguardaProcesso(lErrorPRD, @cNivelAtu, @cNivelAnt, @nInexistente, @nInexistLoop, @nReinicios, @nDistribuicoes, @nIgnorados)

			If lExit
				Exit //Sai do WHILE
			EndIf
		EndIf
	EndDo

	For nIndCache := 1 to Len(aCachePRD)
		aSize(aCachePRD[nIndCache], 0)
	Next
	aSize(aCachePRD, 0)

	FreeObj(oExisteMAT)
	oExisteMAT := Nil

	aSize(aCposPRD, 0)
	aCposPRD := Nil

	::oLogs:log(STR0065 + Time(), "L") //"Fim do loop master de delegacao dos processamentos - "

	If ::oDados:oParametros['lAnalisaMemoriaPosLoop']
		::oDados:oProdutos:analiseMemoria(::oDados:oParametros['lAnalisaMemoriaSplit'], "ANALISE DE MEMORIA APOS LOOP NIVEIS")
	EndIf

Return

/*/{Protheus.doc} revisaoProduto
Busca a revis�o de determinado produto

@author    lucas.franca
@since     27/06/2019
@version 1.0
@param 01 - cProduto, caracter, codigo do produto
@param 02 - cRoteiro, caracter, retorna por refer�ncia o roteiro para produ��o do produto
@return cRevisao, caracter, revis�o utilizada pelo produto
/*/
METHOD revisaoProduto(cProduto, cRoteiro) CLASS MrpDominio
	Local aAreaPRD := Nil
	Local aRetAux  := {}
	Local cRevisao := "   "
	Local lAtual   := cProduto == ::oDados:oProdutos:cCurrentKey

	If !lAtual
		aAreaPRD := ::oDados:retornaArea("PRD")
	EndIf

	aRetAux  := ::oDados:retornaCampo("PRD", 1, cProduto, {"PRD_REVATU", "PRD_ROTEIR"}, , lAtual, , /*lProximo*/, , , .T. /*lVarios*/)
	cRevisao := aRetAux[1]

	If cRoteiro == Nil .OR. Empty(cRoteiro)
		cRoteiro := aRetAux[2]
	EndIf

	If !lAtual
		::oDados:setaArea(aAreaPRD)
	EndIf

Return cRevisao

/*/{Protheus.doc} periodoAnterior
Identifica o periodo anterior do produto existente na matriz
@author    brunno.costa
@since     08/07/2019
@version 1.0
@param 01 - cChaveProd  , caracter, codigo do produto
@param 02 - nPeriodo    , numero  , periodo atual referencia
@param 03 - aPRDPeriodos, array   , array com os dados de periodos existentes na matriz para o cChaveProd - RETORNO POR REFERENCIA
@PARAM 04 - lErrorMAT   , logico  , indica falha no retorno da variavel de controle dos periodos do produto
@return nReturn, numero , periodo anterior do produto existente na matriz
/*/
METHOD periodoAnterior(cChaveProd, nPeriodo, aPRDPeriodos, lErrorMAT) CLASS MrpDominio
	Local nAux      := 0
	Local nAux2
	Local nReturn   := 0
	Local oDados        := ::oDados

	Default aPRDPeriodos := {}
	Default lErrorMAT    := .F.

	oDados:oMatriz:getAllList("Periodos_Produto_" + cChaveProd, @aPRDPeriodos, @lErrorMAT)
	If !lErrorMAT
		aSort(aPRDPeriodos, , , { |x,y| x[2] < y[2] } )
		nAux2 := 1
		While nAux2 > 0
			nAux2 := aScan(aPRDPeriodos, { |nPer| nPer[2] < nPeriodo }, (nAux + 1) )
			If nAux2 > 0
				nAux := nAux2
			EndIf
		EndDo
		If nAux > 0
			nReturn := aPRDPeriodos[nAux][2]
		Else
			lErrorMAT  := .T.
		EndIf
	EndIf

Return nReturn

/*/{Protheus.doc} periodoPosterior
Identifica o periodo posterior do produto existente na matriz
@author    brunno.costa
@since     08/07/2019
@version 1.0
@param 01 - cChaveProd  , caracter, codigo do produto com ID Opcional
@param 02 - nPeriodo    , numero  , periodo atual referencia
@param 03 - aPRDPeriodos, array   , array com os dados de periodos existentes na matriz para o cChaveProd
@PARAM 04 - lErrorMAT   , logico  , indica falha no retorno da variavel de controle dos periodos do produto
@return nReturn, numero , periodo posterior do produto existente na matriz
/*/
METHOD periodoPosterior(cChaveProd, nPeriodo, aPRDPeriodos, lErrorMAT) CLASS MrpDominio
	Local aPRDPeriodos := {}
	Local nAux         := 0
	Local nReturn      := 0
	Local oDados       := ::oDados

	If aPRDPeriodos == Nil
		oDados:oMatriz:getAllList("Periodos_Produto_" + cChaveProd, @aPRDPeriodos, @lErrorMAT)
		If !lErrorMAT
			aSort(aPRDPeriodos, , , { |x,y| x[2] < y[2] } )
		EndIf
	EndIf

	If !Empty(aPRDPeriodos)
		nAux := aScan(aPRDPeriodos, { |nPer| nPer[2] > nPeriodo } )
		If nAux > 0
			nReturn := aPRDPeriodos[nAux][2]
		Else
			lErrorMAT  := .T.
		EndIf
	EndIf

Return nReturn

/*/{Protheus.doc} saldoInicial
Identifica o saldo inicial do periodo
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux   , caracter, codigo da filial
@param 02 - cChaveProd, caracter, codigo do produto com IDOpcional
@param 03 - nPeriodo  , numero  , periodo referencia
@param 04 - lSomaNec  , logico  , indica se deve somar a necessidade do periodo anterior
@param 05 - cIDOpc    , caracter, ID Opcional do produto
@return nSaldo, numero, saldo do periodo anterior
/*/
METHOD saldoInicial(cFilAux, cProduto, nPeriodo, lSomaNec, cIDOpc) CLASS MrpDominio
	Local aAreaMAT      := {}
	Local aPRDPeriodos  := {}
	Local cChaveMAT     := ""
	Local cChaveProd    := cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
	Local lErrorMAT     := .F.
	Local lErrorPRD     := .F.
	Local nSaldo        := 0
	Local nSldPosterior := 0
	Local oDados        := ::oDados

	Default lSomaNec := .T.

	aAreaMAT  := oDados:retornaArea("MAT")

	//Verifica saldo inicial referencia
	cChaveMAT := DtoS(Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cChaveProd

	//Identifica o saldo atual na tabela Produtos
	nSaldo    := oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_SLDDIS", @lErrorPRD)

	If oDados:oOpcionais:getFlag("PRD_COM_OPC" + CHR(10) + cFilAux + cProduto) .And. Empty(cIDOpc)
		nSaldo := 0
	EndIf

	If oDados:existeMatriz(cFilAux, cProduto, , cChaveProd, cIDOpc)
		//Identifica o saldo inicial atual na tabela Matriz
		If nSaldo == 0 .Or. nSaldo == Nil
			nSaldo := oDados:retornaCampo("MAT", 1, cChaveMAT, "MAT_SLDINI", @lErrorMAT)
			If lErrorMAT
				nSaldo := 0
			EndIf
		EndIf

		//Identifica periodo existente anterior
		nPerInicio := ::periodoAnterior(cChaveProd, nPeriodo, @aPRDPeriodos, @lErrorMAT)

		//Identifica saldo final de registro anterior da Matriz
		If nPerInicio > 0
			nSaldo := ::saldoFinal(cFilAux, cChaveProd, nPerInicio, lSomaNec, nSaldo)
		Endif

		//Caso nao tenha identificado o saldo ainda, verifica saldo inicial em registro posterior da Matriz
		If nSaldo == 0 .And. lErrorMAT// .AND. oDados:foiCalculado(cProduto, nPeriodo)
			nSldPosterior := ::saldoPosterior(cFilAux, cProduto, nPeriodo, .F., .F., aPRDPeriodos, cIDOpc)
			If nSldPosterior > 0
				nSaldo := nSldPosterior
			EndIf
		EndIf
	EndIf

	oDados:setaArea(aAreaMAT)

Return nSaldo

/*/{Protheus.doc} saldoFinal
Identifica o saldo final do produto no per�odo atual
@author    brunno.costa
@since     08/07/2019
@version 1.0
@param 01 - cFilAux , caracter, codigo da filial
@param 02 - cProduto, caracter, codigo do produto
@param 03 - nPeriodo, numero  , periodo referencia
@param 04 - lSomaNec, logico  , indica se deve somar a necessidade do periodo anterior
@parma 05 - nSaldo  , numero  , conteudo default
@return nSaldo, numero, saldo final do periodo atual
/*/
METHOD saldoFinal(cFilAux, cProduto, nPeriodo, lSomaNec, nSaldo) CLASS MrpDominio
	Local cChaveMAT
	Local lErrorMAT     := .F.
	Local nPerAux
	Local nSldAnterior  := 0
	Local nNecess       := 0
	Local nNecessPMP    := 0
	Local oDados        := ::oDados

	Default lSomaNec    := .T.
	Default nSaldo        := 0

	For nPerAux := nPerInicio to 1 step -1
		cChaveMAT    := DtoS(Self:oPeriodos:retornaDataPeriodo(cFilAux, nPerAux)) + cProduto
		lErrorMAT    := .F.
		nSldAnterior := oDados:retornaCampo("MAT", 1, cChaveMAT, "MAT_SALDO", @lErrorMAT)

		If !lErrorMAT     //Encontrou produto na matriz
			If lSomaNec
				nNecess    := oDados:retornaCampo("MAT", 1, cChaveMAT, "MAT_NECESS", @lErrorMAT)
				nNecessPMP := ::getPMPPeriodo(cProduto, nPeriodo)
			EndIf
			nSaldo := nSldAnterior + nNecess - nNecessPMP
			Exit

		Else              //Nao encontrou produto na matriz
			nSldAnterior := 0
			Loop

		EndIf

	Next nPerAux

Return nSaldo

/*/{Protheus.doc} saldoPosterior
Identifica o saldo inicial do produto no periodo posterior ao periodo atual
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux     , caracter, codigo da filial
@param 02 - cProduto    , caracter, codigo do produto
@param 03 - nPeriodo    , numero  , periodo atual referencia
@param 04 - lSldIniAtual, logico  , indica avalia saldo inicial do registro atual da matriz
@param 05 - lSldProduto , logico  , indica se avalia o saldo atual da tabela de produtos
@param 06 - aPRDPeriodos, array   , array com os dados de periodos existentes na matriz para o cProduto
@param 07 - cIDOpc      , caracter, ID Opcional do produto
@return nSaldo, numero, saldo inicial posterior ao periodo atual
/*/
METHOD saldoPosterior(cFilAux, cProduto, nPeriodo, lSldIniAtual, lSldProduto, aPRDPeriodos, cIDOpc) CLASS MrpDominio
	Local aAreaMAT
	Local aPeriodos   := Self:oPeriodos:retornaArrayPeriodos(cFilAux)
	Local cChaveMAT   := ""
	Local cChaveProd  := cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
	Local lErrorMAT   := .F.
	Local lErrorPRD   := .F.
	Local nPerAux
	Local nSaldo      := 0
	Local nSldAux     := 0
	Local nPerInicio  := Len(aPeriodos)
	Local oDados      := ::oDados

	Default lSldIniAtual := .F.
	Default lSldProduto  := .T.

	aAreaMAT  := oDados:retornaArea("MAT")
	cChaveMAT := DtoS(aPeriodos[nPeriodo]) + cChaveProd
	lErrorMAT := .F.

	//Identifica o saldo atual na tabela Produtos
	If lSldProduto
		nSaldo := oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_SLDDIS", @lErrorPRD)
	EndIf

	If oDados:existeMatriz(cFilAux, cProduto, , cChaveProd, cIDOpc)
		//Identifica o saldo inicial atual na tabela Matriz
		If lSldIniAtual
			If nSaldo == 0 .Or. nSaldo == Nil
				nSaldo := oDados:retornaCampo("MAT", 1, cChaveMAT, "MAT_SLDINI", @lErrorMAT)
				If lErrorMAT
					nSaldo := 0
				EndIf
			EndIf
		EndIf

		//Verifica Periodo existente posterior
		nPerInicio := ::periodoPosterior(cChaveProd, nPeriodo, aPRDPeriodos, @lErrorMAT)

		//Identifica saldo inicial de registro posterior da Matriz
		If nPerInicio > 0
			For nPerAux := nPerInicio to Len(aPeriodos)
				cChaveMAT := DtoS(aPeriodos[nPerAux]) + cChaveProd
				lErrorMAT := .F.
				nSldAux   := oDados:retornaCampo("MAT", 1, cChaveMAT, "MAT_SLDINI", @lErrorMAT)

				If !lErrorMAT       //Encontrou produto na matriz
					nSaldo := nSldAux
					Exit

				Else                //Nao encontrou produto na matriz
					nSldAux := 0
					Loop

				EndIf

			Next nPerAux
		EndIf
	EndIf

	oDados:setaArea(aAreaMAT)

Return nSaldo

/*/{Protheus.doc} politicaDeEstoque
Aplica politica de estoque a quantidade do produto
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux     , caracter, c�digo da filial
@param 02 - cChaveProd  , caracter, chave do produto (chave do produto, filial+produto)
@param 03 - nSaldoAtu   , numero  , saldo atual do produto
@param 04 - lAtual      , logico  , indica se deve reposicionar no cadastro de parametros de produtos
@param 05 - nPeriodo    , numero  , per�odo onde a demanda est� sendo calculada.
@param 06 - lReinicia   , logico  , Retorna valor por refer�ncia. Indica se o c�lculo do produto deve ser reiniciado.
@param 07 - aBaixaPorOP , array   , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Id Rastreabilidade,;
								     2 - Documento Pai,;
								     3 - Quantidade Necessidade,;
								     4 - Quantidade Estoque,;
								     5 - Quantidade Baixa Estoque,;
								     6 - Quantidade Substitui��o},...}
@param 08 - lAlternativo, l�gico  , indica se este produto � substituto (alternativo)
@param 09 - lProcAGL    , l�gico  , indica que est� reprocessando para calcular os registros ap�s aglutina��o de necessidade
@param 10 - cProduto    , caracter, c�digo do produto
@param 11 - nQtrEnt     , numero  , quantidade total de transfer�ncias de entrada
@param 12 - cNivel      , caracter, nivel do produto
@param 13 - cIDOpc      , caracter, opcional do produto
@param 14 - nQtdTran    , numero  , quantidade transferida do produto
@param 15 - lProcAll    , l�gico  , Indica que o processamento deve ser feito por completo (.T.), ou se dever� ser realizada
                                    somente atualiza��o das globais para cancelar o processamento atual.
@param 16 - lWait       , l�gico  , identifica se o calculo desse produto deve ser pausado por depend�ncia de outro produto (alternativo).
@param 17 - lErrorALT   , l�gico  , Indica se existem produtos alternativos
@param 18 - aMinMaxAlt  , Array   , Array com o nMin e nMax de sequ�ncia do alternativo
@param 19 - nSomaSubTr  , numero  , retorna por refer�ncia quantidade de substitui��o para os alternativos com transfer�ncia de estoque entre filiais.
@param 20 - lSemTran    , l�gico  , Identifica que as tentativas de buscar saldo deste produto em outras filiais se esgotaram, e n�o deve ser
                                    realizada nova tentativa de consumo de estoque neste c�lculo
@return nNecess      , numero  , quantidade apos aplicacao da politica de estoque
/*/
METHOD politicaDeEstoque(cFilAux, cChaveProd, nSaldoAtu, lAtual, nPeriodo, lReinicia,;
                         aBaixaPorOP, lAlternativo, lProcAGL, cProduto, nQtrEnt, cNivel,;
                         cIDOpc, nQtdTran, lProcAll, lWait, lErrorALT, aMinMaxAlt, nSomaSubTr, lSemTran) CLASS MrpDominio
	Local aIndBxAtu   := {}
	Local aLotes      := {}
	Local cChave      := ""
	Local cCodAGL     := ""
	Local cDocFilho   := ""
	Local cNewDoc     := ""
	Local lAglutina   := ::oDados:oDominio:oAglutina:avaliaAglutinacao(cFilAux, cProduto)
	Local lCalcula    := .T.
	Local lErrorPRD   := .F.
	Local lNecePP     := .F.
	Local lRasOrgAgl  := .F.
	Local lRegAgl     := .F.
	Local lRegPMP     := .F.
	Local lSubProduto := .F.
	Local lStkPolPMP  := ::oParametros["stockPolicyPMP"] == "S"
	Local lUsaME      := Self:oMultiEmp:utilizaMultiEmpresa()
	Local nConsEstq   := 0
	Local nDesfez     := 0
	Local nDiferenca  := 0
	Local nEstoque    := 0
	Local nEstqIni    := 0
	Local nIndDocFil  := 0
	Local nIndex      := 0
	Local nNecAux     := 0
	Local nNecDif     := 0
	Local nNecess     := 0
	Local nNecessPMP  := 0
	Local nNecInic    := 0
	Local nNecOri     := 0
	Local nPontoPed   := 0
	Local nPosAgl     := 0
	Local nPosNec     := 0
	Local nPosPP      := 0
	Local nQtdNec     := 0
	Local nQtTransf   := 0
	Local nRegPMP     := 0
	Local nSldAux     := 0
	Local nSobraSld   := 0
	Local nSomaNecec  := 0
	Local nSomaTranf  := 0
	Local nSubsTran   := 0
	Local nTotal      := 0
	Local nTotBxOp    := 0
	Local nTotRegNec  := 0
	Local oDados      := ::oDados

	Default lAtual     := cChaveProd == ::oDados:oProdutos:cCurrentKey
	Default lProcAGL   := .F.
	Default nPeriodo   := 0
	Default nQtrEnt    := 0
	Default nQtdTran   := 0

	lReinicia := .F.

	If nPeriodo > 0 .And. ;
	   nSaldoAtu < 0 .And. ;
	   ::oParametros["nLeadTime"] != 1 .And. ;
	   !::oPeriodos:verificaDataUtil(cFilAux, Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo))

		//Adiciona o pr�ximo per�odo para o c�lculo. Somente ir� gerar necessidade em per�odos �teis.
		lCalcula  := .F.
		lReinicia := .T.
	EndIf

	If lCalcula
		If ::oParametros["lPontoPedido"] .And. !lAlternativo
			nPontoPed := oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_PPED", @lErrorPRD, lAtual /*lAtual*/, , , , , .F. /*lVarios*/)
		Else
			nPontoPed := 0
		EndIf

		If nSaldoAtu < 0
			//Saldo atual � negativo.
			//Gera necessidade para igualar o saldo a 0
			nNecess := Abs(nSaldoAtu)
		EndIf

		If aBaixaPorOP != Nil
			nNecOri := nNecess //Armazena a necessidade original

			//Percorre o aBaixaPorOp aplicando as regras de lotes para cada necessidade.
			nTotBxOp   := Len(aBaixaPorOP)
			nNecess    := 0

			If lAglutina
				For nIndex := 1 To nTotBxOp
					If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "1"
						nRegPMP++
					EndIf
				Next nIndex
				//Se o total de registros desconsiderando o PMP for menor que 1, n�o
				//existe a necessidade de executar as regras de aglutinar as necessidades
				//em um registro �nico.
				If nTotBxOp - nRegPMP < 2
					lAglutina := .F.
				EndIf
			EndIf

			If lAglutina .And. !lProcAGL .And. Self:oParametros["lRastreiaEntradas"]
				lRasOrgAgl := .T.
			EndIf

			For nIndex := 1 To nTotBxOp
				nConsEstq  := 0
				nTotal     := 0
				lRegAgl    := aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "AGL"
				lRegPMP    := aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "1"

				If lAglutina .And. nPosAgl == 0 .And. lRegAgl
					nPosAgl := nIndex
					cCodAGL := aBaixaPorOP[nPosAgl][ABAIXA_POS_DOCPAI]
				EndIf

				If lAglutina .And. !lProcAGL .And. Empty(cDocFilho) .And. !Empty(aBaixaPorOP[nIndex][ABAIXA_POS_DOCFILHO])
					cDocFilho  := aBaixaPorOP[nIndex][ABAIXA_POS_DOCFILHO]
					nIndDocFil := nIndex
				EndIf

				//Atualiza controle de saldo em estoque
				If nIndex == 1
					nEstoque  := aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] - aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE]
					nEstqIni  := aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
				Else
					If nEstoque != aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
						aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] := nEstoque
					EndIf
				EndIf

				If AllTrim(aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI]) $ "|"+scTextPPed+"|" //Ponto Ped.
					nPosPP := nIndex
					Loop
				EndIf

				If lRegAgl .And. !lProcAGL
					Loop
				EndIf

				If aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG] < 0
					lSubProduto := .T.
				EndIf

				nNecInic := aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE]

				//Atualiza a qtd. de necessidade
				nQtdNec := aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG] + aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA] - aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA]
				//Atualiza a qtd. de baixa de estoque.
				//Somente baixa estoque se:
				//-> n�o for do tipo PMP, e;
				//-> n�o for registro de alternativo
				//-> n�o for ponto de pedido
				If !(AllTrim(aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI]) $ "|1|"+scTextPPed+"|"); //"PMP|Ponto Ped."
				   .AND. aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] >= 0

					//Zera consumo de estoque do produto original referente REGRA DO TIPO 3
					If aBaixaPorOP[nIndex][ABAIXA_POS_REGRA_ALT] == "3"
						aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] := 0

					ElseIf lProcAGL .And. nPosAgl > 0 .And. aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] > 0
						//Se est� na recursividade da aglutina��o, e o registro j� possui substitui��o,
						//faz o c�lculo de baixa de estoque considerando a quantidade que j� foi substituida.
						aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] := aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG] - aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO]

						//Abate consumo de estoque
						nQtdNec -= aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE]
					ElseIf "|TRANF" $ "|"+AllTrim(aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI]);
						   .And. aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA] > 0 ;
						   .And. aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] > 0
						   //Se for transfer�ncia de produ��o a necessidade ser� sempre a qtd a ser transferida, j� atribuida na vari�vel nQtdNec
						If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] != "TRANF_PR"
							If aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] > aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
								nQtdNec := nQtdNec - aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
							Else
								nQtdNec := nQtdNec - aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
							EndIf
						EndIf
					ElseIf !lRegAgl
						//Tem necessidade maior que o estoque dispon�vel. Atualiza a QTD de consumo de estoque.
						If (aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG]) >= aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
							aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] := aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]

						//Tem necessidade menor que o estoque. Atualiza a qtd. de consumo de estoque.
						Else
							aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] := aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG]
						EndIf

						//Abate do consumo de estoque a quantidade de transfer�ncia de entrada.
						If lProcAGL .And. nPosAgl > 0 .And. aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA] > 0
							nSobraSld := nQtdNec - aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE]

							If nSobraSld < 0
								aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] += nSobraSld
							Else
								aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] -= aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA]
							EndIf
						EndIf

						//Abate consumo de estoque
						nQtdNec -= aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE]
					EndIf

					//Abate da necessidade ENTRADA DE SUBSTITUI��O
					If (nQtdNec - aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO]) >= 0
						nQtdNec -= aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO]
					EndIf
				EndIf

				//Atualiza a qtd. de baixa de estoque.
				If aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] < 0;
				   .OR. aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] < 0
					aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE] := 0
				EndIf
				nConsEstq += aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE]

				//Atualiza a qtd. de estoque.
				If aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] < 0
					aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] := 0
				EndIf

				//ACRESCENTA necessidade Substitu�da por REGRA DOS TIPOS 2 ou 3 - ALTERNATICO
				IF aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] < 0;
					.AND. (aBaixaPorOP[nIndex][ABAIXA_POS_REGRA_ALT] $ "|2|3|")
					nQtdNec += ABS(aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] )
					nQtdNec -= aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
				EndIf

				If lUsaME
					//Abate as quantidades de transfer�ncia
					If nQtdNec > 0 .And. nQtrEnt > 0 .And. !lRegPMP
						If nQtdNec >= nQtrEnt
							aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA] += nQtrEnt
							nQtdNec -= nQtrEnt
							nQtrEnt := 0
						Else
							aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA] += nQtdNec
							nQtrEnt -= nQtdNec
							nQtdNec := 0
						EndIf
					EndIf

					//Verifica se os produtos alternativos possuem saldo em outras filiais quando � utilizado o Multi-Empresa.
					If lProcAll .And. !lErrorAlt .And. nQtdNec > 0 .And. AllTrim(aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI]) == "OP"
						aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE] := nQtdNec
						nSubsTran := Self:oMultiEmp:alternativosMultiEmpresa(cFilAux, cProduto, nPeriodo, cIDOpc, @aBaixaPorOP[nIndex], nQtdNec, @lWait, aMinMaxAlt)

						If !lWait .And. nSubsTran > 0
							nSomaSubTr += nSubsTran
							nQtdNec    -= nSubsTran
						EndIf
					EndIf

					If lProcAll .And. nQtdNec > 0 .And. cNivel == "99" .And. (!lAglutina .Or. (lAglutina .And. lProcAgl))
						nQtdNec := Self:oMultiEmp:processaEstruturaMultiempresa(cFilAux,cProduto,cIDOpc,nPeriodo,@aBaixaPorOP[nIndex],nQtdNec,@nQtdTran)

						If nQtdTran > 0
							nSomaTranf += nQtdTran
						Endif
					EndIf
				EndIf

				//Aplica as pol�ticas de estoque.
				nNecAux := nQtdNec
				If lAglutina .And. nTotBxOp > 1 .And. !lRegAgl .And. !lRegPMP .And. !lProcAGL
					nTotal := Iif(nQtdNec > 0, nQtdNec, 0)
					aLotes := {nTotal}
				ElseIf !lRegPMP .Or. lStkPolPMP
					If nQtdNec > 0
						aLotes := Self:calcularLotes(cChaveProd, nQtdNec, @nTotal, nPeriodo, cFilAux)
					Else
						aLotes := Self:calcularLotes(cChaveProd, 0, @nTotal, nPeriodo, cFilAux)
					EndIf
				Else
					nTotal := Iif(nQtdNec > 0, nQtdNec, 0)
					aLotes := {nTotal}
				EndIf

				//Armazena o array de controle das quebras de quantidades para produ��o/compra.
				aBaixaPorOP[nIndex][ABAIXA_POS_QUEBRAS_QUANTIDADE] := Self:ajustarArrayQuebrasQtd(aLotes)

				//ALTERNATIVO COM REGRA DO TIPO 1 (Diferente de 2 e 3)
				If aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] < 0;
				   .And. aBaixaPorOP[nIndex][ABAIXA_POS_REGRA_ALT] == "1"

					//ACRESCENTA necessidade Substitu�da por REGRA DO TIPO 1 (Diferente de 2 e 3)
					If (aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] + nTotal;
						- aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE]);
						> ABS(aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO])

						If lAlternativo
							nQtdNec += ABS(aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] + aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE])
						EndIf

					//****************************************************************************//
					//AJUSTA necessidade Substitu�da acima da quantidade dispon�vel, REGRA DO TIPO 1
					//****************************************************************************//
					ElseIf !lAlternativo
						nDiferenca := Abs(aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO])
						nDiferenca -= aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
						nDiferenca -= aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA]
						nDiferenca += nTotal
						nDiferenca -= aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE]

						If nDiferenca > 0
							nDesfez := ::oAlternativo:desfazParcialSubstituicao(cFilAux, aBaixaPorOP[nIndex][ABAIXA_POS_CHAVE_SUBST], cProduto, nDiferenca, nPeriodo, @aBaixaPorOP, .T.)
							aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] += nDesfez
						EndIf

						nQtdNec += ABS(aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO] + aBaixaPorOP[nIndex][ABAIXA_POS_CONSUMO_ESTOQUE])

					EndIf
				EndIf

				//Verifica se ap�s aplicar a pol�tica de estoque deste produto, foi gerada uma necessidade maior do que
				//era necess�rio. Neste caso, utiliza a vari�vel nSldAux para controlar as sobras de estoque e reutilizar para as
				//pr�ximas necessidades.
				If nTotal > nQtdNec .AND. nQtdNec > 0

					//A necessidade que ser� gerada � maior que o necess�rio devido as pol�ticas de estoque do produto.
					//Atualiza a vari�vel nSldAux para considerar a sobra de saldo para os pr�ximos rastreios.
					nSldAux += nTotal - nQtdNec

					//Atualiza no baixaPorOP a qtd. que ser� produzida;
					aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE] := nTotal

				ElseIf nNecInic != nTotal
					//Atualiza no baixaPorOP a qtd. que ser� produzida;
					aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE] := nTotal

				EndIf

				//Marca linha para atualizar dados na global de mem�ria.
				aAdd(aIndBxAtu, nIndex)

				//Sumariza a qtd. dos lotes para registrar na matriz.
				nNecess  += nTotal

				If lRegPMP
					nNecessPMP += aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG]
				EndIf

				aSize(aLotes, 0)

				If lProcAGL .And. lRegAgl
					nEstoque := aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE]
					nEstoque += aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA]
					nEstoque += nSaldoAtu
				Else
					nEstoque  := aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE]
					If !lRegPMP
						nEstoque  -= aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG]
					EndIf
					nEstoque  += aBaixaPorOP[nIndex][ABAIXA_POS_NECESSIDADE]
					nEstoque  += aBaixaPorOP[nIndex][ABAIXA_POS_QTD_SUBSTITUICAO]
					nEstoque  += aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_ENTRADA]
					nEstoque  -= aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
				EndIf

				If lAglutina
					If nTotal > 0 .And. !lRegPMP
						nTotRegNec++
						nPosNec := nIndex
						If !lRegAgl
							aBaixaPorOP[nIndex][ABAIXA_POS_DOC_AGLUTINADOR][1] := .T.
						EndIf
					EndIf
					If nTotBxOp > 1 .And. !lRegPMP
						nSomaNecec += nTotal
					EndIf
					If !Empty(cCodAGL) .And. aBaixaPorOP[nIndex][ABAIXA_POS_DOC_AGLUTINADOR][1]
						aBaixaPorOP[nIndex][ABAIXA_POS_DOC_AGLUTINADOR][2] := cCodAGL
					EndIf
				EndIf

				If lRasOrgAgl .And. !lRegAgl
					aBaixaPorOP[nIndex][ABAIXA_POS_RASTRO_AGLUTINACAO][1] := nTotal
				EndIf

				If lWait .And. !(lUsaME .And. !lProcAll .And. nQtrEnt > 0)
					Exit
				EndIf

			Next nIndex

			//Verifica se a necessidade antes de calcular os lotes
			//� maior que a necessidade ap�s calcular os lotes.
			//Nesse caso, calcula novamente o lote somente para a diferen�a.
			If (nNecOri - nSomaTranf - nSomaSubTr) > nNecess
				nNecDif := (nNecOri - nSomaTranf - nSomaSubTr) - nNecess
				nTotal  := 0
				aLotes  := Self:calcularLotes(cChaveProd, nNecDif, @nTotal, nPeriodo, cFilAux)
				//Sumariza a qtd. dos lotes para registrar na matriz.
				nNecess += nTotal
			EndIf
		Else
			aLotes  := Self:calcularLotes(cChaveProd, nNecess, @nTotal, nPeriodo, cFilAux)
			//Sumariza a qtd. dos lotes para registrar na matriz.
			nNecess := nTotal
		EndIf

		aSize(aLotes, 0)

		//Se houver ponto de pedido, avalia no final do c�lculo
		If !lWait .And. (!lAglutina .Or. nTotBxOp == 1 .Or. nTotRegNec == 0) .And. nPosPP > 0 .And. nPontoPed > 0
			If lProcAGL
				nQtdNec := aBaixaPorOP[nPosPP][ABAIXA_POS_NEC_ORIG]
			Else
				nQtdNec := nPontoPed - (nSaldoAtu+nNecess-nNecessPMP+nSomaTranf)
			EndIf

			If nQtdNec < 0
				//Possui saldo para atender o PP. N�o gera necessidade.
				nQtdNec   := 0
				nPontoPed := 0
			EndIf

			aBaixaPorOP[nPosPP][ABAIXA_POS_NEC_ORIG   ] := nPontoPed
			aBaixaPorOP[nPosPP][ABAIXA_POS_QTD_ESTOQUE] := nSaldoAtu+nNecess-nNecessPMP
			If aBaixaPorOP[nPosPP][ABAIXA_POS_QTD_ESTOQUE] < 0
				aBaixaPorOP[nPosPP][ABAIXA_POS_QTD_ESTOQUE] := 0
			EndIf

			nTotal  := 0
			If lProcAGL
				aBaixaPorOP[nPosPP][ABAIXA_POS_QTD_ESTOQUE] := nEstoque
				nQtdNec := aBaixaPorOP[nPosPP][ABAIXA_POS_NEC_ORIG] - aBaixaPorOP[nPosPP][ABAIXA_POS_QTD_ESTOQUE]
			EndIf
			If lUsaME .And. lProcAll .And. nQtdNec > 0 .And. !lProcAGL
				//Verifica se existe saldo em outra filial e faz a transfer�ncia.
				nQtTransf := 0
				//Vari�vel lSemTran tem origem na primeira chamada do m�todo consumirEstoqueME no in�cio do c�lculo.
				If lSemTran == .F.
					nQtdNec   := Abs(soDominio:oMultiEmp:consumirEstoqueME(cFilAux, cProduto, nPeriodo, cIDOpc, -nQtdNec, @lWait, @nQtTransf, .T.))
				EndIf

				If !lWait
					aBaixaPorOP[nPosPP][ABAIXA_POS_TRANSFERENCIA_ENTRADA] := nQtTransf
					nSomaTranf += nQtTransf

					//Se ainda ficou necessidade, verifica se deve produzir em outra filial.
					If cNivel == "99" .And. nQtdNec > 0
						nQtdNec := Self:oMultiEmp:processaEstruturaMultiempresa(cFilAux,cProduto,cIDOpc,nPeriodo,@aBaixaPorOP[nPosPP],nQtdNec,@nQtdTran)

						If nQtdTran > 0
							nSomaTranf += nQtdTran
						Endif
					EndIf
				EndIf
			EndIf

			aLotes := Self:calcularLotes(cChaveProd, nQtdNec, @nTotal, nPeriodo, cFilAux)

			aBaixaPorOP[nPosPP][ABAIXA_POS_NECESSIDADE] := nTotal
			nNecess += aBaixaPorOP[nPosPP][ABAIXA_POS_NECESSIDADE]

			aBaixaPorOP[nPosPP][ABAIXA_POS_QUEBRAS_QUANTIDADE] := Self:ajustarArrayQuebrasQtd(aLotes)

			aSize(aLotes, 0)

			aAdd(aIndBxAtu, nPosPP)
		EndIf

		If !lWait .And. lProcAll .And. lAglutina .And. !lAlternativo .And. !lProcAGL .And. nTotBxOp > 1 .And. nTotRegNec > 0
			//Quando aglutina, soma todas as necessidades sem aplicar as pol�ticas de estoque,
			//e aplica as pol�ticas sobre o total.
			//Se existir mais de um registro, ser� criado um novo registro para aglutinar a necessidade
			//de compra/produ��o.
			nTotal  := 0
			aLotes  := Self:calcularLotes(cChaveProd, nSomaNecec, @nTotal, nPeriodo, cFilAux)
			nNecess := nTotal

			If Len(aIndBxAtu) > 0
				//Grava as informa��es atualizadas no arquivo de rastreabilidade.
				Self:oRastreio:atualizaRastreio(cFilAux, cChaveProd, nPeriodo, @aBaixaPorOP, aIndBxAtu, cProduto)
			EndIf

			aSize(aIndBxAtu, 0)

			//Verifica necessidades de ponto de pedido.
			If nPosPP > 0 .And. nPontoPed > 0
				nQtdNec := nPontoPed - (nSaldoAtu+nNecess)
				If nQtdNec > 0
					//Se for gerar necessidade para ponto de pedido, considera como necessidade
					//a vari�vel "nSomaNecec" no lugar de "nNecess", para que o c�lculo com lotes seja
					//realizado com as quantidades corretas.
					nQtdNec := nPontoPed - (nSaldoAtu+nSomaNecec)
				EndIf

				If nPosAgl > 0 .And. nQtdNec < 0 .And. aBaixaPorOP[nPosAgl][ABAIXA_POS_TRANSFERENCIA_ENTRADA] > 0
					nQtdNec += aBaixaPorOP[nPosAgl][ABAIXA_POS_TRANSFERENCIA_ENTRADA]
				EndIf

				If nQtdNec < 0
					//Possui saldo para atender o PP. N�o gera necessidade.
					aBaixaPorOP[nPosPP][ABAIXA_POS_NEC_ORIG   ] := 0
					aBaixaPorOP[nPosPP][ABAIXA_POS_QTD_ESTOQUE] := 0
				Else
					lNecePP := .T.
					aBaixaPorOP[nPosPP][ABAIXA_POS_NEC_ORIG   ] := nQtdNec
					aBaixaPorOP[nPosPP][ABAIXA_POS_QTD_ESTOQUE] := nQtdNec

					If lRasOrgAgl
						aBaixaPorOP[nPosPP][ABAIXA_POS_RASTRO_AGLUTINACAO][1] := nQtdNec
					EndIf

					nSomaNecec += nQtdNec

					//Recalcula os lotes com a necessidade de ponto de pedido somada.
					nTotal  := 0
					aLotes  := Self:calcularLotes(cChaveProd, nSomaNecec, @nTotal, nPeriodo, cFilAux)
					nNecess := nTotal
				EndIf
				aBaixaPorOP[nPosPP][ABAIXA_POS_NECESSIDADE       ] := 0
				aBaixaPorOP[nPosPP][ABAIXA_POS_QUEBRAS_QUANTIDADE] := Self:ajustarArrayQuebrasQtd({0})

				If nPosPP <> nPosAgl
					aAdd(aIndBxAtu, nPosPP)
				EndIf
			EndIf

			cNewDoc := ""

			If nPosAgl > 0
				//J� existe registro aglutinador, atualiza.
				aBaixaPorOP[nPosAgl][ABAIXA_POS_NEC_ORIG          ] := nSomaNecec
				aBaixaPorOP[nPosAgl][ABAIXA_POS_NECESSIDADE       ] := nNecess
				aBaixaPorOP[nPosAgl][ABAIXA_POS_QUEBRAS_QUANTIDADE] := Self:ajustarArrayQuebrasQtd(aLotes)
				aAdd(aIndBxAtu, nPosAgl)

				cNewDoc := aBaixaPorOP[nPosAgl][ABAIXA_POS_DOCPAI]
			Else
				//N�o existe registro aglutinador, inclui um novo
				If nTotRegNec > 1 .Or. lNecePP
					cNewDoc := Self:oAglutina:novoIdAglutinacao()
					cChave  := Self:oRastreio:incluiNecessidade(cFilAux, "AGL", cNewDoc, cProduto, cIdOpc, /*06*/, nSomaNecec, nPeriodo,/*09*/, /*10*/, /*11*/, /*12*/, /*13*/, /*14*/, /*15*/, cDocFilho)

					//Adiciona o registro de aglutina��o na primeira posi��o do aBaixaPorOP
					aAdd(aBaixaPorOP, Nil)
					aIns(aBaixaPorOP, 1)
					aBaixaPorOP[1] := Self:oRastreio:montaBaixaPorOP(cChave                             ,; //cChave
					                                                 cNewDoc                            ,; //cDocPai
					                                                 nNecess                            ,; //nNecess
					                                                 0                                  ,; //nQtdEst
					                                                 0                                  ,; //nConsumo
					                                                 0                                  ,; //nSubstitui
					                                                 Self:ajustarArrayQuebrasQtd(aLotes),; //aQuebras
					                                                 "AGL"                              ,; //cTipoPai
					                                                 nSomaNecec                         ,; //nNecOrigem
					                                                 ""                                 ,; //cRegraAlt
					                                                 ""                                 ,; //cChaveSub
					                                                 0                                  ,; //nQtrEnt
					                                                 0                                  ,; //nQtrSai
					                                                 cDocFilho                          ,; //cDocFilho
					                                                 Nil                                ,; //aRastroAgl
					                                                 {.F., ""}                           )

					nPosAgl := 1
					//Verifica necessidade de atualizar o indicador de atualiza��o da linha de ponto de pedido.
					If nPosPP > 0
						nPosPP++
						If Len(aIndBxAtu) > 0
							aSize(aIndBxAtu, 0)
							aAdd(aIndBxAtu, nPosPP)
						EndIf
					EndIf
					aAdd(aIndBxAtu, nPosAgl)

					If nIndDocFil > 0
						nIndDocFil++

						aBaixaPorOP[nIndDocFil][ABAIXA_POS_DOCFILHO] := ""

						If aScan(aIndBxAtu, {|x| x == nIndDocFil}) == 0
							aAdd(aIndBxAtu, nIndDocFil)
						EndIf
					EndIf
				Else
					//Existe somente um registro com necessidade, ent�o n�o cria o registro aglutinador.
					aBaixaPorOP[nPosNec][ABAIXA_POS_NECESSIDADE       ] := nNecess
					aBaixaPorOP[nPosNec][ABAIXA_POS_QUEBRAS_QUANTIDADE] := Self:ajustarArrayQuebrasQtd(aLotes)
					aAdd(aIndBxAtu, nPosNec)
				EndIf
			EndIf

			If !Empty(cNewDoc) .And. nPosPP > 0
				aBaixaPorOP[nPosPP][ABAIXA_POS_DOC_AGLUTINADOR] := {.T., cNewDoc}
			EndIf

			If lRasOrgAgl .And. !Empty(cNewDoc)
				nTotBxOp   := Len(aBaixaPorOP)
				For nIndex := 1 To nTotBxOp
					If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "AGL"
						Loop
					EndIf

					If aBaixaPorOP[nIndex][ABAIXA_POS_RASTRO_AGLUTINACAO][1] != 0 .And. ;
					   aBaixaPorOP[nIndex][ABAIXA_POS_RASTRO_AGLUTINACAO][2] != cNewDoc

						aBaixaPorOP[nIndex][ABAIXA_POS_RASTRO_AGLUTINACAO][2] := cNewDoc
						If aScan(aIndBxAtu, {|x| x == nIndex}) == 0
							aAdd(aIndBxAtu, nIndex)
						EndIf
					EndIf
				Next nIndex
			EndIf

			//Executa novamente o m�todo de forma recursiva para atualizar a utiliza��o do saldo gerado pela primeira necessidade aglutinadora.
			nNecess := Self:politicaDeEstoque(cFilAux, cChaveProd, nEstqIni, lAtual, nPeriodo, @lReinicia, @aBaixaPorOP, lAlternativo, .T., cProduto, nQtrEnt, cNivel, cIDOpc, @nQtdTran, lProcAll, @lWait, lErrorALT, aMinMaxAlt, @nSomaSubTr, lSemTran)
		EndIf

		If Len(aIndBxAtu) > 0
			//Grava as informa��es atualizadas no arquivo de rastreabilidade.
			Self:oRastreio:atualizaRastreio(cFilAux, cChaveProd, nPeriodo, @aBaixaPorOP, aIndBxAtu, cProduto)
			aSize(aIndBxAtu, 0)
		EndIf

		If !lWait .And. lAlternativo .And. lProcAll
			If oDados:oLogs:logValido("XX")
				oDados:oLogs:log(STR0131 + AllTrim(cChaveProd) + STR0132 + cValToChar(nPeriodo), "XX")
			EndIf

			soDominio:oRastreio:atualizaSubstituicao(cFilAux, cProduto + Iif(!Empty(cIDOpc), "|" + cIDOpc, ""), nPeriodo, @aBaixaPorOP, .T.)

			//Chamada recursiva da pol�tica de estoque MrpDominio
			nNecess := Self:politicaDeEstoque(cFilAux, cChaveProd, (nSaldoAtu + nNecess), Nil, nPeriodo, lReinicia, aBaixaPorOP, .F., .F., cProduto, nQtrEnt, cNivel, cIDOpc, @nQtdTran, lProcAll, @lWait, lErrorALT, aMinMaxAlt, @nSomaSubTr, lSemTran)
		EndIf

	EndIf

	nQtdTran := nSomaTranf

Return nNecess

/*/{Protheus.doc} explodeAgrupadoPorRevisao
Explode a estrutura do produto para gerar demandas para os componentes
@author    brunno.costa
@since     20/09/2019
@version 1.0
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - cChaveProd , caracter, codigo do produto pai + ID Opcional
@param 03 - cProduto   , caracter, codigo do produto pai
@param 04 - nPerLead   , n�mero  , per�odo do leadtime
@param 05 - nPeriodo   , n�mero  , identificador do periodo
@param 06 - nPerMaximo , n�mero  , identificador do periodo m�ximo
@param 07 - cIDOpcPai  , caracter, identificador do opcional cProduto selecionado
@param 08 - aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
                                   {{1 - Id Rastreabilidade,;
                                     2 - Documento Pai,;
                                     3 - Quantidade Necessidade,;
                                     4 - Quantidade Estoque,;
                                     5 - Quantidade Baixa Estoque,;
                                     6 - Quantidade Substitui��o},...}
@param 09 - dLTReal    , date    , data real de in�cio ap�s aplicado o leadtime, sem reajustar aos per�odos do MRP
@param 10 - cNivelAtu  , caracter , Nivel atual do produto
/*/
METHOD explodeAgrupadoPorRevisao(cFilAux, cChaveProd, cProduto, nPerLead, nPeriodo, nPerMaximo, cIDOpcPai, aBaixaPorOP, dLTReal, cNivelAtu) CLASS MrpDominio

	//Agrupa as demandas por revis�o
	Local aRevisoes := ::agrupaRevisoes(cFilAux, cChaveProd, nPerLead, @aBaixaPorOP)
	Local lLog      := Self:oLogs:logValido("7")
	Local nTotal    := Len(aRevisoes)
	Local nInd

	For nInd := 1 to nTotal
		If lLog
			::oLogs:log(STR0039 + AllTrim(cChaveProd) + STR0018 + cValToChar(nPeriodo) + "/" + cValToChar(nPerMaximo) + STR0038 + cValToChar(aRevisoes[nInd][AREVISOES_POS_QTDE_TOTAL]), "7") //"Explosao Estrutura : " + " - Periodo: " + " - Necessidade (MAT_NECESS): "
		EndIf
		::explodirEstrutura(cFilAux,;
		                    cProduto,;
		                    aRevisoes[nInd][AREVISOES_POS_QTDE_TOTAL],;
		                    nPerLead,;
		                    nPeriodo,;
		                    "",;
		                    cIDOpcPai,;
		                    aRevisoes[nInd][AREVISOES_POS_aBaixaPorOP],;
		                    Iif(Empty(aRevisoes[nInd][AREVISOES_POS_REVISAO]), Nil, aRevisoes[nInd][AREVISOES_POS_REVISAO]),;
		                    Iif(Empty(aRevisoes[nInd][AREVISOES_POS_ROTEIRO]), Nil, aRevisoes[nInd][AREVISOES_POS_ROTEIRO]),;
		                    aRevisoes[nInd][AREVISOES_POS_LOCAL],;
		                    /*12*/,;
		                    /*13*/,;
		                    aRevisoes[nInd][AREVISOES_POS_VERSAOPROD],;
		                    /*15*/,;
		                    dLTReal,;
							/*17*/,;
							cNivelAtu)
	Next

	//Limpa Array aRevisoes
	For nInd := 1 to Len(aRevisoes)
		aSize(aRevisoes[nInd], 0)
		aRevisoes[nInd] := Nil
	Next
	aSize(aRevisoes, 0)

Return Nil

/*/{Protheus.doc} explodirEstrutura
Explode a estrutura do produto para gerar demandas para os componentes
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux    , caracter, c�digo da filial para processamento
@param 02 - cProduto    , caracter, codigo do produto pai
@param 03 - nNecPai     , numeric , quantidade de necessidade do produto pai
@param 04 - nPerLead    , numeric , per�odos de leadtime
@param 05 - nPeriodo    , numeric , numero do per�odo
@param 06 - cFantasma   , caracter, C�digo do produto pai que n�o � fantasma. Se estiver preenchido, indica que est� explodindo a estrutura de um produto fantasma.
@param 07 - cIDOpcPai   , caracter, identificador do opcional cProduto selecionado
@param 08 - aBaixaPorOP , array   , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Id Rastreabilidade,;
								     2 - Documento Pai,;
								     3 - Quantidade Necessidade,;
								     4 - Quantidade Estoque,;
								     5 - Quantidade Baixa Estoque,;
								     6 - Quantidade Substitui��o},...}
@param 09 - cRevisao   , caracter, revis�o do produto pai
@param 10 - cRoteiro   , caracter, roteiro de produ��o do produto Pai
@param 11 - cLocal     , caracter, local de consumo padr�o
@param 12 - cList      , caracter, chave produto + chr(13) + per�odo referente chaves da aBaixaPorOP
@param 13 - oRastrPais , objeto  , objeto Json para controle/otimiza��o das altera��es de rastreabilidade no regitro Pai durante explos�o na estrutura
@param 14 - cVersao    , caracter, c�digo da vers�o de produ��o utilizada na explos�o
@param 15 - lExplodiu  , logico  , Vari�vel de controle utilizada para identificar se explodiu a necessidade para algum componente. Uso interno e com recursividade.
@param 16 - dLTReal    , date    , data real de in�cio ap�s aplicado o leadtime, sem reajustar aos per�odos do MRP
@param 17 - cCodPrPais , caracter, controle de recursividade - registra a cadeia de produtos que iniciaram a explos�o de forma recursiva (fantasmas)
@param 18 - cNivelAtu  , caracter , Nivel atual do produto
@return lReturn, logico, indica se o produto possui estrutura
/*/
METHOD explodirEstrutura(cFilAux    , cProduto, nNecPai , nPerLead, nPeriodo, cFantasma , cIDOpcPai, ;
                         aBaixaPorOP, cRevisao, cRoteiro, cLocal  , cList   , oRastrPais, cVersao  , ;
                         lExplodiu  , dLTReal , cCodPrPais, cNivelAtu) CLASS MrpDominio

	Local aAreaMAT     := ::oDados:retornaArea("MAT")
	Local aAreaPRD     := ::oDados:retornaArea("PRD")
	Local aAux         := {}
	Local aComponentes := {}
	Local aDadosPRD    := {}
	Local aOperacoes   := {}
	Local cAllocaBN    := ::oParametros["allocationBenefit"]
	Local cBloqueio    := ""
	Local cChave       := ""
	Local cChaveEst    := cProduto
	Local cComponente  := ""
	Local cFilEst      := ""
	Local cIDOpc       := ""
	Local cOpcGrp      := ""
	Local cOpcItem     := ""
	Local cRegra       := ""
	Local cRevFimCmp   := ""
	Local cRevIniCmp   := ""
	Local cTipoProd    := ""
	Local cTRT         := ""
	Local dData        := Self:oPeriodos:retornaDataPeriodo(cFilAux, nPerLead)
	Local dDataOrig    := dData
	Local dDtFimCmp    := Nil
	Local dDtIniCmp    := Nil
	Local lError       := .F.
	Local lQtdFixa     := .F.
	Local lReturn      := .T.
	Local lUpdRstPai   := oRastrPais == Nil
	Local nAgluPRD     := 0
	Local nFatPerda    := 0
	Local nFPotencia   := Nil
	Local nInd         := 0
	Local nNecComp     := 0
	Local nPerOrig     := nPerLead
	Local nQtdBase     := 1
	Local nQtdBasePrd  := 0
	Local nQtdEstrut   := 0
	Local nTotal       := 0
	Local nTotComp     := 0
	Local oEstruturas  := ::oDados:oEstruturas

	Default cIDOpcPai  := ""
	Default cFantasma  := ""
	Default cLocal     := ""
	Default cList      := cFilAux + cProduto + Iif(!Empty(cIDOpcPai),"|"+cIDOpcPai,"") + chr(13) + cValToChar(nPeriodo)
	Default cVersao    := ""
	Default cCodPrPais := "|" + RTrim(cProduto) + "|"
	Default dLTReal    := dData
	Default lExplodiu  := .F.
	Default oRastrPais := JsonObject():New()
	Default cNivelAtu  := Nil

	If slLog19 == Nil
		slLog19 := Self:oLogs:logValido("19")
	EndIf

	If cRevisao == Nil .OR. Empty(cRevisao) .OR. cRoteiro == Nil .OR. Empty(cRoteiro)
		cRevisao   := ::revisaoProduto(cFilAux + cProduto, @cRoteiro)
	EndIf

	If Self:oMultiEmp:utilizaMultiEmpresa()
		cChaveEst := Self:oMultiEmp:getFilialTabela("T4N", cFilAux) + cProduto
	EndIf

	//Retorna array com os componentes da estrutura
	oEstruturas:getRow(1, cChaveEst,, @aComponentes)

	nTotComp := Len(aComponentes)

	If Empty(aComponentes) .And. !Empty(cFantasma) .And. Self:oMultiEmp:utilizaMultiEmpresa()
		//Produto � fantasma (!Empty(cFantasma))
		//e n�o possui estrutura (Empty(aComponentes))
		//e utiliza multi-empresa. Verifica se existe estrutura deste produto em outra filial.
		cFilEst := Self:oMultiEmp:buscaFilialEstrutura(cFilAux, cProduto)
		If !Empty(cFilEst)
			//Produto possui estrutura em outra filial. Busca os componentes.
			//Monta a chave da estrutura com a filial onde o produto fantasma possui estrutura e retorna os componentes.
			cChaveEst := Self:oMultiEmp:getFilialTabela("T4N", cFilEst) + cProduto
			oEstruturas:getRow(1, cChaveEst,, @aComponentes)

			//Gera log do processamento
			If Self:oLogs:logValido("28")
				::oLogs:log(I18N(STR0185, {cFilAux, cFilEst, RTrim(cProduto), RTrim(cFantasma)}), "28") //"Produto fantasma sem estrutura na filial '#1[FILIAL1]#'. Utilizando estrutura do produto fantasma da filial '#2[FILIAL2]#'. Produto fantasma: '#3[PRODFANT]#'. Produto PAI: '#4[PRODPAI]#'."
			EndIf
		EndIf
	EndIf

	If !Empty(aComponentes)
		If aBaixaPorOP != Nil
			nTotal     := Len(aBaixaPorOP)
			For nInd := 1 to nTotal
				lError := .F.
				cChave := aBaixaPorOP[nInd][ABAIXA_POS_CHAVE]
				aAux   := ::oRastreio:oDados_Rastreio:oDados:getItemAList(cList, cChave, @lError)
				If !lError .And. oRastrPais[cChave] == Nil
					oRastrPais[cChave] := aClone(aAux)
				EndIf
			Next
		EndIf
		nQtdBasePrd := ::oDados:retornaCampo("PRD", 1, cFilAux + cProduto, "PRD_QB", @lError, .F., , /*lProximo*/, , , .F. /*lVarios*/)

		//Percorre os componentes da estrutura
		nTotal := Len(aComponentes)
		For nInd := 1 to nTotal
			cComponente := aComponentes[nInd][::oDados:posicaoCampo("EST_CODFIL")]
			nQtdEstrut  := aComponentes[nInd][::oDados:posicaoCampo("EST_QTD")]
			nNecComp    := nQtdEstrut
			cTRT        := aComponentes[nInd][::oDados:posicaoCampo("EST_TRT")]
			dDtIniCmp   := aComponentes[nInd][::oDados:posicaoCampo("EST_VLDINI")]
			dDtFimCmp   := aComponentes[nInd][::oDados:posicaoCampo("EST_VLDFIM")]
			cRevIniCmp  := aComponentes[nInd][::oDados:posicaoCampo("EST_REVINI")]
			cRevFimCmp  := aComponentes[nInd][::oDados:posicaoCampo("EST_REVFIM")]
			cRegra      := aComponentes[nInd][::oDados:posicaoCampo("EST_ALTERN")]
			lQtdFixa    := IIf(aComponentes[nInd][::oDados:posicaoCampo("EST_FIXA")] == '1', .T., .F. )
			nFatPerda   := aComponentes[nInd][::oDados:posicaoCampo("EST_PERDA")]
			nQtdBase    := Iif(nQtdBasePrd != Nil, nQtdBasePrd, aComponentes[nInd][::oDados:posicaoCampo("EST_QTDB")])
			aSize(aOperacoes, 0)
			aOperacoes  := aComponentes[nInd][::oDados:posicaoCampo("EST_OPERA")]
			cBloqueio   := ""
			nAgluPRD    := 0
			dData       := dDataOrig
			nPerLead    := nPerOrig

			//Verifica se a revis�o do componente est� v�lida de acordo com a revis�o atual do produto PAI.
			If cRevIniCmp > cRevisao .Or. cRevFimCmp < cRevisao
				Loop
			EndIf

			//Desconsidera opcionais desselecionados
			cOpcGrp  := aComponentes[nInd][::oDados:posicaoCampo("EST_GRPOPC")]
			cOpcItem := aComponentes[nInd][::oDados:posicaoCampo("EST_ITEOPC")]
			If !Empty(cOpcGrp) .AND. !::oOpcionais:selecionado(cIDOpcPai, cOpcGrp, cOpcItem)
				Loop
			EndIf

			lError := .F.
			aDadosPRD := ::oDados:retornaCampo("PRD", 1, cFilAux + cComponente, {"PRD_BLOQUE", "PRD_AGLUT","PRD_TIPO"}, @lError, .F., , /*lProximo*/, , , .T. /*lVarios*/)
			If !lError
				cBloqueio := aDadosPRD[1]
				nAgluPRD  := aDadosPRD[2]
				cTipoProd := aDadosPRD[3]
				aSize(aDadosPRD, 0)
			EndIf

			If !lError .And. cBloqueio == "1"
				//Produto bloqueado.
				Loop
			EndIf

			if cTipoProd == "BN" .and. cAllocaBN == "N"
			   //Produto BN n�o gera empenho
			   Loop
			EndIf

			cIDOpc := ::oOpcionais:retornaIDComponente(cIDOpcPai, cComponente, cTRT)

			Self:avaliaAglutinaProduto(cFilAux, cComponente, @dData, @nPerLead, nAgluPRD, cIDOpc)

			//Verifica se o componente est� v�lido, de acordo com a data da necessidade.
			If !Empty(dDtIniCmp) .Or. !Empty(dDtFimCmp)
				If dDtIniCmp > dData  .Or. dDtFimCmp < dData
					Loop
				EndIf
			EndIf

			//Verifica se ir� ocorrer recursividade de estruturas
			//Produtos fantasmas, e utilizando multi-empresa.
			If "|" + RTrim(cComponente) + "|" $ cCodPrPais
				Self:interrompeCalculo(STR0186 + CHR(10) + I18N(STR0187, {RTrim(cComponente), cCodPrPais})) //"ESTRUTURA COM RECURSIVIDADE! Verifique o cadastro das estruturas." # "Explodindo necessidade para o componente '#1[COMP]#'. Chave dos produtos pais: #2[CHAVE]#"
			EndIf

			nNecComp := Self:ajustarNecessidadeExplosao(cFilAux, cComponente, nNecPai, nNecComp, lQtdFixa, @nFPotencia, aComponentes[nInd][::oDados:posicaoCampo("EST_POTEN")], nFatPerda, nQtdBase)
			If nNecComp != 0
				//Avalia produto fantasma
				If aComponentes[nInd][::oDados:posicaoCampo("EST_FANT")]
					::oFantasma:processaFantasma(cFilAux, cProduto, cComponente, nNecComp, nPerLead, cIDOpc, aClone(aBaixaPorOP), cList, @oRastrPais, Iif(Empty(cFantasma), cProduto, cFantasma), @lExplodiu, dLTReal, cCodPrPais)

				Else
					lExplodiu := .T.

					If slLog19
						::oLogs:log(STR0017 + AllTrim(cComponente) + STR0018 + cValToChar(nPerLead) + STR0019 + cValToChar(nNecComp), "19") //"Saida estrutura :" + " - Periodo: " + " - nNecess: "
					EndIf

					Self:oSeletivos:setaProdutoValido(cComponente)

					//Faz o Lock
					::oDados:oMatriz:trava(DtoS(dData) + cFilAux + cComponente + Iif(!Empty(cIDOpc), "|" + cIDOpc, ""))

					If aBaixaPorOP != Nil
						::oRastreio:inclusoesNecessidade(cFilAux, aBaixaPorOP, cComponente, cIDOpc, cTRT, nQtdEstrut, ;
						                                 nPerLead, cRegra, @nNecComp, cRevisao, cRoteiro, , ;
						                                 @oRastrPais, lQtdFixa, nFPotencia, nFatPerda, ;
						                                 Iif(Empty(cFantasma), cProduto, cFantasma), cVersao, ;
						                                 !Empty(cFantasma), aOperacoes, dLTReal, nQtdBase)
					EndIf

					::oDados:gravaSaidaEstrutura(cFilAux, dData, cComponente, nNecComp, nPerLead, cIDOpc, .T., .F.) //Mant�m Lock

					//Libera Lock
					::oDados:oMatriz:destrava(DtoS(dData) + cFilAux + cComponente + Iif(!Empty(cIDOpc), "|" + cIDOpc, ""))

				EndIf
			EndIf
		Next

		If aBaixaPorOP != Nil
			nTotal     := Len(aBaixaPorOP)
			For nInd := 1 to nTotal
				lError := .F.
				cChave := aBaixaPorOP[nInd][ABAIXA_POS_CHAVE]
				If oRastrPais[cChave] != Nil .AND. lUpdRstPai .AND. Empty(cFantasma)
					::oRastreio:oDados_Rastreio:oDados:setItemAList(cList, cChave, oRastrPais[cChave], @lError)
					aSize(oRastrPais[cChave], 0)
					oRastrPais[cChave] := Nil
				EndIf
			Next
		EndIf

		aSize(aComponentes, 0)
	ElseIf !Empty(cFantasma) .And. Self:oLogs:logValido("28")
		::oLogs:log(I18N(STR0188, {cFilAux, RTrim(cProduto), RTrim(cFantasma), RTrim(cChaveEst)}), "28") //"Produto fantasma sem estrutura. Filial '#1[FILIAL1]#'. Produto fantasma: '#2[PRODFANT]#'. Produto PAI: '#3[PRODPAI]#'. Chave estrutura: '#4[CHAVE]#'"
	EndIf

	If (nTotComp > 0 .And. !lExplodiu) .Or. (nTotComp <= 0  .And. !Empty(cNivelAtu) .And. cNivelAtu <> '99')
		//Se possui estrutura, mas nenhum componente est� v�lido, ir� marcar flag para identificar o produto neste per�odo como n�vel 99.
		cChave := "PRD_NIV_99_"
		cChave += DtoS(Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cFilAux + cProduto + Iif(!Empty(cIDOpcPai),"|"+cIDOpcPai,"")

		lError := .F.
		Self:oDados:oMatriz:setFlag(cChave, .T., @lError, .F., .F., .F.)
	EndIf

	::oDados:setaArea(aAreaPRD)
	aSize(aAreaPRD, 0)

	::oDados:setaArea(aAreaMAT)
	aSize(aAreaMAT, 0)
	If Empty(cFantasma)
		::oDados:gravaCampo("MAT", 1, DtoS(Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cProduto, "MAT_EXPLOD", .T.)
	EndIf

Return lReturn

/*/{Protheus.doc} ajustarNecessidadeExplosao
Ajusta a Necessidade da Explosao de Estrutura do Componente com Base na Necessidade do Produto Pai, Fator, Perda, Qtd.Fixa, ente outros.
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01, cFilAux    , caracter, codigo da filial para processamento
@param 02, cComponente, caracter, codigo do componente
@param 03, nNecPai    , numero  , quantidade da necessidade do produto pai
@param 04, nNecComp   , numero  , quantidade do componente na estrutura do produto pai
@param 05, lQtdFixa   , logico  , indica se o componente utiliza a quantidade fixa
@param 06, nFPotencia , numero  , fator de potencia do componente para aplicacao
@param 07, nFPotEstru , numero  , fator de potencia do componente na estrutura do produto pai
@param 08, nFatPerda  , numero  , fator de perda do componente na estrutura do produto pai
@param 09, nQtdBase   , numero  , quantidade base da estrutura.
@return nNecComp, numero, necessidade do componente apos ajustes de necessiade na explosao da estrutura
/*/
METHOD ajustarNecessidadeExplosao(cFilAux, cComponente, nNecPai, nNecComp, lQtdFixa, nFPotencia, nFPotEstru, nFatPerda, nQtdBase) CLASS MrpDominio

	If Self:oMOD:produtoMOD(cFilAux, cComponente, Self:oDados)
		nNecComp := Self:oMOD:converteQuantidadeMOD(nNecComp, nNecPai, lQtdFixa, Self:oParametros)
	ElseIf !lQtdFixa
		nNecComp := nNecComp * nNecPai
	EndIf

	//Aplica a quantidade base de estrutura.
	If !lQtdFixa .And. nQtdBase > 1
		nNecComp := nNecComp / nQtdBase
	EndIf

	nNecComp := Self:aplicarPotencia(cFilAux, cComponente, @nFPotencia, nNecComp, nFPotEstru)
	nNecComp := Self:aplicarPerda(nNecComp, nFatPerda)
	nNecComp := Self:arredondarExplosao(cFilAux, cComponente, nNecComp)

Return nNecComp

/*/{Protheus.doc} aplicarPotencia
Aplica potencia do produto
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 cFilAux   , caracter, codigo da filial para processamento
@param 02 cProduto  , caracter, codigo do produto relacionado
@param 03 nFPotencia, numero  , fator de potencia para utilizacao, retorna por referencia
@param 04 nNecComp  , numero  , necessidade do componente apos aplicacao do fator de potencia
@param 05 nFPotEstru, numero  , fator de potencia para o produto na estrutura do produto pai
@return nNecComp, numero, necessidade ap�s aplica��o do fator de potencia
/*/
METHOD aplicarPotencia(cFilAux, cProduto, nFPotencia, nNecComp, nFPotEstru) CLASS MrpDominio

	If nFPotencia == Nil .AND. Self:getUsoPotencia(cFilAux, cProduto)
		nFPotencia := nFPotEstru
	EndIf

	If nFPotencia != Nil .AND. nFPotencia > 0
		nNecComp := nNecComp * (nFPotencia/100)
	EndIf

Return nNecComp

/*/{Protheus.doc} aplicarPerda
Aplica perda do produto
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 nNecComp , numero, necessidade original do componente
@param 02 nFatPerda, numero, fator de perda para aplica��o
@return nNecComp, numero, necessidade ap�s aplica��o do fator de perda
/*/
METHOD aplicarPerda(nNecComp, nFatPerda) CLASS MrpDominio
	If nFatPerda > 0
		nNecComp := (nNecComp/(100-nFatPerda))*100
	EndIf
Return nNecComp



/*/{Protheus.doc} periodoMaxComponentes
Altera o periodo maximo de calculo dos componentes do produto para nPeriodo
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux , caracter, c�digo da filial para processamento
@param 02 - cProduto, caracter, codigo do produto pai
@param 03 - nPeriodo, numero  , periodo maximo a ser atualizado nos componentes
@return lReturn, logico, indica se o produto possui estrutura
/*/
METHOD periodoMaxComponentes(cFilAux, cProduto, nPeriodo) CLASS MrpDominio
	Local aAreaPRD     := Nil
	Local aComponentes := {}
	Local aPendencias  := {}
	Local cComponente  := ""
	Local cChaveEst    := cProduto
	Local cChaveComp   := ""
	Local lError       := .F.
	Local lExecuta
	Local lReturn      := .T.
	Local nMenorPerio
	Local nIndAux      := 0
	Local nIndComp
	Local nPos         := 0
	Local nPerMaxCmp   := -1
	Local nPerInicio
	Local oPendencias  := ::oDados:oPendencias
	Local oEstruturas  := ::oDados:oEstruturas

	aAreaPRD     := ::oDados:retornaArea("PRD")

	If Self:oMultiEmp:utilizaMultiEmpresa()
		cChaveEst := Self:oMultiEmp:getFilialTabela("T4N", cFilAux) + cProduto
	EndIf

	//Retorna array com os componentes da estrutura
	oEstruturas:getRow(1, cChaveEst,, @aComponentes)

	If !Empty(aComponentes)
		aAreaMAT    := ::oDados:retornaArea("MAT")

		//Percorre componentes da estrutura
		For nIndComp := 1 to Len(aComponentes)
			cComponente := aComponentes[nIndComp][::oDados:posicaoCampo("EST_CODFIL")]
			cChaveComp  := cFilAux + cComponente
			oPendencias:trava(cChaveComp)

			//Recupera array de pendencias pai deste componente
			aPendencias := ::oDados:retornaLinha("PEN", 1, cChaveComp, @lError, .T.)
			lExecuta    := .T.
			If lError .And. nPeriodo == -1
				lExecuta := .F.
			ElseIf lError
				aPendencias := {}
			EndIf

			If lExecuta
				//Grava periodo maximo array
				nPos := aScan(aPendencias, {|x| AllTrim(x[1]) == AllTriM(cProduto) })
				If nPos > 0
					aPendencias[nPos][2] := nPeriodo
				Else
					aAdd(aPendencias, {cProduto, nPeriodo})
				EndIf
				::oDados:gravaLinha("PEN", 1, cChaveComp, aPendencias, @lError, .T.)

				//Avalia array e grava menor periodo na PRD
				For nIndAux := 1 to Len(aPendencias)
					If aPendencias[nIndAux][2] != -1
						If nMenorPerio == Nil .Or. aPendencias[nIndAux][2] < nMenorPerio
							nMenorPerio := aPendencias[nIndAux][2]
						EndIf
					EndIf
				Next
				If nMenorPerio == Nil
					nMenorPerio := -1
				EndIf

				//Grava periodo maximo
				nPerMaxCmp := ::oDados:retornaCampo("PRD", 1, cChaveComp, "PRD_NPERMA" , @lError)
				If nPerMaxCmp != nMenorPerio
					If ::oDados:reservaProduto(cChaveComp, @nPerInicio, @nPerMaxCmp);
						.And. nPerMaxCmp != nMenorPerio
						::oDados:gravaCampo("PRD", 1, cChaveComp, "PRD_NPERMA", nPerMaxCmp, .T.)
					EndIf
					::oDados:liberaProduto(cChaveComp)

				EndIf
			EndIf
			oPendencias:destrava(cChaveComp)
		Next
	EndIf

	::oDados:setaArea(aAreaPRD)

Return lReturn

/*/{Protheus.doc} checarFimLoop
Identifica se deve finalizar o loopNiveis
@author    brunno.costa
@since     25/04/2019
@version 1.0
@return lReturn, logico, indica se pode finalizar o loopNiveis, nao existem pendencias
/*/
METHOD checarFimLoop(nInexistLoop, cNivelAtu) CLASS MrpDominio
	Local lReturn     := .T.
	Local lLog        := Self:oLogs:logValido("1")
	Local nProdutos   := 0
	Local nProdutosOk := 0
	Local oProdutos   := ::oDados:oProdutos

	nProdutos   := oProdutos:getflag("nProdutosT")
	nProdutosOk := oProdutos:getflag("nProdCalcT") + nInexistLoop

	If lLog
		::oLogs:log(STR0012 + " " + STR0008 + "("+cValToChar(nProdutos)+") x " + STR0013 + "("+cValToChar(nProdutosOk)+") - " + STR0014 + cNivelAtu, "1") //"Analise reinicio do loop de niveis" + "Total Produtos" + "Total lProdutos Ok" + "Nivel Atual: "
	EndIf

	//Limpa variaveis de controle do loop
	oProdutos:setflag("nProdCalcT", 0, .F., .F.)
	nInexistLoop := 0

	If nProdutos != nProdutosOk
		lReturn := .F.
	EndIf

	If lReturn
		oProdutos:setflag("cNivMin", "00", .F., .F.)
		If lLog
			::oLogs:log(STR0012 + STR0020 + oProdutos:getflag("cNivMin", .F., .F.), "1") //"Analise reinicio do loop de niveis" + " - retorno true - Nivel minimo: "
		EndIf
	ElseIf lLog
		If oProdutos:getflag("cNivMin", .F., .F.) != "00"
			::oLogs:log(STR0012 + STR0021 + oProdutos:getflag("cNivMin", .F., .F.), "1") //"Analise reinicio do loop de niveis" + "- retorno false - Nivel minimo: "
		Else
			::oLogs:log(STR0012 + STR0021 + oProdutos:getflag("cNivMin", .F., .F.) + " " +;
			            STR0008 + "("+cValToChar(nProdutos)+") != " + STR0013 + "("+cValToChar(nProdutosOk)+")", "1") //"Analise reinicio do loop de niveis" + "- retorno false - Nivel minimo: " + "Total Produtos" + "Total Produtos Ok"
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} destruir
Funcao responsavel por destruir os objetos e finalizar threads
@author    brunno.costa
@since     25/04/2019
@version 1.0
/*/
METHOD destruir() CLASS MrpDominio
	Local cTicket   := ::oParametros["ticket"]
	Local lEventLog := Self:oEventos:lHabilitado
	Local oStatus   := MrpDados_Status():New(cTicket)

	Sleep(1000)
	If oStatus:getStatus("calculo") != '1'
		Sleep(10000) //Aguarda termino PCPIPCGO
	EndIf

	//Destroi objeto da camada de dados
	::oDados:destruir(.T.)

	Self:oLogs:log('************************************************** MrpDominio -> Fecha Threads', "R")

	//Finaliza as Threads de processamento
	PCPIPCFinish(::oParametros["cSemaforoThreads"], 100, ::oParametros["nThreads"])

	Sleep(1000)
	//Finaliza as Threads de exporta��o
	PCPIPCFinish(::oParametros["cSemaforoThreads"] + "MAT", 100, ::oParametros["nThreads_MAT"])

	Sleep(1000)
	PCPIPCFinish(::oParametros["cSemaforoThreads"] + "AGL", 100, ::oParametros["nThreads_AGL"])
	If lEventLog
		Sleep(1000)
		PCPIPCFinish(::oParametros["cSemaforoThreads"] + "EVT", 100, ::oParametros["nThreads_EVT"])
	EndIf
	ClearGlbValue('THREAD_MASTER_'+cTicket)
Return

/*/{Protheus.doc} aguardaProcesso
Aguarda o t�rmino do processamento do LoopNiveis.
Somente retorna true quando o processo das threads filhas estiver finalizado.

@author    lucas.franca
@since     04/07/2019
@version 1.0
@return lExit, logico, indica que o processamento foi finalizado
/*/
METHOD aguardaProcesso(lFimPrd, cNivelAtu, cNivelAnt, nInexistente, nInxstLoop, nReinicios, nDistrib, nIgnorados) CLASS MrpDominio
	Local cNewNiv      := ""
	Local cNivAux      := ""
	Local cProduto     := ""
	Local lExit        := .F.
	Local lLog1        := Self:oLogs:logValido("1")
	Local nThreads     := ::oParametros["nThreads"]
	Local nAux         := 0
	Local nProcess     := 0
	Local nProdutoNX   := 0
	Local nProdutoTX   := 0
	Local nProcessNv   := 0
	Local nTentativa   := 0
	Local nJobLiveLock := 0
	Local oDados       := ::oDados
	Local oProdutos    := oDados:oProdutos
	Local oMatriz      := oDados:oMatriz
	Local oStatus      := MrpDados_Status():New(oDados:oParametros["ticket"])

	//Incrementa inexistentes
	oProdutos:setflag("nProdCalcN" + cNivelAnt, nInexistente, .F., .F., .T.)
	oProdutos:setflag("nProcessNv"            , nInexistente, .F., .F., .T.)
	oProdutos:setflag("nProcess"              , nInexistente, .F., .F., .T.)

	If Self:oLogs:logValido("42")
		::oLogs:log(STR0102 + cNivelAnt + STR0103 + cValTOChar(nInexistente), "42") //"Incremento nProcessNv no nivel " 'XX' ", inexistentes "
	EndIf

	nInexistente := 0

	//Ao trocar de nivel, aguarda finalizar todas as Threads do nivel anterior
	If ::oParametros["lPorNivel"] .AND. nThreads > 0
		While IPCCount(::oParametros["cSemaforoThreads"]) < nThreads .And. oStatus:getStatus("status") != "4"
			nTentativa++
			If nTentativa > 1000
				If lLog1
					::oLogs:log(STR0146 + "IPCCount(::oParametros[cSemaforoThreads]) < nThreads : " + cValToChar(IPCCount(::oParametros["cSemaforoThreads"])) + " <  " + cValToChar(nThreads), "1") //"Falha Aguardando Troca de Nivel - 1000 tentativas - "
				EndIf
				Exit
			EndIf
			Sleep(500)
		EndDo
		nTentativa := 0

		nProdutoNX := oProdutos:getflag("nProdutosN" + cNivelAnt)
		nProcessNv := oProdutos:getflag("nProcessNv")
		While nProcessNv < nProdutoNX
			nTentativa++
			If nTentativa > 10
				If lLog1
					::oLogs:log(STR0004 + "(" + cValToChar(nProcessNv)+") < " + STR0005 + "("+cValToChar(nProdutoNX)+")", "1") //"Aguardando troca de nivel - Falha 10 tentativas: Produtos Ok no Nivel" + "Produtos nivel"
				EndIf
				Exit
			EndIf
			Sleep(50)
			nProcessNv  := oProdutos:getflag("nProcessNv")
		EndDo
		nTentativa := 0
		oProdutos:setflag("nProcessNv", 0, .F., .F.)

	//Ao executar todos os niveis, aguarda finalizar todas as Threads, exceto thread de LiveLock
	ElseIf lFimPrd
		If nThreads > 0
			//nJobLiveLock := oLiveLock:getflag("nJobLiveLock")
			//While (IPCCount(::oParametros["cSemaforoThreads"]) + nJobLiveLock) < nThreads
			nTentativa := 0
			While IPCCount(::oParametros["cSemaforoThreads"]) < nThreads
				nTentativa++
				If nTentativa > 1000
					If lLog1
						::oLogs:log(STR0146 + "IPCCount(::oParametros[cSemaforoThreads]) < nThreads : " + cValToChar(IPCCount(::oParametros["cSemaforoThreads"])) + " <  " + cValToChar(nThreads), "1") //"Falha Aguardando Troca de Nivel - 1000 tentativas - "
					EndIf
					Exit
				EndIf
				nAux := 50
				Sleep(nAux)
			EndDo
		Endif

		nProdutoTX := oProdutos:getflag("nProdutosT")
		nProcess   := oProdutos:getflag("nProcess")
		While oProdutos:getflag("nProcess") < nProdutoTX
			nTentativa++
			If nTentativa > 10
				If lLog1
					::oLogs:log(STR0007 + "("+cValToChar(nProcess)+") < " + STR0008 + "("+cValToChar(nProdutoTX)+")", "1") //"Aguardando troca de nivel - Falha 10 tentativas: Total Produtos Ok" + "Total Produtos"
				EndIf
				Exit
			EndIf
			Sleep(50)
			nProcess := oProdutos:getflag("nProcess")
		EndDo
		nTentativa := 0
		oProdutos:setflag("nProcess", 0, .F., .F.)
	EndIf

	//Seta minimo atual
	If ::oParametros["lPorNivel"]
		nProdutoNX := oProdutos:getflag("nProdutosN" + cNivelAnt)
		If nProdutoNX	== oProdutos:getflag("nProdCalcN" + cNivelAnt)
			oMatriz:trava("cNivMin")
			If oProdutos:getflag("cNivMin") == cNivelAnt
				oProdutos:setflag("cNivMin", cNivelAtu)
				If lLog1
					::oLogs:log(StrTran(StrTran(STR0010, "CNIVANT", cNivelAnt), "CNIVATU", cNivelAtu), "1") //"Troca nivel minimo atual de 'CNIVANT' para 'CNIVATU'"
				EndIf
			EndIf
			oMatriz:destrava("cNivMin")
		EndIf

	Else

		cNivAux    := oProdutos:getflag("cNivMin")
		nProdutoNX := oProdutos:getflag("nProdutosN" + cNivAux)
		If nProdutoNX	== oProdutos:getflag("nProdCalcN" + cNivAux)
			oMatriz:trava("cNivMin")
			For nAux := Val(cNivAux)+1 to 99
				cNewNiv   := PadL(cValToChar(nAux), 2, "0")
				If oProdutos:getflag("nProdCalcN"  + cNewNiv) != Nil
					Exit
				EndIf
			Next
			oProdutos:setflag("cNivMin", cNewNiv)
			If lLog1
				::oLogs:log(StrTran(StrTran(STR0010, "CNIVANT", cNivelAnt), "CNIVATU", cNivelAtu), "1") //"Troca nivel minimo atual de 'CNIVANT' para 'CNIVATU'"
			EndIf
			oMatriz:destrava("cNivMin")
		EndIf
	EndIf

	If lFimPrd  //EOF
		If nThreads > 0
			//Ao executar todos os niveis, aguarda finalizar todas as Threads
			nTentativa := 0
			While IPCCount(::oParametros["cSemaforoThreads"]) < nThreads .And. oStatus:getStatus("status") != "4"
				nTentativa++
				If nTentativa > 1000
					If lLog1
						::oLogs:log(STR0146 + "IPCCount(::oParametros[cSemaforoThreads]) < nThreads : " + cValToChar(IPCCount(::oParametros["cSemaforoThreads"])) + " <  " + cValToChar(nThreads), "1") //"Falha Aguardando Troca de Nivel - 1000 tentativas - "
					EndIf
					Exit
				EndIf
				Sleep(50)
			EndDo
		Endif

		//Analisa necessidade de reinicio do loop
		oMatriz:trava("cNivMin")
		cNivelAtu := oProdutos:getflag("cNivMin", .F., .F.)
		cProduto  := oProdutos:getflag("cPriNivel" + cNivelAtu, .F., .F.)
		If nJobLiveLock == 0 .AND. ::checarFimLoop(@nInxstLoop, cNivelAtu) //Finaliza
			oProdutos:setflag("cNivMin", "00", .F., .F.)
			oMatriz:destrava("cNivMin")
			If lLog1
				::oLogs:log("**************************************************", "1")
				::oLogs:log(STR0015, "1") //"Termino execucao do loop de niveis"
			EndIf
			If Self:oLogs:logValido("L")
				::oLogs:log(STR0066 + cValToChar(nReinicios), "L") //"Reinicios do loop de calculo: "
				::oLogs:log(STR0067 + cValToChar(nDistrib)  , "L") //"Distribuicoes de demanda para calculo da necessidade dos produtos: "
				::oLogs:log(STR0068 + cValToChar(nIgnorados), "L") //"Checagens de produtos sem pendencias / ignorados: "
			EndIf
			If lLog1
				::oLogs:log("**************************************************", "1")
			EndIf
			lExit := .T.

		Else                 //Reinicia
			nReinicios++
			cProduto  := oProdutos:getflag("cPriNivel01", .F., .F.)
			If lLog1
				::oLogs:log("**************************************************", "1")
				::oLogs:log(STR0016 + AllTrim(cProduto) + " - " + Time(), "1") //"Reiniciando o loop no produto: "
				::oLogs:log(STR0066 + cValToChar(nReinicios)            , "1") //"Reinicios do loop de calculo: "
				::oLogs:log(STR0067 + cValToChar(nDistrib)              , "1") //"Distribuicoes de demanda para calculo da necessidade dos produtos: "
				::oLogs:log(STR0068 + cValToChar(nIgnorados)            , "1") //"Checagens de produtos sem pendencias / ignorados: "
				::oLogs:log("**************************************************", "1")
			EndIf

			oProdutos:setflag("cNivMin", "01", .F., .F.)
			oMatriz:destrava("cNivMin")

		EndIf
		nJobLiveLock := 0
	EndIf

Return lExit

/*/{Protheus.doc} registraProcessados
Funcao respons�vel por atualizar os status dos registros que foram processados
@author    marcelo.neumann
@since     08/07/2019
@version 1.0
/*/
METHOD registraProcessados() CLASS MrpDominio

	::oDados:oCargaMemoria:registraProcessados()

Return

/*/{Protheus.doc} arredondarExplosao
Faz o arredondamento da quantidade de explos�o da estrutura de acordo com os par�metros do produto.

@author    lucas.franca
@since     14/10/2019
@version 1.0
@param cFilAux , Character, C�digo da filial para processamento
@param cCompon , Character, C�digo do produto que est� sendo calculada a necessidade
@param nQtdOrig, Numeric  , Quantidade original calculada durante a explos�o.
@return nQuant , Numeric  , Quantidade arredondada.
/*/
METHOD arredondarExplosao(cFilAux, cCompon, nNecess) CLASS MrpDominio
	Local aAreaPRD   := {}
	Local aDados     := {}
	Local cNum       := ""
	Local cChaveProd := cFilAux + cCompon
	Local nQuant     := nNecess
	Local nDecimal   := 0
	Local nDif       := 0
	Local lAtual     := cChaveProd == ::oDados:oProdutos:cCurrentKey
	Local lError     := .F.

	If !lAtual
		aAreaPRD := ::oDados:retornaArea("PRD")
	EndIf

	aDados := ::oDados:retornaCampo("PRD", 1, cChaveProd, {"PRD_TIPDEC","PRD_NUMDEC"}, @lError, lAtual, , /*lProximo*/, , , .T. /*lVarios*/)

	If !lError
		Do Case
			Case aDados[1] == 1 //Normal
				//Arredonda de acordo com a qtd. de decimais da estrutura.
				nQuant := Round(nQuant, ::oParametros["nStructurePrecision"])
			Case aDados[1] == 2 //Arredonda
				//Se os decimais forem >= a 5, arredonda para cima. Caso contr�rio, arredonda para baixo.
				nQuant := Round(nQuant, aDados[2])
			Case aDados[1] == 3 //Incrementa
				//Se houver qualquer quantidade decimal, ir� arredondar para cima.
				nDecimal := nQuant - Int(nQuant)
				nQuant   := Int(nQuant)
				If nDecimal <> 0
					If aDados[2] > 0
						//Se utiliza casas decimais, ir� incrementar na qtd. decimal.
						nDif     := nDecimal - NoRound(nDecimal, aDados[2])
						nDecimal := NoRound(nDecimal, aDados[2])
						If nDif <> 0
							cNum := "0." + StrZero(1, aDados[2])
							nDecimal += Val(cNum)
							nQuant   += nDecimal
						Else
							//Se nDif for igual a 0, todos os decimais devem ser considerados sem fazer incremento.
							nQuant += nDecimal
						EndIf
					Else
						//N�o utiliza decimais, ir� incrementar a quantidade inteira.
						nQuant++
					EndIf
				EndIf
			Case aDados[1] == 4 //Trunca
				//Desconsidera os decimais, sem fazer arredondamento p/ cima.
				nDecimal := nQuant - Int(nQuant)
				nQuant := Int(nQuant)
				If aDados[2] > 0
					nQuant += NoRound(nDecimal, aDados[2])
				EndIf
		EndCase
		aSize(aDados  , 0)
	EndIf

	If !lAtual
		::oDados:setaArea(aAreaPRD)
		aSize(aAreaPRD, 0)
	EndIf

Return nQuant

/*/{Protheus.doc} agrupaRevisoes
Funcao respons�vel por atualizar os status dos registros que foram processados
@author    brunno.costa
@since     16/10/2019
@version 1.0
@param 01 - cFilAux    , caracter, codigo da filial
@param 02 - cProduto   , caracter, codigo do produto
@param 03 - nPeriodo   , numero  , periodo referencia
@param 04 - aBaixaPorOP, array   , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Id Rastreabilidade,;
								     2 - Documento Pai,;
								     3 - Quantidade Necessidade,;
								     4 - Quantidade Estoque,;
								     5 - Quantidade Baixa Estoque,;
								     6 - Quantidade Substitui��o},...}
@return aRevisoes, Array, array com os dados agrupados por revis�o:
                {cRevisao           ,
				 cRoteiro           ,
				 cLocal             ,
				 nQtde Total Revis�o,
				 aBaixaPorOP        }
/*/
METHOD agrupaRevisoes(cFilAux, cProduto, nPeriodo, aBaixaPorOP) CLASS MrpDominio

	Local aRevisoes   := {}
	Local aNames      := {}
	Local aVersao     := {}
	Local cRotPad     := ""
	Local cRevPad     := ::revisaoProduto(cProduto, @cRotPad)
	Local cRevisao    := ""
	Local nInd        := 0
	Local nNecess     := 0
	Local nTotal      := Len(aBaixaPorOP)
	Local oRevisoes   := Iif(nTotal > 0, JsonObject():New(), Nil)
	Local nPosRevisao := ::oVersaoDaProducao:getPosicao("REVISAO", "aVersao")
	Local nPosRoteiro := ::oVersaoDaProducao:getPosicao("ROTEIRO", "aVersao")
	Local nPosLocal   := ::oVersaoDaProducao:getPosicao("LOCAL"  , "aVersao")
	Local nPosCodigo  := ::oVersaoDaProducao:getPosicao("CODIGO" , "aVersao")
	Local lVersao     := ::oVersaoDaProducao:possui(cProduto)

	For nInd := 1 to nTotal
		//Identifica a Vers�o da Produ��o
		nNecess := aBaixaPorOP[nInd][ABAIXA_POS_NECESSIDADE]

		If aBaixaPorOP[nInd][ABAIXA_POS_QTD_SUBSTITUICAO] > 0
			nNecess -= aBaixaPorOP[nInd][ABAIXA_POS_QTD_SUBSTITUICAO]
		EndIf

		If lVersao
			aVersao := ::oVersaoDaProducao:identifica(cProduto, nNecess, Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo))
		EndIf

		If !lVersao .OR. Empty(aVersao) .OR. Empty(aVersao[nPosRevisao])
			cRevisao := cRevPad
			aVersao  := {cRevPad,;
						cRotPad,; //TODO - Revisar regra do roteiro
						"",""}       //TODO - Inserir regra de local padr�o
		Else
			cRevisao := aVersao[nPosRevisao]
			aVersao := {cRevisao,;
						aVersao[nPosRoteiro],;
						aVersao[nPosLocal],;
						aVersao[nPosCodigo]}
		EndIf

		//Agrupa resultados em objeto JSON
		If oRevisoes[cRevisao] == Nil
			oRevisoes[cRevisao]    := {aVersao[nPosRevisao],;
									   aVersao[nPosRoteiro],;
									   aVersao[nPosLocal]  ,;
									   nNecess             ,;
									   {aBaixaPorOP[nInd]} ,;
									   aVersao[nPosCodigo]}
			aSize(aVersao, 0)
		Else
			oRevisoes[cRevisao][AREVISOES_POS_QTDE_TOTAL] += nNecess
			aAdd(oRevisoes[cRevisao][AREVISOES_POS_aBaixaPorOP], aBaixaPorOP[nInd])

		EndIf
	Next

	If nTotal == 0
		aAdd(aRevisoes, {cRevPad,;
						 cRotPad,;           //TODO - Revisar regra do roteiro
						 ""      ,;          //TODO - Inserir regra de local padr�o
						 nNecess ,;
						 {}      ,;
						 ""      })
	Else
		//Converte Json em Array de Retorno
		aNames := oRevisoes:GetNames()
		nTotal := Len(aNames)
		For nInd := 1 to nTotal
			cRevisao := aNames[nInd]
			aAdd(aRevisoes, oRevisoes[cRevisao])
		Next

		aSize(aNames, 0)
		aNames := Nil

		FreeObj(oRevisoes)
	EndIf

	//Limpa array ::aVersoes da Mem�ria
	::oVersaoDaProducao:limpaMemoria()

Return aRevisoes

/*/{Protheus.doc} calcularLotes
Calcula os lotes do produto

@author    lucas.franca
@since     22/10/2019
@version 1.0
@param 01 - cProduto   , caracter, chave do produto (filial+produto)
@param 02 - nNecess    , numero  , necessidade do produto
@param 03 - nQtdLotes  , numero  , retorna por refer�ncia a qtd. sumarizada dos lotes.
@param 04 - nPeriodo   , numero  , per�odo onde a demanda est� sendo calculada.
@param 05 - cFilAux    , caracter, c�digo da filial
@return aQtd, Array, Array com as quantidades de necessidade do produto
/*/
METHOD calcularLotes(cProduto, nNecess, nQtdLotes, nPeriodo, cFilAux) CLASS MrpDominio
	Local aDadosPrd  := {}
	Local aAreaPRD   := {}
	Local aQtd       := {}
	Local cNivel     := ""
	Local dDtPeriodo := NIL
	Local lAtual     := cProduto == ::oDados:oProdutos:cCurrentKey
	Local lLimitQbra := Val(Self:oParametros["limiteQuebraLE"])
	Local lUsaEmbal  := Self:oParametros["lPackingQuantityFirst"]
	Local lUsaLtMin  := Self:oParametros["lBreakByMinimunLot"]
	Local lPerQuebra := .T.
	Local lQuebra    := .F.
	Local nIndex     := 0
	Local nTotal     := 0
	Local nLE        := 0
	Local nQE        := 0
	Local nToler     := 0
	Local nTolerPrd  := 0
	Local nLoteMin   := 0
	Local nQtdUlt    := 0
	Local nQtdQuebra := 0
	Local nRestoDiv  := 0


	If nNecess > 0
		//Busca as informa��es do Produto.
		If !lAtual
			aAreaPRD := Self:oDados:retornaArea("PRD")
		EndIf

		aDadosPrd := Self:oDados:retornaCampo("PRD", 1, cProduto, {"PRD_LE", "PRD_QTEMB", "PRD_LM", "PRD_TOLER", "PRD_NIVEST"}, , lAtual, , /*lProximo*/, , , .T. /*lVarios*/)

		If !lAtual
			Self:oDados:setaArea(aAreaPRD)
		EndIf

		nLE       := aDadosPrd[1] //Lote econ�mico
		nQE       := aDadosPrd[2] //Quantidade embalagem
		nLoteMin  := aDadosPrd[3] //Lote M�nimo
		nTolerPrd := aDadosPrd[4] //Toler�ncia
		cNivel    := aDadosPrd[5] //N�vel do produto

		//Verifica se o lote deve ser quebrado, ou se deve ser somado.
		If cNivel == "99"
			lQuebra  := Self:oParametros["lPurchaseRequestPerLot"]
			//Para n�o processar todo o lote
			If !lQuebra .And. nLe > 0 .And. nNecess <= nLe
				nNecess := nLe
			EndIf

			nLoteMin := nQE //N�vel 99, utiliza como lote m�nimo a QTD DE EMBALAGEM.
		Else
			lQuebra  := Self:oParametros["lProductionOrderPerLot"]
		EndIf

		//Verifica se o Lote Econ�mico deve ser substitu�do pelo lote m�nimo
		If nLE == 0 .And. nLoteMin > 0 .And. Self:oParametros["lMinimunLotAsEconomicLot"]
			nLE := nLoteMin
		Endif

		nToler 	   := ( nLE * nTolerPrd ) / 100
		//Calcula o numero de quebras realizadas.
		If lQuebra .And. cNivel != "99" .And. nLe > 0

			nRestoDiv := nNecess % nLE
			nQtdQuebra := Round((nNecess / nLE ), 0)

			If nRestoDiv > nToler
				nQtdQuebra += 1
			endIf

			//Valida o limite para quebra de demanda.
			If lLimitQbra > 0 .And.	nQtdQuebra >= lLimitQbra
				//Define que n�o vai processar a quebra.
				lPerQuebra := .F.

				//Gera log de eventos.
				dDtPeriodo := soDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
				//Inclui o evento for�ado.
				soDominio:oEventos:loga("010", cProduto, dDtPeriodo ,{ dDtPeriodo, nQtdQuebra },cFilAux, .T.)
			EndIf
		EndIf

		If lPerQuebra .And. nLE > 0
			// Tenta Lote Minimo e apos isso Lote Economico

			If lUsaEmbal .And. nNecess <= nLoteMin
				aAdd(aQtd, nLoteMin)
				nNecess := 0

			ElseIf nNecess < nLE

				If lUsaLtMin .And. nLoteMin > 0
					//Faz a quebra por lote m�nimo
					nTotal := Ceiling(nLE / nLoteMin)

					IF nTotal < 1
						nTotal := 1
					EndIf

					For nIndex := 1 To nTotal
						aAdd(aQtd, nLoteMin)
					Next nIndex
				Else
					//Necessidade menor que lote econ�mico, ir� produzir o lote econ�mico.
					aAdd(aQtd, nLE)
				EndIf
				nNecess := 0
			EndIf

			While nNecess > 0
				If nNecess < Iif(lUsaLtMin, nLoteMin, nLE) - nToler
					If nLoteMin > 0
						//Produz o lote m�nimo
						If nNecess <= nLoteMin
							aAdd(aQtd, nLoteMin)
						Else
							If nNecess > ( Round( nNecess / nLoteMin, 0) * nLoteMin )
								nQtdUlt := ( Round( nNecess / nLoteMin, 0) + 1 ) * nLoteMin
							Else
								nQtdUlt := Round( nNecess / nLoteMin, 0) * nLoteMin
							EndIf
							aAdd(aQtd, nQtdUlt)
						Endif
					Else
						//N�o possui lote m�nimo, produz o restante para fechar a qtd.
						aAdd(aQtd, nNecess)
					EndIf
				Else
					//Produz o lote m�nimo ou econ�mico, de acordo com a parametriza��o.
					If lUsaLtMin
						aAdd(aQtd, Iif(nLoteMin == 0, nNecess, nLoteMin))
					Else
						aAdd(aQtd, Iif(nLE == 0, nNecess, nLE))
					EndIf

					If nNecess <= Iif(lUsaLtMin, nLoteMin, nLE) + nToler
						nNecess := 0
					EndIf
				EndIf

				//Desconta a qtd. do lote da qtd total, e verifica se � necess�rio nova quebra (volta o loop).
				nNecess -= aQtd[Len(aQtd)]
			End
		Else
			//N�o possui lote econ�mico, verifica se utiliza o lote m�nimo.
			aAdd(aQtd, Max(nLoteMin, nNecess))
		EndIf
	Else
		//Necessidade zerada ou negativa.
		aAdd(aQtd, nNecess)
	EndIf

	//Sumarizador das quantidades.
	nQtdLotes := 0

	nTotal := Len(aQtd)
	For nIndex := 1 To nTotal
		nQtdLotes += aQtd[nIndex]
	Next

	//Se n�o utiliza a quebra, soma todas as qtds. da quebra em uma �nica quantidade.
	If !lQuebra
		aSize(aQtd, 0)
		aAdd(aQtd, nQtdLotes)
	EndIf

	aSize(aDadosPrd, 0)
	aSize(aAreaPRD , 0)

Return aQtd

/*/{Protheus.doc} ajustarArrayQuebrasQtd
Converte o ARRAY de lotes (array com as quantidades quebradas) para uma matriz
contendo a quantidade e o documento.

@author    lucas.franca
@since     22/10/2019
@version 1.0
@param 01 - cProduto   , caracter, codigo do produto
@param 02 - nNecess    , numero  , necessidade do produto
@param 03 - nQtdLotes  , numero  , retorna por refer�ncia a qtd. sumarizada dos lotes.
@return aQtd, Array, Array com as quantidades de necessidade do produto
/*/
METHOD ajustarArrayQuebrasQtd(aQuant) CLASS MrpDominio
	Local aQtdDocum := Nil
	Local nTotal    := Len(aQuant)
	Local nIndex    := 0

	aQtdDocum := Array(nTotal)

	For nIndex := 1 To nTotal
		aQtdDocum[nIndex] := {aQuant[nIndex], ""}
	Next nIndex
Return aQtdDocum

/*/{Protheus.doc} validaLotesVencidos
Desconta os lotes vencidos do saldo inicial do produto

@author    renan.roeder
@since     14/11/2019
@version 1.0
@param 01 - cFilAux    , caracter, codigo da filial
@param 02 - cProduto   , caracter, codigo do produto
@param 03 - nPeriodo   , numero  , n�mero do per�odo
@param 04 - nSldInicial, numero  , saldo inicial
@param 05 - aRetLotes  , array   , array dos lotes: quantidade e validade
@param 06 - cChaveProd , caracter, chave do produto
@param 07 - cIDOpc     , caracter, ID Opcional do produto
@return  nSaldo     , numero  , saldo atualizado
/*/
METHOD validaLotesVencidos(cFilAux, cProduto, nPeriodo, nSldInicial, aRetLotes, cChaveProd, cIDOpc) CLASS MrpDominio
	Local aCampos    := {}
	Local aLotes     := {}
	Local aLoteVenc  := {}
	Local aPRDPeriod := {}
	Local aRetAux    := {}
	Local cChave     := ""
	Local cList      := ""
	Local lErrorMAT  := .F.
	Local lRegistrou := .F.
	Local lErrorRast := .F.
	Local nDesconto  := 0
	Local nIndLote   := 0
	Local nIndPer    := 0
	Local nPerAnter  := 0
	Local nSaidas    := 0
	Local nSaldo     := nSldInicial
	Local nTotLote   := 0
	Local nTotPer    := 0
	Local nPerUtil   := ::oDados:oDominio:oPeriodos:primeiroPeriodoUtil(cFilAux)

	nPerAnter := ::periodoAnterior(cChaveProd, nPeriodo, @aPRDPeriod, @lErrorMAT)
	If nPerAnter > 0 .And. aRetLotes != Nil
		For nIndLote := 1 To Len(aRetLotes)
			If aRetLotes[nIndLote][2] >= Self:oPeriodos:retornaDataPeriodo(cFilAux, nPerAnter) .And.;
			   aRetLotes[nIndLote][2] < Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
				aAdd(aLoteVenc, aRetLotes[nIndLote])
			EndIf
		Next nIndLote

		//Existem lotes que venceram no per�odo anterior. Aplica regra para descontar o saldo no per�odo atual.
		If Len(aLoteVenc) > 0
			aLotes   := aClone(aRetLotes) //Copia o array para n�o manipular os dados do array original.
			nTotLote := Len(aLotes)
			nTotPer  := Len(aPRDPeriod)
			aCampos  := {"MAT_SAIPRE", "MAT_SAIEST", "MAT_QTRSAI"}

			//Percorre todos os per�odos do produto para obter as sa�das e descontar o saldo utilizado dos lotes.
			For nIndPer := 1 To nTotPer
				If nPerAnter < aPRDPeriod[nIndPer][2]
					//Interrompe o loop se o per�odo de valida��o de lotes for menor
					//que o pr�ximo per�odo do produto.
					Exit
				EndIf

				//Obt�m as sa�das do produto neste per�odo.
				cChave := ""
				If Self:oDados:existeMatriz(cFilAux, cProduto, aPRDPeriod[nIndPer][2], @cChave, cIDOpc)
					aRetAux := Self:oDados:retornaCampo("MAT", 1, cChave, aCampos, @lErrorMAT, , , , , , .T. /*lVarios*/)
					If lErrorMAT == .F.
						//nSaidas := Saidas Previstas + Saidas de estrutura + Transferencia de saida.
						nSaidas += aRetAux[1] + aRetAux[2] + aRetAux[3]
						aSize(aRetAux, 0)
						//Verifica se existe estoque de seguran�a, e adiciona como Sa�da para considerar o uso do lote.
						If nPerUtil == aPRDPeriod[nIndPer][2]
							cChave := Self:oRastreio:getChaveEstSeg(cProduto, aPRDPeriod[nIndPer][2], .T.)
							cList  := cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + chr(13) + aPRDPeriod[nIndPer][1]

							aRetAux := Self:oDados:oRastreio:oDados:getItemAList(cList, cChave, @lErrorRast)
							If !lErrorRast
								nSaidas += aRetAux[Self:oRastreio:getPosicao("NEC_ORIGINAL")]
								aSize(aRetAux, 0)
							EndIf
						EndIf

						//Verifica se houve lotes vencidos neste per�odo
						For nIndLote := 1 To nTotLote
							//Verifica se o vencimento do lote � anterior ao per�odo de c�lculo e >= ao per�odo de valida��o (aPRDPeriod)
							If aLotes[nIndLote][2] >= Self:oPeriodos:retornaDataPeriodo(cFilAux, aPRDPeriod[nIndPer][2]) .And. ;
							   aLotes[nIndLote][2] < Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)                .And. ;
							   aLotes[nIndLote][1] > 0
								//Abate a qtd de sa�da da qtd do lote. O restante do lote ser� considerado como vencido e ser�
								//subtra�do do saldo do produto.
								If aLotes[nIndLote][1] > nSaidas
									aLotes[nIndLote][1] -= nSaidas
									nSaidas             := 0
									If nPerAnter == aPRDPeriod[nIndPer][2]
										nDesconto += aLotes[nIndLote][1]
									EndIf
								Else
									nSaidas             -= aLotes[nIndLote][1]
									aLotes[nIndLote][1] := 0
								EndIf

							ElseIf aLotes[nIndLote][2] >= Self:oPeriodos:retornaDataPeriodo(cFilAux, aPRDPeriod[nIndPer][2]) .Or. ;
							       aLotes[nIndLote][2] >= Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
								//Este lote j� est� fora dos per�odos de valida��o. Interrompe o FOR de lotes para avaliar o pr�ximo per�odo.
								Exit
							EndIf

						Next nIndLote
					EndIf
				EndIf
			Next nIndPer

			//Subtrai o total dos lotes vencidos do saldo do produto.
			nSaldo -= nDesconto

			//Registra informa��es do lote vencido para grava��o na HWC.
			Self:oRastreio:registraLoteVencido(cFilAux, cProduto, cIdOpc, nPeriodo, Abs(nSldInicial - nSaldo), nSldInicial, aLoteVenc)
			lRegistrou := .T.

			//Grava flag identificando que descontou lote vencido para o produto+data
			//Flag utilizada para gravar o registro da tabela HWB caso n�o
			//existam outras informa��es neste per�odo al�m do vencimento do lote.
			cChave := "LTVENC" + CHR(10) +;
			          cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") +;
			          DtoS(Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo))
			Self:oDados:oMatriz:setFlag(cChave, .T., .F., .F.)

			FwFreeArray(aLotes)
			FwFreeArray(aPRDPeriod)
			aSize(aLoteVenc, 0)
			aSize(aCampos  , 0)
		EndIf

		If !lRegistrou
			//Registra vazio para limpar poss�vel rec�lculo.
			Self:oRastreio:registraLoteVencido(cFilAux, cProduto, cIdOpc, nPeriodo, 0, 0, {})
		EndIf
	EndIf

Return nSaldo

/*/{Protheus.doc} descontouLoteVencido
Verifica se foi realizado desconto de algum lote vencido para o produto na data informada.
Utilizado para identificar que deve ser registrado o registro da matriz na tabela HWB, mesmo que n�o exista
nenhuma sa�da para o produto.

@author    lucas.franca
@since     13/05/2022
@version 1.0
@param 01 - cFilAux , Character, C�digo da filial de processamento
@param 02 - cProduto, Character, C�digo do produto
@param 03 - cIdOpc  , Character, ID de opcionais do produto.
@param 04 - dData   , Date     , Data para verifica��o
@return lRet, Logic, Identifica se foi realizada algum desconto de lote vencido no per�odo.
/*/
METHOD descontouLoteVencido(cFilAux, cProduto, cIdOpc, dData) CLASS MrpDominio
	Local cChave := ""
	Local lError := .F.
	Local lFlag  := .F.
	Local lRet   := .F.

	cChave := "LTVENC" + CHR(10) +;
	          cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") +;
	          DtoS(dData)

	lFlag := Self:oDados:oMatriz:getFlag(cChave, @lError, .F.)

	//Se encontrou a flag registrada no m�todo validaLotesVencidos, retorna .T. para gravar o registro na HWB.
	lRet := lError == .F. .And. lFlag == .T.

Return lRet

/*/{Protheus.doc} MRPCalculo
Calculo a necessidade do produto (Function - JOB)
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cFilAux     , logico  , c�digo da filial para processar
@param 02 - oDominio    , objeto  , objeto da classe MrpDominio passado somente sem threads adicionais
@param 03 - cProduto    , caracter, codigo do produto pra calcular a necessidade
@param 04 - cIDOpc      , caracter, codigo do IDOpc do produto
@param 05 - nRecursivas , numero  , numero de chamadas recursivas
@param 06 - lPercent    , logico  , indica se deve imprimir o pecentual atual do processamento de calculo
@param 07 - nInexistLoop, numero  , utilizado quando lPercent == true, indica o numero de produtos pulados devido inexistencia da matriz
@param 08 - lTLiveLock  , logico  , indica que a chamada e oriunda de thread exclusiva de livelock
@param 09 - cTicket     , caracter, n�mero do ticket de processamento do MRP
@return lReturn, logico, indica se realizou o calculo do produto sem pendencias
/*/
Function MRPCalculo(cFilAux, oDominio, cProduto, cIDOpc, nRecursivas, lPercent, nInexistLoop, lTLiveLock, cTicket)

	Local aBaixaPorOP  := {}
	Local aDesfezAlt   := {}
	Local aMinMaxAlt   := {}
	Local aPRDPeriodos := {}
	Local aRetAux      := {}
	Local aRetLotes    := {}
	Local aAuxAlt      := {}
	Local cLogAux      := ""
	Local cProdOrig    := ""
	Local cChave       := ""
	Local cChaveProd   := cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
	Local cChvMinMax   := ""
	Local cNivelAtu    := ""
	Local dLeadTime    := Nil
	Local dLTReal      := Nil
	Local lReturn      := .T.
	Local lErrorMAT    := .F.
	Local lExplode     := .T.
	Local lFalha       := .F.
	Local lErrorPRD    := .F.
	Local lWait        := .F.
	Local lConsumiu    := .F.
	Local lLog1        := .F.
	Local lLog2        := .F.
	Local lLog3        := .F.
	Local lLog4        := .F.
	Local lLog5        := .F.
	Local lLog6        := .F.
	Local lLog7        := .F.
	Local lLogCS       := .F.
	Local lUsaME       := .F.
	Local lForcaTran   := .F.
	Local nConsumo     := 0
	Local nPerAux1     := 0
	Local nPerAux2     := 0
	Local nPerIndMin   := 1
	Local nPerIndMax   := 1
	Local nPeriodo     := -1
	Local nPerLead     := 0
	Local nSldInicial  := 0
	Local nSldIniAux   := 0
	Local nEntPrev     := 0
	Local nSaiPrev     := 0
	Local nSaiEstru    := 0
	Local nSaldo       := 0
	Local nSldAux      := 0
	Local nNecess      := 0
	Local nNecessPMP   := 0
	Local nOldSldIni   := 0
	Local nPerInicio   := 0
	Local nPerMaximo   := 0
	Local nPerMinGrv   := 0
	Local nPerMaxGrv   := 0
	Local nPerCalGrv   := -1
	Local nAuxPerGrv   := -1
	Local nPosAlt      := 0
	Local nQtdTran     := 0
	Local nQtrEnt      := 0
	Local nQtrSai      := 0
	Local nSubsTran    := 0
	Local nUltPerCal   := 0
	Local nInd         := 0
	Local nThreads     := 0
	Local nThreadPRD   := 0
	Local nTotAlt      := 0
	Local nIndAlt      := 0
	Local nSaidSubs    := 0
	Local oDados       := Nil
	Local oLogs        := Nil
	Local oMatriz      := Nil
	Local oProdutos    := Nil
	Local oLiveLock    := Nil
	Local lErrorAlt    := .F.
	Local lReinicia    := .F.
	Local lAlternativo := .F.
	Local lSubProduto  := .F.
	Local lRetPerCal   := .F.
	Local lGravaSld    := .F.
	Local lSemTran     := .F.

	Default nRecursivas := 0
	Default lPercent    := .F.
	Default lTLiveLock  := .F.

	If slRecria .Or. ((soDominio == Nil .Or. soDominio:oPeriodos:retornaArrayPeriodos(cFilAux) == Nil .Or. Len(soDominio:oPeriodos:retornaArrayPeriodos(cFilAux)) == 0) .AND. oDominio == Nil)
		If slRecria
			slRecria := .F.
			If soDominio != Nil
				FreeObj(soDominio)
			EndIf
		EndIf
		MRPPrepDom(cTicket)

	ElseIf oDominio != Nil
		soDominio := oDominio

	EndIf

	oDados        := soDominio:oDados
	soAlternativo := soDominio:oAlternativo
	oLogs         := soDominio:oLogs
	oProdutos     := oDados:oProdutos
	oMatriz       := oDados:oMatriz
	oLiveLock     := oDados:oLiveLock
	nThreads      := soDominio:oParametros["nThreads"]

	lUsaME := soDominio:oMultiEmp:utilizaMultiEmpresa()

	lLog1  := oLogs:logValido("1")
	lLog2  := oLogs:logValido("2")
	lLog3  := oLogs:logValido("3")
	lLog4  := oLogs:logValido("4")
	lLog5  := oLogs:logValido("5")
	lLog6  := oLogs:logValido("6")
	lLog7  := oLogs:logValido("7")
	lLogCS := oLogs:logValido("CS")

	If oDados:reservaProduto(cChaveProd, @nPerInicio, @nPerMaximo, .F., @nUltPerCal, @cNivelAtu, @nThreadPRD)
		//Log inicio de calculo do produto, apos reserva: - Inicio
		If lLog2 .Or. lLog3
			cLogAux := STR0024 + cNivelAtu + STR0025 + AllTrim(cChaveProd) + STR0026 + cValToChar(nPerInicio) + "/" + cValToChar(nPerMaximo) + STR0027 + cValToChar(nUltPerCal) //" - Nivel " + " - Inicio de calculo do produto: " + " - Periodos: " + " - Ultimo periodo calculado: "
			If lLog2
				oLogs:log(cLogAux, "2")
			EndIf
			If lLog3 .And. nPerInicio <= nPerMaximo .And. nPerInicio != 1
				oLogs:log(cLogAux, "3")
			EndIf
		EndIf
		//Log inicio de calculo do produto, apos reserva: - Fim

		//Avalia periodos onde o produto existe
		//Verifica Periodo existente igual ou maior
		If !oDados:existeMatriz(cFilAux, cProduto, , cChaveProd, cIDOpc)
			//Cria lista deste produto para registrar os periodos
			If !oDados:oMatriz:existList("Periodos_Produto_" + cChaveProd)
				oDados:oMatriz:createList("Periodos_Produto_" + cChaveProd)
			EndIf
		EndIf
		oDados:oMatriz:setItemList("Periodos_Produto_" + cChaveProd, "1", 1)
		oDados:oMatriz:getAllList("Periodos_Produto_" + cChaveProd, @aPRDPeriodos, @lErrorMAT)
		If !lErrorMAT
			aSort(aPRDPeriodos, , , { |x,y| x[2] < y[2] } )
		EndIf
		nPerIndMin := aScan(aPRDPeriodos, { |nPer| nPer[2] >= nPerInicio } )
		nPerIndMin := Iif(nPerIndMin == 0, 1, nPerIndMin)

		//Identifica maior periodo
		nPerIndMax := 0
		nPerAux2   := -1
		While nPerAux2 > 0 .or. nPerAux2 == -1
			nPerAux2 := aScan(aPRDPeriodos, { |nPer| nPer[2] <= nPerMaximo }, (nPerIndMax + 1) )
			If nPerAux2 > 0 .and. aPRDPeriodos[nPerAux2][2] <= oDados:oParametros["nPeriodos"]
				nPerIndMax := nPerAux2
			EndIf
		EndDo

		//Identifica exist�ncia de Alternativos e sequ�ncias: Min-Max
		If lUsaME
			cChvMinMax := soDominio:oMultiEmp:getFilialTabela("T4N", cFilAux) + cProduto
		Else
			cChvMinMax := cProduto
		EndIf
		aMinMaxAlt := oDados:oAlternativos:getItemAList("min_max", cChvMinMax, @lErrorAlt)

		aRetAux     := oDados:retornaCampo("PRD", 1, cChaveProd, {"PRD_LOTVNC", "PRD_LSUBPR"}, @lErrorPRD, .F. /*lAtual*/, , , , , .T. /*lVarios*/)
		aRetLotes   := aRetAux[1]
		lSubProduto := aRetAux[2]

		If aRetLotes != Nil
			//Ordena pela data de vencimento.
			aSort(aRetLotes, , , { |x,y| x[2] < y[2] } )
		EndIf

		//Percorre Todos os Periodos Existentes do Produto na Matriz
		For nPerAux1 := nPerIndMin to nPerIndMax
			nPeriodo    := aPRDPeriodos[nPerAux1][2]
			lWait       := .F.
			nEntPrev    := 0
			nSaiPrev    := 0
			nSaiEstru   := 0
			nSaldo      := 0
			nNecess     := 0
			nNecessPMP  := 0
			nConsumo    := 0
			nQtrEnt     := 0
			nQtrSai     := 0
			lErrorMAT   := .F.
			lReinicia   := .F.
			lForcaTran  := .F.
			lRetPerCal  := .F.
			lGravaSld   := .F.
			lSemTran    := .F.

			If lLog2
				oLogs:log(STR0183 + cValToChar(nPeriodo) + STR0075  + AllTrim(cChaveProd) , "2") //"Calculando periodo " 1 // " do produto " ABC
			EndIf

			If !oDados:foiCalculado(cChaveProd, nPeriodo, .T.)
				If nPeriodo == nPerInicio
					nSldInicial := soDominio:saldoInicial(cFilAux, cProduto, nPerInicio, , cIDOpc)
					nOldSldIni  := nSldInicial
				EndIf
				nSldInicial := soDominio:validaLotesVencidos(cFilAux, cProduto, nPeriodo, nSldInicial, aRetLotes, cChaveProd, cIDOpc)

				//Loga Evento 001 - Saldo em estoque inicial menor que zero (Primeiro Per�odo)
				If nPeriodo == 1 .And. nSldInicial < 0
					soDominio:oEventos:loga("001", cProduto, soDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), {nSldInicial}, cFilAux)
				EndIf

				//Matriz Flegada? - Verifica existencia de registro + reserva
				If oDados:existeMatriz(cFilAux, cProduto, nPeriodo, @cChave, cIDOpc)
					//Grava Saldo Inicial
					If lLog4
						oLogs:log(STR0018 + cValToChar(nPeriodo) + STR0028 + AllTrim(cChaveProd) + STR0029 + cValToChar(nSldInicial), "4") //" - Periodo: " + " - Produto: " + "- Saldo inicial (MAT_SLDINI): "
					EndIf

					If lUsaME
						nSldIniAux := oDados:retornaCampo("MAT", 1, cChave, "MAT_SLDINI", @lErrorMAT)
						If !lErrorMAT .And. nSldIniAux != nSldInicial
							lForcaTran := .T.
						EndIf
					EndIf

					oDados:gravaCampo("MAT", 1, cChave  , "MAT_SLDINI", nSldInicial, .T.)
					lConsumiu   := .T.

					//Efetua calculo base do MRP
					aRetAux   := oDados:retornaCampo("MAT", 1, cChave, {"MAT_ENTPRE", "MAT_SAIPRE", "MAT_SAIEST", "MAT_QTRENT", "MAT_QTRSAI"}, @lErrorMAT, , , , , , .T. /*lVarios*/)
					nEntPrev  := aRetAux[1]
					nSaiPrev  := aRetAux[2]
					nSaiEstru := aRetAux[3]
					nQtrEnt   := aRetAux[4]
					nQtrSai   := aRetAux[5]

					nSaldo  := nSldInicial + nEntPrev + nQtrEnt - nSaiPrev - nSaiEstru - nQtrSai

					If lLogCS
						oLogs:log(" - Periodo: " + cValToChar(nPeriodo) + " - Produto: " + AllTrim(cChaveProd) + " -> " + cValToChar(nSaldo) + " := " + cValToChar(nSldInicial) + " + " + cValToChar(nEntPrev) + " - " + cValToChar(nSaiPrev) + " - " + cValToChar(nSaiEstru)+ " - " + cValToChar(nQtrSai), "CS")
					EndIf

				Else
					nSaldo  := nSldInicial
					lErrorMAT := .T.
				EndIf
			Else
				If oDados:existeMatriz(cFilAux, cProduto, nPeriodo, @cChave, cIDOpc)
					aRetAux := oDados:retornaCampo("MAT", 1, cChave, {"MAT_SLDINI", "MAT_ENTPRE", "MAT_SAIPRE", "MAT_SALDO", "MAT_SAIEST", "MAT_QTRENT", "MAT_QTRSAI"}, @lErrorMAT, , , , , , .T. /*lVarios*/)
					If aRetAux != Nil
						nSldInicial := aRetAux[1]
						nEntPrev    := aRetAux[2]
						nSaiPrev    := aRetAux[3]
						nSaldo      := aRetAux[4]
						nSaiEstru   := aRetAux[5]
						nQtrEnt     := aRetAux[6]
						nQtrSai     := aRetAux[7]
					Else
						aRetAux := {}
						If nPeriodo == nPerInicio
							nSldInicial := soDominio:saldoInicial(cFilAux, cProduto, nPerInicio, , cIDOpc)
							nOldSldIni  := nSldInicial
						EndIf
						nSaldo  := nSldInicial
					EndIf

				Else
					If nPeriodo == nPerInicio
						nSldInicial := soDominio:saldoInicial(cFilAux, cProduto, nPerInicio, , cIDOpc)
						nOldSldIni  := nSldInicial
					EndIf
					nSaldo  := nSldInicial
				EndIf
			EndIf

			//Desfaz Explos�es Anteriores deste Produto
			soDominio:oRastreio:desfazExplosoes(cFilAux, cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPeriodo, "", "")

			//Desfaz substituicoes deste produto original
			lWait := .F.
			If !lErrorAlt
				nConsumo := -nSaldo
				nSaldo   := soAlternativo:desfazSubstituicoes(cFilAux, cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nSaldo, nPeriodo, , @aDesfezAlt, @lWait)
				nConsumo += nSaldo
				nEntPrev += nConsumo

				If lWait
					nPerMinGrv := nPeriodo
					nPerMaxGrv := nPeriodo
					soDominio:periodoMaxComponentes(cFilAux, cProduto, (nPeriodo - 1))
					lReturn := .F.
					If lLog5
						oLogs:log(STR0174 + AllTrim(cChaveProd) + STR0018 + cValToChar(nPeriodo), "5") //"Interrompendo c�lculo. N�o conseguiu desfazer substitui��o dos produtos alternativos, produto: " + " - Periodo: "
					EndIf
					If nThreads > 1
						oLiveLock:setResult(cChaveProd, 1, .F., .T., .T.)
					EndIf
				EndIf
			EndIf

			//Identifica chaves Pai para Gera��o de Rastreabilidade, consome saldos estoque
			aBaixaPorOP := soDominio:oRastreio:baixaPorOP(cFilAux, cProduto, cIDOpc, (nSldInicial + nEntPrev), nPeriodo, @lAlternativo, nSaiPrev+nSaiEstru+nQtrSai, nSldInicial)

			//Desfaz substitui��es no rastreamento
			If nConsumo != 0 .And. !lErrorAlt .And. lReturn
				soDominio:oRastreio:desfazSubstituicoes(cFilAux, cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPeriodo, @aBaixaPorOP, nConsumo)
			EndIf

			nNecessPMP := soDominio:reduzPMPSaldo(@nSaldo, aBaixaPorOP, (nSldInicial + nEntPrev + nQtrEnt), (nSaiPrev + nSaiEstru + nQtrSai))
			If nNecessPMP > 0
				soDominio:salvaPMPPeriodo(cFilAux + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPeriodo, nNecessPMP)
			EndIf

			If lUsaME .And. lReturn .And. ((lForcaTran) .Or. (nSaldo < 0 .And. nQtrSai > 0))
				soDominio:oMultiEmp:desfazSaidaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChave, @aBaixaPorOP, @nQtrSai, @nSaldo, lForcaTran)
			EndIf

			If lErrorMAT .And. lUsaME .And. lReturn
				//Se a matriz deste produto ainda n�o foi criada, faz a cria��o para gerar corretamente
				//as quantidades de transfer�ncia de entrada na matriz.
				oDados:atualizaMatriz(cFilAux, soDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), cProduto, cIDOpc, {"MAT_SLDINI"}, {nSldInicial})
				lErrorMAT := .F.
			EndIf

			//Consome alternativos deste produto
			If nSaiEstru > 0 .And. !lErrorAlt .And. lReturn
				nSldAux := nSaldo
				nSaldo  := soAlternativo:consumirAlternativos(cFilAux, cProduto, nSaldo, nPeriodo, cProdOrig, @lWait, cIDOpc, nSaiEstru, aBaixaPorOP, aMinMaxAlt)

				If lWait
					nPerMinGrv := nPeriodo
					nPerMaxGrv := nPeriodo
					soDominio:periodoMaxComponentes(cFilAux, cProduto, (nPeriodo - 1))
					lReturn := .F.
					If lLog5
						oLogs:log(STR0032 + AllTrim(cChaveProd) + STR0018 + cValToChar(nPeriodo), "5") //"Interrompendo calculo produto, nao conseguiu consumir os Alternativos, produto: " + " - Periodo: "
					EndIf
					If nThreads > 1
						oLiveLock:setResult(cChaveProd, 1, .F., .T., .T.)
					EndIf

				Else
					If nSldAux != nSaldo
						soDominio:oRastreio:atualizaSubstituicao(cFilAux, cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPeriodo, @aBaixaPorOP, .F.)
					EndIf
					nTotAlt     := Len(soAlternativo:aPeriodos_Alternativos)
					For nIndAlt := 1 to nTotAlt
						aAuxAlt := soAlternativo:aPeriodos_Alternativos[nIndAlt]

						//Verifica se o alternativo teve consumo diferente
						nPosAlt := aScan(aDesfezAlt, {|x| AllTrim(x[2]) == AllTrim(aAuxAlt[1]) })
						If nPosAlt == 0 .OR. aAuxAlt[3] != aDesfezAlt[nPosAlt][5]//{cProduto, cAlternativo, nPeriodo, nConsAlt, nConsOrig, ::cOrdem}
							oDados:gravaPeriodosProd(cFilAux + aAuxAlt[1], aAuxAlt[2])
						EndIf
					Next
					aSize(soAlternativo:aPeriodos_Alternativos, 0)
				EndIf
			EndIf

			//Busca estoque em outras filiais
			nQtrEnt := 0
			If lUsaME .And. lReturn .And. (nSaldo + nQtrSai) < 0
				nSaidSubs := soAlternativo:quantidadeSubstituicaoAlternativo(aBaixaPorOP)

				If nSaldo + nQtrSai + nSaidSubs < 0
					nSaldo := soDominio:oMultiEmp:consumirEstoqueME(cFilAux, cProduto, nPeriodo, cIDOpc, nSaldo + nQtrSai + nSaidSubs, @lWait, @nQtrEnt, .T., @lSemTran)

					If nQtrSai > 0 .Or. nSaidSubs > 0
						nSaldo := nSaldo - nQtrSai - nSaidSubs
					EndIf

					If lWait
						nPerMinGrv := nPeriodo
						nPerMaxGrv := nPeriodo
						soDominio:periodoMaxComponentes(cFilAux, cProduto, (nPeriodo - 1))
						lReturn := .F.
						lRetPerCal := .T.
						If lLog5
							oLogs:log(STR0169 + AllTrim(cChaveProd) + STR0018 + cValToChar(nPeriodo), "5") //""Interrompendo c�lculo produto, n�o conseguiu consumir o estoque em outra filial, produto: " + " - Periodo: "
						EndIf
						If nThreads > 1
							oLiveLock:setResult(cChaveProd, 1, .F., .T., .T.)
						EndIf
					EndIf
				EndIf
			EndIf

			If !lErrorMAT
				lGravaSld := .T.
			EndIf

			If nPerCalGrv == -1 .Or. nPerCalGrv < nPeriodo
				nAuxPerGrv := nPerCalGrv
				nPerCalGrv := nPeriodo
			EndIf

			//Interrompe o c�lculo quando um dos produtos alternativos ainda n�o foi calculado, ou existe saldo do produto em outra filial que n�o foi calculada.
			If !lReturn .And. nQtrEnt == 0
				If lRetPerCal
					nPerCalGrv := nAuxPerGrv
				EndIf
				If lGravaSld
					If lLog4
						oLogs:log(STR0018 + cValToChar(nPeriodo) + STR0028 + AllTrim(cChaveProd) + STR0033 + cValToChar(nSaldo) + ". MAT_NECESS=0.", "4") //" - Periodo: " + " - Produto: " + " - Saldo (MAT_SALDO): "
					EndIf
					oDados:gravaCampo("MAT", 1, cChave, {"MAT_SALDO", "MAT_NECESS"} , {nSaldo, 0}, , , , .T.)
					lGravaSld := .F.
				EndIf

				Exit
			EndIf

			nQtdTran  := 0
			nSubsTran := 0
			//Aplica politica de estoque
			nNecess := soDominio:politicaDeEstoque(cFilAux, cChaveProd, nSaldo, , nPeriodo, @lReinicia, @aBaixaPorOP, ;
			                                       lAlternativo, .F., cProduto, nQtrEnt, cNivelAtu, cIDOpc, @nQtdTran, ;
			                                       lReturn, @lWait, lErrorALT, aMinMaxAlt, @nSubsTran, lSemTran)

			If lWait
				nPerMinGrv := nPeriodo
				nPerMaxGrv := nPeriodo
				soDominio:periodoMaxComponentes(cFilAux, cProduto, (nPeriodo - 1))
				lReturn := .F.
				If lLog5
					oLogs:log(STR0174 + AllTrim(cChaveProd) + STR0018 + cValToChar(nPeriodo), "5") //"Interrompendo c�lculo. N�o conseguiu desfazer substitui��o dos produtos alternativos, produto: " + " - Periodo: "
				EndIf
				If nThreads > 1
					oLiveLock:setResult(cChaveProd, 1, .F., .T., .T.)
				EndIf
			EndIf

			//Interrompe o c�lculo quando um dos produtos alternativos ainda n�o foi calculado, ou existe saldo do produto em outra filial que n�o foi calculada.
			If !lReturn
				nPerCalGrv := nAuxPerGrv
				Exit
			EndIf

			If lUsaME .And. (nQtdTran > 0 .Or. nSubsTran > 0)
				nSaldo    := nSaldo + nQtdTran + nSubsTran
				lGravaSld := .T.
			EndIf

			//Identifica que o produto deve ser calculado novamente, mas iniciando do pr�ximo per�odo.
			//Necess�rio para quando utiliza calend�rio e o per�odo atual n�o � uma data �til.
			//Ir� jogar as necessidades no primeiro per�odo �til de acordo com o calend�rio.
			If lReinicia
				If nPeriodo+1 < oDados:oParametros["nPeriodos"]
					oDados:oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo+1), nPeriodo+1)
					If aScan(aPRDPeriodos, {|x| x[2] == nPeriodo+1}) == 0
						aPRDPeriodos[nPerAux1][1] := cValToChar(nPeriodo+1)
						aPRDPeriodos[nPerAux1][2] := nPeriodo+1
					Else
						//O pr�ximo per�odo j� est� no array de per�odos do produto, ent�o n�o � necess�rio reiniciar.
						lReinicia := .F.
					EndIf
				Else
					lReinicia := .F.
				EndIf
			EndIf

			//Atualiza periodo maximo dos componentes
			If nPerInicio > 1
				soDominio:periodoMaxComponentes(cFilAux, cProduto, -1)
			EndIf

			If nNecess > 0 .And. lErrorMAT
				//Inclui novo registro na Matriz, quando ha necessidade e ainda nao existe
				If !oDados:existeMatriz(cFilAux, cProduto, nPeriodo, cChaveProd, cIDOpc) .And. oMatriz:trava(cChave)
					lErrorMAT := .F.
					If lLog6
						oLogs:log(STR0034 + AllTrim(cChaveProd) + STR0018 + cValToChar(nPeriodo) + STR0035 + cValToChar(0), "6") //"Inclui novo registro na Matriz: " + " - Periodo: " + " - nNecessidade: "
					EndIf
					oDados:atualizaMatriz(cFilAux, soDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo), cProduto, cIDOpc)

					oDados:gravaPeriodosProd(cChaveProd, nPeriodo)
					oMatriz:destrava(cChave)
				EndIf

				//Grava Saldo Inicial
				If lLog4
					oLogs:log(cValToChar(nPeriodo) + " - " + AllTrim(cChaveProd) + " - " + "MAT_SLDINI: " + cValToChar(nSldInicial), "4")
				EndIf
				oDados:gravaCampo("MAT", 1, cChave, "MAT_SLDINI", nSldInicial)
				lConsumiu   := .T.

				//Grava Saldo
				lGravaSld := .T.
				If nPerCalGrv == -1 .Or. nPerCalGrv < nPeriodo
					nPerCalGrv := nPeriodo
				EndIf
			EndIf

			If lGravaSld
				If lLog4
					oLogs:log(STR0018 + cValToChar(nPeriodo) + STR0028 + AllTrim(cChaveProd) + STR0033 + cValToChar(nSaldo), "4") //" - Periodo: " + " - Produto: " + " - Saldo (MAT_SALDO): "
				EndIf
				oDados:gravaCampo("MAT", 1, cChave, "MAT_SALDO" , nSaldo)
				lGravaSld := .F.
			EndIf

			//Calcula LeadTime
			nPerLead  := nPeriodo
			dLeadTime := soDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
			soDominio:oLeadTime:aplicar(cFilAux, cChaveProd, @nPerLead, @dLeadTime,,, @dLTReal)  //Aplica o Lead Time do produto
			oDados:gravaCampo("MAT", 1, cChave, "MAT_DTINI" , dLeadTime)

			If !lErrorMAT
				If lLog7
					oLogs:log(STR0018 + cValToChar(nPeriodo) + STR0028 + AllTrim(cChaveProd) + STR0038 + cValToChar(nNecess), "7") //" - Periodo: " + " - Produto: " + " - Necessidade (MAT_NECESS): "
				EndIf
				oDados:gravaCampo("MAT", 1, cChave, "MAT_NECESS", nNecess, .T.)
			EndIf

			//Explode nivel da estrutura
			If lExplode
				If !lErrorMAT .And. nNecess != 0
					If (lSubProduto .AND. soDominio:oSubProduto:processar(cFilAux, cProduto, cIDOpc, nPeriodo, nNecess))
						nPerMinGrv := nPeriodo
						nPerMaxGrv := nPeriodo
						nPerCalGrv := nPeriodo - 1
						soDominio:periodoMaxComponentes(cFilAux, cProduto, (nPeriodo - 1))
						lReturn := .F.
						If lLog5
							oLogs:log(STR0148 + AllTrim(cChaveProd) + STR0018 + cValToChar(nPeriodo), "5") //"Interrompe c�lculo ap�s gerar necessidade do subproduto: "
						EndIf

						//Interrompe o C�LCULO - SubProduto
						Exit
					Else
						soDominio:explodeAgrupadoPorRevisao(cFilAux, cChaveProd, cProduto, nPerLead, nPeriodo, nPerMaximo, cIDOpc, aBaixaPorOP, dLTReal, cNivelAtu)
					EndIf
				EndIf

				//Determina periodo minimo para gravacao na PRD
				If (nPerAux1 + 1) <= Len(aPRDPeriodos)
					nPerMinGrv := aPRDPeriodos[nPerAux1 + 1][2]          //Proximo
				Else
					nPerMinGrv := soDominio:oParametros["nPeriodos"] + 1 //FIM: Ultimo +1
				EndIf
			EndIf

			If lReinicia
				nPerAux1--
			EndIf

			nSldInicial := (nNecess - nNecessPMP + nSaldo)

			//Limpa Array aBaixaPorOP
			For nInd := 1 to Len(aBaixaPorOP)
				aSize(aBaixaPorOP[nInd], 0)
				aBaixaPorOP[nInd] := Nil
			Next
			aSize(aBaixaPorOP, 0)
		Next

		FwFreeArray(aRetLotes)

		//Revisa necessidade de reinicio caso haja alteracao do nPerInicio a partir de outra Thread
		oProdutos:trava(cChaveProd)
		If oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_REINIC", @lErrorPRD, .F. /*lAtual*/)
			oDados:gravaCampo("PRD", 1, cChaveProd, "PRD_REINIC", .F., .T.)
			oProdutos:destrava(cChaveProd)
			If nThreads > 1
				oLiveLock:setResult(cChaveProd, 1, .F., .T., .T.)
			EndIf
			If nRecursivas < soDominio:oParametros["nRecursivas_LiveLock"]
				If lLog1
					oLogs:log(STR0077 + AllTrim(cChaveProd) + STR0078 + cValToChar(nPerInicio), "1") //"Reinicio de calculo do produto '" + "' devido alteracao na matriz a partir de outra Thread que requer recalculo a partir do periodo: "
				EndIf
				MRPCalculo(cFilAux, oDominio, cChaveProd,, (nRecursivas + 1),,,, cTicket)
			Else
			    soDominio:oDados:incrementaTotalizador(cChaveProd, .T., .F.) //Incrementa Processo
				If lLog1
					oLogs:log(STR0091 + AllTrim(cChaveProd) + STR0092 + cValToChar(nPerInicio), "1") //"Calculo do produto '" + "' interrompido devido LiveLock - Alteracao na matriz a partir de outra Thread que requer recalculo a partir do periodo: "
				EndIf
			EndIf

			//Libera PRD para outras Threads
			oDados:liberaProduto(cChaveProd)
			If lLog2 .Or. lLog3
				cLogAux := STR0024 + cNivelAtu + STR0045 + AllTrim(cChaveProd) + STR0026 + cValToChar(nPerInicio) + "/" + cValToChar(nPerMaximo) + STR0027 + cValToChar(nUltPerCal) //" - Nivel " + " - Liberou reserva do produto " + " - Periodos: " + " - Ultimo periodo calculado: "
				If lLog2
					oLogs:log(cLogAux, "2")
				EndIf
				If lLog3 .And. nPerInicio <= nPerMaximo .And. nPerInicio != 1
					oLogs:log(cLogAux, "3")
				EndIf
			EndIf

			If lPercent //Chama impressao de % de cobertura de calculo
				oLogs:percentualAtual(oProdutos, nInexistLoop, oProdutos:getflag("nProdCalcT"))
			EndIf

			Return .T.
		Else
			oProdutos:destrava(cChaveProd)
		EndIf

		nPerCalGrv := Iif(nPerMinGrv > soDominio:oParametros["nPeriodos"], nPerMinGrv, nPerCalGrv)
		oDados:gravaPeriodosProd(cChaveProd, nPerMinGrv, nPerMaxGrv, nPerCalGrv)

		If nPerCalGrv != soDominio:oParametros["nPeriodos"] .And. oLogs:logValido("8")
			//" - Produto: " + " - Periodo Minimo: " + " - Periodo Maximo: " + " - Ult. Calculado: "
			oLogs:log(STR0028 + AllTrim(cChaveProd) + STR0040 + cValToChar(nPerMinGrv) + STR0041 + cValToChar(nPerMaxGrv) + STR0042 + cValToChar(nPerCalGrv), "8")
		EndIf

		If nPerMaximo != soDominio:oParametros["nPeriodos"]
			//"Fim loopNiveis produto com pendencia!" + " - Periodo Maximo: " + "Ultimo Periodo para Calculo"
			If oLogs:logValido("9")
				oLogs:log(STR0043 + STR0041 + "("+cValToChar(nPerMaximo)+") != " + STR0044 + " ("+cValToChar(soDominio:oParametros["nPeriodos"])+"): " + cChaveProd + Iif(lExplode,"lExplode == true", "lExplode == false"), "9")
			EndIf
			lReturn := .F.

		EndIf

		If lReturn
			soDominio:oDados:incrementaTotalizador(cChaveProd, .F., .T.) //Incrementa Calculo
		EndIf

		//Libera PRD para outras Threads
		oDados:liberaProduto(cChaveProd)
		If lLog2 .Or. lLog3
			cLogAux := STR0024 + cNivelAtu + STR0045 + AllTrim(cChaveProd) + STR0026 + cValToChar(nPerInicio) + "/" + cValToChar(nPerMaximo) + STR0027 + cValToChar(nPerCalGrv) //" - Nivel " + " - Liberou reserva do produto " + " - Periodos: " + " - Ultimo periodo calculado: "
			If lLog2
				oLogs:log(cLogAux, "2")
			EndIf
			If lLog3 .And. nPerInicio <= nPerMaximo .And. nPerInicio != 1
				oLogs:log(cLogAux, "3")
			EndIf
		EndIf
	Else
		lFalha := .T.
		//oLogs:log(STR0046 + AllTrim(cChaveProd) + STR0047 + cValtoChar(nThreadPRD), "10") //"Falha na reserva do produto " + " - Produto reservado para outra Thread: "
		//Comentado para fins de performance, mantido para facilitar analises de falhas
	EndIf

	If !lTLiveLock
		soDominio:oDados:incrementaTotalizador(cChaveProd, .T., .F.) //Incrementa Processo
	EndIf

	If lPercent //Chama impressao de % de cobertura de calculo
		oLogs:percentualAtual(oProdutos, nInexistLoop, oProdutos:getflag("nProdCalcT"))
	EndIf

	//Limpa Array aBaixaPorOP
	For nInd := 1 to Len(aBaixaPorOP)
		aSize(aBaixaPorOP[nInd], 0)
		aBaixaPorOP[nInd] := Nil
	Next
	aSize(aBaixaPorOP, 0)
	aBaixaPorOP := Nil

	aSize(aRetAux, 0)
	aRetAux := Nil

	For nInd := 1 to Len(aPRDPeriodos)
		aSize(aPRDPeriodos[nInd], 0)
		aPRDPeriodos[nInd] := Nil
	Next
	aSize(aPRDPeriodos, 0)
	aPRDPeriodos := Nil
	soDominio:oDados:limpaFlagProd()

Return lReturn

/*/{Protheus.doc} PCPCalcLL
Chamada single-thread das execucoes relacionadas a Live-Lock (Function - JOB)
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param cTicket, Character, N�mero do ticket de processamento do MRP
/*/
Function PCPCalcLL(cTicket)
	Local aLiveLock  := {}
	Local cChaveProd := ""
	Local cFilAux    := ""
	Local cProduto   := ""
	Local cIdOpc     := ""
	Local lPendencia := .F.
	Local lFirst     := .T.
	Local lLog       := .F.
	Local lUsaME     := .F.
	Local nInd       := 0
	Local nCalculos  := 0
	Local oDados
	Local oLiveLock
	Local oLogs
	Local oStatus

	If slRecria .Or. soDominio == Nil
		If slRecria
			slRecria := .F.
			If soDominio != Nil
				FreeObj(soDominio)
			EndIf
		EndIf
		MRPPrepDom(cTicket)
	EndIf

	oDados     := soDominio:oDados
	oLiveLock  := oDados:oLiveLock
	oLogs      := soDominio:oLogs
	oStatus    := MrpDados_Status():New(oDados:oParametros["ticket"])
	lLog       := oLogs:logValido("5")
	lUsaME     := soDominio:oMultiEmp:utilizaMultiEmpresa()

	If lLog
		oLogs:log(STR0115 + cValToChar(ThreadID()), "5") //"Inicio calculos single-thread: "
	EndIf

	While lFirst .Or. lPendencia
		lFirst     := .F.
		lPendencia := .F.
		aSize(aLiveLock, 0)
		oLiveLock:getAllRes(@aLiveLock)
		For nInd := 1 to Len(aLiveLock)
			nCalculos++
			cChaveProd := aLiveLock[nInd][1]
			If lUsaME
				cFilAux  := Left(cChaveProd, soDominio:oMultiEmp:tamanhoFilial())
				cProduto := SubStr(cChaveProd, soDominio:oMultiEmp:tamanhoFilial()+1)
			Else
				cProduto := cChaveProd
			EndIf

			If oDados:possuiPendencia(cChaveProd)
				soDominio:oOpcionais:separaIdChaveProduto(@cProduto, @cIdOpc)
				MRPCalculo(cFilAux,, cProduto, cIdOpc, , , , .T./*lTLiveLock*/, oDados:oParametros["ticket"])
				lPendencia := .T.
			Else
				oLiveLock:setResult(cChaveProd, 0)
			EndIf

			//Checa cancelamento a cada X delegacoes/calculos
			If Mod(nCalculos, oDados:oParametros["nX_Para_Cancel"]) == 0
				If oStatus:getStatus("status") == "4"
					Exit
				EndIf
				If lLog
					oLogs:log(STR0147 + cValToChar(nCalculos), "5") //"PCPCalcLL Loop Calculos: "
				EndIf
			EndIf

		Next nInd
	EndDo
	If lLog
		oLogs:log(STR0116 + cValToChar(ThreadID()), "5") //"Fim calculos single-thread: "
	EndIf
	oLiveLock:setflag("nJobLiveLock", 0)
Return

/*/{Protheus.doc} MRPPrepDom
Retorna o objeto do Dominio
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cTicket, caracter, n�mero do ticket de processamento do MRP
@param 02 - lRecria, l�gico  , indica se deve ser recriado o objeto, eliminando o antigo
@return oDominio, object, objeto referente ao dom�nio
/*/
Function MRPPrepDom(cTicket, lRecria)
 	Local aParam      := {}
	Local nInd        := 0
	Local oLogs       := Nil
	Local oParametros := Nil
	Default lRecria   := .F.

	If lRecria .And. soDominio != Nil
		FreeObj(soDominio)
	EndIf

	If soDominio == Nil
		GetGlbVars("PCP_aParam" + cTicket, @aParam)
		If aParam != Nil .And. Len(aParam) >= 1
			oParametros := JsonObject():New()
			oParametros:fromJson(aParam[1])

			If Len(aParam) >= 3
				//Retorna Data para padr�o de oParametros
				For nInd := 1 To Len(aParam[3])
					oParametros[aParam[3][nInd]] := StoD(StrTran(oParametros[aParam[3][nInd]], "-", ""))
				Next
			EndIf

			oLogs     := MrpDados_Logs():New(oParametros)
			soDominio := MrpDominio():New(oParametros, oLogs, .T. /*lRecursiva*/)
			soDominio:oDados:setOPeriodos(soDominio:oPeriodos)
		EndIf
	EndIf

Return soDominio

/*/{Protheus.doc} calcularNivel
Processamento MRP - Realiza o c�lculo dos n�veis dos produtos

@type Method
@author marcelo.neumann
@since 21/11/2019
@version P12.1.27
@return Nil
*/
METHOD calcularNivel() CLASS MrpDominio

	Local oStatus := MrpDados_Status():New(::oParametros["ticket"])
	Local lUsaME  := .F.

	If AllTrim(::oParametros["cAutomacao"]) != "1"
		oStatus:setStatus("niveis", "2") //"Executando"
		oStatus:persistir(Self:oDados)
		oStatus:setStatus("tempo_recalculo_niveis" , MicroSeconds())

		lUsaME := Self:oMultiEmp:utilizaMultiEmpresa()

		If ::oParametros["nThreads"] > 1 .AND. AllTrim(::oParametros["cAutomacao"]) != "2"
			If oStatus:getStatus("status") != "4"
				PCPIPCGO(::oParametros["cSemaforoThreads"], .F., "PCPRecaNiv", ::oParametros["ticket"], "", lUsaME) //Delega para processamento em Thread
			EndIf
		Else
			oStatus:preparaAmbiente(::oDados)
			PCPRecaNiv(::oParametros["ticket"], ::oParametros["cAutomacao"], lUsaME)
		EndIf

	EndIf

Return

/*/{Protheus.doc} PCPRecaNiv
Retorna o objeto do Dominio
@author marcelo.neumann
@since 21/11/2019
@version 1.0
@param cTicket   , caracter, n�mero do ticket que est� sendo processado
@param cAutomacao, caracter, C�digo identificador de execu��o da automa��o de testes
@param lUsaME    , l�gico  , indica se utiliza MRP Multi-empresa.
@return Nil
/*/
Function PCPRecaNiv(cTicket, cAutomacao, lUsaME)

	Local cErro   := ""
	Local oStatus := MrpDados_Status():New(cTicket)

	Default cAutomacao := "0"

	If MRPProced(@cErro, lUsaME)
		oStatus:setStatus("niveis", "3") //Conclu�do
	Else
		oStatus:gravaErro("niveis", cErro)
	EndIf

Return

/*/{Protheus.doc} getUsoPotencia
busca o uso de pot�ncia pelo produto em quest�o
@author    douglas.heydt
@since     22/11/2019
@version 1.0
@param 01 - cFilAux, character, c�digo da filial para processamento
@param 02 - cCompon, character, componente no qual consta informa��o se usa ou n�o pot�ncia
@return lPotencia, l�gico, .T. caso usa pot�ncia, .F. falso caso n�o use.
/*/
METHOD getUsoPotencia(cFilAux, cCompon) CLASS MrpDominio
	Local aAreaPRD   := {}
	Local cPotencia  := ""
	Local cChaveProd := cFilAux + cCompon
	Local lAtual     := cChaveProd == ::oDados:oProdutos:cCurrentKey
	Local lError     := .F.
	Local lPotencia  := .F.

	If !lAtual
		aAreaPRD := ::oDados:retornaArea("PRD")
	EndIf

	cPotencia := ::oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_CPOTEN", @lError, lAtual, , /*lProximo*/, , , .F. /*lVarios*/)
	If !lError .AND. cPotencia == "1"
		lPotencia := .T.
	EndIf

	If !lAtual
		::oDados:setaArea(aAreaPRD)
		aSize(aAreaPRD, 0)
	EndIf

Return lPotencia

/*/{Protheus.doc} reduzPMPSaldo
Refaz o saldo atual considerando as demandas do tipo Plano Mestre (PMP).

Como o PMP n�o faz baixa de estoque, e a quantidade do PMP � adicionada como sa�da,
retira as quantidades referentes ao PMP do saldo final.

@author    lucas.franca
@since     06/02/2020
@version 1.0
@param 01 - nSaldo     , Numeric, Saldo atual calculado.
@param 02 - aBaixaPorOP, Array  , array com os dados de rastreabilidade origem (Documentos Pais)
								   {{1 - Id Rastreabilidade,;
								     2 - Documento Pai,;
								     3 - Quantidade Necessidade,;
								     4 - Quantidade Estoque,;
								     5 - Quantidade Baixa Estoque,;
								     6 - Quantidade Substitui��o},...}
@param 03 - nQtdEnt     , Numeric, Quantidade de entradas.
@param 04 - nQtdSai     , Numeric, Quantidade de saidas.
@return nSaldoPMP, Numeric, Saldo gerado pelo PMP.
/*/
METHOD reduzPMPSaldo(nSaldo, aBaixaPorOP, nQtdEnt, nQtdSai) CLASS MrpDominio
	Local nIndex    := 0
	Local nSaldoPMP := 0
	Local nTotal    := 0

	If aBaixaPorOP != Nil
		nTotal := Len(aBaixaPorOP)

		For nIndex := 1 To nTotal
			If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "1"
				nSaldoPMP += aBaixaPorOP[nIndex][ABAIXA_POS_NEC_ORIG]
			EndIf
		Next nIndex

		// Recalcula o saldo considerando o PMP como entrada.
		nQtdEnt += nSaldoPMP
		nQtdSai -= nSaldoPMP

		nSaldo := nQtdEnt - nQtdSai
	EndIf

Return nSaldoPMP

/*/{Protheus.doc} MrpDGetSTR
Retorna os textos identificadores de Ponto de pedido e de Estoque de seguran�a.

@type  Function
@author lucas.franca
@since 19/03/2021
@version P12
@param cTipo   , Character, Tipo de retorno. ES=Estoque de seguran�a. PP=Ponto de pedido.
@return cString, Character, Texto identificador do tipo recebido em cTipo.
/*/
Function MrpDGetSTR(cTipo)
	Local cString := ""

	Do Case
		Case cTipo == "ES"
			cString := STR0143 //Est.Seg.
		Case cTipo == "PP"
			cString := STR0144 //Ponto Ped.
	EndCase
Return cString

/*/{Protheus.doc} avaliaAglutinaProduto
Verifica se o produto deve aglutinar a necessidade de
sa�da de estrutura em um tipo de per�odo diferente do
utilizado pelo MRP.

@author lucas.franca
@since 03/06/2022
@version P12
@param 01 cFilAux , Character, C�digo da filial em processamento
@param 02 cProduto, Character, C�digo do componente que est� sendo gerada a sa�da de estrutura.
@param 03 dData   , Date     , Data atual da necessidade do produto. Retorna por refer�ncia a nova data.
@param 04 nPerLead, Numeric  , N�mero do per�odo atual da necessidade do produto. Retorna por refer�ncia o novo per�odo.
@param 05 nAgluPrd, Numeric  , Par�metro do tipo de aglutina��o do produto.
                               1 - Di�rio;
                               2 - Semanal;
                               3 - Quinzenal;
                               4 - Mensal
@param 06 cIdOpc  , Character, ID de Opcionais do componente
@return Nil
/*/
METHOD avaliaAglutinaProduto(cFilAux, cProduto, dData, nPerLead, nAgluPRD, cIdOpc) CLASS MrpDominio
	Local cChave   := 0
	Local nPerAgl  := 0
	Local nPerAux  := 0
	Local nPerOrig := nPerLead
	Local dDataAgl := Nil

	//Verifica se o produto deve seguir aglutina��o diferente da definida pelo MRP.
	If !Empty(nAgluPRD) .And. nAgluPRD > Self:oParametros["nTipoPeriodos"] .And. Self:oAglutina:avaliaAglutinacao(cFilAux, cProduto, .F.)
		//Identifica a data do produto considerando o tipo de per�odo para aglutina��o (MI_AGLUMRP).
		nPerAgl  := Self:oPeriodos:buscaPeriodoDaData(cFilAux, dData, .T., nAgluPRD)
		dDataAgl := Self:oPeriodos:retornaDataPeriodo(cFilAux, nPerAgl, nAgluPRD)

		//Identifica em qual data do MRP a data aglutinada deve ser considerada.
		nPerLead := Self:oPeriodos:buscaPeriodoDaData(cFilAux, dDataAgl, .T.)
		dData    := Self:oPeriodos:retornaDataPeriodo(cFilAux, nPerLead)

		//Verifica se a data resultante entra no mesmo per�odo
		//da data identificada no per�odo de aglutina��o do produto.
		nPerAux := Self:oPeriodos:buscaPeriodoDaData(cFilAux, dData, .T., nAgluPRD)
		While nPerAgl <> nPerAux
			//Se os per�odos n�o bateram, incrementa/decrementa o per�odo at� encontrar o correto.
			nPerLead := nPerLead + (Iif(nPerAux < nPerAgl, 1, -1))
			dData    := Self:oPeriodos:retornaDataPeriodo(cFilAux, nPerLead)

			//Valida novamente o per�odo.
			nPerAux  := Self:oPeriodos:buscaPeriodoDaData(cFilAux, dData, .T., nAgluPRD)
		End

		If nPerOrig <> nPerLead
			cChave := "|AGLUPRD|" + DtoS(dData) + cFilAux + cProduto + Iif(!Empty(cIdOpc), "|" + cIdOpc, "")
			Self:oDados:oMatriz:setFlag(cChave, nAgluPRD)
			If slLog19
				::oLogs:log(I18N(STR0184, {AllTrim(cProduto), cValToChar(nPerOrig), cValToChar(nPerLead)}), "19") //"Periodo da saida de estrutura do produto #1[PRODUTO]# alterada do periodo #2[PERIODODE]# para o periodo #3[PERIODOATE]#."
			EndIf
		EndIf

	EndIf
Return Nil

/*/{Protheus.doc} interrompeCalculo
Interrompe o c�lculo do MRP e apresenta mensagem de erro na interface.

@author lucas.franca
@since 08/08/2022
@version P12
@param cMsg, Caracter, Mensagem de erro que ser� apresentada na finaliza��o
@return Nil
/*/
METHOD interrompeCalculo(cMsg) CLASS MrpDominio
	Local oStatus := MrpDados_Status():New(::oParametros["ticket"])

	oStatus:gravaErro("calculo", cMsg)
	UserException(cMsg)
Return Nil

/*/{Protheus.doc} salvaPMPPeriodo
Salva a entrada por plano mestre de produ��o no perido.
@author Lucas Fagundes
@since 08/08/2022
@version P12
@param 01 cChave   , Caraceter, Chave do produto que ir� salvar o PMP.
@param 02 nPeridodo, Numerico , Periodo do plano mestre que ser� salvo.
@param 03 nQtdPMP  , Numerico , Quantidade do PMP que ser� salva.
@return Nil
/*/
METHOD salvaPMPPeriodo(cChave, nPeriodo, nQtdPMP) CLASS MrpDominio

	::oDados:oMatriz:setFlag("PMP_" + cChave + "_PER_" + CValToChar(nPeriodo), nQtdPMP)

Return Nil

/*/{Protheus.doc} getPMPPeriodo
Retorna a entrada por plano mestre de produ��o do periodo.
@author Lucas Fagundes
@since 08/08/2022
@version P12
@param 01 cChave   , Caraceter, Chave do produto que ir� salvar o PMP.
@param 02 nPeridodo, Numerico , Periodo que ir� buscar o PMP.
@return nRet, Numerico, Quantidade do PMP no periodo.
/*/
METHOD getPMPPeriodo(cChave, nPeriodo) CLASS MrpDominio
	Local lError := .F.
	Local nRet := 0

	nRet := ::oDados:oMatriz:getFlag("PMP_" + cChave + "_PER_" + CValToChar(nPeriodo), @lError)

	If lError
		nRet := 0
	EndIf

Return nRet
