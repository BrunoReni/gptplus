#include "FDAXFIS.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FdaAliqIpi � Autor � Henry Fila           � Data � 18.10.2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a aliquota de IPI                                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function FdaAlIpi(nItem,aFdaNfCab,aFdaNfItem)   
Local nAliquota	  := 0
Local cChaveB1 := RetFilial("HB1")+aFdaNfItem[nItem,IT_PRODUTO]
Local cChaveF4 := RetFilial("HF4")+aFdaNfItem[nItem,IT_TES]

dbSelectArea("HB1")
dbSetOrder(1)
dbSeek(cChaveB1)         

dbSelectArea("HF4")
dbSetOrder(1)
dbSeek(cChaveF4)

If HF4->HF4_IPI <> "N"
	nAliquota := HB1->HB1_IPI
EndIf

aFdaNfItem[nItem,IT_ALIQIPI] := nAliquota

Return nAliquota
