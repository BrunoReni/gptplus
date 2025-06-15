#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA152.CH"

// Nome das etapas
#DEFINE CHAR_ETAPAS_ABERTURA  "abertura"
#DEFINE CHAR_ETAPAS_CALC_DISP "calculo_disponibilidade"
#DEFINE CHAR_ETAPAS_CALC_TEMP "calculo_tempo_operacao"
#DEFINE CHAR_ETAPAS_DIST_ORD  "distribui_ordem"
#DEFINE CHAR_ETAPAS_GRAVACAO  "gravacao_resultado"

// Status da programa��o
#DEFINE STATUS_PENDENTE         "0"
#DEFINE STATUS_EXECUCAO         "1"
#DEFINE STATUS_DISTRIBUIDO      "2"
#DEFINE STATUS_CANCELADO        "3"
#DEFINE STATUS_DISP_GERADA      "4"
#DEFINE STATUS_TEMPOS_CALCULADO "5"
#DEFINE STATUS_DIST_CONCLUIDA   "6"
#DEFINE STATUS_ERRO             "9"

// Tempo de espera para aguardar a abertura das threads.
// Cada unidade representa um sleep de 100ms
#DEFINE TEMPO_AGUARDA_ABERTURA 600
#DEFINE MAXIMO_THREADS_ABERTAS 4

// Tipos para cada par�metro
#DEFINE PAR_TIPO_CHAR "|dataInicial|dataFinal|MV_TPHR|"
#DEFINE PAR_TIPO_NUM  "|MV_A152THR|MV_PRECISA|tipoOP|tipoProgramacao|"
#DEFINE PAR_TIPO_BOOL "|visualizaDisponibilidade|MV_PERDINF|"
#DEFINE PAR_TIPO_LIST "|recursos|centroTrabalho|ordemProducao|produto|grupoProduto|tipoProduto|"

// Par�metros MV
#DEFINE PAR_MVS "|MV_A152THR|MV_PRECISA|MV_PERDINF|MV_TPHR|"

// Op��es para o processamentoFactory
#DEFINE FACTORY_OPC_BASE     1
#DEFINE FACTORY_OPC_DISP     2
#DEFINE FACTORY_OPC_TEMPOPER 3

// Define se realiza logs
#DEFINE REALIZA_LOGS .T.

Static _oDisp     := Nil
Static _oProcesso := Nil
Static _oTempOper := Nil

/*/{Protheus.doc} PCPA152
Chamada da tela de Programa��o (PO-UI)

@type Function
@author Marcelo Neumann
@since 02/03/2023
@version P12
@return Nil
/*/
Function PCPA152()

	//Verifica se est� sendo aberto pelo m�dulo SIGAPCP
	If PCPVldModu("PCPA152", {10}) .And. PCPVldApp()
		FwCallApp('pcpa152')
	EndIf

Return Nil

/*/{Protheus.doc} JsToAdvpl
Bloco de c�digo que receber� as chamadas da tela.
@type  Static Function
@author Lucas Fagundes
@since 11/04/2023
@version P12
@param 01 oWebChannel, Object  , Instancia da classe TWebEngine.
@param 02 cType      , Caracter, Parametro de tipo.
@param 03 cContent   , Caracter, Conteudo enviado pela tela.
@return .T.
/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Do Case
		Case cType == "loadData"
			oWebChannel:AdvPLToJS("dataBase", DTOC(dDatabase))
	End
Return .T.

/*/{Protheus.doc} P152Start
Fun��o responsavel por iniciar o processamento do programa.
@type  Function
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param 01 cProg , Caracter, C�digo da programa��o para instanciar a classe de processamento.
@param 02 lStart, Logico  , Indica que est� iniciando a programa��o.
@return Nil
/*/
Function P152Start(cProg, lStart)
	Local oProcesso := Nil

	If !PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)
		Return Nil
	EndIf

	oProcesso:gravaValorGlobal("THREAD_MASTER", "ABERTA")

	If oProcesso:aguardaPermissaoParaIniciar()
		If lStart
			oProcesso:gravaPercentual(CHAR_ETAPAS_ABERTURA, 50)
		EndIf

		If oProcesso:processaAbertura()
			If lStart
				oProcesso:processar()
			Else
				oProcesso:continuarProcessamento()
			EndIf
		EndIf

		If oProcesso:oProcError:possuiErro()
			P152Error(oProcesso:retornaProgramacao(), .T.)
		Else
			oProcesso:limpaSecaoGlobal(.T.)
			oProcesso:destroy()
		EndIf
	EndIf

	P152ClnStc()
Return Nil

/*/{Protheus.doc} P152VldPar
Fun��o responsavel por validar os par�metros MV do pcpa152
@type  Function
@author Lucas Fagundes
@since 03/02/2023
@version P12
@param 01 cParam   , Caracter, Nome do par�metro que chamou a fun��o.
@param 02 cValor   , Caracter, Valor atribuido ao par�metro que chamou a fun��o.
@param 03 cValorSpa, Caracter, Valor espanhol atribuido ao par�metro que chamou a fun��o.
@param 04 cValorEng, Caracter, Valor ingl�s atribuido ao par�metro que chamou a fun��o.
@return lOk, Logico, Indica se valor atribuido pode ser usado.
/*/
Function P152VldPar(cParam, cValor, cValorSpa, cValorEng)
	Local lOk := .T.

	If cParam == "MV_A152THR"
		lOk := Val(cValor) <= MAXIMO_THREADS_ABERTAS .And. Val(cValorSpa) <= MAXIMO_THREADS_ABERTAS .And. Val(cValorEng) <= MAXIMO_THREADS_ABERTAS .And.;
		       Val(cValor) >= 0 .And. Val(cValorSpa) >= 0 .And. Val(cValorEng) >= 0

		If !lOk
			Help(' ', 1,"Help" ,,STR0008, 1, 1, , , , , , {i18n(STR0009, {cValToChar(MAXIMO_THREADS_ABERTAS)})}) // "Quantidade inv�lida!"  "Quantidade de threads para o processamento deve ser um valor de 0 a #1[quantidade maxima]#."
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} PCPA152Process
Classe para processamento do pcpa152

@author Lucas Fagundes
@since 01/02/2023
@version P12
/*/
Class PCPA152Process FROM LongNameClass
	Private Data cProg      as Character
	Private Data cSemaforo  as Character
	Private Data cUIdError  as Character
	Private Data cUIDGlb    as Character
	Private Data oParametro as Object
	Public Data oProcError  as Object

	// Construtor/Destrutor da classe
	Public Method new(cProg) Constructor
	Public Method destroy()

	// M�todos de processamento
	Public Method processaAbertura()
	Private Method processaDisponibilidade()
	Private Method processaTempoOperacao()
	Private Method processaGravacao()
	Private Method processaDistribuicao()
	Public Method processar()
	Public Method continuarProcessamento()
	Public Method cancelaExecucao()
	Public Method processamentoCancelado()

	// M�todos de manipula��o do atributos da classe
	Private Method gravaAtributosGlobais()
	Private Method recuperaAtributosGlobais()
	Public Method retornaProgramacao()
	Public Method retornaParametro(cNome)

	// M�todos de inicializa��o
	Private Method iniciaListas()
	Private Method iniciaParametros(oStart)
	Private Method iniciaTabelas(oStart)
	Private Method novaProgramacao()
	Public Method iniciaProgramacao(oStart)

	// M�todos para continuar a programa��o
	Private Method carregaParametros(aAdicional)
	Private Method atualizaParametros(aParams)
	Public Method continuaProgramacao(cProg, aParams)

	// M�todos para manipula��o das etapas
	Public Method atualizaEtapa(cEtapa, cStatus)
	Public Method gravaPercentual(cEtapa, nPerctge)
	Public Method gravaErro(cEtapa, cMsg, cMsgDet, lCancelado)
	Public Method atualizaStatusProgramacao(cStatus)
	Public Method permiteProsseguir()

	// M�todos para manipula��o de variaveis globais
	Private Method iniciaUIdGlobal(lCriaSecao)
	Private Method criaListaGlobal(cIdLista)
	Public Method gravaValorGlobal(cChave, xValor, lLock, lInc)
	Public Method retornaValorGlobal(cChave, lError, lLock)
	Public Method adicionaListaGlobal(cIdLista, cChave, aValor, lInc)
	Public Method retornaListaGlobal(cIdLista, cChave)
	Public Method limpaSecaoGlobal(lLimpaErro)
	Public Method limpaListaGlobal(cIdLista)

	// M�todos para manipula��o das threads
	Private Method abreThreads()
	Private Method fechaThreads()
	Public Method delegar(cFuncao, xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9, lWait)

	// M�todos de controle da thread master
	Private Method abreThreadMaster(lStart)
	Private Method aguardaThreadMasterIniciar()
	Public Method aguardaPermissaoParaIniciar()

	// M�todos auxiliares
	Public Method log(cMsg)

	// M�todos estaticos
	Static Method executaProgramacao(cProg, oBody)
	Static Method getDescricaoEtapa(cEtapa)
	Static Method getDescricaoStatus(cIdStatus, cEtapa)
	Static Method processamentoFactory(cProg, nOpcao, oReturn, lNoVldErro)
	Static Method trataTipoParametro(aInsere, xValor, lInsere)
