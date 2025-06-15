#Include "FISA160L.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160L()

Esta rotina tem objetivo de realizar o cadastro das
Regras para gera��o da Guia de Escritura��o

@author Renato Rezende
@since 17/09/2020
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA160L()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ4")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ4")
    oBrowse:SetDescription(STR0001) //"Regra para gera��o da Guia de Escritura��o"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Renato Rezende
@since 17/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Static  lExMesSb:= FieldPos("CJ4_MESFIX") > 0
Return FWMVCMenu( "FISA160L" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro das regras para gera��o da guia

@author Renato Rezende
@since 17/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "CJ4" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA160L',,{|oModel|VALIDACAO(oModel) })

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA160L",,oCabecalho)

//Configura��es dos campos
oCabecalho:SetProperty('CJ4_CODIGO' , MODEL_FIELD_KEY   , .T. )

oCabecalho:SetProperty('CJ4_CODIGO' , MODEL_FIELD_VALID , {|| ( VldCod(oModel) )})
oCabecalho:SetProperty('CJ4_MODO'   , MODEL_FIELD_VALID , {|| (Fsa160LCpo("CJ4_MODO"))    })
oCabecalho:SetProperty('CJ4_CFVENC' , MODEL_FIELD_VALID , {|| (Fsa160LCpo("CJ4_CFVENC"))    })

oCabecalho:SetProperty('CJ4_CODIGO' , MODEL_FIELD_WHEN  , {|| (oModel:GetOperation() == 3 ) })
oCabecalho:SetProperty('CJ4_MAJSEP'  , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_ORIDES' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_IMPEXP' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_IE'     , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_QTDDIA' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_CFVENC") == "1" } )
oCabecalho:SetProperty('CJ4_DTFIXA' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_CFVENC") $ "2|3|4" } )
If lExMesSb
   oCabecalho:SetProperty('CJ4_MESFIX' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_CFVENC") == "4" } ) 
EndIf
oCabecalho:SetProperty('CJ4_CNPJ'   , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_IEGUIA' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_UF'     , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_INFCOM' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_DESINF' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )

oModel:SetPrimaryKey( {"CJ4_FILIAL","CJ4_CODIGO"} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) //"Regra para gera��o da Guia de Escritura��o"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Renato Rezende    
@since 17/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA160L" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "CJ4")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA160L' )

oCabecalho:AddGroup( 'GRUPO_ID'     , STR0003 , '' , 2 )  //"Defini��o da Regra"
oCabecalho:AddGroup( 'GRUPO_MODO'   , STR0004 , '' , 2 )  //"Modo para gera��o da Guia"
oCabecalho:AddGroup( 'GRUPO_CONF'   , STR0005 , '' , 2 )  //"Crit�rios para gera��o da Guia"
oCabecalho:AddGroup( 'GRUPO_VENC'   , "Vencimento da GNRE" , '' , 2 )  //"Vencimento da GNRE"
oCabecalho:AddGroup( 'GRUPO_COMP'   , "Informa��es Complementares da GNRE" , '' , 2 )  //"Informa��es Complementares da GNRE"


//Campos que fazem parte do grupo de defini��o da regra
oCabecalho:SetProperty( 'CJ4_CODIGO'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )
oCabecalho:SetProperty( 'CJ4_DESCR'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )

//Campos que fazem parte do grupo de regras de titulos
oCabecalho:SetProperty( 'CJ4_MODO'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MODO' )
oCabecalho:SetProperty( 'CJ4_VTELA'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MODO' )
oCabecalho:SetProperty( 'CJ4_MAJSEP'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MODO' )

//Campos que fazem parte do grupo de regras de guia
oCabecalho:SetProperty( 'CJ4_ORIDES'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CONF' )
oCabecalho:SetProperty( 'CJ4_IMPEXP'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CONF' )
oCabecalho:SetProperty( 'CJ4_IE'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CONF' )

//Campos que fazem parte do grupo de vencimento da GNRE
oCabecalho:SetProperty( 'CJ4_CFVENC'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
oCabecalho:SetProperty( 'CJ4_QTDDIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
oCabecalho:SetProperty( 'CJ4_DTFIXA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
If lExMesSb
    oCabecalho:SetProperty( 'CJ4_MESFIX'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
EndIf

//Campos que fazem parte do grupo de informa��es complementares da GNRE
oCabecalho:SetProperty( 'CJ4_CNPJ'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_IEGUIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_UF'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_INFCOM'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_DESINF'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )

//Ajuste dos t�tulos dos campos de filtros de f�rmula
oCabecalho:SetProperty("CJ4_MODO"  , MVC_VIEW_TITULO, STR0006)    //"Modo para Gera��o da Guia de Escritura��o"
oCabecalho:SetProperty("CJ4_VTELA" , MVC_VIEW_TITULO, STR0007)   //"Visualiza Guia no Momento da Gera��o da Nota"
oCabecalho:SetProperty("CJ4_MAJSEP", MVC_VIEW_TITULO, "Guia de Majora��o")   //"Visualiza Guia no Momento da Gera��o da Nota"
oCabecalho:SetProperty("CJ4_ORIDES", MVC_VIEW_TITULO, STR0008)  //"UF de Origem e Destino"
oCabecalho:SetProperty("CJ4_IMPEXP", MVC_VIEW_TITULO, STR0009)  //"Importa��o ou Exporta��o"
oCabecalho:SetProperty("CJ4_IE"    , MVC_VIEW_TITULO, STR0010)      //"Inscri��o Estadual na UF de Destino"
oCabecalho:SetProperty("CJ4_DTFIXA", MVC_VIEW_TITULO, STR0016)  //"Data do Dia Fixo"
oCabecalho:SetProperty("CJ4_QTDDIA", MVC_VIEW_TITULO, STR0015)  //"Quantidade de Dias a Somar"
If lExMesSb
    oCabecalho:SetProperty("CJ4_MESFIX", MVC_VIEW_TITULO, "Quantidade de Meses")  //"Quantidade de Meses"
EndIf

//Aqui � a defini��o de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CABECALHO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160LCpo
Fun��o que valida os campos

@author Renato Rezende    
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Function Fsa160LCpo(cCampo)

Local oModel        := FWModelActive()
Local cModoGera 	:= oModel:GetValue ('FISA160L',"CJ4_MODO")
Local cCfcVenc      := oModel:GetValue ('FISA160L',"CJ4_CFVENC")
Local oCabecalho	:= oModel:GetModel("FISA160L")

If cCampo == "CJ4_MODO"
    //Limpa o conte�do dos campos abaixo
    If cModoGera <> '1'
        //grupo de regras de titulos
        oCabecalho:LoadValue('CJ4_VTELA' , Criavar("CJ4_VTELA") )
        oCabecalho:LoadValue('CJ4_MAJSEP' , Criavar("CJ4_MAJSEP") )        
        
        //grupo de regras de guia
        oCabecalho:LoadValue('CJ4_ORIDES', Criavar("CJ4_ORIDES") )
        oCabecalho:LoadValue('CJ4_IMPEXP', Criavar("CJ4_IMPEXP") )
        oCabecalho:LoadValue('CJ4_IE'    , Criavar("CJ4_IE") )
        
        //grupo de informa��es complementares da GNRE
        oCabecalho:LoadValue('CJ4_CNPJ'  , Criavar("CJ4_CNPJ") )
        oCabecalho:LoadValue('CJ4_IEGUIA', Criavar("CJ4_IEGUIA") )
        oCabecalho:LoadValue('CJ4_UF'    , Criavar("CJ4_UF") )
        oCabecalho:LoadValue('CJ4_INFCOM', Criavar("CJ4_INFCOM") )
        oCabecalho:LoadValue('CJ4_DESINF', " " )
        
        //grupo de vencimento da GNRE
        oCabecalho:LoadValue('CJ4_CFVENC', Criavar("CJ4_CFVENC") )
        oCabecalho:LoadValue('CJ4_QTDDIA', Criavar("CJ4_QTDDIA") )
        oCabecalho:LoadValue('CJ4_DTFIXA', Criavar("CJ4_DTFIXA") )
        If lExMesSb
            oCabecalho:LoadValue('CJ4_MESFIX', Criavar("CJ4_MESFIX") )
        EndIf
    EndIf
ElseIf cCampo == "CJ4_CFVENC"
    If cCfcVenc <> '1'
        oCabecalho:LoadValue('CJ4_QTDDIA' , Criavar("CJ4_QTDDIA") )
        If lExMesSb .And. cCfcVenc <> '4'
            oCabecalho:LoadValue('CJ4_MESFIX' , Criavar("CJ4_MESFIX") )
        EndIf
    Else
        oCabecalho:LoadValue('CJ4_DTFIXA', Criavar("CJ4_DTFIXA") )
        If lExMesSb
            oCabecalho:LoadValue('CJ4_MESFIX' , Criavar("CJ4_MESFIX") )
        EndIf
    EndIf
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Fun��o que valida se o c�digo da regra

@author Renato Rezende
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160L',"CJ4_CODIGO")
Local lRet      := .T.

//Procura se j� existe regra com o mesmo c�digo
CJ4->(DbSetOrder(1))
If CJ4->( MsSeek ( xFilial('CJ4') + cCodigo ) )
    Help( ,, 'Help',, STR0011, 1, 0 ) //"C�digo j� cadastrado!"
    return .F.    
EndIF

//N�o pode digitar operadores e () no c�digo
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0012, 1, 0 ) //"C�digo da regra n�o pode conter os caracteres '*', '/', '+', '-', '(' e ')'"
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0013, 1, 0 ) //"C�digo n�o pode conter espa�o."
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Validacao
Fun��o que realiza as valida��es do modelo

@param		oModel  - Objeto    - Objeto do modelo FISA160L
@Return     lRet    - Booleano  - Retorno com valida��o, .T. pode gravar, .F. n�o poder� gravar.

@author Renato Rezende
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function Validacao(oModel)

Local lRet          := .T.
Local cModoGera     := oModel:GetValue ('FISA160L',"CJ4_MODO" )
Local cOriDest      := oModel:GetValue ('FISA160L',"CJ4_ORIDES" )
Local cImpExp       := oModel:GetValue ('FISA160L',"CJ4_IMPEXP" )
Local cIE           := oModel:GetValue ('FISA160L',"CJ4_IE" )
Local cCfcVenc      := oModel:GetValue ('FISA160L',"CJ4_CFVENC")
Local nDtFixa       := oModel:GetValue ('FISA160L',"CJ4_DTFIXA" )
Local nSomaDt       := oModel:GetValue ('FISA160L',"CJ4_QTDDIA" )
Local nMesFixo      := 0
Local nOperation 	:= oModel:GetOperation()

If lExMesSb
    nMesFixo := oModel:GetValue ('FISA160L',"CJ4_MESFIX" )
EndIf

//Valida��es na inclus�o ou altera��o do cadastro
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    //Se o campo como ser� gerada a guia estiver em branco os outros campos de decis�o n�o poder�o estar preenchidos
    If Empty(cModoGera)
        If !Empty(cOriDest) .Or. !Empty(cImpExp) .Or. !Empty(cIE)    
            lRet:= .F.
            Help( ,, 'Help',, STR0014, 1, 0 ) //"Campo obrigat�rio n�o preenchido: Modo para Gera��o da Guia de Escritura��o (CJ4_MODO)"
        EndIf
    EndIF
    //N�o dexiar data com o valor zero
    If !Empty(cCfcVenc)
        If cCfcVenc == '1' .And. nSomaDt == 0
            lRet:= .F.
        ElseIf cCfcVenc $ '2|3' .And. nDtFixa == 0 
            lRet:= .F.
        ElseIf cCfcVenc == '4' .And. (nDtFixa == 0 .Or. nMesFixo == 0)
            lRet:= .F.
        EndIf
        If !lRet
            Help( ,, 'Help',, STR0017, 1, 0 ) //"O Valor dos campos Data do Dia Fixo (CJ4_DTFIXA) ou Quantidade de Dias a Somar (CJ4_QTDDIA) n�o podem ficar com o valor zero!"
        EndIf
    EndIf
EndIf

Return lRet
