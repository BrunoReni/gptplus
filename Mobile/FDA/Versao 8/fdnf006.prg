#INCLUDE "FDnf006.ch"

//Recalcula os itens da Nota na troca da cond. de pagto (inteligente)
Function NFRecalcula(aCabNot,aObj,aColIte,aIteNot,nTelaPed) 
Local ni := 1, nIteNot := 0
Local nVlrItem := 0

If Len(aIteNot) > 0 

	  MsgStatus(STR0001) //"Alterando pedido, aguarde..."
      
      //Zera totais do cabec. do pedido 
      aCabNot[15,1] := 0
      //aCabNot[12,1] := 0        
      nIteNot:=Len(aIteNot)

      For ni := 1 to Len(aIteNot) 
	      
          dbSelectArea("HPR")
       	  dbSetOrder(1)
                  dbSeek(RetFilial("HPR")+aIteNot[ni,1]+aCabNot[7,1])    //Procura pre�o de venda usando a nova tabela
			
		  If !Eof()                        
                     aIteNot[ni,7] := HPR->HPR_UNI
		  Else           
			 dbSelectArea("HB1")
			 dbSetOrder(1)
                         dbSeek(RetFilial("HB1")+aIteNot[ni,1])     
                         aIteNot[ni,7] := HB1->HB1_PRV1
		  Endif                                 
		  // Atualiza tabela de pre�o
                  aIteNot[ni,5] := aCabNot[8,1]
     	  // Atualiza Valor do Item (SubTotal)
              aIteNot[ni,9] := aIteNot[ni,4] * aIteNot[ni,6]
	      //Limpa o descto
              aIteNot[ni,7] := 0
	      // Verifica/aplica a regra de desconto para o item
              RGAplDescIte(aCabNot[3,1], aCabNot[4,1], aCabNot[7,1], aCabNot[8,1], "", aIteNot, ni, aColIte)
	                
	      // Recalcula total do pedido
              if aIteNot[ni,7] > 0
                          nVlrItem := PVCalcDescto(aColIte,aIteNot,ni,.F.)
                          aCabNot[11,1] := aCabNot[11,1] + nVlrItem
		  else
                  aCabNot[15,1] := aCabNot[15,1] + aIteNot[ni,9]
		  endif
              aCabNot[12,1] := Round(aCabNot[11,1],2) 

	  Next                             
	  
	  ClearStatus()
	  If nTelaPed == 1
                  SetArray(aObj[3,1],aIteNot)   //Browse de itens
	  Endif
          SetText(aObj[1,4],aCabNot[12,1]) //Total
Endif

Return nil         


/*   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �Condicao Inteligente �Autor - Cleber M.    � Data �21/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Preenche a tabela de preco de acordo com a cond. de pagto  ���
���			 � selecionada (usando a tab. de Regras de Neg.)			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SFA CRM 6.0.1                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCliente   -> Cod. do Cliente								  ���
���			 �cLoja      -> Loja do Cliente	 	     		   			  ���
���			 �cCond      -> Cond. de Pagto. 				   			  ���
���			 �(Retorna a tabela de preco encontrada)					  ���
���			 �															  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function NFCondInt(cCliente,cLoja,cCond)
Local lContinua := .T.
Local cTab := ""

dbSelectArea("HCS")
dbSetOrder(1)
dbGoTop()

While !Eof() .And. lContinua

	If (HCS->HCS_CODCLI = cCliente .Or. Empty(HCS->HCS_CODCLI) ).And.;
			(HCS->HCS_LOJA = cLoja .Or. Empty(HCS->HCS_LOJA) )
			
			HCT->( dbSetOrder(3) )	//Cod. da Regra + Cond. Pagto.
			HCT->( dbSeek(RetFilial("HCT")+HCS->HCS_CODREG+cCond) )
			If HCT->(Found())
				cTab := HCT->HCT_CODTAB
				lContinua := .F.
				break
			Endif
    Endif
    
    dbSelectArea("HCS")
    dbSkip()
Enddo

Return cTab


Function NFTpFrete(aCabNot, aTpFrete, nOpcFre)
        aCabNot[43,1] := Substr(aTpFrete[nOpcFre],1,1)
Return Nil
