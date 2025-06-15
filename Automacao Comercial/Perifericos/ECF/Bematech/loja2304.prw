#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH"

Function LOJA2304 ; Return  // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������ͻ��
���Classe    �LJCBematechMP3000THFIV010101  �Autor  �Vendas Clientes � Data �  05/05/08���
��������������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em se comunicar com a impressora Bematech TM-T88FB 01.06.00  ���
��������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		       ���
��������������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
*/
Class LJCBematechMP3000THFIV010101 From LJABematech                 
		
	Method New(oTovsApi)										//Metodo construtor
	
	//Autenticacao e cheque
	Method Autenticar(cLinha, cTexto)											//Autentica documento / cheque
	Method ImpCheque(cBanco	, cValor, cData 	, cFavorecid 	, ;
					 cCidade, cTexto, cExtenso	, cMoedaS 		, ;
					 cMoedaP)  
	Method ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem)				//Configura o codigo de barras
	Method CodBarras(cString) 
	Method LeCMC7()													//Imprime o codigo de barras
					 
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
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
Method New(oTovsApi) Class LJCBematechMP3000THFIV010101

	//Executa o construtor da classe pai
	_Super:New(oTovsApi)
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Autenticar�Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method Autenticar(cLinha, cTexto) Class LJCBematechMP3000THFIV010101

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCheque �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
					 cMoedaP) Class LJCBematechMP3000THFIV010101

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")					 
	    
Return oRetorno     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA2303_ �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
					nFonte, nMargem)	Class LJCBematechMP3000THFIV010101			//Configura o codigo de barras
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   	
    oRetorno := ::ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem)
   	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA2303_ �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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

Method CodBarras(cString) Class LJCBematechMP3000THFIV010101  	//Imprime o codigo de barras
 
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	oRetorno := ::CodBarras(cString)

Return oRetorno   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeCMC7	�Autor  �Vendas Clientes     � Data �  10/06/11   ���
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
Method LeCMC7() Class LJCBematechMP3000THFIV010101

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno
