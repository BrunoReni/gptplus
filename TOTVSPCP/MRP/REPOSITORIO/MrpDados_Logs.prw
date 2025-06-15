#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDados.ch'
#include "fileio.ch"

Static sCRLF   := Iif(sCRLF == Nil, chr(13)+chr(10), sCRLF)

/* TIPOS DE LOGS POSSÍVEIS:

|C |: Carga em memoria - inicio e fim
|CM|: Total de entradas de dados para memoria: produtos, demandas, entradas, alternativos e estruturas
|CS|: Calculo do saldo do produto por periodo "Periodo/Produto -> Saldo  := Sld.Inicial + Ent.Prevista - Saida Prev. - Saida Estrutura"
|E |: Erros gerais
|EA|: Erros aceitaveis, ex: Erros Get's MrpData_Global - gera lixo referente checagens de existencia
|EL|: Erros relacionados ao cálculo de Lead Time
|F |: Log com sufixo de ProcName(ProcLine)
|LM|: Monitor limpeza de memória
|ML|: Monitor de lock da camada de dados (necessario alterar conteudo default no fonte MrpData_Global)
|R |: Resumo de tempos camada de aplicacao
|RN|: Recálculo de níveis
|T |: Log com prefixo de ThreadID (X)
|X |: Outros logs tecnicos
|0 |: Camada de aplicacao
|1 |: Processamento loopNiveis - Repeticoes
|2 |: Processamento loopNiveis - Inicio e fim do calculo - reserva do produto (SEMPRE)
|3 |: Processamento loopNiveis - Inicio e fim do calculo - reserva do produto (nPerInicio <= nPerMaximo .and. nPerInicio != 1)
|4 |: Processamento loopNiveis - Atualizacoes de campos na Matriz de calculo
|5 |: Processamento loopNiveis - Interrompimento calculo - Nao conseguiu reservar Matriz (Live-Lock)
|6 |: Processamento loopNiveis - Inclusao de novo registro na Matriz
|7 |: Processamento loopNiveis - Explosao estrutura
|8 |: Processamento loopNiveis - Atualizacao de Periodos De-Ate, quando nPerCalGrv != soDominio:oParametros["nPeriodos"]
|9 |: Processamento loopNiveis - Fim loopNiveis produto com pendencia
|10|: Processamento loopNiveis - Falha na reserva do produto
|11|: Consumo alternativos     - Interrompe pois o alternativo ainda nao foi calculado
|12|: Consumo alternativos     - Atualizacoes de campos na Matriz de calculo
|13|: Consumo alternativos     - Ajusta periodo inicial produto alternativo consumido
|14|: Consumo alternativos     - Reserva produto alternativo
|15|: Consumo alternativos     - Interrompe While: apos consumir o saldo do alternativo
|16|: Consumo alternativos     - Interrompe While: ao tentar consumir saldo de alternativo bloqueado
|17|: Consumo alternativos     - Interrompe While: Nao ha saldo do alternativo
|18|: Consumo alternativos     - Não encontrou alternativo na matriz de calculo no periodo - Loop
|19|: Explosao Estrutura       - Grava saida estrutura
|20|: PeriodoMaxComponentes    - Grava periodo maximo dos componentes da estrutura
|21|: CriarArrayPeriodos       - Definicao dos periodos
|22|: gravaPeriodosProd        - Atualizacao dos periodos do produto
|23|: gravaPeriodosProd        - Atualizacao dos periodos do produto - PRD_NPERAT
|24|: gravaPeriodosProd        - Atualizacao dos periodos do produto - PRD_NPERCA
|25|: gravaPeriodosProd        - Atualizacao dos periodos do produto - PRD_NPERMA
|26|: gravaPeriodosProd        - nPerMaximo := ::nPeriodos - _Global
|27|: Saida Estrutura -> Periodos Produto X: Quantidade: Y Periodo Minimo: Z
|28|: Recursividade de produto fantasma -> Gera LOG do Produto PAI + Produto Fantasma + Quantidade necessária calculada do Produto Fantasma + Período.
|29|: Produto sem pendencia ou sem matriz
|30|: Imprime tabela de opcionais
|31|: Criacao de arquivo fisico
|32|: Exportacao - Acessos Multi-Thread
|33|: Consumo alternativos     - Registra substituicao
|34|: Consumo alternativos     - Desfaz substituicao
|35|: Imprime tabela de produtos
|36|: Imprime tabela de substituicoes
|40|: Instancia camada de dados - MrpData:New() - Recursiva ou MrpData:New() - Nao Recursiva
|41|: Inicio e fim da carga inicial em memoria
|42|: Analises de decremento e incremento do totalizador de controle da LoopNiveis
|M1|: Logs de transferências multi-empresas.

*/

