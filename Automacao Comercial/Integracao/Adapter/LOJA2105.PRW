#INCLUDE "MSOBJECT.CH"

Function LOJA2105 ; Return  // "dummy" function - Internal Use 

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosXML        �Autor  �Vendas Clientes     � Data �  27/03/09   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em armazenar uma colecao de LJCDadoXML.           ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                          	   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJCDadosXML From LJCList

	Method New()						//Metodo construtor
		
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadosXML.   	    	              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCDadosXML
	
	//Executa o metodo construtor da classe pai
	_Super:New()
	
Return Self