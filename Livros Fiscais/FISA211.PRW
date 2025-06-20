#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#Include "FISA211.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA211()

Rotina com objetivo de cadastrar os recibod de transmiss�o do SPED

@author Erick G Dias
@since 13/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA211()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F3N")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F3N")
    oBrowse:SetDescription(STR0001) //"Cadastro de Recibos de Transmiss�o do SPED"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, favor verificar atualiza��o da EFD Contribui��es"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 13/12/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA211" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro das regras de apura��o

@author Erick G Dias
@since 13/12/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "F3N" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA211',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA211",,oCabecalho)

oModel:SetPrimaryKey( {"F3N_FILIAL","F3N_ANO","F3N_MES","F3N_RECIBO"} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) //"Cadastro de Recibos de Transmiss�o do SPED"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias    
@since 13/12/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA211" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F3N")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA211' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Fun��o que realiza as valida��es do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA150
@Return     lRet       - Booleano - REtorno com valida��o, .T. pode gravar, .F. n�o poder� gravar.
@author Erick G Dias
@since 09/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cMes 		    := oModel:GetValue ('FISA211',"F3N_MES")
Local cAno 		    := oModel:GetValue ('FISA211',"F3N_ANO")
Local cRecibo 		:= oModel:GetValue ('FISA211',"F3N_RECIBO")
Local lRet          := .T.
Local nRecno        := F3N->(RECNO())
Local aAreaF3N      := F3N->(GetArea())

//Valida��es para opera��es de inclus�o e altera��o.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    dbSelectArea("F3N")
    dbSetOrder(1)
    If F3N->(MsSeek(xFilial('F3N') + cAno + cMes))
        //Na inclus�o, se a informa��o existir j� barro o usu�rio para n�o gravar informa��o duplicada
        If nOperation == MODEL_OPERATION_INSERT
            lRet    := .F.
        //J� na edi��o, somente certifico se o RECNO � do pr�prio registro, se for permite a edi��o, caso contr�rio barrar� o usu�rio
        ElseIF nOperation == MODEL_OPERATION_UPDATE .AND. nRecno <> F3N->(RECNO())
            lRet    := .F.            
        EndIF

        IF !lRet
            Help( ,, 'Help',, "J� existe recibo informado para este per�odo!", 1, 0 )//"J� existe recibo informado para este per�odo!"
        EndIF

    EndIF

EndIF

RestArea(aAreaF3N)   

Return lRet