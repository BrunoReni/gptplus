#INCLUDE 'WMSV074.CH'  
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#DEFINE CRLF CHR(13)+CHR(10) 

#DEFINE WMSV07401 "WMSV07401"
#DEFINE WMSV07402 "WMSV07402"
#DEFINE WMSV07404 "WMSV07404"
#DEFINE WMSV07405 "WMSV07405"
#DEFINE WMSV07406 "WMSV07406"
#DEFINE WMSV07407 "WMSV07407"
#DEFINE WMSV07408 "WMSV07408"
#DEFINE WMSV07409 "WMSV07409"
#DEFINE WMSV07410 "WMSV07410"
#DEFINE WMSV07411 "WMSV07411"
#DEFINE WMSV07412 "WMSV07412"
#DEFINE WMSV07413 "WMSV07413"
#DEFINE WMSV07414 "WMSV07414"
#DEFINE WMSV07415 "WMSV07415"
#DEFINE WMSV07416 "WMSV07416"
#DEFINE WMSV07417 "WMSV07417"
#DEFINE WMSV07418 "WMSV07418"
#DEFINE WMSV07419 "WMSV07419"
#DEFINE WMSV07420 "WMSV07420"
#DEFINE WMSV07421 "WMSV07421"
#DEFINE WMSV07422 "WMSV07422"
#DEFINE WMSV07423 "WMSV07423"
#DEFINE WMSV07424 "WMSV07424"
#DEFINE WMSV07425 "WMSV07425"
#DEFINE WMSV07426 "WMSV07426"
//------------------------------------------------------------
/*/{Protheus.doc} WMSV074
Conferencia de mercadorias entrada
@author Jackson Patrick Werka
@since 01/04/2015
@version 1.0
/*/
//------------------------------------------------------------
Static cServico   := ""
Static cOrdTar    := ""
Static cTarefa    := ""
Static cAtividade := ""
Static cArmazem   := ""
Static cEndereco  := ""
Static cDocto     := ""
Static cSerie     := ""
Static dDataIni   := CTOD("")
Static cHoraIni   := ""
Static lWmsDaEn   := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Confer�ncia apenas considerando o endere�o sem o armaz�m
Static lWV074GCO  := ExistBlock("WV074GCO")

Function WMSV074()
Local aAreaAnt    := GetArea()
Local lRet        := .T.
// Salva todas as teclas de atalho anteriores
Local aSavKey     := VTKeys()
Local lAbandona   := .F.
	cServico   := oMovimento:oMovServic:GetServico()
	cOrdTar    := oMovimento:oMovServic:GetOrdem()
	cTarefa    := oMovimento:oMovTarefa:GetTarefa()
	cAtividade := oMovimento:oMovTarefa:GetAtivid()
	cArmazem   := oMovimento:oMovEndOri:GetArmazem()
	cEndereco  := Space(TamSx3("D12_ENDORI")[1])
	dDataIni   := oMovimento:GetDataIni()
	cHoraIni   := oMovimento:GetHoraIni()
	Do While lRet .And. !lAbandona
		// Indica ao operador o endereco de origem da conferencia
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Confer�ncia
		WMSEnder(0,0,oMovimento:oMovEndOri:GetEnder(),oMovimento:oMovEndOri:GetArmazem(),,,STR0002) // Va para o Endereco
		If (VTLastKey()==27)
			WMSV074ESC(@lAbandona)
			Loop
		EndIf
		Exit
	EndDo
	Do While lRet .And. !lAbandona
		WMSVTCabec(STR0001,.F.,.F.,.T.) //Confer�ncia
		If oMovimento:lUsuArm .Or. !lWmsDaEn
			@ 01, 00 VTSay Padr(STR0046+cArmazem,VTMaxCol()) //Armazem: 
		EndIf
		@ 02, 00 VTSay PadR(STR0003,VTMaxCol()) // Endereco
		@ 03, 00 VTSay PadR(oMovimento:oMovEndOri:GetEnder(),VTMaxCol())
		@ 05, 00 VTSay PadR(STR0004, VTMaxCol()) // Confirme!
		@ 06, 00 VTGet cEndereco Pict '@!' Valid ValidEnder(@cEndereco)
		VTRead()
		If (VTLastKey()==27)
			WMSV074ESC(@lAbandona)
			Loop
		EndIf
		Exit
	EndDo
	Do While lRet .And. !lAbandona
		// Confirmar Documento / S�rie
		cDocto := Space(TamSX3("D12_DOC")[1])
		cSerie := Space(TamSX3("D12_SERIE")[1])
		WMSVTCabec(STR0001,.F.,.F.,.T.) //
		@ 01, 00 VTSay PadR(STR0005,VTMaxCol()) //"Documento / Serie"
		@ 02, 00 VTSay PadR(oMovimento:oOrdServ:GetDocto()+' / '+oMovimento:oOrdServ:GetSerie(),VTMaxCol())
		@ 04, 00 VTSay PadR(STR0004, VTMaxCol()) //"Confirme !"	   
		@ 05, 00 VTGet cDocto Picture '@!' Valid ValidDocto()
		@ 05, 10 VTSay '/'
		@ 05, 12 VTGet cSerie Picture '@!' Valid ValidSerie()
		VTRead()
		If (VTLastKey()==27)
			WMSV074ESC(@lAbandona)
			Loop
		EndIf
		// Efetua as valida��es para a Documento/S�rie informado
		If !ValidDocSer()
			Loop
		EndIf
		Exit
	EndDo
	If lRet .And. !lAbandona
		lRet := CofPrdLot()
		WMSAltSts(.F.) // N�o altera a situa��o da atividade no WMSV0001
	EndIf
	VTClear()
	VTKeyBoard(chr(13))
	VTInkey(0)
	// Restaura as teclas de atalho anteriores
	VTKeys(aSavKey)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---CofPrdLot