EndClass

/*/{Protheus.doc} new
Metodo construtor da classe PCPA152Process

@author Lucas Fagundes
@since 01/02/2023
@version P12
@param cProg, Caracter, C�digo da programa��o caso j� esteja em processamento (em branco inicia uma nova programa��o)
@return Self
/*/
Method new(cProg) Class PCPA152Process

	If Empty(cProg)
		Self:cUIdError  := UUIDRandomSeq()
		Self:oProcError := PCPMultiThreadError():New(Self:cUIdError, .T.)
	Else
		Self:cProg := cProg
		Self:iniciaUIdGlobal(.F.)

		If VarIsUID(Self:cUIdGlb)
			Self:recuperaAtributosGlobais()
		EndIf
	EndIf

Return Self

/*/{Protheus.doc} iniciaProgramacao
Inicia uma nova programa��o.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param oStart, Object, Json com os par�metros para inicializa��o.
@return Nil
/*/
Method iniciaProgramacao(oStart) Class PCPA152Process
	Local lLock      := .T.
	Local nTentativa := 0

	While !lockByName("PCPA152_RESERVA_PROG", .T., .F.)
		If nTentativa > 500
			lLock := .F.
			Self:oProcError:setError("PCPA152Process():iniciaProgramacao()", STR0011, "", "") // "N�o foi possivel obter o lock para reservar a programa��o"
			Exit
		EndIf
		nTentativa++
		Sleep(50)
	End

	If lLock
		Self:cProg := Self:novaProgramacao()

		If Self:iniciaUIdGlobal(.T.)
			Self:iniciaParametros(oStart)

			Self:gravaAtributosGlobais()

			Self:abreThreadMaster(.T.)

			Self:iniciaTabelas(oStart)

			unlockByName("PCPA152_RESERVA_PROG", .T., .F.)

			Self:aguardaThreadMasterIniciar()

			If Self:oProcError:possuiErro()
				P152Error(Self:cProg, .F.)
			Else
				Self:gravaValorGlobal("THREAD_MASTER", "PROCESSAR")
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} novaProgramacao
Retorna o c�digo de uma nova programa��o.
@author Lucas Fagundes
@since 13/02/2023
@version P12
@return cProg, Caracter, C�digo de uma nova programa��o.
/*/
Method novaProgramacao() Class PCPA152Process
	Local cAlias := GetNextAlias()
	Local cProg  := "0000000001"
	Local cQuery := ""

	cQuery := " SELECT MAX(T4X_PROG) ultimaProg "
	cQuery +=   " FROM " + RetSqlName("T4X")
	cQuery +=  " WHERE D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
	If !Empty((cAlias)->ultimaProg)
		cProg := (cAlias)->ultimaProg
		cProg := Soma1(cProg)
	EndIf
	(cAlias)->(dbCloseArea())

Return cProg

/*/{Protheus.doc} iniciaUIdGlobal
Cria os UId para as se��es global
@author Lucas Fagundes
@since 13/02/2023
@version P12
@param 01 lCriaSecao, Logico, Indica que deve iniciar a se��o em mem�ria.
@return lCriou, Logico, Indica se conseguiu criar a se��o global.
/*/
Method iniciaUIdGlobal(lCriaSecao) Class PCPA152Process
	Local lCriou     := .F.
	Local nTentativa := 0

	Self:cUIDGlb   := "PCPA152_" + ::cProg
	Self:cSemaforo := "SEM_PCPA152_" + ::cProg

	If lCriaSecao
		While !lCriou
			lCriou := VarSetUID(::cUIDGlb)
			If lCriou
				Self:iniciaListas()
			Else
				nTentativa++
				If nTentativa > 500
					Self:oProcError:setError("PCPA152Process():iniciaUIdGlobal()", STR0197, "") // "Erro ao criar a se��o de mem�ria global!"
					Exit
				EndIf
				Sleep(50)
			EndIf
		End
	EndIf

Return lCriou

/*/{Protheus.doc} iniciaParametros
Inicia os par�metros de processamento atrav�s do json de inicializa��o da programa��o.
@author Lucas Fagundes
@since 13/02/2023
@version P12
@param oStart, Object, Json com os par�metros para inicializa��o.
@return Nil
/*/
Method iniciaParametros(oStart) Class PCPA152Process
	Local aParams := {}
	Local cParam  := ""
	Local nIndex  := 0
	Local nTotPar := 0
	Local oJsAux  := Nil

	aParams := getParMV()

	nTotPar := Len(aParams)
	For nIndex := 1 To nTotPar
		oJsAux := JsonObject():New()
		oJsAux["codigo"] := aParams[nIndex][1]
		oJsAux["valor" ] := SuperGetMV(aParams[nIndex][1], .F., aParams[nIndex][2])

		aAdd(oStart["listaParametros"], oJsAux)
	Next
	FwFreeArray(aParams)

	Self:oParametro := JsonObject():New()

	aParams := oStart["listaParametros"]
	nTotPar := Len(aParams)
	For nIndex := 1 To nTotPar
		cParam := aParams[nIndex]["codigo"]

		If vldTipoPar(cParam, aParams[nIndex]["valor"], .F.)
			Self:oParametro[cParam] := aParams[nIndex]["valor"]
		EndIf
	Next

	aParams := Nil
	oJsAux  := Nil
Return

/*/{Protheus.doc} getParMV
Retorna os par�metros MVs utilizados no processamento.
@type  Static Function
@author Lucas Fagundes
@since 22/03/2023
@version version
@return aParams, Array, Array com os parametros no seguinte formato: aParams[x][1] - Nome do par�metro
                                                                     aParams[x][2] - Valor default
