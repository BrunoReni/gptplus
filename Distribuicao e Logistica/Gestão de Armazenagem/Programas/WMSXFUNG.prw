#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNG.CH"
/*
+---------+--------------------------------------------------------------------+
|Fun��o   | WMSXFUNG - Fun��es WMS Integra��o com Movimenta��es Internas       |
+---------+--------------------------------------------------------------------+
|Objetivo | Dever� agrupar todas as fun��es que ser�o utilizadas em            |
|         | integra��es que estejam relacionadas com o proceso de movimenta��o |
|         | interna (devolu��o/requisi��o) e movimenta��o entre armaz�ns.      |
|         | Valida��es, Gera��o, Estorno...                                    |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSXFUNG01 "WMSXFUNG01"
#DEFINE WMSXFUNG02 "WMSXFUNG02"
#DEFINE WMSXFUNG03 "WMSXFUNG03"
#DEFINE WMSXFUNG04 "WMSXFUNG04"
#DEFINE WMSXFUNG05 "WMSXFUNG05"
#DEFINE WMSXFUNG06 "WMSXFUNG06"
#DEFINE WMSXFUNG07 "WMSXFUNG07"
#DEFINE WMSXFUNG08 "WMSXFUNG08"
#DEFINE WMSXFUNG09 "WMSXFUNG09"
#DEFINE WMSXFUNG10 "WMSXFUNG10"
#DEFINE WMSXFUNG11 "WMSXFUNG11"
#DEFINE WMSXFUNG12 "WMSXFUNG12"
#DEFINE WMSXFUNG13 "WMSXFUNG13"
#DEFINE WMSXFUNG14 "WMSXFUNG14"
#DEFINE WMSXFUNG15 "WMSXFUNG15"
#DEFINE WMSXFUNG16 "WMSXFUNG16"
#DEFINE WMSXFUNG17 "WMSXFUNG17"
#DEFINE WMSXFUNG18 "WMSXFUNG18"
#DEFINE WMSXFUNG19 "WMSXFUNG19"
#DEFINE WMSXFUNG20 "WMSXFUNG20"
#DEFINE WMSXFUNG21 "WMSXFUNG21"
#DEFINE WMSXFUNG22 "WMSXFUNG22"
#DEFINE WMSXFUNG23 "WMSXFUNG23"
#DEFINE WMSXFUNG24 "WMSXFUNG24"
#DEFINE WMSXFUNG25 "WMSXFUNG25"
#DEFINE WMSXFUNG26 "WMSXFUNG26"
#DEFINE WMSXFUNG27 "WMSXFUNG27"
#DEFINE WMSXFUNG28 "WMSXFUNG28"
/*-----------------------------------------------------------------------------
Valida a integra��o da entrada de notas fiscais com WMS
Efetua valida��es com base no cabe�alho das notas fiscais
-----------------------------------------------------------------------------*/
Function WmsAvalDH1(cAcao,cAlias,cRotina,oNil,cEndereco)
Local lRet     := .T.
Local oOrdServ := WmsOrdSer() // Busca referencia do objeto WMS
Local oDmdUnit := Nil

