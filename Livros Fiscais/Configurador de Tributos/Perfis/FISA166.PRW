#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA166.ch" 

Static lF24Tipo := F24->(Fieldpos("F24_TIPOPF")) > 0
Static lF25Tipo  := F25->(Fieldpos("F25_TIPOPF")) > 0
Static lAutomato := IsBlind()
Static oJSPROD 
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA166()

Cadastro de perfil tribut�rio de produto.
Esta rotina far� cadastro de perfis de produto, que ser�o utilizadas no
motor de c�lculo tribut�rio fiscal.

Teremos neste perfil o relacionamento dos c�digos de produtos bem como
as origens que compoem este perfil

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Erick G. Dias
@since 19/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA166()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F20") .AND. AliasIndic("F24") .AND. AliasIndic("F25")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F20")
    oBrowse:SetDescription(STR0002) // Cadastro de Perfil Tribut�rio de Produto
    oBrowse:SetFilterDefault("F20_FILIAL == " + ValToSql(xFilial("F20")) + " .And. " + "F20_TIPO == '04'")
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0001,1,0) // Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FISA166' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.FISA166' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.FISA166' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.FISA166' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.FISA166' OPERATION 9 ACCESS 0 //'Copiar'

If FindFunction("FSA171WIZ")
    ADD OPTION aRotina TITLE 'Facilitador'  ACTION 'FSA171WIZ("1","04")' OPERATION 4 ACCESS 0 //'Facilitador'
EndIF

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai correspondete a tabela de perfil F20
Local oCabecalho := FWFormStruct(1, "F20" )

//Estrutura do produto considerando a tabela F24
Local oProduto := FWFormStruct(1, "F24" )

//Estrutura da origem considerando a tabela F25
Local oOrigem := FWFormStruct(1, "F25" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA166',{|oModel| CARGAORIGEM(oModel)})

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA166",,oCabecalho)

//Adicionando o grid de produto
oModel:AddGrid( 'FISA166PRODUTO', 'FISA166', oProduto,,,,{|oProduto| ValidDel(oProduto)})
//oModel:GetModel( 'FISA166PRODUTO' ):SetUseOldGrid()

//Adicionando o grid das origens de produto
oModel:AddGrid('FISA166ORIGEM','FISA166',oOrigem) 
//oModel:GetModel('FISA166ORIGEM'):SetUseOldGrid()

//Inicializa o campo F20_TIPO com �conte�do "04" que significa tipo de perfil de produto
oCabecalho:SetProperty('F20_TIPO' , MODEL_FIELD_INIT ,{||"04"} )
//Inicializa o campo F25_TIPO com �conte�do "04" que significa tipo de perfil de produto
IF lF25Tipo
    oOrigem:SetProperty('F25_TIPOPF' , MODEL_FIELD_INIT ,{||"04"} )
Endif
IF lF24Tipo
    oProduto:SetProperty('F24_TIPOPF' , MODEL_FIELD_INIT ,{||"04"} )
Endif


//Retira obrigatoriedade dos campos F24_CODIGO e F25_CODIGO
oProduto:SetProperty('F24_CODIGO' , MODEL_FIELD_OBRIGAT,  .F. )
oOrigem:SetProperty('F25_CODIGO'  , MODEL_FIELD_OBRIGAT,  .F. )

//N�o permite alterar o conte�do do campo F20_CODIGO na edi��o
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Valida��o para n�o permitir informar c�digo de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F20_CODIGO' , MODEL_FIELD_VALID, {||( VldPerfil(oModel, 'FISA166', '04') )})

//Define para n�o repetir o c�digo de produto
oModel:GetModel( 'FISA166PRODUTO' ):SetUniqueLine( { 'F24_CDPROD' } )

//Define o valor maximo de linhas do grid
oModel:GetModel('FISA166PRODUTO'):SetMaxLine(9999999)

//N�o permite repetir a origem
oModel:GetModel('FISA166ORIGEM'):SetUniqueLine({'F25_ORIGEM'})

//Relacionamento entre as tabelas F20 Perfil com F24 Produto
oModel:SetRelation( 'FISA166PRODUTO', { { 'F24_FILIAL', 'xFilial("F24")' }, { 'F24_CODIGO', 'F20_CODIGO' }, {'04','F20_TIPO'} }, F24->( IndexKey( 1 ) ) )

//Relacionamento entre as tabelas F20 Perfil com F25 origens
oModel:SetRelation( 'FISA166ORIGEM', { { 'F25_FILIAL', 'xFilial("F25")' }, { 'F25_CODIGO', 'F20_CODIGO' }, {'04','F20_TIPO'} }, F25->( IndexKey( 1 ) ) )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0002) // Cadastro de Perfil Tribut�rio de Produto

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA166" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F20")
Local oProduto	:= FWFormStruct(2, "F24")
Local oOrigem	:= FWFormStruct(2, "F25")

