#INCLUDE "MSOBJECT.CH"

Function LOJA1101 ; Return  // "dummy" function - Internal Use 

/* 
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadoProcesso  �Autor  �Vendas Cliente      � Data �  22/02/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em armazenar dado do processo que sera integrado���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCDadoProcesso
	
	Data cTabela									//Nome da tabela que pertence ao processo
	Data cChave										//Valor da chave do registro da tabela
	Data nIndice								    //Indice da chave
	Data cTipo										//Determina como o dado do processo sera integrado
													//(INSERT, UPDATE OU DELETE)
	Data lIntegra									//Deternima se a tabela do processo sera integrada
	
	Method New(cTabela, cChave, nIndice, cTipo, ;
			   lIntegra)							//Metodo construtor
		
EndClass

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  �Vendas Clientes     � Data �  22/02/08   ���
����������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadoProcesso.    		                 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  	 ���
���			 �ExpC2 (2 - cChave)  - Dados da chave.						     ���
���			 �ExpN1 (3 - nIndice) - Codigo do indice.			             ���
���			 �ExpC3 (4 - CTipo)   - Tipo de integracao do dado.	             ���
���			 �ExpL1 (5 - lIntegra)- Se a tabela sera integrada.	             ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto			    										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method New(cTabela, cChave, nIndice, cTipo, ;
		   lIntegra) Class LJCDadoProcesso
    
	Default lIntegra := .F.
	
	::cTabela 	:= cTabela
	::cChave	:= cChave
	::nIndice	:= nIndice
	::cTipo		:= AllTrim(Upper(cTipo))
	::lIntegra  := lIntegra
	
Return Self