/*/
Static Function getParMV()
	Local aParams := {}

	aAdd(aParams, {"MV_A152THR", 4  })
	aAdd(aParams, {"MV_PRECISA", 4  })
	aAdd(aParams, {"MV_PERDINF", .F.})
	aAdd(aParams, {"MV_TPHR"   , "C"})

Return aParams

/*/{Protheus.doc} iniciaTabelas
Inicia as tabelas da programa��o (T4X, T4Y, T4Z).
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param oStart, Object, Json com os par�metros para inicializa��o.
@return lSuccess, Logico, Indica se teve sucesso na inicializa��o das tabelas.
/*/
Method iniciaTabelas(oStart) Class PCPA152Process
	Local aData    := {}
	Local aParams  := {}
	Local cError   := ""
	Local cFilAux  := ""
	Local cParam   := ""
	Local lSuccess := .T.
	Local nIndex   := 0
	Local nTamPar  := 0
	Local nSeq     := 0
	Local nSeqAux  := 0
	Local oBulk    := FwBulk():New()

	BEGIN TRANSACTION

	RecLock('T4X',.T.)
		T4X_FILIAL := xFilial("T4X")
		T4X_PROG   := Self:cProg
		T4X_STATUS := STATUS_EXECUCAO
		T4X_USER   := oStart["userId"]
		T4X_DTINI  := Date()
		T4X_HRINI  := Time()
	T4X->(MsUnlock())

	cFilAux := xFilial("T4Y")

	oBulk:setTable(RetSqlName("T4Y"))
	oBulk:setFields(structT4Y())

	aParams := oStart["listaParametros"]
	nTamPar := Len(aParams)
	For nIndex := 1 To nTamPar
		cParam := aParams[nIndex]["codigo"]

		If "|" + cParam + "|" $ PAR_MVS
			nSeq := 99
		Else
			nSeqAux++
			nSeq := nSeqAux
		EndIf

		aData := {cFilAux, Self:cProg, nSeq, cParam}
		Self:trataTipoParametro(@aData, aParams[nIndex]["valor"], .T.)

		oBulk:addData(aData)
	Next

	If !oBulk:close()
		cError	:= oBulk:getError()
	EndIf

	If Empty(cError)
		oBulk:reset()

		oBulk:setTable(RetSqlName("T4Z"))
		oBulk:setFields(structT4Z())

		addEtapas(Self:cProg, @oBulk)

		If !oBulk:close()
			cError := oBulk:getError()
		EndIf
	EndIf

	If !Empty(cError)
		lSuccess := .F.
		DisarmTransaction()
		Self:gravaErro(CHAR_ETAPAS_ABERTURA, STR0004, cError) // "Erro na inicializa��o das tabelas!"
	EndIf

	END TRANSACTION

	oBulk:destroy()

	aSize(aData , 0)
	FwFreeArray(aParams)
Return lSuccess

/*/{Protheus.doc} trataTipoParametro
Trata o tipo dos par�metros para salvar na tabela T4Z.
@author Lucas Fagundes
@since 08/02/2023
@version P12
@param aInsere, Array , Retorna por referencia o array com o parametro inseridos
@param xValor , Any   , Valor do par�metro para tratar e inserir no array que salva os dados na tabela T4Z
@param lReturn, Logico, Indica que deve inserir o valor no array.
@return cReturn, Caracter, Valor do parametro convertido para string.
/*/
Method trataTipoParametro(aInsere, xValor, lInsere) Class PCPA152Process
	Local cListaT4Y := Nil
	Local cTipo     := ""
	Local cValorT4Y := ""
	Local cReturn   := ""

	cTipo := ValType(xValor)
	If cTipo == "C"
		cValorT4Y := xValor
		cReturn   := cValorT4Y
	ElseIf cTipo == "N"
		cValorT4Y := cValToChar(xValor)
		cReturn   := cValorT4Y
	ElseIf cTipo == "L" .And. xValor
		cValorT4Y := "true"
		cReturn   := cValorT4Y
	ElseIf cTipo == "L" .And. !xValor
		cValorT4Y := "false"
		cReturn   := cValorT4Y
	ElseIf cTipo == "A"
		cListaT4Y := ArrTokStr(xValor, CHR(10))
		cReturn   := cListaT4Y
	EndIf

	If lInsere
		aAdd(aInsere, cValorT4Y)
		aAdd(aInsere, cListaT4Y)
	EndIf

Return cReturn

/*/{Protheus.doc} structT4Y
Retorna os campos para iniciar os dados da tabela T4Y.
@type  Static Function
@author Lucas Fagundes
@since 02/02/2023
@version P12
@return aStruct, Array, Array com os campos que ser�o usados na inicializa��o da tabela T4Y.
/*/
Static Function structT4Y()
	Local aStruct := {}

	aAdd(aStruct, {"T4Y_FILIAL"})
	aAdd(aStruct, {"T4Y_PROG"  })
	aAdd(aStruct, {"T4Y_SEQ"   })
	aAdd(aStruct, {"T4Y_PARAM" })
	aAdd(aStruct, {"T4Y_VALOR" })
	aAdd(aStruct, {"T4Y_LISTA" })

Return aStruct

/*/{Protheus.doc} structT4Z
Retorna os campos para iniciar os dados da tabela T4Z.
@type  Static Function
@author Lucas Fagundes
@since 02/02/2023
@version P12
@return aStruct, Array, Array com os campos que ser�o usados na inicializa��o da tabela T4Z.
/*/
Static Function structT4Z()
	Local aStruct := {}

	aAdd(aStruct, {"T4Z_FILIAL"})
	aAdd(aStruct, {"T4Z_PROG"  })
	aAdd(aStruct, {"T4Z_SEQ"   })
	aAdd(aStruct, {"T4Z_ETAPA" })
	aAdd(aStruct, {"T4Z_STATUS"})
	aAdd(aStruct, {"T4Z_PERCT" })
	aAdd(aStruct, {"T4Z_DTINI" })
	aAdd(aStruct, {"T4Z_HRINI" })

Return aStruct

/*/{Protheus.doc} addEtapas
Adiciona as etapas no bulk para gravar na tabela T4Z.
@type  Static Function
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param cProg, Caracter, C�digo da programa��o.
@param oBulk, Object   , Objeto bulk para adicionar as etapas.
@return Nil
/*/
Static Function addEtapas(cProg, oBulk)
	Local cFilAux   := xFilial("T4Z")
	Local nSeqEtapa := 0

	nSeqEtapa++
	oBulk:addData({cFilAux               ,;  // T4Z_FILIAL
	               cProg                 ,;  // T4Z_PROG
	               nSeqEtapa             ,;  // T4Z_SEQ
	               CHAR_ETAPAS_ABERTURA  ,;  // T4Z_ETAPA
	               STATUS_EXECUCAO       ,;  // T4Z_STATUS
	               0                     ,;  // T4Z_PERCT
	               date()                ,;  // T4Z_DTINI
	               time()                })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux               ,;  // T4Z_FILIAL
	               cProg                 ,;  // T4Z_PROG
	               nSeqEtapa             ,;  // T4Z_SEQ
	               CHAR_ETAPAS_CALC_DISP ,;  // T4Z_ETAPA
	               STATUS_PENDENTE       ,;  // T4Z_STATUS
	               0                     ,;  // T4Z_PERCT
	               ""                    ,;  // T4Z_DTINI
	               ""                    })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux               ,;  // T4Z_FILIAL
	               cProg                 ,;  // T4Z_PROG
	               nSeqEtapa             ,;  // T4Z_SEQ
	               CHAR_ETAPAS_CALC_TEMP ,;  // T4Z_ETAPA
	               STATUS_PENDENTE       ,;  // T4Z_STATUS
	               0                     ,;  // T4Z_PERCT
	               ""                    ,;  // T4Z_DTINI
	               ""                    })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux               ,;  // T4Z_FILIAL
	               cProg                 ,;  // T4Z_PROG
	               nSeqEtapa             ,;  // T4Z_SEQ
	               CHAR_ETAPAS_DIST_ORD  ,;  // T4Z_ETAPA
	               STATUS_PENDENTE       ,;  // T4Z_STATUS
	               0                     ,;  // T4Z_PERCT
	               ""                    ,;  // T4Z_DTINI
	               ""                    })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux               ,;  // T4Z_FILIAL
	               cProg                 ,;  // T4Z_PROG
	               nSeqEtapa             ,;  // T4Z_SEQ
	               CHAR_ETAPAS_GRAVACAO  ,;  // T4Z_ETAPA
	               STATUS_PENDENTE       ,;  // T4Z_STATUS
	               0                     ,;  // T4Z_PERCT
	               ""                    ,;  // T4Z_DTINI
	               ""                    })  // T4Z_HRINI

Return Nil

/*/{Protheus.doc} gravaAtributosGlobais
Grava os atributos locais na se��o global para ser recuperado quando instanciar a classe em outras threads
@author Lucas Fagundes
@since 14/02/2023
@version P12
@return Nil
/*/
Method gravaAtributosGlobais() Class PCPA152Process
	Local cJson := ""

	Self:gravaValorGlobal("ERROR_UID", Self:cUIdError)

	cJson := Self:oParametro:toJson()
	Self:gravaValorGlobal("PCPA152_PARAMETROS", cJson)
Return Nil

/*/{Protheus.doc} recuperaAtributosGlobais
Recupera os atributos da se��o de variaveis globais
@author Lucas Fagundes
@since 14/02/2023
@version P12
@return Nil
/*/
Method recuperaAtributosGlobais() Class PCPA152Process
	Local cJson := ""

	Self:cUIdError  := Self:retornaValorGlobal("ERROR_UID")
	Self:oProcError := PCPMultiThreadError():New(Self:cUIdError, .F.)

	cJson := Self:retornaValorGlobal("PCPA152_PARAMETROS")
	Self:oParametro := JsonObject():New()
	Self:oParametro:fromJson(cJson)

Return Nil

/*/{Protheus.doc} processar
Metodo responsavel por controlar o processamento do programa.
@author Lucas Fagundes
@since 10/02/2023
@version P12
@return Nil
/*/
Method processar() Class PCPA152Process

	//Etapa - CHAR_ETAPAS_CALC_DISP
	If !Self:processaDisponibilidade()
		Return
	EndIf

	If Self:retornaParametro("visualizaDisponibilidade")
		Self:atualizaStatusProgramacao(STATUS_DISP_GERADA)
	Else
		Self:continuarProcessamento()
	EndIf

Return Nil

/*/{Protheus.doc} continuarProcessamento
Continua o processamento de uma programa��o.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@return Nil
/*/
Method continuarProcessamento() Class PCPA152Process
	Local oDisp := PCPA152Disponibilidade():New(Self)

	oDisp:carregaDisponibilidade()
	oDisp:destroy()

	//ETAPA - CHAR_ETAPAS_CALC_TEMP
	If !Self:processaTempoOperacao()
		Return
	EndIf
	Self:atualizaStatusProgramacao(STATUS_TEMPOS_CALCULADO)

	//ETAPA CHAR_ETAPAS_DIST_ORD
	If !Self:processaDistribuicao()
		Return
	EndIf
	Self:atualizaStatusProgramacao(STATUS_DIST_CONCLUIDA)

	//ETAPA - CHAR_ETAPAS_GRAVACAO
	If !Self:processaGravacao()
		Return
	EndIf
	Self:atualizaStatusProgramacao(STATUS_DISTRIBUIDO)

Return Nil

/*/{Protheus.doc} destroy
Limpa os atributos locais da classe.
(N�o limpa a se��o global)

