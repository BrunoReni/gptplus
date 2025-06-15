#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//------------------------------------------------------------------
/*/
Este fonte tem objetivo de concentrar todas as fun��es que criam e manipulam
o componente de f�rmulas do configurador de tributos.
Este componente ser� composto por um get seletor de operandos
4 bot�es de operadores b�sicos (+-/*)
2 bot�es para abertura e fechamento dos parenteses
1 bot�o para habilitar a edi��o da f�rmula
1 bot�o para adicionar o opernado na f�rmula
1 bot�o para limpar a f�rmula
1 bot�o par verificar sintaxe da f�rmula

Este componente ser� adicionado nas telas de cadastro de regra de base de c�lculo
, regra de al�quota e regra de tributo.

Este componente utilizar� a tabela CIN para gravar as informa��es.
Os Ids dos m�duloes e views dever�o ser enviados todos por par�metro para possibilitar
a reutiliza��o deste componente em mais de uma view e modelo.

/*/
//------------------------------------------------------------------

//------------------------------------------------------------------
/*/{Protheus.doc} xFisFormul

Fun��o que cria os bot�es das f�rmulas para as telas de regra de base de c�lculo, 
al�quota e tributo.

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisFormul(oPanel, cModelo, cViewForm, cTpRegra, cCodCab, cCodModCab, cCodRegra, cViewRegra)

Local cCssBtn	:= getCss()
Local cCssEdit	:= getCss("EDITABLE_OCEAN.PNG")
Local cCssAdd	:= getCss("ADICIONAR_001.PNG")
Local cCssHelp	:= getCss("HELP.PNG")

//Posi��es do eixo Y das linhas
Local nYFisrtRow       := 1
Local nYSecondRow      := 16

//Posi��es do exixo X das linhas
Local nXFirstCol       := 2
Local nXSecondCol      := 72
Local nXThirdCol       := 103
Local nXFourthCol      := 134
Local nXFithCol        := 165
Local nXSixthCol        := 196

//Dimens�es do tamanho dos bot�es
Local nWidthBtn        := 30 //Largura do bot�o
Local nHeightBtn       := 14 //Altura do bot�o
Local nWidthCss        := 65 //Largura do bot�o com CSS
Local nHeightCss       := 16 //Altura do bot�o com CSS

//Variaveis auxiliares para obter o resultado da fun��o xCanAddOpe()
Local nTpOperador        := 1
Local nTpOperando        := 2
Local nTpAbreParenteses  := 3
Local nTpFechaParenteses := 4

Default cTpRegra:= ""
Default cCodCab := ""
Default cCodModCab := ""
Default cCodRegra := CriaVar("CIN_CONSUL")
Default cViewRegra:= ""

//Inicia o bot�o de editar f�rmula habilitado
lclicked    := .T.

If cModelo == "FORMULCAL_ISENTO"
    lclickedI     := .T.
EndIF

If cModelo == "FORMULCAL_OUTROS"
    lclickedO     := .T.
EndIF

//Cria frame para colcoar os componentes
oLayer := FWLayer():New()
oLayer:Init(oPanel, .F.)
oLayer:AddLine('LIN1', 100, .F.)
oPanel1  := oLayer:getLinePanel('LIN1')

//Cria primeira linha dos bot�es
oBtnEditar := TButton():New((nYFisrtRow - 1) , nXFirstCol   ,"      Editar F�rmula" ,oPanel1,{|| xEditFor(cModelo) }                                   ,nWidthCss ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND.  HabBtnEdit(cModelo) .And. HabEditTrib(cModelo)}         ,,.F.)
oBtnSom    := TButton():New(nYFisrtRow       , nXSecondCol  ,"+"                    ,oPanel1,{|| xForBtnAct("+", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnSub    := TButton():New(nYFisrtRow       , nXThirdCol   ,"-"                    ,oPanel1,{|| xForBtnAct("-", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnMul    := TButton():New(nYFisrtRow       , nXFourthCol  ,"*"                    ,oPanel1,{|| xForBtnAct("*", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnDiv    := TButton():New(nYFisrtRow       , nXFithCol    ,"/"                    ,oPanel1,{|| xForBtnAct("/", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnDesfaz := TButton():New(nYFisrtRow       , nXSixthCol   ,"Desfaz"            ,oPanel1,{|| BackSpace(cModelo, .T., cViewForm)                  },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo)}                                              ,,.F.)

//Cria segunda fileira dos bot�es
oBtnEAdd  := TButton():New((nYSecondRow - 1) , nXFirstCol  ,"      Adiciona" ,oPanel1,{|| xForBtnAct(cCodRegra,cModelo, .T., cViewForm, cViewRegra)},nWidthCss ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .And. xCanAddOpe(cModelo)[nTpOperando]}       ,,.F.)
oBtnAbre  := TButton():New(nYSecondRow       , nXSecondCol ,"("              ,oPanel1,{|| xForBtnAct("(", cModelo, .T., cViewForm, cViewRegra) }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .And. xCanAddOpe(cModelo)[nTpAbreParenteses]} ,,.F.)
oBtnFEcha := TButton():New(nYSecondRow       , nXThirdCol  ,")"              ,oPanel1,{|| xForBtnAct(")", cModelo, .T., cViewForm, cViewRegra) }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .And. xCanAddOpe(cModelo)[nTpFechaParenteses]},,.F.)
oBtnClear := TButton():New(nYSecondRow       , nXFourthCol ,"Limpar"         ,oPanel1,{|| xForClear(cModelo, .T.,cViewForm, .T. )              }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo)}                                              ,,.F.)
oBtnChk   := TButton():New(nYSecondRow       , nXFithCol   ,"Validar"        ,oPanel1,{|| xForCheck(cModelo,,.T.,cTpRegra, cCodCab,cCodModCab) }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo)}                                              ,,.F.)
oBtni     := TButton():New(nYSecondRow       , nXSixthCol   ,"   "           ,oPanel1,{|| HelpPrx()}    ,14 ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||.T.}                                              ,,.F.)

//Aplica o CSS nos bot�es
oBtnSom:SetCss(cCssBtn)
oBtnSub:SetCss(cCssBtn)
oBtnMul:SetCss(cCssBtn)
oBtnDiv:SetCss(cCssBtn)
oBtnDesfaz:SetCss(cCssBtn)
oBtnAbre:SetCss(cCssBtn)
oBtnFEcha:SetCss(cCssBtn)
oBtnClear:SetCss(cCssBtn)
oBtnChk:SetCss(cCssBtn)
oBtnEditar:SetCss(cCssEdit)
oBtnEAdd:SetCss(cCssAdd)
oBtni:SetCss(cCssHelp)

Return NIL

//Fun��o auxiliar para criar label em um painel vazio.
Function xFisLabel(oPanel)

oSay1:= TSay():New(200,200,{||' '},oPanel,,,,,,.T.,,,200,20)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} xForBtnAct
Fun��o para adicionar operandos e par�nteses no final da f�rmula

@param cText - Operando/Operador a ser adicionado no final da f�rmula
@param cModelo - Nome do modelo a qual a f�rmula pertence

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xForBtnAct(cText, cModelo, lRefresh, cView, cViewRegra)
Local oModel    :=	FWModelActive()
Local oFormul	:=  oModel:GetModel(cModelo)
Local oView 	:= 	FWViewActive()
Local cFormul   :=  oFormul:GetValue("CIN_FORMUL",1)
Local cFiltro   :=  oFormul:GetValue("CIN_FILTRO",1)
Local AUltChar  := {}

//Somente adicionar� se o texto estiver preenchido.
If !Empty(cText) .AND. !Empty(cFiltro)

    //Verifico se estou adicionando o c�digo da CIN, para carregar o valor da tela
    If cText == "CIN_CONSUL"

        If cFiltro == "ZZ" //Valor num�rico manual                        
            cText := STRTRAN(Alltrim(cvaltochar(oFormul:GetValue("CIN_VAL",1))),".", ",")
        Else //Demais C�digos de regras cadastradas
            cText:= Alltrim(oFormul:GetValue("CIN_CONSUL",1))
        EndIF

        IF cText == xFisTpForm("9") + "DED_DEPENDENTES" .Or. cText == xFisTpForm("9") +  "DED_TAB_PROGRESSIVA" 
            
            AUltChar  := StrTokArr(alltrim(cFormul)," ")
            IF Len(AUltChar) >= 2 .And. !(AUltChar[Len(AUltChar)]  == "-" .OR. (AUltChar[Len(AUltChar)] == "(" .And. AUltChar[Len(AUltChar)-1] == "-"))
                //Preciso verificar se tem operador de subtra��o ou subtra��o e parenteses para adicionar esta dedu��o
                Help( ,, 'Help',, "Este operando somente poder� ser utilizado na opera��o de subtra��o!", 1, 0 )
                return
            ElseIF Len(AUltChar) < 2
                Help( ,, 'Help',, "Este operando somente poder� ser utilizado na opera��o de subtra��o!", 1, 0 )
                return
            EndIF

        EndIF

        //Limpando o campo do c�digo da regra e valor
        oFormul:LoadValue("CIN_CONSUL",CriaVar("CIN_CONSUL"))
        oFormul:LoadValue("CIN_VAL",CriaVar("CIN_VAL"))        

        //Atualiza a VIEW_REGRA
        If lRefresh .AND. !Empty(cViewRegra)
            oview:Refresh(cViewRegra)
        EndIf

    EndIf
    //Adiciona o operador no final da f�rmula
    oFormul:LoadValue('CIN_FORMUL', cFormul + " " + cText)    

    //Atualiza as Views
    If lRefresh .AND. !Empty(cView)
        oview:Refresh(cView)
    EndIF

    //Atualiza a VIEW_REGRA
    If lRefresh .AND. !Empty(cViewRegra)
        oview:Refresh(cViewRegra)
    EndIf


endif 

Return

//------------------------------------------------------------------
/*/{Protheus.doc} x160CLear
Fun��o que limpa a f�rmula e o operador

