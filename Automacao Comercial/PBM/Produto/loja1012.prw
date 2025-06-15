#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1012 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCProdutoEpharma�Autor  �Vendas Clientes     � Data �  05/09/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe que possui as caracteristicas do ProdutoEpharma.            ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCProdutoEpharma From LJAAbstrataProduto
	
	Data nPrcMaximo							//Preco maximo
	Data nVlUnVenda							//Valor unitario de venda
	Data nPrcUnFabr							//Preco unitario de fabrica
	Data nPrcUnAqui                         //Preco unitario aquisicao
	Data nVlRepasse							//Valor de repasse
	Data cMtvRejeic							//Motivo rejeicao
	
	Method ProdEpharm()						//Metodo construtor

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ProdEpharm�Autor  �Vendas Clientes     � Data �  05/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCProdutoEpharma.                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ProdEpharm() Class LJCProdutoEpharma
	
	::AbstraProd()
     
	::nPrcMaximo := 0
	::nVlUnVenda := 0
	::nPrcUnFabr := 0
	::nPrcUnAqui := 0
	::nVlRepasse := 0
	::cMtvRejeic := ""

Return Self