Default cEndereco  := ""

	If cAcao == "1"
		If (cAlias)->DH1_TM <= '500' .And. WmsArmUnit((cAlias)->DH1_LOCAL) //Verifica se armaz�m utiliza unitizador
			oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
			oDmdUnit:SetOrigem('DH1')
			oDmdUnit:SetNumSeq((cAlias)->DH1_NUMSEQ)
			oDmdUnit:SetDocto((cAlias)->DH1_DOC)
			oDmdUnit:oProdLote:SetArmazem((cAlias)->DH1_LOCAL)
			// Dados endere�o origem
			oDmdUnit:oDmdEndOri:SetArmazem((cAlias)->DH1_LOCAL)
			oDmdUnit:oDmdEndOri:SetEnder(cEndereco)
			// Dados endere�o destino
			oDmdUnit:oDmdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
			oDmdUnit:oDmdEndDes:SetEnder((cAlias)->DH1_LOCALI)
			oDmdUnit:CreateD0Q()
		Else
			//-- Somente cria a ordem de servi�o na primeira vez
			If oOrdServ == Nil .OR. (oOrdServ != Nil .AND. GetClassName(oOrdServ) <> "WMSDTCORDEMSERVICOCREATE") 
				oOrdServ := WMSDTCOrdemServicoCreate():New()
				WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
			EndIf

			oOrdServ:SetDocto((cAlias)->DH1_DOC)
			oOrdServ:SetNumSeq((cAlias)->DH1_NUMSEQ)
			oOrdServ:SetCf((cAlias)->DH1_CF) // Tipo de REquisi��o/DEvolu��o
			oOrdServ:SetIdUnit("")
			
			If AllTrim(cRotina) $ "MATA240/MATA241" // Movimenta��o interda de requisi��o/devolu��o
				If (cAlias)->DH1_TM <= '500' // Devolu��o
					// Dados endere�o origem
					oOrdServ:oOrdEndOri:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndOri:SetEnder(cEndereco)
					// Dados endere�o destino
					oOrdServ:oOrdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndDes:SetEnder((cAlias)->DH1_LOCALI)
				Else
					// Requisi��o
					// Dados endere�o origem
					oOrdServ:oOrdEndOri:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndOri:SetEnder((cAlias)->DH1_LOCALI)
					// Dados endere�o destino
					oOrdServ:oOrdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndDes:SetEnder(cEndereco)
				EndIf

				oOrdServ:oProdLote:SetPrdOri((cAlias)->DH1_PRODUT) // Produto Origem
				oOrdServ:oProdLote:SetProduto((cAlias)->DH1_PRODUT) // Produto
				oOrdServ:oProdLote:SetArmazem((cAlias)->DH1_LOCAL) // Armaz�m
				oOrdServ:oProdLote:SetLoteCtl((cAlias)->DH1_LOTECT) // Lote
				oOrdServ:oProdLote:SetNumLote((cAlias)->DH1_NUMLOT) // Sub-Lote

			ElseIf AllTrim(cRotina) $ "MATA260/MATA261/MATA175" // Transfer�ncia
				// Dados endere�o destino
				oOrdServ:oOrdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
				oOrdServ:oOrdEndDes:SetEnder((cAlias)->DH1_LOCALI)

				// Posiciona no primeiro DH1 criado para buscar o endere�o origem
				DH1->(dbSetOrder(2)) //DH1_FILIAL+DH1_DOC+DH1_NUMSEQ
				DH1->(dbSeek(xFilial("DH1")+(cAlias)->(DH1->DH1_DOC+DH1_NUMSEQ) )) //DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ

				// Dados endere�o origem
				oOrdServ:oOrdEndOri:SetArmazem(DH1->DH1_LOCAL)
				oOrdServ:oOrdEndOri:SetEnder(DH1->DH1_LOCALI)

				oOrdServ:oProdLote:SetPrdOri(DH1->DH1_PRODUT) // Produto Origem
				oOrdServ:oProdLote:SetProduto(DH1->DH1_PRODUT) // Produto
				oOrdServ:oProdLote:SetArmazem(DH1->DH1_LOCAL) // Armaz�m
				oOrdServ:oProdLote:SetLoteCtl(DH1->DH1_LOTECT) // Lote
				oOrdServ:oProdLote:SetNumLote(DH1->DH1_NUMLOT) // Sub-Lote
			EndIf

			oOrdServ:oProdLote:LoadData()

			oOrdServ:SetOrigem('DH1')
			If !(lRet := oOrdServ:CreateDCF())
				If cRotina == "MATA241"
					WmsMessage(oOrdServ:GetErro(),"CreateDCF",1)
				Else 
				     WmsMessage(oOrdServ:GetErro(),"CreateDCF",1,.F.)
				EndIF 
			EndIf
			If lRet .And. !oOrdServ:oServico:HasOperac({'1','2'}) // Caso servi�o tenha opera��o de endere�amento, endere�amento crossdocking
				WmsEmpB2B8(.T./*lReserva*/,oOrdServ:nQuant,oOrdServ:oProdLote:GetProduto(),oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oProdLote:GetLoteCtl(),oOrdServ:oProdLote:GetNumLote())
			EndIf
		EndIf
	ElseIf cAcao == "2" //-- Processamento das regras WMS referentes as ordens de servi�o do documento
		//-- Verifica as Ordens de servico geradas para execu��o automatica
		WmsExeServ()
	EndIf
Return lRet

