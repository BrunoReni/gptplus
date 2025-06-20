#Include "FISA160B.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160B()

Esta rotina tem objetivo de realizar cadastro de regras para enquadramento 
pela NCM para calculo de IVA, Pauta, Majora��o.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Renato Rezende
@since 15/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160B()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CIS") .AND. AliasIndic('CIT') .AND. AliasIndic('CIU')
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CIS")
    oBrowse:SetDescription(STR0001) //"Cadastro Regras de Enquadramento por NCM"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0020,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Renato Rezende
@since 15/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA160B" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro de Unidade de Refer�ncia Fiscal

@author Renato Rezende
@since 15/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel    := Nil

//Estrutura Pai do cabe�alho da rotina
Local oNcm      := FWFormStruct(1, "CIS" )

//Estrutura do grid
Local oTributo  := FWFormStruct(1, "CIT" )

Local lCIUCEST   := CIU->(FieldPos("CIU_CEST")) > 0
Local oStCfMVA   := Nil
Local oStCfPaut  := Nil
Local oStCfMajr  := Nil
Local cCmpFolder := ''
Local bLinMva   := {||PosVldCIU("MVA", lCIUCEST)}//Valida��o da linha do grid
Local bLinPauta := {||PosVldCIU("PAUTA", lCIUCEST)}//Valida��o da linha do grid
Local bLinMaj   := {||PosVldCIU("MAJ", lCIUCEST)}//Valida��o da linha do grid

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA160B',,{|oModel|VldPosModel(oModel)})

//Campos para a Aba de MVA:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_MARGEM,CIU_MVAAUX,CIU_ID,CIU_IDNCM,CIU_TIPO,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMVA	:=	FwFormStruct( 1, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Pauta:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_UM,CIU_VIGINI,CIU_VIGFIM,CIU_VLPAUT,CIU_ID,CIU_IDNCM,CIU_TIPO,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfPaut	:=	FwFormStruct( 1, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Majora��o:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_VIGINI,CIU_VIGFIM,CIU_MAJORA,CIU_MJAUX,CIU_ID,CIU_IDNCM,CIU_TIPO,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMajr	:=	FwFormStruct( 1, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA160B",,oNcm)

//Adicionando o grid das varia��es do tributo
oModel:AddGrid( 'FISA160BTRIB'      , 'FISA160B'        , oTributo  )
oModel:AddGrid( 'FISA160BCFGMVA'	, 'FISA160BTRIB'	, oStCfMVA, , bLinMva)
oModel:AddGrid( 'FISA160BCFGPAUTA'	, 'FISA160BTRIB'    , oStCfPaut, , bLinPauta)
oModel:AddGrid( 'FISA160BCFGMAJOR'	, 'FISA160BTRIB'	, oStCfMajr, , bLinMaj)

//Deixando as abas opicionais o preenchimento
oModel:GetModel( 'FISA160BTRIB'   ):SetOptional( .T. )
oModel:GetModel( 'FISA160BCFGMVA'   ):SetOptional( .T. )
oModel:GetModel( 'FISA160BCFGPAUTA' ):SetOptional( .T. )
oModel:GetModel( 'FISA160BCFGMAJOR' ):SetOptional( .T. )

