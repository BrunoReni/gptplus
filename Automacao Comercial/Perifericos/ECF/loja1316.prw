#INCLUDE "MSOBJECT.CH"

Function LOJA1316 ; Return 	 // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCTotalizadorEcf�Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em armazenar os dados do totalizador nao fiscal do ecf ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCTotalizadorEcf
   	
   	Data cIndice											//Indice utilizado pelo ecf
   	Data cTotaliz											//Descricao do totalizador
   	Data cTipo												//Tipo (E- entrada de valor / S - saida de valor)
   	Data cLegenda											//Descricao da legenda
   			
	Method New(cIndice, cTotaliz, cTipo, cLegenda)			//Metodo construtor
	
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCTotalizadorEcf. 		    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice utilizado pelo ecf.	   				 ���
���			 �EXPC2 (2 - cTotaliz) - Descricao do totalizador.					 ���
���			 �EXPC3 (3 - cTipo) - Tipo (E- entrada de valor / S - saida de valor)���
���			 �EXPC4 (4 - cLegenda) - Legenda que o totalizador pertence          ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New(cIndice, cTotaliz, cTipo, cLegenda) Class LJCTotalizadorEcf

	::cIndice 	:= cIndice
   	::cTotaliz	:= cTotaliz
   	::cTipo		:= cTipo
	::cLegenda	:= cLegenda
	
Return Self