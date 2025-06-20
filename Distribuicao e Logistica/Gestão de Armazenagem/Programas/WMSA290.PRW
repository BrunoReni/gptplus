#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA290.CH'

//----------------------------------------------------------
/*/{Protheus.doc} WMSA290 - Cadastro de Ocorr�ncias

@author  SIGAWMS
@version P11
@since   06/03/15
/*/
//----------------------------------------------------------
Function WMSA290()
Local oBrowse
	If AMiIn(39,42) // Somente autorizado para OMS e WMS
		Pergunte('WMSA290',.F.)

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('DCM')         // Apresenta as informa��es no browse por recurso humano
		oBrowse:SetDescription(STR0001) // Descri��o do browse "Cadastro de Ocorr�ncias"
		oBrowse:SetMenuDef('WMSA290')   // Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetAmbiente(.F.)        // Desabilita op��o Ambiente do menu A��es Relacionadas
		oBrowse:SetWalkThru(.F.)        // Desabilita op��o WalkThru do menu A��es Relacionadas
		oBrowse:Activate()
	EndIf
Return
//----------------------------------------------------------
// Fun��o MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0007 ACTION 'AxPesqui' OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA290' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA290' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA290' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA290' OPERATION 5 ACCESS 0 // Excluir
	// Ponto de entrada utilizado para inserir novas op��es no array aRotina
	If ExistBlock("DLG290MNU")
		ExecBlock("DLG290MNU",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// Fun��o ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA290')
Local oStruDCM := FWFormStruct(1, 'DCM')
	oModel:AddFields('DCMMASTER', /*cOwner*/, oStruDCM)
	oModel:SetPrimaryKey( { 'DCM_OCORRE' } )
Return oModel
//----------------------------------------------------------
// Fun��o ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA290')
Local oView    := FWFormView():New()
Local oStruDCM := FWFormStruct(2, 'DCM')
	oView:SetModel(oModel)
	oView:AddField('VIEWDCM', oStruDCM, 'DCMMASTER')
Return oView