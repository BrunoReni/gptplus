#INCLUDE "PRAA902.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PRAA902 
@author   Felipe Machado de Oliveira
@version  P12
@since    29/06/2012
@obs      Cadastro de SQLs Dinâmicos
/*/

Function PRAA902()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DBQ')
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()

Return nil

Static Function ModelDef()
	Local oStructDBQ := FWFormStruct(1, 'DBQ', /*bAvalCampo*/,/*lViewUsado*/)
	Local oModel

	oModel := MPFormModel():New('PRAA902',,{|oModel| PRAA902POS(oModel)})
	oModel:AddFields('DBQMASTER', , oStructDBQ)
	oModel:SetDescription(STR0009)
	oModel:GetModel('DBQMASTER'):SetDescription(STR0010)
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('PRAA902')
	Local oStructDBQ := FWFormStruct(2,'DBQ')

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_DBQ',oStructDBQ,'DBQMASTER')
	oView:CreateHorizontalBox('TELA', 100)
	oView:SetOwnerView('VIEW_DBQ', 'TELA')

Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002   ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.PRAA902' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004   ACTION 'VIEWDEF.PRAA902' OPERATION 3 ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0005   ACTION 'VIEWDEF.PRAA902' OPERATION 4 ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0006   ACTION 'VIEWDEF.PRAA902' OPERATION 5 ACCESS 0    // 'Excluir'
	ADD OPTION aRotina TITLE STR0007   ACTION 'VIEWDEF.PRAA902' OPERATION 8 ACCESS 0    // 'Imprimir'
	ADD OPTION aRotina TITLE STR0008   ACTION 'VIEWDEF.PRAA902' OPERATION 9 ACCESS 0    // 'Copiar'

Return aRotina

Function PRAA902POS(oModel)
   Local cSQL := FwfldGet('DBQ_SQL')
   Local nRetorno := 0

   nRetorno += AT("INSERT", upper(cSQL))
   nRetorno += AT("DELETE", upper(cSQL))
   nRetorno += AT("UPDATE", upper(cSQL))
   nRetorno += AT("CREATE", upper(cSQL))
   nRetorno += AT("ALTER",  upper(cSQL))
   nRetorno += AT("DROP",   upper(cSQL))

   if nRetorno > 0
      oModel:SetErrorMessage('DBQMASTER', 'DBQ_SQL',,,,STR0011 )
      return .F.
   endif

return .T.
