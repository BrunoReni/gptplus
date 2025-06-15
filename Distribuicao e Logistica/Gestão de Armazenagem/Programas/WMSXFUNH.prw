#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNH.CH"

#DEFINE WMSXFUNH01 "WMSXFUNH01"
#DEFINE WMSXFUNH02 "WMSXFUNH02"
#DEFINE WMSXFUNH03 "WMSXFUNH03"
#DEFINE WMSXFUNH04 "WMSXFUNH04"
#DEFINE WMSXFUNH05 "WMSXFUNH05"
#DEFINE WMSXFUNH06 "WMSXFUNH06"
#DEFINE WMSXFUNH07 "WMSXFUNH07"
#DEFINE WMSXFUNH08 "WMSXFUNH08"
#DEFINE WMSXFUNH09 "WMSXFUNH09"
#DEFINE WMSXFUNH10 "WMSXFUNH10"
#DEFINE WMSXFUNH11 "WMSXFUNH11"
#DEFINE WMSXFUNH12 "WMSXFUNH12"
#DEFINE WMSXFUNH13 "WMSXFUNH13"
#DEFINE WMSXFUNH14 "WMSXFUNH14"
#DEFINE WMSXFUNH15 "WMSXFUNH15"
#DEFINE WMSXFUNH16 "WMSXFUNH16"
#DEFINE WMSXFUNH17 "WMSXFUNH17"
#DEFINE WMSXFUNH18 "WMSXFUNH18"
#DEFINE WMSXFUNH19 "WMSXFUNH19"
#DEFINE WMSXFUNH20 "WMSXFUNH20"
#DEFINE WMSXFUNH21 "WMSXFUNH21"
#DEFINE WMSXFUNH22 "WMSXFUNH22"
#DEFINE WMSXFUNH23 "WMSXFUNH23"
#DEFINE WMSXFUNH24 "WMSXFUNH24"
#DEFINE WMSXFUNH25 "WMSXFUNH25"
#DEFINE WMSXFUNH26 "WMSXFUNH26"
#DEFINE WMSXFUNH27 "WMSXFUNH27"
#DEFINE WMSXFUNH28 "WMSXFUNH28"
#DEFINE WMSXFUNH29 "WMSXFUNH29"
#DEFINE WMSXFUNH30 "WMSXFUNH30"

//------------------------------------------------------------------------------
Function WmsAvalSC2(cAcao,cServico,cEndOri,cDocto,nRecSD3,nRecSC2)
//------------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdSerDel := Nil
Local oDmdUnit   := Nil
Local oServico   := Nil
Local cMessage   := ""
Local cOp        := ""
Local cAliasQry	 := ""

