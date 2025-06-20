#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EECAF900.CH"

#Define SEPARADOR Repl("_", 60) + Chr(13) + Chr(10)

/*
Fun��o   : EECAF900
Autor    : Rodrigo Mendes Diaz
Data     : 01/08/18
Objetivo : Cria painel para gerenciamento centralizado das parcelas de c�mbio (EEQ)
*/
Function EECAF900()
Local aCoors := FWGetDialogSize( oMainWnd )
Local oDlg, oPanel, oColumn, oLayer :=  FWLayer():new()
Local nPos
Local bFilterOri
//Quando � selecionada uma view com um filtro relacional (acessa outra tabela), o filtro anterior n�o � removido. Desta forma, caso seja selecionada uma View relacional primeiro remove a view anterior antes de aplicar
Local lAtuView := .T., bAtuView := {|| If(lAtuView .And. ValType(oBrwCambio:oBrowseUI:oViewWidget:getviewactive()) == "O" .And. aScan(aViewsRelacionais, (cId:= oBrwCambio:oBrowseUI:oViewWidget:getviewactive():cId)) > 0, (lAtuView := .F., oBrwCambio:oBrowseUI:oViewWidget:selectview("FWNOVIEW"), oBrwCambio:oBrowseUI:oViewWidget:selectview(cID), lAtuView := .T.), Nil) }
Private aViewsRelacionais := {}
Private oMarca := AF900Mark():New()
Private oBrwCambio
Private bTotaliza := {|| MsAguarde({|| Totaliza() }, STR0001) } //"Totalizando parcelas"
//Objetos dos totalizadores (devem ser private para atualiza��o posterior)
Private oMoeda, oTotaRec, oTotaLiq, oTotLiq, oTotMarcado, oTotaPag, oTotPag, oMoeMarcado
//Vari�veis com os valores a serem exibidos nos totalizadores (devem ser private para atualiza��o posterior)
Private cMoeTot := "", nTotaRec := 0, nTotaLiq := 0, nTotLiq := 0, nTotaPag := 0, nTotPag := 0, nTotMarcado := 0

// variavel de/para para os filtros
private aFilAF900 := {}

      if !avflags("PAINELCAMBIO")
            MsgStop(STR0003,STR0002) //"Necess�rio atualizar o sistema para executar essa rotina." , "Aviso"
            Return Nil
      EndIf

      //Cria a tela principal, sem bordas, t�tulos ou bot�es
      oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0004,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,) //"Painel de Opera��es de C�mbio Exporta��o"

      //Cria o objeto visual principal, que ser� divido entre browse e totais
      oLayer:Init(oDlg,.F.)
      oLayer:AddCollumn('COL_MAIN',100,.F.)
      oCol := oLayer:getColPanel ('COL_MAIN')
      
      //Define o percentual para o rodap� de acordo com o tamanho m�nimo para exibi��o dos campos: 75 pxls
      nPercBottom := (75 / oCol:nClientHeight)*100
      //Cria as divis�es entre browse e rodap�. O tamanho percentual do rodap� ser� o calculado acima e do browse ser� o espa�o restante
      oLayer:AddWindow('COL_MAIN','WIN_TOP',STR0006,100-nPercBottom,.T.,.f.) //"Parcelas de Cambio"
      oLayer:AddWindow('COL_MAIN','WIN_DOWN', STR0007,nPercBottom,.T.,.f.) //"Totais"

      //Cria o objeto do browse das parcelas na por��o superior
      oBrwCambio := FWmBrowse():New()
      oBrwCambio:SetOwner(oLayer:getWinPanel ('COL_MAIN','WIN_TOP'))
      oBrwCambio:SetDescription(STR0005) //"C�mbio - Exporta��o"
      oBrwCambio:SetAlias("EEQ")
      oBrwCambio:SetMenuDef("EECAF900")
      oBrwCambio:DisableDetails()//Desabilita a exibi��o dos detalhes do registro

      //Cria o filtro padr�o para o Browse. Devem ser exibidas todas as parcelas exceto: Adiantamentos da Fase de Cliente, Pedido e Fornencedor e c�mbio tipo 4
//      oBrwCambio:AddFilter(STR0006, "EEQ_EVENT <> '602' .And. EEQ_EVENT <> '605' .And. EEQ_EVENT <> '606' .And. EEQ_EVENT <> '609' .And. EEQ_TIPO <> 'F' .And. EEQ_TP_CON <> '3'", .T., .T.)  //"Parcelas de C�mbio" //NCF - 04/07/2019
      oBrwCambio:AddFilter(STR0006, "EEQ_EVENT <> '602' .And. EEQ_EVENT <> '605' .And. EEQ_EVENT <> '606' .And. EEQ_EVENT <> '609' .And. EEQ_TIPO <> 'F' ", .T., .T.)  //"Parcelas de C�mbio" //NCF - 04/07/2019
      aFilAF900 := {}
//      aAdd( aFilAF900 , { STR0006, "EEQ_EVENT <> '602' .And. EEQ_EVENT <> '605' .And. EEQ_EVENT <> '606' .And. EEQ_EVENT <> '609' .And. EEQ_TIPO <> 'F' .And. EEQ_TP_CON <> '3'", "EEQ_EVENT <> '602' AND EEQ_EVENT <> '605' AND EEQ_EVENT <> '606' AND EEQ_EVENT <> '609' AND EEQ_TIPO <> 'F' AND EEQ_TP_CON <> '3'"})
      aAdd( aFilAF900 , { STR0006, "EEQ_EVENT <> '602' .And. EEQ_EVENT <> '605' .And. EEQ_EVENT <> '606' .And. EEQ_EVENT <> '609' .And. EEQ_TIPO <> 'F' ", "EEQ_EVENT <> '602' AND EEQ_EVENT <> '605' AND EEQ_EVENT <> '606' AND EEQ_EVENT <> '609' AND EEQ_TIPO <> 'F' "})

      //Cria a coluna do marca/desmarca
      ADD MARKCOLUMN oColumn DATA { || If(oMarca:Marcado(EEQ->(Recno())),'LBOK','LBNO') } DOUBLECLICK {|| AF900Mark() } HEADERCLICK {|| oMarca:MarcaTodos() } OF oBrwCambio

      //Configura as legendas
      aLegendas := GetLegenda(.T.)
      aEval(aLegendas, {|x| oBrwCambio:AddLegend(x[1], x[2], x[3]) })

      //Habilita a exibi��o de vis�es e gr�ficos
      oBrwCambio:SetAttach( .T. )
      //Configura as vis�es padr�o
      oBrwCambio:SetViewsDefault(GetVisions())
      //Define a op��o de marca��o como a op��o padr�o do browse no duplo clique sobre os registros
      If (nPos := aScan(Menudef(), {|x| x[2] == "AF900MARK" })) > 0
            oBrwCambio:SetExecuteDef(nPos)
      EndIf
      //For�a a exibi��o do bot�o fechar o browse para fechar a tela
      oBrwCambio:ForceQuitButton()
      //Ativa o Browse
      oBrwCambio:Activate()

      //Cria os objetos dos totalizadores
      CriaTotalizador(oLayer:getWinPanel('COL_MAIN','WIN_DOWN'))
      //Inicializa os valores dos totalizadores
      Eval(bTotaliza)

      //Ajusta o codeblock do filtro para for�ar a execu��o do totalizador ap�s filtrar/remover filtros
      bFilterOri := oBrwCambio:oFwFilter:bFilter
      oBrwCambio:oFwFilter:setExecute(&("{ || Eval(bFilterOri), Eval(bTotaliza) }"))

      //Altera o codeblock de altera��o das vis�es para avaliar os casos de filtro relacional e executar o totalizador
      bExecVOri := oBrwCambio:oBrowseUI:oViewWidget:bRefresh
      oBrwCambio:oBrowseUI:oViewWidget:SetBRefresh(&("{|| Eval(bAtuView), Eval(bExecVOri), Eval(bTotaliza) }"))

      If EasyEntryPoint("AF900BROWSE")
            ExecBlock("AF900BROWSE", .F., .F., Nil)
      EndIf

      ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*
Fun��o     : MenuDef()
Objetivo   : Define as op��es dos bot�es do Browse
*/
Static Function MenuDef()
Local aRotina := {}
Local aRotAdic

      aAdd(aRotina, {STR0008,"AF900REC",0,4}) //"Receber no Exterior"
      aAdd(aRotina, {STR0009,"AF900LIQ",0,4}) // "Liquidar"
      aAdd(aRotina, {STR0010,"AF900EREC",0,4}) //"Estornar Recebimento no Exterior"
      aAdd(aRotina, {STR0011,"AF900ELIQ",0,4}) //"Estornar Liquida��o"
      aAdd(aRotina, {STR0012,"AF900PAG",0,4}) //"Pagar"
      aAdd(aRotina, {STR0013,"AF900EPAG",0,4}) //"Estornar Pagamento"
      aAdd(aRotina, {STR0014,"AF900ALTP",0,4}) //"Alterar Parcelas N�o Pagas/Recebidas"
      aAdd(aRotina, {STR0015,"AF900ALTE",0,4}) //"Alterar por Embarque"
      aAdd(aRotina, {STR0016,"AF900Legenda",0,4}) //"Legenda"
      aAdd(aRotina, {STR0017,"AF900MARK",0,4}) //"Marca/Desmarca"

      If EasyEntryPoint("AF900MNU")
            aRotAdic := ExecBlock("AF900MNU", .F., .F., Nil)
      EndIf

	If ValType(aRotAdic) == "A"
		aEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf

Return aRotina

/*
Fun��o     : AF900Legenda()
Objetivo   : Exibe tela com o detalhamento das legendas do browse
*/
Function AF900Legenda()
Return BrwLegenda(STR0006, STR0016, GetLegenda())//"Parcelas de C�mbio" , 'Legendas'

/*
Fun��o     : GetLegenda
Objetivo   : Retorna as op��es de legenda para o browse
Par�metro  : lFiltro - Indica se deve retornar as condi��es de filtro, al�m das informa��es das cores e t�tulos (Default Falso)
*/
Static Function GetLegenda(lFiltro)
Local aLegenda := {}
local lVarFil := isMemVar("aFilAF900")
local cFiltro := ""

