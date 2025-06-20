#Include "FISA300F.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300F()

Rotina para auxiliar a gera��o dos t�tulos da apura��o de ISS

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300F(cIdF1P, dDtRef, cOpc)

Local nRet	    := 0
Local lExibeCon := .F.

Private lMsErroAuto := .F.
Private aApurMun    := {}
Private oApurISS    := APURISS():New()
Private cOpcao      := cOpc //1=Somente T�tulo;2=T�tulo+Contabiliza��o;3=Somente Contabiliza��o
    
//Faz carga dos valores da apura��o
oApurISS:LoadApur(cIdF1P)

BEGIN TRANSACTION

//Processa informa��es da F1R, para que o usu�rio possa realizar eventuais ajustes antes de gravar os t�tulos
ProcF1R(dDtRef)

//Executa a View da F1R
nRet	:= FWExecView(STR0001 ,'FISA300F', MODEL_OPERATION_UPDATE,,, { || OnClose() },,,{ || OnExit() })	 //"T�tulos da Apura��o"

If nRet == 0 //Clicou no confirmar         

    //Se est� contabilizando perguntar� para o usu�rio se deseja visualizar a contabiliza��o
    If cOpc $ "2/3"
        Pergunte("FISA300F", .F.) 
        lExibeCon   := MV_PAR01 == 1
    EndIf
    
    //Grava��o dos t�tulos/Contabiliza��es
    FwMsgRun(,{|oSay|GrvTitCtb(cIdF1P, lExibeCon) },STR0002,"")	     //"Gerando os t�tulos/contabiliza��es "
    
    //TODO Exibir os t�tulos gerados

ElseIF nRet == 1
	//Clicou no cancelar
	DisarmTransaction()	
EndIF

END TRANSACTION

oApurISS:Clear()

//Destroi objeto
FreeObj(oApurISS)
oApurISS := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 19/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que carrega o modelo j� criado no FISA300A

@author Erick G Dias
@since 19/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FwLoadModel("FISA300A")

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias
@since 19/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados
Local oModel := FWLoadModel("FISA300A")

//Cria��o da estrutura de dados utilizada na interface
Local oMunicipio    := FWFormStruct(2, "F1N")
Local oTitulo       := FWFormStruct(2, "F1R")
Local oView         := Nil

oView := FWFormView():New()
oView:SetModel(oModel)

//Atribuindo formul�rios para interface
oView:AddGrid('VIEW_MUNICIPIO'   , oMunicipio , 'FISA300AMUNICIPIO' )
oView:AddGrid('VIEW_TITULO'      , oTitulo    , 'FISA300ATITULO'   )

//Retira da view os campos de ID
oMunicipio:RemoveField('F1N_ID')
oMunicipio:RemoveField('F1N_IDAPUR')
oMunicipio:RemoveField('F1N_DEDPRP')
oMunicipio:RemoveField('F1N_DEDSUB')
oMunicipio:RemoveField('F1N_DEDUNI')
oMunicipio:RemoveField('F1N_RECUNI')
oMunicipio:RemoveField('F1N_QTDUNI')
oMunicipio:RemoveField('F1N_VLFUNI')
oMunicipio:RemoveField('F1N_STATUS')

oTitulo:RemoveField( 'F1R_ID')
oTitulo:RemoveField( 'F1R_IDAPUR')
oTitulo:RemoveField( 'F1R_NUM')
oTitulo:RemoveField( 'F1R_PARC')
oTitulo:RemoveField( 'F1R_TIPO')
oTitulo:RemoveField( 'F1R_STATUS')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox('SUPERIOR', 50)
oView:CreateHorizontalBox('INFERIOR', 50)

//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView('VIEW_MUNICIPIO' , 'SUPERIOR')
oView:SetOwnerView('VIEW_TITULO'    , 'INFERIOR')

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_MUNICIPIO' , STR0003) //"Munic�pios"
oView:EnableTitleView('VIEW_TITULO'    , STR0004) //"T�tulos por Munic�pio"

//Desabilita op��o de ordena��o do Grid
oView:SetViewProperty( "*", "GRIDNOORDER")

//Adiciona o bot�o de FSA300DLEG
oView:AddUserButton( STR0005, 'CLIPS', {|oView| FSA300DLEG()} ) //'Legenda'

