#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RMIASSINANTE.CH"

Static cBkpLayFil := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCadAssi
Cadastro de Assinantes

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCadAssi()

	Local oBrowse := Nil

    If AmIIn(12)// Acesso apenas para modulo e licença do Varejo
        oBrowse := FWMBrowse():New()
        oBrowse:SetDescription(STR0001)    //"Assinantes"
        oBrowse:SetAlias("MHO")
        oBrowse:SetLocate()
        oBrowse:Activate()
    else
        MSGALERT(STR0011)// "Esta rotina deve ser executada somente pelo módulo 12 (Controle de Lojas)"
        LjGrvLog("RMICADASSI",STR0011)
    EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd(aRotina, { STR0002, "PesqBrw"             , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd(aRotina, { STR0003, "VIEWDEF.RMICADASSI", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd(aRotina, { STR0004, "VIEWDEF.RMICADASSI", 0, 3, 0, NIL } ) //"Incluir"
	aAdd(aRotina, { STR0005, "VIEWDEF.RMICADASSI", 0, 4, 0, NIL } ) //"Alterar"
	aAdd(aRotina, { STR0006, "VIEWDEF.RMICADASSI", 0, 5, 0, NIL } ) //"Excluir"
	aAdd(aRotina, { STR0007, "VIEWDEF.RMICADASSI", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := Nil
	Local oModel     := FWLoadModel("RMICADASSI")
	Local oStructMHO := FWFormStruct(2, "MHO")
    Local oStructMHP := FWFormStruct(2, "MHP")

    oStructMHP:RemoveField("MHP_CASSIN")
    oStructMHP:RemoveField("MHP_LAYFIL")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription(STR0001)    //"Assinantes"

	oView:AddField("RMICADASSI_FIELD_MHO", oStructMHO, "MHOMASTER")
	oView:AddGrid("RMICADASSI_GRID_MHP"  , oStructMHP, "MHPDETAIL")

	oView:CreateHorizontalBox("FORMFIELD", 40)
    oView:CreateHorizontalBox("FORMGRID" , 60)

	oView:SetOwnerView("RMICADASSI_FIELD_MHO", "FORMFIELD")
    oView:SetOwnerView("RMICADASSI_GRID_MHP" , "FORMGRID" )

    oView:EnableTitleView("RMICADASSI_FIELD_MHO", STR0001)    //"Assinantes"
    oView:EnableTitleView("RMICADASSI_GRID_MHP" , STR0008)    //"Assinantes x Processos"

	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0

@obs MHOMASTER - Assinantes
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := Nil
	Local oStructMHO := FWFormStruct(1, "MHO")
    Local oStructMHP := FWFormStruct(1, "MHP")
	
	//----------------------------------------- 
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New("RMICADASSI", /*Pre-Validacao*/, /*Pos-Validacao*/, { |oModel| RmiCommit(oModel)}, { || RmiCancMdl()})
    oModel:SetDescription(STR0009)  //"Modelo de dados dos Assinantes"

    oStructMHO:SetProperty("MHO_COD",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "ExistChav('MHO', M->MHO_COD, 1) .AND. SHPLayouts(M->MHO_COD)"  ) ) //Definindo Valid do assinante para carga dos layouts via Github

	oModel:AddFields("MHOMASTER", Nil, oStructMHO, /*Pre-Validacao*/, /*Pos-Validacao*/)
    oModel:GetModel("MHOMASTER"):SetDescription(STR0001) 	//"Assinantes"

    oModel:AddGrid("MHPDETAIL", "MHOMASTER", oStructMHP, /*bLinePre*/, {|oModelMHP, nLinha| ValLinMHP(oModelMHP, nLinha)}, /*bPre*/, /*bPost*/)
	oModel:GetModel("MHPDETAIL"):SetDescription(STR0008)    //"Assinantes x Processos"
	oModel:SetRelation("MHPDETAIL", { { "MHP_FILIAL", "MHO_FILIAL" }, { "MHP_CASSIN", "MHO_COD" } }, MHP->( IndexKey(1) ))    //MHP_FILIAL+MHP_CASSIN+MHP_CPROCE
	oModel:GetModel("MHPDETAIL"):SetUniqueLine( {"MHP_CPROCE","MHP_TIPO"} )

    oModel:SetActivate( {|oModel| Carga(oModel)} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Carga
Rotina que ira efetuar a carga dos processos padrões na inclusão de um 
novo Assinante.

@author  Rafael Tenorio da Costa
@since   29/10/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Carga(oModel)

    Local aArea      := GetArea()
    Local aProcessos := {}
    Local nProc      := 1
    Local lRetorno   := .T.
    Local cQuery     := ""
    Local cSQL       := ""

    If oModel:GetOperation() == MODEL_OPERATION_INSERT

        oModelMHP  := oModel:GetModel("MHPDETAIL")

        cQuery := "FROM " + RetSqlName("MHN") + " WHERE MHN_FILIAL = '" + xFilial("MHN") + "' AND D_E_L_E_T_ = ' ' "

        cSQL := "SELECT MHN_COD , TIPO = '1' " + cQuery
        cSQL += "UNION SELECT MHN_COD , TIPO = '2' "+cQuery+" ORDER BY MHN_COD"
        LjGrvLog("RMICADASSI","Antes de RmiXSql",cSQL)
        aProcessos := RmiXSql(cSQL, "*", /*lCommit*/, /*aReplace*/)
        LjGrvLog("RMICADASSI","Depois de RmiXSql",aProcessos)

        For nProc:=1 To Len(aProcessos)

            If nProc > 1
                lRetorno := oModelMHP:AddLine() >= nProc
            EndIf
            
            If lRetorno
                oModelMHP:LoadValue("MHP_CPROCE", aProcessos[nProc][1])
                oModelMHP:LoadValue("MHP_TIPO", aProcessos[nProc][2])
                oModelMHP:LoadValue("MHP_ATIVO" , "2")                      //1=Sim,2=Não
            Else
                Exit
            EndIf
        Next nProc

        aSize(aProcessos, 0)
    EndIf

    RestArea(aArea)

Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} ValLinMHP
Valida linha do grid MHP - Assinantes x Processos

@author Rafael Tenorio da Costa
@since  09/06/2016
/*/
//-------------------------------------------------------------------
Static Function ValLinMHP(oModelMHP, nLinha)
	
    Local oModel    := FwModelActive()
	Local lRetorno  := .T.
    Local cFilPro   := ""
    Local aFilPro   := {}
    Local nCont     := 0

    //Valida se a linha não esta deletada
    If !oModelMHP:IsDeleted(nLinha)

        cFilPro := AllTrim( oModelMHP:GetValue("MHP_FILPRO", nLinha) )

        If SubStr(cFilPro, Len(cFilPro)) <> ";"
            cFilPro := cFilPro + ";"
        EndIf            

        aFilPro := StrToKarr(cFilPro, ";")

        For nCont:=1 To Len(aFilPro)

            If !FwFilExist(/*cGrpCompany*/, aFilPro[nCont])
                lRetorno := .F.
                oModel:SetErrorMessage("MHPDETAIL", "MHP_FILPRO", "MHPDETAIL", "MHP_FILPRO", AllTrim( GetSX3Cache("MHP_FILPRO", "X3_TITULO") ), I18n(STR0010, {aFilPro[nCont]}), "")    //"Filial (#1) inválida, verifique."
                LjGrvLog("RMICADASSI", STR0010, aFilPro[nCont])
            EndIf

		Next nCont

        If lRetorno .And. Len(aFilPro) > 0
            oModelMHP:LoadValue("MHP_FILPRO", cFilPro)
        EndIf
    EndIf        
	
Return lRetorno

//------------------------------------------------------------------
/*/{Protheus.doc} GatMHP
Gatilho do objeto MHP

@author Danilo Rodrigues 
@since  27/04/2020
/*/
//-------------------------------------------------------------------
Function GatMHP(cFilVenda, cAssinante, cProcesso, lGatilho)

Local aFilPro   := {} //Guarda todas as filiais
Local cCRLF    	:= Chr(13) + Chr(10) //Pula linha 
Local cLayFil   := "" //Monta o Json
Local nCont     := 0 //Variavel de loop
Local oModel    := Nil //Recebe o model da tela
Local oJsonFil  := Nil //Json com as filiais
Local nI        := 0 //Variavel de loop
Local nPos      := 0 //Posicao da filial no Json

Default cAssinante := ""
Default cProcesso  := "" 
Default lGatilho   := .F.

If lGatilho
    oModel := FwModelActive()
    cFilVenda := oModel:GetValue('MHPDETAIL','MHP_FILPRO')
    cAssinante := AllTrim(oModel:GetValue('MHPDETAIL','MHP_CASSIN'))
    cProcesso := AllTrim(oModel:GetValue('MHPDETAIL','MHP_CPROCE'))
    If Empty(cBkpLayFil)
        cBkpLayFil := oModel:GetValue('MHPDETAIL','MHP_LAYFIL')
    EndIf

    LjGrvLog("RMICADASSI","Entrou em lGatilho", {cFilVenda,cAssinante,cProcesso,cBkpLayFil})
EndIf

If SubStr(Alltrim(cFilVenda), Len(Alltrim(cFilVenda))) == ";"
    cFilVenda := SubStr(Alltrim(cFilVenda), 1,Len(Alltrim(cFilVenda))-1)
EndIf
    
aFilPro := StrTokArr2(cFilVenda, ";")
LjGrvLog("RMICADASSI","Conteudo de aFilPro",aFilPro)

If !Empty(cFilVenda) .AND. cAssinante == "CHEF" .AND. cProcesso == "VENDA"
    
    If Len(aFilPro) > 0
        cLayFil := '{"Filiais":['  + cCRLF 
    EndIf

    If !lGatilho

        For nCont := 1 To Len(aFilPro)

            cLayFil += '{'
            cLayFil += '"Filial":' + '"' + aFilPro[nCont] + '",' + cCRLF
            cLayFil += '"Data":' + ' " ",' + cCRLF
            cLayFil += '"Hora":' + ' " "' + cCRLF

            If nCont < Len(aFilPro) 
                cLayFil += '},' + cCRLF
            Else    
                cLayFil += '}' + cCRLF
            EndIf

        Next nCont

    Else

        oJsonFil := JsonObject():New()
        oJsonFil:FromJson(cBkpLayFil)

        For nCont := 1 To Len(aFilPro) 

            nPos := 0

            For nI := 1 To Len( oJsonFil["Filiais"] )
                If oJsonFil["Filiais"][nI]["Filial"] == aFilPro[nCont]
                    nPos := nI
                    Exit
                EndIF
            Next nI
            
            cLayFil += '{'
            cLayFil += '"Filial":' + '"' + aFilPro[nCont] + '",' + cCRLF
            cLayFil += '"Data":' + ' "' + IIF(nPos > 0, oJsonFil["Filiais"][nPos]["Data"]," ") + '",' + cCRLF
            cLayFil += '"Hora":' + ' "' + IIF(nPos > 0, oJsonFil["Filiais"][nPos]["Hora"]," ") + '"' + cCRLF

            If nCont < Len(aFilPro) 
                cLayFil += '},' + cCRLF
            Else    
                cLayFil += '}' + cCRLF
            EndIf

        Next nCont
        
    EndIf
    
    If Len(aFilPro) > 0
        cLayFil += ']}'
    EndIf

EndIf

Return cLayFil

//------------------------------------------------------------------
/*/{Protheus.doc} RmiCommit
Função para Commit do modelo

@author Bruno Almeida
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Static Function RmiCommit(oModel)

If FWFormCommit( oModel )
    cBkpLayFil := ""
EndIf

Return .T.


//------------------------------------------------------------------
/*/{Protheus.doc} RmiCancMdl
Função para cancel do modelo

@author Bruno Almeida
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Static Function RmiCancMdl()

cBkpLayFil := ""

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} SHPLayouts
Função para setar a régua de processamento do get dos Layouts

@author Evandro Pattaro
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function SHPLayouts(cAssin)
Local oProcess		:= Nil	//objeto da classe MsNewProcess
Local lRet          := .T.
oProcess := MsNewProcess():New( { ||  lRet := SHPGetLay(cAssin,oProcess)} ,STR0013, STR0014+"..." , .T. ) //#"Baixando Layouts" #"Aguarde"
oProcess:Activate()        

Return lRet
//------------------------------------------------------------------
/*/{Protheus.doc} SHPGetLay
Função para carregar os layouts de forma automática

@author Evandro Pattaro
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function SHPGetLay(cAssin,oRegua)
    
    Local oGetLay   := Nil
    Local aArea     := GetArea()
    Local aAreaSM0  := SM0->(GetArea())
    Local aLoad     := {{"configuracao_assinante","MHO_CONFIG"},{"configuracao","MHP_CONFIG"},{"envio","MHP_LAYENV"},{"publicacao","MHP_LAYPUB"}}
    Local aTipo     := {"envia_","busca_"}
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0
    Local oModel    := FwModelActive()
    Local oModelMHO := oModel:GetModel("MHOMASTER")
    Local oModelMHP := oModel:GetModel("MHPDETAIL")
    Local lDados    := .F.
    Local lRet      := .T.
    Local cF3       := ""
    
    If "VENDA DIGITAL" $ cAssin .AND. !IsBlind()
        If "-" $ cAssin
             MsgAlert(STR0021)// O caractere digitado é Inválido '-'.
            Return .F.
        EndIf
        
        If !ConPad1( , , ,'SM0',,,.F.)
            MsgAlert(STR0020)// Filial obrigatoria selecione.
            Return .F.
        else
            cF3 := Alltrim(SM0->M0_CODFIL) //Posicionou no CondPad1
            If !ExistChav('MHO',PadR(Alltrim(cAssin) +"-"+cF3,TAMSX3("MHO_COD")[1]), 1)
                Return .F.    
            EndIf
            oModelMHO:LoadValue("MHO_COD",Alltrim(cAssin) +"-"+cF3)
            M->MHO_COD:= oModelMHO:GetValue("MHO_COD")
        EndIf
    EndIf 
    
    cAssin := Lower(cAssin)// Tratamento de espaço na URL
    
    oGetLay := RmiGetLayObj():New("https://api.github.com/repos/totvs/protheus-smart-hub-layouts/contents/"+Alltrim(cAssin))        

    For nX := 1 to Len(aLoad)            
        oGetLay:GetArq(aLoad[nX,1])
        If oGetLay:lSucesso
            Aadd(aLoad[nX], JsonObject():New())
            aLoad[nX][3]:FromJson(oGetLay:cList)
        Else
            LjGrvLog(" SHPGetLay ",STR0015+" : "+oGetLay:cRetorno) //"Falha na carga da lista dos arquivos de Layout"
            If oGetLay:ogit:oresponseh:cStatuscode == "403"
                MSGALERT(STR0018)//"Limite de solicitações excedido. Tente novamente dentro de 1 hora"
            Else
                MSGALERT(STR0015+" "+STR0019)//"Falha na carga da lista dos arquivos de Layout" "Verifique se o Assinante digitado está correto ou na lista de inclusao automatica no TDN"         
            EndIf    
            Return .T.        
        EndIf

    Next nX

    oModelMHO:SetValue(aLoad[1][2],HttpGet(aLoad[1][3][1]['download_url'])) //JSON de configuração do assinante

    oRegua:SetRegua1(oModelMHP:Length())

    For nX := 1 to oModelMHP:Length()

        oRegua:IncRegua1(STR0016 + oModelMHP:GetValue("MHP_CPROCE"))  //"Analisando processo :"   

        oModelMHP:GoLine(nX)
        lDados := .F.
        If !oModelMHP:IsDeleted()
            oRegua:SetRegua2(Len(aLoad))    
            For nY := 2 To Len(aLoad) //Carga dos arquivos GitHub

                oRegua:IncRegua2(STR0017 + aLoad[nY][1])  //"Carga dos arquivos :"

                For nZ := 1 To Len(aLoad[nY][3]) //Layouts de processos
                    If RAt( aTipo[Val(oModelMHP:GetValue("MHP_TIPO"))]+Replace(Replace(Lower(Alltrim(oModelMHP:GetValue("MHP_CPROCE")))," ","_"),"/","_") , aLoad[nY][3][nZ]['name'] ) > 0                             
                        lDados := .T.       
                        oModelMHP:SetValue(aLoad[nY][2],HttpGet(aLoad[nY][3][nZ]['download_url']))
                        oModelMHP:SetValue("MHP_ATIVO",'1')//ativo
                        oModelMHP:SetValue("MHP_FILPRO",cF3)
                    EndIf                            
                Next nZ
            Next nY
            If !lDados
                oModelMHP:DeleteLine()
            EndIf
        EndIf

    Next nX
RestArea(aAreaSM0)
RestArea(aArea)
Return lRet
