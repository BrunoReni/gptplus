#INCLUDE "MSOBJECT.CH"

User Function LOJA0024 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJIDataBase		�Autor  �Vendas Clientes     � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Interface da classe LJCTopConnect e LJCCodeBase, os metodos precisam���
���			 �ser implementados nas classes filhos.								  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJIDataBase
	
	Method New()				//Metodo construtor
	Method Consultar()			//Metodo que ira consultar os dados da tabela atraves da chave (indice 1)
	Method Alterar()			//Metodo que ira alterar os dados da tabela atraves da chave (indice 1)
	Method Incluir()			//Metodo que ira incluir um registro na tabela
	Method Excluir()			//Metodo que ira excluir os dados da tabela atraves da chave (indice 1)			

EndClass