Default lFiltro := .F.

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_ABERTO")
            aAdd(aLegenda[Len(aLegenda)],cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0018, cFiltro, RetFilter("REC_ABERTO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_VERDE")
      aAdd(aLegenda[Len(aLegenda)], STR0018 ) //"Aguardando Recebimento no Exterior"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_ALIQUIDAR_EMBARCADO") + " .Or. " + RetFilter("REC_ALIQUIDAR_NAOEMBARCADO")
            aAdd(aLegenda[Len(aLegenda)], cFiltro )
            if lVarFil
                  aAdd( aFilAF900 , { STR0019, cFiltro ,  RetFilter("REC_ALIQUIDAR_EMBARCADO",,.T.) + " OR " + RetFilter("REC_ALIQUIDAR_NAOEMBARCADO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_AZUL")
      aAdd(aLegenda[Len(aLegenda)], STR0019 ) //"Aguardando Contrata��o de C�mbio a Receber"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("PAG_ABERTO")
            aAdd(aLegenda[Len(aLegenda)], cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0020, cFiltro, RetFilter("PAG_ABERTO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_LARANJA")
      aAdd(aLegenda[Len(aLegenda)], STR0020 ) //"Aguardando Pagamento"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_LIQUIDADO_CAMBIO") + " .Or. " + RetFilter("PAG_FECHADO")
            aAdd(aLegenda[Len(aLegenda)], cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0021,  cFiltro,  RetFilter("REC_LIQUIDADO_CAMBIO",,.T.) + " OR " + RetFilter("PAG_FECHADO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_VERMELHO")
      aAdd(aLegenda[Len(aLegenda)], STR0021 ) //"C�mbio a Receber Contratado/Pagamento Efetuado"

      aAdd(aLegenda, {})
      If lFiltro
            cFiltro := RetFilter("REC_LIQUIDADO_ADIANTAMENTO")
            aAdd(aLegenda[Len(aLegenda)], cFiltro)
            if lVarFil
                  aAdd( aFilAF900 , { STR0022, cFiltro, RetFilter("REC_LIQUIDADO_ADIANTAMENTO",,.T.)})
            endif
      EndIf
      aAdd(aLegenda[Len(aLegenda)], "BR_PRETO")
      aAdd(aLegenda[Len(aLegenda)], STR0022 ) //"Adiantamento Liquidado em Fase de Pedido/Cliente"

Return aLegenda

/*
Fun��o     : GetVisions()
Objetivo   : Retorna as vis�es definidas para o Browse
*/
Static Function GetVisions()
Local oDSView
Local aVisions := {}
Local aColunas := AvGetCpBrw("EEQ")
Local aContextos := {"REC_ABERTO", "REC_ALIQUIDAR_EMBARCADO", "REC_ALIQUIDAR_NAOEMBARCADO", "REC_LIQUIDADO_CAMBIO", "PAG_ABERTO", "PAG_FECHADO"}
Local cFiltro
Local i
local cNomeFil := ""
local lVarFil := isMemVar("aFilAF900")

      If aScan(aColunas, "EEQ_FILIAL") == 0
            aAdd(aColunas, "EEQ_FILIAL")
      EndIf

      For i := 1 To Len(aContextos)
            cFiltro := RetFilter(aContextos[i])
            cNomeFil := RetFilter(aContextos[i], .T.)
            if lVarFil
                  aAdd( aFilAF900 , { cNomeFil, cFiltro, RetFilter(aContextos[i],,.T.)})
            endif
            If At("EEC", cFiltro) > 0//Se o filtro acionar a tabela EEC, indica que � uma view relacional
                  aAdd(aViewsRelacionais, AllTrim(Str(i)))
            EndIf
            oDSView    := FWDSView():New()
            oDSView:SetName(AllTrim(Str(i)) + "-" + cNomeFil)
            oDSView:SetPublic(.T.)
            oDSView:SetCollumns(aColunas)
            oDSView:SetOrder(1)
            oDSView:AddFilter(AllTrim(Str(i)) + "-" + cNomeFil, cFiltro)
            oDSView:SetID(AllTrim(Str(i)))
            oDsView:SetLegend(.T.)
            aAdd(aVisions, oDSView)
      Next

Return aVisions

/*
Fun��o   : CriaTotalizador(oLayer)
Objetivo : Criar os objetos com os totalizadores da tela
Par�metro: oPanel - Painel onde os objetos ser�o criados
*/
Static Function CriaTotalizador(oPanel)
Local cPicVal := AvSx3("EEQ_VL", AV_PICTURE)
Local nCol :=2, nLine := 2

      @ nLine, nCol SAY STR0023 of oPanel Pixel SIZE 30,08 //"Moeda:"
      nCol += 20
      @ nLine-1, nCol ComboBox oMoeda VAR cMoeTot Items GetMoedas() Size 35, 08 OF oPanel On Change Eval(bTotaliza) Pixel
      nCol += 37
      @ nLine, nCol SAY STR0024 of oPanel Pixel SIZE 30,08 //"A Receber"
      nCol += 28
      @ nLine-1, nCol MSGET oTotaRec Var nTotaRec SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0025 of oPanel Pixel SIZE 30,08 //"A Liquidar"
      nCol += 28
      @ nLine-1, nCol MSGET oTotaLiq Var nTotaLiq SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0026 of oPanel Pixel SIZE 30,08 //"Liquidado"
      nCol += 28
      @ nLine-1, nCol MSGET oTotLiq Var nTotLiq SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0027 of oPanel Pixel SIZE 30,08 //"A Pagar"
      nCol += 25
      @ nLine-1, nCol MSGET oTotaPag Var nTotaPag SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0028 of oPanel Pixel SIZE 30,08 //"Pago"
      nCol += 20
      @ nLine-1, nCol MSGET oTotPag Var nTotPag SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY
      nCol += 52
      @ nLine, nCol SAY STR0029 of oPanel Pixel SIZE 30,08 //"Marcados"
      nCol += 28
      @ nLine, nCol SAY oMoeMarcado VAR oMarca:cMoeda of oPanel Pixel SIZE 30,08
      nCol += 18
      @ nLine-1, nCol MSGET oTotMarcado Var nTotMarcado SIZE 50,08 Picture cPicVal Pixel of oPanel READONLY

Return Nil

/*
Fun��o   : GetMoedas()
Objetivo : Retorna array com todos os c�digos de moedas dispon�veis entre as parcelas de c�mbio da tabela EEQ
*/
Static Function GetMoedas()
Local aMoedas := {""}
Local nPos

      BeginSql Alias "MOEDAS"
            Select EEQ_MOEDA From %table:EEQ% Where %NotDel% Group By EEQ_MOEDA
      EndSql
      While MOEDAS->(!Eof())
            aAdd(aMoedas, MOEDAS->EEQ_MOEDA)
            MOEDAS->(DbSkip())
      EndDo
      MOEDAS->(DbCloseArea())
      //Seta a var�avel do combobox do filtro de moedas com a moeda dolar caso exista alguma parcela nesta moeda. Caso negativo, considera a primeira moeda encontrada.
      If Len(aMoedas) > 0
            If (nPos := aScan(aMoedas, {|x| AllTrim(x) == "US$" })) > 0
                  cMoeTot := aMoedas[nPos]
            Else
                  cMoeTot := aMoedas[1]
            EndIf
      EndIf

Return aMoedas

/*
Fun��o     : Totaliza()
Objetivo   : Totaliza os valores da parcelas para exibi��o na barra de totais
*/
Static Function Totaliza()
local aOrd      := SaveOrd("EEQ")
local cQuery    := ""
local cAliasQry := ""
local oQuery    := nil
local aFilter   := {}
local nFilter   := 0

nTotaRec := 0
nTotaLiq := 0
nTotLiq  := 0
nTotaPag := 0
nTotPag  := 0

if !empty(cMoeTot)
      cQuery := " SELECT "
      cQuery += " SUM ( CASE WHEN ( ( EEQ_TIPO = 'R' OR EEQ_TIPO = 'A' ) AND EEQ_DTCE = ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotaRec, "
      cQuery += " SUM ( CASE WHEN ( ( EEQ_TIPO = 'R' OR EEQ_TIPO = 'A' ) AND EEQ_DTCE <> ' ' AND EEQ_PGT = ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotaLiq, "
      cQuery += " SUM ( CASE WHEN ( ( EEQ_TIPO = 'R' OR EEQ_TIPO = 'A' ) AND EEQ_DTCE <> ' ' AND EEQ_PGT <> ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotLiq, "
      cQuery += " SUM ( CASE WHEN ( EEQ_TIPO = 'P' AND EEQ_PGT =  ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotaPag, "
      cQuery += " SUM ( CASE WHEN ( EEQ_TIPO = 'P' AND EEQ_PGT <> ' ' ) THEN (EEQ_VL - EEQ_CGRAFI + EEQ_ACRESC - EEQ_DECRES + EEQ_MULTA + EEQ_JUROS - EEQ_DESCON) ELSE 0 END ) TotPag "
      cQuery += " FROM " + RetSqlName('EEQ') + " EEQ "
      cQuery += " LEFT JOIN " + RetSqlName('EEC') + " EEC ON  EEC.D_E_L_E_T_ = ' ' AND EEC_FILIAL = EEQ_FILIAL AND EEC_PREEMB = EEQ_PREEMB " 
      cQuery += " WHERE EEQ.D_E_L_E_T_ = ' ' AND EEQ_MOEDA = ? " 

      if isMemVar("oBrwCambio") .and. len(oBrwCambio:oFWFilter:aFilter) > 0
            aFilter := aClone( oBrwCambio:oFWFilter:aFilter ) //:GetFilter()
      endif
 
      for nFilter := 1 to len(aFilter)
            // filtros selecionados
            if aFilter[nFilter][6]
                  cQuery += TrataWhere( nFilter, aFilter[nFilter])
            endif
      next

      oQuery := FWPreparedStatement():New(cQuery)
      oQuery:SetString(1,cMoeTot)
      cQuery := oQuery:GetFixQuery()

      cAliasQry := getNextAlias()
      MPSysOpenQuery(cQuery, cAliasQry)

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
            nTotaRec := (cAliasQry)->TotaRec
            nTotaLiq := (cAliasQry)->TotaLiq
            nTotLiq  := (cAliasQry)->TotLiq
            nTotaPag := (cAliasQry)->TotaPag
            nTotPag  := (cAliasQry)->TotPag
      endif
      (cAliasQry)->(dbCloseArea())

      oQuery:Destroy()
      FwFreeObj(oQuery)
endif

RestOrd(aOrd, .T.)

oTotaRec:Refresh()
oTotaLiq:Refresh()
oTotLiq:Refresh()
oTotaPag:Refresh()
oTotPag:Refresh()

Return Nil

static function TrataWhere(nFilter, aFilter)
      local cRet       := ""
      local lVarFil    := isMemVar("aFilAF900")
      local nPos       := 0
      local cNomeFil   := ""
      local cFilADVPL  := ""
      local nPosFil    := 0
      local cExpr      := ""
      local nPosIni    := 0
      local nPosFim    := 0
      local cFunExp    := ""
      local cFunExpRun := ""
      local nPosField  := 0
      local nPosOper   := 0
      local nPosExpr   := 0
      local cField     := ""
      local cOper      := ""
      local cExpres    := ""
      local cExpNew    := ""
      local cIN        := ""
      local aInfIN     := {}
      local nIn        := 0
      local nOper      := 0
      local cOR_AND    := ""
      local aExpres    := {}
      local aFiltro    := {}
      local nFiltro    := 0
      local cFiltro    := ""
      local lAddCond   := .F.
      local cTipoCpo   := ""

      default nFilter   := 0 
      default aFilter   := {}

      cNomeFil := alltrim( substr( aFilter[1], at("-", aFilter[1]) + 1) )
      cFilADVPL := alltrim( StrTran(aFilter[2],"!=", "<>") )

      // filtros padr�es do sistema
      if lVarFil .and. ( nPos := aScan( aFilAF900, { |X| cNomeFil == alltrim(X[1]) .and. alltrim(X[2]) == cFilADVPL}) ) > 0
            cRet := " AND ( " + aFilAF900[nPos][3] + " ) "
      elseif len(aFilter) > 0
            // filtro com pergunte
            if aFilter[7] .and. ( nPosFil := aScan( oBrwCambio:oFWFilter:aObjFilAsk , { |X| X[1]:cProfielId == cValToChar(nFilter) } ) ) > 0
                  cFiltro := oBrwCambio:oFWFilter:aObjFilAsk[nPosFil,1]:cExpression
                  aFiltro := oBrwCambio:oFWFilter:aObjFilAsk[nPosFil,2]
            else
                  cFiltro := if( empty(aFilter[3]), aFilter[2], aFilter[3])
                  aFiltro := aFilter[4]
            endif

            if len(aFiltro) > 0 .and. !empty(cFiltro)

                  nPosField := aScan( aFiltro , { |X| X[2] == "FIELD"} )
                  nPosOper := aScan( aFiltro , { |X| X[2] == "OPERATOR"} )
                  nPosExpr := aScan( aFiltro , { |X| X[2] == "EXPRESSION"} )
                  cField := if( nPosField == 0, "", aFiltro[nPosField][1])
                  cExpres := if( nPosExpr == 0, "", aFiltro[nPosExpr][1])
                  cOper := if(nPosOper == 0, "", aFiltro[nPosOper][1])
                  nOper := aScan( aFiltro , { |X| empty(X[2])})
                  cExpNew := ""
                  aExpres := {}
                  cExpr := cFiltro
                  cFiltro := "" 

                  while nPosOper > 0
                        lAddCond := .F.
                        cTipoCpo := if( !empty(cField), getSX3Cache(cField,"X3_TIPO"), "")
                        if  cTipoCpo == "C" .and. (( cOper == '$' ) .or. ( cOper == '!x' ) .or. ( cOper == '..' ) .or. ( cOper == '!.' ))
                              cExpres := if( len(aFiltro[nPosExpr]) > 5 .and. !aFiltro[nPosExpr][6], upper(aFiltro[nPosExpr][1]), aFiltro[nPosExpr][1])
                              cExpNew := "("
                              if (( cOper == '$' ) .or. ;// Esta contido
                              ( cOper == '!x' ) )// Nao Esta contido
                                    aInfIN := StrTokArr(AllTrim(cExpres), ',')
                                    cIN := ""
                                    for nIn := 1 to len(aInfIN)              
                                          cIN += if( !empty(aInfIN[nIn]), "'" + aInfIN[nIn] + "',",  "")
                                    next nIn
                                    cIN := SubStr(cIN, 1, len(cIN)-1)
                                    cIN := if(empty(cIN), "''", cIN)
                                    if !empty(cIN)
                                          cExpNew += cField + if( cOper == '$' , " IN(" + cIN + ")" ,  " NOT IN(" + cIN + ")")
                                    endif
                              elseif (( cOper == '..' ) .or. ; // Contem a expressao
                                    ( cOper == '!.' ))// Nao Contem a expressao
                                    cExpNew += cField + if( ( cOper == '..' ) , " LIKE " , " NOT LIKE ") + "'%" + if( empty(cExpres) , cExpres,  alltrim(cExpres)) + "%'"
                              endif
                              cExpNew += ")"
                              lAddCond := .T.
                              aAdd( aExpres, cExpNew )
                        elseif cTipoCpo == "D" // !(cOper == '$') .and. !(cOper == '!x') .and. !(cOper == '..') .and. !(cOper == '!.')
                              nPosIni := at("#", cExpr )
                              nPosFim := at("#", cExpr,  nPosIni + 1)
                              while nPosIni > 0 .and. nPosFim > 0
                                    cFunExp := substr( cExpr, nPosIni, nPosFim - nPosIni + 1)
                                    if !empty( cFunExp )
                                          cFunExpRun := &(StrTran( cFunExp, "#", ""))
                                          cFunExpRun := StrTran( StrTran( upper( cFunExpRun ) , "DTOS", ""), "DTOC", "")
                                          lAddCond := .T.
                                          aAdd( aExpres, cFunExpRun)
                                    endif
                                    nPosIni := at("#", cExpr, nPosFim + 1 )
                                    nPosFim := at("#", cExpr, nPosIni + 1 )
                              end
                        else
                              cExpNew := "("
                              cExpNew += cField + " " + cOper + " "
                              cExpNew += if( cTipoCpo == "C" , "'" + cExpres + "'" , if( cTipoCpo == "D" ,  "'" + DTOS(cExpres) + "'" , cValTochar(cExpres)))
                              cExpNew += ")"
                              lAddCond := .T.
                              aAdd( aExpres, cExpNew )
                        endif

                        if nOper > 0 .and. lAddCond
                              cOR_AND := StrTran( StrTran( aFiltro[nOper][1] , ".AND.", "AND") , ".OR.", "OR" )
                              aAdd( aExpres, cOR_AND )
                        endif

                        nPosField := aScan( aFiltro , { |X| X[2] == "FIELD"}, nPosField + 1 )
                        nPosOper := aScan( aFiltro , { |X| X[2] == "OPERATOR"}, nPosOper + 1 )
                        nPosExpr := aScan( aFiltro , { |X| X[2] == "EXPRESSION"}, nPosExpr + 1 )
                        nOper := aScan( aFiltro , { |X| empty(X[2])}, nOper + 1 )
                        cField := if( nPosField == 0, "", aFiltro[nPosField][1])
                        cExpres := if( nPosExpr == 0, "", aFiltro[nPosExpr][1])
                        cOper := if(nPosOper == 0, "", aFiltro[nPosOper][1])

                  end

                  if len(aExpres) > 0
                        for nFiltro := 1 to len(aExpres)
                              cFiltro += aExpres[nFiltro]
                        next
                  endif
            endif
            if !empty(cFiltro)
                  cRet := " AND ( " + StrTran( StrTran( StrTran( StrTran( StrTran( StrTran( cFiltro , '"', "'" ), "==", "=" ) , ".AND.", "AND") , ".OR.", "OR" ), "ALLTRIM", ""), "!=", "<>") + " ) "
            endif
      endif

return cRet

/*
Fun��o     : RetFilter(cTipo)
Objetivo   : Retorna a chave ou nome do filtro da tabela EEQ de acordo com o contexto desejado
Par�metros : cTipo - C�digo do Contexto
             lNome - Indica que deve ser retornado o nome correspondente ao filtro (default .f.)
*/
Static Function RetFilter(cTipo, lNome, lExpSQL)
Local cRet := ""
Default lNome := .F.
default lExpSQL := .F.

      Do Case
            Case cTipo == "REC_ABERTO" .And. lExpSQL
                  cRet := "EEQ_TIPO <> 'P' AND EEQ_DTCE = ' '"
            Case cTipo == "REC_ABERTO" .And. !lNome
                  cRet := "EEQ->EEQ_TIPO <> 'P' .And. Empty(EEQ->EEQ_DTCE)"
            Case cTipo == "REC_ABERTO" .And. lNome
                  cRet := STR0084 //"Parcelas a Receber"

            Case cTipo == "REC_ALIQUIDAR_EMBARCADO" .And. lExpSQL
                  cRet := "(EEQ_TIPO = 'R' OR (EEQ_TIPO = 'A' AND EEQ_MODAL = '2')) AND EEQ_DTCE <> ' ' AND EEQ_PGT = ' ' AND EEC_DTEMBA <> ' ' "
            Case cTipo == "REC_ALIQUIDAR_EMBARCADO" .And. !lNome
                  cRet := "(EEQ->EEQ_TIPO == 'R' .Or. (EEQ->EEQ_TIPO == 'A' .And. EEQ->EEQ_MODAL == '2')) .And. !Empty(EEQ->EEQ_DTCE) .And. Empty(EEQ->EEQ_PGT) .And. !Empty(Posicione('EEC', 1, EEQ->(EEQ_FILIAL+EEQ_PREEMB), 'EEC_DTEMBA'))"
            Case cTipo == "REC_ALIQUIDAR_EMBARCADO" .And. lNome
                  cRet := STR0085 // "Parcelas a Receber n�o Liquidadas - Processo Embarcado"

            Case cTipo == "REC_ALIQUIDAR_NAOEMBARCADO" .And. lExpSQL
                  cRet := "(EEQ_TIPO = 'R' OR (EEQ_TIPO = 'A' AND EEQ_MODAL = '2')) AND EEQ_DTCE <> ' ' AND EEQ_PGT = ' ' AND EEC_DTEMBA = ' ' "
            Case cTipo == "REC_ALIQUIDAR_NAOEMBARCADO" .And. !lNome
                  cRet := "(EEQ->EEQ_TIPO == 'R' .Or. (EEQ->EEQ_TIPO == 'A' .And. EEQ->EEQ_MODAL == '2')) .And. !Empty(EEQ->EEQ_DTCE) .And. Empty(EEQ->EEQ_PGT) .And. Empty(Posicione('EEC', 1, EEQ->(EEQ_FILIAL+EEQ_PREEMB), 'EEC_DTEMBA'))"
            Case cTipo == "REC_ALIQUIDAR_NAOEMBARCADO" .And. lNome
                  cRet := STR0086 // "Parcelas a Receber n�o Liquidadas - Processo N�o Embarcado"

            Case cTipo == "REC_LIQUIDADO_CAMBIO" .And. lExpSQL
                  cRet := "(EEQ_TIPO = 'R' OR (EEQ_TIPO = 'A' AND EEQ_MODAL = '2')) AND EEQ_DTCE <> ' ' AND EEQ_PGT <> ' ' "
            Case cTipo == "REC_LIQUIDADO_CAMBIO" .And. !lNome
                  cRet := "(EEQ->EEQ_TIPO == 'R' .Or. (EEQ->EEQ_TIPO == 'A' .And. EEQ->EEQ_MODAL == '2')) .And. !Empty(EEQ->EEQ_DTCE) .And. !Empty(EEQ->EEQ_PGT)"
            Case cTipo == "REC_LIQUIDADO_CAMBIO" .And. lNome
                  cRet := STR0087 // "Parcelas a Receber Liquidadas"

            Case cTipo == "REC_LIQUIDADO_ADIANTAMENTO" .And. lExpSQL
                  cRet := "EEQ_TIPO = 'A' AND EEQ_MODAL = '1' AND EEQ_DTCE <> ' ' AND EEQ_PGT <> ' ' "
            Case cTipo == "REC_LIQUIDADO_ADIANTAMENTO" .And. !lNome
                  cRet := "EEQ->EEQ_TIPO == 'A' .And. EEQ->EEQ_MODAL == '1' .And. !Empty(EEQ->EEQ_DTCE) .And. !Empty(EEQ->EEQ_PGT)"
            Case cTipo == "REC_LIQUIDADO_ADIANTAMENTO" .And. lNome
                  cRet := STR0088 // "Adiantamento Liquidado em Fase de Pedido/Cliente"

            Case cTipo == "PAG_ABERTO" .And. lExpSQL
                  cRet := "EEQ_TIPO = 'P' AND ((EEQ_MODAL = ' ' AND EEQ_PGT = ' ') OR (EEQ_TP_CON <> '4' AND EEQ_PGT = ' ') OR (EEQ_TP_CON = '4' AND ((EEQ_MODAL = '1' AND EEQ_PGT = ' ') OR (EEQ_MODAL = '2' AND EEQ_DTCE = ' '))))"
            Case cTipo == "PAG_ABERTO" .And. !lNome
                  cRet := "EEQ->EEQ_TIPO == 'P' .And. ((Empty(EEQ->EEQ_MODAL) .And. Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON <> '4' .And. Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON == '4' .And. ((EEQ->EEQ_MODAL == '1' .And. Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_MODAL == '2' .And. Empty(EEQ->EEQ_DTCE)))))"
            Case cTipo == "PAG_ABERTO" .And. lNome
                  cRet := STR0089 // "Parcelas a Pagar"

            Case cTipo == "PAG_FECHADO" .And. lExpSQL
                  cRet := "EEQ_TIPO = 'P' AND ((EEQ_MODAL = ' ' AND EEQ_PGT <> ' ') OR (EEQ_TP_CON <> '4' AND EEQ_PGT <> ' ') OR (EEQ_TP_CON = '4' AND ((EEQ_MODAL = '1' AND EEQ_PGT <> ' ') OR (EEQ_MODAL = '2' AND EEQ_DTCE <> ' '))))"
            Case cTipo == "PAG_FECHADO" .And. !lNome
                  cRet := "EEQ->EEQ_TIPO == 'P' .And. ((Empty(EEQ->EEQ_MODAL) .And. !Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON <> '4' .And. !Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_TP_CON == '4' .And. ((EEQ->EEQ_MODAL == '1' .And. !Empty(EEQ->EEQ_PGT)) .Or. (EEQ->EEQ_MODAL == '2' .And. !Empty(EEQ->EEQ_DTCE)))))"
            Case cTipo == "PAG_FECHADO" .And. lNome
                  cRet := STR0090 // "Parcelas a Pagar - Liquidadas ou Pagas no Exterior"

      EndCase

Return cRet

/*
Classe  : AF900Mark
Objetivo: Gerenciar a marca��o das parcelas no browse de c�mbio
Autor   : Rodrigo Mendes Diaz
Data    : 01/08/18
*/
Class AF900Mark

      Data aParcelas
      Data nTotal
      Data cMoeda
      Data aSoftLock
      Data cNrOp
      Data lNrOpEFF

      Method New() Constructor
      Method Marca()
      Method Desmarca()
      Method MarcaTodos()
      Method Marcado()
      Method LenMarcados()
      Method GetMoeda()
      Method SetMoeda(cCodMoeda)
      Method GetNrOp()
      Method SetNrOp(cNrOp)
      Method Valida()
      Method GetMarcados()
      Method PossuiParcela()
      Method ReservaRegistros()
      Method LiberaRegistros()
      Method SetParcela(nRecParc, cTipo, nValor)
      Method SetContratoEFF()
      Method isContratoEFF()
      Method MarkAllEFF()

EndClass

/*
M�todo    : New()
Classe    : AF900Mark
Objetivo  : Construtor da Classe
*/
Method New() Class AF900Mark

      Self:nTotal    := 0
      Self:aParcelas := {}
      Self:cMoeda    := ""
      Self:aSoftLock := {}
      Self:lNrOpEFF  := .F.

Return Self

/*
M�todo    : Marca(nRec, lRefresh)
Classe    : AF900Mark
Objetivo  : Marca a parcela, validando antes se a parcela � da mesma moeda das parcelas j� marcadas
Par�metros: nRec - Recno a ser marcado
            lAtuStatus - Quando chamado ap�s a integra��o da parcela, para que seja atualizado o Tipo (Status) da aprcela. � chamado um desmarca e um marca em seguida
            lRefresh - Indica se ser� efetuado o refresh do browse principal
*/
Method Marca(nRec, lRefresh, lAtuStatus) Class AF900Mark
Local lRet := .F.
Local cTipo := ""
Local cSolucao := ""
Default lAtuStatus := .F.

Begin Sequence
      If EEQ->(Recno()) <> nRec
            EEQ->(DbGoTo(nRec))
      EndIf

      If Self:GetNrOp() == Nil
             Self:SetNrOp(EEQ->EEQ_NROP)
      ElseIf Self:GetNrOp() <> EEQ->EEQ_NROP
            EasyHelp(STR0091,STR0002,STR0092)//"N�o � poss�vel marcar parcelas que possuem N�mero de Opera��o diferentes."###"Devem ser marcadas parcelas com o mesmo N�mero de Opera��o."
            Break
      EndIf

      If !lAtuStatus .And. Self:LenMarcados() > 0 .And. ((Self:isContratoEFF() .And. !IsContrEFF()) .Or. (!Self:isContratoEFF() .And. IsContrEFF()))
            If Self:isContratoEFF()
                  cSolucao := STR0095 + Alltrim(Self:GetNrOp()) + STR0096 //"Devem ser marcadas parcelas que possuem v�nculo com contrato de Financiamento "####" no Easy Financing (SIGAEFF)." 
            Else
                  cSolucao := STR0097//"Devem ser marcadas parcelas que n�o possuem v�nculo com contrato de Financiamento no Easy Financing (SIGAEFF)."
            EndIf
            EasyHelp(STR0098,STR0002,cSolucao)//"N�o � poss�vel marcar parcelas que est�o vinculadas a um contrato de Financiamento com parcelas que n�o possuem o vinculo."###""
            Break
      EndIf 

      If Empty(Self:GetMoeda())
            Self:SetMoeda(EEQ->EEQ_MOEDA)
      ElseIf Self:GetMoeda() <> EEQ->EEQ_MOEDA
            If MsgYesNo( STR0030,STR0002 ) //"A parcela selecionada � de uma moeda diferente das parcelas j� marcadas. Deseja demarcar as parcelas j� marcadas para prosseguir?", "Aviso"
                  Self:SetMoeda(EEQ->EEQ_MOEDA)
            EndIf
      EndIf

      If Self:GetMoeda() == EEQ->EEQ_MOEDA
            Do Case
                  Case &(RetFilter("REC_ABERTO"))
                        cTipo := "REC_ABERTO"
                  Case &(RetFilter("REC_ALIQUIDAR_EMBARCADO"))
                        cTipo := "REC_ALIQUIDAR_EMBARCADO"
                  Case &(RetFilter("REC_ALIQUIDAR_NAOEMBARCADO"))
                        cTipo := "REC_ALIQUIDAR_NAOEMBARCADO"
                  Case &(RetFilter("REC_LIQUIDADO_CAMBIO"))
                        cTipo := "REC_LIQUIDADO_CAMBIO"
                  Case &(RetFilter("REC_LIQUIDADO_ADIANTAMENTO"))
                        cTipo := "REC_LIQUIDADO_ADIANTAMENTO"
                  Case &(RetFilter("PAG_ABERTO"))
                        cTipo := "PAG_ABERTO"
                  Case &(RetFilter("PAG_FECHADO"))
                        cTipo := "PAG_FECHADO"
            EndCase
            
            //Caso seja a primeira parcela marcada, tenha integra��o com SIGAEFF Habilitada e parcela possua contrato do EFF vinculada
            If !lAtuStatus .And. Self:LenMarcados() == 0 .And. EasyGParam("MV_EEC_EFF",,.F.) .And. !Empty(Self:GetNrOp()) .And. IsContrEFF()
                  lRet := Self:MarkAllEFF(EEQ->(Recno()), cTipo, RetFilter(cTipo,,.T.), Self:GetNrOp(), IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E"), EEQ->EEQ_BANC) //Verifica se ir� marcar todas as parcelas do mesmo contrato
            Else
                  //aAdd(Self:aParcelas, {EEQ->(Recno()), cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON})
                  Self:SetParcela(EEQ->(Recno()), cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)
                  lRet := .T.
            EndIf
      EndIf
      If lRet
            nTotMarcado := Self:nTotal
            oTotMarcado:Refresh()
            oMoeMarcado:Refresh()
      EndIf
      If lRefresh
            oBrwCambio:Refresh()
      EndIf

End Sequence
Return lRet

/*
M�todo    : Desmarca(nRec, lRefresh)
Classe    : AF900Mark
Objetivo  : Desmarca a parcela
Par�metros: nRec - Recno a ser desmarcado
            lRefresh - Indica se ser� efetuado o refresh do browse principal
*/
Method Desmarca(nRec, lRefresh) Class AF900Mark
Local nPos

      If (nPos := aScan(Self:aParcelas, {|x| x[1] == nRec })) > 0
            Self:nTotal -= Self:aParcelas[nPos][3]
            aDel(Self:aParcelas, nPos)
            aSize(Self:aParcelas, Len(Self:aParcelas)-1)
      EndIf
      If Empty(Self:aParcelas)
            Self:SetMoeda("")
            Self:SetNrOp(Nil)
            Self:SetContratoEFF(.F.)
      EndIf
      nTotMarcado := Self:nTotal
      oTotMarcado:Refresh()
      oMoeMarcado:Refresh()
      If lRefresh
            oBrwCambio:LineRefresh()
      EndIf

Return .T.

/*
M�todo    : PossuiParcela(cTipo)
Classe    : AF900Mark
Objetivo  : Verifica se existe alguma parcela marcada do tipo informado
Par�metro : cTipo - C�digo do tipo de parcela
*/
Method PossuiParcela(cTipo) Class AF900Mark
Return aScan(Self:aParcelas, {|x| x[2] $ cTipo }) > 0

/*
M�todo    : Marcado(nRecno)
Classe    : AF900Mark
Objetivo  : Retorna .t./.f. caso o recno informado esteja marcado
Par�metro : nRecno - Recno do registro da tabela EEQ a ser verificado
*/
Method Marcado(nRecno) Class AF900Mark
Return aScan(Self:aParcelas, {|x| x[1] == nRecno}) > 0

/*
M�todo    : GetMarcados()
Classe    : AF900Mark
Objetivo  : Retorna c�pia do array com as parcelas marcadas
*/
Method GetMarcados() Class AF900Mark
Return aClone(Self:aParcelas)

/*
M�todo    : LenMarcados()
Classe    : AF900Mark
Objetivo  : Retorna a quantidade de parcelas marcadas
*/
Method LenMarcados() Class AF900Mark
Return Len(Self:aParcelas)

/*
M�todo    : GetMoeda()
Classe    : AF900Mark
Objetivo  : Retorna a moeda definida como padr�o para marca��o
*/
Method GetMoeda() Class AF900Mark
Return Self:cMoeda

/*
M�todo    : SetMoeda(cCodMoeda)
Classe    : AF900Mark
Objetivo  : Define a moeda para valida��o das parcelas a serem marcadas
Par�metros: cCodMoeda - C�digo da moeda
*/
Method SetMoeda(cCodMoeda) Class AF900Mark
      If Self:cMoeda <> cCodMoeda
            If Self:LenMarcados() > 0//Caso tenha mudado a moeda e existam parcelas marcadas, desmarca estas parcelas
                  Self:MarcaTodos(.T.,, .F.)
            EndIf
            Self:cMoeda := cCodMoeda
      EndIf
Return Self:cMoeda


/*
M�todo    : GetNrOp()
Classe    : AF900Mark
Objetivo  : Retorna o Numero da Operacao (EEQ_NROP) definida como padr�o para marca��o
*/
Method GetNrOp() Class AF900Mark
Return Self:cNrOp

/*
M�todo    : SetNrOp(cNrOp)
Classe    : AF900Mark
Objetivo  : Define o n�mero de opera��o (EEQ_NROP) para valida��o das parcelas a serem marcadas
Par�metros: cNrOp - C�digo da Opera��o
*/
Method SetNrOp(cNrOp) Class AF900Mark
      If Self:cNrOp <> cNrOp
            Self:cNrOp := cNrOp
            If cNrOp <> nil .And. IsContrEFF()
                  Self:SetContratoEFF(.T.)
            EndIf
      EndIf
Return Self:cNrOp

/*
M�todo    : MarcaTodos(lDesmarca, cNaoDesmarca, lRefresh)
Classe    : AF900Mark
Objetivo  : Efetua a marca��o ou desmarca��o de todas as parcelas da mesma moeda (j� definida anteriomente no atributo cMoeda).
Par�metros: lDesmarca - Indica que ser� feita a desmarca��o (default - marca��o)
            cNaoDesmarca - Se informado, n�o ser�o desmarcadas parcelas do c�digo de a��o informado
            lRefresh - Indica se ser� feito o refresh do browse
*/
Method MarcaTodos(lDesmarca, cNaoDesmarca, lRefresh) Class AF900Mark
Local aOrd, nPos
Local lMV_EECEFF := EasyGParam("MV_EEC_EFF",,.F.)

Default lDesmarca := !Empty(Self:aParcelas)
Default cNaoDesmarca := ""
Default lRefresh := .T.

      If lDesmarca
            If Empty(cNaoDesmarca)
                  Self:aParcelas := {}
                  Self:nTotal := 0
                  Self:SetMoeda("")
                  Self:SetNrOp(Nil)
                  Self:SetContratoEFF(.F.)
            Else
                  While (nPos := aScan(Self:aParcelas, {|x| !(x[2] $ cNaoDesmarca) })) > 0
                        Self:nTotal -= Self:aParcelas[nPos][3]
                        aDel(Self:aParcelas, nPos)
                        aSize(Self:aParcelas, Len(Self:aParcelas)-1)
                  EndDo
            EndIf
      Else
            If Empty(Self:GetMoeda())
                  Self:SetMoeda(EEQ->EEQ_MOEDA)
            EndIf
            If Self:GetNrOp() == Nil
                  Self:SetNrOp(EEQ->EEQ_NROP)
            EndIf
            aOrd := SaveOrd("EEQ")
            EEQ->(DbGoTop())
            While EEQ->(!Eof())
                  If EEQ->EEQ_MOEDA == Self:GetMoeda() .And. EEQ->EEQ_NROP == Self:GetNrOp() .And. (!lMV_EECEFF .Or. ((Self:isContratoEFF() .And. IsContrEFF()) .Or. (!Self:isContratoEFF() .And. !IsContrEFF())))
                        Self:Marca(EEQ->(Recno()), .F.,.T.)
                  EndIf
                  EEQ->(DbSkip())
            EndDo
            RestOrd(aOrd, .T.)
      EndIf
      nTotMarcado := Self:nTotal
      oTotMarcado:Refresh()
      oMoeMarcado:Refresh()
      If lRefresh
            oBrwCambio:Refresh()
      EndIf

Return Nil

/*
M�todo   : Valida(cAcao)
Classe   : AF900Mark
Objetivo : Valida se as parcelas marcadas correspondem � a��o desejada.
           Caso n�o existam parcelas marcadas do tipo desejado, exibe mensagem e retorna falso.
           Caso existam parcelas marcadas do tipo desejado mas tamb�m existam parcelas de outros tipos, pergunta se o usu�rio desejam que 
           sejam desmarcadas automaticamente estas parcelas, e somente retorna true caso ele confirme.
Par�metro: cAcao - C�digo da A��o a ser validada
*/
Method Valida(cAcao) Class AF900Mark
Local lRet := .T.
Local lOkTipo := .F.
Local lTipoDiferente := .F.
Local aAcoes := StrTokArr(cAcao, "|")
Local cMsgTipo := ""
Local aTiposErro := {}, cMsgTiposErro := ""
Local bAddErro := {|x| If(aScan(aTiposErro, x) == 0, aAdd(aTiposErro, x), Nil) }

      aEval(aAcoes, {|x| cMsgTipo += If(!Empty(cMsgTipo), " ou ", "") + "'" + RetFilter(x, .T.) + "'" })

      If Self:LenMarcados() == 0
            EasyHelp( STR0031 + ENTER + StrTran( STR0032 , "XXX", cMsgTipo) , STR0002 ) // "N�o foram identificadas parcelas marcadas." + ENTER + "Efetue a marca��o de ao menos uma parcela do tipo correspondente a XXX para continuar." , "Aviso"
            lRet := .F.
      Else
            aEval(Self:aParcelas, {|x| if(!(x[2] $ cAcao), Eval(bAddErro, x[2]), ) })
            aEval(aTiposErro, {|x| cMsgTiposErro += RetFilter(x, .T.) + ENTER })
            If aScan(Self:aParcelas, {|x| x[2] $ cAcao }) == 0
                  EasyHelp( STR0033 + ENTER + StrTran( STR0034 , "XXX", cMsgTipo) + ENTER + ENTER;
                                 + STR0035 + ENTER +;
                                 cMsgTiposErro, STR0002 ) // "N�o foi marcada nenhuma parcela do tipo correspondente � a��o selecionada." + ENTER + "Efetue a marca��o de ao menos uma parcela com o tipo correspondente a XXX para continuar." + ENTER + "Somente foram identificadas parcelas marcadas com os tipos abaixo, que s�o inv�lidos para a opera��o desejada:" , "Aviso"
                  lRet := .F.
            EndIf
            If lRet .And. Len(cMsgTiposErro) > 0
                  If lRet := MsgYesNo( STR0036 + ENTER;
                           + cMsgTiposErro + ENTER;
                           + STR0037 , STR0002 ) // "Foram marcadas parcelas dos tipos:" + +  "Estes tipos de parcela s�o inv�lidos para a opera��o desejada e ser�o desmarcados automaticamente ao confirmar. Deseja continuar?", "Aviso"
                        Self:MarcaTodos(.T., cAcao, .F.)
                  EndIf
            EndIf
      EndIf

Return lRet

/*
M�todo    : ReservaRegistros()
Classe    : AF900Mark
Objetivo  : Efetua o Softlock dos processos de embarque envolvidos nas parcelas que ser�o atualizadas. Caso o processo esteja travado, exibe mensagem informando 
            quais s�o os processos e perguntando se deseja aguardar ou cancelar.
Par�metros: aParcelas - Array com o Recno das parcelas do EEQ que devem ter os processos travados.
*/
Method ReservaRegistros() Class AF900Mark
Local aOrd := SaveOrd({"EEQ", "EEC"})
Local aErroTrava := {}
Local i
Local lAborta := .F.
Local cMensagem

      EEC->(DbSetOrder(1))
      For i := 1 to Len(Self:aParcelas)
            EEQ->(DbGoTo(Self:aParcelas[i][1]))
            If !(EEQ->EEQ_TP_CON $ "3|4") .And. EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
                  If !EEC->(SimpleLock() .And. SoftLock("EEC"))
                        aAdd(aErroTrava, {"EEC", EEC->(Recno()), STR0038 + AllTrim(EEC->EEC_FILIAL) + STR0039 + AllTrim(EEC->EEC_PREEMB)}) // "Filial: " // " Embarque: "
                  Else
                        aAdd(Self:aSoftLock, {"EEC", EEC->(Recno())})
                  EndIf
            EndIf
      Next

      While !lAborta .And. Len(aErroTrava) > 0
            cMensagem := STR0040 + ENTER //"O seguintes processos de embarque est�o bloqueados por outro acesso ou usu�rio:"
            aEval(aErroTrava, {|x| cMensagem += x[3] + ENTER })
            cMensagem += STR0041 //"Deseja tentar novamente? Caso contr�rio a opera��o ser� cancelada."
            If !(lAborta := !EECView(cMensagem, STR0002 )) //"Aviso"
                  i := 1
                  While i <= Len(aErroTrava)
                        EEC->(DbGoTo(aErroTrava[i][2]))
                        If EEC->(SimpleLock() .And. SoftLock("EEC"))
                              aAdd(Self:aSoftLock, {"EEC", EEC->(Recno())})
                              aDel(aErroTrava, i)
                              aSize(aErroTrava, Len(aErroTrava)-1)
                              i -= 1
                        EndIf
                        i++
                  EndDo
            EndIf
      EndDo

      If lAborta
            Self:LiberaRegistros()
      EndIf

      RestOrd(aOrd, .T.)
Return !lAborta

/*
M�todo    : LiberaRegistros()
Classe    : AF900Mark
Objetivo  : Cancela o Softlock dos registros reservados durante a valida��o
*/
Method LiberaRegistros() Class AF900Mark
Local i
Local aOrd := SaveOrd("EEC")

      For i := 1 To Len(Self:aSoftLock)
            EEC->(DbGoTo(Self:aSoftLock[i][2]))
            If EEC->(IsLocked())
                  EEC->(MsUnlock())
            EndIf
      Next
      Self:aSoftLock := {}

RestOrd(aOrd, .T.)
Return Nil

/*
M�todo    : SetParcela()
Classe    : AF900Mark
Objetivo  : Adicionar os dados da parcela marcada no array de controle aParcelas
*/
Method SetParcela(nRecParc, cTipo, nValor) Class AF900Mark
      aAdd(Self:aParcelas, {nRecParc, cTipo, nValor})
      Self:nTotal += nValor
Return nil

/*
M�todo    : SetContratoEFF()
Classe    : AF900Mark
Objetivo  : Seta se a parcela marcada possui um n�mero de opera��o que pertence a um contrato
*/
Method SetContratoEFF(lNrOpEFF) Class AF900Mark
If Self:lNrOpEFF <> lNrOpEFF
      Self:lNrOpEFF := lNrOpEFF
EndIf

Return Self:lNrOpEFF

/*
M�todo    : isContratoEFF()
Classe    : AF900Marksubiu
Objetivo  : Retorna se a primeira parcela marcada possio numero de opera��o um contrato com v�nculo ao SIGAEFF
*/
Method isContratoEFF() Class AF900Mark
Return Self:lNrOpEFF
/*
Fun��o     : AF900Mark()
Objetivo   : Executa a op��o de Marca/Desmarca da parcela posicionada. Fun��o relacionada no MenuDef e associada � a��o de duplo clique do browse.
*/
Function AF900Mark()
      If oMarca:Marcado(EEQ->(Recno()))
            oMarca:Desmarca(EEQ->(Recno()), .T.)
      Else
            oMarca:Marca(EEQ->(Recno()), .T.)
      EndIf
Return .T.

/*
Fun��o     : AF900ALTE()
Objetivo   : Executa a op��o de altera��o da rotina de c�mbio padr�o para a parcela selecionada, caso corresponda a c�mbio de embarque.
*/
Function AF900ALTE()
Local aOrd := SaveOrd("EEC")
Local cFilLogado := cFilAnt
Local nRecEEQ := EEQ->(Recno())
local nParc := 0
local aMarcados := oMarca:GetMarcados()

      cFilAnt := EEQ->EEQ_FILIAL
      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
            aCab := {}
            aAdd(aCab, {"EEC_FILIAL", EEC->EEC_FILIAL, Nil})
            aAdd(aCab, {"EEC_PREEMB", EEC->EEC_PREEMB, Nil})
            Eval({|x,y| EECAF200(x,y) },aCab, 3)
            //Desmarca e marca a parcela para atualizar o valor no controle de parcelas marcadas
            for nParc := 1 to len( aMarcados )
                  If oMarca:Marcado(aMarcados[nParc][1])
                        oMarca:Desmarca(aMarcados[nParc][1], .F.)
                        oMarca:Marca(aMarcados[nParc][1], .F., .T.)
                  EndIf
            next
            EEQ->(DbGoTo(nRecEEQ))

      Else
            EasyHelp( STR0042 , STR0002 ) // "N�o foi localizado um embarque associado a esta parcela." , "Aviso"
      EndIf

cFilAnt := cFilLogado
RestOrd(aOrd, .T.)
Eval(bTotaliza)
Return Nil

/*
Fun��o     : AF900ALTP()
Objetivo   : Executa a op��o de altera��o em lote de dados das parcelas selecionadas
*/
Function AF900ALTP()
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTitulo := If(oMarca:LenMarcados() > 1, STR0043 , STR0044 ) //"Altera��o em Lote" , "Altera��o de Parcela"
Local oDlg
Local bOk := {|| If(VldAction("ALTERA_LOTE"), (lRet := .T., oDlg:End()), ) }
Local lRet := .F.
Private oProgress := EasyProgress():New()

      If oMarca:Valida("REC_ABERTO|PAG_ABERTO")
            oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)

                  RegToMemory("EEQ",.T.,, .F.)
                  Enchoice("EEQ",0,3,,,,GetFields("ALT_LOTE_VISUALIZA"),PosDlg(oDlg),GetFields("ALT_LOTE_ALTERA"),3,,,,,,,,,.T.)

            ACTIVATE MSDIALOG oDlg On Init ENCHOICEBAR(oDLG,bOk,{|| oDlg:End() }) CENTERED
            lTelaLote := .F.
            If lRet
                  If oMarca:LenMarcados() > 1
                        oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("ALTERA_LOTE"), 5, oProgress) }, STR0045 + " " + cTitulo) // "Executando"
                        oProgress:Init()
                  Else
                        MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("ALTERA_LOTE"),5) }, STR0045 + " " + cTitulo) // "Executando"
                  EndIf
                  If lRet
                        MsgInfo( STR0046 , STR0002 ) // "Opera��o conclu�da." , "Aviso"
                  EndIf
            EndIf
      EndIf

      //Desbloqueia os registros travados durante a valida��o
      oMarca:LiberaRegistros()