//------------------------------------------------------------------------------
Function WmsAvalSD3(cAcao,cAlias,cRotina,cEndereco)
//------------------------------------------------------------------------------
Local lRet := .T.

	If cAcao == "1" // Integra��o da movimenta��o interna a partir da SD3
		lRet := IntMovInt(cRotina,cEndereco)
	ElseIf cAcao == "2" // Execu��o dos servi�os no WMS
		WmsExeServ()
	ElseIf cAcao == "3" // Valida estorno da movimenta��o interna
		lRet := ValEstMov(cRotina)
	ElseIf cAcao == "4" // Estorna movimenta��o interna
		lRet := EstMovInt()
	ElseIf cAcao == "5" // Chamado pelo A240TudoOk
		lRet := ValIntMov1(cRotina)
	ElseIf cAcao == "6" // Chamado pelo A241LinOk
		lRet := ValIntMov2(cRotina)
	ElseIf cAcao == "7" // Chamado pelo Estorno inventario
		lRet := EstMovInv()	
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Function WmsEmpB2B8(lReserva,nQuant,cProduto,cArmazem,cLoteCtl,cNumLote,lEmpSB8)
//-----------------------------------------------------------------------------
Local cOper := Iif(lReserva,"+","-")
Local nValNovo := 0
Local lRet := .T.
Default lEmpSB8 := .T.

	// Gera��o da reserva SB2
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
	If !SB2->(dbSeek(xFilial("SB2")+cProduto+cArmazem))
		CriaSB2(cProduto,cArmazem)
	EndIf
	nValNovo := SB2->B2_RESERVA + (nQuant * (Iif(cOper == "-",-1,1)))
	GravaB2Emp(cOper,nQuant,"",.T.)
	
	lRet := B2_RESERVA = nValNovo
	If !lRet
		WmsMessage(STR0030,WMSXFUNG26) //Erro ao atualizar Reserva do Estoque (B2_RESERVA)
	EndIf

	// Gera��o da reserva SB8
	If lRet .And. lEmpSB8 .And. Rastro(cProduto) .And. !Empty(cLoteCtl+cNumLote)
		SB8->(dbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		SB8->(dbSeek( xFilial("SB8")+cProduto+cArmazem+cLoteCtl+cNumLote))
		nValNovo := SB8->B8_EMPENHO + (nQuant * (Iif(cOper == "-",-1,1)))
		GravaB8Emp(cOper,nQuant,"",.T.)
		
		lRet := B8_EMPENHO = nValNovo
		If !lRet
			WmsMessage(STR0031,WMSXFUNG27) //Erro ao atualizar Empenho do Estoque por Lote (B8_EMPENHO)
		EndIf
	EndIf

Return lRet

//-----------------------------------------------------------------------------
Function WmsGeraDH1(cRotina, lEmpSB8, lDevolucao)
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local nX         := 0
Local cNumSeq    := ""
Local aItenDH1   := {}
Local oOrdServ   := WmsOrdSer()
Local lCpoUser   := ExistBlock('CPOSDH1')
Local aCpoUser   := {}
Local aCpoAuxUsr := {}
Local nPosAux    := 0
Local nY         := 0
Local nMax       := 0

Default lEmpSB8    := .T.
Default lDevolucao := .T.
	
	nMax := IIf(lDevolucao,2,1)
	// Valida informa��es do objeto para gera��o DH1
	If Empty(oOrdServ:oProdLote:GetProduto())
		WmsMessage(STR0001,WMSXFUNG17) //"Produto n�o informado para gera��o DH1"
		lRet := .F.
	EndIf

	If lRet .And. Empty(oOrdServ:oOrdEndOri:GetArmazem())
		WmsMessage(STR0002,WMSXFUNG18) //"Armaz�m origem n�o informado para gera��o DH1"
		lRet := .F.
	EndIf

	If oOrdServ:GetOrigem() != "SD4"
		If lRet .And. Empty(oOrdServ:oOrdEndOri:GetEnder())
			WmsMessage(STR0003,WMSXFUNG19) //"Endere�o origem n�o informado para gera��o DH1"
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. Empty(oOrdServ:oOrdEndDes:GetArmazem())
		WmsMessage(STR0004,WMSXFUNG20) //"Armaz�m destino n�o informado para gera��o DH1"
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(oOrdServ:GetQuant()) <= 0
		WmsMessage(STR0006,WMSXFUNG22) //"Quantidade n�o informada para gera��o DH1"
		lRet := .F.
	EndIf

	If lRet .And. Empty(oOrdServ:oServico:GetServico())
		WmsMessage(STR0007,WMSXFUNG23) //"Servi�o n�o informado para gera��o DH1"
		lRet := .F.
	EndIf

	If oOrdServ:GetOrigem() != "SD4"
		If lRet .And. oOrdServ:oProdLote:HasRastro() .And. Empty(oOrdServ:oProdLote:GetLoteCtl())
			WmsMessage(STR0008,WMSXFUNG24) //"Lote n�o informado para gera��o DH1"
			lRet := .F.
		EndIf
	
		If lRet .And. oOrdServ:oProdLote:HasRastSub() .And. Empty(oOrdServ:oProdLote:GetNumLote())
			WmsMessage(STR0013,WMSXFUNG25) //"Sub-Lote n�o informado para gera��o DH1"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		// Atribui o c�digo sequencial
		// Caso for origem SD4, entende-se que o n�mero da sequ�ncia j� encontra-se definida na ordem de servi�o previamente criada
		If oOrdServ:GetOrigem() == "SD4" .And. !Empty(oOrdServ:GetNumSeq())
			cNumSeq := oOrdServ:GetNumSeq()
		Else 
			cNumSeq := ProxNum()
			oOrdServ:SetNumSeq(cNumSeq)
		EndIf
		// Gerar a movimentacao de REQUISICAO = 1 / DEVOLUCAO = 2
		For nX := 1 To nMax
			aAdd(aItenDH1,Array(33))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+oOrdServ:oProdLote:GetProduto()))
			aItenDH1[nX][01]/*DH1_FILIAL*/:= xFilial("SD3")
			aItenDH1[nX][02]/*DH1_TM    */:= IIf(nX == 1,"999","499")
			aItenDH1[nX][03]/*DH1_EMISAO*/:= dDataBase
			aItenDH1[nX][04]/*DH1_NUMSEQ*/:= cNumSeq
			aItenDH1[nX][05]/*DH1_PRODUT*/:= oOrdServ:oProdLote:GetProduto()
			aItenDH1[nX][06]/*DH1_LOTECT*/:= oOrdServ:oProdLote:GetLoteCtl()
			aItenDH1[nX][07]/*DH1_LOCAL */:= IIf(nX == 1,oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndDes:GetArmazem())
			aItenDH1[nX][08]/*DH1_LOCALI*/:= IIf(nX == 1,oOrdServ:oOrdEndOri:GetEnder(),oOrdServ:oOrdEndDes:GetEnder())
			aItenDH1[nX][09]/*DH1_QUANT */:= oOrdServ:GetQuant()
			aItenDH1[nX][10]/*DH1_QTSEGU*/:= ConvUm(oOrdServ:oProdLote:GetProduto(),oOrdServ:GetQuant(),0,2)
			aItenDH1[nX][11]/*DH1_TRT   */:= oOrdServ:GetTrt()
			aItenDH1[nX][12]/*DH1_PROJPM*/:= CriaVar("DH1_PROJPM")
			aItenDH1[nX][13]/*DH1_TASKPM*/:= CriaVar("DH1_TASKPM")
			aItenDH1[nX][14]/*DH1_CLVL  */:= CriaVar("DH1_CLVL")
			aItenDH1[nX][15]/*DH1_SERVIC*/:= oOrdServ:oServico:GetServico()
			aItenDH1[nX][16]/*DH1_CC    */:= CriaVar("DH1_CC")
			aItenDH1[nX][17]/*DH1_CONTA */:= SB1->B1_CONTA
			aItenDH1[nX][18]/*DH1_ITEMCT*/:= CriaVar("DH1_ITEMCT")
			aItenDH1[nX][19]/*DH1_STATUS*/:= "1"
			aItenDH1[nX][20]/*DH1_OP    */:= oOrdServ:GetOp()
			aItenDH1[nX][21]/*DH1_NUMSA */:= CriaVar("DH1_NUMSA")
			aItenDH1[nX][22]/*DH1_ITEMSA*/:= CriaVar("DH1_ITEMSA")
			aItenDH1[nX][23]/*DH1_DOC   */:= oOrdServ:GetDocto()
			aItenDH1[nX][24]/*DH1_CF    */:= IIf(nX == 1,"RE4","DE4")
			aItenDH1[nX][25]/*DH1_NUMLOT*/:= IIf(oOrdServ:oProdLote:HasRastSub(),oOrdServ:oProdLote:GetNumLote(),CriaVar("D3_NUMLOTE"))
			aItenDH1[nX][26]/*DH1_NUMSER*/:= CriaVar("D3_NUMSERI")
			aItenDH1[nX][27]/*DH1_CUSTO1*/:= 0
			aItenDH1[nX][28]/*DH1_CUSTO2*/:= 0
			aItenDH1[nX][29]/*DH1_CUSTO3*/:= 0
			aItenDH1[nX][30]/*DH1_CUSTO4*/:= 0
			aItenDH1[nX][31]/*DH1_CUSTO5*/:= 0
			If Empty(oOrdServ:oProdLote:GetDtValid())
			   oOrdServ:oProdLote:SetDtValid(STOD("//"))
			Endif 
			aItenDH1[nX][32]/*DH1_DTVALI*/:= oOrdServ:oProdLote:GetDtValid()
			aItenDH1[nX][33]/*DH1_POTENC*/:= 0
			// Campos extras WMS
			AAdd(aCpoAuxUsr,{})
			nPosAux := Len(aCpoAuxUsr)
			AAdd(aCpoAuxUsr[nPosAux],{"DH1_IDDCF",oOrdServ:GetIdDCF()})
			// Campos extras usu�rio
			If lCpoUser
				aCpoUser := ExecBlock('CPOSDH1',.F.,.F.,{cRotina,nX})
				If ValType(aCpoUser) == 'A'
					For nY := 1 to Len(aCpoUser)
						AAdd(aCpoAuxUsr[nPosAux],{aCpoUser[nY,1],aCpoUser[nY,2]})
					Next nY
				EndIf
			EndIf
		Next nX
		// Grava DH1 sem gerar ordem de servi�o (cGravaWms == "2")
		If (lRet := EspDH1Wms(aItenDH1,cRotina,oOrdServ:oOrdEndDes:GetEnder(),"2"/*cGravaWms*/,Nil,aCpoAuxUsr))
			// Reserva SB2
			lRet := WmsEmpB2B8(.T./*lReserva*/,oOrdServ:GetQuant(),oOrdServ:oProdLote:GetProduto(),oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oProdLote:GetLoteCtl(),oOrdServ:oProdLote:GetNumLote(),lEmpSB8)
		EndIf
	EndIf