Default cServico := ""
Default nRecSD3  := 0
Default nRecSC2  := 0
	
	If nRecSD3 > 0
		SD3->(MsGoTo(nRecSD3))
		If Empty(cServico)
			cServico := SD3->D3_SERVIC
		EndIf
		cOp := SD3->D3_OP
	EndIf
	If nRecSC2 > 0
		SC2->(MsGoTo(nRecSC2))
		cOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
	EndIf
	If cAcao == "1" // Validação apontamento OP - MATA250 e MATA680/681
		// Valida o preenchimento do campo Serviço
		If lWmsNew .And. Empty(cServico)
			WmsMessage(WmsFmtMsg(STR0001,{{"[VAR01]",RetTitle("D3_SERVIC")}}),WMSXFUNH03,1) // "O campo '[VAR01]' deve ser preenchido para produtos com controle de WMS."
			lRet := .F.
		EndIf
		// Valida o preenchimento do campo Documento
		If lRet .And. !Empty(cServico) .And. Empty(cDocto)
			WmsMessage(WmsFmtMsg(STR0002,{{"[VAR01]",RetTitle("D3_DOC")}}),WMSXFUNH04,1) // "O campo '[VAR01]' deve ser preenchido sempre que uma produção gerar serviço de WMS."
			lRet := .F.
		EndIf
		If lWmsNew
			If lRet 
				oServico := WMSDTCServicoTarefa():New()
				oServico:SetServico(cServico)
				If oServico:LoadData()
					If !oServico:HasOperac({'1','2'}) // Serviço endereçamento, endereçamento crossdocking
						WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",cServico}}),WMSXFUNH08,1) // "Serviço '[VAR01]' deve ser de operação Endereçamento ou Endereçamento Crossdocking."
						lRet := .F.
					EndIf
				Else
					WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cServico}}),WMSXFUNH09,1) // "Serviço '[VAR01]' não existe no cadastro de Serviço x Tarefa (DC5)."
					lRet := .F.
				EndIf
				oServico:Destroy()
			EndIf
			
			If lRet .And. Empty(cEndOri)
				WmsMessage(STR0005,WMSXFUNH12,1) // "Endereço Origem não foi preenchido para o endereçamento do WMS."
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. lWmsNew .And. !Empty(cDocto)
			
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:DH1% DH1
				LEFT JOIN %Table:D12% D12
					ON D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_IDDCF = DH1.DH1_IDDCF
					AND D12.D12_NUMSEQ = DH1.DH1_NUMSEQ
					AND D12.D12_STATUS NOT IN ('0','1') //-- 0=Estornada;1=Executada
					AND D12.%NotDel%
				LEFT JOIN %Table:DCF% DCF
					ON DCF.DCF_ID = DH1.DH1_IDDCF
					AND DCF.DCF_NUMSEQ = DH1.DH1_NUMSEQ
					AND DCF.DCF_STSERV NOT IN ('0','3') //-- 0=Estornado;3=Executado
					AND DCF.%NotDel%
				WHERE DH1.DH1_FILIAL = %xFilial:DH1%
					AND DH1.DH1_OP = %Exp:cDocto%
					AND ( D12_IDDCF IS NOT NULL OR DCF_ID IS NOT NULL )
					AND DH1.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cOp}}),WMSXFUNH15,,,,STR0007) // "A ordem de produção [VAR01] possui requisições pendentes de atendimento em ordens de serviço de separação no WMS."###"Aguarde a finalização da separação ou exclua a integração das requisições com o WMS para realizar esta operação."
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())

		EndIf

	ElseIf cAcao == "2" // Validação estorno do apontamento OP - MATA250 e MATA680/681
		If !lWmsNew
			If WmsChkDCF("SD3",,,SD3->D3_SERVIC,"3",,SD3->D3_DOC,,,,SD3->D3_LOCAL,SD3->D3_COD,,,SD3->D3_NUMSEQ)
				lRet := WmsAvalDCF("2")
			EndIf
		Else
			If SD3->D3_QUANT > 0  .OR. !Empty(SD3->D3_IDDCF)
				If WmsArmUnit(SD3->D3_LOCAL)
					oDmdUnit := WMSDTCDemandaUnitizacaoDelete():New()
 					oDmdUnit:SetIdD0Q(SD3->D3_IDDCF)
 					oDmdUnit:LoadData()
		 			If !oDmdUnit:CanDelete()
		 				cMessage := STR0010 + " - DU "+LTrim(oDmdUnit:GetDocto())+" - ID "+oDmdUnit:GetIdD0Q() // "Apontamento integrado ao SIGAWMS
		 				cMessage += CRLF + oDmdUnit:GetErro()
	 					WmsMessage(cMessage,WMSXFUNH01,5)
	 					lRet := .F.
	 				EndIf
					FreeObj(oDmdUnit)
				Else
					oOrdSerDel := WMSDTCOrdemServicoDelete():New()
					oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
					oOrdSerDel:LoadData()
					If !oOrdSerDel:CanDelete()
						cMessage := STR0010 + " - OS "+LTrim(oOrdSerDel:GetDocto())+" - ID "+oOrdSerDel:GetIdDCF() // "Apontamento integrado ao SIGAWMS 
						cMessage += CRLF + oOrdSerDel:GetErro()
						WmsMessage(cMessage,WMSXFUNH05,5)
						lRet := .F.
					EndIf
					FreeObj(oOrdSerDel)
				EndIf
			EndIf 
		EndIf

	ElseIf cAcao == "3" // Exclusão/Encerramento da Ordem de Produção
		lRet := ValIntReq(cOp)
	EndIf
Return lRet
//------------------------------------------------------------------------------
Function WmsAvalSD4(cAcao,nRecSD4,nQtdSD4Wms,cOp)
//------------------------------------------------------------------------------
Local lRet := .T.

