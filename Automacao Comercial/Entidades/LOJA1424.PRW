#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

#DEFINE TABELA "SL1"

Function LOJA1424()
Return NIL
/* 
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Classe� LJCEntOrcamento  �Autor  �Vendas Clientes     �Data�  15/07/09   ���
���������������������������������������������������������������������������͹��
���Desc. � Classe utilizada para instanciar a tabela SL1 atraves da Classe  ���
���      � LJAEntidade.                                                     ���
���������������������������������������������������������������������������͹��
���Uso   � SIGALOJA                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Class LJCEntOrcamento From LJAEntidade
	Method New()
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    � New      �Autor  �Vendas Clientes     � Data �  15/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Construtor da classe LJCEntOrcamento 					  ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCEntOrcamento
	_Super:New(TABELA)
Return Self