Return lRet

//-----------------------------------------------------------------------------
Static Function ValIntMov1(cRotina)
//-----------------------------------------------------------------------------
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oEndereco := Nil
Local aBoxDC8   := {}

	If !Empty(M->D3_SERVIC) .And. M->D3_QUANT > 0
		lRet := WmsVldSrv('6',M->D3_SERVIC,,,,,,M->D3_TM)
		//-- Valida o Preenchimento do campo DOCUMENTO
		If lRet .And. Empty(M->D3_DOC)
			WmsMessage(STR0015,WMSXFUNG08,,,,STR0016) // N�o foi informado o campo documento.##O campo "DOCUMENTO" deve ser preenchido sempre que um movimento interno gerar servi�o de WMS.
			lRet := .F.
		EndIf
	ElseIf !Empty(M->D3_SERVIC) .And. M->D3_QUANT == 0
		WmsMessage(STR0017,WMSXFUNG09,,,,STR0018) // "Servi�o n�o pode ser informado para ajuste de custo!"##"Apague o servi�o WMS informado!"
		lRet := .F.
	ElseIf lWmsNew .And. Empty(M->D3_SERVIC) .And. M->D3_QUANT > 0
		WmsMessage(STR0019,WMSXFUNG10,,,,STR0020) // Servi�o WMS n�o informado! // Informe um servi�o WMS v�lido.
		lRet := .F.
	EndIf
	// Valida se o armaz�m � unitizado e o endere�o � de estrutura que controla unitizador
	If lRet .And. lWmsNew .And. !Empty(M->D3_LOCALIZ) .And. WmsArmUnit(M->D3_LOCAL)
		oEndereco := WMSDTCEndereco():New()
		oEndereco:SetArmazem(M->D3_LOCAL)
		oEndereco:SetEnder(M->D3_LOCALIZ)
		If oEndereco:LoadData()
			If (oEndereco:GetTipoEst() != 2 .And. oEndereco:GetTipoEst() != 5)
				aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
				WmsMessage(WmsFmtMsg(STR0025,{{"[VAR01]",aBoxDC8[oEndereco:GetTipoEst()]}}),WMSXFUNG11,1,,,WmsFmtMsg(STR0026,{{"[VAR01]",aBoxDC8[2]},{"[VAR02]",aBoxDC8[5]}})) // N�o � permitido informar o endere�o origem com estrutura f�sica [VAR01], quando o armaz�m controla unitizador (D3_LOCALIZ). // Informe um endere�o do tipo [picking] ou [doca].
				lRet := .F.
			EndIf
		EndIf
		oEndereco:Destroy()
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Static Function ValIntMov2(cRotina)
//-----------------------------------------------------------------------------
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cServico  := GdFieldGet('D3_SERVIC',n)
Local cArmazem  := GdFieldGet('D3_LOCAL',n)
Local cEndereco := GdFieldGet('D3_LOCALIZ',n)
Local nQtde     := GdFieldGet('D3_QUANT',n)

	If !Empty(cServico) .And. nQtde > 0
		lRet := WmsVldSrv('6',cServico,,,,,,cTm) // cTm - Private
	ElseIf !Empty(cServico) .And. nQtde == 0
		WmsMessage(STR0017,WMSXFUNG12,,,,STR0018) // "Servi�o n�o pode ser informado para ajuste de custo!"##"Apague o servi�o WMS informado!"
		lRet := .F.
	ElseIf lWmsNew .And. Empty(cServico) .And. nQtde > 0
		WmsMessage(STR0019,WMSXFUNG13,,,,STR0020) // "Servi�o WMS n�o informado!"##"Informe um servi�o WMS v�lido."
		lRet := .F.
	EndIf
	// Valida se o armaz�m � unitizado e o endere�o � de estrutura que controla unitizador
	If lRet .And. lWmsNew .And. !Empty(cEndereco) .And. WmsArmUnit(cArmazem)
		oEndereco := WMSDTCEndereco():New()
		oEndereco:SetArmazem(cArmazem)
		oEndereco:SetEnder(cEndereco)
		If oEndereco:LoadData()
			If (oEndereco:GetTipoEst() != 2 .And. oEndereco:GetTipoEst() != 5)
				aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
				WmsMessage(WmsFmtMsg(STR0025,{{"[VAR01]",aBoxDC8[oEndereco:GetTipoEst()]}}),WMSXFUNG14,1,,,WmsFmtMsg(STR0026,{{"[VAR01]",aBoxDC8[2]},{"[VAR02]",aBoxDC8[5]}})) // N�o � permitido informar o endere�o origem com estrutura f�sica [VAR01], quando o armaz�m controla unitizador (D3_LOCALIZ). // Informe um endere�o do tipo [picking] ou [doca].
				lRet := .F.
			EndIf
		EndIf
		oEndereco:Destroy()
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Static Function ValEstMov(cRotina)
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lEstWms    := If(Type('lExecWms')=='L', lExecWms, .F.)
Local oDmdUniDel := Nil
Local oOrdSerDel := Nil
Local cMessage   := ""
Local aMessage   := {}

	If !lWmsNew
		If WmsChkDCF('SD3',,,SD3->D3_SERVIC,'3',,SD3->D3_DOC,,,,SD3->D3_LOCAL,SD3->D3_COD,,,SD3->D3_NUMSEQ)
			lRet := WmsAvalDCF('2')
		EndIf
	ElseIf !lEstWms
		If !Empty(SD3->D3_IDDCF)
			If SD3->D3_TM <= "500" .And. WmsArmUnit(SD3->D3_LOCAL)  //Verifica se deve unitizar o produto
				oDmdUniDel := WMSDTCDemandaUnitizacaoDelete():New()
				oDmdUniDel:SetIdD0Q(SD3->D3_IDDCF)
				If oDmdUniDel:LoadData()
					If !oDmdUniDel:CanDelete()
						cMessage := STR0021+" - DU "+LTrim(oDmdUniDel:GetDocto())+" - ID "+oDmdUniDel:GetIdD0Q()+CRLF // Movimenta��o integrada ao SIGAWMS
						aMessage := StrTokArr2(oDmdUniDel:GetErro(),CRLF)
						AEval(aMessage, {|x| cMessage := cMessage + x + " "}, 1,Len(aMessage)-1)
						WmsHelp(cMessage,aMessage[Len(aMessage)],WMSXFUNG01)
						lRet := .F.
					EndIf
				EndIf
			Else
				oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
				If oOrdSerDel:LoadData()
					If !oOrdSerDel:CanDelete()
						cMessage := STR0021+" - OS "+LTrim(oOrdSerDel:GetDocto())+" - ID "+oOrdSerDel:GetIdDCF()+CRLF // Movimenta��o integrada ao SIGAWMS
						aMessage := StrTokArr2(oOrdSerDel:GetErro(),CRLF)
						AEval(aMessage, {|x| cMessage := cMessage + x + " "}, 1,Len(aMessage)-1)
						WmsHelp(cMessage,aMessage[Len(aMessage)],WMSXFUNG02)
						lRet := .F.
					EndIf
				EndIf
			EndIf
			// Valida se a quantidade saldo do produto n�o ficar� menor que a quantidade reservada
			If lRet .And. SD3->D3_TM <= "500" .And. SD3->D3_QUANT > 0
				// Gera��o da reserva SB2
				dbSelectArea("SB2")
				SB2->(dbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
				If SB2->(dbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)) .And. SB2->B2_RESERVA > 0 .And. SaldoSB2() < 0
					WmsHelp(WmsFmtMsg(STR0029,{{"[VAR01]",AllTrim(SD3->D3_LOCAL)},{"[VAR02]",AllTrim(SD3->D3_COD)}}),,WMSXFUNG15) // H� reservas no armaz�m [VAR01] e produto [VAR02] que comprometem o saldo, estorno n�o permitido!
					lRet := .F.
				ElseIf Rastro(SD3->D3_COD)
					// Gera��o da reserva SB2
					dbSelectArea("SB8")
					SB8->(dbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
					If SB8->(dbSeek(xFilial("SB8")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_LOTECTL+SD3->D3_NUMLOTE)) .And. SB8->B8_EMPENHO > 0 .And. SB8SALDO() < 0
						cMessage := WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(SD3->D3_LOCAL)},{"[VAR02]",AllTrim(SD3->D3_COD)},{"[VAR03]",AllTrim(SD3->D3_LOTECTL)}}) // H� reservas no armaz�m [VAR01] e produto [VAR02] do lote [VAR02] que comprometem o saldo, estorno n�o permitido!
						If !Empty(SD3->D3_NUMLOTE)
							cMessage := WmsFmtMsg(STR0028,{{"[VAR01]",AllTrim(SD3->D3_LOCAL)},{"[VAR02]",AllTrim(SD3->D3_COD)},{"[VAR03]",AllTrim(SD3->D3_LOTECTL)},{"[VAR04]",AllTrim(SD3->D3_NUMLOTE)}}) // H� reservas no armaz�m [VAR01] e produto [VAR02] do lote [VAR02] e sublote [VAR01] que comprometem o saldo, estorno n�o permitido!
						EndIf
						WmsHelp(cMessage ,,WMSXFUNG16)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet .And. !Empty(SD3->D3_IDENT) .And. (Left(SD3->D3_DOC,3) $ "CEX|CFT")
			If Left(SD3->D3_DOC,3) == "CEX"
				cMessage := STR0022+SD3->D3_IDENT // "Movimenta��o autom�tica gerada pelo SIGAWMS para registro de excesso na confer�ncia do recebimento: "
			Else
				cMessage := STR0023+SD3->D3_IDENT // "Movimenta��o autom�tica gerada pelo SIGAWMS para registro de falta na confer�ncia do recebimento: "
			EndIf
			WmsHelp(cMessage,STR0024,WMSXFUNG07) // "Para estorno desta movimenta��o dever� ser reaberto o processo de confer�ncia no WMS."
			lRet := .F.
		EndIf
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Static Function IntMovInt(cRotina,cEndereco)
//-----------------------------------------------------------------------------
Local lRet     := .T.
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local nPosDCF  := 0
Local aLibDCF  := WmsLibDCF() // Busca referencia do array WMS
Local oOrdServ := WmsOrdSer() // Busca referencia do objeto WMS
Local oDmdUnit := Nil

    If SD3->D3_QUANT > 0 
        If !lWmsNew
            WmsCriaDCF("SD3",,,,@nPosDCF)
            //-- Verifica se a execucao do servico de wms sera automatica
            If Empty(nPosDCF)
                lRet := .F.
            ElseIf WmsVldSrv('4',SD3->D3_SERVIC)
                AAdd(aLibDCF,nPosDCF)
            EndIf
        Else
            // Se o armaz�m destino � unitizado, deve gerar uma demanda de unitiza��o
            If WmsArmUnit(SD3->D3_LOCAL)
                oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
                oDmdUnit:SetOrigem('SD3')
                oDmdUnit:SetDocto(SD3->D3_DOC)
                oDmdUnit:SetNumSeq(SD3->D3_NUMSEQ)
                oDmdUnit:SetServico(SD3->D3_SERVIC)
                // Dados endere�o origem
                oDmdUnit:oDmdEndOri:SetArmazem(SD3->D3_LOCAL)
                oDmdUnit:oDmdEndOri:SetEnder(cEndereco)
                // Dados endere�o destino
                oDmdUnit:oDmdEndDes:SetArmazem(SD3->D3_LOCAL)
                oDmdUnit:oDmdEndDes:SetEnder(SD3->D3_LOCALIZ)
                // Gera a demanda de unitiza��o gerando a entrada com base nos endere�os escolhidos
                If !(lRet := oDmdUnit:CreateD0Q())
                    WmsMessage(oDmdUnit:GetErro(),WMSXFUNG03,1)
                EndIf
            // Sen�o simplesmente gera uma ordem de servi�o para a quantidade da SD3
            Else
                //-- Somente cria a ordem de servi�o na primeira vez
                If oOrdServ == Nil
                    oOrdServ := WMSDTCOrdemServicoCreate():New()
                    WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
                EndIf
                oOrdServ:SetOrigem('SD3')
                oOrdServ:SetDocto(SD3->D3_DOC)
                oOrdServ:SetNumSeq(SD3->D3_NUMSEQ)
                oOrdServ:SetServico(SD3->D3_SERVIC)
                // Dados endere�o origem
                oOrdServ:oOrdEndOri:SetArmazem(SD3->D3_LOCAL)
                oOrdServ:oOrdEndOri:SetEnder(cEndereco)
                // Dados endere�o destino
                oOrdServ:oOrdEndDes:SetArmazem(SD3->D3_LOCAL)
                oOrdServ:oOrdEndDes:SetEnder(SD3->D3_LOCALIZ)
                // Gera a ordem de servi�o gerando a entrada com base nos endere�os escolhidos
                If !(lRet := oOrdServ:CreateDCF())
                    WmsMessage(oOrdServ:GetErro(),WMSXFUNG04,1)
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