@param cModelo - Nome do modelo a qual a f�rmula pertence

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xForClear(cModelo, lRefresh, cView, lBtn)
Local oModel    :=	FWModelActive()
Local oFormul	:= oModel:GetModel(cModelo)
Local oView 	:= 	FWViewActive()

Default lBtn    := .F.



If cModelo == "FORMULCAL" .and. lBtn
	//Chama fun��o correspondente da regra de Regra de Tributo    
	If FindFunction("Fsa160AFor")
		//Chama fun��o correspondente do modelo tratado.
		Fsa160AFor()
	EndIF
ElseIf cModelo $ "FORMULCAL_ISENTO/FORMULCAL_OUTROS" .and. lBtn 
	//Chama fun��o correspondente da regra de Regra de Tributo    
	If FindFunction("Fsa160AFor")
		//Chama fun��o correspondente do modelo tratado.
		Fsa160AFor(cModelo)
	EndIF
EndiF

//Limpa o conte�do das f�rmulas e do c�digo da regra
oFormul:LoadValue('CIN_FORMUL', "" )

//Atualiza as Views
If lRefresh .And. !Empty(cView)
	oview:Refresh( cView )
Endif

Return

//------------------------------------------------------------------
/*/{Protheus.doc} xForCheck
Fun��o que verifica a f�rmula digitada:
-verificando sintaxe
-caracteres inv�lidos
-abertura  efechamento de paranteses
-Operandos v�lidos e devidamente cadastrados
-Problema de recursividade, da f�rmula depender dela mesmo

@param cModelo - Nome do modelo a qual a f�rmula pertence
@param cRetErro - Mensagem de erro de valida��o se houver
@param lShowMsg - Indica se esta fun��o exibir� ou n�o mensagem
@param cTpRegra - Tipo da regra, se base, al�quota, tributo etc
@param cCodCab - Nome do campo que possui o c�digo da regra que est� sendo manipulad
@param cCodModCab - Nome do modelo que contem o campo da regra que est� sendo manipulad
@param lEmpty - Indica que permite f�rmulas vazias
@param - cExcecao - Aqui s�o operandos que n�o dever�o ser verificados sua exist�ncia na CIN, caso seja necess�rio.

@return lRet - retornar verdadeido se ocorrer algum erro

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xForCheck(cModelo, cRetErro, lShowMsg, cTpRegra, cCodCab, cCodModCab, lEmpty, cExcecao)
Local oModel        := FWModelActive()
Local oFormul	    := oModel:GetModel(cModelo)
Local oCab	        := oModel:GetModel(cCodModCab)
Local cExpressao    := oFormul:GetValue("CIN_FORMUL",1)
Local cCodCIN       :=  ""
Local cFormula      := ""
Local lRet          := .F.

Default cRetErro    := ""
Default lShowMsg    := .F.
Default lEmpty      := .F.
Default cExcecao    := ""

//Somente far� verifica��o se a f�rmula estiver preenchida
If !Empty(cExpressao)    
    //----------------------------------------------------------------
    //Faz verifica��o de sintaxe de parenteses e caracteres inv�lidos
    //----------------------------------------------------------------
    cRetErro  := FisChkForm(cExpressao)
    If Empty(cRetErro)
        
        //Converte a f�rmula em NPI
        cExpressao    := xFisSYard(cExpressao, @cFormula)
        
        //Para o cadastro de regra tribut�ria, preciso fazer a valida��o do prefixo da f�rmula, 
        //dever� corresponder as regras de base e al�quota selecionadas
        If cModelo == "FORMULCAL"
            cRetErro    := ""
            vldPreFixFor(cFormula, @cRetErro)            
        EndIF
        //------------------------------------------------------------
        //Verifica se todos os operandos est�o devidamente cadastrados
        //------------------------------------------------------------
        IF Empty(cRetErro) .AND. xFisForCad(cExpressao, @cRetErro, cExcecao)

            cRetErro    := ""
            //-----------------------------
            //Verifica a sintaxe da f�rmula
            //-----------------------------
            If xFisSintaxe(cFormula, @cRetErro)

                //------------------------------------------------------------
                //Verifica se o c�digo n�o est� contido na pr�prioa f�rmula
                //Chama fun��o para verificar quest�o da recursividade       
                //------------------------------------------------------------
                cCodCIN  := xFisTpForm(cTpRegra)
                cCodCIN  += oCab:GetValue(cCodCab,1)
                cRetErro := ""
                If !xFisFDep(cCodCIN, cExpressao, @cRetErro)
                  
                    lRet := .T.
                    If lShowMsg
                        //Executa f�rmula nPI
                        MsgInfo("Resultado = " + cvaltochar(FisExecNPI(cExpressao));
                        + CRLF + CRLF + CRLF + CRLF +;
                        "Express�o em NPI: " + cExpressao)
                    EndIF                
                    
                Else
                    cRetErro := "Regra '" +   oCab:GetValue(cCodCab,1) + "' N�o pode ser dependente das regras informadas na f�rmula:" + CRLF + CRLF +  substr(Alltrim(cRetErro), 1, len(Alltrim(cRetErro)) - 2)
                EndIf
            
            EndIF

        EndIF

    EndIF
ElseIf lEmpty
    lRet    := .T. //Aqui permito f�rmula vazia!
Else
    cRetErro := "Express�o vazia!"
EndIF

//Verifica se deve exibir mensagem de erro
If !lRet .AND. lShowMsg .And. !Empty(cRetErro)
    Help( ,, 'Help',, cRetErro, 1, 0 )
EndIF 

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} GravaCIN
Fun��o que far� grava��o da tabela CIN
@param cTpRegra - Tipo da regra, 1=Base, 2=Al�quota, 3=Valor Tributo; 4=Valor padr�o
@param cRegra - C�digo da regra a qual a f�rmula est� vinculada
@param cIdRegra - ID da regra a qual a f�rmula est� vinculada
@param cDescri - Descri��o da regra
@param cFormula - F�rmula em express�o aritim�tica
@param cNPI - F�rmula convertida em NPI

@author Erick G. Dias
@since 29/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function GravaCIN(cOpc, cTpRegra, cRegra, cIdRegra, cDescri, cFormula, cAltera, cFormUsuar, cOldIdReg)
Local aAreaAnt  := GETAREA()

Default cAltera    := "0"
Default cDetTrib   := ""
Default cTpRegra   := ""
Default cFormUsuar := cFormula
Default cOldIdReg  := ""
 
If cOpc == "1" //inclus�o

    RecLock("CIN",.T.)
    CIN->CIN_FILIAL	    := xFilial("CIN")
    CIN->CIN_ID    		:= FWUUID("CIN")
    CIN->CIN_CODIGO	    := xFisTpForm(cTpRegra) + cRegra
    CIN->CIN_DESCR   	:= cDescri
    CIN->CIN_TREGRA	    := cTpRegra
    CIN->CIN_REGRA  	:= Iif(cTpRegra <> "0",cRegra,"")
    CIN->CIN_IREGRA  	:= cIdRegra
    CIN->CIN_FORMUL	    := cFormUsuar
    CIN->CIN_FNPI  	    := xFisSYard(cFormula)
    CIN->CIN_ALTERA	    := cAltera //n�o alterado
    MsUnLock()
ElseIf cOpc == "2" //edi��o
    
    //Seek para posicionar a CIN
    dbSelectArea("CIN")
    dbSetOrder(3)

    If !Empty(cOldIdReg) .AND. !Empty(cIdRegra) .AND. CIN->(MsSeek(xFilial('CIN') +cOldIdReg+cTpRegra))
        //Nesse caso, o sistema ir� apenas atualizar o ID da Regra, com o intuito de manter a refer�ncia com o registro de origem.
        RecLock("CIN",.F.)
        CIN->CIN_IREGRA := cIdRegra
        MsUnLock()
    ElseIf !Empty(cIdRegra) .AND. CIN->(MsSeek(xFilial('CIN') + cIdRegra+cTpRegra))
        RecLock("CIN",.F.)
        CIN->CIN_ALTERA := "1"//Indica que sofreu altera��es
        MsUnLock()
    EndIF

ElseIf cOpc == "3" //exclus�o
    
    //Seek para posicionar a CIN
    dbSelectArea("CIN")
    dbSetOrder(3)
    If !Empty(cIdRegra) .AND. CIN->(MsSeek(xFilial('CIN') + cIdRegra+cTpRegra))
        RecLock("CIN",.F.)
	    CIN->(dbDelete())
    	MsUnLock()
    EndIF

EndIF

RESTAREA(aAreaAnt)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} xFisTpForm
Fun��o que recebe o tipo de operando e devolve o prefixo correspondente.

Exemplo:
0 = operador primario sera O.
1 = base, o retorno ser� B.
2 = al�quota o retorno ser� A.
3 = tributo o retorno ser� V.

@param cOrig - Origem do operando

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisTpForm(cOrig)

Local cTipo := ""

If cOrig == "0" //Operadores primarios / Valor Origem
	cTipo	:= "O:"
ElseIf cOrig == "1" //Base de c�lculo
	cTipo	:= "B:"
ElseIf cOrig == "2" //Al�quota
	cTipo	:= "A:"
ElseIf cOrig == "3" //Tributo
	cTipo	:= "V:"
ElseIf cOrig == "4" //URF
	cTipo	:= "U:"
ElseIf cOrig == "6" //Tipo de f�rmulas do tributo base
	cTipo	:= "BAS:"
ElseIf cOrig == "7" //Tipo de f�rmulas do tributo aliquota
	cTipo	:= "ALQ:
ElseIf cOrig == "8" //Tipo de f�rmulas do tributo valor
	cTipo	:= "VAL:"
ElseIf cOrig == "9" //�ndices de C�lculos
	cTipo	:= "I:"    
ElseIf cOrig == "10" //F�rmula MAIOR
	cTipo	:= "MAIOR"
ElseIf cOrig == "11" //Valor de Isento
	cTipo	:= "ISE:"    
ElseIf cOrig == "12" //Valor de Outros
	cTipo	:= "OUT:"    
ElseIf cOrig == "13" //Valor de diferimento
	cTipo	:= "DIF:"    
ElseIf cOrig == "14" //F�rmula MENOR
	cTipo	:= "MENOR"
EndIF

Return cTipo

//------------------------------------------------------------------
/*/{Protheus.doc} xEditFor
Fun��o que habilita a edi��o da f�rmula, executada quando o bot�o de edi��o
� acionado.

