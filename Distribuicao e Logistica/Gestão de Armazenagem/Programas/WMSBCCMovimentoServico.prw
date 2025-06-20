#Include "Totvs.ch"
#Include "WMSBCCMovimentoServico.ch"
//------------------------------------------------------------------------------
// Fun��o para permitir que a classe seja visualizada no inspetor de objetos
//------------------------------------------------------------------------------
Function WMSCLS0059()
Return Nil
//------------------------------------------------------------------------------
CLASS WMSBCCMovimentoServico FROM WMSDTCMovimentosServicoArmazem
	DATA aColetor AS ARRAY
	DATA aConfEnd AS ARRAY
	METHOD New() CONSTRUCTOR
	METHOD Destroy()
	// Method Gets
	METHOD GetArrCol()
	METHOD GetArrConf()
	// Method inicializa��o array
	METHOD IniArrCol()
	METHOD IniArrConf()
	// Method processos
	METHOD RecEnter()
	METHOD RunInput()
	METHOD RecExit()
	METHOD RunOutput()
	METHOD MkInOutOri()
	METHOD UpdLibCrs()
	METHOD UpdUltMov()
	METHOD UpdSepMov()
	METHOD UpdLibSer()
	METHOD UpdEmpSDC()
	METHOD UpdLibVol()
	METHOD MakeTrfSD3()
	METHOD MakeUpdSD3()
	METHOD UpdMntVol(nQtde,cVolume)
	METHOD HasUsrAtv(cRecHum,cFuncao,cUsuArma)
	METHOD OrdColetor(nOriDest)
	METHOD UpdEndMov(nTipo,cNewEnd,cNewUnit, cNewTip)
	METHOD UpdEndOri(cNewEnd,cNewEnd,cNewUnit, cNewTip)
	METHOD UpdEndDes(cNewEnd,cNewEnd,cNewUnit, cNewTip)
	METHOD HitMovEst()
	METHOD ValCapReab()
	METHOD ValMntExc()
	METHOD ValTrocEnd(cEndDest)
	METHOD HasPrdSep()
	METHOD ChkSitMov()
	METHOD ChkFinMov(aErroFin)
	METHOD HasMoreMov()
	METHOD HasMoreEnd(nTipo,cEndereco)
	METHOD UpdSldDis()
	METHOD AllMovPend()
ENDCLASS

METHOD New() CLASS WMSBCCMovimentoServico
	_Super:New()
	Self:aColetor := {}
	Self:aConfEnd := {}
Return

METHOD Destroy() CLASS WMSBCCMovimentoServico
	//FreeObj(Self)
Return Nil

METHOD GetArrCol() CLASS WMSBCCMovimentoServico
Return Self:aColetor

METHOD GetArrConf() CLASS WMSBCCMovimentoServico
Return Self:aConfEnd

METHOD IniArrCol() CLASS WMSBCCMovimentoServico
	Self:aColetor := {}
Return

METHOD IniArrConf() CLASS WMSBCCMovimentoServico
	Self:aConfEnd := {}
Return

//--------------------------------------------------
/*/{Protheus.doc} RecEnter
Grava entrada
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD RecEnter() CLASS WMSBCCMovimentoServico
Local aAreaAnt     := GetArea()
Local lRet         := .T.
Local oBlqSaldo    := Nil
Local oTrfBlqItens := Nil
	// Ao confirmar a ultima atividade da tarefa registrar o movimento de estoque.
	// Grava o Kardex com uma movimenta��o de saida do endereco origem e uma entrada do endere�o destino
	// Carrega dados para Estoque por Endere�o
	// Realiza uma baixa da quantidade de estoque e de saida prevista do endereco origem
	lRet := Self:RunOutput()
	// Realiza uma baixa da entrada prevista e um acrescimo da quantidade de estoque do endereco destino
	If lRet
		lRet := Self:RunInput()
	EndIf
	//Realiza a libera��o da quantidade de saldo a distribuir
	If lRet .And. Self:oMovServic:ChkRecebi()
		lRet := Self:UpdSldDis()
	EndIf
	
	If lRet .And. !Empty(Self:oOrdServ:GetIdOrig())
		lRet := Self:MkInOutOri()
	EndIf
	If lRet
		If (Self:oMovServic:ChkTransf() .Or. Self:oMovServic:ChkRecebi())
			lRet := Self:UpdUltMov()
		EndIf
	EndIf
	If lRet .And. Self:oMovServic:ChkTransf() .And. TableInDic("D18", .F.)
		oTrfBlqItens := WMSDTCTransferenciaBloqueioSaldoItens():New()
		If !(lRet := oTrfBlqItens:GerarBloqueioNoEnderecoDestino(Self:GetIdDCF(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEnder(),Self:cUniDes))
			Self:cErro := oTrfBlqItens:GetErro()
		EndIf
	EndIf
	If lRet .And. WmsX212118("D0V")
		//Registra bloqueio de saldo na D14 e D0V
		If lRet .And. Self:oMovServic:ChkRecebi() .And. Self:oMovServic:ChkBlqSld()
			oBlqSaldo := WMSDTCBloqueioSaldoItens():New()
			oBlqSaldo:SetMovServ(Self)
			oBlqSaldo:AssignD0V()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} RecExit
Grava sa�da
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD RecExit() CLASS WMSBCCMovimentoServico
Local lRet       := .T.

	// Ao confirmar a ultima atividade da tarefa registrar o movimento de estoque.
	// Grava o Kardex com uma movimenta��o de saida do endereco origem e uma entrada do endere�o destino
	// Atualiza��o baixa saida prevista e baixa estoque do endereco origem
	lRet := Self:RunOutput()
	// baixa entrada prevista entrada estoque e gera empenho do endereco destino
	If lRet
		lRet := Self:RunInput()
	EndIf
	If lRet .And. Self:oMovServic:ChkReabast()
		// Liberar separa��o dependente do reabastecimento
		lRet := Self:UpdLibSer()
	EndIf

	If lRet .And. Self:oMovServic:ChkSepara()
		If Self:oOrdServ:GetOrigem() $ 'SC9|SD4'
			// Empenha pedido e verifica se libera pedido na tarefa de separa��o
			lRet := Self:UpdEmpSDC()
		EndIf
		// Grava quantidade separada na conferencia de expedicao, distribuicao de separacao e montagem de volume
		If lRet .And. Self:oOrdServ:GetOrigem() == 'SC9'
			lRet:= Self:UpdSepMov()
			// Verifica se a libera��o do pedido e na montagem de volume e se a montagem � durante a separa��o
			If lRet .And. Self:GetLibPed() == "6" .And. Self:ChkMntVol("1")
				Self:UpdLibVol()
			EndIf
		EndIf
		// Gera movimento interno de requisi��o
		If lRet .And. Self:oOrdServ:GetOrigem() == 'DH1'
			lRet := Self:MakeUpdSD3()
		EndIf
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} RunOutput
Gera uma saida estoque e uma baixa saida prevista
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD RunOutput() CLASS WMSBCCMovimentoServico
Local lEmpPrev   := Self:oMovServic:ChkSepara()
Local lRet       := .T.
Local lUsaCalc   := .T.
Local aTamSX3    := {}
Local oOrdSerAux := Nil
Local cAliasD14  := ""
	// Carrega dados para LoadData EstEnder
	Self:oEstEnder:ClearData()
	// Verifica se a movimenta��o de estoque pode ser usada nos c�lculo de estoque
	If Self:oMovServic:ChkTransf() .And. !Empty(Self:oOrdServ:GetIdOrig())
		oOrdSerAux := WMSDTCOrdemServico():New()
		oOrdSerAux:SetIdDCF(Self:oOrdServ:GetIdOrig())
		If oOrdSerAux:LoadData() .And. oOrdSerAux:oServico:HasOperac({'1','2'})
			lUsaCalc := .F.
		EndIf
		oOrdSerAux:Destroy()
	EndIf
	If Self:IsMovUnit()
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT D14.D14_CODUNI,
					D14.D14_PRDORI,
					D14.D14_PRODUT,
					D14.D14_LOTECT,
					D14.D14_NUMLOT,
					D14.D14_QTDSPR
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D14.D14_LOCAL = %Exp:Self:oMovEndOri:GetArmazem()%
			AND D14.D14_ENDER = %Exp:Self:oMovEndOri:GetEnder()%
			AND D14.%NotDel%
		EndSql
		aTamSX3 := TamSx3("D14_QTDSPR"); TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
		If (cAliasD14)->(!Eof())
			Do While lRet .And. (cAliasD14)->(!Eof())
				// Carrega dados para LoadData EstEnder
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndOri:GetArmazem()) // Armazem
				Self:oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)   // Produto Origem - Componente
				Self:oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT) // Produto Principal
				Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote do produto principal que dever� ser o mesmo no componentes
				Self:oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
				Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
				//Self:oEstEnder:SetTipUni((cAliasD14)->D14_CODUNI) // Registro j� est� na D14, n�o informar para n�o sobrepor
				Self:oEstEnder:SetQuant((cAliasD14)->D14_QTDSPR)
				// Seta o bloco de c�digo para informa��es do documento para o Kardex
				Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem(Self:oOrdServ:GetOrigem()),;
					oMovEstEnd:SetDocto(Self:oOrdServ:GetDocto()),;
					oMovEstEnd:SetSerie(Self:oOrdServ:GetSerie()),;
					oMovEstEnd:SetCliFor(Self:oOrdServ:GetCliFor()),;
					oMovEstEnd:SetLoja(Self:oOrdServ:GetLoja()),;
					oMovEstEnd:SetNumSeq(Self:oOrdServ:GetNumSeq()),;
					oMovEstEnd:SetIdDCF(Self:GetIdDCF());
				})
				// Seta o bloco de c�digo para informa��es do movimento para o Kardex
				Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
					oMovEstEnd:SetIdMovto(Self:GetIdMovto()),;
					oMovEstEnd:SetIdOpera(Self:GetIdOpera()),;
					oMovEstEnd:SetIdUnit(Self:cIdUnitiz),;
					oMovEstEnd:SetlUsaCal(lUsaCalc);
				})
				If !Self:oEstEnder:UpdSaldo('999',.T./*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev /*lEmpPrev*/,.T./*lMovEstEnd*/)
					Self:cErro := Self:oEstEnder:GetErro()
					lRet := .F.
					Exit
				EndIf
				(cAliasD14)->(dbSkip())
			EndDo
		Else
			Self:cErro := WmsFmtMsg(STR0001,{{"[VAR01]",Self:cIdUnitiz}}) // N�o foi encontrado o saldo por endere�o do unitizador [VAR01].
			lRet := .F.
		EndIf
		(cAliasD14)->(DbCloseArea())
	Else
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
		Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
		Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
		Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
		Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que dever� ser o mesmo no componentes
		Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
		Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
		//Self:oEstEnder:SetTipUni(Self:cTipUni) // Registro j� est� na D14, n�o informar para n�o sobrepor
		Self:oEstEnder:SetQuant(Self:nQtdMovto)
		// Seta o bloco de c�digo para informa��es do documento
		Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetOrigem(Self:oOrdServ:GetOrigem()),;
			oMovEstEnd:SetDocto(Self:oOrdServ:GetDocto()),;
			oMovEstEnd:SetSerie(Self:oOrdServ:GetSerie()),;
			oMovEstEnd:SetCliFor(Self:oOrdServ:GetCliFor()),;
			oMovEstEnd:SetLoja(Self:oOrdServ:GetLoja()),;
			oMovEstEnd:SetNumSeq(Self:oOrdServ:GetNumSeq()),;
			oMovEstEnd:SetIdDCF(Self:GetIdDCF());
		})
		// Seta o bloco de c�digo para informa��es do movimento
		Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
			oMovEstEnd:SetIdMovto(Self:GetIdMovto()),;
			oMovEstEnd:SetIdOpera(Self:GetIdOpera()),;
			oMovEstEnd:SetlUsaCal(lUsaCalc);
		})
		If !Self:oEstEnder:UpdSaldo('999',.T./*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev /*lEmpPrev*/,.T./*lMovEstEnd*/)
			Self:cErro := Self:oEstEnder:GetErro()
			lRet := .F.
		EndIf
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} RunInput
Gera uma entrada
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD RunInput() CLASS WMSBCCMovimentoServico
Local lRet       := .T.
Local lEmpenho   := .F.
Local lBloqueio  := .F.
Local lUsaCalc   := .T.
Local aTamSX3    := {}
Local oOrdSerAux := Nil
Local cAliasQry  := ""

	// Verifica se a movimenta��o de estoque pode ser usada nos c�lculo de estoque
	If Self:oMovServic:ChkTransf() .And. !Empty(Self:oOrdServ:GetIdOrig())
		oOrdSerAux := WMSDTCOrdemServico():New()
		oOrdSerAux:SetIdDCF(Self:oOrdServ:GetIdOrig())
		If oOrdSerAux:LoadData() .And. oOrdSerAux:oServico:HasOperac({'1','2'})
			lUsaCalc := .F.
		EndIf
		oOrdSerAux:Destroy()
	EndIf
	If Self:oMovServic:ChkSepara() .And. !(Self:oOrdServ:GetOrigem() == "SD4")
		lEmpenho := .T.
	EndIf

	// Carrega dados para LoadData EstEnder
	Self:oEstEnder:ClearData()
	If Self:IsMovUnit()
		// Se for uma transfer�ncia de estorno de endere�amento e a origem for um picking
		// N�o possui saldo por unitizador, neste caso deve carregar o saldo inicial do unitizador
		If Self:oMovServic:ChkRecebi() .And. Self:oMovEndDes:GetTipoEst() == 2
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D0S.D0S_PRDORI,
						D0S.D0S_CODPRO,
						D0S.D0S_LOTECT,
						D0S.D0S_NUMLOT,
						D0S.D0S_QUANT
				FROM %Table:D0S% D0S
				INNER JOIN %Table:D0Q% D0Q
				ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
				AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
				AND D0Q.%NotDel%
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:cIdUnitiz%
				AND D0S.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D0S_QUANT"); TcSetField(cAliasQry,'D0S_QUANT','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				Do While (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
					Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
					Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndDes:GetArmazem()) // Armazem
					Self:oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D0S_PRDORI)   // Produto Origem - Componente
					Self:oEstEnder:oProdLote:SetProduto((cAliasQry)->D0S_CODPRO) // Produto Principal
					Self:oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D0S_LOTECT) // Lote do produto principal que dever� ser o mesmo no componentes
					Self:oEstEnder:oProdLote:SetNumLote((cAliasQry)->D0S_NUMLOT) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
					Self:oEstEnder:SetIdUnit("") // Picking n�o controla unitizador
					Self:oEstEnder:SetTipUni("") // Picking n�o controla unitizador
					Self:oEstEnder:SetQuant((cAliasQry)->D0S_QUANT)
					// Seta o bloco de c�digo para informa��es do documento para o Kardex
					Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
												oMovEstEnd:SetOrigem(Self:oOrdServ:GetOrigem()),;
												oMovEstEnd:SetDocto(Self:oOrdServ:GetDocto()),;
												oMovEstEnd:SetSerie(Self:oOrdServ:GetSerie()),;
												oMovEstEnd:SetCliFor(Self:oOrdServ:GetCliFor()),;
												oMovEstEnd:SetLoja(Self:oOrdServ:GetLoja()),;
												oMovEstEnd:SetNumSeq(Self:oOrdServ:GetNumSeq()),;
												oMovEstEnd:SetIdDCF(Self:GetIdDCF());
					})
					// Seta o bloco de c�digo para informa��es do movimento para o Kardex
					Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
												oMovEstEnd:SetIdMovto(Self:GetIdMovto()),;
												oMovEstEnd:SetIdOpera(Self:GetIdOpera()),;
												oMovEstEnd:SetIdUnit(Self:cUniDes),;
												oMovEstEnd:SetlUsaCal(lUsaCalc);
					})
					lRet := Self:oEstEnder:UpdSaldo('499',.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,lEmpenho,lBloqueio,/*lEmpPrev*/,.T./*lMovEstEnd*/)
					If lRet
						lRet := Self:oEstEnder:UpdSaldo('999',.F./*lEstoque*/,.T./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,/*lEmpPrev*/,.F./*lMovEstEnd*/)
					EndIf
					If !lRet
						Self:cErro := Self:oEstEnder:GetErro()
						Exit
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0001,{{"[VAR01]",Self:cIdUnitiz}}) // N�o foi encontrado o saldo por endere�o do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		Else
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D14.D14_CODUNI,
						D14.D14_PRDORI,
						D14.D14_PRODUT,
						D14.D14_LOTECT,
						D14.D14_NUMLOT,
						D14.D14_QTDEPR
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:cUniDes%
				AND D14.D14_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
				AND D14.D14_ENDER = %Exp:Self:oMovEndDes:GetEnder()%
				AND D14.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D14_QTDEPR"); TcSetField(cAliasQry,'D14_QTDEPR','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				Do While (cAliasQry)->(!Eof())
					// Carrega dados para LoadData EstEnder
					Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
					Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
					Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndDes:GetArmazem()) // Armazem
					Self:oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D14_PRDORI)   // Produto Origem - Componente
					Self:oEstEnder:oProdLote:SetProduto((cAliasQry)->D14_PRODUT) // Produto Principal
					Self:oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D14_LOTECT) // Lote do produto principal que dever� ser o mesmo no componentes
					Self:oEstEnder:oProdLote:SetNumLote((cAliasQry)->D14_NUMLOT) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
					Self:oEstEnder:SetIdUnit(Self:cUniDes)
					//Self:oEstEnder:SetTipUni((cAliasQry)->D14_CODUNI) // Registro j� existe na D14 com o tipo de unitizador, n�o informar para n�o sobrepor
					Self:oEstEnder:SetQuant((cAliasQry)->D14_QTDEPR)
					// Seta o bloco de c�digo para informa��es do documento para o Kardex
					Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
						oMovEstEnd:SetOrigem(Self:oOrdServ:GetOrigem()),;
						oMovEstEnd:SetDocto(Self:oOrdServ:GetDocto()),;
						oMovEstEnd:SetSerie(Self:oOrdServ:GetSerie()),;
						oMovEstEnd:SetCliFor(Self:oOrdServ:GetCliFor()),;
						oMovEstEnd:SetLoja(Self:oOrdServ:GetLoja()),;
						oMovEstEnd:SetNumSeq(Self:oOrdServ:GetNumSeq()),;
						oMovEstEnd:SetIdDCF(Self:GetIdDCF());
					})
					// Seta o bloco de c�digo para informa��es do movimento para o Kardex
					Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
						oMovEstEnd:SetIdMovto(Self:GetIdMovto()),;
						oMovEstEnd:SetIdOpera(Self:GetIdOpera()),;
						oMovEstEnd:SetlUsaCal(lUsaCalc);
					})
					lRet := Self:oEstEnder:UpdSaldo('499',.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,lEmpenho,lBloqueio,/*lEmpPrev*/,.T./*lMovEstEnd*/)
					If lRet
						lRet := Self:oEstEnder:UpdSaldo('999',.F./*lEstoque*/,.T./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,/*lEmpPrev*/,.F./*lMovEstEnd*/)
					EndIf
					If !lRet
						Self:cErro := Self:oEstEnder:GetError()
						Exit
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				Self:cErro := WmsFmtMsg(STR0001,{{"[VAR01]",Self:cUniDes}}) // N�o foi encontrado o saldo por endere�o do unitizador [VAR01].
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	Else
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
		Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
		Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
		Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
		Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que dever� ser o mesmo no componentes
		Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
		Self:oEstEnder:SetIdUnit(Self:cUniDes)
		//Self:oEstEnder:SetTipUni(Self:cTipUni)
		Self:oEstEnder:SetQuant(Self:nQtdMovto)
		// Seta o bloco de c�digo para informa��es do documento para o Kardex
		Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetOrigem(Self:oOrdServ:GetOrigem()),;
			oMovEstEnd:SetDocto(Self:oOrdServ:GetDocto()),;
			oMovEstEnd:SetSerie(Self:oOrdServ:GetSerie()),;
			oMovEstEnd:SetCliFor(Self:oOrdServ:GetCliFor()),;
			oMovEstEnd:SetLoja(Self:oOrdServ:GetLoja()),;
			oMovEstEnd:SetNumSeq(Self:oOrdServ:GetNumSeq()),;
			oMovEstEnd:SetIdDCF(Self:GetIdDCF());
		})
		// Seta o bloco de c�digo para informa��es do movimento para o Kardex
		Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
			oMovEstEnd:SetIdMovto(Self:GetIdMovto()),;
			oMovEstEnd:SetIdOpera(Self:GetIdOpera()),;
			oMovEstEnd:SetIdUnit(Self:cUniDes),;
			oMovEstEnd:SetlUsaCal(lUsaCalc);
		})
		lRet := Self:oEstEnder:UpdSaldo('499',.T./*lEstoque*/,.F./*lEntPrev*/,.F./*lSaiPrev*/,lEmpenho,lBloqueio,/*lEmpPrev*/,.T./*lMovEstEnd*/)
		If lRet
			lRet := Self:oEstEnder:UpdSaldo('999',.F./*lEstoque*/,.T./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,/*lEmpPrev*/,.F./*lMovEstEnd*/)
		EndIf
		If !lRet
			Self:cErro := Self:oEstEnder:GetErro()
		EndIf
	EndIf