//-----------------------------------------------------------------------------
Static Function EstMovInt()
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lEstWms    := If(Type('lExecWms')=='L', lExecWms, .F.)
Local oDmdUniDel := Nil
Local oOrdSerDel := Nil

	If !lWmsNew
		WmsDelDCF('1','SD3')
	ElseIf !lEstWms
		// Quando � estorno, est� posicionado no registro do estorno gerado
		// Estorno de TM <= 500 -> 999 | TM > 500 -> 499 - Fixo
		If SD3->D3_TM == "999" .And. WmsArmUnit(SD3->D3_LOCAL)  //Verifica se deve unitizar o produto
			oDmdUniDel := WMSDTCDemandaUnitizacaoDelete():New()
			oDmdUniDel:SetIdD0Q(SD3->D3_IDDCF)
			If oDmdUniDel:LoadData()
				If !(lRet := oDmdUniDel:DeleteD0Q())
					WmsMessage(oDmdUniDel:GetErro(),WMSXFUNG05,1)
				EndIf
			EndIf
		Else
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
			If oOrdSerDel:LoadData()
				If !(lRet := oOrdSerDel:DeleteDCF())
					WmsMessage(oOrdSerDel:GetErro(),WMSXFUNG06,1)
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
/*
@description: Retorna servi�o e endere�o de entrada de produ��o
A tabela D1A � a tabela de complemento de produto para WMS. Foi criada pois a tabela SB1 j� possui 255 campos,
que � a limita��o do GCAD.
@type function
@author Wander Horongoso
@since 29/12/2019
@param
cProduto: c�digo do produto
cServProd: ponteiro com a vari�vel que receber� o c�digo do servi�o de produ��o
cEndProd: ponteiro com a vari�vel que receber� o c�digo do endere�o de produ��o
*/
Function WmsSerEndPr(cProduto,cServProd,cEndProd)
Local cAliasAnt := GetArea()
Local cAliasD1A := ""

	If TableInDic("D1A")
		dbSelectArea("D1A") //usado para criar a tabela enquanto n�o houver cadastro. 

		cAliasD1A := GetNextAlias()
		BeginSql Alias cAliasD1A
			SELECT D1A.D1A_SEREPR,
				D1A.D1A_ENDEPR
			FROM %Table:D1A% D1A
			WHERE D1A.D1A_FILIAL = %xFilial:D1A%
			AND D1A.D1A_COD = %Exp:cProduto%
			AND D1A.%NotDel%
		EndSql
		If (cAliasD1A)->(!EoF())
			cServProd := (cAliasD1A)->D1A_SEREPR 
			cEndProd := (cAliasD1A)->D1A_ENDEPR
		Else
			cServProd := Replicate(' ', TamSX3('D3_SERVIC')[1])
			cEndProd := Replicate(' ', TamSX3('D3_LOCALIZ')[1])	
		EndIf
		(cAliasD1A)->(DbCloseArea())
	EndIf
	
	RestArea(cAliasAnt)
