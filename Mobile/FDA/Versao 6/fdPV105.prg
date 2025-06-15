#INCLUDE "FDPV105.ch"

/*   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �Regra de Negocio     �Autor - Paulo Lima   � Data �10/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Verifica se o Pedido esta obedecendo a Regra de Negocio    ���
���			 � 												 			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SFA CRM 6.0.1                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCliente   -> Cod. do Cliente								  ���
���			 �cLoja      -> Loja do Cliente	 	     		   			  ���
���			 �cCond      -> Cond. de Pagto. 				   			  ���
���			 �cTab       -> Tabela de Preco					   			  ���
���			 �cFormPg    -> Forma de Pagto (nao esta sendo usado)		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RGVrfNeg(cCliente, cLoja, cCond, cTab, cFormPg)
Local lRegra := .T. 
Local lExce := .F. 
Local cTable := "HCS"+cEmpresa
Local lContinua := .T.

If !File(cTable)
	MsgStop(STR0001 + cTable + STR0002,STR0003) //"Tabela de Regras de Neg�cio "###" n�o encontrada!"###"Aviso"
	return nil
EndIf

dbSelectArea("HCS")
dbSetOrder(1)
dbGoTop()
While !Eof() .And. lContinua //.And. lRegra .And. !lExce 

	If (HCS->ACS_CODCLI = cCliente .Or. Empty(HCS->ACS_CODCLI) ).And.;
			(HCS->ACS_LOJA = cLoja .Or. Empty(HCS->ACS_LOJA) )
        //Alert("Entrou...")
		dbSelectArea("HCT")
		dbSetOrder(1)
	   	dbSeek(HCS->ACS_CODREG)
        While !Eof() .And. HCT->ACT_CODREG = HCS->ACS_CODREG
        	//Alert(HCT->ACT_ITEM)
			if HCT->ACT_TPRGNG = "1"
				if (HCT->ACT_CODTAB = cTab .Or. Empty(HCT->ACT_CODTAB)) .And.;
				(HCT->ACT_CONDPG = cCond .Or. Empty(HCT->ACT_CONDPG)) 
				//.And.;(HCT->ACT_FORMPG = cFormPg .Or. Empty(HCT->ACT_FORMPG))
					lRegra:=.T.
					//Alert("1")
					lContinua := .F.
					break //sair do loop
				Else
					if (HCT->ACT_CODTAB = cTab .Or. Empty(HCT->ACT_CODTAB))
						if (HCT->ACT_CONDPG <> cCond .And. !Empty(HCT->ACT_CONDPG)) 
						//.Or.;	(HCT->ACT_FORMPG <> cFormPg .And. !Empty(HCT->ACT_FORMPG))
								lRegra := .F.
								//Alert("2")
								dbskip()
								Loop
						Endif
					Else
						if (HCT->ACT_CONDPG = cCond .Or. Empty(HCT->ACT_CONDPG))
							if (HCT->ACT_CODTAB <> cTab .And. !Empty(HCT->ACT_CODTAB))
						//if (HCT->ACT_CONDPG = cCond .And. Empty(HCT->ACT_CONDPG)) .Or.;
						//(HCT->ACT_FORMPG = cFormPg .And. Empty(HCT->ACT_FORMPG))
								lRegra := .F.
								//Alert("3")
								dbskip()
								Loop
							endif
						else
							lRegra := .F.
							//Alert("2 Diferentes!")
							dbskip()
							Loop
						endif
					EndIf
					
					lRegra:= .T.
					//Alert("4")
					//Alert(lRegra)      
					lContinua := .F.
					break //sair do loop
				EndIf	
			Else
				if (HCT->ACT_CODTAB = cTab .Or. Empty(HCT->ACT_CODTAB)) .And.;
				(HCT->ACT_CONDPG = cCond .Or. Empty(HCT->ACT_CONDPG)) 
				//.And.;(HCT->ACT_FORMPG = cFormPg .Or. Empty(HCT->ACT_FORMPG))
					lExce:=.T.
					//Alert("5")
					lContinua := .F.
					break //sair do loop
				Else
					if (HCT->ACT_CODTAB = cTab .Or. Empty(HCT->ACT_CODTAB))
						if (HCT->ACT_CONDPG <> cCond .And. !Empty(HCT->ACT_CONDPG)) 
						//.Or.;(HCT->ACT_FORMPG <> cFormPg .And. !Empty(HCT->ACT_FORMPG))
								lExce := .F.  
								//Alert("6")
								dbskip()
								Loop
						Endif
					Else  
						if (HCT->ACT_CONDPG = cCond .Or. Empty(HCT->ACT_CONDPG))
							if (HCT->ACT_CODTAB <> cTab .And. !Empty(HCT->ACT_CODTAB))
						//if (HCT->ACT_CONDPG = cCond .And. Empty(HCT->ACT_CONDPG)) .Or.;
						//(HCT->ACT_FORMPG = cFormPg .And. Empty(HCT->ACT_FORMPG))
								lExce := .F.
								//Alert("7")
								dbskip()
								Loop
							endif
						else
							lExce := .F.
							//Alert("2 Diferentes!")
							dbskip()
							Loop
						Endif					
					EndIf
					
					lExce:= .T.        
					//Alert("8")
					lContinua := .F.
					break//sair do loop
				EndIf	
			Endif
			dbSelectArea("HCT")
			dbSkip()
		Enddo
	Endif
	dbSelectArea("HCS")
	dbSkip()
Enddo

//Alert("Fim...")
//Alert(lRegra)
//Alert(lExce)

if lRegra .And. !lExce
	Return .T.     
Else
   MsgStop(STR0004,STR0005)  //"Essa venda n�o pode ser efetuada, pois condi��es comerciais diferem das condi��es permitidas pela Regra de Neg�cio da Empresa"###"Regra de Neg�cio"
Endif

Return .F.

/*   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �Regra de Desconto    �Autor - Paulo Lima   � Data �10/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Aplica o descto no item caso o mesmo esteja dentro da regra ���
���			 � 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SFA CRM 6.01                                               ���
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
���			 �nItePed	 -> Indice (elemento) do array aItePed		  	  ��� 
���			 �aColIte	 -> Array c/ dados do Item corrente				  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Analista    � Data   �Motivo da Alteracao                              ���
�������������������������������������������������������������������������Ĵ��
��� Cleber M.  �28/04/03�		Melhorias								  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function RGAplDescIte(cCliente, cLoja, cCond, cTab, cFormPg, aItePed, nItePed, aColIte)
Local I:=0
Local lDesc := .T.
Local cTable := "HCO"+cEmpresa

If !File(cTable)
	MsgStop(STR0006 + cTable + STR0002,STR0003) //"Tabela de Regras de Desconto "###"Aviso" //" n�o encontrada!"
	return nil
EndIf

dbSelectArea("HCO")
dbSetOrder(1)
dbGoTop()

While !Eof()

	If ((HCO->ACO_CODCLI = cCliente .Or. Empty(HCO->ACO_CODCLI) ).And.;
			(HCO->ACO_LOJA = cLoja .Or. Empty(HCO->ACO_LOJA) ) .And.;
			(HCO->ACO_CODTAB = cTab .Or. Empty(HCO->ACO_CODTAB) ) .And.;
			(HCO->ACO_CONDPG = cCond .Or. Empty(HCO->ACO_CONDPG) ) .And.; 
			(HCO->ACO_FORMPG = cFormPg .Or. Empty(HCO->ACO_FORMPG) ) )

	   	dbSelectArea("HCP")
	   	dbSetOrder(2)          
		dbGoTop()
		dbSeek(HCO->ACO_CODREG)
	   	//dbSeek(HCP->ACP_CODREG) 

		lDesc := .F.
  		While !Eof() .And. HCP->ACP_CODREG = HCO->ACO_CODREG .And. !lDesc
			// -----------------------------------------------------------------------
			//  Varrer em todo o Pedido      (Nao estah em uso!!)
			// -----------------------------------------------------------------------
			If nItePed=0
				For I:=1 to Len(aItePed)
					// ---------------------------------------------------------------
					//  Se encontrar a Condicao de Regra
					// ---------------------------------------------------------------
					If ((HCP->ACP_CODPRO = aItePed[I,1] .Or.;
						HCP->ACP_GRUPO = aItePed[I,3]) .And.;
						HCP->ACP_FAIXA >= aItePed[I,4] .And. Empty(aItePed[I,10]))
						lDesc:= .T.
						//aItePed[I,10]	:= HCO->ACO_CODREG
						aItePed[I,7] 	:= HCP->ACP_PERDES
						break
					Endif				  					
				Next								
			// -----------------------------------------------------------------------
			//  Executar no Item Corrente
			// -----------------------------------------------------------------------
			Else
				If ((HCP->ACP_CODPRO = aItePed[nItePed,1] .Or.;
					HCP->ACP_GRUPO = aItePed[nItePed,3]) .And.;
					HCP->ACP_FAIXA >= aItePed[nItePed,4] .And. Empty(aItePed[nItePed,10]) .And.;
					HCP->ACP_PERDES > aItePed[nItePed,7])
						aItePed[nItePed,7] := HCP->ACP_PERDES
						aColIte[7,1] := HCP->ACP_PERDES
						break
		        Endif
			Endif
			dbSkip()
		Enddo				
    Endif
    dbSelectArea("HCO")
    dbSkip()
Enddo
Return Nil


//Aplica regra de desconto por faixa (total) de pedido
Function RGDescTotPed(cCliente, cLoja, cCond, cTab, cFormPg, nTotPed, nDescPed)
Local cTable := "HCO"+cEmpresa

If !File(cTable)
	MsgStop(STR0006 + cTable + STR0002,STR0003) //"Tabela de Regras de Desconto "###" n�o encontrada!"###"Aviso"
	return nil
EndIf

dbSelectArea("HCO")
dbSetOrder(1)
dbGoTop()

While !Eof()

	If ((HCO->ACO_CODCLI = cCliente .Or. Empty(HCO->ACO_CODCLI) ).And.;
			(HCO->ACO_LOJA = cLoja .Or. Empty(HCO->ACO_LOJA) ) .And.;
			(HCO->ACO_CODTAB = cTab .Or. Empty(HCO->ACO_CODTAB) ) .And.;
			(HCO->ACO_CONDPG = cCond .Or. Empty(HCO->ACO_CONDPG) ).And.; 
			(HCO->ACO_FORMPG = cFormPg .Or. Empty(HCO->ACO_FORMPG) ) .And.;
			(HCO->ACO_FAIXA >= nTotPed ) )

			nDescPed:= nTotPed * (HCO->ACO_PERDES / 100)			
         	break
	Endif
  	dbSkip()
Enddo

Return Nil