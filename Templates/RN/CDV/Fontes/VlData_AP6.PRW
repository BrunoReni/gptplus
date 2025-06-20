#INCLUDE "VlData_AP6.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VLDATA_AP6�Autor  �Willy               � Data �  07/01/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a sequencia das datas                             ���
�������������������������������������������������������������������������͹��
���Uso       � CDV - Controle de Despesas de Viagens 					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function VlData()
Local _lVlData := .T.
Local _nI                               

ChkTemplate("CDV")

If Len(aCols) > 1
	For _nI = 1 to n-1
		If !aCols[_nI][_nUsado+1]
			If M->LHR_Data < aCols[_nI][_nPosDat]
				_lVlData := .F.
				MsgInfo(STR0001, STR0002) //'Data fora da Sequencia, Coloque seus Recibos em Ordem de Data.'###'Aten��o'
				Exit
			EndIf
		EndIf
	Next
	
	For _nI = n+1 to Len(aCols)
		If !aCols[_nI][_nUsado+1]
			If M->LHR_Data > aCols[_nI][_nPosDat]
				_lVlData := .F.
				MsgInfo(STR0001, STR0002) //'Data fora da Sequencia, Coloque seus Recibos em Ordem de Data.'###'Aten��o'
				Exit
			EndIf
		EndIf
	Next
EndIf

If _lVlData
	If 	AllTrim(aCols[n][_nPosCod]) != "" .And. ; //Despesa nao preenchida
		aCols[n][_nPosQtd] != 0 .And. ;
		aCols[n][_nPosVrt] > 0

		T_ValidLim(M->LHR_Data, aCols[n][_nPosCod], aCols[n][_nPosQtd], aCols[n][_nPosVrt])
	EndIf
EndIf

Return(_lVlData)