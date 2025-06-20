#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA176.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA176()

Esta rotina tem objetivo de realizar o cadastro das regras de apur��es
para os tibutos gen�ricos

@author Erick G Dias
@since 23/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA176()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2N")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2N")
    oBrowse:SetDescription(STR0001) //"Regra de T�tulos da Apura��o"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)  //"Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA176" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro das regras de apura��o

@author Erick G Dias
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "F2N" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA176',,{|oModel|ValidModel(oModel) })

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA176",,oCabecalho)

oModel:SetPrimaryKey( {"F2N_FILIAL","F2N_TRIB","F2N_RTIT"} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0003)  //"Cadastro de Regra de T�tulo para Apura��o"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias    
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA176" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2N")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA176' )

oCabecalho:AddGroup( 'GRUPO_ID'     , "Defini��o da Regra" , '' , 2 )
oCabecalho:AddGroup( 'GRUPO_TITU'   , "Regras de T�tulo"   , '' , 2 ) 
oCabecalho:AddGroup( 'GRUPO_GUIA'   , "Regra para Guia de Recolhimento" , '' , 2 )


//Campos que fazem parte do grupo de defini��o da regra
oCabecalho:SetProperty( 'F2N_TRIB'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )
oCabecalho:SetProperty( 'F2N_DTRIB'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )

//Campos que fazem parte do grupo de regras de titulos
oCabecalho:SetProperty( 'F2N_RTIT'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TITU' )
oCabecalho:SetProperty( 'F2N_DTIT'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TITU' )

If F2N->(Fieldpos("F2N_RGGUIA")) > 0 .And. F2N->(Fieldpos("F2N_DRGUIA")) > 0
    //Campos que fazem parte do grupo de regras de guia
    oCabecalho:SetProperty( 'F2N_RGGUIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_GUIA' )
    oCabecalho:SetProperty( 'F2N_DRGUIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_GUIA' )
EndIf

//Aqui � a defini��o de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CABECALHO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

// Retirando campo de ID da view.
oCabecalho:RemoveField( 'F2N_FKKID'  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias    
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cTrib 		:= oModel:GetValue ('FISA176',"F2N_TRIB")
Local lRet          := .T.
Local nRecno        := F2N->(RECNO())
Local aAreaF2N      := F2N->(GetArea())

//Valida��es para opera��es de inclus�o e altera��o.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    dbSelectArea("F2N")
    dbSetOrder(1)
    If F2N->(MsSeek(xFilial('F2N') + cTrib ))
        //Na inclus�o, se a informa��o existir j� barro o usu�rio para n�o gravar informa��o duplicada
        If nOperation == MODEL_OPERATION_INSERT
            lRet    := .F.
        //J� na edi��o, somente certifico se o RECNO � do pr�prio registro, se for permite a edi��o, caso contr�rio barrar� o usu�rio
        ElseIF nOperation == MODEL_OPERATION_UPDATE .AND. nRecno <> F2N->(RECNO())
            lRet    := .F.            
        EndIF

        IF !lRet
            Help( ,, 'Help',, STR0004, 1, 0 )              //"C�digo de Tributo j� cadastrado"
        EndIF

    EndIF

EndIF

RestArea(aAreaF2N)

Return lRet

