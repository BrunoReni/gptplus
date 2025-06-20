/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  |M100ICE   � Autor �Liber De Esteban       � Data �26.05.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao da base, aliquota e calculo do ICE               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros|cCalculo -> Solicitacao da MATXFIS, podendo ser A (aliquota)���
���          � B (base) ou V (valor)                                      ���
���          �nItem -> Item do documento fiscal                           ���
���          �aInfo -> Array com a seguinte estrutura: {cCodImp,nCpoLVF}  ���
�������������������������������������������������������������������������Ĵ��
���         Atualizacoes efetuadas desde a codificacao inicial            ���
�������������������������������������������������������������������������Ĵ��
���Programador� Data   �   BOPS   �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Oscar G.   �15/10/18�DMINA-3756�Base de c�lculo sin restar descuentos. ���
���           �        �          �ECU                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function M100ICE(cCalculo,nItem,aInfo)
	
Local aImposto
Local xRet

Local lCalc		:= .F.
Local aItemINFO := {}
Local aArea 	:= GetArea()
Local aAreaSFC 	:= GetArea("SFC")
Local dDataMov	:= dDataBase
Local cCfo		:= ""
Local cModo		:= ""
Local cUnid		:= ""
Local nOrdSFF	:= 1
Local nBase   	:= 0
Local nAliq		:= 0
Local nValICE	:= 0
Local nMerm		:= 0
Local nQtd 		:= 0

If cPaisLoc == 'EQU'
	xRet:=M100ICEQU(cCalculo,nItem,aInfo)
Else
	If SB1->(FieldPos("B1_PARTAR")) == 0
		Return 0
	EndIf
	
	If MaFisFound()
		lXFis := .T.
		lCalc := .T.
	ElseIf ProcName(1)=="EXECBLOCK"
		lXFis := .F.
		lCalc := .T.
	Else
		xRet  := 0
		lCalc := .F.
	EndIF
	
	If lCalc
		If lXFis
			nBase	:= MaFisRet(nItem,"IT_VALMERC")
			cCfo	:= MaFisRet(nItem,"IT_CF")
			nQtd 	:= MaFisRet(nItem,"IT_QUANT")
			If Type('dDEmissao') == "D" .AND. !Empty(dDEmissao)
				dDataMov	:=	dDEmissao
			Endif
			cTes 	:= MaFisRet(nItem,"IT_TES")
			cProd 	:= MaFisRet(nItem,"IT_PRODUTO")
			cInfo	:= aInfo[1]
		Else
	
			aItemINFO 		:= AClone( ParamIxb[1] )
			aImposto		:= AClone( ParamIxb[2] )
			aImposto[11]	:= aItemINFO[4]      // Rateio do Frete
			aImposto[4]		:= aItemINFO[5]      // Rateio de Despesas
			aImposto[3]		:= aItemINFO[3]+aItemINFO[4]+aItemINFO[5] // Base de Calculo
			
			
			xRet	 	 	:= aImposto
			nBase	 	 	:= aImposto[3]
			If Subs(aImposto[5],4,1) == "S"  .And. Len(aImposto) >= 18 .And. ValType(aImposto[18])=="N"
				nBase -= aImposto[18]
			EndIf
			
			nQtd 	 := aItemINFO[1]
			cInfo	 := aImposto[1]
			cProd 	 := aImposto[16]
			cTes 	 := SF4->F4_CODIGO
			cCfo 	 := SF4->F4_CF
			
		EndIf
	
		nOrdSFF	:= IIF(Substr(cCfo,1,1)>="5",16,15)
		//�����������������������Ŀ
		//� Calculo do imposto    �
		//�������������������������
		dbSelectArea("SFC")
		SFC->(DbSetOrder(2))
		dbSelectArea("SFF")
		SFF->(DbSetOrder(nOrdSFF))
		dbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		
		If	(SFC->(DbSeek(xFilial("SFC")+cTes+cInfo))) .And.;
			(SB1->(DbSeek(xFilial("SB1")+cProd))) .And. !Empty(SB1->B1_PARTAR)
			
			If !(SFF->(DbSeek(xFilial("SFF")+SB1->B1_PARTAR+cCfo)))
				(SFF->(DbSeek(xFilial("SFF")+SB1->B1_PARTAR)))
				cCfo := "*"
			EndIf

			If (SFC->(MsSeek(xFilial("SFC")+cTes+cInfo)))
				If SFC->FC_BASE > 0
					nBase  := nBase  * (1 - SFC->FC_BASE / 100)
				Endif
			EndIf
			
			If SFF->(Found())
				lCalc := .F.
				While !SFF->(EOF()) .And. xFilial("SFF") == SFF->FF_FILIAL .And. SB1->B1_PARTAR == SFF->FF_PARTAR
					If	(dDataMov >= SFF->FF_DTDE .And. ( dDataMov <= SFF->FF_DTATE .Or. Empty(SFF->FF_DTATE) )) .And.;
						(cCfo $ "*/"+SFF->FF_CFO_C+"/"+SFF->FF_CFO_V) .And. cInfo == SFF->FF_IMPOSTO
						cModo := SFF->FF_MODO
						nAliq := SFF->FF_ALIQ
						nMerm := SFF->FF_MERMA
						cUnid := SFF->FF_UNIDAD
						lCalc := .T.
					EndIf
					SFF->(dbSkip())
				EndDo
				//
				If lCalc
					If cModo == "V"
						If nMerm > 0
							nAliq := nAliq * (1-nMerm)
						EndIf
						If cUnid == "2" .And. !Empty(SB1->B1_SEGUM)
							//Obtem a relacao com a unidade de medida
							nQtd := ConvUm(SB1->B1_COD,nQtd,0,2)
						EndIf
						
						nValICE := nQtd * nAliq
					Else
						nValICE := nBase * (nAliq / 100)
					EndIf
	
					//�����������������������Ŀ
					//� Definicao do retorno  �
					//�������������������������
					If lXFis
					
						If cCalculo == "B"
							xRet := nBase
						ElseIf cCalculo == "A"
							xRet := nAliq
						ElseIf cCalculo == "V"
							xRet := nValICE
						EndIf
						
					Else
					
						aImposto[3]	:= nBase
						aImposto[2]	:= nAliq
						aImposto[4]	:= nValICE
						xRet:=aImposto
						
					EndIf
					
				EndIf
			EndIf
		Else
			nValICE := nBase * (nAliq / 100)
			If lXFis
				If cCalculo == "B"
					xRet := nBase
				ElseIf cCalculo == "A"
					xRet := nAliq
				ElseIf cCalculo == "V"
					xRet := nValICE
				EndIf
			Else
				aImposto[3]	:= nBase
				aImposto[2]	:= nAliq
				aImposto[4]	:= nValICE
				xRet:=aImposto
				
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaSFC)
EndIf	
Return(xRet)

