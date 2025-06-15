#Include "Totvs.ch"
#Include "WMSDTCOrdemServicoDelete.ch"
#Define CLRF  CHR(13)+CHR(10)
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0031
Fun��o para permitir que a classe seja visualizada
no inspetor de objetos
@author Inova��o WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0031()
Return Nil
//-------------------------------------------------
/*/{Protheus.doc} WMSDTCOrdemServicoDelete
Classe Exclus�o ordem de servi�o
@author Inova��o WMS
@since 16/12/2016
@version 1.0
/*/
//-------------------------------------------------
CLASS WMSDTCOrdemServicoDelete FROM WMSDTCOrdemServico
	DATA lEstPed
	DATA lWmsPergEP
	// Method
	METHOD New() CONSTRUCTOR
	METHOD SetQtdDel(nQtdDel)
	METHOD CanDelete()
	METHOD DeleteDCF()
	METHOD DelDCFUni(cCodRec)
	METHOD CanCancel(nQtdEst)
	METHOD CanExclude(nQtdEst)
	METHOD Destroy()
	METHOD SetHasEst(lEstPed)
ENDCLASS
//-------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD New() CLASS WMSDTCOrdemServicoDelete
	_Super:New()
	Self:lEstPed    := .F.
	Self:lWmsPergEP := .F.
Return

METHOD Destroy() CLASS WMSDTCOrdemServicoDelete
	//Mantido para compatibilidade
Return

//-------------------------------------------------
/*/{Protheus.doc} SetQtdDel
M�todo construtor
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD SetQtdDel(nQtdDel) CLASS WMSDTCOrdemServicoDelete
	If QtdComp(nQtdDel) > QtdComp(Self:nQuant) .Or. QtdComp(nQtdDel) <= QtdComp(0)
		Self:nQtdDel := Self:nQuant
	Else
		Self:nQtdDel := nQtdDel
	EndIf
Return

METHOD SetHasEst(lEstPed) CLASS WMSDTCOrdemServicoDelete
	Self:lEstPed := lEstPed
Return

//-------------------------------------------------
/*/{Protheus.doc} CanDelete
Verifica se pode deletar
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD CanDelete() CLASS WMSDTCOrdemServicoDelete
Local lRet := .T.
	If (Self:cStServ == "3")
		// Verifica se a ordem de servi�o possui servi�o com execu��o autom�tica
		If Self:oServico:GetTpExec() == "2"
			// Verifica se alguma das atividades est� em andamento ou finalizada pelo WMS
			If Self:HaveMovD12('1')
				Self:cErro := STR0002+CLRF // Existem atividades em andamento ou finalizadas para esta
				Self:cErro += STR0003+CLRF // ordem de servi�o pelo processo WMS.
				Self:cErro += STR0004 // Dever� ser estornado o processo WMS manualmente.
				lRet := .F.
			EndIf
		Else
			Self:cErro := STR0005+CLRF // A ordem de servi�o j� foi executada pelo processo WMS.
			Self:cErro += STR0006 // Dever� ser estornado o processo WMS manualmente.
			lRet := .F.
		EndIf
	EndIf
	// Verifica se n�o � reabastecimento e se h� dcf dependente que n�o esteja concluida.
	If lRet
		If !Self:oServico:HasOperac({'5'})
			If Self:ChkDepPend() // Caso servi�o tenha opera��o de reabastecimento
				lRet := .F.
			EndIf
		Else
			// Dever� validar se a quantidade em estoque + entrada prevista � maior ou igual
			// a saida prevista para permitir o estorno do reabastecimento.
			lRet := Self:CanEstReab()
		EndIf
	EndIf
	If !lRet
		AADD(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CLRF +Self:GetErro()) //"SIGAWMS - OS [VAR01] - Produto: [VAR02]"
	EndIf
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} DeleteDCF
Deleta a ordem de servi�o
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD DeleteDCF() CLASS WMSDTCOrdemServicoDelete
Local lRet       := .T.
Local oOrdSerAux := Nil
	// Verifica se o servi�o j� foi executado
	If Self:cStServ == "3"
		oOrdSerAux := WMSDTCOrdemServicoReverse():New()
		oOrdSerAux:GotoDCF(Self:GetRecno())
		If oOrdSerAux:CanReverse()
			If !oOrdSerAux:ReverseDCF()
				Self:cErro := oOrdSerAux:GetErro()
				lRet := .F.
			EndIf
		Else
			Self:cErro := oOrdSerAux:GetErro()
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If !(lRet := Self:UndoIntegr())
			Self:cErro := STR0007 // N�o foi poss�vel desfazer a integra��o da ordem de servi�o!
		EndIf
	EndIf
	If lRet
		If Self:ChkOrdDep()
			If !(lRet := Self:CancelDCF())
				Self:cErro := STR0008 // N�o foi poss�vel cancelar a ordem de servi�o!
			EndIf
		Else
			If !(lRet := Self:ExcludeDCF())
				Self:cErro := STR0009 // N�o foi poss�vel excluir a ordem de servi�o!
			EndIf
		EndIf
	EndIf
