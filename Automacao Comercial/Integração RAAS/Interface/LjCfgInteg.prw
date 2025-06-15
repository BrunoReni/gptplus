#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LJCFGINTEG.CH"

Static oPnlModelo       //Objeto TPanel utilizado para criar os objetos n�o MVC
Static oJsoCfgPro       //Objetos Json criados para controlar o conteudo dos campos _CONFIG e os objetos n�o MVC
Static aJsoCfgSer       //Objetos Json criados para controlar o conteudo dos campos _CONFIG e os objetos n�o MVC

Static cStEstacao                           //Esta��o que ser� utilizada para filtrar a tabela MIJ
Static nStReplica                           //Esta��o que ser� utilizada para filtrar a tabela MIJ
Static aStReplica := {STR0023, STR0024}     //"As Configura��es da Integra��o ser�o replicadas para todas as Esta��es desta Filial."    //"As Configura��es de Integra��o ser�o replicadas para todas as Esta��es de todas as Filiais."

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCfgInteg
Modelo MVC Integra��es Varejo

@type    function
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjCfgInteg()

	Local oBrowse := Nil
    Local lAltFil := .F.    //Indica se o usu�rio tem permiss�o para alterar registros de outras filiais

	oBrowse := FWMBrowse():New()
	oBrowse:SetChgAll(lAltFil)
	oBrowse:SetDescription(STR0001)     //"Integra��es Varejo"
	oBrowse:SetAlias("MII")
	oBrowse:SetLocate()

	oBrowse:SetMenuDef("LJCFGINTEG")
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type   function
@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, {STR0002, "PesqBrw"           , 0, 1, 0, .T. } ) //"Pesquisar"
    aAdd( aRotina, {STR0003, "VIEWDEF.LJCFGINTEG", 0, 2, 0, NIL } )	//"Visualizar"
    aAdd( aRotina, {STR0004, "VIEWDEF.LJCFGINTEG", 0, 3, 0, NIL } )	//"Incluir"
    aAdd( aRotina, {STR0005, "VIEWDEF.LJCFGINTEG", 0, 4, 0, NIL } )	//"Alterar"
    aAdd( aRotina, {STR0006, "VIEWDEF.LJCFGINTEG", 0, 5, 0, NIL } )	//"Excluir"
	aAdd( aRotina, {STR0007, "VIEWDEF.LJCFGINTEG", 0, 8, 0, NIL } )	//"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados das Integra��es Varejo

