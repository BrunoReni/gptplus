#Include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DEMST     � Autor �  Sueli C. Santos      � Data � 19.03.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Declaracao de Estoque de Mercadorias no regime de ST -  	  ���
���          �Versao 02 - Decreto 45.390 de 12/12/07 - RS				  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD -> Data inicial do periodo - mv_par01     			  ���
���          �ExpD -> Data final do periodo - mv_par02                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
	
Function DEMST(dDtEst, cGrpIni, cGrpFim)
Local cAliasSB1	:= "SB1"
Local cAliasSF7	:= "SF7"
Local cAliasSFK	:= "SFK"
Local cUFEstST	:= SuperGetMV("MV_ESTADO",,"")

Local aTrbs		:= {} 
Local aGrTrib	:= {}

Local nValTotC 	:= 0
Local nValBaseC	:= 0
Local nValICMC 	:= 0
Local nValBaseV	:= 0
Local nValICMV 	:= 0 
Local nPos		:= 0
Local nX		:= 0
Local nAliq		:= 0
Local nMVICMPAD	:= SuperGetMV("MV_ICMPAD",,0)
Local nCont     := 0

Local lSB1EC	:= .F.
Local dDtIni   := mv_par01
Local dDtFim   := mv_par02

#IFDEF TOP
	Local aStruSB1	:= {} 
	Local aStruSF7	:= {} 	                                      
	Local aStruSFK	:= {}                                      
	Local lQuery	:= .F.  
	Local cQuery	:= ""
#ELSE
	Local cIndex	:= ""  
	Local cCondicao	:= ""
#ENDIF

//�������������������������������������Ŀ
//�Gera arquivos temporarios            �
//���������������������������������������
aTrbs := GeraTemp()
     
//�����������������������������Ŀ
//�Seleciona os produtos        �
//�������������������������������
dbSelectArea("SB1")
dbSetOrder(1)               
ProcRegua(LastRec())  

lSB1EC := Empty(SB1->(xFilial("SB1")))

