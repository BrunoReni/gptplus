#INCLUDE "MSOBJECT.CH"

Function LOJA1112 ; Return  // "dummy" function - Internal Use 

/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJIIntegracao  	�Autor  �Vendas Clientes     � Data �  04/03/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Interface das classes de replicacao, os metodos tem que ser		  ���
���			 �implementados nas classes filhos.							          ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJIIntegracao
	
	Method New()					//Metodo construtor
	Method Integrar(oDadosProc)		//Metodo que ira integrar os dados via integracao ou conecao especifica

EndClass