Return lRet

METHOD CanCancel(nQtdEst) CLASS WMSDTCOrdemServicoDelete
Local aAreaAnt := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
Local lRet     := .T.

	//-- Verifica se o pedido gera OS na carga, caso contr�rio n�o considera a carga
	If !Empty(Self:GetCarga())
		SC5->(DbSetOrder(1))
		If SC5->(MsSeek(xFilial("SC5")+Self:GetDocto())) .And. SC5->C5_GERAWMS == "1"
			Self:SetCarga("") //Limpa a carga, pois a OS foi gerada no pedido
		EndIf
	EndIf
	//Somente valida se tiver a informa��o de DCF na tabela
	If Self:GetStServ() == '3'
		//Deve checar se para esta ordem de servi�o j� existe algo faturado
		//Pois caso exista, deve deixar estornar parcial este item da SC9
		//Por�m, ainda assim n�o poder� haver nenhuma atividade pendente
		//Se j� tem algo faturado, deve checar se tudo desta OS est� finalizado
		//Se o pedido j� est� liberado pelo WMS, libera o mesmo para estorno
		If !Empty(SC9->C9_NFISCAL)
			If !Self:HaveMovD12("3")
				Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:GetDocto())+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),"")},{"[VAR02]",AllTrim(Self:oProdLote:GetProduto())}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
				Self:cErro += STR0014 + CLRF //"Existem atividades em andamento ou pendentes para esta"
				Self:cErro += STR0015 + CLRF //"ordem de servi�o pelo processo WMS."
				Self:cErro += STR0016 //"Dever� ser finalizado o processo WMS primeiro."
				lRet := .F.
			Else
				//Apaga o campo servi�o e IDDCF deste item da SC9, para n�o estornar a OS
				RecLock('SC9',.F.)
				SC9->C9_IDDCF  := ""
				SC9->C9_STSERV := ""
				SC9->C9_SERVIC := ""
				MsUnlock()
			EndIf
		Else
			If !Self:CanExclude(nQtdEst)
				lRet := .F.
			EndIf
		EndIf
	ElseIf Self:ChkDepPend()
		lRet := .F.
	EndIf
	RestArea(aAreaSC9)
	RestArea(aAreaSC5)
	RestArea(aAreaAnt)
Return lRet