@author Lucas Fagundes
@since 02/02/2023
@version P12
@return Nil
/*/
Method destroy() Class PCPA152Process

	Self:cProg      := Nil
	Self:cSemaforo  := Nil
	Self:cUIDGlb    := Nil
	Self:cUIdError  := Nil
	Self:oProcError := Nil
	Self:oParametro := Nil

Return Nil

/*/{Protheus.doc} Method limpaSecaoGlobal()
Limpa a se��o de variaveis globais e fecha as threads.
@author Lucas Fagundes
@since 03/02/2023
@version P12
@param 01 lLimpaErro, Logico, Indica se deve ou n�o realizar o destroy da classe de erro.
@return Nil
/*/
Method limpaSecaoGlobal(lLimpaErro) Class PCPA152Process
	Local aSecoes := {}
	Local nIndex  := 0
	Local nTotal  := 0

	Self:fechaThreads()

	VarGetAD(Self:cUIDGlb, "IDS_LISTA_MEMORIA", @aSecoes)

	If !Empty(aSecoes)
		nTotal := Len(aSecoes)

		For nIndex := 1 To nTotal
			VarClean(Self:cUIDGlb + aSecoes[nIndex])
		Next nIndex

		aSize(aSecoes, 0)
	EndIf

	VarClean(Self:cUIDGlb)
	If lLimpaErro
		Self:oProcError:destroy()
	EndIf
Return Nil

/*/{Protheus.doc} gravaValorGlobal
Seta um conteudo na se��o de variavel global.
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param 01 cChave, Caracter , Chave identificadora do valor na se��o global.
@param 02 xValor, Any      , Valor da flag que ser� setada.
@param 03 lLock , Logico   , Indica se deve ou n�o realizar o lock na chave.
@param 04 lInc  , Logico   , Indica que deve gravar flag de incremento.
@param 05 nQtdInc, Numerico, Quantidade que ser� incrementada, quando lInc estiver .T.
@return lSuccess, Logico, Indica se teve sucesso ao setar a flag.
/*/
Method gravaValorGlobal(cChave, xValor, lLock, lInc, nQtdInc) Class PCPA152Process
	Local lSuccess  := .F.
	Default lLock   := .F.
	Default lInc    := .F.
	Default nQtdInc := 1

	If lInc
		lSuccess := VarSetX(::cUIDGlb, cChave, @xValor, 1, nQtdInc)
	Else
		If lLock
			lSuccess := VarSetX(::cUIDGlb, cChave, xValor)
		Else
			lSuccess := VarSetXD(::cUIDGlb, cChave, xValor)
		EndIf
	EndIf

Return lSuccess

/*/{Protheus.doc} retornaValorGlobal
Recupera o conteudo de uma flag da se��o de variavel global.
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param 01 cChave, Caracter, Chave identificadora do valor na se��o global.
@param 02 lError, Logico  , Retorna por refer�ncia a ocorrencia de erros.
@param 03 lLock , Logico  , Indica se deve realizar o lock na chave ao recuperar o valor.
@return xValor, Undefined, Conteudo da chave na se��o de varivel global.
/*/
Method retornaValorGlobal(cChave, lError, lLock) Class PCPA152Process
	Local xValor := Nil
	Default lLock := .F.

	If lLock
		lError := !VarGetX(::cUIDGlb, cChave, @xValor)
	Else
		lError := !VarGetXD(::cUIDGlb, cChave, @xValor)
	EndIf

Return xValor

/*/{Protheus.doc} atualizaEtapa
Atualiza o status de uma etapa na tabela T4Z.
@author Lucas Fagundes
@since 03/02/2023
@version P12
@param 01 cEtapa , Caracter, Etapa que ser� atualizada.
@param 02 cStatus, Caracter, Status que ser� gravado.
@return Nil
/*/
Method atualizaEtapa(cEtapa, cStatus) Class PCPA152Process

	// T4Z_FILIAL+T4Z_PROG+T4Z_ETAPA
	T4Z->(DbSetOrder(2))
	If T4Z->(DbSeek(xFilial("T4Z")+Self:cProg+cEtapa))
		RecLock('T4Z',.F.)
			T4Z->T4Z_STATUS := cStatus

			If cStatus == STATUS_DISTRIBUIDO
				T4Z->T4Z_DTFIM := date()
				T4Z->T4Z_HRFIM := time()
				T4Z->T4Z_PERCT := 100

			ElseIf cStatus == STATUS_EXECUCAO
				T4Z->T4Z_DTINI := date()
				T4Z->T4Z_HRINI := time()
			EndIf
		T4Z->(MsUnlock())
	EndIf

Return Nil

/*/{Protheus.doc} gravaPercentual
Atualiza a porcentagem de uma etapa na tabela T4Z.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param 01 cEtapa  , Caracter, Etapa que ser� atualizada.
@param 02 nPerctge, Numerico , Porcentagem que ser� salva para na etapa.
@return Nil
/*/
Method gravaPercentual(cEtapa, nPerctge) Class PCPA152Process

	// T4Z_FILIAL+T4Z_PROG+T4Z_ETAPA
	T4Z->(DbSetOrder(2))
	If T4Z->(DbSeek(xFilial("T4Z")+Self:cProg+cEtapa))
		If T4Z->T4Z_PERCT <> nPerctge
			RecLock('T4Z',.F.)
				T4Z->T4Z_PERCT := nPerctge
			T4Z->(MsUnlock())
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} gravaErro
Grava erro em uma etapa na tabela T4Z.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param 01 cEtapa    , Caracter, Etapa que ir� gravar o erro.
@param 02 cMsg      , Caracter, Mensagem de erro.
@param 03 cMsgDet   , Caracter, Mensage detalhada do erro.
@param 04 lCancelado, L�gico  , Indica se o processamento foi cancelado
@return Nil
/*/
Method gravaErro(cEtapa, cMsg, cMsgDet, lCancelado) Class PCPA152Process
	Local cStack       := getStack(2)
	Local cStatusAtu   := ""
	Local cStatusSet   := ""
	Default lCancelado := .F.

	If cMsgDet == Nil
		cMsgDet := cStack
	EndIf

	// T4Z_FILIAL+T4Z_PROG+T4Z_ETAPA
	T4Z->(DbSetOrder(2))
	If T4Z->(DbSeek(xFilial("T4Z")+Self:cProg+cEtapa))
		cStatusAtu := T4Z->T4Z_STATUS

		If cStatusAtu == STATUS_EXECUCAO .Or. cStatusAtu == STATUS_PENDENTE

			If cStatusAtu == STATUS_EXECUCAO
				cStatusSet := IIf(lCancelado, STATUS_CANCELADO, STATUS_ERRO)
			ElseIf cStatusAtu == STATUS_PENDENTE
				cStatusSet := STATUS_CANCELADO
			EndIf

			RecLock('T4Z',.F.)
				T4Z->T4Z_STATUS := cStatusSet
				T4Z->T4Z_MSG    := cMsg
				T4Z->T4Z_MSGDET := cMsgDet
				T4Z->T4Z_DTFIM  := date()
				T4Z->T4Z_HRFIM  := time()
			T4Z->(MsUnlock())
		EndIf
	EndIf

	cMsg := cMsg + Chr(13)+Chr(10) + cStack
	Self:oProcError:setError(procName(1), cMsg, cMsgDet, "")