@type    function
@return  FWFormView, Objeto com as configura��es a interface do MVC
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	 := FwLoadModel( "LJCFGINTEG" )
	Local oStructMII := Nil
	Local oStructMIJ := Nil
	Local oView		 := Nil

    //Objetos Json criados para controlar o conteudo dos campos _CONFIG e os objetos n�o MVC
    oJsoCfgPro  := Nil
    aJsoCfgSer  := {}

	//--------------------------------------------------------------
	//Montagem da interface via dicionario de dados
	//--------------------------------------------------------------
	oStructMII := FWFormStruct( 2, "MII" )
    oStructMII:RemoveField("MII_FILIAL")
    oStructMII:RemoveField("MII_CONFIG")

    oStructMII:SetProperty("MII_PRODUT", MVC_VIEW_CANCHANGE, .F.)
	
	oStructMIJ := FWFormStruct( 2, "MIJ" )
    oStructMIJ:RemoveField("MIJ_FILIAL" )
    oStructMIJ:RemoveField("MIJ_PRODUT" )
	oStructMIJ:RemoveField("MIJ_LGCOD"  )
    oStructMIJ:RemoveField("MIJ_SIGLA"  )
    oStructMIJ:RemoveField("MIJ_CONFIG" )

    oStructMIJ:SetProperty( "MIJ_ATIVO" , MVC_VIEW_ORDEM, "01")
    oStructMIJ:SetProperty( "MIJ_SERVIC", MVC_VIEW_ORDEM, "02")

    oStructMIJ:SetProperty("MIJ_SERVIC", MVC_VIEW_CANCHANGE, .F.)

	//--------------------------------------------------------------
	//Montagem do View normal se Container
	//--------------------------------------------------------------
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription(STR0001)     //"Integra��es Varejo"
    //oView:SetContinuousForm()

	oView:AddField("MIIMASTER_VIEW", oStructMII, "MIIMASTER" )

    //Cria componentes n�o MVC
	oView:AddOtherObject("MII_OTHER_VIEW", { |oPanel, oView| CfgProduto(oPanel) }/*bActivate*/, /*bDeActivate*/, /*bRefresh*/)

	oView:AddGrid("MIJDETAIL_VIEW", oStructMIJ, "MIJDETAIL" )

    //Cria componentes n�o MVC
	oView:AddOtherObject("MIJ_OTHER_VIEW", { |oPanel, oView| CfgServicos(oPanel) }/*bActivate*/, /*bDeActivate*/, /*bRefresh*/)

	oView:CreateHorizontalBox("PANEL_1", 00)
	oView:CreateHorizontalBox("PANEL_2", 30)
    oView:CreateHorizontalBox("PANEL_3", 40)
    oView:CreateHorizontalBox("PANEL_4", 30)

    oView:SetOwnerView("MIIMASTER_VIEW", "PANEL_1")
    oView:SetOwnerView("MII_OTHER_VIEW", "PANEL_2")
	oView:SetOwnerView("MIJDETAIL_VIEW", "PANEL_3")
    oView:SetOwnerView("MIJ_OTHER_VIEW", "PANEL_4")

    oView:EnableTitleView("MII_OTHER_VIEW", STR0013 )   //"Configura��es"
	oView:EnableTitleView("MIJDETAIL_VIEW", STR0014 )   //"Servi�os"

    oView:SetNoInsertLine("MIJDETAIL_VIEW")
    oView:SetNoDeleteLine("MIJDETAIL_VIEW")
    oView:SetViewProperty("MIJDETAIL_VIEW", "CHANGELINE", { { |oView, cViewID| CfgServicos(/*oPanel*/) } } )
    
	oView:AddUserButton(STR0019, "CLIPS", {|oView| BtnComunic()}, STR0015, /*nShortCut*/, /*aOptions*/, .T.)   //"Testar Comunica��o"     //"Efetua o teste de comunica��o."
    oView:AddUserButton(STR0020, "CLIPS", {|oView| BtnReplica()}, STR0020, /*nShortCut*/, /*aOptions*/, .T.)   //"Replicar"

	oView:SetUseCursor(.T.)
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Mode de Integra��es Varejo

@type    function
@return  MpFormModel, Objeto com as configura��es do modelo de dados do MVC
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStructMII := NIL
    Local oStructMIJ := NIL
    Local oModel	 := NIL
    Local aRelaciMIJ := {}

    nStReplica := 0

    Aadd(aRelaciMIJ, {"MIJ_FILIAL", "MII_FILIAL"})
    Aadd(aRelaciMIJ, {"MIJ_PRODUT", "MII_PRODUT"})

    If !Empty(cStEstacao)
        Aadd(aRelaciMIJ, {"MIJ_LGCOD", "'" + cStEstacao + "'"})
    EndIf

	//-----------------------------------------
	//Monta a estrutura do formul�rio com base no dicion�rio de dados
	//-----------------------------------------
	oStructMII := FWFormStruct(1, "MII")

	oStructMIJ := FWFormStruct(1, "MIJ")

	//-----------------------------------------
	//Monta o modelo do formul�rio
	//-----------------------------------------
	oModel:= MpFormModel():New("LJCFGINTEG", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oModel| SalvaMod(oModel)}/*Commit*/, /*Cancel*/)
	oModel:SetDescription(STR0001)	        //"Integra��es Varejo"

	oModel:AddFields("MIIMASTER", /*cOwner*/, oStructMII, /*Pre-Validacao*/, /*Pos-Validacao*/)     //Necessario para passar ser o pai do AddGrid n�o ser� apresentado

	oModel:AddGrid("MIJDETAIL", "MIIMASTER", oStructMIJ, /*bLinePre*/, /*bLinePos*/, /*bPre*/, /*bPost*/ )
    oModel:SetRelation("MIJDETAIL", aRelaciMIJ, MIJ->( IndexKey( 1 ) ) )    //MIJ_FILIAL, MIJ_PRODUT, MIJ_LGCOD, MIJ_SIGLA
	oModel:GetModel("MIJDETAIL"):SetUniqueLine( {"MIJ_SERVIC"} )
    
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} CfgProduto
Fun��o respons�vel pela manitula��o dos objetos n�o MVC do Produto