/*/{Protheus.doc} MrpDados_Logs
Classe com as regras de negocio para processamento do calculo do MRP
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDados_Logs FROM LongClassName

	//Declaracao de propriedades da classe

	DATA oStatus       AS OBJECT
	DATA cChaveExec    AS STRING   //Sessão de variáveis globais
	DATA processLogs   AS STRING   //indica quais os tipos de log's que deverao ser gerados
	DATA lLogML        AS LOGICAL  //Indica se deve imprimir o monitor de lock, utilização especialmente quando processLogs = "*" e não quer gerar lixo de ML
	DATA cLogsMemoria  AS STRING   //indica se realiza analise de memoria
	DATA cLogsModo     AS STRING   //indica o modo de exportacao dos log's: 0-Conout, 1-Arquivo de log (lento - execucao por execucao); 2-Arquivo de log, somente no final (+ rapido)
	DATA cThreadID     AS STRING   //string com id da thread atual
	DATA nPilhaFunc    AS INTEGER  //indica quantas funcoes devem ser impressas na pilha de funcoes processLogs == F
	DATA cFiltroLog    AS STRING   //conteudo padrao para filtro dos log's - indicado para uso em manutencoes
	DATA cNOTLogsImpre AS STRING

	//Declaracao de metodos publicos
	METHOD new(oParametros) CONSTRUCTOR
	METHOD log(cMensagem, cTipoAtual, nMemoria, lForcaConout, lRecursiva, lForcaArquivo, lBloco)
	METHOD logb(cMensagem, cTipoAtual, nMemoria, lForcaConout, lRecursiva, lForcaArquivo)
	METHOD criaArquivo(cResults, nSecIni, nSecCarga, cLinTotal)
	METHOD logValido(cTipoAtual)
	METHOD percentualAtual(oProdutos, nInexistente, nProdCalc)
	METHOD cargaPercentual(oParametros)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     25/04/2019
@version   1
@param oParametros, objeto, Objeto JSON com todos os parametros do MRP - Consulte MRPAplicacao():parametrosDefault()
/*/
METHOD new(oParametros) CLASS MrpDados_Logs

	If oParametros == Nil
		oParametros["processLogs" ] := "E"
		oParametros["cLogsMemoria"] := ""
		oParametros["cLogsModo"   ] := "0"
		oParametros["nPilhaFunc"  ] := 3
		oParametros["cFiltroLog"  ] := ""
		oParametros["ticket"      ] := ""
	EndIf

	::oStatus       := oStatus := MrpDados_Status():New(oParametros["ticket"])
	::processLogs   := oParametros["processLogs"]
	::lLogML        := Iif(oParametros["lLogML"] == Nil, .T., oParametros["lLogML"])
	::cLogsMemoria  := oParametros["cLogsMemoria"]
	::cLogsModo     := oParametros["cLogsModo"]
	::cThreadID     := cValToChar(ThreadID())
	::cChaveExec    := oParametros["cChaveExec"]
	::nPilhaFunc    := oParametros["nPilhaFunc"]
	::cFiltroLog    := oParametros["cFiltroLog"]
	::cNOTLogsImpre := oParametros["cNOTLogsImpre"]

	If !VarIsUID(::cChaveExec)
		VarSetUID( ::cChaveExec, .T.)
	EndIf

Return Self

