#INCLUDE "SFMG001.ch"
#include "eADVPL.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � InitMensagem        矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Inicia o Modulo de Mensagens             	 			        潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function InitMensagem()

Local oDlg, ocboTipo, oBrwMsg
Local oBtnInc, oBtnAlt, oBtnVisual, oBtnRet
Local aCampo := {}, nCampo := 1, nTipoMsg := 1
Local aTipoMsg := {STR0001, STR0002}, aMsg := {} //"Recebidas"###"Enviadas"
Local cTable := "HMV"
Local oCol
Local nTamBox := Iif(lNotTouch,35,70)

If !(Select("HMV")>0)
	MsgStop(STR0003 + cTable + STR0004,STR0005) //"Tabela de Mensagens "###" n鉶 encontrada!"###"Aviso"
	return nil
EndIf

//Apaga as mensagens com data de vig阯cia excedida
dbSelectArea("HMV")
HMV->(dbSetOrder(2))
While !HMV->(EOF())
	If HMV->HMV_DTVIG >= Date()
		Exit
	EndIf
	HMV->(dbDelete())
	HMV->(dbSkip())
End
DEFINE DIALOG oDlg TITLE STR0006 //"Manuten玢o de Mensagens"

@ 15,05 COMBOBOX oCboTipo VAR nTipoMsg ITEMS aTipoMsg ACTION MsgRefresh(nTipoMsg, oBrwMsg, aMsg, oBtnAlt, oBtnInc) SIZE 145,nTamBox of oDlg
@ 40,05 BROWSE oBrwMsg SIZE 145,95 OF oDlg
SET BROWSE oBrwMsg ARRAY aMsg
ADD COLUMN oCol TO oBrwMsg ARRAY ELEMENT 1 HEADER STR0007 WIDTH 45 //"Codigo"
ADD COLUMN oCol TO oBrwMsg ARRAY ELEMENT 2 HEADER STR0008 WIDTH 55 //"Mensagem"
ADD COLUMN oCol TO oBrwMsg ARRAY ELEMENT 3 HEADER STR0009 WIDTH 40 //"Status"

@ 140,02 BUTTON oBtnInc CAPTION STR0010 SIZE 30,12 ACTION MsgMan(1, nTipoMsg, aMsg, oBrwMsg) of oDlg //"Incluir"
@ 140,35 BUTTON oBtnAlt CAPTION STR0011 SIZE 35,12 ACTION MsgMan(2, nTipoMsg, aMsg, oBrwMsg) of oDlg //"Alterar"
@ 140,73 BUTTON oBtnVisual CAPTION STR0012 SIZE 40,12 ACTION MsgMan(3, nTipoMsg, aMsg, oBrwMsg) of oDlg //"Visual"
@ 140,117 BUTTON oBtnRet CAPTION STR0013 SIZE 40,12 ACTION CloseDialog() of oDlg //"Retornar"

MsgRefresh(nTipoMsg, oBrwMsg, aMsg, oBtnAlt, oBtnInc)

ACTIVATE DIALOG oDlg

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MsgMan()            矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao de manutencao de mensagens 			              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOpMsg - (1-Inclusao, 2-Alteracao, 3-Detalhes);			  潮�
北�			 � nTipoMsg - Tipo da Mensagem (1-Enviado, 2-Recebida)		  潮�
北� 		 � aMsg - Array que cont閙 as mensagens 					  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function MsgMan(nOpMsg, nTipoMsg, aMsg, oBrwMsg)
Local oDlg, oSay, oMsg, oBtnRet, oBtnGra, oBtnExc, oCodMsg
Local cCodMsg:= Space(6), cMsg:=Space(255)
Local cTipoMsg := Space(1), cVend := Space(6)
Local dDataMsg := Date(), dDataVig := Date(), cStatus := Space(1)
Local nLinha := 0

dbSelectArea("HA3")
dbSetOrder(1)
cVend := HA3->HA3_COD

if nOpMsg == 1
	if !CrgProxMsg(@cCodMsg) 
	    Return Nil
	Endif
	cMsg := ""
Else
	nLinha 	:= GridRow(oBrwMsg)
	If nLinha != 0 .And. Len(aMsg) != 0 .And. nLinha <= Len(aMsg)
		cCodMsg := aMsg[nLinha,1]
	Else
		MsgStop(STR0014,STR0015) //"Nenhuma mensagem selecionada."###"Mensagens"
		Return Nil
	EndIf

	dbSelectArea("HMV")
	dbSetOrder(1)
	dbSeek(RetFilial("HMV") + cCodMsg)
	
	If HMV->(Found())
		If nTipoMsg == 2 .And. nOpMsg == 2 //Enviadas/Alterar 
			If HMV->HMV_STATUS == "N" .And. !HMV->(IsDirty())	//Transmitido
				MsgAlert(STR0016,STR0005) //"Mensagem j� transmitida, n鉶 � poss韛el alter�-la."###"Aviso"
				return nil
			Endif
		Endif
		cCodMsg		:= HMV->HMV_COD
		cMsg 	    := HMV->HMV_MSG
		cTipoMsg	:= HMV->HMV_ORI
		cVend 		:= HMV->HMV_VEND
		dDataMsg 	:= HMV->HMV_DATA
		dDataVig 	:= HMV->HMV_DTVIG
		cStatus     := HMV->HMV_STATUS
	EndIf
Endif

if nOpMsg == 1 
	DEFINE DIALOG oDlg TITLE STR0017 //"Inclus鉶 da Mensagem"
Elseif nOpMsg == 2  
	DEFINE DIALOG oDlg TITLE STR0018 //"Alterac鉶 da Mensagem"
Else	
	DEFINE DIALOG oDlg TITLE STR0019 //"Visualizar Mensagem"
Endif

@ 18,02 SAY oSay PROMPT STR0020 of oDlg //"Codigo: "
@ 30,02 SAY oSay PROMPT STR0021 of oDlg //"Mensagem: "

@ 140,110 BUTTON oBtnRet CAPTION STR0022 ACTION CloseDialog() SIZE 50,12 of oDlg //"Cancelar"

If nOpMsg==3
	@ 18,35 GET oCodMsg VAR cCodMsg READONLY NO UNDERLINE of oDlg
	@ 40,02 GET oMsg VAR cMsg SIZE 200,70 MULTILINE READONLY VSCROLL NO UNDERLINE of oDlg
	@ 140,01 BUTTON oBtnExc CAPTION STR0023 ACTION ExcMensagem(cCodMsg, aMsg, nTipoMsg, nOpMsg, oBrwMsg) SIZE 50,12 of oDlg //"Excluir"
Else
	@ 18,35 GET oCodMsg VAR cCodMsg READONLY NO UNDERLINE of oDlg
	@ 40,02 GET oMsg VAR cMsg MULTILINE SIZE 200,70 of oDlg

	@ 140,55 BUTTON oBtnGra CAPTION STR0024; //"Gravar"
	ACTION GrvMensagem(nOpMsg,cCodMsg,cMsg, cVend, dDataMsg, dDataVig, oBrwMsg, aMsg, nTipoMsg) SIZE 50,12 of oDlg
Endif

ACTIVATE DIALOG oDlg

Return nil