@type    function
@param   oPanel, TPanel, Panel onde ser�o criados os componentes
@return  L�gico, Define que foram criados os componentes corretamente
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CfgProduto(oPanel)

    Local oModel    := FWModelActive()
    Local oModelDet := oModel:GetModel("MIIMASTER")
    Local cJson     := oModelDet:GetValue("MII_CONFIG")

    //Caso n�o tenha configura��es retorna panel vazio
    If !Empty(cJson)

        oJsoCfgPro := JsonObject():New()
        oJsoCfgPro:FromJson(cJson)    

        //Cria paineis e objetos
        CriaObjPnl(oPanel, oJsoCfgPro["Components"], "oJsoCfgPro['Components']", 15)
    EndIf        

	oPanel:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CfgServicos
Fun��o respons�vel pela manitula��o dos objetos n�o MVC

@type    function
@param   oPanel, TPanel, Panel onde ser�o criados os componentes
@return  L�gico, Define que foram criados os componentes corretamente
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CfgServicos(oPanel)

    Local oModel    := FWModelActive()
    Local oModelDet := oModel:GetModel("MIJDETAIL")
    Local nLinha    := oModelDet:GetLine()
    Local cJson     := oModelDet:GetValue("MIJ_CONFIG")
    Local oJson     := Nil

    //Carrega painel principal de objetos n�o MVC
	If oPanel <> Nil
		oPnlModelo := oPanel

        aSize(aJsoCfgSer, oModelDet:Length())

        oModelDet:GoLine(1)
        nLinha  := oModelDet:GetLine()
        cJson   := oModelDet:GetValue("MIJ_CONFIG")
    Else

        oPanel := oPnlModelo
	Endif

    oPanel:FreeChildren()

    //Caso n�o tenha configura��es retorna panel vazio
    If Empty(cJson)

        aJsoCfgSer[nLinha] := Nil

    //Cria paineis e objetos
    Else

        If aJsoCfgSer[nLinha] == Nil

            oJson := JsonObject():New()
            oJson:FromJson(cJson)

            aJsoCfgSer[nLinha] := oJson
        EndIf

        CriaObjPnl(oPanel, aJsoCfgSer[nLinha]["Components"], "aJsoCfgSer[" + cValToChar(nLinha) + "]['Components']", 05)
    EndIf

	oPanel:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaObjPnl
Fun��o respons�vel por criar os objetos em cada painel