Return lRet

/*
Fun��o     : AF900REC()
Objetivo   : Efetua o recebimento no exterior das parcelas a receber marcadas
*/
Function AF900REC()
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTitulo := If(oMarca:LenMarcados() > 1, STR0047 , STR0048 ) //"Recebimento no Exterior em Lote" , "Recebimento no Exterior"
Local oDlg
Local bOk := {|| If(VldAction("RECEBE"), (lRet := .T., oDlg:End()), ) }
Local lRet := .F.
local nTotRegMrc := oMarca:LenMarcados()
local lMutParc   := nTotRegMrc <> 1
local nRecEEQ    := 0

Private lFinanciamento := .F.
Private lIsEmb := .T.
Private oProgress := EasyProgress():New()
Private lTelaLote := .T.

      nRecEEQ := EEQ->(recno())

      If oMarca:Valida("REC_ABERTO")
            oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)

                  RegToMemory("EEQ",.T.,, .F.)
                  M->EEQ_MOEDA := oMarca:GetMoeda()
                  M->EEQ_VL := nTotMarcado
                  M->EEQ_VLFCAM := nTotMarcado
                  M->EEQ_MODAL := iif(EEQ->EEQ_TP_CON $ "34",EEQ->EEQ_MODAL,"2")
                  M->EEQ_EVENT := "101"
                  M->EEQ_LTRC := cLote := GetSxeNum("EEQ","EEQ_LTRC","EEQ_LTRC" + cEmpAnt)
                  if !lMutParc
                        EEQ->(dbgoto(oMarca:GetMarcados()[1][1]))
                        M->EEQ_VL     := EEQ->EEQ_VL
                        M->EEQ_ACRESC := EEQ->EEQ_ACRESC
                        M->EEQ_DECRES := EEQ->EEQ_DECRES
                        M->EEQ_DESCON := EEQ->EEQ_DESCON
                        M->EEQ_MULTA  := EEQ->EEQ_MULTA
                        M->EEQ_JUROS  := EEQ->EEQ_JUROS
                        M->EEQ_MOTIVO := EEQ->EEQ_MOTIVO
                  endif
                  Enchoice("EEQ",0,3,,,,GetFields("RECEBE_VISUALIZA",,lMutParc),PosDlg(oDlg),GetFields("RECEBE_ALTERA",,lMutParc),3,,,.T.,,,,,,.T.)
            ACTIVATE MSDIALOG oDlg On Init ENCHOICEBAR(oDLG,bOk,{|| oDlg:End() }) CENTERED
            lTelaLote := .F.
            If lRet
                  If oMarca:LenMarcados() > 1
                        oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE",,lMutParc), 5, oProgress) }, STR0045 + " " + cTitulo) //"Executando"
                        oProgress:Init()
                  Else
                        MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE",, lMutParc ),5) }, STR0045 + " " + cTitulo) //"Executando"
                  EndIf
                  If lRet
                        MsgInfo( STR0049 + cLote, STR0002 ) //"Opera��o conclu�da. Lote de refer�ncia: " , "AVISO"
                  EndIf
            EndIf
      EndIf

      If !lRet
            RollbackSx8()
      EndIf

      //Desbloqueia os registros travados durante a valida��o
      oMarca:LiberaRegistros()

      EEQ->(dbgoto(nRecEEQ))

