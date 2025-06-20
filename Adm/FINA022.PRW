#Include "PROTHEUS.CH"
#Include 'FWMVCDef.ch'
#Include 'FINA022.ch'

Static __cSitCob		:= NIL
Static __aRet			:= {}
Static __cLstCart		:= ""
Static __cLstBco		:= ""
Static __cLstDesc		:= ""
Static __cLstProt		:= ""
Static __cLstAll		:= ""
Static __cLstBcoNoDesc	:= ""
Static __cLstNoBlqd		:= ""
Static __cLstSit0		:= ""
Static lBlind

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA022
manuten��o de situacao de cobran�a

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA022()
Local oBrowse

// Incluido por causa da rotina MSDOCUMENT, o MVC n�o precisa de nenhuma vari�vel private
Private cCadastro	:= STR0001		//'Situa��o de Cobran�a'
Private aRotina		:= MenuDef()

ChkFile("FRV")
dbSelectArea('FRV')
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'FRV' )
oBrowse:SetDescription( cCadastro )
oBrowse:SetMainProc("FINA022")
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicao das acoes da rotina

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.FINA022'	OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.FINA022'	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.FINA022'    OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0008	ACTION 'VIEWDEF.FINA022'    OPERATION 5 ACCESS 0 //'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr1	:= F022Struct('FRV') //FWFormStruct(1,'FRV')
Local oStr2 := F022Struct('FW2')
lBlind := IsBlind()
oStr1:SetProperty('FRV_BLQMOV', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "Pertence('12') .AND. F022VldBlq() "))

oModel := MPFormModel():New('FINA022', /*bPreValidacao*/,{ |oModel| F022POSVL(oModel) },  /*bGrvModel*/, /*bCancel*/ )

