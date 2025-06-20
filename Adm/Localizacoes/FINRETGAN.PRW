#include "protheus.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetGanDeb �Autor  �                    � Data �  31/07/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � RetGanDeb  - Calculo de Ret de GAN.                        ���
�������������������������������������������������������������������������͹��
���Uso       � ARGRetGN (FINRETARG)                                       ���
�������������������������������������������������������������������������͹��
���Parametros� 1. cAgente: Agente de retenci�n (N = No/ S = Si).          ���
��           � 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG ���
��           � 3. aConGan: Arreglo de conceptos de ganancias:             ���
��           �    [1] = Concepto de ganancias.                            ���
��           �    [2] = Base para ganancias.                              ���
��           �    [3] = Concepto2 de ganancias.                           ���
��           �    [4] = Proveedor + Loja.                                 ���
��           �    [5] = E2_MSFIL cuando SE2 est� compartida (sino vacio). ���
��           � 4. cFornece: Proveedor.                                    ���
��           � 5. cLoja: Loja.                                            ���
��           � 6. cChavePOP:FJK_PREOP+Proveedor+Loja, usada en ObtReten().���
��           � 7. lOPRotAut: .T. Si es generaci�n autom�tica.             ���
��           � 8. lPa: .T. Si es PA.                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RetGanDeb(cAgente,nSigno,aConGan,cFornece,cLoja,cChavePOP,lOPRotAut,lPa, nValBase)
Local aBasTtlRet:= {}
Local aSFEGn	:= {}
Local aAreaAtu 	:= {}
Local aAreaSA2	:= {}
Local aGanComp	:= {}
Local aGanRet	:= {0,.F.,.F.}
Local aArea		:=	GetArea()
Local lReduzGan	:= .T.
Local cConcAux	:= ""
Local cConcepto	:= ""
Local nCount	:= 0
Local nRetencMes:= 0
Local nAliq		:= 0
Local nDeduc	:= 0
Local nImposto	:= 0
Local nImpAtual	:= 0
Local nBaseAtual:= 0
Local nRetMinima:= 0
Local nPos		:= 0
Local nBasTtlRet:= 0
Local nValImpor	:= 0
Local nFator	:= 1
Local lVisSFE   := .F.
Local lDeduc		:= .F. 
Local lFDeduc		:= .F. 
Local nDeducMes := 0 
Local lMinera	:=.F.
Local cConGan	:= "04"
Local nFEDeduc  := 0
Local lRegOP := .F.
Local lRG424518 :=SFF->(ColumnPos("FF_ALNOIPF")) > 0       // Novo conceito de aliquota - RG 4245-18 - Nuevos Montos No Sujetos a Retenci�n - Personas F�sicas 
Local lSerieM:=.f.
Local aAreaAtu:=GetArea()
Local nRecSF2:= 0
Local nRecSF1 := 0
Local lCbuVld:= .F.
Local lProvExt  := .F.
Local lProvComB := .F.
Local nImpNoCF  := 0
Local nVlrBrut  := 0
Local nLojProv  := 0
Local nX        := 0
Local cAntFornec := ""
Local cAntLoja   := ""
Local aAreaSFE   := {}
Local aAreaSFF := {}
Local lEscalaGan := .F.
DEFAULT nSigno	:= 1
DEFAULT cChavePOP:= ""
DEFAULT lOPRotAut:= .F.
DEFAULT lPa      := .F. 
DEFAULT nValBase := 0

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEGN := ObtReten(cChavePOP,"","","G")
EndIf

If GetNewPar("MV_SEGMEN","") $ "1|2|3" .And. SA2->(ColumnPos("A2_TIPROVM"))>0 .AND.  SA2->A2_TIPROVM $ "0|1|2|3|4"
	lMinera:=.T.
EndIf	

If  SA2->A2_TIPO $ "E" .And. Empty(SA2->A2_AGREGAN) .And. !lPa  //� Ley 20628 � Impuesto a las Ganancias � Beneficiarios del Exterior
	lProvExt  := .T.                                     //No aplica a PAs
	lReduzGan := .F.    //No aplica Reducci�n de ganancias
EndIf

If type("inclui")=="U"
	 inclui:=NIL
EndIf