Return

//Rotina chamada do apontamento de produ��o simples ACDV020, para preenchimento
Function WmsAcdv020(aSD3,cProduto)
Local cEndProd := ""
Local cServPod := ""	 

	//Busca servi�o e endere�o de entrada de produ��o
	WmsSerEndPr(cProduto,@cServPod,@cEndProd)

	If !Empty(cEndProd) .And. (aScan(aSD3,{|x| x[1] == "D3_LOCALIZ"}) == 0)
		aadd(aSD3,{"D3_LOCALIZ",cEndProd,nil})
	EndIf

	If !Empty(cServPod) .And. (aScan(aSD3,{|x| x[1] == "D3_SERVIC"}) == 0)
		aadd(aSD3,{"D3_SERVIC",cServPod,nil})
	EndIf

	//Comando obrigat�rio para o execauto do mata250
	aadd(aSD3,{"D3_NUMSERI","",nil})
Return

/*Rotina chamada no MATA240, ao estornar um servi�o criado a partir da gera��o da baixa de pr�-requisi��o (MATA185).
Diferentemente do Materiais, que gera um novo documento a cada baixa, o WMS mant�m o mesmo n�mero de documento.
Com isso, no caso de executar o servi�o, estornar, executar e estornar novamente, � necess�rio selecionar o registro
da SD3 que ainda n�o foi estornado. Antes dessa implementa��o o sistema selecionava sempre o primeiro, j� estornado.
@autor: Wander Horongoso
@data: 22/05/2020
@param: 
*/
Function WmsRecNoD3(aCampos)
Local nInd := 0
Local nRet := 0

	For nInd := 1 To Len(aCampos)
		If aCampos[nInd,1] == 'WMS_R_E_C_N_O_'
			nRet := aCampos[nInd,2]
			Exit
		EndIf
	Next nInd

