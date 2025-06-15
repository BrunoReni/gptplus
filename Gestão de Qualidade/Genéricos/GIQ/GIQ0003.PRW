#INCLUDE "TOTVS.CH"
#INCLUDE "FwSchedule.ch"
#INCLUDE "GIQ0003.CH"

#DEFINE ENTER CHR(13) + CHR(10)

#DEFINE nThreadsDEF 16

#DEFINE nMV_CLIENTI 1
#DEFINE nMV_SECRETI 2
#DEFINE nMV_RACGIQ  3
#DEFINE nMV_URLGIQ  4

#DEFINE nMarcado         1
#DEFINE nGrupoDeEmpresa  2
#DEFINE nFilialComposta  3
#DEFINE nDescricaoFilial 4

/*/{Protheus.doc} GIQ0003
Programa para implantar a integração ERP x GIQ.

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
/*/
Main Function GIQ0003()
    Local oImplantador := GIQ0003Class():New()
    oImplantador:MontaWizard()
Return

/*/{Protheus.doc} GIQ0003Class
Regras de Negocio - Wizard de Implantação Integração GIQ x Protheus
@author    brunno.costa / renan.roeder
@since     15/09/2021
/*/
CLASS GIQ0003Class FROM LongClassName

    DATA aEmpresas
    DATA aParametros
    DATA cUsuario
    DATA cGlobalKey
    DATA cSenha
    DATA nEmpresaMarcada
    DATA oCompartilhamentos

	METHOD new(cUsuario, cSenha, aEmpresas, nEmpresaMarcada, cGlobalKey) CONSTRUCTOR

    //METODOS MONTAGEM DO WIZARD
    METHOD MontaWizard()
    METHOD Etapa1(oPanel)
    METHOD Etapa2(oPanel, aSM0)
    METHOD Etapa3(oPanel)
    METHOD Etapa4(oPanel, oStatus)

    //METODO EXECUCAO IMPLANTACAO
    METHOD ExecutaImplantacao(oStatus, aSM0)

    //DEMAIS METODOS AUXILIARES
    METHOD AbreAmbiente(cCompany, cBranch)
    METHOD BuscaProdutosTotalIntegracao()
    METHOD BuscaFornecedoresTotalIntegracao()
    METHOD CarregaEmpresas(aSM0)
    METHOD ChecaPendencias(cFilAux)
    METHOD ChecaAcessoUsuarioAsEmpresasMarcadas()
    METHOD CriaProdutoJson(cAliasTop, oProduto)
    METHOD CriaFornecedorJson(cAliasTop)
    METHOD CriaSchedule()
    METHOD EnviaProdutos()
    METHOD EnviaFornecedores()
    METHOD HabilitaIntegracaoFilial(cFilAux)
    METHOD MarcaFilial(oList)
    METHOD RetornaParametrosDeAcesso()
    METHOD SalvaParametrosAcessoAPlataforma()
    METHOD SalvaX6(aSX6)
    METHOD ValidaDicionarioGIQ()
    METHOD ValidaIntegracaoCompartilhadaAnteriormente()
    METHOD ValidaUsuario()
    METHOD ValidaSelecaoEmpresa()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author    brunno.costa / renan.roeder
@since     15/09/2021

@param 01 - cUsuario        , caracter, usuário digitado pelo usuário na Etapa2
@param 02 - cSenha          , caracter, senha digitada pelo usuário na Etapa2
@param 03 - aEmpresas       , array   , array self:aEmpresas gerado anteriormente no self:CarregaEmpresas()
@param 04 - nEmpresaMarcada , número  , número identificador da primeira empresa aberta válida para o usuário e senha
@param 05 - cGlobalKey      , caracter, nome da sessão de variáveis globais
@return Self, objeto, instancia da Classe GIQ0003Class
/*/
METHOD new(cUsuario, cSenha, aEmpresas, nEmpresaMarcada, cGlobalKey) CLASS GIQ0003Class
    Default cUsuario          := Space(35)
    Default cSenha            := Space(35)
    Default aEmpresas         := {}
    Default nEmpresaMarcada   := 0
    Default cGlobalKey        := CValToChar(ThreadID()) + '_GIQ0003'

    self:oCompartilhamentos        := JsonObject():New()
    self:oCompartilhamentos['SB1'] := JsonObject():New()
    self:oCompartilhamentos['SA2'] := JsonObject():New()
    self:cUsuario         := cUsuario
    self:cSenha           := cSenha
    self:aEmpresas        := aEmpresas
    self:nEmpresaMarcada  := nEmpresaMarcada
    self:aParametros      := Array(4)
    self:cGlobalKey       := cGlobalKey
Return Self

/*/{Protheus.doc} MontaWizard
Monta Estrutura do Wizard de Implantação

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
/*/
METHOD MontaWizard() CLASS GIQ0003Class
    Local aSM0       := {}
    Local lRet       := .T.
    Local oStepWiz 
    Local oNewPag
    Local oStatus

    oStepWiz:= FWWizardControl():New(, { 530, 720 })
    oStepWiz:ActiveUISteps()
    
    // Pagina 1 - Boas Vindas
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0001) //"Boas Vindas"
    oNewPag:SetConstruction({ |oPanel| self:Etapa1(oPanel) })
    oNewPag:SetNextAction({|| .T.})
    
    // Pagina 2 - Autenticação e Seleção de Filiais
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0002) //"Autenticação"
    oNewPag:SetConstruction({|oPanel| self:Etapa2(oPanel, @aSM0) })    
    oNewPag:SetNextAction({|| FWMsgRun(/*oComponent*/,{ || lRet := self:ValidaUsuario() }, Nil, STR0003), lRet }) //"Validando os acessos do administrador"
    
    // Pagina 3 - Parametros de Integração 
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0004) //"Parâmetros Integração"
    oNewPag:SetConstruction({|oPanel| oPanelAux := oPanel, FWMsgRun(/*oComponent*/,{ || self:Etapa3(oPanelAux) }, Nil, STR0005) }) //"Carregando parâmetros de acesso da filial"

    // Pagina 4 - Execução Carga Inicial
    oNewPag := oStepWiz:AddStep()
    oNewPag:SetStepDescription(STR0006) //"Execução Carga Inicial"
    oNewPag:SetConstruction({|oPanel| ;
                            self:Etapa4(oPanel, @oStatus), ;
                            self:ExecutaImplantacao(oStatus, aSM0) })
    oNewPag:SetNextAction({|| .T.})
    oNewPag:SetPrevWhen({|| .F. })
    oNewPag:SetCancelWhen({|| .F. })
    oStepWiz:Activate()

    ClearGlbValue("IntegraGIQ_aHeadOut")
    GIQIPCFinish(self:cGlobalKey, 100, nThreadsDEF)

    FWFreeArray(self:aEmpresas)
    FWFreeArray(aSM0)
    FWFreeArray(self:aParametros)

    FreeObj(self:oCompartilhamentos['SB1'])
    FreeObj(self:oCompartilhamentos['SA2'])
    self:oCompartilhamentos['SB1'] := Nil
    self:oCompartilhamentos['SA2'] := Nil

    FreeObj(self:oCompartilhamentos)
    self:oCompartilhamentos        := Nil
