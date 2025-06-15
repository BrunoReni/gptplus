#INCLUDE "FDVN107.ch"
#include "eADVPL.ch"

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � LoadInv             �Autor: Fabio Garbin  � Data �18/06/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Array com Itens do incentario  	 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aInv - Array dos Dados; cCli - Codigo do CLiente           ���
���			 | cLoja - Loja do ClienteoBrwInv - Objeto do Browse      	  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GravaInv            �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava registros do Inventario 				 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aInv - Array dos Dados; oBrwInv - Objeto do Browse      	  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GravaInv(aInv, oBrwInv)
Local i := 0
Local cTable := "HIN"+cEmpresa

If !File(cTable)
	MsgStop(STR0001 + cTable + STR0002,STR0003) //"N�o � poss�vel gravar. Tabela de Invent�rio "###" n�o encontrada!"###"Aviso"
	Return Nil
EndIf

If !MsgYesOrNo(STR0004,STR0005) //"Confirma Grava��o do Invent�rio ?"###"Invent�rio"
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

Alert(STR0006) //"Invent�rio gravado com sucesso."
SetArray(oBrwInv, aInv)

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � UpdInv              � Autor: Fabio Garbin � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza Array (aInv) e tela do Inventario 				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOp- Operacao (1-Inclui, 2-Exclui); aInv - Array dos Dados;���
���			 � cCliente- Codigo do Cliente; cLoja - Loja do CLiente;	  ���
���          � cprod- Cpdigo do Produto; oGetPrd/oGetQtd - Obejtos Get;	  ���
��� 	     � oBrwInv - Objeto do Browse      	  						  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function UpdInv(nOp, aInv, cCliente, cLoja, cProd, nQtdInv, oGetPrd, oGetQtd, oBrwInv)
// nOp = 1 - Inclusao de Item
// nOp = 2 - Exclusao de Item
Local nPos := 0, i := 0

If nOp = 1 .And. Empty(cProd)  // Nao permite a inclusao sem um produto
	MsgStop(STR0007, STR0005) //"Digite um Produto V�lido"###"Invent�rio"
	Return Nil
EndIf

HB1->( dbSetOrder(1) )
HB1->( dbSeek(cProd) )
If !HB1->(Found())
	MsgStop(STR0007, STR0005) //"Digite um Produto V�lido"###"Invent�rio"
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

ElseIf nOp = 2	// Exclus�o de item
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PreparaInv          �Autor: Cleber  M.    � Data �15/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Prepara tela/variaveis usadas no Inventario	 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aPrdPrefix									        	  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/    
Function PreparaInv(aPrdPrefix)
aSize(aGrupo,0)
aSize(aProduto,0)
nGrupo:=1
cUltGrupo:=""
SetPrefix(aPrdPrefix)
Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � RefreshProd         �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava registros do Inventario 				 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oGet - Obejto e Get; cProd - Codigo do Produto        	  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function RefreshProd(oGet, cProd, aPrdPrefix)

GetProduto(@cProd,aPrdPrefix)
SetText(oGet,cProd)                  

Return Nil


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ChkIndeni           �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Checa se a indenizacao e maior que o valor do pedido  	  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  aCabPed                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ChkIndeni(aCabPed)
Local lRet := .F.

If aCabPed[14,1] < aCabPed[11,1]
	lRet := .T.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � LoadNewPedidos      �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega arrays com Codigos dos Pedidos e outro array com   ���
���          | Valor Total do Pedido  									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�  aCabPed                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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

Function RetStatus(cCodCli, cLojaCli, lTemDupl, cTitulos)
Local nAtraso := 0

lTemDupl := .f.
dbSelectArea("HE1")
dbSetOrder(1)
dbGoTop()
dbSeek( cCodCli+cLojaCli,.f. )
While !HE1->(Eof()) .and. (HE1->E1_CLIENTE == cCodCli .and. HE1->E1_LOJA == cLojaCli)
	If At(HE1->E1_TIPO, cTitulos) == 0
		nAtraso	 := Date() - HE1->E1_VENCTO
		lTemDupl := .t.	
		If nAtraso > 0	//existem titulos em atraso (sair)
			exit
		Endif
	Endif
	HE1->(dbSkip())
Enddo
//Alert(cCodCLi+cLojaCli + " - " + Str(nAtraso, 5,0))
Return nAtraso