//Adiciona o bot�o para visualizar o t�tulo gerado
oView:AddUserButton( STR0006, 'CLIPS', {|oView| FSA300FTIT()} ) //'Visualizar T�tulo'

oView:AddUserButton( STR0007, 'CLIPS', {|oView| pergunte("FISA300F", .T.)} ) //'Configura��es'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} OnClose

Fun��o que far� o tratamento na confirma��o da tela dos t�tulos

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function OnClose()

Local lRet	    := .F.
Local oSay      := Nil

lRet := ApMsgYesNo(STR0008) //"Confirma opera��o?"

If lRet   
    //Atualiza��o da tela para permitir grava��o caso n�o tenha nenhuma altera��o do cliente
    lRet    := FSA300FATU()       

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OnExit

Fun��o que faz valida��o ao clicar no bot�o fechar.

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function OnExit()

Local lRet:= .F.

lRet := ApMsgYesNo(STR0009) //"Deseja realmente sair?"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumTit

Fun��o que retorna o n�mero do t�tulo sequencial

@author Erick G. Dias
@since 19/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GetNumTit()

Local cRet      := ""
Local nTamNF    := TamSx3("FT_NFISCAL")[1]

If SX5->(dbSeek(xFilial("SX5")+"53"+"ISS"))
    cRet := Soma1(Substr(X5Descri(),1,nTamNF),nTamNF)
    RecLock("SX5",.F.)
    SX5->X5_DESCRI  := cRet
    SX5->X5_DESCSPA := cRet
    SX5->X5_DESCENG := cRet
    SX5->(MsUnlock())
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDtVencto

Fun��o que processa a data de vencimento do t�tulo de ISS conforme defini��o 
do cadastro de munic�pio. Para utiliza��o desta fun��o � necess�rio
posicionar a CC2 primeiro. Se n�o houver configura��o dadata de vencimento
no cadstro de munic�pio a fun��o retornar� data de vencimento vazia.

@author Erick G. Dias
@since 24/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GetDtVencto(cUf, cCodMun, dDtRef)

Local dNextMonth    := StoD("//")
Local nQtdUtil      := 0
Local dDtVencto     := StoD("//")

//Verifica se o dia de pagamento foi digitado pelo usu�rio
If !Empty(cUf) .AND. !Empty(cCodMun) .AND. CC2->(DbSeek(xFilial("CC2") + cUf + cCodMun)) .and. CC2->CC2_DTRECO > 0    
    
    //Considera o pr�ximo m�s da apura��o para o vencimento do t�tulo
    dNextMonth    := MonthSum(dDtRef,1)

    //-----------------------------------
    //Considera quantidade de dias uteis
    //-----------------------------------
    If CC2->CC2_TPDIA == '1'
    
        //Inicia com primeiro dia do m�s
        dDtVencto   := FirstDay(dNextMonth)
        
        //La�o at� obter a quantidade de dias uteis
        Do While nQtdUtil < CC2->CC2_DTRECO
            
            //Verifica se a data � v�lida, j� psotegarndo caso o dia n�o seja util
            dDtVencto := DataValida(dDtVencto, .T.)                                                
            
            //Incrementa quantidade de dias uteis
            nQtdUtil++
            
            //Verifica se atingiu a quantidade de dias uteis informado pelo cliente
            If nQtdUtil == CC2->CC2_DTRECO
                //Sai do la�o pois j� obteve a data
                exit
            Else
                //Soma mais um dia pois ainda n�o atingiu a quantidade de dia uteis
                dDtVencto   := DaySum(dDtVencto,1)
            EndIF            

        EndDo

    //-----------------------------------
    //Considera dia fixo pora vencimento
    //-----------------------------------
    ElseIf CC2->CC2_TPDIA == '2'        

        //Calculando a data de vencimento
        dDtVencto := CtoD( StrZero(CC2->CC2_DTRECO, 2) + "/" + month2str(dNextMonth) + "/" + Year2str(dNextMonth) )

        // Validando data calculada, caso o dia n�o seja util, ser� postergado para o pr�ximo dia �til
        dDtVencto := DataValida(dDtVencto, .T.)

    EndIF

EndIf

Return dDtVencto