Return

/*/{Protheus.doc} Etapa1
Monta Etapa 1 do Wizard - Boas Vindas

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - oPanel, objeto, painel para exibição da etapa
/*/
METHOD Etapa1(oPanel) CLASS GIQ0003Class

    Local oSay1
    Local oSay2
    Local oSay3
    Local oSay4
    Local oSay5
    Local oSay6
    Local oSay7
    Local cWelcome1 := STR0007 //"Bem vindo(a)!"
    Local cWelcome2 := STR0008 //"Este é o procedimento de instalação da solução TOTVS para Inspeções da Qualidade."
    Local cWelcome3 := STR0060 //"Ao executar o processo a seguir, a integração ERP x GIQ será ativada para a filial selecionada através do parametro MV_INTGIQE."
    Local cWelcome4 := STR0061 //"Os parâmetros MV_CLIENTI, MV_SECRETI e MV_URLGIQ, que o ERP utiliza para integrar os dados da filial ao GIQ também serão atualizados no configurador."
    Local cWelcome5 := STR0062 //"Será realizada uma carga inicial dos produtos da filial selecionada que estão com o parâmetro Tipo de C.Q. igual a SIGAQuality, e seus respectivos fornecedores."
    Local cWelcome6 := STR0063 //"Será criado um agendamento de tarefa no schedule do Protheus que será utilizado para realizar tentativas de reprocessamento automático das mensagens de integração que não tiveram sucesso na execução."
    Local cWelcome7 := STR0009 //"Para continuar pressione o botão 'Avançar' ou 'Cancelar' para abortar o processo."
    
    oCMFont := TFont():New('Arial',,-14,.T.)

    oSay1   := TSay():New(10 , 15, {|| cWelcome1 }, oPanel, , oCMFont, , , , .T., , , 330, 20)
    oSay2   := TSay():New(30 , 15, {|| cWelcome2 }, oPanel, , oCMFont, , , , .T., , , 330, 20)
    oSay3   := TSay():New(50 , 15, {|| cWelcome3 }, oPanel, , oCMFont, , , , .T., , , 330, 20)
    oSay4   := TSay():New(70 , 15, {|| cWelcome4 }, oPanel, , oCMFont, , , , .T., , , 330, 20)
    oSay5   := TSay():New(90 , 15, {|| cWelcome5 }, oPanel, , oCMFont, , , , .T., , , 330, 20)
    oSay6   := TSay():New(110, 15, {|| cWelcome6 }, oPanel, , oCMFont, , , , .T., , , 330, 25)
    oSay7   := TSay():New(145, 15, {|| cWelcome7 }, oPanel, , oCMFont, , , , .T., , , 330, 20)
   
 Return

/*/{Protheus.doc} Etapa2
Monta Etapa 2 do Wizard - Validação de Acesso e Seleção de Filiais

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@param 01 - oPanel  , objeto  , painel para exibição da etapa
@param 02 - aSM0    , array   , retorna por referência array da FWLoadSM0() - https://tdn.totvs.com/display/framework/FWLoadSM0
/*/
METHOD Etapa2(oPanel, aSM0) CLASS GIQ0003Class
    Local oList
    Local oTGet1
    Local oTGet2

    self:CarregaEmpresas(@aSM0)

    oCHFont := TFont():New('Arial',,-11,.T.,.T.)
	oCMFont := TFont():New('Arial',,-13,.T.)

    @ 5, 5 GROUP TO 40, 195 PROMPT STR0010 OF oPanel PIXEL //"Validação de Acesso"

        @ 14, 10 SAY  STR0011 OF oPanel PIXEL FONT oCHFont //"Usuário Administrador:"
        @ 24, 10 MSGET oTGet1 VAR self:cUsuario SIZE 80, 10 OF oPanel Font oCMFont PIXEL 

        @ 14, 100 SAY STR0012 OF oPanel PIXEL FONT oCHFont //"Senha:"
        @ 24, 100 MSGET oTGet2 VAR self:cSenha SIZE 80, 10 OF oPanel Font oCMFont PIXEL PASSWORD

    // Monta a lista de empresas. 
    @ 40, 5 GROUP TO 170, 195 PROMPT STR0013 OF oPanel PIXEL //"Filiais para Implantação"
        @ 50, 10 LISTBOX oList;
            FIELDS HEADER "", STR0014, STR0015, STR0016 SIZE 180, 115 OF oPanel PIXEL; //"Grupo Emp", "Filial", "Descrição"
            ON DBLCLICK self:MarcaFilial(oList)
            oList:SetArray(self:aEmpresas)
            oList:bLine := {|| { ;
                If(self:aEmpresas[oList:nAt, nMarcado], LoadBitmap(GetResources(), "LBTIK"), LoadBitmap(GetResources(), "LBNO")),;
                self:aEmpresas[oList:nAt, nGrupoDeEmpresa],;
                self:aEmpresas[oList:nAt, nFilialComposta],;
                self:aEmpresas[oList:nAt, nDescricaoFilial] }}
            oList:Refresh()

    // Montando Explicação Filiais
    @ 5, 200 GROUP TO 170, 360 PROMPT STR0017 COLOR CLR_RED OF oPanel PIXEL //"ATENÇÃO"
        @ 15, 205 SAY STR0018 + ENTER + ENTER +; //"Selecione a filial que iniciará uso da solução a partir de agora. As demais filiais devem ser configuradas somente no momento em que a solução passar a ser utilizada."
                      STR0019 + ENTER + ENTER +; //"Obs:  cenários como este a seguir irão requer ambiente Cloud específico para cada filial. Neste caso entre em contato com a TOTVS."
                      STR0020 + ENTER +;         //"- Filial 'São Paulo', Produto '001 - parafuso'"
                      STR0021;                   //"- Filial 'Belo Horizonte', Produto '001 - rolamento'."
                      SIZE 150, 205 OF oPanel PIXEL FONT oCMFont 

    oTGet1:SetFocus()
   
Return

