#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1039 ; Return  // "dummy" function - Internal Use

/*
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������ͻ��
���Classe    �LJCServicoXTelaProduto  �Autor  �Vendas Clientes     � Data �  09/10/07   ���
���������������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em tratar os dados retornados no servicoX tela         ���
���			 �complementar de produtos. 												���
���������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		        ���
���������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
*/
Class LJCServicoXTelaProduto From LJAAbstrataServico

	Data oTelasComp									//Objeto que ira armazenar os dados das telas complementares dos produtos
	
	Method XTelaProd(cTipo)                   		//Metodo construtor
	Method TratarServ(cDados)                     	//Metodo que ira tratar os dados do servico
	Method BusTelProd()                          	//Metodo que ira retornar os dados das telas complementares dos produtos

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �XTelaProd �Autor  �Vendas Clientes     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCServicoXTelaProduto.                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipo) - Tipo do servico.		   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method XTelaProd(cTipo) Class LJCServicoXTelaProduto

	::cTpServ 		:= cTipo
	::oTelasComp 	:= Nil    

Return Self 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratarServ�Autor  �Vendas Clientes     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira tratar os dados retornados no servico.       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDados)   - String com os dados do servico.	  ���
���          �ExpN1 (2 - nPosicao) - Posicao da string dos dados.		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratarServ(cDados, nPosicao) Class LJCServicoXTelaProduto

	Local oTelaCompl		:= Nil					//Objeto que ira armazenar cada tela complementar
	Local nPos	 			:= 1					//Posicao inicial da string cDados
	Local nQtdeCampo 		:= 0					//Quantidade de telas retornadas
	Local nCount 			:= 0					//Variavel de controle contador	
	
	::oTelasComp := LJCTelasCompProdutos():TelasProd()
		
	/*::cTpDados := SubStr(cDados, nPos, 1)
	nPos ++
    
	::oTelasComp:cMensagem := SubStr(cDados, nPos, 80)
	nPos += 80
	
	nQtdeCampo := Val(SubStr(cDados, nPos, 2))
	nPos += 2*/
	
	/*For nCount := 1 To nQtdeCampo*/
	
		oTelaCompl := LJCTelaComplementar():TelaCompl()
		
		oTelaCompl:cTipoCampo := SubStr(cDados, nPos, 1)
		nPos += 1		
		
		oTelaCompl:nMinimo := Val(SubStr(cDados, nPos, 2))
		nPos += 2

		oTelaCompl:nMaximo := Val(SubStr(cDados, nPos, 2))
		nPos += 2

		oTelaCompl:cCampo := AllTrim(SubStr(cDados, nPos, 20))
		nPos += 20		

		::oTelasComp:Add("T" + AllTrim(Str(nCount)), oTelaCompl)
						
	/*Next*/
				
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BusTelProd�Autor  �Vendas Clientes     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira retornar as telas complementares dos produtos���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto    												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BusTelProd() Class LJCServicoXTelaProduto
Return ::oTelasComp