//-------------------------------------------------------------------
/*/{Protheus.doc} GetForTit

Fun��o que retorna as informa��es de fornecedores para gera��o do t�tulo
no contas a receber.

@author Erick G. Dias
@since 24/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GetForTit(cUf, cCodMun, cFornec, cLoja, cNaturez)

//Posiciona no detalhamento do munic�pio
If !Empty(cUf) .AND. !Empty(cCodMun) .AND. F1T->(DbSeek(xFilial("F1T") + cUf + cCodMun))
    
    //Considera as informa��es da tabela F1T
    cFornec  := F1T->F1T_FORN
    cLoja    := F1T->F1T_LOJA
    cNaturez := F1T->F1T_NATURE       

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcTit

Fun��o ir� criar objeto para grava��o da tabela F1R
para, com sugest�es de data de vencimento do t�tulo, participante
e natureza financeira, conforme cadastro de munic�pio.

@author Erick G. Dias
@since 24/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ProcTit(oMunic, dDtRef, cTpImp, nValor)

Local cNumTit   := Criavar("E2_NUM")
Local cPrefix   := Criavar("E2_PREFIXO")
Local cParcela  := Criavar("E2_PARCELA")
Local cTipo     := Criavar("E2_TIPO")
Local cFornec   := Criavar("E2_FORNECE")
Local cLoja     := Criavar("E2_LOJA")
Local cNaturez  := Criavar("E2_NATUREZ")
Local dVencto   := StoD("  /  /    ")
Local oObjTit   := APURISSTIT():New()

//--------------------------------
//Busca Pr�ximo n�mero de t�tulo
//--------------------------------
cNumTit := GetNumTit()

//----------------------
//Tipo do T�tulo ser� TX
//----------------------
cTipo := "TX"+Space(TamSx3("E2_TIPO")[1]-2)

//-------------------------------------
//Obtem o fornecedor, loja e natureza
//-------------------------------------
GetForTit( oMunic:getUF(), oMunic:getMunic(), @cFornec, @cLoja, @cNaturez)

//------------------------------
//Obtem o vencimento do t�tulo
//------------------------------
dVencto := GetDtVencto( oMunic:getUF(), oMunic:getMunic(), dDtRef)

//--------------------------
//Popula objeto de t�tulo
//--------------------------
oObjTit:setTpImp(cTpImp)
oObjTit:setPrefixo(cPrefix)
oObjTit:setNumTit(cNumTit)
oObjTit:setParcela(cParcela)
oObjTit:setTipo(cTipo)
oObjTit:setFornec(cFornec)
oObjTit:setLoja(cLoja)
oObjTit:setNaturez(cNaturez)
oObjTit:setValor(nValor)
oObjTit:setDtVenc(dVencto)

//Adiciona o t�tulo para objeto de apura��o de ISS
oMunic:addTitulo(oObjTit)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTitISS

M�todo que faz a grava��o dos t�tulos no contas a pagar

@author Erick G. Dias
@since 25/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GeraTitISS(oTitulo, lProcContab, cTitGerado, cPrefixo, cCodLp, lExibeCon)

Local lRet  := .F.
Local aSe2  := {  { "E2_FILIAL"   ,xFilial("SE2")     , NIL },;
               { "E2_PREFIXO"  , oTitulo:getPrefixo() , NIL },;
               { "E2_NUM"      , oTitulo:getNumTit()  , NIL },;
               { "E2_TITORIG"  , oTitulo:getNumTit()  , NIL },;
               { "E2_PARCELA"  , oTitulo:getParcela() , NIL },;
               { "E2_TIPO"     , oTitulo:getTipo()    , NIL },;
               { "E2_NATUREZ"  , oTitulo:getNaturez() , NIL },;
               { "E2_FORNECE"  , oTitulo:getFornec()  , NIL },;
               { "E2_LOJA"     , oTitulo:getLoja()    , NIL },;
               { "E2_EMISSAO"  , dDataBase            , NIL },;
               { "E2_VENCTO"   , oTitulo:getDtVenc()  , NIL },;
               { "E2_HIST"     , STR0010    , NIL },; //"Apura��o de ISS"
               { "E2_ORIGEM"   , "FISA300"            , NIL },;
               { "E2_VALOR"    , oTitulo:getValor()   , NIL }}

If !Empty(oTitulo:getNaturez()) .AND. !Empty(oTitulo:getFornec()) .AND. !Empty(oTitulo:getLoja()) .AND. !Empty(oTitulo:getDtVenc())
    
    MSExecAuto({|a,b,c,d,e,f,g,h| FINA050(a,b,c,d,e,f,g,h)}, aSe2, Nil, MODEL_OPERATION_INSERT, /*bExecuta*/, /*aDadosBco*/, /*lExibeLanc*/, /*lOnline*/, /*aDadosCTB*/)
        
    //Indica que gerou o t�tulo
    lRet    := !lMsErroAuto

    //Armazena o n�mero do t�tulo gerado
    cTitGerado  += oTitulo:getNumTit() + '/'
    cPrefixo    += oTitulo:getPrefixo() + '/'

    If lMsErroAuto    
        MostraErro()

    ElseIF cOpcao == "2"
        //Faz contaboliza��o do t�tulo gerado
        lProcContab := FSA300TCONT(cCodLp, SE2->(RECNO()), lExibeCon)
    EndIf    

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF1R