@param cModelo - Modelo que dever� refletir as altera��es ao habilitar a f�rmula

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xEditFor(cModelo)

If cModelo == "FORMULBAS"	
	//Desabilita o bot�o de editar f�rmula
    lclicked    := .F.
    //Chama fun��o correspondente da regra de base de c�lculo
	If FindFunction("Fsa161AFor")
		//Chama fun��o correspondente do modelo tratado.
		Fsa161AFor()
	EndIF
ElseIf cModelo == "FORMULALQ"
    //Desabilita o bot�o de editar f�rmula
    lclicked    := .F.
    //Fun��o do FISA162 que muda a op��o da al�quota para fun��o manual
	If FindFunction('Fsa162AFor')
		lRet := Fsa162AFor()	
	EndIf    
ElseIf cModelo == "FORMULCAL"
    //Desabilita o bot�o de editar f�rmula
    lclicked    := .F.
    //Fun��o do FISA160 que da refresh na view
	If FindFunction('Fsa160AFor')
		lRet := Fsa160AFor("FISCOMPFOR")	
	EndIf

ElseIf cModelo == "FORMULCAL_ISENTO"
    //Desabilita o bot�o de editar f�rmula
    lclickedI    := .F.
    //Fun��o do FISA160 que da refresh na view
	If FindFunction('Fsa160AFor')
		lRet := Fsa160AFor("FISCOMPFOR")	
	EndIf

ElseIf cModelo == "FORMULCAL_OUTROS"
    //Desabilita o bot�o de editar f�rmula
    lclickedO    := .F.
    //Fun��o do FISA160 que da refresh na view
	If FindFunction('Fsa160AFor')
		lRet := Fsa160AFor("FISCOMPFOR")	
	EndIf    

