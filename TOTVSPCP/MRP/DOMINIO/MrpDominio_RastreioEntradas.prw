#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE IND_NOME_LISTA_ENTRADAS    "RASTRO_ENTRADA"
#DEFINE IND_CHAVE_GRAVAR_SME       "Registro_SME"
#DEFINE IND_CHAVE_REG_AGLUTINADO   "Aglutinado_"
#DEFINE IND_CHAVE_AGLUT_DOC_FILHO  "Relaciona_Agl_Filho_"
#DEFINE IND_CHAVE_DE_PARA_EMPENHO  "De_Para_Empenho_"
#DEFINE IND_CHAVE_DADOS_HWC        "DADOS_HWC_RAST"
#DEFINE IND_CHAVE_DOCUMENTOS_SAIDA "RAST_DEM_DOCUMENTOS_SAIDA"
#DEFINE IND_CHAVE_DOCUMENTOS_USO   "RAST_DEM_DOCUMENTOS_USO"

#DEFINE AENTRADAS_POS_FILIAL            1
#DEFINE AENTRADAS_POS_TIPO_DOC_ENTRADA  2
#DEFINE AENTRADAS_POS_NUM_DOC_ENTRADA   3
#DEFINE AENTRADAS_POS_DATA              4
#DEFINE AENTRADAS_POS_PRODUTO           5
#DEFINE AENTRADAS_POS_TRT               6
#DEFINE AENTRADAS_POS_QUANTIDADE        7
#DEFINE AENTRADAS_POS_TIPO_REGISTRO     8
#DEFINE AENTRADAS_POS_TIPO_DOC_SAIDA    9
#DEFINE AENTRADAS_POS_NUM_DOC_SAIDA    10
#DEFINE AENTRADAS_POS_NIVEL            11
#DEFINE AENTRADAS_POS_DOCPAI           12
#DEFINE AENTRADAS_POS_SEQUEN           13
#DEFINE AENTRADAS_POS_OPCIONAL         14
#DEFINE AENTRADAS_POS_LOTE             15
#DEFINE AENTRADAS_POS_SUBLOTE          16
#DEFINE AENTRADAS_SIZE                 16

#DEFINE ASALDOS_POS_TIPO                1
#DEFINE ASALDOS_POS_NUM_DOC_ENTRADA     2
#DEFINE ASALDOS_POS_DATA                3
#DEFINE ASALDOS_POS_QUANTIDADE          4
#DEFINE ASALDOS_POS_VENCIMENTO          5
#DEFINE ASALDOS_POS_LOTE                6
#DEFINE ASALDOS_POS_SUBLOTE             7
#DEFINE ASALDOS_SIZE                    7

#DEFINE AAGLUTINA_POS_FILIAL            1
#DEFINE AAGLUTINA_POS_TIPO_DOC_ORIGEM   2
#DEFINE AAGLUTINA_POS_NUM_DOC_ORIGEM    3
#DEFINE AAGLUTINA_POS_SEQ_ORIGEM        4
#DEFINE AAGLUTINA_POS_NECESSIDADE       5
#DEFINE AAGLUTINA_POS_SUBTITUICAO       6
#DEFINE AAGLUTINA_POS_TRT               7
#DEFINE AAGLUTINA_SIZE                  7

#DEFINE ADOCHWC_FILIAL                  1
#DEFINE ADOCHWC_TIPO_DOC_ENT            2
#DEFINE ADOCHWC_NUM_DOC_ENT             3
#DEFINE ADOCHWC_SEQ_QUEBRA              4
#DEFINE ADOCHWC_DATA                    5
#DEFINE ADOCHWC_PRODUTO                 6
#DEFINE ADOCHWC_TRT                     7
#DEFINE ADOCHWC_QTD_BAIXA               8
#DEFINE ADOCHWC_QTD_SUBS                9
#DEFINE ADOCHWC_QTD_EMPENHO             10
#DEFINE ADOCHWC_QTD_NECESS              11
#DEFINE ADOCHWC_TIPO_DOC_SAI            12
#DEFINE ADOCHWC_NUM_DOC_SAI             13
#DEFINE ADOCHWC_IDOPC                   14
#DEFINE ADOCHWC_LIST_HWC                15
#DEFINE ADOCHWC_POS_HWC                 16
#DEFINE ADOCHWC_SIZE                    16

Static _nSizeDEnt := Nil
Static _oDominio  := Nil
Static snTamCod   := 90

/*/{Protheus.doc} MrpDominio_RastreioEntradas
Classe de controle do rastreio das entradas do MRP
@author marcelo.neumann
@since 07/10/2020
@version 1
/*/
CLASS MrpDominio_RastreioEntradas FROM LongClassName

	DATA aEntInclui   AS Array
	DATA lAglutinado  AS Logical //Indica se est� rodando com aglutina��o
	DATA lHabilitado  AS Logical //Indica se est� usando o rastreio das demandas
	DATA nPosDocFilho AS Numeric
	DATA nPosFilial   AS Numeric
	DATA nPosNecOri   AS Numeric
	DATA nPosNecess   AS Numeric
	DATA nPosEst      AS Numeric
	DATA nPosCodPai   AS Numeric
	DATA nPosConEst   AS Numeric
	DATA nPosDocPai   AS Numeric
	DATA nPosIdOpc    AS Numeric
	DATA nPosPeriodo  AS Numeric
	DATA nPosProduto  AS Numeric
	DATA nPosQuebras  AS Numeric
	DATA nPosTipoPai  AS Numeric
	DATA nPosRastreio AS Numeric
	DATA nPosTrfEnt   AS Numeric
	DATA nPosTrfSai   AS Numeric
	DATA nPosComp     AS Numeric
	DATA nPosDatIni   AS Numeric
	DATA nPosDatFim   AS Numeric
	DATA nPosTRT      AS Numeric
	DATA nPosRevIni   AS Numeric
	DATA nPosRevFim   AS Numeric
	DATA nPosQtdEst   AS Numeric
	DATA nPosQtdFix   AS Numeric
	DATA nPosPotenc   AS Numeric
	DATA nPosPerda    AS Numeric
	DATA nPosQtdBas   AS Numeric
	DATA nPosFant     AS Numeric
	DATA oDados       AS Object
	DATA oDominio     AS Object
	DATA oNivelProd   AS Object
	DATA oDocsSaida   AS Object
	DATA oUsoDoc      AS Object
	DATA oRegSMEPos   AS Object
	DATA oDocHWC      AS Object
	DATA oEntInclui   AS Object

	METHOD new() CONSTRUCTOR

	METHOD addAglutinado(cFilAux, cDocAgl, cTipoOri, cDocOri, nSeqOri, cTRT, nNecess, nSubsti)
	METHOD addDocEmpenho(cIdReg, cDocumento, cDocOrigem, lAddPre)
	METHOD addDocumento(cFilAux, cTipDocEnt, cNumDocEnt, nSequen, dData, cProduto, cTRT, nBaixaEst, nSubsti, nEmpenho, nNecess, cTipDocSai, cNumDocSai, aLinha)
	METHOD addDocsSaida(cNumDocEnt, aRetorno)
	METHOD addDocHWC(cFilAux, cTipDocEnt, cNumDocEnt, nSequen, dData, cProduto, cTRT, nBaixaEst, nSubsti, nEmpenho, nNecess, cTipDocSai, cNumDocSai, cIdOpc, cList, nPosDoc)
	METHOD addEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc)
	METHOD addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc)
	METHOD addRelacionamentoDocFilho(cDocAgl, nSequen, cDocFilho)
	METHOD addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nQuant, cTipoReg, cTipDocSai, cNumDocSai, cDocPai, nSequen, lSomaQtd, cIdOpc, cLote, cSubLote)
	METHOD addSaldoInicial(cFilAux, dData, cProduto, nQuant, aLotVenc, cIdOpc)
	METHOD atualizaPercentual(oDominio, nTotProc, nTotGrav, nIndGrav)
	METHOD buscaDocsAglutinados(aLinha, nSequen)
	METHOD buscaQtdComp(cNumDocSai, nIndQuebra, cCompon, cTRT, cFilAux)
	METHOD calculaQtdComp(aComponent, cRevisao, cCompon, cTRT, lAglutina, aDocSaida, nNecPai, cFilAux)
	METHOD carregaDocsSaida(cNumDoc)
	METHOD criaIdReg(cDocEnt, lConcatPai)
	METHOD efetivaInclusao()
	METHOD getDocEmpenho(cDocum)
	METHOD getEntradas(cChave)
	METHOD getQtdEntrada(cFilAux, cProduto, dData, cIdOpc)
	METHOD getNivel(cChave)
	METHOD montaRetorno(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nBaixaEst, cTipo, cTipDocSai, cNumDocSai, cTRT, cIdPai, cIdReg, cDocPai, cIdOpc, cLote, cSubLote, lNovoSaldo, nNecess)
	METHOD nivelProduto(cFilAux, cProduto)
	METHOD ordena(aEntradas)
	METHOD procDocHWC()
	METHOD quebraAglutinacaoPai(aRetorno, cFilAux, cProduto, cTRT, nBaixaEst, nDistrib, cTipDocEnt, cNumDocEnt, cTipDocSai, cNumDocSai, dData, cTipo, cDocPai, cTRTAgl, oDocsProc, cSeq, cIdPai, cIdOpc, cLote, cSubLote, lNovoSaldo, nNecess)
	METHOD reservaQtdDocEntrada(aLinha, aNecAgl, nIndQuebra, nQtdNecess)
	METHOD substituiAglutinados(cOrigem, aAglutinad, lRetOPEmp)
	METHOD trataAglutinado(aRegistro)
	METHOD trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)
	METHOD trataEstoque(aRetorno, cTipo, cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)
	METHOD trataRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipo, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc, cLote, cSubLote)
	method efetivaDocHWC()

ENDCLASS

/*/{Protheus.doc} MrpDominio_RastreioEntradas
M�todo construtor da classe MrpDominio_RastreioEntradas
@author marcelo.neumann
@since 07/10/2020
@version 1
@param oDominio, objeto, inst�ncia do objeto de dom�nio
@return Self, objeto, instancia desta classe
/*/
METHOD new(oDominio) CLASS MrpDominio_RastreioEntradas

	Self:aEntInclui   := {}
	Self:oDados       := oDominio:oDados:oRastreioEntradas
	Self:oDominio     := oDominio
	Self:oNivelProd   := JsonObject():New()
	Self:oDocsSaida   := JsonObject():New()
	Self:oUsoDoc      := JsonObject():New()
	Self:oRegSMEPos   := JsonObject():New()
	Self:lAglutinado  := oDominio:oAglutina:processamentoAglutinado()
	Self:lHabilitado  := oDominio:oParametros["lRastreiaEntradas"]
	Self:nPosDocFilho := oDominio:oRastreio:getPosicao("DOCFILHO")
	Self:nPosFilial   := oDominio:oRastreio:getPosicao("FILIAL")
	Self:nPosNecOri   := oDominio:oRastreio:getPosicao("NEC_ORIGINAL")
	Self:nPosNecess   := oDominio:oRastreio:getPosicao("NECESSIDADE")
	Self:nPosEst      := oDominio:oRastreio:getPosicao("QTD_ESTOQUE")
	Self:nPosConEst   := oDominio:oRastreio:getPosicao("CONSUMO_ESTOQUE")
	Self:nPosTipoPai  := oDominio:oRastreio:getPosicao("TIPOPAI")
	Self:nPosDocPai   := oDominio:oRastreio:getPosicao("DOCPAI")
	Self:nPosIdOpc    := oDominio:oRastreio:getPosicao("ID_OPCIONAL")
	Self:nPosPeriodo  := oDominio:oRastreio:getPosicao("PERIODO")
	Self:nPosProduto  := oDominio:oRastreio:getPosicao("COMPONENTE")
	Self:nPosQuebras  := oDominio:oRastreio:getPosicao("QUEBRAS_QUANTIDADE")
	Self:nPosRastreio := oDominio:oRastreio:getPosicao("RASTRO_AGLUTINACAO")
	Self:nPosTrfEnt   := oDominio:oRastreio:getPosicao("TRANSFERENCIA_ENTRADA")
	Self:nPosTrfSai   := oDominio:oRastreio:getPosicao("TRANSFERENCIA_SAIDA")
	Self:nPosComp     := oDominio:oDados:posicaoCampo("EST_CODFIL")
	Self:nPosDatIni   := oDominio:oDados:posicaoCampo("EST_VLDINI")
	Self:nPosDatFim   := oDominio:oDados:posicaoCampo("EST_VLDFIM")
	Self:nPosTRT      := oDominio:oDados:posicaoCampo("EST_TRT")
	Self:nPosRevIni   := oDominio:oDados:posicaoCampo("EST_REVINI")
	Self:nPosRevFim   := oDominio:oDados:posicaoCampo("EST_REVFIM")
	Self:nPosQtdEst   := oDominio:oDados:posicaoCampo("EST_QTD")
	Self:nPosQtdFix   := oDominio:oDados:posicaoCampo("EST_FIXA")
	Self:nPosPotenc   := oDominio:oDados:posicaoCampo("EST_POTEN")
	Self:nPosPerda    := oDominio:oDados:posicaoCampo("EST_PERDA")
	Self:nPosQtdBas   := oDominio:oDados:posicaoCampo("EST_QTDB")
	Self:nPosFant     := oDominio:oDados:posicaoCampo("EST_FANT")
	Self:nPosCodPai   := oDominio:oDados:posicaoCampo("EST_CODPAI")
	Self:oDocHWC      := JsonObject():New()
	Self:oEntInclui   := JsonObject():New()

	If Self:lHabilitado
		If !Self:oDados:existAList(IND_NOME_LISTA_ENTRADAS)
			Self:oDados:createAList(IND_NOME_LISTA_ENTRADAS)
		EndIf

		If !Self:oDados:existAList(IND_CHAVE_DADOS_HWC)
			Self:oDados:createAList(IND_CHAVE_DADOS_HWC)
		EndIf

		If !Self:oDados:existAList(IND_CHAVE_DOCUMENTOS_SAIDA)
			Self:oDados:createAList(IND_CHAVE_DOCUMENTOS_SAIDA)
		EndIf

		If !Self:oDados:existAList(IND_CHAVE_DOCUMENTOS_USO)
			Self:oDados:createAList(IND_CHAVE_DOCUMENTOS_USO)
		EndIf

		If !Self:oDados:existAList("PRODUTOS_SME")
			Self:oDados:createAList("PRODUTOS_SME")
		EndIf
	EndIf

Return Self

