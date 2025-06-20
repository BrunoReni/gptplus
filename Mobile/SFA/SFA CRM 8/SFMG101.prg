#INCLUDE "SFMG101.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MsgRefresh()        矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao que atualiza tela e array das mensagens 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nTipoMsg - Tipo da Mensagem (1-Enviado, 2-Recebida)		  潮�
北� 		 � aMsg - Array que cont閙 as mensagens 					  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/

Function MsgRefresh(nTipoMsg, oBrwMsg, aMsg, oBtnAlt, oBtnInc)

If nTipoMsg = 1
	HideControl(oBtnAlt)
	HideControl(oBtnInc)
Else
	ShowControl(oBtnAlt)
	ShowControl(oBtnInc)
EndIf
aSize(aMsg, 0)
dbSelectArea("HMV")
dbSetOrder(1)
dbSeek(RetFilial("HMV"))
//dbGoTop()
While !Eof()
	If HMV->HMV_ORI = Str(nTipoMsg,1,0)
		aAdd(aMsg, {HMV->HMV_COD, HMV->HMV_MSG, HMV->HMV_STATUS})
	EndIf
	dbSkip()
End
SetArray(oBrwMsg, aMsg)
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CrgProxMsg()        矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega o codigo da proxima mensagem incluida			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nTipoMsg - Tipo da Mensagem (1-Enviado, 2-Recebida)		  潮�
北� 		 � aMsg - Array que cont閙 as mensagens 					  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function CrgProxMsg(cCodMsg)
Local nRecno := HMV->(Recno())

dbSelectArea("HMV")
dbGoBottom()
If !Empty(HMV->HMV_COD)
	cCodMsg := StrZero(Val(HMV->HMV_COD) + 1,6)
Else
	cCodMsg := "000001"
EndIf

Return .T.

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � GrvMensagem()       矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Grava dados do CLiente 									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOpMsg - Operacao (1 - Inclusao, 2 Alteracao)			  潮�
北�			 � cCodMsg - Codigo da Mensagem, cMsg - Mensagem      		  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function GrvMensagem(nOpMsg, cCodMsg, cMsg, cVend, dDataMsg, dDataVig, oBrwMsg, aMsg, nTipoMsg)
Local nPos := 0

If !VrfMensagem(cCodMsg,cMsg)
	Return Nil
Endif

dbSelectArea("HMV")
dbSetOrder(1)
If nOpMsg == 1
	dbAppend()
	HMV->HMV_FILIAL := RetFilial("HMV")
	HMV->HMV_COD    := cCodMsg
	HMV->HMV_MSG    := cMsg
	HMV->HMV_ORI    := "2"
	HMV->HMV_VEND   := cVend
	HMV->HMV_DATA   := dDataMsg
	HMV->HMV_DTVIG  := dDataVig
	HMV->HMV_STATUS := "N"
Else
	dbSeek(RetFilial("HMV") + cCodMsg)
	HMV->HMV_COD    := cCodMsg
	HMV->HMV_MSG    := cMsg
	HMV->HMV_ORI    := "2"
	HMV->HMV_VEND   := cVend
	HMV->HMV_DATA   := dDataMsg
	HMV->HMV_DTVIG  := dDataVig
	If HMV->HMV_STATUS <> "N"
		HMV->HMV_STATUS	:="A"
	Endif
Endif
dbCommit()
If nTipoMsg = 2
	If nOpMsg = 1
		aAdd(aMsg, {HMV->HMV_COD, HMV->HMV_MSG, HMV->HMV_STATUS})
	ElseIf nOpMsg = 2
		nPos := GridRow(oBrwMsg)
		aMsg[nPos,1] := HMV->HMV_COD
		aMsg[nPos,2] := HMV->HMV_MSG
		aMsg[nPos,3] := HMV->HMV_STATUS
	EndIf
EndIf
MsgAlert(STR0001) //"Mensagem Gravada com sucesso"
CloseDialog()

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � VrfMensagem()       矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Valida dados da Mensagem 								  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodMsg - Codigo da Mensagem, cMsg - Mensagem      		  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function VrfMensagem(cCodMsg,cMsg)

cCodMsg 	:= Alltrim(cCodMsg)
cMsg	    := AllTrim(cMsg)

if Empty(cCodMsg)
	MsgStop(STR0002,STR0003) //"codigo da Mensagem invalido!"###"Verifica Mensagem"
	Return .F.
Elseif Empty(cMsg)
	MsgStop(STR0004,STR0003) //"Mensagem em Branco!"###"Verifica Mensagem"
	Return .F.
EndIf	

Return .T.

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ExcMensagem()       矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Exclui uma Mensagem 								          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodMsg - Codigo da Mensagem, cMsg - Mensagem      		  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ExcMensagem(cCodMsg, aMsg, nTipoMsg, nOpMsg, oBrwMsg)
Local cResp	:= "", nPos := 0
Local nLin	:= 1
cResp:= if(MsgYesOrNo(STR0005,STR0006),STR0007,STR0008) //"Voc� deseja Excluir a Mensagem Selecionada?"###"Cancelar"###"Sim"###"N鉶"
If cResp=STR0007 //"Sim"
	dbSelectArea("HMV")
	dbSetOrder(1)
	dbSeek(RetFilial("HMV") + cCodMsg)
	If HMV->(Found()) 
		dbDelete()
		dbSkip()
		Alert(STR0009) //"Mensagem Exclu韉a com Sucesso!"
	Endif
	nPos := GridRow(oBrwMsg)
	aDel(aMsg, nPos)
	aSize(aMsg, Len(aMsg)-1)
	CloseDialog()	
Endif

If nPos > 1
	nLin := nPos - 1
EndIf
GridSetRow(oBrwMsg, nLin)

Return Nil
