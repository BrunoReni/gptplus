#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA309.CH" // Utiliza o mesmo CH do VEIA309

/*/{Protheus.doc} VEIA310
	Processo: Transfer�ncia
	Tipo: Notas Fiscais
	Item: Pe�as

	@author Andre Luis Almeida
	@since 06/04/2023
/*/
Function VEIA310()
Return

Static Function MenuDef()
	Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Defini��o do Model

@author Andre Luis Almeida
@since 06/04/2023
@Return oModel
/*/
Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ") // Execu��es
Local oStrTOT := FWFormStruct(1,"VFJ") // Custos Totais
Local oStrVFQ := FWFormStruct(1,"VFQ") // Pe�as De
Local oStrVFN := FWFormStruct(1,"VFN") // Pe�as Para
Local oStrVFK := FWFormStruct(1,"VFK") // NFs Saida
Local oStrVFL := FWFormStruct(1,"VFL") // NFs Entrada

oStrVFQ:AddField(;
		"",; // cTitulo
		'',; // cTooltip
		'EVENTO',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('TVFQ')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFN:AddField(;
		"",; // cTitulo
		'',; // cTooltip
		'EVENTO',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('TVFN')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFK:AddField(;
		"",; // cTitulo
		'',; // cTooltip
		'EVENTO',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('VFK')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFL:AddField(;
		"",; // cTitulo
		'',; // cTooltip
		'EVENTO',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('VFL')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t.)
oStrVFJ:SetProperty('VFJ_VV1002',MODEL_FIELD_OBRIGAT, .t.)

oStrVFQ:SetProperty('VFQ_VEIMAQ',MODEL_FIELD_WHEN,{|| .f. })
oStrVFQ:SetProperty('VFQ_VEIMAQ',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"1"))

oStrVFN:SetProperty('VFN_VEIMAQ',MODEL_FIELD_WHEN,{|| .f. })
oStrVFN:SetProperty('VFN_VEIMAQ',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"2"))

oStrVFN:SetProperty('VFN_GRUITE',MODEL_FIELD_WHEN,{|| .f. })
oStrVFN:SetProperty('VFN_CODITE',MODEL_FIELD_WHEN,{|| .f. })
oStrVFN:SetProperty('VFN_QUANT' ,MODEL_FIELD_WHEN,{|| .f. })

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MAR001","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MOD001","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_CHA001","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1002","VFJ_MAR002","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1002')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1002","VFJ_MOD002","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1002')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1002","VFJ_CHA002","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1002')") )

VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CODSB1","SB1->B1_COD",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_TIPOPE",'SPACE(GetSX3Cache("VFQ_TIPOPE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CODTES","SB1->B1_TE",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CENCUS","SB1->B1_CC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CONTA","SB1->B1_CONTA",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_ITEMCT","SB1->B1_ITEMCC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CLVL","SB1->B1_CLVL",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_DESITE","SB1->B1_DESC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_PESQB1",'SPACE(GetSX3Cache("VFQ_PESQB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODITE",'SPACE(GetSX3Cache("VFQ_CODITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODSB1",'SPACE(GetSX3Cache("VFQ_CODSB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_DESITE",'SPACE(GetSX3Cache("VFQ_DESITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_TIPOPE",'SPACE(GetSX3Cache("VFQ_TIPOPE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODTES",'SPACE(GetSX3Cache("VFQ_CODTES", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CENCUS",'SPACE(GetSX3Cache("VFQ_CENCUS", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CONTA",'SPACE(GetSX3Cache("VFQ_CONTA", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_ITEMCT",'SPACE(GetSX3Cache("VFQ_ITEMCT", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CLVL",'SPACE(GetSX3Cache("VFQ_CLVL", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODTES","VFQ_TIPOPE",'SPACE(GetSX3Cache("VFQ_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODTES","VFN_TIPOPE",'SPACE(GetSX3Cache("VFN_TIPOPE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODSB1","VFN_GRUITE","SB1->B1_GRUPO",.T.,"SB1",1,"xFilial('SB1')+FWFldGet('VFN_CODSB1')"))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODSB1","VFN_CODITE","SB1->B1_CODITE",.T.,"SB1",1,"xFilial('SB1')+FWFldGet('VFN_CODSB1')"))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODSB1","VFN_DESITE","SB1->B1_DESC",.T.,"SB1",1,"xFilial('SB1')+FWFldGet('VFN_CODSB1')"))

VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODVEN","VFK_NOMVEN",'Left(SA3->A3_NOME,GetSX3Cache("VFK_NOMVEN", "X3_TAMANHO"))',.T.,"SA3",1,"xFilial('SA3')+FWFldGet('VFK_CODVEN')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_FORPAG","VFK_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFK_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFK_FORPAG')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODTES","VFK_TIPOPE",'SPACE(GetSX3Cache("VFK_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_FORPAG","VFL_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFL_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFL_FORPAG')") )
VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_CODTES","VFL_TIPOPE",'SPACE(GetSX3Cache("VFL_TIPOPE", "X3_TAMANHO"))',.F.,,,))

oModel := MPFormModel():New("VEIA310", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFQDETAIL" , "VFJMASTER", oStrVFQ , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFQDETAIL", {{'VFQ_FILIAL','VFJ_FILIAL'}, {'VFQ_CODEXE','VFJ_CODIGO'}}, VFQ->(IndexKey(2)) )
oModel:AddGrid( "VFNDETAIL" , "VFJMASTER", oStrVFN , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFNDETAIL", {{'VFN_FILIAL','VFJ_FILIAL'}, {'VFN_CODEXE','VFJ_CODIGO'}}, VFN->(IndexKey(2)) )
oModel:AddGrid( "VFKDETAIL" , "VFJMASTER", oStrVFK , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFKDETAIL", {{'VFK_FILIAL','VFJ_FILIAL'}, {'VFK_CODEXE','VFJ_CODIGO'}}, VFK->(IndexKey(2)) )
oModel:AddGrid( "VFLDETAIL" , "VFJMASTER", oStrVFL , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFLDETAIL", {{'VFL_FILIAL','VFJ_FILIAL'}, {'VFL_CODEXE','VFJ_CODIGO'}}, VFL->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0001) // Transfer�ncia com Notas Fiscais
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFQDETAIL"):SetDescription(STR0009+" - "+STR0003) // Pe�as / Desagrega
oModel:GetModel("VFQDETAIL"):SetOptional(.f.) // N�o deixa passar em branco
oModel:GetModel("VFNDETAIL"):SetDescription(STR0009+" - "+STR0004) // Pe�as / Agrega
oModel:GetModel("VFNDETAIL"):SetOptional(.f.) // N�o deixa passar em branco
oModel:GetModel("VFKDETAIL"):SetDescription(STR0005) // Notas Fiscais de Saida
oModel:GetModel("VFKDETAIL"):SetOptional(.f.) // N�o deixa passar em branco
oModel:GetModel("VFLDETAIL"):SetDescription(STR0006) // Notas Fiscais de Entrada
oModel:GetModel("VFLDETAIL"):SetOptional(.f.) // N�o deixa passar em branco

oModel:GetModel("VFNDETAIL"):SetUniqueLine({"VFN_CODSB1"}) // Somente 1 linha por SB1
oModel:GetModel("VFQDETAIL"):SetUniqueLine({"VFQ_CODSB1"}) // Somente 1 linha por SB1
oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para N�O SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0001) // Transfer�ncia com Notas Fiscais
//oModel:InstallEvent("VEIA310LOG", /*cOwner*/, MVCLOGEV():New("VEIA310") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos est�o no VEIA300EVDEF