Return nRet

/*Rotina chamada no MATA185, ao estornar uma baixa de pr�-requisi��o.
Objetivo � obter um array com informa��es a partir da DH1 (tabela auxiliar com as informa��es da SD3)
em substitui��o � leitura da SD3 existente no MATA185.
@autor: Wander Horongoso
@data: 27/05/2020
@param: 
*/
Function Wms185EstA(cProd, cNumReq, cSCQRecNo, dDataFec)
Local cAliasDH1 := GetNextAlias()
Local aBaixas   := {}

	BeginSql Alias cAliasDH1
	  	SELECT DH1.DH1_EMISAO, DH1.DH1_QUANT, DH1.R_E_C_N_O_
	   	FROM %Table:DH1% DH1
	   	WHERE DH1.DH1_FILIAL = %xFilial:DH1%
		AND DH1.DH1_PRODUT = %Exp:cProd%
		AND DH1.DH1_NUMSEQ = %Exp:cNumReq%
		AND DH1.%NotDel%
	EndSql
	Do While !(cAliasDH1)->(Eof())
	  	If dDataFec < sToD((cAliasDH1)->DH1_EMISAO)
	   		aAdd(aBaixas,{.T.,(cAliasDH1)->DH1_EMISAO,Transform((cAliasDH1)->DH1_QUANT,PesqPict("DH1","DH1_QUANT",14)),(cAliasDH1)->R_E_C_N_O_,SCQ->(Recno())})
	   	EndIf
	   	(cAliasDH1)->(dbSkip())
	EndDo
	(cAliasDH1)->(dbCloseArea())

