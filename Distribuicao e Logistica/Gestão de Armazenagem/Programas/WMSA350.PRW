#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA350.CH'

//----------------------------------------------------------
/*/{Protheus.doc} WMSA350 - Regras para Convoca��o WMS

@author  Guilherme Alexandre Metzger
@version P11
@since   24/02/15
/*/
//----------------------------------------------------------
Function WMSA350()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('DCQ')         //Alias da tabela utilizada
	oBrowse:SetDescription(STR0001) //Descri��o do browse "Regras para Convoca��o WMS"
	oBrowse:SetMenuDef('WMSA350')   //Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetAmbiente(.F.)        //Desabilita op��o Ambiente do menu A��es Relacionadas
	oBrowse:SetWalkThru(.F.)        //Desabilita op��o WalkThru do menu A��es Relacionadas

	// Adiciona as legendas do browse
	oBrowse:AddLegend("DCQ_STATUS=='1'", 'GREEN', STR0008) // Ativo
	oBrowse:AddLegend("DCQ_STATUS=='2'", 'RED'  , STR0009) // Inativo

	oBrowse:Activate()
Return

//----------------------------------------------------------
// Fun��o MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0011 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA350' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA350' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA350' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.WMSA350' OPERATION 5 ACCESS 0 // Excluir

	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock('WMS350MNU')
		ExecBlock('WMS350MNU',.F.,.F.)
	EndIf
Return aRotina

//----------------------------------------------------------
// Fun��o ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA350',/*bPreValid*/,{ |oModel| PosVldMdl(oModel) })
Local oStruDCQ := FWFormStruct(1, 'DCQ')
	oModel:AddFields('DCQMASTER', /*cOwner*/, oStruDCQ)
	oModel:SetPrimaryKey({'DCQ_FILIAL','DCQ_TPREGR','DCQ_STATUS','DCQ_LOCAL','DCQ_CODFUN','DCQ_CODZON','DCQ_SERVIC','DCQ_TAREFA','DCQ_ATIVID'})
Return oModel

//----------------------------------------------------------
// Fun��o ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA350')
Local oView    := FWFormView():New()
Local oStruDCQ := FWFormStruct(2, 'DCQ')
	oView:SetModel(oModel)
	oView:AddField('VIEWDCQ', oStruDCQ, 'DCQMASTER')
Return oView

//----------------------------------------------------------
// Fun��o de p�s-valida��o do Model
//----------------------------------------------------------
Static Function PosVldMdl(oModel)
Local nOp     := oModel:GetOperation()
Local lRet    := .T.
Local lExiste := .F.
	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE
		// N�o permite que seja gravado registro duplicado
		If oModel:GetValue('DCQMASTER','DCQ_TPREGR') == '1' .And.; // Limita��o
			(nOp == MODEL_OPERATION_INSERT .Or. (nOp == MODEL_OPERATION_UPDATE .And.;
			(oModel:IsFieldUpdated('DCQMASTER','DCQ_STATUS') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_LOCAL' ) .Or.;
			 oModel:IsFieldUpdated('DCQMASTER','DCQ_CODFUN') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_CODZON') .Or.;
			 oModel:IsFieldUpdated('DCQMASTER','DCQ_SERVIC') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_TAREFA') .Or.;
			 oModel:IsFieldUpdated('DCQMASTER','DCQ_ATIVID'))))
			
			DCQ->(DbSetOrder(1))
			lExiste := DCQ->(DbSeek(xFilial('DCQ')+oModel:GetValue('DCQMASTER','DCQ_TPREGR')+oModel:GetValue('DCQMASTER','DCQ_STATUS')+oModel:GetValue('DCQMASTER','DCQ_LOCAL')+oModel:GetValue('DCQMASTER','DCQ_CODFUN')+oModel:GetValue('DCQMASTER','DCQ_CODZON')+oModel:GetValue('DCQMASTER','DCQ_SERVIC')+oModel:GetValue('DCQMASTER','DCQ_TAREFA')+oModel:GetValue('DCQMASTER','DCQ_ATIVID')))
		ElseIf oModel:GetValue('DCQMASTER','DCQ_TPREGR') == '2' .And.; // Sequ�ncia
				(nOp == MODEL_OPERATION_INSERT .Or. (nOp == MODEL_OPERATION_UPDATE .And.;
				(oModel:IsFieldUpdated('DCQMASTER','DCQ_STATUS') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_LOCAL' ) .Or.;
				 oModel:IsFieldUpdated('DCQMASTER','DCQ_SERVIC') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_TAREFA') .Or.;
				 oModel:IsFieldUpdated('DCQMASTER','DCQ_ATIVID') .Or. oModel:IsFieldUpdated('DCQMASTER','DCQ_ENDINI') .Or.;
				 oModel:IsFieldUpdated('DCQMASTER','DCQ_ENDFIM'))))
			DCQ->(DbSetOrder(3))
			lExiste := DCQ->(DbSeek(xFilial('DCQ')+oModel:GetValue('DCQMASTER','DCQ_TPREGR')+oModel:GetValue('DCQMASTER','DCQ_STATUS')+oModel:GetValue('DCQMASTER','DCQ_LOCAL')+oModel:GetValue('DCQMASTER','DCQ_SERVIC')+oModel:GetValue('DCQMASTER','DCQ_TAREFA')+oModel:GetValue('DCQMASTER','DCQ_ATIVID')+oModel:GetValue('DCQMASTER','DCQ_ENDINI')+oModel:GetValue('DCQMASTER','DCQ_ENDFIM')))
		
		EndIf
		If lExiste
			HELP(,,'JAGRAVADO')
			lRet := .F.
		EndIf

	EndIf
Return lRet