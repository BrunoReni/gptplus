#INCLUDE 'protheus.ch'
#include "TBICONN.CH"
#include "BCWIZARDSC.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BCWizardSc
Função principal que tem como objetivo a abertura da tela  para a
configuração do plano de contas.
@param aWizard, array, array contendo as empresas e sua  estrutura
de contas
BC
@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
Main function BCWizardSc(aWizard) 
	Local oLayer       := FWLayer():New()
    LOCAL nElem := 1
    Local nFilial 
    PUBLIC oDialog      := Nil
    PUBLIC oFont := Nil
    PUBLIC cCombo1 := Nil
    PUBLIC oTree := NIL
    PUBLIC nCompany 
    PUBLIC nBranch
	Static lContinue   := .F.

	//-------------------------------------------------------------------
	// Monta tela de WIZARD das contas contabeis
	//-------------------------------------------------------------------
	DEFINE DIALOG oDialog TITLE "TOTVS - WIZARD" FROM 050, 051 TO 800,800 PIXEL 
		//-------------------------------------------------------------------
		// Monta as sessôes da tela. 
		//-------------------------------------------------------------------  
		oLayer:Init( oDialog )
		oLayer:addLine( "TOP", 80, .F.) 
		oLayer:addCollumn( "TOP_ALL",100, .T. , "TOP")
		oLayer:addWindow( "TOP_ALL", "TOP_WINDOW", STR0001 , 900, .F., .T.,, "TOP"    ) //Validar as contas contabeis
        
        oLayer:addWindow( "TOP_ALL", "TOP2_WINDOW", STR0002 , 50, .F., .T.,, "TOP"    ) //Arvore

		oTop    := oLayer:getWinPanel( "TOP_ALL", "TOP_WINDOW", "TOP" )
        oParam  := oLayer:getWinPanel( "TOP_ALL", "TOP2_WINDOW", "TOP" )

        oPnlInfo:=TPanel():New(0,0,,oTop,   NIL, .T., .F., NIL, /*RGB(255,147,157)*/, 050,050,  .F., .F. )
        oPnlInfo:Align := CONTROL_ALIGN_ALLCLIENT

        oScrollSay := TScrollBox():New(oPnlInfo,000,000,130,365,.T.,.T.,.T.)

        // Cria Fonte para visualização
        //-------------------------------------------------------------------  
        oFont := TFont():New('Courier new',,-12,.T.)

        //-------------------------------------------------------------------
		// Declara as variaveis que serão utilizadas
		//-------------------------------------------------------------------  
        aItens := {STR0003,STR0004} //Padrão#Customizado
        nLinRadio := 20
        nNumElem := LEN(aWizard)
        aRadio  := {}
        aNomEmp := {}
        aButEmp := {}
        nTipo := {}

        oSayR1:= TSay():New(05,010,{|| STR0017+" / "+STR0018 },oScrollSay,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //Empresa#Filial
        oSayR2:= TSay():New(05,150,{|| STR0019 },oScrollSay,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)  //Opcoes 

        //-------------------------------------------------------------------
		// Criação dos componentes para empresa / Filial 
		//-------------------------------------------------------------------  

        For nElem := 1 to Len (aWizard)
            aadd(aRadio,{nElem})
            aadd(aNomEmp, {nElem})
            aadd(aButEmp, {nElem})
            aadd(nTipo, {nElem})

            for nFilial := 2 to len (aWizard[nElem])
                aadd(aRadio[nElem],nFilial)
                aadd(aNomEmp[nElem], nFilial)
                aadd(aButEmp[nElem], nFilial)
                aadd(nTipo[nElem], nFilial)

                aButEmp[nElem][nFilial] := TButton():New( nLinRadio, 300,STR0005,oScrollSay,{|u|newTree(u:cname)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //visualizar
                aButEmp[nElem][nFilial] :CNAME := alltrim(str(nElem))+":"+alltrim(str(nFilial))
                
                aNomEmp[nElem][nFilial]:= TSay():New(nLinRadio,010,{||iif(nElem > Len (aWizard),setNameEmp(aNomEmp, aWizard),aWizard[nElem][1]+" / "+aWizard[nElem][nFilial][1])},oScrollSay,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
                
                aRadio[nElem][nFilial] := TRadMenu():New(nLinRadio,120,aItens,{|u| iif(nElem > Len (aWizard), 1,If (PCount()==0,nTipo[nElem][nFilial],nTipo[nElem][nFilial]:=u))},oScrollSay,,{|u|bt(u), oTop:refresh()},,,,,,100,100,,,,.T.)
                aRadio[nElem][nFilial] :CNAME := alltrim(str(nElem))+":"+alltrim(str(nFilial))
                aRadio[nElem][nFilial] :CREADVAR := '1'
                aRadio[nElem][nFilial] :lHoriz := .t.
                
                nLinRadio += 20
            next
        next
        
        //Linha inclusa para dar refresh na ultima linha.
        aNomEmp[(nElem-1)][(nFilial-1)]:= TSay():New((nLinRadio-20),010,{||aWizard[(nElem-1)][1]+" / "+aWizard[(nElem-1)][(nFilial-1)][1]},oScrollSay,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

        oDialog:refresh()
        refreshBt()


	ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, { ||  lContinue := .T., oDialog:End() }, { || oDialog:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. )   

RETURN aWizard

//-------------------------------------------------------------------
/*/{Protheus.doc} setNameEmp
Seta o nome da Empresa e filial na label

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function setNameEmp(aNomEmp, aWizard)
    local nElem := 1
    local nFilial 
    For nElem := 1 to Len (aWizard)
        for nFilial := 2 to len (aWizard[nElem])
            aNomEmp[nElem][nFilial]:cTitle = aWizard[nElem][1]+" / "+aWizard[nElem][nFilial][1]
        next
    next

    refreshBt()
    
RETURN aWizard[(nElem-1)]

//-------------------------------------------------------------------
/*/{Protheus.doc} refreshBt
Atualiza as labels do botão.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function refreshBt()
    local nElem := 1
    local nFilial
    For nElem := 1 to Len (aWizard)
        for nFilial := 2 to len (aWizard[nElem])
            if(val(aRadio[nElem][nFilial]:CREADVAR) = 1)
                aButEmp[nElem][nFilial]:CTITLE =  STR0005//Visualizar
            else
                aButEmp[nElem][nFilial]:CTITLE =  STR0006//Alterar
            ENDIF
        NEXT
    NEXT

RETURN NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} bt
Função para alternar as opções do Botão.
@param Elem, string, Coordenadas de Empresa e filial para exibição.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function bt(Elem)

    aElem :=  StrTokArr2(Elem:CNAME,':')

    if(aRadio[val(aElem[1])][val(aElem[2])]:CREADVAR = '1')
        aRadio[val(aElem[1])][val(aElem[2])]:CREADVAR := '2'
    else
        aRadio[val(aElem[1])][val(aElem[2])]:CREADVAR := '1'
    ENDIF
    refreshBt()
return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} newTree
Cria a arvore para exibição na tela.
@param Elem, string, Coordenadas de Empresa e filial para exibição.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
Static Function newTree(Elem)
    Local aOptions:= {STR0007,STR0008,STR0009,STR0010,STR0011, STR0016 } //Ativo#Passivo#Receitas#Despesas#Custos#Outros
    Local n
    oTree := TTree():New(0,0,130,260,oParam,,)
    oTree:BeginUpdate()

    aNodes := {}
    aElem :=  StrTokArr2(Elem,':')

    nCompany := val(aElem[1])
    nBranch  := val(aElem[2])

    for n := 2 to len (aWizard[nCompany][nBranch])
        aadd( aNodes, {StrZero(val(aWizard[nCompany][nBranch][n][2]),11), StrZero(val(aWizard[nCompany][nBranch][n][1]),11), "", aWizard[nCompany][nBranch][n][1] + ":"+ aWizard[nCompany][nBranch][n][4] , getColor(aWizard[nCompany][nBranch][n][3]),} )
    next
    oTree:PTSendTree( aNodes )

    oTree:PTSendNodes()
    oTree:EndUpdate()

    oSayTree := TSay():New(200,280,{|| STR0012 },oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Reclassificar a conta"
    oSayTree2 := TSay():New(210,280,{|| getNameComp(nCompany, nBranch)},oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)    
    cCombo1:= aOptions[1]
    oCombo1 := TComboBox():New(220,280,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aOptions,50,20,oDialog,,,,,,.T.,,,,,,,,,'cCombo1')
    oReclas := TButton():New( 240, 290,STR0013,oDialog,{|u|changeElem(Elem)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Reclassificar
    oReclas:SetCss("TButton{background-color:#043d73 ; color: #FFFFFF}")

    TBtnBmp2():New(520, 560, 26, 26, 'BR_AZUL', NIL, NIL, NIL, NIL, oDialog, STR0007, NIL, .T.)
    TBtnBmp2():New(540, 560, 26, 26, 'BR_AMARELO', NIL, NIL, NIL, NIL, oDialog, STR0008, NIL, .T.)
    TBtnBmp2():New(560, 560, 26, 26, 'BR_VERDE', NIL, NIL, NIL, NIL, oDialog, STR0009, NIL, .T.)
    TBtnBmp2():New(580, 560, 26, 26, 'BR_LARANJA', NIL, NIL, NIL, NIL, oDialog, STR0010, NIL, .T.)
    TBtnBmp2():New(600, 560, 26, 26, 'BR_MARROM', NIL, NIL, NIL, NIL, oDialog, STR0011, NIL, .T.)
    TBtnBmp2():New(620, 560, 26, 26, 'BR_PRETO', NIL, NIL, NIL, NIL, oDialog, STR0016, NIL, .T.)

    TSay():New(261,300,{|| STR0007 },oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //Ativo
    TSay():New(271,300,{|| STR0008 },oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //Passivo
    TSay():New(281,300,{|| STR0009 },oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // Receitas
    TSay():New(292,300,{|| STR0010 },oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // Despesas
    TSay():New(302,300,{|| STR0011 },oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)  //Custos
    TSay():New(312,300,{|| STR0016 },oDialog,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)  //Outros

    oDialog:refresh()

RETURN Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} changeElem
Faz a reclassificação do nó, assim como os filhos e seus pais.
@Elem, string, coordenadas da empresa e filial a ser alterada.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
Static function changeElem(Elem)

    local nAux := 1
    local aCompAux := aclone(aWizard)
    local aElem :=  StrTokArr2(Elem,':')
    local nCompany := val(aElem[1])
    local nBranch  := val(aElem[2])

    if(aRadio[nCompany][nBranch]:CREADVAR == '1')
        MessageBox(STR0014, STR0020,0) //"Modo de visualizacao!#erro"

    elseif(EMPTY(oTree:PTGetPrompt()))
        MessageBox(STR0015, STR0020,0) //"selecione uma conta!#erro"
    else
        aNode := StrTokArr2(oTree:PTGetPrompt(),':')
        aElem :=  StrTokArr2(Elem,':')

        if(n := ASCAN(aCompAux[nCompany][nBranch], {|x| getNode(x, aNode[1])})) > 0 

            aCompAux[nCompany][nBranch][n][3] := getClass(cCombo1)
        
        ENDIF

        for nAux := 2 to len (aCompAux[nCompany][nBranch])

            if (len(alltrim(aNode[1])) > len(alltrim(aCompAux[nCompany][nBranch][nAux][1])) .and. SubStr(alltrim(aNode[1]), 1, len(alltrim(aCompAux[nCompany][nBranch][nAux][1]))) == alltrim(aCompAux[nCompany][nBranch][nAux][1]))

                aCompAux[nCompany][nBranch][nAux][3] := 'N'
            ENDIF
            if (len(alltrim(aNode[1])) < len(alltrim(aCompAux[nCompany][nBranch][nAux][1])) .and. SubStr(alltrim(aCompAux[nCompany][nBranch][nAux][1]), 1, len(alltrim(aNode[1]))) == alltrim(aNode[1]))

                aCompAux[nCompany][nBranch][nAux][3] := getClass(cCombo1)
            ENDIF              
        next
        aWizard := ACLONE( aCompAux )

        newTree(Elem)

    ENDIF
return

//-------------------------------------------------------------------
/*/{Protheus.doc} BCWizardTable
Retorna a cor de acordo com classificação da conta

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
Static Function getColor(cClass)
  // Cria novo item na Tree
    cColor := "BR_PRETO"

    DO CASE
        CASE cClass == 'A'
            cColor  := "BR_AZUL"
        CASE cClass == 'P'
            cColor  := "BR_AMARELO"
        CASE cClass == 'R'
            cColor  := "BR_VERDE"
        CASE cClass == 'D'
            cColor  := "BR_LARANJA"
        CASE cClass == 'C'
            cColor  := "BR_MARROM"
    ENDCASE

Return cColor

//-------------------------------------------------------------------
/*/{Protheus.doc} getClass
Retorna a classe do lançamento.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
Static Function getClass(name)
    cClass := "N"

    DO CASE
        CASE name == STR0007 //'Ativo'
            cClass := "A"
        CASE name == STR0008 //'Passivo'
            cClass := "P"
        CASE name == STR0009 //'Receitas'
            cClass := "R"
        CASE name == STR0010 //'Despesas'
            cClass := "D"
        CASE name == STR0011 //'Custos'
            cClass := "C"
    ENDCASE

Return cClass

//-------------------------------------------------------------------
/*/{Protheus.doc} getNode
Função para validar apenas se o nó é igual ao valor passado.
Foi criada apenas para não executar quando for diferente de 
caracter.
@param x, array, array contendo o nó a ser avaliar.
@param node, string, nome da conta a ser avaliar.

@author Rodrigo Soares  
@since 10/03/2020
/*/
//-------------------------------------------------------------------
static function getNode(x, node)
    vAux := x
    if(type('vAux') !='C')
        IF(alltrim(x[1]) == alltrim(node))
            RETURN .t.
        ENDIF
    ENDIF
return .f.

static function getNameComp(x, y)

return aWizard[x][1]+" / "+aWizard[x][y][1]