EndiF

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} HabBtnEdit
Esta fun��o indica se os componentes de composi��o das f�rmulas dever�o 
estar habilitados ou n�o.

@param cModelo - Modelo que dever� refletir as altera��es ao habilitar a f�rmula

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function HabBtnEdit(cModelo)

 Local lRet := .T.

If cModelo == "FORMULBAS"
	If FindFunction('Fsa161HBtn')
		lRet := Fsa161HBtn()	
	EndIf
ElseIf cModelo == "FORMULALQ"
    //Fun��o do fonte FISA162 que valida se est� na op��o para edi��o da f�rmula
	If FindFunction('Fsa162HBtn')
		lRet := Fsa162HBtn()	
	EndIf
ElseIf cModelo $ "FORMULCAL/FORMULCAL_ISENTO/FORMULCAL_OUTROS"
    IF FindFunction('Fsa160HBtn')
        lRet := Fsa160HBtn(cModelo)
    Endif
EndIF

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} xCanEdit
Fun��o que verifica o modelo ativo e obtem a opera��o.
@return bool - verdadeiro se a opera��o for inclus�o ou edi��o.

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xCanEdit()
Local oModel        := FWModelActive()
return oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE

//------------------------------------------------------------------
/*/{Protheus.doc} getCss
Fun��o que monta o CSS

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Static Function getCss(cImg)

Local cEstilo	:= ""

cEstilo := "QPushButton {"  

If !Empty(cImg)
	//Usando a propriedade background-image, inserimos a imagem que ser� utilizada, a imagem pode ser pega pelo reposit�rio (RPO)
	cEstilo += " background-image: url(rpo:" + cImg + ");background-repeat: none; margin: 2px;" 
EndIF

cEstilo += " border-style: outset;"
cEstilo += " border-width: 1px;"
cEstilo += " border: 1px solid #03396C;"
cEstilo += " border-radius: 6px;"
cEstilo += " border-color: #03396C;"
cEstilo += " font: bold 12px Arial;"
cEstilo += " padding: 6px;"
cEstilo += " background-color: #f4f7f9;"
cEstilo += "}"

//Na classe QPushButton:pressed , temos o efeito pressed, onde ao se pressionar o bot�o ele muda
cEstilo += "QPushButton:pressed {"
cEstilo += " background-color: #e68a2c;"
cEstilo += " border-style: inset;"
cEstilo += "}" 

Return cEstilo

//------------------------------------------------------------------
/*/{Protheus.doc} xCanAddOpe

Fun��o que analisar� se operando/operador/parenteses pode ou n�o ser
adicionado na f�rmula.

@param - cFormul - F�rmula atual
@param - cText -  Texto a ser adicionado no final da f�rmula

@author Erick G. Dias
@since 03/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xCanAddOpe(cModelo)
Local oModel        :=	FWModelActive()
Local oFormul	    := oModel:GetModel(cModelo)
Local cFormul       := Alltrim(oFormul:GetValue("CIN_FORMUL",1))
local cUltChar      := Alltrim(substring(cFormul , Len(cFormul)  ,1))
Local lOperador  := .F.
Local lOperando  := .F.
Local lAbertura  := .F.
Local lFechament := .F.
/*
F�rmula vazia, ou Ultimo caracter � abertura de parenteses, ou �ltimo caracter � um operandor:
    Somente habilitar bot�es de adicionar operando e abertura de parenteses

�ltimo caracter � fechamento de parenteses ou �ltimo caracter � um operando:
    Habilitar somente Bot�o de operadores bot�o de fechar parenteses

*/
If Empty(cUltChar) .Or. cUltChar $ "(" .Or. cUltChar $ "+-/*"
    //Somente habilitar bot�es de adicionar operando e abertura de parenteses    
    lOperando  := .T.
    lAbertura  := .T.    

Else //Aqui restarem as hip�teses de fechamento de parenteses e operando
    //Habilitar somente Bot�o de operadores bot�o de fechar parenteses
    lOperador   := .T.
    lFechament  := .T.

EndIF

Return {lOperador,lOperando, lAbertura, lFechament}

//------------------------------------------------------------------
/*/{Protheus.doc} xFisForCad

Fun��o que far� valida��o dos operandos contidos na f�rmula, se realmente
existem na base de dados ou n�o.
Caso todos estejam devidamente cadastrados a fun��o retornar� verdadeiro.
Caso contr�rio a fun��o retornar� falso e tamb�m a mensagem de erro com
etalhe de qual operando n�o est� cadastrado. Somente ser�o permitidos operandos
devidamente cadastrados

@param - cFormul - F�rmula atual com sintaxe 
@param - cErro - Mensagem com erro de valida��o 
@param - cExcecao - Aqui s�o operandos que n�o dever�o ser verificados, caso seja necess�rio.
@return - lret - indica se ao menos algum operando n�o foi encontrado no cadastro

@author Erick G. Dias
@since 05/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisForCad(cFormula, cErro, cExcecao)

Local aFormula	:= StrTokArr(alltrim(cFormula)," ")
Local nX        := 0 
Local lRet      := .T.
Local nTamCINCod := TamSx3("CIN_CODIGO")[1]
Default cExcecao    := ""

cErro := "As regras abaixo n�o foram encontradas no cadastro, por favor verifique: "  + CRLF + CRLF

//Itero o array para verifica se todos os operandos est�o devidamente cadastrados.
For nX := 1 to Len(aFormula)

    //N�o preciso verificar operadores e parenteses e n�meros
    If (!aFormula[nX] $ "+-*/()," .AND. aFormula[nX] <> "MAIOR" .AND. aFormula[nX] <> "MENOR") .And. !aFormula[nX] $ cExcecao .AND. !Empty(aFormula[nX]) .And. !IsDigit(aFormula[nX])
        
        //Seek na CIN buscando o c�digo da regra        
        dbSelectArea("CIN")
        dbSetOrder(1) //CIN_FILIAL+CIN_CODIGO+CIN_ALTERA+CIN_ID
        If !CIN->(MsSeek(xFilial('CIN') + Padr(aFormula[nX],nTamCINCod)  + "0" ))
            //Se n�o encontrou ent�o atualizar� a mensagem de erro com o c�digo da regra
            cErro += iif(lRet, "", ", ") +  Padr(aFormula[nX],nTamCINCod)
            lRet := .F.
        EndIF        
    EndIF

Next nX

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} xFisFDep

Fun��o que faz valida��o se o operador atual est� contido 
em sua pr�pria f�rmula, seja de forma direta ou indireta.
Farei esta verifica��o com uma fun��o recusriva, como n�o sei
quantos n�veis de f�rmulas pode ter, preciso verificar f�rmula da f�rmula
para certificar que o operador n�o est� contido em sua pr�pria f�rmula.
Irei at� encontrar um operador prim�rio, URF ou num�rico, mas enquanto houver
operador composto continuarei verificando.
Esta verifica��o � devida para evitar problema de recursividade, pois 
se A depende de B, e B depende de A, nunca seria poss�vel resolver esta f�rmula,
ficaria em loop infinito.

@param - cCodCIN - C�digo da f�rmula 
@param - cFormula - F�rmula que dever� ser verificada
@param - cErro - Mensagem de erro com detalhamento, caso o operando esteja contido em sua pr�pria f�rmula
@return - lret - Indica que operando est� contido em sua pr�pria f�rmula.

