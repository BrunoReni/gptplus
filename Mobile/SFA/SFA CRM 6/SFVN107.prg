#INCLUDE "SFVN107.ch"
#include "eADVPL.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � LoadInv             矨utor: Fabio Garbin  � Data �18/06/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Array com Itens do incentario  	 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aInv - Array dos Dados; cCli - Codigo do CLiente           潮�
北�			 | cLoja - Loja do ClienteoBrwInv - Objeto do Browse      	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function LoadInv(aInv, cCodCli, cLoja)

dbSelectArea("HIN")
dbSetOrder(2)
If dbSeek(cCodCli + cLoja)
	While !Eof() .And. cCodCli = HIN->IN_CLI  .And. cLoja = HIN->IN_LOJA
		aAdd(aInv, {HIN->IN_CLI, HIN->IN_LOJA, AllTrim(HIN->IN_PROD), HIN->IN_QTD, 0})
		HIN->(dbSkip())
	EndDo
EndIf

Return


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � GravaInv            矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Grava registros do Inventario 				 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aInv - Array dos Dados; oBrwInv - Objeto do Browse      	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function GravaInv(aInv, oBrwInv)
Local i := 0
Local cTable := "HIN"+cEmpresa

If !File(cTable)
	MsgStop(STR0001 + cTable + STR0002,STR0003) //"N鉶 � poss韛el gravar. Tabela de Invent醨io "###" n鉶 encontrada!"###"Aviso"
	Return Nil
EndIf

If !MsgYesOrNo(STR0004,STR0005) //"Confirma Grava玢o do Invent醨io ?"###"Invent醨io"
	Return
EndIf

For i := 1 To Len(aInv)
	HB1->(dbSetOrder(1))
	HB1->(dbSeek(aInv[i,3]))
	If aInv[i,5] = 1
		dbSelectArea("HIN")
		dbSetOrder(1)
		If !dbSeek(HB1->B1_GRUPO + HB1->B1_COD + aInv[i,1] + aInv[i,2])
			dbAppend()
		EndIf
		HIN->IN_CLI   := aInv[i,1]
		HIN->IN_LOJA  := aInv[i,2]
		HIN->IN_GRUPO := HB1->B1_GRUPO
		HIN->IN_PROD  := aInv[i,3]
		HIN->IN_DATA  := Date()
		HIN->IN_QTD   := aInv[i,4]
		dbCommit()
	EndIf
Next

Alert(STR0006) //"Invent醨io gravado com sucesso."
SetArray(oBrwInv, aInv)

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � UpdInv              � Autor: Fabio Garbin � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Atualiza Array (aInv) e tela do Inventario 				  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOp- Operacao (1-Inclui, 2-Exclui); aInv - Array dos Dados;潮�
北�			 � cCliente- Codigo do Cliente; cLoja - Loja do CLiente;	  潮�
北�          � cprod- Cpdigo do Produto; oGetPrd/oGetQtd - Obejtos Get;	  潮�
北� 	     � oBrwInv - Objeto do Browse      	  						  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function UpdInv(nOp, aInv, cCliente, cLoja, cProd, nQtdInv, oGetPrd, oGetQtd, oBrwInv)
// nOp = 1 - Inclusao de Item
// nOp = 2 - Exclusao de Item
Local nPos := 0, i := 0

If nOp = 1 .And. Empty(cProd)  // Nao permite a inclusao sem um produto
	MsgStop(STR0007, STR0005) //"Digite um Produto V醠ido"###"Invent醨io"
	Return Nil
EndIf

HB1->( dbSetOrder(1) )
HB1->( dbSeek(cProd) )
If !HB1->(Found())
	MsgStop(STR0007, STR0005) //"Digite um Produto V醠ido"###"Invent醨io"
	Return Nil
Else
	cProd := HB1->B1_COD
Endif

If nOp = 1  // Inclui Item               
	// Verifica primeiro se j� existe o Item no Array
	nPos := ScanArray(aInv,AllTrim(cProd),,,3)
	/*For i := 1 To Len(aInv)  
		If aInv[i,3] == AllTrim(cProd)
			nPos := i
			Exit
		EndIf
	Next	*/
	If nPos == 0
		aAdd(aInv, {cCliente, cLoja, AllTrim(cProd), nQtdInv, 1}) // Inclui o Item
	Else
		aInv[nPos, 4] := aInv[nPos, 4] + nQtdInv // Atualiza o item
		aInv[nPos, 5] := 1
	EndIf

ElseIf nOp = 2	// Exclus鉶 de item
	If Len(aInv) == 0
		return nil	
	Endif
	nPos := GridRow(oBrwInv)

	HB1->(dbSetOrder(1))
	HB1->(dbSeek(aInv[nPos,3]))
	dbSelectArea("HIN")
	dbSetOrder(1)
	If dbSeek(HB1->B1_GRUPO + HB1->B1_COD + aInv[nPos,1] + aInv[nPos,2])
		dbDelete()
		dbSkip()
	EndIf
	
	aDel(aInv, nPos)
	aSize(aInv, Len(aInv)-1)
EndIf
cProd   := ""
nQtdInv := 0

SetText(oGetPrd, cProd)
Settext(oGetQtd, nQtdInv)
SetArray(oBrwInv, aInv)

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PreparaInv          矨utor: Cleber  M.    � Data �15/09/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Prepara tela/variaveis usadas no Inventario	 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aPrdPrefix									        	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/    
Function PreparaInv(aPrdPrefix)
aSize(aGrupo,0)
aSize(aProduto,0)
nGrupo:=1
cUltGrupo:=""
SetPrefix(aPrdPrefix)
Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � RefreshProd         矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Grava registros do Inventario 				 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� oGet - Obejto e Get; cProd - Codigo do Produto        	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function RefreshProd(oGet, cProd, aPrdPrefix)

GetProduto(@cProd,aPrdPrefix)
SetText(oGet, cProd)

Return Nil


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ChkIndeni           矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Checa se a indenizacao e maior que o valor do pedido  	  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�  aCabPed                                                   潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ChkIndeni(aCabPed)
Local lRet := .F.

If aCabPed[14,1] < aCabPed[11,1]
	lRet := .T.
EndIf

Return lRet

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � LoadNewPedidos      矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega arrays com Codigos dos Pedidos e outro array com   潮�
北�          | Valor Total do Pedido  									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�  aCabPed                                                   潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/

Function LoadNewPedidos(cCodCli, cLojaCli, aPedido, aVlrPed)
Local lChkCli := !Empty(cCodCli) .And. !Empty(cLojaCli)

dbSelectArea("HC5")
If !lChkCli 
	dbSetOrder(1)
	While HC5->(!Eof())
		If HC5->C5_STATUS = "N" .And. HC5->(IsDirty())
			AADD(aPedido,HC5->C5_NUM)
			MsgStop(Str(HC5->C5_VALOR,8,2))
			AADD(aVlrPed,HC5->C5_VALOR)
		EndIf	
		HC5->(dbSkip())
	EndDo
Else
	dbSetOrder(2)
	dbSeek(cCodCli+cLojaCli)
	While HC5->(!Eof()) .And. HC5->C5_CLI = cCodCli .And. HC5->C5_LOJA = cLojaCli
		If HC5->C5_STATUS = "N" .And. HC5->(IsDirty())
			AADD(aPedido,HC5->C5_NUM)
			AADD(aVlrPed,HC5->C5_VALOR)
		EndIf	
		HC5->(dbSkip())
	EndDo
EndIf
Return