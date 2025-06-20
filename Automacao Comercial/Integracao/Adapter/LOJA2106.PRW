#INCLUDE "MSOBJECT.CH"

Function LOJA2106 ; Return  // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadoXML       �Autor  �Vendas Cliente      � Data �  27/03/09   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em armazenar os dados do XML gerado    		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCDadoXML
	
	Data cXML											//String do XML gerado	
	Data cTabela										//Nome da tabela que pertence a integrcao
	
    Data cVersao										// Versao do Adapter 					(LayOut)
    Data cIdentific										// Identicacao da transacao do adapter 	(LayOut)
    Data cFuncao										// Funcao da transacao do adapter      	(LayOut)

	Method New(cXML, cTabela, cVersao, cIdentific, ;
	           cFuncao)									//Metodo construtor
			
EndClass

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Metodo    �New          �Autor  �Vendas Clientes     � Data �  27/03/09   ���
����������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadoXML.      		                 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                           ���
����������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cXML) - XML Gerado.		 					  	 ���
���			 �ExpC2 (2 - cTabela) - Nome da tabela. 					  	 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto			    										 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method New(cXML, cTabela, cVersao, cIdentific, cFuncao) Class LJCDadoXML
	
	::cXML			:= cXML
	::cTabela 		:= cTabela
    ::cVersao		:= cVersao									
    ::cIdentific	:= cIdentific								
    ::cFuncao		:= cFuncao									

Return Self