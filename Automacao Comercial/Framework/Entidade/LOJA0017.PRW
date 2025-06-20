#INCLUDE "MSOBJECT.CH"

User Function LOJA0017 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJIEntidade		�Autor  �Vendas Clientes     � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Interface da classe LJAEntidade, os metodos precisam ser implementa-���
���			 �dos na classe LJAEntidade.										  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJIEntidade
	
	Method New()						//Metodo construtor
	Method DadosSet(cCampo, oValor)    	//Metodo que ira atribuir um valor a um campo da tabela
	Method DadosGet(cCampo)				//Metodo que ira pegar um valor de um campo da tabela
	Method Consultar(nIndice)			//Metodo que ira consultar os dados da tabela atraves de um dos indices
	Method Alterar(nIndice)				//Metodo que ira alterar os dados da tabela atraves de um dos indices
	Method Incluir()					//Metodo que ira incluir um registro na tabela
	Method Excluir(nIndice)				//Metodo que ira excluir os dados da tabela atraves de um dos indices
	Method Clonar()						//Metodo que ira clonar o objeto
	Method Limpar()						//Metodo que ira limpar todos os valores dos campos da entidade
	
EndClass