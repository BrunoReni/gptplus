#include "Protheus.ch"
#include "FwMvcDef.ch"
#Include "JURA280.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA280
Rotina responsavel pelas notifica��es do Totvs Legal
Fun��o responsavel pela defini��o do browse
@since 15/07/2020
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function JURA280()
Local oBrowse       := FWMBrowse():New()

	DbSelectArea('O12')
	oBrowse:SetAlias('O12')

	oBrowse:SetMenuDef('JURA280')
	oBrowse:SetDescription(STR0001)//Notifica��es do Totvs Juridico

	oBrowse:Activate()
	oBrowse:Destroy()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Fun��o responsavel pela defini��o do menu
@since 15/07/2020
@return aRotina, retorna as op��es do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.JURA280' OPERATION OP_VISUALIZAR ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.JURA280' OPERATION OP_INCLUIR    ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.JURA280' OPERATION OP_ALTERAR    ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.JURA280' OPERATION OP_EXCLUIR    ACCESS 0 // Excluir

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o responsavel pela defini��o do modelo
@since 15/07/2020
@return oModel, retorna o objeto do modelo
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel   := nil
Local oStrO12  := FWFormStruct(1, 'O12' )

	oModel := MPFormModel():New('JURA280', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('O12MASTER',/*cOwner*/,oStrO12,/*bPre*/,/*bPos*/,/*bLoad*/)

	oModel:SetDescription(STR0001)

	oModel:GetModel('O12MASTER'):SetDescription(STR0001) //'Notifica��es do Totvs Jur�dico' 

	JurSetRules( oModel, 'O12MASTER',, 'O12' )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o responsavel pela defini��o da view
@since 15/07/2020
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA280')
Local oStrO12 := FWFormStruct(2, 'O12')

	oView:SetModel(oModel)

	oView:AddField('VIEW_O12' ,oStrO12, 'O12MASTER')

	oView:CreateHorizontalBox('BOX', 100)

	oView:SetOwnerView('VIEW_O12','BOX')

	oView:SetDescription(STR0001) //'Notifica��es do Totvs Jur�dico'

Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} JA280Notify
Fun��o responsavel pela grava��o da notifica��o
@since 24/07/2020
@param cTitulo, character, T�tulo a ser informado na notifica��o
@param cCodUsr, character, C�digo do usu�rio que ir� possuir a notifica��o
@param cIcon, character, icone que ser� apresentado
@param cTpAcao, character, tipo da a��o (1=notifica��o/2=redirecionamento/3=download)
@param cOrigem, character, origem que gerou a notifica��o
@param cParam, character, Parametros adicionais caso necess�rio
@param lOnlyOne, boolean, Informa se dever� existir apenas 1 registro por dia
@return aRet, Retorna um array com 2 posi��es, sendo 1= informa se gravou com sucesso, 2= mensagem caso erro
/*/
//------------------------------------------------------------------------------
Function JA280Notify(cTitulo, cCodUsr, cIcon, cTpAcao, cOrigem, cParam, lOnlyOne)
Local aRet       := {.T.,""}
Local aArea      := {}
Local aAreaO12   := {}
Local oModel     := Nil
Local oMdlO12    := Nil

Default cTitulo  := ""
Default cCodUsr  := __cUserId
Default cIcon    := "notification"
Default cTpAcao  := "1" //Notification
Default cOrigem  := FunName()
Default cParam   := ""
Default lOnlyOne := .F.

	If FWAliasInDic("O12") //Grava��o de notifica��es Totvs Jur�dico
		aArea    := GetArea()
		aAreaO12 := O12->(GetArea())
		oModel   := FwLoadModel("JURA280")
		oMdlO12  := oModel:GetModel('O12MASTER')

		dbSelectArea("O12")
		O12->( dbSetOrder( 2 ) ) //O12_FILIAL+O12_CODUSR+DTOS(O12_DATA)+O12_ORIGEM

		If lOnlyOne .and. O12->( DbSeek(xFilial("O12")+cCodUsr+DTOS(Date())+cOrigem) )
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
		Else
			oModel:SetOperation(MODEL_OPERATION_INSERT)
		EndIf

		If oModel:Activate()
			If Empty(oMdlO12:GetValue( "O12_CODIGO"))
				oMdlO12:SetValue( "O12_CODIGO",GetSxeNum('O12','O12_CODIGO'))
			Endif

			oMdlO12:SetValue( "O12_TITULO", cTitulo )
			oMdlO12:SetValue( "O12_CODUSR", cCodUsr )
			oMdlO12:SetValue( "O12_ICONE" , cIcon   )
			oMdlO12:SetValue( "O12_ORIGEM", cOrigem )
			oMdlO12:SetValue( "O12_TPACAO", cTpAcao )
			oMdlO12:SetValue( "O12_PARAM" , cParam  )
			oMdlO12:SetValue( "O12_LIDO" , .F.      )

			If oModel:VldData()
				oModel:CommitData()
			Else
				aRet[1] :=.F.
				aRet[2] := JurModErro(oModel)
			EndIf

			oModel:DeActivate()
		EndIf

		oModel:Destroy()

		FwFreeObj(oModel)

		O12->(DbCloseArea())

		RestArea(aAreaO12)
		RestArea(aArea)
	EndIf
	
Return aRet