If ProcName(1)=="EXECBLOCK"
	aImposto := ExecBlock( "M100ICE",.F.,.F., ParamIxb ,.T. )
	//
	Return aImposto
	//
EndIf

Return M100ICE(cCalculo,nItem,aInfo)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |M100ICEQU �Autor  �Renato Nagib        � Data �  14/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Rotina para calculo do ICE para o Equador                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                     Equador                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100ICEQU(cCalculo,nItem,aInfo)

	Local lXFis
	Local lCalc
	Local xRet
	Local cProd
	Local nValMerc
	Local nBase
	Local nAliq
	Local nValImp
	Local aItemSD1
	Local aImposto	

	If MaFisFound()
		lXFis := .T.
		lCalc := .T.
	ElseIf ProcName(1)=="EXECBLOCK"
		lXFis := .F.
		lCalc := .T.
	Else
		xRet  := 0
		lCalc := .F.
	EndIF
	
	If lCalc
		
		//Calculo utilizando para rotina manual
		If lXFis
			If cCalculo == 'B'
				nValMerc:= MaFisRet(nItem,"IT_VALMERC")
				nBase:=nValMerc
				xRet:=nBase
			Else
				cProd 	:= MaFisRet(nItem,"IT_PRODUTO")
				dbSelectArea('SB1')
				dbSetOrder(1)
				If dbSeek(xFilial('SB1')+cProd)
					If SB1->B1_ALIQICE > 0
						nAliq:=SB1->B1_ALIQICE
					Else	
						dbSelectArea('SFB')
						dbSetOrder(1)
						If dbSeek(xFilial('SFB')+aInfo[1])
							nAliq:=SFB->FB_ALIQ
						EndIf
					EndIf
				EndIf
				
				If cCalculo == 'V'				
	            	nValMerc:= MaFisRet(nItem,"IT_VALMERC")
					nBase:=nValMerc
	            	nValImp:=((nBase * nAliq)/100)
	            	xRet:=nValImp	
				ElseIf cCalculo == 'A'
					xRet:=nAliq
				EndIf				 	
			EndIf	
		
		//Calculo para rotina automatica
		Else
			aItemSD1 		:= AClone( ParamIxb[1] )
			aImposto		:= AClone( ParamIxb[2] )
			
			//Busca aliquota do produto.Caso nao exista utiliza a da SFB 
			cProd:=aImposto[16]
			dbSelectArea('SB1')
			dbSetOrder(1)
			If dbSeek(xFilial('SB1')+cProd)
				If SB1->B1_ALIQICE > 0
					nAliq:=SB1->B1_ALIQICE
				Else	
					dbSelectArea('SFB')
					dbSetOrder(1)
					If dbSeek(xFilial('SFB')+aInfo[1])
						nAliq:=SFB->FB_ALIQ
					EndIf
				EndIf
			EndIf
			
			aImposto[2]		:=nAliq //Aliquota
			aImposto[3]		:=aItemSD1[3]// Base de Calculo
			aImposto[4]		:=((aItemSD1[3] * nAliq)/100) //Valor do imposto
			xRet	 	 	:= aImposto
		EndIf
	EndIf		
Return (xRet) 