/*/{Protheus.doc} addSaldoInicial
Adiciona um registro referente a um saldo inicial de um produto
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux  , caracter, c�digo da filial
@param 02 dData    , data    , data do registro
@param 03 cProduto , num�rico, c�digo do produto
@param 04 aInfoLote, array   , Array com informa��es do lote: [1][1] Quantidade
                                                              [1][2] Data de Validade
                                                              [1][3] Local
                                                              [1][4] Lote
                                                              [1][5] Sub-lote
@param 05 cIdOpc   , caracter, id do opcional
@return Nil
/*/
METHOD addSaldoInicial(cFilAux, dData, cProduto, aInfoLote, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aAux       := {}
	Local aSaldos    := {}
	Local cLote      := ""
	Local cSubLote   := ""
	Local cIdReg     := ""
	Local cNumDocEnt := "SaldoInicial"
	Local cTipDocEnt := "SI"
	Local lErro      := .F.
	Local lOk        := .T.
	Local nQuant     := 0

	cIdOpc  := AllTrim(cIdOpc)
	cFilAux := xFilial("SME") //Nesse momento n�o haver� o controle Multi-Filial

	aAux     := Array(ASALDOS_SIZE)
	cIdReg   := "0_" + cFilAux + cProduto + cIdOpc
	nQuant   := aInfoLote[1]
	cLote    := aInfoLote[4]
	cSubLote := aInfoLote[5]

	aSaldos := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)
	If aSaldos == Nil
		aSaldos := {}
	EndIf

	aAux[ASALDOS_POS_TIPO           ] := cTipDocEnt
	aAux[ASALDOS_POS_NUM_DOC_ENTRADA] := cNumDocEnt
	aAux[ASALDOS_POS_DATA           ] := dData
	aAux[ASALDOS_POS_QUANTIDADE     ] := nQuant
	aAux[ASALDOS_POS_VENCIMENTO     ] := aInfoLote[2]
	aAux[ASALDOS_POS_LOTE           ] := cLote
	aAux[ASALDOS_POS_SUBLOTE        ] := cSubLote

	aAdd(aSaldos, aClone(aAux))

	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aSaldos, @lErro)

	If lErro
		lOk := .F.
	Else
		Self:addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, , nQuant, "0", "", "", "", 1, .F., cIdOpc, cLote, cSubLote)
	EndIf

	aSize(aAux   , 0)
	aSize(aSaldos, 0)

Return lOk

/*/{Protheus.doc} addEntradaPrevista
Adiciona um registro referente a uma entrada prevista de um produto
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, c�digo da filial
@param 02 cTipDocEnt, caracter, tipo da entrada (OP, PC, SC)
@param 03 cNumDocEnt, caracter, n�mero do documento de entrada
@param 04 dData     , data    , data do registro
@param 05 cProduto  , caracter, c�digo do produto
@param 06 nQuant    , num�rico, quantidade do produto
@param 07 cIdOpc    , caracter, id do Opcional
@return   lOk       , l�gico  , indica se foi gravado com sucesso
/*/
METHOD addEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aAux   := {}
	Local aSaldo := {}
	Local cIdReg := ""
	Local lErro  := .F.
	Local lOk    := .T.

	cIdOpc     := AllTrim(cIdOpc)
	cFilAux    := xFilial("SME") //Nesse momento n�o haver� o controle Multi-Filial
	cNumDocEnt := "Pre_" + cNumDocEnt

	aAux   := Array(ASALDOS_SIZE)
	cIdReg := "1_" + cFilAux + cProduto + cIdOpc

	Self:oDados:trava(cIdReg)
	aSaldo := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If Empty(aSaldo) .Or. lErro
		aSaldo := {}
	EndIf

	aAux[ASALDOS_POS_TIPO           ] := cTipDocEnt
	aAux[ASALDOS_POS_NUM_DOC_ENTRADA] := cNumDocEnt
	aAux[ASALDOS_POS_DATA           ] := dData
	aAux[ASALDOS_POS_QUANTIDADE     ] := nQuant
	aAux[ASALDOS_POS_VENCIMENTO     ] := Nil
	aAdd(aSaldo, aAux)

	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aSaldo, @lErro)
	Self:oDados:destrava(cIdReg)

	If lErro
		lOk := .F.
	Else
		Self:addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, , nQuant, "1", "", "", "", 1, .F., cIdOpc)
	EndIf

	aSize(aAux  , 0)
	aSize(aSaldo, 0)

Return lOk

/*/{Protheus.doc} addNovoSaldo
Adiciona um registro referente a um novo saldo gerado para um produto durante o processamento (Lote Econ�mico, Ponto de Pedido)
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, c�digo da filial
@param 02 cTipDocEnt , caracter, tipo do documento de entrada (OP, PC, SC)
@param 03 cNumDocEnt, caracter, n�mero do documento de entrada
@param 04 dData     , data    , data do registro
@param 05 cProduto  , caracter, c�digo do produto
@param 06 nQuant    , num�rico, quantidade do produto
@param 07 cIdOpc    , caracter, id do opcional
@return   lOk       , l�gico  , indica se foi gravado com sucesso
/*/
METHOD addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aAux   := {}
	Local aSaldo := {}
	Local cIdReg := ""
	Local lErro  := .F.
	Local lOk    := .T.
	Default cIdOpc := ""

	cIdOpc  := AllTrim(cIdOpc)
	cFilAux := xFilial("SME") //Nesse momento n�o haver� o controle Multi-Filial
	aAux    := Array(ASALDOS_SIZE)
	cIdReg  := "3_" + cFilAux + cProduto + cIdOpc

	Self:oDados:trava(cIdReg)
	aSaldo := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If Empty(aSaldo) .Or. lErro
		aSaldo := {}
	EndIf

	aAux[ASALDOS_POS_TIPO           ] := cTipDocEnt
	aAux[ASALDOS_POS_NUM_DOC_ENTRADA] := cNumDocEnt
	aAux[ASALDOS_POS_DATA           ] := dData
	aAux[ASALDOS_POS_QUANTIDADE     ] := nQuant
	aAux[ASALDOS_POS_VENCIMENTO     ] := Nil
	aAdd(aSaldo, aAux)

	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aSaldo, @lErro)
	Self:oDados:destrava(cIdReg)

	If lErro
		lOk := .F.
	EndIf

	aSize(aAux  , 0)
	aSize(aSaldo, 0)

Return lOk

/*/{Protheus.doc} addRegistroSME
Adiciona um registro para ser gravado na tabela SME
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo de entrada (OP, SC, PC)
@param 03 cNumDocEnt, caracter, n�mero do documento referente � entrada
@param 04 dData     , date    , data da entrada
@param 05 cProduto  , caracter, produto da entrada
@param 06 cTRT      , caracter, sequencial do produto
@param 07 nQuant    , num�rico, quantidade da entrada
@param 08 cTipoReg  , caracter, tipo de registro
                                0 = Saldo Inicial
                                1 = Entrada Prevista
                                2 = Composi��o da Rastreabilidade
                                3 = Saldo gerado pela Entrada Prevista (quando por exemplo uma OP produz 10 e o empenho � de 8)
@param 09 cTipDocSai, caracter, tipo do documento de sa�da gerado para essa entrada
@param 10 cNumDocSai, caracter, n�mero do documento de sa�da gerado para essa entrada
@param 11 cDocPai   , caracter, documento pai do registro da HWC
@param 12 nSequen   , numerico, sequ�ncia do registro da HWC
@param 13 lSomaQtd  , l�gico  , indica se deve somar a quantidade caso j� exista registro igual
@param 14 cIdOpc    , caracter, id do opcional
@param 15 cLote     , caracter, c�digo do lote
@param 16 cSubLote  , caracter, c�digo do sub-lote
@return Nil
/*/
METHOD addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nQuant, cTipoReg, cTipDocSai, cNumDocSai, cDocPai, nSequen, lSomaQtd, cIdOpc, cLote, cSubLote) CLASS MrpDominio_RastreioEntradas
	Local cChave     := ""
	Local cChvProd   := ""
	Local lUsaMe     := Self:oDominio:oMultiEmp:utilizaMultiEmpresa()

	Default cDocPai  := ""
	Default nSequen  := 1
	Default lSomaQtd := .F.
	Default cIdOpc   := ""
	Default cLote    := ""
	Default cSubLote := ""

	aEntrada := Array(AENTRADAS_SIZE)
	aEntrada[AENTRADAS_POS_FILIAL          ] := cFilAux
	aEntrada[AENTRADAS_POS_TIPO_DOC_ENTRADA] := GetTipoEnt(cTipDocEnt)
	aEntrada[AENTRADAS_POS_NUM_DOC_ENTRADA ] := cNumDocEnt
	aEntrada[AENTRADAS_POS_DATA            ] := dData
	aEntrada[AENTRADAS_POS_PRODUTO         ] := cProduto
	aEntrada[AENTRADAS_POS_TRT             ] := cTRT
	aEntrada[AENTRADAS_POS_QUANTIDADE      ] := nQuant
	aEntrada[AENTRADAS_POS_TIPO_REGISTRO   ] := cTipoReg
	aEntrada[AENTRADAS_POS_TIPO_DOC_SAIDA  ] := cTipDocSai
	aEntrada[AENTRADAS_POS_NUM_DOC_SAIDA   ] := cNumDocSai
	aEntrada[AENTRADAS_POS_NIVEL           ] := Self:nivelProduto("", cProduto) //Passa filial em branco pois rastreabilidade ainda n�o est� preparada para multi-empresa.
	aEntrada[AENTRADAS_POS_DOCPAI          ] := cDocPai
	aEntrada[AENTRADAS_POS_SEQUEN          ] := nSequen
	aEntrada[AENTRADAS_POS_OPCIONAL        ] := AllTrim(cIdOpc)
	aEntrada[AENTRADAS_POS_LOTE            ] := cLote
	aEntrada[AENTRADAS_POS_SUBLOTE         ] := cSubLote

	cChave := RTrim(aEntrada[AENTRADAS_POS_FILIAL          ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_TIPO_DOC_ENTRADA]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_NUM_DOC_ENTRADA ]) + "|"
	cChave += DtoS( aEntrada[AENTRADAS_POS_DATA            ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_PRODUTO         ]) + "|"
	cChave += Iif(aEntrada[AENTRADAS_POS_TRT]==Nil,"",RTrim(aEntrada[AENTRADAS_POS_TRT])) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_TIPO_REGISTRO   ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_TIPO_DOC_SAIDA  ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_NUM_DOC_SAIDA   ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_DOCPAI          ]) + "|"
	cChave += Str(  aEntrada[AENTRADAS_POS_SEQUEN          ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_OPCIONAL        ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_LOTE            ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_SUBLOTE         ])

	cChvProd := IIf(lUsaMe, aEntrada[AENTRADAS_POS_FILIAL], "")
	cChvProd += RTrim(aEntrada[AENTRADAS_POS_PRODUTO]) + CHR(13)
	cChvProd += AllTrim(aEntrada[AENTRADAS_POS_OPCIONAL])

	If !Self:oEntInclui:HasProperty(cChvProd)
		Self:oEntInclui[cChvProd] := {}
	EndIf

	If lSomaQtd .And. Self:oRegSMEPos:HasProperty(cChave)
		Self:oEntInclui[cChvProd][Self:oRegSMEPos[cChave]][AENTRADAS_POS_QUANTIDADE] += aEntrada[AENTRADAS_POS_QUANTIDADE]
	Else
		aAdd(Self:oEntInclui[cChvProd], aEntrada)
	EndIf

	Self:oRegSMEPos[cChave] := Len(Self:oEntInclui[cChvProd])
Return

/*/{Protheus.doc} efetivaInclusao
Grava em vari�vel global os registros de entradas contidos no array Self:aEntInclui
@author marcelo.neumann
@since 30/11/2020
@version 1
@return lOk, l�gico, indica se gravou a informa��o em mem�ria
/*/
METHOD efetivaInclusao() CLASS MrpDominio_RastreioEntradas
	Local aChaves := {}
	Local aNames  := Self:oEntInclui:GetNames()
	Local cChave  := ""
	Local cNivel  := ""
	Local lErro   := .F.
	Local lOk     := .T.
	Local nIndex  := 0
	Local nTotal  := 0
	Local oProds  := Nil

	nTotal := Len(aNames)

	If nTotal > 0
		oProds := JsonObject():New()
		For nIndex := 1 To nTotal
			cChave := aNames[nIndex]

			Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, IND_CHAVE_GRAVAR_SME + cChave, Self:oEntInclui[cChave], @lErro,,.T., 2)
			lOk := Iif(lErro, .F., lOk)
			oProds[cChave] := Self:oEntInclui[cChave][1][AENTRADAS_POS_NIVEL]

			aSize(Self:oEntInclui[cChave], 0)
			Self:oEntInclui:delName(cChave)
		Next nIndex
		aSize(Self:aEntInclui, 0)

		aChaves := oProds:GetNames()
		nTotal  := Len(aChaves)
		For nIndex := 1 To nTotal
			cNivel := oProds[aChaves[nIndex]]
			If cNivel == Nil
				cNivel := "--"
			EndIf
			Self:oDados:setItemList("PRODUTOS_SME", aChaves[nIndex], cNivel)
		Next nIndex
		aSize(aChaves, 0)
		FreeObj(oProds)

	EndIf

Return lOk

/*/{Protheus.doc} getEntradas
Retorna o array com a rastreabilidade das entradas

@author marcelo.neumann
@since 30/11/2020
@version 1
@param cChave, Caracter, Chave do produto para buscar as entradas.
@return aEntrada, array, array com a rastreabilidade das entradas
/*/
METHOD getEntradas(cChave) CLASS MrpDominio_RastreioEntradas
	Local aEntradas := {}
	Local lErro     := .F.

	aEntradas := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, IND_CHAVE_GRAVAR_SME + cChave, @lErro)
	If lErro .Or. aEntradas == Nil .Or. ValType(aEntradas) <> "A"
		aEntradas := {}
	EndIf

Return aEntradas

/*/{Protheus.doc} getNivel
Busca o n�vel do produto a partir da chave utilizada na lista global PRODUTOS_SME.

@author lucas.franca
@since 02/12/2022
@version P12
@param cChave, Caracter, Chave do produto para buscar o n�vel.
@return cNivel, Caracter, N�vel do produto.
/*/
METHOD getNivel(cChave) CLASS MrpDominio_RastreioEntradas
	Local aDados    := STRTOKARR( cChave, CHR(13) )
	Local cNivel    := "99"
	Local cChavePrd := PadR(aDados[1], snTamCod) + Iif(Len(aDados)>1, "|"+aDados[2],"")

	cNivel := Self:nivelProduto('', cChavePrd)
	aSize(aDados, 0)

Return cNivel