---Permite ir executando a confer�ncia dos produtos, informando os dados
---de lote, sub-lote e quantidade a ser conferida
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function CofPrdLot()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aTelaUMI  := {}
Local aGets     := {}
Local oEndereco := WMSDTCEndereco():New()
// Solicita a confirmacao do lote nas operacoes com radio frequencia
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.T.)
Local lWMSConf  := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local lEncerra  := .F.
Local lAbandona := .F.
Local lQtdBar   := .F.
Local cWmsUMI   := ""
Local cCodBar   := ""
Local cProduto  := ""
Local cPrdAnt   := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local nQtConf   := 0
Local cPictQt   := ""
Local cUM       := ""
Local cDscUM    := ""
Local nItem     := 0
Local nAviso    := 0
Local nQtdNorma := 0
Local nQtde1UM  := 0
Local nQtde2UM  := 0
Local nGet      := 0
Local nLin      := 0
Local nQtdTot   := 0

	If  ExistBlock("WV074TEP")//Permite incluir um novo atalho no coletor ao informar o produto
		Execblock("WV074TEP",.F.,.F.,)
	EndIf
	// Atribui a funcao de JA CONFERIDOS a combinacao de teclas <CTRL> + <Q>
	VTSetKey(17,{||ShowPrdCof()},STR0006) // Ja Conferidos
	Do While !lEncerra .And. !lAbandona
		cProduto := Space(TamSx3("D12_PRODUT")[1])
		cNumLote := Space(TamSx3("D12_NUMLOT")[1])
		cCodBar  := Space(128)
		nQtdConf := 0
		// 01234567890123456789
		// 0 ____Confer�ncia_____
		// 1 Documento: 000000       // Serie: 000000
		// 2 Informe o Produto
		// 3 PA1
		// 4 Informe o Lote
		// 5 AUTO000636
		// 6 Qtde 999.00 UM
		// 7               240.00
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Confer�ncia
		@ 01,00 VtSay AllTrim(cDocto)+"/"+AllTrim(cSerie)
		@ 02,00 VTSay STR0009 // Informe o Produto
		@ 03,00 VtGet cCodBar Picture "@!" Valid ValidPrdLot(@cProduto,@cLoteCtl,@cNumLote,@nQtConf,@cCodBar)
		// Descricao do Produto com tamanho especifico.
		VtRead()
		If VTLastKey()==27
			nAviso := WMSVTAviso(STR0001,STR0010,{STR0011,STR0012}) // Deseja encerrar a conferencia? // Encerrar // Interromper
			If nAviso == 1
				lEncerra := .T.
			ElseIf nAviso == 2
				lAbandona  := .T.
			Else
				Loop
			EndIf
		EndIf
		// Indica que quantidade j� atribu�da
		lQtdBar := (nQtConf > 0)
		If lQtdBar
			cPrdAnt := Space(TamSx3("D12_PRODUT")[1])
		EndIf
		If !lEncerra .And. !lAbandona
			// Forca selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
			If ((cProduto <> cPrdAnt) .Or. lWMSConf )
				// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
				WmsValUM(Nil,;     // Quantidade movimento
						@cWmsUMI,; // Unidade parametrizada
						cProduto,; // Produto
						cArmazem,; // Armazem
						cEndereco,;// Endere�o
						@nItem,;   // Item unidade medida
						.T.,;      // Indica se � uma confer�ncia
						lQtdBar)   // Indica que quantidade j� preenchida
				
				DbSelectArea('DC5') //inclu�do para evitar erro na fun��o Tabela por falta de alias posicionado
				// Monta tela produto
				WmsMontPrd( cWmsUMI,;                 // Unidade parametrizada
							.T.,;                     // Indica se � uma confer�ncia
							Tabela("L2",cTarefa,.F.),;// Descri��o da tarefa
							cArmazem,;                // Armazem
							cEndereco,;               // Endere�o
							cProduto,;                // Produto Origem
							cProduto,;                // Produto
							cLoteCtl,;                // Lote
							cNumLote,;                // sub-lote
							Nil,;                     // Id Unitizador
							nQtConf)                  // Quantidade preenchida
				If (VTLastKey()==27)
					Loop
				EndIf

				DbSelectArea('DC5') //inclu�do para evitar erro na fun��o Tabela por falta de alias posicionado
				If (QtdComp(nQtConf) <= QtdComp(0))
					// Seleciona unidade de medida
					WmsSelUM(cWmsUMI,;                  // Unidade parametrizada
							@cUM,;                      // Unidade medida reduzida
							@cDscUM,;                   // Descri��o unidade medida
							Nil,;                       // Quantidade movimento
							@nItem,;                    // Item sele��o unidade
							@cPictQt,;                  // Mascara unidade medida
							Nil,;                       // Quantidade no item sele��o unidade
							.T.,;                       // Indica se � uma confer�ncia
							Tabela("L2",cTarefa,.F.),;  // Descri��o da tarefa
							cArmazem,;                  // Armazem
							cEndereco,;                 // Endere�o 
							cProduto,;                  // Produto Origem
							cProduto,;                  // Produto
							cLoteCtl,;                  // Lote
							cNumLote,;                  // sub-lote
							lQtdBar)                    // Indica que quantidade j� preenchida
					// Esc
					If (VTLastKey()==27)
						Loop
					EndIf
				EndIf
			EndIf
			cPrdAnt := cProduto
		EndIf
		nLin := 4
		If !lEncerra .And. !lAbandona .And. lWmsLote
			If Empty(cLoteCtl)
				// Se tiver espa�o na tela suficiente ele mostra o sub-lote na mesma tela
				If VTMaxRow() >= 10
					If Rastro(cProduto) .And. !Empty(oMovimento:oMovPrdLot:GetLoteCtl())
						@ nLin++,00  VtSay STR0013 // Informe o Lote
						@ nLin++,00  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValLoteCtl(cProduto,cLoteCtl)
					EndIf
					If Rastro(cProduto,"S") .And. !Empty(oMovimento:oMovPrdLot:GetNumLote())
						@ nLin++,00 VTSay STR0014 // Informe o Sub-Lote
						@ nLin++,00 VTGet cNumLote Picture "@!" When VTLastKey()==05 .Or. Empty(cNumLote) Valid ValSubLote(cProduto,cLoteCtl,cNumLote)
					EndIf
					VtRead()
					If VTLastKey()==27
						Loop // Volta para o inicio do produto
					EndIf
				Else
					nGet := 1
					aGets := {}
					If Rastro(cProduto) .And. !Empty(oMovimento:oMovPrdLot:GetLoteCtl())
						AAdd(aGets,{STR0013,cLoteCtl,{||ValLoteCtl(cProduto,aGets[nGet,2])}})//  Informe o Lote
					EndIf
					If Rastro(cProduto,"S") .And. !Empty(oMovimento:oMovPrdLot:GetNumLote())
						AAdd(aGets,{STR0014,cNumLote,{||ValSubLote(cProduto,cLoteCtl,aGets[nGet,2])}}) // Informe o Sub-Lote
					EndIf
					// Aqui ele faz um loop para pegar as informa��es de rastro
					Do While nGet <= Len(aGets)
						If Len(aGets) > 0
							@ nLin,  00  VtSay Padr(aGets[nGet,1],VTMaxCol())
							@ nLin+1,00  VtSay Space(VTMaxCol()) // Apaga a linha, caso haja algo nela
							@ nLin+1,00  VtGet aGets[nGet,2] Picture "@!" When VTLastKey()==05 .Or. Empty(aGets[nGet,2]) Valid Eval(aGets[nGet,3])
						EndIf
						VtRead()
	
						If VTLastKey()==27
							Exit // Volta para o inicio do produto
						EndIf
						If nGet == 1
							cLoteCtl := aGets[nGet,2]
						ElseIf nGet == 2
							cNumLote := aGets[nGet,2]
						EndIf
						nGet++
					EndDo

					If VTLastKey()==27
						Loop //  Volta para o inicio do produto
					EndIf
					nLin += Iif(Len(aGets) > 0,2,0)
				EndIf
			EndIf
			// Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
			If !(Iif(Empty(cLoteCtl),.T.,ValLoteCtl(cProduto,cLoteCtl))) .Or. ;
				!(Iif(Empty(cNumLote),.T.,ValSubLote(cProduto,cLoteCtl,cNumLote)))
				Loop // Volta para o inicio do produto
			EndIf
			//Altera status da movimenta��o
			UpdStatus(cProduto,cLoteCtl,cNumLote)
		EndIf
		If !lEncerra .And. !lAbandona
			//Carrega informa��es do endere�o da confer�ncia
			oEndereco:SetArmazem(cArmazem)
			oEndereco:SetEnder(cEndereco)
			oEndereco:LoadData()
			nQtdNorma := DLQtdNorma(cProduto,cArmazem,oEndereco:GetEstFis(),,.F.)
			// Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
			Do While .T.
				@ nLin++,00 VTSay PadR(STR0015+' '+cDscUM,VTMaxCol()) //Qtde
				@ nLin++,00 VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid !Empty(nQtConf)
				VTRead()
				If VTLastKey()==27
					Exit // Volta para o inicio do produto
				EndIf
				If !ValidQtd(cProduto,cLoteCtl,cNumLote,nQtConf,nItem,nQtdNorma,@nQtde1UM,@nQtde2UM)
					nQtConf := 0
					If !lQtdBar
						nLin -= 2
						Loop
					EndIf
				EndIf
				Exit
			EndDo
			If VTLastKey()==27
				Loop
			EndIf
		EndIf
		// Somente grava a quantidade se o usu�rio n�o cancelar
		If !lEncerra .And. !lAbandona .And. QtdComp(nQtConf) > 0
			VTMsg(STR0016) // Processando...
			GravCofOpe(cProduto,cLoteCtl,cNumLote,nQtde1UM)
		EndIf
		// Se o usu�rio optou por encerrar, deve verificar se pode ser finalizado a confer�ncia
		If lEncerra .Or. lAbandona
			// Se o usu�rio optou por interromper, deve verificar se pode sair da confer�ncia
			// Caso n�o haja mais nada para ser executado, n�o ser� poss�vel efetuar
			// a libera��o da expedi��o para o faturamento
			If lAbandona
				lAbandona := SaiCofEnd()
				lEncerra := !lAbandona
			EndIf
			If lEncerra
				lEncerra:= FinCofEnt()
			EndIf
		EndIf
	EndDo
	If ExistBlock("WV074TEF")//Para que seja poss�vel remover a tecla de fun��o criada no Ponto de Entrada WV074TEP.
		ExecBlock("WV074TEF",.F.,.F.)
	EndIf
	// Restaura tela anterior
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ShowPrdCof
---Exibe os produtos e quantidade conferida para cada um deles
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ShowPrdCof()
Local lWmsLote   := SuperGetMV('MV_WMSLOTE',.F.,.T.)
Local aAreaAnt   := GetArea()
Local aProduto   := {}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aHeaders   := {}
Local aSizes     := {}
Local cAliasQry  := GetNextAlias()
Local cWhere     := ""
	// Se n�o informa o lote no coletor, ele n�o mostra na Query
	// Se n�o informa lote ele agrupa por produto apenas
	cWhere := "%"
	If oMovimento:lUsuArm .Or. !lWmsDaEn
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	If lWmsLote
		BeginSql Alias cAliasQry
			SELECT D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_QTDMOV,
					D12.D12_QTDLID
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_DOC = %Exp:cDocto%
			AND D12.D12_SERIE  = %Exp:cSerie%	
			AND D12.D12_STATUS IN ('3','4','1')
			AND D12.D12_RECHUM = %Exp:__cUserID%
			AND D12.D12_ENDDES  = %Exp:cEndereco%
			AND D12.%NotDel%
			%Exp:cWhere%
			ORDER BY D12.D12_PRODUT,
						D12.D12_LOTECT,
						D12.D12_NUMLOT
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT D12.D12_PRODUT,
					SUM(D12.D12_QTDMOV) D12_QTDMOV,
					SUM(D12.D12_QTDLID) D12_QTDLID
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_DOC = %Exp:cDocto%
			AND D12.D12_SERIE = %Exp:cSerie%	
			AND D12.D12_STATUS IN ('3','4','1')
			AND D12.D12_RECHUM = %Exp:__cUserID%
			AND D12.D12_ENDDES = %Exp:cEndereco%
			AND D12.%NotDel%
			GROUP BY D12.D12_PRODUT
			ORDER BY D12.D12_PRODUT
		EndSql
	EndIf
	TCSetField(cAliasQry,'D12_QTDMOV' ,'N',TamSx3('D12_QTDMOV')[1], TamSx3('D12_QTDMOV')[2])
	TCSetField(cAliasQry,'D12_QTDLID','N',TamSx3('D12_QTDLID')[1],TamSx3('D12_QTDLID')[2])
	Do While (cAliasQry)->(!Eof())
		If lWmsLote
			AAdd(aProduto,{Iif((cAliasQry)->D12_QTDMOV <> (cAliasQry)->D12_QTDLID,'*',' '),(cAliasQry)->D12_PRODUT,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->D12_PRODUT,'SB1->B1_DESC'),(cAliasQry)->D12_LOTECTL,(cAliasQry)->D12_NUMLOT,(cAliasQry)->D12_QTDLID})
		Else
			AAdd(aProduto,{Iif((cAliasQry)->D12_QTDMOV <> (cAliasQry)->D12_QTDLID,'*',' '),(cAliasQry)->D12_PRODUT,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->D12_PRODUT,'SB1->B1_DESC'),(cAliasQry)->D12_QTDLID})
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)

	If lWmsLote
		aHeaders := {' ',RetTitle("D12_PRODUT"),RetTitle("B1_DESC"),RetTitle("D12_LOTECT"),RetTitle("D12_NUMLOT"),STR0043} //Produto|Descri��o|Lote|Sub-Lote|Qtde Conferida
		aSizes   := {1,TamSx3("D12_PRODUT")[1],30,TamSx3("D12_LOTECT")[1],TamSx3("D12_NUMLOT")[1],11}
	Else
		aHeaders := {' ',RetTitle("D12_PRODUT"),RetTitle("B1_DESC"),STR0044} // Produto|Descri��o|Qtde Conferida
		aSizes   := {1,TamSx3("D12_PRODUT")[1],30,11}
	EndIf
	VtClearBuffer()
	WMSVTCabec(STR0017,.F.,.F.,.T.) // Produto
	VTaBrowse(1,,,,aHeaders,aProduto,aSizes)
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil
/*--------------------------------------------------------------------------------
---ValidDocto
---Valida a informa��o da documento informado, trocando operador se for o caso
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
//-----------------------------------------------------------------------------
// Valida a informa��o do campo Documento
//-----------------------------------------------------------------------------
Static Function ValidDocto()
Local lRet     := .T.
	// Se n�o informou o documento retorna
	If Empty(cDocto)
		Return .F.
	EndIf
	// Se o documento informado � o mesmo convocado
	If cDocto == oMovimento:oOrdServ:GetDocto()
		Return .T.
	EndIf
	// Se o documento � diferente, deve validar se existe este documento
	cDocto := PadR(cDocto,TamSX3("F1_DOC")[1])
	If !ExistDocSer(cDocto)
		WMSVTAviso(WMSV07415,STR0018) // Documento inv�lido!
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValidSerie
---Valida a informa��o da documento/serie informado, trocando operador se for o caso
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ValidSerie()
Local lRet     := .T.
	//Se a s�rie informada � a mesma convocada
	If cDocto == oMovimento:oOrdServ:GetDocto() .And. cSerie == oMovimento:oOrdServ:GetSerie()
		Return .T.
	EndIf
	//Se a s�rie � diferente, deve validar se existe este documento + s�rie
	cSerie := PadR(cSerie,TamSX3("F1_SERIE")[1])
	If !ExistDocSer(cDocto,cSerie)
		WMSVTAviso(WMSV07407,STR0019) // S�rie inv�lida!
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValidDocSer
---Valida a informa��o da documento/serie informado, trocando operador se for o caso
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ValidDocSer()
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local lTrocouDoc := .F.
Local lRet       := .T.
Local nRecnoD12  := 0
	// Se o operador informou outro documento tira a reserva feita pelo WMSV001
	If cDocto <> oMovimento:oOrdServ:GetDocto() .Or. ;
		cSerie <> oMovimento:oOrdServ:GetSerie()
		If !WmsQuestion(STR0020,WMSV07417) //Deseja alterar Documento/Serie?
			lRet := .F.
		Else
			lTrocouDoc := .T.
		EndIf
	EndIf
	// Se trocou o documento ou serie, deve validar a nova informa��o
	If lRet
		If lTrocouDoc
			If !HasTarDoc(@nRecnoD12)
				WMSVTAviso(WMSV07401,WmsFmtMsg(STR0021,{{"[VAR01]",cArmazem}})) // N�o existem atividades de confer�ncia para o documento no armaz�m [VAR01].
				Return .F.
			EndIf
		EndIf
		////  algum item do mesmo documento foi convocado p/ outro operador.
		If TarExeOper()
			WMSVTAviso(WMSV07402,STR0022) // Atividades da tarefa em andamento por outro operador.
			Return .F.
		EndIf
		If lTrocouDoc
			oMovimento:SetRecHum(Iif(lLiberaRH,cRecHVazio,oMovimento:GetRecHum()))
			If QtdComp(oMovimento:GetQtdLid()) > QtdComp(0)
				oMovimento:SetStatus("3") // Atividade Em Andamento
			Else
				oMovimento:SetStatus("4") // Atividade A Executar
				oMovimento:SetDataIni(CtoD(""))
				oMovimento:SetHoraIni("")
			EndIf
			oMovimento:SetDataFim(CtoD(""))
			oMovimento:SetHoraFim("")
			oMovimento:UpdateD12()
			If lLiberaRH
				// Retira recurso humano atribuido as atividades de outros itens do mesmo documento/s�rie
				CancRHServ()
			EndIf
			oMovimento:GotoD12(nRecnoD12)
			If WMSAltSts()
				If oMovimento:GetStatus() != "3"
					oMovimento:SetRecHum(__cUserID)
					oMovimento:SetStatus("3") // Atividade Executando
					oMovimento:SetDataIni(dDataBase)
					oMovimento:SetHoraIni(Time())
					oMovimento:SetDataFim(CTOD(""))
					oMovimento:SetHoraFim("")
					oMovimento:UpdateD12()
				EndIf
			EndIf
			//Atribui novamente vari�veis
			cServico   := oMovimento:oMovServic:GetServico()
			cOrdTar    := oMovimento:oMovServic:GetOrdem()
			cTarefa    := oMovimento:oMovTarefa:GetTarefa()
			cAtividade := oMovimento:oMovTarefa:GetAtivid()
			cArmazem   := oMovimento:oMovEndOri:GetArmazem()
			dDataIni   := oMovimento:GetDataIni()
			cHoraIni   := oMovimento:GetHoraIni()
			WMSVTAviso(STR0001,PadC(STR0023,VTMaxCol())+STR0024) // Aten��o - Documento alterado. Executar a conferencia do documento informado.
		EndIf
		// Atribui o documento todo para o usu�rio
		AddRHServ()
	EndIf
Return .T.
/*--------------------------------------------------------------------------------
---HasTarDoc
---Verifica se tem atividades para o novo documento informado
---Jackson Patrick Werka - 01/04/2015
---nRecnoD12, numerico, (N�mero do recno da movimenta��o)
---cProduto,  caracter, (Produto)
---cLoteCtl,  caracter, (Lote)
---cNumLote,  caracter, (Sub-Lote)
----------------------------------------------------------------------------------*/
Static Function HasTarDoc(nRecnoD12,cProduto,cLoteCtl,cNumLote)
Local lRet       := .F.
Local aAreaAnt   := GetArea()
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])