Fun��o que processar� as informa��es necess�rias para grava��o da tabela 
F1R

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function ProcF1R(dDtRef)

Local nX        := 0
Local nY        := 0
Local lSaveApur := .F.
Local aTitulos  := {}
Local lExistePro := .F.
Local lExisteUni := .F.

//Faz carga dos valores por munic�pio
aApurMun := oApurISS:getApurMun()

//La�o nos munic�pios
For nX  := 1 to Len(aApurMun)   
    
    lExistePro := .F.    
    lExisteUni := .F.

    //Obtem a lista de F1R do munic�pio
    aTitulos    := aApurMun[nX]:getTitulos()

    For nY:=1 to Len(aTitulos)
        
        //Verifica se j� existe F1R, e para qual tipo de ISS a F1R j� foi gerada.
        If aTitulos[nY]:getTpImp() == "01"
            //J� existe F1R gravada para Iss Pr�prio
            lExistePro   := .T.        
        ElseIf aTitulos[nY]:getTpImp() == "03"
            //J� existe F1R gravada para Iss Uniprofissional
            lExisteUni   := .T.            
        EndiF        

    Next nY    

    //Verifica se existe valor a recolher do ISS Pr�prio
    If !lExistePro .AND. aApurMun[nX]:getISSProp() > 0
        ProcTit(aApurMun[nX], dDtRef, "01", aApurMun[nX]:getISSProp())
        lSaveApur   := .T.
    EndIF    
    
    //Verifica se existe valor a recolher da Sociedade Uniprofissional
    If !lExisteUni .AND. aApurMun[nX]:getISSUni() > 0        
        ProcTit(aApurMun[nX], dDtRef, "03", aApurMun[nX]:getISSUni())
        lSaveApur   := .T.
    EndIF        

Next nX

//Salva se necess�rio as altera��es da F1R para exibir o grid par ausu�rio editar.
If lSaveApur
    oApurISS:SaveApur()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvTitCtb

Fun��o que far� a grava��o dos t�tulos no contas a pagar 

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function GrvTitCtb(cIdF1P, lExibeCon)

Local nX            := 0
Local nY            := 0
Local aTitulos      := {}
Local lSaveApur     := .F.
Local lProcContab   := .F.
Local cFiltroBrw    := ""
Local cTipo         := "TX"+Space(TamSx3("E2_TIPO")[1]-2)
Local cTitGerado    := ""
Local cPrefixo      := ""
Local cCodLp        := "750" //Estou utilizando o c�digo 750 para manter compatibilidade com a contabiliza��o da apura��o de ISS MATA954
Local cChaveTit     := ""
Local lApurado       := .F.
Local lTitulo       := .F.
Local lCont         := .F.

//Faz carga dos valores da apura��o
oApurISS:LoadApur(cIdF1P)

//Faz carga dos valores por munic�pio
aApurMun := oApurISS:getApurMun()

