#INCLUDE "FDPV104.ch"

/*   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �Regra de Bonificacao �Autor - Paulo Lima   � Data �10/07/02 ���
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
���			 �aItePed    -> Array dos Itens do Pedido					  ���
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
��� Cleber     |25/04/03|  Alteracao na gravacao do preco de venda		  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

#include "eADVPL.ch"

Function RGAdcBon(cCliente, cLoja, cCond, cTab, cFormPg, aItePed)
Local cTesBon:=""
Local lMulti := .T., lBonif := .F.
Local I:=0 , nPrc:=0.00, nQtdeBonif :=0.00 , nQtde:=0.00, nQtdePed :=0.00
Local aBonif:= {}, aAuxPed := {}
Local cTable := "HCQ"+cEmpresa

If !File(cTable)
	MsgStop(STR0001 + cTable + STR0002,STR0003) //"Tabela de Regras de Bonif. "###" n�o encontrada!"###"Aviso"
	return nil
EndIf

// ---------------------------------------------------------------------------------
//   						TES DO ITEM DE BONIFICACAO
// ---------------------------------------------------------------------------------
dbSelectArea("HCF")
dbSetOrder(1)
dbSeek("MV_BONUSTS")   
if !(HCF->(Found()))
// ------------------------------------------------------------------------------------
//	Caso nao exista o MV_BONUSTS, ele nao incluirah os itens de Bonificacao
// ------------------------------------------------------------------------------------
	Return Nil           
else
	cTesBon:=AllTrim(HCF->CF_VALOR)
	dbSelectArea("HF4")
	dbSetOrder(1)
	dbSeek(cTesBon)
	if !(HF4->(Found()))
	// ------------------------------------------------------------------------------------
	//	Caso nao encontre o Tes de Bonus cadastrado, ele nao incluirah 
	//  os itens de Bonificacao
	// ------------------------------------------------------------------------------------
		Return Nil
	Endif

Endif          

dbSelectArea("HCQ")
dbSetOrder(1)
dbGoTop()

While !Eof()

	If ( (HCQ->ACQ_CODCLI = cCliente .Or. Empty(HCQ->ACQ_CODCLI) ).And.;
			(HCQ->ACQ_LOJA = cLoja .Or. Empty(HCQ->ACQ_LOJA) ) .And.;
			(HCQ->ACQ_CODTAB = cTab .Or. Empty(HCQ->ACQ_CODTAB) ) .And.;
			(HCQ->ACQ_CONDPG = cCond .Or. Empty(HCQ->ACQ_CONDPG) ) .And.; 
			(HCQ->ACQ_FORMPG = cFormPg .Or. Empty(HCQ->ACQ_FORMPG) ) )

	   dbSelectArea("HCR")
	   dbSetOrder(1)          
	   dbSeek(HCQ->ACQ_CODREG) 
	   
// ------------------------------------------------------------------
//      Se a bonificacao for para Todos os Itens
// ------------------------------------------------------------------			
       If HCQ->ACQ_TPRGBN == "1"
			nQtde:=0
			nQtdePed:=0                                  
			aSize(aAuxPed,0)
			lMulti:= .T.
			While !Eof() .And. HCR->ACR_CODREG = HCQ->ACQ_CODREG .And. lMulti
//				Alert("Entrou no Bonif. Item < Tipo 1> ")
				For I:=1 to Len(aItePed)
					If (HCR->ACR_CODPRO = aItePed[I,1] .Or.;
						HCR->ACR_GRUPO = aItePed[I,3]) .And.;
						HCR->ACR_LOTE <= aItePed[I,4] .And.;
						cTesBon <> aItePed[I,8] .And. Empty(aItePed[I,10])
						
						AADD(aAuxPed ,I)
						break
					Endif				  					
				Next
	
				If i>Len(aItePed)									
					// ----------------------------------------------------------------
					// Varremos todo o Pedido e nao encontramos essa situacao da Regra 
					// ----------------------------------------------------------------
					lMulti:=.F.
				else
					// ----------------------------------------------------------------
					// Encontrou a Condicao da Regra e continuaremos a verificar 
					// outros itens da regra.
					// ----------------------------------------------------------------
					lMulti:=.T.
					
//					nQtde:=nQtde + HCR->CR_LOTE
//					nQtdePed:=nQtdePed + aItePed[I,4]

					if aItePed[I,4] < nQtdePed .Or. nQtdePed=0
						nQtde:=HCR->ACR_LOTE
						nQtdePed:=aItePed[I,4]
        			Endif
				EndIf				
				dbSkip()
			Enddo

			if lMulti
				nQtdeBonif  := Int(nQtdePed / nQtde) * HCQ->ACQ_QUANT
				AADD(aBonif,{AllTrim(HCQ->ACQ_CODPRO),nQtdeBonif, cTab, cTesBon, HCR->ACR_CODREG})	
				For I:=1 to Len(aAuxPed)
				 	aItePed[aAuxPed[I],10] := HCQ->ACQ_CODREG  
				Next
    		Endif

// -------------------------------------------------------------------------------------
//      Se a bonificacao for para Cada Item
// -------------------------------------------------------------------------------------			
	   Else
		lBonif:=.F.
			While !Eof() .And. HCR->ACR_CODREG = HCQ->ACQ_CODREG .And. !lBonif
//				Alert("Entrou no Bonif. Item < Tipo 2> ")
				For I:=1 to Len(aItePed)

					// ----------------------------------------------------------
					//  Se encontrar a Condicao de Regra
					// ----------------------------------------------------------
					If ((HCR->ACR_CODPRO = aItePed[I,1] .Or.;
						HCR->ACR_GRUPO = aItePed[I,3]) .And.;
						HCR->ACR_LOTE <= aItePed[I,4] .And.;
						cTesBon <> aItePed[I,8] .And. Empty(aItePed[I,10]))

						nQtdeBonif  := Int(aItePed[I,4] / HCR->ACR_LOTE) * HCQ->ACQ_QUANT
						AADD(aBonif,{AllTrim(HCQ->ACQ_CODPRO),nQtdeBonif, cTab, cTesBon,HCR->ACR_CODREG}) 
						lBonif:= .T.
						aItePed[I,10]:= HCQ->ACQ_CODREG
						break
					Endif				  					
				Next								
				dbSkip()
			Enddo				

	    EndIf      	
	EndIf
	dbSelectArea("HCQ")
	dbSkip()
Enddo  

if Len(aBonif) > 0 
	// Copia para o Array do Pedido    
//	Alert("Copia do aBonif para aItePed")  
	RGCpBonPed(aItePed,aBonif,cTab)	
EndIf

Return Nil

Function RGCpBonPed(aItePed, aBonif, cTab)
Local I:=1, nPrc:=0.00, nSubTotI := 0.00
	For I:=1 to Len(aBonif)
		dbSelectArea("HB1")
		dbSetOrder(1) 
		dbSeek(Alltrim(aBonif[I,1]))                                                                     
		// Se Tab. de Preco estiver Vazia, coleta o Preco cadastrado no HB1
		//If !Empty(aBonif[I,4])
		If !Empty(aBonif[I,3])	//Tab. preco
			dbSelectArea("HPR")
			dbSetOrder(1)
			//dbSeek(HCQ->ACQ_CODPRO + cTab)
			dbSeek(Alltrim(aBonif[I,1]) + cTab)
			If !Eof()
				nPrc:=HPR->PR_UNI
				//Alert(aBonif[I,1] + cTab + " = " + str(nPrc))
			Else
				nPrc:=HB1->B1_PRV1			
				//Alert("Not found... " + str(nPrc))
			Endif
		Else
			nPrc:=HB1->B1_PRV1			
			//Alert(nPrc)
        Endif
		nSubTotI:=nPrc * aBonif[I,2]
//		Alert(aBonif[i,2])
    	AADD(aItePed,{aBonif[i,1], AllTrim(HB1->B1_DESC), AllTrim(HB1->B1_GRUPO), aBonif[i,2], aBonif[i,3], nPrc, 0, aBonif[i,4], nSubTotI, aBonif[I,5],1})
	Next
Return Nil

Function RGDuplBon(aBonif)
Local nX :=0, nI:=0

For nX:=1 to Len(aBonif)
    For nI:=(nX+1) to Len(aBonif)
		if aBonif[nX,1] == aBonif[nI,1]
		     //aBonif[nX,2]:=aBonif[nX,2]+aBonif[nY,2]
		     nI:=nI-1
		     aDel(aBonif,nI+1)
		     aSize(aBonif,len(aBonif)-1)
		Endif
    Next
Next
Return Nil