If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
	dbSelectArea("SF2")
	dbSetOrder(1)
	If lMsfil
		nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	Else
		nRecSF2 := FINBuscaNF(xFilial("SF2", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	EndIf
	If (SA2->(ColumnPos("A2_CBUINI"))>0 .and. SA2->(ColumnPos("A2_CBUFIM"))>0) .and. SA2->A2_CBUINI <= SF2->F2_EMISSAO .and. SA2->A2_CBUFIM >= SF2->F2_EMISSAO .and. Subs(SF2->F2_SERIE,1,1) =="A"
		lCbuVld:=.T.
	EndIf
	
	If nRecSF2 > 0 .And. ( Subs(SF2->F2_SERIE,1,1)=="M" .Or. lCbuVld)
		lSerieM:=.T.
	EndIf
	
	If  nRecSF2 > 0 .And. Subs(SF2->F2_SERIE,1,1)=="B" .And. SA2->A2_TIPO $ "I" .And. SF1->(Columnpos("F1_IMPNOCF")) > 0 .AND. SF2->(Columnpos("F2_IMPNOCF")) > 0  .And. Type("aTxMoedas") != "U"//� RG 830 � Retenci�n de Ganancias - Comprobantes serie �B� emitidos por Responsables Inscriptos
		lProvComB:= .T.   
		nImpNoCF := -1 * Round(xMoeda(SF2->F2_IMPNOCF,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
		nVlrBrut := Round(xMoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
		nValBase := Round(xMoeda(nValBase,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
	EndIf
Else
	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	If lMsfil
		nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	Else
		nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	EndIf
	
	If (SA2->(ColumnPos("A2_CBUINI"))>0 .and. SA2->(ColumnPos("A2_CBUFIM"))>0) .and. SA2->A2_CBUINI <= SF1->F1_EMISSAO .and. SA2->A2_CBUFIM >= SF1->F1_EMISSAO .and. Subs(SF1->F1_SERIE,1,1) == "A"
		lCbuVld:=.T.
	EndIf
	
	If  nRecSF1 > 0 .And.( Subs(SF1->F1_SERIE,1,1)=="M" .Or. lCbuVld)
		lSerieM:=.T.
	EndIf
	
	If  nRecSF1 > 0 .And. Subs(SF1->F1_SERIE,1,1)=="B" .And. SA2->A2_TIPO $ "I" .And. SF1->(Columnpos("F1_IMPNOCF")) > 0 .AND. SF2->(Columnpos("F2_IMPNOCF")) > 0  .And. Type("aTxMoedas") != "U"//� RG 830 � Retenci�n de Ganancias - Comprobantes serie �B� emitidos por Responsables Inscriptos
		lProvComB:= .T. 
		nImpNoCF := Round(xMoeda(SF1->F1_IMPNOCF,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))    
		nVlrBrut := Round(xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
		nValBase := Round(xMoeda(nValBase,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
	EndIf
EndIf
RestArea(aAreaAtu)

If !lSerieM .and. lRetpa .and. type("cSerienf")=="C" .and. Subs(cSerienf,1,1)=="M"
	lSerieM:=.T.
EndIf

For nCount:=1  to Len(aConGan)
	If  aConGan[nCount][2] < 0
		aAdd(aGanComp,-1)
	Else
		aAdd(aGanComp,1)
	Endif
	If  aConGan[nCount,1] == '02' .And. !Empty(aConGan[nCount,3])
		cConcepto := aConGan[nCount,3]
	Else
		If  lCbuVld .And. !lProvExt
			aConGan[nCount,1] := "MA"
		EndIf
		cConcepto := aConGan[nCount,1]
	Endif
	If  lProvComB 
		aConGan[nCount][2]:= aConGan[nCount][2] - ( nImpNoCF * (nValBase / nVlrBrut) )
	Endif	
	nPos := Ascan(aBasTtlRet,{|conceito| conceito[1] == cConcepto})
	If nPos == 0
		Aadd(aBasTtlRet,{cConcepto,0})
		nPos := Len(aBasTtlRet)
	Endif
	aBasTtlRet[nPos,2] += aConGan[nCount][2] * aGanComp[nCount]
Next nCount

//���������������������������������������������������������������������Ŀ
//� Obter Impostos somente qdo a Empresa Usuario for Agente de Reten��o �
//� o el concepto sea =="07" donde siempre se debe retener,             �
//� y el total dos titulos for maior que 0.00                           �
//�����������������������������������������������������������������������
For nCount:=1  to Len(aConGan)
	SA2->( dbSetOrder(1) )
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
		SA2->( MsSeek(aConGan[nCount][5]+aConGan[nCount][4]) )
	Else
		SA2->( MsSeek(xFilial("SA2")+aConGan[nCount][4]) )
	Endif
	If SA2->A2_AGREGAN   == "00"
		Loop
	Endif
	If (SA2->(ColumnPos("A2_DTIREDG")) > 0 .And. SA2->(ColumnPos("A2_DTFREDG")) > 0 ;
	   .And. !Empty(SA2->A2_DTIREDG) .And. !Empty(SA2->A2_DTFREDG) ) .And. !lProvExt
	    If  ( Dtos(dDataBase)< Dtos(SA2->A2_DTIREDG) ) .Or. ( Dtos(Ddatabase) > Dtos(SA2->A2_DTFREDG) )
	    	lReduzGan:= .F.
	    EndIf
	EndIf

	If (SA2->(ColumnPos("A2_DTICALG")) > 0 .And. SA2->(ColumnPos("A2_DTFCALG")) > 0 ;
	   .And. !Empty(SA2->A2_DTICALG) .And. !Empty(SA2->A2_DTFCALG) ) .And. !lProvExt
	    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALG) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALG) )
	    	If SA2->A2_PORGAN == 0
	    		IF Empty(SA2->A2_CODCOND)
	   				Return(aSFEGN)
	   			Else
	   				Loop
	   			EndIF	   			
	   		EndIf
	   	Else
	   		lReduzGan:= .F.	   		
	    EndIf
	EndIf

	cFornece	:=	SA2->A2_COD
	cLoja		:=	SA2->A2_LOJA

	/*Respalda c�digo y loja del proveedor*/
	cAntFornec  :=  cFornece
	cAntLoja    :=  cLoja

	nBasRetMes := 0.00
	nRetencMes := 0.00
	nDeducMes  := 0.00
	cConcepto  := 	aConGan[nCount][1]
	cConcepto2 :=	aConGan[nCount][3]

	If !Empty(cConcepto) .And. ((subs(cAgente,1,1) == "S") .Or. cConcepto=="07");
		.And. aConGan[nCount][2] <> 0.00 ;
		.And. cConcepto <> '00'

		If ( cConcepto#"07" .And. (subs(cAgente,1,1) # "S") )
			Return(aSFEGN)
		EndIf

		//�������������������������������������������������������������������������Ŀ
		//� Varrer arquivo de Retencoes para obter acumulados do mes como condomino �
		//���������������������������������������������������������������������������
		If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855" .And. !lProvExt
			nLojProv := aScan(aProvCuit, { |x| x[1] == SA2->A2_CGC})
			If nLojProv > 0
				For nX := 1 To Len(aProvCuit[nLojProv][2])
					cFORNECE := aProvCuit[nLojProv][2][nX][1]
					cLOJA    := aProvCuit[nLojProv][2][nX][2]

					ObtGan(@nRetencMes,@nFEDeduc,@nBasRetMes,cFORNECE,cLOJA,cConcepto,.T.)
					nBasRetMes := nBasRetMes
				Next nX
			EndIf
		EndIf
		
		If  !lProvExt //Para proveedor Exterior no aplica
			nLojProv := aScan(aProvCuit, { |x| x[1] == SA2->A2_CGC})
			If nLojProv > 0
				For nX := 1 To Len(aProvCuit[nLojProv][2])
					cFORNECE := aProvCuit[nLojProv][2][nX][1]
					cLOJA    := aProvCuit[nLojProv][2][nX][2]
					AcumRetGan(cFORNECE, cLOJA, cConcepto, @nBasRetMes, @nRetencMes, @nDeducMes, .T.) //Acumulado Retenci�n Ganancias
				Next nX
			EndIf
		Endif
		
		If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855" .and. !(SA2->A2_CONDO $ "1|2") .And. !lProvExt
			nLojProv := aScan(aProvCuit, { |x| x[1] == SA2->A2_CGC})
			If nLojProv > 0
				For nX := 1 To Len(aProvCuit[nLojProv][2])
					cFORNECE := aProvCuit[nLojProv][2][nX][1]
					cLOJA    := aProvCuit[nLojProv][2][nX][2]

					ObtGan(@nRetencMes,@nDeducMes,@nBasRetMes,cFORNECE,cLOJA,cConcepto)
				Next nX
				If nDeducMes>0 .or. nBasRetMes>0
					nBasRetMes := nBasRetMes - nDeducMes
					lFDeduc := .T.
					lRegOP := .T. 
				EndIf
			EndIf
		EndIf

		//Verifica configuraci�n de escalas (FF_ESCALA)
		aAreaSFF := SFF->(GetArea())
		dbSelectArea("SFF")
		dbSetOrder(2)
		If "FF_IMPOSTO" $ IndexKey()
			MsSeek(xFilial("SFF")+cConcepto+'GAN')
		Else
			MsSeek(xFilial("SFF")+cConcepto)
		Endif
		If !(SFF->FF_ESCALA $ "D| ")
			lEscalaGan := .T.
		EndIf
		SFF->(RestArea(aAreaSFF))
		
		If  !lProvExt //Para proveedor Exterior no aplica
			nLojProv := aScan(aProvCuit, { |x| x[1] == SA2->A2_CGC})
			If nLojProv > 0
				For nX := 1 To Len(aProvCuit[nLojProv][2])
					cFORNECE := aProvCuit[nLojProv][2][nX][1]
					cLOJA    := aProvCuit[nLojProv][2][nX][2]

					If FunName() == "FINA855" .And. Inclui != Nil .And. !Inclui .And. !Empty(FJK->FJK_ORDPAG)
						aAreaSFE := SFE->(GetArea())
						dbSelectArea("SFE")
						dbSetOrder(2)
						If SFE->(MsSeek(xFilial("SFE") + FJK->FJK_ORDPAG + 'G'))
							lDeduc := IIF( SFE->FE_DEDUC > 0, .T., .F.)
						EndIf
						SFE->(RestArea(aAreaSFE))
					Else
						lFDeduc := .T.
					EndIf

					AcumRetGan(cFORNECE, cLOJA, cConcepto, @nBasRetMes, @nRetencMes, @nDeducMes, .F., lEscalaGan) //Acumulado Retenci�n Ganancias
					
				Next nX
			EndIf
		Endif

		/*Restaura c�digo y loja del proveedor*/
		cFornece := cAntFornec
		cLoja    := cAntLoja

		//������������������������������������������������������������Ŀ
		//� Obter Base Atual para c�lculo da Gan�ncia.                 �
		//� Base Atual := ( Base Acumulada do mes + Total das NFs -    �
		//�                 Minimo disponivel mensal )                 �
		//��������������������������������������������������������������
		nAliq      := 0.00
		nDeduc     := 0.00
		nImposto   := 0.00
		nImpAtual  := 0.00

		nBaseAtual := nBasRetMes + aConGan[nCount][2]

		//������������������������������������������������������������������Ŀ
		//� Buscar el Valor de Retencion Minima.                             �
		//��������������������������������������������������������������������
		If cConcepto == '02' .And. !Empty(cConcepto2)
			cConcAux := cConcepto2+Space(TamSx3("FF_NUM")[1] - TamSx3("FF_ITEM")[1])
		Else
			cConcAux := cConcepto+Space(TamSx3("FF_NUM")[1] - TamSx3("FF_ITEM")[1])
		Endif
		
		If  !lProvExt //Para proveedor Exterior no aplica
			aAreaAtu:=GetArea()
			aAreaSA2:= SA2->(GetArea())
			dbSelectArea("SA2")
			dbSetOrder(1)
	
			If  MsSeek(xFilial("SA2")+cFORNECE+cLOJA) .AND. SA2->A2_INSCGAN == "N"
				nRetMinima :=0
			Else
				dbSelectArea("SFF")
				dbSetOrder(1)
				If !lMinera .And. MsSeek(xFilial("SFF")+cConcAux+"12")
					nRetMinima	:=	FF_IMPORTE
				Else
					// Caso ja tenha sido realizada manutencao no arquivo SFF, atraves da rotina MATA994.
					cConcAux := Space(TamSx3("FF_NUM")[1])
					If !lMinera .And. MsSeek(xFilial("SFF")+cConcAux+"12")
						nRetMinima	:=	FF_IMPORTE
					Else
						// Mantem a compatibilidade com o legado, caso nao tenha sido realizada manutencao
						// no arquivo SFF, atraves da rotina MATA994.
						cConcAux := StrZero(1,TamSx3("FF_NUM")[1])
						If !lMinera .And. MsSeek(xFilial("SFF")+cConcAux+"12")
							nRetMinima	:=	FF_IMPORTE
						Else
							nRetMinima	:=	0
						EndIf
					EndIf
				EndIf
	        EndIf
			If lSerieM
				nRetMinima	:=	0
			EndIf
			RestArea(aAreaAtu)
			SA2->(RestArea(aAreaSA2))
		Endif
		
		//������������������������������������������������������������������Ŀ
		//� Verificar que ACTIVIDAD desempe�a el proveedor para la retencion �
		//� de IG.                                                           �
		//��������������������������������������������������������������������
		dbSelectArea("SFF")
		dbSetOrder(2)
		If cConcepto == '02' .And. !Empty(cConcepto2)
			If "FF_IMPOSTO" $ IndexKey()
				MsSeek(xFilial("SFF")+cConcepto2+'GAN')
			Else
				MsSeek(xFilial("SFF")+cConcepto2)
			Endif
		Else
			If "FF_IMPOSTO" $ IndexKey()
				MsSeek(xFilial("SFF")+cConcepto+'GAN')
			Else
				MsSeek(xFilial("SFF")+cConcepto)
			Endif
		Endif
		If SFF->FF_ESCALA $ "D| " 
			//���������������������������������������������������������������Ŀ
			//� Posicionar no Item "06" da Tabela de Ganancias para Obter     �
			//� os percentuais. (Item "06" Conceito):                         �
			//� Venta de Bienes de Cambio, Bienes Muebles; Locaciones de Obra �
			//� Y/O Servicios; Transferencia Definitiva de Llaves, Marcas,    �
			//� Patentes de Invencion, Regalias, Concesion y Similares.       �
			//�����������������������������������������������������������������
			dbSelectArea("SFF")
			dbSetOrder(2)
			If cConcepto == '02' .And. !Empty(cConcepto2)
				If "FF_IMPOSTO" $ IndexKey()
					MsSeek(xFilial("SFF")+cConcepto2+'GAN')
				Else
					MsSeek(xFilial("SFF")+cConcepto2)
				Endif
				nPos := Ascan(aBasTtlRet,{|conceito| conceito[1] == cConcepto2})
			Else
				If "FF_IMPOSTO" $ IndexKey()
					MsSeek(xFilial("SFF")+cConcepto+'GAN')
				Else
					MsSeek(xFilial("SFF")+cConcepto)
				Endif
				nPos := Ascan(aBasTtlRet,{|conceito| conceito[1] == cConcepto})
			Endif

			nBasTtlRet := nBaseAtual

			If (nBasTtlRet + nDeducMes > FF_IMPORTE ) .or.  SA2->A2_INSCGAN == "N" .or. lMinera .Or. lProvExt
				//������������������������������������������������������������Ŀ
				//� Calcular Gan�ncia baseando na Tabela de Gan�ncias.         �
				//��������������������������������������������������������������
				//�����������������������������������������������������������������������Ŀ
				//� Calculo da Gan�ncia:                                                  �
				//� Imposto := ( Retencao+Base de Calculo) * (Alquota Inscrito/100)       �
				//� Imposto := Imposto Atual - Impostos ja retidos no m�s.                �
				//�������������������������������������������������������������������������
				If SA2->A2_INSCGAN == "S"
					If lMinera
						If (SA2->A2_TIPROVM $ "0|1|2|3") 
							nAliq    := FF_ALSIMIN
						Elseif SA2->A2_TIPROVM $ "4" 
							nAliq    := FF_ALNOMIN
						EndIf
					Else	
						nAliq    := FF_ALQINSC
					EndIf
					nFator   := nBaseAtual/nBasTtlRet
					
					If  ExistBlock("A850FTGN")
						nFator :=	ExecBlock("A850FTGN",.F.,.F.,{cConcepto,nFator})
					Endif
					
					If  (lMinera .And. SA2->A2_TIPROVM=="4") .Or. lProvExt
						nDeduc   :=  0
					Else
						nDeduc   := FF_IMPORTE * nFator
					EndIf   					
					
					// Validacion de Importe > 0 
					IF ((!lSerieM .and. FF_IMPORTE > 0 ) .or.  lSerieM )  .And. SA2->A2_CONDO $ "1|2"  .And. !lProvExt  //Para proveedor Exterior no aplica
						nDeduc   := Iif(!lSerieM,FF_IMPORTE,0)
						If nRetencMes == 0 .and. nBasRetMes == 0
							nBaseAtual := nBaseAtual-IIf(!lSerieM,FF_IMPORTE,0)
						EndIf
						nImposto := ((FF_RETENC) + ((nBaseAtual*((100-FF_REDBASE)/100)) ) * (nAliq/100)) * Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
					Else
						If Inclui != Nil
							lVisSFE := Inclui
						Endif
						If  !lProvExt
							If  cPaisloc == 'ARG' .and. FunName() == 'FINA855' .and. nRetencMes > 0 //if para calcular o imposto com dedu��o caso eu j� possua a reten��o e a base de reten��o registrados en base, em caso de modifica��o do registro existente
								nImposto := ((FF_RETENC) + ((nBaseAtual*((100-FF_REDBASE)/100)) - IIf(nRetencMes > 0 .and. nBasRetMes > 0 .And. nDeducMes == 0,nDeduc,IIf(lFDeduc .and. nRetencMes > 0 .and. nDeducMes == 0,nDeduc,IIf(lVisSFE,0,IIF(lDeduc,nDeduc,0)))) ) * (nAliq/100)) * Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
							Else 
								nImposto := ((FF_RETENC) + ((nBaseAtual*((100-FF_REDBASE)/100)) - IIf(nRetencMes == 0 .and. nBasRetMes == 0,nDeduc,IIf(lFDeduc .and. nRetencMes == 0 .and. nDeducMes == 0,nDeduc,IIf(lVisSFE,0,IIF(lDeduc,nDeduc,0)))) ) * (nAliq/100)) * Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
							Endif
						Else 
							If  SUBSTR(UPPER(FF_ITEM),1,1)  $ "E"  //Conceptos para Proveedores Exterior: E0,E1,E2,Ex
								nDeduc     :=  nBaseAtual
								nBaseAtual := (nBaseAtual *((100-FF_REDBASE)/100)) 
								nDeduc     :=  nDeduc - nBaseAtual
								nImposto   := ( nBaseAtual * (nAliq/100) )
								aGanRet[3] := .T.
							Else
								nDeduc  := 0
								nImposto:= 0
							Endif
						Endif
						
					EndIF
					nImpAtual:= nImposto-nRetencMes
				Else
					If Alltrim(SA2->A2_TPESSOA) == "PF" .And.  lRG424518
						nAliq    := FF_ALNOIPF  
					Else
						nAliq    := FF_ALQNOIN
					EndIf
					nDeduc   := 0
					nImposto := ((FF_RETENC) + ((nBaseAtual*((100-FF_REDBASE)/100)) - nDeduc ) * (nAliq/100))* Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
					nImpAtual:= nImposto -  nRetencMes 
				EndIf
			ElseIf SA2->A2_CONDO $ "1|2" .and. SA2->A2_INSCGAN == "S" .and. ((!lSerieM .and. FF_IMPORTE > 0 ).or.  lSerieM ).and. nRetencMes == 0 .and. nBasRetMes == 0
				nDeduc   := IIf(!lSerieM,FF_IMPORTE,0)
				nBaseAtual := nBaseAtual-IIf(!lSerieM,FF_IMPORTE,0)
				nAliq    := FF_ALQINSC
				nImpAtual := 0
			EndIf

		ElseIf !lProvExt
            nValImpor:= IIf(!lSerieM,SFF->FF_IMPORTE,0)
			//���������������������������������������������������������������Ŀ
			//� Posicionar no Item "07" da Tabela de Ganancias para Obter     �
			//� os percentuais. (Item "07" Conceito):                         �
			//� Ejercicio de Profesiones Liberales u Oficios; Sindico; Manda- �
			//� tario; Director de Sociedades Anonimas; Corredor; Viajante de �
			//� Comercio y Despachante de Aduana.                             �
			//�����������������������������������������������������������������
			If SFF->FF_ITEM $ "DA"
			//Derechos de Autor
				aGanRet := F085TotGan(IIf(ColumnPos("FF_TPLIM") > 0,SFF->FF_TPLIM,"0"),SA2->A2_COD,SA2->A2_LOJA,SFF->FF_LIMITE,aConGan[1][2])
				If aGanRet[2]
					nBaseAtual := aGanRet[1]
					If SA2->A2_INSCGAN == "N"
						nImposto := ((SFF->FF_RETENC) + (nBaseAtual  * (SFF->FF_ALQNOIN/100))) * Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
						nImpAtual:= nImposto-nRetencMes
						If Alltrim(SA2->A2_TPESSOA) == "PF" .And.  lRG424518
							nAliq    := FF_ALNOIPF  
						Else
							nAliq    := SFF->FF_ALQNOIN
						EndIf
						nDeduc   := 0
					Else
						//������������������������������������������������������������Ŀ
						//� Adotar a Escala Aplicable.                                 �
						//��������������������������������������������������������������
						dbSelectArea("SFF")
						dbSetOrder(2)
						If "FF_IMPOSTO" $ IndexKey()
							MsSeek(xFilial("SFF")+"13"+"GAN")
						Else
							MsSeek(xFilial("SFF")+"13")
						Endif
						While !Eof()
							//�����������������������������������������������������������������������Ŀ
							//� Calculo da Gan�ncia:                                                  �
							//� Imposto := Retencao+(Base de Calculo-Faixa Tabela) * (Percentual/100) �
							//� Imposto := Imposto Atual - Impostos ja retidos no m�s.                �
							//�������������������������������������������������������������������������
							If (nBaseAtual - nValImpor) < FF_FXATE
								nImposto := (FF_RETENC + (nBaseAtual- nValImpor -FF_FXDE)* (FF_PERC/100))* Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
								nImpAtual := nImposto - nRetencMes
								If lMinera
									If (SA2->A2_TIPROVM $ "0|1|2|3") 
										nAliq    := FF_ALSIMIN
									Elseif SA2->A2_TIPROVM $ "4" 
										nAliq    := FF_ALNOMIN
									EndIf
								Else
									nAliq :=FF_PERC
								EndIf
								nDeduc:=nValImpor
								
								Exit
							EndIf
				    		dbSkip()
						EndDo
					EndIf
				EndIf
			Else
				If SA2->A2_INSCGAN == "N"
					nImposto := ((FF_RETENC) + (nBaseAtual  * (FF_ALQNOIN/100))) * Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
					nImpAtual:= nImposto-nRetencMes
					If Alltrim(SA2->A2_TPESSOA) == "PF" .And.  lRG424518
						nAliq    := FF_ALNOIPF  
					Else	
						nAliq    := FF_ALQNOIN
					EndIf
					nDeduc   := 0
				Else
					//������������������������������������������������������������Ŀ
					//� Adotar a Escala Aplicable.                                 �
					//��������������������������������������������������������������
					If "FF_IMPOSTO" $ IndexKey()
						MsSeek(xFilial("SFF")+"13"+"GAN")
					Else
						MsSeek(xFilial("SFF")+"13")
					Endif
					While !Eof()
						//�����������������������������������������������������������������������Ŀ
						//� Calculo da Gan�ncia:                                                  �
						//� Imposto := Retencao+(Base de Calculo-Faixa Tabela) * (Percentual/100) �
						//� Imposto := Imposto Atual - Impostos ja retidos no m�s.                �
						//�������������������������������������������������������������������������

						If ((nBaseAtual - nValImpor) < FF_FXATE )
							If  Inclui!=Nil
								lVisSFE := Inclui
							Endif 
							If nRetencMes == 0 .and. nBasRetMes == 0
								nImposto := (FF_RETENC + (nBaseAtual- nValImpor -FF_FXDE)* (FF_PERC/100))* Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
								nDeduc:=nValImpor
							Else
								nImposto := (IIF( lVisSFE, FF_RETENC,IIF(lDeduc, FF_RETENC * 2, FF_RETENC)) + ( ( nBaseAtual - nValImpor - IIf(lVisSFE,0,IIF(lDeduc,nValImpor + FF_FXDE,0) )- FF_FXDE)* (FF_PERC/100) ) ) * Iif(lReduzGan,(SA2->A2_PORGAN/100),1)
							EndIf
							nImpAtual := nImposto - nRetencMes
							If lMinera
								If (SA2->A2_TIPROVM $ "0|1|2|3") 
									nAliq    := FF_ALSIMIN
								Elseif SA2->A2_TIPROVM $ "4" 
									nAliq    := FF_ALNOMIN
								EndIf
							Else
								nAliq :=FF_PERC
							EndIf
							If lMinera .And. SA2->A2_TIPROVM=="4"
								nDeduc   :=  0
							EndIf
							Exit
						EndIf
			    		dbSkip()
					End
				EndIf
			EndIf
		EndIf
		//����������������������������������������������������������������Ŀ
		//� Generar las Retenci�n de Gan�ncias                             �
		//������������������������������������������������������������������
		Aadd(aSFEGn,Array(12))
		aSFEGn[Len(aSFEGn)][1] := ""
		aSFEGn[Len(aSFEGn)][2] := IIf(aGanRet[3],(nBaseAtual),IIf(EMPTY(SA2->A2_CODCOND),aConGan[nCount][2] ,(nBaseAtual - nBasRetMes))) // FE_VALBASE
		aSFEGn[Len(aSFEGn)][3] := nAliq                                         // FE_ALIQ
		aSFEGn[Len(aSFEGn)][4] := Round(Iif(nImpAtual >= nRetMinima, nImpAtual, 0 ) * nSigno, TamSX3("FE_VALIMP")[2]) // FE_VALIMP
		aSFEGn[Len(aSFEGn)][5] := Round(Iif(nImpAtual >= nRetMinima, nImpAtual, 0 ) * nSigno, TamSX3("FE_RETENC")[2]) // FE_RETENC
		If cPaisloc == 'ARG' .and. FunName() == 'FINA855' .and. LFDeduc .And. nDeducMes == 0
			aSFEGn[Len(aSFEGn)][6] := IIf(nRetencMes > 0 .and. nBasRetMes > 0 .and. (nImpAtual + nRetencMes >= nRetMinima),nDeduc * aGanComp[nCount],IIf(lFDeduc .and. nRetencMes >= 0 .and. (nImpAtual + nRetencMes >= nRetMinima),nDeduc,0))    // FE_DEDUC
		Elseif  lProvExt
			aSFEGn[Len(aSFEGn)][6] := nDeduc 
		Else
			aSFEGn[Len(aSFEGn)][6] := IIf(nRetencMes == 0 .and. nBasRetMes == 0 .and. (nImpAtual + nRetencMes >= nRetMinima),nDeduc * aGanComp[nCount],IIf(lFDeduc .and. nRetencMes == 0 .and. (nImpAtual + nRetencMes >= nRetMinima),nDeduc,0))    // FE_DEDUC
		endif
		aSFEGn[Len(aSFEGn)][7] := cConcepto                                     // FE_CONCEPT
		aSFEGn[Len(aSFEGn)][8] := Iif(lReduzGan,SA2->A2_PORGAN,100)             // FE_PORCRET
		aSFEGn[Len(aSFEGn)][9] := cConcepto2                                    // FE_CONCEPT
   		If SA2->(ColumnPos("A2_CODCOND")*ColumnPos("A2_CONDO")*ColumnPos("A2_PERCCON")) > 0 .And. SA2->A2_CONDO == "2"
			aSFEGn[Len(aSFEGn)][10] := SA2->A2_COD                              // FE_PORCRET
			aSFEGn[Len(aSFEGn)][11] := SA2->A2_LOJA                                // FE_PORCRET
		Else
			aSFEGn[Len(aSFEGn)][10] := ''                              // FE_PORCRET
			aSFEGn[Len(aSFEGn)][11] := ''                              // FE_PORCRET
		Endif
		aSFEGn[Len(aSFEGn)][12] := Iif(aGanComp[nCount] < 0, .T., .F.) //NC - conceitos diferentes
	EndIf
Next
RestArea(aArea)

Return aSFEGN


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetGanMnt �Autor  �                    � Data �  31/07/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � RetGanMnt  - Calculo de Ret de GAN.                        ���
�������������������������������������������������������������������������͹��
���Uso       � ARGRetGNMnt (FINRETARG)                                    ���
�������������������������������������������������������������������������͹��
���Parametros� 1. cAgente: Agente de retenci�n (N = No/ S = Si).          ���
��           � 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG ���
��           � 3. aConGan                                                 ���
��           �    [1] = Concepto de ganancias.                            ���
��           �    [2] = Base para ganancias.                              ���
��           �    [3] = Concepto2 de ganancias.                           ���
��           �    [4] = Proveedor + Loja.                                 ���
��           �    [5] = E2_MSFIL cuando SE2 est� compartida (sino vacio). ���
��           � 4. cFornece: Proveedor.                                    ���
��           � 5. cLoja: Loja.                                            ���
��           � 6. cDoc: SE2->E2_NUM                                       ���
��           � 7. cSerie: SE2->E2_PREFIXO                                 ���
��           � 8. lPa: .T. Si es PA.                                      ���
��           � 9. nTTit: 1 //SD1/SF1 o 2 //SD2/SF2                        ���
��           � 10.cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()���
��           � 11.lOPRotAut: .T. Si es generaci�n autom�tica.             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RetGanMnt(cAgente,nSigno,aConGan,cFornece,cLoja,cDoc,cSerie,lPa,nTTit,cChavePOP,lOPRotAut)
Local aSFEGn   	:= {}
Local aGanComp	:= {}
Local aArea		:=	GetArea()
Local lReduzGan	:= .T.
Local lCalcMon 	:= .F. //Validacao do calculo de Ganancia e IVA para monotributista
Local nAliq		:= 0
Local nImposto	:= 0
Local nBaseAtual:= 0
Local nRetMinima:= 0
Local nMinimo 	:= 0
Local nMinUnit	:= 0
Local nI		:= 0
Local aAreaAtu  :=GetArea()
Local lSerieM   :=.F.
DEFAULT nSigno	:=	1
DEFAULT lPa 	:= .F.
DEFAULT cChavePOP	:= ""
DEFAULT lOPRotAut:= .F.

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEGN := ObtReten(cChavePOP,"","","G")
EndIf


If  SA2->(ColumnPos("A2_TIPROVM"))>0 .AND.  GetNewPar("MV_SEGMEN","") $ "1|2|4"  .And. SA2->A2_TIPROVM $ "0|1|2|3|4" 
	lMinera:=.T.
EndIf

If (SE2->E2_TIPO $ MVPAGANT + "/"+ MV_CPNEG)
	dbSelectArea("SF2")
	dbSetOrder(1)
	If lMsfil
		nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	Else
		nRecSF2 := FINBuscaNF(xFilial("SF2", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	EndIf	
	
	If nRecSF2 > 0 .And.(  Subs(SF2->F2_SERIE,1,1)=="M")
		lSerieM:=.T.
	EndIf
Else
	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	If lMsfil
		nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	Else
		nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	EndIf	
	
	If nRecSF1 > 0 .And. (Subs(SF1->F1_SERIE,1,1)=="M")
		lSerieM:=.T.
	EndIf
EndIf
RestArea(aAreaAtu)


If !lSerieM .and. lRetpa .and. type("cSerienf")=="C" .and. Subs(cSerienf,1,1)=="M"
	lSerieM:=.T.
EndIf

For nI:=1  to Len(aConGan)
	If aConGan[nI][2] < 0
		aAdd(aGanComp,-1)
	Else
		aAdd(aGanComp,1)
	Endif
Next nI

For nI := 1 to Len(aConGan)

	dbSelectArea("SFF")
	dbGoTop()
	dbSetOrder(2)	

	If MsSeek(xFilial("SFF") + aConGan[nI][1] + 'GAN')
		If aConGan[nI][1] $ "G1|G2"
			nMinimo  	:= Iif(SFF->(ColumnPos("FF_LIMITE"))>0,SFF->FF_LIMITE,0)
			nMinUnit 	:= Iif(SFF->(ColumnPos("FF_MINUNIT"))>0,SFF->FF_MINUNIT,0)
			nRetMinima 	:= IIf(!lSerieM,SFF->FF_IMPORTE,0)
		Endif

		If SFF->FF_TIPO == "M"
			//Verifica se deve calcular a Ganancia
			lCalcMon := F850CheckLim(aConGan[nI][1],,cFornece,nMinimo,cDoc,cSerie,nMinUnit,"GAN",lPa,nTTit,Iif(lMsFil,SE2->E2_MSFIL,""))
		Endif
	Endif

	If lCalcMon
		SA2->( dbSetOrder(1) )
		If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
			SA2->( MsSeek(aConGan[nCount][5]+aConGan[nCount][4]) )
		Else
			SA2->( MsSeek(xFilial("SA2")+aConGan[nI][4]) )
		Endif

		If SA2->(ColumnPos("A2_DTIREDG")) > 0 .And. SA2->(ColumnPos("A2_DTFREDG")) > 0 ;
		   .And. !Empty(SA2->A2_DTIREDG) .And. !Empty(SA2->A2_DTFREDG)
		    If  ( Dtos(dDataBase)< Dtos(SA2->A2_DTIREDG) ) .Or. ( Dtos(Ddatabase) > Dtos(SA2->A2_DTFREDG) )
		    	lReduzGan:= .F.
		    EndIf
		EndIf

		If SA2->(ColumnPos("A2_DTICALG")) > 0 .And. SA2->(ColumnPos("A2_DTFCALG")) > 0 ;
		   .And. !Empty(SA2->A2_DTICALG) .And. !Empty(SA2->A2_DTFCALG)
		    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALG) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALG) )
		   		If SA2->A2_PORGAN == 0
	   				Return(aSFEGN)	   			
	   			EndIf
		    EndIf
		EndIf

		cFornece	:=	SA2->A2_COD
		cLoja		:=	SA2->A2_LOJA


		If !Empty(aConGan[nI][1]).And. aConGan[nI][2] <> 0.00

			nAliq      := 0.00
			nImposto   := 0.00

			nBaseAtual := aConGan[nI][2] * aGanComp[nI]

			dbSelectArea("SFF")
			dbSetOrder(2)
			MsSeek(xFilial("SFF") + aConGan[nI][1] + 'GAN')

			If ( nBaseAtual > SFF->FF_IMPORTE ) .or. lSerieM
				//������������������������������������������������������������Ŀ
				//� Calcular Gan�ncia baseando na Tabela de Gan�ncias.         �
				//��������������������������������������������������������������
				//�����������������������������������������������������������������������Ŀ
				//� Calculo da Gan�ncia:                                                  �
				//� Imposto := ( Retencao+Base de Calculo) * (Alquota Inscrito/100)       �
				//�������������������������������������������������������������������������

					nAliq    := SFF->FF_ALQNOIN
					nImposto := ((nBaseAtual - Iif(!lSerieM,SFF->FF_IMPORTE,0)) * (nAliq/100))* Iif(lReduzGan,(SA2->A2_PORGAN/100),1) * aGanComp[nI]

				//����������������������������������������������������������������Ŀ
				//� Generar las Retenci�n de Gan�ncias                             �
				//������������������������������������������������������������������
				Aadd(aSFEGn,Array(12))
				aSFEGn[Len(aSFEGn)][1] := ""
				aSFEGn[Len(aSFEGn)][2] := aConGan[nI][2]                            		// FE_VALBASE
				aSFEGn[Len(aSFEGn)][3] := nAliq                                         // FE_ALIQ
				aSFEGn[Len(aSFEGn)][4] := Round(nImposto * nSigno,TamSX3("FE_VALIMP")[2])  	// FE_VALIMP
				aSFEGn[Len(aSFEGn)][5] := Round(nImposto * nSigno,TamSX3("FE_RETENC")[2])  	// FE_RETENC
				aSFEGn[Len(aSFEGn)][6] := 0/*nDeduc*/                                   // FE_DEDUC
				aSFEGn[Len(aSFEGn)][7] := aConGan[nI][1]                                // FE_CONCEPT
				aSFEGn[Len(aSFEGn)][8] := Iif(lReduzGan,SA2->A2_PORGAN,100)             // FE_PORCRET
				aSFEGn[Len(aSFEGn)][9] := aConGan[nI][3]                               	// FE_CONCEPT
		   		If SA2->(ColumnPos("A2_CODCOND")*ColumnPos("A2_CONDO")*ColumnPos("A2_PERCCON")) > 0 .And.SA2->A2_CONDO == "2"
					aSFEGn[Len(aSFEGn)][10] := SA2->A2_COD                               // FE_PORCRET
					aSFEGn[Len(aSFEGn)][11] := SA2->A2_LOJA                              // FE_PORCRET
				Else
					aSFEGn[Len(aSFEGn)][10] := ''                              			// FE_PORCRET
					aSFEGn[Len(aSFEGn)][11] := ''                             				// FE_PORCRET
				Endif
				aSFEGn[Len(aSFEGn)][12] := Iif(aGanComp[nI] < 0,.T.,.F.)
			Endif
		EndIf
	Endif
Next nI
RestArea(aArea)
Return aSFEGN


/*
������������������������������������������������������������������������ͻ
�Programa  �ObtGan     �Autor  �Raul Ortiz Medina   � Data �  07/02/17   �
������������������������������������������������������������������������͹
�Desc.     � Realiza el acumulado de los valores de Retenciones de       �
�          � Ganancias de Orden de Pago Previa                           �
������������������������������������������������������������������������͹
�Uso       � FINA850                                                     �
������������������������������������������������������������������������ͼ
*/

Static Function ObtGan(nRetenc,nDeduc,nBasRet,cFornece,cLoja,cConcep,lCond)
Local cQuery	:= ""
Local cTempGan  := GetNextAlias()

Default lCond	:= .F.

	cQuery := "SELECT SUM(FVC_RETENC) RETENC,SUM(FVC_DEDUC) DEDUC, SUM(FVC_VALBAS) VALBASE " 
	cQuery += "FROM " + RetSqlName("FVC") + " FVC, " + RetSqlName("FJK") + " FJK "
	cQuery += "WHERE "
	cQuery += "FVC_FILIAL = '"  + xFilial("FVC") + "' AND "
	cQuery += "FJK_FILIAL = '" + xFilial("FJK") + "' AND "
	If !lCond
		cQuery	+= "FVC_FORNEC = '" + cFornece + "' AND "
		cQuery += "FVC_LOJA = '" + cLoja + "' AND "
		cQuery += "FVC_FORNEC = FJK_FORNEC AND "
		cQuery += "FVC_LOJA = FJK_LOJA  AND "
	Else
		cQuery	+= "FVC_FORCON = '" + cFornece + "' AND "
		cQuery += "FVC_LOJCON = '" + cLoja + "' AND "
	EndIf
	cQuery += "FVC_TIPO = 'G' AND "
	cQuery += "FVC_CONCEP = '" + cConcep + "' AND "
	cQuery += "FVC_PREOP = FJK_PREOP AND "
	If  !Inclui 
		cQuery += "FVC_PREOP <> '" + FJK->FJK_PREOP + "' AND "     
	Endif
	cQuery += "FJK_ORDPAG = '' AND "
	cQuery += "Substring(FJK_DTDIG,5,2) ='" + AllTrim(StrZero(Month(dDataBase),2)) + "' AND "
	cQuery += "Substring(FJK_DTDIG,1,4) ='" + AllTrim(STR(Year(dDataBase))) + "' AND "
	cQuery += "FVC.D_E_L_E_T_ = '' AND "
	cQuery += "FJK.D_E_L_E_T_ = ''"
	
	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTempGan,.F.,.T.)
	(cTempGan)->(dbGoTop())
	
	If !(cTempGan)->(EOF())
		nBasRet += (cTempGan)->VALBASE
		nRetenc += (cTempGan)->RETENC
		nDeduc  += (cTempGan)->DEDUC
	EndIf
	
	(cTempGan)->(dbCloseArea())
	
	If Select((cTempGan)) == 0
		FErase(cTempGan + GetDBExtension())
		FErase(cTempGan + OrdBagExt())
	EndIF
	
Return

/*/{Protheus.doc} AcumRetGan
	(Obtener el acumulado de retenci�n de ganancias)
	@type  Function
	@author Arturo Samaniego
	@since 19/07/2021
	@param 
		cCodProv (C): C�digo de Proveedor
		cLojProv (C): Tienda del Proveedor
		cConcGan (C): Concepto de Ganancias
		nBasRetMes (N): Valor FE_VALBASE
		nRetencMes (N): Valor FE_RETENC
		nDeducMes (N): Valor FE_DEDUC
		lRetCond (L): .T. = Proveedor Condominio
	@return Nil
/*/
Static Function AcumRetGan(cCodProv, cLojProv, cConcGan, nBasRetMes, nRetencMes, nDeducMes, lRetCond, lEscalaGan)
Local cTempSFE := Criatrab(nil,.F.)
Local cMes     := StrZero(Month(dDataBase),2)
Local cAno     := StrZero(Year(dDataBase),4)
Local cQrySFE  := ""
Local nNumRegs := 0

Default cCodProv   := ""
Default cLojProv   := ""
Default cConcGan   := ""
Default nBasRetMes := 0
Default nRetencMes := 0
Default nDeducMes  := 0
Default lRetCond   := .F.
Default lEscalaGan := .F.

	cQrySFE := " SELECT SUM(FE_VALBASE) FE_VALBASE, SUM(FE_RETENC) FE_RETENC " + IIf(!lRetCond, ", SUM(FE_DEDUC) FE_DEDUC", "")
	cQrySFE += " FROM " + RetSqlName("SFE") + " SFE "
	cQrySFE += " WHERE FE_FILIAL = '" + xFilial('SFE') + "' "
	If lRetCond
		cQrySFE += " AND Substring(FE_EMISSAO,5,2) ='" + cMes + "' "
		cQrySFE += " AND Substring(FE_EMISSAO,1,4)  ='" + cAno +"' "
		cQrySFE += " AND FE_FORCOND = '" + cCodProv + "' "
		cQrySFE += " AND FE_LOJCOND = '" + cLojProv + "' "
	Else
		cQrySFE += " AND (Substring(FE_EMISSAO,5,2) ='" + cMes + "' OR Substring(FE_DTRETOR,5,2) ='" + cMes + "') "
		cQrySFE += " AND Substring(FE_EMISSAO,1,4)  ='" + cAno +"' "
		cQrySFE += " AND FE_FORNECE = '" + cCodProv + "' "
		cQrySFE += " AND FE_LOJA = '" + cLojProv + "' "
		cQrySFE += " AND ((FE_FORNECE <> FE_FORCOND) AND (FE_LOJA <> FE_LOJCOND))"
	EndIf
	cQrySFE += " AND FE_TIPO = 'G' "
	cQrySFE += " AND FE_CONCEPT = '" + cConcGan + "' "
	cQrySFE += " AND D_E_L_E_T_ = ' ' "
	cQrySFE += " AND (((Substring(FE_DTESTOR,5,2) = (Substring(FE_DTRETOR,5,2))) AND ((Substring(FE_DTESTOR,1,4) = Substring(FE_DTRETOR,1,4))))  "
	cQrySFE += " OR (FE_DTRETOR = '        ' AND ((Substring(FE_DTESTOR,5,2) = (Substring(FE_EMISSAO,5,2))) AND ((Substring(FE_DTESTOR,1,4) = Substring(FE_EMISSAO,1,4))))))  "

	cQrySFE := ChangeQuery(cQrySFE)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySFE),cTempSFE,.T.,.T.)
	
	Count to nNumRegs
	
	If  nNumRegs > 0
		(cTempSFE)->(dbGoTop())
		If (cTempSFE)->(!eof())
			If lRetCond
				nBasRetMes += (cTempSFE)->FE_VALBASE
				nRetencMes += (cTempSFE)->FE_RETENC
			Else
				nBasRetMes += (cTempSFE)->FE_VALBASE - IIf(!lEscalaGan, (cTempSFE)->FE_DEDUC, 0)
				nDeducMes += (cTempSFE)->FE_DEDUC
				nRetencMes += (cTempSFE)->FE_RETENC
			EndIf
		Endif   
	Endif 
	(cTempSFE)->(dbCloseArea())

Return Nil