//La�o nos munic�pios
For nX  := 1 to Len(aApurMun)    
    
    //Carrega as informa��es gravadas na F1R
    aApurMun[nX]:loadTitulos()
    
    //Obtem a lista de F1R do munic�pio
    aTitulos    := aApurMun[nX]:getTitulos()

    lApurado    := .F.
    lTitulo     := .F.
    lCont       := .F.

    //La�o nas informa��es da F1R
    For nY  := 1 to Len(aTitulos)
        
        //-------------------------------------------
        //Grava��o dos t�tulos e/ou contabiliza��o
        //-------------------------------------------
        IF aTitulos[nY]:getStatus() == "1" .And. cOpcao $ "1/2"
            
            //Faz grava��o dos t�tulos
            GeraTitISS(aTitulos[nY], @lProcContab, @cTitGerado, @cPrefixo, cCodLp, lExibeCon)            
    
            //Atualizando o Status da Apura��o
            IF cOpcao == "2"
                //Status que gerou t�tulo e contabilizou                
                aTitulos[nY]:setStatus('3')

            Else
                //Status que somente gerou t�tulo                
                aTitulos[nY]:setStatus('2')
            EndIF
            
            lSaveApur   := .T.        
        //-------------------------------------------
        //Somente Contabiliza��o
        //-------------------------------------------
        ElseIf aTitulos[nY]:getStatus() == "2" .AND. cOpcao == "3"
            //Posiciona o t�tulo e realiza a contabiliza��o
            cChaveTit	:= xFilial("SE2") + ;
                        aTitulos[nY]:getPrefixo() + ;
                        aTitulos[nY]:getNumTit() + ;
                        aTitulos[nY]:getParcela() + ;
                        aTitulos[nY]:getTipo() + ;
                        aTitulos[nY]:getFornec() + ;
                        aTitulos[nY]:getLoja()

            //Posiciona no t�tulo e realiza a contabiliza��o
            If !Empty(cChaveTit) .And.  SE2->(MsSeek(cChaveTit)) .And. FSA300TCONT(cCodLp, SE2->(RECNO()))                                                
                //Status que contabilizou t�tulo                
                aTitulos[nY]:setStatus("3")
                lSaveApur   := .T.
            EndIF
            
        EndIF

        //Verifica��o para atualizar status do munic�pio
        IF aTitulos[nY]:getStatus() == "1"
            //Somente apurado
            lApurado    := .T.
        ElseIF aTitulos[nY]:getStatus() == "2"
            //Somente t�tulo
            lTitulo := .T.
        ElseIf aTitulos[nY]:getStatus() == "3"
            //T�tulo e contabiliza��o
            lCont := .T.
        EndIF
        
    Next nY

    //Tratamento para atualizar a legenda da F1N
    If (!lTitulo .AND. !lCont .AND. lApurado) .OR. (!lTitulo .AND. !lCont .AND. !lApurado)
        //Todas F1R somente apuraram
        aApurMun[nX]:setStatus("1")
    ElseIF lTitulo .AND. !lCont .AND. !lApurado
        //Todas F1R somente geraram t�tulo
        aApurMun[nX]:setStatus("2")
    ElseIF !lTitulo .AND. lCont .AND. !lApurado
        //Todas F1R geraram t�tulo e contabiliza��o
        aApurMun[nX]:setStatus("3")    
    Else    
        //T�tulos/Contabiliza��o parcial
        aApurMun[nX]:setStatus("4")
    Endif

Next nX       

//Salva se necess�rio apura��o para atualizar o Status dos munic�pios que geraram t�tulos
If lSaveApur    
    oApurISS:SaveApur()
EndIF

If !Empty(cTitGerado)
    //Monta filtro para exibir os t�tulos gerados pela apura��o
    cFiltroBrw	:= ' E2_FILIAL = "' + xFilial("SE2") + '" .AND. '
    cFiltroBrw	+= ' E2_TIPO == "' + cTipo + '" .AND. '
    cFiltroBrw	+= ' E2_ORIGEM == "FISA300" .AND. '
    cFiltroBrw	+= ' E2_NUM $ "' +  cTitGerado + '"'    
        
    FISA300I("SE2", STR0011, cFiltroBrw) //"T�tulo Gerado"

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300FATU

Fun��oi auxiliar para edi��o do modelo para permitir salvar caso
n�o tenha nenhuma altera��o realizada pelo cliente, ele acatou
todas as sugest�es de gera��o do t�tulo.

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FSA300FATU()