oModel:SetDescription(STR0001)		//'Situa��o de Cobran�a'
oModel:addFields('FRVMASTER',,oStr1)
oModel:addGrid('FW2DETAIL','FRVMASTER',oStr2, { |oModelGrid, nLine, cAction,cField| FW2LINPRE(oModelGrid,nLine,cAction,cField) }, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:getModel('FRVMASTER'):SetDescription(STR0001)		//'Situa��o de Cobran�a'
oModel:getModel('FW2DETAIL'):SetDescription(STR0019)		//"Processos de Bloqueio"

oModel:GetModel('FW2DETAIL'):SetOptional( .T. )
oModel:SetRelation('FW2DETAIL',{ {'FW2_FILIAL','XFILIAL("FW2")'} ,{'FW2_SITUAC','FRV_CODIGO'} }, FW2->(IndexKey(1)) )

oModel:GetModel( 'FW2DETAIL' ):SetUniqueLine( { 'FW2_CODIGO' } )

oModel:SetVldActivate( {|oModel| F022VLMod(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel:= ModelDef()
Local oStr1	:= FWFormStruct(2, 'FRV')
Local oStr2	:= FWFormStruct(2,'FW2',{ |x| !ALLTRIM(x) $ 'FW2_SITUAC'})

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'FRVMASTER' )
oView:AddGrid('FORM2' , oStr2,'FW2DETAIL')

oView:CreateHorizontalBox( 'BOXFORM1', 40)
oView:CreateHorizontalBox( 'BOXFORM2', 60)

oView:SetOwnerView('FORM2','BOXFORM2')
oView:SetOwnerView('FORM1','BOXFORM1')
oView:EnableTitleView('FORM1' , STR0001 ) 	//'Situa��o de Cobran�a'
oView:EnableTitleView('FORM2' , STR0019 ) 	//"Processos de Bloqueio"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F022Struct
Monta a estrutura do Model

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F022Struct(cTabela)
Local oStruct := NIL

//Cria��o de Gatilho
// [01] Id do campo de origem
// [02] Id do campo de destino
// [03] Bloco de codigo de valida��o da execu��o do gatilho
// [04] Bloco de codigo de execu��o do gatilho
If cTabela == "FRV"
    oStruct := FWFormStruct(1, "FRV" )
    oStruct:AddTrigger( "FRV_BANCO"  	, "FRV_BANCO"  	, {|| .T. }  , {|| F022Trigger("FRV_BANCO") }  )
    oStruct:AddTrigger( "FRV_DESCON"  	, "FRV_DESCON"  	, {|| .T. }  , {|| F022Trigger("FRV_DESCON") }  )
Endif

If cTabela == "FW2"
    oStruct := FWFormStruct(1, "FW2" )
    oStruct:AddTrigger('FW2_CODIGO','FW2_DESCRI',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FW1', 1, FWxFilial('FW1') + oModel:GetModel("FW2DETAIL"):GetValue("FW2DETAIL","FW2_CODIGO"), 'FW1_DESCRI')})
Endif

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} F022Trigger
Gatilho dos campos FRV_BANCO e FRV_DESCON

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F022Trigger(cCampo)
Local oModel		:= FWModelActive()
Local cRet			:= oModel:GetValue("FRVMASTER",cCampo)
Local cBanco 		:= oModel:GetValue("FRVMASTER","FRV_BANCO")
Local cDescontada	:= oModel:GetValue("FRVMASTER","FRV_DESCON")
Local aArea 		:= GetArea()

If cBanco == '2'
    oModel:LoadValue("FRVMASTER","FRV_DESCON","2")
    oModel:LoadValue("FRVMASTER","FRV_PERCEN",0)
    oModel:LoadValue("FRVMASTER","FRV_NATIOF",Space(10))
ElseIf cDescontada == '2'
    oModel:LoadValue("FRVMASTER","FRV_PERCEN",0)
    oModel:LoadValue("FRVMASTER","FRV_NATIOF",Space(10))
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F022VLMod
Realiza a validacao do modelo de dados do MVC

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F022VLMod(oModel As Object) As Logical
    Local cTechFin   As Character

    Local lRet       As Logical

    Local nOperation As Numeric
    Local nTamSx3    As Numeric

    lRet       := .T.
    nOperation := oModel:GetOperation()
    nTamSx3    := TamSX3("E1_SITUACA")[1]

    cTechFin   := PadR(SuperGetMV("MV_CARTECF",, ""), nTamSx3)
    cTechFin   += "|" + PadR(SuperGetMV("MV_DEVTECF",, ""), nTamSx3)

    If lRet .And. (nOperation == MODEL_OPERATION_UPDATE ) .And. FRV->FRV_CODIGO $ cTechFin
        Help(" ",1,"FN022ALT",,"N�o � poss�vel alterar situa��o de cobran�a TECHFIN" ,1,0) //"N�o � poss�vel alterar situa��o de cobran�a TECHFIN"
        lRet := .F.
    EndIf

    If lRet .And. (nOperation == MODEL_OPERATION_DELETE )
        If Alltrim(FRV->FRV_CODIGO) $ "0|1|2|3|4|5|6|7|F|G|H|I|J"
            Help(" ",1,"FA022NODEL1",,STR0009 ,1,0)		//"Esta situa��o de cobran�a � padr�o do sistema e n�o poder� ser excluida."
            lRet := .F.
        Endif

        If lRet .And. FRV->FRV_CODIGO $ cTechFin
            Help(" ",1,"FN022DEL",,"N�o � poss�vel excluir situa��o de cobran�a TECHFIN" ,1,0) //"N�o � poss�vel excluir situa��o de cobran�a TECHFIN""
            lRet := .F.
        EndIf

        If lRet .and. Fa022canDel(FRV->FRV_CODIGO)
            Help(" ",1,"FA022NODEL2",,STR0010 ,1,0)		//"Esta situa��o de cobran�a possui movimentos relacionados a mesma e n�o poder� ser excluida."
            lRet := .F.
        Endif

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F022POSVL
Realiza a p�s valida��o do modelo de dados do MVC

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F022POSVL(oModel)
Local lRet			:= .T.
Local nOperation 	:= oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT

    lRet := F022VDTI(oModel)

ElseIf nOperation == MODEL_OPERATION_DELETE
    If !lBlind
        lRet := MsgNoYes(STR0011)		//"Deseja excluir a situa��o de cobran�a?"
    EndIf
    If !lRet
        Help( " ", 1, "F022CANC",,STR0012, 1, 0 ) 	//"Opera��o cancelada"
    EndIf
EndIf

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} F022VDTI
Realiza a p�s valida��o de inclus�o ou altera��o

@author pequim

@since 26/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function F022VDTI(oModel)
Local lRet			:= .T.
Local cDescricao	:= oModel:GetValue("FRVMASTER","FRV_DESCRI")
Local cBanco		:= oModel:GetValue("FRVMASTER","FRV_BANCO")
Local cDescontada	:= oModel:GetValue("FRVMASTER","FRV_DESCON")
Local nPercDesc		:= oModel:GetValue("FRVMASTER","FRV_PERCEN")
Local cNatureza		:= oModel:GetValue("FRVMASTER","FRV_NATIOF")
Local lBlq			:= oModel:GetValue('FRVMASTER','FRV_BLQMOV') == '1'
Local cPIX          := ""
Local lCpoPix       := FRV->(FieldPos("FRV_PIX")) > 0
Local cAliasFRV	    := ""
Local cQuery        := ""

//Valida se descri��o foi preenchida
If Empty(cDescricao)
    Help( " ", 1, "F022DESCR",,STR0013, 1, 0 ) 	//"Por favor, preencha o campo < Descri��o >."
    lRet := .F.
Endif

//Situa��o de cobranca nao relacionada a banco (carteira)
If cBanco == '2'
    If cDescontada == '1' .or. nPercDesc > 0 .or. !Empty(cNatureza)
        Help( " ", 1, "F022BANCO",,STR0014, 1, 0 ) 	//"Apenas situa��es de cobran�a relacionadas a banco poder�o ter desconto, percentual de desconto e natureza para IOF."
        lRet := .F.
    Endif
ElseIf cDescontada == '2' .and. (nPercDesc > 0 .or. !Empty(cNatureza))
    Help( " ", 1, "F022DESC",,STR0015, 1, 0 ) 	//"Apenas situa��es de cobran�a com desconto poder�o ter percentual de desconto e natureza para IOF."
    lRet := .F.
EndIf

If lBlq .AND. oModel:GetModel('FW2DETAIL'):IsEmpty()
    Help( " ", 1, "F022DESC",,STR0021, 1, 0 )
    lRet := .F.
EndIf

//Valida se ja existe situa��o de cobran�a com PIX = Sim
If lCpoPix
    cPIX    := oModel:GetValue("FRVMASTER","FRV_PIX")
    IF cPIX == "1"
        If cBanco <> "1"
	        Help( " ", 1, "F022BCOPIX",,STR0023, 1, 0 ) //"Apenas situa��es de cobran�as relacionadas a banco poder�o utilizar PIX"
            lRet := .F.
        EndIf

	    If lRet
            cAliasFRV	:= GetNextAlias()
            cQuery := "SELECT FRV.FRV_PIX FROM "
            cQuery += RetSqlName("FRV") + " FRV"
            cQuery += " WHERE"
            cQuery += " FRV.FRV_FILIAL = '"	+ XFilial("FRV") + "' AND"
            cQuery += " FRV.FRV_PIX = '1' AND"
            cQuery += " FRV.D_E_L_E_T_ = ' '"

            cQuery := ChangeQuery(cQuery)

            DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasFRV,.F.,.T.)

            If !(cAliasFRV)->(Eof())
                Help( " ", 1, "F022PIX",,STR0022, 1, 0 ) // "J� existe uma Situa��o de Cobran�a que utiliza PIX"
                lRet := .F.
            EndIf
            (cAliasFRV)->(dbCloseArea())
        EndIf
    EndIf
EndIf


Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} Fa022CanDel
Realiza a valida��o de permiss�o de exclus�o de uma determinada
situa��o de cobran�a criada pelo usu�rio
N�o se aplica as situa��es padr�o do sistema (0|1|2|3|4|5|6|7|8|9|F|G|H|I|J)

