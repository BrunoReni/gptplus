#INCLUDE "MSOBJECT.CH"

Function LOJA2155 ; Return  // "dummy" function - Internal Use 
           
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCGeraXMLDA1     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em gerar o XML DA1							      ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCGeraXMLDA1 From LJAGeraXML
		
	Method New()					                   	//Metodo construtor
	Method Gerar(oDadoInt, oCampos)						//Gera Xml

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCGeraXMLDA1.		                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCGeraXMLDA1

	//Executa o metodo construtor da classe pai
	_Super:New()
		
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gerar     �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gerar o XML. Metodo abstrato, tem que ser    ���
���			 �subscrito pelas classes filhos.	          	  			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oDadoInt) - Dado da integracao.				  ���											                
���			 �ExpO2 (2 - oCampos) - Campos do XML.				  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Gerar(oDadoInt, oCampos) Class LJCGeraXMLDA1

	Local lRetorno 		:= .T.					//Retorno do metodo

	lRetorno := ::Gerar1Ent(oDadoInt, "ITENS_DA_TABELA_DE_PRECO", Nil, oCampos)    
    
Return lRetorno