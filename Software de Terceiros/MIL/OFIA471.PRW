#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA471.CH"

/*/{Protheus.doc} OFIA471
	Cadastro de Solicita��es e Libera��es de Valor Minimo e Credito do Cliente na Saida de Servi�os Especializados

	@author Andre Luis Almeida
	@since 29/09/2022
/*/
Function OFIA471()
Return

Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('OFIA471')

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVRU := FWFormStruct(1, "VRU")

	oModel := MPFormModel():New('OFIA471',,,,)
	oModel:AddFields('VRUMASTER',/*cOwner*/ , oStrVRU)
	oModel:SetDescription(STR0001) // Solicita��es e Libera��es de Valor Minimo e Credito do Cliente na Saida de Servi�os Especializados
	oModel:GetModel('VRUMASTER'):SetDescription(STR0001) // Solicita��es e Libera��es de Valor Minimo e Credito do Cliente na Saida de Servi�os Especializados

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVRU:= FWFormStruct(2, "VRU", { |cCampo| !ALLTRIM(cCampo) $ 'VRU_CODIGO/VRU_CODVRR/' } )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'BOXVRU', 100)
	oView:AddField('VIEW_VRU', oStrVRU, 'VRUMASTER')
	oView:SetOwnerView('VIEW_VRU','BOXVRU')

Return oView

/*/{Protheus.doc} OA4710011_InclusaoSolicitacao
Inclusao da Solicita��o

@author Andre Luis Almeida
@since 29/09/2022
@type function
/*/
Function OA4710011_InclusaoSolicitacao( cCodVRR , aLimCre , aVlrMin , nTotSai , nDivMin )
	Local oModVRU
	Local aRetTela  := {}
	Local cQuery    := ""
	Local nRecVRU   := 0
	Local nCntFor   := 0
	Default cCodVRR := ""
	Default aLimCre := {}
	Default aVlrMin := {}
	Default nTotSai := 0
	Default nDivMin := 0
	//
	aRetTela := OA4710041_TelaPendencias( aLimCre , aVlrMin , .t. ) // Tela de Pendencias para Solicitacao de Libera��o
	//
	cQuery := "SELECT R_E_C_N_O_ AS RECVRU "
	cQuery += "  FROM " + RetSqlName("VRU")
	cQuery += " WHERE VRU_FILIAL = '" + xFilial("VRU") + "'"
	cQuery += "   AND VRU_CODVRR = '" + cCodVRR + "'"
	cQuery += "   AND VRU_ATIVO  = '1'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += "   AND VRU_TIPSOL = "
	//
	For nCntFor := 1 to len(aRetTela)
		//
		nRecVRU := FM_SQL( cQuery + "'" + aRetTela[nCntFor] + "'" )
		If nRecVRU > 0
			VRU->(DbGoTo(nRecVRU))
			oModVRU := FWLoadModel( 'OFIA471' )
			oModVRU:SetOperation( MODEL_OPERATION_UPDATE )
			If oModVRU:Activate()
				oModVRU:LoadValue( "VRUMASTER" , "VRU_ATIVO " , "0" ) // Desativar o registro em aberto para gerar um novo.
				If oModVRU:VldData()
					oModVRU:CommitData()
				EndIf
				oModVRU:DeActivate()
			EndIf
			FreeObj(oModVRU)
		EndIf
		//
		oModVRU := FWLoadModel( 'OFIA471' )
		oModVRU:SetOperation( MODEL_OPERATION_INSERT )
		If oModVRU:Activate()
			oModVRU:LoadValue( "VRUMASTER" , "VRU_CODVRR" , cCodVRR )
			oModVRU:LoadValue( "VRUMASTER" , "VRU_TIPSOL" , aRetTela[nCntFor] )
			oModVRU:LoadValue( "VRUMASTER" , "VRU_VLRSOL" , IIf(aRetTela[nCntFor]=="1",nTotSai,nDivMin) )
			If oModVRU:VldData()
				oModVRU:CommitData()
			EndIf
			oModVRU:DeActivate()
		EndIf
		FreeObj(oModVRU)
		//
	Next
	//
