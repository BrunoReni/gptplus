#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA460.CH"

/*/{Protheus.doc} OFIA460
	Entrada de Serviços Especializados

	@author Andre Luis Almeida
	@since 02/09/2022
/*/
Function OFIA460()
Local aSize       := FWGetDialogSize( oMainWnd )
Local nTamNFI     := GeTSX3Cache("VRP_NUMNFI","X3_TAMANHO")
Private cCadastro := STR0001 // Entrada de Serviços Especializados
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
	
oDlgOA460 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oBrwVRP := FWMBrowse():New()
oBrwVRP:SetAlias('VRP')
oBrwVRP:SetDescription(cCadastro)
oBrwVRP:SetOwner(oDlgOA460)
oBrwVRP:AddLegend( 'VRP->VRP_STATUS == "0"' , 'BR_BRANCO'   , STR0002 ) // Entrada Digitada
oBrwVRP:AddLegend( 'VRP->VRP_STATUS == "1"' , 'BR_VERDE'    , STR0003 ) // Entrada Efetivada
oBrwVRP:AddLegend( 'VRP->VRP_STATUS == "2"' , 'BR_VERMELHO' , STR0004 ) // Entrada Cancelada
oBrwVRP:AddFilter(STR0005, "@ VRP_NUMNFI <> '"+space(nTamNFI)+"'") // Com Nota Fiscal
oBrwVRP:AddFilter(STR0006, "@ VRP_NUMNFI = '"+space(nTamNFI)+"'") // Sem Nota Fiscal
oBrwVRP:DisableDetails()
oBrwVRP:DisableLocate()
oBrwVRP:SetAmbiente(.F.)
oBrwVRP:SetWalkthru(.F.)
oBrwVRP:SetUseFilter()
oBrwVRP:ForceQuitButton()
oBrwVRP:Activate()

oDlgOA460:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0007 ACTION 'OA4600041_VisualizarEntrada()' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.OFIA460' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.OFIA460' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0010 ACTION 'OA4600031_CancelarEntrada()' OPERATION 5 ACCESS 0 // Cancelar
	ADD OPTION aRotina TITLE STR0011 ACTION 'OA4600061_BancoConhecimento()' OPERATION 4 ACCESS 0 // Banco de Conhecimento
	ADD OPTION aRotina TITLE STR0012 ACTION 'OA4600101_ImprimirEntrada()' OPERATION 8 ACCESS 0 // Imprimir Dados da Entrada

Return aRotina


Static Function ModelDef()
Local oStrVRP := FWFormStruct(1,"VRP")
Local oStrVRQ := FWFormStruct(1,"VRQ")

oModel := MPFormModel():New("OFIA460", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )

oModel:AddFields("VRPMASTER",/*cOwner*/ , oStrVRP)
oModel:AddGrid( "VRQDETAIL" , "VRPMASTER", oStrVRQ , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VRQDETAIL", {{'VRQ_FILIAL','VRP_FILIAL'}, {'VRQ_CODVRP','VRP_CODIGO'}}, VRQ->(IndexKey(1)) )

oModel:GetModel("VRPMASTER"):SetDescription(STR0001) // Entrada de Serviços Especializados
oModel:GetModel("VRQDETAIL"):SetDescription(STR0013) // Serviços Especializados
oModel:GetModel("VRQDETAIL"):SetOptional(.f.) // Não deixa passar com os Serviços em branco

oModel:SetDescription(STR0001) // Entrada de Serviços Especializados
//oModel:InstallEvent("OFIA460LOG", /*cOwner*/, MVCLOGEV():New("OFIA460") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA460EVDEF", /*cOwner*/, OFIA460EVDEF():New() )

oModel:AddRules( 'VRPMASTER', 'VRP_LOJFOR', 'VRPMASTER', 'VRP_CODFOR', 3)

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 02/09/2022
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVRP:= FWFormStruct(2,"VRP", { |cCampo| !ALLTRIM(cCampo) $ "VRP_CODIGO/" } )
Local oStrVRQ:= FWFormStruct(2,"VRQ", { |cCampo| !ALLTRIM(cCampo) $ "VRQ_CODIGO/VRQ_CODVRP/" } )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VRP', oStrVRP, 'VRPMASTER' )
oView:AddGrid( 'VIEW_VRQ' , oStrVRQ, 'VRQDETAIL' )

// definição de como será a tela
oView:CreateHorizontalBox('CABEC' , 35)
oView:CreateHorizontalBox('FILHO' , 65)

oView:SetOwnerView('VIEW_VRP', 'CABEC' )
oView:SetOwnerView('VIEW_VRQ', 'FILHO')

oView:AddUserButton("<F4> "+STR0014,'PRODUTO', {|| OA4600051_VerEstoque() }) // Visualiza Estoque do Serviço Especializado posicionado
oView:AddUserButton(STR0012,'IMPRESSAO', {|| OA4600121_ValidaImpressao() }) // Imprimir Dados da Entrada

Return oView

/*/{Protheus.doc} OA4600011_GravaStatusEntrada
Grava Status da Entrada

@author Andre Luis Almeida
@since 06/09/2022
/*/
Static Function OA4600011_GravaStatusEntrada( cCodigo , cStatus )
Local oModVRP   := FWLoadModel( 'OFIA461' ) // MVC somente para atualizar o cabeçalho VRP
Default cCodigo := ""
Default cStatus := "0" // 0=Entrada Digitada
VRP->(DbSetOrder(1))
If VRP->(DbSeek(xFilial("VRP")+cCodigo))
	If cStatus <> VRP->VRP_STATUS
		// Gravar Status
		oModVRP:SetOperation( MODEL_OPERATION_UPDATE )
		If oModVRP:Activate()
			oModVRP:SetValue( "VRPMASTER" , "VRP_STATUS" , cStatus ) // 0=Entrada Digitada / 1=Entrada Efetivada / 2=Entrada Cancelada
			If oModVRP:VldData()
				oModVRP:CommitData()
			EndIf
			oModVRP:DeActivate()
		EndIf
	EndIf
EndIf
FreeObj(oModVRP)
Return

/*/{Protheus.doc} OA4600021_IncluirEntrada
Incluir a Entrada de Servicos Especializados

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4600021_IncluirEntrada( lEfetEnt )
Local lRet    := .f.
Local nCntFor := 0
Local nTotSrv := 0
Local nCntSeq := 0
Local aCabNFE := {}
Local aIteNFE := {}
Local aTemp   := {}
Local cTipMov := "0" // 0=Entrada
Local cPorMov := "0" // 0=Normal
Local cOpeMov := "0" // 0=Compra
Local aSrvMov := {}
Local cQuery  := ""
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
Default lEfetEnt := .f.
//
oProcEntr:SetRegua1(3)
oProcEntr:IncRegua1(STR0015) // Levantando Serviços...
//
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM " + RetSqlName("VRQ")
cQuery += " WHERE VRQ_FILIAL = '" + VRP->VRP_FILIAL + "'"
cQuery += "   AND VRQ_CODVRP = '" + VRP->VRP_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_= ' '"
oProcEntr:SetRegua2(FM_SQL(cQuery))
//
BEGIN TRANSACTION
	DbSelectArea("VRQ")
	DbSetOrder(2) // VRQ_FILIAL + VRQ_CODVRP
	If DbSeek( VRP->VRP_FILIAL + VRP->VRP_CODIGO )
		lRet := .t.
		Do While !VRQ->(Eof()) .and. VRQ->VRQ_FILIAL == VRP->VRP_FILIAL .and. VRQ->VRQ_CODVRP == VRP->VRP_CODIGO
			//
			oProcEntr:IncRegua2()
			//
			VPX->(DbSetOrder(1)) // VPX_FILIAL + VPX_SERINT
			VPX->(DbSeek( xFilial("VPX") + VRQ->VRQ_SERINT ))
			VPV->(DbSetOrder(1)) // VPV_FILIAL + VPV_CODTIP
			VPV->(DbSeek( xFilial("VPV") + VPX->VPX_TIPSER ))
			If VPV->VPV_CTRSLD <> "0" // Se possuir algum tipo de controle de SALDO de ESTOQUE - verificar saldo
				aAdd(aSrvMov,{ VRQ->VRQ_SERINT , VRQ->VRQ_QTDSER })
			EndIf
			//
			If !Empty(VRP->VRP_NUMNFI)
				//
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+VPV->VPV_CODSB1))
				//
				nCntSeq++
				aTemp := {}
				aAdd(aTemp,{ "D1_DOC"     , VRP->VRP_NUMNFI                       , Nil })
				aAdd(aTemp,{ "D1_SERIE"   , VRP->VRP_SERNFI                       , Nil })
				aAdd(aTemp,{ "D1_ITEM"    , strzero(nCntSeq,TamSX3("D1_ITEM")[1]) , Nil })
				aAdd(aTemp,{ "D1_COD"     , SB1->B1_COD                           , Nil })
				aAdd(aTemp,{ "D1_UM"      , SB1->B1_UM                            , Nil })
				aAdd(aTemp,{ "D1_QUANT"   , VRQ->VRQ_QTDSER                       , Nil })
				aAdd(aTemp,{ "D1_VUNIT"   , VRQ->VRQ_VLRUNI                       , Nil })
				aAdd(aTemp,{ "D1_TOTAL"   , VRQ->VRQ_QTDSER * VRQ->VRQ_VLRUNI     , Nil })
				aAdd(aTemp,{ "D1_EMISSAO" , dDataBase                             , Nil })
				aAdd(aTemp,{ "D1_TES"     , VRQ->VRQ_CODTES                       , Nil })
				aAdd(aTemp,{ "D1_LOCAL"   , SB1->B1_LOCPAD                        , Nil })
				aAdd(aIteNFE,aclone(aTemp))
				//
				nTotSrv += ( VRQ->VRQ_QTDSER * VRQ->VRQ_VLRUNI )
				//
			EndIf
			//
			dbSelectArea("VRQ")
			dbSkip()
		Enddo
		//
		If len(aIteNFE) > 0
			//
			oProcEntr:IncRegua1(STR0016) // Efetivando a Nota Fiscal de Entrada...
			oProcEntr:SetRegua2(2)
			oProcEntr:IncRegua2()
			//
			SA2->(DbSetOrder(1))
			SA2->(DbSeek( xFilial("SA2") + VRP->VRP_CODFOR + VRP->VRP_LOJFOR ))
			//
			aAdd(aCabNFE,{"F1_TIPO"   , "N"             ,Nil})
			aAdd(aCabNFE,{"F1_FORMUL" , "N"             ,Nil})
			aAdd(aCabNFE,{"F1_DOC"    , VRP->VRP_NUMNFI ,Nil})
			aAdd(aCabNFE,{"F1_SERIE"  , VRP->VRP_SERNFI ,Nil})
			aAdd(aCabNFE,{"F1_COND"   , VRP->VRP_FORPAG ,Nil})
			aAdd(aCabNFE,{"F1_EMISSAO", dDataBase       ,Nil})
			aAdd(aCabNFE,{"F1_FORNECE", VRP->VRP_CODFOR ,Nil})
			aAdd(aCabNFE,{"F1_LOJA"   , VRP->VRP_LOJFOR ,Nil})
			aAdd(aCabNFE,{"F1_VALMERC", nTotSrv         ,Nil})
			aAdd(aCabNFE,{"F1_VALBRUT", nTotSrv         ,Nil})
			aAdd(aCabNFE,{"F1_EST"    , SA2->A2_EST     ,Nil})
			aAdd(aCabNFE,{"F1_PLIQUI" , 0               ,Nil})
			aAdd(aCabNFE,{"F1_PBRUTO" , 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI1", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME1", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI2", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME2", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI3", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME3", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECI4", ""              ,Nil})
			aAdd(aCabNFE,{"F1_VOLUME4", 0               ,Nil})
			aAdd(aCabNFE,{"F1_ESPECIE", ""              ,Nil})
			aAdd(aCabNFE,{"E2_NATUREZ", SA2->A2_NATUREZ ,Nil})
			//
			lMSHelpAuto := .t.
			lMsErroAuto := .f.
			MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,aIteNFE)
			If lMsErroAuto
				DisarmTransaction()
				RollBackSX8()
				lRet := .f.
			Else
				ConfirmSx8() // Confirm do Nro NF
			EndIf
			//
		EndIf
		If lRet .and. lEfetEnt
			oProcEntr:IncRegua2()
			oProcEntr:IncRegua1(STR0017) // Atualizando Estoque dos Serviços...
			oProcEntr:SetRegua2(len(aSrvMov))
			For nCntFor := 1 to len(aSrvMov)
				oProcEntr:IncRegua2()
				cSeqMov := OFIA452( aSrvMov[nCntFor,1] , cTipMov , cPorMov , cOpeMov , aSrvMov[nCntFor,2] , VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Grava a Movimentação de Estoque do Servico Especializado
				If Empty(cSeqMov) .or. cDebugMIL == "OFIA460003"
					lRet := .f.
					DisarmTransaction()
					Exit
				EndIf
			Next
		EndIf
	EndIf
END TRANSACTION
If lRet
	OA4600011_GravaStatusEntrada( VRP->VRP_CODIGO , "1" ) // Mudar Status para 1=Entrada Efetivada
	OA4500041_AjustaCustoMedio( VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Ajusta Custo Medio dos Serviços da Entrada
EndIf
dbSelectArea("SX6")
MsRUnLock()
Return lRet

/*/{Protheus.doc} OA4600031_CancelarEntrada
Opção CANCELAR do aRotina do OFIA460 - Entrada de Servicos Especializados

@author Andre Luis Almeida
@since 06/09/2022
/*/
Function OA4600031_CancelarEntrada()
Local lRet    := .f.
Local cSeqMov := "NAOCONTROLA" // Necessario conteudo para iniciar o While
Local cTipMov := "1" // 1=Saida
Local cPorMov := "1" // 1=Por Cancelamento
Local cOpeMov := "0" // 0=Compra
Local cFilSD2 := xFilial("SD2")
Local nCntFor := 0
Local aSrvMov := {}
Local aCabNFE := {}
Local aIteNFE := {}
Local aTemp   := {}
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
If VRP->VRP_STATUS == "2" // 2=Entrada Cancelada
	Help("",1,"OA4600031_CancelarEntrada",,STR0018,1,0) // Entrada já Cancelada. Impossível continuar.
Else
	If MsgNoYes(STR0019,STR0020) // Confirma o Cancelamento da Entrada? / Atenção
		lRet := .t.
		BEGIN TRANSACTION
		If VRP->VRP_STATUS == "1" // 1=Entrada Efetivada
			DbSelectArea("VRQ")
			DbSetOrder(2) // VRQ_FILIAL + VRQ_CODVRP
			DbSeek( VRP->VRP_FILIAL + VRP->VRP_CODIGO )
			Do While ( !VRQ->(Eof()) .and. VRQ->VRQ_FILIAL == VRP->VRP_FILIAL .and. VRQ->VRQ_CODVRP == VRP->VRP_CODIGO )
				DbSelectArea("VPX")
				DbSetOrder(1) // VPX_FILIAL + VPX_SERINT
				DbSeek( xFilial("VPX") + VRQ->VRQ_SERINT )
				DbSelectArea("VPV")
				DbSetOrder(1) // VPV_FILIAL + VPV_CODTIP
				DbSeek( xFilial("VPV") + VPX->VPX_TIPSER )
				If VPV->VPV_CTRSLD <> "0" // Se possuir algum tipo de controle de SALDO de ESTOQUE - verificar saldo
					DbSelectArea("VPY")
					DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
					If ( !DbSeek( xFilial("VPY") + VRQ->VRQ_SERINT + cFilSD2 ) .or. VPY->VPY_QTDEST < VRQ->VRQ_QTDSER ) // NAO possui Estoque
						Help("",1,"OA4600031_CancelarEntrada",,STR0021,1,0) // Serviço Especializado não se encontra mais no Estoque da Filial logada! Impossível continuar.
						lRet := .f.
						Exit
					EndIf
					aAdd(aSrvMov,{ VRQ->VRQ_SERINT , VRQ->VRQ_QTDSER })
				EndIf
				dbSelectArea("VRQ")
				dbSkip()
			Enddo
			If lRet
				For nCntFor := 1 to len(aSrvMov)
					cSeqMov := OFIA452( aSrvMov[nCntFor,1] , cTipMov , cPorMov , cOpeMov , aSrvMov[nCntFor,2] , VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Grava a Movimentação de Estoque do Servico Especializado
					If Empty(cSeqMov) .or. cDebugMIL == "OFIA460006"
						Exit
					EndIf
				Next
				lRet := .f.
				If !Empty(cSeqMov)
					If !Empty(VRP->VRP_NUMNFI) // Possui NF
						//Chamar o MATA103 cancelando
						dbSelectArea("SF1")
						dbSetOrder(1)
						If dbSeek(xFilial("SF1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR )
							aCabNFE   := {}
							aAdd(aCabNFE,{"F1_DOC"		,SF1->F1_DOC    ,Nil})
							aAdd(aCabNFE,{"F1_SERIE"	,SF1->F1_SERIE  ,Nil})
							aAdd(aCabNFE,{"F1_FORNECE"	,SF1->F1_FORNECE,Nil})
							aAdd(aCabNFE,{"F1_LOJA" 	,SF1->F1_LOJA   ,Nil})
							aAdd(aCabNFE,{"F1_TIPO"		,SF1->F1_TIPO   ,Nil})
							aAdd(aCabNFE,{"F1_FORMUL"	,SF1->F1_FORMUL ,Nil})
							aAdd(aCabNFE,{"F1_EMISSAO"	,SF1->F1_EMISSAO,Nil})
							aAdd(aCabNFE,{"F1_ESPECIE"	,SF1->F1_ESPECIE,Nil})
							aAdd(aCabNFE,{"F1_COND"		,SF1->F1_COND   ,Nil})
							aAdd(aCabNFE,{"F1_EST"		,SF1->F1_EST    ,Nil})
							dbSelectArea("SD1")
							dbSetOrder(1)
							dbSeek(xFilial("SD1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR )
							While !eof() .and. xFilial("SD1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR == ;
												SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
								aTemp := {}
								aAdd(aTemp,{"D1_DOC"    ,SD1->D1_DOC    ,Nil})
								aAdd(aTemp,{"D1_SERIE"  ,SD1->D1_SERIE  ,Nil})
								aAdd(aTemp,{"D1_FORNECE",SD1->D1_FORNECE,Nil})
								aAdd(aTemp,{"D1_LOJA"   ,SD1->D1_LOJA   ,Nil})
								aAdd(aTemp,{"D1_COD"    ,SD1->D1_COD    ,Nil})
								aAdd(aTemp,{"D1_ITEM"   ,SD1->D1_ITEM   ,Nil})
								aAdd(aIteNFE,aclone(aTemp))
								DBSelectArea("SD1")
								DbSkip()
							enddo
							//
							lMSHelpAuto := .t.
							lMsErroAuto := .f.
							MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIteNFE,5)
							If lMsErroAuto .or. cDebugMIL == "OFIA460007"
								MostraErro()
								DisarmTransaction()
								Return .f.
							EndIf
						EndIf
					EndIf
					lRet := .t.
				EndIf
			EndIf
		EndIf
		END TRANSACTION
	EndIf
EndIf
If lRet
	OA4600011_GravaStatusEntrada( VRP->VRP_CODIGO , "2" ) // Mudar Status para 2=Entrada Cancelada
	OA4500051_ZeraCustoMedio( "E" , VRP->VRP_FILIAL , VRP->VRP_CODIGO ) // Zera Custo Medio se o Cancelamento da Entrada Zerar o Estoque dos Serviços
EndIf
Return lRet

/*/{Protheus.doc} OA4600041_VisualizarEntrada
Visualizar Entrada

@author Andre Luis Almeida
@since 09/09/2022
/*/
Function OA4600041_VisualizarEntrada()
Local cMsgAvi := ""
Local nOpcAvi := 1
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
If VRP->VRP_STATUS == "1" .and. !Empty(VRP->VRP_NUMNFI) // Entrada Efetivada COM NF
	cMsgAvi += CHR(13)+CHR(10)
	cMsgAvi += "- "+STR0022+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Registro da Entrada do Serviço Especializado
	cMsgAvi += "- "+STR0023 // Nota Fiscal de Entrada do Serviço Especializado
	nOpcAvi := Aviso(STR0007,cMsgAvi,{STR0024,STR0025,STR0010},3) // Visualizar / Reg.Entrada / Nota Fiscal / Cancelar
EndIf
If nOpcAvi == 1 // Visualizar Cadastro VRP
	DbSelectArea("VRP")
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0007) // Visualizar
	oExecView:SetSource("OFIA460")
	oExecView:SetOperation(MODEL_OPERATION_VIEW)
	oExecView:OpenView(.T.)
ElseIf nOpcAvi == 2 // Visualizar a NF Entrada
	SF1->(DbSetOrder(1))
	SF1->(DbSeek(xFilial("SF1")+VRP->VRP_NUMNFI+VRP->VRP_SERNFI+VRP->VRP_CODFOR+VRP->VRP_LOJFOR))
	MATA103(,,2)
EndIf
Return

/*/{Protheus.doc} OA4600051_VerEstoque
Ver o Estoque do Serviço Especializado posicionado

@author Andre Luis Almeida
@since 03/11/2022
/*/
Function OA4600051_VerEstoque()
Local oModel     := FWModelActive()
Local oVRQMod    := oModel:GetModel("VRQDETAIL")
Local nOperModel := oModel:GetOperation()
Local cFilSD2    := xFilial("SD2")
//
SetKey(VK_F4, Nil )
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7, Nil )
EndIf
DbSelectArea("VPY")
DbSetOrder(2) // VPY_FILIAL + VPY_SERINT + VPY_FILEST
If DbSeek( xFilial("VPY") + oVRQMod:GetValue( "VRQ_SERINT" ) + cFilSD2 ) // Pega a Filial Logada
	OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
ElseIf DbSeek( xFilial("VPY") + oVRQMod:GetValue( "VRQ_SERINT" ) ) // Pega qualquer Filial
	OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .f. )
Else
	Help("",1,"OA4600051_VerEstoque",,STR0026,1,0) // Não existe estoque disponivel para esse Serviço Especializado.
EndIf
SetKey(VK_F4,{|| OA4600051_VerEstoque() })
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7,{|| OA4600071_RelacionaSaida() })
EndIf
//
Return

/*/{Protheus.doc} OA4600061_BancoConhecimento
Banco de Conhecimento

@author Andre Luis Almeida
@since 06/12/2022
/*/
Function OA4600061_BancoConhecimento()

If VRP->VRP_STATUS == "1" // Somente EFETIVADA
	dbSelectArea("SF1")
	dbSetOrder(1)
	If dbSeek(xFilial("SF1") + VRP->VRP_NUMNFI + VRP->VRP_SERNFI + VRP->VRP_CODFOR + VRP->VRP_LOJFOR )
		MsDocument( "SF1", SF1->( Recno() ), 4 )
	EndIf
Else
	Help("",1,"OA4600061_BancoConhecimento",,STR0027,1,0) // Opção disponível apenas após efetivação da Nota Fiscal.
EndIf

Return

/*/{Protheus.doc} OA4600071_RelacionaSaida
Relaciona a Entrada com a Saida

@author Andre Luis Almeida
@since 07/12/2022
/*/
Function OA4600071_RelacionaSaida()
Local oModel     := FWModelActive()
Local oView      := FWViewActive()
Local nOperModel := oModel:GetOperation()
Local oVRQMod    := oModel:GetModel("VRQDETAIL")
Local nLinhaAt   := oVRQMod:GetLine()
Local cRelacion  := ""
Local nCntFor    := 0
Local nRecVRQ    := 0
Local aRetTela   := {" "," ",0}
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBUGMIL",.f.,.f.),"")
//
SetKey(VK_F4, Nil )
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7, Nil )
EndIf
If Empty(oVRQMod:GetValue( "VRQ_CODVRS" ))
	Help("",1,"OA4600071_RelacionaSaida",,STR0028,1,0) // Tipo de Serviço não permite relacionar a Entrada com a Saida.
Else
	If nOperModel == MODEL_OPERATION_UPDATE // Alteração
		nRecVRQ := VRQ->(RecNo())
	EndIf
	For nCntFor := 1 to oVRQMod:Length()
		oVRQMod:GoLine(nCntFor)
		If !oVRQMod:IsDeleted()
			cRelacion += oVRQMod:GetValue("VRQ_FILVRS")+oVRQMod:GetValue("VRQ_CODVRS")+"/"
		EndIf
	Next
	If nRecVRQ > 0
		VRQ->(DbGoTo(nRecVRQ))
	EndIf
	oVRQMod:GoLine(nLinhaAt)
	aRetTela := OA4600081_Saidas( oVRQMod:GetValue("VRQ_SERINT") , oVRQMod:GetValue("VRQ_FILVRS") , oVRQMod:GetValue("VRQ_CODVRS") , oVRQMod:GetValue("VRQ_QTDSER") , cRelacion )
	If nRecVRQ > 0
		VRQ->(DbGoTo(nRecVRQ))
	EndIf
	oVRQMod:GoLine(nLinhaAt)
	oVRQMod:LoadValue( "VRQ_FILVRS" , aRetTela[1] )
	oVRQMod:LoadValue( "VRQ_CODVRS" , aRetTela[2] )
	oVRQMod:SetValue(  "VRQ_QTDSER" , aRetTela[3] )
	oView:Refresh("VRQDETAIL")
EndIf
SetKey(VK_F4,{|| OA4600051_VerEstoque() })
If nOperModel == MODEL_OPERATION_INSERT .or. nOperModel == MODEL_OPERATION_UPDATE // Inclusão ou Alteração
	SetKey(VK_F7,{|| OA4600071_RelacionaSaida() })
EndIf
//
Return

/*/{Protheus.doc} OA4600081_Saidas
Tela para selecionar o Serviço na Saida

@author Andre Luis Almeida
@since 12/12/2022
/*/
Static Function OA4600081_Saidas( cSerInt , cFilVRS , cCodVRS , nQtdSer , cRelacion )
Local oModel      := FWModelActive()
Local nOperModel  := oModel:GetOperation()
Local cFiltro     := ""
Local aSize       := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0029 // Relacionar com a Saida de Serviços Especializados

cFiltro := "@ VRS_SERINT = '"+cSerInt+"'"
cFiltro += " AND EXISTS ("
cFiltro += " SELECT VRR.VRR_CODIGO "
cFiltro += "   FROM " + RetSqlName("VRR") + " VRR "
cFiltro += "  WHERE VRR.VRR_FILIAL = VRS_FILIAL "
cFiltro += "    AND VRR.VRR_CODIGO = VRS_CODVRR "
cFiltro += "    AND VRR.VRR_STATUS = '1' "
cFiltro += "    AND VRR.D_E_L_E_T_ = ' ' )"
cFiltro += " AND NOT EXISTS ("
cFiltro += " SELECT VRQ.VRQ_CODIGO "
cFiltro += "   FROM " + RetSqlName("VRQ") + " VRQ "
cFiltro += "   JOIN " + RetSqlName("VRP") + " VRP ON VRP.VRP_FILIAL=VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO=VRQ.VRQ_CODVRP AND VRP.VRP_STATUS<>'2' AND VRP.D_E_L_E_T_=' ' "
If nOperModel == MODEL_OPERATION_UPDATE // Alteração
	cFiltro += " AND ( VRP.VRP_FILIAL <> '"+VRP->VRP_FILIAL+"' OR VRP.VRP_CODIGO <> '"+VRP->VRP_CODIGO+"' )"
EndIf
cFiltro += "  WHERE VRQ.VRQ_FILVRS = VRS_FILIAL "
cFiltro += "    AND VRQ.VRQ_CODVRS = VRS_CODIGO "
cFiltro += "    AND VRQ.D_E_L_E_T_ = ' ' )"

oAuxOA460 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oAuxOA460 )
oWorkArea:CreateHorizontalBox( "LINE01", 70 , .f. )
oWorkArea:SetBoxCols( "LINE01", { "OBJServico" } )
oWorkArea:CreateHorizontalBox( "LINE02", 30 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "OBJSaida" } )
oWorkArea:Activate()

oBrwVRR := FWMBrowse():New()
oBrwVRR:SetAlias('VRR')
oBrwVRR:SetDescription(STR0030) // Dados da Saida do Serviço Especializado posicionado
oBrwVRR:SetOwner(oWorkarea:GetPanel("OBJSaida"))
oBrwVRR:SetMenuDef( '' )
oBrwVRR:SetDoubleClick( { || OA4600091_VisualizarSaida() } )
oBrwVRR:AddButton(STR0031,{|| OA4600091_VisualizarSaida() },,2,2) // Visualizar Saida
oBrwVRR:DisableDetails()
oBrwVRR:DisableLocate()
oBrwVRR:DisableConfig()
oBrwVRR:DisableSeek()
oBrwVRR:SetAmbiente(.F.)
oBrwVRR:SetWalkthru(.F.)
oBrwVRR:SetUseFilter(.f.)
oBrwVRR:lOptionReport := .f.
oBrwVRR:Activate()

oBrwVRS := FWMBrowse():New()
oBrwVRS:SetAlias('VRS')
oBrwVRS:SetDescription(cCadastro)
oBrwVRS:SetMenuDef( '' )
oBrwVRS:SetOwner(oWorkarea:GetPanel("OBJServico"))
oBrwVRS:AddLegend( 'VRS->VRS_FILIAL == "'+cFilVRS+'" .AND. VRS->VRS_CODIGO == "'+cCodVRS+'"' , 'BR_VERDE'  , STR0032 ) // Selecionado no Serviço posicionado
If !Empty(cRelacion)
	oBrwVRS:AddLegend( 'VRS->VRS_FILIAL+VRS->VRS_CODIGO $ "'+cRelacion+'"' , 'BR_AZUL' , STR0033 ) // Já Relacionado a outro Serviço
EndIf
oBrwVRS:AddLegend( 'VRS->VRS_FILIAL <> "'+cFilVRS+'" .OR. VRS->VRS_CODIGO <> "'+cCodVRS+'"' , 'BR_BRANCO' , STR0034 ) // Não Selecionado
oBrwVRS:SetFilterDefault(cFiltro)
oBrwVRS:SetDoubleClick( { || cFilVRS := VRS->VRS_FILIAL , cCodVRS := VRS->VRS_CODIGO , nQtdSer := VRS->VRS_QTDSER , oAuxOA460:End() } )
oBrwVRS:AddButton(STR0035,{|| cFilVRS := VRS->VRS_FILIAL , cCodVRS := VRS->VRS_CODIGO , nQtdSer := VRS->VRS_QTDSER , oAuxOA460:End() },,2,2) // Selecionar Saida
oBrwVRS:AddButton(STR0036,{|| cFilVRS := "" , cCodVRS := "<F7>" , nQtdSer := 0 , oAuxOA460:End() },,2,2) // Retirar seleção
oBrwVRS:DisableDetails()
oBrwVRS:DisableLocate()
oBrwVRS:DisableConfig()
oBrwVRS:SetAmbiente(.F.)
oBrwVRS:SetWalkthru(.F.)
oBrwVRS:SetUseFilter()
oBrwVRS:ForceQuitButton()
oBrwVRS:lOptionReport := .f.
oBrwVRS:Activate()

oRelac:= FWBrwRelation():New() 
oRelac:AddRelation( oBrwVRS , oBrwVRR , { { "VRR_FILIAL" , "VRS_FILIAL" }, { "VRR_CODIGO" , "VRS_CODVRR" } })
oRelac:Activate()

oAuxOA460:Activate( , , , , , , ) //ativa a janela

cCodVRS := IIf(!Empty(cCodVRS),cCodVRS,"<F7>")

Return { cFilVRS , cCodVRS , nQtdSer }

/*/{Protheus.doc} OA4600091_VisualizarSaida
Chama Visualização da Saida OFIA470

@author Andre Luis Almeida
@since 13/12/2022
/*/
Static Function OA4600091_VisualizarSaida()
Local nRecVRS := VRS->(RecNo())
DbSelectArea("VRR")
DbSetOrder(1)
If DbSeek( VRS->VRS_FILIAL + VRS->VRS_CODVRR )
	OA4700051_VisualizarSaida()
EndIf
DbSelectArea("VRS")
DbGoTo(nRecVRS)
Return()

/*/{Protheus.doc} OA4600101_ImprimirEntrada
Impressão dos Dados da Entrada

@author Andre Luis Almeida
@since 14/12/2022
/*/
Function OA4600101_ImprimirEntrada()
Local aArea     := GetArea()
//
oReport := ReportDef()
oReport:PrintDialog()
RestArea( aArea )
//
Return

/*/{Protheus.doc} ReportDef
	ReportDef para tReport

	@author Andre Luis Almeida
	@since 14/12/2022
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local aStrVRP   := FWFormStruct(3,"VRP")
Local aStrVRQ   := FWFormStruct(3,"VRQ",{ |x| !AllTrim(x) $ "VRQ_FILIAL/VRQ_CODIGO/VRQ_CODVRP/VRQ_SERINT/VRQ_CODVRS/" })
Local nCntFor   := 0
Local cCampo    := ""
//
oReport := TReport():New("OFIA460",cCadastro,,{|oReport| OA4600111_TReport( oReport )})
oReport:SetLandscape() // Imprime o relatório em Paisagem
//
oSection1 := TRSection():New(oReport,STR0039,{"VRP","SA2","SE4"}) // Entrada
For nCntFor := 1 to Len(aStrVRP[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVRP[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVRP[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection1,cCampo,"VRP",,,)
	Else // Campos Virtuais
		Do Case
			Case cCampo == "VRP_NOMFOR"
				TRCell():New(oSection1,cCampo,"VRP",,,,, {|| cVRP_NOMFOR },,,,,,,,,)
			Case cCampo == "VRP_DESFPG"
				TRCell():New(oSection1,cCampo,"VRP",,,,, {|| cVRP_DESFPG },,,,,,,,,)
			Case cCampo == "VRP_USRNOM"
				TRCell():New(oSection1,cCampo,"VRP",,,,, {|| cVRP_USRNOM },,,,,,,,,)
		EndCase
	EndIf
Next
//
oSection2 := TRSection():New(oReport,STR0013,{"VRQ","VPX"}) // Serviços Especializados
For nCntFor := 1 to Len(aStrVRQ[FORM_STRUCT_TABLE_MODEL])
	cCampo := aStrVRQ[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
	If !aStrVRQ[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Campos Reais
		TRCell():New(oSection2,cCampo,"VRQ",,,)
	Else // Campos Virtuais
		Do Case
			Case cCampo == "VRQ_GRUSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_GRUSER },,,,,,,,,)
			Case cCampo == "VRQ_CODSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_CODSER },,,,,,,,,)
			Case cCampo == "VRQ_DESSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_DESSER },,,,,,,,,)
			Case cCampo == "VRQ_TIPSER"
				TRCell():New(oSection2,cCampo,"VRQ",,,,, {|| cVRQ_TIPSER },,,,,,,,,)
		EndCase
	EndIf
Next
// Campos Relacionados a Saida
TRCell():New(oSection2,"VRR_NUMNFI","VRR",,,,, {|| cVRR_NUMNFI },,,,,,,,,)
TRCell():New(oSection2,"VRR_SERNFI","VRR",,,,, {|| cVRR_SERNFI },,,,,,,,,)
TRCell():New(oSection2,"VRR_DATNFI","VRR",,,,, {|| dVRR_DATNFI },,,,,,,,,)
TRCell():New(oSection2,"VRS_DTIVIG","VRS",,,,, {|| dVRS_DTIVIG },,,,,,,,,)
TRCell():New(oSection2,"VRS_DTFVIG","VRS",,,,, {|| dVRS_DTFVIG },,,,,,,,,)
TRCell():New(oSection2,"VRS_NROSER","VRS",,,,, {|| cVRS_NROSER },,,,,,,,,)
TRCell():New(oSection2,"VRS_CHASSI","VRS",,,,, {|| cVRS_CHASSI },,,,,,,,,)
//
TRFunction():New(oSection2:Cell("VRQ_VLRTOT"),NIL,"SUM") // Totalizador
//
oReport:SetTotalInLine(.f.)
//
Return oReport

/*/{Protheus.doc} OA4600111_TReport
	Impressao em tReport

	@author Andre Luis Almeida
	@since 14/12/2022
/*/
Static Function OA4600111_TReport( oReport )
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local cQuery    := ""
Private cVRP_NOMFOR := ""
Private cVRP_DESFPG := ""
Private cVRP_USRNOM := ""
Private cVRQ_GRUSER := ""
Private cVRQ_CODSER := ""
Private cVRQ_DESSER := ""
Private cVRQ_TIPSER := ""
Private cVRR_NUMNFI := ""
Private cVRR_SERNFI := ""
Private dVRR_DATNFI := ctod("")
Private dVRS_DTIVIG := ctod("")
Private dVRS_DTFVIG := ctod("")
Private cVRS_NROSER := ""
Private cVRS_CHASSI := ""
//
cQuery := "SELECT COUNT(*) "
cQuery += "  FROM " + RetSqlName("VRQ")
cQuery += " WHERE VRQ_FILIAL = '" + VRP->VRP_FILIAL + "'"
cQuery += "   AND VRQ_CODVRP = '" + VRP->VRP_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_= ' '"
oReport:SetMeter(FM_SQL(cQuery)+3)
//
oReport:IncMeter()
cVRP_NOMFOR := Posicione("SA2",1,xFilial("SA2")+VRP->VRP_CODFOR+VRP->VRP_LOJFOR,"A2_NOME")
cVRP_DESFPG := Posicione("SE4",1,xFilial("SE4")+VRP->VRP_FORPAG,"E4_DESCRI")
cVRP_USRNOM := Left(UsrRetName(VRP->VRP_USRINC),25)
oSection1:Init()
oSection1:PrintLine() // VRP
oSection1:Finish()
oReport:IncMeter()
oReport:SkipLine()
//
oSection2:Init()
DbSelectArea("VRQ")
DbSetOrder(2) // VRQ_FILIAL + VRQ_CODVRP
DbSeek( VRP->VRP_FILIAL + VRP->VRP_CODIGO )
Do While !VRQ->(Eof()) .and. VRQ->VRQ_FILIAL == VRP->VRP_FILIAL .and. VRQ->VRQ_CODVRP == VRP->VRP_CODIGO
	oReport:IncMeter()
	VPX->(DbSetOrder(1))
	VPX->(DbSeek( xFilial("VPX") + VRQ->VRQ_SERINT ))
	cVRQ_GRUSER := VPX->VPX_GRUSER
	cVRQ_CODSER := VPX->VPX_CODSER
	cVRQ_DESSER := VPX->VPX_DESSER
	cVRQ_TIPSER := VPX->VPX_TIPSER
	If !Empty(VRQ->VRQ_FILVRS+VRQ->VRQ_CODVRS)
		VRS->(DbSetOrder(1))
		VRS->(DbSeek( VRQ->VRQ_FILVRS+VRQ->VRQ_CODVRS ))
		VRR->(DbSetOrder(1))
		VRR->(DbSeek( VRS->VRS_FILIAL+VRS->VRS_CODVRR ))
		cVRR_NUMNFI := VRR->VRR_NUMNFI
		cVRR_SERNFI := VRR->VRR_SERNFI
		dVRR_DATNFI := Posicione("SF2",1,xFilial("SF2")+VRR->VRR_NUMNFI+VRR->VRR_SERNFI,"F2_EMISSAO")
		dVRS_DTIVIG := VRS->VRS_DTIVIG
		dVRS_DTFVIG := VRS->VRS_DTFVIG
		cVRS_NROSER := VRS->VRS_NROSER
		cVRS_CHASSI := VRS->VRS_CHASSI
	EndIf
	oSection2:PrintLine() // VRQ
	dbSelectArea("VRQ")
	dbSkip()
EndDo
oReport:SkipLine()
oSection2:Finish()
oReport:SkipLine()
oReport:SkipLine()
oReport:IncMeter()
//
Return Nil

/*/{Protheus.doc} OA4600121_ValidaImpressao
Valida se pode Imprimir os Dados da Entrada

@author Andre Luis Almeida
@since 15/12/2022
/*/
Static Function OA4600121_ValidaImpressao()
Local lImprime   := .t.
Local oModel     := FWModelActive()
Local nOperModel := oModel:GetOperation()
If nOperModel == MODEL_OPERATION_INSERT // Inclusão
	lImprime := .f.
	Help("",1,"OA4600121_ValidaImpressao",,STR0037,1,0) // Opção não disponivel na Inclusão da Entrada. Necessário SALVAR e acessar a Impressão via MENU ou através da Visualização da Entrada.
ElseIf nOperModel == MODEL_OPERATION_UPDATE // Alteração
	If VRP->VRP_STATUS == "0" // Digitado
		lImprime := .f.
		Help("",1,"OA4600121_ValidaImpressao",,STR0038,1,0) // Opção não disponivel na Alteração da Entrada com Status Digitada. Acesse a Impressão via MENU ou através da Visualização da Entrada.
	EndIf
EndIf
If lImprime
	OA4600101_ImprimirEntrada()
EndIf
Return

/*/{Protheus.doc} OA4600131_ValorUltimaEntrada
Retorna Valor Unitario da Ultima Entrada

@author Andre Luis Almeida
@since 23/12/2022
/*/
Function OA4600131_ValorUltimaEntrada( cSerInt )
Local cFilVRP := ""
Local cQAlAux := "SQLAUX"
Local cQuery  := "SELECT DISTINCT VRP_FILIAL FROM "+RetSqlName("VRP")+" WHERE VRP_STATUS = '1' AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
While !( cQAlAux )->( Eof() )
	cFilVRP += "'"+( cQAlAux )->( VRP_FILIAL )+"',"
	( cQAlAux )->( dbSkip() )
EndDo
( cQAlAux )->( dbCloseArea() )
cFilVRP := IIf(!Empty(cFilVRP),left(cFilVRP,len(cFilVRP)-1),"'"+xFilial("VRP")+"'")
cQuery := "SELECT VRQ.VRQ_VLRUNI "
cQuery += "  FROM " + RetSQLName("VRQ") + " VRQ "
cQuery += "  JOIN " + RetSQLName("VRP") + " VRP ON ( VRP.VRP_FILIAL = VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO = VRQ.VRQ_CODVRP AND VRP.VRP_STATUS = '1' AND VRP.D_E_L_E_T_ = ' ' ) "
cQuery += " WHERE VRQ.VRQ_FILIAL IN (" + cFilVRP+ ")"
cQuery += "   AND VRQ.VRQ_SERINT = '"+cSerInt+"'"
cQuery += "   AND VRQ.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VRQ.R_E_C_N_O_ DESC"
Return FM_SQL(cQuery)