#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1003.CH"
  
User Function LOJA1003 ; Return  // "dummy" function - Internal Use

/*
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������ͻ��
���Classe    �LJCProdutosAutorizados  �Autor  �Vendas Clientes     � Data �  04/09/07   ���
���������������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel armazenar os produtos autorizados.				        ���
���������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		        ���
���������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
*/
Class LJCProdutosAutorizados

	Data oProdutos									//Objeto do tipo LJCPRODUTOS
	
	Method ProdAutori()								//Metodo construtor
	Method ExisteProd(cCodProd)						//Metodo que ira verificar se o produto existe na pre-autorizacao
													//ou se a quantidade autorizada ja foi totalmente vendida.
	Method PodeVender(cCodProd, nQtde)				//Metodo que ira verificar se o produto pode ser vendido
	Method AtuQtComp(cCodProd, nQtde)				//Atualiza a quantidade comprada do produto
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ProdAutori�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCProdutosAutorizados.		          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ProdAutori() Class LJCProdutosAutorizados

	::oProdutos := Nil
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ExisteProd�Autor  �Vendas Clientes     � Data �  18/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em verificar se o produto exite na pre-  ���
���			 �autorizacao.											      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - cCodProd) - Codigo de barra do produto.    	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ExisteProd(cCodProd) Class LJCProdutosAutorizados

	Local lRetorno := .F.					//Variavel de retorno da funcao
	Local oProduto := Nil					//Objeto do produto autorizado
	
	//Verifica se o produto esta na pre-autorizacao 
	If ::oProdutos:Contains(cCodProd) 
        //Busca o produto
		oProduto := ::oProdutos:ElementKey(cCodProd)
		//Verifica se a quantidade autorizada e diferente da vendida, ou seja,
		//se for igual o produto tambem nao exite
		If !(oProduto:nQtdeAutor == oProduto:nQtdeComp)
			lRetorno := .T.
		Endif		
	EndIf    

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PodeVender�Autor  �Vendas Clientes     � Data �  18/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em verificar se o produto pode ser       ���
���			 �vendido.												      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - cCodProd) - Codigo de barra do produto.    	  ���
���          �ExpN2 (2 - nQtde)    - Quantidade do produto.         	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PodeVender(cCodProd, nQtde) Class LJCProdutosAutorizados

	Local lRetorno := .F.					//Variavel de retorno da funcao
	Local oProduto := Nil					//Objeto do produto autorizado
	
    //Verifica se o produto esta na pre-autorizacao 
	If ::oProdutos:Contains(cCodProd) 
		//Busca o produto
		oProduto := ::oProdutos:ElementKey(cCodProd)
		//Verifica se a quantidade comprada e menor ou igual a quantidade autorizada menos a vendida, ou seja,
		//se ja foi tudo vendido
		If nQtde <= (oProduto:nQtdeAutor - oProduto:nQtdeComp)
			lRetorno := .T.
		Else
			MsgAlert(STR0001 + ; //"Quantidade autorizada ("
			         AllTrim(Str((oProduto:nQtdeAutor - oProduto:nQtdeComp))) + ;
			         STR0002) //") para este produto"	
		EndIf		
	EndIf		
    
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AtuQtComp �Autor  �Vendas Clientes     � Data �  19/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em atualizar a quantidade comprada do    ���
���			 �produto.												      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpN1 (1 - cCodProd) - Codigo de barra do produto.    	  ���
���			 �ExpN2 (2 - nQtde)    - Quantidade do produto.         	  ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AtuQtComp(cCodProd, nQtde) Class LJCProdutosAutorizados

	Local oProduto := Nil					//Objeto do produto autorizado
	
	//Verifica se o produto esta na pre-autorizacao 
	If ::oProdutos:Contains(cCodProd) 
		//Busca o produto na pre-autorizacao
		oProduto := ::oProdutos:ElementKey(cCodProd)
		
	    If (nQtde + oProduto:nQtdeComp) <= oProduto:nQtdeAutor
			//Atualiza a quantidade comprada
			oProduto:nQtdeComp += nQtde
		Endif 
	EndIf

Return Nil