@type    function
@param   oPanel, TPanel, Panel onde ser�o criados os componentes
@param   oJson, JsonObject, Objeto com as configura��es de cada componente que ser� criado no panel
@param   cJson, Caractere, Vari�vel que ser� utilizada por cada componente para atualizar o conte�do
@param   nPosIni, Num�rico, Posi��o inicial da altura do TPanel criado
@author  Rafael Tenorio da Costa
@since   29/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CriaObjPnl(oPanel, oJson, cJson, nPosIni)

    Local aPaineis  := {}
    Local nCampos   := Len(oJson)
    Local nCont     := 0
    Local cCampo    := ""
    Local xConteudo := Nil
    Local cTipo     := ""    
    Local cTitulo   := ""
    Local cVariavel := ""
    Local cAtuObj   := ""
    Local xObjeto   := Nil
    Local bValid    := {|| VldNaoMvc() }
    Local nTamHor   := 155                  //Tamanho do componente na horizontal
    Local nTamVer   := 10                   //Tamanho do componente na vertical
    Local nColIni   := 03                   //Coluna inicial do componente
    Local nLinIni 	:= 01					//Linha inicial do componente
    Local nLinIniCen:= 10                   //Linha inicial do componente centralizado
    Local nPos      := 0

    aPaineis := CriaPaineis(oPanel, nCampos, nPosIni)

    For nCont:=1 To nCampos

        cCampo    := oJson[nCont]["IdComponent"]
        xConteudo := oJson[nCont]["ComponentContent"]
        cTitulo   := oJson[nCont]["Component"]["ComponentLabel"]
        cTipo     := Upper( oJson[nCont]["Component"]["ComponentType"] )

        cVariavel := cJson + "[" + cValToChar(nCont) + "]['ComponentContent']"
        cAtuObj   := "{ |U| Iif(PCOUNT() > 0, " + cVariavel + " := U, " + cVariavel + ") }"

        Do Case

            Case "TEXT" $ cTipo

                &cVariavel := Padr(xConteudo, 254)

                xObjeto := TGet():New( nLinIni, nColIni, &cAtuObj, aPaineis[nCont], nTamHor, nTamVer, oJson[nCont]["Component"]["Parameters"]["Picture"], bValid, 0, , , .F., , .T., ,.F.,,.F.,.F.,,.F.,.F.,, &cVariavel,,,,,,, cTitulo, 1)

                xObjeto:cF3 := oJson[nCont]["Component"]["Parameters"]["F3"]

                If xObjeto:Picture == "@*"
                    xObjeto:lPassword := .T.
                EndIf

            Case cTipo == "CHECKBOX"

                xObjeto := TCheckBox():New( nLinIniCen, nColIni, cTitulo, &cAtuObj, aPaineis[nCont], nTamHor, nTamVer,,,, bValid,,,,.T.,,,)

            Case cTipo $ "COMBOBOX|LISTBOX"

                nPos := aScan( oJson[nCont]["Component"]["Parameters"]["List"], {|x| Alltrim(x) == AllTrim( &cVariavel )} )

                xObjeto := TComboBox():New(nLinIni, nColIni, &cAtuObj, oJson[nCont]["Component"]["Parameters"]["List"], nTamHor, nTamVer, aPaineis[nCont],,, bValid,,,.T.,,,,,,,,, &cVariavel, cTitulo, 1)
                
                xObjeto:Select(nPos)

        End Case

    Next nCont

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaPaineis
Fun��o respons�vel por criar os paneis dentro do painel principal

@type    function
@param   oPanel, TPanel, Panel onde ser�o criados os componentes
@param   nCampos, Num�rico, Quantidade de componentes que ser�o criados
@param   nPosIni, Num�rico, Posi��o inicial da altura do TPanel criado
@return  Array, Com todos os panels criados dentro do panel principal
@author  Rafael Tenorio da Costa
@since   29/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CriaPaineis(oPanel, nCampos, nPosIni)

    Local aPaineis   := {}
    Local nColunas   := 4
    Local nPosIniLar := (oPanel:nWidth / nColunas) * 0.5
    Local nTamLarObj := nPosIniLar
    Local nColuna    := 0
    Local nPosIniAlt := 5
    Local nTamAltObj := 20
    Local nTamMaxAlt := oPanel:nHeight * 0.5
    Local nEspaco    := 3
    Local nEspacoAux := 0

    Default nPosIni  := 5                   //Linha inicial do componente

    For nPosIniAlt := nPosIni To nTamMaxAlt Step (nTamAltObj + nEspaco)

        For nColuna := 0 To nColunas

            If nColuna == 0

                nPosIniLar  := nTamLarObj
                nEspacoAux  := 0
                Aadd(aPaineis, TPanel():New(nPosIniAlt, nEspacoAux              , "", oPanel, ,.T., , /*fontColor*/, /*backgroundColor*/, nTamLarObj, nTamAltObj) )
            Else

                nPosIniLar  := nTamLarObj * nColuna
                nEspacoAux  += nEspaco
                Aadd(aPaineis, TPanel():New(nPosIniAlt, nPosIniLar + nEspacoAux , "", oPanel, , .T., , /*fontColor*/, /*backgroundColor*/, nTamLarObj, nTamAltObj) )
            EndIf

            If nCampos == Len(aPaineis)
                Exit
            EndIf

        Next nColuna

        If Len(aPaineis) >= nCampos
            Exit
        EndIf
        
    Next nAltura

Return aPaineis