/*/{Protheus.doc} nivelProduto
Retorna o n�vel do produto
@author lucas.franca
@since 17/03/2021
@version P12
@param cFilAux , Character, C�digo da filial
@param cProduto, Character, C�digo do produto
@return cNivel , Character, N�vel do produto
/*/
METHOD nivelProduto(cFilAux, cProduto) CLASS MrpDominio_RastreioEntradas
	Local aAreaPRD   := {}
	Local cChaveProd := cFilAux + cProduto
	Local cNivel     := Self:oNivelProd[cChaveProd]
	Local lErrorPrd  := .F.
	Local lAtual     := .F.

	If cNivel == Nil
		lAtual := cChaveProd == Self:oDominio:oDados:oProdutos:cCurrentKey
		If !lAtual
			aAreaPRD := Self:oDominio:oDados:retornaArea("PRD")
		EndIf

		cNivel := Self:oDominio:oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_NIVEST", @lErrorPrd, lAtual)

		If lErrorPrd .Or. Empty(cNivel)
			cNivel := Nil
		EndIf

		Self:oNivelProd[cChaveProd] := cNivel

		If !lAtual
			Self:oDominio:oDados:setaArea(aAreaPRD)
			aSize(aAreaPRD, 0)
		EndIf
	EndIf

Return cNivel

/*/{Protheus.doc} ordena
Ordena o array com a rastreabilidade das entradas
@author marcelo.neumann
@since 30/11/2020
@version 1
@param aEntradas, array, array com as entradas a serem ordenadas
@return Nil
/*/
METHOD ordena(aEntradas) CLASS MrpDominio_RastreioEntradas

	If !Empty(aEntradas)
		/*
			Ordena o array aEntradas para:
			x[AENTRADAS_POS_NIVEL]                                   -> N�vel do produto
			DtoS(x[AENTRADAS_POS_DATA])                              -> Data da entrada
			x[AENTRADAS_POS_PRODUTO]                                 -> Produto
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="ESTNEG", "0", "1") -> Registros de estoque negativo primeiro.
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0144, "0", "1")  -> Registros de estoque de seguran�a primeiro.
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="Pr�-OP", "0", "1") -> Registros de empenhos primeiro.
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0143, "1", "0")  -> Registros de ponto de pedido por �ltimo
			x[AENTRADAS_POS_NUM_DOC_SAIDA     ]                      -> Documento de sa�da
			x[AENTRADAS_POS_TIPO_DOC_ENTRADA]                        -> Tipo do documento
			x[AENTRADAS_POS_NUM_DOC_ENTRADA]                         -> N�mero do documento
		*/
		aSort(aEntradas, , , {|x,y| Iif(x[AENTRADAS_POS_NIVEL]==Nil,;
		                                x[AENTRADAS_POS_NIVEL] := Self:nivelProduto("", x[AENTRADAS_POS_PRODUTO]),;
		                                x[AENTRADAS_POS_NIVEL])+ ;
		                            DtoS(x[AENTRADAS_POS_DATA])                              + ;
		                            x[AENTRADAS_POS_PRODUTO]                                 + ;
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="ESTNEG", "0", "1") + ; //Estoque negativo
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0143, "0", "1")  + ; //"Est.Seg."
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="Pr�-OP", "0", "1") + ; //Empenho
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0144, "1", "0")  + ; //"Ponto Ped."
		                            x[AENTRADAS_POS_NUM_DOC_SAIDA     ]                      + ;
		                            x[AENTRADAS_POS_TIPO_DOC_ENTRADA  ]                      + ;
		                            x[AENTRADAS_POS_NUM_DOC_ENTRADA   ]                        ;
		                          < ;
		                            Iif(y[AENTRADAS_POS_NIVEL]==Nil,;
		                                y[AENTRADAS_POS_NIVEL] := Self:nivelProduto("", y[AENTRADAS_POS_PRODUTO]),;
		                                y[AENTRADAS_POS_NIVEL])+ ;
		                            DtoS(y[AENTRADAS_POS_DATA])                              + ;
		                            y[AENTRADAS_POS_PRODUTO]                                 + ;
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]=="ESTNEG", "0", "1") + ; //Estoque negativo
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0143, "0", "1")  + ; //"Est.Seg."
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]=="Pr�-OP", "0", "1") + ; //Empenho
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0144, "1", "0")  + ; //"Ponto Ped."
		                            y[AENTRADAS_POS_NUM_DOC_SAIDA     ]                      + ;
		                            y[AENTRADAS_POS_TIPO_DOC_ENTRADA  ]                      + ;
		                            y[AENTRADAS_POS_NUM_DOC_ENTRADA   ]                       })
	EndIf

Return

/*/{Protheus.doc} addDocumento
Adiciona um documento (registro da tabela HWC)
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo de entrada (OP, SC, PC)
@param 03 cNumDocEnt, caracter, n�mero do documento referente � entrada
@param 04 nSequen   , num�rico, sequ�ncia do documento
@param 05 dData     , data    , data do documento
@param 06 cProduto  , caracter, c�digo do produto
@param 07 cTRT      , caracter, TRT do produto da sequ�ncia
@param 08 nBaixaEst , num�rico, quantidade baixada do estoque
@param 09 nSubsti   , num�rico, quantidade substitu�da por um alternativo
@param 10 nEmpenho  , num�rico, quantidade empenhada
@param 11 nNecess   , num�rico, necessidade gerada
@param 12 cTipDocSai, caracter, tipo do documento de sa�da
@param 13 cNumDocSai, caracter, n�mero do documento de sa�da
@param 14 aLinha    , array   , array com os dados de mem�ria da rastreabilidade
@param 15 cIdOpc    , caracter, id do opcional
@return Nil
/*/
METHOD addDocumento(cFilAux   , cTipDocEnt, cNumDocEnt, nSequen , dData  , cProduto  , ;
                    cTRT      , nBaixaEst , nSubsti   , nEmpenho, nNecess, cTipDocSai, ;
                    cNumDocSai, aLinha    , cIdOpc) CLASS MrpDominio_RastreioEntradas

	Local aDocsEntr  := {}
	Local cDocSaiPar := cNumDocSai
	Local cDocPai    := aLinha[Self:nPosDocPai]
	Local lAddRel    := .F.
	Local lPossuiAgl := .F.
	Local lUsaQtdQbr := !Empty(nSequen) .And. nSequen <= Len(aLinha[Self:nPosQuebras]) .And. !Empty(aLinha[Self:nPosQuebras][nSequen][1])
	Local nBaixaOrig := nBaixaEst
	Local nIndDocEnt := 0
	Local nSobraSld  := 0
	Local nTotDocEnt := 0

	cIdOpc     := AllTrim(cIdOpc)
	cTipDocSai := AllTrim(cTipDocSai)
	cFilAux    := xFilial("SME") //Nesse momento n�o haver� o controle Multi-Filial

	//Verifica se este registro teve a sua necessidade aglutinada em um registro do TIPO_PAI=AGL.
	//Se sim, utiliza como DOC DE ENTRADA o documento gerado pelo registro aglutinador, e utiliza a
	//quantidade real de necessidade deste registro para os c�lculos da gera��o do rastreio.
	If aLinha[Self:nPosRastreio][1] <> 0 .And. !Empty(aLinha[Self:nPosRastreio][2]) .And. Empty(cNumDocEnt)
		nBaixaEst  -= aLinha[Self:nPosRastreio][1]
		nNecess    += aLinha[Self:nPosRastreio][1]
		aDocsEntr  := Self:buscaDocsAglutinados(aLinha, nSequen)
		nTotDocEnt := Len(aDocsEntr)
	EndIf

	If nTotDocEnt > 0
		lPossuiAgl := .T.
	EndIf

	If cTipDocSai == "1" // PMP
		nSobraSld := nNecess
	Else
		nSobraSld := aLinha[Self:nPosNecess] - (aLinha[Self:nPosNecOri] - nBaixaEst)
	EndIf

	If cTipDocSai == STR0143 .Or. cTipDocSai == "ESTNEG" //"Est.Seg."
		If Empty(cNumDocEnt)
			cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
		EndIf
		If nTotDocEnt == 0
			If lUsaQtdQbr
				nNecess := aLinha[Self:nPosQuebras][nSequen][1]
			Else
				nNecess := aLinha[Self:nPosNecess]
			EndIf
			aAdd(aDocsEntr, {cNumDocEnt, nNecess})
			nTotDocEnt := 1
		EndIf

		If nBaixaEst > 0
			Self:trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, aDocsEntr[1][1], dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)
		EndIf

		For nIndDocEnt := 1 To nTotDocEnt
			Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			cNumDocEnt := aDocsEntr[nIndDocEnt][1]

			If Self:lAglutinado
				Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, cNumDocEnt)
			EndIf
		Next nIndDocEnt

		If nSobraSld > 0
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
		EndIf

	ElseIf cTipDocSai $ STR0144 //"Ponto Ped."
		If Empty(cNumDocEnt)
			cNumDocEnt := STR0144 + DToS(dData) + "_" + cValToChar(nSequen) + "_Filha"
		EndIf

		If nTotDocEnt == 0
			If lUsaQtdQbr
				nNecess := aLinha[Self:nPosQuebras][nSequen][1]
			Else
				nNecess := aLinha[Self:nPosNecOri]
			EndIf
			aAdd(aDocsEntr, {cNumDocEnt, nNecess})
			nTotDocEnt := 1
		EndIf

		For nIndDocEnt := 1 To nTotDocEnt
			Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			Self:addNovoSaldo(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, aDocsEntr[nIndDocEnt][2], cIdOpc)

			If Self:lAglutinado
				Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
			EndIf
		Next nIndDocEnt

	ElseIf cTipDocSai == "Pr�-OP"
		If !Self:lAglutinado
			cNumDocSai := Self:getDocEmpenho(cNumDocSai)[1]
		EndIf

		If nBaixaEst > 0
			Self:trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, "OP", cNumDocSai, cDocPai, nSequen, cIdOpc)

			If nBaixaEst > 0
				Self:addRegistroSME(cFilAux, "", "", dData, cProduto, cTRT, nBaixaEst, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			EndIf
		EndIf

		If nNecess > 0
			If Empty(cNumDocEnt)
				If Self:lAglutinado
					cNumDocEnt := Trim(cDocSaiPar) + "_" + cValToChar(nSequen) + "_Filha"
				Else
					cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
				EndIf
			EndIf

			If nTotDocEnt == 0
				If lUsaQtdQbr
					nNecess := aLinha[Self:nPosQuebras][nSequen][1]
				Else
					nNecess := aLinha[Self:nPosNecOri] - nBaixaOrig
				EndIf
				aAdd(aDocsEntr, {cNumDocEnt, nNecess})
				nTotDocEnt := 1
			EndIf

			For nIndDocEnt := 1 To nTotDocEnt
				Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
				cNumDocEnt := aDocsEntr[nIndDocEnt][1]

				If Self:lAglutinado
					Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, cNumDocEnt)
				EndIf
			Next nIndDocEnt

			If nSobraSld > 0
				Self:addNovoSaldo(cFilAux, "OP", cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
			EndIf

		EndIf

	ElseIf cTipDocSai $ "0123459"
		If nNecess > 0

			If Empty(cNumDocEnt)
				cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
			EndIf

			If nTotDocEnt == 0
				If lUsaQtdQbr
					nNecess := aLinha[Self:nPosQuebras][nSequen][1]
				Else
					nNecess := aLinha[Self:nPosNecOri] - nBaixaEst
				EndIf
				aAdd(aDocsEntr, {cNumDocEnt, nNecess})
				nTotDocEnt := 1
			EndIf

			For nIndDocEnt := 1 To nTotDocEnt
				Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)

				If Self:lAglutinado .And. !lPossuiAgl
					Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
				EndIf
			Next nIndDocEnt

			If nSobraSld > 0
				Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
			EndIf

		EndIf

		If nBaixaEst > 0
			Self:trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)

			If nBaixaEst > 0
				Self:addRegistroSME(cFilAux, "", "", dData, cProduto, cTRT, nBaixaEst, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			EndIf
		EndIf

	ElseIf cTipDocSai == "OP"
		If nSubsti < 0
			nBaixaEst := -nSubsti

			If nNecess > 0
				If Empty(cNumDocEnt)
					cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
				Else
					If nBaixaEst > 0
						Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, cNumDocEnt)
					EndIf
				EndIf

				Self:addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nNecess, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			EndIf
		EndIf

		If (nEmpenho - nBaixaEst) > 0
			If nTotDocEnt > 0 .Or. !Empty(cNumDocEnt)
				lAddRel := .T.
			EndIf
			If Empty(cNumDocEnt)
				cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
			EndIf

			If nTotDocEnt == 0
				aAdd(aDocsEntr, {cNumDocEnt, (nEmpenho - nBaixaEst)})
				nTotDocEnt := 1
			EndIf

			For nIndDocEnt := 1 To nTotDocEnt
				Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)

				If lAddRel .And. Self:lAglutinado
					Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
				EndIf
			Next nIndDocEnt
		EndIf

		If nBaixaEst > 0
			Self:addRegistroSME(cFilAux, "", "", dData, cProduto, cTRT, nBaixaEst, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
		EndIf

		If nNecess > 0 .And. nEmpenho > 0 .And. nNecess > (nEmpenho - nBaixaEst)
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, (nNecess - (nEmpenho - nBaixaEst)), cIdOpc)
		ElseIf nEmpenho < 0
			//Empenho negativo adiciona como entrada de saldo
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocSai, dData, cProduto, Abs(nEmpenho), cIdOpc)
		EndIf
	ElseIf cTipDocSai == "AGL" .And. nNecess > 0
		If nTotDocEnt == 0
			If Empty(cNumDocEnt)
				cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
			EndIf
			If lUsaQtdQbr
				nNecess := aLinha[Self:nPosQuebras][nSequen][1]
			Else
				nNecess := aLinha[Self:nPosNecOri]
			EndIf
			aAdd(aDocsEntr, {cNumDocEnt, nNecess})
			nTotDocEnt := 1
		EndIf

		For nIndDocEnt := 1 To nTotDocEnt
			Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
		Next nIndDocEnt

		If nSobraSld > 0
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
		EndIf

	EndIf

	aSize(aDocsEntr, 0)
Return