/*/{Protheus.doc} log
Gera log  - Mensagem em String
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cMensagem    , caracter, texto para impressao
@param 02 - cTipoAtual   , caracter, tipo do identificador do texto de log atual
@param 03 - nMemoria     , numerico, retorno por referencia de consumo de memoria atual
@param 04 - lForcaConout , logico  , forca conout
@param 05 - lRecursiva   , logico  , indicador de chamada recursiva
@param 06 - lForcaArquivo, logico  , forca criacao do arquivo
/*/
METHOD log(cMensagem, cTipoAtual, nMemoria, lForcaConout, lRecursiva, lForcaArquivo, lBloco) CLASS MrpDados_Logs

	Local aMemoria  := {}
	Local cNomeFunc := ""
	Local cLinFunc  := ""
	Local cMsgOld   := ""
	Local cSufixo   := ""
	Local lError    := .F.
	Local lStatOk   := .T.
	Local nInd      := 0

	Default cMensagem     := ""
	Default cTipoAtual    := ""
	Default nMemoria      := 0
	Default lForcaConout  := .F.
	Default lRecursiva    := .F.
	Default lForcaArquivo := .F.
	Default lBloco        := .F.

	cTipoAtual := cValToChar(cTipoAtual)

	If lForcaConout .Or. ;
	   ( !Empty(::processLogs) .AND.;
	     ((At("*", ::processLogs) > 0 .AND. !("|" + AllTrim(cTipoAtual) + "|" $ "|EA|")) .OR. ("|" + cTipoAtual + "|") $ ("|" + ::processLogs + "|")) .AND.;
	     (Empty(::cFiltroLog) .OR. (!lBloco .AND. AllTrim(::cFiltroLog) $ cMensagem) .OR. (lBloco .AND. AllTrim(::cFiltroLog) $ eVal(cMensagem))) )

		If !lForcaConout
			If !Self:lLogML .AND. cTipoAtual == "ML"
				Return
			EndIf

			If cTipoAtual $ ::cNOTLogsImpre
				Return
			EndIf

			If cTipoAtual == "E" .AND. Self:oStatus:getStatus("status", @lStatOk) == "4" .OR. !lStatOk
				Return
			EndIf
		EndIf

		If lBloco
			cMensagem := eVal(cMensagem)
		EndIf

		//Acrescenta informacoes de memoria
		If !Empty(::cLogsMemoria) .AND.;
		   ("|" + cTipoAtual + "|") $ ("|" + ::cLogsMemoria + "|")

			aMemoria  := Array(50, 2)
			ShowInfMem(cMensagem, aMemoria)
			aEval(aMemoria, {|x| nMemoria += Iif(x[1] == Nil, 0, x[1]) })
			nMemoria  := nMemoria / 1024
			cMensagem += ";" + cValToChar(nMemoria) + " MB"
			aMemoria := FwFreeArray(aMemoria)
		EndIf

		//Acrescenta sufixo da funcao
		If At("*", ::processLogs) > 0 .OR. "|F|" $ "|" + ::processLogs + "|" .OR. "E" == cTipoAtual .OR. ::nPilhaFunc > 0
			If cTipoAtual == "E"
				cMensagem := "****************************** " + AllTrim(cMensagem) + " ******************************"
			EndIf

			For nInd := 1 to ::nPilhaFunc
				cNomeFunc := ProcName(nInd)
				cLinFunc  := cValToChar(ProcLine(nInd))
				If Empty(cSufixo)
					cSufixo   := "[" + cNomeFunc + "(" + cLinFunc + ")]"
				Else
					cSufixo   += "<-[" + cNomeFunc + "(" + cLinFunc + ")]"
				EndIf
			Next
			If !Empty(cSufixo)
				cMensagem    += ";{" + STR0001 + ": " + cSufixo + "}" //Pilha de chamada
			EndIf
		EndIf

		//Acrescenta prefixo da Thread
		If At("*", ::processLogs) > 0 .OR. "|F|" $ "|" + ::processLogs + "|"
			cMensagem  := PadL(::cThreadID, 6, " ") + ";" + cMensagem
		EndIf

		//Adiciona prefixo tipo atual do log
		cMensagem := "(" + PadL(cTipoAtual, 2, " ") + ");" + cMensagem

		If ::cLogsModo == "0" .OR. ::cLogsModo == "A" .OR. lForcaConout
			LogMsg('MRPLOG', 0, 0, 1, '', '', cMensagem)

		EndIf

		If (::cLogsModo == "2" .OR. ::cLogsModo == "A") .AND. !lForcaArquivo .AND. !lRecursiva
			VarGetX( ::cChaveExec, "log_mrp", @cMsgOld )
			If !lError .AND. cMsgOld != Nil
				cMensagem  := cMsgOld + sCRLF + cMensagem
			Else
				lError := .F.
			EndIf

			//Realiza gravacoes parciais do arquivo a cada 10000 caracteres de string
			If Len(cMensagem) > 10000
				::criaArquivo("\MRP", ::cChaveExec + "_log.log", cMensagem)
				cMensagem := ""
			EndIf

			lError := !VarSetX ( ::cChaveExec, "log_mrp" , cMensagem )

		ElseIf (::cLogsModo == "1" .OR. ::cLogsModo == "2" .OR. ::cLogsModo == "A" .AND. lForcaArquivo) .AND. !lRecursiva
			VarGetX( ::cChaveExec, "log_mrp", @cMsgOld )
			If !lError .AND. cMsgOld != Nil
				cMensagem  := cMsgOld + sCRLF + cMensagem
			Else
				lError := .F.
			EndIf
			lError := !VarSetX ( ::cChaveExec, "log_mrp" , "" )

			::criaArquivo("\MRP", ::cChaveExec + "_log.log", cMensagem)
		EndIf
	EndIf