//-------------------------------------------------------------------
/*/{Protheus.doc} BtnComunic
Executa o teste de comunica��o no RAC

@type    function
@author  Rafael Tenorio da Costa
@since   29/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function BtnComunic()
    
    Local oModel    := FWModelActive()
    Local oModelDet := oModel:GetModel("MIJDETAIL")
    Local cProduto  := oModelDet:GetValue("MIJ_PRODUT")
    Local cCodEst   := oModelDet:GetValue("MIJ_LGCOD" )
    Local cSigla    := oModelDet:GetValue("MIJ_SIGLA" )
    Local nLinha    := oModelDet:GetLine()
    Local oLjAuthen := LjAuthentication():New(cProduto, cCodEst)
    Local cErro     := ""

    //Atualiza configura��es de produto
    oLjAuthen:SetProductComponents(oJsoCfgPro)

    //Atualiza configura��es de servi�o
    oLjAuthen:SetaServicesComponents(cSigla, aJsoCfgSer[nLinha])

    If oLjAuthen:ConnectionTest(cSigla, .T.)
        MsgInfo(STR0016)    //"Conex�o realizada com sucesso!"
    Else
        
        If !oLjAuthen:oMessageError:GetStatus()
            cErro :=         AllTrim( oLjAuthen:oMessageError:GetMessage("E") )
            cErro += " - " + AllTrim( oLjAuthen:oMessageError:GetMessage("W") )

            LjGrvLog("LjCfgInteg", "Erro ao efetuar teste de comunica��o: " + cErro, /*xVar*/, /*lCallStack*/)
        EndIf

        LjxjMsgErr(STR0017, STR0018, "LjCfgInteg")   //"N�o foi poss�vel efetuar a conex�o."   //"Verifique os dados preenchidos na tela nos agrupamentos de Configura��es e Servi�os."
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldNaoMvc()
Valida componentes n�o MVC

@type    function
@return  L�gico, Define se o campo foi validado
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function VldNaoMvc()

    Local oModel := FWModelActive()
    
    oModel:lModify := .T.   //Alterado para chamar a fun��es de VldData e CommitData do modelo, quando alterado os campos virtuais.
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaMod(oModel)
Faz o commit das informa��es

@type    function
@param   oModel, MpFormModel, Modelo MVC que ser� salvo
@return  L�gico, Define se as informa��es for�o salvas corretamente
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function SalvaMod(oModel)

    Local lRetorno  := .F.
    Local nLinha    := 1
    Local oModelDet := oModel:GetModel("MIJDETAIL")
    Local nOperacao := oModel:GetOperation()

    If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE

        oModel:SetValue("MIIMASTER", "MII_CONFIG", oJsoCfgPro:ToJson())

        For nLinha:=1 To oModelDet:Length()

            oModelDet:GoLine(nLinha)

            //N�o foi alterado nada
            If aJsoCfgSer[nLinha] == Nil
                Loop
            EndIf

            oModelDet:SetValue("MIJ_CONFIG", aJsoCfgSer[nLinha]:ToJson())
        Next nLinha

        //Replica informa��es
        Replicar(oModel)
    EndIf

    lRetorno := FwFormCommit(oModel)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCfInSEst()
Seta esta��o que ser� utilizada para filtrar a tabela MIJ

@type    function
@param   cCodEst, Caractere, C�digo da esta��o
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjCfInSEst(cCodEst)
    cStEstacao := cCodEst
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Replicar(oModel)
Replica informa��es para demais Filiais e Esta��es