Return lRet

/*
Fun��o     : AF900ELIQ()
Objetivo   : Efetua o estorno do recebimento no exterior das parcelas a receber marcadas
*/
Function AF900EREC()
Local aEEQAuto := {}
Local lRet := .F.
Local oProgress := EasyProgress():New()

      If oMarca:Valida("REC_ALIQUIDAR_EMBARCADO|REC_ALIQUIDAR_NAOEMBARCADO") .And. VldAction("RECEBE_CANCELA") .And. MsgYesNo( STR0050 , STR0002 ) //"Confirma o estorno do recebimento das parcelas?", "Aviso"
            If oMarca:LenMarcados() > 1
                  oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE_CANCELA"), 5, oProgress) }, STR0051 ) //"Executando Estorno do Recebimento em Lote"
                  oProgress:Init()
            Else
                  MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("RECEBE_CANCELA"), 5) }, STR0052 ) // "Executando Estorno do Recebimento da Parcela"
            EndIf
      EndIf
      If lRet
            MsgInfo( STR0046 , STR0002 ) //"Opera��o conclu�da com sucesso." , "Aviso"
      EndIf
      //Desbloqueia os registros travados durante a valida��o
      oMarca:LiberaRegistros()

Return lRet

/*
Fun��o     : AF900LIQ()
Objetivo   : Efetua a liquida��o das parcelas a receber marcadas
*/
Function AF900LIQ()
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTitulo := If(oMarca:LenMarcados() > 1, STR0053 , STR0054 ) //"Liquida��o em Lote", "Liquida��o"
Local oDlg
Local bOk := {|| If(VldAction("LIQUIDA"), (lRet := .T., oDlg:End()), ) }
Local lRet := .T.
Local nEEQRecno
local nTotRegMrc := oMarca:LenMarcados()
local lMutParc   := nTotRegMrc <> 1
local nRecEEQ    := 0

