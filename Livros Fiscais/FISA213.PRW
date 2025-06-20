#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA213.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA213()  

Rotina com objetivo de registrar os percentuais de estorno dos cr�ditos
de PIS e COFINS, referente ao b/enef�cio da agro ind�istria, que permite 
determinadas vendas n�o sem tributadas, por�m em contra partida dever�
estornar os cr�ditos de PIS e COFINS de determinados insumos.

Estes percentuais ser�o armazenados nesta tabela para que apura��o 
da EFD Contribui��es possa ler e gerar os estornos automaticamente,
atrav�s dos registros M110 e M510, ajustes de redu��o de cr�dito
de PIS e COFINS.

@author Erick G Dias
@since 05/02/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA213()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F3V")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F3V")
    oBrowse:SetDescription(STR0001)//"Cadastro dos Percentuais de Estorno dos Cr�ditos de PIS e COFINS"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicion�rio desatualizado, favor verificar atualiza��o da EFD Contribui��es"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA213" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro das regras de apura��o

@author Erick G Dias
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "F3V",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(1, "F3V",{|cCampo| COMPSTRU("ITE",cCampo)})

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA213',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })
 
//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA213",,oCabecalho)

oCabecalho:SetProperty('F3V_PERAPU' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Adiciona o grid
oModel:AddGrid("FISA213ITEM","FISA213",oItem)

oModel:SetRelation('FISA213ITEM', {{ 'F3V_FILIAL', 'xFilial("F3V")' }, { 'F3V_PERAPU', 'F3V_PERAPU' }, { 'F3V_ORIG', 'F3V_ORIG' }}, F3V->( IndexKey(1)))

oModel:SetPrimaryKey( {"F3V_FILIAL","F3V_PERAPU", "F3V_ORIG" } )

oModel:GetModel( 'FISA213ITEM' ):SetUniqueLine( { 'F3V_DESCHP' } )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001)  //"Cadastro dos Percentuais de Estorno dos Cr�ditos de PIS e COFINS"

oModel:AddCalc( 'FISA213ITEMTOTAL', 'FISA213', 'FISA213ITEM', 'F3V_PERDET', 'Total', 'SUM', { | oFW | .T. },,'Total %' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA213" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2,"F3V",{|cCampo| COMPSTRU("CAB",cCampo)})
Local oItem      := FWFormStruct(2,"F3V",{|cCampo| COMPSTRU("ITE",cCampo)})
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

// Retirando campo de ID e origem da view.
oCabecalho:RemoveField('F3V_ID')
oCabecalho:RemoveField('F3V_ORIG')

oItem:RemoveField('F3V_ID')
oItem:RemoveField('F3V_ORIG')

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA213' )

//Adiciona o grid com os c�digo BCC
oView:AddGrid("VIEW_ITEM",oItem,"FISA213ITEM")

// Cria o objeto de Estrutura
oCalc1 := FWCalcStruct( oModel:GetModel( 'FISA213ITEMTOTAL') )
//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddField( 'VIEW_TOTAL', oCalc1, 'FISA213ITEMTOTAL' )

//Separa a tela em duas partes
oView:CreateHorizontalBox("SUPERIOR",20)	
oView:CreateHorizontalBox("INFERIOR",60)
oView:CreateHorizontalBox("RODAPE",20)

//Defini��o do cabe�alho e do item na tela
oView:SetOwnerView("VIEW_CABECALHO","SUPERIOR")
oView:SetOwnerView("VIEW_ITEM","INFERIOR")
oView:SetOwnerView("VIEW_TOTAL","RODAPE")

//T�tulos do cabe�alho e do item
oView:EnableTitleView('VIEW_CABECALHO', STR0003) //'Estorno do Cr�dito do Per�odo' 
oView:EnableTitleView('VIEW_ITEM'     , STR0004) //'Detalhamento do Estorno de Cr�dito'
oView:EnableTitleView('VIEW_TOTAL'    , STR0005) //'Total do Percentual de Detalhamento'

oView:SetViewProperty( "*", "GRIDNOORDER" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPSTRU
Fun��o que faz verifica��o dos campos que dever�o ser exibidos
no cabe�alho ou ent�o no item do Grid.

@author Erick G Dias    
@since 05/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function COMPSTRU(cTipo,cCampo)

Local lRet := .F.

If cTipo == "CAB" .AND. AllTrim(cCampo) $ "F3V_PERAPU/F3V_PEREST/F3V_ORIG" //Verifica os campos de cabe�alho
    lRet := .T.
ElseIf cTipo == "ITE" .AND. AllTrim(cCampo) $ "F3V_DESCHP/F3V_PERDET/F3V_ORIG/F3V_CODAJU/F3V_CODCTA" //Verifica os campos dos itens
    lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA213PER
Fun��o zuxilar para valida��o do per�odo dos percentuais

@author Erick G Dias    
@since 06/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA213PER()

Local lRet  := .F.

lRet := Len(Alltrim(FwFldGet("F3V_PERAPU")))==6 .And. ;
        VAL(Substr(FwFldGet("F3V_PERAPU"),5,2))>=1 .And. ;
        VAL(Substr(FwFldGet("F3V_PERAPU"),5,2))<=12 .AND. ;
        !ExistCpo("F3V", FwFldGet("F3V_PERAPU"))

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Fun��o que far� a valida��o de grava��o do modelo
Aqui verificarei se o percentual do detalhamento totaliza 100%, para evitar
c�lculo incorreto na apura��o da EFD COntribui��es.

@author Erick G Dias    
@since 07/02/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local oGrid     := oModel:GetModel( 'FISA213ITEM' )
Local nI        := 0
Local nTotal    := 0
Local lRet      := .T.

//Percorrer� as linhas do grid, de forma que o somat�rio dos percentuais do detalhamento seja igual a 100%
For nI := 1 To oGrid:Length()
    oGrid:GoLine(nI)
    IF !oGrid:IsDeleted() //N�o considero as linhas deletadas
        nTotal += oGrid:GetValue('F3V_PERDET')
    EndiF
Next nI

//Verifico se o somat�rio dos percentuais � diferente de 100%, se for ent�o ser� exibida mensagem de alerta para usu�rio
If nTotal <> 100
    lRet := .F.
    Help( ,, 'Help',, STR0006, 1, 0 )//"O somat�rio dos percentuais de detalhamento precisa ser igual a 100%, por favor verifique os percentuais do detalhamento informados."
EndIF

Return lRet