/*/{Protheus.doc} trataBaixaEntradaPrevista
Busca as entradas previstas que foram utilizadas pelo documento de sa�da
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo do documento de entrada
@param 03 cNumDocEnt, caracter, n�mero do documento de entrada
@param 04 dData     , date    , data da entrada
@param 05 cProduto  , caracter, produto da entrada
@param 06 cTRT      , caracter, TRT do produto na estrutura
@param 07 nBaixaEst , num�rico, quantidade da entrada
@param 08 cTipDocSai, caracter, tipo do documento de sa�da
@param 09 cNumDocSai, caracter, n�mero do documento de sa�da
@param 10 cDocPai   , caracter, documento pai do registro da HWC
@param 11 nSequen   . num�rico, sequ�ncia do registro da HWC
@param 12 cIdOpc    , caracter, id do opcional
@return Nil
/*/
METHOD trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aEntAdd   := {}
	Local aEntradas := {}
	Local nIndex    := 0
	Local nLenEntr  := 0
	Local nNecec    := 0
	Local nQtdDoc   := 0

	cIdOpc  := AllTrim(cIdOpc)
	nQtdDoc := Self:getQtdEntrada(cFilAux, cProduto, dData, cIdOpc)

	If cTipDocSai == STR0143 //Est.Seg
		//Quando � estoque de seguran�a, registra as baixas de estoque antes de verificar as baixas por documentos de entrada
		Self:trataEstoque(@aEntAdd  , ;
		                  "0"       , ;
		                  cFilAux   , ;
		                  "SI"      , ;
		                  ""        , ;
		                  dData     , ;
		                  cProduto  , ;
		                  cTRT      , ;
		                  nBaixaEst , ;
		                  cTipDocSai, ;
		                  cNumDocSai, ;
		                  cDocPai   , ;
		                  nSequen   , ;
		                  cIdOpc    )

		nLenEntr   := Len(aEntAdd)
		For nIndex := 1 To nLenEntr
			cNumDocSai := Self:getDocEmpenho(aEntAdd[nIndex][9])[1]

			Self:addRegistroSME(cFilAux            , ;
			                    aEntAdd[nIndex][2] , ;
			                    aEntAdd[nIndex][3] , ;
			                    dData              , ;
			                    cProduto           , ;
			                    aEntAdd[nIndex][10], ;
			                    aEntAdd[nIndex][6] , ;
			                    "2"                , ;
			                    aEntAdd[nIndex][8] , ;
			                    cNumDocSai         , ;
			                    cDocPai            , ;
			                    nSequen            , ;
			                    .T.                , ;
			                    cIdOpc             )
			nBaixaEst -= aEntAdd[nIndex][6]
		Next nIndex
		aSize(aEntAdd, 0)
	EndIf

	//Verifica se j� foi realizada a baixa completa por consumo de estoque para o estoque de seguran�a.
	If nBaixaEst > 0
		nNecec := nBaixaEst

		If nNecec > nQtdDoc
			nNecec := nQtdDoc
		EndIf

		//Se estiver aglutinando, deve explodir os documentos para buscar a OP correta do Empenho (usando o TRT)
		aEntradas := Self:substituiAglutinados("S", ;
		                                       {Self:montaRetorno(cFilAux     ,;
		                                                           cTipDocEnt ,;
		                                                           cNumDocEnt ,;
		                                                           dData      ,;
		                                                           cProduto   ,;
		                                                           nNecec     ,;
		                                                           "3"        ,;
		                                                           cTipDocSai ,;
		                                                           cNumDocSai ,;
		                                                           cTRT       ,;
		                                                           ""         ,;
		                                                           ""         ,;
		                                                           cDocPai    ,;
		                                                           cIdOpc     ,;
		                                                           ""         ,;
		                                                           "");
		                                       }, ;
		                                       .F.)

		//Percorre os documentos ap�s a explos�o buscando a OP que fez a baixa
		nLenEntr  := Len(aEntradas)
		For nIndex := 1 To nLenEntr
			Self:trataEstoque(@aEntAdd             , ;
			                  "1"                  , ;
			                  aEntradas[nIndex][1] , ;
			                  aEntradas[nIndex][2] , ;
			                  aEntradas[nIndex][3] , ;
			                  aEntradas[nIndex][4] , ;
			                  aEntradas[nIndex][5] , ;
			                  aEntradas[nIndex][10], ;
			                  aEntradas[nIndex][6] , ;
			                  aEntradas[nIndex][8] , ;
			                  aEntradas[nIndex][9] , ;
			                  cDocPai              , ;
			                  nSequen              , ;
			                  cIdOpc               )
		Next nIndex

		nLenEntr  := Len(aEntAdd)
		For nIndex := 1 To nLenEntr
			cNumDocSai := Self:getDocEmpenho(aEntAdd[nIndex][9])[1]

			Self:addRegistroSME(cFilAux            , ;
			                    aEntAdd[nIndex][2] , ;
			                    aEntAdd[nIndex][3] , ;
			                    dData              , ;
			                    cProduto           , ;
			                    aEntAdd[nIndex][10], ;
			                    aEntAdd[nIndex][6] , ;
			                    "3"                , ;
			                    aEntAdd[nIndex][8] , ;
			                    cNumDocSai         , ;
			                    cDocPai            , ;
			                    nSequen            , ;
			                    .T.                , ;
			                    cIdOpc             )
			nBaixaEst -= aEntAdd[nIndex][6]
		Next nIndex
	EndIf
Return

/*/{Protheus.doc} trataRegistroSME
Faz o tratamento do registro para gravar na tabela SME. Explode a aglutina��o se necess�rio.
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo do documento de entrada
@param 03 cNumDocEnt, caracter, n�mero do documento de entrada
@param 04 dData     , date    , data do documento
@param 05 cProduto  , caracter, c�digo do produto
@param 06 cTRT      , caracter, TRT do produto
@param 07 nBaixaEst , num�rico, quantidade da baixa
@param 08 cTipo     , caracter, tipo do registro
@param 09 cTipDocSai, caracter, tipo do documento de sa�da
@param 10 cNumDocSai, caracter, n�mero do documento de sa�da
@param 11 cDocPai   , caracter, n�mero do documento pai da HWC
@param 12 nSequen   , num�rico, sequ�ncia do registro da HWC
@param 13 cIdOpc    , caracter, id do opcional
@param 14 cLote     , caracter, c�digo do lote
@param 15 cSubLote  , caracter, c�digo do sub-lote
@return aRetorno, array, array com o(s) registro(s) a ser(em) gravado(s) na SME
/*/
METHOD trataRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipo, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc, cLote, cSubLote) CLASS MrpDominio_RastreioEntradas
	Local aRetorno   := {}
	Local lDemanda   := .F.
	Local nCntNewDoc := 0
	Local nIndex     := 0
	Local nQtdTotal  := 0
	Local nTotal     := 0
	Default cIdOpc   := ""

	cIdOpc  := AllTrim(cIdOpc)
	cFilAux := xFilial("SME") //Nesse momento n�o haver� o controle Multi-Filial

	//Verifica se o registro � dependente de alguma baixa de estoque
	If Empty(cTipDocEnt) .And. Empty(cNumDocEnt)
		//Trata saldo inicial
		Self:trataEstoque(@aRetorno, "0", cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)

		//Trata novos saldos
		If nBaixaEst > 0
			Self:trataEstoque(@aRetorno, "1", cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)

			If nBaixaEst > 0
				Self:trataEstoque(@aRetorno, "3", cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)
			EndIf
		EndIf

		Self:trataAglutinado(@aRetorno)
	Else
		aAdd(aRetorno, Self:montaRetorno(cFilAux   , ;
		                                 cTipDocEnt, ;
		                                 cNumDocEnt, ;
		                                 dData     , ;
		                                 cProduto  , ;
		                                 nBaixaEst , ;
		                                 cTipo     , ;
		                                 cTipDocSai, ;
		                                 cNumDocSai, ;
		                                 cTRT      , ;
		                                 ""        , ;
		                                 ""        , ;
		                                 cDocPai   , ;
		                                 cIdOpc    , ;
		                                 cLote     , ;
		                                 cSubLote  , ;
		                                 .F.       , ;
		                                 nBaixaEst ) )

		Self:trataAglutinado(@aRetorno)
	EndIf

	nTotal := Len(aRetorno)
	For nIndex := 1 To nTotal

		aRetorno[nIndex][12] := Self:criaIdReg(aRetorno[nIndex][3], aRetorno[nIndex][17])
		nQtdTotal            += aRetorno[nIndex][6]

		If !lDemanda
			lDemanda := "|"+aRetorno[nIndex][8]+"|" $ "|0|1|2|3|4|5|9|Pr�-OP|"
		EndIf
		If Left(aRetorno[nIndex][3], 4) != "Pre_"
			nCntNewDoc++
		EndIf
	Next nIndex

	If !Empty(cNumDocEnt)
		If nCntNewDoc > 1 .And. nQtdTotal > 0 .And. Self:oDominio:oAglutina:avaliaAglutinacao("", cProduto, lDemanda)
			Self:addRelacionamentoDocFilho(cDocPai, 1, cNumDocEnt)

			If cTipDocSai == "Pr�-OP"
				Self:addDocEmpenho(cDocPai, cNumDocEnt, RTrim(cNumDocSai), .F.)
			EndIf
		EndIf

		If ! cTipo $ "|0|1|"
			Self:addDocsSaida(cNumDocEnt, aRetorno)
		EndIf
	EndIf
Return aRetorno

/*/{Protheus.doc} trataEstoque
Retorna o array com a rastreabilidade das entradas
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 aRetorno  , array   , array a ser atualizado com os registros de baixa de estoque
@param 02 cTipo     , caracter, tipo de baixa a ser tratada (0 = Saldo Inicial, 1 = Entrada Prevista, 3 = Novo Saldo)
@param 03 cFilAux   , caracter, filial do registro
@param 04 cTipDocEnt, caracter, tipo do documento de entrada
@param 05 cNumDocEnt, caracter, n�mero do documento de entrada
@param 06 dData     , date    , data do documento
@param 07 cProduto  , caracter, c�digo do produto
@param 08 cTRT      , caracter, TRT do produto
@param 09 nBaixaEst , num�rico, quantidade da baixa
@param 10 cTipDocSai, caracter, tipo do documento de sa�da
@param 11 cNumDocSai, caracter, n�mero do documento de sa�da
@param 12 cDocPai   , caracter, n�mero do documento pai da HWC
@param 13 nSequen   , num�rico, sequ�ncia do registro da HWC
@param 14 cIdOpc    , caracter, id do Opcional
@return Nil
/*/
METHOD trataEstoque(aRetorno, cTipo, cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aEntradas  := {}
	Local cIdReg     := ""
	Local cLote      := ""
	Local cSubLote   := ""
	Local dDataSaldo := Nil
	Local lNovoSaldo := cTipo == "3"
	Local nDiferen   := 0
	Local nIndex     := 0
	Local nLenEntr   := 0

	Default cIdOpc   := ""

	cIdOpc := AllTrim(cIdOpc)
	cIdReg := cTipo + "_" + cFilAux + cProduto + cIdOpc

	Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)
	aEntradas := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)

	If !Empty(aEntradas)
		aSort(aEntradas, , , {|x,y| Iif(x[ASALDOS_POS_TIPO]=="E", "0", "1") + ;
		                            Iif(x[ASALDOS_POS_TIPO]=="P", "1", "0") + ;
		                            DtoS(x[ASALDOS_POS_DATA]) +;
		                            Iif(x[ASALDOS_POS_TIPO]=="SI", DtoS(x[ASALDOS_POS_VENCIMENTO]), "0") +;
		                            x[ASALDOS_POS_TIPO]       +;
		                            x[ASALDOS_POS_NUM_DOC_ENTRADA] ;
		                           < ;
		                            Iif(y[ASALDOS_POS_TIPO]=="E", "0", "1") + ;
		                            Iif(y[ASALDOS_POS_TIPO]=="P", "1", "0") + ;
		                            DtoS(y[ASALDOS_POS_DATA]) +;
		                            Iif(y[ASALDOS_POS_TIPO]=="SI", DtoS(y[ASALDOS_POS_VENCIMENTO]), "0") +;
		                            y[ASALDOS_POS_TIPO]       +;
		                            y[ASALDOS_POS_NUM_DOC_ENTRADA]})

		nLenEntr := Len(aEntradas)
		nIndex   := 1

		While nIndex <= nLenEntr
			//Verifica se o saldo � posterior � data da baixa
			If aEntradas[nIndex][ASALDOS_POS_DATA] > dData
				nIndex++
				Loop
			EndIf

			//Verifica se o saldo estava v�lido na data da baixa
			If !Empty(aEntradas[nIndex][ASALDOS_POS_VENCIMENTO]) .And. !Self:oDominio:oParametros["lExpiredLot"] .And. aEntradas[nIndex][ASALDOS_POS_VENCIMENTO] < dData
				nIndex++
				Loop
			EndIf

			//Somente utiliza documentos de ponto de pedido se os documentos foram criados em per�odos anteriores.
			If aEntradas[nIndex][ASALDOS_POS_TIPO] == "P" .And. aEntradas[nIndex][ASALDOS_POS_DATA] == dData
				nIndex++
				Loop
			EndIf

			cTipDocEnt := aEntradas[nIndex][ASALDOS_POS_TIPO           ]
			cNumDocEnt := aEntradas[nIndex][ASALDOS_POS_NUM_DOC_ENTRADA]
			dDataSaldo := aEntradas[nIndex][ASALDOS_POS_DATA           ]
			cLote      := aEntradas[nIndex][ASALDOS_POS_LOTE           ]
			cSubLote   := aEntradas[nIndex][ASALDOS_POS_SUBLOTE        ]
			nDiferen   := nBaixaEst - aEntradas[nIndex][ASALDOS_POS_QUANTIDADE]

			If nDiferen == 0
				aDel(aEntradas, nIndex)
				nLenEntr--
				aSize(aEntradas, nLenEntr)

			ElseIf nDiferen < 0
				aEntradas[nIndex][4] -= nBaixaEst

			Else
				nBaixaEst := aEntradas[nIndex][ASALDOS_POS_QUANTIDADE]
				aDel(aEntradas, nIndex)
				nLenEntr--
				nIndex--
				aSize(aEntradas, nLenEntr)
			EndIf

			aAdd(aRetorno, Self:montaRetorno(cFilAux                , ;
			                                 GetTipoEnt(cTipDocEnt) , ;
			                                 cNumDocEnt             , ;
			                                 dDataSaldo             , ;
			                                 cProduto               , ;
			                                 nBaixaEst              , ;
			                                 "2"                    , ;
			                                 cTipDocSai             , ;
			                                 cNumDocSai             , ;
			                                 cTRT                   , ;
			                                 ""                     , ;
			                                 ""                     , ;
			                                 cDocPai                , ;
			                                 cIdOpc                 , ;
			                                 cLote                  , ;
			                                 cSubLote               , ;
											 lNovoSaldo) )

			If nDiferen == 0
				nBaixaEst := 0
				Exit
			ElseIf nDiferen < 0
				nBaixaEst := 0
				Exit
			Else
				nBaixaEst := nDiferen
			EndIf

			nIndex++
		End

		If nLenEntr == 0
			Self:oDados:delItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)
		Else
			Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aEntradas)
		EndIf
	EndIf

	Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)

	aSize(aEntradas, 0)

Return