METHOD CanExclude(nQtdEst) CLASS WMSDTCOrdemServicoDelete
Local aAreaAnt    := GetArea()
Local lRet        := .T.
Local nWmsVlEP    := SuperGetMV("MV_WMSVLEP",.F.,1)   // Tratamento da OS WMS no estorno da libera��o do pedido
Local cLoteCtl    := SC9->C9_LOTECTL
Local cNumLote    := SC9->C9_NUMLOTE
Local cItem       := SC9->C9_ITEM
Local cSequen     := SC9->C9_SEQUEN
Local nQtdLib     := SC9->C9_QTDLIB
Local oVolItens   := Nil
Local oConfExpOpe := Nil
Local oDisSepItem := Nil

	If Type('lWmsPergEP')=='L'
		Self:lWmsPergEP := lWmsPergEP
	EndIf
	If Type("lEstPedDAK")=='L'
		Self:lEstPed    := lEstPedDAK
	EndIf

	// Valida se existe volume DCV
	oVolItens := WMSDTCVolumeItens():New()
	oVolItens:SetPedido(Self:GetDocto())
	oVolItens:SetItem(cItem)
	oVolItens:SetSequen(cSequen)
	oVolItens:SetPrdOri(Self:oProdLote:GetPrdOri())
	If oVolItens:LoadData(5)
		lRet := .F.
		If (nQtdLib - oVolItens:GetQtSeqLib()) >= nQtdEst
			lRet := .T.
		EndIf
		If !lRet
			Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:GetDocto())+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),"")},{"[VAR02]",AllTrim(Self:oProdLote:GetProduto())}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
			Self:cErro += STR0017 + CRLF // "Existem volumes montados para esta libera��o de pedido."
			Self:cErro += STR0018 // "Os volumes dever�o ser estornados manualmente."
		EndIf
	EndIf
	
	If lRet
		// Valida se existe conferencia de expedi��o D04
		oConfExpOpe := WMSDTCConferenciaExpedicaoConferidoOperador():New()
		oConfExpOpe:SetPedido(Self:GetDocto())
		oConfExpOpe:SetItem(cItem)
		oConfExpOpe:SetSequen(cSequen)
		oConfExpOpe:SetPrdOri(Self:oProdLote:GetPrdOri())
		If oConfExpOpe:LoadData(3)
			lRet :=  .F.
			If (nQtdLib - oConfExpOpe:GetQtSeqLib()) >= nQtdEst
				lRet := .T.
			EndIf
			If !lRet
				Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:GetDocto())+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),"")},{"[VAR02]",AllTrim(Self:oProdLote:GetProduto())}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
				Self:cErro += STR0019 + CRLF // "Existe confer�ncia de expedi��o para esta libera��o de pedido."
				Self:cErro += STR0020 // "A confer�ncia dever� ser estornada manualmente."
			EndIf
		EndIf
	EndIf
	
	If lRet
		// Valida se existe distribui��o de separa��o D0E
		oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
		oDisSepItem:SetCarga(Self:GetCarga())
		oDisSepItem:SetPedido(Self:GetDocto())
		oDisSepItem:oDisPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
		oDisSepItem:oDisPrdLot:SetProduto(Self:oProdLote:GetPrdOri())
		oDisSepItem:SetLoteCtl(cLoteCtl)
		oDisSepItem:SetNumLote(cNumLote)
		If oDisSepItem:LoadData(3)
			lRet := .F.
			// Calcula se a quantidade estornada � o suficiente para continuar
			If oDisSepItem:oDisPrdLot:oProduto:oProdComp:IsDad()
				// Calcula com a quantidade m�xima dos componente para saber se o produto pai foi totalmente estornado
				If (oDisSepItem:oDisSep:GetQtdSep() - oDisSepItem:GetQtMxPai()) >= nQtdEst
					lRet := .T.
				EndIf
			Else
				If (oDisSepItem:oDisSep:GetQtdSep() - oDisSepItem:oDisSep:GetQtdDis()) >= nQtdEst
					lRet := .T.
				EndIf
			EndIf
			
			If !lRet
				Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:GetDocto())+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),"")},{"[VAR02]",AllTrim(Self:oProdLote:GetProduto())}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
				Self:cErro += STR0021 + CRLF // "Existe distribui��o de separa��o para esta libera��o de pedido."
				Self:cErro += STR0022 // "A distribui��o dever� ser estornada manualmente."
			EndIf
		EndIf
	EndIf

	If lRet
		If !(Self:GetStServ() $ "1|2")
			// Assume valor padr�o caso o par�metro tenha sido preenchido de forma inconsistente
			If nWmsVlEP < 1 .Or. nWmsVlEP > 3
				nWmsVlEP := 1
			EndIf
			// Se n�o estiver sendo chamado da rotina de gera��o das notas fiscais de sa�da
			If (IsInCallStack("Mata460a") .Or. (IsInCallStack("WmsAvalDAK") .And. Self:lEstPed)) .And. nWmsVlEP <> 1
				// Verifica se alguma das atividades est� em andamento pelo WMS
				If Self:HaveMovD12("5")
					Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:GetDocto())+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),"")},{"[VAR02]",AllTrim(Self:oProdLote:GetProduto())}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
					Self:cErro += STR0023 + CRLF // "Existem atividades em andamento para esta ordem de servi�o."
					Self:cErro += STR0024 // "Finalize as atividades ou estorne o processo WMS manualmente."
					lRet := .F.
				Else
					// STR0019
					// Confirma o estorno da libera��o do pedido sem estornar o processo WMS manualmente?
					// Em caso positivo, a ordem de servi�o WMS ser� cancelada e o saldo dos produtos ser�
					// mantido na doca sem empenho, aguardando a sua utiliza��o por outro pedido.
					If nWmsVlEP == 2 .Or. (nWmsVlEP == 3 .And. (!Self:lWmsPergEP .Or. WmsMessage(STR0025,"CanExclude",3))) // "Confirma o estorno da libera��o do pedido sem estornar o processo WMS manualmente? Em caso positivo, a ordem de servi�o WMS ser� cancelada e o saldo dos produtos ser� mantido na doca sem empenho, aguardando a sua utiliza��o por outro pedido."
						Self:lWmsPergEP := .F. // Pegunta apenas uma vez
					Else
						lRet := .F.
					EndIf
				EndIf
			Else
				//Verifica se a ordem de servi�o possui servi�o com execu��o autom�tica
				If Self:oServico:GetTpExec() == "2"
					//Verifica se alguma das atividades est� em andamento ou finalizada pelo WMS
					If Self:HaveMovD12("1")
						Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:GetDocto())+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),"")},{"[VAR02]",AllTrim(Self:oProdLote:GetProduto())}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
						Self:cErro += STR0026 + CLRF // Existem atividades em andamento ou finalizadas para esta
						Self:cErro += STR0015 + CLRF // "ordem de servi�o pelo processo WMS."
						Self:cErro += STR0027 // "Dever� ser estornado o processo WMS manualmente."
						lRet := .F.
					EndIf
				Else
					Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",AllTrim(Self:GetDocto())+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),"")},{"[VAR02]",AllTrim(Self:oProdLote:GetProduto())}}) + CLRF // "SIGAWMS - OS [VAR01] - Produto: [VAR02]"
					Self:cErro += STR0028 + CLRF // A ordem de servi�o j� foi executada pelo processo WMS.
					Self:cErro += STR0027 // "Dever� ser estornado o processo WMS manualmente."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD DelDCFUni(cCodRec) CLASS WMSDTCOrdemServicoDelete
