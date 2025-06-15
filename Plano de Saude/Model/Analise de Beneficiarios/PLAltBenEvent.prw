#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include "PLALTBENMODEL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLAltBenEvent
Classe de Eventos do MVC para validar/commit o modelo PLAltBenModel
(Altera��o cadastral do benefici�rio)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Class PLAltBenEvent From FWModelEvent
 
    Data cLayoutWeb As String
    Data cSequenLayout As String
    Data cOrdemLayout As String
    Data cErrorMessage As String
    Data aAnexos As Array

    Method New() CONSTRUCTOR

    Method After(oSubModel, cModelId, cAlias, lNewRecord)
    Method Before(oSubModel, cModelId, cAlias, lNewRecord)
    Method AfterTTS(oModel, cModelId)                                                       
    Method BeforeTTS(oModel, cModelId)                                                     
    Method InTTS(oModel, cModelId)                                                          
    Method Activate(oModel, lCopy)
    Method DeActivate(oModel)   
    Method VldActivate(oModel, cModelId)
    Method ModelPreVld(oModel, cModelId)
    Method ModelPosVld(oModel, cModelId)
    Method GridPosVld(oSubModel, cModelID)
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    Method GridLinePosVld(oSubModel, cModelID, nLine)                                       
    Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
    Method FieldPosVld(oSubModel, cModelID)                  

    // M�todos auxiliares
    Method GetSequenLayout()
    Method GetOrdemLayout()
    Method GetDadosLayout(cCampo)
    Method ValidCmpObrigat(oSubModel, nItem)
    Method DownloadAnexos()
    Method AnexarArquivos(cAlias, cChaveDocument)
 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PLAltBenEvent

    Self:cLayoutWeb := GetNewPar("MV_PLLAYAL", "PPLALTBEN") // Parametro que define o Layout utilizado na API de altera��o cadastral do benefici�rio 
    Self:cErrorMessage := ""
    Self:cSequenLayout := ""
    Self:cOrdemLayout := ""
    Self:aAnexos := {}

    Self:GetSequenLayout()
    Self:GetOrdemLayout()

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} After
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit 
depois da grava��o de cada submodelo (field ou cada linha de uma grid)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PLAltBenEvent

    Local oDados := Nil
    Local aGravacao := {}
    Local aDados:= {}

    Private lGrvDadServ := .F. // Variavel utilizada na fun��o PLGRVLWEB

    If cModelId == "DETAILB7L"

        // Grava��o direta da altera��o cadastral do benefici�rio
        If oSubModel:GetValue("B7L_GRAVAD") .And. Alltrim(oSubModel:GetValue("B7L_VLANT")) <> Alltrim(oSubModel:GetValue("B7L_VLPOS"))
 
            oDados := Self:GetDadosLayout(Alltrim(oSubModel:GetValue("B7L_CAMPO")))

            If oDados["status"]

                aAdd(aDados, "BA1")
                aAdd(aDados, oDados["dados"]["variavel"])
                aAdd(aDados, Alltrim(oSubModel:GetValue("B7L_VLPOS")))
                aAdd(aDados, "")
                aAdd(aDados, .F.)
                aAdd(aDados, oDados["dados"]["campo"])
                aAdd(aDados, Val(oSubModel:GetValue("B7L_RECREG")))

                aAdd(aGravacao, aDados)

                PLGRVLWEB(Self:cLayoutWeb, aGravacao, "", Alltrim(oSubModel:GetValue("B7L_RECREG")), .T.)

                aGravacao := aSize(aGravacao, 0)         	
                aDados := aSize(aDados, 0)
                aDados := Nil
                aGravacao := Nil

            EndIf
        EndIf
    EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Before
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes 
da grava��o de cada submodelo (field ou cada linha de uma grid)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PLAltBenEvent    

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do  ap�s a 
transa��o. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method AfterTTS(oModel, cModelId) Class PLAltBenEvent


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit antes 
da transa��o. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method BeforeTTS(oModel, cModelId) Class PLAltBenEvent 

    Local cChaveDocument := xFilial("BBA")+oModel:GetValue("MASTERBBA", "BBA_CODSEQ")

    If Len(Self:aAnexos) > 0
        If Self:AnexarArquivos("BBA", cChaveDocument)

            If oModel:GetValue("MASTERBBA", "BBA_STATUS") == "1" // 1 = Pendente de Documenta��o
                oModel:LoadValue("MASTERBBA", "BBA_STATUS", "2") // 2 = Em Analise
            EndIf
        EndIf
    EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit Ap�s 