Default cAcao   := "1"
Default nRecSD4 := 0
Default cOp     := ""

	If nRecSD4 > 0
		SD4->(MsGoTo(nRecSD4))
	EndIf

	If cAcao == "1" // Modificação/Exclusão da Requisição de Estoque
		IF !Empty(SD4->D4_IDDCF)
			WmsMessage(WmsFmtMsg(STR0012,{{"[VAR01]",cOp}}),WMSXFUNH18,,,,STR0013) // "A ordem de produção [VAR01] possui requisições com ordens de serviço de separação no WMS." ### "Efetue o estorno da integração das requisições com o WMS para realizar esta operação."
			lRet := .F.
		EndIF
	ElseIf cAcao == "2" 
		nQtdSD4Wms := 0
		lRet :=  ValIntReq(SD4->D4_OP,SD4->D4_TRT,SD4->D4_IDDCF,@nQtdSD4Wms)
	ElseIf cAcao == "3"
		WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cOp}}),WMSXFUNH15,,,,STR0007) // "A ordem de produção [VAR01] possui requisições pendentes de atendimento em ordens de serviço de separação no WMS."###"Aguarde a finalização da separação ou exclua a integração das requisições com o WMS para realizar esta operação."
		lRet := .F.
	EndIf
Return lRet

//------------------------------------------------------------------------------
Function WmsIntOP(nRecSD3,cEndereco,cServico)
//------------------------------------------------------------------------------
Local aAreaAnt := GetArea()
Local aAreaSD3 := SD3->(GetArea())
Local lRet     := .T.
Local oOrdServ := WmsOrdSer()
Local oDmdUnit := Nil

Default cServico := ""

	SD3->(MsGoTo(nRecSD3))
	If SD3->D3_QUANT <= 0  
		Return .T. 
	EndIf
	
	If Empty(cServico)
		cServico := SD3->D3_SERVIC
	EndIf
	
	If Empty(cEndereco)
		WmsMessage(STR0008,WMSXFUNH10,1) // "Endereço Origem não informado para integração com WMS."
		Return .F.
	EndIf
	
	If Empty(cServico)
		WmsMessage(STR0009,WMSXFUNH11,1) // "Serviço não informado para integração com WMS."
		Return .F.
	EndIf
	
	If !(SD3->D3_LOCAL == SuperGetMv("MV_CQ",.F.,"")) .And. WmsArmUnit(SD3->D3_LOCAL) //Verifica se deve unitizar o produto 
		oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
		// Dados produto
		oDmdUnit:oProdLote:SetArmazem(SD3->D3_LOCAL)
		// Dados endereço origem
		oDmdUnit:oDmdEndOri:SetArmazem(SD3->D3_LOCAL)
		oDmdUnit:oDmdEndOri:SetEnder(cEndereco)
		// Dados endereço destino
		oDmdUnit:oDmdEndDes:SetArmazem(SD3->D3_LOCAL)
		oDmdUnit:oDmdEndDes:SetEnder("")
		// Dados serviço
		oDmdUnit:oServico:SetServico(cServico)
		// Dados documento
		oDmdUnit:SetNumSeq(SD3->D3_NUMSEQ)
		oDmdUnit:SetDocto(SD3->D3_DOC)
		oDmdUnit:SetOrigem("SC2")
		If !(lRet := oDmdUnit:CreateD0Q())
			WmsMessage(oDmdUnit:GetErro(),WMSXFUNH13,1)
		EndIf
	Else
		If oOrdServ == Nil
			oOrdServ := WMSDTCOrdemServicoCreate():New()
			WmsOrdSer(oOrdServ)
		EndIf
		// Dados produto
		oOrdServ:oProdLote:SetArmazem(SD3->D3_LOCAL)
		// Dados endereço origem
		oOrdServ:oOrdEndOri:SetArmazem(SD3->D3_LOCAL)
		oOrdServ:oOrdEndOri:SetEnder(cEndereco)
		// Dados endereço destino
		oOrdServ:oOrdEndDes:SetArmazem(SD3->D3_LOCAL)
		oOrdServ:oOrdEndDes:SetEnder("")
		// Dados serviço
		oOrdServ:oServico:SetServico(cServico)
		// Dados documento
		oOrdServ:SetNumSeq(SD3->D3_NUMSEQ)
		oOrdServ:SetDocto(SD3->D3_DOC)
		oOrdServ:SetOrigem("SC2")
		If !(lRet := oOrdServ:CreateDCF())
			WmsMessage(oOrdServ:GetErro(),WMSXFUNH14,1)
		EndIf
	EndIf
	