Return oModel

/*/{Protheus.doc} ViewDef
Defini��o do interface

@author Andre Luis Almeida
@since 06/04/2023
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ", { |cCampo| !ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Execu��es
Local oStrTOT:= FWFormStruct(2,"VFJ", { |cCampo|  ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Totais
Local oStrVFQ:= FWFormStruct(2,"VFQ", { |cCampo| !ALLTRIM(cCampo) $ "VFQ_CODIGO/VFQ_CODEXE/VFQ_CODSB1/VFQ_REFSAI/" } ) // Pe�as De
Local oStrVFN:= FWFormStruct(2,"VFN", { |cCampo| !ALLTRIM(cCampo) $ "VFN_CODIGO/VFN_CODEXE/VFN_CODSB1/VFN_PESQB1/" } ) // Pe�as Para
Local oStrVFK:= FWFormStruct(2,"VFK", { |cCampo| !ALLTRIM(cCampo) $ "VFK_CODIGO/VFK_CODEXE/" } ) // NFs Saida
Local oStrVFL:= FWFormStruct(2,"VFL", { |cCampo| !ALLTRIM(cCampo) $ "VFL_CODIGO/VFL_CODEXE/" } ) // NFs Entrada

oStrVFQ:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFN:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFK:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFL:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFQ', oStrVFQ, 'VFQDETAIL' ) // Pe�as De
oView:AddGrid( 'VIEW_VFN', oStrVFN, 'VFNDETAIL' ) // Pe�as Para
oView:AddGrid( 'VIEW_VFK', oStrVFK, 'VFKDETAIL' ) // NFs Saida
oView:AddGrid( 'VIEW_VFL', oStrVFL, 'VFLDETAIL' ) // NFs Entrada

// defini��o de como ser� a tela
oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 60)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_NFS',STR0007) // Dados para gera��o das Notas Fiscais
oView:AddSheet('FOLDER','FOLD_VFQ',STR0009+" - "+STR0003) // Pe�as / Desagrega
oView:AddSheet('FOLDER','FOLD_VFN',STR0009+" - "+STR0004) // Pe�as / Agrega

oView:CreateHorizontalBox( 'BOXNF1', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXNF2', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXVFQ',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFQ')
oView:CreateHorizontalBox( 'BOXVFN',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFN')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFK' , 'BOXNF1' ) // NFs Saida
oView:SetOwnerView( 'VIEW_VFL' , 'BOXNF2' ) // NFs Entrada
oView:SetOwnerView( 'VIEW_VFQ' , 'BOXVFQ' ) // Pe�as De
oView:SetOwnerView( 'VIEW_VFN' , 'BOXVFN' ) // Pe�as Para

oView:SetNoInsertLine('VIEW_VFN') // Pe�as Para - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFN') // Pe�as Para - Nao Deletar Linhas

oView:SetNoInsertLine('VIEW_VFK') // NFs Saida - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFK') // NFs Saida - Nao Deletar Linhas

oView:SetNoInsertLine('VIEW_VFL') // NFs Entrada - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFL') // NFs Entrada - Nao Deletar Linhas

oView:AddUserButton(STR0008,'CLIPS',{ |oView| VA3000131_LegendaEvento("3") }) // Legenda Eventos

Return oView