Local oModel    := FWModelActive()
Local oMunic  	:= oModel:GetModel('FISA300AMUNICIPIO')
Local oTitulo	:= oModel:GetModel('FISA300ATITULO')
Local oView 	:= FWViewActive()
Local cVal      := ""
Local nX        := 0
Local nY        := 0
Local lRet      := .T.

//Este trecho � necess�rio, pois preciso alterar o modelo para o bot�o confirmar fechar a tela.
//Como o modelo possui tabela tempor�ria, preciso alterar o modelo manualmente
If oTitulo:Length() > 0
    cVal	:= oTitulo:GetValue("F1R_PREFIX",1)
    oTitulo:SetValue('F1R_PREFIX', "." )
    oview:Refresh( 'VIEW_TITULO' )
    oTitulo:SetValue('F1R_PREFIX', cVal )
    oview:Refresh( 'VIEW_TITULO' )
EndIF

//Valida��o das linhas dos munic�pios e t�tulos
For nX:=1 to oMunic:Length()
    
    //Posiciona linha do munic�pio
    oMunic:GoLine( nX )

    //Verifico se n�o est� deletada
    IF !oMunic:IsDeleted()

        //Percorre linhas dos t�tulos do munic�pio posicionado
        For nY := 1 to oTitulo:Length()
        
            //Posiciona a linha do t�tulo
            oTitulo:GoLine( nY )

            //Verifico se n�o est� deletada e se os campos obrigat�rios est�o preenchidos
            IF !oTitulo:IsDeleted() .AND. (Empty(oTitulo:GetValue("F1R_FORN")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_LOJA")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_VENCTO")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_NATURE")) .OR. ;
                                          Empty(oTitulo:GetValue("F1R_VALOR")))
                lRet := .F.
                Help( ,, 'Help',, STR0012 + oMunic:GetValue("F1N_MUN") + " !" , 1, 0 ) //"Existem informa��es obrigat�rioas n�o preenchidas na se��o de T�tulos por Munic�pio em: "
            EndIF

            //Se Aqui alguma informa��o obrigat�rio est� faltando, n�o pode permitir grava��o
            If !lRet
                Exit
            EndIF

        Next nY
    EndIF

    //Se Aqui alguma informa��o obrigat�rio est� faltando, n�o pode permitir grava��o
    If !lRet
        Exit
    EndIF

Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300DLEG

Fun��o apra gerar legenda

@author Erick G. Dias
@since 26/06/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Function FSA300DLEG() 
      
Local aLegenda := {} 

aAdd( aLegenda, { "BR_VERMELHO" , STR0013 })  //"N�o gerado"
aAdd( aLegenda, { "BR_VERDE"    , STR0014 })  //"T�tulo gerado"
aAdd( aLegenda, { "BR_AZUL"     , STR0015 })  //"T�tulo gerado e contabilizado"
aAdd( aLegenda, { "BR_AMARELO"  , STR0016 })  //"T�tulos/Contabiliza��o parcial"

BrwLegenda( STR0005, STR0005, aLegenda )  //'Legenda'

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA300FTIT

Fun��o que exibe o t�tulo gerado conforme F1R posicionada

@author Erick G. Dias
@since 02/07/2019
@version 12.1.23

/*/
//-------------------------------------------------------------------
Static Function FSA300FTIT()

Local oModel        :=	FWModelActive()
Local oTitulo	    := oModel:GetModel('FISA300ATITULO')
Local cFiltroBrw    := ""

If !Empty(oTitulo:GetValue("F1R_NUM"))
    //Monta filtro para exibir os t�tulos gerados pela apura��o
    cFiltroBrw	:= ' E2_FILIAL = "' + xFilial("SE2") + '" .AND. '
    cFiltroBrw	+= ' E2_TIPO == "' + "TX"+Space(TamSx3("E2_TIPO")[1]-2) + '" .AND. '
    cFiltroBrw	+= ' E2_ORIGEM == "FISA300" .AND. '
    cFiltroBrw	+= ' E2_NUM == "' +  oTitulo:GetValue("F1R_NUM") + '"'    
        
    FISA300I("SE2", STR0011, cFiltroBrw) //"T�tulo Gerado"

EndIF

Return
 