@author pequim

@since 26/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function Fa022CanDel(cCodigo)
Local aArea		:= GetArea()
Local lRet		:= .F.
Local cQuery	:= ""
Local cAliasTMP	:= GetNextAlias()

DEFAULT cCodigo	:= ""

If !Empty(cCodigo)

    cQuery    += " SELECT                                    " + CRLF
    cQuery    += "     E1_SITUACA                            " + CRLF
    cQuery    += " FROM "+RetSQLName("SE1")+" SE1            " + CRLF
    cQuery    += " WHERE                                     " + CRLF
    cQuery    += "     E1_FILIAL  = '"+xFilial("SE1")+"' AND " + CRLF
    cQuery    += "     E1_SITUACA = '"+cCodigo+"'        AND " + CRLF
    cQuery    += "     D_E_L_E_T_ = ' '                      " + CRLF

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)

    dbSelectArea(cAliasTmp)
    If !(cAliasTMP)->(Eof())
        lRet := .T.
    EndIf
    (cAliasTmp)->(dbCloseArea())

Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa022When
When do campo FRV_PERCEN

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fa022When()
Local lRet 		:= .T.
Local oModel		:= FWModelActive()
Local cBanco 		:= oModel:GetValue("FRVMASTER","FRV_BANCO")
Local cDescontada	:= oModel:GetValue("FRVMASTER","FRV_DESCON")
Local nOperation 	:= oModel:GetOperation()
Local cField		:= ReadVar()
Local cCartPad      := "0|1|2|3|4|5|6|7|F|G|H|I|J"

