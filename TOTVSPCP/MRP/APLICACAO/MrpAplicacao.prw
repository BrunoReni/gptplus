#include 'protheus.ch'
#include 'MRPAPLICACAO.ch'

Static sCRLF

/*/{Protheus.doc} MrpAplicacao
Classe aplicacao do MRP (2019)
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpAplicacao FROM LongNameClass

	//Declaracao de propriedades da classe
	DATA oParametros        AS OBJECT   //Objeto JSON com todos os parametros do MRP - Consulte MRPAplicacao():parametrosDefault()
	DATA oDominio           AS OBJECT   //objeto da camada de dominio

	//Declaracao de metodos publicos
	METHOD new() CONSTRUCTOR
	METHOD cancelaExecucao(cTicket)      //Cancela a Execu��o do MRP
	METHOD calculoPercentual(oParametros)//Retorna o percentual do c�lculo do MRP
	METHOD cargaPercentual(oParametros)  //Retorna o percentual da carga dos dados em Mem�ria
	METHOD eventoPercentual(oParametros, cStatus) //Retorna o percentual de execu��o do Log de Eventos
	METHOD rasDemPercentual(oParametros, cStatus) //Retorna o percentual do processo de rastrebilidade de demandas
	METHOD executar(oParametros)         //Executa o MRP
	METHOD inicializaCarga(oParametros)  //Inicia a carga dos dados em mem�ria
	METHOD parametrosDefault()           //Atribui par�metros Default

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     25/04/2019
@version   1
@Return Self, objeto, instancia da classe MrpAplicacao
/*/
METHOD new() CLASS MrpAplicacao

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	//Altera maxStringSize da secao GENARAL do AppServer.ini para 500 - valido somente para pr�xima execucao
	If GetPvProfString("GENERAL" , "maxStringSize", "0"  , "AppServer.ini" ) < "500"
		WritePProString("GENERAL", "maxStringSize", "500", "AppServer.ini" )
	EndIf

Return Self

/*/{Protheus.doc} inicializaCarga
M�todo respons�vel por inicializar a carga das tabelas de Produtos, Alternativos,
Estruturas, Estoque e Calend�rio

@author    brunno.costa
@since     31/07/2019
@version   1
@param 01 - oParametros, JSON  , parametros de entrada no formato JSON
/*/
METHOD inicializaCarga(oParametros) CLASS MrpAplicacao

	Local oLogs
	Local oStatus   := MrpDados_Status():New(oParametros["ticket"])

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	::parametrosDefault(@oParametros)

	//Instancia classe de log's
	oLogs := MrpDados_Logs():New(oParametros)

	//Seta status
	oStatus:setStatus("status"         , "2") //Iniciado
	oStatus:setStatus("memoria_inicial", "2") //Carregando
	oStatus:setStatus("memoria"        , "2") //Carregando

	//Inicializa objeto da classe de Dominio - Carga dos dados em memoria
	::oDominio := MrpDominio():New(oParametros, oLogs)

	If oStatus:getStatus("status") != "4"         //!Cancelado
		oStatus:setStatus("memoria_inicial", "3") //Em Mem�ria
		oStatus:persistir(::oDominio:oDados)
	EndIf

Return

/*/{Protheus.doc} cancelaExecucao
Inicia processo de cancelamento da execucao
@author    brunno.costa
@since     31/07/2019
@version 1.0
@param 01 - oParametros, JSON  , parametros de entrada no formato JSON
/*/
METHOD cancelaExecucao(oParametros) CLASS MrpAplicacao

	Local cTicket    := oParametros["ticket"]
	Local oStatus    := Nil
	Local oDados     := Nil
	Local oLogs      := Nil

	Default oParametros := JsonObject():New()

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	oStatus := MrpDados_Status():New(cTicket)
	If oStatus:getStatus("status") != "3"      //Conclu�do
		oStatus:setStatus("status", "4")       //Cancelado
	EndIf

	//Leitura parametros de entrada JSON
	::parametrosDefault(@oParametros)

	//Cria chave de execucao
	oParametros["cChaveExec"]       := "MRP_TICKET_" + cTicket
	oParametros["cSemaforoThreads"] := "MRP_T" + Right(cTicket,3) + "_C"

	//Instancia classe de log's
	oLogs := MrpDados_Logs():New(oParametros)

	//Instancia classe de dados em mem�ria - Recursiva
	oDados := MrpDados():New(oParametros, , oLogs, .T.)

	oStatus:persistir(oDados)

	//Status da thread master de execu��o do MRP. Se estiver com conte�do 1, � pq ocorreu algum erro em sua execu��o
	//e o cancelamento deve seguir independente do conte�do de oStatus:getStatus("finalizado")
	cStatThrMs := GetGlbValue('THREAD_MASTER_'+cTicket)
	cStatThrMs := IIf(Empty(cStatThrMs), "0", cStatThrMs)

	If oStatus:getStatus("status") == "4" .And.;                                    //Cancelado
	   (oStatus:getStatus("finalizado") $ '|true|1|' .Or. cStatThrMs == "1") .And.; //Execu��o do C�lculo Conclu�da, N�o Iniciada ou com erro na thread principal
	   oStatus:getStatus("cargaInicialConcluida") == '2'                            //Carga Inicial Conclu�da

		If  oStatus:getStatus("memoria_inicial") == "3" //Em Mem�ria
			oLogs:log(STR0035, "R")                     //Processamento cancelado, memoria descarregada!
			If ::oDominio == Nil
				::oDominio := MrpDominio():New(oParametros, oLogs, .T.)
			EndIf
			::oDominio:destruir()
		EndIf

	EndIf

Return

