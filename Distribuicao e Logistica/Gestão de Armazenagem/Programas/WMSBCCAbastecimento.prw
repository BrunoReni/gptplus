#Include "Totvs.ch"
#Include "WMSBCCAbastecimento.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0001
Fun��o para permitir que a classe seja visualizada
no inspetor de objetos
@author Inova��o WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0001()
Return Nil

Static lWMSQTDAB := ExistBlock("WMSQTDAB")
Static lWMSQYABA := ExistBlock("WMSQYABA")
Static lWMSQYABC := ExistBlock("WMSQYABC")

//---------------------------------------------
/*/{Protheus.doc} WMSBCCAbastecimento
Classe regra de neg�cio Abastecimento
@author Inova��o WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCAbastecimento FROM WMSDTCMovimentosServicoArmazem

	// Declaracao das propriedades da Classe
	DATA oMovSepOri
	DATA oEstFis
	DATA nQuantOS   // Quantidade de rebastecimento para ser gerado a OS
	DATA nQtdNorPkg
	DATA nQtdNorPul
	DATA cTipRepPkg
	DATA xRegra
	DATA cTipReab   // D-Demanda, A-Automatico, M-Manual
	DATA lMultReab
	DATA lHasPkMas
	DATA aGerReab AS ARRAY
	// Declara��o dos M�todos da Classe
	METHOD New() CONSTRUCTOR
	METHOD SetTipReab(cTipReab)
	METHOD SetOrdServ(oOrdServ)
	METHOD SetMovSepOri(oMovSepOri)
	METHOD ExecFuncao()
	METHOD VldGeracao()
	METHOD CriaDCFAbt()
	METHOD ProcEstAbt()
	METHOD ProcEndAbt()
	METHOD QryEstEnd(lNormaInt)
	METHOD RetQtdMul(nQtdAbast,nQtdSaldo)
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSBCCAbastecimento
	_Super:New()
	Self:oMovSepOri := Nil
	Self:oEstFis    := WMSDTCEstruturaFisica():New()
	Self:nQuantOS   := 0
	Self:nQtdNorPkg := 0
	Self:nQtdNorPul := 0
	Self:cTipRepPkg := "1"
	Self:xRegra     := CtoD("")
	Self:cTipReab   := "M"
	// Gera m�ltiplos movimentos de reabastecimento
	Self:lMultReab := (SuperGetMV("MV_WMSMABP", .F., "N")=="S")
	Self:lHasPkMas := .F.
	Self:aGerReab:= {}
Return

METHOD Destroy() CLASS WMSBCCAbastecimento
	//Mantido para compatibilidade
Return 

METHOD SetTipReab(cTipReab) CLASS WMSBCCAbastecimento
Return Self:cTipReab := cTipReab

METHOD SetOrdServ(oOrdServ) CLASS WMSBCCAbastecimento
	Self:oMovSepOri := Nil
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico
	// Carrega dados endere�o origem
	Self:oMovEndOri:SetArmazem(Self:oOrdServ:oOrdEndOri:GetArmazem())
	Self:oMovEndOri:SetEnder(Self:oOrdServ:oOrdEndOri:GetEnder())
	Self:oMovEndOri:LoadData()
	Self:oMovEndOri:ExceptEnd()
	// Carrega dados endere�o destino
	Self:oMovEndDes:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
	Self:oMovEndDes:SetEnder(Self:oOrdServ:oOrdEndDes:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()

	If oOrdServ:GetRegra() == "1"
		Self:xRegra := Self:oMovPrdLot:GetLoteCtl()
	ElseIf Self:oOrdServ:GetRegra() == "2"
		Self:xRegra := Space(TamSx3("D14_NUMSER")[1]) // Numero de Serie
	ElseIf Self:oOrdServ:GetRegra() $ "3|4"
		// Caso n�o controle rastro atribui para xRegra = Data em branco
		Self:xRegra := CtoD("")
	Else
		// Quando n�o possue regra atribui 4 e caso n�o controle rastro atribui para xRegra = Data em branco
		If Self:oMovPrdLot:HasRastro()
			Self:oOrdServ:SetRegra("4")
		Else
			Self:oOrdServ:SetRegra("3")
		EndIf
		Self:xRegra := CtoD("")
	EndIf
	Self:aGerReab := {}
Return

METHOD SetMovSepOri(oMovSepOri,lMultCmp) CLASS WMSBCCAbastecimento
Default lMultCmp := .F.

	Self:oMovSepOri := oMovSepOri
	// Atribui ordem de servi�o origem
	Self:oOrdServ:SetIdOrig(oMovSepOri:GetIdDCF())
	Self:oOrdServ:oOrdEndOri:SetArmazem(oMovSepOri:oMovEndOri:GetArmazem())
	// Atribui endereco destino
	Self:oOrdServ:oOrdEndDes:SetArmazem(oMovSepOri:oMovEndOri:GetArmazem())
	Self:oOrdServ:oOrdEndDes:SetEnder(oMovSepOri:oMovEndOri:GetEnder())
	Self:oOrdServ:oOrdEndDes:LoadData()
	// Atribui as informa��es de produto/lote para o movimento de abastecimento
	Self:oMovPrdLot:SetArmazem(oMovSepOri:oMovPrdLot:GetArmazem())
	Self:oMovPrdLot:SetPrdOri(oMovSepOri:oMovPrdLot:GetPrdOri())
	Self:oMovPrdLot:SetProduto(oMovSepOri:oMovPrdLot:GetProduto())
	//
	Self:oOrdServ:oProdLote:SetArmazem(oMovSepOri:oMovPrdLot:GetArmazem())
	Self:oOrdServ:oProdLote:SetPrdOri(oMovSepOri:oMovPrdLot:GetPrdOri())
	Self:oOrdServ:oProdLote:SetProduto(oMovSepOri:oMovPrdLot:GetProduto())
	// Atribui as informa��es de lote e sub-lote da ordem de servi�o de origem
	Self:oMovPrdLot:SetLoteCtl(IIf(lMultCmp,oMovSepOri:oMovPrdLot:GetLoteCtl(),""))
	Self:oMovPrdLot:SetNumLote(IIf(lMultCmp,oMovSepOri:oMovPrdLot:GetNumLote(),""))
	Self:oMovPrdLot:SetNumSer(oMovSepOri:oMovPrdLot:GetNumSer())
	Self:oMovPrdLot:LoadData()
	// Atribui lote e sub-lote
	Self:oOrdServ:oProdLote:SetLoteCtl(IIf(lMultCmp,oMovSepOri:oMovPrdLot:GetLoteCtl(),oMovSepOri:oOrdServ:oProdLote:GetLoteCtl()))
	Self:oOrdServ:oProdLote:SetNumLote(IIf(lMultCmp,oMovSepOri:oMovPrdLot:GetNumLote(),oMovSepOri:oOrdServ:oProdLote:GetNumLote()))
	Self:oOrdServ:oProdLote:SetNumSer(IIf(lMultCmp,oMovSepOri:oMovPrdLot:GetNumSer(),oMovSepOri:oOrdServ:oProdLote:GetNumSer()))
	// Atribui a mesma regra da ordem de servi�o de origem
	If oMovSepOri:oOrdServ:GetRegra() == "3" .And. oMovSepOri:oMovPrdLot:HasRastro() 
		Self:oOrdServ:SetRegra("4")
	EndIf
	// Atribui o mesmo array de libera��o dos movimentos da separa��o
	Self:oOrdServ:SetArrLib(oMovSepOri:oOrdServ:GetArrLib())
	Self:aRecD12 := oMovSepOri:aRecD12
	// Atribui endereco destino
	Self:oMovEndDes:SetArmazem(oMovSepOri:oMovEndOri:GetArmazem())
	Self:oMovEndDes:SetEnder(oMovSepOri:oMovEndOri:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()
	// Atribui endereco origem
	// Por hora o WMS n�o permite separar em um armaz�m e descarregar em outro,
	// assume o mesmo do destino
	Self:oMovEndOri:SetArmazem(oMovSepOri:oMovEndOri:GetArmazem())
	Self:cTipReab := "D" //Demanda
	Self:aGerReab := {}
Return

METHOD VldGeracao() CLASS WMSBCCAbastecimento
Local aAreaAnt := GetArea()
Local lRet     := .T.
	// Carrega o servi�o de reabastecimento cadastrado na sequencia de abastecimento
	Self:oMovSeqAbt:SetArmazem(Self:oMovEndDes:GetArmazem())
	Self:oMovSeqAbt:SetProduto(Self:oMovPrdLot:GetProduto())
	Self:oMovSeqAbt:SetServico(Self:oMovServic:GetServico())
	Self:oMovSeqAbt:SetEstFis(Self:oMovEndDes:GetEstFis())
	If Self:oMovSeqAbt:LoadData(2)// DC3_FILIAL+DC3_CODPRO+DC3_LOCAL+DC3_TPESTR
		Self:cTipRepPkg := IIf(Empty(Self:oMovSeqAbt:GetTipoRep()),"1",Self:oMovSeqAbt:GetTipoRep())
		If Empty(Self:oMovServic:GetServico()) .And. !Empty(Self:oMovSeqAbt:GetSerAbas())
			Self:oMovServic:SetServico(Self:oMovSeqAbt:GetSerAbas())
			Self:oMovServic:LoadData()
			If !(Self:oMovServic:ChkReabast())
				Self:oMovServic:SetServico('')
				Self:cErro := WmsFmtMsg(STR0004,{{"[VAR01]",Self:oMovPrdLot:GetProduto()}}) // "N�o foi poss�vel determinar o servi�o de reabastecimento para o produto [VAR01]." 
				lRet := .F.
			EndIf
		EndIf
	Else
		Self:cErro := WmsFmtMsg(STR0001,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndDes:GetArmazem()},{"[VAR03]",Self:oMovEndDes:GetEstFis()}}) // Produto/Armaz�m [VAR01]/[VAR02] n�o possui sequencia de abastecimento para a estrutura [VAR03] (PICKING).
		lRet := .F.
	EndIf
	If lRet
		// Determinando a norma do endere�o de pickimg
		Self:nQtdNorPkg := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndDes:GetArmazem(),Self:oMovEndDes:GetEstFis(),/*cDesUni*/,.F.,Self:oMovEndDes:GetEnder())
		// Se n�o encontrou uma sequencia de abastecimento de PICKING para o item
		If Self:nQtdNorPkg == 0
			Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",Self:oMovPrdLot:GetProduto()}}) // O produto [PRODUTO] n�o possui norma cadastrada para estrutura do tipo PICKING.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		// Verifica se endere�o de picking possue estruturas de picking com quantidade m�nima de apanhe maior
		// Para permitir reabastecer de picking master
		Self:lHasPkMas := Self:oMovSeqAbt:HasPickMas()
	EndIf
	// Busca servico de reabastecimento
	If lRet .And. Empty(Self:oMovServic:GetServico())
		Self:oMovServic:SetServico(Self:oMovServic:FindReabas())
		If Empty(Self:oMovServic:GetServico())
			Self:cErro := Self:oMovServic:GetErro()
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. !Empty(Self:oMovServic:GetServico())
		Self:oMovServic:LoadData()
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD ExecFuncao() CLASS WMSBCCAbastecimento
Local lRet      := .T.
	// Seta as informa��es da sequencia de abastecimento
	Self:oMovSeqAbt:SetArmazem(Self:oMovPrdLot:GetArmazem())
	Self:oMovSeqAbt:SetProduto(Self:oMovPrdLot:GetProduto())

	If (lRet := Self:VldGeracao())
		lRet := Self:ProcEstAbt()
	EndIf