@type    function
@param   oModel, MpFormModel, Modelo MVC que ser� salvo
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function Replicar(oModel)

    Local aArea     := GetArea()
    Local aAreaMII  := MII->( GetArea() )
    Local aAreaMIJ  := MIJ->( GetArea() )
    Local oModelDet := oModel:GetModel("MIJDETAIL")
    Local nServicos := oModelDet:Length()
    Local nSer      := 0
    Local cProduto  := oModel:GetValue("MIIMASTER", "MII_PRODUT")
    Local cCfgProdut:= oModel:GetValue("MIIMASTER", "MII_CONFIG")
    Local aFiliais  := {}
    Local nFiliais  := 0    
    Local nFil      := 0
    Local lAchou    := .F.
    Local cSql      := ""
    Local aEstacoes := {}
    Local nEstacoes := 0
    Local nEst      := 0
    Local cBkpFilAnt:= cFilAnt

    //"1=Somente Esta��es da Filial corrente", "2=Todas as Esta��es de todas Filiais"}
    If nStReplica > 0 .And. MsgYesNo( aStReplica[nStReplica] + CRLF + CRLF + STR0031, STR0025)   //"Confirma Replica��o ?"   //"Aten��o"

        //"1=Somente Esta��es da Filial corrente"
        If nStReplica == 1
            Aadd(aFiliais, xFilial("MII"))

        //"2=Todas as Esta��es de todas Filiais"
        Else
            aFiliais := FWAllFilial(/*cCompany*/, /*cUnitBusiness*/, /*cGrpCompany*/, .F./*lOnlyCode*/)
        EndIf
        nFiliais := Len(aFiliais)

        For nFil:=1 To nFiliais

            cFilAnt := aFiliais[nFil]

            MII->( DBSetOrder(1) )      //MII_FILIAL + MII_PRODUT
            lAchou := MII->( DbSeek(xFilial("MII") + cProduto) )

            RecLock("MII", !lAchou)
                MII->MII_FILIAL := xFilial("MII")
                MII->MII_PRODUT := cProduto
                MII->MII_CONFIG := cCfgProdut
            MII->( MsUnlock() )

            cSql      := "SELECT LG_CODIGO FROM " + RetSqlName("SLG") + " WHERE D_E_L_E_T_ = ' ' AND LG_FILIAL = '" + xFilial("SLG") + "'"
            aEstacoes := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)
            nEstacoes := Len(aEstacoes)

            For nEst:=1 To nEstacoes

                For nSer:=1 To nServicos

                    oModelDet:GoLine(nSer)

                    MIJ->( DBSetOrder(1) )      //MIJ_FILIAL + MIJ_PRODUT + MIJ_LGCOD + MIJ_SIGLA
                    lAchou := MIJ->( DbSeek(xFilial("MIJ") + cProduto + aEstacoes[nEst][1] + oModelDet:GetValue("MIJ_SIGLA")) )

                    RecLock("MIJ", !lAchou)
                        MIJ->MIJ_FILIAL := xFilial("MIJ")
                        MIJ->MIJ_PRODUT := cProduto
                        MIJ->MIJ_LGCOD  := aEstacoes[nEst][1]
                        MIJ->MIJ_SIGLA  := oModelDet:GetValue("MIJ_SIGLA" )
                        MIJ->MIJ_SERVIC := oModelDet:GetValue("MIJ_SERVIC")
                        MIJ->MIJ_ATIVO  := oModelDet:GetValue("MIJ_ATIVO" )
                        MIJ->MIJ_CONFIG := oModelDet:GetValue("MIJ_CONFIG")
                    MIJ->( MsUnlock() )
                Next nSer

            Next nEst

        Next nFil
    EndIf

    nStReplica := 0

    cFilAnt := cBkpFilAnt

    RestArea(aAreaMIJ)
    RestArea(aAreaMII)
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BtnReplica()
Wizard para configura��o do Andamento Automatico

