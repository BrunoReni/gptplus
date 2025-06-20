#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA130.CH'

#DEFINE WMSA13001 "WMSA13001"

//----------------------------------------------------------
/*/{Protheus.doc} WMSA130 - Recursos Humanos

@author  SIGAWMS
@version P11
@since   03/03/15
/*/
//----------------------------------------------------------
Function WMSA130()
Local oBrowse

	If AMiIn(39,42) // Somente autorizado para OMS e WMS
		Pergunte('DLA130',.F.)
		oBrowse := FWMBrowse():New()
		If MV_PAR01 == 1
			oBrowse:SetAlias('DCD') // Apresenta as informa��es no browse por recurso humano
		Else
			oBrowse:SetAlias('DCI') // Apresenta as informa��es no browse por fun��o
		EndIf

		oBrowse:SetDescription(STR0001)               // Descri��o do browse "Recursos Humanos"
		oBrowse:SetMenuDef('WMSA130')                 // Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetParam({|| Pergunte('DLA130',.T.)}) // Defini��o da fun��o chamada ao pressionar tecla F12
		oBrowse:SetAmbiente(.F.)                      // Desabilita op��o Ambiente do menu A��es Relacionadas
		oBrowse:SetWalkThru(.F.)                      // Desabilita op��o WalkThru do menu A��es Relacionadas
		oBrowse:Activate()
	EndIf
Return
//----------------------------------------------------------
// Fun��o MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0008 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA130' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA130' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA130' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA130' OPERATION 5 ACCESS 0 // Excluir

	//Ponto de entrada utilizado para inserir novas op��es no array aRotina
	If ExistBlock("DLG130MNU")
		ExecBlock("DLG130MNU",.F.,.F.)
	EndIf
Return(aRotina)
//----------------------------------------------------------
// Fun��o ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA130')
Local oStruDCD := FWFormStruct(1,'DCD')
Local oStruDCI := FWFormStruct(1,'DCI')
	
	oStruDCD:SetProperty('DCD_CODFUN', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,'NaoVazio() .And. ExistChav("DCD",M->DCD_CODFUN,1) .And. StaticCall(WMSA130,ValidField,A,B,C)'))
	
	oModel:SetDescription(STR0001) // Recursos Humanos
	// Adicionando ao modelo um componente de formul�rio
	oModel:AddFields('DCDMASTER', /*cOwner*/, oStruDCD)
	// Remove obrigatoriedade do campo, pois ele ser� preenchido automaticamente no commit
	oStruDCI:SetProperty("DCI_CODFUN",MODEL_FIELD_OBRIGAT,.F.)
	// Adicionando ao modelo um componente de grid
	oModel:AddGrid('DCIDETAIL', 'DCDMASTER', oStruDCI)
	// Cria��o de rela��o entre as entidades do modelo
	oModel:SetRelation('DCIDETAIL', { { 'DCI_FILIAL', 'xFilial( "DCI" )' }, { 'DCI_CODFUN', 'DCD_CODFUN' } }, DCI->( IndexKey( 1 ) ) )
	// Define valida��o de linha duplicada para o grid
	oModel:GetModel('DCIDETAIL'):SetUniqueLine({'DCI_FUNCAO'})
Return oModel
//----------------------------------------------------------
// Fun��o ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA130')
Local oView    := FWFormView():New()
Local oStruDCD := FWFormStruct(2,'DCD')
Local oStruDCI := FWFormStruct(2,'DCI')
	oView:SetModel(oModel)
	// Criando o componente de formul�rio na interface
	oView:AddField('VIEWDCD', oStruDCD, 'DCDMASTER')
	//Remove campos repetidos
	oStruDCI:RemoveField('DCI_CODFUN')
	oStruDCI:RemoveField('DCI_NOMFUN')
	// Criando o componente de grid na interface
	oView:AddGrid('VIEWDCI', oStruDCI, 'DCIDETAIL')
	// Cria��o dos conteiners para exibi��o dos dados na interface
	oView:CreateHorizontalBox('SUPERIOR', 20)
	oView:CreateHorizontalBox('INFERIOR', 80)
	// Relacionando o componente da interface
	oView:SetOwnerView('VIEWDCD', 'SUPERIOR')
	oView:SetOwnerView('VIEWDCI', 'INFERIOR')
Return oView
//----------------------------------------------------------
// Fun��o de valida��o dos campos
//----------------------------------------------------------
Static Function ValidField(oModel,cField,xValue)
Local aAreaAnt := GetArea()
Local lRet     := .T.
	If cField == 'DCD_CODFUN'
		PswOrder(1)
		If !PswSeek(xValue,.T.)
			oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,,,WMSA13001,STR0006,STR0007) // C�digo de usu�rio n�o existe. // Verifique o c�digo informado.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
