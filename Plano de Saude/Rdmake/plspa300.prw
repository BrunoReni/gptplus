
#Include "PROTHEUS.CH"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PLSPA300  �Autor  �Thiago Machado Correa � Data �  06/10/04   ���
���������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada PTU - A300									���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       � AP6 - Pls                                                    ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

User Function PLSPA300()

Local lRet   := .F.
Local nIdade := 0

If BA1->BA1_CODINT == "0227"
	If cTipPla == "0079"
		nIdade := Calc_idade(dDatFin, BA1->BA1_DATNAS)
		If nIdade >= 66
			lRet := .T.		       
		EndIf
	Endif
Endif


Return lRet