Return Nil

/*/{Protheus.doc} getStack
Retorna a pilha de chamadas.
@type  Static Function
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param nStart, Numerico, Indica uma posi��o especifica para iniciar a montagem da stack.
@return cStack, Caracter, String com a pilha de chamadas.
/*/
Static Function getStack(nStart)
	Local cProc    := ""
	Local cStack   := ""
	Local nIndex   := 0
	Local nLength  := 5
	Default nStart := 1

	For nIndex := nStart To nLength
		cProc := ProcName(nIndex)

		If Empty(cProc)
			Exit
		EndIf

		cProc  := cProc + " (" + ProcSource(nIndex) + ") line: " + cValToChar(ProcLine(nIndex)) + Chr(13)+Chr(10)
		cStack += cProc
	Next

Return cStack

/*/{Protheus.doc} abreThreads
Abre as threads para execu��o do processamento.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@return lAbriu, Logico, Retorna se conseguiu abrir com sucesso as threads.
/*/
Method abreThreads() Class PCPA152Process
	Local cRecover := ""
	Local lAbriu   := .T.

	If Self:oParametro["MV_A152THR"] > 1
		cRecover := 'P152Error("'+ Self:cProg +'", .F.)'
		PCPIPCStart(Self:cSemaforo, Self:oParametro["MV_A152THR"], Nil, cEmpAnt, cFilAnt, Self:cUIdError, cRecover)

		lAbriu := PCPIPCWIni(Self:cSemaforo, TEMPO_AGUARDA_ABERTURA)

		If !lAbriu
			Self:gravaErro(CHAR_ETAPAS_ABERTURA, STR0013, "") // "N�o foi possivel abrir as threads de processamento."
		EndIf
	EndIf

Return lAbriu

/*/{Protheus.doc} fechaThreads
Fecha as threads que foram abertas para o processamento.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@return Nil
/*/
Method fechaThreads() Class PCPA152Process

	If Self:oParametro["MV_A152THR"] > 1
		PCPIPCFinish(Self:cSemaforo, 10, Self:oParametro["MV_A152THR"])
	EndIf

Return

/*/{Protheus.doc} delegar
Delega uma fun��o para processamento.
@author Lucas Fagundes
@since 07/02/2023
@version P12
@param 01    cFuncao, Caracter, Fun��o que ser� executada.
@param 02-09 xVar   , Any     , Par�metro para a funca��o que ser� executada
@param 10    lWait  , Logico  , Indica que ir� esperar uma thread ser liberada caso todas estejam em uso.
@return Nil
/*/
Method delegar(cFuncao, xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9, lWait) Class PCPA152Process
	Default lWait := .T.

	If Self:oParametro["MV_A152THR"] > 1
		PCPIPCGO(Self:cSemaforo, .F., cFuncao, xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9, lWait)
	Else
		&cFuncao.(xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9)
	EndIf

Return Nil

/*/{Protheus.doc} P152Error
Grava nas tabelas erros de processamento.
@type  Function
@author Lucas Fagundes
@since 07/02/2023
@version P12
@param 01 cProg     , Caracter, C�digo da programa��o que teve erro.
@param 02 lLimpaErro, Logico  , Indica se deve ou n�o realizar o destroy da classe de erro.
@return Nil
/*/
Function P152Error(cProg, lLimpaErro)
	Local aError     := {}
	Local aEtapas    := {}
	Local cEtapa     := ""
	Local cMsg       := ""
	Local cMsgDet    := ""
	Local lCancelado := .F.
	Local nIndex     := 0
	Local nTotEtapas := 0
	Local oEtapa     := Nil
	Local oInfo      := Nil
	Local oProcesso  := Nil

	If !PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso, .T.)
		Return Nil
	EndIf

	oInfo := P152GetSta(cProg, .F.)

	If oInfo <> Nil
		lCancelado := oProcesso:processamentoCancelado()
		aError     := oProcesso:oProcError:getaError()

		If lCancelado
			cMsg    := aError[1][2]
			cMsgDet := aError[1][3]
		Else
			cMsg    := STR0006 // "Ocorreu um erro durante a execu��o, consulte o campo de detalhes para mais informa��es."
			cMsgDet := aError[1][2] + aError[1][3] + aError[1][4]
		EndIf

		aEtapas := oInfo["etapas"]
		nTotEtapas := Len(aEtapas)
		For nIndex := 1 To nTotEtapas
			oEtapa  := aEtapas[nIndex]
			cEtapa  := oEtapa["etapa"]

			oProcesso:gravaErro(cEtapa, cMsg, cMsgDet, lCancelado)
		Next

		If !lCancelado
			oProcesso:atualizaStatusProgramacao(STATUS_ERRO)
		EndIf
	EndIf

	oProcesso:limpaSecaoGlobal(lLimpaErro)
	oProcesso:destroy()

	FwFreeArray(aError)
	FreeObj(oProcesso)
	FreeObj(oInfo)
Return Nil

/*/{Protheus.doc} aguardaPermissaoParaIniciar
Aguarda o fim da inicializa��o da programa��o.
@author Lucas Fagundes
@since 07/02/2023
@version P12
@return lIniciar, Logico, Retorna se pode ou n�o iniciar o processamento.
/*/
Method aguardaPermissaoParaIniciar() Class PCPA152Process
	Local cValor   := Self:retornaValorGlobal("THREAD_MASTER")
	Local lIniciar := .T.

	While cValor != "PROCESSAR" .And. !Self:oProcError:possuiErro()
		Sleep(100)
		cValor := Self:retornaValorGlobal("THREAD_MASTER")
	End

	If Self:oProcError:possuiErro()
		lIniciar := .F.
	EndIf

Return lIniciar