Local oView := Nil
Local cVersao 	:= GetVersao(.F.)


oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho  , 'FISA166'         )
oView:AddGrid(  'VIEW_PRODUTO'   , oProduto    , 'FISA166PRODUTO'  )
oView:AddGrid(  'VIEW_ORIGEM'    , oOrigem     , 'FISA166ORIGEM'   )

//Habilitando op��es de filtros 
oView:SetViewProperty('VIEW_PRODUTO', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_PRODUTO', "GRIDSEEK", {.T.})
oView:SetViewProperty('VIEW_ORIGEM', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_ORIGEM', "GRIDSEEK", {.T.})

//Retira os campos da View
oCabecalho:RemoveField( 'F20_TIPO' )
oProduto:RemoveField( 'F24_CODIGO' )
oOrigem:RemoveField( 'F25_CODIGO'  )
IF lF25Tipo
    oOrigem:RemoveField( 'F25_TIPOPF')
Endif
IF lF24Tipo
    oProduto:RemoveField( 'F24_TIPOPF')
Endif

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'MEDIO'     , 40 )
oView:CreateHorizontalBox( 'INFERIOR'  , 40 )

//O formul�rio da interface ser� colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO'   , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_PRODUTO'     , 'MEDIO'    )
oView:SetOwnerView( 'VIEW_ORIGEM'      , 'INFERIOR' )

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_CABECALHO' , STR0002 )
oView:EnableTitleView('VIEW_PRODUTO' , STR0003 ) 
oView:EnableTitleView('VIEW_ORIGEM' , STR0004 ) 

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

//Picture do campo c�digo
oCabecalho:SetProperty('F20_CODIGO' , MVC_VIEW_PICT, "@!")

//Adiciona bot�o do Facilitador
If FindFunction("FSA171WIZ") 
    oView:AddUserButton( 'Facilitador','', {|oView| FSA171WIZ("2","04")} )
EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerfil
Fun��o que valida se o c�digo de perfil cadastrado j� existe

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function VldPerfil(oModel, cModelName, cTpPerfil)

Local cPerfil 	:= oModel:GetValue (cModelName,"F20_CODIGO")
Local lRet      := .T.

//Verifico se o perfil j� existe.
If F20->( MsSeek ( xFilial('F20') + cPerfil + cTpPerfil ) )
    lRet    := .F.    
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaOrigem
Fun��o que faz a carga autom�tica das origens de produto no grid.
O objetivo � facilitar o cadastro do usu�rio, sugerindo todas as origens,
cabendo ele somente excluir as origens que n�o pertinentes ao perfil.

@author Erick G Dias
@since 05/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CargaOrigem(oModel)

Local oOrigen		:= oModel:GetModel("FISA166ORIGEM")
Local lFirst        := .T.
Local aDadosSX5     := FWGetSX5( "S0" )
Local nX            := 0

//A carga ser� realizada somente no momento da inclus�o do perfil
If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. oOrigen:Length() == 1
    //Posiciono na tabela SX5 para buscar as informa��es da origem do produto
    For nX := 1 to Len(aDadosSX5)
        //Adiciono uma linha para cada ocorr�ncia de origem na SX5
        IF !lFirst
            //N�o devo criar AddLine() na primeira linha, se fizer teremos a primeira linha vazia.
            oOrigen:AddLine()            
        EndIF
        oOrigen:LoadValue("F25_ORIGEM" , Alltrim(aDadosSX5[nX][3]))
        oOrigen:LoadValue("F25_DSORIG" , Alltrim(aDadosSX5[nX][4]))
        IF lF25Tipo
            oOrigen:LoadValue("F25_TIPOPF" ,'04')
        Endif
        lFirst  := .F.        
    Next       
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA166GF24

Fun��o para grava��o/exclus�o da F24 chamada de "fora" da rotina
de cadastro

@author joao.pellegrini
@since 13/09/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA166GF24(cCodPerfil, cOper, cCodProd)

Local oModel := NIL
Local oProd := NIL
Local lRet := .F.

oModel := FWLoadModel("FISA166")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

DbSelectArea("F20")
F20->(DbSetOrder(1))

If F20->(DbSeek(xFilial("F20") + cCodPerfil + "04"))

    oModel:Activate()

    oProd := oModel:GetModel("FISA166PRODUTO")

    If cOper == "INCLUI"

        oProd:AddLine()
        oProd:SetValue("F24_CDPROD",cCodProd)
        IF lF24Tipo
            oProd:LoadValue("F24_TIPOPF" ,'04')
        Endif

    ElseIf cOper == "EXCLUI"

         If oProd:SeekLine( { {"F24_CDPROD", cCodProd } } )
            oProd:DeleteLine()
        EndIf

    EndIf

    If oModel:VldData()
        lRet := oModel:CommitData()        
    Else
        aErros := oModel:GetErrorMessage()
    EndIf

EndIf

oModel:Deactivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA166DPRD
Fun��o auxiliar para tratar o inicializador padr�o da descri��o do 
do Produto, pois o campo X3_RELACAO � limitado e n�o cabia 
toda a instru��o necess�ria.

@author Erich Buttner
@since 01/02/2019
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA166DPRD()

Local cDescr    := ""
Local cCodPro := Upper(F24->F24_CDPROD) 
Local lJson     := .F.

If oJSPROD == Nil
    lJson := ProduJs()
EndIf

If lJson
    If AllTrim(cCodPro) == "TODOS"
        cDescr  := "TODOS OS PRODUTOS"
    ElseIf  oJSPROD[RTrim(xFilial("SB1"))] <> Nil
        cDescr  := oJSPROD[RTrim(xFilial("SB1"))][1][cCodPro]
        If Empty(cDescr)
        cDescr  := POSICIONE("SB1",1,xFilial("SB1")+AllTrim(cCodPro),"B1_DESC")
        EndIf
    EndIf
EndIf

Return cDescr

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA166X3

Fun��o para ajustar o valid do campo de codigo de produto

@author erich buttner
@since 01/02/2019
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA166X3()

Local aDados := {}

aAdd( aDados, { { 'F24_CDPROD' 	}, { { 'X3_VALID'	, 'Vazio() .Or. ExistCpo("SB1") .Or. Upper(Alltrim(FwFldGet("F24_CDPROD"))) == "TODOS"' } } } )
aAdd( aDados, { { 'F24_DSPROD' 	}, { { 'X3_RELACAO'	, 'Iif(FindFunction("FSA166DPRD"), FSA166DPRD(),"")' } } } )

Return


/*/{Protheus.doc} AtuTpPF04
    (Atualiza novos campos F25_TIPOPF e F24_TIPOPF)

@author Rafael S Oliveira
@since 01/03/2021
@version P12.1.30

    /*/
Function AtuTpPF04()

IF lF24Tipo
    cQuery := "UPDATE " +  RetSqlName('F24') + " SET F24_TIPOPF = '04' WHERE F24_FILIAL = " + ValToSql(xFilial('F24')) + " AND F24_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif
IF lF25Tipo
    cQuery := "UPDATE " +  RetSqlName('F25') + " SET F25_TIPOPF = '04' WHERE F25_FILIAL = " + ValToSql(xFilial('F25')) + " AND F25_TIPOPF = ' '
    TcSqlExec(cQuery)
Endif

Return

/*/{Protheus.doc} VldTodos
    Valida a inclus�o do tipo TODOS

@author Yuri Gimenes
@since 08/04/2022
@version P12.1.33

    /*/
static Function ValidDel(oObjeto)

Local lRet      := .T.
Local lProdTd    := .F.
Local lProdAv    := .F.
Local nY
Local oModelGrid := oObjeto

/*
nOpcao == 1 -> Tipo de Opera��o
nOpcao == 2 -> C�digo de Servi�o
*/
oModelPad   := FwModelActive()

For nY := 1 to oModelGrid:Length()

    oModelGrid:GoLine(nY)

    iF !oModelGrid:IsDeleted()

        cCdProd := AllTrim(oModelGrid:GetValue ("F24_CDPROD"))

        lProdTd := iif(lProdTd==.F.,iif(AllTrim(cCdProd)=="TODOS",.t.,.f.),.T.)
        lProdAv := iif(lProdAv==.F.,iif(AllTrim(cCdProd)<>"TODOS",.t.,.f.),.T.)

        If lProdTd .and. lProdAv
            exit
        ENDIF

    EndIf

Next nY

nY := 0

If lProdTd .and. lProdAv

    If lAutomato .or. MsgYesNo( STR0005 + chr(13)+chr(10) +;    //"Existem Produtos configurados como 'TODOS' no Grid."
                                STR0006 + chr(13)+chr(10) +;    //"Os tipos de Produto diferente de TODOS ser�o exclu�dos"
                                STR0007, STR0002)               //"Deseja continuar?"

        For nY := 1 to oModelGrid:Length()

        oModelGrid:GoLine(nY)

            iF !oModelGrid:IsDeleted()

                cCdProd := AllTrim(oModelGrid:GetValue ("F24_CDPROD"))

                if(!("TODOS" $ cCdProd) .and. lProdTd)
                    oModelGrid:DeleteLine()
                EndIf
            EndIF

        Next nY
    else

        lRet := .F.
        oModelPad:SetErrorMessage(,,,,,STR0008,STR0009)

    EndIf

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProduJs

Cria um JSON com todos produtos dos perfis para melhorar a performance ao visualizar, 
alterar e excluir no perfil de produtos

@author Julia Mota
@since 05/09/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ProduJs()
Local cAlias	:= GetNextAlias()
Local cQuery	:= " "
Local cChave := " "
Local oPSAtiv 
Local cFilBkp := ""
Local lRet    := .F. 

	cQuery := " SELECT  SB1.B1_FILIAL FILIAL,SB1.B1_COD CODIGO,SB1.B1_DESC DESCR
	cQuery += " FROM "+RETSQLNAME("SB1")+" SB1"
    cQuery += " WHERE SB1.D_E_L_E_T_ = '' ORDER BY 1 ASC""

	cQuery 	:= ChangeQuery(cQuery)
	oPSAtiv := FWPreparedStatement():New(cQuery)

	cQuery	:= oPSAtiv:GetFixQuery()
	cAlias:= MPSysOpenQuery(cQuery)	
	
	DbSelectArea (cAlias)
	
    oJSPROD:=JsonObject():new()
    oJSDetalhe:=JsonObject():new()
	
 	While (cAlias)->(!Eof())
        
        cChave := (cAlias)->CODIGO
        
        if !(Empty(cFilBkp)) .AND. !(cFilBkp==(cAlias)->FILIAL)
            Aadd(oJSPROD[AllTrim(cFilBkp)], oJSDetalhe)
            FREEOBJ(oJSDetalhe)
            oJSDetalhe:=JsonObject():new()
        ENDIF

        if  !(cFilBkp==(cAlias)->FILIAL)
            cFilBkp := (cAlias)->FILIAL
            oJSPROD[AllTrim(cFilBkp)]:={}
        ENDIF
        oJSDetalhe[cChave]:=(cAlias)->DESCR

		(cAlias)->(DbSkip())					
	EndDo	
    If oJSPROD:toJSON() <> "{}" .AND. oJSDetalhe:toJSON() <> "{}"
        Aadd(oJSPROD[RTrim(cFilBkp)], oJSDetalhe)
        lRet := .T.
    EndIf
    FREEOBJ(oJSDetalhe)
	(cAlias)->(dbCloseArea()) //Fecha tabela temporaria

Return lRet
