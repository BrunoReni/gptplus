#INCLUDE "SFMT101.ch"
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
Function MetaRefresh(nTipoMet, aMeta, oSayGrp, oCboGrupo, oSayMes, oCboMeses)
//nTipoMet
// 1 - Meta por Mes
// 2 - Meta por Grupo
If nTipoMet = 1
	HideControl(oCboGrupo)
	HideControl(oSayGrp)
	ShowControl(oCboMeses)
	ShowControl(oSayMes)
ElseIf nTipoMet = 2
	HideControl(oCboMeses)
	HideControl(oSayMes)
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
	aAdd(aMeses, StrZero(nI,2) + "/" + Str(Year(Date()),4,0))
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
Local nPos := 0
Local cGrupo := ""
Local cTabelaFil := RetFilial("HBM")
dbSelectArea("HBM")
dbSetOrder(1)
dbSeek(cTabelaFil)
//dbGoTop()
//If Len(aGrupo) = 0
While !Eof() .And. HBM->HBM_FILIAL = cTabelaFil
	cGrupo := HBM->HBM_GRUPO + "-" + AllTrim(HBM->HBM_DESC)
	nPos := ScanArray(aGrupo, cGrupo,,,1) 
	If nPos = 0
		aAdd(aGrupo, cGrupo)
	EndIf
	dbSkip()
EndDo
//EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CalcMtMes           �Autor: Fabio Garbin  � Data �13/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Arrays por Meses    				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aMeta - Array das Metas;                                   ���
���			 � oBrwMet - Browse das Metas								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CalcMtMes(aMeta, cMesAno, cGrupo, oBrwMet)
Local nTotQtd := 0, nTotValor := 0, nTotQtdR := 0, nTotValorR := 0
Local cMes    := Substr(cMesAno,1,2)
Local cAno    := Substr(cMesAno,4,4)
Local cSeek   := cMes + cAno
Local cProd   := ""
Local lAdd	  := .F.

aSize(aMeta,0)

dbSelectArea("HMT")
dbSetOrder(1)
dbSeek(RetFilial("HMT") + cSeek,.t.)

While !HMT->(Eof()) .And. HMT->HMT_MESANO == cSeek
	cProd	   := HMT->HMT_PROD
	nTotQtd    := 0
	nTotValor  := 0
	nTotQtdR   := 0
	nTotValorR := 0
	While !HMT->(Eof()) .And. cProd == HMT->HMT_PROD
		nTotQtd    += HMT->HMT_QTD
		nTotValor  += HMT->HMT_VALOR
		nTotQtdR   += HMT->HMT_QTDR
		nTotValorR += HMT->HMT_VALORR
		HMT->(dbSkip())	
	EndDo
	aAdd(aMeta, {cProd, nTotQtd, nTotValor, nTotQtdR, nTotValorR})
EndDo

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
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CalcMtGrupo(aMeta, cMesAno, cGrupo, oBrwMet)
Local nTotQtd := 0, nTotValor := 0, nTotQtdR := 0, nTotValorR := 0
Local cProd   := ""

aSize(aMeta,0)
cGrupo  := SubStr(cGrupo,1,At("-", cGrupo)-1)

dbSelectArea("HMT")
dbSetOrder(2)
dbSeek(RetFilial("HMT") + cGrupo,.t.)

While !HMT->(Eof()) .And. Alltrim(cGrupo) == Alltrim(HMT->HMT_GRUPO)
	cProd	   := HMT->HMT_PROD
	nTotQtd    := 0
	nTotValor  := 0
	nTotQtdR   := 0
	nTotValorR := 0
	While !HMT->(Eof()) .And. cProd == HMT->HMT_PROD
		nTotQtd    += HMT->HMT_QTD
		nTotValor  += HMT->HMT_VALOR
		nTotQtdR   += HMT->HMT_QTDR
		nTotValorR += HMT->HMT_VALORR
		HMT->(dbSkip())	
	EndDo
	aAdd(aMeta, {cProd, nTotQtd, nTotValor, nTotQtdR, nTotValorR})
EndDo

Return Nil

Function PesquisaMeta(nTipoMet, aMeta, cMesAno, cGrupo, oBrwMet, oFldData, oDlg)
//Local oSay
//Local cTexto := ""
//@ 16,05 SAY oSay PROMPT Space(40) OF oFldData
If nTipoMet = 1
	CalcMtMes(aMeta, cMesAno, cGrupo,  oBrwMet)
	//cTexto := "Mes/Ano:  " + Alltrim(cMesAno)
ElseIf nTipoMet = 2
	CalcMtGrupo(aMeta, cMesAno, cGrupo, oBrwMet)
	//cTexto := "Grupo:  " + Alltrim(cGrupo)
EndIf

SetArray(oBrwMet, aMeta)
//Alert(cTexto)
//SetText(oSay, cTexto)

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
If dbSeek(RetFilial("HB1") + cCodPrd)
	cPrdDesc := AllTrim(HB1->HB1_DESC)
EndIf
SetText(oGet, cPrdDesc)

Return Nil