Local lRet      := .T.
Local aAreaDCF  := DCF->(GetArea())
Local aAreaD0R  := D0R->(GetArea())
Local cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.R_E_C_N_O_ RECNODCF,
				D0R.R_E_C_N_O_ RECNOD0R
		FROM %Table:DCF% DCF
		INNER JOIN %Table:D0R% D0R
		ON D0R.D0R_FILIAL = %xFilial:D0R%
		AND D0R.D0R_IDUNIT = DCF.DCF_UNITIZ
		AND D0R.%NotDel%
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_CODREC = %Exp:cCodRec%
		AND DCF.DCF_ORIGEM = 'D0R'
		AND DCF.%NotDel%
	EndSql
	Do While lRet .And. (cAliasQry)->(!Eof())
		//Apaga IDDCF da D0R
		If !Empty((cAliasQry)->RECNOD0R)
			D0R->(DbGoTo((cAliasQry)->RECNOD0R))
			RecLock('D0R', .F.)
			D0R->D0R_IDDCF := ""
			D0R->D0R_STATUS:= "6" //Aguardando Classifica��o NF
			D0R->(MsUnlock())
		EndIf
		//Apaga ordem de servi�o
		DCF->(DbGoTo((cAliasQry)->RECNODCF))
		RecLock('DCF', .F.)
		DCF->(DbDelete())
		DCF->(MsUnlock())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaDCF)
	RestArea(aAreaD0R)
Return lRet
