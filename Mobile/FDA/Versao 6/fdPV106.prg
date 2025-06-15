/*   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �Regra de Bonif V. 2  �Autor - Paulo Lima   � Data �10/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Adiciona as Bonificacoes no Pedido      					  ���
���			 � 												 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SFA CRM 6.0                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCliente   -> Cod. do Cliente								  ���
���			 �cLoja      -> Loja do Cliente	 	     		   			  ���
���			 �cCond      -> Cond. de Pagto. 				   			  ���
���			 �cTab       -> Tabela de Preco					   			  ���
���			 �cFormPg    -> Forma de Pagto					   			  ���
���			 �aPedido    -> Array dos Itens do Pedido					  ���
���			 �       [1] -> Cod. do Produto do Item						  ���
���			 �       [2] -> Descricao do Produto						  ���
���			 �       [3] -> Grupo do Produto							  ���
���			 �       [4] -> Qtde. de Produtos do Item  					  ���
���			 �       [5] -> Cod. da Tabela de Preco 					  ���
���			 �       [6] -> Preco do Produto 							  ���
���			 �       [7] -> Desconto									  ���
���			 �       [8] -> Tes											  ���
���			 �       [9] -> Valor Total por Item						  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FtRgrBonus(xPar1,xPar2,cCliente,cLoja,cTabPreco,cCondPg,cFormPg)
Local aRetorno := {}
Local aPos     := {1,2,3}    //Posicao da Colunas no Array de Pedidos
Local aCopia   := {} 		 // Copia do Array do Pedido
Local aRemove  := {}        // Itens que serao removido conforme receberem a Bonificacao
Local aLote    := {}
Local aGrupos  := {}
Local cCursor  := "ACQ"
Local cCursor2 := "ACR"
Local cProduto := ""
Local cGrupo   := ""
Local lQuery   := .F.
Local lValido  := .F.
Local lBonific := .F.
Local lContinua:= .T.
Local nX       := 0
Local nY       := 0
Local nZ       := 0
Local nMult    := 0
Local nCabLote := 0
Local nSoma    := 0
Local nQuant   := 0
Local cCnt	   := ""
Local nRecs    := 0
Local nCnt	   := 1
Local cTesBonus :=""
//DEFAULT cProduto  := Space(Len(HB1->B1_COD))
//DEFAULT cCliente  := Space(Len(HA1->A1_COD))
//DEFAULT cLoja     := Space(Len(HA1->A1_LOJA))
//DEFAULT cTabPreco := Space(Len(HTC->TC_CODTAB))
//DEFAULT cCondPg   := Space(Len(HTC->TC_CONDPG))
//DEFAULT cFormPg   := Space(2)

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek("MV_BONUSTS")   

If Eof()
	lContinua:= .F.
Else
	cTesBonus:=HCF->CF_VALOR
	
	dbSelectArea("HF4")
	dbSetOrder(1)
	dbSeek(cTesBonus)
	if !Eof()
		lContinua:= .F.	
	Else
		If SubStr(cTesBonus,1,3)<="500" 
			lContinua := .F.
		Endif
	Endif	

	if !lContinua
		cTesBonus:=Nil
	Endif
	
Endif          

if lContinua
	For nX	:=	1	To Len(xPar1)
		If xPar1[nX][xPar2[aPos[3]]] <> cTesBonus
//			nPosProd	:=	Ascan(aCopia,{|x| x[1] == xPar1[nX][xPar2[1]]})
//			If nPosProd	> 0
//				aCopia[nPosProd][2]	+=	xPar1[nX][xPar2[2]]
//			Else
				AAdd(aCopia,{xPar1[nX][xPar2[aPos[1]]],xPar1[nX][xPar2[aPos[2]]],xPar1[nX][xPar2[aPos[3]]]})
//			Endif
		Endif
	Next

	dbSelectArea("ACQ")
	dbSetOrder(1)
    dbGotop()
	While !Eof()
		lValido:= .F.
		If ((HCQ->CQ_CODCLI == cCliente .Or. Empty(HCQ->CQ_CODCLI) ).And.;
				(HCQ->CQ_LOJA == cLoja .Or. Empty(HCQ->CQ_LOJA) ) .And.;
				(HCQ->CQ_CODTAB == cTabPreco .Or. Empty(HCQ->CQ_CODTAB) ) .And.;
				(HCQ->CQ_CONDPG == cCondPg .Or. Empty(HCQ->CQ_CONDPG) ) .And.;
				(HCQ->CQ_FORMPG == cFormPg .Or. Empty(HCQ->CQ_FORMPG) ) )
			lValido := .T.
		EndIf
		If lValido
			lBonific := .T.
			If HCQ->(FieldPos("CQ_LOTE"))>0
				nCabLote := Max(HCQ->CQ_LOTE,0)
			Endif
			dbSelectArea("ACR")
			dbSetOrder(1)
			aRemove := {}
			While ( !Eof() .And. HCQ->CQ_CODREG == HCR->CR_CODREG )
				If nCabLote == 0
					//������������������������������������������������������������������������Ŀ
					//�Busca por Produto                                                       �
					//��������������������������������������������������������������������������
//					nY := aScan(aCopia,{|x| x[aPos[1]]==HCR->CR_CODPRO .And. x[aPos[2]]>=IIf(nCabLote>0,nCabLote,HCR->CR_LOTE) .And. x[aPos[3]]<>cTesBonus })
					nY:=0
					For nY:=1 to Len(aCopia) 
						if aCopia[nY,aPos[1]]==HCR->CR_CODPRO .And. aCopia[nY,aPos[2]]>=IIf(nCabLote>0,nCabLote,HCR->CR_LOTE) .And. aCopia[nY, aPos[3]]<>cTesBonus 
							break
						Endif
					Next
					If nY > Len(aCopia)
						nY:=0
					Endif       
					
					//������������������������������������������������������������������������Ŀ
					//�Busca por Grupo                                                         �
					//��������������������������������������������������������������������������
					If nY == 0 .And. Empty(HCR->CR_CODPRO)
						For nX := 1 To Len(aCopia)
							cProduto := aCopia[nX][aPos[1]]
							//nY := aScan(aGrupos,{|x| x[1] == cProduto})
							nY:=0
							For nY:=1 to Len(aGrupos)
								if  aGrupos[nY,1] == cProduto   
							 		Break
							 	Endif
							Next
							if nY > Len(aGrupos)
								nY:=0
							Endif
							
							If nY == 0
								dbSelectArea("HB1")
								dbSetOrder(1)
								dbSeek(cProduto)
								cGrupo := HB1->B1_GRUPO
								aadd(aGrupos,{cProduto,cGrupo})
							Else
								cGrupo := aGrupos[nY][2]
							EndIf
							nY := 0
							If cGrupo == HCR->CR_GRUPO .And. aCopia[nX][aPos[2]]>=IIf(nCabLote>0,nCabLote,HCR->CR_LOTE)
								nY := nX
								Exit
							EndIf
						Next
					EndIf
					//������������������������������������������������������������������������Ŀ
					//�Avalia o tipo de Bonificacao                                            �
					//��������������������������������������������������������������������������
					//Se o tipo de bonificacao for "TODOS" e nao achei algum produto, zerar o aRemove e sair
					If nY <> 0 
					   	Aadd(aRemove,{nY,Int(aCopia[nY][aPos[2]] / HCR->CR_LOTE),HCR->CR_LOTE,aCopia[nY][aPos[2]]})
					ElseIf HCQ->CQ_TPRGBN <> "2"
						aRemove	:=	{}
						Exit
					EndIf
				Else
					Aadd(aLote,{HCR->CR_CODPRO,HCR->CR_GRUPO})
				EndIf
				
				dbSelectArea("HCR")
				dbSkip()
			EndDo

			dbSelectArea("HCQ")
			nQuant	:=	HCQ->CQ_QUANT
			
			//�������������������������������������������������������������������������������Ŀ
			//�Definir o multiplicador dependendo do tipo de bonificacao, se for tipo "TODOS",�
			//�pego o m�nimo multiplo, se for "SOMENTE UM" pego o maximo multiplo.            �
			//���������������������������������������������������������������������������������
			For nX:=	1	To	Len(aRemove)
				If HCQ->CQ_TPRGBN=="1"
					nMult	:=	If(nX==1,aRemove[1][2],Min(aRemove[nX][2],nMult))
				Else 
					nMult	:=	If(nX==1,aRemove[1][2],Max(aRemove[nX][2],nMult))
				Endif
			Next							                                         

			//������������������������������������������������������������������������Ŀ
			//�Avalia o tipo de Bonificacao                                            �
			//��������������������������������������������������������������������������
			If lBonific .And. Len(aRemove)>0
				For nX := 1 To Len(aRemove)   
					//��������������������������������������������������������������Ŀ
					//�Anular los items que foram usados em uma Regra de bonificacao �
					//�por lotes.                                                    �
					//����������������������������������������������������������������
					If nCabLote > 0
						aCopia[aRemove[nX][1]][aPos[2]]	:=	0
						nMult	:=	aRemove[nX][2]
					Else
						//���������������������������������������������������������������������������Ŀ
						//�Se o tipo de bonificacao for por "SOMENTE UM", vou dar bonificacao         �
						//�de acordo com o item que atingiu a maior bonificacao                       �
						//�����������������������������������������������������������������������������
						If HCQ->CQ_TPRGBN=="2" 
							If aRemove[nX][2] >= nMult
								aCopia[aRemove[nX][1]][aPos[2]] -= aRemove[nX][3] * nMult
								Exit
							Endif
						//���������������������������������������������������������������������������Ŀ
						//�Se o tipo de bonificacao for por "TODOS", vou dar bonificacao de acordo com�
						//�o item que limitou a bonificacao (nMult)                                   �
						//�����������������������������������������������������������������������������
						Else
							aCopia[aRemove[nX][1]][aPos[2]] -= aRemove[nX][3] * nMult
						Endif
					Endif
				Next
				Aadd(aRetorno,{HCQ->CQ_CODPRO, nMult * nQuant,cTesBonus,HCQ->CQ_CODREG})
			Endif			
        Endif
//		nY := aScan(aCopia,{|x| x[aPos[2]]>0 })

//		If nY == 0
//			Exit
//		EndIf
		dbSelectArea("HCQ")
		dbSkip()
	Enddo
Endif   
Return (aRetorno)     


Function FScan(aArray, nX, nY, cCond)
For nX:=1 to len(aArray)
	if aArray[nX,nY]==cCond
	     break
	endif
Next

if nX>len(aArray)
	nX:=0
Endif

Return nX