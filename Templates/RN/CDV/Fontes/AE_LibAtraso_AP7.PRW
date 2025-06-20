#INCLUDE "AE_LibAtraso_AP7.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_LibAtraso_Ap7 �Autor  � Willy       � Data �  17/03/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Libera Atraso na Prestacao de Contas.                     ���
���          �  Bloqueio por Atraso na Prestacao de Contas.               ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function LibAtraso()

Local _cPerg1 		:= STR0001 //"Deseja Liberar Atraso da Presta��o de Contas desse Colaborador?"
Local _cPerg2 		:= STR0002 //"Deseja Bloquear por Atraso a Presta��o de Contas desse Colaborador?"
Local _aAreaLHQ2	:= GetArea()

ChkTemplate("CDV")

If LHQ->LHQ_FLAG == "K"
	MsgInfo(STR0003) //"Esta solicita��o est� cancelada e n�o pode ser alterada."
	Return
EndIf                  
If LHQ->LHQ_FLAG == "Z"
	MsgInfo(STR0004) //"Esta solicita��o est� fechada e n�o pode ser alterada."
	Return
EndIf
If LHQ->LHQ_FLAG == "C"
	MsgInfo(STR0005) //"Esta solicita��o est� autorizada e liberada e n�o pode ser alterada."
	Return
EndIf
If LHQ->LHQ_FLAG == "B"
	MsgInfo(STR0006) //"Presta��o de contas sem solicita��o n�o podem ser bloqueadas."
	Return
EndIf
	
If !LHQ->LHQ_FLAG == "P"
	If MsgYESNO(_cPerg2, STR0007) //"Aten��o"
		dbSelectArea("LHQ")
		RecLock("LHQ",.F.)
		LHQ->LHQ_FLAG := "P"
		MsUnLock("LHQ")
		MsgInfo(STR0008) //"Bloqueio por Atraso, concluido com Sucesso!"
	Endif
Else
	If MsgYESNO(_cPerg1, "Aten��o")
		dbSelectArea("LHQ")
		RecLock("LHQ",.F.)
		If Empty(LHQ->LHQ_SAIDA)
			LHQ->LHQ_FLAG := "M"
		Else
			If Empty(LHQ->LHQ_EMISS)
				LHQ->LHQ_FLAG := "V"
			Else
				If Empty(LHQ->LHQ_IMPRESS)
					LHQ->LHQ_FLAG := "D"
				Else
					LHQ->LHQ_FLAG := "L"
				Endif
			Endif
		EndIf
		MsUnLock("LHQ")
		MsgInfo(STR0009) //"Libera��o de Atraso, concluida com Sucesso!"
	Endif
EndIf
RestArea(_aAreaLHQ2)

Return(Nil)