@author Erick G. Dias
@since 07/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisFDep(cCodCIN, cFormula, cErro)

Local aOperadores   := {}
Local nX            := 0
Local lRet          := .F.

//Se a f�rmula ou c�digo estiverem vazios ent�o retorno .F., pois n�o tem como verificar
If Empty(cCodCIN) .Or. Empty(cFormula)    
    Return .F.
EndIF

//Prossigo verificando o c�digo est� contido na f�rmula, se estiver j� retorno verdadeiro e atualizo a mensagem
If Alltrim(cCodCIN)  $ Alltrim(cFormula)
    cErro += "'" + cCodCIN + "' >> "
    Return .T.
Else
    //Se n�o estiver contido preciso ent�o verificar todos os operandos para saber se tem mais alguma dependencia.
    dbSelectArea("CIN")
    dbSetOrder(1)
    //Split da f�rmula
    aOperadores := StrTokArr(alltrim(cFormula)," ")
    
    //La�o nos operandos da f�rmula
    For nX := 1 to Len(aOperadores)
        
        //Operando num�rico n�o precisa ser verificado, pois n�o possui f�rmula
        //Operador tamb�m n�o precisa ser verificado
        If !(IsDigit(aOperadores[nx]) .Or. aOperadores[nx] $ "+-*/()")
            //Posiciono a CIN
            If CIN->(MsSeek(xFilial('CIN') + aOperadores[nx])) .And. Alltrim(CIN->CIN_TREGRA) $ "1#2#6#7#8#"
                //Se for operando composto, ent�o Verifico se est� contido nesta f�rmula e chama novamene a mesma fuin��o.
                lRet := xFisFDep(cCodCIN, CIN->CIN_FORMUL, @cErro)
                If lRet                    
                    cErro += "'"+  aOperadores[nx] +  "' >> "
                    Exit //Se est� contido sai do la�o e retorna                    
                EndIF            
            EndIF

            //Operando prim�rio tamb�m n�o precisa ser verificado
        Else    
            //Aqui provavelmente � um operador prim�rio ou URF, ou ainda n�o estar cadastrado na CIN, em todo caso n�o estar� contido aqui 
            //Vai para pr�ximo operador
        EndIF                

    Next NX
EndIF

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} xFisSintaxe

Fun��o que verifica a sintaxe da f�rmula, ap�s valida��es de depend�ncias,
e de operandos devidamente cadastrados

@param - cFormula - F�rmula informada pelo usu�ro
@param - cError - VAri�vel que ter� o detalhamento de erro caso houver algumm problema de sintaxe da f�rmula

@return - lret - Retorna .T. se f�rmula estiver sem erros

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisSintaxe(cFormula, cError)

Local aFormula  := {}
Local nX        := 0
Local cLastPos  := ""
Local cType     := ""
Local cDetalhe  := " "
Local nParamMax := 0
Local lContinue := .F.

//Verifico se a f�rmula est� preenchida antes de fazer o split
If !Empty(cFormula)
    aFormula	:= StrTokArr(alltrim(cFormula)," ")
Else
    cError := "F�rmula est� vazia!"
    return .f.
EndIF

//Itero o array para verificar a sintaze da f�rmula
For nX:=1 to Len(aFormula)
    
    //Obtem o tipo do componente da f�rmula
    cType   := RetTypeFor(aFormula[nX])
    lContinue   := .F.

    //Primeiro componente, somente poder� ser abertura de parenteses ou operando
    If Empty(cLastPos)
        If cType == "OPERANDO" .Or. cType == "ABERTURA" .Or. cType == "FORMULA_MAIOR_MENOR"
            lContinue   := .T.
        Else
            cError  := "F�rmula somente pode ser iniciada com operando, abertura de parenteses ou f�rmula!"
        EndIf            
    
    //Se anterior foi um operando, ent�o somente  poder� ser somente poder� ser um operador ou fechamento de parenteses    
    ElseIf cLastPos == "OPERANDO"
        If cType == "OPERADOR" .OR. cType == "FECHAMENTO"
            lContinue   := .T.
        ElseIF nParamMax > 0 //Aqui tem uma exce��o, permitir� dois operandos seguidos caso seja argumento da fun�� MAIOR ou MENOR.
            lContinue   := .T.
            nParamMax  -= 1 //Removo, indicando que j� foi utilizado operando da fun��o MAIOR ou MENOR
        Else
            cError  := "Esperado um operador ou fechamento de paranteses!"
        EndIF
    
    //Se anterior foi um operador, entao somente peritir� um operando ou abertura de parenteses    
    ElseIF cLastPos == "OPERADOR"
        If cType == "OPERANDO" .Or. cType == "ABERTURA"        
            lContinue   := .T.
        Else
            cError  := "Esperado um operando ou abertura de parenteses!"
        EndIf
    
    //Se anterior for abertura de parenteses, somene permitira outra abertura de parenteses ou um operando    
    ElseIF cLastPos == "ABERTURA"      
        If cType == "ABERTURA" .OR. cType == "OPERANDO" .OR. cType == "FORMULA_MAIOR_MENOR"
            lContinue   := .T.
        Else
            cError  := "Esperado um operando, abertura de parenteses ou f�rmula!"
        EndIf    
    
    //Se anterior for fechamento de parenteses, somene permitira outro fechamento ou um operador
    ElseIF cLastPos == "FECHAMENTO"
        If cType == "OPERADOR" .OR. cType == "FECHAMENTO"        
            lContinue   := .T.            
        Else
            cError  := "Esperado operador ou fechamento de parenteses!"
        EndIf
    
    ElseIF cLastPos == "FORMULA_MAIOR_MENOR"
        If cType == "ABERTURA"
            lContinue   := .T.  
            nParamMax   := 2 //Para f�rmula MAIOR ou MENOR pode esperar dois operandos seguidos como argumentos da fun��o
        Else
            cError  := "Esperado abertura de parenteses!"
        EndIf

    EndIF 

    If lContinue
        //Atualiza o �ltimo componente
        cLastPos    := cType
    Else
        //Alguma condi��o acima n�o foi respeitada e existe algum erro na f�rmula        
        //Verifico se posso buscar operando anterior
        If nX > 1
            cDetalhe    += aFormula[nX-1] + " "
        EndIF

        //Adiciono operando atual
        cDetalhe    += aFormula[nX] + " "

        //Verifico se posso buscar pr�ximo operando
        If nX < len(aFormula) 
            cDetalhe    += aFormula[nX+1]
        EndIF        

        cError  += + CRLF + CRLF + " Verifique o trecho abaixo:"  + CRLF + CRLF + cDetalhe
        
        exit
    EndiF

Next nX

//Caso o �ltimo elemento da f�rmula seja operador ou abertura de parenteses exibir� erro, pois n�o ser� permitido
If nX > Len(aFormula) .And. cType == "OPERADOR" .Or. cLastPos == "ABERTURA"
    cError  := "F�rmula n�o pode terminar com operadores + - * / ou abertura de parenteses!"
    lContinue   := .F.
EndIF

Return lContinue

//------------------------------------------------------------------
/*/{Protheus.doc} IsOperador

Verifica se texto � um operador
@param - cCode - F�rmula informada pelo usu�ro
@return - Retorna .T. caso seja um operador

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function IsOperador(cCode)
Return "*" $ cCode .Or. "/" $ cCode .Or. "-" $ cCode .Or. "+" $ cCode

//------------------------------------------------------------------
/*/{Protheus.doc} IsAbertura