/*/{Protheus.doc} getQtdEntrada
Retorna qual � a quantidade de entradas que o produto possui.

@author lucas.franca
@since 29/10/2021
@version P12
@param 01 cFilAux , caracter, filial do registro
@param 02 cProduto, caracter, c�digo do produto
@param 03 dData   , date    , data da avalia��o
@param 04 cIdOpc  , caracter, id do opcional
@return nQtdEst, Numeric, Quantidade de saldo em estoque
/*/
METHOD getQtdEntrada(cFilAux, cProduto, dData, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aEntradas  := {}
	Local cIdReg     := "1_" + cFilAux + cProduto + AllTrim(cIdOpc)
	Local nIndex     := 0
	Local nLenEntr   := 0
	Local nQtdEst    := 0

	aEntradas := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)

	If !Empty(aEntradas)

		nLenEntr := Len(aEntradas)
		For nIndex := 1 To nLenEntr

			//Verifica se o saldo � posterior � data da baixa
			If aEntradas[nIndex][ASALDOS_POS_DATA] > dData
				Loop
			EndIf

			//Verifica se o saldo estava v�lido na data da baixa
			If !Empty(aEntradas[nIndex][ASALDOS_POS_VENCIMENTO]) .And. aEntradas[nIndex][ASALDOS_POS_VENCIMENTO] < dData
				Loop
			EndIf

			//Somente utiliza documentos de ponto de pedido se os documentos foram criados em per�odos anteriores.
			If aEntradas[nIndex][ASALDOS_POS_TIPO] == "P" .And. aEntradas[nIndex][ASALDOS_POS_DATA] == dData
				Loop
			EndIf

			nQtdEst += aEntradas[nIndex][ASALDOS_POS_QUANTIDADE]
		Next nIndex

		aSize(aEntradas, 0)
	EndIf

Return nQtdEst

/*/{Protheus.doc} addAglutinado
Grava em uma vari�vel global os documentos origem do documento de aglutina��o
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux , caracter, filial do registro
@param 02 cDocAgl , caracter, n�mero do documento Aglutinado (DEM0000000, EMP0000000, SAI0000000)
@param 03 cTipoOri, caracter, tipo do documento origem
@param 04 cDocOri , caracter, n�mero do documento origem
@param 05 nSeqOri , num�rico, sequ�ncia do documento origem
@param 06 cTRT    , caracter, sequ�ncia do produto na estrutura
@param 07 nNecess , num�rico, necessidade
@param 08 nSubsti , num�rico, quantidade subtitu�da
@return Nil
/*/
METHOD addAglutinado(cFilAux, cDocAgl, cTipoOri, cDocOri, nSeqOri, cTRT, nNecess, nSubsti) CLASS MrpDominio_RastreioEntradas
	Local aAglut := {}
	Local aAux   := {}
	Local cIdReg := ""
	Local lErro  := .F.

	If Self:lAglutinado
		cFilAux := xFilial("SME") //Nesse momento n�o haver� o controle Multi-Filial
		aAux    := Array(AAGLUTINA_SIZE)
		cIdReg  := IND_CHAVE_REG_AGLUTINADO + Trim(cDocAgl)

		aAux[AAGLUTINA_POS_FILIAL         ] := cFilAux
		aAux[AAGLUTINA_POS_TIPO_DOC_ORIGEM] := Trim(cTipoOri)
		aAux[AAGLUTINA_POS_NUM_DOC_ORIGEM ] := cDocOri
		aAux[AAGLUTINA_POS_SEQ_ORIGEM     ] := cValtoChar(nSeqOri)
		aAux[AAGLUTINA_POS_NECESSIDADE    ] := nNecess
		aAux[AAGLUTINA_POS_SUBTITUICAO    ] := nSubsti
		aAux[AAGLUTINA_POS_TRT            ] := cTRT

		Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)

		aAglut := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
		If lErro .Or. Empty(aAglut)
			aAglut := {}
		EndIf

		aAdd(aAglut, aAux)
		Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aAglut)

		Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)
	EndIf

	aSize(aAux  , 0)
	aSize(aAglut, 0)

Return

/*/{Protheus.doc} trataAglutinado
Busca e atualiza o array com os documentos aglutinados (explode a aglutina��o)
@author marcelo.neumann
@since 30/11/2020
@version 1
@param aRegistro, array, registro a ser atualizado
@return Nil
/*/
METHOD trataAglutinado(aRegistro) CLASS MrpDominio_RastreioEntradas
	Local aRegAux := {}

	If Self:lAglutinado .And. !Empty(aRegistro)
		aRegAux   := Self:substituiAglutinados("E", aRegistro, .T.)
		aRegistro := Self:substituiAglutinados("S", aRegAux  , .T.)
	EndIf

Return

/*/{Protheus.doc} substituiAglutinados
Retorna o array com a rastreabilidade das entradas
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cOrigem   , caracter, indica qual o documento ser� subtitu�do/avaliado ("E" Entrada, "S" Sa�da)
@param 02 aAglutinad, array   , registro a ser atualizado
@param 03 lRetOPEmp , l�gico  , indica se ir� retornar a OP do empenho (.T.) ou a sua chave (.F.)
@return   aRetorno  , array   , registro com os o n�mero de documento original
/*/
METHOD substituiAglutinados(cOrigem, aAglutinad, lRetOPEmp) CLASS MrpDominio_RastreioEntradas
	Local aAglut     := {}
	Local aDelAglut  := {}
	Local aRelac     := {}
	Local aRetorno   := {}
	Local cDocAux    := ""
	Local cDocPai    := ""
	Local cFilAux    := ""
	Local cIdOpc     := ""
	Local cIdPai     := ""
	Local cIdRegAg   := ""
	Local cIdRegFi   := ""
	Local cLote      := ""
	Local cNewDoc    := ""
	Local cNumDocEnt := ""
	Local cNumDocSai := ""
	Local cProduto   := ""
	Local cSubLote   := ""
	Local cTipDocEnt := ""
	Local cTipDocSai := ""
	Local cTipo      := ""
	Local cTRT       := ""
	Local dData      := Nil
	Local lNovoSaldo := .F.
	Local nBaixaEst  := 0
	Local nIndex     := 0
	Local nIndHWG    := 0
	Local nLenHWG    := 0
	Local nLenReg    := 0
	Local nNecess    := 0
	Local nQtdComp   := 0
	Local oDocsProc  := JsonObject():New()

	If _nSizeDEnt == Nil
		_nSizeDEnt := GetSx3Cache("ME_NMDCENT","X3_TAMANHO")
	EndIf

	nLenReg := Len(aAglutinad)
	For nIndex := 1 To nLenReg
		cFilAux    := aAglutinad[nIndex][1]
		cTipDocEnt := aAglutinad[nIndex][2]
		cNumDocEnt := aAglutinad[nIndex][3]
		dData      := aAglutinad[nIndex][4]
		cProduto   := aAglutinad[nIndex][5]
		nBaixaEst  := aAglutinad[nIndex][6]
		cTipo      := aAglutinad[nIndex][7]
		cTipDocSai := aAglutinad[nIndex][8]
		cNumDocSai := aAglutinad[nIndex][9]
		cTRT       := aAglutinad[nIndex][10]
		cIdPai     := aAglutinad[nIndex][11]
		cDocPai    := aAglutinad[nIndex][13]
		cIdOpc     := AllTrim(aAglutinad[nIndex][14])
		cLote      := aAglutinad[nIndex][15]
		cSubLote   := aAglutinad[nIndex][16]
		lNovoSaldo := aAglutinad[nIndex][17]
		nNecess    := aAglutinad[nIndex][18]

		If cTipDocSai == STR0144 .And. cOrigem == "E" //"Ponto Ped."
			cIdRegAg := ""
			aAglut   := {}
		Else
			If cOrigem == "E"
				cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(cNumDocEnt)
			Else
				cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(cNumDocSai)
			EndIf
		EndIf

		aAglut := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg)
		If Empty(aAglut)

			Self:carregaDocsSaida(Trim(cNumDocSai))
			If cOrigem == "S" .And. Self:oDocsSaida[Trim(cNumDocSai)] != Nil
				Self:quebraAglutinacaoPai(@aRetorno             ,;
				                          cFilAux               ,;
				                          cProduto              ,;
				                          aAglutinad[nIndex][10],;
				                          nBaixaEst             ,;
				                          nBaixaEst             ,;
				                          cTipDocEnt            ,;
				                          cNumDocEnt            ,;
				                          cTipDocSai            ,;
				                          Trim(cNumDocSai)      ,;
				                          dData                 ,;
				                          cTipo                 ,;
				                          cDocPai               ,;
				                          aAglutinad[nIndex][10],;
				                          @oDocsProc            ,;
				                          ""                    ,;
				                          cIdPai                ,;
				                          cIdOpc                ,;
				                          cLote                 ,;
				                          cSubLote              ,;
				                          lNovoSaldo            ,;
				                          nNecess                )
			Else
				aAdd(aRetorno, Self:montaRetorno(cFilAux   , ;
				                                 cTipDocEnt, ;
				                                 cNumDocEnt, ;
				                                 dData     , ;
				                                 cProduto  , ;
				                                 nBaixaEst , ;
				                                 cTipo     , ;
				                                 cTipDocSai, ;
				                                 cNumDocSai, ;
				                                 cTRT      , ;
				                                 cIdPai    , ;
				                                 ""        , ;
				                                 cDocPai   , ;
				                                 cIdOpc    , ;
				                                 cLote     , ;
				                                 cSubLote  , ;
				                                 lNovoSaldo, ;
				                                 nNecess   ) )
			EndIf
		Else
			nLenHWG := Len(aAglut)
			For nIndHWG := 1 To nLenHWG
				If cOrigem == "E"
					cTipDocEnt := GetTipoEnt(aAglut[nIndHWG][AAGLUTINA_POS_TIPO_DOC_ORIGEM])
					cNumDocEnt := aAglut[nIndHWG][AAGLUTINA_POS_NUM_DOC_ORIGEM]
				Else
					cTipDocSai := aAglut[nIndHWG][AAGLUTINA_POS_TIPO_DOC_ORIGEM]
					cNumDocSai := aAglut[nIndHWG][AAGLUTINA_POS_NUM_DOC_ORIGEM]
				EndIf
				cDocAux := "DOCPAI_" + Trim(cNumDocSai) + aAglut[nIndHWG][AAGLUTINA_POS_SEQ_ORIGEM]
				If (oDocsProc[Trim(cNumDocSai)] != Nil .And. cTipDocSai == STR0144) .Or. ; //Ponto Ped.
				   (oDocsProc[cDocAux] != Nil .And. oDocsProc[cDocAux])
					Loop
				EndIf

				nDiferen := nBaixaEst - aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE]
				nQtdComp := nBaixaEst

				If nDiferen > 0
					nBaixaEst := aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE]
					aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] := 0

				ElseIf nDiferen == 0
					aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] := 0

				Else
					aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] := -nDiferen
				EndIf

				If lRetOPEmp .And. aAglut[nIndHWG][AAGLUTINA_POS_TIPO_DOC_ORIGEM] == "Pr�-OP"
					If cOrigem == "E"
						cNewDoc := Self:getDocEmpenho(cNumDocEnt)[1]
						If PadR(cNewDoc, _nSizeDEnt) <> PadR(cNumDocEnt, _nSizeDEnt)
							cNumDocEnt := cNewDoc
							cTipDocEnt := aAglutinad[nIndex][2]
						EndIf
					Else
						cNumDocSai := Self:getDocEmpenho(cNumDocSai)[1]
					EndIf
				EndIf

				If cOrigem == "S"
					cIdRegFi := IND_CHAVE_AGLUT_DOC_FILHO + aAglut[nIndHWG][AAGLUTINA_POS_SEQ_ORIGEM] + "_" + Trim(cNumDocSai)
					aRelac   := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegFi)

					If !Empty(aRelac)
						cTipDocSai := "OP"
						cNumDocSai := aRelac[1]
					EndIf
				EndIf

				cTRT := aAglut[nIndHWG][AAGLUTINA_POS_TRT]

				Self:carregaDocsSaida(cNumDocSai)
				If cOrigem == "S" .And. Self:oDocsSaida[cNumDocSai] != Nil

					Self:quebraAglutinacaoPai(@aRetorno             ,;
					                          cFilAux               ,;
					                          cProduto              ,;
					                          aAglutinad[nIndex][10],;
					                          nBaixaEst             ,;
					                          nQtdComp              ,;
					                          cTipDocEnt            ,;
					                          cNumDocEnt            ,;
					                          cTipDocSai            ,;
					                          cNumDocSai            ,;
					                          dData                 ,;
					                          cTipo                 ,;
					                          cDocPai               ,;
					                          cTRT                  ,;
					                          @oDocsProc            ,;
					                          aAglut[nIndHWG][AAGLUTINA_POS_SEQ_ORIGEM],;
					                          cIdPai                ,;
					                          cIdOpc                ,;
					                          cLote                 ,;
					                          cSubLote              ,;
					                          lNovoSaldo            ,;
					                          nNecess                )

				Else
					aAdd(aRetorno, Self:montaRetorno(cFilAux   , ;
					                                 cTipDocEnt, ;
					                                 cNumDocEnt, ;
					                                 dData     , ;
					                                 cProduto  , ;
					                                 nBaixaEst , ;
					                                 cTipo     , ;
					                                 cTipDocSai, ;
					                                 cNumDocSai, ;
					                                 cTRT      , ;
					                                 ""        , ;
					                                 ""        , ;
					                                 cDocPai   , ;
					                                 cIdOpc    , ;
					                                 cLote     , ;
					                                 cSubLote  , ;
					                                 lNovoSaldo, ;
					                                 nNecess   ) )
				EndIf

				oDocsProc[Trim(cNumDocSai)] := .T.

				If aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] == 0
					oDocsProc[cDocAux] := .T.
				EndIf

				If aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] == 0 .And. aAglut[nIndHWG][AAGLUTINA_POS_SUBTITUICAO] == 0
					aAdd(aDelAglut, nIndHWG)
				EndIf

				If nDiferen > 0
					nBaixaEst := nDiferen

				ElseIf nDiferen == 0
					nBaixaEst := 0
					Exit

				Else
					nBaixaEst := 0
					Exit
				Endif
			Next nIndHWG

			//Verifica a necessidade de eliminar linhas zeradas
			nLenHWG := Len(aDelAglut)
			If nLenHWG > 0
				For nIndHWG := nLenHWG To 1 Step -1
					aDel(aAglut, aDelAglut[nIndHWG])
				Next nIndHWG
				aSize(aAglut, Len(aAglut)-nLenHWG)
				aSize(aDelAglut, 0)
			EndIf

			Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg, aAglut)

		EndIf

		aSize(aAglutinad[nIndex], 0)
	Next nIndex

	aSize(aAglutinad, 0)
	aSize(aAglut    , 0)
	aSize(aRelac    , 0)
	FreeObj(oDocsProc)
	oDocsProc := Nil
Return aRetorno