Return lRet
//-----------------------------------------------------------------------------
METHOD MkInOutOri() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local lEmpPrev  := .F.
Local aTamSX3   := {}
Local oOrdSerAux:= WMSDTCOrdemServico():New()
Local cAliasD13 := ""
Local cAliasD14 := ""
	oOrdSerAux:SetIdDCF(Self:oOrdServ:GetIdOrig())
	If oOrdSerAux:LoadData()
		If oOrdSerAux:ChkMovEst()
			// valida se n�o � servico de separa��o e servico de reabastecimento
			lEmpPrev := oOrdSerAux:oServico:HasOperac({'3','4','5'})
			Self:oEstEnder:ClearData()
			If Self:IsMovUnit()
				cAliasD14 := GetNextAlias()
				BeginSql Alias cAliasD14
					SELECT D14.D14_CODUNI,
							D14.D14_PRDORI,
							D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_QTDEST
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:Self:cUniDes%
					AND D14.D14_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
					AND D14.D14_ENDER = %Exp:Self:oMovEndDes:GetEnder()%
					AND D14.%NotDel%
				EndSql
				aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
				If (cAliasD14)->(!Eof())
					While lRet .And. (cAliasD14)->(!Eof())
						// Carrega dados para LoadData EstEnder
						Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
						Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
						Self:oEstEnder:oProdLote:SetArmazem(Self:oMovEndDes:GetArmazem()) // Armazem
						Self:oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)   // Produto Origem - Componente
						Self:oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT) // Produto Principal
						Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote do produto principal que dever� ser o mesmo no componentes
						Self:oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
						Self:oEstEnder:SetIdUnit(Self:cUniDes)
						//Self:oEstEnder:SetTipUni((cAliasD14)->D14_CODUNI) // Registro j� est� na D14, n�o precisa informar
						Self:oEstEnder:SetQuant((cAliasD14)->D14_QTDEST)
						lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
						If lRet .And. oOrdSerAux:ChkMovEst(.F.)
							// Soma uma entrada prevista no endere�o origem
							Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
							Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
							Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
							Self:oEstEnder:SetTipUni(Iif(Self:cUniDes==Self:cIdUnitiz,(cAliasD14)->D14_CODUNI,Self:cTipUni))
							lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
						EndIf
						If !lRet
							Self:cErro := Self:oEstEnder:GetErro()
						EndIf
						(cAliasD14)->(dbSkip())
					EndDo
				Else
					Self:cErro := WmsFmtMsg(STR0001,{{"[VAR01]",Self:cUniDes}}) // N�o foi encontrado o saldo por endere�o do unitizador [VAR01].
					lRet := .F.
				EndIf
				(cAliasD14)->(dbCloseArea())
			Else
				// Carrega dados para LoadData EstEndEr
				Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
				Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
				Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
				Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
				Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que dever� ser o mesmo no componentes
				Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
				Self:oEstEnder:SetIdUnit(Self:cUniDes)
				//Self:oEstEnder:SetTipUni(Self:cTipUni) // Registro j� est� na D14, n�o precisa informar
				Self:oEstEnder:SetQuant(Self:nQtdMovto)
				// Soma uma saida prevista no endere�o destino
				lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev)
				If lRet .And. oOrdSerAux:ChkMovEst(.F.)
					// Soma uma entrada prevista no endere�o origem
					Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
					Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
					Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
					If !(Self:cUniDes==Self:cIdUnitiz)
						Self:oEstEnder:SetTipUni(Self:cTipUni)
					EndIf
					lRet := Self:oEstEnder:UpdSaldo('499',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/)
				EndIf
				If !lRet
					Self:cErro := Self:oEstEnder:GetErro()
				EndIf
			EndIf
		EndIf
		// Verifica os movimentos da ordem de servi�o origem para desconsiderar
		// no c�lculo de estoque 
		If lRet .And. oOrdSerAux:oServico:HasOperac({'1','2'}) .And. WmsX312118("D13","D13_USACAL") .And. WmsX312118("DCF","DCF_IDMVOR")
			cAliasD13 := GetNextAlias()
			BeginSql Alias cAliasD13
				SELECT D13.R_E_C_N_O_ RECNOD13
				FROM %Table:D13% D13
				WHERE D13.D13_FILIAL = %xFilial:D13%
				AND D13.D13_IDDCF = %Exp:Self:oOrdServ:GetIdOrig()%
				AND D13.D13_IDMOV = %Exp:Self:oOrdServ:GetIdMovOr()%
				AND D13.D13_USACAL <> '2'
				AND D13.%NotDel%
			EndSql
			Do While (cAliasD13)->(!Eof())
				D13->(dbGoTo((cAliasD13)->RECNOD13))
				RecLock("D13",.F.)
				D13->D13_USACAL = '2'
				D13->(MsUnLock())
				(cAliasD13)->(dbSkip())
			EndDo
			(cAliasD13)->(dbCloseArea())
		EndIf
	EndIf
	oOrdSerAux:Destroy()
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdLibCrs
Atualiza libera��o cross
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdLibCrs() CLASS WMSBCCMovimentoServico
Local aAreaD12   := D12->(GetArea())
Local aAreaSC9   := SC9->(GetArea())
Local oServico   := WMSDTCServicoTarefa():New()
Local lRet       := .T.
Local lRetPE     := .T.
Local lUPDLIB01  := ExistBlock('UPDLIB01')
Local cAliasDCF  := ""
Local cAliasAux  := ""
Local cAliasSC9  := ""
Local cAliasD08  := ""
Local nQtdTot    := 0
Local nQuant     := 0
Local nNewRecno  := 0
Local nRecD08    := 0

Private oOrdServ  := WMSDTCOrdemServicoCreate():New()
	WmsOrdSer(oOrdServ)
	// Busca todos os documentos aglutinados ao movimento
	cAliasDCF := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DISTINCT DCF.DCF_ID,
				DCF.DCF_SEQUEN,
				DCF.DCF_QUANT
		FROM %Table:DCR% DCR
		INNER JOIN %Table:DCF% DCF
		ON DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCF.DCF_ID = DCR.DCR_IDDCF
		AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
		AND DCF.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
		AND DCR.DCR_SEQUEN = %Exp:Self:GetSequen()%
		AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
		AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
		AND DCR.%NotDel%
	EndSql
	Do While lRet .And. (cAliasDCF)->(!Eof())
		// Busca a quantidade total que j� foi endere�ada
		cAliasAux := GetNextAlias()
		BeginSql Alias cAliasAux
			SELECT SUM( (DCR.DCR_QUANT / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) / CASE WHEN D11B.QTD_FILHOS IS NULL THEN 1 ELSE D11B.QTD_FILHOS END) DCR_QUANT
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND DCR.DCR_FILIAL = %xFilial:DCR%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_SEQUEN = DCR.DCR_SEQUEN
			AND D12.D12_ATUEST = '1'
			AND (D12.D12_STATUS = '1'
				OR (D12.D12_STATUS = '3'
				AND D12.D12_IDMOV = %Exp:Self:GetIdMovto()%
				AND D12.D12_IDOPER = %Exp:Self:GetIdOpera()% ))
			AND D12.%NotDel%
			LEFT JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D12.D12_FILIAL = %xFilial:D12%
			AND D11.D11_PRODUT = D12.D12_PRDORI
			AND D11.D11_PRDORI = D12.D12_PRDORI
			AND D11.D11_PRODUT = D12.D12_PRODUT
			AND D11.%NotDel%
			LEFT JOIN ( SELECT D11A.D11_PRODUT,
								COUNT(*) QTD_FILHOS
						FROM %Table:D11% D11A
						WHERE D11A.D11_FILIAL = %xFilial:D11%
						AND D11A.D11_PRODUT = D11A.D11_PRDORI
						AND D11A.%NotDel%
						GROUP BY D11A.D11_PRODUT) D11B
			ON D11B.D11_PRODUT = D12.D12_PRDORI
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = %Exp:(cAliasDCF)->DCF_ID%
			AND DCR.DCR_SEQUEN = %Exp:(cAliasDCF)->DCF_SEQUEN%
			AND DCR.%NotDel%
		EndSql
		If (cAliasAux)->(!Eof())
			nQtdTot := (cAliasAux)->DCR_QUANT
		EndIf
		(cAliasAux)->(dbCloseArea())
		// Quando a quantidade movimentada completa a quantidade da ordem de servi�o, j� pode ser liberado o pedido de venda.
		// Caso o endere�amento fa�a parte de uma distribui��o, busca o pedido de venda relacionado com o pedido de compra
		If QtdComp((cAliasDCF)->DCF_QUANT) == QtdComp(nQtdTot)
			// Seleciona os pedidos da distribui��o caso exista.
			cAliasSC9 := GetNextAlias()
			BeginSql Alias cAliasSC9
				SELECT SC9.R_E_C_N_O_ RECNOSC9,
						SC9.C9_SERVIC,
						SUM(D08.D08_QTDDIS) QUANT,
						CASE WHEN SUM(D08.D08_QTDDIS) = %Exp:nQtdTot% THEN 1 ELSE 2 END ORDEM
				FROM %Table:SD1% SD1
				INNER JOIN %Table:D06% D06
				ON D06.D06_FILIAL = %xFilial:D06%
				AND SD1.D1_FILIAL = %xFilial:SD1%
				AND D06.D06_CODDIS = SD1.D1_CODDIS
				AND D06.D06_SITDIS = '2'
				AND D06.%NotDel%
				INNER JOIN %Table:D08% D08
				ON D08.D08_FILIAL = %xFilial:D08%
				AND SD1.D1_FILIAL = %xFilial:SD1%
				AND D08.D08_PRODUT = SD1.D1_COD
				AND D08.D08_CODDIS = D06.D06_CODDIS
				AND D08.%NotDel%
				INNER JOIN %Table:SC9% SC9
				ON SC9.C9_FILIAL = %xFilial:SC9%
				AND D08.D08_FILIAL = %xFilial:D08%
				AND SC9.C9_PEDIDO = D08.D08_PEDIDO
				AND SC9.C9_ITEM = D08.D08_ITEM
				AND SC9.C9_SEQUEN = D08.D08_SEQUEN
				AND SC9.C9_PRODUTO = D08.D08_PRODUT
				AND SC9.C9_BLEST = '02'
				AND SC9.C9_BLCRED = '   '
				AND SC9.%NotDel%
				INNER JOIN %Table:SC6% SC6
				ON SC6.C6_FILIAL =  %xFilial:SC6%
				AND SC9.C9_FILIAL = %xFilial:SC9%
				AND SC6.C6_NUM = SC9.C9_PEDIDO
				AND SC6.C6_ITEM = SC9.C9_ITEM
				AND SC6.C6_PRODUTO = SC9.C9_PRODUTO
				AND ((SC6.C6_PEDCOM = SD1.D1_PEDIDO
					AND SC6.C6_ITPC = SD1.D1_ITEMPC)
					OR (SC6.C6_PEDCOM = '  '))
				AND SC6.%NotDel%
				WHERE SD1.D1_FILIAL = %xFilial:SD1%
				AND SD1.%NotDel%
				AND SD1.D1_IDDCF = %Exp:(cAliasDCF)->DCF_ID%
				GROUP BY SC9.R_E_C_N_O_,
							SC9.C9_SERVIC,
							SC6.C6_PEDCOM
				// Ordena primeiramente os pedidos com pedido de compra vinculado e depois os pedidos com a mesma quantidade
				// e ent�o o pedido com a maior quantidade, para evitar ao m�ximo a quebra do pedido de venda
				ORDER BY SC6.C6_PEDCOM DESC,
							ORDEM,
							QUANT DESC
			EndSql
			If (cAliasSC9)->(Eof())
				(cAliasSC9)->(dbCloseArea())
				// Seleciona os pedidos que para o produto quando n�o possui distribui��o.
				cAliasSC9 := GetNextAlias()
				BeginSql Alias cAliasSC9
					SELECT SC9.R_E_C_N_O_ RECNOSC9,
							SC9.C9_SERVIC,
							SC9.C9_QTDLIB QUANT
					FROM %Table:SC9% SC9
					INNER JOIN %Table:SC6% SC6
					ON SC6.C6_FILIAL = %xFilial:SC6%
					AND SC6.C6_NUM = SC9.C9_PEDIDO
					AND SC6.C6_ITEM = SC9.C9_ITEM
					AND SC6.C6_PRODUTO = SC9.C9_PRODUTO
					AND SC6.%NotDel%
					AND ((EXISTS (  SELECT 1
									FROM %Table:SD1% SD1
									WHERE SD1.D1_FILIAL = %xFilial:SD1%
									AND SC6.C6_FILIAL = %xFilial:SC6%
									AND SD1.D1_IDDCF = %Exp:(cAliasDCF)->DCF_ID%
									AND SD1.D1_PEDIDO = SC6.C6_PEDCOM
									AND SD1.D1_ITEMPC = SC6.C6_ITPC
									AND SD1.%NotDel% ))
						OR (SC6.C6_PEDCOM = '   '))
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_PRODUTO = %Exp:Self:oMovPrdLot:GetPrdOri()%
					AND SC9.C9_BLEST = '02'
					AND SC9.C9_BLCRED = '   '
					AND SC9.%NotDel%
					ORDER BY SC6.C6_PEDCOM DESC,
								SC6.C6_ENTREG,
								SC9.C9_QTDLIB DESC
				EndSql
			EndIf
			dbSelectArea("SC9")
			SC9->(dbSetOrder(1))
			Do While lRet .And. (cAliasSC9)->(!Eof())
				// Avalia se pedido de crossdoking pode ser liberado
				If lUPDLIB01
					lRetPE := ExecBlock('UPDLIB01',.F.,.F.,{(cAliasSC9)->RECNOSC9})
					If ValType(lRetPE) == 'L' .And. !lRetPE
						(cAliasSC9)->(dbSkip())
						Loop
					EndIf
				EndIf
				oServico:SetServico((cAliasSC9)->C9_SERVIC)
				// Confirma��o de servi�o Cross-Docking
				If oServico:LoadData() .And. oServico:HasOperac({'4'})
					// Posiciona no SC9 a ser liberado
					SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
					// Verifica se o pedido est� em uma distribui��o (D08)
					cAliasD08 := GetNextAlias()
					BeginSql Alias cAliasD08
						SELECT R_E_C_N_O_ RECNOD08
						FROM %Table:D08% D08
						WHERE D08.D08_FILIAL = %xFilial:D08%
						AND D08.D08_PEDIDO = %Exp:SC9->C9_PEDIDO%
						AND D08.D08_ITEM = %Exp:SC9->C9_ITEM%
						AND D08.D08_SEQUEN = %Exp:SC9->C9_SEQUEN%
						AND D08.D08_PRODUT = %Exp:SC9->C9_PRODUTO%
						AND D08.%NotDel%
						AND EXISTS (SELECT 1
									FROM %Table:D06% D06
									WHERE D06.D06_FILIAL = %xFilial:D06%
									AND D06.D06_CODDIS = D08.D08_CODDIS
									AND D06.D06_SITDIS = '2'
									AND D06.%NotDel% )
					EndSql
					If (cAliasD08)->(!Eof())
						nRecD08 := (cAliasD08)->RECNOD08
					EndIf
					(cAliasD08)->(dbCloseArea())
					// Quantidade informada pela distribui��o ou quantidade do pedido de venda
					nQuant := (cAliasSC9)->QUANT
					If QtdComp(nQuant) > QtdComp(nQtdTot)
						// Assume a quantidade restante ao inv�s da quantidade inteira do pedido
						nQuant := nQtdTot
					EndIf
					nQtdTot -= nQuant
					nNewRecno := (cAliasSC9)->RECNOSC9
					// Efetua a divis�o do SC9 quando a distribui��o n�o atendeu completamente o pedido
					// ou quando a quantidade exceda o saldo do produto - impedindo que seja liberado
					// um pedido com quantidade maior que o saldo em estoque.
					If QtdComp(SC9->C9_QTDLIB) > QtdComp(nQuant)
						lRet := WmsDivSC9(SC9->C9_CARGA,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_SERVIC,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_NUMSERI,nQuant,,,,,.F./*lWmsLibSC9*/,.F./*lGeraEmp*/,,SC9->(Recno()),,,,@nNewRecno)
					EndIf
					If lRet
						// Garante que mantenha o posicionamento do SC9.
						SC9->(dbGoTo(nNewRecno))
						// Caso exista uma distribui��o para o item do pedido, atualiza o sequen do D08
						If nRecD08 > 0
							D08->(dbGoTo(nRecD08))
							If !(D08->D08_SEQUEN == SC9->C9_SEQUEN)
								RecLock("D08",.F.)
								D08->D08_SEQUEN := SC9->C9_SEQUEN
								D08->(MsUnlock())
							EndIf
						EndIf
						// Retira o bloqueio de estoque
						RecLock("SC9",.F.)
						SC9->C9_BLEST := ""
						// Posiciona do SC6 para utiliza��o do dados pela MaAvalSC9.
						If !(xFilial("SC6")==SC6->C6_FILIAL .And.;
							SC6->C6_NUM==SC9->C9_PEDIDO .And.;
							SC6->C6_ITEM==SC9->C9_ITEM .And.;
							SC6->C6_PRODUTO==SC9->C9_PRODUTO)
							dbSelectArea("SC6")
							SC6->(dbSetOrder(1))
							MsSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO))
						EndIf
						RecLock("SC6",.F.)
						// Regra de desbloqueio de estoque
						MaAvalSC9("SC9",5,{{ "","","","",nQuant,,Ctod(""),"","","",SC9->C9_LOCAL}})
						SC6->(MsUnlock())
						SC9->(MsUnlock())
						// Sai do loop, pois n�o existe mais saldo para liberar os pedidos restantes.
						If nQtdTot <= 0
							Exit
						EndIf
					EndIf
				EndIf
				(cAliasSC9)->(dbSkip())
			EndDo
			(cAliasSC9)->(dbCloseArea())
		EndIf
		(cAliasDCF)->(dbSkip())
	EndDo
	(cAliasDCF)->(dbCloseArea())
	//Integra��o com o WMS
	//Verifica as Ordens de servico geradas para execu��o automatica
	If lRet
		WmsExeServ()
	EndIf
	oServico:Destroy()
	RestArea(aAreaD12)
	RestArea(aAreaSC9)
Return lRet

