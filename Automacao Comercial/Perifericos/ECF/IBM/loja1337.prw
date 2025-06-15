#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH"

Function LOJA1337 ; Return  // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������ͻ��
���Classe    �LJCIBM4610SJ6010001    �Autor  �Vendas Clientes     � Data �  20/06/11   ���
��������������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em se comunicar com a impressora IBM 4610-SJ6 v.01.00.01     ���
��������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		       ���
��������������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
*/
Class LJCIBM4610SJ6010001 From LJAIBM                 

	Data lImpCheque 
		
	Method New(oTovsApi)										//Metodo construtor
	
	//Autenticacao e cheque
	Method Autenticar(cLinha, cTexto)											//Autentica documento / cheque
	Method ImpCheque(cBanco	, cValor, cData 	, cFavorecid 	, ;
					 cCidade, cTexto, cExtenso	, cMoedaS 		, ;
					 cMoedaP)  
	Method ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem)				//Configura o codigo de barras
	Method CodBarras(cString) 
	Method LeCMC7()													//Imprime o codigo de barras
    Method GetCodEcf() 	
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  20/06/11   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCSwedaSt120.			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oTotvsAPI) - Objeto do tipo LJCTotvsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New(oTovsApi) Class LJCIBM4610SJ6010001

	//Executa o construtor da classe pai 
		//Executa o construtor da classe pai       
	::lImpCheque := .F.   
	
	_Super:New(oTovsApi) 

	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Autenticar�Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a autenticacao.			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTexto) - Texto a ser impresso na autenticacao.  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Autenticar(cLinha, cTexto) Class LJCIBM4610SJ6010001

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCheque �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a impressao de cheque.		  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cBanco) - Numero do banco.						  ���
���			 �EXPC2 (2 - cValor) - Valor do cheque.						  ���
���			 �EXPC3 (3 - cData) - Data do cheque (ddmmaaaa).		 	  ���
���			 �EXPC4 (4 - cFavorecid) - Nome do favorecido.			   	  ���
���			 �EXPC5 (5 - cCidade) - Cidade a ser impressa no cheque.	  ���
���			 �EXPC6 (6 - cTexto) - Texto adicional impresso no cheque.    ���
���			 �EXPC7 (7 - cExtenso) - Valor do cheque por extenso.	  	  ���
���			 �EXPC8 (8 - cMoedaS) - Moeda por extenso no singular.	  	  ���
���			 �EXPC9 (9 - cMoedaP) - Moeda por extenso no plural.		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpCheque(cBanco	, cValor, cData 	, cFavorecid 	, ;
					 cCidade, cTexto, cExtenso	, cMoedaS 		, ;
					 cMoedaP) Class LJCIBM4610SJ6010001

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")					 
	    
Return oRetorno     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfCodBar�Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por configurar o codigo de barras		  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nAltura) - Altura do codigo de barras  		  ���
���			 �EXPN2 (2 - nLargura) - Largura do codigo de barras 		  ���
���			 �EXPN3 (3 - nPosicao) - Posicao do codigo de barras 		  ���
���			 �EXPN4 (4 - nFonte) - Fonte do codigo de barras  			  ���
���			 �EXPN5 (5 - nMargem) - Margem do codigo de barras 			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Method ConfCodBar(nAltura, nLargura, nPosicao, ;
					nFonte, nMargem)	Class LJCIBM4610SJ6010001			//Configura o codigo de barras
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   	
    oRetorno := ::ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem)
   	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA2303_ �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por configurar o codigo de barras		  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros� EXPC1 (1 - cString) - Valor do codigo de barras.  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/     

Method CodBarras(cString) Class LJCIBM4610SJ6010001  	//Imprime o codigo de barras
 
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	oRetorno := ::CodBarras(cString)

Return oRetorno   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeCMC7	�Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a leitura do CMC7.			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeCMC7() Class LJCIBM4610SJ6010001

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCodEcf �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Codigo da Impressora Referente a 				  ���
���          �TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCodEcf() Class LJCIBM4610SJ6010001 

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := "181301"	//Copia o valor da propriedade da classe

Return oRetorno