Verifica se texto � abertura de parenteses
@param - cCode - F�rmula informada pelo usu�ro
@return - Retorna .T. caso seja abertura de parenteses

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function IsAbertura(cCode)
return "(" $ cCode

//------------------------------------------------------------------
/*/{Protheus.doc} IsFechamento

Verifica se texto � fechamento de parenteses
@param - cCode - F�rmula informada pelo usu�ro
@return - Retorna .T. caso seja fechamento de parenteses

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//-----------------------------------------------------------------
Function IsFechamento(cCode)
return ")" $ cCode

//------------------------------------------------------------------
/*/{Protheus.doc} RetTypeFor

Fun��o que recebe texto e retorna o tipo do elemento da f�rmual
@param - cCode - F�rmula informada pelo usu�ro
@return - cType - retorna o tipo do elemento da f�rmula

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//-----------------------------------------------------------------
Function RetTypeFor(cCode)

Local cType := ""

If IsFechamento(cCode)
    //Fechamento de parenteses
    cType := "FECHAMENTO"
ElseIf IsAbertura(cCode)    
    //Abertura de parenteses
    cType := "ABERTURA"
ElseIf IsOperador(cCode)    
    //Operador de parenteses
    cType := "OPERADOR"
ElseIf cCode == "MAIOR" .Or. cCode == "MENOR"
    //Aqui � f�rmula
    cType := "FORMULA_MAIOR_MENOR"
Else
    //Aqui somente sobrou operador
    cType := "OPERANDO"
EndIF

Return cType

//-------------------------------------------------------------------
/*/{Protheus.doc} FORMCARG

Fun��o respons�vel por efetuar a carga dos operandos prim�rios

@author Rafael S Oliveira
@since 06/02/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Function FORMCARG()

//Grava os operandos de valor de origem
GrvOpSys("0")
//Grava os operandos de �ndices de c�lculos
GrvOpSys("9")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvOpSys

Fun��o que grava os operandos gerados automaticamente pelo sistema

@author Erick Dias
@since 29/06/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Static Function GrvOpSys(cTpRegra)

Local aOp         := {}
Local nX          := 0
Local cAlias      := GetNextAlias()
Local cAlias2     := GetNextAlias()
Local cPrefixo    := ""
Local cCodigo     := ""
Local cFormula    := ""
Local cDescri     := ""

//Abaixo resolve quais informa��es dever�o ser gravadas/verificadas
If cTpRegra == "0"
    aOp := FormOperPri()
    cPrefixo    := xFisTpForm("0") //"0" = Operador prim�rio
ElseIf cTpRegra == "9"
    //Dados a serem carregados com operandos de �ndice de c�lculos
    aOp := FIndicesCalc()
    cPrefixo    := xFisTpForm("9") //"9" = Operador de �ndice de c�lculo
EndIf

//Query na CIN
BeginSql Alias cAlias
        
SELECT COUNT(CIN.CIN_ID) REGISTROS
FROM %TABLE:CIN% CIN
wHERE CIN.CIN_FILIAL=%XFILIAL:CIN%
AND CIN.CIN_TREGRA = %Exp:cTpRegra%
AND CIN.%NOTDEL%

EndSql

DbSelectArea (cAlias)

//Se a quantidade de registros retornada na query for igual a quantidade das informa��es, ent�o n�o precisa ser feito nada.
//Por�m se a quantidade for diferente, ent�o existe alguma informa��o que n�o est� gravada no banco, e ser� verificado uma a uma para gravar
If (cAlias)->REGISTROS < Len(aOp)    
    
    dbSelectArea("CIN")
    CIN->(dbSetOrder(1)) //CIN_FILIAL+CIN_CODIGO+CIN_ALTERA+CIN_ID
    CIN->(dbGoTop())

    //La�o doas f�rmuas verificando se est�o gravadas no banco. Se n�o estiver, ent�o o banco ser� atualizado.
    For nX := 1 to Len(aOp)

        cCodigo     := aOp[nX][2]
        cFormula    := cPrefixo + aOp[nX][2]
        cDescri     := aOp[nX][1]

        cQuery := "SELECT CIN_FILIAL, CIN_CODIGO"+CRLF
        cQuery += "FROM "+RetSqlName("CIN")+CRLF
        cQuery += "WHERE CIN_FILIAL = '"+xFilial("CIN")+"'"+CRLF
        cQuery += "AND CIN_CODIGO = '"+cFormula+"'"+CRLF

        cQuery := ChangeQuery(cQuery)

        dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias2, .F., .T.)
        (cAlias2)->(DbGoTop())

        If (cAlias2)->(EOF())  
            GravaCIN("1", cTpRegra, cCodigo, "", cDescri, cFormula)
        EndIf
        
        (cAlias2)->(dbCloseArea())
    Next
Endif


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FormOperPri

Fun��o respons�vel definir os operandos prim�rios

@author Rafael S Oliveira
@since 06/02/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Static Function FormOperPri()

Local aOpBase := {}
Local aOpAliq := {}
Local aCarga  := {}
Local nI      := 0
    
    //Adiciona Base
    aOpBase := FSA161VORI(.T.)
    
    For nI := 1  to len(aOpBase)
        If !Empty(aOpBase[nI][2]) .and. !Empty(aOpBase[nI][3])
            aAdd(aCarga,{aOpBase[nI][2] , aOpBase[nI][3]})       
        Endif
    Next

    //Adicionado registros que n�o est�o no Combo da base    
    aAdd(aCarga,{"Valor do Desconto"                                                ,"DESCONTO"                 })    
    aAdd(aCarga,{"Valor do Seguro"                                                  ,"SEGURO"                   })
    aAdd(aCarga,{"Valor das Despesas"                                               ,"DESPESAS"                 })
    aAdd(aCarga,{"ICMS Desonerado"                                                  ,"ICMS_DESONERADO"          })       
    aAdd(aCarga,{"ICMS Retido"                                                      ,"ICMS_RETIDO"              })
    aAdd(aCarga,{"Dedu��o de Subempreitada"                                         ,"DEDUCAO_SUBEMPREITADA"    })
    aAdd(aCarga,{"Dedu��o de Materiais"                                             ,"DEDUCAO_MATERIAIS"        })
    aAdd(aCarga,{"Dedu��o INSS Subcontratada"                                       ,"DEDUCAO_INSS_SUB"         })
    aAdd(aCarga,{"Dedu��o INSS"                                                     ,"DEDUCAO_INSS"             })
    aAdd(aCarga,{"Base do IPI na Transfer�ncia"                                     ,"BASE_IPI_TRANSFERENCIA"   })
    aAdd(aCarga,{"Custo (�ltima Aquisi��o)"                                         ,"CUSTO_ULT_AQUI"          })
    aAdd(aCarga,{"Desconto (�ltima Aquisi��o)"                                      ,"DESCONTO_ULT_AQUI"       })
    aAdd(aCarga,{"MVA (�ltima Aquisi��o)"                                           ,"MVA_ULT_AQUI"            })
    aAdd(aCarga,{"Quantidade (�ltima Aquisi��o)"                                    ,"QUANTIDADE_ULT_AQUI"     })
    aadd(aCarga,{"Valor unitario (�ltima Aquisi��o)"                                ,"VLR_UNITARIO_ULT_AQUI"})
    aadd(aCarga,{"Valor antecipa��o (�ltima Aquisi��o)"                             ,"VLR_ANTECIPACAO_ULT_AQUI"})
    aadd(aCarga,{"Valor ICMS (�ltima Aquisi��o)"                                    ,"ICMS_ULT_AQUI"})
    aadd(aCarga,{"Indice auxiliar de FECP (�ltima Aquisi��o)"                       ,"IND_AUXILIAR_FECP_ULT_AQUI"})
    aadd(aCarga,{"Base ICMS ST (�ltima Aquisi��o)"                                  ,"BASE_ICMSST_ULT_AQUI"})
    aadd(aCarga,{"Aliquota ICMS ST (�ltima Aquisi��o)"                              ,"ALQ_ICMSST_ULT_AQUI"})
    aadd(aCarga,{"Valor ICMS ST (�ltima Aquisi��o)"                                 ,"VLR_ICMSST_ULT_AQUI"})
    aadd(aCarga,{"Base FECP ST (�ltima Aquisi��o)"                                  ,"BASE_FECP_ST_ULT_AQUI"})
    aadd(aCarga,{"Aliquota FECP ST (�ltima Aquisi��o)"                              ,"ALQ_FECP_ST_ULT_AQUI"})
    aadd(aCarga,{"Valor FECP ST (�ltima Aquisi��o)"                                 ,"VLR_FECP_ST_ULT_AQUI"})
    aadd(aCarga,{"Base ICMS ST Recolhido Anteriormente (�ltima Aquisi��o)"          ,"BASE_ICMSST_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Aliquota ICMS ST Recolhido Anteriormente (�ltima Aquisi��o)"      ,"ALQ_ICMSST_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Valor ICMS ST Recolhido Anteriormente (�ltima Aquisi��o)"         ,"VLR_ICMSST_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Base FECP Recolhido Anteriormente (�ltima Aquisi��o)"             ,"BASE_FECP_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Aliquota FECP Recolhido Anteriormente (�ltima Aquisi��o)"         ,"ALQ_FECP_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Valor FECP Recolhido Anteriormente (�ltima Aquisi��o)"            ,"VLR_FECP_REC_ANT_ULT_AQUI"})
    aAdd(aCarga,{"Valor Zero de Base / Al�quota"                                    ,"ZERO"                    })
    aAdd(aCarga,{"Aliq.Contribui��o Previdenci�ria (CPRB)"                          ,"ALQ_CPRB"                 })
    aAdd(aCarga,{"Valor Manual"                                                     ,"VAL_MANUAL"              })
    aadd(aCarga,{"Base ICMS (�ltima Aquisi��o)"                                     ,"BASE_ICMS_ULT_AQUI"})
    aadd(aCarga,{"Aliquota ICMS (�ltima Aquisi��o)"                                 ,"ALQ_ICMS_ULT_AQUI"})
    aadd(aCarga,{"Valor do ICMS (Ultima Aquisi��o de Estrutrura de Produto)"        ,"VLR_ICMS_ULT_AQUI_ESTRUTURA"})
    aadd(aCarga,{"Base ICMS ST Recolhido Anteriormente "                            ,"BASE_ICMSST_REC_ANT"})
    aadd(aCarga,{"Aliquota ICMS ST Recolhido Anteriormente "                        ,"ALQ_ICMSST_REC_ANT"})
    aadd(aCarga,{"Valor ICMS ST Recolhido Anteriormente "                           ,"VLR_ICMSST_REC_ANT"})
    aadd(aCarga,{"Base FECP Recolhido Anteriormente "                               ,"BASE_FECP_REC_ANT"})
    aadd(aCarga,{"Aliquota FECP Recolhido Anteriormente "                           ,"ALQ_FECP_REC_ANT"})
    aadd(aCarga,{"Valor FECP Recolhido Anteriormente "                              ,"VLR_FECP_REC_ANT"})
  
    //Adicona Aliquota
    aOpAliq := C162CBOX(.T.)
    
    For nI := 1  to len(aOpAliq)
        If !Empty(aOpAliq[nI][2]) .and. !Empty(aOpAliq[nI][3])
            aAdd(aCarga,{aOpAliq[nI][2] , aOpAliq[nI][3]})       
        Endif
    Next          

    //Adicionado registro que n�o est�o no Combo da al�quota
    aAdd(aCarga,{"Alq. Apura��o SN ISS"     ,"ALQ_SIMPLES_NACIONAL_ISS"     })
    aAdd(aCarga,{"Alq. Apura��o SN ICMS"    ,"ALQ_SIMPLES_NACIONAL_ICMS"    })

Return aCarga


//-------------------------------------------------------------------
/*/{Protheus.doc} FIndicesCalc

