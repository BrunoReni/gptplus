#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��                 
���Programa    �AjSXTCF    �Autor    �Inova��o - RH       � Data �  29/06/2015 ���
������������������������������������������������������������������������������͹��
���Desc.       � Fonte respons�vels pelos ajustas na vers�o p12.               ���
���            �                                                               ���
������������������������������������������������������������������������������͹��
���Programador � DATA      � Chamado     �  MOTIVO DA ALTERACAO                ���
���Matheus M.  �01/07/2016 � TVHRQX      �  Ajuste no valid do campo AI8_VISAPV���
���            �           �             �                                     ���
���            �           �             �                                     ���
���Oswaldo L   �27-04-17   �DRHPONTP300  � Entre os dias 24-04-17 e 26-04-17   ���
���            �           �             � baixamos os fontes do TFS das pastas ���
���            �           �             � MAIN, 12.1.14 e 12.1.16. Conforme    ���
���            �           �             � solicitado fizemos merge delas,depois���
���            �           �             � removemos alteracoes em SX           ���
��������������������ͱ��������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/ 

Main function TCFLoad()
Local lRet        := .T.

If FindFunction('fChkConv12')
   lRet := fChkConv12()
EndIf   

If !lRet
	Return
Endif

Return (.T.)
