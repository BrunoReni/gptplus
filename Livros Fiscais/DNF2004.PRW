#Include "Protheus.Ch"
#INCLUDE "FWCOMMAND.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DNF2004   �Autor  �Mary C. Hergert     � Data � 25/10/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     �Geracao dos movimentos de saida por filial para o meio      ���
���          �magnetico DNF2004.                                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DNF2004(dDtInicial,dDtFinal,aFilsSel)

	Local aTRBS 	:= DNF2004TRB()

	DNF2004Proc(dDtInicial,dDtFinal,aFilsSel) 

Return(aTRBs)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �DNF2004Proc�Autor  �Mary C. Hergert     � Data � 25/10/2004  ���
��������������������������������������������������������������������������͹��
���Desc.     �Processa os movimentos por filial                            ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �DNF2004                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function DNF2004Proc(dDtInicial,dDtFinal,aFilsSel)

	Local cTrabalho	:= ""
	Local cProdDNF	:= GetNewPar("MV_PRODDNF","")
	Local cConvDNF	:= GetNewPar("MV_CONVDNF","")
	Local cVolDNF	:= GetNewPar("MV_VOLDNF","")
	Local cNF		:= ""
	Local cSerie	:= ""
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cFild2	:= ""
    Local cFilOri	:= SM0->M0_CODFIL
	Local nReg		:= 0   
    Local nFilial   := 0  
    Local cFilAtu   := ""               

	//���������������������������Ŀ
	//�Areas e indices de trabalho�
	//�����������������������������
	dbSelectArea("SF3")
	SF3->(dbSetOrder(5))
	dbSelectArea("SD2")
	SD2->(dbSetOrder(3))
	dbSelectArea("SB5")
	SB5->(dbSetOrder(1))
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1)) 

	//�������������������������������������������������������Ŀ
	//�Um meio magnetico contendo a matriz e todas as filiais.�
	//���������������������������������������������������������
	For nFilial := 1 To Len( aFilsSel )
		If aFilsSel[ nFilial, 1 ]
			cFilAnt := aFilsSel[ nFilial, 2 ]
            cFilAtu := aFilsSel[ nFilial, 2 ]

	        dbSelectArea("SM0")
	        SM0->(dbSeek(cEmpAnt+cFilAtu,.T.))
	
	        cFilAnt := SM0->M0_CODFIL
			cNF		:= ""
			cSerie	:= ""
			cCliente:= ""
			cLoja	:= ""
			cFild2	:= ""
		
			cTrabalho := CriaTrab(Nil, .F.)
			IndRegua("SD2",cTrabalho,"D2_FILIAL+D2_DOC+D2_SERIE+D2_ITEM",,"SD2->D2_FILIAL == '" + xFilial("SD2") + ;
					 "' .AND. DTOS(SD2->D2_EMISSAO) >= '" + DTOS(dDtInicial) + "' .AND. DTOS(SD2->D2_EMISSAO) <= '" + ;
					 DTOS(dDtFinal) + "' .AND. SUBSTR(SD2->D2_CF,1,1) >= '5' .AND. SD2->D2_TIPO <> 'S'")
			Do While ! SD2->(Eof())
				//������������������������������������������������������Ŀ
				//�Somente serao processados notas fiscais que possuirem �
				//�produtos com o codigo da DNF.                         �
				//��������������������������������������������������������
		   		SF3->(dbSeek(xFilial("SF3")+SD2->D2_SERIE+SD2->D2_DOC))
				SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
				SB5->(dbSeek(xFilial("SB5") + SD2->D2_COD))
				SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES))
				If SD2->D2_TIPO$"DB"
					SA2->(dbSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA))
				Else
					SA1->(dbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA))
				Endif
					
				If SD2->D2_TIPO $ "ICSP" .Or. Empty(&(cProdDNF)) .Or. !Empty(SD2->D2_PDV) .Or. !SF4->F4_ESTOQUE == "S"
					SD2->(dbSkip())
					Loop
				Endif
				
		      	If SD2->D2_DOC <> cNF .Or. SD2->D2_SERIE <> cSerie .Or. ;
		        	SD2->D2_CLIENTE <> cCliente .Or. SD2->D2_LOJA <> cLoja .Or.;
		        	SD2->D2_FILIAL <> cFild2
					cNF			:= SD2->D2_DOC
					cSerie		:= SD2->D2_SERIE
					cCliente	:= SD2->D2_CLIENTE
					cLoja		:= SD2->D2_LOJA
					cFild2		:= SD2->D2_FILIAL
					nReg		+= 1
		
					//���������������������������������Ŀ
					//�Registro 0 - Dados da Nota Fiscal�
					//�����������������������������������
					RecLock("R00",.T.)
					R00->A00_PER	:= StrZero(Year(dDtFinal),4) + StrZero(Month(dDtFinal),2)
					R00->A00_EMITE	:= StrZero(Val(SM0->M0_CGC),14) 
					R00->A00_NF		:= SD2->D2_DOC
					R00->A00_SERIE	:= If(Empty(SerieNfId("SD2",2,"D2_SERIE")),"000",SerieNfId("SD2",2,"D2_SERIE"))
					R00->A00_EMIS	:= SD2->D2_EMISSAO
					R00->A00_SAI	:= SD2->D2_EMISSAO
					If Substr(SD2->D2_CF,1,1) == "7"
						R00->A00_DEST	:= ""
					Else 
						If SD2->D2_TIPO$"DB"
							R00->A00_DEST :=SA2->A2_CGC
						Else
							R00->A00_DEST :=SA1->A1_CGC
						Endif
						//���������������������Ŀ
						//| Comparacao de CNPJs |
						//�����������������������
						If AllTrim(SM0->M0_CGC) == AllTrim(R00->A00_DEST)
							R00->A00_DEST := replicate("9",14)
						Endif 
					Endif
					R00->A00_OBSERV	:= SF3->F3_OBSERV
					R00->A00_REG 	:= nReg
					MsUnLock()		  
			
				Endif
		
				//��������������������������������������Ŀ
				//�Registro 1 - Itens do Documento Fiscal�
				//����������������������������������������
				RecLock("R01",.T.)
				R01->A01_PER  	:= StrZero(Year(dDtFinal),4) + StrZero(Month(dDtFinal),2)
				R01->A01_EMITE	:= StrZero(Val(SM0->M0_CGC),14) 
				R01->A01_NF		:= SD2->D2_DOC
				R01->A01_SERIE	:= If(Empty(SerieNfId("SD2",2,"D2_SERIE")),"000",SerieNfId("SD2",2,"D2_SERIE"))
				R01->A01_EMIS		:= SD2->D2_EMISSAO
				R01->A01_ITEM		:= SD2->D2_ITEM
				R01->A01_PROD		:= &(cProdDNF)
				R01->A01_CAPAC	:= &(cVolDNF)
				R01->A01_CFOP		:= SD2->D2_CF
				R01->A01_UN		:= SD2->D2_UM
				R01->A01_QUANT	:= SD2->D2_QUANT
				R01->A01_UNIT		:= SD2->D2_PRCVEN
				R01->A01_TOTAL	:= SD2->D2_TOTAL
				R01->A01_IPI		:= SD2->D2_IPI
				
				If Empty(cConvDNF)
					R01->A01_ESTAT := 0				
				ElseIf &(cConvDNF) == 0
					R01->A01_ESTAT := 0
				Else
					If (SB1->B1_TIPCONV)=="M"
						R01->A01_ESTAT := &(cConvDNF) * SD2->D2_QUANT
					Else
						R01->A01_ESTAT := &(cConvDNF) / SD2->D2_QUANT
					Endif
				Endif			       
				R01->A01_REG 	:= nReg
				MsUnLock()
				SD2->(dbSkip())
			Enddo
		EndIf
	Next nFilial

	//������������������������������������������Ŀ
	//�Volta a empresa anteriormente selecionada.�
	//��������������������������������������������
	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
	cFilAnt := SM0->M0_CODFIL

	#IFNDEF TOP
		//������������������������������������������������������������������������Ŀ
		//�Deletando os Indices                                                    �
		//��������������������������������������������������������������������������
		dbSelectArea("SD2")
		RetIndex("SD2")
		dbClearFilter()
		Ferase(cTrabalho+OrdBagExt())
	#ENDIF
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DNF2004TRB�Autor  �Mary C. Hergert     � Data � 25/10/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria tabelas temporarias para processamento por filial      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �DNF2004                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DNF2004TRB()

	Local cArq00		:= ""
	Local cArq01		:= ""
	Local aStru00  	:= {}
	Local aStru01  	:= {}
	//������������������������������������������������������������������������Ŀ
	//�Criacao os arquivos de trabalho                                         �
	//��������������������������������������������������������������������������

	//������������������������������������������������������������������������Ŀ
	//�Registro 0 - Dados das Notas Fiscais                                    �
	//��������������������������������������������������������������������������
	AADD(aStru00,{"A00_REG"		,"N",020,0})
	AADD(aStru00,{"A00_PER"		,"C",006,0})
	AADD(aStru00,{"A00_EMITE"	,"C",014,0})
	AADD(aStru00,{"A00_NF"		,"C",TamSX3("F2_DOC")[1],0})
	AADD(aStru00,{"A00_SERIE"	,"C",003,0})
	AADD(aStru00,{"A00_EMIS"	,"D",008,0})
	AADD(aStru00,{"A00_SAI"		,"D",008,0})
	AADD(aStru00,{"A00_DEST"	,"C",014,0})
	AADD(aStru00,{"A00_OBSERV"	,"C",070,0})
	//
	cArq00	:=	CriaTrab(aStru00)
	dbUseArea(.T.,__LocalDriver,cArq00,"R00")
	IndRegua("R00",cArq00,"A00_REG")

	//������������������������������������������������������������������������Ŀ
	//�Registro 1 - Itens das Notas Fiscais                                    �
	//��������������������������������������������������������������������������
	AADD(aStru01,{"A01_REG"		,"N",020,0})
	AADD(aStru01,{"A01_PER"		,"C",006,0})
	AADD(aStru01,{"A01_EMITE"	,"C",014,0})
	AADD(aStru01,{"A01_NF"		,"C",TamSX3("F2_DOC")[1],0})
	AADD(aStru01,{"A01_SERIE"	,"C",003,0})
	AADD(aStru01,{"A01_EMIS"	,"D",008,0})
	AADD(aStru01,{"A01_ITEM"	,"C",003,0}) 
	AADD(aStru01,{"A01_PROD"	,"N",003,0}) 	
	AADD(aStru01,{"A01_CAPAC"	,"N",005,0}) 
	AADD(aStru01,{"A01_CFOP"	,"C",004,0}) 
	AADD(aStru01,{"A01_UN"		,"C",002,0})
	AADD(aStru01,{"A01_QUANT"	,"N",014,3}) 
	AADD(aStru01,{"A01_UNIT"	,"N",016,6}) 
	AADD(aStru01,{"A01_TOTAL"	,"N",014,2}) 
	AADD(aStru01,{"A01_IPI"		,"N",006,2}) 
	AADD(aStru01,{"A01_ESTAT"	,"N",014,3}) 
    //
	cArq01	:=	CriaTrab(aStru01)
	dbUseArea(.T.,__LocalDriver,cArq01,"R01")
	IndRegua("R01",cArq01,"A01_REG")

	aTrbs	:=	{{cArq00,"R00"},{cArq01,"R01"}}

Return(aTrbs)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao   �DNF2004Del �Autor  � Mary C. Hergert    � Data � 26/10/2004  ���
�������������������������������������������������������������������������͹��
���Desc.    �Apaga arquivos temporarios criados para gerar o arquivo      ���
���         �Magnetico                                                    ���
�������������������������������������������������������������������������͹��
���Uso      �DNF2004                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DNF2004Del(aDelArqs)

	Local aAreaDel 	:= GetArea()
	Local nI 		:= 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[ni,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[ni,1]+GetDBExtension())
			Ferase(aDelArqs[ni,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return