/*/{Protheus.doc} Etapa3
Monta Etapa 3 do Wizard - Seleção de Parâmetros de Acesso a Plataforma

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - oPanel   , objeto  , painel para exibição da etapa
/*/
METHOD Etapa3(oPanel) CLASS GIQ0003Class
    Local oCHFont
    Local oCMFont
    Local oClientID
    Local oSecretID
    //Local oRACURL
    Local oGIQURL

    self:aParametros := StartJob("GIQ0003P" , GetEnvServer() , .T. , self:cUsuario, self:cSenha, self:aEmpresas, self:nEmpresaMarcada)
    
    DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD 
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10
    
    @ 5, 5 GROUP TO 170, 360 PROMPT STR0022 + self:aEmpresas[self:nEmpresaMarcada][nGrupoDeEmpresa] + "/" + self:aEmpresas[self:nEmpresaMarcada][nFilialComposta] OF oPanel PIXEL //"Acesso a plataforma da filial: "

        @ 25, 15 SAY STR0023 OF oPanel PIXEL FONT oCHFont //"Client ID:"
        @ 35, 15 MSGET oClientID VAR self:aParametros[nMV_CLIENTI] SIZE 180, 10 OF oPanel Font oCMFont PIXEL

        @ 50, 15 SAY STR0024 OF oPanel PIXEL FONT oCHFont //"Secret ID:"
        @ 60, 15 MSGET oSecretID VAR self:aParametros[nMV_SECRETI] SIZE 180, 10 OF oPanel Font oCMFont PIXEL

        //@ 75, 15 SAY STR0025 OF oPanel PIXEL FONT oCHFont //"URL RAC:"
        //@ 85, 15 MSGET oRACURL VAR self:aParametros[nMV_RACGIQ] SIZE 180, 10 OF oPanel Font oCMFont PIXEL 

        @ 75, 15 SAY STR0026 OF oPanel PIXEL FONT oCHFont //"URL GIQ:"
        @ 85, 15 MSGET oGIQURL VAR self:aParametros[nMV_URLGIQ] SIZE 180, 10 OF oPanel Font oCMFont PIXEL

    GIQIPCStart(self:cGlobalKey, nThreadsDEF, 0, self:aEmpresas[self:nEmpresaMarcada][nGrupoDeEmpresa], self:aEmpresas[self:nEmpresaMarcada][nFilialComposta], "GIQ0003ClassError") //Inicializa as Threads

 Return

/*/{Protheus.doc} Etapa4
Monta Etapa 4 do Wizard - Acompanhamento e Execução

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - oPanel , objeto, painel para exibição da etapa
@param 02 - oStatus, objeto, objeto LISTBOX utilizado para apresentar os dados da execução
/*/
METHOD Etapa4(oPanel, oStatus) CLASS GIQ0003Class
    Local aStatus := {}
    Local cStatus
    Local oBtnPanel := TPanel():New(0, 0, "", oPanel, , , , , , 40, 40, .T., .T.)
    Local oFont 
    
    oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT

    DEFINE FONT oFont NAME "Courier New" SIZE 10, 0
    @ 5, 5 LISTBOX oStatus VAR cStatus ITEMS aStatus SIZE 355, 160 OF oBtnPanel PIXEL  FONT oFont
   
 Return

/*/{Protheus.doc} ValidaUsuario
Controla Validação de Usuário e Mensagens

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@return lValid, lógico, indica se o usuário é válido para todas as empresas marcadas
/*/
METHOD ValidaUsuario() CLASS GIQ0003Class
    Local aReturn       := {}
    Local cDicCompany   := ""
    Local cNoCompany    := ""
    Local cMsg          := ""
    Local lValid        := .F.    
    Local nVldLogin

    If Empty(self:cUsuario)
        cMsg := STR0027 //"Informe o usuário"
    ElseIf !self:ValidaSelecaoEmpresa()
        cMsg := STR0028 //"Selecione ao menos uma empresa"
    Else 
        nVldLogin := PswAdmin(Alltrim(self:cUsuario), Alltrim(self:cSenha))
        If nVldLogin == 0
            aReturn               := StartJob("GIQ0003E", GetEnvServer(), .T., self:aEmpresas, self:cUsuario, self:cSenha)
            lValid                := aReturn[1]
            self:nEmpresaMarcada  := aReturn[2]
            cNoCompany            := aReturn[3]
            cDicCompany           := aReturn[4]
            If Empty(cNoCompany) 
                If !lValid 
                    cMsg := STR0029 + SubStr(cDicCompany, 1, Len(cDicCompany) - 1) //"Atualização de dicionário de dados UPDDISTR (Pacote GIQ) não aplicado ou desatualizado para a(s) empresa(s): "
                EndIf
            Else
               cMsg      := STR0030 + SubStr(cNoCompany, 1, Len(cNoCompany) - 1) //"Usuário não possui acesso na(s) empresa(s): "
               lValid    := .F.
            EndIf
        Else
            If nVldLogin == 1
                cMsg := STR0031 //"O usuário informado não é administrador do sistema."
            ElseIf nVldLogin == 2
                cMsg := STR0032 //"Dados para login incorretos."
            EndIf
        EndIf
    EndIf

    If !lValid
        MsgAlert(cMsg, STR0033) //"Falha na Validação de Acesso"
    EndIf

Return lValid

/*/{Protheus.doc} ChecaAcessoUsuarioAsEmpresasMarcadas
Checa Acesso do Usuário as Empresas Marcadas

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@return aReturn := 
    {lValid: resultado geral de validação nas empresas,
    nEmpresaMarcada,
    cNoCompany: empresas que o usuário não tem acesso,
    cDicCompany: empresas com necessidade de ajuste do dicionário}
/*/
METHOD ChecaAcessoUsuarioAsEmpresasMarcadas() CLASS GIQ0003Class
    Local aReturn          := {}
    Local cDicCompany      := ""
    Local cNoCompany       := ""
    Local lValid           := .F.
    Local nEmpresa         := 0
    Local nEmpresaMarcada := 0

    For nEmpresa := 1 To Len(self:aEmpresas)
        If self:aEmpresas[nEmpresa][nMarcado]
            If self:AbreAmbiente(self:aEmpresas[nEmpresa][nGrupoDeEmpresa], self:aEmpresas[nEmpresa][nFilialComposta], self:cUsuario, self:cSenha)
                If nEmpresaMarcada == 0
                    nEmpresaMarcada := nEmpresa
                EndIf
                If self:ValidaDicionarioGIQ()         
                    lValid := .T. 
                Else
                    cDicCompany += self:aEmpresas[nEmpresa][nGrupoDeEmpresa] + ","
                    lValid   := .F.
                EndIf
            Else 
                cNoCompany += self:aEmpresas[nEmpresa][nGrupoDeEmpresa] + "/" + self:aEmpresas[nEmpresa][nFilialComposta] + "," 
            EndIf
            RpcClearEnv()
        EndIf
    Next nEmpresa 
    aReturn := {lValid, nEmpresaMarcada, cNoCompany, cDicCompany}
Return aReturn

/*/{Protheus.doc} ValidaDicionarioGIQ
Valida Existência do Dicionário do GIQ: QF0

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@return lRet, lógico, indica se existe a QF0 no dicionário
/*/
METHOD ValidaDicionarioGIQ() CLASS GIQ0003Class
    Local lRet := .F.
    DBSelectArea("SX2")
    DBSetOrder(1)
    If SX2->(DBSeek("QF0"))
        lRet := .T.
    EndIf
Return lRet

/*/{Protheus.doc} MarcaFilial
Marca a Filial da Linha

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@return .T.
/*/
METHOD MarcaFilial(oList) CLASS GIQ0003Class
	Local lMark := .T.
    If self:ValidaSelecaoEmpresa() .and. !self:aEmpresas[oList:nAt, nMarcado]
        lMark := .F.
    Else
        self:aEmpresas[oList:nAt, nMarcado] := !self:aEmpresas[oList:nAt, nMarcado]
        oList:Refresh(.F.)
    EndIf
Return lMark

