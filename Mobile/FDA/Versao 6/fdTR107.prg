#INCLUDE "FDTR107.ch"
#include "eADVPL.ch"

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � LoadTroca           �Autor: Marcelo Vieira| Data �01/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Array com Itens das trocas      	 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aTroca- Array dos Dados; cCli - Codigo do CLiente          ���
���			 | cLoja - Loja do ClienteoBrwInv - Objeto do Browse      	  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function LoadTroca(aTroca, cCodCli, cLoja)

dbSelectArea("HTR")
dbSetOrder(1)
If dbSeek(cCodCli + cLoja)
	While !Eof() .And. cCodCli = HTR->TR_CLI  .And. cLoja = HTR->TR_LOJA
		aAdd(aTroca, {HTR->TR_CLI, HTR->TR_LOJA, AllTrim(HTR->TR_PROD), HTR->TR_QTD, 0})
		HTR->(dbSkip())
	EndDo
EndIf

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GravaTRC            �Autor: M.Vieira      � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava registros das Trocas   				 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aTroca - Array dos Dados; oBrwTrc - Objeto do Browse    	  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GravaTrc(aTroca, oBrwTrc)
Local i := 0
Local cTable := "HTR"+cEmpresa

If !File(cTable)
	MsgStop(STR0001 + cTable + STR0002,STR0003) //"N�o � poss�vel gravar. Tabela de Trocas "###" n�o encontrada!"###"Aviso"
	Return Nil
EndIf

If !MsgYesOrNo(STR0004,STR0005) //"Confirma Grava��o desta Troca ?"###"Trocas"
	Return
EndIf

For i := 1 To Len(aTroca)
	HB1->(dbSetOrder(1))
	HB1->(dbSeek(aTroca[i,3]))
	If aTroca[i,5] = 1
		dbSelectArea("HTR")
		dbSetOrder(2)
		If !dbSeek(HB1->B1_GRUPO + HB1->B1_COD + aTroca[i,1] + aTroca[i,2])
			HTR->( dbAppend() )
		EndIf
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � UpdTrc              � Autor: M. Vieira    � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza Array (aTroca) e tela das Trocas    			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOp-Operacao(1-Inclui, 2-Exclui); aTroca - Array dos Dados;���
���			 � cCliente- Codigo do Cliente; cLoja - Loja do CLiente;	  ���
���          � cprod- Cpdigo do Produto; oGetPrd/oGetQtd - Obejtos Get;	  ���
��� 	     � oBrwTrc - Objeto do Browse      	  						  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function UpdTrc(nOp, aTroca, cCliente, cLoja, cProd, nQtdTrc, oGetPrd, oGetQtd, oBrwTrc)
// nOp = 1 - Inclusao de Item
// nOp = 2 - Exclusao de Item
Local nPos := 0, i := 0

If nOp = 1 .And. Empty(cProd)  // Nao permite a inclusao sem um produto
	MsgStop(STR0007, STR0005) //"Digite um Produto V�lido"###"Trocas"
	Return Nil
EndIf

HB1->( dbSetOrder(1) )
HB1->( dbSeek(cProd) )
If !HB1->(Found())
	MsgStop(STR0007, STR0005) //"Digite um Produto V�lido"###"Trocas"
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

ElseIf nOp = 2	// Exclus�o de item
	If Len(aTroca) == 0
		return nil	
	Endif
	nPos := GridRow(oBrwTrc)

	HB1->(dbSetOrder(1))
	HB1->(dbSeek(aTroca[nPos,3]))
	dbSelectArea("HTR")
	dbSetOrder(1)
	If dbSeek(HB1->B1_GRUPO + HB1->B1_COD + aTroca[nPos,1] + aTroca[nPos,2])
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PreparaTroca        �Autor: Cleber  M.    � Data �15/09/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Prepara tela/variaveis usadas na Trocas  	 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aPrdPrefix									        	  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/    
Function PrepTroca(aPrdPrefix)
aSize(aGrupo,0)
aSize(aProduto,0)
nGrupo:=1
cUltGrupo:=""
SetPrefix(aPrdPrefix)
Return nil