RestArea(aAreaSD3)
RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Function WmsDelOP(nRecSD3)
//------------------------------------------------------------------------------
Local aAreaAnt   := GetArea()
Local aAreaSD3   := SD3->(GetArea())
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdSerDel := Nil
Local oDmdUnit   := Nil

	SD3->(MsGoTo(nRecSD3))
	If !lWmsNew
		lRet := WmsDelDCF("1","SD3")
	Else
		If SD3->D3_QUANT > 0 .AND. !Empty(SD3->D3_IDDCF)
			If WmsArmUnit(SD3->D3_LOCAL) 
				oDmdUnit := WMSDTCDemandaUnitizacaoDelete():New()
				oDmdUnit:SetIdD0Q(SD3->D3_IDDCF)
				oDmdUnit:LoadData()
				If !(lRet := oDmdUnit:DeleteD0Q())
					WmsMessage(oDmdUnit:GetErro(),WMSXFUNH02,1)
				EndIf
				FreeObj(oDmdUnit)
			Else
				oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
				oOrdSerDel:LoadData()
				If !(lRet := oOrdSerDel:DeleteDCF())
					WmsMessage(oOrdSerDel:GetErro(),WMSXFUNH07,1)
				EndIf
				FreeObj(oOrdSerDel)
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSD3)
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
// Valida se na exclusão ou no encerramento da OP não existem 
// requisições no WMS que ainda não foram atendidas.
//------------------------------------------------------------------------------
Static Function ValIntReq(cOp,cTrt,cIdDCF,nQtdSD4Wms)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Local nTamSx3   := TamSx3("D4_QUANT")

Default cTrt   := ""
Default cIdDCF := ""
	cWhere := "%"
	If !Empty(cTrt)
		cWhere += " AND SD4.D4_TRT = '"+cTrt+"'"
	EndiF
	If !Empty(cIdDCF)
		cWhere += " AND SD4.D4_IDDCF = '"+cIdDCF+"'"
	Else
		cWhere += " AND SD4.D4_IDDCF <> '"+Space(TamSx3("D4_IDDCF")[1])+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT SUM(SD4.D4_QUANT) D4_QUANT,
				SUM(SDC.DC_QUANT) DC_QUANT
		FROM %Table:SD4% SD4
		LEFT JOIN %Table:SDC% SDC
		ON SDC.DC_FILIAL = %xFilial:SDC%
		AND SD4.D4_FILIAL = %xFilial:SD4%
		AND SDC.DC_PRODUTO = SD4.D4_COD
		AND SDC.DC_LOCAL = SD4.D4_LOCAL
		AND SDC.DC_OP = SD4.D4_OP
		AND SDC.DC_TRT = SD4.D4_TRT
		AND SDC.DC_IDDCF = SD4.D4_IDDCF
		AND SDC.%NotDel%
		WHERE SD4.D4_FILIAL = %xFilial:SD4%
		AND SD4.D4_OP = %Exp:cOp%
		AND SD4.D4_QTDEORI > 0
		AND SD4.%NotDel%
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasQry,'D4_QUANT','N',nTamSx3[1],nTamSx3[2])
	TcSetField(cAliasQry,'DC_QUANT','N',nTamSx3[1],nTamSx3[2])
	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->D4_QUANT > 0
		// Se recebeu o parametro, deve retornar o mesmo, caso contrário deve validar
		If ValType(nQtdSD4Wms) == "N"
			nQtdSD4Wms := (cAliasQry)->DC_QUANT
		Else
			If QtdComp((cAliasQry)->D4_QUANT) != QtdComp((cAliasQry)->DC_QUANT)
				WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cOp}}),WMSXFUNH06,,,,STR0007) // "A ordem de produção [VAR01] possui requisições pendentes de atendimento em ordens de serviço de separação no WMS."###"Aguarde a finalização da separação ou exclua a integração das requisições com o WMS para realizar esta operação."
				lRet := .F.
			EndIf
		EndIf
	EndIf 
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
// Executa as regras de Perda por OP relacionadas ao WMS
//------------------------------------------------------------------------------
Function WmsPerdaOP(nRecnoSBC,lEstorno,cProg,nDifD4)
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local lRet      := .T.

Default cProg	:= ""
Default nDifD4	:= 0

	If !lEstorno
		lRet := oEstEnder:MakePerda(nRecnoSBC, cProg, nDifD4)
	Else
		lRet := oEstEnder:UndoPerda(nRecnoSBC)
	EndIf
	If !lRet
		WmsMessage(STR0011 + CRLF + CRLF + oEstEnder:GetErro(),WMSXFUNH16,2) // Problema na integração do Apontamento de Perda com o WMS:
	EndIf
	oEstEnder:Destroy()