/*/{Protheus.doc} ValidaSelecaoEmpresa
Valida Seleção de Ao Menos Uma Empresa

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@return retorna .T. se houver pelo menos uma empresa marcada
/*/
METHOD ValidaSelecaoEmpresa() CLASS GIQ0003Class
Return (aScan(self:aEmpresas, {|x| x[1] == .T. }) > 0)

/*/{Protheus.doc} CarregaEmpresas
Cria Array self:aEmpresas Carregando as Empresas

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@param 01 - aSM0    , array   , retorna por referência array da FWLoadSM0() - https://tdn.totvs.com/display/framework/FWLoadSM0
/*/
METHOD CarregaEmpresas(aSM0) CLASS GIQ0003Class
    Local aGrupo    := {}
    Local cGrpFil   := ""
    Local cLayout   := ""
    Local nEmpresa
    Local nLayout
    Local nSM0
    Local oTamanhos := JsonObject():New()

	SET DELET ON

    OpenSM0()
    aGrupo := FWAllGrpCompany()
    For nEmpresa := 1 To Len(aGrupo)
        cLayout := FWSM0Layout(aGrupo[nEmpresa])
        oTamanhos[aGrupo[nEmpresa]] := JsonObject():New()
        oTamanhos[aGrupo[nEmpresa]]['nTamEmp']  := 0
        oTamanhos[aGrupo[nEmpresa]]['nTamUnid'] := 0
        oTamanhos[aGrupo[nEmpresa]]['nTamFil']  := 0
        For nLayout := 1 To Len(cLayout)
            If SubStr(cLayout,nLayout,1) == "E"
                oTamanhos[aGrupo[nEmpresa]]['nTamEmp']  += 1
            ElseIf SubStr(cLayout,nLayout,1) == "U"
                oTamanhos[aGrupo[nEmpresa]]['nTamUnid'] += 1
            ElseIf SubStr(cLayout,nLayout,1) == "F"
                oTamanhos[aGrupo[nEmpresa]]['nTamFil']  += 1
            EndIf
        Next nLayout
    Next aGrupo

    aSM0 := FWLoadSM0()
    For nSM0 := 1 To Len(aSM0)
        cGrpFil := PadR(aSM0[nSM0][3], oTamanhos[aSM0[nSM0][1]]['nTamEmp'])  +; 
                   PadR(aSM0[nSM0][4], oTamanhos[aSM0[nSM0][1]]['nTamUnid']) +;
                   PadR(aSM0[nSM0][5], oTamanhos[aSM0[nSM0][1]]['nTamFil'])

        AADD(self:aEmpresas, { .F., AllTrim(aSM0[nSM0][1]), cGrpFil, AllTrim(aSM0[nSM0][7])})
    Next nSM0

    For nEmpresa := 1 To Len(aGrupo)
        FreeObj(oTamanhos[aGrupo[nEmpresa]])
        oTamanhos[aGrupo[nEmpresa]] := Nil
    Next aGrupo

    FreeObj(oTamanhos)
    oTamanhos := Nil

    FwFreeArray(aGrupo)

Return

/*/{Protheus.doc} ExecutaImplantacao
Executa os Procedimentos de Implantação

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - oStatus, objeto, objeto LISTBOX utilizado para apresentar os dados da execução
@param 02 - aSM0   , array   , retorna por referência array da FWLoadSM0() - https://tdn.totvs.com/display/framework/FWLoadSM0
/*/
METHOD ExecutaImplantacao(oStatus, aSM0) CLASS GIQ0003Class
    Local nPendencias := 0
    Local nQuantidade := 0
    Local lFornOK     := .F.
    Local lProdutoOK  := .F.
    Local nAtual      := 0
    Local nTotal      := 0
    Local cPercentual := ""
    Local nPosFor     := 0
    Local nPosProd    := 0
    Local cTexto      := ""

    oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0036 + ' - ' + self:aEmpresas[self:nEmpresaMarcada][nGrupoDeEmpresa] + '/' + self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]) //"Conectando Ambiente"
    self:AbreAmbiente(self:aEmpresas[self:nEmpresaMarcada][nGrupoDeEmpresa], self:aEmpresas[self:nEmpresaMarcada][nFilialComposta])

    VarSetUID(self:cGlobalKey, .T.)
    VarSetX(self:cGlobalKey, 'nProdutos'    , 0)
    VarSetX(self:cGlobalKey, 'nFornecedores', 0)
    VarSetX(self:cGlobalKey, 'nProdutos_Total'    , self:BuscaProdutosTotalIntegracao())
    VarSetX(self:cGlobalKey, 'nFornecedores_Total', self:BuscaFornecedoresTotalIntegracao())
    
    oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0034) //"Atualizando Parâmetros de Acesso a Plataforma"
    self:SalvaParametrosAcessoAPlataforma()

    oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0035) //"Criando Tarefa no Schedule"
    
    self:CriaSchedule() // Cria o agendamento

    self:ValidaIntegracaoCompartilhadaAnteriormente()

    //Ativar parametro MV_INTGIQE para as filiais selecionadas
    oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0037) //"Ativando Integração na Filial"
    self:HabilitaIntegracaoFilial(self:aEmpresas[self:nEmpresaMarcada][nFilialComposta])

    // Carga inicial de fornecedores
    If (self:oCompartilhamentos['SA2'][xFilial("SA2", self:aEmpresas[self:nEmpresaMarcada][nFilialComposta])] == xFilial("SA2", self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]))
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0038) //"Integração de Fornecedores Já Foi Processada"
        lFornOK := .T.
    Else
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0039) //"Integrando Fornecedores"
        StartJob("GIQ0003FOR" , GetEnvServer() , .F. , self:cUsuario, self:cSenha, self:aEmpresas, self:nEmpresaMarcada, self:cGlobalKey)
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + cValToChar(nQuantidade) + " " + STR0040 + " (  0%)") //"Fornecedores Enviados"
        nPosFor := oStatus:Len()
    EndIf

    // Carga inicial de produtos
    If (self:oCompartilhamentos['SB1'][xFilial("SB1", self:aEmpresas[self:nEmpresaMarcada][nFilialComposta])] == xFilial("SB1", self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]))
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0041) //"Integração de Produtos Já Foi Processada"
        lProdutoOK := .T.
    Else
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0042) //"Integrando Produtos"
        StartJob("GIQ0003PRD" , GetEnvServer() , .F. , self:cUsuario, self:cSenha, self:aEmpresas, self:nEmpresaMarcada, self:cGlobalKey)
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + cValToChar(nQuantidade) + " " + STR0043+ " (  0%)") //"Produtos Enviados"
        nPosProd := oStatus:Len()
    EndIf

    While !lFornOK .OR. !lProdutoOK

        If !lFornOK
            VarGetX(self:cGlobalKey, 'nFornecedores', @nAtual)
            VarGetX(self:cGlobalKey, 'nFornecedores_Total', @nTotal)
            cPercentual = " (" + cValToChar(Round(nAtual / nTotal * 100, 0)) + "%)"
            lFornOK := nAtual == nTotal
            cTexto := Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " " + STR0040 + cPercentual
            oStatus:Modify(cTexto, nPosFor)
        EndIf

        If !lProdutoOK
            VarGetX(self:cGlobalKey, 'nProdutos', @nAtual)
            VarGetX(self:cGlobalKey, 'nProdutos_Total', @nTotal)
            cPercentual = " (" + cValToChar(Round(nAtual / nTotal * 100, 0)) + "%)"
            lProdutoOK := nAtual == nTotal
            cTexto := Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " " + STR0043 + cPercentual
            oStatus:Modify(cTexto, nPosProd)
        EndIf
        
        oStatus:Refresh()

        Sleep(1000)
    EndDo
    Sleep(1000) //Aguarda conclusão de todas as Threads

    nPendencias := self:ChecaPendencias(xFilial("QF0", self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]))
    If nPendencias > 0
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0044 + " " + cValToChar(nPendencias) + " " + STR0045) //"Integração concluída com" + "pendências que serão reprocessadas. Caso necessário, consulte o GIQ0002."
    Else
        oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0046) //"Integração concluída com sucesso."
    EndIf

    VarClean( self:cGlobalKey )

    // Fecha ambiente
    RpcClearEnv()
    oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0047 + ' - ' + self:aEmpresas[self:nEmpresaMarcada][nGrupoDeEmpresa] + '/' +  self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]) //"Ambiente Encerrado"

    oStatus:Add(Padr(Dtoc(MsDate()), 14) + Padr(Time(), 10) + ' - ' + STR0048) //"Configurações Finalizadas"
    oStatus:Refresh()