Return aBaixas

/*Rotina chamada no MATA185, ao estornar uma baixa de pr�-requisi��o.
Objetivo � obter informa��es a partir da DH1 (tabela auxiliar com as informa��es da SD3)
em substitui��o � leitura da SD3 existente no MATA185.
@autor: Wander Horongoso
@data: 27/05/2020
@param: 
*/
Function Wms185EstB(nRecNo)
Local aRet := {}

	dbSelectArea("DH1")
	dbGoTo(nRecNo)
	Aadd(aRet,DH1->DH1_QUANT)
	Aadd(aRet,DH1->DH1_PROJPM)
	Aadd(aRet,DH1->DH1_TASKPM)

Return aRet

/*Rotina chamada no MATA185, ao estornar uma baixa de pr�-requisi��o.
Objetivo � excluir a ordem de servi�o gerada na baixa.
@autor: Wander Horongoso
@data: 27/05/2020
@param: 
*/
Function Wms185EstC(nRecNo)
Local oOrdServ := nil
Local lRet := .T.

	dbSelectArea('DCF')
	DCF->(dbSetOrder(9))
	If DCF->(dbSeek(xFilial('DCF')+DH1->DH1_IDDCF))
		oOrdServ := WMSDTCOrdemServicoDelete():New()
		If oOrdServ:GoToDCF(DCF->(Recno()))
			If oOrdServ:CanDelete()
				oOrdServ:DeleteDCF()
			Else
				lRet := .F.
				oOrdServ:ShowWarnig()
			EndIf
		EndIf
	EndIf

Return lRet

//-----------------------------------------------------------------------------
/*Rotina chamada no MATA240, ao estornar um lan�amento de invent�rio.
Objetivo � estornar o lan�amento de ajuste de invent�rio nas tabelas D14, D13 quando WMS novo
@autor: Roselaine Adriano
@data: 07/05/2021

*/
Static Function EstMovInv()
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oProduto   := IIf(lWmsNew,WMSDTCProdutoDadosAdicionais():New(),Nil)
Local oEstEnder  := IIf(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local oMovEstEnd := IIf(lWmsNew,WMSDTCMovimentosEstoqueEndereco():New(),Nil)
Local aProduto   := {}
Local nProduto   := NIL

	If lWmsNew
		oProduto:SetProduto(SD3->D3_COD)
        If oProduto:LoadData()
            // Carrega estrutura do produto x componente
            aProduto := oProduto:GetArrProd()                    
            If Len(aProduto) > 0
                For nProduto := 1 To Len(aProduto)
                    // Carrega dados para Estoque por Endere�o
                    oEstEnder:oEndereco:SetArmazem(SD3->D3_LOCAL)
                    oEstEnder:oEndereco:SetEnder(SD3->D3_LOCALIZ)
                    // Carrega dados produto
                    oEstEnder:oProdLote:SetArmazem(SD3->D3_LOCAL)
                    oEstEnder:oProdLote:SetPrdOri(SD3->D3_COD)                 // Produto Origem
                    oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
                    oEstEnder:oProdLote:SetLoteCtl(SD3->D3_LOTECTL)               // Lote do produto principal que dever� ser o mesmo no componentes
                    oEstEnder:oProdLote:SetNumLote(SD3->D3_NUMLOTE)               // Sub-Lote do produto principal que dever� ser o mesmo no componentes
                    oEstEnder:oProdLote:SetNumSer(SD3->D3_NUMSERI)                 // Numero de serie
                    oEstEnder:LoadData()
                    oEstEnder:SetQuant(QtdComp(SD3->D3_QUANT * aProduto[nProduto][2]) )
                    // Realiza Entrada Armazem Estoque por Endere�o
                    // Seta o bloco de c�digo para informa��es do documento
					oEstEnder:SetBlkDoc({|oMovEstEnd|;
										oMovEstEnd:SetOrigem("SB7"),;
										oMovEstEnd:SetDocto(SD3->D3_DOC),;
										oMovEstEnd:SetNumSeq(SD3->D3_NUMSEQ);
					})
					// Seta o bloco de c�digo para informa��es do movimento para o Kardex
    				oEstEnder:SetBlkMov({|oMovEstEnd|;
        							oMovEstEnd:SetIdUnit(oEstEnder:cIdUnitiz);
    				})
					lRet := oEstEnder:UpdSaldo(SD3->D3_TM,.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T., /*lMovEstEnd*/)
					If !lRet
					   Exit
					EndIf 
				Next
            EndIf
        EndIf    
	EndIf
Return lRet

