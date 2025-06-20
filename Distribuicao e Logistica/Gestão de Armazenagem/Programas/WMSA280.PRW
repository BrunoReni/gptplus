#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA280.CH'

//----------------------------------------------------------
/*/{Protheus.doc} WMSA280 - Cadastro de Exce��es de Atividades

@author  SIGAWMS
@version P11
@since   04/03/15
/*/
//----------------------------------------------------------
Function WMSA280()
Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DCL')
	oBrowse:SetDescription(STR0001) // Descri��o do browse "Cadastro de Exce��es de Atividades"
	oBrowse:SetMenuDef('WMSA280')   // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetAmbiente(.F.)        // Desabilita op��o Ambiente do menu A��es Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita op��o WalkThru do menu A��es Relacionadas
	oBrowse:Activate()
Return
//----------------------------------------------------------
// Fun��o MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA280' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA280' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA280' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA280' OPERATION 5 ACCESS 0 // Excluir
	// Ponto de entrada utilizado para inserir novas op��es no array aRotina
	If ExistBlock("DLG280MNU")
		ExecBlock("DLG280MNU",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// Fun��o ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local aCposCab  := {'DCL_CODIGO', 'DCL_DESCOD'} // Campos que nao devem ser exibidos na Grid
Local oModel
Local oStruDCLM
Local oStruDCLD

	oStruDCLM := FWFormStruct(1, 'DCL', { |cCampo| AllTrim(cCampo) == "DCL_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) )  > 0 })
	oStruDCLD := FWFormStruct(1, 'DCL', { |cCampo| AllTrim(cCampo) == "DCL_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) == 0 })

	oModel := MPFormModel():New('WMSA280')
	oModel:SetDescription(STR0001) // Cadastro de Exce��es de Atividades
	// Adicionando ao modelo um componente de formul�rio
	oModel:AddFields('DCLMASTER', /*cOwner*/, oStruDCLM)
	// Adicionando ao modelo um componente de grid
	oModel:AddGrid('DCLDETAIL', 'DCLMASTER', oStruDCLD)
	// Define valida��o de linha duplicada para o grid
	oModel:GetModel('DCLDETAIL'):SetUniqueLine({'DCL_ATIVID'})
	// Cria��o de rela��o entre as entidades do modelo
	oModel:SetRelation('DCLDETAIL', { { 'DCL_FILIAL', 'xFilial( "DCL" )' }, { 'DCL_CODIGO', 'DCL_CODIGO' }, { 'DCL_DESCOD', 'DCL_DESCOD' }  }, DCL->( IndexKey( 1 ) ) )
	// Definindo a chave prim�ria do modelo
	oModel:SetPrimaryKey( { 'DCL_FILIAL', 'DCL_CODIGO', 'DCL_ORDEM' } )
Return oModel
//----------------------------------------------------------
// Fun��o ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local aCposCab := {'DCL_CODIGO', 'DCL_DESCOD'} // Campos que nao devem ser exibidos na Grid
Local oModel   := FWLoadModel('WMSA280')
Local oView    := FWFormView():New()
Local oStruDCLM
Local oStruDCLD

	oStruDCLM := FWFormStruct(2, 'DCL', { |cCampo| AllTrim(cCampo) == "DCL_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) )  > 0 })
	oStruDCLD := FWFormStruct(2, 'DCL', { |cCampo| AllTrim(cCampo) == "DCL_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) == 0 })

	oView:SetModel(oModel)
	// Criando o componente de formul�rio na interface
	oView:AddField('VIEWDCLM', oStruDCLM, 'DCLMASTER')
	// Criando o componente de grid na interface
	oView:AddGrid('VIEWDCLD', oStruDCLD, 'DCLDETAIL')
	oView:AddIncrementField('VIEWDCLD', 'DCL_ORDEM')
	// Cria��o dos conteiners para exibi��o dos dados na interface
	oView:CreateHorizontalBox('SUPERIOR', 20)
	oView:CreateHorizontalBox('INFERIOR', 80)
	// Relacionando o componente da interface
	oView:SetOwnerView('VIEWDCLM', 'SUPERIOR')
	oView:SetOwnerView('VIEWDCLD', 'INFERIOR')
Return oView