Return ( len(aRetTela) > 0 )

/*/{Protheus.doc} OA4710021_AprovarReprovarSolicitacao
1 - Aprovar Solicita��o / 2 - Reprovar Solicita��o

@author Andre Luis Almeida
@since 29/09/2022
@type function
/*/
Function OA4710021_AprovarReprovarSolicitacao(cAprRep)
	Local oModVRU
	Local nCntFor   := 0
	Local nRecVRU   := 0
	Local aMotivo   := {}
	Local cMotivo   := ""
	Local cStatus   := ""
	Local cQuery    := ""
	Local cMsg      := ""
	Default cAprRep := "1"
	//
	Do Case
		Case VRU->VRU_ATIVO == '0' // N�O ATIVOS - Cancelada
			MsgStop(STR0003,STR0002) // Solicita��o Cancelada. Imposs�vel continuar. / Aten��o
		Case VRU->VRU_ATIVO == '1' .and. VRU->VRU_STATUS == '0' // ATIVOS - Pendente Libera��o
			If cAprRep == "1" // 1 - Aprovar Solicita��o
				cMsg := STR0004 // Deseja APROVAR a Solicita��o?
				VAI->(Dbsetorder(4))
				VAI->(DbSeek(xFilial("VAI")+__cUserID))
				If VRU->VRU_TIPSOL == "1" // 1=Limite Cr�dito
					If VAI->VAI_ALLBCR < VRU->VRU_VLRSOL // Al�ada de Libera��o de Cr�dito
						MsgStop(STR0005,STR0002) // Usu�rio sem permiss�o para Liberar o Valor Total da Saida dos Servi�os Especializados. / Aten��o
						Return
					EndIf
					cMotivo := "000029" // APROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
				ElseIf VRU->VRU_TIPSOL == "2" // 2=Valor Minimo
					If VAI->VAI_ALLBSE < VRU->VRU_VLRSOL // Al�ada de Valor Minimo do Servico Especializado
						MsgStop(STR0006,STR0002) // Usu�rio sem permiss�o para Liberar toda divergencia de Valor Minimo dos Servi�os Especializados. / Aten��o
						Return
					EndIf
					cMotivo := "000027" // APROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
				EndIf
			Else // 2 - Reprovar Solicita��o
				cMsg := STR0007 // Deseja REPROVAR a Solicita��o?
				If VRU->VRU_TIPSOL == "1" // 1=Limite Cr�dito
					cMotivo := "000028" // REPROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
				ElseIf VRU->VRU_TIPSOL == "2" // 2=Valor Minimo
					cMotivo := "000030" // REPROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
				EndIf
			EndIf
			If MsgNoYes( cMsg , STR0002 ) // Aten��o
				//
				BEGIN TRANSACTION
				//
				aMotivo := OFA210MOT(cMotivo,"B",VRU->VRU_FILIAL,VRU->VRU_CODIGO,.T.) // Filtro da consulta do motivo
				If Len(aMotivo) > 0
					//
					oModVRU := FWLoadModel( 'OFIA471' )
					oModVRU:SetOperation( MODEL_OPERATION_UPDATE )
					If oModVRU:Activate()
						oModVRU:LoadValue( "VRUMASTER" , "VRU_STATUS" , cAprRep ) // ( 1 - Aprovar / 2 - Reprovar )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_DATAPR" , dDatabase )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_HORAPR" , left(time(),2)+substr(time(),4,2) )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_USRAPR" , __cUserID )
						oModVRU:LoadValue( "VRUMASTER" , "VRU_MOTIVO" , aMotivo[1] )
						If oModVRU:VldData()
							oModVRU:CommitData()
						EndIf
						oModVRU:DeActivate()
					EndIf
					FreeObj(oModVRU)
					//
					If cAprRep == "1" // 1 - Aprovar Solicita��o
						//
						cQuery := "SELECT VRU_STATUS "
						cQuery += "  FROM " + RetSqlName("VRU")
						cQuery += " WHERE VRU_FILIAL = '" + VRU->VRU_FILIAL + "'"
						cQuery += "   AND VRU_CODVRR = '" + VRU->VRU_CODVRR + "'"
						cQuery += "   AND VRU_ATIVO  = '1'"
						cQuery += "   AND D_E_L_E_T_ = ' '"
						cQuery += "   AND VRU_TIPSOL = "
						For nCntFor := 1 to 2
							cStatus += FM_SQL( cQuery + "'" + strzero(nCntFor,1) + "' ORDER BY VRU_CODIGO DESC" )
						Next
						DbSelectArea("VRU")
						If !("0" $ cStatus) // NAO existe Solicita��o Pendente
							If !("2" $ cStatus) // NAO Existe Solicita��o Reprovada
								OA4700011_GravaStatusSaida( VRU->VRU_CODVRR , "4" ) // Mudar o VRR_STATUS 4-Liberado para Efetivar Saida
							EndIf
						EndIf
						//
					Else // 2 - Reprovar Solicita��o
						//
						OA4700011_GravaStatusSaida( VRU->VRU_CODVRR , "5" ) // Mudar o VRR_STATUS 5-Libera��o de Pend�ncias Reprovada
						//
						DbSelectArea("VRU")
						nRecVRU := VRU->(RecNo())
						OA4710051_DesativarSolicitacoes( VRU->VRU_FILIAL , VRU->VRU_CODVRR , VRU->(RecNo()) ) // Marcar 0=NAO ATIVO para todas as Solicita��es da Saida VRR
						VRU->( DbGoTo( nRecVRU ) )
						//
					EndIf
					//
				EndIf
				//
				END TRANSACTION
				//
			EndIf
		Case VRU->VRU_ATIVO == '1' .and. VRU->VRU_STATUS == '1' // ATIVOS - Aprovada
			MsgStop(STR0008,STR0002) // Solicita��o j� esta Aprovada. Imposs�vel continuar. / Aten��o
		Case VRU->VRU_ATIVO == '1' .and. VRU->VRU_STATUS == '2' // ATIVOS - Reprovada
			MsgStop(STR0009,STR0002) // Solicita��o j� esta Reprovada. Imposs�vel continuar. / Aten��o
	EndCase