Default cProduto := Space(TamSX3('D12_PRODUT')[1])
Default cLoteCtl := Space(TamSX3('D12_LOTECT')[1])
Default cNumLote := Space(TamSX3('D12_NUMLOT')[1])
	cWhere := "%"
	If !Empty(cProduto)
		cWhere += " AND D12.D12_PRODUT  = '"+cProduto+"'"
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D12.D12_LOTECT  = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D12.D12_NUMLOT  = '"+cNumLote+"'"
	EndIf
	If oMovimento:lUsuArm
		cWhere += " AND D12.D12_LOCORI  = '"+cArmazem+"'"
	EndIf	
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_DOC = %Exp:cDocto%
		AND D12.D12_SERIE = %Exp:cSerie%
		AND D12.D12_STATUS IN ('3','4')
		AND (D12.D12_RECHUM = %Exp:cRecHVazio%
			OR D12.D12_RECHUM  = %Exp:__cUserID% )
		AND D12.D12_ENDORI = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasQry)->(!Eof())
		nRecnoD12 := (cAliasQry)->RECNOD12
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---TarExeOper
---Analisa se a tarefa est� em andamento por outro operador.
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function TarExeOper()
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar% 
		AND D12.D12_CLIFOR = %Exp:oMovimento:oOrdServ:GetCliFor()%
		AND D12.D12_DOC = %Exp:cDocto%
		AND D12.D12_SERIE  = %Exp:cSerie%
		AND D12.D12_RECHUM <> %Exp:cRecHVazio%
		AND D12.D12_RECHUM <> %Exp:__cUserID%
		AND D12.D12_LOCORI = %Exp:cArmazem%
		AND D12.D12_ENDORI = %Exp:cEndereco%
		AND D12.D12_STATUS <> '0'
		AND D12.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---CancRHServ
