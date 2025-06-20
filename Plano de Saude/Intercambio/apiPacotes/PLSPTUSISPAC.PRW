#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} PlsPtuSisPac From PlsRest
    Classe que define client para consumo da API REST do Sistema de Pacotes (SISPAC) da Unimed Brasil
        de acordo com Protocolo de Transa��es Unimed - PTU Vers�o 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class PlsPtuSisPac From PlsRest

    // Atributos para Autoriza��o    
    Data cSessionToken  As String               // sessionToken  | Token para acesso, |  AN | 40 | M | Nota: Para obter o token da aplica��o desejada � necess�rio solicitar via
                                                //               | fornecido pela     |     |    |   | sistema de demandas � Unimed do Brasil
                                                //               | Unimed Brasil      |     |    |   | 
    Data cUserName      As String               // username      | Nome do Usu�rio no |  AN | 100| M | Nota: Usu�rio de acesso � �rea restrita do Portal Unimed com o respectivo 
                                                //               | Portal Unimed      |     |    |   | perfil associado � aplica��o requerida
    Data cPassword      As String               // password      | Senha do Usu�rio   |  AN |  V | M | Nota: Senha de acesso � �rea restrita do Portal Unimed
                                                //               | no Portal Unimed   |     |    |   | Tamanho m�ximo de 20 caracteres
    Data cUnimed        As String               // unimed        | C�digo da Unimed   |  N  | 04 | M | Codifica��o: C�digo do Sistema + Cooperativa
                                                //               | do Usu�rio         |     |    |   | Ver abaixo:
    Data cBearer        As String

    Data cPathSisPac    As String

    // Estrutura para Requisi��o de Pacotes (Objeto da Classe SisPacReq)
    Data oSisPacReq

    // Estrutura de Retorno (Objeto da Classe SisPacRet)
    Data oSisPacRet

    // Para testes autom�ticos
    Data lAutoma        As Boolean

    Method New(cCodOpe)
    Method loadAccess()
    Method resetReq()
    Method requestAut()
    Method setAutoma(lAuto)
    Method setTextResp(cText)
    Method setRespJson(cJson)
    Method setBearer()
    Method setSPReq(oSisPacReq)
    Method setSPRet(oSisPacRet)
    Method reqConsPac()
    Method consultapacote(cCodOpe, cCodPac, cCdItem, cTpAcom, cStPaco, cCdEspe, cTpPaco,;
                      cDtRefe, cCdPres, cCpfCnp, nOffset, nLimite)
 
EndClass

/*/{Protheus.doc} New
    Construtor da Classe Principal PlsPtuSisPac
    
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(cCodOpe) Class PlsPtuSisPac

    _Super:new()
    If Empty(cCodOpe)
        cCodOpe     := PlsIntPad()
    EndIf
    self:cCodOpe    := cCodOpe
    self:nMaxTry    := 0
    self:lAutoma     := .F.
    self:loadAccess()
    self:oSisPacReq := {}
    self:oSisPacRet := {}

Return

/*/{Protheus.doc} loadAccess
    Carrega dados de acesso
    
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method loadAccess() Class PlsPtuSisPac

    BA0->(DbSetOrder(1)) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    if !Empty(self:cCodOpe) .And. BA0->(DbSeek(xFilial('BA0')+self:cCodOpe))

        self:cUnimed := BA0->(BA0_CODIDE+BA0_CODINT)
        self:cEndPoint := Alltrim(BA0->BA0_URLPAC)    
        self:cSessionToken := Alltrim(BA0->BA0_STKPAC)    
        self:cUserName := Alltrim(BA0->BA0_USRPAC)    
        self:cPassword := Alltrim(BA0->BA0_PWDPAC)    
        self:cBearer := Alltrim(BA0->BA0_TOKPAC) 
        self:cPathSisPac := ""

        If BA0->(FieldPos("BA0_PTHPAC")) > 0
            self:cPathSisPac := Alltrim(BA0->BA0_PTHPAC)
        EndIf   

    endIf