Return lRet

// Cria uma ordem de servi�o para reabastecimento
METHOD CriaDCFAbt() CLASS WMSBCCAbastecimento
local lRet := .T.
Local oOrdServ := WMSDTCOrdemServicoCreate():New()
	// Cria nova ordem de servi�o para a quantidade estornada devolvendo para o endere�o origem
	oOrdServ:SetOrigem("DCF")
	oOrdServ:oProdLote:SetArmazem(Self:oOrdServ:oProdLote:GetArmazem())
	oOrdServ:oProdLote:SetPrdOri(Self:oOrdServ:oProdLote:GetPrdOri())
	oOrdServ:oProdLote:SetProduto(Self:oOrdServ:oProdLote:GetProduto())
	oOrdServ:oProdLote:SetLoteCtl(Self:oOrdServ:oProdLote:GetLoteCtl())
	oOrdServ:oProdLote:SetNumLote(Self:oOrdServ:oProdLote:GetNumLote())
	oOrdServ:oProdLote:SetNumSer(Self:oOrdServ:oProdLote:GetNumSer())
	oOrdServ:oProdLote:LoadData()
	// Servi�o
	oOrdServ:oServico:SetServico(Self:oOrdServ:oServico:GetServico())
	oOrdServ:oServico:LoadData()
	// Endere�o origem
	oOrdServ:oOrdEndOri:SetArmazem(Self:oMovEndOri:GetArmazem())
	// Endere�o destino
	oOrdServ:oOrdEndDes:SetArmazem(Self:oMovEndDes:GetArmazem())
	oOrdServ:oOrdEndDes:SetEnder(Self:oMovEndDes:GetEnder())
	oOrdServ:oOrdEndDes:LoadData()
	// Demais campos
	oOrdServ:SetRegra(Self:oOrdServ:GetRegra())
	oOrdServ:SetQtdOri(Self:oOrdServ:GetQuant())
	oOrdServ:SetIdOrig(Self:oOrdServ:GetIdOrig())
	If !oOrdServ:AssignDCF()
		Self:cErro := oOrdServ:GetErro()
		lRet := .F.
	Else
		// Carrega dados da ordem de servi�o para execu��o
		Self:oOrdServ:cDocumento := oOrdServ:cDocumento
		Self:oOrdServ:cSerieDoc  := oOrdServ:cSerieDoc
		Self:oOrdServ:cSerie     := oOrdServ:cSerie
		Self:oOrdServ:cCliFor    := oOrdServ:cCliFor
		Self:oOrdServ:cLoja      := oOrdServ:cLoja
		Self:oOrdServ:cOrigem    := oOrdServ:cOrigem
		Self:oOrdServ:cNumSeq    := oOrdServ:cNumSeq
		Self:oOrdServ:nQtdOri    := oOrdServ:nQtdOri
		Self:oOrdServ:nQuant     := oOrdServ:nQuant
		Self:oOrdServ:nQuant2    := oOrdServ:nQuant2
		Self:oOrdServ:dData      := oOrdServ:dData
		Self:oOrdServ:cStServ    := oOrdServ:cStServ
		Self:oOrdServ:cRegra     := oOrdServ:cRegra
		Self:oOrdServ:cPriori    := oOrdServ:cPriori
		Self:oOrdServ:cCodFun    := oOrdServ:cCodFun
		Self:oOrdServ:cCarga     := oOrdServ:cCarga
		Self:oOrdServ:cIdUnitiz  := oOrdServ:cIdUnitiz
		Self:oOrdServ:cCodNorma  := oOrdServ:cCodNorma
		Self:oOrdServ:cStRadi    := oOrdServ:cStRadi
		Self:oOrdServ:cIdDCF     := oOrdServ:cIdDCF
		Self:oOrdServ:cSequen    := oOrdServ:cSequen
		Self:oOrdServ:cIdOrigem  := oOrdServ:cIdOrigem
		Self:oOrdServ:cOk        := oOrdServ:cOk
		Self:oOrdServ:nRecno     := oOrdServ:nRecno
	EndIf
Return lRet

// Processa estoque para reabastecimento
METHOD ProcEstAbt() CLASS WMSBCCAbastecimento
Local lRet       := .T.
Local aSeqAbast  := {}
Local nSeqAbast  := 0
Local cTipoEst   := ""
Local nCont      := 0

	If lRet
		// Carrega sequencias de abastecimento
		Self:oMovSeqAbt:SeqAbast(4)
		aSeqAbast := Self:oMovSeqAbt:GetArrSeqA()
		nSeqAbast := Len(aSeqAbast)
		If nSeqAbast <= 0
			Self:cErro += WmsFmtMsg(STR0003,{{"[VAR01]",Self:oMovPrdLot:GetProduto()},{"[VAR02]",Self:oMovEndDes:GetArmazem()}}) // Produto/Armaz�m [VAR01]/[VAR02] n�o possui sequ�ncia de abastecimento cadastrada (DC3).
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If Self:oOrdServ:GetRegra() == "4"
			// Como busca por data de validade, pode misturar as sequencias de abastecimento
			// Neste caso utiliza como base a pr�pria norma do picking para busca de saldo
			Self:nQtdNorPul := Self:nQtdNorPkg
			// Busca sem considerar a ordem da sequencia de abastecimento
			lRet := Self:ProcEndAbt()
		Else
			// Realiza o apanhe dos produtos at� que a quantidade seja zero
			Do While lRet .And. nSeqAbast > 0 .And. QtdComp(Self:nQuant) > QtdComp(0)
			    nCont++ 
			    // Busca dados Sequencia abastecimento
				Self:oMovSeqAbt:SetOrdem(aSeqAbast[nCont][1])
				Self:oMovSeqAbt:LoadData()
				// Busca dados Estrutura Fisica
				Self:oEstFis:SetEstFis(Self:oMovSeqAbt:GetEstFis())
				Self:oEstFis:LoadData()
				// Somente estrturas do tipo pulm�o devem ser processadas
				// Quando regra for por data de validade busca a menor data de validade dentro do mesmo tipo de estrutura
				If (Self:oOrdServ:GetRegra() == "3" .And. Self:oMovPrdLot:HasRastro()) .And. cTipoEst != Self:oEstFis:GetTipoEst()
					Exit
				EndIf
				// Atribui tipo estrutura
				cTipoEst := Self:oEstFis:GetTipoEst()
				// Atribui estrutura fisica endere�o origem
				Self:oMovEndOri:SetEstFis(Self:oMovSeqAbt:GetEstFis())
				// Determinando a quantidade da norma do pulm�o
				Self:nQtdNorPul := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndOri:GetArmazem(),Self:oEstFis:GetEstFis(),/*cDesUni*/,.F.)
				//S� retorna .F. se n�o achar saldo e se for a �ltima sequ�ncia de Pulm�o
				//Serve para casos com v�rias estrutura da Pulm�o cadastrada na sequ�ncia de abastecimento.
				lRet := Self:ProcEndAbt() .OR. nCont < Len(aSeqAbast)
				nSeqAbast--
			EndDo
		EndIf
	EndIf

	// Deve atualizar a quantidade na ordem de servi�o gerada
	If lRet .And. !Empty(Self:oOrdServ:GetIdDCF()) .And. QtdComp(Self:nQuantOS) > QtdComp(0)
		Self:oOrdServ:SetStServ("3")
		Self:oOrdServ:SetQtdOri(Self:nQuantOS)
		Self:oOrdServ:SetQuant(Self:nQuantOS)
		If !(lRet := Self:oOrdServ:UpdateDCF())
			Self:cErro := Self:oOrdServ:GetErro()
		EndIf
	EndIf