/*/{Protheus.doc} aguardaThreadMasterIniciar
Aguarda a inicializa��o da thread master de processamento.
@author Lucas Fagundes
@since 14/02/2023
@version P12
@return Nil
/*/
Method aguardaThreadMasterIniciar() Class PCPA152Process
	Local cValorAux  := Self:retornaValorGlobal("THREAD_MASTER")
	Local nTentativa := 0

	While cValorAux == "PENDENTE" .And. !Self:oProcError:possuiErro()
		nTentativa++
		If nTentativa > TEMPO_AGUARDA_ABERTURA
			Self:gravaErro(CHAR_ETAPAS_ABERTURA, STR0014, "") // "N�o foi possivel abrir a thread master para o processamento."
			Exit
		EndIf

		Sleep(100)
		cValorAux := Self:retornaValorGlobal("THREAD_MASTER")
	End

Return Nil

/*/{Protheus.doc} atualizaStatusProgramacao
Atualiza o status da programa��o na tabela T4X.
@author Lucas Fagundes
@since 08/02/2023
@version P12
@param cStatus, Caracter, C�digo do status que vai setar na TX4.
@return Nil
/*/
Method atualizaStatusProgramacao(cStatus) Class PCPA152Process

	// T4X_FILIAL+T4X_PROG
	T4X->(DbSetOrder(1))
	If T4X->(DbSeek(xFilial("T4X")+Self:cProg))
		RecLock('T4X',.F.)
			T4X->T4X_STATUS := cStatus

			If cStatus == STATUS_DISTRIBUIDO .Or. cStatus == STATUS_ERRO
				T4X->T4X_DTFIM := date()
				T4X->T4X_HRFIM := time()
			EndIf
		T4X->(MsUnlock())
	EndIf

Return Nil

/*/{Protheus.doc} criaListaGlobal
Cria uma nova lista de dados
@author lucas.franca
@since 08/02/2023
@version P12
@param cIdLista, Caracter, Identificador da lista
@return Nil
/*/
Method criaListaGlobal(cIdLista) Class PCPA152Process
    //Cria se��o para a lista
    If VarSetUID(Self:cUIDGlb + cIdLista)
        //Se criou, armazena ID da se��o para limpeza de mem�ria
        VarSetA(Self:cUIDGlb, "IDS_LISTA_MEMORIA", {}, 1, cIdLista)
    EndIf
Return

/*/{Protheus.doc} adicionaListaGlobal
Adiciona dados em uma lista

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 cIdLista, Caracter, Identificador da lista
@param 02 cChave  , Caracter, Chave do registro da lista
@param 03 aValor  , Array   , Array com os valores para adicionar na lista
@param 04 lInc    , Logic   , .T. = Incrementa valor na global. .F. = Substitui valor na global
@return Nil
/*/
Method adicionaListaGlobal(cIdLista, cChave, aValor, lInc) Class PCPA152Process
	Local cUUID := Self:cUIDGlb + cIdLista

	If lInc
		VarSetA(cUUID, cChave, {}, 1, @aValor)
	Else
		VarSetAD(cUUID, cChave, @aValor)
	EndIf
Return Nil

/*/{Protheus.doc} retornaListaGlobal
Retorna os dados de uma lista.

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 cIdLista, Caracter, Identificador da lista
@param 02 cChave  , Caracter, Chave do registro da lista. Se vazio, retorna todas as chaves da lista.
@return aLista, Array, Array com os dados da lista
/*/
Method retornaListaGlobal(cIdLista, cChave) Class PCPA152Process
	Local aLista := {}
	Local cUUID  := Self:cUIDGlb + cIdLista

	If Empty(cChave)
		VarGetAA(cUUID, @aLista)
	Else
		VarGetAD(cUUID, cChave, @aLista)
	EndIf
Return aLista

/*/{Protheus.doc} iniciaListas
Inicia as listas que ser�o utilizadas durante o processamento.
@author Lucas Fagundes
@since 09/02/2023
@version P12
@return Nil
/*/
Method iniciaListas() Class PCPA152Process
	Self:criaListaGlobal("DADOS_SMR")
	Self:criaListaGlobal("DADOS_SMK")
	Self:criaListaGlobal("DADOS_SMF")
	Self:criaListaGlobal("DADOS_SVM")
	Self:criaListaGlobal("DISPONIBILIDADE_RECURSOS")
Return

/*/{Protheus.doc} retornaProgramacao
Retonar a programa��o da instancia atual da classe.
@author Lucas Fagundes
@since 10/02/2023
@version P12
@return Self:cProg, Caracter, C�digo da programa��o
/*/
Method retornaProgramacao() Class PCPA152Process

Return Self:cProg

/*/{Protheus.doc} retornaParametro
Retorna um par�metro de execu��o.
@author Lucas Fagundes
@since 10/02/2023
@version P12
@param cNome, Caracter, Nome do par�metro que ir� busca
@return xValor, Any, Valor do par�metro, se n�o existir retorna Nil
/*/
Method retornaParametro(cNome) Class PCPA152Process
	Local xValor := Nil

	If Self:oParametro:hasProperty(cNome)
		xValor := Self:oParametro[cNome]
	EndIf

Return xValor

/*/{Protheus.doc} processaAbertura
Abertura do processamento - Etapa CHAR_ETAPAS_ABERTURA
@author Marcelo Neumann
@since 14/03/2023
@version P12
@return lOk, L�gico, Inidica se processou com sucesso a etapa
/*/
Method processaAbertura() Class PCPA152Process
	Local lOk := .F.

	If Self:permiteProsseguir() .And. Self:abreThreads()
		Self:atualizaEtapa(CHAR_ETAPAS_ABERTURA, STATUS_DISTRIBUIDO)
		lOk := .T.
	EndIf

Return lOk

/*/{Protheus.doc} processaDisponibilidade
Processa a disponibilidade dos recursos - Etapa CHAR_ETAPAS_CALC_DISP
@author Marcelo Neumann
@since 14/03/2023
@version P12
@return lOk, L�gico, Inidica se processou com sucesso a etapa
/*/
Method processaDisponibilidade() Class PCPA152Process
	Local lOk   := .F.
	Local oDisp := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
		Self:atualizaEtapa(CHAR_ETAPAS_CALC_DISP, STATUS_EXECUCAO)

		If oDisp:processaRecursos()
			Self:atualizaEtapa(CHAR_ETAPAS_CALC_DISP, STATUS_DISTRIBUIDO)
			lOk := .T.
		EndIf

	EndIf

Return lOk

/*/{Protheus.doc} permiteProsseguir
Indica se deve prosseguir com o processamento ou se precisa ser parado.

@author Marcelo Neumann
@since 14/03/2023
@version P12
@return L�gico, indica se o processamento est� ativo ou se foi abortado
/*/
Method permiteProsseguir() Class PCPA152Process

	If Self:processamentoCancelado()
		Return .F.
	EndIf

	If Self:oProcError:possuiErro()
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} getDescricaoStatus
Retorna a descri��o de um determinado status

@author Marcelo Neumann
@since 14/02/2023
@version P12
@param  01 cIdStatus, Caracter, C�digo do status
@param  02 cEtapa   , Caracter, C�digo da etapa (caso seja para resgatar o status da etapa)
@return cDesStatus  , Caracter, Descri��o do status
/*/
Method getDescricaoStatus(cIdStatus, cEtapa) Class PCPA152Process
	Local cDesStatus := ""
	Default cEtapa   := ""

	If cIdStatus == STATUS_PENDENTE
		cDesStatus := STR0019 //"Pendente"

	ElseIf cIdStatus == STATUS_EXECUCAO
		If cEtapa == CHAR_ETAPAS_CALC_DISP
			cDesStatus := STR0021 //"Gerando disponibilidade"
		ElseIf cEtapa == CHAR_ETAPAS_CALC_TEMP
			cDesStatus := STR0132 // "Calculando tempo das opera��es"
		ElseIf cEtapa == CHAR_ETAPAS_DIST_ORD
			cDesStatus := STR0177 // "Distribuindo ordens de produ��o"
		ElseIf cEtapa == CHAR_ETAPAS_GRAVACAO
			cDesStatus := STR0143 // "Gravando dados"
		Else
			cDesStatus := STR0020 //"Em execu��o"
		EndIf

	ElseIf cIdStatus == STATUS_DISTRIBUIDO
		cDesStatus := STR0022 //"Distribu�do"

	ElseIf cIdStatus == STATUS_CANCELADO
		cDesStatus := STR0023 //"Cancelado"

	ElseIf cIdStatus == STATUS_DISP_GERADA
		cDesStatus := STR0024 //"Disponibilidade gerada"

	ElseIf cIdStatus == STATUS_TEMPOS_CALCULADO
		cDesStatus := STR0133 // "Tempo das opera��es calculado"

	ElseIf cIdStatus == STATUS_ERRO
		cDesStatus := STR0025 //"Erro"
	EndIf

Return cDesStatus

/*/{Protheus.doc} getDescricaoEtapa
Retorna a descri��o da etapa