Return

/*/{Protheus.doc} resetReq
    Reinicializa dados da Requisi��o
    
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method resetReq() Class PlsPtuSisPac

    self:aHeadParam := {}
    self:aQryParam  := {}
    self:nMaxTry    := 0
    self:lSucess    := .F.
    self:cJson      := ''
    self:cPath      := ''
    self:cError     := ''
    self:lGeraLog   := .F.
    self:cNameLog   := ''
    self:cRespType  := 'json'
    If !self:lAutoma
        self:cRespJson  := ''
        self:cTextResp  := ''
    EndIf
    //self:oSisPacReq := {}
    self:oSisPacRet := {}

Return

/*/{Protheus.doc} requestAut
    Faz requisi��o do Bearer o qual � utilizado como autoriza��o para futura requisi��o de Pacotes.
    
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method requestAut() Class PlsPtuSisPac

    Local aRet := {.T.,""}

    self:resetReq()

    self:impLog(Replicate('-',50),.F.)
    self:impLog('Iniciando processo para solicitar Bearer')

    If Empty(Alltrim(self:cSessionToken)) .Or. Empty(Alltrim(self:cUserName)) .Or. ;
       Empty(Alltrim(self:cPassword)) .Or. Empty(Alltrim(self:cUnimed))
        aRet[1] := .F.
        aRet[2] := "Configura��es de Acesso n�o cadastradas na Operadora "+self:cCodOpe+"."
    Else
        self:setPath('/idp/portal/' + self:cSessionToken)

        self:aHeadParam := {}

        //Monta QryParam
        self:aQryParam  := {}
        self:setQryPar('username'    ,self:cUserName)
        self:setQryPar('password'    ,self:cPassword)
        self:setQryPar('unimed'      ,self:cUnimed)

        self:setRespType('text')

        if self:lAutoma
            self:lSucess   := .T.
        else
            // Faz requisi��o
            self:comunPost()
        endIf

        If self:lSucess
            self:setBearer()
        EndIf
    EndIf

Return aRet

Method setAutoma(lAuto) Class PlsPtuSisPac
    self:lAutoma := lAuto
Return

Method setBearer() Class PlsPtuSisPac
    self:cBearer := self:cTextResp
    self:cBearer := strtran(self:cBearer,'"','')
    BA0->(DbSetOrder(1)) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    If !Empty(self:cCodOpe) .And. !Empty(self:cBearer) .And. BA0->(DbSeek(xFilial('BA0')+self:cCodOpe))
        BA0->(RecLock("BA0",.F.))
        BA0->BA0_TOKPAC := self:cBearer     // At� 999 caracteres
        BA0->(MsUnLock())
    EndIf
Return

Method setSPReq(oSisPacReq) Class PlsPtuSisPac
    self:oSisPacReq := oSisPacReq
Return

Method setSPRet(oSisPacRet) Class PlsPtuSisPac
    self:oSisPacRet := oSisPacRet
Return

Method setTextResp(cText) Class PlsPtuSisPac
    self:cTextResp := cText
Return

Method setRespJson(cJson) Class PlsPtuSisPac
    self:cRespJson := cJson
Return

