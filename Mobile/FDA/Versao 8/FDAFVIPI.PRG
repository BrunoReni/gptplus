#include "FDAXFIS.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FdaValIpi  � Autor � Henry Fila           � Data � 18.10.2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o valor do IPI                                       ���
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
Function FdaValIpi(nItem,aFdaNfCab,aFdaNfItem)   
Local cChaveB1:=RetFilial("HB1")+aFdaNfItem[nItem,IT_PRODUTO]     
Local cChaveF4:=RetFilial("HF4")+aFdaNfItem[nItem,IT_TES]

dbSelectArea("HB1")
dbSetOrder(1)
dbSeek(cChaveB1)

dbSelectArea("HF4")
dbSetOrder(1)
dbSeek(cChaveF4)

//�������������������������������������������������������������Ŀ
//� Calcula o valor do IPI                                      �
//���������������������������������������������������������������
If ( HF4->HF4_IPI <> "N" )
	//�������������������������������������������������������������Ŀ
	//� Calculo do IPI Normal                                       �
	//���������������������������������������������������������������
    
	If HB1->HB1_VLR_IPI == 0
		aFdaNfItem[nItem,IT_VALIPI] := FdaNoRound(aFdaNfItem[nItem,IT_BASEIPI]*aFdaNfItem[nItem,IT_ALIQIPI]/100,2)
	Else
		//�������������������������������������������������������������Ŀ
		//� Calculo do IPI de Pauta                                     �
		//���������������������������������������������������������������	
		aFdaNfItem[nItem,IT_VALIPI] := aFdaNfItem[nItem,IT_QTDVEN]*HB1->HB1_VLR_IPI
	EndIf
Else
	aFdaNfItem[nItem,IT_VALIPI] := 0
EndIf
//�������������������������������������������������������������Ŀ
//� Caso nao haja valor do IPI nao se deve ter base de calculo  �
//���������������������������������������������������������������
If aFdaNfItem[nItem,IT_VALIPI] == 0
	aFdaNfItem[nItem,IT_BASEIPI]:= 0
EndIf                          

Return
