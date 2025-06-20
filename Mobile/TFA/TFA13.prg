#INCLUDE "TFA13.ch"
#include "eADVPL.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � OpenFiles           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Abre todos os arquivos utilizados pelo SFA	 			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
Local lRet       := .T.
Local cStr       := ""
Local aTable     := {}
Local cTable     := ""
Local nTblRecs   := ADVTBL->(RecCount())
Local nAtuRecs   := 0
Local cTblNoOpen := "ADV_IND/HEMP" + "HA3" + cEmpresa
Local nContem    := 0

ShowControl(oSayFile)
ShowControl(oMeterFiles)

dbSelectArea("ADVTBL")
dbSetOrder(1)
dbGoTop()
While !ADVTBL->(Eof()) .And. lRet
	nContem := At(AllTrim(ADVTBL->TBLNAME), cTblNoOpen)
	If cTable != AllTrim(ADVTBL->TBLNAME) .And. nContem = 0
		cTable := AllTrim(ADVTBL->TBLNAME)
		If File(cTable)	
			SetText(oSayFile, STR0001 + ADVTBL->DESCR + Space(5)) //"Abrindo "
			lRet := OpenFile(cTable)
		Else
			// Criar Tabela e Indices
			SetText(oSayFile, STR0002 + ADVTBL->DESCR + Space(5)) //"Criando "
			lRet := OpenFile(cTable, .T.)
		EndIf
	EndIf
	ADVTBL->(dbSkip())
	nAtuRecs += 1
	nMeterFiles := (nAtuRecs/nTblRecs) * 100
	SetMeter(oMeterFiles,nMeterFiles)
EndDo

Return lRet

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � OpenFile            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Abre um arquivo 								 			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cAlias: Alias a ser aberto, nIndex - Quantida de Indices	  潮�
北�          � cEmpresa: Codigo da Empresa								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function OpenFile(cTable, lCreate, lReindex)
Local nIndex := 1
Local cAlias := Substr(cTable,1,3)
Local lRet   := .F.
Local aStru  := {}

lCreate  := If(lCreate  = Nil, lCreate  := .F., lCreate)
lReindex := If(lReindex = Nil, lReindex := .F., lReindex)

// Cria tabela inexistente
If lCreate
	dbSelectArea("ADVTBL")
	dbSetOrder(1)
	While !ADVTBL->(Eof()) .And. AllTrim(ADVTBL->TBLNAME) = cTable
		//aAdd(aStru, {AllTrim(ADVTBL->FLDNAME), ADVTBL->FLDNAME, ADVTBL->FLDTYPE, ADVTBL->FLDLENDEC})
		aAdd(aStru, {AllTrim(ADVTBL->FLDNAME), ADVTBL->FLDTYPE, ADVTBL->FLDLEN, ADVTBL->FLDLENDEC})
		ADVTBL->(dbSkip())
	EndDo
	dbCreate(cTable, aStru, "LOCAL" )
	
	lRet := dbUseArea( .T., "LOCAL", cTable, cAlias, .T., .F. )
	
	dbSelectArea("ADVIND")
	dbSetOrder(1)
	If dbSeek(cTable) .And. lRet
		nIndex := 1
		While !ADVIND->(Eof()) .And. cTable = AllTrim(ADVIND->TBLNAME)
			dbSelectArea(cAlias)
			dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)
			dbSetIndex(AllTrim(ADVIND->NOME_IDX))
			dbSelectArea("ADVIND")
			ADVIND->(dbSkip())
		EndDo
	EndIf
Else
// Abrindo tabela
	lRet := dbUseArea( .T., "LOCAL", cTable, cAlias, .T., .F. )
	
	dbSelectArea("ADVIND")
	dbSetOrder(1)
	If dbSeek(cTable) .And. lRet
		// reindexa  as tabelas conforme parametro
		If lReindex
			nIndex := 1
			While !ADVIND->(Eof()) .And. cTable = AllTrim(ADVIND->TBLNAME)
				dbSelectArea(cAlias)
				dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)
				dbSetIndex(AllTrim(ADVIND->NOME_IDX))
				dbSelectArea("ADVIND")
				ADVIND->(dbSkip())
			EndDo		
		Else
			While !ADVIND->(Eof()) .And. cTable = AllTrim(ADVIND->TBLNAME)
				dbSelectArea(cAlias)
				If !File(AllTrim(ADVIND->NOME_IDX))
					dbCreateIndex(AllTrim(ADVIND->NOME_IDX), AllTrim(ADVIND->EXPRE),)	
				EndIf
				dbSetIndex(AllTrim(ADVIND->NOME_IDX))
				dbSelectArea("ADVIND")
				ADVIND->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf
Return lRet

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � VldSenha            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Validacao da Senha							 			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cSenha: senha digitada, lClose - Fecha a janela			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles)
Local lRet   := .T.
Local lClose := .F.

If AllTrim(cSenha) != AllTrim(AA1->AA1_SENHA)
	MsgStop(STR0003,STR0004) //"Senha Invalida!"###"Aviso"
	nTry += 1
	lRet := .F.
	If nTry > nTimes
		lClose := .T.
	EndIf
Else
	lClose := .T.
	lRet := OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
EndIf

If lClose
	CloseDialog()
EndIf
Return lRet