If At("->",cField)>0
    cField := SubStr(cField,At("->",cField)+2,len(cField))
EndIf

//Altera��o em situacao de cobranca padrao do sistema
//Apenas permite alterar descri��o, taxa de desconto e natureza
If nOperation == MODEL_OPERATION_UPDATE

    If cField $ "FRV_DESCRI|FRV_PERCEN|FRV_NATIOF"
        If cDescontada == '1'
            lRet := (cField $ "FRV_DESCRI|FRV_PERCEN|FRV_NATIOF")
        Else
            lRet := (cField == "FRV_DESCRI")
        Endif
    Else
        If cField == "FRV_DESCON" .and. cBanco == "2"
            lRet := .F.
        ElseIf cField $ "FRV_BANCO|FRV_DESCON|FRV_PROTES" .and. !Fa022CanDel(FRV->FRV_CODIGO) .And. !(Alltrim(FRV->FRV_CODIGO) $ cCartPad)
                lRet := .T.
        Else
            lRet := .F.
        EndIf
    Endif
Else
    //When do campo FRV_DESCONT
    If cField == "FRV_DESCON" .and. cBanco == '2'
        lRet := .F.
    Endif

    //When do campo FRV_PERCEN
    //When do campo FRV_NATIOF
    If cField $ "FRV_PERCEN|FRV_NATIOF" .and. (cBanco == '2' .or. cDescontada == '2')
        lRet := .F.
    Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN022SITCB
Fun��o para retornar as informa��es do cadastro de situacao de cotran�a

@param cSitCob - C�digo da situa��o de cobran�a
@return aRet	 - Array contendo as seguintes informa��es
                    [1] - Se cobran�a em Carteira (L�gico)
                    [2] - Se cobran�a em Banco (L�gico)
                    [3] - Se cobran�a Descontada (L�gico)
                    [4] - Se cobran�a Protesto (L�gico)
                    [5] - Se cobran�a criada por usuario (L�gico)
                    [6] - Se cobran�a Simples (L�gico)
                    [7] - Percentual de desconto (Num�rico)
                    [8] - C�digo da Natureza para IOF (Caracter)
                    [9] - Descricao da situacao de cobranca (Caracter)

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN022SITCB(cSitCob)
Local aArea		:= GetArea()
Local lBanco	:= .F.
Local lDesconto	:= .F.
Local lProtesto	:= .F.
Local lSimples	:= .F.
Local nPercDesc	:= 0
Local cNaturIOF	:= ""
Local lSitUser	:= .F.
Local lSitPDD	:= .F.
Local lSitPix   := .F.
Local lCarteira := .T.
Local cDescricao:=""