/*/{Protheus.doc} percentualCalculo
Retorna o percentual de C�lculo
@author    brunno.costa
@since     31/07/2019
@version 1.0
@param 01 - oParametros, JSON  , parametros de entrada no formato JSON
@cReturn, caracter, string com o percentual de c�lculo do MRP
/*/
METHOD calculoPercentual(oParametros) CLASS MrpAplicacao

	Local oStatus
	Local oDados
	Local oLogs
	Local cTicket  := oParametros["ticket"]
	Local cReturn  := "0 %"
	Local nPercent := 0

	Default oParametros := JsonObject():New()

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	oStatus    := MrpDados_Status():New(cTicket)
	If oStatus:getStatus("calculo") == "2"
		//Leitura parametros de entrada JSON
		::parametrosDefault(@oParametros)

		//Cria chave de execucao
		oParametros["cChaveExec"]       := "MRP_TICKET_" + cTicket
		oParametros["cSemaforoThreads"] := "MRP_T" + Right(cTicket,3) + "_I"

		//Instancia classe de log's
		oLogs := MrpDados_Logs():New(oParametros)

		//Instancia classe de dados em mem�ria - Recursiva
		oDados   := MrpDados():New(oParametros, , oLogs, .T.)
		nPercent := oDados:oProdutos:getflag("calculationPercentage")
		If !Empty(nPercent)
			cReturn  := cValToChar(nPercent) + "%"
		EndIf

	ElseIf oStatus:getStatus("calculo") == "3"
		cReturn := "100 %"

	ElseIf oStatus:getStatus("calculo") == "4"
		cReturn := "X %"

	Else
		cReturn := "0 %"

	EndIf

Return cReturn

/*/{Protheus.doc} cargaPercentual
Retorna o percentual de Carga em Mem�ria do MRP
@author    brunno.costa
@since     31/07/2019
@version 1.0
@param 01 - oParametros, JSON  , parametros de entrada no formato JSON
@cReturn, caracter, string com o percentual de carga em mem�ria do MRP
/*/
METHOD cargaPercentual(oParametros) CLASS MrpAplicacao

	Local oStatus
	Local oLogs
	Local cTicket  := oParametros["ticket"]
	Local cReturn  := "0 %"
	Local nPercent := 0

	Default oParametros := JsonObject():New()

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	oStatus := MrpDados_Status():New(cTicket)

	If !(oStatus:getStatus("memoria") $ "3|4")
		//Leitura parametros de entrada JSON
		::parametrosDefault(@oParametros)

		//Cria chave de execucao
		oParametros["cChaveExec"]       := "MRP_TICKET_" + cTicket
		oParametros["cSemaforoThreads"] := "MRP_T" + Right(cTicket,3) + "_I"

		//Instancia classe de log's
		oLogs := MrpDados_Logs():New(oParametros)

		//Leitura parametros de entrada JSON
		::parametrosDefault(@oParametros)

		nPercent := oLogs:cargaPercentual(oParametros)
		If !Empty(nPercent)
			cReturn  := cValToChar(nPercent) + " %"
		EndIf
	ElseIf oStatus:getStatus("memoria") == "3"
		cReturn := "100 %"

	ElseIf oStatus:getStatus("memoria") == "4"
		cReturn := "100 %"
	EndIf

Return cReturn

/*/{Protheus.doc} eventoPercentual
Retorna o percentual de Carga em Mem�ria do MRP
@author    brunno.costa
@since     31/07/2019
@version 1.0
@param 01 - oParametros, JSON    , parametros de entrada no formato JSON
@param 02 - cStatus    , caracter, retorna por refer�ncia o status do evento
@cReturn, caracter, string com o percentual de carga em mem�ria do MRP
/*/
METHOD eventoPercentual(oParametros, cStatus) CLASS MrpAplicacao

	Local cTicket  := oParametros["ticket"]
	Local cReturn  := "0 %"
	Local nPercent := 0
	Local oStatus

	Default oParametros := JsonObject():New()

	SET DATE FRENCH; Set(_SET_EPOCH, 1980)

	oStatus := MrpDados_Status():New(cTicket)
	cStatus := oStatus:getStatus("documentEventLogStatus")
	If cStatus == "2"
		nPercent := oStatus:getStatus("documentEventLogPercentage")
		If Empty(nPercent)
			cReturn := "0 %"
		Else
			cReturn := cValToChar(nPercent) + "%"
		EndIf

	ElseIf cStatus == "3"
		cReturn := "100 %"

	ElseIf cStatus == "4"
		cReturn := "X %"

	Else
		cReturn := "0 %"

	EndIf

Return cReturn

/*/{Protheus.doc} rasDemPercentual
Retorna o percentual da gera��o de rastreabilidade de demandas

@author lucas.franca
@since 30/11/2022
@version P12
@param 01 oParametros, Object  , Objeto com os par�metros do MRP
@param 02 cStatus    , Caracter, Retorna por refer�ncia o status do processo
@return cReturn, Caracter, String com o percentual do processo
/*/
METHOD rasDemPercentual(oParametros, cStatus) CLASS MrpAplicacao

	Local cTicket  := oParametros["ticket"]
	Local cReturn  := "0 %"
	Local nPercent := 0
	Local oStatus  := Nil

	oStatus := MrpDados_Status():New(cTicket)
	cStatus := oStatus:getStatus("rastreiaEntradasStatus")
	If cStatus == "2"
		nPercent := oStatus:getStatus("rastreiaEntradasPercentage")
		If !Empty(nPercent)
			cReturn := cValToChar(nPercent) + "%"
		EndIf

	ElseIf cStatus == "3"
		cReturn := "100 %"
	EndIf