oTributo:SetProperty('CIT_TIPO'     ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("1")} )
oStCfMVA:SetProperty('CIU_TIPO'     ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("1")} )
oStCfPaut:SetProperty('CIU_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("2")} )
oStCfMajr:SetProperty('CIU_TIPO'    ,     MODEL_FIELD_INIT    ,{||FSA160TIPO("3")} )

//N�o permite alterar a sigla do tributo
oNcm:SetProperty('CIS_CODNCM' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oNcm:SetProperty('CIS_CODNCM' , MODEL_FIELD_VALID,{||( VldCod(oModel) )})

//Define para n�o repetir os campos de ano e m�s
oModel:GetModel( 'FISA160BTRIB' ):SetUniqueLine( { 'CIT_TRIB' } )

oTributo:SetProperty('CIT_IDNCM'    , MODEL_FIELD_OBRIGAT,  .F. )

oStCfMVA:SetProperty( 'CIU_IDNCM'   , MODEL_FIELD_OBRIGAT,  .F. ) 
oStCfPaut:SetProperty('CIU_IDNCM'   , MODEL_FIELD_OBRIGAT,  .F. ) 
oStCfMajr:SetProperty('CIU_IDNCM'   , MODEL_FIELD_OBRIGAT,  .F. ) 

oStCfMVA:SetProperty("CIU_ITEM"     , MODEL_FIELD_OBRIGAT,  .T. )
oStCfPaut:SetProperty("CIU_ITEM"	, MODEL_FIELD_OBRIGAT,  .T. )
oStCfMajr:SetProperty("CIU_ITEM"	, MODEL_FIELD_OBRIGAT,  .T. )

oNcm:SetProperty('CIS_CODNCM'   , MODEL_FIELD_KEY,  .T. ) 

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) //"Cadastro Regras de Enquadramento por NCM"

oModel:SetPrimaryKey({""})

oModel:SetRelation( 'FISA160BTRIB'      , { { 'CIT_FILIAL', 'xFilial( "CIT" )' }, { 'CIT_IDNCM', 'CIS_ID'}, { 'CIT_TIPO',"'1'" } }      , CIT->( IndexKey( 2 ) ) )
oModel:SetRelation( 'FISA160BCFGMVA'    , { { 'CIU_FILIAL', 'xFilial( "CIU" )' }, { 'CIU_TIPO', "'1'" }   , { 'CIU_IDNCM', 'CIT_ID' }   , { 'CIU_TRIB', 'CIT_TRIB' } }, 'CIU_FILIAL+CIU_ITEM+CIU_TRIB+CIU_NCM' )
oModel:SetRelation( 'FISA160BCFGPAUTA'  , { { 'CIU_FILIAL', 'xFilial( "CIU" )' }, { 'CIU_TIPO', "'2'" }   , { 'CIU_IDNCM', 'CIT_ID' }   , { 'CIU_TRIB', 'CIT_TRIB' } }, 'CIU_FILIAL+CIU_ITEM+CIU_TRIB+CIU_NCM' )
oModel:SetRelation( 'FISA160BCFGMAJOR'  , { { 'CIU_FILIAL', 'xFilial( "CIU" )' }, { 'CIU_TIPO', "'3'" }   , { 'CIU_IDNCM', 'CIT_ID' }   , { 'CIU_TRIB', 'CIT_TRIB' } }, 'CIU_FILIAL+CIU_ITEM+CIU_TRIB+CIU_NCM' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Renato Rezende
@since 15/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA160B" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oNcm      := FWFormStruct(2, "CIS")
Local oTributo  := FWFormStruct(2, "CIT")
Local oStCfMVA   := Nil
Local oStCfPaut  := Nil
Local oStCfMajr  := Nil
Local oView      := Nil
Local cCmpFolder := ''
Local lCIUCEST   := CIU->(FieldPos("CIU_CEST")) > 0

oView := FWFormView():New()
oView:SetModel( oModel )

//Ajustando os campos que ser�o mostrados por abas
//Campos para a Aba de IVA:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_ORIGEM,CIU_VIGINI,CIU_VIGFIM,CIU_MARGEM,CIU_MVAAUX,CIU_ID,CIU_TIPO,CIU_IDNCM,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMVA	:=	FwFormStruct( 2, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Pauta:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_UM,CIU_VIGINI,CIU_VIGFIM,CIU_VLPAUT,CIU_ID,CIU_TIPO,CIU_IDNCM,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfPaut	:=	FwFormStruct( 2, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Campos para a Aba de Majora��o:
cCmpFolder	:=	'CIU_ITEM,CIU_UFORI,CIU_UFDEST,CIU_VIGINI,CIU_VIGFIM,CIU_MAJORA,CIU_MJAUX,CIU_ID,CIU_TIPO,CIU_IDNCM,CIU_NCM,CIU_TRIB'

If lCIUCEST
    cCmpFolder += ',CIU_CEST'
EndIf

oStCfMajr	:=	FwFormStruct( 2, 'CIU', {|x| AllTrim( x ) $ cCmpFolder } )

//Atribuindo formul�rios para interface
oView:AddField('VIEW_NCM'       , oNcm      , 'FISA160B'         )
oView:AddGrid( 'VIEW_TRIBUTO'   , oTributo  , 'FISA160BTRIB'     )
oView:AddGrid( 'VIEW_MVA'	    , oStCfMVA	, 'FISA160BCFGMVA'   )
oView:AddGrid( 'VIEW_PAUTA'	    , oStCfPaut	, 'FISA160BCFGPAUTA' )
oView:AddGrid( 'VIEW_MAJOR'	    , oStCfMajr	, 'FISA160BCFGMAJOR' )

//Retira os campos da View
oNcm:RemoveField('CIS_ID')
oTributo:RemoveField('CIT_ID')
oTributo:RemoveField('CIT_IDNCM')
oTributo:RemoveField('CIT_TIPO')
oTributo:RemoveField('CIT_NCM')
oTributo:RemoveField('CIT_ALIQ')
oTributo:RemoveField('CIT_CODISS')

oStCfMVA:RemoveField('CIU_ID')
oStCfMVA:RemoveField('CIU_IDNCM')
oStCfMVA:RemoveField('CIU_TIPO')
oStCfMVA:RemoveField('CIU_NCM')
oStCfMVA:RemoveField('CIU_TRIB')

oStCfPaut:RemoveField('CIU_ID')
oStCfPaut:RemoveField('CIU_IDNCM')
oStCfPaut:RemoveField('CIU_TIPO')
oStCfPaut:RemoveField('CIU_NCM')
oStCfPaut:RemoveField('CIU_TRIB')

oStCfMajr:RemoveField('CIU_ID')
oStCfMajr:RemoveField('CIU_IDNCM')
oStCfMajr:RemoveField('CIU_TIPO')
oStCfMajr:RemoveField('CIU_NCM')
oStCfMajr:RemoveField('CIU_TRIB')


//Cria tr�s box
oView:CreateHorizontalBox( 'SUPERIOR'   , 18 )
oView:CreateHorizontalBox( 'MEIO'       , 37 )
oView:CreateHorizontalBox( 'INFERIOR'   , 45 )

//Cria o Folder Principal
oView:CreateFolder( 'FOLDER', 'INFERIOR' )

//Cria as Abas Principais
oView:AddSheet( 'FOLDER'	, 'ABA_MVA'	        , STR0002 ) //"Margem de Valor Agregado"
oView:AddSheet( 'FOLDER'	, 'ABA_PAUTA'	    , STR0003 ) //"Pauta"
oView:AddSheet( 'FOLDER'	, 'ABA_MAJORACAO'	, STR0004 ) //"Majora��o Al�quota"

//Cria box da aba de Principais
oView:CreateHorizontalBox( 'PAINEL_MVA'         , 100,,, 'FOLDER', 'ABA_MVA'        )
oView:CreateHorizontalBox( 'PAINEL_PAUTA'       , 100,,, 'FOLDER', 'ABA_PAUTA'      )
oView:CreateHorizontalBox( 'PAINEL_MAJORACAO'   , 100,,, 'FOLDER', 'ABA_MAJORACAO'  )

//Faz v�nculo do box com a view
oView:SetOwnerView( 'VIEW_NCM'      , 'SUPERIOR'    )
oView:SetOwnerView( 'VIEW_TRIBUTO'  , 'MEIO'        )

//Seta a View com seu respectivo Owner
oView:SetOwnerView( 'VIEW_NCM'      , 'SUPERIOR'        )
oView:SetOwnerView( 'VIEW_TRIBUTO'  , 'MEIO'            )
oView:SetOwnerView( 'VIEW_MVA'      , 'PAINEL_MVA'      )
oView:SetOwnerView( 'VIEW_PAUTA'    , 'PAINEL_PAUTA'    )
oView:SetOwnerView( 'VIEW_MAJOR'    , 'PAINEL_MAJORACAO')

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_NCM'    , STR0005 ) //'NCM'
oView:EnableTitleView('VIEW_TRIBUTO', STR0006 ) //'Tributos'
oView:EnableTitleView('VIEW_MVA'    , STR0007 ) //'Valores Auxiliares por Tributos( MVA )'
oView:EnableTitleView('VIEW_PAUTA'  , STR0008 ) //'Valores Auxiliares por Tributos( Pauta )'
oView:EnableTitleView('VIEW_MAJOR'  , STR0009 ) //'Valores Auxiliares por Tributos( Majora��o de Al�quota )'

//Picture do campo C�digo NCM
oNcm:SetProperty('CIS_CODNCM' , MVC_VIEW_PICT, "@R 9999.99.99")

//Alterando a descri��o de algns campos
oStCfMVA:SetProperty("CIU_ORIGEM", MVC_VIEW_TITULO, STR0010) //"Origem do Produto"
oStCfMVA:SetProperty("CIU_MVAAUX", MVC_VIEW_TITULO, STR0011) //"�ndice Auxiliar do MVA"
oStCfPaut:SetProperty("CIU_VLPAUT", MVC_VIEW_TITULO, STR0012) //"Valor da Pauta"
oStCfPaut:SetProperty("CIU_UM", MVC_VIEW_TITULO, STR0013) //"Unidade de Medida do Produto"
oStCfMajr:SetProperty("CIU_MAJORA", MVC_VIEW_TITULO, STR0014) //"Percentual de Majora��o"
oStCfMajr:SetProperty("CIU_MJAUX", MVC_VIEW_TITULO, STR0015) //"�ndice Auxiliar de Majora��o"

//Desabilita a edi��o do campo
oStCfMVA:SetProperty("CIU_ITEM", MVC_VIEW_CANCHANGE, .F.)
oStCfPaut:SetProperty("CIU_ITEM", MVC_VIEW_CANCHANGE, .F.)
oStCfMajr:SetProperty("CIU_ITEM", MVC_VIEW_CANCHANGE, .F.)

//Definindo o campo como incremental
oView:AddIncrementField( "VIEW_MVA", "CIU_ITEM" )
oView:AddIncrementField( "VIEW_PAUTA", "CIU_ITEM" )
oView:AddIncrementField( "VIEW_MAJOR", "CIU_ITEM" )

//Ordem do grid de MVA
oStCfMVA:SetProperty("CIU_ITEM"  , MVC_VIEW_ORDEM, "01")
oStCfMVA:SetProperty("CIU_UFORI" , MVC_VIEW_ORDEM, "02")
oStCfMVA:SetProperty("CIU_UFDEST", MVC_VIEW_ORDEM, "03")
oStCfMVA:SetProperty("CIU_VIGINI", MVC_VIEW_ORDEM, "04")
oStCfMVA:SetProperty("CIU_VIGFIM", MVC_VIEW_ORDEM, "05")
oStCfMVA:SetProperty("CIU_ORIGEM", MVC_VIEW_ORDEM, "06")
If lCIUCEST
    oStCfMVA:SetProperty("CIU_CEST"  , MVC_VIEW_ORDEM, "07")
    oStCfMVA:SetProperty("CIU_MARGEM", MVC_VIEW_ORDEM, "08")
    oStCfMVA:SetProperty("CIU_MVAAUX", MVC_VIEW_ORDEM, "09")
Else
    oStCfMVA:SetProperty("CIU_MARGEM", MVC_VIEW_ORDEM, "07")
    oStCfMVA:SetProperty("CIU_MVAAUX", MVC_VIEW_ORDEM, "08")
EndIf  

//Ordem do grid de Pauta
oStCfPaut:SetProperty("CIU_ITEM"  , MVC_VIEW_ORDEM, "01")
oStCfPaut:SetProperty("CIU_UFORI" , MVC_VIEW_ORDEM, "02")
oStCfPaut:SetProperty("CIU_UFDEST", MVC_VIEW_ORDEM, "03")
oStCfPaut:SetProperty("CIU_VIGINI", MVC_VIEW_ORDEM, "04")
oStCfPaut:SetProperty("CIU_VIGFIM", MVC_VIEW_ORDEM, "05")
If lCIUCEST
    oStCfPaut:SetProperty("CIU_CEST"  , MVC_VIEW_ORDEM, "06")
    oStCfPaut:SetProperty("CIU_UM"    , MVC_VIEW_ORDEM, "07")
    oStCfPaut:SetProperty("CIU_VLPAUT", MVC_VIEW_ORDEM, "08")
Else
    oStCfPaut:SetProperty("CIU_UM"    , MVC_VIEW_ORDEM, "06")
    oStCfPaut:SetProperty("CIU_VLPAUT", MVC_VIEW_ORDEM, "07")
EndIf

//Ordem do grid de Majora��o
oStCfMajr:SetProperty("CIU_ITEM"  , MVC_VIEW_ORDEM, "01")
oStCfMajr:SetProperty("CIU_UFORI" , MVC_VIEW_ORDEM, "02")
oStCfMajr:SetProperty("CIU_UFDEST", MVC_VIEW_ORDEM, "03")
oStCfMajr:SetProperty("CIU_VIGINI", MVC_VIEW_ORDEM, "04")
oStCfMajr:SetProperty("CIU_VIGFIM", MVC_VIEW_ORDEM, "05")
If lCIUCEST
    oStCfMajr:SetProperty("CIU_CEST"  , MVC_VIEW_ORDEM, "06")
    oStCfMajr:SetProperty("CIU_MAJORA", MVC_VIEW_ORDEM, "07")
    oStCfMajr:SetProperty("CIU_MJAUX" , MVC_VIEW_ORDEM, "08")
Else
    oStCfMajr:SetProperty("CIU_MAJORA", MVC_VIEW_ORDEM, "06")
    oStCfMajr:SetProperty("CIU_MJAUX" , MVC_VIEW_ORDEM, "07")
EndIf

//Desabilitando op��o de ordena��o
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160TIPO
Fun��o que retornar o c�digo do tipo

@param		cOp       - String  -  Op��o do Tipo do detalhamento da Atividade
@return     cOp       - String  -  Op��o do Tipo do detalhamento da Atividade

@author Renato Rezende
@since 15/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function FSA160TIPO(cOp)
Return cOp

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldCIU
Fun��o que realiza a valida��o de p�s edi��o da linha do grid dos valores
@param		cOpcap  - String    - Op��o com identificador de qual modelo a valida��o foi envocada
@Return     lRet    - Booleano  - REtorno com valida��o, .T. pode prosseguir, .F. n�o poder� prosseguir

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function PosVldCIU(cOpcao, lCIUCEST)
Local oModel		:= FWModelActive()
Local dDtIni        := ctod("  /  /    ")
Local dDtFim        := ctod("  /  /    ")
Local nTamGrid	    := 0
Local nX            := 0
Local nLnAtual      := 0
Local cUfOri        := ""
Local cUfDest       := ""
Local cMsgErro      := ""
Local cUndMedida    := ""
Local cOrigProd     := ""
Local cItemAtu      := ""
Local lChkVigIni    := .T.
Local lChkVigFim    := .T.
Local lErro         := .F.
Local oGrid         := nil
Local cCodCEST      := ""

Default lCIUCEST    := .F.

//Obtenho as informa��es para serem validadas
If cOpcao == "MVA" //Grid de MVA
    oGrid       := oModel:GetModel("FISA160BCFGMVA")
    cOrigProd   := oGrid:GetValue("CIU_ORIGEM")
    If lCIUCEST
        cCodCEST    := oGrid:GetValue("CIU_CEST")
    EndIf
ElseIf cOpcao == "PAUTA" //Grid De Paura
    oGrid       := oModel:GetModel("FISA160BCFGPAUTA")
    cUndMedida  := oGrid:GetValue("CIU_UM")
    If lCIUCEST
        cCodCEST    := oGrid:GetValue("CIU_CEST")
    EndIf
ElseIf cOpcao == "MAJ" //grid de Majora��o
    oGrid    := oModel:GetModel("FISA160BCFGMAJOR")
    If lCIUCEST
        cCodCEST := oGrid:GetValue("CIU_CEST")
    EndIf
EndIF

//Obtenho os valores do grid
nTamGrid := oGrid:Length()
cUfOri   := oGrid:GetValue("CIU_UFORI")
cUfDest  := oGrid:GetValue("CIU_UFDEST")
dDtIni   := oGrid:GetValue("CIU_VIGINI")
dDtFim   := oGrid:GetValue("CIU_VIGFIM")
cItemAtu := oGrid:GetValue("CIU_ITEM") 
nLnAtual := oGrid:Getline()

//Itero as linhas para verificar as UFs de origem e destino
For nX := 1 to nTamGrid
    
    //Muda linha do grid
    oGrid:GoLine(nX)
    
    //Verifico se a linha est� deletada. Se estiver irei para pr�xima linha v�lida
    //Verifico tamb�m se n�o estou validando a pr�pria linha
    If nLnAtual <> nX .And. !oGrid:IsDeleted() 

        //Verifico se a origem e destino s�o iguais. Se n�o passar no check de origem e destino precisa fazer os demais checks
        If !ChkOriDest(cUfOri, cUfDest, oGrid)
            
            //Se possuem mesma origem e destino, ent�o preciso verificar a vig�ncia            
            //Primeiro fa�o Check da vig�ncia inicial
            lChkVigIni := ChkVigIni(dDtIni, oGrid)
            
            //Depois fa�o Check da vig�ncia final
            lChkVigFim := ChkVigFim(dDtFim, oGrid)

            If cOpcao == "MVA"
                //Valida��o do MVA
                lErro := (!lChkVigIni .OR. !lChkVigFim) .And. !ChkOriPrd(cOrigProd, oGrid) .And. !ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
            ELseIf cOpcao == "PAUTA"
                //VAlida��o da Pauta
                lErro := (!lChkVigIni .OR. !lChkVigFim) .And. !ChkUndMed(cUndMedida, oGrid) .And. !ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
            ELseIf cOpcao == "MAJ"
                //VAlida��o da Majora��o
                lErro := (!lChkVigIni .OR. !lChkVigFim) .And. !ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
            EndIF

            //Mensagem para identificar a linha que est� divergente com a linha atual do grid
            If lErro
                cMsgErro := STR0023 + cItemAtu + STR0024  + oGrid:GetValue("CIU_ITEM") + " )" + CRLF //"Linha atual(Item: " -- ") est� em conflito de vig�ncia com linha j� cadastrada(Item: "                
                //Restauro a linha inicial do grid antes de sa�r da fun��o
                oGrid:GoLine(nLnAtual)
                HELP(' ',1, STR0021 ,, cMsgErro ,2,0,,,,,, {STR0022} ) //"Inconsist�ncia de valores" -- "Verifique a vig�ncia das informa��es"
                Return .F.
            EndIF

        EndIF

    EndIF

Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkOriDest
Fun��o que faz check de of origem e destino.

@param		cUfOri  - String    - UF origem da linha que est� sendo validada
@param		cUfDest  - String    - UF Destino da linha que est� sendo validada
@param		oGrid  - Objeto    - OBjeto com as informa��es do grid validado

@Return     lRet    - Booleano  - Rrtorno com valida��o, .T. possui origem e destino diferentes, .F. possuem mesmas origem e destino

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkOriDest(cUfOri, cUfDest, oGrid)

Local lRet  := .T.

//Verifica se origem e destino s�o iguais/correspondentes
//Os aster�scos significam todos os Estados.
If (cUfOri  == oGrid:GetValue("CIU_UFORI")  .OR. cUfOri  == "**" .Or. oGrid:GetValue("CIU_UFORI")  == "**") .AND.;
   (cUfDest == oGrid:GetValue("CIU_UFDEST") .OR. cUfDest == "**" .Or. oGrid:GetValue("CIU_UFDEST") == "**" )
    lRet  := .F. //Aqui significa que possuem mesma origem e destino
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkVigIni
Fun��o que faz check da data inicial da vig�ncia.

@param		dDtIni  - Date    - Data Inicial da linha que est� sendo editada
@param		oGrid  - Objeto    - OBjeto com as informa��es do grid validado
@Return     lRet    - Booleano  - Rrtorno com valida��o, .T. data inicial n�o est� contida em nenhum outro range

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkVigIni(dDtIni, oGrid)

Local lRet  := .T.

//Verifica se est� compreendido em cadastro somente com data inicial preenchida
//Verifica se a data inicial est� compreenchida em algum cadastro como data inicial e final informados
If dDtIni >= oGrid:GetValue("CIU_VIGINI") .And. ;
    (Empty(oGrid:GetValue("CIU_VIGFIM")) .Or. dDtIni <= oGrid:GetValue("CIU_VIGFIM"))

    //Aqui a data inicial est� contida em outro range, deve retornar mensagem de erro
    lRet    := .F.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkVigFim
Fun��o que faz check da data final da vig�ncia.

@param		dDtFim  - Date    - Data Final da linha que est� sendo editada
@param		oGrid  - Objeto    - OBjeto com as informa��es do grid validado
@Return     lRet    - Booleano  - Rrtorno com valida��o, .T. data final n�o est� contida em nenhum outro range

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkVigFim(dDtFim, oGrid)
Local lRet  := .T.

If Empty(dDtFim)
    //Se a data estiver vazia, ent�o n�o poderia ter outra data vazia
    IF Empty(oGrid:GetValue("CIU_VIGFIM"))
        //Aqui significa que j� existe uma linha com data de vig�ncia vazia
        lRet := .F.
    EndIf

ElseIF dDtFim >= oGrid:GetValue("CIU_VIGINI") .And. ;
       (Empty(oGrid:GetValue("CIU_VIGFIM")) .OR. dDtFim <= oGrid:GetValue("CIU_VIGFIM"))
    //Aqui a data final est� contida em algum range
    //Caso a data final seja informada ent�o verificaremos se est�comprendida em algum cadastro com data inicial e final preenchidos.
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkOriPrd
Fun��o que faz check da origem do produto

@param		cOriPrd  - String    - Origem do produto da linha que est� sendo editada
@param		oGrid  - Objeto    - OBjeto com as informa��es do grid validado
@Return     lRet    - Booleano  - Rrtorno com valida��o, .T. origem do produto � diferente

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkOriPrd(cOriPrd, oGrid)
Local lRet  := .T.

//O aster�sco significa todas as origens
If cOriPrd == oGrid:GetValue("CIU_ORIGEM") .Or. cOriPrd == "*" .Or. oGrid:GetValue("CIU_ORIGEM") == "*"
    lRet    := .F.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkUndMed
Fun��o que faz check da unidade de medida

@param		cUndMed  - String    - Unidade de medida da linha que est� sendo editada
@param		oGrid  - Objeto    - OBjeto com as informa��es do grid validado
@Return     lRet    - Booleano  - Rrtorno com valida��o, .T. unidade de medida � diferente

@author Erick Dias
@since 23/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function ChkUndMed(cUndMed, oGrid)
Local lRet  := .T.

//Os aster�scos significam todas as unidade de medida
If cUndMed == oGrid:GetValue("CIU_UM") .Or. cUndMed == "**" .Or. oGrid:GetValue("CIU_UM") == "**"
    lRet    := .F.
EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCEST
Fun��o que faz check do C�digo CEST

@param cCodCEST - String    - C�digo CEST da linha que est� sendo editada
@param oGrid    - Objeto    - Objeto com as informa��es do grid validado

@Return lRet     - Booleano  - Retorno com valida��o, .T. c�digo CEST � diferente

@author pereira.weslley
@since 20/01/2023
@version P12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ChkCEST(cCodCEST, oGrid, nTamGrid, lCIUCEST)
Local lRet  := .T.

If lCIUCEST
    If cCodCEST == oGrid:GetValue("CIU_CEST")
        lRet    := .F.
    EndIF

    If nTamGrid > 1 .And. (Empty(oGrid:GetValue("CIU_CEST")) .And. !Empty(cCodCEST)) .Or. (!Empty(oGrid:GetValue("CIU_CEST")) .And. Empty(cCodCEST))
        lRet    := .F.
    EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPosModel
Fun��o que realiza o pos processamento do modelo
Aqui basicamente atualizarei os Ids dos modelos, pois na c�pia os Ids s�o copiados tamb�m, 
causando erro de chave duplicada. Poderia marcar os campos de IDs como chaves, e eles n�o seriam
copiados, por�m nada seria copiado, j� que o relacionamento � em fun��o do Id.
Portanto estou atualizando manualmente os IDs dos modelos para possibilitar a funcionalidade da c�pia

@param		oModel  - Objeto    - Objeto do modelo
@Return     lRet    - Booleano  - Retornar .T. para prosseguir com grava��o do modelo

@author Erick Dias
@since 24/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function VldPosModel(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cIdCIS        := ""
Local cIdCIT        := ""
Local nX            := 0
Local nTam          := 0
Local oNcm          := nil
Local oTrib         := nil

//Somente para oper��es de inclus�o(c�pia tamb�m)
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
    
    //-----------------------------
    //Atribui o ID para o cabe�alho
    //-----------------------------
    oNcm    := oModel:GetModel("FISA160B")
    cIdCIS  := FWUUID("CIS")
    
    If nOperation == MODEL_OPERATION_INSERT
        oNcm:SetValue('CIS_ID', cIdCIS) //Chave da CIS
    EndIF

    //-----------------------------------
    //Atribui o ID para o grid do tributo
    //-----------------------------------
    oTrib := oModel:GetModel("FISA160BTRIB")
    nTam  := oTrib:Length()

    //La�o no grid do tributo
    For nX := 1 to nTam
        oTrib:GoLine(nX)
        cIdCIT := FWUUID("CIT")
        
        If nOperation == MODEL_OPERATION_INSERT
            oTrib:SetValue('CIT_ID'   , cIdCIT) //Chave da CIT
            oTrib:SetValue('CIT_IDNCM', cIdCIS) //Chave estrangeira com CIS
        EndIf
        
        oTrib:SetValue('CIT_NCM', oNcm:GetValue('CIS_CODNCM')) //Grava o c�digo do NCM

        //--------------------------------------
        //Atribui o ID para os grids dos valores
        //--------------------------------------        
        //Grid do MVA
        AtuIdCIU(oModel, "FISA160BCFGMVA"  , cIdCIT, oNcm:GetValue('CIS_CODNCM'), nOperation)
        //Grid da Pauta
        AtuIdCIU(oModel, "FISA160BCFGPAUTA", cIdCIT, oNcm:GetValue('CIS_CODNCM'), nOperation)
        //Grid da Majora��o
        AtuIdCIU(oModel, "FISA160BCFGMAJOR", cIdCIT, oNcm:GetValue('CIS_CODNCM'), nOperation)
 
    Next nX

Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuIdCIU
Fun��o que possui a atualiza��o da tabela CIU, como � em comum para todos os 
grids de valores, ent�o encapsulei em uma fun��o s�.

@param		oModel  - Objeto    - Objeto do modelo
@param		cModel  - String    - Nome do modelo
@param		cIdCIT  - String    - Id da tabela CIT(chave estrangeira)

@author Erick Dias
@since 24/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function AtuIdCIU(oModel, cModel, cIdCIT, cNCM, nOperation)

Local nX        := 0
Local oCIU      := oModel:GetModel(cModel)
Local nTamFilho := oCIU:Length()

//Atualiza todos os itens da CIU
For nX := 1 to nTamFilho
    oCIU:GoLine(nX)
    
    If nOperation == MODEL_OPERATION_INSERT
        oCIU:SetValue('CIU_ID'   , FWUUID("CIU")) //Id da CIU
        oCIU:SetValue('CIU_IDNCM', cIdCIT       ) //Chave estrangeira com CIT
    EndIf

    oCIU:SetValue('CIU_NCM', cNCM       ) //C�digo do NCM

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Fun��o que valida se o c�digo de regra por ncm j� existe

@author Renato Rezende
@since 26/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160B',"CIS_CODNCM")
Local lRet      := .T.

dbSelectArea("SYD")
dbSetOrder(1) 
//Verifica se o c�digo de NCM est� devidamente cadastrado na SYD
If !SYD->( MsSeek ( xFilial('SYD') + cCodigo ) )
    Help( ,, 'Help',, STR0025, 1, 0 )  //"C�digo NCM inv�lido."
    return .F.    
EndIF

//Procura se j� existe regra com o mesmo c�digo
If CIS->( MsSeek ( xFilial('CIS') + cCodigo ) )
    Help( ,, 'Help',, STR0016, 1, 0 )  //"C�digo NCM j� cadastrado."
    return .F.    
EndIF

Return lRet
