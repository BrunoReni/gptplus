/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � MetaRefresh         �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Alterna o Tipo da Meta que sera pesquisada	 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nTipoMet - (1-Meta do Mes, 2-Meta por grupo);			  ���
���          � aMeta - Array com dados da Meta; 						  ���
���          � oSayGrp, oCboGrupo - Controle do Grupo      	              ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo)

//nTipoMet
// 1 - Meta por Mes
// 2 - Meta por Grupo
If nTipoMet = 1
	HideControl(oCboGrupo)
	HideControl(oSayGrp)
ElseIf nTipoMet = 2
	ShowControl(oCboGrupo)
	ShowControl(oSayGrp)
EndIf

Return Nil


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � LoadMes             �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Arrays do Meses    				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aMeses - Array dos Meses   	  							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function LoadMes(aMeses)
Local nI := 1

For nI := 1 To 12
	aAdd(aMeses, StrZero(nI,2) + "/" + Str(Year(Date()),2,0))
Next

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � LoadGrupos          �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Arrays dos Grupos  				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aGrupo - Array dos Grupos   	  							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function LoadGrupos(aGrupo)
Local nI := 1

dbSelectArea("HBM")
dbSetOrder(1)
dbGoTop()
While !Eof()
	aAdd(aGrupo, HBM->BM_GRUPO + " - " + HBM->BM_DESC)
	dbSkip()
EndDo
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CalcMtMes           �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Arrays por Meses    				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aMeta - Array das Metas; cColuna1 - Label da 1a Coluna	  ���
���			 � oBrwMet - Browse das Metas								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CalcMtMes(aMeta, cColuna1, oBrwMet)
Local nTotQtd := 0, nTotValor := 0, nTotQtdR := 0, nTotValorR := 0
Local cMes    := ""

cColuna1 := "Mes"
aSize(aMeta,0)
dbSelectArea("HMT")
dbSetOrder(1)
dbGoTop()
cMes       := HMT->MT_DATA
While !HMT->(Eof())
	nTotQtd    += HMT->MT_QTD
	nTotValor  += HMT->MT_VALOR
	nTotQtdR   += HMT->MT_QTDR
	nTotValorR += HMT->MT_VALORR
	HMT->(dbSkip())	
	If cMes != HMT->MT_DATA .Or. Eof()
		aAdd(aMeta, {cMes, nTotQtd, nTotValor, nTotQtdR, nTotValorR})
		nTotQtd    := 0
		nTotValor  := 0
		nTotQtdR   := 0
		nTotValorR := 0
		cMes       := HMT->MT_DATA
	EndIf
EndDo

SetArray(oBrwMet, aMeta)

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CalcMtGrupo         �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Arrays por Grupo    				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aMeta - Array das Metas; cMesAno - Mes/Ano da Pesquisa	  ���
���			 � cGrupo - Codigo do Grupo  								  ���
���			 � cColuna1 - Label da 1a Coluna; oBrwMet - Browse das Metas  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CalcMtGrupo(aMeta, cMesAno, cGrupo, cColuna1, oBrwMet)
Local nTotQtd  := 0, nTotValor := 0, nTotQtdR := 0, nTotValorR := 0
Local cProd    := ""
Local cMes     := Substr(cMesAno,1,2)
Local cAno     := Substr(cMesAno,4,4)

cMesAno := AllTrim(cMes + cAno)
cGrupo  := AllTrim(SubStr(cGrupo,1,At("-", cGrupo)-1))

cColuna1 := "Grupo"
aSize(aMeta,0)
dbSelectArea("HMT")
dbSetOrder(1)
If dbSeek(cMesAno + cGrupo)
	cProd    := HMT->MT_PROD
Else
	Alert("Sem dados")
EndIf
While !HMT->(Eof()) .And. cMesAno = HMT->MT_DATA .And. cGrupo = HMT->MT_GRUPO
	nTotQtd    += HMT->MT_QTD
	nTotValor  += HMT->MT_VALOR
	nTotQtdR   += HMT->MT_QTDR
	nTotValorR += HMT->MT_VALORR
	HMT->(dbSkip())	
	If cProd != HMT->MT_PROD .Or. Eof()
		aAdd(aMeta, {AllTrim(cProd), nTotQtd, nTotValor, nTotQtdR, nTotValorR})
		nTotQtd    := 0
		nTotValor  := 0
		nTotQtdR   := 0
		nTotValorR := 0
		cProd      := HMT->MT_PROD
	EndIf
EndDo

SetArray(oBrwMet, aMeta)

Return Nil


Function PesquisaMeta(nTipoMet, aMeta, cMesAno, cGrupo, cColuna1, oBrwMet, oFldData, oDlg)
If nTipoMet = 1
	CalcMtMes(aMeta, @cColuna1, oBrwMet)
ElseIf nTipoMet = 2
	CalcMtGrupo(aMeta, cMesAno, cGrupo, @cColuna1, oBrwMet)
EndIf

//SET ACTIVE FOLDER oFldData OF oDlg
//SetFolder(oDlg,oFldData)

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PesqProd            �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Mostra a descricao do Produto quando selecionado no Browse ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oBrw - Browse selecionado; oGet - Get da Descricao	      ���
���			 � cPrdDesc - Descricao do Produto; aX - Array do Browse	  ���
���			 � cPrdPos - Posicao do Array que contem o dodigo do produto  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PesqProd(oBrw, oGet, cPrdDesc, aX, nPrdPos)
Local nLinha := GridRow(oBrw)
Local cCodPrd := aX[nLinha, nPrdPos]

dbSelectArea("HB1")
dbSetOrder(1)
If dbSeek(cCodPrd)
	cPrdDesc := AllTrim(HB1->B1_DESC)
EndIf
SetText(oGet, cPrdDesc)

Return Nil