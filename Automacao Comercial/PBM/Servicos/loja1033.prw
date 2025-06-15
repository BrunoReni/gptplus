#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1033 ; Return  // "dummy" function - Internal Use

/*
����������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������ͻ��
���Classe    �LJCServicoXProdutoTrnCentre�Autor  �Vendas Clientes     � Data �  04/09/07   ���
������������������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em tratar os dados retornados no servicoX produto         ���
���			 �TrnCentre.   	 														       ���
������������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		           ���
������������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������
*/
Class LJCServicoXProdutoTrnCentre From LJAAbstrataServico

	Data oProdutos                          	//Objeto que ira armazenar os dados dos produtos
	Data nIndContin								//Indicar de continuacao do produto
	
	Method XProdTrnCe(cTipo)					//Metodo construtor
	Method TratarServ(cDados)					//Metodo que ira tratar os dados do servico    
	Method BuscaProd()							//Metodo que ira retornar os dados dos produtos
    	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �XProdTrnCe�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCServicoXProdutoTrnCentre.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipo) - Tipo do servico.		   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method XProdTrnCe(cTipo) Class LJCServicoXProdutoTrnCentre

	::cTpServ 		:= cTipo
	::oProdutos 	:= Nil
	::nIndContin	:= 0

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
Method TratarServ(cDados, nPosicao) Class LJCServicoXProdutoTrnCentre

	Local oProdTrnCe			:= Nil				//Objeto que ira armazenar cada produto
	Local nPos 					:= 1 				//Posicao inicial da string cDados
	Local nQtdeProd 			:= 0				//Quantidade de produtos retornados
	Local nCount 				:= 0				//Variavel de controle contador
	
	If ::oProdutos == Nil
		::oProdutos := LJCProdutos():Produtos()
	EndIf
		
	::cTpDados := SubStr(cDados, nPos, 1)
	nPos ++
    
	::nIndContin := Val(SubStr(cDados, nPos, 1))
	nPos ++
	
	nQtdeProd := Val(SubStr(cDados, nPos, 2))
	nPos += 2
	
	For nCount := 1 To nQtdeProd
	
		oProdTrnCe := LJCProdutoTrnCentre():ProTrnCent()
		
		oProdTrnCe:cCodProdut := SubStr(cDados, nPos, 13)
		nPos += 13
	
		oProdTrnCe:cTpEmbalag := SubStr(cDados, nPos, 1)
		nPos ++		
		
		If ::oProdutos:Contains(oProdTrnCe:cCodProdut)
			oProdTrnCe:nQtdeAutor := ::oProdutos:ElementKey(oProdTrnCe:cCodProdut):nQtdeAutor + Val(SubStr(cDados, nPos, 3))		
		Else
			oProdTrnCe:nQtdeAutor := Val(SubStr(cDados, nPos, 3))
		Endif
		nPos += 3
		
		oProdTrnCe:nPrcBruto := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 7

		oProdTrnCe:nPrcLiqui := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 7

		oProdTrnCe:nVlRecLoja := Val(SubStr(cDados, nPos, 7)) / 100
		nPos += 7

		oProdTrnCe:nDescConce := Val(SubStr(cDados, nPos, 5)) / 100
		nPos += 5

		oProdTrnCe:nStProduto := Val(SubStr(cDados, nPos, 2))
		nPos += 2
		
		oProdTrnCe:nSubsidio := (oProdTrnCe:nPrcLiqui - oProdTrnCe:nVlRecLoja)
				
		::oProdutos:Add(oProdTrnCe:cCodProdut, oProdTrnCe)
							
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
Method BuscaProd() Class LJCServicoXProdutoTrnCentre
Return ::oProdutos