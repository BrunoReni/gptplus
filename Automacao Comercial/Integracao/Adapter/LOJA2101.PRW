#INCLUDE "MSOBJECT.CH"

Function LOJA2101 ; Return  // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadoIntegracao�Autor  �Vendas Cliente      � Data �  27/03/09   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em armazenar dado da integracao				 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCDadoIntegracao
	
	Data cTabela									//Nome da tabela que pertence a integrcao
	Data cChave										//Valor da chave do registro da tabela
	Data cIndice								    //Indice da chave
	Data cTipo										//Determina como o dado do processo sera integrado
													//(3 - INCLUSAO, 4 - ALTERACAO OU 5 - EXCLUSAO)
	Data lXml										//Indica se o XML ja foi gerado													
	
	Method New(cTabela, cChave, cIndice, cTipo)		//Metodo construtor
			
EndClass

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  �Vendas Clientes     � Data �  27/03/09   ���
����������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadoIntegracao.  		                 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  	 ���
���			 �ExpC2 (2 - cChave)  - Dados da chave.						     ���
���			 �ExpN1 (3 - cIndice) - Codigo do indice.			             ���
���			 �ExpC3 (4 - cTipo)   - Tipo de integracao do dado.	             ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto			    										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method New(cTabela, cChave, cIndice, cTipo) Class LJCDadoIntegracao
	
	::cTabela 	:= cTabela
	::cChave	:= cChave
	::cIndice	:= cIndice
	::cTipo		:= AllTrim(Upper(cTipo))
	::lXml		:= .F.
	
Return Self