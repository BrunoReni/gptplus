#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AJSXPON.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��                 
���Programa    �AjSXPON    �Autor    �Inova��o - RH       � Data �  29/06/2015 ���
������������������������������������������������������������������������������͹��
���Desc.       � Fonte respons�vels pelos ajustas na vers�o p12.               ���
���            �                                                               ���
������������������������������������������������������������������������������͹��
���Programador � DATA      � Chamado     �  MOTIVO DA ALTERACAO                ���
���            �           �             �                                     ���
���            �           �             �                                     ���
���            �           �             �                                     ���
���Oswaldo L   �27-04-17   �DRHPONTP300  �Entre os dias 24-04-17 e 26-04-17    ���
���            �           �             �baixamos os fontes do TFS das pastas ���
���            �           �             �MAIN, 12.1.14 e 12.1.16. Conforme    ���
���            �           �             �solicitado fizemos merge delas,depois���
���            �           �             �removemos alteracoes em SX           ���
���Oswaldo L   �01-08-17   �DRHPONTP-1415�Ajuste atributos campo R6_ABINTJ     ���
���Oswaldo L   �15-08-17   �DRHPONTP-1535�Ajuste novo atributos campo R6_ABINTJ���
��������������������ͱ��������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/ 

Main function PONLoad()
Local lRet   		:= .T.

lRet := fChkConv12()
If !lRet
	Return
Endif

Return (.T.)