/*/{Protheus.doc} quebraAglutinacaoPai
Gera a quebra da aglutina��o do produto pai

@author lucas.franca
@since 26/03/2021
@version P12
@param 01 aRetorno  , Array     , Array para adicionar as informa��es da quebra
@param 02 cFilAux   , Character , Filial para grava��o
@param 03 cProduto  , Character , C�digo do produto
@param 04 cTRT      , Character , Sequ�ncia da estrutura
@param 05 nBaixaEst , Numeric   , Quantidade de baixa
@param 06 nDistrib  , Numeric   , Quantidade total do componente
@param 07 cTipDocEnt, Character , Tipo do documento de entrada
@param 08 cNumDocEnt, Character , N�mero do documento de entrada
@param 09 cTipDocSai, Character , Tipo do documento de sa�da
@param 10 cNumDocSai, Character , N�mero do documento de sa�da
@param 11 dData     , Date      , Data do documento
@param 12 cTipo     , Character , Tipo do documento
@param 13 cDocPai   , Character , Documento pai
@param 14 cTRTAgl   , Character , Sequ�ncia da estrutura da aglutina��o
@param 15 oDocsProc , JsonObject, Objeto para controlar os documentos que j� foram processados.
@param 16 cSeq      , Character , Sequ�ncia do documento pai
@param 17 cIdPai    , Character , Identificador de registro pai
@param 18 cIdOpc    , Character , Id do Opcional
@param 19 cLote     , Character , C�digo do lote
@param 20 cSubLote  , Character , C�digo do sub-lote
@param 21 lNovoSaldo, Logico    , Indica que a saida consumiu uma entrada de novo saldo.
@param 22 nNecess   , Numerico  , Necessidade do documento de sa�da
@return Nil
/*/
METHOD quebraAglutinacaoPai(aRetorno, cFilAux, cProduto, cTRT, nBaixaEst, nDistrib, cTipDocEnt, cNumDocEnt, cTipDocSai, ;
                            cNumDocSai, dData, cTipo, cDocPai, cTRTAgl, oDocsProc, cSeq, cIdPai, cIdOpc, cLote, cSubLote,;
                            lNovoSaldo, nNecess) CLASS MrpDominio_RastreioEntradas
	Local aQtdComp   := {}
	Local cIdPaiQueb := ""
	Local cChavePai  := ""
	Local nIndQuebra := 0
	Local nIndQtd    := 0
	Local nFinish    := 0
	Local nStart     := 0
	Local nStep      := 0
	Local nQtdFilho  := 0
	Local nTotQuebra := Len(Self:oDocsSaida[cNumDocSai])
	Local nTotQtd    := 0

	cIdOpc := AllTrim(cIdOpc)

	If cTipDocEnt == "0"
		nStep   := -1
		nFinish := 1
		nStart  := nTotQuebra
	Else
		nStep   := 1
		nFinish := nTotQuebra
		nStart  := 1
	EndIf

	For nIndQuebra := nStart To nFinish Step nStep
		If oDocsProc[Trim(Self:oDocsSaida[cNumDocSai][nIndQuebra][9])] != Nil .And. ;
		   Self:oDocsSaida[cNumDocSai][nIndQuebra][8] == STR0144 //Ponto Ped.
			Loop
		Else
			oDocsProc[Trim(Self:oDocsSaida[cNumDocSai][nIndQuebra][9])] := .T.
		EndIf

		If cTipDocSai == "OP"
			aQtdComp := Self:buscaQtdComp(cNumDocSai, nIndQuebra, cProduto, cTRT, cFilAux)
		Else
			aQtdComp := {{nBaixaEst, cTRTAgl}}
		EndIf

		If cTipDocSai != "Pr�-OP"
			If Empty(cIdPai)
				cIdPaiQueb := Self:oDocsSaida[cNumDocSai][nIndQuebra][12]
			Else
				cIdPaiQueb := cIdPai
			EndIf
		EndIf

		nTotQtd   := Len(aQtdComp)

		For nIndQtd := 1 To nTotQtd

			cChavePai := cIdPaiQueb + ";" + RTrim(cProduto) + ";" + RTrim(aQtdComp[nIndQtd][2])

			Self:oUsoDoc[cChavePai] := Self:oDados:getItemList(IND_CHAVE_DOCUMENTOS_USO, cChavePai)
			If Self:oUsoDoc[cChavePai] == Nil
				Self:oUsoDoc[cChavePai] := 0
			EndIf

			If aQtdComp[nIndQtd][1] > nDistrib
				nQtdFilho := nDistrib
			Else
				nQtdFilho := aQtdComp[nIndQtd][1]
			EndIf

			If !Empty(cIdPaiQueb) .And. Empty(cIdPai)
				If Self:oUsoDoc[cChavePai] >= aQtdComp[nIndQtd][1] .And. nIndQuebra <> nFinish
					//Atingiu o limite de qtd desse pai. Passa para o pr�ximo.
					Loop
				EndIf
				If Self:oUsoDoc[cChavePai] + nQtdFilho > aQtdComp[nIndQtd][1]
					nQtdFilho := aQtdComp[nIndQtd][1] - Self:oUsoDoc[cChavePai]
				EndIf
			EndIf

			aAdd(aRetorno, Self:montaRetorno(cFilAux             , ;
			                                 cTipDocEnt          , ;
			                                 cNumDocEnt          , ;
			                                 dData               , ;
			                                 cProduto            , ;
			                                 nQtdFilho           , ;
			                                 cTipo               , ;
			                                 cTipDocSai          , ;
			                                 cNumDocSai          , ;
			                                 aQtdComp[nIndQtd][2], ;
			                                 cIdPaiQueb          , ;
			                                 ""                  , ;
			                                 cDocPai             , ;
			                                 cIdOpc              , ;
			                                 cLote               , ;
			                                 cSubLote            , ;
			                                 lNovoSaldo          , ;
			                                 nNecess             ) )

			nDistrib -= nQtdFilho

			If !Empty(cIdPaiQueb) .And. Empty(cIdPai)
				Self:oUsoDoc[cChavePai] += nQtdFilho
			EndIf

			Self:oDados:setItemList(IND_CHAVE_DOCUMENTOS_USO, cChavePai, Self:oUsoDoc[cChavePai])

			If nDistrib <= 0
				Exit
			EndIf
		Next nIndQtd

		aSize(aQtdComp, 0)

		If nDistrib <= 0
			Exit
		EndIf
	Next nIndQuebra
Return

/*/{Protheus.doc} addRelacionamentoDocFilho
Adiciona o DE-PARA entre uma entrada aglutinada e uma sa�da
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cDocAgl  , caracter, documento aglutinado
@param 02 nSequen  , num�rico, sequ�ncia do documento
@param 03 cDocFilho, caracter, documento filho
@return Nil
/*/
METHOD addRelacionamentoDocFilho(cDocAgl, nSequen, cDocFilho) CLASS MrpDominio_RastreioEntradas
	Local aAglut := {}
	Local cIdReg := IND_CHAVE_AGLUT_DOC_FILHO + cValToChar(nSequen) + "_" + Trim(cDocAgl)
	Local lErro  := .F.

	If Self:lAglutinado
		Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)

		aAglut := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
		If lErro .Or. Empty(aAglut)
			aAglut := {}
		EndIf

		aAdd(aAglut, cDocFilho)
		Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aAglut)

		Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)

		aSize(aAglut, 0)
	EndIf

Return

/*/{Protheus.doc} addDocEmpenho
Adiciona o DE-PARA entre o IDREG do empenho e sua OP
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cIdReg    , caracter, identificador do empenho
@param 02 cDocumento, caracter, n�mero da OP
@param 03 cDocOrigem, caracter, n�mero da OP origem do empenho
@param 04 lAddPre   , l�gico  , indica se adiciona o prefixo "Pre_" no n�mero do documento
@return Nil
/*/
METHOD addDocEmpenho(cIdReg, cDocumento, cDocOrigem, lAddPre) CLASS MrpDominio_RastreioEntradas
	Local aDocEmp  := {}
	Local lErro    := .F.

	Default lAddPre := .T.

	If lAddPre
		cDocumento := "Pre_" + cDocumento
		cDocOrigem := "Pre_" + cDocOrigem
	EndIf

	cIdReg := IND_CHAVE_DE_PARA_EMPENHO + Trim(cIdReg)

	Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)

	aDocEmp := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If lErro .Or. Empty(aDocEmp)
		aDocEmp := {}
	EndIf

	aAdd(aDocEmp, {cDocumento, cDocOrigem})
	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aDocEmp)

	Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)

	aSize(aDocEmp, 0)

Return

/*/{Protheus.doc} getDocEmpenho
Recupera o valor da OP correspondente ao empenho
@author marcelo.neumann
@since 30/11/2020
@version 1
@param  cDocum    , caracter, identificador do empenho
@return aDocEmp[1], array   , retorna as OPs relacionadas ao empenho: [1][1] - OP do empenho
                                                                      [1][2] - OP que originou o empenho
/*/
METHOD getDocEmpenho(cDocum) CLASS MrpDominio_RastreioEntradas
	Local aDocEmp  := {}
	Local cIdReg   := IND_CHAVE_DE_PARA_EMPENHO + Trim(cDocum)
	Local lErro    := .F.

	aDocEmp := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If lErro .Or. Empty(aDocEmp)
		Return {cDocum, " "}
	EndIf

Return aDocEmp[1]

/*/{Protheus.doc} buscaDocsAglutinados
Busca os documentos aglutinados de entrada, e qual a quantidade dispon�vel em cada um.

@author lucas.franca
@since 07/01/2021
@version P12
@param 01 aLinha, Array, array com os dados de mem�ria da rastreabilidade.
@param 02 nSequen, Numeric, numero da sequencia do documento gerado.
@return aDocs, Array, Array com os documentos para utiliza��o, e qual a quantidade dispon�vel em cada documento.
/*/
METHOD buscaDocsAglutinados(aLinha, nSequen) CLASS MrpDominio_RastreioEntradas
	Local aDocs      := {}
	Local aNecAgl    := {}
	Local cNumDocEnt := ""
	Local cPrdComOpc := aLinha[Self:nPosProduto] + Iif(!Empty(aLinha[Self:nPosIdOpc]) , "|" + aLinha[Self:nPosIdOpc], "")
	Local nNecess    := aLinha[Self:nPosRastreio][1]
	Local nQtdDisp   := 0
	Local nIndQuebra := 0
	Local nTotQuebra := 0

	aNecAgl := Self:oDominio:oRastreio:retornaRastreio(aLinha[Self:nPosFilial], cPrdComOpc, aLinha[Self:nPosPeriodo], aLinha[Self:nPosRastreio][2], "")
	If !Empty(aNecAgl)
		nTotQuebra := Len(aNecAgl[Self:nPosQuebras])

		For nIndQuebra := 1 To nTotQuebra
			//Verifica se o documento atual possui quantidade dispon�vel
			nQtdDisp := Self:reservaQtdDocEntrada(aLinha, aNecAgl, nIndQuebra, nNecess)
			If nQtdDisp > 0
				//Possui quantidade dispon�vel, verifica qual � o n�mero de documento para gerar rastreabilidade
				If !Empty(aNecAgl[Self:nPosQuebras][nIndQuebra][2])
					cNumDocEnt := aNecAgl[Self:nPosQuebras][nIndQuebra][2]
				Else
					cNumDocEnt := aLinha[Self:nPosRastreio][2] + "_" + cValToChar(nSequen) + "_Filha"
				EndIf
				//Adiciona no array para retornar, n�mero de documento e quantidade
				aAdd(aDocs, {cNumDocEnt, nQtdDisp})
			EndIf
			//Desconta da necessidade total a quantidade j� utilizada.
			nNecess -= nQtdDisp
			If nNecess <= 0
				//Se atendeu toda a necessidade, sai do FOR.
				Exit
			EndIf
		Next nIndQuebra
	EndIf
	aSize(aNecAgl, 0)
Return aDocs

/*/{Protheus.doc} reservaQtdDocEntrada
Reserva quantidade do documento de entrada para uma demanda.

@author lucas.franca
@since 07/01/2021
@version P12
@param 01 aLinha    , Array  , array com os dados de mem�ria da rastreabilidade do registro que est� sendo gerado.
@param 02 aNecAgl   , Array  , array com os dados de mem�ria da rastreabilidade do registro com as necessidades aglutinadas.
@param 03 nIndQuebra, Numeric, �ndice da quebra da necessidade que deve ser avaliado.
@param 04 nQtdNecess, Numeric, Quantidade necess�ria
@return nQuant, Numeric, Quantidade dispon�vel do documento.
/*/
METHOD reservaQtdDocEntrada(aLinha, aNecAgl, nIndQuebra, nQtdNecess) CLASS MrpDominio_RastreioEntradas
	Local cChave    := "RESERVAQTD" + aLinha[Self:nPosRastreio][2] + cValToChar(nIndQuebra)
	Local lError    := .F.
	Local nQuant    := 0
	Local nQtdDisp  := aNecAgl[Self:nPosQuebras][nIndQuebra][1]
	Local nQtdUsada := 0

	//Trava a chave.
	Self:oDados:trava(cChave)

	//Verifica qual a quantidade deste documento j� foi reservada
	nQtdUsada := Self:oDados:getFlag(cChave, @lError, .F.)

	//Se n�o encontrou a flag, toda a quantidade ainda est� dispon�vel.
	If lError
		nQtdUsada := 0
	EndIf

	//Desconta da quantidade dispon�vel a quantidade que j� foi utilizada.
	nQtdDisp -= nQtdUsada

	//Utiliza a quantidade que for necess�ria para atender a necessidade.
	If nQtdNecess >= nQtdDisp
		nQuant := nQtdDisp
	Else
		nQuant := nQtdNecess
	EndIf

	//Atualiza a quantidade j� utilizada
	nQtdUsada += nQuant
	Self:oDados:setFlag(cChave, nQtdUsada, @lError, .F.)

	//Libera o lock
	Self:oDados:destrava(cChave)
Return nQuant

/*/{Protheus.doc} buscaQtdComp
Busca a quantidade utilizada de um componente em rela��o a um produto pai

@author lucas.franca
@since 17/03/2021
@version P12
@param 01 cNumDocSai, Character, Documento de sa�da
@param 02 nIndQuebra, Numeric  , �ndice do array Self:oDocsSaida[cNumDocSai][nIndQuebra] em avalia��o
@param 03 cCompon   , Character, c�digo do componente em an�lise
@param 04 cTRT      , Character, Sequ�ncia do componente
@param 05 cFilAux   , Character, Filial que est� processando.
@return aQtdComp, Array, Array com as quantidades do componente
/*/
METHOD buscaQtdComp(cNumDocSai, nIndQuebra, cCompon, cTRT, cFilAux) CLASS MrpDominio_RastreioEntradas
	Local aRastreio  := {}
	Local aComponent := {}
	Local aQtdComp   := {}
	Local cProdPai   := Self:oDocsSaida[cNumDocSai][nIndQuebra][5]
	Local cDocOri    := Self:oDocsSaida[cNumDocSai][nIndQuebra][13]
	Local cIDOpc     := AllTrim(Self:oDocsSaida[cNumDocSai][nIndQuebra][14])
	Local cRevisao   := ""
	Local lAglutina  := Self:oDominio:oAglutina:avaliaAglutinacao("", cCompon)
	Local nPeriodo   := Self:oDominio:oPeriodos:buscaPeriodoDaData("", Self:oDocsSaida[cNumDocSai][nIndQuebra][4], .F.)

	aRastreio := Self:oDominio:oRastreio:retornaRastreio("", cProdPai + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPeriodo, cDocOri, "")
	cTRT      := Trim(cTRT)

	If !Empty(aRastreio)
		cRevisao := buscaRevisao("", cProdPai, nPeriodo, cDocOri, aRastreio, Self)

		Self:oDominio:oDados:oEstruturas:getRow(1, cProdPai,, @aComponent)

		If !Empty(aComponent)
			aQtdComp := Self:calculaQtdComp(aComponent, cRevisao, cCompon, cTRT, lAglutina, Self:oDocsSaida[cNumDocSai][nIndQuebra], Self:oDocsSaida[cNumDocSai][nIndQuebra][18], cFilAux)

			aSize(aComponent, 0)
		EndIf
		aSize(aRastreio, 0)
	EndIf