as grava��es por�m antes do final da transa��o. Esse evento ocorre 
uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method InTTS(oModel, cModelId) Class PLAltBenEvent

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
M�todo que � chamado pelo MVC quando ocorrer a ativa��o do Model. 
Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method Activate(oModel, lCopy) Class PLAltBenEvent


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
M�todo que � chamado pelo MVC quando ocorrer a desativa��o do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method DeActivate(oModel) Class PLAltBenEvent

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
M�todo que � chamado pelo MVC quando ocorrer as a��es de valida��o 
do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method VldActivate(oModel, cModelId) Class PLAltBenEvent

    Local lOK := .T.

    If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
        Do Case 
            Case !(BBA->BBA_STATUS == "1" .Or. (BBA->BBA_STATUS == "2" .And. !ExistCpo("B5G", BBA->(BBA_CODINT+BBA_CODSEQ), 3))) // 1 = Pendente de Documenta��o ; B5G = Passos da Analise
                Help("", 1, "VALID", Nil, STR0013,  1, 0) // "N�o � permitido excluir ou alterar protocolo de solicita��o quando estiver em analise ou finalizado."
                lOk := .F.
            
            Case BBA->BBA_TIPMAN == "1" // 1 = Inclus�o
                Help("", 1, "VALID", Nil, STR0014,  1, 0) // "N�o � permitido alterar ou excluir um protocolo de solicita��o de inclus�o cadastral."
                lOk := .F.
            
            Case !Empty(Self:cErrorMessage)
                Help("", 1, "VALID", Nil, Self:cErrorMessage,  1, 0) 
                lOK := .F.
        EndCase
    EndIf

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPreVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o 
do Model. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method ModelPreVld(oModel, cModelId) Class PLAltBenEvent

    Local lOK := .T.

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o 
do Model. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method ModelPosVld(oModel, cModelId) Class PLAltBenEvent

    Local lOK := .T.
    Local nX := 0
    Local lAllAprovado := .T.
    Local cNumeroProtocolo := ""
    Local oModelBBA := oModel:GetModel("MASTERBBA")
    Local oModelB7L := oModel:GetModel("DETAILB7L")
    Local aSaveLines := FWSaveRows()
    
    If Empty(oModelBBA:GetValue("BBA_NROPRO"))

        cNumeroProtocolo := Posicione("BA0", 1, xFilial("BA0")+oModelBBA:GetValue("BBA_CODINT"), "BA0_SUSEP") + DToS(dDataBase) + oModelBBA:GetValue("BBA_CODSEQ")
        oModelBBA:SetValue("BBA_NROPRO", cNumeroProtocolo)

    EndIf

    For nX := 1 To oModelB7L:Length()

        oModelB7L:GoLine(nX)

        If Alltrim(oModelB7L:GetValue("B7L_VLANT")) == Alltrim(oModelB7L:GetValue("B7L_VLPOS"))
            oModelB7L:LoadValue("B7L_GRAVAD", .T.)
        EndIf

        If !oModelB7L:GetValue("B7L_GRAVAD")
            lAllAprovado := .F.
            Exit
        EndIf

    Next nX

    If lAllAprovado
        oModelBBA:LoadValue("BBA_APROVA", .T.)
        oModelBBA:LoadValue("BBA_STATUS", "7") // 7 = Aprovado Automaticamente
    EndIf

    FWRestRows(aSaveLines)

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} GridPosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de p�s valida��o 
do Grid.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method GridPosVld(oSubModel, cModelID) Class PLAltBenEvent

    Local lOK := .T.
    Local nX := 0
    Local oDadosAnexos := Nil
    Local aSaveLines := FWSaveRows()

    Do Case
        Case cModelID == "DETAILB7L"
            For nX := 1 To oSubModel:Length()
                oSubModel:GoLine(nX)

                If oSubModel:IsDeleted()
                    Loop
                EndIf

                // Valida campos obrigatorios
                If !Self:ValidCmpObrigat(oSubModel, nX)
                    lOk := .F.
                    Exit
                EndIf        
            Next nX

        Case cModelID == "DETAILANEXO"
            Self:aAnexos := {}

            For nX := 1 To oSubModel:Length()
                oSubModel:GoLine(nX)

                If !oSubModel:IsInserted() .And. !oSubModel:IsUpdated()
                    Loop
                EndIf

                If !Empty(oSubModel:GetValue("DIRECTORY")) .And. !Empty(oSubModel:GetValue("FILENAME"))

                    oDadosAnexos := JsonObject():New()

                    oDadosAnexos["userDirectory"] := Alltrim(oSubModel:GetValue("DIRECTORY"))
                    oDadosAnexos["fileName"] := Alltrim(oSubModel:GetValue("FILENAME"))
                    oDadosAnexos["serverDirectory"] := "" // Server ser� preenchido no DownloadAnexos

                    aAdd(Self:aAnexos, oDadosAnexos)
                EndIf

            Next nX

            If Len(Self:aAnexos) > 0
                If !Self:DownloadAnexos()
                    lOk := .F.
                EndIf
            EndIf
    EndCase

    FWRestRows(aSaveLines)

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o 
da linha do Grid.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class PLAltBenEvent

    Local lOK := .T.
    Local oDados := Nil
    Local oModel := FWModelActive()
    
    Do Case
        Case cAction == "SETVALUE" .And. cModelID == "DETAILB7L" 
            Do Case
                Case Empty(oModel:GetValue("MASTERBBA", "BBA_MATRIC"))
                    Help("", 1, "VALID", Nil, STR0004,  1, 0)  // "Primeiro dever� ser preenchido a matricula do benefici�rio."
                    lOK := .F.

                Case cId == "B7L_CAMPO" .And. !Empty(xValue)

                    If BA1->(FieldPos(Alltrim(xValue))) == 0
                        Help("", 1, "VALID", Nil, STR0005+" ["+xValue+"]",  1, 0) // "Campo informado n�o encontrado na base de dados"
                        lOK := .F.
                    Else
                        oDados := Self:GetDadosLayout(Alltrim(xValue))

                        If oDados["status"]
                            Do Case
                                Case !oDados["dados"]["editar"]
                                    Help("", 1, "VALID", Nil, STR0007+" ["+xValue+"]",  1, 0) // "Campo n�o permite edi��o no layout de altera��o cadastral"
                                    lOK := .F.
                            EndCase

                            If lOK
                                If oDados["dados"]["valida"]
                                    oSubModel:LoadValue("B7L_GRAVAD", .F.)
                                Else
                                    oSubModel:LoadValue("B7L_GRAVAD", .T.)
                                EndIf
                            EndIf
                        Else
                            Help("", 1, "VALID", Nil, STR0008+" ["+xValue+"]",  1, 0) // "Campo n�o encontrado no layout de altera��o cadastral"
                            lOK := .F.
                        EndIf

                    EndIf        
            EndCase 
        
        Case cModelID == "DETAILANEXO" 
            Do Case
                Case cAction == "SETVALUE" .And. !oSubModel:IsInserted() .And. !Empty(xCurrentValue) .And. !oSubModel:IsUpdated()
                    Help("", 1, "VALID", Nil, STR0015,  1, 0) // "N�o � permitido alterar um anexo j� cadastrado."
                    lOk := .F.
                
                Case cAction == "DELETE" .And. !oSubModel:IsInserted() .And. !oSubModel:IsUpdated()
                    Help("", 1, "VALID", Nil, STR0016,  1, 0) // "N�o � permitido excluir um anexo j� cadastrado." 
                    lOk := .F.
            EndCase
    EndCase

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o 
da linha do Grid.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method GridLinePosVld(oSubModel, cModelID, nLine) Class PLAltBenEvent 

    Local lOK := .T.

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPreVld
M�todo que � chamado pelo MVC quando ocorrer a a��o de pr� valida��o 
do Field.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class PLAltBenEvent

    Local lOK := .T.