METHOD UpdUltMov() CLASS WMSBCCMovimentoServico
Local lRet         := .T.
Local lUltMov      := .F.
Local lMovUnit     := Self:IsMovUnit()
Local aTamSX3      := {}
Local aAreaAnt     := GetArea()
Local oMntUniItem  := Nil
Local cAliasQry    := ""

	If !lMovUnit
		// Verifica se todos os movimentos da DCF foram concluidos
		// Desconsidera o movimento atual,pois o movimento � a ultima atividade mas n�o alterou o status
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DISTINCT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCR% DCR1
			INNER JOIN %Table:DCR% DCR2
			ON DCR2.DCR_FILIAL = %xFilial:DCR%
			AND DCR2.DCR_IDORI = DCR1.DCR_IDORI
			AND DCR2.%NotDel%
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D12.D12_ORDMOV IN ( '3', '4' )
			AND D12.D12_IDDCF = DCR2.DCR_IDORI
			AND D12.D12_IDMOV = DCR2.DCR_IDMOV
			AND D12.D12_IDOPER = DCR2.DCR_IDOPER
			AND D12.%NotDel%
			INNER JOIN %Table:DCF% DCF
			ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_ID = DCR2.DCR_IDDCF
			AND DCF.DCF_SEQUEN = DCR2.DCR_SEQUEN
			AND DCF.%NotDel%
			WHERE DCR1.DCR_FILIAL = %xFilial:DCR%
			AND DCR1.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR1.DCR_IDMOV = %Exp:Self:GetIdMovto()%
			AND DCR1.DCR_IDOPER = %Exp:Self:GetIdOpera()%
			AND DCR1.%NotDel%
			AND NOT EXISTS (SELECT 1
							FROM %Table:D12% D12E
							WHERE D12E.D12_FILIAL = %xFilial:D12%
							AND D12.D12_FILIAL = %xFilial:D12%
							AND D12E.D12_STATUS IN ( '4', '3', '2', '-' )
							AND D12E.R_E_C_N_O_ <> %Exp:Self:GetRecno()% // Desconsidera o movimento atual
							AND D12E.D12_SERVIC = D12.D12_SERVIC
							AND D12E.D12_TAREFA = D12.D12_TAREFA
							AND D12E.D12_IDDCF = DCR2.DCR_IDORI
							AND D12E.%NotDel% )
		EndSql
		If (cAliasQry)->(!Eof())
			lUltMov := .T.
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		// Quando for o movimento de um unitizador, sempre considera como ultimo movimento que atualiza o estoque
		lUltMov := .T.
	EndIf

	If lUltMov
		If !lMovUnit
			// Realiza a verifica��o quando for um produto partes para realizar a
			// analise de saldo dos filhos e montar o produto pai automaticamente
			If Self:oMovServic:ChkRecebi()
				Self:oOrdServ:oProdLote:oProduto:oProdComp:SetPrdCmp(Self:oOrdServ:oProdLote:GetProduto())
				// Quando a movimenta��o � de um produto pai e ele monta o produto
				If Self:oOrdServ:oProdLote:oProduto:oProdComp:LoadData(2) .And. Self:oOrdServ:oProdLote:oProduto:oProdComp:IsMntPrd()
					Self:oEstEnder:ClearData()
					lRet := Self:oEstEnder:MontPrdPai(.F.,; // lInventario
						{{; // aPais
							Self:oMovEndDes:GetArmazem(),; // Armaz�m
							Self:oOrdServ:oProdLote:oProduto:oProdComp:GetProduto(),; // Produto Pai
							Self:oMovPrdLot:GetLoteCtl(),; // Lote
							Self:oMovPrdLot:GetNumLote(),; // Sub-Lote
							Self:oMovPrdLot:GetNumSer();   // Numero de S�rie
						}},;
						{; // aParam - Informa��es do SD3
							Self:oMovEndDes:GetArmazem(),; // [01] cLocal
							dDataBase,;                    // [02] dData
							Self:oMovPrdLot:GetNumLote(),; // [03] cNumLote
							Self:oMovPrdLot:GetLoteCtl(),; // [04] cLoteCtl
							Self:oMovPrdLot:GetDtValid(),; // [05] dDtValid
							0,;                            // [06] nQtSegUm
							Self:oMovPrdLot:GetNumSer(),;  // [07] cNumSerie
							Self:oMovEndDes:GetEstFis(),;  // [08] cEstFis
							"",;                           // [09] cContagem
							Self:oOrdServ:GetDocto(),;     // [10] cNumDoc
							Self:oOrdServ:GetSerie(),;     // [11] cSerie
							Self:oOrdServ:GetCliFor(),;    // [12] cFornece
							Self:oOrdServ:GetLoja(),;      // [13] cLoja
							dDataBase,;                    // [14] mv_par01 -> D3_EMISSAO
							Self:oOrdServ:oProdLote:oProduto:oProdGen:GetCC(),; // [15] mv_par02 -> D3_CC
							2;                             // [16] mv_par14 -> 1=Pega os custos medios finais;2=Pega os custos medios atuais
						},;
						{dDataBase},;                     // [17] Data da montagem
						@Self:aPrdMont)                   // [18] Array de produtos montados
				EndIf
			EndIf

			If lRet 
				If Self:oOrdServ:GetOrigem() == "DH1"
					// Baixa reserva para movimentos de DH1 que n�o s�o de endere�amento
					If !Self:oMovServic:ChkRecebi()
						
						// Baixa da reserva do SB2						
						lRet := Self:oOrdServ:UpdEmpSB2("-",Self:oMovPrdLot:GetPrdOri(),Self:oMovEndOri:GetArmazem(),Self:oOrdServ:GetQuant())
						If !lRet
							Self:cErro := Self:oOrdServ:GetErro()
						EndIf
						
						// Baixa da reserva do SB8
						If lRet .And. Self:oMovPrdLot:HasRastro() .And. !Empty(Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote())
							lRet := Self:oOrdServ:UpdEmpSB8("-",Self:oMovPrdLot:GetPrdOri(),Self:oMovEndOri:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(), Self:oMovPrdLot:GetNumLote(), Self:oOrdServ:GetQuant())
							If !lRet
								Self:cErro := Self:oOrdServ:GetErro()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			// Efetua movimenta��o de estoque SD3 para os movimentos de transferencia
			If lRet .And. Self:oMovServic:ChkTransf()
				lRet := Self:MakeTrfSD3()
			EndIf
		Else
			If Self:oMovServic:ChkRecebi()
				// Atualiza��o do Status do unitizador na finaliza��o do ultimo movimento
				oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
				oMntUniItem:SetIdUnit(Self:cIdUnitiz)
				// Atualiza os produtos do unitizador (D0S) para endere�ado '1=Sim'
				oMntUniItem:SetEndrec("1") // 1=Sim
				oMntUniItem:UpdEndrec(.F./*lProduto*/)
				// Atualiza o unitizador (D0R) para '4=Endere�ado'
				oMntUniItem:oUnitiz:SetStatus("4") // 4=Endere�ado
				oMntUniItem:oUnitiz:UpdStatus()
			EndIf

			If Self:oMovServic:ChkTransf()
				// Cursor na D14 para saber os itens do unitizador quando transfer�ncia de um unitizador completo
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT D14.D14_LOCAL,
							D14.D14_PRODUT,
							D14.D14_PRDORI,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_QTDEST
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
					AND D14.%NotDel%
				EndSql
				aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
				Do While lRet .And. (cAliasQry)->(!Eof())
					Self:oMovPrdLot:SetArmazem((cAliasQry)->D14_LOCAL)
					Self:oMovPrdLot:SetProduto((cAliasQry)->D14_PRODUT)
					Self:oMovPrdLot:SetPrdOri((cAliasQry)->D14_PRDORI)
					Self:oMovPrdLot:SetLoteCtl((cAliasQry)->D14_LOTECT)
					Self:oMovPrdLot:SetNumLote((cAliasQry)->D14_NUMLOT)
					Self:oMovPrdLot:LoadData()
					// Seta a quantidade da movimenta��o do produto
					Self:SetQtdMov((cAliasQry)->D14_QTDEST)
					// Efetua movimenta��o de estoque SD3 para os movimentos de transferencia
					lRet := Self:MakeTrfSD3()

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
			EndIf
			// Retorna informa��es do objeto (principalmente para funcionar a fun��o IsMovUnit()
			Self:oMovPrdLot:ClearData() // Limpa os atributos
			// Seta a quantidade da movimenta��o do produto
			Self:SetQtdMov(1)
		EndIf
		If Self:oMovServic:ChkRecebi()
			If ExistBlock("ULTMOVENDCA")
				ExecBlock("ULTMOVENDCA",.F.,.F.,{Self:oOrdServ:GetIdDCF()})
			EndIf
		EndIf
		If ExistBlock("WMSBMSUM")
			ExecBlock("WMSBMSUM",.F.,.F.,{Self:GetRecno()})
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD UpdSepMov() CLASS WMSBCCMovimentoServico
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local oMntVolItem := Nil
Local oDisSepItem := Nil
Local oConExpItem := Nil
Local cAliasQry   := ""

	If Self:ChkConfExp() .Or. Self:ChkDisSep() .Or. Self:ChkMntVol("2") .Or. (Self:ChkMntVol("1") .And. Self:cRadiof == "2")  .Or. (Self:ChkMntVol("1") .And. !oMovimento:ValMntExc())
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCF.DCF_CARGA,
					DCF.DCF_DOCTO,
					DCR.DCR_QUANT
			FROM %Table:DCR% DCR
			INNER JOIN %Table:DCF% DCF
			ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCF.DCF_ID = DCR.DCR_IDDCF
			AND DCF.%NotDel%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
			AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
			AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.%NotDel%
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			// Montagem de volume
			If Self:ChkMntVol("2") .Or. (Self:ChkMntVol("1") .And. Self:cRadiof == "2") .Or. (Self:ChkMntVol("1") .And. !oMovimento:ValMntExc())
				oMntVolItem := WMSDTCMontagemVolumeItens():New()
				oMntVolItem:SetCarga((cAliasQry)->DCF_CARGA)
				oMntVolItem:SetPedido((cAliasQry)->DCF_DOCTO)
				oMntVolItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
				oMntVolItem:SetProduto(Self:oMovPrdLot:GetProduto())
				oMntVolItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
				oMntVolItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
				// Busca o codigo da montagem de volume
				oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
				If oMntVolItem:LoadData()
					// DCT
					oMntVolItem:SetQtdSep(oMntVolItem:GetQtdSep() + (cAliasQry)->DCR_QUANT)
					If !oMntVolItem:UpdateDCT()
						lRet := .F.
						Self:cErro := MntVolItem:oMntVol:GetErro()
					EndIf
				EndIf
				oMntVolItem:Destroy()
			EndIf
			// Distribuicao de separacao
			If Self:ChkDisSep()
				oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
				oDisSepItem:SetCarga((cAliasQry)->DCF_CARGA)
				oDisSepItem:SetPedido((cAliasQry)->DCF_DOCTO)
				oDisSepItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
				oDisSepItem:SetProduto(Self:oMovPrdLot:GetProduto())
				oDisSepItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
				oDisSepItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
				oDisSepItem:oDisEndOri:SetArmazem(Self:oMovEndDes:GetArmazem())
				oDisSepItem:oDisSep:oDisEndDes:SetArmazem(Self:oMovEndDes:GetArmazem())
				// Busca codigo da distribui��o da separa��o
				oDisSepItem:SetCodDis(oDisSepItem:oDisSep:FindCodDis())
				If oDisSepItem:LoadData()
					oDisSepItem:SetQtdSep(oDisSepItem:GetQtdSep()+(cAliasQry)->DCR_QUANT)
					If !oDisSepItem:UpdateD0E()
						lRet := .F.
						Self:cErro := oDisSepItem:GetErro()
					EndIf
				EndIf
				oDisSepItem:Destroy()
			EndIf
			// Conferencia de expedicao
			If Self:ChkConfExp()
				oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
				oConExpItem:SetCarga((cAliasQry)->DCF_CARGA)
				oConExpItem:SetPedido((cAliasQry)->DCF_DOCTO)
				oConExpItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
				oConExpItem:SetProduto(Self:oMovPrdLot:GetProduto())
				oConExpItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
				oConExpItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
				oConExpItem:SetLibPed(Self:oMovServic:GetLibPed())
				// Busca codigo da conferencia de expedi��o
				oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
				If oConExpItem:LoadData()
					oConExpItem:SetQtdSep(oConExpItem:GetQtdSep()+(cAliasQry)->DCR_QUANT)
					If !oConExpItem:UpdateD02()
						lRet := .F.
						Self:cErro := oConExpItem:GetErro()
					EndIf
				EndIf
				oConExpItem:Destroy()
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdLibSer
Atualiza��o libera��o servi�o
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdLibSer() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local oMovAux   := Nil
Local cAliasD12 := GetNextAlias()
	// Busca tarefas de separa��o com problema para fazer rein�cio autom�tico
	BeginSql Alias cAliasD12
		SELECT D12.R_E_C_N_O_ AS RECNOD12
		FROM %Table:D12% D12
		WHERE D12_FILIAL = %xFilial:D12%
		AND D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		AND D12_LOCORI = %Exp:Self:oMovEndDes:GetArmazem()%
		AND D12_ENDORI = %Exp:Self:oMovEndDes:GetEnder()%
		AND D12_STATUS = '2'
		AND D12.%NotDel%
	EndSql
	If (cAliasD12)->(!Eof())
		oMovAux := WMSDTCMovimentosServicoArmazem():New()
		Do While (cAliasD12)->(!Eof())
			oMovAux:GoToD12((cAliasD12)->RECNOD12)
			If oMovAux:oMovServic:ChkSepara()
				oMovAux:SetStatus("4")
				oMovAux:UpdateD12()
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} UpdEmpSDC
Atualiza��o libera��o empenho
@author SQUAD WMS Logistica
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdEmpSDC() CLASS WMSBCCMovimentoServico
Local lRet        := .T.
Local lBaixaEst   := Self:GetBxEsto() == "1"
Local aTamSx3     := TamSx3("DCR_QUANT")
Local aAreaAnt    := GetArea()
Local aRotAuto    := {}
Local aCustoMov   := {0,0,0,0,0} // Utilizado para fazer rateio do custo
Local cAliasTRP   := Nil
Local cAliasDCF   := Nil
Local cAliasSDC   := Nil
Local cAliasQry   := Nil
Local cTm         := SuperGetMv("MV_WMSTMBR",.F.," ")
Local nQuant      := 0
Local nQtdEmp     := 0
Local nQtdSld     := 0

Private lMsErroAuto := .F.
Private lExecWms    := Nil
Private lDocWms     := Nil
Private lEstWmsCq   := Nil

	// Se servi�o baixa requisi��o
	// valida se parametro cadastrado
	// se � de requisi��o
	// se o tipo de movimento baixa empenho
	Self:cErro := ""
	If lBaixaEst
		If !Empty(cTm)
			dbSelectArea("SF5")
			dbSetOrder(1)
			If SF5->(dbSeek(xFilial("SF5")+cTm))
				If (SF5->F5_TIPO == "R")
					If !(SF5->F5_ATUEMP == "S")
						lRet := .F.
						Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",cTm}}) // Tipo movimento [VAR01] de requisi��o n�o atualiza empenho 
					EndIf
				Else
					lRet := .F.
					Self:cErro := WmsFmtMsg(STR0007,{{"[VAR01]",cTm}}) // Tipo de movimento [VAR01] n�o � de requisi��o
				EndIf
			Else
				lRet := .F.
				Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",cTm}}) // Tipo de movimento [VAR01] n�o cadastrado!
			EndIf
		Else
			lRet := .F.
			Self:cErro := STR0009 // Par�metro de tipo de movimento para baixa de requisi��o n�o configurado (MV_WMSTMBR)
			
		EndIf
	EndIf
	// Para produtos que n�o s�o componentes permite a reserva a cada movimento e a requisi��o
	// Quando produto componente somente permite a reserva, n�o efetua requisi��o
	If lRet .And. Self:oMovPrdLot:GetProduto() == Self:oMovPrdLot:GetPrdOri()
		// Verifica se todos os movimentos da DCF foram concluidos
		// Desconsidera o movimento atual,pois o movimento � a ultima atividade mas n�o alterou o status
		cAliasDCF := GetNextAlias()
		BeginSql Alias cAliasDCF
			SELECT DCF.DCF_CARGA,
					DCF.DCF_DOCTO,
					DCF.DCF_SERIE,
					DCF.DCF_CLIFOR,
					DCF.DCF_LOJA,
					DCF.DCF_NUMSEQ,
					DCR.DCR_QUANT,
					DCR.DCR_IDDCF
			FROM %Table:DCR% DCR
			INNER JOIN %Table:DCF% DCF
			ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
			AND DCF.DCF_ID = DCR.DCR_IDDCF
			AND DCF.%NotDel%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
			AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
			AND DCR.%NotDel%
		EndSql
		TcSetField(cAliasDCF,'DCR_QUANT','N',aTamSx3[1],aTamSx3[2])
		Do While lRet .And. (cAliasDCF)->(!Eof())
			// Quando separa��o origem SC9 gera empenho
			If lRet .And. Self:oOrdServ:GetOrigem() == "SC9"
				lRet := WmsAtuSC9((cAliasDCF)->DCF_CARGA,;
									(cAliasDCF)->DCF_DOCTO,;
									(cAliasDCF)->DCF_SERIE,;
									Self:oMovPrdLot:GetProduto(),;
									Self:oMovServic:GetServico(),;
									Self:oMovPrdLot:GetLoteCtl(),;
									Self:oMovPrdLot:GetNumLote(),;
									Self:oMovPrdLot:GetNumSer(),;
									(cAliasDCF)->DCR_QUANT,;
									/*nQuant2UM*/,;
									Self:oMovEndDes:GetArmazem(),;
									Self:oMovEndDes:GetEnder(),;
									(cAliasDCF)->DCR_IDDCF,;
									IIf(Empty(Self:oOrdServ:GetRegra()),;
									Nil,;
									Val(Self:oOrdServ:GetRegra())),;
									CtoD(''),;
									Self:GetLibPed() == "1")
			EndIf
			If lRet .And. Self:oOrdServ:GetOrigem() == "SD4"
				// Verifica se � uma transfer�ncia entre armaz�ns
				If !(Self:oMovEndOri:GetArmazem() == Self:oMovEndDes:GetArmazem())
					// Baixa da reserva do SB2
					Self:oOrdServ:UpdEmpSB2("-",Self:oMovPrdLot:GetPrdOri(),Self:oMovEndOri:GetArmazem(),Self:nQtdOrig)
					// Baixa da reserva do SB8
					If Self:oMovPrdLot:HasRastro() .And. !Empty(Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote())
						Self:oOrdServ:UpdEmpSB8("-",Self:oMovPrdLot:GetPrdOri(),Self:oMovEndOri:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(), Self:oMovPrdLot:GetNumLote(), Self:nQtdOrig)
					EndIf
					// Efetua uma transfer�ncia entre armaz�ns do saldo de estoque
					lRet := Self:MakeTrfSD3()
					// Gera empenho na SB8 no armaz�m destino
					If lRet .And. Self:oMovPrdLot:HasRastro() .And. !Empty(Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote())
						If QtdComp(Self:nQtdMovto) >= QtdComp(Self:nQtdOrig)
							//Se a quantidade movimentada for maior que a solicitada para a SD4, empenha apenas a quantidade original da requisi��o
							Self:oOrdServ:UpdEmpSB8("+",Self:oMovPrdLot:GetPrdOri(),Self:oMovEndDes:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(), Self:oMovPrdLot:GetNumLote(), Self:nQtdOrig)
						Else
							//Se a quantidade movimentada for maior que a solicitada para a SD4, empenha apenas a quantidade movimentada
							Self:oOrdServ:UpdEmpSB8("+",Self:oMovPrdLot:GetPrdOri(),Self:oMovEndDes:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(), Self:oMovPrdLot:GetNumLote(), Self:nQtdMovto)
						EndIf
					EndIf
				EndIf
				If lRet
					nQtdSld   := (cAliasDCF)->DCR_QUANT
					// busca requisi��es
					cAliasQry  := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT TRP.D4_LOCAL,
								TRP.D4_OP,
								TRP.D4_TRT,
								TRP.D4_COD,
								TRP.D4_LOTECTL,
								TRP.D4_NUMLOTE,
								TRP.D4_SLDREQ
						FROM (  SELECT SD4.D4_LOCAL,
										SD4.D4_OP,
										SD4.D4_TRT,
										SD4.D4_COD,
										SD4.D4_LOTECTL,
										SD4.D4_NUMLOTE,
										(SD4.D4_QUANT - CASE WHEN SUM(SDC.DC_QUANT) IS NULL THEN 0 ELSE SUM(SDC.DC_QUANT) END) D4_SLDREQ
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
								AND SD4.D4_IDDCF = %Exp:(cAliasDCF)->DCR_IDDCF%
								AND SD4.D4_COD = %Exp:Self:oMovPrdLot:GetPrdOri()%
								AND SD4.D4_LOTECTL = %Exp:Self:oMovPrdLot:GetLoteCtl()%
								AND SD4.D4_NUMLOTE = %Exp:Self:oMovPrdLot:GetNumLote()%
								AND SD4.D4_QTDEORI > 0
								AND SD4.%NotDel%
								GROUP BY SD4.D4_LOCAL,
											SD4.D4_OP,
											SD4.D4_TRT,
											SD4.D4_COD,
											SD4.D4_LOTECTL,
											SD4.D4_NUMLOTE,
											SD4.D4_QUANT) TRP
						WHERE TRP.D4_SLDREQ > 0
					EndSql
					TcSetField(cAliasQry,'D4_SLDREQ','N',aTamSX3[1],aTamSX3[2])
					Do While lRet .And. (cAliasQry)->(!Eof()) .And. nQtdSld > 0
						If QtdComp((cAliasQry)->D4_SLDREQ) >= QtdComp(nQtdSld)
							nQtdEmp := nQtdSld
						Else
							nQtdEmp := (cAliasQry)->D4_SLDREQ
						EndIf
						// Produto
						Self:oEstEnder:ClearData()
						Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
						Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
						Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
						Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
						Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
						Self:oEstEnder:oProdLote:SetNumSer("")
						// Endere�o Destino
						Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
						Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
						// Dados Gerais
						Self:oEstEnder:SetQuant(nQtdEmp)
						// Gera empenho SDC para ordem de produ��o
						lRet := Self:oEstEnder:GeraEmpReq("SC2",;
														(cAliasQry)->D4_OP,;
														(cAliasQry)->D4_TRT,;
														(cAliasDCF)->DCR_IDDCF,;
														Nil,;
														.T.,;
														!lBaixaEst)
						If lRet
							If lBaixaEst
								// Efetua a baixa da requisi��o
								// baixa estoque por produto e/ou lote
								aRotAuto := {}
								aAdd(aRotAuto,{"D3_TM"     , cTm                               ,Nil})
								aAdd(aRotAuto,{"D3_DOC"    , Self:oOrdServ:GetDocto()          ,Nil})
								aAdd(aRotAuto,{"D3_EMISSAO", dDataBase                         ,Nil})
								aAdd(aRotAuto,{"D3_NUMSEQ" , ProxNum()                         ,Nil})
								aAdd(aRotAuto,{"D3_COD"    , Self:oMovPrdLot:GetProduto()      ,Nil})
								If Rastro(Self:oMovPrdLot:GetProduto())
									aAdd(aRotAuto,{"D3_LOTECTL", Self:oMovPrdLot:GetLoteCtl()  ,Nil})
									aAdd(aRotAuto,{"D3_NUMLOTE", Self:oMovPrdLot:GetNumLote()  ,Nil})
								EndIf
								aAdd(aRotAuto,{"D3_LOCAL"  , Self:oMovEndDes:GetArmazem()      ,Nil})
								aAdd(aRotAuto,{"D3_LOCALIZ", Self:oMovEndDes:GetEnder()        ,Nil})
								aAdd(aRotAuto,{"D3_QUANT"  , nQtdEmp                           ,Nil})
								aAdd(aRotAuto,{"D3_TRT"    , (cAliasQry)->D4_TRT               ,Nil})
								aAdd(aRotAuto,{"D3_PROJPMS", CriaVar('D3_PROJPMS')             ,Nil})
								aAdd(aRotAuto,{"D3_TASKPMS", CriaVar('D3_TASKPMS')             ,Nil})
								aAdd(aRotAuto,{"D3_CLVL"   , CriaVar('D3_CLVL')                ,Nil})
								aAdd(aRotAuto,{"D3_SERVIC" , Self:oOrdServ:GetServico()        ,Nil})
								aAdd(aRotAuto,{"D3_STSERV" , Self:oOrdServ:GetStServ()         ,Nil})
								aAdd(aRotAuto,{"D3_CC"     , CriaVar('D3_CC')                  ,Nil})
								aAdd(aRotAuto,{"D3_CONTA"  , CriaVar('D3_CONTA')               ,Nil})
								aAdd(aRotAuto,{"D3_ITEMCTA", CriaVar('D3_ITEMCTA')             ,Nil})
								aAdd(aRotAuto,{"D3_OP"     , (cAliasQry)->D4_OP                ,Nil})
								aAdd(aRotAuto,{"D3_NUMSA"  , CriaVar('D3_NUMSA')               ,Nil})
								aAdd(aRotAuto,{"D3_ITEMSA" , CriaVar('D3_ITEMSA')              ,Nil})
								aAdd(aRotAuto,{"D3_IDDCF"  , (cAliasDCF)->DCR_IDDCF            ,Nil})
								aAdd(aRotAuto,{"D3_REGWMS" , Self:oOrdServ:GetRegra()          ,Nil})
								aAdd(aRotAuto,{"D3_CUSTO1" , aCustoMov[1]                      ,Nil})
								aAdd(aRotAuto,{"D3_CUSTO2" , aCustoMov[2]                      ,Nil})
								aAdd(aRotAuto,{"D3_CUSTO3" , aCustoMov[3]                      ,Nil})
								aAdd(aRotAuto,{"D3_CUSTO4" , aCustoMov[4]                      ,Nil})
								aAdd(aRotAuto,{"D3_CUSTO5" , aCustoMov[5]                      ,Nil})
								aAdd(aRotAuto,{"D3_POTENCI", CriaVar('D3_POTENCI')             ,Nil})
								// Indica que ser� DH1 e DCF
								lExecWms       := .T.
								lDocWms        := .T.
								// Realiza a baixa do SD3 com base no DH1
								MSExecAuto({|x,y| MATA240(x,y)},aRotAuto,3) //Inclus�o
								If lMsErroAuto
									// Erro na cria��o da SD3 pelo MsExecAuto
									If !IsTelNet()
										MostraErro()
									Else
										VTDispFile(NomeAutoLog(),.t.)
									EndIf
									lRet := .F.
								EndIf
								// AtualizaSaldo
								// Produto
								If lRet
									Self:oEstEnder:ClearData()
									Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
									Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
									Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
									Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
									Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
									Self:oEstEnder:oProdLote:SetNumSer("")
									// Endere�o Destino
									Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
									Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
									// Dados Gerais
									Self:oEstEnder:SetQuant(nQtdEmp)
									// Seta o bloco de c�digo para informa��es do documento para o Kardex
									Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
																oMovEstEnd:SetOrigem(Self:oOrdServ:GetOrigem()),;
																oMovEstEnd:SetDocto(Self:oOrdServ:GetDocto()),;
																oMovEstEnd:SetSerie(Self:oOrdServ:GetSerie()),;
																oMovEstEnd:SetCliFor(Self:oOrdServ:GetCliFor()),;
																oMovEstEnd:SetLoja(Self:oOrdServ:GetLoja()),;
																oMovEstEnd:SetNumSeq(Self:oOrdServ:GetNumSeq()),;
																oMovEstEnd:SetIdDCF(Self:oOrdServ:GetIdDCF())})
																// Seta o bloco de c�digo para informa��es do movimento para o Kardex
									Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
																oMovEstEnd:SetIdMovto(Self:GetIdMovto()),;
																oMovEstEnd:SetIdOpera(Self:GetIdOpera()),;
																oMovEstEnd:SetIdUnit(Self:GetUniDes())})
									// Realiza Sa�da Armazem Estoque por Endere�o
									If !Self:oEstEnder:UpdSaldo('999',.T./*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,/*lEmpPrev*/,.T./*lMovEstEnd*/)
										Self:cErro := Self:oEstEnder:GetErro()
										lRet := .F.
									EndIf
								EndIf
								If lRet 
									//DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
									SDC->(dbSetOrder(2))
									If SDC->(dbSeek(xFilial("SDC")+Self:oMovPrdLot:GetProduto()+Self:oMovEndDes:GetArmazem()+(cAliasQry)->D4_OP+(cAliasQry)->D4_TRT+Self:oMovPrdLot:GetLoteCtl()+Self:oMovPrdLot:GetNumLote()+Self:oMovEndDes:GetEnder()))
										RecLock("SDC",.F.)
										SDC->(dbDelete())
										SDC->(MSUnLock())
									EndIf
								EndIf
							EndIf
						EndIf
						If !lRet
							Exit
						EndIf
						// Ajusta calculo
						nQtdSld -= nQtdEmp
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())
				EndIf
				// Remove o empenho da quantidade � maior e elimina a SD4 provis�ria
				If lRet .And. QtdComp(nQtdSld) > 0
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SD4.R_E_C_N_O_ RECNOSD4
						FROM %Table:SD4% SD4
						WHERE SD4.D4_FILIAL = %xFilial:SD4%
						AND SD4.D4_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
						AND SD4.D4_IDDCF = %Exp:(cAliasDCF)->DCR_IDDCF%
						AND SD4.D4_QTDEORI = 0
						AND SD4.%NotDel%
					EndSql
					Do While (cAliasQry)->(!Eof())
						SD4->(dbGoTo((cAliasQry)->RECNOSD4))
						// Atualiza quantidade empenho de acordo com a quantidade requisitada
						GravaEmp(SD4->D4_COD,;            // Produto
								SD4->D4_LOCAL,;           // Armazem
								nQtdSld,;                 // Quantidade
								Nil,;                     // Quantidade 2 UM
								SD4->D4_LOTECTL,;         // Lote
								SD4->D4_NUMLOTE,;         // Sub-Lote
								Nil,;                     // Endere�o
								Nil,;                     // N�mero de s�rie
								SD4->D4_OP,;              // Ordem de produ��o
								SD4->D4_TRT,;             // Trt Op
								Nil,;                     // Pedido
								Nil,;                     // Seq. Pedido
								'SD4',;                   // Origem
								Nil,;                     // Op Origem
								Nil,;                     // Data Entrega
								Nil,;                     // aTravas
								.T.,;                     // Estorno
								Nil,;                     // Projeto
								.T.,;                     // Empenha SB2
								.T.,;                     // Grava SD4
								Nil,;                     // Consulta Vencidos
								.T.,;                     // Empenha SB8/SBF
								Nil,;                     // Cria SDC
								Nil,;                     // Encerra Op
								Nil,;                     // IdDCF
								Nil,;                     // aSalvCols
								Nil,;                     // nSG1
								Nil,;                     // OpEncer
								Nil,;                     // TpOp
								Nil,;                     // CAT83
								Nil,;                     // Data Emiss�o
								Nil,;                     // Grava Lote
								Nil)                      // aSDC
						// Elimina SD4
						RecLock('SD4',.F.)
						SD4->D4_QUANT -= nQtdSld
						If SD4->D4_QUANT == 0
							SD4->(dbDelete())
						EndIf
						SD4->(MsUnLock())
						(cAliasQry)->(dbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())
				EndIf
			EndIf
			(cAliasDCF)->(DbSkip())
		EndDo
		(cAliasDCF)->(DbCloseArea())
	Else
		cAliasDCF := GetNextAlias()
		BeginSql Alias cAliasDCF
			SELECT DISTINCT DCF.DCF_CARGA,
					DCF.DCF_DOCTO,
					DCF.DCF_SERIE,
					DCR.DCR_IDDCF,
					DCF.DCF_SEQUEN
			FROM %Table:DCR% DCR
			INNER JOIN %Table:DCF% DCF
			ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
			AND DCF.DCF_ID = DCR.DCR_IDDCF
			AND DCF.%NotDel%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
			AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
			AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
			AND DCR.%NotDel%
		EndSql
		Do While lRet .And. (cAliasDCF)->(!Eof())
			// Busca os documentos e retorna a quantidade que poder� ser liberada
			cAliasTRP := GetNextAlias()
			BeginSql Alias cAliasTRP
				SELECT MIN((CASE WHEN TRP.DCR_QUANT IS NULL THEN 0 ELSE TRP.DCR_QUANT END )/ D11.D11_QTMULT) DCR_QUANT
				FROM %Table:D11% D11
				LEFT JOIN (SELECT SUM(DCR.DCR_QUANT) DCR_QUANT,
									D12.D12_PRODUT,
									D12.D12_PRDORI
							FROM %Table:DCR% DCR, %Table:D12% D12
							WHERE DCR.DCR_FILIAL = %xFilial:DCR%
							AND DCR.DCR_IDDCF = %Exp:(cAliasDCF)->DCR_IDDCF%
							AND DCR.DCR_SEQUEN = %Exp:(cAliasDCF)->DCF_SEQUEN%
							AND DCR.%NotDel%
							AND D12.D12_FILIAL = %xFilial:D12%
							AND D12.D12_IDDCF = DCR.DCR_IDORI
							AND D12.D12_IDMOV = DCR.DCR_IDMOV
							AND D12.D12_IDOPER = DCR.DCR_IDOPER
							AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
							AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
							AND D12.D12_ATUEST = '1'
							AND (D12.D12_STATUS = '1'
								OR (D12.D12_STATUS = '3'
								AND  D12.D12_IDMOV = %Exp:Self:GetIdMovto()%
								AND  D12.D12_IDOPER = %Exp:Self:GetIdOpera()% ))
							AND D12.%NotDel%
							GROUP BY D12.D12_PRODUT,
									D12.D12_PRDORI) TRP
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = TRP.D12_PRDORI
				AND D11.D11_PRDCMP = TRP.D12_PRODUT
				AND D11.%NotDel%
				WHERE D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
				AND D11.%NotDel%
			EndSql
			TcSetField(cAliasTRP,'DCR_QUANT','N',aTamSx3[1],aTamSx3[2])
			Do While lRet .And. (cAliasTRP)->(!Eof()) .And. QtdComp(Int((cAliasTRP)->DCR_QUANT)) > 0
				// Atribui a quantidade multipla separada
				nQuant := Int((cAliasTRP)->DCR_QUANT)
				// Quando separa��o origem SC9 gera empenho
				If lRet .And. Self:oOrdServ:GetOrigem() == "SC9"
					// Busca quantidade j� empenhada
					cAliasSDC := GetNextAlias()
					BeginSql Alias cAliasSDC
						SELECT SUM(SDC.DC_QUANT) DC_QUANT
						FROM %Table:SDC% SDC
						WHERE SDC.DC_FILIAL = %xFilial:SDC%
						AND SDC.DC_PRODUTO = %Exp:Self:oMovPrdLot:GetPrdOri()%
						AND SDC.DC_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
						AND SDC.DC_ORIGEM = 'SC6'
						AND SDC.DC_PEDIDO = %Exp:(cAliasDCF)->DCF_DOCTO%
						AND SDC.DC_ITEM = %Exp:(cAliasDCF)->DCF_SERIE%
						AND SDC.DC_IDDCF = %Exp:(cAliasDCF)->DCR_IDDCF%
						AND SDC.DC_LOTECTL = %Exp:Self:oMovPrdLot:GetLoteCtl()%
						AND SDC.DC_NUMLOTE = %Exp:Self:oMovPrdLot:GetNumLote()%
						AND SDC.DC_LOCALIZ = %Exp:Self:oMovEndDes:GetEnder()%
						AND SDC.%NotDel%
					EndSql
					TcSetField(cAliasSDC,'DC_QUANT','N',aTamSx3[1],aTamSx3[2])
					If (cAliasSDC)->(!Eof()) .And. QtdComp((cAliasSDC)->DC_QUANT) > 0
						// Se encontrar quantidade empenhada desconta da quantidade total separada para gerar a diferen�a
						nQuant -=  (cAliasSDC)->DC_QUANT
					EndIf
					(cAliasSDC)->(dbCloseArea())
					RestArea(aAreaAnt)

					lRet := WmsAtuSC9((cAliasDCF)->DCF_CARGA,;
										(cAliasDCF)->DCF_DOCTO,;
										(cAliasDCF)->DCF_SERIE,;
										Self:oMovPrdLot:GetPrdOri(),;
										Self:oMovServic:GetServico(),;
										Self:oMovPrdLot:GetLoteCtl(),;
										Self:oMovPrdLot:GetNumLote(),;
										Self:oMovPrdLot:GetNumSer(),;
										nQuant,;
										/*nQuant2UM*/,;
										Self:oMovEndDes:GetArmazem(),;
										Self:oMovEndDes:GetEnder(),;
										(cAliasDCF)->DCR_IDDCF,;
										IIf(Empty(Self:oOrdServ:GetRegra()),;
										Nil,;
										Val(Self:oOrdServ:GetRegra())),;
										CtoD(''),;
										Self:GetLibPed() == "1")
				EndIf
				(cAliasTRP)->(dbSkip())
			EndDo
			(cAliasTRP)->(dbCloseArea())
			(cAliasDCF)->(dbSkip())
		EndDo
		(cAliasDCF)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdLibVol
Atualiza��o libera��o WMS Volume
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdLibVol() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local oMntVol   := Nil
Local cAliasDCF := GetNextAlias()
	// Verifica se todos os movimentos da DCF foram concluidos
	// Desconsidera o movimento atual,pois o movimento � a ultima atividade mas n�o alterou o status
	BeginSql Alias cAliasDCF
		SELECT DISTINCT DCF.DCF_CARGA,
				DCF.DCF_DOCTO,DCF.DCF_ID,DC5.DC5_MLTATI
		FROM %Table:DCR% DCR1
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		AND D12.D12_STATUS <> '0'
		AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()%
		AND D12.D12_ORDMOV IN ('3','4')
		AND D12.%NotDel%
		INNER JOIN %Table:DC5% DC5
		ON DC5.DC5_FILIAL = %xFilial:DC5%
		AND DC5.DC5_SERVIC = D12.D12_SERVIC
		AND DC5.DC5_TAREFA = D12.D12_TAREFA
		AND DC5.%NotDel%
		AND NOT EXISTS (SELECT 1
						FROM %Table:D12% D12E
						WHERE D12E.D12_FILIAL = %xFilial:D12%
						AND DCR1.DCR_FILIAL = %xFilial:DCR%
						AND D12.D12_FILIAL = %xFilial:D12%
						AND D12E.D12_IDDCF = DCR1.DCR_IDORI
						AND D12E.D12_IDMOV <> %Exp:Self:GetIdMovto()%
						AND D12E.D12_IDOPER <> %Exp:Self:GetIdOpera()%
						AND D12E.D12_SERVIC = D12.D12_SERVIC
						AND D12E.D12_TAREFA = D12.D12_TAREFA
						AND D12E.D12_ORDATI = D12.D12_ORDATI
						AND D12E.D12_STATUS IN ('4','3','2','-')
						AND D12E.%NotDel% )
		INNER JOIN %Table:DCR% DCR
		ON DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDORI = DCR1.DCR_IDORI
		AND DCR.DCR_IDORI = D12.D12_IDDCF
		AND DCR.DCR_IDMOV = D12.D12_IDMOV
		AND DCR.DCR_IDOPER = D12.D12_IDOPER
		AND DCR.%NotDel%
		INNER JOIN %Table:DCF% DCF
		ON DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = DCR.DCR_IDDCF
		AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN
		AND DCF.%NotDel%
		WHERE DCR1.DCR_FILIAL = %xFilial:DCR%
		AND DCR1.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
		AND DCR1.DCR_IDMOV = %Exp:Self:GetIdMovto()%
		AND DCR1.DCR_IDOPER = %Exp:Self:GetIdOpera()%
		AND DCR1.D_E_L_E_T_ = ' '"
	EndSql
	If (cAliasDCF)->(!Eof())
		oMntVol := WMSDTCMontagemVolume():New()
	EndIf
	Do While (cAliasDCF)->(!Eof())
		oMntVol:SetCarga((cAliasDCF)->DCF_CARGA)
		oMntVol:SetPedido((cAliasDCF)->DCF_DOCTO)
		oMntVol:SetIdDCF((cAliasDCF)->DCF_ID)
		oMntVol:SetMultAtiv((cAliasDCF)->DC5_MLTATI)
		// Busca codigo da montagem
		oMntVol:SetCodMnt(oMntVol:FindCodMnt())
		If oMntVol:LoadData()
			If oMntVol:GetStatus() == "3"
				oMntVol:LiberSC9()
			EndIf
		EndIf
		(cAliasDCF)->(dbSkip())
	EndDo
	(cAliasDCF)->(dbCloseArea())
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} MakeTrfSD3
Realiza movimenta��o de entrada e saida SD3
@author alexsander.correa
@since 03/03/2015
@version 1.0
/*/
//--------------------------------------------------
METHOD MakeTrfSD3() CLASS WMSBCCMovimentoServico
Local lRet       := .T.
Local lCabecalho := .T.
Local aRotAuto   := {}
Local aAreaAnt   := GetArea()
Local cWhere     := ""
Local cAliasSB8  := ""
Local cAliasDH1  := Nil
Local nQtdReq    := 0
Local dDtValid   := StoD("")
Local cLocOrigem := ""
Local cEndOrigem := ""
Local cAliasSD3  := ""
Local nQuant     := 0
Local cLote      := ""
Local cIdDCF     := ""

Private lMsErroAuto := .F.
Private lExecWms    := Nil
Private lDocWms     := Nil
Private lEstWmsCq   := Nil

	// Movimenta��o de SD3 quando movimento interno de transferencia.
	If Self:oOrdServ:GetOrigem() == "DH1"
		// Atualiza estoque devolu��o
		cAliasDH1 := GetNextAlias()
		BeginSql Alias cAliasDH1
			SELECT DH1.R_E_C_N_O_ RECNODH1,
				   SB8.B8_DTVALID,
				   DH1.DH1_DTVALI
			  FROM %Table:DH1% DH1
			  LEFT JOIN %Table:SB8% SB8
			    ON SB8.B8_FILIAL = %xFilial:SB8%
			   AND SB8.B8_NUMLOTE = DH1.DH1_NUMLOT
			   AND SB8.B8_LOTECTL = DH1.DH1_LOTECT
			   AND SB8.B8_PRODUTO = DH1.DH1_PRODUT
			   AND SB8.B8_LOCAL = DH1.DH1_LOCAL
			   AND SB8.%NotDel%
			 WHERE DH1.DH1_FILIAL = %xFilial:DH1%
			   AND DH1.DH1_IDDCF = %Exp:Self:oOrdServ:GetIdDCF()%
			   AND DH1.%NotDel%
			 ORDER BY DH1.R_E_C_N_O_
		EndSql
		Do While (cAliasDH1)->(!Eof())
			DH1->(dbSetOrder(1))
			DH1->(dbGoTo((cAliasDH1)->RECNODH1))

			If lCabecalho
				aAdd(aRotAuto, {DH1->DH1_DOC, dDataBase})
				cLocOrigem := DH1->DH1_LOCAL
				cEndOrigem := DH1->DH1_LOCALI
				lCabecalho := .F.
			Else
				// ------------Estrutura do Array------------
				// Titulo     Campo      Tipo Tamanho Decimal
				// ---------- ---------- ---- ------- -------
				// Prod.Orig. D3_COD     C         15       0
				// Desc.Orig. D3_DESCRI  C         30       0
				// UM Orig.   D3_UM      C          2       0
				// Armazem Or D3_LOCAL   C          2       0
				// Endereco O D3_LOCALIZ C         15       0
				// Prod.Desti D3_COD     C         15       0
				// Desc.Desti D3_DESCRI  C         30       0
				// UM Destino D3_UM      C          2       0
				// Armazem De D3_LOCAL   C          2       0
				// Endereco D D3_LOCALIZ C         15       0
				// Numero Ser D3_NUMSERI C         20       0
				// Lote       D3_LOTECTL C         10       0
				// Sub-Lote   D3_NUMLOTE C          6       0
				// Validade   D3_DTVALID D          8       0
				// Potencia   D3_POTENCI N          6       2
				// Quantidade D3_QUANT   N         12       2
				// Qt 2aUM    D3_QTSEGUM N         12       2
				// Estornado  D3_ESTORNO C          1       0
				// Sequencia  D3_NUMSEQ  C          6       0
				// Lote Desti D3_LOTECTL C         10       0
				// Validade D D3_DTVALID D          8       0
				// Cod.Servic D3_SERVIC  C          3       0
				// Item Grade D3_ITEMGRD C          3       0
				// ---------- ---------- ---- ------- -------
				dDtValid := SToD((cAliasDH1)->B8_DTVALID)
				IF Empty(dDtValid) 
				   dDtValid := SToD((cAliasDH1)->DH1_DTVALI)
				EndIF
				
				nQuant := DH1->DH1_QUANT
				cLote  := DH1->DH1_LOTECT
				cIdDCF := DH1->DH1_IDDCF

				aAdd(aRotAuto,{})
				aAdd(aRotAuto[02],{"D3_COD"    , Self:oMovPrdLot:GetProduto()       , Nil}) // [01] Produto origem
				aAdd(aRotAuto[02],{"D3_DESCRI" , Self:oMovPrdLot:oProduto:GetDesc() , Nil}) // [02] Descri��o origem
				aAdd(aRotAuto[02],{"D3_UM"     , Self:oMovPrdLot:oProduto:GetUM()   , Nil}) // [03] Unidade de medica origem
				aAdd(aRotAuto[02],{"D3_LOCAL"  , cLocOrigem                         , Nil}) // [04] Armaz�m origem
				aAdd(aRotAuto[02],{"D3_LOCALIZ", cEndOrigem                         , Nil}) // [05] Endere�o origem
				aAdd(aRotAuto[02],{"D3_COD"    , Self:oMovPrdLot:GetProduto()       , Nil}) // [06] Produto destino
				aAdd(aRotAuto[02],{"D3_DESCRI" , Self:oMovPrdLot:oProduto:GetDesc() , Nil}) // [07] Descri��o origem
				aAdd(aRotAuto[02],{"D3_UM"     , Self:oMovPrdLot:oProduto:GetUM()   , Nil}) // [08] Unidade de medida destino
				aAdd(aRotAuto[02],{"D3_LOCAL"  , DH1->DH1_LOCAL                     , Nil}) // [09] Armaz�m destino
				aAdd(aRotAuto[02],{"D3_LOCALIZ", Self:oMovEndDes:GetEnder()         , Nil}) // [10] Endere�o destino DH1->DH1_LOCALI
				aAdd(aRotAuto[02],{"D3_NUMSERI", DH1->DH1_NUMSER                    , Nil}) // [11] Numero de s�rie
				aAdd(aRotAuto[02],{"D3_LOTECTL", DH1->DH1_LOTECT                    , Nil}) // [12] Lote
				aAdd(aRotAuto[02],{"D3_NUMLOTE", DH1->DH1_NUMLOT                    , Nil}) // [13] Sub-Lote
				aAdd(aRotAuto[02],{"D3_DTVALID", dDtValid                           , Nil}) // [14] Data de validade
				aAdd(aRotAuto[02],{"D3_POTENCI", CriaVar('D3_POTENCI')              , Nil}) // [15]
				aAdd(aRotAuto[02],{"D3_QUANT"  , DH1->DH1_QUANT                     , Nil}) // [16] Quantidade
				aAdd(aRotAuto[02],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM")              , Nil}) // [17]
				aAdd(aRotAuto[02],{"D3_ESTORNO", CriaVar("D3_ESTORNO")              , Nil}) // [18]
				aAdd(aRotAuto[02],{"D3_NUMSEQ" , DH1->DH1_NUMSEQ                    , Nil}) // [19] Numero sequencial
				aAdd(aRotAuto[02],{"D3_LOTECTL", DH1->DH1_LOTECT                    , Nil}) // [20] Lote destino
				aAdd(aRotAuto[02],{"D3_DTVALID", dDtValid                           , Nil}) // [21] Data de validade destino
				aAdd(aRotAuto[02],{"D3_SERVIC" , DH1->DH1_SERVIC                    , Nil}) // [22] Servico
				aAdd(aRotAuto[02],{"D3_ITEMGRD", CriaVar("D3_ITEMGRD")              , Nil}) // [23]
				aAdd(aRotAuto[02],{"D3_IDDCF"  , DH1->DH1_IDDCF                     , Nil}) // [24] Id DCF
			EndIf
			(cAliasDH1)->(dbSkip())
		EndDo
		(cAliasDH1)->(dbCloseArea())

		// Valida se SB2 existe - Armaz�m Origem
		WmsAvalSB2(cLocOrigem,Self:oMovPrdLot:GetProduto())
		// Valida se SB2 existe - Armaz�m Destino
		WmsAvalSB2(DH1->DH1_LOCAL,Self:oMovPrdLot:GetProduto())

		// Indica que ser� DH1 e DCF
		lExecWms       := .T.
		lDocWms        := .T.
		MSExecAuto({|x,y| MATA261(x,y)},aRotAuto,3) //Inclus�o
		If lMsErroAuto
			// Erro na cria��o da SD3 pelo MsExecAuto
			If !IsTelNet()
				MostraErro()
			Else
				VTDispFile(NomeAutoLog(),.t.)
			EndIf
			lRet := .F.
		EndIf

		//Verificar se SD3 foi criada com base na DH1.
		If lRet
			cAliasSD3 := GetNextAlias()

			BeginSql Alias cAliasSD3
				SELECT 1 FROM %Table:SD3% SD3
				WHERE SD3.D3_COD = %Exp:Self:oMovPrdLot:GetProduto()%
				AND SD3.D3_LOTECTL = %Exp:cLote%
				AND SD3.D3_QUANT = %Exp:nQuant%
				AND SD3.D3_LOCAL = %Exp:cLocOrigem%
				AND SD3.D3_LOCALIZ = %Exp:cEndOrigem%
				AND SD3.D3_IDDCF = %Exp:cIdDCF%
				AND SD3.%NotDel%
			EndSql
			If (cAliasSD3)->(Eof())
				Self:cErro := STR0012 //Registros de movimentos internos (SD3) n�o foram criados. Movimento ser� interrompido. Entre em contato com a TI.
				lRet := .F.
			EndIf

			(cAliasSD3)->(dbCloseArea())
		EndIf

		If lRet
			// Atualiza estoque devolu��o
			cAliasDH1 := GetNextAlias()
			BeginSql Alias cAliasDH1
				SELECT DH1.R_E_C_N_O_ RECNODH1
				FROM %Table:DH1% DH1
				WHERE DH1.DH1_FILIAL = %xFilial:DH1%
				AND DH1.DH1_IDDCF = %Exp:Self:oOrdServ:GetIdDCF()%
				AND DH1.D_E_L_E_T_ = ' '
				ORDER BY DH1.R_E_C_N_O_
			EndSql
			Do While (cAliasDH1)->(!Eof())
				DH1->(dbSetOrder(1))
				DH1->(dbGoTo((cAliasDH1)->RECNODH1))
				// Atualiza DH1
				RecLock("DH1",.F.)
				DH1->DH1_STATUS = "2" // Finalizada
				DH1->(MsUnlock())
				(cAliasDH1)->(dbSkip())
			EndDo
			(cAliasDH1)->(dbCloseArea())
		EndIf
		// Quando transfer�ncia
	ElseIf Self:oMovEndOri:GetArmazem() != Self:oMovEndDes:GetArmazem()

		If !Empty(Self:oMovPrdLot:GetLoteCtl())
			cAliasSB8 := GetNextAlias()
			BeginSql Alias cAliasSB8
			SELECT SB8.B8_DTVALID
			  FROM %Table:SB8% SB8
			 WHERE SB8.B8_FILIAL = %xFilial:SB8%
			   AND SB8.B8_NUMLOTE = %Exp:Self:oMovPrdLot:GetNumLote()%
			   AND SB8.B8_LOTECTL = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			   AND SB8.B8_PRODUTO = %Exp:Self:oMovPrdLot:GetProduto() %
			   AND SB8.B8_LOCAL = %Exp:Self:oMovEndOri:GetArmazem()%
			   AND SB8.%NotDel%
			EndSql
			IF (cAliasSB8)->(!EoF())
				dDtValid := SToD((cAliasSB8)->B8_DTVALID)
			Else 
				dDtValid :=  Self:oMovPrdLot:GetDtValid() 
			EndIF
			(cAliasSB8)->(DbCloseArea())
		EndIf
		
		aAdd(aRotAuto, {Self:oOrdServ:GetDocto(), dDataBase})
		aAdd(aRotAuto,{})
		aAdd(aRotAuto[02],{"D3_COD"    , Self:oMovPrdLot:GetProduto()       , Nil}) // [01] Produto origem
		aAdd(aRotAuto[02],{"D3_DESCRI" , Self:oMovPrdLot:oProduto:GetDesc() , Nil}) // [02] Descri��o origem
		aAdd(aRotAuto[02],{"D3_UM"     , Self:oMovPrdLot:oProduto:GetUM()   , Nil}) // [03] Unidade de medica origem
		aAdd(aRotAuto[02],{"D3_LOCAL"  , Self:oMovEndOri:GetArmazem()       , Nil}) // [04] Armaz�m origem
		aAdd(aRotAuto[02],{"D3_LOCALIZ", Self:oMovEndOri:GetEnder()         , Nil}) // [05] Endere�o origem
		aAdd(aRotAuto[02],{"D3_COD"    , Self:oMovPrdLot:GetProduto()       , Nil}) // [06] Produto destino
		aAdd(aRotAuto[02],{"D3_DESCRI" , Self:oMovPrdLot:oProduto:GetDesc() , Nil}) // [07] Descri��o origem
		aAdd(aRotAuto[02],{"D3_UM"     , Self:oMovPrdLot:oProduto:GetUM()   , Nil}) // [08] Unidade de medida destino
		aAdd(aRotAuto[02],{"D3_LOCAL"  , Self:oMovEndDes:GetArmazem()       , Nil}) // [09] Armaz�m destino
		aAdd(aRotAuto[02],{"D3_LOCALIZ", Self:oMovEndDes:GetEnder()         , Nil}) // [10] Endere�o destino DH1->DH1_LOCALI
		aAdd(aRotAuto[02],{"D3_NUMSERI", Self:oMovPrdLot:GetNumSer()        , Nil}) // [11] Numero de s�rie
		aAdd(aRotAuto[02],{"D3_LOTECTL", Self:oMovPrdLot:GetLoteCtl()       , Nil}) // [12] Lote
		aAdd(aRotAuto[02],{"D3_NUMLOTE", Self:oMovPrdLot:GetNumLote()       , Nil}) // [13] Sub-Lote
		aAdd(aRotAuto[02],{"D3_DTVALID", dDtValid                           , Nil}) // [14] Data de validade
		aAdd(aRotAuto[02],{"D3_POTENCI", CriaVar('D3_POTENCI')              , Nil}) // [15]
		aAdd(aRotAuto[02],{"D3_QUANT"  , Self:GetQtdMov()                   , Nil}) // [16] Quantidade
		aAdd(aRotAuto[02],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM")              , Nil}) // [17]
		aAdd(aRotAuto[02],{"D3_ESTORNO", CriaVar("D3_ESTORNO")              , Nil}) // [18]
		aAdd(aRotAuto[02],{"D3_NUMSEQ" , ProxNum()                          , Nil}) // [19] Numero sequencial
		aAdd(aRotAuto[02],{"D3_LOTECTL", Self:oMovPrdLot:GetLoteCtl()       , Nil}) // [20] Lote destino
		aAdd(aRotAuto[02],{"D3_DTVALID", dDtValid                           , Nil}) // [21] Data de validade destino
		aAdd(aRotAuto[02],{"D3_SERVIC" , Self:oMovServic:GetServico()       , Nil}) // [22] Servico
		aAdd(aRotAuto[02],{"D3_ITEMGRD", CriaVar("D3_ITEMGRD")              , Nil}) // [23]
		aAdd(aRotAuto[02],{"D3_IDDCF"  , Self:oOrdServ:GetIdDCF()           , Nil}) // [24] Id DCF

		// Valida se SB2 existe - Armaz�m Origem
		WmsAvalSB2(Self:oMovEndOri:GetArmazem(),Self:oMovPrdLot:GetProduto())
		// Valida se SB2 existe - Armaz�m Destino
		WmsAvalSB2(Self:oMovEndDes:GetArmazem(),Self:oMovPrdLot:GetProduto())

		lExecWms := .T.
		lDocWms  := .T.

		// Quando � criado uma transfer�ncia por meio de um estorno da libera��o do CQ, ao confirmar, a
		// movimenta��o n�o deve gerar um novo SD7
		If !Empty(Self:oOrdServ:GetIdOrig()) .And. Self:oMovEndDes:GetArmazem() == SuperGetMv("MV_CQ",.F.,"98")
			lEstWmsCq := .T. // Vari�vel utilizada na fun��o a261Grava, para impedir a cria��o do CQ.
		EndIf

		MSExecAuto({|x,y| MATA261(x,y)},aRotAuto,3) //Inclus�o
		If lMsErroAuto
			// Erro na cria��o da SD3 pelo MsExecAuto
			If !IsTelNet()
				MostraErro()
			Else
				VTDispFile(NomeAutoLog(),.t.)
			EndIf
			lRet := .F.
		EndIf
		If lRet .And. Self:oOrdServ:GetOrigem() == "SD4"
			// Atualiza DH1
			// Par�metro Where
			cWhere := "%"
			If !Empty(Self:oMovPrdLot:GetLoteCtl())
				cWhere += " AND DH1.DH1_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
			EndIf
			If !Empty(Self:oMovPrdLot:GetNumLote())
				cWhere += " AND DH1.DH1_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
			EndIf
			cWhere += "%"
			cAliasDH1 := GetNextAlias()
			BeginSql Alias cAliasDH1
				SELECT DH1.R_E_C_N_O_ RECNODH1
				FROM %table:DH1% DH1
				WHERE DH1.DH1_FILIAL = %xFilial:DH1%
				AND DH1.DH1_IDDCF = %Exp:Self:oOrdServ:GetIdDCF()%
				AND DH1.%NotDel%
				%Exp:cWhere%
				ORDER BY DH1.R_E_C_N_O_
			EndSql
			If (cAliasDH1)->(!Eof())
				nQtdReq := Self:GetQtdMov()
				Do While (cAliasDH1)->(!Eof()) .And. nQtdReq > 0
					DH1->(dbGoTo((cAliasDH1)->RECNODH1))
					RecLock("DH1",.F.)
					If QtdComp(DH1->DH1_QUANT) <= QtdComp(nQtdReq)
						nQtdReq -= DH1->DH1_QUANT
						DH1->DH1_QUANT := 0
					Else
						DH1->DH1_QUANT -= nQtdReq
						nQtdReq := 0
					EndIf
					If DH1->DH1_QUANT <= 0
						DH1->(dbDelete())
					EndIf
					DH1->(MsUnlock())
					(cAliasDH1)->(dbSkip())
				EndDo
			EndIf
			(cAliasDH1)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} MakeUpdSD3
Atualiza SD3 libera��o requisi��o
@author Squad WMS
@since 18/10/2017
@version 2.0
/*/
//--------------------------------------------------
METHOD MakeUpdSD3() CLASS WMSBCCMovimentoServico
Local lRet       := .T.
Local lBaixaEst  := Self:GetBxEsto() == "1"
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3("DCR_QUANT")
Local aRotAuto   := {}
Local aCustoMov  := {0,0,0,0,0} // Utilizado para fazer rateio do custo
Local oOrdSerAux:= WMSDTCOrdemServico():New()
Local cAliasD12  := ""
Local cAliasDCR  := ""

