#INCLUDE "MSOBJECT.CH"

Function LOJA1131 ; Return  // "dummy" function - Internal Use 

/* 
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCEmailIntegracao �Autor  �Vendas Cliente      � Data �  24/03/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe em enviar email do processo offline						   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJCEmailIntegracao From LJAEmail

	Method New()										//Metodo construtor
	Method Enviar(cDe, cAssunto, cMsg)   				//Metodo responsavel em enviar email	
    	
EndClass

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  �Vendas Clientes     � Data �  24/03/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAEmail         		                 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�																 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto			    										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method New() Class LJCEmailIntegracao

	//Executa o metodo construtor da classe pai
	_Super:New()
    
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Enviar    �Autor  �Vendas Clientes     � Data �  24/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em enviar email								  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDe)  	 - Nome do remetente.					  ���
���			 �ExpC4 (4 - cAssunto)  - Assunto.		    				  ���
���			 �ExpC6 (6 - cMsg)  - Mensagem do email.					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico			    									  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Enviar(cDe, cAssunto, cMsg) Class LJCEmailIntegracao
	
	Local lRetorno	:= .T.											//Retorno do metodo
	Local cDestino	:= Trim(SuperGetMV("MV_LJCTINT",, ""))			//Conta de e-mail do destinatario 
		
	If  !Empty(cDestino)
		lRetorno := _Super:Enviar(cDe, cDestino, "", cAssunto, "", cMsg)
	EndIf
		
Return Nil