Return lOK



//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPosVld
M�todo que � chamado pelo MVC quando ocorrer a a��o de p�s valida��o 
do Field.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/03/2022
/*/
//------------------------------------------------------------------- 
Method FieldPosVld(oSubModel, cModelID) Class PLAltBenEvent 

    Local lOK := .T.

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSequenLayout
Busca o sequencial do Layout Web de altera��o cadastral

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 16/03/2022
/*/
//------------------------------------------------------------------- 
Method GetSequenLayout() Class PLAltBenEvent

    B90->(DbSetOrder(2))
    If B90->(MsSeek(xFilial("B90")+Self:cLayoutWeb))
        If B90->B90_ATIVO == "1" // 1 = Sim
            Self:cSequenLayout := B90->B90_SEQUEN
        Else
            Self:cErrorMessage := STR0010 // "Layout Web de Altera��o n�o est� ativo."
        EndIf
    EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GetOrdemLayout
Busca a ordem do sequencial do Layout Web de altera��o cadastral

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 16/03/2022
/*/
//------------------------------------------------------------------- 
Method GetOrdemLayout() Class PLAltBenEvent

    Local cAliasTemp := ""
    
    If !Empty(Self:cSequenLayout)
        cAliasTemp := GetNextAlias()

        BeginSQL Alias cAliasTemp
            SELECT B7C.B7C_ORDEM AS ORDEM
                FROM %Table:B7C% B7C
                WHERE B7C_FILIAL = %XFilial:B7C% AND
                    B7C_SEQB90 = %Exp:Self:cSequenLayout% AND
                    B7C_ALIAS = %Exp:'BA1'% AND
                    %NotDel%
        EndSQL

        If !(cAliasTemp)->(EoF())
            Self:cOrdemLayout := Alltrim((cAliasTemp)->ORDEM)
        Else
            Self:cErrorMessage := STR0011 // "Layout Web de Altera��o n�o configurado."
        EndIf

        (cAliasTemp)->(DbCloseArea())
    EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadosLayout
Retorna os dados do campo referente ao layout

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 16/03/2022
/*/
//------------------------------------------------------------------- 
Method GetDadosLayout(cCampo) Class PLAltBenEvent

    Local oRetorno := JsonObject():New()

    oRetorno["status"] := .F.
    oRetorno["dados"] := JsonObject():New()

    If !Empty(cCampo)
        cCampo := Lower(GetSx3Cache(cCampo, "X3_TIPO"))+cCampo
        
        B91->(DbSetOrder(1))
        If B91->(MsSeek(xFilial("B91")+Self:cSequenLayout+Self:cOrdemLayout+cCampo))

            oRetorno["status"] := .T.
            oRetorno["dados"]["editar"] := B91->B91_EDITAR
            oRetorno["dados"]["obrigatorio"] := B91->B91_OBRIGA
            oRetorno["dados"]["ativo"] := B91->B91_VISUAL
            oRetorno["dados"]["tipo"] := B91->B91_TIPO
            oRetorno["dados"]["campo"] := Alltrim(B91->B91_CAMPO)
            oRetorno["dados"]["descricao"] := Alltrim(B91->B91_DESCRI)
            oRetorno["dados"]["variavel"] := Alltrim(B91->B91_NOMXMO)
            oRetorno["dados"]["valida"] := .F.

            B2C->(DbSetOrder(2))
            If B2C->(MsSeek(xFilial("B2C")+Self:cSequenLayout+cCampo))
                While !B2C->(EoF()) .And. B2C->B2C_FILIAL == xFilial("B2C") .And. B2C->B2C_SEQB90 == Self:cSequenLayout .And. Alltrim(B2C->B2C_CMPB91) == cCampo
                    
                    If Alltrim(B2C->B2C_VAR) == "VALIDA" .And. !Empty(B2C->B2C_VALOR)
                        oRetorno["dados"]["valida"] := .T.
                    EndIf

                    B2C->(DbSkip())
                EndDo
            EndIf 
        EndIf
    EndIf