Private lMsErroAuto := .F.
Private lExecWms    := Nil
Private lDocWms     := Nil
	//-------------------------------------------------------------------------//
	//            Busca ordens de servi�o totalmente finalizadas               //
	//-------------------------------------------------------------------------//
	cAliasDCR := GetNextAlias()
	BeginSql Alias cAliasDCR
		SELECT DCR.DCR_IDDCF,
				DCR.DCR_SEQUEN
		FROM %Table:DCR% DCR
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
		AND DCR.DCR_SEQUEN = %Exp:Self:oOrdServ:GetSequen()%
		AND DCR.%NotDel%
		AND NOT EXISTS (SELECT 1
						FROM %Table:DCR% DCRE, %Table:D12% D12E
						WHERE DCRE.DCR_FILIAL = %xFilial:DCR%
						AND DCR.DCR_FILIAL = %xFilial:DCR%
						AND DCRE.DCR_IDDCF = DCR.DCR_IDDCF
						AND DCRE.DCR_SEQUEN = DCR.DCR_SEQUEN
						AND DCRE.%NotDel%
						AND D12E.D12_FILIAL = %xFilial:D12%
						AND D12E.D12_IDDCF = DCRE.DCR_IDORI
						AND D12E.D12_IDMOV <> %Exp:Self:GetIdMovto()%
						AND D12E.D12_IDOPER <> %Exp:Self:GetIdOpera()%
						AND D12E.D12_ATUEST = '1'
						AND D12E.D12_STATUS IN ('4','3','2','-')
						AND D12E.%NotDel% )
		GROUP BY DCR.DCR_IDDCF,
				DCR.DCR_SEQUEN
	EndSql
	Do While (cAliasDCR)->(!EoF()) .And. lRet
		//-------------------------------------------------------------------------//
		// Baixa reservas SB2 e SB8 para a quantidade completa da ordem de servi�o //
		//-------------------------------------------------------------------------//
		oOrdSerAux:SetIdDCF((cAliasDCR)->DCR_IDDCF)
		If oOrdSerAux:LoadData()
			// Baixa da reserva do SB2
			Self:oOrdServ:UpdEmpSB2("-",oOrdSerAux:oProdLote:GetPrdOri(),Self:oMovEndOri:GetArmazem(),oOrdSerAux:GetQuant())
			// Baixa da reserva do SB8
			If Self:oMovPrdLot:HasRastro()
				Self:oOrdServ:UpdEmpSB8("-",oOrdSerAux:oProdLote:GetPrdOri(),Self:oMovEndOri:GetArmazem(),oOrdSerAux:oProdLote:GetLoteCtl(),oOrdSerAux:oProdLote:GetNumLote(),oOrdSerAux:GetQuant())
			EndIf
			//Atualiza status DH1
			DH1->(DbSetOrder(2)) //DH1_FILIAL+DH1_DOC+DH1_NUMSEQ
			If DH1->(!DbSeek(xFilial("DH1")+oOrdSerAux:GetDocto()+oOrdSerAux:GetNumSeq()))
				Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",Self:oOrdServ:GetDocto()},{"[VAR02]",Self:oOrdServ:GetNumSeq()}}) // "N�o foi poss�vel encontrar a movimenta��o origem para o Documento:[VAR01]/NumSeq:[VAR02] (DH1)"
				lRet := .F.
			Else
				RecLock("DH1",.F.)
				DH1->DH1_STATUS = "2" // Ordem de servi�o realizada
				DH1->(MsUnlock())
			EndIf
		Else
			Self:cErro :=  WmsFmtMsg(STR0004,{{"[VAR01",(cAliasDCR)->DCR_IDDCF}}) //Erro ao encontrar ordem de sevi�o [VAR01] para baixar saldo em estoque.
			lRet := .F.
		EndIf
		//-------------------------------------------------------------------------//
		// Baixa empenho D14 para todas as movimenta��es da ordem de servi�o       //
		//-------------------------------------------------------------------------//
		If lRet
			cAliasD12 := GetNextAlias()
			BeginSql Alias cAliasD12
				SELECT D12.D12_PRODUT,
						D12.D12_PRDORI,
						D12.D12_LOTECT,
						D12.D12_NUMLOT,
						D12.D12_NUMSER,
						D12.D12_LOCDES,
						D12.D12_ENDDES,
						D12.D12_IDMOV,
						D12.D12_IDOPER,
						D12.D12_UNIDES,
						DCR.DCR_QUANT
				FROM %Table:DCR% DCR
				INNER JOIN %Table:D12% D12
				ON D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_IDDCF = DCR.DCR_IDORI
				AND D12.D12_IDMOV = DCR.DCR_IDMOV
				AND D12.D12_IDOPER = DCR.DCR_IDOPER
				AND D12.D12_SEQUEN = DCR.DCR_SEQUEN
				AND D12.D12_ATUEST = '1'
				AND D12.%NotDel%
				WHERE DCR.DCR_FILIAL = %xFilial:DCR%
				AND DCR.DCR_IDDCF  = %Exp:(cAliasDCR)->DCR_IDDCF%
				AND DCR.DCR_SEQUEN = %Exp:(cAliasDCR)->DCR_SEQUEN%
				AND DCR.%NotDel%
			EndSql
			TcSetField(cAliasD12,'DCR_QUANT','N',aTamSX3[1],aTamSX3[2])
			Do While (cAliasD12)->(!Eof())
				// Retira apenas o empenho do endere�o
				// Carrega dados para Estoque por Endere�o
				// Baixa de saldo de separa��o n�o controla unitizador
				Self:oEstEnder:ClearData()
				Self:oEstEnder:oEndereco:SetArmazem((cAliasD12)->D12_LOCDES)
				Self:oEstEnder:oEndereco:SetEnder((cAliasD12)->D12_ENDDES)
				Self:oEstEnder:oProdLote:SetArmazem((cAliasD12)->D12_LOCDES)
				Self:oEstEnder:oProdLote:SetPrdOri((cAliasD12)->D12_PRDORI)
				Self:oEstEnder:oProdLote:SetProduto((cAliasD12)->D12_PRODUT ) // Componente
				Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD12)->D12_LOTECT ) // Lote do produto principal que dever� ser o mesmo no componentes
				Self:oEstEnder:oProdLote:SetNumLote((cAliasD12)->D12_NUMLOT ) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
				Self:oEstEnder:SetQuant((cAliasD12)->DCR_QUANT )
				// Seta o bloco de c�digo para informa��es do documento para o Kardex
				Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
											oMovEstEnd:SetOrigem(oOrdSerAux:GetOrigem()),;
											oMovEstEnd:SetDocto(oOrdSerAux:GetDocto()),;
											oMovEstEnd:SetSerie(oOrdSerAux:GetSerie()),;
											oMovEstEnd:SetCliFor(oOrdSerAux:GetCliFor()),;
											oMovEstEnd:SetLoja(oOrdSerAux:GetLoja()),;
											oMovEstEnd:SetNumSeq(oOrdSerAux:GetNumSeq()),;
											oMovEstEnd:SetIdDCF(oOrdSerAux:GetIdDCF())})
				// Seta o bloco de c�digo para informa��es do movimento para o Kardex
				Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
											oMovEstEnd:SetIdMovto(""),;
											oMovEstEnd:SetIdOpera(""),;
											oMovEstEnd:SetIdUnit("")})
				// Realiza Sa�da Armazem Estoque por Endere�o
				If !Self:oEstEnder:UpdSaldo('999',.F./*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T. /*lEmpenho*/,.F. /*lBloqueio*/,/*lEmpPrev*/,.F./*lMovEstEnd*/)
					Self:cErro := Self:oEstEnder:GetErro()
					lRet := .F.
					Exit
				EndIf
				(cAliasD12)->(dbSkip())
			EndDo
			//-------------------------------------------------------------------------//
			// Baixa estoque D14 para todas as movimenta��es da ordem de servi�o       //
			// Gera SD3 de sa�da de endere�o do DOCA                                   //
			//-------------------------------------------------------------------------//
			If lRet .And. lBaixaEst
				// Deve fazer um rateio do custo caso haja mais de um registro de movimenta��o
				// Pode ocorrer quando o produto controla lote e solicitou mais de um lote pelo WMS
				If DH1->DH1_CUSTO1 > 0
					aCustoMov[1] := ((oOrdSerAux:GetQuant() * DH1->DH1_CUSTO1) / DH1->DH1_QUANT)
				EndIf
				If DH1->DH1_CUSTO2 > 0
					aCustoMov[2] := ((oOrdSerAux:GetQuant() * DH1->DH1_CUSTO2) / DH1->DH1_QUANT)
				EndIf
				If DH1->DH1_CUSTO3 > 0
					aCustoMov[3] := ((oOrdSerAux:GetQuant() * DH1->DH1_CUSTO3) / DH1->DH1_QUANT)
				EndIf
				If DH1->DH1_CUSTO4 > 0
					aCustoMov[4] := ((oOrdSerAux:GetQuant() * DH1->DH1_CUSTO4) / DH1->DH1_QUANT)
				EndIf
				If DH1->DH1_CUSTO5 > 0
					aCustoMov[5] := ((oOrdSerAux:GetQuant() * DH1->DH1_CUSTO5) / DH1->DH1_QUANT)
				EndIf
				aRotAuto := {}
				aAdd(aRotAuto,{"D3_TM"     , DH1->DH1_TM                           ,Nil})
				aAdd(aRotAuto,{"D3_DOC"    , DH1->DH1_DOC                          ,Nil})
				aAdd(aRotAuto,{"D3_EMISSAO", dDataBase                             ,Nil})
				aAdd(aRotAuto,{"D3_NUMSEQ" , DH1->DH1_NUMSEQ                       ,Nil})
				aAdd(aRotAuto,{"D3_COD"    , DH1->DH1_PRODUT                       ,Nil})
				If Rastro(DH1->DH1_PRODUT)
					aAdd(aRotAuto,{"D3_LOTECTL", oOrdSerAux:oProdLote:GetLoteCtl() ,Nil})
					aAdd(aRotAuto,{"D3_NUMLOTE", oOrdSerAux:oProdLote:GetNumLote() ,Nil})
				EndIf
				aAdd(aRotAuto,{"D3_LOCAL"  , DH1->DH1_LOCAL                        ,Nil})
				aAdd(aRotAuto,{"D3_LOCALIZ", oOrdSerAux:oOrdEndDes:GetEnder()      ,Nil})
				aAdd(aRotAuto,{"D3_QUANT"  , oOrdSerAux:GetQuant()                 ,Nil})
				aAdd(aRotAuto,{"D3_TRT"    , DH1->DH1_TRT                          ,Nil})
				aAdd(aRotAuto,{"D3_PROJPMS", DH1->DH1_PROJPM                       ,Nil})
				aAdd(aRotAuto,{"D3_TASKPMS", DH1->DH1_TASKPM                       ,Nil})
				aAdd(aRotAuto,{"D3_CLVL"   , DH1->DH1_CLVL                         ,Nil})
				aAdd(aRotAuto,{"D3_SERVIC" , DH1->DH1_SERVIC                       ,Nil})
				aAdd(aRotAuto,{"D3_STSERV" , oOrdSerAux:GetStServ()                ,Nil})
				aAdd(aRotAuto,{"D3_CC"     , DH1->DH1_CC                           ,Nil})
				aAdd(aRotAuto,{"D3_CONTA"  , DH1->DH1_CONTA                        ,Nil})
				aAdd(aRotAuto,{"D3_ITEMCTA", DH1->DH1_ITEMCT                       ,Nil})
				aAdd(aRotAuto,{"D3_OP"     , DH1->DH1_OP                           ,Nil})
				aAdd(aRotAuto,{"D3_NUMSA"  , DH1->DH1_NUMSA                        ,Nil})
				aAdd(aRotAuto,{"D3_ITEMSA" , DH1->DH1_ITEMSA                       ,Nil})
				aAdd(aRotAuto,{"D3_IDDCF"  , DH1->DH1_IDDCF                        ,Nil})
				aAdd(aRotAuto,{"D3_REGWMS" , oOrdSerAux:GetRegra()                 ,Nil})
				aAdd(aRotAuto,{"D3_CUSTO1" , aCustoMov[1]                          ,Nil})
				aAdd(aRotAuto,{"D3_CUSTO2" , aCustoMov[2]                          ,Nil})
				aAdd(aRotAuto,{"D3_CUSTO3" , aCustoMov[3]                          ,Nil})
				aAdd(aRotAuto,{"D3_CUSTO4" , aCustoMov[4]                          ,Nil})
				aAdd(aRotAuto,{"D3_CUSTO5" , aCustoMov[5]                          ,Nil})
				aAdd(aRotAuto,{"D3_POTENCI", DH1->DH1_POTENC                       ,Nil})
				// Indica que ser� DH1 e DCF
				lExecWms       := .T.
				lDocWms        := .T.
				// Realiza a baixa do SD3 com base no DH1
				MSExecAuto({|x,y| MATA240(x,y)},aRotAuto,3) //Inclus�o
				If lMsErroAuto
					// Erro na cria��o da SD3 pelo MsExecAuto
					If !IsTelNet()
						MostraErro()
					Else
						VTDispFile(NomeAutoLog(),.t.)
					EndIf
					lRet := .F.
				EndIf
				(cAliasD12)->(DbGoTop())
				If lRet
					Do While (cAliasD12)->(!Eof())
						// AtualizaSaldo
						// Carrega dados para Estoque por Endere�o
						// Baixa de saldo de separa��o n�o controla unitizador
						Self:oEstEnder:ClearData()
						Self:oEstEnder:oEndereco:SetArmazem((cAliasD12)->D12_LOCDES)
						Self:oEstEnder:oEndereco:SetEnder((cAliasD12)->D12_ENDDES)
						Self:oEstEnder:oProdLote:SetArmazem((cAliasD12)->D12_LOCDES)
						Self:oEstEnder:oProdLote:SetPrdOri((cAliasD12)->D12_PRDORI)
						Self:oEstEnder:oProdLote:SetProduto((cAliasD12)->D12_PRODUT ) // Componente
						Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD12)->D12_LOTECT ) // Lote do produto principal que dever� ser o mesmo no componentes
						Self:oEstEnder:oProdLote:SetNumLote((cAliasD12)->D12_NUMLOT ) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
						Self:oEstEnder:SetQuant((cAliasD12)->DCR_QUANT )
						// Seta o bloco de c�digo para informa��es do documento para o Kardex
						Self:oEstEnder:SetBlkDoc({|oMovEstEnd|;
													oMovEstEnd:SetOrigem(oOrdSerAux:GetOrigem()),;
													oMovEstEnd:SetDocto(oOrdSerAux:GetDocto()),;
													oMovEstEnd:SetSerie(oOrdSerAux:GetSerie()),;
													oMovEstEnd:SetCliFor(oOrdSerAux:GetCliFor()),;
													oMovEstEnd:SetLoja(oOrdSerAux:GetLoja()),;
													oMovEstEnd:SetNumSeq(oOrdSerAux:GetNumSeq()),;
													oMovEstEnd:SetIdDCF(oOrdSerAux:GetIdDCF())})
													// Seta o bloco de c�digo para informa��es do movimento para o Kardex
						Self:oEstEnder:SetBlkMov({|oMovEstEnd|;
													oMovEstEnd:SetIdMovto((cAliasD12)->D12_IDMOV),;
													oMovEstEnd:SetIdOpera((cAliasD12)->D12_IDOPER),;
													oMovEstEnd:SetIdUnit((cAliasD12)->D12_UNIDES)})
						// Realiza Sa�da Armazem Estoque por Endere�o
						If !Self:oEstEnder:UpdSaldo('999',.T./*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,/*lEmpPrev*/,.T./*lMovEstEnd*/)
							Self:cErro := Self:oEstEnder:GetErro()
							lRet := .F.
							Exit
						EndIf
						(cAliasD12)->(DbSkip())
					EndDo
				EndIf
			EndIf
			(cAliasD12)->(dbCloseArea())
		EndIf
		(cAliasDCR)->(DbSkip())
	EndDo
	(cAliasDCR)->(DbCloseArea())
	oOrdSerAux:Destroy()
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdMntVol
Atualiza montagem de volume
@author felipe.m
@since 08/04/2015
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdMntVol(nQtde,cVolume) CLASS WMSBCCMovimentoServico
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local oMntVolItem := WMSDTCMontagemVolumeItens():New()
Local oVolumeItem := WMSDTCVolumeItens():New()
Local cAliasQry   := ""
Local cAliasDCV   := ""
Local nQtdVol     := 0
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_CARGA,
				SC9.C9_PEDIDO,
				SC9.C9_ITEM,
				SC9.C9_SEQUEN,
				SC9.C9_QTDLIB,
				DCF.DCF_ID,
				DCR.DCR_QUANT
		FROM %Table:DCR% DCR
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND DCR.DCR_FILIAL = %xFilial:DCR%
		AND D12.D12_IDDCF = DCR.DCR_IDORI"
		AND D12.D12_IDMOV = DCR.DCR_IDMOV"
		AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		AND D12.%NotDel%
		INNER JOIN %Table:SC9% SC9
		ON SC9.C9_FILIAL = %xFilial:SC9%
		AND DCR.DCR_FILIAL = %xFilial:DCR%
		AND SC9.C9_IDDCF = DCR.DCR_IDDCF
		AND SC9.C9_LOTECTL = D12.D12_LOTECT
		AND SC9.C9_NUMLOTE = D12.D12_NUMLOT
		AND SC9.%NotDel%
		INNER JOIN %Table:DCF% DCF
		ON DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCF.DCF_ID = DCR.DCR_IDDCF
		AND DCF.%NotDel%
		WHERE DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
		AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
		AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
		AND DCR.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof()) .And. QtdComp(nQtde) > 0
		// � preciso descontar a quantidade embalada em volumes anteriores
		cAliasDCV := GetNextAlias()
		BeginSql Alias cAliasDCV
			SELECT SUM(DCV.DCV_QUANT) AS SOMADCV
			FROM %Table:DCV% DCV
			WHERE DCV.DCV_FILIAL = %xFilial:DCV%
			AND DCV.DCV_CARGA = %Exp:(cAliasQry)->DCF_CARGA%
			AND DCV.DCV_PEDIDO = %Exp:(cAliasQry)->C9_PEDIDO%
			AND DCV.DCV_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
			AND DCV.DCV_LOTE = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND DCV.DCV_SUBLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND DCV.DCV_ITEM = %Exp:(cAliasQry)->C9_ITEM%
			AND DCV.DCV_SEQUEN = %Exp:(cAliasQry)->C9_SEQUEN%
			AND DCV.%NotDel%
		EndSql
		// Calculo multiplo para os filhos
		If !(Self:oMovPrdLot:GetPrdOri() == Self:oMovPrdLot:GetProduto())
			Self:oMovPrdLot:oProduto:oProdComp:SetPrdCmp(Self:oMovPrdLot:GetProduto())
			Self:oMovPrdLot:oProduto:oProdComp:LoadData(2)
		EndIf
		nQtdSld := (((cAliasQry)->C9_QTDLIB * Self:oMovPrdLot:oProduto:oProdComp:GetQtMult()) - (cAliasDCV)->SOMADCV)
		(cAliasDCV)->(dbCloseArea()) // Fecha a query da soma
		If QtdComp(nQtdSld) > QtdComp(nQtde)
			nQtdVol := nQtde
		Else
			nQtdVol := nQtdSld
		EndIf
		If QtdComp(nQtdVol) > QtdComp((cAliasQry)->DCR_QUANT)
			nQtdVol := (cAliasQry)->DCR_QUANT
		EndIf
		If QtdComp(nQtdVol) <= 0
			(cAliasQry)->(dbSkip())
			Loop
		EndIf
		oMntVolItem:SetCarga((cAliasQry)->DCF_CARGA)
		oMntVolItem:SetPedido((cAliasQry)->C9_PEDIDO)
		oMntVolItem:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
		oMntVolItem:SetProduto(Self:oMovPrdLot:GetProduto())
		oMntVolItem:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
		oMntVolItem:SetNumLote(Self:oMovPrdLot:GetNumLote())
		// Busca o codigo da montagem de volume
		oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
		If oMntVolItem:LoadData()
			// DCV
			oVolumeItem:SetCodMnt(oMntVolItem:GetCodMnt())
			oVolumeItem:SetCarga(oMntVolItem:GetCarga())
			oVolumeItem:SetPedido(oMntVolItem:GetPedido())
			oVolumeItem:SetCodVol(cVolume)
			oVolumeItem:SetPrdOri(oMntVolItem:GetPrdOri())
			oVolumeItem:SetProduto(oMntVolItem:GetProduto())
			oVolumeItem:SetLoteCtl(oMntVolItem:GetLoteCtl())
			oVolumeItem:SetNumLote(oMntVolItem:GetNumLote())
			oVolumeItem:SetCodOpe(__CUSERID)
			oVolumeItem:SetItem((cAliasQry)->C9_ITEM)
			oVolumeItem:SetSequen((cAliasQry)->C9_SEQUEN)
			oVolumeItem:SetQuant(nQtdVol)
			oVolumeItem:AssignDCV()
			// DCT
			oMntVolItem:SetQtdSep(oMntVolItem:GetQtdSep() + nQtdVol)
			oMntVolItem:SetQtdEmb(oMntVolItem:GetQtdEmb() + nQtdVol)
			oMntVolItem:SetIdDCF((cAliasQry)->DCF_ID)
			If oMntVolItem:UpdateDCT()
				If WmsCarga(oMntVolItem:GetCarga())
					WMV081Fina(1,oMntVolItem:GetCarga(),oMntVolItem:GetPedido(),oMntVolItem:GetCodMnt(),.F.,Self:ChkSolImpE())
				Else
					WMV081Fina(2,Nil,oMntVolItem:GetPedido(),oMntVolItem:GetCodMnt(),.F.,Self:ChkSolImpE())
				EndIf
			Else
				lRet := .F.
				Self:cErro := MntVolItem:oMntVol:GetErro()
			EndIf
			nQtde -= nQtdVol
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} HasUsrAtv
Verifica se tem usu�rio ativo
@author felipe.m
@since 23/12/2014
@version 1.0
@param cRecHum, character, (C�digo do recurso humano)
@param cFuncao, character, (C�digo da fun��o)
@param cUsuArma, character, (C�digo do usu�rio)
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------
METHOD HasUsrAtv(cRecHum,cFuncao,cUsuArma) CLASS WMSBCCMovimentoServico
Local lRet      := .F.
Local aAreaD12  := D12->(GetArea())
Local cAliasD12 := GetNextAlias()
Local cRecD12   := AllTrim(Str(Self:GetRecno()))
Local nCnt      := 0
	For nCnt := 1 To Len(Self:aColetor)
		cRecD12 := cRecD12+","+AllTrim(Str(Self:aColetor[nCnt,1]))
	Next
	
	cRecD12 := "%" + cRecD12 + "%"
	
	If !Empty(cUsuArma)
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
			AND D12.D12_TAREFA = %Exp:Self:oMovTarefa:GetTarefa()%
			AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
			AND D12.D12_STATUS = '3'"
			AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()%
			AND D12.D12_ORDATI = %Exp:Self:oMovTarefa:GetOrdem()%
			AND D12.D12_RECHUM = %Exp:cRecHum%
			AND D12.D12_RHFUNC = %Exp:cFuncao%
			AND D12.D12_LOCORI = %Exp:cUsuArma%
			AND D12.R_E_C_N_O_ NOT IN ( %Exp:cRecD12% )
			AND D12.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
			AND D12.D12_TAREFA = %Exp:Self:oMovTarefa:GetTarefa()%
			AND D12.D12_ATIVID = %Exp:Self:oMovTarefa:GetAtivid()%
			AND D12.D12_STATUS = '3'"
			AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()%
			AND D12.D12_ORDATI = %Exp:Self:oMovTarefa:GetOrdem()%
			AND D12.D12_RECHUM = %Exp:cRecHum%
			AND D12.D12_RHFUNC = %Exp:cFuncao%
			AND D12.R_E_C_N_O_ NOT IN ( %Exp:cRecD12% )
			AND D12.%NotDel%
		EndSql
	EndIf
	If (cAliasD12)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasD12)->(DbCloseArea())
	RestArea(aAreaD12)
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} OrdColetor
Ordem coletor
@author felipe.m
@since 23/12/2014
@version 1.0
@param nOriDest, num�rico, (Descri��o do par�metro)
/*/
//--------------------------------------------------
METHOD OrdColetor(nOriDest) CLASS WMSBCCMovimentoServico
Local aAux := {}
Local i
Local nWmsMDes  := SuperGetMV('MV_WMSMDES',.F.,0)
Local aColetorX := aClone(Self:aColetor)

Default nOriDest := 1

	If nWmsMDes == 0
		// ordena��o por endere�o destino
		ASort(aColetorX,,,{|x,y| x[5]+x[6]+x[7]+x[8] < y[5]+y[6]+y[7]+y[8]})

		For i:= 1 to Len(aColetorX)

			// para produtos+lote+sublote no mesmo endereco destino faz o agrupamento somando as quantidades.
			If nOriDest == 1
				nAux := aScan(aAux,{|x|x[5]+x[6]+x[7]+x[8] == aColetorX[i][5]+aColetorX[i][6]+aColetorX[i][7]+aColetorX[i][8] })
			Else
				nAux := aScan(aAux,{|x|x[4]+x[6]+x[7]+x[8] == aColetorX[i][4]+aColetorX[i][6]+aColetorX[i][7]+aColetorX[i][8] })
			EndIf
			If nAux == 0
				aAdd(aAux,aColetorX[i])
			Else
				aAux[nAux][9] += aColetorX[i][9]
			EndIf

			aDel(aColetorX,i) // apaga do array o registro que ja foi gravado no array auxiliar
			aSize(aColetorX,Len(aColetorX)-1)   //exclui fisicamente o registro, reordenando o array

			If Len(aColetorX) > 0
				i--   // como eh eliminado cada registro do array apanhe, decrementa o contador
			Else
				Exit // quando todos os registros ja estiverem reordenados no array auxiliar, sai fora do FOR
			EndIf
		Next i

	ElseIf nWmsMDes == 1 // ordenacao inversa do apanhe agrupando por endereco destino iguais
		aSort(aColetorX,,,{|x,y| x[2] > y[2]}) //1o ordena no inverso do apanhe
		// monta array auxiliar agrupando por endereco destino
		aAux := {}
		cEndDest := ''
		For i:= 1 To Len(aColetorX)

			nReg := aScan(aColetorX,{|x|x[5] == cEndDest }) // verifica se tem algum registro com o mesmo endereco destino
			If nReg > 0 .And. aScan(aAux,{|x| x[2] == aColetorX[nReg][2]}) == 0 // se achar com mesmo endereco verifica ainda se ja foi gravado no array auxiliar

				// para produtos+lote+sublote no mesmo endereco destino faz o agrupamento somando as quantidades.
				nAux := aScan(aAux,{|x|x[5]+x[6]+x[7]+x[8] == aColetorX[nReg][5]+aColetorX[nReg][6]+aColetorX[nReg][7]+aColetorX[nReg][8] })
				If nAux == 0
					aAdd(aAux,aColetorX[nReg])
				Else
					aAux[nAux][9] += aColetorX[nReg][9]
				EndIf

				aDel(aColetorX,nReg) // apaga do array o registro que ja foi gravado no array auxiliar
				aSize(aColetorX,Len(aColetorX)-1)   // exclui fisicamente o registro, reordenando o array
			Else
				cEndDest := aColetorX[i][5] // armazena nessa variavel para agrupar por endereco destino

				// para produtos+lote+sublote no mesmo endereco destino faz o agrupamento somando as quantidades.
				nAux := aScan(aAux,{|x|x[5]+x[6]+x[7]+x[8] == aColetorX[i][5]+aColetorX[i][6]+aColetorX[i][7]+aColetorX[i][8] })
				If nAux == 0
					aAdd(aAux,aColetorX[i])
				Else
					aAux[nAux][9] += aColetorX[i][9]
				EndIf

				aDel(aColetorX,i)
				aSize(aColetorX,Len(aColetorX)-1)
			EndIf
			If Len(aColetorX) > 0
				i--   // como eh eliminado cada registro do array apanhe, decrementa o contador
			Else
				Exit // quando todos os registros ja estiverem reordenados no array auxiliar, sai fora do FOR
			EndIf
		Next i

	EndIf
Return aAux

METHOD UpdEndOri(cNewEnd,cNewUnit, cNewTip) CLASS WMSBCCMovimentoServico
Return Self:UpdEndMov(1,cNewEnd,cNewUnit,cNewTip)
//--------------------------------------------------
/*/{Protheus.doc} UpdEndDes
Atualiza endere�o destino
@author felipe.m
@since 23/12/2014
@version 1.0
@param cNewEnd, character, (Novo endere�o)
/*/
//--------------------------------------------------
METHOD UpdEndDes(cNewEnd,cNewUnit, cNewTip) CLASS WMSBCCMovimentoServico
Return Self:UpdEndMov(2,cNewEnd,cNewUnit,cNewTip)

//--------------------------------------------------
/*/{Protheus.doc} UpdEndMov
Atualiza endere�o origem ou destino do movimento
@author jackson.werka
@since 12/09/2017
@version 1.0
@param nTipo, num�rico, 1-Endere�o Origem;2-Endere�o Destino
@param cNewEnd, character, (Novo endere�o)
/*/
//--------------------------------------------------
METHOD UpdEndMov(nTipo,cNewEnd,cNewUnit,cNewTip) CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local lEntPrev  := (nTipo == 2)
Local lSaiPrev  := (nTipo == 1)
Local lEmpPrev  := Self:oMovServic:ChkSepara()
Local aAreaD12  := D12->(GetArea())
Local aTamSX3   := {}
Local oMovAux   := WMSDTCMovimentosServicoArmazem():New()
Local cAliasD12 := Nil
Local cAliasD14 := Nil
Local cSitList  := ""

	If nTipo == 1 // Endere�o Origem
		cSitList := "('2','4')"
	Else
		cSitList := "('2','3','4')"
	EndIf
	cSitList := "%"+cSitList+"%"
	cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT D12.R_E_C_N_O_ RECD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_DOC = %Exp:Self:oOrdServ:GetDocto()%
		AND D12.D12_SERIE = %Exp:Self:oOrdServ:GetSerie()%
		AND D12.D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
		AND D12.D12_LOJA = %Exp:Self:oOrdServ:GetLoja()%
		AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
		AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
		AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
		AND D12.D12_LOCORI = %Exp:Self:oMovEndOri:GetArmazem()%
		AND D12.D12_ENDORI = %Exp:Self:oMovEndOri:GetEnder()%
		AND D12.D12_LOCDES = %Exp:Self:oMovEndDes:GetArmazem()%
		AND D12.D12_ENDDES = %Exp:Self:oMovEndDes:GetEnder()%
		AND D12.D12_IDMOV  = %Exp:Self:GetIdMovto()%
		AND D12.D12_STATUS IN %Exp:cSitList%
		AND D12.%NotDel%
	EndSql
	Do While lRet .And. (cAliasD12)->(!Eof())
		oMovAux:GoToD12((cAliasD12)->RECD12)
		// Atualiza��o do endere�o do moviemento
		If oMovAux:IsUpdEst()
			If Self:IsMovUnit()
				cAliasD14 := GetNextAlias()
				BeginSql Alias cAliasD14
					SELECT D14.D14_CODUNI,
							D14.D14_PRDORI,
							D14.D14_PRODUT,
							D14.D14_LOTECT,
							D14.D14_NUMLOT,
							D14.D14_QTDEST
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:Self:cIdUnitiz%
					AND D14.D14_LOCAL = %Exp:Self:oMovEndOri:GetArmazem()%
					AND D14.D14_ENDER = %Exp:Self:oMovEndOri:GetEnder()%
					AND D14.%NotDel%
				EndSql
				aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
				If (cAliasD14)->(!Eof())
					Do While lRet .And. (cAliasD14)->(!Eof())
						// Carrega dados para LoadData EstEnder
						Self:oEstEnder:ClearData()
						If nTipo == 1 // Endere�o Origem
							Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
							Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
						Else
							Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
							Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
						EndIf
						Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
						Self:oEstEnder:oProdLote:SetPrdOri((cAliasD14)->D14_PRDORI)   // Produto Origem - Componente
						Self:oEstEnder:oProdLote:SetProduto((cAliasD14)->D14_PRODUT) // Produto Principal
						Self:oEstEnder:oProdLote:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote do produto principal que dever� ser o mesmo no componentes
						Self:oEstEnder:oProdLote:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
						// Se for alterar o endere�o destino e este n�o for unitizado, n�o deve passar o unitizador
						If nTipo == 1
							If Self:OriNotUnit()
								Self:oEstEnder:SetIdUnit("")
								Self:oEstEnder:SetTipUni("")
							Else
								Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
								Self:oEstEnder:SetTipUni((cAliasD14)->D14_CODUNI)
							EndIf
						Else
							If Self:DesNotUnit()
								Self:oEstEnder:SetIdUnit("")
								Self:oEstEnder:SetTipUni("")
							Else
								Self:oEstEnder:SetIdUnit(Self:cUniDes)
								Self:oEstEnder:SetTipUni((cAliasD14)->D14_CODUNI)
							EndIf
						EndIf
						// Atribui a quantidade do produto no unitizador
						Self:oEstEnder:SetQuant((cAliasD14)->D14_QTDEST)
						// Desfaz entrada prevista do endereco atual
						lRet := Self:oEstEnder:UpdSaldo('999',.F./*lEstoque*/,lEntPrev,lSaiPrev,.F./*lEmpenho*/,.F./*lBloqueio*/,lEmpPrev)
						// Gera entrada prevista para o endereco novo
						If lRet
							// Carrega o novo endere�o no movimento auxiliar para validar o mesmo
							If nTipo == 1 
								// Endere�o Origem
								oMovAux:oMovEndOri:SetEnder(cNewEnd)
								oMovAux:oMovEndOri:LoadData()
								// Se o novo endere�o � unitizado, deve gravar o unitizador
								If oMovAux:OriNotUnit()
									Self:oEstEnder:SetIdUnit("")
									Self:oEstEnder:SetTipUni("")
								Else
									Self:oEstEnder:SetIdUnit(cNewUnit)
									Self:oEstEnder:SetTipUni(cNewTip)
								EndIf
							Else
								// Endere�o destino
								oMovAux:oMovEndDes:SetEnder(cNewEnd)
								oMovAux:oMovEndDes:LoadData()
								// Se o novo endere�o � unitizado, deve gravar o unitizador
								If oMovAux:DesNotUnit()
									Self:oEstEnder:SetIdUnit("")
									Self:oEstEnder:SetTipUni("")
								Else
									Self:oEstEnder:SetIdUnit(cNewUnit)
									Self:oEstEnder:SetTipUni(cNewTip)
								EndIf
							EndIf
							Self:oEstEnder:oEndereco:SetEnder(cNewEnd)
							lRet := Self:oEstEnder:UpdSaldo('499',.F./*lEstoque*/,lEntPrev,lSaiPrev,.F./*lEmpenho*/,.F./*lBloqueio*/,lEmpPrev)
						EndIf
						If !lRet
							Self:cErro := Self:oEstEnder:GetErro()
						EndIf
						(cAliasD14)->(DbSkip())
					EndDo
				Else
					Self:cErro := WmsFmtMsg(STR0001,{{"[VAR01]",Self:cIdUnitiz}}) // N�o foi encontrado o saldo por endere�o do unitizador [VAR01].
					lRet := .F.
				EndIf
				(cAliasD14)->(DbCloseArea())
			Else
				Self:oEstEnder:ClearData()
				If nTipo == 1 // Endere�o Origem
					Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
					Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
				Else
					Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
					Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
				EndIf
				Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem())
				Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
				Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
				Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl())
				Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote())
				Self:oEstEnder:SetQuant(Self:GetQtdMov())
				// Se for alterar o endere�o destino e este n�o for unitizado, n�o deve passar o unitizador
				If nTipo == 1
					If Self:OriNotUnit()
						Self:oEstEnder:SetIdUnit("")
						Self:oEstEnder:SetTipUni("")
					Else	
						Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
					EndIf
				Else
					If Self:DesNotUnit()
						Self:oEstEnder:SetIdUnit("")
						Self:oEstEnder:SetTipUni("")
					Else
						Self:oEstEnder:SetIdUnit(Self:cUniDes)
					EndIf
				EndIf
				// Desfaz entrada prevista do endereco atual
				lRet := Self:oEstEnder:UpdSaldo('999',.F./*lEstoque*/,lEntPrev,lSaiPrev,.F./*lEmpenho*/,.F./*lBloqueio*/,lEmpPrev)
				// Gera entrada prevista para o endereco novo
				If lRet
					If nTipo == 1 
						// Endere�o Origem
						oMovAux:oMovEndOri:SetEnder(cNewEnd)
						oMovAux:oMovEndOri:LoadData()
						// Se o novo endere�o � unitizado, deve gravar o unitizador
						If oMovAux:OriNotUnit()
							Self:oEstEnder:SetIdUnit("")
							Self:oEstEnder:SetTipUni("")
						Else
							Self:oEstEnder:SetIdUnit(cNewUnit)
							Self:oEstEnder:SetTipUni(cNewTip)
						EndIf
					Else
						// Endere�o Destino
						oMovAux:oMovEndDes:SetEnder(cNewEnd)
						oMovAux:oMovEndDes:LoadData()
						// Se o novo endere�o � unitizado, deve gravar o unitizador
						If oMovAux:DesNotUnit()
							Self:oEstEnder:SetIdUnit("")
							Self:oEstEnder:SetTipUni("")
						Else
							Self:oEstEnder:SetIdUnit(cNewUnit)
							Self:oEstEnder:SetTipUni(cNewTip)
						EndIf
					EndIf
					Self:oEstEnder:oEndereco:SetEnder(cNewEnd)
					lRet := Self:oEstEnder:UpdSaldo('499',.F./*lEstoque*/,lEntPrev,lSaiPrev,.F./*lEmpenho*/,.F./*lBloqueio*/,lEmpPrev)
				EndIf
				If !lRet
					Self:cErro := Self:oEstEnder:GetErro()
				EndIf
			EndIf
		EndIf
		// Atualiza o endereco na movimenta��o convocada
		If nTipo == 1 
			// Endere�o Origem
			oMovAux:oMovEndOri:SetEnder(cNewEnd)
			oMovAux:SetIdUnit(cNewUnit)
		Else
			// Endere�o Destino
			oMovAux:oMovEndDes:SetEnder(cNewEnd)
			oMovAux:SetUniDes(cNewUnit)
		EndIf
		oMovAux:UpdateD12()
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())

	If lRet .And. Iif(nTipo == 1,!Empty(Self:oOrdServ:oOrdEndOri:GetEnder()),!Empty(Self:oOrdServ:oOrdEndDes:GetEnder()))
		// Se possui mais de um movimento com endere�os diferentes para a ordem de servi�o
		// Limpa o endere�o destino informado na ordem de servi�o e processos complementares
		If Self:HasMoreEnd(nTipo,cNewEnd)
			cNewEnd := ""
		EndIf

		If Self:oOrdServ:GetOrigem() == "DH1"
			// Atualiza o endere�o na DH1 quando foi informado.
			DH1->(dbSetOrder(1)) // DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ
			DH1->(dbSeek(xFilial("DH1")+Self:oOrdServ:GetDocto()+Self:oMovEndOri:GetArmazem()+Self:oOrdServ:GetNumSeq()))
			Do While DH1->(!Eof()) .And. xFilial("DH1")+Self:oOrdServ:GetDocto()+Self:oMovEndDes:GetArmazem()+Self:oOrdServ:GetNumSeq() == DH1->(DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ)
				If Self:GetIdDCF() == DH1->DH1_IDDCF
					RecLock('DH1',.F.)
					DH1->DH1_LOCALI := cNewEnd
					DH1->(MsUnLock())
				EndIf
				DH1->(dbSkip())
			EndDo
		ElseIf Self:oOrdServ:GetOrigem() == "SC9"
			SC9->(dbSetOrder(9)) // C9_FILIAL+C9_IDDCF
			If SC9->(dbSeek(xFilial("SC9")+Self:GetIdDCF()))
				SC6->(dbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If SC6->(dbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
					RecLock('SC6',.F.)
					SC6->C6_LOCALIZ := cNewEnd
					SC6->(MsUnLock())
				EndIf
			EndIf
		EndIf
		If nTipo == 1 // Endere�o Origem
			Self:oOrdServ:oOrdEndOri:SetEnder(cNewEnd)
		Else
			Self:oOrdServ:oOrdEndDes:SetEnder(cNewEnd)
		EndIf
		Self:oOrdServ:UpdateDCF()
	EndIf
	// Atualiza registro corrente
	RestArea(aAreaD12)
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} HitMovEst
Realiza acerto no estoque para quantidades separadas
a menor.
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD HitMovEst() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local lEmpPrev  := Self:oMovServic:ChkSepara()
	// Caso servico de separa��o gera quantidade empenho
	// Caso n�o seja separa��o gera quantidade saida prevista
	// Carrega dados para LoadData EstEndEr
	Self:oEstEnder:ClearData()
	Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
	Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
	Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
	Self:oEstEnder:oProdLote:SetPrdOri(Self:oMovPrdLot:GetPrdOri())   // Produto Origem - Componente
	Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
	Self:oEstEnder:oProdLote:SetLoteCtl(Self:oMovPrdLot:GetLoteCtl()) // Lote do produto principal que dever� ser o mesmo no componentes
	Self:oEstEnder:oProdLote:SetNumLote(Self:oMovPrdLot:GetNumLote()) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
	Self:oEstEnder:SetIdUnit(Self:cIdUnitiz)
	//Self:oEstEnder:SetTipUni(Self:cTipUni) // Registro j� existe na D14 com tipo, n�o informar para n�o sobrepor
	Self:oEstEnder:SetQuant(Self:nQtdMovto)
	lRet := Self:oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,lEmpPrev /*lEmpPrev*/)
	// Carrega dados para LoadData EstEndEr
	// Ajusta entrada prevista no endere�o destino.
	If lRet
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
		Self:oEstEnder:SetIdUnit("") // Limpa o unitizador na descarga da separa��o
		Self:oEstEnder:SetTipUni("") // Limpa o unitizador na descarga da separa��o
		lRet := Self:oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/)
	EndIf