If !(lSB1EC) // Se tabela SB1 for exclusiva pesquiso pelo SB1
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSB1	:= "SB1_DEST"
			aStruSB1	:= SB1->(dbStruct())
			cQuery		:= "SELECT B1_FILIAL, B1_COD, B1_GRUPO, B1_PICM, "
			cQuery    	+= "B1_PICMENT, B1_UPRC, B1_PRV1, B1_POSIPI, B1_DESC, B1_UM  "
			cQuery    	+= "FROM " + RetSqlName("SB1") + " "
			cQuery    	+= "WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND "
			cQuery 		+= "B1_PICMENT > 0 AND "
			cQuery 		+= "B1_GRUPO >= '" + cGrpIni + "' AND "  
			cQuery 		+= "B1_GRUPO <= '" + cGrpFim + "' AND "  
			cQuery 		+= "D_E_L_E_T_ = ' ' "
			cQuery 		+= "ORDER BY B1_FILIAL,B1_GRUPO,B1_COD "
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1)   
				
			For nX := 1 To len(aStruSB1)
				If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
					TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSB1)	
		Else
	#ENDIF
		    cIndex    := CriaTrab(NIL,.F.)
		    cCondicao := 'B1_FILIAL == "' + xFilial("SB1") + '" .And. '
		   	cCondicao += 'B1_PICMENT > 0 .And. '
		   	cCondicao += 'B1_GRUPO >= "' + cGrpIni + '" .And. '
		   	cCondicao += 'B1_GRUPO <= "' + cGrpFim + '" '
		    IndRegua(cAliasSB1,cIndex,SB1->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SB1")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SB1")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSB1)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF
	
	Do While !(cAliasSB1)->(Eof())
		
		//�������������������������������������������Ŀ
		//�Pesquisando saldo em estoque ST            �
		//���������������������������������������������
		#IFDEF TOP
			lQuery := .T.
			cAliasSFK := "AliasSFK"
			aStruSFK  := SFK->(dbStruct())
			cQuery := "SELECT FK_FILIAL,FK_PRODUTO,FK_DATA,"
			cQuery += "FK_AICMS,FK_QTDE,FK_BRICMS,FK_BASEICM "
			cQuery += "FROM "+RetSqlName("SFK")+" "
			cQuery += "WHERE FK_FILIAL='"+xFilial("SFK")+"' AND "
			cQuery += "FK_DATA>='"+Dtos(dDtIni)+"' AND "
			cQuery += "FK_DATA<='"+Dtos(dDtFim)+"' AND "   
			cQuery += "FK_PRODUTO = '"+ (cAliasSB1)->B1_COD +"' AND "
			cQuery += "D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(SFK->(IndexKey()))
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFK,.T.,.T.)
			
			For nX := 1 To Len(aStruSFK)
				If aStruSFK[nX][2] <> "C" .And. FieldPos(aStruSFK[nX][1])<>0
					TcSetField(cAliasSFK,aStruSFK[nX][1],aStruSFK[nX][2],aStruSFK[nX][3],aStruSFK[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSFK)	
   		#ELSE
			SFK->(dbSeek(xFilial("SFK")+(cAliasSB1)->B1_COD +dtos(dDtIni),.T.))
		#ENDIF 
		
		If !(cAliasSFK)->(Eof()) .AND. (cAliasSFK)->(FieldPos("FK_QTDE")) > 0 .And. (cAliasSFK)->FK_QTDE > 0
			//Verificando aliquota
			nAliq 		:= Iif((cAliasSB1)->B1_PICM<>0,(cAliasSB1)->B1_PICM,nMVICMPAD)
			//Calculo Valor Total - Compras
			nValTotC := (Iif((cAliasSB1)->(FieldPos("B1_UPRC")) > 0,(cAliasSB1)->B1_UPRC,0) * Iif((cAliasSFK)->(FieldPos("FK_QTDE")) > 0,(cAliasSFK)->FK_QTDE,0))
			//Calculo Base - Compras
			nValBaseC := (nValTotC * (1 + ((cAliasSB1)->B1_PICMENT/100)))
			//Calculo ICMS - Compras
			nValICMC := ((nValBaseC * nAliq) / 100)
			//Calculo Base - Vendas
			nValBaseV := (Iif((cAliasSB1)->(FieldPos("B1_PRV1")) > 0,(cAliasSB1)->B1_PRV1,0) * Iif((cAliasSFK)->(FieldPos("FK_QTDE")) > 0,(cAliasSFK)->FK_QTDE,0))
			//Calculo ICMS - Vendas
			nValICMV := ((nValBaseV * nAliq) / 100)
		
			//�������������������������������������������Ŀ
			//�Incluindo dados na Tabela RTE              �
			//���������������������������������������������
				
			dbSelectArea("RTE")
			RecLock("RTE",.T.)	 
			RTE->REG		:= "D1"
			RTE->GRUPO		:= (cAliasSB1)->B1_GRUPO
			RTE->NCM    	:= (cAliasSB1)->B1_POSIPI
			RTE->CODIGO  	:= (cAliasSB1)->B1_COD                    
			RTE->DESCR  	:= (cAliasSB1)->B1_DESC
			RTE->QTDADE  	:= Iif((cAliasSFK)->(FieldPos("FK_QTDE")) > 0,(cAliasSFK)->FK_QTDE,0)
			RTE->ALIQ  		:= nAliq
			RTE->VLUNITC  	:= Iif((cAliasSB1)->(FieldPos("B1_UPRC")) > 0,(cAliasSB1)->B1_UPRC,0)
			RTE->MVA  		:= (cAliasSB1)->B1_PICMENT
			RTE->VLTOTC  	:= nValTotC
			RTE->BASEC  	:= nValBaseC
			RTE->VLICMSC	:= nValICMC
			RTE->VLUNITV	:= Iif((cAliasSB1)->(FieldPos("B1_PRV1")) > 0,(cAliasSB1)->B1_PRV1,0)
			RTE->BASEV		:= nValBaseV
			RTE->VLICMSV	:= nValICMV  
			RTE->UNIDADE	:= (cAliasSB1)->B1_UM  
			MsUnlock() 
		Else  
		    //Se nao ha movimento, grava somente D0 e D9
		    IF ! RST->(dbSeek((cAliasSB1)->B1_GRUPO+"D0"))	
		     	RecLock("RST",.T.)
			    RST->REG        := "D0"
			    RST->GRUPO		:= (cAliasSB1)->B1_GRUPO
			    MsUnlock()
		    
			    If !RST->(dbSeek((cAliasSB1)->B1_GRUPO+"D9"))
				    RecLock("RST",.T.)	
			   	    RST->REG        := "D9"
			    	RST->GRUPO		:= (cAliasSB1)->B1_GRUPO
				    RST->TOTICM    	:= 0 // pelo validador ele soma os dois valores de ICMS.
				    MsUnlock() 
			    Endif
		    EndIf		  
		Endif          
		
		If !lQuery
			RetIndex("SFK")	
			dbClearFilter()	
			Ferase(cIndex+OrdBagExt()) 
		Else		
			dbSelectArea(cAliasSFK)
			dbCloseArea()
		Endif 
		(cAliasSB1)->(dbSkip())		           
	Enddo 
	
	//���������������������������������������Ŀ
	//�Exclui area de trabalho utilizada - SB1�
	//�����������������������������������������
	If !lQuery
		RetIndex("SB1")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSB1)
		dbCloseArea()
	Endif