Return lRet

// Processa endere�os para reabastecimento
METHOD ProcEndAbt() CLASS WMSBCCAbastecimento
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cAliasD14 := ""
Local nQtdAbast := 0
Local nQtdAbasPE:= 0
Local lNormaInt := .F.
Local lRegraOK  := .T.
Local lFoundD14 := .F.

	// Se a quantidade a reabastecer no PICKING � menor que a norma do PULMAO vai tentar buscar no
	// armazem endere�os que estejam com a quantidade menor que a norma do endere�o, palete incompleto
	lNormaInt := Iif((QtdComp(Self:nQuant) >= QtdComp(Self:nQtdNorPul)),.T.,.F.)
	// Permite substituir a busca de saldo padr�o
	If lWMSQYABA
		cAliasD14 := ExecBlock("WMSQYABA",.F.,.F.,{Self:oMovEndOri:GetArmazem(),Self:oMovEndOri:GetEnder(),Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote()})
		cAliasD14 := Iif(ValType(cAliasD14)=="C",cAliasD14,"")
	EndIf
	If Empty(cAliasD14)
		//Realiza query para buscar os endere�os com saldo
		cAliasD14 := Self:QryEstEnd(lNormaInt)
	EndIf
	While (cAliasD14)->(!Eof())
		// Se for por data de validade, n�o carregou previamente a estrutura fisica
		If Self:oOrdServ:GetRegra() == "4" .And. (cAliasD14)->D14_ESTFIS != Self:oEstFis:GetEstFis()
			// Carrega as informa��es da estrutura fisica
			Self:oEstFis:SetEstFis((cAliasD14)->D14_ESTFIS)
			Self:oEstFis:LoadData()
			Self:oMovEndOri:SetEstFis((cAliasD14)->D14_ESTFIS)
			// Carrega as informa��es da sequencia de abastecimento
			Self:oMovSeqAbt:SetOrdem((cAliasD14)->DC3_ORDEM)
			Self:oMovSeqAbt:LoadData()
		EndIf

		// Desconsidera SBE n�o encontrado - falha de integridade
		Self:oMovEndOri:SetEnder((cAliasD14)->D14_ENDER)
		Self:SetIdUnit((cAliasD14)->D14_IDUNIT)
		If !Self:oMovEndOri:LoadData()
			// Gravar LOG -- "Endere�o n�o cadastradado. (SBE)"
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Desconsidera endere�os bloqueados
		If Self:oMovEndOri:GetStatus() == "3"
			// Gravar LOG -- "Endere�o bloqueado. (SBE)"
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Desconsidera endere�os com bloqueio de sa�da
		If Self:oMovEndOri:GetStatus() == "5"
			// Gravar LOG -- "Endere�o com bloqueio de sa�da. (SBE)"
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Desconsidera endere�os com bloqueio de invent�rio
		If Self:oMovEndOri:GetStatus() == "6"
			// Gravar LOG -- "Endere�o com bloqueio de invent�rio. (SBE)"
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Descontar do saldo os movimentos de RF pendentes
		If QtdComp((cAliasD14)->D14_SALDO) <= QtdComp(0)
			// Gravar LOG -- "Saldo utilizado para outros movimentos."
			(cAliasD14)->(DbSkip())
			Loop
		EndIf

		lRegraOK := .F.
		If Empty(Self:oOrdServ:GetRegra())
			lRegraOK := .T.
		ElseIf Self:oOrdServ:GetRegra() == "1"
			lRegraOK := Iif(!Empty(Self:xRegra),(cAliasD14)->D14_LOTECT==Self:xRegra,.T.)
		ElseIf Self:oOrdServ:GetRegra() == "2"
			lRegraOK := Iif(!Empty(Self:xRegra),(cAliasD14)->D14_NUMSER==Self:xRegra,.T.)
		ElseIf Self:oOrdServ:GetRegra() == "3" .Or. Self:oOrdServ:GetRegra() == "4"
			lRegraOK := Iif(!Empty(Self:xRegra),(cAliasD14)->D14_DTVALD>=Self:xRegra,.T.)
		EndIf
		If !lRegraOK
			// Gravar LOG -- Regra WMS impede utiliza��o saldo.
			(cAliasD14)->(DbSkip())
			Loop
		EndIf

		// Determina a quantidade a ser apanhada no endere�o
		If Self:cTipRepPkg == "1" // Baixa a norma (Palete) completo
			// Se o solicitado for menor que uma norma, for�a a baixa uma norma completa ou o saldo do endere�o
			If QtdComp(Self:nQuant) < QtdComp(Self:nQtdNorPul)
				nQtdAbast := Min((cAliasD14)->D14_SALDO,Self:nQtdNorPul)
			Else
				nQtdAbast := Min((cAliasD14)->D14_SALDO,Self:nQuant)
			EndIf
		Else
			nQtdAbast := Min((cAliasD14)->D14_SALDO,Self:nQuant)
		EndIf
		//-- Valida se a quantidade � multipla da 2aUM do produto
		nQtdAbast := Self:RetQtdMul(nQtdAbast,(cAliasD14)->D14_SALDO)
		If QtdComp(nQtdAbast) <= QtdComp(0)
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		//-- PE possibilita a redefinicao da quantidade a ser utilizada nos reabastecimentos.
		If lWMSQTDAB
			nQtdAbasPE := ExecBlock("WMSQTDAB",.F.,.F.,{Self:oMovPrdLot:GetProduto(),; // Produto 
														Self:oMovEndDes:GetArmazem(),; // Armaz�m destino
														Self:oMovEndDes:GetEstFis(),;  // Estrutura f�sica destino
														Self:oMovEndDes:GetEnder(),;   // Endere�o destino
														Self:oMovEndOri:GetArmazem(),; // Armaz�m origem
														Self:oMovEndOri:GetEstFis(),;  // Estrutura f�sica origem
														Self:oMovEndOri:GetEnder(),;   // Endere�o origem
														nQtdAbast,;                    // Quantidade abastecer
														(cAliasD14)->D14_LOTECT,;      // Lote
														(cAliasD14)->D14_NUMLOT,;      // Sublote
														(cAliasD14)->D14_NUMSER,;      // N�mero de s�rie
														(cAliasD14)->D14_IDUNIT})      // Unitizador
			nQtdAbast  := If(ValType(nQtdAbasPE)=="N",nQtdAbasPE,nQtdAbast)
		EndIf
		If QtdComp(nQtdAbast) <= QtdComp(0)
			(cAliasD14)->(DbSkip())
			// Gravar LOG -- "Endere�o descartado pelo PE DLENDAP."
			Loop
		EndIf
		// Nesse ponto considera-se o saldo est� dispon�vel
		lFoundD14 := .T.
		// Carregando as informa��es do movimento
		Self:oMovPrdLot:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote
		Self:oMovPrdLot:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote
		Self:oMovPrdLot:SetNumSer((cAliasD14)->D14_NUMSER)  // Numero de serie
		// Verifica se permite misturar produtos e/ou lotes para reabastecimento autom�ticos ou manuais
		// Valida se endere�o destino informado.
		If lRet .And. !Self:ChkEndDes(,,Self:cTipReab)
			lRet := .F.
		EndIf
		// Verifica se a Atividade utiliza Radio Frequencia
		// Carregas as exce��es das atividades na origem
		If lRet
			Self:oMovEndOri:ExceptEnd()
			// Se a ordem de servi�o ainda n�o foi criada, cria a DCF
			If Empty(Self:oOrdServ:GetIdDCF())
				Self:oOrdServ:SetQuant(nQtdAbast)
				// Se gerou a ordem de servi�o, deve carregar ela para a ordem de servi�o do reabastecimento
				If !Self:CriaDCFAbt()
					lRet := .F.
				EndIf
			Else
				// Caso contr�rio, s� aumente a quantidade na DCF j� criada
				Self:oOrdServ:SetQuant(Self:oOrdServ:GetQuant() + nQtdAbast)
				Self:oOrdServ:UpdateDCF()
			EndIf
		EndIf
		// Enquanto for maior que zero, vai separando a quantidade de uma norma ou o restante
		Do While lRet .And. QtdComp(nQtdAbast) > QtdComp(0)
			// Status movimento
			Self:cStatus := IIf(Self:oMovServic:GetBlqSrv() == "1","2","4")
			Self:nQtdMovto := Min(nQtdAbast,Self:nQtdNorPul)
			nQtdAbast     -= Self:nQtdMovto
			Self:nQuant   -= Self:nQtdMovto
			Self:nQuantOS += Self:nQtdMovto
			// Atualiza estoque por endere�o
			lRet := Self:MakeOutput()
			If lRet .And. !Self:MakeInput()
				lRet := .F.
			EndIf
			// Gera movimentos WMS
			If lRet .And. !Self:AssignD12()
				lRet := .F.
			EndIf
			// Grava as informa��es do reabastecimento gerado
			If Self:cAtuEst == '1'
				AAdd(Self:aGerReab, {(cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_NUMLOT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQtdMovto})
			EndIf
			// Se n�o gera multiplos reabastecimentos, sai ao gerar o primeiro
			If lRet .And. !Self:lMultReab
				Exit
			EndIf
		EndDo
		// Se houve algum erro sai do processo
		If !lRet
			Exit
		EndIf

		If lWMSQYABC
			ExecBlock("WMSQYABC",.F.,.F.,{Self:oMovPrdLot:GetPrdOri(),;
										  Self:oMovPrdLot:GetProduto(),;
										  Self:oMovPrdLot:GetLoteCtl(),;
										  Self:oMovPrdLot:GetNumLote(),;
										  Self:oMovEndOri:GetArmazem(),;
										  Self:oMovEndOri:GetEnder(),;
										  (cAliasD14)->D14_IDUNIT,;
										  Self:nQtdMovto,;
										  Self:oOrdServ:GetIdDCF(),;
										  Self:oOrdServ:GetDocto(),;
										  Self:oOrdServ:IsMovUnit()})
		EndIf

		// Se n�o gera multiplos reabastecimentos, sai ao gerar o primeiro
		If !Self:lMultReab
			Exit
		EndIf

		// Conseguiu atender toda a quantidade solicitada
		If QtdComp(Self:nQuant) <= QtdComp(0)
			Exit
		EndIf
		(cAliasD14)->(DbSkip())
	EndDo
	(cAliasD14)->(DbCloseArea())
	If !lFoundD14 .And. Self:cTipReab <> "D"
		Self:cErro := STR0005 //N�o h� saldo dispon�vel para o reabastecimento!
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD QryEstEnd(lNormaInt) CLASS WMSBCCAbastecimento
Local cQuery    := ""
Local cAliasD14 := GetNextAlias()
Local aTamSX3   := TamSx3("D14_QTDEST")
Local cOrdemDC3 := Replicate('0', TamSx3("DC3_ORDEM")[1])
Local lConsVenc := (SuperGetMV('MV_LOTVENC', .F., 'N')=='S')
Local lWmsTrBl  := .F.

	If ExistBlock("WMSQYABA")
		lWmsTrBl := ExecBlock("WMSQYABA",.F.,.F.,{})
	EndIf

	cQuery :=         "SELECT "+Iif((Self:oOrdServ:GetRegra() == '4'),"DC3.DC3_ORDEM",("'"+cOrdemDC3+"' DC3_ORDEM"))+","
	cQuery +=               " D14_ENDER,"
	cQuery +=               " D14_ESTFIS,"
	cQuery +=               " D14_LOTECT,"
	cQuery +=               " D14_NUMLOT,"
	cQuery +=               " D14_DTVALD,"
	cQuery +=               " D14_NUMSER,"
	cQuery +=               " D14_PRIOR,"
	cQuery +=               " D14_IDUNIT,"
	If lWmsTrBl
		cQuery +=               " (D14_QTDEST-(D14_QTDEMP)) D14_QTDLIB,"
	Else
		cQuery +=               " (D14_QTDEST-(D14_QTDEMP+D14_QTDBLQ)) D14_QTDLIB,"
	EndIf
	cQuery +=               " D14_QTDSPR,"
	If lWmsTrBl
		cQuery +=               " (D14_QTDEST-(D14_QTDEMP+D14_QTDSPR)) D14_SALDO, D14_QTDEST "
	Else
		cQuery +=               " (D14_QTDEST-(D14_QTDEMP+D14_QTDBLQ+D14_QTDSPR)) D14_SALDO"
	EndIf
	cQuery +=          " FROM "+RetSqlName("D14")+" D14"
	// Quando separa por data de validade n�o segue a sequencia de abastecimento
	If Self:oOrdServ:GetRegra() == "4"
		cQuery +=     " INNER JOIN "+RetSqlName("DC3")+" DC3"
		cQuery +=        " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
		cQuery +=       " AND DC3.DC3_LOCAL = D14.D14_LOCAL"
		cQuery +=       " AND DC3.DC3_CODPRO = D14.D14_PRODUT"
		cQuery +=       " AND DC3.DC3_TPESTR = D14.D14_ESTFIS"
		cQuery +=       " AND DC3.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=         " INNER JOIN "+RetSqlName("DC8")+" DC8"
	cQuery +=            " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=           " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
	If Self:lHasPkMas
		cQuery +=       " AND DC8.DC8_TPESTR IN ('1','2')" // Somente estrutura pulmao e picking
	Else
		cQuery +=       " AND DC8.DC8_TPESTR = '1'" // Somente estrutura pulmao
	EndIf
	cQuery +=           " AND DC8.D_E_L_E_T_ = ' '"
	cQuery +=         " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=           " AND D14_LOCAL  = '"+Self:oMovEndOri:GetArmazem()+"'"
	cQuery +=           " AND D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery +=           " AND D14_PRDORI = '"+Self:oMovPrdLot:GetPrdOri()+"'"
	If Self:oMovPrdLot:HasRastro()
		If !Empty(Self:oMovPrdLot:GetLoteCtl())
			cQuery +=   " AND D14_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
		EndIf
		If !Empty(Self:oMovPrdLot:GetNumLote())
			cQuery +=   " AND D14_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
		EndIf
	EndIf
	// Quando separa por data de validade n�o segue a sequencia de abastecimento
	// Quando regra default por Data, busca os endere�os do mesmo tipo de estrutura
	If Self:oOrdServ:GetRegra() != "4" .And. !(Self:oOrdServ:GetRegra() == "3" .And. Self:oMovPrdLot:HasRastro())
		cQuery +=       " AND D14_ESTFIS = '"+Self:oEstFis:GetEstFis()+"'"
	EndIf
	If lWmsTrBl
		cQuery +=           " AND (D14_QTDEST-(D14_QTDEMP)) > 0"
	Else
		cQuery +=           " AND (D14_QTDEST-(D14_QTDEMP+D14_QTDBLQ)) > 0"
	EndIf
	// Valida se controla rastro e n�o aceita lotes vencidos
	If Self:oMovPrdLot:HasRastro() .And. !lConsVenc
		cQuery +=       " AND D14_DTVALD >= '"+DTOS(dDataBase)+"'"
	EndIf
	cQuery +=           " AND (D14.D14_LOCAL <> '"+Self:oMovEndDes:GetArmazem()+"'"
	cQuery +=               " OR D14.D14_ENDER <> '"+Self:oMovEndDes:GetEnder()+"')"
	cQuery +=           " AND D14.D_E_L_E_T_ = ' '"
	// Ordena��o de acordo com as regras de sa�da da ordem de servi�o
	If Self:oOrdServ:GetRegra() == "4"
		cQuery +=     " ORDER BY D14_DTVALD,D14_DTFABR,D14_PRIOR,D14_SALDO "+If(lNormaInt,"DESC","ASC")+",D14_LOTECT,D14_NUMLOT,D14_IDUNIT,D14_ENDER"
	Else
		If Self:oOrdServ:GetRegra() == "1" // Lote
			cQuery += " ORDER BY D14_PRIOR,D14_LOTECT,D14_NUMLOT,D14_SALDO "+If(lNormaInt,"DESC","ASC")+",D14_IDUNIT,D14_ENDER"
		ElseIf Self:oOrdServ:GetRegra() == "2" // Numero de Serie
			cQuery += " ORDER BY D14_PRIOR,D14_NUMSER,D14_SALDO "+If(lNormaInt,"DESC","ASC")+",D14_IDUNIT,D14_ENDER"
		Else  // Data (Default)
			cQuery += " ORDER BY D14_PRIOR,D14_DTVALD,D14_DTFABR,D14_LOTECT,D14_NUMLOT,D14_SALDO "+If(lNormaInt,"DESC","ASC")+",D14_IDUNIT,D14_ENDER"
		EndIf
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
	// Ajustando o tamanho dos campos da query
	TcSetField(cAliasD14,'D14_QTDLIB','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_SALDO','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_DTVALD','D')
Return cAliasD14

//--------------------------------------------------
/*/{Protheus.doc} RetQtdMul
Retorna a quantidade m�ltipla com base na segunda unidade de medida do produto
Caso a quantidade solicitada seja menor que um multiplo, retorna sempre uma unidade a mais
Exemplo: Caixa com 10 unidades, solicitou reabastecer 15 unidades, se tiver saldo 
deve levar 2 caixas, ou seja 20 unidades para reabastecer deste unico endere�o.

@author jackson.werka
@since 03/05/2018
@version 1.0
/*/
//--------------------------------------------------
METHOD RetQtdMul(nQtdAbast,nQtdSaldo) CLASS WMSBCCAbastecimento
Local nQtdMul  := nQtdAbast
Local nFatConv := 0

	If Self:oMovPrdLot:GetConv() != 0 .And. Self:oMovSeqAbt:GetUMMovto() == "2" .And. !Self:oMovSeqAbt:HasMinSep()
		If Self:oMovPrdLot:GetTipConv() == "D"
			nFatConv := Self:oMovPrdLot:GetConv()
		EndIf
	Else
		nFatConv := Self:oMovSeqAbt:GetQtMinSp()
	EndIf

	If nFatConv > 0
		// Somente se n�o for multiplo do fator de convers�o
		If Mod(nQtdAbast,nFatConv) > 0
			// Se o saldo for maior que o multiplo + 1, arredonda pra cima
			If QtdComp((NoRound(nQtdAbast / nFatConv, 0) + 1) * nFatConv) <= QtdComp(nQtdSaldo)
				nQtdMul := (NoRound(nQtdAbast / nFatConv, 0) + 1) * nFatConv
			Else
				nQtdMul := NoRound(nQtdAbast / nFatConv, 0) * nFatConv
			EndIf
		EndIf
	EndIf
Return nQtdMul
