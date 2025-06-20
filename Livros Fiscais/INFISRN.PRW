/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � IFRNEST  �Autor  �Liber De Esteban    � Data �  13/03/08   ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Retorna Dados do Estoque para processamento do Informativo  ���
���          �Fiscal - RN                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com o resumo do estoque                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nAnoEx - Ano de exercicio para gera��o do Informativo       ���
���          �cTipo - Tipo do arquivo (1-Comercio/Servico , 2-Industria)  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function IFRNEST(nAnoEx,cTipo)
Local aEstoque	:= {}
Local cCodProd	:= ""
Local dDataIni	:= CTOD("31/12/"+STR(nAnoEx-1,4))
Local dDataFim	:= CTOD("31/12/"+STR(nAnoEx,4))

//             I,F
Aadd(aEstoque,{0,0}) //MP Tributados
Aadd(aEstoque,{0,0}) //MP Isentos
Aadd(aEstoque,{0,0}) //PA Tributados
Aadd(aEstoque,{0,0}) //PA Isentos
Aadd(aEstoque,{0,0}) //Tributado
Aadd(aEstoque,{0,0}) //Isento
Aadd(aEstoque,{0,0}) //Substui��o Tributaria
Aadd(aEstoque,{0,0}) //Ativo Fixo
Aadd(aEstoque,{0,0}) //Material Consumo

dbSelectArea("SB1")
dbSetOrder(1)
DbSeek(xFilial("SB1"))
ProcRegua (SB1->(LastRec()))

While SB1->(!eof()) .And. xFilial("SB1") == SB1->B1_FILIAL

	IncProc("Processando Estoque")
	cCodProd	:= SB1->B1_COD
	If ("2"$cTipo)
		//Inicial MP
		aEstoque[1][1] += IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "00/20",FsPrdInv(cCodProd,.F.,dDataIni)[1][2],0)
		aEstoque[2][1] += IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "40/41",FsPrdInv(cCodProd,.F.,dDataIni)[1][2],0)
		
		//Final MP
		aEstoque[1][2] += IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "00/20",FsPrdInv(cCodProd,.F.,dDataFim)[1][2],0)
		aEstoque[2][2] += IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "40/41",FsPrdInv(cCodProd,.F.,dDataFim)[1][2],0)
		
		//Inicial PA
		aEstoque[3][1] += IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "00/20",FsPrdInv(cCodProd,.F.,dDataIni)[1][2],0)
		aEstoque[4][1] += IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "40/41",FsPrdInv(cCodProd,.F.,dDataIni)[1][2],0)
		
		//Final PA
		aEstoque[3][2] += IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "00/20",FsPrdInv(cCodProd,.F.,dDataFim)[1][2],0)
		aEstoque[4][2] += IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "40/41",FsPrdInv(cCodProd,.F.,dDataFim)[1][2],0)	
	EndIf
	
	//Inicial Ativo
	aEstoque[8][1] += IIF(SB1->B1_ATIVO == "S" .AND. SB1->B1_CLASFIS $ "40/41",FsPrdInv(cCodProd,.F.,dDataIni)[1][2],0)
	
	//Final Ativo
	aEstoque[8][2] += IIF(SB1->B1_ATIVO == "S" .AND. SB1->B1_CLASFIS $ "00/20",FsPrdInv(cCodProd,.F.,dDataFim)[1][2],0)
	
	//Inicial MC
	aEstoque[9][1] += IIF(SB1->B1_TIPO == "MC" .AND. SB1->B1_CLASFIS $ "40/41",FsPrdInv(cCodProd,.F.,dDataIni)[1][2],0)
	
	//Final MC
	aEstoque[9][2] += IIF(SB1->B1_TIPO == "MC" .AND. SB1->B1_CLASFIS $ "00/20",FsPrdInv(cCodProd,.F.,dDataFim)[1][2],0)
	
	SB1->(DbSkip())
EndDo