---Retira recurso humano atribuido as atividades de conferencia
---de outros itens do mesmo documento / serie.
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function CancRHServ()
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:oMovimento:oMovServic:GetServico()%
		AND D12.D12_DOC    = %Exp:oMovimento:oOrdServ:GetDocto()%
		AND D12.D12_SERIE  = %Exp:oMovimento:oOrdServ:GetSerie()%
		AND D12.D12_STATUS = '4' // Atividade A Executar
		AND D12.D12_RECHUM = %Exp:__cUserID%
		AND D12.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		D12->(MsGoto((cAliasQry)->D12RECNO))
		RecLock('D12', .F.)  // Trava para gravacao
		D12->D12_RECHUM := cRecHVazio
		D12->(MsUnlock())	
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return Nil
/*--------------------------------------------------------------------------------
---AddRHServ
---Atribui o recurso humano para as atividades de conferencia
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function AddRHServ()
Local lRet       := .F.
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local cWhere     := ""
	cWhere := "%"
	If oMovimento:lUsuArm .Or. !lWmsDaEn
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf	
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_DOC = %Exp:cDocto%
		AND D12.D12_SERIE  = %Exp:cSerie%
		AND D12.D12_STATUS IN ('2','3','4')
		AND D12.D12_RECHUM = %Exp:cRecHVazio%
		AND D12.D12_ENDDES  = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	Do While (cAliasQry)->(!Eof())
		D12->(MsGoto((cAliasQry)->RECNOD12))
		RecLock('D12', .F.)  // Trava para gravacao
		D12->D12_RECHUM := __cUserID
		D12->D12_DATINI := dDataIni
		D12->D12_HORINI := cHoraIni	
		D12->D12_DATFIM := CTOD("")
		D12->D12_HORFIM := ""
		D12->(MsUnlock())	
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidPrdLot
---Valida o produto informado, verificando se o mesmo pertence ao documento/serie
---Valida se o mesmo j� foi enderecado e pode ser conferido
---Jackson Patrick Werka - 01/04/2015
---cProduto, character, (Produto informado)
---cDescPro, character, (Descri��o do produto)
---cDescPr2, character, (Descri��o do produto)
---cDescPr3, character, (Descri��o do produto)
---cLoteCtl, character, (Lote etiqueta)
---cNumLote, character, (Sub-lote etiqueta)
---nQtde, numerico, (Quantidade etiqueta)
---cCodBar, character, (Codigo de barras)
----------------------------------------------------------------------------------*/
Static Function ValidPrdLot(cProduto,cLoteCtl,cNumLote,nQtde,cCodBar)
Local lRet      := .T.
	If Empty(cCodBar)
		Return .F.
	EndIf
	//Deve zerar estas informa��es, pois pode haver informa��o de outra etiqueta
	cLoteCtl := Space(TamSX3('D12_LOTECT')[1])
	cNumLote := Space(TamSX3('D12_NUMLOT')[1])
	
	lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQtde,@cCodBar)
	If ExistBlock("WMS074VL") // Executado para efetuar a valida��o do produto digitado
		lRetPE:= ExecBlock('WMS074VL',.F.,.F.,{cProduto,cLoteCtl,cNumLote,nQtde,cCodBar,cDocto,cSerie})
		lRet  := If(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf
	// Deve validar se o produto possui quantidade para ser conferida
	If lRet
		If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.)) == 0
			WMSVTAviso(WMSV07404,IIF(lWmsDaEn .And. !oMovimento:lUsuArm,STR0025,WmsFmtMsg(STR0047,{{"[VAR01]",cArmazem}}))) // N�o existe confer�ncia para o produto. //N�o existe confer�ncia para o produto no armaz�m [VAR01]. 
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		// Verifica se possui alguma quantidade para conferir liberada
		If lRet .And. QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote)) == 0
			// Caso n�o haja quantidade liberada, verifica se possui quantidade bloqueada
			If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.,.T.)) > 0
				WMSVTAviso(WMSV07405,STR0026) // Confer�ncia do produto bloqueada.
			Else
				WMSVTAviso(WMSV07406,STR0027) // Confer�ncia do produto finalizada.
			EndIf
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValLoteCtl
---Valida o produto/lote informado, verificando se o mesmo pertence ao documento/serie
---Valida se o mesmo j� foi enderecado e pode ser conferido
---Jackson Patrick Werka - 01/04/2015
---cProduto, character, (Produto)
---cLoteCtl, character, (Lote etiqueta)
----------------------------------------------------------------------------------*/
Static Function ValLoteCtl(cProduto,cLoteCtl)
Local lRet  := .T.
	If Empty(cLoteCtl)
		Return .F.
	EndIf
	If QtdComp(QtdPrdCof(cProduto,cLoteCtl,,.F.)) == 0
		WMSVTAviso(WMSV07408,STR0028) // Produto/Lote n�o pertence a confer�ncia.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Verifica se possui alguma quantidade para conferir liberada
	If lRet .And. QtdComp(QtdPrdCof(cProduto,cLoteCtl)) == 0
		// Caso n�o haja quantidade liberada, verifica se possui quantidade bloqueada
		If QtdComp(QtdPrdCof(cProduto,cLoteCtl,,.F.,.T.)) > 0
			WMSVTAviso(WMSV07409,STR0026) // Confer�ncia do Produto/Lote bloqueada.
		Else
			WMSVTAviso(WMSV07410,STR0027) // Confer�ncia do Produto/Lote finalizada.
		EndIf
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValSubLote
---Valida o produto/rastro informado, verificando se o mesmo pertence ao documento/serie
---Valida se o mesmo j� foi enderecado e pode ser conferido
---Jackson Patrick Werka - 01/04/2015
---cLoteCtl, character, (Lote)
---cNumLote, Caracter, (Sub-lote)
----------------------------------------------------------------------------------*/
Static Function ValSubLote(cProduto,cLoteCtl,cNumLote)
Local lRet  := .T.
	If Empty(cNumLote)
		Return .F.
	EndIf
	If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.)) == 0
		WMSVTAviso(WMSV07412,STR0029) // Produto/Rastro n�o pertence a confer�ncia.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Verifica se possui alguma quantidade para conferir liberada
	If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote)) == 0
		// Caso n�o haja quantidade liberada, verifica se possui quantidade bloqueada
		If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.,.T.)) > 0
			WMSVTAviso(WMSV07413,STR0030) // Confer�ncia do Produto/Rastro bloqueada.
		Else
			WMSVTAviso(WMSV07414,STR0031) // Confer�ncia do Produto/Rastro finalizada.
		EndIf
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValidQtd
---Valida a quantidade informada efetuando a convers�o das unidades de medida
---Jackson Patrick Werka - 01/04/2015
---nQtConf, Numerico, (Quantidade conferida)
---nItem, Numerico, (Quantidade Item)
---nQtdNorma, Numerico, (Quantidade da norma)
---nQtde1UM, Numerico, (Quantidade 1UM)
---nQtde2UM, Numerico, (Quantidade 2UM)
----------------------------------------------------------------------------------*/
Static Function ValidQtd(cProduto,cLoteCtl,cNumLote,nQtConf,nItem,nQtdNorma,nQtde1UM,nQtde2UM)
Local lRet := .T.
Local nQtdPrdCof := 0
	// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
	If Empty(nQtConf)
		Return .F.
	EndIf
	// O sistema trabalha sempre na 1a.UM
	If nItem == 1
		// Converter de U.M.I. p/ 1a.UM
		nQtde1UM := (nQtConf * nQtdNorma)
		nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
	ElseIf nItem == 2
		// Converter de 2a.UM p/ 1a.UM
		nQtde2UM := nQtConf
		nQtde1UM := ConvUm(cProduto,0,nQtde2UM,1)
	ElseIf nItem == 3
		// Converter de 1a.UM p/ 2a.UM
		nQtde1UM := nQtConf
		nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
	EndIf
	// Validando as quantidades informadas
	nQtdPrdCof := QtdPrdCof(cProduto,cLoteCtl,cNumLote)
	If QtdComp(nQtde1UM) > QtdComp(nQtdPrdCof)
		WMSVTAviso(WMSV07416,STR0032) // Quantidade informada maior que a quantidade liberada para confer�ncia.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---QtdPrdCof