Return

/*/{Protheus.doc} ValidaIntegracaoCompartilhadaAnteriormente
Verificar se

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
/*/
METHOD ValidaIntegracaoCompartilhadaAnteriormente() CLASS GIQ0003Class
    Local nEmpresa := 0

    For nEmpresa := 1 to len(self:aEmpresas)
    
        If SuperGetMV("MV_INTGIQE", .F., .F., self:aEmpresas[nEmpresa][nFilialComposta])
            self:oCompartilhamentos['SA2'][xFilial("SA2", self:aEmpresas[nEmpresa][nFilialComposta])] = xFilial("SA2", self:aEmpresas[nEmpresa][nFilialComposta])
            self:oCompartilhamentos['SB1'][xFilial("SB1", self:aEmpresas[nEmpresa][nFilialComposta])] = xFilial("SB1", self:aEmpresas[nEmpresa][nFilialComposta])
        EndIf
    
    Next nEmpresa
    
Return


/*/{Protheus.doc} SalvaParametrosAcessoAPlataforma
Salva Parâmetros de Acesso a Plataforma

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
/*/
METHOD SalvaParametrosAcessoAPlataforma() CLASS GIQ0003Class
    Local aSX6     := {}
    Local nTamSX6  := 0
    nTamSX6 := TamSX3("A1_FILIAL")[1]
    Aadd(aSX6, { self:aEmpresas[self:nEmpresaMarcada][nFilialComposta], 'MV_CLIENTI', 'C', STR0049, STR0050, '',; //"Informar o usuário do RAC que será utilizado nas" + "integrações com o GIQ"
        self:aParametros[nMV_CLIENTI], self:aParametros[nMV_CLIENTI], self:aParametros[nMV_CLIENTI], 'S', 'S'})

    Aadd(aSX6, { self:aEmpresas[self:nEmpresaMarcada][nFilialComposta], 'MV_SECRETI', 'C', STR0051, STR0052, '',; //"Informar a senha do RAC que será utilizado nas" + "integrações com o GIQ"
        self:aParametros[nMV_SECRETI], self:aParametros[nMV_SECRETI], self:aParametros[nMV_SECRETI], 'S', 'S'})

    Aadd(aSX6, { Space(nTamSX6), 'MV_RACGIQ' , 'C', STR0053, STR0054, STR0055, ; //"URL Autenticação para Sistema GIQ" + "Defina e URL de autenticação para o Sistema GIQ (" + "Gestão de Inspeção da Qualidade)"
        self:aParametros[nMV_RACGIQ], self:aParametros[nMV_RACGIQ], self:aParametros[nMV_RACGIQ], 'S', 'S'})

    Aadd(aSX6, { self:aEmpresas[self:nEmpresaMarcada][nFilialComposta], 'MV_URLGIQ' , 'C', STR0056, STR0057, '', ; //"URL Destino (tenant do cliente)" + "Define a URL do GIQ"
        self:aParametros[nMV_URLGIQ], self:aParametros[nMV_URLGIQ], self:aParametros[nMV_URLGIQ], 'S', 'S'})
    self:SalvaX6(aSX6)
Return

/*/{Protheus.doc} HabilitaIntegracaoFilial
Habilita MV_INTGIQE na Filial

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@param 01 - cFilAux, caracter, filial para habilitar a integração
/*/
METHOD HabilitaIntegracaoFilial(cFilAux) CLASS GIQ0003Class
    self:SalvaX6({{ cFilAux, 'MV_INTGIQE', 'L', STR0058, STR0058,'',; //"Indica se haverá integração com o GIQ nas entradas" + ", ao invés de haver integração com o SIGAQIE"
                ".T.", ".T.", ".T.", 'S', 'S'}})
Return

/*/{Protheus.doc} SalvaX6
Salva Parâmetros na SX6

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - aSX6, array, array com os dados para gravar os registros dos parâmetros na SX6
/*/
METHOD SalvaX6(aSX6) CLASS GIQ0003Class
    Local aStruct  := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_DESC1", "X6_DESC2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI", "X6_PYME" }
    Local aSvAlias := GetArea()
    Local lFind    := .F.
    Local nParams  := 0
    Local nFields  := 0

    Default aSX6   := {}

    dbSelectArea("SX6")
    dbSetOrder(1)
    For nParams := 1 To Len(aSX6)
        If !Empty(aSX6[ nParams ][2])
            If !dbSeek(aSX6[ nParams, 1] + aSX6[ nParams, 2])
                lFind := .F.
            Else
                lFind := .T.
            EndIf

            RecLock("SX6", !lFind)
                For nFields := 1 To Len(aSX6[ nParams ])
                    If !Empty(FieldName(FieldPos(aStruct[ nFields ])))
                        IF !lFind .Or. "X6_CONT" $ aStruct[ nFields ]
                            FieldPut(FieldPos(aStruct[ nFields ]), aSX6[ nParams, nFields])
                        EndIf
                    EndIf
                Next 
            MsUnLock()
        EndIf
    Next

    RestArea(aSvAlias)
    FwFreeArray(aSvAlias)
    FWFreeArray(aSX6)
Return

