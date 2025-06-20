#INCLUDE "SFMT101.ch"
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
	aAdd(aMeses, StrZero(nI,2) + "/" + Str(Year(Date()),2,0))
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
Local nI := 1

dbSelectArea("HBM")
dbSetOrder(1)
dbGoTop()
While !Eof()
	aAdd(aGrupo, HBM->BM_GRUPO + "-" + HBM->BM_DESC)
	dbSkip()
EndDo
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CalcMtMes           矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Arrays por Meses    				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aMeta - Array das Metas; cColuna1 - Label da 1a Coluna	  潮�
北�			 � oBrwMet - Browse das Metas								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function CalcMtMes(aMeta, cMesAno, cGrupo, cColuna1, oMeterMeta)
Local nTotQtd := 0, nTotValor := 0, nTotQtdR := 0, nTotValorR := 0
Local cMes    := Substr(cMesAno,1,2)
Local cAno    := Substr(cMesAno,4,4)
Local cSeek   := AllTrim(cMes + cAno)

cColuna1 := STR0001 //"Mes"
aSize(aMeta,0)

dbSelectArea("HMT")
dbGoTop()
dbSetOrder(1)
dbSeek(cSeek,.t.)

While !HMT->(Eof()) .And. HMT->MT_DATA == cSeek
	cMes	   := HMT->MT_DATA
	nTotQtd    += HMT->MT_QTD
	nTotValor  += HMT->MT_VALOR
	nTotQtdR   += HMT->MT_QTDR
	nTotValorR += HMT->MT_VALORR
	HMT->(dbSkip())	
	If cMes != HMT->MT_DATA .Or. HMT->(Eof())
		aAdd(aMeta, {cMes, nTotQtd, nTotValor, nTotQtdR, nTotValorR})
		nTotQtd    := 0
		nTotValor  := 0
		nTotQtdR   := 0
		nTotValorR := 0
		cMes       := HMT->MT_DATA
		exit
	EndIf
EndDo

If Len(aMeta) == 0
	Alert(STR0003) //"Sem dados"
Endif

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
北�			 � cColuna1 - Label da 1a Coluna; oBrwMet - Browse das Metas  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function CalcMtGrupo(aMeta, cColuna1, oMeterMeta)
Local nQtdRec   := 0
Local cProd     := ""
Local nHmtRecs  := HMT->(RecCount())
Local nHmtCount := 0
Local nPos      := 0
cColuna1 := "Grupo"

aSize(aMeta,0)
dbSelectArea("HMT")
dbSetOrder(2)
dbGotop()
While !HMT->(Eof())
//	SetText(oSayMeter, cColuna1 + ": " + AllTrim(HMT->MT_GRUPO))
	nPos := ScanArray(aMeta, AllTrim(HMT->MT_GRUPO),,,1)
	If nPos = 0
		aAdd(aMeta, {AllTrim(HMT->MT_GRUPO), 0, 0, 0, 0})
		nPos := Len(aMeta)
	EndIf
	aMeta[nPos, 2] := aMeta[nPos, 2] + HMT->MT_QTD
	aMeta[nPos, 3] := aMeta[nPos, 3] + HMT->MT_VALOR
	aMeta[nPos, 4] := aMeta[nPos, 4] + HMT->MT_QTDR
	aMeta[nPos, 5] := aMeta[nPos, 5] + HMT->MT_VALORR	
	HMT->(dbSkip())	
	nHmtCount++
	SetMeter(oMeterMeta, (nHmtRecs * 100 /nHmtCount)) 
EndDo

If Len(aMeta) == 0
	Alert(STR0003) //"Sem dados"
Endif
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CalcMtProd         矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Arrays por Grupo    				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aMeta - Array das Metas; cMesAno - Mes/Ano da Pesquisa	  潮�
北�			 � cGrupo - Codigo do Grupo  								  潮�
北�			 � cColuna1 - Label da 1a Coluna; oBrwMet - Browse das Metas  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function CalcMtProd(aMeta, cColuna1, oMeterMeta)
Local nTotQtd  := 0, nTotValor := 0, nTotQtdR := 0, nTotValorR := 0
Local cProd    := ""
Local nHmtRecs := HMT->(RecCount())
Local nHmtCount := 0
Local nPos      := 0
cColuna1 := "Produto"

aSize(aMeta,0)
dbSelectArea("HMT")
dbSetOrder(3)
dbGotop()
While !HMT->(Eof())
//	SetText(oSayMeter, cColuna1 + ": " + AllTrim(HMT->MT_PROD))

	nPos := ScanArray(aMeta, AllTrim(HMT->MT_PROD),,,1)
	If nPos = 0
		aAdd(aMeta, {AllTrim(HMT->MT_PROD), 0, 0, 0, 0})
		nPos := Len(aMeta)
	EndIf
	aMeta[nPos, 2] := aMeta[nPos, 2] + HMT->MT_QTD
	aMeta[nPos, 3] := aMeta[nPos, 3] + HMT->MT_VALOR
	aMeta[nPos, 4] := aMeta[nPos, 4] + HMT->MT_QTDR
	aMeta[nPos, 5] := aMeta[nPos, 5] + HMT->MT_VALORR	
	
	HMT->(dbSkip())	
	nHmtRecs++
	SetMeter(oMeterMeta, (nHmtRecs/nHmtCount) )
EndDo

If Len(aMeta) == 0
	Alert(STR0003) //"Sem dados"
Endif

Return Nil

Function PesquisaMeta(nTipoMet, aMeta, cColuna1, oMeterMeta, oBrwMet, oFldData, oDlg)

//ShowControl(oSayMeter)
ShowControl(oMeterMeta)

If nTipoMet = 1
	CalcMtGrupo(aMeta, @cColuna1, oMeterMeta)
ElseIf nTipoMet = 2
	CalcMtProd(aMeta, @cColuna1, oMeterMeta)
EndIf

//HideControl(oSayMeter)
HideControl(oMeterMeta)
SET ACTIVE FOLDER oFldData OF oDlg
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PesqItem            矨utor: Fabio Garbin  � Data �13/10/02 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Mostra a descricao do Produto quando selecionado no Browse 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� oBrw - Browse selecionado; oGet - Get da Descricao	      潮�
北�			 � cPrdDesc - Descricao do Produto; aX - Array do Browse	  潮�
北�			 � nTipoMet - Classificacao por grupo ou produto  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PesqItem(oBrw, oGet, aItemPsq, cItemDesc, nTipoMet, nCol)
Local nLinha     := GridRow(oBrw)
Local cCodItem := ""
Local cAlias      := If(nTipoMet = 1, "HBM", "HB1")

If nCol = Nil
	nCol := 1
EndIf

cCodItem := aItemPsq[nLinha, nCol]
dbSelectArea(cAlias)
dbSetOrder(1)
If dbSeek(cCodItem)
	cItemDesc := If(nTipoMet = 1,AllTrim(HBM->BM_DESC) ,AllTrim(HB1->B1_DESC))
Else
	cItemDesc := ""
EndIf
SetText(oGet, cItemDesc)

Return Nil

Function AtuFolderData(oBrwMet, aMeta)
SetArray(oBrwMet, aMeta)
Return Nil