/*/{Protheus.doc} reqConsPac
    Faz consulta de pacotes de acordo com os dados da requisi��o.
    
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method reqConsPac() Class PlsPtuSisPac

    Local oRequest  := nil
    Local oResponse := nil

    self:resetReq()

    self:impLog(Replicate('-',50),.F.)
    self:impLog('Iniciando processo de Requisicao dos Pacotes')

    If !Empty(Self:cPathSisPac)
        self:setPath(Lower(Self:cPathSisPac))
    Else
        self:setPath('/dominios-pacote/v1/consultapacotes')
    EndIf

    //Monta header
    self:aHeadParam := {}
    self:setHeadPar('accept','*/*')
    self:setHeadPar('content-type','application/json')
    If !Empty(Alltrim(self:cBearer))
        self:setHeadPar('Authorization',self:cBearer)
    EndIf

    //Monta QryParam
    self:aQryParam  := {}

    oRequest := JsonObject():new()
    oRequest['cd_uni_ori'] := self:oSisPacReq:cCdUniOri
    If !Empty(self:oSisPacReq:cCdPacote)
        oRequest['cd_pacote'] := self:oSisPacReq:cCdPacote
    EndIf
    If !Empty(self:oSisPacReq:cCdItem)
        oRequest['cd_item'] := self:oSisPacReq:cCdItem
    EndIf
    If !Empty(self:oSisPacReq:cTpAcomodacao)
        oRequest['tp_acomodacao'] := self:oSisPacReq:cTpAcomodacao
    EndIf
    If !Empty(self:oSisPacReq:cStPacote)
        oRequest['st_pacote'] := self:oSisPacReq:cStPacote
    EndIf
    If !Empty(self:oSisPacReq:cCdEspec)
        oRequest['cd_espec'] := self:oSisPacReq:cCdEspec
    EndIf
    If !Empty(self:oSisPacReq:cTpPacote)
        oRequest['tp_pacote'] := self:oSisPacReq:cTpPacote
    EndIf
    If !Empty(self:oSisPacReq:cDtReferencia)
        oRequest['dt_referencia'] := self:oSisPacReq:cDtReferencia
    EndIf
    If !Empty(self:oSisPacReq:cCdPrest)
        oRequest['cd_prest'] := self:oSisPacReq:cCdPrest
    EndIf
    If !Empty(self:oSisPacReq:cCdCpfCnpj)
        oRequest['cd_cpf_cnpj'] := self:oSisPacReq:cCdCpfCnpj
    EndIf
    If !Empty(self:oSisPacReq:nOffset)
        oRequest['offset'] := self:oSisPacReq:nOffset
    EndIf
    If !Empty(self:oSisPacReq:nLimit)
        oRequest['limit'] := self:oSisPacReq:nLimit
    EndIf

    //Monta JSON request params
    self:setJson(FWJsonSerialize(oRequest, .F.,.F.))
    self:setRespType('json')

    // S� faz requisi��o se n�o for teste autom�tico
    if self:lAutoma    
        self:lSucess := .T.
    else
        // Faz requisi��o
        self:comunPost()
    endIf

    if self:lSucess
        oResponse := JsonObject():New()
        oResponse:fromJSON(self:cRespJson)
        oSisPacRet := SisPacRet():New(oResponse)
        self:setSPRet(oSisPacRet)
    endIf

Return