---Permite carregar a quantidade do produto que est� pendente de confer�ncia
---Jackson Patrick Werka - 01/04/2015
---lSitLib, Logico, (Indica se est� liberado)
---lSitBlq, Logico, (Indica se est� bloqueado)
---lQtdLid, Logico, (Indica se est� lida)
----------------------------------------------------------------------------------*/
Static Function QtdPrdCof(cProduto,cLoteCtl,cNumLote,lSitLib,lSitBlq,lQtdLid)
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3('D12_QTDMOV')
Local cWhere     := ""
Local cCampos    := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local nQuant     := 0

Default cLoteCtl:= Space(TamSX3('D12_LOTECT')[1])
Default cNumLote:= Space(TamSX3('D12_NUMLOT')[1])
Default lSitLib := .T.
Default lSitBlq := .F.
Default lQtdLid := .F.
	cWhere := "%"
	If !Empty(cLoteCtl)
		cWhere += " AND D12.D12_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D12.D12_NUMLOT = '"+cNumLote+"'"
	EndIf
	If oMovimento:lUsuArm .Or. !lWmsDaEn
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf
	If lQtdLid
		cWhere += " AND D12.D12_STATUS IN ('3','1')"
	ElseIf lSitLib
		cWhere += " AND D12.D12_STATUS IN ('3','4')"
	ElseIf lSitBlq
		cWhere += " AND D12.D12_STATUS = '2'"
	Else
		cWhere += " AND D12.D12_STATUS <> '0'"
	EndIf
	cWhere += "%"
	cCampos := "%"
	If lQtdLid
		cCampos += "SUM(D12.D12_QTDLID) QTD_SALDO"
	ElseIf lSitLib
		cCampos += "SUM(D12.D12_QTDMOV - D12.D12_QTDLID) QTD_SALDO"
	Else
		cCampos += "SUM(D12.D12_QTDMOV) QTD_SALDO"
	EndIf	
	cCampos += "%"
	BeginSql Alias cAliasQry
		SELECT %Exp:cCampos%
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_DOC = %Exp:cDocto%
		AND D12.D12_SERIE = %Exp:cSerie%
		AND D12.D12_PRODUT = %Exp:cProduto%
		AND (D12.D12_RECHUM = %Exp:__cUserID%
			OR D12.D12_RECHUM = %Exp:cRecHVazio% )
		AND D12.D12_ENDDES = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasQry,'QTD_SALDO','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nQuant := (cAliasQry)->QTD_SALDO
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return nQuant
/*--------------------------------------------------------------------------------
---GravCofOpe
---Grava a quantidade conferida, finalizando a atividade
---relativa ao produto conferido, se for o caso.
---Jackson Patrick Werka - 01/04/2015
---cProduto, Numerico, (Produto)
---cLoteCtl, Caracter, (Lote)
---cNumLote, Caracter, (Sub-Lote)
---nQtConf,  Caracter, (Quantidade conferida)
----------------------------------------------------------------------------------*/
Static Function GravCofOpe(cProduto,cLoteCtl,cNumLote,nQtConf)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local nQtdLid    := 0
	// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
	Begin Transaction
		cWhere := "%"
		If !Empty(cLoteCtl)
			cWhere += " AND D12.D12_LOTECT  = '"+cLoteCtl+"'"
		EndIf
		If !Empty(cNumLote)
			cWhere += " AND D12.D12_NUMLOT  = '"+cNumLote+"'"
		EndIf
		If oMovimento:lUsuArm .Or. !lWmsDaEn
			cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_DOC = %Exp:cDocto%
			AND D12.D12_SERIE = %Exp:cSerie%
			AND D12.D12_PRODUT = %Exp:cProduto%
			AND D12.D12_STATUS IN ('3','4')
			AND (D12.D12_RECHUM = %Exp:__cUserID%
				OR D12.D12_RECHUM  =  %Exp:cRecHVazio% )
			AND D12.D12_ENDDES  = %Exp:cEndereco%
			AND ((D12.D12_QTDMOV-D12.D12_QTDLID) > 0)
			AND D12.%NotDel%
			%Exp:cWhere%
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof()) .And. QtdComp(nQtConf) > 0
			D12->(dbGoTo((cAliasQry)->RECNOD12))
			// Verifica somente o saldo que falta conferir daquele item
			// Se o saldo � diferente do informado para conferir
			// E a diferen�a absoluta do saldo mais o conferido � maior que a tolerancia
			If QtdComp(D12->D12_QTDMOV - D12->D12_QTDLID) < QtdComp(nQtConf)
				nQtdLid := D12->D12_QTDMOV - D12->D12_QTDLID
			Else
				nQtdLid := nQtConf
			EndIf
			RecLock("D12",.F.)
			D12->D12_DATINI := dDataIni
			D12->D12_HORINI := cHoraIni
			D12->D12_DATFIM := dDataBase
			D12->D12_HORFIM := Time()
			D12->D12_RECHUM := __cUserID
			D12->D12_STATUS := '3' // Atividade Em Andamento
			D12->D12_QTDLID := D12->D12_QTDLID + nQtdLid
			D12->(MsUnLock())
			// Diminuindo a quantida utilizada da quantidade conferida
			nQtConf -= nQtdLid
			// PE para permitir executar a��es adicionais na grava��o da confer�ncia por operador
			If lWV074GCO
				ExecBlock("WV074GCO", .F., .F.)
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	End Transaction
RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---FinCofEnt
---Grava a quantidade conferida, finalizando a atividade
---relativa ao produto conferido, se for o caso.
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function FinCofEnt()
Local lRet       := .T.
Local lDiverge   := .F.
Local aAreaAnt   := GetArea()
Local cAliasQry  := Nil
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local cWhere     := ""
	If AtivAntPen()
		WMSVTAviso(WMSV07419,STR0034) // Existem atividades anteriores n�o finalizadas.
		Return .F.
	EndIf

	If DocAntPen()
		WMSVTAviso(WMSV07420,STR0035) // Existem ordens de servi�o pendentes de execu��o.
		Return .F.
	EndIf
	cWhere := "%"
	If oMovimento:lUsuArm .Or. !lWmsDaEn
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	Begin Transaction
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_DOC = %Exp:cDocto%
			AND D12.D12_SERIE = %Exp:cSerie%
			AND D12.D12_STATUS IN ('2','3','4')
			AND (D12.D12_RECHUM = %Exp:__cUserID%
				OR D12.D12_RECHUM = %Exp:cRecHVazio% )
			AND D12.D12_ENDDES = %Exp:cEndereco%
			AND ((D12.D12_QTDMOV - D12.D12_QTDLID) > 0)
			AND D12.%NotDel%
			%Exp:cWhere%
		EndSql
		If (cAliasQry)->(!Eof())
			If WmsQuestion(STR0036,WMSV07411) // Existem itens n�o conferidos. Confirma a finaliza��o da confer�ncia?
				Do While (cAliasQry)->(!Eof())
					lDiverge := .T.
					D12->(dbGoTo((cAliasQry)->RECNOD12))
					RecLock("D12",.F.)
					D12->D12_DATFIM := dDataBase
					D12->D12_HORFIM := Time()
					D12->D12_STATUS := '2' // Atividade Com Problemas
					D12->D12_PRAUTO := '1' // Permite reinicio autom�tico
					D12->D12_ANOMAL := 'S'
					D12->(MsUnLock())
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				lRet   := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
		// Aqui deve liberar os itens da conferencia, caso esteja parametrizado para tal
		If lRet .And. !lDiverge
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D12.R_E_C_N_O_ RECNOD12
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_SERVIC = %Exp:cServico%
				AND D12.D12_TAREFA = %Exp:cTarefa%
				AND D12.D12_ATIVID = %Exp:cAtividade%
				AND D12.D12_ORDTAR = %Exp:cOrdTar%
				AND D12.D12_DOC = %Exp:cDocto%
				AND D12.D12_SERIE = %Exp:cSerie%
				AND D12.D12_RECHUM = %Exp:__cUserID%
				AND D12.D12_ENDDES = %Exp:cEndereco%
				AND D12.D12_STATUS IN ('2','3','4')
				AND ((D12.D12_QTDMOV - D12.D12_QTDLID) <= 0)
				AND D12.%NotDel%
				%Exp:cWhere%
			EndSql
			Do While (cAliasQry)->(!Eof())
				D12->(dbGoTo((cAliasQry)->RECNOD12))
				RecLock("D12",.F.)
				D12->D12_STATUS := '1' // Finalizado
				D12->(MsUnLock())			
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	If lRet .And. !lDiverge
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_DOC = %Exp:cDocto%
			AND D12.D12_SERIE = %Exp:cSerie%
			AND D12.D12_STATUS IN ('2','3','4')
			AND D12.D12_RECHUM <> %Exp:__cUserID%
			AND D12.D12_ENDDES = %Exp:cEndereco%
			AND ((D12.D12_QTDMOV - D12.D12_QTDLID) > 0)
			AND D12.%NotDel%
			%Exp:cWhere%
		EndSql
		If (cAliasQry)->(!Eof())
			WMSVTAviso(WMSV07421,STR0037) // Confer�ncia em andamento, h� pend�ncias atribuidas para outros usu�rios!
		Else
			WMSVTAviso(WMSV07422,STR0038) // Confer�ncia encerrada com sucesso!
			If ExistBlock("WMS074CF") // Executado ap�s a finaliza��o da atividade de confer�ncia
				ExecBlock('WMS074CF',.F.,.F.,{cServico,cDocto,cSerie})
			EndIf 
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		WMSVTAviso(WMSV07423,STR0039) // N�o foi poss�vel finalizar a confer�ncia.
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---SaiCofEnd
---Efetua a valida��o para verificar se n�o exitem mais itens pendentes
---Caso n�o exista mais nenhuma pendencia, somente dever� ser finalizado a confer�ncia
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function SaiCofEnd()
Local aAreaAnt   := GetArea()
Local lRet       := .T.
	If !AtivAtuPen()
		If !DocAntPen()
			WMSVTAviso(WMSV07424,STR0040) // N�o existem mais itens para serem conferidos. Confer�ncia deve ser finalizada.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidEnder
---Valida o endere�o informado
---Jackson Patrick Werka - 01/04/2015
---cEndereco, Caracter, (Endere�o informado)
----------------------------------------------------------------------------------*/
Static Function ValidEnder(cEndereco)
Local aAreaAnt := GetArea()
Local lRet     := .T.
	// Se n�o informou o endere�o retorna
	If Empty(cEndereco)
		Return .F.
	EndIf
	If cEndereco != oMovimento:oMovEndOri:GetEnder()
		WMSVTAviso(WMSV07425,STR0041) // Endereco incorreto!
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
	If lRet
		If !oMovimento:oMovEndOri:LoadData()
			WMSVTAviso(WMSV07426,WmsFmtMsg(STR0042,{{"[VAR01]",oMovimento:oMovEndOri:GetEnder()}})) // O endereco [VAR01] n�o est� cadastrado!
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return(lRet)
/*--------------------------------------------------------------------------------
---AtivAntPen
---Verifica se existem atividades anteriores n�o finalizadas
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function AtivAntPen()
Local lRet      := .F.
Local cAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_DOC = %Exp:cDocto%
		AND D12.D12_SERIE = %Exp:cSerie%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_ORDTAR < %Exp:cOrdTar%
		AND D12.D12_STATUS IN ('2','3','4')
		AND D12.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(cAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---DocAntPen
---Verifica se existem ordens de servi�o n�o executadas para o mesmo documento
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function DocAntPen()
Local lRet        := .F.
Local cAreaAnt    := GetArea()
Local cAliasQry   := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_DOCTO = %Exp:cDocto%
		AND DCF.DCF_SERIE = %Exp:cSerie%
		AND DCF.DCF_SERVIC = %Exp:cServico%
		AND DCF.DCF_STSERV IN ('1','2')
		AND DCF.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(cAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---AtivAtuPen
---Verifica se existem atividades do documento atual ainda pendentes
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function AtivAtuPen()
Local lRet       := .F.
Local cAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:SDB%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_DOC = %Exp:cDocto%
		AND D12.D12_SERIE = %Exp:cSerie%
		AND D12.D12_STATUS IN ('2','3','4')
		AND (D12.D12_RECHUM = %Exp:__cUserID%
			OR D12.D12_RECHUM = %Exp:cRecHVazio% )
		AND D12.D12_LOCORI = %Exp:cArmazem%
		AND D12.D12_ENDORI = %Exp:cEndereco%
		AND D12.%NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(cAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---WMSV074ESC
---Questiona ao usu�rio se o mesmo deseja sair da confer�ncia, abandonando a mesma
---Jackson Patrick Werka - 01/04/2015
---lAbandona, Logico, (Indica se abandona conferencia)
----------------------------------------------------------------------------------*/
Static Function WMSV074ESC(lAbandona)
// Disponibiliza novamente o documento para convoca��o quando o operador
// altera o documento ou abandona confer�ncia pelo Coletor RF.
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])

	If WmsQuestion(STR0045) // Deseja sair da conferencia?
		// Variavel private definida no programa WMSV001
		lAbandona := .T.
		// Variavel definida no programa WMSV001
		WMSAltSts(.F.)
		Begin Transaction
			oMovimento:SetRecHum(IIf(lLiberaRH,cRecHVazio,oMovimento:GetRecHum()))
			oMovimento:SetStatus(IIf((oMovimento:GetQtdMov() == oMovimento:GetQtdLid()),"3","4")) // Atividade A Executar
			oMovimento:UpdateD12()
		End Transaction
		If lLiberaRH
			// Retira recurso humano atribuido as atividades de outros itens do mesmo documento/serie.
			CancRHServ()
		EndIf
	EndIf