Else // Se for compartilhado, pesquiso pelo SF7 - Excecoes Fiscais.
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF7	:= "SF7_DEST"
			aStruSF7	:= SF7->(dbStruct())
			cQuery		:= "SELECT F7_FILIAL, F7_GRTRIB, F7_EST, F7_MARGEM, "
			cQuery    	+= "F7_ALIQDST "
			cQuery    	+= "FROM " + RetSqlName("SF7") + " "
			cQuery    	+= "WHERE F7_FILIAL = '" + xFilial("SF7") + "' "
			cQuery 		+= "AND F7_EST = '"+ Alltrim(cUFEstST) + "' "
			cQuery 		+= "AND F7_MARGEM <> 0 "
			cQuery 		+= "AND D_E_L_E_T_ = ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF7->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF7)   
				
			For nX := 1 To len(aStruSF7)
				If aStruSF7[nX][2] <> "C" .And. FieldPos(aStruSF7[nX][1])<>0
					TcSetField(cAliasSF7,aStruSF7[nX][1],aStruSF7[nX][2],aStruSF7[nX][3],aStruSF7[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSF7)	
		Else
	#ENDIF
		    cIndex    := CriaTrab(NIL,.F.)
		    cCondicao := 'F7_FILIAL == "' + xFilial("SF7") + '" '
		   	cCondicao += '.And. F7_EST == "'+ Alltrim(cUFESTST) + '" '
		   	cCondicao += '.And. F7_MARGEM <> 0 '
		    IndRegua(cAliasSF7,cIndex,SF7->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF7")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF7")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF7)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF
	
	Do While !(cAliasSF7)->(Eof())

		nPos := aScan(aGrTrib,{|x| x[1] == (cAliasSF7)->F7_GRTRIB})
		If nPos == 0
			aadd(aGrTrib,{(cAliasSF7)->F7_GRTRIB,;					//1 - Grupo de Tributacao
						 (cAliasSF7)->F7_MARGEM,;					//2 - Margem de Lucro
						 (cAliasSF7)->F7_ALIQDST}) 					//3 - Aliquota Destino - ST

		Endif	
		(cAliasSF7)->(dbSkip())		           
	Enddo 

	If Len(aGrTrib)	> 0
		#IFDEF TOP    
		    If TcSrvType()<>"AS/400"
				lQuery		:= .T.
				cAliasSB1	:= "SB1_DEST"
				aStruSB1	:= SB1->(dbStruct())
				cQuery		:= "SELECT B1_FILIAL, B1_COD, B1_GRUPO, B1_PICM, B1_GRTRIB, "
				cQuery    	+= "B1_PICMENT, B1_UPRC, B1_PRV1, B1_POSIPI, B1_DESC, B1_UM "
				cQuery    	+= "FROM " + RetSqlName("SB1") + " "
				cQuery    	+= "WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND "
				cQuery 		+= "B1_GRUPO >= '" + cGrpIni + "' AND "  
				cQuery 		+= "B1_GRUPO <= '" + cGrpFim + "' AND "  
				cQuery 		+= "D_E_L_E_T_ = ' ' "
				cQuery 		+= "ORDER BY "+SqlOrder(SB1->(IndexKey()))
				cQuery 		:= ChangeQuery(cQuery)                       			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1)   
					
				For nX := 1 To len(aStruSB1)
					If aStruSB1[nX][2] <> "C" .And. FieldPos(aStruSB1[nX][1])<>0
						TcSetField(cAliasSB1,aStruSB1[nX][1],aStruSB1[nX][2],aStruSB1[nX][3],aStruSB1[nX][4])
					EndIf
				Next nX
				dbSelectArea(cAliasSB1)	
			Else
		#ENDIF
			    cIndex    := CriaTrab(NIL,.F.)
			    cCondicao := 'B1_FILIAL == "' + xFilial("SB1") + '" .And. '
			   	cCondicao += 'B1_GRUPO >= "' + cGrpIni + '" .And. '
			   	cCondicao += 'B1_GRUPO <= "' + cGrpFim + '" '   
			    IndRegua(cAliasSB1,cIndex,SB1->(IndexKey()),,cCondicao)
			    nIndex := RetIndex("SB1")
					
				#IFNDEF TOP
					dbSetIndex(cIndex+OrdBagExt())
				#ENDIF    
				dbSelectArea("SB1")
			    dbSetOrder(nIndex+1)
			    dbSelectArea(cAliasSB1)
			    ProcRegua(LastRec())
		    	dbGoTop()
		#IFDEF TOP
			Endif                                           
		#ENDIF
		
		Do While !(cAliasSB1)->(Eof())
			
			//�������������������������������������������Ŀ
			//�Verificando Grupo de Tributacao            �
			//���������������������������������������������
			nPos := aScan(aGrTrib,{|x| x[1] == (cAliasSB1)->B1_GRTRIB}) //Grupo de tributacao
			If nPos == 0
				(cAliasSB1)->(DbSkip())
				Loop								
			Endif			
			
			//�������������������������������������������Ŀ
			//�Pesquisando saldo em estoque ST            �
			//���������������������������������������������		

				#IFDEF TOP
					lQuery := .T.
					cAliasSFK := "AliasSFK"
					aStruSFK  := SFK->(dbStruct())
					cQuery := "SELECT FK_FILIAL,FK_PRODUTO,FK_DATA,"
					cQuery += "FK_AICMS,FK_QTDE,FK_BRICMS,FK_BASEICM "
					cQuery += "FROM "+RetSqlName("SFK")+" "
					cQuery += "WHERE FK_FILIAL='"+xFilial("SFK")+"' AND "
					cQuery += "FK_DATA>='"+Dtos(dDtIni)+"' AND "
					cQuery += "FK_DATA<='"+Dtos(dDtFim)+"' AND "   
					cQuery += "FK_PRODUTO = '"+ (cAliasSB1)->B1_COD +"' AND "
					cQuery += "D_E_L_E_T_=' ' "
					cQuery += "ORDER BY "+SqlOrder(SFK->(IndexKey()))
					
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFK,.T.,.T.)
					
					For nX := 1 To Len(aStruSFK)
						If aStruSFK[nX][2] <> "C" .And. FieldPos(aStruSFK[nX][1])<>0
							TcSetField(cAliasSFK,aStruSFK[nX][1],aStruSFK[nX][2],aStruSFK[nX][3],aStruSFK[nX][4])
						EndIf
					Next nX
					dbSelectArea(cAliasSFK)	
		   		#ELSE
					SFK->(dbSeek(xFilial("SFK")+(cAliasSB1)->B1_COD +dtos(dDtIni),.T.))
				#ENDIF 
				
			If !(cAliasSFK)->(Eof()) .AND. (cAliasSFK)->(FieldPos("FK_QTDE")) > 0 .And. (cAliasSFK)->FK_QTDE > 0
				//Verificando aliquota
				nAliq 		:= Iif(aGrTrib[nPos][3]<>0,aGrTrib[nPos][3],Iif((cAliasSB1)->B1_PICM<>0,(cAliasSB1)->B1_PICM,nMVICMPAD))
				//Calculo Valor Total - Compras
				nValTotC 	:= (Iif((cAliasSB1)->(FieldPos("B1_UPRC")) > 0,(cAliasSB1)->B1_UPRC,0) * Iif((cAliasSFK)->(FieldPos("FK_QTDE")) > 0,(cAliasSFK)->FK_QTDE,0))
				//Calculo Base - Compras
				nValBaseC 	:= (nValTotC * (1 + (aGrTrib[nPos][2]/100))) //Margem de Lucro
				//Calculo ICMS - Compras
				nValICMC 	:= ((nValBaseC * nAliq) / 100)
				//Calculo Base - Vendas
				nValBaseV 	:= (Iif((cAliasSB1)->(FieldPos("B1_PRV1")) > 0,(cAliasSB1)->B1_PRV1,0) * Iif((cAliasSFK)->(FieldPos("FK_QTDE")) > 0,(cAliasSFK)->FK_QTDE,0))
				//Calculo ICMS - Vendas
				nValICMV 	:= ((nValBaseV * nAliq) / 100)
			
				//�������������������������������������������Ŀ
				//�Incluindo dados na Tabela RTE              �
				//���������������������������������������������
			  		
				dbSelectArea("RTE")
				RecLock("RTE",.T.)	
				
				RTE->GRUPO		:= (cAliasSB1)->B1_GRUPO
				RTE->NCM    	:= (cAliasSB1)->B1_POSIPI
				RTE->CODIGO  	:= (cAliasSB1)->B1_COD                    
				RTE->DESCR  	:= (cAliasSB1)->B1_DESC
				RTE->QTDADE  	:= Iif((cAliasSFK)->(FieldPos("FK_QTDE")) > 0,(cAliasSFK)->FK_QTDE,0)
				RTE->ALIQ  		:= nAliq
				RTE->VLUNITC  	:= Iif((cAliasSB1)->(FieldPos("B1_UPRC")) > 0,(cAliasSB1)->B1_UPRC,0)
				RTE->MVA  		:= aGrTrib[nPos][2]
				RTE->VLTOTC  	:= nValTotC
				RTE->BASEC  	:= nValBaseC
				RTE->VLICMSC	:= nValICMC
				RTE->VLUNITV	:= Iif((cAliasSB1)->(FieldPos("B1_PRV1")) > 0,(cAliasSB1)->B1_PRV1,0)
				RTE->BASEV		:= nValBaseV
				RTE->VLICMSV	:= nValICMV   
				RTE->UNIDADE	:= (cAliasSB1)->B1_UM  
				MsUnlock() 
			Else
			    //Se nao ha movimento, grava somente D0 e D9
		        IF ! RST->(dbSeek((cAliasSB1)->B1_GRUPO+"D0"))	
		     	    RecLock("RST",.T.)
			        RST->REG        := "D0"
			        RST->GRUPO		:= (cAliasSB1)->B1_GRUPO
			        MsUnlock()
		    
			        If !RST->(dbSeek((cAliasSB1)->B1_GRUPO+"D9"))
				        RecLock("RST",.T.)	
			   	        RST->REG        := "D9"
			    	    RST->GRUPO		:= (cAliasSB1)->B1_GRUPO
				        RST->TOTICM    	:= 0 // pelo validador ele soma os dois valores de ICMS.
				        MsUnlock() 
			        Endif
		        EndIf		  
			Endif
			If !lQuery
				RetIndex("SFK")	
				dbClearFilter()	
				Ferase(cIndex+OrdBagExt()) 
			Else		
				dbSelectArea(cAliasSFK)
				dbCloseArea()
			Endif
			(cAliasSB1)->(dbSkip())		           
		Enddo 
		
		//���������������������������������������Ŀ
		//�Exclui area de trabalho utilizada - SB1�
		//�����������������������������������������
		If !lQuery
			RetIndex("SB1")	
			dbClearFilter()	
			Ferase(cIndex+OrdBagExt())
		Else
			dbSelectArea(cAliasSB1)
			dbCloseArea()
		Endif
	Endif

	//���������������������������������������Ŀ
	//�Exclui area de trabalho utilizada - SF7�
	//�����������������������������������������
	If !lQuery
		RetIndex("SF7")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF7)
		dbCloseArea()
	Endif
	
