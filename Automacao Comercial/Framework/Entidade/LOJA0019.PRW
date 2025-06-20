#INCLUDE "MSOBJECT.CH"

User Function LOJA0019 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosCampo     �Autor  �Vendas Clientes     � Data �  25/02/08   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar as caracteristicas dos campos    	  ���
���		     �da tabela. 	  													  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCDadosCampo

	Data cNome					//Nome do tipo
	Data cTipo					//Tipo de dados do campo
	Data nTamanho				//Tamanho do campo
	Data nCasasDec				//Numero de casas decimais
	Data cFormato				//Formato do campo (Picture)
	Data oValor					//Valor do campo
	Data cContexto				//Contexto do campo
	Data cTitulo				//Tirulo do campo
	Data cDescricao				//Descricao do campo
	Data cOrdem					//Ordem do campo
	
	Method New()				//Metodo construtor
    Method Clonar()				//Metodo que ira clonar o objeto LJCDadosCampo por recursividade
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadosCampo.	                      ���
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
Method New() Class LJCDadosCampo
	
	::cNome 		:= ""
	::cTipo 		:= ""
	::nTamanho 		:= 0
	::nCasasDec 	:= 0
	::cFormato		:= ""
	::oValor		:= Nil
	::cContexto		:= ""
	::cTitulo		:= ""
	::cDescricao	:= ""
	::cOrdem		:= ""
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Clonar    �Autor  �Vendas Clientes     � Data �  28/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em clonar o objeto LJCDadosCampo.		          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�														      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Clonar() Class LJCDadosCampo

	Local oRetorno := Nil				//Retorno do metodo
	
	//Estancia o objeto LJCDadosCampo (recursividade)
	oRetorno := LJCDadosCampo():New()
	
	oRetorno:cNome 		:= ::cNome
	oRetorno:cTipo 		:= ::cTipo
	oRetorno:nTamanho 	:= ::nTamanho 	
	oRetorno:nCasasDec 	:= ::nCasasDec
	oRetorno:cFormato	:= ::cFormato
	oRetorno:oValor		:= ::oValor
	oRetorno:cContexto	:= ::cContexto
	oRetorno:cTitulo	:= ::cTitulo
	oRetorno:cDescricao	:= ::cDescricao
	oRetorno:cOrdem		:= ::cOrdem
	
Return oRetorno