//** Vari�veis usadas na valida��o dos campos no EECAF200
Private lFinanciamento := .F.
Private lIsEmb := .T.
Private nTipoDet := 99
Private lTelaLote := .T.
//***
Private oProgress := EasyProgress():New()

      nRecEEQ := EEQ->(recno())

      If oMarca:PossuiParcela("REC_ALIQUIDAR_EMBARCADO") .And. oMarca:PossuiParcela("REC_ALIQUIDAR_NAOEMBARCADO")
            If lRet := MsgYesNo( STR0055 , STR0002 ) //"Foram identificadas parcelas associadas a processos embarcados e parcelas associadas a processos n�o embarcados. Para prosseguir, as parcelas vinculadas a processos n�o embarcados ser�o desmarcadas. Deseja continuar?", "Aviso"
                  oMarca:MarcaTodos(.T., "REC_ALIQUIDAR_EMBARCADO", .F.)
            EndIf
      EndIf

      If lRet
            lRet := oMarca:Valida("REC_ALIQUIDAR_EMBARCADO|REC_ALIQUIDAR_NAOEMBARCADO")
      EndIf
      If lRet
            oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)

                  RegToMemory("EEQ",.T.,, .F.)
                  M->EEQ_MOEDA := oMarca:GetMoeda()
                  M->EEQ_VL := nTotMarcado
                  M->EEQ_VLFCAM := nTotMarcado
                  M->EEQ_MODAL := "1"
                  M->EEQ_NROP := oMarca:GetNrOp()
                  M->EEQ_LTBX := cLote := GetSxeNum("EEQ","EEQ_LTBX","EEQ_LTBX" + cEmpAnt)
                  nEEQRecno := oMarca:aParcelas[1][1]
                  EEQ->(DBGOTO(nEEQRecno))
                  M->EEQ_EVENT := EEQ->EEQ_EVENT //OSSME-7209 MFR 10/01/2022
                  if !lMutParc
                        M->EEQ_VL     := EEQ->EEQ_VL
                        M->EEQ_ACRESC := EEQ->EEQ_ACRESC
                        M->EEQ_DECRES := EEQ->EEQ_DECRES
                        M->EEQ_DESCON := EEQ->EEQ_DESCON
                        M->EEQ_MULTA  := EEQ->EEQ_MULTA
                        M->EEQ_JUROS  := EEQ->EEQ_JUROS
                        M->EEQ_MOTIVO := EEQ->EEQ_MOTIVO
                  endif
                  If EasyGParam("MV_EEC_EFF",,.F.) .And. !Empty(M->EEQ_NROP) .And. oMarca:isContratoEFF() //Se integrado com SIGAEFF, verifica se o Numero de Contrato pertence a um contrato do EFF
                        M->EEQ_BANC   := EEQ->EEQ_BANC
                        M->EEQ_AGEN   := EEQ->EEQ_AGEN
                        M->EEQ_NCON   := EEQ->EEQ_NCON
                        M->EEQ_NOMEBC := Posicione("SA6",1,xFilial("SA6") + AvKey(M->EEQ_BANC,"A6_COD") + AvKey(M->EEQ_AGEN,"A6_AGENCIA") + AvKey(M->EEQ_NCON,"A6_NUMCON") , "A6_NOME")
                  EndIf

                  Enchoice("EEQ",0,3,,,,GetFields("LIQUIDA_VISUALIZA",,lMutParc),PosDlg(oDlg),GetFields("LIQUIDA_ALTERA",oMarca:GetNrOp(),lMutParc, oMarca:isContratoEFF()),3,,,,,,,,,.T.)

            ACTIVATE MSDIALOG oDlg On Init ENCHOICEBAR(oDLG,bOk,{|| lRet := .F., oDlg:End() }) CENTERED

            If lRet
                  If oMarca:LenMarcados() > 1
                        oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("LIQUIDA",,lMutParc), 99, oProgress) }, STR0056 ) // "Executando Liquida��o em Lote"
                        oProgress:Init()
                  Else
                        MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields("LIQUIDA",,lMutParc), 99) }, STR0057 ) // "Executando Liquida��o da Parcela"
                  EndIf
                  If lRet
                        MsgInfo( STR0049 + cLote, STR0002 ) //"Opera��o conclu�da. Lote de refer�ncia: " , "Aviso"
                  EndIf
            EndIf
      EndIf
      If !lRet
            RollbackSx8()
      EndIf
      //Desbloqueia os registros travados durante a valida��o
      oMarca:LiberaRegistros()
      EEQ->(dbgoto(nRecEEQ))

Return lRet

