#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"        

Function LOJA1920 ; Return     

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �LJIRecargaCelular�Autor  �VENDAS CRM       � Data �  16/03/10   ���
�����������������������������������������������������������������������������͹��
���Desc.     �Interface para transacao com recarga de celular			      ��� 
�����������������������������������������������������������������������������͹��
���Uso       � MP10                                                           ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������     
*/
Class LJIRecargaCelular

	Method RecNFis(oDadosTran)
	Method RecFis(oDadosTran)
	Method Confirmar()
	Method Desfazer()
	Method GetTrans()

EndClass