#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA160D.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160D()

Esta rotina tem objetivo de realizar cadastro de regras para enquadramento 
pelo c�digo de ISS Federal.

Esta rotina estar� dispon�vel somente na vers�o 12.

@author Renato Rezende
@since 29/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function FISA160D()
Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CIX") .AND. AliasIndic("CIY") .And. AliasIndic("CIT")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CIX")
    oBrowse:SetDescription(STR0013) //"Al�quotas por C�digo de Servi�o"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Renato Rezende
@since 29/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA160D" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro de Unidade de Refer�ncia Fiscal

@author Renato Rezende
@since 29/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel    := Nil

Local oStCISS   := FWFormStruct(1, "CIX" )
Local oStCTrib  := FWFormStruct(1, "CIT" )
Local oStCGrid  := FWFormStruct(1, "CIY" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA160D', , {|oModel|VldPosModel(oModel)} )

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA160D",,oStCISS)

//Adicionando o grid das varia��es do tributo
oModel:AddGrid( 'FISA160DTRIB'      , 'FISA160D'        , oStCTrib  )
oModel:AddGrid( 'FISA160DCFGISS'	, 'FISA160DTRIB'	, oStCGrid )

//Deixando as abas opicionais o preenchimento
oModel:GetModel( 'FISA160DCFGISS' ):SetOptional( .T. )

oStCTrib:SetProperty('CIT_TIPO'  , MODEL_FIELD_INIT ,{||FSA160TIPO("2")} )

//N�o permite alterar o codigo do ISS
oStCISS:SetProperty('CIX_CODISS' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oStCISS:SetProperty('CIX_CODISS' , MODEL_FIELD_VALID,{||( VldCod(oModel) )})

//Define para n�o repetir o tributo
oModel:GetModel( 'FISA160DTRIB' ):SetUniqueLine( { 'CIT_TRIB' } )
oModel:GetModel( 'FISA160DCFGISS' ):SetUniqueLine( { 'CIY_UF', 'CIY_CODMUN' } )

//Campo obrigatorio 
oStCTrib:SetProperty('CIT_ALIQ' , MODEL_FIELD_OBRIGAT,  .T.) 
oStCGrid:SetProperty("CIY_ITEM"	, MODEL_FIELD_OBRIGAT,  .T.)

oStCTrib:SetProperty('CIT_IDNCM' , MODEL_FIELD_OBRIGAT,  .F. )
oStCGrid:SetProperty('CIY_IDISS' , MODEL_FIELD_OBRIGAT,  .F. ) 

//Indica que o campo � chave
oStCISS:SetProperty('CIX_CODISS'   , MODEL_FIELD_KEY,  .T. ) 

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0013) //"Al�quotas por C�digo de Servi�o"

oModel:SetPrimaryKey({""})

oModel:SetRelation( 'FISA160DTRIB'  , { { 'CIT_FILIAL', 'xFilial("CIT")' }, { 'CIT_IDNCM', 'CIX_ID' }, { 'CIT_TIPO', "'2'" } }, "CIT_FILIAL+CIT_ID" )
oModel:SetRelation( 'FISA160DCFGISS', { { 'CIY_FILIAL', 'xFilial("CIY")' }, { 'CIY_IDISS', 'CIT_ID' }, { 'CIY_TRIB', 'CIT_TRIB' } }, 'CIY_FILIAL+CIY_ITEM+CIY_TRIB+CIY_CODISS' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Renato Rezende
@since 30/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA160D" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oStCISS   := FWFormStruct(2, "CIX" )
Local oStCTrib  := FWFormStruct(2, "CIT" )
Local oStCGrid  := FWFormStruct(2, "CIY" )
Local oView     := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField('VIEW_ISS'       , oStCISS   , 'FISA160D'         )
oView:AddGrid( 'VIEW_TRIBUTO'   , oStCTrib  , 'FISA160DTRIB'     )
oView:AddGrid( 'VIEW_GRID'	    , oStCGrid	, 'FISA160DCFGISS'   )

//Habilitando op��es de filtros 
oView:SetViewProperty('VIEW_GRID', "GRIDFILTER" , {.T.})
oView:SetViewProperty('VIEW_GRID', "GRIDSEEK"   , {.T.})

//Retira os campos da View
oStCISS:RemoveField('CIX_ID')

oStCTrib:RemoveField('CIT_ID')
oStCTrib:RemoveField('CIT_IDNCM')
oStCTrib:RemoveField('CIT_TIPO')
oStCTrib:RemoveField('CIT_CODISS')
oStCTrib:RemoveField('CIT_NCM')

oStCGrid:RemoveField('CIY_ID')
oStCGrid:RemoveField('CIY_IDISS')
oStCGrid:RemoveField('CIY_CODISS')
oStCGrid:RemoveField('CIY_TRIB')

//Cria tr�s box
oView:CreateHorizontalBox( 'SUPERIOR'   , 18 )
oView:CreateHorizontalBox( 'MEIO'       , 37 )
oView:CreateHorizontalBox( 'INFERIOR'   , 45 )

//Faz v�nculo do box com a view
oView:SetOwnerView( 'VIEW_ISS'      , 'SUPERIOR'    )
oView:SetOwnerView( 'VIEW_TRIBUTO'  , 'MEIO'        )
oView:SetOwnerView( 'VIEW_GRID'     , 'INFERIOR'    )

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_ISS'    , STR0014) //"C�digo de Servi�o"
oView:EnableTitleView('VIEW_TRIBUTO', STR0005 ) //"Tributos"
oView:EnableTitleView('VIEW_GRID'   , STR0015 ) //"Al�quota Espec�fica por Munic�pio"

//Desabilita a edi��o do campo
oStCGrid:SetProperty("CIY_ITEM", MVC_VIEW_CANCHANGE, .F.)

//Definindo o campo como incremental
oView:AddIncrementField( "VIEW_GRID", "CIY_ITEM" )

//Ordem do grid
oStCGrid:SetProperty("CIY_ITEM"     , MVC_VIEW_ORDEM, "01")
oStCGrid:SetProperty("CIY_UF"       , MVC_VIEW_ORDEM, "02")
oStCGrid:SetProperty("CIY_CODMUN"   , MVC_VIEW_ORDEM, "03")
oStCGrid:SetProperty("CIY_DESMUN"   , MVC_VIEW_ORDEM, "04")
oStCGrid:SetProperty("CIY_ALIQ"     , MVC_VIEW_ORDEM, "05")

oStCISS:SetProperty("CIX_CODISS"     , MVC_VIEW_ORDEM, "01")

//Alterando descri��o de alguns campos
oStCISS:SetProperty("CIX_CODISS", MVC_VIEW_TITULO, STR0014) //"C�digo de Servi�o"
oStCTrib:SetProperty("CIT_ALIQ", MVC_VIEW_TITULO, STR0016) //"Al�quota Padr�o"
oStCGrid:SetProperty("CIY_UF", MVC_VIEW_TITULO, STR0017) //"Estado"
oStCGrid:SetProperty("CIY_CODMUN", MVC_VIEW_TITULO, STR0018) //"C�digo Munic�pio"
oStCGrid:SetProperty("CIY_ALIQ", MVC_VIEW_TITULO, STR0019) //"Al�quota Espec�fica"

//Desabilitando op��o de ordena��o
oView:SetViewProperty("*", "ENABLENEWGRID")
oView:SetViewProperty("*", "GRIDNOORDER" )

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
Local cIdCIX        := ""
Local cIdCIT        := ""
Local nX            := 0
Local nTam          := 0
Local oISS          := nil
Local oTrib         := nil

//Somente para oper��es de inclus�o(c�pia tamb�m)
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
    
    //-----------------------------
    //Atribui o ID para o cabe�alho
    //-----------------------------
    oISS    := oModel:GetModel("FISA160D")
    cIdCIX  := FWUUID("CIX")
    oISS:SetValue('CIX_ID', cIdCIX) //Chave da CIX    

    //-----------------------------------
    //Atribui o ID para o grid do tributo
    //-----------------------------------
    oTrib := oModel:GetModel("FISA160DTRIB")
    nTam  := oTrib:Length()

    //La�o no grid do tributo
    For nX := 1 to nTam
        oTrib:GoLine(nX)
        cIdCIT := FWUUID("CIT")
        
        If nOperation == MODEL_OPERATION_INSERT
            oTrib:SetValue('CIT_ID'   , cIdCIT) //Chave da CIT
            oTrib:SetValue('CIT_IDNCM', cIdCIX) //Chave estrangeira com CIX
        EndIF        

        oTrib:SetValue('CIT_CODISS', oISS:GetValue('CIX_CODISS')) //C�digo de servi�o

        //--------------------------------------
        //Atribui o ID para o grid doS valores
        //--------------------------------------
        AtuIdCIY(oModel, "FISA160DCFGISS"  , cIdCIT, oISS:GetValue('CIX_CODISS'), nOperation) 

    Next nX

Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuIdCIY
Fun��o que possui a atualiza��o da tabela CIY, como � em comum para todos os 
grids de valores, ent�o encapsulei em uma fun��o s�.

@param		oModel  - Objeto    - Objeto do modelo
@param		cModel  - String    - Nome do modelo
@param		cIdCIT  - String    - Id da tabela CIT(chave estrangeira)

@author Erick Dias
@since 24/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function AtuIdCIY(oModel, cModel, cIdCIT, cCodServ,nOperation)

Local nX        := 0
Local oCIY      := oModel:GetModel(cModel)
Local nTamFilho := oCIY:Length()

//Atualiza todos os itens da CIY
For nX := 1 to nTamFilho
    oCIY:GoLine(nX)
    
    If nOperation == MODEL_OPERATION_INSERT
        oCIY:SetValue('CIY_ID'   , FWUUID("CIY")) //Id da CIY
        oCIY:SetValue('CIY_IDISS', cIdCIT       ) //Chave estrangeira com CIT
    EndIF
    
    oCIY:SetValue('CIY_CODISS', cCodServ    ) //C�digo de Servi�o
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Fun��o que valida se o c�digo de regra de ISS j� existe

@author Renato Rezende
@since 30/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160D',"CIX_CODISS")
Local lRet      := .T.

SX5->(dbSetOrder(1))

//Vejo se c�digo est� cadastrado na SX5
If !SX5->(DBSeek(xFilial("SX5") + "60" + cCodigo))
    Help( ,, 'Help',, STR0020 , 1, 0 ) //"C�digo de Presta��o de Servi�o n�o Cadastrado"
    return .F.    
EndIF

//Vejo se c�digo j� foi cadastrado na CIX
If CIX->(DBSeek(xFilial("CIX") + cCodigo))
    Help( ,, 'Help',, STR0021 , 1, 0 ) //"C�digo de presta��o de servi�o j� cadastrado."
    return .F.    
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA160DEST
Fun��o que montar� o filtro da consulta padr�o CC2CIY.
Aqui retornar� por padr�o o filtro da CIY, mas poder� ser 
utilizada tamb�m pelos facilitadores, na consulta padr�o 
dos munic�pios para filtrar participantes.

@author Erick G Dias
@since 23/07/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA160DEST()

Local cRet := ""
Local cUf  := FWFldGet("CIY_UF")

If !Empty(cUf)
    cRet := "CC2_EST=='" + cUf + "'"
Else
    If type("cA1Estado") <> "U"
        cRet    := "CC2_EST == '" + cA1Estado + "'"
    ElseIF type("cA2Estado") <> "U"
        cRet    := "CC2_EST == '" + cA2Estado + "'"
    EndIf
EndIf

Return cRet