Return

/*/{Protheus.doc} OA4710031_VisualizarSaida
Visualizar Saida

@author Andre Luis Almeida
@since 29/09/2022
@type function
/*/
Function OA4710031_VisualizarSaida()
Private cCadastro := STR0010 // Visualizar Saida
VRR->(DbSetOrder(1))
If VRR->(DbSeek(VRU->VRU_FILIAL+VRU->VRU_CODVRR))
	OA4700051_VisualizarSaida()
EndIf
Return

/*/{Protheus.doc} OA4710041_TelaPendencias
Tela de Pendencias para Solicitar Libera��o

@author Andre Luis Almeida
@since 03/10/2022
@type function
/*/
Function OA4710041_TelaPendencias( aLimCre , aVlrMin , lSolicit )
Local aSizeAut   := MsAdvSize(.t.)
Local aObjects   := {}
Local aPosObj    := {}
Local aInfo      := {}
Local aRetTela   := {}
Local aNewBot    := {}
Local oVERDE     := LoadBitmap( GetResources() , "BR_VERDE" )
Local oVERMELHO  := LoadBitmap( GetResources() , "BR_VERMELHO" )
Local oFontTit   := TFont():New( "Arial", 10,20 )
Private cCadastro := STR0011 // Valor Desejado x Valor Minimo dos Servi�os Especializados
Default aVlrMin  := {}
Default aLimCre  := {}
Default lSolicit := .t.
//
If lSolicit
	cCadastro := STR0012 // Solicita��o de Libera��o de Pend�ncias para Saida de Servi�os Especializados
EndIf
//
AADD( aNewBot , {"PMSCOLOR",{ || OA4710071_Legenda() } , STR0029 } ) // Legenda
//
If len(aLimCre)>0
	AAdd( aObjects, { 0 , 25 , .T. , .F. } ) // Titulo Cliente ( Limite de Cr�dito )
	AAdd( aObjects, { 0 , 45 , .T. , .F. } ) // Cliente ( Limite de Cr�dito )
