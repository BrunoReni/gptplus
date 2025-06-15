#INCLUDE "PRAA900.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PRAC900 
Método construtor e classe
@author   Felipe Machado de Oliveira
@version  P12
@since    21/06/2012
@obs      Localizacao de documentos
/*/

*----------------*
Function PRAA900()
*----------------*
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('DBO')
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()

return nil

*------------------------*
Static Function ModelDef()
*------------------------*
	Local oStructDBO := FWFormStruct(1, 'DBO', nil, nil)
	Local oModel     := MPFormModel():New('PRAA900')

	oStructDBO:SetProperty('DBO_LOCAL'  , MODEL_FIELD_VALID   , { || A900VLDE() })
//	oStructDBO:SetProperty('DBO_DESC'  , MODEL_FIELD_OBRIGAT , .T.)
//	oStructDBO:SetProperty('DBO_LOCAL'  , MODEL_FIELD_OBRIGAT , .T.)
//	oStructDBO:SetProperty('DBO_ORD'  , MODEL_FIELD_OBRIGAT , .T.)

	oModel:AddFields('DBOMASTER',/*cOwner*/, oStructDBO,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0009)
	oModel:GetModel('DBOMASTER'):SetDescription(STR0010)

return oModel

*-----------------------*
Static Function ViewDef()
*-----------------------*
	Local oModel     := FWLoadModel('PRAA900')
	Local oStructDBO := FWFormStruct(2,'DBO')
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField('VIEW_DBO',oStructDBO,'DBOMASTER')
	oView:CreateHorizontalBox('TELA', 100)
	oView:SetOwnerView('VIEW_DBO', 'TELA')

return oView

*-----------------------*
Static Function MenuDef()
*-----------------------*
  Local aRotina := {}

  ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 // 'Pesquisar'
  ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.PRAA900' OPERATION 2 ACCESS 0 // 'Visualizar'
  ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.PRAA900' OPERATION 3 ACCESS 0 // 'Incluir'
  ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.PRAA900' OPERATION 4 ACCESS 0 // 'Alterar'
  ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.PRAA900' OPERATION 5 ACCESS 0 // 'Excluir'
  ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.PRAA900' OPERATION 8 ACCESS 0 // 'Imprimir'
  ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.PRAA900' OPERATION 9 ACCESS 0 // 'Copiar'

Return aRotina

*----------------------*
Function A900VLDE()
*----------------------*
	Local oModel     := FwModelActive()
	Local oModelDBO  := oModel:GetModel('DBOMASTER')
	Local cLocal     := oModelDBO:GetValue('DBO_LOCAL')
	Local nOperation := oModelDBO:GetOperation()

	Local lRet := .T.

	if nOperation == 3 .OR. nOperation == 4
		if !ExistDir(cLocal)
			oModel:SetErrorMessage('DBOMASTER', 'DBO_LOCAL',,,,STR0011 )
			lRet := .F.
		endif
	endif

return lRet
