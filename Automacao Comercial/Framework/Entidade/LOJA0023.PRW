#INCLUDE "MSOBJECT.CH"

User Function LOJA0023 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCConexao		�Autor  �Vendas Clientes     � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manter tipo de conexao ativa(TOP ou CODEBASE) ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCConexao

	Data oConexao						// Objeto do tipo LJIDataBase
	
	Method New()						// Metodo construtor
	Method NewCodeBase()				// Metodo construtor para somente codebase
	Method DataBase()			    	// Metodo que ira retornar a conexao ativa
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCConexao.		                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oEntidade) - Entidade.			                  ���															  
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oEntidade) Class LJCConexao
	
	#IFDEF TOP
		//Estancia o objeto LJCTopConnect
		::oConexao := LJCTopConnect():New(oEntidade)		
	#ELSE
		//Estancia o objeto LJCCodeBase	
		::oConexao := LJCCodeBase():New(oEntidade)				
	#ENDIF
		
Return Self

Method NewCodeBase(oEntidade) Class LJCConexao
	
	//Estancia o objeto LJCCodeBase	
	::oConexao := LJCCodeBase():New(oEntidade)				
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �DataBase  �Autor  �Vendas Clientes     � Data �  25/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar a conexao ativa.				      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto    								   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DataBase() Class LJCConexao
Return ::oConexao