If __cSitCob != cSitCob

    __cSitCob	:= cSitCob

    dbSelectArea("FRV")
    dbSetOrder(1)
    If MsSeek(xFilial("FRV")+cSitCob)
        lCarteira	:= (FRV->FRV_BANCO  != '1')				//Situacao de cobranca n�o usa banco
        lBanco		:= (FRV->FRV_BANCO  == '1')				//Situacao de cobranca usa banco
        lDesconto	:= (FRV->FRV_DESCON == '1')				//Situacao de cobranca descontada
        lProtesto	:= (FRV->FRV_PROTES == '1')				//Situacao de cobranca protesto
        lSimples	:= ((FRV->FRV_BANCO  == '1') .and. ;	//Situacao de cobranca Simples
                        (FRV->FRV_DESCON == '2') .and. ;
                        (FRV->FRV_PROTES == '2'))
        nPercDesc	:= FRV->FRV_PERCEN						//Percentual de desconto
        cNaturIOF	:= FRV->FRV_NATIOF						//Natureza do IOF
        lSitUser	:= !(Alltrim(FRV->FRV_CODIGO) $ '0|1|2|3|4|5|6|7|F|G|H|I|J')	//Situacao de cobranca criada pelo usuario
        cDescricao	:= FRV->FRV_DESCRI
        lSitPDD		:= If(FRV->(FieldPos("FRV_SITPDD"))>0 ,FRV->FRV_SITPDD == '1',.F.)
        lSitPix     := If(FRV->(FieldPos("FRV_PIX"))>0 ,FRV->FRV_PIX == '1',.F.)
    Endif					   										

    //Caso nao encontre a situacao de cobranca no cadastro, trata como uma situacao de carteira
    __aRet := {lCarteira, lBanco, lDesconto, lProtesto, lSitUser, lSimples, nPercDesc, cNaturIOF,cDescricao,lSitPDD,lSitPix }

Endif

RestArea(aArea)

Return __aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FN022LSTCB
Fun��o para retornar as informa��es do cadastro de situacao de cotran�a

@param nOpcao - Op��o para retorno de lista dos c�digos da situa��o de cobran�a
                    0 - Limpa a lidata (utilizar no final da rotina)
                    1 - Lista das cobran�as em carteira
                    2 - Lista das cobran�as descontadas
                    3 - Lista das cobran�as em banco
                    4 - Lista das cobran�as protesto

@param cProcesso - Verificar quais situa��es de cobran�a est�o bloqueadas para determinado processo
                    e n�o inclui-las na lista retornada

@return cLista	 - Lista conendo os c�digos dd cobran�a da op��o solicitada (separados por '|')

@author pequim

@since 26/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function FN022LSTCB(nOpcao,cProcesso)
Local aArea := GetArea()
Local cSitBlqPrc := ""

Default nOpcao := 9
Default cProcesso := ""

If FWIsInCallStack("FINA740") //Se vier da rotina Fun��es de Contas a Receber, limpo as Statics antes de processa-las novamente
    __cLstDesc	:= ""
    __cLstBco	:= ""
    __cLstCart	:= ""
    __cLstProt	:= ""
    __cLstAll	:= ""
    __cLstBcoNoDesc	:= ""
    __cLstNoBlqd := ""
EndIf

If Empty(__cLstCart)

    //PCREQ-3782 - Bloqueio por situa��o de cobran�a
    If !Empty(cProcesso)
        cSitBlqPrc := F023VerBlq("2",cProcesso)
    Endif

    //Utilizado para valida��es E1_SITUACA $ " |0" - Titulo em carteira padr�o
    __cLstSit0 := Padr("0",Len(FRV->FRV_CODIGO))+"|"+ Space(Len(FRV->FRV_CODIGO))

    dbSelectArea("FRV")
    dbSetOrder(1)
    If MsSeek(xFilial("FRV"))
        While !Eof() .AND. FRV->FRV_FILIAL == xFilial ("FRV")

            __cLstAll	+= FRV->FRV_CODIGO + '|'		//Todas os codigos de cobran�a

            If !(FRV->FRV_CODIGO $ cSitBlqPrc)

                //PCREQ-3782 - Bloqueio por situa��o de cobran�a
                __cLstNoBlqd	+= FRV->FRV_CODIGO + '|'	//Todas os codigos de cobran�a sem bloqueio

                //Se utiliza Banco
                If FRV->FRV_BANCO  == '1'
                    __cLstBco += FRV->FRV_CODIGO + '|'
                    If FRV->FRV_DESCON  == '2'
                        __cLstBcoNoDesc += FRV->FRV_CODIGO + '|'
                    Endif
                Else
                    __cLstCart += FRV->FRV_CODIGO + '|'
                Endif

                //Se cobranca descontada
                If FRV->FRV_DESCON  == '1'
                    __cLstDesc += FRV->FRV_CODIGO + '|'
                Endif

                //Se cobranca descontada
                If FRV->FRV_PROTES  == '1'
                    __cLstProt += FRV->FRV_CODIGO + '|'
                Endif

            Endif

            FRV->(dbSkip())
        EndDo
    Endif