Return cReturn

/*/{Protheus.doc} executar
Metodo de execucao do MRP
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oParametros, JSON, parametros de entrada no formato JSON
/*/
METHOD executar(oParametros) CLASS MrpAplicacao
	Local aEvents 	 := {}
	Local aParam     := {}
	Local cOpcionais := ""
	Local cTimes     := ""
	Local cStatus    := ""
	Local lAnTempo
	Local lExporta   := .F.
	Local lOk        := .T.
	Local nMemoria1  := 0
	Local nMemoria2  := 0
	Local nMemoria3  := 0
	Local nMemoria5  := 0
	Local nSecIni    := 0
	Local nSecCarga  := 0
	Local nSecLoop   := 0
	Local nSecExp    := 0
	Local nSecFim    := 0
	Local nSecAux    := 0
	Local nResults   := 0
	Local nThrRAS    := 1
	Local nThrMAT    := 1
	Local nThrAGL    := 1
	Local nThrEVT    := 1
	Local nThr       := 1
	Local oLogs
	Local oSaida     := MrpDominio_Saida():New()
	Local oStatus    := MrpDados_Status():New(oParametros["ticket"])

	Default oParametros := JsonObject():New()

	sCRLF := Iif(sCRLF == Nil, chr(13)+chr(10), sCRLF)

	oStatus:setStatus("finalizado", "false")

	//Se o processamento foi cancelado por algum erro, n�o prossegue com a execu��o
	If oStatus:getStatus("status") == "4"//Cancelado
		Return
	EndIf

	//Seta Status Global
	oStatus:setStatus("status" , "2")             //'Iniciado'

	//Leitura parametros de entrada JSON
	::parametrosDefault(@oParametros)
	lAnTempo   := ::oParametros["lAnTempo"]

	oStatus:setStatus("rastreiaEntradasStatus", "1") //N�o iniciado
	oStatus:setStatus("rastreiaEntradasPercentage", 0)

	oLogs := MrpDados_Logs():New(oParametros)
	oLogs:log(STR0001, "0", @nMemoria1) //"Inicio execucao do MRP."

	//Loga os parametros
	oLogs:log(STR0027 + sCRLF + StrTran(oParametros:toJson(), ",", "," + sCRLF) + sCRLF      , "P") //" - Parametros Json: "

	//Inicializa objeto da classe de Dominio - Carga dos dados em memoria
	nSecIni    := Iif(lAnTempo, Seconds(), 0)
	::oDominio := MrpDominio():New(oParametros, oLogs)
	nSecCarga  := Iif(lAnTempo, Seconds(), 0)

	If AllTrim(::oParametros["cAutomacao"]) == "2"
		While .T.
			Sleep(50)
			If oStatus:getStatus("memoria_inicial") == "3"; //Em Mem�ria
			   .OR. oStatus:getStatus("status") == "4";     //Cancelado
			   .OR. oStatus:getStatus("memoria") == "4"     //Descarregado
			   Exit
			EndIf
		End
	EndIf

	//Seta Status Global e em Disco
	If oStatus:getStatus("memoria") <> "9" //"Erro"
		oStatus:setStatus("memoria", "3") //Em Mem�ria
		oStatus:setStatus("calculo", "2") //Em Andamento
	EndIf
	oStatus:persistir(::oDominio:oDados)

	//Ajusta quantidade de Threads para Exporta��o
	If AllTrim(::oParametros["cAutomacao"]) != "0" .OR. ::oParametros["nThreads_MAT"] == 0
		::oParametros["nThreads_RAS"] := 1
		::oParametros["nThreads_MAT"] := 1
		::oParametros["nThreads_AGL"] := 1
		::oParametros["nThreads_EVT"] := 1
		GetGlbVars("PCP_aParam" + oParametros["ticket"], @aParam)
		aParam[1] := ::oParametros:toJson()
		PutGlbVars("PCP_aParam" + oParametros["ticket"], aParam)
	EndIf

	//Inicia a abertura de threads para utiliza��o na exporta��o
	If ::oParametros["nThreads_AGL"] > 1 .And. oStatus:getStatus("status") != "4"
		PCPIPCStart(::oParametros["cSemaforoThreads"] + "AGL", ::oParametros["nThreads_AGL"], 0, ::oParametros["cEmpAnt"], ::oParametros["cFilAnt"], "PCPA712_MRP_" + oParametros["ticket"]) //Inicializa as Threads
	EndIf
	If ::oParametros["nThreads_MAT"] > 1 .And. oStatus:getStatus("status") != "4"
		PCPIPCStart(::oParametros["cSemaforoThreads"] + "MAT", ::oParametros["nThreads_MAT"], 0, ::oParametros["cEmpAnt"], ::oParametros["cFilAnt"], "PCPA712_MRP_" + oParametros["ticket"]) //Inicializa as Threads
	EndIf
	If ::oParametros["nThreads_EVT"] > 1 .And. oStatus:getStatus("status") != "4" .AND. ::oDominio:oEventos:lHabilitado
		PCPIPCStart(::oParametros["cSemaforoThreads"] + "EVT", ::oParametros["nThreads_EVT"], 0, ::oParametros["cEmpAnt"], ::oParametros["cFilAnt"], "PCPA712_MRP_" + oParametros["ticket"]) //Inicializa as Threads
	EndIf

	If oStatus:getStatus("status") != "4"//N�o Cancelado
		//Inicia a grava��o em disco da tabela SMV (documentos considerados na carga em mem�ria)
		::oDominio:oDados:oMatriz:setFlag("TERMINO_GRAVACAO_SMV", "N")
		oSaida:exportarDocumentos(::oDominio)

		//Percorre os niveis de produtos - Efetua calculo do MRP por nivel + produto
		::oDominio:loopNiveis()
		nSecLoop   := Iif(lAnTempo, Seconds(), 0)
		oLogs:log(STR0002, "0", @nMemoria2) //"Apos finalizar o loop de niveis"
	EndIf

	//Seta Status Global e em Disco
	If oStatus:getStatus("status") != "4" //!Cancelado
		oStatus:setStatus("calculo", "3") //Conclu�do
		oStatus:setStatus("persistencia", "2") //Em Andamento
		oStatus:persistir(::oDominio:oDados)
		oLogs:log(STR0016, "0", @nMemoria5) //Fim calculo do MRP
	Else
		oStatus:setStatus("calculo", "4") //Cancelado
	EndIf

	//Atualiza os registros processados
	If oStatus:getStatus("status") != "4"//N�o Cancelado
		::oDominio:registraProcessados()
	EndIf

	If oStatus:getStatus("status") != "4"
		nResults := ::oDominio:oDados:tamanhoLista("MAT")
		If nResults < 200
			//Ajusta para executar single threads quando existem poucos dados
			nThrRAS := ::oParametros["nThreads_RAS"]
			nThrMAT := ::oParametros["nThreads_MAT"]
			nThrAGL := ::oParametros["nThreads_AGL"]
			nThrEVT := ::oParametros["nThreads_EVT"]
			nThr    := ::oParametros["nThreads"    ]

			::oParametros["nThreads_RAS"] := 1
			::oParametros["nThreads_MAT"] := 1
			::oParametros["nThreads_AGL"] := 1
			::oParametros["nThreads_EVT"] := 1
			::oParametros["nThreads"    ] := 1
		EndIf
	EndIf

	//Exporta dados de Rastreio - !N�o Cancelado
	If oStatus:getStatus("status") != "4"
		oSaida:exportarRastreio(::oDominio)
	EndIf

	//Exporta dados de Rastreio - !N�o Cancelado
	If oStatus:getStatus("status") != "4"
		oSaida:exportarAglutinacaoRastreio(::oDominio)
	EndIf

	//Exporta resultados para HWB - !N�o Cancelado
	If oStatus:getStatus("status") != "4"
		oSaida:exportarResultados(@nResults, ::oDominio)
		lExporta := .T.
	EndIf

	If nResults < 200 .And. oStatus:getStatus("status") != "4"
		::oParametros["nThreads_RAS"] := nThrRAS
		::oParametros["nThreads_MAT"] := nThrMAT
		::oParametros["nThreads_AGL"] := nThrAGL
		::oParametros["nThreads_EVT"] := nThrEVT
		::oParametros["nThreads"    ] := nThr
	EndIf

	//Processa dados de Rastreio de Entradas ap�s exporta��o da HWC/HWG
	//Tamb�m ir� disparar a grava��o dos resultados na SME ap�s o processamento.
	If oStatus:getStatus("status") != "4" .And. ::oParametros["lRastreiaEntradas"]
		::oDominio:oRastreioEntradas:procDocHWC()
	EndIf

	//Exporta dados da Opcionais - !N�o Cancelado
	If oStatus:getStatus("status") != "4"
		cOpcionais := oSaida:exportarOpcionais(::oDominio)
	EndIf

	//Exporta dados de Log de Eventos For�ados !N�o Cancelado e Existir evento 10 registrado.
	::oDominio:oDados:oEventos:getAllAlist("010",@aEvents ,.T.) 
	If oStatus:getStatus("status") != "4" .And. !Empty(aEvents)
		oSaida:exportarEventos(::oDominio,{'010'})
		aSize(aEvents, 0)
	EndIf
	
	//Exporta dados de Log de Eventos - !N�o Cancelado e Loga Eventos 
	If oStatus:getStatus("status") != "4" .And. ::oParametros["lEventLog"]
		oSaida:exportarEventos(::oDominio)
	EndIf

	//Exporta dados de transfer�ncias
	If oStatus:getStatus("status") != "4" .And. ::oDominio:oMultiEmp:utilizaMultiEmpresa()
		oSaida:exportarTransferencia(::oDominio)
	EndIf

	//Se existe dado para exportar, aguarda o t�rmino para prosseguir
	If lExporta
		oSaida:aguardaTermino(::oDominio)

		//Se utiliza multi-empresa, gera dados complementares da HWB para as filiais processadas.
		If oStatus:getStatus("status") != "4" .And. ::oDominio:oMultiEmp:utilizaMultiEmpresa()
			oSaida:exportarComplementoHWB(::oDominio)
		EndIf
	EndIf

	//Verifica se a tabela SMV j� foi gravada antes de indicar o t�rmino do MRP.
	oSaida:aguardaSMV(::oDominio)

	//Grava status da persist�ncia dos dados
	cStatus := oStatus:getStatus("status")
	If cStatus != "4" //Verifica se houve cancelamento.
		cStatus := "3" //Se n�o houve cancelamento, utiliza o status de Conclu�do.
	EndIf
	oStatus:setStatus("persistencia", cStatus)
	//Persiste a atualiza��o de status.
	oStatus:persistir(::oDominio:oDados)

	//Aguarda t�rmino da gera��o da rastreabilidade -> J� valida utiliza��o da rastreabilidade dentro do aguardaEntradas
	oSaida:aguardaEntradas(::oDominio)

	nSecExp := Iif(lAnTempo, Seconds(), 0)

	If oStatus:getStatus("status") != "4" //!Cancelado
		oLogs:log(STR0003, "0", @nMemoria3)//"Apos exportar os resultados"

		If lAnTempo
			cTimes  := sCRLF
			cTimes  += PadR(STR0004,  7, " ") + " ; " //"Prefixo"
			cTimes  += PadR(STR0042, 35, " ") + " ; " //"Etapa"
			cTimes  += PadR(STR0043, 10, " ") + " ; " //"Tempo(seg)"
			cTimes  += STR0044 + " ; "                //"Periodos"
			cTimes  += STR0045 + " ; "                //"Memoria"
			cTimes  += STR0046 + " ; "                //"Resultados"
			cTimes  += STR0047 + " ; "                //"Threads"
			cTimes  +=  sCRLF

			lOk     := .T.
			nSecAux := oStatus:getStatus("tempo_selecao_parametros_tela", @lOk)
			nSecAux := Iif(!lOk .OR. Empty(nSecAux), 0, Round(nSecAux, 1))
			cTimes  += "PCPA712 ; " + PadR(STR0040, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria1) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "0. Selecao de Parametros" + " MB;"

			lOk     := .T.
			nSecAux := oStatus:getStatus("tempo_sincronizacao", @lOk)
			nSecAux := Iif(!lOk .OR. Empty(nSecAux), 0, Round(nSecAux, 1))
			cTimes  += "PCPA712 ; " + PadR(STR0036, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria1) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "1. Sincronizacao" + " MB;"

			nSecAux := Round(nSecCarga - nSecIni, 1)
			cTimes  += "PCPA712 ; " + PadR(STR0006, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria1) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "2. Carga inicial em memoria;" + " MB;"

			lOk     := .T.
			nSecAux := oStatus:getStatus("tempo_recalculo_niveis", @lOk)
			nSecAux := Iif(!lOk .OR. Empty(nSecAux), 0, Round(nSecAux, 1))
			cTimes  += "PCPA712 ; " + PadR(STR0037, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria1) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "3. Recalculo Niveis Estrutura" + " MB;"

			lOk     := .T.
			nSecAux := oStatus:getStatus("tempo_exlusao_previstos_ini", @lOk)
			nSecAux := Iif(!lOk .OR. Empty(nSecAux), 0, Round(nSecAux, 1))
			cTimes  += "PCPA712 ; " + PadR(STR0038, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria1) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "4. Prepara Exclusao Previstos" + " MB;"

			lOk     := .T.
			nSecAux := oStatus:getStatus("tempo_exlusao_previstos_fim", @lOk)
			nSecAux := Iif(!lOk .OR. Empty(nSecAux), 0, Round(nSecAux, 1))
			cTimes  += "PCPA712 ; " + PadR(STR0039, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria1) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "4. Exclusao Previstos" + " MB;"

			nSecAux := Round(nSecLoop - nSecCarga, 1)
			cTimes  += "PCPA712 ; " + PadR(STR0008, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria2) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "5. Loop Niveis;" + " MB;"

			nSecAux := Round(nSecExp - nSecLoop, 1)
			cTimes  += "PCPA712 ; " + PadR(STR0009, 35, " ") + " ; " + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria3) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "6. Persistencia em Disco;" + " MB;"
		EndIf
	EndIf

	If lAnTempo
		nSecFim := Seconds()
		nSecAux := Round(nSecFim - nSecIni, 1)
		cTimes  += "PCPA712 ; " + PadR(STR0011, 35, " ") + " ; "  + PadL(cValToChar(nSecAux)   , 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria5) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "7. GERAL CALCULO    ;" + " MB;"

		//lOk     := .T.
		//nSecAux := oStatus:getStatus("tempo_geracao_documentos")
		//nSecAux := Iif(!lOk .OR. Empty(nSecAux), 0, Round(MicroSeconds() - nSecAux, 1))
		//cTimes     += "PCPA712 ; " + PadR(STR0010, 35, " ") + " ; "  + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria5) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "8. Geracao de Documentos" + " MB;"

		lOk     := .T.
		nSecAux := oStatus:getStatus("tempo_espera", @lOk)
		nSecAux := Iif(!lOk .OR. Empty(nSecAux), 0, Round(MicroSeconds() - nSecAux, 1))
		cTimes     += "PCPA712 ; " + PadR(STR0010, 35, " ") + " ; "  + PadL(cValToChar(nSecAux), 10, " ") + " ; " + cValToChar(::oParametros["nPeriodos"]) + " ; " + cValToChar(nMemoria5) + STR0007 + " ; " + cValToChar(nResults) + " ; " + cValToChar(::oParametros["nThreads"]) + sCRLF //"executar;" + "9. ESPERA USUARIO;" + " MB;"
	EndIf

	If oStatus:getStatus("status") != "4" //!Cancelado
		oLogs:log(cTimes, "R")
	EndIf

	//Seta Status Global
	If oStatus:getStatus("status") != "4" //!Cancelado
		oStatus:setStatus("status"  , "3") //Finalizado
	Else
		oLogs:log(STR0035, "R") //"Processamento cancelado, memoria descarregada!"
	EndIf
	
	oStatus:persistir(::oDominio:oDados)

	//Destroi objeto da camada de dominio
	::oDominio:destruir()

	If oStatus:getStatus("status") != "4" //!Cancelado
		cTimes := "PCPA712 ; " + PadR(STR0014, 35, " ") + " ; " + cValToChar(Seconds() - nSecFim) //"executar;" + "7. Tempo destroi;" + " MB;"
		oLogs:log(cTimes, "R", , , , .T.)
	EndIf

	sCRLF := Nil

	If ::oParametros['lAguardaDescarga']
	    If oStatus:getStatus("memoria") <> "9"
	    	oStatus:setStatus("memoria", "4") //Descarregado
		EndIf
	    oStatus:persistir(::oDominio:oDados)
	Else
	    oStatus:persistir(::oDominio:oDados)
	EndIf
	oStatus:setStatus("finalizado", "true")