Return (Nil)
/*--------------------------------------------------------------------------------
---UpdStatus
---Verifica se o produto informado � o mesmo que o posicionado no objeto,
-- caso contr�rio posiciona no recno correto e atualiza o status das movimenta��es 
---Amanda Rosa Vieira - 14/12/2016
---cProduto,  caracter, (Produto)
---cLoteCtl,  caracter, (Lote)
---cNumLote,  caracter, (Sub-Lote)
----------------------------------------------------------------------------------*/
Static Function UpdStatus(cProduto,cLoteCtl,cNumLote)
Local nRecnoD12 := 0
	//Se o produto da movimenta��o corrente n�o teve quantidade lida, ent�o seu status passa para "A Excutar"
	//J� a movimenta��o do 'novo' produto ou lote informado deve passar para "Em Execu��o"
	If cProduto <> oMovimento:oMovPrdLot:GetProduto() .Or. cLoteCtl <> oMovimento:oMovPrdLot:GetLoteCtl() .Or. cNumLote <> oMovimento:oMovPrdLot:GetNumLote()
		If QtdPrdCof(oMovimento:oMovPrdLot:GetProduto(),oMovimento:oMovPrdLot:GetLoteCtl(),oMovimento:oMovPrdLot:GetNumLote(),.F.,.F.,.T.) == 0
			oMovimento:SetStatus("4") // Atividade A Executar
			oMovimento:UpdateD12()
		EndIf
		HasTarDoc(@nRecnoD12,cProduto,cLoteCtl,cNumlote)
		oMovimento:GotoD12(nRecnoD12)
		If oMovimento:GetStatus() != "3"
			oMovimento:SetStatus("3") // Atividade Executando
			oMovimento:UpdateD12()
		EndIf
	EndIf
