#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1032 ; Return  // "dummy" function - Internal Use

/*
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
���Classe    �LJCServicoXProdutoEpharma �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�����������������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em tratar os dados retornados no servicoX produto        ���
���			 �Epharma.   	 														      ���
�����������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		          ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
*/
Class LJCServicoXProdutoEpharma From LJAAbstrataServico

	Data oProdutos       					//Objeto que ira armazenar os dados dos produtos
	
	Method XProdEphar(cTipo)				//Metodo construtor
	Method TratarServ(cDados)				//Metodo que ira tratar os dados do servico    
	Method BuscaProd()						//Metodo que ira retornar os dados dos produtos

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �XProdEphar�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCServicoXProdutoEpharma.             ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipo) - Tipo do servico.		   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method XProdEphar(cTipo) Class LJCServicoXProdutoEpharma

	::cTpServ 		:= cTipo
	::oProdutos 	:= Nil

Return Self 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratarServ�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira tratar os dados retornados no servico.       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDados)   - String com os dados do servico.	  ���
���			 �ExpN1 (2 - nPosicao) - Posicao da string dos dados.		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratarServ(cDados, nPosicao) Class LJCServicoXProdutoEpharma

	Local oProdEphar		:= Nil 					//Objeto que ira armazenar cada produto
	Local nPos 				:= 1					//Posicao inicial da string cDados
	Local nQtdeProd 		:= 0					//Quantidade de produtos retornados
	Local nCount 			:= 0					//Variavel de controle contador		
	
	::oProdutos := LJCProdutos():Produtos()
		
	::cTpDados := Val(SubStr(cDados, nPos, 1))
	nPos ++

	nQtdeProd := Val(SubStr(cDados, nPos, 2))
	nPos += 2
	
	For nCount := 1 To nQtdeProd
	
		oProdEphar := LJCProdutoEpharma():ProdEpharm()
		
		oProdEphar:cCodProdut := SubStr(cDados, nPos, 13)
		nPos += 13		
		
		If ::oProdutos:Contains(oProdEphar:cCodProdut)
			oProdEphar:nQtdeAutor := ::oProdutos:ElementKey(oProdEphar:cCodProdut):nQtdeAutor + Val(SubStr(cDados, nPos, 2))		
		Else
			oProdEphar:nQtdeAutor := Val(SubStr(cDados, nPos, 2))
		Endif
		nPos += 2
					
		oProdEphar:nPrcMaximo := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 7
		
		oProdEphar:nVlUnVenda := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 7
		
		oProdEphar:nPrcUnFabr := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 7
		
		oProdEphar:nPrcUnAqui := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 7

		oProdEphar:nVlRepasse := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 8
		
		oProdEphar:cMtvRejeic := SubStr(cDados, nPos, 2)
		nPos += 2		
		
		::oProdutos:Add(oProdEphar:cCodProdut, oProdEphar)
						
	Next
				
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuscaProd �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira retornar os produtos.          	          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ��� 
�������������������������������������������������������������������������͹��
���Retorno   �Objeto												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaProd() Class LJCServicoXProdutoEpharma
Return ::oProdutos