If ("1"$cTipo)
	
	//��������������������������������������Ŀ
	//�Processando o saldo inicial do periodo�
	//����������������������������������������
	aEst := {"EST",""}
	FsEstInv(aEst,1,.T.,.F.,dDataIni,.F.,.F.)
	
	EST->(dbGoTop())
	Do While ! EST->(Eof())
	
		If EST->SITUACA <> "3"
			If EST->CLASSFIS $ "10/30/60/70"
				aEstoque[5][1] += EST->CUSTO
			ElseIf EST->CLASSFIS $ "40/41"
				aEstoque[6][1] += EST->CUSTO
			Else
				aEstoque[7][1] += EST->CUSTO
			EndIf
		EndIf
		
		EST->(dbSkip())
	Enddo
	// Excluindo area aberta pela funcao FsEstInv
	FsEstInv(aEst,2,,,dDataIni,.F.,.F.)
	
	//��������������������������������������Ŀ
	//�Processando o saldo final do periodo  �
	//����������������������������������������
	aEst := {"EST",""}
	FsEstInv(aEst,1,.T.,.F.,dDataFim,.F.,.F.)
	
	EST->(dbGoTop())
	Do While ! EST->(Eof())
	
		If EST->SITUACA <> "3"
			If EST->CLASSFIS $ "10/30/60/70"
				aEstoque[5][2] += EST->CUSTO
			ElseIf EST->CLASSFIS $ "40/41"
				aEstoque[6][2] += EST->CUSTO
			Else
				aEstoque[7][2] += EST->CUSTO
			EndIf
		EndIf
		
		EST->(dbSkip())
	Enddo
	
	// Excluindo area aberta pela funcao FsEstInv
	FsEstInv(aEst,2,,,dDataFim,.F.,.F.)
EndIf

Return(aEstoque)

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � IFRNEST  �Autor  �Liber De Esteban    � Data �  13/03/08     ���
���������������������������������������������������������������������������Ĵ��
���Desc.     �Retorna Movimentacoes do ano para processamento do            ���
���          �Informativo Fiscal - RN                                       ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Array com o resumo das movimentacoes                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros�nAnoEx - Ano de exercicio para gera��o do Informativo         ���
���          �aWizard - Parametros passados pelo usuario no wizard da rotina���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGAFIS                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function IFRNMOV(nAnoEx,aWizard)
Local dDataIni	:= CTOD("01/01/"+STR(nAnoEx,4))
Local dDataFim	:= CTOD("31/12/"+STR(nAnoEx,4))
Local aMovi		:= {}
Local nX		:= 0
Local aStruSF3  := {}

Aadd(aMovi,0) //Entradas Internas
Aadd(aMovi,0) //Entradas Importa��o
Aadd(aMovi,0) //Saida Internas
Aadd(aMovi,0) //Saida Exporta��o
Aadd(aMovi,0) //Entradas Internas ATF
Aadd(aMovi,0) //Entradas Importa��o ATF
Aadd(aMovi,0) //Entradas Internas MC
Aadd(aMovi,0) //Entradas Importa��o MC
Aadd(aMovi,0) //Entradas Internas MP
Aadd(aMovi,0) //Entradas Importa��o MP

dbSelectArea("SF3")
dbSetOrder(1)               

#IFDEF TOP
	aStruSF3  := SF3->(dbStruct())
    If TcSrvType()<>"AS/400"
	    lQuery 		:= .T.
		cAliasSF3	:= GetNextAlias()
		aStru  		:= SF3->(dbStruct())
		cQuery 		:= "SELECT SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_ESTADO, "
		cQuery 		+= "SF3.F3_CFO,SF3.F3_TIPO,SF3.F3_VALCONT,SF3.F3_BASEICM,SF3.F3_OUTRICM,SF3.F3_ISENICM,SF3.F3_ICMSRET,SF3.F3_VALICM " 
		cQuery 		+= "FROM " + RetSqlName("SF3") + " SF3 " 
		cQuery		+= "WHERE SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "    
		cQuery 		+= "SF3.F3_ENTRADA >= '" + DTOS(dDataIni) + "' AND "
		cQuery 		+= "SF3.F3_ENTRADA <= '" + DTOS(dDataFim) + "' AND "
		cQuery 		+= "SF3.F3_DTCANC = '" + Dtos(Ctod("")) + "' AND "
		cQuery 		+= "SF3.F3_TIPO <> 'S' AND "
		cQuery 		+= "SF3.D_E_L_E_T_ = ' ' "
		cQuery 		+= "ORDER BY " + SqlOrder(SF3->(IndexKey()))
	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
		
		dbSelectArea(cAliasSF3)	
	Else