Return lRet
/*----------------------------------------------------------------------
---ValCapReab
---M�todo utilizado para verificar a capacidade da estrutura de picking
---para convocar a atividades de reabastecimento
---alexsander.correa 07/11/2016
----------------------------------------------------------------------*/
METHOD ValCapReab() CLASS WMSBCCMovimentoServico
Local lRet       := .T.
Local nCapEnder  := 0
Local lPercOcup  := .F.
Local nSaldoD14  := 0
	// Se n�o est� carregada a sequ�ncia de abastecimento, 
	If Empty(Self:oMovSeqAbt:GetCodNor()) .Or. Self:oMovSeqAbt:GetEstFis() != Self:oMovEndDes:GetEstFis()
		Self:oMovSeqAbt:SetProduto(Self:oMovPrdLot:GetProduto())
		Self:oMovSeqAbt:SetArmazem(Self:oMovEndDes:GetArmazem())
		Self:oMovSeqAbt:SetEstFis(Self:oMovEndDes:GetEstFis())
		If !Self:oMovSeqAbt:LoadData(2)
			lRet := .F.
		EndIf
	EndIf
	If lRet
		// Verifica se o endere�o utiliza percentual de ocupa��o
		lPercOcup := WmsChkDCP(Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEnder(),Self:oMovEndDes:GetEstFis(),Self:oMovSeqAbt:GetCodNor(),Self:oMovPrdLot:GetProduto())
		Self:oEstEnder:ClearData()
		Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndDes:GetArmazem())
		Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndDes:GetEnder())
		// Se possui percentual de ocupa��o, deve considerar o saldo do produto apenas
		If lPercOcup
			Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto())
		EndIf

		nSaldoD14 := Self:oEstEnder:ConsultSld(.F.,.F.,.F.,.F.)

		nCapEnder := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),/*cDesUni*/,.T.,Self:oMovEndDes:GetEnder()) // Considerar a qtd pelo nr de unitizadores
		If nSaldoD14 >= nCapEnder
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*----------------------------------------------------------------------
---ValMntExc
---M�todo utilizado para verificar a montagem de volume exclusiva para movimentos aglutinados
---amanda.vieira 09/11/2016
----------------------------------------------------------------------*/
METHOD ValMntExc() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local lCarga    := (SuperGetMV('MV_WMSACAR', .F., 'S')=='S')
Local cAliasQry := ""
Local cCargaVz  := Space(TamSx3("DCF_CARGA")[1])

	If Self:GetAgluti() == "1"
		cAliasQry := GetNextAlias()
		If lCarga
			BeginSql Alias cAliasQry
				SELECT DCFA.DCF_CARGA,
						DCFA.DCF_DOCTO
				FROM %Table:DCR% DCRA
				INNER JOIN %Table:DCF% DCFA"
				ON DCFA.DCF_FILIAL = %xFilial:DCF%
				AND DCFA.DCF_ID = DCRA.DCR_IDDCF
				AND DCFA.DCF_STSERV = '3'
				AND DCFA.%NotDel%
				INNER JOIN %Table:DCS% DCSA
				ON DCSA.DCS_FILIAL = %xFilial:DCS%
				AND DCSA.DCS_CODMNT = ( SELECT MAX(DCSB.DCS_CODMNT) DCS_CODMNT
										FROM %Table:DCS% DCSB
										WHERE DCSB.DCS_FILIAL = DCSA.DCS_FILIAL
										AND DCSB.DCS_CARGA = DCSA.DCS_CARGA
										AND DCSB.DCS_PEDIDO = DCSA.DCS_PEDIDO
										AND DCSB.D_E_L_E_T_ = ' ')
				AND DCSA.DCS_CARGA = DCFA.DCF_CARGA
				AND DCSA.DCS_PEDIDO = DCFA.DCF_DOCTO
				AND DCSA.DCS_MNTEXC <> '0'
				AND DCSA.%NotDel%
				WHERE DCRA.DCR_FILIAL = %xFilial:DCR%
				AND DCRA.DCR_IDMOV = %Exp:Self:GetIdMovto()%
				AND DCRA.DCR_IDOPER = %Exp:Self:GetIdOpera()%
				AND DCRA.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
				AND ((DCSA.DCS_MNTEXC = '1' 
					AND EXISTS( SELECT DCFB.DCF_CARGA
								FROM %Table:DCR% DCRB
								INNER JOIN %Table:DCF% DCFB
								ON DCFB.DCF_FILIAL = DCFA.DCF_FILIAL
								AND DCFB.DCF_ID = DCRB.DCR_IDDCF
								AND DCFB.DCF_STSERV = '3'
								AND DCFB.%NotDel%
								WHERE DCRB.DCR_FILIAL = DCRA.DCR_FILIAL
								AND DCRB.DCR_IDMOV = DCRA.DCR_IDMOV
								AND DCRB.DCR_IDOPER = DCRA.DCR_IDOPER
								AND DCRB.DCR_IDORI = DCRA.DCR_IDORI
								AND (DCFB.DCF_CARGA = %Exp:cCargaVz%
									OR DCFB.DCF_CARGA <> DCFA.DCF_CARGA )
								AND DCRB.%NotDel% ))
					OR (DCSA.DCS_MNTEXC = '2' 
						AND EXISTS( SELECT DCFB.DCF_DOCTO
									FROM %Table:DCR% DCRB
									INNER JOIN %Table:DCF% DCFB
									ON DCFB.DCF_FILIAL = DCFA.DCF_FILIAL
									AND DCFB.DCF_ID = DCRB.DCR_IDDCF
									AND DCFB.DCF_STSERV = '3'
									AND DCFB.DCF_DOCTO <> DCFA.DCF_DOCTO
									AND DCFB.%NotDel%
									WHERE DCRB.DCR_FILIAL = DCRA.DCR_FILIAL
									AND DCRB.DCR_IDMOV = DCRA.DCR_IDMOV
									AND DCRB.DCR_IDOPER = DCRA.DCR_IDOPER
									AND DCRB.DCR_IDORI = DCRA.DCR_IDORI
									AND DCRB.%NotDel% ))
					OR (DCSA.DCS_MNTEXC = '3' 
						AND EXISTS( SELECT DCFB.DCF_DOCTO
									FROM %Table:DCR% DCRB
									INNER JOIN %Table:DCF% DCFB
									ON DCFB.DCF_FILIAL = DCFA.DCF_FILIAL
									AND DCFB.DCF_ID = DCRB.DCR_IDDCF
									AND DCFB.DCF_STSERV = '3'
									AND (DCFB.DCF_CLIFOR <> DCFA.DCF_CLIFOR
										OR DCFB.DCF_LOJA <> DCFA.DCF_LOJA)
									AND DCFB.%NotDel%
									WHERE DCRB.DCR_FILIAL = DCRA.DCR_FILIAL
									AND DCRB.DCR_IDMOV = DCRA.DCR_IDMOV
									AND DCRB.DCR_IDOPER = DCRA.DCR_IDOPER
									AND DCRB.DCR_IDORI = DCRA.DCR_IDORI
									AND DCRB.%NotDel% )))
				AND DCRA.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasQry
				SELECT DCFA.DCF_CARGA,
						DCFA.DCF_DOCTO
				FROM %Table:DCR% DCRA
				INNER JOIN %Table:DCF% DCFA"
				ON DCFA.DCF_FILIAL = %xFilial:DCF%
				AND DCFA.DCF_ID = DCRA.DCR_IDDCF
				AND DCFA.DCF_STSERV = '3'
				AND DCFA.%NotDel%
				INNER JOIN %Table:DCS% DCSA
				ON DCSA.DCS_FILIAL = %xFilial:DCS%
				AND DCSA.DCS_CODMNT = ( SELECT MAX(DCSB.DCS_CODMNT) DCS_CODMNT
										FROM %Table:DCS% DCSB
										WHERE DCSB.DCS_FILIAL = DCSA.DCS_FILIAL
										AND DCSB.DCS_CARGA = DCSA.DCS_CARGA
										AND DCSB.DCS_PEDIDO = DCSA.DCS_PEDIDO
										AND DCSB.D_E_L_E_T_ = ' ')
				AND DCSA.DCS_CARGA = DCFA.DCF_CARGA
				AND DCSA.DCS_PEDIDO = DCFA.DCF_DOCTO
				AND DCSA.DCS_MNTEXC <> '0'
				AND DCSA.%NotDel%
				WHERE DCRA.DCR_FILIAL = %xFilial:DCR%
				AND DCRA.DCR_IDMOV = %Exp:Self:GetIdMovto()%
				AND DCRA.DCR_IDOPER = %Exp:Self:GetIdOpera()%
				AND DCRA.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
				AND ((DCSA.DCS_MNTEXC = '1' 
					AND EXISTS( SELECT DCFB.DCF_CARGA
								FROM %Table:DCR% DCRB
								INNER JOIN %Table:DCF% DCFB
								ON DCFB.DCF_FILIAL = DCFA.DCF_FILIAL
								AND DCFB.DCF_ID = DCRB.DCR_IDDCF
								AND DCFB.DCF_STSERV = '3'
								AND DCFB.%NotDel%
								WHERE DCRB.DCR_FILIAL = DCRA.DCR_FILIAL
								AND DCRB.DCR_IDMOV = DCRA.DCR_IDMOV
								AND DCRB.DCR_IDOPER = DCRA.DCR_IDOPER
								AND DCRB.DCR_IDORI = DCRA.DCR_IDORI
								AND DCFB.DCF_DOCTO <> DCFA.DCF_DOCTO
								AND DCRB.%NotDel% ))
					OR (DCSA.DCS_MNTEXC = '2' 
						AND EXISTS( SELECT DCFB.DCF_DOCTO
									FROM %Table:DCR% DCRB
									INNER JOIN %Table:DCF% DCFB
									ON DCFB.DCF_FILIAL = DCFA.DCF_FILIAL
									AND DCFB.DCF_ID = DCRB.DCR_IDDCF
									AND DCFB.DCF_STSERV = '3'
									AND DCFB.DCF_DOCTO <> DCFA.DCF_DOCTO
									AND DCFB.%NotDel%
									WHERE DCRB.DCR_FILIAL = DCRA.DCR_FILIAL
									AND DCRB.DCR_IDMOV = DCRA.DCR_IDMOV
									AND DCRB.DCR_IDOPER = DCRA.DCR_IDOPER
									AND DCRB.DCR_IDORI = DCRA.DCR_IDORI
									AND DCRB.%NotDel% ))
					OR (DCSA.DCS_MNTEXC = '3' 
						AND EXISTS( SELECT DCFB.DCF_DOCTO
									FROM %Table:DCR% DCRB
									INNER JOIN %Table:DCF% DCFB
									ON DCFB.DCF_FILIAL = DCFA.DCF_FILIAL
									AND DCFB.DCF_ID = DCRB.DCR_IDDCF
									AND DCFB.DCF_STSERV = '3'
									AND (DCFB.DCF_CLIFOR <> DCFA.DCF_CLIFOR
										OR DCFB.DCF_LOJA <> DCFA.DCF_LOJA)
									AND DCFB.%NotDel%
									WHERE DCRB.DCR_FILIAL = DCRA.DCR_FILIAL
									AND DCRB.DCR_IDMOV = DCRA.DCR_IDMOV
									AND DCRB.DCR_IDOPER = DCRA.DCR_IDOPER
									AND DCRB.DCR_IDORI = DCRA.DCR_IDORI
									AND DCRB.%NotDel% )))
				AND DCRA.%NotDel%
			EndSql
		EndIf
		If (cAliasQry)->(!Eof())
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet
/*----------------------------------------------------------------------
---ValTrocEnd
---M�todo utilizado ao trocar o endere�o destino via coletor, para verificar se a estrutura do 
endere�o informado faz parte da sequ�ncia de abastecimento do produto.
---wander.horongoso 09/04/2020
----------------------------------------------------------------------*/
METHOD ValTrocEnd(cEndDest) CLASS WMSBCCMovimentoServico
Local lRet := .T.
Local cAliasQry := GetNextAlias()

	IF Self:IsMovUnit()
		BeginSql Alias cAliasQry
			SELECT D14.D14_PRODUT
			FROM %Table:SBE% SBE
			INNER JOIN %Table:D14% D14
			ON D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = SBE.BE_LOCAL
			AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
			AND D14.%NotDel%
			WHERE SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
			AND SBE.BE_LOCALIZ =  %Exp:cEndDest%
			AND SBE.%NotDel%
			AND NOT EXISTS (SELECT DISTINCT 1 
							FROM %Table:DC3% DC3
							WHERE DC3.DC3_FILIAL = %xFilial:DC3%
							AND DC3.DC3_LOCAL = D14.D14_LOCAl
							AND DC3.DC3_CODPRO = D14.D14_PRODUT
							AND DC3.DC3_TPESTR = SBE.BE_ESTFIS
							AND DC3.%NotDel%)
		EndSql
		If (cAliasQry)->(!Eof())
			Self:cErro := STR0010 // "Estrutura fisica do endere�o n�o existe para um ou mais produtos do unitizador."
			lRet := .F. 
		EndIf
		(cAliasQry)->(dbCloseArea())

	Else 
		BeginSql Alias cAliasQry
			SELECT DISTINCT 1
			FROM %Table:SBE% SBE
			INNER JOIN %Table:DC3% DC3
			ON DC3.DC3_FILIAL = %xFilial:DC3%
			AND DC3.DC3_LOCAL = SBE.BE_LOCAL
			AND DC3.DC3_CODPRO = %Exp:Self:oMovPrdLot:GetProduto()%
			AND DC3.DC3_TPESTR = SBE.BE_ESTFIS
			AND DC3.%NotDel%
			WHERE SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = %Exp:Self:oMovEndDes:GetArmazem()%
			AND SBE.BE_LOCALIZ = %Exp:cEndDest%
			AND SBE.%NotDel%
		EndSql
		If (cAliasQry)->(Eof())
		   Self:cErro := STR0011 //"Endere�o com estrutura n�o cadastrada na sequ�ncia de abastecimento do produto."
			lRet:= .F.    
		End If 
		(cAliasQry)->(dbCloseArea())
	EndIf