Endif

/*
Lista de op�oes de retorno
    0 - Lista de todas as situa��es de cobran�as
    1 - Lista das cobran�as em carteira
    2 - Lista das cobran�as descontadas
    3 - Lista das cobran�as em banco
    4 - Lista das cobran�as protesto
    5 - Lista das cobran�as em banco mas sem desconto
    6 - Lista das cobran�as n�o bloqueadas para um determinado processo
    7 - Lista de cobrancas 0 (carteira) ou vazia
*/
If nOpcao == 0
    cLista := __cLstAll
ElseIf nOpcao == 1
    cLista := __cLstCart
ElseIf nOpcao == 2
    cLista := __cLstDesc
ElseIf nOpcao == 3
    cLista := __cLstBco
ElseIf nOpcao == 4
    cLista := __cLstProt
ElseIf nOpcao == 5
    cLista := __cLstBcoNoDesc
ElseIf nOpcao == 6
    cLista := __cLstNoBlqd
ElseIf nOpcao == 7
    cLista := __cLstSit0
Else
    cLista		:= ""
    __cLstDesc	:= ""
    __cLstBco	:= ""
    __cLstCart	:= ""
    __cLstProt	:= ""
    __cLstAll	:= ""
    __cLstBcoNoDesc	:= ""
    __cLstNoBlqd := ""
    __cLstSit0	:= ""
Endif

RestArea(aArea)

Return cLista

//-------------------------------------------------------------------
/*/{Protheus.doc} FW2LINPRE
Valida edi��o da Grid de processos de bloqueio

@author pequim

@since 26/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FW2LINPRE(oModelGrid,nLine,cAction,cField)
Local lRet    	:= .T.
Local oModel	:= FWModelActive()
Local cControl 	:= oModel:GetValue("FRVMASTER","FRV_BLQMOV")

If cAction != 'DELETE'

    If lRet .and. cControl != "1" //Controle de bloqueio de movimentos de CR desativado
        Help( " ", 1, "AF022FW2LIN",, STR0017+CRLF+STR0018 , 1, 0 )	//"Controle de bloqueio de movimentos n�o est� ativado para essa situa��o de cobran�a."
        lRet := .F.
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F022VldBlq
Valida edi��o da Grid de processos de bloqueio

@author William Gundim

@since 26/11/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function F022VldBlq()
Local oModel	:= FWModelActive()
Local oAux		:= oModel:GetModel('FW2DETAIL')
Local lBlq		:= oModel:GetValue('FRVMASTER','FRV_BLQMOV') == '1'
Local lRet		:= .T.
Local nX		:= 0

If !lBlq
    If !oAux:IsEmpty()
        If MsgYesNo(STR0020)
            For nX := 1 To oAux:Length()
                oAux:SetLine(nX)
                oAux:DeleteLine()
            Next nX
        Else
            lRet := .F.
        EndIf
    EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} F022SITPIX
Retorna codigos de situacao associados ao PIX
@return: Lista de codigos de situacoes tipo PIX separados por ponto e virgula (na verdade so podera existir UM)
@author Marcelo Iuspa

@since 21/10/2020
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function F022SITPIX()
    Local aSavAre      As Array
    Local cAliasTrb    As Character
    Local cSitPix      As Character
    Local cQuery       As Character
    Local lCpoPix      As Logical

    cAliasTrb  := GetNextAlias()
    cQuery :=""
    cSitPix := ""
    aSavAre   := GetArea()

    lCpoPix := FRV->(FieldPos("FRV_PIX")) > 0

    If lCpoPix
        cQuery := " SELECT FRV_CODIGO FROM " + RetSqlName("FRV") + " WHERE FRV_PIX = '1' AND " + ;
                " FRV_FILIAL = '" + xFilial("FRV") + "' AND D_E_L_E_T_ = ' ' "

        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery), cAliasTrb,.T.,.T.)

        If (cAliasTrb)->(!EOF())
            cSitPix := (cAliasTrb)->FRV_CODIGO
        EndIf

        (cAliasTrb)->(dbCloseArea())

        RestArea(aSavAre)
    EndIf
Return(cSitPix)