/*/{Protheus.doc} CriaSchedule
Cria Agendamento do Schedule na XX1 e XX2

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
/*/
METHOD CriaSchedule() CLASS GIQ0003Class
    Local aJobs       := { 'GIQ0001' }
    Local aSvAlias    := GetArea()
    Local aSM0        := {}
    Local aSchdComp   := {}
    Local cExecComp   := ''
    Local cQuery      := ''
    Local cRecurrence := ''
    Local cTaskID     := ''
    Local cTime       := ''
    Local cTmpAlias   := ''
    Local nAux        := 0
    Local nItem       := 1

    // Monta lista de empresas\filiais para execução do agendamento
    aSM0 := FWLoadSM0()
    For nItem := 1 to len(self:aEmpresas)
        IF self:aEmpresas[nItem][nMarcado]
            cExecComp += self:aEmpresas[nItem][nGrupoDeEmpresa] + "/" + self:aEmpresas[nItem][nFilialComposta] + ";"
        EndIf
    Next

    For nItem := 1 to len(aJobs)
        cRecurrence := 'A'
        cTime := '00:00'

        If aJobs[ nItem ] == "GIQ0001"
            cRecurrence := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(288);Interval(00:05);Discard;"
        EndIf

        cTaskID := FwSchdByFunction(aJobs[ nItem ])
        If Empty(cTaskID)
            FwInsSchedule(aJobs[ nItem ], __cUserID, , cRecurrence, cTime, Upper(GetEnvServer()), cExecComp , SCHD_ACTIVE, Date(), 2, NIL)
        Else
            If !(ExistFunc("FwOpenXX2"))
                DbSelectArea("XX2")
            Else
                FwOpenXX2()
            EndIf

            // Exclui as empresas\filiais de cada agendamento
            cQuery := "SELECT R_E_C_N_O_ ID FROM XX2 WHERE XX2_AGEND = '" + cTaskID + "' "
            cTmpAlias := MPSysOpenQuery(cQuery)

            While (cTmpAlias)->(!Eof())
                XX2->(DBGoto((cTmpAlias)->ID))    
                RecLock("XX2", .F.)
                    XX2->(DBDelete())
                XX2->(MsUnlock())

                (cTmpAlias)->(DBSkip())
            End
            (cTmpAlias)->(DbCloseArea())

            // Recria a ligação entre o agendamento e filiais
            aSchdComp := StrtokArr(cExecComp, ";")
            For nAux := 1 to len(aSchdComp)
                RecLock('XX2', .T.)
                    XX2->XX2_AGEND  := cTaskID
                    XX2->XX2_EMPFIL := aSchdComp[ nAux ]
                MsUnLock()        
            Next
        EndIf
    Next

    RestArea(aSvAlias)

    FWFreeArray(aSvAlias)
    FWFreeArray(aJobs)
    FWFreeArray(aSM0)
    FWFreeArray(aSchdComp)
Return

/*/{Protheus.doc} AbreAmbiente
Abre Ambiente do Protheus

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - cCompany, caracter, grupo de empresa para abertura do ambiente
@param 02 - cBranch , caracter, filial para abertura do ambiente

@return lRet, lógico, indnca se conseguiu preparar o ambiente
/*/
METHOD AbreAmbiente(cCompany, cBranch) CLASS GIQ0003Class
    Local lRet      := .T.  
    RPCSetType(3)
    IF !Empty(self:cUsuario)
        lRet := RpcSetEnv(cCompany, cBranch, self:cUsuario, self:cSenha)
    else
        lRet := RpcSetEnv(cCompany, cBranch)
    EndIf
Return lRet

/*/{Protheus.doc} EnviaProdutos
Envia Todos os Produtos Com Integração Quality Ativa para o GIQ

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@return nProdutos, número, quantidade de produtos que serão enviados
/*/
METHOD EnviaProdutos() CLASS GIQ0003Class
	Local cAliasTop := GetNextAlias()
    Local oProduto
    Local nProdutos := 0
	BeginSql Alias cAliasTop
		%noparser%
		SELECT  DISTINCT
                SB1.B1_COD,
                SB1.B1_DESC,
                SB1.B1_UM,
                SA2.A2_COD,
                SA2.A2_LOJA,
                SA2.A2_CGC,
                SA2.A2_NOME
        FROM        %table:SA2% SA2 
                    INNER JOIN
                    %table:SA5% SA5 ON SA2.A2_COD = SA5.A5_FORNECE AND SA2.A2_LOJA = SA5.A5_LOJA 
                    RIGHT OUTER JOIN
                    %table:SB1% SB1 ON SA5.A5_PRODUTO = SB1.B1_COD
        WHERE (SB1.B1_TIPOCQ = 'Q')
            AND SB1.%notDel%
            AND (SA2.%notDel% OR SA2.D_E_L_E_T_ IS NULL)
            AND (SA5.%notDel% OR SA5.D_E_L_E_T_ IS NULL)
            AND SB1.B1_FILIAL = %xfilial:SB1%
            AND (SA2.A2_FILIAL = %xfilial:SA2% OR SA2.A2_FILIAL IS NULL)
            AND (SA5.A5_FILIAL = %xfilial:SA5% OR SA5.A5_FILIAL IS NULL)
        ORDER BY SB1.B1_COD, SA2.A2_COD, SA2.A2_LOJA
	EndSql
    //            AND SB1.B1_COD = 'GIQ0007'

	While !(cAliasTop)->(Eof())
        If oProduto != NIL .AND. !Empty(oProduto['codigo']) .AND. oProduto['codigo'] != TRIM((cAliasTop)->B1_COD)
            GIQIPCGO(self:cGlobalKey, .F., "GIQ0003EPR", oProduto:toJson())
            FreeObj(oProduto)
            oProduto := Nil
            nProdutos++
            VarSetX(self:cGlobalKey, 'nProdutos', nProdutos)
        EndIf
        oProduto = self:CriaProdutoJson(cAliasTop, oProduto)
        (cAliasTop)->(dbSkip())
	EndDo

    If oProduto != Nil .AND. !Empty(oProduto['codigo'])
        GIQIPCGO(self:cGlobalKey, .F., "GIQ0003EPR", oProduto:toJson())
        FreeObj(oProduto)
        oProduto := Nil
        nProdutos++
        VarSetX(self:cGlobalKey, 'nProdutos', nProdutos)
    EndIf

	(cAliasTop)->(dbCloseArea())

Return nProdutos

/*/{Protheus.doc} CriaProdutoJson
Cria Arquivo JSON padrão para Envio de Produtos para o GIQ

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - cAliasTop, caracter, alias do banco de dados com os dados do produto
@param 02 - oProduto , objeto  , objeto com os dados do produto em situações da existência de mais de um fornecedor relacionado
@Return oProduto , objeto  , retorna por referência objeto JSON do Produto
/*/
METHOD CriaProdutoJson(cAliasTop, oProduto) CLASS GIQ0003Class
	Local nFornecedores	:= 0
    Default oProduto    := JsonObject():New()

    if Empty(oProduto["codigo"])
        oProduto["codigo"]        := TRIM((cAliasTop)->B1_COD)
        oProduto["descricao"]     := TRIM(EncodeUTF8((cAliasTop)->B1_DESC))
        oProduto["nome"]          := TRIM(EncodeUTF8((cAliasTop)->B1_DESC))
        oProduto["unidadeMedida"] := TRIM((cAliasTop)->B1_UM)
        oProduto["delete"]        := .F.
        oProduto['fornecedores']  := {}
    EndIf
	nFornecedores := Len(oProduto['fornecedores'])
    If !Empty((cAliasTop)->A2_COD)
        nFornecedores++
        Aadd(oProduto['fornecedores'], JsonObject():New())
        oProduto['fornecedores'][nFornecedores]['codigo']    := TRIM((cAliasTop)->A2_COD) + '-' + TRIM((cAliasTop)->A2_LOJA)
        oProduto['fornecedores'][nFornecedores]['nome']      := TRIM(EncodeUTF8((cAliasTop)->A2_NOME))
        If !Empty(TRIM(SA2 -> A2_CGC))
            oProduto['fornecedores'][nFornecedores]['documento'] := TRIM(SA2->A2_CGC)
        EndIf
    EndIf

