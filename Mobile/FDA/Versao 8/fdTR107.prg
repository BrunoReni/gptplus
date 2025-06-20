#INCLUDE "FDTR107.ch"
#include "eADVPL.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � LoadTroca           矨utor: Marcelo Vieira| Data �01/10/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Array com Itens das trocas      	 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aTroca- Array dos Dados; cCli - Codigo do CLiente          潮�
北�			 | cLoja - Loja do ClienteoBrwInv - Objeto do Browse      	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function LoadTroca(aTroca, cCodCli, cLoja)

dbSelectArea("HTR")
dbSetOrder(1)
If dbSeek(RetFilial("HTR") + cCodCli + cLoja)
	While !Eof() .And. HTR->HTR_FILIAL == RetFilial("HTR") .And. cCodCli = HTR->TR_CLI  .And. cLoja = HTR->TR_LOJA
		aAdd(aTroca, {HTR->TR_CLI, HTR->TR_LOJA, AllTrim(HTR->TR_PROD), HTR->TR_QTD, 0})
		HTR->(dbSkip())
	EndDo
EndIf

Return

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � GravaTRC            矨utor: M.Vieira      � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Grava registros das Trocas   				 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aTroca - Array dos Dados; oBrwTrc - Objeto do Browse    	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function GravaTrc(aTroca, oBrwTrc)
Local i := 0
Local cTable := "HTR"+cEmpresa

If !File(cTable)
	MsgStop(STR0001 + cTable + STR0002,STR0003) //"N鉶 � poss韛el gravar. Tabela de Trocas "###" n鉶 encontrada!"###"Aviso"
	Return Nil
EndIf

If !MsgYesOrNo(STR0004,STR0005) //"Confirma Grava玢o desta Troca ?"###"Trocas"
	Return
EndIf

For i := 1 To Len(aTroca)
	HB1->(dbSetOrder(1))
	HB1->(dbSeek(RetFilial("HB1")+aTroca[i,3]))
	If aTroca[i,5] = 1
		dbSelectArea("HTR")
		dbSetOrder(2)
		If !dbSeek(RetFilial("HTR")+HB1->B1_GRUPO + HB1->B1_COD + aTroca[i,1] + aTroca[i,2])
			HTR->( dbAppend() )
		EndIf
		HTR->HTR_FILIAL := RetFilial("HTR")
		HTR->TR_CLI   := aTroca[i,1]
		HTR->TR_LOJA  := aTroca[i,2]
		HTR->TR_GRUPO := HB1->B1_GRUPO
		HTR->TR_PROD  := aTroca[i,3]
		HTR->TR_DATA  := Date()
        HTR->TR_DTVENC:= Date()		
		HTR->TR_QTD   := aTroca[i,4]
		HTR->TR_OBS   := ""    
        HTR->TR_STATUS:= "N"    		
		HTR->( dbCommit() ) 
	EndIf
Next

Alert(STR0006) //"Troca gravada com sucesso."
SetArray(oBrwTrc, aTroca)

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � UpdTrc              � Autor: M. Vieira    � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Atualiza Array (aTroca) e tela das Trocas    			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOp-Operacao(1-Inclui, 2-Exclui); aTroca - Array dos Dados;潮�
北�			 � cCliente- Codigo do Cliente; cLoja - Loja do CLiente;	  潮�
北�          � cprod- Cpdigo do Produto; oGetPrd/oGetQtd - Obejtos Get;	  潮�
北� 	     � oBrwTrc - Objeto do Browse      	  						  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function UpdTrc(nOp, aTroca, cCliente, cLoja, cProd, nQtdTrc, oGetPrd, oGetQtd, oBrwTrc)
// nOp = 1 - Inclusao de Item
// nOp = 2 - Exclusao de Item
Local nPos := 0, i := 0

If nOp = 1 .And. Empty(cProd)  // Nao permite a inclusao sem um produto
	MsgStop(STR0007, STR0005) //"Digite um Produto V醠ido"###"Trocas"
	Return Nil
EndIf

HB1->( dbSetOrder(1) )
HB1->( dbSeek(RetFilial("HB1")+cProd) )
If !HB1->(Found())
	MsgStop(STR0007, STR0005) //"Digite um Produto V醠ido"###"Trocas"
	Return Nil
Else
	cProd := HB1->B1_COD
Endif

If nOp = 1  // Inclui Item               
	// Verifica primeiro se j� existe o Item no Array
	nPos := ScanArray(aTroca,AllTrim(cProd),,,3)

	If nPos == 0
		aAdd(aTroca, {cCliente, cLoja, AllTrim(cProd), nQtdTrc, 1}) // Inclui o Item
	Else
		aTroca[nPos, 4] := aTroca[nPos, 4] + nQtdTrc // Atualiza o item
		aTroca[nPos, 5] := 1
	EndIf

ElseIf nOp = 2	// Exclus鉶 de item
	If Len(aTroca) == 0
		return nil	
	Endif
	nPos := GridRow(oBrwTrc)

	HB1->(dbSetOrder(1))
	HB1->(dbSeek(RetFilial("HB1")+aTroca[nPos,3]))
	dbSelectArea("HTR")
	dbSetOrder(1)
	If dbSeek(RetFilial("HTR")+HB1->B1_GRUPO + HB1->B1_COD + aTroca[nPos,1] + aTroca[nPos,2])
		dbDelete()
		dbSkip()
	EndIf
	
	aDel(aTroca, nPos)
	aSize(aTroca, Len(aTroca)-1)
EndIf
cProd   := ""
nQtdTrc := 0

SetText(oGetPrd, cProd)
Settext(oGetQtd, nQtdTrc)
SetArray(oBrwTrc, aTroca)

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PreparaTroca        矨utor: Cleber  M.    � Data �15/09/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Prepara tela/variaveis usadas na Trocas  	 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aPrdPrefix									        	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/    
Function PrepTroca(aPrdPrefix)
aSize(aGrupo,0)
aSize(aProduto,0)
nGrupo:=1
cUltGrupo:=""
SetPrefix(aPrdPrefix)
Return nil