@author Marcelo Neumann
@since 14/02/2023
@version P12
@param  cEtapa    , Caracter, C�digo da etapa
@return cDescEtapa, Caracter, Descri��o da etapa
/*/
Method getDescricaoEtapa(cEtapa) Class PCPA152Process
	Local cDescEtapa := cEtapa

	If cEtapa == CHAR_ETAPAS_ABERTURA
		cDescEtapa := STR0015 //"Preparando o processamento..."

	ElseIf cEtapa == CHAR_ETAPAS_CALC_DISP
		cDescEtapa := STR0016 //"Calculando a disponibilidade..."

	ElseIf cEtapa == CHAR_ETAPAS_CALC_TEMP
		cDescEtapa := STR0017 //"Calculando o tempo de opera��o..."

	ElseIf cEtapa == CHAR_ETAPAS_DIST_ORD
		cDescEtapa := STR0178 // "Distribuindo ordens..."

	ElseIf cEtapa == CHAR_ETAPAS_GRAVACAO
		cDescEtapa := STR0018 //"Gravando resultados..."
	EndIf

Return cDescEtapa

/*/{Protheus.doc} cancelaExecucao
Cancela o processamento de uma programa��o

@author Marcelo Neumann
@since 07/03/2023
@version P12
@param cProg, Caracter, C�digo da programa��o a ser cancelada
@return Nil
/*/
Method cancelaExecucao() Class PCPA152Process

	Self:oProcError:setError("PCPA152Process():cancelaExecucao()", ;
	                         STR0040                             , ; //"Processamento cancelado."
	                         STR0041                             , ; //"Processamento da programa��o cancelado pelo usu�rio."
	                         "")
	Self:gravaValorGlobal("CANCELADO", .T.)
	Self:atualizaStatusProgramacao(STATUS_CANCELADO)

Return

/*/{Protheus.doc} processamentoCancelado
Retorna se a programa��o foi cancelada

@author Marcelo Neumann
@since 07/03/2023
@version P12
@return lCancelado, L�gico, Indica se o processamento foi cancelado
/*/
Method processamentoCancelado() Class PCPA152Process
	Local lCancelado := .F.
	Local lError     := .F.

	If Self:retornaValorGlobal("CANCELADO", @lError) .And. !lError
		lCancelado := .T.
	EndIf

Return lCancelado

/*/{Protheus.doc} processaTempoOperacao
Inicia o processamento do tempo das opera��es.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return lSucesso, Logico, Indica que o processamento encerrou com sucesso.
/*/
Method processaTempoOperacao() Class PCPA152Process
	Local lOk        := .F.
	Local oTempoOper := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		Self:atualizaEtapa(CHAR_ETAPAS_CALC_TEMP, STATUS_EXECUCAO)

		If oTempoOper:processaTempoOperacao()
			Self:atualizaEtapa(CHAR_ETAPAS_CALC_TEMP, STATUS_DISTRIBUIDO)
			lOk := .T.
		EndIf

	EndIf

Return lOk

/*/{Protheus.doc} processaGravacao
Inicia a grava��o dos dados.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return lOk, Logico, Indica que o processamento encerrou com sucesso.
/*/
Method processaGravacao() Class PCPA152Process
	Local lOk        := .F.
	Local oTempoOper := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		Self:atualizaEtapa(CHAR_ETAPAS_GRAVACAO, STATUS_EXECUCAO)

		If oTempoOper:gravaDados()
			Self:atualizaEtapa(CHAR_ETAPAS_GRAVACAO, STATUS_DISTRIBUIDO)
			lOk := .T.
		EndIf

	EndIf

Return lOk

/*/{Protheus.doc} continuaProgramacao
Continua o processamento de uma programa��o com a disponibilidade gerada.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param 01 cProg  , Caracter, C�digo da programa��o que ir� continuar.
@param 02 aParams, Array   , Parametros adicionais para a continua��o da programa��o.
@return Nil
/*/
Method continuaProgramacao(cProg, aParams) Class PCPA152Process
	Local cStatus := ""

	Self:cProg := cProg

	T4X->(DbSetOrder(1))
	If T4X->(DbSeek(xFilial("T4X")+Self:cProg))
		cStatus := T4X->T4X_STATUS
	Else
		Self:oProcError:setError("PCPA152Process():continuaProgramacao()", STR0134, "") // "Programa��o n�o encontrada!"
	EndIf

	If cStatus == STATUS_DISP_GERADA
		If Self:iniciaUIdGlobal(.T.)
			Self:carregaParametros(aParams)

			Self:gravaAtributosGlobais()

			Self:abreThreadMaster(.F.)

			Self:atualizaParametros(aParams)

			Self:aguardaThreadMasterIniciar()

			If Self:oProcError:possuiErro()
				P152Error(Self:cProg, .F.)
			Else
				Self:gravaValorGlobal("THREAD_MASTER", "PROCESSAR")
			EndIf
		EndIf
	Else
		Self:oProcError:setError("PCPA152Process():continuaProgramacao()", STR0135, STR0136)  // "Status da programa��o inv�lido!" "Somente � possivel continuar programa��es com status disponibilidade gerada."
	EndIf


Return Nil

/*/{Protheus.doc} carregaParametros
Carrega os parametros para continuar o processamento da programa��o.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param aAdicional, Array, Par�metros adicionais recebidos para continuar a programa��o.
@return Nil
/*/
Method carregaParametros(aAdicional) Class PCPA152Process
	Local cParam     := ""
	Local nIndex     := 0
	Local nTotal     := Len(aAdicional)
	Local xValor     := Nil

	Self:oParametro := P152GetPar(Self:cProg)

	For nIndex := 1 To nTotal
		cParam := aAdicional[nIndex]["codigo"]
		xValor := aAdicional[nIndex]["valor" ]

		If vldTipoPar(cParam, xValor, .F.)
			Self:oParametro[cParam] := xValor
		EndIf
	Next

Return Nil

/*/{Protheus.doc} atualizaParametros
Grava os par�metros recebidos para continuar a programa��o na tabela de par�metros.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param aParams, Array, Parametros recebidos na continua��o da programa��o.
@return Nil
/*/
Method atualizaParametros(aParams) Class PCPA152Process
	Local cParam := ""
	Local nIndex := 1
	Local nTotal := Len(aParams)
	Local xValor := Nil

	For nIndex := 1 To nTotal
		cParam := aParams[nIndex]["codigo"]
		xValor := Self:trataTipoParametro(Nil, aParams[nIndex]["valor"], .F.)

		T4Y->(DbSetOrder(2))
		If T4Y->(DbSeek(xFilial("T4Y")+Self:cProg+cParam))
			RecLock('T4Y',.F.)
				If "|" + cParam + "|" $ PAR_TIPO_LIST
					T4Y->T4Y_LISTA := xValor
				Else
					T4Y->T4Y_VALOR := xValor
				EndIf
			T4Y->(MsUnlock())
		EndIf
	Next

Return Nil

/*/{Protheus.doc} vldTipoPar
Valida os tipo dos par�metros e faz a convers�o do que est� salvo na tabela para o tipo correto.
@type  Static Function
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param 01 cNome    , Caracter, Nome do par�metro que ir� validar.
@param 02 xValor   , Any     , Valor do par�metro que ir� validar, retorna por referencia o valor convertido se lConverte == .T.
@param 03 lConverte, Logico  , Indica que deve converter para o tipo correto do par�metro.
@return lOk, Logico, Retorna se o par�metro est� correto.
/*/
Static Function vldTipoPar(cNome, xValor, lConverte)
	Local lOk := .T.

	cNome := "|" + cNome + "|"

	If cNome $ PAR_TIPO_CHAR
		lOk := ValType(xValor) == "C"
	ElseIf cNome $ PAR_TIPO_NUM
		If lConverte
			xValor := Val(xValor)
		EndIf

		lOk := ValType(xValor) == "N"
	ElseIf cNome $ PAR_TIPO_BOOL
		If lConverte .And. xValor == "true"
			xValor := .T.
		ElseIf lConverte .And. xValor == "false"
			xValor := .F.
		EndIf

		lOk := ValType(xValor) == "L"
	ElseIf cNome $ PAR_TIPO_LIST
		If lConverte
			xValor := StrTokArr(xValor, CHR(10))
		EndIf

		lOk := ValType(xValor) == "A"
	EndIf

Return lOk

/*/{Protheus.doc} abreThreadMaster
Inicia a thread master para o processamento.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param lStart, Logico, Indica que est� iniciando uma nova programa��o.
@return Nil
/*/
Method abreThreadMaster(lStart) Class PCPA152Process
	Local cRecover := 'P152Error("' + Self:cProg + '", .T.)'

	Self:gravaValorGlobal("THREAD_MASTER", "PENDENTE")

	Self:oProcError:startJob("P152Start", getEnvServer(), .F., cEmpAnt, cFilAnt, Self:cProg, lStart, /*oVar03*/, /*oVar04*/, ;
							/*oVar05*/, /*oVar06*/, /*oVar07*/, /*oVar08*/, /*oVar09*/, /*oVar10*/, /*bRecover*/, cRecover)