Endif

MontaArq()			
	
Return(aTrbs) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DMEST     � Autor �  Sueli C. Santos      � Data � 19.03.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Declaracao de Estoque de Mercadorias no regime de ST -  	  ���
���          �Versao 01 - Decreto 45.390 de 12/12/07 - RS				  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD -> Data inicial do periodo - mv_par01     			  ���
���          �ExpD -> Data final do periodo - mv_par02                    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MontaArq()
Local cGrupo := ""

dbSelectArea("RTE")

RTE->(dbGoTop())
dbSetOrder(1)

	Do While !RTE->(Eof()) 
				
		IF ! RST->(dbSeek(RTE->GRUPO+"D0"))	
			RecLock("RST",.T.)
			RST->REG        := "D0"
			RST->GRUPO		:= RTE->GRUPO
			MsUnlock()
		EndIf
		
		RecLock("RST",.T.)
		RST->REG        := "D1"
		RST->GRUPO		:= RTE->GRUPO
		RST->NCM    	:= RTE->NCM
		RST->CODIGO  	:= RTE->CODIGO
		RST->DESCR  	:= RTE->DESCR
		RST->QTDADE  	:= RTE->QTDADE
		RST->UNIDADE    := RTE->UNIDADE
		RST->ALIQ  		:= RTE->ALIQ
		RST->VLUNITC	:= RTE->VLUNITC
		RST->MVA  		:= RTE->MVA
		RST->VLTOTC  	:= RTE->VLTOTC
		RST->BASEC  	:= RTE->BASEC
		RST->VLICMSC	:= RTE->VLICMSC
		MsUnlock() 
		
		RecLock("RST",.T.)
		RST->REG        := "D2"
		RST->GRUPO		:= RTE->GRUPO
		RST->NCM    	:= RTE->NCM
		RST->CODIGO  	:= RTE->CODIGO
		RST->DESCR  	:= RTE->DESCR
		RST->QTDADE  	:= RTE->QTDADE
		RST->UNIDADE    := RTE->UNIDADE
		RST->ALIQ  		:= RTE->ALIQ  
		RST->VLUNITV	:= RTE->VLUNITV
		RST->BASEV		:= RTE->BASEV
		RST->VLICMSV	:= RTE->VLICMSV  
		MsUnlock()  
		
	
		If !RST->(dbSeek(RTE->GRUPO+"D9"))
			RecLock("RST",.T.)	
			RST->REG        := "D9"
			RST->GRUPO		:= RTE->GRUPO
			RST->TOTICM    	:= RTE->VLICMSV + RTE->VLICMSC // pelo validador ele soma os dois valores de ICMS.
			MsUnlock() 
		Else
			RecLock("RST",.F.)	
			RST->TOTICM    	+= RTE->VLICMSV + RTE->VLICMSC			
			MsUnlock() 
		Endif
			
		cGrupo := RTE->GRUPO
		
	RTE->(dbskip())  
