#INCLUDE "FILEIO.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"

Function LOJA1200 ; Return  // "dummy" function - Internal Use 
 
/* 
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosExportacao�Autor  �Vendas Clientes     � Data �  23/04/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar os dados que serao exportados.  	  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCDadosExportacao

	Data aDados										//Array com os dados que serao exportados, dados do tipo LJCDadoExportacao

	Method New()                                   	//Metodo construtor
	Method Incluir(cTabela, cChave, nIndice) 		//Incluir um dado do tipo LJCDadoExportacao no array aDados
	Method GetExportacao()                         	//Retorna o array aDados

EndClass       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadosExportacao.                    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCDadosExportacao
      
	::aDados := {}

Return Self           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    |Incluir   �Autor  �Vendas Clientes     � Data �  23/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em Incluir um dado do tipo LJCDadoExportacao no ���
���			 �array aDados												  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
���			 �ExpC2 (2 - cChave)  - Dados da chave.						  ���
���			 �ExpN1 (3 - nIndice) - Codigo do indice.			          ���
���			 �ExpC3 (4 - cTipo)   - Tipo de integracao do dado.	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Incluir(cTabela, cChave, nIndice, cTipo) Class LJCDadosExportacao
    
	Local oDadoExportacao := LJCDadoExportacao():new(cTabela, cChave, nIndice, cTipo)

	Default cTipo := "INSERT"
	
	AADD(::aDados, oDadoExportacao)

Return Nil 

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Metodo    �GetExportacao �Autor  �Vendas Clientes     � Data �  23/04/08    ���
������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar o array aDados com os dados da exportacao���
������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                             ���
������������������������������������������������������������������������������͹��
���Parametros�											                       ���															  
������������������������������������������������������������������������������͹��
���Retorno   �Array 									   				       ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method GetExportacao() Class LJCDadosExportacao
Return ::aDados