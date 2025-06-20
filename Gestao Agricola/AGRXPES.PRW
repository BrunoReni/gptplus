#include 'protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRXPE01 �Autor  � Ricardo Tomasi     � Data �  02/08/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o chamada ap�s a inclus�o do Documento de Saida.      ���
�������������������������������������������������������������������������͹��
���Fun��es   � Gera FunRural quando a TES n�o esta para gerar financeiro. ���
���          � Gera FETHAB - Imposto localizado para o estado "MT".       ���
���          � Atualiza saldo dos Compromissos Futuros.                   ���
���          � Atualiza saldo dos Romaneios de Saida.                     ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AGRXPE01()
Local aAreaAnt := GetArea()
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local lFethab  := IIf(GetMV('MV_ESTADO')$'MT',.T.,.F.)
Local nValFun  := 0
Local nTotFun  := 0
Local nValFet  := IIf(lFethab,GetMV('MV_FETHAB'),0)
Local nTotFet  := 0
//Local aFina050 := Array(0)
//Local cHist    := 'FETHAB NF. ' + SF2->F2_DOC
//Private lMsErroAuto := .f.

Do Case
	Case SM0->M0_PRODRUR == 'F'
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),1,3))
	Case SM0->M0_PRODRUR == 'L'
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),5,3))
	Case SM0->M0_PRODRUR == 'J'
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),9,3))
	OtherWise
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),1,3))
EndCase

dbSelectArea('SD2')
dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	While .Not. Eof() .And. xFilial('SF2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == xFilial('SD2')+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA

		dbSelectArea('SF4')
		dbSetOrder(1)
		dbSeek(xFilial('SF4')+SD2->D2_TES)

		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+SD2->D2_COD)

		dbSelectArea('SC5')
		dbSetOrder(1)
		dbSeek(xFilial('SC5')+SD2->D2_PEDIDO)

		dbSelectArea('SC6')
		dbSetOrder(1)
		dbSeek(xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)

		//�����������������������������������������������������������������������������������Ŀ
		//�Caso tenha sido informado o codigo do Romaneio de Saida no Pedido de Venda.        �
		//�Atualiza a tabela SD2 (Itens da NF) com as informa��es da tabela SC6 (Itens do PV).�
		//�Atualiza a tabela NPR (Romaneio de Saida) abatendo do saldo a quantidade           �
		//�informada no Item da NF (SD2)                                                      �
		//�������������������������������������������������������������������������������������
		If .Not. Empty(SC6->C6_CODROM)
			RecLock('SD2',.f.)
			SD2->D2_CODROM := SC6->C6_CODROM
			MsUnLock()
			dbSelectArea('NPR')
			dbSetOrder(1)
			dbSeek(xFilial('NPR')+SC6->C6_CODROM)
			RecLock('NPR',.f.)
			NPR->NPR_SALDO -= AGRX001(SD2->D2_UM,NPR->NPR_UM,SD2->D2_QUANT)
			MsUnLock()
		EndIf

		//�����������������������������������������������������������������������������������Ŀ
		//�Caso tenha sido informado o codigo do Compromisso Futuro no Pedido de Venda.       �
		//�Atualiza a tabela SD2 (Itens da NF) com as informa��es da tabela SC6 (Itens do PV).�
		//�Atualiza a tabela NO1 (Compromissos Fut.) abatendo do saldo a quantidade           �
		//�informada no Item da NF (SD2)                                                      �
		//�Caso o saldo do Compromisso Futuro fique menor que 1 o faturamento do compromisso  �
		//�futuro sera fechado (NO1_FCHFAT = "S").                                            �
		//�������������������������������������������������������������������������������������
		If .Not. Empty(SC6->C6_NUMCP)
			RecLock('SD2',.f.)
			SD2->D2_NUMCP := SC6->C6_NUMCP
			MsUnLock()
			dbSelectArea('NO1')
			dbSetOrder(1)
			dbSeek(xFilial('NO1')+SC6->C6_NUMCP)
			RecLock('NO1',.f.)
			NO1->NO1_SALDO -= AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
			If NO1->NO1_SALDO < 1
				NO1->NO1_FCHFAT := 'S'
			EndIf
			MsUnLock()
		EndIf

		//���������������������������������������Ŀ
		//�Caso o Cliente n�o seja Tipo Exporta��o�
		//�e sobre o produto incidir Cont.Seg.Soc.�
		//�sera calculado o valor da contribui��o.�
		//�����������������������������������������
		If SB1->B1_CONTSOC == 'S' .And. SC5->C5_TIPOCLI <> 'X'
			nTotFun += (SD2->D2_TOTAL * nValFun) / 100
		EndIf

		//�����������������������������������������������������������Ŀ
		//�Caso o haja necessidade de calculo do FETHAB pela locali-  �
		//�za��o do usuario do sistema. Sera validado a incidencia no �
		//�cadastro do produto (B1_FETHAB) e a incidencia sobre a     �
		//�opera��o [TES].                                            �
		//�As duas sendo verdadeiras sera calculado o valor do imposto�
		//�baseado no parametro (MV_FETHAB).                          �
		//�������������������������������������������������������������
		If lFethab
				If SB1->B1_FETHAB == 'S' .And. If(TAMSX3("F4_FETHAB")[3]=="C",SF4->F4_FETHAB="S",SF4->F4_CALCFET="1")
				nTotFet += (AGRX001(SD2->D2_UM,'TL',SD2->D2_QUANT) * nValFet)
			EndIf
		EndIf

		dbSelectArea('SD2')
		dbSkip()
	EndDo