Return oRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCmpObrigat
Valida os campos obrigatorios no modelo de acordo com o Layout
Generico

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 31/05/2022
/*/
//------------------------------------------------------------------- 
Method ValidCmpObrigat(oSubModel, nItem) Class PLAltBenEvent

    Local oDados := Nil
    Local lValid := .T.
    Local aCmpObrigat := {"B7L_CAMPO", "B7L_VLPOS"}
    Local cCampoCadastro := ""
    Local nX := 0
    Local cCampo := ""
    Local lValueObrigat := .F.

    oDados := Self:GetDadosLayout(Alltrim(oSubModel:GetValue("B7L_CAMPO")))

    If oDados["status"]
        lValueObrigat := oDados["dados"]["obrigatorio"]
    EndIf

    For nX := 1 To Len(aCmpObrigat)

        cCampo := aCmpObrigat[nX]

        If cCampo == "B7L_CAMPO"
            cCampoCadastro := oSubModel:GetValue(cCampo)
        EndIf

        If (Empty(oSubModel:GetValue(cCampo)) .And. cCampo <> "B7L_VLPOS") .Or. (cCampo == "B7L_VLPOS" .And. Empty(oSubModel:GetValue(cCampo)) .And. lValueObrigat)
            Help("", 1, "VALID", Nil, STR0017+"("+cCampo+"->"+cCampoCadastro+")"+STR0018+"["+STR0019+cValToChar(nItem)+"]",  1, 0) // "O campo " ; " n�o foi preenchido." ; "Item: "
            lValid := .F.
            Exit
        EndIf

    Next Nx

Return lValid


//-------------------------------------------------------------------
/*/{Protheus.doc} DownloadAnexos
Realiza o download dos anexos recebidos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/06/2022
/*/
//------------------------------------------------------------------- 
Method DownloadAnexos() Class PLAltBenEvent

    Local lDownload := .T.
	Local nX := 0
	Local cNomeArquivo := ""
	Local cDiretorio := ""
	Local cExtensao := ""
    Local lStatus := .F.
    Local cError := ""
	Local nStatusCode := 0
	Local nCodError := 0
	Local lWrite := .F.
	Local cPathWeb := GetNewPar("MV_PLURDOW", "")
	
	Default aDownload := {}
	Default cLocalFile := ""

    ACB->(DbSetOrder(2))

	For nX := 1 To Len(Self:aAnexos)

		cDiretorio := Self:aAnexos[nX]["userDirectory"]
		cNomeArquivo := Self:aAnexos[nX]["fileName"]

		splitPath(cDiretorio, Nil, Nil, Nil, @cExtensao)

        If At("?", cExtensao) > 0
			cExtensao := Substr(cExtensao, 1, At("?", cExtensao)-1)
		EndIf

		If Empty(cPathWeb)
			cPathWeb := PLSMUDSIS(GetWebDir()+GetSkinPls()+"\relatorios\")
		EndIf

		If !File(cPathWeb+cNomeArquivo+cExtensao)
         
			If ACB->(MsSeek(xFilial("ACB")+Upper(cNomeArquivo+cExtensao)))
				Help("", 1, "VALID", Nil, STR0020+" ["+cNomeArquivo+cExtensao+"]",  1, 0) // "Nome do arquivo ja existe no banco de conhecimento, altere o nome e tente novamente!"
				lDownload := .F.
				Exit
			EndIf

            If "HTTPS:" $ Upper(cDiretorio) .Or. "HTTP:" $ Upper(cDiretorio) // Arquivo Web
			    lWrite :=  MemoWrite(cPathWeb+cNomeArquivo+cExtensao, HttpGet(cDiretorio))
                nStatusCode := HTTPGetStatus(@cError)

                If !lWrite
                    nCodError := FError()
                EndIf

                lStatus := nStatusCode == 200
            Else
                lStatus := CpyT2S(cDiretorio, cPathWeb)

                If lStatus
                    lStatus := fRename(cPathWeb+Lower(AllTrim(SubStr(cDiretorio, Rat(PLSMUDSIS('\'), cDiretorio)+1))), cPathWeb+cNomeArquivo+cExtensao) == 0 // Renomeia Arquivo
                EndIf
            EndIf

			If lStatus .And. File(cPathWeb+cNomeArquivo+cExtensao)
				Self:aAnexos[nX]["serverDirectory"] := cPathWeb+cNomeArquivo+cExtensao
			Else    
                Help("", 1, "VALID", Nil, STR0021+"["+cDiretorio+"]",  1, 0) // "N�o foi possivel localizar o anexo informado."
				lDownload := .F.
				Exit
			EndIf
		Else
            Help("", 1, "VALID", Nil, STR0022,  1, 0) // "J� existe um anexo com esse nome de arquivo."
            lDownload := .F.
            Exit
		EndIf

	Next nX

Return lDownload


//-------------------------------------------------------------------
/*/{Protheus.doc} AnexarArquivos
Anexa os arquivos no protocolo - Banco de conhecimento

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/06/2022
/*/
//------------------------------------------------------------------- 
Method AnexarArquivos(cAlias, cChaveDocument) Class PLAltBenEvent

	Local nX := 0
	Local lAnexo := .F.

    If !Empty(cAlias) .And. !Empty(cChaveDocument)
        For nX := 1 To Len(Self:aAnexos)

            PLSINCONH(Self:aAnexos[nX]["serverDirectory"], cAlias, cChaveDocument, .T.)

            fErase(Self:aAnexos[nX]["serverDirectory"])
            lAnexo := .T.
        Next nX
    EndIf

Return lAnexo