Return oProduto

/*/{Protheus.doc} EnviaFornecedores
Envia Todos os Fornecedores Com Relacionamento a Produto Inspeção QUALITY para o GIQ

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@return nFornecedores, número, quantidade de nFornecedores que serão enviados
/*/
METHOD EnviaFornecedores() CLASS GIQ0003Class
    Local cAliasTop     := GetNextAlias()
    Local nFornecedores := 0
    Local oFornecedor
	BeginSql Alias cAliasTop
		%noparser%
		SELECT  DISTINCT 
                SA2.A2_COD,
                SA2.A2_LOJA,
                SA2.A2_CGC,
                SA2.A2_NOME
        FROM        %table:SA2% SA2 
                    INNER JOIN
                    %table:SA5% SA5 ON SA2.A2_COD = SA5.A5_FORNECE AND SA2.A2_LOJA = SA5.A5_LOJA
                    INNER JOIN
                    %table:SB1% SB1 ON SA5.A5_PRODUTO = SB1.B1_COD
        WHERE (SB1.B1_TIPOCQ = 'Q')
            AND SB1.%notDel%
            AND SA2.%notDel%
            AND SA5.%notDel%
            AND SB1.B1_FILIAL = %xfilial:SB1%
            AND SA2.A2_FILIAL = %xfilial:SA2%
            AND SA5.A5_FILIAL = %xfilial:SA5%
        ORDER BY SA2.A2_COD, SA2.A2_LOJA
	EndSql

	While !(cAliasTop)->(Eof())
        oFornecedor = self:CriaFornecedorJson(cAliasTop)
        GIQIPCGO(self:cGlobalKey, .F., "GIQ0003EFO", oFornecedor:toJson())
        FreeObj(oFornecedor)
        oFornecedor := Nil
        nFornecedores++
        VarSetX(self:cGlobalKey, 'nFornecedores', nFornecedores)
        (cAliasTop)->(dbSkip())
	EndDo

	(cAliasTop)->(dbCloseArea())
Return nFornecedores

/*/{Protheus.doc} CriaFornecedorJson
Cria Arquivo JSON padrão para Envio de Fornecedores para o GIQ

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - cAliasTop, caracter, alias do banco de dados com os dados do produto
@return oFornecedor , objeto  , retorna objeto JSON do Produto
/*/
METHOD CriaFornecedorJson(cAliasTop) CLASS GIQ0003Class
	Local oFornecedor := JsonObject():New()
    oFornecedor['codigo']    := TRIM((cAliasTop)->A2_COD) + '-' + TRIM((cAliasTop)->A2_LOJA)
    oFornecedor['nome']      := TRIM(EncodeUTF8((cAliasTop)->A2_NOME))
    If !Empty(TRIM(SA2->A2_CGC))
        oFornecedor['documento'] := TRIM(SA2->A2_CGC)
    EndIf
    oFornecedor['delete']    := .F.
Return oFornecedor

/*/{Protheus.doc} ChecaPendencias
Checa Pendências de Envio na QF0

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - cFilAux, caracter, filial para checagem de pendências
@return nReturn, número, quantidade de pendências existentes na QF0
/*/
METHOD ChecaPendencias(cFilAux) CLASS GIQ0003Class
	Local cAliasTop := GetNextAlias()
    Local nReturn   := 0
	BeginSql Alias cAliasTop
		%noparser%
		SELECT COUNT(*) QTDE
        FROM %table:QF0% QF0
        WHERE QF0_API IN ('MATA010GIQ', 'MATA020GIQ')
            AND QF0.%notDel%
            AND QF0.QF0_FILIAL = %Exp:cFilAux%
	EndSql
	nReturn := (cAliasTop)->QTDE
	(cAliasTop)->(dbCloseArea())
Return nReturn

/*/{Protheus.doc} RetornaParametrosDeAcesso
Retorna Parâmetros de Acesso da Primeira Filial Selecionada

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@return self:aParametros
/*/
METHOD RetornaParametrosDeAcesso() CLASS GIQ0003Class
    self:AbreAmbiente(self:aEmpresas[self:nEmpresaMarcada][nGrupoDeEmpresa], self:aEmpresas[self:nEmpresaMarcada][nFilialComposta])
    self:aParametros[nMV_CLIENTI] := PadR(SuperGetMV("MV_CLIENTI", .F., ""                                   , self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]), 255)
    self:aParametros[nMV_SECRETI] := PadR(SuperGetMV("MV_SECRETI", .F., ""                                   , self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]), 255)
    self:aParametros[nMV_RACGIQ]  := PadR(SuperGetMV("MV_RACGIQ" , .F., "https://admin.rac.staging.totvs.app"), 255)
    self:aParametros[nMV_URLGIQ]  := PadR(SuperGetMV("MV_URLGIQ" , .F., ""                                   , self:aEmpresas[self:nEmpresaMarcada][nFilialComposta]), 255)
    RpcClearEnv()
Return self:aParametros

METHOD BuscaProdutosTotalIntegracao() CLASS GIQ0003Class
    Local cQuery := ""
    Local nTotal := 0
    Local cAlias := GetNextAlias()

    cQuery := "SELECT COUNT(*) TOTAL FROM "
    cQuery += "( "
    cQuery += "SELECT  DISTINCT              "
    cQuery += "                SB1.B1_COD,   "
    cQuery += "                SB1.B1_DESC,  "
    cQuery += "                SB1.B1_UM     "
    cQuery += "        FROM    "+RetSqlName("SA2")+" SA2 "
    cQuery += "                INNER JOIN "+RetSqlName("SA5")+" SA5 ON SA2.A2_COD = SA5.A5_FORNECE AND SA2.A2_LOJA = SA5.A5_LOJA "
    cQuery += "                RIGHT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON SA5.A5_PRODUTO = SB1.B1_COD "
    cQuery += "        WHERE (SB1.B1_TIPOCQ = 'Q') "
    cQuery += "            AND SB1.D_E_L_E_T_ <> '*' "
    cQuery += "            AND (SA2.D_E_L_E_T_ <> '*' OR SA2.D_E_L_E_T_ IS NULL) " 
    cQuery += "            AND (SA5.D_E_L_E_T_ <> '*' OR SA5.D_E_L_E_T_ IS NULL) "
    cQuery += "            AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
    cQuery += "            AND (SA2.A2_FILIAL = '"+xFilial("SA2")+"' OR SA2.A2_FILIAL IS NULL) "
    cQuery += "            AND (SA5.A5_FILIAL = '"+xFilial("SA5")+"' OR SA5.A5_FILIAL IS NULL) "
    //cQuery += "            AND SB1.B1_COD = 'GIQ0007' "
    cQuery += ") TOTAL_PRODUTOS "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If !(cAlias)->(Eof())
        nTotal := (cAlias)->(TOTAL)
    EndIf
    (cAlias)->(DbCloseArea())