Return lRet
/*--------------------------------------------------------------------------------
---HasPrdSep
---Verifica se o produto foi totalmente separado
---alexsander.correa - 28/11/2016
----------------------------------------------------------------------------------*/
METHOD HasPrdSep() CLASS WMSBCCMovimentoServico
Local lRet      := .F.
Local cAliasQry := GetNextAlias()
	If WmsCarga(Self:oOrdServ:GetCarga())
		BeginSql Alias cAliasQry
			SELECT DISTINCT 1
			FROM %Table:DCF% DCF
			INNER JOIN %Table:DCR% DCR
			ON DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = DCF.DCF_ID
			AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN
			AND DCR.%NotDel%
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = DCF.DCF_SERVIC
			AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND D12.D12_IDDCF  = DCR.DCR_IDORI
			AND D12.D12_IDMOV  = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_ORDTAR = %Exp:Self:oMovServic:FindOrdAnt()% // Assume a tarefa exatamante anterior
			AND D12.D12_ORDMOV IN ('3','4')
			AND D12.D12_STATUS IN ('-','2','3','4')
			AND D12.%NotDel%
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC = %Exp:Self:oMovServic:GetServico()%
			AND DCF.DCF_CARGA =  %Exp:Self:oOrdServ:GetCarga()%
			AND DCF.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DISTINCT 1
			FROM %Table:DCF% DCF
			INNER JOIN %Table:DCR% DCR
			ON DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = DCF.DCF_ID
			AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN
			AND DCR.%NotDel%
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = DCF.DCF_SERVIC
			AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
			AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
			AND D12.D12_IDDCF  = DCR.DCR_IDORI
			AND D12.D12_IDMOV  = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_ORDTAR = %Exp:Self:oMovServic:FindOrdAnt()% // Assume a tarefa exatamante anterior
			AND D12.D12_ORDMOV IN ('3','4')
			AND D12.D12_STATUS IN ('-','2','3','4')
			AND D12.%NotDel%
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC = %Exp:Self:oMovServic:GetServico()%
			AND DCF.DCF_DOCTO =  %Exp:Self:oOrdServ:GetDocto()%
			AND DCF.%NotDel%
		EndSql
	EndIf
	// Se n�o encontrar movimentos anteriores pendentes de finaliza��o
	lRet := (cAliasQry)->(Eof())
	(cAliasQry)->(DbCloseArea())