Return

/*/{Protheus.doc} parametrosDefault
Ajusta parametros default no objeto JSON
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oParametros, JSON  , parametros de entrada no formato JSON

Regras de Negocio:
-> dDataIni          , data    , data de inicio para calculo do MRP
-> lHorizonteFirme   , logico  , indicador de utiliza��o do horizonte firme
-> lEstoqueSeguranca , logico  , indicador de aplicacao do estoque de seguranca
-> lPontoPedido      , logico  , indicador de aplicacao do ponto de pedido
-> nPeriodos         , numerico, indica a quantidade de periodos do calculo
-> nTipoPeriodos     , numerico, indica o tipo de periodo do calculo - conforme MrpDominio_Periodos.prw

Regras de processamento:
-> lPorNivel         , logico  , indica a forma de processamento: .T.= nivel por nivel, .F.= multi-nivel
-> nThreads          , numerico, indica o numero de Threads que devera ser utilizado

Analise de performance x Logs x debug:
-> processLogs       , caracter, indicador de geracao de log's (detalhamento no arquivo MRPDados_Logs)
-> cLogsMemoria      , caracter, indicador de analise de memoria referente IDs processLogs - pre requisito: processLogs
-> cLogsModo         , caracter, indica o modo de geracao dos log's: 0 - Conout, 1 - Arquivo de log (lento - execucao por execucao), 2 - Arquivo de log a cada X caracteres (+ rapido); A - Conout + tipo 2
-> lAnTempo          , logico  , indica se deve realizar analise de tempo
-> nPilhaFunc        , numerico, indica a quantidade de funcoes listadas na pilha de chamadas do log
-> cFiltroLog        , caracter, indica conteudo que deve conter no log

/*/
METHOD parametrosDefault(oParametros) CLASS MrpAplicacao

	//Defini��o de ambiente
	oParametros['cEmpAnt'                      ] := Iif(Empty(oParametros['cEmpAnt'])                 , ""                 , oParametros['cEmpAnt'                    ])
	oParametros['cFilAnt'                      ] := Iif(Empty(oParametros['cFilAnt'])                 , ""                 , oParametros['cFilAnt'                    ])

	//Regra de negocio
	oParametros['lRastreia'                    ] := Iif(oParametros['lRastreia'                  ] == Nil, .T.             , oParametros['lRastreia'                  ])
	oParametros['lRastreiaEntradas'            ] := Iif(oParametros['lRastreiaEntradas'          ] == Nil, .F.             , oParametros['lRastreiaEntradas'          ])
	oParametros['dDataIni'                     ] := Iif(Empty(oParametros['dDataIni'])                   , Date()          , oParametros['dDataIni'                   ])
	oParametros['lDETerceiro'                  ] := Iif(oParametros['lDETerceiro'                ] == Nil, .T.             , oParametros['lDETerceiro'                ])
	oParametros['lEMTerceiro'                  ] := Iif(oParametros['lEMTerceiro'                ] == Nil, .T.             , oParametros['lEMTerceiro'                ])
	oParametros['lHorizonteFirme'              ] := Iif(oParametros['lHorizonteFirme'            ] == Nil, .F.             , oParametros['lHorizonteFirme'            ])
	oParametros['lEstoqueSeguranca'            ] := Iif(oParametros['lEstoqueSeguranca'          ] == Nil, .T.             , oParametros['lEstoqueSeguranca'          ])
	oParametros['lPontoPedido'                 ] := Iif(oParametros['lPontoPedido'               ] == Nil, .T.             , oParametros['lPontoPedido'               ])
	oParametros['nPeriodos'                    ] := Iif(oParametros['nPeriodos'                  ] == Nil, 30              , oParametros['nPeriodos'                  ])
	oParametros['nTipoPeriodos'                ] := Iif(oParametros['nTipoPeriodos'              ] == Nil, 1               , oParametros['nTipoPeriodos'              ])
	oParametros['dInicioDemandas'              ] := Iif(oParametros['dInicioDemandas'            ] == Nil, StoD("19800101"), ConvDate(oParametros['dInicioDemandas'   ]))
	oParametros['dFimDemandas'                 ] := Iif(oParametros['dFimDemandas'               ] == Nil, StoD("20491231"), ConvDate(oParametros['dFimDemandas'      ]))
	oParametros['lDemandsProcessed'            ] := Iif(oParametros['lDemandsProcessed'          ] == Nil, .F.             , oParametros['lDemandsProcessed'          ])
	oParametros['cDemandType'                  ] := Iif(oParametros['cDemandType'                ] == Nil, ""              , oParametros['cDemandType'                ])
	oParametros['cDocumentType'                ] := Iif(oParametros['cDocumentType'              ] == Nil, ""              , oParametros['cDocumentType'              ])
	oParametros['cDocuments'                   ] := Iif(oParametros['cDocuments'                 ] == Nil, ""              , oParametros['cDocuments'                 ])
	oParametros['cProductGroups'               ] := Iif(oParametros['cProductGroups'             ] == Nil, ""              , oParametros['cProductGroups'             ])
	oParametros['cProductTypes'                ] := Iif(oParametros['cProductTypes'              ] == Nil, ""              , oParametros['cProductTypes'              ])
	oParametros['cWarehouses'                  ] := Iif(oParametros['cWarehouses'                ] == Nil, ""              , oParametros['cWarehouses'                ])
	oParametros['nStructurePrecision'          ] := Iif(oParametros['nStructurePrecision'        ] == Nil, 7               , oParametros['nStructurePrecision'        ])
	oParametros["lPackingQuantityFirst"        ] := Iif(oParametros["lPackingQuantityFirst"      ] == Nil, .F.             , oParametros["lPackingQuantityFirst"      ])
	oParametros["lProductionOrderPerLot"       ] := Iif(oParametros["lProductionOrderPerLot"     ] == Nil, .F.             , oParametros["lProductionOrderPerLot"     ])
	oParametros["lPurchaseRequestPerLot"       ] := Iif(oParametros["lPurchaseRequestPerLot"     ] == Nil, .F.             , oParametros["lPurchaseRequestPerLot"     ])
	oParametros["lBreakByMinimunLot"           ] := Iif(oParametros["lBreakByMinimunLot"         ] == Nil, .F.             , oParametros["lBreakByMinimunLot"         ])
	oParametros["lMinimunLotAsEconomicLot"     ] := Iif(oParametros["lMinimunLotAsEconomicLot"   ] == Nil, .T.             , oParametros["lMinimunLotAsEconomicLot"   ])
	oParametros['lExpiredLot'                  ] := Iif(oParametros['lExpiredLot'                ] == Nil, .T.             , oParametros['lExpiredLot'                ])
	oParametros["cConsolidatePurchaseRequest"  ] := Iif(oParametros['cConsolidatePurchaseRequest'] == Nil, "3"             , oParametros['cConsolidatePurchaseRequest'])
	oParametros["cConsolidateProductionOrder"  ] := Iif(oParametros['cConsolidateProductionOrder'] == Nil, "3"             , oParametros['cConsolidateProductionOrder'])
	oParametros["lUsesProductIndicator"        ] := Iif(oParametros['lUsesProductIndicator'      ] == Nil, .F.             , oParametros['lUsesProductIndicator'      ])
	oParametros["lUsesInProcessLocation"       ] := Iif(oParametros['lUsesInProcessLocation'     ] == Nil, .F.             , oParametros['lUsesInProcessLocation'     ])
	oParametros["cInProcessLocation"           ] := Iif(oParametros['cInProcessLocation'         ] == Nil, "99"            , oParametros['cInProcessLocation'         ])
	oParametros['lGeraDoc'                     ] := Iif(oParametros['lGeraDoc'                   ] == Nil, .F.             , oParametros['lGeraDoc'                   ])
	oParametros["lUsesLaborProduct"            ] := Iif(oParametros['lUsesLaborProduct'          ] == Nil, .F.             , oParametros['lUsesLaborProduct'          ])
	oParametros["cStandardTimeUnit"            ] := Iif(oParametros['cStandardTimeUnit'          ] == Nil, "H"             , oParametros['cStandardTimeUnit'          ])
	oParametros["cUnitOfLaborInTheBOM"         ] := Iif(oParametros['cUnitOfLaborInTheBOM'       ] == Nil, "N"             , oParametros['cUnitOfLaborInTheBOM'       ])
	oParametros["lSubtraiRejeitosCQ"           ] := Iif(oParametros['lSubtraiRejeitosCQ'         ] == Nil, .F.             , oParametros['lSubtraiRejeitosCQ'         ])
	oParametros["transportingLanes"            ] := Iif(oParametros['transportingLanes'          ] == Nil, "2"             , oParametros['transportingLanes'          ])

	//Regras de processamento
	oParametros['cAutomacao'                   ] := Iif(oParametros['cAutomacao'                 ] == Nil, "0"             , oParametros['cAutomacao'                 ])
	oParametros['lPorNivel'                    ] := Iif(oParametros['lPorNivel'                  ] == Nil, .T.             , oParametros['lPorNivel'                  ])
	oParametros['nThreads'                     ] := Iif(oParametros['nThreads'                   ] == Nil, 8               , oParametros['nThreads'                   ])
	oParametros['nThreads_MAT'                 ] := Iif(oParametros['nThreads_MAT'               ] == Nil, 4               , oParametros['nThreads_MAT'               ])
	oParametros['nThreads_RAS'                 ] := Iif(oParametros['nThreads_RAS'               ] == Nil, 8               , oParametros['nThreads_RAS'               ])
	oParametros['nThreads_AGL'                 ] := Iif(oParametros['nThreads_AGL'               ] == Nil, 6               , oParametros['nThreads_AGL'               ])
	oParametros['nThreads_EVT'                 ] := Iif(oParametros['nThreads_EVT'               ] == Nil, 6               , oParametros['nThreads_EVT'               ])
	oParametros['nThreads'                     ] := Iif(oParametros['nThreads'                   ] == 1  , 0               , oParametros['nThreads'                   ]) //Altera para 0 Thread quando 1: 1 Thread e pior do que Zero (Nenhuma adicional. Configurar Thread a partir de 2)
	oParametros['nRecursivas_LiveLock'         ] := Iif(oParametros['nRecursivas_LiveLock'       ] == Nil, 1               , oParametros['nRecursivas_LiveLock'       ]) //Tentativas consecutivas da mesma Thread calcular o produto apos necessidade de reinicio devido a LiveLock
	oParametros['nOpcCarga'                    ] := Iif(oParametros['nOpcCarga'                  ] == Nil, 0               , oParametros['nOpcCarga'                  ])
	oParametros['cSemaforoThreads'             ] := Iif(oParametros['cSemaforoThreads'           ] == Nil, "PCPMRP"        , oParametros['cSemaforoThreads'           ])
	oParametros['nX_Para_Cancel'               ] := Iif(oParametros['nX_Para_Cancel'             ] == Nil, 50              , oParametros['nX_Para_Cancel'             ])
	oParametros["cChaveExec"                   ] := Iif(oParametros['cChaveExec'                 ] == Nil, "MRP_P" + cValToChar(oParametros["nPeriodos"]) + "_D" + DtoS(Date()) + "_H" + StrTran(Time(),":","") + "_T" + cValToChar(oParametros["nThreads"]), oParametros['cChaveExec'])
	oParametros['lAguardaDescarga'             ] := Iif(oParametros['lAguardaDescarga'           ] == Nil, .F.             , oParametros['lAguardaDescarga'           ])

	//Analise de performance x Logs
	oParametros['processLogs'                  ] := Iif(Empty(oParametros['processLogs'])                  , "|L|E|F|T|R|" , oParametros['processLogs'                ])
	//oParametros['processLogs'                ] := Iif(Empty(oParametros['processLogs'])                  , "|27|34|L|E|F|T|R|R1|R2|R3|R4|R5|R6|R7|R8|R9"  , oParametros['processLogs'])
	//oParametros['processLogs'                ] := Iif(Empty(oParametros['processLogs'])                  , "|L|E|F|T|R|CM|P|", oParametros['processLogs'])
	//oParametros['processLogs'                ] := Iif(Empty(oParametros['processLogs'])                  , "|L|E|F|T|R|CS|%|", oParametros['processLogs'])
	//oParametros['processLogs'                ] := Iif(Empty(oParametros['processLogs'])                  , "|L|E|F|T|R||9|L|C|E|F|T|R|P|CS|1|2|7|9|10|16|5|27|%", oParametros['processLogs'])
	//oParametros['processLogs'                ] := Iif(Empty(oParametros['processLogs'])                  , "|CS|L|E|F|T|R||L|C|E|F|T|R|P|1|2|4|5|7|8|9|10|11|16|24|23|34|%", oParametros['processLogs'])
	//oParametros['processLogs'                ] := Iif(Empty(oParametros['processLogs'])                  , "*", oParametros['processLogs'])

	oParametros['cNOTLogsImpre'                ] := Iif(Empty(oParametros['cNOTLogsImpre'])                , ""            , oParametros['cNOTLogsImpre'                ])
	oParametros['lLogML'                       ] := Iif(Empty(oParametros['lLogML']    )                   , .T.           , oParametros['lLogML'                       ])
	oParametros['cLogsMemoria'                 ] := Iif(Empty(oParametros['cLogsMemoria'])                 , ""            , oParametros['cLogsMemoria'                 ])
	oParametros['cLogsModo'                    ] := Iif(Empty(oParametros['cLogsModo'])                    , "0"           , oParametros['cLogsModo'                    ])
	oParametros['lAnTempo'                     ] := Iif(oParametros['lAnTempo'                   ] == Nil  , .T.           , oParametros['lAnTempo'                     ])
	oParametros['nPilhaFunc'                   ] := Iif(oParametros['nPilhaFunc'                 ] == Nil  , 3             , oParametros['nPilhaFunc'                   ])
	oParametros['cFiltroLog'                   ] := Iif(Empty(oParametros['cFiltroLog'])                   , ""            , oParametros['cFiltroLog'                   ])
	oParametros['lAnalisaMemoriaPosCarga'      ] := Iif(oParametros['lAnalisaMemoriaPosCarga'    ] == Nil  , .F.           , oParametros['lAnalisaMemoriaPosCarga'      ])
	oParametros['lAnalisaMemoriaPosLoop'       ] := Iif(oParametros['lAnalisaMemoriaPosLoop'     ] == Nil  , .F.           , oParametros['lAnalisaMemoriaPosLoop'       ])
	oParametros['lAnalisaMemoriaSplit'         ] := Iif(oParametros['lAnalisaMemoriaSplit'       ] == Nil  , .F.           , oParametros['lAnalisaMemoriaSplit'         ])
	oParametros['lAnalisaMemoriaPosExpRastreio'] := Iif(oParametros['lAnalisaMemoriaPosExpRastreio'] == Nil, .F.           , oParametros['lAnalisaMemoriaPosExpRastreio'])
	oParametros['lEventLog'                    ] := Iif(oParametros['lEventLog'                    ] == Nil, .F.           , oParametros['lEventLog'                    ])
	oParametros['memoryLoadType'               ] := Iif(oParametros['memoryLoadType'               ] == Nil, "0"           , oParametros['memoryLoadType'               ])
	oParametros['revisionInProductIndicator'   ] := Iif(oParametros['revisionInProductIndicator'   ] == Nil, "2"           , oParametros['revisionInProductIndicator'   ])

	If At("ML", oParametros['processLogs']) <= 0
		//Desabilita log de monitor de lock se n�o for especificado no par�metro. Utilizando quando MV_LOGMRP = *
		oParametros['lLogML'] := .F.
	EndIf

	If ValType(oParametros['dDataIni']) == "C"
		oParametros['dDataIni'] := Replace(oParametros['dDataIni'], "\", "")
		oParametros['dDataIni'] := Replace(oParametros['dDataIni'], "/", "")
		oParametros['dDataIni'] := Replace(oParametros['dDataIni'], "-", "")
		oParametros['dDataIni'] := StoD(oParametros['dDataIni'])
	EndIf

	//Atribui objeto a propriedade da classe
	::oParametros := oParametros

Return

/*/{Protheus.doc} ConvDate
Fun��o para convers�o de data
@author lucas.franca
@since 22/10/2019
@version P12
@param cData, string de data YYYY-MM-DD
@return dData, data, data para convers�o
/*/
Static Function ConvDate(cData)
	Local dData := cData

	If ValType(cData) == "C"
		dData := StoD(StrTran(cData,'-',''))
	EndIf

Return dData
