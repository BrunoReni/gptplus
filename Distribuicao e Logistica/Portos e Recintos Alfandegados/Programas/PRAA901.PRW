#INCLUDE "PRAA901.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PRAA901 
Metodo construtor da classe
@author   Felipe Machado de Oliveira
@version  P12
@since    02/07/2012
@obs      Cadastro de Parâmetros para Consulta Dinâmica
/*/

Function PRAA901()
	Local oBrowse

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias('DBP')
	oBrowse:SetDescription(STR0001)
	oBrowse:Activate()

Return nil

Static Function ModelDef()
	Local oStructDBP := FWFormStruct(1,'DBP',nil, nil)
	Local oModel

	oModel := MPFormModel():New('PRAA901', , {|oModel|PRAA901POS(oModel)})
	oModel:AddFields('DBPMASTER', , oStructDBP )
	oModel:SetDescription(STR0009)
	oModel:GetModel('DBPMASTER'):SetDescription(STR0010)

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('PRAA901')
	Local oStructDBP := FWFormStruct(2,'DBP')
	Local oView

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_DBP', oStructDBP, 'DBPMASTER')
	oView:CreateHorizontalBOX('TELA',100)
	oView:SetOwnerView('VIEW_DBP','TELA')


Return oView

Static Function MenuDef()
  Local aRotina := {}

  ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 // 'Pesquisar'
  ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.PRAA901' OPERATION 2 ACCESS 0 // 'Visualizar'
  ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.PRAA901' OPERATION 3 ACCESS 0 // 'Incluir'
  ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.PRAA901' OPERATION 4 ACCESS 0 // 'Alterar'
  ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.PRAA901' OPERATION 5 ACCESS 0 // 'Excluir'
  ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.PRAA901' OPERATION 8 ACCESS 0 // 'Imprimir'
  ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.PRAA901' OPERATION 9 ACCESS 0 // 'Copiar'

RETURN aRotina

FUNCTION PRAA901POS(oModel)
	Local nOperation := oModel:GetOperation()
	Local cSql := Upper(FwFldGet('DBP_SQL'))
	Local nRetorno := 0

	IF nOperation ==3 .OR. nOperation==4
		nRetorno += At('UPDATE',cSql)
		nRetorno += At('DELETE',cSql)
		nRetorno += At('INSERT',cSql)
		nRetorno += At('DROP',cSql)
		nRetorno += At('CREATE',cSql)
		nRetorno += At('ALTER',cSql)
	ENDIF

	IF nRetorno > 0
		oModel:SetErrorMessage('DBPMASTER', 'DBP_SQL',,,,STR0011 )
		RETURN .F.
	ENDIF

RETURN .T.