Return lRet
/*---------------------------------------------------------
---ChkSitMov
---Verifica a situa��o do moviemento para permitir alterar o endere�o.
---felipe.m 13/11/2015
---------------------------------------------------------*/
METHOD ChkSitMov() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT D12.D12_STATUS
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_IDDCF = %Exp:Self:GetIdDCF()%
		AND D12.D12_IDMOV = %Exp:Self:GetIdMovto()%
		AND D12.%NotDel%
	EndSql
	Do While (cAliasD12)->(!Eof())
		If !((cAliasD12)->D12_STATUS $ "2|4")
			lRet := .F.
			Exit
		EndIf
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ChkFinMov
Valida saldos do produto no endere�o
a menor.
@author Squad WMS Protheus
@since 20/06/2018
@version 1.0

@return l�gico
@param aErroFin, array, Erros gerados
@param nQuant, N�merico, Quantidade � ser validada
/*/
METHOD ChkFinMov(aErroFin,nQuant) CLASS WMSBCCMovimentoServico
Local lRet       := .T.
Local lConsBlq   := .F.

If ExistBlock('WMSQYABA')
	lConsBlq := ExecBlock('WMSQYABA',.F.,.F.,{})
EndIf

Default aErroFin := {}
Default nQuant   := 0
	// Finalizar ou Apontar a movimenta��o
	Self:SetQuant(nQuant)
	// Valida bloqueio produto (B1_MSBLQL)
	If !Self:IsMovUnit() .And. !WmsSB1Blq(Self:oMovPrdLot:GetProduto(),@Self:cErro)
		lRet := .F.
	EndIf
	// Desconsidera bloqueio, bloqueio de sa�da, bloqueio de invent�rio.
	If lRet .And. !Self:oMovServic:ChkConfer()
		If !Self:ChkEndOri(.T.,.T.,,lConsBlq)
			lRet := .F.
		EndIf
		// Desconsidera bloqueio, bloqueio de entrada, bloqueio de invent�rio.
		If lRet .And. !Self:ChkEndDes(.T.)
			lRet := .F.
		EndIf
	EndIf
	// Grava array de erros se houver
	If !lRet
		Aadd(aErroFin, WmsFmtMsg(STR0002,{{"[VAR01]",Self:oOrdServ:GetDocto()+Iif(!Empty(Self:oOrdServ:GetSerie()),"/"+AllTrim(Self:oOrdServ:GetSerie()),'')},{"[VAR02]",Self:oOrdServ:oProdLote:GetProduto()},{"[VAR03]",Self:GetIdDCF()},{"[VAR04]",Self:GetIdMovto()},{"[VAR05]",Self:GetIdOpera()}}) + CRLF +Self:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02] - Id. OS: [VAR03] - Id. Movimento: [VAR04] - Id. Opera��o: [VAR05].
	EndIf
Return lRet

METHOD HasMoreMov() CLASS WMSBCCMovimentoServico
Local lRet      := .F.
Local cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT COUNT(*) COUNTD12
		FROM %Table:D12% D12
		WHERE D12_FILIAL = %xFilial:D12%
		AND D12_DOC = %Exp:Self:oOrdServ:GetDocto()%
		AND D12_SERIE = %Exp:Self:oOrdServ:GetSerie()%
		AND D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
		AND D12_LOJA = %Exp:Self:oOrdServ:GetLoja()%
		AND D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
		AND D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
		AND D12_IDDCF = %Exp:Self:GetIdDCF()%
		AND D12_IDMOV <> %Exp:Self:GetIdMovto()%
		AND D12.%NotDel%
	EndSql
	If (cAliasD12)->(!Eof())
		lRet := (cAliasD12)->COUNTD12 > 0
	EndIf
	(cAliasD12)->(DbCloseArea())
Return lRet

METHOD HasMoreEnd(nTipo,cEndereco) CLASS WMSBCCMovimentoServico
Local lRet      := .F.
Local cAliasD12 := GetNextAlias()
Local cArmazem  := ""

	If nTipo == 1  // Endere�o origem
		cArmazem := Self:oMovEndOri:GetArmazem()
	Else // Endereco destino
		cArmazem := Self:oMovEndDes:GetArmazem()
	EndIf
	BeginSql Alias cAliasD12
		SELECT COUNT(*) COUNTD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_DOC = %Exp:Self:oOrdServ:GetDocto()%
		AND D12.D12_SERIE = %Exp:Self:oOrdServ:GetSerie()%
		AND D12.D12_CLIFOR = %Exp:Self:oOrdServ:GetCliFor()%
		AND D12.D12_LOJA = %Exp:Self:oOrdServ:GetLoja()%
		AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
		AND D12.D12_TAREFA = %Exp:Self:oMovServic:GetTarefa()%
		AND D12.D12_IDDCF = %Exp:Self:GetIdDCF()%
		AND D12.D12_LOCORI = %Exp:cArmazem%
		AND D12.D12_ENDORI <> %Exp:cEndereco%
		AND D12.D12_IDMOV  <> %Exp:Self:GetIdMovto()%
		AND D12.%NotDel%
	EndSql
	If (cAliasD12)->(!Eof())
		lRet := (cAliasD12)->COUNTD12 > 0
	EndIf
	(cAliasD12)->(DbCloseArea())
Return lRet

METHOD UpdSldDis() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local aTamSx3   := {}
Local oSaldoADis:= WMSDTCSaldoADistribuir():New()
Local cAliasTRP := Nil
Local cAliasDCF := Nil
Local cAliasQry := Nil
	If Self:IsMovUnit()
		// Ajusta a quantidade � distribuir dos produtos normais
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D0S.D0S_PRDORI,
					D0S.D0S_IDD0Q,
					D0S.D0S_QUANT,
					D0Q.D0Q_LOCAL,
					D0Q.D0Q_DOCTO,
					D0Q.D0Q_SERIE,
					D0Q.D0Q_CLIFOR,
					D0Q.D0Q_LOJA,
					D0Q.D0Q_NUMSEQ
			FROM %Table:D0S% D0S
			INNER JOIN %Table:D0Q% D0Q
			ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
			AND D0Q.%NotDel%
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D0S.D0S_CODPRO = D0S.D0S_PRDORI
			AND D0S.%NotDel%
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			//Desconta saldo a distribuir de movimenta��es de endere�amento que n�o possuam bloqueio de saldo
			oSaldoADis:ClearData()
			//Informa��es do produto
			oSaldoADis:oProdLote:SetArmazem((cAliasQry)->D0Q_LOCAL)
			oSaldoADis:oProdLote:SetProduto((cAliasQry)->D0S_PRDORI)
			oSaldoADis:SetIdDCF((cAliasQry)->D0S_IDD0Q)
			oSaldoADis:SetDocto((cAliasQry)->D0Q_DOCTO)
			oSaldoADis:SetSerie((cAliasQry)->D0Q_SERIE)
			oSaldoADis:SetCliFor((cAliasQry)->D0Q_CLIFOR)
			oSaldoADis:SetLoja((cAliasQry)->D0Q_LOJA)
			oSaldoADis:SetNumSeq((cAliasQry)->D0Q_NUMSEQ)
			If oSaldoADis:LoadData(1)
				oSaldoADis:SetQtdSld(oSaldoADis:GetSaldo()-(cAliasQry)->D0S_QUANT)
				If QtdComp(oSaldoADis:GetSaldo()) > 0
					lRet := oSaldoADis:UpdateD0G()
				Else
					lRet := oSaldoADis:DeleteD0G()
				EndIf
			EndIF
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		// Ajusta a quantidade � distribuir dos produtos componentes
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D0S.D0S_IDD0Q,
					D0S.D0S_PRDORI
			FROM %Table:D0S% D0S
			INNER JOIN %Table:D0Q% D0Q
			ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
			AND D0Q.%NotDel%
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D0S.D0S_CODPRO <> D0S.D0S_PRDORI
			AND D0S.%NotDel%
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			// Busca os documentos e retorna a quantidade que poder� ser liberada
			cAliasTRP := GetNextAlias()
			BeginSql Alias cAliasTRP
				SELECT MIN((CASE WHEN TRP.D0S_QUANT IS NULL THEN 0 ELSE TRP.D0S_QUANT END )/ D11.D11_QTMULT) D0S_QUANT
				FROM %Table:D11% D11
				LEFT JOIN (SELECT SUM(D0S1.D0S_QUANT) D0S_QUANT,
									D0S1.D0S_CODPRO,
									D0S1.D0S_PRDORI
							FROM %Table:D0S% D0S1
							WHERE D0S1.D0S_FILIAL = %xFilial:D0S%
							AND D0S1.D0S_IDD0Q  = %Exp:(cAliasQry)->D0S_IDD0Q%
							AND ( D0S1.D0S_ENDREC = '1'
								OR ( D0S1.D0S_ENDREC = '2' AND D0S1.D0S_IDUNIT = %Exp:Self:cIdUnitiz% ))
							AND D0S1.%NotDel%
							GROUP BY D0S1.D0S_CODPRO,
										D0S1.D0S_PRDORI) TRP
				ON D11.D11_FILIAL = %xFilial:D11%	
				AND D11.D11_PRDORI = TRP.D0S_PRDORI
				AND D11.D11_PRDCMP = TRP.D0S_CODPRO
				AND D11.%NotDel%
				WHERE D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = %Exp:(cAliasQry)->D0S_PRDORI%
				AND D11.%NotDel%
			EndSql
			aTamSX3 := TamSx3("D14_QTDEST");TcSetField(cAliasTRP,'D0S_QUANT','N',aTamSx3[1],aTamSx3[2])
			Do While lRet .And. (cAliasTRP)->(!Eof()) .And. QtdComp(Int((cAliasTRP)->D0S_QUANT)) > 0
				// Atribui a quantidade multipla separada
				nQuant := Int((cAliasTRP)->D0S_QUANT)

				oSaldoADis:SetIdDCF((cAliasQry)->D0S_IDD0Q)
				If oSaldoADis:LoadData(3)
					oSaldoADis:SetQtdSld(oSaldoADis:GetQtdOri() - nQuant)
					If QtdComp(oSaldoADis:GetSaldo()) > 0
						lRet := oSaldoADis:UpdateD0G()
					Else
						lRet := oSaldoADis:DeleteD0G()
					EndIf
				EndIf
				(cAliasTRP)->(dbSkip())
			EndDo
			(cAliasTRP)->(dbCloseArea())
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Else
		If Self:oMovPrdLot:GetProduto() == Self:oMovPrdLot:GetPrdOri()
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT DCR.DCR_IDDCF,
						DCR.DCR_QUANT
				FROM %Table:DCR% DCR
				INNER JOIN %Table:DCF% DCF
				ON DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCR.DCR_FILIAL = %xFilial:DCR%
				AND DCF.DCF_ID = DCR.DCR_IDDCF
				AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
				AND DCF.%NotDel%
				WHERE DCR.DCR_FILIAL = %xFilial:DCR%
				AND DCR.DCR_IDORI = %Exp:Self:GetIdDCF()%
				AND DCR.DCR_SEQUEN = %Exp:Self:GetSequen()%
				AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
				AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
				AND DCR.%NotDel%
			EndSql
			Do While lRet .And. (cAliasQry)->(!Eof())
				oSaldoADis:SetIdDCF((cAliasQry)->DCR_IDDCF)
				If oSaldoADis:LoadData(3)
					oSaldoADis:SetQtdSld(oSaldoADis:GetSaldo() - (cAliasQry)->DCR_QUANT)
					If QtdComp(oSaldoADis:GetSaldo()) > 0
						lRet := oSaldoADis:UpdateD0G()
					Else
						lRet := oSaldoADis:DeleteD0G()
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		Else
			cAliasDCF := GetNextAlias()
			BeginSql Alias cAliasDCF
				SELECT DISTINCT DCF.DCF_CARGA,
						DCF.DCF_DOCTO,
						DCF.DCF_SERIE,
						DCR.DCR_IDDCF,
						DCF.DCF_SEQUEN
				FROM %Table:DCR% DCR
				INNER JOIN %Table:DCF% DCF
				ON DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCF.DCF_SEQUEN = DCR.DCR_SEQUEN
				AND DCF.DCF_ID = DCR.DCR_IDDCF
				AND DCF.%NotDel%
				WHERE DCR.DCR_FILIAL = %xFilial:DCR%
				AND DCR.DCR_IDORI = %Exp:Self:oOrdServ:GetIdDCF()%
				AND DCR.DCR_IDMOV = %Exp:Self:GetIdMovto()%
				AND DCR.DCR_IDOPER = %Exp:Self:GetIdOpera()%
				AND DCR.%NotDel%
			EndSql
			Do While lRet .And. (cAliasDCF)->(!Eof())
				// Busca os documentos e retorna a quantidade que poder� ser liberada
				cAliasTRP := GetNextAlias()
				BeginSql Alias cAliasTRP
					SELECT MIN((CASE WHEN TRP.DCR_QUANT IS NULL THEN 0 ELSE TRP.DCR_QUANT END )/ D11.D11_QTMULT) DCR_QUANT
					FROM %Table:D11% D11
					LEFT JOIN (SELECT SUM(DCR.DCR_QUANT) DCR_QUANT,
										D12.D12_PRODUT,
										D12.D12_PRDORI
								FROM %Table:DCR% DCR, %Table:D12% D12
								WHERE DCR.DCR_FILIAL = %xFilial:DCR%
								AND DCR.DCR_IDDCF  = %Exp:(cAliasDCF)->DCR_IDDCF%
								AND DCR.DCR_SEQUEN = %Exp:(cAliasDCF)->DCF_SEQUEN%
								AND DCR.%NotDel%
								AND D12.D12_FILIAL = %xFilial:D12%
								AND D12.D12_IDDCF = DCR.DCR_IDORI
								AND D12.D12_IDMOV = DCR.DCR_IDMOV
								AND D12.D12_IDOPER = DCR.DCR_IDOPER
								AND D12.D12_LOTECT = %Exp:Self:oMovPrdLot:GetLoteCtl()%
								AND D12.D12_NUMLOT = %Exp:Self:oMovPrdLot:GetNumLote()%
								AND D12.D12_ATUEST = '1'
								AND (D12.D12_STATUS = '1'
									OR (D12.D12_STATUS = '3'
									AND D12.D12_IDMOV = %Exp:Self:GetIdMovto()%
									AND D12.D12_IDOPER = %Exp:Self:GetIdOpera()% ))
								AND D12.%NotDel%
								GROUP BY D12.D12_PRODUT,
											D12.D12_PRDORI) TRP
					ON D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRDORI = TRP.D12_PRDORI
					AND D11.D11_PRDCMP = TRP.D12_PRODUT
					AND D11.%NotDel%
					WHERE D11.D11_FILIAL = %xFilial:D11%
					AND D11.D11_PRDORI = %Exp:Self:oMovPrdLot:GetPrdOri()%
					AND D11.%NotDel%
				EndSql
				aTamSX3 := TamSx3("D14_QTDEST");TcSetField(cAliasTRP,'DCR_QUANT','N',aTamSx3[1],aTamSx3[2])
				Do While lRet .And. (cAliasTRP)->(!Eof()) .And. QtdComp(Int((cAliasTRP)->DCR_QUANT)) > 0
					// Atribui a quantidade multipla separada
					nQuant := Int((cAliasTRP)->DCR_QUANT)
					oSaldoADis:SetIdDCF((cAliasDCF)->DCR_IDDCF)
					If oSaldoADis:LoadData(3)
						oSaldoADis:SetQtdSld(oSaldoADis:GetQtdOri() -nQuant)
						If QtdComp(oSaldoADis:GetSaldo()) > 0
							lRet := oSaldoADis:UpdateD0G()
						Else
							lRet := oSaldoADis:DeleteD0G()
						EndIf
					EndIf
					(cAliasTRP)->(dbSkip())
				EndDo
				(cAliasTRP)->(dbCloseArea())
				(cAliasDCF)->(dbSkip())
			EndDo
			(cAliasDCF)->(dbCloseArea())
		EndIf
	EndIf
	If !lRet
		Self:cErro := oSaldoADis:GetErro()
	EndIf
Return lRet

METHOD AllMovPend() CLASS WMSBCCMovimentoServico
Local lRet      := .T.
Local cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT 1
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_IDDCF = %Exp:Self:GetIdDCF()%
		AND D12.D12_IDMOV = %Exp:Self:GetIdMovto()%
		AND D12.D12_STATUS IN ('1','3')
		AND D12.%NotDel%
	EndSql
	If (cAliasD12)->(!Eof())
		lRet := .F.
	EndIf
Return lRet	