/*/{Protheus.doc} consultapacote
    M�todo p�blico para acesso � API REST do Sistema de Pacotes (SISPAC) da Unimed Brasil
        de acordo com Protocolo de Transa��es Unimed - PTU Vers�o 1.0 MS.104 Rev.01:
        Faz consulta de pacotes de acordo com os par�metros de entrada e retorna pacotes em forma de array.
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    @params cCodOpe, string, unimed de origem dos pacotes, obrigat�rio
        cCodPac, string, c�digo do pacote a ser pesquisado, opcional
        cCdItem, string, c�digo do item principal do pacote, opcional
        cTpAcom, string, c�digo do tipo de acomoda��o do pacote, opcional
        cStPaco, string, c�digo do status do pacote, opcional
        cCdEspe, string, c�digo da especialidade do pacote, opcional
        cTpPaco, string, c�digo do tipo do pacote, opcional
        cDtRefe, string formato yyyy-mm-dd, data de refer�ncia para consulta do pacote, opcional
        cCdPres, string, c�digo do prestador do pacote, opcional
        cCpfCnp, string, cpf ou cnpj do prestador, opcional
        nOffset, number, deslocamento da pesquisa, opcional
        nlimite, number, limite de pacotes a serem retornados, opcional
    @return aRet, array, array contendo status da requisi��o, pacotes requisitados e suas composi��es:
        aRet[1] = Status da Requisi��o (.T. = Sucesso, .F. = Falhou)
        aRet[2] = Mensagem de erro caso requisi��o tenha falhado.
        aRet[3] = C�d. Status da execu��o da Requisi��o (1 a 14)
        aRet[4] = Desc. Status da execu��o da Requisi��o
        aRet[5] = Total de Pacotes Existentes no Sistema de acordo com os par�metros de entrada
        aRet[6] = Deslocamento/p�gina retornada
        aRet[7] = Limite de Pacotes retornados na requisi��o (p�gina)
        aRet[8] = Pacotes
        aRet[8][i][1] = c�d. unimed origem
        aRet[8][i][2] = nome unimed origem
        aRet[8][i][3] = prestadores
        aRet[8][i][3][j][1] = nome prestador
        aRet[8][i][3][j][2] = c�d. prestador
        aRet[8][i][3][j][3] = cpf ou cnpj prestador
        aRet[8][i][4] = c�d. item
        aRet[8][i][5] = desc. item
        aRet[8][i][6] = qtd. servico
        aRet[8][i][7] = vl. servico
        aRet[8][i][8] = vl. total
        aRet[8][i][9] = c�d. pacote
        aRet[8][i][10] = status pacote
        aRet[8][i][11] = tipo acomodacao
        aRet[8][i][12] = tipo pacote
        aRet[8][i][13] = c�d. especialidade
        aRet[8][i][14] = tipo internacao
        aRet[8][i][15] = dt. negocia. pacote
        aRet[8][i][16] = Honor. incluso
        aRet[8][i][17] = Anestesia incluso
        aRet[8][i][18] = Auxiliar incluso
        aRet[8][i][19] = tipo rede
        aRet[8][i][20] = opme incluso
        aRet[8][i][21] = dt. inicio vigencia
        aRet[8][i][22] = dt. fim vigencia
        aRet[8][i][23] = dt. publicacao
        aRet[8][i][24] = dt. aprov. reprov.
        aRet[8][i][25] = valor pacote
        aRet[8][i][26] = versao pacote
        aRet[8][i][27] = itens alternativos
        aRet[8][i][27][j][1] = c�d. item
        aRet[8][i][27][j][2] = descri��o item
        aRet[8][i][27][j][3] = qtd. servi�o
        aRet[8][i][27][j][4] = c�d. unidade medida
        aRet[8][i][27][j][4] = desc. unidade medida
        aRet[8][i][28] = detalhes
        aRet[8][i][28][j][1] = c�d. tipo composicao
        aRet[8][i][28][j][2] = tipo tabela
        aRet[8][i][28][j][3] = c�d. item
        aRet[8][i][28][j][4] = desc. item
        aRet[8][i][28][j][5] = qtd. servi�o
        aRet[8][i][28][j][6] = valor servi�o
        aRet[8][i][28][j][7] = valor total
        aRet[8][i][28][j][8] = c�d. unidade medida
        aRet[8][i][28][j][9] = desc. unidade medida
        aRet[8][i][29] = valor dos itens de Material que compoe o pacote
        aRet[8][i][30] = valor dos itens de Medicamento que compoe o pacote
        aRet[8][i][31] = valor dos itens de OPME que compoe o pacote
        aRet[8][i][32] = valor dos itens de Taxas e Gases que compoe o pacote
        aRet[8][i][33] = valor dos itens de Procedimentos que compoe o pacote
        aRet[8][i][34] = valor dos itens de Diarias que compoe o pacote
    @example

        User Function PLSUBCNPC()
        Local aRet := {}
        Local oRestClient   := {}

        Local cCodOpe := "0055"
        Local cUniOri := "0002"
        Local cCodPac := "98000550"

        oRestClient := PLSPTUSISPAC():New(cCodOpe)

        // Retorna todos os pacotes da unimed 0002
        aRet := oRestClient:consultapacote(cUniOri)
        // Retorna apenas o pacote 98000550 da unimed 0002
        aRet := oRestClient:consultapacote(cUniOri, cCodPac)

        cUniOri := "0055"
        cCodPac := "70001030"
        // Retorna todos os pacotes da unimed 0055
        aRet := oRestClient:consultapacote(cUniOri)
        // Retorna apenas o pacote 70001030 da unimed 0055
        aRet := oRestClient:consultapacote(cUniOri, cCodPac)
        Return
    
        Problemas conhecidos:
            1 - Quando utilizados juntos os par�metros de entrada cCdItem e cCdPres/cCpfCnp
                a API REST sempre retorna status de execu��o 2: "Erro: Erro de processamento."
    /*/