Fun��o respons�vel por retornar os operandos dos �ndices de c�lculos, como
MVA, Majora��, Pauta.

@author Erick Dias
@since 29/06/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Static Function FIndicesCalc()
Local aCarga    := {}

//Adicionando os operandos de �ndice de c�lculos vinculados ao cadastro de NCM 
aAdd(aCarga,{"Percentual Redu��o de Base"                   ,"PERC_REDUCAO_BASE"         })
aAdd(aCarga,{"Margem de Valor Agregado"                     ,"MVA"                       })
aAdd(aCarga,{"Percentual de Majora��o de Al�quota"          ,"MAJORACAO"                 })
aAdd(aCarga,{"Valor de Pauta"                               ,"PAUTA"                     })
aAdd(aCarga,{"�ndice Auxiliar de MVA"                       ,"INDICE_AUXILIAR_MVA"       })
aAdd(aCarga,{"�ndice Auxiliar de Majora��o"                 ,"INDICE_AUXILIAR_MAJORACAO" })   
aAdd(aCarga,{"Al�quota Tabela Progressiva"                  ,"ALIQ_TAB_PROGRESSIVA"      })   
aAdd(aCarga,{"Dedu��o Tabela Progressiva"                   ,"DED_TAB_PROGRESSIVA"       })   
aAdd(aCarga,{"Dedu��o por Dependentes"                      ,"DED_DEPENDENTES"           })   
aAdd(aCarga,{"Al�quota da opera��o de Servi�o"              ,"ALQ_SERVICO"               })
aAdd(aCarga,{"Indicadores Econ�micos FCA"                   ,"INDICE_AUXILIAR_FCA"       })
aAdd(aCarga,{"Percentual de Diferimento"                    ,"PERC_DIFERIMENTO"          })

Return aCarga