Return aQtdComp

/*/{Protheus.doc} calculaQtdComp
Calcula a quantidade utilizada de um componente em rela��o a um produto pai

@author lucas.franca
@since 03/11/2021
@version P12
@param 01 aComponent, Array    , Array com a estrutura do produto
@param 02 cRevisao  , Character, Revis�o do produto
@param 03 cCompon   , Character, c�digo do componente em an�lise
@param 04 cTRT      , Character, Sequ�ncia do componente
@param 05 lAglutina , Logic    , Indica se o produto possui aglutina��o
@param 06 aDocSaida , Array    , Array "Self:oDocsSaida[cNumDocSai][nIndQuebra]" que est� sendo processado
@param 07 nNecPai   , Numeric  , Quantidade do produto pai
@param 08 cFilAux   , Character, Filial que est� processando.
@return aQtdComp, Array, Array com as quantidades do componente
/*/
METHOD calculaQtdComp(aComponent, cRevisao, cCompon, cTRT, lAglutina, aDocSaida, nNecPai, cFilAux) CLASS MrpDominio_RastreioEntradas
	Local aQtdComp := {}
	Local aEstFant := {}
	Local cRevFant := ""
	Local lQtdFixa := .F.
	Local nIndex   := 0
	Local nTotal   := Len(aComponent)
	Local nIndFant := 0
	Local nTotFant := 0
	Local nQtdFant := 0
	Local cCodPai := ""
	Local lError := .F.
	Local nQtdBasePrd := Nil


	For nIndex := 1 To nTotal

		lQtdFixa := IIf(aComponent[nIndex][Self:nPosQtdFix] == '1', .T., .F. )

			cCodPai := aComponent[nIndex][Self:nPosCodPai]
			nQtdBasePrd := ::oDominio:oDados:retornaCampo("PRD", 1, cFilAux + cCodPai, "PRD_QB", @lError, .F., , /*lProximo*/, , , .F. /*lVarios*/)

		If aComponent[nIndex][Self:nPosComp  ] == cCompon  .And. ;
		   aComponent[nIndex][Self:nPosRevIni] <= cRevisao .And. ;
		   aComponent[nIndex][Self:nPosRevFim] >= cRevisao .And. ;
		   (lAglutina .Or. Trim(aComponent[nIndex][Self:nPosTRT]) == cTRT)

			If !Empty(aComponent[nIndex][Self:nPosDatIni]) .Or. !Empty(aComponent[nIndex][Self:nPosDatFim])
				If aComponent[nIndex][Self:nPosDatIni] > aDocSaida[4] .Or. ;
				   aComponent[nIndex][Self:nPosDatFim] < aDocSaida[4]
					Loop
				EndIf
			EndIf



			aAdd(aQtdComp, {Self:oDominio:ajustarNecessidadeExplosao(""                                  , ;
			                                                         cCompon                             , ;
			                                                         nNecPai                             , ;
			                                                         aComponent[nIndex][Self:nPosQtdEst] , ;
			                                                         lQtdFixa                            , ;
			                                                         Nil                                 , ;
			                                                         aComponent[nIndex][Self:nPosPotenc] , ;
			                                                         aComponent[nIndex][Self:nPosPerda]  , ;
			                                                         Iif(nQtdBasePrd != Nil, nQtdBasePrd, aComponent[nIndex][Self:nPosQtdBas])), ;
			                                                         aComponent[nIndex][Self:nPosTRT]})

		ElseIf aComponent[nIndex][Self:nPosFant] == .T.

			Self:oDominio:oDados:oEstruturas:getRow(1, aComponent[nIndex][Self:nPosComp],, @aEstFant)
			If !Empty(aEstFant)
				cRevFant := Self:oDominio:revisaoProduto(aComponent[nIndex][Self:nPosComp])
				nQtdFant := Self:oDominio:ajustarNecessidadeExplosao(""                                  , ;
			                                                         aComponent[nIndex][Self:nPosComp]   , ;
			                                                         nNecPai                             , ;
			                                                         aComponent[nIndex][Self:nPosQtdEst] , ;
			                                                         lQtdFixa                            , ;
			                                                         Nil                                 , ;
			                                                         aComponent[nIndex][Self:nPosPotenc] , ;
			                                                         aComponent[nIndex][Self:nPosPerda]  , ;
			                                                         Iif(nQtdBasePrd != Nil, nQtdBasePrd, aComponent[nIndex][Self:nPosQtdBas]))

				aQtdFant := Self:calculaQtdComp(aEstFant, cRevFant, cCompon, cTRT, lAglutina, aDocSaida, nQtdFant, cFilAux)
				aSize(aEstFant, 0)

				nTotFant := Len(aQtdFant)
				For nIndFant := 1 To nTotFant
					aAdd(aQtdComp, aQtdFant[nIndFant])
				Next nIndFant
				aSize(aQtdFant, 0)

			EndIf
		EndIf
	Next nIndex
Return aQtdComp

/*/{Protheus.doc} addDocsSaida
Adiciona os elementos de retorno no objeto oDocsSaida

@author lucas.franca
@since 29/03/2021
@version P12
@param 01 cNumDocEnt, Character, Documento de entrada
@param 02 aRetorno  , Array    , Array com os dados de retorno
@return Nil
/*/
METHOD addDocsSaida(cNumDocEnt, aRetorno) CLASS MrpDominio_RastreioEntradas
	Local nTotal := 0
	Local nIndex := 0

	If Self:oDocsSaida[cNumDocEnt] == Nil
		Self:oDocsSaida[cNumDocEnt] := aClone(aRetorno)
	Else
		nTotal := Len(aRetorno)
		For nIndex := 1 To nTotal
			aAdd(Self:oDocsSaida[cNumDocEnt], aClone(aRetorno[nIndex]))
		Next nIndex
	EndIf
	//Registra na mem�ria global os dados do documento
	Self:oDados:setItemAList(IND_CHAVE_DOCUMENTOS_SAIDA, cNumDocEnt, Self:oDocsSaida[cNumDocEnt])
Return Nil

/*/{Protheus.doc} carregaDocsSaida
Carrega da mem�ria global informa��es do objeto oDocsSaida

@author lucas.franca
@since 30/11/2022
@version P12
@param 01 cNumDoc, Caracter, N�mero do documento
@return Nil
/*/
METHOD carregaDocsSaida(cNumDoc) CLASS MrpDominio_RastreioEntradas
	Local lError := .F.

	Self:oDocsSaida[cNumDoc] := Self:oDados:getItemAList(IND_CHAVE_DOCUMENTOS_SAIDA, cNumDoc, @lError)
	If lError
		Self:oDocsSaida[cNumDoc] := Nil
	EndIf
Return

/*/{Protheus.doc} addDocHWC
Adiciona um documento proveniente da tabela HWC para processar posteriormente.

@author lucas.franca
@since 23/11/2022
@version P12
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo de entrada (OP, SC, PC)
@param 03 cNumDocEnt, caracter, n�mero do documento referente � entrada
@param 04 nSequen   , num�rico, sequ�ncia do documento
@param 05 dData     , data    , data do documento
@param 06 cProduto  , caracter, c�digo do produto
@param 07 cTRT      , caracter, TRT do produto da sequ�ncia
@param 08 nBaixaEst , num�rico, quantidade baixada do estoque
@param 09 nSubsti   , num�rico, quantidade substitu�da por um alternativo
@param 10 nEmpenho  , num�rico, quantidade empenhada
@param 11 nNecess   , num�rico, necessidade gerada
@param 12 cTipDocSai, caracter, tipo do documento de sa�da
@param 13 cNumDocSai, caracter, n�mero do documento de sa�da
@param 14 cIdOpc    , caracter, id do opcional
@param 15 cList     , caracter, Identificador dos dados da HWC em mem�ria
@param 16 nPosDoc   , numero  , �ndice do array de dados (ordenados) subtra�do das posi��es de lote vencido.
@return Nil
/*/
METHOD addDocHWC(cFilAux   , cTipDocEnt, cNumDocEnt, nSequen , dData  , cProduto  ,;
                 cTRT      , nBaixaEst , nSubsti   , nEmpenho, nNecess, cTipDocSai,;
                 cNumDocSai, cIdOpc    , cList     , nPosDoc ) CLASS MrpDominio_RastreioEntradas

	Local aDados := Array(ADOCHWC_SIZE)
	Local cChave := cFilAux + RTrim(cProduto) + CHR(13) + AllTrim(cIdOpc)

	If !Self:oDocHWC:HasProperty(cChave)
		Self:oDocHWC[cChave] := {}
	EndIf

	aDados[ADOCHWC_FILIAL      ] := cFilAux
	aDados[ADOCHWC_TIPO_DOC_ENT] := cTipDocEnt
	aDados[ADOCHWC_NUM_DOC_ENT ] := cNumDocEnt
	aDados[ADOCHWC_SEQ_QUEBRA  ] := nSequen
	aDados[ADOCHWC_DATA        ] := dData
	aDados[ADOCHWC_PRODUTO     ] := cProduto
	aDados[ADOCHWC_TRT         ] := cTRT
	aDados[ADOCHWC_QTD_BAIXA   ] := nBaixaEst
	aDados[ADOCHWC_QTD_SUBS    ] := nSubsti
	aDados[ADOCHWC_QTD_EMPENHO ] := nEmpenho
	aDados[ADOCHWC_QTD_NECESS  ] := nNecess
	aDados[ADOCHWC_TIPO_DOC_SAI] := cTipDocSai
	aDados[ADOCHWC_NUM_DOC_SAI ] := cNumDocSai
	aDados[ADOCHWC_IDOPC       ] := cIdOpc
	aDados[ADOCHWC_LIST_HWC    ] := cList
	aDados[ADOCHWC_POS_HWC     ] := nPosDoc

	aAdd(Self:oDocHWC[cChave], aDados)
Return Nil

/*/{Protheus.doc} efetivaDocHWC
Salva na vari�vel global os dados mantidos em cache local referente aos documentos da HWC (para a rastreabilidade)

@author marcelo.neumann
@since 29/05/2023
@version P12
@return Nil
/*/
METHOD efetivaDocHWC() CLASS MrpDominio_RastreioEntradas
	Local aNames := Self:oDocHWC:GetNames()
	Local nIndex := 0
	Local nTotal := Len(aNames)

	If !Empty(aNames)
		For nIndex := 1 To nTotal
			Self:oDados:setItemAList(IND_CHAVE_DADOS_HWC, aNames[nIndex], Self:oDocHWC[aNames[nIndex]], .F., .F., .T., 2)
		Next nIndex
	EndIf

	FreeObj(Self:oDocHWC)
	Self:oDocHWC:=JsonObject():New()
	aSize(aNames, 0)
Return Nil

/*/{Protheus.doc} procDocHWC
Processa os documentos da tabela HWC que foram salvos pelo m�todo addDocHWC

@author lucas.franca
@since 23/11/2022
@version P12
@return Nil
/*/
METHOD procDocHWC() CLASS MrpDominio_RastreioEntradas
	Local cErrorUID := Nil
	Local oPCPError := Nil

	If Self:oDominio:oParametros["nThreads"] <= 1
		MrpRasPrc(Self:oDominio:oParametros["ticket"])
	Else
		cErrorUID := Iif(FindFunction("PCPMTERUID"), PCPMTERUID(), "PCPA712_MRP_" + Self:oDominio:oParametros["ticket"])
		oPCPError := PCPMultiThreadError():New(cErrorUID)
		oPCPError:startJob("MrpRasPrc", GetEnvServer(), .F., Nil, Nil, Self:oDominio:oParametros["ticket"])
	EndIf
Return

/*/{Protheus.doc} buscaRevisao
Busca a revis�o do produto

@type  Static Function
@author lucas.franca
@since 17/03/2021
@version P12
@param cFilAux   , Character, Filial em processamento
@param cProduto  , Character, C�digo do produto
@param nPeriodo  , Numeric  , N�mero do per�odo
@param cDocOri   , Character, Documento origem
@param aRastreio , Array    , Array com os dados do rastreio
@param oRastroEnt, Object   , Objeto de refer�ncia da classe de RastreioEntradas
@return cRevisao, Character, Revis�o do produto a ser considerada
/*/
Static Function buscaRevisao(cFilAux, cProduto, nPeriodo, cDocOri, aRastreio, oRastroEnt)
	Local aBaixaPorOP := {}
	Local aRevisoes   := {}
	Local cRevisao    := oRastroEnt:oDominio:revisaoProduto(cFilAux + cProduto)

	aAdd(aBaixaPorOP, oRastroEnt:oDominio:oRastreio:montaBaixaPorOP(cDocOri                            ,;
	                                                                aRastreio[oRastroEnt:nPosDocPai ]  ,;
	                                                                aRastreio[oRastroEnt:nPosNecess ]  ,;
	                                                                aRastreio[oRastroEnt:nPosEst    ]  ,;
	                                                                aRastreio[oRastroEnt:nPosConEst ]  ,;
	                                                                0                                  ,;
	                                                                aRastreio[oRastroEnt:nPosQuebras]  ,;
	                                                                aRastreio[oRastroEnt:nPosTipoPai]  ,;
	                                                                aRastreio[oRastroEnt:nPosNecOri ]  ,;
	                                                                ""                                 ,;
	                                                                ""                                 ,;
	                                                                aRastreio[oRastroEnt:nPosTrfEnt  ] ,;
	                                                                aRastreio[oRastroEnt:nPosTrfSai  ] ,;
	                                                                aRastreio[oRastroEnt:nPosDocFilho] ,;
	                                                                aRastreio[oRastroEnt:nPosRastreio] ))

	aRevisoes := oRastroEnt:oDominio:agrupaRevisoes(cFilAux, cFilAux + cProduto, nPeriodo, @aBaixaPorOP)
	If Len(aRevisoes) > 0
		cRevisao := aRevisoes[1][1]
	EndIf
	aSize(aRevisoes  , 0)
	aSize(aBaixaPorOP, 0)