Method consultapacote(cCodOpe, cCodPac, cCdItem, cTpAcom, cStPaco, cCdEspe, cTpPaco,;
                      cDtRefe, cCdPres, cCpfCnp, nOffset, nLimite) Class PlsPtuSisPac

    Local oSisPacReq := {}
    Local aPacotes   := {}
    Local nTotal     := 0
    Local nIdStats   := 0
    Local cDsStats   := ""
    Local nLimit     := 0
    Local nOffSetP   := 0
    Local aRet       := {.T.,""}

    Default cCodOpe := PlsIntPad()
    Default cCodPac := ""
    Default cCdItem := ""
    Default cTpAcom := ""
    Default cStPaco := ""
    Default cCdEspe := ""
    Default cTpPaco := ""
    Default cDtRefe := ""
    Default cCdPres := ""
    Default cCpfCnp := ""
    Default nOffset := ""
    Default nLimite := ""

    self:impLog(Replicate('-',50),.F.)
    self:impLog('Iniciando processo para solicitar Pacotes')

    oSisPacReq := SisPacReq():New(cCodOpe)
    
    If !Empty(cCodPac)
        oSisPacReq:setCodPac(cCodPac)
    EndIf
    If !Empty(cCdItem)
        oSisPacReq:setCdItem(cCdItem)
    EndIf
    If !Empty(cTpAcom)
        oSisPacReq:setTpAcom(cTpAcom)
    EndIf
    If !Empty(cStPaco)
        oSisPacReq:setStPaco(cStPaco)
    EndIf
    If !Empty(cCdEspe)
        oSisPacReq:setCdEspe(cCdEspe)
    EndIf
    If !Empty(cTpPaco)
        oSisPacReq:setTpPaco(cTpPaco)
    EndIf
    If !Empty(cDtRefe)
        oSisPacReq:setDtRefe(cDtRefe)
    EndIf
    If !Empty(cCdPres)
        oSisPacReq:setCdPres(cCdPres)
    EndIf
    If !Empty(cCpfCnp)
        oSisPacReq:setCpfCnp(cCpfCnp)
    EndIf
    If !Empty(nOffset)
        oSisPacReq:setOffset(nOffset)
    EndIf
    If !Empty(nLimite)
        oSisPacReq:setLimite(nLimite)
    EndIf

    self:setSPReq(oSisPacReq)
    self:reqConsPac()
    If !self:lSucess
        aRet := self:requestAut()
        If self:lSucess .And. aRet[1]
            self:reqConsPac()
        ElseIf !aRet[1]
            self:cError := aRet[2]
        EndIf
    Endif

    If self:lSucess
        nTotal   := self:oSisPacRet:nTotal
        aPacotes := self:oSisPacRet:aPacotes
        nIdStats := self:oSisPacRet:nIdStatusExecucao
        cDsStats := self:oSisPacRet:cDsStatusExecucao
        nOffSetP := self:oSisPacRet:nOffset
        nLimit   := self:oSisPacRet:nLimit
    EndIf

Return {self:lSucess, self:cError, nIdStats, cDsStats, nTotal, nOffSetP, nLimit, aPacotes}