Return Nil

/*/{Protheus.doc} P152GetPar
Retorna os par�metros de uma programa��o.
@type  Function
@author Lucas Fagundes
@since 23/03/2023
@version P12
@param cProg, Caracter, C�digo da programa�ao que ir� buscar os parametros
@return oParams, Object, Json com os parametros da programa��o
/*/
Function P152GetPar(cProg)
	Local cParam    := ""
	Local lConverte := .T.
	Local oParams   := JsonObject():New()
	Local xValor    := Nil

	T4Y->(DbSetOrder(1))
	If T4Y->(DbSeek(xFilial('T4Y')+cProg))
		While T4Y->(!EoF()) .And. T4Y->T4Y_PROG == cProg
			cParam := RTrim(T4Y->T4Y_PARAM)
			lConverte := .T.

			If "|" + cParam + "|" $ PAR_TIPO_LIST
				If Empty(T4Y->T4Y_LISTA) .And. T4Y->T4Y_LISTA != " "
					xValor    := {}
					lConverte := .F.
				Else
					xValor := T4Y->T4Y_LISTA
				EndIf
			Else
				xValor := RTrim(T4Y->T4Y_VALOR)
			EndIf

			If vldTipoPar(cParam, @xValor, lConverte)
				oParams[cParam] := xValor
			EndIf

			T4Y->(dbSkip())
		End
	EndIf

Return oParams

/*/{Protheus.doc} processamentoFactory
Metodo de fabrica��o das classes de processamento.

@author Lucas Fagundes
@since 27/03/2023
@version P12
@param 01 cProg     , Caracter, C�digo da programa��o que ser� instanciada a classe de controle.
@param 02 nOpcao    , Numerico, Op��o de retorno com base nos defines iniciados em FACTORY_OPC.
@param 03 oReturn   , Object  , Retorna por referencia a instancia da classe.
@param 04 lNoVldErro, Logico  , Indica que n�o deve realizar a valida��o de erro/cancelamento se a classe de processamento for instanciada.
@return lSucesso, Logico, Indica se teve sucesso ao instanciar a classe ou n�o.
/*/
Method processamentoFactory(cProg, nOpcao, oReturn, lNoVldErro) Class PCPA152Process
	Local lSucesso     := .T.
	Default lNoVldErro := .F.

	If Empty(_oProcesso)
		_oProcesso := PCPA152Process():New(cProg)
	EndIf

	lSucesso := _oProcesso:oProcError != Nil .And. (lNoVldErro .Or. _oProcesso:permiteProsseguir())
	If lSucesso
		If nOpcao == FACTORY_OPC_BASE
			oReturn := _oProcesso
		ElseIf nOpcao == FACTORY_OPC_DISP
			If Empty(_oDisp)
				_oDisp := PCPA152Disponibilidade():New(_oProcesso)
			EndIf

			oReturn := _oDisp
		ElseIf nOpcao == FACTORY_OPC_TEMPOPER
			If Empty(_oTempOper)
				_oTempOper := PCPA152TempoOperacao():New(_oProcesso)
			EndIf

			oReturn := _oTempOper
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} executaProgramacao
Inicia ou continua uma programa��o
@author Lucas Fagundes
@since 27/03/2023
@version P12
@param 01 cProg, Caracter, C�digo da programa��o que ir� continuar.
@param 02 oBody, Object  , Par�metros para iniciar/continuar a programa��o.
@return oSelf, Object, Nova instancia da classe de processamento.
/*/
Method executaProgramacao(cProg, oBody) Class PCPA152Process
	Local oSelf := PCPA152Process():New()

	If Empty(cProg)
		oSelf:iniciaProgramacao(oBody)
	Else
		oSelf:continuaProgramacao(cProg, oBody["listaParametros"])
	EndIf

Return oSelf

/*/{Protheus.doc} P152ClnStc
Limpa o cache das classes de processamento nas variaveis estaticas.
@type  Function
@author Lucas Fagundes
@since 30/03/2023
@version P12
@return Nil
/*/
Function P152ClnStc()

	If !Empty(_oDisp)
		_oDisp:destroy()
		_oDisp := Nil
	EndIf

	If !Empty(_oProcesso)
		_oProcesso:destroy()
		_oProcesso := Nil
	EndIf

	If !Empty(_oTempOper)
		_oTempOper:destroy()
		_oTempOper := Nil
	EndIf

Return Nil

/*/{Protheus.doc} processaDistribuicao
Inicia a distribui��o das opera��es.
@author Lucas Fagundes
@since 04/04/2023
@version P12
@return lOk, Logico, Indica que o processamento encerrou com sucesso.
/*/
Method processaDistribuicao() Class PCPA152Process
	Local lOk        := .F.
	Local oTempoOper := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		Self:atualizaEtapa(CHAR_ETAPAS_DIST_ORD, STATUS_EXECUCAO)

		If oTempoOper:processaDistribuicao()
			Self:atualizaEtapa(CHAR_ETAPAS_DIST_ORD, STATUS_DISTRIBUIDO)
			lOk := .T.
		EndIf

	EndIf

Return lOk

/*/{Protheus.doc} log
Realiza o log de uma mensagem.
@author Lucas Fagundes
@since 17/04/2023
@version P12
@param cMsg, Caracter, Mensagem que ser� feito o log.
@return Nil
/*/
Method log(cMsg) Class PCPA152Process

	If REALIZA_LOGS
		LogMsg(ProcSource(1), 0, 0, 1, "", "", cMsg)
	EndIf

Return Nil

/*/{Protheus.doc} limpaListaGlobal
Realiza a limpeza das chaves em uma lista da se��o global.
@author Lucas Fagundes
@since 27/04/2023
@version P12
@param cIdLista, Caracter, C�digo identificador da lista.
@return lOk, Logico, Indica se conseguiu limpar a lista com sucesso.
/*/
Method limpaListaGlobal(cIdLista) Class PCPA152Process

Return VarCleanA(Self:cUIDGlb+cIdLista)