Else
	AAdd( aObjects, { 0 ,  0 , .T. , .F. } ) // NAO deixa espa�o para Titulo Cliente ( Limite de Cr�dito )
	AAdd( aObjects, { 0 ,  0 , .T. , .F. } ) // NAO deixa espa�o para Cliente ( Limite de Cr�dito )
EndIf
If lSolicit
	AAdd( aObjects, { 0 , 25 , .T. , .F. } ) // Titulo Servi�os Especializados ( Valor Minimo )
Else
	AAdd( aObjects, { 0 ,  0 , .T. , .F. } ) // NAO deixa espa�o para Titulo Servi�os Especializados ( Valor Minimo )
EndIf
AAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // Servi�os Especializados ( Valor Minimo )
//
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 }	// Tamanho total da tela
aPosObj := MsObjSize( aInfo, aObjects ) 										// Monta objetos conforme especificacoes
//
DEFINE MSDIALOG oDlgOA471 FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL STYLE DS_MODALFRAME
	oDlgOA471:lEscClose := .F.
	//
	oTPan1 := TPanel():New(aPosObj[1,1] ,aPosObj[1,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[1,4] - aPosObj[1,2], aPosObj[1,3] - aPosObj[1,1],.T.,.F.)
	oTPan2 := TPanel():New(aPosObj[2,1] ,aPosObj[2,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[2,4] - aPosObj[2,2], aPosObj[2,3] - aPosObj[2,1],.T.,.F.)
	oTPan3 := TPanel():New(aPosObj[3,1] ,aPosObj[3,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[3,4] - aPosObj[3,2], aPosObj[3,3] - aPosObj[3,1],.T.,.F.)
	oTPan4 := TPanel():New(aPosObj[4,1] ,aPosObj[4,2],"",oDlgOA471,NIL,.T.,.F.,NIL,NIL,aPosObj[4,4] - aPosObj[4,2], aPosObj[4,3] - aPosObj[4,1],.T.,.F.)
	//
	oTPan4:Align := CONTROL_ALIGN_BOTTOM
	oTPan3:Align := CONTROL_ALIGN_BOTTOM
	oTPan2:Align := CONTROL_ALIGN_BOTTOM
	oTPan1:Align := CONTROL_ALIGN_BOTTOM
	//
	If len(aLimCre) > 0
		If !aLimCre[1,1]
			aAdd(aRetTela,"1") // 1=Limite de Credito
		EndIf
		@ 010,010 SAY STR0013 Font oFontTit SIZE 300,10 OF oTPan1 PIXEL COLOR CLR_BLUE // Pend�ncia de Limite de Cr�dito do Cliente OK
		oLbLimCre := TWBrowse():New( 1,1,100,100,,,,oTPan2,,,,{ || .t. } ,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
		oLbLimCre:addColumn( TCColumn():New( ""      , { || IIf(aLimCre[oLbLimCre:nAt,1],oVERDE,oVERMELHO) } ,,,, "LEFT" ,  05 ,.T.,.F.,,,,.F.,) )
		oLbLimCre:addColumn( TCColumn():New( STR0014 , { || aLimCre[oLbLimCre:nAt,02]                      } ,,,, "LEFT" ,  60 ,.F.,.F.,,,,.F.,) ) // Cliente
		oLbLimCre:addColumn( TCColumn():New( STR0015 , { || aLimCre[oLbLimCre:nAt,03]                      } ,,,, "LEFT" , 200 ,.F.,.F.,,,,.F.,) ) // Nome
		oLbLimCre:nAt := 1
		oLbLimCre:SetArray(aLimCre)
		oLbLimCre:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	//
	If ASCAN( aVlrMin , {|i| i[1] == .f. }) <> 0
		aAdd(aRetTela,"2") // 2=Valor Minimo nos Servi�os Especializados
	EndIf
	If lSolicit
		@ 010,010 SAY STR0011 Font oFontTit SIZE 300,10 OF oTPan3 PIXEL COLOR CLR_BLUE // Valor Desejado x Valor Minimo dos Servi�os Especializados
	EndIf
	oLbVlrMin := TWBrowse():New( 1,1,100,100,,,,oTPan4,,,,{ || .t. } ,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
	oLbVlrMin:addColumn( TCColumn():New( ""      , { || IIf(aVlrMin[oLbVlrMin:nAt,1],oVERDE,oVERMELHO)              } ,,,, "LEFT" ,  05 ,.T.,.F.,,,,.F.,) )
	oLbVlrMin:addColumn( TCColumn():New( STR0016 , { || aVlrMin[oLbVlrMin:nAt,02]                                   } ,,,, "LEFT" ,  35 ,.F.,.F.,,,,.F.,) ) // Grupo
	oLbVlrMin:addColumn( TCColumn():New( STR0017 , { || aVlrMin[oLbVlrMin:nAt,03]                                   } ,,,, "LEFT" ,  80 ,.F.,.F.,,,,.F.,) ) // C�digo do Servi�o
	oLbVlrMin:addColumn( TCColumn():New( STR0018 , { || aVlrMin[oLbVlrMin:nAt,04]                                   } ,,,, "LEFT" , 140 ,.F.,.F.,,,,.F.,) ) // Descri��o
	oLbVlrMin:addColumn( TCColumn():New( STR0019 , { || aVlrMin[oLbVlrMin:nAt,05]                                   } ,,,, "LEFT" ,  35 ,.F.,.F.,,,,.F.,) ) // Tipo
	oLbVlrMin:addColumn( TCColumn():New( STR0020 , { || Transform(aVlrMin[oLbVlrMin:nAt,08],"@E 999,999")           } ,,,, "RIGHT",  50 ,.F.,.F.,,,,.F.,) ) // Quantidade
	oLbVlrMin:addColumn( TCColumn():New( STR0021 , { || Transform(aVlrMin[oLbVlrMin:nAt,06],"@E 99,999,999,999.99") } ,,,, "RIGHT",  90 ,.F.,.F.,,,,.F.,) ) // Valor Minimo Permitido
	oLbVlrMin:addColumn( TCColumn():New( STR0022 , { || Transform(aVlrMin[oLbVlrMin:nAt,06]*aVlrMin[oLbVlrMin:nAt,08],"@E 99,999,999,999.99") } ,,,, "RIGHT", 90 ,.F.,.F.,,,,.F.,) ) // Total Minimo Permitido
	oLbVlrMin:addColumn( TCColumn():New( STR0023 , { || Transform(aVlrMin[oLbVlrMin:nAt,07],"@E 99,999,999,999.99") } ,,,, "RIGHT", 100 ,.F.,.F.,,,,.F.,) ) // Valor Desejado (com desconto)
	oLbVlrMin:addColumn( TCColumn():New( STR0024 , { || Transform(aVlrMin[oLbVlrMin:nAt,09],"@E 99,999,999,999.99") } ,,,, "RIGHT", 100 ,.F.,.F.,,,,.F.,) ) // Total Desejado (com desconto)
	oLbVlrMin:addColumn( TCColumn():New( STR0025 , { || Transform((aVlrMin[oLbVlrMin:nAt,06]-aVlrMin[oLbVlrMin:nAt,07])*aVlrMin[oLbVlrMin:nAt,08]*-1,"@E 999,999,999.99") } ,,,, "RIGHT", 70 ,.F.,.F.,,,,.F.,) ) // Diferen�a
	oLbVlrMin:addColumn( TCColumn():New( STR0026 , { || Transform((((aVlrMin[oLbVlrMin:nAt,06]-aVlrMin[oLbVlrMin:nAt,07])*aVlrMin[oLbVlrMin:nAt,08])/(aVlrMin[oLbVlrMin:nAt,06]*aVlrMin[oLbVlrMin:nAt,08]))*100*-1,"@E 9999.99")+" %" } ,,,, "RIGHT", 40 ,.F.,.F.,,,,.F.,) ) // % Diferen�a
	oLbVlrMin:nAt := 1
	oLbVlrMin:SetArray(aVlrMin)
	oLbVlrMin:Align := CONTROL_ALIGN_ALLCLIENT
	//
ACTIVATE MSDIALOG oDlgOA471 ON INIT EnchoiceBar(oDlgOA471,{ || oDlgOA471:End() }, { || ( aRetTela := {} , oDlgOA471:End() ) },,aNewBot)
//
Return aClone(aRetTela)

/*/{Protheus.doc} OA4710051_DesativarSolicitacoes
Gravar VRU_ATIVO = 0-NAO -> Desativar as Solicitacoes de Pendencias

@author Andre Luis Almeida
@since 05/10/2022
@type function
/*/
Function OA4710051_DesativarSolicitacoes( cFilVRR , cCodVRR , nRecVRU )
Local oModVRU
Local cQuery    := ""
Local cSQLAux   := "SQLAUX"
cQuery := "SELECT R_E_C_N_O_ AS RECVRU "
cQuery += "  FROM " + RetSqlName("VRU")
cQuery += " WHERE VRU_FILIAL = '" + cFilVRR + "'"
cQuery += "   AND VRU_CODVRR = '" + cCodVRR + "'"
cQuery += "   AND VRU_ATIVO  = '1'"
If nRecVRU <> 0
	cQuery += "   AND R_E_C_N_O_ <> "+Alltrim(str(nRecVRU))
EndIf
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux , .F., .T. )
Do While !( cSQLAux )->( Eof() )
	If (cSQLAux)->( RECVRU ) > 0
		VRU->( DbGoTo( (cSQLAux)->( RECVRU ) ) )
		oModVRU := FWLoadModel( 'OFIA471' )
		oModVRU:SetOperation( MODEL_OPERATION_UPDATE )
		If oModVRU:Activate()
			oModVRU:LoadValue( "VRUMASTER" , "VRU_ATIVO " , "0" ) // Desativar o registro em aberto para gerar um novo no futuro.
			If oModVRU:VldData()
				oModVRU:CommitData()
			EndIf
			oModVRU:DeActivate()
		EndIf
		FreeObj(oModVRU)
	EndIf
	( cSQLAux )->( DbSkip() )
EndDo
( cSQLAux )->( dbCloseArea() )
DbSelectArea("VRU")
Return

/*/{Protheus.doc} OA4710061_DescricaoMotivo
Retorna a Descri��o do Motivo

@author Andre Luis Almeida
@since 25/10/2022
@type function
/*/
Function OA4710061_DescricaoMotivo()
Local cQuery   := ""
Local cTipAss  := ""
Local cRetDesc := ""
If !Empty(VRU->VRU_MOTIVO)
	Do Case
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "11" // 1=Solicita��o Aprovada / 1=Limite Cr�dito
			cTipAss := "000029" // APROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "12" // 1=Solicita��o Aprovada / 2=Valor Minimo
			cTipAss := "000027" // APROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "21" // 1=Solicita��o Reprovada / 1=Limite Cr�dito
			cTipAss := "000028" // REPROVA SOL.LIM.CREDITO SERV.ESPECIALIZADO
		Case VRU->VRU_STATUS+VRU->VRU_TIPSOL == "22" // 1=Solicita��o Reprovada / 2=Valor Minimo
			cTipAss := "000030" // REPROVA SOL.VLR.MINIMO SERV.ESPECIALIZADO
	EndCase
	If !Empty(cTipAss)
		cQuery := "SELECT VS0_DESMOT"
		cQuery += "  FROM "+RetSqlName("VS0")
		cQuery += " WHERE VS0_FILIAL = '"+xFilial("VS0")+"'"
		cQuery += "   AND VS0_TIPASS = '"+cTipAss+"'"
		cQuery += "   AND VS0_CODMOT = '"+VRU->VRU_MOTIVO+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		cRetDesc := FM_SQL(cQuery)
	EndIf
EndIf
Return Padr(cRetDesc,50)

/*/{Protheus.doc} OA4710071_Legenda
Legenda

@author Andre Luis Almeida
@since 28/10/2022
@type function
/*/
Function OA4710071_Legenda()

Local aLegenda  := {{ 'BR_VERDE'    , STR0027 } ,; // OK
					{ 'BR_VERMELHO' , STR0028 } }  // Pendencia

BrwLegenda(cCadastro,STR0029,aLegenda) //Legenda

Return