//-------------------------------------------------------------------
/*/{Protheus.doc} PesqCIN
Fun��o executada quando usu�rio entrada na rotina FISA170
Esta rotina verifica a inexistencia de formlas para regras de base, aliquota ou calculo 

Retorna registros da tabela especificada n�o encontrados na CIN

@author Rafael S Oliveira
@since 10/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------

Function PesqCIN(cTab) 
Local cAlias    := GetNextAlias()
Local cId	    := cTab+"_ID"
Local cFrom	    := RetSqlName(cTab) + " "+ cTab
Local cWhere	:= cTab+".D_E_L_E_T_=' '"

cId     := "%"+cId+"%" 
cFrom   := "%"+cFrom+"%"
cWhere  := "%"+cWhere+"%"

//Retorna registros n�o encontrados em ambas as tabelas
BeginSql Alias cAlias

    SELECT
        %Exp:cId%
    FROM
        %Exp:cFrom%
    LEFT OUTER JOIN %TABLE:CIN% CIN ON (CIN_IREGRA = %Exp:cId% AND CIN.%NOTDEL%)
    WHERE 
        CIN.CIN_IREGRA IS NULL
        AND	 %Exp:cWhere%

EndSql

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} vldPreFixFor
Fun��o que realizar a valida��o do prfixo da f�rmula do tributo com as 
regras de base e al�quota selecionadas.
Isso � necess�rio pois o usu�rio somente poder� editar a f�rmula
depois da base * al�quota, do contr�rio n�o saberemos o que gravar no campo
base e al�quota, ter�amos somente o valor.

@param cFormula - F�rmula atual da regra
@param cRetErro - Erro a ser exibido caso o prefixo n�o corresponda
@return - retorna verdadeiro se o prefixo corresponder

@author Erick Dias
@since 11/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function vldPreFixFor(cFormula, cRetErro)

Local aFormula	:= StrTokArr(alltrim(cFormula)," ")
Local lRet      := .F.
Local cPrefixo  := ""
Local cRegras   := Fsa160Prefix()
Local nX        := 0 
//TODO rever aqui esta valida��o...podemos ter diversos modelos e n�o d� pra chumbar somente um padr�o.
// cRetErro    := "O prefixo da f�rmula deve corresponder as regras de base e al�quota informadas:" +  CRLF +  CRLF + cRegras

// //Itero o array para verifica se todos os operandos est�o devidamente cadastrados.
// For nX := 1 to Len(aFormula)
//     cPrefixo += Alltrim(aFormula[nX])
//     If cPrefixo == cRegras
//         lRet    := .T.
//         cRetErro    := ""
//     EndIF
// Next nX

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} HabEditTrib
Fun��o auxiliar que permte habilitar o bot�o de edi��o da f�rmula
no cadastro do tributo.

@param cModelo - Modelo a qual est� consumindo o componente da f�rmula
@return - Retorna verdadeiro se deve habilitar o bot�o editar.

@author Erick Dias
@since 13/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function HabEditTrib(cModeloCab,cModelo)
Local lRet  := .T.

IF cModelo == "FORMULCAL"
    lRet    := Fsa160ETrb()
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTPCIN
Fun��o auxiliar que retorna os tipo da CIN
conforme selecionado no combo.
A princ�pio esta fun��o ser� utilizada na consulta padr�o da CIN

@author Erick Dias
@since 16/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function xFisTPCIN()
Local nTipo := M->CIN_FILTRO
Local cRet  := ""

If nTipo == "01" //Regras Prim�rias
    cRet  := "0 "
ElseIf nTipo == "02" //Regras de Base de C�lculo
    cRet  := "1 "
ElseIf nTipo == "03" //Regras de Al�quota
    cRet  := "2 "
ElseIf nTipo == "04" //URF
    cRet  := "4 "
ElseIf nTipo == "05" //Regras de Tributos
    cRet  := "6 /7 /8 /11/12/13"
ElseIf nTipo == "06" //�ndices de c�lculo
    cRet  := "9 "    
ElseIf nTipo == "07" //Al�quotas da tabela progressiva
    cRet  := "11"    
ElseIf nTipo == "08" //Dedu��o da tabela progressiva
    cRet  := "12"            
ElseIf nTipo == "09" //Dedu��o por dependentes
    cRet  := "13"            
EndIF
 
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTRBCIN
Fun��o auxiliar que retorna o tributo selecionado pelo usu�rio
para poder filtrar a consulta das regras

@author Erick Dias
@since 16/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function xFisTRBCIN()
Return M->CIN_TRIB

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTRBCIN
Fun��o que retorna as op��es do combo para filtrar o tipo das regras.
@author Erick Dias
@since 16/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function XFISTREGRA()                                                                                                                   

Local cRet := '01=Valores de Origem;02=Regra Base de C�lculo;03=Regra de Al�quota;04=Regras de URF;05=Regras de Tributo;06=�ndices de C�lculo;ZZ=Valor Manual'

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} HelpPrx
Fun��o que monta tela com mais informa��es e eplica��es sobre os prefixos.

@author Erick Dias
@since 08/07/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function HelpPrx()

Local cTxtIntro := ""
cTxtIntro += "<table width='100%' border=2 cellpadding='15' cellspacing='5'>"
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='5' align='center'><font face='Tahoma' size='+2'>"
cTxtIntro += "<b>Detalhamento dos Prefixos das Regras.</b>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>"
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='5'><font face='Tahoma' color='#000099' size='+1'>"
cTxtIntro += "'O:' Regras criadas automaticamente pelo sistema, possuem valores de origem do documento fiscal, tais como frete, desconto e valor da mercadoria.<br><br>"
cTxtIntro += "'B:' Regras de Base de C�lculo criadas pelo usu�rio.<br><br>"
cTxtIntro += "'A:' Regras de Al�quota criadas pelo usu�rio.<br><br>"
cTxtIntro += "'U:' Regras de Unidade de Refer�ncia Fiscal(URF) criadas pelo usu�rio.<br><br>"
cTxtIntro += "'I:' �ndices criados automaticamente pelo sistema, tais como percentual de Majora��o, MVA e Pauta.<br><br>"
cTxtIntro += "'BAS:' Base de C�lculo do Tributo.<br><br>"
cTxtIntro += "'ALQ:' Al�quota do Tributo.<br><br>"
cTxtIntro += "'VAL:' Valor do Tributo.<br><br>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>"
cTxtIntro += "</table>"

DEFINE MSDIALOG oDlgUpd TITLE "TCF(Totvs Configurador de Tributos)" FROM 00,00 TO 430,700 PIXEL
TSay():New(005,005,{|| cTxtIntro },oDlgUpd,,,,,,.T.,,,340,300,,,,.T.,,.T.)       
//TButton():New( 220,180, '&Processar...', oDlgUpd,{|| RpcClearEnv(), oProcess := MsNewProcess():New( {|| FISProcUpd(aEmpr, oProcess) }, 'Aguarde...', 'Iniciando Processamento...', .F.), oProcess:Activate(), oDlgUpd:End()},075,015,,,,.T.,,,,,,)
//TButton():New( 220,270, '&Cancelar', oDlgUpd,{|| RpcClearEnv(), oDlgUpd:End()},075,015,,,,.T.,,,,,,)

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BackSpace
Fun��o que deleta o �ltimo operando/operador da f�rmula, para que n�o seja
necess�rio refazer toda a f�rmula

@author Erick Dias
@since 14/07/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function BackSpace(cModelo, lRefresh, cView)

Local oModel    :=	FWModelActive()
Local oFormul	:= oModel:GetModel(cModelo)
Local oView 	:= 	FWViewActive()
Local cForm     := oFormul:GetValue("CIN_FORMUL",1)
Local aFormula	:= StrTokArr(alltrim(cForm)," ")
Local cNewFor   := " "
Local nX        := 0

//Montarei a f�rmula sem �ltimo elemento
For nX:= 1 to Len(aFormula) - 1
    cNewFor += aFormula[nX]
    cNewFor += " "
Next nX

//Limpa o conte�do das f�rmulas e do c�digo da regra
oFormul:LoadValue('CIN_FORMUL', cNewFor )

//Atualiza as Views
If lRefresh .And. !Empty(cView)
	oview:Refresh( cView )
Endif

Return
