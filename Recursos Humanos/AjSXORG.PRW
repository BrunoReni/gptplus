#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��                 
���Programa    �AjSXORG    �Autor    �Inova��o - RH       � Data �  29/06/2015 ���
������������������������������������������������������������������������������͹��
���Desc.       � Fonte respons�vels pelos ajustas na vers�o p12.               ���
���            �                                                               ���
������������������������������������������������������������������������������͹��
���Programador � DATA      � Chamado     �  MOTIVO DA ALTERACAO                ���
���            �           �             �                                     ���
���            �           �             �                                     ���
���            �           �             �                                     ���
���Matheus M.  � 02/02/2016� TUHNWS      � Ajuste para colocar os campos  -    ���
���            �           �             � RCL_DFUNC e RCL_FUNCAO no browse    ���
���            �           �             � e para que a descri��o da fun��o    ���
���            �           �             � seja exibida.				       ���
���Renan Borges� 07/11/2016� TVTWG9      � Realizado a implementa��o da op��o  ���
���            �           �             � 4 da solicita��o na rotina de Movi  ���
���            �           �             � menta��o de Postos, destinada a re  ���
���            �           �             � du��o da quantidade de postos.      ���
���Oswaldo L   �27-04-17   �DRHPONTP300  � Entre os dias 24-04-17 e 26-04-17   ���
���            �           �             �baixamos os fontes do TFS das pastas ���
���            �           �             �MAIN, 12.1.14 e 12.1.16. Conforme    ���
���            �           �             �solicitado fizemos merge delas,depois���
���            �           �             �removemos alteracoes em SX           ���
���Isabel N.   � 25/07/2017�DRHPONTP-360 �Ajuste/Limpeza do fonte para 12.1.17.���
��������������������ͱ��������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/ 

Main function ORGLoad()
Local lRet := .T.

lRet := fChkConv12()
If !lRet
	Return
Endif

Return (.T.)
