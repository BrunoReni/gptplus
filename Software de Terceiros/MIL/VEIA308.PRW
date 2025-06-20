#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA303.CH" // Utiliza o mesmo CH do VEIA303

/*/{Protheus.doc} VEIA308
	Processo: Desagrega (Individual)
	Tipo: Movimenta��es Internas
	Item: Pe�as

	@author Andre Luis Almeida
	@since 13/03/2023
/*/
Function VEIA308()
Return

Static Function MenuDef()
	Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Defini��o do Model

@author Andre Luis Almeida
@since 13/03/2023
@Return oModel
/*/
Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ") // Execu��es
Local oStrTOT := FWFormStruct(1,"VFJ") // Custos Totais
Local oStrVFQ := FWFormStruct(1,"VFQ") // Pe�as
Local oStrVFO := FWFormStruct(1,"VFO") // Movimenta��es Internas

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t. )

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MAR001","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MOD001","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_CHA001","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )

VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CODSB1","SB1->B1_COD",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')") )
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CENCUS","SB1->B1_CC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CONTA","SB1->B1_CONTA",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_ITEMCT","SB1->B1_ITEMCC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CLVL","SB1->B1_CLVL",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_DESITE","SB1->B1_DESC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_PESQB1",'SPACE(GetSX3Cache("VFQ_PESQB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_PESQB1",'SPACE(GetSX3Cache("VFQ_PESQB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODITE",'SPACE(GetSX3Cache("VFQ_CODITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODSB1",'SPACE(GetSX3Cache("VFQ_CODSB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_DESITE",'SPACE(GetSX3Cache("VFQ_DESITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CENCUS",'SPACE(GetSX3Cache("VFQ_CENCUS", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CONTA",'SPACE(GetSX3Cache("VFQ_CONTA", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_ITEMCT",'SPACE(GetSX3Cache("VFQ_ITEMCT", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CLVL",'SPACE(GetSX3Cache("VFQ_CLVL", "X3_TAMANHO"))',.F.,,,))

oModel := MPFormModel():New("VEIA308", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFQDETAIL" , "VFJMASTER", oStrVFQ , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFQDETAIL", {{'VFQ_FILIAL','VFJ_FILIAL'}, {'VFQ_CODEXE','VFJ_CODIGO'}}, VFQ->(IndexKey(2)) )
oModel:AddGrid( "VFODETAIL" , "VFJMASTER", oStrVFO , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFODETAIL", {{'VFO_FILIAL','VFJ_FILIAL'}, {'VFO_CODEXE','VFJ_CODIGO'}}, VFO->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0006) // Desagrega (Individual) com Movimenta��es Internas
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFQDETAIL"):SetDescription(STR0005) // Pe�as
oModel:GetModel("VFQDETAIL"):SetOptional(.f.) // N�o deixa passar em branco
oModel:GetModel("VFODETAIL"):SetDescription(STR0003) // Movimenta��es Internas
oModel:GetModel("VFODETAIL"):SetOptional(.f.) // N�o deixa passar em branco

oModel:GetModel("VFQDETAIL"):SetUniqueLine({"VFQ_CODSB1"}) // Somente 1 linha por SB1
oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para N�O SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0006) // Desagrega (Individual) com Movimenta��es Internas
//oModel:InstallEvent("VEIA308LOG", /*cOwner*/, MVCLOGEV():New("VEIA308") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos est�o no VEIA300EVDEF

Return oModel

/*/{Protheus.doc} ViewDef
Defini��o do interface

@author Andre Luis Almeida
@since 13/03/2023
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ", { |cCampo| !ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_VV1002/VFJ_MAR002/VFJ_MOD002/VFJ_CHA002/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Execu��es
Local oStrTOT:= FWFormStruct(2,"VFJ", { |cCampo|  ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/" } ) // Totais
Local oStrVFQ:= FWFormStruct(2,"VFQ", { |cCampo| !ALLTRIM(cCampo) $ "VFQ_CODIGO/VFQ_CODEXE/VFQ_CODSB1/VFQ_TIPOPE/VFQ_CODTES/VFQ_REFSAI/VFQ_VEIMAQ/" } ) // Pe�as
Local oStrVFO:= FWFormStruct(2,"VFO", { |cCampo| !ALLTRIM(cCampo) $ "VFO_CODIGO/VFO_CODEXE/" } ) // Movimenta��es Internas

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFQ', oStrVFQ, 'VFQDETAIL' ) // Pe�as
oView:AddGrid( 'VIEW_VFO', oStrVFO, 'VFODETAIL' ) // Movimenta��es Internas

// defini��o de como ser� a tela
oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 60)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_VFO',STR0004) // Dados para gera��o das Movimenta��es Internas
oView:AddSheet('FOLDER','FOLD_VFQ',STR0005) // Pe�as

oView:CreateHorizontalBox( 'BOXVFO',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFO')
oView:CreateHorizontalBox( 'BOXVFQ',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFQ')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFO' , 'BOXVFO' ) // Movimenta��es Internas
oView:SetOwnerView( 'VIEW_VFQ' , 'BOXVFQ' ) // Pe�as

oView:SetNoInsertLine('VIEW_VFO') // Movimenta��es Internas - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFO') // Movimenta��es Internas - Nao Deletar Linhas

Return oView