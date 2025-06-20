#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA167.ch" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA167()

Esta rotina tem objetivo de realizar cadastro das moedas estaduais
como UPF, FCA, que s�o geralmente utilizados nos c�lculos dos fundos de
ICMS. Este cadastro ser� utilizado no motor de c�lculo do fiscal, por�m
pode plenamente ser aplicado para qualquer outra obriga��o acess�ria,
pois � um cadastro gen�rico

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA167()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F29") .AND. AliasIndic('F2A')
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F29")
    oBrowse:SetDescription(STR0001) // Cadastro de Refer�ncia Fiscal
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA167" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro de Unidade de Refer�ncia Fiscal

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel    := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho:= FWFormStruct(1, "F29" )

//Estrutura do grid
Local oItem     := FWFormStruct(1, "F2A" )
Local lCIN      := AliasIndic("CIN") .And. FindFunction("xFisFormul")
Local oCINStruct:= Iif(lCIN,FWFormStruct(1,"CIN"),nil) 

//Instanciando o modelo
If lCIN
    oModel	:= MPFormModel():New('FISA167',/*Pre-Validacao*/,{|oModel|F167GrvCIN(oModel) })
Else
    oModel	:= MPFormModel():New('FISA167')
EndIf

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA167",,oCabecalho)

//Adicionando o grid das varia��es do tributo
oModel:AddGrid( 'FISA167ITEM', 'FISA167', oItem)
//oModel:GetModel( 'FISA167ITEM' ):SetUseOldGrid()

//Retira a obrigatoriedade da URF do grid, pois ser� gravado automaticamente pelo MVC atrav�s da rela��o com F29
oItem:SetProperty('F2A_URF' , MODEL_FIELD_OBRIGAT,  .F. )

//Valida��o no campo F29_CODIGO
oCabecalho:SetProperty('F29_CODIGO' , MODEL_FIELD_VALID, {||( VldCodigo(oModel) )})

//N�o permite alterar a sigla do tributo
oCabecalho:SetProperty('F29_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Define para n�o repetir os campos de ano e m�s
oModel:GetModel( 'FISA167ITEM' ):SetUniqueLine( { 'F2A_MES', 'F2A_ANO' } )

//Relacionamento entre as tabelas F26 e F2B
oModel:SetRelation( 'FISA167ITEM', { { 'F2A_FILIAL', 'xFilial("F2A")' }, { 'F2A_URF', 'F29_CODIGO' } }, F2A->( IndexKey( 1 ) ) )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) // Cadastro de Refer�ncia Fiscal

If lCIN
    //Adiciono os campos da CIN no modelo
    oModel:AddFields("FISA167CIN","FISA167",oCINStruct)
    //Relacionamento entre a tabela F29 e a CIN para grava��o autom�tica do MVC
    oModel:SetRelation( 'FISA167CIN', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F29_ID'}, {'CIN_TREGRA', "'4 '"}}, CIN->( IndexKey(3)))
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA167" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F29")
Local oItem	     := FWFormStruct(2, "F2A")
Local oView      := Nil
Local cVersao 	 := GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA167'     )
oView:AddGrid(  'VIEW_ITEM'      , oItem      , 'FISA167ITEM' )

//Habilitando op��es de filtros 
oView:SetViewProperty('VIEW_ITEM', "GRIDFILTER", {.T.})
oView:SetViewProperty('VIEW_ITEM', "GRIDSEEK", {.T.})

//Retira os campos da View
oItem:RemoveField( 'F2A_URF' )

//Cria dois box, 30% e 70%
oView:CreateHorizontalBox( 'SUPERIOR'  , 20 )
oView:CreateHorizontalBox( 'INFERIOR'  , 80 )