@type    function
@author  Rafael Tenorio da Costa
@since 	 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function BtnReplica()

	Local aArea     := GetArea()
	Local oWizard   := Nil
	Local nPanel    := 1
	Local oPanel1   := Nil
	Local oLayer1   := Nil
	Local oColumn1  := Nil 
	Local oPanel2   := Nil
	Local oLayer2   := Nil
	Local oColumn2  := Nil
    Local nRadio    := 1
    Local aRadio    := {STR0021, STR0022}   //"Somente Esta��es da Filial corrente"      //"Todas as Esta��es de todas Filiais"
	Local aSizeD    := FWGetDialogSize( oMainWnd )
    Local aCoord    := { aSizeD[1]*0.40, aSizeD[2]*0.40, aSizeD[3]*0.60, aSizeD[4]*0.40 }

    nStReplica      := 0

	oWizard := APWizard():New(	STR0025/*<chTitle>*/    ,;	//"Aten��o"
								STR0026/*<chMsg>*/      ,;  //"Este assistente o auxiliara na replica��o das Configura��es da Integra��o"
								STR0027/*<cTitle>*/     ,;  //"Replica��o das Configura��es da Integra��o"
								STR0028/*<cText>*/      ,;	//"Neste assistente ser� poss�vel replicar as informa��es para as Esta��es desta Filial ou para as demais Filiais e Esta��es."
								{|| .T.}/*<bNext>*/     ,;
								{|| .T.}/*<bFinish>*/   ,;
								/*<lPanel>*/            ,;
								/*<cResHead> */         ,;
								/*<bExecute>*/          ,;
								/*<lNoFirst>*/          ,;
								aCoord/*<aCoord>*/      )

	//---------- Panel sel��o de Esta��es ----------
	oWizard:NewPanel(	STR0029/*<chTitle>*/        ,;	//"Replicar configura��es para quais Esta��es ?"
						STR0030/*<chMsg>*/          ,;  //"Neste ponto ser�o definidas as Esta��es que ir�o receber as Configura��es da Integra��o."
					 	{||.T.}/*<bBack>*/          ,;
					 	{|| nRadio > 0 }/*<bNext>*/ ,;
					 	{||.T.}/*<bFinish>*/        ,;
					 	.T./*<.lPanel.>*/           ,;
					 	{||.T.}/*<bExecute>*/       )

	nPanel++
	oPanel1 := oWizard:GeTPanel(nPanel)
	oLayer1 := FWLayer():New()
	oLayer1:Init(oPanel1, .F.)
	oLayer1:AddCollumn("BOX_FULL", 100, .F.)

	oColumn1 		:= oLayer1:getColPanel("BOX_FULL", Nil)
	oColumn1:Align 	:= CONTROL_ALIGN_ALLCLIENT
	
    TRadMenu():New( oColumn1:nTop + 10, oColumn1:nLeft + 10, aRadio, {|u|Iif (PCOUNT() > 0, nRadio := u, nRadio)}, oColumn1,,,,,,,,100,12,,,,.T.)

	//---------- Panel Confirma��o ----------
	oWizard:NewPanel(	STR0031/*<chTitle>*/                    ,;	//"Confirma Replica��o ?"
						STR0032/*<chMsg>*/                      ,;	//"Veja as configura��es que ser�o feitas"
					 	{||.T.}/*<bBack>*/                      ,;
					 	{||.T.}/*<bNext>*/                      ,;
					 	{|| nStReplica := nRadio}/*<bFinish>*/  ,;
					 	.T./*<.lPanel.>*/                       ,;
					 	{||.T.}/*<bExecute>*/                   )

	nPanel++
	oPanel2 := oWizard:GeTPanel(nPanel)
	oLayer2 := FWLayer():New()
	oLayer2:Init(oPanel2, .F.)
	oLayer2:AddCollumn("BOX_FULL", 100, .F.)

	oColumn2 		:= oLayer2:getColPanel("BOX_FULL", Nil)
	oColumn2:Align 	:= CONTROL_ALIGN_ALLCLIENT
	
	TSay():New(oColumn2:nTop + 010, oColumn2:nLeft + 10, {|| STR0025 }                  , oColumn2,,,,,, .T.,,, 290, 010)   //"Aten��o"
    
	TSay():New(oColumn2:nTop + 030, oColumn2:nLeft + 10, {|| aStReplica[nRadio] }       , oColumn2,,,,,, .T.,,, 290, 010)

    TSay():New(oColumn2:nTop + 050, oColumn2:nLeft + 10, {|| I18n(STR0033, {STR0001}) } , oColumn2,,,,,, .T.,,, 290, 010)   //"Estas configura��es ser�o salvas quando a interface #1 for confirmada."      //"Integra��es Varejo"
	
	oWizard:Activate( .T./*<.lCenter.>*/,;
					 {||.T.}/*<bValid>*/,;
					 {||.T.}/*<bInit>*/	,;
					 {||.T.}/*<bWhen>*/ )
					 
	FwFreeObj(oWizard)
	RestArea(aArea)

Return Nil