/*
Fun��o     : AF900ELIQ()
Objetivo   : Efetua o estorno de liquida��o das parcelas a receber marcadas
*/
Function AF900ELIQ()
Local lRet := .F.
Local oProgress := EasyProgress():New()

      If oMarca:Valida("REC_LIQUIDADO_CAMBIO") .And. VldAction("LIQUIDA_CANCELA") .And. MsgYesNo( STR0058 , STR0002 ) //"Confirma o estorno da liquida��o das parcelas?", "Aviso"
            If oMarca:LenMarcados() > 1
                  oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98, oProgress) }, STR0059 ) // "Executando Estorno da Liquida��o em Lote"
                  oProgress:Init()
            Else
                  MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98) }, STR0060 ) //"Executando Estorno da Liquida��o da Parcela"
            EndIf
      EndIf
      If lRet
            MsgInfo(STR0046,STR0002) //"Opera��o conclu�da com sucesso.", "Aviso"
      EndIf
      //Desbloqueia os registros travados durante a valida��o
      oMarca:LiberaRegistros()

Return lRet

/*
Fun��o     : AF900PAG()
Objetivo   : Efetua o pagamento das parcelas a pagar marcadas
*/
Function AF900PAG()
Local aCoors := FWGetDialogSize( oMainWnd )
Local cTitulo := If(oMarca:LenMarcados() > 1, STR0061 , STR0062 ) //"Pagamento em Lote", "Pagamento"
Local oDlg
Local bOk := {|| If(VldAction("PAGA"), (lRet := .T., oDlg:End()), ) }
Local lRet := .T.
Local nEEQRecno
local nTotRegMrc := oMarca:LenMarcados()
local lMutParc   := nTotRegMrc <> 1
local nRecEEQ    := 0

//** Vari�veis usadas na valida��o dos campos no EECAF200
Private lFinanciamento := .F.
Private lIsEmb := .T.
Private nTipoDet := 99
Private lTelaLote := .T.
//***
Private oProgress := EasyProgress():New()

      nRecEEQ := EEQ->(recno())

      If lRet
            lRet := oMarca:Valida("PAG_ABERTO")
      EndIf
      If lRet
            oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)

                  RegToMemory("EEQ",.T.,, .F.)
                  M->EEQ_MOEDA := oMarca:GetMoeda()
                  M->EEQ_VL := nTotMarcado
                  M->EEQ_VLFCAM := nTotMarcado
                  M->EEQ_NROP := oMarca:GetNrOp()
                  M->EEQ_LTPG := cLote := GetSxeNum("EEQ","EEQ_LTPG","EEQ_LTPG" + cEmpAnt)
                  nEEQRecno := oMarca:aParcelas[1][1]
                  EEQ->(DBGOTO(nEEQRecno))
                  M->EEQ_EVENT := EEQ->EEQ_EVENT //OSSME-7209 MFR 10/01/2022
                  if !lMutParc
                        M->EEQ_VL     := EEQ->EEQ_VL
                        M->EEQ_ACRESC := EEQ->EEQ_ACRESC
                        M->EEQ_DECRES := EEQ->EEQ_DECRES
                        M->EEQ_DESCON := EEQ->EEQ_DESCON
                        M->EEQ_MULTA  := EEQ->EEQ_MULTA
                        M->EEQ_JUROS  := EEQ->EEQ_JUROS
                        M->EEQ_MOTIVO := EEQ->EEQ_MOTIVO
                  endif
                  Enchoice("EEQ",0,3,,,,GetFields("PAGA_VISUALIZA",,lMutParc),PosDlg(oDlg),GetFields("PAGA_ALTERA",oMarca:GetNrOp(),lMutParc),3,,,,,,,,,.T.)

            ACTIVATE MSDIALOG oDlg On Init ENCHOICEBAR(oDLG,bOk,{|| lRet := .F., oDlg:End() }) CENTERED

            If lRet
                  If oMarca:LenMarcados() > 1
                        oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields(IF(M->EEQ_MODAL=="1", "PAGA_CAMBIO", "PAGA_EXTERIOR"),,lMutParc), 99, oProgress) }, STR0063 ) //"Executando Pagamento em Lote"
                        oProgress:Init()
                  Else
                        MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), GetIntegFields(IF(M->EEQ_MODAL=="1", "PAGA_CAMBIO", "PAGA_EXTERIOR"),,lMutParc), 99) }, STR0064 ) //"Executando Pagamento da Parcela"
                  EndIf
                  If lRet
                        MsgInfo( STR0049 + cLote , STR0002 ) //"Opera��o conclu�da. Lote de refer�ncia: " + cLote, "Aviso"
                  EndIf
            EndIf
      EndIf
      If !lRet
            RollbackSx8()
      EndIf
      //Desbloqueia os registros travados durante a valida��o
      oMarca:LiberaRegistros()
      EEQ->(dbgoto(nRecEEQ))

Return lRet

/*
Fun��o     : AF900EPAG()
Objetivo   : Efetua o estorno de pagamento das parcelas a pagar marcadas
*/
Function AF900EPAG()
Local lRet := .F.
Local oProgress := EasyProgress():New()

      If oMarca:Valida("PAG_FECHADO") .And. VldAction("PAGA_CANCELA") .And. MsgYesNo( STR0065 , STR0002 ) //"Confirma o estorno do pagamento das parcelas?", "Aviso"
            If oMarca:LenMarcados() > 1
                  oProgress:SetProcess({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98, oProgress) }, STR0066 ) //"Executando Estorno do Pagamento em Lote"
                  oProgress:Init()
            Else
                  MsAguarde({|| lRet := IntegEEQ(oMarca:GetMarcados(), {}, 98) }, STR0067 )
            EndIf
      EndIf
      If lRet
            MsgInfo(STR0046 , STR0002 ) //"Opera��o conclu�da com sucesso.", "Aviso"
      EndIf
      //Desbloqueia os registros travados durante a valida��o
      oMarca:LiberaRegistros()

Return lRet

/*
Fun��o     : VldAction(cAction)
Objetivo   : Valida a execu��o das a��es de tela, verificando os campos obrigat�rios de acordo com o contexto
Par�metros : cAction - Indica a a��o executada
*/
Static Function VldAction(cAction, lBloqueia, nOpc, aEEQAuto)
Local lRet := .T.
Local i
Local aCampos := {}
Local cMensagem := ""
Local aOrd
Default lBloqueia := .T.
Default nOpc := 0
Default aEEQAuto := {}

      Do Case
            Case cAction $ "LIQUIDA"
                  aCampos := GetFields("LIQUIDA_OBRIGATORIO")
                  If !Empty(M->EEQ_NROP) .And. !IsContrEFF()//THTS - 16/09/2022 - Se o Contrato vinculado for do EFF, n�o executar a valida��o
                        lRet := AF200VldOpr()
                  EndIf
            Case cAction == "RECEBE"
                  If M->EEQ_MODAL == "2"
                        aCampos := GetFields("RECEBE_OBRIGATORIO_EXTERIOR")
                  Else
                        aCampos := GetFields("RECEBE_OBRIGATORIO")
                  EndIf
            Case cAction == "PAGA"
                  If M->EEQ_MODAL == "2"
                        aCampos := GetFields("PAGA_OBRIGATORIO_EXTERIOR")
                  Else
                        aCampos := GetFields("PAGA_OBRIGATORIO_BRASIL")
                  EndIf
            Case cAction == "ALTERA_LOTE"
                  aCampos := GetFields("ALT_LOTE_OBRIGATORIO")

            Case cAction == "INTEGEEQ"
                  If nOpc == 5 .And. EEQ->EEQ_TIPO == "A" .And. EEQ->EEQ_MODAL == "2" .And. aScan(aEEQAuto, {|x| x[1] == "EEQ_DTCE" .And. Empty(x[2]) }) > 0
                        cMensagem += STR0068 + ENTER // "Opera��o n�o permitida. Por se tratar de uma parcela de adiantamento, o cr�dito no exterior deve ser estornado no cadastro de clientes."
                        EasyHelp(cMensagem, STR0002 ) //"Aviso"
                        lRet := .F.
                  EndIf
                  If !(EEQ->EEQ_TP_CON $ "3|4")
                        //Se n�o for c�mbio 3/4deve possuir um embarque obrigatoriamente
                        aOrd := SaveOrd("EEC")
                        EEC->(DbSetOrder(1))
                        If !EEC->(DbSeek(xFilial()+EEQ->EEQ_PREEMB))
                              EasyHelp(StrTran(StrTran( STR0069 , "XXX", Alltrim(EEQ->EEQ_PREEMB)), "YYY", Alltrim(xFilial("EEC"))), STR0002 ) // "O processo de embarque 'XXX' da Filial 'YYY' associado a esta parcela n�o foi localizado." , "Aviso"
                              lRet := .F.
                        EndIf
                  Else
                        If EEQ->EEQ_SOURCE == Avkey("ESS", "EEQ_SOURCE")
                              //Somente se for originado do Siscoserv, precisa localizar a Invoice
                              aOrd := SaveOrd("ELA")
                              //O m�dulo deve ser alterado para ESS devido ao controle de eventos cont�beis
                              cModulo := "ESS"
                              ELA->(DbSetOrder(4))
                              If !ELA->(DbSeek(xFilial("ELA")+AvKey(EEQ->EEQ_TPPROC,"ELA_TPPROC")+AvKey(EEQ->EEQ_PROCES,"ELA_PROCES")+AvKey(EEQ->EEQ_NRINVO,"ELA_NRINVO")))
                                    EasyHelp(StrTran(StrTran(StrTran( STR0070 , "XXX", Alltrim(EEQ->EEQ_NRINVO)), "YYY", Alltrim(xFilial("ELA"))), "ZZZ", If(EEQ->EEQ_TPPROC == "P", STR0027 , STR0024 )), STR0002 ) //"A Invoice 'XXX' da Filial 'YYY' do tipo 'ZZZ' associada a esta parcela n�o foi localizada.","Aviso" //"A Pagar" // "A Receber" 
                                    lRet := .F.
                              EndIf
                        EndIf
                        If nOpc == 98
                              //Se for estorno de liquida��o de um cambio 3/4, � necess�rio limpar os campos (n�o existe op��o espec�fica no EECAF500)
                              aIntegra := GetIntegFields("PAGA_CANCELA_3_4", aClone(aIntegra))
                        EndIf
                  EndIf
      EndCase
      
      If lRet
            For i := 1 To Len(aCampos)
                  If Empty(&("M->"+aCampos[i]))
                        EasyHelp(StrTran(STR0071, "XXX", AvSx3(aCampos[i], AV_TITULO)), STR0002 ) //"O campo 'XXX' deve ser informado para prosseguir com a opera��o.","Aviso"
                        lRet := .F.
                        Exit
                  EndIf
            Next
      EndIf

      if lRet
            if ( cAction == "RECEBE" .or. cAction == "PAGA" ) .and. existfunc('AF200VdBancExt') 
                  lRet := AF200VdBancExt(.F.)
            endif
      endif

      If lRet .And. EasyEntryPoint("AF900VLD")
            lRet := ExecBlock("AF900VLD", .F., .F., {cAction, lBloqueia, nOpc, aEEQAuto, lRet})
      EndIf

      If lRet .And. lBloqueia
            //Bloqueia os processos de embarque relacionados �s parcelas
            MsAguarde({|| lRet := oMarca:ReservaRegistros() }, STR0072 ) //"Verificando disponibilidade de registros"
      EndIf

      If aOrd <> Nil
            RestOrd(aOrd)
      EndIf

Return lRet