//Faz v�nculo do box com a view
oView:SetOwnerView( 'VIEW_CABECALHO' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ITEM'      , 'INFERIOR' )

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_CABECALHO' , 'Defini��o da URF(Unidade de Refer�ncia Fiscal)' ) //'Detalhamento do Tributo'
oView:EnableTitleView('VIEW_ITEM'      , 'Valores da URF' ) //'Detalhamento das regras de c�lculo'

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

//Picture do campo c�digo
oCabecalho:SetProperty('F29_CODIGO' , MVC_VIEW_PICT, "@!")

//Remove Campos da View
If F29->(Fieldpos("F29_ID")) > 0
    oCabecalho:RemoveField("F29_ID")
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F167GrvCIN
Fun��o respons�vel por realizar a carga no conte�do dos campos
no MVC para gravar a tabela CIN

@author Renato Rezende
@since 06/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function F167GrvCIN(oModel)

Local nOperation    := oModel:GetOperation()
Local cCodigo       := oModel:GetValue ('FISA167',"F29_CODIGO")
Local cDescri       := oModel:GetValue ('FISA167',"F29_DESC")
Local cIdRegra      := oModel:GetValue ('FISA167',"F29_ID")
Local cPrefixo      := xFisTpForm("4") //URF
Local oFSA167CIN    := oModel:GetModel("FISA167CIN")
    
If nOperation == MODEL_OPERATION_INSERT

    //Inclui o valor no Model para grava��o dos dados na CIN
    oFSA167CIN:SetValue('CIN_FILIAL',   xFilial("CIN")   )
    oFSA167CIN:SetValue('CIN_CODIGO',   cPrefixo+cCodigo )
    oFSA167CIN:SetValue('CIN_DESCR' ,   cDescri          )
    oFSA167CIN:SetValue('CIN_TREGRA',   "4 "              )
    oFSA167CIN:SetValue('CIN_REGRA' ,   cCodigo          )
    oFSA167CIN:SetValue('CIN_IREGRA',   cIdRegra         )
    oFSA167CIN:SetValue('CIN_FORMUL',   cCodigo          )
    oFSA167CIN:SetValue('CIN_FNPI'  ,   cCodigo          )
    oFSA167CIN:SetValue('CIN_ALTERA',   "0"              )

ElseIf nOperation == MODEL_OPERATION_UPDATE

    //Inclui o valor no Model para altera��o da descri��o da CIN
    oFSA167CIN:SetValue('CIN_DESCR' ,   cDescri           )
EndIF

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} VldCodigo
Fun��o que realiza a valida�� do c�digo da URF.

@author erick.dias
@since 10/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCodigo(oModel)

Local cCodigo     := oModel:GetValue ('FISA167', "F29_CODIGO")
Local lRet          := .T.

//Verifica se campo j� est� cadastrado
If F29->( MsSeek ( xFilial('F29') + cCodigo  ) )
    Help( ,, 'Help',, "C�digo de URF j� cadastrado!", 1, 0 ) 
    return .F.    
EndIF

//N�o pode digitar operadores e () no c�digo
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, "C�digo n�o pode conter os caracteres '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, "C�digo n�o pode conter espa�o.", 1, 0 ) 
    Return .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA167F29
Fun��o executada quando usu�rio entrada na rotina FISA170
Esta rotina faz carga na tabela CIN conforme as regras definidas 
Esta rotina deve ser executada epenas quando existir regras cadastradas antes da existencia de formulas

@author Rafael S Oliveira
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA167F29()
Local oModel    := nil
Local cAlias    := GetNextAlias()
Local cCodigo   := ""
Local cDescri   := ""
Local cIdRegra  := ""
Local cFormula  := ""
Local cPrefixo  := xFisTpForm("4") //URF

//Atualiza novo campo F29_ID
AtualizaID()


//Realiza pesquisa pela rela��o da F29 com CIN
cAlias := PesqCIN("F29")

DbSelectArea(cAlias)

If ((cAlias)->(Eof()))
    (cAlias)->(dbCloseArea())
    return
Endif

//Model da rotina FISA167
oModel    := FWLoadModel('FISA167')

DbSelectArea("F29")
F29->(DbSetOrder(2)) // F29_FILIAL+F29_ID

While (!(cAlias)->(Eof()))
    lRet      := .F.

    If F29->(MsSeek(xFilial("F29") + (cAlias)->F29_ID))
        
        oModel:Activate()
        cCodigo   := oModel:GetValue ('FISA167',"F29_CODIGO")
        cDescri   := oModel:GetValue ('FISA167',"F29_DESC")
        cIdRegra  := oModel:GetValue ('FISA167',"F29_ID")

        //Atualiza CIN
        cFormula   := cCodigo
        GravaCIN("1","4", cCodigo, cIdRegra, cDescri, cPrefixo + cFormula)
        
        
        oModel:DeActivate()
    Endif
    (cAlias)->(dbSkip())
End

oModel:Destroy()
F29->(DbCloseArea())
(cAlias)->(dbCloseArea())

Return


/*/{Protheus.doc} AtualizaID
    (Atualiza novo campo F29_ID)

@author Rafael S Oliveira
@since 10/02/2021
@version P12.1.30

    /*/
Static Function AtualizaID()
Local cAliasF29 := GetNextAlias()

BeginSql Alias cAliasF29

    SELECT
        F29.R_E_C_N_O_ As RECNOF29
    FROM
        %Table:F29% F29
    WHERE 
        F29.F29_ID = ""
        AND F29.%NOTDEL%
EndSql


While !(cAliasF29)->(Eof())
    F29->(DbGoTo((cAliasF29)->RECNOF29)) // Se possiciona NO REGISTRO

    RecLock("F29",.F.)
        F29->F29_ID := FWUUID("F29")
    F29->(MsUnlock())
    
    (cAliasF29)->(DbSkip())
Enddo

//Fecha query
If Select(cAliasF29) > 0
    DbSelectArea(cAliasF29)
    DbCloseArea()
EndIf

Return