Return lRet
//------------------------------------------------------------------------------
// Executa validações WMS na Perda por OP
//------------------------------------------------------------------------------
Function WMSVldPerda(lVldendori,cLocOri,cEnder)
Local lRet := .T.
Local oEndereco := Nil
Default lVldendori := .F. //Valida endereço 
Default cLocOri := ""
Default cEnder := ""

	If !lVldendori
		cLocOri := aCols[n,nPosLoc]
		cEnder := aCols[n,nPosLocFIs]
	EndIf 
	
	If !lVldendori .AND. !Empty(aCols[n,nPosLocDes]+aCols[n,nPosLocFDe]+aCols[n,nPosProDes])
		WmsMessage(STR0031,WMSXFUNH17,5) //"Não é permitido informar Local, Endereço ou Produto Destino para os produtos controlados pelo WMS. Funcionalidade pendente de desenvolvimento."
		lRet := .F.
	EndIf

	// validar aqui se a estrutura fisica do endereço informad e de produção.
	If lRet 
		oEndereco := WMSDTCEndereco():New()
		oEndereco:SetArmazem(cLocOri)
		oEndereco:SetEnder(cEnder)
		If oEndereco:LoadData()	
			If oEndereco:GetTipoEst() <> 7 // Valida para que o apontamento da perda seja pra estrutura do tipo produção
				WmsMessage(STR0032,WMSXFUNH30,5) //"Não é permitido informar Endereço com estrutura diferente de Produção para apontamento de perda de produtos com controle WMS."
				lRet := .F.
			EndIf
		EndIf 
	EndIf 

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsFatMI()
Realiza a movimentação de estoque ao faturar um remito (MI).]
@type function
@author Wander Horongoso
@version 12.1.2210
@since 08/06/2022
@param
Pedido: número do pedido
Item: código do item do pedido
Sequencia: número de sequência do pedido
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Function WmsFatMI(cPedido, cItem, cSeq, cProd,lSc9,cEspecie)
Local lRet := .T. 
Local cQry := ''
Local oEstEnder := nil
Default lSc9:= .T. 
	 
	If SuperGetMV("MV_WMSNEW",.F.,.F.) .And. IntWms(cProd)
		If !lSc9 
			lRet := WmsIntSD2(cEspecie) 
		Else 
			cQry := GetNextAlias()
			BeginSQL Alias cQry
				SELECT R_E_C_N_O_
				FROM %Table:SC9% 
				WHERE C9_FILIAL = %xFilial:SC9%
				AND C9_PEDIDO = %Exp:cPedido%
				AND C9_ITEM = %Exp:cItem%
				AND C9_SEQUEN = %Exp:cSeq%
				AND %NotDel%
			EndSQL
			If !(cQry)->(Eof())
				oEstEnder := WMSDTCEstoqueEndereco():New()
				lRet := oEstEnder:MakeFatur((cQry)->R_E_C_N_O_)
			EndIf

			(cQry)->(dbCloseArea())
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsIntSD2()
Realiza a movimentação de estoque ao faturar um remito de Transferência(MI).
@type function
@author Roselaine Adriano
@version 12.1.2210
@since 05/10/2022
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Static Function WmsIntSD2(cEspecie)
Local lRet     := .T.
Local oOrdServ := Nil
Local aAreaAnt := GetArea()
Local oMovimento := WMSBCCMovimentoServico():New()
Local cAliasQry:= Nil
Local cAliasDCF:= Nil 

	If !FWIsIncallStack("MATA462TN") .OR. Alltrim(cEspecie) <> "RTS"
		Return lRet
	EndIf
	If oOrdServ == Nil
		oOrdServ := WMSDTCOrdemServicoCreate():New()
		WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
	EndIf
	oOrdServ:SetDocto(SD2->D2_DOC)
	oOrdServ:SetSerie(SD2->D2_SERIE)
	oOrdServ:oProdLote:SetProduto(SD2->D2_COD)
	oOrdServ:SetNumSeq(SD2->D2_NUMSEQ)
	oOrdServ:SetOrigem('SD2')
	//busca através do numero do documento da Sd2 o ultimos local destino na tabela DCF para setar os dados para o proxmo 
	cAliasDCF:= GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DISTINCT DCF_ENDDES
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF_DOCTO = %Exp:SD2->D2_DOC%
		AND DCF_SERIE = %Exp:SD2->D2_SERIE%
		AND DCF_STSERV = '3'
		AND DCF.DCF_CLIFOR = %Exp:SD2->D2_CLIENTE%
		AND DCF.DCF_LOJA = %Exp:SD2->D2_LOJA%
		AND DCF.DCF_SERVIC = %Exp:SD2->D2_SERVIC%
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(!Eof())
	    //Se ja havia Setado o endereco setar para o proximo produto automatico sem abrir a tela. 
		oOrdServ:oOrdEndDes:SetEnder((cAliasDCF)->DCF_ENDDES)
	ENDIF
	(cAliasDCF)->(DbCloseArea())

	If !oOrdServ:CreateDCF()
		WmsMessage(oOrdServ:GetErro(),"WmsIntSD2",1)
		lRet := .F.
	EndIf

	//Depois que criou a DCf ja executa e finaliza os movimentos 
	//Executa ordem de serviço
	If lRet
		AAdd(oOrdServ:aLibDCF,oOrdServ:GetIdDCF())
		lRet := WmsExeServ(.F.,.T.,,.F.)
	EndIf

	//Finaliza movimentação oOrdServ:oProdlote:oProduto:GetEndSai()
	If lRet
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_DOC = %Exp:SD2->D2_DOC%
			AND D12.D12_SERIE = %Exp:SD2->D2_SERIE%
			AND D12.D12_CLIFOR = %Exp:SD2->D2_CLIENTE%
			AND D12.D12_LOJA = %Exp:SD2->D2_LOJA%
			AND D12.D12_SERVIC = %Exp:SD2->D2_SERVIC%
			AND D12.D12_PRODUT = %Exp:SD2->D2_COD%
			AND D12.D12_LOTECT = %Exp:SD2->D2_LOTECTL%
			AND D12.D12_NUMLOT = %Exp:SD2->D2_NUMLOTE%
			AND D12.D12_IDDCF  = %Exp:oOrdServ:GetIdDCF()%
			AND D12.%NotDel%
			ORDER BY D12_ORDTAR,
						D12_IDMOV,
						D12_ORDATI
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			oMovimento:GoToD12((cAliasQry)->RECNOD12)
			oMovimento:SetLog("2")
			oMovimento:SetStatus("1")
			oMovimento:SetPrAuto("2")
			oMovimento:SetDataIni(dDataBase)
			oMovimento:SetHoraIni(Time())
			oMovimento:SetDataFim(dDataBase)
			oMovimento:SetHoraFim(Time())
			oMovimento:SetRecHum(__cUserID)
			oMovimento:SetQtdLid(oMovimento:nQtdMovto)
			oMovimento:SetRadioF("2")
			oMovimento:UpdateD12()
			// Finalizar ou Apontar a movimentação
			If oMovimento:IsUltAtiv()
				If oMovimento:IsUpdEst()
					lRet := oMovimento:RecEnter()
					If !lRet 
						WmsMessage(oOrdServ:GetErro()+" "+STR0014,WMSXFUNH19,,,,STR0015)  //"Movimentação WMS Não finalizada". //"Problema na atualização de saldos WMS durante a finalização dos movimentos." 
						EXIT
					EndIF
					
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	//Baixa estoque na DOCA para o documento 
	If lRet
		oEstEnder := WMSDTCEstoqueEndereco():New()
		lRet := oEstEnder:MakeFtMI(SD2->(Recno()),oOrdServ:GetIdDCF(),oMovimento:oMovenddes:cEndereco)
		If !lRet 
			WmsMessage(oOrdServ:GetErro()+" "+STR0016,WMSXFUNH20,,,,STR0017)  //"Erro ao Baixar Estoque WMS (D14)."  //"Movimentos WMS não executados."
		EndIF
	EndIF 
	RestArea(aAreaAnt)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsVldReMI()