#ENDIF
	    cIndex    		:= CriaTrab(NIL,.F.)
	    cCondicao 		:= 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
	   	cCondicao 		+= 'DTOS(F3_ENTRADA) >= "' + DTOS(dDataIni) + '" .And. '
	   	cCondicao 		+= 'DTOS(F3_ENTRADA) <= "' + DTOS(dDataFim) + '" .And. '
		cCondicao		+= 'Empty(F3_DTCANC) .And. '
		cCondicao		+= 'F3_TIPO <> "S" '
		
	    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
	    dbSelectArea(cAliasSF3)
	    ProcRegua(LastRec())
	    dbGoTop()
#IFDEF TOP
	Endif
#ENDIF

While !(cAliasSF3)->(Eof())
	
	IncProc("Processando Movimenta��es")
	//���������������������������������Ŀ
	//�Compras e transferencias no Pais |
	//�����������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][01]
		aMovi[1] += (cAliasSF3)->F3_VALCONT
	Endif
	
	//���������������������������Ŀ
	//�Entradas do Exterior       �
	//�����������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][02]
		aMovi[2] += (cAliasSF3)->F3_VALCONT
	Endif
	
	//���������������������������������Ŀ
	//�Vendas e transferencias no Pais  |
	//�����������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][03]
		aMovi[3] += (cAliasSF3)->F3_VALCONT
	Endif

	//���������������������������Ŀ
	//�Saidas p/ Exterior         �
	//�����������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][04]
		aMovi[4] += (cAliasSF3)->F3_VALCONT
	Endif
	
	//������������������������������Ŀ
	//�Entrada de Ativo Imobilizado  �
	//��������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][05]
		aMovi[5] += (cAliasSF3)->F3_VALCONT
	Endif
	
	//������������������������������������������Ŀ
	//�Entrada de Ativo Imobilizado do Exterior  |
	//��������������������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][06]
		aMovi[6] += (cAliasSF3)->F3_VALCONT
	Endif
	
	//��������������������������������������Ŀ
	//�Entrada de Material de Uso e Consumo  |
	//����������������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][07]
		aMovi[7] += (cAliasSF3)->F3_VALCONT
	Endif
		
	//�������������������������������������������������Ŀ
	//�Entrada de Material de Uso e Consumo do Exterior |
	//���������������������������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][08]
		aMovi[8] += (cAliasSF3)->F3_VALCONT
	Endif
	
	//�������������������������������������������������Ŀ
	//�Entrada de Materia Prima no Pais                 |
	//���������������������������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][09]
		aMovi[9] += (cAliasSF3)->F3_VALCONT
	Endif

	//�������������������������������������������������Ŀ
	//�Entrada de Materia Prima do Exterior             |
	//���������������������������������������������������
	If AllTrim((cAliasSF3)->F3_CFO) $ aWizard[03][10]
		aMovi[10] += (cAliasSF3)->F3_VALCONT
	Endif
	
	(cAliasSF3)->(dbSkip())
Enddo
                           
//���������������������������������������Ŀ
//�Exclui area de trabalho utilizada - SF3�
//�����������������������������������������
If !lQuery
	RetIndex("SF3")	
	dbClearFilter()	
	Ferase(cIndex+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	dbCloseArea()
Endif		

Return (aMovi)