Return cRevisao

/*/{Protheus.doc} GetTipoEnt
Retorna o Tipo de Documento a ser gravado na SME
@author marcelo.neumann
@since 30/11/2020
@version 1
@param  cTipo     , caracter, tipo do documento de entrada (OP, SC, PC, SI)
                              P = A entrada � um Ponto de Pedido
                              E = A entrada � um estoque de seguran�a
                              0 = A entrada � um Saldo Inicial
                              1 = A entrada � uma OP
                              2 = A entrada � uma SC
                              3 = A entrada � um PC
@return cTipDocEnt, caracter, tipo da entrada (1, 2, 3, 4)
/*/
Static Function GetTipoEnt(cTipo)
	Local cTipDocEnt := ""

	If cTipo == "SI"
		cTipDocEnt := "0"

	ElseIf cTipo == "OP"
		cTipDocEnt := "1"

	ElseIf cTipo == "SC"
		cTipDocEnt := "2"

	ElseIf cTipo == "PC"
		cTipDocEnt := "3"

	ElseIf cTipo == "Pr�-OP"
		cTipDocEnt := "R"

	Else
		cTipDocEnt := cTipo
	EndIf
Return cTipDocEnt

/*/{Protheus.doc} MrpRasPrc
Fun��o para delegar o processamento dos dados de rastreabilidade da HWC.

@type  Function
@author lucas.franca
@since 24/11/2022
@version P12
@param cTicket, Caracter, N�mero do ticket do MRP
@return Nil
/*/
Function MrpRasPrc(cTicket)
	Local aDados     := {}
	Local lError     := .F.
	Local nTotal     := 0
	Local nIndex     := 0
	Local nDelegados := 0
	Local oDados     := Nil
	Local oRastroEnt := Nil
	Local oStatus    := Nil
	Local oLogs      := Nil
	Local oSaida     := MrpDominio_Saida():New()

	PrepStatics(cTicket)

	oDados     := _oDominio:oDados:oRastreioEntradas
	oRastroEnt := _oDominio:oRastreioEntradas
	oStatus    := _oDominio:oLogs:oStatus
	oLogs      := _oDominio:oLogs

	oStatus:preparaAmbiente(_oDominio:oDados)

	oLogs:log("[Rastreabilidade] - Iniciando processamento " + Time(), "32")

	//Aguarda o t�rmino das exporta��es para iniciar o processamento
	oSaida:aguardaRastreio(_oDominio)
	oSaida:aguardaAglutinacao(_oDominio)

	oLogs:log("[Rastreabilidade] - Exportacao de Rastreio (HWC) + Aglutinacao (HWG) finalizados. " + Time(), "32")

	oStatus:setStatus("rastreiaEntradasStatus", "2") //Executando

	//Recupera os dados da mem�ria
	oDados:getAllAList(IND_CHAVE_DADOS_HWC, @aDados, @lError)
	If !lError
		nTotal := Len(aDados)
		oDados:setFlag("ADD_DOCUMENTO_FINALIZADO", 0)

		oLogs:log("[Rastreabilidade] - " + cValToChar(nTotal) + " registros para processar.", "32")

		nIndex := 0
		While nIndex < nTotal .And. oStatus:getStatus("status") <> "4" //Percorre os registros e valida se o processo foi cancelado
			nIndex++

			//Delega o registro para ser processado em oura thread.
			If _oDominio:oParametros["nThreads"] <= 1
				MrpRasAdd(cTicket, aDados[nIndex][2])
			Else
				PCPIPCGO(_oDominio:oParametros["cSemaforoThreads"], .F., "MrpRasAdd", cTicket, aDados[nIndex][2])
			EndIf
			//Limpa array com os dados j� delegados.
			aSize(aDados[nIndex][2], 0)
			aSize(aDados[nIndex]   , 0)

			oRastroEnt:atualizaPercentual(_oDominio, nTotal, 0, 0)

			nDelegados++
		End

		//Aguarda as threads finalizarem
		While oStatus:getStatus("status") != "4" .And. oDados:getFlag("ADD_DOCUMENTO_FINALIZADO") < nDelegados
			oRastroEnt:atualizaPercentual(_oDominio, nTotal, 0, 0)
			Sleep(500)
		End

		//Inicia o processo de grava��o da SME
		If oStatus:getStatus("status") != "4"
			oLogs:log("[Rastreabilidade] - Dados processados. Iniciando gravacao dos dados na SME. " + Time(), "32")
			oSaida:exportarEntradas(_oDominio, nTotal)
			oLogs:log("[Rastreabilidade] - Gravacao dos dados na SME finalizada " + Time(), "32")
		EndIf

	EndIf

	oStatus:setStatus("rastreiaEntradasStatus", "3") //Conclu�do
	oLogs:log("[Rastreabilidade] - Finalizado o processamento " + Time(), "32")

	aSize(aDados, 0)
Return Nil

/*/{Protheus.doc} atualizaPercentual
M�todo para atualizar o percentual de progresso do processo de rastreabilidade

@type  METHOD
@author lucas.franca
@since 28/11/2022
@version P12
@param 01 oStatus , Object , Objeto de status do MRP
@param 02 nTotProc, Numeric, Total de registros para processamento
@param 03 nTotGrav, Numeric, Total de registros para grava��o
@param 04 nIndGrav, Numeric, �ndice de grava��o dos dados
@return Nil
/*/
METHOD atualizaPercentual(oDominio, nTotProc, nTotGrav, nIndGrav) CLASS MrpDominio_RastreioEntradas
	Local nPercent := 0
	Local nInd     := 0

	If nIndGrav > 0
		//Se est� no processo de grava��o, n�o precisa calcular o percentual do processamento pois j� foi finalizado.
		nPercent := 50
	Else
		//Percentual do processamento dos dados, limitado � 50% do total
		nInd := oDominio:oDados:oRastreioEntradas:getFlag("ADD_DOCUMENTO_FINALIZADO")
		If nInd > 0
			nPercent += Round( (nInd / nTotProc) * 50 , 2)
		EndIf
	EndIf

	//Percentual da grava��o dos dados, limitado � 50% do total.
	If nIndGrav > 0
		nPercent += Round( (nIndGrav / nTotGrav) * 50 , 2)
	EndIf
	oDominio:oLogs:oStatus:setStatus("rastreiaEntradasPercentage", nPercent)
Return Nil

/*/{Protheus.doc} MrpRasAdd
Fun��o para realizar o processamento dos dados de rastreabilidade da HWC.

@type  Function
@author lucas.franca
@since 25/11/2022
@version P12
@param 01 cTicket, Caracter, N�mero do ticket do MRP
@param 02 aDados , Array   , Array com os dados para processamento. Array � criado no m�todo addDocHWC
@return Nil
/*/
Function MrpRasAdd(cTicket, aDados)
	Local aDataHWC   := {}
	Local cListAnt   := ""
	Local nPosHWC    := 0
	Local nIndex     := 0
	Local nTotal     := Len(aDados)
	Local oRastroEnt := Nil
	Local oDados     := Nil

	PrepStatics(cTicket)

	oRastroEnt := _oDominio:oRastreioEntradas
	oDados     := _oDominio:oDados:oRastreioEntradas

	//Ordena os dados por per�odo.
	aDados := aSort(aDados,,, {|x,y| DtoS(x[ADOCHWC_DATA]) + "_" + StrZero(x[ADOCHWC_POS_HWC], 10) + StrZero(x[ADOCHWC_SEQ_QUEBRA], 10) <;
	                                 DtoS(y[ADOCHWC_DATA]) + "_" + StrZero(y[ADOCHWC_POS_HWC], 10) + StrZero(y[ADOCHWC_SEQ_QUEBRA], 10)})

	//Percorre os dados da HWC para realizar o processamento do addDocumento.
	For nIndex := 1 To nTotal

		If cListAnt != aDados[nIndex][ADOCHWC_LIST_HWC]
			//Recupera os dados de mem�ria da HWC para utilizar no processo
			FwFreeArray(aDataHWC)
			_oDominio:oRastreio:oDados_Rastreio:oDados:getAllAList(aDados[nIndex][ADOCHWC_LIST_HWC], @aDataHWC)
			aDataHWC := _oDominio:oRastreio:ordenaRastreio(aDataHWC, .F.)
			cListAnt := aDados[nIndex][ADOCHWC_LIST_HWC]
		EndIf
		nPosHWC := aDados[nIndex][ADOCHWC_POS_HWC]

		oRastroEnt:addDocumento(aDados[nIndex][ADOCHWC_FILIAL      ],; //Filial
		                        aDados[nIndex][ADOCHWC_TIPO_DOC_ENT],; //Tipo Documento Entrada
		                        aDados[nIndex][ADOCHWC_NUM_DOC_ENT ],; //N�mero Documento Entrada
		                        aDados[nIndex][ADOCHWC_SEQ_QUEBRA  ],; //Sequ�ncia
		                        aDados[nIndex][ADOCHWC_DATA        ],; //Data
		                        aDados[nIndex][ADOCHWC_PRODUTO     ],; //Produto
		                        aDados[nIndex][ADOCHWC_TRT         ],; //TRT
		                        aDados[nIndex][ADOCHWC_QTD_BAIXA   ],; //Baixa Estoque
		                        aDados[nIndex][ADOCHWC_QTD_SUBS    ],; //Substitui��o
		                        aDados[nIndex][ADOCHWC_QTD_EMPENHO ],; //Empenho
		                        aDados[nIndex][ADOCHWC_QTD_NECESS  ],; //Necessidade
		                        aDados[nIndex][ADOCHWC_TIPO_DOC_SAI],; //Tipo Documento Sa�da
		                        aDados[nIndex][ADOCHWC_NUM_DOC_SAI ],; //N�mero Documento Sa�da
		                        aDataHWC[nPosHWC][2]                ,; //Dados da rastreabilidade
		                        aDados[nIndex][ADOCHWC_IDOPC       ])  //ID Opcional

	Next nIndex

	oRastroEnt:efetivaInclusao()

	//Incrementa contador de delega��es finalizadas
	oDados:setFlag("ADD_DOCUMENTO_FINALIZADO", 1,,,,.T.)

	aSize(aDados, 0)
	FwFreeArray(aDataHWC)
Return Nil

/*/{Protheus.doc} PrepStatics
Alimenta as vari�veis Static do fonte caso ainda n�o tenham sido alimentadas (_oDominio)

@type  Static Function
@author lucas.franca
@since 01/12/2022
@version P12
@param 01 cTicket, Caracter, N�mero do ticket do MRP
@return Nil
/*/
Static Function PrepStatics(cTicket)

	If _oDominio == Nil
		_oDominio := MRPPrepDom(cTicket)
	EndIf

Return

/*/{Protheus.doc} montaRetorno
Monta o array de retorno para exporta��o dos dados.
@author Lucas Fagundes
@since 21/12/2022
@version P12
@param 01 cFilAux   , Caracter, C�digo da Filial
@param 02 cTipDocEnt, Caracter, Tipo Documento Entrada
@param 03 cNumDocEnt, Caracter, N�mero Documento Entrada
@param 04 dData     , Date    , Data
@param 05 cProduto  , Caracter, C�digo do Produto
@param 06 nBaixaEst , Numerico, Quantidade
@param 07 cTipo     , Caracter, Tipo
@param 08 cTipDocSai, Caracter, Tipo Documento Sa�da
@param 09 cNumDocSai, Caracter, N�mero Documento Sa�da
@param 10 cTRT      , Caracter, TRT
@param 11 cIdPai    , Caracter, ID Registro pai
@param 12 cIdReg    , Caracter, IDREG do registro
@param 13 cDocPai   , Caracter, DOCPAI da HWC
@param 14 cIdOpc    , Caracter, Id Opcional
@param 15 cLote     , Caracter, C�digo do Lote
@param 16 cSubLote  , Caracter, C�digo do Sub-lote
@param 17 lNovoSaldo, Caracter, Indica utiliza��o de novo saldo
@param 18 nNecess   , Numerico, Necessidade gerada
@return aRetorno, Array, Array com as informa��es para exporta��o dos dados.
/*/
METHOD montaRetorno(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nBaixaEst, cTipo, cTipDocSai, cNumDocSai,;
                    cTRT, cIdPai, cIdReg, cDocPai, cIdOpc, cLote, cSubLote, lNovoSaldo, nNecess) CLASS MrpDominio_RastreioEntradas
	Local aRetorno := Array(18)
	Default lNovoSaldo := .F.
	Default nNecess    := 0

	aRetorno[01] := cFilAux    //01 Filial
	aRetorno[02] := cTipDocEnt //02 Tipo Documento Entrada
	aRetorno[03] := cNumDocEnt //03 N�mero Documento Entrada
	aRetorno[04] := dData      //04 Data
	aRetorno[05] := cProduto   //05 Produto
	aRetorno[06] := nBaixaEst  //06 Quantidade
	aRetorno[07] := cTipo      //07 Tipo
	aRetorno[08] := cTipDocSai //08 Tipo Documento Sa�da
	aRetorno[09] := cNumDocSai //09 C�digo Documento Sa�da
	aRetorno[10] := cTRT       //10 TRT
	aRetorno[11] := cIdPai     //11 ID Registro pai
	aRetorno[12] := cIdReg     //12 IDREG do registro
	aRetorno[13] := cDocPai    //13 DOCPAI da HWC
	aRetorno[14] := cIdOpc     //14 Id Opcional
	aRetorno[15] := cLote      //15 Lote
	aRetorno[16] := cSubLote   //16 Sub-lote
	aRetorno[17] := lNovoSaldo //17 Novo Saldo
	aRetorno[18] := nNecess    //18 Necessidade

Return aRetorno

/*/{Protheus.doc} criaIdReg
Cria o idreg do registro para a tabela SME.
@author Lucas Fagundes
@since 02/03/2023
@version P12
@param 01 cDocEnt   , Caracter, Documento de entrada da saida que ir� criar o idreg.
@param 02 lConcatPai, Logico  , Indica que deve concatenar o idreg do documento recebido em cDocEnt.
@return cIdReg, Caracter, Idreg para o registro na SME.
/*/
METHOD criaIdReg(cDocEnt, lConcatPai) CLASS MrpDominio_RastreioEntradas
	Local cIdReg := ""
	Local nInc   := 1
	Local cIdRegPai := ""
	Local cChave := "IDREG_SME_DOC_" + cDocEnt

	Self:oDados:setFlag("IDREG_SME", @nInc,,,, .T.)
	cIdReg := cValToChar(nInc)

	cIdRegPai := Self:oDados:getFlag(cChave)
	If Empty(cIdRegPai)
		Self:oDados:setFlag(cChave, cIdReg)
	EndIf

	If lConcatPai .And. !Empty(cIdRegPai)
		cIdReg := cIdReg + "|" + cIdRegPai + "|"
	EndIf

Return cIdReg
