#INCLUDE "FDMG101.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � MsgRefresh()        �Autor: Fabio Garbin  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao que atualiza tela e array das mensagens 			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nTipoMsg - Tipo da Mensagem (1-Enviado, 2-Recebida)		  ���
��� 		 � aMsg - Array que cont�m as mensagens 					  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Function MsgRefresh(nTipoMsg, oBrwMsg, aMsg, oBtnAlt)

If nTipoMsg = 1
	HideControl(oBtnAlt)
Else
	ShowControl(oBtnAlt)
EndIf
aSize(aMsg, 0)
dbSelectArea("HMV")
dbSetOrder(1)
dbGoTop()
While !Eof()
	If HMV->HMV_ORI = Str(nTipoMsg,1,0)
		aAdd(aMsg, {HMV->HMV_COD, HMV->HMV_MSG, HMV->HMV_STATUS})
	EndIf
	dbSkip()
End
SetArray(oBrwMsg, aMsg)
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CrgProxMsg()        �Autor: Fabio Garbin  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega o codigo da proxima mensagem incluida			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nTipoMsg - Tipo da Mensagem (1-Enviado, 2-Recebida)		  ���
��� 		 � aMsg - Array que cont�m as mensagens 					  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GrvMensagem()       �Autor: Fabio Garbin  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava dados do CLiente 									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpMsg - Operacao (1 - Inclusao, 2 Alteracao)			  ���
���			 � cCodMsg - Codigo da Mensagem, cMsg - Mensagem      		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
	dbSeek(RetFilial("HMV")+cCodMsg)
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VrfMensagem()       �Autor: Fabio Garbin  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida dados da Mensagem 								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodMsg - Codigo da Mensagem, cMsg - Mensagem      		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ExcMensagem()       �Autor: Fabio Garbin  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Exclui uma Mensagem 								          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodMsg - Codigo da Mensagem, cMsg - Mensagem      		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ExcMensagem(cCodMsg, aMsg, nTipoMsg, nOpMsg, oBrwMsg)
Local cResp	:= "", nPos := 0
cResp:= if(MsgYesOrNo(STR0005,STR0006),"Sim","N�o") //"Voc� deseja Excluir a Mensagem Selecionada?"###"Cancelar"
If cResp="Sim"
	dbSelectArea("HMV")
	dbSetOrder(1)
	dbSeek(RetFilial("HMV")+cCodMsg)
	If HMV->(Found()) 
		dbDelete()
		dbSkip()
		Alert(STR0007) //"Mensagem Exclu�da com Sucesso!"
	Endif
	nPos := GridRow(oBrwMsg)
	aDel(aMsg, nPos)
	aSize(aMsg, Len(aMsg)-1)
	CloseDialog()	
Endif

Return Nil