Return

/*/{Protheus.doc} logb
Gera log - Mensagem em Bloco
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cMensagem    , caracter, texto para impressao
@param 02 - cTipoAtual   , caracter, tipo do identificador do texto de log atual
@param 03 - nMemoria     , numerico, retorno por referencia de consumo de memoria atual
@param 04 - lForcaConout , logico  , forca conout
@param 05 - lRecursiva   , logico  , indicador de chamada recursiva
@param 06 - lForcaArquivo, logico  , forca criacao do arquivo
/*/
METHOD logb(cMensagem, cTipoAtual, nMemoria, lForcaConout, lRecursiva, lForcaArquivo) CLASS MrpDados_Logs
	::log(cMensagem, cTipoAtual, nMemoria, lForcaConout, lRecursiva, lForcaArquivo, .T.)
Return

/*/{Protheus.doc} criaArquivo
Grava arquivo no disco
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cCaminho , caracter, string com o caminho para gravar o arquivo a partir do Rootpath
@param 02 - cArquivo , caracter, nome do arquivo
@param 03 - cConteudo, caracter, conteudo do arquivo
/*/
METHOD criaArquivo(cCaminho, cArquivo, cConteudo) CLASS MrpDados_Logs
	Local nH
	Local lReturn := .T.

	VarBeginT(::cChaveExec, cCaminho + "\" + cArquivo)

	If !ExistDir( cCaminho ) .AND. MakeDir(cCaminho) != 0
		::log(STR0002 + cCaminho + "\'. " + STR0003 + ": " + cValToChar(FError()), "E") //"Não foi possível criar o diretorio '...RootPath" + "Erro"
		lReturn := .F.
	EndIf

	IF lReturn
		If !File(cCaminho + "\" + cArquivo, 0 ,.T.)
			nH := fCreate(cCaminho + "\" + cArquivo)
			If nH == -1
				::log(STR0004 + cCaminho + "\" + cArquivo + "' - " + STR0003 + " " + cValToChar(FError()), "E", 0, .F., .T.) //"Falha ao criar arquivo '...RootPath\" + "Erro"
				lReturn := .F.
			Endif
		Else
			nH := fOpen(cCaminho + "\" + cArquivo, FO_READWRITE + FO_SHARED)
			FSeek(nH, 0, FS_END) // Posiciona no fim do arquivo
			fWrite(nH, sCRLF)
		EndIf
		If lReturn
			fWrite(nH, cConteudo)
			fClose(nH)
		EndIf
	Endif

	If lReturn
		::log(STR0005 + " '" + cCaminho + "\" + cArquivo + "' " + STR0006, "31", 0, .F., .T.)
	EndIf

	VarEndT(::cChaveExec, cCaminho + "\" + cArquivo)

Return lReturn

/*/{Protheus.doc} logValido
Indica se o tipo de log e valido para geracao
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cTipoAtual , caracter, tipo de log atual
@return lReturn, logico, indica se o tipo do log e valido para geracao
/*/
METHOD logValido(cTipoAtual) CLASS MrpDados_Logs
Local lReturn := !Empty(::processLogs) .AND.;
				(  (At("*", ::processLogs) > 0 .AND. !("|" + AllTrim(cValToChar(cTipoAtual)) + "|" $ "|EA|")) .OR.;
				   ("|" + cValToChar(cTipoAtual) + "|") $ ("|" + ::processLogs + "|"))
Return lReturn

/*/{Protheus.doc} percentualAtual
Imprime percentual de cobertura de calculo das necessidades dos produtos
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oProdutos    , objeto, instancia da camada de dados de produtos
@param 01 - nInexistente , numero, quantidade de produtos pulados na LoopNiveis
@param 01 - nProdCalc    , numero, quantidade de produtos Delegados/calculados na LoopNiveis
/*/
METHOD percentualAtual(oProdutos, nInexistente, nProdCalc) CLASS MrpDados_Logs

	Local nPertent      := 0
	Local nProdutos

	nProdutos  := oProdutos:getRowsNum()
	If (nProdCalc + nInexistente) > 0;
	   .AND. Round((nProdCalc + nInexistente) / nProdutos * 100, 2) > oProdutos:getflag("calculationPercentage")
		nPertent := Round((nProdCalc + nInexistente) / nProdutos * 100, 2)
		oProdutos:setflag("calculationPercentage", nPertent, .F., .F.)
		::log(STR0052 + cValToChar(nPertent) + "%" + " - " + STR0053 + "["+cValToChar(nProdCalc + nInexistente)+"] / " + STR0054 + "["+cValToChar(nProdutos)+"] (" + Time() + ")", "%")
	EndIf

	oProdutos:setflag("lPercentX", .F., .F., .F.)

Return

/*/{Protheus.doc} cargaPercentual
Imprime percentual de cobertura de calculo das necessidades dos produtos
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oParametros, objeto, objeto JSON com os parâmetros da execução
@return nPercent, numero, indica o percentual de carga em memoria dos dados
/*/
METHOD cargaPercentual(oParametros) CLASS MrpDados_Logs
	Local nPercent := 0
	Local oCarga   := Nil

	Default oParametros := JsonObject():New()

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	oStatus := MrpDados_Status():New(oParametros["ticket"])
	If !(oStatus:getStatus("memoria") $ "3|4")

		//Cria chave de execucao
		oParametros["cChaveExec"]       := "MRP_TICKET_" + oParametros["ticket"]
		oParametros["cSemaforoThreads"] := "MRP_T" + Right(oParametros["ticket"],3) + "_I"

		//Instancia classe de dados em memória - Recursiva
		oDados   := MrpDados():New(oParametros, , Self, .T.)
		oCarga   := MrpDados_CargaMemoria():New(oDados)
		nPercent := oCarga:percentualAtual(oDados)

		If nPercent > 0 .AND. nPercent < 100 .AND. nPercent > oDados:oProdutos:getflag("memoryLoadPercentage")
			oDados:oProdutos:setflag("memoryLoadPercentage", nPercent, .F., .F.)
		Else
			nPercent := oDados:oProdutos:getflag("memoryLoadPercentage")
		EndIf


		FreeObj(oCarga)
		oDados := FreeObj(oDados)
	EndIf
	oStatus := FreeObj(oStatus)

Return nPercent