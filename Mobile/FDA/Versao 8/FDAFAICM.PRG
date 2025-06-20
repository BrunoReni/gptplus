#include "FDAXFIS.CH"
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FdaAlIcms  � Autor � Henry Fila           � Data � 18.10.2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a aliquota de ICMS                                   ���
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
Function FdaAlIcms(nItem,aFdaNfCab,aFdaNfItem)
Local cTipoNF   := aFdaNfCab[NF_TIPONF]
Local nAliquota := 0
Local cNF_UForigem
Local cNF_UFdest 
Local cChave := RetFilial("HB1")+aFdaNfItem[nItem, IT_PRODUTO ]

dbSelectArea("HB1")
dbSetOrder(1)
dbSeek(cChave)

nAliquota := If ( HB1->HB1_PICM == 0 , MV_ICMPAD ,  HB1->HB1_PICM )

dbSelectArea("HF4")
dbSetOrder(1)
dbSeek(RetFilial("HF4")+aFdaNfItem[nItem, IT_TES ] ) 

If HF4->HF4_ICM <> "N"
		//�������������������������������������������������������������Ŀ
		//� Tratamento para Operacaoes InterEstaduais com ICMS          �
		//���������������������������������������������������������������
	cNF_UForigem    := aFdaNfCab[ NF_UFORIGEM ]
    cNF_UFdest      := aFdaNfCab[ NF_UFDEST ]

    If !aFdaNfCab[ NF_INSCR ] 
	    If (  cNF_UForigem  <>  cNF_UFdest  )  	
			//�������������������������������������������������������������Ŀ
			//� Calculo da Aliquota de ICMS                                 �
			//���������������������������������������������������������������
			If ( aFdaNfCab[ NF_UFORIGEM ] $ MV_NORTE )  
				nAliquota := 12 
			Else
				nAliquota := IIf( aFdaNfCab[NF_UFDEST] $ MV_NORTE , 7 , 12 )
			EndIf
		Endif
	Endif	
Else              
	nAliquota := 0
EndIf                                         
 
If HF4->HF4_ICM <> "N"
   aFdaNfItem[nItem][IT_ALIQICM] := nAliquota
Else
   aFdaNfItem[nItem][IT_ALIQICM] := 0       
EndIf

Return nAliquota 