/*
Fun��o     : GetFields(cOpc)
Objetivo   : Define a rela��o de campos para tela (Visualiza��o, Altera��o e Obrigat�rios) de acordo com cada contexto para tela
Par�metros : cOpc - C�digo do contexto desejado
*/
Static Function GetFields(cOpc, cOperacao, lMultParcela, lContraEFF)
Private aFields := {}
Default lMultParcela := .T.
Default lContraEFF   := .F.

      Do Case
            Case cOpc == "LIQUIDA_VISUALIZA"
                  aFields := {"EEQ_MOEDA", "EEQ_VLFCAM", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX", "EEQ_EQVL","EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC", "EEQ_LTBX", "NOUSER"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "LIQUIDA_ALTERA"
                  If Empty(cOperacao)
                        aFields := {"EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX","EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_RFBC"}
                  Else                  
                        aFields := {"EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_TX"}
                        If !EasyGParam("MV_EEC_EFF",,.F.) .Or. !lContraEFF
                              aAdd(aFields, "EEQ_BANC")
                              aAdd(aFields, "EEQ_AGEN")
                              aAdd(aFields, "EEQ_NCON")
                        EndIf
                        aAdd(aFields, "EEQ_RFBC")
                  EndIf
                  if EasyGParam("MV_AVG0131",,.F.) .and. ( lMultParcela .or. !(AllTrim(EEQ->EEQ_MODAL) == "2" .and. !empty(EEQ->EEQ_DTCE)))
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.) .and. !(AllTrim(EEQ->EEQ_MODAL) == "2" .and. !empty(EEQ->EEQ_DTCE))
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "LIQUIDA_OBRIGATORIO"
                  aFields := {"EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_TX"}
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BANC")
                        aAdd(aFields, "EEQ_AGEN")
                        aAdd(aFields, "EEQ_NCON")
                  endif
            Case cOpc == "RECEBE_VISUALIZA"
                  aFields := {"EEQ_MOEDA", "EEQ_VLFCAM", "EEQ_EQVL", "EEQ_DTCE", "EEQ_OBS", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT", "EEQ_MOEBCO", "EEQ_PRINBC", "EEQ_VLMBCO", "EEQ_LTRC", "NOUSER"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "RECEBE_ALTERA"
                  aFields := {"EEQ_DTCE", "EEQ_OBS", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "RECEBE_OBRIGATORIO"
                  aFields := {"EEQ_DTCE", "EEQ_MODAL"}

            Case cOpc == "RECEBE_OBRIGATORIO_EXTERIOR"
                  aFields := GetFields("RECEBE_OBRIGATORIO")
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BCOEXT")
                        aAdd(aFields, "EEQ_CNTEXT")
                        aAdd(aFields, "EEQ_AGCEXT")
                  endif

            Case cOpc == "PAGA_VISUALIZA"
                  aFields := {"EEQ_MOEDA", "EEQ_VLFCAM", "EEQ_DTCE", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX", "EEQ_EQVL","EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC","EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT", "EEQ_MOEBCO", "EEQ_PRINBC", "EEQ_VLMBCO", "EEQ_LTPG", "NOUSER"}
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, "EEQ_ACRESC" )
                        aAdd( aFields, "EEQ_DECRES" )
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "PAGA_ALTERA"
                  If Empty(cOperacao)
                        aFields := {"EEQ_DTCE", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_NROP", "EEQ_TX", "EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT"}
                  Else
                        aFields := {"EEQ_DTCE", "EEQ_SOL","EEQ_DTNEGO","EEQ_PGT", "EEQ_TX", "EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_NOMEBC","EEQ_RFBC", "EEQ_MODAL", "EEQ_BCOEXT", "EEQ_CNTEXT", "EEQ_AGCEXT", "EEQ_NBCEXT"}
                  EndIf
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, "EEQ_MOTIVO" )
                  endif
                  if !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, "EEQ_DESCON" )
                        aAdd( aFields, "EEQ_MULTA" )
                        aAdd( aFields, "EEQ_JUROS" )
                  endif

            Case cOpc == "PAGA_OBRIGATORIO"
                  aFields := {"EEQ_DTCE", "EEQ_MODAL"}

            Case cOpc == "PAGA_OBRIGATORIO_BRASIL"
                  aFields := GetFields("PAGA_OBRIGATORIO")
                  aAdd(aFields, "EEQ_SOL")
                  aAdd(aFields, "EEQ_DTNEGO")
                  aAdd(aFields, "EEQ_PGT")
                  aAdd(aFields, "EEQ_TX")
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BANC")
                        aAdd(aFields, "EEQ_AGEN")
                        aAdd(aFields, "EEQ_NCON")
                  endif
                  aAdd(aFields, "EEQ_DTCE")
            
            Case cOpc == "PAGA_OBRIGATORIO_EXTERIOR"
                  aFields := GetFields("PAGA_OBRIGATORIO")
                  if ( empty(M->EEQ_MOTIVO) .or. MovBcoBx(M->EEQ_MOTIVO) )
                        aAdd(aFields, "EEQ_BCOEXT")
                        aAdd(aFields, "EEQ_CNTEXT")
                        aAdd(aFields, "EEQ_AGCEXT")
                  endif
            
            Case cOpc == "ALT_LOTE_VISUALIZA"
                  aFields := {"EEQ_VCT", "NOUSER"}

            Case cOpc == "ALT_LOTE_ALTERA"
                  aAdd(aFields, "EEQ_VCT")

            Case cOpc == "ALT_LOTE_OBRIGATORIO"
                  aAdd(aFields, "EEQ_VCT")
                  
      EndCase

      If EasyEntryPoint("AF900GETFIELDS")
            ExecBlock("AF900GETFIELDS",.F.,.F., cOpc)
      EndIf

Return aFields

/*
Fun��o     : IntegEEQ(aMarcados, aEEQAuto, nOpc, oProgress)
Objetivo   : Efetua a integra��o das parcelas marcadas via ExecAuto (EECAF200 ou EECAF500)
Par�metros : aMarcados - Array contendo as parcelas marcadas
             aEEQAuto - Array com os dados chave para o ExecAuto
             nOpc - Op��o a ser enviada para o ExecAuto
             oProgress - Objeto contendo a tela de progresso opc=5 receber no exterior, 99 pagar  98 estornar pagamento           
*/
Static Function IntegEEQ(aMarcados, aEEQAuto, nOpc, oProgress)
Local cFilLogado := cFilAnt
Local aOrd := SaveOrd({"EEC", "EEQ"}), i
Local aCab
Local cErros := "", cMensagem := ""
Local lRet, lProcErro := .F.
Local cCodModulo := cModulo
Local nErroCount := 0
Local cMotivoEst := ""
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.//Indica que todas as mensagens de help devem ser direcionadas para o arquivo de log
Private lELinkBlind := Len(aMarcados) > 1//Caso tenha mais de uma parcela marcada desliga a janela do EasyLink
Private lELinkAuto := .T.//Indica para o EasyLink que o mesmo est� sendo executado em uma rotina autom�tica e que os erros devem ser retornados por EasyHelp

      //Somente haver� regua de processamento quando existir mais de uma parcela marcada
      If oProgress <> Nil
            oProgress:SetRegua(Len(aMarcados))
      EndIf

      EEC->(DbSetOrder(1))
      For i := 1 To Len(aMarcados)
            EEQ->(DbGoTo(aMarcados[i][1]))
            //Altera a filial corrente para a filial da parcela
            If !Empty( EEQ->EEQ_FILIAL)
                  cFilAnt := EEQ->EEQ_FILIAL
            EndIf
            lMsErroAuto := .F.
            lProcErro := .F.
            //Busca os campos chave de acordo com a parcela
            aIntegra := GetIntegFields("CHAVE_EEQ", aClone(aEEQAuto))
            //Valida se a opera��o pode ser efetuada e inclui campos adicionais no array de integra��o caso sejam exigidos pela opera��o
            If !(lMsErroAuto := !VldAction("INTEGEEQ", .F., nOpc, aIntegra))
                  If !(EEQ->EEQ_TP_CON $ "3|4")
                        //Se for c�mbio tipo 1 ou 2 executa o EECAF200
                        aCab := GetIntegFields("CHAVE_EEC")
                        If nOpc == 98 .And. IsContrEFF()
                              If Empty(cMotivoEst)
                                    cMotivoEst := MotHistEFF() //Necess�rio informar um motivo para o estorno
                              EndIf
                              aAdd(aIntegra, {"AUTMOTIVO"   , cMotivoEst , Nil})
                        EndIf
                        MsExecAuto({|a,b,c,d| EECAF200(a,b,c,d) },aCab, 3, aIntegra, nOpc)
                  Else
                        //Se for c�mbio tipo 3 ou 4 executa o EECAF500
                        MsExecAuto({|a,b,c| EECAF500(a,,,b,c) }, "EEQ", aIntegra, 4)
                  EndIf
                  //Retorna para a parcela caso tenha sido desposicionado na rotina autom�tica
                  EEQ->(DbGoTo(aMarcados[i][1]))
            EndIf
            If lMsErroAuto
                  nErroCount++
                  //Caso tenha ocorrido erro informa a parcela onde ocorreu o erro e as mensagens retornadas
                  If nErroCount > 1
                        cErros += SEPARADOR
                  EndIf
                  cErros += StrTran( STR0073 , "XXX", AllTrim(Str(nErroCount))) + ENTER //"Erro XXX:"
                  cErros += StrTran(StrTran( STR0074 , "XXX", AllTrim(EEQ->EEQ_PARC)), "YYY", AllTrim(If(!Empty(EEQ->EEQ_PROCES), EEQ->EEQ_PROCES, EEQ->EEQ_PREEMB))) + ENTER //"N�o foi poss�vel atualizar a parcela 'XXX' do processo 'YYY': "
                  //Recupera os erros da rotina autom�tica (caso existam)
                  If ValType(NomeAutoLog()) == "C"
                        cErros += STR0075 + ENTER //"A execu��o da rotina autom�tica retornou a(s) seguinte(s) mensagem(ns): "
                        cErros += MemoRead(NomeAutoLog())
                        //Apaga o arquivo de log para que n�o seja concatenado no pr�ximo erro
                        FErase(NomeAutoLog())
                  Else
                        cErros += STR0076 + ENTER //"A rotina n�o retornou uma mensagem de erro espec�fica."
                  EndIf
                  oMarca:Desmarca(EEQ->(Recno()), .F.)
            Else
                  //Verifica se precisa atualizar o n�mero do lote
                  AtualizaLote(nOpc, EEQ->EEQ_TIPO, aIntegra)
                  //Desmarca e marca a parcela para atualizar o tipo da parcela no controle de parcelas marcadas
                  oMarca:Desmarca(EEQ->(Recno()), .F.)
                  oMarca:Marca(EEQ->(Recno()), .F., .T.)
            EndIf
            //Retorna a filial original
            cFilAnt := cFilLogado
            //Nas opera��es de atualiza��o de parcelas do Siscoserv o m�dulo � alterado para ESS na rotina de valida (VldAction("INTEGEEQ", ...))
            cModulo := cCodModulo
            //Incrementa a regua de processamento
            If oProgress <> Nil
                  oProgress:IncRegua()
            EndIf
      Next
      lRet := oMarca:LenMarcados() > 0
      If lRet
            ConfirmSX8()
      EndIf
      If nErroCount > 0
            cMensagem := STR0077 + ENTER + ENTER //"Aten��o: Ocorreram erros na opera��o."
            If Len(aMarcados) == nErroCount
                  cMensagem += STR0078 + ENTER + ENTER //"Devido aos erros o lote foi cancelado e a numera��o descartada."
            Else
                  cMensagem += STR0079 + ENTER + ENTER
            EndIf
            If nErroCount > 1
                  cMensagem += StrTran(STR0080 , "XXX", AllTrim(Str(nErroCount)) + STR0081 + AllTrim(Str(Len(aMarcados)))) + ENTER + ENTER // "Das parcelas selecionadas XXX n�o foram atualizadas devido aos erros, os quais ser�o apresentados abaixo: " " de "
            Else
                  cMensagem += STR0082 + ENTER + ENTER
            EndIf
            EECView(cMensagem + cErros, STR0083 ) //"Aviso: Ocorreram erros na opera��o"
      EndIf

cFilAnt := cFilLogado
RestOrd(aOrd)
Eval(bTotaliza)
Return lRet

/*
Fun��o     : AtualizaLote(cOpc, cTipo, aIntegra)
Objetivo   : Verifica se o lote precisa ser removido da parcela
Par�metros : nOpc - Op��o que foi executada no ExecAuto
             cTipo - Tipo da parcela (P-Pagar, R-Receber, A-Adiantamento)
             aIntegra - Array com os campos do ExecAuto
*/
Static Function AtualizaLote(nOpc, cTipo, aIntegra)
Local cCampo := ""

      If cTipo == "P"
            If nOpc == 98 .Or. aScan(aIntegra, {|x| x[1] == "EEQ_DTCE" .And. Empty(x[2]) }) > 0 .Or. aScan(aIntegra, {|x| x[1] == "EEQ_PGT" .And. Empty(x[2]) }) > 0
                  cCampo := "EEQ_LTPG"                                 
            EndIf
      Else
            If nOpc == 5 .And. aScan(aIntegra, {|x| x[1] == "EEQ_DTCE" .And. Empty(x[2]) }) > 0
                  cCampo := "EEQ_LTRC"
            EndIf
            If nOpc == 98
                  cCampo := "EEQ_LTBX"
            EndIf
      EndIf

      If !Empty(cCampo) .And. !Empty(EEQ->&(cCampo))
            EEQ->(Reclock("EEQ", .F.))
            EEQ->&(cCampo) := ""
            EEQ->(MsUnlock())
      EndIf

Return Nil

/*
Fun��o     : GetIntegFields(cOpc, aFields)
Objetivo   : Prepara o array com os dados do ExecAuto na tabela EEQ com base no registro posicionado ou dados da mem�ria
Par�metros : cOpc - Op��o Selecionada para retornar os campos de acordo com o contexto
             aFields - Array com campos j� definidos anteriormente, onde ser�o inclu�dos os novos campos
*/
Static Function GetIntegFields(cOpc, aFields, lMultParcela)
Private aCustom
Default aFields := {}
Default lMultParcela := .T.

      Do Case
            Case cOpc == "CHAVE_EEQ"
                  aAdd(aFields, {"EEQ_EVENT"    , EEQ->EEQ_EVENT  , Nil})
                  aAdd(aFields, {"EEQ_PREEMB"   , EEQ->EEQ_PREEMB , Nil})
                  aAdd(aFields, {"EEQ_NRINVO"   , EEQ->EEQ_NRINVO , Nil})
                  aAdd(aFields, {"EEQ_PARC"     , EEQ->EEQ_PARC   , Nil})
                  If EEQ->EEQ_TP_CON $ "3|4"
                        aAdd(aFields, {"EEQ_PROCES", EEQ->EEQ_PROCES, Nil})
                        aAdd(aFields, {"EEQ_TPPROC", EEQ->EEQ_TPPROC, Nil})
                        aAdd(aFields, {"EEQ_MODAL" , if(M->EEQ_MODAL == nil, EEQ->EEQ_MODAL, M->EEQ_MODAL), Nil}) //no estorno n�o tem a vari�vel em mem�ria
                  EndIf
            Case cOpc == "CHAVE_EEC"
                  aAdd(aFields, {"EEC_FILIAL", EEC->EEC_FILIAL, Nil})
                  aAdd(aFields, {"EEC_PREEMB", EEC->EEC_PREEMB, Nil})
            Case cOpc == "LIQUIDA"
                  aAdd(aFields, {"EEQ_SOL"     , M->EEQ_SOL      , Nil})
                  aAdd(aFields, {"EEQ_DTNEGO"  , M->EEQ_DTNEGO   , Nil})
                  aAdd(aFields, {"EEQ_PGT"     , M->EEQ_PGT      , Nil})
                  aAdd(aFields, {"EEQ_NROP"    , M->EEQ_NROP     , Nil})
                  aAdd(aFields, {"EEQ_RFBC"    , M->EEQ_RFBC     , Nil})
                  aAdd(aFields, {"EEQ_TX"      , M->EEQ_TX       , Nil})
                  aAdd(aFields, {"EEQ_BANC"    , M->EEQ_BANC     , Nil})
                  aAdd(aFields, {"EEQ_AGEN"    , M->EEQ_AGEN     , Nil})
                  aAdd(aFields, {"EEQ_NCON"    , M->EEQ_NCON     , Nil})
                  aAdd(aFields, {"EEQ_LTBX"    , M->EEQ_LTBX     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
            Case cOpc == "RECEBE"
                  aAdd(aFields, {"EEQ_DTCE"    , M->EEQ_DTCE     , Nil})
                  aAdd(aFields, {"EEQ_MODAL"   , M->EEQ_MODAL    , Nil})
                  aAdd(aFields, {"EEQ_OBS"     , M->EEQ_OBS      , Nil})
                  aAdd(aFields, {"EEQ_BCOEXT"  , M->EEQ_BCOEXT   , Nil})
                  aAdd(aFields, {"EEQ_AGCEXT"  , M->EEQ_AGCEXT   , Nil})
                  aAdd(aFields, {"EEQ_CNTEXT"  , M->EEQ_CNTEXT   , Nil})
                  aAdd(aFields, {"EEQ_LTRC"    , M->EEQ_LTRC     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
                  If EEQ->EEQ_TP_CON $ "3|4" .AND. EasyVermodal('EEQ')
                     aAdd(aFields, {"EEQ_PGT"    , M->EEQ_DTCE , Nil}) 
                  EndIf   

            Case cOpc == "RECEBE_CANCELA"
                  aAdd(aFields, {"EEQ_DTCE"    , CTod("")       , Nil})
            Case cOpc == "PAGA_EXTERIOR"
                  aAdd(aFields, {"EEQ_DTCE"    , M->EEQ_DTCE     , Nil})
                  aAdd(aFields, {"EEQ_PGT"     , M->EEQ_PGT      , Nil})//RMD - 02/10/18
                  aAdd(aFields, {"EEQ_MODAL"   , M->EEQ_MODAL    , Nil})
                  aAdd(aFields, {"EEQ_OBS"     , M->EEQ_OBS      , Nil})
                  aAdd(aFields, {"EEQ_BCOEXT"  , M->EEQ_BCOEXT   , Nil})
                  aAdd(aFields, {"EEQ_AGCEXT"  , M->EEQ_AGCEXT   , Nil})
                  aAdd(aFields, {"EEQ_CNTEXT"  , M->EEQ_CNTEXT   , Nil})
                  aAdd(aFields, {"EEQ_LTPG"    , M->EEQ_LTPG     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
            Case cOpc == "PAGA_CAMBIO"
                  aAdd(aFields, {"EEQ_DTCE"    , M->EEQ_DTCE     , Nil})
                  aAdd(aFields, {"EEQ_MODAL"   , M->EEQ_MODAL    , Nil})
                  aAdd(aFields, {"EEQ_SOL"     , M->EEQ_SOL      , Nil})
                  aAdd(aFields, {"EEQ_DTNEGO"  , M->EEQ_DTNEGO   , Nil})
                  aAdd(aFields, {"EEQ_PGT"     , M->EEQ_PGT      , Nil})
                  aAdd(aFields, {"EEQ_NROP"    , M->EEQ_NROP     , Nil})
                  aAdd(aFields, {"EEQ_RFBC"    , M->EEQ_RFBC     , Nil})
                  aAdd(aFields, {"EEQ_TX"      , M->EEQ_TX       , Nil})
                  aAdd(aFields, {"EEQ_BANC"    , M->EEQ_BANC     , Nil})
                  aAdd(aFields, {"EEQ_AGEN"    , M->EEQ_AGEN     , Nil})
                  aAdd(aFields, {"EEQ_NCON"    , M->EEQ_NCON     , Nil})
                  aAdd(aFields, {"EEQ_OBS"     , M->EEQ_OBS      , Nil})
                  aAdd(aFields, {"EEQ_LTPG"    , M->EEQ_LTPG     , Nil})
                  if EasyGParam("MV_AVG0131",,.F.)
                        aAdd(aFields, {"EEQ_MOTIVO"  , M->EEQ_MOTIVO   , Nil})
                  endif
                  If !lMultParcela .and. EasyGParam("MV_AVG0131",,.F.) .and. EasyGParam("MV_EEC0046",,.F.)
                        aAdd( aFields, { "EEQ_ACRESC", M->EEQ_ACRESC , nil } )
                        aAdd( aFields, { "EEQ_DECRES", M->EEQ_DECRES , nil } )
                        aAdd( aFields, { "EEQ_DESCON", M->EEQ_DESCON , nil } )
                        aAdd( aFields, { "EEQ_MULTA" , M->EEQ_MULTA  , nil } )
                        aAdd( aFields, { "EEQ_JUROS" , M->EEQ_JUROS  , nil } )
                  Endif
            Case cOpc == "PAGA_CANCELA_3_4"                  
                  aAdd(aFields, {"EEQ_PGT"     ,  CTod("")       , Nil})
                  aAdd(aFields, {"EEQ_DTCE"    , iif(EasyVermodal('EEQ'), CTod(""), EEQ->EEQ_DTCE)         , Nil}) 
                  aAdd(aFields, {"EEQ_MODAL"   , EEQ->EEQ_MODAL  , Nil})
                  aAdd(aFields, {"EEQ_SOL"     , CTod("")        , Nil})
                  aAdd(aFields, {"EEQ_DTNEGO"  , CTod("")        , Nil})
                  aAdd(aFields, {"EEQ_RFBC"    , ""              , Nil})
                  aAdd(aFields, {"EEQ_TX"      , 0               , Nil})
            Case cOpc == "ALTERA_LOTE"
                  aAdd(aFields, {"EEQ_VCT", M->EEQ_VCT, Nil})
      EndCase

      If EasyEntryPoint("AF900INTCP")
            aCustom := aClone(aFields)
            If ExecBlock("AF900INTCP",.F.,.F., cOpc)
                  aFields := aClone(aCustom)
            EndIf
      EndIf

Return aFields

/*
Fun��o   : AF900DtEmb()
Objetivo : Inicializa o campo virtual EEQ_DTEMBA com a data de embarque para parcelas relacionadas a embarque
*/
Function AF900DtEmb()
Local dRet := CToD("")

      If !Empty(EEQ->EEQ_PREEMB) .AND. EEQ->EEQ_EVENT <> '602' .And. EEQ->EEQ_EVENT <> '605' .And. EEQ->EEQ_EVENT <> '606' .And. EEQ->EEQ_EVENT <> '609' .And. EEQ->EEQ_TIPO <> 'F' .And. EEQ->EEQ_TP_CON <> '3' .And. EEQ->EEQ_TP_CON <> '4'
            dRet := Posicione('EEC', 1, EEQ->EEQ_FILIAL+EEQ->EEQ_PREEMB, 'EEC_DTEMBA')
      EndIf

Return dRet

/*
Fun��o      : IsContrEFF()
Objetivo    : Verifica se o numero de contrato informado no campo EEQ_NROP pertence a um contrato de Financiamento do SIGAEFF
Retorno     : .T. - Contrato existe no EFF; .F. - Contrato n�o existe no EFF;
*/
Static Function IsContrEFF()
Local lRet := .F.

If EasyGParam("MV_EEC_EFF",,.F.)
      EF3->(dbSetOrder(3))//EF3_FILIAL + EF3_TPMODU + EF3_INVOIC + EF3_PARC + EF3_CODEVE
      If EF3->(dbSeek(xFilial("EF3") + IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E") + EEQ->EEQ_NRINVO + If(Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARC,EEQ->EEQ_PARFIN) + "600"))
            lRet := .T.
      EndIf      
EndIf

Return lRet

/*
Fun��o      : MotHistEFF()
Objetivo    : Caso encontre a parcela no contrato EFF, abre a tela para digitar o motivo do estorno.
Retorno     : Retorna o texto digitado para o Motivo do Estorno
*/
Static Function MotHistEFF()
Local cRet := ""

Private lEFFTpMod := .T.
Private lTemChave := .T.

If EasyGParam("MV_EEC_EFF",,.F.)
      //EF3->(dbSetOrder(3))//EF3_FILIAL + EF3_TPMODU + EF3_INVOIC + EF3_PARC + EF3_CODEVE
      //EF1->(dbSetORder(1))//EF1_FILIAL + EF1_TPMODU + EF1_CONTRA + EF1_BAN_FI + EF1_PRACA + EF1_SEQCNT
      //If EF3->(dbSeek(xFilial("EF3") + IF(EEQ->EEQ_TP_CON $ ("2/4"),"I","E") + EEQ->EEQ_NRINVO + If(Empty(EEQ->EEQ_PARFIN),EEQ->EEQ_PARC,EEQ->EEQ_PARFIN) + "600")) .And.;
      //   EF1->(dbSeek(xFilial("EF1") + EF3->EF3_TPMODU + EF3->EF3_CONTRA + EF3->EF3_BAN_FI + EF3->EF3_PRACA + EF3->EF3_SEQCNT))
            cRet := STR0093 + FWTimeStamp(2) + STR0094 + FwGetUserName(RetCodUsr())+"." //EX400MotHis("LIQ", EF1->EF1_CONTRA, EF1->EF1_BAN_FI, EF1->EF1_PRACA, EF1->EF1_TP_FIN, EF3->EF3_PREEMB, EF3->EF3_INVOIC, EF3->EF3_PARC, EF3->EF3_CODEVE, EF3->EF3_SEQ, EF1->EF1_TPMODU, EF1->EF1_SEQCNT) //"Estorno em lote via Painel de C�mbio (EECAF900) em "###" por "
      //EndIf      
EndIf

Return cRet

/*
Fun��o      : MarkAllEFF()
Objetivo    : Ao marcar a primeira parcela, caso a mesma esteja vinculada a um contrato do EFF, verifica se ser� marcadas todas as parcelas do mesmo contrato
Retorno     : -
*/
Method MarkAllEFF(nRecEEQ, cTipo, cExpSQL, cContrato, cTpModu, cBanco) Class AF900MARK
Local cAliasOper := GetNextAlias()
Local lRet := .F.
CriaTmpEFF(cAliasOper, cContrato, cTpModu, cBanco, nRecEEQ, cExpSQL)

If (cAliasOper)->(!EOF()) .And. MsgYesNo(STR0099 + Alltrim(Self:GetNrOp()) + "." + ENTER + STR0100, STR0002) //"Esta parcela possui vincula��o com o contrato de financiamento "### "Deseja que todas as demais parcelas vinculadas ao mesmo contrato de financiamento sejam marcadas pelo sistema?"####Aviso
      Self:SetParcela(nRecEEQ, cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)//Marca a parcela selecionada
      //Marca as outras parcelas do contrato
      While (cAliasOper)->(!EOF())
            Self:SetParcela((cAliasOper)->(R_E_C_N_O_), cTipo, (cAliasOper)->EEQ_VL - (cAliasOper)->EEQ_CGRAFI + (cAliasOper)->EEQ_ACRESC - (cAliasOper)->EEQ_DECRES + (cAliasOper)->EEQ_MULTA + (cAliasOper)->EEQ_JUROS - (cAliasOper)->EEQ_DESCON)
            (cAliasOper)->(dbSkip())
      End
      lRet := .T.
Else //Marca somente a parcela selecionada            
      Self:SetParcela(nRecEEQ, cTipo, EEQ->EEQ_VL - EEQ->EEQ_CGRAFI + EEQ->EEQ_ACRESC - EEQ->EEQ_DECRES + EEQ->EEQ_MULTA + EEQ->EEQ_JUROS - EEQ->EEQ_DESCON)
      lRet := .T.
EndIf

(cAliasOper)->(dbCloseArea())

Return lRet

/*
Fun��o      : BuscaOperac()
Objetivo    : Verifica se existem mais parcelas com o mesmo contrato de financiamento com o mesmo status da parcela que est� sendo verificada
Retorno     : 
*/
Static Function CriaTmpEFF(cAliasOper, cContrato, cTpModu, cBanco, nReqEEQ, cExpSQL)

cExpSQL := "% " + cExpSQL + " %"

BeginSQL Alias cAliasOper

SELECT
  EEQ.R_E_C_N_O_,
  EEQ_VL,
  EEQ_CGRAFI,
  EEQ_ACRESC,
  EEQ_DECRES,
  EEQ_MULTA,
  EEQ_JUROS,
  EEQ_DESCON
FROM
  %table:EEQ% EEQ
  INNER JOIN %table:EF3% EF3 ON (
    EF3_FILIAL = %xFilial:EF3%
    AND EF3_TPMODU = %Exp:cTpModu%
    AND EF3_INVOIC = EEQ_NRINVO
    AND EF3_PREEMB = EEQ_PREEMB
    AND EF3_PARC   = EEQ_PARC	
    AND EF3_CONTRA = EEQ_NROP 
    AND EF3_BAN_FI = EEQ_BANC
  )
  INNER JOIN %table:EEC% EEC ON (
    EEC_FILIAL = %xFilial:EEC%
    AND EEC_PREEMB = EEQ_PREEMB
  ) 
WHERE 
  EEQ_FILIAL         = %xFilial:EEQ%
  AND EEQ_NROP       = %Exp:cContrato%
  AND EF3_CODEVE     = '600' 
  AND EF3_BAN_FI     = %Exp:cBanco%
  AND %Exp:cExpSQL%
  AND EEQ.R_E_C_N_O_ <> %Exp:nReqEEQ%
  AND EEQ.%NotDel%
  AND EF3.%NotDel%
  AND EEC.%NotDel%
ORDER BY EEQ.EEQ_FILIAL, EEQ.EEQ_NRINVO, EEQ.EEQ_PREEMB, EEQ.EEQ_PARC, EEQ.EEQ_FASE, EEQ.EEQ_PROCES

EndSQL

Return
