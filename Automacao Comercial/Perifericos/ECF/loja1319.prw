#INCLUDE "MSOBJECT.CH"

Function LOJA1319 ; Return 	 // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������ͻ��
���Classe    �LJCMensagensPromocionais�Autor  �Vendas Clientes     � Data �  05/05/08   ���
���������������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em armazenar as linhas que serao impressas no rodape do cupom ���
���������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		        ���
���������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
*/
Class LJCMensagensPromocionais From LJCColecao
   			
	Method New()											//Metodo construtor
	
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCMensagensPromocionais.	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New() Class LJCMensagensPromocionais

	//Executa o metodo construtor da classe pai
	::Colecao()
	
Return Self