Realiza a Validação de tipo de servico e saldo utilizado para remito de transferencia Mercado internacional .
@type function
@author Roselaine Adriano
@version 12.1.2210
@since 10/10/2022
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Function WmsVldReMI(cAliasI,cTipDoc, nLinha, aDadosIOri, aCols, cLocal, cLocaliz,nPosserv,cProd, cEspecie,nQuant,nPosloteCt,nPosNumLot,nPosquant, nPoscod, nPosLocaliz, nPosLocal)
Local lRet := .T. 
Local cWmsSrRT := SuperGetMV("MV_WMSSRRT",.F.,"")  // Servico parametrizado para utilização no remito de Transferência mErcado internacional. 
Local oEstEnder := Nil
Local nSaldoD14 := 0 
Local aSaldos	:= {}
Local aAreaAnt  := Nil
Local oSaldoWMS := Nil
LOCAL nFindEnd	:= 0
LOCAL cLoteAux  := ""
LOCAL cNLoteAux := ""
Local nZ := 0
Local nQuantAux := 0

	If SuperGetMV("MV_WMSNEW",.F.,.F.) .And. IntWms(cProd) .And. cAliasI == 'SD2' .And. cEspecie = 'RTS' .And. FwIsInCallStack('MATA462TN') .And. nLinha > 0 
		If !Empty(cWmsSrRT) 
			DC5->(DbSetOrder(1))
			If DC5->(DbSeek(xFilial("DC5")+cWmsSrRT, .F.))
				If DC5->DC5_TIPO == "2" 
				   aDadosIOri[nLinha][nPosserv]  := cWmsSrRT
				   aCols[nLinha][nPosserv]  := cWmsSrRT
				ENDIF
			ENDIF
		EndIf

		If Empty(aCols[nLinha][nPosserv])
			WmsMessage(STR0019,WMSXFUNH22,,,,STR0020)  //"Produto com controle WMS" // "Informe um serviço de saida."
			lRet := .F. 
		EndIf

		If Empty(cLocaliz)
			WmsMessage(STR0025,WMSXFUNH25,,,,STR0026)  //"Produto com controle de WMS." //"Obrigatório informar o endereço origem."
			lRet := .F. 
		ENDIF 

		If lRet .And. Rastro(cProd) 
		    //Protege o Alias antes da chamada do método WMS
			aAreaAnt := GetArea()
			oSaldoWMS := WMSDTCEstoqueEndereco():New()
			//Consulta o Saldo do Endereço no WMS
			aSaldos  := oSaldoWMS:GetSldEnd(cProd,cLocal,cLocaliz,aDadosIOri[nLinha][nPosloteCt],aDadosIOri[nLinha][nPosNumlot],,1)//cPrdOri,cLocal,cEnder,cLote,cSubLote,cNumSer,nOrdem
			nFindEnd := aScan(aSaldos,  {|x| x[2] == cLocaliz})
			nSaldoD14 := IIf( nFindEnd == 0,0,aSaldos[nFindEnd][6])
			cLoteAux := IIf( nFindEnd == 0,"",aSaldos[nFindEnd][3])
			cNLoteAux:= IIf( nFindEnd == 0,"",aSaldos[nFindEnd][4])
			//Recupera o Alias
			RestArea(aAreaAnt)
			
			If Len(aSaldos) == 1 .AND. !Empty(cLoteAux)
				If nSaldoD14 < nQuant
					WmsMessage(WmsFmtMsg(STR0024,{{"[VAR01]", cValTochar(nSaldoD14)},{"[VAR02]", cLoteAux}}),WMSXFUNH21,,,,STR0021) // "Quantidade saldo WMS indisponível. Saldo WMS: [VAR01] para o LOTE: [VAR02]." "Verifique o Saldo ou informe o LOTE."
					lRet := .F. 
				EndIf
				If lRet .AND. !Empty( nSaldoD14 )
					If Empty(aCols[nLinha, nPosLoteCt])
						aCols[nLinha,nPosLoteCt]    := cLoteAux
						aDadosIOri[nLinha,nPosLoteCt] := cLoteAux
					EndIf 
					If Empty(aCols[nLinha,nPosNumLot])
						aCols[nLinha,nPosNumLot]   := cNLoteAux
						aDadosIOri[nLinha,nPosNumLot] := cNLoteAux
					EndIf
				EndIf 
	    	Else
				//If Empty(aDadosIOri[nLinha][nPosloteCt]) 
					//If Len(aSaldos) > 1 
						WmsMessage(STR0027,WMSXFUNH28,,,,STR0023)  //"Produto com mais de um lote no endereço." //"Obrigatório informar o LOTE."
						lRet := .F.
					//Else
					//	WmsMessage(STR0022,WMSXFUNH23,,,,STR0023)  //"Produto com controle de Rastro" //"Obrigatório informar o LOTE."
					//	lRet := .F. 
					//EndIf
				//Else
				//	If nSaldoD14 < nQuant
				//		WmsMessage(WmsFmtMsg(STR0024,{{"[VAR01]", cValTochar(nSaldoD14)},{"[VAR02]", cLoteAux}}),WMSXFUNH26,,,,STR0028) // "Quantidade saldo WMS indisponível. Saldo WMS: [VAR01] para o LOTE: [VAR02]." "Verifique o Saldo do LOTE."
				//		lRet := .F. 
				//	EndIf
				//EndIf 	
			EndIf 
		EndIf 

		If lRet
			nSaldoD14 := 0 
			//Busca o Saldo do produto geral mesmo quando nao informou endereço 
			oEstEnder := WMSDTCEstoqueEndereco():New()
			oEstEnder:ClearData()
			oEstEnder:oEndereco:SetArmazem(cLocal)
			oEstEnder:oEndereco:SetEnder(cLocaliz)
			oEstEnder:oProdLote:SetProduto(cProd)
			oEstEnder:oProdLote:SetLoteCtl(aDadosIOri[nLinha][nPosloteCt])
			oEstEnder:oProdLote:SetNumLote(aDadosIOri[nLinha][nPosNumlot])
			nSaldoD14 := oEstEnder:ConsultSld(.F./*EntPrevista*/,.T./*SaidPrevista*/,.T./*Empenho*/,.T./*Bloqueado*/)
	 		If nSaldoD14 < nQuant
				WmsMessage(WmsFmtMsg(STR0018,{{"[VAR01]",cValTochar(nSaldoD14)}}),WMSXFUNH24,5/*MSG_HELP*/) // "Quantidade saldo WMS indisponível. Saldo WMS: [VAR01]."
				lRet := .F. 
			ENDIF
		ENDIF

		//buscar a quantidade ja informada no remito para o LOTE
		If lRet
			For nZ := 1 to Len(aCols)
				If !aCols[nZ][Len(aCols[nZ])]
					If Rastro(cProd)
						If 	aCols[nZ][nPosCod] == cProd	.And. aCols[nZ][nPosLoteCt] == cLoteAux	.And. aCols[nZ][nPosNumLot] == cNLoteAux .AND. aCols[nZ][nPosLocal] == cLocal .AND. aCols[nZ][nPosLocaliz] == cLocaliz
							nQuantAux += aCols[nZ][nPosQuant]
						EndIf
					Else 
						If 	aCols[nZ][nPosCod] == cProd	.AND. aCols[nZ][nPosLocal] == cLocal .AND. aCols[nZ][nPosLocaliz] == cLocaliz
							nQuantAux += aCols[nZ][nPosQuant]
						EndIf
					EndIf
				EndIf
			Next
			If nSaldoD14 < nQuantAux
				WmsMessage(WmsFmtMsg(STR0029,{{"[VAR01]",cValTochar(nSaldoD14)}}),WMSXFUNH27,5/*MSG_HELP*/) // "Quantidade saldo WMS indisponível para o documento. Saldo WMS: [VAR01]."
				lRet := .F.
			EndIf
		endIf
		
	ENDIF
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WMSMovRemt()
Realiza a Validação de tipo de servico e saldo utilizado para remito de transferencia Mercado internacional .
@type function
@author Roselaine Adriano
@version 12.1.2210
@since 10/10/2022
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Function WMSMovRemt()
Local lWMSGREM := SuperGetMV("MV_WMSGREM",.F.,.F.)
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
	
	If !lWMSGREM .OR. !lWmsNew .OR. !FindFunction("WMSR459")
	   Return 
	EndIf 

   Pergunte("WMSR459",.F.)   
	MV_PAR01 := SD2->D2_DOC
	MV_PAR02 := SD2->D2_DOC
	MV_PAR03 := SD2->D2_SERIE
	MV_PAR04 := SD2->D2_SERIE
   WMSR459()
   
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsMeInt
	Função que avalia se o pedido de venda esta com todos as atividade do WMS liberadas.
	@murilo.brandao
	@since 08/12/2022
	@version 1.0
	/*/
//-----------------------------------------------------------------------------------
Function WmsMeInt(cProduto,lTela,lAll)
Local lRet := .T.
Default lAll := .F.

If IntWms(cProduto)
	If SC9->C9_BLWMS <> '05'
		lRet := .F.
		IF lTela .And. !lAll
			WmsMessage(STR0030,WMSXFUNH29,5)//"Nesse pedido de venda existe atividades pendentes de execução no WMS."
		EndIf
	EndIf
EndIf

Return lRet