Return nTotal

METHOD BuscaFornecedoresTotalIntegracao() CLASS GIQ0003Class
    Local cQuery := ""
    Local nTotal := 0
    Local cAlias := GetNextAlias()

    cQuery := "SELECT COUNT(*) TOTAL FROM "
    cQuery += "( "
    cQuery += "SELECT  DISTINCT              "
    cQuery += "                SA2.A2_COD,   "
    cQuery += "                SA2.A2_LOJA,  "
    cQuery += "                SA2.A2_CGC,   "
    cQuery += "                SA2.A2_NOME   "
    cQuery += "        FROM    "+RetSqlName("SA2")+" SA2 "
    cQuery += "                INNER JOIN "+RetSqlName("SA5")+" SA5 ON SA2.A2_COD = SA5.A5_FORNECE AND SA2.A2_LOJA = SA5.A5_LOJA "
    cQuery += "                INNER JOIN "+RetSqlName("SB1")+" SB1 ON SA5.A5_PRODUTO = SB1.B1_COD "
    cQuery += "        WHERE (SB1.B1_TIPOCQ = 'Q') "
    cQuery += "            AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "            AND SA2.D_E_L_E_T_ = ' ' " 
    cQuery += "            AND SA5.D_E_L_E_T_ = ' ' "
    cQuery += "            AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
    cQuery += "            AND SA2.A2_FILIAL = '"+xFilial("SA2")+"' "
    cQuery += "            AND SA5.A5_FILIAL = '"+xFilial("SA5")+"' "
    cQuery += ") TOTAL_FORNECEDORES "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If !(cAlias)->(Eof())        
        nTotal := (cAlias)->(TOTAL)
    EndIf
    (cAlias)->(dbCloseArea())

Return nTotal

/*/{Protheus.doc} GIQ0003E
Função Executada por JOB para Checar Acesso do Usuário a Empresa
(Abre Ambiente Fora da Thread Principal para não OCULTAR os HELP em TELA)

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - aEmpresas , array, array self:aEmpresas gerado anteriormente
@param 02 - cUsuario , caracter, usuário digitado pelo usuário na Etapa2
@param 03 - cSenha   , caracter, senha digitada pelo usuário na Etapa2

@return aReturn := 
    {lValid: resultado geral de validação nas empresas,
    nEmpresaMarcada,
    cNoCompany: empresas que o usuário não tem acesso,
    cDicCompany: empresas com necessidade de ajuste do dicionário}

/*/
Function GIQ0003E(aEmpresas, cUsuario, cSenha)
    Local oImplantador := GIQ0003Class():New(cUsuario, cSenha, aEmpresas)
    Local aReturn      := oImplantador:ChecaAcessoUsuarioAsEmpresasMarcadas()
Return aReturn

/*/{Protheus.doc} GIQ0003P
Função Executada por JOB Retornar os Parâmetros Globais
(Abre Ambiente Fora da Thread Principal para não OCULTAR os HELP em TELA)

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@param 01 - cUsuario        , caracter, usuário digitado pelo usuário na Etapa2
@param 02 - cSenha          , caracter, senha digitada pelo usuário na Etapa2
@param 03 - aEmpresas       , array   , array self:aEmpresas gerado anteriormente
@param 04 - nEmpresaMarcada, numero   , primeira empresa selecionada pelo usuário anteriormente
@return aParametros
/*/
Function GIQ0003P(cUsuario, cSenha, aEmpresas, nEmpresaMarcada)
    Local oImplantador := GIQ0003Class():New(cUsuario, cSenha, aEmpresas, nEmpresaMarcada)
    Local aParametros  := oImplantador:RetornaParametrosDeAcesso()
Return aParametros

/*/{Protheus.doc} GIQ0003PRD
Função Executada por JOB para Enviar Produtos

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@param 01 - cUsuario        , caracter, usuário digitado pelo usuário na Etapa2
@param 02 - cSenha          , caracter, senha digitada pelo usuário na Etapa2
@param 03 - aEmpresas       , array   , array self:aEmpresas gerado anteriormente
@param 04 - nEmpresaMarcada, numero   , primeira empresa selecionada pelo usuário anteriormente
/*/
Function GIQ0003PRD(cUsuario, cSenha, aEmpresas, nEmpresaMarcada, cGlobalKey)
    Local oImplantador := GIQ0003Class():New(cUsuario, cSenha, aEmpresas, nEmpresaMarcada, cGlobalKey)
    oImplantador:AbreAmbiente(oImplantador:aEmpresas[oImplantador:nEmpresaMarcada][nGrupoDeEmpresa], oImplantador:aEmpresas[oImplantador:nEmpresaMarcada][nFilialComposta])
    oImplantador:EnviaProdutos()
    RpcClearEnv()
Return

/*/{Protheus.doc} GIQ0003EPR
Função Executada por Thread para Enviar Produtos

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - cJsonProduto, caracter, string json do produto para envio ao GIQ
/*/
Function GIQ0003EPR(cJsonProduto)
    Local oProduto := JsonObject():New()
    oProduto:fromJson(cJsonProduto)
    IntegraGIQ():EnviaProdutoParaGIQ(oProduto)
Return

/*/{Protheus.doc} GIQ0003PRD
Função Executada por JOB para Enviar Produtos

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33
@param 01 - cUsuario        , caracter, usuário digitado pelo usuário na Etapa2
@param 02 - cSenha          , caracter, senha digitada pelo usuário na Etapa2
@param 03 - aEmpresas       , array   , array self:aEmpresas gerado anteriormente
@param 04 - nEmpresaMarcada, numero   , primeira empresa selecionada pelo usuário anteriormente
/*/
Function GIQ0003FOR(cUsuario, cSenha, aEmpresas, nEmpresaMarcada, cGlobalKey)
    Local oImplantador := GIQ0003Class():New(cUsuario, cSenha, aEmpresas, nEmpresaMarcada, cGlobalKey)
    oImplantador:AbreAmbiente(oImplantador:aEmpresas[oImplantador:nEmpresaMarcada][nGrupoDeEmpresa], oImplantador:aEmpresas[oImplantador:nEmpresaMarcada][nFilialComposta])
    oImplantador:EnviaFornecedores()
    RpcClearEnv()
Return 

/*/{Protheus.doc} GIQ0003EFO
Função Executada por Thread para Enviar Fornecedores

@type  Function
@author brunno.costa/renan.roeder
@since 15/09/2021
@version P12.1.33

@param 01 - cJsonFornecedor, caracter, string json do fornecedor para envio ao GIQ
/*/
Function GIQ0003EFO(cJsonFornecedor)
    Local oFornecedor := JsonObject():New()
    oFornecedor:fromJson(cJsonFornecedor)
    IntegraGIQ():enviaFornecedorParaGIQ(oFornecedor)
Return