Return
//------------------------------------------------------------
/*/{Protheus.doc} ExistDocSer
Valida se existe o documento e s�rie informados
@author amanda.vieira
@since 17/12/2019
@version 1.0
/*/
//------------------------------------------------------------
Static Function ExistDocSer(cDocto,cSerie)
Local lRet       := .F.
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()
	cWhere := "%"
	If !Empty(cSerie)
		cWhere += " AND D12.D12_SERIE  = '"+cSerie+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		  FROM %Table:D12% D12
		 WHERE D12.D12_FILIAL = %xFilial:D12%
		   AND D12.D12_DOC = %Exp:cDocto%
		   AND D12.D12_STATUS IN ('3','4')
		   AND D12.%NotDel%
		   %Exp:cWhere%
	EndSql
	If (cAliasQry)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet
//------------------------------------------------------------
/*/{Protheus.doc} WV074SETEN
"Essa fun��o foi criada para o uso "EXCLUSIVO" do ponto de entrada WV074TEP, 
para a inclus�o de uma tecla de atalho que permita a altera��o do endere�o de confer�ncia sem a
necessidade de encerrar e iniciar nova a confer�ncia, abrir telas de endere�o e de documento."
@author murilo.brandao
@since 01/12/2020
@version 1.0
/*/
//------------------------------------------------------------
Function WV074SETEN(cEnd)
cEndereco:=cEnd
Return
