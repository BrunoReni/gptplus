#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1013 ; Return  // "dummy" function - Internal Use

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Classe    �LJCProdutoTrnCentre �Autor  �Vendas Clientes     � Data �  05/09/07   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Classe que possui as caracteristicas do ProdutoTrnCentre.             ���
�����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                                  ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Class LJCProdutoTrnCentre From LJAAbstrataProduto

	Data cTpEmbalag							//Tipo de embalagem
	Data nPrcBruto							//Preco bruto
	Data nPrcLiqui							//Preco liquido
	Data nVlRecLoja							//Valor a receber da loja
	Data nDescConce							//Desconto concedido
	Data nStProduto							//Status produto
	Data nSubsidio							//Valor do subsidio
	
	Method ProTrnCent()						//Metodo construtor

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ProTrnCent�Autor  �Vendas Clientes     � Data �  05/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCProdutoTrnCentre.                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ProTrnCent() Class LJCProdutoTrnCentre
	
	::AbstraProd()
	
	::cTpEmbalag := ""
	::nPrcBruto := 0
	::nPrcLiqui := 0
	::nVlRecLoja := 0
	::nDescConce := 0
	::nStProduto := 0
	::nSubsidio := 0

Return Self