End	


 Return()

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �GeraTemp   � Autor �Luciana Pires          � Data � 19.03.08 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Gera arquivos temporarios                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function GeraTemp()
Local aStru		:= {}
Local aTrbs		:= {}
Local cArq		:= ""
	
//�������������������������������������������������������������������������������������������Ŀ
//�Registros - Produto com MVA / Preco de Tabela										      �
//���������������������������������������������������������������������������������������������
aStru	:= {}
cArq	:= "" 
AADD(aStru,{"REG"	    	,"C",002,0})
AADD(aStru,{"GRUPO"	    	,"C",TamSX3("B1_GRUPO")[1],0})	//Grupo do Produto
AADD(aStru,{"NCM"		    ,"C",008,0})					//NCM do Produto
AADD(aStru,{"CODIGO"		,"C",TamSX3("B1_COD")[1],0})   //Codigo do Produto
AADD(aStru,{"DESCR"  		,"C",050,0})   	//Descricao do Produto
AADD(aStru,{"QTDADE"       	,"N",007,0}) 	//Quantidade em estoque na data de referencia
AADD(aStru,{"ALIQ"	    	,"N",005,2}) 	//Aliquota do Produto
AADD(aStru,{"VLUNITC"    	,"N",015,2})	//Valor Unitario de compra do produto
AADD(aStru,{"MVA"     		,"N",005,2})	//Margem de Valor Agregado
AADD(aStru,{"VLTOTC"  		,"N",015,2})	//Valor total a preco de compra
AADD(aStru,{"BASEC"  		,"N",015,2})	//Base de Calculo - Compra
AADD(aStru,{"VLICMSC"  		,"N",015,2})	//Valor ICMS - Compra
AADD(aStru,{"VLUNITV"    	,"N",015,2})	//Preco de venda tabelado do produto
AADD(aStru,{"BASEV"  		,"N",015,2})	//Base de Calculo - Venda
AADD(aStru,{"VLICMSV"  		,"N",015,2})	//Valor ICMS - Venda
AADD(aStru,{"UNIDADE"  		,"C",006,2})	//Unidade de Medida

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"RTE")                      	
IndRegua("RTE",cArq,"GRUPO+CODIGO")
AADD(aTrbs,{cArq,"RTE"})

