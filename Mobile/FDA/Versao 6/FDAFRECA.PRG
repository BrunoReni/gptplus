/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FdaFisRecal� Autor � Henry Fila           � Data � 18.10.2004 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Recalcula os impostos                                        ���
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

Function FdaFisRecal(aFdaNfCab,aFdaNfItem)
Local nX := 0 
Local nItens:=Len(aFdaNfItem)

For nX := 1 to nItens 
	FdaBsIcms(nX,aFdaNfCab,aFdaNfItem)
	FdaAlIcms(nX,aFdaNfCab,aFdaNfItem)
	FdaVlIcms(nX,aFdaNfCab,aFdaNfItem)	
	
	FdaBsIpi(nX,aFdaNfCab,aFdaNfItem)
	FdaAlIpi(nX,aFdaNfCab,aFdaNfItem)
	FdaValIpi(nX,aFdaNfCab,aFdaNfItem)	
Next	

Return