EndIf

If nTotFun > 0
	If RecLock('SF2',.f.)
		SF2->F2_CONTSOC := nTotFun
		MsUnLock()
	EndIf
EndIf

If nTotFet > 0
	If RecLock('SF2',.f.)
		SF2->F2_FETHAB := nTotFet
		MsUnLock()
	EndIf
EndIf

RestArea(aAreaSC6)
RestArea(aAreaSF4)
RestArea(aAreaSB1)
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aAreaAnt)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRXPE02 �Autor  � Ricardo Tomasi     � Data �  07/12/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada antes da exclus�o da NFS.                 ���
�������������������������������������������������������������������������͹��
���Fun��es   � Valida se existem titulos de impostos baixados.            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AGRXPE02()
Local aAreaAnt := GetArea()
Local aAreaSE2 := SE2->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local lRetorno := .t.

dbSelectArea('SD2')
dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	While .Not. Eof() .And. xFilial('SF2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == xFilial('SD2')+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		dbSelectArea('NO1')
		dbSetOrder(1)
		dbSeek(xFilial('NO1')+SD2->D2_NUMCP)
		If .Not. Empty(SD2->D2_NUMCP).And.NO1->NO1_FECHAD=='S'
			ApMsgAlert("Esta NFS n�o podera ser excluida, pois o Compromisso Futuro referente a ela j� esta fechado.","Compromisso Futuro")
			lRetorno := .f.
			Exit
		EndIf
		dbSelectArea('SD2')
		dbSkip()
	EndDo
EndIf

RestArea(aAreaSD2)
RestArea(aAreaSE2)
RestArea(aAreaAnt)
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRXPE03 �Autor  � Ricardo Tomasi     � Data �  07/12/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada antes da exclus�o da NFS.                 ���
�������������������������������������������������������������������������͹��
���Fun��es   � Excluir titulo de FETHAB gerado para esta NFS.             ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AGRXPE03()

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRXPE04 �Autor  � Ricardo Tomasi     � Data �  07/12/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada na confirma��o do pedido de venda.        ���
�������������������������������������������������������������������������͹��
���Fun��es   � Validar saldo do Compromisso Futuro.                       ���
���          � Validar saldo do Romaneio de Saida.                        ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AGRXPE04()
Local aAreaAnt  := GetArea()
Local lRetorno  := .t.
Local nX        := 0
Local nP_UM     := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_UM'})
Local nP_QTDVEN := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN'})
Local nP_CODROM := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_CODROM'})
Local nP_NUMCP  := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_NUMCP' })

For nX := 1 To Len(aCols)

	If .Not. Empty(aCols[nX,nP_CODROM])
		dbSelectArea('NPR')
		dbSetOrder(1)
		dbSeek(xFilial('NPR')+aCols[nX,nP_CODROM])
		If NPR->NPR_SALDO <> AGRX001(aCols[nX,nP_UM],NPR->NPR_UM,aCols[nX,nP_QTDVEN])
			ApMsgAlert("Saldo do Romaneio para atender este pedido."+Chr(13)+Chr(10)+;
					   "Saldo do Romaneio: "+Transform(AGRX001(NPR->NPR_UM,aCols[nX,nP_UM],NPR->NPR_SALDO),;
					   '@E 999,999,999.99')+aCols[nX,nP_UM], "Saldo do Romaneio")
		EndIf
		If NPR->NPR_SALDO < AGRX001(aCols[nX,nP_UM],NPR->NPR_UM,aCols[nX,nP_QTDVEN])
			lRetorno := .f.
			Exit
		EndIf
	EndIf

	If .Not. Empty(aCols[nX,nP_NUMCP])
		dbSelectArea('NO1')
		dbSetOrder(1)
		dbSeek(xFilial('NO1')+aCols[nX,nP_NUMCP])
		If (NO1->NO1_SALDO + 1) < AGRX001(aCols[nX,nP_UM],NO1->NO1_UM1PRO,aCols[nX,nP_QTDVEN])
			ApMsgAlert("N�o ha saldo no Compromisso Futuro para atender este pedido."+Chr(13)+Chr(10)+;
					   "Saldo do Compromisso: "+Transform(AGRX001(NO1->NO1_UM1PRO,aCols[nX,nP_UM],NO1->NO1_SALDO),;
					   '@E 999,999,999.99')+aCols[nX,nP_UM], "Saldo do Comp. Fut.")
			lRetorno := .f.
			Exit
		EndIf
	EndIf

Next nX

RestArea(aAreaAnt)
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRXPE05 �Autor  � Ricardo Tomasi     � Data �  07/12/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada na exclusao de itens da NFS.              ���
�������������������������������������������������������������������������͹��
���Fun��es   �                                                            ���
���          � Alterar saldo do Compromisso Futuro.                       ���
���          � Alterar saldo do Romaneio de Saida.                        ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AGRXPE05()
Local aAreaAnt  := GetArea()

If .Not. Empty(SD2->D2_CODROM)
	dbSelectArea('NPR')
	dbSetOrder(1)
	If dbSeek(xFilial('NPR')+SD2->D2_CODROM)
		RecLock('NPR')
		NPR->NPR_SALDO += AGRX001(SD2->D2_UM,NPR->NPR_UM,SD2->D2_QUANT)
		MsUnLock()
	EndIf
EndIf

If .Not. Empty(SD2->D2_NUMCP)
	dbSelectArea('NO1')
	dbSetOrder(1)
	If dbSeek(xFilial('NO1')+SD2->D2_NUMCP)
		RecLock('NO1',.f.)
		If NO1->NO1_SALDO < 1
			NO1->NO1_FCHFAT := 'N'
		EndIf
		NO1->NO1_SALDO += AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
		MsUnLock()
	EndIf
EndIf

RestArea(aAreaAnt)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRXPE08 �Autor  � Ricardo Tomasi     � Data �  02/08/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o chamada ap�s a baixa do titulo a pagar.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AGRXPE08()
Local aArea := GetArea()

//�����������������������������������������������������������������������������������Ŀ
//�Este ponto de entrada chama a fun��o que altera o status do titulo no contrato fin.�
//�������������������������������������������������������������������������������������
AGRA105G()

RestArea(aArea)
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRXPE09 �Autor  � Ricardo Tomasi     � Data �  02/08/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o chamada ap�s a cacelamento da baixa do titulo do    ���
���          � contas a pagar.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AGRXPE09()
Local aArea := GetArea()

//�����������������������������������������������������������������������������������Ŀ
//�Este ponto de entrada chama a fun��o que altera o status do titulo no contrato fin.�
//�������������������������������������������������������������������������������������
AGRA105H()

RestArea(aArea)
Return()
