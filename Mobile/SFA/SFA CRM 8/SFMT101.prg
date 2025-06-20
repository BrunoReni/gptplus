#INCLUDE "SFMT101.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MetaRefresh         矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Alterna o Tipo da Meta que sera pesquisada	 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nTipoMet - (1-Meta do Mes, 2-Meta por grupo);			  潮�
北�          � aMeta - Array com dados da Meta; 						  潮�
北�          � oSayGrp, oCboGrupo - Controle do Grupo      	              潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � LoadMes             矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Arrays do Meses    				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aMeses - Array dos Meses   	  							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function LoadMes(aMeses)
Local nI := 1

For nI := 1 To 12
	aAdd(aMeses, StrZero(nI,2) + "/" + Str(Year(Date()),4,0))
Next

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � LoadGrupos          矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Arrays dos Grupos  				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aGrupo - Array dos Grupos   	  							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CalcMtMes           矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Arrays por Meses    				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aMeta - Array das Metas;                                   潮�
北�			 � oBrwMet - Browse das Metas								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CalcMtGrupo         矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Arrays por Grupo    				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aMeta - Array das Metas; cMesAno - Mes/Ano da Pesquisa	  潮�
北�			 � cGrupo - Codigo do Grupo  								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
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
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PesqProd            矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Mostra a descricao do Produto quando selecionado no Browse 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� oBrw - Browse selecionado; oGet - Get da Descricao	      潮�
北�			 � cPrdDesc - Descricao do Produto; aX - Array do Browse	  潮�
北�			 � cPrdPos - Posicao do Array que contem o dodigo do produto  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
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