aStru	:= {}
cArq	:= ""               
AADD(aStru,{"REG"	    	,"C",002,0})
AADD(aStru,{"GRUPO"	    	,"C",TamSX3("B1_GRUPO")[1],0})	//Grupo do Produto
AADD(aStru,{"NCM"		    ,"C",008,0})					//NCM do Produto
AADD(aStru,{"CODIGO"		,"C",TamSX3("B1_COD")[1],0})   //Codigo do Produto
AADD(aStru,{"DESCR"  		,"C",050,0})   	//Descricao do Produto
AADD(aStru,{"QTDADE"       	,"N",007,0}) 	//Quantidade em estoque na data de referencia
AADD(aStru,{"ALIQ"	    	,"N",005,2}) 	//Aliquota do Produto
AADD(aStru,{"VLUNITC"    	,"N",015,2})	//Valor Unitario de compra do produto
AADD(aStru,{"MVA"     		,"N",005,2})	//Margem de Valor Agregado
AADD(aStru,{"VLTOTC"  		,"N",015,2})	//Valor total a preco de compra
AADD(aStru,{"BASEC"  		,"N",015,2})	//Base de Calculo - Compra
AADD(aStru,{"VLICMSC"  		,"N",015,2})	//Valor ICMS - Compra
AADD(aStru,{"VLUNITV"    	,"N",015,2})	//Preco de venda tabelado do produto
AADD(aStru,{"BASEV"  		,"N",015,2})	//Base de Calculo - Venda
AADD(aStru,{"VLICMSV"  		,"N",015,2})	//Valor ICMS - Venda
AADD(aStru,{"UNIDADE"  		,"C",006,2})	//Unidade de Medida
AADD(aStru,{"TOTICM"		,"N",015,2})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"RST")                      	
IndRegua("RST",cArq,"GRUPO+REG")
AADD(aTrbs,{cArq,"RST"})

Return(aTrbs)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �DECESTDel   �Autor  �Luciana Pires       � Data � 19.03.208   ���
���������������������������������������������������������������������������͹��
���Desc.     �Deleta os arquivos temporarios processados                    ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �DECESTST                                                      ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/         
Function DEMSTDel(aDelArqs)
Local aAreaDel := GetArea()
Local nI := 0
	
For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[nI,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[nI,1]+GetDBExtension())
		Ferase(aDelArqs[nI,1]+OrdBagExt())
	Endif	
Next
RestArea(aAreaDel)	

Return()
	
